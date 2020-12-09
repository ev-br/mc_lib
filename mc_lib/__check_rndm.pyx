# cython: language_level=3

""" This is a collection of tests to (lightly) exercise the Cython API of
RndmWrapper. 

Tests can be run two ways:

- Simply importing the module 
>>> import __check_rndm

- Alternatively, there is a set of python wrappers for each of the tests here,
see tests/test_rndm.py.
These python wrappers are automatically discovered by pytest.

The basic idea is taken from https://stackoverflow.com/questions/42259741.
"""

import numpy as np
from numpy.random import PCG64, MT19937, Generator, SeedSequence
from numpy.testing import assert_equal
from pytest import raises

from mc_lib.rndm cimport RndmWrapper


def test_identical():
    # RndmWrapper's stream is identical to the wrapped generator
    cdef RndmWrapper rndm = RndmWrapper(seed=(1234567, 0))
    r = [rndm.uniform() for _ in range(15)]

    seed_seq = SeedSequence(1234567, spawn_key=(0,))
    bitgen = PCG64(seed_seq)
    gen = Generator(bitgen)
    r_np = gen.uniform(size=15)

    assert_equal(r_np, r)


def test_generators():
    # RndmWrapper accepts alternative generators
    cdef RndmWrapper rndm

    for bitgen in [MT19937]:
        rndm = RndmWrapper(seed=(12345, 0), bitgen_kind=bitgen)
        r = [rndm.uniform() for _ in range(15)]

        seed_seq = SeedSequence(12345, spawn_key=(0,))
        gen = Generator(bitgen(seed_seq))
        r_np = gen.uniform(size=15)

        assert_equal(r_np, r)


def test_wrong_generator():
    with raises(TypeError):
        RndmWrapper(bitgen_kind='oops')

    class fake(object):
        def __call__(self):
            pass

    with raises(TypeError):
        RndmWrapper(bitgen_kind=fake())


def test_worker_id():
    cdef RndmWrapper rndm = RndmWrapper(seed=(1234567, 1))
    r = [rndm.uniform() for _ in range(15)]

    entropy = 1234567
    seed_seq = SeedSequence(entropy).spawn(8)[1]
    bitgen = PCG64(seed_seq)
    gen = Generator(bitgen)
    r_np = gen.uniform(size=15)

    assert_equal(r_np, r)


#####################################
if __name__ == "__main__":

    TESTS = [test_identical,
             test_generators,
             test_wrong_generator,
             test_worker_id,
    ]

    for test in TESTS:
        test()
        print('.', end='')
    print('\n')
