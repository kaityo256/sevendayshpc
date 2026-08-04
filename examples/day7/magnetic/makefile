all: a.out b.out c.out

CC=g++
CPPFLAGS=-std=c++11 -O3 -mavx2 -mfma

-include makefile.opt

a.out: mag.cpp
	$(CC) $(CPPFLAGS) $< -o $@

b.out: mag_simd.cpp
	$(CC) $(CPPFLAGS) $< -o $@

c.out: mag_soa.cpp
	$(CC) $(CPPFLAGS) $< -o $@

test: a.out b.out c.out
	time ./a.out > a.txt
	time ./b.out > b.txt
	time ./c.out > c.txt
	diff a.txt b.txt
	diff a.txt c.txt

clean:
	rm -f a.out b.out c.out a.txt b.txt c.txt
