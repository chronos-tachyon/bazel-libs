# vim:set ft=bzl:
# Copyright © 2018 Donald King
# Licensed under the terms of the LICENSE file in this repository.

_LIBS = {
    "m": {
        "linkopts": ["-lm"],
    },
    "dl": {
        "linkopts": select(
            {
                "@net_chronostachyon_libs//constraints:linux": ["-ldl"],
                "@net_chronostachyon_libs//constraints:darwin": [],
            },
            no_match_error = "I don't know how to use library \"dl\" on your system",
        ),
    },
}

def _make_grouping():
    return struct(
        before_common = [],
        before_static = [],
        before_shared = [],
        before_shared_dso = [],
        before_shared_so = [],
        before_shared_dylib = [],
        before_shared_dll = [],
        common = [],
        static = [],
        shared = [],
        shared_dso = [],
        shared_so = [],
        shared_dylib = [],
        shared_dll = [],
        after_common = [],
        after_static = [],
        after_shared = [],
        after_shared_dso = [],
        after_shared_so = [],
        after_shared_dylib = [],
        after_shared_dll = [],
    )

def _realize_grouping(grouping, shared):
    result = []
    result.extend(grouping.before_common)
    result.extend(grouping.before_static if not shared else [])
    result.extend(grouping.before_shared if shared else [])
    result.extend(grouping.before_shared_dso if shared and shared != True else [])
    result.extend(grouping.before_shared_so if shared == "so" else [])
    result.extend(grouping.before_shared_dylib if shared == "dylib" else [])
    result.extend(grouping.before_shared_dll if shared == "dll" else [])
    result.extend(grouping.common)
    result.extend(grouping.static if not shared else [])
    result.extend(grouping.shared if shared else [])
    result.extend(grouping.shared_dso if shared and shared != True else [])
    result.extend(grouping.shared_so if shared == "so" else [])
    result.extend(grouping.shared_dylib if shared == "dylib" else [])
    result.extend(grouping.shared_dll if shared == "dll" else [])
    result.extend(grouping.after_common)
    result.extend(grouping.after_static if not shared else [])
    result.extend(grouping.after_shared if shared else [])
    result.extend(grouping.after_shared_dso if shared and shared != True else [])
    result.extend(grouping.after_shared_so if shared == "so" else [])
    result.extend(grouping.after_shared_dylib if shared == "dylib" else [])
    result.extend(grouping.after_shared_dll if shared == "dll" else [])
    return result

