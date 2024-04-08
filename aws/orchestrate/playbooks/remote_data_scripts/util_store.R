#!/usr/bin/env Rscript

# ----------------------------------------------------------------------------- helper functions

extractJvmMemory <- function(metricName) {
    info("extracting jvm info for:", metricName)
    data <- metrics_csv %>%
        filter(grepl(metricName, metric)) %>%
        group_by(timestamp) %>%
        summarize(value = sum(value))
    data <- as.data.frame(data)
    # add 'metric' column
    data.frame(metric = metricName, data)
}

extractCpu <- function (metricName) {
    extractInsights(metricName, convertToMilliseconds = FALSE)
}

extractInsights <- function(metricName, convertToMilliseconds = TRUE) {
    info("extracting insights for:", metricName)
    data <- metrics_csv %>%
        filter(grepl(metricName, metric)) %>%
        group_by(timestamp)
    if (convertToMilliseconds) {
        data$timestamp <- round(data$timestamp / 1000)
    }
    data <- as.data.frame(data)
}

collectStoreSummaryData <- function(summaryData) {
    data.frame(
        nodeType = "store",
        testGroup = test_group,
        testName = test_name,
        clusterType = cluster_type,
        consensusAlg = consensus_alg,
        summaryData)
}

collectStoreRawData <- function(rawData) {
    rawData <- data.frame(
        nodeType = "store",
        testGroup = test_group,
        testName = test_name,
        clusterType = cluster_type,
        consensusAlg = consensus_alg,
        rawData)
    # finalize column order
    rawData <- rawData[, c('nodeType', 'testGroup', 'testName', 'clusterType', 'consensusAlg', 'category', 'metric', 'value', 'timestamp')]
    rawData
}

adjust_start_times <- function(data) {
    info("adjusting start times")
    minStart <- min(data$timestamp)
    testNames <- unique(data$testName)

    for (testName in testNames) {
        tmp <- data[data$testName == testName,]
        minTestStart <- tmp[1,]$timestamp
        diff <- minTestStart - minStart
        data[data$testName == testName,]$timestamp <- data[data$testName == testName,]$timestamp - diff
    }
    data
}

prepareStoreResourceUsageMetrics <- function(data) {
    info("preparing store resource usage metrics")

    # Rename the columns
    names(data) <- c("nodeType", "testGroup", "testName", "clusterType", "consensusAlg", "category", "metric_name", "metric_value", "timestamp")
    data$test_id <- paste0(data$testGroup, data$testName)    # EXEX1
    data$test_id <- paste(data$test_id, data$clusterType, data$consensusAlg, sep = "_")   # EXEX1_consensus_raft

    # filter for store metrics and test names
    data <- data %>% filter(nodeType == "store")

    data$timestamp <- as.numeric(data$timestamp)

    data <- adjust_start_times(data)

    # Convert the timestamp from "seconds" to POSIXct date-time
    data$timestamp_sec <- as.POSIXct(data$timestamp, origin = "1970-01-01")
    # Round the timestamp to the nearest second
    data$timestamp_sec <- round(data$timestamp_sec)
    data$timestamp_sec <- as.POSIXct(data$timestamp_sec, origin = "1970-01-01")

    data$metric_value <- as.numeric(data$metric_value)

    # Group the data
    data <- data %>% group_by(test_id, metric_name, timestamp_sec)
    data
}

extractDataFromMetricsFile <- function(inputFile, outputFile, searchStrings){
    grepString <- ""
    for (seacrhString in searchStrings) {
        grepString <- paste0(grepString, " -e '", seacrhString, "'")
    }
    cmd <- paste0("bash -c 'cat ", inputFile, " | grep ", grepString, " > ", outputFile, "'")
    info("executing command:", cmd)
    system(command = cmd)
}