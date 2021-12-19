# Create a project
project(
  'mc_lib_examples',
  ['cpp', 'cython'],
  default_options : ['warning_level=3'],
  meson_version: '>= 0.54',
)


# Check if platform is MACOS and give C++17 flags if needed
if build_machine.system() == 'darwin'
    add_global_arguments('-std=c++17', language : 'cpp')
    message('found OS X, add special argument to compiler')
endif

# Check if Cython installed
cython = find_program('cython', required : true)
if not cython.found()
  error('Cython not found.')
endif

# Find installed python
py_mod = import('python')
py3 = py_mod.find_installation()

# Find python default dependency
py3_dep = py3.dependency()

# Check numpy installation, and get path to it directory
incdir_numpy = run_command(py3,
  ['-c', 'import os; os.chdir(".."); import numpy; print(numpy.get_include())'],
  check : true
).stdout().strip()

# Create a future dependency to numpy by its path
inc_np = include_directories(incdir_numpy)


# Check mc_lib installation and get path to it directory
incdir_mc_lib = run_command(py3,
  ['-c', 'import os; os.chdir(".."); import mc_lib; print(mc_lib.get_include())'],
  check : true
).stdout().strip()

# Create a future dependency to mc_lib by its path
inc_mc_lib = include_directories(incdir_mc_lib)

numpy_nodepr_api = '-DNPY_NO_DEPRECATED_API=NPY_1_9_API_VERSION'

######## cy_ising extension ####################

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
  cpp_args: [numpy_nodepr_api],
  install: true,
  subdir: 'examples',
)


######## cy_poisson extension ####################

# Set up linking with npymath and npyrandom libraries.
# this is done following https://numpy.org/devdocs/reference/random/examples/cython/extending_distributions.pyx.html
# and https://numpy.org/devdocs/reference/random/examples/cython/setup.py.html

npymath_path = incdir_numpy / '..' / 'lib'
npymath_lib = meson.get_compiler('cpp').find_library('npymath', dirs: npymath_path)
npyrandom_path = incdir_numpy / '..' / '..' / 'random' / 'lib'
npyrandom_lib = meson.get_compiler('cpp').find_library('npyrandom', dirs: npyrandom_path)


# Compile .cpp file
_cy_poisson = custom_target('cy_poisson_cpp',
  output : 'cy_poisson.cpp',
  input : 'cy_poisson.pyx',
  command : [cython, '--cplus', '-3', '--fast-fail', '@INPUT@', '-o', '@OUTPUT@']
)

# Compile .so file
py3.extension_module(
  'cy_poisson', _cy_poisson,
  include_directories: [inc_np, npymath_path, npyrandom_path, inc_mc_lib],
  dependencies : [py3_dep, npymath_lib, npyrandom_lib],
  cpp_args: [numpy_nodepr_api],
  install: true,
  subdir: 'examples',
)

