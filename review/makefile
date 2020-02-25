all: sevendayshpc.pdf
RE=preface.re day1.re day2.re day3.re day4.re day5.re day6.re day7.re postface.re

imgcopy:
	cp ../preface/fig/*.png images/preface
	cp ../day1/fig/*.png images/day1
	cp ../day2/fig/*.png images/day2
	cp ../day3/fig/*.png images/day3
	cp ../day4/fig/*.png images/day4
	cp ../day5/fig/*.png images/day5
	cp ../day6/fig/*.png images/day6
	cp ../day7/fig/*.png images/day7

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
	docker run --rm -v `pwd`/:/work kauplan/review2.5 /bin/bash -c "cd /work; rake pdf"
	#docker run -it --rm -v C:\\Users\\watanabe\\Desktop\\github\\sevendayshpc\\review:/work kauplan/review2.5 /bin/bash -c "cd /work;rake pdf"


clean:
	rm -f sevendayshpc.pdf
