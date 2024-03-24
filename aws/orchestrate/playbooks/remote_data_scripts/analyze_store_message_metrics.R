#!/usr/bin/env Rscript

#' Analysis of consensus messaging.
#' @description
#' Analysis of consensus messaging.

source("util.R")
source("util_store.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 2,
    failure_msg = "required arguments are not provided.",
    defaults = c(
        "../collected_data/metrics/samples/EX",
        "store.message.raw.merged.csv"
    )
)

io_folder <- args[1]
input_file <- args[2]

input_file <- paste(io_folder, input_file, sep = "/")

# ----------------------------------------------------------------------------- prepare metrics
info("analysing consensus messaging:", input_file)

# Read the CSV data
data <- read.csv(input_file, header = FALSE, stringsAsFactors = FALSE)
data <- prepareStoreResourceUsageMetrics(data)

# Extract the message type
data$metric_name <- sub(".*\\.", "", data$metric_name)

# NB! See searchStrings in collect_store_message_metrics.R to understand the message types that are being analyzed.

# ----------------------------------------------------------------------------- plots

info("Plotting message counts")
# Count the number of messages per group
message_counts <- data %>% summarise(count = n())

# order by timestamp
message_counts <- message_counts %>% arrange(timestamp_sec)

# Plot count of messages, grouped by consensusAlg & timestamp_sec
ggplot(message_counts, aes(x = timestamp_sec, y = count, color = testName_algorithm)) +
    geom_point() +
    geom_line() +
    labs(x = "Time (seconds)", y = "Count", title = "Count of Messages per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_message_counts", source = "processor")
rm(message_counts); gc()

info("Plotting message sizes")
# Sum the size of messages per group
message_sizes <- data %>% summarise(sum = sum(metric_value / 1024))

# order by timestamp
message_sizes <- message_sizes %>% arrange(timestamp_sec)

# Plot size of messages, grouped by consensusAlg & timestamp_sec
ggplot(message_sizes, aes(x = timestamp_sec, y = sum, color = testName_algorithm)) +
    geom_point() +
    geom_line() +
    labs(x = "Time (seconds)", y = "Sum of Message Sizes (kB)", title = "Sum of Message Sizes per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_message_sizes", source = "processor")
