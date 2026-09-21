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
--no-rewrite GLOB     Repeatable. A path or glob whose files are walked and
                      reported but NEVER written, by any class. Values add to the
                      built-in defaults (the archive's provenance READMEs, the
                      typst sync map and the architecture decision records),
                      whose prose states where things USED to be; nothing clears
                      the defaults.
--strict              Promote every identical-sides warning (a rewrite that makes
                      the two sides of one sentence or one table row identical,
                      `from X to Y` becoming `from Y to Y`) to a non-zero exit.
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
C5/C9/C10 all exclude it), .git/, .lake/, build/, __pycache__/, and this file
itself together with its fixture tests -- its worked examples describe what a
relocation does in general and are not citations of any particular tree
location, so rewriting them turns the documentation into nonsense ("anchored on
the full old prefix `X`, never the bare token `X`") while every real citation is
rewritten correctly.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys

PRUNE_DIRS = {".git", ".lake", "build", "specs", "__pycache__", "node_modules"}

HARNESS = os.path.join("scripts", "check-module-invariants.sh")

# Class 5's two sites. The axiom baselines are the only place in the tree where a
# declaration's fully-qualified name is pinned as DATA rather than as code, so a
# namespace rename that misses them turns every pinned check red at once.
AXIOM_BASELINE_SITES = {
    "scripts/check-module-invariants.sh":
        re.compile(r"^'[A-Za-z0-9_.]+' depends on axioms:"),
    "FormalSystem/MainResults.lean":
        re.compile(r"^#print axioms\s+[A-Za-z0-9_.]+\s*$"),
}

# Class 2/3 scope by extension, and the two path-prefixed extension sets.
PROSE_EXT = {".lean", ".md", ".typ"}
SCRIPT_DIR = "scripts"
SCRIPT_EXT = {".sh", ".py", ".txt"}
WORKFLOW_DIR = os.path.join(".github", "workflows")
WORKFLOW_EXT = {".yml", ".yaml"}

# Files whose prose records where a module USED to live. The tool cannot tell a
# citation of a module's current location from a historical statement about its
# old one, and in these files the historical reading is the common one: provenance
# tables, "moved from X to Y" decision records. They are reported, never written.
DEFAULT_NO_REWRITE = ("Boneyard/**/README.md", "typst/SYNC-MAP.md",
                      "docs/architecture/ADR-*.md")

# Module roots whose on-disk location is not the repository root. Both test libraries live
# under Tests/ (`srcDir = "Tests"` in lakefile.toml); `FormalSystem` and `BimodalTools` are
# rooted at the repository root and so need no entry.
MODULE_ROOT_DIRS = {"BimodalTest": "Tests", "BimodalToolsTest": "Tests"}


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


class NamespaceMapping:
    """One `Old.Ns -> New.Ns` pair.

    One pattern serves `namespace`, `open` and bare fully-qualified occurrences
    alike: all three are the same dotted name in source text, and a rule that
    matched only the `namespace` keyword would leave every use site behind.
    """

    def __init__(self, old_ns: str, new_ns: str) -> None:
        self.old_ns = old_ns
        self.new_ns = new_ns
        self.dotted_re = re.compile(
            r"(?<![A-Za-z0-9_.])" + re.escape(old_ns) + r"(?![A-Za-z0-9_])")

    def __str__(self) -> str:
        return f"{self.old_ns} -> {self.new_ns}"


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


def glob_to_regex(pattern: str) -> re.Pattern[str]:
    """One explicit glob dialect, matched against a whole repo-relative path.

    `**/` is zero or more directories, a bare `**` is anything, and `*` and `?`
    never cross a `/`. Neither `fnmatch` (its `*` crosses `/`) nor
    `PurePath.match` (whose `**` handling differs between versions) gives that.
    """
    out, i = [], 0
    while i < len(pattern):
        if pattern.startswith("**/", i):
            out.append("(?:.*/)?")
            i += 3
        elif pattern.startswith("**", i):
            out.append(".*")
            i += 2
        elif pattern[i] == "*":
            out.append("[^/]*")
            i += 1
        elif pattern[i] == "?":
            out.append("[^/]")
            i += 1
        else:
            out.append(re.escape(pattern[i]))
            i += 1
    return re.compile("^" + "".join(out) + "$")


def compile_globs(patterns: list[str]) -> list[re.Pattern[str]]:
    """Translate each pattern, forgiving a leading `./` and native separators."""
    out = []
    for pattern in patterns:
        pattern = pattern.replace(os.sep, "/")
        out.append(glob_to_regex(pattern[2:] if pattern.startswith("./") else pattern))
    return out


def matches_any(path: str, patterns: list[re.Pattern[str]]) -> bool:
    return any(p.match(path) for p in patterns)


def walk_repo() -> list[str]:
    """Every tracked-shaped file in the repository, minus the exclusion set."""
    out = []
    for root, dirs, files in os.walk("."):
        dirs[:] = sorted(d for d in dirs if d not in PRUNE_DIRS)
        for name in sorted(files):
            out.append(rel(os.path.join(root, name)))
    return out


SELF_PATH = "scripts/move-modules.py"
# The fixture tests name made-up modules under real roots, in map rows as well as
# in file bodies; a rewrite would turn a fixture's `old -> new` row into
# `new -> new`. Excluded for the same reason as this file.
SELF_PATHS = {SELF_PATH, "scripts/test-move-modules.py"}


def classes_for(path: str) -> set[str]:
    """Which rewrite classes apply to this file, by extension and location."""
    if path in SELF_PATHS:
        return set()
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
                 sentinel: bool = False,
                 ns_mappings: list[NamespaceMapping] | None = None) -> str:
    """Apply classes 1-5 line by line, counting each class separately.

    With `sentinel`, every replacement is an opaque marker carrying no module
    name. Re-running the rewrite in that mode is how the bare-form audit
    distinguishes a bare citation that survived from one the rewrite created.
    """
    applicable = classes_for(path)
    ns_mappings = ns_mappings or []
    baseline_re = AXIOM_BASELINE_SITES.get(path) if ns_mappings else None
    if not applicable and not baseline_re:
        return text

    out_lines = []
    for line in text.splitlines(keepends=True):
        body = line.rstrip("\n")
        newline = line[len(body):]

        # Class 5 first: a baseline line is DATA, counted as a baseline rewrite
        # rather than folded into class 4's general namespace count.
        if baseline_re and baseline_re.match(body):
            body, n = apply_namespace(body, ns_mappings, sentinel)
            if n:
                counts["baseline"] += n
                files.setdefault("baseline", set()).add(path)
            out_lines.append(body + newline)
            continue

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
        if ns_mappings and applicable:
            body, n = apply_namespace(body, ns_mappings, sentinel)
            if n:
                counts["namespace"] += n
                files.setdefault("namespace", set()).add(path)

        out_lines.append(body + newline)
    return "".join(out_lines)


