# Day 7 : より実践的なスパコンプログラミング

ここまで読んだ人、お疲れ様です。ここから読んでいる人、それでも問題ありません。
「一週間でなれる！」と銘打ってだらだら書いてきたが、神様も6日間で世界を作って最後の日は休んだそうなので、Day 7は何かを系統的に話すというよりは、私のスパコンプログラマとしての経験を雑多に書いてみようと思う。

## SIMDについて

スパコンプログラミングに興味があるような人なら、「SIMD」という言葉を聞いたことがあるだろう。SIMDとは、「single instruction multiple data」の略で、「一回の命令で複数のデータを同時に扱う」という意味である。先に、並列化は大きく分けて「データ並列」「共有メモリ並列」「分散メモリ並列」の三種類になると書いたが、SIMDはデータ並列(Data parallelism)に属す。現在、一般的に数値計算に使われるCPUにはほとんどSIMD命令が実装されている。まず、なぜSIMDが必要になるか、そしてSIMDとは何かについて見てみよう。

計算機というのは、要するにメモリからデータと命令を取ってきて、演算器に投げ、結果をメモリに書き戻す機械である。CPUの動作単位は「サイクル」で表される。演算器に計算を投げてから、結果が返ってくるまでに数サイクルかかるが、現代のCPUではパイプライン処理という手法によって事実上1サイクルに1個演算ができる。1サイクル1演算できるので、あとは「1秒あたりのサイクル数=動作周波数」を増やせば増やすほど性能が向上することになる。

というわけでCPUベンダーで動作周波数を向上させる熾烈な競争が行われたのだが、2000年代に入って動作周波数は上がらなくなった。これはリーク電流による発熱が主な原因なのだが、ここでは深く立ち入らない。1サイクルに1演算できる状態で、動作周波数をもう上げられないのだから、性能を向上させるためには「1サイクルに複数演算」をさせなければならない。この「1サイクルに複数演算」の実現にはいくつかの方法が考えられた。

![fig/simd.png](fig/simd.png)

まず、単純に演算器の数を増やすという方法が考えられる。1サイクルで命令を複数取ってきて、その中に独立に実行できるものがあれば、複数の演算器に同時に投げることで1サイクルあたりの演算数を増やそう、という方法論である。これを **スーパースカラ** と呼ぶ。独立に実行できる命令がないと性能が上がらないため、よくアウトオブオーダー実行と組み合わされる。要するに命令をたくさん取ってきて命令キューにためておき、スケジューラがそこを見て独立に実行できる命令を選んでは演算器に投げる、ということをする。

この方法には「命令セットの変更を伴わない」という大きなメリットがある。ハードウェアが勝手に並列実行できる命令を探して同時に実行してくれるので、プログラマは何もしなくて良い。そういう意味において、 **スーパースカラとはハードウェアにがんばらせる方法論** である。デメリット、というか問題点は、実行ユニットの数が増えると、依存関係チェックの手間が指数関数的に増えることである。一般的には整数演算が4つ程度、浮動小数点演算が2つくらいまでが限界だと思われる。

さて、スーパースカラの問題点は、命令の依存関係チェックが複雑であることだった。そこさえ解決できるなら、演算器をたくさん設置すればするほど性能が向上できると期待できる。そこで、事前に並列に実行できる命令を並べておいて、それをそのままノーチェックで演算器に流せばいいじゃないか、という方法論が考えられた。整数演算器や浮動小数点演算器、メモリのロードストアといった実行ユニットを並べておき、それらに供給する命令を予め全部ならべたものを「一つの命令」とする。並列実行できる実行ユニットの数だけ命令を「パック」したものを一つの命令にとするため、命令が極めて長くなる。そのため、この方式は「Very Long Instruction Word (超長い命令語)」、略してVLIWと呼ばれる。実際にはコンパイラがソースコードを見て並列に実行できる命令を抽出し、なるべく並列に実行できるように並べて一つの命令を作る。そういう意味において、 **VLIWとはコンパイラにがんばらせる方法論**である。

この方式で性能を稼ぐためには、VLIWの「命令」に有効な命令が並んでなければならない。しかし、命令に依存関係が多いと同時に使える実行ユニットが少なくなり、「遊ぶ」実行ユニットに対応する箇所には「NOP(no operation = 何もしない)」が並ぶことになる。VLIWはIntelとHPが共同開発したIA-64というアーキテクチャに採用され、それを実装したItanium2は、ハイエンドサーバやスパコン向けにそれなりに採用された。個人的にはItanium2は(レジスタもいっぱいあって)好きな石なのだが、この方式が輝くためには「神のように賢いコンパイラ」が必須となる。一般に「神のように賢いコンパイラ」を要求する方法はだいたい失敗する運命にある。また、命令セットが実行ユニットの仕様と強く結びついており、後方互換性に欠けるのも痛い。VLIWは組み込み用途では人気があるものの、いまのところハイエンドなHPC向けとしてはほぼ滅びたと言ってよいと思う。

さて、「ハードウェアにがんばらせる」方法には限界があり、「コンパイラにがんばらせる」方法には無理があった。残る方式は **プログラマにがんばらせる方法論** だけである。それがSIMDである。

異なる命令をまとめてパックするのは難しい。というわけで、命令ではなく、データをパックすることを考える。たとえば「C=A+B」という足し算を考える。これは「AとBというデータを取ってきて、加算し、Cとしてメモリに書き戻す」という動作をする。ここで、「C1 = A1+B1」「C2 = A2+B2」という独立な演算があったとしよう。予め「A1:A2」「B1:B2」とデータを一つのレジスタにパックしておき、それぞれの和を取ると「C1:C2」という、2つの演算結果がパックしたレジスタが得られる。このように複数のデータをパックするレジスタをSIMDレジスタと呼ぶ。例えばAVX2なら256ビットのSIMDレジスタがあるため、64ビットの倍精度実数を4つパックできる。そしてパックされた4つのデータ間に独立な演算を実行することができる。ここで、ハードウェアはパックされたデータの演算には依存関係が無いことを仮定する。つまり依存関係の責任はプログラマ側にある。ハードウェアから見れば、レジスタや演算器の「ビット幅」が増えただけのように見えるため、ハードウェアはさほど複雑にならない。しかし、性能向上のためには、SIMDレジスタを活用したプログラミングを行わなければならない。
SIMDレジスタを活用して性能を向上させることを俗に「SIMD化 (SIMD-vectorization)」などと呼ぶ。
原理的にはコンパイラによってSIMD化することは可能であり、実際に、最近のコンパイラのSIMD最適化能力の向上には目を見張るものがある。
しかし、効果的なSIMD化のためにはデータ構造の変更を伴うことが多く、コンパイラにはそういったグローバルな変更を伴う最適化が困難であることから、基本的には「SIMD化はプログラマが手で行う必要がある」のが現状である。

とりあえず簡単なSIMD化の例を見てみよう。こんなコードを考える。
一次元の配列の単純な和のループである。

[func.cpp](func.cpp)

```cpp
const int N = 10000;
double a[N], b[N], c[N];

void func() {
  for (int i = 0; i < N; i++) {
    c[i] = a[i] + b[i];
  }
}
```

これを普通にコンパイルすると、こんなアセンブリになる。

```sh
g++ -O1 -S func.cpp  
```

```asm
  xorl  %eax, %eax
  leaq  _a(%rip), %rcx
  leaq  _b(%rip), %rdx
  leaq  _c(%rip), %rsi
  movsd (%rax,%rcx), %xmm0
  addsd (%rax,%rdx), %xmm0
  movsd %xmm0, (%rax,%rsi)
  addq  $8, %rax
  cmpq  $80000, %rax
  jne LBB0_1
```

配列`a`,`b`,`c`のアドレスを`%rcx`, `%rdx`, `%rsi`に取得し、
`movsd`で`a[i]`のデータを`%xmm0`に持ってきて、`addsd`で`a[i]+b[i]`を計算して`%xmm0`に保存し、
それを`c[i]`の指すアドレスに`movsd`で書き戻す、ということをやっている。
これはスカラーコードなのだが、`xmm`は128ビットSIMDレジスタである。
x86は歴史的経緯からスカラーコードでも浮動小数点演算にSIMDレジスタである`xmm`を使うのだが、ここでは深く立ち入らない。
興味のある人は、適当な文献でx86における浮動小数点演算の歴史を調べられたい。

さて、このループをAVX2を使ってSIMD化することを考える。
AVX2のSIMDレジスタはymmで表記される。ymmレジスタは256ビットで、倍精度実数(64ビット)が4つ保持できるので、

* ループを4倍展開する
* 配列aから4つデータを持ってきてymmレジスタに乗せる
* 配列bから4つデータを持ってきてymmレジスタに乗せる
* 二つのレジスタを足す
* 結果のレジスタを配列cのしかるべき場所に保存する

ということをすればSIMD化完了である。SIMD化には組み込み関数を使う。コードを見たほうが早いと思う。

[func_simd.cpp](func_simd.cpp)

```cpp
#include <x86intrin.h>
void func_simd() {
  for (int i = 0; i < N; i += 4) {
    __m256d va = _mm256_load_pd(&(a[i]));
    __m256d vb = _mm256_load_pd(&(b[i]));
    __m256d vc = va + vb;
    _mm256_store_pd(&(c[i]), vc);
  }
}
```

組み込み関数を使うには、`x86intrin.h`をインクルードする。
`__m256d`というのが256ビットのSIMDレジスタを表す変数だと思えば良い。
そこに4つ連続したデータを持ってくる命令が`_mm256_load_pd`であり、
SIMDレジスタの内容をメモリに保存する命令が`_mm256_load_pd`である。
これをコンパイルしてアセンブリを見てみよう。

```sh
g++ -O1 -mavx2 -S func_simd.cpp
```

```asm
  xorl  %eax, %eax
  leaq  _a(%rip), %rcx
  leaq  _b(%rip), %rdx
  leaq  _c(%rip), %rsi
  xorl  %edi, %edi
LBB0_1:  
  vmovupd (%rax,%rcx), %ymm0         # (a[i],a[i+1],a[i+2],a[i+3]) -> ymm0
  vaddpd  (%rax,%rdx), %ymm0, %ymm0  # ymm0 + (b[i],b[i+1],b[i+2],b[i+3]) -> ymm 0
  vmovupd %ymm0, (%rax,%rsi)         # ymm0 -> (c[i],c[i+1],c[i+2],c[i+3])
  addq  $4, %rdi    # i += 4
  addq  $32, %rax
  cmpq  $10000, %rdi
  jb  LBB0_1
```

