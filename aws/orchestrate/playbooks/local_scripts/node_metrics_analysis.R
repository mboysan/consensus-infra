#!/usr/bin/env Rscript

#' Analysis of node metrics resource usage metrics.
#' @description
#' Plots node metrics related results.
#' @param metrics_file path to metrics file
#' @param output_folder base folder to write output results
#' @param output_file_prefix file prefix for an individual result
#' @examples
#' ./<script>.R <metrics_file> <output_folder> <output_file_prefix>
#' ./node_metrics_analysis.R metrics.txt ./ client

source("util.R")

args <- commandArgs(trailingOnly=TRUE)
args <- valiadate_args(
  args = args,
  validator = \(x) length(x) == 3,
  failure_msg = "path to metrics file and/or output folder and/or output file prefix missing.",
  defaults = c("collected_metrics/node_metrics_sample.txt", NULL, NULL)
)

metrics_file <- args[1]
output_folder <- args[2]
output_file_prefix <- args[3]

# ----------------------------------------------------------------------------- prepare metrics
info("analysing metrics of:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('name', 'value', 'timestamp'))
class(metrics_csv[, 'timestamp']) <- c('POSIXt', 'POSIXct')

# ----------------------------------------------------------------------------- process jvm memory data

memory_to_ts <- function(name) {
  extract <- function(csv_data, prefix) {
    csv_data[startsWith(csv_data['name']$name, prefix),]
  }
  memory_sum <- function(a) {
    bytes_to_megabytes <- function(bytes) {
      bytes / (1000 * 1000)
    }
    sum(bytes_to_megabytes(as.numeric(a$value)))
  }
  csv_to_ts(name, metrics_csv, extract, memory_sum)
}

jvm.memory.max <- memory_to_ts('jvm.memory.max')
jvm.memory.committed <- memory_to_ts('jvm.memory.committed')
jvm.memory.used <- memory_to_ts('jvm.memory.used')

jvm.memory.plot <- plot_ts(list(
  jvm.memory.max,
  jvm.memory.committed,
  jvm.memory.used
))
jvm.memory.plot

# ----------------------------------------------------------------------------- process cpu data

cpu_to_ts <- function(name) {
  extract <- function(csv_data, prefix) {
    csv_data[startsWith(csv_data['name']$name, prefix),]
  }
  to_numeric <- function(a) {
    as.numeric(a$value)
  }
  csv_to_ts(name, metrics_csv, extract, to_numeric)
}

system.cpu.count <- cpu_to_ts('system.cpu.count')
system.load.average.1m <- cpu_to_ts('system.load.average.1m')
system.cpu.usage <- cpu_to_ts('system.cpu.usage')
process.cpu.usage <- cpu_to_ts('process.cpu.usage')

cpu_load_plot <- plot_ts(list(
  system.load.average.1m
))
cpu_load_plot

cpu_usage_plot <- plot_ts(list(
  system.cpu.usage,
  process.cpu.usage
))
cpu_usage_plot

# ----------------------------------------------------------------------------- finalize

all_plots <- list(
  list("jvm_memory", jvm.memory.plot),
  list("cpu_load", cpu_load_plot),
  list("cpu_usage", cpu_usage_plot)
)

save_plots(all_plots, output_folder, output_file_prefix)

# ggsave('./test.png', p)


# system cpu
# process cpu


# idx <- metricsCsv[,'timestamp']
#
# dat <- xts(metricsCsv, order.by = idx)
# str(dat['2022-04-24 18:01:52'])
# dat['2022-04-24 18:01:52']
#
# dat['2022-04-24 18:01:52']


# v <- lapply(dat['2022-04-24 18:01:52','value'], as.numeric)
# v


# total memory consumption calculated with somes of both heap & non-heap spaces of:
# jvm.memory.committed
# jvm.memory.max
# jvm.memory.used

# system.cpu.count = number of cpu cores used
# system.load.average.1m = 1 minute cpu load average, calculation of load = (loadAverage / cpuCount) * 100 (https://dzone.com/articles/what-is-load-average)
# system.cpu.usage = What % load the overall system is at, from 0.0-1.0 (https://stackoverflow.com/a/27282046)
# process.cpu.usage = What % CPU load this current JVM is taking, from 0.0-1.0 (https://stackoverflow.com/a/27282046)