#!/bin/sh
#*=====================================================================*/
#*    serrano/diffusion/article/flt/fst-artifact/scripts/env.sh        */
#*    -------------------------------------------------------------    */
#*    Author      :  Manuel Serrano                                    */
#*    Creation    :  Sun Mar 23 08:00:28 2025                          */
#*    Last change :  Fri Jun 27 15:09:23 2025 (serrano)                */
#*    Copyright   :  2025 Manuel Serrano                               */
#*    -------------------------------------------------------------    */
#*    Artifcat environment variables                                   */
#*=====================================================================*/

REPETITION=10
FST_ARTIFACT_ROOT=${FST_ARTIFACT_ROOT:-$PWD}

downloaddir=${DOWNLOADDIR:-$FST_ARTIFACT_ROOT/download/${package}}
installdir=${INSTALLDIR:-$FST_ARTIFACT_ROOT/install/${package}}
logdir=${LOGDIR:-$FST_ARTIFACT_ROOT/log}


host=$FST_HOST

if [ "$host " = " " ]; then
  host=`hostname`
  if [ "$host " = " " ]; then
    host=`uname -n`
    if [ "$host " = " " ]; then
      host=$HOST
      if [ "$host " = " " ]; then
	host=unknown
      fi
    fi
  fi

fi

PLOTDIR=plot.$host

PATH=$PATH:$installdir/bigloo/bin
export PATH

STATS=`dirname $dir`/stats.$host
BMEMS=`dirname $dir`/bmems.$host
BRANCHS=`dirname $dir`/branchs.$host
HEAPS=`dirname $dir`/heaps.$host
FLOATS=`dirname $dir`/floats.$host
LOGS=`dirname $dir`/logs.$host

# artifact colors
COLORFLTONE="FF00FF"
COLORFLT="61D836"
COLORFLTNZ="00A2FF"
COLORFLTNZ_LIGHT="82BEFA"
COLORFLTFOUR="909090"
COLORLB="d83812"
COLORNUN="cf0034"
COLORNAN="edd20b"
COLORALLOC="aa0000"
COLORFLT2="ffb6f3" # gambit 2-tag
COLORFLTLB="ac2db7"

COLORFLTONE_NAME="bold pink"
COLORFLT_NAME="green"
COLORFLTNZ_NAME="dark blue"
COLORFLTNZ_LIGHT_NAME="light blue"
COLORFLTFOUR_NAME="gray"
COLORLB_NAME="orange"
COLORNUN_NAME="red"
COLORNAN_NAME="yellow"
COLORALLOC_NAME="red"
COLORFLT2_NAME="light pink" # gambit 2-tag
COLORFLTLB_NAME="purple"

# benchmarks
BENCH=r7rs
SCM_NONFLOAT_BENCHMARKS="r7rs-compiler r7rs-dynamic r7rs-earley r7rs-graphs r7rs-matrix r7rs-maze r7rs-nboyer r7rs-parsing r7rs-peval r7rs-sboyer r7rs-scheme r7rs-slatex"
SCM_FLOAT_BENCHMARKS="r7rs-fft r7rs-fibfp r7rs-mbrot r7rs-nucleic r7rs-pnpoly r7rs-ray r7rs-simplex r7rs-sumfp r7rs-sum1"
SCM_BENCHMARKS="$SCM_NONFLOAT_BENCHMARKS $SCM_FLOAT_BENCHMARKS"

SCM_NONFLOAT_BENCHMARKS_NAMES=$(echo $SCM_NONFLOAT_BENCHMARKS | sed -E 's/\br7rs-//g')
SCM_FLOAT_BENCHMARKS_NAMES=$(echo $SCM_FLOAT_BENCHMARKS | sed -E 's/\br7rs-//g')
SCM_BENCHMARKS_NAMES=$(echo $SCM_BENCHMARKS | sed -E 's/\br7rs-//g')

JS_BENCHMARKS="bague base64 basic-es2015 boyer boyer-scm crypto  crypto-aes crypto-md5 crypto-sha1 date-format-tofte date-format-xparb deltablue earley earley-boyer earley-scm flightplanner hash-map leval maze puzzle qsort regexp richards sieve sieve-mem splay tagcloud traverse unipoker almabench n-body navier-stokes raytrace"

# vector size for heap benchmarks
SCM_BENCHMARKS_VECTOR_SIZES="0 10000 100000 1000000 10000000 100000000"
SCM_SMALLEST_NON_ZERO_SIZE=10000

# compilers
BIGLOOS="bigloo bigloo_flt bigloo_fltlb bigloo_fltnz bigloo_flt1 bigloo_nan bigloo_nun"

# compilers
GAMBITS="gambit_0 gambit_1 gambit_2 gambit_3 gambit_4 gambit_nun"
GAMBIT_FLOAT="gambit_0"
