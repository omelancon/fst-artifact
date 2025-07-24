#!/bin/sh
#*=====================================================================*/
#*    .../diffusion/article/flt/artifact/scripts/stats-to-pdf.sh       */
#*    -------------------------------------------------------------    */
#*    Author      :  Manuel Serrano                                    */
#*    Creation    :  Thu Oct  3 09:44:21 2024                          */
#*    Last change :  Mon Mar 24 13:58:47 2025 (serrano)                */
#*    Copyright   :  2024-25 Manuel Serrano                            */
#*    -------------------------------------------------------------    */
#*    Generate PDF files from stats files                              */
#*=====================================================================*/

#*---------------------------------------------------------------------*/
#*    Configuration                                                    */
#*---------------------------------------------------------------------*/
path=`realpath $0`
dir=`dirname $path`

. $dir/env.sh

if [ "$dir " = ". " ]; then
  dir=`pwd`
fi

if [ "$#" -ge 2 ]; then
  BENCHMARKS=$*
else
  BENCHMARKS="r7rs-compiler r7rs-dynamic r7rs-earley r7rs-graphs r7rs-matrix r7rs-maze r7rs-nboyer r7rs-parsing r7rs-peval r7rs-sboyer r7rs-scheme r7rs-slatex #;floats r7rs-fibfp r7rs-fft r7rs-mbrot r7rs-nucleic r7rs-pnpoly r7rs-ray r7rs-simplex r7rs-sum1 r7rs-sumfp"
fi

mkdir -p $PLOTDIR

#*---------------------------------------------------------------------*/
#*    unprefix                                                         */
#*---------------------------------------------------------------------*/
unprefix() {
  file=$1
  cat $1 | sed -e 's/r7rs-//' > $file.tmp
  mv $file.tmp $file
}

#*---------------------------------------------------------------------*/
#*    plot                                                             */
#*---------------------------------------------------------------------*/
plot() {
  pdf=$1
  dir=`dirname $pdf`
  plot=`basename $pdf .pdf`
  shift
  colors=$1
  shift
  size=$1
  shift
  stats=$*

  if [ ! -f $pdf ] || [ $pdf -ot $plot.plot ]; then
    $ROOT/download/bglstone/bin/gnuplothistogram -o $dir/$plot --size $size --relative-sans-right $stats --benchmarks "$BENCHMARKS" --separator 12 --rename "Bigloo.fltlb" "Scheme self-tagging (2-tag, mantissa low-bits)" --rename "Bigloo.fltnz" "Scheme self-tagging (2-tag)" --rename "Bigloo.flt" "Scheme self-tagging (3-tag)" --rename "Bigloo.flt1" "Scheme self-tagging (1-tag)" --rename "Bigloo.nan" "Scheme NaN-boxing" --rename "Bigloo.nun" "Scheme NuN-boxing" --rename "Bigloo.bigloo" "orig" --rename "Bigloo" "orig" --values --colors "#$colors" \
      && (cd $dir; unprefix $plot.csv) \
      && (cd $dir; gnuplot $plot.plot) 
  fi
}
    
#*---------------------------------------------------------------------*/
#*    All PDF barcharts                                                */
#*---------------------------------------------------------------------*/
# bigloo vs bigloo_fltlb
plot $PLOTDIR/bigloo_vs_fltlb.pdf "#$COLORLB" "6,2" $STATS/bigloo.stat $STATS/bigloo_fltlb.stat

# bigloo vs bigloo_flt
plot $PLOTDIR/bigloo_vs_flt.pdf "#$COLORFLT,#$COLORFLTNZ,#$COLORFLTONE" "6,3" $STATS/bigloo.stat $STATS/bigloo_flt.stat $STATS/bigloo_fltnz.stat $STATS/bigloo_flt1.stat

# bigloo vs bigloo_nan
plot $PLOTDIR/bigloo_vs_nan.pdf "#$COLORNAN,#$COLORNUN,#$COLORFLTONE" "6,3" $STATS/bigloo.stat $STATS/bigloo_nan.stat $STATS/bigloo_nun.stat $STATS/bigloo_flt1.stat 

# bigloo vs bigloo_ftl and bigloo_ftl1
plot $PLOTDIR/bigloo_vs_flts.pdf "#f00,#0f0,#00f,#ff0,#0ff" "6,3" $STATS/bigloo.stat $STATS/bigloo_flt.stat $STATS/bigloo_flt1.stat
