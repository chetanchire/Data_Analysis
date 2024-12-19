#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)

# Define UI for application that draws a histogram
fluidPage(
  # Application title
  titlePanel("Old Faithful Geyser Data"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput("Analysis", label = "Select analysis_log file",
                multiple = FALSE, accept = NULL, width = NULL,
                placeholder = "Showing built-in data", capture = NULL
      ),
      fileInput("Append", label = "Append analysis_log file",
                multiple = FALSE, accept = NULL, width = NULL,
                placeholder = "Showing built-in data", capture = NULL
      ),
      sliderInput("bins",
                  "Number of bins:",
                  min = 1, max = 200, value = 30)
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
)
