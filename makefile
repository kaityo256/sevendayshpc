MD=$(shell ls day?/README.md *.md)
all: $(MD:%.md=%.pdf) clean_intermediate
PANDOCOPT=-s -V documentclass=ltjarticle -V geometry:margin=1in

.SUFFIXES: .md .tex. pdf

%.pdf: %.md
	pandoc $< -o $(@:%.pdf=%.tex) $(PANDOCOPT)
	cd $(dir $@);lualatex $(notdir $*).tex

.PHONY: clean clean_intermediate

clean_intermediate:
	rm -f $(MD:%.md=%.tex)
	rm -f $(MD:%.md=%.log)
	rm -f $(MD:%.md=%.aux)
	rm -f $(MD:%.md=%.out)

clean: clean_intermediate
	rm -f $(MD:%.md=%.pdf)
