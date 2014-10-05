
library(shiny)
library(shinyIncubator)

# CHANGE: The title of your simulation webapp.
APP.TITLE <- "Shiny Sim"


shinyUI(fluidPage(

    tags$head(tags$link(rel="stylesheet", type="text/css",
        href="shinysim.css")),

    progressInit(),

    headerPanel(APP.TITLE),

    sidebarPanel(
        h3("Simulation parameters"),
        fluidRow(

            # CHANGE: Insert input widgets for each simulation parameter you
            # want to be able to change through the Web UI. "Numeric
            # multiplier" is a sample.
            numericInput("simParam1",label="Numeric multiplier",value=1,
                min=0,max=10),

            radioButtons("seedType",label="",
                choices=c("Random seed"="rand",
                    "Specific seed"="specific"),
                selected="rand",
                inline=TRUE),
            conditionalPanel(condition="input.seedType == 'specific'",
                numericInput("seed","Seed",value=0)),

            # OPTIONAL: Only include this if it makes sense for the user to be
            # able to tweak the length of the simulation.
            numericInput("maxTime","Number of sim periods",
                value=10,min=1,step=1),
            actionButton("runsim",label="Run sim"),
            htmlOutput("log")
        )
    ),

    mainPanel(
        # CHANGE: Insert output widgets for each type of analysis. Here we
        # just have two plots (the second of which isn't even set to anything
        # in server.R) as placeholders.
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
