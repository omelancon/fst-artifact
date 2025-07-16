#!/bin/sh
#*=====================================================================*/
#*    serrano/diffusion/article/flt/fst-artifact/scripts/plot.sh       */
#*    -------------------------------------------------------------    */
#*    Author      :  Manuel Serrano                                    */
#*    Creation    :  Mon Mar 24 14:11:49 2025                          */
#*    Last change :  Tue Jul 15 12:31:53 2025 (serrano)                */
#*    Copyright   :  2025 Manuel Serrano                               */
#*    -------------------------------------------------------------    */
#*    Generate the plots, invoked automatically by run.sh              */
#*=====================================================================*/

#*---------------------------------------------------------------------*/
#*    Configuration                                                    */
#*---------------------------------------------------------------------*/
path=`realpath $0`
dir=`dirname $path`

. $dir/env.sh

set -u

ratiofile="$PLOTDIR/ratio.tex"
legendfile="$PLOTDIR/legend.tex"
repetitionsfile="$PLOTDIR/repetitions.tex"

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
  plotdir=`dirname $pdf`
  plot=`basename $pdf .pdf`
  shift
  colors=$1
  shift
  size=$1
  shift
  bmargin=$1
  shift
  key=$1
  shift
  tmargin=$1
  shift
  title=$1
  shift
  range=$1
  shift
  stats=$*

  if [ ! -f $pdf ] || [ $pdf -ot $plot.plot ]; then
    $downloaddir/bglstone/bin/gnuplothistogram -o $plotdir/$plot --size $size --tmargin $tmargin --relative-sans-left $stats --benchmarks "$SCM_BENCHMARKS" --logscale --separator 12 --rename "Bigloo.fltlb" "self-tagging (2-tag, mantissa low-bits)" --rename "Bigloo.fltnz" "self-tagging (2-tag)" --rename "Bigloo.flt" "self-tagging (3-tag)" --rename "Bigloo.flt1" "self-tagging (1-tag)" --rename "Bigloo.nan" "NaN-boxing" --rename "Bigloo.nun" "" --rename "Bigloo.bigloo" "" --rename "Bigloo" "" --rename "Gambit.nun" "" --rename "Gambit" "" --rename "gambit" "" --rename "Gambit.0" "" --rename "Gambit.1" "self-tagging (1-tag)" --rename "Gambit.2" "self-tagging (2-tag)" --rename "Gambit.3" "self-tagging (3-tag)" --rename "Gambit.4" "self-tagging (4-tag)" --values --colors "$colors" --bmargin $bmargin --key "$key" --title "$title" --v-fontsize 4 --errorbars --range $range \
      && (cd $plotdir; unprefix $plot.csv) \
      && (cd $plotdir; gnuplot $plot.plot) 
  fi
}

