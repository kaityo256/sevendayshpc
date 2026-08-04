---
title: Postface
description: The author’s experiences with supercomputers and acknowledgments
sidebar:
  order: 10
---

In 2003, when I was a doctoral student, I obtained an account on the Earth Simulator. At the time it was the world’s number-one supercomputer, reigning as an overwhelming presence far ahead of the systems below it. I belonged to a project in order to use it and, if I may say so myself, I think I was expected to make a meaningful contribution. But I was in the third year of my doctorate and busy writing my dissertation. Moreover, remote use of the Earth Simulator was not permitted then. To use it, I had to reserve a terminal and travel to the research facility in Shin-Sugita. This may sound like an excuse, but I did not have the capacity to write my dissertation while also traveling to a distant terminal to develop and tune code. In the end, I graduated, found a job, and saw the project conclude without having used the Earth Simulator to any significant extent. In November 2004, the year I graduated, the Earth Simulator also surrendered first place in the TOP500 to Blue Gene.

“I had the chance to work with the world’s fastest supercomputer, and I barely touched it.”

That regret left me with a powerful resolve: the next time Japan built a national flagship supercomputer, I would make absolutely sure to master it.

Time passed. In 2011, I took my family to Kobe and stayed there for about six months to evaluate the K computer before it opened to general users. I was not involved, but this was precisely when the HPL measurements on K were being performed. In June 2011, K [took first place in the TOP500, Japan’s first number-one ranking since the Earth Simulator seven years earlier](http://www.riken.jp/pr/topics/2011/20110620/).

After various twists and turns, a project I proposed was accepted. In March 2015, I was submitting full-system jobs on K in order to publish a paper. K was normally shared by many users, and there was only one opportunity each month to run a full-system job. The paper deadline was in early April, so I had three opportunities beginning in January. The job had worked correctly in tests at around 4,096 nodes, but it failed twice at 82,944 nodes, leaving no more room for failure. The cause was a temporary buffer whose size grew with the node count: it was harmless at 4,096 nodes but exhausted memory at 82,944. K sent email when a job started and when it ended, so if the start and end messages arrived at the same time, I immediately knew the job had crashed.

On the third attempt, the start message arrived but no end message followed. That meant my job was occupying the entire K computer and running at that very moment. It was genuinely a case of being able to say, “You know that job running on that supercomputer? That’s mine.” But I could not relax until it finished. I waited almost as if praying for the completion email. After the job ended, I checked the log showing normal termination and visualized the dump file. There was a large bubble—I was simulating bubble formation with molecular dynamics at the time. The job on which submission of the paper depended somehow completed successfully, allowing me to submit it. I can still recall the tension, the disappointment after each failure, and the excitement while that third job was running.

My work brings me into contact with supercomputers every day, and I believe they carry a sense of possibility. They feel capable of things that ordinary personal computers cannot do. When I first began using them, I worried whether someone like me could really operate one. Once I tried, I found it surprisingly straightforward and enjoyed the feeling that I had mastered a supercomputer. With further experience, however, I increasingly felt that the machine held much more potential than I knew how to extract. Even today, I have not done work that leaves me fully satisfied that I brought out a supercomputer’s potential and performed a truly interesting calculation. Yet supercomputers remain fascinating.

Because supercomputers involve large amounts of public money, the news stories about them often seem to be negative. Interesting calculations and technologies receive little attention, while topics far removed from the enjoyment of supercomputing—epitomized in Japan by the question, “Why can’t it be number two?”—dominate discussion. It has been frustrating, as someone with a long relationship with supercomputers, to see explanations by people who do not appear particularly familiar with them win broad agreement. As in any field, you cannot truly feel what a supercomputer is without actually working with one. People are free to debate them in terms of price, benchmark scores, and theoretical peak performance, but I do not believe those figures alone let me understand a supercomputer.

This text was not written so that someone unfamiliar with supercomputers could skim it and feel that they understood them. I wrote it so that readers could experience several things: parallel computing is easier than it may appear; anyone can quickly begin using a supercomputer; trying to exploit one fully immediately reveals many difficult and obscure problems; and those difficulties are precisely what make the subject interesting.

I will put down my pen while dreaming that, at a conference reception in the near future, a student I have never met will suddenly approach me and say, “I read *Become an HPC Programmer in Seven Days!* and became a supercomputer programmer.”

Hiroshi Watanabe, 2018

## Acknowledgments

I began writing this article after being inspired by [tanakamura](https://github.com/tanakamura)’s [Practical Low-Level Programming](https://tanakamura.github.io/pllp/docs/).

angel\_p\_57 taught me about buffering in MPI. fujita\_d\_h discussed L1 error correction on Blue Gene/L with me. n\_IMRC introduced me to a paper on TLB misses in matrix multiplication. I also thank everyone who gave the unfinished article so many stars and everyone who sent comments on Twitter and elsewhere. Without your positive response, I could not have continued writing.

I will be delighted if this text inspires even one more person to try using a supercomputer.
