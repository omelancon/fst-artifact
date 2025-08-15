#!/bin/sh

package=cbench
color=33

. `dirname $0`/versions.sh
. `dirname $0`/common.sh

mkdir -p $installdir

for benchmark in $C_BENCHMARKS; do
    if [ "$benchmark" = "sum1" ]; then
        cp $CBENCH_SOURCES/sum1.data $installdir/sum1.data
    fi

    echo -n "compiling $benchmark.c ... "
    if $CC -O3 "$CBENCH_SOURCES/$benchmark.c" -o "$installdir/$benchmark.exe" -lm 2>> "$logdir/cbench.log"; then
        echo "DONE"
    else
        echo "\033[0;31mFAIL\033[0m"
    fi
done