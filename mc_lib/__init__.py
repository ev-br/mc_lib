"""Assorted small utilities for MC simulations.

Intended usage:

from mc_lib import RealObservable
from mc_lib.lattice import tabulate_neighbors
from mc_lib.rndm cimport RndmWrapper
"""

__version__ = "0.0.1"

# This import will check whether the cython sources have been built,
# and if not will raise a useful error.
from . import __check_build
