all: sevendayshpc.pdf
RE=preface.re day1.re day2.re day3.re day4.re day5.re day6.re day7.re postface.re

preface.md: ../preface/README.md
	cp $< $@

postface.md: ../conclusion/README.md
	cp $< $@

day1.md: ../day1/README.md
	cp $< $@

day2.md: ../day2/README.md
	cp $< $@

day3.md: ../day3/README.md
	cp $< $@

day4.md: ../day4/README.md
	cp $< $@

day5.md: ../day5/README.md
	cp $< $@
	
day6.md: ../day6/README.md
	cp $< $@

day7.md: ../day7/README.md
	cp $< $@


%.re: %.md
	ruby pre.rb $^ > $*.pre
	md2review $*.pre > $*.post
	ruby post.rb $*.post > $*.re

sevendayshpc.pdf: config.yml $(RE)
	docker run -it --rm -v C:\\Users\\watanabe\\Desktop\\github\\sevendayshpc\\review:/work kauplan/review2.5 /bin/bash -c "cd /work;rake pdf"


clean:
	rm -f sevendayshpc.pdf
