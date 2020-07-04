import numpy as np
from numpy.random import PCG64, MT19937, Generator, SeedSequence
from numpy.testing import assert_equal
from pytest import raises

from rndm_wrapper cimport RndmWrapper


def test_identical():
    # RndmWrapper's stream is identical to the wrapped generator
    cdef RndmWrapper rndm = RndmWrapper(seed=(1234567, 0))
    r = [rndm.uniform() for _ in range(15)]

    bitgen = PCG64(seed=1234567)
    gen = Generator(bitgen)
    r_np = gen.uniform(size=15)

    assert_equal(r_np, r)


def test_generators():
    # RndmWrapper accepts alternative generators
    cdef RndmWrapper rndm

    for bitgen in [MT19937]:
        rndm = RndmWrapper(seed=(12345, 0), bitgen_kind=bitgen)
        r = [rndm.uniform() for _ in range(15)]

        gen = Generator(bitgen(12345))
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

TESTS = [test_identical,
         test_generators,
         test_wrong_generator,
         test_worker_id,
]

for test in TESTS:
    test()
    print('.', end='')
print('\n')
