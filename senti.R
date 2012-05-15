library(multicore)
library(ggplot2)
library(igraph)
library(reshape)

d <- read.csv('pizza-unique.csv', colClass='character', comment='', header=TRUE)
d$geox <- as.numeric(d$geox)
d$geoy <- as.numeric(d$geoy)

remove.urls <- function(x) gsub("http.*$", "", gsub('http.*\\s', ' ', x))
remove.html <- function(x) gsub('&quot;', '', x)

d$text <- remove.urls(d$text)
d$text <- remove.html(d$text)
d$text <- gsub("@", "FOOBAZ", d$text)
d$text <- gsub("[[:punct:]]+", " ", d$text)
d$text <- gsub("FOOBAZ", "@", d$text)
d$text <- gsub("[[:space:]]+", ' ', d$text)
d$text <- tolower(d$text)

## Simple approach, based on code/slides from Jeff Breen
posw <- read.table('breen/positive-words.txt', header=FALSE, comment=';', as.is=TRUE)[,1]
negw <- read.table('breen/negative-words.txt', header=FALSE, comment=';', as.is=TRUE)[,1]

score.breen <- function(tweet) {
  words <- strsplit(tweet, "\\s+")[[1]]
  pm <- sum(!is.na(match(words, posw)))
  nm <- sum(!is.na(match(words, negw)))
  return(pm-nm)
}

## Use SentiWordNet - slightly better resolution
swn <- read.csv('sentinet_r.csv', header=TRUE, as.is=TRUE)
swn <- subset(swn, !is.nan(PosScore) & !is.na(ID))

## distribution of parts of speech
tmp <- table(swn$POS)
names(tmp) <- c('', 'Adjective', 'Noun', 'Adverb', 'Verb')
tmp <- data.frame(tmp)[-1,]
ggplot(tmp, aes(x=Var1, y=Freq))+geom_bar(stat='identity')+
  xlab("Part of Speech") + ylab("Frequency")

## evaluate whether each word is pos, neg or neutral
## by taking the value of pos-neg: >0 => pos, <0 => neg etc
status <- sapply(1:nrow(swn), function(x) {
  if (swn$Pos[x] > swn$Neg[x]) return("positive")
  else if (swn$Pos[x] < swn$Neg[x]) return("negative")
  else return("neutral")
})
tmp <- data.frame(POS=swn$POS, Status=status)
tmp <- data.frame(do.call('rbind', by(tmp, tmp$POS, function(x) table(x$Status))))
tmp$pos <- c('adjective', 'noun', 'adverb', 'verb')
tmp <- melt(tmp, id='pos', variable_name = 'Sentiment')
ggplot(tmp, aes(x=pos,y=value,fill=Sentiment))+geom_bar(position='fill')+
  xlab("")+ylab("Proportion")

## distribution of 'objectivity' of the individual words
tmp <- swn
tmp$os <- 1-(tmp$PosScore+tmp$NegScore)
ggplot(tmp, aes(x=os))+geom_histogram(colour='black', fill='white')+
  xlab("Objectivity Score") + ylab("Frequency")


## match a term to SWN and return the pos & neg scores
swn.match <- function(w) {
  tmp <- subset(swn, Term == w)
  if (nrow(tmp) >= 1)
    return(tmp[1,c(3,4)])
  else return(c(0,0))
}

## generate a 'sentiment score' using SentiWordNet
score.swn <- function(tweet) {
  words <- strsplit(tweet, "\\s+")[[1]]
  cs <- colSums(do.call('rbind',
                        lapply(words, function(z) swn.match(z))))
  return(cs[1]-cs[2])
}

## do the same thing, but faster
score.swn.2 <- function(tweet) {
  words <- strsplit(tweet, "\\s+")[[1]]
  rows <- match(words, swn$Term)
  rows <- rows[!is.na(rows)]
  cs <- colSums(swn[rows,c(3,4)])
  return(cs[1]-cs[2])  
}

## 6052 sec for score.swn
## 461 sec for score.swn2

#scores.swn <- mclapply(d$text, score.swn)
scores.swn <- mclapply(d$text, score.swn.2)
scores.breen <- mclapply(d$text, score.breen)

save.image('work.Rda')

# lets explore scores
d$swn <- unlist(scores.swn)
d$breen <- unlist(scores.breen)

tmp <- rbind(data.frame(Method='SWN', Scores=d$swn),
             data.frame(Method='Breen', Scores=d$breen))
ggplot(tmp, aes(x=Scores, fill=Method))+geom_density(alpha=0.25)+
  xlab("Sentiment Scores")

# geocoded
library(maps)
tmp <- subset(d, !is.na(geox) & geoy < -65 & geoy > -130 & geox > 25 & geox < 50)
m <- map_data('state')
ggplot()+
  geom_polygon( data=m, aes(x=long, y=lat, group=group),
               colour='grey70', fill=NA) +
  geom_point(data=tmp, aes(geoy, geox, colour=swn, size=abs(swn)), alpha=0.75) +
  opts(axis.text.x = theme_blank(),
       axis.text.y = theme_blank(),
       axis.ticks = theme_blank(),
       axis.title.x = theme_blank(),
       axis.title.y = theme_blank()) +
  xlab("") + ylab("") +
  scale_colour_gradient(low="red", high="green")
