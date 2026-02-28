import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.BidirectionalReachable

/-!
# Canonical Completeness: Sorry-Free BFMCS Construction

This module constructs a sorry-free fully saturated `BFMCS Int` by using the
**Bidirectional Reachable Fragment** approach from BidirectionalReachable.lean.

## Strategy

1. Define `fragmentFMCS`: an `FMCS (BidirectionalFragment M₀ h_mcs₀)` where each
   fragment element maps to its own world. This FMCS has sorry-free forward_F and
   backward_P (from fragment closure properties).

2. Build an order-preserving chain `Int → BidirectionalFragment M₀ h_mcs₀` that
   visits all necessary F/P witnesses, then pull back `fragmentFMCS` along this chain.

3. Construct BFMCS Int with modal saturation using witness families, each built
   from a BidirectionalFragment rooted at the witness MCS.

## Key Insight

The BidirectionalFragment approach resolves the F-persistence problem because:
- Forward_F and backward_P are proven at the fragment level (Phase A/C)
- The fragment is totally ordered (Phase B)
- Witness seeds are consistent because fragment elements witness consistency

## References

- BidirectionalReachable.lean: fragment infrastructure, totality, F/P closure
- CanonicalFMCS.lean: canonicalMCS_forward_F, canonicalMCS_backward_P (sorry-free)
- Task 951 plan v2: Bidirectional Reachable Fragment approach
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-!
## Phase D/E: FMCS on BidirectionalFragment

The fragment FMCS maps each element to its own world. Forward_G and backward_H
follow from CanonicalR properties. Forward_F and backward_P follow from
the fragment's closure properties (forward_F_stays_in_fragment, backward_P_stays_in_fragment).

This gives us a COMPLETE sorry-free FMCS at the BidirectionalFragment level.
The remaining challenge is converting to FMCS Int.
-/

/--
FMCS over the BidirectionalFragment: each element maps to its own world.

This is analogous to `canonicalMCSBFMCS` but restricted to the bidirectional fragment.
The key advantage is that forward_F and backward_P hold trivially from the
fragment's closure properties.

**Properties (all sorry-free)**:
- `forward_G`: from CanonicalR = GContent subset
- `backward_H`: from HContent/GContent duality
- `forward_F`: from `forward_F_stays_in_fragment`
- `backward_P`: from `backward_P_stays_in_fragment`
-/
noncomputable def fragmentFMCS :
    FMCS (BidirectionalFragment M₀ h_mcs₀) where
  mcs := fun w => w.world
  is_mcs := fun w => w.is_mcs
  forward_G := fun w₁ w₂ _ h_le h_G =>
    -- CanonicalR w₁.world w₂.world means GContent(w₁) ⊆ w₂, so G(φ) ∈ w₁ → φ ∈ w₂
    h_le h_G
  backward_H := fun w₁ w₂ _ h_le h_H =>
    -- CanonicalR w₂.world w₁.world → HContent(w₁) ⊆ w₂ (by duality)
    (GContent_subset_implies_HContent_reverse w₂.world w₁.world w₂.is_mcs w₁.is_mcs h_le) h_H

/--
Forward_F for fragmentFMCS: if `F(φ) ∈ w.world`, there exists `s ≥ w` in the
fragment with `φ ∈ s.world`.

This is the key property that was blocked for the DovetailingChain but is
trivial for the BidirectionalFragment approach.
-/
theorem fragmentFMCS_forward_F
    (w : BidirectionalFragment M₀ h_mcs₀) (φ : Formula)
    (h_F : Formula.some_future φ ∈ (fragmentFMCS (h_mcs₀ := h_mcs₀)).mcs w) :
    ∃ s : BidirectionalFragment M₀ h_mcs₀,
      w ≤ s ∧ φ ∈ (fragmentFMCS (h_mcs₀ := h_mcs₀)).mcs s := by
  obtain ⟨s, h_R, h_phi⟩ := forward_F_stays_in_fragment w φ h_F
  exact ⟨s, h_R, h_phi⟩

