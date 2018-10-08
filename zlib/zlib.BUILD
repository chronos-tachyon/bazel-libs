# vim:set ft=bzl:
# Copyright © 2018 Donald King
# Licensed under the terms of the LICENSE file in this repository.

load(
    "@net_chronostachyon_libs//internal:cc.bzl",
    "fancy_cc_library",
)

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # zlib license (variant of 3-clause BSD)

HEADERS = [
    "zlib.h",
    "zconf.h",
]

SOURCES = [
    "crc32.h",
    "deflate.h",
    "gzguts.h",
    "inffast.h",
    "inffixed.h",
    "inflate.h",
    "inftrees.h",
    "trees.h",
    "zutil.h",
    "adler32.c",
    "compress.c",
    "crc32.c",
    "deflate.c",
    "gzclose.c",
    "gzlib.c",
    "gzread.c",
    "gzwrite.c",
    "infback.c",
    "inffast.c",
    "inflate.c",
    "inftrees.c",
    "trees.c",
    "uncompr.c",
    "zutil.c",
]

genrule(
    name = "zconf_h",
    srcs = [
        "@net_chronostachyon_libs//zlib:zconf-extra.h",
        "zconf.h.in",
    ],
    outs = ["zconf.h"],
    cmd = """
    set -eu -o pipefail
    cat \\
        "$(location @net_chronostachyon_libs//zlib:zconf-extra.h)" \\
        "$(location :zconf.h.in)" \\
        > "$@"
    """,
)

genrule(
    name = "zlib_ldscript",
    srcs = ["zlib.map"],
    outs = ["zlib.ldscript"],
    cmd = """
    cp -a "$<" "$@"
    """,
)

filegroup(
    name = "headers",
    srcs = HEADERS,
)

fancy_cc_library(
    name = "z",
    srcs = SOURCES,
    hdrs = HEADERS,
    configuration = {
        "std": "c11",
        "pthreads": False,
        "silence": ["implicit-fallthrough", "attributes"],
        "defines": [
            "HAVE_UNISTD_H",
            "HAVE_STDARG_H",
            "HAVE_HIDDEN",
            "ZLIB_CONST",
        ],
        "major_version": "1",
        "current_version": "2.11",
        "compatibility_version": "0.0",
        "shared_dso_deps": [":zlib.ldscript"],
        "shared_dso_linkopts": ["-Wl,-version-script", "$(location :zlib.ldscript)"],
    },
)
