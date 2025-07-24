#!/bin/sh
#*=====================================================================*/
#*    serrano/diffusion/article/flt/fst-artifact/scripts/common.sh     */
#*    -------------------------------------------------------------    */
#*    Author      :  Manuel Serrano                                    */
#*    Creation    :  Thu Oct  3 08:39:01 2024                          */
#*    Last change :  Thu Jun 26 10:47:06 2025 (serrano)                */
#*    Copyright   :  2024-25 Manuel Serrano                            */
#*    -------------------------------------------------------------    */
#*    Common utility functions                                         */
#*=====================================================================*/

path=`realpath $0`
dir=`dirname $path`

. $dir/env.sh

action=all
force=false
verbose=1

mkdir -p $logdir
log=$logdir/${package}.log

makeopts="-j -l4"

current_dir=$PWD

end() {
  cd $current_dir
}

trap end EXIT

parse_cmdline() {
  while : ; do
    case $1 in
      "")
	break;;

      --downloaddir)
	shift
	downloaddir=$1;;
      
      --installdir)
	shift
	installdir=$1;;
      
      --commit)
	shift
	commit=$1;;
      
      --branch)
	shift
	branch=$1;;
      
      --force-clean)
	force=true;;
      
      --verbose)
	verbose=1;;
      
      --silent)
	verbose=0;;
      
      download)
	action=download;;
      
      install)
	action=install;;
      
      all)
	action=all;;
      
      *)
	echo "usage: $0 [--force-clean] [--download-dir DIR] [--install-dir DIR] [--commit ID] [--branch NAME] [download | install | all]"
	exit 1;;
    esac
    shift
  done
}

print() {
  if [ `expr $verbose ">=" 1` ]; then
    echo "$*"
  fi
}

check_dir() {
  if [ ! -d $downloaddir ]; then
    echo "Directory \"$downloaddir\" missing!"
    exit 2
  fi
}  

download_tarball() {
  if [ -d $downloaddir ]; then
    if [ "$force " = "true " ]; then
      rm -rf $downloaddir
    fi
  fi
    
  if [ ! -d $downloaddir ]; then
    print "   \e[1;${color}mtarball\e[0m curl $tarballurl"
    mkdir -p $downloaddir
    curl -f -L --retry 5 $tarballurl --silent | tar xJ -C $downloaddir --no-same-owner --strip-components=1 >> $log 2>&1
  fi
}
  
download_git() {
  if [ -d $downloaddir ]; then
    if [ "$force " = "true " ]; then
      rm -rf $downloaddir
    else
      cur_commit=`(cd $downloaddir; git rev-parse HEAD 2> /dev/null)`

      if [ "$cur_commit " != "$commit " ]; then
	rm -rf $downloaddir
      fi
    fi
  fi
  
  if [ ! -d $downloaddir ]; then
    print "   \e[1;${color}mgit\e[0m clone -b $branch $giturl [$commit]"
    (mkdir -p $downloaddir >> $log 2>&1; \
     cd $downloaddir; \
     git init >> $log 2>&1; \
     git remote add origin $giturl >> $log 2>&1; \
     git fetch origin $commit >> $log 2>&1; \
     git checkout FETCH_HEAD >> $log 2>&1) || (tail -n 10 $log; exit 3)

    #git clone -b $branch --depth 1 $giturl $downloaddir > $log 2>&1 && (cd $downloaddir; git checkout $commit >> $log 2>&1) || (tail -n 10 $log; exit 3)
  fi
}

download_git_with_clone() {
  if [ -d $downloaddir ]; then
    if [ "$force " = "true " ]; then
      rm -rf $downloaddir
    else
      cur_commit=`(cd $downloaddir; git rev-parse HEAD 2> /dev/null)`

      if [ "$cur_commit " != "$commit " ]; then
	rm -rf $downloaddir
      fi
    fi
  fi

  if [ ! -d $downloaddir ]; then
    print "   \e[1;${color}mgit\e[0m clone -b $branch $giturl [$commit]"
    git clone -b $branch $giturl $downloaddir > $log 2>&1 && (cd $downloaddir; git checkout $commit >> $log 2>&1) || (tail -n 10 $log; exit 3)
  fi
}

configure() {
  print "   \e[1;${color}mconfigure\e[0m $@"
  (cd $downloaddir && ./configure "$@" >> $log 2>&1) || (tail -n 10 $log; exit 4)
}

make_compile() {
  print "   \e[1;${color}mmake\e[0m $@"
  (cd $downloaddir && make ${makeopts} $@ >> $log 2>&1) || (tail -n 10 $log; exit 5)
}

make_install() {
  print "   \e[1;${color}mmake install\e[0m $@"
  (cd $downloaddir && make install >> $log 2>&1) || (tail -n 10 $log; exit 6)
}

find_best_c_compiler() {
    for CC in gcc-14 gcc-13 gcc-12 gcc-11 gcc-10 gcc-9 gcc-8 gcc clang ; do
      if which $CC > /dev/null 2>&1 ; then
	export CC
        return 0
      fi
    done

    return 1
}

find_best_c_compiler

# top level expressions
parse_cmdline $*

print "\e[1;${color}m${package}\e[0m (see $log)"
echo -n "" > $log

