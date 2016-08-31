---
layout: post
title: Analyzing photos for "social interest"
---
<img src="/images/fulls/social-interest/facebook_tiles.jpg" class="fit image">

* TOC
{:toc}

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

The first interesting thing we might look at doesn't need the images themselves at all -- the distribution of likes.

### Distribution of likes

<img src="/images/fulls/social-interest/linear-distribution.png" class="chart image">

This looks somewhat exponential, but not perfectly so. In particular, the curve is very shallow at low numbers of likes (nearly equal frequency of 0 and 1 likes), and the tail is longer than might be expected -- possibly log-normal.

Looking at the ratio between subsequent histogram bins reveals that it is not flat, and that the distribution skews long -- more harmonic than geometric.

<img src="/images/fulls/social-interest/non-geometric.png" class="chart image">

This can be seen further by looking at the probability of randomly choosen image having n + 1 likes, given that it has at least n likes.

<img src="/images/fulls/social-interest/additional-likes.png" class="chart image">

For an example, though any image on Facebook has a 91.0% chance of receiving at least one vote, an image with 22 likes has a 95.7% chance of receiving at least one additional vote, and image with 44 likes has a 97.2% chance of making it to 45.

So what is the distribution? We thought it looked log-normal, so let's try looking at the distribution of log-likes (defined as log_10(likes + 1).)

<img src="/images/fulls/social-interest/log-like.png" class="chart image">

<img src="/images/fulls/social-interest/norm_fit.png" class="chart image">

While clearly not normal, as the attempt at fitting a Gaussian curve shows above, it is much closer to normally distributed. This means that intuition about probabilities will be approximately accurate. For example, the mean of a set of log-likes will generally be close to its median. This is very convenient! We can see this clearly by looking at the distrubtion over likes and log-likes as a box-plot. In this plot, the horizontal lines read from top to botton: 95th percentile value, 75th percentile value, median (50%), 25th percentile value, 5th percentile value. The star plots the location of the arithmetic mean.

<img src="/images/fulls/social-interest/boxplot.png" class="chart image">

There is also some theoretical reason to believe that log-likes might be a more relevant way of analyzing like data. Intuitively, the difference between 44 likes and 45 likes seems smaller than the difference between 1 like and 2 likes on an image.

Let's say each image has an inherent "social interest" value and the probability that any person likes an image is the product of the social interest value and the probability that they see the image. Since Facebook's news feed shows the most popular content, this probability is a function of the number of likes it has. The number of likes is now an arrival process where the next arrival (like) is accelerated by previous arrivals. I'm not sure if there is a standard distribution representing this kind of process, but it makes sense then that the "social interest" value would be non-linearly, perhaps exponentially, correlated with the total number of likes.

### Images over time

The other simple piece of metadata that can provide some initial observation is the timestamp associated with each image.

<img src="/images/fulls/social-interest/2008-2017.png" class="chart image">

Data was pulled from user timelines for 2013-2016, however many images are uploaded before 2013, as users can post older images to their timelines. However, as this data is relatively incomplete, it's not particularly useful for time-series analysis. Let's restrict the chart to 2013-2016.

<img src="/images/fulls/social-interest/2013-2017.png" class="chart image">

It would seem that the volume of images is roughly consistent, perhaps slightly decreasing over this time period. There is some seasonal variability as well, which we will return to in a later section.

However, the total number of likes awarded has been consistently increasing over this time period.

<img src="/images/fulls/social-interest/liking-2013-2017.png" class="chart image">

This could be an artifact of more widely shared content, especially political content, that may be accumulating thousands of likes and skewing the mean. However, the median number of likes per image has also been increasing, which should be somewhat resistance to widely shared outliers.

<img src="/images/fulls/social-interest/median-likes-2013-2017.png" class="chart image">

Why this is happening is anyone's guess -- Facebook has a lot of control here. Maybe they've been seeing better user engagement, perhaps a product of increased mobile usage. Maybe they've started promoting photos more heavily, keeping them on news feeds for longer. Maybe a combination of the two factors.

As expected for a period of time in which I was finishing undergrad, in grad school, and had many acquantances subject to the academic calendar, Facebook image activity picks up considerably during school breaks (June - August and December.) Alternatively, perhaps everyone simply has more images to post during these time periods. Analyzing the data of students separately from non-students could shed some more light on this.

