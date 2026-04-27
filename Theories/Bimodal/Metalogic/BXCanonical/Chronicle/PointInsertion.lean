import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleTypes
import Bimodal.Metalogic.BXCanonical.Chronicle.RRelation
import Bimodal.Theorems.TemporalDerived

/-!
# Point Insertion Lemmas (Burgess 2.4-2.8)

Implements the core point insertion machinery for the Burgess chronicle
construction, adapted for strict (irreflexive) temporal semantics on the
`irr_until` branch.

## Key Adaptations from Burgess 1982

Burgess uses axioms A3a and A4a which are **not valid** under strict semantics
(see counterexample in `TemporalDerived.lean`). We replace them with BX axioms:

- **A3a's role** (Lemma 2.4 seed consistency): BX4 (`connect_future: φ → G(P(φ))`)
  + BX5 (`self_accum_until`) provide the algebraic content directly.
- **A4a's role** (Lemma 2.6 point insertion): BX5 + BX6 (`absorb_until`)
  + BX7 (`linear_until`) provide the needed structural properties.

## Strict Semantics Considerations

Under strict Until semantics with half-open guard [t,s):
- U(γ,β) at t means ∃s>t, β(s) ∧ ∀u∈[t,s), γ(u)
- The guard γ covers the current point t but NOT the witness point s
- BX9 (until_elim) gives γ ∨ β at t (guard covers current point)
- The witness point only has β, not necessarily γ

This means Burgess's Lemma 2.4 must be adapted: we produce an endpoint MCS
with β and g_content(A), plus evidence that U(γ,β) was active in the past
(via BX4: connect_future). The guard γ is handled by the interval DCS
construction in Phase 4.

## Definitions

Local definitions used for point insertion lemmas.

## Main Results

- `lemma_2_4`: Until witness endpoint construction
- `lemma_2_5b`: Composition of g_content ordering (transitivity)
- `lemma_2_6`: Counterexample insertion (delta not in C -> insert D with neg delta)
- `lemma_2_7_guard`: Guard extraction at current point from Until
- `BurgessR3Maximal_maximality_combined`: Maximality witness for content-based splitting

### Withdrawn (Phase 3, Task 107)

- `lemma_2_6_strong`: FALSE under strict semantics (g_content(D) <= C unprovable)
- `lemma_2_7`: FALSE under strict semantics (D2 branch cannot produce xi at future MCS)
- `lemma_2_8`: Depends on `lemma_2_7`; also has false D2-style reasoning

## References

- Burgess 1982: "Basic tense logic", Section 2, Lemmas 2.4-2.8
- Task 107 implementation plan, Phase 3
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.TemporalDerived

/-! ## Helper: F(neg phi) from G(phi) not in A

A common pattern: if G(φ) ∉ MCS A, then F(¬φ) ∈ A.
This requires going through double-negation elimination under G,
since F(¬φ) = ¬G(¬¬φ) which is not definitionally equal to ¬G(φ).
-/

/-- If G(φ) ∉ MCS A, then F(¬φ) ∈ A. -/
theorem F_neg_of_G_not {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ : Formula)
    (h_Gφ_not : Formula.all_future φ ∉ A) :
    Formula.some_future φ.neg ∈ A := by
  have h_G_nnφ_not : Formula.all_future φ.neg.neg ∉ A := by
    intro h_G_nnφ
    have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    have h_G_dne : DerivationTree [] (Formula.all_future (φ.neg.neg.imp φ)) :=
      DerivationTree.temporal_necessitation _ h_dne
    have h_kd : DerivationTree [] ((φ.neg.neg.imp φ).all_future.imp
        (φ.neg.neg.all_future.imp φ.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist φ.neg.neg φ)
    have h1 := theorem_in_mcs h_mcs h_G_dne
    have h2 := theorem_in_mcs h_mcs h_kd
    have h3 := SetMaximalConsistent.implication_property h_mcs h2 h1
    have h_Gφ := SetMaximalConsistent.implication_property h_mcs h3 h_G_nnφ
    exact h_Gφ_not h_Gφ
  rcases SetMaximalConsistent.negation_complete h_mcs
      (Formula.all_future φ.neg.neg) with h | h
  · exact absurd h h_G_nnφ_not
  · exact h

/-- If H(φ) ∉ MCS A, then P(¬φ) ∈ A. Dual of `F_neg_of_G_not`. -/
theorem P_neg_of_H_not {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ : Formula)
    (h_Hφ_not : Formula.all_past φ ∉ A) :
    Formula.some_past φ.neg ∈ A := by
  have h_H_nnφ_not : Formula.all_past φ.neg.neg ∉ A := by
    intro h_H_nnφ
    have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    have h_H_dne : DerivationTree [] (Formula.all_past (φ.neg.neg.imp φ)) :=
      Bimodal.Theorems.past_necessitation _ h_dne
    have h_kd : DerivationTree [] ((φ.neg.neg.imp φ).all_past.imp
        (φ.neg.neg.all_past.imp φ.all_past)) :=
      Bimodal.Theorems.past_k_dist φ.neg.neg φ
    have h1 := theorem_in_mcs h_mcs h_H_dne
    have h2 := theorem_in_mcs h_mcs h_kd
    have h3 := SetMaximalConsistent.implication_property h_mcs h2 h1
    have h_Hφ := SetMaximalConsistent.implication_property h_mcs h3 h_H_nnφ
    exact h_Hφ_not h_Hφ
  rcases SetMaximalConsistent.negation_complete h_mcs
      (Formula.all_past φ.neg.neg) with h | h
  · exact absurd h h_H_nnφ_not
  · exact h

/-! ## Lemma 2.4: Until Witness Endpoint Construction -/

/-- The Until witness seed: {β} ∪ g_content(A) is consistent when
U(γ,β) ∈ MCS A. -/
theorem until_witness_seed_consistent {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    SetConsistent ({β} ∪ g_content A) := by
  have h_F_β : Formula.some_future β ∈ A := by
    have h_ax : DerivationTree [] ((Formula.untl γ β).imp (Formula.some_future β)) :=
      DerivationTree.axiom [] _ (Axiom.until_F γ β)
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_ax) h_until
  exact forward_temporal_witness_seed_consistent A h_mcs β h_F_β

/-- **Lemma 2.4** (adapted for strict semantics): Given MCS A with U(γ, β) ∈ A,
there exists MCS C with β ∈ C, g_content(A) ⊆ C, and P(U(γ,β)) ∈ C. -/
noncomputable def lemma_2_4 {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    ∃ C : Set Formula, SetMaximalConsistent C ∧
      β ∈ C ∧ g_content A ⊆ C ∧
      Formula.some_past (Formula.untl γ β) ∈ C := by
  have h_seed_cons := until_witness_seed_consistent h_mcs γ β h_until
  obtain ⟨C, h_sup, h_C_mcs⟩ := set_lindenbaum _ h_seed_cons
  have h_β_C : β ∈ C := h_sup (Set.mem_union_left _ (Set.mem_singleton β))
  have h_g_sub : g_content A ⊆ C := fun χ hχ => h_sup (Set.mem_union_right _ hχ)
  have h_GP : Formula.all_future (Formula.some_past (Formula.untl γ β)) ∈ A := by
    have h_ax : DerivationTree [] ((Formula.untl γ β).imp
        (Formula.all_future (Formula.some_past (Formula.untl γ β)))) :=
      DerivationTree.axiom [] _ (Axiom.connect_future (Formula.untl γ β))
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_ax) h_until
  have h_P_until_C : Formula.some_past (Formula.untl γ β) ∈ C :=
    h_g_sub h_GP
  exact ⟨C, h_C_mcs, h_β_C, h_g_sub, h_P_until_C⟩

/-! ## BX9 Guard Extraction -/

/-- BX9 at MCS level: U(γ,β) ∈ A implies either γ ∈ A or β ∈ A. -/
theorem until_elim_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    γ ∈ A ∨ β ∈ A := by
  have h_ax : DerivationTree [] ((Formula.untl γ β).imp (Formula.or γ β)) :=
    DerivationTree.axiom [] _ (Axiom.until_elim γ β)
  have h_or : Formula.or γ β ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_ax) h_until
  rcases SetMaximalConsistent.negation_complete h_mcs γ with h_γ | h_neg_γ
  · exact Or.inl h_γ
  · exact Or.inr (SetMaximalConsistent.implication_property h_mcs h_or h_neg_γ)

