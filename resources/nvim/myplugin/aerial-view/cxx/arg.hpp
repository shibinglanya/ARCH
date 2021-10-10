#ifndef AERIAL_VIEW_ARG_HPP__
#define AERIAL_VIEW_ARG_HPP__

#include <cstdlib>

#define ARGBEGIN                                                               \
  for (int idx = 1; idx < argc;) {                                             \
    if (false) {

#define OPTION(arg)                                                            \
  ++idx;                                                                       \
  }                                                                            \
  else if (!strcmp(argv[idx], (arg))) {                                        \
    int ARGFLAG;                                                               \
    ARGFLAG = 0;

#define ARG ((ARGFLAG++ ? idx : ++idx) < argc ? argv[idx] : (abort(), nullptr))

#define ARGINTEGER (strtol(ARG, NULL, 0))

#define ARGSTRING ARG

using ARGSTRING_TYPE = const char *;
using ARGINTEGER_TYPE = long;

#define ARGEND                                                                 \
  ++idx;                                                                       \
  }                                                                            \
  else {                                                                       \
    abort();                                                                   \
  }                                                                            \
  }

#endif
