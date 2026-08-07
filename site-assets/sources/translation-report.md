# Figure Translation Extraction Report

This report was generated from `site-assets/sources/day*/fig-ja-en.pptx`.
The original PowerPoint files were read only and were not modified.

## Summary

| day | slides | text items | Japanese text items | translations | untranslated | layout check |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `day1` | 4 | 42 | 38 | 38 | 0 | 7 |
| `day2` | 8 | 89 | 85 | 85 | 0 | 8 |
| `day3` | 1 | 13 | 12 | 12 | 0 | 2 |
| `day4` | 6 | 85 | 79 | 79 | 0 | 22 |
| `day5` | 6 | 24 | 24 | 24 | 0 | 7 |
| `day6` | 3 | 34 | 10 | 10 | 0 | 4 |
| `day7` | 3 | 73 | 28 | 28 | 0 | 8 |

## Files

- `site-assets/sources/day1/translations.csv`
- `site-assets/sources/day2/translations.csv`
- `site-assets/sources/day3/translations.csv`
- `site-assets/sources/day4/translations.csv`
- `site-assets/sources/day5/translations.csv`
- `site-assets/sources/day6/translations.csv`
- `site-assets/sources/day7/translations.csv`
- `site-assets/sources/translations-all.csv`

## Untranslated Items

- None.

## Layout Check Items

- `day1` slide 2, shape 21: 気軽に試すことができる / 簡単にできる時は簡単
- `day1` slide 2, shape 22: ノードをまたぐことができない / 性能を出すのは意外に大変
- `day1` slide 2, shape 71: 書いた通りに並列化される
- `day1` slide 2, shape 72: 明示的に通信を書かなければならない
- `day1` slide 3, shape 5: あそこで流れてるジョブ、 / 俺のなんすよwww
- `day1` slide 4, shape 6: あそこで流れてるジョブ、 / 俺のなんすよwww
- `day1` slide 4, shape 8: 一週間でなれる！スパコンプログラマ
- `day2` slide 3, shape 6: 大規模計算は大縄跳び
- `day2` slide 3, shape 7: 一人でもこけたら全体が失敗してしまう
- `day2` slide 4, shape 36: 高速ネットワーク / (InfiniBand等)
- `day2` slide 6, shape 7: まず出向先近くのホテルに行く / (ステージイン)
- `day2` slide 6, shape 28: 出向中はホテルと会社の往復 / (ローカルファイルにのみアクセス)
- `day2` slide 6, shape 35: 出向が終わったら家に帰る / (ステージアウト)
- `day2` slide 8, shape 53: 1ノードジョブが実行中 / 4ノードジョブが待っている / その後に短い2ノードジョブが来た
- `day2` slide 8, shape 58: 後から投げられた2ノードジョブが / 前のジョブを追い越して実行される / (バックフィル)
- `day3` slide 1, shape 13: トータルの計算量を固定したまま並列数を増やし、実行時間を短縮する
- `day3` slide 1, shape 14: 並列単位あたりの計算量を固定して並列数を増やし、トータルサイズを稼ぐ
- `day4` slide 1, shape 3: 馬鹿パラは通信がほぼ不要
- `day4` slide 1, shape 59: 初期化以外では通信しない
- `day4` slide 1, shape 60: 馬鹿パラは信頼性が不要
- `day4` slide 1, shape 76: 失敗した計算だけやり直せば良い
- `day4` slide 2, shape 55: 非自明並列 (全体通信)
- `day4` slide 2, shape 56: 非自明並列 (局所通信)
- `day4` slide 2, shape 58: 高速フーリエ変換(FFT)など
- `day4` slide 3, shape 19: 一様加熱 / (固定境界)
- `day4` slide 3, shape 20: 温度固定 / (周期境界)
- `day4` slide 3, shape 21: 棒全体を加熱する / 両端を同じ温度に固定する
- `day4` slide 3, shape 22: リング状の金属の左を高温、右を低温に固定
- `day4` slide 4, shape 24: ある点の、次の時刻の状態を計算するには、 / 両脇の点の情報が必要になる
- `day4` slide 4, shape 58: 「のりしろ」付きで領域分割
- `day4` slide 4, shape 78: まず端の情報を交換
- `day4` slide 4, shape 105: もらった情報をもとに、次の時刻の端の点の状態が計算できる
- `day4` slide 5, shape 2: 並列プログラムのファイルの吐き方
- `day4` slide 5, shape 3: 1. 全プロセス勝手に吐く
- `day4` slide 5, shape 31: ステップ数 x プロセス数の / 大量のファイルが出力される
- `day4` slide 5, shape 60: ファイル出力がまとめて / 一回なので早い
- `day4` slide 6, shape 16: 相手から直接データを受け取る
- `day4` slide 6, shape 23: 決められた場所にデータを置く
- `day4` slide 6, shape 24: 受信側のタイミングで受け取りに行く
- `day5` slide 3, shape 9: 各プロセスは「のりしろ」部分込みの領域を保持する
- `day5` slide 4, shape 96: 「のりしろ」以外のデータを一次元配列に
- `day5` slide 5, shape 355: 自分の左側ののりしろに、左側のプロセスからデータが保存される
- `day5` slide 5, shape 356: 左から受け取り、右に送る通信
- `day5` slide 6, shape 94: 1. 左右の通信が終わった状態
- `day5` slide 6, shape 95: 2. 左右からもらったデータごと / 　上に送る (下からももらう)
- `day5` slide 6, shape 204: 2. 上辺に加え、斜めのデータも / 　送ることができた
- `day6` slide 2, shape 11: 最初に「楽そうだから」と思って / 仕事を引き受けすぎると・・・
- `day6` slide 2, shape 16: いつの間にか「担当者」になって / 大変なことに・・・
- `day6` slide 2, shape 17: この件、君が / 担当って聞いたんで
- `day6` slide 3, shape 4: シングルノード(12コア x 2ソケット)でのスケーリング
- `day7` slide 1, shape 20: 実行ユニットが増えると / 命令振り分けで死ぬ
- `day7` slide 1, shape 21: 命令の後方互換性を保てる
- `day7` slide 1, shape 39: 依存関係チェックが不要 / → ハードウェアが簡単に
- `day7` slide 1, shape 40: 神のように賢いコンパイラが必要 / 後方互換性を失う
- `day7` slide 1, shape 46: ハードウェアは簡単 / 後方互換性も保てる
- `day7` slide 1, shape 54: 命令を複数取ってきて、 / スケジューラが振り分ける
- `day7` slide 1, shape 55: 事前に並列実行できる命令を / ひとつにまとめておく
- `day7` slide 1, shape 63: 複数のデータに同じ演算を / 一度に行う

## Translation Inconsistencies

- None.
