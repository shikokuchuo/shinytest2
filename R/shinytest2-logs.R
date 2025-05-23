#' @export
print.shinytest2_log <- function(x, ...) {
  cat(format(x), ...)
  invisible(x)
}

#' @export
#' @importFrom cli col_blue col_magenta col_cyan col_green col_red col_silver make_ansi_style
format.shinytest2_log <- function(x, ...) {

  get_color <- function(location, level) {
    switch(as.character(location),
      shiny = switch(level, stderr = col_magenta, force),
      chromote = switch(level, throw = col_red, error = col_red, col_cyan),
      shinytest2 = switch(level, col_green)
    )
  }

  location_name <- c(
    chromote = "{chromote}",
    shinytest2 = "{shinytest2}",
    shiny = "{shiny}"
  )
  language <- c(
    chromote = "JS",
    shinytest2 = "R",
    shiny = "R"
  )

  x_name <- location_name[x$location]
  x_language <- language[x$location]
  x_identifier <- paste0(format(x_name), " ", format(x_language), " ", format(x$level))
  x_timestamp <- ifelse(is.na(x$timestamp), "-----------", format(x$timestamp, "%H:%M:%OS2"))

  x_msg <-
    Map(
      x$message,
      # get color functions
      Map(x$location, x$level, f = get_color),
      f = function(msg, color) {
        if (grepl("\n", msg, fixed = TRUE)) {
          # Multiline messages should have color start/end on each line
          # Split by `\n`, color, then join with `\n`
          paste0(
            vapply(
              strsplit(msg, "\n", fixed = TRUE)[[1]],
              color,
              character(1)
            ),
            collapse = "\n"
          )
        } else {
          color(msg)
        }
      }
    )

  first_part <- paste0(
    x_identifier, " ", x_timestamp, " "
  )

  first_part_char_len <- nchar(first_part[1])
  first_spaces <- paste0("\n", paste0(rep(" ", first_part_char_len), collapse = ""))
  # Replace all new lines with heavily indented new lines to align msg output
  x_msg_w_spaces <- gsub("\n", first_spaces, x_msg, fixed = TRUE)

  paste0(
    first_part, x_msg_w_spaces,
    collapse = "\n"
  )
}
