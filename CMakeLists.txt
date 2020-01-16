cmake_minimum_required(VERSION 3.8)
project(movinga VERSION 2.0 LANGUAGES C CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/sdl2)

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

find_package(SDL2 CONFIG REQUIRED)
find_package(SDL2-image CONFIG REQUIRED)
find_package(SDL2-mixer CONFIG REQUIRED)
find_package(SDL2-ttf CONFIG REQUIRED)

add_subdirectory(src)