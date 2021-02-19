# cython: language_level=3

from numpy.random cimport bitgen_t

cdef class RndmWrapper():
    cdef:
        double[::1] buf
        Py_ssize_t idx
        bitgen_t *rng
        
        object py_gen

    # public
    cdef double uniform(self) nogil
 
    # implementation details
    cdef void _fill(self) nogil
