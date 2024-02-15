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

plot_message_counts <- read.csv(paste(io_folder, "plot_message_counts.dat", sep="/"), header = TRUE)
plot_message_counts$timestamp_sec <- as.POSIXct(plot_message_counts$timestamp_sec, origin = "1970-01-01")
plot_message_counts$count <- as.numeric(plot_message_counts$count)

ggplot(plot_message_counts, aes(x = timestamp_sec, y = count, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Count", title = "Count of Messages per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_message_counts", source="controller")

plot_message_sizes <- read.csv(paste(io_folder, "plot_message_sizes.dat", sep="/"), header = TRUE)
plot_message_sizes$timestamp_sec <- as.POSIXct(plot_message_sizes$timestamp_sec, origin = "1970-01-01")
plot_message_sizes$sum <- as.numeric(plot_message_sizes$sum)

ggplot(plot_message_sizes, aes(x = timestamp_sec, y = sum, color = testName_algorithm)) +
    geom_line() +
    labs(x = "Time (seconds)", y = "Sum of Message Sizes (kB)", title = "Sum of Message Sizes per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_message_sizes", source="controller")
