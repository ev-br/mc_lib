from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import numpy

ext = Extension("observable", 
                sources=["observable.pyx"],
                #sources="observable.h"
                #include_dirs=[numpy.get_include()],
                extra_compile_args=["-std=c++11"],
                language="c++",)

ext_modules = [ext]

for e in ext_modules:
    e.cython_directives = {'language_level' : '3'}

setup(ext_modules=ext_modules,
      cmdclass = {'build_ext': build_ext})

