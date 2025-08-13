#include <stdio.h>

int main(int argc, char *argv[])
{
        int i;
        double s = 0, d;
        FILE *fp;
        char *infile = "./sum1.data";
        if (argc > 1)
                infile = argv[1];

        for (i=0; i<2100; i++) {
                
                fp = fopen(infile, "r");
                if (fp == NULL) {
                        fprintf(stderr, "can't open %s\n", infile);
                        exit(1);
                }

                while (fscanf(fp,"%lf", &d) != EOF)
                        s += d;

                fclose(fp);
        }
        
        printf("%f\n", s);
        return 0;
}
