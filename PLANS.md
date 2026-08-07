# Astro Starlight構成・運用方針

## 1. 目的と基本方針

Web版はPandocによるHTML直接生成からAstro Starlightへ移行済みで、日本語版と英語版を提供している。生成した静的サイトは`docs/`へ出力し、事前チェックに合格したものだけをGitHub ActionsからGitHub Pagesへデプロイする。

本移行では以下を確定事項とする。

- 日本語Markdownと英語Markdownを、それぞれ独立した正本として管理する。
- 初回の英訳は日本語Markdownを原文とする。
- 公開URLには常に言語コードを含め、`/ja/`と`/en/`を使用する。
- サイトルート`/sevendayshpc/`は言語選択ページにする。
- 日英で対応するページは同じルート名を使用する。
- 英語画像が未作成の場合は日本語画像を表示する。
- 英語画像はMarkdownのリンクを変えずに順次差し替えられるようにする。
- 図版の英訳は、PowerPointから対訳表を作成して人間が確認した後、英語スライドへ反映する二段階方式とする。
- Astroの本番出力先は`docs/`とする。
- `docs/`は生成物としてGit管理しない。
- GitHub PagesのSourceは「GitHub Actions」に設定し、ワークフローが`docs/`をPages artifactとしてアップロードする。ブランチの`/docs`を直接公開する方式は使用しない。
- C++サンプルは`examples/`で管理し、ルートのCMakeプロジェクトから一括ビルドできる状態を維持する。

英語題名は **Become an HPC Programmer in Seven Days!** とする。

## 2. ディレクトリ構成

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
├── examples/
│   ├── day1/                   # C++、CMake設定、データなど
│   ├── day3/
│   ├── ...
│   └── day7/
├── site-assets/
│   ├── images/
│   │   ├── ja/                 # 日本語PNGの正本
│   │   └── en/                 # 作成済みの英語画像だけを置く
│   └── sources/
│       ├── day1/
│       │   ├── fig-ja-en.pptx  # 日本語・英語図版の編集元
│       │   └── translations.csv
│       ├── day2/
│       │   ├── fig-ja-en.pptx
│       │   └── translations.csv
│       ├── ...
│       ├── day7/
│       │   ├── fig-ja-en.pptx
│       │   └── translations.csv
│       ├── translations-all.csv
│       └── translation-report.md
├── tools/
│   ├── prepare-public.mjs
│   ├── check-site.mjs
│   ├── extract-pptx-translations.py
│   └── apply-pptx-translations.py
├── .generated/
│   └── public/                 # 自動生成するpublicDir（Git管理外）
├── docs/                       # Astro出力（Git管理外、デプロイ対象）
└── .github/workflows/pages.yml
```

日本語Markdownは`src/content/docs/ja/`、英語Markdownは`src/content/docs/en/`を正本とする。共有サンプルは`examples/`、公開画像は`site-assets/images/`、画像の編集元と対訳表は`site-assets/sources/`で役割別に管理する。

各章の`translations.csv`は、PowerPoint内の各テキストと英訳案の対応を管理する正本とする。全章をまとめた`translations-all.csv`は確認用の集約ファイルとし、章ごとのCSVと内容が矛盾しないようにする。

## 3. Astroとコンテンツ

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

- ルート、preface、Day 1〜Day 7、postfaceのMarkdownを`src/content/docs/ja/`へ移行し、これを日本語原稿の正本とする。
- 各ページに`title`、`description`、サイドバー順序・表示名のfrontmatterを追加する。
- Starlightのタイトルと重複する先頭の`#`見出しは削除する。
- 章間リンクを新しいルートに合わせる。
- 文章、数式、コードブロック、実行結果、参考文献、キャプションは、表示上必要な修正を除いて維持する。
- Pandoc固有の指定と、生成済みHTMLを前提とした記述を除去する。

### 3.3 英語原稿

