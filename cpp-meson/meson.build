project(
  'HelloWorld',
  'cpp',
  version: '0.1.0',
  default_options: [
    'cpp_std=c++20',
    'warning_level=3',
    'buildtype=debugoptimized',
  ],
)

inc = include_directories('include')

srcs = files('src/util.cpp')

libhello = static_library('libhello', srcs, include_directories: inc)

executable(
  'hello',
  'src/main.cpp',
  include_directories: inc,
  link_with: libhello,
  install: true,
)

test_srcs = files('tests/test_util.cpp')

test_exe = executable(
  'tests',
  test_srcs,
  dependencies: [dependency('gtest'), dependency('gtest_main')],
  include_directories: inc,
  link_with: libhello,
)

test('util test', test_exe)
