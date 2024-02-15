#!/usr/bin/env Rscript

source("../remote_data_scripts/util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 1,
    failure_msg = "required arguments are not provided.",
    defaults = c("metrics/samples/EX1 EX2")
)

# backup commandArgs
commandArgs_bak <- commandArgs

io_folder <- args[1]
commandArgs <- function (...) io_folder

source("redo_message_analysis.R")
source("redo_performance_analysis.R")
source("redo_resource_usage_analysis.R")

# restore commandArgs
commandArgs <- commandArgs_bak