/-- BX10 at MCS level: U(γ,β) ∈ A implies F(β) ∈ A. -/
theorem until_F_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    Formula.some_future β ∈ A := by
  have h_ax : DerivationTree [] ((Formula.untl γ β).imp (Formula.some_future β)) :=
    DerivationTree.axiom [] _ (Axiom.until_F γ β)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_until

/-- BX5 at MCS level: U(γ,β) ∈ A implies U(γ∧U(γ,β), β) ∈ A. -/
theorem self_accum_until_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    Formula.untl (Formula.and γ (Formula.untl γ β)) β ∈ A := by
  have h_ax : DerivationTree [] ((Formula.untl γ β).imp
      (Formula.untl (Formula.and γ (Formula.untl γ β)) β)) :=
    DerivationTree.axiom [] _ (Axiom.self_accum_until γ β)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_until

/-- BX4 at MCS level: φ ∈ A implies G(P(φ)) ∈ A. -/
theorem connect_future_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ : Formula)
    (h_φ : φ ∈ A) :
    Formula.all_future (Formula.some_past φ) ∈ A := by
  have h_ax : DerivationTree [] (φ.imp (Formula.all_future (Formula.some_past φ))) :=
    DerivationTree.axiom [] _ (Axiom.connect_future φ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_φ

/-- Conjunction introduction at MCS level. -/
theorem conj_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ ψ : Formula)
    (h_φ : φ ∈ A) (h_ψ : ψ ∈ A) :
    Formula.and φ ψ ∈ A := by
  rcases SetMaximalConsistent.negation_complete h_mcs (φ.imp ψ.neg) with h | h
  · have h_neg_ψ := SetMaximalConsistent.implication_property h_mcs h h_φ
    exact absurd h_ψ (SetMaximalConsistent.neg_excludes h_mcs _ h_neg_ψ)
  · exact h

/-! ## Lemma 2.5: g_content Ordering Composition -/

/-- **Lemma 2.5** (composition): g_content ordering is transitive. -/
theorem lemma_2_5b {A D C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_AD : g_content A ⊆ D) (h_DC : g_content D ⊆ C) :
    g_content A ⊆ C := by
  intro φ hφ
  have h_GGφ : Formula.all_future (Formula.all_future φ) ∈ A :=
    SetMaximalConsistent.all_future_all_future h_mcs_A hφ
  have h_Gφ_D : Formula.all_future φ ∈ D := h_AD h_GGφ
  exact h_DC h_Gφ_D

/-- Dual of lemma_2_5b: h_content ordering is transitive (past direction). -/
theorem lemma_2_5b_past {A D C : Set Formula}
    (h_mcs_C : SetMaximalConsistent C)
    (h_CD : h_content C ⊆ D) (h_DA : h_content D ⊆ A) :
    h_content C ⊆ A := by
  intro φ hφ
  have h_HHφ : Formula.all_past (Formula.all_past φ) ∈ C :=
    SetMaximalConsistent.all_past_all_past h_mcs_C hφ
  have h_Hφ_D : Formula.all_past φ ∈ D := h_CD h_HHφ
  exact h_DA h_Hφ_D

/-! ## Lemma 2.6: Counterexample Insertion (Negative Insertion) -/

