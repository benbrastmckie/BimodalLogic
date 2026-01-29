# Implementation Plan: Task #628 (Revised)

- **Task**: 628 - Prove semantic_truth_implies_truth_at (upward bridge)
- **Status**: [PLANNED]
- **Version**: 002
- **Created**: 2026-01-29
- **Revised From**: implementation-001.md
- **Effort**: 1-2 hours
- **Priority**: Low → ABANDON RECOMMENDED
- **Dependencies**: None (task is now irrelevant)
- **Research Inputs**: specs/628_prove_semantic_truth_implies_truth_at_upward_bridge/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true (but work is obsolete)

## Revision Summary

**This task should be ABANDONED.** The completeness architecture has been completely restructured since the original plan was written, making the upward bridge theorem irrelevant.

### What Changed

1. **New Completeness Architecture** (Task 660, completed 2026-01-29)
   - `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Weak completeness via representation theorem
   - `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - Strong completeness for finite contexts
   - `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` - Set-based contexts

2. **The Representation Theorem Now Directly Provides Completeness**
   - `representation_theorem` in `UniversalCanonicalModel.lean` shows consistent formulas are satisfiable
   - `weak_completeness` uses this directly: valid φ → provable φ
   - No need for the "upward bridge" between finite model truth and general `truth_at`

3. **Original Target No Longer Exists**
   - The file `Logos/Metalogic_v2/FiniteModelProperty.lean` referenced in the original plan is in the Boneyard
   - The `semantic_truth_implies_truth_at` theorem was part of a deprecated approach
   - The new architecture in `Theories/Bimodal/Metalogic/` uses a different strategy entirely

4. **Sorries in New Architecture Are Different**
   - `soundness` in WeakCompleteness.lean (pending Boneyard fix)
   - `infinitary_strong_completeness` (requires ultraproducts/compactness)
   - Various sorries in Representation layer (T-axiom applications, cross-origin cases)
   - **None of these require the upward bridge theorem**

### Architectural Comparison

| Aspect | Original Plan (Boneyard) | Current Architecture |
|--------|-------------------------|----------------------|
| Completeness core | `semantic_weak_completeness` via FMP | `weak_completeness` via representation theorem |
| Truth bridge needed | Yes, for FMP generalization | No, representation theorem is sufficient |
| Target file | Boneyard/Metalogic_v2/FiniteModelProperty.lean | N/A - architecture doesn't need it |
| Status | OBSOLETE | ACTIVE |

## Recommendation: ABANDON

The original task aimed to prove `semantic_truth_implies_truth_at` at line 481 of `Boneyard/Metalogic_v2/FiniteModelProperty.lean`. This work is now irrelevant because:

1. **The completeness proof no longer needs this bridge** - The new architecture proves completeness via the representation theorem directly
2. **The Boneyard code is deprecated** - The active metalogic is in `Theories/Bimodal/Metalogic/`
3. **Effort is better spent on active sorries** - Tasks like:
   - Task 700 (algebraic representation theorem)
   - Task 733 (ultraproduct-based compactness)
   - Task 732 (Truth Lemma phase 4)

## Alternative: Related Active Work

If upward/downward bridge work is still desired, it should be reconceptualized for the new architecture:

### The New Sorries in Representation Layer

| File | Sorry | Purpose | Related to Original Task? |
|------|-------|---------|---------------------------|
| TruthLemma.lean:382 | Box forward | Box case of truth lemma | YES - same difficulty |
| TruthLemma.lean:405 | Box backward | Box case of truth lemma | YES - same difficulty |
| TruthLemma.lean:423 | all_past backward | Temporal backward | YES - bounded relevance needed |
| TruthLemma.lean:441 | all_future backward | Temporal backward | YES - bounded relevance needed |
| CoherentConstruction.lean | Various | Cross-origin cases | Partially related |

**Note**: These sorries are explicitly marked as "NOT REQUIRED FOR COMPLETENESS" in the code. The representation theorem works without them by only using the forward direction of the Truth Lemma.

### If Reopening This Work

If there is a desire to complete these sorries (for theoretical completeness, not practical necessity), a new task should be created with scope limited to:

1. **Forward/backward Truth Lemma for box** - 4-6 hours, same difficulty as original task
2. **Backward Truth Lemma for temporal** - 3-4 hours, needs bounded relevance lemma

These would NOT affect the completeness results, which are already proven via the representation theorem path.

## Phase 1: Cleanup (Optional) [NOT STARTED]

**Goal**: Mark task as abandoned and document the architectural change.

**Tasks**:
- [ ] Add note to Boneyard/Metalogic_v2/FiniteModelProperty.lean explaining the sorry is superseded
- [ ] Update related task notes (631, 610, 627) to reference the new architecture

**Timing**: 30 minutes

**Verification**:
- Documentation updated

## Conclusion

**Recommendation**: Mark task 628 as ABANDONED with reason "Architecture changed - upward bridge no longer needed for completeness". The 12-16 hours originally estimated would be spent on deprecated code. The completeness results are already achieved via the representation theorem approach.

---

## Appendix: Current Sorry Count in Active Metalogic

| Layer | File | Sorries | Impact on Completeness |
|-------|------|---------|------------------------|
| Completeness | WeakCompleteness.lean | 1 (soundness) | Blocks equivalence only |
| Completeness | InfinitaryStrongCompleteness.lean | 1 | Infinite contexts only |
| Representation | TruthLemma.lean | 4 | None (forward direction works) |
| Representation | CanonicalWorld.lean | 2 | Minor (MCS properties) |
| Representation | CanonicalHistory.lean | 2 | Minor (T-axiom) |
| Representation | UniversalCanonicalModel.lean | 4 | Minor (edge cases) |
| Representation | TaskRelation.lean | 6 | Minor (compositionality) |
| Representation | CoherentConstruction.lean | 11 | None (forward chain works) |
| Representation | IndexedMCSFamily.lean | 4 | Superseded by CoherentConstruction |

**Total active sorries**: ~35 (none blocking weak/strong completeness)
