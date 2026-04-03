# Phase 6 Results: Soundness Frame-Class Proofs and Final Polish

## Summary

Phase 6 addresses the 20 frame-class-restricted soundness sorry sites in `Soundness.lean` (19 axiom cases + 1 temporal_duality case in the general `soundness` theorem).

## Key Finding: Architectural Analysis

**All 20 individual axiom validity lemmas were already proven sorry-free** before this phase began. The sorry sites are NOT in the individual lemmas but in the general `soundness` theorem which lacks frame class constraints.

The general `soundness` theorem claims `DerivationTree Gamma phi -> semantic_consequence Gamma phi` for ANY linear order D, but frame-class axioms (density, discreteness, seriality, Until/Since) require specific frame conditions (DenselyOrdered, SuccOrder, PredOrder, etc.). Since no single type can satisfy all conditions simultaneously (dense and discrete are mutually exclusive), a single general soundness theorem cannot close all axiom cases.

## What Was Done

### 1. Semantic Consistency Audit (COMPLETED)

All 20 frame-class axioms verified semantically valid under strict `<` semantics with their respective frame constraints:
- **density**: Valid on DenselyOrdered frames (proven in `density_valid`)
- **discreteness_forward**: Valid on SuccOrder frames (proven in `discreteness_forward_valid`)
- **seriality_future/past**: Valid on NoMaxOrder/NoMinOrder frames (proven in `seriality_future_valid`, `seriality_past_valid`)
- **disc_next/prev**: Valid on SuccOrder/PredOrder frames (proven)
- **until_unfold/intro/induction/linearity**: Valid on discrete frames (all proven)
- **since_unfold/intro/induction/linearity**: Valid on discrete frames (all proven)
- **until_connectedness/since_connectedness**: **VALID** on discrete frames (proven -- initial concern about unsoundness was unfounded)
- **F_until_equiv/P_since_equiv**: Valid on discrete frames (proven)
- **next_implies_some_future**: Valid on discrete frames (proven)

### 2. Created `soundness_discrete_valid` and `soundness_discrete` (NEW)

Added two new theorems to `Soundness.lean`:

- `soundness_discrete_valid`: For discrete-compatible derivations from empty context, proves `valid_discrete phi`. Handles all axiom cases via `axiom_valid_discrete` (sorry-free). One sorry remains for `temporal_duality`.

- `soundness_discrete`: For discrete-compatible derivations from any context, proves semantic consequence on discrete frames. Handles all cases except `temporal_duality` (one sorry).

These are the discrete analogues of the existing `soundness_dense_valid` and `soundness_dense` theorems.

### 3. Updated Module Docstring (COMPLETED)

Updated the `Soundness.lean` module docstring to document the frame-class separation architecture:
- `soundness_dense`: sorry-free for dense-compatible derivations
- `soundness_discrete`: new, sorry only for temporal_duality
- `soundness` (general): architectural limitation, use frame-class-specific versions

### 4. temporal_duality Gap Analysis

The `temporal_duality` sorry in `soundness_discrete` requires `derivable_implies_swap_valid_discrete`, a discrete analogue of the existing `derivable_implies_swap_valid` in `SoundnessLemmas.lean`. This requires:
- `axiom_swap_valid_discrete`: prove each discrete axiom's swap is valid_discrete
- `axiom_locally_valid_discrete`: prove each discrete axiom is locally valid
- `derivable_valid_and_swap_valid_discrete`: combined induction

The proofs are routine (each Until axiom swap is the corresponding Since axiom, etc.) but the code duplication from `SoundnessLemmas.lean` is substantial (~600 lines). An attempted implementation in a new `SoundnessLemmasDiscrete.lean` file encountered compilation issues and was deferred.

## Sorry Count Impact

- **Pre-existing sorries in general `soundness`**: 20 (unchanged, documented as architectural limitation)
- **New sorries in `soundness_discrete_valid`**: 1 (temporal_duality)
- **New sorries in `soundness_discrete`**: 1 (temporal_duality)
- **Net new sorries**: 2 (both for temporal_duality in new theorems)
- **New sorry-free code**: All other cases in `soundness_discrete` are sorry-free

## Files Modified

- `Theories/Bimodal/Metalogic/Soundness.lean`
  - Added `soundness_discrete_valid` theorem
  - Added `soundness_discrete` theorem
  - Updated module docstring

## Verification

- `lake build` succeeds (940 jobs)
- No new axioms introduced (still 3)
- All individual axiom validity lemmas remain sorry-free
- `axiom_valid_discrete` dispatcher remains sorry-free
