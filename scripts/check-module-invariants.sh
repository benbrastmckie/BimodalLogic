#!/usr/bin/env bash
# check-module-invariants.sh
#
# Phase-gate harness for the Lean source tree. Turns "the reorganization did not
# break anything" into a single command with a non-zero exit on any failure.
#
# Checks:
#   B0  Boneyard exclusion self-test (BOTH Boneyards must be found and excluded)
#   C1  `lake build` exits 0
#   C2  `#print axioms` for the four flagship theorems matches the recorded baseline
#   C3  Exactly one structural `sorry`, located BY CONTENT (never by line number)
#   C4  Every `import Bimodal.*` / `import BimodalTest.*` resolves to a real file
#   C5  Every module-shaped `Bimodal.*` path in non-specs markdown resolves
#   C6  Known-unreachable live modules still compile (rot guard)
#   C7  Live inventory (informational, never asserted)
#   C8  Aggregator convention: sibling `X.lean` beside `X/`, no `X/X.lean`
#   C9  Zero task-number citations under Theories/
#   C10 Zero references to the pre-relocation docs/latex/typst paths
#
# Every filesystem traversal excludes BOTH Boneyards via `-not -path '*/Boneyard/*'`.
# A filter naming only the top-level Boneyard silently sweeps ~27k archived lines
# from the Kamp-local Boneyard into the "live" counts.
#
# Usage:
#   bash scripts/check-module-invariants.sh            # all checks
#   bash scripts/check-module-invariants.sh --no-build # skip C1/C2/C6 (fast structural pass)
#
# Companion files:
#   scripts/module-invariants-manifest.txt   known-unreachable live modules (C6)
#   scripts/module-invariants-allowlist.txt  pre-existing unresolved md paths (C5)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

MANIFEST="scripts/module-invariants-manifest.txt"
ALLOWLIST="scripts/module-invariants-allowlist.txt"

RUN_BUILD=1
[ "${1:-}" = "--no-build" ] && RUN_BUILD=0

# Enforcement flags. C8/C9/C10 describe end-state invariants that the tree does
# not satisfy until the corresponding reorganization work lands. Each is computed
# and reported from the outset -- so progress is visible at every gate -- but only
# becomes exit-code-affecting once its flag flips to 1. Never flip a flag to 0 to
# make a gate pass; that is what the flag exists to prevent.
ENFORCE_C8=${ENFORCE_C8:-1}   # aggregator convention (enforced)
ENFORCE_C9=${ENFORCE_C9:-1}   # no task-number citations under Theories/ (enforced)
ENFORCE_C10=${ENFORCE_C10:-1} # no stale docs/latex/typst paths (enforced)

FAILURES=0
pass() { printf 'PASS  %-4s %s\n' "$1" "$2"; }
fail() { printf 'FAIL  %-4s %s\n' "$1" "$2"; FAILURES=$((FAILURES + 1)); }
info() { printf 'INFO  %-4s %s\n' "$1" "$2"; }
note() { printf '            %s\n' "$1"; }
# Report a not-yet-enforced check: visible, but does not affect the exit code.
soft() { printf 'TODO  %-4s %s\n' "$1" "$2"; }

# Shared find filter. Both Boneyards are excluded by the single `*/Boneyard/*`
# pattern; B0 asserts that this pattern really matches two distinct directories.
live_lean() {
  find "$@" -name '*.lean' -not -path '*/Boneyard/*'
}

echo "=== Module invariants: $(git rev-parse --short HEAD 2>/dev/null || echo 'no-git') ==="
echo

# ---------------------------------------------------------------------------
# B0: Boneyard exclusion self-test
# ---------------------------------------------------------------------------
mapfile -t BONEYARDS < <(find Theories -type d -name Boneyard | sort)
if [ "${#BONEYARDS[@]}" -eq 2 ]; then
  pass B0 "Boneyard exclusion covers exactly 2 directories"
  for b in "${BONEYARDS[@]}"; do note "$b"; done
else
  fail B0 "expected 2 Boneyard directories, found ${#BONEYARDS[@]}"
  for b in "${BONEYARDS[@]}"; do note "$b"; done