def apply_namespace(line: str, ns_mappings: list[NamespaceMapping],
                    sentinel: bool = False) -> tuple[str, int]:
    """Rewrite `namespace` / `open` / FQN occurrences from the namespace map."""
    total = 0
    for mapping in ns_mappings:
        new = SENTINEL if sentinel else mapping.new_ns
        line, n = mapping.dotted_re.subn(new, line)
        total += n
    return line, total


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


# The identical-sides check. A side is name-shaped: it contains a `/` or a `.`,
# optionally wrapped in backticks or quotes. The connector set is closed.
_SIDE = r"[`'\"]?([A-Za-z0-9_][A-Za-z0-9_./-]*)[`'\"]?"
CONNECTOR_RE = re.compile(
    _SIDE + r"(?:\s+(?:to|into)\s+|\s*(?:->|→|=>)\s*)" + _SIDE)


def side_pairs(line: str) -> list[tuple[str, str]]:
    """The two-sided constructs on one line, as (side, side) string pairs.

    Two constructs only: two name-shaped tokens joined by a connector, and a
    markdown table row -- every unordered pair of its non-empty cells, not only
    adjacent ones, because a provenance table puts its two path columns apart.
    """
    pairs = []
    for match in CONNECTOR_RE.finditer(line):
        left, right = (side.rstrip(".") for side in match.groups())
        if all("/" in side or "." in side for side in (left, right)):
            pairs.append((left, right))
    if line.lstrip().startswith("|"):
        cells = [cell.strip() for cell in line.split("|") if cell.strip()]
        pairs.extend((cells[i], cells[j]) for i in range(len(cells))
                     for j in range(i + 1, len(cells)))
    return pairs


