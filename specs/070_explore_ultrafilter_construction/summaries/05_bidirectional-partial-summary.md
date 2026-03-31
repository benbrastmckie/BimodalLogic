# Implementation Summary: Bidirectional Temporal Witness (Partial)

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Plan**: v4 - Bidirectional Temporal Witness
**Status**: PARTIAL (Phases 0-1 complete, Phase 2 blocked)
**Date**: 2026-03-30
**Session**: sess_1774927396_43b919

## Completed Work

### Phase 0: Archive Dead Code and Update ROADMAP [COMPLETED]

Added archive comments to dead code in UltrafilterChain.lean:
- CoherentZChain section (~7286-7496): Marked as fundamentally broken (asymmetric preservation)
- `f_preserving_seed_consistent` sub-cases A/B (~3363-3375): Marked as mathematically unprovable
- `omega_true_dovetailed_forward_F_resolution` (~7696): Marked as superseded by bidirectional construction

Updated ROADMAP.md:
- Added "Temporal Coherence Resolution (March 2026)" section
- Documented dead ends (CoherentZChain, f_preserving_seed_consistent, bundle-level coherence)
- Documented correct approach (bidirectional temporal witness)
- Updated Class B status to reference resolution

### Phase 1: Define Bidirectional Seed [COMPLETED]

Added new definitions to UltrafilterChain.lean (after line 3685):

```lean
def bidirectional_temporal_box_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ H_theory M ∪ box_theory M

theorem G_theory_subset_bidirectional_seed
theorem H_theory_subset_bidirectional_seed
theorem box_theory_subset_bidirectional_seed
theorem bidirectional_seed_subset_mcs

def bidirectional_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ bidirectional_temporal_box_seed M

theorem phi_in_bidirectional_seed
theorem bidirectional_seed_subset_phi_union_M
```

### Phase 2: Bidirectional Seed Consistency [PARTIAL]

Added theorems (with one sorry):

```lean
theorem G_of_bidirectional_seed (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ bidirectional_temporal_box_seed M, Formula.all_future x ∈ M

theorem bidirectional_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (bidirectional_seed M phi)
```

**Blocking Issue**: The H_theory case in `G_of_bidirectional_seed` requires proving:
- Given `H(a) ∈ M`, show `G(H(a)) ∈ M`

This requires either:
1. Derivation of `H(a) → G(H(a))` from existing TM axioms
2. Identification of a missing axiom for linear temporal logic

## Technical Analysis

### Why G(H(a)) is Needed

The consistency proof uses G-lift: from `L_no_phi ⊢ neg(phi)`, derive `G(neg phi) ∈ M`.

G-lift requires all context elements to be G-liftable:
- G_theory elements: `G(a) → G(G(a))` via temp_4 axiom (proven)
- box_theory elements: `G(f) ∈ M` via G_of_box_theory (proven)
- H_theory elements: `H(a) → G(H(a))` - **NOT YET PROVEN**

### Semantic Justification

In linear tense logic, `H(a) → G(H(a))` is valid because:
- H(a) = "always in the past, a held"
- G(H(a)) = "always in the future, it was always in the past that a held"
- The past is fixed: once H(a) is true, it remains true at all future times

This is the "no branching past" property of linear time.

### Possible Derivation Paths

1. **S5-past approach**: If H is an S5 operator over past times, then `H(a) → Box(H(a))`. Combined with `Box(a) → G(Box(a))` (temp_future) and G distributing over Box-T, we could derive `G(H(a))`.

2. **Perpetuity approach**: The perpetuity axiom P1 gives `Box(a) → G(a) ∧ H(a)`. If we can show `Box(H(a)) ∈ M` when `H(a) ∈ M`, we'd get `G(H(a))`.

3. **Direct axiom**: Linear tense logic may include `H(a) → G(H(a))` as an axiom (the "common past" or "history preservation" axiom).

## Verification Status

| Check | Result |
|-------|--------|
| lake build | Passes |
| Sorry count | 53 total (2 new from bidirectional) |
| Axiom count | 3 (unchanged) |
| New definitions | Compile without error |

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
  - Archive comments added (~lines 3363-3375, 7276-7295, 7667-7686)
  - Bidirectional seed definitions added (~lines 3686-3875)

- `ROADMAP.md`
  - New "Temporal Coherence Resolution" section
  - Updated Class B status

## Next Steps

1. **Research**: Search for `H(a) → G(H(a))` derivation in tense logic literature
2. **Codebase search**: Check if existing axioms can derive this
3. **If derivable**: Complete G_of_bidirectional_seed proof
4. **If not derivable**: Document as a required axiom for linear TM

Once Phase 2 is complete, Phases 3-9 follow naturally using the bidirectional witness.
