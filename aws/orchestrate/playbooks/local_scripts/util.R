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
using('readr',
      'stringr',
      'ggplot2',
      'xts',
      'roxygen2' # for documentation
)

# ----------------------------------------------------------------------------- utilitiy functions and constants

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

process_csv_file <- function(filepath, lambdas) {
  con <- file(filepath, "r")
  while ( TRUE ) {
    line <- readLines(con, n = 1)
    if ( length(line) == 0 ) {
      break
    }
    for (lambda in lambdas) {
      do.call(lambda, as.list(line))
    }
  }

  close(con)
}

create_csv_files <- function(operations) {
  files <- c()
  for (op in operations) {
    file <- tempfile(pattern = op, fileext = '.csv')
    files <- c(files, file)
  }
  names(files) <- operations
  files
}

#' Converts a csv data to xts data applying the function specified.
#' @description
#' By default, the converted data has a single named column called 'value' upon return.
#' Pre-requisites:
#'  The csv_data supplied must have the following columns: name, value, timestamp
#' @param csv_data csv data to convert
#' @param apply_function function to apply (default -> to_numeric)
to_ts <- function(csv_data, FUN, col_names = c('value')) {
  idx <- csv_data[, 'timestamp']
  data.ts <- xts(csv_data, order.by = idx)
  data.ts <- period.apply(data.ts, endpoints(data.ts, on = "ms"), FUN = FUN)
  names(data.ts) <- col_names
  data.ts
}

csv_to_ts <- function(name, CSV_OBJ, EXTRACTOR, APPLY_FUNCTION) {
  extracted <- do.call(EXTRACTOR, list(CSV_OBJ, name))
  to_ts(extracted, FUN = APPLY_FUNCTION)
}

#' Plot time series data
#' @description
#' Function that plots a list of compatible xts data.
#' @param ... (xts_data_list) a list of 2D xts data object
#' @examples
#' Replaces the following call:
#' p <- ggplot() +
#'   geom_line(data = jvm.memory.committed.sum.ts, aes(x=Index, value)) +
#'   geom_line(data = jvm.memory.used.sum.ts, aes(x=Index, value)) +
#'   scale_x_datetime(date_labels = "%H:%M:%OS3")
plot_ts <- function(...) {
  l <- list(...)
  p <- ggplot()
  for (xts_data in l) {
    p <- p + geom_line(data = xts_data, aes(x = Index, value))
  }
  p <- p + scale_x_datetime(date_labels = "%H:%M:%OS3")
  p
}

#' Saves plots as image files
#' @param plot_list list of ggplot objects
save_plots <- function (plot_list, out_folder = NULL, out_file_prefix = NULL, image_extension = "png") {
  if (is.na(out_folder)) {
    out_folder <- NULL
  }
  if (is.na(out_file_prefix)) {
    out_file_prefix <- NULL
  }
  info("saving plots in", out_folder)
  for (item in plot_list) {
    name <- item[[1]]
    plot <- item[[2]]
    file_name <- paste0(out_file_prefix, name, ".", image_extension)
    info("saving plot to:", file_name)
    ggsave(file_name, plot, path = out_folder)
  }
}