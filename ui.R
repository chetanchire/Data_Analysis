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
  fluidRow(
    #titlePanel("Select Data"),
    column(6,
      fileInput("Analysis", label = "Select analysis_log file",
        multiple = FALSE, accept = NULL, width = NULL,
        placeholder = "Showing built-in data", capture = NULL
      )
    ),
    column(6,
      fileInput("Append", label = "Append analysis_log file",
        multiple = FALSE, accept = NULL, width = NULL,
        placeholder = "Showing built-in data", capture = NULL
      )
    )
  ),

  fluidRow(
    column(6,
      selectInput("xvar", "X Axis Variable",
        choices = NULL, selected = NULL, multiple = FALSE
      )
    ),
    column(6,
      selectInput("yvar", "Y Axis Variable",
        choices = NULL, selected = NULL, multiple = FALSE
      )
    )
  ),

  fluidRow(
    column(2,
      selectInput("ab1", "Select Antibody Cycle",
        choices = NULL, selected = NULL, multiple = TRUE
      )
    ),
    column(2,
      selectInput("band", "Select Band ID",
        choices = NULL, selected = NULL, multiple = TRUE
      )
    )
  ),

  fluidRow(
    plotOutput("distPlot")
  ),
  fluidRow(
    textOutput("lines")
  )
)