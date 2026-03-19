# Implementation Summary: Task #991 (Partial)

**Task**: temporal_algebraic_representation
**Date**: 2026-03-18
**Status**: PARTIAL - Phases 1-2 completed, Phase 3 partial, Phases 4-10 not started
**Session**: sess_1773851988_e7ba48

## Overview

This task refactors the ProofChecker codebase from reflexive temporal semantics (<=, >=) to strict/irreflexive temporal semantics (<, >) for the temporal operators G (all_future) and H (all_past). This fundamental change simplifies the canonical model construction by making irreflexivity definitional, eliminates the need for the Gabbay IRR proof (~1200 lines), and enables parametric representation theorems for distinct frame classes.

## Completed Work

### Phase 1: Semantic Core Change [COMPLETED]

**Files Modified:**
- `Theories/Bimodal/Semantics/Truth.lean`

**Changes:**
- Changed `truth_at` definition:
  - `all_past`: `s <= t` changed to `s < t`
  - `all_future`: `t <= s` changed to `t < s`
- Updated docstrings to say "strict" instead of "reflexive"
- Updated `past_iff` and `future_iff` lemmas
- Updated `time_shift_preserves_truth` proof (changed `le` to `lt` variants)
- All variable names updated from `h_le` to `h_lt` for clarity

**Verification:** Truth.lean builds successfully with strict semantics.

### Phase 2: Axiom System Refactoring [COMPLETED]

**Files Modified:**
- `Theories/Bimodal/ProofSystem/Axioms.lean`

**Changes:**
- Deleted `temp_t_future` constructor (Gφ → φ)
- Deleted `temp_t_past` constructor (Hφ → φ)
- Reformulated `density` axiom:
  - Old: `Fφ → FFφ` (existential form)
  - New: `GGφ → Gφ` (Sahlqvist universal form)
- Reformulated `seriality_future` axiom:
  - Old: `F(¬⊥)` (no parameter)
  - New: `Gφ → Fφ` (with parameter, Sahlqvist form)
- Reformulated `seriality_past` axiom:
  - Old: `P(¬⊥)` (no parameter)
  - New: `Hφ → Pφ` (with parameter, Sahlqvist form)
- Updated `frameClass` function to remove temp_t cases
- Updated `isBase` function for new seriality signatures
- Updated module docstrings (21 axioms → 19 axioms, 17 base → 15 base)

**Verification:** Axioms.lean builds successfully.

### Phase 3: Soundness Proof Updates [PARTIAL]

**Files Modified:**
- `Theories/Bimodal/Metalogic/Soundness.lean`

**Changes:**
- Deleted `temp_t_future_valid` theorem
- Deleted `temp_t_past_valid` theorem
- Updated `temp_4_valid`: Changed `le_trans` to `lt_trans`
- Updated `temp_a_valid`: Proof works with strict semantics (t serves as witness for r < s)
- Updated `temp_l_valid`: Uses trichotomy for r vs t instead of le_or_gt
- Updated `temp_linearity_valid`: Changed all `<=` to `<` in proof
- Rewrote `density_valid`: Now uses `DenselyOrdered.dense` for genuine density proof
- Rewrote `seriality_future_valid`: Uses `NoMaxOrder.exists_gt`
- Rewrote `seriality_past_valid`: Uses `NoMinOrder.exists_lt` (has sorry - needs frame condition)
- Updated `discreteness_forward_valid`: Partial update (has sorry for discrete case)
- Updated `axiom_base_valid`: Removed temp_t cases
- Updated `axiom_valid_dense`: Removed temp_t cases, added seriality handling
- Updated `axiom_valid_discrete`: Removed temp_t cases, uses Order.NoMaxOrder.of_succ_lt
- Updated main `soundness` theorem: Removed temp_t cases, added sorries for extension axioms

**Remaining Work:**
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` needs substantial updates:
  - Multiple proofs use `<=` that need to be changed to `<`
  - `temp_t_future` and `temp_t_past` case matches need removal
  - Swap validity proofs need updating for new axiom signatures

**Verification:** Soundness.lean does not yet build due to SoundnessLemmas.lean errors.

## Phases Not Started

- Phase 4: Canonical Irreflexivity Simplification
- Phase 5: Canonical Truth Lemma Simplification
- Phase 6: Staged Construction Cleanup
- Phase 7: Algebraic and Parametric Updates
- Phase 8: Derived Theorems and Perpetuity
- Phase 9: Decidability and Automation
- Phase 10: Final Cleanup and Verification

## Blockers

The primary blocker is the cascading nature of the semantic change:
1. Truth.lean change propagates to all files that use temporal quantification
2. Axiom removal requires updating all case matches in the codebase
3. SoundnessLemmas.lean is a critical dependency that must be fixed before Soundness.lean can build

## Sorries Introduced

| File | Location | Reason |
|------|----------|--------|
| Soundness.lean | seriality_past_valid | Needs NoMinOrder (valid_discrete only provides SuccOrder/PredOrder) |
| Soundness.lean | discreteness_forward_valid | Discrete case needs SuccOrder structure |
| Soundness.lean | soundness (density case) | Needs DenselyOrdered D |
| Soundness.lean | soundness (discreteness case) | Needs SuccOrder D |
| Soundness.lean | soundness (seriality cases) | Need NoMaxOrder/NoMinOrder D |
| Soundness.lean | axiom_valid_dense (seriality) | Needs Nontrivial → NoMaxOrder derivation |

## Key Design Decisions

1. **Sahlqvist Forms**: Used Sahlqvist universal forms for density (`GGp -> Gp`) and seriality (`Gp -> Fp`, `Hp -> Pp`) to ensure automatic canonicity.

2. **Frame Conditions**: The soundness proofs now properly require the appropriate frame conditions:
   - Density requires `DenselyOrdered D`
   - Seriality future requires `NoMaxOrder D`
   - Seriality past requires `NoMinOrder D`
   - Discreteness requires `SuccOrder D` and `PredOrder D`

3. **Trichotomy Usage**: The temp_l proof now uses full trichotomy (`lt_trichotomy`) since strict semantics doesn't include the present in temporal quantification.

## Next Steps

1. Fix SoundnessLemmas.lean (highest priority - blocks all downstream work)
2. Continue through Phases 4-10 in order
3. Run `lake build` to verify complete project compilation
4. Grep for remaining `temp_t_future`/`temp_t_past` references
5. Verify no sorries remain in production code

## Metrics

- Lines modified: ~500 (estimated)
- Lines to be deleted (IRR proof): ~1200 (not yet done)
- Axioms removed: 2 (temp_t_future, temp_t_past)
- Axioms reformulated: 3 (density, seriality_future, seriality_past)