/-- **Lemma 2.6** (adapted): Given MCS A and C with g_content(A) ⊆ C,
if δ ∉ C, then there exists MCS D with ¬δ ∈ D and g_content(A) ⊆ D. -/
noncomputable def lemma_2_6 {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_g_AC : g_content A ⊆ C)
    (δ : Formula)
    (h_δ_not_C : δ ∉ C) :
    ∃ D : Set Formula, SetMaximalConsistent D ∧
      δ.neg ∈ D ∧ g_content A ⊆ D := by
  have h_Gδ_not_A : Formula.all_future δ ∉ A := by
    intro h_Gδ; exact h_δ_not_C (h_g_AC h_Gδ)
  have h_F_neg_δ := F_neg_of_G_not h_mcs_A δ h_Gδ_not_A
  have h_seed_cons := forward_temporal_witness_seed_consistent A h_mcs_A δ.neg h_F_neg_δ
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed_cons
  exact ⟨D, h_D_mcs,
    h_sup (Set.mem_union_left _ (Set.mem_singleton _)),
    fun χ hχ => h_sup (Set.mem_union_right _ hχ)⟩

/-! ### Withdrawn Lemmas

See module docstring for details on withdrawn lemma_2_6_strong, lemma_2_7, lemma_2_8.
-/

/-- Guard extraction: U(ξ,η) ∈ A with η ∉ A implies ξ ∈ A. -/
theorem lemma_2_7_guard {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ A)
    (h_η_not : η ∉ A) :
    ξ ∈ A := by
  rcases until_elim_mcs h_mcs ξ η h_until with h | h
  · exact h
  · exact absurd h h_η_not

/-- Conjunction membership gives left component in MCS. -/
theorem conj_left_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ ψ : Formula)
    (h_conj : Formula.and φ ψ ∈ A) :
    φ ∈ A := by
  have h_ax : DerivationTree [] ((Formula.and φ ψ).imp φ) := lce_imp φ ψ
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_conj

/-- Conjunction membership gives right component in MCS. -/
theorem conj_right_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ ψ : Formula)
    (h_conj : Formula.and φ ψ ∈ A) :
    ψ ∈ A := by
  have h_ax : DerivationTree [] ((Formula.and φ ψ).imp ψ) := rce_imp φ ψ
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_conj

/-! ## G/H Implies F/P (Seriality + BX3 + BX10/BX12) -/

/-- In an MCS, G(α) implies F(α). Uses seriality + BX3 + BX10 + BX12. -/
theorem G_implies_F_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (α : Formula)
    (h_G : Formula.all_future α ∈ A) :
    Formula.some_future α ∈ A := by
  set top := Formula.bot.imp Formula.bot with top_def
  have h_weak : DerivationTree [] (Formula.imp α (Formula.imp top α)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s α top)
  have h_G_top_α : Formula.all_future (Formula.imp top α) ∈ A := by
    have h1 := theorem_in_mcs h_mcs (DerivationTree.temporal_necessitation _ h_weak)
    have h2 := theorem_in_mcs h_mcs
      (DerivationTree.axiom [] _ (Axiom.temp_k_dist α (Formula.imp top α)))
    exact SetMaximalConsistent.implication_property h_mcs
      (SetMaximalConsistent.implication_property h_mcs h2 h1) h_G
  have h_top_in : top ∈ A :=
    theorem_in_mcs h_mcs (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_F_top : Formula.some_future top ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.serial_future)) h_top_in
  have h_TUT : Formula.untl top top ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.F_until_equiv top))) h_F_top
  have h_TUα : Formula.untl top α ∈ A := by
    have h1 := SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.right_mono_until top α top)))
      h_G_top_α
    exact SetMaximalConsistent.implication_property h_mcs h1 h_TUT
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.until_F top α))) h_TUα

/-- In an MCS, H(α) implies P(α). Mirror of G_implies_F_mcs. -/
theorem H_implies_P_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (α : Formula)
    (h_H : Formula.all_past α ∈ A) :
    Formula.some_past α ∈ A := by
  set top := Formula.bot.imp Formula.bot with top_def
  have h_weak : DerivationTree [] (Formula.imp α (Formula.imp top α)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s α top)
  have h_H_top_α : Formula.all_past (Formula.imp top α) ∈ A := by
    have h1 := theorem_in_mcs h_mcs (Bimodal.Theorems.past_necessitation _ h_weak)
    have h2 := theorem_in_mcs h_mcs (Bimodal.Theorems.past_k_dist α (Formula.imp top α))
    exact SetMaximalConsistent.implication_property h_mcs
      (SetMaximalConsistent.implication_property h_mcs h2 h1) h_H
  have h_top_in : top ∈ A :=
    theorem_in_mcs h_mcs (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_P_top : Formula.some_past top ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.serial_past)) h_top_in
  have h_TST : Formula.snce top top ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.P_since_equiv top))) h_P_top
  have h_TSα : Formula.snce top α ∈ A := by
    have h1 := SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.right_mono_since top α top)))
      h_H_top_α
    exact SetMaximalConsistent.implication_property h_mcs h1 h_TST
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.since_P top α))) h_TSα

