#!/usr/bin/env Rscript

#' Analysis of consensus messaging.
#' @description
#' Analysis of consensus messaging.
#' @param metrics_file path to metrics file
#' @param output_folder base folder to write output results
#' @param output_file_prefix file prefix for an individual result
#' @examples
#' ./<script>.R <metrics_file> <output_folder> <output_file_prefix>

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
  args = args,
  validator = \(x) length(x) == 3,
  failure_msg = "path to metrics file and/or output folder and/or output file prefix missing.",
  defaults = c("collected_metrics/EX1/node2.metrics.txt", NULL, NULL)
)

metrics_file <- args[1]
output_folder <- args[2]
output_file_prefix <- args[3]

millis_to_seconds <- function(timestamp) {
  as.numeric(timestamp) / 1000
}

# ----------------------------------------------------------------------------- prepare metrics
info("analysing consensus messaging:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('name', 'value', 'timestamp'))
metrics_csv['timestamp'] <- lapply(metrics_csv['timestamp'], FUN = millis_to_seconds)
# class(metrics_csv[, 'timestamp']) <- c('POSIXt', 'POSIXct')

# ----------------------------------------------------------------------------- process requests

bizur_consensus_request_types <- c(
  'PleaseVoteRequest',
  'ReplicaReadRequest',
  'ReplicaWriteRequest',
  'CollectKeysRequest',
  'HeartbeatRequest'
)

raft_consensus_request_types <- c(
  'AppendEntriesRequest',
  'RequestVoteRequest'
)

kvstore_request_types <- c(
  'KVDeleteRequest',
  'KVGetRequest',
  'KVIterateKeysRequest',
  'KVSetRequest'
)

bizur_client_request_types <- kvstore_request_types
raft_client_request_types <- c('StateMachineRequest')

find_data <- function(basePattern, searchArray) {
  data <- metrics_csv
  basePatternRows <- grepl(basePattern, data$name)
  data <- data[basePatternRows, ]
  name_rows <- grepl(paste(searchArray, collapse = "|"), data$name)
  data <- data[name_rows, ]
  data
}

outgoing_requests <- function(searchArray) {
  find_data("send", searchArray)
}

incoming_requests <- function(searchArray) {
  find_data("receive", searchArray)
}


bizur_out <- outgoing_requests(bizur_consensus_request_types)
bizur_in <- incoming_requests(bizur_consensus_request_types)
bizur_consensus_requests <- rbind(bizur_in, bizur_out)
bizur_consensus_requests
# bizur_agg_data <- aggregate(value ~ timestamp, bizur_consensus_requests, sum)
# plot(bizur_agg_data$timestamp, bizur_agg_data$value, type = "l", xlab = "Timestamp", ylab = "Aggregated Value")


raft_out <- outgoing_requests(raft_consensus_request_types)
raft_in <- incoming_requests(raft_consensus_request_types)
raft_consensus_requests <- rbind(raft_in, raft_out)
raft_consensus_requests
raft_agg_data <- aggregate(value ~ timestamp, raft_consensus_requests, sum)
plot(raft_agg_data$timestamp, raft_agg_data$value, type = "l", xlab = "Timestamp", ylab = "Aggregated Value")

# total number of consensus messages sent/received throughout the experiment
# number of client messages sent/received per second (plot)
# number of consensus messages sent/received per second (plot)
# number of all messages sent/received per second (plot)
# size of consensus messages sent/received per second (plot)

# To AI:
