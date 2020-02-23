#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

##
## *.re を *.tex に変換したあとに実行されるスクリプト。
## 第1引数：作業用展開ディレクトリ
## 第2引数：呼び出しを実行したディレクトリ
##


##
## @arg texdir 作業用展開ディレクトリ
## @arg srcdir 呼び出しを実行したディレクトリ
##
def main(texdir, srcdir)
  Dir.glob("#{texdir}/*.tex").each do |filename|
    s1 = File.open(filename, "rt:utf-8") {|f| f.read }
    s2 = fix_reviewcolumn(s1)  # コラムをいろいろ修正
    if s1 != s2
      origfile = filename + ".orig"
      File.rename(filename, origfile) unless File.exist?(origfile)
      File.open(filename, "w:utf-8") {|f| f.write(s2) }
    end
  end
end

##
## コラム（「==[column] タイトル」）を変換したあとのLaTeXコードを修正する
##
def fix_reviewcolumn(content)
  return content.gsub(/^\\begin\{reviewcolumn\}$.*?^\\end\{reviewcolumn\}$/m) {|str|
    ##
    ## コラムの目次を「〈タイトル〉」から「【コラム】〈タイトル〉」に変更する
    ##
    prefix = "【コラム】"
    str = str.gsub(/^(\\addcontentsline\{toc\}\{\w+\}\{)/) { "#{$1}#{prefix}" }
    ##
    ## これ↓だと脚注が消えてしまうので
    ##
    ##   \begin{reviewcolumn}
    ##   本文\footnotemark{}
    ##   \footnotetext[1]{脚注}   % ←コラム内に脚注がある
    ##   \end{reviewcolumn}
    ##
    ## こう↓修正する
    ##
    ##   \begin{reviewcolumn}
    ##   本文\footnotemark{}
    ##   \end{reviewcolumn}
    ##   \footnotetext[1]{脚注}   % ←コラム外に脚注を移動する
    ##
    fntexts = []
    str = str.gsub(/^\\footnotetext\[\d+\]\{.*?\}\r?\n/m) {|s| fntexts << s; "" }
    str << "\n" << fntexts.join() if fntexts
    ##
    str
  }
end

main(*ARGV)
