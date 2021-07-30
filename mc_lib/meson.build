
py3.extension_module(
  'rndm', 'rndm.pyx',
  include_directories: inc_np,
  dependencies : py3_dep,
  install: true,
  subdir: 'mc_lib',
  override_options : ['cython_language=cpp'],
)



py3.extension_module(
  'observable', 'observable.pyx',
  include_directories: inc_np,
  dependencies : py3_dep,
  install: true,
  subdir: 'mc_lib',
  override_options : ['cython_language=cpp'],  #<-  works
)

python_sources = [
    '__init__.py',
    'rndm.pxd',
    'observable.pxd',
]

python_sources_lattices = [
    'lattices/__init__.py',
    'lattices/_common.py',
    'lattices/_cubic.py',
    'lattices/_triang.py',
]

py3.install_sources(
    python_sources,
    pure: false,
    subdir: 'mc_lib'
)

py3.install_sources(
    python_sources_lattices,
    pure: false,
    subdir: 'mc_lib/lattices'
)

py3.install_sources(
    '_observable/observable.h',
    pure: false,
    subdir: 'mc_lib/_observable'
)

subdir('tests')


