# Based off https://numpy.org/doc/1.18/reference/random/extending.html
cimport cython
from cpython.pycapsule cimport PyCapsule_IsValid, PyCapsule_GetPointer
from numpy.random cimport bitgen_t

from numpy.random import PCG64
import numpy as np

cdef const char *capsule_name = "BitGenerator"

cdef class RndmWrapper():
    def __init__(self, seed=1234, buf_size=4096, bitgen_kind=None):
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
        if bitgen_kind is None:
            bitgen_kind = PCG64
        py_gen = bitgen_kind(seed)

        capsule = py_gen.capsule
        self.rng = <bitgen_t *>PyCapsule_GetPointer(capsule, capsule_name)
        # XXX: check the capsule name

        self.buf = np.empty(buf_size, dtype='float64')
        self._fill()

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cdef void _fill(self) nogil:
        self.idx = 0
        for i in range(self.buf.shape[0]):
            self.buf[i] = self.rng.next_double(self.rng.state)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cdef double uniform(self) nogil:
        if self.idx >= self.buf.shape[0]:
            self._fill()
        cdef double value = self.buf[self.idx]
        self.idx += 1 
        return value

