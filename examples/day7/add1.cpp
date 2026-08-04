#include <cstdio>
#include <x86intrin.h>

__m256d add(__m256d v1, __m256d v2) {
  return v1 + v2;
}
