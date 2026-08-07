# Contributing

Thank you for your interest in improving *Become an HPC Programmer in Seven Days!* This repository contains the source for the Japanese and English web editions, together with the example programs used in the material.

## What to Contribute

Useful contributions include:

- Corrections and improvements to the English documentation in `src/content/docs/en/`
- Corrections and improvements to the Japanese documentation in `src/content/docs/ja/`
- Translation improvements between the Japanese and English editions
- Fixes to the C++ examples in `examples/`
- Improvements to the site build, validation, or development tooling

Please keep pull requests focused. Small changes are easier to review and merge.

## Documentation and Translation

The Japanese and English documents are maintained as separate source texts. Do not mechanically overwrite one language from the other. When updating translated content, preserve any intentional differences in wording, examples, or explanation unless the change is meant to remove that difference.

For technical content, preserve the meaning of:

- Source code
- Command lines and command output
- API names and identifiers
- Mathematical formulas
- MPI, OpenMP, SIMD, compiler, and system-specific terminology

For translation changes, please describe whether the pull request corrects meaning, improves style, or synchronizes content with the other language.

## Example Code

Example programs are teaching material. Prefer clarity over unnecessary abstraction, and avoid changes that obscure the MPI, OpenMP, SIMD, or HPC concept being demonstrated.

For code changes, describe any change in behavior, output, compiler requirements, MPI behavior, OpenMP assumptions, or SIMD assumptions.

## Development Setup

This project uses Node.js for the documentation site. The required Node.js version is declared in `package.json`.

Install dependencies with:

```sh
npm ci
```

Run the full site check with:

```sh
npm run check
```

If you modify C++ examples and have an MPI development environment available, also build the examples:

```sh
cmake -S . -B build
cmake --build build
```

Run the relevant example programs when the change affects runtime behavior.

## Generated Files

Do not commit generated output directories such as `docs/` or `.generated/`.

Only update `package-lock.json` when dependency changes require it.

## Pull Request Checklist

Before opening a pull request, please check that:

- The change is limited to one clear purpose
- `npm run check` passes
- C++ examples build if you changed files under `examples/`
- Documentation changes preserve technical meaning
- Translation changes explain their intent
- Generated output directories are not included

## Copyright and License

By submitting text contributions to this repository, you assign the copyright in the submitted text to Hiroshi Watanabe. The assigned text will be distributed under the Creative Commons Attribution 4.0 International License.

Code contributions are provided under the repository's MIT License unless otherwise agreed in writing.
