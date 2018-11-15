#include <x86intrin.h>
#include <iostream>
#include <random>
#include <algorithm>
#include <cmath>

double BX = 0.0;
double BY = 0.0;
double BZ = 1.0;

const int N = 100000;

struct vec {
  double x, y, z, w;
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

void calc_rk2_simd() {
  __m256d vb_zxy = _mm256_set_pd(0.0, BY, BX, BZ);
  __m256d vb_yzx = _mm256_set_pd(0.0, BX, BZ, BY);
  __m256d vdt = _mm256_set_pd(0.0, dt, dt, dt);
  __m256d vdt_h = _mm256_set_pd(0.0, dt * 0.5, dt * 0.5, dt * 0.5);
  const int im_yzx = 64 * 3 + 16 * 0 + 4 * 2 + 1 * 1;
  const int im_zxy = 64 * 3 + 16 * 1 + 4 * 0 + 1 * 2;
  for (int i = 0; i < N; i++) {
    __m256d vv = _mm256_load_pd((double *)(&(v[i].x)));
    __m256d vr = _mm256_load_pd((double *)(&(r[i].x)));
    __m256d vv_yzx = _mm256_permute4x64_pd(vv, im_yzx);
    __m256d vv_zxy = _mm256_permute4x64_pd(vv, im_zxy);
    __m256d vp = vv_yzx * vb_zxy - vv_zxy * vb_yzx;
    __m256d vc = vv + vp * vdt_h;
    __m256d vp_yzx = _mm256_permute4x64_pd(vc, im_yzx);
    __m256d vp_zxy = _mm256_permute4x64_pd(vc, im_zxy);
    __m256d vp2 = vp_yzx * vb_zxy - vp_zxy * vb_yzx;
    vv += vp2 * vdt;
    vr += vv * vdt;
    _mm256_store_pd((double *)(&(v[i].x)), vv);
    _mm256_store_pd((double *)(&(r[i].x)), vr);
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
    //calc_rk2();
    calc_rk2_simd();
    t += dt;
    if ((i % 1000) == 0) {
      //std::cout << t << " " << energy() << std::endl;
    }
  }
  dump();
}
