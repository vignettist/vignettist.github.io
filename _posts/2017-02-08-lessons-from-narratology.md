---
title: Lessons from narratology
layout: post
date: '2017-02-08'
---
As I explore and develop Vignette, my photo narrative project, I have also been reading about theories of narrative structure. Narratives are vital to human understanding. Narratives describe a connection between a series of events by convincing a reader of a progression or cause. Without the ability to construct a narrative, there would be no stories, only unrelated events. [1] Research in cognition shows that narrative is strongly linked to memory, and that understanding of many complex relationships takes the form of narrative. [2] Modern narratology is heavily influenced by cognitive models and “considers narrative to be the conscious and unconscious mental framework that supports and directs human thinking.” [3] Furthermore, narrative creation is understood to be a critical part of personality building and self-definition. [10] Constructing coherent life-narratives is strongly associated with greater life satisfaction and reduced risk of depression, [7] and assistance with narrative is now a common psychotherapeutic approach.

<blockquote>Throughout our lives, things frequently happen without prior warning and bring about radical changes in the course of events, for example the first unexpected meeting with one’s future partner. In reconstructing our own lives as stories, we like to emphasize how particular occurrences have brought about and influenced subsequent events. Life is described as a goal-directed chain of events which, despite numerous obstacles and thanks to certain opportunities, has led to the present state of affairs, and which may yet have further unpredictable turns and unexpected developments in store for us. It is therefore not surprising that psycho- analysis should have incorporated the telling of the patient’s life story into the therapeutic process; indeed, many psychologists give the act of narration a central position in therapy. [2]</blockquote>

### What is narratology?

I am by no means an expert in literary theory, and I will not attempt to summarize narratology comprehensively. Instead, I have collected theories and history from my readings that provide useful perspectives and ideas for the exploration and development of Vignette.

Narratology is the study of what is and isn’t a story, and what makes those things that are narratives ‘tick.’ In fact, critic Frank Kermode uses a ‘tick,’ the sound of a clock, explicitly in his attempt to illustrate one of the major concepts of narratology, plot: “The clock’s tick-tock I take to be a model of what we call a plot, an organization that humanizes time by giving it form.” The second important concept in narratology is discourse. While plot is responsible for organizing and connecting events, discourse is how the plot is presented to its audience. [1]

In Vignette, while both plot and discourse will primarily be up to the user, the software will assist with both. To help find stories and make it easier to navigate by story, we need a way of guessing at the plot, or narrative connections, between the events. For the discourse, Vignette will be a little more hands off. The user will be the one writing their story, the one choosing the photos to accompany it, and the one utilizing visualizations to help draw narrative lines. Even still, Vignette will be responsible for generating those visualizations, and helping the user to find and choose them. Vignette will never attempt to emulate or replace human creativity, but it must necessarily change it. As Japanese researcher Takashi Ogata states when he introduces his artificial intelligence narrative generation system, new technology necessarily leads to new narrative forms. [3]

Many literary theorists have tried to categorize narratives. The simple trichotomy of events, plot, and discourse introduced above is essentially a simplification of the six fundamental components of narrative defined by Aristotle: plot, character, thoughts, diction, song, and scenery. [3] In the early 20th century, a Russian folklorist, Vladimir Propp, analyzed a hundred folktales and defined 31 functions, including characters, events, and themes, that could be combined in different ways to produce a multitude of stories. Later theorists found other, generally more general ways of dividing stories: theorist Franz Stanzel split categories based on the narrator’s perspective [2] and Gérard Genette divided stories by tense, mood, and voice. [1]

### Plot and schemas for stories

In the 1970s, many researchers started trying to discover story schemas or plot grammars. Like the grammar of language itself, a story grammar consists of abstract objects that can be combined with each other in different ways to define the syntactic structure of a narrative. An influential author in this field was David E. Rumelhart, who in his 1975 paper Notes on a Schema for Stories, defined a straightforward example of a story grammar. He proposed 11 rules that could be combined in various ways, beginning with the most fundamental: STORY = SETTING + EPISODE. Each of these terms was defined further, for example, a SETTING is any number of STATES, and an EPISODE is an EVENT + REACTION. [4]

<span style="background-color: transparent; font-size: 1rem;">Two years later, another researcher, Peter Thorndyke, proposed another story grammar that was very similar in theme. His 10 simple rules are reproduced below.</span>

