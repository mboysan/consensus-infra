#!/usr/bin/env Rscript

#' For summarizing client metrics.
#' @description
#' Summarizes the metrics collected from clients (i.e. performance tests) and dumps them to csv files as summary 
#' and raw (with timestamps) formats.
#' @param metrics_file path to metrics file
#' @param output_folder base folder to write output results
#' @param test_name name of the test that was run (ideally should be same as the ansible playbook file that was executed.)
#' @examples
#' ./collect_client_metrics.R <metrics_file> <output_folder> <test_name>
#' ./collect_client_metrics.R metrics.txt ./ S1
#'

source("util.R")

args <- commandArgs(trailingOnly=TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 3,
    failure_msg = "required arguments are not provided.",
    # defaults = c("collected_metrics/client_metrics_sample.txt", "collected_metrics/EX1", "EX1")
    defaults = c("collected_metrics/S2/client.txt", "collected_metrics/S2", "S2")
)

metrics_file <- args[1]
output_folder <- args[2]
test_name <- args[3]

# ----------------------------------------------------------------------------- prepare metrics

info("analyzing client metrics of:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('metric', 'value', 'timestamp'))

# ----------------------------------------------------------------------------- helper functions

extract <- function(metricName) {
    data <- metrics_csv %>%
        filter(grepl(metricName, metric)) %>%
        group_by(timestamp)
    rowCount <- nrow(data)
    data <- as.data.frame(data)
    if (rowCount <= 0) {
        data[1,] <- c(metric = metricName, value = -1, timestamp = -1)
    }
    data$value <- as.numeric(data$value)
    data
}

summary <- function(csv) {
    metricName <- csv$metric[1]
    data <- csv %>%
        # mutate(value = value / 1024) %>%
        summarize(
            min = min(value),
            max = max(value),
            mean = mean(value),
            p1 = quantile(value, 0.01),
            p5 = quantile(value, 0.05),
            p50 = quantile(value, 0.5),
            p90 = quantile(value, 0.9),
            p95 = quantile(value, 0.95),
            p99 = quantile(value, 0.99),
            p99.9 = quantile(value, 0.999),
            p99.99 = quantile(value, 0.9999))
        # pivot_longer(cols=-value, names_to = "metric", values_to = "value")
    data <- as.data.frame(data)
    # add 'metric' column
    data.frame(metric = metricName, data)
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

latency_summary <- rbind(
    summary(read_latency),
    summary(read_failed_latency),
    summary(update_latency),
    summary(update_failed_latency),
    summary(insert_latency),
    summary(insert_failed_latency),
    summary(scan_latency),
    summary(scan_failed_latency),
    summary(read_modify_write_latency),
    summary(read_modify_write_failed_latency)
)
latency_summary <- data.frame(category = "latency", latency_summary)
# print(latency_summary)

# ----------------------------------------------------------------------------- collect summary data

all_summary <- rbind(latency_summary)
all_summary <- data.frame(nodeType = "client", testName = test_name, latency_summary)
print(all_summary)

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
all_raw <- data.frame(nodeType = "client", testName = test_name, category = "latency", all_raw)
print(all_raw)

# ----------------------------------------------------------------------------- write all to csv files
info("writing client summary data to csv file")
out_file <- paste(output_folder, "client.summary.out.csv", sep = "/")
write.csv(all_summary, out_file, row.names = FALSE)

info("writing client summary data to csv file")
out_file <- paste(output_folder, "client.raw.out.csv", sep = "/")
write.csv(all_raw, out_file, row.names = FALSE)

# TODO: check the timestamps. Failed ones have -1 as the value and all of them are strings
