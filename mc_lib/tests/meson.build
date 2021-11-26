_check_rndm_cpp = custom_target('check_rndm_cpp',
  output : '__check_rndm.cpp',
  input : '__check_rndm.pyx',
  command : [cython, '--cplus', '-3', '--fast-fail', '@INPUT@', '-o', '@OUTPUT@']
)

py3.extension_module(
  '__check_rndm', _check_rndm_cpp,
  include_directories: inc_np,
  dependencies : py3_dep,
  cpp_args: [numpy_nodepr_api],
  install: true,
  subdir: 'mc_lib/tests'
)



python_sources = [
    '__init__.py',
    'test_cubic_lattice.py',
    'test_observable.py',
    'test_rndm.py',
]

py3.install_sources(
    python_sources,
    pure: false,
    subdir: 'mc_lib/tests'
)
