#ifndef _WIN32
#include <x86intrin.h>
#else
#include <intrin.h>
#endif  // _WIN32

__m256d setpd(double a, double b, double c, double d) {
  return _mm256_set_pd(d, c, b, a);
}
