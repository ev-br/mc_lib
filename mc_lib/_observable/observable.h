#ifndef __MC_SCALAROBSERVABLE__
#define __MC_SCALAROBSERVABLE__

#include<iostream>
#include<iomanip>
#include<cassert>
#include<vector>
#include<utility>
#include<tuple>
#include<algorithm>
#include<cmath>

/***************************************************************************
 * A bare-bones MC observable with error estimation with binning analysis. *
 *                                                                         *
 * A poor man's replacement for alps::alea observables.                    *
 ***************************************************************************/

namespace mc_stats {

// forward declarations
namespace detail {
    const size_t N_B_MAX = 1000;
    template<typename T> void collate(std::vector<T>& arr);
    template<typename T> std::pair<T, T> bSTAT(const std::vector<T>& blocks);
    template<typename T> std::tuple< std::vector<T>, std::vector<T>, std::vector<T> > mrg(const std::vector<T>&);
    template<typename T> std::tuple<T, T, bool> block_stats(const std::vector<T>&, const std::vector<T>);
}


template<typename T>
class ScalarObservable
{
public:
    ScalarObservable<T>(size_t n_b_max=detail::N_B_MAX)
                          : _value(0),
                            _i_b(0),
                            _Z_b(1),
                            _n_b_max(n_b_max) {
        _blocks.reserve(_n_b_max);
    }
    void from_blocks(const std::vector<T>& blocks, size_t Z_b);

    void operator<<(T x);    // add a measurement
    T mean() const;
    T errorbar() const;
    bool converged() const;

    std::vector<T> blocks() const { return _blocks;}
    double Z_b() const { return _Z_b;}
    size_t num_blocks() const { return _blocks.size(); }

public:
    // Debug: Analyze the blocked stats etc
    T block_mean() const { return detail::bSTAT<T>(_blocks).first; };
    T block_errorbar() const { return detail::bSTAT<T>(_blocks).second; };
    T get_current_value() const {return _value;}

protected:
    std::vector<T> _blocks;       // filled blocks

    T _value;      // next, 'open', block accumulator
    size_t _i_b;     // # of measurements in the 'open' block
    size_t _Z_b;     // # of measurements in closed blocks
    size_t _n_b_max; // max # of filled blocks

};


/***************************************
 * Add a measurement to the observable *
 ***************************************/
template<typename T>
void
ScalarObservable<T>::operator<<(T x) {
    _value += x;
    _i_b += 1;

    // is the current block full? Wrap it up.
    if (_i_b == _Z_b) {
        _blocks.push_back(_value/_Z_b);
        _i_b = 0;
        _value = 0;

        // collate blocks: 1000 -> 500 twice larger blocks
        if (_blocks.size() == _n_b_max) {
            // XXX: check overflow of Z_b
            detail::collate(_blocks);
            _Z_b *= 2;
        }
    }
}


// XXX: avoid recalculations, store mutable tuple(av, err, conv) instead? 
template<typename T>
T
ScalarObservable<T>::mean() const {
    T av, err;
    bool conv;
    std::vector<T> v_av, v_err, v_size;
    std::tie(v_av, v_err, v_size) = detail::mrg(_blocks);
    std::tie(av, err, conv) = detail::block_stats(v_av, v_err);
    return av;
}


template<typename T>
T
ScalarObservable<T>::errorbar() const {
    T av, err;
    bool conv;
    std::vector<T> v_av, v_err, v_size;
    std::tie(v_av, v_err, v_size) = detail::mrg(_blocks);
    std::tie(av, err, conv) = detail::block_stats(v_av, v_err);
    return err;
}


template<typename T>
bool
ScalarObservable<T>::converged() const {
    T av, err;
    bool conv;
    std::vector<T> v_av, v_err, v_size;
    std::tie(v_av, v_err, v_size) = detail::mrg(_blocks);
    std::tie(av, err, conv) = detail::block_stats(v_av, v_err);
    return conv;
}


template<typename T>
void
ScalarObservable<T>::from_blocks(const std::vector<T>& blocks, size_t Z_b)
{
    this->_blocks.clear();
    std::copy(blocks.begin(), blocks.end(), std::back_inserter(this->_blocks));
    this->_Z_b = Z_b;
    this->_value = 0;
    this->_i_b = 0;
}


template<typename T>
void
pretty_print_block_stats(const ScalarObservable<T>& obs) {
    std::cout <<"--------\n";
    std::cout <<"value: " << obs.mean() << " +/- " << obs.errorbar() << "  ";
    std::cout << std::boolalpha << "\t converged: " << obs.converged() << "\n";
    std::cout << "Z = "<< obs.Z_b()*obs.num_blocks()<<"\n";

    std::vector<T> v_av, v_err, v_size;
    std::tie(v_av, v_err, v_size) = detail::mrg(obs.blocks());

    std::cout << std::setprecision(6);
    for(size_t j=0; j<v_err.size(); j++) {
        std::cout << "\t" << v_av[j] << "  +/- " << v_err[j] << "\t(" << v_size[j] << ")\n";
    }
}


// Trampoline subroutine : Cython does not understand std::tuple.
template<typename T>
void
trampoline_mrg(const ScalarObservable<T>& obs,
               std::vector<T>& v_av,
               std::vector<T>& v_err,
               std::vector<T>& v_size)
{
    std::tie(v_av, v_err, v_size) = detail::mrg(obs.blocks());
}


namespace detail {

/********************************************************
 * Merge blocks in-place: 100 -> 50 twice larger blocks *
 ********************************************************/
template<typename T> 
void
collate(std::vector<T>& arr) {
    size_t n2 = floor(arr.size() / 2);
    for(size_t j = 0; j < n2; j++) {
        arr[j] = 0.5 * (arr[2*j] + arr[2*j+1]);
    }
    arr.resize(n2);
}


/****************************************
 * Block statistics at fixed block size *
 ****************************************/
template<typename T>
std::pair<T, T>
bSTAT(const std::vector<T>& blocks) {
    T av = 0, av2 = 0;
    size_t n_b = blocks.size();
    for(size_t j = 0; j < n_b; j++) {
        av += blocks[j] / n_b;
        av2 += blocks[j] * blocks[j] / n_b;
    }
    T dif = av2 - av*av;
    if (dif < 0) {dif = 0.;}
    T err = sqrt(dif) / sqrt(1.0*n_b);
    return std::make_pair(av, err);
}


/******************************************
 * Merge blocks, analyze block statistics *
 ******************************************/
template<typename T>
std::tuple< std::vector<T>, std::vector<T>, std::vector<T> >
mrg(const std::vector<T>& blocks) {
    std::vector<T> arr;
    std::copy(blocks.begin(), blocks.end(), std::back_inserter(arr));

    std::vector<T> v_av, v_err, v_size;

    do {

        std::pair<T, T> av_err = bSTAT(arr);
        v_av.push_back(av_err.first);
        v_err.push_back(av_err.second);
        v_size.push_back(arr.size());

        collate(arr);

    } while(arr.size() > 4);

    return std::tie(v_av, v_err, v_size);
}


template<typename T>
std::tuple<T, T, bool>
block_stats(const std::vector<T>& v_av, const std::vector<T> v_err) {

    // block mean is the second-to last entry
    T av = v_av.size() > 2 ? v_av[v_av.size() -2]
                           : v_av[0];
    T err = *std::max_element(v_err.begin(), v_err.end());

    // TODO: convergence check
    bool conv = false;

    return std::tie(av, err, conv);
}


}  // namespace detail

}; // namespace mc_stats

#endif
