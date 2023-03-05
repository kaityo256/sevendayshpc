#include <cstdio>
#ifndef _WIN32
#include <x86intrin.h>
#else
#include <intrin.h>
#endif  // _WIN32

void print256d(__m256d x) {
  double alignas(32) y[4];
  _mm256_store_pd(y, x);
  printf("%f %f %f %f\n", y[3], y[2], y[1], y[0]);
}

int main(void) {
  __m256d v1 =  _mm256_set_pd(3.0, 2.0, 1.0, 0.0);
  print256d(v1);
}
