TARGET=$(shell ls */README.md | sed 's/README.md/index.html/')
PANDOC=pandoc -s --mathjax -t html --template=template --shift-heading-level-by=-1

all: $(TARGET)


%/index.html: %/README.md
	$(PANDOC) $< -o $@

clean:
	rm -f $(TARGET)
