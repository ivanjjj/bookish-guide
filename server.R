#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(stringr)
library(dplyr)


nogram <- read.csv("nogram.csv")
bigram <- read.csv("bigram.csv")
trigram <- read.csv("trigram.csv")
quadgram <- read.csv("quadgram.csv")

button1_word <- ""
button2_word <- ""
button3_word <- ""

clean_input <- function(sentence){
    sentence <- str_replace_all(sentence, "[^[:alnum:][:space:]']", "")
    sentence <- str_replace_all(sentence, "\\s*'\\B|\\B'\\s*", "")
    sentence <- str_replace_all(sentence, "[[:digit:]]+", "")
    sentence <- stringr::str_to_lower(sentence)
    sentence <- str_trim(sentence, side = c("right"))
    return(sentence)
}

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

get_bigram <- function(word){
    filter(bigram,word_1==word)[1:3,2]
}
get_trigram <- function(word1,word2){
    filter(trigram,word_1==word1, word_2==word2)[1:3,3]
}
get_quadgram <- function(word1,word2,word3){
    filter(quadgram,word_1==word1, word_2==word2, word_3==word3)[1:3,4]
}

shinyServer(function(input, output, session) {
    output$value <- renderText({ input$text_input })
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

    observe({
        # We'll use the input$controller variable multiple times, so save it as x
        # for convenience.
        x <- input$text_input
        y <- get_next_word(x)
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
