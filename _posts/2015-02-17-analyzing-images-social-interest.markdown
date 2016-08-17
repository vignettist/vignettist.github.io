---
layout: post
title: Analyzing photos for "social interest"
---
<img src="/images/fulls/social-interest/facebook_tiles.jpg" class="fit image">

## What makes a photo interesting?

This is a very difficult question to answer, as image processing algorithms don't do well with subjectivity. Flickr has their interestingness algorithm, but it is based primarily on initial user interactions with the image: views, favorites, and comments. [^flickr] How could we tell that an image might be interesting *before* anyone has seen it?

Recent research pushes in convolutional neural networks have produced promising results, showing the feasibility of analyzing images for subjective style, [^karayev] aesthetic quality, [^lu1] or both. [^lu2] However, aesthetic quality as measured by Flickr or DPChallenge users is not exactly what [Vignette](http://vignette.cool) is interested in. We want to know what images will have "*social interest*."

This is, perhaps, an even more difficult question to answer. Different people can find the same image either interesting or uninteresting, depending on whether they know the people photographed or have familiarity with the location. Some people like portraits, some people like landscapes. Some people care if an image is blurry, some people are just happy to see a photo of their niece. This definition of "social interest" will change not only from person to person but also in the same person over time. It is an intensely subjective, vague, personal, and unstable question to try to answer. But let's try anyway.

## Building a dataset

To approach this question, we first need a dataset that we can analyze. Perhaps the largest dataset of "social" images today exists on Facebook. Furthermore, these images are associated with a quantitative response variable, the number of "likes," that we can expect to be imperfectly correlated with the "social interest" we are interested in measuring.

However, Facebook does not make this data easy to access. Though you, as a user, may see your friends photos, as a consumer of the Graph API, you may not. [^graphapi]

The alternative to using Facebook's API is the time-consuming process of scraping pages. The most straightforward way to accomplish this is through the use of a headless browser, essentially a standard web browser that doesn't render to the screen. Then, we can extract the DOM elements that carry the information we need.

With this method, I created a small database of approximately 85,000 images from Facebook.

*It is important to note that this is an incredibly biased dataset -- as I can only build a dataset of my friends, it only contains my friends (and the images that they post.) This means it is very strongly biased towards San Francisco, MIT, and Oregon, and as a result that it is whiter and more educated than the general population. Attempts to generalize from any results here must be done with extreme caution. However, looking at the differences in what different populations find "socially interesting" could be extremely fascinating.*

### Scraping Facebook

The scraping was done using Python, with Selenium and PhantomJS. There's nothing particularly elegant about it -- it loads up pages exactly like you or I would in our web browser (though it loads the mobile version), it scrolls to the bottom of the page, and then it looks for specific DOM elements.

It begins by creating a list of users, then searching their walls for photos to create a list of Faceboook photo IDs. Then, it creates a database with the location of each photo and the number of likes it has received, as well as some other metadata including the date it was posted and who posted it. Finally, the original image is downloaded from Facebook and copies of several sizes are created.

## Initial observations

### The "Instagram effect?"

## Citations

[^flickr]: Quora. [How does Flickr's interestingness work?](https://www.quora.com/How-does-Flickrs-interestingness-work) 2011.

[^karayev]: Karayev, et. al. [Recognizing image style](https://sergeykarayev.com/files/1311.3715v3.pdf). 2014.

[^lu1]: Lu, et. al. [RAPID: Rating Pictorial Aesthetics using Deep Learning](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ACMMM2014/lu.pdf). 2014.

[^lu2]: Lu, et. al. [Deep Multi-Patch Aggregation Network for Image Style, Aesthetics, and Quality Estimation](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ICCV15/lu.pdf). 2015.

[^graphapi]: [Facebook Graph API](https://developers.facebook.com/docs/graph-api)