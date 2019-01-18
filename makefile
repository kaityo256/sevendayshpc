MD=$(shell ls day?/README.md *.md)
all: sevendayshpc.pdf
sevendayshpc.pdf: $(MD:%.md=%.pdf)
	pdftk README.pdf day1/README.pdf day2/README.pdf day3/README.pdf day4/README.pdf day5/README.pdf day6/README.pdf day7/README.pdf conclusion/README.pdf cat output sevendayshpc.pdf

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
