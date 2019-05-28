---
title: "Modelling body temperature of ectotherms"
layout: article
author: Juan G. Rubalcaba
---

Many ectotherms (cold-blooded animals like invertebrates, frogs or lizards) can exploit the heterogeneity of their environment 
selecting microhabitats such as sunny or shaded areas, basking sites or burrows to control body temperature. This capacity for "behavioural thermoregulation" is critical because it allows ectotherms to buffer variations in body temperature and thus the impact of climate warming.

It is important to measure or model the temperatures that organisms experience in each microhabitat to understand how their repertoire will vary under climate change. We use the concept of "operative temperature", defined as the equilibrium temperature of an individual in a microhabitat, to obtain information on the repertoire of microclimates that individuals can use for thermoregulation. 

<img src="/images/posts/bodytemp.jpg">

>The operative temperature is the equilibrium temperature of an individual in a microenvironment, and depends on multiple sources and sinks of heat energy, as well as body size, shape and radiative proprieties of the animal.


But knowing the repertoire of operative temperatures is only part of the job. We also need to understand how individuals use these microhabitats to control body temperature throughout the day. For example, if lizards target a preferred temperature of 31ºC and they can select amongst basking sites (operative temperature 37ºC), shaded areas (26ºC) and burrows (21ºC), they will probably move between exposed and shaded areas to maintain body temperature near their preferred value. 

But can we actually estimate this probability? and beyond that, can we model the probability distribution of body temperatures that individuals will experience while moving among microhabitats? This is what we aimed <a href = "https://www.amnat.org/an/newpapers/MayRubalcaba.html" target="_blank"> here </a>, applying the maximum entropy framework, a procedure to derive statistical distributions when we know little about the rules governing the behaviour of the system. 

Using the maximum entropy framework to model behavioural thermoregulation sounds trickier than it is. This is why I'm writting this post (and this <a href = "https://jrubalcaba.shinyapps.io/jrubalcabagithub/" target="_blank"> online app </a>).

><a href = "https://jrubalcaba.shinyapps.io/jrubalcabagithub/" target="_blank"> Try the app! </a>
><a href = "https://jrubalcaba.shinyapps.io/jrubalcabagithub/" target="_blank"> Download the R code </a>

Imagine that we know the temperature that individuals of a small lizard species target in the field (we can get this information by just measuring body temperature of individuals in the field at any time). Futhermore, we know the operative temperatures of each microhabitat (basking sites, shades and burrows) either because we measured them, or because we have a good mathematical model estimating these temperatures. We ask what is the probability of finding an animal in each site.

FOTO DE INPUTS

A question would be *do they really care about having body temperatures that are not exactly equal to their preferred temperature?* If we talk about lizards, we know that many species are actually very good at thermoregulating behaviourally, but others act as thermoconformers. We therfore need a way to quantify *how much thermoreconformer* is our species. This is what parameter *lambda* tells us. Although *lambda* can take any real value, we will just focus on lambda equal or lower than 0. When equal to 0, there will be no constraint on the allocation of individuals among microhabitats and thus they will be distributed randomly:

FOTO LAMBDA 0

In this case, we are showing a very simplistic example where lambda 0 means equal probability of sun, shade or burrow. But when individuals are randomly allocated they must sample the actual proportion of sunny areas, shades and burrows. The relative frequencies of microhabitats are prior probabilities in the model (here we assume a flat prior) and actually a topic for a further post. 

What happens if we increase lambda? 

Why is that useful? There are two main questions that we can address with this model. First, when we know the repertoire of operative temperatures, modelling the distribution of body temperatures gives us information about what is the probability that animals experience, for example, temperatures above their heat tolerance limits. Recent advances in biophysical modelling now allow to model operative temperatures of microclimates from macroclimatic data at any geographical location. We just need to feed the maximum-entropy model with these data to derive distributions and thus forecast the risks of climate warming.

Second, in the paper we show how to contrast predicted distributions with observed body temperature data. With this information, we can derive the actual value of lambda (the thermoregulatory strategy) displayed by our population. This measure informs about the potential of behaviour to buffer climate change. 

There are still a lot of questions that we can address and (honestly) I have no idea how the model will behave with other species / different sites / different planets (it would be cool to try this). I hope this paper opens new avenues to investigate the responses of ectotherms to climate warming!

