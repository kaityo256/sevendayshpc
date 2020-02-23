# -*- coding: utf-8 -*-


##
## Docker用のタスク。
##
namespace :docker do

  docker_image = ENV['DOCKER_IMAGE']
  docker_image = "kauplan/review2.5" if docker_image.to_s.empty?
  docker_opts  = "--rm -v $PWD:/work"
  docker_opts += ENV.keys().grep(/^STARTER_/).map {|k| " -e #{k}" }.join()

  desc "+ pull docker image for building PDF file"
  task :setup do
    sh "docker pull #{docker_image}"
  end

  docker_run = proc do |command|
    cmd = "/bin/bash -c 'cd work; #{command}'"
    sh "docker run #{docker_opts} #{docker_image} #{cmd}"
  end

  desc "+ run 'rake pdf' on docker"
  task :pdf do docker_run.call('rake pdf') end

  desc "+ run 'rake pdf:nombre' on docker"
  task :'pdf:nombre' do docker_run.call('rake pdf:nombre') end

  desc "+ run 'rake epub' on docker"
  task :epub do docker_run.call('rake epub') end

  desc "+ run 'rake web' on docker"
  task :web do docker_run.call('rake web') end

end


##
## PDFにノンブルを入れるためのRakeタスク。
## ノンブルについては「ワンストップ！技術同人誌を書こう」第10章を参照のこと。
## https://booth.pm/ja/items/708196
##
namespace :pdf do

  desc "+ add nombre (rake pdf:nombre [file=*.pdf] [out=*.pdf])"
  task :nombre do
    infile  = ENV['file']; infile  = nil if infile  && infile.empty?
    outfile = ENV['out'] ; outfile = nil if outfile && outfile.empty?
    #
    begin
      require 'combine_pdf'
    rescue LoadError
      abort "ERROR: 'combine_pdf' gem not installed; please run `gem install combine_pdf` at first."
    end
    #
    class CombinePDF::PDF
      def add_nombre(options={})
        start    = options[:start]    || 1
        margin_h = options[:margin_h] || 5
        margin_w = options[:margin_w] || 2
        font     = options[:font]     || :Helvetica
        size     = options[:size]     || 6
        color    = options[:color]    || [0.5, 0.5, 0.5]  # gray
        binding  = options[:binding]  || :left
        digit_w, digit_h = CombinePDF::Fonts.dimensions_of("9", font, size)
        box_w = digit_w * 1.2
        box_h = digit_h * 1.3
        is_left = binding == :left
        params = {
          x: nil, y: nil, width: box_w, height: box_h,
          font: font, font_size: size, font_color: color,
        }
        self.pages.each.with_index(start) do |page, page_num|
          mediabox = page[:CropBox] || page[:MediaBox]  or
            abort "ERROR: failed to get page size of pdf"
          page_w = mediabox[2]
          page_h = mediabox[3]
          top    = page_h - margin_h
          bottom = margin_h
          left   = margin_w
          right  = page_w - margin_w - box_w
          params[:x] = is_left ? left : right
          params[:y] = bottom
          page_num.to_s.reverse.each_char do |c|
            page.textbox(c, params)
            params[:y] += box_h
          end
          is_left = ! is_left
        end
        self
      end
    end
    #
    if infile.nil?
      require 'yaml'
      config = File.open("config.yml", 'r', encoding: 'utf-8') {|f| YAML.load(f) }
      bookname = config['bookname']  or abort("ERROR: missing 'bookname' in config.yml")
      infile = bookname + ".pdf"
    end
    File.file?(infile)  or abort("ERROR: #{infile}: pdf file not found.")
    if outfile.nil?
      #outfile = infile.sub(/\.pdf$/, '_nombre.pdf')
      outfile = infile
    end
    #
    #pdf = CombinePDF.parse(File.binread(infile))
    #pdf.add_nombre()
    #File.binwrite(outfile, pdf.to_pdf())
    pdf = CombinePDF.load(infile)
    pdf.add_nombre()
    pdf.save(outfile)
  end

end


##
## 高解像度用の画像から低解像度の画像を生成するRakeタスク。
## 詳細は「ワンストップ！技術同人誌を書こう」第8章を参照のこと。
## https://booth.pm/ja/items/708196
##
desc "+ convert images (high resolution -> low resolution)"
task :images do
  ## macOSならsipsコマンドを使い、それ以外ではImageMagickを使う
  has_sips = File.exist?("/usr/bin/sips")
  if ! has_sips
    ok = system("convert --version >/dev/null")
    if ! ok
      abort "ERROR: 'convert' command not found; please install ImageMagick."
    end
  end
  ## 高解像度の画像をもとに低解像度の画像を作成する
  for src in Dir.glob("images_highres/**/*.{png,jpg,jpeg}")
    ## 低解像度の画像を作成済みなら残りの処理をスキップ
    dest = src.sub("images_highres/", "images_lowres/")
    next if File.exist?(dest) && File.mtime(src) == File.mtime(dest)
    ## 必要ならフォルダを作成
    dir = File.dirname(dest)
    mkdir_p dir if ! File.directory?(dir)
    ## 高解像度の画像のDPIを変更（72dpi→360dpi）
    if has_sips
      sh "sips -s dpiHeight 360 -s dpiWidth 360 #{src}"
    else
      sh "convert -density 360 -units PixelsPerInch #{src} #{src}"
    end
    ## 低解像度の画像を作成（72dpi、横幅1/5）
    if has_sips
      `sips -g pixelWidth #{src}` =~ /pixelWidth: (\d+)/
      option = "-s dpiHeight 72 -s dpiWidth 72 --resampleWidth #{$1.to_i / 5}"
      sh "sips #{option} --out #{dest} #{src}"
    else
      sh "convert -density 72 -units PixelsPerInch -resize 20% #{src} #{dest}"
    end
    ## 低解像度の画像のタイムスタンプを、高解像度の画像と同じにする
    ## （＝画像のタイムスタンプが違ったら、画像が更新されたと見なす）
    File.utime(File.atime(dest), File.mtime(src), dest)
  end
  ## 高解像度の画像が消されたら、低解像度の画像も消す
  for dest in Dir.glob("images_lowres/**/*").sort().reverse()
    src = dest.sub("images_lowres/", "images_highres/")
    rm_r dest if ! File.exist?(src)
  end
end


##
## 低解像度と高解像度を切り替えるRakeタスク。
## 詳細は「ワンストップ！技術同人誌を書こう」第8章を参照のこと。
## https://booth.pm/ja/items/708196
##
namespace "images" do

  desc "+ toggle image directories ('images_{lowres,highres}')"
  task :toggle do
    if ! File.symlink?("images")
      msg =  "ERROR: 'images' directory should be a symbolic link.\n"
      msg << "       rename it and create symbolic link, for example:\n"
      msg << "  $ mv images images_highres\n"
      msg << "  $ ln -s images_highres images\n"
      abort msg
    end
    link = File.readlink("images")
    rm "images"
    if link == "images_lowres"
      ln_s "images_highres", "images"
    else
      ln_s "images_lowres", "images"
    end
  end

end
