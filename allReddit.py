# coding: utf-8
# In[29]:
#!/usr/bin/python

import praw

# In[30]:


reddit = praw.Reddit(client_id='EZj05YvLpkzVaQ', \
                     client_secret='bq2dAoxEFpJMKJp7JoEDNwCADHM', \
                     user_agent='ScrapedUp', \
                     username='madmike34455', \
                     password='FalsePassword')




topics_dict = { "title":[], "score":[], "id":[], "url":[], "comms_num": [], "created": [], "body":[] }


# In[52]:


for submission in reddit.subreddit('all').search('spacex OR elon musk OR Tesla'):
    topics_dict["title"].append(submission.title)
    topics_dict["score"].append(submission.score)
    topics_dict["id"].append(submission.id)
    topics_dict["url"].append(submission.url)
    topics_dict["comms_num"].append(submission.num_comments)
    topics_dict["created"].append(submission.created)
    topics_dict["body"].append(submission.selftext)

len(topics_dict["title"])



import pandas as pd


# In[61]:


topics_data = pd.DataFrame(topics_dict)

import datetime

def get_date(submission):
    time = submission
    return datetime.date.fromtimestamp(time)

timestamps = topics_data["created"].apply(get_date)

topics_data = topics_data.assign(timestamp = timestamps)


# In[67]:


topics_data.info()


# In[80]:


comms_dict = { "topic": [], "body":[], "comm_id":[], "created":[] }


# In[79]:


iteration = 1
for topic in topics_data["id"]:
    print(str(iteration))
    iteration += 1
    submission = reddit.submission(id=topic)
    submission.comments.replace_more(limit=None)
    for comment in submission.comments.list():
        comms_dict["topic"].append(topic)
        comms_dict["body"].append(comment.body)
        comms_dict["comm_id"].append(comment)
        comms_dict["created"].append(comment.created)

print("done")


# In[14]:


comms_data = pd.DataFrame(comms_dict)
comms_data

timestamps = comms_data["created"].apply(get_date)

comms_data = comms_data.assign(timestamp = timestamps)


# In[15]:


topics_data.to_csv("subreddit_elon_topics.csv")
comms_data.to_csv("subreddit_elon_comments.csv")