def rewrite_fragment(path: str, fragment: str, mappings: list[Mapping],
                     ns_mappings: list[NamespaceMapping]) -> str:
    """Classes 2-4 applied to a fragment of a line from `path`, counting nothing."""
    applicable = classes_for(path)
    if "dotted" in applicable:
        fragment, _ = apply_regex(fragment, mappings, "dotted_re", "new_mod")
    if "slash" in applicable:
        fragment, _ = apply_regex(fragment, mappings, "slash_re", "new_path_slash")
    if ns_mappings and applicable:
        fragment, _ = apply_namespace(fragment, ns_mappings)
    return fragment


def identical_sides(path: str, before: str, after: str, mappings: list[Mapping],
                    ns_mappings: list[NamespaceMapping]) -> list[tuple[int, str, str]]:
    """Lines whose rewrite made two sides identical that differed before.

    A syntactic before/after comparison, not a tense detector: it catches
    `from X to Y` collapsing into `from Y to Y`, and nothing subtler. Sides are
    read from the BEFORE line and rewritten in isolation, which avoids aligning
    tokens across the two lines; a pair already identical before is not a
    finding. `rewrite_text` preserves lines, so the two texts zip by index.
    """
    hits = []
    for lineno, (old, new) in enumerate(zip(before.splitlines(),
                                            after.splitlines()), 1):
        if old == new:
            continue
        for left, right in side_pairs(old):
            if left != right and (rewrite_fragment(path, left, mappings, ns_mappings)
                                  == rewrite_fragment(path, right, mappings,
                                                      ns_mappings)):
                hits.append((lineno, old, new))
                break
    return hits


LINK_RE = re.compile(r"(?<=\]\()([^)\s]+)(?=[)\s])")

NON_PATH_PREFIXES = ("http://", "https://", "ftp://", "mailto:", "#", "/")


def map_repo_path(path: str, mappings: list[Mapping]) -> str:
    """Apply the path mapping to a repo-relative path, longest prefix first."""
    for mapping in mappings:
        old = mapping.old_path_slash
        if path == old or path.startswith(old + "/"):
            return mapping.new_path_slash + path[len(old):]
    return path


def rebase_links(path: str, text: str, mappings: list[Mapping],
                 stats: dict[str, int]) -> str:
    """Class 7 -- re-base relative links in a markdown file the mapping moves.

    Resolve-map-recompute, never `../`-counting: resolve the target against the
    file's OLD directory to a repo-relative path, apply the path mapping to that
    path, then recompute the relative path from the file's NEW directory. A
    heuristic that merely strips one `../` per level of depth change gets the
    cases wrong where the target itself stays put but the file's distance to the
    repository root changes in the other direction -- and those links generally
    sit outside the docs/ scope any link gate covers, so nothing would catch it.
    """
    old_dir = os.path.dirname(path)
    new_dir = os.path.dirname(map_repo_path(path, mappings))

    def replace(match: re.Match[str]) -> str:
        raw = match.group(1)
        target, sep, fragment = raw.partition("#")
        if not target or target.startswith(NON_PATH_PREFIXES):
            stats["skipped"] += 1
            return raw
        trailing = "/" if target.endswith("/") else ""
        resolved = os.path.normpath(os.path.join(old_dir, target))
        if not os.path.exists(resolved):
            # Not a link to anything in this tree: either an already-broken link
            # or a `](a)`-shaped regex false positive. Either way, not ours to
            # rewrite -- a relocation is not the place to repair a broken link.
            stats["skipped"] += 1
            return raw
        recomputed = rel(os.path.relpath(map_repo_path(rel(resolved), mappings),
                                         new_dir or "."))
        if recomputed + trailing == target:
            stats["unchanged"] += 1
            return raw
        stats["rebased"] += 1
        return recomputed + trailing + sep + fragment

    return LINK_RE.sub(replace, text)


