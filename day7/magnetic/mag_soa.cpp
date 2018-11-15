#include <iostream>
#include <random>
#include <algorithm>
#include <cmath>

double BX = 0.0;
double BY = 0.0;
double BZ = 1.0;

const int N = 100000;
double rx[N], ry[N], rz[N];
double vx[N], vy[N], vz[N];

const double dt = 0.01;
double t = 0.0;

double energy(void) {
  double e = 0.0;
  for (int i = 0; i < N; i++) {
    e += vx[i] * vx[i];
    e += vy[i] * vy[i];
    e += vz[i] * vz[i];
  }
  return e * 0.5 / static_cast<double>(N);
}

void calc_euler() {
  for (int i = 0; i < N; i++) {
    double px = vy[i] * BZ - vz[i] * BY;
    double py = vz[i] * BX - vx[i] * BZ;
    double pz = vx[i] * BY - vy[i] * BX;
    vx[i] += px * dt;
    vy[i] += py * dt;
    vz[i] += pz * dt;
    rx[i] = rx[i] + vx[i] * dt;
    ry[i] = ry[i] + vy[i] * dt;
    rz[i] = rz[i] + vz[i] * dt;
  }
}

void calc_rk2() {
  for (int i = 0; i < N; i++) {
    double px = vy[i] * BZ - vz[i] * BY;
    double py = vz[i] * BX - vx[i] * BZ;
    double pz = vx[i] * BY - vy[i] * BX;
    double vcx = vx[i] + px * dt * 0.5;
    double vcy = vy[i] + py * dt * 0.5;
    double vcz = vz[i] + pz * dt * 0.5;
    double px2 = vcy * BZ - vcz * BY;
    double py2 = vcz * BX - vcx * BZ;
    double pz2 = vcx * BY - vcy * BX;
    vx[i] += px2 * dt;
    vy[i] += py2 * dt;
    vz[i] += pz2 * dt;
    rx[i] = rx[i] + vx[i] * dt;
    ry[i] = ry[i] + vy[i] * dt;
    rz[i] = rz[i] + vz[i] * dt;
  }
}

void init() {
  std::mt19937 mt;
  std::uniform_real_distribution<double> ud(0.0, 1.0);
  for (int i = 0; i < N; i++) {
    double z = ud(mt) * 2.0 - 1.0;
    double s = ud(mt) * M_PI;
    vx[i] = sqrt(1 - z * z) * cos(s);
    vy[i] = sqrt(1 - z * z) * sin(s);
    vz[i] = z;
    rx[i] = 0.0;
    ry[i] = 0.0;
    rz[i] = 0.0;
  }
  double z = ud(mt) * 2.0 - 1.0;
  double s = ud(mt) * M_PI;
  BX = sqrt(1 - z * z) * cos(s);
  BY = sqrt(1 - z * z) * sin(s);
  BZ = z;
}

void dump() {
  for (int i = 0; i < N; i++) {
    std::cout << rx[i] << " ";
    std::cout << ry[i] << " ";
    std::cout << rz[i] << std::endl;
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
