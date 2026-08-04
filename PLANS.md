# Astro Starlight移行計画

## 1. 目的と基本方針

Web版をPandocによるHTML直接生成からAstro Starlightへ移行し、完全な英語版を追加する。生成した静的サイトは`docs/`へ出力し、事前チェックに合格したものだけをGitHub ActionsからGitHub Pagesへデプロイする。

本移行では以下を確定事項とする。

- 日本語Markdownと英語Markdownを、それぞれ独立した正本として管理する。
- 初回の英訳は日本語Markdownを原文とする。
- 公開URLには常に言語コードを含め、`/ja/`と`/en/`を使用する。
- サイトルート`/sevendayshpc/`は言語選択ページにする。
- 日英で対応するページは同じルート名を使用する。
- 英語画像が未作成の場合は日本語画像を表示する。
- 英語画像はMarkdownのリンクを変えずに順次差し替えられるようにする。
- Astroの本番出力先は`docs/`とする。
- `docs/`は生成物としてGit管理しない。
- GitHub PagesのSourceは「GitHub Actions」に設定し、ワークフローが`docs/`をPages artifactとしてアップロードする。ブランチの`/docs`を直接公開する方式は使用しない。
- Re:VIEWは日本語PDFの生成にのみ使用し、英語PDFは作成しない。
- C++サンプルと既存のビルド動作はWeb移行によって変更しない。

英語題名は暫定的に **Become an HPC Programmer in Seven Days!** とし、英語トップページ確定前に最終確認する。

## 2. 目標ディレクトリ構成

```text
.
├── astro.config.mjs
├── package.json
├── package-lock.json
├── tsconfig.json
├── PLANS.md
├── src/
│   ├── content.config.ts
│   ├── content/
│   │   └── docs/
│   │       ├── ja/
│   │       │   ├── index.md
│   │       │   ├── preface/index.md
│   │       │   ├── day1/index.md
│   │       │   ├── ...
│   │       │   ├── day7/index.md
│   │       │   └── postface/index.md
│   │       └── en/
│   │           ├── index.md
│   │           ├── preface/index.md
│   │           ├── day1/index.md
│   │           ├── ...
│   │           ├── day7/index.md
│   │           └── postface/index.md
│   ├── pages/
│   │   └── index.astro
│   └── styles/
│       └── custom.css
├── site-assets/
│   └── images/
│       └── en/                 # 作成済みの英語画像だけを置く
├── tools/
│   ├── prepare-public.mjs
│   └── check-site.mjs
├── .generated/
│   └── public/                 # 自動生成するpublicDir（Git管理外）
├── docs/                       # Astro出力（Git管理外、デプロイ対象）
├── day1/, ..., day7/           # 既存プログラムと日本語画像
├── preface/, postface/         # 既存の日本語画像
├── review/                     # 日本語PDF生成環境
└── .github/workflows/pages.yml
```

既存の章ディレクトリは、プログラム、CMake設定、データ、グラフ、PowerPoint原稿、日本語PNGの保管場所として維持する。MarkdownだけをStarlightのコンテンツコレクションへ移動する。

## 3. Astroとコンテンツの移行

### 3.1 Starlight設定

- `site`を`https://kaityo256.github.io`、`base`を`/sevendayshpc`に設定する。
- `ja`と`en`をlocaleとして登録し、日本語をフォールバック元にする。
- どちらも明示的な言語パス配下に生成し、一方を言語コードなしのroot localeにはしない。
- `/`には`/ja/`と`/en/`へのリンクを持つ言語選択ページを置く。
- サイドバーは「はじめに、Day 1〜Day 7、おわりに」の順に固定する。
- 検索、前後ページ移動、コードハイライトを有効にする。
- Remark/Rehypeプラグインを使用し、既存のインライン`$...$`とブロック`$$...$$`をMathJaxまたはKaTeXで表示する。
- `outDir`を`docs/`、`publicDir`を`.generated/public/`に設定する。

