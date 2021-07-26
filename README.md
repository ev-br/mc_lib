# Assorted small utilities for MC simulations with Cython.

----------

## How to install (meson + PEP517)

```
    git remote add mc_lib_git https://github.com/ev-br/mc_lib
    git fetch mc_lib_git
    git checkout mc_lib_git/master
```
```
    pip install .
```

----------
## How to build (meson)
Get the latest meson
```pip install git+https://github.com/mesonbuild/meson.git@master```
```
    git remote add mc_lib_git https://github.com/ev-br/mc_lib
    git fetch mc_lib_git
    git checkout mc_lib_git/master
```
```
    pip install -r requirements.txt
```
   
Meson uses a configure and a build stage.
   To configure it for putting the build artifacts in `build/` 
   and a local install under `installdir/` and then build:

   ```
    meson setup build --prefix=$PWD/installdir
    meson install -C build
   ``` 
   If you want to rebuild the package for some developer needs.
   Use `setup` with flag `--wipe` to fully rebuild package or
   `--reconfigure` to update current build
   
Get your installdir visible to python:   
```
    export PYTHONPATH=$PWD/installdir/lib/python{Your python version}/site-packages
```
Run included tests with
```
    pytest mc_lib -v --pyargs
```
----


## Usage 

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




## Notes

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

- On MacOS you may need to tell cython to use C++11, `-std=C++11` or
some such. This is due to the fact that by default xcode selects an older
C++ dialect. As an example of using this in a Jupyter notebook, see
`examples/frustrated_2d_ising.ipynb`. For command-line usage, see `meson.build`
files in the main `mc_lib` repository.

[![pip(Linux&MacOS)](https://github.com/ev-br/mc_lib/actions/workflows/pip_ubuntu_macos.yml/badge.svg)](https://github.com/ev-br/mc_lib/actions/workflows/pip_ubuntu_macos.yml/)
[![meson(Linux & MacOS)](https://github.com/ev-br/mc_lib/actions/workflows/dev_ubuntu_macos.yml/badge.svg)](https://github.com/ev-br/mc_lib/actions/workflows/dev_ubuntu_macos.yml/)
[![license](http://img.shields.io/badge/license-BSD-blue.svg?style=flat)](https://github.com/ev-br/mc_lib/blob/master/LICENSE)


