# Assorted small utilities for MC simulations with Cython.

[![pip(Linux&MacOS)](https://github.com/ev-br/mc_lib/actions/workflows/pip_ubuntu_macos.yml/badge.svg)](https://github.com/ev-br/mc_lib/actions/workflows/pip_ubuntu_macos.yml/)
[![meson(Linux & MacOS)](https://github.com/ev-br/mc_lib/actions/workflows/dev_ubuntu_macos.yml/badge.svg)](https://github.com/ev-br/mc_lib/actions/workflows/dev_ubuntu_macos.yml/)
[![meson(Windows)](https://github.com/ev-br/mc_lib/actions/workflows/windows.yml/badge.svg)](https://github.com/ev-br/mc_lib/actions/workflows/windows.yml/)
[![license](http://img.shields.io/badge/license-BSD-blue.svg?style=flat)](https://github.com/ev-br/mc_lib/blob/master/LICENSE)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5169027.svg)](https://doi.org/10.5281/zenodo.5169027)


## Installation

There are several ways to install the library. They are all equivalent, and
only differ in a level of control over the process.


### A one-liner

It is easiest to install directly from github:

```
$ python -m pip install git+https://github.com/ev-br/mc_lib.git@master

```

Under the hood we use [`meson`](https://mesonbuild.com/) and PEP517 as a build
system, but this is well hidden and need not be a concern. 
Now test your fresh install:

```
$ pytest --pyargs mc_lib -v
```


### Clone and install

Alternatively, clone the repository from GitHub and run `pip` on the local clone:

```
$ git clone https://github.com/ev-br/mc_lib.git
$ cd mc_lib
$ python -m pip install .
```


### Manual build with `meson`

This is needed if you plan to develop the library. First, get the latest `meson`
snapshot (we hope this is temporary and we'll be able to use a stable version
once meson 0.60 is released) and other required packages:

```
$ python -m pip install git+https://github.com/mesonbuild/meson.git@master
$ python -m pip install -r requirements.txt
```

Then, clone the source repository

```
$ git clone https://github.com/ev-br/mc_lib.git
$ cd mc_lib
```
   
Meson uses a configure and a build stage. We configure it to use
`build/` for a working directory and place a local install into the
`installdir/` directory:

```
$ meson setup build --prefix=$PWD/installdir
$ meson install -C build
```

(During development, in some circumstances, you may need to to use
`setup` with a `--wipe` flag to fully rebuild package or `--reconfigure` to
update the current build. Normally, this should not be needed, and if it is,
it's a bug. Please report it by opening an issue at
https://github.com/ev-br/mc_lib/issues.)

Finally, make the `installdir/` visible to python:

```
$ export PYTHONPATH=$PWD/installdir/lib/python{Your python version}/site-packages
```

Now the install is usable and tests should pass:

```
$ pytest mc_lib -v --pyargs
```

See the `dev.sh` shell script, which does these steps in order.

# Usage 

```
>>> from mc_lib.lattice import get_neighbors    # for sc and other lattices
```

and

```
%% cython --cplus
from mc_lib cimport RealObservable          # for statistics
from mc_lib.rndm cimport RndmWrapper        # For rndm.uniform in Cython
```

See `examples/cy_ising.pyx` for a usage example.


### Compiling from Jupyter

You may need to tell Jupyter where to find the library. To do this,
run (in a python cell), `import mc_lib; print(mc_lib.get_include())`, and
paste the output into the `-I` parameter of the `%%cython` magic:

```
In [7]: %%cython --I<copy-paste the path here>
   ...: from mc_lib.rndm cimport RndmWrapper
   ...: cdef RndmWrapper rndm = RndmWrapper((123, 0))
   ...: print(rndm.uniform())
```


# Notes

- Generally you will need `cython`, `numpy >= 1.19.5`
(because `RndmWrapper` wraps `np.random.Generator`) and `pytest` for testing.

- On Apple M1, the numpy requirement is `numpy >= 1.21.0` (which is the first
numpy version to support this hardware). 

- Since `RealObservable` uses C++, you'll need to compile your client Cython
code to C++ not C. E.g. in a Jupyter notebook, use
```
%%cython --cplus
from mc_lib cimport RealObservable
```

- On MacOS you may need to tell cython to use C++11, via the `-std=C++11` switch
or some such. This is due to the fact that by default, xcode selects an older
C++ dialect. As an example of using this in a Jupyter notebook, see
`examples/frustrated_2d_ising.ipynb`. For command-line usage, see `meson.build`
files in the main `mc_lib` repository.


# Troubleshooting

Here are several common problems:

- Compilation prints something about `numpy deprecated API`. This is harmless, safe
to ignore.

- Compilations warns out `tp_print` being deprecated on python 3.9 and above. This is
harmless, safe to ignore.

- Compilation fails with errors suggesting that `std::tie` should be `std::time`.
You are probably on a MacOS, and your C++ compiler does not use C++11. Add to your
compile step a C++ flag `-std=C++11` or `-std=C++17`.

- Trying to compile Cython code fails because it does not find
`numpy/random/bitgen.h` header. Either your numpy is too old (you need at least
`1.19.5`), or you need to add a `.get_include()` path to the cython compile step.

If you face an issue with either building or using the library, do not hesitate
to open an issue at our tracker,
[https://github.com/ev-br/mc_lib/issues](https://github.com/ev-br/mc_lib/issues).
