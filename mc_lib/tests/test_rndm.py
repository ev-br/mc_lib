""" Collection of RndmWrapper's Cython API tests.

Since RndmWrapper is used from Cython, tests are defined in `__check_rndm.pyx`
to exercise the Cython API. Here we add python wrappers so that pytest collects
finds them. 

"""
import mc_lib.__check_rndm as mod

def test_identical():
    mod.test_identical()


def test_generators():
    mod.test_generators()


def test_wrong_generator():
    mod.test_wrong_generator()


def test_worker_id():
    mod.test_worker_id()

def test_idx_bufsize():
    mod.test_idx_bufsize()
    


