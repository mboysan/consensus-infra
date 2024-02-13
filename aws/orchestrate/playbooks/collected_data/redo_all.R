#!/usr/bin/env Rscript

source("../remote_data_scripts/util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 2,
    failure_msg = "required arguments are not provided.",
    defaults = c("metrics/EX1 EX2", "metrics/EX1 EX2")
)

input_folder <- args[1]
output_folder <- args[2]

source("redo_message_analysis.R")
source("redo_performance_analysis.R")
source("redo_resource_usage_analysis.R")
