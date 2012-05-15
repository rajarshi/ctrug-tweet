ctrug-tweet
===========

This project contains the R sources and some of the data to run the examples I presented at the CT R 
Users Group meeing on May 15, 2012. The focus of this talk was to show how R can be used to evaluate
text to generate a "sentiment score". It's significantly inspired by Jeff Breens [tutorial](https://github.com/jeffreybreen/twitter-sentiment-analysis-tutorial-201107) on sentiment scoring of tweets pertaining to airlines.

My example is based on the work of [Prof. Debarchana Ghosh](http://www.geography.uconn.edu/people/ghosh.html)
 who is investigating health realated issues such as obesity, using Twitter as one possible data source. The 
current dataset contains approximately 180K tweets related to the topic of pizza being [classified as a 
vegetable](http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0CIMBEBYwAA&url=http%3A%2F%2Fwww.msnbc.msn.com%2Fid%2F45306416%2Fns%2Fhealth-diet_and_nutrition%2Ft%2Fpizza-vegetable-congress-says-yes%2F&ei=zBGxT9btA-Pr0gHCpdykDA&usg=AFQjCNHX7_7RIhSUiFbOH-F15EXeVaK_dg)

Tweets were downloaded over an extended period of time using a PHP client. Sentiment scoring is performed 
using a simple dictionary lookup. The first approach uses Breens word lists while the second approach
employs [SentiWordNet](http://sentiwordnet.isti.cnr.it/), which provides a finer way to score sentiments
(though I don't go into the details of [POS tagging](http://en.wikipedia.org/wiki/Part-of-speech_tagging)). The
Breen word lists are available from this repository. However, I cannot redistribute the SentiWord list and
even though I processed it into a simple CSV for the example code, I don't think I have permission to 
redistribute it.

I should point out that I'm not a text-mining expert and am still on the fence on the validity of sentiment
scoring. This presentation focuses on the use of R in such an application and not on the pros/cons of 
sentiment analysis itself.
