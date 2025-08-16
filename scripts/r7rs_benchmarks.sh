#!/bin/sh
package=r7rs_benchmarks
color=39

. `dirname $0`/versions.sh
. `dirname $0`/common.sh

# download
if [ "$action " = "download " -o "$action " = "all " ]; then
  download_git || exit 1
  (cd $downloaddir && \
   git restore --source=882b28c9fe931a912f7d670816e5d14454e246a5 -- \
     src/Chez-prelude.scm \
     src/Chez-postlude.scm && \
   git show 7357ac5b2b59c88a6f2e5e7267d2da8259a6ce92 -- bench | git apply -R --3way --index) >> $log 2>&1
   (cd $downloaddir && git checkout --theirs bench) >> $log 2>&1
   cp -R $downloaddir/../bglstone/src/r7rs/inputs/* $downloaddir/inputs
   sed -i 's|\.\./\.\./r7rs/inputs|inputs|g' "$downloaddir"/inputs/*.input
fi
