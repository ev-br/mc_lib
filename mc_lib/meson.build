# compile .cpp for rndm module
_rndm_cpp = custom_target('rndm_cpp',
  output : 'rndm.cpp',
  input : 'rndm.pyx',
  depend_files: 'rndm.pxd',
  command : [cython, '--cplus', '-3', '--fast-fail', '@INPUT@', '-o', '@OUTPUT@']
)

# generate .so for rndm
py3.extension_module(
  'rndm', _rndm_cpp,
  include_directories: inc_np,
  dependencies : py3_dep,
  cpp_args: [numpy_nodepr_api],
  install: true,
  subdir: 'mc_lib'
)

# compile .cpp for observable module
_observable_cpp = custom_target('observable_cpp',
  output : 'observable.cpp',
  input : 'observable.pyx',
  depend_files: 'observable.pxd',
  command : [cython, '--cplus', '-3', '--fast-fail', '@INPUT@', '-o', '@OUTPUT@']
)

# generate .so for observable
py3.extension_module(
  'observable', _observable_cpp,
  include_directories: inc_np,
  dependencies : [py3_dep],
  install: true,
  subdir: 'mc_lib'
)
# create a list of files which will be installed as source
python_sources = [
    '__init__.py',
    'rndm.pxd',
    'observable.pxd',
]
# crate list of files from subdir `lattices`
python_sources_lattices = [
    'lattices/__init__.py',
    'lattices/_common.py',
    'lattices/_cubic.py',
    'lattices/_triang.py',
]
# install source files in current dir
py3.install_sources(
    python_sources,
    pure: false,
    subdir: 'mc_lib'
)

# install source files in `lattices`
py3.install_sources(
    python_sources_lattices,
    pure: false,
    subdir: 'mc_lib/lattices'
)

# install source files in `_observable`
# we can install .h files cause the `install sources` similar to `install_data`
py3.install_sources(
    '_observable/observable.h',
    pure: false,
    subdir: 'mc_lib/_observable'
)

# go into `tests`
subdir('tests')


