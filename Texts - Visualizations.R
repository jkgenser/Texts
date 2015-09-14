## import data

library(ggplot2)
library(ggthemes)
library(lubridate)
library(dplyr)
library(plyr)
library(quantmod)
library(plotrix)
options(stringsAsFactors = FALSE)
df = read.csv("H:/USER/JGenser/PROJECTS/Texts/Data/messages_out.csv")


#############
## Cleaning #
#############
df$handle_id = as.factor(df$handle_id)

df$date = as.POSIXct(df$datetime, format="%Y-%m-%d", tz='UTC')

df$day <- day(df$datetime)
df$month <- month(df$datetime)
df$year <- year(df$datetime)
df$weekday = as.POSIXlt(df$datetime)$wday

df = df[df$handle_id !=0,]

## subset of  data limited to top message partners
df_lim <- df[df$tot_msgs > 1500,]
df_lim$handle_id <- as.factor(df_lim$handle_id)




df$handle_id <- as.factor(df$handle_id)
df$is_from_me <-as.factor(df$is_from_me)
total_by_id <- df %>% dplyr::filter(tot_msgs>50) %>% select(handle_id) %>%   plyr::count()
total_by_id$sort = total_by_id$freq
total_by_id$freq=NULL


sent_by_id <- df %>% dplyr::filter(tot_msgs>50, is_from_me==1) %>% select(handle_id) %>%   plyr::count()
sent_by_id$is_from_me <- factor(1, labels='Sent')
sent_by_id$freq = sent_by_id$freq * -1
sent_by_id = merge(sent_by_id, total_by_id, by='handle_id')
# sent_by_id = sent_by_id %>% transform(freq = reorder(freq, -sort))

received_by_id <- df %>% dplyr::filter(tot_msgs>50, is_from_me==0) %>% select(handle_id) %>%   plyr::count()
received_by_id$is_from_me <- factor(0, labels='Received')
received_by_id = merge(received_by_id, total_by_id, by='handle_id')
# received_by_id = received_by_id %>% transform(freq = reorder(freq, -sort))


combined = rbind(sent_by_id, received_by_id)


pbar <- ggplot(data=sent_by_id, aes(x=reorder(handle_id,-sort)))+
            geom_bar(data=sent_by_id, aes(y=freq, fill=is_from_me), stat='identity')+
            geom_bar(data=received_by_id, aes(y=freq, fill=is_from_me), stat='identity')+
            theme_hc() + scale_color_tableau() +
            ylab('# Texts Exchanged') + xlab('Contact ID') +
            theme(axis.ticks = element_blank(), axis.text.x = element_blank())+
            theme(legend.title=element_blank())+
            ggtitle('Distribution of Texting Volume by Contact')
            
print(pbar)



## cdf of CHARACTER COUNT in text messages to and from top texting partners
p <- ggplot(df_lim[df_lim$charcount <115,], aes(x=charcount, group=handle_id, color=handle_id)) +
        stat_ecdf(aes(charcount)) + theme_hc() + scale_color_tableau(name='Contact ID') +
        ylab('Cumulative') + xlab('Number of Characters in each Message') +
        ggtitle('Cumulative Distribution of Texts by Character Count - Top Texting Partners')
        
print(p)

## cdf of WORD COUNT in text messages to and from top texting partners
p2 <- ggplot(df_lim[df_lim$wordcount <45,], aes(x=wordcount, group=handle_id, color=handle_id)) +
        stat_ecdf(aes(wordcount)) + theme_hc() + scale_color_tableau(name='Contact ID') +
        ylab('cumulative') + xlab('Number of Words in each Message') +
        ggtitle('Cumulative Distribution of Texts by Word Count - Top Texting Partners')

print(p2)


df$text = 1
df$hour <- hour(df$datetime)
df$new = df$hour
df$minute <- minute(df$datetime)
df$hourminute <- df$hour + df$minute/60
texts_phm <- df$hourminute %>% plyr::count()

new = df %>% group_by(hour, day, month, year) %>% dplyr::summarise(texts_in_hr=sum(text))
new = new[new$texts_in_hr>0,]

texts_ph <- new %>% group_by(hour) %>%  dplyr::summarise(avg_tph=mean(texts_in_hr))

phm = df %>% group_by(hourminute, hour, day, month, year) %>% dplyr::summarise(texts_in_min=sum(text))
phm = phm[phm$texts_in_min>0,]
texts_phm <- phm %>% group_by(hourminute) %>% dplyr::summarise(avg_tpm=mean(texts_in_min))


texts_ph$rm <- rollmean(texts_ph$freq,texts_ph$x)

clock24.plot(texts_phm$avg_tpm, texts_phm$hourminute, main = "Average Texts by Minute of Day", point.col='blue', rp.type="s")


clock24.plot(texts_ph$avg_tph, texts_ph$hour, main = "Average Texting Intensity by Hour of Day", line.col='blue', rp.type="r",
             show.radial.grid=FALSE,show.grid.labels=FALSE, lty=1, lwd=2.5)




