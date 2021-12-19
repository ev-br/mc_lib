# Several simple examples of using `mc_lib` primitives.

1. A simple 1D Ising simulation with local Metropolis updates (`cy_ising.pyx`)

2. A frustrated 2D Ising on a triangular lattice (`frustrated_2d_ising.ipynb`)

3. An example of generating a non-uniform random variable with `RndmWrapper` instance. 

4. An example of a 2D Ising simulation using Wolff cluster updates (`cy_ising_cluster.pyx`)

There are several ways of building the Cython extensions: basically, you can choose between
`setuptools` and `meson`.


### Build with `setuptools`
1.  1D Ising

> python setup.py build_ext -i
> 
> python -c'from cy_ising import simulate; simulate(4, 1.25, 100000)'

2.  Frustrated 2D Ising

> pip install jupyter 
> 
> ipython -c"%run frustrated_2d_ising.ipynb"

### Build with `meson`
1.  1D Ising

> meson setup builddir1 --prefix=$PWD/installdir1
> 
> meson install -C builddir1

It will create meson build directory and installdir1. 
Example will be in `$PWD/installdir1/lib/python{your python vesion}/site-packages`
    
2.  Frustrated 2D Ising

> pip install jupyter 
> 
> ipython -c"%run frustrated_2d_ising.ipynb"