- すべての日本語ページに一対一で対応する英語Markdownを作成する。
- 初回英訳は日本語Markdownを原文とするが、英語Markdownに読者層・文化的前提・最新事情に合わせた意図的な修正が加えられた場合は、その英語Markdownを当該箇所の優先版として扱う。
- 日本語Markdownを更新して英語Markdownへ反映する際は、既存の英語Markdownを機械的に上書きしない。英語側に日本語版との差分がある箇所は、差分の意図を確認し、英語版の修正を保持したうえで必要な更新だけを反映する。
- 見出し、本文、キャプション、altテキスト、ナビゲーション文言、注記、本文中の説明コメントを英訳する。
- コマンド、プログラム出力、API名、識別子、数式、ソースコードの意味は変更しない。
- HPC分野で一般的な英語表現を統一して使用する。
- 日本語だけの参考リンクは、信頼できる英語版が存在すれば差し替える。相当する資料がなければ原典を維持する。
- 共有サンプルコードは言語非依存とする。共有ファイル内の日本語コメントは必要に応じて英語化するが、動作と出力は変えない。
- 英語PDFターゲットは追加しない。

初期用語表：

| 日本語     | 英語                                                    |
| ---------- | ------------------------------------------------------- |
| スパコン   | supercomputer / HPC system（文脈で選択）                |
| 自明並列   | embarrassingly parallel                                 |
| 馬鹿パラ   | embarrassingly parallel（日本語の通称は初出時だけ説明） |
| 領域分割   | domain decomposition                                    |
| のりしろ   | halo / ghost region                                     |
| 並列化効率 | parallel efficiency                                     |
| 時間発展   | time integration / time evolution（文脈で選択）         |

本文と図版で同じ専門用語が現れる場合は、英語Markdownで採用した訳語を図版の対訳表でも優先し、表記を統一する。

## 4. 画像とダウンロード可能なサンプル

### 4.1 公開画像の配置

- `tools/prepare-public.mjs`が開発・本番ビルド前に`.generated/public/`を構築する。
- `site-assets/images/ja/<chapter>/`にある日本語画像を`.generated/public/ja/<chapter>/fig/`へコピーする。
- 英語用画像は、まず日本語画像一式を`.generated/public/en/<chapter>/fig/`へコピーし、その後`site-assets/images/en/<chapter>/`に存在する同名ファイルで上書きする。
- 日本語Markdownは常に`/sevendayshpc/ja/<chapter>/fig/<file>`を参照する。
- 英語Markdownは常に`/sevendayshpc/en/<chapter>/fig/<file>`を参照する。英語画像を追加してもMarkdownは変更しない。
- 画像内の文字が日本語の間も、英語Markdownのaltテキストは最初から英訳する。
- `examples/<chapter>/`にあるプログラムなどは、章ごとの公開ディレクトリへコピーする。
- PowerPointなどの編集元は`site-assets/sources/<chapter>/`に保持し、Webの配布対象にはしない。

### 4.2 PowerPoint図版の管理

`site-assets/sources/day1/`から`site-assets/sources/day7/`までの各ディレクトリに、日本語・英語図版の編集元である`fig-ja-en.pptx`を置き、これをPowerPoint図版の正本とする。

```text
site-assets/sources/
├── day1/fig-ja-en.pptx
├── day2/fig-ja-en.pptx
├── day3/fig-ja-en.pptx
├── day4/fig-ja-en.pptx
├── day5/fig-ja-en.pptx
├── day6/fig-ja-en.pptx
└── day7/fig-ja-en.pptx
```

各`fig-ja-en.pptx`では、原則として日本語スライドと対応する英語スライドを連続して配置し、1スライドを1図に対応させる。

英語図版の作成は、次の二段階で行う。

1. PowerPointから日本語テキストを抽出し、英訳案を含む対訳表を作成する。
2. 人間が対訳表を確認して承認した後、各日本語スライドの直後に英語スライドを追加する。

第1段階ではPowerPointを変更しない。対訳表の確認前に、スライドの複製、英訳の反映、並べ替え、再保存を行ってはならない。

### 4.3 対訳表の作成

`tools/extract-pptx-translations.py`は、`day1`から`day7`までの各`fig-ja-en.pptx`を順番に処理し、編集可能な日本語テキストを抽出する。

抽出対象には、少なくとも次を含める。

