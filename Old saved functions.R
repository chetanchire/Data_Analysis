

# redata <- function(rasta) {
#   # Make sure "rasta" is non-NULL before using this function
#   if (file_ext(rasta) == "csv") {
#     .data <- read.csv(rasta, sep = ",")
#     if (all(colist %in% colnames(.data))) {
#       .data$S <- as.numeric(.data$S)
#       .data$class <- as.factor(.data$class)
#       .data$band <- as.factor(.data$band)
#       .data$lane <- as.factor(.data$lane)
#       .data$cycleAB <- paste(.data$cycle, .data$Ab1_name)
#       return(.data)
#     } else {
#       return(NULL)
#     }
#   } else {
#     return(NULL)
#   }
# }

valid_datafile <- function(rasta) {
  if (!is.null(rasta) && file_ext(rasta) == "csv") {
    return(rasta)
  } else {
    return(NULL)
  }
}



read_data <- reactive({
  req(input$Analysis)
  if (file_ext(input$Analysis$datapath) == "csv") {
    df <- redata(input$Analysis$datapath)
    if (is.null(df)) {
      df <- redata("data/analysis_log.csv")
      cat("Can not analyze the uploaded CSV")
    }
  }
})

rdata <- reactive(
  {
    if (is.null(input$Analysis) ||
        is.null(valid_datafile(input$Analysis$datapath))
    ) {
      df <- redata("data/analysis_log.csv")
    } else if (!is.null(valid_datafile(input$Analysis$datapath))) {
      df <- redata(input$Analysis$datapath)
    }
    if (!is.null(input$Append) &&
        !is.null(valid_datafile(input$Append$datapath))
    ) {
      tempdf <- redata(input$Append$datapath)
      df <- rbind(df, tempdf)
      tempdf <- NULL
    }
    df
  }
)


# rdata <- reactive({
#   df<- read.csv("data/Analysis_log.csv", sep = ",")
#   df
#   
#   req(input$Analysis)
#   val_df <- file_ext(input$Analysis$datapath) == "csv"
#   shinyFeedback::feedbackDanger("Analysis", !val_df, "This is not a CSV")
#   req(val_df, cancelOutput = TRUE)
#   
#   tempdf<- read.csv(input$Analysis$datapath, sep = ",")
#
#   val_col <- all(colist %in% colnames(tempdf))
#   shinyFeedback::feedbackDanger("Analysis", !val_col, "This is a wrong CSV")
#   req(val_col, cancelOutput = TRUE)
#   df <- tempdf
#   
#   df
#   
#   # if (!is.null(input$Analysis$datapath)) {
#   #   tempdf <- redata(input$Analysis$datapath)
#   #   if (!is.null(tempdf)) {
#   #     df <- tempdf
#   #   } else {
#   #     showModal(modalDialog(title = "Important message",
#   #       easy_close = TRUE,
#   #       "something went wrong while reading the file"
#   #     ))
#   #     #df <- redata("data/Analysis_log.csv")
#   #   }
#   # } else {
#   #   #df <- NULL
#   #   #df <- redata("data/Analysis_log.csv")
#   # }
#   # #df
# })

# bdata <- reactive({
#   rdata() %>%
#     {if (!is.null(input$ab1)) filter(., Ab1_name %in% input$ab1) else .} %>%
#     {if (!is.null(input$band)) filter(., band %in% input$band) else .}
# })

# bdata <- reactive({
#   rdata() %>%
#     {if (!is.null(input$ab1)) filter(., Ab1_name %in% input$ab1) else .} %>%
#     {if (!is.null(input$band)) filter(., band %in% input$band) else .}
# })

analysis_data <- reactive({
  req(input$Analysis)
  tempdf <- redata(input$Analysis$datapath, "Analysis")
  if (!is.null(tempdf)) {
    df <- tempdf
  } else { }
})

append_data <- reactive({
  req(input$Append)
  counter(1)
  return(redata(input$Append$datapath, "Append"))
})

combine_data <- reactive({
  if (counter() != 0) {
    if (is.null(append_data())) {
      counter(0)
    } else {
      if (is.null(analysis_data())) {
        counter(0)
      } else {
        counter(0)
        return(rbind(analysis_data(), append_data()))
      }
    }
  }
})

rdata <- reactive({
  if (is.null(analysis_data())) {
    return(redata("data/analysis_log.csv", " "))
  } else {
    analysis_data()
  }
})
