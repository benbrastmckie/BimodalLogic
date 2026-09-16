#!/usr/bin/env bash
# check-module-invariants.sh
#
# Phase-gate harness for the Lean source tree. Turns "the reorganization did not
# break anything" into a single command with a non-zero exit on any failure.
#
# Checks:
#   B0  Boneyard exclusion self-test (the single archive must be found and excluded)
#   C1  `lake build` exits 0
#   C2  `#print axioms` for the four flagship theorems matches the recorded baseline
#   C3  ZERO structural `sorry`, asserted BY CONTENT (never by line number)
#   C4  Every `import FormalSystem.*` / `import BimodalTest.*` resolves to a real file
#   C5  Every module-shaped `FormalSystem.*` path in non-specs markdown resolves
#   C6  Known-unreachable live modules still compile (rot guard)
#   C7  Live inventory (informational, never asserted)
#   C8  Aggregator convention: sibling `X.lean` beside `X/`, no `X/X.lean`
#       Walked parents: FormalSystem/, FormalSystem/Metalogic/, FormalSystem/Syntax/
#   C9  Zero task-number citations under FormalSystem/, lakefile.lean, README.md,
#       and scripts/
#   C10 Zero references to the pre-relocation docs/latex/typst paths
#   C11 Every import inside FormalSystem/Boneyard/ resolves, or is waived
#   C12 Every slash-shaped source path in docs/ + README.md resolves
#   C13 Every relative markdown link in docs/ + README.md resolves
#   C14 Documented axiom/sorry counts match the tree -- in docs/, README.md AND
#       FormalSystem/**/*.lean docstrings; and the axiom set of every declaration
#       C2 does not cover matches its baseline, including every subject of a
#       SORRY-FREE claim in FormalSystem/Metalogic.lean
#   C15 Every paper-anchor citation in live scope resolves against the pinned
#       record (manifest row, or an explicit KNOWN-ANCHORS row); and, as a second
#       independent assertion, every docs/theorem-index.md row carries its anchor
#       (or the literal `Paper: —` plus a reason) at the declaration itself
#   C16 Batteries env_linter batch (simpNF, docBlame, unusedArguments, ...) has no
#       finding beyond scripts/nolints.json's grandfathered baseline; dupNamespace
#       reported via a live textual (namespace-nesting) approximation, never gated
#   C17 Dead-declaration scan: base identifiers with zero occurrences outside their
#       own declaring line, across FormalSystem/ + Tests/ + repo-wide markdown
#       (REPORTED, not gated)
#   C18 Duplicated prose across README.md, FormalSystem/README.md,
#       FormalSystem/Metalogic/README.md and FormalSystem/Metalogic.lean, at two
#       granularities: whole paragraphs, and sentences of 15+ words
#       (REPORTED, not gated)
#   C19 Docstring-coverage floor (90%), G-12 heuristic refined with a /-!
#       section-comment credit (REPORTED, not gated; 90% floor, never fails)
#   C20 file.lean:NNN citations: tier 1 gates any that is out of range or lands
#       on a blank line (repo-wide); tier 2 reports any at all in
#       publication-facing scope, gated by ENFORCE_C20=1
#   C21 Every declaration named in FormalSystem/MainResults.lean is axiom-pinned by
#       C2 or C14 -- a subset assertion over the two existing baselines, NOT a third
#       baseline
#   C22 The two deliberately-duplicated `allAxiomNames` lists agree
#   C23 Naming regressions: zero live `lemma`, no Uppercase_x name outside the two
#       recorded classes, no new outer-shadows-inner bare-declaration pair. Computed
#       by EXTENDING C16's namespace walker, not by a fourth scanner
#   C24 Every module in the FormalSystem root closure transitively imports
#       FormalSystem.Init, via `lake exe checkInitImports` -- the root file is the
#       single place repository-wide linter options and tactic imports are
#       inherited from, so a module with no path to it silently opts out
#   C25 Every `lean_exe` root declared in lakefile.lean compiles -- the root list
#       is scraped at run time, so a newly declared executable is covered the day
#       it is added and there is no list to forget
#   C9D Task-number citations under docs/ (computed always, soft by default)
#   INV Every `<!-- BEGIN GENERATED: inventory -->` block in the tree is current
#
# Every filesystem traversal excludes the archive via `-not -path '*/Boneyard/*'`.
# The archive was consolidated into a single tree at `FormalSystem/Boneyard/`; the
# former second archive at `Metalogic/WeakCanonical/Kamp/Boneyard/` (63 files /
# 29,256 lines) now lives at `Boneyard/Kamp/KampWeakCanonical/`. B0 asserts the
# directory count is exactly 1, so a second archive reappearing anywhere under
# `FormalSystem/` fails the gate instead of silently splitting the counts again --
# which is what happened before, and is why the name glob (not a path prefix) is
# what the traversals filter on.
#
# Usage:
#   bash scripts/check-module-invariants.sh            # all checks
#   bash scripts/check-module-invariants.sh --no-build # skip C1/C2/C6/C16/C24/C25 (fast structural pass)
#   bash scripts/check-module-invariants.sh --emit-inventory          # rewrite generated inventory blocks
#   bash scripts/check-module-invariants.sh --emit-inventory --check  # fail if a rewrite would change a byte
#
# Companion files:
#   scripts/module-invariants-manifest.txt   known-unreachable live modules (C6)
#   scripts/module-invariants-allowlist.txt  pre-existing unresolved md paths (C5)
#   scripts/boneyard-import-waivers.txt    unrepairable archived imports (C11)
#   scripts/markdown-slash-path-allowlist.txt  hypothetical slash paths (C12)
#   scripts/markdown-link-allowlist.txt        link-syntax-illustration files (C13)
#   specs/paper-definitions-of-record.md       pinned paper anchors + known-anchor rows (C15)
#   scripts/nolints.json                       grandfathered env_linter findings (C16)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

MANIFEST="scripts/module-invariants-manifest.txt"
ALLOWLIST="scripts/module-invariants-allowlist.txt"
WAIVERS="scripts/boneyard-import-waivers.txt"
SLASH_ALLOWLIST="scripts/markdown-slash-path-allowlist.txt"
LINK_ALLOWLIST="scripts/markdown-link-allowlist.txt"

# scripts/lib/ is on sys.path for the python passes below; keep the tree clean.
export PYTHONDONTWRITEBYTECODE=1

RUN_BUILD=1
[ "${1:-}" = "--no-build" ] && RUN_BUILD=0

# ---------------------------------------------------------------------------
# --emit-inventory: the generated-count owner
#
# Hand-maintained module inventory tables drift the moment a file is added,
# split or renamed, and nothing in the tree noticed: 40 of 72 per-file line
# counts were wrong when this mode was written, and one README listed five files
# that had moved to another directory. Counts are therefore machine-owned. A
# markdown file opts in by wrapping its table in
#
#     <!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation -->
#     ... table ...
#     <!-- END GENERATED -->
#
# and this mode rewrites every column except the hand-written trailing one.
#
# Marker options (all optional except dir=):
#   dir=<path>              directory the inventory covers, repo-relative
#   rows=loose|subdirs|both|totals
#                           which rows to emit (default both); `totals` emits the
#                           live/archived file and line rollup for dir= instead
#                           of a per-file listing. When dir= is the archive itself
#                           -- any path with a `Boneyard` component -- `totals`
#                           emits ARCHIVE-shaped rows instead of live-shaped ones:
#                           archived file count, archived line count, top-level
#                           subdirectory count, and the repository's
#                           archive-directory count (the same figure B0 asserts).
#                           Live-shaped rows would be a category error there: with
#                           dir=FormalSystem/Boneyard the "live" and "archived"
#                           sets are the same files, so the block would label
#                           archived code as live.
#   empty=skip|include      whether a subdirectory with no `.lean` members gets a
#                           subdirs row (default skip). The archive's README-only
#                           tombstone subtrees are real inventory entries -- the
#                           code was deleted and the README retained as the
#                           historical record -- so the archive's table sets
#                           `empty=include` and they are listed with a zero count
#                           rather than silently dropped.
#   filter=all|aggregators|non-aggregators
#                           restrict the loose rows; an aggregator is a loose
#                           `X.lean` with a sibling directory `X/` (default all)
#   cols=lines|files-lines  one numeric column (lines) or two (file count then
#                           line count, for directory-shaped tables)
#   desc=yes|no             emit the trailing hand-written column (default yes)
#   link=yes|no             render a subdirectory row as a link to its README
#                           when one exists (default no)
#   sort=name|lines-desc    row order (default name)
#
# The trailing column is HAND-WRITTEN and survives regeneration: rows are keyed
# on the file or directory name, so an existing description is carried across
# verbatim. A newly-appeared file gets `<!-- TODO: add description -->`; a row
# whose file no longer exists is dropped. A row naming a file outside the
# scanned directory (`../FormalSystem.lean`) is kept as a pinned row with its
# numbers refreshed, as long as the path still resolves.
#
# A table that is deliberately NOT generated -- one ordered by the layering rather
# than alphabetically, or carrying no counts at all -- registers itself instead with
#
#     <!-- INVENTORY: hand-maintained (dir=FormalSystem/Semantics) -->
#
# placed immediately above it. Registration buys exemption from generation, never
# from being checked: this mode still asserts that such a table has a row for every
# live file and subdirectory and no row for anything else.
#
# Two modes:
#   --emit-inventory           rewrite every registered block in place
#   --emit-inventory --check   exit non-zero if a rewrite would change a byte
#
# Only --check belongs in CI. The writer is a developer command.
if [ "${1:-}" = "--emit-inventory" ]; then
  EMIT_CHECK=0
  if [ "${2:-}" = "--check" ]; then EMIT_CHECK=1; fi
  export EMIT_CHECK
  python3 - <<'PYEOF'
import os, re, sys

sys.path.insert(0, os.path.join("scripts", "lib"))
from live_walk import live_loose_files, live_subdirs, live_files, line_count, classify_lines

CHECK = os.environ.get("EMIT_CHECK") == "1"

BEGIN_RE = re.compile(r'^<!--\s*BEGIN GENERATED:\s*inventory\s*(?P<opts>[^>]*?)\s*-->\s*$')
END_RE = re.compile(r'^<!--\s*END GENERATED\s*-->\s*$')
HAND_RE = re.compile(r'^<!--\s*INVENTORY:\s*hand-maintained\s*\(dir=(?P<dir>[^)\s]+)\)')
SEP_CELL_RE = re.compile(r'^:?-{2,}:?$')
LINK_RE = re.compile(r'^\[(?P<label>.*)\]\((?P<href>[^)]*)\)$')
TODO_DESC = "<!-- TODO: add description -->"


def markdown_targets():
    """Every markdown file the generator is allowed to touch.

    `Boneyard` is deliberately NOT pruned here, although every *source* traversal
    in this harness excludes it by name. The archive's README owns the archive's
    own counts, and pruning it made that README the one README in the tree whose
    numbers were hand-typed and ungated -- which is exactly how three mutually
    disagreeing archive file counts came to ship. Walking it costs nothing on a
    tree with no markers: this walk gains the archive's markdown files, and only
    the ones that actually carry a BEGIN GENERATED or INVENTORY marker do any work.
    """
    out = []
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs
                   if d not in (".git", "specs", ".claude", ".lake", "node_modules")]
        for f in files:
            if f.endswith(".md"):
                out.append(os.path.normpath(os.path.join(root, f)))
    return sorted(out)


def parse_opts(raw):
    opts = {}
    for tok in raw.split():
        if "=" in tok:
            k, v = tok.split("=", 1)
            opts[k] = v
    return opts


def split_row(line):
    body = line.strip()
    if not body.startswith("|"):
        return None
    body = body[1:]
    if body.endswith("|"):
        body = body[:-1]
    return [c.strip() for c in body.split("|")]


def row_key(cell):
    cell = cell.strip()
    m = LINK_RE.match(cell)
    if m:
        cell = m.group("label").strip()
    return cell.strip("`").strip()


def is_separator(cells):
    return bool(cells) and all(SEP_CELL_RE.match(c.replace(" ", "")) for c in cells if c != "")


def is_archive_base(directory):
    """True when `directory` is itself the archive, or lives inside it.

    Tested on the directory NAME, never a path prefix -- the same rule ADR-005
    fixed and B0 asserts. A scan rooted at the archive must not describe its
    contents as live: `live_files` only prunes subdirectories *named* Boneyard,
    so with dir=FormalSystem/Boneyard it returns all 168 archived files and would
    label every one of them live.
    """
    parts = os.path.normpath(directory).split(os.sep)
    return "Boneyard" in parts


def archive_dir_count(root="FormalSystem"):
    """Directories named `Boneyard` anywhere under `root` -- the figure B0 asserts."""
    n = 0
    for _r, dirs, _f in os.walk(root):
        n += sum(1 for d in dirs if d == "Boneyard")
    return n


def scan(directory, opts):
    """Return [(key, [numeric cells...], link_target_or_None)] for `directory`."""
    rows = opts.get("rows", "both")
    filt = opts.get("filter", "all")
    cols = opts.get("cols", "lines")
    want_link = opts.get("link", "no") == "yes"
    keep_empty = opts.get("empty", "skip") == "include"

    subdir_names = {os.path.basename(p) for p in live_subdirs(directory)}
    out = []
    if rows == "totals":
        if is_archive_base(directory):
            archived = live_files(directory, ".lean")
            out.append(("Archived `.lean` files", ["{:,}".format(len(archived))], "literal"))
            out.append(("Archived lines",
                        ["{:,}".format(sum(line_count(f) for f in archived))], "literal"))
            out.append(("Top-level subdirectories",
                        ["{:,}".format(len(live_subdirs(directory)))], "literal"))
            out.append(("Archive directories in the repository",
                        ["{:,}".format(archive_dir_count())], "literal"))
            return out
        live = live_files(directory, ".lean")
        archived = [f for f in
                    (os.path.join(r, n)
                     for r, _d, ns in os.walk(directory) for n in ns)
                    if f.endswith(".lean") and (os.sep + "Boneyard" + os.sep) in f]
        code_total = comment_total = 0
        for f in live:
            c, k = classify_lines(f)
            code_total += c
            comment_total += k
        out.append(("Live `.lean` files", ["{:,}".format(len(live))], "literal"))
        out.append(("Live lines of code", ["{:,}".format(code_total)], "literal"))
        out.append(("Live comment lines", ["{:,}".format(comment_total)], "literal"))
        if archived:
            out.append(("Archived `.lean` files", ["{:,}".format(len(archived))], "literal"))
            out.append(("Archived lines",
                        ["{:,}".format(sum(line_count(f) for f in archived))], "literal"))
        return out
    if rows in ("loose", "both"):
        for path in live_loose_files(directory, ".lean"):
            name = os.path.basename(path)
            stem = name[:-len(".lean")]
            is_agg = stem in subdir_names
            if filt == "aggregators" and not is_agg:
                continue
            if filt == "non-aggregators" and is_agg:
                continue
            nums = ["{:,}".format(line_count(path))]
            if cols == "files-lines":
                nums = ["1"] + nums
            out.append((name, nums, None))
    if rows in ("subdirs", "both"):
        for sub in live_subdirs(directory):
            members = live_files(sub, ".lean")
            if not members and not keep_empty:
                continue
            key = os.path.basename(sub) + "/"
            total = sum(line_count(m) for m in members)
            if cols == "files-lines":
                nums = [str(len(members)), "{:,}".format(total)]
            else:
                nums = ["—"]
            link = None
            if want_link and os.path.isfile(os.path.join(sub, "README.md")):
                link = os.path.basename(sub) + "/README.md"
            out.append((key, nums, link))
    return out


def render_block(opts, existing_lines):
    directory = opts.get("dir")
    if not directory:
        raise SystemExit("emit-inventory: BEGIN marker has no dir= option")
    if not os.path.isdir(directory):
        raise SystemExit("emit-inventory: dir=%s does not exist" % directory)
    cols = opts.get("cols", "lines")
    want_desc = opts.get("desc", "yes") != "no"
    ncols = (2 if cols == "files-lines" else 1) + 1 + (1 if want_desc else 0)

    header = None
    sep = None
    descriptions = {}
    order = []
    for ln in existing_lines:
        cells = split_row(ln)
        if cells is None or len(cells) < 2:
            continue
        if is_separator(cells):
            sep = ln.rstrip()
            continue
        if header is None and not order:
            header = ln.rstrip()
            continue
        key = row_key(cells[0])
        if want_desc:
            descriptions[key] = cells[-1].strip() if len(cells) >= ncols else TODO_DESC
        order.append(key)
    if header is None:
        header = "| File | Lines |" + (" Description |" if want_desc else "")
    if sep is None:
        sep = "|------|------:|" + ("-------------|" if want_desc else "")

    scanned = scan(directory, opts)
    scan_keys = {k for k, _, _ in scanned}

    # Pinned rows: an existing row naming a path outside the scan that still
    # resolves (e.g. `../FormalSystem.lean`) is kept, with its numbers refreshed.
    pinned = []
    for key in order:
        if key in scan_keys or key.endswith("/"):
            continue
        resolved = os.path.normpath(os.path.join(directory, key))
        if os.path.isfile(resolved):
            nums = ["{:,}".format(line_count(resolved))]
            if cols == "files-lines":
                nums = ["1"] + nums
            pinned.append((key, nums, None))

    rows = pinned + scanned
    if opts.get("sort") == "lines-desc":
        def size_of(r):
            raw = r[1][-1].replace(",", "")
            return int(raw) if raw.isdigit() else -1
        rows = sorted(rows, key=lambda r: (-size_of(r), r[0]))

    out = [header, sep]
    for key, nums, link in rows:
        if link == "literal":
            # A rollup row: the first cell is a metric name, not a path.
            label = key
        elif link:
            label = "[`%s`](%s)" % (key, link)
        else:
            label = "`%s`" % key
        cells = [label] + nums
        if want_desc:
            cells.append(descriptions.get(key, TODO_DESC))
        out.append("| " + " | ".join(cells) + " |")
    return out


def audit_hand_maintained(target, lines):
    """A table registered as hand-maintained must still be exhaustive.

    Registration buys exemption from *generation* (a deliberate reading order, no
    line counts), never from being checked: the failure mode a hand table has left
    is a file that appeared or moved and never made it into the list.
    """
    problems = []
    for i, ln in enumerate(lines):
        m = HAND_RE.match(ln.strip())
        if not m:
            continue
        directory = m.group("dir")
        j = i
        while j < len(lines) and not lines[j].strip().startswith("|"):
            j += 1
        have = set()
        while j < len(lines) and lines[j].strip().startswith("|"):
            cells = split_row(lines[j])
            if cells and not is_separator(cells):
                have.add(row_key(cells[0]))
            j += 1
        want = {os.path.basename(f) for f in live_loose_files(directory, ".lean")}
        want |= {os.path.basename(d) + "/" for d in live_subdirs(directory)
                 if live_files(d, ".lean")}
        for missing in sorted(want - have):
            problems.append("%s: %s is live but has no row" % (target, missing))
        for phantom in sorted(k for k in have - want if k.endswith((".lean", "/"))):
            problems.append("%s: row `%s` names nothing live" % (target, phantom))
    return problems


changed = []
hand_problems = []
for target in markdown_targets():
    with open(target, encoding="utf-8") as fh:
        lines = fh.read().split("\n")
    hand_problems.extend(audit_hand_maintained(target, lines))
    out = []
    i = 0
    touched = False
    in_fence = False
    while i < len(lines):
        if lines[i].lstrip().startswith("```"):
            in_fence = not in_fence
        m = None if in_fence else BEGIN_RE.match(lines[i])
        if not m:
            out.append(lines[i]); i += 1; continue
        begin = lines[i]
        j = i + 1
        body = []
        while j < len(lines) and not END_RE.match(lines[j]):
            body.append(lines[j]); j += 1
        if j >= len(lines):
            raise SystemExit("emit-inventory: %s has an unterminated BEGIN GENERATED block" % target)
        new_body = render_block(parse_opts(m.group("opts")), body)
        out.append(begin)
        out.extend(new_body)
        out.append(lines[j])
        if new_body != body:
            touched = True
        i = j + 1
    if not touched:
        continue
    changed.append(target)
    if not CHECK:
        with open(target, "w", encoding="utf-8") as fh:
            fh.write("\n".join(out))

