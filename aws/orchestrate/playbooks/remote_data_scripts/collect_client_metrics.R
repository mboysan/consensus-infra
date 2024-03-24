#!/usr/bin/env Rscript

#' For summarizing client metrics.
#' @description
#' Summarizes the metrics collected from clients (i.e. performance tests) and dumps them to csv files as summary 
#' and raw formats.
#' @param io_folder path to base metrics path (e.g. ../collected_data/metrics/samples)
#' @param test_group the test group that was run (e.g. S)
#' @param test_name name of the test that was run
#' @param consensus_protocol the consensus protocol used in the test
#' @examples
#' ./collect_client_metrics.R <io_folder> <test_group> <test_name> <consensus_protocol>
#' ./collect_client_metrics.R ../collected_data/metrics/samples ./ EX EX1 "raft"
#'

source("util.R")

args <- commandArgs(trailingOnly = TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 4,
    failure_msg = "required arguments are not provided.",
    # raft
    defaults = c("../collected_data/metrics/samples", "EX", "EX1", "raft")
    # bizur
    # defaults = c("../collected_data/metrics/samples", "EX", "EX2", "bizur")
)

METRICS_FILE_NAME <- "client.metrics.txt"

io_folder <- args[1]
test_group <- args[2]
test_name <- args[3]
consensus_alg <- args[4]

metrics_file <- paste(io_folder, test_group, test_name, METRICS_FILE_NAME, sep = "/")
output_folder <- paste(io_folder, test_group, test_name, sep = "/")

# ----------------------------------------------------------------------------- prepare metrics

info("collecting client metrics of:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('metric', 'value', 'timestamp'))

# ----------------------------------------------------------------------------- helper functions

extract <- function(metricName) {
    data <- metrics_csv %>%
        filter(metricName == metric) %>%
        group_by(timestamp)
    rowCount <- nrow(data)
    data <- as.data.frame(data)
    if (rowCount <= 0) {
        data[1,] <- c(metric = metricName, value = -1, timestamp = -1)
    }
    data$value <- as.numeric(data$value)
    data
}

# return a compatible data.frame from the provided metric and value
metric_as_df <- function(metric, value) {
    data.frame(metric = c(metric), value = c(value), timestamp = c(-1))
}

# count the rows in the given csv and return a compatible data.frame
count_as_df <- function(metric, csv) {
    csv <- csv %>% filter(value > -1, na.rm = TRUE)
    metric_as_df(metric, nrow(csv))
}

calc_runtime <- function(csv) {
    runtime <- max(as.numeric(csv$timestamp)) - min(as.numeric(csv$timestamp))
    runtime <- (runtime / 1000) # to seconds
    runtime
}

calc_throughput <- function(csv) {
    csv <- csv %>% filter(value > -1, na.rm = TRUE)
    runtime <- calc_runtime(csv)
    opCount <- nrow(csv)
    throughput <- (opCount / runtime)
    debug("runtime (sec)=[", runtime, "],", "total op count=[", opCount, "],", "throughput (ops/sec)=[", throughput, "]")
    throughput
}

# ----------------------------------------------------------------------------- latency data

read_latency <- extract("read")
read_failed_latency <- extract('read-failed')
update_latency <- extract('update')
update_failed_latency <- extract('update-failed')
insert_latency <- extract('insert')
insert_failed_latency <- extract('insert-failed')
scan_latency <- extract('scan')
scan_failed_latency <- extract('scan-failed')
read_modify_write_latency <- extract('read-modify-write')
read_modify_write_failed_latency <- extract('read-modify-write-failed')

# ----------------------------------------------------------------------------- collect raw timestamp data

all_raw <- rbind(
    read_latency,
    read_failed_latency,
    update_latency,
    update_failed_latency,
    insert_latency,
    insert_failed_latency,
    scan_latency,
    scan_failed_latency,
    read_modify_write_latency,
    read_modify_write_failed_latency
)
all_raw <- all_raw %>% filter(value > -1, na.rm = TRUE)   # sanitize
all_raw <- data.frame(nodeType = "client", testGroup = test_group, testName = test_name, consensusAlg = consensus_alg, category = "latency", all_raw)

# finalize column order
all_raw <- all_raw[, c('nodeType', 'testGroup', 'testName', 'consensusAlg', 'category', 'metric', 'value', 'timestamp')]

read_count <- count_as_df('read_count', read_latency)
update_count <- count_as_df('update_count', update_latency)
insert_count <- count_as_df('insert_count', insert_latency)
scan_count <- count_as_df('scan_count', scan_latency)
readWrite_count <- count_as_df('rmw_count', read_modify_write_latency)
total_ops_count <- count_as_df('total_ops_count', all_raw)

runtime <- calc_runtime(all_raw)
runtime <- metric_as_df("runtime_sec", runtime)

throughput <- calc_throughput(all_raw)
throughput <- metric_as_df("throughput", throughput)

# ----------------------------------------------------------------------------- collect summary data

latency_summary <- rbind(
    doSummary(read_latency),
    doSummary(read_failed_latency),
    doSummary(update_latency),
    doSummary(update_failed_latency),
    doSummary(insert_latency),
    doSummary(insert_failed_latency),
    doSummary(scan_latency),
    doSummary(scan_failed_latency),
    doSummary(read_modify_write_latency),
    doSummary(read_modify_write_failed_latency)
)
latency_summary <- data.frame(category = "latency", latency_summary)

overall_summary <- rbind(
    doSummary(read_count),
    doSummary(update_count),
    doSummary(insert_count),
    doSummary(scan_count),
    doSummary(readWrite_count),
    doSummary(total_ops_count),
    doSummary(runtime),
    doSummary(throughput)
)
overall_summary <- overall_summary %>% filter(mean > 0, na.rm = TRUE)   # sanitize
overall_summary <- data.frame(category = 'overall', overall_summary)

all_summary <- rbind(
    latency_summary,
    overall_summary
)
all_summary <- all_summary %>% filter(mean > -1, na.rm = TRUE)   # sanitize
all_summary <- data.frame(nodeType = "client", testGroup = test_group, testName = test_name, consensusAlg = consensus_alg, all_summary)

# ----------------------------------------------------------------------------- write all to csv files
info("writing client raw data to csv file")
out_file <- paste(output_folder, "client.raw.out.csv", sep = "/")
write.csv(all_raw, out_file, row.names = FALSE)

info("writing client summary data to csv file")
out_file <- paste(output_folder, "client.summary.out.csv", sep = "/")
write.csv(all_summary, out_file, row.names = FALSE)

# fixme: fix read-failed & update-failed csvs. See W5 client.summary.merged.csv