<img src="/images/fulls/social-interest/school_breaks.png" class="chart image">

There's also strong variation within the week. Weekend are the most popular days to post photos, followed by Fridays and Mondays. As a majority of the sampled population was in the US-Eastern timezone, I've plotted two lines, one in the original UTC, and one with 5 hours subtracted to put it in US-Eastern.

<img src="/images/fulls/social-interest/weekdays.png" class="chart image">

Images posted just before the weekend get the most likes, unsurprisingly. At this point, Facebook's news feed algorithm is probably short on content and high on users.

<img src="/images/fulls/social-interest/median_weekdays.png" class="chart image">

5 a.m. US-Eastern seems to be the time of day with the fewest images uploaded, and 8 p.m. the maximum.

<img src="/images/fulls/social-interest/hourly_quantity.png" class="chart image">

And images uploaded first thing in the morning get the most likes (probably as a result fo more views.)

<img src="/images/fulls/social-interest/hourly_median.png" class="chart image">

#### Missing time data?

In looking over this time data, one strange thing stood out to me -- the number of images uploaded on January 1st. This can be seen very clearly in the first plot of 2008 - 2013.

If we look at the distribution over the minute in the hour in which an image was posted, we see something quite strange.

<img src="/images/fulls/social-interest/minutes.png" class="chart image">

The effect is even more pronounced looking at the second that an image was uploaded.

<img src="/images/fulls/social-interest/seconds.png" class="chart image">

It is clear that many images are missing precision in the timestamp. A difference in the client that was used to upload the image perhaps?

These small inaccuracies in the time stamp won't affect the social interest analysis that we're interested in much. While we will have to factor out the confounding variable of time, the impact that this variable has on our response (likes) is over a period of years, not hours.

### The "Instagram effect?"

One interesting result can be found with just the width and height metadata alone: square-cropped images receive measureably more likes on average:

<img src="/images/fulls/social-interest/aspect.png" class="chart image">

Like some of the graphs above, this is a box-plot with the means marked by stars. I have also plotted the 5/95% confidence intervals on the means (calculated by 1.96 x standard error) with gray 'X's.

I have a hypothesis for this aspect ratio dependence: the use of a square-crop indicates that the person who took the photo excercised more care than average in the process of choosing subject matter, framing a photography, and editing the image. Someone who square-crops images might be someone who takes an interest in "social interest."

## Looking at the images

Let's begin looking at the actual images in the dataset. A good place to start might be the most popular images. Below are the ten images with the most likes (after cropping to a square region in the center of the image and resizing to 256x256 pixels.)

<img src="/images/fulls/social-interest/top10-1/montage.jpg" class="fit image">

An immediate issue is visible -- the most popular images are widely shared political, pop-science, or humor content, not the snapshots that we want to be analyzing.

### Removing non-snapshots

These images, especially because they have so many likes, will influence our analysis in undesireable ways. Because many of them are one off political posts by users not present in the primary dataset, one approach to remove this content might be by restricting the dataset only to users with a certain number of images present in the dataset. (This will also make it easier to normalize the likes per image by individual users.)

Requiring 4 images decreases the dataset from 85,904 images to 68,509. Unfortunately, though this improves the image selection slightly, it doesn't make as big a difference as we would like. There are still only two photos that seem to be snapshots in the top 10.

<img src="/images/fulls/social-interest/top10-2/montage.jpg" class="fit image">

Next, let's try restricting it to Facebook users whose walls were crawled in the data scraping phase.

<img src="/images/fulls/social-interest/top10-3/montage.jpg" class="fit image">

This looks mostly like real images now! But, we have decreased the size of the image database to just 50,399 images, and have excluded many snapshot images posted by friends of users.

It really seems to be only the images with large numbers of likes that are problematic. For example, these images posted by users excluded from the above collection, who have more than one image in the dataset, all with 195-199 likes, seem mostly legitimate.

<img src="/images/fulls/social-interest/top10-4/montage.jpg" class="fit image">

We'll add all images with less than 200 likes back to the dataset. This may produce a small bias towards less liked images, but as only a very small percentage of images have this many likes in the first place, the bias is likely tolerable. This dataset has 76,425 images in it. All told, we have excluded 9,479 images -- those posted by non-friend users with only one image in the dataset and with over 200 likes.

