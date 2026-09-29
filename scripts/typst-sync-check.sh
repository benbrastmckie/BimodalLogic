#!/usr/bin/env bash
# ============================================================================
# typst-sync-check.sh
#
# Mechanical drift detector for typst/. Three checks:
#   1. Name resolution   -- every backticked span in typst/**/*.typ resolves
#                           against live Lean source (excl. Boneyard/) or
#                           the whitelist.
#   2. Count freshness   -- regenerated status.typ (JSON) matches the
#                           committed typst/generated/status.typ exactly, AND
#                           (module-map sub-check) the committed
#                           typst/generated/automation-module-map.typ agrees
#                           with a live regeneration from
#                           scripts/typst-module-map.sh --json (build-free:
#                           no lake invocation either).
#   3. Machine appendix  -- committed generated/machine-appendix.jsonl agrees
#                           with a live recount of the Axiom/DerivationTree
#                           constructor blocks, and machine-appendix.typ is
#                           exactly the renderer's output for that JSONL
#                           (jq/python/awk only; no lake invocation).
#
# (The former banner-presence and legend-discipline checks were retired with
# the sync-class banner system; the compiled book carries no sync-class
# markings.)
#
# Exit code: 0 if all checks pass, 1 if any check fails (a per-violation
# report is printed to stderr). A usage error (unrecognized flag, extra
# argument) exits 2.
#
# Usage:
#   scripts/typst-sync-check.sh
#       Run all three checks above (unchanged full run). This is the form
#       CI calls; its behaviour is byte-identical to before --counts-only,
#       --fix and --help existed.
#
#   scripts/typst-sync-check.sh --counts-only
#       Run ONLY Check 2's generated/status.typ comparison (the scalar,
#       string, and sorry-table fields) -- not Check 1, Check 2b, or
#       Check 3. Build-free: no `lake` invocation. Intended for a
#       pre-commit gate that must stay fast and not require oleans.
#       Exits 0 if in sync, 1 on any drifted field.
#
#   scripts/typst-sync-check.sh --fix
#       On a Check 2 mismatch, regenerate typst/generated/status.typ by
#       invoking `scripts/typst-status-counts.sh` (its write path) and
#       report which fields the regeneration resolved. NEEDS A BUILT
#       LIBRARY: the write path reads a per-declaration axiom report out
#       of the build with `#print axioms`, unlike --counts-only above.
#       Also reports -- read-only, without attempting a fix -- any Check 2b
#       (module map) or Check 3 (machine appendix) drift, naming the
#       generator command for each, since --fix repairs status.typ only.
#       Never runs `git add`; the caller must stage the regenerated file
#       itself. Does nothing (and reports "nothing to fix") when Check 2
#       is already in sync, so a no-op run cannot create a stamp-only
#       diff. Exits 0 only when status.typ, the module map, and the
#       machine appendix all end up in sync.
#
#   scripts/typst-sync-check.sh --help
#       Print this usage and exit 0.
# ============================================================================

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Two independent roots since the asset relocation: BIMODAL_DIR is the LEAN
# SOURCE root, used for identifier and path resolution, and does NOT move.
# TYPST_DIR is the typst tree being scanned, which now sits at the project root.
#
BIMODAL_DIR="${REPO_ROOT}/FormalSystem"
# Check 1 resolves names against a LIST of Lean source roots, which BIMODAL_DIR alone stopped
# covering when the tooling half left the published library for `lean_lib BimodalTools`. The
# manual's dataset-pipeline and machine-appendix chapters cite identifiers that live in the
# tooling modules (`DatasetRecord`, `axiomsUsed`, `pattern_key`, the exe root names), and a
# single-root scan stopped resolving 22 of them the moment those modules moved. Colon-separated,
# and used by Check 1 ONLY: Checks 2-3 below still take BIMODAL_DIR as one directory path.
LEAN_SRC_ROOTS="${REPO_ROOT}/FormalSystem:${REPO_ROOT}/BimodalTools"
TYPST_DIR="${REPO_ROOT}/typst"
WHITELIST="${TYPST_DIR}/sync-check-whitelist.txt"
MAIN_FILE="${TYPST_DIR}/BimodalReference.typ"
STATUS_TYP="${TYPST_DIR}/generated/status.typ"
MODULE_MAP_TYP="${TYPST_DIR}/generated/automation-module-map.typ"
MA_JSONL="${TYPST_DIR}/generated/machine-appendix.jsonl"
MA_TYP="${TYPST_DIR}/generated/machine-appendix.typ"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
USAGE_LINE="Usage: scripts/typst-sync-check.sh [--counts-only|--fix|--help]"

