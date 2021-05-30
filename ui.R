#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Next Word Predictor"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            actionButton("button1", "1st word"),
            actionButton("button2", "2nd word"),
            actionButton("button3", "3rd word")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            textAreaInput("text_input", "Enter Text Here:", width = "500px")
        )
    )
))
