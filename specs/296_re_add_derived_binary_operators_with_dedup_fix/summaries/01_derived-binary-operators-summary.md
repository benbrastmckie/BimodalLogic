# Implementation Summary: Re-Add Derived Binary Temporal Operators (Task #296)

- **Task**: 296 — Re-add derived binary temporal operators with dedup fix
- **Status**: PARTIAL (P1–P3 complete; P4/P5 deferred)
- **Plan**: specs/296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md
- **Session**: sess_1784042369_262c14_296
- **Scope**: Orchestrator directive "code now, defer heavy regen" — implement only the three
  code phases (P1, P2, P3); do NOT run P4 (fresh c4 generator acceptance test) or P5, since P4
  triggers a prohibitively slow ~264MB executable C rebuild deferred to a later user-approved step.

## Outcome

The 6 derived binary temporal operators (`release`, `weak_until`, `trigger`, `weak_since`,
`strong_release`, `strong_trigger`) are re-added to every enumeration path and are now correctly
recognized, tagged, serialized, round-tripped, and measurable at the value level. Every phase ends
at a green build with zero sorries, zero new axioms, and zero vacuous definitions. `#guard`
assertions (which fail the build if false) machine-verify the key claims.

## Phases Completed

### Phase 1 — Enumerator branches re-added (FormulaEnumerator.lean) [COMPLETED]
- Re-added the 6 cross-product builders in `enumExactHelper` (reverse of removal commit
  `8943e3356`), concatenated into the existing `temporalBinaries` array.
- Re-added the binary-derived branches in `sampleOne` (new `offBinaryDerived` slot),
  `sampleOneRandom` (branch 11), and `randomSubFormula` (branch 9, restoring `IO.rand 0 9`).
- Added the 6 branches to `partitionCrossProduct` — the parallel path never had them
  (pre-existing parity gap vs the sequential path; report §2.2).
- Added `#guard` membership assertions: `release(p,q)` and `weak_until(p,q)` appear in the c3
  enumeration (build-failing if absent).
- Enumeration-level delta captured via `#eval`: `enumExactHelper` c4 count = **7852**, c5 = 75914.

### Phase 2 — Representation layer completed (Normalization.lean) [COMPLETED]
- Added 4 `EnrichedFormula` constructors (`release`, `weak_until`, `trigger`, `weak_since`;
  `strong_release`/`strong_trigger` already existed).
- Extended `toPrimitive`, `recognizeComposites`, `toJson`, `prettyPrint`, `toSExpr` (compiler-
  enforced exhaustiveness; no other file in the codebase pattern-matches `EnrichedFormula`).
- Added fold recognition at the natural construction sites:
  - `foldImp`: `release` = `¬(¬φ U ¬ψ)` and `trigger` = `¬(¬φ S ¬ψ)`, placed after the
    `some_future`/`some_past` ⊥-guards so `release(φ,⊥)` still routes to `all_future`.
  - `foldFormula` untl/snce nodes: `strong_release` = `(ψ∧φ) U ψ`, `strong_trigger` = `(ψ∧φ) S ψ`.
  - `recognizeComposites` imp node (where `or_` is formed): `weak_until` = `(φ U ψ) ∨ Gψ`,
    `weak_since` = `(φ S ψ) ∨ Hψ`.
- Added 4 `@[simp]` `rfl` unfold lemmas and extended the three unfold-direction macros
  (`modal_norm`, `modal_norm_at`, `modal_norm_all`).
- Added a `#guard` round-trip suite: all 6 operators fold to their own tag and satisfy
  `toPrimitive ∘ foldFormulaFull = id`; the `release(p,⊥) → all_future` regression holds.

### Phase 3 — Value-level census + fold-tag cross-check (Normalization.lean) [COMPLETED]
- Added `Formula.matchBinaryDerived`: a primitive-pattern top-node matcher for the 6 binary
  operators with ⊥-guards mirroring the fold's collapse priorities (so `release(φ,⊥)` is not
  miscounted as a `release`).
- Added `EnrichedFormula.topBinaryTag` / `Formula.foldedBinaryTag` (folded-tag census) and the
  `valueCensus` / `foldedCensus` list utilities.
- Added a `#guard` cross-check over a 7-formula sample: value census == folded census, all 6 tags
  present exactly once, and the `release(p,⊥)` collapse is counted by neither census.

## Verification

- `lake build Bimodal.Automation.FormulaEnumerator` — green.
- `lake build Bimodal.Automation.Normalization` — green.
- `lake build Bimodal.Automation` (1046 jobs, all downstream library modules) — green.
- All `#guard` assertions pass (build-failing otherwise).
- sorry_count = 0, vacuous_count = 0, new axioms = 0 (in both modified files).
- No signature changes; no other module pattern-matches `EnrichedFormula`, so no downstream breakage.

## Plan Deviations

- **Phase 1, live-binary baseline (deferred)**: The plan's final P1 task runs a fresh c4 baseline
  via the real `dataset_generator` binary. That run triggers the same ~264MB executable C rebuild
  as P4, so per the orchestrator directive it is deferred to P4. The enumeration-level delta is
  captured instead via `#eval` (c4 = 7852, c5 = 75914) and `#guard` membership at c3.
- **Phase 2, `modal_fold` macro (altered)**: The 4 unfold lemmas were added and the three
  unfold-direction macros were extended, but the reverse-direction `modal_fold` macro was
  intentionally NOT extended. These operators' unfold RHS contains further derived operators
  (`.or`/`.all_future`/`.all_past`), so a `← _unfold` rewrite would break simp confluence in the
  existing `RoundTripTests`. The value-level `foldFormula`/`recognizeComposites` recognition — the
  actual fold path used by the census and serialization — fully handles them.

## Deferred (require later user-approved step)

- **Phase 4** — Fresh c4 generation + acceptance test (all 13 operators present in unique pipeline
  output). Deferred because `lake exe dataset_generator` triggers a slow full C rebuild. This is
  the research acceptance test; the code is ready for it.
- **Phase 5 (optional)** — `always`/`sometimes` complexity-gate adjustment, executed only if P4
  finds those two complexity-2 unary operators absent. The 6 binary operators are unaffected.

## Continuation

Next action: run Phase 4 (`lake exe dataset_generator -- --max-complexity 4 --output
data/bmlogic-c4.jsonl`, clearing `.checkpoint` first), then run `valueCensus`/`foldedCensus` over
the generated JSONL to confirm all 13 derived operators have nonzero presence. Budget for a single
slow generator/rebuild run.

## Artifacts

- `Theories/Bimodal/Automation/FormulaEnumerator.lean` (modified — enumerator branches + census guards)
- `Theories/Bimodal/Automation/Normalization.lean` (modified — representation layer + census)
- `specs/296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md`
  (phase markers + deviation annotations)