/-- G-propagation seed consistency. -/
theorem g_propagation_seed_consistent {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (α : Formula)
    (h_G : Formula.all_future α ∈ A) :
    SetConsistent (forward_temporal_witness_seed A α) := by
  exact forward_temporal_witness_seed_consistent A h_mcs α (G_implies_F_mcs h_mcs α h_G)

/-- G-propagation insertion: given G(α) ∈ f(x), produce MCS D with α ∈ D
and g_content(f(x)) ⊆ D. -/
noncomputable def g_propagation_witness {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (α : Formula)
    (h_G : Formula.all_future α ∈ A) :
    ∃ D : Set Formula, SetMaximalConsistent D ∧ α ∈ D ∧ g_content A ⊆ D := by
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ (g_propagation_seed_consistent h_mcs α h_G)
  exact ⟨D, h_D_mcs,
    h_sup (Set.mem_union_left _ (Set.mem_singleton _)),
    fun χ hχ => h_sup (Set.mem_union_right _ hχ)⟩

/-! ## Seed Consistency for DCS Extension -/

/-- If S is a DCS and φ ∉ S, then {φ.neg} ∪ S is consistent. -/
theorem dcs_neg_union_consistent {S : Set Formula} (h_dcs : SetDeductivelyClosed S)
    {φ : Formula} (h_not : φ ∉ S) :
    SetConsistent ({φ.neg} ∪ S) := by
  intro L hL ⟨d⟩
  apply h_not
  by_cases h_neg_in_L : φ.neg ∈ L
  · have d_ext : DerivationTree (φ.neg :: L) Formula.bot :=
      DerivationTree.weakening L (φ.neg :: L) Formula.bot d (List.subset_cons_of_subset _ (List.Subset.refl L))
    have d_imp : DerivationTree L φ.neg.neg :=
      deduction_theorem L φ.neg Formula.bot d_ext
    have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    have d_phi : DerivationTree L φ :=
      DerivationTree.modus_ponens L φ.neg.neg φ
        (DerivationTree.weakening [] L (φ.neg.neg.imp φ) h_dne (List.nil_subset L)) d_imp
    set M := L.filter (fun x => !decide (x = φ.neg)) with hM_def
    have hM_sub_S : ∀ ψ ∈ M, ψ ∈ S := by
      intro ψ hψ; rw [hM_def] at hψ
      have h_mem := List.mem_filter.mp hψ
      have h1 : ψ ∈ L := h_mem.1
      have h2 : ψ ≠ φ.neg := by simp at h_mem; exact h_mem.2
      rcases hL ψ h1 with h_sing | h_S
      · exact absurd (Set.mem_singleton_iff.mp h_sing) h2
      · exact h_S
    have hL_sub : L ⊆ φ.neg :: M := by
      intro x hx
      by_cases heq : x = φ.neg
      · subst heq; exact .head M
      · exact .tail _ (List.mem_filter.mpr ⟨hx, by simp; exact heq⟩)
    have d_phi_w : DerivationTree (φ.neg :: M) φ :=
      DerivationTree.weakening L (φ.neg :: M) φ d_phi hL_sub
    have d_neg_imp : DerivationTree M (φ.neg.imp φ) :=
      deduction_theorem M φ.neg φ d_phi_w
    have h_peirce : DerivationTree [] ((φ.neg.imp φ).imp φ) := by
      have s1 : DerivationTree [φ.neg, φ.neg.imp φ] φ :=
        DerivationTree.modus_ponens [φ.neg, φ.neg.imp φ] φ.neg φ
          (DerivationTree.assumption _ (φ.neg.imp φ) (by simp))
          (DerivationTree.assumption _ φ.neg (by simp))
      have s2 : DerivationTree [φ.neg, φ.neg.imp φ] Formula.bot :=
        DerivationTree.modus_ponens [φ.neg, φ.neg.imp φ] φ Formula.bot
          (DerivationTree.assumption _ φ.neg (by simp)) s1
      have s3 := deduction_theorem [φ.neg.imp φ] φ.neg Formula.bot s2
      have s4 : DerivationTree [φ.neg.imp φ] φ :=
        DerivationTree.modus_ponens [φ.neg.imp φ] φ.neg.neg φ
          (DerivationTree.weakening [] [φ.neg.imp φ] (φ.neg.neg.imp φ) h_dne (List.nil_subset _)) s3
      exact deduction_theorem [] (φ.neg.imp φ) φ s4
    have d_phi_M : DerivationTree M φ :=
      DerivationTree.modus_ponens M (φ.neg.imp φ) φ
        (DerivationTree.weakening [] M ((φ.neg.imp φ).imp φ) h_peirce (List.nil_subset M)) d_neg_imp
    exact h_dcs.2 M φ hM_sub_S d_phi_M
  · have hL_S : ∀ ψ ∈ L, ψ ∈ S := by
      intro ψ hψ
      have h_mem := hL ψ hψ
      rcases h_mem with h_sing | h_S
      · have : ψ = φ.neg := Set.mem_singleton_iff.mp h_sing
        exact absurd (this ▸ hψ) h_neg_in_L
      · exact h_S
    exact absurd (h_dcs.1 L hL_S ⟨d⟩) (not_false)

/-! ## R3Maximal Properties -/

/-- R3Maximal negation completeness: δ ∉ B implies δ.neg ∈ B. -/
theorem r3Maximal_neg_of_not_mem {A B C : Set Formula}
    (h_R3 : R3Maximal A B C) (δ : Formula) (h_not : δ ∉ B) :
    δ.neg ∈ B := by
  by_contra h_neg_not
  have h_cons := dcs_neg_union_consistent h_R3.1 h_not
  have h_dc_dcs := deductiveClosure_is_dcs h_cons
  have h_B_sub : B ⊆ deductiveClosure ({δ.neg} ∪ B) :=
    fun φ hφ => subset_deductiveClosure _ (Set.mem_union_right _ hφ)
  have h_neg_in : δ.neg ∈ deductiveClosure ({δ.neg} ∪ B) :=
    subset_deductiveClosure _ (Set.mem_union_left _ (Set.mem_singleton δ.neg))
  have h_proper : B ⊂ deductiveClosure ({δ.neg} ∪ B) :=
    ⟨h_B_sub, fun h_eq => h_neg_not (h_eq h_neg_in)⟩
  have h_r3 : r3Relation A (deductiveClosure ({δ.neg} ∪ B)) C :=
    r3Relation_subset h_R3.2.1 h_B_sub
  exact h_R3.2.2 _ h_dc_dcs h_proper h_r3

/-- R3Maximal forces MCS (via monotonicity of r3Relation). -/
theorem R3Maximal_is_mcs {A B C : Set Formula}
    (h_R3 : R3Maximal A B C) : SetMaximalConsistent B := by
  refine ⟨h_R3.1.1, ?_⟩
  intro φ h_not_φ h_cons_insert
  have h_cons : SetConsistent ({φ} ∪ B) := by rwa [Set.insert_eq] at h_cons_insert
  have h_dc_dcs := deductiveClosure_is_dcs h_cons
  have h_B_sub : B ⊆ deductiveClosure ({φ} ∪ B) :=
    fun ψ hψ => subset_deductiveClosure _ (Set.mem_union_right _ hψ)
  have h_φ_in : φ ∈ deductiveClosure ({φ} ∪ B) :=
    subset_deductiveClosure _ (Set.mem_union_left _ (Set.mem_singleton φ))
  exact h_R3.2.2 _ h_dc_dcs ⟨h_B_sub, fun h_eq => h_not_φ (h_eq h_φ_in)⟩
    (r3Relation_subset h_R3.2.1 h_B_sub)

/-- An MCS has no proper DCS extension. -/
theorem mcs_no_proper_dcs_extension {B D : Set Formula}
    (h_mcs : SetMaximalConsistent B) (h_dcs : SetDeductivelyClosed D)
    (hBD : B ⊂ D) : False := by
  obtain ⟨φ, h_φ_D, h_φ_not_B⟩ := Set.not_subset.mp hBD.2
  have h_incons := h_mcs.2 φ h_φ_not_B
  apply h_incons
  intro L hL ⟨d⟩
  exact h_dcs.1 L (fun ψ hψ => (Set.insert_subset h_φ_D hBD.1) (hL ψ hψ)) ⟨d⟩

/-- rRelation is reflexive for MCS. -/
theorem rRelation_self_mcs {B : Set Formula}
    (h_mcs : SetMaximalConsistent B) : rRelation B B := by
  intro γ δ h_until
  rcases SetMaximalConsistent.negation_complete h_mcs γ with h_γ | h_neg_γ
  · exact Or.inr ⟨h_γ, h_until⟩
  · exact Or.inl (SetMaximalConsistent.implication_property h_mcs
      (until_disjunction_in_mcs h_mcs h_until) h_neg_γ)

/-- rRelationSince is reflexive for MCS. -/
theorem rRelationSince_self_mcs {B : Set Formula}
    (h_mcs : SetMaximalConsistent B) : rRelationSince B B := by
  intro γ δ h_since
  rcases SetMaximalConsistent.negation_complete h_mcs γ with h_γ | h_neg_γ
  · exact Or.inr ⟨h_γ, h_since⟩
  · exact Or.inl (SetMaximalConsistent.implication_property h_mcs
      (since_disjunction_in_mcs h_mcs h_since) h_neg_γ)

/-! ## Full Lemma 2.6: Three-Way Decomposition (for obligation-based R3Maximal) -/

/-- **Full Lemma 2.6** (Burgess 1982): Three-way decomposition for R3Maximal.
Simplified by R3Maximal_is_mcs: all witnesses are B itself. -/
noncomputable def lemma_2_6_full {A C : Set Formula}
    (_h_mcs_A : SetMaximalConsistent A)
    (_h_mcs_C : SetMaximalConsistent C)
    {B : Set Formula}
    (h_R3 : R3Maximal A B C)
    (δ : Formula)
    (h_δ_not_B : δ ∉ B) :
    ∃ (D B' B'' : Set Formula),
      SetMaximalConsistent D ∧
      δ.neg ∈ D ∧
      B ⊆ D ∧
      B ⊆ B' ∧
      B ⊆ B'' ∧
      R3Maximal A B' D ∧
      R3Maximal D B'' C := by
  have h_mcs_B := R3Maximal_is_mcs h_R3
  have h_neg_δ : δ.neg ∈ B := by
    rcases SetMaximalConsistent.negation_complete h_mcs_B δ with h | h
    · exact absurd h h_δ_not_B
    · exact h
  have h_dcs := mcs_is_dcs h_mcs_B
  refine ⟨B, B, B, h_mcs_B, h_neg_δ, le_refl _, le_refl _, le_refl _, ?_, ?_⟩
  · exact ⟨h_dcs, ⟨h_R3.2.1.1, rRelationSince_self_mcs h_mcs_B⟩,
      fun D hD_dcs hBD _ => mcs_no_proper_dcs_extension h_mcs_B hD_dcs hBD⟩
  · exact ⟨h_dcs, ⟨rRelation_self_mcs h_mcs_B, h_R3.2.1.2⟩,
      fun D hD_dcs hBD _ => mcs_no_proper_dcs_extension h_mcs_B hD_dcs hBD⟩

/-! ## Burgess Lemma 2.6 for BurgessR3Maximal (Content-Based)

The content-based BurgessR3Maximal is ANTI-monotone in B (adding elements to B
adds more requirements on A and C), so B is a genuinely non-MCS DCS in general.
The maximality witness lemma proves that if delta not in B, then some extension
of B by delta violates burgessR3, which is the key to the splitting construction.
-/

/--
Helper: If L is a subset of {delta} union B with B a DCS, and L derives phi, then either
phi is in B, or there exists beta in B with a theorem (beta AND delta) implies phi.
-/
theorem dc_delta_B_controlled {B : Set Formula} (h_dcs : SetDeductivelyClosed B)
    {delta phi : Formula} {L : List Formula}
    (hL_sub : ∀ psi ∈ L, psi ∈ ({delta} : Set Formula) ∪ B)
    (hL_deriv : DerivationTree L phi) :
    (phi ∈ B) ∨ (∃ beta ∈ B, Nonempty (DerivationTree [] ((Formula.and beta delta).imp phi))) := by
  haveI : ∀ x : Formula, Decidable (x ∈ B) := fun x => Classical.propDecidable _
  by_cases h_delta_L : delta ∈ L
  · let L_B := L.filter (· ∈ B)
    have hL_sub_dB : L ⊆ delta :: L_B := by
      intro psi hpsi
      by_cases h_B : psi ∈ B
      · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hpsi, decide_eq_true_eq.mpr h_B⟩)
      · rcases hL_sub psi hpsi with h | h
        · rw [Set.mem_singleton_iff.mp h]; exact .head _
        · exact absurd h h_B
    have d_w : DerivationTree (delta :: L_B) phi :=
      DerivationTree.weakening L (delta :: L_B) phi hL_deriv hL_sub_dB
    have d_imp := deduction_theorem L_B delta phi d_w
    have hLB_sub : ∀ psi ∈ L_B, psi ∈ B := by
      intro psi hpsi; exact decide_eq_true_eq.mp (List.mem_filter.mp hpsi).2
    by_cases hLB_empty : L_B = []
    · rw [hLB_empty] at d_imp
      have h_top_B : (Formula.bot.imp Formula.bot) ∈ B :=
        dcs_contains_theorems h_dcs (Bimodal.Theorems.Combinators.identity Formula.bot)
      exact Or.inr ⟨Formula.bot.imp Formula.bot, h_top_B, ⟨Bimodal.Theorems.Combinators.imp_trans
        (Bimodal.Theorems.Propositional.rce_imp (Formula.bot.imp Formula.bot) delta) d_imp⟩⟩
    · have h_imp_B : delta.imp phi ∈ B := h_dcs.2 L_B _ hLB_sub d_imp
      right
      refine ⟨delta.imp phi, h_imp_B, ⟨?_⟩⟩
      have h_l : DerivationTree [(Formula.and (delta.imp phi) delta)] (delta.imp phi) :=
        DerivationTree.modus_ponens [(Formula.and (delta.imp phi) delta)]
          (Formula.and (delta.imp phi) delta) (delta.imp phi)
          (DerivationTree.weakening [] [(Formula.and (delta.imp phi) delta)] _
            (Bimodal.Theorems.Propositional.lce_imp (delta.imp phi) delta) (List.nil_subset _))
          (DerivationTree.assumption _ _ (by simp))
      have h_r : DerivationTree [(Formula.and (delta.imp phi) delta)] delta :=
        DerivationTree.modus_ponens [(Formula.and (delta.imp phi) delta)]
          (Formula.and (delta.imp phi) delta) delta
          (DerivationTree.weakening [] [(Formula.and (delta.imp phi) delta)] _
            (Bimodal.Theorems.Propositional.rce_imp (delta.imp phi) delta) (List.nil_subset _))
          (DerivationTree.assumption _ _ (by simp))
      have h_mp : DerivationTree [(Formula.and (delta.imp phi) delta)] phi :=
        DerivationTree.modus_ponens [(Formula.and (delta.imp phi) delta)] delta phi h_l h_r
      exact deduction_theorem [] (Formula.and (delta.imp phi) delta) phi h_mp
  · left
    have hL_B : ∀ psi ∈ L, psi ∈ B := by
      intro psi hpsi
      rcases hL_sub psi hpsi with h | h
      · exact absurd (Set.mem_singleton_iff.mp h ▸ hpsi) h_delta_L
      · exact h
    exact h_dcs.2 L phi hL_B hL_deriv

/-- If BurgessR3Maximal(A, B, C) and delta not in B, the deductive closure of
{delta} union B does NOT satisfy burgessR3(A, -, C) (when consistent). -/
theorem BurgessR3Maximal_extension_fails {A B C : Set Formula}
    (h_R3M : BurgessR3Maximal A B C)
    {delta : Formula} (h_delta_not : delta ∉ B)
    (h_cons : SetConsistent ({delta} ∪ B)) :
    ¬burgessR3 A (deductiveClosure ({delta} ∪ B)) C := by
  intro h_r3
  have h_dc := deductiveClosure_is_dcs h_cons
  have h_sub : B ⊆ deductiveClosure ({delta} ∪ B) :=
    fun phi hphi => subset_deductiveClosure _ (Set.mem_union_right _ hphi)
  have h_delta_in : delta ∈ deductiveClosure ({delta} ∪ B) :=
    subset_deductiveClosure _ (Set.mem_union_left _ (Set.mem_singleton delta))
  have h_proper : B ⊂ deductiveClosure ({delta} ∪ B) :=
    ⟨h_sub, fun h_eq => h_delta_not (h_eq h_delta_in)⟩
  exact h_R3M.2.2 _ h_dc h_proper h_r3

/-- If both until and since conditions hold for delta extension of B,
then DC({delta} union B) satisfies burgessR3(A, -, C). -/
theorem dc_delta_B_burgessR3 {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_dcs : SetDeductivelyClosed B)
    (h_r3 : burgessR3 A B C)
    {delta : Formula}
    (h_until_all : ∀ beta ∈ B, ∀ gamma ∈ C, Formula.untl (Formula.and beta delta) gamma ∈ A)
    (h_since_all : ∀ beta ∈ B, ∀ alpha ∈ A, Formula.snce (Formula.and beta delta) alpha ∈ C) :
    burgessR3 A (deductiveClosure ({delta} ∪ B)) C := by
  constructor
  · intro phi hphi gamma hgamma
    obtain ⟨L, hL_sub, ⟨d⟩⟩ := hphi
    rcases dc_delta_B_controlled h_dcs hL_sub d with h_B | ⟨beta, hbeta, ⟨h_impl⟩⟩
    · exact h_r3.1 phi h_B gamma hgamma
    · exact untl_left_mono_thm h_mcs_A h_impl (h_until_all beta hbeta gamma hgamma)
  · intro phi hphi alpha halpha
    obtain ⟨L, hL_sub, ⟨d⟩⟩ := hphi
    rcases dc_delta_B_controlled h_dcs hL_sub d with h_B | ⟨beta, hbeta, ⟨h_impl⟩⟩
    · exact h_r3.2 phi h_B alpha halpha
    · exact snce_left_mono_thm h_mcs_C h_impl (h_since_all beta hbeta alpha halpha)

/--
**BurgessR3Maximal maximality witness**: If BurgessR3Maximal(A, B, C) and delta not in B,
then NOT both of:
- for all beta in B, gamma in C: untl(beta AND delta, gamma) in A
- for all beta in B, alpha in A: snce(beta AND delta, alpha) in C
-/
theorem BurgessR3Maximal_maximality_combined {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_R3M : BurgessR3Maximal A B C)
    {delta : Formula} (h_delta_not : delta ∉ B) :
    ¬((∀ beta ∈ B, ∀ gamma ∈ C, Formula.untl (Formula.and beta delta) gamma ∈ A) ∧
      (∀ beta ∈ B, ∀ alpha ∈ A, Formula.snce (Formula.and beta delta) alpha ∈ C)) := by
  intro ⟨h_until_all, h_since_all⟩
  have h_dcs := h_R3M.1
  by_cases h_neg_delta_B : delta.neg ∈ B
  · -- delta.neg in B: untl(delta.neg AND delta, gamma) in A for all gamma in C.
    -- Since (delta.neg AND delta) derives bot, by BX2: untl(bot, gamma) in A.
    -- By until_guard: bot in A, contradiction.
    have h_contr : DerivationTree [] ((Formula.and delta.neg delta).imp Formula.bot) := by
      have d1 : DerivationTree [Formula.and delta.neg delta] delta.neg :=
        DerivationTree.modus_ponens [Formula.and delta.neg delta]
          (Formula.and delta.neg delta) delta.neg
          (DerivationTree.weakening [] [Formula.and delta.neg delta] _
            (Bimodal.Theorems.Propositional.lce_imp delta.neg delta) (List.nil_subset _))
          (DerivationTree.assumption _ _ (by simp))
      have d2 : DerivationTree [Formula.and delta.neg delta] delta :=
        DerivationTree.modus_ponens [Formula.and delta.neg delta]
          (Formula.and delta.neg delta) delta
          (DerivationTree.weakening [] [Formula.and delta.neg delta] _
            (Bimodal.Theorems.Propositional.rce_imp delta.neg delta) (List.nil_subset _))
          (DerivationTree.assumption _ _ (by simp))
      have d3 : DerivationTree [Formula.and delta.neg delta] Formula.bot :=
        DerivationTree.modus_ponens [Formula.and delta.neg delta] delta Formula.bot d1 d2
      exact deduction_theorem [] (Formula.and delta.neg delta) Formula.bot d3
    have h_top_C : (Formula.bot.imp Formula.bot) ∈ C :=
      theorem_in_mcs h_mcs_C (Bimodal.Theorems.Combinators.identity Formula.bot)
    have h_utl := h_until_all delta.neg h_neg_delta_B _ h_top_C
    have h_utl_bot := untl_left_mono_thm h_mcs_A h_contr h_utl
    have h_bot : Formula.bot ∈ A := until_guard_in_mcs h_mcs_A h_utl_bot
    exact h_mcs_A.1 [Formula.bot]
      (fun psi hpsi => by simp at hpsi; exact hpsi ▸ h_bot)
      ⟨DerivationTree.assumption _ _ (by simp)⟩
  · -- delta.neg not in B: {delta} union B is consistent
    have h_cons : SetConsistent ({delta} ∪ B) := by
      haveI : ∀ x : Formula, Decidable (x ∈ B) := fun x => Classical.propDecidable _
      intro L hL_sub ⟨d⟩
      by_cases h_delta_L : delta ∈ L
      · let L_B := L.filter (· ∈ B)
        have hL_sub' : L ⊆ delta :: L_B := by
          intro psi hpsi
          by_cases h_B : psi ∈ B
          · exact List.mem_cons_of_mem _
              (List.mem_filter.mpr ⟨hpsi, decide_eq_true_eq.mpr h_B⟩)
          · rcases hL_sub psi hpsi with h | h
            · rw [Set.mem_singleton_iff.mp h]; exact .head _
            · exact absurd h h_B
        have d_w := DerivationTree.weakening L (delta :: L_B) Formula.bot d hL_sub'
        have d_neg := deduction_theorem L_B delta Formula.bot d_w
        have hLB_sub : ∀ psi ∈ L_B, psi ∈ B := by
          intro psi hpsi; exact decide_eq_true_eq.mp (List.mem_filter.mp hpsi).2
        exact h_neg_delta_B (h_dcs.2 L_B _ hLB_sub d_neg)
      · have hL_B : ∀ psi ∈ L, psi ∈ B := by
          intro psi hpsi
          rcases hL_sub psi hpsi with h | h
          · exact absurd (Set.mem_singleton_iff.mp h ▸ hpsi) h_delta_L
          · exact h
        exact h_dcs.1 L hL_B ⟨d⟩
    have h_dc_r3 := dc_delta_B_burgessR3 h_mcs_A h_mcs_C h_dcs h_R3M.2.1
      h_until_all h_since_all
    exact BurgessR3Maximal_extension_fails h_R3M h_delta_not h_cons h_dc_r3

/-! ## Burgess Lemma 2.6: Full D₀ Seed Construction

The content-based splitting lemma following Burgess 1982. Given BurgessR3Maximal(A, B, C)
and delta ∉ B, construct MCS D with ¬delta ∈ D and BurgessR3Maximal(A, B', D),
BurgessR3Maximal(D, B'', C) with B ⊆ B', B ⊆ B''.

**D₀ Seed**: The full Burgess seed is
  D₀ = {S(β,α) : α∈A, β∈B} ∪ B ∪ {¬δ} ∪ {U(β,γ) : β∈B, γ∈C}

This ensures B ⊆ D₀ (hence B ⊆ D after Lindenbaum), and the Until/Since
formulas ensure burgessR3(A, B, D) and burgessR3(D, B, C) hold for the
seed's content. Zorn extension then gives BurgessR3Maximal.

**Consistency Argument**: Uses BurgessR3Maximal_maximality_combined. For any
finite subset L of D₀, the elements from the Until/Since parts are already
in A/C respectively, and B is consistent. The ¬delta part is handled by
showing delta cannot be derived from the rest (since delta ∉ B and B ⊆ DC(D₀)).
-/

/-- The full Burgess D₀ seed for Lemma 2.6. -/
def burgess_D0 (A B C : Set Formula) (delta : Formula) : Set Formula :=
  {φ | ∃ α ∈ A, ∃ β ∈ B, φ = Formula.snce β α} ∪
  B ∪
  ({delta.neg} : Set Formula) ∪
  {φ | ∃ β ∈ B, ∃ γ ∈ C, φ = Formula.untl β γ}

/-- B is a subset of the D₀ seed. -/
theorem B_subset_burgess_D0 {A B C : Set Formula} {delta : Formula} :
    B ⊆ burgess_D0 A B C delta := by
  intro φ hφ
  exact Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_union_right _ hφ))

/-- ¬delta is in the D₀ seed. -/
theorem neg_delta_in_burgess_D0 {A B C : Set Formula} {delta : Formula} :
    delta.neg ∈ burgess_D0 A B C delta := by
  exact Set.mem_union_left _
    (Set.mem_union_right _ (Set.mem_singleton delta.neg))

/-- Until formulas U(β,γ) for β ∈ B, γ ∈ C are in the D₀ seed. -/
theorem untl_in_burgess_D0 {A B C : Set Formula} {delta : Formula}
    {β : Formula} (hβ : β ∈ B) {γ : Formula} (hγ : γ ∈ C) :
    Formula.untl β γ ∈ burgess_D0 A B C delta :=
  Set.mem_union_right _ ⟨β, hβ, γ, hγ, rfl⟩

/-- Since formulas S(β,α) for β ∈ B, α ∈ A are in the D₀ seed. -/
theorem snce_in_burgess_D0 {A B C : Set Formula} {delta : Formula}
    {α : Formula} (hα : α ∈ A) {β : Formula} (hβ : β ∈ B) :
    Formula.snce β α ∈ burgess_D0 A B C delta :=
  Set.mem_union_left _
    (Set.mem_union_left _
      (Set.mem_union_left _ ⟨α, hα, β, hβ, rfl⟩))

/-- **D₀ seed consistency**: The full Burgess seed is consistent.

The key argument: any finite L ⊆ D₀ with L ⊢ ⊥ would enable constructing
a proper DCS extension of B satisfying burgessR3(A, -, C), contradicting
the maximality of B in BurgessR3Maximal(A, B, C).

Specifically: if L ⊢ ⊥ and we separate ¬delta from L, we get L' ⊢ delta
where L' ⊆ D₀ \ {¬delta}. But D₀ \ {¬delta} ⊆ DC(B ∪ Until_part ∪ Since_part),
and all Until/Since elements are already derivable from B (via burgessR3
conditions). So delta ∈ DC(B), meaning delta ∈ B (since B is a DCS),
contradicting delta ∉ B.

More precisely: the Until formulas U(β,γ) are in A, the Since formulas
S(β,α) are in C. These are NOT directly in B. The consistency proof must
show that combining elements from B with elements that are theorems relative
to A/C cannot produce ⊥ while the individual sets remain consistent. -/
-- B ⊆ A when burgessR3(A, B, C) and C is nonempty MCS.
-- Proof: pick any γ₀ ∈ C. For β ∈ B: untl(β, γ₀) ∈ A (burgessRSet).
-- By until_guard: β ∈ A.
theorem B_sub_A_of_burgessR3 {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3 : burgessR3 A B C) :
    B ⊆ A := by
  -- C is an MCS so it's nonempty: ⊤ ∈ C (where ⊤ = ⊥ → ⊥)
  have h_top_C : (Formula.bot.imp Formula.bot) ∈ C :=
    theorem_in_mcs h_mcs_C (Bimodal.Theorems.Combinators.identity Formula.bot)
  intro β hβ
  have h_untl := h_r3.1 β hβ _ h_top_C
  exact until_guard_in_mcs h_mcs_A h_untl

-- B ⊆ C when burgessR3(A, B, C) and A is nonempty MCS.
theorem B_sub_C_of_burgessR3 {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3 : burgessR3 A B C) :
    B ⊆ C := by
  have h_top_A : (Formula.bot.imp Formula.bot) ∈ A :=
    theorem_in_mcs h_mcs_A (Bimodal.Theorems.Combinators.identity Formula.bot)
  intro β hβ
  have h_snce := h_r3.2 β hβ _ h_top_A
  exact since_guard_in_mcs h_mcs_C h_snce

/-- Every element of D₀ except ¬δ is either in A or in C.
More precisely: elements from B and Until components are in A,
elements from B and Since components are in C. -/
theorem burgess_D0_elem_in_A_or_C {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3 : burgessR3 A B C) {delta φ : Formula}
    (hφ : φ ∈ burgess_D0 A B C delta) (hφ_ne : φ ≠ delta.neg) :
    φ ∈ A ∨ φ ∈ C := by
  have h_B_A := B_sub_A_of_burgessR3 h_mcs_A h_mcs_C h_r3
  have h_B_C := B_sub_C_of_burgessR3 h_mcs_A h_mcs_C h_r3
  simp only [burgess_D0, Set.mem_union, Set.mem_setOf_eq, Set.mem_singleton_iff] at hφ
  rcases hφ with ⟨⟨α, hα, β, hβ, rfl⟩ | hφ_B⟩ | hφ_neg | ⟨β, hβ, γ, hγ, rfl⟩
  · -- Since formula S(β, α): in C by burgessRSetSince
    exact Or.inr (h_r3.2 β hβ α hα)
  · -- B element: in both A and C
    exact Or.inl (h_B_A hφ_B)
  · -- ¬δ: excluded by hypothesis
    exact absurd hφ_neg hφ_ne
  · -- Until formula U(β, γ): in A by burgessRSet
    exact Or.inl (h_r3.1 β hβ γ hγ)

theorem burgess_D0_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_R3M : BurgessR3Maximal A B C)
    {delta : Formula} (h_delta_not : delta ∉ B) :
    SetConsistent (burgess_D0 A B C delta) := by
  sorry

end Bimodal.Metalogic.BXCanonical.Chronicle