def fancy_cc_library(**kwargs):
    LIB_ONLY = [
        "defines",
        "includes",
        "srcs",
        "hdrs",
        "textual_hdrs",
        "data",
        "strip_include_prefix",
        "include_prefix",
        "alwayslink",
    ]
    BIN_ONLY = [
    ]
    IMP_ONLY = [
        "hdrs",
    ]
    COMMON = [
        "compatible_with",
        "deprecation",
        "distribs",
        "features",
        "licenses",
        "restricted_to",
        "testonly",
        "toolchains",
        "visibility",
    ]
    KNOWN = LIB_ONLY + BIN_ONLY + IMP_ONLY + COMMON + [
        "name",
        "configuration",
        "copts",
        "linkopts",
        "deps",
        "tags",
        "nocopts",
        "win_def_file",
    ]

    unknown = [k for k in kwargs if k not in KNOWN]
    if unknown:
        fail("unknown named arguments: " + repr(sorted(unknown)))

    copts = _make_grouping()
    linkopts = _make_grouping()
    deps = _make_grouping()

    name = kwargs["name"]
    configuration = kwargs["configuration"]
    nocopts = kwargs.get("nocopts", "")
    win_def_file = kwargs.get("win_def_file", None)
    tags = kwargs.get("tags", [])

    copts.after_common.extend(configuration.get("copts", []))
    copts.after_shared.extend(configuration.get("shared_copts", []))
    copts.after_shared_dso.extend(configuration.get("shared_dso_copts", []))
    copts.after_shared_so.extend(configuration.get("shared_so_copts", []))
    copts.after_shared_dylib.extend(configuration.get("shared_dylib_copts", []))
    copts.after_shared_dll.extend(configuration.get("shared_dll_copts", []))

    linkopts.after_common.extend(configuration.get("linkopts", []))
    linkopts.after_shared.extend(configuration.get("shared_linkopts", []))
    linkopts.after_shared_dso.extend(configuration.get("shared_dso_linkopts", []))
    linkopts.after_shared_so.extend(configuration.get("shared_so_linkopts", []))
    linkopts.after_shared_dylib.extend(configuration.get("shared_dylib_linkopts", []))
    linkopts.after_shared_dll.extend(configuration.get("shared_dll_linkopts", []))

    deps.after_common.extend(configuration.get("deps", []))
    deps.after_shared.extend(configuration.get("shared_deps", []))
    deps.after_shared_dso.extend(configuration.get("shared_dso_deps", []))
    deps.after_shared_so.extend(configuration.get("shared_so_deps", []))
    deps.after_shared_dylib.extend(configuration.get("shared_dylib_deps", []))
    deps.after_shared_dll.extend(configuration.get("shared_dll_deps", []))

    std = configuration.get("std", "c11")
    pthreads = configuration.get("pthreads", True)
    always_hidden = configuration.get("always_hidden", True)
    always_pic = configuration.get("always_pic", True)
    silence = configuration.get("silence", [])
    defines = configuration.get("defines", [])
    include_dirs = configuration.get("include_dirs", [])
    lib_dirs = configuration.get("lib_dirs", [])
    libs = configuration.get("libs", [])
    rpath = configuration.get("rpath", [])

    major_version = configuration.get("major_version", "0")
    current_version = configuration.get("current_version", "0.0")
    compat_version = configuration.get("compat_version", current_version)
    soname = configuration.get("soname", "lib" + name + ".so." + major_version)
    dyname = configuration.get("dyname", "lib" + name + "." + major_version + ".dylib")
    dypath = configuration.get("dypath", "@rpath")
    dllname = configuration.get("dllname", name + "-" + major_version + ".dll")

    copts.before_common.append("-std=" + std)
    copts.before_common.append("-Wall")
    copts.before_common.append("-Wextra")
    copts.before_common.append("-Wno-system-headers")
    for warning in silence:
        copts.before_common.append("-Wno-" + warning)
    copts.before_common.append("-Werror")
    if pthreads:
        copts.before_common.append("-pthreads")
    if always_hidden:
        copts.before_common.append("-fvisibility=hidden")
    else:
        copts.before_static.append("-fvisibility=hidden")
    if always_pic:
        copts.before_common.append("-fPIC")
        copts.common.append("-DPIC")
    else:
        copts.before_shared.append("-fPIC")
        copts.shared.append("-DPIC")
    copts.common.append("-D_POSIX_C_SOURCE=200809L")
    copts.common.append("-D_XOPEN_SOURCE=700")
    copts.common.append("-D_LARGEFILE_SOURCE")
    copts.common.append("-D_LARGEFILE64_SOURCE")
    copts.common.append("-D_FILE_OFFSET_BITS=64")
    copts.common.append("-D_REENTRANT")
    copts.common.append("-D_THREAD_SAFE")
    copts.common.append("-D_DEFAULT_SOURCE")
    copts.common.append("-D_DARWIN_C_SOURCE")
    copts.common.append("-D_GNU_SOURCE")
    copts.common.append("-D_POSIX_PTHREAD_SEMANTICS")
    copts.common.extend(["-D" + it for it in defines])
    copts.common.extend(["-I$(GENDIR)/" + it for it in include_dirs])
    copts.common.extend(["-I" + it for it in include_dirs])
    linkopts.before_shared_so.extend([
        "-Wl,-soname," + soname,
    ])
    linkopts.before_shared_dylib.extend([
        "-Wl,-install_name," + dypath + "/" + dyname,
        "-Wl,-current_version," + major_version + "." + current_version,
        "-Wl,-compatibility_version," + major_version + "." + compat_version,
    ])
    linkopts.before_shared_dll.extend([])  # FIXME
    linkopts.common.extend(["-Wl,-rpath," + it for it in rpath])
    linkopts.common.extend(["-L" + it for it in lib_dirs])
    for lib in libs:
        libdata = _LIBS[lib]
        copts.common.extend(libdata.get("copts", []))
        linkopts.common.extend(libdata.get("linkopts", []))
        deps.common.extend(libdata.get("deps", []))

    static_lib_kwargs = dict([(k, v) for k, v in kwargs.items() if k in LIB_ONLY or k in COMMON])
    static_lib_copts = _realize_grouping(copts, shared=None)
    static_lib_linkopts = _realize_grouping(linkopts, shared=None)
    static_lib_deps = _realize_grouping(deps, shared=None)

    shared_lib_kwargs = dict([(k, v) for k, v in kwargs.items() if k in LIB_ONLY or k in COMMON])
    shared_lib_copts = _realize_grouping(copts, shared=True)
    shared_lib_linkopts = _realize_grouping(linkopts, shared=True)
    shared_lib_deps = _realize_grouping(deps, shared=True)

    shared_bin_kwargs = dict([(k, v) for k, v in kwargs.items() if k in BIN_ONLY or k in COMMON])
    shared_so_name = "lib" + name + ".so"
    shared_so_name_x = soname
    shared_so_name_x_y_z = soname + "." + current_version
    shared_so_copts = _realize_grouping(copts, shared="so")
    shared_so_linkopts = _realize_grouping(linkopts, shared="so")
    shared_so_deps = _realize_grouping(deps, shared="so")
    shared_dylib_name = dyname
    shared_dylib_copts = _realize_grouping(copts, shared="dylib")
    shared_dylib_linkopts = _realize_grouping(linkopts, shared="dylib")
    shared_dylib_deps = _realize_grouping(deps, shared="dylib")
    shared_dll_name = dllname
    shared_dll_copts = _realize_grouping(copts, shared="dll")
    shared_dll_linkopts = _realize_grouping(linkopts, shared="dll")
    shared_dll_deps = _realize_grouping(deps, shared="dll")

    imp_kwargs = dict([(k, v) for k, v in kwargs.items() if k in IMP_ONLY or k in COMMON])

    genrule_kwargs = dict([(k, v) for k, v in kwargs.items() if k in COMMON])

    separate_libs = not (always_pic and always_hidden)

    # Build for static linking
    native.cc_library(
        name = name + "_static",
        copts = static_lib_copts,
        nocopts = nocopts,
        linkopts = static_lib_linkopts,
        deps = static_lib_deps,
        includes = ["."],
        linkstatic = True,
        tags = tags,
        **static_lib_kwargs)

    # Build for shared linking
    native.cc_library(
        name = name,
        copts = shared_lib_copts,
        nocopts = nocopts,
        linkopts = shared_lib_linkopts,
        deps = shared_lib_deps,
        includes = ["."],
        tags = tags,
        **shared_lib_kwargs)

    # Build *.so.X shared library for Linux
    native.cc_binary(
        name = shared_so_name_x,
        srcs = select(
            {
                "@net_chronostachyon_libs//constraints:linux": [":" + name],
            },
            no_match_error = "This target only builds on Linux",
        ),
        deps = shared_so_deps,
        copts = shared_so_copts,
        linkopts = shared_so_linkopts,
        linkshared = True,
        linkstatic = True,
        tags = tags + ["manual"],
        **shared_bin_kwargs)
    native.genrule(
        name = shared_so_name_x_y_z.replace(".", "_"),
        srcs = [shared_so_name_x],
        outs = [shared_so_name, shared_so_name_x_y_z],
        cmd = """
        x="$(location :""" + shared_so_name_x + """)"
        y="$(location :""" + shared_so_name + """)"
        z="$(location :""" + shared_so_name_x_y_z + """)"
        cp -a "$$x" "$$y"
        cp -a "$$x" "$$z"
        """,
        tags = tags + ["manual"],
        output_to_bindir = True,
        **genrule_kwargs)

    # Build *.X.dylib shared library for Mac
    native.cc_binary(
        name = shared_dylib_name,
        srcs = select(
            {
                "@net_chronostachyon_libs//constraints:darwin": [":" + name],
            },
            no_match_error = "This target only builds on Darwin / macOS",
        ),
        deps = shared_dylib_deps,
        copts = shared_dylib_copts,
        linkopts = shared_dylib_linkopts,
        linkshared = True,
        linkstatic = True,
        tags = tags + ["manual"],
        **shared_bin_kwargs)

    # Build *-X.dll shared library for Windows
    native.cc_binary(
        name = shared_dll_name,
        srcs = select(
            {
                "@net_chronostachyon_libs//constraints:windows": [":" + name],
            },
            no_match_error = "This target only builds on Windows",
        ),
        deps = shared_dll_deps,
        copts = shared_dll_copts,
        linkopts = shared_dll_linkopts,
        linkshared = True,
        linkstatic = True,
        tags = tags + ["manual"],
        **shared_bin_kwargs)
