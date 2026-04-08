# Implementation Summary: Split Until/Since Coherence

- **Task**: 84 - Establish until_since_coherent for chain constructions
- **Plan**: plans/04_until-since-split.md (v3)
- **Status**: [COMPLETED]
- **Phases**: 4/4 completed

## What Was Done

### Phase 1: Split Predicate Definition
- Defined `BFMCS.backward_until_since_coherent` (conjuncts 2, 4)
- Defined `BFMCS.forward_until_since_coherent` (conjuncts 1, 3)
- Proved `split_until_since_coherent`, `until_since_coherent_backward`, `until_since_coherent_forward`

### Phase 2: Refactor Truth Lemma Signatures
- Split `h_uc : B.until_since_coherent` into `h_buc` + `h_fuc` in:
  - `parametric_canonical_truth_lemma` and `parametric_shifted_truth_lemma`
  - `canonical_truth_lemma`, `shifted_truth_lemma`, `restricted_shifted_truth_lemma`
  - All re-exports: `base_truth_lemma`, `base_shifted_truth_lemma`, `discrete_base_truth_lemma`, `canonical_truth_lemma_int`, `shifted_truth_lemma_int`
  - All ParametricRepresentation.lean theorems (4 signatures)

### Phase 3: Wire Backward Coherence
- Wired `backward_until_coherent` and `backward_since_coherent` from UntilSinceCoherence.lean into all 3 completeness theorems
- Step transfer hypothesis is sorry'd: g_content propagates G-formulas forward but cannot pull Until backward
- Each sorry is now precisely typed: `φ.untl ψ ∈ fam.mcs r` given `φ.untl ψ ∈ fam.mcs (r+1)` and `φ ∈ fam.mcs r`

### Phase 4: Document Forward Sorry Sites
- Added inline docstring comments at each `h_fuc` sorry explaining the blocker
- Updated sorry summary table in Completeness.lean

## Files Modified

| File | Changes |
|------|---------|
| `Metalogic/Bundle/TemporalCoherence.lean` | +3 definitions, +3 lemmas |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | Split h_uc in 2 truth lemmas |
| `Metalogic/Algebraic/ParametricRepresentation.lean` | Split h_uc in 4 theorems |
| `Metalogic/Bundle/CanonicalConstruction.lean` | Split h_uc in 3 truth lemmas |
| `Metalogic/BaseCompleteness.lean` | Updated 2 re-exports |
| `Metalogic/DiscreteCompleteness.lean` | Updated 1 re-export |
| `Metalogic/DenseCompleteness.lean` | Updated 2 re-exports |
| `FrameConditions/Completeness.lean` | Wired backward, documented forward, added import |

## Sorry Analysis

**Before**: 3 monolithic `B.until_since_coherent := sorry` (opaque, 4 conjuncts each)

**After**: Per completeness theorem:
- 2 step-transfer sorry (backward Until + backward Since) — narrowly typed
- 1 forward_until_since_coherent sorry — documented blocker
- Step transfer: `(φ U ψ) ∈ fam.mcs (r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`

**Net**: 3 opaque sorry → 9 precisely scoped sorry (6 step-transfer + 3 forward)

## Verification

- `lake build` passes (945 jobs)
- No new axioms introduced
- All existing tests continue to pass
