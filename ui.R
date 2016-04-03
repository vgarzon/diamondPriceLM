# ui.R
# Diamond price linear model
# 2016-04-03

library(shiny)

shinyUI(pageWithSidebar(
    
    headerPanel("Diamond Price Linear Model"),
    
    sidebarPanel(
        
        # Limit sample size to 30k to speed-up app
        sliderInput("sampleSize", "Sample Size", min = 5000, max = 30000,
                    value = 10000, step = 5000),

        # Button to resample input data
        actionButton("newSample", "New Sample"),
        br(), br(),

        # Training fraction, default 70%
        sliderInput("trainFrac", "Training Fraction", min = 0.1, max = 0.9,
                    value = 0.7, step = 0.1),

        h4("Select Features"),
    
        # Select model features
        checkboxInput("addLogPrice", "log(price)"),
        checkboxInput("addCRCarat",  "carat^(1/3)"),
        checkboxInput("addClarity",  "clarity"),
        checkboxInput("addColor",    "color"),
        checkboxInput("addCut",      "cut"),
        checkboxInput("addDepth",    "depth"),
        checkboxInput("addTable",    "table")

    ),
    
    mainPanel(
        h4("Model"),
        verbatimTextOutput("textFormula"),

        # Plot of test price data versus prediction        
        plotOutput("plot"),
        
        # Fit coefficients
        h4("Fit Coefficients"),
        verbatimTextOutput("text1")
    )
))