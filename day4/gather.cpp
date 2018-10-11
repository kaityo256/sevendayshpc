#include <cstdio>
#include <mpi.h>
#include <vector>

const int L = 8;

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank, procs;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &procs);
  const int mysize = L / procs;
  // ローカルなデータ(自分のrank番号で初期化)
  std::vector<int> local(mysize, rank);
  // 受け取り用のグローバルデータ
  std::vector<int> global(L);
  // 通信(ランク0番に集める)
  MPI_Gather(local.data(), mysize, MPI_INT, global.data(), mysize, MPI_INT, 0,  MPI_COMM_WORLD);

  // ランク0番が代表して表示
  if (rank == 0) {
    for (int i = 0; i < L; i++) {
      printf("%d", global[i]);
    }
    printf("\n");
  }
  MPI_Finalize();
}
