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
        df <- read.csv2(input$Analysis$datapath, sep=",")
      }
      df$S <- as.numeric(df$S)
      df
    }
  )

  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    x <- rdata()$S
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = "darkgray", border = "white",
         xlab = "Waiting time to next eruption (in mins)",
         main = "Histogram of waiting times")
  })
}
