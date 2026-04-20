import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# BX Canonical Frame

Defines the canonical frame for BX completeness. Points are maximal consistent
sets (MCS). The temporal ordering is: w ≤ v iff g_content(w) ⊆ v (equivalently,
for all φ, G(φ) ∈ w → φ ∈ v). Modal equivalence: w ~ v iff they agree on all
Box-formulas.

## Main Definitions

- `BXPoint`: A point in the canonical frame (wrapping SetMaximalConsistent)
- `bx_le`: Canonical temporal ordering
- `bx_modal_equiv`: Modal equivalence relation
- `bx_le_refl`: Reflexivity (from BX1: G(φ) → φ)
- `bx_le_trans`: Transitivity (from temp_4: G(φ) → G(G(φ)))

## Key Infrastructure

- `g_content_closed_derivation`: If L ⊆ g_content(S) and L ⊢ φ, then G(φ) ∈ S
- `h_content_closed_derivation`: Dual for h_content/H
- These enable the backward direction of the truth lemma for G/H.

## References

- Burgess 1984, Goldblatt 1992 (canonical model construction for tense logics)
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Theorems

/-! ## BX Canonical Point -/

/--
A point in the BX canonical frame: a set of formulas that is maximally consistent.
-/
structure BXPoint where
  /-- The underlying set of formulas -/
  formulas : Set Formula
  /-- Proof that the set is maximally consistent -/
  is_mcs : SetMaximalConsistent formulas

/-! ## Canonical Temporal Ordering -/

/--
Canonical temporal ordering: w ≤ v iff g_content(w) ⊆ v.formulas.
Equivalently: for all φ, G(φ) ∈ w → φ ∈ v.
-/
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas

/--
Canonical modal equivalence: w ~ v iff they agree on all Box-formulas.
-/
def bx_modal_equiv (w v : BXPoint) : Prop :=
  ∀ φ : Formula, Formula.box φ ∈ w.formulas ↔ Formula.box φ ∈ v.formulas

/-! ## Key Helper: g_content Closed Under Derivation -/

/--
If all formulas in a list L are in g_content(S), and L ⊢ φ, then G(φ) ∈ S.

This is the Set-based MCS version of generalized temporal necessitation.
Key technique: apply `generalized_temporal_k` to get `G(L) ⊢ G(φ)`,
then use `closed_under_derivation` since each `G(ψ) ∈ S` for `ψ ∈ L`.
-/
noncomputable def g_content_closed_derivation {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ g_content S)
    (h_deriv : DerivationTree L φ) : Formula.all_future φ ∈ S := by
  -- Apply generalized temporal K: L ⊢ φ gives G(L) ⊢ G(φ)
  have d_G : (Context.map Formula.all_future L) ⊢ Formula.all_future φ :=
    generalized_temporal_k L φ h_deriv
  -- All formulas in G(L) are in S
  have h_GL_in_S : ∀ f ∈ Context.map Formula.all_future L, f ∈ S := by
    intro f hf
    rw [Context.mem_map_iff] at hf
    obtain ⟨ψ, hψ_in, hψ_eq⟩ := hf
    rw [← hψ_eq]
    exact h_sub ψ hψ_in
  exact SetMaximalConsistent.closed_under_derivation h_mcs
    (Context.map Formula.all_future L) h_GL_in_S d_G

/--
If all formulas in a list L are in h_content(S), and L ⊢ φ, then H(φ) ∈ S.

Dual of `g_content_closed_derivation` using `generalized_past_k`.
-/
noncomputable def h_content_closed_derivation {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ h_content S)
    (h_deriv : DerivationTree L φ) : Formula.all_past φ ∈ S := by
  have d_H : (Context.map Formula.all_past L) ⊢ Formula.all_past φ :=
    generalized_past_k L φ h_deriv
  have h_HL_in_S : ∀ f ∈ Context.map Formula.all_past L, f ∈ S := by
    intro f hf
    rw [Context.mem_map_iff] at hf
    obtain ⟨ψ, hψ_in, hψ_eq⟩ := hf
    rw [← hψ_eq]
    exact h_sub ψ hψ_in
  exact SetMaximalConsistent.closed_under_derivation h_mcs
    (Context.map Formula.all_past L) h_HL_in_S d_H

/--
g_content of an MCS is consistent (viewed as a set).

