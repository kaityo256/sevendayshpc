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

Why use a supercomputer in the first place? Because if you have access to one, you should use it. A supercomputer does more than enable large-scale calculations; it also expands the range of problems you can imagine tackling.

However, access to such computing resources is far from evenly distributed around the world. The [TOP500](https://top500.org/), which ranks the world’s most powerful general-purpose computer systems, also shows where these systems are installed. In the June 2026 edition, more than half of the 500 listed systems were located in just four countries: the United States, Japan, Germany, and China. Together, these countries accounted for 277 systems.

This concentration means that access to a world-class supercomputer remains limited to a relatively small number of people and institutions. Therefore, if you are fortunate enough to have access to one, you should take full advantage of it.

My own experience has shown me how profoundly access to computing resources can shape the way researchers think. While collaborating with a researcher overseas, I once proposed a particular calculation. He replied that the idea was interesting but that the calculation would be far too computationally expensive. When I told him, “It would take about a day on our supercomputer,” he was astonished.

This episode illustrates more than the relative abundance of computational resources in Japan. It suggests that the scale of the computing resources we use every day can shape the limits of what we consider computationally feasible—and, consequently, the kinds of questions we think to ask. I believe this is one of the most important benefits of having access to a supercomputer.

The usual sequence is to begin a calculation on a local PC, find that it has become too demanding, and then consider a supercomputer as the next step. Before applying for access, you would estimate what size of supercomputer could perform what scale of calculation. In other words, the topic—the objective—comes first, and the supercomputer—the means—comes afterward. That is entirely reasonable. My personal view, however, is that it is often better to start using a supercomputer even before you know exactly what you want to do or how much computation it will require. Someone who works only on a local PC may unconsciously reject research topics that would need a supercomputer. Someone accustomed to using one has a higher ceiling on their imagination and can consider options that an ordinary PC could not handle. In that sense, the supercomputer—the means—comes first and the topic—the objective—can follow. Supercomputers are not especially difficult to begin using, so start before overthinking it.

## Let’s get started

This is not unique to parallel programming: whenever you begin something new, people who started a little earlier will offer all kinds of advice. Someone will inevitably say, “You should optimize communication from the beginning,” or, “There is no point parallelizing code whose serial efficiency is poor.” You can safely ignore them for the first couple of years. First, learn to use a supercomputer. Even if your code is slow because it has not been tuned, and even if its parallel efficiency is poor, write something that runs on a reasonable number of nodes and execute it. That should be your first goal. The ability to write code that runs across a substantial number of nodes is already a powerful tool.

![Supercomputers make ambitious work possible](/sevendayshpc/en/preface/fig/myjob.png)
