## import data

library(ggplot2)
library(ggthemes)
library(lubridate)
library(plyr)
library(readstata13)
library(quantmod)
library(plotrix)
options(stringsAsFactors = FALSE)
df = read.dta13('H:/USER/JGenser/PROJECTS/Texts/Data/calendarfromStata.dta')


df$monthf<-factor(df$month,levels=as.character(1:12),labels=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),ordered=TRUE)
df$weekdayf<-factor(df$dow+1,levels=rev(1:7),labels=rev(c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")),ordered=TRUE)
df$texts_per_day = df$counter





P<- ggplot(df, aes(monthweek, weekdayf, fill = texts_per_day)) + 
  geom_tile(colour = "white") + facet_grid(year~monthf) + scale_fill_gradient(low="snow", high="red") +  xlab("Week of Month") + ylab("")+
  theme_pander() + ggtitle('Texts Received and Sent Each Day')
P

df$weekdayf <- factor(df$dow, levels = (0:6), labels=c("Mon","Tue","Wed","Thu","Fri","Sat","Sun"))
p <- ggplot(df, aes(x=texts_per_day)) + 
  geom_density(aes(y=..density..),size=.65, fill='lightblue3', alpha=0.3) +
  facet_grid(weekdayf ~.)+
  # theme(axis.ticks = element_blank(), axis.text.y = element_blank())
  theme_hc(axis.ticks = element_blank(), axis.text.y=element_blank())
print(p)

p <- ggplot(df, aes(x=weekdayf, y=texts_per_day)) + 
  geom_density(aes(y=..density..))
print(p)
