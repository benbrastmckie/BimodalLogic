#!/usr/bin/env bash
# Compile-check the tracked evidence probes under `specs/evidence/`.
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
# WHY THE PROBES DO NOT LIVE IN A TASK DIRECTORY.  They used to, under
# `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/`.  When `/todo` archived that task the
# whole directory moved to `specs/archive/`, which `.gitignore` excludes -- so the four probes left
# version control entirely (absent from a fresh clone) and this guard failed on every run against a
# path that no longer existed.  Nothing announced either fact, because this script is not wired into
# CI.  A probe outlives the task that produced it by construction: it records a design obstruction,
# not a unit of work.  It therefore lives in `specs/evidence/`, which is task-independent and
# tracked, exactly as `specs/reviews/` is.  Do not move a probe back under a task directory.
#
# WHAT EACH PROBE HOLDS IN PLACE.  See the tables in the WIRED and WIRED_REPO lists below.
#
# TWO ENTRY FORMS.  `WIRED` entries are paths under `specs/evidence/`, which is where a probe
# belongs.  `WIRED_REPO` entries are full repository-relative paths, for the case where a probe
# cannot yet be moved into the collection because other files cite its current path verbatim.
# Both forms are checked identically by `check_probe` below; the second exists only so that a
# probe stranded outside the collection is still guarded rather than left to rot unwatched.
# Prefer `WIRED`: reach for `WIRED_REPO` only with a named blocker recorded beside the entry.
#
# Usage:
#   bash scripts/check-evidence-probes.sh
#
# Exit status: 0 if every wired probe compiles, 1 otherwise.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

# Collection-relative: each WIRED entry below is a path under `specs/evidence/`, so several
# probe collections can be guarded by the one loop.
EVIDENCE="specs/evidence"

# --- WIRED --------------------------------------------------------------------------------
# probe (path under specs/evidence/)                        | the decision it holds in place
# ----------------------------------------------------------|-----------------------------------
# bi-lasso-decision-layer/phase3-scan-bound-is-false         | no bound computed from the lasso's
#                                                           | segment lengths alone can drive a
#                                                           | semantic scan -- this is why the
#                                                           | layer enumerates annotations instead
#                                                           | of evaluating
# bi-lasso-decision-layer/phase7-filtered-frame-is-universal | the filtered frame's one-step
#                                                           | relation is universal, so it carries
#                                                           | no dynamics -- this is why the layer
#                                                           | presents frames rather than
#                                                           | filtering
# bi-lasso-decision-layer/phase12-check-not-compositional    | the `imp` case admits no
#                                                           | compositional reading -- this is why
#                                                           | `check`'s two existentials sit
#                                                           | OUTSIDE any recursion on the formula
# bi-lasso-decision-layer/phase10-origin-anchoring-obstruction | no recurrence of the type at the
#                                                           | point of interest need exist -- this
#                                                           | is what stops `check` being
#                                                           | re-anchored at position 0.
#                                                           | Load-bearing: it is the probe a
#                                                           | future dispatch is most likely to
#                                                           | try to contradict, since anchoring
#                                                           | looks like a cleanup
# stability-modal-substrate/closure-field-is-necessary   | `SharingSkeleton`'s `lift` field is a
#                                                           | genuine obligation, not a defensive
#                                                           | one.  Give the landed (C5) witness
#                                                           | `stabFamily` the no-hopping
#                                                           | succession bundle, changing nothing
#                                                           | else, and `LiftableRaw` becomes
#                                                           | FALSE: `crossPath` is a `Step`-path
#                                                           | no index-identity path tracks.  This
#                                                           | is why `lift` is a field every
#                                                           | producer discharges rather than a
#                                                           | lemma proved once, and it is the
#                                                           | probe a future dispatch is most
#                                                           | likely to try to eliminate, since
#                                                           | the field looks like boilerplate
# frame-constraints-audit/mixed-sign-composition-obstruction | mixed-sign composition (`TotalComp`)
#                                                           | must NOT be added to `def:frame` --
#                                                           | the drift frame `F°` satisfies all
#                                                           | four constraints and fails it, and
#                                                           | `app:drift` needs `F°` for
#                                                           | `cor:no-characterization`.  It also
#                                                           | carries the positive half:
#                                                           | `Completion -> Saturation` holds
#                                                           | UNDER `TotalComp`, which locates the
#                                                           | obstruction exactly
# seam-gluing-ray-product/stab-fibre-is-ray-product         | the `⊡` quantification domain IS the
#                                                           | fibre product of the past-ray and
#                                                           | future-ray spaces over the seam
#                                                           | state (general task frame, and the
#                                                           | ω-sequence form over ℤ) -- this is
#                                                           | the MECHANISM behind the finite-width
#                                                           | refutation (a product of two path
#                                                           | spaces cannot be a finite fibre), not
#                                                           | an escape from it, and every route in
#                                                           | the omega-sequence-decidability round
#                                                           | assumes it
# seam-gluing-ray-product/stab-depth-stratification         | POSITIVE: the `⊡`-value at a state
#                                                           | is computable from a per-state
#                                                           | labelling stratified by `⊡`-depth
#                                                           | (`stratum`), which is exactly what
#                                                           | the landed `atomize` /
#                                                           | `plusTruthAt_iff_atomize` already
#                                                           | supplies -- this licenses R1's
#                                                           | automaton ALPHABET; it bounds and
#                                                           | decides nothing on its own
WIRED=(
  "bi-lasso-decision-layer/phase3-scan-bound-is-false"
  "bi-lasso-decision-layer/phase7-filtered-frame-is-universal"
  "bi-lasso-decision-layer/phase12-check-not-compositional"
  "bi-lasso-decision-layer/phase10-origin-anchoring-obstruction"
  "frame-constraints-audit/mixed-sign-composition-obstruction"
  "stability-modal-substrate/closure-field-is-necessary"
  "seam-gluing-ray-product/stab-fibre-is-ray-product"
  "seam-gluing-ray-product/stab-depth-stratification"
)

