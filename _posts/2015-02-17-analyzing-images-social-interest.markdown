---
layout: post
title: Analyzing photos for "social interest"
---
<img src="/images/fulls/03.jpg" class="fit image">

What makes a photo interesting?
=======

This is a very difficult question to answer, as image processing algorithms don't do well with subjectivity. Flickr has their interestingness algorithm, but it is based primarily on initial user interactions with the image: views, favorites, and comments. [^flickr] How could we tell that an image might be interesting *before* anyone has seen it?

Recent research pushes in convolutional neural networks have produced promising results, showing the feasibility of analyzing images for subjective style [^karayev], aesthetic quality [^lu1], or both. [^lu2]. However, aesthetic quality as measured by Flickr or DPChallenge users is not exactly what [Vignette](http://vignette.cool) is interested in. We want to know what images will have "*social interest*."

Curabitur orci turpis, egestas placerat velit eget, dictum pellentesque ipsum. Suspendisse potenti. Suspendisse ac maximus arcu. Sed ut mattis ex. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum eleifend odio vitae varius aliquam. Quisque ac pretium nisi. Curabitur tempus urna ac ultrices commodo.

Curabitur iaculis est at mattis mattis. Aliquam erat volutpat. Etiam vitae cursus quam. Nunc ultricies nunc non lorem fringilla cursus. Etiam dapibus libero ac turpis accumsan pulvinar. Sed auctor velit eget mi consequat bibendum. Aliquam interdum purus eget metus pretium ullamcorper.

Pellentesque feugiat ex non ligula commodo, eget varius tortor pellentesque. Pellentesque id tortor felis. Cras fringilla ante eget orci laoreet, non consequat urna suscipit. Pellentesque luctus ac nulla vitae porttitor. Proin sed tortor quis magna efficitur efficitur a id leo. Donec efficitur augue et laoreet maximus. Ut semper egestas porttitor. Phasellus sagittis vulputate sem at laoreet.

Sed lobortis urna ut mi volutpat, sit amet euismod sapien tincidunt. Nulla facilisi. Pellentesque quis tempus neque. Mauris dictum ac sapien nec congue. In hac habitasse platea dictumst. Duis id pellentesque nisl. Morbi eget massa magna.

[^flickr]: Quora. [How does Flickr's interestingness work?](https://www.quora.com/How-does-Flickrs-interestingness-work) 2011.

[^karayev]: Karayev, et. al. [Recognizing image style](https://sergeykarayev.com/files/1311.3715v3.pdf). 2014.

^[lu1]: Lu, et. al. [RAPID: Rating Pictorial Aesthetics using Deep Learning](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ACMMM2014/lu.pdf). 2014.

^[lu2]: Lu, et. al. [Deep Multi-Patch Aggregation Network for Image Style, Aesthetics, and Quality Estimation](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ICCV15/lu.pdf). 2015.