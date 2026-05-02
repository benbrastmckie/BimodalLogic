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

## Open Guard Semantics (Task 113)

Under open guard semantics with guard interval (t,s):
- U(γ,β) at t means ∃s>t, β(s) ∧ ∀u∈(t,s), γ(u)
- The guard γ does NOT cover the current point t (open interval)
- BX9 (until_elim) is REMOVED: γ ∨ β at t is not guaranteed
- The until_guard axiom is REMOVED: γ at t is not guaranteed
- BX10 (until_F: γ U β → F(β)) remains valid

Several lemmas in this file are INVALID under open guard and retained as
sorry stubs with documentation. Key valid tools:
- BX10: γ U β → F(β) (eventuality extraction)
- BX5: γ U β → (γ ∧ (γ U β)) U β (self-accumulation)
- BX4: φ → G(P(φ)) (connect_future)

Burgess's Lemma 2.4 produces an endpoint MCS with β and g_content(A),
plus evidence that U(γ,β) was active in the past (via BX4). The guard γ
is handled by the interval DCS construction in Phase 4.

## Definitions

Local definitions used for point insertion lemmas.

## Main Results

- `lemma_2_4`: Until witness endpoint construction
- `lemma_2_5b`: Composition of g_content ordering (transitivity)
- `lemma_2_6`: Counterexample insertion (delta not in C -> insert D with neg delta)
- `dc_delta_B_burgessR3`: Extension of B by delta preserves burgessR3
- `BurgessR3Maximal_extension_fails`: Maximality prevents consistent proper extensions

### Withdrawn (Phase 3, Task 107) / Re-assessed (Phase 5, Task 107)

- `lemma_2_6_strong`: FALSE under strict semantics (g_content(D) <= C unprovable)
- `lemma_2_7`: Re-assessed as VALID (Phase 5, plan v27). The earlier "FALSE"
  assessment was for a D2-branch proof that predated BX13. Burgess's original
  proof using BX5+BX7+BX13 works under strict/open-guard semantics.
