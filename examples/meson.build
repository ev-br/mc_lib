# Create a project
project(
  'mc_lib_example',
  ['cpp', 'cython'],
  default_options : ['warning_level=3'],
  meson_version: '>= 0.54',
)

install_dir = 'examples'

# Check if platform is MACOS and give C++17 flags if needed
if build_machine.system() == 'darwin'
    add_global_arguments('-std=c++17', language : 'cpp')
    message('found OS X, add special argument to compiler')
endif

# Check if Cython installed
cython = find_program('cython', required : true)
if not cython.found()
  error('MESON_BUILD_FAILED: Cython3 not found.')
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

# Check mc_lib installation and get path to it directory
incdir_mc_lib = run_command(py3,
  ['-c', 'import os; os.chdir(".."); import mc_lib; print(mc_lib.get_include())'],
  check : true
).stdout().strip()

# Create a future dependency to numpy and mc_lib by its path
inc_np = include_directories(incdir_numpy)
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
  subdir: install_dir,
)

# Install other files, if needed
python_sources = [
    '__init__.py',
]

py3.install_sources(
    python_sources,
    pure: false,
    subdir: install_dir,
)