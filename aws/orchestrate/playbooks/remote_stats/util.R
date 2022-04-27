dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE) # create personal library
.libPaths(Sys.getenv("R_LIBS_USER"))  # add to the path

# install.packages('readr')
# install.packages('stringr')
# install.packages('collections')
install.packages('roxygen2')  # for documentation
install.packages('ggplot2')
install.packages('xts')

process <- function(filepath, lambdas) {
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

createCsvFiles <- function(operations) {
  files <- c()
  for (op in operations) {
    file <- tempfile(pattern = op, fileext = '.csv')
    files <- c(files, file)
  }
  names(files) <- operations
  files
}

#' Convert milliseconds (since epoch) to seconds.
#' @param timestamp milliseconds since epoch
epochMillisToSeconds <- function(timestamp) {
  timestamp / 1000
}
