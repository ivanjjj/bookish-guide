# bookish-guide UI
# Author: Ivan Jennings

# Load in relevant libraries
library(shiny)
library(evaluate)

# Define UI for application that predicts 3 next words
shinyUI(fluidPage(

    # Application title
    titlePanel("bookish-guide: Next Word Predictor"),

    # Display 3 buttons with predictions
    sidebarLayout(
        sidebarPanel(
            actionButton("button1", "1st word"),
            actionButton("button2", "2nd word"),
            actionButton("button3", "3rd word")
        ),

        # Code for displaying the main text input
        mainPanel(
            textAreaInput("text_input", "Enter Text Here:", width = "500px"),
            includeMarkdown("documentation.md")
        )
    )
))
