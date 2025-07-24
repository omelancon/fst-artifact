#!/bin/sh
#*=====================================================================*/
#*    .../diffusion/article/flt/fst-artifact/scripts/archive.sh        */
#*    -------------------------------------------------------------    */
#*    Author      :  manuel serrano                                    */
#*    Creation    :  Fri Jul  4 07:54:53 2025                          */
#*    Last change :  Fri Jul  4 07:59:36 2025 (serrano)                */
#*    Copyright   :  2025 manuel serrano                               */
#*    -------------------------------------------------------------    */
#*    Archive statistics for one machine.                              */
#*=====================================================================*/

#*---------------------------------------------------------------------*/
#*    Configuration                                                    */
#*---------------------------------------------------------------------*/
path=`realpath $0`
dir=`dirname $path`

. $dir/env.sh

date=`date +"%d-%m-%Y:%H-%M"`

dir=$host.$date
mkdir $host.$date

if [ -d $STATS ]; then
  mv $STATS $dir
fi  
if [ -d $BMEMS ]; then
  mv $BMEMS $dir
fi  
if [ -d $BRANCHS ]; then
  mv $BRANCHS $dir
fi  
if [ -d $HEAPS ]; then
  mv $HEAPS $dir
fi  
if [ -d $FLOATS ]; then
  mv $FLOATS $dir
fi  
if [ -d $LOGS ]; then
  mv $LOGS $dir
fi  
