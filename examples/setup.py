import sys

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import numpy
import mc_lib

# Special dance for MacOS
# https://github.com/cython/cython/issues/2694
if sys.platform == "darwin":
    extra_compile_args = ["-stdlib=libc++", "-std=c++11"]
else:
    extra_compile_args = []


ext = Extension("cy_ising", ["cy_ising.pyx"],
                include_dirs = [numpy.get_include(),
                                mc_lib.get_include()],
                language='c++',
                extra_compile_args=extra_compile_args,
      )

setup(ext_modules=[ext],
      cmdclass = {'build_ext': build_ext})
