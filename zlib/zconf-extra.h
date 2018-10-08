/* Extra preprocessor declarations for zconf.h.
 *
 * Copyright © 2018 Donald King
 * Licensed under the terms of the LICENSE file in this repository.
 */

#ifndef ZLIB_CONST
#  define ZLIB_CONST
#endif

#ifdef ZEXTERN
# undef ZEXTERN
#endif

#ifdef ZEXPORT
# undef ZEXPORT
#endif

#ifdef ZEXPORTVA
# undef ZEXPORTVA
#endif

#if defined(WINDOWS) || defined(WIN32) || defined(_WIN32) || defined(__CYGWIN__)
#  include <windef.h>
#  ifdef ZLIB_INTERNAL
#    define ZEXTERN extern __declspec(dllexport)
#  else /* !ZEXTERN && WINDOWS && ZLIB_INTERNAL */
#    define ZEXTERN extern __declspec(dllimport)
#  endif /* !ZEXTERN && WINDOWS && ZLIB_INTERNAL */
#  define ZEXPORT   WINAPI
#  define ZEXPORTVA WINAPIV
#else
#  define ZEXTERN   extern __attribute__((visibility("default")))
#  define ZEXPORT   /* empty */
#  define ZEXPORTVA /* empty */
#endif

/* End of zconf-extra.h */