class AmbiguousStem(Exception):
    """A mapping stem names BOTH a directory and a same-named `.lean` file."""

    def __init__(self, stem: str) -> None:
        self.directory = rel(stem) + "/"
        self.file = rel(stem) + ".lean"
        super().__init__(
            f"{rel(stem)} is ambiguous: both {self.directory} and {self.file} "
            f"exist. `Foo.lean` beside `Foo/` is the normal aggregator layout, and "
            f"one row cannot move both. Move the directory's contents with child "
            f"rows first, remove the emptied directory, then move the aggregator "
            f"file with its own row in a second invocation.")


def resolve_move(stem: str) -> tuple[str, str] | None:
    """The on-disk pair a mapping's extension-free stem names, or None.

    A mapping names a MODULE, and `module_to_path` returns that module's path
    stem without an extension. Two different things can sit at that stem, and
    both are legitimate map rows:

      - a DIRECTORY, when the row moves a whole subtree (`FormalSystem.Boneyard`);
      - a single `.lean` FILE, when the row moves one module
        (`FormalSystem.Automation.DataExport`).

    Only the directory case existed when this tool was written, and a
    file-granular row silently reported `skip ... (not present)` -- every
    citation rewritten, nothing moved, and a report that looked orderly.

    When BOTH exist the row is ambiguous and `AmbiguousStem` is raised, naming
    both. Preferring the directory, as this function once did, rewrote every
    citation of the aggregator file and then left the file behind.
    """
    if os.path.isdir(stem) and os.path.isfile(stem + ".lean"):
        raise AmbiguousStem(stem)
    if os.path.isdir(stem):
        return stem, ""
    if os.path.isfile(stem + ".lean"):
        return stem, ".lean"
    return None


def count_files(path: str) -> int:
    """Files at or under `path`: 1 for a module file, the whole subtree for a directory."""
    if os.path.isfile(path):
        return 1
    return sum(len(names) for _, _, names in os.walk(path))


def move_trees(mappings: list[Mapping],
               dry_run: bool) -> tuple[list[str], int, int]:
    """Class 6 -- relocate each mapped subtree or module with a single `git mv`.

    One `git mv`, never a delete-and-add: the rename is what lets
    `git log --follow` cross the relocation, which is the whole reason the
    archive keeps its history rather than reappearing as 225 new files.
    """
    moved, failures, file_total = [], 0, 0
    for mapping in mappings:
        # Backstop for the up-front scan in `run`. It can only fire in apply
        # mode -- a dry run moves nothing, so an ambiguity one row creates for a
        # later row never materialises on disk -- and when it fires the citation
        # writes have already happened. Loud, not a guarantee.
        try:
            resolved = resolve_move(mapping.old_path)
        except AmbiguousStem as exc:
            print(f"  FAIL {exc}", file=sys.stderr)
            failures += 1
            continue
        if resolved is None:
            print(f"  skip {mapping.old_path} (not present)")
            continue
        _, ext = resolved
        src, dst = mapping.old_path + ext, mapping.new_path + ext
        if not os.path.exists(src):
            print(f"  skip {src} (not present)")
            continue
        if os.path.exists(dst):
            print(f"  FAIL {dst} already exists; refusing to merge trees",
                  file=sys.stderr)
            failures += 1
            continue
        file_count = count_files(src)
        if dry_run:
            moved.append(f"{rel(src)} -> {rel(dst)}")
            file_total += file_count
            continue
        parent = os.path.dirname(dst)
        if parent and not os.path.isdir(parent):
            os.makedirs(parent, exist_ok=True)
        result = subprocess.run(["git", "mv", src, dst],
                                capture_output=True, text=True)
        if result.returncode != 0:
            print(f"  FAIL git mv {src} {dst}: {result.stderr.strip()}",
                  file=sys.stderr)
            failures += 1
            continue
        moved.append(f"{rel(src)} -> {rel(dst)}")
        file_total += file_count
    return moved, failures, file_total


def run_harness() -> int:
    """Closing step -- the invariant harness, exit code propagated verbatim."""
    print(f"\n=== {HARNESS} --no-build ===")
    return subprocess.run(["bash", HARNESS, "--no-build"]).returncode


def read_text(path: str) -> str | None:
    try:
        with open(path, encoding="utf-8") as handle:
            return handle.read()
    except (OSError, UnicodeDecodeError):
        return None