geomean() {
  local csv=$1
  shift
  local colno=$1
  shift
  local names=$1

  local pattern=$(echo "$names" | sed 's/ /|/g')

  local ratio=$(grep -E "$pattern" "$csv" | awk -F',' -v col="$colno" '
    BEGIN { sum_log = 0; count = 0 }
    {
      val = $col + 0;
      if (val > 0) {
        sum_log += log(val);
        count++;
      }
    }
    END {
      if (count > 0) {
        printf "%.2f\n", exp(sum_log / count);
      } else {
        print "NaN";
      }
    }
  ')
  echo $ratio | sed 's/\b0\././g'
}

make_latexfriendly() {
  local input="$1"
  if [ "$input" = "redrock2020" ]; then
    echo "redrockTT"
  else
    echo "$input" | tr -cd 'a-zA-Z'
  fi
}

echo > $ratiofile
echo > $legendfile
echo > $repetitionsfile

cat >> $legendfile <<EOF
% used to highlight cells in interval table
\newcommand{\htmlColorOneTag}{$COLORFLTONE}
\newcommand{\htmlColorTwoTag}{$COLORFLT2}
\newcommand{\htmlColorThreeTag}{$COLORFLT}
\newcommand{\htmlColorFourTag}{$COLORFLTFOUR}
\newcommand{\htmlColorTwoTagNZ}{$COLORFLTNZ}
\newcommand{\htmlColorNan}{$COLORNAN}
\newcommand{\htmlColorAlloc}{$COLORALLOC}

\definecolor{tag0}{HTML}{$COLORFLT}
\definecolor{tag3}{HTML}{$COLORFLTNZ}
\definecolor{tag4}{HTML}{$COLORFLTNZ_LIGHT}
\definecolor{tag7}{HTML}{$COLORFLTFOUR}
\definecolor{1tag}{HTML}{$COLORFLTONE}
\definecolor{2tag}{HTML}{$COLORFLT2}
\definecolor{alloc}{HTML}{$COLORALLOC}
\newcommand{\tagzerocolorname}{$COLORFLT_NAME\xspace}
\newcommand{\tagthreecolorname}{$COLORFLTNZ_NAME\xspace}
\newcommand{\tagfourcolorname}{$COLORFLTNZ_LIGHT_NAME\xspace}
\newcommand{\tagsevencolorname}{$COLORFLTFOUR_NAME\xspace}
\newcommand{\onetagcolorname}{$COLORFLTONE_NAME\xspace}
\newcommand{\twotagcolorname}{$COLORFLT2_NAME\xspace}
\newcommand{\alloccolorname}{$COLORALLOC\xspace}
EOF

cat >> $repetitionsfile <<EOF
\newcommand{\experimentsrepetitions}{$REPETITION}
EOF

#*---------------------------------------------------------------------*/
#*    COMP_time_nun_ARCH.pdf                                           */
#*---------------------------------------------------------------------*/
cat >> $legendfile <<EOF
\newcommand{\legendbiglootimenun}{
\begin{center}
\begin{tabular}{llllllll}
\colorrect{self-tagging (1-tag)}{$COLORFLTONE}     &
\colorrect{self-tagging (2-tag w/ prealloc. zero)}{$COLORFLTNZ}    &
\colorrect{self-tagging (3-tag)}{$COLORFLT}   &
\colorrect{NaN-boxing}{$COLORNAN}    \\\\
\end{tabular}
\end{center}
}
EOF

cat >> $legendfile <<EOF
\newcommand{\legendgambittimenun}{
\begin{center}
\begin{tabular}{llllllll}
\colorrect{self-tagging (1-tag)}{$COLORFLTONE}     &
\colorrect{self-tagging (2-tag)}{$COLORFLT2}    &
\colorrect{self-tagging (3-tag)}{$COLORFLT}   &
\colorrect{self-tagging (4-tag)}{$COLORFLTFOUR}  \\\\
\end{tabular}
\end{center}
}
EOF

plot $PLOTDIR/bigloo_time_nun_$host.pdf "#$COLORFLTONE,#$COLORFLTNZ,#$COLORFLT,#$COLORNAN" "7,2" "3" "off" "0.2" "" "[0.2:2.9]" $STATS/bigloo_nun.stat $STATS/bigloo_flt1.stat $STATS/bigloo_fltnz.stat $STATS/bigloo_flt.stat $STATS/bigloo_nan.stat
plot $PLOTDIR/gambit_time_nun_$host.pdf "#$COLORFLTONE,#$COLORFLT2,#$COLORFLT,#$COLORFLTFOUR" "7,2" "3" "off" "0.2" "" "[0.2:2.9]" $STATS/gambit_nun.stat $STATS/gambit_1.stat $STATS/gambit_2.stat $STATS/gambit_3.stat $STATS/gambit_4.stat

latex_friendly_host=$(make_latexfriendly $host)

cat >> $ratiofile <<EOF
%bigloo vs nun
\newcommand{\bigloo${latex_friendly_host}FltOneNunRatioFloats}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 2 "$SCM_FLOAT_BENCHMARKS_NAMES")}
\newcommand{\bigloo${latex_friendly_host}FltOneNunRatioNonFloats}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 2 "$SCM_NONFLOAT_BENCHMARKS_NAMES")}
\newcommand{\bigloo${latex_friendly_host}FltOneNunRatioAll}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 2 "$SCM_BENCHMARKS_NAMES")}

