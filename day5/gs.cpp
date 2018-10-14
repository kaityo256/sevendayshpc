#include <iostream>
#include <iomanip>
#include <vector>
#include <fstream>
#include <algorithm>

const int L = 128;
const int V = L * L;
const double F = 0.04;
const double k = 0.06075;
const double dt = 0.2;
const double Du = 0.05;
const double Dv = 0.1;

typedef std::vector<double> vd;

void init(vd &u, vd &v) {
  int d = 3;
  for (int i = L / 2 - d; i < L / 2 + d; i++) {
    for (int j = L / 2 - d; j < L / 2 + d; j++) {
      u[j + i * L] = 0.7;
    }
  }
  d = 6;
  for (int i = L / 2 - d; i < L / 2 + d; i++) {
    for (int j = L / 2 - d; j < L / 2 + d; j++) {
      v[j + i * L] = 0.9;
    }
  }
}

double calcU(double tu, double tv) {
  return tu * tu * tv - (F + k) * tu;
}

double calcV(double tu, double tv) {
  return -tu * tu * tv + F * (1.0 - tv);
}

double laplacian(int ix, int iy, vd &s) {
  double ts = 0.0;
  ts += s[ix - 1 + iy * L];
  ts += s[ix + 1 + iy * L];
  ts += s[ix + (iy - 1) * L];
  ts += s[ix + (iy + 1) * L];
  ts -= 4.0 * s[ix + iy * L];
  return ts;
}

void calc(vd &u, vd &v, vd &u2, vd &v2) {
  for (int iy = 1; iy < L - 1; iy++) {
    for (int ix = 1; ix < L - 1; ix++) {
      double du = 0;
      double dv = 0;
      du = Du * laplacian(ix, iy, u);
      dv = Dv * laplacian(ix, iy, v);
      du += calcU(u[ix + iy * L], v[ix + iy * L]);
      dv += calcV(u[ix + iy * L], v[ix + iy * L]);
      u2[ix + iy * L] = u[ix + iy * L] + du * dt;
      v2[ix + iy * L] = v[ix + iy * L] + dv * dt;
    }
  }
}

void save_as_dat(vd &u) {
  static int index = 0;
  char filename[256];
  sprintf(filename, "conf%03d.dat", index);
  std::cout << filename << std::endl;
  std::ofstream ofs(filename, std::ios::binary);
  ofs.write((char *)(u.data()), sizeof(double)*L * L);
  index++;
}

int main() {
  vd u(V, 0.0), v(V, 0.0);
  vd u2(V, 0.0), v2(V, 0.0);
  init(u, v);
  for (int i = 0; i < 20000; i++) {
    if (i & 1) {
      calc(u2, v2, u, v);
    } else {
      calc(u, v, u2, v2);
    }
    if (i % 200 == 0) save_as_dat(u);
  }
}
