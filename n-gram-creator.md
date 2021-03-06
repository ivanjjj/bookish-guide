---
title: "bookish-guide model creator"
author: "Ivan Jennings"
date: "21/04/2021"
output:
  html_document:
    keep_md: yes
---
Load in the appropriate libraries


```r
knitr::opts_chunk$set(echo = TRUE)
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library(stopwords)
library(quanteda)
```

```
## Package version: 3.0.0
## Unicode version: 10.0
## ICU version: 61.1
```

```
## Parallel computing: 8 of 8 threads used.
```

```
## See https://quanteda.io for tutorials and examples.
```

```r
library(quanteda.textplots)
library(quanteda.textmodels)
library(tidyr)
```

## Download
Code to download the appropriate files and save them into the local directory. We will use the swiftkey data set which includes a 3 corpus' of text from news articles, twitter and blogs.


```r
## Download file if it doesn't already exist
if(!file.exists("swiftkey_data.zip")){
  url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
  download.file(url, "swiftkey_data.zip")
}
if(!dir.exists("final")){
  zip::unzip("swiftkey_data.zip")
}

if(!file.exists("badwords.txt")){
  url2 <- "https://www.cs.cmu.edu/~biglou/resources/bad-words.txt"
  download.file(url2, "badwords.txt")
}
```

## Load

Next we will load the data into R from the downloaded files.


```r
## load data into R
blog_file <- paste(getwd(), "/final/en_US/en_US.blogs.txt", sep = "")
news_file <- paste(getwd(), "/final/en_US/en_US.news.txt", sep = "")
twitter_file <- paste(getwd(), "/final/en_US/en_US.twitter.txt", sep = "")

blog_data <- read.delim(blog_file, header = FALSE, quote= "", sep = "\n")
news_data <- read.delim(news_file, header = FALSE, quote= "", sep = "\n")
twitter_data <- read.delim(twitter_file, header = FALSE, quote= "", sep = "\n", skipNul = TRUE, encoding = "UTF-8")

badwords <- read.delim("badwords.txt", header = FALSE, quote= "", sep = "\n", skipNul = TRUE)
names(badwords) <- c("txt")
```

# Transform

The following code extracts 10% of the samples of text, so that we don't overload the training model with data. We also set the seed so that this can be reproduced.


```r
set.seed(553)
blog <- data.frame(txt = sample(blog_data$V1, length(blog_data$V1)*0.1, replace = FALSE))
twitter <- data.frame(txt = sample(twitter_data$V1, length(twitter_data$V1)*0.1, replace = FALSE))
news <- data.frame(txt = sample(news_data$V1, length(news_data$V1)*0.1, replace = FALSE))
```

Next we use the quanteda functions to extract the word tokens and remove unnecessary data from the corpus - e.g. punctuation, http code. We then convert the list of tokens into a document freqency matrix.


```r
x <- rbind(twitter,
           news, blog)
x <- data.frame(doc_id = row.names(x),
                   text = x$txt,
                   stringsAsFactors = FALSE)
rm(blog, blog_data, news, news_data, twitter, twitter_data)

corpus <- corpus(x)
tokens <- tokens(corpus)
tokens2 <- tokens(tokens, remove_numbers=TRUE, remove_punct=TRUE, remove_symbols=TRUE, remove_url=TRUE) %>%
  tokens_remove(badwords$txt)

dfm <- tokens2 %>% dfm()
```

The following sets of code will extract bigrams, trigrams, quadrams & nograms (nograms = unigrams) and then save this into csv files for later use in our prediction model.


```r
bigrams <- tokens2 %>% tokens_ngrams(2) %>% dfm()

feat <- names(topfeatures(bigrams, 10000))
bigrams_select <- dfm_select(bigrams, pattern = feat, selection = "keep")

y <- sort(colSums(bigrams_select), TRUE)
y <- data.frame(names(y),y, row.names = NULL)

names(y) <- c("word","count")

y <- y %>%
  mutate(freq = count / sum(count)) %>%
  separate(word, c("word_1","word_2"), "_")

write.csv(y, "bigram.csv", row.names = FALSE)
rm(bigrams, bigrams_select)
```


```r
trigrams <- tokens2 %>% tokens_ngrams(3) %>% dfm()

feat <- names(topfeatures(trigrams, 10000))
trigrams_select <- dfm_select(trigrams, pattern = feat, selection = "keep")

y <- sort(colSums(trigrams_select), TRUE)
y <- data.frame(names(y),y, row.names = NULL)

names(y) <- c("word","count")

y <- y %>%
  mutate(freq = count / sum(count)) %>%
  separate(word, c("word_1","word_2","word_3"), "_")

write.csv(y, "trigram.csv", row.names = FALSE)
rm(trigrams, trigrams_select)
```


```r
quadgrams <- tokens2 %>% tokens_ngrams(4) %>% dfm()

feat <- names(topfeatures(quadgrams, 10000))
quadgrams_select <- dfm_select(quadgrams, pattern = feat, selection = "keep")

y <- sort(colSums(quadgrams_select), TRUE)
y <- data.frame(names(y),y, row.names = NULL)

names(y) <- c("word","count")

y <- y %>%
  mutate(freq = count / sum(count)) %>%
  separate(word, c("word_1","word_2","word_3", "word_4"), "_")

write.csv(y, "quadgram.csv", row.names = FALSE)
rm(quadgrams, quadgrams_select)
```


```r
nograms <- tokens2 %>% tokens_ngrams(1) %>% dfm()

feat <- names(topfeatures(nograms, 100))
nograms_select <- dfm_select(nograms, pattern = feat, selection = "keep")

y <- sort(colSums(nograms_select), TRUE)
y <- data.frame(names(y),y, row.names = NULL)

names(y) <- c("word","count")

y <- y %>%
  mutate(freq = count / sum(count))

write.csv(y, "nogram.csv", row.names = FALSE)
rm(nograms, nograms_select, dfm, badwords, tokens, tokens2, x, y)
```
