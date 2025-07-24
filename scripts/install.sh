#!/bin/sh
#*=====================================================================*/
#*    .../diffusion/article/flt/fst-artifact/scripts/install.sh        */
#*    -------------------------------------------------------------    */
#*    Author      :  Manuel Serrano                                    */
#*    Creation    :  Thu Oct  3 09:44:21 2024                          */
#*    Last change :  Fri Jun 27 17:34:32 2025 (serrano)                */
#*    Copyright   :  2024-25 Manuel Serrano                            */
#*    -------------------------------------------------------------    */
#*    Install all the FLT compilers                                    */
#*=====================================================================*/

#*---------------------------------------------------------------------*/
#*    Configuration                                                    */
#*---------------------------------------------------------------------*/
path=`realpath $0`
dir=`dirname $path`

. $dir/env.sh

plot_only=false

for arg in "$@"; do
  if [ "$arg" = "--plot-only" ]; then
    plot_only=true
    break
  fi
done

if $plot_only; then
    $dir/bigloo.sh
    $dir/bglstone.sh
    exit 0
fi

# compilers
$dir/bigloo.sh
$dir/bigloo_flt.sh
$dir/bigloo_fltlb.sh
$dir/bigloo_fltnz.sh
$dir/bigloo_flt1.sh
$dir/bigloo_nan.sh
$dir/bigloo_nun.sh

$dir/gambit_0.sh
$dir/gambit_1.sh
$dir/gambit_2.sh
$dir/gambit_3.sh
$dir/gambit_4.sh
$dir/gambit_nun.sh

# $dir/hop.sh
# $dir/hop_flt.sh
# $dir/hop_fltlb.sh
# $dir/hop_fltv.sh
# $dir/hop_fltnz.sh
# $dir/hop_flt1.sh
# $dir/hop_nan.sh
# $dir/hop_nun.sh

# benchmark suites
$dir/bglstone.sh
$dir/bglstone_flt.sh
$dir/bglstone_fltlb.sh
$dir/bglstone_fltnz.sh
$dir/bglstone_flt1.sh
$dir/bglstone_nan.sh
$dir/bglstone_nun.sh

$dir/bglstone_gambit_0.sh
$dir/bglstone_gambit_1.sh
$dir/bglstone_gambit_2.sh
$dir/bglstone_gambit_3.sh
$dir/bglstone_gambit_4.sh
$dir/bglstone_gambit_nun.sh

# $dir/jsbench.sh
