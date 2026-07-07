#!/usr/bin/env bash
# ============================================================================
# typst-sync-check.sh
#
# Mechanical drift detector for Theories/Bimodal/typst/ (task 313, Phase 4;
# task-312 suggested follow-up). Four checks:
#   1. Name resolution   -- every backticked span in typst/**/*.typ resolves
#                           against live Lean source (excl. Boneyard/) or
#                           the whitelist.
#   2. Banner presence   -- every chapter file included by
#                           BimodalReference.typ carries #sync-banner(.
#   3. Legend discipline -- no file whose dominant banner is paper/outlook
#                           also carries a "check"-class banner call.
#   4. Count freshness   -- regenerated status.typ (JSON) matches the
#                           committed typst/generated/status.typ exactly.
#
# Exit code: 0 if all checks pass, 1 if any check fails (a per-violation
# report is printed to stderr).
#
# Usage: scripts/typst-sync-check.sh
# ============================================================================

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIMODAL_DIR="${REPO_ROOT}/Theories/Bimodal"
TYPST_DIR="${BIMODAL_DIR}/typst"
WHITELIST="${TYPST_DIR}/sync-check-whitelist.txt"
MAIN_FILE="${TYPST_DIR}/BimodalReference.typ"
STATUS_TYP="${TYPST_DIR}/generated/status.typ"

FAIL=0

# ---------------------------------------------------------------------------
# Check 1: Name resolution
# ---------------------------------------------------------------------------
echo "== Check 1: backtick name resolution ==" >&2

