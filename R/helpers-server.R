tryNotify <- function(expr, id = "notification") {
  notify <- function(ew, id, type) {
    showNotification(conditionMessage(ew),
                     id = id, type = type, duration = NULL)
  }
  tryCatch(
      withCallingHandlers(
          expr,
          message = function(m) {
            notify(m, id = id, type = ifelse(grepl("Error", m$message),
                                             "error", "default"))
          },
          warning = function(w) {
            notify(w, id = id, type = "warning")
          }),
      error = function(e) {
        notify(e, id = id, type = "error")
      })
}

rhandsontable_workaround <- function(table, values) {
  # Workaround for rhandsontable issue #138
  # https://github.com/jrowen/rhandsontable/issues/138
  # Desc.: the rownames are not updated when copying values in the table
  # that exceed the current number of rows; hence, we have to manually
  # update the rownames before running hot_to_r(), which would crash otherwise

  # to modify the rhandsontable we need to create a local non-reactive variable
  df_tmp <- table
  row_names <- as.list(as.character(seq_len(length(df_tmp$data))))
  df_tmp$params$rRowHeaders <- row_names
  df_tmp$params$rowHeaders <- row_names
  df_tmp$params$rDataDim <- as.list(c(length(row_names),
                                      length(df_tmp$params$columns)))

  # With the above workaround we run into the problem that the 'afterRemoveRow'
  # event checked in rhandsontable:::toR also tries to remove the surplus rowname(s)
  # For now, we can overwrite the event and handle the 'afterRemoveRow' as a usual
  # 'afterChange' event
  if (df_tmp$changes$event == "afterRemoveRow")
    df_tmp$changes$event <- "afterChange"

  if (is.null(hot_to_r(df_tmp)))
    return(NULL)
  hot_to_r(df_tmp)
}
