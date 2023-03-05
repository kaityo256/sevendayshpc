#include <cstdio>
#ifndef _WIN32
#include <x86intrin.h>
#else
#include <intrin.h>
#endif  // _WIN32

void print256d(__m256d x) {
  alignas(32) double y[4];
  _mm256_store_pd(y, x);
  printf("%f %f %f %f\n", y[3], y[2], y[1], y[0]);
}

int main(void) {
  __m256d v1 =  _mm256_set_pd(3.0, 2.0, 1.0, 0.0);
  __m256d v2 =  _mm256_set_pd(7.0, 6.0, 5.0, 4.0);
  __m256d v3 = _mm256_mul_pd(v1, v2);
  print256d(v3);
}
