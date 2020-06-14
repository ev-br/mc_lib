from numpy.random import PCG64, MT19937, Generator
from numpy.testing import assert_equal

from pytest import raises

from .rndm_wrapper import RndmWrapper

def test_identic():
    # RndmWrapper's stream is identical to the wrapped generator
    rndm = RndmWrapper(seed=1234567)
    r = [rndm.py_uniform() for _ in range(5)]

    bitgen = PCG64(seed=1234567)
    gen = Generator(bitgen)
    r_np = gen.uniform(size=5)

    assert_equal(r_np, r)


def test_generators():
    # RndmWrapper accepts alternative generators
    for bitgen in [MT19937]:
        rndm = RndmWrapper(seed=12345, bitgen_kind=bitgen)
        r = [rndm.py_uniform() for _ in range(5)]

        gen = Generator(bitgen(12345))
        r_np = gen.uniform(size=5)

        assert_equal(r_np, r)


def test_wrong_generator():
    with raises(TypeError):
        RndmWrapper(bitgen_kind='oops')

    class fake(object):
        def __call__(self):
            pass

    with raises(TypeError):
        RndmWrapper(bitgen_kind=fake())