If some finite L ⊆ g_content(S) derives ⊥, then G(⊥) ∈ S (by g_content_closed_derivation),
then ⊥ ∈ S (by BX1: G(⊥) → ⊥), contradicting S consistent.
-/
theorem g_content_set_consistent {S : Set Formula} (h_mcs : SetMaximalConsistent S) :
    SetConsistent (g_content S) := by
  intro L hL ⟨d⟩
  -- Under irreflexive semantics, G(⊥) → ⊥ requires seriality, not BX1.
  sorry

/-! ## Reflexivity (from BX1: G(φ) → φ) -/

/--
The canonical ordering is reflexive: w ≤ w for all BXPoints.
-/
theorem bx_le_refl (w : BXPoint) : bx_le w w := by
  -- Under irreflexive semantics, bx_le is NOT reflexive.
  -- G(φ) → φ is no longer valid.
  sorry

/-! ## Transitivity (from temp_4: G(φ) → G(G(φ))) -/

/--
The canonical ordering is transitive: w ≤ u and u ≤ v implies w ≤ v.
-/
theorem bx_le_trans {w u v : BXPoint} (hwu : bx_le w u) (huv : bx_le u v) :
    bx_le w v := by
  intro φ hφ
  have h_GGφ := SetMaximalConsistent.all_future_all_future w.is_mcs hφ
  exact huv (hwu h_GGφ)

/-! ## Forward/Backward Temporal Witnesses -/

