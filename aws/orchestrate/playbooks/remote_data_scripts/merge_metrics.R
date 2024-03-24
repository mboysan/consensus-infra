#!/usr/bin/env Rscript

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
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

test_folders <- list.dirs(io_folder, recursive = FALSE)

# ----------------------------------------------------------------------------- helper functions

mergeMetrics <- function(nodeType, metricsType, dataType) {
    merged_metrics_csv <- data.frame()
    for (folder in test_folders) {
        # e.g. store.memory.summary.out.csv
        metrics_file <- nodeType
        if (!is.na(metricsType)) {
            metrics_file <- paste(metrics_file, metricsType, sep = ".")
        }
        if (!is.na(dataType)) {
            metrics_file <- paste(metrics_file, dataType, sep = ".")
        }
        metrics_file <- paste(metrics_file, "out.csv", sep = ".")
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
if (merge_client_metrics) {
    client_summary_metrics <- mergeMetrics("client", NA, "summary")
    writeCsv("client.summary.merged.csv", client_summary_metrics)
    rm(client_summary_metrics); gc()
}

if (merge_store_metrics) {
    store_memory_summary_metrics <- mergeMetrics("store", "memory", "summary")
    writeCsv("store.memory.summary.merged.csv", store_memory_summary_metrics)
    rm(store_memory_summary_metrics); gc()

    store_cpu_summary_metrics <- mergeMetrics("store", "cpu", "summary")
    writeCsv("store.cpu.summary.merged.csv", store_cpu_summary_metrics)
    rm(store_cpu_summary_metrics); gc()

    store_message_summary_metrics <- mergeMetrics("store", "message", "summary")
    writeCsv("store.message.summary.merged.csv", store_message_summary_metrics)
    rm(store_message_summary_metrics); gc()
}

# raw metrics
if (merge_client_metrics) {
    client_raw_metrics <- mergeMetrics("client", NA, "raw")
    writeCsv("client.raw.merged.csv", client_raw_metrics)
    rm(client_raw_metrics); gc()
}

if (merge_store_metrics) {
    store_memory_raw_metrics <- mergeMetrics("store", "memory", "raw")
    writeCsv("store.memory.raw.merged.csv", store_memory_raw_metrics)
    rm(store_memory_raw_metrics); gc()

    store_cpu_raw_metrics <- mergeMetrics("store", "cpu", "raw")
    writeCsv("store.cpu.raw.merged.csv", store_cpu_raw_metrics)
    rm(store_cpu_raw_metrics); gc()

    store_message_raw_metrics <- mergeMetrics("store", "message", "raw")
    writeCsv("store.message.raw.merged.csv", store_message_raw_metrics)
    rm(store_message_raw_metrics); gc()
}
