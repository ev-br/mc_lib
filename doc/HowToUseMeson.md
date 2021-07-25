# How to use Meson as build system in your Python-Cython app

----------

<p align="center">
    <a href="https://mesonbuild.com/index.html">
    <img width="50" 
         height="50" 
         src="https://mesonbuild.com/assets/images/meson_logo.png" alt="meson source">
    </a>
</p>

# Table of contents

1. [Introduction](#introduction)
2. [Project structure](#paragraph1)
3. [Top level meson file](#paragraph2)
    1. [Project settings](#subparagraph21)
    2. [Useful system checks](#subparagraph22)
4. [Meson + Python](#paragraph3)
5. [Meson + Cython](#paragraph4)
5. [How to compile apps, which are using mc_lib with meson](#paragraph5)

---------
## <a name="introduction"></a> Introduction 

Some introduction. I'll add it later


## <a name="paragraph1"></a> Project structure 

All `meson.build` files connected between each other, it means,
that variables declared in upper `meson.build` are visible
from every subdirs `meson.build` files.

The order of subdir() links is important for project. 

Example:
```
project
│   file001.pyx
│   meson.build (A) 
│   
└───subdir1
│   │   file011.pyx
│   │   meson.build (B)
│   │
│   └───subdir1_1
│       │   file111.pyx
│       │   file112.pxd
│       │   meson.build (C)
│   
└───subdir2
    │   file021.pyx
    │   meson.build (D)
```

`meson.build (A)`:

```meson
subdir('subdir1')
subdir('subdir2')
```
Variables declared in `subdir1` are visible in `subdir2`, but not vice versa.


## <a name="paragraph2"></a> Top level `meson.build`


### <a name="subparagraph21"></a> Project settings 
There should be declared:
1. Project name,
2. Programming languages(meson trying to find a suitable compiler for named languages ),
3. Suitable meson version,
4. App version,
5. Licenses,
6. Etc.

Cython files compiles in order: `.pyx` &rarr; `.c` or `.cpp` &rarr; `.so`.
So there must be declared at least 2 languages: `cpp` or `c` and `cython`.


### <a name="subparagraph22"></a> Useful system checks 
For apps which are using `cython` can be added manual check
using `find_program` function:
```meson
cython = find_program('cython', required : true)
if not cython.found()
  error('MESON_BUILD_FAILED: Cython not found.')
endif
```

Also, the `python` installation must be checked too. 
Default `python` dependencies saved into variable
to insert them into every compile target
```meson
py_mod = import('python')
py3 = py_mod.find_installation()
py3_dep = py3.dependency()
```
As for `MC_lib`, the most part of it uses `numpy` API,
so numpy declared as dependency, by its location:
```meson
incdir_numpy = run_command(py3,
  ['-c', 'import os; os.chdir(".."); import numpy; print(numpy.get_include())'],
  check : true
).stdout().strip()

inc_np = include_directories(incdir_numpy)
```


## <a name="paragraph3"></a> Meson + Python 
There is no need to compile pure `python` files,
so all of them can be installed as sources:
```meson
python_sources = [
    '__init__.py',
    'Pytester.py',
] # declare list of .py files

py3.install_sources(
    python_sources,
    pure: false,
    subdir: install_dir
)
```


## <a name="paragraph4"></a> Meson + Cython 
To make compiled `cython` file accessible
to its `.pxd` (cython API) or `.py` (python API), firstly
it must compiled into `.c` or `.cpp` file then 
it must be converted into `shared_library` meson class object.

Compile cpp file
Meson version < 0.59:
```meson
_observable_cpp = custom_target('observable_cpp',
  output : 'observable.cpp',
  input : 'observable.pyx',
  command : [cython, '--cplus', '-3', '--fast-fail', '@INPUT@', '-o', '@OUTPUT@']
)

py3.extension_module(
  'observable', _observable_cpp,
  include_directories: inc_np,
  dependencies : [py3_dep],
  install: true,
  subdir: install_dir
)
```
---------

###Maybe will work later

Meson version > 0.59:

```meson
py3.extension_module(
  'observable', 'observable.cpp',
  include_directories: inc_np,
  dependencies : py3_dep,
  install: true,
  subdir: install_dir,
  cython_args: '--cplus'
)
```

As for my work, compiler argument  `cython_args: '--cplus'`
don't work, meson do not apply any `cython` args, which I added
by this command. Also using `custom target` give developer a possibility
to control `.so` files compilation. For example, to build 
MC_lib on OSX it necessary to use `C++11`, and using `custom target`
for `.pyx` &rarr; `.cpp` take positional args for `cython` compiler and
'extension_module' take positional args for `C++` compiler


All API for compiled files should be installed as source files
```meson
python_sources = [
    'observable.h',
    'observable.pxd',
]

py3.install_sources(
    python_sources,
    pure: false,
)
```

## <a name="paragraph4"></a> How to compile apps, which are using mc_lib with meson

Example of build file is  `/examples/meson.build`. All site-packages must be included
into shared_library meson class (`python.extension_module`).
The same solution is used in `mc_lib/meson.build` for NumPy package.

```meson
# Check mc_lib installation and get path to it directory
incdir_mc_lib = run_command(py3,
  ['-c', 'import os; os.chdir(".."); import mc_lib; print(mc_lib.get_include())'],
  check : true
).stdout().strip()

inc_mc_lib = include_directories(incdir_mc_lib)

# Compile .cpp file
_cy_ising = custom_target('cy_ising_cpp',
  output : 'cy_ising.cpp',
  input : 'cy_ising.pyx',
  command : [cython, '--cplus', '-3', '--fast-fail', '@INPUT@', '-o', '@OUTPUT@']
)

# Compile .so file
py3.extension_module(
  'cy_ising', _cy_ising,
  include_directories: [inc_np,inc_mc_lib],
  dependencies : py3_dep,
  install: true,
)
```

Specially for MacOS need to add `-std=C++17` compiler flag.
```meson
if build_machine.system() == 'darwin'
    add_global_arguments('-std=c++17', language : 'cpp')
    message('found OS X, add special argument to compiler')
endif
```


