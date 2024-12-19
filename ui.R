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
  titlePanel("Improc Output Analysis"),

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
      selectInput("xvar", "X Axis Variable",
                choices = NULL, selected = NULL, multiple = FALSE
      ),
      selectInput("yvar", "Y Axis Variable",
                choices = NULL, selected = NULL, multiple = FALSE
      )
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
)
