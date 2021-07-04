#cython: language_level=3

import numpy as np
import copy
from mc_lib.lattices import tabulate_neighbors

cimport cython
from libc.math cimport exp, tanh
from libcpp.vector cimport vector
from libcpp cimport bool

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

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double magnetization(long[::1] spins):
    cdef:
        double mag = 0.0
        Py_ssize_t site
    
    for site in range(spins.shape[0]):
        mag += spins[site]

    return mag
    
# Pre culculating exp(-2.0*beta * summ * spins[site]), where summ * spins[site] in [-4, 4]
@cython.boundscheck(False)
@cython.wraparound(False)
cdef void culc_ratios(double[::1] ratios,
                      double beta):
    for summ in range(-4, 5):
        ratios[summ + 4] = exp(-2.0*beta * summ)
        
        
# A single metropolis update
@cython.boundscheck(False)
@cython.wraparound(False)
cdef void flip_spin(long[::1] spins, 
                    const long[:, ::1] neighbors,
                    double beta,
                    const double[::1] ratios,
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
   
    cdef double ratio = ratios[4 + summ * spins[site]]
    
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
    cdef:
        vector[int] pocket
        vector[int] cluster
        int cur, cur_id
        int nghbr
        int i, j
        bool in_cluster
        
    cur = int(spins.shape[0] * rndm.uniform())
    pocket.push_back(cur)
    cluster.push_back(cur)
    
    while not pocket.empty():
        cur_id = int(pocket.size() * rndm.uniform())
        cur = pocket[cur_id]
        for i in range(1, neighbors[cur, 0] + 1):
            nghbr = neighbors[cur, i]
            if spins[cur] != spins[nghbr]:
                continue
            
            in_cluster = False
            for j in range(cluster.size()):
                if cluster[j] == nghbr:
                    in_cluster = True
                    break
                
            if not in_cluster and rndm.uniform() < p:
                cluster.push_back(nghbr)
                pocket.push_back(nghbr)
                
        pocket.erase(pocket.begin() + cur_id)
        
    for i in range(cluster.size()):
        spins[cluster[i]] *= -1

##########################################################################3

def simulate(Py_ssize_t L,
             long[:, ::1] neighbors,
             double beta,
             Py_ssize_t num_sweeps,
             int num_therm = 100000,
             int to_print = 0,
             int sampl_frequency = 10000,
             double cluster_upd_prob = 1.0,
             int do_intermediate_measure = 0,
             int upd_per_sweep = 1):
    
    '''
    L - length of the conformation
    neighbors - table of neighbor indexes
    beta - invere temperature
    num_sweeps - number of sweeps for the measurement
    num_therm - number of thermolisation sweeps
    to_print :
        0 - intermediate values will not be printed 
        1 -intermediate values will be printed 
    
    '''
    
    
    # set up the lattice
    cdef:   
        double T = 1./beta

    # print(np.asarray(neighbors))
    print("beta = ", beta, "  T = ", 1./beta)


    # set up the simulation
    cdef RndmWrapper rndm = RndmWrapper((1234, 0))

    cdef:
        int num_prnt = 10000
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

    cdef double[::1] ratios = np.empty(9, dtype=float)
    culc_ratios(ratios, beta)
    
    # initialize spins
    cdef long[::1] spins =  np.empty(L, dtype=int)
    init_spins(spins, rndm)
    print("Conformation size =", L)
    # print("initial config: ", np.asarray(spins))

    # thermalization
    for sweep in range(num_therm):
        choose_update = rndm.uniform()
        if choose_update < cluster_upd_prob:
            for i in range(upd_per_sweep):
                cluster_update(spins, neighbors, accept_ratio, rndm)
        else:
            for i in range(steps_per_sweep):
                step += 1
                flip_spin(spins, neighbors, beta, ratios, rndm)

    # main MC loop
    for sweep in range(num_sweeps):
        choose_update = rndm.uniform()
        if choose_update < cluster_upd_prob:
            for i in range(upd_per_sweep):
                cluster_update(spins, neighbors, accept_ratio, rndm)
        else:
            for i in range(steps_per_sweep):
                step += 1
                flip_spin(spins, neighbors, beta, ratios, rndm)
        
        # measurement
        av_en += energy(spins, neighbors) / L
        mag_sq = (magnetization(spins) / L) ** 2
        Z += 1
        ene.add_measurement(energy(spins, neighbors) / L)
        mag2.add_measurement(mag_sq)
        mag4.add_measurement(mag_sq**2)
        
        # energy samples
        if do_intermediate_measure == 1 and sweep % sampl_frequency == 0:
            ene_arr.append(copy.deepcopy(ene))

        # printout
        if sweep % num_prnt == 0:
            if to_print == 1:
                print("\n----- sweep = ", sweep, "spins = ", np.asarray(spins), "beta = ", beta)
                print("  ene = ", av_en / Z, " (naive)")
                print("      = ", ene.mean, '+/-', ene.errorbar)
    
                print("  mag^2 = ", mag2.mean, '+/-', mag2.errorbar)
                print("  mag^4 = ", mag4.mean, '+/-', mag4.errorbar)
            # uncomment to check the block stats
            #ene.pretty_print_block_stats()
    
    print("\nFinal:")
    print("  ene = ", av_en / Z, " (naive)")
    print("  ene = ", ene.mean, '+/-', ene.errorbar)

    print("  mag^2 = ", mag2.mean, '+/-', mag2.errorbar)
    print("  mag^4 = ", mag4.mean, '+/-', mag4.errorbar)
        
    '''
    # energy measurment for converge test
    for sweep in range(num_sweeps * 10):
        for i in range(steps_per_sweep):
            step += 1
            flip_spin(spins, neighbors, beta, ratios, rndm)
        
        long_time_ene.add_measurement(energy(spins, neighbors))
    
    print("test ene = ", long_time_ene.mean, "+/-", long_time_ene.errorbar)
    
    # check the the final result converges
    if long_time_ene.mean + long_time_ene.errorbar > ene.mean + ene.errorbar or long_time_ene.mean - long_time_ene.errorbar < ene.mean - ene.errorbar :
        raise RuntimeError("did not converge")
        
    '''
    return ene, mag2, mag4, np.array(ene_arr, dtype=RealObservable)


