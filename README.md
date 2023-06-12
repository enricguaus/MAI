![esmuc.png](./esmuc.png)
# MAI
Musicians and Artificial Intelligence  
by Fèlix Pastor ([ESMUC](https://www.esmuc.cat/) | [Sheepdog](http://sheepdog.es/)) and Enric Guaus ([ESMUC](https://www.esmuc.cat/) | [Sheepdog](http://sheepdog.es/))  
SONAR+D  
Friday, June 16, 2023, 12:00-13:00.  
[Lounge+D](https://sonar.es/en/activity/lounged-viernes)

## Introduction
In the last years, Artificial Intelligence has provided numerous breakthroughs within the music industries.  Automatic music reccommendation (p.ex. [Spotify](https://open.spotify.com/?)), copyright management companies using AI (p.ex. [BMAT](https://www.bmat.com/)), free online text to speech applications (p.ex. [Murf](https://murf.ai/)) or noise removal plugins (p.ex. [LALAL.AI](https://www.lalal.ai/voice-cleaner/)), among others, are good examples of that. 

Nowadays, with the emergence of [generative artificial intelligence](https://en.wikipedia.org/wiki/Generative_artificial_intelligence), part of the research in music applications is focused on the automatic creation of melodies given a list of tags (p.ex. [Mubert](https://mubert.com/)), a short textual description (p.ex. [Riffusion](https://www.riffusion.com/)) or a detailed textual description (p.ex. [MusicML](https://google-research.github.io/seanet/musiclm/examples/)). These stunning products are the result of many years of research carried out by universities and institutions sharing their results through research papers in journals and conferences (p.ex. [ISMIR](https://www.ismir.net/)), code (p.ex. [Tensorflow](https://www.tensorflow.org/)) and datasets (p.ex. [MusicBrainz](https://musicbrainz.org/)).  

However, it is well known that machine learning algorithms tend to propose models that hardly deviate from the parameters established by the data itself. This makes all of the initiatives mentioned above useless for many composers and performers. Traditionally, artists create their aesthetic models based on knowledge, tradition, social context, etc. but there is always a component of innovation, risk and customization that current AI models cannot include. Nevertheless, there are some successful examples of composers who have used AI models in their compositions in contemporary music (p.ex. [Quayola & Seta](https://www.youtube.com/watch?v=WzfBkArrN28)), jazz (p.ex. [Marco Mezquida](https://www.youtube.com/watch?v=dHh4vP5T6VM)) or electronic music (p.ex. [Mouse on Mars](https://www.youtube.com/watch?v=F7WlJTO9-Kg)). In these cases, the models used on stage have been created thanks to external collaboration or extensive in-house knowledge in computer science and data mining. According to [Born (2021)](#lectures), this division of tasks between the composer and scientist may become a “subordination-service” in which science is brought in apparently as subordinate discipline to ‘serve’ what are assumed to be the pre-existing, autonomous creative ‘visions’ or ‘needs’ of composers.

## Goals

The “Musicians and Artificial Intelligence” (MAI) project seeks to explore the intersection between the musical and scientific approaches to AI through a showcase of two PureData patches that implement two different architectures for creating AI models that can be mapped to a DAW or any other synthesis software via OSC or MIDI.

For that, we want to promote the use of these pre-cooked and ready-to-use patches between musicians as a starting point for further exploration. We will promote its use between our students, but the code and installation guides are publicly available for the whole community.

Please, navigate between de [supervAIsed](/supervAIsed) and [unsupervAIsed](/unsupervAIsed) folders for further information.

Feedback is welcome.

## Resources

* [code](/supervAIsed/puredata) and [details](/supervAIsed) for supervAIsed architecture.
* [code](/unsupervAIsed/puredata) and [details](/unsupervAIsed) for unsupervAIsed architecture.

## Future work

* Convert to VST plugins for DAWs (eliminates Blackhole, MIDI and OSC configurations).
* Please, use it and send feedback!

## Acknowledgments 

This work has been partly funded by the Escola Superior de Música de Catalunya ([ESMUC](https://www.esmuc.cat/)) .

## Lectures

* Born, G. (2021). Artistic Research and Music Research: Epistemological Status, Interdisciplinary Forms, and Institutional Conditions. In A. Huber, D. Ingrisch, T. Kaufmann, J. Kretz, G. Schröder & T. Zembylas (Ed.), Knowing in Performing: Artistic Research in Music and the Performing Arts (pp. 35-50). Bielefeld: transcript Verlag. 
