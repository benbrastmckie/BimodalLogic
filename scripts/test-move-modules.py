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
               "no_verify": True, "no_rewrite": None, "strict": False}
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


class MoveSetIntegrityTest(unittest.TestCase):
    """An ambiguous stem is refused before any write; a run that moves nothing fails."""

    def test_stem_naming_directory_and_file_is_refused(self) -> None:
        files = {
            "FormalSystem/Syntax/Lang/Child.lean": "namespace Lang\nend Lang\n",
            "FormalSystem/Syntax/Lang.lean": "import FormalSystem.Syntax.Lang.Child\n",
            "docs/x.md": "See `FormalSystem.Syntax.Lang` in `FormalSystem/Syntax/Lang`.\n",
        }
        with fixture_repo(files):
            before = snapshot()
            module_map = write_map(["FormalSystem.Syntax.Lang -> FormalSystem.Lang"])
            rc, out, err = run_tool(module_map=module_map)
            self.assertNotEqual(rc, 0)
            self.assertIn("FormalSystem/Syntax/Lang/", err)
            self.assertIn("FormalSystem/Syntax/Lang.lean", err)
            self.assertIn("aggregator", err)
            self.assertIn("second invocation", err)
            # Nothing is rewritten for a move that will fail, and nothing moved.
            self.assertEqual(snapshot(), before)
            self.assertFalse(os.path.exists("FormalSystem/Lang"))
            self.assertFalse(os.path.exists("FormalSystem/Lang.lean"))

    def test_rows_requested_and_nothing_moved_is_a_failure(self) -> None:
        files = {
            "FormalSystem/Other.lean": "-- see FormalSystem.Gone.Mod\n",
            "docs/x.md": "See `FormalSystem.Gone.Mod` at `FormalSystem/Gone/Mod.lean`.\n",
        }
        with fixture_repo(files):
            module_map = write_map(["FormalSystem.Gone.Mod -> FormalSystem.Here.Mod"])
            rc, out, err = run_tool(module_map=module_map, dry_run=True)
            self.assertNotEqual(rc, 0)
            self.assertGreater(class_count(out, "class 2  dotted citations"), 0)
            self.assertGreater(class_count(out, "class 3  slash-path citations"), 0)
            self.assertEqual(class_count(out, "class 6  tree moves"), 0)
            self.assertRegex(
                out, r"files moved\s+0 in 0 path\(s\), against 3 citation\(s\) rewritten")
            self.assertIn("nothing moved", err)

    def test_report_states_moved_next_to_rewritten(self) -> None:
        with fixture_repo(BASELINE_FILES):
            module_map = write_map(["FormalSystem.Foo.Bar -> FormalSystem.Baz.Bar"])
            rc, out, err = run_tool(module_map=module_map)
            self.assertEqual(rc, 0, err)
            self.assertRegex(
                out, r"files moved\s+1 in 1 path\(s\), against 3 citation\(s\) rewritten")


HISTORICAL_README = (
    "Archived. Moved from `FormalSystem/Old` to `FormalSystem/New`; the module was\n"
    "`FormalSystem.Old.M`. See Old/M.lean for the bare form.\n")

NO_REWRITE_FILES = {
    "FormalSystem/Old/M.lean": "namespace Old\nend Old\n",
    "Boneyard/X/README.md": HISTORICAL_README,
    "docs/x.md": "See `FormalSystem.Old.M` at `FormalSystem/Old/M.lean`.\n",
}


