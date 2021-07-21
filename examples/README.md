Build simple examples of using `mc_lib` primitives.


### Build with `setuptools`
1.  1D Ising

> python setup.py build_ext -i
> 
> python -c'from cy_ising import simulate; simulate(4, 1.25, 100000)'    

2.  Frustrated 2D Ising

>pip install jupyter 
> 
>ipython -c"%run frustrated_2d_ising.ipynb"
### Build with `meson`
1.  1D Ising

> meson setup builddir1 --prefix=$PWD/installdir1
> 
> meson install -C builddir1

It will create meson build directory and installdir1. 
Example will be in `$PWD/installdir1/lib/python{your python vesion}/site-packages`
    
2.  Frustrated 2D Ising

>pip install jupyter 
> 
>ipython -c"%run frustrated_2d_ising.ipynb"


