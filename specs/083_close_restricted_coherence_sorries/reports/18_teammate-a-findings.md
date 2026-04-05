# Teammate A Findings: Complete Sorry Audit and Completeness Pipeline State

## Key Findings

1. **Total actual sorry count**: 76 sorry instances across the codebase (excluding comments mentioning "sorry")
2. **DeterministicChain**: Truly zero-sorry (confirmed via grep)
3. **DeterministicFMCS**: 6 sorries -- 2 in forward_F/backward_P, 4 in until/since coherence
4. **completeness_over_Int**: Claims to be "sorry-free" but depends on `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` which both have sorry, AND the `restricted_shifted_truth_lemma` has sorry in Until/Since cases
5. **No custom `axiom` declarations** anywhere in the codebase -- all sorry is via `sorry` keyword
6. **Boneyard** is not imported by any active code

## Complete Sorry Inventory

### CRITICAL PATH: Blocking completeness_over_Int

| File | Line | Context | Blocks Completeness? |
|------|------|---------|---------------------|
| `Metalogic/Algebraic/DovetailedChain.lean` | 621 | `forward_dovetailed_until_persists` -- X-content propagation for Until | YES (transitive) |
| `Metalogic/Algebraic/DovetailedChain.lean` | 989 | `backward_dovetailed_since_persists` -- Y-content propagation for Since | YES (transitive) |
| `Metalogic/Algebraic/DovetailedChain.lean` | 1085 | `until_backward_to_zero` -- Until propagation across chain boundary | YES (transitive) |
| `Metalogic/Algebraic/DovetailedChain.lean` | 1098 | `since_forward_to_zero` -- Since propagation across chain boundary | YES (transitive) |
| `Metalogic/Algebraic/DovetailedChain.lean` | 1258 | `DovetailedFMCS_forward_F` -- family-level F witness | **YES (direct)** |
| `Metalogic/Algebraic/DovetailedChain.lean` | 1266 | `DovetailedFMCS_backward_P` -- family-level P witness | **YES (direct)** |
| `Metalogic/Bundle/CanonicalConstruction.lean` | 631 | `canonical_truth_lemma` untl case | YES (used by shifted_truth_lemma) |
| `Metalogic/Bundle/CanonicalConstruction.lean` | 632 | `canonical_truth_lemma` snce case | YES (used by shifted_truth_lemma) |
| `Metalogic/Bundle/CanonicalConstruction.lean` | 781 | `shifted_truth_lemma` untl case | NO (not used by completeness_over_Int) |
| `Metalogic/Bundle/CanonicalConstruction.lean` | 782 | `shifted_truth_lemma` snce case | NO (not used by completeness_over_Int) |
| `Metalogic/Bundle/CanonicalConstruction.lean` | 940 | `restricted_shifted_truth_lemma` untl case | **YES (direct)** |
| `Metalogic/Bundle/CanonicalConstruction.lean` | 943 | `restricted_shifted_truth_lemma` snce case | **YES (direct)** |

### ALTERNATE PATH: DeterministicFMCS (not currently used by completeness_over_Int)

| File | Line | Context | Blocks Completeness? |
|------|------|---------|---------------------|
| `Metalogic/Algebraic/DeterministicFMCS.lean` | 60 | `deterministic_forward_F` | No (alt path) |
| `Metalogic/Algebraic/DeterministicFMCS.lean` | 66 | `deterministic_backward_P` | No (alt path) |
| `Metalogic/Algebraic/DeterministicFMCS.lean` | 193 | `usc` forward Until | No (alt path) |
| `Metalogic/Algebraic/DeterministicFMCS.lean` | 195 | `usc` backward Until | No (alt path) |
| `Metalogic/Algebraic/DeterministicFMCS.lean` | 197 | `usc` forward Since | No (alt path) |
| `Metalogic/Algebraic/DeterministicFMCS.lean` | 199 | `usc` backward Since | No (alt path) |

### SOUNDNESS (separate from completeness)

| File | Line | Context | Blocks Completeness? |
|------|------|---------|---------------------|
| `Metalogic/Soundness.lean` | 1157-1181 | 25 axiom cases in `soundness_general_task` | No |
| `Metalogic/Soundness.lean` | 1205 | `soundness_discrete_task` frame-class restriction | No |
| `Metalogic/Soundness.lean` | 1447 | `soundness_general_discrete` temporal_duality case | No |
| `Metalogic/Soundness.lean` | 1504 | Another soundness case | No |

