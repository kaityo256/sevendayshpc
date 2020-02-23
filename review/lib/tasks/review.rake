require 'fileutils'
require 'rake/clean'

BOOK = 'book'
BOOK_PDF = BOOK + '.pdf'
BOOK_EPUB = BOOK + '.epub'
CONFIG_FILE = 'config.yml'
WEBROOT = 'webroot'

def build(mode, chapter)
  sh "review-compile --target=#{mode} --footnotetext --stylesheet=style.css #{chapter} > tmp"
  mode_ext = { 'html' => 'html', 'latex' => 'tex', 'idgxml' => 'xml' }
  FileUtils.mv 'tmp', chapter.gsub(/re\z/, mode_ext[mode])
end

def build_all(mode)
  sh "review-compile --target=#{mode} --footnotetext --stylesheet=style.css"
end

def config_file()
  conf = ENV['config']
  conf = CONFIG_FILE if conf.nil? || conf.empty?
  return conf
end

task default: :html_all

desc 'build html (Usage: rake build re=target.re)'
task :html => :prepare do
  if ENV['re'].nil?
    puts 'Usage: rake build re=target.re'
    exit
  end
  build('html', ENV['re'])
end

desc 'build all html'
task :html_all => :prepare do
  build_all('html')
end

desc 'preproc all'
task :preproc => :prepare do
  Dir.glob('*.re').each do |file|
    sh "review-preproc --replace #{file}"
  end
end

desc 'generate PDF and EPUB file'
task all: %i[pdf epub]

desc 'generate PDF file'
task :pdf => :prepare do
  require 'review'
  #require 'review/pdfmaker'
  require './lib/ruby/review-pdfmaker'
  #
  FileUtils.rm_rf [BOOK_PDF, BOOK, BOOK + '-pdf']
  begin
    ReVIEW::PDFMaker.execute(config_file())
  rescue RuntimeError => ex
    if ex.message =~ /^failed to run command:/
      abort "*\n* ERROR (review-pdfmaker):\n*  #{ex.message}\n*"
    else
      raise
    end
  end
end

desc 'generate EPUB file'
task :epub => :prepare do
  FileUtils.rm_rf [BOOK_EPUB, BOOK, BOOK + '-epub']
  sh "review-epubmaker #{config_file()}"
end

desc 'generate stagic HTML file for web'
task :web => :prepare do
  FileUtils.rm_rf [WEBROOT]
  sh "review-webmaker #{config_file()}"
end


#desc "+ copy *.re files under 'contents/' into here."
task :prepare do
  require 'yaml'
  config = YAML.load_file(config_file())
  PREPARES.each do |x|
    case x
    when Proc; x.call(config)
    else     ; __send__(x, config)
    end
  end
end

## 前処理を追加したい場合は、関数名またはProcオブジェクトをこの配列に追加する
PREPARES = [:copy_files_under_contentdir]

def copy_files_under_contentdir(config)
  ## 設定ファイル (config.yml) の「contentdir:」の値を調べる
  contdir = config['contentdir']
  if contdir && contdir != '.'  # '.' はカレントディレクトリを表すので対象外
    ## もし contentdir が存在しなければエラー
    unless File.directory?(contdir)
      abort_with_message <<END
ERROR: Content directory '#{contdir}' not exist.
       Please check 'contentdir:' value in config file,
       or create '#{contdir}' directory and put *.re files into there.
END
    end
    ## カレントディレクトリに *.re ファイルがあればエラー
    unless Dir.glob('*.re').empty?
      re_file = Dir.glob('*.re').sort.first
      abort_with_message <<END
ERROR: File '#{re_file}' found in current directory.
       When 'contentdir:' specifieid in config file,
       you must put all *.re files into that directory.
       Please remove *.re files from current directory.
END
    end
    ## contentdir にある *.re ファイルをカレントディレクトリにコピー
    cp Dir.glob(File.join(contdir, '*.re')), '.', :verbose=>false
    ## コピーしたファイルをRakeプロセス終了時に削除
    at_exit { rm_f Dir.glob('*.re'), :verbose=>false }
  end
end

def abort_with_message(error_msg)
  $stderr.puts "***"
  $stderr.puts error_msg.gsub(/^/, '*** ')
  $stderr.puts "***"
  abort()
end


CLEAN.include([BOOK, BOOK_PDF, BOOK_EPUB, BOOK + '-pdf', BOOK + '-epub', WEBROOT, 'images/_review_math'])