- テキストボックス
- オートシェイプ内のテキスト
- グループ化された図形内のテキスト
- 表のセル内のテキスト
- プレースホルダー内のテキスト
- 通常の図形として取得可能なグラフタイトル、軸ラベル、凡例
- その他、PowerPoint上で編集可能な文字列

SmartArt、グラフオブジェクト内部、数式オブジェクト、画像内に埋め込まれた文字など、通常の方法で取得できない可能性がある要素は無理にOCRせず、検査レポートへ記録する。

各章について、次のファイルを生成する。

```text
site-assets/sources/day1/translations.csv
site-assets/sources/day2/translations.csv
site-assets/sources/day3/translations.csv
site-assets/sources/day4/translations.csv
site-assets/sources/day5/translations.csv
site-assets/sources/day6/translations.csv
site-assets/sources/day7/translations.csv
```

さらに、全章をまとめた次のファイルを生成する。

```text
site-assets/sources/translations-all.csv
site-assets/sources/translation-report.md
```

CSVはUTF-8で保存する。Excelで確認する可能性を考慮し、必要に応じてUTF-8 BOM付きとする。

CSVには、次の列をこの順序で含める。

```csv
day,slide_number,shape_id,shape_name,shape_type,japanese,english,status,notes
```

各列の意味は次のとおりとする。

| 列             | 内容                                                      |
| -------------- | --------------------------------------------------------- |
| `day`          | `day1`から`day7`までのディレクトリ名                      |
| `slide_number` | 1から始まるスライド番号                                   |
| `shape_id`     | PowerPoint内部の図形ID                                    |
| `shape_name`   | PowerPoint内で設定されている図形名                        |
| `shape_type`   | `textbox`、`autoshape`、`table_cell`、`grouped_shape`など |
| `japanese`     | PowerPointから抽出した元の文字列                          |
| `english`      | 日本語に対応する英訳案                                    |
| `status`       | 翻訳の確認状態                                            |
| `notes`        | 翻訳上の注意、曖昧さ、レイアウト上の懸念など              |

初回生成時の`status`は、すべて`draft`とする。

原則として、1つの図形または1つの表セルをCSVの1行とする。ただし、1つの図形に独立した複数のラベルや段落が含まれる場合は、必要に応じて段落単位に分割してよい。

同じ日本語が複数の場所に現れる場合も省略せず、出現位置ごとに別の行として記録する。

### 4.4 図版の翻訳方針

図中の英訳は、科学・技術系のWeb記事に掲載する図版として、簡潔で自然な英語にする。

- 図中のラベルは、原則として簡潔な名詞句にする。
- 説明文は意味を保ちながら自然な英文にする。
- HPC分野で一般的な専門用語を優先する。
- 本文の英語Markdownと用語を統一する。
- 同じ日本語には、原則として同じ英訳を割り当てる。
- 文脈によって訳し分ける場合は、`notes`に理由を書く。
- 日本語の語順を機械的に維持せず、英語として自然な語順にする。
- 英文が日本語より大幅に長くなる場合は、`notes`に`layout check`と記載する。
- 訳語に確信が持てない場合は、`notes`に候補または懸念を記載する。
- 元の改行が表示調整だけを目的とした不自然なものである場合は、英語として自然な位置へ変更してよい。その場合は`notes`に記録する。

以下は原則として翻訳しない。

- 数字
- 数式
- 変数名
- 関数名
- プログラムコード
- URL
- ファイル名
- 単位
- 固有の記号
- すでに英語で書かれている文字列

日本語と数式、変数、英語が混在する場合は、日本語部分だけを翻訳する。

例：

```text
温度 T
```

は次のようにする。

```text
Temperature T
```

「図1」「図2」などの図番号が図版内に含まれる場合は、原則として`Figure 1`、`Figure 2`とする。ただし、英語本文で`Fig. 1`形式を採用している場合は本文に合わせる。

### 4.5 対訳表の確認

対訳表を人間が確認するまでは、PowerPointへの反映を行わない。

確認時には、少なくとも次を点検する。

