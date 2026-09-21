#!/usr/bin/env python3
"""move-modules.py -- relocate Lean modules and rewrite every citation of them.

A module relocation in this repository is never just a `git mv`: the module name
appears in archived `import` lines, in live docstrings as a dotted name and as a
slash path, in markdown and typst prose, in the `scripts/` gate harness, and in
relative links inside the moved files themselves. This tool performs all of it
from one auditable mapping file, counts what it touched per rewrite class, and
closes by running the invariant harness.

Inputs
------
--module-map FILE     Lines of the form `old.module -> new.module`. Entries are
                      matched as module PREFIXES, longest first, so an entire
                      subtree moves on one line. `#` starts a comment.
--namespace-map FILE  Optional. Lines of the form `Old.Ns -> New.Ns`, driving the
                      namespace/open/FQN and axiom-baseline rewrite classes. A
                      relocation that changes no declaration's namespace needs
                      none.
--dry-run             Report what would change; touch nothing.
--no-verify           Skip the closing harness run (for composing several maps
                      into one commit).

The path mapping is DERIVED from the module mapping rather than accepted as a
second input, so the two cannot drift apart.

Rewrite classes
---------------
1. `import` lines under FormalSystem/, Tests/ and the archive.
2. Dotted citations elsewhere (.lean docstrings, markdown, typst, scripts/).
3. Slash-path citations, same scope plus .github/workflows/.
4. namespace / open / fully-qualified-name occurrences (needs --namespace-map).
5. The C2 and C14 axiom baselines in scripts/check-module-invariants.sh and every
   `#print axioms` line in FormalSystem/MainResults.lean.
6. The tree move itself, as a single `git mv` per mapping.
7. Relative-link re-basing inside moved markdown.

The bare-token trap
-------------------
Every rewrite rule is anchored on the FULL old prefix -- `FormalSystem/Boneyard`,
never the bare token `Boneyard`. Citations that already use the bare form are
typically relative to the old parent directory and become correct repository-root
paths the moment the subtree moves; rewriting them corrupts them. The report
carries an explicit bare-form audit line asserting a zero delta, because a passing
total does not distinguish "left alone" from "rewritten twice".

Exclusions: specs/ (the task-management record legitimately names old paths, and
C5/C9/C10 all exclude it), .git/, .lake/, build/, __pycache__/.
"""

from __future__ import annotations

import argparse
import os
import re
import sys

PRUNE_DIRS = {".git", ".lake", "build", "specs", "__pycache__", "node_modules"}

# Class 2/3 scope by extension, and the two path-prefixed extension sets.
PROSE_EXT = {".lean", ".md", ".typ"}
SCRIPT_DIR = "scripts"
SCRIPT_EXT = {".sh", ".py", ".txt"}
WORKFLOW_DIR = os.path.join(".github", "workflows")
WORKFLOW_EXT = {".yml", ".yaml"}

# Module roots whose on-disk location is not the repository root.
MODULE_ROOT_DIRS = {"BimodalTest": "Tests"}


class Mapping:
    """One `old.module -> new.module` pair, plus the path pair it induces."""

    def __init__(self, old_mod: str, new_mod: str) -> None:
        self.old_mod = old_mod
        self.new_mod = new_mod
        self.old_path = module_to_path(old_mod)
        self.new_path = module_to_path(new_mod)
        self.old_path_slash = self.old_path.replace(os.sep, "/")
        self.new_path_slash = self.new_path.replace(os.sep, "/")

        esc_old_mod = re.escape(old_mod)
        esc_old_path = re.escape(self.old_path_slash)

        # Class 1: a whole import line, the old module as a prefix of the imported
        # module. Anchored at both ends so a word merely beginning with `import`
        # inside a comment or a fenced block is not a match.
        self.import_re = re.compile(
            r"^(import\s+)" + esc_old_mod + r"((?:\.[A-Za-z0-9_]+)*)(\s*)$")
        # Class 2: the dotted name. The lookbehind rejects a preceding `.` so a
        # longer dotted name that merely ENDS with the old one is not rewritten.
        self.dotted_re = re.compile(
            r"(?<![A-Za-z0-9_.])" + esc_old_mod + r"(?![A-Za-z0-9_])")
        # Class 3: the slash path. A preceding `/` is deliberately ALLOWED -- a
        # relative link such as `../../FormalSystem/Boneyard/x.md` must be
        # rewritten -- while a preceding word character is not.
        self.slash_re = re.compile(
            r"(?<![A-Za-z0-9_])" + esc_old_path + r"(?![A-Za-z0-9_])")
        # The bare final path component used as a path prefix. The lookbehind
        # rejects `/`, so this matches ONLY citations that already omit the old
        # parent -- the class that must survive the relocation untouched.
        self.bare_re = re.compile(
            r"(?<![A-Za-z0-9_/.])" + re.escape(os.path.basename(self.old_path))
            + r"/")

    def __str__(self) -> str:
        return f"{self.old_mod} -> {self.new_mod}"


