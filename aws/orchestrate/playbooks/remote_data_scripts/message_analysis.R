#!/usr/bin/env Rscript

#' Analysis of consensus messaging.
#' @description
#' Analysis of consensus messaging.

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 2,
    failure_msg = "required arguments are not provided.",
    defaults = c(
        "../collected_data/metrics/samples/EX",
        # use all.raw.merged.csv or store.raw.merged.csv
        "all.raw.merged.csv"
    )
)

io_folder <- args[1]
input_file <- args[2]

input_file <- paste(io_folder, input_file, sep = "/")

# ----------------------------------------------------------------------------- prepare metrics
info("analysing consensus messaging:", input_file)

# Read the CSV data
data <- read.csv(input_file, header = FALSE, stringsAsFactors = FALSE)

# Rename the columns
names(data) <- c("nodeType", "testGroup", "testName", "consensusAlg", "category", "metric_name", "metric_value", "timestamp")
data$testName_algorithm <- paste0(data$testGroup, data$testName)    # EXEX1
data$testName_algorithm <- paste(data$testName_algorithm, data$consensusAlg, sep = "_")   # EXEX1_raft

# filter for store metrics
data <- data %>% filter(nodeType == "store")

# Extract the message type
data$message_type <- sub(".*\\.", "", data$metric_name)

# filter for relevant data
consensus_requests <- c(
    # raft
    'AppendEntriesRequest',
    'RequestVoteRequest',

    # bizur
    'PleaseVoteRequest',
    'ReplicaReadRequest',
    'ReplicaWriteRequest',
    'CollectKeysRequest',
    'HeartbeatRequest'
)

data <- data %>%
    filter(message_type %in% consensus_requests)

# Order by timestamp
data$timestamp <- as.numeric(data$timestamp)
data <- data %>% arrange(timestamp)

adjust_start_times <- function() {
    minStart <- min(data$timestamp)
    testNames <- unique(data$testName)

    for (testName in testNames) {
        tmp <- data[data$testName == testName,]
        minTestStart <- tmp[1,]$timestamp
        diff <- minTestStart - minStart
        data[data$testName == testName,]$timestamp <- data[data$testName == testName,]$timestamp - diff
    }
    data
}

data <- adjust_start_times()

# Convert the timestamp from milliseconds to POSIXct date-time
data$timestamp_sec <- as.POSIXct(data$timestamp / 1000, origin = "1970-01-01")
# Round the timestamp to the nearest second
data$timestamp_sec <- round(data$timestamp_sec)
data$timestamp_sec <- as.POSIXct(data$timestamp_sec, origin = "1970-01-01")

data$metric_value <- as.numeric(data$metric_value)

# Group the data
data <- data %>% group_by(testName_algorithm, timestamp_sec)

# ----------------------------------------------------------------------------- plots

info("Plotting message counts")
# Count the number of messages per group
message_counts <- data %>% summarise(count = n())

# Plot count of messages, grouped by consensusAlg & timestamp_sec
ggplot(message_counts, aes(x = timestamp_sec, y = count, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Count", title = "Count of Messages per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_message_counts", source = "processor")
rm(message_counts); gc()

info("Plotting message sizes")
# Sum the size of messages per group
message_sizes <- data %>% summarise(sum = sum(metric_value / 1024))

# Plot size of messages, grouped by consensusAlg & timestamp_sec
ggplot(message_sizes, aes(x = timestamp_sec, y = sum, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Sum of Message Sizes (kB)", title = "Sum of Message Sizes per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_message_sizes", source = "processor")
rm(message_sizes); gc()

