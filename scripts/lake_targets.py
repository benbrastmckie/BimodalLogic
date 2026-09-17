#!/usr/bin/env python3
"""Read the build targets declared in lakefile.toml.

The single reader every script and CI step uses to enumerate Lake targets, so no caller keeps its
own regex over the lakefile. Lake's defaults are applied here, because `lake translate-config`
and hand-written TOML both omit them: a `lean_lib` with no `roots` has roots `[name]`, and any
target with no `srcDir` has srcDir ".".

Usage (run from the repository root, or pass --lakefile):
  lake_targets.py exe-roots   one lean_exe root module per line
  lake_targets.py lib-roots   one lean_lib root module per line
  lake_targets.py exes        one `target<TAB>root<TAB>srcDir` line per lean_exe

Exit status 2, with a message on stderr, when the lakefile is missing or unparseable, or declares
no target of the requested kind. Callers must treat that as a failure: an empty target list
means the lakefile moved or changed shape, never that there is nothing to check.
"""

import sys
import tomllib


def die(msg: str) -> None:
    print(f"lake_targets.py: {msg}", file=sys.stderr)
    raise SystemExit(2)


def main(argv: list[str]) -> None:
    path = "lakefile.toml"
    args = list(argv)
    if len(args) >= 2 and args[0] == "--lakefile":
        path = args[1]
        args = args[2:]
    if len(args) != 1 or args[0] not in ("exe-roots", "lib-roots", "exes"):
        die("usage: lake_targets.py [--lakefile PATH] {exe-roots|lib-roots|exes}")
    mode = args[0]
    try:
        with open(path, "rb") as fh:
            cfg = tomllib.load(fh)
    except OSError as e:
        die(f"cannot read {path}: {e}")
    except tomllib.TOMLDecodeError as e:
        die(f"cannot parse {path}: {e}")

    exes = cfg.get("lean_exe", [])
    libs = cfg.get("lean_lib", [])
    lines: list[str] = []
    if mode == "exe-roots":
        lines = [exe.get("root", exe["name"]) for exe in exes]
    elif mode == "lib-roots":
        for lib in libs:
            lines.extend(lib.get("roots", [lib["name"]]))
    else:
        lines = [
            f"{exe['name']}\t{exe.get('root', exe['name'])}\t{exe.get('srcDir', '.')}"
            for exe in exes
        ]
    if not lines:
        die(f"{path} declares no target for mode {mode}")
    print("\n".join(lines))


if __name__ == "__main__":
    main(sys.argv[1:])
