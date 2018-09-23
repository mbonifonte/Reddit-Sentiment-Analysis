library(tidytext)
library(tidyr)
library(stringr)
library(ggplot2)
library(magrittr)
library(dplyr)
library(lubridate)
library(ggridges)

# Load csv of Reddit comments into dataframe

All_comments <- read.csv(file="C:/Users/Madmi/Documents/RamHacks/subreddit_elon_comments.csv", 
                         header=TRUE, stringsAsFactors=FALSE) 
All_comments %>% glimpse()

# OK, we have more than 1,000 comments from Reddit search "Elon Musk OR SpaceX OR Tesla"
# Let's filter these comments by substance and then export each as a CSV for exploration

# Get Elon Musk comments

All_musk_comments <- All_comments %>%
  filter(str_detect(body, "musk")) %>% glimpse()
write.csv((All_musk_comments), "./elon/all_musk_mentions.csv")


# Get SpaceX comments

All_spacex_comments <- All_comments %>%
  filter(str_detect(body, "spacex")) %>% glimpse()
write.csv((All_spacex_comments), "./elon/all_spacex_mentions.csv")


# Get Tesla comments

All_tesla_comments <- All_comments %>%
  filter(str_detect(body, "tesla")) %>% glimpse()
write.csv((All_tesla_comments), "./elon/all_tesla_mentions.csv")


# In Excel, we surveyed each of these substances, adding a corresponding "term" column to each
# We then pasted all of these into one spreadsheet, "all_everything_mentions.csv" 
# This could have easily been done with the "dplyr" R package, too



# Visualizing substance mentions over time

# Preparing plot of all substance mentions over time


TotalMentions <- read.csv("./elon/all_everything_mentions.csv", 
                          header=TRUE, stringsAsFactors=FALSE) 
TotalMentions %>% glimpse()


TotalMentions %>% 
  arrange(created) %>% glimpse() 


# Visualize mentions of each substance across time

ggplot(TotalMentions, aes(timestamp)) + geom_bar(aes(fill=factor(term)), stat = "count") +
  facet_grid(~term)

# Look at all substance mentions over time using the Joy Division plot

ggplot(TotalMentions, aes(x = timestamp, y = term)) + geom_density_ridges()

# Visualize all using small multiples 

ggplot(TotalMentions, aes(timestamp, color=term)) + geom_histogram(aes(binwidth=0.01), stat = "count") +
  facet_grid(~term)

# We also tried a few other visualizations

ggplot(TotalMentions, aes(timestamp)) + geom_histogram(aes(fill=factor(term)), binwidth="40", stat = "count") +
  facet_grid(~term)

ggplot(TotalMentions, aes(TotalMentions$timestamp, color=term)) + geom_freqpoly(aes(binwidth=0.01), stat="bin") 

ggplot(all_sentiment, aes(all_sentiment$Month)) + geom_bar(aes(fill=factor(all_sentiment$sentiment)), stat = "count")


# Sentiment analysis

# We employed sentiment analysis using the "tidytext" R package
# and our CSV file of mentions of 3 search terms

# First, load the AFINN sentiment analysis library that comes with "tidytext" 

AFINN <- sentiments %>%
  filter(lexicon == "AFINN") %>%
  select(word, afinn_score = score)

TotalMentionsComments <- TotalMentions

# Tokenize comments into one-word rows and cut out stop words 
# Then join AFINN-scored words with words in comments, if present
# Return 114,000-row tibble with X1, term, word, month and sentiment score

all_sentiment <- TotalMentionsComments %>%
  select(body, X, created, term, timestamp, Month) %>%
  unnest_tokens(word, body) %>%
  anti_join(stop_words) %>%
  inner_join(AFINN, by = "word") %>%
  group_by(X, term, word, Month) %>%
  summarize(sentiment = mean(afinn_score))

all_sentiment

# all_avg_sent <- all_sentiment %>%
#   summarize(avg = mean(sentiment)) 
# 
# all_avg_sent
# 
# write_csv((all_avg_sent), "reddit/all_avg_sent.csv")


# Visualize sentiment analysis 


# Plot words chronologically by sentiment and frequency; dot size is count of word

ggplot(all_sentiment, aes(x= all_sentiment$Month, y = all_sentiment$sentiment)) +
  geom_point() +
  geom_count() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_hline(yintercept = mean(all_sentiment$sentiment), color = "red", lty = 2)



# Count word occurences, bind two dataframes

all_sentiment_wordcount <- all_sentiment %>%
  select(X, term, word, sentiment) %>%
  group_by(word) %>%
  tally()

Bind_sent_and_word <- all_sentiment %>%
  full_join(all_sentiment_wordcount, by="word")

# Plot all substances chronologically sentiment vs. word frequency, colored by substance and facetwrapped

ggplot(Bind_sent_and_word, aes(y=all_sentiment$Month, x=sentiment, color=term)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_hline(yintercept = mean(Bind_sent_and_word$sentiment), color = "red", lty = 2) +
  facet_wrap(~term)

# Filter just our 3 terms

Filtered_sent_vs_word <- Bind_sent_and_word %>%
  filter(term == "elon" | term == "spacex" | term == "tesla") %>% glimpse()

# Plot word freq vs. sentiment, colored by substance

ggplot(Filtered_sent_vs_word, aes(y=n, x=sentiment, color=term)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.1, hjust = 1.1) 

# Adding this would add average sentiment line: + geom_hline(yintercept = mean(Filtered_sent_vs_word$sentiment), color = "red", lty = 2) 

# END