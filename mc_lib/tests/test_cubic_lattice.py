# Test conversion sites <--> coords
import numpy as np
from numpy.testing import assert_equal

import pytest

from mc_lib.lattices import tabulate_neighbors

from mc_lib.lattices._cubic import get_coord, get_site
from mc_lib.lattices._cubic import get_neighbors_sc
import mc_lib.lattices._triang as triang


def test_roundtrip():
    L = (5, 5, 5)
    for site in range(L[0] * L[1] * L[2]):
        xyz = get_coord(site, L)
        site1 = get_site(xyz, L)
        #print(site, xyz, site1)
        assert_equal(site, site1)


def test_coords():
    L = (4, 4, 4)
    site = get_site((2, 2, 2), L)
    neighb_sites = get_neighbors_sc(site, L)
    assert neighb_sites == [58, 38, 41, 43, 46, 26]

    coords = [tuple(get_coord(site1, L)) for site1 in neighb_sites]
    assert_equal(sorted(coords),
                 [(1, 2, 2), (2, 1, 2), (2, 2, 1),
                  (2, 2, 3), (2, 3, 2), (3, 2, 2)])


    site = get_site((3, 2, 2), L)
    neighb_sites = get_neighbors_sc(site, L)
    assert_equal(sorted(neighb_sites),
                 [10, 42, 54, 57, 59, 62])

    coords = [tuple(get_coord(site1, L)) for site1 in neighb_sites]
    assert_equal(sorted(coords),
                 [(0, 2, 2), (2, 2, 2), (3, 1, 2),
                 (3, 2, 1), (3, 2, 3), (3, 3, 2)])


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


def test_simple_cubic_1D():
   nn = tabulate_neighbors((4, 1, 1), kind='sc')
   assert_equal(nn,
                np.array([[ 2, 1, 3],
                          [ 2, 0, 2],
                          [ 2, 1, 3],
                          [ 2, 0, 2]])
   )
   
   nn1 = tabulate_neighbors((1, 1, 4), kind='sc')
   assert_equal(nn, nn1)


####################### Triangular lattice 2D ################

def test_triang_roundtrip():
    L = (3, 3)
    for site in range(L[0] * L[1]):
        xyz = triang.get_coord(site, L)
        site1 = triang.get_site(xyz, L)
        #print(site, xyz, site1)
        assert_equal(site, site1)


def test_triang_coords():
    L = (3, 3)
    coords = {0: (0, 0), 1: (0, 1), 2: (0, 2),
              3: (1, 0), 4: (1, 1), 5: (1, 2),
              6: (2, 0), 7: (2, 1), 8: (2, 2),
    }
    
    for site in coords:
        assert_equal(triang.get_coord(site, L),
                     coords[site])



def test_triang_2D():
    nn = tabulate_neighbors((3, 3), kind='triang')
    assert_equal(nn,
                 np.array([[6, 1, 2, 3, 4, 6, 8],  # site = 0
                           [6, 0, 2, 4, 5, 6, 7],  #        1
                           [6, 0, 1, 3, 5, 7, 8],  #        2
                           [6, 0, 2, 4, 5, 6, 7],  #        3
                           [6, 0, 1, 3, 5, 7, 8],  #        4
                           [6, 1, 2, 3, 4, 6, 8],  #        5
                           [6, 0, 1, 3, 5, 7, 8],  #        6
                           [6, 1, 2, 3, 4, 6, 8],  #        7
                           [6, 0, 2, 4, 5, 6, 7]]) #        8

    )
