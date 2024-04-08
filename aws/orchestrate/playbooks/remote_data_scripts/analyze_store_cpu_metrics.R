#!/usr/bin/env Rscript

#' Analysis of resource usage metrics.
#' @description
#' Analysis of resource usage metrics.

source("util.R")
source("util_store.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 2,
    failure_msg = "required arguments are not provided.",
    defaults = c(
        "../collected_data/metrics/samples/EX",
        "store.cpu.raw.merged.csv"
    )
)

io_folder <- args[1]
input_file <- args[2]

input_file <- paste(io_folder, input_file, sep = "/")

# ----------------------------------------------------------------------------- prepare metrics
# Read the CSV data
data <- read.csv(input_file, header = FALSE, stringsAsFactors = FALSE)
data <- prepareStoreResourceUsageMetrics(data)

# order by timestamp
data <- data %>% arrange(timestamp)

# ----------------------------------------------------------------------------- plots
# system.cpu.count = number of cpu cores used
# system.load.average.1m = 1 minute cpu load average, calculation of load = (loadAverage / cpuCount) * 100 (https://dzone.com/articles/what-is-load-average)
# system.cpu.usage = What % load the overall system is at, from 0.0-1.0 (https://stackoverflow.com/a/27282046)
# process.cpu.usage = What % CPU load this current JVM is taking, from 0.0-1.0 (https://stackoverflow.com/a/27282046)

# For simplicity, we'll be using the following metrics:
# process.cpu.usage

info("Plotting cpu data")

data <- data %>% filter(metric_name == "process.cpu.usage")

# Plot process cpu usage, grouped by consensusAlg, metric_name & timestamp_sec
ggplot(data, aes(x = timestamp_sec, y = metric_value, color = test_id)) +
    geom_point() +
    geom_line() +
    labs(x = "Time (seconds)", y = "Process CPU Usage (%)", title = "Process CPU Usage Percent per Second") +
    theme_minimal() +
    theme(legend.position = "bottom")
exportPlot(io_folder, "plot_process_cpu_data", source = "processor")
