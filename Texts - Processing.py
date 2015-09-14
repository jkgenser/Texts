# -*- coding: utf-8 -*-
"""
Created on Mon Aug 31 08:21:32 2015

@author: jgenser
"""

import pandas as pd
import pylab as pl
import numpy as np
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from sklearn import neighbors
from sklearn import cross_validation
from sklearn import metrics
from sklearn.cross_validation import cross_val_score
from sklearn import cluster

import sys
reload(sys)
sys.setdefaultencoding('utf8')

##read in raw data
raw = pd.read_csv("H:/USER/JGenser/PROJECTS/Texts/Data/message.csv", low_memory =False)

##read in gender flags
gender = pd.read_csv("H:/USER/JGenser/PROJECTS/Texts/Data/handle_gender_flags.csv")

##function to convert iOS datetime to pd.datetime
def getDatetime(timestamp):
    datetime = pd.to_datetime(timestamp, unit='s') + pd.DateOffset(years=31) - pd.DateOffset(hours=5)
    return datetime

## function to tokenize each text message
def text_tokenizer(text):
    wordlist=[]
    if type(text)==str:
        words=word_tokenize(unicode(text, errors='replace'))
        for word in words:
            word = word.lower()
            wordlist.append(word)
        return wordlist
    elif type(text)==float:
        return wordlist




## limit to columns of interest
columns = ['text', 'handle_id', 'date', 'is_from_me']
messages = raw[columns]

## extract datetime from iOS
messages['datetime'] = messages['date'].apply(getDatetime)

## encode all text messages to unicode
## tokenize and add count of words in each text as a feature in the dataset
messages['texts_tokenized'] = messages['text'].apply(text_tokenizer)
messages['wordcount'] = messages['texts_tokenized'].apply(len)
messages['charcount'] = messages['text'].apply(lambda x: len(str(x)))



## identify most frequent texting partners
handle_counts = messages['handle_id'].value_counts().reset_index()
handle_counts.columns = ['handle_id', 'tot_msgs']
messages = pd.merge(messages, handle_counts, on='handle_id')

## calculate counts by texting partner
sent_counts = messages[messages['is_from_me']==1]['handle_id'].value_counts().reset_index()
sent_counts.columns = ['handle_id', 'tot_sent']
received_counts = messages[messages['is_from_me']==0]['handle_id'].value_counts().reset_index()
received_counts.columns = ['handle_id', 'tot_rec']
merged_counts = pd.merge(handle_counts, sent_counts, on='handle_id')
merged_counts = pd.merge(merged_counts, received_counts, on='handle_id')

##calculate texts per day
messages['day'] = messages['datetime'].apply(lambda x: x.day)
messages['month'] = messages['datetime'].apply(lambda x: x.month)
messages['year'] = messages['datetime'].apply(lambda x: x.year)
messages['counter']=1

perday = messages.groupby(['day', 'month', 'year']).sum().reset_index()


## export for graphs
messages_out = messages[['handle_id', 'is_from_me', 'datetime', 'tot_msgs', 'wordcount','charcount']]
messages_out.to_csv('H:/USER/JGenser/PROJECTS/Texts/Data/messages_out.csv')
merged_counts.to_csv ('H:/USER/JGenser/PROJECTS/Texts/Data/counts_by_handle.csv')


########################
## Naive Bayes        ##
########################

## merge on gender identification
## manually flagged gender for handle_id with at least 100 messages
messages = pd.merge(messages, gender, on='handle_id', how='inner')


#make a set of all words in the training set:
all_words = set()
for text in messages['texts_tokenized']:
    for word in text:
        all_words.add(word)
        
def extract_features(text):
    features={}
    # Extract word frequency using ntlk.FreqDist
    text_wordfreq = nltk.FreqDist(text)
    # For every word in the training set, set the feature value
    for word in all_words:
        if word in text_wordfreq:
            features[word]=1
        else:
            features[word]=0
    return features
        
def prep_texts_sex(df):
    prepped_texts = []
    for row in df.iterrows():
        text = row[1].texts_tokenized
        sex = row[1].Sex
        prepped_texts.append([text,sex])
    return prepped_texts
    
## subset data into received and sent messages for 2013    
## first, drop records with unassigned sex    
    
#received = messages[(messages['is_from_me']==0) & (messages['year']==2013)]    
#sent = messages[(messages['is_from_me']==1) & (messages['year']==2013)]    
received = messages[messages['is_from_me']==0][0:12500]
sent = messages[messages['is_from_me']==1][0:12500]    

##these lists are two vectors, the first is the tokenized text message and the second is the sex of sender/recipient
train_r = prep_texts_sex(received[['texts_tokenized','Sex']])
train_s = prep_texts_sex(sent[['texts_tokenized','Sex']])

training_r = nltk.classify.apply_features(extract_features,train_r)
classifier_r = nltk.NaiveBayesClassifier.train(training_r)

training_s = nltk.classify.apply_features(extract_features,train_s)
classifier_s = nltk.NaiveBayesClassifier.train(training_s)


classifier_s.show_most_informative_features(100)
classifier_r.show_most_informative_features(100)

