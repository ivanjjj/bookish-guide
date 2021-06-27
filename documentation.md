---
title: "bookish-guide: Next Word Prediction App"
author: "Ivan Jennings"
date: "31/05/2021"
output:
  html_document:
    keep_md: yes
---



## How to use this application

- Enter text in the text field at the top of the page
- While you are typing in text, the button above the text will provide a prediction for the next word based on the last words you have written (up to 3 last words)
- You can also click on the button at the top to add the word to the end of your text

## About

- This app retrieves data that has been prepared by n-gram-creator
- n-gram-creator downloads swiftkey data that has been taken from news sites, blogs & twitter. The data is cleaned and then a model is created. The resulting data is uploaded to this shiny app for word predictions

