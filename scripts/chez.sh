#!/bin/sh
package=chez
color=33

CHEZ_CONFIGURE_OPTIONS=""

. `dirname $0`/versions.sh
. `dirname $0`/common.sh

# download
if [ "$action " = "download " -o "$action " = "all " ]; then
  download_git_with_clone || exit 1
fi

# software package install
if [ "$action " = "install " -o "$action " = "all " ]; then
  check_dir

  if [ ! -f $installdir/bin/gsc ]; then
    if [ ! -f ${downloaddir}/makefile ]; then
      configure --prefix=${installdir} $CHEZ_CONFIGURE_OPTIONS CC="$CC" || exit 1
    fi
    make_compile || exit 1
    make_install
  fi
fi
