TARGET=$(shell ls */README.md | sed 's/README.md/index.html/')
PANDOC=pandoc -s --mathjax -t html --template=template --shift-heading-level-by=-1

all: $(TARGET) index.html

index.html: README.md
	sed 's/README.md/index.html/' README.md > index.md
	$(PANDOC) index.md -o $@
	rm -f index.md


%/index.html: %/README.md
	$(PANDOC) $< -o $@

clean:
	rm -f $(TARGET) index.html
