#!/usr/bin/env Rscript

#' Analysis of consensus messaging.
#' @description
#' Analysis of consensus messaging.
#' @param metrics_file path to metrics file
#' @param output_folder base folder to write output results
#' @param output_file_prefix file prefix for an individual result
#' @examples
#' ./<script>.R <metrics_file> <output_folder> <output_file_prefix>

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 3,
    failure_msg = "path to metrics file and/or output folder and/or output file prefix missing.",
    # raft
    # defaults = c("collected_metrics/EX1/node2.metrics.txt", NULL, NULL)

    # bizur
    # defaults = c("collected_metrics/EX2/node2.metrics.txt", NULL, NULL)

    # MERGED
    defaults = c("collected_metrics/MERGED/all.raw.merged.csv", NULL, NULL)
)

metrics_file <- args[1]
output_folder <- args[2]
output_file_prefix <- args[3]

# ----------------------------------------------------------------------------- prepare metrics
info("analysing consensus messaging:", metrics_file)

# Read the CSV data
data <- read.csv(metrics_file, header = FALSE, stringsAsFactors = FALSE)

# Rename the columns
# names(data) <- c("metric_name", "metric_value", "timestamp")
names(data) <- c("nodeType", "testName", "category", "metric_name", "metric_value", "timestamp")

# -------- Extract the message type
data$message_type <- sub(".*\\.", "", data$metric_name)

# -------- Filter for consensus requests
# raft
consensus_requests <- c("AppendEntriesRequest", "RequestVoteRequest")
raft_data <- data %>%
    filter(message_type %in% consensus_requests)
raft_data$consensus_alg <- "raft"
raft_data$timestamp <- as.numeric(raft_data$timestamp)
raftStartTime <- min(raft_data$timestamp)

# bizur
consensus_requests <- c(
    'PleaseVoteRequest',
    'ReplicaReadRequest',
    'ReplicaWriteRequest',
    'CollectKeysRequest',
    'HeartbeatRequest'
)
bizur_data <- data %>%
    filter(message_type %in% consensus_requests)
bizur_data$consensus_alg <- "bizur"
bizur_data$timestamp <- as.numeric(bizur_data$timestamp)
bizurStartTime <- min(bizur_data$timestamp)

# scale timestamp origin
if (raftStartTime < bizurStartTime) {
    subtractTime <- bizurStartTime - raftStartTime
    bizur_data$timestamp <- bizur_data$timestamp - subtractTime
} else {
    subtractTime <- raftStartTime - bizurStartTime
    raft_data$timestamp <- raft_data$timestamp - subtractTime
}

# Merge all data
data <- rbind(raft_data, bizur_data)
data$timestamp <- as.numeric(data$timestamp)
data$metric_value <- as.numeric(data$metric_value)

# Convert the timestamp from milliseconds to POSIXct date-time
data$timestamp_sec <- as.POSIXct(data$timestamp / 1000, origin = "1970-01-01")
# Round the timestamp to the nearest second
data$timestamp_sec <- round(data$timestamp_sec)
data$timestamp_sec <- as.POSIXct(data$timestamp_sec, origin = "1970-01-01")


# Group the data
grouped_data <- data %>% group_by(testName, consensus_alg, timestamp_sec)

# Count the number of messages per group
message_counts <- grouped_data %>% summarise(count = n())

# Sum the size of messages per group
message_sizes <- grouped_data %>% summarise(sum = sum(metric_value / 1024))

# Order the data based on timestamp_sec
ordered_message_counts <- message_counts %>% arrange(timestamp_sec)
ordered_message_sizes <- message_sizes %>% arrange(timestamp_sec)

# Plot count of messages, grouped by consensus_alg & timestamp_sec
ggplot(ordered_message_counts, aes(x = timestamp_sec, y = count, color = consensus_alg)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Count", title = "Count of Messages per Second") +
    theme_minimal()

# Plot size of messages, grouped by consensus_alg & timestamp_sec
ggplot(ordered_message_sizes, aes(x = timestamp_sec, y = sum, color = consensus_alg)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Sum of Message Sizes (kB)", title = "Sum of Message Sizes per Second") +
    theme_minimal()
