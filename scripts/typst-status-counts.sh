#!/usr/bin/env bash
# ============================================================================
# typst-status-counts.sh
#
# Single-source-of-truth generator for the volatile counts cited in
# typst/ (sorry totals, axiom-constructor count, rule
# count). Reproduces the SYNC-MAP.md "Ground-Truth Counts" (Phase 1)
# methodology so that no hand-copied number ever needs to survive in
# chapter prose.
#
# Usage:
#   scripts/typst-status-counts.sh            # writes typst/generated/status.typ
#                                              # NEEDS A BUILT LIBRARY: the
#                                              # per-declaration axiom report is
#                                              # read out of it with #print axioms
#   scripts/typst-status-counts.sh --json     # emits JSON to stdout only, no lake
#                                              # (consumed by typst-sync-check.sh)
#
# Methodology (must match SYNC-MAP.md exactly):
#   - Axiom constructors: count `  | ` lines inside the `inductive Axiom`
#     block of ProofSystem/Axioms.lean.
#   - Inference rules: count `  | ` lines inside the `inductive
#     DerivationTree` block of ProofSystem/Derivation.lean.
#   - Sorry counts: comment-stripped (block `/- -/` and line `--` comments
#     removed) `\bsorry\b` occurrences under Metalogic/**/*.lean, reported
#     per top-level subtree, with the nested WeakCanonical/Kamp/Boneyard/
#     archive counted separately from the rest of WeakCanonical/.
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# BIMODAL_DIR is the LEAN SOURCE root, which does not move. The typst tree it
# writes into now lives at the project root, so the two are no longer nested.
BIMODAL_DIR="${REPO_ROOT}/FormalSystem"
OUT_TYP="${REPO_ROOT}/typst/generated/status.typ"

JSON_ONLY=0
if [[ "${1:-}" == "--json" ]]; then
  JSON_ONLY=1
fi

cd "${BIMODAL_DIR}"

# ---------------------------------------------------------------------------
# Axiom constructor count
# ---------------------------------------------------------------------------
AXIOM_COUNT=$(awk '/^inductive Axiom/,/deriving Repr/' ProofSystem/Axioms.lean | grep -c '^  | ')

# Frame-class assignment breakdown (Axiom.minFrameClass, Axioms.lean):
# Dense-only, Discrete-only and Dedekind-only counts come from explicit match
# arms; Base is everything else (the `_ => .Base` catch-all). Every non-Base
# tier MUST be subtracted here -- omitting one silently inflates base_count.
DENSE_ONLY_COUNT=$(awk '/^def Axiom.minFrameClass/,/^theorem FrameClass.base_le/' ProofSystem/Axioms.lean | grep -c '=> \.Dense')
ZTIME_ONLY_COUNT=$(awk '/^def Axiom.minFrameClass/,/^theorem FrameClass.base_le/' ProofSystem/Axioms.lean | grep -c '=> \.ZTime')
RTIME_ONLY_COUNT=$(awk '/^def Axiom.minFrameClass/,/^theorem FrameClass.base_le/' ProofSystem/Axioms.lean | grep -c '=> \.RTime')
BASE_COUNT=$((AXIOM_COUNT - DENSE_ONLY_COUNT - ZTIME_ONLY_COUNT - RTIME_ONLY_COUNT))

