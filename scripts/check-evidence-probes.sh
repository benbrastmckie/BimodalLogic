#!/usr/bin/env bash
# Compile-check the bi-lasso decision layer's evidence probes.
#
# WHAT A PROBE IS.  Each file under the evidence directory below is a machine-checked record of a
# design obstruction: a `sorry`-free Lean file whose theorems REFUTE something the plan for the
# decision layer once proposed.  They are not tests of the layer's behaviour; they are the reasons
# the layer has the shape it has.
#
# WHY THEY NEED A GUARD.  A probe lives under `specs/`, so no Lake target root reaches it and
# `lake build` never compiles it.  Left alone it rots: the definitions it cites drift, and the
# record silently stops meaning what it says.  Worse, a probe that has quietly stopped compiling
# is no longer an obstacle to anyone, so a future change can undo the very decision it records.
# This script is what keeps that from happening -- it is the analogue, for probes, of the C6 rot
# guard in `check-module-invariants.sh`, and uses the same mechanism (`lake env lean` on a file
# outside the build graph).
#
# WHAT EACH PROBE HOLDS IN PLACE.  See the table in the WIRED list below.
#
# Usage:
#   bash scripts/check-evidence-probes.sh
#
# Exit status: 0 if every wired probe compiles, 1 otherwise.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

EVIDENCE="specs/417_semantic_fmp_finite_worldstate_over_z/evidence"

# --- WIRED --------------------------------------------------------------------------------
# probe                                    | the decision it holds in place
# -----------------------------------------|--------------------------------------------------
# phase3-scan-bound-is-false                | no bound computed from the lasso's segment lengths
#                                          | alone can drive a semantic scan -- this is why the
#                                          | layer enumerates annotations instead of evaluating
# phase7-filtered-frame-is-universal        | the filtered frame's one-step relation is
#                                          | universal, so it carries no dynamics -- this is why
#                                          | the layer presents frames rather than filtering
# phase12-check-not-compositional           | the `imp` case admits no compositional reading --
#                                          | this is why `check`'s two existentials sit OUTSIDE
#                                          | any recursion on the formula
# phase10-origin-anchoring-obstruction      | no recurrence of the type at the point of interest
#                                          | need exist -- this is what stops `check` being
#                                          | re-anchored at position 0.  Load-bearing: it is the
#                                          | probe a future dispatch is most likely to try to
#                                          | contradict, since anchoring looks like a cleanup
WIRED=(
  "phase3-scan-bound-is-false"
  "phase7-filtered-frame-is-universal"
  "phase12-check-not-compositional"
  "phase10-origin-anchoring-obstruction"
)

# --- DEFERRED -----------------------------------------------------------------------------
# `spike-untl-unfolding-and-fwd-obstruction` is deliberately NOT wired.  It compiles today, but
# its subject is the frame-class mismatch between `FrameClass.Base` and `FrameClass.Discrete`,
# and it asserts results about a `filteredStep_fwd` that the frame-class uniformity work is
# expected to change.  Wiring it now would freeze a question that is still open.  Wire it in when
# that work lands.
DEFERRED=("spike-untl-unfolding-and-fwd-obstruction")

failures=0
echo "Evidence probes (compile-checked outside the build graph)"
echo "========================================================="

for probe in "${WIRED[@]}"; do
  file="$EVIDENCE/$probe.lean"
  printf '  %-46s ' "$probe"
  if [ ! -f "$file" ]; then
    echo "FAIL (missing: $file)"
    failures=$((failures + 1))
    continue
  fi
  if out=$(lake env lean "$file" 2>&1); then
    echo "PASS"
  else
    echo "FAIL (does not compile)"
    printf '%s\n' "$out" | sed 's/^/        /'
    failures=$((failures + 1))
  fi
done

for probe in "${DEFERRED[@]}"; do
  printf '  %-46s ' "$probe"
  if [ -f "$EVIDENCE/$probe.lean" ]; then
    echo "SKIP (deferred: frame-class uniformity work)"
  else
    echo "SKIP (deferred; file absent)"
  fi
done

echo
if [ "$failures" -eq 0 ]; then
  echo "PASS  all ${#WIRED[@]} wired probe(s) compile"
  exit 0
fi
echo "FAIL  $failures of ${#WIRED[@]} wired probe(s) failed"
echo
echo "A probe failing means a recorded design obstruction no longer compiles."
echo "Do NOT delete the probe or weaken its statements to make this pass: repair the"
echo "citation drift, or -- if the obstruction genuinely no longer holds -- say so"
echo "explicitly and revisit the decision the probe was holding in place."
exit 1