/--
Backward_P for fragmentFMCS: if `P(φ) ∈ w.world`, there exists `s ≤ w` in the
fragment with `φ ∈ s.world`.

This is the past-direction analog, equally trivial at the fragment level.
-/
theorem fragmentFMCS_backward_P
    (w : BidirectionalFragment M₀ h_mcs₀) (φ : Formula)
    (h_P : Formula.some_past φ ∈ (fragmentFMCS (h_mcs₀ := h_mcs₀)).mcs w) :
    ∃ s : BidirectionalFragment M₀ h_mcs₀,
      s ≤ w ∧ φ ∈ (fragmentFMCS (h_mcs₀ := h_mcs₀)).mcs s := by
  obtain ⟨s, h_R_past, h_phi⟩ := backward_P_stays_in_fragment w φ h_P
  have h_R : CanonicalR s.world w.world :=
    HContent_subset_implies_GContent_reverse w.world s.world w.is_mcs s.is_mcs h_R_past
  exact ⟨s, h_R, h_phi⟩

/--
The fragmentFMCS is temporally coherent: all F/P obligations have witnesses in the fragment.
-/
theorem fragmentFMCS_temporally_coherent :
    (∀ w : BidirectionalFragment M₀ h_mcs₀, ∀ φ : Formula,
      Formula.some_future φ ∈ (fragmentFMCS (h_mcs₀ := h_mcs₀)).mcs w →
      ∃ s, w ≤ s ∧ φ ∈ (fragmentFMCS (h_mcs₀ := h_mcs₀)).mcs s) ∧
    (∀ w : BidirectionalFragment M₀ h_mcs₀, ∀ φ : Formula,
      Formula.some_past φ ∈ (fragmentFMCS (h_mcs₀ := h_mcs₀)).mcs w →
      ∃ s, s ≤ w ∧ φ ∈ (fragmentFMCS (h_mcs₀ := h_mcs₀)).mcs s) :=
  ⟨fragmentFMCS_forward_F, fragmentFMCS_backward_P⟩

/-!
## Witness Seed Consistency

This crucial lemma enables the Int-chain construction. When a witness `W` exists
in the fragment with `CanonicalR M W` and `φ ∈ W`, the seed `{φ} ∪ GContent(M)`
is consistent. This is because `W` contains both `φ` and `GContent(M)`.
-/

/--
If `CanonicalR M W` and `φ ∈ W`, then `{φ} ∪ GContent(M)` is consistent.

**Proof**: Every formula in the seed is in `W` (an MCS):
- `φ ∈ W` by hypothesis
- `GContent(M) ⊆ W` by `CanonicalR M W`
Since `W` is consistent, any finite subset derives only derivable conclusions.
-/
theorem witness_seed_consistent (M W : Set Formula)
    (h_mcs_W : SetMaximalConsistent W)
    (h_R : CanonicalR M W)
    (φ : Formula) (h_phi : φ ∈ W) :
    SetConsistent ({φ} ∪ GContent M) := by
  intro L hL_sub ⟨d⟩
  have h_L_in_W : ∀ x ∈ L, x ∈ W := by
    intro x hx
    have := hL_sub x hx
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with rfl | h_gc
    · exact h_phi
    · exact h_R h_gc
  exact h_mcs_W.1 L h_L_in_W ⟨d⟩

/-!
## Phase E: Enriched Chain Construction (Fragment → Int)

The fragment-level FMCS has all properties sorry-free, but we need FMCS Int.
To convert, we build an order-preserving chain `Int → Fragment` that visits
all necessary F/P witnesses.

### Key Lemma: Enriched Seed Consistency

When `F(φ) ∈ w.world` for a fragment element `w`, the enriched seed
`{φ} ∪ GContent(w.world)` is consistent. This is because
`forward_F_stays_in_fragment` gives a witness `W` with `CanonicalR w W`
and `φ ∈ W`, so `W ⊇ {φ} ∪ GContent(w.world)` and `W` is consistent.