ほとんどそのままなので、アセンブリ詳しくない人でも理解は難しくないと思う。
配列のアドレスを`%rcx`, `%rdx`, `%rsi`に取得するところまでは同じ。
元のコードでは`movsd`で`xmm`レジスタにデータをコピーしていたのが、
`vmovupd`で`ymm`レジスタにデータをコピーしているのがわかる。
どの組み込み関数がどんなSIMD命令に対応しているかは[Intel Intrinsics Guide](https://software.intel.com/sites/landingpage/IntrinsicsGuide/#)が便利である。

念の為、このコードが正しく計算できてるかチェックしよう。
適当に乱数を生成して配列`a[N]`と`b[N]`に保存し、ついでに答えも`ans[N]`に保存しておく。

```cpp
int main() {
  std::mt19937 mt;
  std::uniform_real_distribution<double> ud(0.0, 1.0);
  for (int i = 0; i < N; i++) {
    a[i] = ud(mt);
    b[i] = ud(mt);
    ans[i] = a[i] + b[i];
  }
  check(func, "scalar");
  check(func_simd, "vector");
}
```

倍精度実数同士が等しいかチェックするのはいろいろと微妙なので、バイト単位で比較しよう。
ここでは配列`c[N]`と`ans[N]`を`unsigned char`にキャストして比較している。

```cpp
void check(void(*pfunc)(), const char *type) {
  pfunc();
  unsigned char *x = (unsigned char *)c;
  unsigned char *y = (unsigned char *)ans;
  bool valid = true;
  for (int i = 0; i < 8 * N; i++) {
    if (x[i] != y[i]) {
      valid = false;
      break;
    }
  }
  if (valid) {
    printf("%s is OK\n", type);
  } else {
    printf("%s is NG\n", type);
  }
}
```

全部まとめたコードはこちら。

[simdcheck.cpp](simdcheck.cpp)

実際に実行してテストしてみよう。

```sh
$ g++ -mavx2 -O3 simdcheck.cpp
$ ./a.out
scalar is OK
vector is OK
```

正しく計算できているようだ。

さて、これくらいのコードならコンパイラもSIMD化してくれる。で、問題はコンパイラがSIMD化したかどうかをどうやって判断するかである。
一つの方法は、コンパイラの吐く最適化レポートを見ることだ。インテルコンパイラなら`-qopt-report`で最適化レポートを見ることができる。

```sh
$ icpc -march=core-avx2 -O2 -c -qopt-report -qopt-report-file=report.txt func.cpp
$ cat report.txt
Intel(R) Advisor can now assist with vectorization and show optimization
  report messages with your source code.
(snip)
LOOP BEGIN at func.cpp(5,3)
   remark #15300: LOOP WAS VECTORIZED
LOOP END
```

実際にはもっとごちゃごちゃ出てくるのだが、とりあえず最後に「LOOP WAS VECTORIZED」とあり、SIMD化できたことがわかる。
しかし、どうSIMD化したのかはさっぱりわからない。`-qopt-report=5`として最適レポートのレベルを上げてみよう。

```sh
$ icpc -march=core-avx2 -O2 -c -qopt-report=5 -qopt-report-file=report5.txt func.cpp
$ cat report5.txt
Intel(R) Advisor can now assist with vectorization and show optimization
  report messages with your source code.
(snip)
LOOP BEGIN at func.cpp(5,3)
   remark #15388: vectorization support: reference c has aligned access   [ func.cpp(6,5) ]
   remark #15388: vectorization support: reference a has aligned access   [ func.cpp(6,5) ]
   remark #15388: vectorization support: reference b has aligned access   [ func.cpp(6,5) ]
   remark #15305: vectorization support: vector length 4
   remark #15399: vectorization support: unroll factor set to 4
   remark #15300: LOOP WAS VECTORIZED
   remark #15448: unmasked aligned unit stride loads: 2
   remark #15449: unmasked aligned unit stride stores: 1
   remark #15475: --- begin vector loop cost summary ---
   remark #15476: scalar loop cost: 6
   remark #15477: vector loop cost: 1.250
   remark #15478: estimated potential speedup: 4.800
   remark #15488: --- end vector loop cost summary ---
   remark #25015: Estimate of max trip count of loop=625
LOOP END
```

このレポートから以下のようなことがわかる。

* ymmレジスタを使ったSIMD化であり (vector length 4)
* ループを4倍展開しており(unroll factor set to 4)
* スカラーループのコストが6と予想され (scalar loop cost: 6)
* ベクトルループのコストが1.250と予想され (vector loop cost: 1.250)
* ベクトル化による速度向上率は4.8倍であると見積もられた (estimated potential speedup: 4.800)

でも、こういう時にはアセンブリ見ちゃった方が早い。

```sh
icpc -march=core-avx2 -O2 -S func.cpp
```

コンパイラが吐いたアセンブリを、少し手で並び替えたものがこちら。

```asm
        xorl      %eax, %eax
..B1.2:
        lea       (,%rax,8), %rdx
        vmovupd   a(,%rax,8), %ymm0
        vmovupd   32+a(,%rax,8), %ymm2
        vmovupd   64+a(,%rax,8), %ymm4
        vmovupd   96+a(,%rax,8), %ymm6
        vaddpd    b(,%rax,8), %ymm0, %ymm1
        vaddpd    32+b(,%rax,8), %ymm2, %ymm3
        vaddpd    64+b(,%rax,8), %ymm4, %ymm5
        vaddpd    96+b(,%rax,8), %ymm6, %ymm7
        vmovupd   %ymm1, c(%rdx)
        vmovupd   %ymm3, 32+c(%rdx)
        vmovupd   %ymm5, 64+c(%rdx)
        vmovupd   %ymm7, 96+c(%rdx)
        addq      $16, %rax
        cmpq      $10000, %rax
        jb        ..B1.2
```

先程、手でループを4倍展開してSIMD化したが、さらにそれを4倍展開していることがわかる。

これ、断言しても良いが、こういうコンパイラの最適化について調べる時、コンパイラの最適化レポートとにらめっこするよりアセンブリ読んじゃった方が絶対に早い。
「アセンブリを読む」というと身構える人が多いのだが、どうせSIMD化で使われる命令ってそんなにないし、
最低でも「どんな種類のレジスタが使われているか」を見るだけでも「うまくSIMD化できてるか」がわかる。
ループアンロールとかそういうアルゴリズムがわからなくても、アセンブリ見てxmmだらけだったらSIMD化は(あまり)されてないし、ymmレジスタが使われていればAVX/AVX2を使ったSIMD化で、
zmmレジスタが使われていればAVX-512を使ったSIMD化で、`vmovupd`が出てればメモリからスムーズにデータがコピーされてそうだし、
`vaddpd`とか出てればちゃんとSIMDで足し算しているなとか、そのくらいわかれば実用的にはわりと十分だったりする。
そうやっていつもアセンブリを読んでいると、そのうち「アセンブリ食わず嫌い」が治って、コンパイラが何を考えたかだんだんわかるようになる……かもしれない。

## チェックポイントリスタート

スパコンにジョブを投げるとき、投げるキューを選ぶ。このとき、キューごとに「実行時間の上限」が決まっていることがほとんである。実行時間制限はサイトやキューごとに違うが、短いと一日、長くても一週間程度であることが多い。一般に長時間実行できるキューは待ち時間も長くなる傾向にあるため、可能であれば長いジョブを短く分割して実行したほうが良い。このときに必要となるのがチェックポイントリスタートである。

## TLBミスについて

TODO:

## マルチスレッド環境でのmallocの問題

TODO:
