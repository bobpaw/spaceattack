cmake_minimum_required(VERSION 3.8)

if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
      CACHE STRING "")
elseif(DEFINED ENV{VCPKG_INSTALLATION_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_INSTALLATION_ROOT}/scripts/buildsystems/vcpkg.cmake"
      CACHE STRING "")
endif()

project(SpaceAttack VERSION 2.0 LANGUAGES C CXX)
set(PROJECT_SHORTNAME "movinga")
set(PROJECT_STRING "${PROJECT_NAME} ${PROJECT_VERSION}")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

set(default_build_type "Release")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
      STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Macros and stuff
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
include(CTest)
endif()

include(CheckIncludeFileCXX)
include(CheckIncludeFile)
include(CheckCXXCompilerFlag)
include(CheckSymbolExists)
include(CheckCXXSymbolExists)

include_directories("${CMAKE_CURRENT_BINARY_DIR}")

check_include_file_cxx(iostream HAVE_IOSTREAM)
check_include_file_cxx(string HAVE_STRING)
check_include_file_cxx(vector HAVE_VECTOR)
check_include_file(stdio.h HAVE_STDIO_H)

if() # No standard library
endif()

if (CMAKE_TOOLCHAIN_FILE MATCHES ".*vcpkg.cmake$")
  set(VCPKG_FOUND TRUE)
else()
  set(VCPKG_FOUND FALSE)
endif()
find_package(PkgConfig)

if (VCPKG_FOUND)
find_package(SDL2 CONFIG REQUIRED)
find_package(SDL2-image CONFIG REQUIRED)
find_package(SDL2-mixer CONFIG REQUIRED)
find_package(SDL2-ttf CONFIG REQUIRED)
elseif (PKG_CONFIG_FOUND)
pkg_check_modules(SDL2 REQUIRED IMPORTED_TARGET sdl2)
pkg_check_modules(SDL2_image REQUIRED IMPORTED_TARGET SDL2_image)
pkg_check_modules(SDL2_mixer REQUIRED IMPORTED_TARGET SDL2_mixer)
pkg_check_modules(SDL2_ttf REQUIRED IMPORTED_TARGET SDL2_ttf)
else()
error("How am I expected to find SDL2")
endif()

configure_file("config.h.in" "config.h" ESCAPE_QUOTES @ONLY)

if ($<VERSION_GREATER_EQUAL:"${CMAKE_VERSION}","3.12">)
  add_compile_definitions(HAVE_CONFIG_H)
else()
  add_compile_options(-DHAVE_CONFIG_H)
endif()

add_subdirectory(src)