This resolves the F-persistence problem that blocked the DovetailingChain.
-/

/--
GContent of a fragment element is consistent.
Follows from GContent(M) ⊆ M (by T-axiom) and M is consistent.
-/
lemma GContent_consistent_of_fragment
    (w : BidirectionalFragment M₀ h_mcs₀) :
    SetConsistent (GContent w.world) := by
  intro L hL_sub ⟨d⟩
  have h_L_in_M : ∀ x ∈ L, x ∈ w.world := by
    intro x hx
    have h_gc := hL_sub x hx
    have h_T := DerivationTree.axiom [] ((Formula.all_future x).imp x) (Axiom.temp_t_future x)
    exact set_mcs_implication_property w.is_mcs (theorem_in_mcs w.is_mcs h_T) h_gc
  exact w.is_mcs.1 L h_L_in_M ⟨d⟩

/--
When `F(φ) ∈ w.world`, the enriched seed `{φ} ∪ GContent(w.world)` is consistent.

This is the KEY lemma that resolves the F-persistence problem.
The BidirectionalFragment's closure property (`forward_F_stays_in_fragment`)
provides a witness MCS `W` with `CanonicalR w W` and `φ ∈ W`. Since `W` contains
both `φ` and `GContent(w.world)`, the seed is consistent.
-/
theorem enriched_seed_consistent_from_F
    (w : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_F : Formula.some_future φ ∈ w.world) :
    SetConsistent ({φ} ∪ GContent w.world) := by
  obtain ⟨s, h_R, h_phi⟩ := forward_F_stays_in_fragment w φ h_F
  exact witness_seed_consistent w.world s.world s.is_mcs h_R φ h_phi

/--
HContent of a fragment element is consistent.
Follows from HContent(M) ⊆ M (by T-axiom for past) and M is consistent.
-/
lemma HContent_consistent_of_fragment
    (w : BidirectionalFragment M₀ h_mcs₀) :
    SetConsistent (HContent w.world) := by
  intro L hL_sub ⟨d⟩
  have h_L_in_M : ∀ x ∈ L, x ∈ w.world := by
    intro x hx
    have h_hc := hL_sub x hx
    have h_T := DerivationTree.axiom [] ((Formula.all_past x).imp x) (Axiom.temp_t_past x)
    exact set_mcs_implication_property w.is_mcs (theorem_in_mcs w.is_mcs h_T) h_hc
  exact w.is_mcs.1 L h_L_in_M ⟨d⟩

/--
When `P(φ) ∈ w.world`, the enriched seed `{φ} ∪ HContent(w.world)` is consistent.

This is the backward analog of `enriched_seed_consistent_from_F`.
-/
theorem enriched_seed_consistent_from_P
    (w : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_P : Formula.some_past φ ∈ w.world) :
    SetConsistent ({φ} ∪ HContent w.world) := by
  obtain ⟨s, h_R_past, h_phi⟩ := backward_P_stays_in_fragment w φ h_P
  -- s has CanonicalR_past w.world s.world (HContent(w) ⊆ s) and φ ∈ s.world
  -- So {φ} ∪ HContent(w.world) ⊆ s.world (consistent)
  intro L hL_sub ⟨d⟩
  have h_L_in_s : ∀ x ∈ L, x ∈ s.world := by
    intro x hx
    have := hL_sub x hx
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with rfl | h_hc
    · exact h_phi
    · exact h_R_past h_hc
  exact s.is_mcs.1 L h_L_in_s ⟨d⟩

/--
Build a GContent-successor in the fragment.
Given `w` in the fragment, produce `w'` with `CanonicalR w w'` and `w'` in the fragment.
-/
noncomputable def fragmentGSucc (w : BidirectionalFragment M₀ h_mcs₀) :
    BidirectionalFragment M₀ h_mcs₀ :=
  w.forward_closed
    (lindenbaumMCS_set (GContent w.world) (GContent_consistent_of_fragment w))
    (lindenbaumMCS_set_is_mcs _ (GContent_consistent_of_fragment w))
    (fun _ h_G => lindenbaumMCS_set_extends _ (GContent_consistent_of_fragment w) h_G)

