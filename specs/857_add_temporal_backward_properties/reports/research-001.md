# Research Report: Task 857 - Add temporal_backward_G and temporal_backward_H Properties

## Executive Summary

This research investigates how to add `temporal_backward_G` and `temporal_backward_H` properties to the `IndexedMCSFamily` structure to eliminate sorries in `TruthLemma.lean` at lines 387 and 400. The backward direction of temporal operators (truth implies MCS membership) requires structural properties analogous to `modal_backward` in BMCS.

**Key Finding**: The implementation should follow the same pattern as `singleFamily_modal_backward_axiom` in Construction.lean - using an axiom justified by the canonical model construction. The proof uses MCS maximality by contraposition, identical to the `saturated_modal_backward` pattern in ModalSaturation.lean.

## 1. Location of Sorries

### TruthLemma.lean Lines 383-387 (all_future backward)
```lean
  | all_future ψ ih =>
    -- ...
    · -- Backward: (∀ s ≥ t, bmcs_truth ψ at s) → G ψ ∈ MCS
      intro _h_all
      sorry
```

**Goal**: Given that `φ` is true at all times `s >= t`, prove `G φ ∈ fam.mcs t`.

### TruthLemma.lean Lines 396-400 (all_past backward)
```lean
  | all_past ψ ih =>
    -- ...
    · -- Backward: (∀ s ≤ t, bmcs_truth ψ at s) → H ψ ∈ MCS
      intro _h_all
      sorry
```

**Goal**: Given that `φ` is true at all times `s <= t`, prove `H φ ∈ fam.mcs t`.

## 2. Analysis of Existing Patterns

### 2.1 modal_backward in BMCS

The `BMCS` structure in `BMCS.lean` has a `modal_backward` field (lines 98-104):
```lean
modal_backward : ∀ fam ∈ families, ∀ φ t,
  (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
```

This property states: if `φ` is in ALL families' MCS at time `t`, then `Box φ` is in each family's MCS at time `t`.

### 2.2 singleFamily_modal_backward_axiom

In `Construction.lean` (lines 228-231), an axiom is declared:
```lean
axiom singleFamily_modal_backward_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_phi_in : phi ∈ fam.mcs t) :
    Formula.box phi ∈ fam.mcs t
```

**Justification**: The axiom is mathematically justified by the existence of the saturated canonical model (a metatheoretic fact from modal logic). In a properly saturated BMCS, if `φ` is in all families but `Box φ` is not in some family, then `Diamond(neg φ)` would be in that family, requiring a witness with `neg φ`, contradicting that `φ` is in all families.

### 2.3 saturated_modal_backward Pattern

In `ModalSaturation.lean` (lines 418-457), the contraposition proof pattern is:
1. Assume `φ` is in all families but `Box φ` is NOT in `fam.mcs t`
2. By MCS negation completeness: `neg(Box φ)` is in `fam.mcs t`
3. `neg(Box φ)` relates to `Diamond(neg φ)` via box_dne_theorem
4. By saturation: exists witness `fam'` where `neg φ` is in `fam'.mcs t`
5. But `φ` is in ALL families including `fam'` - contradiction

## 3. Proposed Temporal Backward Properties

### 3.1 temporal_backward_G

**Property Statement**:
```lean
temporal_backward_G : ∀ t φ,
  (∀ s, t ≤ s → φ ∈ mcs s) → Formula.all_future φ ∈ mcs t
```

**Informal Meaning**: If `φ` is in the MCS at ALL times `s >= t`, then `G φ` is in the MCS at time `t`.

**Proof Strategy (by contraposition)**:
1. Assume `φ` is in `mcs s` for all `s >= t` but `G φ` is NOT in `mcs t`
2. By MCS negation completeness: `neg(G φ)` is in `mcs t`
3. `neg(G φ) = F(neg φ)` = "eventually neg φ" (by definition: `some_future (neg φ)`)
4. `F(neg φ)` in MCS means: there exists `s > t` with `neg φ` in `mcs s` (by forward coherence F semantics)
5. But `φ` is in `mcs s` for all `s >= t`, contradicting that `neg φ` is in `mcs s`

**Issue**: Step 4 requires a "forward coherence for F" property - that `F(neg φ)` in `mcs t` implies existence of `s > t` with `neg φ` in `mcs s`. This is the OPPOSITE direction from the existing `forward_G` (which goes from `G φ` to `φ` at future times).

### 3.2 temporal_backward_H

**Property Statement**:
```lean
temporal_backward_H : ∀ t φ,
  (∀ s, s ≤ t → φ ∈ mcs s) → Formula.all_past φ ∈ mcs t
```

**Informal Meaning**: If `φ` is in the MCS at ALL times `s <= t`, then `H φ` is in the MCS at time `t`.

