from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import numpy

ext = Extension("exact_ising", ["exact_ising.pyx"],
                include_dirs = [numpy.get_include()],
                language='c++',)

setup(ext_modules=[ext],
      cmdclass = {'build_ext': build_ext})
