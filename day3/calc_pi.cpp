#include <cstdio>
#include <random>
#include <algorithm>

double calc_pi(std::mt19937 &mt, const int trial) {
  std::uniform_real_distribution<double> ud(0.0, 1.0);
  int n = 0;
  for (int i = 0; i < trial; i++) {
    double x = ud(mt);
    double y = ud(mt);
    if (x * x + y * y < 1.0) n++;
  }
  return 4.0 * static_cast<double>(n) / static_cast<double>(trial);
}

int main(void) {
  std::mt19937 mt(0);
  double pi = calc_pi(mt, 100000);
  printf("%f\n", pi);
}