def run(args: argparse.Namespace) -> int:
    mappings = load_mappings(args.module_map)
    ns_mappings = ([NamespaceMapping(old, new)
                    for old, new in parse_map(args.namespace_map)]
                   if args.namespace_map else [])

    # Every stem is checked against the pre-move tree before anything is read or
    # written: no citation is rewritten for a move that is going to fail.
    ambiguous = 0
    for mapping in mappings:
        try:
            resolve_move(mapping.old_path)
        except AmbiguousStem as exc:
            print(f"FAIL  {exc}", file=sys.stderr)
            ambiguous += 1
    if ambiguous:
        return 1

    counts: dict[str, int] = {"import": 0, "dotted": 0, "slash": 0,
                              "namespace": 0, "baseline": 0}
    link_stats: dict[str, int] = {"rebased": 0, "unchanged": 0, "skipped": 0}
    files: dict[str, set[str]] = {}
    bare_before = bare_after = 0
    bare_files: set[str] = set()
    changed: list[tuple[str, str]] = []

    no_rewrite = compile_globs(list(DEFAULT_NO_REWRITE)
                               + (getattr(args, "no_rewrite", None) or []))
    skip_matched = 0
    skipped: list[tuple[str, int]] = []
    skipped_moved: list[str] = []
    side_warnings: list[str] = []

    for path in walk_repo():
        skip = matches_any(path, no_rewrite)
        if skip:
            skip_matched += 1
        if not classes_for(path) and path not in AXIOM_BASELINE_SITES:
            continue
        text = read_text(path)
        if text is None:
            continue
        if skip:
            # What the rewrite WOULD do, on throwaway counters: the class counts
            # below describe writes that happen, and none happens here. No class
            # 7 either, and no bare-form accounting -- with nothing written a
            # before/after delta is vacuous.
            would = dict.fromkeys(counts, 0)
            rewrite_text(path, text, mappings, would, {}, ns_mappings=ns_mappings)
            if sum(would.values()):
                skipped.append((path, sum(would.values())))
            if path.endswith(".md") and map_repo_path(path, mappings) != path:
                skipped_moved.append(path)
            continue
        # Class 7 runs FIRST, while the file is still at its old location: every
        # link target is resolved relative to where the file is now.
        if path.endswith(".md") and map_repo_path(path, mappings) != path:
            text_for_rewrite = rebase_links(path, text, mappings, link_stats)
            if text_for_rewrite != text:
                files.setdefault("link", set()).add(path)
        else:
            text_for_rewrite = text
        new_text = rewrite_text(path, text_for_rewrite, mappings, counts, files,
                                ns_mappings=ns_mappings)
        # The audit re-runs the SAME rewrite with opaque replacements, so a bare
        # citation the rewrite created is not mistaken for one it preserved. A
        # rule keyed on the bare token would consume pre-existing bare citations
        # and the two counts would diverge.
        sentinel_text = rewrite_text(path, text, mappings, dict(counts), {},
                                     sentinel=True, ns_mappings=ns_mappings)
        before = bare_form_count(text, mappings)
        after = bare_form_count(sentinel_text, mappings)
        bare_before += before
        bare_after += after
        if before:
            bare_files.add(path)
        if new_text != text:
            changed.append((path, new_text))
            # Here and not inside `rewrite_text`, which runs twice per file; and
            # only for files that will be written. Kept apart from the bare-form
            # audit above: no shared counter and no shared exit branch. The map
            # files reuse the `old -> new` separator but are never walked.
            for lineno, old, new in identical_sides(path, text, new_text, mappings,
                                                    ns_mappings):
                side_warnings.append(path)
                print(f"WARN  {path}:{lineno}: the rewrite made two sides of this "
                      f"line identical; if it states where something USED to be, "
                      f"revert it by hand\n        before: {old.strip()}\n"
                      f"        after:  {new.strip()}", file=sys.stderr)

    if not args.dry_run:
        for path, new_text in changed:
            with open(path, "w", encoding="utf-8") as handle:
                handle.write(new_text)

    moved, move_failures, moved_files = move_trees(mappings, args.dry_run)

    report(args, mappings, ns_mappings, counts, files, changed, moved,
           link_stats, bare_before, bare_after, len(bare_files), moved_files,
           skip_matched, skipped, skipped_moved, side_warnings)

    if bare_before != bare_after:
        print("\nFAIL  bare-form citations were rewritten; every rule must be "
              "anchored on the full old prefix", file=sys.stderr)
        return 1
    if move_failures:
        return 1
    if side_warnings and getattr(args, "strict", False):
        print(f"\nFAIL  {len(side_warnings)} identical-sides warning(s) under "
              f"--strict", file=sys.stderr)
        return 1
    if not moved:
        print("\nFAIL  rows were requested and nothing moved; every stem in the "
              "module map is absent from this tree", file=sys.stderr)
        return 1
    if args.dry_run or args.no_verify:
        return 0
    return run_harness()