CHECK1_REPORT=$(python3 - "${REPO_ROOT}" "${BIMODAL_DIR}" "${TYPST_DIR}" "${WHITELIST}" << 'PYEOF'
import re, glob, os, subprocess, sys

repo_root, bimodal_dir, typst_dir, whitelist_path = sys.argv[1:5]

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
            ["grep", "-rl", "--include=*.lean", "-F", name, bimodal_dir,
             "--exclude-dir=Boneyard"],
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
    # chapter prose that drops a shared prefix (e.g. "WeakCanonical/Kamp/
    # Boneyard/" instead of "Metalogic/WeakCanonical/Kamp/Boneyard/").
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
    is_pathlike = "/" in cand_delined or cand_delined.endswith((".lean", ".md", ".sh", ".typ"))
    if is_pathlike:
        rel = cand_delined
        allow_boneyard = "Boneyard" in rel.split("/")
        if rel.startswith("Theories/Bimodal/"):
            rel_bimodal = rel[len("Theories/Bimodal/"):]
        else:
            rel_bimodal = rel
        if path_exists_excl_boneyard(rel_bimodal, bimodal_dir):
            continue
        if path_exists_excl_boneyard(rel, repo_root):
            continue
        if suffix_search(rel, bimodal_dir, allow_boneyard):
            continue
        if suffix_search(rel, repo_root, allow_boneyard):
            continue
        violations.append((cand, files, "path does not exist under Theories/Bimodal/ (excl. Boneyard/ unless the candidate itself names it) or repo root"))
        continue
    # Bare identifier / dotted qualified name
    if grep_lean(cand):
        continue
    violations.append((cand, files, "identifier not found in any *.lean file under Theories/Bimodal/ (excl. Boneyard/)"))

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
# Check 2: Banner presence
# ---------------------------------------------------------------------------
echo "== Check 2: sync-banner presence ==" >&2

CHAPTER_FILES=$(grep -oE '#include "chapters/[^"]+\.typ"' "${MAIN_FILE}" | sed -E 's/#include "chapters\/([^"]+)"/\1/')

CHECK2_FAIL=0
for ch in ${CHAPTER_FILES}; do
  f="${TYPST_DIR}/chapters/${ch}"
  if [[ ! -f "${f}" ]]; then
    echo "VIOLATION: included chapter file missing: chapters/${ch}" >&2
    CHECK2_FAIL=1
    continue
  fi
  if ! grep -q '#sync-banner(' "${f}"; then
    echo "VIOLATION: chapters/${ch} has no #sync-banner( call" >&2
    CHECK2_FAIL=1
  fi
done
if [[ "${CHECK2_FAIL}" == "1" ]]; then
  FAIL=1
else
  echo "All included chapters carry a #sync-banner( call." >&2
fi

# ---------------------------------------------------------------------------
# Check 3: Legend discipline
# ---------------------------------------------------------------------------
echo "== Check 3: legend discipline (no check-class banner in paper/outlook files) ==" >&2

CHECK3_FAIL=0
for ch in ${CHAPTER_FILES}; do
  f="${TYPST_DIR}/chapters/${ch}"
  [[ -f "${f}" ]] || continue
  has_dominant_paper_or_outlook=$(grep -c '#sync-banner("paper"\|#sync-banner("outlook"' "${f}")
  has_check=$(grep -c '#sync-banner("check"' "${f}")
  if [[ "${has_dominant_paper_or_outlook}" -gt 0 && "${has_check}" -gt 0 ]]; then
    echo "VIOLATION: chapters/${ch} declares both a paper/outlook banner and a check-class banner (legend discipline violation)" >&2
    CHECK3_FAIL=1
  fi
done
if [[ "${CHECK3_FAIL}" == "1" ]]; then
  FAIL=1
else
  echo "No paper/outlook chapter carries a conflicting check-class banner." >&2
fi

# ---------------------------------------------------------------------------
# Check 4: Count freshness
# ---------------------------------------------------------------------------
echo "== Check 4: count freshness (generated/status.typ vs live regeneration) ==" >&2

if [[ ! -f "${STATUS_TYP}" ]]; then
  echo "VIOLATION: ${STATUS_TYP} does not exist -- run scripts/typst-status-counts.sh" >&2
  FAIL=1
else
  LIVE_JSON=$(bash "${REPO_ROOT}/scripts/typst-status-counts.sh" --json)
  # Compare the top-level #let bindings (scalar counts) plus the
  # sorry-table tuple array against a live regeneration. The commit/date
  # stamp fields are deliberately excluded: they are expected to advance
  # between the last-committed regeneration and a sync-check run against a
  # tree that has since gained commits (Phase 12 re-stamps at the final
  # commit). A genuine drift is any other mismatch.
  MISMATCH_REPORT=$(python3 - "${STATUS_TYP}" << PYEOF
import re, sys, json

live = json.loads('''${LIVE_JSON}''')
with open(sys.argv[1], encoding="utf-8") as fh:
    text = fh.read()

scalar_fields = ["axiom-count", "rule-count", "base-count", "dense-only-count",
                  "discrete-only-count", "sorry-total", "sorry-total-excl-boneyard"]
live_map = {
    "axiom-count": live["axiom_count"],
    "rule-count": live["rule_count"],
    "base-count": live["base_count"],
    "dense-only-count": live["dense_only_count"],
    "discrete-only-count": live["discrete_only_count"],
    "sorry-total": live["sorry_total"],
    "sorry-total-excl-boneyard": live["sorry_total_excl_boneyard"],
}
mismatches = []
for name in scalar_fields:
    m = re.search(r"#let " + re.escape(name) + r" = (\d+)", text)
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
    "WeakCanonical/": live["sorry_weakcanonical"],
    "Core/, ConservativeExtension/, Decidability/, Relational/, SoundnessLemmas/, top-level": live["sorry_other"],
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
  echo "${MISMATCH_REPORT}" >&2
  if ! echo "${MISMATCH_REPORT}" | grep -q "^MISMATCH_COUNT=0$"; then
    FAIL=1
  else
    echo "All fields in generated/status.typ match a live regeneration." >&2
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
if [[ "${FAIL}" == "1" ]]; then
  echo "typst-sync-check.sh: FAIL" >&2
  exit 1
else
  echo "typst-sync-check.sh: PASS (all 4 checks green)" >&2
  exit 0
fi
