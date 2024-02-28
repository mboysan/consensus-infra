#!/usr/bin/env Rscript

dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE) # create personal library
.libPaths(Sys.getenv("R_LIBS_USER"))  # add to the path

# ----------------------------------------------------------------------------- libraries

#' Taken from: https://stackoverflow.com/a/44660688
using <- function(...) {
  libs <- unlist(list(...))
  req <- unlist(lapply(libs, require, character.only = TRUE))
  need <- libs[req == FALSE]
  if (length(need) > 0) {
    install.packages(need)
    lapply(need, require, character.only = TRUE)
  }
}

# list of packages/libraries required
using(
  'dplyr',
  'ggplot2',
  'svglite'
)

# ----------------------------------------------------------------------------- utilitiy functions and constants

# To get rid of e notation in numbers
options(scipen = 999)

DEBUG_ENABLED <- TRUE
START_TIME <- Sys.time()

elapsed <- function(start_time = START_TIME) {
  end_time <- Sys.time()
  elapsedTime <- end_time - start_time
  paste0("elapsed:[", elapsedTime, "]")
}

currTime <- function() {
  format(Sys.time(), "%H:%M:%OS3", digits = 3L)
}

info <- function(...) {
  texts <- c(...)
  cat(paste0(currTime(), " [INFO]"), texts, "\n")
}

debug <- function(...) {
  if (DEBUG_ENABLED) {
    texts <- c(...)
    cat(paste0(currTime(), " [DEBUG]"), texts, "\n")
  }
}

error <- function(...) {
  texts <- c(...)
  cat(paste0(currTime(), " [ERROR]"), texts, "\n")
}

valiadate_args <- function(args, validator, failure_msg, defaults = NULL, use_defaults_on_fail = TRUE) {
  info("args provided:", args)
  result <- do.call(validator, list(args))
  debug(paste0("validator result: ", result))
  if (result) {
    return(args)
  }
  if (!is.null(defaults) && use_defaults_on_fail) {
    info("using default args:", defaults)
    return(defaults)
  }
  stop(failure_msg)
}

savePlotData <- function (data, columnNamesToInclude, outputFile) {
  info("saving plot data to file:", outputFile)
  data <- data[, names(data) %in% columnNamesToInclude]
  write.csv(data, file = outputFile, row.names = FALSE)
}

exportPlot <- function(folder, fileName, source, extension="svg", ggPlot=last_plot()) {
  fileName <- paste(fileName, source, "out", extension, sep=".")
  fileName <- paste(folder, fileName, sep="/")

  info("exporting plot to file:", fileName)
  ggsave(fileName, plot=ggPlot)

  info("Removing cached plot and freeing memory")
  ggplot(); gc()
}

remove_outliers_from_metric_value <- function(data) {
  data[remove_outliers(data$metric_value),]
}

remove_outliers <- function(data) {
  Q1 <- quantile(data, 0.25)
  Q3 <- quantile(data, 0.75)
  IQR <- Q3 - Q1

  # Define lower and upper bounds
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR

  # Remove outliers
  data > lower_bound & data < upper_bound
}