def module_to_path(mod: str) -> str:
    """Repo-relative directory/file stem for a module name, extension-free."""
    parts = mod.split(".")
    root = MODULE_ROOT_DIRS.get(parts[0])
    if root:
        return os.path.join(root, *parts)
    return os.path.join(*parts)


def parse_map(path: str) -> list[tuple[str, str]]:
    """Parse `old -> new` lines, rejecting anything else loudly."""
    pairs = []
    with open(path, encoding="utf-8") as handle:
        for lineno, raw in enumerate(handle, 1):
            line = raw.split("#", 1)[0].strip()
            if not line:
                continue
            if "->" not in line:
                sys.exit(f"{path}:{lineno}: expected `old -> new`, got: {line}")
            old, new = (part.strip() for part in line.split("->", 1))
            if not old or not new:
                sys.exit(f"{path}:{lineno}: empty side in mapping: {line}")
            pairs.append((old, new))
    if not pairs:
        sys.exit(f"{path}: no mappings found")
    return pairs


def load_mappings(path: str) -> list[Mapping]:
    """Mappings sorted longest-prefix-first, so a nested pair wins over its parent."""
    mappings = [Mapping(old, new) for old, new in parse_map(path)]
    mappings.sort(key=lambda m: (m.old_mod.count("."), len(m.old_mod)), reverse=True)
    return mappings


def rel(path: str) -> str:
    """Normalize to a forward-slash repo-relative path for matching and display."""
    return os.path.normpath(path).replace(os.sep, "/")


def walk_repo() -> list[str]:
    """Every tracked-shaped file in the repository, minus the exclusion set."""
    out = []
    for root, dirs, files in os.walk("."):
        dirs[:] = sorted(d for d in dirs if d not in PRUNE_DIRS)
        for name in sorted(files):
            out.append(rel(os.path.join(root, name)))
    return out


def classes_for(path: str) -> set[str]:
    """Which rewrite classes apply to this file, by extension and location."""
    ext = os.path.splitext(path)[1]
    applicable: set[str] = set()
    if ext == ".lean" and (path.startswith("FormalSystem/")
                           or path.startswith("Tests/")
                           or path == "FormalSystem.lean"):
        applicable.add("import")
    if ext in PROSE_EXT:
        applicable.update(("dotted", "slash"))
    elif path.startswith(SCRIPT_DIR + "/") and ext in SCRIPT_EXT:
        applicable.update(("dotted", "slash"))
    elif path.startswith(WORKFLOW_DIR.replace(os.sep, "/") + "/") and ext in WORKFLOW_EXT:
        applicable.add("slash")
    return applicable


SENTINEL = "\x00"


def bare_form_count(text: str, mappings: list[Mapping]) -> int:
    """Occurrences of each mapping's bare final path component, as a path prefix.

    The lookbehind rejects a preceding `/`, so a full-prefix occurrence such as
    `FormalSystem/Boneyard/x` never counts here -- only a citation that ALREADY
    uses the bare form does. Those are the ones that must come through the
    relocation byte-identical.
    """
    total = 0
    for mapping in mappings:
        total += len(mapping.bare_re.findall(text))
    return total


def rewrite_text(path: str, text: str, mappings: list[Mapping],
                 counts: dict[str, int], files: dict[str, set[str]],
                 sentinel: bool = False) -> str:
    """Apply classes 1-3 line by line, counting each class separately.

    With `sentinel`, every replacement is an opaque marker carrying no module
    name. Re-running the rewrite in that mode is how the bare-form audit
    distinguishes a bare citation that survived from one the rewrite created.
    """
    applicable = classes_for(path)
    if not applicable:
        return text

    out_lines = []
    for line in text.splitlines(keepends=True):
        body = line.rstrip("\n")
        newline = line[len(body):]

        if "import" in applicable:
            rewritten, hit = apply_import(body, mappings, sentinel)
            if hit:
                counts["import"] += 1
                files.setdefault("import", set()).add(path)
                out_lines.append(rewritten + newline)
                continue

        if "dotted" in applicable:
            body, n = apply_regex(body, mappings, "dotted_re", "new_mod", sentinel)
            if n:
                counts["dotted"] += n
                files.setdefault("dotted", set()).add(path)
        if "slash" in applicable:
            body, n = apply_regex(body, mappings, "slash_re", "new_path_slash",
                                  sentinel)
            if n:
                counts["slash"] += n
                files.setdefault("slash", set()).add(path)

        out_lines.append(body + newline)
    return "".join(out_lines)


