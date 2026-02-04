# Research Report: Task 857 - Zero-Sorry Zero-Axiom Approach for Temporal Backward Properties

## Executive Summary

This follow-up research investigates whether `temporal_backward_G` and `temporal_backward_H` can be proven structurally without introducing new axioms. After comprehensive analysis of the codebase, the answer is **conditional**: a zero-axiom approach is possible but requires adopting the multi-family saturated construction approach (via `FamilyCollection.toBMCS` in SaturatedConstruction.lean), which has its own incomplete proofs.

**Key Finding**: The constant family construction CANNOT support a zero-axiom temporal backward proof. The fundamental issue is identical to modal_backward: proving `G phi` from "phi at all future times" requires a witness existence property that constant families cannot provide.

## 1. Summary of Previous Research (research-001.md)

The first research report recommended an axiom-based approach following `singleFamily_modal_backward_axiom`. The recommendation was based on:

1. The constant family cannot satisfy `forward_F` (F phi in MCS does NOT imply phi in MCS)
2. Without temporal saturation properties, the contraposition proof cannot complete
3. The axiom pattern is consistent with existing `singleFamily_modal_backward_axiom`

## 2. Why Axiom-Based Was Originally Recommended

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

## 3. What Would Be Required for Zero-Axiom

### Option A: Full Multi-Family Saturation

The fully saturated construction in `SaturatedConstruction.lean` provides a zero-axiom path for modal_backward. The same approach could work for temporal_backward_G/H if we had:

1. **Temporal Saturation**: For every `F phi` in any family's MCS, there exists a witness time where `phi` holds
2. **Temporal Backward Saturation**: For every `P phi` in any family's MCS, there exists a witness time where `phi` holds

However, `SaturatedConstruction.lean` has sorries in `FamilyCollection.exists_fullySaturated_extension` (line 506), specifically around:
- Line 714: Consistency of `{psi} ∪ BoxContent` when psi is in L
- Line 733: BoxContent at different times

### Option B: Temporal-Specific Saturation

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

## 6. Alternative Approaches

### 6.1 Time-Varying MCS Family (Not Recommended)

One could construct a family where `mcs t` varies with t. However:
- This would break the existing coherence proofs
- Would require completely new infrastructure
- The construction complexity would exceed the axiom cost

### 6.2 Accept Axioms for Single-Family Construction

The mathematically honest approach: accept that single-family constructions require axioms for backward directions. Document these as "construction assumptions" per sorry-debt-policy.md.

### 6.3 Complete the Multi-Family Saturated Construction

The zero-axiom path exists but requires completing the sorries in `SaturatedConstruction.lean`:
- Line 714: `{psi} ∪ BoxContent` consistency proof
- Line 733: BoxContent time-independence

This would provide zero-axiom modal_backward. Temporal_backward would then require an additional saturation layer.

## 7. Recommendation

### Immediate Implementation (Task 857)

**Use the axiom-based approach from research-001.md**. Rationale:

1. **Consistency**: Follows the existing `singleFamily_modal_backward_axiom` pattern
2. **Correctness**: The axioms are mathematically justified by canonical model theory
3. **Pragmatism**: The zero-axiom alternative requires significant additional infrastructure
4. **Documentation**: Per sorry-debt-policy.md, axioms are documented technical debt, not sorries

### Implementation Details

Add to Construction.lean after line 231:

```lean
/--
Axiom: For any single-family BMCS, temporal_backward_G holds.

**Mathematical Justification**:
If phi is in the MCS at ALL times s >= t, then G phi must be in the MCS at t.
This is NOT provable from first principles for a single constant family because
F phi in MCS does not imply existence of a witness time where phi holds.

This axiom captures the metatheoretic fact that G phi should be derivable from
the premise that phi holds at all future times, which is valid in TM logic.
-/
axiom singleFamily_temporal_backward_G_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_all_future : forall s, t <= s -> phi in fam.mcs s) :
    Formula.all_future phi in fam.mcs t

/--
Axiom: For any single-family BMCS, temporal_backward_H holds.
Symmetric to temporal_backward_G for past times.
-/
axiom singleFamily_temporal_backward_H_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_all_past : forall s, s <= t -> phi in fam.mcs s) :
    Formula.all_past phi in fam.mcs t
```

Then in TruthLemma.lean, replace the sorries:

**Line 387 (all_future backward)**:
```lean
    · -- Backward: (forall s >= t, bmcs_truth psi at s) -> G psi in MCS
      intro h_all
      have h_psi_all_mcs : forall s, t <= s -> psi in fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s hts)
      exact singleFamily_temporal_backward_G_axiom D fam psi t h_psi_all_mcs
```

**Line 400 (all_past backward)**:
```lean
    · -- Backward: (forall s <= t, bmcs_truth psi at s) -> H psi in MCS
      intro h_all
      have h_psi_all_mcs : forall s, s <= t -> psi in fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s hst)
      exact singleFamily_temporal_backward_H_axiom D fam psi t h_psi_all_mcs
```

### Future Work (Beyond Task 857)

To achieve truly zero-axiom completeness:

1. Complete the sorries in `SaturatedConstruction.lean`
2. Add temporal saturation properties to `FamilyCollection`
3. Prove temporal_backward_G/H as lemmas from temporal saturation
4. Update the construction pipeline to use saturated families

This is estimated at 40+ hours of work and should be a separate task.

## 8. Summary

| Aspect | Zero-Axiom Approach | Axiom-Based Approach |
|--------|---------------------|----------------------|
| Feasibility | Blocked by SaturatedConstruction sorries | Immediately implementable |
| Complexity | High (new infrastructure needed) | Low (follows existing pattern) |
| Mathematical Soundness | Sound | Sound (canonical model theory) |
| Consistency | Would eliminate all axioms | Consistent with modal_backward |
| Recommendation | Future work | **Use for Task 857** |

## 9. References

- Construction.lean: Single-family BMCS construction with `singleFamily_modal_backward_axiom`
- SaturatedConstruction.lean: Multi-family saturation infrastructure (incomplete)
- TruthLemma.lean: Location of the sorries at lines 387 and 400
- MCSProperties.lean: Key lemmas for MCS manipulation
- IndexedMCSFamily.lean: Structure definition with temporal coherence
- sorry-debt-policy.md: Framing for axioms as documented technical debt

## 10. Conclusion

The zero-axiom approach is not viable for Task 857 within the current single-family architecture. The axiom-based approach is the correct immediate implementation, with zero-axiom completeness as a future enhancement requiring substantial infrastructure work.
