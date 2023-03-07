#include <immintrin.h>

__m256d setpd(double a, double b, double c, double d) {
  return _mm256_set_pd(d, c, b, a);
}
