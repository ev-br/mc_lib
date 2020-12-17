#cython: language_level=3

# Based off https://numpy.org/doc/1.18/reference/random/extending.html
cimport cython
from cpython.pycapsule cimport PyCapsule_IsValid, PyCapsule_GetPointer
from numpy.random cimport bitgen_t

from numpy.random import PCG64, SeedSequence
import numpy as np

cdef const char *capsule_name = "BitGenerator"

cdef class RndmWrapper():
    def __init__(self, seed=(1234, 0), buf_size=4096, bitgen_kind=None):
        """ Random generator wrapper class for use from Cython.
        
        Intended usage (in Cython):
        >>> rndm = RndmWrapper(seed=(1234, 0))
        >>> rndm.uniform()
        
        This generates a single random draw, which is identical to
        >>> from numpy.random import PCG64, Generator, SeedSequence
        >>> seed_seq = SeedSequence((1234, 0))
        >>> bitgen = PCG64(seed_seq)
        >>> rndm = Generator(bitgen)
        >>> rndm.uniform()
        
        NB: When used from jupyter notebook's %%cython, it seems to require
        explicit numpy include path, like so::
        
            np.get_include()
                    
            %%cython -I <copy-paste the `np.get_include() output`>
            from cython_template.rndm cimport RndmWrapper
        """
        if bitgen_kind is None:
            bitgen_kind = PCG64

        # cf Numpy-discussion list, K.~Sheppard, R.~Kern, June 29, 2020 and below
        # https://mail.python.org/pipermail/numpy-discussion/2020-June/080794.html
        # also
        # https://mail.python.org/pipermail/numpy-discussion/2020-December/081323.html
        entropy, num = seed
        seed_seq = SeedSequence((entropy, num))
        py_gen = bitgen_kind(seed_seq)
        
        # store the python object to avoid it being garbage collected
        self.py_gen = py_gen

        capsule = py_gen.capsule
        self.rng = <bitgen_t *>PyCapsule_GetPointer(capsule, capsule_name)
        if not PyCapsule_IsValid(capsule, capsule_name):
            raise ValueError("Invalid pointer to anon_func_state")

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