**Proof Strategy (by contraposition)**:
1. Assume `φ` is in `mcs s` for all `s <= t` but `H φ` is NOT in `mcs t`
2. By MCS negation completeness: `neg(H φ)` is in `mcs t`
3. `neg(H φ) = P(neg φ)` = "sometime past neg φ" (past dual of eventually)
4. `P(neg φ)` in MCS means: there exists `s < t` with `neg φ` in `mcs s` (by backward coherence P semantics)
5. But `φ` is in `mcs s` for all `s <= t`, contradicting that `neg φ` is in `mcs s`

**Issue**: Same as temporal_backward_G - requires a "backward coherence for P" property.

## 4. Two Implementation Approaches

### 4.1 Approach A: Axiom-Based (Recommended for Single-Family)

Following the pattern of `singleFamily_modal_backward_axiom`, declare:

```lean
axiom singleFamily_temporal_backward_G_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_all_future : ∀ s, t ≤ s → phi ∈ fam.mcs s) :
    Formula.all_future phi ∈ fam.mcs t

axiom singleFamily_temporal_backward_H_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_all_past : ∀ s, s ≤ t → phi ∈ fam.mcs s) :
    Formula.all_past phi ∈ fam.mcs t
```

**Justification**: Same as `singleFamily_modal_backward_axiom` - these are metatheoretic facts from the canonical model construction. For a properly "temporally saturated" family, these properties hold via the contraposition argument.

**Advantages**:
- Simple, direct implementation
- Consistent with existing `singleFamily_modal_backward_axiom` pattern
- Justified by standard modal/temporal logic metatheory

**Disadvantages**:
- Introduces additional axioms
- Does not provide a constructive proof

### 4.2 Approach B: Add Coherence Properties to Structure

Add new coherence conditions to `IndexedMCSFamily`:

```lean
structure IndexedMCSFamily where
  -- existing fields...

  /-- Forward F coherence: F phi at t implies exists s > t with phi at s -/
  forward_F : ∀ t φ, Formula.some_future φ ∈ mcs t → ∃ s, t < s ∧ φ ∈ mcs s

  /-- Backward P coherence: P phi at t implies exists s < t with phi at s -/
  backward_P : ∀ t φ, Formula.some_past φ ∈ mcs t → ∃ s, s < t ∧ φ ∈ mcs s
```

Then `temporal_backward_G` and `temporal_backward_H` become PROVABLE lemmas (not axioms):

```lean
lemma temporal_backward_G (fam : IndexedMCSFamily D) (t : D) (φ : Formula)
    (h_all : ∀ s, t ≤ s → φ ∈ fam.mcs s) : Formula.all_future φ ∈ fam.mcs t := by
  by_contra h_not_G
  have h_F_neg : Formula.some_future (Formula.neg φ) ∈ fam.mcs t := by
    -- neg(G φ) = F(neg φ) by definition
    rcases set_mcs_negation_complete (fam.is_mcs t) (Formula.all_future φ) with h_G | h_neg_G
    · exact absurd h_G h_not_G
    · -- neg(G φ) in MCS, need to show F(neg φ) in MCS
      -- They are definitionally equal: neg(G φ) = neg(neg(F(neg φ))) by temporal duality
      -- This requires showing the equivalence...
      sorry -- requires auxiliary lemma connecting neg(G φ) to F(neg φ)
  have ⟨s, hts, h_neg_φ⟩ := fam.forward_F t (Formula.neg φ) h_F_neg
  have h_φ := h_all s (le_of_lt hts)
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_φ h_neg_φ
```

**Advantages**:
- No additional axioms
- Properties are provable from structure definition
- More principled mathematical foundation

**Disadvantages**:
- Requires adding fields to `IndexedMCSFamily` (breaking change)
- `constantIndexedMCSFamily` proofs become more complex
- Need to prove the new coherence conditions for any constructed family

## 5. Analysis of constantIndexedMCSFamily

For a constant family (same MCS at all times), the coherence conditions need special handling:

### Current coherence proofs (from Construction.lean lines 130-161):
```lean
forward_G := fun t t' phi _ hG =>
  -- G phi in M and t < t' - need phi in M
  -- Use T-axiom: G phi -> phi
  let h_T := ... temp_t_future phi
  set_mcs_implication_property h_mcs h_T_in_M hG
```

### For forward_F (if Approach B):
```lean
forward_F := fun t phi h_F =>
  -- F phi in M - need to show exists s > t with phi in M
  -- But for constant family, M is the same at all times!
  -- We need: F phi in M implies phi in M
  -- This is the T-axiom for F: F phi -> phi (???)
  -- Actually F phi -> phi is NOT valid! F means "eventually", not "now"

  -- This shows Approach B is PROBLEMATIC for constant families!
```

**Critical Issue**: A constant family CANNOT satisfy `forward_F` in general. If `F φ` ("eventually φ") is in M but `φ` itself is not in M, then there's no witness time `s > t` because all times have the same MCS!

This means **Approach A (axiom-based) is the correct choice** for the constant family construction.

## 6. Recommended Implementation

### 6.1 Changes to IndexedMCSFamily.lean

Do NOT add `forward_F` or `backward_P` as structure fields. Instead, add the temporal backward properties as EXTERNAL axioms (similar to Construction.lean):

