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
METRICS_FILE_NAME <- "store.memory.metrics.txt"

io_folder <- args[1]
test_group <- args[2]
test_name <- args[3]
consensus_alg <- args[4]

main_metrics_file <- paste(io_folder, test_group, test_name, MAIN_METRICS_FILE_NAME, sep = "/")
metrics_file <- paste(io_folder, test_group, test_name, METRICS_FILE_NAME, sep = "/")
output_folder <- paste(io_folder, test_group, test_name, sep = "/")

extractDataFromMetricsFile(main_metrics_file, metrics_file, c("jvm.memory.used", "insights.store.sizeOf"))

# ----------------------------------------------------------------------------- prepare metrics
info("analyzing store memory metrics of:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('metric', 'value', 'timestamp'))

# ----------------------------------------------------------------------------- memory data

jvm_memory_used <- extractJvmMemory("jvm.memory.used")
keys_total <- extractInsights("insights.store.sizeOf.keys")
values_total <- extractInsights("insights.store.sizeOf.values")
store_total <- extractInsights("insights.store.sizeOf.total")

# ----------------------------------------------------------------------------- collect summary data
memory_summary <- rbind(
    doSummary(jvm_memory_used),
    doSummary(keys_total),
    doSummary(values_total),
    doSummary(store_total)
)
memory_summary <- data.frame(category = "memory", memory_summary)
memory_summary <- collectStoreSummaryData(memory_summary)

info("writing store memory summary data to csv file")
out_file <- paste(output_folder, "store.memory.summary.out.csv", sep = "/")
write.csv(memory_summary, out_file, row.names = FALSE)
rm(memory_summary); gc()

# ----------------------------------------------------------------------------- collect raw timestamp data
memory_raw <- rbind(
    jvm_memory_used,
    keys_total,
    values_total,
    store_total
)
rm(jvm_memory_used, keys_total, values_total, store_total); gc()
memory_raw <- data.frame(category = "memory", memory_raw)
memory_raw <- collectStoreRawData(memory_raw)

info("writing store memory raw data to csv file")
out_file <- paste(output_folder, "store.memory.raw.out.csv", sep = "/")
write.csv(memory_raw, out_file, row.names = FALSE)