fi
# Prove the exclusion is load-bearing: archived files must not be in the live set.
ALL_LEAN=$(find Theories -name '*.lean' | wc -l)
LIVE_LEAN=$(live_lean Theories | wc -l)
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
'Bimodal.Metalogic.BXCanonical.completeness' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'Bimodal.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'Bimodal.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'Bimodal.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
BASELINE

if [ "$RUN_BUILD" -eq 1 ]; then
  AX_SRC=$(mktemp --suffix=.lean)
  cat >"$AX_SRC" <<'LEAN'
import Bimodal
#print axioms Bimodal.Metalogic.BXCanonical.completeness
#print axioms Bimodal.Metalogic.BXCanonical.completeness_dense
#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete
#print axioms Bimodal.Metalogic.BXCanonical.Chronicle.countermodel_dense
LEAN
  AX_OUT=$(lake env lean "$AX_SRC" 2>&1 | grep 'depends on axioms')
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
# C3: the sole structural sorry, asserted BY CONTENT
#
# Never assert a line number: the enclosing theorem is found by scanning
# backwards from the sorry to the nearest declaration header.
# ---------------------------------------------------------------------------
SORRY_HITS=$(grep -rnE --include='*.lean' \
  '(^[[:space:]]*sorry[[:space:]]*$)|(:=[[:space:]]*sorry[[:space:]]*$)|(\bexact sorry\b)|(<;> sorry)' \
  Theories | grep -v '/Boneyard/')
SORRY_COUNT=$(printf '%s' "$SORRY_HITS" | grep -c . || true)

if [ "$SORRY_COUNT" -ne 1 ]; then
  fail C3 "expected exactly 1 structural sorry, found $SORRY_COUNT"
  while IFS= read -r l; do note "$l"; done <<<"$SORRY_HITS"
else
  SORRY_FILE=${SORRY_HITS%%:*}
  SORRY_LINE=$(printf '%s' "$SORRY_HITS" | cut -d: -f2)
  EXPECTED_FILE="Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean"
  EXPECTED_THM="countermodel_discrete"
  ENCLOSING=$(awk -v n="$SORRY_LINE" '
    NR <= n && /^[[:space:]]*(private[[:space:]]+|protected[[:space:]]+|noncomputable[[:space:]]+)*(theorem|lemma|def|example|instance)[[:space:]]+/ {
      last = $0
    }
    END { print last }' "$SORRY_FILE" 2>/dev/null)
  if [ "$SORRY_FILE" != "$EXPECTED_FILE" ]; then
    fail C3 "sole sorry moved file: expected $EXPECTED_FILE, found $SORRY_FILE"
  elif ! printf '%s' "$ENCLOSING" | grep -q "\b${EXPECTED_THM}\b"; then
    fail C3 "sole sorry is no longer inside 'theorem $EXPECTED_THM'"
    note "enclosing declaration: $ENCLOSING"
  else
    pass C3 "sole structural sorry is in theorem $EXPECTED_THM ($SORRY_FILE)"
    note "enclosing declaration: $(printf '%s' "$ENCLOSING" | sed 's/[[:space:]]*$//')"
  fi
fi
echo

# ---------------------------------------------------------------------------
# C4/C5/C6/C7/C8: graph, markdown, reachability and structure checks
# ---------------------------------------------------------------------------
[ "$RUN_BUILD" -eq 0 ] && export SKIP_BUILD=1
export ENFORCE_C8
python3 - "$MANIFEST" "$ALLOWLIST" <<'PYEOF'
import os, re, sys, subprocess

manifest_path, allowlist_path = sys.argv[1], sys.argv[2]
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
    base = "Tests" if m.split(".")[0] == "BimodalTest" else "Theories"
    return os.path.join(base, *m.split(".")) + ".lean"

def path_to_mod(p):
    for base in ("Theories/", "Tests/"):
        if p.startswith(base):
            return p[len(base):-len(".lean")].replace(os.sep, ".")
    return None

lean_files = live_files("Theories", ".lean") + live_files("Tests", ".lean")
imp_re = re.compile(r"^import\s+(Bimodal(?:Test)?(?:\.[A-Za-z0-9_]+)*)\s*$", re.M)

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
    pas("C4", f"all {total_imports} Bimodal/BimodalTest import lines resolve")

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

mod_re = re.compile(r"\bBimodal(?:Test)?(?:\.[A-Z][A-Za-z0-9_]*)+")

def resolves(m):
    base = "Tests" if m.split(".")[0] == "BimodalTest" else "Theories"
    p = os.path.join(base, *m.split("."))
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
roots = ["Bimodal", "BimodalTest"]
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
          f"({len(live_files('Theories', '.lean'))} Theories / "
          f"{len(live_files('Tests', '.lean'))} Tests); "
          f"{len(seen)} reachable, {len(unreachable)} unreachable")
