# Script that's used for debug purposes

# install debugger on vscode
# R --no-restore --quiet -f install.R --args "https://github.com/ManuelHentschel/VSCode-R-Debugger/releases/download/v0.5.2/vscDebugger_0.5.2.tar.gz"


to_ts <- function(csv_data, col_names = c('value')) {
    class(csv_data[, 'timestamp']) <- c('POSIXt', 'POSIXct')
    idx <- csv_data[, 'timestamp']
    data.ts <- xts(csv_data, order.by = idx)
    data.ts <- period.apply(data.ts, endpoints(data.ts, on = "ms"), FUN=identity)
    # names(data.ts) <- col_names
    data.ts
}
