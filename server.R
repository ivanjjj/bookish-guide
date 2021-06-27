# bookish-guide Server
# Author: Ivan Jennings

# Load in relevant libraries
library(shiny)
library(stringr)
library(dplyr)

# Read in csv files which contain the top words for each n-gram
nogram <- read.csv("nogram.csv")
bigram <- read.csv("bigram.csv")
trigram <- read.csv("trigram.csv")
quadgram <- read.csv("quadgram.csv")

# initiate the text for each button so that we can add to it later on.
button1_word <- ""
button2_word <- ""
button3_word <- ""

# Function for cleaning data that is input by the user and sent to the get_next_word function

# args:
# sentence(str): document of text
# returns the same document of text after performing the following transformations

# Removes non-alphanumeric characters
# Removes punctuation, but keeps apostrophes that are part of a word
# Removes numbers
# Converts words to lower case
# Trims white space

clean_input <- function(sentence){
    sentence <- str_replace_all(sentence, "[^[:alnum:][:space:]']", "")
    sentence <- str_replace_all(sentence, "\\s*'\\B|\\B'\\s*", "")
    sentence <- str_replace_all(sentence, "[[:digit:]]+", "")
    sentence <- stringr::str_to_lower(sentence)
    sentence <- str_trim(sentence, side = c("right"))
    return(sentence)
}

# Function for retrieving the next word based on the last 3 words in the input text.
# args:
# sentence(str): string of text input by the user
# returns dataframe of  words with 3 rows and one column ordered by top frequency first

get_next_word <- function(sentence){
    sentence <- clean_input(sentence)
    num_words <- str_count(sentence, "\\w+")
    word_1 <- ""
    word_2 <- ""
    word_3 <- ""
    if(num_words>2){word_1 <- word(sentence, -3,-3)}
    if(num_words>1){word_2 <- word(sentence, -2,-2)}
    if(num_words>0){word_3 <- word(sentence, -1,-1)}

    next_word <- get_quadgram(word_1, word_2, word_3)

    if(is.na(next_word[1])==TRUE){
        next_word <- get_trigram(word_2, word_3)
    }
    if(is.na(next_word[1])==TRUE){
        next_word <- get_bigram(word_3)
    }
    if(is.na(next_word[1])==TRUE){
        next_word <- sample(nogram$word, 1, prob=nogram$freq)
    }
    return(next_word)
}

# Helper functions for retrieving top words from the csv files for the get_next_word function
# args:
# word(x)(str): input 1, 2 or 3 words in string format
# returns first n-gram match if available



get_bigram <- function(word){
    filter(bigram,word_1==word)[1:3,2]
}
get_trigram <- function(word1,word2){
    filter(trigram,word_1==word1, word_2==word2)[1:3,3]
}
get_quadgram <- function(word1,word2,word3){
    filter(quadgram,word_1==word1, word_2==word2, word_3==word3)[1:3,4]
}

# Server function for the main code

shinyServer(function(input, output, session) {
    # initialises text box for user entry
    output$value <- renderText({ input$text_input })

    # reactive code for each button, which appends button text (predictions) to the main text field
    observeEvent(input$button1, {
        x <- input$text_input
        updateTextAreaInput(session, "text_input", value = paste(x, button1_word))

    })
    observeEvent(input$button2, {
        x <- input$text_input
        updateTextAreaInput(session, "text_input", value = paste(x, button2_word))

    })
    observeEvent(input$button3, {
        x <- input$text_input
        updateTextAreaInput(session, "text_input", value = paste(x, button3_word))

    })

    # Code which updates predictions based on user input
    observe({
        # passes user input into variable x
        x <- input$text_input
        # Get prediction for next word based on input text and assign to y variable
        y <- get_next_word(x)
        # Update each button with the top predictions and assign to global variable
        button1_word <<- y[1]
        button2_word <<- ifelse(is.na(y[2]), "", y[2])
        button3_word <<- ifelse(is.na(y[3]), "", y[3])
        updateActionButton(session, "button1",
                           label = button1_word)
        updateActionButton(session, "button2",
                           label = button2_word)
        updateActionButton(session, "button3",
                           label = button3_word)


    })


})
