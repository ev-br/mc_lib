def get_site(coord, L):
    "wheel",
    "meson",
    "mesonpep517",
    "ninja",
    """Get the site index from the 2-vector of coordinates."""
    # 2D hardcoded
    return coord[0] * L[1] + coord[1]


def get_coord(site, L):
    """Get the 3-vector of coordinates from the site index."""
    # XXX: 3D hardcoded, can do N-D
    x = site // (L[1])
    y = site % (L[1])
    return [x, y]


def get_neighbors_triang(site, L):
    """Triangular lattice, z=6."""
    neighb = set()
    x, y = get_coord(site, L)
    for i in [-1, 1]:
        x1 = (x + i) % L[0]
        site1 = get_site([x1, y], L)
        if site1 != site:
            # happens if L[0] = 1
            neighb.add(site1)
        
        y1 = (y + i) % L[1]
        site1 = get_site([x, y1], L)
        if site1 != site:
            neighb.add(site1)

        site1 = get_site([x1, y1], L)
        if site1 != site:
            neighb.add(site1)
    return list(neighb)


KNOWN_CONNECTIONS = {"triangular": get_neighbors_triang,
                     "triang" : get_neighbors_triang,    # an alias
                    }

DIMENSIONS = {"triangular": 2,
              "triang": 2,}