\newcommand{\bigloo${latex_friendly_host}FltnzNunRatioFloats}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 5 "$SCM_FLOAT_BENCHMARKS_NAMES")}
\newcommand{\bigloo${latex_friendly_host}FltnzNunRatioNonFloats}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 5 "$SCM_NONFLOAT_BENCHMARKS_NAMES")}
\newcommand{\bigloo${latex_friendly_host}FltnzNunRatioAll}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 5 "$SCM_BENCHMARKS_NAMES")}

\newcommand{\bigloo${latex_friendly_host}FltThreeNunRatioFloats}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 8 "$SCM_FLOAT_BENCHMARKS_NAMES")}
\newcommand{\bigloo${latex_friendly_host}FltThreeNunRatioNonFloats}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 8 "$SCM_NONFLOAT_BENCHMARKS_NAMES")}
\newcommand{\bigloo${latex_friendly_host}FltThreeNunRatioAll}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 8 "$SCM_BENCHMARKS_NAMES")}

\newcommand{\bigloo${latex_friendly_host}NanNunRatioFloats}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 11 "$SCM_FLOAT_BENCHMARKS_NAMES")}
\newcommand{\bigloo${latex_friendly_host}NanNunRatioNonFloats}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 11 "$SCM_NONFLOAT_BENCHMARKS_NAMES")}
\newcommand{\bigloo${latex_friendly_host}NanNunRatioAll}{$(geomean $PLOTDIR/bigloo_time_nun_$host.csv 11 "$SCM_BENCHMARKS_NAMES")}

%gambit vs nun
\newcommand{\gambit${latex_friendly_host}FltOneNunRatioFloats}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 2 "$SCM_FLOAT_BENCHMARKS_NAMES")}
\newcommand{\gambit${latex_friendly_host}FltOneNunRatioNonFloats}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 2 "$SCM_NONFLOAT_BENCHMARKS_NAMES")}
\newcommand{\gambit${latex_friendly_host}FltOneNunRatioAll}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 2 "$SCM_BENCHMARKS_NAMES")}

\newcommand{\gambit${latex_friendly_host}FltTwoNunRatioFloats}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 5 "$SCM_FLOAT_BENCHMARKS_NAMES")}
\newcommand{\gambit${latex_friendly_host}FltTwoNunRatioNonFloats}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 5 "$SCM_NONFLOAT_BENCHMARKS_NAMES")}
\newcommand{\gambit${latex_friendly_host}FltTwoNunRatioAll}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 5 "$SCM_BENCHMARKS_NAMES")}

\newcommand{\gambit${latex_friendly_host}FltThreeNunRatioFloats}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 8 "$SCM_FLOAT_BENCHMARKS_NAMES")}
\newcommand{\gambit${latex_friendly_host}FltThreeNunRatioNonFloats}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 8 "$SCM_NONFLOAT_BENCHMARKS_NAMES")}
\newcommand{\gambit${latex_friendly_host}FltThreeNunRatioAll}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 8 "$SCM_BENCHMARKS_NAMES")}

\newcommand{\gambit${latex_friendly_host}FltFourNunRatioFloats}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 11 "$SCM_FLOAT_BENCHMARKS_NAMES")}
\newcommand{\gambit${latex_friendly_host}FltFourNunRatioNonFloats}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 11 "$SCM_NONFLOAT_BENCHMARKS_NAMES")}
\newcommand{\gambit${latex_friendly_host}FltFourNunRatioAll}{$(geomean $PLOTDIR/gambit_time_nun_$host.csv 11 "$SCM_BENCHMARKS_NAMES")}
EOF
#*---------------------------------------------------------------------*/
#*    COMP_time_alloc_ARCH.pdf                                         */
#*---------------------------------------------------------------------*/