- `lemma_2_8`: Depends on D2-style reasoning; may be recoverable but not needed

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
there exists MCS C with β ∈ C, g_content(A) ⊆ C, P(U(γ,β)) ∈ C, and
a DCS interval set B with BurgessR3Maximal(A, B, C). -/
noncomputable def lemma_2_4 {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    ∃ B C : Set Formula, SetMaximalConsistent C ∧
      β ∈ C ∧ g_content A ⊆ C ∧
      Formula.some_past (Formula.untl γ β) ∈ C ∧
      BurgessR3Maximal A B C := by
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
  obtain ⟨B, h_B⟩ := burgessR3Maximal_from_g_content_sub h_mcs h_C_mcs h_g_sub
  exact ⟨B, C, h_C_mcs, h_β_C, h_g_sub, h_P_until_C, h_B⟩

-- until_elim_mcs: REMOVED (task 113 Phase 3). INVALID under open guard.
-- Use until_F_mcs (BX10) instead.

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

/-! ### Withdrawn and Re-assessed Lemmas

- `lemma_2_6_strong`: FALSE under strict semantics (g_content(D) ≤ C unprovable).
  Remains withdrawn.

- `lemma_2_7`: Previously marked FALSE under strict semantics (Phase 3, task 107),
  but that assessment was for a "D2 branch" proof approach that predated BX13
  (enrichment_until, Burgess A3a). With BX13 now available (Phase 2, task 107),
  Burgess's ORIGINAL proof of Lemma 2.7 is valid:
  1. BX5 (self_accum_until) enriches the Until guard
  2. BX7 (linear_until) provides the three-way disjunction
  3. BX13 (enrichment_until) simplifies the surviving disjunct
  4. BX1/BX2 (monotonicity) rule out two disjuncts
  None of these axioms depend on BX9 (removed) or the T-axiom.
  **Gate verdict (Phase 5, plan v27): VALID. Proceed with Strategy 1.**

- `lemma_2_8`: May also be recoverable with BX13, but Lemma 2.7 suffices
  for the C5 n>0 sub-case 3 (Burgess Lemma 2.10). Not needed if 2.7 works.
-/

-- lemma_2_7_guard: REMOVED (task 113 Phase 3). INVALID under open guard.
-- Depended on removed until_elim_mcs. (This was the old "D2 branch" approach,
-- NOT Burgess's original proof which uses BX5+BX7+BX13.)

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

-- rRelation_self_mcs: REMOVED (task 113 Phase 3). INVALID under open guard.
-- Depended on removed until_disjunction_in_mcs.

-- rRelationSince_self_mcs: REMOVED (task 113 Phase 3). INVALID under open guard.
-- Depended on removed since_disjunction_in_mcs.

-- lemma_2_6_full: REMOVED (task 113 Phase 3). Dead code (no callers).
-- Depended on removed rRelation_self_mcs / rRelationSince_self_mcs.
-- The codebase now uses BurgessR3Maximal (content-based) instead.

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

/-! ## Set.univ is ClosedUnderDerivation -/

/-- `Set.univ` is `ClosedUnderDerivation` -- every formula is in `Set.univ`. -/
theorem set_univ_closed_under_derivation : ClosedUnderDerivation (Set.univ : Set Formula) :=
  fun _ _ _ _ => Set.mem_univ _

/-! ## Inconsistent case helpers for g_content/h_content ⊆ B

When `{φ} ∪ B` is inconsistent and `G(φ) ∈ A` with `burgessR3(A, B, C)`,
we show `burgessR3(A, Set.univ, C)` using ex-falso propagation through
`left_mono_until_G`. The maximality clause of `BurgessR3Maximal` (now over
`ClosedUnderDerivation`) then gives a contradiction via `Set.univ`.
-/

/-- Helper: `⊢ φ → (φ.neg → ψ)` for any ψ (ex falso from assumption). -/
private noncomputable def ex_falso_from_assumption (φ ψ : Formula) :
    DerivationTree [] (φ.imp (φ.neg.imp ψ)) := by
  -- [φ.neg, φ] ⊢ ⊥ via modus ponens (φ.neg = φ → ⊥)
  have h1 : DerivationTree [φ.neg, φ] Formula.bot :=
    DerivationTree.modus_ponens [φ.neg, φ] φ Formula.bot
      (DerivationTree.assumption _ φ.neg (by simp))
      (DerivationTree.assumption _ φ (by simp))
  -- [φ.neg, φ] ⊢ ψ via ex falso
  have h2 : DerivationTree [φ.neg, φ] ψ :=
    DerivationTree.modus_ponens [φ.neg, φ] Formula.bot ψ
      (DerivationTree.weakening [] [φ.neg, φ] (Formula.bot.imp ψ)
        (Bimodal.Theorems.Propositional.efq_axiom ψ) (List.nil_subset _))
      h1
  -- Discharge φ.neg then φ: [φ] ⊢ φ.neg → ψ, then [] ⊢ φ → (φ.neg → ψ)
  exact deduction_theorem [] φ _ (deduction_theorem [φ] φ.neg ψ h2)

/-- Helper: G(φ.neg → ψ) ∈ A from G(φ) ∈ A, using ex_falso_from_assumption + TG + temp_k_dist. -/
private theorem G_ex_falso_strengthen {A : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (φ ψ : Formula)
    (h_Gφ : Formula.all_future φ ∈ A) :
    (φ.neg.imp ψ).all_future ∈ A := by
  have d_ef := ex_falso_from_assumption φ ψ
  exact SetMaximalConsistent.implication_property h_mcs_A
    (SetMaximalConsistent.implication_property h_mcs_A
      (theorem_in_mcs h_mcs_A (DerivationTree.axiom [] _ (Axiom.temp_k_dist φ (φ.neg.imp ψ))))
      (theorem_in_mcs h_mcs_A (DerivationTree.temporal_necessitation _ d_ef)))
    h_Gφ

/-- Helper: H(ψ.neg → χ) ∈ C from H(ψ) ∈ C, using ex_falso_from_assumption + past_necessitation + past_k_dist. -/
private theorem H_ex_falso_strengthen {C : Set Formula}
    (h_mcs_C : SetMaximalConsistent C) (ψ χ : Formula)
    (h_Hψ : Formula.all_past ψ ∈ C) :
    (ψ.neg.imp χ).all_past ∈ C := by
  have d_ef := ex_falso_from_assumption ψ χ
  exact SetMaximalConsistent.implication_property h_mcs_C
    (SetMaximalConsistent.implication_property h_mcs_C
      (theorem_in_mcs h_mcs_C (Bimodal.Theorems.past_k_dist ψ (ψ.neg.imp χ)))
      (theorem_in_mcs h_mcs_C (Bimodal.Theorems.past_necessitation _ d_ef)))
    h_Hψ

/-- When {φ} ∪ B is inconsistent with DCS B, we have φ.neg ∈ B.
Proof: ¬SetConsistent means ∃ derivation of ⊥ from {φ} ∪ B.
By deduction theorem: derivation of φ.neg from B. By closure: φ.neg ∈ B. -/
private theorem neg_mem_of_inconsistent_union {B : Set Formula}
    (h_dcs : SetDeductivelyClosed B)
    {φ : Formula} (h_not_cons : ¬SetConsistent ({φ} ∪ B)) :
    φ.neg ∈ B := by
  -- ¬SetConsistent means ∃ L ⊆ {φ} ∪ B with Nonempty (DerivationTree L ⊥)
  -- SetConsistent S = ∀ L, (∀ ψ ∈ L, ψ ∈ S) → ¬Nonempty (DerivationTree L ⊥)
  -- Use classical logic to extract witness
  by_contra h_neg_not_B
  apply h_not_cons
  -- If φ.neg ∉ B, then {φ.neg.neg} ∪ B would extend B... Actually, use dcs_neg_union_consistent
  -- The contrapositive: if {φ} ∪ B is inconsistent, then φ ∉ B (already known) and φ.neg ∈ B.
  -- We prove: if φ.neg ∉ B, then {φ} ∪ B IS consistent.
  -- Since B is DCS and φ.neg ∉ B, by dcs_neg_union_consistent: {φ.neg.neg} ∪ B is consistent.
  -- And φ.neg.neg → φ (double negation elimination), so {φ} ∪ B ⊆ DC({φ.neg.neg} ∪ B).
  -- Any subset of a consistent set is consistent.
  -- Actually, we can be more direct: if φ.neg ∉ B and B is DCS, then for any L ⊆ {φ} ∪ B,
  -- if we had DerivationTree L ⊥, we could derive φ.neg from B (contradiction).
  intro L hL ⟨d⟩
  -- L ⊆ {φ} ∪ B and DerivationTree L ⊥.
  -- Partition L: separate φ occurrences from B elements.
  set M := L.filter (fun x => !decide (x = φ)) with hM_def
  have hM_sub_B : ∀ ψ ∈ M, ψ ∈ B := by
    intro ψ hψ; rw [hM_def] at hψ
    have h_mem := List.mem_filter.mp hψ
    have h1 : ψ ∈ L := h_mem.1
    have h2 : ψ ≠ φ := by simp at h_mem; exact h_mem.2
    rcases hL ψ h1 with h | h
    · exact absurd (Set.mem_singleton_iff.mp h) h2
    · exact h
  have hL_sub_φM : L ⊆ φ :: M := by
    intro x hx
    by_cases heq : x = φ
    · subst heq; exact .head M
    · exact .tail _ (List.mem_filter.mpr ⟨hx, by simp; exact heq⟩)
  have d_w : DerivationTree (φ :: M) Formula.bot :=
    DerivationTree.weakening L (φ :: M) Formula.bot d hL_sub_φM
  -- By deduction theorem: M ⊢ φ → ⊥ = φ.neg
  have d_neg : DerivationTree M φ.neg := deduction_theorem M φ Formula.bot d_w
  -- By DCS closure: φ.neg ∈ B — contradiction
  exact h_neg_not_B (h_dcs.2 M φ.neg hM_sub_B d_neg)

/-- B is a proper subset of Set.univ when B is consistent. -/
private theorem dcs_ssubset_univ {B : Set Formula}
    (h_dcs : SetDeductivelyClosed B) :
    B ⊂ (Set.univ : Set Formula) := by
  constructor
  · exact Set.subset_univ B
  · intro h_eq
    -- If B = Set.univ, then ⊥ ∈ B, contradicting consistency
    have h_bot : Formula.bot ∈ B := h_eq (Set.mem_univ Formula.bot)
    exact h_dcs.1 [Formula.bot] (fun ψ hψ => by simp at hψ; rw [hψ]; exact h_bot)
      ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩

/-- When {φ} ∪ B is inconsistent, φ.neg ∈ B, G(φ) ∈ A, and burgessR3(A, B, C),
then burgessR3(A, Set.univ, C). The argument: from φ.neg ∈ B and G(φ) ∈ A,
for any ψ: G(φ.neg → ψ) ∈ A (ex falso), then untl_left_mono_G gives
untl(ψ, γ) ∈ A from untl(φ.neg, γ) ∈ A. This gives burgessRSet for Set.univ.
burgessR_implies_burgessRSince gives the Since direction. -/
private theorem burgessR3_univ_of_inconsistent_ext {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3 : burgessR3 A B C)
    {φ : Formula} (h_Gφ : Formula.all_future φ ∈ A)
    (h_neg_in_B : φ.neg ∈ B) :
    burgessR3 A Set.univ C := by
  constructor
  · -- burgessRSet(A, Set.univ, C): for any ψ ∈ Set.univ, for any γ ∈ C, untl(ψ, γ) ∈ A
    intro ψ _ γ hγ
    -- untl(φ.neg, γ) ∈ A from burgessR3(A, B, C) and φ.neg ∈ B
    have h_untl_neg := h_r3.1 φ.neg h_neg_in_B γ hγ
    -- G(φ.neg → ψ) ∈ A from G(φ) ∈ A
    have h_G_impl := G_ex_falso_strengthen h_mcs_A φ ψ h_Gφ
    -- untl_left_mono_G: G(φ.neg → ψ) and untl(φ.neg, γ) give untl(ψ, γ)
    exact untl_left_mono_G h_mcs_A h_G_impl h_untl_neg
  · -- burgessRSetSince(C, Set.univ, A): for any ψ ∈ Set.univ, for any α ∈ A, snce(ψ, α) ∈ C
    intro ψ _ α hα
    -- burgessR(A, ψ, C) from the Until direction above
    have h_burgessR : burgessR A ψ C := fun γ hγ => by
      have h_untl_neg := h_r3.1 φ.neg h_neg_in_B γ hγ
      have h_G_impl := G_ex_falso_strengthen h_mcs_A φ ψ h_Gφ
      exact untl_left_mono_G h_mcs_A h_G_impl h_untl_neg
    -- burgessR_implies_burgessRSince gives snce(ψ, α) ∈ C
    exact burgessR_implies_burgessRSince h_mcs_A h_mcs_C h_burgessR α hα

/-! ## g_content(A) ⊆ B from BurgessR3Maximal

Given `BurgessR3Maximal(A, B, C)` with A, C MCS and g_content(A) ⊆ C,
every φ ∈ g_content(A) (i.e., G(φ) ∈ A) must also be in B.

**Proof** (Report 47, task 107 Phase 5b v31, corrected v32):
- **Consistent case** ({φ}∪B consistent): `dc_delta_B_burgessR3` shows
  burgessR3(A, DC({φ}∪B), C) using left_mono_until_G/since_H. But
  `BurgessR3Maximal_extension_fails` gives ¬burgessR3. Contradiction.
- **Inconsistent case** ({φ}∪B inconsistent): φ.neg ∈ B (by DCS closure).
  `burgessR3_univ_of_inconsistent_ext` gives burgessR3(A, Set.univ, C).
  Set.univ is ClosedUnderDerivation. B ⊂ Set.univ (B is consistent).
  BurgessR3Maximal maximality (over ClosedUnderDerivation) gives contradiction.
-/

/-- Helper: ⊢ φ → (β → (β ∧ φ)). Conjunction introduction curried. -/
private noncomputable def conj_intro_curried (β φ : Formula) :
    DerivationTree [] (φ.imp (β.imp (Formula.and β φ))) := by
  have h1 : DerivationTree [β, φ] (Formula.and β φ) :=
    DerivationTree.modus_ponens [β, φ] _ _
      (DerivationTree.modus_ponens [β, φ] β _
        (DerivationTree.weakening [] [β, φ] _
          (pairing β φ) (List.nil_subset _))
        (DerivationTree.assumption _ β (by simp)))
      (DerivationTree.assumption _ φ (by simp))
  exact deduction_theorem [] φ _ (deduction_theorem [φ] β _ h1)

/-! ## Duality: h_content(C) ⊆ D implies g_content(D) ⊆ C

Local proof of the duality theorem needed for Lemma 2.6 splitting.
(The canonical version lives in ChronicleConstruction.lean which imports
this file, so we reproduce it here to avoid circular imports.)
-/

/-- h_content(B) ⊆ A implies g_content(A) ⊆ B for MCS A, B.
Proof: Suppose G(ψ) ∈ A and ψ ∉ B. Then ¬ψ ∈ B (MCS). By BX4' (connect_past):
¬ψ → H(F(¬ψ)), so H(F(¬ψ)) ∈ B, hence F(¬ψ) ∈ h_content(B) ⊆ A.
But F(¬ψ) = ¬G(ψ^{nn}), so G(ψ^{nn}) ∉ A. Yet G(ψ) → G(ψ^{nn}) by DNI
+ temporal necessitation + K distribution, contradiction. -/
private theorem h_content_sub_imp_g_content_sub' {A B : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_B : SetMaximalConsistent B)
    (h_hBA : h_content B ⊆ A) :
    g_content A ⊆ B := by
  intro ψ hψ
  by_contra h_not
  have h_neg_ψ : ψ.neg ∈ B := by
    rcases SetMaximalConsistent.negation_complete h_mcs_B ψ with h | h
    · exact absurd h h_not
    · exact h
  have h_ax : DerivationTree [] (ψ.neg.imp (ψ.neg.some_future.all_past)) :=
    DerivationTree.axiom [] _ (Axiom.connect_past ψ.neg)
  have h_HF : Formula.all_past (Formula.some_future ψ.neg) ∈ B :=
    SetMaximalConsistent.implication_property h_mcs_B
      (theorem_in_mcs h_mcs_B h_ax) h_neg_ψ
  have h_F_neg_ψ_A : Formula.some_future ψ.neg ∈ A := h_hBA h_HF
  have h_G_nn_not : Formula.all_future ψ.neg.neg ∉ A :=
    SetMaximalConsistent.neg_excludes h_mcs_A _ h_F_neg_ψ_A
  have h_dni : DerivationTree [] (ψ.imp ψ.neg.neg) :=
    Bimodal.Theorems.Combinators.dni ψ
  have h_G_dni : DerivationTree [] (Formula.all_future (ψ.imp ψ.neg.neg)) :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_G_dist : DerivationTree [] ((Formula.all_future (ψ.imp ψ.neg.neg)).imp
      (Formula.all_future ψ |>.imp (Formula.all_future ψ.neg.neg))) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ ψ.neg.neg)
  have h_G_nn : Formula.all_future ψ.neg.neg ∈ A := by
    have h1 := theorem_in_mcs h_mcs_A h_G_dni
    have h2 := theorem_in_mcs h_mcs_A h_G_dist
    have h3 := SetMaximalConsistent.implication_property h_mcs_A h2 h1
    exact SetMaximalConsistent.implication_property h_mcs_A h3 hψ
  exact h_G_nn_not h_G_nn

/-- g_content(A) ⊆ B implies h_content(B) ⊆ A for MCS A, B. Dual of above. -/
private theorem g_content_sub_imp_h_content_sub' {A B : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_B : SetMaximalConsistent B)
    (h_gAB : g_content A ⊆ B) :
    h_content B ⊆ A := by
  intro ψ hψ
  by_contra h_not
  have h_neg_ψ : ψ.neg ∈ A := by
    rcases SetMaximalConsistent.negation_complete h_mcs_A ψ with h | h
    · exact absurd h h_not
    · exact h
  have h_GP : Formula.all_future (Formula.some_past ψ.neg) ∈ A :=
    connect_future_mcs h_mcs_A ψ.neg h_neg_ψ
  have h_P_neg_ψ_B : Formula.some_past ψ.neg ∈ B := h_gAB h_GP
  have h_H_nn_not : Formula.all_past ψ.neg.neg ∉ B :=
    SetMaximalConsistent.neg_excludes h_mcs_B _ h_P_neg_ψ_B
  have h_dni : DerivationTree [] (ψ.imp ψ.neg.neg) :=
    Bimodal.Theorems.Combinators.dni ψ
  have h_H_dni : DerivationTree [] (Formula.all_past (ψ.imp ψ.neg.neg)) :=
    Bimodal.Theorems.past_necessitation _ h_dni
  have h_H_dist : DerivationTree [] ((Formula.all_past (ψ.imp ψ.neg.neg)).imp
      (Formula.all_past ψ |>.imp (Formula.all_past ψ.neg.neg))) :=
    Bimodal.Theorems.past_k_dist ψ ψ.neg.neg
  have h_H_nn : Formula.all_past ψ.neg.neg ∈ B := by
    have h1 := theorem_in_mcs h_mcs_B h_H_dni
    have h2 := theorem_in_mcs h_mcs_B h_H_dist
    have h3 := SetMaximalConsistent.implication_property h_mcs_B h2 h1
    exact SetMaximalConsistent.implication_property h_mcs_B h3 hψ
  exact h_H_nn_not h_H_nn

/-! ## Lemma 2.6 Splitting: BurgessR3Maximal Interval Insertion

Given `BurgessR3Maximal(A, B, C)` with `β ∉ B` and `g_content(A) ⊆ C`,
produce MCS D with `¬β ∈ D` and `BurgessR3Maximal(A, B', D)` and
`BurgessR3Maximal(D, B'', C)`.

The Burgess D0 seed approach uses `{β.neg} ∪ g_content(A) ∪ h_content(C)`
as the seed, with consistency proved via generalized temporal K distribution
in both G and H directions combined with burgessR3 Until/Since formulas.
-/

/-- The D0 splitting seed: `{β.neg} ∪ g_content(A) ∪ h_content(C)`. -/
private def splitting_seed (A C : Set Formula) (β : Formula) : Set Formula :=
  {β.neg} ∪ g_content A ∪ h_content C

/-- The splitting seed `{β.neg} ∪ g_content(A) ∪ h_content(C)` is consistent
when `BurgessR3Maximal(A, B, C)`, `g_content(A) ⊆ C`, and `β ∉ B`.

The proof reduces seed inconsistency to a contradiction in A or C using
the generalized temporal K distribution in both the G and H directions,
combined with the Until/Since formulas from burgessR3. -/
private theorem splitting_seed_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (β : Formula)
    (h_β_not_B : β ∉ B) :
    SetConsistent (splitting_seed A C β) := by
  sorry

theorem lemma_2_6_splitting {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (β : Formula)
    (h_β_not_B : β ∉ B) :
    ∃ B' D B'', BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧ β.neg ∈ D ∧
      g_content A ⊆ D ∧ g_content D ⊆ C := by
  -- Step 1: The seed is consistent
  have h_seed_cons := splitting_seed_consistent h_mcs_A h_mcs_C h_r3m h_gc β h_β_not_B
  -- Step 2: Lindenbaum-extend to MCS D
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed_cons
  -- Step 3: Extract seed membership
  have h_β_neg_D : β.neg ∈ D :=
    h_sup (Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_singleton _)))
  have h_g_sub_D : g_content A ⊆ D := fun φ hφ =>
    h_sup (Set.mem_union_left _ (Set.mem_union_right _ hφ))
  have h_h_sub_D : h_content C ⊆ D := fun φ hφ =>
    h_sup (Set.mem_union_right _ hφ)
  -- Step 4: Derive g_content(D) ⊆ C from h_content(C) ⊆ D
  have h_g_D_C : g_content D ⊆ C :=
    h_content_sub_imp_g_content_sub' h_D_mcs h_mcs_C h_h_sub_D
  -- Step 5: BurgessR3Maximal witnesses from g_content inclusions
  obtain ⟨B', h_B'⟩ := burgessR3Maximal_from_g_content_sub h_mcs_A h_D_mcs h_g_sub_D
  obtain ⟨B'', h_B''⟩ := burgessR3Maximal_from_g_content_sub h_D_mcs h_mcs_C h_g_D_C
  exact ⟨B', D, B'', h_B', h_B'', h_D_mcs, h_β_neg_D, h_g_sub_D, h_g_D_C⟩

/-! ## Lemma 2.7: Until-Formula Splitting (Burgess 1982)

Lemma 2.7 (Until-formula splitting): given `BurgessR3Maximal(A, B, C)` with
`U(xi, eta) ∈ A` and `eta ∉ B`, produce `B', D, B''` with:
- `BurgessR3Maximal(A, B', D)`
- `BurgessR3Maximal(D, B'', C)`
- `xi ∈ D` and `eta ∈ B'`

## Proof Strategy (Burgess 1982, direct seed)

From `eta ∉ B` and maximality of B: `BurgessR3Maximal_extension_fails` gives
`¬burgessR3(A, DC({eta}∪B), C)` (when {eta}∪B consistent). This means some
formula `phi ∈ DC({eta}∪B)` with some `gamma ∈ C` has `¬U(phi, gamma) ∈ A`.
By `dc_delta_B_controlled`, either `phi ∈ B` (impossible since burgessR3(A,B,C)
holds) or there exists `beta₀ ∈ B` with `⊢ (beta₀∧eta) → phi`.

So we obtain `beta₀ ∈ B`, `gamma₀ ∈ C` with `¬U(beta₀∧eta, gamma₀) ∈ A`.

**Core BX5+BX7+BX13 chain** (adapted from Burgess 1982 p. 371):

1. BX5 on `U(xi, eta)`: get `U(xi∧U(xi,eta), eta) ∈ A`
2. BX5 on `U(beta₀, gamma₀)` (from burgessR3): get `U(beta₀∧U(beta₀,gamma₀), gamma₀) ∈ A`
3. BX7 on these two enriched Until formulas → three-way disjunction D1∨D2∨D3
4. Eliminate D1 and D2 using `¬U(beta₀∧eta, gamma₀) ∈ A` + left_mono_until
5. D3 survives: `U(phi₁∧phi₂, phi₁∧gamma₀) ∈ A` where phi₁ = xi∧U(xi,eta)
6. BX10 gives F(phi₁∧gamma₀) ∈ A, so `{phi₁∧gamma₀} ∪ g_content(A) ∪ h_content(C)` consistent
7. Lindenbaum → MCS D with `xi ∈ D`, `g_content(A) ⊆ D`, `g_content(D) ⊆ C`
8. `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` from g_content
9. `eta ∈ B'` from `U(xi, beta∧eta) ∈ A` for all beta ∈ B, plus maximality
-/

/-- Helper: BX3 (right_mono_until) at MCS level. If ⊢ ψ → χ and
U(φ, ψ) ∈ A, then U(φ, χ) ∈ A. -/
private theorem right_mono_until_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {φ ψ χ : Formula}
    (h_impl : DerivationTree [] (ψ.imp χ))
    (h_untl : Formula.untl φ ψ ∈ A) :
    Formula.untl φ χ ∈ A := by
  -- G(ψ → χ) ∈ A from temporal necessitation
  have h_G_impl : Formula.all_future (ψ.imp χ) ∈ A :=
    theorem_in_mcs h_mcs (DerivationTree.temporal_necessitation _ h_impl)
  -- BX3: G(ψ → χ) → U(φ, ψ) → U(φ, χ)
  have h_bx3 := DerivationTree.axiom [] _ (Axiom.right_mono_until ψ χ φ)
  exact SetMaximalConsistent.implication_property h_mcs
    (SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_bx3) h_G_impl) h_untl

