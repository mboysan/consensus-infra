#!/usr/bin/env Rscript

#' For summarizing store metrics.
#' @description
#' Summarizes the metrics collected from stores and dumps them to csv files as summary and raw (with timestamps) 
#' formats.
#' @param metrics_file path to metrics file
#' @param output_folder base folder to write output results
#' @param test_name name of the test that was run (ideally should be same as the ansible playbook file that was executed.)
#' @examples
#' ./collect_store_metrics.R <metrics_file> <output_folder> <test_name> <consensus_protocol>
#' ./collect_store_metrics.R metrics.txt ./ S1 raft
#'

source("util.R")

args <- commandArgs(trailingOnly=TRUE)
args <- valiadate_args(
    args = args,
    validator = \(x) length(x) == 4,
    failure_msg = "required arguments are not provided.",
    # raft
    defaults = c("collected_metrics/EX1/node2.metrics.txt", "collected_metrics/EX1", "EX1", "raft")
    # bizur
    # defaults = c("collected_metrics/EX2/node2.metrics.txt", "collected_metrics/EX2", "EX2", "bizur")
)

metrics_file <- args[1]
output_folder <- args[2]
test_name <- args[3]
consensus_alg <- args[4]

# ----------------------------------------------------------------------------- prepare metrics
info("analyzing store metrics of:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('metric', 'value', 'timestamp'))

# ----------------------------------------------------------------------------- helper functions

extractJvm <- function(metricName) {
    data <- metrics_csv %>%
        filter(grepl(metricName, metric)) %>%
        group_by(timestamp) %>%
        summarize(value = sum(value))
    data <- as.data.frame(data)
    # add 'metric' column
    data.frame(metric = metricName, data)
}

extractInsights <- function(metricName) {
    data <- metrics_csv %>%
        filter(grepl(metricName, metric)) %>%
        group_by(timestamp)
    data <- as.data.frame(data)
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

# ----------------------------------------------------------------------------- memory data

jvm_memory_used <- extractJvm("jvm.memory.used")
keys_total <- extractInsights("insights.store.sizeOf.keys")
values_total <- extractInsights("insights.store.sizeOf.values")
store_total <- extractInsights("insights.store.sizeOf.total")

jvm_memory_used_summary <- summary(jvm_memory_used)
keys_total_summary <- summary(keys_total)
values_total_summary <- summary(values_total)
store_total_summary <- summary(store_total)

memory_summary <- rbind(
        jvm_memory_used_summary,
        keys_total_summary,
        values_total_summary,
        store_total_summary
)

memory_summary <- data.frame(category = "memory", memory_summary)

# ----------------------------------------------------------------------------- cpu data

system_cpu_usage <- extractInsights("system.cpu.usage")
process_cpu_usage <- extractInsights("process.cpu.usage")

system_cpu_usage_summary <- summary(system_cpu_usage)
process_cpu_usage_summary <- summary(process_cpu_usage)

cpu_summary <- rbind(
        system_cpu_usage_summary,
        process_cpu_usage_summary
)

cpu_summary <- data.frame(category = "cpu", cpu_summary)

# ----------------------------------------------------------------------------- request/response (message) data
messages_server_send <- extractInsights("insights.tcp.server.send")
messages_server_receive <- extractInsights("insights.tcp.server.receive")
messages_client_send <- extractInsights("insights.tcp.client.send")
messages_client_receive <- extractInsights("insights.tcp.client.receive")

# ----------------------------------------------------------------------------- collect summary data

all_summary <- rbind(
        memory_summary,
        cpu_summary
)
all_summary <- data.frame(nodeType = "store", testName = test_name, consensusAlg = consensus_alg, all_summary)

# ----------------------------------------------------------------------------- collect raw timestamp data

memory_raw <- rbind(
    jvm_memory_used,
    keys_total,
    values_total,
    store_total
)
memory_raw <- data.frame(category = "memory", memory_raw)

cpu_raw <- rbind(
    system_cpu_usage,
    process_cpu_usage
)
cpu_raw <- data.frame(category = "cpu", cpu_raw)

messages_raw <- rbind(
    messages_server_send,
    messages_server_receive,
    messages_client_send,
    messages_client_receive
)
messages_raw <- data.frame(category = "messages", messages_raw)

all_raw <- rbind(
    memory_raw,
    cpu_raw,
    messages_raw
)
all_raw <- data.frame(nodeType = "store", testName = test_name, consensusAlg = consensus_alg, all_raw)

# finalize column order
all_raw <- all_raw[,c('nodeType', 'testName', 'consensusAlg', 'category', 'metric', 'value', 'timestamp')]

# ----------------------------------------------------------------------------- write all to csv files
info("writing store summary data to csv file")
out_file <- paste(output_folder, "store.summary.out.csv", sep = "/")
write.csv(all_summary, out_file, row.names = FALSE)

info("writing store raw data to csv file")
out_file <- paste(output_folder, "store.raw.out.csv", sep = "/")
write.csv(all_raw, out_file, row.names = FALSE)

# debug
# print(all_raw)
print(all_summary)

# TODO: check the timestamps. some of them have milliseconds scale (insights), some of them don't (jvm)
