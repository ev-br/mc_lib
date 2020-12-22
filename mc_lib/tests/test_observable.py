import numpy as np
from numpy.testing import assert_allclose, assert_equal

from mc_lib.observable import RealObservable, block_stats

def test_simple():
    r = RealObservable()
    lst = list(range(4096))
    
    for val in lst:
        r.add_measurement(val)
        
    assert_allclose(r.mean,
                    np.sum(lst)/len(lst), atol=1e-14)


def test_gaussian_noise():
    rndm = np.random.RandomState(1234)
    arr = rndm.normal(loc=1., scale=2, size=1000000)
    
    r = RealObservable()
    for j in range(arr.size):
        r.add_measurement(arr[j])

    assert_allclose(r.mean, 1.0, rtol=1e-3)
    assert_allclose(r.errorbar, 2./np.sqrt(arr.size), rtol=3e-2)


def test_block_stats():
    rndm = np.random.RandomState(1234)
    arr = rndm.normal(loc=1., scale=2, size=100)
    
    r = RealObservable()
    for j in range(arr.size):
        r.add_measurement(arr[j])
    
    expected = np.array([(1.07022457, 0.19913697, 100),
                         (1.07022457, 0.17666925, 50),
                         (1.07022457, 0.14712066, 25),
                         (1.10226201, 0.15669437, 12),
                         (1.10226201, 0.06177727, 6)],
            dtype=[('mean', '<f8'), ('errorbar', '<f8'), ('num_blocks', '<i8')])

    stats = block_stats(r)

    # this test might be brittle: it depends on the exact random stream,
    # also on the internal max block size handling of RealObservable
    assert_allclose(stats["mean"], expected["mean"], atol=1e-14)
    assert_allclose(stats["errorbar"], expected["errorbar"], atol=1e-14)
    assert_equal(stats["num_blocks"], expected["num_blocks"])