cat >> $legendfile <<EOF
\newcommand{\legendbiglootimealloc}{
\begin{center}
\begin{tabular}{l}
\colorrect{self-tagging (1-tag)}{$COLORFLTONE}
\end{tabular}
\end{center}
}
EOF

cat >> $legendfile <<EOF
\newcommand{\legendgambittimealloc}{
\begin{center}
\begin{tabular}{l}
\colorrect{self-tagging (4-tag)}{$COLORFLTFOUR}
\end{tabular}
\end{center}
}
EOF

plot $PLOTDIR/gambit_time_alloc_$host.pdf "#$COLORFLTFOUR" "7,2" "3" "off" "0.2" "" "[0.2:2.9]" $STATS/gambit_0.stat $STATS/gambit_4.stat
plot $PLOTDIR/bigloo_time_alloc_$host.pdf "#$COLORFLTONE" "7,2" "3" "off" "0.2" "" "[0.2:2.9]" $STATS/bigloo.stat $STATS/bigloo_flt.stat

#*---------------------------------------------------------------------*/
#*    COMP_time_mantissa_ARCH.pdf                                      */
#*---------------------------------------------------------------------*/
cat >> $legendfile <<EOF
\newcommand{\legendbiglootimemantissa}{
\begin{center}
\colorrect{self-tagging (2-tag, mantissa low bits)}{$COLORFLTLB}
\end{center}
}
EOF

plot $PLOTDIR/bigloo_time_mantissa_$host.pdf "#$COLORFLTLB" "8,2" "2.5" "off" "0.2" "" "[0.125:2.5]" $STATS/bigloo.stat $STATS/bigloo_fltlb.stat

#*---------------------------------------------------------------------*/
#*    COMP_mem_ARCH.pdf                                                */
#*---------------------------------------------------------------------*/
cat >> $legendfile <<EOF
\newcommand{\legendbigloomem}{
\begin{center}
\begin{tabular}{lll}
\colorrect{self-tagging (1-tag)}{$COLORFLTONE}     &
\colorrect{self-tagging (2-tag w/ prealloc. zero)}{$COLORFLTNZ}    &
\colorrect{self-tagging (3-tag)}{$COLORFLT}   \\\\
\colorrect{NaN-boxing}{$COLORNAN}    &
\colorrect{NuN-boxing}{$COLORNUN}    \\\\
\end{tabular}
\end{center}
}
EOF

(cd $BMEMS; $installdir/bigloo/bin/bigloo -i $dir/bmem2csv.scm bigloo_mem_$host $SCM_BENCHMARKS --ratio "8,2" --key "off" --separator 12 --colors "#ff0,#$COLORFLTONE,#$COLORFLTNZ,#$COLORFLT,#$COLORNAN,#$COLORNUN" -:- bigloo bigloo_flt1 bigloo_fltnz bigloo_flt bigloo_nan bigloo_nun 2> ../$PLOTDIR/bigloo_mem_$host.plot | sed -e 's/r7rs-//'  > ../$PLOTDIR/bigloo_mem_$host.csv) && (cd $PLOTDIR; gnuplot bigloo_mem_$host.plot)

#*---------------------------------------------------------------------*/
#*    COMP_branch_ARCH.pdf                                             */
#*---------------------------------------------------------------------*/
cat >> $legendfile <<EOF
\newcommand{\legendbigloobranch}{
\begin{center}
\begin{tabular}{lll}
\colorrect{self-tagging (2-tag, mantissa low-bits)}{$COLORFLTLB}     &
\colorrect{self-tagging (1-tag)}{$COLORFLTONE} & \\\\
\colorrect{self-tagging (2-tag w/ prealloc. zero)}{$COLORFLTNZ}    &
\colorrect{NaN-boxing}{$COLORNAN}    &
\colorrect{NuN-boxing}{$COLORNUN}    \\\\
\end{tabular}
\end{center}
}
EOF

