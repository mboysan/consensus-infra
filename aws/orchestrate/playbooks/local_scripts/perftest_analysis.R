#!/usr/bin/env Rscript

#' Analysis of performance test metrics.
#' @description
#' Plots perf test results.
#' @param metrics_file path to metrics file
#' @param output_folder base folder to write output results
#' @param output_file_prefix file prefix for an individual result
#' @examples
#' ./<script>.R <metrics_file> <output_folder> <output_file_prefix>
#' ./perftest_analysis.R metrics.txt ./ client

source("util.R")

args <- commandArgs(trailingOnly=TRUE)
args <- valiadate_args(
  args = args,
  validator = \(x) length(x) == 3,
  failure_msg = "path to metrics file and/or output folder and/or output file prefix missing.",
  defaults = c("collected_metrics/perftest_sample.txt", NULL, NULL)
)

metrics_file <- args[1]
output_folder <- args[2]
output_file_prefix <- args[3]

info("analysing metrics of:", metrics_file)

# ----------------------------------------------------------------------------- latency data

millis_to_seconds <- function(timestamp) {
  as.numeric(timestamp) / 1000
}

us_to_ms <- function(value) {
  as.numeric(value) / 1000
}

# col.names = name, value, timestamp
latency_metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('name', 'value', 'timestamp'))
latency_metrics_csv['timestamp'] <- lapply(latency_metrics_csv['timestamp'], FUN = millis_to_seconds)
class(latency_metrics_csv[, 'timestamp']) <- c('POSIXt', 'POSIXct')

extract <- function(operation) {
  op_csv <- latency_metrics_csv[latency_metrics_csv['name']$name == operation,]
  op_csv['value'] <- lapply(op_csv['value'], FUN = us_to_ms)
  op_csv
}

aggregate_latencies <- function(...) {
  bound <- rbind(...)
  aggregate(value~timestamp, bound, FUN=mean)
}

as_ts <- function(latency_data) {
  idx <- latency_data[, 'timestamp']
  latency_data <- latency_data['value']
  latency_data <- xts(latency_data, order.by = idx)
  latency_data
}

read.latency <- extract('read')
read.failed.latency <- extract('read-failed')
update.latency <- extract('update')
update.failed.latency <- extract('update-failed')
insert.latency <- extract('insert')
insert.failed.latency <- extract('insert-failed')
scan.latency <- extract('scan')
scan.failed.latency <- extract('scan-failed')
read.modify.write.latency <- extract('read-modify-write')
read.modify.write.failed.latency <- extract('read-modify-write-failed')

read.latency.plot <- plot_ts(as_ts(read.latency))
read.latency.plot

update.latency.plot <- plot_ts(as_ts(update.latency))
update.latency.plot

aggregated.latencies <- aggregate_latencies(
  read.latency,
  read.failed.latency,
  update.latency,
  update.failed.latency,
  insert.latency,
  insert.failed.latency,
  scan.latency,
  scan.failed.latency,
  read.modify.write.latency,
  read.modify.write.failed.latency
)
aggregated.latencies.plot <- plot_ts(as_ts(aggregated.latencies))
aggregated.latencies.plot

# ----------------------------------------------------------------------------- summary stats data

extract_summary_stats <- function(csv_data) {
  csv_data[str_count(csv_data['name']$name, "(?<=^\\[).+(?=\\])") == 1,]
}

# col.names = name, type, value
summary_stats_csv <- read.csv(metrics_file, header = FALSE, col.names = c('name', 'type', 'value'))
summary.stats <- extract_summary_stats(summary_stats_csv)
summary.stats

# ----------------------------------------------------------------------------- finalize

all_plots <- list(
  list("read_latency", read.latency.plot),
  list("update_latency", update.latency.plot),
  #...
  list("merged_latencies", aggregated.latencies.plot)
)

save_plots(all_plots, output_folder, output_file_prefix)