if CHECK:
    if hand_problems:
        print("FAIL  INV  %d hand-maintained inventory row problem(s)" % len(hand_problems))
        for m in hand_problems:
            print("            %s" % m)
        if not changed:
            sys.exit(1)
    if changed:
        print("FAIL  INV  %d file(s) carry a stale generated inventory block" % len(changed))
        for t in changed:
            print("            %s" % t)
        print("            run: bash scripts/check-module-invariants.sh --emit-inventory")
        sys.exit(1)
    print("PASS  INV  every generated inventory block is current, "
          "every hand-maintained one is exhaustive")
    sys.exit(0)

if changed:
    print("rewrote %d file(s):" % len(changed))
    for t in changed:
        print("  %s" % t)
else:
    print("no generated inventory block needed a rewrite")
sys.exit(0)
PYEOF
  exit $?
fi


# Enforcement flags. C8/C9/C10 describe end-state invariants that the tree does
# not satisfy until the corresponding reorganization work lands. Each is computed
# and reported from the outset -- so progress is visible at every gate -- but only
# becomes exit-code-affecting once its flag flips to 1. Never flip a flag to 0 to
# make a gate pass; that is what the flag exists to prevent.
ENFORCE_C8=${ENFORCE_C8:-1}   # aggregator convention (enforced)
ENFORCE_C9=${ENFORCE_C9:-1}   # no task-number citations under FormalSystem/ (enforced)
ENFORCE_C10=${ENFORCE_C10:-1} # no stale docs/latex/typst paths (enforced)
# C9D is the C9 rule applied to docs/, which does not yet satisfy it. Computed and
# reported from the outset; flip to 1 once docs/development/PHASED_IMPLEMENTATION.md
# and the smaller residue are cleared.
ENFORCE_C9_DOCS=${ENFORCE_C9_DOCS:-0} # no task-number citations under docs/ (NOT yet enforced)
# C16 gates the Batteries env_linter batch (defsWithUnderscore, docBlame, simpNF,
# structureInType, tacticDocs, unusedArguments -- everything `lake exe runLinter`/the
# configured `lintDriver` checks). scripts/nolints.json grandfathers 217 findings, all
# of them `unusedArguments` (the sole permanently-grandfathered category; every other
# category was burned down to genuine conformance rather than suppressed). A clean run
# here therefore means "no NEW finding", not "the tree has zero findings" -- exactly
# CI's own `lake lint` gate. Enforced from the
# outset because nolints.json makes it genuinely green today, unlike C8/C9/C10 above.
ENFORCE_C16=${ENFORCE_C16:-1} # env_linter batch has no un-nolisted finding (enforced)
# C20 tier 2 asks every publication-facing surface to cite declaration names rather
# than file:line. The scope is clean, so this is enforced. Never flip it back to 0 to
# quiet a new citation; remove the citation instead.
ENFORCE_C20=${ENFORCE_C20:-1} # no file:line citations in publication scope (enforced)
# C21 asserts that every result the main-results page advertises has its axiom set pinned by
# one of the two baselines this script already carries. The scope is clean the day the page is
# written, so this is enforced from the outset. Never flip it back to 0 to quiet a new name;
# either pin the declaration in the C14 baseline pair or take it off the page.
ENFORCE_C21=${ENFORCE_C21:-1} # MainResults.lean names are all axiom-pinned (enforced)
# C23 gates the three naming classes this repository burned down: `lemma` declarations,
# Uppercase_x names whose prefix is a real declaration, and outer-shadows-inner base
# identifier collisions. All three are at zero outside their recorded exception sets, so
# this is enforced. Never flip it to 0; add a reasoned entry to the in-scanner exception
# set instead, where the reason is read alongside the name it exempts.
ENFORCE_C23=${ENFORCE_C23:-1} # naming regressions (enforced)
# C24 asserts that every module in the FormalSystem root closure transitively imports
# FormalSystem.Init, the root file repository-wide linter options and tactic imports are meant
# to be inherited from. The adoption work landed in the same change that added this check, so
# it is green from its first run and ships enforced with no soft period -- a soft window here
# would only be a window in which the invariant could regress unnoticed. Never flip it to 0 to
# quiet a failure; add the import at the offending module's own minimal element, or record a
# genuinely-cannot-import module in `exceptions` in scripts/CheckInitImports.lean.
ENFORCE_C24=${ENFORCE_C24:-1} # every module transitively imports FormalSystem.Init (enforced)
# C25 compile-checks every `lean_exe` root declared in lakefile.lean. Those roots sit outside
# both library root closures, so `lake build` never elaborates them and C24's closure walk never
# reaches them -- ProofStepExport.lean was failing to elaborate with no gate anywhere able to
# observe it. The repair landed in the same change that added this check, so all thirteen roots
# are green from its first run and it ships enforced with no soft period. Never flip it to 0 to
# quiet a failure; repair the root, or delete the `lean_exe` target if it is genuinely dead.
ENFORCE_C25=${ENFORCE_C25:-1} # every lean_exe root module compiles (enforced)
# C26 asserts, by reading the SOURCE TEXT rather than an imported environment, that no live
# `def` or `abbrev` carries an underscore inside its own name component, and that every in-source
# `nolint` attribute is on scripts/nolint-attribute-allowlist.txt. Both halves exist because
# `defsWithUnderscore` -- the env_linter C16 runs -- has four structural blind spots, each of
# which let the category reopen with every standing gate green. They are recorded in
# docs/development/NAMING_CONVENTION_DEVIATION.md and each is closed by a specific property of
# this check:
#   (1) OUT-OF-CLOSURE MODULES. `runLinter FormalSystem` observes only the FormalSystem library
#       closure. A module reachable only from a `lean_exe` root is never elaborated by it. C26
#       walks the TREE and consults no import closure at all, so such a module is as visible to
#       it as any other file.
#   (2) IN-SOURCE `nolint` ATTRIBUTES. An `attribute [nolint X] foo` produces no finding, so
#       there is nothing for runLinter, CI, a scripts/nolints.json baseline diff or C16 to count
#       -- unlike a JSON entry, which is at least a reviewable line. The second half below turns
#       every such attribute back into a line in a reviewable file.
#   (3) THE UPSTREAM `_1`/`_2`/`_mathlib` HEURISTIC. Mathlib's `isBadNameWithUnderscore` skips
#       any name whose last component ends in `_1`, `_2` or `_mathlib`, on the assumption that
#       such a name is an autogenerated instance. The exemption is invisible at the declaration
#       site. C26 deliberately does NOT inherit that heuristic.
#   (4) `private` DECLARATIONS. An env_linter reads a package by IMPORTING it, and a non-public
#       declaration is not exported to an importing module -- probed directly, the environment of
#       `import FormalSystem` holds zero non-auto private declarations from FormalSystem modules.
#       This is an upstream property of the observation mechanism, which Mathlib shares; it
#       cannot be fixed by configuring runLinter differently. A textual scan has no such blind
#       spot, so `private` declarations are in scope here.
# Ships ENFORCED with no soft window, on the C24/C25 precedent: both halves are green on the tree
# the day the check lands (zero flagged names, zero unlisted attributes), so a soft period would
# only be a window in which the invariant could regress unnoticed. Never flip it to 0 to quiet a
# failure: rename the declaration, or -- for an attribute -- add a reasoned entry to
# scripts/nolint-attribute-allowlist.txt, where the reason is read alongside the name it exempts.
ENFORCE_C26=${ENFORCE_C26:-1} # no snake_case def/abbrev, no unlisted nolint attribute (enforced)
# C16's second half widens the env_linter batch beyond the single `FormalSystem` library root to
# every root declared in lakefile.lean -- the other library root and all thirteen `lean_exe`
# roots -- because `runLinter FormalSystem` observes only the FormalSystem closure and a module
# reachable only from an exe root is invisible to it. That is the same blind spot C26's textual
# scan closes for declared names; this half is what closes it for shapes only ELABORATION can
# judge, above all auto-generated structure-field projections, where whether an underscored name
# is a violation depends on whether the field's type is a Prop.
# NOT YET ENFORCED, on a measurement rather than a preference: the widened target carries 179
# pre-existing findings today (see the C16 header for the per-root numbers), so enforcing it now
# would turn the gate red on work this check's own change does not own. It is computed and
# printed at every gate instead, on the ENFORCE_C9_DOCS model, so the debt is visible rather
# than either force-passed or blocking. Flip to 1 once the count reaches zero.
ENFORCE_C16_ROOTS=${ENFORCE_C16_ROOTS:-0} # env_linter batch over EVERY lakefile root (NOT yet enforced)

FAILURES=0
pass() { printf 'PASS  %-4s %s\n' "$1" "$2"; }
fail() { printf 'FAIL  %-4s %s\n' "$1" "$2"; FAILURES=$((FAILURES + 1)); }
info() { printf 'INFO  %-4s %s\n' "$1" "$2"; }
note() { printf '            %s\n' "$1"; }
# Report a not-yet-enforced check: visible, but does not affect the exit code.
soft() { printf 'TODO  %-4s %s\n' "$1" "$2"; }

# Shared find filter. The archive is excluded by the `*/Boneyard/*` name glob;
# B0 asserts that this pattern matches exactly one directory.
live_lean() {
  find "$@" -name '*.lean' -not -path '*/Boneyard/*'
}

echo "=== Module invariants: $(git rev-parse --short HEAD 2>/dev/null || echo 'no-git') ==="
echo

# ---------------------------------------------------------------------------
# B0: Boneyard exclusion self-test
# ---------------------------------------------------------------------------
mapfile -t BONEYARDS < <(find FormalSystem -type d -name Boneyard | sort)
if [ "${#BONEYARDS[@]}" -eq 1 ]; then
  pass B0 "Boneyard exclusion covers exactly 1 directory"
  for b in "${BONEYARDS[@]}"; do note "$b"; done
else
  fail B0 "expected 1 Boneyard directory, found ${#BONEYARDS[@]}"
  for b in "${BONEYARDS[@]}"; do note "$b"; done
fi
# Prove the exclusion is load-bearing: archived files must not be in the live set.
ALL_LEAN=$(find FormalSystem -name '*.lean' | wc -l)
LIVE_LEAN=$(live_lean FormalSystem | wc -l)
if [ "$ALL_LEAN" -gt "$LIVE_LEAN" ]; then
  note "excluded $((ALL_LEAN - LIVE_LEAN)) archived .lean files ($ALL_LEAN total -> $LIVE_LEAN live)"
else
  fail B0 "exclusion filter removed nothing; archived files are leaking into live counts"
fi
echo

# ---------------------------------------------------------------------------
# C1: build
# ---------------------------------------------------------------------------
if [ "$RUN_BUILD" -eq 1 ]; then
  BUILD_LOG=$(mktemp)
  if lake build >"$BUILD_LOG" 2>&1; then
    pass C1 "lake build exits 0"
  else
    fail C1 "lake build failed"
    tail -40 "$BUILD_LOG" | while IFS= read -r l; do note "$l"; done
  fi
  if lake build BimodalTest >>"$BUILD_LOG" 2>&1; then
    pass C1 "lake build BimodalTest exits 0"
  else
    fail C1 "lake build BimodalTest failed"
    tail -40 "$BUILD_LOG" | while IFS= read -r l; do note "$l"; done
  fi
  rm -f "$BUILD_LOG"
else
  info C1 "skipped (--no-build)"
fi
echo

# ---------------------------------------------------------------------------
# C2: axiom sets for the four flagship theorems
#
# Do NOT scrape `lake build` stdout for these -- an incremental build may not
# re-emit them. A dedicated scratch file is compiled against the built library.
# ---------------------------------------------------------------------------
read -r -d '' AXIOM_BASELINE <<'BASELINE'
'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.derivable_of_validDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
BASELINE

if [ "$RUN_BUILD" -eq 1 ]; then
  AX_SRC=$(mktemp --suffix=.lean)
  cat >"$AX_SRC" <<'LEAN'
import FormalSystem
#print axioms FormalSystem.Metalogic.BXCanonical.completeness
#print axioms FormalSystem.Metalogic.BXCanonical.derivable_of_validDense
#print axioms FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime
#print axioms FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense
LEAN
  # The pretty-printer wraps at a fixed width, and `FormalSystem.` is longer than the
  # namespace it replaced, so a long axiom record now spills onto continuation lines that
  # begin with a space. Rejoin those before grepping, or the record is silently truncated
  # and C2 reports a divergence that is purely cosmetic.
  AX_OUT=$(lake env lean "$AX_SRC" 2>&1 \
    | sed -e ':a' -e '$!N' -e 's/\n / /' -e 'ta' -e 'P' -e 'D' \
    | grep 'depends on axioms')
  rm -f "$AX_SRC"
  if [ "$AX_OUT" = "$AXIOM_BASELINE" ]; then
    pass C2 "all four flagship axiom sets match baseline"
    while IFS= read -r l; do note "$l"; done <<<"$AX_OUT"
  else
    fail C2 "axiom sets diverged from baseline -- this is a HARD STOP, not a new baseline"
    note "--- expected ---"
    while IFS= read -r l; do note "$l"; done <<<"$AXIOM_BASELINE"
    note "--- actual ---"
    while IFS= read -r l; do note "$l"; done <<<"$AX_OUT"
  fi
else
  info C2 "skipped (--no-build)"
fi
echo

# ---------------------------------------------------------------------------
# C3: the structural sorry inventory, asserted BY CONTENT
#
# The inventory is ZERO. `FormalSystem/` (excluding `Boneyard/`) contains no
# structural `sorry` at all: the last one, `countermodel_discrete`, was closed
# when the theorem moved from `WeakCanonical/Transfer.lean` to
# `WeakCanonical/GroupModel/CountermodelBase.lean` and was proved there at the
# `Q x_l Z` carrier off `companionChronicle`.
#
# Never assert a line number, and never relax this back to a nonzero count to
# accommodate a new sorry: a new structural sorry is a regression, and this
# check is the gate that says so.
# ---------------------------------------------------------------------------
SORRY_HITS=$(grep -rnE --include='*.lean' \
  '(^[[:space:]]*sorry[[:space:]]*$)|(:=[[:space:]]*sorry[[:space:]]*$)|(\bexact sorry\b)|(<;> sorry)' \
  FormalSystem | grep -v '/Boneyard/')
SORRY_COUNT=$(printf '%s' "$SORRY_HITS" | grep -c . || true)

if [ "$SORRY_COUNT" -ne 0 ]; then
  fail C3 "expected zero structural sorries, found $SORRY_COUNT"
  while IFS= read -r l; do note "$l"; done <<<"$SORRY_HITS"
else
  pass C3 "structural sorry inventory is ZERO across FormalSystem/ (Boneyard/ excluded)"
fi
echo

# ---------------------------------------------------------------------------
# C4/C5/C6/C7/C8/C11: graph, markdown, reachability, archive and structure checks
# ---------------------------------------------------------------------------
[ "$RUN_BUILD" -eq 0 ] && export SKIP_BUILD=1
export ENFORCE_C8
python3 - "$MANIFEST" "$ALLOWLIST" "$WAIVERS" <<'PYEOF'
import os, re, sys, subprocess

manifest_path, allowlist_path, waivers_path = sys.argv[1], sys.argv[2], sys.argv[3]
failures = 0
def pas(c, m): print(f"PASS  {c:<4} {m}")
def bad(c, m):
    global failures
    failures += 1
    print(f"FAIL  {c:<4} {m}")
def inf(c, m): print(f"INFO  {c:<4} {m}")
def note(m):   print(f"            {m}")

BONEYARD = os.sep + "Boneyard"

# The Boneyard-excluding walk lives in scripts/lib/live_walk.py and is shared
# with the --emit-inventory generator, so the inventory tables and C7's rollup
# can never disagree about what "live" means.
sys.path.insert(0, os.path.join("scripts", "lib"))
from live_walk import live_files  # noqa: E402

def mod_to_path(m):
    base = "Tests" if m.split(".")[0] == "BimodalTest" else "."
    return os.path.normpath(os.path.join(base, *m.split("."))) + ".lean"

def path_to_mod(p):
    for base in ("Tests/", ""):
        if p.startswith(base):
            return p[len(base):-len(".lean")].replace(os.sep, ".")
    return None

lean_files = (live_files("FormalSystem", ".lean") + live_files("Tests", ".lean")
              + (["FormalSystem.lean"]
                 if os.path.isfile("FormalSystem.lean") else []))
imp_re = re.compile(r"^import\s+((?:FormalSystem|BimodalTest)(?:\.[A-Za-z0-9_]+)*)\s*$", re.M)

graph, texts = {}, {}
for p in lean_files:
    txt = open(p, encoding="utf-8", errors="replace").read()
    texts[p] = txt
    graph[path_to_mod(p)] = imp_re.findall(txt)

# --- C4: dangling imports ---------------------------------------------------
dangling = []
for p in lean_files:
    for i, line in enumerate(texts[p].splitlines(), 1):
        m = imp_re.match(line + "\n")
        if not m:
            continue
        tgt = m.group(1)
        if not os.path.isfile(mod_to_path(tgt)):
            dangling.append((p, i, tgt))
total_imports = sum(len(v) for v in graph.values())
if dangling:
    bad("C4", f"{len(dangling)} dangling import(s) across {total_imports} import lines")
    for p, i, t in dangling:
        note(f"{p}:{i}: import {t}  ->  {mod_to_path(t)} (missing)")
else:
    pas("C4", f"all {total_imports} FormalSystem/BimodalTest import lines resolve")

# --- C5: markdown module paths ---------------------------------------------
allow = set()
if os.path.isfile(allowlist_path):
    for line in open(allowlist_path, encoding="utf-8"):
        line = line.split("#")[0].strip()
        if line:
            allow.add(line)

md_files = []
for root, dirs, files in os.walk("."):
    dirs[:] = [d for d in dirs
               if d not in (".git", ".lake", "specs", "Boneyard", "build", "__pycache__")]
    for f in files:
        if f.endswith(".md"):
            md_files.append(os.path.relpath(os.path.join(root, f), "."))

mod_re = re.compile(r"\b(?:FormalSystem|BimodalTest)(?:\.[A-Z][A-Za-z0-9_]*)+")

def resolves(m):
    base = "Tests" if m.split(".")[0] == "BimodalTest" else "."
    p = os.path.normpath(os.path.join(base, *m.split(".")))
    return os.path.isfile(p + ".lean") or os.path.isdir(p)

unresolved, used_allow = [], set()
for p in sorted(md_files):
    for i, line in enumerate(open(p, encoding="utf-8", errors="replace"), 1):
        for m in mod_re.findall(line):
            if resolves(m):
                continue
            if m in allow:
                used_allow.add(m)
                continue
            unresolved.append((p, i, m))
if unresolved:
    bad("C5", f"{len(unresolved)} unresolved module path(s) in non-specs markdown")
    for p, i, m in unresolved:
        note(f"{p}:{i}: {m}")
else:
    pas("C5", f"all module-shaped paths in {len(md_files)} markdown files resolve"
              + (f" ({len(used_allow)} allowlisted)" if used_allow else ""))
stale_allow = allow - used_allow
if stale_allow:
    inf("C5", f"{len(stale_allow)} allowlist entr(y/ies) no longer occur; prune them")
    for m in sorted(stale_allow):
        note(m)

# --- reachability (feeds C6 and C7) ----------------------------------------
roots = ["FormalSystem", "BimodalTest"]
try:
    lf = open("lakefile.lean", encoding="utf-8").read()
    roots += re.findall(r"root\s*:=\s*`([A-Za-z0-9_.]+)", lf)
except OSError:
    pass
seen, stack = set(), list(roots)
while stack:
    m = stack.pop()
    if m in seen or m not in graph:
        continue
    seen.add(m)
    stack.extend(graph[m])
unreachable = sorted(set(graph) - seen)

