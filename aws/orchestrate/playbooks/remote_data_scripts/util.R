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
  'ggplot2'
)

# ----------------------------------------------------------------------------- utilitiy functions and constants

# To get rid of e notation in numbers
options(scipen = 999)

DEBUG_ENABLED <- TRUE

info <- function(...) {
  texts <- c(...)
  cat("[INFO]", texts, "\n")
}

debug <- function(...) {
  if (DEBUG_ENABLED) {
    texts <- c(...)
    cat("[DEBUG]", texts, "\n")
  }
}

error <- function(...) {
  texts <- c(...)
  cat("[ERROR]", texts, "\n")
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

remove_outliers <- function(data) {
  df <- data
  Q1 <- quantile(df$metric_value, 0.25)
  Q3 <- quantile(df$metric_value, 0.75)
  IQR <- Q3 - Q1

  # Define lower and upper bounds
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR

  # Remove outliers
  df <- df[df$metric_value > lower_bound & df$metric_value < upper_bound, ]
}