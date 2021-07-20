project(
  'mc_lib',
  ['cpp', 'cython'],
  default_options : ['warning_level=3'],
  version: '0.2',
  license: 'BSD-2',
  meson_version: '>= 0.54',
)

if build_machine.system() == 'darwin'
    add_global_arguments('-std=c++17', language : 'cpp')
    message('found OS X, add special argument to compiler')
endif


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

# Thx rgommers "https://github.com/rgommers/scipy/blob/meson/scipy/meson.build"
# NumPy include directory - needed in all submodules
incdir_numpy = run_command(py3,
  ['-c', 'import os; os.chdir(".."); import numpy; print(numpy.get_include())'],
  check : true
).stdout().strip()

inc_np = include_directories(incdir_numpy)


subdir('mc_lib')
