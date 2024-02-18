#!/usr/bin/env Rscript

#' Analysis of performance measurements (client metrics).
#' @description
#' Analysis of performance measurements (client metrics)

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
  args = args,
  validator = \(x) length(x) > 5,
  failure_msg = "required arguments are not provided.",
  # use all.raw.merged.csv or client.raw.merged.csv
  defaults = c(
      "../collected_data/metrics/samples/MERGED/all.raw.merged.csv",
      "../collected_data/metrics/samples/EX1 EX2",
      "remove_outliers_per_test=true",
      "timescale_in_milliseconds=true",
      "collect_plot_raw_data=true",
      "EX1",
      "EX2"
  )
)

input_file <- args[1]
output_folder <- args[2]
remove_outliers_per_test <- grepl("true", args[3], ignore.case = TRUE)
timescale_in_milliseconds <- grepl("true", args[4], ignore.case = TRUE)
collect_plot_raw_data <- grepl("true", args[5], ignore.case = TRUE)
test_names <- args[-c(1:5)]

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
  for (testName in test_names) {
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

roundToNearestSecond <- function (data) {
    # Round the timestamp to the nearest second
    data$timestamp_sec <- round(data$timestamp_sec)
    data$timestamp_sec <- as.POSIXct(data$timestamp_sec, origin = "1970-01-01")
    data
}

if (!timescale_in_milliseconds) {
    data <- roundToNearestSecond(data)
}

# ----------------------------------------------------------------------------- calculations

data$metric_value <- as.numeric(data$metric_value)

removeOutliersPerTest <- function (data) {
    # Remove outliers per test
    info("Removing outliers per test")
    newData <- data.frame()
    for (test in test_names) {
        test_data <- data[data$testName == test,]
        test_data <- test_data[remove_outliers(test_data$metric_value),]
        newData <- rbind(newData, test_data)
    }
    newData
}
if (remove_outliers_per_test) {
    data <- removeOutliersPerTest(data)
}

# Group the data
grouped_data <- data

if (timescale_in_milliseconds) {
    grouped_data <- data %>%
        group_by(testName_algorithm, metric_name, timestamp_sec)
} else {
    grouped_data <- data %>%
        group_by(testName_algorithm, metric_name, timestamp_sec) %>%
        mutate(metric_value = mean(metric_value)) %>%
        distinct(testName_algorithm, metric_name, metric_value, timestamp_sec, .keep_all = TRUE)
}

# convert us to ms
grouped_data$metric_value <- grouped_data$metric_value / 1000

# client read latency
read_latency_data <- grouped_data %>%
  filter(metric_name == "read")


# client update latency
update_latency_data <- grouped_data %>%
  filter(metric_name == "update")

# ----------------------------------------------------------------------------- plots
# Plot read latency, grouped by consensusAlg, metric & timestamp_sec
plot_read_latency <- ggplot(read_latency_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
  stat_summary(fun=mean, geom="line") +
  labs(x = "Time (seconds)", y = "Read Latency (ms)", title = "Read Latency per Second") +
  theme_minimal()
exportPlot(output_folder, "plot_read_latency", source="processor")

# Plot update latency, grouped by consensusAlg, metric & timestamp_sec
plot_update_latency <- ggplot(update_latency_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
  stat_summary(fun=mean, geom="line") +
  labs(x = "Time (seconds)", y = "Update Latency (ms)", title = "Update Latency per Second") +
  theme_minimal()
exportPlot(output_folder, "plot_update_latency", source="processor")

# Plot operation latency, grouped by consensusAlg, metric & timestamp_sec
plot_operation_latency <- ggplot(grouped_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
  stat_summary(fun=mean, geom="line") +
  labs(x = "Time (seconds)", y = "Operation Latency (ms)", title = "Operation Latency per Second") +
  theme_minimal()
exportPlot(output_folder, "plot_operation_latency", source="processor")

if (collect_plot_raw_data) {
    columnNames <- c("timestamp_sec", "metric_value", "testName_algorithm", ".group")
    savePlotData(plot_read_latency$data, columnNames, paste(output_folder, "plot_read_latency.dat", sep="/"))
    savePlotData(plot_update_latency$data, columnNames, paste(output_folder, "plot_update_latency.dat", sep="/"))
    savePlotData(plot_operation_latency$data, columnNames, paste(output_folder, "plot_operation_latency.dat", sep="/"))
}