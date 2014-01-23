#!/usr/bin/env bash

if [ ! -d src ]
then
  mkdir src
fi

cd src

if [ ! -f sortloot-343.diff ]
then
  wget "http://web.archive.org/web/20100413233903/http://www.netsonic.fi/~walker/nh/sortloot-343.diff"
fi
if [ ! -f nh343-statuscolors.patch ]
then
  wget "http://www.ben-kiki.org/oren/statuscolors/nh343-statuscolors.patch"
fi
if [ ! -f nh343-menucolor.diff ]
then
  wget "http://bilious.alt.org/~paxed/nethack/nh343-menucolor.diff"
fi
if [ ! -f nethack-343-src.tgz ]
then
  wget "http://aarnet.dl.sourceforge.net/project/nethack/nethack/3.4.3/nethack-343-src.tgz"
fi

if [ ! -f md5.txt ]
then
  echo "21479c95990eefe7650df582426457f9 nethack-343-src.tgz" > md5.txt 
fi

if [ -d nethack-3.4.3 ]
then
  rm -rf nethack-3.4.3
fi

tar xzf nethack-343-src.tgz

sed -i -e's/nethack-3.4.3-orig/nethack-3.4.3/' nh343-menucolor.diff

patch -p0 < nh343-menucolor.diff
patch -p0 < sortloot-343.diff
patch -p0 < nh343-statuscolors.patch

cd nethack-3.4.3
pushd sys/unix/
sh setup.sh
popd
sed -i -e's@/\* #define LINUX \*/@#define LINUX@' include/unixconf.h
sed -i -e's/WINTTYLIB = -ltermlib/WINTTYLIB = -lncurses/' src/Makefile
make all