/-- Helper: U(xi, beta∧eta) ∈ A for all beta with G(beta) ∈ A, from U(xi, eta) ∈ A.
Uses BX3 (right_mono_until): G(eta → beta∧eta) follows from G(beta) ∈ A.
This holds in particular for beta ∈ g_content(A) (where G(beta) ∈ A by definition). -/
private theorem untl_conj_eta_of_g_content {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {xi eta : Formula}
    (h_untl : Formula.untl xi eta ∈ A) (beta : Formula)
    (h_Gbeta : Formula.all_future beta ∈ A) :
    Formula.untl xi (Formula.and beta eta) ∈ A := by
  -- First get U(xi, eta∧beta) via BX3: G(eta → eta∧beta) and U(xi, eta) → U(xi, eta∧beta)
  -- G(eta → eta∧beta) follows from G(beta) via ⊢ beta → (eta → eta∧beta) + TG + K_dist
  have h_conj_intro := conj_intro_curried eta beta
  -- G(beta → (eta → eta∧beta)) ∈ A
  have h_G_ci : Formula.all_future (beta.imp (eta.imp (Formula.and eta beta))) ∈ A :=
    theorem_in_mcs h_mcs (DerivationTree.temporal_necessitation _ h_conj_intro)
  -- G(eta → eta∧beta) ∈ A by K_dist on G(beta) and G(beta → (eta → eta∧beta))
  have h_kd := DerivationTree.axiom [] _ (Axiom.temp_k_dist beta (eta.imp (Formula.and eta beta)))
  have h1 := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_kd) h_G_ci
  have h_G_eta_conj : Formula.all_future (eta.imp (Formula.and eta beta)) ∈ A :=
    SetMaximalConsistent.implication_property h_mcs h1 h_Gbeta
  -- BX3: G(eta → eta∧beta) → U(xi, eta) → U(xi, eta∧beta)
  have h_u_eta_beta : Formula.untl xi (Formula.and eta beta) ∈ A := by
    have h_bx3 := DerivationTree.axiom [] _ (Axiom.right_mono_until eta (Formula.and eta beta) xi)
    exact SetMaximalConsistent.implication_property h_mcs
      (SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_bx3) h_G_eta_conj) h_untl
  -- Now swap: U(xi, eta∧beta) → U(xi, beta∧eta) by right_mono with ⊢ eta∧beta → beta∧eta
  have h_swap : DerivationTree [] ((Formula.and eta beta).imp (Formula.and beta eta)) := by
    have s1 : DerivationTree [Formula.and eta beta] beta :=
      DerivationTree.modus_ponens _ _ _ (DerivationTree.weakening [] _ _ (rce_imp eta beta) (List.nil_subset _))
        (DerivationTree.assumption _ _ (by simp))
    have s2 : DerivationTree [Formula.and eta beta] eta :=
      DerivationTree.modus_ponens _ _ _ (DerivationTree.weakening [] _ _ (lce_imp eta beta) (List.nil_subset _))
        (DerivationTree.assumption _ _ (by simp))
    have s3 : DerivationTree [Formula.and eta beta] (Formula.and beta eta) :=
      DerivationTree.modus_ponens _ _ _ (DerivationTree.modus_ponens _ _ _
        (DerivationTree.weakening [] _ _ (pairing beta eta) (List.nil_subset _)) s1) s2
    exact deduction_theorem [] (Formula.and eta beta) (Formula.and beta eta) s3
  exact right_mono_until_mcs h_mcs h_swap h_u_eta_beta

