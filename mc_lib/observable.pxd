from libcpp cimport bool as cpp_bool
from libcpp.vector cimport vector

cdef extern from "_observable/observable.h" namespace "mc_stats":
    cdef cppclass ScalarObservable[T]:
        ScalarObservable()
        ScalarObservable(size_t b_n_max)   # FIXME: how to use from py/cy?

        void operator<<(T value)
        T mean() const
        T errorbar() const
        cpp_bool converged() const

        vector[T] blocks() const
        double Z_b() const
        size_t num_blocks() const


cdef class RealObservable():
    cdef ScalarObservable[double] _obs

    cpdef void add_measurement(self, double value)

