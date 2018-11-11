#include <cstdio>
#include <x86intrin.h>

void print256d(__m256d x) {
  printf("%f %f %f %f\n", x[3], x[2], x[1], x[0]);
}

__attribute__((aligned(32))) double a[] = {0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0};

int main(void) {
  __m256d v1 = _mm256_load_pd(a);
  __m256d v2 = _mm256_load_pd(a + 4);
  __m256d v3 = v1 + v2;
  print256d(v3);
}
