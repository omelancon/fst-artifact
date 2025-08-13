/* MBROT -- Generation of Mandelbrot set fractal. */

#include <stdio.h>

#define FLOAT double

#define N 75

#define max_count 64
#define radius2 16.0

static int count (FLOAT r, FLOAT i, FLOAT step, int x, int y)
{
  FLOAT cr = r + x*step;
  FLOAT ci = i + y*step;
  FLOAT zr = cr;
  FLOAT zi = ci;
  int c = 0;

  while (c != max_count)
    {
      FLOAT zr2 = zr*zr;
      FLOAT zi2 = zi*zi;

      if (zr2+zi2 > radius2)
        return c;

      zi = 2.0*zr*zi + ci;
      zr = (zr2-zi2) + cr;

      c++;
    }

  return c;
}

static void mbrot (int *matrix, FLOAT r, FLOAT i, FLOAT step, int n)
{
  int x, y;

  for (y=n-1; y>=0; y--)
    for (x=n-1; x>=0; x--)
      matrix[y*n+x] = count (r, i, step, x, y);
}

double parse_or_default(const char *s, double def) {
  return s ? strtod(s, NULL) : def;
}

int main(int argc, char **argv)
{
  double r    = parse_or_default(argc>1?argv[1]:NULL, -1.0);
  double i    = parse_or_default(argc>2?argv[2]:NULL, -0.5);
  double step = parse_or_default(argc>3?argv[3]:NULL, 0.005);

  int result;

  for (int it=0; it<5100; ++it) {
    int matrix[N*N];
    mbrot(matrix, r, i, step, N);
    result = matrix[0];
  }

  if (result != 5) printf("*** wrong result ***\n");
  
  return 0;
}