if [ -f $BRANCHS/r7rs-compiler/bigloo.branch ]; then
  (cd $BRANCHS; $installdir/bigloo/bin/bigloo -i $dir/branch2csv.scm bigloo_branch_$host $SCM_BENCHMARKS --ratio "8,2" --key "off" --separator 12 --colors "#ff0,#$COLORFLTLB,#$COLORFLTONE,#$COLORFLTNZ,#$COLORNAN,#$COLORNUN" -:- bigloo bigloo_fltlb bigloo_flt1 bigloo_fltnz bigloo_nan bigloo_nun 2> ../$PLOTDIR/bigloo_branch_$host.plot | sed -e 's/r7rs-//'  > ../$PLOTDIR/bigloo_branch_$host.csv) && (cd $PLOTDIR; gnuplot bigloo_branch_$host.plot)
fi

#*---------------------------------------------------------------------*/
#*    Heap                                                             */
#*---------------------------------------------------------------------*/
mkdir -p $PLOTDIR/gc

for benchmark in $SCM_FLOAT_BENCHMARKS; do
  gnuplot -e "benchmark='$benchmark'" \
          -e "bigloo_orig='$HEAPS/$benchmark/bigloo.heap'" \
          -e "bigloo_orig_name='Bigloo (alloc)'" \
          -e "bigloo_orig_color='#$COLORALLOC'" \
          -e "bigloo_fst='$HEAPS/$benchmark/bigloo_flt1.heap'" \
          -e "bigloo_fst_name='Bigloo (self-tagging, 1-tag)'" \
          -e "bigloo_fst_color='#$COLORFLTONE'" \
          -e "gambit_orig='$HEAPS/$benchmark/gambit_0.heap'" \
          -e "gambit_orig_name='Gambit (alloc)'" \
          -e "gambit_orig_color='#$COLORALLOC'" \
          -e "gambit_fst='$HEAPS/$benchmark/gambit_4.heap'" \
          -e "gambit_fst_name='Gambit (self-tagging, 4-tag)'" \
          -e "gambit_fst_color='#$COLORFLTFOUR'" \
          -e "output='$PLOTDIR/gc/$benchmark.pdf'" \
	        -e "smallest_non_zero_vector='$SCM_SMALLEST_NON_ZERO_SIZE'" \
          $dir/plot_gc.gp
done

# The line below is used to generate the legend
gnuplot -e "bigloo_orig='$HEAPS/$benchmark/bigloo.heap'" \
        -e "bigloo_orig_name='Bigloo (alloc)'" \
        -e "bigloo_orig_color='#$COLORALLOC'" \
        -e "bigloo_fst='$HEAPS/$benchmark/bigloo_flt1.heap'" \
        -e "bigloo_fst_name='Bigloo (self-tagging, 1-tag)'" \
        -e "bigloo_fst_color='#$COLORFLTONE'" \
        -e "gambit_orig='$HEAPS/$benchmark/gambit_0.heap'" \
        -e "gambit_orig_name='Gambit (alloc)'" \
        -e "gambit_orig_color='#$COLORALLOC'" \
        -e "gambit_fst='$HEAPS/$benchmark/gambit_4.heap'" \
        -e "gambit_fst_name='Gambit (self-tagging, 4-tag)'" \
        -e "gambit_fst_color='#$COLORFLTFOUR'" \
        -e "legend_only=1" \
        -e "output='$PLOTDIR/gc/legend.pdf'" \
        $dir/plot_gc.gp