![](/uploads/2017/06/06/Screen%20Shot%202017-06-06%20at%2011.42.44%20AM.png)

*<span style="font-size: 1rem;">Thorndyke's grammar defines each element of a narrative in terms of a composition of other elements. An asterisk indicates that the element can be repeated, for example, a plot may be made of multiple episodes. [5]</span>
*

With grammars like these, researchers attempted to lay out the elements of a narrative in terms of its basic components. Even a simple story, such as the one below, used by Thorndyke in his research, could become bewilderingly complex.

![](/uploads/2017/06/06/Screen%20Shot%202017-06-06%20at%2011.42.32%20AM.png)

<span style="font-size: 1rem;"><i>Using his grammar, Thorndyke decomposed a simple story into its atomic narrative components. [5]</i></span>

While decomposition of narratives into elaborate structural trees is of limited applicability to Vignette, or indeed, any real world project, what Thorndyke used this structure for was quite interesting — he systematically varied the narrative by removing or rearranging structural components, and measured the ability of study participants to comprehend and recall each variant. What he found makes intuitive common sense: facts and events that were more important to the narrative (higher in the hierarchy) were easier to recall; repeating structure in subplots improved recall; and removing or de-emphasizing higher order themes reduced comprehensibility and recall. If the story was presented as a series of descriptive facts, i.e., events presented without the benefit of narrative connection, recall and comprehensibility dropped by 50%. The story grammar as presented can be seen as defining a kind of narrative coherence. [5] These results have been reproduced by other researchers [6], and while the decomposition of a story into a strictly structuralist grammar has fallen out of fashion in modern literary criticism, or at least is understood as a fundamentally limited method of analysis, conclusions about coherence and understanding remain relevant.

In addition to showing the dramatic influence of narrative on how people process and understand events, Thorndyke and Rumelhart’s grammar present some opportunities for categorizing the narrative role played by images explored with Vignette. A photograph could represent a

* **Setting**, by depicting a character, location or time
* **Event**, by depicting an attempt, outcome or resolution
* **State**, by depicting a modification of the original setting

It is clear from Thorndyke’s grammar however, that this is only half of a story. Missing are goals, subgoals, desired states, and the important higher level concepts, like themes, that can be built from them. The creation and description of these objects cannot be represented by photos alone, and users and their words must fill the void. This gap also suggests roles for the conversation user interface in Vignette. While goals, for example, cannot be determined from photographs alone, they can be elucidated through conversation.

### Defamiliarization and creativity support systems

Viktor Shklovsky coined the term defamiliarization to describe a method for making a known object seem strange or extraordinary through the use of unconventional language or technique in describing it. [3] One can imagine using defamiliarization to elicit new or buried emotional responses to a photograph, and the term recalled a connection to the work of photo-historian Annette Kuhn. In her book, Family Secrets, she describes and uses the technique of memory work to gain new insights into her personal and cultural past through the medium of photography. By considering the subject of the photograph, visualizing oneself in the place of the subject, thinking about the technology used to create (and today, share) the image, and other methods, she created a structure for establishing sufficient methodological distance to allow emotionally closeness. [9] The technique of subject perspective switching is particularly interesting to me, not the least because of the ease with which the grammatical transformation could be performed with natural language processing libraries. In fact, this technique has been used by Japanese researcher Mina Akaishi in a prototype narrative generation system. [8] Other researchers have proposed creativity support systems for narrative creation, supervised or stimulated by a creative user. [3] Vignette will, in many ways, be another example of a creativity support system.

---------------------------------------

### Bibliography

* Culler, J. (1997). Literary Theory: A Very Short Introduction.
* Fludernik, M. (2009). An Introduction to Narratology.
* Ogata, T. (2016). Computational and Cognitive Approaches to Narratology.
* Rumelhart, DE. (1975). Notes on a Schema for Stories.
* Thorndyke, P. (1977). Cognitive Structures in Comprehension and Memory of Narrative Discourse.
* Brewer, W. and Lichtenstein, E. (1980). Event schemas, story schemas, and story grammars.
* Baerger, D. and McAdams, D. (1999). Life Story Coherence and its Relation to Psychological Well- Being.
* Akaishi, M. (2006). A Dynamic Decomposition/Recomposition Framework for Documents Based on Narrative Structure Model.
* Kuhn, Annette. (2002). Family Secrets: Acts of Memory and Imagination.
* McAdams, D. (2008). Personal Narratives and the Life Story.