#include <iostream>
#include <random>
#include <algorithm>
#include <cmath>

double BX = 0.0;
double BY = 0.0;
double BZ = 1.0;

const int N = 100000;

struct vec {
  double x, y, z;
};

vec r[N], v[N];
const double dt = 0.01;
double t = 0.0;

double energy(void) {
  double e = 0.0;
  for (int i = 0; i < N; i++) {
    e += v[i].x * v[i].x;
    e += v[i].y * v[i].y;
    e += v[i].z * v[i].z;
  }
  return e * 0.5 / static_cast<double>(N);
}

void calc_euler() {
  for (int i = 0; i < N; i++) {
    double px = v[i].y * BZ - v[i].z * BY;
    double py = v[i].z * BX - v[i].x * BZ;
    double pz = v[i].x * BY - v[i].y * BX;
    v[i].x += px * dt;
    v[i].y += py * dt;
    v[i].z += pz * dt;
    r[i].x = r[i].x + v[i].x * dt;
    r[i].y = r[i].y + v[i].y * dt;
    r[i].z = r[i].z + v[i].z * dt;
  }
}

void calc_rk2() {
  for (int i = 0; i < N; i++) {
    double px = v[i].y * BZ - v[i].z * BY;
    double py = v[i].z * BX - v[i].x * BZ;
    double pz = v[i].x * BY - v[i].y * BX;
    double vcx = v[i].x + px * dt * 0.5;
    double vcy = v[i].y + py * dt * 0.5;
    double vcz = v[i].z + pz * dt * 0.5;
    double px2 = vcy * BZ - vcz * BY;
    double py2 = vcz * BX - vcx * BZ;
    double pz2 = vcx * BY - vcy * BX;
    v[i].x += px2 * dt;
    v[i].y += py2 * dt;
    v[i].z += pz2 * dt;
    r[i].x += v[i].x * dt;
    r[i].y += v[i].y * dt;
    r[i].z += v[i].z * dt;
  }
}

void init() {
  std::mt19937 mt;
  std::uniform_real_distribution<double> ud(0.0, 1.0);
  for (int i = 0; i < N; i++) {
    double z = ud(mt) * 2.0 - 1.0;
    double s = ud(mt) * M_PI;
    v[i].x = sqrt(1 - z * z) * cos(s);
    v[i].y = sqrt(1 - z * z) * sin(s);
    v[i].z = z;
    r[i].x = 0.0;
    r[i].y = 0.0;
    r[i].z = 0.0;
  }
  double z = ud(mt) * 2.0 - 1.0;
  double s = ud(mt) * M_PI;
  BX = sqrt(1 - z * z) * cos(s);
  BY = sqrt(1 - z * z) * sin(s);
  BZ = z;
}

void dump() {
  for (int i = 0; i < N; i++) {
    std::cout << r[i].x << " ";
    std::cout << r[i].y << " ";
    std::cout << r[i].z << std::endl;
  }
}

int main() {
  init();
  double t = 0.0;
  for (int i = 0; i < 10000; i++) {
    //calc_euler();
    calc_rk2();
    t += dt;
    if ((i % 1000) == 0) {
      //std::cout << t << " " << energy() << std::endl;
    }
  }
  dump();
}
