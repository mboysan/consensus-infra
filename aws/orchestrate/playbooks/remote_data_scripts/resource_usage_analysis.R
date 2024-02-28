#!/usr/bin/env Rscript

#' Analysis of resource usage metrics.
#' @description
#' Analysis of resource usage metrics.

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
# Read the CSV data
data <- read.csv(input_file, header = FALSE, stringsAsFactors = FALSE)

# Rename the columns
names(data) <- c("nodeType", "testGroup", "testName", "consensusAlg", "category", "metric_name", "metric_value", "timestamp")
data$testName_algorithm <- paste0(data$testGroup, data$testName)    # EXEX1
data$testName_algorithm <- paste(data$testName_algorithm, data$consensusAlg, sep = "_")   # EXEX1_raft

# filter for store metrics and test names
data <- data %>% filter(nodeType == "store")

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

# Convert the timestamp from "seconds" to POSIXct date-time
data$timestamp_sec <- as.POSIXct(data$timestamp, origin = "1970-01-01")
# Round the timestamp to the nearest second
data$timestamp_sec <- round(data$timestamp_sec)
data$timestamp_sec <- as.POSIXct(data$timestamp_sec, origin = "1970-01-01")

data$metric_value <- as.numeric(data$metric_value)

# Group the data
data <- data %>% group_by(testName_algorithm, metric_name, timestamp_sec)

# ----------------------------------------------------------------------------- plots

# total memory consumption calculated with somes of both heap & non-heap spaces of:
# jvm.memory.committed
# jvm.memory.max
# jvm.memory.used

# system.cpu.count = number of cpu cores used
# system.load.average.1m = 1 minute cpu load average, calculation of load = (loadAverage / cpuCount) * 100 (https://dzone.com/articles/what-is-load-average)
# system.cpu.usage = What % load the overall system is at, from 0.0-1.0 (https://stackoverflow.com/a/27282046)
# process.cpu.usage = What % CPU load this current JVM is taking, from 0.0-1.0 (https://stackoverflow.com/a/27282046)

# For simplicity, we'll be using the following metrics:
# jvm.memory.used
# process.cpu.usage

info("Plotting memory data")
# jvm memory usage
memory_data <- data %>% filter(metric_name == "jvm.memory.used")
# convert to MB
memory_data$metric_value <- memory_data$metric_value / 1000 / 1000

# Plot memory usage, grouped by consensusAlg, metric_name & timestamp_sec
ggplot(memory_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "JVM Memory (MB)", title = "JVM Memory Used per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_memory_data", source = "processor")
rm(memory_data); gc()

info("Plotting cpu data")
# process cpu usage
process_cpu_data <- data %>% filter(metric_name == "process.cpu.usage")

# Plot process cpu usage, grouped by consensusAlg, metric_name & timestamp_sec
ggplot(process_cpu_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Process CPU Usage (%)", title = "Process CPU Usage Percent per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_process_cpu_data", source = "processor")

