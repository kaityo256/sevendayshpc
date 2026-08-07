---
title: Become an HPC Programmer in Seven Days!
published: false
description: An English version of a Japanese seven-day introduction to supercomputer programming with MPI, OpenMP, and SIMD.
tags: hpc, mpi, openmp, cpp
---

I have published an English version of my online course, **Become an HPC Programmer in Seven Days!**

English version: https://kaityo256.github.io/sevendayshpc/en/

Repository: https://github.com/kaityo256/sevendayshpc

The course is an introduction to programming for supercomputers and HPC systems. It is based on a Japanese text titled **一週間でなれる！スパコンプログラマ**, and it walks through the basic ideas over seven days.

## What the Course Covers

The material starts from the environment setup and gradually moves into parallel programming techniques used on HPC systems:

1. Environment setup
2. Using a supercomputer
3. Embarrassingly parallel computation
4. Nontrivial parallelism with domain decomposition
5. Two-dimensional reaction-diffusion equations
6. Hybrid parallel programming with MPI and OpenMP
7. SIMD optimization

The examples are written mostly in C++ and include small programs for MPI, OpenMP, and SIMD. The goal is not to be a complete reference manual, but to give readers a concrete path from "I have heard of supercomputers" to "I can understand the basic structure of an HPC program."

## Why I Made It

Many introductions to parallel programming focus either on theory or on a specific production environment. I wanted this material to be more like a short course: each chapter introduces a practical concept, shows a small example, and builds toward more realistic parallel programs.

The Japanese version has existed for some time. I recently prepared the English web version so that the material can be read by a wider audience.

## A Note About the English Translation

The English edition was translated from Japanese. I reviewed it, but I am not fully confident that every sentence sounds natural to English-speaking readers.

If you find awkward wording, unclear explanations, mistranslations, or inconsistent terminology, pull requests are very welcome. Small language fixes are especially appreciated.

Contribution guide: https://github.com/kaityo256/sevendayshpc/blob/main/CONTRIBUTING.md

## A Note About Technical Freshness

I should also be clear about my own background. I used supercomputers seriously until around 2015, but I have not been a heavy production HPC user in recent years.

That means some parts of the material may reflect older assumptions about supercomputer environments, job schedulers, compilers, MPI implementations, or common workflows. The fundamentals of MPI, OpenMP, domain decomposition, and SIMD are still useful, but some operational details may deserve updates.

If you work with modern HPC systems and notice outdated descriptions, I would be grateful for corrections.

## Links

- English version: https://kaityo256.github.io/sevendayshpc/en/
- Japanese version: https://kaityo256.github.io/sevendayshpc/ja/
- GitHub repository: https://github.com/kaityo256/sevendayshpc

I hope this is useful for students, researchers, and programmers who want a first hands-on introduction to HPC programming.
