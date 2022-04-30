dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE) # create personal library
.libPaths(Sys.getenv("R_LIBS_USER"))  # add to the path

install.packages('stringr')
install.packages('roxygen2')  # for documentation
install.packages('ggplot2')
install.packages('xts')

library('readr')
library('stringr')
library('ggplot2')
library('xts')

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
  out <- tryCatch(
  {
    idx <- csv_data[, 'timestamp']
    data.ts <- xts(csv_data, order.by = idx)
    data.ts <- period.apply(data.ts, endpoints(data.ts, on = "ms"), FUN = FUN)
    # name the computed column as 'value'
    names(data.ts) <- col_names
    data.ts
  },
    error = function (cond) {
      return(NA)
    }
  )
  out
}

csv_to_ts <- function(name, CSV_OBJ, EXTRACTOR, APPLY_FUNCTION) {
  out <- tryCatch(
  {
    extracted <- do.call(EXTRACTOR, list(CSV_OBJ, name))
    to_ts(extracted, FUN = APPLY_FUNCTION)
  },
    error = function (cond) {
      return(NA)
    }
  )
  out
}

#' Plot time series data
#' @description
#' Function that plots a list of compatible xts data.
#' @param xts_data_list a list of 2D xts data object
#' @examples
#' Replaces the following call:
#' p <- ggplot() +
#'   geom_line(data = jvm.memory.committed.sum.ts, aes(x=Index, value)) +
#'   geom_line(data = jvm.memory.used.sum.ts, aes(x=Index, value)) +
#'   scale_x_datetime(date_labels = "%H:%M:%OS3")
plot_ts <- function(xts_data_list) {
  out <- tryCatch(
  {
    p <- ggplot()
    for (xts_data in xts_data_list) {
      p <- p + geom_line(data = xts_data, aes(x = Index, value))
    }
    p <- p + scale_x_datetime(date_labels = "%H:%M:%OS3")
    p
  },
    error = function (cond) {
      return(NA)
    }
  )
  out
}

#' Saves plots as image files
#' @param plot_list list of ggplot objects
#' TODO: specifiy out path and image extension.
save_plots <- function (plot_list) {
  for (item in plot_list) {
    name <- item[[1]]
    plot <- item[[2]]
    ggsave(paste0(name, ".png"), plot)
  }
}