#!/usr/bin/env Rscript

source("util.R")
source("util_store.R")

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

MAIN_METRICS_FILE_NAME <- "store.metrics.txt"
METRICS_FILE_NAME <- "store.message.metrics.txt"

io_folder <- args[1]
test_group <- args[2]
test_name <- args[3]
consensus_alg <- args[4]

main_metrics_file <- paste(io_folder, test_group, test_name, MAIN_METRICS_FILE_NAME, sep = "/")
metrics_file <- paste(io_folder, test_group, test_name, METRICS_FILE_NAME, sep = "/")
output_folder <- paste(io_folder, test_group, test_name, sep = "/")

consensus_requests <- c(
    # raft
    'AppendEntriesRequest',
    'RequestVoteRequest',

    # bizur
    'PleaseVoteRequest',
    'ReplicaReadRequest',
    'ReplicaWriteRequest',
    'CollectKeysRequest',
    'HeartbeatRequest'
)
# searchStrings <- c("insights.tcp")
searchStrings <- consensus_requests
extractDataFromMetricsFile(main_metrics_file, metrics_file, searchStrings)

# ----------------------------------------------------------------------------- prepare metrics
info("analyzing store message metrics of:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('metric', 'value', 'timestamp'))

# TODO: summary of message metrics

# ----------------------------------------------------------------------------- collect raw timestamp data
messages_raw <- rbind(
    extractInsights("insights.tcp.server.send"),
    extractInsights("insights.tcp.server.receive"),
    extractInsights("insights.tcp.client.send"),
    extractInsights("insights.tcp.client.receive")
)
messages_raw <- data.frame(category = "messages", messages_raw)
messages_raw <- collectStoreRawData(messages_raw)

info("writing store message raw data to csv file")
out_file <- paste(output_folder, "store.message.raw.out.csv", sep = "/")
write.csv(messages_raw, out_file, row.names = FALSE)