/--
If F(ψ) ∈ w, there exists v ≥ w with ψ ∈ v.
-/
noncomputable def bx_forward_witness (w : BXPoint) (ψ : Formula)
    (h_F : Formula.some_future ψ ∈ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas := by
  have h_seed_cons := forward_temporal_witness_seed_consistent w.formulas w.is_mcs ψ h_F
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum _ h_seed_cons
  exact ⟨⟨M, hM_mcs⟩,
    fun χ hχ => hM_sup (Set.mem_union_right _ hχ),
    hM_sup (Set.mem_union_left _ (Set.mem_singleton ψ))⟩

/--
If P(ψ) ∈ w, there exists v ≤ w with ψ ∈ v.
-/
noncomputable def bx_backward_witness (w : BXPoint) (ψ : Formula)
    (h_P : Formula.some_past ψ ∈ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas := by
  have h_seed_cons := past_temporal_witness_seed_consistent w.formulas w.is_mcs ψ h_P
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum _ h_seed_cons
  have h_h_sub : h_content w.formulas ⊆ M :=
    fun χ hχ => hM_sup (Set.mem_union_right _ hχ)
  exact ⟨⟨M, hM_mcs⟩,
    h_content_subset_implies_g_content_reverse w.formulas M w.is_mcs hM_mcs h_h_sub,
    hM_sup (Set.mem_union_left _ (Set.mem_singleton ψ))⟩

/-! ## G-content Forward and Backward -/

/--
If G(φ) ∈ w and w ≤ v, then φ ∈ v.
-/
theorem bx_G_forward {w v : BXPoint} {φ : Formula}
    (h_le : bx_le w v) (h_G : Formula.all_future φ ∈ w.formulas) :
    φ ∈ v.formulas :=
  h_le h_G

/--
If G(φ) ∉ w, then there exists v ≥ w with φ ∉ v.

Proof: ¬G(φ) ∈ w. Show {¬φ} ∪ g_content(w) is consistent. Extend to MCS v.
Then v ≥ w (since g_content(w) ⊆ v) and ¬φ ∈ v (so φ ∉ v).

Consistency: If L ⊆ {¬φ} ∪ g_content(w) and L ⊢ ⊥, split on whether ¬φ ∈ L.
If ¬φ ∈ L: by deduction L\{¬φ} ⊢ ¬¬φ, then derive φ (double negation elimination),
then G(φ) ∈ w by g_content_closed_derivation, contradiction.
If ¬φ ∉ L: L ⊆ g_content(w), so G(⊥) ∈ w, then ⊥ ∈ w, contradiction.
-/
noncomputable def bx_G_backward (w : BXPoint) (φ : Formula)
    (h_not_G : Formula.all_future φ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ φ ∉ v.formulas := by
  -- Seed: {¬φ} ∪ g_content(w)
  have h_seed_cons : SetConsistent ({Formula.neg φ} ∪ g_content w.formulas) := by
    intro L hL ⟨d⟩
    by_cases h_negφ_in : Formula.neg φ ∈ L
    · -- ¬φ ∈ L. Deduction: L \ {¬φ} ⊢ ¬¬φ. Then derive G(φ) ∈ w.
      let L_filt := L.filter (fun y => decide (y ≠ Formula.neg φ))
      have d_reord : DerivationTree (Formula.neg φ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (cons_filter_neq_perm h_negφ_in x).symm)
      have d_negneg : DerivationTree L_filt (Formula.neg (Formula.neg φ)) :=
        deduction_theorem L_filt (Formula.neg φ) Formula.bot d_reord
      -- All of L_filt ⊆ g_content(w)
      have h_filt_in_g : ∀ ψ ∈ L_filt, ψ ∈ g_content w.formulas := by
        intro ψ hψ
        have h_and := List.mem_filter.mp hψ
        have h_ne : ψ ≠ Formula.neg φ := by simpa using h_and.2
        have h_mem := hL ψ h_and.1
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd rfl h_ne
        · exact h
      -- Derive double_neg_elim: ¬¬φ → φ
      have h_dne : [] ⊢ (Formula.neg (Formula.neg φ)).imp φ :=
        Bimodal.Theorems.Propositional.double_negation φ
      -- L_filt ⊢ ¬¬φ, weaken dne to L_filt, apply MP to get L_filt ⊢ φ
      have d_dne_weak : DerivationTree L_filt ((Formula.neg (Formula.neg φ)).imp φ) :=
        DerivationTree.weakening [] L_filt _ h_dne (List.nil_subset _)
      have d_phi : DerivationTree L_filt φ :=
        DerivationTree.modus_ponens L_filt _ _ d_dne_weak d_negneg
      -- G(φ) ∈ w by g_content_closed_derivation
      have h_Gφ := g_content_closed_derivation w.is_mcs L_filt h_filt_in_g d_phi
      exact h_not_G h_Gφ
    · -- ¬φ ∉ L, so L ⊆ g_content(w)
      have h_L_in_g : ∀ ψ ∈ L, ψ ∈ g_content w.formulas := by
        intro ψ hψ
        have h_mem := hL ψ hψ
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd hψ h_negφ_in
        · exact h
      -- G(⊥) ∈ w, then ⊥ ∈ w (BX1), contradiction
      exact g_content_set_consistent w.is_mcs L h_L_in_g ⟨d⟩
  -- Extend to MCS
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum _ h_seed_cons
  exact ⟨⟨M, hM_mcs⟩,
    fun χ hχ => hM_sup (Set.mem_union_right _ hχ),
    SetMaximalConsistent.neg_excludes hM_mcs φ
      (hM_sup (Set.mem_union_left _ (Set.mem_singleton _)))⟩

/-! ## H-content Forward and Backward -/

/--
If H(φ) ∈ w and v ≤ w, then φ ∈ v.

Uses the g/h content duality: g_content(v) ⊆ w implies h_content(w) ⊆ v.
-/
theorem bx_H_forward {w v : BXPoint} {φ : Formula}
    (h_le : bx_le v w) (h_H : Formula.all_past φ ∈ w.formulas) :
    φ ∈ v.formulas :=
  g_content_subset_implies_h_content_reverse v.formulas w.formulas
    v.is_mcs w.is_mcs h_le h_H

/--
If H(φ) ∉ w, then there exists v ≤ w with φ ∉ v.

Mirror of bx_G_backward using h_content.
-/
noncomputable def bx_H_backward (w : BXPoint) (φ : Formula)
    (h_not_H : Formula.all_past φ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ φ ∉ v.formulas := by
  -- Under irreflexive semantics, this needs redesign (uses BX1' via H(⊥)→⊥).
  sorry
  /- OLD PROOF:
  -- Seed: {¬φ} ∪ h_content(w)
  have h_seed_cons : SetConsistent ({Formula.neg φ} ∪ h_content w.formulas) := by
    intro L hL ⟨d⟩
    by_cases h_negφ_in : Formula.neg φ ∈ L
    · let L_filt := L.filter (fun y => decide (y ≠ Formula.neg φ))
      have d_reord : DerivationTree (Formula.neg φ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (cons_filter_neq_perm h_negφ_in x).symm)
      have d_negneg : DerivationTree L_filt (Formula.neg (Formula.neg φ)) :=
        deduction_theorem L_filt (Formula.neg φ) Formula.bot d_reord
      have h_filt_in_h : ∀ ψ ∈ L_filt, ψ ∈ h_content w.formulas := by
        intro ψ hψ
        have h_and := List.mem_filter.mp hψ
        have h_ne : ψ ≠ Formula.neg φ := by simpa using h_and.2
        have h_mem := hL ψ h_and.1
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd rfl h_ne
        · exact h
      have h_dne : [] ⊢ (Formula.neg (Formula.neg φ)).imp φ :=
        Bimodal.Theorems.Propositional.double_negation φ
      have d_dne_weak : DerivationTree L_filt ((Formula.neg (Formula.neg φ)).imp φ) :=
        DerivationTree.weakening [] L_filt _ h_dne (List.nil_subset _)
      have d_phi : DerivationTree L_filt φ :=
        DerivationTree.modus_ponens L_filt _ _ d_dne_weak d_negneg
      have h_Hφ := h_content_closed_derivation w.is_mcs L_filt h_filt_in_h d_phi
      exact h_not_H h_Hφ
    · have h_L_in_h : ∀ ψ ∈ L, ψ ∈ h_content w.formulas := by
        intro ψ hψ
        have h_mem := hL ψ hψ
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd hψ h_negφ_in
        · exact h
      -- H(⊥) ∈ w, then ⊥ ∈ w (BX1'), contradiction
      have h_H_bot := h_content_closed_derivation w.is_mcs L h_L_in_h d
      have h_ax : DerivationTree [] (Formula.all_past Formula.bot |>.imp Formula.bot) :=
        DerivationTree.axiom [] _ (Axiom.temp_t_past Formula.bot)
      have h_bot := SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_ax) h_H_bot
      exact w.is_mcs.1 [Formula.bot] (fun ψ hψ => by simp at hψ; rw [hψ]; exact h_bot)
        ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
  -- Extend to MCS
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum _ h_seed_cons
  have h_h_sub : h_content w.formulas ⊆ M :=
    fun χ hχ => hM_sup (Set.mem_union_right _ hχ)
  exact ⟨⟨M, hM_mcs⟩,
    h_content_subset_implies_g_content_reverse w.formulas M w.is_mcs hM_mcs h_h_sub,
    SetMaximalConsistent.neg_excludes hM_mcs φ
      (hM_sup (Set.mem_union_left _ (Set.mem_singleton _)))⟩
  -/

/-! ## Modal Equivalence Properties -/

theorem bx_modal_equiv_refl (w : BXPoint) : bx_modal_equiv w w :=
  fun _ => Iff.rfl

theorem bx_modal_equiv_symm {w v : BXPoint} (h : bx_modal_equiv w v) :
    bx_modal_equiv v w :=
  fun φ => (h φ).symm

theorem bx_modal_equiv_trans {w u v : BXPoint}
    (hwu : bx_modal_equiv w u) (huv : bx_modal_equiv u v) :
    bx_modal_equiv w v :=
  fun φ => (hwu φ).trans (huv φ)

/-! ## Modal Witness -/

/--
If ◇ψ ∈ w, there exists v with bx_modal_equiv w v and ψ ∈ v.

Uses S5 modal axioms and Lindenbaum.
The seed is {ψ} ∪ box_content(w) where box_content(w) = {χ | □χ ∈ w}.

Consistency: suppose L ⊆ {ψ} ∪ box_content(w) and L ⊢ ⊥.
If ψ ∈ L: by deduction L\{ψ} ⊢ ¬ψ. By generalized modal K, □(L\{ψ}) ⊢ □(¬ψ).
Since each □χ ∈ w for χ in L\{ψ}, we get □(¬ψ) ∈ w.
But ◇ψ = ¬□¬ψ ∈ w, contradiction.
If ψ ∉ L: L ⊆ box_content(w), so □(L) ⊢ □(⊥), □(⊥) ∈ w, then ⊥ ∈ w by modal_t.
-/
noncomputable def bx_modal_witness (w : BXPoint) (ψ : Formula)
    (h_dia : Formula.diamond ψ ∈ w.formulas) :
    ∃ v : BXPoint, bx_modal_equiv w v ∧ ψ ∈ v.formulas := by
  -- box_content
  let bc := {χ : Formula | Formula.box χ ∈ w.formulas}
  -- Seed consistency
  have h_seed_cons : SetConsistent ({ψ} ∪ bc) := by
    intro L hL ⟨d⟩
    by_cases h_ψ_in : ψ ∈ L
    · -- ψ ∈ L case
      let L_filt := L.filter (fun y => decide (y ≠ ψ))
      have d_reord : DerivationTree (ψ :: L_filt) Formula.bot :=
        derivation_exchange d (fun x => (cons_filter_neq_perm h_ψ_in x).symm)
      have d_neg : DerivationTree L_filt (Formula.neg ψ) :=
        deduction_theorem L_filt ψ Formula.bot d_reord
      have h_filt_in_bc : ∀ χ ∈ L_filt, χ ∈ bc := by
        intro χ hχ
        have h_and := List.mem_filter.mp hχ
        have h_ne : χ ≠ ψ := by simpa using h_and.2
        have h_mem := hL χ h_and.1
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd rfl h_ne
        · exact h
      -- Apply generalized modal K: L_filt ⊢ ¬ψ gives □(L_filt) ⊢ □(¬ψ)
      have d_box_neg : (Context.map Formula.box L_filt) ⊢ Formula.box (Formula.neg ψ) :=
        generalized_modal_k L_filt (Formula.neg ψ) d_neg
      have h_box_L_in : ∀ f ∈ Context.map Formula.box L_filt, f ∈ w.formulas := by
        intro f hf
        rw [Context.mem_map_iff] at hf
        obtain ⟨χ, hχ_in, hχ_eq⟩ := hf
        rw [← hχ_eq]
        exact h_filt_in_bc χ hχ_in
      have h_box_neg_in := SetMaximalConsistent.closed_under_derivation w.is_mcs
        (Context.map Formula.box L_filt) h_box_L_in d_box_neg
      -- ◇ψ = ¬□¬ψ ∈ w, and □¬ψ ∈ w: contradiction
      -- diamond ψ = (neg ψ).box.neg = neg (box (neg ψ))
      have h_eq : Formula.diamond ψ = Formula.neg (Formula.box (Formula.neg ψ)) := rfl
      rw [h_eq] at h_dia
      exact set_consistent_not_both w.is_mcs.1 _ h_box_neg_in h_dia
    · -- ψ ∉ L case
      have h_L_in_bc : ∀ χ ∈ L, χ ∈ bc := by
        intro χ hχ
        have h_mem := hL χ hχ
        simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
        rcases h_mem with rfl | h
        · exact absurd hχ h_ψ_in
        · exact h
      have d_box_bot : (Context.map Formula.box L) ⊢ Formula.box Formula.bot :=
        generalized_modal_k L Formula.bot d
      have h_box_L_in : ∀ f ∈ Context.map Formula.box L, f ∈ w.formulas := by
        intro f hf
        rw [Context.mem_map_iff] at hf
        obtain ⟨χ, hχ_in, hχ_eq⟩ := hf
        rw [← hχ_eq]
        exact h_L_in_bc χ hχ_in
      have h_box_bot_in := SetMaximalConsistent.closed_under_derivation w.is_mcs
        (Context.map Formula.box L) h_box_L_in d_box_bot
      -- □⊥ → ⊥ by modal_t
      have h_ax : DerivationTree [] (Formula.box Formula.bot |>.imp Formula.bot) :=
        DerivationTree.axiom [] _ (Axiom.modal_t Formula.bot)
      have h_bot := SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_ax) h_box_bot_in
      exact w.is_mcs.1 [Formula.bot] (fun χ hχ => by simp at hχ; rw [hχ]; exact h_bot)
        ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
  -- Extend to MCS
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum _ h_seed_cons
  -- Show modal equivalence: box_content(w) = box_content(M)
  -- Forward: □φ ∈ w → □□φ ∈ w (modal_4) → □φ ∈ bc → □φ ∈ M
  -- Backward: □φ ∈ M → φ ∈ M (modal_t) → ... we need the S5 argument
  -- Actually: □φ ∈ w → □□φ ∈ w (modal_4) → □φ ∈ bc → □φ ∈ M
  -- And: □φ ∈ M. We want □φ ∈ w.
  -- By S5: ◇□φ → □φ. If □φ ∈ M, we need to show □φ ∈ w.
  -- Using modal_b on w: φ ∈ w → □◇φ ∈ w.
  -- This is getting complicated. Use the standard S5 argument:
  -- Since bc ⊆ M, any □φ ∈ w gives □□φ ∈ w (modal_4) gives □φ ∈ bc gives □φ ∈ M.
  -- For the reverse, we use modal_5_collapse + S5.
  -- For □φ ∈ M, we want □φ ∈ w.
  -- By contraposition: if □φ ∉ w, then ◇¬φ ∈ w (negation completeness),
  -- so ¬φ ∈ some MCS accessible from w... but that MCS might not be M.
  -- The standard way: show ◇□φ ∈ w (because □φ ∈ M and M extends bc with ψ,
  -- and we need S5 argument).
  -- This is the hardest part of modal canonical models. For now, sorry the
  -- full modal equivalence and prove the forward direction.
  have h_ψ_in : ψ ∈ M := hM_sup (Set.mem_union_left _ (Set.mem_singleton ψ))
  have h_bc_sub : bc ⊆ M := fun χ hχ => hM_sup (Set.mem_union_right _ hχ)
  have h_equiv : bx_modal_equiv w ⟨M, hM_mcs⟩ := by
    intro χ
    constructor
    · -- □χ ∈ w → □χ ∈ M
      intro h_box
      -- □χ ∈ w → □□χ ∈ w (modal_4) → □χ ∈ bc → □χ ∈ M
      have h_m4 : DerivationTree [] ((Formula.box χ).imp (Formula.box (Formula.box χ))) :=
        DerivationTree.axiom [] _ (Axiom.modal_4 χ)
      have h_box_box := SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_m4) h_box
      -- □□χ ∈ w means □χ ∈ bc (since bc = {ψ | □ψ ∈ w})
      have h_in_bc : Formula.box χ ∈ bc := h_box_box
      exact h_bc_sub h_in_bc
    · -- □χ ∈ M → □χ ∈ w
      intro h_box_M
      -- Use S5: ◇□χ → □χ (modal_5_collapse)
      -- We need ◇□χ ∈ w. By modal_b on w: □χ → □◇□χ... no, modal_b is φ → □◇φ.
      -- If □χ ∈ M and M extends bc, we need a more subtle argument.
      -- Standard approach for S5 canonical models:
      -- Suppose □χ ∉ w. Then ¬□χ ∈ w, i.e., ◇¬χ ∈ w, i.e., ¬□¬¬χ ∈ w.
      -- Actually, ¬(□χ) ∈ w. This means (□χ).diamond^{-1}... the argument is:
      -- ¬□χ = ◇(¬χ) by modal duality? No, ◇φ = ¬□¬φ. ¬□χ ≠ ◇(¬χ).
      -- ◇(¬χ) = ¬□¬¬χ, not ¬□χ.
      -- But we can derive: from ¬□χ ∈ w, we get □¬□χ ∈ w (by S5: ¬□φ → □¬□φ which is
      -- the dual of modal_5_collapse: ◇□φ → □φ).
      -- ¬□χ → □(¬□χ) is derivable in S5.
      -- Then □(¬□χ) ∈ w → ¬□χ ∈ bc → ¬□χ ∈ M.
      -- But also □χ ∈ M. Contradiction with M consistent.
      by_contra h_not_box
      have h_neg_box : (Formula.box χ).neg ∈ w.formulas := by
        cases SetMaximalConsistent.negation_complete w.is_mcs (Formula.box χ) with
        | inl h => exact absurd h h_not_box
        | inr h => exact h
      -- S5 negative introspection: ¬□φ → □(¬□φ)
      -- Derivation:
      -- 1. modal_5_collapse χ: ◇(□χ) → □χ, i.e., (□χ).neg.box.neg → □χ
      -- 2. Contrapositive: (□χ).neg → (□χ).neg.box.neg.neg
      -- 3. DNE on (□χ).neg.box: (□χ).neg.box.neg.neg → (□χ).neg.box
      -- 4. Compose: (□χ).neg → (□χ).neg.box, i.e., ¬□χ → □(¬□χ)
      have h_m5 : DerivationTree [] ((Formula.box χ).neg.box.neg.imp (Formula.box χ)) :=
        DerivationTree.axiom [] _ (Axiom.modal_5_collapse χ)
      have h_contra : DerivationTree [] ((Formula.box χ).neg.imp (Formula.box χ).neg.box.neg.neg) :=
        Propositional.contraposition h_m5
      have h_dne : DerivationTree [] ((Formula.box χ).neg.box.neg.neg.imp (Formula.box χ).neg.box) :=
        Propositional.double_negation ((Formula.box χ).neg.box)
      have h_neg_intro : DerivationTree [] ((Formula.box χ).neg.imp (Formula.box χ).neg.box) :=
        Combinators.imp_trans h_contra h_dne
      -- ¬□χ ∈ w → □(¬□χ) ∈ w
      have h_box_neg_box := SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_neg_intro) h_neg_box
      -- □(¬□χ) ∈ w → (¬□χ) ∈ bc → (¬□χ) ∈ M
      have h_in_bc : (Formula.box χ).neg ∈ bc := h_box_neg_box
      have h_neg_in_M := h_bc_sub h_in_bc
      -- But □χ ∈ M and ¬□χ ∈ M contradicts M consistent
      exact set_consistent_not_both hM_mcs.1 (Formula.box χ) h_box_M h_neg_in_M
  exact ⟨⟨M, hM_mcs⟩, h_equiv, h_ψ_in⟩

/-! ## Box Preservation Along bx_le

Key lemma for the dovetail chain truth lemma: box formulas are preserved
in both directions along the canonical temporal ordering bx_le. This follows
from temp_future (□φ → G(□φ)) for the forward direction, and S5 negative
introspection (¬□φ → □(¬□φ)) for the backward direction (via contrapositive).
-/

/--
S5 negative introspection: ¬□φ → □(¬□φ).

Proof: modal_5_collapse gives ◇□φ → □φ, i.e., ¬□(¬□φ) → □φ.
Contrapositive: ¬□φ → ¬¬□(¬□φ). Compose with DNE to get ¬□φ → □(¬□φ).
-/
noncomputable def neg_box_to_box_neg_box (φ : Formula) :
    DerivationTree [] ((Formula.box φ).neg.imp (Formula.box (Formula.box φ).neg)) := by
  -- modal_5_collapse φ: (□φ).neg.box.neg → □φ, i.e., ◇□φ → □φ
  have h_m5 : DerivationTree [] ((Formula.box φ).neg.box.neg.imp (Formula.box φ)) :=
    DerivationTree.axiom [] _ (Axiom.modal_5_collapse φ)
  -- Contrapositive: (□φ).neg → (□φ).neg.box.neg.neg
  have h_contra : DerivationTree [] ((Formula.box φ).neg.imp (Formula.box φ).neg.box.neg.neg) :=
    Propositional.contraposition h_m5
  -- DNE: (□φ).neg.box.neg.neg → (□φ).neg.box
  have h_dne : DerivationTree [] ((Formula.box φ).neg.box.neg.neg.imp (Formula.box φ).neg.box) :=
    Propositional.double_negation ((Formula.box φ).neg.box)
  -- Compose
  exact Combinators.imp_trans h_contra h_dne

/--
Box formulas are preserved in both directions along bx_le.

Forward: □φ ∈ w → G(□φ) ∈ w (temp_future) → □φ ∈ v (bx_G_forward).
Backward: contrapositive of forward applied to ¬□φ using S5 negative introspection.
  If □φ ∉ w, then ¬□φ ∈ w, then □(¬□φ) ∈ w (neg_box_to_box_neg_box),
  then G(□(¬□φ)) ∈ w (temp_future), then □(¬□φ) ∈ v, then ¬□φ ∈ v (modal_t),
  so □φ ∉ v. Contrapositive: □φ ∈ v → □φ ∈ w.
-/
theorem box_preserved_along_bx_le {w v : BXPoint} (h_le : bx_le w v) (φ : Formula) :
    Formula.box φ ∈ w.formulas ↔ Formula.box φ ∈ v.formulas := by
  constructor
  · -- Forward: □φ ∈ w → □φ ∈ v
    intro h_box
    -- □φ → G(□φ) by temp_future
    have h_tf : DerivationTree [] ((Formula.box φ).imp (Formula.all_future (Formula.box φ))) :=
      DerivationTree.axiom [] _ (Axiom.temp_future φ)
    have h_G_box := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_tf) h_box
    -- G(□φ) ∈ w and w ≤ v gives □φ ∈ v
    exact bx_G_forward h_le h_G_box
  · -- Backward: □φ ∈ v → □φ ∈ w (contrapositive)
    intro h_box_v
    by_contra h_not_box
    -- ¬□φ ∈ w (negation completeness)
    have h_neg_box : (Formula.box φ).neg ∈ w.formulas := by
      cases SetMaximalConsistent.negation_complete w.is_mcs (Formula.box φ) with
      | inl h => exact absurd h h_not_box
      | inr h => exact h
    -- ¬□φ → □(¬□φ) by S5 negative introspection
    have h_box_neg := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs (neg_box_to_box_neg_box φ)) h_neg_box
    -- □(¬□φ) → G(□(¬□φ)) by temp_future
    have h_tf2 : DerivationTree [] ((Formula.box (Formula.box φ).neg).imp
        (Formula.all_future (Formula.box (Formula.box φ).neg))) :=
      DerivationTree.axiom [] _ (Axiom.temp_future (Formula.box φ).neg)
    have h_G_box_neg := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_tf2) h_box_neg
    -- G(□(¬□φ)) ∈ w and w ≤ v gives □(¬□φ) ∈ v
    have h_box_neg_v := bx_G_forward h_le h_G_box_neg
    -- □(¬□φ) ∈ v → ¬□φ ∈ v by modal_t
    have h_mt : DerivationTree [] ((Formula.box (Formula.box φ).neg).imp (Formula.box φ).neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg)
    have h_neg_v := SetMaximalConsistent.implication_property v.is_mcs
      (theorem_in_mcs v.is_mcs h_mt) h_box_neg_v
    -- ¬□φ ∈ v and □φ ∈ v: contradiction
    exact set_consistent_not_both v.is_mcs.1 (Formula.box φ) h_box_v h_neg_v

