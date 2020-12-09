# Test conversion sites <--> coords
import numpy as np
from numpy.testing import assert_equal

import pytest

#from cython_template.lattices import get_neighbors
#from .lattices._cubic import get_coord, get_site
from mc_lib.lattices import tabulate_neighbors


@pytest.mark.xfail
def test_roundtrip():
    L = (5, 5, 5)
    for site in range(L[0] * L[1] * L[2]):
        xyz = get_coord(site, L)
        site1 = get_site(xyz, L)
        #print(site, xyz, site1)
        assert_equal(site, site1)


@pytest.mark.xfail
def test_coords():
    lst = []
    for nghb in get_neighbors(get_site((2, 2, 2), L), L):
        lst.append("%s %s --" % (nghb, get_coord(nghb, L)))
        #print(nghb, get_coord(nghb, L), end=" -- ")
    result = "".join(lst)

    expected = " 31 [1, 1, 1] -- 32 [1, 1, 2] -- 33 [1, 1, 3] -- 36 [1, 2, 1] -- 37 [1, 2, 2] -- 38 [1, 2, 3] -- 41 [1, 3, 1] -- 42 [1, 3, 2] -- 43 [1, 3, 3] -- 56 [2, 1, 1] -- 57 [2, 1, 2] -- 58 [2, 1, 3] -- 61 [2, 2, 1] -- 62 [2, 2, 2] -- 63 [2, 2, 3] -- 66 [2, 3, 1] -- 67 [2, 3, 2] -- 68 [2, 3, 3] -- 81 [3, 1, 1] -- 82 [3, 1, 2] -- 83 [3, 1, 3] -- 86 [3, 2, 1] -- 87 [3, 2, 2] -- 88 [3, 2, 3] -- 91 [3, 3, 1] -- 92 [3, 3, 2] -- 93 [3, 3, 3] -- "
    assert result == expected


def test_simple_cubic_2D():
   nn = tabulate_neighbors((4, 4, 1), kind='sc')
   assert_equal(nn,
                np.array([[ 4,  1,  3, 12,  4],
                          [ 4,  0,  5,  2, 13],
                          [ 4,  1,  3, 14,  6],
                          [ 4,  0,  2,  7, 15],
                          [ 4,  0,  8,  5,  7],
                          [ 4,  1,  4,  9,  6],
                          [ 4,  2, 10,  5,  7],
                          [ 4, 11,  3,  4,  6],
                          [ 4,  9, 11,  4, 12],
                          [ 4,  8, 13, 10,  5],
                          [ 4,  9, 11,  6, 14],
                          [ 4,  8, 10, 15,  7],
                          [ 4,  8,  0, 13, 15],
                          [ 4,  9, 12,  1, 14],
                          [ 4, 10,  2, 13, 15],
                          [ 4,  3, 11, 12, 14]])
   )
   
   nn1 = tabulate_neighbors((1, 4, 4), kind='sc')
   assert_equal(nn, nn1)
