from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import numpy

ext = Extension("rndm_wrapper", ["rndm_wrapper.pyx"],
                include_dirs = [numpy.get_include()],
                language="c++",)

ext_test = Extension("test_rndm_wrapper", ["test_rndm_wrapper.pyx"],
                include_dirs = [numpy.get_include()],
                language="c++",)

ext_modules = [ext, ext_test]

for e in ext_modules:
    e.cython_directives = {'language_level' : '3'}

setup(ext_modules=ext_modules,
      cmdclass = {'build_ext': build_ext})

