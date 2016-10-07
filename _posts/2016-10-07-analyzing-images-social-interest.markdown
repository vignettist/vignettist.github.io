---
layout: post
title: Analyzing photos for "social interest"
---
<img src="/images/fulls/social-interest/facebook_tiles.jpg" class="fit image">

* TOC
{:toc}

## What makes a photo interesting?

Interesting photos can remind us of a person or a place or a time, connect us to events distant from where we are now, inform us about the world, and make us want to learn more. What is it that makes a photo interesting? Can we, through analysis of an image alone, determine whether it will be interesting?

Other approaches, such as Facebook's news feed and Flickr's interestingness algorithm, measure interest from user interactions with the image: views, favorites, and comments. [^flickr] How could we tell that an image might be interesting *before* anyone has seen it?

Recent research pushes in convolutional neural networks have produced promising results, showing the feasibility of analyzing images for subjective style, [^karayev] aesthetic quality, [^lu1] or both. [^lu2] However, aesthetic quality as measured by Flickr or DPChallenge users is not exactly what [Vignette](http://vignette.cool) is interested in. We want to know what images will have "*social interest*."

Computers do not do well with subjectivity, and it is difficult to image a more subjective, challenging problem than this. Different people can find the same image either interesting or uninteresting, depending on whether they know the people photographed or have familiarity with the location. Some people like portraits, some people like landscapes. Some people care if an image is blurry, some people are just happy to see a photo of their niece. This definition of "social interest" will change not only from person to person but also in the same person over time. It is an intensely subjective, vague, personal, and unstable question to try to answer, and computers almost certainly will not succeed.

But perhaps, there exist some commonalities of interest, some characteristics within an image that can provide a hint that a photo will be interesting, a suggestion rather than a declaration.

## Building a dataset

To approach this question as a machine learning problem, we first need a dataset that we can analyze. Perhaps the largest dataset of "social" images today exists on Facebook. Furthermore, these images are associated with a quantitative response variable, the number of "likes," that we expect to be imperfectly correlated with the "social interest" we are interested in measuring.

However, Facebook does not make this data easy to access. Though you, as a user, may see your friends photos, as a consumer of the Graph API, you may not. [^graphapi]

The alternative to using Facebook's API is the time-consuming process of scraping pages. The most straightforward way to accomplish this is through the use of a headless browser, essentially a standard web browser that doesn't render to the screen. Then, we can extract the DOM elements that carry the information we need.

With this method, I have created a small database of approximately 85,000 images from Facebook.

*It is important to note that this is an incredibly biased dataset -- as I can only build a dataset of my friends, it only contains my friends (and the images that they post.) This means it is very strongly biased towards San Francisco, MIT, and Oregon, and that it is whiter and more educated than the general population. Attempts to generalize from any results here must be done with extreme caution. However, looking at the differences in what different demographics find "socially interesting" could be fascinating research in and of itself.*

### Scraping Facebook

[The scraper](https://github.com/vignettist/social-interest/blob/master/image_scraper.py) was written in Python, with Selenium and PhantomJS. There's nothing particularly elegant about it -- it loads up pages exactly like a standard Facebook user would in our their browser (though it loads the mobile version for speed's sake), it scrolls to the bottom of the page, and then it looks for specific DOM elements.

It begins by creating a list of users, then searching their walls for photos to create a list of Faceboook photo IDs. Then, it creates a database with the location of each photo and the number of likes it has received, as well as some other metadata including the date it was posted and who posted it. Finally, the original image is downloaded from Facebook and copies of several sizes are created.

## Initial observations

Before we begin to analyze the images themselves, we can look at what is revealed through the metadata alone -- timestamps, likes, and sizes.

### Distribution of likes

<img src="/images/fulls/social-interest/linear-distribution.png" class="chart image">

This looks somewhat exponential, but not perfectly so. In particular, the curve is very shallow at low numbers of likes (nearly equal frequency of 0 and 1 likes), and the tail is longer than might be expected -- possibly log-normal.

Looking at the ratio between subsequent histogram bins reveals that it is not flat, and that the distribution skews long -- more harmonic than geometric.

<img src="/images/fulls/social-interest/non-geometric.png" class="chart image">

This can be seen further by looking at the probability of randomly chosen image having $$n + 1$$ likes, given that it has at least $$n$$ likes.

<img src="/images/fulls/social-interest/additional-likes.png" class="chart image">

For an example, though any image on a Facebook wall has a 91.0% chance of receiving at least one vote, an image with 22 likes has a 95.7% chance of receiving at least one additional vote, and image with 44 likes has a 97.2% chance of making it to 45.

So what is the distribution? We thought it looked log-normal, so let's try looking at the distribution of log-likes (defined as $$\log_{10}(\mathrm{likes} + 1)$$.)

<img src="/images/fulls/social-interest/log-like.png" class="chart image">

<img src="/images/fulls/social-interest/norm_fit.png" class="chart image">

While clearly not normal, as the attempt at fitting a Gaussian curve shows above, it is much closer to normally distributed. This means that intuition about probabilities will be approximately accurate. For example, the mean of a set of log-likes will generally be close to its median. This is very convenient! We can see this clearly by looking at the distribution over likes and log-likes as a box-plot. In this plot, the horizontal lines read from top to bottom: 95th percentile value, 75th percentile value, median (50%), 25th percentile value, 5th percentile value. The star plots the location of the arithmetic mean.

<img src="/images/fulls/social-interest/boxplot.png" class="chart image">

There is also some theoretical reason to believe that log-likes might be a more relevant way of analyzing like data. Intuitively, the difference between 44 likes and 45 likes seems smaller than the difference between 1 like and 2 likes on an image.

Let's say each image has an inherent "social interest" value and the probability that any person likes an image is the product of the social interest value and the probability that they see the image. Since Facebook's news feed shows the most popular content, this probability is a function of the number of likes it has. The number of likes is now an arrival process where the next arrival (like) is accelerated by previous arrivals. I'm not sure if there is a standard distribution representing this kind of process, but it makes sense then that the "social interest" value would be non-linearly distributed but positively correlated with the total number of likes.

### Images over time

The other simple piece of metadata that can provide some initial insight is the timestamp associated with each image.

<img src="/images/fulls/social-interest/2008-2017.png" class="chart image">

Data was pulled from user walls for the years 2013 - 2016, however many images are uploaded before 2013, as users can post older images to their walls. However, as this data is relatively incomplete, it's not particularly useful for time-series analysis. Let's restrict the chart to 2013 - 2016.

<img src="/images/fulls/social-interest/2013-2017.png" class="chart image">

It would seem that the volume of images is roughly consistent, perhaps slightly decreasing over this time period. There is some seasonal variability as well, which we will return to in a later section.

However, the total number of likes awarded has been consistently increasing over this time period.

<img src="/images/fulls/social-interest/liking-2013-2017.png" class="chart image">

This could be an artifact of more widely shared content, especially political content, that may be accumulating thousands of likes and skewing the mean. However, the median number of likes per image has also been increasing, which should be somewhat resistance to widely shared outliers.

<img src="/images/fulls/social-interest/median-likes-2013-2017.png" class="chart image">

Why this is happening is anyone's guess -- Facebook has a lot of control here. Maybe they've been seeing better user engagement, perhaps a product of increased mobile usage. Maybe they've started promoting photos more heavily, keeping them on news feeds for longer. Maybe users just have more friends linked on Facebook now. Most likely, some combination of all these factors.

As expected for a period of time in which I was finishing undergrad, then in grad school, and had many acquaintances subject to the academic calendar, Facebook image activity picks up considerably during school breaks (June - August and December.) Alternatively, perhaps everyone simply has more images to post during these vacation-heavy time periods. Analyzing the data of students separately from non-students could shed some more light on this.

<img src="/images/fulls/social-interest/school_breaks.png" class="chart image">

There's also strong variation within the week. Weekend are the most popular days to post photos, followed by Fridays and Mondays. As a majority of the sampled population was in the US-Eastern timezone, I've plotted two lines, one in the original UTC, and one with 5 hours subtracted to put it in US-Eastern.

<img src="/images/fulls/social-interest/weekdays.png" class="chart image">

Images posted just before the weekend get the most likes, unsurprisingly. At this point, Facebook's news feed algorithm is probably short on content and high on users.

<img src="/images/fulls/social-interest/median_weekdays.png" class="chart image">

5 a.m. US-Eastern seems to be the time of day with the fewest images uploaded, and 8 p.m. the maximum.

<img src="/images/fulls/social-interest/hourly_quantity.png" class="chart image">

And images uploaded first thing in the morning get the most likes (likely a result of more views.)

<img src="/images/fulls/social-interest/hourly_median.png" class="chart image">

#### Missing time data?

In looking over this time data, one strange thing stands out -- the number of images uploaded on January 1st. This can be seen very clearly in the first plot of 2008 - 2013.

If we look at the distribution over the minute in the hour in which an image was posted, we see something quite strange.

<img src="/images/fulls/social-interest/minutes.png" class="chart image">

The effect is even more pronounced looking at the second that an image was uploaded.

<img src="/images/fulls/social-interest/seconds.png" class="chart image">

It is clear that many images are missing precision in the timestamp. Perhaps a difference in the client that was used to upload the image?

These small inaccuracies in the time stamp won't affect the social interest analysis that we're interested in much. While we will have to factor out the confounding variable of time, the impact that this variable has on our like response is over a period of years, not hours.

### The "Instagram effect?"

One interesting result can be found with just the width and height metadata alone: square-cropped images receive measurably more likes on average:

<img src="/images/fulls/social-interest/aspect.png" class="chart image">

Like many of the graphs above, this is a box-plot with the means marked by stars. I have also plotted the 5/95% confidence intervals on the means (calculated by $$1.96\times$$ standard error) with gray 'X's.

I have a hypothesis for this aspect ratio dependence: the use of a square-crop indicates that the person who took the photo exercised more care than average in the process of choosing subject matter, framing a photography, and editing the image. Someone who square-crops images might be someone who takes an interest in "social interest."

## Looking at the images

Let's begin looking at the actual images in the dataset. A good place to start might be the most popular images. Below are the ten images with the most likes (after cropping to a square region in the center of the image and resizing to 256x256 pixels.) Faces have been blurred in these images, but the content is still recognizable.

<img src="/images/fulls/social-interest/top10-1/montage.jpg" class="fit image">

An immediate issue is visible -- the most popular images are widely shared political, pop-science, or humor content, not the snapshots that we want to be analyzing.

### Removing non-snapshots

These images, especially because they have so many likes, will influence our analysis in undesirable ways. Because many of them are one off political posts by users not present in the primary dataset, one approach to remove this content might be by restricting the dataset only to users with a certain number of images present in the dataset. (This will also make it easier to normalize the likes per image by individual users.)

Requiring 4 images decreases the dataset from 85,904 images to 68,509. Unfortunately, though this improves the image selection slightly, it doesn't make as big a difference as we would like. There are still only two photos that seem to be snapshots in the top 10.

<img src="/images/fulls/social-interest/top10-2/montage.jpg" class="fit image">

Next, let's try restricting it to Facebook users whose walls were crawled in the data scraping phase.

<img src="/images/fulls/social-interest/top10-3/montage.jpg" class="fit image">

This looks mostly like real images now! But, we have decreased the size of the image database to just 50,399 images, and have excluded many snapshot images posted by friends of users.

It really seems to be only the images with large numbers (>200) of likes that are problematic. For example, these images posted by users excluded from the above collection, who have more than one image in the dataset, all with 195-199 likes, seem mostly legitimate.

<img src="/images/fulls/social-interest/top10-4/montage.jpg" class="fit image">

We'll add all images with less than 200 likes back to the dataset. This may produce a small bias towards less liked images, but as only a very small percentage of images have this many likes in the first place, the bias is likely tolerable. This dataset has 76,425 images in it. All told, we have excluded 9,479 images -- those posted by non-friend users with only one image in the dataset and with over 200 likes.

Finally, we know that there is a time dependent trend in likes. Let's restrict images to only those uploaded in 2013 and after, so that we can reliably estimate and remove this time-dependent bias. This leaves us with a final dataset of 72,427 images.

### Normalizing likes by time

As shown above, the average number of likes has increased with time. This can also be seen by fitting a linear equation to the log-like value.

<img src="/images/fulls/social-interest/trended-scatter.png" class="chart image">

This linear regression also provides a possible solution -- simply subtract the mean value predicted by the regression from each log-like value. This results in a "de-trended" log-like dataset.

<img src="/images/fulls/social-interest/detrended-scatter.png" class="chart image">

The month-to-month mean log-like time series now shows small variations but no obvious trend.

<img src="/images/fulls/social-interest/corrected-mean-likes-2013-2017.png" class="chart image">

### Normalizing likes by user

Removing the user-dependent effect is a more difficult challenge. Different users have different exposure levels on Facebook and different social contexts. But we are not privy to this information -- the dataset we have is all that we can observe.

One possible normalization strategy is to remove the mean of each user. However, for users who genuinely do post more socially interesting content, this normalization will confound the dataset. Another possibility is to do nothing, and accept the uncontrolled effect of each user.

Both possibilities are bad, so we will instead create a "compromise" strategy, of trying to jointly estimate the per-user like factor (which we will assume to be additive in log-likes, or multiplicative in likes) simultaneously with the image-dependent parameters of social interest. This will be returned to later in this blog post.

## Face detection

The first aspect of the image that we will examine in depth as a possible social interest predictor is faces. People like people, and it would be entirely unsurprising if images with people in them tended to garner more likes than images without.

To detect faces, we will use a Haar cascade, a standard multi-scale object recognition algorithm that makes use of Haar wavelets,[^viola] like the [near-duplicate detection](http://exclav.es/2016/07/04/near-duplicate-detection-wavelets/) explored previously. Haar cascades are implemented in OpenCV through the ``CascadeClassifier`` class.

After performing this analysis on every image in the dataset, a box-plot of log-likes versus the number of faces visible in each image reveals a small but significant correlation is observed.

<img src="/images/fulls/social-interest/faces/num_faces.png" class="chart image">

If we look at the time-normalized log-like data instead, the difference in log-likes between each category is expanded by approximately 3%. While this is a very small difference (and very difficult to observe directly in the plot) it is a positive indication that the time-normalization process has slightly reduced the noise present in the original dataset.

<img src="/images/fulls/social-interest/faces/num_faces_normalized.png" class="chart image">

There is also a response visible to the total size of all faces in the image, which is expected to correlate slightly with the number of faces in the image.

<img src="/images/fulls/social-interest/faces/face_size_normalized.png" class="chart image">

And, there is a response visible to the size of the largest face visible in the image, which might have a somewhat weaker correlation with the number of faces visible in the image. (Selfies, for example, might have a large "largest face.")

<img src="/images/fulls/social-interest/faces/largest_face_size_normalized.png" class="chart image">

As before, the box-plot shows the 5/25/50/75/95 percentile ranges of the distribution. Means are marked with a blue star, and the 5/95% confidence intervals on the means are marked with gray Xs. This shows that the effect of faces in the image has a significant impact on the mean, though it does not explain the majority of the variance (distributions are much broader than the difference between images with no faces and faces present.)

## Image understanding

The use of image understanding algorithms can give insight into the content of these social images (or at least what a classification algorithm trained on [ImageNet](http://image-net.org/) believes the images to contain.) Using [TensorFlow](http://tensorflow.org/) and Google's "Inception" deep convolutional neural network architecture, [^inception] the dataset of images was analyzed for semantic content. The most common categories in the dataset were found to be the following:

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
Outdoors and landscapes.
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

These categories also suggests an alternative method of [filtering out unwanted non-photographic content](#removing-non-snapshots).

### Correlation with likes

<img src="/images/fulls/social-interest/categories/category_distribution.png" class="chart image">

Selfie, small group, family, and graduation photos seem to garner the most Facebook attention, while landscapes and outdoor photos receive the least. Most other categories are in a fairly narrow band in the middle, without statistically significant deviation from the mean.

On first glance, these relatively weak correlations don't seem incredibly promising for the prospect of using semantic image data and face detection for predicting social interest. But we can try anyway.

## Transfer learning

Transfer learning is a technique where a partially trained machine learning model is retrained on a new dataset, or when the intermediate, hidden result from a model is used to create features for a new model. For example, the Inception network may be [retrained to classify new varieties of objects](https://www.tensorflow.org/versions/r0.9/how_tos/image_retraining/index.html). This can be especially useful when the training dataset is small, which is approximately true in this case, with only 72,000 images. It can also be much faster than training an entire network from scratch. In this case, the final pooling layer of the Inception network, a layer of size 2048x1, is computed for each image.

### Transfer learning with a neural network

The most obvious method of applying transfer learning from the Inception classification network to this problem is with the further use of neural networks. To use a neural network for this problem we construct a new network after the inception-net pooling layer that consists of a fully connected layer, a drop-out layer, a second fully connected layer, and a linear projection to a single social interest variable. This network is somewhat different from most neural network topologies, as unlike in a classification problem, where the network attempts to match a probability distribution over categories, we are now trying to predict the output of a single quantitative variable. So, rather than attempting to minimize the [cross-entropy](http://colah.github.io/posts/2015-09-Visual-Information/) of two distributions, we will try to minimize the mean squared error of the predicted log-like value.

As this network is trained, the MSE quickly drops to near a minimum. In this graph, captured from [TensorBoard](https://www.tensorflow.org/versions/r0.11/how_tos/summaries_and_tensorboard/index.html) during the training process, the orange line is the test error, and the blue line is the training error, which has high variance due to the smaller batch size and the dropout layers.

<img src="/images/fulls/social-interest/ml/nn_mse.png" class="chart image" />

An interesting evolution can also be observed here: the standard deviation of the output first falls to close to zero, as the neural network learns to approximate the mean of the training set, before slowly rising and it learns structure from the image features.

<img src="/images/fulls/social-interest/ml/nn_std.png" class="chart image" />

The training was terminated early after about 14,000 steps as the validation error began to rise.

<img src="/images/fulls/social-interest/ml/nn_performance.png" class="chart image" />

<img src="/images/fulls/social-interest/ml/nn_user_performance.png" class="chart image" />

The trained model, tested on the validation set, had a root-mean-square error of 0.462. Is this good? It turns out that this is only tangentially related to what we actually want to measure -- relative differences between images on a per-user basis.  

#### A better error estimate

Instead of RMSE, we can instead estimate the effectiveness of our model by calculating the percentage of comparisons between images taken by the same user that it ranks correctly. If a user has 50 images, there are 50*49/2 = 1225 possible comparisons between images. We can expect to get 50% of the wrong if we are randomly guessing. If we got 100% of them correct, then we could establish the correct rank order of images.

With this metric, the neural network model achieves a performance of 55.9%. This isn’t great, but it’s (slightly) better than random chance!

While the neural network approach was not ultimately the most successful algorithm for predicting social interest in this experiment, it has the most promise for future development. By retraining the entirety of a classification network, and incorporating other networks, such as those trained for visual aesthetics[^lu1] or even pornography[^yahoo], the performance of the neural network model could exceed the performance of boosted trees significantly. Even with these same features, due to the vast number of hyperparameters to adjust, the neural network performance could certainly be improved. However, this task will have to wait for additional time availability and access to more sophisticated computation hardware.

### Transfer learning with other ML algorithms

We can use the 2048 values of the Inception network final pooling layer, along with summary statistics from the face detection exploration, as dataset features directly with many common machine learning algorithms. The two that we will explore further here are support vector machines and boosted decision trees.

#### Support vector machines

The first approach we can throw at this prediction problem is a support vector machine, a fairly well understood and extremely flexible machine learning algorithm. What will our loss-function be for evaluating the correctness of our prediction? The mathematically-nicest way to do this is to use the mean-square-error (or root-mean-square-error) as an error signal, and attempt to minimize that, as was used for the neural network. However, for validating performance, we will continue to use the comparison-correctness metric described above.

After performing a grid search establish the best SVM parameters, the best we can do is predict comparisons with 55.9% accuracy. (Trained with 1/10 the data in order to speed comparisons of methods by 100-1000x.) This is basically the same accuracy as the neural network achieved.

##### Using user data

Perhaps the result can be improved if data about the user responsible for each image was included in the training step. Then, predictions involving image features alone, and not information about the user, could be considered to be true predictions of social interest based on image content. During performance testing, the validation set images have the user information zeroed out -- the image features alone are provided to the SVM.

After performing a second grid search, the best performance achieved is 56.4% accuracy -- a modest but significant improvement over training without use of user info. However, this is still trained with 1/10 of the data. Training with the complete dataset improves this result slightly to 56.5%, though it significantly increases the computational time.

<img src="/images/fulls/social-interest/ml/svm_performance.png" class="chart image">

Note that when the validation data is scatter plotted, the correlation between predicted and actual likes is non-existent. The $$r^2$$ value is just 0.017. This is expected as each "user cluster" of images is shifted more-or-less randomly, though they should be internally consistent.

<img src="/images/fulls/social-interest/ml/svm_user_performance.png" class="chart image">

Well, somewhat internally consistent. It's not evident from this scatter plot that the model is working at all, and the negative coefficients on some users indicate worse performance than random guessing. Let's try a few final methods of approaching this problem.

#### Boosted decision trees

[Gradient boosted](https://en.wikipedia.org/wiki/Gradient_boosting) decision trees work much better for this problem, due to the high dimensionality of the input data. Fairly easily, we are able to obtain a 56.9% accuracy, better than achieved with the SVM, without even attempting taking into account user information. Additionally, this is substantially faster than an SVM.

<img src="/images/fulls/social-interest/ml/boosted_scatter.png" class="chart image">

##### Simultaneous estimation of user-dependent effect

How can we modify the decision tree to incorporate user information and achieve a better result? Since a boosted decision tree is a general additive model, one possibility is to use the one-hot user data as a training feature directly. However, this has its complications -- we don't want a non-stump decision tree to use both user and image information. If we restrict the max-depth of each tree to 1, making every tree a stump, then this is not an issue, but performance is degraded. To avoid writing a custom gradient boosting implementation, we will not attempt this method.

Another possibility is to simultaneously estimate a per-user additive factor as additional trees are fit to the data. The first attempt at doing this involved alternately fitting 10 trees to the data, calculating the per-user mean error, and subtracting 20% of this per-user mean error from the log-like training value. Using this method, the accuracy increases to 57.1%, which is a fairly minor improvement.

The second method attempted for the estimating the per user additive factor was the following: apply gradient boosting to fit trees until reaching an early stopping criterion, calculate the per-user mean error on the training data, subtract that from the training log-likes, start over, and repeat. In this iterative way, the per user additive factor can be estimated. This process produces a 58.0% accuracy – comparatively quite good! -- although the training time is very long, as it must fit a gradient boosted tree model several times over.

Essentially, we have taken the standard gradient boosting algorithm and wrapped it in an optimization of the per-user mean. This first implementation subtracted the entire user mean on each step -- a very naive optimization that attempts to jump immediately to the correct answer. By decreasing this learning rate, a slightly better 58.1% accuracy can be achieved.

<img src="/images/fulls/social-interest/ml/boosted_w_user.png" class="chart image">

<img src="/images/fulls/social-interest/ml/boost_w_user_user_performance.png" class="chart image">

This model is the model that will be used going forwards.

## Results

Evaluated on a hold-out test dataset, (unique from the training and validation datasets used previously) only 54.7% of comparisons were correctly evaluated. This implies that there may have been some overfitting of the validation dataset during the hyperparameter/algorithm search. Alternatively, perhaps the test and validation datasets are too small, increasing the variance of this performance metric.

### On a non-Facebook dataset

A second way of evaluating the performance of these methods is by subjectively evaluating the performance on an unscored, non-Facebook dataset. In this case, we will be using a set of personal smartphone photos donated by a third party. As this is also the final application the model is being built for, it is the truest evaluation of its final usefulness.

We will look at the evaluated rankings of the set of photos taken on a particular date, and subjectively evaluate its performance. We will be using the gradient boosted tree model created with simultaneous estimation of the per-user additive parameters.

In each case, a wide range of predicted values were observed. Let's look at the top 5 and bottom 5 images for each day, excluding [near duplicates](http://exclav.es/2016/07/04/near-duplicate-detection-wavelets/). 

<img src="/images/fulls/social-interest/evaluation/image_rank_day_2.png" class="chart image" />

**Top 5:**

<div class="fiveup">
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/0-0.236570566893.jpg" class="fiveup image" />
		0.24
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/2-0.0846151411533.jpg" class="fiveup image" />
		0.085
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/3-0.0546078383923.jpg" class="fiveup image" />
		0.055
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/4-0.00846081972122.jpg" class="fiveup image" />
		0.008
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/6--0.00668597221375.jpg" class="fiveup image" />
		-0.007
	</div>
</div>

**Bottom 5:**

<div class="fiveup">
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/27--0.290789484978.jpg" class="fiveup image" />
		-0.291
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/26--0.254970729351.jpg" class="fiveup image" />
		-0.255
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/24--0.219216883183.jpg" class="fiveup image" />
		-0.219
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/23--0.208859860897.jpg" class="fiveup image" />
		-0.209
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day2/22--0.193027734756.jpg" class="fiveup image" />
		-0.193
	</div>
</div>

In this first example day, we see characteristically mixed results. The most likely image to be of social interest is, indeed a great image from that day. The third image, a close variant of the first (but not a near duplicate) is another "hit." However, as the content of these two images is very similar, it would be expected that they produce similar scores, which they do not. This indicates a need for improvement -- perhaps increasing the size the training dataset size with crops and rotations of the original images would build a model more robust to these minor variations. The other two images are both okay, and the fifth should not have been ranked nearly as highly as it was.

Of the bottom 5 images, two (the fourth and fifth) show a scene that should (in my subjective opinion) hold social interest -- hiking and setting up camp.

<img src="/images/fulls/social-interest/evaluation/image_rank_day_1.png" class="chart image" />

**Top 5:**

<div class="fiveup">
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/0-0.102307856083.jpg" class="fiveup image" />
		0.102
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/1-0.0760345160961.jpg" class="fiveup image" />
		0.076
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/3-0.0522575676441.jpg" class="fiveup image" />
		0.052
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/4-0.0502961874008.jpg" class="fiveup image" />
		0.050
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/5-0.0500894188881.jpg" class="fiveup image" />
		-0.050
	</div>
</div>

**Bottom 5:**

<div class="fiveup">
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/98--0.385226011276.jpg" class="fiveup image" />
		-0.385
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/97--0.367828667164.jpg" class="fiveup image" />
		-0.368
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/95--0.303746163845.jpg" class="fiveup image" />
		-0.304
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/94--0.278033137321.jpg" class="fiveup image" />
		-0.278
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day1/91--0.254591166973.jpg" class="fiveup image" />
		-0.254
	</div>
</div>

The model performs significantly better on this day, finding several great images of people, groups, and objects of interest on a day with nearly one hundred images. Of the bottom performing images, I personally find several of them nice, but we do know from previous investigation that landscapes tend to perform poorly. The fifth worst image likely should have been ranked higher, as it is of a somewhat unusual subject, bees!

<img src="/images/fulls/social-interest/evaluation/image_rank_day_3.png" class="chart image" />

**Top 5:**

<div class="fiveup">
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/0-0.121648490429.jpg" class="fiveup image" />
		0.122
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/1-0.110284596682.jpg" class="fiveup image" />
		0.110
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/4-0.0724286735058.jpg" class="fiveup image" />
		0.072
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/6-0.0502673685551.jpg" class="fiveup image" />
		0.050
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/8-0.00772568583488.jpg" class="fiveup image" />
		0.007
	</div>
</div>

**Bottom 5:**

<div class="fiveup">
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/25--0.238839328289.jpg" class="fiveup image" />
		-0.239
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/24--0.191740334034.jpg" class="fiveup image" />
		-0.192
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/23--0.178450167179.jpg" class="fiveup image" />
		-0.178
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/22--0.15498816967.jpg" class="fiveup image" />
		-0.155
	</div>
	<div class="scoreim">
		<img src="/images/fulls/social-interest/evaluation/day3/21--0.154493629932.jpg" class="fiveup image" />
		-0.154
	</div>
</div>

The top four images are all great picks for this day. Number five is somewhat iffy, but it could make sense in a narrative for setting a sense of place. The bottom four are all fairly missable photos. (The landscape with the clouds is a very blurry photo, a sharper version of it was rated higher.) The photo of the shadow, ranked fifth worst is somewhat interesting, however.

These three days worth of photos provide a typical cross-section into how the model performs currently. Overall, it is not great, though it is sometimes able to identify certain images that are likely to be socially interesting. There are significant issues that would be present in attempting to use this model for highlighting important images in a user interface.

In order to be understandable and intuitive to the user, a less opaque model, such as one that simply highlighted images with people in them, would be significantly more usable.

## Next steps

All is not lost, however! There are several apparent avenues for future investigation.

### How well can humans do this?

In the introduction, I discussed how I thought that this would be a difficult, underdefined task. After all, even humans have difficulty evaluating "social interest." But how well would humans perform on this same task, that of choosing the more interesting of a pair of images? I'm not completely sure -- it would certainly be an interesting Mechanical Turk experiment to set up.

### Different predictive features

Maybe image semantic analysis features really aren't the most predictive. What about the hidden layers of a network trained on AVA[^ava], or a face-detection network? (Haar cascades were used for the face data above.) After all, aesthetic parameters such as image sharpness, saturation, and composition, and deeper face attributes such as emotion certainly affect social interest.

### Using more training data

Since beginning this project, I have obtained an additional 300,000 Facebook images that could be used to extend the training dataset. However, these are from a slightly different source, (photo album pages, rather than wall pages) which could add additional noise to the training dataset. A better solution for extending the dataset would be by scraping the wall pages of users that I am not friends with, reducing the "social bias" of the data.

### Training a neural network

As mentioned above, one direction that I did not investigate is the complete training of a neural network from scratch. This was for two reasons -- a lack of computing hardware, and a lack of data. However, this problem may be more tractable for me in the near future. One method that I am particularly interested in exploring here is weight sharing between networks designed to predict different things -- for example, could a network that simultaneously predicts semantic content, aesthetic quality, and social interest share many of the first few convolutional layers? My suspicion is that it could.

## Conclusions

> Aim low. Aim so low no one will even care if you succeed. -- Marge Simpson

Expectations for success were initially minimal, and those expectations have been mostly met. Weak correlations have been found with expected image properties, including the presence of faces and the classified category of the image. The best trained classifier has a slightly better than chance likelihood of correctly classifying images according to social interest. Subjective evaluation of the results on a dataset from a completely different source demonstrates similar results -- slightly more interesting selections than randomly chosen images. However, because the model is relatively opaque and occasionally inconsistent in its decision making, a simpler and more easily understood method of highlighting images of social interest may perform better in real interfaces. Significant opportunities remain for further investigation.

## Appendix

Jupyter notebooks containing source code for this exploration are available [here](https://github.com/vignettist/social-interest). All code is licensed under the MIT License.

Unfortunately, I cannot release the Facebook image dataset due to privacy concerns.

Text is Copyright 2016, Logan Williams. All images are owned by their original creators.

## Citations

[^flickr]: Quora. [How does Flickr's interestingness work?](https://www.quora.com/How-does-Flickrs-interestingness-work) 2011.

[^karayev]: Karayev, et. al. [Recognizing image style](https://sergeykarayev.com/files/1311.3715v3.pdf). 2014.

[^lu1]: Lu, et. al. [RAPID: Rating Pictorial Aesthetics using Deep Learning](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ACMMM2014/lu.pdf). 2014.

[^lu2]: Lu, et. al. [Deep Multi-Patch Aggregation Network for Image Style, Aesthetics, and Quality Estimation](http://infolab.stanford.edu/~wangz/project/imsearch/Aesthetics/ICCV15/lu.pdf). 2015.

[^graphapi]: [Facebook Graph API](https://developers.facebook.com/docs/graph-api)

[^inception]: Szegedy, et. al. [Going Deeper with Convolutions](https://arxiv.org/abs/1409.4842). 2014.

[^ava]: Murray, Marchesotti, and Perronnin. [AVA: A Large-Scale Database for Aesthetic Visual Analysis](http://refbase.cvc.uab.es/files/MMP2012a.pdf). CVPR 2012.

[^yahoo]: Mahadeokar and Pesavento: [Open Sourcing a Deep Learning Solution for Detecting NSFW Images](https://yahooeng.tumblr.com/post/151148689421/open-sourcing-a-deep-learning-solution-for). 2016.

[^viola]: Viola and Jones. [Rapid Object Detection using a Boosted Cascade of Simple Features](https://www.cs.cmu.edu/~efros/courses/LBMV07/Papers/viola-cvpr-01.pdf). CVPR 2001.