# --- C6: unreachable-module rot guard --------------------------------------
# Manifest entries may carry a `broken:` prefix, meaning the module is known not
# to compile. Those are still tracked (so they cannot be forgotten) but are not
# compile-checked -- the rot already happened and is recorded, not re-discovered
# on every run. Removing the prefix is how a repaired module re-enters the gate.
manifest, manifest_broken = [], []
if os.path.isfile(manifest_path):
    for line in open(manifest_path, encoding="utf-8"):
        line = line.split("#")[0].strip()
        if not line:
            continue
        if line.startswith("broken:"):
            manifest_broken.append(line[len("broken:"):].strip())
        else:
            manifest.append(line)
manifest_set = set(manifest) | set(manifest_broken)
unmanifested = [m for m in unreachable if m not in manifest_set]
if unmanifested:
    bad("C6", f"{len(unmanifested)} unreachable live module(s) absent from {manifest_path}")
    for m in unmanifested:
        note(f"{m}  ->  {mod_to_path(m)}")
else:
    pas("C6", f"all {len(unreachable)} unreachable live module(s) are manifested")

phantom = [m for m in manifest_set if m not in graph]
if phantom:
    bad("C6", f"{len(phantom)} manifest entr(y/ies) name a module that does not exist")
    for m in sorted(phantom):
        note(m)

stale_manifest = sorted(m for m in manifest_set if m in seen)
if stale_manifest:
    bad("C6", f"{len(stale_manifest)} manifest entr(y/ies) name a REACHABLE module; "
              f"`lake build` already guards these -- delete the lines")
    for m in stale_manifest:
        note(m)

if manifest_broken:
    inf("C6", f"{len(manifest_broken)} module(s) manifested as known-broken (not compile-checked)")
    for m in manifest_broken:
        note(m)

if os.environ.get("SKIP_BUILD") != "1":
    broken = []
    for m in manifest:
        if m not in graph:
            continue
        # `lake build <module>` (not `lake env lean <path>`) is the authoritative
        # check: it builds the module's transitive dependencies first, so a
        # missing .olean for an unbuilt sibling is not mistaken for rot.
        r = subprocess.run(["lake", "build", m], capture_output=True, text=True)
        if r.returncode != 0:
            errs = [l for l in (r.stdout + r.stderr).splitlines() if "error:" in l]
            broken.append((m, errs[:4]))
    if broken:
        bad("C6", f"{len(broken)} manifested module(s) no longer compile")
        for m, lines in broken:
            note(m)
            for l in lines:
                note("  " + l)
    else:
        pas("C6", f"all {len(manifest)} manifested module(s) still compile in isolation")
else:
    inf("C6", "compile-check skipped (--no-build)")

# --- C7: live inventory (informational) -------------------------------------
inf("C7", f"{len(lean_files)} live .lean files "
          f"({len(live_files('FormalSystem', '.lean'))} FormalSystem / "
          f"{len(live_files('Tests', '.lean'))} Tests); "
          f"{len(seen)} reachable, {len(unreachable)} unreachable")
counts = {}
for p in live_files("FormalSystem", ".lean"):
    top = os.path.relpath(p, "FormalSystem").split(os.sep)[0]
    if top.endswith(".lean"):
        top = "(loose)"
    counts[top] = counts.get(top, 0) + 1
for k in sorted(counts):
    note(f"{k:<20} {counts[k]:>4}")

# --- C8: aggregator convention ----------------------------------------------
# Convention: a directory `X/` has exactly one sibling aggregator `X.lean`.
# Walked parents: `FormalSystem/`, `FormalSystem/Metalogic/` and `FormalSystem/Syntax/`.
# `FormalSystem/Syntax` joined the tuple when the L-minus/L-plus/L-star language family was
# nested under it; that move brought `Syntax/MinusLanguage/`, `Syntax/PlusLanguage/` and
# `Syntax/StarLanguage/` (each arriving with its own sibling aggregator) plus the
# pre-existing `Syntax/SubformulaClosure/` into C8's scope.
# Allowlisted exception: `FormalSystem.lean` + `FormalSystem/FormalSystem.lean`.
# That pair is the Lake `lean_lib FormalSystem` root (`srcDir := "."`,
# `roots := #[`FormalSystem]`), so the self-named indirection is load-bearing, not a
# convention violation.
C8_ALLOW_SELFNAMED = {"FormalSystem/FormalSystem.lean"}
c8_problems = []
for parent in ("FormalSystem", "FormalSystem/Metalogic", "FormalSystem/Syntax"):
    for d in sorted(os.listdir(parent)):
        full = os.path.join(parent, d)
        if not os.path.isdir(full) or d == "Boneyard":
            continue
        # Only Lean-bearing directories participate in the aggregator convention.
        # Asset directories (docs/, latex/, typst/) have no module to aggregate.
        if not live_files(full, ".lean"):
            continue
        sibling = full + ".lean"
        selfnamed = os.path.join(full, d + ".lean")
        if not os.path.isfile(sibling):
            c8_problems.append(f"{full}/ has no sibling aggregator {sibling}")
        if os.path.isfile(selfnamed) and selfnamed not in C8_ALLOW_SELFNAMED:
            c8_problems.append(f"{selfnamed} is a self-named aggregator (use the sibling form)")
if c8_problems:
    if os.environ.get("ENFORCE_C8") == "1":
        bad("C8", f"{len(c8_problems)} aggregator convention violation(s)")
    else:
        print(f"TODO  {'C8':<4} {len(c8_problems)} aggregator convention violation(s) (not yet enforced)")
    for m in c8_problems:
        note(m)
else:
    pas("C8", "every FormalSystem/, Metalogic/ and Syntax/ subdirectory has exactly one sibling aggregator")

# --- C11: archive import resolution ----------------------------------------
# The Boneyard is uncompiled, so `lake build` cannot notice when an archived
# file's import goes stale. Without this check the archive rots silently:
# 65 archived import lines were already dangling when the two archives were
# consolidated into one. C11 makes the invariant enforceable -- every archived
# import must resolve to a file on disk, or be named in the waiver file with a
# recorded reason. Shipped enforced from day one, deliberately without an
# ENFORCE_C11 flag: the flags above exist for end-state invariants the tree does
# not yet satisfy, and this one is satisfied at the moment it lands.
#
# The regex is C4's, verbatim. Do NOT widen it to a bare `^import`: archived
# files carry block-comment continuation lines and fenced code blocks that begin
# with the word `import`, which inflate a naive count by 31 lines and would
# produce that many false failures.
def archive_files(base):
    out = []
    for root, dirs, files in os.walk(base):
        for f in files:
            if f.endswith(".lean"):
                out.append(os.path.join(root, f))
    return sorted(out)

archive_roots = []
for root, dirs, files in os.walk("FormalSystem"):
    if os.path.basename(root) == "Boneyard":
        archive_roots.append(root)
        dirs[:] = []
archive_lean = []
for r in sorted(archive_roots):
    archive_lean.extend(archive_files(r))

waived, waiver_reasons = set(), {}
if os.path.isfile(waivers_path):
    for line in open(waivers_path, encoding="utf-8"):
        raw = line.rstrip("\n")
        mod = raw.split("#")[0].strip()
        if mod:
            waived.add(mod)
            waiver_reasons[mod] = raw.split("#", 1)[1].strip() if "#" in raw else ""

arch_dangling, used_waiver, arch_imports = [], set(), 0
for p in archive_lean:
    txt = open(p, encoding="utf-8", errors="replace").read()
    for i, line in enumerate(txt.splitlines(), 1):
        m = imp_re.match(line + "\n")
        if not m:
            continue
        arch_imports += 1
        tgt = m.group(1)
        if os.path.isfile(mod_to_path(tgt)):
            continue
        if tgt in waived:
            used_waiver.add(tgt)
            continue
        arch_dangling.append((p, i, tgt))

if arch_dangling:
    bad("C11", f"{len(arch_dangling)} unwaived dangling import(s) across "
               f"{arch_imports} archived import lines in {len(archive_lean)} archived file(s)")
    for p, i, t in arch_dangling:
        note(f"{p}:{i}: import {t}  ->  {mod_to_path(t)} (missing, not waived)")
    note(f"repair the import, or add `{arch_dangling[0][2]}` to {waivers_path} with a reason")
else:
    pas("C11", f"all {arch_imports} archived import lines in {len(archive_lean)} archived "
               f"file(s) resolve ({len(used_waiver)} waived)")

stale_waivers = waived - used_waiver
if stale_waivers:
    inf("C11", f"{len(stale_waivers)} waiver entr(y/ies) no longer occur; prune them")
    for m in sorted(stale_waivers):
        note(m)

sys.exit(1 if failures else 0)
PYEOF
PY_STATUS=$?
[ "$PY_STATUS" -ne 0 ] && FAILURES=$((FAILURES + 1))
echo

# ---------------------------------------------------------------------------
# INV: generated inventory blocks are current
#
# The CI path runs the --check sub-mode only, never the writer: a stale block is
# a failure a developer resolves with `--emit-inventory`, not something a gate
# silently rewrites underneath them.
# ---------------------------------------------------------------------------
INV_OUT=$(bash "$0" --emit-inventory --check 2>&1)
INV_STATUS=$?
printf '%s\n' "$INV_OUT"
[ "$INV_STATUS" -ne 0 ] && FAILURES=$((FAILURES + 1))
echo


# ---------------------------------------------------------------------------
# C9: no task-number citations under FormalSystem/, lakefile.lean, README.md,
# or scripts/
#
# `.claude/rules/no-task-references-in-deliverables.md` forbids ephemeral
# task-management identifiers in deliverable files. Task numbers are renumbered
# by vault operations and mean nothing to a future reader of a README. Scope
# widened beyond FormalSystem/ to catch the same defect in the other places it
# was slipping past this check: lakefile.lean's lean_exe docstrings and
# scripts/*.sh's own comments. specs/** stays excluded -- it is the rule's own
# documented exemption -- and this script's own path is excluded (self-match:
# widening the scan to scripts/ would otherwise catch this file's own header
# examples the moment one is added, the same reason C10 self-excludes below).
#
# The regex also matches an ephemeral `specs/NNN_slug/` PATH citation. The rule
# forbids these for the same reason it forbids "task 42" -- a task directory is
# renumbered by vault operations and is meaningless to a future reader -- but the
# `tasks?\s+#?[0-9]+` shape structurally cannot see one, so seventeen of them sat
# in live `.lean` files while this check reported zero.
#
# `scripts/check-evidence-probes.sh` is excluded alongside this file: the path it
# names is not a citation but the directory it exists to read, so the rule's
# "use a durable anchor instead" remedy does not apply to it.
# ---------------------------------------------------------------------------
TASK_REFS=$(grep -rniE --include='*.lean' --include='*.md' --include='*.sh' \
  '\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b|specs/[0-9]{3}_[A-Za-z0-9_]+' \
  FormalSystem lakefile.lean README.md scripts 2>/dev/null \
  | grep -v '/Boneyard/' | grep -v '^scripts/check-module-invariants\.sh:' \
  | grep -v '^scripts/check-evidence-probes\.sh:')
TASK_REF_COUNT=$(printf '%s' "$TASK_REFS" | grep -c . || true)
if [ "$TASK_REF_COUNT" -eq 0 ]; then
  pass C9 "zero task-number citations under FormalSystem/, lakefile.lean, README.md, scripts/"
else
  MSG="$TASK_REF_COUNT task-number citation(s) under FormalSystem/, lakefile.lean, README.md, scripts/ (use a durable anchor instead)"
  if [ "$ENFORCE_C9" -eq 1 ]; then fail C9 "$MSG"; else soft C9 "$MSG (not yet enforced)"; fi
  printf '%s\n' "$TASK_REFS" | head -20 | while IFS= read -r l; do note "$l"; done
  [ "$TASK_REF_COUNT" -gt 20 ] && note "... and $((TASK_REF_COUNT - 20)) more"
fi
echo

# ---------------------------------------------------------------------------
# C10: no references to the pre-relocation asset paths
#
# docs/, latex/ and typst/ live at the project root. `specs/**` legitimately
# records the historical paths and is excluded.
# ---------------------------------------------------------------------------
STALE_PATHS=$(grep -rnE 'FormalSystem/(docs|latex|typst)\b' . \
  --exclude-dir=.git --exclude-dir=.lake --exclude-dir=specs \
  --exclude-dir=build --exclude-dir=__pycache__ 2>/dev/null \
  | grep -v '/Boneyard/' \
  | grep -v '^\./scripts/check-module-invariants\.sh:')
STALE_COUNT=$(printf '%s' "$STALE_PATHS" | grep -c . || true)
if [ "$STALE_COUNT" -eq 0 ]; then
  pass C10 "zero references to FormalSystem/{docs,latex,typst} outside specs/"
else
  MSG="$STALE_COUNT stale reference(s) to FormalSystem/{docs,latex,typst}"
  if [ "$ENFORCE_C10" -eq 1 ]; then fail C10 "$MSG"; else soft C10 "$MSG (not yet enforced)"; fi
  printf '%s\n' "$STALE_PATHS" | head -20 | while IFS= read -r l; do note "$l"; done
  [ "$STALE_COUNT" -gt 20 ] && note "... and $((STALE_COUNT - 20)) more"
fi
echo

# ---------------------------------------------------------------------------
# C12/C13: markdown path and link resolution across docs/ + README.md
#
# C5 matches only DOTTED module names (`FormalSystem.Metalogic.Foo`) via
# `\b(?:FormalSystem|BimodalTest)(?:\.[A-Z][A-Za-z0-9_]*)+`, so the SLASH form
# (`FormalSystem/Metalogic/Foo.lean`) is invisible to it. That blind spot is why a
# source-file table naming six files, four of which did not exist, survived a green
# gate for as long as it did. C12 closes it.
#
# C5's regex is deliberately NOT extended to cover this: adding `Bimodal` to it
# would turn the gate red on occurrences in `FormalSystem/**/README.md` that are a
# separate piece of work. C12 is a distinct check over a distinct path shape.
#
# Both are scoped to `docs/` + `README.md`, and both take a companion allowlist
# FILE rather than hardcoded exclusions, so a future surprise is recorded rather
# than forcing an unrelated edit.
# ---------------------------------------------------------------------------
python3 - "$SLASH_ALLOWLIST" "$LINK_ALLOWLIST" <<'MDPYEOF'
import os, re, sys

slash_allow_path, link_allow_path = sys.argv[1], sys.argv[2]
failures = 0
def pas(c, m): print(f"PASS  {c:<4} {m}")
def bad(c, m):
    global failures
    failures += 1
    print(f"FAIL  {c:<4} {m}")
def inf(c, m): print(f"INFO  {c:<4} {m}")
def note(m):   print(f"            {m}")

def read_allowlist(path):
    out = set()
    if os.path.isfile(path):
        for line in open(path, encoding="utf-8"):
            line = line.split("#")[0].strip()
            if line:
                out.add(line)
    return out

# The scope: every markdown file under docs/, plus the front page.
md_files = []
for root, dirs, files in os.walk("docs"):
    dirs[:] = [d for d in dirs if d not in (".git", "__pycache__")]
    for f in files:
        if f.endswith(".md"):
            md_files.append(os.path.normpath(os.path.join(root, f)))
if os.path.isfile("README.md"):
    md_files.append("README.md")
md_files.sort()

# --- C12: slash-shaped source paths ----------------------------------------
# `Logos/` and `Bimodal/` are the two pre-merge tree roots. Neither resolves to
# anything today, so any occurrence is by construction a defect -- which is exactly
# why they are in the pattern.
slash_re = re.compile(r"\b(?:FormalSystem|Tests|Logos|Bimodal)/[A-Za-z0-9_./-]+")

def slash_resolves(p):
    return (os.path.exists(p) or os.path.isfile(p + ".lean")
            or os.path.isfile(p + ".md") or os.path.isdir(p))

slash_allow = read_allowlist(slash_allow_path)
unresolved, used_slash_allow = [], set()
for f in md_files:
    for i, line in enumerate(open(f, encoding="utf-8", errors="replace"), 1):
        for m in slash_re.findall(line):
            m = m.rstrip("./,:;)")
            if not m or slash_resolves(m):
                continue
            if m in slash_allow:
                used_slash_allow.add(m)
                continue
            unresolved.append((f, i, m))

if unresolved:
    bad("C12", f"{len(unresolved)} unresolved slash-shaped source path(s) in docs/ + README.md")
    for f, i, m in unresolved[:20]:
        note(f"{f}:{i}: {m}")
    if len(unresolved) > 20:
        note(f"... and {len(unresolved) - 20} more")
else:
    pas("C12", f"all slash-shaped source paths in {len(md_files)} markdown files resolve"
               + (f" ({len(used_slash_allow)} allowlisted)" if used_slash_allow else ""))
stale = slash_allow - used_slash_allow
if stale:
    inf("C12", f"{len(stale)} allowlist entr(y/ies) no longer occur; prune them")
    for m in sorted(stale):
        note(m)

# --- C13: relative markdown links ------------------------------------------
link_re = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
link_allow = read_allowlist(link_allow_path)
used_link_allow = set()
broken = []
for f in md_files:
    if f in link_allow:
        used_link_allow.add(f)
        continue
    d = os.path.dirname(f) or "."
    for i, line in enumerate(open(f, encoding="utf-8", errors="replace"), 1):
        for link in link_re.findall(line):
            if link.startswith(("http://", "https://", "mailto:", "#")):
                continue
            target = link.split("#")[0]
            if not target:
                continue
            full = target if target.startswith("/") else os.path.join(d, target)
            if not os.path.exists(full):
                broken.append((f, i, link))

if broken:
    bad("C13", f"{len(broken)} unresolved relative markdown link(s) in docs/ + README.md")
    for f, i, link in broken[:20]:
        note(f"{f}:{i}: -> {link}")
    if len(broken) > 20:
        note(f"... and {len(broken) - 20} more")
else:
    pas("C13", f"all relative markdown links in {len(md_files) - len(used_link_allow)} "
               f"markdown files resolve"
               + (f" ({len(used_link_allow)} file(s) allowlisted)" if used_link_allow else ""))
stale_links = link_allow - used_link_allow
if stale_links:
    inf("C13", f"{len(stale_links)} link-allowlist entr(y/ies) match no file; prune them")
    for m in sorted(stale_links):
        note(m)

sys.exit(1 if failures else 0)
MDPYEOF
MD_STATUS=$?
[ "$MD_STATUS" -ne 0 ] && FAILURES=$((FAILURES + 1))
echo

# ---------------------------------------------------------------------------
# C14: status-claim tripwires
#
# This is the check that closes the loop the rest of this script leaves open.
# C2 and C3 assert facts about the TREE; nothing asserted that `docs/` agrees
# with them. It has two halves:
#
#   (i)  a content scan for STALE literals -- an axiom count that is not 45, or a
#        table row documenting a non-zero sorry count. This half is cheap and
#        always runs. Its scope is docs/ + README.md + FormalSystem/**/*.lean:
#        the .lean half was added because C14's markdown-only scope is exactly
#        why SIX "42 axiom constructors" claims survived a 42 -> 45 change
#        untouched -- every one of them lived in a Lean docstring, where C14
#        could not see it. Lean doc comments are documentation and are in scope.
#   (ii) `#print axioms` for the two headline theorems that C2's four do not
#        cover, so that the decidability soundness bridge and RTime
#        completeness are pinned by the BUILD rather than by prose. This half
#        reuses C2's scratch-file + `lake env lean` machinery, including the
#        continuation-line rejoin, and skips under --no-build exactly as C2 does.
#
# The stale-literal patterns are deliberately narrow. A broad `[1-9]` scan over
# any line containing "sorry" produces false positives on prose that says the
# count is zero; the table-row shape is what actually carries a documented count.
# ---------------------------------------------------------------------------
C14_FAIL=0