- 英訳が本文の用語と一致している。
- 同じ日本語の訳語が不必要に揺れていない。
- 数式、変数、単位、プログラムコードが変更されていない。
- 専門用語の意味が正しい。
- 英語として不自然な直訳になっていない。
- 英訳が長すぎる項目に`layout check`が付いている。
- 訳が曖昧な項目に説明が付いている。
- 翻訳対象から漏れた日本語がない。
- SmartArt、画像、グラフ、数式などに未抽出の文字がないか目視で確認している。

確認済みの行は、`status`を`approved`に変更する。修正が必要な行は`english`を修正し、必要に応じて`notes`へ理由を記録する。

PowerPoint反映処理は、原則としてすべての翻訳対象行が`approved`になった後に実行する。

### 4.6 英語スライドへの反映

`tools/apply-pptx-translations.py`は、確認済みの対訳表を使用して英語スライドを作成した旧ワークフロー用のスクリプトである。現在は`fig-ja-en.pptx`をPowerPoint図版の正本とし、必要な修正はこのファイルへ反映する。

各`fig-ja-en.pptx`では、元の日本語スライドを維持し、その直後に同じ図の英語版を置く。

変換前：

```text
1ページ目：図1（和文）
2ページ目：図2（和文）
3ページ目：図3（和文）
```

変換後：

```text
1ページ目：図1（和文）
2ページ目：図1（英文）
3ページ目：図2（和文）
4ページ目：図2（英文）
5ページ目：図3（和文）
6ページ目：図3（英文）
```

反映時には、原則として`shape_id`、`shape_name`、図形の位置情報を使用して対象を特定し、単純な文字列一致だけに依存しない。

処理では次を守る。

- 元の日本語スライドを変更しない。
- 画像、図形、位置、サイズ、線、塗り、重なり順を可能な限り維持する。
- 数式、変数名、単位、数字、コードを変更しない。
- `status`が`approved`でない行は反映しない。
- 対訳表に存在しない日本語は変更しない。
- 置換できなかった項目をレポートする。
- 正本を意図せず上書きしない。
- 変換後のPowerPointは別名で保存する。
- 英文が図形からはみ出す場合は、改行、テキスト枠、フォントサイズを調整する。
- フォントサイズを縮小する場合も、原則として元の70%未満にはしない。
- 自動調整で解決できない場合は、レポートへ記録して手動修正対象とする。

出力ファイル名は、原則として次のようにする。

```text
site-assets/sources/day1/fig-ja-en.pptx
site-assets/sources/day2/fig-ja-en.pptx
...
site-assets/sources/day7/fig-ja-en.pptx
```

英語画像を書き出す際は、各英語スライドからPNGを生成し、対応するファイルを`site-assets/images/en/<chapter>/`へ配置する。

PowerPointからPNGへの変換は、PowerPointまたはLibreOfficeなど、レイアウトを十分に維持できる方法を使用する。変換後は日本語版と英語版を目視で比較する。

### 4.7 対訳表作成レポート

`site-assets/sources/translation-report.md`には、少なくとも次を記録する。

1. 各`fig-ja-en.pptx`のスライド数
2. 各ファイルから抽出したテキスト件数
3. 日本語を含む図形の件数
4. 翻訳案を作成した件数
5. 翻訳対象外と判断した件数
6. SmartArt、グラフ、画像、数式など、通常の抽出では確認できなかった可能性がある要素
7. 翻訳が曖昧な項目
8. 英訳が長く、レイアウト確認が必要な項目
9. 同じ日本語に対する訳語の不一致
10. エラーまたは処理できなかったファイル

対訳表の作成完了時には、次を確認する。

- `day1`から`day7`まで、すべての`translations.csv`が存在する。
- `translations-all.csv`が存在する。
- `translation-report.md`が存在する。
- 正本の`fig-ja-en.pptx`が意図しない形で変更されていない。
- CSVが`day`、`slide_number`、`shape_id`の順に並んでいる。
- 初回生成時の全行の`status`が`draft`である。
- `english`が空欄の行には、その理由が`notes`に記載されている。

第1段階の完了条件は、次のファイルが揃い、PowerPointが未変更のままであることとする。

```text
site-assets/sources/day1/translations.csv
site-assets/sources/day2/translations.csv
site-assets/sources/day3/translations.csv
site-assets/sources/day4/translations.csv
site-assets/sources/day5/translations.csv
site-assets/sources/day6/translations.csv
site-assets/sources/day7/translations.csv
site-assets/sources/translations-all.csv
site-assets/sources/translation-report.md
```

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