#*---------------------------------------------------------------------*/
#*    Scheme performance                                               */
#*---------------------------------------------------------------------*/
#* # figure 5.b                                                        */
#* plot $PLOTDIR/bigloo_vs_fltlb.pdf "#$COLORLB" "8,2" "3" "off" "" "[0:*]" $STATS/bigloo.stat $STATS/bigloo_fltlb.stat */
#*                                                                     */
#* # figure 7                                                          */
#* plot $PLOTDIR/bigloo_vs_flt1.pdf "#$COLORLB" "8,2" "3" "off" ""  "[0:*]" $STATS/bigloo.stat $STATS/bigloo_flt1.stat */
#*                                                                     */
#* # figure 9                                                          */
#* plot $PLOTDIR/bigloo_vs_flt.pdf "#$COLORFLTONE,#$COLORFLTNZ,#$COLORFLT,#$COLORNAN" "8,2" "5" "under nobox" "Relative time (@PROCESSOR@)" "[0.5:2.5]" $STATS/bigloo_nun.stat $STATS/bigloo_flt1.stat $STATS/bigloo_fltnz.stat $STATS/bigloo_flt.stat $STATS/bigloo_nan.stat */
#*                                                                     */
#* plot $PLOTDIR/gambit_vs_flt.pdf "#$COLORFLTONE,#$COLORFLTNZ,#$COLORFLT,#$COLORFLTFOUR" "8,2" "5" "under nobox" "Relative time (@PROCESSOR@)" "[0.5:2.5]" $STATS/gambit_nun.stat $STATS/gambit_1.stat $STATS/gambit_2.stat $STATS/gambit_3.stat $STATS/gambit_4.stat */
#*                                                                     */
#* # figure 11                                                         */
#* plot $PLOTDIR/bigloo_vs_nan.pdf "#$COLORNAN,#$COLORNUN,#$COLORFLTONE" "8,2" "5" "under nobox" "Relative time (@PROCESSOR@)" "[0:*]" $STATS/bigloo.stat $STATS/bigloo_nan.stat $STATS/bigloo_nun.stat $STATS/bigloo_flt1.stat */
#*                                                                     */
# figure 8 (gc)

#* {*---------------------------------------------------------------------*} */
#* {*    Memory                                                           *} */
#* {*---------------------------------------------------------------------*} */
#* # figure 5.a                                                        */
#* (cd $BMEMS; $installdir/bigloo/bin/bigloo -i $dir/bmem2csv.scm bigloo_vs_fltlb_bmem $SCM_BENCHMARKS --key "off" --separator 12 --colors "#000,#$COLORLB" -:- bigloo bigloo_fltlb 2> ../$PLOTDIR/bigloo_vs_fltlb_bmem.plot | sed -e 's/r7rs-//' > ../$PLOTDIR/bigloo_vs_fltlb_bmem.csv) && (cd $PLOTDIR; gnuplot bigloo_vs_fltlb_bmem.plot) */
#*                                                                     */
#* # figure 8                                                          */
#* (cd $BMEMS; $installdir/bigloo/bin/bigloo -i $dir/bmem2csv.scm bigloo_vs_flt_bmem $SCM_BENCHMARKS --key "off" --separator 12 --colors "#000,#$COLORFLT,#$COLORFLTNZ,#$COLORFLTONE" -:- bigloo bigloo_flt bigloo_fltnz bigloo_flt1 2> ../$PLOTDIR/bigloo_vs_flt_bmem.plot | sed -e 's/r7rs-//'  > ../$PLOTDIR/bigloo_vs_flt_bmem.csv) && (cd $PLOTDIR; gnuplot bigloo_vs_flt_bmem.plot) */
#*                                                                     */
#* {*---------------------------------------------------------------------*} */
#* {*    Branch prediction (generated only if branch profile files exist) *} */
#* {*---------------------------------------------------------------------*} */
#* # figure 5.c                                                        */
#* if [ -f $BRANCHS/r7rs-compiler/bigloo.branch ]; then                */
#*   (cd $BRANCHS; $installdir/bigloo/bin/bigloo -i $dir/branch2csv.scm bigloo_vs_fltlb_branch $SCM_BENCHMARKS --key "off" --separator 12 --colors "#000,#$COLORLB" -:- bigloo bigloo_fltlb 2> ../$PLOTDIR/bigloo_vs_fltlb_branch.plot | sed -e 's/r7rs-//'  > ../$PLOTDIR/bigloo_vs_fltlb_branch.csv) && (cd $PLOTDIR; gnuplot bigloo_vs_fltlb_branch.plot) */
#*                                                                     */
#*   (cd $BRANCHS; $installdir/bigloo/bin/bigloo -i $dir/branch2csv.scm bigloo_vs_flt_branch $SCM_BENCHMARKS --key "off" --separator 12 --colors "#000,#$COLORLB" -:- bigloo bigloo_flt bigloo_fltnz 2> ../$PLOTDIR/bigloo_vs_flt_branch.plot | sed -e 's/r7rs-//'  > ../$PLOTDIR/bigloo_vs_flt_branch.csv) && (cd $PLOTDIR; gnuplot bigloo_vs_flt_branch.plot) */
#* fi                                                                  */

