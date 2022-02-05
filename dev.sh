#!/bin/sh
set -e

meson setup builddir --prefix=$PWD/installdir
meson install -C builddir
# Get python version for PYHTONPATH
ver=$(python -c'from sys import version_info as v; print("%s.%s"%(v.major, v.minor))')
export PYTHONPATH=$PWD/installdir/lib/python$ver/site-packages/
pytest mc_lib -v --pyargs