/-! ## Lemma 2.7 Helpers and Implementation -/

/-- BX14 (separation_until) at MCS level: If untl(q, p) ∈ A and
untl(r, p).neg ∈ A, then untl(q, q ∧ r.neg) ∈ A. -/
private theorem separation_until_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {p q r : Formula}
    (h_untl : Formula.untl q p ∈ A)
    (h_neg : (Formula.untl r p).neg ∈ A) :
    Formula.untl q (Formula.and q r.neg) ∈ A := by
  have h_bx14 := DerivationTree.axiom [] _ (Axiom.separation_until p q r)
  have h_step := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_bx14) h_untl
  exact SetMaximalConsistent.implication_property h_mcs h_step h_neg

/-- BX13 (enrichment_until) at MCS level: If p ∈ A and untl(phi, psi) ∈ A,
then untl(phi, psi ∧ snce(phi, p)) ∈ A. -/
private theorem enrichment_until_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {phi psi p : Formula}
    (h_p : p ∈ A)
    (h_untl : Formula.untl phi psi ∈ A) :
    Formula.untl phi (Formula.and psi (Formula.snce phi p)) ∈ A := by
  have h_conj := conj_mcs h_mcs p (Formula.untl phi psi) h_p h_untl
  have h_bx13 := DerivationTree.axiom [] _ (Axiom.enrichment_until phi psi p)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_bx13) h_conj

