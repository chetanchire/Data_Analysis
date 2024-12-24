library(tools)
library(shinyFeedback)

daFil <- function(.data, filVar, filVal) {
  # This function filters ".data" on "filVar" column 
  # only when non-null "filVal" are provided
  if (!is.null(filVal)) {
    data1 <- .data %>% filter(.data[[filVar]] %in% filVal)
  } else { data1 <- .data }
  return(data1)
}

redata <- function(rasta, ui_var, colist) {
  # Make sure "rasta" is non-NULL before using this function
  # "colist" is a list of column names that should be in the uploaded files
  val_df <- file_ext(rasta) == "csv"
  shinyFeedback::feedbackDanger(ui_var, !val_df,
                                "File did not load: This is not a CSV"
  )
  req(val_df, cancelOutput = TRUE)
  
  .data <- read.csv(rasta, sep = ",")
  
  val_col <- all(colist %in% colnames(.data))
  shinyFeedback::feedbackDanger(ui_var, !val_col,
                                "File did not load: This is a wrong CSV"
  )
  req(val_col, cancelOutput = TRUE)
  
  .data$S <- as.numeric(.data$S)
  .data$class <- as.factor(.data$class)
  .data$band <- as.factor(.data$band)
  .data$lane <- as.factor(.data$lane)
  .data$cycleAB <- paste(.data$cycle, .data$Ab1_name)
  return(.data)
}

update_inputs <- function(.data) {
  # odata <- rdata()
  updateSelectInput(inputId = "xvar", choices = colnames(.data))
  updateSelectInput(inputId = "yvar", choices = colnames(.data))
  updateSelectInput(inputId = "ab1", choices = unique(.data$Ab1_name))
  updateSelectInput(inputId = "band", choices = unique(.data$band))
  updateSelectInput(inputId = "class", choices = unique(.data$class))
  updateSelectInput(inputId = "membrane", choices = unique(.data$membrane_id))
}

append_data <- function(data1, data2) {
  return(rbind(data1, data2))
}

reset_data <- function(data, colist) {
  data[['read_data']] <- redata("data/analysis_log.csv", " ", colist)
  data[['prev_data']] <- NULL
  return(data)
}