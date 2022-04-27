#!/usr/bin/env Rscript --vanilla

source("util.R")

library('readr')
library('stringr')
library('ggplot2')
# library('dplyr')

supportedOperations <- c(
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

csvFiles <- createCsvFiles(supportedOperations)

isOperation <- function(line, operation) {
  startsWith(line, paste0(operation, ','))
}

# write latencies to separate csv files based on operation type
writeLatencies <- function(line) {
  for (op in names(csvFiles)) {
    if (isOperation(line, op)) {
      file <- csvFiles[[op]]
      write(line, file, append=TRUE)
    }
  }
}

# write summary-stats to a csv file
writeSummaryStats <- function(line) {
  # if line starts with a pattern like: [UPDATE], type, value
  statName <- tolower(str_extract(line, "(?<=^\\[).+(?=\\])"))
  if (!is.na(statName)) {
    statsFile <- csvFiles[['summary-stats']]
    write(line, statsFile, append = TRUE)
  }
}

process("perftest_sample.txt", c(
  writeLatencies,
  writeSummaryStats
))

# --------------------------------------------------------------------------------- plots

readLatencyCsv <- read.csv(csvFiles[['read']], header = FALSE, col.names = c('operation', 'latency', 'timestamp'))
readLatencyCsv['time'] <- lapply(readLatencyCsv['timestamp'], FUN = epochMillisToSeconds)
class(readLatencyCsv[,'time']) <- c('POSIXt','POSIXct')

p <- ggplot(readLatencyCsv, aes(time, latency)) + geom_line() + scale_x_datetime(date_labels = "%H:%M:%OS3")
p

