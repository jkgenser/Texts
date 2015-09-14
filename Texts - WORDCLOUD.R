library(dplyr)
library(RColorBrewer)
library(wordcloud)

## import data
sent = read.csv('H:/USER/JGenser/PROJECTS/Texts/Data/sent_wordcloud.csv')
received = read.csv('H:/USER/JGenser/PROJECTS/Texts/Data/received_wordcloud.csv')

sent$color='tomato'
sent[sent$sex=='F',]$color = 'steelblue'
colorlist = basecolors[match(sent$sex,unique(sent$sex))]

received$color='tomato'
received[received$sex=='F',]$color = 'steelblue'


wordcloud(words = sent$word, freq = sent$weight, min.freq = 1,
          max.words=50, random.order=FALSE, rot.per=0.15, scale=c(4,.2),
          colors=sent$color, vfont=c("sans serif","bold"), ordered.colors=TRUE)
# dev.off()

wordcloud(words = received$word, freq = received$weight, min.freq = 1,
          max.words=50, random.order=FALSE, rot.per=0.15, scale=c(5,.2),
          colors=received$color, vfont=c("sans serif","bold"), ordered.colors=TRUE)

