_rndm_cpp = custom_target('rndm_cpp',
  output : 'rndm.cpp',
  input : 'rndm.pyx',
  command : [cython, '--cplus', '-3', '--fast-fail', '@INPUT@', '-o', '@OUTPUT@']
)

py3.extension_module(
  'rndm', _rndm_cpp,
  include_directories: inc_np,
  dependencies : py3_dep,
  install: true,
  subdir: 'mc_lib'
)

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
  subdir: 'mc_lib'
)

python_sources = [
    '__init__.py',
    'rndm.pxd',
    'observable.pxd',
]

py3.install_sources(
    python_sources,
    pure: false,
    subdir: 'mc_lib'
)

subdir('lattices')
subdir('tests')
subdir('_observable')


