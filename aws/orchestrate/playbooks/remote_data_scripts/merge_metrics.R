#!/usr/bin/env Rscript

source("util.R")

args <- commandArgs(trailingOnly=TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 3,
    failure_msg = "required arguments are not provided.",
    defaults = c(
        "../collected_data/metrics/samples/EX",
        "merge_client_metrics=true",
        "merge_store_metrics=true")
)

io_folder <- args[1]
merge_client_metrics <- grepl("true", args[2], ignore.case = TRUE)
merge_store_metrics <- grepl("true", args[3], ignore.case = TRUE)

test_folders <- list.dirs(io_folder, recursive=FALSE)

# ----------------------------------------------------------------------------- helper functions

mergeMetrics <- function(nodeType, metricsType) {
    merged_metrics_csv <- data.frame()
    for (folder in test_folders) {
        # e.g. store.summary.out.csv
        metrics_file <- paste(nodeType, metricsType, "out.csv", sep = ".")
        metrics_file <- paste(folder, metrics_file, sep = "/")
        
        info("merging metrics from", metrics_file)
        metrics_csv <- read.csv(metrics_file, header = TRUE)
        merged_metrics_csv <- rbind(merged_metrics_csv, metrics_csv)
    }
    merged_metrics_csv
}

writeCsv <- function(fileName, data) {
    info("writing data to csv file", fileName)
    out_file <- paste(io_folder, fileName, sep = "/")
    write.csv(data, out_file, row.names = FALSE)
}

# ----------------------------------------------------------------- merge metrics from provided tests and write to csv

# summary metrics
client_summary_metrics <- NULL
store_summary_metrics <- NULL

if (merge_client_metrics) {
    client_summary_metrics <- mergeMetrics("client", "summary")
    writeCsv("client.summary.merged.csv", client_summary_metrics)
}

if (merge_store_metrics) {
    store_summary_metrics <- mergeMetrics("store", "summary")
    writeCsv("store.summary.merged.csv", store_summary_metrics)
}

if (merge_client_metrics || merge_store_metrics) {
    all_summary_metrics <- rbind(client_summary_metrics, store_summary_metrics)
    writeCsv("all.summary.merged.csv", all_summary_metrics)
}

# raw metrics
client_raw_metrics <- NULL
store_raw_metrics <- NULL

if (merge_client_metrics) {
    client_raw_metrics <- mergeMetrics("client", "raw")
    writeCsv("client.raw.merged.csv", client_raw_metrics)
}

if (merge_store_metrics) {
    store_raw_metrics <- mergeMetrics("store", "raw")
    writeCsv("store.raw.merged.csv", store_raw_metrics)
}

if (merge_client_metrics || merge_store_metrics) {
    all_raw_metrics <- rbind(client_raw_metrics, store_raw_metrics)
    writeCsv("all.raw.merged.csv", all_raw_metrics)
}

all_raw_metrics <- NULL
all_summary_metrics <- NULL
gc()

# ----------------------------------------------------------------- 

