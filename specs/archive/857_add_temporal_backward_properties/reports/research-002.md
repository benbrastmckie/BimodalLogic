# Research Report: Task 857 - Zero-Sorry Zero-Axiom Approach for Temporal Backward Properties

## Executive Summary

This follow-up research investigates whether `temporal_backward_G` and `temporal_backward_H` can be proven structurally without introducing new axioms. **Axioms are not an acceptable solution** - the goal is to find a structural proof approach.

**Key Finding**: The constant family construction CANNOT support temporal backward proofs. The fundamental issue is identical to modal_backward: proving `G phi` from "phi at all future times" requires a witness existence property that constant families cannot provide. **We must use a different construction approach** - either complete the multi-family saturated construction or develop temporally-saturated families.

## 1. Summary of Previous Research (research-001.md)

The first research report incorrectly recommended an axiom-based approach following `singleFamily_modal_backward_axiom`. That recommendation was based on:

1. The constant family cannot satisfy `forward_F` (F phi in MCS does NOT imply phi in MCS)
2. Without temporal saturation properties, the contraposition proof cannot complete
3. The axiom pattern is consistent with existing `singleFamily_modal_backward_axiom`

**This recommendation is rejected.** Axioms are never the appropriate strategy - we must find structural proofs.

## 2. Why the Constant Family Construction Cannot Work

### The Constant Family Limitation

In `constantIndexedMCSFamily` (Construction.lean lines 130-161), the same MCS `M` is used at all times. The forward coherence proofs work via T-axiom:

```lean
forward_G := fun t t' phi _ hG =>
  -- G phi in M and t < t' - need phi in M
  -- Use T-axiom: G phi -> phi
  let h_T := ... temp_t_future phi
  set_mcs_implication_property h_mcs h_T_in_M hG
```

However, the BACKWARD direction requires proving:
```
(forall s >= t, phi in mcs s) -> G phi in mcs t
```

For a constant family, this becomes:
```
phi in M -> G phi in M
```

This is NOT derivable because `phi -> G phi` is NOT a valid theorem in temporal logic. The T-axiom gives us `G phi -> phi`, not the converse.

### The Saturation Gap

The proof by contraposition requires:
1. Assume `G phi` NOT in `mcs t`
2. By MCS maximality: `neg(G phi) = F(neg phi)` IS in `mcs t`
3. `F(neg phi)` in MCS means exists `s > t` with `neg phi` in `mcs s`
4. But `phi` is in `mcs s` for all `s >= t`, contradiction

**Step 3 is the gap**: For a constant family, `F(neg phi)` being in MCS does NOT imply there exists a witness time. The MCS is the same at all times, so there's no "different time" to witness the F formula.

## 3. Required Approaches for Structural Proofs

### Approach A: Complete Multi-Family Saturation

The fully saturated construction in `SaturatedConstruction.lean` provides a zero-axiom path for modal_backward. The same approach could work for temporal_backward_G/H if we had:

1. **Temporal Saturation**: For every `F phi` in any family's MCS, there exists a witness time where `phi` holds
2. **Temporal Backward Saturation**: For every `P phi` in any family's MCS, there exists a witness time where `phi` holds

However, `SaturatedConstruction.lean` has sorries in `FamilyCollection.exists_fullySaturated_extension` (line 506), specifically around:
- Line 714: Consistency of `{psi} ∪ BoxContent` when psi is in L
- Line 733: BoxContent at different times

### Approach B: Temporal-Specific Saturation

A simpler approach: define a "temporally saturated" family that specifically supports F/P witnesses:

```lean
structure TemporallySaturatedFamily where
  fam : IndexedMCSFamily D
  /-- F phi at t implies exists s > t with phi at s -/
  forward_F : forall t phi, Formula.some_future phi in fam.mcs t ->
              exists s, t < s ∧ phi in fam.mcs s
  /-- P phi at t implies exists s < t with phi at s -/
  backward_P : forall t phi, Formula.some_past phi in fam.mcs t ->
               exists s, s < t ∧ phi in fam.mcs s
```

