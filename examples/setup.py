from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import numpy

# XXX HACK: find out the include path (observable.pxd)
import os
import inspect
import mc_lib
incl_path = os.path.split(inspect.getsourcefile(mc_lib))[0]

ext = Extension("cy_ising", ["cy_ising.pyx"],
                include_dirs = [numpy.get_include(),
                                #'/home/br/sweethome/proj/mc_lib/mc_lib'],
                                incl_path],
                language='c++',)

setup(ext_modules=[ext],
      cmdclass = {'build_ext': build_ext})
