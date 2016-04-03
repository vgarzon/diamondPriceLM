# server.R
# Diamond price linear model
# 2016-04-03

library(shiny)
library(caret)
library(ggplot2)

# Load diamonds data from ggplot2
data("diamonds")

shinyServer(function(input, output) {

    # Sample data subset to reduce execution time    
    dataInput <- reactive({
        input$newSample
        diamonds[sample(nrow(diamonds), input$sampleSize), ]
    })

    # Reactive data partitioning
    dataPart <- reactive({
        dataSample <- dataInput()
        inTrain <- createDataPartition(y = dataSample$price,
                                       p = input$trainFrac, list=FALSE)
        # Return partitioned data
        list(training = dataSample[ inTrain, ], 
             testing  = dataSample[-inTrain, ])
    })

    # Build linear model formula according to feature selection
    fitFormula <- reactive({
        # Basic formula
        fmla <- price ~ carat

        # Add / change terms
        if (input$addLogPrice) fmla <- update(fmla, I(log(.)) ~ .)
        if (input$addCRCarat)  fmla <- update(fmla, . ~ . + I(carat^(1/3)))
        if (input$addClarity)  fmla <- update(fmla, . ~ . + clarity)
        if (input$addColor)    fmla <- update(fmla, . ~ . + color)
        if (input$addCut)      fmla <- update(fmla, . ~ . + cut)
        if (input$addDepth)    fmla <- update(fmla, . ~ . + depth)
        if (input$addTable)    fmla <- update(fmla, . ~ . + table)
        
        return(fmla)
    })

    # Fit linear model using 
    modelFit <- reactive({
        lm(fitFormula(), data = dataPart()$training)
    })
    
    # Plot of observed (test data) versus predicted price
    output$plot <- renderPlot({
        testing <- dataPart()$testing
        predFit <- predict(modelFit(), newdata = testing)

        # Return data to original scale if fit done in log scale
        if (input$addLogPrice) predFit <- exp(predFit)

        # Plot using square axes
        par(pty = "s")
        plot(predFit, testing$price,
             main = "Test Data Price versus Predictions",
             xlab = "Prediction", ylab = "Observations")
        priceRange <- range(testing$price)
        predRange <- range(predFit)
        lines(priceRange, priceRange, col = "red", lwd = 3)
        
        # Print prediction error, RMSE and R^2
        predError <- postResample(predFit, testing$price)
        RMSEText <- paste("RMSE=", round(predError[1], 1))
        RsqdText <- paste("Rsquared=", round(predError[2], 3))
        text(1.25*mean(predRange), 2500, RMSEText, adj = c(0,0), col = "blue")
        text(1.25*mean(predRange), 1000, RsqdText, adj = c(0,0), col = "blue")
    })

    # Display model formula
    output$textFormula <- renderText({
        fmla <- fitFormula()
        as.character(paste(fmla[2], "~", fmla[3]))
    })
    
    # Display model coefficients
    output$text1 <- renderPrint({
        round(modelFit()$coefficients, ifelse(input$addLogPrice, 3, 1))
    })
    
})
