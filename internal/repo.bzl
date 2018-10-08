# vim:set ft=bzl:
# Copyright © 2018 Donald King
# Licensed under the terms of the LICENSE file in this repository.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")

RULES = {
    "http_archive": http_archive,
    "git_repository": git_repository,
    "new_git_repository": new_git_repository,
}

def if_not_exist(rule, name, **kwargs):
  if name not in native.existing_rules():
    rule(name=name, **kwargs)

def many_repositories(rows):
  for row in rows:
    rule = RULES[row["rule"]]
    name = row["name"]
    rest = dict([(k, v) for k, v in row.items() if k != "rule" and k != "name"])
    if_not_exist(rule, name, **rest)
