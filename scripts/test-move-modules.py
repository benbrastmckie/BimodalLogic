#!/usr/bin/env python3
"""test-move-modules.py -- fixture tests for scripts/move-modules.py.

Stdlib `unittest` only. Every test builds a disposable git repository in a
temporary directory, runs the tool's `run()` in process against it, and asserts
on the return code, the report text and the resulting tree. Nothing here ever
runs the tool against the real repository.

    python3 scripts/test-move-modules.py
"""

from __future__ import annotations

import argparse
import contextlib
import importlib.util
import io
import os
import subprocess
import sys
import tempfile
import unittest

# Resolved at import time, BEFORE any test changes directory.
SCRIPTS_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPTS_DIR)
TOOL_PATH = os.path.join(SCRIPTS_DIR, "move-modules.py")

# The hyphen in the filename rules out a plain `import`.
_spec = importlib.util.spec_from_file_location("move_modules", TOOL_PATH)
move_modules = importlib.util.module_from_spec(_spec)
sys.modules["move_modules"] = move_modules
_spec.loader.exec_module(move_modules)

GIT_IDENTITY = ["-c", "user.email=fixture@example.invalid",
                "-c", "user.name=fixture", "-c", "commit.gpgsign=false"]


@contextlib.contextmanager
def fixture_repo(files: dict[str, str]):
    """A committed git repository holding `files`, entered as the CWD.

    `run()` walks `.` and `move_trees` shells out to `git mv`, so the fixture has
    to be a real repository at the working directory.
    """
    original = os.getcwd()
    with tempfile.TemporaryDirectory() as root:
        try:
            for name, body in files.items():
                target = os.path.join(root, name)
                os.makedirs(os.path.dirname(target) or root, exist_ok=True)
                with open(target, "w", encoding="utf-8") as handle:
                    handle.write(body)
            subprocess.run(["git", "init", "-q", root], check=True)
            subprocess.run(["git", "-C", root, *GIT_IDENTITY, "add", "-A"],
                           check=True)
            subprocess.run(["git", "-C", root, *GIT_IDENTITY, "commit", "-q",
                            "-m", "fixture"], check=True)
            os.chdir(root)
            yield root
        finally:
            os.chdir(original)


_MAP_DIRS: list[tempfile.TemporaryDirectory] = []


def write_map(lines: list[str]) -> str:
    """An `old -> new` mapping file OUTSIDE any fixture repository's walked tree."""
    holder = tempfile.TemporaryDirectory()
    _MAP_DIRS.append(holder)
    path = os.path.join(holder.name, "map.txt")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines) + "\n")
    return path


def tearDownModule() -> None:
    while _MAP_DIRS:
        _MAP_DIRS.pop().cleanup()


def run_tool(**overrides) -> tuple[int, str, str]:
    """Run `move_modules.run` with every flag defaulted; return (rc, out, err).

    The one place a new flag's default is added. `parse_map` reports a malformed
    map through `sys.exit(str)`, so SystemExit becomes a return code here.
    """
    options = {"module_map": None, "namespace_map": None, "dry_run": False,
               "no_verify": True}
    options.update(overrides)
    args = argparse.Namespace(**options)
    out, err = io.StringIO(), io.StringIO()
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
        try:
            rc = move_modules.run(args)
        except SystemExit as exc:
            if isinstance(exc.code, int):
                rc = exc.code
            elif exc.code is None:
                rc = 0
            else:
                print(exc.code, file=sys.stderr)
                rc = 1
    return rc, out.getvalue(), err.getvalue()


def snapshot(paths: list[str] | None = None) -> dict[str, bytes]:
    """`{path: bytes}` for byte-identity assertions; every walked file by default."""
    if paths is None:
        paths = move_modules.walk_repo()
    result = {}
    for path in paths:
        with open(path, "rb") as handle:
            result[path] = handle.read()
    return result


def class_count(report: str, label: str) -> int:
    """The leading figure on the report line beginning with `label`."""
    for line in report.splitlines():
        stripped = line.strip()
        if stripped.startswith(label):
            return int(stripped[len(label):].split()[0])
    raise AssertionError(f"no report line starting with {label!r} in:\n{report}")


BASELINE_FILES = {
    "FormalSystem/Foo/Bar.lean": "namespace Foo\nend Foo\n",
    "FormalSystem/Other.lean": "import FormalSystem.Foo.Bar\n",
    "docs/x.md": "See `FormalSystem.Foo.Bar` at `FormalSystem/Foo/Bar.lean`.\n",
}


class BaselineTest(unittest.TestCase):
    """The unmodified tool's behavior the hardening must not disturb."""

    def test_single_file_move_rewrites_and_moves(self) -> None:
        with fixture_repo(BASELINE_FILES):
            module_map = write_map(["FormalSystem.Foo.Bar -> FormalSystem.Baz.Bar"])
            rc, out, err = run_tool(module_map=module_map)
            self.assertEqual(rc, 0, err)
            self.assertGreater(class_count(out, "class 1  import lines"), 0)
            self.assertGreater(class_count(out, "class 2  dotted citations"), 0)
            self.assertGreater(class_count(out, "class 3  slash-path citations"), 0)
            self.assertTrue(os.path.isfile("FormalSystem/Baz/Bar.lean"))
            self.assertFalse(os.path.exists("FormalSystem/Foo/Bar.lean"))
            with open("FormalSystem/Other.lean", encoding="utf-8") as handle:
                self.assertEqual(handle.read(), "import FormalSystem.Baz.Bar\n")
            with open("docs/x.md", encoding="utf-8") as handle:
                self.assertEqual(
                    handle.read(),
                    "See `FormalSystem.Baz.Bar` at `FormalSystem/Baz/Bar.lean`.\n")


if __name__ == "__main__":
    unittest.main()
