#!/usr/bin/env Rscript --vanilla

source("util.R")

library('readr')
library('stringr')
library('ggplot2')
# library('dplyr')

supported_operations <- c(
  'read',
  'read-failed',
  'update',
  'update-failed',
  'insert',
  'insert-failed',
  'scan',
  'scan-failed',
  'read-modify-write',
  'read-modify-write-failed',
  'summary-stats'
)

csv_files <- create_csv_files(supported_operations)

is_operation <- function(line, operation) {
  startsWith(line, paste0(operation, ','))
}

# write latencies to separate csv files based on operation type
write_latencies <- function(line) {
  for (op in names(csv_files)) {
    if (is_operation(line, op)) {
      file <- csv_files[[op]]
      write(line, file, append=TRUE)
    }
  }
}

# write summary-stats to a csv file
write_summary_stats <- function(line) {
  # if line starts with a pattern like: [UPDATE], type, value
  statName <- tolower(str_extract(line, "(?<=^\\[).+(?=\\])"))
  if (!is.na(statName)) {
    statsFile <- csv_files[['summary-stats']]
    write(line, statsFile, append = TRUE)
  }
}

process_csv_file("perftest_sample.txt", c(
  write_latencies,
  write_summary_stats
))

# --------------------------------------------------------------------------------- plots

readLatencyCsv <- read.csv(csv_files[['read']], header = FALSE, col.names = c('operation', 'latency', 'timestamp'))
readLatencyCsv['time'] <- lapply(readLatencyCsv['timestamp'], FUN = epoch_millis_to_seconds)
class(readLatencyCsv[,'time']) <- c('POSIXt','POSIXct')

p <- ggplot(readLatencyCsv, aes(time, latency)) + geom_line() + scale_x_datetime(date_labels = "%H:%M:%OS3")
p


# metrics_csv <- read.csv("perftest_sample.txt", header = FALSE, col.names = c('name', 'value', 'timestamp'))
# class(metrics_csv[, 'timestamp']) <- c('POSIXt', 'POSIXct')
#
# extract <- function(csv_data, prefix) {
#   is_operation <- csv_data['name']$name == prefix
#   csv_data[is_operation, ]
# }
#
# read.latency <- extract(metrics_csv, 'read')
# read.latency <- extract(metrics_csv, 'read-failed')
# read.latency