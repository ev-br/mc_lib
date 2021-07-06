project(
  'mc_lib_tests',
  ['cython'],
  default_options : ['warning_level=3'],
  meson_version: '>= 0.59',
)

if meson.backend() != 'ninja'
  error('MESON_SKIP_TEST: Ninja backend required')
endif

cython = find_program('cython', required : true)
if not cython.found()
  error('MESON_BUILD_FAILED: Cython3 not found.')
endif


py_mod = import('python')
py3 = py_mod.find_installation()
py3_dep = py3.dependency()

# TEST rndm
py3.extension_module(
  'test_build', 'test_build.pyx',
  dependencies : [py3_dep],
)

