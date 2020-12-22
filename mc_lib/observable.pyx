# distutils: language = c++

# hack to make cythonize detect c++
#from libcpp.vector cimport vector
cdef extern from "_observable/observable.h" namespace "mc_stats":
    void trampoline_mrg(const ScalarObservable[double]& obs,
                        vector[double] v_av,
                        vector[double] v_err,
                        vector[double] v_size)

import numpy as np

from observable cimport ScalarObservable

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



def block_stats(RealObservable obs):
    """Return an array of triplets (mean, err, block_size)."""
    cdef vector[double] v_av, v_err, v_size

    trampoline_mrg(obs._obs, v_av, v_err, v_size)
    
    dt = np.dtype([("mean", float), ("errorbar", float), ("num_blocks", int)])
    arr = np.empty(v_av.size(), dtype=dt)
    for j in range(arr.shape[0]):
        arr[j] = (v_av[j], v_err[j], v_size[j])
    return arr