# (i) stale axiom counts. 45 is the constructor count of `inductive Axiom`, per
# `Axiom.minFrameClass`. 42 is the figure in the stale `Axioms.lean` docstring,
# which omits the RTime (Dedekind-complete) layer; 21, 14 and 44 are older figures still.
# Scope note: `FormalSystem` is scanned for `*.lean` only, and Boneyard/ is excluded --
# archived modules are not documentation and are allowed to carry historical figures.
#
# WIDENING (both branches, kept identical so they cannot drift apart): the terminal
# word set gains `schema` (matches `schemata` too, since the pattern has no trailing
# `\b`) alongside `axiom`/`constructor`, and an optional single interposed word (e.g.
# "21 TM axiom schemas") is now tolerated between the count and the terminal word.
STALE_AXIOMS=$(grep -rniE --include='*.md' \
  '\b(14|21|42|44)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)' \
  docs README.md 2>/dev/null || true)
# The trailing `grep -i axiom` is a PRECISION guard, not a weakening: `.lean` sources
# carry constructor counts for types other than `Axiom` (e.g. `EnrichedFormula`'s 21
# constructors in Automation/Normalization.lean), and a bare "21 constructors" in such
# a docstring is a correct statement about a different type. Requiring the word "axiom"
# somewhere on the line keeps the tripwire aimed at axiom-count claims. The markdown
# half above is deliberately left exactly as it was -- this is a widening of C14's
# scope, not a rewrite of its existing behavior.
#
# A second PRECISION guard (`grep -v -i covers`) was added alongside the first when
# widening exposed a genuine false positive: `Automation/ProofSearch/Core.lean`
# documents that its matcher "covers" 42 of the tree's 45 axiom constructors --
# a correct SUBSET claim, not a stale TOTAL claim, and the word "covers" is what
# distinguishes the two in every case checked at widening time (verified: neither
# guard removes either of this phase's two genuine stale-count fixes).
STALE_AXIOMS_LEAN=$(grep -rniE --include='*.lean' \
  '\b(14|21|42|44)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)' \
  FormalSystem 2>/dev/null \
  | grep -v '/Boneyard/' | grep -i 'axiom' | grep -v -i 'covers' || true)
STALE_AXIOMS=$(printf '%s\n%s' "$STALE_AXIOMS" "$STALE_AXIOMS_LEAN" | grep -c . >/dev/null \
  && printf '%s\n%s' "$STALE_AXIOMS" "$STALE_AXIOMS_LEAN" | grep . || true)
STALE_AXIOM_COUNT=$(printf '%s' "$STALE_AXIOMS" | grep -c . || true)

# (i) documented non-zero sorry counts, in table-row shape (`... sorries | 7`).
# C3 asserts the real inventory is zero, so any such row is stale by construction.
STALE_SORRIES=$(grep -rniE --include='*.md' \
  'sorr(y|ies)[^|]*\|[[:space:]]*[1-9]' docs README.md 2>/dev/null || true)
STALE_SORRY_COUNT=$(printf '%s' "$STALE_SORRIES" | grep -c . || true)

if [ "$STALE_AXIOM_COUNT" -eq 0 ] && [ "$STALE_SORRY_COUNT" -eq 0 ]; then
  pass C14 "no stale axiom or sorry counts documented in docs/ + README.md + FormalSystem/*.lean"
else
  C14_FAIL=1
  fail C14 "$STALE_AXIOM_COUNT stale axiom count(s), $STALE_SORRY_COUNT documented non-zero sorry count(s)"
  [ "$STALE_AXIOM_COUNT" -gt 0 ] && printf '%s\n' "$STALE_AXIOMS" | head -10 \
    | while IFS= read -r l; do note "$l"; done
  [ "$STALE_SORRY_COUNT" -gt 0 ] && printf '%s\n' "$STALE_SORRIES" | head -10 \
    | while IFS= read -r l; do note "$l"; done
  note "the tree is the authority: C3 asserts zero sorries, Axiom.minFrameClass gives 45 axioms"
fi

# (ii) #print axioms for the theorems C2 does not cover.
# The C14BASE and C14LEAN heredocs below are compared by exact string equality, so they must
# list the same declarations in the same order. Edit them together, appending to both.
#
# The list is long by design. It is the consolidated axiom manifest for the
# consequence / compactness / strong-completeness stack: every declaration in
# Metalogic/{StrongCompleteness,Compactness,DiscreteNonCompactness,DedekindNonCompactness}.lean
# and Metalogic/Conservativity/TMCompletenessReduction.lean that used to carry its own in-file
# `#print axioms` directive now lives here instead. Exactly five in-file directives remain, on
# the five termini: strongCompletenessBase, strongCompletenessDense, notCompactZTime,
# notCompactRTime, consequence_completeness_rtime.
#
# Eight entries carry a STRICT SUBSET of [propext, Classical.choice, Quot.sound], recorded
# literally rather than rounded up: setConsequence_of_not_satisfiable, satisfiableSet_iff_
# finitelySatisfiable, modelExistence_iff_finitelySatisfiable, Conservativity.TMFrag,
# Semantics.plusValidIn_ofFormula_iff, Semantics.galoisClosed_mod and
# StarLanguage.StarDerivationTree are [propext], and qDepth_qAlpha is [propext, Quot.sound].
# A smaller dependency is not a regression.
#
# The trailing block pins the TM⋆ headline results that `docs/theorem-index.md` carries rows
# for, so those rows are machine-pinned rather than prose-only. `StarLanguage.StarAxiom` is
# deliberately ABSENT: `#print axioms` reports it as `does not depend on any axioms`, which the
# `grep 'depends on axioms'` filter below drops, so it contributes a line to neither heredoc and
# cannot be pinned by this mechanism. Its ledger row is omitted for that reason; do not invent a
# baseline line for it.
#
# The second block below (soundness onward) is the SORRY-FREE claim set of
# FormalSystem/Metalogic.lean's module docstring. Every declaration that docstring calls
# SORRY-FREE is pinned here or by C2, so no such claim is prose-only: the docstring asserts
# it and this baseline proves it. Adding a SORRY-FREE bullet to Metalogic.lean without
# adding its subject here reintroduces exactly the drift this block exists to prevent.
read -r -d '' C14_BASELINE <<'C14BASE'
'FormalSystem.Metalogic.Decidability.sound_of_isValid' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.completeness_rtime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompletenessBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompletenessDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.semantic_deduction_in' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_consequence' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_setConsequence' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompleteness_of_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.setConsequence_of_not_satisfiable' depends on axioms: [propext]
'FormalSystem.Metalogic.compact_of_strongCompleteness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompleteness_iff_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.not_compact_of_witness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.not_strongCompleteness_of_witness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.compact_of_modelExistence' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.modelExistence_of_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.compact_iff_modelExistence' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.consequence_completeness_base' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.completeness_base' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_base_consequence' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.consequence_completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_dense_consequence' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.consequence_completeness_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.completeness_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_ztime_consequence' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.sat_ofModel_frame' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.modelExistence_of_satPreserved' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.modelExistenceBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.modelExistenceDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.compactBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.compactDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.truthAt_next_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.truthAt_next_iterate' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.archWitness_finitely_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.archWitness_not_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.notStrongCompletenessZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.qDepth_qAlpha' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.dedWitness_core' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedWitness_not_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedWitness_finitely_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.notStrongCompletenessRTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.modelExistenceRTime_refuted' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmMinusComplete_iff_forward' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmMinusCompleteBase_iff_forwardBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmMinusCompleteZTime_iff_forwardZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmMinusCompleteDense_iff_forwardDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmMinusCompleteRTime_iff_forwardRTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.qAlpha_step' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.exists_strictMono_qPoints' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.setConsequence_iff_not_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.satisfiableSet_iff_finitelySatisfiable' depends on axioms: [propext]
'FormalSystem.Metalogic.modelExistence_iff_finitelySatisfiable' depends on axioms: [propext]
'FormalSystem.Metalogic.soundness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_rtime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.WeakCanonical.countermodel_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.notCompactZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.notCompactRTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.truthAt_tr' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.minus_soundness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.minus_soundness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.minus_soundness_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.minus_soundness_rtime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.minus_not_derivable_nil_bot' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.minus_not_derivable_nil_bot_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.translate' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.derivable_translate' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.ceb_backward' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.cef_backward' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.ced_backward' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.cec_backward' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.TMFrag' depends on axioms: [propext]
'FormalSystem.Metalogic.Conservativity.tmFrag_sound' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.tmFrag_complete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.tmFrag_complete_base' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.tmFrag_complete_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.tmFrag_complete_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.tmFrag_complete_rtime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.tmMinus_le_tmFrag' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.tmMinus_lt_tmFrag_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.minusCompactBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.minusCompactDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.plus_soundness_validIn' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.plusValidIn_ofFormula_iff' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.decide' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.galoisClosed_mod' depends on axioms: [propext]
'FormalSystem.Semantics.galoisClosed_of_indicator' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.galoisClosed_sat_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.galoisClosed_isDiscrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.validOn_nextTop_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.validOn_nextTop_iff_isDiscrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Independence.sat_rtime_ssubset_mod_axiomSet' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Independence.sat_ztime_ssubset_mod_axiomSet' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Independence.deterministic_not_plusDefinable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.consequence_completeness_rtime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_rtime_engine' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.countermodel_dedekind_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.StarLanguage.StarDerivationTree' depends on axioms: [propext]
'FormalSystem.Metalogic.Conservativity.star_soundness_validIn' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.starDerivable_ofFormula_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.starConservative_of_plusComplete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Conservativity.plusIncomplete_of_starNonconservative' depends on axioms: [propext, Classical.choice, Quot.sound]
C14BASE

if [ "$RUN_BUILD" -eq 1 ]; then
  C14_SRC=$(mktemp --suffix=.lean)
  cat >"$C14_SRC" <<'C14LEAN'
import FormalSystem
#print axioms FormalSystem.Metalogic.Decidability.sound_of_isValid
#print axioms FormalSystem.Metalogic.completeness_rtime
#print axioms FormalSystem.Metalogic.strongCompletenessBase
#print axioms FormalSystem.Metalogic.strongCompletenessDense
#print axioms FormalSystem.Metalogic.semantic_deduction_in
#print axioms FormalSystem.Metalogic.soundness_consequence
#print axioms FormalSystem.Metalogic.soundness_setConsequence
#print axioms FormalSystem.Metalogic.strongCompleteness_of_compact
#print axioms FormalSystem.Metalogic.setConsequence_of_not_satisfiable
#print axioms FormalSystem.Metalogic.compact_of_strongCompleteness
#print axioms FormalSystem.Metalogic.strongCompleteness_iff_compact
#print axioms FormalSystem.Metalogic.not_compact_of_witness
#print axioms FormalSystem.Metalogic.not_strongCompleteness_of_witness
#print axioms FormalSystem.Metalogic.compact_of_modelExistence
#print axioms FormalSystem.Metalogic.modelExistence_of_compact
#print axioms FormalSystem.Metalogic.compact_iff_modelExistence
#print axioms FormalSystem.Metalogic.consequence_completeness_base
#print axioms FormalSystem.Metalogic.completeness_base
#print axioms FormalSystem.Metalogic.soundness_base_consequence
#print axioms FormalSystem.Metalogic.consequence_completeness_dense
#print axioms FormalSystem.Metalogic.completeness_dense
#print axioms FormalSystem.Metalogic.soundness_dense_consequence
#print axioms FormalSystem.Metalogic.consequence_completeness_ztime
#print axioms FormalSystem.Metalogic.completeness_ztime
#print axioms FormalSystem.Metalogic.soundness_ztime_consequence
#print axioms FormalSystem.Metalogic.sat_ofModel_frame
#print axioms FormalSystem.Metalogic.modelExistence_of_satPreserved
#print axioms FormalSystem.Metalogic.modelExistenceBase
#print axioms FormalSystem.Metalogic.modelExistenceDense
#print axioms FormalSystem.Metalogic.compactBase
#print axioms FormalSystem.Metalogic.compactDense
#print axioms FormalSystem.Metalogic.truthAt_next_iff
#print axioms FormalSystem.Metalogic.truthAt_next_iterate
#print axioms FormalSystem.Metalogic.archWitness_finitely_satisfiable
#print axioms FormalSystem.Metalogic.archWitness_not_satisfiable
#print axioms FormalSystem.Metalogic.notStrongCompletenessZTime
#print axioms FormalSystem.Metalogic.qDepth_qAlpha
#print axioms FormalSystem.Metalogic.dedWitness_core
#print axioms FormalSystem.Metalogic.dedWitness_not_satisfiable
#print axioms FormalSystem.Metalogic.dedWitness_finitely_satisfiable
#print axioms FormalSystem.Metalogic.notStrongCompletenessRTime
#print axioms FormalSystem.Metalogic.modelExistenceRTime_refuted
#print axioms FormalSystem.Metalogic.tmMinusComplete_iff_forward
#print axioms FormalSystem.Metalogic.tmMinusCompleteBase_iff_forwardBase
#print axioms FormalSystem.Metalogic.tmMinusCompleteZTime_iff_forwardZTime
#print axioms FormalSystem.Metalogic.tmMinusCompleteDense_iff_forwardDense
#print axioms FormalSystem.Metalogic.tmMinusCompleteRTime_iff_forwardRTime
#print axioms FormalSystem.Metalogic.qAlpha_step
#print axioms FormalSystem.Metalogic.exists_strictMono_qPoints
#print axioms FormalSystem.Metalogic.setConsequence_iff_not_satisfiable
#print axioms FormalSystem.Metalogic.satisfiableSet_iff_finitelySatisfiable
#print axioms FormalSystem.Metalogic.modelExistence_iff_finitelySatisfiable
#print axioms FormalSystem.Metalogic.soundness
#print axioms FormalSystem.Metalogic.soundness_dense
#print axioms FormalSystem.Metalogic.soundness_ztime
#print axioms FormalSystem.Metalogic.soundness_rtime
#print axioms FormalSystem.Metalogic.WeakCanonical.countermodel_discrete
#print axioms FormalSystem.Metalogic.notCompactZTime
#print axioms FormalSystem.Metalogic.notCompactRTime
#print axioms FormalSystem.Semantics.truthAt_tr
#print axioms FormalSystem.Metalogic.minus_soundness
#print axioms FormalSystem.Metalogic.minus_soundness_dense
#print axioms FormalSystem.Metalogic.minus_soundness_ztime
#print axioms FormalSystem.Metalogic.minus_soundness_rtime
#print axioms FormalSystem.Metalogic.minus_not_derivable_nil_bot
#print axioms FormalSystem.Metalogic.minus_not_derivable_nil_bot_ztime
#print axioms FormalSystem.Metalogic.Conservativity.translate
#print axioms FormalSystem.Metalogic.Conservativity.derivable_translate
#print axioms FormalSystem.Metalogic.Conservativity.ceb_backward
#print axioms FormalSystem.Metalogic.Conservativity.cef_backward
#print axioms FormalSystem.Metalogic.Conservativity.ced_backward
#print axioms FormalSystem.Metalogic.Conservativity.cec_backward
#print axioms FormalSystem.Metalogic.Conservativity.TMFrag
#print axioms FormalSystem.Metalogic.Conservativity.tmFrag_sound
#print axioms FormalSystem.Metalogic.Conservativity.tmFrag_complete
#print axioms FormalSystem.Metalogic.Conservativity.tmFrag_complete_base
#print axioms FormalSystem.Metalogic.Conservativity.tmFrag_complete_dense
#print axioms FormalSystem.Metalogic.Conservativity.tmFrag_complete_ztime
#print axioms FormalSystem.Metalogic.Conservativity.tmFrag_complete_rtime
#print axioms FormalSystem.Metalogic.Conservativity.tmMinus_le_tmFrag
#print axioms FormalSystem.Metalogic.Conservativity.tmMinus_lt_tmFrag_ztime
#print axioms FormalSystem.Metalogic.Conservativity.minusCompactBase
#print axioms FormalSystem.Metalogic.Conservativity.minusCompactDense
#print axioms FormalSystem.Metalogic.Conservativity.plus_soundness_validIn
#print axioms FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff
#print axioms FormalSystem.Semantics.plusValidIn_ofFormula_iff
#print axioms FormalSystem.Metalogic.Decidability.decide
#print axioms FormalSystem.Semantics.galoisClosed_mod
#print axioms FormalSystem.Semantics.galoisClosed_of_indicator
#print axioms FormalSystem.Semantics.galoisClosed_sat_dense
#print axioms FormalSystem.Semantics.galoisClosed_isDiscrete
#print axioms FormalSystem.Semantics.validOn_nextTop_iff
#print axioms FormalSystem.Semantics.validOn_nextTop_iff_isDiscrete
#print axioms FormalSystem.Metalogic.Independence.sat_rtime_ssubset_mod_axiomSet
#print axioms FormalSystem.Metalogic.Independence.sat_ztime_ssubset_mod_axiomSet
#print axioms FormalSystem.Metalogic.Independence.deterministic_not_plusDefinable
#print axioms FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness
#print axioms FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior
#print axioms FormalSystem.Metalogic.consequence_completeness_rtime
#print axioms FormalSystem.Metalogic.BXCanonical.completeness_rtime_engine
#print axioms FormalSystem.Metalogic.BXCanonical.countermodel_dedekind_dense
#print axioms FormalSystem.StarLanguage.StarDerivationTree
#print axioms FormalSystem.Metalogic.Conservativity.star_soundness_validIn
#print axioms FormalSystem.Metalogic.Conservativity.starDerivable_ofFormula_iff
#print axioms FormalSystem.Metalogic.Conservativity.starConservative_of_plusComplete
#print axioms FormalSystem.Metalogic.Conservativity.plusIncomplete_of_starNonconservative
C14LEAN
  C14_OUT=$(lake env lean "$C14_SRC" 2>&1 \
    | sed -e ':a' -e '$!N' -e 's/\n / /' -e 'ta' -e 'P' -e 'D' \
    | grep 'depends on axioms')
  rm -f "$C14_SRC"
  if [ "$C14_OUT" = "$C14_BASELINE" ]; then
    pass C14 "every pinned declaration matches its axiom baseline (the consequence/compactness stack plus every SORRY-FREE claim in Metalogic.lean)"
    while IFS= read -r l; do note "$l"; done <<<"$C14_OUT"
  else
    C14_FAIL=1
    fail C14 "axiom sets diverged from baseline -- this is a HARD STOP, not a new baseline"
    note "--- expected ---"
    while IFS= read -r l; do note "$l"; done <<<"$C14_BASELINE"
    note "--- actual ---"
    while IFS= read -r l; do note "$l"; done <<<"$C14_OUT"
  fi
else
  info C14 "#print axioms half skipped (--no-build); the content scan above still ran"
fi
echo

# ---------------------------------------------------------------------------
# C15: paper-anchor integrity
#
# WHY THIS EXISTS: 30 dangling paper-anchor citations accumulated in this tree
# across six paper editing waves, and not one of them was caught at write time.
# `lem:fibers` alone was cited 17 times after the paper deleted its `\label`.
# Nothing in this script asserted that a `def:`/`thm:`/`lem:`/`cor:`/`app:`/`rmk:`
# citation names an anchor that actually exists.
#
# RESOLUTION SOURCE IS THE RECORD, NOT THE PAPER. specs/paper-definitions-of-record.md
# is this repository's citation source of record (that is the record's own charter),
# and the paper lives in a different repository this one cannot see from CI. Resolving
# against the live .tex would make this check go red whenever the author edits the
# paper -- an event this repository does not control and cannot fix by editing itself.
# So a citation resolves if EITHER:
#
#   (a) it has a row in the record's machine-readable MANIFEST (a pinned anchor), or
#   (b) it has a row in the record's KNOWN-ANCHORS block, whose status is either
#       LIVE-UNPINNED (live in the paper, deliberately not pinned) or DANGLING
#       (retired, commented out, or never existed).
#
# Every anchor is therefore a RECORDED DECISION. An anchor with no row is either a
# typo or an undocumented citation, and both are defects.
#
# SCOPE is deliberate: specs/** is excluded (task artifacts routinely quote anchors
# that were live when they were written, and rewriting history is not the goal), and
# FormalSystem/Boneyard/ is excluded (archived modules are frozen). What remains is
# live, load-bearing scope: FormalSystem/ (non-Boneyard), Tests/, typst/, docs/,
# and README.md.
# ---------------------------------------------------------------------------
C15_RECORD="specs/paper-definitions-of-record.md"
if [ ! -f "$C15_RECORD" ]; then
  fail C15 "record not found: $C15_RECORD (C15 cannot resolve any anchor without it)"
