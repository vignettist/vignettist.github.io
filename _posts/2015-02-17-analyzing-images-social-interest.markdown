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

## Initial observations

### The "Instagram effect?"

## Citations

[^flickr]: Quora. [How does Flickr's interestingness work?](https://www.quora.com/How-does-Flickrs-interestingness-work) 2011.

[^karayev]: Karayev, et. al. [Recognizing image style](https://sergeykarayev.com/files/1311.3715v3.pdf). 2014.

[^lu1]: Lu, et. al. [RAPID: Rating Pictorial Aesthetics using Deep Learning](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ACMMM2014/lu.pdf). 2014.

[^lu2]: Lu, et. al. [Deep Multi-Patch Aggregation Network for Image Style, Aesthetics, and Quality Estimation](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ICCV15/lu.pdf). 2015.