### BUNDLE PATH (deprecated/alternate infrastructure)

| File | Line | Context | Blocks Completeness? |
|------|------|---------|---------------------|
| `Metalogic/Bundle/SuccRelation.lean` | 557 | `until_persists_through_succ` | No (not imported by completeness) |
| `Metalogic/Bundle/SimplifiedChain.lean` | 195 | G-lift for restricted seed | No |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 1241 | T-axiom stub (archived) | No |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 2149 | G-wrapping multi-BRS | No |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 3778 | T-axiom stub (archived) | No |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 4045 | T-axiom stub | No |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 4188 | T-axiom stub | No |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 5926 | Outer theorem via sorry | No |
| `Metalogic/Bundle/SuccChainTruth.lean` | 311 | Box backward sorry | No |
| `Metalogic/Bundle/SuccExistence.lean` | 476 | Forward temporal witness seed | No |
| `Metalogic/Bundle/SuccExistence.lean` | 784 | Forward temporal witness seed | No |
| `Metalogic/Bundle/SuccExistence.lean` | 860 | Backward temporal witness seed | No |
| `Metalogic/Algebraic/UltrafilterChain.lean` | 3917 | `succ_chain_restricted_forward_F` | No |
| `Metalogic/Algebraic/UltrafilterChain.lean` | 3927 | `succ_chain_restricted_backward_P` | No |
| `Metalogic/Algebraic/RestrictedTruthLemma.lean` | 121 | G-step (dead code) | No |
| `Metalogic/Algebraic/RestrictedTruthLemma.lean` | 168 | H-step (dead code) | No |
| `FrameConditions/Completeness.lean` | 135 | `dense_completeness_fc` | No (separate theorem) |
| `FrameConditions/Completeness.lean` | 238 | `bfmcs_from_mcs_temporally_coherent` | No (old bundle path) |

### EXAMPLES / TESTS / BONEYARD (not on any critical path)

| File | Line(s) | Count | Notes |
|------|---------|-------|-------|
| `Examples/ModalProofStrategies.lean` | 204, 252, 295, 325, 430 | 5 | Pedagogical examples |
| `Examples/ModalProofs.lean` | 168, 183, 196, 249, 256 | 5 | Pedagogical examples |
| `Examples/TemporalProofs.lean` | 180, 194 | 2 | Pedagogical examples |
| `Examples/Demo.lean` | 69 | 1 | Demo code |
| `Boneyard/UltrafilterDeadCode/FPreservingSeed.lean` | 917, 923 | 2 | Dead code |
| `Boneyard/TAxiomDependentCode/TruthPreservationArchive.lean` | 30, 49 | 2 | Archived |
| `Boneyard/TAxiomDependentCode/TargetedChainArchive.lean` | 32, 67, 103, 137 | 4 | Archived |
| `Boneyard/TAxiomDependentCode/CanonicalConstructionArchive.lean` | 65, 69 | 2 | Archived |

### OTHER (miscellaneous, not blocking)

| File | Line | Context | Blocks Completeness? |
|------|------|---------|---------------------|
| `Metalogic/Bundle/CanonicalConstruction.lean` | 631, 632 | `canonical_truth_lemma` untl/snce | No (only shifted version used) |
| `Metalogic/Bundle/CanonicalConstruction.lean` | 781, 782 | `shifted_truth_lemma` untl/snce | No (restricted version used) |
| `Theorems/TemporalDerived.lean` | 235 | Mentioned in comment only | No |

## DeterministicChain Status

**ZERO SORRY** -- Confirmed via `grep -n sorry DeterministicChain.lean` returning no matches. The file contains:
- `deterministic_chain` definition (Int-indexed MCS chain via `iterate_x_content`/`iterate_y_content`)
- `deterministic_chain_mcs`: every chain element is MCS (proven)
- `forward_G_int`/`backward_H_int`: G/H coherence (proven)
- Until/Since persistence properties (proven)

All proofs rely on `x_content_mcs`, `y_content_mcs`, and axiom-derived properties from TemporalContent.

## DeterministicFMCS Status

