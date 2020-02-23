# -*- coding: utf-8 -*-

##
## change ReVIEW source code
##

require 'set'


module ReVIEW


  ## コメント「#@#」を読み飛ばす（ただし //embed では読み飛ばさない）
  class LineInput

    def initialize(f)
      super
      @enable_comment = true
    end

    def enable_comment(flag)
      @enable_comment = flag
    end

    def gets
      line = super
      if @enable_comment
        while line && line =~ /\A\#\@\#/
          line = super
        end
      end
      return line
    end

  end if defined?(LineInput)


  class Compiler

    ## ブロック命令
    defblock :program, 0..3      ## プログラム
    defblock :terminal, 0..3     ## ターミナル
    defblock :sideimage, 2..3    ## テキストの横に画像を表示

    ## インライン命令
    definline :balloon           ## コード内でのふきだし説明（Re:VIEW3から追加）
    definline :secref            ## 節(Section)や項(Subsection)を参照

    private

    ## パーサを再帰呼び出しに対応させる

    def do_compile
      f = LineInput.new(StringIO.new(@chapter.content))
      @strategy.bind self, @chapter, Location.new(@chapter.basename, f)
      tagged_section_init
      parse_document(f, false)
      close_all_tagged_section
    end

    def parse_document(f, block_cmd)
      while f.next?
        case f.peek
        when /\A\#@/
          f.gets # Nothing to do
        when /\A=+[\[\s\{]/
          if block_cmd                      #+
            line = f.gets                   #+
            error "'#{line.strip}': should close '//#{block_cmd}' block before sectioning." #+
          end                               #+
          compile_headline f.gets
        #when /\A\s+\*/                     #-
        #  compile_ulist f                  #-
        when LIST_ITEM_REXP                 #+
          compile_list(f)                   #+
        when /\A\s+\d+\./
          compile_olist f
        when /\A\s*:\s/
          compile_dlist f
        when %r{\A//\}}
          return if block_cmd               #+
          f.gets
          #error 'block end seen but not opened'                   #-
          error "'//}': block-end found, but no block command opened."  #+
        #when %r{\A//[a-z]+}                       #-
        #  name, args, lines = read_command(f)     #-
        #  syntax = syntax_descriptor(name)        #-
        #  unless syntax                           #-
        #    error "unknown command: //#{name}"    #-
        #    compile_unknown_command args, lines   #-
        #    next                                  #-
        #  end                                     #-
        #  compile_command syntax, args, lines     #-
        when /\A\/\/\w+/                           #+
          parse_block_command(f)                   #+
        when %r{\A//}
          line = f.gets
          warn "`//' seen but is not valid command: #{line.strip.inspect}"
          if block_open?(line)
            warn 'skipping block...'
            read_block(f, false)
          end
        else
          if f.peek.strip.empty?
            f.gets
            next
          end
          compile_paragraph f
        end
      end
    end

    ## コードブロックのタブ展開を、LaTeXコマンドの展開より先に行うよう変更。
    ##
    ## ・たとえば '\\' を '\\textbackslash{}' に展開してからタブを空白文字に
    ##   展開しても、正しい展開にはならないことは明らか。先にタブを空白文字に
    ##   置き換えてから、'\\' を '\\textbackslash{}' に展開すべき。
    ## ・またタブ文字の展開は、本来はBuilderではなくCompilerで行うべきだが、
    ##   Re:VIEWの設計がまずいのでそうなっていない。
    ## ・'//table' と '//embed' ではタブ文字の展開は行わない。
    def read_block_for(cmdname, f)   # 追加
      disable_comment = cmdname == :embed    # '//embed' では行コメントを読み飛ばさない
      ignore_inline   = cmdname == :embed    # '//embed' ではインライン命令を解釈しない
      enable_detab    = cmdname !~ /\A(?:em)?table\z/  # '//table' ではタブ展開しない
      f.enable_comment(false) if disable_comment
      lines = read_block(f, ignore_inline, enable_detab)
      f.enable_comment(true)  if disable_comment
      return lines
    end
    def read_block(f, ignore_inline, enable_detab=true)   # 上書き
      head = f.lineno
      buf = []
      builder = @strategy                            #+
      f.until_match(%r{\A//\}}) do |line|
        if ignore_inline
          buf.push line
        elsif line !~ /\A\#@/
          #buf.push text(line.rstrip)                #-
          line = line.rstrip                         #+
          line = builder.detab(line) if enable_detab #+
          buf << text(line)                          #+
        end
      end
      unless %r{\A//\}} =~ f.peek
        error "unexpected EOF (block begins at: #{head})"
        return buf
      end
      f.gets # discard terminator
      buf
    end

    ## ブロック命令を入れ子可能に変更（'//note' と '//quote'）

    def parse_block_command(f)
      line = f.gets()
      lineno = f.lineno
      line =~ /\A\/\/(\w+)(\[.*\])?(\{)?$/  or
        error "'#{line.strip}': invalid block command format."
      cmdname = $1.intern; argstr = $2; curly = $3
      ##
      prev = @strategy.doc_status[cmdname]
      @strategy.doc_status[cmdname] = true
      ## 引数を取り出す
      syntax = syntax_descriptor(cmdname)  or
        error "'//#{cmdname}': unknown command"
      args = parse_args(argstr || "", cmdname)
      begin
        syntax.check_args args
      rescue CompileError => err
        error err.message
      end
      ## ブロックをとらないコマンドにブロックが指定されていたらエラー
      if curly && !syntax.block_allowed?
        error "'//#{cmdname}': this command should not take block (but given)."
      end
      ## ブロックの入れ子をサポートしてあれば、再帰的にパースする
      handler = "on_#{cmdname}_block"
      builder = @strategy
      if builder.respond_to?(handler)
        if curly
          builder.__send__(handler, *args) do
            parse_document(f, cmdname)
          end
          s = f.peek()
          f.peek() =~ /\A\/\/}/  or
            error "'//#{cmdname}': not closed (reached to EOF)"
          f.gets()   ## '//}' を読み捨てる
        else
          builder.__send__(handler, *args)
        end
      ## そうでなければ、従来と同じようにパースする
      elsif builder.respond_to?(cmdname)
        if !syntax.block_allowed?
          builder.__send__(cmdname, *args)
        elsif curly
          lines = read_block_for(cmdname, f)
          builder.__send__(cmdname, lines, *args)
        else
          lines = default_block(syntax)
          builder.__send__(cmdname, lines, *args)
        end
      else
        error "'//#{cmdname}': #{builder.class.name} not support this command"
      end
      ##
      @strategy.doc_status[cmdname] = prev
    end

    ## 箇条書きの文法を拡張

    LIST_ITEM_REXP = /\A( +)(\*+|\-+) +/    # '*' は unordred list、'-' は ordered list

    def compile_list(f)
      line = f.gets()
      line =~ LIST_ITEM_REXP
      indent = $1
      char = $2[0]
      $2.length == 1  or
        error "#{$2[0]=='*'?'un':''}ordered list should start with level 1"
      line = parse_list(f, line, indent, char, 1)
      f.ungets(line)
    end

    def parse_list(f, line, indent, char, level)
      if char != '*' && line =~ LIST_ITEM_REXP
        start_num, _ = $'.lstrip().split(/\s+/, 2)
      end
      st = @strategy
      char == '*' ? st.ul_begin { level } : st.ol_begin(start_num) { level }
      while line =~ LIST_ITEM_REXP  # /\A( +)(\*+|\-+) +/
        $1 == indent  or
          error "mismatched indentation of #{$2[0]=='*'?'un':''}ordered list"
        mark = $2
        text = $'
        if mark.length == level
          break unless mark[0] == char
          line = parse_item(f, text.lstrip(), indent, char, level)
        elsif mark.length < level
          break
        else
          raise "internal error"
        end
      end
      char == '*' ? st.ul_end { level } : st.ol_end { level }
      return line
    end

    def parse_item(f, text, indent, char, level)
      if char != '*'
        num, text = text.split(/\s+/, 2)
        text ||= ''
      end
      #
      buf = [parse_text(text)]
      while (line = f.gets()) && line =~ /\A( +)/ && $1.length > indent.length
        buf << parse_text(line)
      end
      #
      st = @strategy
      char == '*' ? st.ul_item_begin(buf) : st.ol_item_begin(buf, num)
      rexp = LIST_ITEM_REXP  # /\A( +)(\*+|\-+) +/
      while line =~ rexp && $2.length > level
        $2.length == level + 1  or
          error "invalid indentation level of (un)ordred list"
        line = parse_list(f, line, indent, $2[0], $2.length)
      end
      char == '*' ? st.ul_item_end() : st.ol_item_end()
      #
      return line
    end

    public

    ## 入れ子のインライン命令をパースできるよう上書き
    def parse_text(line)
      stack      = []
      tag_name   = nil
      close_char = nil
      items      = [""]
      nestable   = true
      scan_inline_command(line) do |text, s1, s2, s3|
        if s1     # ex: '@<code>{', '@<b>{', '@<m>$'
          if nestable
            items << text
            stack.push([tag_name, close_char, items])
            s1 =~ /\A@<(\w+)>([{$|])\z/  or raise "internal error"
            tag_name   = $1
            close_char = $2 == '{' ? '}' : $2
            items      = [""]
            nestable   = false if ignore_nested_inline_command?(tag_name)
          else
            items[-1] << text << s1
          end
        elsif s2  # '\}' or '\\' (not '\$' nor '\|')
          text << (close_char == '}' ? s2[1] : s2)
          items[-1] << text
        elsif s3  # '}', '$', or '|'
          items[-1] << text
          if close_char == s3
            items.delete_if {|x| x.empty? }
            elem = [tag_name, {}, items]
            tag_name, close_char, items = stack.pop()
            items << elem << ""
            nestable = true
          else
            items[-1] << s3
          end
        else
          if items.length == 1 && items[-1].empty?
            items[-1] = text
          else
            items[-1] << text
          end
        end
      end
      if tag_name
        error "inline command '@<#{tag_name}>' not closed."
      end
      items.delete_if {|x| x.empty? }
      #
      return compile_inline_command(items)
    end

    alias text parse_text

    private

    def scan_inline_command(line)
      pos = 0
      line.scan(/(\@<\w+>[{$|])|(\\[\\}])|([}$|])/) do
        m = Regexp.last_match
        text = line[pos, m.begin(0)-pos]
        pos = m.end(0)
        yield text, $1, $2, $3
      end
      remained = pos == 0 ? line : line[pos..-1]
      yield remained, nil, nil, nil
    end

    def compile_inline_command(items)
      buf = ""
      strategy = @strategy
      items.each do |x|
        case x
        when String
          buf << strategy.nofunc_text(x)
        when Array
          tag_name, attrs, children = x
          op = tag_name
          inline_defined?(op)  or
            raise CompileError, "no such inline op: #{op}"
          if strategy.respond_to?("on_inline_#{op}")
            buf << strategy.__send__("on_inline_#{op}") {|both_p|
              if !both_p
                compile_inline_command(children)
              else
                [compile_inline_command(children), children]
              end
            }
          elsif strategy.respond_to?("inline_#{op}")
            children.empty? || children.all? {|x| x.is_a?(String) }  or
              error "'@<#{op}>' does not support nested inline commands."

            buf << strategy.__send__("inline_#{op}", children[0])
          else
            error "strategy does not support inline op: @<#{op}>"
          end
        else
          raise "internal error: x=#{x.inspect}"
        end
      end
      buf
    end

    def ignore_nested_inline_command?(tag_name)
      return IGNORE_NESTED_INLINE_COMMANDS.include?(tag_name)
    end

    IGNORE_NESTED_INLINE_COMMANDS = Set.new(['m', 'raw', 'embed'])

  end


  class Book::ListIndex

    ## '//program' と '//terminal' をサポートするよう拡張
    def self.item_type  # override
      #'(list|listnum)'            # original
      '(list|listnum|program|terminal)'
    end

    ## '//list' や '//terminal' のラベル（第1引数）を省略できるよう拡張
    def self.parse(src, *args)  # override
      items = []
      seq = 1
      src.grep(%r{\A//#{item_type}}) do |line|
        if id = line.slice(/\[(.*?)\]/, 1)
          next if id.empty?                     # 追加
          items.push item_class.new(id, seq)
          seq += 1
          ReVIEW.logger.warn "warning: no ID of #{item_type} in #{line}" if id.empty?
        end
      end
      new(items, *args)
    end

  end if defined?(Book::ListIndex)


  module Book::Compilable

    def content   # override
      ## //list[?] や //terminal[?] の '?' をランダム文字列に置き換える。
      ## こうすると、重複しないラベルをいちいち指定しなくても、ソースコードや
      ## ターミナルにリスト番号がつく。ただし @<list>{} での参照はできない。
      unless @_done
        pat = Book::ListIndex.item_type  # == '(list|listnum|program|terminal)'
        @content = @content.gsub(/^\/\/#{pat}\[\?\]/) { "//#{$1}[#{_random_label()}]" }
        ## 改行コードを「\n」に統一する
        @content = @content.gsub(/\r\n/, "\n")
        ## (experimental) 範囲コメント（'#@+++' '#@---'）を行コメント（'#@#'）に変換
        @content = @content.gsub(/^\#\@\+\+\+$.*?^\#\@\-\-\-$/m) { $&.gsub(/^/, '#@#') }
        @_done = true
      end
      @content
    end

    module_function

    def _random_label
      "_" + rand().to_s[2..10]
    end

  end if defined?(Book::Compilable)


  class Catalog

    def parts_with_chaps
      ## catalog.ymlの「CHAPS:」がnullのときエラーになるのを防ぐ
      (@yaml['CHAPS'] || []).flatten.compact
    end

  end if defined?(Catalog)


  class Builder

    ## Re:VIEW3で追加されたもの
    def on_inline_balloon(arg)
      return "← #{yield}"
    end

    ## ul_item_begin() だけあって ol_item_begin() がないのはどうかと思う。
    ## ol の入れ子がないからといって、こういう非対称な設計はやめてほしい。
    def ol_item_begin(lines, _num)
      ol_item(lines, _num)
    end
    def ol_item_end()
    end

    protected

    def truncate_if_endwith?(str)
      sio = @output   # StringIO object
      if sio.string.end_with?(str)
        pos = sio.pos - str.length
        sio.seek(pos)
        sio.truncate(pos)
        true
      else
        false
      end
    end

    def enter_context(key)
      @doc_status[key] = true
    end

    def exit_context(key)
      @doc_status[key] = nil
    end

    def with_context(key)
      enter_context(key)
      return yield
    ensure
      exit_context(key)
    end

    def within_context?(key)
      return @doc_status[key]
    end

    def within_codeblock?
      d = @doc_status
      d[:program] || d[:terminal] \
      || d[:list] || d[:emlist] || d[:listnum] || d[:emlistnum] \
      || d[:cmd] || d[:source]
    end

    ## 入れ子可能なブロック命令

    public

    def on_note_block      caption=nil, &b; on_minicolumn :note     , caption, &b; end
    def on_memo_block      caption=nil, &b; on_minicolumn :memo     , caption, &b; end
    def on_tip_block       caption=nil, &b; on_minicolumn :tip      , caption, &b; end
    def on_info_block      caption=nil, &b; on_minicolumn :info     , caption, &b; end
    def on_warning_block   caption=nil, &b; on_minicolumn :warning  , caption, &b; end
    def on_important_block caption=nil, &b; on_minicolumn :important, caption, &b; end
    def on_caution_block   caption=nil, &b; on_minicolumn :caution  , caption, &b; end
    def on_notice_block    caption=nil, &b; on_minicolumn :notice   , caption, &b; end

    def on_minicolumn(type, caption=nil, &b)
      raise NotImplementedError.new("#{self.class.name}#on_minicolumn(): not implemented yet.")
    end
    protected :on_minicolumn

    def on_sideimage_block(imagefile, imagewidth, option_str=nil, &b)
      raise NotImplementedError.new("#{self.class.name}#on_sideimage_block(): not implemented yet.")
    end

    def validate_sideimage_args(imagefile, imagewidth, option_str)
      opts = {}
      if option_str.present?
        option_str.split(',').each do |kv|
          kv.strip!
          next if kv.empty?
          kv =~ /(\w[-\w]*)=(.*)/  or
            error "//sideimage: [#{option_str}]: invalid option string."
          opts[$1] = $2
        end
      end
      #
      opts.each do |k, v|
        case k
        when 'side'
          v == 'L' || v == 'R'  or
            error "//sideimage: [#{option_str}]: 'side=' should be 'L' or 'R'."
        when 'boxwidth'
          v =~ /\A\d+(\.\d+)?(%|mm|cm|zw)\z/  or
            error "//sideimage: [#{option_str}]: 'boxwidth=' invalid (expected such as 10%, 30mm, 3.0cm, or 5zw)"
        when 'sep'
          v =~ /\A\d+(\.\d+)?(%|mm|cm|zw)\z/  or
            error "//sideimage: [#{option_str}]: 'sep=' invalid (expected such as 2%, 5mm, 0.5cm, or 1zw)"
        when 'border'
          v =~ /\A(on|off)\z/  or
            error "//sideimage: [#{option_str}]: 'border=' should be 'on' or 'off'"
          opts[k] = v == 'on' ? true : false
        else
          error "//sideimage: [#{option_str}]: unknown option '#{k}=#{v}'."
        end
      end
      #
      imagefile.present?  or
        error "//sideimage: 1st option (image file) required."
      imagewidth.present?  or
        error "//sideimage: 2nd option (image width) required."
      imagewidth =~ /\A\d+(\.\d+)?(%|mm|cm|zw|pt)\z/  or
        error "//sideimage: [#{imagewidth}]: invalid image width (expected such as: 30mm, 3.0cm, 5zw, or 100pt)"
      #
      return imagefile, imagewidth, opts
    end
    protected :validate_sideimage_args

    ## コードブロック（//program, //terminal）

    CODEBLOCK_OPTIONS = {
      'fold'   => true,
      'lineno' => false,
      'linenowidth' => -1,
      'eolmark'     => false,
      'foldmark'    => true,
      'lang'        => nil,
    }

    ## プログラム用ブロック命令
    ## ・//list と似ているが、長い行を自動的に折り返す
    ## ・seqsplit.styの「\seqsplit{...}」コマンドを使っている
    def program(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('program', lines, id, caption, optionstr)
    end

    ## ターミナル用ブロック命令
    ## ・//cmd と似ているが、長い行を自動的に折り返す
    ## ・seqsplit.styの「\seqsplit{...}」コマンドを使っている
    def terminal(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('terminal', lines, id, caption, optionstr)
    end

    protected

    def _codeblock(blockname, lines, id, caption, optionstr)
      raise NotImplementedError.new("#{self.class.name}#_codeblock(): not implemented yet.")
    end

    def _each_block_option(option_str)
      option_str.split(',').each do |kvs|
        k, v = kvs.split('=', 2)
        yield k, v
      end if option_str && !option_str.empty?
    end

    def _parse_codeblock_optionstr(optionstr, blockname)  # parse 'fold={on|off},...'
      opts = {}
      return opts if optionstr.nil? || optionstr.empty?
      vals = {nil=>true, 'on'=>true, 'off'=>false}
      optionstr.split(',').each_with_index do |x, i|
        x = x.strip()
        x =~ /\A([-\w]+)(?:=(.*))?\z/  or
          raise "//#{blockname}[][][#{x}]: invalid option format."
        k, v = $1, $2
        case k
        when 'fold', 'eolmark', 'foldmark'
          if vals.key?(v)
            opts[k] = vals[v]
          else
            raise "//#{blockname}[][][#{x}]: expected 'on' or 'off'."
          end
        when 'lineno'
          if vals.key?(v)
            opts[k] = vals[v]
          elsif v =~ /\A\d+\z/
            opts[k] = v.to_i
          elsif v =~ /\A\d+-?\d*(?:\&+\d+-?\d*)*\z/
            opts[k] = v
          else
            raise "//#{blockname}[][][#{x}]: expected line number pattern."
          end
        when 'linenowidth'
          if v =~ /\A-?\d+\z/
            opts[k] = v.to_i
          else
            raise "//#{blockname}[][][#{x}]: expected integer value."
          end
        when 'fontsize'
          if v =~ /\A((x-|xx-)?small|(x-|xx-)?large)\z/
            opts[k] = v
          else
            raise "//#{blockname}[][][#{x}]: expected small/x-small/xx-small."
          end
        when 'indentwidth'
          if v =~ /\A\d+\z/
            opts[k] = v.to_i
          else
            raise "//#{blockname}[][][#{x}]: expected integer (>=0)."
          end
        when 'lang'
          if v
            opts[k] = v
          else
            raise "//#{blockname}[][][#{x}]: requires option value."
          end
        else
          if i == 0
            opts['lang'] = v
          else
            raise "//#{blockname}[][][#{x}]: unknown option."
          end
        end
      end
      return opts
    end

    def _build_caption_str(id, caption)
      str = ""
      with_context(:caption) do
        str = compile_inline(caption) if caption.present?
      end
      if id.present?
        number = _build_caption_number(id)
        prefix = "#{I18n.t('list')}#{number}#{I18n.t('caption_prefix')}"
        str = "#{prefix}#{str}"
      end
      return str
    end

    def _build_caption_number(id)
      chapter = get_chap()
      number = @chapter.list(id).number
      return chapter.nil? \
           ? I18n.t('format_number_header_without_chapter', [number]) \
           : I18n.t('format_number_header', [chapter, number])
    rescue KeyError
      error "no such list: #{id}"
    end

    public

    ## インライン命令のバグ修正

    def inline_raw(str)
      name = target_name()
      if str =~ /\A\|(.*?)\|/
        str = $'
        return "" unless $1.split(',').any? {|s| s.strip == name }
      end
      return str.gsub('\\n', "\n")
    end

    def inline_embed(str)
      name = target_name()
      if str =~ /\A\|(.*?)\|/
        str = $'
        return "" unless $1.split(',').any? {|s| s.strip == name }
      end
      return str
    end

    ## インライン命令を入れ子に対応させる

    def on_inline_href
      escaped_str, items = yield true
      url = label = nil
      separator1 = /, /
      separator2 = /(?<=[^\\}]),/  # 「\\,」はセパレータと見なさない
      [separator1, separator2].each do |sep|
        pair = items[0].split(sep, 2)
        if pair.length == 2
          url = pair[0]
          label = escaped_str.split(sep, 2)[-1]  # 「,」がエスケープされない前提
          break
        end
      end
      url ||= items[0]
      url = url.gsub(/\\,/, ',')   # 「\\,」を「,」に置換
      return build_inline_href(url, label)
    end

    def on_inline_ruby
      escaped_str = yield
      arr = escaped_str.split(', ')
      if arr.length > 1                 # ex: @<ruby>{小鳥遊, たかなし}
        yomi = arr.pop().strip()
        word = arr.join(', ')
      elsif escaped_str =~ /,([^,]*)\z/ # ex: @<ruby>{小鳥遊,たかなし}
        word, yomi = $`, $1.strip()
      else
        error "@<ruby>: missing yomi, should be '@<ruby>{word, yomi}' style."
      end
      return build_inline_ruby(word, yomi)
    end

    ## 節 (Section) や項 (Subsection) を参照する。
    ## 引数 id が節や項のラベルでないなら、エラー。
    ## 使い方： @<subsec>{label}
    def inline_secref(id)  # 参考：ReVIEW::Builder#inline_hd(id)
      ## 本来、こういった処理はParserで行うべきであり、Builderで行うのはおかしい。
      ## しかしRe:VIEWのアーキテクチャがよくないせいで、こうせざるを得ない。無念。
      sec_id = id
      chapter = nil
      if id =~ /\A([^|]+)\|(.+)/
        chap_id = $1; sec_id = $2
        chapter = @book.contents.detect {|chap| chap.id == chap_id }  or
          error "@<secref>{#{id}}: chapter '#{chap_id}' not found."
      end
      begin
        _inline_secref(chapter || @chapter, sec_id)
      rescue KeyError
        error "@<secref>{#{id}}: section (or subsection) not found."
      end
    end

    private

    def _inline_secref(chap, id)
      sec_id = chap.headline(id).id
      num, title = _get_secinfo(chap, sec_id)
      level = num.split('.').length
      #
      secnolevel = @book.config['secnolevel']
      if secnolevel + 1 < level
        error "'secnolevel: #{secnolevel}' should be >= #{level-1} in config.yml"
      ## config.ymlの「secnolevel:」が3以上なら、項 (Subsection) にも
      ## 番号がつく。なので、節 (Section) のタイトルは必要ない。
      elsif secnolevel + 1 > level
        parent_title = nil
      ## そうではない場合は、節 (Section) と項 (Subsection) とを組み合わせる。
      ## たとえば、"「1.1 イントロダクション」内の「はじめに」" のように。
      elsif secnolevel + 1 == level
        parent_id = sec_id.sub(/\|[^|]+\z/, '')
        _, parent_title = _get_secinfo(chap, parent_id)
      else
        raise "not reachable"
      end
      #
      return _build_secref(chap, num, title, parent_title)
    end

    def _get_secinfo(chap, id)  # 参考：ReVIEW::LATEXBuilder#inline_hd_chap()
      num = chap.headline_index.number(id)
      caption = compile_inline(chap.headline(id).caption)
      if chap.number && @book.config['secnolevel'] >= num.split('.').size
        caption = "#{chap.headline_index.number(id)} #{caption}"
      end
      title = I18n.t('chapter_quote', caption)
      return num, title
    end

    def _build_secref(chap, num, title, parent_title)
      raise NotImplementedError.new("#{self.class.name}#_build_secref(): not implemented yet.")
    end

    protected

    def find_image_filepath(image_id)
      finder = get_image_finder()
      filepath = finder.find_path(image_id)
      return filepath
    end

    def get_image_finder()
      imagedir = "#{@book.basedir}/#{@book.config['imagedir']}"
      types    = @book.image_types
      builder  = @book.config['builder']
      chap_id  = @chapter.id
      return ReVIEW::Book::ImageFinder.new(imagedir, chap_id, builder, types)
    end

  end


  class LATEXBuilder

    ## 章や節や項や目のタイトル
    alias __original_headline headline
    def headline(level, label, caption)
      return with_context(:headline) do
        __original_headline(level, label, caption)
      end
    end

    ## テーブルヘッダー
    alias __original_table_header table_header
    def table_header(id, caption)
      return with_context(:caption) do
        __original_table_header(id, caption)
      end
    end

    ## 改行命令「\\」のあとに改行文字「\n」を置かない。
    ##
    ## 「\n」が置かれると、たとえば
    ##
    ##     foo@<br>{}
    ##     bar
    ##
    ## が
    ##
    ##     foo\\
    ##
    ##     bar
    ##
    ## に展開されてしまう。
    ## つまり改行のつもりが改段落になってしまう。
    def inline_br(_str)
      #"\\\\\n"   # original
      "\\\\{}"
    end


    ## コードブロック（//program, //terminal）

    def program(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('program', lines, id, caption, optionstr)
    end

    def terminal(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('terminal', lines, id, caption, optionstr)
    end

    protected

    FONTSIZES = {
      "small"    => "small",
      "x-small"  => "footnotesize",
      "xx-small" => "scriptsize",
      "large"    => "large",
      "x-large"  => "Large",
      "xx-large" => "LARGE",
    }

    ## コードブロック（//program, //terminal）
    def _codeblock(blockname, lines, id, caption, optionstr)
      ## ブロックコマンドのオプション引数はCompilerクラスでパースすべき。
      ## しかしCompilerクラスがそのような設計になってないので、
      ## 仕方ないのでBuilderクラスでパースする。
      opts = _parse_codeblock_optionstr(optionstr, blockname)
      CODEBLOCK_OPTIONS.each {|k, v| opts[k] = v unless opts.key?(k) }
      #
      if opts['eolmark']
        lines = lines.map {|line| "#{detab(line)}\\startereolmark{}" }
      else
        lines = lines.map {|line| detab(line) }
      end
      #
      if opts['indentwidth'] && opts['indentwidth'] > 0
        indent_w   = opts['indentwidth']
        indent_str = " " * (indent_w - 1) + "{\\starterindentchar}"
        lines = lines.map {|line|
          line.sub(/\A( +)/) {
            m, n = ($1.length - 1).divmod indent_w
            " " << indent_str * m << " " * n
          }
        }
      end
      #
      if id.present? || caption.present?
        caption_str = _build_caption_str(id, caption)
      else
        caption_str = nil
      end
      #
      fontsize = FONTSIZES[opts['fontsize']]
      print "\\def\\startercodeblockfontsize{#{fontsize}}\n"
      #
      environ = "starter#{blockname}"
      print "\\begin{#{environ}}[#{id}]{#{caption_str}}"
      print "\\startersetfoldmark{}" unless opts['foldmark']
      if opts['eolmark']
        print "\\startereolmarkdark{}"  if blockname == 'terminal'
        print "\\startereolmarklight{}" if blockname != 'terminal'
      end
      if opts['lineno']
        gen = LineNumberGenerator.new(opts['lineno'])
        width = opts['linenowidth']
        if width && width >= 0
          if width == 0
            last_lineno = gen.each.take(lines.length).compact.last
            width = last_lineno.to_s.length
          end
          print "\\startersetfoldindentwidth{#{'9'*(width+2)}}"
          format = "\\textcolor{gray}{%#{width}s:} "
        else
          format = "\\starterlineno{%s}"
        end
        buf = []
        opt_fold = opts['fold']
        lines.zip(gen).each do |x, n|
          buf << ( opt_fold \
                   ? "#{format % n.to_s}\\seqsplit{#{x}}" \
                   : "#{format % n.to_s}#{x}" )
        end
        print buf.join("\n")
      else
        print "\\seqsplit{"       if opts['fold']
        print lines.join("\n")
        print "}"                 if opts['fold']
      end
      puts "\\end{#{environ}}"
      nil
    end

    public

    ## ・\caption{} のかわりに \reviewimagecaption{} を使うよう修正
    ## ・「scale=X」に加えて「pos=X」も受け付けるように拡張
    def image_image(id, caption, option_str)
      pos = nil; border = nil; arr = []
      _each_block_option(option_str) do |k, v|
        case k
        when 'pos'
          v =~ /\A[Hhtb]+\z/  or  # H: Here, h: here, t: top, b: bottom
            raise "//image[][][pos=#{v}]: expected 'pos=H' or 'pos=h'."
          pos = v     # detect 'pos=H' or 'pos=h'
        when 'border', 'draft'
          case v
          when nil  ; flag = true
          when 'on' ; flag = true
          when 'off'; flag = false
          else
            raise "//image[][][#{k}=#{v}]: expected '#{k}=on' or '#{k}=off'"
          end
          border = flag          if k == 'border'
          arr << "draft=#{flag}" if k == 'draft'
        else
          arr << (v.nil? ? k : "#{k}=#{v}")
        end
      end
      #
      metrics = parse_metric('latex', arr.join(","))
      puts "\\begin{reviewimage}[#{pos}]%%#{id}" if pos
      puts "\\begin{reviewimage}%%#{id}"     unless pos
      metrics = "width=\\maxwidth" unless metrics.present?
      puts "\\starterimageframe{%" if border
      puts "\\includegraphics[#{metrics}]{#{@chapter.image(id).path}}%"
      puts "}%"                    if border
      with_context(:caption) do
        #puts macro('caption', compile_inline(caption)) if caption.present?  # original
        puts macro('reviewimagecaption', compile_inline(caption)) if caption.present?
      end
      puts macro('label', image_label(id))
      puts "\\end{reviewimage}"
    end

    def _build_secref(chap, num, title, parent_title)
      s = ""
      ## 親セクションのタイトルがあれば使う
      if parent_title
        s << "%s内の" % parent_title   # TODO: I18n化
      end
      ## 対象セクションへのリンクを作成する
      if @book.config['chapterlink']
        label = "sec:" + num.gsub('.', '-')
        s << "\\reviewsecref{#{title}}{#{label}}"
      else
        s << title
      end
      return s
    end

    ###

    public

    def ul_begin
      blank
      puts '\begin{starteritemize}'    # instead of 'itemize'
    end

    def ul_end
      puts '\end{starteritemize}'      # instead of 'itemize'
      blank
    end

    def ol_begin(start_num=nil)
      blank
      puts '\begin{starterenumerate}'  # instead of 'enumerate'
      if start_num.nil?
        return true unless @ol_num
        puts "\\setcounter{enumi}{#{@ol_num - 1}}"
        @ol_num = nil
      end
    end

    def ol_end
      puts '\end{starterenumerate}'    # instead of 'enumerate'
      blank
    end

    def ol_item_begin(lines, num)
      str = lines.join
      num = escape(num).sub(']', '\rbrack{}')
      puts "\\item[#{num}] #{str}"
    end

    def ol_item_end()
    end

    ## 入れ子可能なブロック命令

    def on_minicolumn(type, caption, &b)
      puts "\\begin{reviewminicolumn}\n"
      if caption.present?
        @doc_status[:caption] = true
        puts "\\reviewminicolumntitle{#{compile_inline(caption)}}\n"
        @doc_status[:caption] = nil
      end
      yield
      puts "\\end{reviewminicolumn}\n"
    end
    protected :on_minicolumn

    def on_sideimage_block(imagefile, imagewidth, option_str=nil, &b)
      imagefile, imagewidth, opts = validate_sideimage_args(imagefile, imagewidth, option_str)
      filepath = find_image_filepath(imagefile)
      side     = opts['side'] || 'L'
      normalize = proc {|s|
        s =~ /\A(\d+(?:\.\d+)?)(%|mm|cm)\z/
        if    $2.nil?   ; s
        elsif $2 == '%' ; "#{$1.to_f/100.0}\\textwidth"
        else            ; "#{$1}true#{$2}"
        end
      }
      imgwidth = normalize.call(imagewidth)
      boxwidth = normalize.call(opts['boxwidth']) || imgwidth
      sepwidth = normalize.call(opts['sep'] || "0pt")
      puts "{\n"
      puts "  \\def\\starterminiimageframe{Y}\n" if opts['border']
      puts "  \\begin{startersideimage}{#{side}}{#{filepath}}{#{imgwidth}}{#{boxwidth}}{#{sepwidth}}{}\n"
      yield
      puts "  \\end{startersideimage}\n"
      puts "}\n"
    end

    ## nestable inline commands

    def on_inline_i()     ; "{\\reviewit{#{yield}}}"       ; end
    def on_inline_b()     ; "{\\reviewbold{#{yield}}}"     ; end
    #def on_inline_tt()    ; "{\\reviewtt{#{yield}}}"       ; end
    def on_inline_tti()   ; "{\\reviewtti{#{yield}}}"      ; end
    def on_inline_ttb()   ; "{\\reviewttb{#{yield}}}"      ; end
    #def on_inline_code()  ; "{\\reviewcode{#{yield}}}"     ; end
    def on_inline_del()   ; "{\\reviewstrike{#{yield}}}"   ; end
    def on_inline_sub()   ; "{\\textsubscript{#{yield}}}"  ; end
    def on_inline_sup()   ; "{\\textsuperscript{#{yield}}}"; end
    def on_inline_em()    ; "{\\reviewem{#{yield}}}"       ; end
    def on_inline_strong(); "{\\reviewstrong{#{yield}}}"   ; end
    def on_inline_u()     ; "{\\reviewunderline{#{yield}}}"; end
    def on_inline_ami()   ; "{\\reviewami{#{yield}}}"      ; end
    def on_inline_balloon(); "{\\reviewballoon{#{yield}}}" ; end

    def on_inline_tt()
      ## LaTeXでは、'\texttt{}' 中の '!?:.' の直後の空白が2文字分で表示される。
      ## その問題を回避するために、' ' を '\ ' にする。
      s = yield
      s = s.gsub(/([!?:.]) /, '\\1\\ ')
      return "{\\reviewtt{#{s}}}"
    end

    def on_inline_code()
      with_context(:inline_code) {
        ## LaTeXでは、'\texttt{}' 中の '!?:.' の直後の空白が2文字分で表示される。
        ## その問題を回避するために、' ' を '\ ' にする。
        s = yield
        s = s.gsub(/([!?:.]) /, '\\1\\ ')
        ## コンテキストによって、背景色をつけないことがある
        if false
        elsif within_context?(:headline)       # 章タイトルや節タイトルでは
          "{\\reviewcode[headline]{#{s}}}"     #   背景色をつけない（かも）
        elsif within_context?(:caption)        # リストや画像のキャプションでも
          "{\\reviewcode[caption]{#{s}}}"      #   背景色をつけない（かも）
        else                                   # それ以外では
          "{\\reviewcode{#{s}}}"               #   背景色をつける（かも）
        end
      }
    end

    def build_inline_href(url, escaped_label)  # compile_href()をベースに改造
      if /\A[a-z]+:/ !~ url
        "\\ref{#{url}}"
      elsif escaped_label
        "\\href{#{escape_url(url)}}{#{escaped_label}}"
      else
        "\\url{#{escape_url(url)}}"
      end
    end

    def build_inline_ruby(escaped_word, escaped_yomi)  # compile_ruby()をベースに改造
      "\\ruby{#{escaped_word}}{#{escaped_yomi}}"
    end

    def inline_bou(str)
      ## original
      #str.split(//).map { |c| macro('ruby', escape(c), macro('textgt', BOUTEN)) }.join('\allowbreak')
      ## work well with XeLaTeX as well as upLaTeX
      str.split(//).map {|c| "\\ruby{#{escape(c)}}{#{BOUTEN}}" }.join('\allowbreak')
    end

  end if defined?(LATEXBuilder)


  class HTMLBuilder

    def layoutfile
      ## 'rake web' のときに使うレイアウトファイルを 'layout.html5.erb' へ変更
      if @book.config.maker == 'webmaker'
        htmldir = 'web/html'
        #localfilename = 'layout-web.html.erb'
        localfilename = 'layout.html5.erb'
      else
        htmldir = 'html'
        localfilename = 'layout.html.erb'
      end
      ## 以下はリファクタリングした結果
      basename = @book.htmlversion == 5 ? 'layout-html5.html.erb' : 'layout-xhtml1.html.erb'
      htmlfilename = File.join(htmldir, basename)
      #
      layout_file = File.join(@book.basedir, 'layouts', localfilename)
      if ! File.exist?(layout_file)
        ! File.exist?(File.join(@book.basedir, 'layouts', 'layout.erb'))  or
          raise ReVIEW::ConfigError, 'layout.erb is obsoleted. Please use layout.html.erb.'
        layout_file = nil
      elsif ENV['REVIEW_SAFE_MODE'].to_i & 4 > 0
        warn "user's layout is prohibited in safe mode. ignored."
        layout_file = nil
      end
      layout_file ||= File.expand_path(htmlfilename, ReVIEW::Template::TEMPLATE_DIR)
      return layout_file
    end

    def result
      # default XHTML header/footer
      @title = strip_html(compile_inline(@chapter.title))
      @body = @output.string
      @language = @book.config['language']
      @stylesheets = @book.config['stylesheet']
      @next = @chapter.next_chapter
      @prev = @chapter.prev_chapter
      @next_title = @next ? compile_inline(@next.title) : ''
      @prev_title = @prev ? compile_inline(@prev.title) : ''

      if @book.config.maker == 'webmaker'
        #@toc = ReVIEW::WEBTOCPrinter.book_to_string(@book)          #-
        @toc = ReVIEW::WEBTOCPrinter.book_to_html(@book, @chapter)   #+
      end

      ReVIEW::Template.load(layoutfile).result(binding)
    end

    def headline(level, label, caption)
      prefix, anchor = headline_prefix(level)
      prefix = "<span class=\"secno\">#{prefix}</span> " if prefix
      puts "" if level > 1
      a_id = ""
      a_id = "<a id=\"h#{anchor}\"></a>" if anchor
      #
      if caption.empty?
        puts a_id if label
      else
        attr = label ? " id=\"#{normalize_id(label)}\"" : ""
        puts "<h#{level}#{attr}>#{a_id}#{prefix}#{compile_inline(caption)}</h#{level}>"
      end
    end

    def image_image(id, caption, metric)
      src = @chapter.image(id).path.sub(%r{\A\./}, '')
      alt = escape_html(compile_inline(caption))
      metrics = parse_metric('html', metric)
      metrics = " class=\"img\"" unless metrics.present?
      puts "<div id=\"#{normalize_id(id)}\" class=\"image\">"
      puts "<img src=\"#{src}\" alt=\"#{alt}\"#{metrics} />"
      image_header(id, caption)
      puts "</div>"
    end

    ## コードブロック（//program, //terminal）

    def program(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('program', 'code', lines, id, caption, optionstr)
    end

    def terminal(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('terminal', 'cmd-code', lines, id, caption, optionstr)
    end

    protected

    def _codeblock(blockname, classname, lines, id, caption, optionstr)
      ## ブロックコマンドのオプション引数はCompilerクラスでパースすべき。
      ## しかしCompilerクラスがそのような設計になってないので、
      ## 仕方ないのでBuilderクラスでパースする。
      opts = _parse_codeblock_optionstr(optionstr, blockname)
      CODEBLOCK_OPTIONS.each {|k, v| opts[k] = v unless opts.key?(k) }
      #
      if opts['eolmark']
        lines = lines.map {|line| "#{detab(line)}<small class=\"startereolmark\"></small>" }
      else
        lines = lines.map {|line| detab(line) }
      end
      #
      puts "<div id=\"#{normalize_id(id)}\" class=\"#{classname}\">" if id.present?
      puts "<div class=\"#{classname}\">"                        unless id.present?
      #
      if id.present? || caption.present?
        str = _build_caption_str(id, caption)
        print "<span class=\"caption\">#{str}</span>\n"
        classattr = "list"
      else
        classattr = "emlist"
      end
      #
      lang = opts['lang']
      lang = File.extname(id || "").gsub(".", "") if lang.blank?
      classattr << " language-#{lang}" unless lang.blank?
      classattr << " highlight"        if highlight?
      print "<pre class=\"#{classattr}\">"
      #
      gen = opts['lineno'] ? LineNumberGenerator.new(opts['lineno']).each : nil
      if gen
        width = opts['linenowidth']
        if width < 0
          format = "%s"
        elsif width == 0
          last_lineno = gen.each.take(lines.length).compact.last
          width = last_lineno.to_s.length
          format = "%#{width}s"
        else
          format = "%#{width}s"
        end
      end
      buf = []
      start_tag = opts['linenowidth'] >= 0 ? "<em class=\"linenowidth\">" : "<em class=\"lineno\">"
      lines.each_with_index do |line, i|
        buf << start_tag << (format % gen.next) << ": </em>" if gen
        buf << line << "\n"
      end
      puts highlight(body: buf.join(), lexer: lang,
                     format: "html", linenum: !!gen,
                     #options: {linenostart: start}
                     )
      #
      print "</pre>\n"
      print "</div>\n"
    end

    public

    ## コードリスト（//list, //emlist, //listnum, //emlistnum, //cmd, //source）
    def list(lines, id=nil, caption=nil, lang=nil)
      _codeblock("list", "caption-code", lines, id, caption, _codeblock_optstr(lang, false))
    end
    def listnum(lines, id=nil, caption=nil, lang=nil)
      _codeblock("listnum", "code", lines, id, caption, _codeblock_optstr(lang, true))
    end
    def emlist(lines, caption=nil, lang=nil)
      _codeblock("emlist", "emlist-code", lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def emlistnum(lines, caption=nil, lang=nil)
      _codeblock("emlistnum", "emlistnum-code", lines, nil, caption, _codeblock_optstr(lang, true))
    end
    def source(lines, caption=nil, lang=nil)
      _codeblock("source", "source-code", lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def cmd(lines, caption=nil, lang=nil)
      lang ||= "shell-session"
      _codeblock("cmd", "cmd-code", lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def _codeblock_optstr(lang, lineno_flag)
      arr = []
      arr << lang if lang
      if lineno_flag
        first_line_num = line_num()
        arr << "lineno=#{first_line_num}"
        arr << "linenowidth=0"
      end
      return arr.join(",")
    end
    private :_codeblock_optstr

    protected

    ## @<secref>{}

    def _build_secref(chap, num, title, parent_title)
      s = ""
      ## 親セクションのタイトルがあれば使う
      if parent_title
        s << "%s内の" % parent_title   # TODO: I18n化
      end
      ## 対象セクションへのリンクを作成する
      if @book.config['chapterlink']
        filename = "#{chap.id}#{extname()}"
        dom_id = 'h' + num.gsub('.', '-')
        s << "<a href=\"#{filename}##{dom_id}\">#{title}</a>"
      else
        s << title
      end
      return s
    end

    public

    ## 順序つきリスト

    def ol_begin(start_num=nil)
      @_ol_types ||= []    # stack
      case start_num
      when nil
        type = "1"; start = 1
      when /\A(\d+)\.\z/
        type = "1"; start = $1.to_i
      when /\A([A-Z])\.\z/
        type = "A"; start = $1.ord - 'A'.ord + 1
      when /\A([a-z])\.\z/
        type = "a"; start = $1.ord - 'a'.ord + 1
      else
        type = nil; start = nil
      end
      if type
        puts "<ol start=\"#{start}\" type=\"#{type}\">"
      else
        puts "<ol class=\"ol-none\">"
      end
      @_ol_types.push(type)
    end

    def ol_end()
      ol = !! @_ol_types.pop()
      if ol
        puts "</ol>"
      else
        puts "</ol>"
      end
    end

    def ol_item_begin(lines, num)
      ol = !! @_ol_types[-1]
      if ol
        print "<li>#{lines.join}"
      else
        n = escape_html(num)
        print "<li data-mark=\"#{n}\"><span class=\"li-mark\">#{n} </span>#{lines.join}"
      end
    end

    def ol_item_end()
      puts "</li>"
    end

    ## 入れ子可能なブロック命令

    def on_minicolumn(type, caption, &b)
      puts "<div class=\"#{type}\">"
      puts "<p class=\"caption\">#{compile_inline(caption)}</p>" if caption.present?
      yield
      puts '</div>'
    end
    protected :on_minicolumn

    def on_sideimage_block(imagefile, imagewidth, option_str=nil, &b)
      imagefile, imagewidth, opts = validate_sideimage_args(imagefile, imagewidth, option_str)
      filepath = find_image_filepath(imagefile)
      side     = (opts['side'] || 'L') == 'L' ? 'left' : 'right'
      imgclass = opts['border'] ? "image-bordered" : nil
      normalize = proc {|s| s =~ /^\A(\d+(\.\d+))%\z/ ? "#{$1.to_f/100.0}\\textwidth" : s }
      imgwidth = normalize.call(imagewidth)
      boxwidth = normalize.call(opts['boxwidth']) || imgwidth
      sepwidth = normalize.call(opts['sep'] || "0pt")
      #
      puts "<div class=\"sideimage\">\n"
      puts "  <div class=\"sideimage-image\" style=\"float:#{side};text-align:center;width:#{boxwidth}\">\n"
      puts "    <img src=\"#{filepath}\" class=\"#{imgclass}\" style=\"width:#{imgwidth}\"/>\n"
      puts "  </div>\n"
      puts "  <div class=\"sideimage-text\" style=\"margin-#{side}:#{boxwidth}\">\n"
      puts "    <div style=\"padding-#{side}:#{sepwidth}\">\n"
      yield
      puts "    </div>\n"
      puts "  </div>\n"
      puts "</div>\n"
    end

    def footnote(id, str)
      id_val = "fn-#{normalize_id(id)}"
      href   = "#fnb-#{normalize_id(id)}"
      text   = compile_inline(str)
      chap_num = @chapter.footnote(id).number
      if @book.config['epubversion'].to_i == 3
        attr = " epub:type=\"footnote\""
        mark = "[*#{chap_num}]"
      else
        attr = ""
        mark = "[<a href=\"#{href}\">*#{chap_num}</a>]"
      end
      #
      if truncate_if_endwith?("</div><!--/.footnote-list-->\n")
      else
        puts "<div class=\"footnote-list\">"
      end
      print "<div class=\"footnote\" id=\"#{id_val}\"#{attr}>"
      print "<p class=\"footnote\">"
      print "<span class=\"footnote-mark\">#{mark} </span>"
      print text
      print "</p>"
      puts  "</div>"
      puts  "</div><!--/.footnote-list-->\n"
    end

    ## nestable inline commands

    def on_inline_i()     ; "<i>#{yield}</i>"           ; end
    def on_inline_b()     ; "<b>#{yield}</b>"           ; end
    def on_inline_code()  ; "<code>#{yield}</code>"     ; end
    def on_inline_tt()    ; "<tt>#{yield}</tt>"         ; end
    def on_inline_del()   ; "<s>#{yield}</s>"           ; end
    def on_inline_sub()   ; "<sub>#{yield}</sub>"       ; end
    def on_inline_sup()   ; "<sup>#{yield}</sup>"       ; end
    def on_inline_em()    ; "<em>#{yield}</em>"         ; end
    def on_inline_strong(); "<strong>#{yield}</strong>" ; end
    def on_inline_u()     ; "<u>#{yield}</u>"           ; end
    def on_inline_ami()   ; "<span class=\"ami\">#{yield}</span>"; end
    def on_inline_balloon(); "<span class=\"balloon\">#{yield}</span>"; end

    def build_inline_href(url, escaped_label)  # compile_href()をベースに改造
      if @book.config['externallink']
        label = escaped_label || escape_html(url)
        "<a href=\"#{escape_html(url)}\" class=\"link\">#{label}</a>"
      elsif escaped_label
        I18n.t('external_link', [escaped_label, escape_html(url)])
      else
        escape_html(url)
      end
    end

    def build_inline_ruby(escaped_word, escaped_yomi)  # compile_ruby()をベースに改造
      pre = I18n.t('ruby_prefix'); post = I18n.t('ruby_postfix')
      if @book.htmlversion == 5
        "<ruby>#{escaped_word}<rp>#{pre}</rp><rt>#{escaped_yomi}</rt><rp>#{post}</rp></ruby>"
      else
        "<ruby><rb>#{escaped_word}</rb><rp>#{pre}</rp><rt>#{escaped_yomi}</rt><rp>#{post}</rp></ruby>"
      end
    end

  end if defined?(HTMLBuilder)


  class PDFMaker

    ### original: 2.4, 2.5
    #def call_hook(hookname)
    #  return if !@config['pdfmaker'].is_a?(Hash) || @config['pdfmaker'][hookname].nil?
    #  hook = File.absolute_path(@config['pdfmaker'][hookname], @basehookdir)
    #  if ENV['REVIEW_SAFE_MODE'].to_i & 1 > 0
    #    warn 'hook configuration is prohibited in safe mode. ignored.'
    #  else
    #    system_or_raise("#{hook} #{Dir.pwd} #{@basehookdir}")
    #  end
    #end
    ### /original

    def call_hook(hookname)    # review-pdfmaker がエラーにならないために
      d = @config['pdfmaker']
      return unless d.is_a?(Hash)
      return unless d[hookname]
      if ENV['REVIEW_SAFE_MODE'].to_i & 1 > 0
        warn 'hook configuration is prohibited in safe mode. ignored.'
        return
      end
      ## hookname が文字列の配列なら、それらを全部実行する
      basehookdir = @basehookdir
      [d[hookname]].flatten.each do |hook|
        script = File.absolute_path(hook, basehookdir)
        ## 拡張子が .rb なら、rubyコマンドで実行する（ファイルに実行属性がなくてもよい）
        if script.end_with?('.rb')
          ruby = ruby_fullpath()
          ruby = "ruby" unless File.exist?(ruby)
          system_or_raise(ruby, script, Dir.pwd, basehookdir)
        else
          system_or_raise(script, Dir.pwd, basehookdir)
        end
      end
    end

    private
    def ruby_fullpath
      require 'rbconfig'
      c = RbConfig::CONFIG
      return File.join(c['bindir'], c['ruby_install_name']) + c['EXEEXT'].to_s
    end

  end unless defined?(AbstractMaker)


  ##
  ## 行番号を生成するクラス。
  ##
  ##   gen = LineNumberGenerator.new("1-3&8-10&15-")
  ##   p gen.each.take(15).to_a
  ##     #=> [1, 2, 3, nil, 8, 9, 10, nil, 15, 16, 17, 18, 19, 20, 21]
  ##
  class LineNumberGenerator

    def initialize(arg)
      @ranges = []
      inf = Float::INFINITY
      case arg
      when true        ; @ranges << (1 .. inf)
      when Integer     ; @ranges << (arg .. inf)
      when /\A(\d+)\z/ ; @ranges << (arg.to_i .. inf)
      else
        arg.split('&', -1).each do |str|
          case str
          when /\A\z/
            @ranges << nil
          when /\A(\d+)\z/
            @ranges << ($1.to_i .. $1.to_i)
          when /\A(\d+)\-(\d+)?\z/
            start = $1.to_i
            end_  = $2 ? $2.to_i : inf
            @ranges << (start..end_)
          else
            raise ArgumentError.new("'#{strpat}': invalid lineno format")
          end
        end
      end
    end

    def each(&block)
      return enum_for(:each) unless block_given?
      for range in @ranges
        range.each(&block) if range
        yield nil
      end
      nil
    end

  end


  ##
  ## Webページ用（HTMLMakerとは違うことに注意）
  ##
  class WEBMaker

    def copy_stylesheet(basetmpdir)
      cssdir = File.join(basetmpdir, "css")
      Dir.mkdir(cssdir) unless File.directory?(cssdir)
      [@config['stylesheet']].flatten.compact.each do |x|
        FileUtils.cp("css/#{x}", cssdir)
      end
    end

    def template_name
      #if @config['htmlversion'].to_i == 5
      #  'web/html/layout-html5.html.erb'
      #else
      #  'web/html/layout-xhtml1.html.erb'
      #end
      "layout.html5.erb"
    end

    def find_template(filename)
      filepath = File.join(@basedir, 'layouts', File.basename(filename))
      return filepath if File.exist?(filepath)
      return File.expand_path(filename, ReVIEW::Template::TEMPLATE_DIR)
    end

    def render_template(filepath)
      return ReVIEW::Template.load(filepath).result(binding())
    end

    def generate_file_with_template(filepath, filename=nil)
      tmpl_filename ||= template_name()
      tmpl_filepath = find_template(tmpl_filename)
      content = render_template(tmpl_filepath)
      File.open(filepath, 'w') {|f| f.write(content) }
      return content
    end

    def _i18n(*args)
      ReVIEW::I18n.t(*args)
    end

    def _join_names(names)
      return join_with_separator(names, _i18n('names_splitter'))
    end

    def _escape(s)
      return CGI.escapeHTML(s)
    end

    def build_part(part, basetmpdir, htmlfile)
      part_name = part.name.strip
      #
      sb = ""
      sb << "<div class=\"part\">\n"
      sb << "<h1 class=\"part-number\">#{_i18n('part', part.number)}</h1>\n"
      sb << "<h2 class=\"part-title\">#{part_name}</h2>\n" if part_name.present?
      sb << "</div>\n"
      @body = sb
      @language = @config['language']
      @stylesheets = @config['stylesheet']
      #
      generate_file_with_template("#{basetmpdir}/#{htmlfile}")
    end

    def build_indexpage(basetmpdir)
      if @config['coverimage']
        imgfile = File.join(@config['imagedir'], @config['coverimage'])
      else
        imgfile = nil
      end
      #
      sb = ""
      if imgfile
        sb << "  <div id=\"cover-image\" class=\"cover-image\">\n"
        sb << "    <img src=\"#{imgfile}\" class=\"max\"/>\n"
        sb << "  </div>\n"
      end
      @body = sb
      @language = @config['language']
      @stylesheets = @config['stylesheet']
      @toc = ReVIEW::WEBTOCPrinter.book_to_html(@book, nil)
      @next = @book.chapters[0]
      @next_title = @next ? @next.title : ''
      #
      generate_file_with_template("#{basetmpdir}/index.html")
    end

    def build_titlepage(basetmpdir, htmlfile)
      author    = @config['aut'] ? _join_names(@config.names_of('aut')) : nil
      publisher = @config['pbl'] ? _join_names(@config.names_of('pbl')) : nil
      #
      sb = ""
      sb << "<div class=\"titlepage\">\n"
      sb << "<h1 class=\"tp-title\">#{_escape(@config.name_of('booktitle'))}</h1>\n"
      sb << "<h2 class=\"tp-author\">#{author}</h2>\n"        if author
      sb << "<h3 class=\"tp-publisher\">#{publisher}</h3>\n"  if publisher
      sb << "</div>\n"
      @body = sb
      @language = @config['language']
      @stylesheets = @config['stylesheet']
      #
      generate_file_with_template("#{basetmpdir}/#{htmlfile}")
    end

  end


  class WEBTOCPrinter

    def self.book_to_html(book, current_chapter)
      printer = self.new(nil, nil, nil)
      arr = printer.handle_book(book, current_chapter)
      html = printer.render_html(arr)
      return html
    end

    def render_html(arr)
      tag, attr, children = arr
      tag == "book"  or raise "internal error: tag=#{tag.inspect}"
      buf = "<ul class=\"toc toc-1\">\n"
      children.each do |child|
        _render_li(child, buf, 1)
      end
      buf << "</ul>\n"
      return buf
    end

    def parse_inline(str)
      builder = HTMLBuilder.new
      builder.instance_variable_set('@book', @_book)
      @compiler ||= Compiler.new(builder)
      return @compiler.text(str)
    end

    def _render_li(arr, buf, n)
      tag, attr, children = arr
      case tag
      when "part"
        buf << "<li class=\"toc-part\">#{parse_inline(attr[:label])}\n"
        buf << "  <ul class=\"toc toc-#{n+1}\">\n"
        children.each {|child| _render_li(child, buf, n+1) }
        buf << "  </ul>\n"
        buf << "</li>\n"
      when "chapter"
        buf << "    <li class=\"toc-chapter\"><a href=\"#{h attr[:path]}\">#{parse_inline(attr[:label])}</a>"
        if children && !children.empty?
          buf << "\n      <ul class=\"toc toc-#{n+1}\">\n"
          children.each {|child| _render_li(child, buf, n+1) }
          buf << "      </ul>\n"
          buf << "    </li>\n"
        else
          buf << "</li>\n"
        end
      when "section"
        buf << "        <li class=\"toc-section\"><a href=\"##{attr[:anchor]}\">#{parse_inline(attr[:label])}</a></li>\n"
      end
      buf
    end

    def handle_book(book, current_chapter)
      @_book = book
      children = []
      book.each_part do |part|
        if part.number
          children << handle_part(part, current_chapter)
        else
          part.each_chapter do |chap|
            children << handle_chapter(chap, current_chapter)
          end
        end
      end
      #
      attrs = {
        title: book.config['booktitle'],
        subtitle: book.config['subtitle'],
      }
      return ["book", attrs, children]
    end

    def handle_part(part, current_chapter)
      children = []
      part.each_chapter do |chap|
        children << handle_chapter(chap, current_chapter)
      end
      #
      attrs = {
        number: part.number,
        title:  part.title,
        #label:  "#{I18n.t('part_short', part.number)} #{part.title}",
        label:  "#{I18n.t('part', part.number)} #{part.title}",
      }
      return ["part", attrs, children]
    end

    def handle_chapter(chap, current_chapter)
      children = []
      if current_chapter.nil? || chap == current_chapter
        chap.headline_index.each do |sec|
          next if sec.number.present? && sec.number.length >= 2
          children << handle_section(sec, chap)
        end
      end
      #
      chap_node = TOCParser.chapter_node(chap)
      ext   = chap.book.config['htmlext'] || 'html'
      path  = chap.path.sub(/\.re\z/, ".#{ext}")
      label = if chap_node.number && chap.on_chaps?
                "#{I18n.t('chapter_short', chap.number)} #{chap.title}"
              else
                chap.title
              end
      #
      attrs = {
        number: chap_node.number,
        title:  chap.title,
        label:  label,
        path:   path,
      }
      return ["chapter", attrs, children]
    end

    def handle_section(sec, chap)
      if chap.number && sec.number.length > 0
        number = [chap.number] + sec.number
        label  = "#{number.join('.')} #{sec.caption}"
      else
        number = nil
        label  = sec.caption
      end
      attrs = {
        number: number,
        title:  sec.caption,
        label:  label,
        anchor: "h#{number ? number.join('-') : ''}",
      }
      return ["section", attrs, []]
    end

  end


end
