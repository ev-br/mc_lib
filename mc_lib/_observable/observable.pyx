# distutils: language = c++

# hack to make cythonize detect c++
#from libcpp.vector cimport vector

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

   # def __lshift__(self, value):
   #     self._obs.add_measurement(value)
