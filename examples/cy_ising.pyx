#cython: language_level=3

import numpy as np
from mc_lib1111 import tabulate_neighbors

cimport cython
from libc.math cimport exp, tanh

from mc_lib.rndm cimport RndmWrapper
from mc_lib.observable cimport RealObservable

cdef void init_spins(long[::1] spins,
                     RndmWrapper rndm):
    # initial configuration
    for j in range(spins.shape[0]):
        spins[j] = 1 if rndm.uniform() > 0.5 else -1


@cython.boundscheck(False)
@cython.wraparound(False)
cdef double energy(long[::1] spins, 
                   long[:, ::1] neighbors,
                   double J=1.0):
    """Ising model energy of a spin state.
    """
    cdef:
        double ene = 0.0
        Py_ssize_t site, site1, num_neighb

    for site in range(spins.shape[0]):
        num_neighb = neighbors[site, 0]
        for j in range(1, num_neighb+1):
            site1 = neighbors[site, j]
            ene += -J * spins[site] * spins[site1]
    
    # each bond is counted twice, hence divide by two
    return ene / 2.0


    
# A single metropolis update
@cython.boundscheck(False)
@cython.wraparound(False)
cdef void flip_spin(long[::1] spins, 
                    const long[:, ::1] neighbors,
                    double beta,
                    RndmWrapper rndm):
    cdef:
        Py_ssize_t site = int(spins.shape[0] * rndm.uniform())
        Py_ssize_t site1

    # the update is s -> -s, hence
    # ratio = new/old = exp(+J/T(-s)(prev + next)) / exp(+J/T(s)(prev+next))
    #                 = exp(-2J/T s(prev + next))
    
    cdef long num_neighb = neighbors[site, 0]
    cdef long summ = 0 
    for j in range(1, num_neighb + 1):
        site1 = neighbors[site, j]
        summ += spins[site1]
   
    cdef double ratio = exp(-2.0*beta * summ * spins[site])
    
    if rndm.uniform() > ratio:
        return

    # accepted
    spins[site] = -spins[site]
    

##########################################################################3

def simulate(Py_ssize_t L,
             double beta,
             Py_ssize_t num_sweeps):

    # set up the lattice
    cdef:
        long[:, ::1] neighbors = tabulate_neighbors((L, 1, 1), kind='sc')    
        double T = 1./beta

    print(np.asarray(neighbors))
    print("beta = ", beta, "  T = ", 1./beta)


    # set up the simulation
    cdef RndmWrapper rndm = RndmWrapper((1234, 0))

    cdef:
        int num_therm = int(1e4)
        int num_prnt = 10000
        int steps_per_sweep = 1000
        int step = 0, sweep = 0
        int i, j
        double av_en = 0., Z = 0.
        RealObservable ene = RealObservable()

    # initialize spins
    cdef long[::1] spins =  np.empty(L, dtype=int)
    init_spins(spins, rndm)
    print("initial config: ", np.asarray(spins))

    # thermalization
    for sweep in range(num_therm):
        for i in range(steps_per_sweep):
            step += 1
            flip_spin(spins, neighbors, beta, rndm)

    # main MC loop
    for sweep in range(num_sweeps):
        for i in range(steps_per_sweep):
            step += 1
            flip_spin(spins, neighbors, beta, rndm)
        
        # measurement
        av_en += energy(spins, neighbors)
        Z += 1
        ene.add_measurement(energy(spins, neighbors))
        
        # printout
        if sweep % num_prnt == 0:
            print("\n----- sweep = ", sweep, "spins = ", np.asarray(spins), "beta = ", beta)
            print("  ene = ", av_en / Z, " (naive)")
            print("      = ", ene.mean, '+/-', ene.errorbar, ene.is_converged)
            th = tanh(beta)
            print("      = ", -L * th * (1 + th**(L-2)) / (1 + th**L), " (exact)" )
            # uncomment to check the block stats
            #ene.pretty_print_block_stats()

    # check the the final result agress w/ exact
    th = tanh(beta)
    ground_truth = -L * th * (1 + th**(L-2)) / (1 + th**L)
    if np.abs(ground_truth - ene.mean) > ene.errorbar:
        raise RuntimeError("did not converge")


if __name__ == "__main__":
    L = 4
    beta = 1.25
    simulate(L, beta, num_sweeps=20)