#*---------------------------------------------------------------------*/
#*    Hop performance                                                  */
#*---------------------------------------------------------------------*/
# conf=`echo $hop | sed -e 's/hop//'`
# confname=`echo $hop | sed -e 's/hop_//'`
# jsbench="jsbench$conf"
# 
# logs=""
# for b in $JS_BENCHMARKS; do
#   logs="$logs $LOGS/$b.log.json"
# done
#
# $installdir/hop/bin/hop --no-server -- $downloaddir/$jsbench/tools/logbench.js gnuplothistogram.js --nosort --relativesans  --logscale y --engine=$downloaddir/$jsbench/tools/engines -e hop -e hop_nan -e hop_nun -e hop_flt1 --xtics=rotater --target=hop.pdf --format=pdf --size "8,2" --alias "hop.nan=JavaScript NaN-boxing" --alias "hop.nun=JavaScript NuN-boxing" --alias "hop.flt1=JavaScript self-tagging (1-tag)" --alias "hop=orig" --yrange "[0:*]" --colors "red,#$COLORNAN,#$COLORNUN,#$COLORFLTONE" --values --separator 28 --bmargin 6 $logs
# 
# mv hop.plot $PLOTDIR/hop.plot
# mv hop.csv $PLOTDIR/hop.csv
# 
# figure 12
# (cd $PLOTDIR; gnuplot hop.plot)

#*---------------------------------------------------------------------*/
#*    Float Distribution                                               */
#*---------------------------------------------------------------------*/

get_float_percentage() {
  local pattern=$1
  local file=$2
  awk -F, -v "p=$pattern" 'BEGIN {
      total = 0;
      target = 0;
    }
    { 
      total += $2;
      if (match($1, "^" p)) target += $2
    }
    END {
      if (target > 0 && total > 0) { printf "%.0f%% ", (100 * target / total); }
      else { printf "- "; }
    }' $file
}

float_buckets="zero nan inf"
for i in $(seq 0 31); do
  bin=$(printf "%05d" "$(echo "obase=2;$i" | bc)")
  float_buckets="$float_buckets $bin"
done

float_table_csv=$PLOTDIR/floats.csv
echo -n "high-bits $SCM_FLOAT_BENCHMARKS" > $float_table_csv
for pattern in $float_buckets; do
  echo >> $float_table_csv
  echo -n $pattern >> $float_table_csv
  for benchmark in $SCM_FLOAT_BENCHMARKS; do
    echo -n " $(get_float_percentage $pattern "$FLOATS/$benchmark/$benchmark.floats")" >> $float_table_csv
  done
done
cat $float_table_csv | tr -s ' ' | column -t > $PLOTDIR/floats.txt
