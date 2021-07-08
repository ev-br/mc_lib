from pckg.inc.mc_lib.rndm cimport RndmWrapper

cdef check_build_rndm():
    cdef RndmWrapper rndm = RndmWrapper((1234, 0))
    rndm.uniform()
    return

def chk_bld():
    check_build_rndm()
    print('rndm work')
    return