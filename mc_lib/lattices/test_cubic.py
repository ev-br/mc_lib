# Test conversion sites <--> coords

from numpy.testing import assert_equal

from make_cubic import get_neighbors, get_coord, get_site


def test_roundtrip():
    L = (5, 5, 5)
    for site in range(L[0] * L[1] * L[2]):
        xyz = get_coord(site, L)
        site1 = get_site(xyz, L)
        #print(site, xyz, site1)
        assert_equal(site, site1)


def test_coords():
    lst = []
    for nghb in get_neighbors(get_site((2, 2, 2), L), L):
        lst.append("%s %s --" % (nghb, get_coord(nghb, L)))
        #print(nghb, get_coord(nghb, L), end=" -- ")
    result = "".join(lst)

    expected = " 31 [1, 1, 1] -- 32 [1, 1, 2] -- 33 [1, 1, 3] -- 36 [1, 2, 1] -- 37 [1, 2, 2] -- 38 [1, 2, 3] -- 41 [1, 3, 1] -- 42 [1, 3, 2] -- 43 [1, 3, 3] -- 56 [2, 1, 1] -- 57 [2, 1, 2] -- 58 [2, 1, 3] -- 61 [2, 2, 1] -- 62 [2, 2, 2] -- 63 [2, 2, 3] -- 66 [2, 3, 1] -- 67 [2, 3, 2] -- 68 [2, 3, 3] -- 81 [3, 1, 1] -- 82 [3, 1, 2] -- 83 [3, 1, 3] -- 86 [3, 2, 1] -- 87 [3, 2, 2] -- 88 [3, 2, 3] -- 91 [3, 3, 1] -- 92 [3, 3, 2] -- 93 [3, 3, 3] -- "
    assert result == expected

