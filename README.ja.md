# 一週間でなれる！スパコンプログラマ

[English version](README.md)

MPI、OpenMP、SIMDを題材に、スーパーコンピュータ向け並列プログラミングを7日間で学ぶためのオンライン教材です。日本語版と英語版を公開しています。

- [日本語版](https://kaityo256.github.io/sevendayshpc/ja/)
- [English version](https://kaityo256.github.io/sevendayshpc/en/)

## 内容

1. 環境構築
2. スパコンの使い方
3. 自明並列
4. 領域分割による非自明並列
5. 二次元反応拡散方程式
6. ハイブリッド並列
7. SIMD化

各章のサンプルプログラムとCMake設定は `examples/`、Web版の原稿は `src/content/docs/ja/` と `src/content/docs/en/`、図版は `site-assets/` で管理しています。

## 開発

依存関係をインストールします。

```sh
npm ci
```

サイトのチェックとビルドを実行します。

```sh
npm run check
```

MPI開発環境がある場合、C++サンプルは次のようにビルドできます。

```sh
cmake -S . -B build
cmake --build build
```

寄稿については [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## ライセンス

Copyright (C) 2018-present Hiroshi Watanabe

文章と図版（PowerPointファイルを含む）は [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/) で提供します。

本リポジトリに含まれるプログラムは [MIT License](LICENSE) で提供します。
