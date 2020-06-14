# Based off https://numpy.org/doc/1.18/reference/random/extending.html

from cpython.pycapsule cimport PyCapsule_IsValid, PyCapsule_GetPointer
from numpy.random cimport bitgen_t
from numpy.random import PCG64
import numpy as np

cimport cython


cdef const char *capsule_name = "BitGenerator"


cdef class RndmWrapper(object):
    """ Random generator wrapper class for use from Cython.
    
    Intended usage (in Cython):
    >>> rndm = RndmWrapper(seed=1234)
    >>> rndm.uniform()
    
    This generates a single random draw, which is identical to
    >>> from numpy.random import PCG64, Generator
    >>> bitgen = PCG64(seed=1234)
    >>> rndm = Generator(bitgen)
    >>> rndm.uniform()
    """
   
    def __init__(self, seed=1234, buf_size=4096, bitgen_kind=None):
        self.seed = seed
        
        if bitgen_kind is None:
            bitgen_kind = PCG64
        self.py_gen = bitgen_kind(seed)

        capsule = self.py_gen.capsule
        self.rng = <bitgen_t *>PyCapsule_GetPointer(capsule, capsule_name)
        # TODO: check the capsule name
        
        self._buf = np.empty(buf_size, dtype='float64')
        self._fill_buffer()
    
    cdef double _single_uniform(self) nogil:
        return self.rng.next_double(self.rng.state)
    
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cdef void _fill_buffer(self) nogil:
        for i in range(self._buf.shape[0]):
            self._buf[i] = self._single_uniform()
        self.idx = 0
 
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cdef double uniform(self) nogil:
        if self.idx >= self._buf.shape[0]:
            self._fill_buffer()

        cdef double value = self._buf[self.idx]
        self.idx += 1
        return value
        
    def py_uniform(self):
        return self.uniform()

#####################################

