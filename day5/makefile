all: a.out b.out

a.out: gs.cpp
	g++ -O3 $< -o $@

b.out: gs_mpi.cpp
	mpic++ -O3 $< -o $@

clean:
	rm -f a.out b.out

clear: clean
	rm -f *.png *.dat