class NoRewriteTest(unittest.TestCase):
    """Files on the --no-rewrite list are walked and reported, never written."""

    def run_default(self) -> tuple[int, str, str]:
        module_map = write_map(["FormalSystem.Old -> FormalSystem.New"])
        return run_tool(module_map=module_map)

    def test_default_list_file_is_byte_identical_after_apply(self) -> None:
        with fixture_repo(NO_REWRITE_FILES):
            rc, out, err = self.run_default()
            self.assertEqual(rc, 0, err)
            with open("Boneyard/X/README.md", encoding="utf-8") as handle:
                self.assertEqual(handle.read(), HISTORICAL_README)
            with open("docs/x.md", encoding="utf-8") as handle:
                self.assertEqual(
                    handle.read(),
                    "See `FormalSystem.New.M` at `FormalSystem/New/M.lean`.\n")
            self.assertRegex(out, r"skipped\s+--no-rewrite\s+1 file\(s\) matched, "
                                  r"1 would have been rewritten")
            self.assertRegex(out, r"Boneyard/X/README\.md\s+\(2 occurrence\(s\)\)")

    def test_class_counts_exclude_skipped_files(self) -> None:
        with fixture_repo(NO_REWRITE_FILES):
            rc, out, err = self.run_default()
            self.assertEqual(rc, 0, err)
            self.assertEqual(class_count(out, "class 2  dotted citations"), 1)
            self.assertEqual(class_count(out, "class 3  slash-path citations"), 1)
            # D4: the skipped file's bare-form citation is outside the audit.
            self.assertRegex(out, r"bare-form occurrences\s+0 before,\s+0 after")

    def test_skipped_and_moved_file_keeps_its_links_and_is_listed(self) -> None:
        readme = "Up: [other](../Other.lean), was `FormalSystem/Old`.\n"
        files = {
            "FormalSystem/Old/M.lean": "namespace Old\nend Old\n",
            "FormalSystem/Old/README.md": readme,
            "FormalSystem/Other.lean": "import FormalSystem.Old.M\n",
        }
        with fixture_repo(files):
            module_map = write_map(["FormalSystem.Old -> FormalSystem.Deep.New"])
            rc, out, err = run_tool(module_map=module_map,
                                    no_rewrite=["FormalSystem/**/README.md"])
            self.assertEqual(rc, 0, err)
            with open("FormalSystem/Deep/New/README.md", encoding="utf-8") as handle:
                self.assertEqual(handle.read(), readme)
            self.assertIn("skipped AND moved", out)
            section = out.split("skipped AND moved", 1)[1]
            self.assertIn("FormalSystem/Old/README.md", section)
            self.assertEqual(class_count(out, "class 7  relative links"), 0)

    def test_skipped_and_moved_heading_absent_when_empty(self) -> None:
        with fixture_repo(NO_REWRITE_FILES):
            rc, out, err = self.run_default()
            self.assertNotIn("skipped AND moved", out)


    def test_tool_and_fixture_tests_are_never_rewrite_targets(self) -> None:
        files = dict(NO_REWRITE_FILES)
        body = 'ROW = "FormalSystem.Old -> FormalSystem.New"\n'
        files["scripts/move-modules.py"] = body
        files["scripts/test-move-modules.py"] = body
        files["scripts/other.py"] = body
        with fixture_repo(files):
            rc, out, err = self.run_default()
            self.assertEqual(rc, 0, err)
            for name in ("scripts/move-modules.py", "scripts/test-move-modules.py"):
                with open(name, encoding="utf-8") as handle:
                    self.assertEqual(handle.read(), body)
            with open("scripts/other.py", encoding="utf-8") as handle:
                self.assertNotEqual(handle.read(), body)


class IdenticalSidesTest(unittest.TestCase):
    """A rewrite that collapses `from X to Y` into `from Y to Y` is reported."""

    MAP = ["FormalSystem.Old -> FormalSystem.New"]

    def run_with(self, files: dict[str, str], **flags) -> tuple[int, str, str]:
        files = dict(files)
        files["FormalSystem/Old/M.lean"] = "namespace Old\nend Old\n"
        with fixture_repo(files):
            return run_tool(module_map=write_map(self.MAP), dry_run=True, **flags)

    def test_prose_sentence_warns_and_strict_fails(self) -> None:
        files = {"docs/notes.md": (
            "# Notes\n"
            "\n"
            "Moved from `FormalSystem/Old` to `FormalSystem/New` last year.\n"
            "Renamed FormalSystem.Old -> FormalSystem.New.\n")}
        rc, out, err = self.run_with(files)
        self.assertEqual(rc, 0, err)
        self.assertIn("docs/notes.md:3", err)
        self.assertIn("docs/notes.md:4", err)
        self.assertIn("Moved from `FormalSystem/Old` to `FormalSystem/New`", err)
        self.assertIn("Moved from `FormalSystem/New` to `FormalSystem/New`", err)
        self.assertRegex(out, r"identical-sides\s+2 warning\(s\) in 1 file\(s\)")
        rc, out, err = self.run_with(files, strict=True)
        self.assertNotEqual(rc, 0)
        self.assertIn("--strict", err)

    def test_table_row_with_non_adjacent_columns_warns(self) -> None:
        files = {"docs/notes.md": (
            "| Before | Note | After |\n"
            "|--------|------|-------|\n"
            "| FormalSystem/Old | some note | FormalSystem/New |\n")}
        rc, out, err = self.run_with(files)
        self.assertEqual(rc, 0, err)
        self.assertIn("docs/notes.md:3", err)
        self.assertRegex(out, r"identical-sides\s+1 warning\(s\) in 1 file\(s\)")
        rc, out, err = self.run_with(files, strict=True)
        self.assertNotEqual(rc, 0)

    def test_apply_mode_warns_too(self) -> None:
        files = {"docs/notes.md": "Moved from `FormalSystem/Old` to `FormalSystem/New`.\n",
                 "FormalSystem/Old/M.lean": "namespace Old\nend Old\n"}
        with fixture_repo(files):
            rc, out, err = run_tool(module_map=write_map(self.MAP))
            self.assertEqual(rc, 0, err)
            self.assertIn("docs/notes.md:1", err)

    def test_sides_already_identical_do_not_warn(self) -> None:
        files = {"docs/notes.md": (
            "Compare `FormalSystem/Old` to `FormalSystem/Old` and note no change.\n"
            "| FormalSystem/Old | FormalSystem/Old |\n")}
        rc, out, err = self.run_with(files, strict=True)
        self.assertEqual(rc, 0, err)
        self.assertNotIn("docs/notes.md", err)

    def test_rewritten_line_without_two_sides_does_not_warn(self) -> None:
        files = {"docs/notes.md": "See `FormalSystem/Old/M.lean` for the definition.\n"}
        rc, out, err = self.run_with(files, strict=True)
        self.assertEqual(rc, 0, err)
        self.assertEqual(class_count(out, "class 3  slash-path citations"), 1)
        self.assertNotIn("docs/notes.md", err)

    def test_skipped_file_is_never_checked(self) -> None:
        files = {"Boneyard/X/README.md":
                 "Moved from `FormalSystem/Old` to `FormalSystem/New`.\n"}
        rc, out, err = self.run_with(files, strict=True)
        self.assertEqual(rc, 0, err)
        self.assertNotIn("Boneyard/X/README.md", err)


