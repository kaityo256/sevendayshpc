all: a.out

a.out: simdcheck.cpp
	g++ -mavx2 -O3 $<

clean:
	rm -f a.out
