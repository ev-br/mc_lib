
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


def get_neighbors_root_two(site, L):
    """Chess king moves in 3D."""
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


def get_neighbors_sc(site, L):
    """Simple cubic lattice, z=6."""
    neighb = set()
    x, y, z = get_coord(site, L)
    for i in [-1, 1]:
        x1 = (x + i) % L[0]
        site1 = get_site([x1, y, z], L)
        if site1 != site:
            # happens if L[0] = 1
            neighb.add(site1)
        
        y1 = (y + i) % L[1]
        site1 = get_site([x, y1, z], L)
        if site1 != site:
            neighb.add(site1)

        z1 = (z + i) % L[2]
        site1 = get_site([x, y, z1], L)
        if site1 != site:
            neighb.add(site1)
    return list(neighb)


KNOWN_CONNECTIONS = {"root-two": get_neighbors_root_two,
                     "sc" : get_neighbors_sc,}

