def escape_underscore(str)
  str.gsub("_", "@<underscore>")
end

def escape_inline_math(str)
  while str =~ /\$(.*?)\$/
    math = escape_underscore($1)
    str = $` + "@<m>|" + math + "|" + $'
  end
  str
end

def replace_review_command(line)
  return line if line !~ /^<!---(.*)--->$/

  key = $1.strip
  return "//}" if key == "end"

  line = "//#{key}\{"
  line
end

def in_math
  while (line = gets)
    if line=~/\$\$/
      puts "//}"
      return
    else
      puts escape_underscore(line)
    end
  end
end

while (line = gets)
  if line=~/\$\$/
    puts "//texequation{"
    in_math
  else
    line = replace_review_command(line)
    puts escape_inline_math(line)
  end
end
