#!/bin/sh
set -e

meson setup builddir --prefix=$PWD/installdir
meson install -C builddir
# Get python version for PYHTONPATH
ver=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1.\2/')
export PYTHONPATH=$PWD/installdir/lib/python$ver/site-packages/
pytest mc_lib -v --pyargs
