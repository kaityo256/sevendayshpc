all: a.out b.out

a.out: gather2d.cpp
	mpic++ -std=c++11 $< -o $@

b.out: sendrecv.cpp
	mpic++ -std=c++11 $< -o $@

clean:
	rm -f a.out b.out