else
  C15_KNOWN=$(mktemp)
  # (a) manifest rows: anchor_id is field 1; strip the `#SubAnchor` suffix so that
  # `def:frame#Saturation` registers its parent `def:frame` too.
  sed -n '/<!-- MANIFEST:BEGIN -->/,/<!-- MANIFEST:END -->/p' "$C15_RECORD" \
    | grep -v '<!--' | grep -v '^```' | grep -v '^#' | grep -v '^[[:space:]]*$' \
    | cut -d'|' -f1 | sed 's/#.*//' >> "$C15_KNOWN"
  # (b) known-anchor rows
  sed -n '/<!-- KNOWN-ANCHORS:BEGIN -->/,/<!-- KNOWN-ANCHORS:END -->/p' "$C15_RECORD" \
    | grep -v '<!--' | grep -v '^```' | grep -v '^#' | grep -v '^[[:space:]]*$' \
    | cut -d'|' -f1 >> "$C15_KNOWN"
  sort -u -o "$C15_KNOWN" "$C15_KNOWN"

  C15_CITED=$(mktemp)
  # `--include` restricts the walk to documentation-bearing file types; `--exclude-dir`
  # drops the archive. Both are needed: `-h -o` discards the path, so a post-hoc path
  # filter is not available on this pipeline.
  grep -rhoE '\b(def|thm|lem|cor|app|rmk):[A-Za-z0-9][A-Za-z0-9_-]*' \
    --include='*.lean' --include='*.md' --include='*.typ' --exclude-dir=Boneyard \
    FormalSystem Tests typst docs README.md 2>/dev/null \
    | sort -u > "$C15_CITED" || true

  C15_UNKNOWN=$(comm -23 "$C15_CITED" "$C15_KNOWN")
  C15_UNKNOWN_COUNT=$(printf '%s' "$C15_UNKNOWN" | grep -c . || true)
  if [ "$C15_UNKNOWN_COUNT" -eq 0 ]; then
    C15_TOTAL=$(grep -c . "$C15_CITED" || true)
    pass C15 "all $C15_TOTAL paper-anchor citation(s) resolve against $C15_RECORD"
  else
    fail C15 "$C15_UNKNOWN_COUNT paper-anchor citation(s) resolve to nothing in $C15_RECORD"
    printf '%s\n' "$C15_UNKNOWN" | head -15 | while IFS= read -r a; do
      [ -z "$a" ] && continue
      loc=$(grep -rlF "$a" --include='*.lean' --include='*.md' --include='*.typ' \
              FormalSystem Tests typst docs README.md 2>/dev/null \
              | grep -v '/Boneyard/' | head -2 | tr '\n' ' ')
      note "$a  <- $loc"
    done
    note "fix the citation, or record the anchor in the record's KNOWN-ANCHORS block"
    note "(status LIVE-UNPINNED if it resolves in the paper, DANGLING if it does not)"
  fi
  rm -f "$C15_KNOWN" "$C15_CITED"
fi

# ---------------------------------------------------------------------------
# C15, second assertion: every theorem-index row is anchored at its declaration
#
# `docs/theorem-index.md` is the repository's single per-theorem ledger, and its
# Paper-label column is only as good as the declaration sites it claims to describe.
# This asserts the round trip: for every row, the named declaration's own `/--` doc
# comment carries a `Paper:` line whose value is either the row's anchor or the
# literal `—` followed by a one-clause reason. `—` is a satisfied cell, not a gap:
# compactness, non-compactness, consequence completeness, the conservativity bridge
# and the expressiveness results are the formalization's own and have no paper
# counterpart to cite.
#
# Structurally INDEPENDENT of the anchor-resolution loop above, and reported
# separately, so that a failure here is never confused with an unresolved anchor and
# neither half can make the other unrunnable.
# ---------------------------------------------------------------------------
python3 - <<'PYEOF'
import os, re, sys

INDEX = "docs/theorem-index.md"
def pas(m): print("PASS  C15  %s" % m)
def bad(m): print("FAIL  C15  %s" % m)
def note(m): print("            %s" % m)

if not os.path.isfile(INDEX):
    bad("theorem index not found: %s (the per-theorem ledger is the second assertion's input)" % INDEX)
    sys.exit(1)

ROW = re.compile(r'^\| (?P<label>.+?) \| (?P<stmt>.+?) \| `(?P<name>FormalSystem\.[^`]+)` \| '
                 r'`(?P<file>[^`]+)` \| (?P<fc>.+?) \| (?P<ax>.+?) \|$')
# `inductive` is in this alternation because the ledger carries rows for type
# declarations, not only for theorems: a derivation-tree type is a headline result in
# exactly the way its soundness theorem is. Widening the alternation can only let a row
# that previously reported "no such declaration" be found and then still be required to
# carry its `Paper:` line -- it cannot silence an existing failure.
DECL = re.compile(r'^\s*(?:@\[[^\]]*\]\s*)?(?:private\s+|protected\s+|noncomputable\s+)*'
                  r'(?:theorem|lemma|def|abbrev|instance|inductive)\s+([A-Za-z_][A-Za-z0-9_.\']*)')

rows = []
for line in open(INDEX, encoding="utf-8"):
    m = ROW.match(line.rstrip("\n"))
    if m:
        rows.append((m.group("label").strip().strip("`"), m.group("name"), m.group("file")))

problems = []
cache = {}
for label, name, path in rows:
    if not os.path.isfile(path):
        problems.append("%s: File cell names a path that does not exist (%s)" % (name, path))
        continue
    if ":" in path:
        problems.append("%s: File cell carries a line number (%s); cite declaration names" % (name, path))
        continue
    if path not in cache:
        cache[path] = open(path, encoding="utf-8", errors="replace").read().split("\n")
    lines = cache[path]
    # A declaration match inside a block comment is not a declaration: module
    # docstrings in this tree quote their own theorem statements in ```lean fences.
    code = []
    depth = 0
    for l in lines:
        code.append(depth == 0)
        depth += l.count("/-") - l.count("-/")
        if depth < 0:
            depth = 0
    base = name.split(".")[-1]
    i = None
    for k, l in enumerate(lines):
        if code[k] and DECL.match(l) and DECL.match(l).group(1) == base:
            i = k
            break
    if i is None:
        problems.append("%s: no such declaration in %s" % (name, path))
        continue
    j = i - 1
    while j >= 0 and lines[j].strip().startswith("@["):
        j -= 1
    if j < 0 or not lines[j].strip().endswith("-/"):
        problems.append("%s: has no doc comment to carry its Paper: line" % name)
        continue
    k = j
    while k >= 0 and not lines[k].lstrip().startswith("/--"):
        k -= 1
    block = "\n".join(lines[max(k, 0):j + 1])
    pm = re.search(r'^\s*Paper: (.+)$', block, re.M)
    if not pm:
        problems.append("%s: doc comment carries no `Paper:` line" % name)
        continue
    val = pm.group(1).strip()
    if label == "—":
        if not val.startswith("— ("):
            problems.append("%s: index row has no paper label, so the site must read "
                            "`Paper: — (reason)`; it reads `%s`" % (name, val))
    elif val != "`%s`" % label:
        problems.append("%s: index row cites `%s` but the site reads %s" % (name, label, val))

if not rows:
    bad("theorem index has no parseable rows; the second assertion cannot run")
    sys.exit(1)
if problems:
    bad("%d of %d theorem-index row(s) are not anchored at their declaration" % (len(problems), len(rows)))
    for p in problems[:15]:
        note(p)
    if len(problems) > 15:
        note("... and %d more" % (len(problems) - 15))
    note("every row must carry `Paper: <anchor>` or `Paper: — (reason)` in the")
    note("declaration's own /-- block; `—` is a satisfied cell, not a gap")
    sys.exit(1)
pas("all %d theorem-index row(s) carry their anchor (or `Paper: —`) at the declaration" % len(rows))
sys.exit(0)
PYEOF
C15B_STATUS=$?
[ "$C15B_STATUS" -ne 0 ] && FAILURES=$((FAILURES + 1))
echo

# ---------------------------------------------------------------------------
# C20: file.lean:NNN citations -- two tiers
#
# WHY THIS EXISTS: a `Foo.lean:123` citation is a pointer that rots the moment
# anything above line 123 is edited, and nothing noticed. Measured when this check
# was written: 1,354 such citations in live scope, of which 118 point at a line that
# does not exist or at a blank line. The standing convention is to cite the
# DECLARATION NAME, never file:line -- a name survives every edit that a line number
# does not.
#
# Two tiers, because the two halves have very different costs:
#
#   Tier 1 (GATED, repo-wide live scope). A citation whose target line is out of
#   range, or lands on a blank line, is provably wrong. Machine-detectable, so
#   machine-fixable, so gated everywhere.
#
#   Tier 2 (reported; gated only under ENFORCE_C20=1). ANY file:line citation in
#   publication-facing scope -- README.md, docs/, typst/, every README.md under
#   FormalSystem/, and the aggregators and top-level modules of FormalSystem/,
#   Metalogic/ and Semantics/. These are the surfaces a paper reader and doc-gen4
#   actually land on. `FormalSystem/Metalogic/WeakCanonical/**` is deliberately
#   EXCLUDED from tier 2: its ~1,080 citations are internal proof-engineering
#   navigation notes between files a referee never opens, and gating them would turn
#   a documentation nicety into a thousand-site refactor with real regression risk.
#   They are still covered by tier 1.
#
# A citation whose filename resolves to several live files, or to none (an archived
# path, say), is reported as unverifiable rather than failed: the check will not
# guess which file was meant.
# ---------------------------------------------------------------------------
export ENFORCE_C20
python3 - <<'PYEOF'
import os, re, sys

ENFORCE = os.environ.get("ENFORCE_C20") == "1"

def pas(m): print("PASS  C20  %s" % m)
def bad(m): print("FAIL  C20  %s" % m)
def inf(m): print("INFO  C20  %s" % m)
def soft(m): print("TODO  C20  %s" % m)
def note(m): print("            %s" % m)

CITE = re.compile(r'\b((?:[A-Za-z0-9_]+/)*[A-Za-z0-9_]+\.lean):(\d+)\b')

live = []
for root, dirs, fs in os.walk("."):
    dirs[:] = [d for d in dirs if d not in (".git", ".lake", "Boneyard", "__pycache__", "specs")]
    for f in fs:
        if f.endswith(".lean"):
            live.append(os.path.normpath(os.path.join(root, f)))
by_base = {}
for p in live:
    by_base.setdefault(os.path.basename(p), []).append(p)

def resolve(ref):
    """Return (path, None) when the citation names exactly one live file."""
    if "/" in ref:
        c = [p for p in live if p == ref or p.endswith(os.sep + ref.replace("/", os.sep))]
    else:
        c = by_base.get(ref, [])
    if len(c) == 1:
        return c[0], None
    return None, ("ambiguous" if len(c) > 1 else "unresolved")

SCAN_ROOTS = ["FormalSystem", "docs", "typst", "Tests", "scripts", "README.md"]
SELF = os.path.join("scripts", "check-module-invariants.sh")
files = []
for r in SCAN_ROOTS:
    if os.path.isfile(r):
        files.append(r)
        continue
    for root, dirs, fs in os.walk(r):
        dirs[:] = [d for d in dirs if d not in ("Boneyard", ".lake", "__pycache__")]
        for f in fs:
            if f.endswith((".lean", ".md", ".typ", ".sh")):
                files.append(os.path.normpath(os.path.join(root, f)))
files = sorted(f for f in files if f != SELF)

WEAKCANON = os.path.join("FormalSystem", "Metalogic", "WeakCanonical") + os.sep

def publication_scope(p):
    """The surfaces a paper reader or doc-gen4 lands on."""
    if p.startswith(WEAKCANON):
        return False
    if p == "README.md" or p.startswith("docs" + os.sep) or p.startswith("typst" + os.sep):
        return True
    if os.path.basename(p) == "README.md" and p.startswith("FormalSystem" + os.sep):
        return True
    d = os.path.dirname(p)
    return p.endswith(".lean") and d in ("FormalSystem",
                                         os.path.join("FormalSystem", "Metalogic"),
                                         os.path.join("FormalSystem", "Semantics"))

cache = {}
wrong, unverifiable, pub = [], [], []
total = 0
for p in files:
    for i, l in enumerate(open(p, encoding="utf-8", errors="replace").read().split("\n"), 1):
        for ref, num in CITE.findall(l):
            total += 1
            if publication_scope(p):
                pub.append((p, i, ref, num))
            target, why = resolve(ref)
            if target is None:
                unverifiable.append((p, i, ref, num, why))
                continue
            if target not in cache:
                cache[target] = open(target, encoding="utf-8", errors="replace").read().split("\n")
            tl = cache[target]
            n = int(num)
            if n < 1 or n > len(tl):
                wrong.append((p, i, ref, num, "line %s does not exist; %s has %d lines"
                              % (num, target, len(tl))))
            elif tl[n - 1].strip() == "":
                wrong.append((p, i, ref, num, "line %s of %s is blank" % (num, target)))

status = 0
if wrong:
    bad("tier 1: %d of %d file.lean:NNN citation(s) point at a line that does not exist "
        "or is blank" % (len(wrong), total))
    for p, i, ref, num, why in wrong[:15]:
        note("%s:%d  ->  %s:%s  (%s)" % (p, i, ref, num, why))
    if len(wrong) > 15:
        note("... and %d more" % (len(wrong) - 15))
    note("replace each with the declaration name at the intended site")
    status = 1
else:
    pas("tier 1: all %d resolvable file.lean:NNN citation(s) land on a real, non-blank line"
        % (total - len(unverifiable)))

if unverifiable:
    inf("%d citation(s) name a filename that is ambiguous or resolves to no live file "
        "(not checkable, not failed)" % len(unverifiable))
    for p, i, ref, num, why in unverifiable[:5]:
        note("%s:%d  ->  %s:%s  (%s)" % (p, i, ref, num, why))

if pub:
    msg = ("tier 2: %d file.lean:NNN citation(s) in publication-facing scope across %d file(s) "
           "(cite the declaration name instead)" % (len(pub), len({p for p, _, _, _ in pub})))
    if ENFORCE:
        bad(msg)
        status = 1
    else:
        soft(msg + " (not yet enforced)")
    seen = {}
    for p, i, ref, num in pub:
        seen[p] = seen.get(p, 0) + 1
    for p in sorted(seen, key=lambda x: -seen[x])[:10]:
        note("%4d  %s" % (seen[p], p))
    if not ENFORCE:
        note("set ENFORCE_C20=1 to make this exit-code-affecting once the scope is clean")
else:
    pas("tier 2: zero file.lean:NNN citations in publication-facing scope")

sys.exit(status)
PYEOF
C20_STATUS=$?
[ "$C20_STATUS" -ne 0 ] && FAILURES=$((FAILURES + 1))
echo
# ---------------------------------------------------------------------------
# The lakefile root scrape: ONE site, two consumers.
#
# C25 compile-checks every `lean_exe` root; C16's second half lints every root of either kind.
# Both read the list from here rather than each scraping `lakefile.lean` for itself, so a newly
# declared target is covered by both the day it is added and there is no second regex to forget.
# The `lean_exe` regex is the one C6's reachability walk already uses; the `lean_lib` form is
# `roots := #[...]`, which that regex deliberately does not match (there `root` is followed by
# an `s`, not by `:=`), so the two lists are disjoint by construction rather than by filtering.
# ---------------------------------------------------------------------------
LAKE_EXE_ROOTS=$(python3 - <<'PYEOF'
import re
try:
    lf = open("lakefile.lean", encoding="utf-8").read()
except OSError:
    raise SystemExit(0)
for m in re.findall(r"root\s*:=\s*`([A-Za-z0-9_.]+)", lf):
    print(m)
PYEOF
)
LAKE_LIB_ROOTS=$(python3 - <<'PYEOF'
import re
try:
    lf = open("lakefile.lean", encoding="utf-8").read()
except OSError:
    raise SystemExit(0)
for block in re.findall(r"roots\s*:=\s*#\[([^\]]*)\]", lf):
    for m in re.findall(r"`([A-Za-z0-9_.]+)", block):
        print(m)
PYEOF
)

# ---------------------------------------------------------------------------
# C16: environment linters (defsWithUnderscore, docBlame, simpNF, structureInType,
# tacticDocs, unusedArguments, ...) via the configured lintDriver
#
# `lake exe runLinter FormalSystem` runs Batteries' full env_linter suite -- the same
# one `lintDriver := "batteries/runLinter"` wires into `lake lint`/CI -- and reads
# scripts/nolints.json unconditionally, filtering out every declaration recorded
# there before deciding pass/fail. nolints.json grandfathers 217 findings, all of them
# `unusedArguments` -- the sole permanently-grandfathered category, on the measured
# evidence recorded in docs/development/NAMING_CONVENTION_DEVIATION.md. A clean run
# here therefore means "no NEW finding since the grandfather baseline", mirroring CI's
# own `lake lint` gate exactly -- this is the local equivalent of that check. Never
# regenerate nolints.json to make a genuine regression disappear: `--update` rewrites
# the file wholesale from current findings and would grandfather the regression along
# with everything else. To retire a category, fix it and remove its rows with a `jq`
# filter, then prove the removal with a green `lake exe runLinter FormalSystem`.
#
# `dupNamespace` is deliberately NOT part of this batch (it is a separate Lean-core
# text linter, not a Batteries @[env_linter], and never appears in runLinter's
# output regardless of its true count). Isolating it via the REAL linter requires
# `lake lint --builtin-only --lint-only .dupNamespace`, which forces Lake to
# rebuild the ENTIRE default target under different linter options on every
# single invocation (confirmed during this check's own development: roughly ten
# minutes, and OOM-killed once) -- unsustainable for a routinely-run script.
#
# Instead, dupNamespace's condition is checked TEXTUALLY below, reporting-only:
# it fires when a declaration's own name repeats a component of its enclosing
# `namespace`, so a plain scan tracking `namespace`/`section`/`end` nesting and
# flagging any `structure`/`inductive`/`def`/`abbrev`/`theorem`/`instance`/`class`
# whose name (plus, for a `structure`/`class`, its auto-generated field
# projections and `.mk` constructor) repeats an open segment reproduces the real
# linter's verdict closely, in milliseconds, with no build. This is intentionally
# an approximation (it will miss `to_additive`-style generated names, and
# multi-line/attribute-heavy declarations are best-effort) -- acceptable because
# this half is reporting-only. For a cheap cross-check against the REAL linter,
# `lake env lean <file>` re-elaborates a single file against the existing oleans in
# roughly two seconds, runs `dupNamespace` for real, and writes no oleans -- a
# different route entirely from the ~10-minute full-rebuild
# `lake lint --builtin-only --lint-only .dupNamespace` path described above, and the
# one to reach for when this scanner's verdict on a file needs confirming. A
# HARDCODED count was deliberately
# rejected here: this script exists in part to catch hand-typed numbers drifting
# from the tree (see C14), so freezing dupNamespace's count would be the same
# defect class in miniature.
#
# THE LINTER TARGET, AND WHY IT IS NO LONGER JUST `FormalSystem`.
#
# `runLinter <Module>` observes a package by IMPORTING it, so `runLinter FormalSystem` sees
# exactly the FormalSystem library closure and nothing else. Every `lean_exe` root sits outside
# that closure, and so does the `BimodalTest` library root -- the same structural gap C25 exists
# to close for compilation, unclosed for linting. It is not hypothetical: 20 live
# `defsWithUnderscore` findings sit in an out-of-closure module today (auto-generated
# projections of one `structure` whose fields are snake_case and data-valued), and
# `runLinter FormalSystem` reports 0 in the same breath.
#
# MEASURED BEFORE DECIDING. `lake exe runLinter <Module>` accepts any module name, library root
# or exe root alike. Sweeping all fifteen roots with the tree already built by C1 -- which is
# the position this check runs in -- costs 44s wall clock and reports:
#
#     FormalSystem 0   ProofStepExport 0   BenchmarkAnchors 0   TableauProofStepPipeline 0
#     ProofFirstExporter 0   DatasetValidator 1   CheckInitImports 1   EnumBenchmark 4
#     TraceExporter 5   BenchmarkOracle 9   TableauBridge 12   MachineAppendixExport 16
#     DatasetExport 32   BimodalTest 85
#
# -- 179 findings outside the `FormalSystem` root, of which 56 are `defsWithUnderscore`
# (DatasetExport 20, BimodalTest 36) and the rest are docBlame/unusedArguments-class.
#
# THE DECISION: widen, but REPORTING-ONLY, behind ENFORCE_C16_ROOTS, which defaults to 0. The
# scope is not clean, so enforcing it would hold the gate hostage to a burndown this change does
# not own; abandoning the widening would leave the elaboration-only shapes with no instrument at
# all. Reporting it prints the debt at every gate, which is the ENFORCE_C9_DOCS pattern and the
# reason that pattern exists. The first half above -- `runLinter FormalSystem` against
# scripts/nolints.json -- stays ENFORCED and unchanged; this half neither relaxes it nor
# depends on it, and no existing ENFORCE_ flag was flipped to accommodate the widening.
# ---------------------------------------------------------------------------
if [ "$RUN_BUILD" -eq 1 ]; then
  C16_LOG=$(mktemp)
  if lake exe runLinter FormalSystem >"$C16_LOG" 2>&1; then
    pass C16 "env_linter batch (defsWithUnderscore, docBlame, simpNF, structureInType, tacticDocs, unusedArguments) has no un-nolisted finding"
  else
    MSG="env_linter batch reports new finding(s) beyond scripts/nolints.json's grandfathered baseline"
    if [ "$ENFORCE_C16" -eq 1 ]; then fail C16 "$MSG"; else soft C16 "$MSG (not yet enforced)"; fi
    grep -m1 '^-- Found ' "$C16_LOG" | while IFS= read -r l; do note "$l"; done
    tail -20 "$C16_LOG" | while IFS= read -r l; do note "$l"; done
    note "run 'lake exe runLinter --update FormalSystem' only after confirming every new finding is intentional -- --update grandfathers everything currently reported, including a genuine regression"
  fi
  rm -f "$C16_LOG"
