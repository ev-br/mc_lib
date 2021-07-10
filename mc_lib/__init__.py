"""Assorted small utilities for MC simulations.

Intended usage:

from mc_lib.observable cimport RealObservable
from mc_lib.lattice import tabulate_neighbors
from mc_lib.rndm cimport RndmWrapper
"""

__version__ = "0.2"

# This import will check whether the cython sources have been built,
# and if not will raise a useful error.
# from . import __check_build


def get_include():
    import os
    import mc_lib
    return os.path.dirname(mc_lib.__file__)