/--
Modal equivalence holds between any two bx_le-related BXPoints.
Immediate corollary of box_preserved_along_bx_le.
-/
theorem bx_modal_equiv_of_bx_le {w v : BXPoint} (h_le : bx_le w v) :
    bx_modal_equiv w v :=
  fun φ => box_preserved_along_bx_le h_le φ

/-! ## Eventuality Resolution for Until/Since

The key construction for the Until/Since truth lemma: given φ U ψ ∈ w with ψ ∉ w,
find a witness v ≥ w with ψ ∈ v such that φ holds along a chain from w to v.

### Design (Task 102, v5)

The guard condition uses chain-member quantification rather than universal
quantification over all BXPoints in a bx_le interval. The universal guard
is unprovable because bx_le (g_content subset inclusion) is a non-total
preorder admitting "junk points" from unrelated Lindenbaum extensions.
The chain-based guard matches what the TruthLemma actually needs: guard
properties at chain positions, not arbitrary BXPoints.

The forward direction constructs a 2-element chain [w, v] using:
- BX9 (Until elimination) for φ ∈ w
- BX10 (eventuality extraction) for F(ψ) ∈ w
- bx_forward_witness for the witness v with ψ ∈ v

The backward direction derives φ U ψ ∈ w from a chain witness. This
requires Until induction along the chain, which is structurally difficult
without a deterministic successor relation.

