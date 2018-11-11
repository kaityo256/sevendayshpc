#include <x86intrin.h>

__m256d load(double *a, int index) {
  return _mm256_load_pd(a + index);
}
