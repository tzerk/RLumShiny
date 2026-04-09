#' Print the code used to load the data and generate the plots
#'
#' @param input,output,session
#' Reactive objects used by shiny.
#'
#' @param ...
#' Each function is represented as a named lists with elements `name` (the
#' function name), `arg1` (the name of the first argument), `args` (a list of
#' names and values for additional arguments), and optionally `rets` (the name
#' of the object returned) and `info` (a comment to be prepended).
#'
#' @param n_inputs
#' Number of input dataset used by the app.
#'
#' @param join_inputs_into_list
#' Whether the inputs should be joined into a single list. This is ignored
#' unless `n_inputs > 1`.
#'
#' @param extension
#' The input file extension ("csv" by default).
#'
#' @noRd
printCode <- function(input, output, session, ...,
                      n_inputs, join_inputs_into_list = TRUE,
                      extension = "csv") {
  preamble <- .format_preamble(n_inputs, join_inputs_into_list, extension)
  fun.call <- sapply(list(...), .format_function_call)
  paste0(preamble, paste(fun.call, collapse = "\n"), sep = "\n")
}

## Format the preamble section
.format_preamble <- function(n_inputs, join_into_list, extension) {
  template <- function(idx, n_inputs, extension) {
    ## don't use file1 and data1 if there is only one input
    if (idx == 1 && n_inputs == 1) idx <- ""
    readCall <- switch(extension,
                       "xsyg" = "read_XSYG2R(file%s, fastForward = TRUE, verbose = FALSE)",
                       "bin" = "read_BIN2R(file%s, fastForward = TRUE, verbose = FALSE)",
                       "binx" = "read_BIN2R(file%s, fastForward = TRUE, verbose = FALSE)",
                       "data.table::fread(file%s, data.table = FALSE)")
    sprintf(paste("file%s <- file.choose()",
                  paste("data%s <-", readCall),
                  sep = "\n"),
            idx, idx, idx)
  }

  ## header lines
  head <- paste("# To reproduce the plot in your local R environment",
                "# copy and run the following code to your R console.",
                "",
                "library(Luminescence)",
                "",
                sep = "\n")

  ## code to read the inputs
  read <- NULL
  for (idx in seq_len(n_inputs)) {
    read <- paste(read, template(idx, n_inputs, extension), sep = "\n")
  }

  ## optionally join multiple inputs into a single list
  if (n_inputs > 1 && join_into_list) {
    inputs <- paste0("data", 1:n_inputs, collapse = ", ")
    read <- paste(read,
                  sprintf("data <- list(%s)", inputs),
                  sep = "\n")
  }

  ## return the complete preamble
  paste0(head, read, ifelse(n_inputs > 0, "\n", ""), sep = "\n")
}

## Format a complete function call
.format_function_call <- function(fun) {
  rets <- if (!is.null(fun$rets)) paste(fun$rets, "<-", fun$name) else fun$name
  len.indent <- nchar(rets) + 1 # for the opening bracket
  indent.sep <- sprintf(",\n%s", strrep(" ", len.indent))

  ## collect the argument names
  names <- names(fun$args)
  if (is.null(names))
    names <- rep(NA, length(fun$args))
  names[which(names == "")] <- NA

  ## format a list of arguments into an indented comma-separated string
  args <- paste(mapply(function(name, arg) {
    if (inherits(arg, "character"))
      arg <- paste0("'", arg, "'")
    if (inherits(arg, "list"))
      arg <- deparse(arg)
    if (length(arg) > 1) {
      ## use the range notation when possible
      if (is.numeric(arg) && identical(arg, seq(min(arg), max(arg))))
        arg <- paste(range(arg), collapse = ":")
      else
        arg <- paste0("c(", paste(arg, collapse = ", "), ")")
    }
    if (is.null(arg))
      arg <- "NULL"
    if (!is.na(name))
      paste(name, "=", arg)
    else
      arg
  }, names[-1], fun$args[-1]), collapse = indent.sep)

  if (!is.null(fun$info))
    rets <- paste0("# ", fun$info, "\n", rets)
  if (!is.null(fun$arg1))
    args <- paste(fun$arg1, args, sep = indent.sep)
  sprintf("%s(%s)\n", rets, args)
}
