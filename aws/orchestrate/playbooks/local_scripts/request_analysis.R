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
  defaults = c("collected_metrics/EX1/node2.metrics.txt", NULL, NULL)
)

metrics_file <- args[1]
output_folder <- args[2]
output_file_prefix <- args[3]

# ----------------------------------------------------------------------------- prepare metrics
info("analysing consensus messaging:", metrics_file)

# Read the CSV data
# data <- read.csv("collected_metrics/EX1/node2.metrics.txt", header = FALSE, stringsAsFactors = FALSE)
data <- read.csv(metrics_file, header = FALSE, stringsAsFactors = FALSE)

# Rename the columns
names(data) <- c("metric_name", "metric_value", "timestamp")

# Extract the message type
data$message_type <- sub(".*\\.", "", data$metric_name)

# Filter for consensus requests
consensus_requests <- c("AppendEntriesRequest", "RequestVoteRequest")
# consensus_requests <- c(
#   'PleaseVoteRequest',
#   'ReplicaReadRequest',
#   'ReplicaWriteRequest',
#   'CollectKeysRequest',
#   'HeartbeatRequest'
# )
data <- data %>%
  filter(message_type %in% consensus_requests)

# Determine if the message is a request or a response
# data$message_kind <- ifelse(grepl("send", data$metric_name), "request", "response")

# Convert the timestamp from milliseconds to POSIXct date-time
data$timestamp_sec <- as.POSIXct(data$timestamp / 1000, origin="1970-01-01")
# Round the timestamp to the nearest second
data$timestamp_sec <- round(data$timestamp_sec)
data$timestamp_sec <- as.POSIXct(data$timestamp_sec, origin="1970-01-01")

# Group the data by message type and second
# grouped_data <- data %>% group_by(message_type, timestamp_sec, message_kind)
grouped_data <- data %>% group_by(message_type, timestamp_sec)

# Count the number of messages per group
message_counts <- grouped_data %>% summarise(count = n())

# Sum the size of messages per group (TODO: rename count to sum)
# message_counts <- grouped_data %>% summarise(count = sum(metric_value))

# Order the data based on timestamp_sec
ordered_message_counts <- message_counts %>% arrange(timestamp_sec)

ordered_message_counts

# Plot the data
ggplot(ordered_message_counts, aes(x = timestamp_sec, y = count, color = message_type)) +
  geom_line() +
  labs(x = "Time (seconds)", y = "Count", title = "Count of Messages per Second") +
  theme_minimal()

sum(ordered_message_counts$count)
