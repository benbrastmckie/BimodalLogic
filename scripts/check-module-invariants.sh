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
#   C9  Zero task-number citations under FormalSystem/
#   C10 Zero references to the pre-relocation docs/latex/typst paths
#   C11 Every import inside FormalSystem/Boneyard/ resolves, or is waived
#   C12 Every slash-shaped source path in docs/ + README.md resolves
#   C13 Every relative markdown link in docs/ + README.md resolves
#   C14 Documented axiom/sorry counts match the tree -- in docs/, README.md AND
#       FormalSystem/**/*.lean docstrings; axiom sets of the two headline
#       theorems C2 does not cover match their baseline
#   C15 Every paper-anchor citation in live scope resolves against the pinned
#       record (manifest row, or an explicit KNOWN-ANCHORS row)
#   C9D Task-number citations under docs/ (computed always, soft by default)
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
#   bash scripts/check-module-invariants.sh --no-build # skip C1/C2/C6 (fast structural pass)
#
# Companion files:
#   scripts/module-invariants-manifest.txt   known-unreachable live modules (C6)
#   scripts/module-invariants-allowlist.txt  pre-existing unresolved md paths (C5)
#   scripts/boneyard-import-waivers.txt    unrepairable archived imports (C11)
#   scripts/markdown-slash-path-allowlist.txt  hypothetical slash paths (C12)
#   scripts/markdown-link-allowlist.txt        link-syntax-illustration files (C13)
#   specs/paper-definitions-of-record.md       pinned paper anchors + known-anchor rows (C15)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

MANIFEST="scripts/module-invariants-manifest.txt"
ALLOWLIST="scripts/module-invariants-allowlist.txt"
WAIVERS="scripts/boneyard-import-waivers.txt"
SLASH_ALLOWLIST="scripts/markdown-slash-path-allowlist.txt"
LINK_ALLOWLIST="scripts/markdown-link-allowlist.txt"

RUN_BUILD=1
[ "${1:-}" = "--no-build" ] && RUN_BUILD=0

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
'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
BASELINE

if [ "$RUN_BUILD" -eq 1 ]; then
  AX_SRC=$(mktemp --suffix=.lean)
  cat >"$AX_SRC" <<'LEAN'
import FormalSystem
#print axioms FormalSystem.Metalogic.BXCanonical.completeness
#print axioms FormalSystem.Metalogic.BXCanonical.completeness_dense
#print axioms FormalSystem.Metalogic.BXCanonical.completeness_discrete
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

def live_files(base, ext):
    out = []
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d != "Boneyard"]
        for f in files:
            if f.endswith(ext):
                out.append(os.path.join(root, f))
    return sorted(out)

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
# Allowlisted exception: `FormalSystem.lean` + `FormalSystem/FormalSystem.lean`.
# That pair is the Lake `lean_lib FormalSystem` root (`srcDir := "."`,
# `roots := #[`FormalSystem]`), so the self-named indirection is load-bearing, not a
# convention violation.
C8_ALLOW_SELFNAMED = {"FormalSystem/FormalSystem.lean"}
c8_problems = []
for parent in ("FormalSystem", "FormalSystem/Metalogic"):
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
    pas("C8", "every FormalSystem/ and Metalogic/ subdirectory has exactly one sibling aggregator")

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
# C9: no task-number citations under FormalSystem/
#
# `.claude/rules/no-task-references-in-deliverables.md` forbids ephemeral
# task-management identifiers in deliverable files. Task numbers are renumbered
# by vault operations and mean nothing to a future reader of a README.
# ---------------------------------------------------------------------------
TASK_REFS=$(grep -rniE --include='*.lean' --include='*.md' \
  '\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b' FormalSystem 2>/dev/null | grep -v '/Boneyard/')
TASK_REF_COUNT=$(printf '%s' "$TASK_REFS" | grep -c . || true)
if [ "$TASK_REF_COUNT" -eq 0 ]; then
  pass C9 "zero task-number citations under FormalSystem/"
else
  MSG="$TASK_REF_COUNT task-number citation(s) under FormalSystem/ (use a durable anchor instead)"
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
#        cover, so that the decidability soundness bridge and Dedekind
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
# which omits the Dedekind layer; 21, 14 and 44 are older figures still.
# Scope note: `FormalSystem` is scanned for `*.lean` only, and Boneyard/ is excluded --
# archived modules are not documentation and are allowed to carry historical figures.
STALE_AXIOMS=$(grep -rniE --include='*.md' \
  '\b(14|21|42|44)[[:space:]]+(axiom|constructor)' docs README.md 2>/dev/null || true)
