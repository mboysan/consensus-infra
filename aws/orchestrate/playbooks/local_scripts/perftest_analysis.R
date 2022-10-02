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

operation_to_ts <- function(operation) {
  op_csv <- latency_metrics_csv[latency_metrics_csv['name']$name == operation,]
  op_csv['value'] <- lapply(op_csv['value'], FUN = us_to_ms)
  idx <- op_csv[, 'timestamp']
  op_csv <- op_csv['value']
  op_csv <- xts(op_csv, order.by = idx)
  op_csv
}

read.latency <- operation_to_ts('read')
read.failed.latency <- operation_to_ts('read-failed')
update.latency <- operation_to_ts('update')
update.failed.latency <- operation_to_ts('update-failed')
insert.latency <- operation_to_ts('insert')
insert.failed.latency <- operation_to_ts('insert-failed')
scan.latency <- operation_to_ts('scan')
scan.failed.latency <- operation_to_ts('scan-failed')
read.modify.write.latency <- operation_to_ts('read-modify-write')
read.modify.write.failed.latency <- operation_to_ts('read-modify-write-failed')

read.latency.plot <- plot_ts(list(read.latency))
read.latency.plot

update.latency.plot <- plot_ts(list(update.latency))
update.latency.plot

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
  list("update_latency", update.latency.plot)
  #...
)

save_plots(all_plots, output_folder, output_file_prefix)