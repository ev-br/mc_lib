#cython: language_level=3

import numpy as np
import copy
from mc_lib.lattices import tabulate_neighbors

cimport cython
from libc.math cimport exp, tanh
from libcpp.vector cimport vector
from libcpp.set cimport set
from cython.operator cimport dereference as deref, preincrement as inc
from libcpp cimport bool

from mc_lib.rndm cimport RndmWrapper
from mc_lib.observable cimport RealObservable

cdef long[::1] init_spins(int L,
                     RndmWrapper rndm):
    ''' 
    initial configuration
    L: number of spins in configuration
    '''
    cdef long[::1] spins =  np.empty(L, dtype=int)
    for j in range(L):
        spins[j] = 1 if rndm.uniform() > 0.5 else -1
    
    return spins

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

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double magnetization(long[::1] spins):
    cdef:
        double mag = 0.0
        Py_ssize_t site
    
    for site in range(spins.shape[0]):
        mag += spins[site]

    return mag
    
# Pre calculating exp(-2.0*beta * summ * spins[site])
@cython.boundscheck(False)
@cython.wraparound(False)
cdef void tabulate_ratios(double[::1] ratios,
                      double beta,
                      int nDim):
    cdef:
        int summ
    for summ in range(-nDim, nDim+1):
        ratios[summ + nDim] = exp(-2.0*beta * summ)
        
        
# A single metropolis update
@cython.boundscheck(False)
@cython.wraparound(False)
cdef void flip_spin(long[::1] spins, 
                    const long[:, ::1] neighbors,
                    double beta,
                    const double[::1] ratios,
                    RndmWrapper rndm,
                    int nDim):
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
   
    cdef double ratio = ratios[nDim + summ * spins[site]]
    
    if rndm.uniform() > ratio:
        return

    # accepted
    spins[site] = -spins[site]
    

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void cluster_update(long[::1] spins,
                         const long[:, ::1] neighbors,
                         double p,
                         RndmWrapper rndm):
    '''
    An implementation of the Wolff algorithm
    as presented in Statistical Mechanics Algorithms and Computations
    by Werner Krauth
    '''
    
    cdef:
        vector[int] pocket
        set[int] cluster
        int cur, cur_id
        int nghbr
        int i, j
        bool in_cluster
        set[int].iterator it
        
    cur = int(spins.shape[0] * rndm.uniform())
    pocket.push_back(cur)
    cluster.insert(cur)
    
    while not pocket.empty():
        cur_id = int(pocket.size() * rndm.uniform())
        cur = pocket[cur_id]
        for i in range(1, neighbors[cur, 0] + 1):
            nghbr = neighbors[cur, i]
            if spins[cur] != spins[nghbr]:
                continue
            
            in_cluster = False
            if(cluster.find(nghbr) != cluster.end()):
                in_cluster = True
                
            if not in_cluster and rndm.uniform() < p:
                cluster.insert(nghbr)
                pocket.push_back(nghbr)
                
        pocket.erase(pocket.begin() + cur_id)
        
    it = cluster.begin()
    while it != cluster.end():
        spins[deref(it)] *= -1
        inc(it)

##########################################################################

