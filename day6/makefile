SRC=$(shell ls gs*.cpp)
EXE=$(SRC:.cpp=.out)

all: $(EXE) $(SRC)

CC=g++
CPPFLAGS= -O3 -mavx2 -std=c++11 -fopenmp

#CC=icpc
#CPPFLAGS= -O3 -xHOST -std=c++11 -qopenmp

.cpp.out:
	$(CC) $(CPPFLAGS) $< -o $@

#a.out: gs_omp.cpp

data:
	OMP_NUM_THREADS=1 ./gs_omp1.out | grep threads > gs_omp1.txt
	OMP_NUM_THREADS=2 ./gs_omp1.out | grep threads >> gs_omp1.txt
	OMP_NUM_THREADS=4 ./gs_omp1.out | grep threads >> gs_omp1.txt
	OMP_NUM_THREADS=8 ./gs_omp1.out | grep threads >> gs_omp1.txt
	OMP_NUM_THREADS=12 ./gs_omp1.out | grep threads >> gs_omp1.txt
	OMP_NUM_THREADS=18 ./gs_omp1.out | grep threads >> gs_omp1.txt
	OMP_NUM_THREADS=24 ./gs_omp1.out | grep threads >> gs_omp1.txt
	OMP_NUM_THREADS=1 ./gs_omp2.out | grep threads > gs_omp2.txt
	OMP_NUM_THREADS=2 ./gs_omp2.out | grep threads >> gs_omp2.txt
	OMP_NUM_THREADS=4 ./gs_omp2.out | grep threads >> gs_omp2.txt
	OMP_NUM_THREADS=8 ./gs_omp2.out | grep threads >> gs_omp2.txt
	OMP_NUM_THREADS=12 ./gs_omp2.out | grep threads >> gs_omp2.txt
	OMP_NUM_THREADS=18 ./gs_omp2.out | grep threads >> gs_omp2.txt
	OMP_NUM_THREADS=24 ./gs_omp2.out | grep threads >> gs_omp2.txt

perf1:
	OMP_NUM_THREADS=1 perf record ./gs_omp1.out > gs_omp1.perf
	perf report --stdio --sort dso | grep -E "gs_omp1.out" >> gs_omp1.perf
	OMP_NUM_THREADS=2 perf record ./gs_omp1.out >> gs_omp1.perf
	perf report --stdio --sort dso | grep -E "gs_omp1.out" >> gs_omp1.perf
	OMP_NUM_THREADS=4 perf record ./gs_omp1.out >> gs_omp1.perf
	perf report --stdio --sort dso | grep -E "gs_omp1.out" >> gs_omp1.perf
	OMP_NUM_THREADS=8 perf record ./gs_omp1.out >> gs_omp1.perf
	perf report --stdio --sort dso | grep -E "gs_omp1.out" >> gs_omp1.perf
	OMP_NUM_THREADS=12 perf record ./gs_omp1.out >> gs_omp1.perf
	perf report --stdio --sort dso | grep -E "gs_omp1.out" >> gs_omp1.perf
	OMP_NUM_THREADS=18 perf record ./gs_omp1.out >> gs_omp1.perf
	perf report --stdio --sort dso | grep -E "gs_omp1.out" >> gs_omp1.perf
	OMP_NUM_THREADS=24 perf record ./gs_omp1.out >> gs_omp1.perf
	perf report --stdio --sort dso | grep -E "gs_omp1.out" >> gs_omp1.perf

perf2:
	OMP_NUM_THREADS=1 perf record ./gs_omp2.out > gs_omp2.perf
	perf report --stdio --sort dso | grep -E "gs_omp2.out" >> gs_omp2.perf
	OMP_NUM_THREADS=2 perf record ./gs_omp2.out >> gs_omp2.perf
	perf report --stdio --sort dso | grep -E "gs_omp2.out" >> gs_omp2.perf
	OMP_NUM_THREADS=4 perf record ./gs_omp2.out >> gs_omp2.perf
	perf report --stdio --sort dso | grep -E "gs_omp2.out" >> gs_omp2.perf
	OMP_NUM_THREADS=8 perf record ./gs_omp2.out >> gs_omp2.perf
	perf report --stdio --sort dso | grep -E "gs_omp2.out" >> gs_omp2.perf
	OMP_NUM_THREADS=12 perf record ./gs_omp2.out >> gs_omp2.perf
	perf report --stdio --sort dso | grep -E "gs_omp2.out" >> gs_omp2.perf
	OMP_NUM_THREADS=18 perf record ./gs_omp2.out >> gs_omp2.perf
	perf report --stdio --sort dso | grep -E "gs_omp2.out" >> gs_omp2.perf
	OMP_NUM_THREADS=24 perf record ./gs_omp2.out >> gs_omp2.perf
	perf report --stdio --sort dso | grep -E "gs_omp2.out" >> gs_omp2.perf
clean:
	rm -f $(EXE)