def report(args: argparse.Namespace, mappings: list[Mapping],
           ns_mappings: list[NamespaceMapping], counts: dict[str, int],
           files: dict[str, set[str]], changed: list[tuple[str, str]],
           moved: list[str], link_stats: dict[str, int], bare_before: int,
           bare_after: int, bare_file_count: int, moved_files: int,
           skip_matched: int, skipped: list[tuple[str, int]],
           skipped_moved: list[str], side_warnings: list[str]) -> None:
    mode = "DRY RUN" if args.dry_run else "APPLIED"
    print(f"=== move-modules ({mode}) ===")
    for mapping in mappings:
        print(f"  map  {mapping}   ({mapping.old_path} -> {mapping.new_path})")
    for mapping in ns_mappings:
        print(f"  ns   {mapping}")
    print()
    labels = [("import", "class 1  import lines"),
              ("dotted", "class 2  dotted citations"),
              ("slash", "class 3  slash-path citations"),
              ("namespace", "class 4  namespace/open/FQN"),
              ("baseline", "class 5  axiom baselines")]
    for key, label in labels:
        print(f"  {label:<34} {counts[key]:>5} occurrence(s) in "
              f"{len(files.get(key, ())):>4} file(s)")
    print(f"  {'class 6  tree moves':<34} {len(moved):>5} path(s)")
    for line in moved:
        print(f"           {line}")
    scanned = sum(link_stats.values())
    print(f"  {'class 7  relative links':<34} {link_stats['rebased']:>5} "
          f"re-based in {len(files.get('link', ())):>4} file(s)")
    print(f"           {link_stats['unchanged']} unchanged, "
          f"{link_stats['skipped']} skipped (not a path in this tree), "
          f"{scanned} scanned")
    print()
    rewritten = sum(counts.values())
    # One line, so the two figures cannot be read apart: a run that rewrites
    # hundreds of citations and moves nothing looks orderly class by class.
    print(f"  {'files moved':<34} {moved_files:>5} in {len(moved)} path(s), against "
          f"{rewritten} citation(s) rewritten (classes 1-5)")
    print(f"  audit    bare-form occurrences        {bare_before:>5} before, "
          f"{bare_after:>5} after, in {bare_file_count} file(s)")
    print(f"  files changed                         {len(changed):>5}")
    print(f"  {'warnings identical-sides':<34} {len(side_warnings):>5} warning(s) in "
          f"{len(set(side_warnings))} file(s)")
    print()
    print(f"  {'skipped  --no-rewrite':<34} {skip_matched:>5} file(s) matched, "
          f"{len(skipped)} would have been rewritten (review by hand)")
    for path, would in skipped:
        print(f"           {path}  ({would} occurrence(s))")
    if skipped_moved:
        print("  skipped AND moved: relative links not re-based")
        for path in skipped_moved:
            print(f"           {path}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        prog="move-modules.py",
        description="Relocate Lean modules and rewrite every citation of them.")
    parser.add_argument("--module-map", required=True,
                        help="file of `old.module -> new.module` lines")
    parser.add_argument("--namespace-map",
                        help="optional file of `Old.Ns -> New.Ns` lines")
    parser.add_argument("--no-rewrite", action="append", metavar="PATH_OR_GLOB",
                        help="repeatable; files that are reported but never "
                             "written, by any class. Values ADD to the built-in "
                             "defaults (" + ", ".join(DEFAULT_NO_REWRITE) + "); "
                             "nothing clears the defaults. `**/` matches zero or "
                             "more directories; `*` and `?` never cross a `/`")
    parser.add_argument("--strict", action="store_true",
                        help="exit non-zero on any identical-sides warning (a "
                             "rewrite that turns `from X to Y` into `from Y to Y`, "
                             "in a sentence or a table row)")
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
