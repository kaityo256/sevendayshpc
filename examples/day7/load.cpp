#include <cstdio>
#include <immintrin.h>

void print256d(__m256d x) {
  alignas(32) double y[4];
  _mm256_store_pd(y, x);
  printf("%f %f %f %f\n", y[3], y[2], y[1], y[0]);
}

alignas(32) double a[] = {0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0};

int main(void) {
  __m256d v1 = _mm256_load_pd(a);
  __m256d v2 = _mm256_load_pd(a + 4);
  __m256d v3 = _mm256_add_pd(v1, v2);
  print256d(v3);
}
