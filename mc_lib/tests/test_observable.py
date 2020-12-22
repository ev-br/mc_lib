import numpy as np
from numpy.testing import assert_allclose

from mc_lib.observable import RealObservable

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

