# -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)
AC_INIT([idl-cedar-client], [1.0.0], [cedardb@hao.ucar.edu])
AC_CONFIG_SRCDIR([cedar_data.pro])
AC_CONFIG_AUX_DIR([conf])

AM_INIT_AUTOMAKE

# Checks for programs.
AC_PROG_CXX
AC_PROG_LIBTOOL
AC_PROG_INSTALL

# Checks for typedefs, structures, and compiler characteristics.

AC_ARG_ENABLE([prodir],
   [AS_HELP_STRING([--with-pro],[idl program files dir (default ${datadir}/idl)])],
   [
        idl_pro_dir="$withval"
   ],
   [
        idl_pro_dir=${datadir}/idl
   ]
)

AC_SUBST([idl_pro_dir])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT

