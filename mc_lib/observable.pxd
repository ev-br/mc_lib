# cython: language_level=3

from libcpp cimport bool as cpp_bool
from libcpp.vector cimport vector

cdef extern from "_observable/observable.h" namespace "mc_stats":
    cdef cppclass ScalarObservable[T]:
        ScalarObservable()
        ScalarObservable(size_t b_n_max)   # FIXME: how to use from py/cy?
        void from_blocks(vector[T] blocks, size_t Z_b)

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


# needed to work around cython not understanding std::tuple
cdef extern from "_observable/observable.h" namespace "mc_stats":
    void trampoline_mrg(const ScalarObservable[double]& obs,
                        vector[double] v_av,
                        vector[double] v_err,
                        vector[double] v_size)
