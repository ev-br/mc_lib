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
6. [Meson + PEP517](#paragraph5)
7. [How to compile apps, which are using mc_lib with meson](#paragraph6)

---------
## <a name="introduction"></a> Introduction 
In this document I want to try to tell how to work with Meson with Python+Cython program.
The output of my work -- mc_lib working with meson with two installation ways.
One for users with PEP517, another for future mc_lib's developers. 

I worked with this project as study practice at my university, so the full report on russian:

[Overleaf](https://ru.overleaf.com/read/gmzrcgzryjcm)



## <a name="paragraph1"></a> Project structure

Meson using it's own syntax in `meson.build`,
the main difference from languages like Python is that
all `meson.build` files connected between each other, it means,
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
Also variables from `meson.build (C)` are visible outside subdirectory in `meson.build (D)`

## <a name="paragraph2"></a> Top level `meson.build`


### <a name="subparagraph21"></a> Project settings 
There should be declared:
1. Project name,
2. Programming languages(meson trying to find a suitable compiler for named languages ),
   (In Meson < 0.59, you can't declare Cython here)
3. Suitable meson version,
4. App version,
5. Licenses,
6. Etc.

Cython files compiled in order: `.pyx` &rarr; `.c` or `.cpp` &rarr; `.so`.
So there must be at least 2 languages: `cpp` or `c` and `cython`.


### <a name="subparagraph22"></a> Useful system checks 
Check if ninja installed:
```meson
if meson.backend() != 'ninja'
  error('Ninja backend required')
endif
```

For apps which are using `cython` can be added manual check
using `find_program` function:
```meson
cython = find_program('cython', required : true)
if not cython.found()
  error('Cython not found.')
endif
```

And for installation of mc_lib on MacOS, a special cpp compiler flag should be provided.
```meson
# Special check for MacOS, cause of cpp version
if build_machine.system() == 'darwin'
    add_global_arguments('-std=c++17', language : 'cpp')
    message('found OS X, add special argument to compiler')
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
As for `mc_lib`, the most part of it uses `numpy` API,
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
python_sources_lattices = [
    'lattices/__init__.py',
    'lattices/_common.py',
    'lattices/_cubic.py',
    'lattices/_triang.py',
]

py3.install_sources(
    python_sources,
    pure: false,
    subdir: 'mc_lib/lattices'
)
```
As shown in example, you can work with subdirectories using relative pathes.

## <a name="paragraph4"></a> Meson + Cython 
To make compiled `cython` file accessible
to its `.pxd` (cython API) or `.py` (python API), firstly
it must compiled into `.c` or `.cpp` file then 
it must be converted into a `shared_library` meson class object.

Compile `.cpp` file:
```meson
_observable_cpp = custom_target('observable_cpp',
  output : 'observable.cpp',
  input : 'observable.pyx',
  depend_files: 'observable.pxd',
  command : [cython, '--cplus', '-3', '--fast-fail', '@INPUT@', '-o', '@OUTPUT@']
)
```
`custom_target` executed console commands with given args. In this example with
`@INPUT@` = `'observable.pyx'`,
`@OUTPUT@` = `'observable.cpp'`.
The  `depend_files` arg, it helps to detect changes in `.pxd`
files during compilation phase. 

Generate `.so`
```meson
py3.extension_module(
  'observable', _observable_cpp,
  include_directories: inc_np,
  dependencies : [py3_dep],
  install: true,
  subdir: 'mc_lib'
)
```
This method works fine, but for bigger libraries it will become a problem to use
`custom_target` for each module of the program.

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
    subdir: 'mc_lib'
)
```

## <a name="paragraph5"></a> Meson + PEP517
To make meson build system visible to `pip` you need to create `pyproject.toml` and
install a package which will do it. I used [mesonpep517](https://pypi.org/project/mesonpep517/).
So, to make `pip` works in `pyproject.toml` declared:
```toml
[build-system]
requires  = [
    "meson",
    "mesonpep517",
]

build-backend = "mesonpep517.buildapi"

[tool.mesonpep517.metadata]
...
```
Also additional information about the package should be provided in `[tool.mesonpep517.metadata]` section.

## <a name="paragraph6"></a> How to compile apps, which are using mc_lib with meson

Example of build file is  `/examples/meson.build`. All site-packages must be included
into shared_library meson class (`python.extension_module`).
The same solution is used in `mc_lib/meson.build` for the NumPy package.

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

Especially for MacOS, I need to add the `-std=C++17` compiler flag.
```meson
if build_machine.system() == 'darwin'
    add_global_arguments('-std=c++17', language : 'cpp')
    message('found OS X, add special argument to compiler')
endif
```

------

#### Author: Godyaev Dmitry
#### Email: dvgnnv@gmail.com



