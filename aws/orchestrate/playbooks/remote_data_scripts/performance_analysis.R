#!/usr/bin/env Rscript

#' Analysis of performance measurements (client metrics).
#' @description
#' Analysis of performance measurements (client metrics)

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 4,
    failure_msg = "required arguments are not provided.",
    defaults = c(
        "../collected_data/metrics/samples/EX",
        # use all.raw.merged.csv or client.raw.merged.csv
        "all.raw.merged.csv",
        "remove_outliers_per_test=true",
        "timescale_in_milliseconds=false"
    )
)

io_folder <- args[1]
input_file <- args[2]
remove_outliers_per_test <- grepl("true", args[3], ignore.case = TRUE)
timescale_in_milliseconds <- grepl("true", args[4], ignore.case = TRUE)

input_file <- paste(io_folder, input_file, sep = "/")

# ----------------------------------------------------------------------------- prepare metrics
# Read the CSV data
data <- read.csv(input_file, header = FALSE, stringsAsFactors = FALSE)

# Rename the columns
names(data) <- c("nodeType", "testGroup", "testName", "consensusAlg", "category", "metric_name", "metric_value", "timestamp")
data$testName_algorithm <- paste0(data$testGroup, data$testName)    # EXEX1
data$testName_algorithm <- paste(data$testName_algorithm, data$consensusAlg, sep = "_")   # EXEX1_raft

# filter for client metrics
data <- data %>% filter(nodeType == "client")

testNames <- unique(data$testName)

# Order by timestamp
data$timestamp <- as.numeric(data$timestamp)
data <- data %>% arrange(timestamp)

adjust_start_times <- function() {
    minStart <- min(data$timestamp)
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
data$timestamp_sec <- as.POSIXct(data$timestamp / 1000, origin = "1970-01-01")

roundToNearestSecond <- function(data) {
    info("Rounding the timestamp to the nearest second")
    data$timestamp_sec <- round(data$timestamp_sec)
    data$timestamp_sec <- as.POSIXct(data$timestamp_sec, origin = "1970-01-01")
    data
}

if (!timescale_in_milliseconds) {
    data <- roundToNearestSecond(data)
}

# ----------------------------------------------------------------------------- calculations

data$metric_value <- as.numeric(data$metric_value)

removeOutliersPerTest <- function(data) {
    info("Removing outliers per test")
    newData <- data.frame()
    for (test in testNames) {
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
if (timescale_in_milliseconds) {
    data <- data %>%
        group_by(testName_algorithm, metric_name, timestamp_sec)
} else {
    data <- data %>%
        group_by(testName_algorithm, metric_name, timestamp_sec) %>%
        mutate(metric_value = mean(metric_value)) %>%
        distinct(testName_algorithm, metric_name, metric_value, timestamp_sec, .keep_all = TRUE)
}

info("Converting metric_value from microseconds to milliseconds")
data$metric_value <- data$metric_value / 1000

read_latency_data <- data %>% filter(metric_name == "read")
update_latency_data <- data %>% filter(metric_name == "update")

# ----------------------------------------------------------------------------- plots
info("Plotting read latency")
ggplot(read_latency_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    stat_summary(fun = mean, geom = "line") +
    labs(x = "Time (seconds)", y = "Read Latency (ms)", title = "Read Latency per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_read_latency", source = "processor")

info("Plotting update latency")
ggplot(update_latency_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    stat_summary(fun = mean, geom = "line") +
    labs(x = "Time (seconds)", y = "Update Latency (ms)", title = "Update Latency per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_update_latency", source = "processor")

info("Plotting operation latency")
ggplot(data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    stat_summary(fun = mean, geom = "line") +
    labs(x = "Time (seconds)", y = "Operation Latency (ms)", title = "Operation Latency per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_operation_latency", source = "processor")
