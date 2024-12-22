#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(ggplot2)
library(tools)
library(shinyFeedback)

# Define server logic required to draw a histogram
function(input, output, session) {

  colist <- c("S", "class", "band", "lane", "cycle", "Ab1_name",
              "membrane_id")
  
  daFil <- function(.data, filVar, filVal) {
    # This function filters ".data" on "filVar" column 
    # only when non-null "filVal" are provided
    if (!is.null(filVal)) {
      data1 <- .data %>% filter(.data[[filVar]] %in% filVal)
    } else { data1 <- .data }
    return(data1)
  }
  
  redata <- function(rasta, ui_var) {
    # Make sure "rasta" is non-NULL before using this function
    if (file_ext(rasta) == "csv") {
      .data <- read.csv(rasta, sep = ",")
      if (all(colist %in% colnames(.data))) {
        .data$S <- as.numeric(.data$S)
        .data$class <- as.factor(.data$class)
        .data$band <- as.factor(.data$band)
        .data$lane <- as.factor(.data$lane)
        .data$cycleAB <- paste(.data$cycle, .data$Ab1_name)
        return(.data)
      } else {
        val_col <- all(colist %in% colnames(.data))
        shinyFeedback::feedbackDanger(ui_var, !val_col,
          "File did not load: This is a wrong CSV"
        )
        req(val_col, cancelOutput = TRUE)
        #return(NULL)
      }
    } else {
      val_df <- file_ext(rasta) == "csv"
      shinyFeedback::feedbackDanger(ui_var, !val_df,
        "File did not load: This is not a CSV"
      )
      req(val_df, cancelOutput = TRUE)
      #return(NULL)
    }
  }

  rdata <- reactive({
    if (!is.null(input$Analysis$datapath)) {
      df <- redata(input$Analysis$datapath, "Analysis")
    } else {
      df <- redata("data/Analysis_log.csv")
    }
    if (!is.null(input$Append$datapath)) {
      tempdf <- redata(input$Append$datapath, "Append")
      df <- rbind(df, tempdf)
    }
    df
  })

  observeEvent(rdata(), {
    data <- rdata()
    updateSelectInput(inputId = "xvar", choices = colnames(data))
    updateSelectInput(inputId = "yvar", choices = colnames(data))
    updateSelectInput(inputId = "ab1", choices = unique(data$Ab1_name))
    updateSelectInput(inputId = "band", choices = unique(data$band))
    updateSelectInput(inputId = "class", choices = unique(data$class))
    updateSelectInput(inputId = "membrane", choices = unique(data$membrane_id))
  })

  bdata <- reactive({
    data <- rdata()
    data %>%
      daFil("Ab1_name", input$ab1) %>%
      daFil("band", input$band) %>%
      daFil("class", input$class) %>%
      daFil("membrane_id", input$membrane)
  })

  output$distPlot <- renderPlot({
    p <- ggplot(bdata(), aes_string(input$xvar, input$yvar, 
                                    color = input$color))
    if (input$scale == "normal") {
      return(p + geom_point())
    } else if (input$scale == "log") {
      return(p + geom_point() +
               scale_y_continuous(transform = "log10"))
    } else if (input$scale == "ln") {
      return(p + geom_point() +
               scale_y_continuous(transform = "log"))
    } 
  }, res = 96)
  output$lines <- renderText({
    paste0("Showing ",nrow(bdata()), " rows out of ", nrow(rdata()))
  })
}
