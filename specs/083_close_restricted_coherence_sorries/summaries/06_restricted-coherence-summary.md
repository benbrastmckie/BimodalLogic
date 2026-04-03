# Implementation Summary: Task #83 (v6) - Phases 1-4

## Status: PARTIAL (Phases 1-3 completed, Phase 4 partial)

## What Was Accomplished

### Phase 1: Formula Type Extension [COMPLETED]

Added `untl` (Until) and `snce` (Since) binary constructors to the `Formula` inductive type.

**Files modified**: 10 files across Syntax, ProofSystem, Semantics, Metalogic, and Automation.

**Key decisions**:
- Named constructors `untl`/`snce` (not `until`/`since`) due to Lean 4 keyword conflict
- Added sorry placeholders in 12 truth lemma proof locations (to be filled in later phases)

### Phase 2: SubformulaClosure and DeferralClosure Extension [COMPLETED]

Added Until/Since deferral infrastructure to `SubformulaClosure.lean`.

**New definitions**: `IsUntilFormula`, `IsSinceFormula`, `toUntilDeferral`, `toSinceDeferral`,
`untilDeferralSet`, `sinceDeferralSet`, `baseDeferralClosure`, `extendedDeferralClosure`.

### Phase 3: Axioms and Proof System [COMPLETED]

Added 10 new Burgess-Xu axiom schemata. All classified as `FrameClass.Discrete`.

### Phase 4: Semantics Extension [PARTIAL]

**Completed**:
- `time_shift_preserves_truth` for untl/snce: DONE (both sorry closed)
- `truth_double_shift_cancel` for untl/snce: DONE (already completed in Phase 1)
- Truth.lean is now SORRY-FREE

**Blocked**:
- Soundness proofs for 10 new axioms: BLOCKED by axiom formulation issue

### BLOCKER: Axiom Formulation Issue with Reflexive Semantics

The standard Burgess-Xu axioms (1982/1988) assume STRICT temporal operators where G means
"at all future times s > t". Our system uses REFLEXIVE temporal operators where G means
"at all times s >= t" (including t itself).

**Specific issue with `until_unfold`**: The axiom `(φ U ψ) → ψ ∨ (φ ∧ G(φ U ψ))` requires
`G(φ U ψ)` at time t, meaning `∀ s ≥ t, (φ U ψ) at s`. But `φ U ψ` at time t with witness s
only guarantees `φ U ψ` at times in `[t, s]`, NOT at times beyond `s`. For times `s' > s` (the
Until witness), there is no guarantee that `φ U ψ` holds.

**Impact**: This makes `until_unfold` semantically INVALID under reflexive semantics as
currently formulated. The `until_intro` (converse) is similarly affected.

**Resolution options**:
1. Reformulate axioms to use strict-future `F'` (define `F'φ := F(φ) ∧ φ`, the weak closure)
2. Switch Until/Since semantics to strict: `∃ s > t` instead of `∃ s ≥ t`
3. Use `some_future (φ U ψ)` (existential, not universal) in the unfolding
4. Research the correct reflexive-time formulation of Burgess-Xu axioms

This requires a research round (not implementation) to determine the correct axiom set.

## Build Status

`lake build` passes with 0 errors (938 jobs).

## Sorry Count

| Location | Count | Status |
|----------|-------|--------|
| Truth.lean | 0 | CLOSED (Phase 4) |
| ParametricTruthLemma.lean | 4 | Open (Phase 7) |
| CanonicalConstruction.lean | 6 | Open (Phase 7) |
| Soundness.lean | 20 | BLOCKED (axiom formulation) |

Total new sorry: ~30 (down from ~32, after closing Truth.lean sorry).
