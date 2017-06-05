---
title: Conversation in action
layout: post
date: '2017-06-05T13:12:55+00:00'
---
[Previously](http://vignette.cool/2017/01/25/tools-for-working-with-images.html), I discussed methods of clustering photos into geographically and temporally related groups, and some of the trade-offs involved in various clustering algorithms and parameters. Since then, I have arrived at a workable set of defaults, and created an interface that allows clusters to be merged and split. I have not yet built a tool for custom cluster editing, and the split tool does not allow the user to select a split point. Instead, it uses k-means clustering with k=2 to try to find the most logical point to split the cluster. This is a user interface issue more than a technical issue -- I am not yet sure how to integrate a more customizable cluster creation tool into the application.

![](/uploads/2017/06/05/cluster_merging-1.gif)

*Merging multiple clusters together into one event with Vignette.*

### Conversation engine

Fundamentally, Vignette is driven by a hypothesis that since stories are always told to someone, it is much easier to tell a story through conversation than by composing text onto a blank piece of paper. By interacting with a conversational user interface, the user might find it easier to think about photos and the connections between them in a narrative way.

For the prototype Vignette app that I am creating to test these hypotheses, I designed a relatively simple and constrained conversation system, driven by a finite state machine, or FSM. In an FSM, there are explicitly designed states corresponding to specific output messages from the computer. One can imagine it as a kind of flowchart, and to design the conversation flow, I actually created a large flow chart of questions and possible responses.

![](/uploads/2017/06/05/Screen%20Shot%202017-05-03%20at%201.14.17%20PM.png)

*A portion of the finite state machine that drives the conversational user interface in Vignette.*

Some states in the state machine have multiple possible outputs. Decisions on which output path to follow can be made randomly or by analysis of the the user’s input. Currently, this analysis is quite limited, and it primarily looks for the presence of affirmative or negative words to decide if the user is responding yes or no. If the user is responding with a long statement, the FSM may decide to skip a followup question and use that statement directly, however, this is based only on the length of the statement, not on the content.

The FSM transitions from one state to another either automatically or after the user has provided a new input. With every transition, it presents a new statement or question to the user. Some of these statements are entirely pre-defined, for example “Show me another photo you think is interesting,” which is visible on the state diagram above. Other outputs will try to use information from earlier in the conversation to produce a more intelligent response, either by having some notion of the current topic of conversation (a person or a place), or by picking out a piece of the previous response. This is used currently to ask the user to elaborate on an earlier answer.

<video>
<source>/uploads/2017/06/05/ww_story.mp4
</video>

Clearly, this conversation engine has a very poor level of understanding of the content of the conversation. It is easy to imagine that more sophisticated natural language processing and a contextual understanding database might enable better questions and a greater level of human response.

I believe that this is not entirely true -- while improvements in certain areas, especially syntax, would be beneficial, understanding the context of photographs and the intent of natural language is a very difficult problem. When dealing with the potentially quite personal data contained in photographs, the stakes are very high. To some extent, the fewer assumptions that are made when asking a question the better. From testing the Vignette prototype, motivated users are adept at filling in the gaps in a vague or poorly worded question. This is not to say that understanding cannot be improved. Better natural language processing is on the Vignette roadmap. But, assumptions about content and context must always be made carefully. Asking, not asserting is a core design principle of my work.

The questions themselves can also be improved. I have spoken with radio hosts and podcast producers to learn how they  try to tangle out stories from real people. What kind of questions put someone in a storytelling mode? What questions require very few assumptions? Essentially, what would you as an interviewer ask a subject if you had completely neglected to prepare for the interview but still wanted to tell a good story?

### Story formation

For Vignette, conversation is not the goal. Instead, the conversational user interface is intended to prompt users to start thinking about the memories and feelings captured in their photographs in more depth. Once in this narrative mode of thinking, the computer prompts the user to begin writing their story in a more traditional text composition environment.

![](/uploads/2017/06/05/Screen%20Shot%202017-06-01%20at%204.57.27%20PM-1.png)

*At the conclusion of a conversation, Vignette prompts the user to transition to the composition mode.*

To avoid the difficulty of starting writing from a completely blank slate, Vignette uses the conversation it has had with the user to form a skeleton of a story.

The story skeleton begins by choosing images to insert. Approximately one image is used every hour of a cluster, with priority given to those images that the user has thumbs-upped or that have been involved in the conversation. Next, user responses associated with a particular image through conversational context are placed adjacent to their topic image in the story. However, because the order that the user chooses to tell the narrative in may not correspond to the order it was experienced in, the sequencing of the story skeleton is sometimes confused. The question that was asked of the user is also included, interview transcript style, with the answer. In the future, more sophisticated natural language processing to merge the question and the answer into a more natural paragraph would improve this process.

![](/uploads/2017/06/05/short_story_skeleton.png)

*The auto-generated story skeleton.*

At this stage, a simple composition interface is presented to the user, with the ability to add text and headings, choose images from the event, and add maps to help illuminate geographic context. At each edit, addition, or deletion, the state of the story is updated in a MongoDB collection.

<video><source>/uploads/2017/06/05/ww_editor.mp4</source></video>

The interface is designed to be as straightforward and non-distracting as possible. To this end, sophisticated formatting options are not provided, neither is the ability to upload images not already associated with the cluster or even to choose images in Vignette from a different cluster.

There may be ways to push this minimalism even further. Several observers of test users have pointed out that users have not added images to the story, instead they have used the ones automatically placed in the story by the generator. Perhaps this feature is unnecessary. Users could still control the images in the story by thumbs-upping them in the conversation interface.

I also discovered that users also have different preferences about text coming before or after an image. It may make more sense to flip the default, so that text introduces each image.

### Next steps

The application featured in these screenshots and videos is currently online (and, of course, open source) on GitHub. However, setting it up to use yourself is currently a complicated process. Vignette needs some substantial packaging and cleanup effort, and the photo import process needs to be better integrated into the overall application. (Currently, photos are imported by running a separate script.)

I am excited about continuing to experiment with the conversational engine. Interviewers will often leave silence in a conversation to encourage the interviewee to keep talking in order to fill in the silence. What if a chatbot did this too? What if the chat interface briefly showed a “message in progress” ellipsis, then this vanished? I think that this might provoke a clarifying response for the user, or an expansion of the current discussion. It could also help subtly indicate that the computer doesn’t feel very confident in what it is trying to ask or say -- another way to add AI humility. It could also be interesting to add text-to-speech and support spoken responses. Not only would this be a more comfortable input interface for storytelling on mobile devices, emotionally intimate stories might be better told with the nuance of human speech.

Geography is an extremely important, especially for longer (year-scale) self-narrative arcs. There are many opportunities to better integrate place into Vignette. For example, the clustering interface could expose the places visited in each cluster, and a “cluster map” view could allow for exploration of geographic trends.

<video><source>/uploads/2017/06/05/overview.mp4</source></video>

There are also some less critical, self contained additions to Vignette that could be interesting projects. It would be pretty fun to create different renderers for the final narrative content -- to a static webpage, to a PDF, to a pamphlet/book format, etc. Are there unconventional formats that this would work well with?

Another fun side project would be building some image adjustment filters. One of the main reasons people use Instagram is that it makes photos look better. Vignette should help people make their photos look as good as possible too.

I would also like to continue showing new users the Vignette demo and seeing what they write and do with it. If you are interested in participating in a Vignette user study, please send me an email at [logan.williams@alum.mit.edu](mailto:logan.williams@alum.mit.edu). Currently, I will be conducting these in the Bay Area, but if you are technologically adventurous, I’d be interested in helping you run your own instance of Vignette as well.