class GlobTranslatorTest(unittest.TestCase):
    """The one glob dialect --no-rewrite and --namespace-paths share."""

    def matches(self, pattern: str, path: str) -> bool:
        return bool(move_modules.glob_to_regex(pattern).match(path))

    def test_double_star_matches_zero_or_more_directories(self) -> None:
        pattern = "Boneyard/**/README.md"
        self.assertTrue(self.matches(pattern, "Boneyard/README.md"))
        self.assertTrue(self.matches(pattern, "Boneyard/X/README.md"))
        self.assertTrue(self.matches(pattern, "Boneyard/X/Y/Z/README.md"))
        self.assertFalse(self.matches(pattern, "Boneyard/X/NOTES.md"))
        self.assertFalse(self.matches(pattern, "Other/Boneyard/X/README.md"))

    def test_literal_path_is_exact(self) -> None:
        self.assertTrue(self.matches("typst/SYNC-MAP.md", "typst/SYNC-MAP.md"))
        self.assertFalse(self.matches("typst/SYNC-MAP.md", "typst/SYNC-MAPxmd"))
        self.assertFalse(self.matches("typst/SYNC-MAP.md", "typst/x/SYNC-MAP.md"))

    def test_adr_glob_matches_adrs_only(self) -> None:
        pattern = "docs/architecture/ADR-*.md"
        self.assertTrue(self.matches(
            pattern, "docs/architecture/ADR-010-Boneyard-At-Repository-Root.md"))
        self.assertFalse(self.matches(pattern, "docs/architecture/README.md"))
        self.assertFalse(self.matches(pattern, "docs/architecture/BFMCS_ARCHITECTURE.md"))

    def test_single_star_and_question_mark_do_not_cross_a_slash(self) -> None:
        self.assertFalse(self.matches("docs/*.md", "docs/architecture/README.md"))
        self.assertTrue(self.matches("docs/*.md", "docs/README.md"))
        self.assertFalse(self.matches("a?b", "a/b"))
        self.assertTrue(self.matches("a?b", "axb"))

    def test_default_list_is_exactly_three_entries(self) -> None:
        self.assertEqual(
            list(move_modules.DEFAULT_NO_REWRITE),
            ["Boneyard/**/README.md", "typst/SYNC-MAP.md", "docs/architecture/ADR-*.md"])

    def test_adr_glob_against_the_real_directory_listing(self) -> None:
        directory = os.path.join(REPO_ROOT, "docs", "architecture")
        names = sorted(os.listdir(directory))
        matched = [n for n in names
                   if self.matches("docs/architecture/ADR-*.md", "docs/architecture/" + n)]
        self.assertEqual(matched, [n for n in names if n.startswith("ADR-")])
        self.assertTrue(matched)
        self.assertNotIn("README.md", matched)


if __name__ == "__main__":
    unittest.main()
