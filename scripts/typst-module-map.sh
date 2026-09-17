#!/usr/bin/env bash
# ============================================================================
# typst-module-map.sh
#
# Build-free generator for the Automation "Module Map" table cited in
# typst/chapters/p4-proof-automation.typ. Unlike typst-status-counts.sh's
# write path, this generator needs NO built library (no `lake env lean`
# call anywhere) -- it is pure `wc -l` plus a comment-stripped `\bsorry\b`
# scan, so both its write mode and its --json mode are safe to run in CI
# and are consumed identically by scripts/typst-sync-check.sh Check 2.
#
# Rows are discovered by GLOB, not a fixed list, over exactly:
#   FormalSystem/Automation/Tactics/*.lean
#   FormalSystem/Automation/ProofSearch/*.lean
#   FormalSystem/Automation/SuccessPatterns.lean
# (never FormalSystem/Automation/Boneyard/ or FormalSystem/Boneyard/ -- there
# is no Boneyard/ under either glob root today, but the exclusion is
# asserted defensively below in case one is ever created). A renamed, added,
# or removed module under these globs therefore changes the live
# regeneration automatically, so Check 2 fails loudly instead of drifting.
#
# Columns emitted per row: (path, lines, sorry_free). `path` is relative to
# FormalSystem/Automation/. `sorry_free` uses the SAME comment-stripped
# `\bsorry\b` methodology as typst-status-counts.sh's strip_and_count_sorries
# (block `/- -/` and line `--` comments removed before counting) -- this is
# reused, not reinvented, per the plan's explicit instruction. The chapter's
# hand-written `Role` column is NOT emitted here; it stays hand-authored in
# the .typ source, keyed by the same path strings this script prints.
#
# Usage:
#   scripts/typst-module-map.sh            # writes
#                                           # typst/generated/automation-module-map.typ
#   scripts/typst-module-map.sh --json     # emits JSON to stdout only
#                                           # (consumed by typst-sync-check.sh
#                                           # Check 2's module-map sub-check)
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUTOMATION_DIR="${REPO_ROOT}/FormalSystem/Automation"
OUT_TYP="${REPO_ROOT}/typst/generated/automation-module-map.typ"

JSON_ONLY=0
if [[ "${1:-}" == "--json" ]]; then
  JSON_ONLY=1
fi

# ---------------------------------------------------------------------------
# Sorry detection: comment-stripped \bsorry\b count == 0.
# Same stripping methodology as typst-status-counts.sh's
# strip_and_count_sorries (block /- -/ and line -- comments removed first).
# ---------------------------------------------------------------------------
count_sorries() {
  local f="$1"
  python3 - "$f" << 'PYEOF'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    text = fh.read()
text = re.sub(r"/-.*?-/", "", text, flags=re.DOTALL)
text = re.sub(r"--.*", "", text)
print(len(re.findall(r"\bsorry\b", text)))
PYEOF
}

# ---------------------------------------------------------------------------
# Discover rows by glob (never Boneyard/), sorted deterministically by path.
# ---------------------------------------------------------------------------
declare -a ROW_PATHS=()

collect() {
  local glob_pattern="$1"
  local f
  for f in ${glob_pattern}; do
    [[ -f "${f}" ]] || continue
    case "${f}" in
      */Boneyard/*) continue ;;
    esac
    ROW_PATHS+=("${f}")
  done
}

collect "${AUTOMATION_DIR}/Tactics/*.lean"
collect "${AUTOMATION_DIR}/ProofSearch/*.lean"
collect "${AUTOMATION_DIR}/SuccessPatterns.lean"

# Sort by path (relative), deterministic.
mapfile -t SORTED_REL < <(
  for f in "${ROW_PATHS[@]}"; do
    echo "${f#${AUTOMATION_DIR}/}"
  done | sort
)

# ---------------------------------------------------------------------------
# Emit rows: (relative_path, lines, sorry_free)
# ---------------------------------------------------------------------------
JSON_ROWS=()
TYP_ROWS=()
TOTAL=0

for rel in "${SORTED_REL[@]}"; do
  full="${AUTOMATION_DIR}/${rel}"
  lines=$(wc -l < "${full}" | tr -d ' ')
  sorry_count=$(count_sorries "${full}")
  if [[ "${sorry_count}" == "0" ]]; then
    sorry_free="true"
  else
    sorry_free="false"
  fi
  TOTAL=$((TOTAL + lines))
  JSON_ROWS+=("{\"path\": \"${rel}\", \"lines\": ${lines}, \"sorry_free\": ${sorry_free}}")
  TYP_ROWS+=("  (\"${rel}\", ${lines}, ${sorry_free}),")
done

# ---------------------------------------------------------------------------
# --json mode
# ---------------------------------------------------------------------------
if [[ "${JSON_ONLY}" == "1" ]]; then
  {
    echo "{"
    echo "  \"rows\": ["
    row_count="${#JSON_ROWS[@]}"
    for i in "${!JSON_ROWS[@]}"; do
      if [[ "${i}" -lt $((row_count - 1)) ]]; then
        echo "    ${JSON_ROWS[$i]},"
      else
        echo "    ${JSON_ROWS[$i]}"
      fi
    done
    echo "  ],"
    echo "  \"total\": ${TOTAL}"
    echo "}"
  }
  exit 0
fi

# ---------------------------------------------------------------------------
# Write mode: typst/generated/automation-module-map.typ
#
# No commit/date stamp -- deliberately, to keep the Check 2 diff exact and
# avoid stamp churn (see plan Phase 1 rationale: this mirrors the
# `sorry-table` precedent in status.typ but omits the stamp fields that
# status.typ carries, since those apply only to the scalar counts stamped
# at a specific commit, not to a live-tree glob).
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "${OUT_TYP}")"
{
  echo "// ============================================================================"
  echo "// generated/automation-module-map.typ"
  echo "//"
  echo "// GENERATED FILE -- never edit by hand. Regenerate via:"
  echo "//   scripts/typst-module-map.sh"
  echo "//"
  echo "// Rows discovered by glob over FormalSystem/Automation/{Tactics,ProofSearch}/*.lean"
  echo "// and FormalSystem/Automation/SuccessPatterns.lean (never Boneyard/). Columns:"
  echo "// (path, lines, sorry_free). The chapter's Role column stays hand-written,"
  echo "// keyed by the same path strings."
  echo "// ============================================================================"
  echo ""
  echo "#let automation-module-map = ("
  for row in "${TYP_ROWS[@]}"; do
    echo "${row}"
  done
  echo ")"
  echo ""
  echo "#let automation-module-total = ${TOTAL}"
} > "${OUT_TYP}"

echo "Wrote ${OUT_TYP}" >&2