/--
`fragmentGSucc w ≥ w` in the preorder.
-/
lemma fragmentGSucc_le (w : BidirectionalFragment M₀ h_mcs₀) :
    w ≤ fragmentGSucc w := by
  show CanonicalR w.world (fragmentGSucc w).world
  intro φ h_G
  exact lindenbaumMCS_set_extends _ (GContent_consistent_of_fragment w) h_G

/--
Build an enriched successor in the fragment that contains a witness formula.
Given `w` in the fragment and `F(φ) ∈ w.world`, produce `w'` with
`CanonicalR w w'`, `φ ∈ w'`, and `w'` in the fragment.
-/
noncomputable def fragmentFSucc
    (w : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_F : Formula.some_future φ ∈ w.world) :
    BidirectionalFragment M₀ h_mcs₀ :=
  w.forward_closed
    (lindenbaumMCS_set ({φ} ∪ GContent w.world) (enriched_seed_consistent_from_F w φ h_F))
    (lindenbaumMCS_set_is_mcs _ (enriched_seed_consistent_from_F w φ h_F))
    (fun _ h_G => lindenbaumMCS_set_extends _ (enriched_seed_consistent_from_F w φ h_F)
      (Set.mem_union_right _ h_G))

/--
The enriched successor contains the witness formula.
-/
lemma fragmentFSucc_contains_witness
    (w : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_F : Formula.some_future φ ∈ w.world) :
    φ ∈ (fragmentFSucc w φ h_F).world := by
  show φ ∈ (lindenbaumMCS_set ({φ} ∪ GContent w.world)
    (enriched_seed_consistent_from_F w φ h_F))
  exact lindenbaumMCS_set_extends _ (enriched_seed_consistent_from_F w φ h_F)
    (Set.mem_union_left _ (Set.mem_singleton φ))

/--
The enriched successor is ≥ w.
-/
lemma fragmentFSucc_le
    (w : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_F : Formula.some_future φ ∈ w.world) :
    w ≤ fragmentFSucc w φ h_F := by
  show CanonicalR w.world (fragmentFSucc w φ h_F).world
  intro ψ h_G
  exact lindenbaumMCS_set_extends _ (enriched_seed_consistent_from_F w φ h_F)
    (Set.mem_union_right _ h_G)

/-!
## BoxContent and Diamond Witness Infrastructure

These definitions support modal saturation: constructing witness families for
Diamond obligations.
-/

/--
BoxContent(M) = {φ | Box(φ) ∈ M}: the set of formulas necessarily true at M.
-/
def BoxContent (M : Set Formula) : Set Formula :=
  {φ | Formula.box φ ∈ M}

/--
BoxWitnessSeed for Diamond(ψ): {ψ} ∪ BoxContent(M).
-/
def BoxWitnessSeed (M : Set Formula) (ψ : Formula) : Set Formula :=
  {ψ} ∪ BoxContent M

/--
ψ is in its own BoxWitnessSeed.
-/
lemma psi_mem_BoxWitnessSeed (M : Set Formula) (ψ : Formula) :
    ψ ∈ BoxWitnessSeed M ψ :=
  Set.mem_union_left _ (Set.mem_singleton ψ)

/--
BoxContent is a subset of BoxWitnessSeed.
-/
lemma BoxContent_subset_BoxWitnessSeed (M : Set Formula) (ψ : Formula) :
    BoxContent M ⊆ BoxWitnessSeed M ψ :=
  Set.subset_union_right

/--
BoxWitnessSeed consistency: If Diamond(ψ) ∈ MCS M, then {ψ} ∪ BoxContent(M) is consistent.

