from numpy.random cimport bitgen_t

cdef class RndmWrapper:
    cdef bitgen_t *rng
    cdef long seed
    cdef object py_gen
    cdef double[::1] _buf
    cdef Py_ssize_t idx

    # public
    cdef double uniform(self) nogil

    # implementation details
    cdef double _single_uniform(self) nogil
    cdef void _fill_buffer(self) nogil
