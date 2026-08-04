#include <immintrin.h>

const int N = 10000;
double a[N], b[N], c[N];
void func_simd() {
  for (int i = 0; i < N; i += 4) {
    __m256d va = _mm256_load_pd(&(a[i]));
    __m256d vb = _mm256_load_pd(&(b[i]));
    __m256d vc = _mm256_add_pd(va, vb);
    _mm256_store_pd(&(c[i]), vc);
  }
}