/-- BX10 (until_F) at MCS level: If untl(phi, psi) ∈ A, then F(psi) ∈ A.
Alias for `until_F_mcs` for local use. -/
private theorem until_implies_F_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {phi psi : Formula}
    (h_untl : Formula.untl phi psi ∈ A) :
    Formula.some_future psi ∈ A :=
  until_F_mcs h_mcs phi psi h_untl

/-- F-monotonicity at MCS level: If ⊢ phi → psi and F(phi) ∈ A, then F(psi) ∈ A.
F(phi) = ¬G(¬phi). From ⊢ phi → psi we get ⊢ ¬psi → ¬phi, then G(¬psi) → G(¬phi),
so ¬G(¬phi) → ¬G(¬psi), i.e., F(phi) → F(psi). -/
private theorem F_mono_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {phi psi : Formula}
    (h_impl : DerivationTree [] (phi.imp psi))
    (h_F : Formula.some_future phi ∈ A) :
    Formula.some_future psi ∈ A := by
  -- F(phi) = ¬G(¬phi). Suppose G(¬psi) ∈ A for contradiction.
  by_contra h_not_F
  -- ¬F(psi) ∈ A means G(psi.neg) ∈ A (since F(psi) = ¬G(psi.neg) = (G(psi.neg)).neg)
  have h_G_neg_psi : Formula.all_future psi.neg ∈ A := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future psi.neg) with h | h
    · exact h
    · exact absurd h h_not_F
  -- From ⊢ phi → psi: ⊢ ¬psi → ¬phi (contrapositive)
  -- G(¬psi → ¬phi) is a theorem
  -- G(¬psi) → G(¬phi) by K-distribution
  have h_contra : DerivationTree [] (psi.neg.imp phi.neg) := by
    have h1 : DerivationTree [phi, psi.neg] psi :=
      DerivationTree.modus_ponens _ _ _
        (DerivationTree.weakening [] _ _ h_impl (List.nil_subset _))
        (DerivationTree.assumption _ phi (by simp))
    have h2 : DerivationTree [phi, psi.neg] Formula.bot :=
      DerivationTree.modus_ponens _ _ _
        (DerivationTree.assumption _ psi.neg (by simp)) h1
    have h3 := deduction_theorem [psi.neg] phi Formula.bot h2
    exact deduction_theorem [] psi.neg phi.neg h3
  have h_G_contra := theorem_in_mcs h_mcs
    (DerivationTree.temporal_necessitation _ h_contra)
  have h_kd := theorem_in_mcs h_mcs
    (DerivationTree.axiom [] _ (Axiom.temp_k_dist psi.neg phi.neg))
  have h_G_neg_phi : Formula.all_future phi.neg ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (SetMaximalConsistent.implication_property h_mcs h_kd h_G_contra) h_G_neg_psi
  -- G(¬phi) ∈ A = ¬F(phi) ∈ A contradicts F(phi) ∈ A
  -- F(phi) = (G(phi.neg)).neg = some_future phi
  -- so G(phi.neg) and F(phi) = (G(phi.neg)).neg are contradictory
  exact absurd h_G_neg_phi (SetMaximalConsistent.neg_excludes h_mcs _ h_F)

