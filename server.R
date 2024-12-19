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
      df
    }
  )

  observeEvent(rdata(), {
    choices1 <- colnames(rdata())
    updateSelectInput(inputId = "xvar", choices = choices1)
    updateSelectInput(inputId = "yvar", choices = choices1)
  })

  output$distPlot <- renderPlot({
    ggplot(rdata(), aes_string(input$xvar, input$yvar)) +
      geom_point()
  })
}