With these properties, `temporal_backward_G` and `temporal_backward_H` become provable lemmas:

```lean
lemma temporal_backward_G (fam : TemporallySaturatedFamily) (t : D) (phi : Formula)
    (h_all : forall s, t <= s -> phi in fam.fam.mcs s) :
    Formula.all_future phi in fam.fam.mcs t := by
  by_contra h_not_G
  have h_F_neg : Formula.some_future (Formula.neg phi) in fam.fam.mcs t := by
    rcases set_mcs_negation_complete (fam.fam.is_mcs t) (Formula.all_future phi) with h_G | h_neg_G
    · exact absurd h_G h_not_G
    · -- neg(G phi) = F(neg phi) via temporal duality
      -- This requires: neg(G phi) <-> F(neg phi) is provable
      -- In fact, G phi = neg(F(neg phi)) definitionally in some formulations
      sorry -- requires temporal duality theorem
  have ⟨s, hts, h_neg_phi⟩ := fam.forward_F t (Formula.neg phi) h_F_neg
  have h_phi := h_all s (le_of_lt hts)
  exact set_consistent_not_both (fam.fam.is_mcs s).1 phi h_phi h_neg_phi
```

**Problem**: A constant family CANNOT satisfy `forward_F` because `F phi` being in the constant MCS `M` does NOT guarantee there's a time where `phi` holds. The witness needs to be a DIFFERENT set at a DIFFERENT time.

## 4. Analysis of Existing Multi-Family Constructions

### 4.1 SaturatedConstruction.lean

The `FamilyCollection.toBMCS` (line 277) converts a fully saturated family collection to a BMCS. The key requirement is `isFullySaturated`:

```lean
def FamilyCollection.isFullySaturated {phi : Formula} (C : FamilyCollection D phi) : Prop :=
  forall psi : Formula, forall fam in C.families, forall t : D,
    diamondFormula psi in fam.mcs t -> exists fam' in C.families, psi in fam'.mcs t
```

This handles MODAL saturation (Diamond/Box), not TEMPORAL saturation (F/G, P/H).

### 4.2 WeakCoherentBundle.lean

The `WeakCoherentBundle` approach separates core and witness families but still uses constant families. It doesn't address temporal saturation.

### 4.3 PreCoherentBundle.lean

This module is marked as "MATHEMATICALLY BLOCKED" due to the fundamental box-coherence issue. The same issue would apply to any temporal variant.

### 4.4 CoherentConstruction.lean

Provides infrastructure for coherent bundle construction but relies on axioms for saturation existence.

## 5. The Fundamental Obstacle

The constant family construction is fundamentally incompatible with temporal backward proofs because:

1. **Same MCS at all times**: `fam.mcs t = fam.mcs t' = M` for all t, t'
2. **F/P semantics require witnesses at DIFFERENT times**:
   - `F phi` true at t means phi holds at some t' > t
   - `P phi` true at t means phi holds at some t' < t
3. **Constant families collapse all times**: There's no "different time" - the MCS is M everywhere

This means ANY approach using constant families will require an axiom for temporal_backward, just as it requires `singleFamily_modal_backward_axiom` for modal_backward.

## 6. Structural Proof Strategies

### 6.1 Strategy: Complete Multi-Family Saturated Construction (Recommended)

The correct path requires completing the sorries in `SaturatedConstruction.lean`:
- Line 714: `{psi} ∪ BoxContent` consistency proof
- Line 733: BoxContent time-independence

This would provide zero-axiom modal_backward. Then extend the saturation to cover temporal operators:
- Add temporal saturation properties to `FamilyCollection`
- Prove temporal_backward_G/H as structural theorems

**Estimated effort**: 40-60 hours
**Benefit**: Eliminates ALL axioms from BMCS construction, making it publication-ready

### 6.2 Strategy: Develop Temporally-Saturated Family Type

Create a new family type that guarantees temporal witness properties:

