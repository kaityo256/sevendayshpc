#ifndef _WIN32
#include <x86intrin.h>
#else
#include <intrin.h>
#endif  // _WIN32

__m256d load(double *a, int index) {
  return _mm256_load_pd(a + index);
}
