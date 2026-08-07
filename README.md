# Become an HPC Programmer in Seven Days!

[日本語版](README.ja.md)

This is an online learning resource for parallel programming on supercomputers and HPC systems. It covers MPI, OpenMP, and SIMD over a seven-day course, and is published in both Japanese and English.

- [Japanese version](https://kaityo256.github.io/sevendayshpc/ja/)
- [English version](https://kaityo256.github.io/sevendayshpc/en/)

## Contents

1. Environment setup
2. Using a supercomputer
3. Embarrassingly parallel computation
4. Nontrivial parallelism with domain decomposition
5. Two-dimensional reaction-diffusion equations
6. Hybrid parallel programming
7. SIMD optimization

Example programs and CMake settings are under `examples/`. The web edition source documents are under `src/content/docs/ja/` and `src/content/docs/en/`. Site assets are managed under `site-assets/`.

## Development

Install dependencies:

```sh
npm ci
```

Run the site checks and build:

```sh
npm run check
```

If you have an MPI development environment, build the C++ examples with:

```sh
cmake -S . -B build
cmake --build build
```

See [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes.

## License

Copyright (C) 2018-present Hiroshi Watanabe

Text and figures, including PowerPoint files, are distributed under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

Programs in this repository are distributed under the [MIT License](LICENSE).
