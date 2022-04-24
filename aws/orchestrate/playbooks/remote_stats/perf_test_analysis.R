#!/usr/bin/env Rscript

dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE) # create personal library
.libPaths(Sys.getenv("R_LIBS_USER"))  # add to the path

#install.packages('readr')
#install.packages('stringr')
# install.packages('collections')
library('readr')
library('stringr')
library('ggplot2')
library('dplyr')

process <- function(filepath, lambdas) {
  con <- file(filepath, "r")
  while ( TRUE ) {
    line <- readLines(con, n = 1)
    if ( length(line) == 0 ) {
      break
    }
    for (lambda in lambdas) {
      do.call(lambda, as.list(line))
    }
  }

  close(con)
}

createCsvFiles <- function(operations) {
  files <- c()
  for (op in operations) {
    file <- tempfile(pattern = op, fileext = '.csv')
    files <- c(files, file)
  }
  names(files) <- operations
  files
}

isOperation <- function(line, operation) {
  startsWith(line, paste0(operation, ','))
}

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

process("perf_test_wip_01.txt", c(
  writeLatencies,
  writeSummaryStats
))

# --------------------------------------------------------------------------------- plots

epochMillisToTime <- function(timestamp) {
  timestamp / 1000
}

readLatencyCsv <- read.csv(csvFiles[['read']], col.names = c('operation', 'latency', 'timestamp'))
readLatencyCsv['time'] <- lapply(readLatencyCsv['timestamp'], FUN = epochMillisToTime)
class(readLatencyCsv[,'time']) <- c('POSIXt','POSIXct')

p <- ggplot(readLatencyCsv, aes(time, latency)) + geom_line() + scale_x_datetime(date_labels = "%H:%M:%OS3")
p

