# [一週間でなれる！スパコンプログラマ](https://kaityo256.github.io/sevendayshpc/)

[リポジトリ(kaityo256/sevendayshpc)](https://github.com/kaityo256/sevendayshpc)

[HTML版](https://kaityo256.github.io/sevendayshpc/)

[一括PDF版](sevendayshpc.pdf)

## [はじめに](preface/README.md)

* なぜスパコンを使うのか

## Day 1 : [環境構築](day1/README.md)

とりえあず手元のPCでMPIが使える環境を整え、簡単なMPIプログラミングを試してみる。

* MPIとは
* 余談：MPIは難しいか
* MPIのインストール
* はじめてのMPI
* ランク
* 標準出力について
* GDBによるMPIプログラムのデバッグ

## Day 2 : [スパコンの使い方](day2/README.md)

スパコンを使うときに知っておきたいこと。ジョブの投げ方など。

* はじめに
* スパコンとは
* 余談：BlueGene/Lのメモリエラー
* スパコンのアカウントの取得方法
* ジョブの実行の仕組み
* ジョブスクリプトの書き方
* フェアシェア
* バックフィル
* チェーンジョブ
* ステージング
* 並列ファイルシステム

## Day 3 : [自明並列](day3/README.md)

自明並列、通称「馬鹿パラ」のやり方について。

* 自明並列、またの名を馬鹿パラとは
* 自明並列の例1: 円周率
* 自明並列テンプレート
* 自明並列の例2: 多数のファイル処理
* 自明並列の例3: 統計処理
* 並列化効率
* サンプル並列とパラメタ並列の違い

## Day 4 : [領域分割による非自明並列](day4/README.md)

非自明並列の例として、一次元熱伝導方程式方程式を領域分割してみる。

* 非自明並列
* 一次元拡散方程式 (シリアル版)
* 一次元拡散方程式 (並列版)
* 余談： EagerプロトコルとRendezvousプロトコル

## Day 5 : [二次元反応拡散方程式](day5/README.md)

本格的なMPIプログラムの例として、二次元反応拡散方程式を領域分割してみる。

* シリアル版
* 並列化ステップ1: 通信の準備など
* 並列化ステップ2: データの保存
* 並列化ステップ2: のりしろの通信
* 並列化ステップ3: 並列コードの実装
* 余談：MPIの面倒くささ

## Day 6 : [ハイブリッド並列](day6/README.md)

プロセス並列とスレッド並列の併用によるハイブリッド並列化について。
特にスレッド並列で気をつけたいことなど。

* ハイブリッド並列とは
* 仮想メモリとTLB
* 余談：TLBミスについて
* NUMA
* OpenMPの例
* 性能評価
* 余談：ロックの話
* ハイブリッド並列の実例

## Day 7 : [SIMD化](day7/README.md)

SIMD化について。

* はじめに
* SIMDとは
* SIMDレジスタを触ってみる
* 余談：アセンブリ言語？アセンブラ言語？
* 簡単なSIMD化の例
* 余談：x86における浮動小数点演算の扱い
* もう少し実戦的なSIMD化

## [おわりに](conclusion/README.md)

## ライセンス

Copyright (C) 2018-present Hiroshi Watanabe

この文章と絵(pptxファイルを含む)はクリエイティブ・コモンズ 4.0 表示 (CC-BY 4.0)で提供する。

This article and pictures are licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

本リポジトリに含まれるプログラムは、[MITライセンス](https://opensource.org/licenses/MIT)で提供する。

The source codes in this repository are licensed under [the MIT License](https://opensource.org/licenses/MIT).

なお、HTML版の作成に際し、CSSとして[github-markdown-css](https://github.com/sindresorhus/github-markdown-css)を利用しています。
