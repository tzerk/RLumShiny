printCode <- function(input, output, session, n_input, fun, args,
                      join_inputs_in_list = TRUE) {

  # prepare code as text output
  str1 <- paste("file <- file.choose()",
                "data <- data.table::fread(file, data.table = FALSE)",
                sep = "\n")
  if (n_input == 2) {
    str1 <- paste(str1,
                  "file2 <- file.choose()",
                  "data2 <- data.table::fread(file2, data.table = FALSE)",
                  sep = "\n")
    if (join_inputs_in_list)
      str1 <- paste(str1,
                    "data <- list(data, data2)", sep = "\n")
  }

  header <- paste("# To reproduce the plot in your local R environment",
                  "# copy and run the following code to your R console.",
                  "",
                  "library(Luminescence)",
                  if (n_input > 0) paste(str1, "\n"),
                  sep = "\n")

  names <- names(args)

  if (is.null(names))
    names <- rep(NA, length(args))

  names[which(names == "")] <- NA

  verb.arg <- paste(mapply(function(name, arg) {
    if (all(inherits(arg, "character")))
      arg <- paste0("'", arg, "'")
    if (inherits(arg, "list"))
      arg <- deparse(arg)
    if (length(arg) > 1)
      arg <- paste0("c(", paste(arg, collapse = ", "), ")")
    if (is.null(arg))
      arg <- "NULL"
    if (!is.na(name))
      paste(name, "=", arg)
    else
      arg
  }, names[-1], args[-1]), collapse = ",\n")

  funCall <- paste0(fun, "\n", verb.arg, ")")
  code.output <- paste0(header, "\n", funCall, sep = "\n")

  return(code.output)
}
