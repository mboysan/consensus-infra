#!/usr/bin/env Rscript

source("../remote_data_scripts/util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 1,
    failure_msg = "required arguments are not provided.",
    defaults = c("metrics/samples/EX")
)

io_folder <- args[1]

plot_memory_data <- read.csv(paste(io_folder, "plot_memory.dat", sep="/"), header = TRUE)
plot_memory_data$timestamp_sec <- as.POSIXct(plot_memory_data$timestamp_sec, origin = "1970-01-01")
plot_memory_data$metric_value <- as.numeric(plot_memory_data$metric_value)

ggplot(plot_memory_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "JVM Memory (MB)", title = "JVM Memory Used per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_memory_data", source="controller")

plot_process_cpu_data <- read.csv(paste(io_folder, "plot_cpu.dat", sep="/"), header = TRUE)
plot_process_cpu_data$timestamp_sec <- as.POSIXct(plot_process_cpu_data$timestamp_sec, origin = "1970-01-01")
plot_process_cpu_data$metric_value <- as.numeric(plot_process_cpu_data$metric_value)

ggplot(plot_process_cpu_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Process CPU Usage (%)", title = "Process CPU Usage Percent per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_process_cpu_data", source="controller")