# The trailing `grep -i axiom` is a PRECISION guard, not a weakening: `.lean` sources
# carry constructor counts for types other than `Axiom` (e.g. `EnrichedFormula`'s 21
# constructors in Automation/Normalization.lean), and a bare "21 constructors" in such
# a docstring is a correct statement about a different type. Requiring the word "axiom"
# somewhere on the line keeps the tripwire aimed at axiom-count claims. The markdown
# half above is deliberately left exactly as it was -- this is a widening of C14's
# scope, not a rewrite of its existing behavior.
STALE_AXIOMS_LEAN=$(grep -rniE --include='*.lean' \
  '\b(14|21|42|44)[[:space:]]+(axiom|constructor)' FormalSystem 2>/dev/null \
  | grep -v '/Boneyard/' | grep -i 'axiom' || true)
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
# the five termini: strongCompletenessBase, strongCompletenessDense, notCompactDiscrete,
# notCompactDedekind, consequence_completeness_dedekind.
#
# Four entries carry a STRICT SUBSET of [propext, Classical.choice, Quot.sound], recorded
# literally rather than rounded up: setConsequence_of_not_satisfiable, satisfiableSet_iff_
# finitelySatisfiable and modelExistence_iff_finitelySatisfiable are [propext], and
# qDepth_qAlpha is [propext, Quot.sound]. A smaller dependency is not a regression.
read -r -d '' C14_BASELINE <<'C14BASE'
'FormalSystem.Metalogic.Decidability.sound_of_isValid' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.completeness_dedekind' depends on axioms: [propext, Classical.choice, Quot.sound]
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
'FormalSystem.Metalogic.consequence_completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_discrete_consequence' depends on axioms: [propext, Classical.choice, Quot.sound]
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
'FormalSystem.Metalogic.notStrongCompletenessDiscrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.qDepth_qAlpha' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.dedWitness_core' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedWitness_not_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedWitness_finitely_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.notStrongCompletenessDedekind' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.modelExistenceDedekind_refuted' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmComplete_iff_forward' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmCompleteBase_iff_forwardBase' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmCompleteDiscrete_iff_forwardDiscrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmCompleteDense_iff_forwardDense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.tmCompleteDedekind_iff_forwardDedekind' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.qAlpha_step' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.exists_strictMono_qPoints' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.setConsequence_iff_not_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.satisfiableSet_iff_finitelySatisfiable' depends on axioms: [propext]
'FormalSystem.Metalogic.modelExistence_iff_finitelySatisfiable' depends on axioms: [propext]
C14BASE

if [ "$RUN_BUILD" -eq 1 ]; then
  C14_SRC=$(mktemp --suffix=.lean)
  cat >"$C14_SRC" <<'C14LEAN'
import FormalSystem
#print axioms FormalSystem.Metalogic.Decidability.sound_of_isValid
#print axioms FormalSystem.Metalogic.completeness_dedekind
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
#print axioms FormalSystem.Metalogic.consequence_completeness_discrete
#print axioms FormalSystem.Metalogic.completeness_discrete
#print axioms FormalSystem.Metalogic.soundness_discrete_consequence
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
#print axioms FormalSystem.Metalogic.notStrongCompletenessDiscrete
#print axioms FormalSystem.Metalogic.qDepth_qAlpha
#print axioms FormalSystem.Metalogic.dedWitness_core
#print axioms FormalSystem.Metalogic.dedWitness_not_satisfiable
#print axioms FormalSystem.Metalogic.dedWitness_finitely_satisfiable
#print axioms FormalSystem.Metalogic.notStrongCompletenessDedekind
#print axioms FormalSystem.Metalogic.modelExistenceDedekind_refuted
#print axioms FormalSystem.Metalogic.tmComplete_iff_forward
#print axioms FormalSystem.Metalogic.tmCompleteBase_iff_forwardBase
#print axioms FormalSystem.Metalogic.tmCompleteDiscrete_iff_forwardDiscrete
#print axioms FormalSystem.Metalogic.tmCompleteDense_iff_forwardDense
#print axioms FormalSystem.Metalogic.tmCompleteDedekind_iff_forwardDedekind
#print axioms FormalSystem.Metalogic.qAlpha_step
#print axioms FormalSystem.Metalogic.exists_strictMono_qPoints
#print axioms FormalSystem.Metalogic.setConsequence_iff_not_satisfiable
#print axioms FormalSystem.Metalogic.satisfiableSet_iff_finitelySatisfiable
#print axioms FormalSystem.Metalogic.modelExistence_iff_finitelySatisfiable
C14LEAN
  C14_OUT=$(lake env lean "$C14_SRC" 2>&1 \
    | sed -e ':a' -e '$!N' -e 's/\n / /' -e 'ta' -e 'P' -e 'D' \
    | grep 'depends on axioms')
  rm -f "$C14_SRC"
  if [ "$C14_OUT" = "$C14_BASELINE" ]; then
    pass C14 "decidability soundness, Dedekind completeness and Base/Dense strong completeness match their axiom baseline"
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
  '\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b' docs 2>/dev/null || true)
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