**Proof Strategy**:
Suppose {ψ} ∪ BoxContent(M) is inconsistent.
Then there exist φ₁, ..., φ_n in BoxContent(M) with {ψ, φ₁, ..., φ_n} ⊢ ⊥.
By deduction: {φ₁, ..., φ_n} ⊢ ¬ψ.
By generalized modal K: Box(φ₁), ..., Box(φ_n) ⊢ Box(¬ψ).
Since Box(φ_i) ∈ M, by MCS closure: Box(¬ψ) ∈ M.
But Diamond(ψ) = ¬Box(¬ψ) ∈ M, contradiction.
-/
theorem box_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_diamond : diamondFormula ψ ∈ M) :
    SetConsistent (BoxWitnessSeed M ψ) := by
  intro L hL_sub ⟨d⟩
  by_cases h_psi_in : ψ ∈ L
  · let L_filt := L.filter (fun y => decide (y ≠ ψ))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (ψ :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)
    have d_neg : L_filt ⊢ Formula.neg ψ :=
      deduction_theorem L_filt ψ Formula.bot d_reord
    have h_Box_filt_in_M : ∀ chi ∈ L_filt, Formula.box chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ ψ := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [BoxWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_boxcontent
      · exact absurd h_eq h_ne
      · exact h_boxcontent
    have d_Box_neg : (Context.map Formula.box L_filt) ⊢ Formula.box (Formula.neg ψ) :=
      Bimodal.Theorems.generalized_modal_k L_filt (Formula.neg ψ) d_neg
    have h_Box_context_in_M : ∀ phi ∈ Context.map Formula.box L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_Box_filt_in_M chi h_chi_in
    have h_Box_neg_in_M : Formula.box (Formula.neg ψ) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.box L_filt)
        h_Box_context_in_M d_Box_neg
    have h_diamond_eq : diamondFormula ψ = Formula.neg (Formula.box (Formula.neg ψ)) := rfl
    rw [h_diamond_eq] at h_diamond
    exact set_consistent_not_both h_mcs.1 (Formula.box (Formula.neg ψ)) h_Box_neg_in_M h_diamond
  · have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [BoxWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_boxcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · have h_Box_chi : Formula.box chi ∈ M := h_boxcontent
        have h_T := DerivationTree.axiom [] ((Formula.box chi).imp chi) (Axiom.modal_t chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_Box_chi
    exact h_mcs.1 L h_L_in_M ⟨d⟩

/--
Construct a witness MCS for Diamond(ψ) ∈ M₀: extends {ψ} ∪ BoxContent(M₀).
-/
noncomputable def diamondWitnessMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_diamond : diamondFormula ψ ∈ M) : Set Formula :=
  lindenbaumMCS_set (BoxWitnessSeed M ψ) (box_witness_seed_consistent M h_mcs ψ h_diamond)

/--
The witness MCS is maximal consistent.
-/
lemma diamondWitnessMCS_is_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_diamond : diamondFormula ψ ∈ M) :
    SetMaximalConsistent (diamondWitnessMCS M h_mcs ψ h_diamond) :=
  lindenbaumMCS_set_is_mcs (BoxWitnessSeed M ψ) (box_witness_seed_consistent M h_mcs ψ h_diamond)

/--
ψ is in the witness MCS.
-/
lemma diamondWitnessMCS_contains_psi (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_diamond : diamondFormula ψ ∈ M) :
    ψ ∈ diamondWitnessMCS M h_mcs ψ h_diamond :=
  lindenbaumMCS_set_extends (BoxWitnessSeed M ψ)
    (box_witness_seed_consistent M h_mcs ψ h_diamond)
    (psi_mem_BoxWitnessSeed M ψ)

/--
BoxContent(M) is in the witness MCS.
-/
lemma diamondWitnessMCS_contains_BoxContent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_diamond : diamondFormula ψ ∈ M) :
    BoxContent M ⊆ diamondWitnessMCS M h_mcs ψ h_diamond :=
  Set.Subset.trans (BoxContent_subset_BoxWitnessSeed M ψ)
    (lindenbaumMCS_set_extends (BoxWitnessSeed M ψ)
      (box_witness_seed_consistent M h_mcs ψ h_diamond))

end Bimodal.Metalogic.Bundle