```lean
structure TemporallySaturatedIndexedMCSFamily extends IndexedMCSFamily where
  /-- F phi at t implies exists s > t with phi at s -/
  forward_F : forall t phi, Formula.some_future phi in mcs t ->
              exists s, t < s ∧ phi in mcs s
  /-- P phi at t implies exists s < t with phi at s -/
  backward_P : forall t phi, Formula.some_past phi in mcs t ->
               exists s, s < t ∧ phi in mcs s
```

Then construct such families using Lindenbaum extension at each time point. This requires:
- Proving consistency of witness sets
- Proving coherence between time points
- Proving the resulting structure satisfies temporal saturation

**Estimated effort**: 25-35 hours
**Benefit**: Cleaner separation between modal and temporal saturation

### 6.3 Strategy: Time-Varying MCS Construction

Construct a family where `mcs t` genuinely varies with t, built by:
1. Starting with a base consistent set
2. At each time t, extending to include appropriate G/H formulas
3. Ensuring coherence via forward/backward properties

**Estimated effort**: 30-45 hours
**Challenge**: Requires proving coherence across varying time points

## 7. Recommendation for Task 857

**Task 857 must be blocked pending completion of structural infrastructure.** We cannot implement temporal_backward_G/H properties without one of the following:

### Option 1: Complete Task 856 First (Recommended)

Task 856 ("Implement multi-family saturated BMCS construction") is the correct prerequisite. Once multi-family saturation is complete:

1. The saturated construction eliminates `singleFamily_modal_backward_axiom`
2. We can extend the saturation layer to cover temporal operators
3. Both modal_backward AND temporal_backward become structural theorems

**Action**: Mark Task 857 as blocked by Task 856.

### Option 2: Develop Temporally-Saturated Family Construction

Create a new construction pipeline:

1. Define `TemporallySaturatedIndexedMCSFamily` structure (Section 6.2)
2. Prove construction exists using Lindenbaum lemma at each time
3. Prove temporal_backward_G/H as structural theorems
4. Update TruthLemma.lean to use the new construction

**Estimated effort**: 25-35 hours
**Benefit**: Can proceed independently of Task 856

### Option 3: Wait for Better Understanding

The obstacle may indicate a deeper conceptual issue. Consider:
- Consulting literature on temporal logic completeness proofs
- Checking if the TruthLemma backward directions are actually needed
- Verifying if the sorries are in the dependency chain of main theorems

**Action**: Research whether TruthLemma backward completeness is necessary for the main completeness theorem.

## 8. Summary

| Aspect | Complete Saturation (Task 856) | New Temporally-Saturated Type | Wait for Clarification |
|--------|-------------------------------|------------------------------|----------------------|
| Feasibility | Blocked by SaturatedConstruction sorries | Requires new infrastructure | Requires research |
| Complexity | High (40-60 hours) | Medium (25-35 hours) | Low (4-6 hours research) |
| Mathematical Soundness | Sound | Sound | TBD |
| Axioms | Zero axioms | Zero axioms | Zero axioms |
| Recommendation | **Best long-term solution** | Viable independent path | Check if needed first |

## 9. References

- Construction.lean: Single-family BMCS construction with `singleFamily_modal_backward_axiom` (to be eliminated)
- SaturatedConstruction.lean: Multi-family saturation infrastructure (Task 856)
- TruthLemma.lean: Location of the sorries at lines 387 and 400
- MCSProperties.lean: Key lemmas for MCS manipulation
- IndexedMCSFamily.lean: Structure definition with temporal coherence
- Task 856: Multi-family saturated BMCS construction (prerequisite)

## 10. Conclusion

**Task 857 should be blocked pending structural infrastructure.** The constant family construction cannot support temporal_backward proofs without axioms, and axioms are not an acceptable solution.

**Recommended path**: Complete Task 856 (multi-family saturated construction) first, then extend the saturation layer to cover temporal operators. This eliminates both modal axioms AND temporal axioms, resulting in a fully axiom-free completeness proof suitable for publication.

**Alternative path**: Develop temporally-saturated family construction as independent infrastructure (25-35 hours estimated).

**Do not**: Add axioms to "solve" this problem. The existence of `singleFamily_modal_backward_axiom` is technical debt that should be eliminated, not replicated for temporal operators.
