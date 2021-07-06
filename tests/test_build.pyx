cimport cython

from mc_lib.rndm import RndmWrapper

cdef int test_rndm_c():
    cdef RndmWrapper rndm = RndmWrapper((1234, 0))
    return rndm.uniform()

def test_rndm():
    print(test_rndm_c())