PowerPoint図版の作業には、必要に応じて次のコマンドを追加する。

```text
npm run figures:extract   PowerPointから対訳表と検査レポートを作成
npm run figures:check     対訳表の形式、承認状態、用語の揺れを検査
npm run figures:apply     承認済みの対訳表を英語スライドへ反映
```

Pythonスクリプトをnpm scriptsから呼び出す場合も、実体は`tools/`以下に置く。

`npm run figures:extract`は元のPowerPointを変更してはならない。

`npm run figures:apply`は、未承認の行が存在する場合、または対訳表とPowerPointの図形情報が一致しない場合に失敗させる。

`npm run check`は以下を検出した場合に失敗する。

- Astro設定またはfrontmatterが不正
- 必須の日英ページが不足
- 日英のルート構成が不一致
- ローカル画像、配布ファイル、CSS、JavaScriptが不足
- 生成HTML内の内部リンク先ファイルの不足
- `lang`指定またはlocaleパスが不正
- Astro本番ビルドの失敗
- 生成対象ページまたは公開アセットが不足している

図版翻訳を必須チェックへ含める段階では、さらに次を検出する。

- `day1`から`day7`までの`fig-ja-en.pptx`または対訳表の不足
- 対訳表の必須列の不足
- 不正な`status`
- 同じ図形を示す行の重複
- `approved`であるにもかかわらず英訳が空欄
- 同じ日本語に対する意図しない訳語の揺れ
- 英語画像を作成済みとしている章で、必要な画像が不足

フラグメントリンクのID、言語切り替えUIの対応先、外部HTTPリンクは現在の自動検査の対象外とする。外部リンクは相手サイトの障害で不安定になるため、コミットごとの必須チェックには含めない。

表示確認ではDay 1、Day 5、Day 7を代表ページとして次を確認する。

- 見出しと章内目次
- C++、shell、diff、Ruby、assemblyのコードブロック
- インライン数式とブロック数式
- 横幅の広い画像とモバイル表示
- 章内・章間リンクとソースコードのダウンロード
- 日本語検索と英語検索
- 同じ章を保った言語切り替え
- 日本語図版と英語図版の対応
- 英語図版内の文字切れ、重なり、不自然な改行
- 数式、変数、単位、矢印、線、色、配置が日本語版から変化していないこと

## 6. GitHub Actionsによるデプロイ

`.github/workflows/pages.yml`にbuild jobとdeploy jobを分けて定義する。

Pull Request、push、手動実行では次を実行する。

1. リポジトリをcheckoutする。
2. npm cacheを有効にしてNode.js 22をセットアップする。
3. `npm ci`を実行する。
4. `npm run check`を実行する。
5. Pull Request以外では、全チェック成功後に`docs/`をGitHub Pages artifactとしてアップロードする。

デフォルトブランチへのpushおよび手動実行では、続けて公式Pages Actionでartifactをデプロイする。

追加要件：

- デフォルトブランチ向けPull Requestでチェックを実行する。
- デフォルトブランチへのpushと手動実行でデプロイ可能にする。
- 権限は必要なjobに限り`contents: read`、`pages: write`、`id-token: write`を付与する。
- `github-pages` environmentとPages用concurrencyを使用する。
- Pull Requestからはデプロイしない。
- 公式Actionは確認済みmajor versionへ固定し、Dependabotで更新を提案させる。
- Repository Settings > Pages > Sourceは「GitHub Actions」に設定済みである。

PowerPointの対訳表作成や英語スライド生成は、通常のPagesデプロイ時には実行しない。図版の翻訳・確認・反映は明示的なローカル作業として行い、確認済みの英語PNGだけを通常のサイトビルドで使用する。

## 7. 実施状況

以下は実施済みである。

