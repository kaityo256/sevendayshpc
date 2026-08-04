---
title: Preface
description: Why use a supercomputer?
sidebar:
  order: 2
---

There are machines in the world called supercomputers, often shortened to “supercomputers” or “HPC systems.” As is often the case with impressive-sounding names, there is no unambiguous definition of exactly what a supercomputer is. Different people will draw the line differently, but for our purposes you can think of one as a machine made up of many “nodes,” each containing CPUs and memory, connected by a high-speed network and accompanied by a large file system.

Because the word contains “super,” some people may imagine that a supercomputer is something extraordinary and difficult to use. The techniques required simply to use one, however, are quite straightforward. In my experience, a student with basic programming skills can start submitting ordinary supercomputer jobs after receiving instruction from an experienced user for less than a month. Getting started is that easy. Mastering a supercomputer is another matter. In practice, every additional decimal digit in the degree of parallelism exposes qualitatively different difficulties. Code that runs with one hundred processes may fail with one thousand, and code that runs with one thousand may crash with ten thousand. That depth is fascinating, but it lies outside the scope of this text.

This article is for people who do not have a supercomputer expert nearby. Its goal is to help you become capable of using a supercomputer in seven days—or, more precisely, to convince you that anyone can plausibly become a supercomputer programmer after spending about seven days on it.

## Why use a supercomputer?

Why use a supercomputer in the first place? Because it is there. If you are reading the original Japanese edition, you are quite likely in Japan, which gives you access to some of the world’s leading supercomputers. Japan is a major supercomputing nation. The TOP500 website shows the countries hosting the world’s five hundred fastest systems. In June 2018, China led with 206 sites, the United States was second with 124, and Japan ranked third with 36. A country that ranks third in the number of TOP500 systems and has repeatedly hosted the world’s number-one system can reasonably be called one of the world’s major supercomputing nations.

I once had the following experience while collaborating with a researcher overseas. I proposed a calculation to my collaborator. He replied that it would be interesting, but computationally far too expensive. When I told him, “It would take about a day on our supercomputer,” he was astonished. This was more than an example of Japan having abundant computational resources. It suggests that **the upper limit of a person’s imagination is set by the scale of the computing resources they use every day**. I believe this is extremely important.

The usual sequence is to begin a calculation on a local PC, find that it has become too demanding, and then consider a supercomputer as the next step. Before applying for access, you would estimate what size of supercomputer could perform what scale of calculation. In other words, the topic—the objective—comes first, and the supercomputer—the means—comes afterward. That is entirely reasonable. My personal view, however, is that it is often better to start using a supercomputer even before you know exactly what you want to do or how much computation it will require. Someone who works only on a local PC may unconsciously reject research topics that would need a supercomputer. Someone accustomed to using one has a higher ceiling on their imagination and can consider options that an ordinary PC could not handle. In that sense, the supercomputer—the means—comes first and the topic—the objective—can follow. Supercomputers are not especially difficult to begin using, so start before overthinking it.

## Let’s get started

This is not unique to parallel programming: whenever you begin something new, people who started a little earlier will offer all kinds of advice. Someone will inevitably say, “You should optimize communication from the beginning,” or, “There is no point parallelizing code whose serial efficiency is poor.” You can safely ignore them for the first couple of years. First, learn to use a supercomputer. Even if your code is slow because it has not been tuned, and even if its parallel efficiency is poor, write something that runs on a reasonable number of nodes and execute it. That should be your first goal. The ability to write code that runs across a substantial number of nodes is already a powerful tool.

![Supercomputers make ambitious work possible](/sevendayshpc/en/preface/fig/myjob.png)
