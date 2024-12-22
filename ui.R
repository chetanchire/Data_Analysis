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
library(shinyFeedback)

# Define UI for application that draws a histogram
fluidPage(
  # Application title
  titlePanel("Improc Output Analysis"),
  
  fluidRow(style = "background-color:#e6e6e6;",
    #titlePanel("Select Data"),
    column(6, shinyFeedback::useShinyFeedback(),
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

  fluidRow(style = "background-color:#cccccc;",
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

  fluidRow(style = "background-color:#e6e6e6;",
    column(3,
      selectInput("ab1", "Select Antibody Cycle",
        choices = NULL, selected = NULL, multiple = TRUE
      )
    ),
    column(3,
      selectInput("band", "Select Band ID",
        choices = NULL, selected = NULL, multiple = TRUE
      )
    ),
    column(3,
      selectInput("class", "Select Class ID",
        choices = NULL, selected = NULL, multiple = TRUE
      )
    ),
    column(3,
      selectInput("membrane", "Select Membrane ID",
        choices = NULL, selected = NULL, multiple = TRUE
      )
    )
  ),

  fluidRow(
    column(10,
      plotOutput("distPlot")
    ),
    column(2,
      selectInput("color", "Color datapoints by: ",
                  choices = c("Antibody" = "Ab1_name",
                              "Band ID" = "band",
                              "Class" = "class",
                              "Membrane ID" = "membrane_id",
                              "Lane" = "lane"),
                  selected = NULL, multiple = FALSE),
      selectInput("scale", "Choose Y-axis Scale: ",
                  choices = c("Normal" = "normal",
                              "Log10" = "log",
                              "Natural Log" = "ln"),
                  selected = NULL, multiple = FALSE)
    )
  ),
  fluidRow(style = "background-color:#e6e6e6;",
    textOutput("lines"),
    actionButton("dfil", "Filter Data")
  )
)