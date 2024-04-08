#!/usr/bin/env Rscript

#' For summarizing store metrics.
#' @description
#' Summarizes the metrics collected from stores and dumps them to csv files as summary and raw formats.
#' @param io_folder path to base metrics path (e.g. ../collected_data/metrics/samples)
#' @param test_group the test group that was run (e.g. S)
#' @param test_name name of the test that was run
#' @param consensus_protocol the consensus protocol used in the test
#' @examples
#' ./collect_store_metrics.R <io_folder> <test_group> <test_name> <consensus_protocol>
#' ./collect_store_metrics.R ../collected_data/metrics/samples ./ EX EX1 "raft"
#'

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 5,
    failure_msg = "required arguments are not provided.",
    # raft
    # defaults = c("../collected_data/metrics/samples", "EX", "EX1", "consensus", "raft")
    # bizur
    defaults = c("../collected_data/metrics/samples", "EX", "EX2", "consensus", "bizur")
)

# backup commandArgs
commandArgs_bak <- commandArgs

io_folder <- args[1]
test_group <- args[2]
test_name <- args[3]
cluster_type <- args[4]
consensus_alg <- args[5]
commandArgs <- function (...) {
    c(io_folder, test_group, test_name, cluster_type, consensus_alg)
}

source("collect_store_memory_metrics.R")
source("collect_store_cpu_metrics.R")
source("collect_store_message_metrics.R")

# restore commandArgs
commandArgs <- commandArgs_bak