def simulate(long[:, ::1] neighbors,
             double beta,
             Py_ssize_t num_sweeps,
             int num_therm=100000,
             bint verbose=0,
             int sampl_frequency=10000,
             double cluster_upd_prob=1.0,
             int do_intermediate_measure=0,
             int upd_per_sweep=1):
    '''
    neighbors - table of neighbor indexes,
    where n = neighbors[i, 0] is number of neigbours of spin and
    neighbours[i, 1:n+1] is the list of neighbors of spin
    
    beta - invere temperature
    
    num_sweeps - number of sweeps for the measurement
    
    num_therm - number of thermolization sweeps
    
    verbose:
        0 - print nothing
        1 - print information about conformation, measures during execution,
        and final results
        
    sampl_frequency - determines how often intermediate measures will be takeen
    
    cluster_upd_prob - probability of using claster update algorythm insted of 
    one-spin update for each step
        1.0 - only cluster update will be used
        0.0 - only one-spin update will be used
        
    do_intermediate_measure - 1 means function will return an array of enery
    values measured during the calculation
    
    upd_per_sweep - number of cluster updates per 
    
    num_therm - number of thermalization sweeps
    
    sampl_frequency - determines how often intermediate values will be taken
	
    cluster_upd_prob - probability of using claster update algorythm insted
    of one-spin update for each step
    
    do_intermediate_measure - 1 means function will return an array of enery
    values measured during the calculation
    
    upd_per_sweep - number of cluster updates per sweep
    '''

    # set up the simulation
    cdef RndmWrapper rndm = RndmWrapper((1234, 0))

    cdef:
        double T = 1./beta
        int L = neighbors.shape[0]
        int steps_per_sweep = 10000
        int step = 0, sweep = 0
        int i, j
        double av_en = 0., Z = 0., mag_sq = 0.
        RealObservable long_time_ene = RealObservable()
        RealObservable ene = RealObservable()
        RealObservable mag2 = RealObservable()
        RealObservable mag4 = RealObservable()
        list ene_arr = []
        double choose_update
        double accept_ratio = 1.0 - exp(-2.0 * beta)
        int nDim = max(neighbors[:, 0])
        
        
    if verbose == 1:
        print("beta = ", beta, "  T = ", 1./beta)
        print("Conformation size =", L)

    cdef double[::1] ratios = np.empty(nDim*2+1 , dtype=float)
    tabulate_ratios(ratios, beta, nDim)
    
    # initialize spins
    cdef long[::1] spins = init_spins(L, rndm)

    # thermalization
    for sweep in range(num_therm):
        choose_update = rndm.uniform()
        if choose_update < cluster_upd_prob:
            for i in range(upd_per_sweep):
                cluster_update(spins, neighbors, accept_ratio, rndm)
        else:
            for i in range(steps_per_sweep):
                step += 1
                flip_spin(spins, neighbors, beta, ratios, rndm, nDim)

    # main MC loop
    for sweep in range(num_sweeps):
        choose_update = rndm.uniform()
        if choose_update < cluster_upd_prob:
            for i in range(upd_per_sweep):
                cluster_update(spins, neighbors, accept_ratio, rndm)
        else:
            for i in range(steps_per_sweep):
                step += 1
                flip_spin(spins, neighbors, beta, ratios, rndm, nDim)
        
        # measurement
        av_en += energy(spins, neighbors) / L
        mag_sq = (magnetization(spins)/L) ** 2
        Z += 1
        ene.add_measurement(energy(spins, neighbors) / L)
        mag2.add_measurement(mag_sq)
        mag4.add_measurement(mag_sq**2)
        
        # energy samples
        if do_intermediate_measure == 1 and sweep % sampl_frequency == 0:
            ene_arr.append(copy.deepcopy(ene))

        # printout
        if verbose == 1:
            if sweep % sampl_frequency == 0:
                print("\n----- sweep = ", sweep, "beta = ", beta)
                print("  ene = ", av_en / Z, " (naive)")
                print("      = ", ene.mean, '+/-', ene.errorbar)
    
                print("  mag^2 = ", mag2.mean, '+/-', mag2.errorbar)
                print("  mag^4 = ", mag4.mean, '+/-', mag4.errorbar)
            # uncomment to check the block stats
            #ene.pretty_print_block_stats()
    
    if verbose == 1:
        print("\nFinal:")
        print("  ene = ", av_en / Z, " (naive)")
        print("  ene = ", ene.mean, '+/-', ene.errorbar)
    
        print("  mag^2 = ", mag2.mean, '+/-', mag2.errorbar)
        print("  mag^4 = ", mag4.mean, '+/-', mag4.errorbar)
        
    return ene, mag2, mag4, np.array(ene_arr, dtype=RealObservable)


