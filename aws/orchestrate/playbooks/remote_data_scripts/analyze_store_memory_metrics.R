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
        "store.memory.raw.merged.csv"
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
# total memory consumption calculated with somes of both heap & non-heap spaces of:
# jvm.memory.committed
# jvm.memory.max
# jvm.memory.used

# For simplicity, we'll be using the following metrics:
# jvm.memory.used

info("Plotting memory data")

data <- data %>% filter(metric_name == "jvm.memory.used")

# convert to MB
data$metric_value <- data$metric_value / 1000 / 1000

# Plot memory usage, grouped by consensusAlg, metric_name & timestamp_sec
ggplot(data, aes(x = timestamp_sec, y = metric_value, color = test_id)) +
    geom_point() +
    geom_line() +
    labs(x = "Time (seconds)", y = "JVM Memory (MB)", title = "JVM Memory Used per Second") +
    theme_minimal()
exportPlot(io_folder, "plot_memory_data", source = "processor")
