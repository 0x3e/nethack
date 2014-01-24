#!/usr/bin/env bash
#http://nethack.sourceforge.net/docs/nh343/README.linux.txt
set -e
er=''
#yacc
command -v yacc >/dev/null 2>&1 || er="yacc not installed\n"
#lex
command -v lex >/dev/null 2>&1 || er=$er"lex not installed\n"
ncurses_count=$(ldconfig -p 2> /dev/null |grep ncurses|wc -l)

if [ "$ncurses_count" == "0" ]
then
  er=$er"ncurses not installed\n"
fi
if [ -n "$er" ]
then
  echo -e "$er"
  exit 1
fi

if [ ! -d nethacks ]
then
  mkdir nethacks
fi

cd nethacks

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

echo "445b3ebcfeadb75c8ccab17dfcfda5b8  nh343-menucolor.diff
d527e20189b0dfcd6ed7b4749687f6fd  sortloot-343.diff
b11eeacbf6e58496563723dcf1047ac1  nh343-statuscolors.patch
21479c95990eefe7650df582426457f9  nethack-343-src.tgz" > md5.txt 

md5sum --check md5.txt || exit 4

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

if [ "$1" == "make" ]
then
  make all
fi
if [ "$1" == "install" ]
then
  make all && sudo make install
fi
