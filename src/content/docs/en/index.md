---
title: Become an HPC Programmer in Seven Days!
description: A seven-day introduction to MPI, OpenMP, SIMD, and supercomputer programming
sidebar:
  order: 1
  label: Home
---

[Repository (kaityo256/sevendayshpc)](https://github.com/kaityo256/sevendayshpc)

## [Preface](preface/)

- Why use a supercomputer?

## Day 1: [Setting Up Your Environment](day1/)

Set up an environment where you can use MPI on your own computer and try some simple MPI programs.

- What is MPI?
- Aside: Is MPI difficult?
- Installing MPI
- Your first MPI program
- Ranks
- Standard output
- Debugging MPI programs with GDB

## Day 2: [Using a Supercomputer](day2/)

Learn what you need to know when using a supercomputer, including how to submit jobs.

- Introduction
- What is a supercomputer?
- Aside: Memory errors on Blue Gene/L
- Obtaining a supercomputer account
- How job execution works
- Writing job scripts
- Fair share
- Backfilling
- Chained jobs
- Staging
- Parallel file systems

## Day 3: [Embarrassingly Parallel Workloads](day3/)

Learn how to implement embarrassingly parallel workloads.

- What is embarrassingly parallel computing?
- Example 1: Calculating pi
- An embarrassingly parallel template
- Example 2: Processing many files
- Example 3: Statistical processing
- Parallel efficiency
- Sample parallelism versus parameter parallelism

## Day 4: [Nontrivial Parallelism with Domain Decomposition](day4/)

As an example of nontrivial parallelism, decompose the domain of a one-dimensional heat equation.

- Nontrivial parallelism
- One-dimensional diffusion equation: serial version
- One-dimensional diffusion equation: parallel version
- Aside: Eager and rendezvous protocols

## Day 5: [Two-Dimensional Reaction-Diffusion Equation](day5/)

As a full-scale MPI programming example, decompose the domain of a two-dimensional reaction-diffusion equation.

- Serial version
- Parallelization step 1: Preparing communication
- Parallelization step 2: Saving data
- Parallelization step 2: Exchanging halo regions
- Parallelization step 3: Implementing the parallel code
- Aside: The inconvenience of MPI

## Day 6: [Hybrid Parallelism](day6/)

Learn hybrid parallelization using both process and thread parallelism, with particular attention to pitfalls in threaded programs.

- What is hybrid parallelism?
- Virtual memory and the TLB
- Aside: TLB misses
- NUMA
- An OpenMP example
- Performance evaluation
- Aside: Locks
- A practical example of hybrid parallelism

## Day 7: [SIMD Vectorization](day7/)

Learn about SIMD vectorization.

- Introduction
- What is SIMD?
- Working directly with SIMD registers
- Aside: “Assembly language” or “assembler language”?
- A simple SIMD example
- Aside: Floating-point operations on x86
- A more practical SIMD example

## [Postface](postface/)

## License

Copyright (C) 2018-present Hiroshi Watanabe

This text and its illustrations, including the PowerPoint files, are licensed under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

The source code in this repository is licensed under the [MIT License](https://opensource.org/licenses/MIT).

The HTML edition uses [github-markdown-css](https://github.com/sindresorhus/github-markdown-css) for styling.
