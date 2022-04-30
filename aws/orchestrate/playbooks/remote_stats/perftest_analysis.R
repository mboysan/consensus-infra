#!/usr/bin/env Rscript --vanilla

source("util.R")

# ----------------------------------------------------------------------------- latency data

millis_to_seconds <- function(timestamp) {
  as.numeric(timestamp) / 1000
}

# col.names = name, value, timestamp
latency_metrics_csv <- read.csv("perftest_sample.txt", header = FALSE, col.names = c('name', 'value', 'timestamp'))
latency_metrics_csv['timestamp'] <- lapply(latency_metrics_csv['timestamp'], FUN = millis_to_seconds)
class(latency_metrics_csv[, 'timestamp']) <- c('POSIXt', 'POSIXct')

operation_to_ts <- function(operation) {
  extract_latencies <- function(csv_data, operation) {
    csv_data[csv_data['name']$name == operation,]
  }
  us_to_ms <- function(a) {
    as.numeric(a$value) / 1000
  }
  csv_to_ts(operation, latency_metrics_csv, extract_latencies, us_to_ms)
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
summary_stats_csv <- read.csv("perftest_sample.txt", header = FALSE, col.names = c('name', 'type', 'value'))
summary.stats <- extract_summary_stats(summary_stats_csv)
summary.stats

# ----------------------------------------------------------------------------- finalize

all_plots <- list(
  list("read_latency", read.latency.plot),
  list("update_latency", update.latency.plot)
  #...
)

save_plots(all_plots)