else
  info C16 "env_linter batch skipped (--no-build)"
fi

# C16, second half: the same env_linter batch over EVERY root declared in lakefile.lean.
# Reporting-only while ENFORCE_C16_ROOTS is 0 -- see that flag and the decision recorded in this
# check's header above. The root list comes from the single scrape site above, so a newly
# declared target is covered the day it is added.
if [ "$RUN_BUILD" -eq 1 ]; then
  C16R_LOG=$(mktemp)
  C16R_TOTAL=0
  C16R_DIRTY=0
  C16R_ROWS=""
  C16R_COUNT=0
  while IFS= read -r C16R_ROOT; do
    [ -n "$C16R_ROOT" ] || continue
    [ "$C16R_ROOT" = "FormalSystem" ] && continue   # the enforced half above already covers it
    C16R_COUNT=$((C16R_COUNT + 1))
    # BUILD BEFORE LINTING, and this is load-bearing rather than defensive. `lake exe runLinter
    # <Module>` builds the runLinter EXECUTABLE, not the module it is handed: the module is read
    # back from its .olean at run time. An out-of-closure root's olean is stale here by
    # construction -- C1's `lake build` cannot reach it and C25's builds run later in this script
    # -- so without this line the sweep silently lints the PREVIOUS state of exactly the modules
    # it exists to cover. Measured, not theorised: a deliberate snake_case seed in an
    # out-of-closure module was invisible to this sweep and visible to the same runLinter command
    # run by hand a moment later, after C25 had rebuilt the olean. `lake build` is a no-op once
    # the root is current, so C25 pays nothing for this.
    lake build "$C16R_ROOT" >/dev/null 2>&1 || true
    if lake exe runLinter "$C16R_ROOT" >"$C16R_LOG" 2>&1; then
      continue
    fi
    C16R_N=$(grep -m1 -oE '^-- Found [0-9]+' "$C16R_LOG" | grep -oE '[0-9]+' || true)
    [ -n "$C16R_N" ] || C16R_N=$(grep -c 'error: ' "$C16R_LOG" || true)
    C16R_TOTAL=$((C16R_TOTAL + C16R_N))
    C16R_DIRTY=$((C16R_DIRTY + 1))
    C16R_ROWS="${C16R_ROWS}${C16R_ROOT}: ${C16R_N}"$'\n'
  done <<< "$LAKE_EXE_ROOTS"$'\n'"$LAKE_LIB_ROOTS"
  rm -f "$C16R_LOG"
  if [ "$C16R_COUNT" -eq 0 ]; then
    fail C16 "no non-FormalSystem root scraped from lakefile.lean -- the scraper regex or the lakefile's shape changed"
  elif [ "$C16R_TOTAL" -eq 0 ]; then
    pass C16 "env_linter batch is clean on all $C16R_COUNT non-FormalSystem lakefile root(s)"
    note "every root is now clean; set ENFORCE_C16_ROOTS=1 to make this exit-code-affecting"
  else
    MSG="$C16R_TOTAL env_linter finding(s) across $C16R_DIRTY of $C16R_COUNT non-FormalSystem lakefile root(s)"
    if [ "$ENFORCE_C16_ROOTS" -eq 1 ]; then fail C16 "$MSG"; else soft C16 "$MSG (not yet enforced)"; fi
    printf '%s' "$C16R_ROWS" | sort -t: -k2 -rn | head -6 | while IFS= read -r l; do note "$l"; done
    note "these roots are outside the FormalSystem closure, so \`runLinter FormalSystem\` reports 0 on them by construction"
    note "set ENFORCE_C16_ROOTS=1 to make this exit-code-affecting once the count reaches zero"
  fi
else
  info C16 "env_linter batch over the other lakefile roots skipped (--no-build)"
fi
# dupNamespace, and the C23 naming-regression assertions: one live textual pass over the tree,
# sharing the namespace walk. Runs regardless of --no-build (no build needed). Exits non-zero
# only for C23; dupNamespace itself stays reporting-only.
python3 - <<'PYEOF'
import os, re, sys

def live_lean_files(base):
    out = []
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d != "Boneyard"]
        for f in files:
            if f.endswith(".lean"):
                out.append(os.path.join(root, f))
    return sorted(out)

ns_open_re = re.compile(r"^namespace\s+([A-Za-z_][A-Za-z0-9_'.]*)")
section_re = re.compile(r"^section(?:\s+[A-Za-z_][A-Za-z0-9_']*)?\s*$")
end_re = re.compile(r"^end(?:\s+([A-Za-z_][A-Za-z0-9_'.]*))?\s*$")
decl_re = re.compile(
    r"^(?:@\[[^\]]*\]\s*)*"
    r"(?:private\s+|protected\s+|noncomputable\s+|scoped\s+|local\s+|mutual\s+)*"
    r"(structure|inductive|def|abbrev|theorem|instance|class)\s+"
    r"([A-Za-z_][A-Za-z0-9_'.]*)"
)
field_re = re.compile(r"^[A-Za-z_][A-Za-z0-9_']*\s*:")

findings = []
for path in live_lean_files("FormalSystem"):
    stack, frames = [], []
    try:
        lines = open(path, encoding="utf-8", errors="replace").readlines()
    except OSError:
        continue
    n_lines = len(lines)
    i = 0
    while i < n_lines:
        raw = lines[i]
        line = raw.strip()
        m = ns_open_re.match(line)
        if m:
            segs = m.group(1).split(".")
            stack.extend(segs)
            frames.append(len(segs))
            i += 1
            continue
        if section_re.match(line):
            frames.append(0)
            i += 1
            continue
        if end_re.match(line):
            if frames:
                n = frames.pop()
                if n:
                    stack = stack[:-n] if n <= len(stack) else []
            i += 1
            continue
        m = decl_re.match(line)
        if m and stack:
            kind, ident = m.group(1), m.group(2)
            if ident.startswith("_root_."):
                combined = ident[len("_root_."):].split(".")
            else:
                combined = stack + ident.split(".")
            seen, dup = set(), None
            for s in combined:
                if s in seen:
                    dup = s
                    break
                seen.add(s)
            if dup:
                findings.append((path, i + 1, ident, dup))
                if kind in ("structure", "class") and ident == dup:
                    j, field_count, in_doc = i + 1, 0, False
                    while j < n_lines:
                        body_raw = lines[j]
                        stripped_body = body_raw.strip()
                        if stripped_body == "":
                            j += 1; continue
                        if not body_raw[:1].isspace():
                            break
                        if in_doc:
                            if "-/" in stripped_body:
                                in_doc = False
                            j += 1; continue
                        if stripped_body.startswith("/--"):
                            if "-/" not in stripped_body[3:]:
                                in_doc = True
                            j += 1; continue
                        if field_re.match(stripped_body):
                            field_count += 1
                        j += 1
                    findings.append((path, i + 1, f"{ident}.mk", dup))
                    for _ in range(field_count):
                        findings.append((path, i + 1, f"{ident}.<field>", dup))
        i += 1

if not findings:
    print("PASS  C16  dupNamespace: zero declaration(s) with a repeated namespace component (live textual check)")
else:
    print(f"INFO  C16  dupNamespace: {len(findings)} declaration(s) with a repeated namespace component (live textual check, approximate; never affects FAILURES)")
    for p, l, ident, dup in findings[:20]:
        print(f"            {p}:{l}: {ident} (duplicated component: {dup})")
    if len(findings) > 20:
        print(f"            ... and {len(findings) - 20} more")

# --- C23 additions: the three naming-regression assertions -------------------
# These reuse the namespace walk above rather than adding a fourth scanner, with the
# five corrections a naive reuse needs: `lemma` in the declaration keyword set; an
# identifier class that survives `?`, `'` and unicode suffixes (a bare
# `[A-Za-z0-9_'.]*` truncates `asAnd?` to `asAnd` and manufactures ~30 false
# positives); `private` declarations excluded; `/- ... -/` and `/-! ... -/` blocks
# skipped; and structure-member namesakes never flagged -- which the
# outer-shadows-inner test gives for free, since neither namespace is a prefix of
# the other for `Syntax.Atom.beq_refl` vs `Syntax.Formula.beq_refl`.

DECL2 = re.compile(
    r"^\s*(?:@\[[^\]]*\]\s*)?(?:(private)\s+|protected\s+|noncomputable\s+|scoped\s+"
    r"|local\s+|partial\s+|unsafe\s+)*"
    r"(theorem|lemma|def|abbrev|instance|structure|inductive|class|opaque)\s+"
    r"([^\s\(\{\[:]+)")
LEMMA = re.compile(r"^\s*(?:@\[[^\]]*\]\s*)?(?:private |protected |noncomputable |scoped "
                   r"|local )*lemma\s")
UPPER = re.compile(r"^[A-Z][A-Za-z0-9']*_")
# The recorded leave-alone classes. A tense-operator prefix is one of the paper's own
# operators, not a namespace: `F_until_equiv_valid` is a fact about `F`, and
# `F.until_equiv_valid` would invent a namespace `F` that does not and should not exist.
TENSE_PREFIX = re.compile(r"^(F|P|G|H|A|FF|HF)_")
# Prefixes that name no live declaration, so dot-namespacing them would invent one.
UPPER_ALLOW = {"CAggOdSwap_clause_iff", "CAggOdSwap_clause_iff_faithful", "O_zero_correct"}

decls2 = []      # (ns, base, private, path, line)
lemmas = []
for path in live_lean_files("FormalSystem"):
    stack, frames, depth = [], [], 0
    try:
        lines = open(path, encoding="utf-8", errors="replace").readlines()
    except OSError:
        continue
    for i, raw in enumerate(lines, 1):
        opens = raw.count("/-"); closes = raw.count("-/")
        in_comment = depth > 0
        depth += opens - closes
        if depth < 0:
            depth = 0
        if in_comment:
            continue
        line = raw.strip()
        if line.startswith("--"):
            continue
        m = ns_open_re.match(line)
        if m:
            segs = m.group(1).split(".")
            stack.extend(segs); frames.append(len(segs)); continue
        if section_re.match(line):
            frames.append(0); continue
        if end_re.match(line):
            if frames:
                n = frames.pop()
                if n:
                    stack = stack[:-n] if n <= len(stack) else []
            continue
        if LEMMA.match(raw):
            lemmas.append((path, i))
        m = DECL2.match(line)
        if m:
            name = m.group(3)
            if "." in name:
                continue                       # already dot-qualified: not a bare declaration
            decls2.append((".".join(stack), name, m.group(1) is not None, path, i))

c23_fail = []

# (1) zero live `lemma` declarations
if lemmas:
    print(f"FAIL  C23  {len(lemmas)} live `lemma` declaration(s); the convention is `theorem`")
    for p, l in lemmas[:10]:
        print(f"            {p}:{l}")
    c23_fail.append("lemma")
else:
    print("PASS  C23  zero live `lemma` declarations (both C17 and C19 can see every declaration)")

# (2) no new Uppercase_x name outside the recorded leave-alone classes.
#
# THIRD EXEMPTION, and it is not a style preference: dot-namespacing `Prefix_rest` when a live
# declaration is already called `rest` CAPTURES that name. Declaring `Prefix.rest` puts `rest`
# in scope, as `Prefix.rest`, inside every other `Prefix.*` declaration -- so a sibling whose
# body mentions the standalone `rest` silently resolves to the wrong declaration. Measured, not
# theorised: renaming `BurgessR3Maximal_burgessR3` to `BurgessR3Maximal.burgessR3` made
# `BurgessR3Maximal.extension_fails`'s reference to the standalone `burgessR3` resolve to the
# theorem instead of the definition, and the build failed with an application type mismatch.
# Thirteen of the fifty-one candidate renames had this shape and were left underscored.
LIVE_BASES = {n for _, n, _, _, _ in decls2}
upper_bad = [(ns, n, p, l) for ns, n, priv, p, l in decls2
             if UPPER.match(n) and not TENSE_PREFIX.match(n) and n not in UPPER_ALLOW
             and n.split("_", 1)[1] not in LIVE_BASES]
if upper_bad:
    print(f"FAIL  C23  {len(upper_bad)} Uppercase_x name(s) outside the recorded leave-alone classes")
    for ns, n, p, l in upper_bad[:10]:
        print(f"            {p}:{l}: {n} (use `{n.split('_',1)[0]}.{n.split('_',1)[1]}`)")
    c23_fail.append("Uppercase_x")
else:
    print("PASS  C23  no Uppercase_x name outside the tense-operator, no-such-prefix and\n            name-capture classes")

# (3) no new outer-shadows-inner bare-declaration pair
by_base = {}
for ns, n, priv, p, l in decls2:
    if priv or not ns:
        continue
    by_base.setdefault(n, []).append((ns, p, l))
# Pairs that are accepted and recorded, with the reason, rather than renamed.
SHADOW_ALLOW = {
    # structure-member namesakes on distinct types: legitimate dot-notation
    "isValid",
    # a deliberate, documented duplication -- `ProofStepExport.lean` is a `lean_exe` root
    # with its own `main` and cannot import the leaf module holding the canonical list.
    # C22 asserts the two lists agree, which is the only thing worth checking about them.
    "allAxiomNames",
    # (the frozen-module exemption is applied by path below, not by name)
    # two genuinely different operations sharing a name; resolving it needs a per-site
    # arity analysis across 14 files, recorded as follow-up rather than done blind
    "insertEnv",
}
# SCOPED, REMOVABLE EXEMPTION. Declarations under this path are owned by a separate,
# in-flight workstream that has the module md5-pinned, so the outer member of any pair
# rooted there cannot be renamed from here -- and renaming the inner member alone would
# leave the two base identifiers colliding, which is the thing C17 actually trips over.
# Such a pair is therefore neither fixable nor meaningfully half-fixable right now.
# DELETE THIS EXEMPTION once that workstream lands, and resolve whatever it reports.
FROZEN_PREFIX = os.path.join("FormalSystem", "Metalogic", "Decidability", "Verified",
                             "Termination") + os.sep

shadow = []
for base, rows in by_base.items():
    if base in SHADOW_ALLOW:
        continue
    for a in rows:
        for b in rows:
            if a is b:
                continue
            if b[0].startswith(a[0] + "."):
                if a[1].startswith(FROZEN_PREFIX) or b[1].startswith(FROZEN_PREFIX):
                    continue
                shadow.append((base, a, b))
if shadow:
    print(f"FAIL  C23  {len(shadow)} outer-shadows-inner bare-declaration pair(s)")
    for base, a, b in shadow[:10]:
        print(f"            {base}: outer {a[0]} ({a[1]}:{a[2]})")
        print(f"            {' ' * len(base)}  inner {b[0]} ({b[1]}:{b[2]})")
    c23_fail.append("shadowing")
else:
    print("PASS  C23  no outer-shadows-inner bare-declaration pair outside the recorded set")

if c23_fail:
    print("            C17's dead-declaration census keys on the last dot-segment, so any two")
    print("            declarations sharing a base name mask each other and neither can ever be")
    print("            reported dead. That is the tooling ground these three assertions protect.")
    sys.exit(1)
PYEOF
C23_STATUS=$?
if [ "$C23_STATUS" -ne 0 ] && [ "$ENFORCE_C23" -eq 1 ]; then
  FAILURES=$((FAILURES + 1))
fi
echo

# ---------------------------------------------------------------------------
# C17: dead-declaration scan (reporting-only)
#
# Numbering note: the review's own text calls this check "C16", which collides
# with this file's C16 (the environment-linter batch above). The delegation's
# mapping supersedes the review's label: C17 = D-16 (this check), C18 = E-13
# (paragraph duplication, below).
#
# For each declaration in non-Boneyard FormalSystem/**/*.lean, the BASE
# identifier (the last dot-segment of its name -- e.g. `c0` for `Chronicle.c0`,
# matching how dot notation and an `open` namespace actually reference it) is
# tokenised and counted across every `.lean` file in FormalSystem/ and Tests/
# plus every `.md` file in the repo (excluding .git/.lake/specs/Boneyard/
# build/__pycache__, the same scope C5 already uses for markdown). A
# declaration whose base identifier occurs nowhere else -- not even on another
# line of its own file -- is reported as a candidate dead declaration.
#
# This is reporting-only and deliberately approximate, same spirit as C16's
# dupNamespace check: it is blind to attribute/simp-set-driven indirect usage
# (a theorem tagged `@[formula_unfold]` and consumed only via `simp only
# [formula_unfold]` elsewhere is textually "dead" by this scan but is not
# actually unused), to `to_additive`-generated names, and to same-named
# declarations in different namespaces (a shared base name like `mk` or
# `toString` will never register as dead, which is the safe direction of
# error for a census that must never gate). No ENFORCE_C17 flag -- reporting-
# only per the delegation, and an unused enforcement flag invites a later
# unreviewed flip.
# ---------------------------------------------------------------------------
python3 - <<'PYEOF'
import os, re

def live_lean_files(base):
    out = []
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d != "Boneyard"]
        for f in files:
            if f.endswith(".lean"):
                out.append(os.path.join(root, f))
    return sorted(out)

def prose_files():
    out = []
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs
                   if d not in (".git", ".lake", "specs", "Boneyard", "build", "__pycache__")]
        for f in files:
            if f.endswith(".md"):
                out.append(os.path.relpath(os.path.join(root, f), "."))
    return sorted(out)

decl_re = re.compile(
    r"^(?:@\[[^\]]*\]\s*)*"
    r"(?:private\s+|protected\s+|noncomputable\s+|scoped\s+|local\s+|mutual\s+)*"
    r"(structure|inductive|def|abbrev|theorem|lemma|instance|class)\s+"
    r"([A-Za-z_][A-Za-z0-9_'.]*)"
)
token_re = re.compile(r"[A-Za-z_][A-Za-z0-9_']*")

