install_dir = 'mc_lib'

_rndm_pxd = custom_target('_rndm_pxd',
  output : 'rndm.pxd',
  input : 'rndm.pxd',
  command : ['cp', '@INPUT@', '@OUTDIR@'],
)

cython_rndm_pxd = declare_dependency(sources: _rndm_pxd)

py3.extension_module(
  'rndm', 'rndm.pyx',
  include_directories: inc_np,
  dependencies : [py3_dep, cython_rndm_pxd],
  install: true,
  subdir: install_dir
)


pydir = meson.current_build_dir()

python_sources = [
    '__init__.py',
    'rndm.pxd'
]

py3.install_sources(
    python_sources,
    pure: false,
    subdir: install_dir
)

subdir('__check_build')
subdir('lattices')
subdir('tests')