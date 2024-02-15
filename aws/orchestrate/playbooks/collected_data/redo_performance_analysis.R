#!/usr/bin/env Rscript

source("../remote_data_scripts/util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 1,
    failure_msg = "required arguments are not provided.",
    defaults = c("metrics/EX1 EX2")
)

io_folder <- args[1]

plot_read_latency <- read.csv(paste(io_folder, "plot_read_latency.dat", sep="/"), header = TRUE)
plot_read_latency$timestamp_sec <- as.POSIXct(plot_read_latency$timestamp_sec, origin = "1970-01-01")
plot_read_latency$metric_value <- as.numeric(plot_read_latency$metric_value)

ggplot(plot_read_latency, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    stat_summary(fun=mean, geom="line") +
    labs(x = "Time (seconds)", y = "Read Latency (ms)", title = "Read Latency per Second") +
    theme_minimal()
savePlot(io_folder, "plot_read_latency")

plot_update_latency <- read.csv(paste(io_folder, "plot_update_latency.dat", sep="/"), header = TRUE)
plot_update_latency$timestamp_sec <- as.POSIXct(plot_update_latency$timestamp_sec, origin = "1970-01-01")
plot_update_latency$metric_value <- as.numeric(plot_update_latency$metric_value)

ggplot(plot_update_latency, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    stat_summary(fun=mean, geom="line") +
    labs(x = "Time (seconds)", y = "Update Latency (ms)", title = "Update Latency per Second") +
    theme_minimal()
savePlot(io_folder, "plot_update_latency")

plot_operation_latency <- read.csv(paste(io_folder, "plot_operation_latency.dat", sep="/"), header = TRUE)
plot_operation_latency$timestamp_sec <- as.POSIXct(plot_operation_latency$timestamp_sec, origin = "1970-01-01")
plot_operation_latency$metric_value <- as.numeric(plot_operation_latency$metric_value)

ggplot(plot_operation_latency, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    stat_summary(fun=mean, geom="line") +
    labs(x = "Time (seconds)", y = "Operation Latency (ms)", title = "Operation Latency per Second") +
    theme_minimal()
savePlot(io_folder, "plot_operation_latency")
