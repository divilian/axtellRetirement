
library(shiny)

APP.TITLE <- "Shiny Sim"


shinyUI(pageWithSidebar(title=APP.TITLE,

    tags$head(tags$link(rel="stylesheet", type="text/css",
        href="shinysim.css")),

    progressInit(),

    headerPanel(APP.TITLE),

    sidebarPanel(
        h3("Simulation parameters"),
        fluidRow(
            # Insert input widgets for each sim parameter
            radioButtons("seedType",label="",
                choices=c("Random seed"="rand",
                    "Specific seed"="specific"),
                selected="rand",
                inline=TRUE),
            conditionalPanel(condition="input.seedType == 'specific'",
                numericInput("seed","Seed",value=0)),
            # May not always want to offer this choice
            numericInput("maxTime","Number of sim generations",
                value=10,min=1,step=1)
            actionButton("runsim",label="Run sim"),
            htmlOutput("log")
        )
    ),

    mainPanel(
        # Insert output widgets for each type of analysis
        tabsetPanel(
            tabPanel("Analysis 1",
                plotOutput("analysis1Plot")
            ),
            tabPanel("Analysis 2",
                plotOutput("analysis2Plot")
            )
        )
    )
))
