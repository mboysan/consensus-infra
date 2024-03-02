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

# ----------------------------------------------------------------------------- helper functions

# return a compatible data.frame from the provided metric and value
metric_as_df <- function(metric, value) {
    data.frame(metric = c(metric), value = c(value), timestamp = c(-1))
}

# count the rows in the given csv and return a compatible data.frame
count_as_df <- function(metric, csv) {
    csv <- csv %>% filter(value > -1, na.rm = TRUE)
    metric_as_df(metric, nrow(csv))
}

# sum the rows in the given csv and return a compatible data.frame
sum_as_df <- function(metric, csv) {
    csv <- csv %>% filter(value > -1, na.rm = TRUE)
    metric_as_df(metric, sum(csv$value))
}

# ----------------------------------------------------------------------------- prepare metrics
info("analyzing store message metrics of:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('metric', 'value', 'timestamp'))

messages_raw <- data.frame()
message_summary <- data.frame()
for (request in consensus_requests) {
    request_data <- extractInsights(request)
    if (nrow(request_data) > 0) {
        request_summary_data <- summary(request_data)
        message_summary <- rbind(message_summary, request_summary_data)
        messages_raw <- rbind(messages_raw, request_data)
    }
}

rm(metrics_csv); gc()

# ----------------------------------------------------------------------------- collect summary data
total_request_count <- summary(count_as_df("total_consensus_request_count", messages_raw))
total_request_size <- summary(sum_as_df("total_consensus_request_size", messages_raw))
message_summary <- rbind(message_summary, total_request_count, total_request_size)

message_summary <- data.frame(category = "message", message_summary)
message_summary <- collectStoreSummaryData(message_summary)

info("writing store message summary data to csv file")
out_file <- paste(output_folder, "store.message.summary.out.csv", sep = "/")
write.csv(message_summary, out_file, row.names = FALSE)
rm(message_summary); gc()

# ----------------------------------------------------------------------------- collect raw timestamp data
messages_raw <- data.frame(category = "message", messages_raw)
messages_raw <- collectStoreRawData(messages_raw)

info("writing store message raw data to csv file")
out_file <- paste(output_folder, "store.message.raw.out.csv", sep = "/")
write.csv(messages_raw, out_file, row.names = FALSE)