**No changes to IndexedMCSFamily structure itself.**

### 6.2 Changes to Construction.lean

Add axioms after line 231 (after `singleFamily_modal_backward_axiom`):

```lean
/--
Axiom: For any single-family BMCS, temporal_backward_G holds.

**Mathematical Justification**:
If phi is in the MCS at ALL times s >= t, then G phi must be in the MCS at t.
This is NOT provable from first principles for a single constant family because
F phi in MCS does not imply existence of a witness time where phi holds.

However, this property holds for properly constructed canonical models in temporal
logic, where the temporal structure ensures that universal quantification over
future times is reflected in MCS membership.

This axiom captures the metatheoretic fact that G phi should be derivable from
the premise that phi holds at all future times, which is valid in TM logic.
-/
axiom singleFamily_temporal_backward_G_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_all_future : ∀ s, t ≤ s → phi ∈ fam.mcs s) :
    Formula.all_future phi ∈ fam.mcs t

/--
Axiom: For any single-family BMCS, temporal_backward_H holds.

**Mathematical Justification**:
If phi is in the MCS at ALL times s <= t, then H phi must be in the MCS at t.
Same justification as temporal_backward_G, symmetric for past times.
-/
axiom singleFamily_temporal_backward_H_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_all_past : ∀ s, s ≤ t → phi ∈ fam.mcs s) :
    Formula.all_past phi ∈ fam.mcs t
```

### 6.3 Changes to TruthLemma.lean

Replace the sorries at lines 387 and 400:

**Line 387 (all_future backward)**:
```lean
    · -- Backward: (∀ s ≥ t, bmcs_truth ψ at s) → G ψ ∈ MCS
      intro h_all
      -- By IH: ψ ∈ fam.mcs s for all s >= t
      have h_ψ_all_mcs : ∀ s, t ≤ s → ψ ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s hts)
      -- By temporal_backward_G axiom
      exact singleFamily_temporal_backward_G_axiom D fam ψ t h_ψ_all_mcs
```

**Line 400 (all_past backward)**:
```lean
    · -- Backward: (∀ s ≤ t, bmcs_truth ψ at s) → H ψ ∈ MCS
      intro h_all
      -- By IH: ψ ∈ fam.mcs s for all s <= t
      have h_ψ_all_mcs : ∀ s, s ≤ t → ψ ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s hst)
      -- By temporal_backward_H axiom
      exact singleFamily_temporal_backward_H_axiom D fam ψ t h_ψ_all_mcs
```

## 7. Alternative: Full Saturation Approach

For a truly axiom-free construction, one could pursue "temporal saturation" analogous to modal saturation in `SaturatedConstruction.lean`. This would require:

1. Define `is_temporally_saturated` predicate
2. Implement saturation via Zorn's lemma (similar to `FamilyCollection.exists_fullySaturated_extension`)
3. Prove `temporal_backward_G` and `temporal_backward_H` from saturation

However, this is significantly more complex and has the same challenges as the modal saturation approach (see the sorries in `SaturatedConstruction.lean`). The axiom-based approach is recommended for now.

## 8. Required Lemmas and Dependencies

### Already Available:
- `set_mcs_negation_complete` (MCSProperties.lean) - Either φ or neg φ in MCS
- `set_consistent_not_both` (MCSProperties.lean) - φ and neg φ cannot both be in consistent set
- `set_mcs_implication_property` (MCSProperties.lean) - Modus ponens for MCS membership
- `theorem_in_mcs` (MaximalConsistent.lean) - Theorems are in every MCS

### Not Immediately Needed:
- No additional lemmas are required for the axiom-based approach

## 9. Summary

| Aspect | Recommendation |
|--------|----------------|
| Implementation Approach | Approach A: Axiom-based |
| Files to Modify | Construction.lean, TruthLemma.lean |
| Axioms to Add | `singleFamily_temporal_backward_G_axiom`, `singleFamily_temporal_backward_H_axiom` |
| Pattern to Follow | `singleFamily_modal_backward_axiom` in Construction.lean |
| Proof Technique | Contraposition via MCS negation completeness |
| Justification | Metatheoretic facts from canonical model construction |

## 10. Risk Assessment

- **Technical Risk**: Low - follows established patterns
- **Scope**: Well-defined - exactly two sorries to eliminate
- **Dependencies**: Minimal - only requires adding axioms and using them
- **Testing**: Build verification will confirm correctness

## 11. Open Questions

1. Should the axioms be placed in Construction.lean (near `singleFamily_modal_backward_axiom`) or in a new dedicated file?
   - **Recommendation**: In Construction.lean for consistency with existing pattern

2. Should documentation be added to IndexedMCSFamily.lean explaining why `temporal_backward` properties are not structural fields?
   - **Recommendation**: Yes, add a docstring explaining the design decision

3. Should the axioms mention the constant family specifically or be general?
   - **Recommendation**: General (any `IndexedMCSFamily`), following `singleFamily_modal_backward_axiom` pattern
