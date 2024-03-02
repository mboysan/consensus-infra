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
METRICS_FILE_NAME <- "store.cpu.metrics.txt"

io_folder <- args[1]
test_group <- args[2]
test_name <- args[3]
consensus_alg <- args[4]

main_metrics_file <- paste(io_folder, test_group, test_name, MAIN_METRICS_FILE_NAME, sep = "/")
metrics_file <- paste(io_folder, test_group, test_name, METRICS_FILE_NAME, sep = "/")
output_folder <- paste(io_folder, test_group, test_name, sep = "/")

extractDataFromMetricsFile(main_metrics_file, metrics_file, c("system.cpu.usage", "process.cpu.usage"))

# ----------------------------------------------------------------------------- prepare metrics
info("analyzing store cpu metrics of:", metrics_file)

metrics_csv <- read.csv(metrics_file, header = FALSE, col.names = c('metric', 'value', 'timestamp'))

# ----------------------------------------------------------------------------- cpu data

system_cpu_usage <- extractCpu("system.cpu.usage")
process_cpu_usage <- extractCpu("process.cpu.usage")

# ----------------------------------------------------------------------------- collect summary data
cpu_summary <- rbind(
    summary(system_cpu_usage),
    summary(process_cpu_usage)
)
cpu_summary <- data.frame(category = "cpu", cpu_summary)
cpu_summary <- collectStoreSummaryData(cpu_summary)

info("writing store cpu summary data to csv file")
out_file <- paste(output_folder, "store.cpu.summary.out.csv", sep = "/")
write.csv(cpu_summary, out_file, row.names = FALSE)
rm(cpu_summary); gc()

# ----------------------------------------------------------------------------- collect raw timestamp data
cpu_raw <- rbind(
    system_cpu_usage,
    process_cpu_usage
)
rm(system_cpu_usage, process_cpu_usage); gc()
cpu_raw <- data.frame(category = "cpu", cpu_raw)
cpu_raw <- collectStoreRawData(cpu_raw)

info("writing store cpu raw data to csv file")
out_file <- paste(output_folder, "store.cpu.raw.out.csv", sep = "/")
write.csv(cpu_raw, out_file, row.names = FALSE)
