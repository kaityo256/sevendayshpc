#include <cstdio>
#ifdef _WIN32
#include <Windows.h>
#include <process.h>
#else  // _WIN32
#include <sys/types.h>
#include <unistd.h>
#endif  // _WIN32
#include <mpi.h>

namespace hpc {

int getpid() {
#ifdef _WIN32
  return ::_getpid();
#else   // _WIN32
  return ::getpid();
#endif  // _WIN32
}

void sleep(int seconds) {
#ifdef _WIN32
  const DWORD milliseconds = seconds * 1000;
  ::Sleep(milliseconds);
#else   // _WIN32
  ::sleep(seconds);
#endif  // _WIN32
}

}  // namespace hpc

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  printf("Rank %d: PID %d\n", rank, hpc::getpid());
  fflush(stdout);
  int i = 0;
  int sum = 0;
  while (i == rank) {
    hpc::sleep(1);
  }
  MPI_Allreduce(&rank, &sum, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
  printf("%d\n", sum);
  MPI_Finalize();
}
