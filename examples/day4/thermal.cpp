#include <cstdio>
#include <fstream>
#include <iostream>
#include <vector>

const int L = 128;
const int STEP = 100000;
const int DUMP = 1000;

void onestep(std::vector<double> &lattice, const double h) {
  static std::vector<double> orig(L);
  std::copy(lattice.begin(), lattice.end(), orig.begin());
  for (int i = 1; i < L - 1; i++) {
    lattice[i] += h * (orig[i - 1] - 2.0 * orig[i] + orig[i + 1]);
  }
  // For Periodic Boundary
  lattice[0] += h * (orig[L - 1] - 2.0 * lattice[0] + orig[1]);
  lattice[L - 1] += h * (orig[L - 2] - 2.0 * lattice[L - 1] + orig[0]);
}

void dump(std::vector<double> &data) {
  static int index = 0;
  char filename[256];
  sprintf(filename, "data%03d.dat", index);
  std::cout << filename << std::endl;
  std::ofstream ofs(filename);
  for (int i = 0; i < data.size(); i++) {
    ofs << i << " " << data[i] << std::endl;
  }
  index++;
}

void fixed_temperature(std::vector<double> &lattice) {
  const double h = 0.01;
  const double Q = 1.0;
  for (int i = 0; i < STEP; i++) {
    onestep(lattice, h);
    lattice[L / 4] = Q;
    lattice[3 * L / 4] = -Q;
    if ((i % DUMP) == 0) dump(lattice);
  }
}

void uniform_heating(std::vector<double> &lattice) {
  const double h = 0.2;
  const double Q = 1.0;
  for (int i = 0; i < STEP; i++) {
    onestep(lattice, h);
    for (auto &s : lattice) {
      s += Q * h;
    }
    lattice[0] = 0.0;
    lattice[L - 1] = 0.0;
    if ((i % DUMP) == 0) dump(lattice);
  }
}

int main() {
  std::vector<double> lattice(L, 0.0);
  //uniform_heating(lattice);
  fixed_temperature(lattice);
}
