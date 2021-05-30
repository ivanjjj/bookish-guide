---
title: "Milestone Report 1"
author: "Ivan Jennings"
date: "21/04/2021"
output:
  html_document:
    keep_md: yes
---



## Executive Summary
The purpose of this report is to show some exploratory analysis of some text data which has come from 3 sources - blogs, news and twitter. Eventually this data will be used to create an app which will use natural language processing (NLP) to predict the next word in a sentence e.g. an auto-correct application such as the ones used in mobile phones.




## Data Exploration
After loading in the data, here is a summary of the dimensions of the data, and a small portion of the data that is in each file.


```r
## Get data structure from each data set
str(blog_data)
```

```
## 'data.frame':	899288 obs. of  1 variable:
##  $ V1: chr  "In the years thereafter, most of the Oil fields and platforms were named after pagan “gods”." "We love you Mr. Brown." "Chad has been awesome with the kids and holding down the fort while I work later than usual! The kids have been"| __truncated__ "so anyways, i am going to share some home decor inspiration that i have been storing in my folder on the puter."| __truncated__ ...
```

```r
str(news_data)
```

```
## 'data.frame':	1010242 obs. of  1 variable:
##  $ V1: chr  "He wasn't home alone, apparently." "The St. Louis plant had to close. It would die of old age. Workers had been making cars there since the onset o"| __truncated__ "WSU's plans quickly became a hot topic on local online sites. Though most people applauded plans for the new bi"| __truncated__ "The Alaimo Group of Mount Holly was up for a contract last fall to evaluate and suggest improvements to Trenton"| __truncated__ ...
```

```r
str(twitter_data)
```

```
## 'data.frame':	2360148 obs. of  1 variable:
##  $ V1: chr  "How are you? Btw thanks for the RT. You gonna be in DC anytime soon? Love to see you. Been way, way too long." "When you meet someone special... you'll know. Your heart will beat more rapidly and you'll smile for no reason." "they've decided its more fun if I don't." "So Tired D; Played Lazer Tag & Ran A LOT D; Ughh Going To Sleep Like In 5 Minutes ;)" ...
```

We can see that there are almost 1 million blog observations, over 1 million observations in the news data set and over 2 million in the twitter set. Let's take a sample of each text so that we can get a more efficient data set.



Next I will look at some different summaries of the files - e.g. total characters & words per portion of text (each row contains one portion of text)



![](index_files/figure-html/plot-1.png)<!-- -->

We can see that the majority of the blog data set has between 0 and 200 words as well as 0 to 1000 characters per line. The news data set has a lower quantity of words and characters per line. Finally the twitter data set is restricted by 140 characters so we can see a more even distribution between 0 and 125 characters.

Last of all, let's take a look at the top words in each data set.


```
##   count     n
## 1   the 10363
## 2    to  5910
## 3   and  5898
## 4     a  4982
## 5    of  4978
## 6     i  4313
```

```
##   count    n
## 1   the 1988
## 2    to 1650
## 3     i 1495
## 4     a 1266
## 5   you 1154
## 6   and  950
```

```
##   count    n
## 1   the 9813
## 2    to 4505
## 3     a 4465
## 4   and 4465
## 5    of 3837
## 6    in 3380
```

We can see that there is a large number of non-useful words such as "the" and "to", so we will need to do some further exploration and removal of un-needed words.

## Conclusion

We have had a good look at the data so far, but we will need to do some further cleaning and review of the data to use in our final product.

Here is the code used to get the above numbers


```r
knitr::opts_chunk$set(echo = FALSE)
library(dplyr)
library(tidytext)
library(ggplot2)
library(gridExtra)
## Download file if it doesn't already exist
if(!file.exists("swiftkey_data.zip")){
  url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
  download.file(url, "swiftkey_data.zip")
}
if(!dir.exists("final")){
  zip::unzip("swiftkey_data.zip")
}
## load data into R
blog_file <- paste(getwd(), "/final/en_US/en_US.blogs.txt", sep = "")
news_file <- paste(getwd(), "/final/en_US/en_US.news.txt", sep = "")
twitter_file <- paste(getwd(), "/final/en_US/en_US.twitter.txt", sep = "")

blog_data <- read.delim(blog_file, header = FALSE, quote= "", sep = "\n")
news_data <- read.delim(news_file, header = FALSE, quote= "", sep = "\n")
twitter_data <- read.delim(twitter_file, header = FALSE, quote= "", sep = "\n", skipNul = TRUE)
## Get data structure from each data set
str(blog_data)
str(news_data)
str(twitter_data)
## Get sample of 5000 of each corpus, set seed for reproducibility
set.seed(553)
blog <- data.frame(txt = sample(blog_data$V1, 5000, replace = FALSE))
twitter <- data.frame(txt = sample(twitter_data$V1, 5000, replace = FALSE))
news <- data.frame(txt = sample(news_data$V1, 5000, replace = FALSE))
## Create function for splitting the data out into one row for each character or word
count_token <- function(df, token){
  df %>%
  mutate(id = row_number()) %>%
  unnest_tokens(count, txt, token = token)
}

blog_char <- count_token(blog, "characters")
twitter_char <- count_token(twitter, "characters")
news_char <- count_token(news, "characters")

blog_word <- count_token(blog, "words")
twitter_word <- count_token(twitter, "words")
news_word <- count_token(news, "words")

## Get a table with the number of characters or words per line of text

count_blog_char <- count(blog_char, id)
count_twitter_char <- count(twitter_char, id)
count_news_char <- count(news_char, id)

count_blog_word <- count(blog_word, id)
count_twitter_word <- count(twitter_word, id)
count_news_word <- count(news_word, id)

## Create histograms of characters and words per row

blog_char_plot <- qplot(n, data=count_blog_char, main = "Blog/Characters", xlab = "", bins = 30)
twitter_char_plot <- qplot(n, data=count_twitter_char, main = "Twitter/Characters", xlab = "", bins = 30)
news_char_plot <- qplot(n, data=count_news_char, main = "News/Characters", xlab = "", bins = 30)
blog_word_plot <- qplot(n, data=count_blog_word, main = "Blog/Words", xlab = "", bins = 30)
twitter_word_plot <- qplot(n, data=count_twitter_word, main = "Twitter/Words", xlab = "", bins = 30)
news_word_plot <- qplot(n, data=count_news_word, main = "News/Words", xlab = "", bins = 30)
grid.arrange(blog_char_plot, twitter_char_plot, news_char_plot, blog_word_plot, twitter_word_plot, news_word_plot)
## Print top words in each data set
head(count(blog_word, count, sort = TRUE))
head(count(twitter_word, count, sort = TRUE))
head(count(news_word, count, sort = TRUE))
```
