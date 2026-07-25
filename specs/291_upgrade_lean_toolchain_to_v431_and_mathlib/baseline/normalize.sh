#!/usr/bin/env bash
# Normalize one captured executable output stream for comparison.
#
#   Usage: bash normalize.sh [--structural] <file>    (normalized text to stdout)
#
# Normalization is deliberately NARROW. A field is masked only where two runs of the SAME
# build on the SAME input were observed to differ. A value that merely differs before and
# after the upgrade is the signal this gate exists to detect, and is never masked away.
# Per-field justification and the measured reproducibility split live in exe/REPRODUCIBILITY.md.
#
# Default mode  -> for the 7 targets measured as exactly reproducible.
# --structural  -> additionally masks RNG-derived pool cardinalities, for the 5 targets that
#                  call unseeded `IO.rand` (FormulaEnumerator.lean:811+) and therefore do not
#                  reproduce even against themselves. For those, everything EXCEPT the masked
#                  cardinality must still match exactly.
set -u

STRUCTURAL=0
if [ "${1:-}" = "--structural" ]; then STRUCTURAL=1; shift; fi
F="${1:?usage: normalize.sh [--structural] <file>}"

norm() {
  sed -E \
    -e 's/[0-9]+ ms/<MS> ms/g' \
    -e 's/"elapsed_ms": [0-9]+/"elapsed_ms": <MS>/g' \
    -e 's/"time_ms": [0-9]+/"time_ms": <MS>/g' \
    -e 's/elapsed=[0-9]+ms/elapsed=<MS>ms/g' \
    -e 's/elapsed: [0-9]+ms/elapsed: <MS>ms/g' \
    -e 's/[0-9]+s elapsed/<S>s elapsed/g' \
    -e 's#[^ "]*/(exe|exe-run2|exe-post)/([A-Za-z0-9_.-]+)#<OUTDIR>/\2#g' \
    "$F" \
  | grep -vE '^[[:space:]]*Progress: [0-9]+/[0-9]+ formulas labeled[[:space:]]*$'
  #    ^ dataset_validator's feasibility-gate loop runs over 63,067,610 formulas (many hours),
  #      so the capture is capped mid-loop and the cut-off point is a function of machine speed,
  #      not program behavior. Everything meaningful — all 30 conformance assertions and the
  #      enumeration cardinality — precedes the loop and IS compared.
}

if [ "$STRUCTURAL" -eq 1 ]; then
  norm | sed -E \
    -e 's/pool: [0-9]+ unique/pool: <N> unique/g' \
    -e 's/pool size: [0-9]+/pool size: <N>/g' \
    -e 's/pool [0-9]+ -> [0-9]+ \(\+[0-9]+, [0-9]+% growth\)/pool <N> -> <N> (+<N>, <N>% growth)/g' \
    -e 's/pool=[0-9]+ \(\+[0-9]+, [0-9]+% growth\)/pool=<N> (+<N>, <N>% growth)/g' \
    -e 's/\([0-9]+ formulas\/sec\)/(<N> formulas\/sec)/g' \
    -e 's/[0-9]+ theorems in [0-9]+ms/<N> theorems in <MS>ms/g' \
    -e 's/^([[:space:]]*(Valid|Invalid|Timeout|Unknown)): [0-9]+ \([0-9]+%\)/\1: <N> (<N>%)/g' \
    -e 's/VmRSS:[[:space:]]+[0-9]+ kB/VmRSS: <N> kB/g' \
    -e 's/[0-9]+\/[0-9]+ \([0-9]+%\)/<N>\/<N> (<N>%)/g' \
    -e 's/(GoalCategory\.[A-Za-z]+): [0-9]+/\1: <N>/g' \
    -e 's/Axiom-seeded pool: [0-9]+ formulas/Axiom-seeded pool: <N> formulas/g' \
    -e 's/Avg decision time: [0-9]+ms/Avg decision time: <MS>ms/g' \
    -e 's/complete: [0-9]+ valid formulas/complete: <N> valid formulas/g'
else
  norm
fi
