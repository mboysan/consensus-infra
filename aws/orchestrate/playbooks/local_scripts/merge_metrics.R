#!/usr/bin/env Rscript


source("util.R")

args <- commandArgs(trailingOnly=TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 2,
    failure_msg = "required arguments are not provided.",
    defaults = c("collected_metrics", "collected_metrics/MERGED", "S1", "S2")
)

input_folder <- args[1]
output_folder <- args[2]
test_names <- args[-c(1, 2)]

# ----------------------------------------------------------------------------- helper functions

mergeMetrics <- function(nodeType, metricsType) {
    merged_metrics_csv <- data.frame()
    for (test_name in test_names) {
        # e.g. store.summary.out.csv
        metrics_file <- paste(nodeType, metricsType, "out.csv", sep = ".")
        metrics_file <- paste(input_folder, test_name, metrics_file, sep = "/")
        
        info("merging metrics from", metrics_file)
        metrics_csv <- read.csv(metrics_file, header = TRUE)
        merged_metrics_csv <- rbind(merged_metrics_csv, metrics_csv)
    }
    merged_metrics_csv
}

writeCsv <- function(fileName, data) {
    info("writing data to csv file", fileName)
    out_file <- paste(output_folder, fileName, sep = "/")
    write.csv(data, out_file, row.names = FALSE)
}

# ----------------------------------------------------------------- merge metrics from provided tests and write to csv

# summary metrics
client_summary_metrics <- mergeMetrics("client", "summary")
writeCsv("client.summary.merged.csv", client_summary_metrics)

store_summary_metrics <- mergeMetrics("store", "summary")
writeCsv("store.summary.merged.csv", store_summary_metrics)

all_summary_metrics <- rbind(client_summary_metrics, store_summary_metrics)
writeCsv("all.summary.merged.csv", all_summary_metrics)

# raw metrics
client_raw_metrics <- mergeMetrics("client", "raw")
writeCsv("client.raw.merged.csv", client_raw_metrics)

store_raw_metrics <- mergeMetrics("store", "raw")
writeCsv("store.raw.merged.csv", store_raw_metrics)

all_raw_metrics <- rbind(client_raw_metrics, store_raw_metrics)
writeCsv("all.raw.merged.csv", all_raw_metrics)

all_raw_metrics <- NULL
all_summary_metrics <- NULL
gc()

# ----------------------------------------------------------------- 

