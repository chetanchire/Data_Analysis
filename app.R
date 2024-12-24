#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(tools)
library(shinyFeedback)

source("helpers/utils.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

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
                        br(),
                        actionButton("append", "Append this data to previous data",
                                     width = "300px"), 
                        br(),
                        actionButton("reset", "Reset Data", width = "300px")
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
                 textOutput("lines")
                 #actionButton("dfil", "Filter Data")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    options(shiny.maxRequestSize=30*1024^2)
    
    dframe <- reactiveValues(read_data = NULL, prev_data = NULL)
    
    colist <- c("S", "class", "band", "lane", "cycle", "Ab1_name",
                "membrane_id")
    
    rdata <- reactive({
        if (is.null(input$Analysis)) {
            redata("data/analysis_log.csv", " ", colist)
            # read_csv("analysis_log.csv", show_col_types = FALSE)
        } else {
            redata(input$Analysis$datapath, "Analysis", colist)
        }
    })
    
    observeEvent(input$append, {
        dframe$read_data <- append_data(dframe$read_data, dframe$prev_data)
    })
    
    observeEvent(input$reset, {
        reset_data(dframe, colist)
    })
    
    observeEvent(rdata(), {
        dframe$prev_data <- dframe$read_data
        dframe$read_data <- rdata()
        # update_inputs(dframe$read_data)
    })
    
    observe({
        update_inputs(dframe$read_data)
    })
    
    bdata <- reactive({
        bdata <- dframe$read_data
        bdata %>%
            daFil("Ab1_name", input$ab1) %>%
            daFil("band", input$band) %>%
            daFil("class", input$class) %>%
            daFil("membrane_id", input$membrane)
    })

    output$distPlot <- renderPlot({
        req(input$xvar, input$yvar)
        
        p <- ggplot(bdata(), 
                    aes(x = !!as.name(input$xvar), y = !!as.name(input$yvar),
                        color = !!as.name(input$color))) + geom_point()
        if (input$scale == "normal") { return(p)
            } else if (input$scale == "log") {
            return(p + scale_y_continuous(transform = "log10"))
                } else if (input$scale == "ln") {
            return(p + scale_y_continuous(transform = "log"))
                }
    }, res = 96)
    
    output$lines <- renderText({
        paste0("Showing ",nrow(bdata()), " rows out of ", nrow(dframe$read_data),
               " ", nrow(dframe$prev_data))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