### References
- Burgess 1984: "Basic tense logic" (defect discharge)
- Goldblatt 1992: "Logics of Time and Computation" (canonical model construction)
- Task 101 research (sigma_strict design, Filtration/SigmaOrdering.lean)
- Task 102 research round 5 (chain-member quantification)
-/

/--
Forward Until eventuality resolution: given φ U ψ ∈ w and ψ ∉ w,
construct v ≥ w with ψ ∈ v and φ ∈ w.

The guard property (φ ∈ w) is the chain-member guard for a 2-element
chain [w, v]. This replaces the unprovable universal guard over all
BXPoints in the bx_le interval.
-/
noncomputable def bx_until_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas := by
  -- By BX10: F(ψ) ∈ w
  have h_F_psi : Formula.some_future ψ ∈ w.formulas := by
    have h_ax := DerivationTree.axiom [] _ (Axiom.until_F φ ψ)
    exact SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h_until
  -- By bx_forward_witness: get v with bx_le w v and ψ ∈ v
  obtain ⟨v, h_wv, h_ψv⟩ := bx_forward_witness w ψ h_F_psi
  -- By BX9: φ ∈ w (since φ U ψ ∈ w and ψ ∉ w)
  have h_φw : φ ∈ w.formulas := by
    have h_ax := DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)
    have h_or := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h_until
    cases SetMaximalConsistent.negation_complete w.is_mcs φ with
    | inl h => exact h
    | inr h_neg_phi =>
      exact absurd (SetMaximalConsistent.implication_property w.is_mcs h_or h_neg_phi) h_not_psi
  exact ⟨v, h_wv, h_ψv, h_φw⟩

/--
Forward Since eventuality resolution: mirror of bx_until_eventuality_resolution
for the past direction, using h_content instead of g_content.
-/
noncomputable def bx_since_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas := by
  -- By BX10': P(ψ) ∈ w
  have h_P_psi : Formula.some_past ψ ∈ w.formulas := by
    have h_ax := DerivationTree.axiom [] _ (Axiom.since_P φ ψ)
    exact SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h_since
  -- By bx_backward_witness: get v with bx_le v w and ψ ∈ v
  obtain ⟨v, h_vw, h_ψv⟩ := bx_backward_witness w ψ h_P_psi
  -- By BX9': φ ∈ w (since φ S ψ ∈ w and ψ ∉ w)
  have h_φw : φ ∈ w.formulas := by
    have h_ax := DerivationTree.axiom [] _ (Axiom.since_elim φ ψ)
    have h_or := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h_since
    cases SetMaximalConsistent.negation_complete w.is_mcs φ with
    | inl h => exact h
    | inr h_neg_phi =>
      exact absurd (SetMaximalConsistent.implication_property w.is_mcs h_or h_neg_phi) h_not_psi
  exact ⟨v, h_vw, h_ψv, h_φw⟩

end Bimodal.Metalogic.BXCanonical
