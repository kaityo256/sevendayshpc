#include <cstdio>
#include <mpi.h>
#include <cassert>
#include <vector>

const int L = 8;

struct MPIinfo {
  int rank;
  int procs;
  int GX, GY;
  int local_grid_x, local_grid_y;
  int local_size_x, local_size_y;
};

void init(std::vector<int> &local_data, MPIinfo &mi) {
  const int offset = mi.local_size_x * mi.local_size_y * mi.rank;
  for (int iy = 0; iy < mi.local_size_y; iy++) {
    for (int ix = 0; ix < mi.local_size_x; ix++) {
      int index = (ix + 1) + (iy + 1) * (mi.local_size_x + 2);
      int value = ix + iy * mi.local_size_x + offset;
      local_data[index] = value;
    }
  }
}

void dump_local_sub(std::vector<int> &local_data, MPIinfo &mi) {
  printf("rank = %d\n", mi.rank);
  for (int iy = 0; iy < mi.local_size_y + 2; iy++) {
    for (int ix = 0; ix < mi.local_size_x + 2; ix++) {
      unsigned int index = ix + iy * (mi.local_size_x + 2);
      printf(" %03d", local_data[index]);
    }
    printf("\n");
  }
  printf("\n");
}

void dump_local(std::vector<int> &local_data, MPIinfo &mi) {
  for (int i = 0; i < mi.procs; i++) {
    MPI_Barrier(MPI_COMM_WORLD);
    if (i == mi.rank) {
      dump_local_sub(local_data, mi);
    }
  }
}

void setup_info(MPIinfo &mi) {
  int rank = 0;
  int procs = 0;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &procs);
  int d2[2] = {};
  MPI_Dims_create(procs, 2, d2);
  mi.rank = rank;
  mi.procs = procs;
  mi.GX = d2[0];
  mi.GY = d2[1];
  mi.local_grid_x = rank % mi.GX;
  mi.local_grid_y = rank / mi.GX;
  mi.local_size_x = L / mi.GX;
  mi.local_size_y = L / mi.GY;
}

// 自分から見て +dx, +dyだけずれたプロセスのランクを返す
int get_rank(int dx, int dy, MPIinfo &mi) {
  int rx = (mi.local_grid_x + dx + mi.GX) % mi.GX;
  int ry = (mi.local_grid_y + dy + mi.GY) % mi.GY;
  return rx + ry * mi.GX;
}

void sendrecv_x(std::vector<int> &local_data, MPIinfo &mi) {
  const int lx = mi.local_size_x;
  const int ly = mi.local_size_y;
  std::vector<int> sendbuf(ly);
  std::vector<int> recvbuf(ly);
  int left = get_rank(-1, 0, mi);
  int right = get_rank(1, 0, mi);
  for (int i = 0; i < ly; i++) {
    int index = lx + (i + 1) * (lx + 2);
    sendbuf[i] = local_data[index];
  }
  MPI_Status st;
  MPI_Sendrecv(sendbuf.data(), ly, MPI_INT, right, 0,
               recvbuf.data(), ly, MPI_INT, left, 0, MPI_COMM_WORLD, &st);
  for (int i = 0; i < ly; i++) {
    int index = (i + 1) * (lx + 2);
    local_data[index] = recvbuf[i];
  }

  for (int i = 0; i < ly; i++) {
    int index = 1 + (i + 1) * (lx + 2);
    sendbuf[i] = local_data[index];
  }
  MPI_Sendrecv(sendbuf.data(), ly, MPI_INT, left, 0,
               recvbuf.data(), ly, MPI_INT, right, 0, MPI_COMM_WORLD, &st);
  for (int i = 0; i < ly; i++) {
    int index = lx + 1 + (i + 1) * (lx + 2);
    local_data[index] = recvbuf[i];
  }
}

void sendrecv_y(std::vector<int> &local_data, MPIinfo &mi) {
  const int lx = mi.local_size_x;
  const int ly = mi.local_size_y;
  std::vector<int> sendbuf(lx + 2);
  std::vector<int> recvbuf(lx + 2);
  int up = get_rank(0, -1, mi);
  int down = get_rank(0, 1, mi);
  MPI_Status st;
  // 上に投げて下から受け取る
  for (int i = 0; i < lx + 2; i++) {
    int index = i + 1 * (lx + 2);
    sendbuf[i] = local_data[index];
  }
  MPI_Sendrecv(sendbuf.data(), lx + 2, MPI_INT, up, 0,
               recvbuf.data(), lx + 2, MPI_INT, down, 0, MPI_COMM_WORLD, &st);
  for (int i = 0; i < lx + 2; i++) {
    int index = i + (ly + 1) * (lx + 2);
    local_data[index] = recvbuf[i];
  }
  // 下に投げて上から受け取る
  for (int i = 0; i < lx + 2; i++) {
    int index = i + (ly) * (lx + 2);
    sendbuf[i] = local_data[index];
  }
  MPI_Sendrecv(sendbuf.data(), lx + 2, MPI_INT, down, 0,
               recvbuf.data(), lx + 2, MPI_INT, up, 0, MPI_COMM_WORLD, &st);
  for (int i = 0; i < lx + 2; i++) {
    int index = i + 0 * (lx + 2);
    local_data[index] = recvbuf[i];
  }
}

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  MPIinfo mi;
  setup_info(mi);
  // ローカルデータの確保
  std::vector<int> local_data((mi.local_size_x + 2) * (mi.local_size_y + 2), 0);
  // ローカルデータの初期化
  init(local_data, mi);
  // ローカルデータの表示
  dump_local(local_data, mi);
  // x方向に通信
  sendrecv_x(local_data, mi);
  dump_local(local_data, mi);
  sendrecv_y(local_data, mi);
  dump_local(local_data, mi);
  MPI_Finalize();
}