lean_files = live_lean_files("FormalSystem")
declarations = []
for path in lean_files:
    try:
        lines = open(path, encoding="utf-8", errors="replace").readlines()
    except OSError:
        continue
    for i, raw in enumerate(lines, 1):
        m = decl_re.match(raw.strip())
        if m:
            declarations.append((m.group(2).split(".")[-1], path, i))

# Tests/ is not part of C17's declaration scope but IS a legitimate reference
# site (tests routinely call library declarations by name), so it is included
# in the occurrence corpus -- excluding it would misreport every
# test-only-referenced declaration as dead.
occurrence_files = list(lean_files) + prose_files()
for root, dirs, files in os.walk("Tests"):
    for f in files:
        if f.endswith(".lean"):
            occurrence_files.append(os.path.join(root, f))

occurrences = {}
for path in occurrence_files:
    try:
        lines = open(path, encoding="utf-8", errors="replace").readlines()
    except OSError:
        continue
    for i, line in enumerate(lines, 1):
        for tok in set(token_re.findall(line)):
            occurrences.setdefault(tok, set()).add((path, i))

dead = []
for base, decl_file, decl_line in declarations:
    other = occurrences.get(base, set()) - {(decl_file, decl_line)}
    if not other:
        dead.append((base, decl_file, decl_line))

if not dead:
    print("PASS  C17  zero dead declaration(s) (base-identifier token scan)")
else:
    print(f"INFO  C17  {len(dead)} declaration(s) with zero other occurrences (dead-declaration scan, approximate; never affects FAILURES)")
    for base, f, l in dead[:20]:
        print(f"            {f}:{l}: {base}")
    if len(dead) > 20:
        print(f"            ... and {len(dead) - 20} more")
PYEOF
echo

# ---------------------------------------------------------------------------
# C18: paragraph duplication across the top-level READMEs (reporting-only)
#
# D-16/E-13's "C16" label collision note above applies to this check too --
# C18 is the delegation's mapping for E-13.
#
# Scope (confirmed to exist at implementation time, per the Scope Hypothesis):
# README.md, FormalSystem/README.md, FormalSystem/Metalogic/README.md, and
# FormalSystem/Metalogic.lean (an aggregator whose presence C8 governs).
# Paragraphs (blank-line-delimited blocks) are whitespace-normalised (all
# runs of whitespace, including newlines, collapsed to a single space) and
# pooled across all four files; any normalised paragraph appearing more than
# once -- within one file or across files -- is reported. Markdown headers
# and horizontal rules are excluded (they are structure, not prose), and
# paragraphs under 40 normalised characters are excluded to keep the census
# aimed at substantial copy-paste duplication rather than short, legitimately
# repeated phrases. A second pass, at sentence granularity, follows it; see the
# comment there for why the paragraph pass alone is not enough. No ENFORCE_C18
# flag -- reporting-only per the delegation.
# ---------------------------------------------------------------------------
python3 - <<'PYEOF'
import re

FILES = [
    "README.md",
    "FormalSystem/README.md",
    "FormalSystem/Metalogic/README.md",
    "FormalSystem/Metalogic.lean",
]

def paragraphs(path):
    try:
        text = open(path, encoding="utf-8", errors="replace").read()
    except OSError:
        return []
    paras, cur, start = [], [], None
    for i, line in enumerate(text.split("\n"), 1):
        if line.strip() == "":
            if cur:
                paras.append((start, "\n".join(cur)))
                cur, start = [], None
        else:
            if start is None:
                start = i
            cur.append(line)
    if cur:
        paras.append((start, "\n".join(cur)))
    return paras

def normalize(p):
    return re.sub(r"\s+", " ", p).strip()

occ = {}
for path in FILES:
    for lineno, raw in paragraphs(path):
        norm = normalize(raw)
        if len(norm) < 40:
            continue
        if re.match(r"^#{1,6}\s", norm) or re.match(r"^[-*_]{3,}$", norm):
            continue
        occ.setdefault(norm, []).append((path, lineno))

dups = [(norm, locs) for norm, locs in occ.items() if len(locs) > 1]
if not dups:
    print("PASS  C18  zero duplicated paragraph(s) across the four top-level READMEs")
else:
    print(f"INFO  C18  {len(dups)} duplicated paragraph(s) across the four top-level READMEs (never affects FAILURES)")
    for norm, locs in dups[:20]:
        loc_str = ", ".join(f"{f}:{l}" for f, l in locs)
        print(f"            {loc_str}: {norm[:80]!r}")
    if len(dups) > 20:
        print(f"            ... and {len(dups) - 20} more")

# --- sentence granularity -------------------------------------------------
#
# The paragraph pass is the right detector for wholesale copy-paste, and it is
# retained above unchanged. It is structurally blind to the duplication these
# four surfaces actually accumulate: a claim copied as a SENTENCE into a block
# with different bounds -- a `/-!` docstring bullet in `Metalogic.lean` against a
# markdown paragraph in `README.md`, each with different surrounding text. No
# normalised paragraph is byte-identical, so the paragraph pass reported PASS
# while two such duplicates stood. This second pass shingles on sentence
# boundaries instead.
#
# A "sentence" here is a run ending at `. `, `.\n` or end-of-block; a shingle is
# reported only at 15 words or more, which is long enough that an identical run
# is a copied claim rather than a coincidence of ordinary English.

SENT_SPLIT = re.compile(r"(?<=[.!?])\s+")
MIN_WORDS = 15

def sentences(norm):
    for raw in SENT_SPLIT.split(norm):
        t = raw.strip()
        if len(t.split()) >= MIN_WORDS:
            yield t

sent_occ = {}
for path in FILES:
    for lineno, raw in paragraphs(path):
        norm = normalize(raw)
        if re.match(r"^#{1,6}\s", norm) or re.match(r"^[-*_]{3,}$", norm):
            continue
        for t in sentences(norm):
            sent_occ.setdefault(t, []).append((path, lineno))

sent_dups = [(t, locs) for t, locs in sent_occ.items() if len(locs) > 1]
if not sent_dups:
    print("PASS  C18  zero duplicated sentence(s) (>= %d words) across the same four files"
          % MIN_WORDS)
else:
    print("INFO  C18  %d duplicated sentence(s) (>= %d words) across the same four files "
          "(never affects FAILURES)" % (len(sent_dups), MIN_WORDS))
    for t, locs in sent_dups[:20]:
        loc_str = ", ".join(f"{f}:{l}" for f, l in locs)
        print(f"            {loc_str}: {t[:80]!r}")
    if len(sent_dups) > 20:
        print(f"            ... and {len(sent_dups) - 20} more")
PYEOF
echo

# ---------------------------------------------------------------------------
# C19: docstring-coverage floor (reporting-only)
#
# Declaration-shaped lines (theorem|lemma|def|structure|inductive|class|abbrev|
# instance) in non-Boneyard FormalSystem/**/*.lean. `lemma` is G-12's one
# deliberate addition to the review's own keyword list. The baseline is G-12's
# heuristic, not D-15's 91.8% "core scope" figure -- G-12's is the only one with
# a named, re-runnable method (see this task's plan Overview for the full
# rationale); D-15's baseline is explicitly NOT used here.
#
# TWO figures are computed and both are reported, so a future reader can see
# that the number moved because the definition of "documented" was widened, not
# because coverage itself changed:
#
#   (i)  UNREFINED (G-12 exactly as specified): a declaration counts as
#        documented iff a `/-- ... -/` doc comment ends within the three lines
#        immediately above it. Measured 89.37% (10427 total, 1108 undocumented)
#        -- under the 90% floor.
#   (ii) REFINED (this check's reported figure): (i), OR the declaration falls
#        within the scope of the nearest preceding `/-! ... -/` section
#        comment. That scope begins immediately after the section comment's
#        own closing `-/` and ends at the EARLIEST of: another `/-!` comment
#        opening, a `namespace`/`section`/`end` command, a declaration that is
#        itself (i)-documented (the author explicitly labelled a new unit, so
#        the ambient section's credit ends there), or end of file. Measured
#        92.32% (9626 documented) -- clears the floor.
#
# The refinement was authorized (not assumed) after the unrefined figure was
# found under 90%: this blind spot was already documented as a KNOWN, ANTICIPATED
# limitation of G-12's heuristic ("under-reports coverage for declarations
# documented by an enclosing /-! -/ section comment") before this check existed,
# not a new discovery invented to clear the floor. It was applied ONCE as a
# single, precisely-specified rule and measured once -- not iterated toward a
# target. Verified in both directions before adoption: (a) manually inspecting 8
# of the ORIGINAL undocumented hits confirmed they were genuinely covered by an
# enclosing section, not actually undocumented; (b) manually inspecting several
# NEWLY-credited hits after a first draft of the rule found real over-crediting
# (a section header 664 lines away crediting an unrelated theorem deep in an
# 11000-line file with no intervening boundary) -- the "ends at the next
# (i)-documented declaration too" clause was added specifically to close that
# gap, and the largest remaining credited gap (241 lines, in
# WeakCanonical/GroupModel/MonoDiscrete.lean) was re-checked and found genuine:
# the section header explicitly names every theorem in the batch it covers.
#
# Per-keyword rates worth carrying into a documentation follow-up task
# regardless of the aggregate clearing the floor: class 16.3%, instance 57.6%,
# lemma 55.6% (all measured against the unrefined figures; these three
# categories are real, small-sample documentation gaps, not artifacts of either
# heuristic).
#
# Reporting-only: never increments FAILURES, no ENFORCE_C19 flag. No build
# invocation; runs under --no-build like C17/C18.
# ---------------------------------------------------------------------------
python3 - <<'PYEOF'
import os, re

def live_lean_files(base):
    out = []
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d != "Boneyard"]
        for f in files:
            if f.endswith(".lean"):
                out.append(os.path.join(root, f))
    return sorted(out)

decl_re = re.compile(
    r"^(?:@\[[^\]]*\]\s*)*"
    r"(?:private\s+|protected\s+|noncomputable\s+|scoped\s+|local\s+|mutual\s+)*"
    r"(theorem|lemma|def|structure|inductive|class|abbrev|instance)\s+[A-Za-z_]"
)
boundary_re = re.compile(r"^(namespace|section|end)\b")

total = 0
documented_unrefined = 0
documented_refined = 0

for path in live_lean_files("FormalSystem"):
    text = open(path, encoding="utf-8", errors="replace").read()
    lines = text.split("\n")
    n = len(lines)

    doc_ends = set()
    for m in re.finditer(r"/--.*?-/", text, re.DOTALL):
        doc_ends.add(text.count("\n", 0, m.end()) + 1)

    section_end_lines = set()
    for m in re.finditer(r"/-!.*?-/", text, re.DOTALL):
        section_end_lines.add(text.count("\n", 0, m.end()) + 1)

    decl_lines = {}
    for i, raw in enumerate(lines, 1):
        if decl_re.match(raw.strip()):
            decl_lines[i] = any((i - k) in doc_ends for k in (1, 2, 3))

    active = False
    for i in range(1, n + 1):
        line = lines[i - 1].strip()
        if i in section_end_lines:
            active = True
            continue
        if boundary_re.match(line):
            active = False
        if i in decl_lines:
            total += 1
            if decl_lines[i]:
                documented_unrefined += 1
                documented_refined += 1
                active = False
            elif active:
                documented_refined += 1

pct_unrefined = 100.0 * documented_unrefined / total if total else 0.0
pct_refined = 100.0 * documented_refined / total if total else 0.0
FLOOR = 90.0

print(f"INFO  C19  docstring coverage (unrefined G-12): {documented_unrefined}/{total} = {pct_unrefined:.2f}%")
if pct_refined >= FLOOR:
    print(f"PASS  C19  docstring coverage (refined, /-! section credit): {documented_refined}/{total} = {pct_refined:.2f}% (floor: {FLOOR:.0f}%)")
else:
    print(f"TODO  C19  docstring coverage (refined, /-! section credit): {documented_refined}/{total} = {pct_refined:.2f}% -- below the {FLOOR:.0f}% floor (never affects FAILURES)")
PYEOF
echo

# ---------------------------------------------------------------------------
# C21: every result MainResults.lean advertises is axiom-pinned
#
# `FormalSystem/MainResults.lean` is the one-page list of headline results, and it is
# publication-facing: doc-gen4 renders it, and it is what a reader who wants "the theorems"
# is pointed at. A page like that earns its keep only if the guarantee it states is checked
# somewhere. This check is that somewhere.
#
# It is a SUBSET ASSERTION, deliberately, and NOT a third axiom baseline. C2 pins four
# declarations by exact `#print axioms` string equality and C14 pins the rest, 105 between
# them; every name MainResults.lean carries is already in that set. Adding a third recorded
# baseline for the same declarations would mean three places to update on any change and three
# chances for them to disagree -- which is precisely the drift that retired the hand-transcribed
# `#print axioms` output blocks two Metalogic modules used to carry. So this check asserts a
# closure property over the two baselines that already exist: a declaration may not appear on
# the main-results page unless one of them pins its axiom set.
#
# It therefore fails, rather than warns, on an unpinned name. A warning would let the page
# advertise a result whose axiom dependencies nothing is watching, which is the whole failure
# mode.
#
# Note what this does NOT do: it does not check the axiom SETS (C2 and C14 do that, under
# --no-build's `#print axioms` half), and it does not check that every pinned declaration is on
# the page (the baselines are far broader than the headline list, by design).
# ---------------------------------------------------------------------------
C21_SRC="FormalSystem/MainResults.lean"
if [ ! -f "$C21_SRC" ]; then
  fail C21 "$C21_SRC is missing -- the main-results page is part of the published surface"
else
  C21_NAMES=$(grep -oE '^#print axioms [A-Za-z_][A-Za-z0-9_.'"'"']*' "$C21_SRC" \
    | awk '{print $3}' | sort -u)
  C21_PINNED=$(printf '%s\n%s\n' "$AXIOM_BASELINE" "$C14_BASELINE" \
    | grep -oE "^'[^']+'" | tr -d "'" | sort -u)
  C21_TOTAL=$(printf '%s' "$C21_NAMES" | grep -c . || true)
  C21_MISSING=$(comm -23 <(printf '%s\n' "$C21_NAMES") <(printf '%s\n' "$C21_PINNED") | grep . || true)
  C21_MISS_COUNT=$(printf '%s' "$C21_MISSING" | grep -c . || true)
  if [ "$C21_TOTAL" -eq 0 ]; then
    fail C21 "$C21_SRC carries no '#print axioms' directive -- the page states no guarantee"
  elif [ "$C21_MISS_COUNT" -eq 0 ]; then
    pass C21 "all $C21_TOTAL declaration(s) named in MainResults.lean are pinned by C2 or C14"
  else
    MSG="$C21_MISS_COUNT of $C21_TOTAL MainResults.lean declaration(s) are pinned by neither C2 nor C14"
    if [ "$ENFORCE_C21" -eq 1 ]; then fail C21 "$MSG"; else soft C21 "$MSG (not yet enforced)"; fi
    printf '%s\n' "$C21_MISSING" | while IFS= read -r l; do note "$l"; done
    note "add the declaration to the C14 baseline pair, or take it off the main-results page"
  fi
fi
echo

# ---------------------------------------------------------------------------
# C22: the two `allAxiomNames` lists agree
#
# `Automation/AxiomNames.lean` and `Automation/ProofStepExport.lean` both declare a list
# called `allAxiomNames`, and the duplication is DELIBERATE and documented at the second
# site: `ProofStepExport.lean` is a `lean_exe` root that declares its own `main`, so it
# cannot import the leaf module that owns the canonical list. The names are therefore not
# renamed apart -- renaming one would hide the fact that they must agree, which is the only
# thing worth checking about them.
#
# What can go wrong is the two lists drifting when a constructor is added to `inductive
# Axiom`. Nothing noticed before this check: neither file imports the other, so the compiler
# cannot compare them, and each list is internally consistent whatever it contains.
#
# The comparison is on the SET of quoted strings, not on order or layout: the two lists are
# formatted differently on purpose (one groups by axiom layer with comments, the other runs
# in source order), and requiring byte equality would fail on that cosmetic difference alone.
# ---------------------------------------------------------------------------
ENFORCE_C22=${ENFORCE_C22:-1} # the two allAxiomNames lists agree (enforced)
C22_A="FormalSystem/Automation/AxiomNames.lean"
C22_B="FormalSystem/Automation/ProofStepExport.lean"
if [ ! -f "$C22_A" ] || [ ! -f "$C22_B" ]; then
  fail C22 "one of the two allAxiomNames modules is missing"
else
  c22_names() {
    awk '/^def allAxiomNames/,/^[[:space:]]*\][[:space:]]*$/' "$1" \
      | grep -oE '"[a-zA-Z_][a-zA-Z0-9_]*"' | tr -d '"' | sort -u
  }
  C22_NA=$(c22_names "$C22_A")
  C22_NB=$(c22_names "$C22_B")
  C22_CA=$(printf '%s' "$C22_NA" | grep -c . || true)
  C22_CB=$(printf '%s' "$C22_NB" | grep -c . || true)
  C22_ONLY_A=$(comm -23 <(printf '%s\n' "$C22_NA") <(printf '%s\n' "$C22_NB") | grep . || true)
  C22_ONLY_B=$(comm -13 <(printf '%s\n' "$C22_NA") <(printf '%s\n' "$C22_NB") | grep . || true)
  if [ "$C22_CA" -eq 0 ] || [ "$C22_CB" -eq 0 ]; then
    fail C22 "could not extract an allAxiomNames list from one of the two modules"
  elif [ -z "$C22_ONLY_A" ] && [ -z "$C22_ONLY_B" ]; then
    pass C22 "the two allAxiomNames lists agree ($C22_CA names each)"
  else
    MSG="the two allAxiomNames lists disagree ($C22_CA vs $C22_CB names)"
    if [ "$ENFORCE_C22" -eq 1 ]; then fail C22 "$MSG"; else soft C22 "$MSG (not yet enforced)"; fi
    [ -n "$C22_ONLY_A" ] && printf '%s\n' "$C22_ONLY_A" \
      | while IFS= read -r l; do note "only in AxiomNames.lean: $l"; done
    [ -n "$C22_ONLY_B" ] && printf '%s\n' "$C22_ONLY_B" \
      | while IFS= read -r l; do note "only in ProofStepExport.lean: $l"; done
    note "both lists must be updated in the same change; neither file imports the other"
  fi
fi
echo

# ---------------------------------------------------------------------------
# C24: every FormalSystem module (transitively) imports FormalSystem.Init
#
# `FormalSystem/Init.lean` is this library's root file, modelled on `Mathlib.Init`
# and on CSLib's `Cslib/Init.lean`: the single place from which repository-wide
# linter options, `set_option` defaults and common tactic imports are meant to be
# inherited. That guarantee is worth exactly as much as its weakest module -- a
# file with no path to `Init` silently opts out of every option the root sets, and
# nothing about a green build reveals it. This check is what makes the root's
# promise an invariant rather than a convention.
#
# `lake exe checkInitImports` reads the real import graph out of the compiled
# environment (`CoreM.withImportModules #[`FormalSystem]` plus ImportGraph's
# transitive closure), not out of the text of the `import` lines, so it sees
# inheritance through intermediate modules exactly as Lean does. The property is
# carried by the eleven minimal elements of the internal DAG -- the modules with no
# `FormalSystem.*` import of their own -- so the tree satisfies this with eleven
# import lines, not one per module.
#
# Ships ENFORCED, with no soft period, and this is deliberate: unlike C8/C9/C10,
# whose debt was still outstanding the day they were written, the adoption work
# landed in the same change as this block, so the check is green from its first
# run. A soft period here would only create a window in which the invariant could
# regress unnoticed. Never flip ENFORCE_C24 to 0 to quiet a failure -- add the
# missing import at the offending module's own minimal element instead, or, if the
# module genuinely cannot depend on `FormalSystem.*` (the `ForMathlib` upstreaming
# rule is the one live instance), record it in `exceptions` in
# scripts/CheckInitImports.lean with its reason written beside it.
#
# Inside the RUN_BUILD guard because `CoreM.withImportModules` loads `.olean`s: the
# check cannot run at all without a built tree, so under --no-build it reports
# INFO and skips, exactly as C16 and C2 do.
#
# Negative-tested per docs/development/MODULE_INVARIANTS.md's "Adding a Check"
# mandate: the import line was removed from one low-fan-out leaf, this block was
# observed to report FAIL C24 with a non-zero script exit, and the line was
# restored and the PASS re-observed. Re-run that test after any change to this
# check's scope or to CheckInitImports.lean's exit path -- the executable
# previously returned `diff.length.toUInt32`, which an 8-bit exit status truncates,
# so it would have reported failure while handing the shell a 0 at any count that
# happened to be a multiple of 256.
# ---------------------------------------------------------------------------
if [ "$RUN_BUILD" -eq 1 ]; then
  C24_LOG=$(mktemp)
  if lake exe checkInitImports >"$C24_LOG" 2>&1; then
    pass C24 "every FormalSystem module transitively imports FormalSystem.Init"
  else
    MSG="module(s) in the FormalSystem root closure do not transitively import FormalSystem.Init"
    if [ "$ENFORCE_C24" -eq 1 ]; then fail C24 "$MSG"; else soft C24 "$MSG (not yet enforced)"; fi
    grep -m1 '^error: ' "$C24_LOG" | while IFS= read -r l; do note "$l"; done
    tail -20 "$C24_LOG" | while IFS= read -r l; do note "$l"; done
    note "add the import at the offending module's own minimal element (a module with no FormalSystem.* import), not one line per module"
  fi
  rm -f "$C24_LOG"