Finally, we know that there is a time dependent trend in likes. Let's restrict images to only those uploaded in 2013 and after, so that we can reliably estimate and remove this time-dependent bias. This leaves us with a final dataset of 72,427 images.

### Normalizing likes by time

As shown above, the average number of likes has increased with time. This can also be seen by fitting a linear regression to the log-like value.

<img src="/images/fulls/social-interest/trended-scatter.png" class="chart image">

This linear regression also provides a possible solution -- simply subtract the mean value predicted by the regression from each log-like value. This results in a "de-trended" log-like dataset.

<img src="/images/fulls/social-interest/detrended-scatter.png" class="chart image">

The month-to-month mean log-like time series now shows small variations but no obvious trend.

<img src="/images/fulls/social-interest/corrected-mean-likes-2013-2017.png" class="chart image">

### Normalizing likes by user

Removing the user-dependent effect is a more difficult challenge. Different users have different exposure levels on Facebook and different social contexts. But we are not privy to this information -- the dataset we have is all that we can observe.

One possible normalization strategy is to remove the mean of each user. However, for users who genuinely do post more socially interesting content, this normalization will confound the dataset.

Another possibility is to do nothing, and accept the uncontrolled effect of each user.

A third possibility is to create a set of dummy variables, corresponding to each user, and use these dummy variables as part of the training process. Then, during testing, these dummy variables (which ought to account for the "per user" part of the dependence) are discarded. [TODO: investigate this] As this becomes more difficult when considering non-additive prediction methods, we will for now focus on the first two.

## Face detection

The first aspect of the image that I looked at to predict social interest was faces. People like people, and it would be entirely unsurprising if images with people in them tended to garner more likes than images without.

To detect faces, we can use a Haar cascade, a standard multi-scale object recognition algorithm that makes use of Haar wavelets, like the [near-duplicate detection](http://exclav.es/2016/07/04/near-duplicate-detection-wavelets/) explored previously. Haar cascades are implemented in OpenCV through the ``CascadeClassifier`` class.

After performing this analysis on every image in the dataset, a box-plot can be made of log-likes versus the number of faces visible in each image. A small but significant correlation is observed.

<img src="/images/fulls/social-interest/faces/num_faces.png" class="chart image">

If we look at the time-normalized data instead, this correlation is slightly expanded by about 3%. While this is a very small difference (and very difficult to observe directly in the graph) it is an indication that the time-normalization process reduced the "noise" in the original dataset slightly.

<img src="/images/fulls/social-interest/faces/num_faces_normalized.png" class="chart image">

There is also a response visible to the total size of all faces in the image, which is expected to correlate slightly with the number of faces in the image.

<img src="/images/fulls/social-interest/faces/face_size_normalized.png" class="chart image">

And, there is a response visible to the size of the largest face visible in the image, which might have a somewhat weaker correlation with the number of faces visible in the image.

<img src="/images/fulls/social-interest/faces/largest_face_size_normalized.png" class="chart image">

As before, the box-plot shows the 5/25/50/75/95 percentile ranges of the distribution. Means are marked with a blue star, and the 5/95% confidence intervals on the means are marked with gray Xs. The effect of faces in the image has a significant impact on the mean, though it does not explain the majority of the variance.

## Image understanding

To be done.

## Retraining a convolutional neural network

To be done.

## Results

To be done.

## Conclusions

To be done.

## Citations

[^flickr]: Quora. [How does Flickr's interestingness work?](https://www.quora.com/How-does-Flickrs-interestingness-work) 2011.

[^karayev]: Karayev, et. al. [Recognizing image style](https://sergeykarayev.com/files/1311.3715v3.pdf). 2014.

[^lu1]: Lu, et. al. [RAPID: Rating Pictorial Aesthetics using Deep Learning](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ACMMM2014/lu.pdf). 2014.

[^lu2]: Lu, et. al. [Deep Multi-Patch Aggregation Network for Image Style, Aesthetics, and Quality Estimation](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ICCV15/lu.pdf). 2015.

[^graphapi]: [Facebook Graph API](https://developers.facebook.com/docs/graph-api)