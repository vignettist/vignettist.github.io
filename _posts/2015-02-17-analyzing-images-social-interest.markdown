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

One possible normalization strategy is to remove the mean of each user. However, for users who genuinely do post more socially interesting content, this normalization will confound the dataset. Another possibility is to do nothing, and accept the uncontrolled effect of each user.

Both possibilities are bad, so we will instead attempt a "compromise" strategy, of trying to jointly estimate the per-user like factor (which we will assume to be additive in log-likes, or multiplicative in likes) simultaneously with the image-dependent parameters of social interest.

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

The use of image understanding algorithms can give insight into the content of these social images (or at least what a classification algorithm trained on [ImageNet](http://image-net.org/) believes the images to contain.) Using [TensorFlow](http://tensorflow.org/) and Google's "Inception" convolutional neural network (CNN) architecture, [^inception] the dataset of images was analyzed for semantic content. The most common categories in the dataset were found to be the following:

<img src="/images/fulls/social-interest/categories/category_counts.png" class="chart image">

These categories do not correspond *exactly* to what the images truly contain, but they do seem to form useful clusters. Below, ten randomly selected images from each category our displayed, along with a subjective evaluation of what images from that category actually contain.

<dl>
<dt>web site, website, internet site, site</dt>
<dd><img src="/images/fulls/social-interest/categories/0.jpg" class="fit image">
Seems to be mostly screenshots and memes.
</dd>

<dt>restaurant, eating house, eating place, eatery</dt>
<dd><img src="/images/fulls/social-interest/categories/1.jpg" class="fit image">
Groups of people, social situations.
</dd>

<dt>wig</dt>
<dd><img src="/images/fulls/social-interest/categories/2.jpg" class="fit image">
Selfies, profile-photo-like images.
</dd>

<dt>stage</dt>
<dd><img src="/images/fulls/social-interest/categories/3.jpg" class="fit image">
Stages and group photos.
</dd>

<dt>sunglasses, dark glasses, shades</dt>
<dd><img src="/images/fulls/social-interest/categories/4.jpg" class="fit image">
Selfies and couples (mostly with sunglasses, of course.)
</dd>

<dt>comic book</dt>
<dd><img src="/images/fulls/social-interest/categories/5.jpg" class="fit image">
Drawings and memes.
</dd>

<dt>book jacket, dust cover, dust jacket, dust wrapper</dt>
<dd><img src="/images/fulls/social-interest/categories/6.jpg" class="fit image">
Drawings and memes.
</dd>

<dt>lakeside, lakeshore</dt>
<dd><img src="/images/fulls/social-interest/categories/7.jpg" class="fit image">
Outdoors and landscapes.
</dd>

<dt>pajama, pyjama, pj's, jammies</dt>
<dd><img src="/images/fulls/social-interest/categories/8.jpg" class="fit image">
Family photos.
</dd>

<dt>suit, suit of clothes</dt>
<dd><img src="/images/fulls/social-interest/categories/9.jpg" class="fit image">
Selfies and group photos.
</dd>

<dt>jersey, T-shirt, tee shirt</dt>
<dd><img src="/images/fulls/social-interest/categories/10.jpg" class="fit image">
Selfies and small group photos.
</dd>

<dt>seat belt, seatbelt</dt>
<dd><img src="/images/fulls/social-interest/categories/11.jpg" class="fit image">
Car selfies? (I guess this is a genre of social images.)
</dd>

<dt>seashore, coast, seacoast, sea-coast</dt>
<dd><img src="/images/fulls/social-interest/categories/12.jpg" class="fit image">
Outdoors and landscapes.
</dd>

<dt>envelope</dt>
<dd><img src="/images/fulls/social-interest/categories/13.jpg" class="fit image">
More memes.
</dd>

<dt>alp</dt>
<dd><img src="/images/fulls/social-interest/categories/14.jpg" class="fit image">
Ourdoors and landscapes.
</dd>

<dt>bow tie, bow-tie, bowtie</dt>
<dd><img src="/images/fulls/social-interest/categories/15.jpg" class="fit image">
Formal event portraits.
</dd>

<dt>cliff, drop, drop-off</dt>
<dd><img src="/images/fulls/social-interest/categories/16.jpg" class="fit image">
Outdoors, rock climbing.
</dd>

<dt>mortarboard</dt>
<dd><img src="/images/fulls/social-interest/categories/17.jpg" class="fit image">
Graduation photos. (Possible dataset bias, here!)
</dd>

<dt>plate</dt>
<dd><img src="/images/fulls/social-interest/categories/18.jpg" class="fit image">
Food photos.
</dd>

<dt>valley, vale</dt>
<dd><img src="/images/fulls/social-interest/categories/19.jpg" class="fit image">
Outdoors and landscapes.
</dd>
</dl>

### Correlation with likes

<img src="/images/fulls/social-interest/categories/category_distribution.png" class="chart image">

Selfie, small group, family, and graduation photos seem to garner the most Facebook attention, while landscapes and outdoor photos receive the least. Most other categories are in a fairly narrow band in the middle, without statistically significant deviation from the mean.

On first glance, this doesn't seem incredibly promising for the prospect of using semantic image data for predicting Facebook popularity. But we can try anyway.

## Transfer learning

Transfer learning is a technique where the interim result from a pretrained machine learning algorithm is used to train for a new type of output. For example, the Inception network may be [retrained to classify new varieties of objects](https://www.tensorflow.org/versions/r0.9/how_tos/image_retraining/index.html). This can be especially useful when the training dataset is small, which is approximately true in this case, with only 72,000 images. It can also be much faster than retraining an entire network. In this case, the final pooling layer of the Inception network, a layer of size 2048x1, is computed for each image.

### Transfer learning with other ML algorithms

We can use these 2048 values, along with summary statistics from the face detection exploration, as features of our data directly with many common machine learning algorithms. The two that I will explore here are support vector machines and boosted decision trees.

### Transfer learning with an SVM

The first approach we can throw at this prediction problem is a support vector machine, a well understood machine learning technique that has many nice properties. How can we evaluate correctness of our prediction? The mathematically-nicest way to do this is to use the mean-square-error (or root-mean-square-error) as an error signal, and attempt to minimize that. However, this is not perfectly equivalent to what we want to do, as we are more interested in relative differences between images on a per-user basis.

#### A better error estimate

Instead, we can estimate the effectiveness of our predictor by calculating the percentage of comparisons between images in the same user that it predicts correctly. If a user has 50 images, there are 50*49/2 = 1225 possible comparisons between images. We can expect to get 50% of the wrong if we are randomly guessing. If we got 100% of them correct, then we could establish the correct rank order of images.

After performing a grid search establish the best SVM parameters, the best we can do is predict comparisons with 55.9% accuracy. (Trained with 1/10 the data in order to speed comparisons of methods.) This isn't great, but it's better than random chance!

Scatter plotting the predicted likes against the validation likes shows a weak correlation. (I hope.)

[Graph of this]

#### Using user data

Perhaps the result can be improved if data about the user responsible for each image was included in the training step. Then, predictions involving image features alone, and not information about the user, could be considered to be true predictions of social interest based on image content. Of course, it won't work out this cleanly due to the rbf kernel involving many combinations of predictors, some of which will be both image predictor features and user features.

During testing, the test images have the user information zeroed out -- just the image features alone are provided to the SVM.

After performing a second grid search, the best we can do is 56.4% -- a modest but significant improvement over training without use of user info. However, this is still trained with 1/10 of the data. Training with the complete dataset improves this result slightly to 56.5%, though it significantly increases the computational time.

[Graph of this]

Note that when the validation data is scatter plotted, the correlation between predicted and actual likes is non-existent. The r^2 value is just 0.017. This is expected as each "user cluster" of images is shifted more-or-less randomly, though they should be internally consistent.

[10x10 graphs]

### Transfer learning with boosted trees

#### Simultaneous estimation of user-dependent effect

### Transfer learning with a neural network

Above this, we construct a new network, consisting of a fully connected layer that reduces the size to 1000x1, a drop-out layer, a fully connected layer that reduces the size to 500x1, a second drop-out layer, and a final linear layer that reduces the size to a single variable. Unlike a classification problem, where we are attempting to match a probability distribution over categories, we are now trying to predict the output of a quantitative variable. So, rather than attempting to minimize the [cross-entropy](http://colah.github.io/posts/2015-09-Visual-Information/) of two distributions, we will try to minimize the mean squared error of the predicted log-like value.

As this network is trained, the MSE quickly drops to near a minimum. In this graph, captured from TensorBoard during the training process, the orange line is the test error, and the blue line is the training error, which has high variance due to the smaller batch size and the dropout layers.

<img src="/images/fulls/social-interest/training/mse.png" class="fit image" />

After 20,000 steps, the training was terminated, and performance was tested on a hold-out validation set of images.

## Results on a non-Facebook dataset

Another way of evaluating the performance of these methods is by subjectively evaluating the performance on an unscored, non-Facebook dataset. In this case, I am using a donated set of photos from a friend of mine. We can look at the evaluated rankings of the photos taken on a particular date.

### SVM

[Photos from Bilal dataset SVM]

### Boosted decision trees

[Photos from Bilal dataset boosted]

### Neural network retraining

[Photos from Bilal dataset NN]

## Next steps

There are several apparent avenues for future investigation.

### How well can humans even do this?

In the introduction, I discussed how I thought that this would be a difficult, underdefined task. After all, even humans have difficulty evaluating "social interest." But how well would humans perform on this same task? (Choosing the more interesting of a pair of images.) I'm not completely sure -- it would certainly be an interesting Mechanical Turk experiment to set up.

### Different predictive features

Maybe image semantic analysis features really aren't the most predictive. What about the hidden layers of a network trained on AVA[^ava], or a face-detection network? (Schaar cascades were used for the face data above.)

### Training a neural network

One direction that I did not investigate is the complete training of a neural network from scratch. This was for two reasons -- a lack of computing hardware, and a lack of data. However, I have since obtained a modern GPU and downloaded some 300,000 additional Facebook images, perhaps making this problem more tractable.

## Conclusions

Expectations for success were intially minimal, and those expectations have been mostly met. Weak correlations have been found with expected image properties, including the 

## Citations

[^flickr]: Quora. [How does Flickr's interestingness work?](https://www.quora.com/How-does-Flickrs-interestingness-work) 2011.

[^karayev]: Karayev, et. al. [Recognizing image style](https://sergeykarayev.com/files/1311.3715v3.pdf). 2014.

[^lu1]: Lu, et. al. [RAPID: Rating Pictorial Aesthetics using Deep Learning](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ACMMM2014/lu.pdf). 2014.

[^lu2]: Lu, et. al. [Deep Multi-Patch Aggregation Network for Image Style, Aesthetics, and Quality Estimation](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ICCV15/lu.pdf). 2015.

[^graphapi]: [Facebook Graph API](https://developers.facebook.com/docs/graph-api)

[^inception]: Szegedy, et. al. [Going Deeper with Convolutions](https://arxiv.org/abs/1409.4842). 2014.

[^ava]: Naila Murray, Luca Marchesotti, Florent Perronnin. AVA: A Large-Scale Database for Aesthetic Visual Analysis. CVPR 2012.