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

# Define server logic required to draw a histogram
function(input, output, session) {
  
  daFil <- function(.data, filVar, filVal) {
    # This function filters ".data" on "filVar" column 
    # only when non-null "filVal" are provided
    if (!is.null(filVal)) {
      data1 <- .data %>% filter(.data[[filVar]] %in% filVal)
    } else { data1 <- .data }
    return(data1)
  }
  
  redata <- function(rasta) {
    .data <- read.csv(rasta, sep = ",")
    .data$S <- as.numeric(.data$S)
    .data$class <- as.factor(.data$class)
    .data$band <- as.factor(.data$band)
    .data$lane <- as.factor(.data$lane)
    .data$cycleAB <- paste(.data$cycle, .data$Ab1_name)
    return(.data)
  }
  
  # counter <- reactiveVal(0)
  
  # observeEvent(input$dfil, counter(counter() + 1))
  
  rdata <- reactive(
    {
      if (is.null(input$Analysis)) {
        df <- redata("data/Analysis_log.csv")
      } else {
        df <- redata(input$Analysis$datapath)
      }
      df$S <- as.numeric(df$S)
      if (!is.null(input$Append)) {
        tempdf <- redata(input$Append$datapath)
        df <- rbind(df, tempdf)
      }
      df
    }
  )

  observeEvent(rdata(), {
    choices1 <- colnames(rdata())
    choices2 <- unique(rdata()$Ab1_name)
    choices3 <- unique(rdata()$band)
    choices4 <- unique(rdata()$class)
    choices5 <- unique(rdata()$membrane_id)
    updateSelectInput(inputId = "xvar", choices = choices1)
    updateSelectInput(inputId = "yvar", choices = choices1)
    updateSelectInput(inputId = "ab1", choices = choices2)
    updateSelectInput(inputId = "band", choices = choices3)
    updateSelectInput(inputId = "class", choices = choices4)
    updateSelectInput(inputId = "membrane", choices = choices5)
  })

  # bdata <- reactive({
  #   rdata() %>%
  #     {if (!is.null(input$ab1)) filter(., Ab1_name %in% input$ab1) else .} %>%
  #     {if (!is.null(input$band)) filter(., band %in% input$band) else .}
  # })
  
  # adata <- reactive({
  #   if (counter() == 1) {
  #     return(anti_join(rdata(), bdata()))
  #     counter(0)
  #   } else {
  #     return(rdata)
  #   }
  # })
  
  bdata <- reactive({
    rdata() %>%
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
