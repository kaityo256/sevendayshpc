#include <cstdio>
#ifndef _WIN32
#include <x86intrin.h>
#else
#include <intrin.h>
#endif  // _WIN32

void print256d(__m256d x) {
  printf("%f %f %f %f\n", x[3], x[2], x[1], x[0]);
}

int main(void) {
  __m256d v1 =  _mm256_set_pd(3.0, 2.0, 1.0, 0.0);
  print256d(v1);
}
