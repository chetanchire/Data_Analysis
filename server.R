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

# Define server logic required to draw a histogram
function(input, output, session) {
  rdata <- reactive(
    {
      if (is.null(input$Analysis)) {
        df <- read.csv2("data/Analysis_log.csv", sep = ",")
      } else {
        df <- read.csv2(input$Analysis$datapath, sep = ",")
      }
      df$S <- as.numeric(df$S)
      if (!is.null(input$Append)) {
        tempdf <- read.csv2(input$Append$datapath, sep = ",")
        tempdf$S <- as.numeric(tempdf$S)
        df <- rbind(df, tempdf)
      }
      df$cycleAB <- paste(df$cycle, df$Ab1_name)
      df
    }
  )

  observeEvent(rdata(), {
    choices1 <- colnames(rdata())
    choices2 <- unique(rdata()$Ab1_name)
    choices3 <- unique(rdata()$band)
    updateSelectInput(inputId = "xvar", choices = choices1)
    updateSelectInput(inputId = "yvar", choices = choices1)
    updateSelectInput(inputId = "ab1", choices = choices2)
    updateSelectInput(inputId = "band", choices = choices3)
  })

  # adata <- reactive({
  #   if (!is.null(input$ab1) & !is.null(input$band)) {
  #     rdata() %>% filter(Ab1_name %in% input$ab1) %>%
  #       filter(band %in% input$band)
  #   } else if (is.null(input$ab1) & !is.null(input$band)) {
  #     rdata() %>% filter(band %in% input$band)
  #   } else if (!is.null(input$ab1) & is.null(input$band)) {
  #     rdata() %>% filter(Ab1_name %in% input$ab1)
  #   } else {
  #     rdata()
  #   }
  # })

  bdata <- reactive({
    rdata() %>%
      {if (!is.null(input$ab1)) filter(., Ab1_name %in% input$ab1) else .} %>%
      {if (!is.null(input$band)) filter(., band %in% input$band) else .}
  })

  output$distPlot <- renderPlot({
    ggplot(bdata(), aes_string(input$xvar, input$yvar)) +
      geom_point()
  })
  output$lines <- renderText({
    paste0("Showing ",nrow(bdata()), " rows out of ", nrow(rdata()))
  })
}
