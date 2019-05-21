#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([SpaceAttack], [2.0], [aidenpw@hotmail.com])
AC_CONFIG_SRCDIR([main.cc])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AC_LANG([C++])

# Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AX_CXX_COMPILE_STDCXX([11], [noext], [mandatory])

# Checks for libraries.
AC_CHECK_LIB([SDL2], [SDL_Init])
AC_CHECK_LIB([SDL2_image], [IMG_Init])
AC_CHECK_LIB([SDL2_mixer], [Mix_OpenAudio])
AC_CHECK_LIB([SDL2_ttf], [TTF_Init])

#Check for headers
AC_LANG_PUSH([C])
AC_CHECK_HEADER([stdio.h])
AC_LANG_POP([C])
AC_CHECK_HEADERS([iostream string vector])

# Checks for typedefs, structures, and compiler characteristics.
AC_CHECK_HEADER_STDBOOL
AC_C_INLINE
AC_TYPE_UINT8_T

# Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([strtol])

AC_CONFIG_FILES([Makefile])
AM_INIT_AUTOMAKE
AC_OUTPUT
