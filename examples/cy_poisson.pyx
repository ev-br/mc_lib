import numpy as np
cimport numpy as np
from mc_lib.rndm cimport RndmWrapper
from numpy.random.c_distributions cimport random_poisson


def generate(n_samples, lam=2):
    """Generate n_samples from the Poisson distribution with given lambda.
    """
    cdef RndmWrapper rndm = RndmWrapper((1234, 0))
    cdef long[::1] vals = np.empty((n_samples,), dtype=int)

    for j in range(vals.shape[0]):
        vals[j] = random_poisson(rndm.rng, lam=2)
        
    vals_arr = np.array(vals)

    return vals_arr



def test():
    """A quick check that a sample distribution looks Poissonian indeed."""
    lam = 2
    vals = generate(10000, lam=lam)
    count = np.bincount(vals)

    from math import exp, factorial
    poiss = [exp(-lam) * lam**k / factorial(k) for k in range(count.size)]

    from numpy.testing import assert_allclose
    assert_allclose(count / count.sum(),
                    poiss, atol=5e-3)

