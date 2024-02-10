#!/usr/bin/env Rscript

#' Analysis of performance measurements (client metrics).
#' @description
#' Analysis of performance measurements (client metrics)

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
  args = args,
  validator = \(x) length(x) > 2,
  failure_msg = "required arguments are not provided.",
  # use all.raw.merged.csv or client.raw.merged.csv
  defaults = c("collected_metrics/MERGED/all.raw.merged.csv", "", "EX1", "EX2")
)

input_file <- args[1]
output_folder <- args[2]
test_names <- args[-c(1, 2)]

# ----------------------------------------------------------------------------- prepare metrics
# Read the CSV data
data <- read.csv(input_file, header = FALSE, stringsAsFactors = FALSE)

# Rename the columns
names(data) <- c("nodeType", "testName", "consensusAlg", "category", "metric_name", "metric_value", "timestamp")
data$testName_algorithm <- paste(data$testName, data$consensusAlg, sep = "_")

# filter for store metrics and test names
data <- data %>%
  filter(nodeType == "client") %>%
  filter(testName %in% test_names)

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

# Convert the timestamp from "milliseconds to seconds" to POSIXct date-time
data$timestamp_sec <- as.POSIXct(data$timestamp/1000, origin = "1970-01-01")
# Round the timestamp to the nearest second
data$timestamp_sec <- round(data$timestamp_sec)
data$timestamp_sec <- as.POSIXct(data$timestamp_sec, origin = "1970-01-01")

data$metric_value <- as.numeric(data$metric_value)

# Group the data
grouped_data <- data %>% group_by(testName_algorithm, consensusAlg, timestamp_sec)

# ----------------------------------------------------------------------------- calculations

# convert us to ms
grouped_data$metric_value <- grouped_data$metric_value / 1000

# client read latency
read_latency_data <- grouped_data %>%
  filter(metric_name == "read")

# client update latency
update_latency_data <- grouped_data %>%
  filter(metric_name == "update")

# ----------------------------------------------------------------------------- plots
# Plot read latency, grouped by consensusAlg & timestamp_sec
ggplot(read_latency_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
  stat_summary(fun=mean, geom="line") +
  labs(x = "Time (seconds)", y = "Read Latency (ms)", title = "Read Latency per Second") +
  theme_minimal()

# Plot update latency, grouped by consensusAlg & timestamp_sec
ggplot(update_latency_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
  stat_summary(fun=mean, geom="line") +
  labs(x = "Time (seconds)", y = "Update Latency (ms)", title = "Update Latency per Second") +
  theme_minimal()

# Plot operation latency, grouped by consensusAlg & timestamp_sec
ggplot(grouped_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
  stat_summary(fun=mean, geom="line") +
  labs(x = "Time (seconds)", y = "Operation Latency (ms)", title = "Operation Latency per Second") +
  theme_minimal()
