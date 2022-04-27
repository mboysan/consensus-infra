#!/usr/bin/env Rscript --vanilla

source("util.R")

library('xts')
library('ggplot2')

metrics_csv <- read.csv('node_metrics_sample.txt', header = FALSE, col.names = c('name', 'value', 'timestamp'))
class(metrics_csv[, 'timestamp']) <- c('POSIXt', 'POSIXct')

extract <- function(csv_data, prefix) {
  csv_data[startsWith(csv_data['name']$name, prefix),]
}

#' Converts a csv data to xts data applying the function specified.
#' @description
#' By default, the converted data has a single named column called 'value' upon return.
#' @param csv_data csv data to convert
#' @param apply_function function to apply
to_ts <- function(csv_data, apply_function, col_names = c('value')) {
  idx <- csv_data[, 'timestamp']
  data.ts <- xts(csv_data, order.by = idx)
  data.ts <- period.apply(data.ts, endpoints(data.ts, on = "ms"), FUN = apply_function)
  # name the computed column as 'value'
  names(data.ts) <- col_names
  data.ts
}

#' Plot time series data
#' @description
#' Function that plots a list of compatible xts data.
#' @param xts_data_list a list of 2D xts data object
#' @examples
#' Replaces the following call:
#' p <- ggplot() +
#'   geom_line(data = jvm.memory.committed.sum.ts, aes(x=Index, value)) +
#'   geom_line(data = jvm.memory.used.sum.ts, aes(x=Index, value)) +
#'   scale_x_datetime(date_labels = "%H:%M:%OS3")
plot_ts <- function(xts_data_list) {
  p <- ggplot()
  for (xts_data in xts_data_list) {
    p <- p + geom_line(data = xts_data, aes(x = Index, value))
  }
  p <- p + scale_x_datetime(date_labels = "%H:%M:%OS3")
  p
}

# ----------------------------------------------------------------------------- process jvm memory data
#' Converts bytes to megabytes (in decimal).
#' @param bytes bytes
bytes_to_megabytes <- function(bytes) {
  bytes / (1000 * 1000)
}

memory_sum <- function(a) {
  sum(bytes_to_megabytes(as.numeric(a$value)))
}

jvm.memory.max <- extract(metrics_csv, 'jvm.memory.max')
jvm.memory.committed <- extract(metrics_csv, 'jvm.memory.committed')
jvm.memory.used <- extract(metrics_csv, 'jvm.memory.used')

jvm.memory.plot <- plot_ts(list(
  to_ts(jvm.memory.max, memory_sum),
  to_ts(jvm.memory.committed, memory_sum),
  to_ts(jvm.memory.used, memory_sum)
))
jvm.memory.plot

# ----------------------------------------------------------------------------- process cpu data

to_numeric <- function(a) {
  as.numeric(a$value)
}

system.cpu.count <- extract(metrics_csv, 'system.cpu.count')
system.load.average.1m <- extract(metrics_csv, 'system.load.average.1m')
system.cpu.usage <- extract(metrics_csv, 'system.cpu.usage')
process.cpu.usage <- extract(metrics_csv, 'process.cpu.usage')

cpu_load_plot <- plot_ts(list(
  to_ts(system.load.average.1m, to_numeric)
))
cpu_load_plot

cpu_usage_plot <- plot_ts(list(
  to_ts(system.cpu.usage, to_numeric),
  to_ts(process.cpu.usage, to_numeric)
))
cpu_usage_plot

# ----------------------------------------------------------------------------- all plots

save_plots <- function (plot_list) {
  for (item in plot_list) {
    name <- item[[1]]
    plot <- item[[2]]
    ggsave(paste0(name, ".png"), plot)
  }
}

all_plots <- list(
  list("jvm_memory", jvm.memory.plot),
  list("cpu_load", cpu_load_plot),
  list("cpu_usage", cpu_usage_plot)
)

save_plots(all_plots)

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