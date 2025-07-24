To install all the needed software

```shell
ROOT=<MY_DIR> ./install.sh
```  

To run the benchmarks and generate PDF files

```shell
ROOT=<MY_DIR> ./run.sh
```

The generated PDF files are stored in the "plot"
directory.

To only generate the plots

```shell
./install.sh --plot-only
./plot.sh
```

To generate the plots for one particular machine

```shell
FST_HOST=<YOUR_HOST> ./plot.sh
```