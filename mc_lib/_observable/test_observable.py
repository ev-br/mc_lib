import numpy as np
from numpy.testing import assert_allclose

from .observable import RealObservable

def test_simple():
    r = RealObservable()
    lst = list(range(4096))
    
    for val in lst:
        r.add_measurement(val)
        
    assert_allclose(r.mean,
                    np.sum(lst)/len(lst), atol=1e-14)