### 3.2 日本語原稿

- ルート、preface、Day 1〜Day 7、postfaceのMarkdownを`src/content/docs/ja/`へ移行する。公開切り替えまでは既存Markdownも残す。
- 各ページに`title`、`description`、サイドバー順序・表示名のfrontmatterを追加する。
- Starlightのタイトルと重複する先頭の`#`見出しは削除する。
- 章間リンクを新しいルートに合わせる。
- 文章、数式、コードブロック、実行結果、参考文献、キャプションは、表示上必要な修正を除いて維持する。
- Pandoc固有の指定と、生成済みHTMLを前提とした記述を除去する。
- Re:VIEWは既存の日本語Markdownを入力元としたまま維持する。Astro移行の公開確認後、正本の重複を解消する段階で入力経路を改めて検討する。

### 3.3 英語原稿

- すべての日本語ページに一対一で対応する英語Markdownを作成する。
- 見出し、本文、キャプション、altテキスト、ナビゲーション文言、注記、本文中の説明コメントを英訳する。
- コマンド、プログラム出力、API名、識別子、数式、ソースコードの意味は変更しない。
- HPC分野で一般的な英語表現を統一して使用する。
- 日本語だけの参考リンクは、信頼できる英語版が存在すれば差し替える。相当する資料がなければ原典を維持する。
- 共有サンプルコードは言語非依存とする。共有ファイル内の日本語コメントは必要に応じて英語化するが、動作と出力は変えない。
- 英語用Re:VIEW設定や英語PDFターゲットは追加しない。

初期用語表：

| 日本語 | 英語 |
|---|---|
| スパコン | supercomputer / HPC system（文脈で選択） |
| 自明並列 | embarrassingly parallel |
| 馬鹿パラ | embarrassingly parallel（日本語の通称は初出時だけ説明） |
| 領域分割 | domain decomposition |
| のりしろ | halo / ghost region |
| 並列化効率 | parallel efficiency |
| 時間発展 | time integration / time evolution（文脈で選択） |

## 4. 画像とダウンロード可能なサンプル

- `tools/prepare-public.mjs`が開発・本番ビルド前に`.generated/public/`を構築する。
- 各章の`fig/`にある日本語画像を`.generated/public/ja/<chapter>/fig/`へコピーする。
- 英語用画像は、まず日本語画像一式を`.generated/public/en/<chapter>/fig/`へコピーし、その後`site-assets/images/en/<chapter>/`に存在する同名ファイルで上書きする。
- 日本語Markdownは常に`/sevendayshpc/ja/<chapter>/fig/<file>`を参照する。
- 英語Markdownは常に`/sevendayshpc/en/<chapter>/fig/<file>`を参照する。英語画像を追加してもMarkdownは変更しない。
- 画像内の文字が日本語の間も、英語Markdownのaltテキストは最初から英訳する。
- 本文からリンクするプログラムなどは、章ごとの公開ディレクトリへコピーする。
- PowerPointは画像の編集元として保持し、従来から意図的に公開している場合を除いてWebの配布対象にはしない。

## 5. ローカルコマンドと事前チェック

以下のnpm scriptsを用意する。

```text
npm run dev          アセットを準備してローカル開発サーバーを起動
npm run build        アセットを準備してdocs/を生成
npm run preview      生成済みdocs/をローカル表示
npm run check        デプロイ前の必須チェックをすべて実行
npm run check:astro  Astroの型・コンテンツ検証
npm run check:site   生成サイトと内部参照の検証
```

`npm run check`は以下を検出した場合に失敗させる。

- Astro設定またはfrontmatterが不正
- 必須の日英ページが不足
- 日英のルート構成が不一致
- ローカル画像、配布ファイル、CSS、JavaScriptが不足
- 生成HTML内の内部リンクまたはフラグメントリンク切れ
- `lang`指定またはlocaleパスが不正
- 対応言語への切り替え先が不足
- Astro本番ビルドの失敗
- 生成対象ページまたは公開アセットが不足している