**6 sorries** in 2 categories:
1. **Forward F / Backward P** (lines 60, 66): `deterministic_forward_F` and `deterministic_backward_P` -- the core temporal witness properties. These require proving that F(psi) in the chain at time t implies psi appears at some strictly later time.
2. **Until/Since coherence** (lines 193, 195, 197, 199): 4 cases in `usc` theorem, all dependent on forward_F/backward_P.

The DeterministicFMCS is currently an **alternate path** -- `completeness_over_Int` uses the DovetailedChain path instead.

## completeness_over_Int Dependency Chain

```
completeness_over_Int                    (Completeness.lean:472)
  └─ dovetailed_bundle_validity_implies_provability  (Completeness.lean:430)
       ├─ not_provable_implies_neg_consistent        [sorry-free]
       ├─ neg_consistent_gives_mcs_without_phi       [sorry-free]
       ├─ construct_dovetailed_bfmcs_bundle          [sorry-free structurally]
       ├─ dovetailed_bundle_to_bfmcs                 [sorry-free]
       ├─ dovetailed_bfmcs_restricted_temporally_coherent  (Completeness.lean:401)
       │    ├─ shifted_restricted_forward_F
       │    │    └─ DovetailedFMCS_forward_F         [SORRY - line 1258] <<<
       │    └─ shifted_restricted_backward_P
       │         └─ DovetailedFMCS_backward_P        [SORRY - line 1266] <<<
       ├─ shiftClosedCanonicalOmega_is_shift_closed  [sorry-free]
       └─ restricted_shifted_truth_lemma             (CanonicalConstruction.lean:812)
            ├─ atom, bot, imp, box, all_future, all_past cases [sorry-free]
            ├─ untl case                             [SORRY - line 940] <<<
            └─ snce case                             [SORRY - line 943] <<<
```

**Total blocking sorries for completeness_over_Int: 4**
- `DovetailedFMCS_forward_F` (DovetailedChain.lean:1258)
- `DovetailedFMCS_backward_P` (DovetailedChain.lean:1266)
- `restricted_shifted_truth_lemma` untl case (CanonicalConstruction.lean:940)
- `restricted_shifted_truth_lemma` snce case (CanonicalConstruction.lean:943)

These 4 sorries have deeper dependencies on 4 additional sorries in DovetailedChain:
- `forward_dovetailed_until_persists` (line 621) -- X-content propagation
- `backward_dovetailed_since_persists` (line 989) -- Y-content propagation
- `until_backward_to_zero` (line 1085) -- chain boundary crossing
- `since_forward_to_zero` (line 1098) -- chain boundary crossing

**Root cause**: All blocking sorries trace to the same fundamental issue: **Until/Since persistence through X/Y-content propagation under strict semantics**. The strict temporal semantics (where F means strictly future, not weakly) means the T-axiom `G(phi) -> phi` is not available, making Until/Since propagation through chain steps fundamentally harder.

## Non-blocking Sorries

| Category | Count | Notes |
|----------|-------|-------|
| Boneyard (dead/archived code) | 8 | Not imported by anything |
| Examples/Demo | 13 | Pedagogical, not imported |
| Soundness (separate theorem) | 28 | Does not affect completeness |
| Bundle path (deprecated) | 14 | Alternate infrastructure, not used by completeness_over_Int |
| DeterministicFMCS (alternate path) | 6 | Not used by completeness_over_Int |
| RestrictedTruthLemma dead code | 2 | Explicitly marked dead code |
| CanonicalConstruction non-restricted | 4 | Only restricted version used |
| Dense completeness | 1 | Separate theorem (Int is not dense) |
| Old bundle temporal coherence | 1 | Old path |

**Total non-blocking: 77 minus 4 blocking = ~72 non-blocking** (some counted in multiple categories)

## Confidence Level

**HIGH** -- This audit is based on exhaustive grep across all `.lean` files, tracing every sorry instance, and reading the dependency chain from `completeness_over_Int` through every theorem it calls. The 4 blocking sorries are confirmed by reading the actual code paths. No `axiom` declarations exist that could hide assumptions.

**Key insight**: The codebase documentation in Completeness.lean claims `completeness_over_Int` is "sorry-free via the dovetailed chain construction" (line 470), but this is **incorrect** -- the dovetailed chain still has 2 sorry in `forward_F`/`backward_P`, and the `restricted_shifted_truth_lemma` has 2 sorry in Until/Since cases. The claim appears to be aspirational rather than factual.
