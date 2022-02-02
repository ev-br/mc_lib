import operator
import numpy as np

from . import _cubic
from . import _triang
from . import _square
    
known_connections = {}
known_connections.update(_cubic.KNOWN_CONNECTIONS)
known_connections.update(_triang.KNOWN_CONNECTIONS)
known_connections.update(_square.KNOWN_CONNECTIONS)

known_dimensions = {}
known_dimensions.update(_cubic.DIMENSIONS)
known_dimensions.update(_triang.DIMENSIONS)
known_dimensions.update(_square.DIMENSIONS)


def get_neighbors_selector(kind):
    """Select a kind of connector"""
    try:
        return known_connections[kind]
    except KeyError:
        raise ValueError("Unknown kind %s" % kind)


def dimension(kind):
    """Select a dimension of a lattice."""
    try:
        return known_dimensions[kind]
    except KeyError:
        raise ValueError("ndims: Unknown kind %s" % kind)


def tabulate_neighbors(L, kind):
    r"""Tabulate the root-2 neighbors on the 3D cubic lattice with PBC.

    Parameters
    ----------
    L : int or length-3 array
        the lattice is L \times L \times L if L is a scalar,
        otherwise L[0]*L[1]*L[2]
    kind : callable or str
        ``kind(site, L)`` returns a list of neighbors of ``site``.

    Returns
    -------
    neighbors : array, shape(Nsite, NUM_NEIGHB + 1)

    Notes
    -----
    
    The sites of the lattice are indexed by a flat index,
    ``site = 0, 1, ..., Nsite-1``, where ``Nsite = L**3``.
    
    The ``neighbors`` array is: ``nk = neighbors[site, 0]`` is the number of neighbors
    of ``site`` and ``neighbors[site, 1:nk+1]`` are the neighbor sites.

    E.g., for the following 2D arrangement, the format is

          4
          |
      2 - 1 - 3
          |
          5

    ``neighbors[1, 0] == 4`` since there are four neighbors, and 
    ``neighbors[1, 1:5] == [2, 3, 4, 5]`` (the order not guaranteed).
    """
    try:
        L = operator.index(L)
        L = (L,) * dimension(kind)
    except:
        # TODO: allow 2D w/ kind='sc' and L=(3, 4)
        assert len(L) == dimension(kind)


    if callable(kind):
        get_neighbors = kind
    else:
        get_neighbors = get_neighbors_selector(kind)

    # total # of sites
    Nsite = 1
    for ll in L:
        Nsite *= ll

    # construct lists of neighbors for each site
    n_lst = []
    for site in range(Nsite):
        lst = get_neighbors(site, L)
        n_lst.append( [len(lst)] + lst )

    # max coordination number        
    max_num_neighb = max([e[0] for e in n_lst])
    
    # copy neighbors lists into a numpy array
    neighb = np.empty((Nsite, max_num_neighb + 1), dtype=int)
    for site in range(Nsite):
        neighb[site, :max_num_neighb+1] = n_lst[site]
    
    return neighb
