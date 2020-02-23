
def escape_underscore(str)
  str.gsub('_','@<underscore>') 
end

def escape_inline_math(str)
  while str =~ /\$(.*?)\$/
    math = escape_underscore($1)
    str = $` + "@<m>|" + math + "|" + $'
  end
  str
end

def in_math
  while line=gets
    if line=~/\$\$/
      puts "//}"
      return
    else
      puts escape_underscore(line)
    end
  end
end

while line=gets
  if line=~/\$\$/
    puts "//texequation{"
    in_math
  else
    puts escape_inline_math(line)
  end
end
