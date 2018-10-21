#include <cstdio>
#include <mpi.h>

int rank;

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  printf("rank = %d, address = %x\n", rank, &rank);
  MPI_Finalize();
}
