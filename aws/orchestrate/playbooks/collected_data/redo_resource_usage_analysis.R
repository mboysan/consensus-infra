#!/usr/bin/env Rscript

source("../remote_data_scripts/util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 2,
    failure_msg = "required arguments are not provided.",
    defaults = c("metrics/EX1 EX2", "metrics/EX1 EX2")
)

input_folder <- args[1]
output_folder <- args[2]

memory_data <- read.csv(paste(input_folder, "plot_memory.dat", sep="/"), header = TRUE)
memory_data$timestamp_sec <- as.POSIXct(memory_data$timestamp_sec, origin = "1970-01-01")
memory_data$metric_value <- as.numeric(memory_data$metric_value)

ggplot(memory_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "JVM Memory (MB)", title = "JVM Memory Used per Second") +
    theme_minimal()

process_cpu_data <- read.csv(paste(input_folder, "plot_cpu.dat", sep="/"), header = TRUE)
process_cpu_data$timestamp_sec <- as.POSIXct(process_cpu_data$timestamp_sec, origin = "1970-01-01")
process_cpu_data$metric_value <- as.numeric(process_cpu_data$metric_value)

ggplot(process_cpu_data, aes(x = timestamp_sec, y = metric_value, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Process CPU Usage (%)", title = "Process CPU Usage Percent per Second") +
    theme_minimal()
