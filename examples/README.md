# Several simple examples of using `mc_lib` primitives.

* 1D Ising model: 

  - the exact solution (`1DIsing.ipynb`)
  - simulation with local Metropolis updates (`cy_ising.pyx`)


* 2D Ising model:

  - frustrated 2D model on a triangular lattice (`frustrated_2d_ising.ipynb`), local updates
  - Wolff cluster simulations of the 2D model (`cy_ising_cluster.pyx`), and
    a comparison to an enumeration for a small lattice (`cluster_update_examples.ipynb`)
  - Wolff cluster simulation of the Ising model on a non-regular lattice
    (a SAW conformation) `cluster_update_on_conformation.ipynb`

* An example of generating a non-uniform random variable with `RndmWrapper` instance. 

-------------

To build Cython extensions, you can choose between `setuptools` and `meson`.


### Build with `setuptools`
1.  1D Ising

```shell
$ python setup.py build_ext -i
$ python -c'from cy_ising import simulate; simulate(4, 1.25, 100000)'
```

2.  Frustrated 2D Ising

```shell
$ pip install jupyter 
$ ipython -c"%run frustrated_2d_ising.ipynb"
```

### Build with `meson`

```shell
$ meson setup builddir --prefix=$PWD/installdir
$ meson install -C builddir
```

It will create meson build directory `builddir`, and place the build artifacts
into `$PWD/installdir/lib/python{your python vesion}/site-packages`.
To import them, you need to e.g. set the `PYTHONPATH` variable.