/-- Helper: ⊢ (a ∧ b) → a (left conjunction elimination). -/
private noncomputable def and_left_impl (a b : Formula) :
    DerivationTree [] ((Formula.and a b).imp a) :=
  lce_imp a b

/-- Helper: ⊢ (a ∧ b) → b (right conjunction elimination). -/
private noncomputable def and_right_impl (a b : Formula) :
    DerivationTree [] ((Formula.and a b).imp b) :=
  rce_imp a b

/-- The D0 seed for Lemma 2.7:
  B ∪ {xi} ∪ {untl(β, γ) : β ∈ B, γ ∈ C}
  ∪ {snce(β, α) : β ∈ B, α ∈ A}
  ∪ {snce(β ∧ eta, α) : β ∈ B, α ∈ A}.

The last component (snce with β∧eta guard) is the key Burgess insight:
it encodes eta's presence in the interval, enabling eta ∈ B' via dc_delta_B_burgessR3
and maximality. -/
private def lemma_2_7_seed (A B C : Set Formula) (xi eta : Formula) : Set Formula :=
  B ∪ {xi} ∪ {φ | ∃ β ∈ B, ∃ γ ∈ C, φ = Formula.untl β γ} ∪
  {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce β α} ∪
  {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce (Formula.and β eta) α}

