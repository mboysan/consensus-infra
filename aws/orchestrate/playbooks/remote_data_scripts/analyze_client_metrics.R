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
        "client.raw.merged.csv",
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
names(data) <- c("nodeType", "testGroup", "testName", "clusterType", "consensusAlg", "category", "metric_name", "metric_value", "timestamp")
data$test_id <- paste0(data$testGroup, data$testName)    # EXEX1
data$test_id <- paste(data$test_id, data$clusterType, data$consensusAlg, sep = "_")   # EXEX1_consensus_raft

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

    # extract minutes:seconds string using substr and store time information as POSIXct, using an arbitrary date
    # inspired by: https://stackoverflow.com/a/12868358
    data$timestamp_sec <- as.POSIXct(paste("2012-01-01", substr(data$timestamp_sec, 15, 20)))
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
        group_by(test_id, metric_name, timestamp_sec)
} else {
    data <- data %>%
        group_by(test_id, metric_name, timestamp_sec) %>%
        mutate(metric_value = mean(metric_value)) %>%
        distinct(test_id, metric_name, metric_value, timestamp_sec, .keep_all = TRUE)
}

info("Converting metric_value from microseconds to milliseconds")
data$metric_value <- data$metric_value / 1000

# ----------------------------------------------------------------------------- plots
info("Plotting read latency")
successful_read_latency_data <- data %>% filter(metric_name == "read")
failed_read_latency_data <- data %>% filter(metric_name == "read-failed")
ggplot(successful_read_latency_data, aes(x = timestamp_sec, y = metric_value, color = test_id)) +
    # geom_point() +
    stat_summary(fun = mean, geom = "line") +
    geom_point(data = failed_read_latency_data, aes(x = timestamp_sec, y = metric_value, color = test_id), size = 4, shape = 4) +
    labs(x = "Time (min:sec)", y = "Read Latency (ms)", title = "Read Latency per Second") +
    theme_minimal() +
    theme(legend.position = "bottom")
exportPlot(io_folder, "plot_read_latency", source = "processor")
rm(successful_read_latency_data); gc()
rm(failed_read_latency_data); gc()

info("Plotting update latency")
successful_update_latency_data <- data %>% filter(metric_name == "update")
failed_update_latency_data <- data %>% filter(metric_name == "update-failed")
ggplot(successful_update_latency_data, aes(x = timestamp_sec, y = metric_value, color = test_id)) +
    # geom_point() +
    stat_summary(fun = mean, geom = "line") +
    geom_point(data = failed_update_latency_data, aes(x = timestamp_sec, y = metric_value, color = test_id), size = 4, shape = 4) +
    labs(x = "Time (min:sec)", y = "Update Latency (ms)", title = "Update Latency per Second") +
    theme_minimal() +
    theme(legend.position = "bottom")
exportPlot(io_folder, "plot_update_latency", source = "processor")
rm(successful_update_latency_data); gc()
rm(failed_update_latency_data); gc()

info("Plotting operation latency")
successful_latency_data <- data %>% filter(!grepl("failed", metric_name, ignore.case = TRUE))
failed_latency_data <- data %>% filter(grepl("failed", metric_name, ignore.case = TRUE))
ggplot(successful_latency_data, aes(x = timestamp_sec, y = metric_value, color = test_id)) +
    # geom_point() +
    stat_summary(fun = mean, geom = "line") +
    geom_point(data = failed_latency_data, aes(x = timestamp_sec, y = metric_value, color = test_id), size = 4, shape = 4) +
    labs(x = "Time (min:sec)", y = "Operation Latency (ms)", title = "Operation Latency per Second") +
    theme_minimal() +
    theme(legend.position = "bottom")
exportPlot(io_folder, "plot_operation_latency", source = "processor")
