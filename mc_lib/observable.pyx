# cython: language_level=3

# hack to make cythonize detect c++
#from libcpp.vector cimport vector

import numpy as np

from .observable cimport ScalarObservable
from .observable cimport trampoline_mrg

cdef class RealObservable():

    def __cinit__(self):
        self._obs = ScalarObservable[double]()

    @property
    def mean(self):
        return self._obs.mean()

    @property
    def errorbar(self):
        return self._obs.errorbar()

    @property
    def is_converged(self):
        return self._obs.converged()

    @property
    def num_blocks(self):
        return self._obs.num_blocks()

    @property
    def Z_b(self):
        return self._obs.Z_b()

    cpdef void add_measurement(self, double value):
        self._obs << value

    def pretty_print_block_stats(self, fmt=None):
        """Print the block stats.
        
        Parameters
        ----------
        fmt : str, optional
            Format of the output. Default is `'\t %s +/- %s (%s)'`."
        """
        stats = block_stats(self)
        
        if fmt is None:
            fmt = "\t %s +/- %s  (%s)"
        print('----')
        for av, err, num in stats:
            s = fmt % (av, err, num)
            print(s)
        print('----')

    def __getstate__(self):
        cdef vector[double] blocks_vec = self._obs.blocks()
        blocks_arr = np.empty(self.num_blocks, dtype=float)
        for j in range(blocks_arr.shape[0]):
            blocks_arr[j] = blocks_vec[j]
        return blocks_arr, self.Z_b

    def __setstate__(self, state):
        blocks_arr, Z_b = state
        cdef vector[double] blocks_vec;
        for j in range(blocks_arr.shape[0]):
            blocks_vec.push_back(blocks_arr[j])
        self._obs.from_blocks(blocks_vec, Z_b)


def block_stats(RealObservable obs):
    """Return an array of triplets (mean, err, block_size)."""
    cdef vector[double] v_av, v_err, v_size

    trampoline_mrg(obs._obs, v_av, v_err, v_size)
    
    dt = np.dtype([("mean", float), ("errorbar", float), ("num_blocks", int)])
    arr = np.empty(v_av.size(), dtype=dt)
    for j in range(arr.shape[0]):
        arr[j] = (v_av[j], v_err[j], v_size[j])
    return arr
