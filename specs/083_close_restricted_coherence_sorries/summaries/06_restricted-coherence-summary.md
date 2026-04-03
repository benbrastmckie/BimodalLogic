# Implementation Summary: Task #83 (v6) - Phases 1-3

## Status: PARTIAL (Phases 1-3 of 7 completed)

## What Was Accomplished

### Phase 1: Formula Type Extension [COMPLETED]

Added `untl` (Until) and `snce` (Since) binary constructors to the `Formula` inductive type,
extending the TM logic with temporal Until/Since operators needed for the Burgess-Xu approach
to temporal completeness.

**Files modified**: 10 files across Syntax, ProofSystem, Semantics, Metalogic, and Automation.

**Key decisions**:
- Named constructors `untl`/`snce` (not `until`/`since`) due to Lean 4 keyword conflict
- Added sorry placeholders in 12 truth lemma proof locations (to be filled in Phases 4-7)
- Simplified `eq_of_beq` proof using `nomatch` for cross-constructor dismissals

### Phase 2: SubformulaClosure and DeferralClosure Extension [COMPLETED]

Added Until/Since deferral infrastructure to `SubformulaClosure.lean` without breaking existing
proofs. Introduced `baseDeferralClosure` as an intermediate definition to preserve backward
compatibility.

**New definitions**: `IsUntilFormula`, `IsSinceFormula`, `toUntilDeferral`, `toSinceDeferral`,
`untilDeferralSet`, `sinceDeferralSet`, `baseDeferralClosure`, `extendedDeferralClosure`.

**Key decision**: Kept `deferralClosure = baseDeferralClosure` (identical to old definition) to
avoid cascading proof breakage. The `extendedDeferralClosure` includes Until/Since deferrals
and will be used in later phases.

### Phase 3: Axioms and Proof System [COMPLETED]

Added 10 new Burgess-Xu axiom schemata to the proof system:
- `until_unfold`, `until_intro`, `until_induction`, `until_linearity`
- `since_unfold`, `since_intro`, `since_induction`, `since_linearity`
- `until_connectedness`, `since_connectedness`

All classified as `FrameClass.Discrete`, `isDenseCompatible = False`, `isBase = False`.

Updated Soundness.lean and SoundnessLemmas.lean with sorry stubs for axiom validity proofs.

**Build status**: `lake build` passes with 0 errors.

## What Remains

Phases 4-7 (estimated 15-19 hours):
- Phase 4: Soundness proofs for 10 new axioms + close Truth.lean time-shift sorry
- Phase 5: TemporalContent/Succ relation extension with u_step/s_step
- Phase 6: Dovetailed chain with Until/Since fair scheduling
- Phase 7: Completeness rewiring to close original 2 sorry + 12 truth lemma sorry

## New Sorries Introduced

| Phase | File | Count | Description |
|-------|------|-------|-------------|
| 1 | Truth.lean | 2 | time_shift_preserves_truth for untl/snce |
| 1 | ParametricTruthLemma.lean | 4 | Two truth lemmas x 2 constructors |
| 1 | CanonicalConstruction.lean | 6 | Three truth lemmas x 2 constructors |
| 3 | Soundness.lean | 20 | 10 axiom validity proofs x 2 soundness theorems |

Total: ~32 new sorry placeholders (all tracked, to be closed in Phases 4-7).