1. **Astro基盤**：設定、コンテンツスキーマ、言語選択ページ、CSS、アセット準備処理を追加した。
2. **日英原稿**：トップ、preface、Day 1〜Day 7、postfaceを日英それぞれの正本として配置した。
3. **アセット整備**：共有サンプル、日本語画像、英語画像、画像編集元を役割別に分離し、英語側の日本語画像フォールバックを実装した。
4. **事前チェック**：Astro検証、日英ページ構成、アセット、生成サイトの内部参照検査を実装した。
5. **Pages workflow**：Pull Requestではビルドと検査、デフォルトブランチへのpushと手動実行ではデプロイまで行う構成にした。
6. **公開切り替え**：Pages SourceをGitHub Actionsへ変更し、言語選択ページ、日本語版、英語版を公開した。
7. **旧生成系の撤去**：Pandoc HTML、Pandocテンプレート、旧Makefile、旧PDF生成環境を削除した。
8. **サンプルビルド**：CMake、GCC、OpenMPI、OpenMPを使用して全ターゲットのビルド成功を確認した。
9. **図版テキストの抽出**：`day1`から`day7`までの`fig-ja-en.pptx`から日本語テキストを抽出し、章別`translations.csv`、`translations-all.csv`、`translation-report.md`を作成した。
10. **図版対訳の確認**：対訳表を確認し、全翻訳行の`status`を`approved`へ変更した。
11. **英語スライドの生成**：`tools/apply-pptx-translations.py`により、各日本語スライドの直後に英語版を追加した`fig-ja-en.pptx`を`day1`から`day7`まで作成した。
12. **英語スライドの機械検査**：英語スライドに抽出可能な日本語が残っていないこと、スライド数が元の2倍であることを確認した。さらに`tools/check-fix-pptx-layout.py`でテキスト枠のはみ出しリスクと重なりを検査し、可能な範囲でAutoFitとフォントサイズ調整を反映した。
13. **レイアウト未解決項目の記録**：自動修正できない、または目視確認が必要な候補を`site-assets/sources/pptx-layout-issues.md`へ記録した。
14. **図版翻訳の完了**：`day1`から`day7`までの図版翻訳をすべて完了し、英語PNGを`site-assets/images/en/<chapter>/`へ配置した。
15. **図版の手動確認**：PowerPoint上の未解決候補と、PC・モバイル表示での英語画像の文字切れ、配置、数式、線、色を目視確認した。

現時点で、Astro移行、日英Web版、図版翻訳、英語画像生成、手動確認まで完了している。

## 8. 現在の確認項目

自動検査で次を継続して保証する。

- `/sevendayshpc/ja/`と`/sevendayshpc/en/`に必要な全ページが生成される。
- 既存画像が表示され、未翻訳の英語画像は日本語画像へフォールバックする。
- 数式、コードブロック、内部リンク先ファイル、プログラムのダウンロードに必要な公開物が生成される。
- `npm ci && npm run check`が成功する。
- Pull Requestではチェックだけを実行し、デプロイしない。
- デフォルトブランチへのpushと手動実行ではGitHub Actionsからデプロイする。

図版翻訳について、対訳表作成後は次を継続して確認する。

- `day1`から`day7`までの各`fig-ja-en.pptx`に対応する`translations.csv`が存在する。
- `translations-all.csv`と章別CSVの内容が一致する。
- 対訳表の必須列と`status`が正しい。
- 正本の`fig-ja-en.pptx`が対訳表作成処理によって意図せず変更されていない。
- 未承認の翻訳がPowerPointへ反映されていない。
- `fig-ja-en.pptx`に日本語スライドと対応する英語スライドが揃っている。
- 英語スライドに、通常のテキスト抽出で取得できる日本語が残っていない。
- レイアウト検査で自動修正できない項目が`pptx-layout-issues.md`に記録され、手動確認済みである。
- 英語画像が日本語画像の代わりに英語側へ公開される。

次の項目は自動検査では保証せず、必要に応じて手動確認する。

- PCとモバイルでの表示。
- 日本語検索と英語検索の検索品質。
- 同じ章を保った言語切り替え。
- フラグメントリンクと外部HTTPリンク。
- PowerPoint内のSmartArt、画像、グラフ、数式に含まれる未抽出の日本語。
- 英語図版の文字切れ、重なり、フォントサイズ、改行位置。
- 日本語版と英語版の図形、線、矢印、色、数式、変数、単位の一致。