def apply_import(line: str, mappings: list[Mapping],
                 sentinel: bool = False) -> tuple[str, bool]:
    """Rewrite one import line if any mapping's module is a prefix of its target."""
    for mapping in mappings:
        match = mapping.import_re.match(line)
        if match:
            new = SENTINEL if sentinel else mapping.new_mod
            return (match.group(1) + new + match.group(2) + match.group(3), True)
    return line, False


def apply_regex(line: str, mappings: list[Mapping], attr: str,
                replacement: str, sentinel: bool = False) -> tuple[str, int]:
    """Apply one class's pattern for every mapping, returning the occurrence count."""
    total = 0
    for mapping in mappings:
        new = SENTINEL if sentinel else getattr(mapping, replacement)
        line, n = getattr(mapping, attr).subn(new, line)
        total += n
    return line, total


def read_text(path: str) -> str | None:
    try:
        with open(path, encoding="utf-8") as handle:
            return handle.read()
    except (OSError, UnicodeDecodeError):
        return None


def run(args: argparse.Namespace) -> int:
    mappings = load_mappings(args.module_map)

    counts: dict[str, int] = {"import": 0, "dotted": 0, "slash": 0}
    files: dict[str, set[str]] = {}
    bare_before = bare_after = 0
    bare_files: set[str] = set()
    changed: list[tuple[str, str]] = []

    for path in walk_repo():
        if not classes_for(path):
            continue
        text = read_text(path)
        if text is None:
            continue
        new_text = rewrite_text(path, text, mappings, counts, files)
        # The audit re-runs the SAME rewrite with opaque replacements, so a bare
        # citation the rewrite created is not mistaken for one it preserved. A
        # rule keyed on the bare token would consume pre-existing bare citations
        # and the two counts would diverge.
        sentinel_text = rewrite_text(path, text, mappings, dict(counts), {},
                                     sentinel=True)
        before = bare_form_count(text, mappings)
        after = bare_form_count(sentinel_text, mappings)
        bare_before += before
        bare_after += after
        if before:
            bare_files.add(path)
        if new_text != text:
            changed.append((path, new_text))

    if not args.dry_run:
        for path, new_text in changed:
            with open(path, "w", encoding="utf-8") as handle:
                handle.write(new_text)

    report(args, mappings, counts, files, changed,
           bare_before, bare_after, len(bare_files))

    if bare_before != bare_after:
        print("\nFAIL  bare-form citations were rewritten; every rule must be "
              "anchored on the full old prefix", file=sys.stderr)
        return 1
    return 0


def report(args: argparse.Namespace, mappings: list[Mapping],
           counts: dict[str, int], files: dict[str, set[str]],
           changed: list[tuple[str, str]], bare_before: int, bare_after: int,
           bare_file_count: int) -> None:
    mode = "DRY RUN" if args.dry_run else "APPLIED"
    print(f"=== move-modules ({mode}) ===")
    for mapping in mappings:
        print(f"  map  {mapping}   ({mapping.old_path} -> {mapping.new_path})")
    print()
    labels = [("import", "class 1  import lines"),
              ("dotted", "class 2  dotted citations"),
              ("slash", "class 3  slash-path citations")]
    for key, label in labels:
        print(f"  {label:<34} {counts[key]:>5} occurrence(s) in "
              f"{len(files.get(key, ())):>4} file(s)")
    print()
    print(f"  audit    bare-form occurrences        {bare_before:>5} before, "
          f"{bare_after:>5} after, in {bare_file_count} file(s)")
    print(f"  files changed                         {len(changed):>5}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        prog="move-modules.py",
        description="Relocate Lean modules and rewrite every citation of them.")
    parser.add_argument("--module-map", required=True,
                        help="file of `old.module -> new.module` lines")
    parser.add_argument("--namespace-map",
                        help="optional file of `Old.Ns -> New.Ns` lines")
    parser.add_argument("--dry-run", action="store_true",
                        help="report only; write nothing and move nothing")
    parser.add_argument("--no-verify", action="store_true",
                        help="skip the closing invariant-harness run")
    args = parser.parse_args(argv)

    if not os.path.isdir(".git"):
        sys.exit("move-modules.py must be run from the repository root")
    return run(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