MODE="full"
case "${1:-}" in
  "")
    MODE="full"
    ;;
  --counts-only)
    MODE="counts_only"
    ;;
  --fix)
    MODE="fix"
    ;;
  --help)
    MODE="help"
    ;;
  *)
    echo "typst-sync-check.sh: unrecognized argument: $1" >&2
    echo "${USAGE_LINE}" >&2
    exit 2
    ;;
esac

if [[ $# -gt 1 ]]; then
  echo "typst-sync-check.sh: unexpected extra argument(s): ${*:2}" >&2
  echo "${USAGE_LINE}" >&2
  exit 2
fi

if [[ "${MODE}" == "help" ]]; then
  cat << USAGE
${USAGE_LINE}

  (no arguments)   Run all three sync checks (name resolution, count
                   freshness incl. module-map, machine appendix). This is
                   the form CI calls. Exit 0 if all pass, 1 otherwise.

  --counts-only    Run ONLY Check 2's generated/status.typ comparison
                   (the scalar/string/sorry-table fields), build-free (no
                   lake invocation). Intended for a pre-commit gate. Exit
                   0 if in sync, 1 on any drifted field.

  --fix            Build-requiring. On a Check 2 mismatch, regenerate
                   typst/generated/status.typ via
                   scripts/typst-status-counts.sh (NEEDS A BUILT LIBRARY:
                   it reads a per-declaration axiom report out of the
                   build) and report which fields changed. Also reports
                   (read-only, not fixed) any Check 2b (module map) or
                   Check 3 (machine appendix) drift, naming the generator
                   command for each. Never runs \`git add\`. Reports
                   "nothing to fix" and leaves status.typ untouched when
                   Check 2 is already in sync. Exit 0 only when
                   status.typ, the module map, and the machine appendix
                   all end up in sync.

  --help           Print this message and exit 0.
USAGE
  exit 0
fi

FAIL=0

# ---------------------------------------------------------------------------
# Check 2 core comparison, wrapped in a function so --counts-only and --fix
# can invoke EXACTLY this comparison rather than a second copy of it -- the
# "generator and checker must stay compatible" constraint forbids a third
# methodology. Sets CHECK2_MISMATCH_REPORT (text to print) and returns 0 if
# generated/status.typ matches a live regeneration, 1 otherwise.
# ---------------------------------------------------------------------------
run_check2_status() {
  if [[ ! -f "${STATUS_TYP}" ]]; then
    CHECK2_MISMATCH_REPORT="VIOLATION: ${STATUS_TYP} does not exist -- run scripts/typst-status-counts.sh"
    return 1
  fi
  local live_json
  live_json=$(bash "${REPO_ROOT}/scripts/typst-status-counts.sh" --json)
  CHECK2_MISMATCH_REPORT=$(python3 - "${STATUS_TYP}" << PYEOF
import re, sys, json

live = json.loads('''${live_json}''')
with open(sys.argv[1], encoding="utf-8") as fh:
    text = fh.read()

scalar_fields = ["axiom-count", "rule-count", "base-count", "dense-only-count",
                  "ztime-only-count", "rtime-only-count",
                  "sorry-total", "sorry-total-excl-boneyard",
                  # Repository scale. A new #let in status.typ that is NOT
                  # listed here is never compared, which is how a cited figure
                  # rots silently while this check stays green. Every figure
                  # the generator emits belongs in one of the two lists.
                  "formalsystem-file-count", "formalsystem-line-count",
                  "tests-file-count", "tests-line-count",
                  "tools-file-count", "tools-line-count"]
# String-valued fields need their own comparison: the integer path below
# matches (\d+) only, so a string field added to scalar_fields would report
# MISSING on every run.
string_fields = ["lean-toolchain-pin", "mathlib-tag", "mathlib-rev"]
live_map = {
    "axiom-count": live["axiom_count"],
    "rule-count": live["rule_count"],
    "base-count": live["base_count"],
    "rtime-only-count": live["rtime_only_count"],
    "dense-only-count": live["dense_only_count"],
    "ztime-only-count": live["ztime_only_count"],
    "sorry-total": live["sorry_total"],
    "sorry-total-excl-boneyard": live["sorry_total_excl_boneyard"],
    "formalsystem-file-count": live["formalsystem_file_count"],
    "formalsystem-line-count": live["formalsystem_line_count"],
    "tests-file-count": live["tests_file_count"],
    "tests-line-count": live["tests_line_count"],
    "tools-file-count": live["tools_file_count"],
    "tools-line-count": live["tools_line_count"],
    "lean-toolchain-pin": live["lean_toolchain_pin"],
    "mathlib-tag": live["mathlib_tag"],
    "mathlib-rev": live["mathlib_rev"],
}
mismatches = []
for name in scalar_fields:
    m = re.search(r"#let " + re.escape(name) + r" = (\d+)", text)
    committed = m.group(1) if m else "MISSING"
    if str(live_map[name]) != committed:
        mismatches.append(f"{name}: committed={committed} live={live_map[name]}")

for name in string_fields:
    m = re.search(r"#let " + re.escape(name) + r' = "([^"]*)"', text)
    committed = m.group(1) if m else "MISSING"
    if str(live_map[name]) != committed:
        mismatches.append(f"{name}: committed={committed} live={live_map[name]}")

# sorry-table: parse the committed tuple array and compare subtree counts
m = re.search(r"#let sorry-table = \((.*?)\n\)", text, re.DOTALL)
committed_table = {}
if m:
    for row in re.finditer(r'\("([^"]+)",\s*(\d+)\)', m.group(1)):
        committed_table[row.group(1)] = int(row.group(2))
expected_table = {
    "Algebraic/": live["sorry_algebraic"],
    "BXCanonical/": live["sorry_bxcanonical"],
    "Bundle/": live["sorry_bundle"],
    # The WeakCanonical row is SPLIT: an archived count printed beside the live
    # sorry-total-excl-boneyard figure read as a contradiction. Both halves are
    # asserted here so the split cannot silently drop either.
    "WeakCanonical/ (live)": live["sorry_weakcanonical_excl_boneyard"],
    "WeakCanonical/ (archived, Boneyard/Kamp/)":
        live["sorry_weakcanonical"] - live["sorry_weakcanonical_excl_boneyard"],
    # Label must track typst-status-counts.sh's emitted row label exactly.
    # ConservativeExtension/ and Relational/ were archived/removed and dropped
    # from the generator's label and sum; this expectation was not updated at
    # the time, and the drift stayed masked only because the committed
    # status.typ was itself stale.
    "Core/, Decidability/, SoundnessLemmas/, top-level": live["sorry_other"],
}
for k, v in expected_table.items():
    committed_v = committed_table.get(k, "MISSING")
    if str(v) != str(committed_v):
        mismatches.append(f"sorry-table[{k}]: committed={committed_v} live={v}")

for msg in mismatches:
    print("VIOLATION: " + msg)
print(f"MISMATCH_COUNT={len(mismatches)}")
PYEOF
)
  local mismatch_count
  mismatch_count=$(echo "${CHECK2_MISMATCH_REPORT}" | grep -o '^MISMATCH_COUNT=[0-9]*$' | cut -d= -f2)
  [[ "${mismatch_count:-1}" == "0" ]]
}

# ---------------------------------------------------------------------------
# Check 2b core comparison (module map), wrapped for the same reuse reason as
# Check 2 above. Sets CHECK2B_REPORT; returns 0 if in sync, 1 otherwise.
# ---------------------------------------------------------------------------
run_check2_modulemap() {
  if [[ ! -f "${MODULE_MAP_TYP}" ]]; then
    CHECK2B_REPORT="VIOLATION: ${MODULE_MAP_TYP} does not exist -- run scripts/typst-module-map.sh"
    return 1
  fi
  local live_json
  live_json=$(bash "${REPO_ROOT}/scripts/typst-module-map.sh" --json)
  CHECK2B_REPORT=$(python3 - "${MODULE_MAP_TYP}" << PYEOF
import re, sys, json

live = json.loads('''${live_json}''')
live_rows = {r["path"]: (r["lines"], r["sorry_free"]) for r in live["rows"]}
live_total = live["total"]

with open(sys.argv[1], encoding="utf-8") as fh:
    text = fh.read()

m = re.search(r"#let automation-module-map = \((.*?)\n\)", text, re.DOTALL)
committed_rows = {}
if m:
    for row in re.finditer(r'\("([^"]+)",\s*(\d+),\s*(true|false)\)', m.group(1)):
        committed_rows[row.group(1)] = (int(row.group(2)), row.group(3) == "true")

tm = re.search(r"#let automation-module-total = (\d+)", text)
committed_total = int(tm.group(1)) if tm else None

mismatches = []
added = set(live_rows) - set(committed_rows)
removed = set(committed_rows) - set(live_rows)
for p in sorted(added):
    mismatches.append(f"row added (present live, missing in committed file): {p} {live_rows[p]}")
for p in sorted(removed):
    mismatches.append(f"row removed (present in committed file, absent live): {p} {committed_rows[p]}")
for p in sorted(set(live_rows) & set(committed_rows)):
    if live_rows[p] != committed_rows[p]:
        mismatches.append(f"row changed: {p} committed={committed_rows[p]} live={live_rows[p]}")
if committed_total != live_total:
    mismatches.append(f"automation-module-total: committed={committed_total} live={live_total}")

for msg in mismatches:
    print("VIOLATION: " + msg + " -- regenerate via: bash scripts/typst-module-map.sh")
print(f"MODULE_MAP_MISMATCHES={len(mismatches)}")
PYEOF
)
  local mismatch_count
  mismatch_count=$(echo "${CHECK2B_REPORT}" | grep -o '^MODULE_MAP_MISMATCHES=[0-9]*$' | cut -d= -f2)
  [[ "${mismatch_count:-1}" == "0" ]]
}

# ---------------------------------------------------------------------------
# Check 3 sub-checks (machine appendix), wrapped for reuse by --fix's
# read-only reporting. Sub-check A: count agreement. Sub-check B: rendering
# agreement. Each sets its own report var and returns 0/1.
# ---------------------------------------------------------------------------
run_check3_counts() {
  local live_axiom_count live_rule_count
  live_axiom_count=$(awk '/^inductive Axiom/,/deriving Repr/' "${BIMODAL_DIR}/ProofSystem/Axioms.lean" | grep -c '^  | ')
  live_rule_count=$(awk '
    /^inductive DerivationTree/ { infile=1 }
    infile && /^  \| / { count++ }
    infile && /^[A-Za-z]/ && !/^inductive DerivationTree/ && NR>1 && seen { exit }
    infile { seen=1 }
    END { print count }
  ' "${BIMODAL_DIR}/ProofSystem/Derivation.lean")

  CHECK3_COUNT_REPORT=$(python3 - "${MA_JSONL}" "${live_axiom_count}" "${live_rule_count}" << 'PYEOF'
import json, sys

path, live_axioms, live_rules = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
counts = {"axiom": 0, "inference_rule": 0, "derived_operator": 0}
meta = None
mismatches = []
with open(path, encoding="utf-8") as fh:
    for i, line in enumerate(fh):
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            mismatches.append(f"line {i+1} of machine-appendix.jsonl is not valid JSON")
            continue
        kind = obj.get("kind")
        if kind == "metadata":
            meta = obj
        elif kind in counts:
            counts[kind] += 1

if meta is None:
    mismatches.append("no metadata line in machine-appendix.jsonl")
else:
    for key, actual in (("axiom_count", counts["axiom"]),
                        ("rule_count", counts["inference_rule"]),
                        ("derived_operator_count", counts["derived_operator"])):
        if meta.get(key) != actual:
            mismatches.append(f"metadata {key}={meta.get(key)} but {actual} such lines present")

if counts["axiom"] != live_axioms:
    mismatches.append(f"committed axiom lines={counts['axiom']} but live Axioms.lean constructor count={live_axioms}")
if counts["inference_rule"] != live_rules:
    mismatches.append(f"committed inference_rule lines={counts['inference_rule']} but live Derivation.lean rule count={live_rules}")

for m in mismatches:
    print("VIOLATION: " + m + " -- regenerate via: bash scripts/typst-machine-appendix.sh")
print(f"MA_COUNT_MISMATCHES={len(mismatches)}")
PYEOF
)
  local mismatch_count
  mismatch_count=$(echo "${CHECK3_COUNT_REPORT}" | grep -o '^MA_COUNT_MISMATCHES=[0-9]*$' | cut -d= -f2)
  [[ "${mismatch_count:-1}" == "0" ]]
}

run_check3_render() {
  CHECK3_RENDER_DIFF=$(bash "${REPO_ROOT}/scripts/typst-machine-appendix.sh" --render-only "${MA_JSONL}" | diff - "${MA_TYP}" 2>&1)
  [[ -z "${CHECK3_RENDER_DIFF}" ]]
}

# ===========================================================================
# --counts-only mode: Check 2's status.typ comparison alone, build-free.
# ===========================================================================
if [[ "${MODE}" == "counts_only" ]]; then
  echo "== Check 2 (--counts-only): generated/status.typ vs live regeneration ==" >&2
  if run_check2_status; then
    echo "${CHECK2_MISMATCH_REPORT}" >&2
    echo "All fields in generated/status.typ match a live regeneration." >&2
    exit 0
  else
    echo "${CHECK2_MISMATCH_REPORT}" >&2
    echo "typst-sync-check.sh --counts-only: FAIL" >&2
    exit 1
  fi
fi

# ===========================================================================
# --fix mode: regenerate status.typ on a Check 2 mismatch (needs a built
# library); report Check 2b/Check 3 drift read-only, without fixing it.
# ===========================================================================
if [[ "${MODE}" == "fix" ]]; then
  FIX_FAIL=0

  echo "== Check 2: generated/status.typ vs live regeneration ==" >&2
  if run_check2_status; then
    echo "Nothing to fix: generated/status.typ already matches a live regeneration." >&2
  else
    echo "Drift found:" >&2
    echo "${CHECK2_MISMATCH_REPORT}" >&2
    echo "Regenerating typst/generated/status.typ via scripts/typst-status-counts.sh" \
         "(needs a built library -- this may take a while if the library is not warm)..." >&2
    if ! bash "${REPO_ROOT}/scripts/typst-status-counts.sh"; then
      echo "VIOLATION: scripts/typst-status-counts.sh failed -- see its output above" \
           "(a common cause is a library that has not been built: run 'lake build' first)." >&2
      FIX_FAIL=1
    else
      if run_check2_status; then
        echo "Fixed: generated/status.typ now matches a live regeneration." >&2
      else
        echo "Still drifted after regeneration (unexpected -- the generator and this" \
             "checker may have diverged):" >&2
        echo "${CHECK2_MISMATCH_REPORT}" >&2
        FIX_FAIL=1
      fi
    fi
    echo "Note: --fix does NOT run 'git add'. Stage typst/generated/status.typ yourself" \
         "once you are satisfied with the change." >&2
  fi

  echo "== Check 2b (read-only -- --fix repairs status.typ only): automation-module-map.typ ==" >&2
  if run_check2_modulemap; then
    echo "generated/automation-module-map.typ matches a live regeneration." >&2
  else
    echo "${CHECK2B_REPORT}" >&2
    echo "--fix does not repair this -- regenerate via: bash scripts/typst-module-map.sh" >&2
    FIX_FAIL=1
  fi

  echo "== Check 3 (read-only -- --fix repairs status.typ only): machine-appendix.* ==" >&2
  if [[ ! -f "${MA_JSONL}" || ! -f "${MA_TYP}" ]]; then
    echo "VIOLATION: missing machine appendix artifact(s) (${MA_JSONL}, ${MA_TYP})" \
         "-- regenerate via: bash scripts/typst-machine-appendix.sh" >&2
    FIX_FAIL=1
  else
    if run_check3_counts; then
      echo "${CHECK3_COUNT_REPORT}" >&2
    else
      echo "${CHECK3_COUNT_REPORT}" >&2
      echo "--fix does not repair this -- regenerate via: bash scripts/typst-machine-appendix.sh" >&2
      FIX_FAIL=1
    fi
    if run_check3_render; then
      echo "machine-appendix.typ matches a re-render from the committed JSONL." >&2
    else
      echo "VIOLATION: generated/machine-appendix.typ does not match a re-render from the" \
           "committed JSONL (hand edit or renderer drift)" \
           "-- regenerate via: bash scripts/typst-machine-appendix.sh" >&2
      echo "${CHECK3_RENDER_DIFF}" | head -20 >&2
      echo "--fix does not repair this -- regenerate via: bash scripts/typst-machine-appendix.sh" >&2
      FIX_FAIL=1
    fi
  fi

  if [[ "${FIX_FAIL}" == "1" ]]; then
    echo "typst-sync-check.sh --fix: FAIL (status.typ regeneration attempted; Check 2b/3 never are)" >&2
    exit 1
  else
    echo "typst-sync-check.sh --fix: PASS (status.typ, module map, and machine appendix all in sync)" >&2
    exit 0
  fi
fi

# ===========================================================================
# Full mode (no arguments): unchanged three-check run. This is the form CI
# calls, and its behaviour below is byte-identical to before --counts-only,
# --fix and --help existed.
# ===========================================================================

# ---------------------------------------------------------------------------
# Check 1: Name resolution
# ---------------------------------------------------------------------------
echo "== Check 1: backtick name resolution ==" >&2

CHECK1_REPORT=$(python3 - "${REPO_ROOT}" "${LEAN_SRC_ROOTS}" "${TYPST_DIR}" "${WHITELIST}" << 'PYEOF'
import re, glob, os, subprocess, sys

repo_root, bimodal_dirs_raw, typst_dir, whitelist_path = sys.argv[1:5]
# Every Lean source root, in declaration order. `bimodal_dir` is kept as the FIRST root so the
# messages below still name the primary one; resolution tries all of them.
bimodal_dirs = [d for d in bimodal_dirs_raw.split(":") if d and os.path.isdir(d)]
bimodal_dir = bimodal_dirs[0] if bimodal_dirs else bimodal_dirs_raw

# Load whitelist
whitelist = set()
if os.path.exists(whitelist_path):
    with open(whitelist_path, encoding="utf-8") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line or line.startswith("#"):
                continue
            whitelist.add(line)

# Extract candidates
candidates = {}
for f in glob.glob(os.path.join(typst_dir, "**", "*.typ"), recursive=True):
    if os.sep + "generated" + os.sep in f:
        continue
    with open(f, encoding="utf-8") as fh:
        text = fh.read()
    for m in re.finditer(r"`([^`\n]+)`", text):
        cand = m.group(1)
        candidates.setdefault(cand, []).append(os.path.relpath(f, repo_root))

def grep_lean(name):
    try:
        out = subprocess.run(
            ["grep", "-rl", "--include=*.lean", "-F", name] + bimodal_dirs
            + ["--exclude-dir=Boneyard"],
            capture_output=True, text=True, timeout=30,
        )
        return out.returncode == 0 and bool(out.stdout.strip())
    except Exception:
        return False

def strip_line_suffix(path):
    # Strip a trailing ":123" or ":123-145" line/range reference.
    return re.sub(r":\d+(-\d+)?$", "", path)

def path_exists_excl_boneyard(rel_path, base):
    full = os.path.join(base, rel_path)
    if os.path.exists(full):
        return True
    return False

def suffix_search(name, base, allow_boneyard):
    # Search the whole tree under `base` for any directory/file whose
    # path (relative to base) ends with the given suffix -- handles
    # chapter prose that drops a shared prefix (e.g. "Kamp/KampWeakCanonical/"
    # instead of "Boneyard/Kamp/KampWeakCanonical/").
    # When allow_boneyard is False, Boneyard/ subtrees are excluded from
    # the walk (mirrors --exclude-dir=Boneyard elsewhere); when True
    # (the candidate itself names a Boneyard path -- a deliberate
    # historical reference), Boneyard/ is walked normally.
    suffix = name.rstrip("/")
    suffix_parts = suffix.split("/")
    for root, dirs, files in os.walk(base):
        if not allow_boneyard and "Boneyard" in dirs:
            dirs.remove("Boneyard")
        rel_root = os.path.relpath(root, base)
        candidates_here = list(files) + list(dirs)
        for c in candidates_here:
            full_rel = os.path.join(rel_root, c) if rel_root != "." else c
            full_rel_parts = full_rel.split(os.sep)
            if full_rel_parts[-len(suffix_parts):] == suffix_parts:
                return True
    return False

violations = []
for cand, files in sorted(candidates.items()):
    if cand in whitelist:
        continue
    if " " in cand:
        # Multi-word span: try literal grep once (handles genuine verbatim
        # quotes); otherwise it needs a whitelist entry (type-signature /
        # prose illustration).
        if grep_lean(cand):
            continue
        violations.append((cand, files, "multi-word span not found verbatim in Lean source (add to whitelist if intentional exposition, not a claim)"))
        continue
    cand_delined = strip_line_suffix(cand)
    is_pathlike = "/" in cand_delined or cand_delined.endswith((".lean", ".md", ".sh", ".typ", ".toml"))
    if is_pathlike:
        rel = cand_delined
        allow_boneyard = "Boneyard" in rel.split("/")
        resolved = False
        for base in bimodal_dirs:
            prefix = os.path.basename(base) + "/"
            rel_bimodal = rel[len(prefix):] if rel.startswith(prefix) else rel
            if path_exists_excl_boneyard(rel_bimodal, base):
                resolved = True
                break
        if resolved:
            continue
        if path_exists_excl_boneyard(rel, repo_root):
            continue
        if any(suffix_search(rel, base, allow_boneyard) for base in bimodal_dirs):
            continue
        if suffix_search(rel, repo_root, allow_boneyard):
            continue
        roots_desc = "/, ".join(os.path.basename(b) for b in bimodal_dirs) + "/"
        violations.append((cand, files, f"path does not exist under any Lean source root ({roots_desc}; excl. Boneyard/ unless the candidate itself names it) nor under the repo root"))
        continue
    # Bare identifier / dotted qualified name
    if grep_lean(cand):
        continue
    roots_desc = "/, ".join(os.path.basename(b) for b in bimodal_dirs) + "/"
    violations.append((cand, files, f"identifier not found in any *.lean file under the Lean source roots ({roots_desc}; excl. Boneyard/)"))

if violations:
    for cand, files, reason in violations:
        print(f"VIOLATION: `{cand}` -- {reason} (in: {', '.join(sorted(set(files)))})")
    print(f"TOTAL_VIOLATIONS={len(violations)}")
else:
    print("TOTAL_VIOLATIONS=0")
    print(f"TOTAL_CANDIDATES={len(candidates)}")
PYEOF
)

echo "${CHECK1_REPORT}" >&2
if ! echo "${CHECK1_REPORT}" | grep -q "^TOTAL_VIOLATIONS=0$"; then
  FAIL=1
fi

# ---------------------------------------------------------------------------
# Check 2: Count freshness
# ---------------------------------------------------------------------------
echo "== Check 2: count freshness (generated/status.typ vs live regeneration) ==" >&2

if run_check2_status; then
  echo "${CHECK2_MISMATCH_REPORT}" >&2
  echo "All fields in generated/status.typ match a live regeneration." >&2
else
  echo "${CHECK2_MISMATCH_REPORT}" >&2
  FAIL=1
fi

# --- Check 2 (module-map sub-check): automation-module-map.typ vs a live
# regeneration from scripts/typst-module-map.sh --json (build-free) ---
echo "== Check 2b: module map freshness (generated/automation-module-map.typ vs live regeneration) ==" >&2

if run_check2_modulemap; then
  echo "${CHECK2B_REPORT}" >&2
  echo "generated/automation-module-map.typ matches a live regeneration." >&2
else
  echo "${CHECK2B_REPORT}" >&2
  FAIL=1
fi

# ---------------------------------------------------------------------------
# Check 3: machine appendix freshness
#
# Two sub-checks over the committed machine appendix artifacts:
#   A. Count agreement -- the committed JSONL's axiom/rule line counts match
#      a live recount of the `inductive Axiom` / `inductive DerivationTree`
#      constructor blocks (same awk scans as typst-status-counts.sh), and
#      the metadata line's counts match the actual line counts.
#   B. Rendering agreement -- re-rendering machine-appendix.typ from the
#      committed JSONL (with the committed stamps, which live inside the
#      JSONL metadata line) reproduces the committed .typ byte-for-byte,
#      proving the rendering is derived, never hand-edited.
#
# Runtime budget: jq/python/awk only -- no lake invocation.
# ---------------------------------------------------------------------------
echo "== Check 3: machine appendix freshness (generated/machine-appendix.*) ==" >&2

if [[ ! -f "${MA_JSONL}" || ! -f "${MA_TYP}" ]]; then
  echo "VIOLATION: missing machine appendix artifact(s) (${MA_JSONL}, ${MA_TYP}) -- regenerate via: bash scripts/typst-machine-appendix.sh" >&2
  FAIL=1
else
  # --- Sub-check A: count agreement (live source scans vs committed JSONL) ---
  if run_check3_counts; then
    echo "${CHECK3_COUNT_REPORT}" >&2
  else
    echo "${CHECK3_COUNT_REPORT}" >&2
    FAIL=1
  fi

  # --- Sub-check B: rendering agreement (re-render committed JSONL, diff) ---
  if run_check3_render; then
    echo "machine-appendix.typ matches a re-render from the committed JSONL." >&2
  else
    echo "VIOLATION: generated/machine-appendix.typ does not match a re-render from the committed JSONL (hand edit or renderer drift) -- regenerate via: bash scripts/typst-machine-appendix.sh" >&2
    echo "${CHECK3_RENDER_DIFF}" | head -20 >&2
    FAIL=1
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
if [[ "${FAIL}" == "1" ]]; then
  echo "typst-sync-check.sh: FAIL" >&2
  exit 1
else
  echo "typst-sync-check.sh: PASS (all 3 checks green)" >&2
  exit 0
fi
