import sys
import numpy as np

PACKAGE_NAME = 'mc_lib'


# Special dance for MacOS
# https://github.com/cython/cython/issues/2694
if sys.platform == "darwin":
    extra_compile_args = ["-stdlib=libc++", "-std=c++11"]
else:
    extra_compile_args = []


def configuration(parent_package='', top_path=None):
    from numpy.distutils.misc_util import Configuration

    config = Configuration(PACKAGE_NAME, parent_package, top_path)

    config.add_subpackage('__check_build')
    config.add_subpackage('tests')

    config.add_extension('observable',
                         sources=['observable.cpp'],
                         depends=['_observable/observable.h',
                                  'observable.pyx', 'observable.pxd'],
                         language='c++',
                         extra_compile_args=extra_compile_args,
    )

    # the name of the extension *must* match the .pyx name:
    # https://stackoverflow.com/questions/8024805
    config.add_extension('rndm',
                         sources=['rndm.c'],
                         depends=['rndm.pyx', 'rndm.pxd'],
                         include_dirs=[np.get_include()],)

    config.add_extension('__check_rndm',
                         sources=['__check_rndm.c'],
                         depends=['__check_rndm.pyx'])

    config.add_subpackage('lattices')

    return config


if __name__ == '__main__':
    from numpy.distutils.core import setup
    setup(**configuration(top_path='').todict())
