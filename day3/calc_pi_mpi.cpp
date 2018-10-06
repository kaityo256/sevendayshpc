#include <cstdio>
#include <random>
#include <algorithm>
#include <mpi.h>

double calc_pi(std::mt19937 &mt, const int trial) {
  std::uniform_real_distribution<double> ud(0.0, 1.0);
  int n = 0;
  for (int i = 0; i < trial; i++) {
    double x = ud(mt);
    double y = ud(mt);
    if (x * x + y * y < 1.0) n++;
  }
  return 4.0 * static_cast<double>(n) / static_cast<double>(trial);
}

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  std::mt19937 mt(rank);
  double pi = calc_pi(mt, 100000);
  printf("%d: %f\n", rank, pi);
  MPI_Finalize();
}