else
  info C24 "FormalSystem.Init transitive-import check skipped (--no-build)"
fi
echo

# ---------------------------------------------------------------------------
# C25: every `lean_exe` root declared in lakefile.lean compiles
#
# `lake build` builds the two library targets, so it elaborates exactly what is
# reachable from `FormalSystem` and `BimodalTest`. Every `lean_exe` root is outside
# both closures: nothing imports it, `lake build` never touches it, and C24's
# closure walk never reaches it either. C6's rot guard does not cover them either --
# C6 seeds its reachability walk from every `root :=` in this same lakefile, so an
# exe root is *reachable* by C6's definition and listing one in
# scripts/module-invariants-manifest.txt trips C6's stale-manifest branch instead of
# covering it. That is the wrong mechanism; this check is the right one, and the
# manifest must not gain an exe-root line.
#
# The gap was not hypothetical. FormalSystem/Automation/ProofStepExport.lean -- the
# `proof_extractor` root -- failed to elaborate for an extended period with three
# `Application type mismatch` errors masking a further 873, and no gate anywhere in
# the repository was able to observe it. `lake exe proof_extractor` was simply
# broken, and the tree was green.
#
# The root list is scraped from lakefile.lean at run time with the same regex C6's
# reachability block uses, so a newly declared `lean_exe` is covered the day it is
# added and there is no second list to forget to update. An empty scrape is a
# failure, not a silent pass: it means the regex or the lakefile's shape changed.
#
# Module targets, never exe targets. `lake build <root>` elaborates and emits C
# without linking; `lake exe <name>` would link a 240-310 MB binary per root, and
# there are thirteen of them. Elaboration coverage is what this invariant is about.
# Measured cost with the tree already built by C1, which is the position this check
# runs in: 10s wall-clock for all thirteen roots.
#
# Ships ENFORCED with no soft period, on the C24 precedent: the ProofStepExport
# repair landed in the same change, so every root is green from the first run and a
# soft window would only be a window in which the invariant could regress unnoticed.
#
# Inside the RUN_BUILD guard because it is a build; under --no-build it reports INFO
# and skips, exactly as C1/C2/C6/C16/C24 do.
#
# Negative-tested per docs/development/MODULE_INVARIANTS.md's "Adding a Check"
# mandate: a one-character break was introduced in
# FormalSystem/Automation/TraceExporter.lean -- deliberately NOT ProofStepExport,
# the module the same change repairs, since a failure there would prove nothing
# about the gate -- `FAIL C25` was observed together with a non-zero script exit
# (both, not just the printed line: `FAIL C25  1 of 13 lean_exe root module(s) do
# not compile`, script exit 1), and the file was restored and the `PASS` and exit 0
# re-observed. The sharpest part of that observation is what did NOT fail: C1
# reported `lake build exits 0` in the same run, because the broken module is
# outside the closure `lake build` walks. That is precisely the invisible-failure
# condition this check exists to close. Re-run that test after any change to this check's scope or to
# the root-scraping regex; check the shell's exit status as well as the printed
# line, because C24's history is exactly a case of a check that could print a
# failure while handing the shell a 0.
# ---------------------------------------------------------------------------
if [ "$RUN_BUILD" -eq 1 ]; then
  # Scraped once, near C16 -- see "The lakefile root scrape" above. An empty list is still a
  # failure here, not a silent pass: it means the regex or the lakefile's shape changed.
  C25_ROOTS="$LAKE_EXE_ROOTS"
  C25_ROOT_COUNT=$(printf '%s\n' "$C25_ROOTS" | grep -c . || true)
  if [ "$C25_ROOT_COUNT" -eq 0 ]; then
    fail C25 "no lean_exe root scraped from lakefile.lean -- the scraper regex or the lakefile's shape changed"
    note "expected one or more \`root := \\\`Module.Name\` lines in lakefile.lean"
  else
    C25_LOG=$(mktemp)
    C25_BROKEN=""
    while IFS= read -r C25_ROOT; do
      [ -n "$C25_ROOT" ] || continue
      if ! lake build "$C25_ROOT" >"$C25_LOG" 2>&1; then
        C25_BROKEN="${C25_BROKEN}${C25_ROOT}"$'\n'
        grep -m3 '^error: ' "$C25_LOG" | while IFS= read -r l; do note "$C25_ROOT: $l"; done
      fi
    done <<< "$C25_ROOTS"
    rm -f "$C25_LOG"
    C25_BROKEN_COUNT=$(printf '%s\n' "$C25_BROKEN" | grep -c . || true)
    if [ "$C25_BROKEN_COUNT" -eq 0 ]; then
      pass C25 "all $C25_ROOT_COUNT lean_exe root module(s) from lakefile.lean compile"
    else
      MSG="$C25_BROKEN_COUNT of $C25_ROOT_COUNT lean_exe root module(s) do not compile"
      if [ "$ENFORCE_C25" -eq 1 ]; then fail C25 "$MSG"; else soft C25 "$MSG (not yet enforced)"; fi
      printf '%s\n' "$C25_BROKEN" | grep . | while IFS= read -r l; do note "broken root: $l"; done
      note "repair the root, or drop its lean_exe target; do NOT add it to scripts/module-invariants-manifest.txt (C6 fails on an exe-root line by construction)"
    fi
  fi
else
  info C25 "lean_exe root compile check skipped (--no-build)"
fi
echo

# ---------------------------------------------------------------------------
# C26: snake_case `def`/`abbrev` names, and in-source `nolint` attributes
#
# The four blind spots this closes are enumerated at ENFORCE_C26 above. What follows is
# how the scan itself is built, and every exemption in it with its reason.
#
# SCOPE: every live `*.lean` file under FormalSystem/, via the same `Boneyard`-pruning walk
# C16's textual half uses. No import closure is consulted anywhere in this block -- that is
# precisely what makes an out-of-closure module and a `private` declaration visible.
#
# DECLARATION KINDS: `def` and `abbrev` only.
#   -- `theorem` is excluded because snake_case is the CORRECT Mathlib convention for a
#      proposition, and the upstream linter's own `isDefinition` guard excludes it too.
#   -- `instance` is excluded on measured evidence, not on taste. All 23 live snake_case
#      `instance` declarations were probed by elaboration against the built oleans, and every
#      one of them is recorded by Lean as a `thmInfo`, not a `defnInfo` -- they are Prop-valued
#      instances, for which snake_case is again the correct convention, and which is exactly why
#      `defsWithUnderscore` never fires on them. A scan that did not exempt `instance` would
#      start life red on 23 conformant names. RESIDUAL, stated rather than hidden: a
#      data-valued (`Type`-valued) `instance` with an underscored name would be a genuine
#      violation and this exemption would miss it. There are none today; the reporting-only
#      env_linter sweep over every lakefile root (C16, second half) is what would see one,
#      because that half elaborates and can tell a `defnInfo` from a `thmInfo`.
#   -- STRUCTURE FIELDS are likewise out of scope for this textual half, and this is the same
#      distinction again. Lean turns each field into a projection `def`, so a data-valued field
#      with an underscored name IS a `defsWithUnderscore` violation -- 20 live ones exist, all
#      auto-generated projections of one `structure` in an out-of-closure module. But 188
#      structure fields tree-wide are textually snake_case and the overwhelming majority are
#      Prop-valued, hence theorems, hence correctly named: `runLinter FormalSystem` reports zero
#      on all of them. Prop-ness is not decidable from the source text, so flagging fields here
#      would be 188 findings to catch 20. Field-shaped violations are assigned to the
#      elaboration-based sweep instead, where the distinction is free.
#
# VISIBILITY: `private` declarations are IN scope. This is blind spot (4), and it is the one
# thing no env_linter can ever do.
#
# NAMING RULE, deliberately not `isBadNameWithUnderscore`: strip a leading `_root_.`, take the
# last dot-component, and flag it when it contains an underscore that is not in TRAILING
# position. Flagging a name whose last component ends `_1`/`_2`/`_mathlib` is blind spot (3).
# Not flagging a purely TRAILING underscore is a required carve-out, not a softening: `true` and
# `false` are keywords, so `MonadicFormula.true_` and `MonadicFormula.false_`
# (Metalogic/WeakCanonical/MonadicFO.lean) disambiguate by suffix and are correct as written.
# Those two names are the measured reason the rule reads "not trailing" rather than "no
# underscore at all".
#
# Runs regardless of --no-build: it reads source text and needs no oleans, exactly as C16's
# textual half and C23 do.
# ---------------------------------------------------------------------------
python3 - <<'PYEOF'
import os, re, sys

def live_lean_files(base):
    out = []
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d != "Boneyard"]
        for f in files:
            if f.endswith(".lean"):
                out.append(os.path.join(root, f))
    return sorted(out)

# Same walk vocabulary as C16's textual half / C23, so there is one namespace model in this
# script rather than four.
NS_OPEN = re.compile(r"^namespace\s+([A-Za-z_][A-Za-z0-9_'.]*)")
SECTION = re.compile(r"^section(?:\s+[A-Za-z_][A-Za-z0-9_']*)?\s*$")
END = re.compile(r"^end(?:\s+([A-Za-z_][A-Za-z0-9_'.]*))?\s*$")
DECL = re.compile(
    r"^\s*(?:@\[[^\]]*\]\s*)?(?:(private)\s+|protected\s+|noncomputable\s+|scoped\s+"
    r"|local\s+|partial\s+|unsafe\s+)*"
    r"(def|abbrev)\s+"
    r"([^\s\(\{\[:]+)")

def last_component(name):
    if name.startswith("_root_."):
        name = name[len("_root_."):]
    return name.split(".")[-1]

def underscored(name):
    # An underscore anywhere but the trailing position. See the NAMING RULE note above for why
    # a purely trailing underscore is correct rather than tolerated.
    return "_" in last_component(name).rstrip("_")

bad = []
for path in live_lean_files("FormalSystem"):
    stack, frames, depth = [], [], 0
    try:
        lines = open(path, encoding="utf-8", errors="replace").readlines()
    except OSError:
        continue
    for i, raw in enumerate(lines, 1):
        opens, closes = raw.count("/-"), raw.count("-/")
        in_comment = depth > 0
        depth += opens - closes
        if depth < 0:
            depth = 0
        if in_comment:
            continue
        line = raw.strip()
        if line.startswith("--"):
            continue
        m = NS_OPEN.match(line)
        if m:
            segs = m.group(1).split(".")
            stack.extend(segs); frames.append(len(segs)); continue
        if SECTION.match(line):
            frames.append(0); continue
        if END.match(line):
            if frames:
                n = frames.pop()
                if n:
                    stack = stack[:-n] if n <= len(stack) else []
            continue
        m = DECL.match(line)
        if m and underscored(m.group(3)):
            bad.append((path, i, m.group(3), m.group(1) is not None))

failed = False

if not bad:
    print("PASS  C26  zero snake_case `def`/`abbrev` names in the live tree (textual scan:\n"
          "            out-of-closure modules, `private` declarations and `_1`/`_2`-shaped\n"
          "            names all in view)")
else:
    print(f"FAIL  C26  {len(bad)} snake_case `def`/`abbrev` name(s) in the live tree")
    for path, l, n, priv in bad[:10]:
        print(f"            {path}:{l}: {'private ' if priv else ''}{n}")
    if len(bad) > 10:
        print(f"            ... and {len(bad) - 10} more")
    print("            rename to lowerCamelCase. A green `lake exe runLinter FormalSystem` is")
    print("            NOT evidence against this finding -- see the four blind spots at")
    print("            ENFORCE_C26 in this script.")
    failed = True

# --- C26 half two: the in-source `nolint` attribute inventory (blind spot 2) ----------------
#
# Both attribute forms are matched: `@[... nolint X ...]` decorating the declaration that
# follows it, and `attribute [nolint X] a b c`, whose name list may run onto indented
# continuation lines (the `defsWithUnderscore` site does exactly that, one name per line with a
# trailing comment on each). A pair is keyed by (linter, name-as-written): the as-written form
# is what a reviewer sees in the diff, and matching on it is what makes the allow-list checkable
# against the source rather than against a resolved environment this half never builds.
#
# The failure is folded into the SAME check id and the same exit status as half one, and both
# halves always print. Neither can mask the other.

ALLOWLIST = os.path.join("scripts", "nolint-attribute-allowlist.txt")
allowed, allow_seen = set(), set()
try:
    for entry in open(ALLOWLIST, encoding="utf-8"):
        entry = entry.split("#", 1)[0].strip()
        if entry:
            allowed.add(entry)
except OSError:
    print(f"FAIL  C26  companion file {ALLOWLIST} is missing or unreadable")
    print("            C26's second half asserts this file against the tree; without it every")
    print("            in-source nolint attribute would silently become unreviewed again.")
    failed = True

NOLINT_ATTR = re.compile(r"^\s*attribute\s*\[([^\]]*)\]\s*(.*)$")
DECORATOR = re.compile(r"^\s*@\[([^\]]*)\]\s*(.*)$")
ANY_DECL = re.compile(
    r"^\s*(?:private\s+|protected\s+|noncomputable\s+|scoped\s+|local\s+|partial\s+"
    r"|unsafe\s+)*"
    r"(?:def|abbrev|theorem|instance|structure|inductive|class|opaque|axiom)\s+"
    r"([^\s\(\{\[:]+)")
IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_'.!?]*$")

def linters_in(bracket):
    return re.findall(r"nolint\s+([A-Za-z_][A-Za-z0-9_']*)", bracket)

def names_in(text):
    text = text.split("--", 1)[0]
    return [t for t in text.split() if IDENT.match(t)]

unlisted = []
for path in live_lean_files("FormalSystem"):
    try:
        lines = open(path, encoding="utf-8", errors="replace").readlines()
    except OSError:
        continue
    depth = 0
    i = 0
    while i < len(lines):
        raw = lines[i]
        opens, closes = raw.count("/-"), raw.count("-/")
        in_comment = depth > 0
        depth += opens - closes
        if depth < 0:
            depth = 0
        if in_comment or raw.strip().startswith("--"):
            i += 1
            continue

        m = NOLINT_ATTR.match(raw)
        if m and linters_in(m.group(1)):
            names = names_in(m.group(2))
            j = i + 1
            while j < len(lines):
                cont = lines[j]
                if cont.strip() == "" or not cont[:1].isspace():
                    break
                got = names_in(cont)
                if not got:
                    break
                names.extend(got)
                j += 1
            for lint in linters_in(m.group(1)):
                for nm in names:
                    key = f"{lint}:{nm}"
                    allow_seen.add(key)
                    if key not in allowed:
                        unlisted.append((path, i + 1, key))
            i = j
            continue

        m = DECORATOR.match(raw)
        if m and linters_in(m.group(1)):
            # The decorated declaration is the rest of this line, or the next declaration line.
            target, j = None, i
            rest = m.group(2)
            d = ANY_DECL.match(rest)
            if d:
                target = d.group(1)
            else:
                j = i + 1
                while j < len(lines) and j < i + 12:
                    nxt = lines[j]
                    if nxt.strip() == "" or nxt.strip().startswith("--"):
                        j += 1
                        continue
                    d = ANY_DECL.match(nxt)
                    if d:
                        target = d.group(1)
                    break
            for lint in linters_in(m.group(1)):
                key = f"{lint}:{target if target else '<unresolved>'}"
                allow_seen.add(key)
                if key not in allowed:
                    unlisted.append((path, i + 1, key))
        i += 1

if unlisted:
    print(f"FAIL  C26  {len(unlisted)} in-source `nolint` attribute(s) not on {ALLOWLIST}")
    for path, l, key in unlisted[:10]:
        print(f"            {path}:{l}: {key}")
    if len(unlisted) > 10:
        print(f"            ... and {len(unlisted) - 10} more")
    print("            An in-source nolint produces NO finding, so nothing else in this")
    print("            repository can see it. Either remove the attribute and fix the")
    print("            declaration, or add a reasoned entry to the allow-list.")
    failed = True
else:
    print(f"PASS  C26  all {len(allow_seen)} in-source `nolint` attribute pair(s) are on\n"
          f"            {ALLOWLIST}")

stale = sorted(allowed - allow_seen)
if stale:
    print(f"INFO  C26  {len(stale)} allow-list entr(y/ies) match nothing in the tree")
    for key in stale[:10]:
        print(f"            {key}")
    print(f"            remove them from {ALLOWLIST}; a stale exemption is how such a file")
    print("            turns into a dumping ground.")

if failed:
    sys.exit(1)
PYEOF
C26_STATUS=$?
if [ "$C26_STATUS" -ne 0 ] && [ "$ENFORCE_C26" -eq 1 ]; then
  FAILURES=$((FAILURES + 1))
fi
echo

# ---------------------------------------------------------------------------
# C9-DOCS: task-number citations under docs/
#
# `.claude/rules/no-task-references-in-deliverables.md` binds docs/ exactly as it
# binds FormalSystem/, but docs/ does not yet satisfy it. Following this script's
# own documented pattern for an end-state invariant the tree has not reached, the
# computation runs from the outset and is REPORTED at every gate, while only the
# flag controls whether it affects the exit code.
#
# Do not silently omit this check to keep the gate quiet, and do not flip the flag
# to 0 once it is 1. Clear the citations instead.
# ---------------------------------------------------------------------------
DOCS_TASK_REFS=$(grep -rniE --include='*.md' \
  '\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b|specs/[0-9]{3}_[A-Za-z0-9_]+' docs 2>/dev/null || true)
DOCS_TASK_REF_COUNT=$(printf '%s' "$DOCS_TASK_REFS" | grep -c . || true)
if [ "$DOCS_TASK_REF_COUNT" -eq 0 ]; then
  pass C9D "zero task-number citations under docs/"
else
  MSG="$DOCS_TASK_REF_COUNT task-number citation(s) under docs/ (use a durable anchor instead)"
  if [ "$ENFORCE_C9_DOCS" -eq 1 ]; then fail C9D "$MSG"; else soft C9D "$MSG (not yet enforced)"; fi
  printf '%s\n' "$DOCS_TASK_REFS" | cut -d: -f1 | sort | uniq -c | sort -rn | head -5 \
    | while IFS= read -r l; do note "$l"; done
  note "set ENFORCE_C9_DOCS=1 to make this exit-code-affecting once the citations are cleared"
fi
echo

# ---------------------------------------------------------------------------
echo "==========================================================="
if [ "$FAILURES" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
  exit 0
else
  echo "$FAILURES CHECK GROUP(S) FAILED"
  exit 1
fi
