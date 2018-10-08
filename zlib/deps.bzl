# vim:set ft=bzl:
# Copyright © 2018 Donald King
# Licensed under the terms of the LICENSE file in this repository.

load("@net_chronostachyon_libs//internal:repo.bzl", "many_repositories")

ZLIB = [
    {
        "rule": "http_archive",
        "name": "net_zlib",
        "sha256": "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
        "urls": [
            "https://blob.chronos-tachyon.net/zlib-1.2.11.tar.gz",
            "https://www.zlib.net/zlib-1.2.11.tar.gz",
        ],
        "strip_prefix": "zlib-1.2.11/",
        "build_file": "@net_chronostachyon_libs//zlib:zlib.BUILD",
        "patch_cmds": [
            "rm -f zconf.h",
        ],
    },
]

def zlib_dependencies():
  many_repositories(ZLIB)