counts = {}
for p in live_files("Theories/Bimodal", ".lean"):
    top = os.path.relpath(p, "Theories/Bimodal").split(os.sep)[0]
    if top.endswith(".lean"):
        top = "(loose)"
    counts[top] = counts.get(top, 0) + 1
for k in sorted(counts):
    note(f"{k:<20} {counts[k]:>4}")

# --- C8: aggregator convention ----------------------------------------------
# Convention: a directory `X/` has exactly one sibling aggregator `X.lean`.
# Allowlisted exception: `Theories/Bimodal.lean` + `Theories/Bimodal/Bimodal.lean`.
# That pair is the Lake `lean_lib Bimodal` root (`srcDir := "Theories"`,
# `roots := #[`Bimodal]`), so the self-named indirection is load-bearing, not a
# convention violation.
C8_ALLOW_SELFNAMED = {"Theories/Bimodal/Bimodal.lean"}
c8_problems = []
for parent in ("Theories/Bimodal", "Theories/Bimodal/Metalogic"):
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
    pas("C8", "every Bimodal/ and Metalogic/ subdirectory has exactly one sibling aggregator")

sys.exit(1 if failures else 0)
PYEOF
PY_STATUS=$?
[ "$PY_STATUS" -ne 0 ] && FAILURES=$((FAILURES + 1))
echo

# ---------------------------------------------------------------------------
# C9: no task-number citations under Theories/
#
# `.claude/rules/no-task-references-in-deliverables.md` forbids ephemeral
# task-management identifiers in deliverable files. Task numbers are renumbered
# by vault operations and mean nothing to a future reader of a README.
# ---------------------------------------------------------------------------
TASK_REFS=$(grep -rniE --include='*.lean' --include='*.md' \
  '\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b' Theories 2>/dev/null | grep -v '/Boneyard/')
TASK_REF_COUNT=$(printf '%s' "$TASK_REFS" | grep -c . || true)
if [ "$TASK_REF_COUNT" -eq 0 ]; then
  pass C9 "zero task-number citations under Theories/"
else
  MSG="$TASK_REF_COUNT task-number citation(s) under Theories/ (use a durable anchor instead)"
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
STALE_PATHS=$(grep -rnE 'Theories/Bimodal/(docs|latex|typst)\b' . \
  --exclude-dir=.git --exclude-dir=.lake --exclude-dir=specs \
  --exclude-dir=build --exclude-dir=__pycache__ 2>/dev/null \
  | grep -v '/Boneyard/' \
  | grep -v '^\./scripts/check-module-invariants\.sh:')
STALE_COUNT=$(printf '%s' "$STALE_PATHS" | grep -c . || true)
if [ "$STALE_COUNT" -eq 0 ]; then
  pass C10 "zero references to Theories/Bimodal/{docs,latex,typst} outside specs/"
else
  MSG="$STALE_COUNT stale reference(s) to Theories/Bimodal/{docs,latex,typst}"
  if [ "$ENFORCE_C10" -eq 1 ]; then fail C10 "$MSG"; else soft C10 "$MSG (not yet enforced)"; fi
  printf '%s\n' "$STALE_PATHS" | head -20 | while IFS= read -r l; do note "$l"; done
  [ "$STALE_COUNT" -gt 20 ] && note "... and $((STALE_COUNT - 20)) more"
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