# --- WIRED_REPO ---------------------------------------------------------------------------
# Repository-relative probe paths, for probes that cannot (yet) live under `specs/evidence/`.
#
# probe (repository-relative path)                          | the decision it holds in place
# ----------------------------------------------------------|-----------------------------------
# specs/archive/476_box_faithful_small_model_theorem/       | the finite model property FAILS at
#   evidence/fmp-hypothesis-is-false.lean                   | ZTime for EVERY candidate list --
#                                                           | `fmp_false` exhibits one formula no
#                                                           | finite `IntPresentation` satisfies
#                                                           | but which is ZTime-satisfiable.  This
#                                                           | is why the decision layer presents
#                                                           | finite GENERATORS of infinite regular
#                                                           | models rather than searching for a
#                                                           | finite model, and why no finite-model
#                                                           | certificate may be assumed available
#
# WHY THIS ONE IS NOT UNDER `specs/evidence/`.  It should be, by the convention in this file's
# header, and this is a DEFERRED MOVE with a named blocker -- not an exemption.  Three files
# outside the current writable scope cite the probe by its archive path verbatim
# (`FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`,
# `FormalSystem/Metalogic/Decidability/BiLasso/README.md`, and
# `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`), so moving the file would break
# those citations in the same edit.  Move it when those three sites can be updated together.
#
# NOTE ON VERSION CONTROL.  `.gitignore` excludes `specs/archive/`, so this file survives in
# version control only because it was tracked before it was archived; a *new* file at that path
# would not be.  `git add` on it needs `git add -u`, since plain `git add` refuses an
# ignore-matching pathspec.  That fragility is a further reason to complete the move.
# specs/706_.../probes/NoFiniteCarrierModel.lean and specs/710_.../probes/NoFiniteWidthModel.lean
# ARE NOT YET UNDER `specs/evidence/`, and this too is a DEFERRED MOVE with a named blocker, not
# an exemption: both files are owned by their own live tasks (706, 710), which are pending a
# follow-up task's promotion of these two refutations into `FormalSystem/` (see
# `FormalSystem/Metalogic/Decidability/FMP/README.md`'s "The finite-carrier route is refuted, not
# merely open" subsection, which cites them by declaration name:
# `Probe706.no_finite_carrier_sat`, `Probe710.not_finite_width_fmp`). Move them into the
# collection together with that promotion, not before.
WIRED_REPO=(
  "specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean"
  "specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean"
  "specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean"
)

# --- DEFERRED -----------------------------------------------------------------------------
# `spike-untl-unfolding-and-fwd-obstruction` is deliberately NOT wired.  It no longer compiles:
# it cites `FrameClass.Discrete` and `TaskFrame.trivialFrame`, both gone from the current
# frame-class API.  Its subject is the frame-class mismatch between `FrameClass.Base` and
# `FrameClass.Discrete`, and it asserts results about a `filteredStep_fwd` that the frame-class
# uniformity work is expected to change.  Wiring it now would freeze a question that is still
# open.  When that work lands, repair it under the same no-weakening rule as the wired probes
# (track the API; never delete or restate an obstruction to make it pass), then wire it in.
DEFERRED=("bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction")

failures=0
echo "Evidence probes (compile-checked outside the build graph)"
echo "========================================================="

# One check, both entry forms: $1 is the label printed, $2 the file to compile.
check_probe() {
  local label="$1" file="$2"
  printf '  %-62s ' "$label"
  if [ ! -f "$file" ]; then
    echo "FAIL (missing: $file)"
    failures=$((failures + 1))
    return
  fi
  local out
  if out=$(lake env lean "$file" 2>&1); then
    echo "PASS"
  else
    echo "FAIL (does not compile)"
    printf '%s\n' "$out" | sed 's/^/        /'
    failures=$((failures + 1))
  fi
}

for probe in "${WIRED[@]}"; do
  check_probe "$probe" "$EVIDENCE/$probe.lean"
done

for probe in "${WIRED_REPO[@]}"; do
  check_probe "$probe" "$probe"
done

for probe in "${DEFERRED[@]}"; do
  printf '  %-62s ' "$probe"
  if [ -f "$EVIDENCE/$probe.lean" ]; then
    echo "SKIP (deferred: frame-class uniformity work)"
  else
    echo "SKIP (deferred; file absent)"
  fi
done

wired_total=$(( ${#WIRED[@]} + ${#WIRED_REPO[@]} ))

echo
if [ "$failures" -eq 0 ]; then
  echo "PASS  all $wired_total wired probe(s) compile"
  exit 0
fi
echo "FAIL  $failures of $wired_total wired probe(s) failed"
echo
echo "A probe failing means a recorded design obstruction no longer compiles."
echo "Do NOT delete the probe or weaken its statements to make this pass: repair the"
echo "citation drift, or -- if the obstruction genuinely no longer holds -- say so"
echo "explicitly and revisit the decision the probe was holding in place."
exit 1
