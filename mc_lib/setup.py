import os
import numpy as np

PACKAGE_NAME = 'mc_lib'


def configuration(parent_package='', top_path=None):
    from numpy.distutils.misc_util import Configuration

    config = Configuration(PACKAGE_NAME, parent_package, top_path)

    config.add_subpackage('__check_build')
    config.add_subpackage('tests')

    config.add_extension('observable',
                         sources=['observable.cpp'],
                         depends=['_observable/observable.h',
                                  'observable.pyx'],
                         language='c++',)

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