外部HTTPリンクは相手サイトの障害で不安定になるため、コミットごとの必須チェックにはしない。外部リンク検査は別コマンドまたは定期実行の非ブロッキングなワークフローにする。

Pandoc版を削除する前に、Day 1、Day 5、Day 7を代表ページとして次を比較する。

- 見出しと章内目次
- C++、shell、diff、Ruby、assemblyのコードブロック
- インライン数式とブロック数式
- 横幅の広い画像とモバイル表示
- 章内・章間リンクとソースコードのダウンロード
- 日本語検索と英語検索
- 同じ章を保った言語切り替え

## 6. GitHub Actionsによるデプロイ

`.github/workflows/pages.yml`にbuild jobとdeploy jobを分けて定義する。

Pull Requestおよびpushでは次を実行する。

1. リポジトリをcheckoutする。
2. npm cacheを有効にしてNode.js 22をセットアップする。
3. `npm ci`を実行する。
4. `npm run check`を実行する。
5. 全チェック成功後に`docs/`をGitHub Pages artifactとしてアップロードする。

デフォルトブランチへのpush時だけ、続けて公式Pages Actionでartifactをデプロイする。

追加要件：

- デフォルトブランチ向けPull Requestでチェックを実行する。
- デフォルトブランチへのpushと手動実行でデプロイ可能にする。
- 権限は必要なjobに限り`contents: read`、`pages: write`、`id-token: write`を付与する。
- `github-pages` environmentとPages用concurrencyを使用する。
- Pull Requestからはデプロイしない。
- 公式Actionは確認済みmajor versionへ固定し、Dependabotで更新を提案させる。
- Repository Settings > Pages > Sourceを「GitHub Actions」に変更する。

## 7. 実施順序

1. **Astro基盤**：設定、コンテンツスキーマ、言語選択ページ、CSS、アセット準備処理、最小限の日本語ページを追加する。
2. **日本語移行**：全Markdownを移動して表示を確認し、Re:VIEWの入力経路を更新する。
3. **アセット整備**：言語別画像と配布ファイルを生成し、英語側の日本語画像フォールバックを確認する。
4. **英語版作成**：トップ、preface、Day 1〜Day 7、postfaceを章ごとに翻訳・技術レビューする。
5. **事前チェック**：Astro検証、日英ルート一致、アセット、生成サイトの内部リンク検証を実装する。
6. **Pages workflow**：Pull Requestではビルドと検査、デフォルトブランチではデプロイまで実行する。
7. **公開切り替え**：preview確認後にマージし、Pages SourceをGitHub Actionsへ変更して、`/`、`/ja/`、`/en/`、代表章、画像、ダウンロードを確認する。
8. **旧Web生成の撤去**：Starlight版の公開確認後に、コミット済みPandoc HTML、Pandocテンプレート、不要なMakefileのWebターゲットを削除する。日本語PDFで必要なものは残す。

## 8. 完了条件

- `/sevendayshpc/`で言語を選択できる。
- `/sevendayshpc/ja/`に完全な日本語Web版がある。
- `/sevendayshpc/en/`に完全な英語Web版がある。
- 全ページで同じ章の対応言語へ切り替えられる。
- 既存画像がすべて表示され、未翻訳の英語画像は日本語画像へフォールバックし、英語altテキストを持つ。
- 数式、コードブロック、内部リンク、プログラムのダウンロードが動作する。
- clean checkoutから`npm ci && npm run check`が成功する。
- Pull Requestではチェックだけが実行され、デプロイされない。
- デフォルトブランチへのpushで`docs/`がGitHub Actionsからデプロイされる。
- 公開サイトがPCとモバイルの手動スモークテストに合格する。
- 既存の日本語PDF生成を維持し、英語PDFは生成しない。
