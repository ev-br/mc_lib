import operator
import numpy as np

__all__ = ["tabulate_neighbors", "NUM_NEIGHB"]

NUM_NEIGHB = 27

def get_site(coord, L):
    """Get the site index from the 3-vector of coordinates."""
    # XXX: 3D hardcoded, can do N-D
    return coord[0] * L[1] * L[2] + coord[1] * L[2] + coord[2]


def get_coord(site, L):
    """Get the 3-vector of coordinates from the site index."""
    # XXX: 3D hardcoded, can do N-D
    x = site // (L[1]*L[2])
    yz = site % (L[1]*L[2])
    y = yz // L[2]
    z = yz % L[2]
    return [x, y, z]


def get_neighbors(site, L):
    neighb = set()
    x, y, z = get_coord(site, L)
    for i in [-1, 0, 1]:
        for j in [-1, 0, 1]:
            for k in [-1, 0, 1]:
                x1 = (x + i) % L[0]
                y1 = (y + j) % L[1]
                z1 = (z + k) % L[2]
                neighb.add(get_site([x1, y1, z1], L))

    return list(neighb)


def tabulate_neighbors(L):
    r"""Tabulate the root-2 neighbors on the 3D cubic lattice with PBC.

    Parameters
    ----------
    L : int or length-3 array
        the lattice is L \times L \times L if L is a scalar,
        otherwise L[0]*L[1]*L[2]

    Returns
    -------
    neighbors : array, shape(Nsite, NUM_NEIGHB + 1)

    Notes
    -----
    
    The sites of the lattice are indexed by a flat index,
    ``site = 0, 1, ..., Nsite-1``, where ``Nsite = L**3``.
    
    The ``neighbors`` array is: ``neighbors[site, 0]`` is the number of neighbors
    of ``site`` and ``neighbors[site, 1:]`` are the neighbor sites.

    E.g., for the following 2D arrangement, the format is

          4
          |
      2 - 1 - 3
          |
          5

    ``neighbors[1, 0] == 4`` since there are four neighbors, and 
    ``neighbors[1, 1:] == [2, 3, 4, 5]`` (the ordering of neighbors is not
     guaranteed).
    """
    try:
        L = operator.index(L)
        L = (L, L, L)
    except:
        assert len(L) == 3
        pass

    Nsite = L[0]*L[1]*L[2]
    neighb = np.empty((Nsite, NUM_NEIGHB+1), dtype=int)
    for site in range(Nsite):
        neighb[site, 0] = NUM_NEIGHB
        neighb[site, 1:] = get_neighbors(site, L)
    return neighb