# ---------------------------------------------------------------------------
# DerivationTree rule count
# ---------------------------------------------------------------------------
# The inductive block runs from `inductive DerivationTree` to the next
# top-level (non-indented) declaration; grep the doc-commented rule count
# via the number of `-- Rule N:`-free `  | ` constructor lines within the
# block bounded by the next `inductive`/`def`/`theorem` at column 0, or EOF.
RULE_COUNT=$(awk '
  /^inductive DerivationTree/ { infile=1 }
  infile && /^  \| / { count++ }
  infile && /^[A-Za-z]/ && !/^inductive DerivationTree/ && NR>1 && seen { exit }
  infile { seen=1 }
  END { print count }
' ProofSystem/Derivation.lean)

# ---------------------------------------------------------------------------
# Sorry counts (comment-stripped, per Metalogic/ subtree)
# ---------------------------------------------------------------------------
strip_and_count_sorries() {
  # $1 = directory or file glob (find-compatible path)
  # A missing path counts as 0 rather than aborting: subtrees legitimately
  # disappear when they are archived or removed, and a counting script must
  # report that as "no sorries here", not die under `set -e`.
  local path="$1"
  if [[ ! -e "${path}" ]]; then
    echo 0
    return 0
  fi
  find "${path}" -name '*.lean' -type f 2>/dev/null | while read -r f; do
    python3 - "$f" << 'PYEOF'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    text = fh.read()
# Strip block comments /- ... -/ (non-greedy, handles nesting poorly but
# matches SYNC-MAP's original methodology which assumes non-nested blocks
# in practice for this codebase).
text = re.sub(r"/-.*?-/", "", text, flags=re.DOTALL)
# Strip line comments -- ...
text = re.sub(r"--.*", "", text)
count = len(re.findall(r"\bsorry\b", text))
print(count)
PYEOF
  done | awk '{s+=$1} END {print s+0}'
}

METALOGIC_DIR="Metalogic"

SORRY_ALGEBRAIC=$(strip_and_count_sorries "${METALOGIC_DIR}/Algebraic")
SORRY_BXCANONICAL=$(strip_and_count_sorries "${METALOGIC_DIR}/BXCanonical")
SORRY_BUNDLE=$(strip_and_count_sorries "${METALOGIC_DIR}/Bundle")

# WeakCanonical/: the Kamp archive used to be nested at
# `Metalogic/WeakCanonical/Kamp/Boneyard/`, so scanning `WeakCanonical/` swept its
# sorries up and the "excluding boneyard" figure was ALL minus the nested count. The
# archives have since been consolidated and that subtree now lives at
# `Boneyard/Kamp/KampWeakCanonical/`, OUTSIDE `WeakCanonical/`. Subtracting a
# now-always-zero nested count would silently drop those archived sorries out of the
# "including boneyard" total; they are added back explicitly instead, so both published
# figures mean exactly what they meant before the move.
SORRY_WEAKCANONICAL_LIVE=$(strip_and_count_sorries "${METALOGIC_DIR}/WeakCanonical")
SORRY_KAMP_BONEYARD=$(strip_and_count_sorries "${REPO_ROOT}/Boneyard/Kamp/KampWeakCanonical")
SORRY_WEAKCANONICAL_ALL=$((SORRY_WEAKCANONICAL_LIVE + SORRY_KAMP_BONEYARD))
SORRY_WEAKCANONICAL_EXCL=${SORRY_WEAKCANONICAL_LIVE}

# Everything else in Metalogic/ (Core, ConservativeExtension, Decidability,
# Relational, SoundnessLemmas, plus top-level .lean files).
SORRY_OTHER_TOP=$(python3 - << 'PYEOF'
import re, glob
total = 0
for f in glob.glob("Metalogic/*.lean"):
    with open(f, encoding="utf-8") as fh:
        text = fh.read()
    text = re.sub(r"/-.*?-/", "", text, flags=re.DOTALL)
    text = re.sub(r"--.*", "", text)
    total += len(re.findall(r"\bsorry\b", text))
print(total)
PYEOF
)
SORRY_CORE=$(strip_and_count_sorries "${METALOGIC_DIR}/Core")
SORRY_DECIDABILITY=$(strip_and_count_sorries "${METALOGIC_DIR}/Decidability")
SORRY_SOUNDNESSLEMMAS=$(strip_and_count_sorries "${METALOGIC_DIR}/SoundnessLemmas")

# ConservativeExtension/ and Relational/ no longer exist (archived and removed
# respectively) and are no longer summed here.
SORRY_OTHER=$((SORRY_OTHER_TOP + SORRY_CORE + SORRY_DECIDABILITY + SORRY_SOUNDNESSLEMMAS))

SORRY_TOTAL_INCL_BONEYARD=$((SORRY_ALGEBRAIC + SORRY_BXCANONICAL + SORRY_BUNDLE + SORRY_WEAKCANONICAL_ALL + SORRY_OTHER))
SORRY_TOTAL_EXCL_BONEYARD=$((SORRY_ALGEBRAIC + SORRY_BXCANONICAL + SORRY_BUNDLE + SORRY_WEAKCANONICAL_EXCL + SORRY_OTHER))

# ---------------------------------------------------------------------------
# Version pins
#
# All three are plain file reads, so they are available in --json mode (which
# must run without a build). The toolchain file carries no trailing newline in
# some checkouts, hence the explicit trim.
# ---------------------------------------------------------------------------
LEAN_TOOLCHAIN_PIN=$(tr -d '[:space:]' < "${REPO_ROOT}/lean-toolchain")

# The requested tag is what lakefile.toml asks for; the resolved commit is what
# lake actually fetched. They are reported separately because a moved tag would
# change the second without changing the first.
MATHLIB_TAG=$(awk '
  /^\[\[require\]\]/ { inreq=1; name="" }
  inreq && /^name *= *"mathlib"/ { ismathlib=1 }
  inreq && ismathlib && /^rev *= */ {
    gsub(/^rev *= *"/, ""); gsub(/"$/, ""); print; exit
  }
  /^\[\[lean_lib\]\]/ { inreq=0; ismathlib=0 }
' "${REPO_ROOT}/lakefile.toml")

MATHLIB_REV=$(python3 - "${REPO_ROOT}/lake-manifest.json" << 'PYEOF'
import json, sys
with open(sys.argv[1], encoding="utf-8") as fh:
    manifest = json.load(fh)
for pkg in manifest.get("packages", []):
    if pkg.get("name") == "mathlib":
        print(pkg.get("rev", ""))
        break
PYEOF
)

# ---------------------------------------------------------------------------
# Repository scale
#
# Per-tree file and line counts over the LIVE trees only. Boneyard/ is
# deliberately absent: an archived figure must never be foldable into a live
# one, which is the same rule the split WeakCanonical sorry row enforces above.
# ---------------------------------------------------------------------------
count_lean_files() {
  find "$1" -name '*.lean' -type f 2>/dev/null | wc -l | tr -d ' '
}

count_lean_lines() {
  find "$1" -name '*.lean' -type f -exec cat {} + 2>/dev/null | wc -l | tr -d ' '
}

FORMALSYSTEM_FILE_COUNT=$(count_lean_files "${REPO_ROOT}/FormalSystem")
FORMALSYSTEM_LINE_COUNT=$(count_lean_lines "${REPO_ROOT}/FormalSystem")
TESTS_FILE_COUNT=$(count_lean_files "${REPO_ROOT}/Tests")
TESTS_LINE_COUNT=$(count_lean_lines "${REPO_ROOT}/Tests")
TOOLS_FILE_COUNT=$(count_lean_files "${REPO_ROOT}/BimodalTools")
TOOLS_LINE_COUNT=$(count_lean_lines "${REPO_ROOT}/BimodalTools")

# A repo-wide tracked-file count is deliberately NOT emitted. It changes on
# every commit that adds any file anywhere, so policing it under Check 2 would
# make the sync check fail on work that never touched a cited figure. The three
# per-tree Lean counts above are the scale figures that carry meaning.

# Cross-check: FormalSystem.lean is produced by `lake exe mk_all --lib
# FormalSystem` and verified byte-for-byte by its --check mode, so it carries
# exactly one import line per file under FormalSystem/. A mismatch against the
# filesystem count is a real inconsistency (a file added without regenerating
# the root), not a counting bug. Warn loudly and keep going: --json is consumed
# by typst-sync-check.sh, and bricking the sync check over an unrelated mk_all
# drift would hide every other figure it polices.
FORMALSYSTEM_IMPORT_COUNT=$(grep -c '^import ' "${REPO_ROOT}/FormalSystem.lean" || true)
if [[ "${FORMALSYSTEM_IMPORT_COUNT}" != "${FORMALSYSTEM_FILE_COUNT}" ]]; then
  echo "typst-status-counts.sh: WARNING -- FormalSystem.lean has ${FORMALSYSTEM_IMPORT_COUNT}" >&2
  echo "  import lines but FormalSystem/ has ${FORMALSYSTEM_FILE_COUNT} .lean files." >&2
  echo "  Run 'lake exe mk_all --lib FormalSystem' to regenerate the library root." >&2
fi

# ---------------------------------------------------------------------------
# Commit stamp
# ---------------------------------------------------------------------------
STAMP_COMMIT=$(git -C "${REPO_ROOT}" rev-parse --short HEAD)
STAMP_DATE=$(date -u +%Y-%m-%d)

# ---------------------------------------------------------------------------
# Emit JSON (always computed; used for --json mode and for sync-check diff)
# ---------------------------------------------------------------------------
JSON=$(cat << EOF
{
  "axiom_count": ${AXIOM_COUNT},
  "rule_count": ${RULE_COUNT},
  "base_count": ${BASE_COUNT},
  "dense_only_count": ${DENSE_ONLY_COUNT},
  "ztime_only_count": ${ZTIME_ONLY_COUNT},
  "rtime_only_count": ${RTIME_ONLY_COUNT},
  "sorry_total": ${SORRY_TOTAL_INCL_BONEYARD},
  "sorry_total_excl_boneyard": ${SORRY_TOTAL_EXCL_BONEYARD},
  "sorry_algebraic": ${SORRY_ALGEBRAIC},
  "sorry_bxcanonical": ${SORRY_BXCANONICAL},
  "sorry_bundle": ${SORRY_BUNDLE},
  "sorry_weakcanonical": ${SORRY_WEAKCANONICAL_ALL},
  "sorry_weakcanonical_excl_boneyard": ${SORRY_WEAKCANONICAL_EXCL},
  "sorry_other": ${SORRY_OTHER},
  "lean_toolchain_pin": "${LEAN_TOOLCHAIN_PIN}",
  "mathlib_tag": "${MATHLIB_TAG}",
  "mathlib_rev": "${MATHLIB_REV}",
  "formalsystem_file_count": ${FORMALSYSTEM_FILE_COUNT},
  "formalsystem_line_count": ${FORMALSYSTEM_LINE_COUNT},
  "tests_file_count": ${TESTS_FILE_COUNT},
  "tests_line_count": ${TESTS_LINE_COUNT},
  "tools_file_count": ${TOOLS_FILE_COUNT},
  "tools_line_count": ${TOOLS_LINE_COUNT},
  "stamp_commit": "${STAMP_COMMIT}",
  "stamp_date": "${STAMP_DATE}"
}
EOF
)

if [[ "${JSON_ONLY}" == "1" ]]; then
  echo "${JSON}"
  exit 0
fi

echo "${JSON}"

# ---------------------------------------------------------------------------
# Per-declaration axiom report
#
# The five flagship completeness declarations the typst status chapter displays.
# Their axiom sets are read out of the BUILT LIBRARY with `#print axioms`, never
# typed: the same construction C2 and C14 use in
# scripts/check-module-invariants.sh. Names are FULLY QUALIFIED, because
# `completeness_dense` and `completeness_ztime` each name two distinct live
# theorems -- one in `FormalSystem.Metalogic.BXCanonical`, one in
# `FormalSystem.Metalogic` -- and the module column alone does not disambiguate
# them.
#
# This step needs a built library, which is why it lives in the write path and
# not in `--json`: `--json` is consumed by typst-sync-check.sh, which must run
# without a build.
# ---------------------------------------------------------------------------
AXIOM_DECLS=(
  FormalSystem.Metalogic.BXCanonical.completeness
  FormalSystem.Metalogic.BXCanonical.derivable_of_validDense
  FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime
  FormalSystem.Metalogic.BXCanonical.completeness_rtime_engine
  FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense
)

AX_SRC=$(mktemp --suffix=.lean)
{
  echo "import FormalSystem"
  for d in "${AXIOM_DECLS[@]}"; do echo "#print axioms ${d}"; done
} > "${AX_SRC}"
# The pretty-printer wraps at a fixed width, so a long axiom record spills onto
# continuation lines beginning with a space; rejoin them before parsing or the
# record is silently truncated.
if ! AX_OUT=$(cd "${REPO_ROOT}" && lake env lean "${AX_SRC}" 2>&1 \
      | sed -e ':a' -e '$!N' -e 's/\n / /' -e 'ta' -e 'P' -e 'D' \
      | grep 'depends on axioms'); then
  echo "typst-status-counts.sh: could not read axiom sets from the built library." >&2
  echo "  Run 'lake build' first; the axiom report is generated, never typed." >&2
  rm -f "${AX_SRC}"
  exit 1
fi
rm -f "${AX_SRC}"

AXIOM_REPORT_TYP=$(AX_OUT="${AX_OUT}" \
  TYPST_AXIOM_MODULES="${REPO_ROOT}/scripts/typst-axiom-report-modules.txt" \
  python3 "${REPO_ROOT}/scripts/lib/typst_axiom_report.py")

# ---------------------------------------------------------------------------
# Write typst/generated/status.typ
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "${OUT_TYP}")"
cat > "${OUT_TYP}" << EOF
// ============================================================================
// generated/status.typ
//
// GENERATED FILE -- never edit by hand. Regenerate via:
//   scripts/typst-status-counts.sh
//
// Reproduces the SYNC-MAP.md Phase 1 ground-truth-counts methodology.
// Stamped from live source at commit ${STAMP_COMMIT} (${STAMP_DATE}).
// ============================================================================

#let stamp-commit = "${STAMP_COMMIT}"
#let stamp-date = "${STAMP_DATE}"

#let axiom-count = ${AXIOM_COUNT}
#let rule-count = ${RULE_COUNT}
#let base-count = ${BASE_COUNT}
#let dense-only-count = ${DENSE_ONLY_COUNT}
#let ztime-only-count = ${ZTIME_ONLY_COUNT}
#let rtime-only-count = ${RTIME_ONLY_COUNT}

#let sorry-total = ${SORRY_TOTAL_INCL_BONEYARD}
#let sorry-total-excl-boneyard = ${SORRY_TOTAL_EXCL_BONEYARD}

// Version pins. lean-toolchain-pin is the whole toolchain string; mathlib-tag
// is what lakefile.toml requests and mathlib-rev is what lake resolved it to.
#let lean-toolchain-pin = "${LEAN_TOOLCHAIN_PIN}"
#let mathlib-tag = "${MATHLIB_TAG}"
#let mathlib-rev = "${MATHLIB_REV}"

// Repository scale, LIVE trees only. Boneyard/ is deliberately absent so that
// no archived figure can be folded into a live one.
#let formalsystem-file-count = ${FORMALSYSTEM_FILE_COUNT}
#let formalsystem-line-count = ${FORMALSYSTEM_LINE_COUNT}
#let tests-file-count = ${TESTS_FILE_COUNT}
#let tests-line-count = ${TESTS_LINE_COUNT}
#let tools-file-count = ${TOOLS_FILE_COUNT}
#let tools-line-count = ${TOOLS_LINE_COUNT}

#let sorry-table = (
  ("Algebraic/", ${SORRY_ALGEBRAIC}),
  ("BXCanonical/", ${SORRY_BXCANONICAL}),
  ("Bundle/", ${SORRY_BUNDLE}),
  ("WeakCanonical/ (live)", ${SORRY_WEAKCANONICAL_EXCL}),
  ("WeakCanonical/ (archived, Boneyard/Kamp/)", ${SORRY_KAMP_BONEYARD}),
  ("Core/, Decidability/, SoundnessLemmas/, top-level", ${SORRY_OTHER}),
)

// The WeakCanonical row is SPLIT because the un-split row printed an ARCHIVED
// count beside \`sorry-total-excl-boneyard\`, which is a LIVE figure: a reader saw
// "0 sorries outside the archive" next to "WeakCanonical/: 4" and had no way to
// tell the 4 was entirely archived. The generator already computes both halves,
// so the split costs nothing and removes the contradiction.

${AXIOM_REPORT_TYP}
EOF

echo "Wrote ${OUT_TYP}" >&2
