#!/usr/bin/env Rscript

#' Replay the collected metrics on the controller.
#' @description
#' Replay the collected metrics on the controller.

source("util.R")

COLLECT_METRICS <- FALSE
ANALYZE_CLIENT_METRICS <- TRUE
ANALYZE_STORE_CPU_METRICS <- FALSE
ANALYZE_STORE_MEMORY_METRICS <- FALSE
ANALYZE_STORE_MESSAGE_METRICS <- FALSE
PLOT_SOURCE <- "controller"

arg_io_folder <- "../collected_data/metrics"
arg_test_group <- "W2"
arg_tests <- data.frame(
    c("EX1", "consensus", "raft"),
    c("EX2", "consensus", "bizur")
)
arg_tests <- t(arg_tests)    # flip the matrix

if (COLLECT_METRICS) {
    scriptArgs <- data.frame()
    for(i in 1:nrow(arg_tests)) {
        test <- arg_tests[i,]
        scriptArgs <- rbind(scriptArgs, c(arg_io_folder, arg_test_group, test[1], test[2], test[3]))
    }
    colnames(scriptArgs) <- c("io_folder", "test_group", "test_name", "cluster_type", "consensus_alg")

    # backup commandArgs
    commandArgs_bak <- commandArgs
    for (i in 1:nrow(scriptArgs)) {
        commandArgs <- function (...) {
            row <- scriptArgs[i,]
            # unname(unlist(row[1,]))
            unname(unlist(row))
        }
        source("collect_client_metrics.R")
        source("collect_store_metrics.R")
    }

    commandArgs <- function (...) {
        c(paste0(arg_io_folder, "/", arg_test_group), "merge_client_metrics=true", "merge_store_metrics=true")
    }
    source("merge_metrics.R")

    # restore commandArgs
    commandArgs <- commandArgs_bak
}

# backup commandArgs
commandArgs_bak <- commandArgs
baseFolder <- paste0(arg_io_folder, "/", arg_test_group)

if (ANALYZE_CLIENT_METRICS) {
    commandArgs <- function (...) {
        c(baseFolder, "client.raw.merged.csv", "remove_outliers_per_test=true", "timescale_in_milliseconds=false")
    }
    source("analyze_client_metrics.R")
}

if (ANALYZE_STORE_CPU_METRICS) {
    commandArgs <- function (...) {
        c(baseFolder, "store.cpu.raw.merged.csv")
    }
    source("analyze_store_cpu_metrics.R")
}

if (ANALYZE_STORE_MEMORY_METRICS) {
    commandArgs <- function (...) {
        c(baseFolder, "store.memory.raw.merged.csv")
    }
    source("analyze_store_memory_metrics.R")
}

if (ANALYZE_STORE_MESSAGE_METRICS) {
    commandArgs <- function (...) {
        c(baseFolder, "store.message.raw.merged.csv")
    }
    source("analyze_store_message_metrics.R")
}

# restore commandArgs
commandArgs <- commandArgs_bak