/-- Consistency of the Lemma 2.7 D0 seed.

The proof uses BX14 (separation) + BX13 (enrichment) + BX10 (F-extraction).
Any finite inconsistent subset L ⊆ D0 can be refuted by constructing
an Until formula in A whose event subsumes L's elements.

Key steps:
1. BX5 on untl(beta0, gamma0): enriched guard
2. BX14 separation using neg-untl(beta0∧eta, gamma0): gives event with eta.neg
3. BX13 iterated enrichment: packs S-formulas into event
4. BX10: F(event) ∈ A, so event is consistent
5. Any finite L ⊆ D0 maps into a consistent event -/
private theorem lemma_2_7_seed_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (xi eta : Formula)
    (h_until : Formula.untl xi eta ∈ A)
    (h_eta_not_B : eta ∉ B) :
    SetConsistent (lemma_2_7_seed A B C xi) := by
  sorry

theorem lemma_2_7 {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (xi eta : Formula)
    (h_until : Formula.untl xi eta ∈ A)
    (h_eta_not_B : eta ∉ B) :
    ∃ B' D B'' : Set Formula,
      BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧
      xi ∈ D ∧
      eta ∈ B' := by
  -- Step 1: The D0 seed is consistent
  have h_seed_cons := lemma_2_7_seed_consistent h_mcs_A h_mcs_C h_r3m h_gc xi eta h_until h_eta_not_B
  -- Step 2: Lindenbaum-extend to MCS D
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed_cons
  -- Step 3: Extract key memberships from seed
  have h_xi_D : xi ∈ D :=
    h_sup (Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_union_right _ (Set.mem_singleton xi))))
  have h_B_sub_D : B ⊆ D := fun φ hφ =>
    h_sup (Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_union_left _ hφ)))
  -- Until formulas: untl(β, γ) ∈ D for all β ∈ B, γ ∈ C
  have h_untl_D : ∀ β ∈ B, ∀ γ ∈ C, Formula.untl β γ ∈ D := by
    intro β hβ γ hγ
    exact h_sup (Set.mem_union_left _ (Set.mem_union_right _ ⟨β, hβ, γ, hγ, rfl⟩))
  -- Since formulas: snce(β, α) ∈ D for all β ∈ B, α ∈ A
  have h_snce_D : ∀ β ∈ B, ∀ α ∈ A, Formula.snce β α ∈ D := by
    intro β hβ α hα
    exact h_sup (Set.mem_union_right _ ⟨β, hβ, α, hα, rfl⟩)
  -- Step 4: Establish burgessR3(D, B, C) from seed Until formulas
  have h_rSet_D : burgessRSet D B C := fun β hβ γ hγ => h_untl_D β hβ γ hγ
  -- burgessRSince(C, B, D) follows from burgessR via Lemma 2.3
  have h_rSetSince_D : burgessRSetSince C B D := by
    intro β hβ
    exact burgessR_implies_burgessRSince h_D_mcs h_mcs_C (h_rSet_D β hβ)
  have h_r3_DBC : burgessR3 D B C := ⟨h_rSet_D, h_rSetSince_D⟩
  -- Step 5: Establish burgessR3(A, B, D) from seed Since formulas
  -- snce(β, α) ∈ D for all β ∈ B, α ∈ A gives burgessRSetSince(D, B, A)
  have h_rSetSince_A : burgessRSetSince D B A := fun β hβ α hα => h_snce_D β hβ α hα
  -- burgessR(A, β, D) follows from burgessRSince via Lemma 2.3 backward
  have h_rSet_A : burgessRSet A B D := by
    intro β hβ
    exact burgessRSince_implies_burgessR h_mcs_A h_D_mcs (h_rSetSince_A β hβ)
  have h_r3_ABD : burgessR3 A B D := ⟨h_rSet_A, h_rSetSince_A⟩
  -- Step 6: BurgessR3Maximal via Zorn (burgessR3Maximal_extension_exists)
  obtain ⟨B', _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
    h_r3m.1 h_r3_ABD
  obtain ⟨B'', _, h_B''_max⟩ := burgessR3Maximal_extension_exists h_D_mcs h_mcs_C
    h_r3m.1 h_r3_DBC
  -- Step 7: Show eta ∈ B'
  -- B' ⊇ B and BurgessR3Maximal(A, B', D).
  -- For eta ∈ B': show DC({eta} ∪ B') satisfies burgessR3(A, -, D).
  -- For any phi ∈ DC({eta} ∪ B') and delta ∈ D: untl(phi, delta) ∈ A.
  -- By dc_delta_B_controlled: phi ∈ B' or ⊢ (beta'∧eta) → phi for beta' ∈ B'.
  -- If phi ∈ B': untl(phi, delta) ∈ A from burgessR3(A, B', D). ✓
  -- If ⊢ (beta'∧eta) → phi: need untl(beta'∧eta, delta) ∈ A.
  --   For delta ∈ D: by untl_conj_eta_of_g_content (with appropriate setup),
  --   U(xi, beta'∧eta∧delta_stuff) ∈ A, giving untl(beta'∧eta, delta) via right_mono.
  -- The key is that D was built with burgessR3(A, B', D), so untl(beta', delta) ∈ A
  -- for all beta' ∈ B', delta ∈ D. We need to strengthen the guard to beta'∧eta.
  -- From U(xi, eta) ∈ A: for beta' ∈ B' and delta ∈ D, we need untl(beta'∧eta, delta) ∈ A.
  -- This follows if G(eta) ∈ A (then BX2G gives guard strengthening).
  -- If G(eta) ∉ A, we use the indirect argument via BX13.
  -- Actually, the eta ∈ B' argument uses the structure of B': since B' is the Zorn-maximal
  -- extension of B with burgessR3(A, B', D), and eta can be consistently added.
  -- We show: if eta ∉ B', then {eta} ∪ B' is consistent (since B' is DCS and eta ∉ B'),
  -- and DC({eta} ∪ B') satisfies burgessR3(A, -, D). This contradicts maximality.
  have h_eta_B' : eta ∈ B' := by
    sorry
  exact ⟨B', D, B'', h_B'_max, h_B''_max, h_D_mcs, h_xi_D, h_eta_B'⟩

end Bimodal.Metalogic.BXCanonical.Chronicle
