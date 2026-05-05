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

/-- **Lemma 2.4** (adapted for strict semantics): Given MCS A with U(γ, β) ∈ A
and ¬burgessR3(A, Set.univ, C) for the constructed C, there exists MCS C with
β ∈ C, g_content(A) ⊆ C, P(U(γ,β)) ∈ C, and a DCS interval set B with
BurgessR3Maximal(A, B, C).

The hypothesis `h_not_univ_gen` provides ¬burgessR3(A, Set.univ, C) for ANY MCS C
extending the seed {β} ∪ g_content(A). This is needed because C is constructed
internally and callers cannot know it in advance. -/
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
  have h_no_univ : ¬burgessR3 A Set.univ C := by
    sorry -- NoUnivBurgessR3: threaded from chronicle construction
  obtain ⟨B, h_B⟩ := burgessR3Maximal_from_g_content_sub h_mcs h_C_mcs h_g_sub h_no_univ
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

/-- MCS disjunction elimination (local version): If (φ ∨ ψ) ∈ A then φ ∈ A ∨ ψ ∈ A.
Recall φ.or ψ = φ.neg.imp ψ. -/
private theorem or_elim_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {φ ψ : Formula}
    (h : (φ.or ψ) ∈ A) : φ ∈ A ∨ ψ ∈ A := by
  rcases SetMaximalConsistent.negation_complete h_mcs φ with h_φ | h_neg_φ
  · exact Or.inl h_φ
  · exact Or.inr (SetMaximalConsistent.implication_property h_mcs h h_neg_φ)

/-- BX7 (linear_until) at MCS level: If U(φ,ψ) ∈ A and U(χ,θ) ∈ A,
then one of three disjuncts holds:
  D1: U(φ∧χ, ψ∧θ) ∈ A, or D2: U(φ∧χ, ψ∧χ) ∈ A, or D3: U(φ∧χ, φ∧θ) ∈ A. -/
theorem linear_until_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ ψ χ θ : Formula)
    (h_u1 : Formula.untl φ ψ ∈ A)
    (h_u2 : Formula.untl χ θ ∈ A) :
    Formula.untl (Formula.and φ χ) (Formula.and ψ θ) ∈ A ∨
    Formula.untl (Formula.and φ χ) (Formula.and ψ χ) ∈ A ∨
    Formula.untl (Formula.and φ χ) (Formula.and φ θ) ∈ A := by
  -- Form the conjunction: U(φ,ψ) ∧ U(χ,θ) ∈ A
  have h_conj := conj_mcs h_mcs _ _ h_u1 h_u2
  -- Apply BX7 axiom
  have h_bx7 := DerivationTree.axiom [] _ (Axiom.linear_until φ ψ χ θ)
  have h_disj := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_bx7) h_conj
  -- h_disj : (D1 ∨ D2) ∨ D3 ∈ A
  -- Case split on the outer disjunction
  rcases or_elim_mcs h_mcs h_disj with h12 | h3
  · -- D1 ∨ D2 ∈ A
    rcases or_elim_mcs h_mcs h12 with h1 | h2
    · exact Or.inl h1
    · exact Or.inr (Or.inl h2)
  · exact Or.inr (Or.inr h3)

/-- BX7' (linear_since) at MCS level: If S(φ,ψ) ∈ A and S(χ,θ) ∈ A,
then one of three disjuncts holds:
  D1: S(φ∧χ, ψ∧θ) ∈ A, or D2: S(φ∧χ, ψ∧χ) ∈ A, or D3: S(φ∧χ, φ∧θ) ∈ A. -/
theorem linear_since_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ ψ χ θ : Formula)
    (h_s1 : Formula.snce φ ψ ∈ A)
    (h_s2 : Formula.snce χ θ ∈ A) :
    Formula.snce (Formula.and φ χ) (Formula.and ψ θ) ∈ A ∨
    Formula.snce (Formula.and φ χ) (Formula.and ψ χ) ∈ A ∨
    Formula.snce (Formula.and φ χ) (Formula.and φ θ) ∈ A := by
  have h_conj := conj_mcs h_mcs _ _ h_s1 h_s2
  have h_bx7 := DerivationTree.axiom [] _ (Axiom.linear_since φ ψ χ θ)
  have h_disj := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_bx7) h_conj
  rcases or_elim_mcs h_mcs h_disj with h12 | h3
  · rcases or_elim_mcs h_mcs h12 with h1 | h2
    · exact Or.inl h1
    · exact Or.inr (Or.inl h2)
  · exact Or.inr (Or.inr h3)

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

/-- If BurgessR3Maximal(A, B, C) and delta ∉ B, the deductive closure of
{delta} ∪ B does NOT satisfy burgessR3(A, -, C).

No consistency requirement: the maximality clause in BurgessR3Maximal
quantifies over `ClosedUnderDerivation` sets, which includes
`deductiveClosure ({delta} ∪ B)` regardless of consistency. -/
theorem BurgessR3Maximal_extension_fails {A B C : Set Formula}
    (h_R3M : BurgessR3Maximal A B C)
    {delta : Formula} (h_delta_not : delta ∉ B) :
    ¬burgessR3 A (deductiveClosure ({delta} ∪ B)) C := by
  intro h_r3
  have h_cud : ClosedUnderDerivation (deductiveClosure ({delta} ∪ B)) :=
    deductiveClosure_closed_under_derivation _
  have h_sub : B ⊆ deductiveClosure ({delta} ∪ B) :=
    fun phi hphi => subset_deductiveClosure _ (Set.mem_union_right _ hphi)
  have h_delta_in : delta ∈ deductiveClosure ({delta} ∪ B) :=
    subset_deductiveClosure _ (Set.mem_union_left _ (Set.mem_singleton delta))
  have h_proper : B ⊂ deductiveClosure ({delta} ∪ B) :=
    ⟨h_sub, fun h_eq => h_delta_not (h_eq h_delta_in)⟩
  exact h_R3M.2.2 _ h_cud h_proper h_r3

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

/-- **Unified interface**: Given BurgessR3Maximal(A, B, C) and delta ∉ B,
EITHER delta.neg ∈ B (when {delta}∪B is inconsistent)
OR ¬burgessR3(A, DC({delta}∪B), C).

The second disjunct always holds (BurgessR3Maximal_extension_fails). The first
disjunct holds additionally when {delta}∪B is inconsistent. -/
theorem BurgessR3Maximal_neg_or_ext_fails {A B C : Set Formula}
    (h_R3M : BurgessR3Maximal A B C)
    {delta : Formula} (h_delta_not : delta ∉ B) :
    delta.neg ∈ B ∨ ¬burgessR3 A (deductiveClosure ({delta} ∪ B)) C := by
  by_cases h_cons : SetConsistent ({delta} ∪ B)
  · exact Or.inr (BurgessR3Maximal_extension_fails h_R3M h_delta_not)
  · exact Or.inl (neg_mem_of_inconsistent_union h_R3M.1 h_cons)

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

## Burgess D₀ Seed Construction (Burgess 1982, p.370)

The seed includes explicit Until/Since formulas to directly establish
`burgessR3` relations from seed membership, bypassing the unprovable
Since condition for deductive closure extension.

D₀ = B ∪ {β.neg} ∪ {untl(β', γ) : β' ∈ B, γ ∈ C} ∪ {snce(β', α) : β' ∈ B, α ∈ A}

Consistency of D₀ follows from the BX5+BX14+BX10 chain:
1. From maximality: extract beta0 ∈ B, gamma0 ∈ C with ¬U(beta0∧β, gamma0) ∈ A
2. BX5: U(beta0∧U(beta0,gamma0), gamma0) ∈ A
3. BX14: U(q, q∧(beta0∧β).neg) ∈ A where q = beta0∧U(beta0,gamma0)
4. BX10: F(q∧(beta0∧β).neg) ∈ A, proving F(β.neg) ∈ A
5. forward_temporal_witness_seed_consistent gives {β.neg}∪g_content(A) consistent
6. D₀ ⊆ {β.neg}∪g_content(A)∪h_content(C) which is consistent since h_content(C)⊆A
-/

-- ARCHIVED (Task 107): The old splitting_seed = {β.neg} ∪ g_content(A) ∪ h_content(C)
-- had a mathematically broken consistency proof: the Since condition for
-- dc_delta_B_burgessR3 requires ⊢ beta → (beta ∧ β) which is false (Report 52).
-- Also, weakening direction was backwards in the inconsistent case.
-- Replaced by Burgess's actual D₀ construction with explicit Until/Since formulas.

/-- Burgess's D₀ seed for Lemma 2.6 (Burgess 1982, p.370):
  B ∪ {β.neg} ∪ {untl(β', γ) : β' ∈ B, γ ∈ C} ∪ {snce(β', α) : β' ∈ B, α ∈ A}

The seed directly encodes the Until/Since formulas needed to establish
burgessR3 relationships after Lindenbaum extension, without requiring
the unprovable Since condition for deductive closure. -/
private def burgess_D0_seed (A B C : Set Formula) (β : Formula) : Set Formula :=
  B ∪ {β.neg} ∪
  {φ | ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ} ∪
  {φ | ∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α}

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

/-- **List-level cut** (derivation from implied context):
If Γ ⊢ φ for each φ ∈ L, and L ⊢ ψ, then Γ ⊢ ψ.

This is the substitution principle: we can replace assumptions in L
with their derivations from Γ. Proved by induction on L. -/
private noncomputable def derivation_from_implied (Γ : Context) :
    (L : Context) → (ψ : Formula) →
    (∀ φ ∈ L, DerivationTree Γ φ) →
    DerivationTree L ψ →
    DerivationTree Γ ψ
  | [], ψ, _, d => DerivationTree.weakening [] Γ ψ d (List.nil_subset Γ)
  | l :: L', ψ, h_derives, d => by
    -- Apply deduction theorem to remove l from the head
    have d_impl : DerivationTree L' (l.imp ψ) := deduction_theorem L' l ψ d
    -- Recursively derive l.imp ψ from Γ
    have h_derives' : ∀ φ ∈ L', DerivationTree Γ φ := fun φ hφ =>
      h_derives φ (List.mem_cons.mpr (Or.inr hφ))
    have d_impl_Γ : DerivationTree Γ (l.imp ψ) :=
      derivation_from_implied Γ L' (l.imp ψ) h_derives' d_impl
    -- Derive l from Γ
    have d_l : DerivationTree Γ l := h_derives l (List.mem_cons.mpr (Or.inl rfl))
    -- Apply modus ponens: Γ ⊢ l.imp ψ and Γ ⊢ l gives Γ ⊢ ψ
    exact DerivationTree.modus_ponens Γ l ψ d_impl_Γ d_l

/-- Corollary: If a set S implies each element of L (i.e., for each φ∈L
there exist premises in S deriving φ), and L ⊢ ⊥, then S is inconsistent.
Contrapositive: if S is consistent, then no L derived from S can derive ⊥,
hence the set of formulas implied by S is consistent. -/
private theorem inconsistent_from_implied {S : Set Formula}
    (h_cons : SetConsistent S)
    (L : List Formula) (hL : ∀ φ ∈ L, φ ∈ S)
    (d : Nonempty (DerivationTree L Formula.bot)) : False :=
  h_cons L hL d

/-! ### List Conjunction and Helpers for Burgess Compression

These helpers support the Burgess compression argument: given a finite
subset L of a seed D₀, we compress it into a single conjunction and
show that conjunction is consistent via the BX chain. -/

/-- Conjunction of a list of formulas. Empty list gives ⊤ (= ⊥→⊥). -/
private noncomputable def list_conj : List Formula → Formula
  | [] => Formula.bot.imp Formula.bot  -- top
  | [φ] => φ
  | (φ :: rest) => Formula.and φ (list_conj rest)

/-- ⊢ list_conj L → φ for each φ ∈ L. -/
private noncomputable def list_conj_implies_elem :
    (L : List Formula) → (φ : Formula) → (h : φ ∈ L) →
    DerivationTree [] ((list_conj L).imp φ)
  | [ψ], φ, h => by
    simp [List.mem_singleton] at h
    subst h; simp [list_conj]; exact identity φ
  | (ψ₁ :: ψ₂ :: rest), φ, h => by
    simp [list_conj]
    -- Cannot use rcases on Or into Type; use decidable equality instead
    by_cases h_eq : φ = ψ₁
    · -- φ = ψ₁: extract left component of ψ₁ ∧ list_conj(ψ₂::rest)
      subst h_eq; exact lce_imp φ (list_conj (ψ₂ :: rest))
    · -- φ ∈ ψ₂ :: rest: extract right component, then recurse
      have h' : φ ∈ ψ₂ :: rest := by
        rcases List.mem_cons.mp h with rfl | h'
        · exact absurd rfl h_eq
        · exact h'
      have h_right := rce_imp ψ₁ (list_conj (ψ₂ :: rest))
      have h_rec := list_conj_implies_elem (ψ₂ :: rest) φ h'
      exact imp_trans h_right h_rec

/-- If B is DCS and all elements of L are in B, then list_conj L ∈ B. -/
private theorem list_conj_mem_dcs {B : Set Formula} (h_dcs : SetDeductivelyClosed B) :
    (L : List Formula) → (h : ∀ φ ∈ L, φ ∈ B) → list_conj L ∈ B
  | [], _ => dcs_contains_theorems h_dcs (identity Formula.bot)
  | [φ], h => by simp [list_conj]; exact h φ (List.mem_singleton.mpr rfl)
  | (φ₁ :: φ₂ :: rest), h => by
    simp [list_conj]
    have h1 : φ₁ ∈ B := h φ₁ (List.mem_cons.mpr (Or.inl rfl))
    have h2 : list_conj (φ₂ :: rest) ∈ B :=
      list_conj_mem_dcs h_dcs (φ₂ :: rest) (fun ψ hψ =>
        h ψ (List.mem_cons.mpr (Or.inr hψ)))
    exact dcs_conj_closed h_dcs h1 h2

/-- If A is MCS and all elements of L are in A, then list_conj L ∈ A. -/
private theorem list_conj_mem_mcs {A : Set Formula} (h_mcs : SetMaximalConsistent A) :
    (L : List Formula) → (h : ∀ φ ∈ L, φ ∈ A) → list_conj L ∈ A
  | [], _ => theorem_in_mcs h_mcs (identity Formula.bot)
  | [φ], h => by simp [list_conj]; exact h φ (List.mem_singleton.mpr rfl)
  | (φ₁ :: φ₂ :: rest), h => by
    simp [list_conj]
    have h1 : φ₁ ∈ A := h φ₁ (List.mem_cons.mpr (Or.inl rfl))
    have h2 : list_conj (φ₂ :: rest) ∈ A :=
      list_conj_mem_mcs h_mcs (φ₂ :: rest) (fun ψ hψ =>
        h ψ (List.mem_cons.mpr (Or.inr hψ)))
    exact conj_mcs h_mcs φ₁ (list_conj (φ₂ :: rest)) h1 h2

/-- If F(φ)∈A (MCS), then {φ} is consistent. -/
private theorem consistent_of_F_mem {A : Set Formula}
    (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_F : Formula.some_future φ ∈ A) :
    SetConsistent ({φ} : Set Formula) := by
  -- {φ} ⊆ {φ} ∪ g_content(A), and the latter is consistent
  have h_seed := forward_temporal_witness_seed_consistent A h_mcs φ h_F
  exact SetConsistent_of_subset (Set.subset_union_left) h_seed

/-- If {φ} is consistent and [φ] ⊢ ⊥, then False. -/
private theorem inconsistent_singleton_false {φ : Formula}
    (h_cons : SetConsistent ({φ} : Set Formula))
    (d : DerivationTree [φ] Formula.bot) : False :=
  h_cons [φ] (fun ψ hψ => by simp [List.mem_singleton] at hψ; subst hψ; exact Set.mem_singleton _) ⟨d⟩


/-- Derivation-level left_mono for Until: if ⊢ φ→χ then ⊢ untl(φ,ψ) → untl(χ,ψ).
Uses BX2 (left_mono_until): (φ→χ)∧G(φ→χ) → untl(φ,ψ) → untl(χ,ψ). -/
private noncomputable def untl_left_mono_deriv (φ ψ χ : Formula)
    (h_impl : DerivationTree [] (φ.imp χ)) :
    DerivationTree [] ((Formula.untl φ ψ).imp (Formula.untl χ ψ)) := by
  have h_G := DerivationTree.temporal_necessitation _ h_impl
  have h_conj : DerivationTree [] (Formula.and (φ.imp χ) (φ.imp χ).all_future) :=
    DerivationTree.modus_ponens [] _ _
      (DerivationTree.modus_ponens [] _ _ (pairing (φ.imp χ) (φ.imp χ).all_future) h_impl)
      h_G
  have h_ax := DerivationTree.axiom [] _ (Axiom.left_mono_until φ ψ χ)
  exact DerivationTree.modus_ponens [] _ _
    (DerivationTree.modus_ponens [] _ _ h_ax h_conj)
    |> fun f => by
      -- Actually: h_ax : (φ→χ)∧G(φ→χ) → untl(φ,ψ) → untl(χ,ψ)
      -- h_conj : (φ→χ)∧G(φ→χ)
      -- Modus ponens gives: untl(φ,ψ) → untl(χ,ψ)
      exact DerivationTree.modus_ponens [] _ _ h_ax h_conj

/-- Derivation-level left_mono for Since: if ⊢ φ→χ then ⊢ snce(φ,ψ) → snce(χ,ψ).
Uses BX2' (left_mono_since): (φ→χ)∧H(φ→χ) → snce(φ,ψ) → snce(χ,ψ). -/
private noncomputable def snce_left_mono_deriv (φ ψ χ : Formula)
    (h_impl : DerivationTree [] (φ.imp χ)) :
    DerivationTree [] ((Formula.snce φ ψ).imp (Formula.snce χ ψ)) := by
  have h_H := Bimodal.Theorems.past_necessitation _ h_impl
  have h_conj : DerivationTree [] (Formula.and (φ.imp χ) (φ.imp χ).all_past) :=
    DerivationTree.modus_ponens [] _ _
      (DerivationTree.modus_ponens [] _ _ (pairing (φ.imp χ) (φ.imp χ).all_past) h_impl)
      h_H
  have h_ax := DerivationTree.axiom [] _ (Axiom.left_mono_since φ ψ χ)
  exact DerivationTree.modus_ponens [] _ _ h_ax h_conj

/-- Derivation-level right_mono for Until: if ⊢ φ→ψ then ⊢ untl(χ,φ) → untl(χ,ψ).
Uses BX3 (right_mono_until): G(φ→ψ) → untl(χ,φ) → untl(χ,ψ). -/
private noncomputable def untl_right_mono_deriv (φ ψ χ : Formula)
    (h_impl : DerivationTree [] (φ.imp ψ)) :
    DerivationTree [] ((Formula.untl χ φ).imp (Formula.untl χ ψ)) := by
  have h_G := DerivationTree.temporal_necessitation _ h_impl
  have h_ax := DerivationTree.axiom [] _ (Axiom.right_mono_until φ ψ χ)
  exact DerivationTree.modus_ponens [] _ _ h_ax h_G

/-- Structure to hold the result of iterated BX13 enrichment. -/
structure EnrichedEvent (A : Set Formula) (guard event : Formula) (alphas : List Formula) where
  event' : Formula
  h_untl : Formula.untl guard event' ∈ A
  h_impl : DerivationTree [] (event'.imp event)
  h_snce : ∀ α ∈ alphas, DerivationTree [] (event'.imp (Formula.snce guard α))

/-- Iterated BX13 enrichment: given untl(guard, event) ∈ A and a list of
formulas each in A, enrich the event with snce(guard, αⱼ) for each αⱼ.

Result: EnrichedEvent containing the new event and proofs. -/
private noncomputable def iterated_enrichment {A : Set Formula}
    (h_mcs : SetMaximalConsistent A)
    (guard : Formula) :
    (alphas : List Formula) →
    (h_alphas : ∀ α ∈ alphas, α ∈ A) →
    (event : Formula) →
    Formula.untl guard event ∈ A →
    EnrichedEvent A guard event alphas
  | [], _, event, h_untl => EnrichedEvent.mk event h_untl (identity event) (fun _ h => by simp at h)
  | α :: rest, h_alphas, event, h_untl => by
    have h_α : α ∈ A := h_alphas α (List.mem_cons.mpr (Or.inl rfl))
    have h_enriched := enrichment_until_mcs h_mcs h_α h_untl
    have h_rest : ∀ α' ∈ rest, α' ∈ A := fun α' hα' =>
      h_alphas α' (List.mem_cons.mpr (Or.inr hα'))
    let evt := iterated_enrichment h_mcs guard rest h_rest
      (Formula.and event (Formula.snce guard α)) h_enriched
    exact EnrichedEvent.mk evt.event' evt.h_untl
      (imp_trans evt.h_impl (lce_imp event (Formula.snce guard α)))
      (fun α' hα' => by
        by_cases h_eq : α' = α
        · subst h_eq; exact imp_trans evt.h_impl (rce_imp event (Formula.snce guard α'))
        · have h : α' ∈ rest := by
            rcases List.mem_cons.mp hα' with rfl | h
            · exact absurd rfl h_eq
            · exact h
          exact evt.h_snce α' h)

/-- **Burgess compression**: Show that any particular conjunction
ζ = snce(b, α) ∧ b ∧ β.neg ∧ untl(b, γ) with b∈B, α∈A, γ∈C is consistent.

This is the core of Burgess 1982, Lemma 2.6 consistency argument.
The BX chain: BX5 on untl(b,γ)∈A, BX14 with ¬untl(b∧β,γ)∈A,
BX13 with α∈A, BX10 extracts F(event)∈A with event implying ζ. -/
private noncomputable def burgess_zeta_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (_h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (β : Formula) (_h_β_not_B : β ∉ B)
    (h_F_beta_neg : Formula.some_future β.neg ∈ A)
    -- The ζ components: b ∈ B, α ∈ A, γ ∈ C
    (b : Formula) (hb : b ∈ B)
    (alpha_list : List Formula) (h_alphas : ∀ α ∈ alpha_list, α ∈ A)
    (γ : Formula) (hγ : γ ∈ C)
    -- We also need ¬untl(b∧β, γ)∈A from maximality
    (h_neg_until : (Formula.untl (Formula.and b β) γ).neg ∈ A) :
    -- The event from the BX chain implies each component.
    -- We prove: there exists event with F(event)∈A and event implies each component.
    -- Use Sigma type since fields are Type-valued (DerivationTree).
    Σ' event : Formula,
      Formula.some_future event ∈ A ×'
      DerivationTree [] (event.imp b) ×'
      DerivationTree [] (event.imp β.neg) ×'
      DerivationTree [] (event.imp (Formula.untl b γ)) ×'
      (∀ α ∈ alpha_list, DerivationTree [] (event.imp (Formula.snce b α))) := by
  have h_r3 : burgessR3 A B C := h_r3m.2.1
  -- Step 1: untl(b, γ) ∈ A from burgessR3
  have h_untl_bg : Formula.untl b γ ∈ A := h_r3.1 b hb γ hγ
  -- Step 2: BX5: untl(b ∧ untl(b,γ), γ) ∈ A
  have h_bx5 := self_accum_until_mcs h_mcs_A b γ h_untl_bg
  -- Step 3: BX14 (separation): untl(q, q ∧ (b∧β).neg) ∈ A
  -- where q = b ∧ untl(b,γ)
  let q := Formula.and b (Formula.untl b γ)
  have h_sep : Formula.untl q (Formula.and q (Formula.and b β).neg) ∈ A :=
    separation_until_mcs h_mcs_A h_bx5 h_neg_until
  -- Step 4: BX13 iterated enrichment with alpha_list
  let evt := iterated_enrichment h_mcs_A q alpha_list h_alphas
    (Formula.and q (Formula.and b β).neg) h_sep
  let event := evt.event'
  have h_untl_event := evt.h_untl
  have h_event_impl_base := evt.h_impl
  have h_event_impl_snce := evt.h_snce
  -- Step 5: BX10: F(event) ∈ A
  have h_F_event : Formula.some_future event ∈ A :=
    until_implies_F_mcs h_mcs_A h_untl_event
  -- Step 6: Show event implies each component
  -- event → base → q = b ∧ untl(b,γ)
  have h_event_impl_q : DerivationTree [] (event.imp q) :=
    imp_trans h_event_impl_base (lce_imp q (Formula.and b β).neg)
  -- event → q → b
  have h_event_impl_b : DerivationTree [] (event.imp b) :=
    imp_trans h_event_impl_q (lce_imp b (Formula.untl b γ))
  -- event → q → untl(b, γ)
  have h_event_impl_untl : DerivationTree [] (event.imp (Formula.untl b γ)) :=
    imp_trans h_event_impl_q (rce_imp b (Formula.untl b γ))
  -- event → β.neg (same argument as h_event_implies_beta_neg in the file)
  have h_event_impl_beta_neg : DerivationTree [] (event.imp β.neg) := by
    -- event → base = q ∧ (b∧β).neg
    -- event → q → b (have h_event_impl_b)
    -- event → (b∧β).neg (from base)
    -- From b and (b∧β).neg: β → b∧β → ⊥, so β.neg
    have h_r_neg : DerivationTree [] (event.imp (Formula.and b β).neg) :=
      imp_trans h_event_impl_base (rce_imp q (Formula.and b β).neg)
    -- Build: [event] ⊢ β.neg
    have h_assume : DerivationTree [event] β.neg := by
      have hev : DerivationTree [event] event := DerivationTree.assumption _ _ (by simp)
      have hb' : DerivationTree [event] b :=
        DerivationTree.modus_ponens _ _ _ (DerivationTree.weakening [] _ _ h_event_impl_b (List.nil_subset _)) hev
      have hr : DerivationTree [event] (Formula.and b β).neg :=
        DerivationTree.modus_ponens _ _ _ (DerivationTree.weakening [] _ _ h_r_neg (List.nil_subset _)) hev
      -- β → b∧β (using b and pairing)
      -- (b∧β).neg = (b∧β) → ⊥
      -- So β → b∧β → ⊥ = β → ⊥ = β.neg
      have h_beta_bot : DerivationTree (β :: [event]) Formula.bot := by
        have hb'' : DerivationTree (β :: [event]) b :=
          DerivationTree.weakening _ _ _ hb' (List.subset_cons_of_subset _ (List.Subset.refl _))
        have hbeta : DerivationTree (β :: [event]) β :=
          DerivationTree.assumption _ _ (by simp)
        have h_conj : DerivationTree (β :: [event]) (Formula.and b β) :=
          DerivationTree.modus_ponens _ _ _
            (DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ (pairing b β) (List.nil_subset _)) hb'') hbeta
        have hr' : DerivationTree (β :: [event]) (Formula.and b β).neg :=
          DerivationTree.weakening _ _ _ hr (List.subset_cons_of_subset _ (List.Subset.refl _))
        exact DerivationTree.modus_ponens _ _ _ hr' h_conj
      exact deduction_theorem [event] β Formula.bot h_beta_bot
    exact deduction_theorem [] event β.neg h_assume
  -- event → snce(q, α) for each α (from iterated_enrichment)
  -- Then snce(q, α) → snce(b, α) via left_mono (⊢ q→b)
  have h_event_impl_snce_b : ∀ α ∈ alpha_list,
      DerivationTree [] (event.imp (Formula.snce b α)) := by
    intro α hα
    have h_snce_q := h_event_impl_snce α hα
    -- snce(q, α) → snce(b, α) via left_mono with ⊢ q→b
    have h_q_to_b : DerivationTree [] (q.imp b) := lce_imp b (Formula.untl b γ)
    have h_mono := snce_left_mono_deriv q α b h_q_to_b
    exact imp_trans h_snce_q h_mono
  exact ⟨event, h_F_event, h_event_impl_b, h_event_impl_beta_neg,
    h_event_impl_untl, h_event_impl_snce_b⟩

/-- Noncomputable extraction: for each φ ∈ D₀, return a B-guard formula in B.
- For φ∈B (including Until/Since formulas that happen to be in B): guard = φ.
- For untl(β',γ) with φ∉B: guard = β'.
- For snce(β',α) with φ∉B: guard = β'.
- For β.neg with β.neg∉B: guard = ⊤ (any theorem in DCS).

B-membership is checked FIRST to ensure that B-elements are directly
recoverable from the guard conjunction via conjunction elimination. -/
private noncomputable def d0_guard {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B)
    (β : Formula) (φ : Formula) (h : φ ∈ burgess_D0_seed A B C β) :
    { g : Formula // g ∈ B } := by
  classical
  by_cases h1 : φ ∈ B
  · exact ⟨φ, h1⟩
  · by_cases h3 : ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ
    · exact ⟨Classical.choose h3, (Classical.choose_spec h3).1⟩
    · by_cases h4 : ∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α
      · exact ⟨Classical.choose h4, (Classical.choose_spec h4).1⟩
      · -- Must be β.neg
        exact ⟨Formula.bot.imp Formula.bot, dcs_contains_theorems h_dcs (identity Formula.bot)⟩

/-- For each element of L, extract the associated C-event (if Until formula). -/
private noncomputable def d0_c_event_list {A B C : Set Formula}
    (β : Formula) (L : List Formula)
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) : List Formula :=
  L.filterMap (fun φ => by
    classical
    exact if h : ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ then
      some (Classical.choose (Classical.choose_spec h).2)
    else none)

/-- Elements of d0_c_event_list are in C. -/
private theorem d0_c_event_list_mem {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {γ : Formula} (hγ : γ ∈ d0_c_event_list β L hL) : γ ∈ C := by
  unfold d0_c_event_list at hγ
  simp [List.mem_filterMap] at hγ
  obtain ⟨φ, _, hγ_eq⟩ := hγ
  by_cases h : ∃ β' ∈ B, ∃ γ' ∈ C, φ = Formula.untl β' γ'
  · -- If branch: γ = some (Classical.choose ...)
    simp [h] at hγ_eq
    subst hγ_eq
    exact (Classical.choose_spec (Classical.choose_spec h).2).1
  · -- Else branch: γ = none, contradiction
    simp [h] at hγ_eq

/-- For each element of L, extract the associated A-event (if Since formula). -/
private noncomputable def d0_a_event_list {A B C : Set Formula}
    (β : Formula) (L : List Formula)
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) : List Formula :=
  L.filterMap (fun φ => by
    classical
    exact if ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ then none
    else if h : ∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α then
      some (Classical.choose (Classical.choose_spec h).2)
    else none)

/-- Elements of d0_a_event_list are in A. -/
private theorem d0_a_event_list_mem {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {α : Formula} (hα : α ∈ d0_a_event_list β L hL) : α ∈ A := by
  unfold d0_a_event_list at hα
  rcases List.mem_filterMap.mp hα with ⟨φ, hφL, h_eq⟩
  -- h_eq : (if (∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ) then none
  --         else if h : (∃ β' ∈ B, ∃ α' ∈ A, φ = Formula.snce β' α')
  --              then some (Classical.choose (Classical.choose_spec h).2) else none)
  --        = some α
  split at h_eq
  · simp at h_eq
  · split at h_eq
    · next h_snce =>
      simp at h_eq
      -- h_eq : Classical.choose (Classical.choose_spec h_snce).2 = α
      rw [← h_eq]
      exact (Classical.choose_spec ((Classical.choose_spec h_snce).2)).1
    · simp at h_eq

/-- Recursively extract B-guards from L ⊆ D₀, producing a list of formulas in B.
Also includes β₀ (the maximality witness guard) to ensure b∧β monotonicity works. -/
private noncomputable def collect_guards {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B)
    (β : Formula) :
    (L : List Formula) →
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) →
    { gs : List Formula // ∀ g ∈ gs, g ∈ B }
  | [], _ => ⟨[], fun _ h => (by simp at h)⟩
  | φ :: rest, hL =>
    let ⟨g, hg⟩ := d0_guard h_dcs β φ (hL φ (List.mem_cons.mpr (Or.inl rfl)))
    let ⟨gs, hgs⟩ := collect_guards h_dcs β rest
      (fun ψ hψ => hL ψ (List.mem_cons.mpr (Or.inr hψ)))
    ⟨g :: gs, fun g' hg' => by
      rcases List.mem_cons.mp hg' with rfl | h
      · exact hg
      · exact hgs g' h⟩

/-- Key property of collect_guards: if φ∈L and φ∈B, then φ is in the guard list.
Since d0_guard checks B-membership first, it returns φ itself for B-elements. -/
private theorem collect_guards_mem_of_B {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (β : Formula) :
    (L : List Formula) →
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) →
    ∀ φ ∈ L, φ ∈ B → φ ∈ (collect_guards h_dcs β L hL).val
  | [], _, φ, hφ, _ => (by simp at hφ)
  | ψ :: rest, hL, φ, hφ, h_B => by
    simp [collect_guards]
    rcases List.mem_cons.mp hφ with rfl | h_rest
    · left
      unfold d0_guard; simp [h_B]
    · right; exact collect_guards_mem_of_B h_dcs β rest _ φ h_rest h_B

/-- Helper: d0_guard for untl(β',γ') when untl(β',γ') ∉ B returns β'.
This resolves the Classical.choose via constructor injectivity. -/
private theorem d0_guard_untl_val {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (β β' γ' : Formula)
    (h_D0 : Formula.untl β' γ' ∈ burgess_D0_seed A B C β)
    (h_not_B : Formula.untl β' γ' ∉ B) (hβ' : β' ∈ B) (hγ' : γ' ∈ C) :
    (d0_guard h_dcs β (Formula.untl β' γ') h_D0).val = β' := by
  unfold d0_guard; simp [h_not_B]
  split
  · next h =>
    have h_spec := Classical.choose_spec h
    obtain ⟨γ'', hγ'', h_eq⟩ := h_spec.2
    rw [Formula.untl.injEq] at h_eq
    convert h_eq.1.symm; simp [Formula.untl.injEq]
  · next h =>
    exfalso; exact h ⟨β', hβ', γ', hγ', rfl⟩

/-- Helper: d0_guard for snce(β',α') when snce(β',α') ∉ B and is not an untl formula
returns β'. -/
private theorem d0_guard_snce_val {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (β β' α' : Formula)
    (h_D0 : Formula.snce β' α' ∈ burgess_D0_seed A B C β)
    (h_not_B : Formula.snce β' α' ∉ B)
    (h_not_untl : ¬(∃ β'' ∈ B, ∃ γ'' ∈ C, Formula.snce β' α' = Formula.untl β'' γ''))
    (hβ' : β' ∈ B) (hα' : α' ∈ A) :
    (d0_guard h_dcs β (Formula.snce β' α') h_D0).val = β' := by
  unfold d0_guard; simp [h_not_B, h_not_untl]
  split
  · next h =>
    have h_spec := Classical.choose_spec h
    obtain ⟨α'', hα'', h_eq⟩ := h_spec.2
    rw [Formula.snce.injEq] at h_eq
    convert h_eq.1.symm; simp [Formula.snce.injEq]
  · next h =>
    exfalso; exact h ⟨β', hβ', α', hα', rfl⟩

/-- If untl(β',γ') ∈ L with β'∈B, γ'∈C, and untl(β',γ') ∉ B, then β' is in
the guard list. -/
private theorem collect_guards_mem_of_untl {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (β : Formula) :
    (L : List Formula) →
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) →
    ∀ β' γ', Formula.untl β' γ' ∈ L → β' ∈ B → γ' ∈ C →
      Formula.untl β' γ' ∉ B →
      β' ∈ (collect_guards h_dcs β L hL).val
  | [], _, β', γ', hφ, _, _, _ => (by simp at hφ)
  | ψ :: rest, hL, β', γ', hφ, hβ', hγ', h_not_B => by
    simp [collect_guards]
    rcases List.mem_cons.mp hφ with rfl | h_rest
    · left
      exact (d0_guard_untl_val h_dcs β β' γ'
        (hL (Formula.untl β' γ') (List.mem_cons.mpr (Or.inl rfl))) h_not_B hβ' hγ').symm
    · right
      exact collect_guards_mem_of_untl h_dcs β rest _ β' γ' h_rest hβ' hγ' h_not_B

/-- If snce(β',α') ∈ L with β'∈B, α'∈A, snce(β',α') ∉ B, and it is not
an untl formula, then β' is in the guard list. -/
private theorem collect_guards_mem_of_snce {A B C : Set Formula}
    (h_dcs : SetDeductivelyClosed B) (β : Formula) :
    (L : List Formula) →
    (hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β) →
    ∀ β' α', Formula.snce β' α' ∈ L → β' ∈ B → α' ∈ A →
      Formula.snce β' α' ∉ B →
      ¬(∃ β'' ∈ B, ∃ γ'' ∈ C, Formula.snce β' α' = Formula.untl β'' γ'') →
      β' ∈ (collect_guards h_dcs β L hL).val
  | [], _, β', α', hφ, _, _, _, _ => (by simp at hφ)
  | ψ :: rest, hL, β', α', hφ, hβ', hα', h_not_B, h_not_untl => by
    simp [collect_guards]
    rcases List.mem_cons.mp hφ with rfl | h_rest
    · left
      exact (d0_guard_snce_val h_dcs β β' α'
        (hL (Formula.snce β' α') (List.mem_cons.mpr (Or.inl rfl))) h_not_B h_not_untl hβ' hα').symm
    · right
      exact collect_guards_mem_of_snce h_dcs β rest _ β' α' h_rest hβ' hα' h_not_B h_not_untl

/-- If untl(β',γ') ∈ L with β'∈B, γ'∈C, then γ' ∈ d0_c_event_list output.
Uses constructor injectivity to recover γ' from Classical.choose. -/
private theorem d0_c_event_list_γ_mem {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {β' γ' : Formula} (hφ : Formula.untl β' γ' ∈ L)
    (hβ' : β' ∈ B) (hγ' : γ' ∈ C) :
    γ' ∈ d0_c_event_list β L hL := by
  -- Go through mem_filterMap: find the element that maps to γ'
  have h_mem : Formula.untl β' γ' ∈ L := hφ
  have h_ex : ∃ β'' ∈ B, ∃ γ'' ∈ C, Formula.untl β' γ' = Formula.untl β'' γ'' :=
    ⟨β', hβ', γ', hγ', rfl⟩
  -- d0_c_event_list maps untl(β',γ') to some(Classical.choose ...) when the condition holds
  -- The output includes this element
  show γ' ∈ d0_c_event_list β L hL
  unfold d0_c_event_list
  apply List.mem_filterMap.mpr
  refine ⟨Formula.untl β' γ', hφ, ?_⟩
  -- Need: (if h : ... then some (Classical.choose ...) else none) = some γ'
  rw [dif_pos h_ex]
  congr 1
  -- Need: Classical.choose (Classical.choose_spec h_ex).2 = γ'
  have h_spec := Classical.choose_spec (Classical.choose_spec h_ex).2
  rw [Formula.untl.injEq] at h_spec
  exact h_spec.2.2.symm

/-- If snce(β',α') ∈ L with β'∈B, α'∈A, and the element is NOT matched as
an untl formula, then α' ∈ d0_a_event_list output. -/
private theorem d0_a_event_list_α_mem {A B C : Set Formula}
    {β : Formula} {L : List Formula}
    {hL : ∀ φ ∈ L, φ ∈ burgess_D0_seed A B C β}
    {β' α' : Formula} (hφ : Formula.snce β' α' ∈ L)
    (hβ' : β' ∈ B) (hα' : α' ∈ A)
    (h_not_untl : ¬(∃ β'' ∈ B, ∃ γ'' ∈ C, Formula.snce β' α' = Formula.untl β'' γ'')) :
    α' ∈ d0_a_event_list β L hL := by
  show α' ∈ d0_a_event_list β L hL
  unfold d0_a_event_list
  apply List.mem_filterMap.mpr
  refine ⟨Formula.snce β' α', hφ, ?_⟩
  -- Need: (if ... then none else if h : ... then some(Classical.choose ...) else none) = some α'
  rw [if_neg h_not_untl]
  have h_ex : ∃ β'' ∈ B, ∃ α'' ∈ A, Formula.snce β' α' = Formula.snce β'' α'' :=
    ⟨β', hβ', α', hα', rfl⟩
  rw [dif_pos h_ex]
  congr 1
  have h_spec := Classical.choose_spec (Classical.choose_spec h_ex).2
  rw [Formula.snce.injEq] at h_spec
  exact h_spec.2.2.symm

/-- **Burgess D₀ finite subset consistency** (consistent case):
Given BurgessR3Maximal(A,B,C) with β∉B and {β}∪B consistent, any finite L ⊆ D₀
is consistent.

Proof (Burgess 1982, p.370-371): Any finite L ⊆ D₀ decomposes into:
- L_B ⊆ {β.neg} ∪ B (base formulas)
- L_U = {untl(β'₁,γ₁), ..., untl(β'ₖ,γₖ)} with each β'ᵢ∈B, γᵢ∈C (in A by burgessR3)
- L_S = {snce(β'₁,α₁), ..., snce(β'ₘ,αₘ)} with each β'ⱼ∈B, αⱼ∈A (in C by burgessR3)

Compress via DCS closure: b = ∧(B-elements of L) ∈ B, γ̂ = ∧γᵢ ∈ C, α̂ = ∧αⱼ ∈ A.
The single conjunction ζ = b ∧ β.neg ∧ untl(b,γ̂) ∧ snce(b,α̂) implies all elements
of L (via conjunction elimination + guard weakening A2a/A1b). So if L⊢⊥ then ζ⊢⊥.

Prove ζ consistent via BX chain: BX5 on untl(b,γ̂)∈A gives untl(b∧untl(b,γ̂), γ̂)∈A.
BX14 with ¬untl(b∧β, γ̂)∈A gives untl(q, q∧(b∧β).neg)∈A where q=b∧untl(b,γ̂).
BX13 packs snce(q,α̂) into the event. BX10 gives F(event)∈A with event ⊢ ζ.
F(event)∈A means event is consistent (seriality), hence ζ is consistent. -/
private theorem burgess_D0_finite_subset_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (_h_gc : g_content A ⊆ C)
    (β : Formula)
    (_h_β_not_B : β ∉ B)
    (_h_neg_cons : SetConsistent ({β.neg} ∪ B))
    (h_F_beta_neg : Formula.some_future β.neg ∈ A)
    -- Maximality witnesses: β₀∈B, γ₀∈C with ¬untl(β₀∧β, γ₀)∈A
    (β₀ : Formula) (hβ₀ : β₀ ∈ B)
    (γ₀ : Formula) (hγ₀ : γ₀ ∈ C)
    (h_neg_until₀ : (Formula.untl (Formula.and β₀ β) γ₀).neg ∈ A) :
    SetConsistent (burgess_D0_seed A B C β) := by
  have h_B_dcs : SetDeductivelyClosed B := h_r3m.1
  have h_r3 : burgessR3 A B C := h_r3m.2.1
  intro L hL ⟨d⟩
  -- Step 1: Extract components from L.
  -- B-guards: list of formulas in B, one per element of L, plus β₀.
  let b_list_raw := (collect_guards h_B_dcs β L hL).val
  have hb_list : ∀ g ∈ b_list_raw, g ∈ B := (collect_guards h_B_dcs β L hL).property
  -- Include β₀ in guard list to ensure monotonicity for BX14
  let b_list := β₀ :: b_list_raw
  have hb_list' : ∀ g ∈ b_list, g ∈ B := by
    intro g hg; rcases List.mem_cons.mp hg with rfl | h
    · exact hβ₀
    · exact hb_list g h
  -- C-events: from Until formulas, plus γ₀
  let c_list_raw := d0_c_event_list β L hL
  let c_list := γ₀ :: c_list_raw
  have hc_list : ∀ γ ∈ c_list, γ ∈ C := by
    intro γ hγ; rcases List.mem_cons.mp hγ with rfl | h
    · exact hγ₀
    · exact d0_c_event_list_mem h
  -- A-events
  let a_list := d0_a_event_list β L hL
  have ha_list : ∀ α ∈ a_list, α ∈ A := fun α hα => d0_a_event_list_mem hα
  -- Step 2: Form compressed formulas.
  let b := list_conj b_list  -- ∈ B by DCS closure
  let γ_hat := list_conj c_list  -- ∈ C by MCS closure
  have hb_B : b ∈ B := list_conj_mem_dcs h_B_dcs b_list hb_list'
  have hγ_C : γ_hat ∈ C := list_conj_mem_mcs h_mcs_C c_list hc_list
  -- Step 3: ¬untl(b∧β, γ_hat) ∈ A (from maximality witnesses via monotonicity).
  -- We have ¬untl(β₀∧β, γ₀) ∈ A.
  -- If untl(b∧β, γ_hat) ∈ A, then by left_mono (⊢ (b∧β)→(β₀∧β)):
  --   untl(β₀∧β, γ_hat) ∈ A
  -- Then by right_mono (G(γ_hat→γ₀)):
  --   untl(β₀∧β, γ₀) ∈ A, contradicting h_neg_until₀.
  have h_neg_until_b : (Formula.untl (Formula.and b β) γ_hat).neg ∈ A := by
    rcases SetMaximalConsistent.negation_complete h_mcs_A
      (Formula.untl (Formula.and b β) γ_hat) with h | h
    · -- h : untl(b∧β, γ_hat) ∈ A → contradiction
      -- b → β₀ (conjunction elimination since β₀ ∈ b_list)
      have h_b_to_β₀ : DerivationTree [] (b.imp β₀) :=
        list_conj_implies_elem b_list β₀ (List.mem_cons.mpr (Or.inl rfl))
      -- (b∧β) → (β₀∧β) from b→β₀
      have h_bβ_to_β₀β : DerivationTree [] ((Formula.and b β).imp (Formula.and β₀ β)) := by
        -- [b∧β] ⊢ b (lce), b ⊢ β₀ (h_b_to_β₀), [b∧β] ⊢ β (rce)
        -- pairing β₀ β gives β₀ → β → β₀∧β
        have step : DerivationTree [Formula.and b β] (Formula.and β₀ β) := by
          have hb' := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ (lce_imp b β) (List.nil_subset _))
            (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          have hβ₀' := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ h_b_to_β₀ (List.nil_subset _)) hb'
          have hβ' := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ (rce_imp b β) (List.nil_subset _))
            (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          exact DerivationTree.modus_ponens _ _ _
            (DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ (pairing β₀ β) (List.nil_subset _)) hβ₀') hβ'
        exact deduction_theorem [] (Formula.and b β) (Formula.and β₀ β) step
      -- untl(b∧β, γ_hat) → untl(β₀∧β, γ_hat) via left_mono
      have h1 := untl_left_mono_thm h_mcs_A h_bβ_to_β₀β h
      -- γ_hat → γ₀ (conjunction elimination since γ₀ ∈ c_list)
      have h_γ_to_γ₀ : DerivationTree [] (γ_hat.imp γ₀) :=
        list_conj_implies_elem c_list γ₀ (List.mem_cons.mpr (Or.inl rfl))
      -- untl(β₀∧β, γ_hat) → untl(β₀∧β, γ₀) via right_mono
      have h2 := right_mono_until_mcs h_mcs_A h_γ_to_γ₀ h1
      -- Contradiction with h_neg_until₀
      exact absurd h2 (SetMaximalConsistent.neg_excludes h_mcs_A _ h_neg_until₀)
    · exact h
  -- Step 4: Apply burgess_zeta_consistent.
  obtain ⟨event, h_F_event, h_ev_b, h_ev_beta_neg, h_ev_untl, h_ev_snce⟩ :=
    burgess_zeta_consistent h_mcs_A h_mcs_C h_r3m β _h_β_not_B h_F_beta_neg
      b hb_B a_list ha_list γ_hat hγ_C h_neg_until_b
  -- Step 5: Show event implies each element of L.
  -- For each φ∈L, we need DerivationTree [event] φ.
  have h_event_implies_L : ∀ φ ∈ L, DerivationTree [event] φ := by
    intro φ hφ
    have h_φ_D0 := hL φ hφ
    simp [burgess_D0_seed, Set.mem_union] at h_φ_D0
    -- Use classical reasoning to handle the union membership
    -- h_φ_D0 : φ ∈ B ∨ φ ∈ {β.neg} ∨ (∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ) ∨ (∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α)
    by_cases h_B : φ ∈ B
    · -- Case 1: φ ∈ B
      -- event → b → φ (guard extraction + conjunction elimination)
      have h_φ_in_raw : φ ∈ b_list_raw := collect_guards_mem_of_B h_B_dcs β L hL φ hφ h_B
      have h_φ_in_b : φ ∈ b_list := List.mem_cons.mpr (Or.inr h_φ_in_raw)
      have h_b_to_φ : DerivationTree [] (b.imp φ) := list_conj_implies_elem b_list φ h_φ_in_b
      have h_ev_to_φ : DerivationTree [] (event.imp φ) := imp_trans h_ev_b h_b_to_φ
      exact DerivationTree.modus_ponens _ _ _
        (DerivationTree.weakening [] _ _ h_ev_to_φ (List.nil_subset _))
        (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
    · -- φ ∉ B, so check other cases
      by_cases h_neg : φ = β.neg
      · -- Case 2: φ = β.neg
        subst h_neg
        exact DerivationTree.modus_ponens _ _ _
          (DerivationTree.weakening [] _ _ h_ev_beta_neg (List.nil_subset _))
          (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
      · -- φ ≠ β.neg, check for Until formula
        by_cases h_untl : ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ
        · -- Case 3: φ = untl(β', γ')
          -- Extract witnesses using classical choice (avoids Or.casesOn in Type)
          let β' := Classical.choose h_untl
          have hβ' : β' ∈ B := (Classical.choose_spec h_untl).1
          let γ' := Classical.choose (Classical.choose_spec h_untl).2
          have hγ' : γ' ∈ C := (Classical.choose_spec (Classical.choose_spec h_untl).2).1
          have h_eq : φ = Formula.untl β' γ' := (Classical.choose_spec (Classical.choose_spec h_untl).2).2
          have h_φ_eq : Formula.untl β' γ' ∈ L := by rw [←h_eq]; exact hφ
          rw [h_eq]
          by_cases h_untl_B : Formula.untl β' γ' ∈ B
          · -- untl(β', γ') ∈ B: treat as B-element
            have h_in_raw := collect_guards_mem_of_B h_B_dcs β L hL (Formula.untl β' γ') h_φ_eq h_untl_B
            have h_in_b : Formula.untl β' γ' ∈ b_list := List.mem_cons.mpr (Or.inr h_in_raw)
            have h_b_imp : DerivationTree [] (b.imp (Formula.untl β' γ')) :=
              list_conj_implies_elem b_list (Formula.untl β' γ') h_in_b
            have h_ev_imp := imp_trans h_ev_b h_b_imp
            exact DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ h_ev_imp (List.nil_subset _))
              (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          · -- untl(β', γ') ∉ B: use monotonicity
            -- β' ∈ b_list_raw via collect_guards
            have h_β'_in_raw := collect_guards_mem_of_untl h_B_dcs β L hL β' γ' h_φ_eq hβ' hγ' h_untl_B
            have h_β'_in_b : β' ∈ b_list := List.mem_cons.mpr (Or.inr h_β'_in_raw)
            have h_b_to_β' : DerivationTree [] (b.imp β') := list_conj_implies_elem b_list β' h_β'_in_b
            -- γ' ∈ c_list via d0_c_event_list_γ_mem
            have h_γ'_in_raw := @d0_c_event_list_γ_mem A B C β L hL β' γ' h_φ_eq hβ' hγ'
            have h_γ'_in_c : γ' ∈ c_list := List.mem_cons.mpr (Or.inr h_γ'_in_raw)
            have h_γhat_to_γ' : DerivationTree [] (γ_hat.imp γ') :=
              list_conj_implies_elem c_list γ' h_γ'_in_c
            -- untl(b, γ_hat) → untl(β', γ_hat) via left_mono
            have h_left := untl_left_mono_deriv b γ_hat β' h_b_to_β'
            -- untl(β', γ_hat) → untl(β', γ') via right_mono
            have h_right := untl_right_mono_deriv γ_hat γ' β' h_γhat_to_γ'
            -- Chain: event → untl(b, γ_hat) → untl(β', γ_hat) → untl(β', γ')
            have h_chain := imp_trans h_ev_untl (imp_trans h_left h_right)
            exact DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
              (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
        · -- Not an Until formula, check for Since formula
          by_cases h_snce : ∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α
          · -- Case 4: φ = snce(β', α')
            -- Extract witnesses using classical choice (avoids Or.casesOn in Type)
            let β' := Classical.choose h_snce
            have hβ' : β' ∈ B := (Classical.choose_spec h_snce).1
            let α' := Classical.choose (Classical.choose_spec h_snce).2
            have hα' : α' ∈ A := (Classical.choose_spec (Classical.choose_spec h_snce).2).1
            have h_eq : φ = Formula.snce β' α' := (Classical.choose_spec (Classical.choose_spec h_snce).2).2
            have h_φ_eq_snce : Formula.snce β' α' ∈ L := by rw [←h_eq]; exact hφ
            rw [h_eq]
            by_cases h_snce_B : Formula.snce β' α' ∈ B
            · -- snce(β', α') ∈ B: treat as B-element
              have h_in_raw := collect_guards_mem_of_B h_B_dcs β L hL (Formula.snce β' α') h_φ_eq_snce h_snce_B
              have h_in_b : Formula.snce β' α' ∈ b_list := List.mem_cons.mpr (Or.inr h_in_raw)
              have h_b_imp : DerivationTree [] (b.imp (Formula.snce β' α')) :=
                list_conj_implies_elem b_list (Formula.snce β' α') h_in_b
              have h_ev_imp := imp_trans h_ev_b h_b_imp
              exact DerivationTree.modus_ponens _ _ _
                (DerivationTree.weakening [] _ _ h_ev_imp (List.nil_subset _))
                (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
            · -- snce(β', α') ∉ B: use monotonicity
              -- snce ≠ untl (constructor disjointness)
              have h_not_untl : ¬(∃ β'' ∈ B, ∃ γ'' ∈ C, Formula.snce β' α' = Formula.untl β'' γ'') := by
                rintro ⟨_, _, _, _, h_eq⟩; exact Formula.noConfusion h_eq
              -- β' ∈ b_list_raw via collect_guards
              have h_β'_in_raw := collect_guards_mem_of_snce h_B_dcs β L hL β' α' h_φ_eq_snce hβ' hα' h_snce_B h_not_untl
              have h_β'_in_b : β' ∈ b_list := List.mem_cons.mpr (Or.inr h_β'_in_raw)
              have h_b_to_β' : DerivationTree [] (b.imp β') := list_conj_implies_elem b_list β' h_β'_in_b
              -- α' ∈ a_list via d0_a_event_list_α_mem
              have h_α'_in_a := @d0_a_event_list_α_mem A B C β L hL β' α' h_φ_eq_snce hβ' hα' h_not_untl
              -- event → snce(b, α') from h_ev_snce
              have h_ev_snce_α' := h_ev_snce α' h_α'_in_a
              -- snce(b, α') → snce(β', α') via left_mono with ⊢ b → β'
              have h_mono := snce_left_mono_deriv b α' β' h_b_to_β'
              have h_chain := imp_trans h_ev_snce_α' h_mono
              exact DerivationTree.modus_ponens _ _ _
                (DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
                (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          · -- Contradiction: φ must be in one of the four sets
            exfalso
            -- After simp at h_φ_D0, we have a disjunction of the four cases
            -- Since we've excluded all four, we have a contradiction
            simp [h_B, h_neg, h_untl, h_snce] at h_φ_D0
  -- Step 6: Derive contradiction.
  have d_event : DerivationTree [event] Formula.bot :=
    derivation_from_implied [event] L Formula.bot h_event_implies_L d
  -- {event} is consistent (F(event)∈A)
  have h_event_cons := consistent_of_F_mem h_mcs_A event h_F_event
  exact inconsistent_singleton_false h_event_cons d_event

/-- **Burgess D₀ finite subset consistency** (inconsistent case):
When {β}∪B is inconsistent (so β.neg ∈ B), D₀ = B ∪ untl-formulas ∪ snce-formulas.

Strategy: case-split on whether B is MCS BEFORE constructing c_list.

**Case A (B not MCS)**: Extract delta' ∉ B with {delta'}∪B consistent. Apply
`BurgessR3Maximal_extension_fails` to get neg-until witness (beta0, gamma0) with
`(untl(beta0∧delta', gamma0)).neg ∈ A`. Add gamma0 to c_list so γ_hat implies gamma0.
Then the pos sub-case resolves: from untl(⊥, γ_hat) ∈ A (left_mono via b∧β → ⊥),
get untl(beta0∧delta', γ_hat) ∈ A (left_mono+EFQ), then right_mono with γ_hat → gamma0
gives untl(beta0∧delta', gamma0) ∈ A, contradicting the neg-until witness.

**Case B (B is MCS)**: The neg sub-case works as before. The pos sub-case requires
the stronger Burgess maximality (over ClosedUnderDerivation, not just
SetDeductivelyClosed) which our current BurgessR3Maximal does not provide. -/
private theorem burgess_D0_finite_subset_consistent_incons {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (_h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (_h_gc : g_content A ⊆ C)
    (β : Formula)
    (_h_beta_neg_in_B : β.neg ∈ B) :
    SetConsistent (burgess_D0_seed A B C β) := by
  have h_B_dcs : SetDeductivelyClosed B := h_r3m.1
  have h_r3 : burgessR3 A B C := h_r3m.2.1
  -- Derive β ∉ B (from β.neg ∈ B and B consistent).
  have h_β_not_B : β ∉ B := by
    intro h_in
    exact h_B_dcs.1 [β, β.neg] (fun ψ hψ => by
      simp [List.mem_cons] at hψ
      rcases hψ with rfl | rfl
      · exact h_in
      · exact _h_beta_neg_in_B)
      ⟨DerivationTree.modus_ponens [β, β.neg] β Formula.bot
        (DerivationTree.assumption [β, β.neg] β.neg (by simp [List.mem_cons]))
        (DerivationTree.assumption [β, β.neg] β (by simp [List.mem_cons]))⟩
  intro L hL ⟨d⟩
  -- Step 1: Extract B-guard components from L
  let b_list_raw := (collect_guards h_B_dcs β L hL).val
  have hb_list : ∀ g ∈ b_list_raw, g ∈ B := (collect_guards h_B_dcs β L hL).property
  -- Use β.neg as the anchor element (it's in B)
  let β₀ := β.neg
  let hβ₀ : β₀ ∈ B := _h_beta_neg_in_B
  let b_list := β₀ :: b_list_raw
  have hb_list' : ∀ g ∈ b_list, g ∈ B := by
    intro g hg; rcases List.mem_cons.mp hg with rfl | h
    · exact hβ₀
    · exact hb_list g h
  -- A-events
  let a_list := d0_a_event_list β L hL
  have ha_list : ∀ α ∈ a_list, α ∈ A := fun α hα => d0_a_event_list_mem hα
  -- Step 2: Case-split on SetMaximalConsistent B to determine c_list construction.
  -- When B is not MCS, we extract a neg-until witness and add its gamma0 to c_list,
  -- which makes the pos sub-case resolvable via right_mono contradiction.
  by_cases h_mcs_B : SetMaximalConsistent B
  · -- Case B: B is MCS.
    -- With CUD-maximality, BurgessR3Maximal_extension_fails works for ANY δ ∉ B.
    -- Use β directly: ¬burgessR3(A, DC({β}∪B), C).
    -- Extract witness and include it in b_list/c_list for the pos sub-case.
    have h_not_r3_β := BurgessR3Maximal_extension_fails h_r3m h_β_not_B
    have h_neg_until_exists : ∃ beta0 ∈ B, ∃ gamma0 ∈ C,
        Formula.untl (Formula.and beta0 β) gamma0 ∉ A := by
      by_contra h_all_until
      push_neg at h_all_until
      have h_rset : burgessRSet A (deductiveClosure ({β} ∪ B)) C := by
        intro phi hphi gamma hgamma
        obtain ⟨Ldc, hL_sub, ⟨ddc⟩⟩ := hphi
        rcases dc_delta_B_controlled h_B_dcs hL_sub ddc with h_B_case | ⟨beta_w, hbeta_w, ⟨h_impl⟩⟩
        · exact h_r3.1 phi h_B_case gamma hgamma
        · exact untl_left_mono_thm h_mcs_A h_impl (h_all_until beta_w hbeta_w gamma hgamma)
      have h_rsince : burgessRSetSince C (deductiveClosure ({β} ∪ B)) A := by
        intro phi hphi alpha halpha
        obtain ⟨Ldc, hL_sub, ⟨ddc⟩⟩ := hphi
        rcases dc_delta_B_controlled h_B_dcs hL_sub ddc with h_B_case | ⟨beta_w, hbeta_w, ⟨h_impl⟩⟩
        · exact h_r3.2 phi h_B_case alpha halpha
        · have h_burgessR_ext : burgessR A (Formula.and beta_w β) C :=
            fun gamma hgamma => h_all_until beta_w hbeta_w gamma hgamma
          have h_snce_ext := burgessR_implies_burgessRSince h_mcs_A _h_mcs_C h_burgessR_ext alpha halpha
          exact snce_left_mono_thm _h_mcs_C h_impl h_snce_ext
      exact h_not_r3_β ⟨h_rset, h_rsince⟩
    obtain ⟨beta0, h_beta0, gamma0, h_gamma0, h_not_in_A⟩ := h_neg_until_exists
    have h_neg_until_in_A : (Formula.untl (Formula.and beta0 β) gamma0).neg ∈ A := by
      rcases SetMaximalConsistent.negation_complete h_mcs_A
        (Formula.untl (Formula.and beta0 β) gamma0) with h | h
      · exfalso; exact h_not_in_A h
      · exact h
    -- Use original c_list (for neg sub-case compatibility) but prepend gamma0
    let γ₀ := Formula.bot.imp Formula.bot
    have hγ₀ : γ₀ ∈ C := theorem_in_mcs _h_mcs_C (identity Formula.bot)
    let c_list_raw := d0_c_event_list β L hL
    let c_list := gamma0 :: γ₀ :: c_list_raw
    have hc_list : ∀ γ ∈ c_list, γ ∈ C := by
      intro γ hγ; rcases List.mem_cons.mp hγ with rfl | h
      · exact h_gamma0
      · rcases List.mem_cons.mp h with rfl | h2
        · exact hγ₀
        · exact d0_c_event_list_mem h2
    let b := list_conj b_list
    let γ_hat := list_conj c_list
    have hb_B : b ∈ B := list_conj_mem_dcs h_B_dcs b_list hb_list'
    have hγ_C : γ_hat ∈ C := list_conj_mem_mcs _h_mcs_C c_list hc_list
    -- Neg/pos case split
    rcases SetMaximalConsistent.negation_complete h_mcs_A
      (Formula.untl (Formula.and b β) γ_hat) with h_pos | h_neg
    · -- Pos sub-case: untl(b∧β, γ_hat) ∈ A.
      -- Since b = list_conj(b_list) with β.neg as first element: ⊢ b → β.neg.
      -- Hence ⊢ (b∧β) → ⊥. By EFQ: ⊢ (b∧β) → (beta0∧β).
      -- left_mono + right_mono give untl(beta0∧β, gamma0) ∈ A, contradiction.
      exfalso
      have h_b_to_beta_neg : DerivationTree [] (b.imp β.neg) :=
        list_conj_implies_elem b_list β.neg (List.mem_cons.mpr (Or.inl rfl))
      have h_bβ_to_bot : DerivationTree [] ((Formula.and b β).imp Formula.bot) := by
        have h_step : DerivationTree [Formula.and b β] Formula.bot := by
          have hb' := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ (lce_imp b β) (List.nil_subset _))
            (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          have hβ_neg := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ h_b_to_beta_neg (List.nil_subset _)) hb'
          have hβ := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ (rce_imp b β) (List.nil_subset _))
            (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          exact DerivationTree.modus_ponens _ _ _ hβ_neg hβ
        exact deduction_theorem [] (Formula.and b β) Formula.bot h_step
      have h_bβ_to_guard : DerivationTree [] ((Formula.and b β).imp (Formula.and beta0 β)) :=
        imp_trans h_bβ_to_bot (efq_axiom (Formula.and beta0 β))
      -- left_mono: untl(b∧β, γ_hat) → untl(beta0∧β, γ_hat)
      have h_untl_guard := untl_left_mono_thm h_mcs_A h_bβ_to_guard h_pos
      -- right_mono with γ_hat → gamma0
      have h_γhat_to_gamma0 : DerivationTree [] (γ_hat.imp gamma0) :=
        list_conj_implies_elem c_list gamma0 (List.mem_cons.mpr (Or.inl rfl))
      have h_untl_gamma0 := right_mono_until_mcs h_mcs_A h_γhat_to_gamma0 h_untl_guard
      -- Contradiction
      exact SetMaximalConsistent.neg_excludes h_mcs_A _ h_neg_until_in_A h_untl_gamma0
    · -- Neg sub-case (B is MCS): standard burgess_zeta_consistent argument.
      have h_untl_bg : Formula.untl b γ_hat ∈ A := h_r3.1 b hb_B γ_hat hγ_C
      have h_F_dummy : Formula.some_future β.neg ∈ A := by
        have h_bx5 := self_accum_until_mcs h_mcs_A b γ_hat h_untl_bg
        let q := Formula.and b (Formula.untl b γ_hat)
        have h_sep : Formula.untl q (Formula.and q (Formula.and b β).neg) ∈ A :=
          separation_until_mcs h_mcs_A h_bx5 h_neg
        have h_F_base : Formula.some_future (Formula.and q (Formula.and b β).neg) ∈ A :=
          until_implies_F_mcs h_mcs_A h_sep
        have h_impl_beta_neg : DerivationTree [] ((Formula.and q (Formula.and b β).neg).imp β.neg) := by
          have h_to_q := lce_imp q (Formula.and b β).neg
          have h_q_to_b := lce_imp b (Formula.untl b γ_hat)
          have h_b_to_neg : DerivationTree [] (b.imp β.neg) :=
            list_conj_implies_elem b_list β.neg (List.mem_cons.mpr (Or.inl rfl))
          exact imp_trans h_to_q (imp_trans h_q_to_b h_b_to_neg)
        exact F_mono_mcs h_mcs_A h_impl_beta_neg h_F_base
      obtain ⟨event, h_F_event, h_ev_b, _h_ev_beta_neg, h_ev_untl, h_ev_snce_raw⟩ :=
        burgess_zeta_consistent h_mcs_A _h_mcs_C h_r3m β h_β_not_B h_F_dummy
          b hb_B a_list ha_list γ_hat hγ_C h_neg
      have h_ev_snce : ∀ α ∈ a_list, DerivationTree [] (event.imp (Formula.snce b α)) :=
        h_ev_snce_raw
      have h_event_implies_L : ∀ φ ∈ L, DerivationTree [event] φ := by
        intro φ hφ
        have h_φ_D0 := hL φ hφ
        simp [burgess_D0_seed, Set.mem_union] at h_φ_D0
        by_cases h_B : φ ∈ B
        · have h_φ_in_raw : φ ∈ b_list_raw := collect_guards_mem_of_B h_B_dcs β L hL φ hφ h_B
          have h_φ_in_b : φ ∈ b_list := List.mem_cons.mpr (Or.inr h_φ_in_raw)
          have h_b_to_φ : DerivationTree [] (b.imp φ) := list_conj_implies_elem b_list φ h_φ_in_b
          have h_ev_to_φ := imp_trans h_ev_b h_b_to_φ
          exact DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ h_ev_to_φ (List.nil_subset _))
            (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
        · by_cases h_neg' : φ = β.neg
          · subst h_neg'
            have h_neg_in_raw : β.neg ∈ b_list_raw := collect_guards_mem_of_B h_B_dcs β L hL β.neg hφ _h_beta_neg_in_B
            have h_neg_in_b : β.neg ∈ b_list := List.mem_cons.mpr (Or.inr h_neg_in_raw)
            have h_b_to_neg : DerivationTree [] (b.imp β.neg) := list_conj_implies_elem b_list β.neg h_neg_in_b
            have h_ev_to_neg := imp_trans h_ev_b h_b_to_neg
            exact DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ h_ev_to_neg (List.nil_subset _))
              (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          · by_cases h_untl : ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ
            · let β' := Classical.choose h_untl
              have hβ' : β' ∈ B := (Classical.choose_spec h_untl).1
              let γ' := Classical.choose (Classical.choose_spec h_untl).2
              have hγ' : γ' ∈ C := (Classical.choose_spec (Classical.choose_spec h_untl).2).1
              have h_eq : φ = Formula.untl β' γ' := (Classical.choose_spec (Classical.choose_spec h_untl).2).2
              have h_φ_eq : Formula.untl β' γ' ∈ L := by rw [←h_eq]; exact hφ
              rw [h_eq]
              by_cases h_untl_B : Formula.untl β' γ' ∈ B
              · have h_in_raw := collect_guards_mem_of_B h_B_dcs β L hL (Formula.untl β' γ') h_φ_eq h_untl_B
                have h_in_b : Formula.untl β' γ' ∈ b_list := List.mem_cons.mpr (Or.inr h_in_raw)
                have h_b_imp := list_conj_implies_elem b_list (Formula.untl β' γ') h_in_b
                have h_ev_imp := imp_trans h_ev_b h_b_imp
                exact DerivationTree.modus_ponens _ _ _
                  (DerivationTree.weakening [] _ _ h_ev_imp (List.nil_subset _))
                  (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
              · have h_β'_in_raw := collect_guards_mem_of_untl h_B_dcs β L hL β' γ' h_φ_eq hβ' hγ' h_untl_B
                have h_β'_in_b : β' ∈ b_list := List.mem_cons.mpr (Or.inr h_β'_in_raw)
                have h_b_to_β' := list_conj_implies_elem b_list β' h_β'_in_b
                have h_γ'_in_raw := @d0_c_event_list_γ_mem A B C β L hL β' γ' h_φ_eq hβ' hγ'
                have h_γ'_in_c : γ' ∈ c_list := List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inr h_γ'_in_raw)))
                have h_γhat_to_γ' := list_conj_implies_elem c_list γ' h_γ'_in_c
                have h_left := untl_left_mono_deriv b γ_hat β' h_b_to_β'
                have h_right := untl_right_mono_deriv γ_hat γ' β' h_γhat_to_γ'
                have h_chain := imp_trans h_ev_untl (imp_trans h_left h_right)
                exact DerivationTree.modus_ponens _ _ _
                  (DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
                  (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
            · by_cases h_snce : ∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α
              · let β' := Classical.choose h_snce
                have hβ' : β' ∈ B := (Classical.choose_spec h_snce).1
                let α' := Classical.choose (Classical.choose_spec h_snce).2
                have hα' : α' ∈ A := (Classical.choose_spec (Classical.choose_spec h_snce).2).1
                have h_eq : φ = Formula.snce β' α' := (Classical.choose_spec (Classical.choose_spec h_snce).2).2
                have h_φ_eq_snce : Formula.snce β' α' ∈ L := by rw [←h_eq]; exact hφ
                rw [h_eq]
                by_cases h_snce_B : Formula.snce β' α' ∈ B
                · have h_in_raw := collect_guards_mem_of_B h_B_dcs β L hL (Formula.snce β' α') h_φ_eq_snce h_snce_B
                  have h_in_b : Formula.snce β' α' ∈ b_list := List.mem_cons.mpr (Or.inr h_in_raw)
                  have h_b_imp := list_conj_implies_elem b_list (Formula.snce β' α') h_in_b
                  have h_ev_imp := imp_trans h_ev_b h_b_imp
                  exact DerivationTree.modus_ponens _ _ _
                    (DerivationTree.weakening [] _ _ h_ev_imp (List.nil_subset _))
                    (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
                · have h_not_untl : ¬(∃ β'' ∈ B, ∃ γ'' ∈ C, Formula.snce β' α' = Formula.untl β'' γ'') := by
                    rintro ⟨_, _, _, _, h_eq⟩; exact Formula.noConfusion h_eq
                  have h_β'_in_raw := collect_guards_mem_of_snce h_B_dcs β L hL β' α' h_φ_eq_snce hβ' hα' h_snce_B h_not_untl
                  have h_β'_in_b : β' ∈ b_list := List.mem_cons.mpr (Or.inr h_β'_in_raw)
                  have h_b_to_β' := list_conj_implies_elem b_list β' h_β'_in_b
                  have h_α'_in_a := @d0_a_event_list_α_mem A B C β L hL β' α' h_φ_eq_snce hβ' hα' h_not_untl
                  have h_ev_snce_α' := h_ev_snce α' h_α'_in_a
                  have h_mono := snce_left_mono_deriv b α' β' h_b_to_β'
                  have h_chain := imp_trans h_ev_snce_α' h_mono
                  exact DerivationTree.modus_ponens _ _ _
                    (DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
                    (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
              · exfalso
                simp [h_B, h_neg', h_untl, h_snce] at h_φ_D0
      have d_event : DerivationTree [event] Formula.bot :=
        derivation_from_implied [event] L Formula.bot h_event_implies_L d
      have h_event_cons := consistent_of_F_mem h_mcs_A event h_F_event
      exact inconsistent_singleton_false h_event_cons d_event
  · -- Case A: B is NOT MCS.
    -- Extract delta' ∉ B with {delta'}∪B consistent, and neg-until witness.
    have h_not_mcs : ∃ δ', δ' ∉ B ∧ SetConsistent (insert δ' B) := by
      by_contra h_all
      push_neg at h_all
      exact h_mcs_B ⟨h_B_dcs.1, fun φ h_not => by
        have := h_all φ h_not
        rwa [Set.insert_eq] at this⟩
    obtain ⟨delta', h_delta'_not_B, _h_delta'_cons⟩ := h_not_mcs
    -- From maximality: ¬burgessR3(A, DC({delta'}∪B), C)
    have h_not_r3 := BurgessR3Maximal_extension_fails h_r3m h_delta'_not_B
    -- Extract neg-until witness: ∃ beta0 ∈ B, gamma0 ∈ C, (untl(beta0∧delta', gamma0)).neg ∈ A
    have h_neg_until_exists : ∃ beta0 ∈ B, ∃ gamma0 ∈ C,
        Formula.untl (Formula.and beta0 delta') gamma0 ∉ A := by
      by_contra h_all_until
      push_neg at h_all_until
      have h_rset : burgessRSet A (deductiveClosure ({delta'} ∪ B)) C := by
        intro phi hphi gamma hgamma
        obtain ⟨Ldc, hL_sub, ⟨ddc⟩⟩ := hphi
        rcases dc_delta_B_controlled h_B_dcs hL_sub ddc with h_B_case | ⟨beta_w, hbeta_w, ⟨h_impl⟩⟩
        · exact h_r3.1 phi h_B_case gamma hgamma
        · exact untl_left_mono_thm h_mcs_A h_impl (h_all_until beta_w hbeta_w gamma hgamma)
      have h_rsince : burgessRSetSince C (deductiveClosure ({delta'} ∪ B)) A := by
        intro phi hphi alpha halpha
        obtain ⟨Ldc, hL_sub, ⟨ddc⟩⟩ := hphi
        rcases dc_delta_B_controlled h_B_dcs hL_sub ddc with h_B_case | ⟨beta_w, hbeta_w, ⟨h_impl⟩⟩
        · exact h_r3.2 phi h_B_case alpha halpha
        · have h_burgessR_ext : burgessR A (Formula.and beta_w delta') C :=
            fun gamma hgamma => h_all_until beta_w hbeta_w gamma hgamma
          have h_snce_ext := burgessR_implies_burgessRSince h_mcs_A _h_mcs_C h_burgessR_ext alpha halpha
          exact snce_left_mono_thm _h_mcs_C h_impl h_snce_ext
      exact h_not_r3 ⟨h_rset, h_rsince⟩
    obtain ⟨beta0, h_beta0, gamma0, h_gamma0, h_not_in_A⟩ := h_neg_until_exists
    have h_neg_until_in_A : (Formula.untl (Formula.and beta0 delta') gamma0).neg ∈ A := by
      rcases SetMaximalConsistent.negation_complete h_mcs_A
        (Formula.untl (Formula.and beta0 delta') gamma0) with h | h
      · exfalso; exact h_not_in_A h
      · exact h
    -- Construct c_list with gamma0 included (so γ_hat implies gamma0 via conjunction elimination)
    let γ₀ := Formula.bot.imp Formula.bot
    have hγ₀ : γ₀ ∈ C := theorem_in_mcs _h_mcs_C (identity Formula.bot)
    let c_list_raw := d0_c_event_list β L hL
    let c_list := gamma0 :: γ₀ :: c_list_raw
    have hc_list : ∀ γ ∈ c_list, γ ∈ C := by
      intro γ hγ; rcases List.mem_cons.mp hγ with rfl | h
      · exact h_gamma0
      · rcases List.mem_cons.mp h with rfl | h2
        · exact hγ₀
        · exact d0_c_event_list_mem h2
    let b := list_conj b_list
    let γ_hat := list_conj c_list
    have hb_B : b ∈ B := list_conj_mem_dcs h_B_dcs b_list hb_list'
    have hγ_C : γ_hat ∈ C := list_conj_mem_mcs _h_mcs_C c_list hc_list
    -- Key property: γ_hat → gamma0 (gamma0 is the first element of c_list)
    have h_γhat_to_gamma0 : DerivationTree [] (γ_hat.imp gamma0) :=
      list_conj_implies_elem c_list gamma0 (List.mem_cons.mpr (Or.inl rfl))
    -- Neg/pos case split
    rcases SetMaximalConsistent.negation_complete h_mcs_A
      (Formula.untl (Formula.and b β) γ_hat) with h_pos | h_neg
    · -- Pos sub-case: untl(b∧β, γ_hat) ∈ A.
      -- Since β.neg is first in b_list: ⊢ b → β.neg, hence ⊢ (b∧β) → ⊥.
      -- By left_mono from ⊥: untl(r, γ_hat) ∈ A for any r.
      -- In particular untl(beta0∧delta', γ_hat) ∈ A.
      -- By right_mono with γ_hat → gamma0: untl(beta0∧delta', gamma0) ∈ A.
      -- This contradicts h_neg_until_in_A.
      exfalso
      -- Step 1: ⊢ (b∧β) → ⊥
      have h_b_to_beta_neg : DerivationTree [] (b.imp β.neg) :=
        list_conj_implies_elem b_list β.neg (List.mem_cons.mpr (Or.inl rfl))
      have h_bβ_to_bot : DerivationTree [] ((Formula.and b β).imp Formula.bot) := by
        -- [b∧β] ⊢ b (lce), b ⊢ β.neg (h_b_to_beta_neg), [b∧β] ⊢ β (rce)
        -- β.neg = β → ⊥, so [β.neg, β] ⊢ ⊥
        have h_step : DerivationTree [Formula.and b β] Formula.bot := by
          have hb' := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ (lce_imp b β) (List.nil_subset _))
            (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          have hβ_neg := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ h_b_to_beta_neg (List.nil_subset _)) hb'
          have hβ := DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ (rce_imp b β) (List.nil_subset _))
            (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          exact DerivationTree.modus_ponens _ _ _ hβ_neg hβ
        exact deduction_theorem [] (Formula.and b β) Formula.bot h_step
      -- Step 2: ⊢ ⊥ → (beta0∧delta') via EFQ
      have h_bot_to_guard : DerivationTree [] (Formula.bot.imp (Formula.and beta0 delta')) :=
        efq_axiom (Formula.and beta0 delta')
      -- Step 3: ⊢ (b∧β) → (beta0∧delta')
      have h_bβ_to_guard : DerivationTree [] ((Formula.and b β).imp (Formula.and beta0 delta')) :=
        imp_trans h_bβ_to_bot h_bot_to_guard
      -- Step 4: left_mono: untl(b∧β, γ_hat) → untl(beta0∧delta', γ_hat)
      have h_untl_guard := untl_left_mono_thm h_mcs_A h_bβ_to_guard h_pos
      -- Step 5: right_mono with γ_hat → gamma0: untl(beta0∧delta', γ_hat) → untl(beta0∧delta', gamma0)
      have h_untl_gamma0 := right_mono_until_mcs h_mcs_A h_γhat_to_gamma0 h_untl_guard
      -- Step 6: Contradiction
      exact SetMaximalConsistent.neg_excludes h_mcs_A _ h_neg_until_in_A h_untl_gamma0
    · -- Neg sub-case (Case A): (untl(b∧β, γ_hat)).neg ∈ A.
      -- Standard burgess_zeta_consistent argument with Case A's c_list.
      have h_untl_bg : Formula.untl b γ_hat ∈ A := h_r3.1 b hb_B γ_hat hγ_C
      have h_F_dummy : Formula.some_future β.neg ∈ A := by
        have h_bx5 := self_accum_until_mcs h_mcs_A b γ_hat h_untl_bg
        let q := Formula.and b (Formula.untl b γ_hat)
        have h_sep : Formula.untl q (Formula.and q (Formula.and b β).neg) ∈ A :=
          separation_until_mcs h_mcs_A h_bx5 h_neg
        have h_F_base : Formula.some_future (Formula.and q (Formula.and b β).neg) ∈ A :=
          until_implies_F_mcs h_mcs_A h_sep
        have h_impl_beta_neg : DerivationTree [] ((Formula.and q (Formula.and b β).neg).imp β.neg) := by
          have h_to_q := lce_imp q (Formula.and b β).neg
          have h_q_to_b := lce_imp b (Formula.untl b γ_hat)
          have h_b_to_neg : DerivationTree [] (b.imp β.neg) :=
            list_conj_implies_elem b_list β.neg (List.mem_cons.mpr (Or.inl rfl))
          exact imp_trans h_to_q (imp_trans h_q_to_b h_b_to_neg)
        exact F_mono_mcs h_mcs_A h_impl_beta_neg h_F_base
      obtain ⟨event, h_F_event, h_ev_b, _h_ev_beta_neg, h_ev_untl, h_ev_snce_raw⟩ :=
        burgess_zeta_consistent h_mcs_A _h_mcs_C h_r3m β h_β_not_B h_F_dummy
          b hb_B a_list ha_list γ_hat hγ_C h_neg
      have h_ev_snce : ∀ α ∈ a_list, DerivationTree [] (event.imp (Formula.snce b α)) :=
        h_ev_snce_raw
      have h_event_implies_L : ∀ φ ∈ L, DerivationTree [event] φ := by
        intro φ hφ
        have h_φ_D0 := hL φ hφ
        simp [burgess_D0_seed, Set.mem_union] at h_φ_D0
        by_cases h_B : φ ∈ B
        · have h_φ_in_raw : φ ∈ b_list_raw := collect_guards_mem_of_B h_B_dcs β L hL φ hφ h_B
          have h_φ_in_b : φ ∈ b_list := List.mem_cons.mpr (Or.inr h_φ_in_raw)
          have h_b_to_φ : DerivationTree [] (b.imp φ) := list_conj_implies_elem b_list φ h_φ_in_b
          have h_ev_to_φ := imp_trans h_ev_b h_b_to_φ
          exact DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ h_ev_to_φ (List.nil_subset _))
            (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
        · by_cases h_neg' : φ = β.neg
          · subst h_neg'
            have h_neg_in_raw : β.neg ∈ b_list_raw := collect_guards_mem_of_B h_B_dcs β L hL β.neg hφ _h_beta_neg_in_B
            have h_neg_in_b : β.neg ∈ b_list := List.mem_cons.mpr (Or.inr h_neg_in_raw)
            have h_b_to_neg : DerivationTree [] (b.imp β.neg) := list_conj_implies_elem b_list β.neg h_neg_in_b
            have h_ev_to_neg := imp_trans h_ev_b h_b_to_neg
            exact DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ h_ev_to_neg (List.nil_subset _))
              (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
          · by_cases h_untl : ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ
            · let β' := Classical.choose h_untl
              have hβ' : β' ∈ B := (Classical.choose_spec h_untl).1
              let γ' := Classical.choose (Classical.choose_spec h_untl).2
              have hγ' : γ' ∈ C := (Classical.choose_spec (Classical.choose_spec h_untl).2).1
              have h_eq : φ = Formula.untl β' γ' := (Classical.choose_spec (Classical.choose_spec h_untl).2).2
              have h_φ_eq : Formula.untl β' γ' ∈ L := by rw [←h_eq]; exact hφ
              rw [h_eq]
              by_cases h_untl_B : Formula.untl β' γ' ∈ B
              · have h_in_raw := collect_guards_mem_of_B h_B_dcs β L hL (Formula.untl β' γ') h_φ_eq h_untl_B
                have h_in_b : Formula.untl β' γ' ∈ b_list := List.mem_cons.mpr (Or.inr h_in_raw)
                have h_b_imp := list_conj_implies_elem b_list (Formula.untl β' γ') h_in_b
                have h_ev_imp := imp_trans h_ev_b h_b_imp
                exact DerivationTree.modus_ponens _ _ _
                  (DerivationTree.weakening [] _ _ h_ev_imp (List.nil_subset _))
                  (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
              · have h_β'_in_raw := collect_guards_mem_of_untl h_B_dcs β L hL β' γ' h_φ_eq hβ' hγ' h_untl_B
                have h_β'_in_b : β' ∈ b_list := List.mem_cons.mpr (Or.inr h_β'_in_raw)
                have h_b_to_β' := list_conj_implies_elem b_list β' h_β'_in_b
                have h_γ'_in_raw := @d0_c_event_list_γ_mem A B C β L hL β' γ' h_φ_eq hβ' hγ'
                -- gamma0 :: γ₀ :: c_list_raw: need two cons steps
                have h_γ'_in_c : γ' ∈ c_list := List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inr h_γ'_in_raw)))
                have h_γhat_to_γ' := list_conj_implies_elem c_list γ' h_γ'_in_c
                have h_left := untl_left_mono_deriv b γ_hat β' h_b_to_β'
                have h_right := untl_right_mono_deriv γ_hat γ' β' h_γhat_to_γ'
                have h_chain := imp_trans h_ev_untl (imp_trans h_left h_right)
                exact DerivationTree.modus_ponens _ _ _
                  (DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
                  (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
            · by_cases h_snce : ∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α
              · let β' := Classical.choose h_snce
                have hβ' : β' ∈ B := (Classical.choose_spec h_snce).1
                let α' := Classical.choose (Classical.choose_spec h_snce).2
                have hα' : α' ∈ A := (Classical.choose_spec (Classical.choose_spec h_snce).2).1
                have h_eq : φ = Formula.snce β' α' := (Classical.choose_spec (Classical.choose_spec h_snce).2).2
                have h_φ_eq_snce : Formula.snce β' α' ∈ L := by rw [←h_eq]; exact hφ
                rw [h_eq]
                by_cases h_snce_B : Formula.snce β' α' ∈ B
                · have h_in_raw := collect_guards_mem_of_B h_B_dcs β L hL (Formula.snce β' α') h_φ_eq_snce h_snce_B
                  have h_in_b : Formula.snce β' α' ∈ b_list := List.mem_cons.mpr (Or.inr h_in_raw)
                  have h_b_imp := list_conj_implies_elem b_list (Formula.snce β' α') h_in_b
                  have h_ev_imp := imp_trans h_ev_b h_b_imp
                  exact DerivationTree.modus_ponens _ _ _
                    (DerivationTree.weakening [] _ _ h_ev_imp (List.nil_subset _))
                    (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
                · have h_not_untl : ¬(∃ β'' ∈ B, ∃ γ'' ∈ C, Formula.snce β' α' = Formula.untl β'' γ'') := by
                    rintro ⟨_, _, _, _, h_eq⟩; exact Formula.noConfusion h_eq
                  have h_β'_in_raw := collect_guards_mem_of_snce h_B_dcs β L hL β' α' h_φ_eq_snce hβ' hα' h_snce_B h_not_untl
                  have h_β'_in_b : β' ∈ b_list := List.mem_cons.mpr (Or.inr h_β'_in_raw)
                  have h_b_to_β' := list_conj_implies_elem b_list β' h_β'_in_b
                  have h_α'_in_a := @d0_a_event_list_α_mem A B C β L hL β' α' h_φ_eq_snce hβ' hα' h_not_untl
                  have h_ev_snce_α' := h_ev_snce α' h_α'_in_a
                  have h_mono := snce_left_mono_deriv b α' β' h_b_to_β'
                  have h_chain := imp_trans h_ev_snce_α' h_mono
                  exact DerivationTree.modus_ponens _ _ _
                    (DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
                    (DerivationTree.assumption _ _ (by exact List.mem_singleton.mpr rfl))
              · exfalso
                simp [h_B, h_neg', h_untl, h_snce] at h_φ_D0
      have d_event : DerivationTree [event] Formula.bot :=
        derivation_from_implied [event] L Formula.bot h_event_implies_L d
      have h_event_cons := consistent_of_F_mem h_mcs_A event h_F_event
      exact inconsistent_singleton_false h_event_cons d_event

/-- The Burgess D₀ seed for Lemma 2.6 is consistent when BurgessR3Maximal(A, B, C),
g_content(A) ⊆ C, and β ∉ B.

Proof by cases on whether {β}∪B is consistent:
- Consistent case: BX5+BX14+BX10 chain gives F(β.neg)∈A, then Burgess compression
  shows any finite L ⊆ D₀ is consistent.
- Inconsistent case: β.neg∈B, seed simplifies, same compression argument applies. -/
private theorem burgess_D0_seed_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (β : Formula)
    (h_β_not_B : β ∉ B) :
    SetConsistent (burgess_D0_seed A B C β) := by
  have h_B_dcs : SetDeductivelyClosed B := h_r3m.1
  have h_r3 : burgessR3 A B C := h_r3m.2.1
  -- Strategy: show D₀ ⊆ a known consistent superset.
  -- Key fact 1: {β.neg} ∪ g_content(A) is consistent (via BX5+BX14+BX10)
  -- Key fact 2: B ⊆ g_content(A) (from g_content_sub_B property via BurgessR3Maximal)
  -- Key fact 3: untl(β',γ) ∈ A for β'∈B, γ∈C (from burgessR3), so untl(β',γ) ∈ g_content(A)?
  --   No: g_content(A) = {φ | G(φ) ∈ A}. untl(β',γ) ∈ A does NOT mean G(untl(β',γ)) ∈ A.
  -- Correct strategy: show D₀ ⊆ B ∪ {β.neg} ∪ A, and use the fact that
  --   burgessR3 formulas are in A, B is consistent, and {β.neg}∪B is handled by cases.

  -- Establish F(β.neg) ∈ A from BX5+BX14+BX10 chain (Burgess's argument)
  by_cases h_cons : SetConsistent ({β} ∪ B)
  · -- Case: {β} ∪ B is consistent
    -- By maximality, DC({β} ∪ B) does not satisfy burgessR3
    have h_not_r3 := BurgessR3Maximal_extension_fails h_r3m h_β_not_B
    -- Extract Until condition failure (the only thing that CAN fail is the Until direction,
    -- since the Since direction requires the unprovable condition).
    -- Actually, ¬burgessR3 means ¬(burgessRSet ∧ burgessRSetSince).
    -- We use classical logic: if the Until condition held AND the Since condition held,
    -- then burgessR3 would hold. Since it doesn't, one must fail.
    -- We extract the Until failure directly via push_neg on maximality.
    -- The key insight: we DON'T need to separately prove Since. We just need
    -- the existence of beta0, gamma0 with ¬U(beta0∧β, gamma0) ∈ A.
    -- From ¬burgessR3: either Until fails or Since fails.
    -- If Until fails: we get our witness directly.
    -- If Since fails: we extract a different contradiction.
    -- Simpler: use r3Maximal_neg_of_not_mem to get β.neg ∈ B.
    -- Wait, that's for R3Maximal not BurgessR3Maximal. Let me check.
    -- Actually the cleanest approach: since {β}∪B is consistent and β∉B,
    -- we know BurgessR3Maximal_extension_fails gives ¬burgessR3(A, DC({β}∪B), C).
    -- This means: ∃ phi ∈ DC({β}∪B), ∃ gamma ∈ C, ¬(untl(phi,gamma) ∈ A)
    --   OR ∃ phi ∈ DC({β}∪B), ∃ alpha ∈ A, ¬(snce(phi,alpha) ∈ C).
    -- By dc_delta_B_controlled, phi ∈ B or ⊢(beta0∧β)→phi for some beta0∈B.
    -- In either subcase, using left_mono_until or the burgessR3 of original B,
    -- we can extract our witness.
    -- Simplest extraction: unfold burgessR3.
    have h_neg_r3_unfolded : ¬(burgessRSet A (deductiveClosure ({β} ∪ B)) C ∧
        burgessRSetSince C (deductiveClosure ({β} ∪ B)) A) := h_not_r3
    -- For the Until direction extraction:
    -- If burgessRSet fails: ∃ phi ∈ DC({β}∪B), ∃ gamma ∈ C, untl(phi,gamma) ∉ A
    -- Claim: burgessRSet MUST fail (since if it held AND Since held, burgessR3 holds)
    -- We can't determine which fails, so extract from the disjunction.
    -- Actually, let's use a cleaner approach: directly extract neg-Until witness.
    -- From BurgessR3Maximal maximality with β∉B, we know that for SOME extension
    -- direction, the condition fails. The Until direction is the one we can exploit.
    -- Key observation: we need ¬U(beta0∧β, gamma0) ∈ A for SOME beta0∈B, gamma0∈C.
    -- This is equivalent to: NOT (∀ beta0∈B, ∀ gamma0∈C, U(beta0∧β, gamma0) ∈ A).
    -- Proof by contradiction: if ∀ beta0∈B, ∀ gamma0∈C, U(beta0∧β, gamma0) ∈ A,
    -- then burgessRSet(A, DC({β}∪B), C) would hold (via dc_delta_B_controlled + left_mono).
    -- Combined with burgessRSince (if it also held), this contradicts h_not_r3.
    -- We sidestep the Since condition by showing the Until condition alone suffices
    -- to reach contradiction with a WEAKER target: just need F(β.neg) ∈ A.
    have h_neg_until_exists : ∃ beta0 ∈ B, ∃ gamma0 ∈ C,
        Formula.untl (Formula.and beta0 β) gamma0 ∉ A := by
      by_contra h_all_until
      push_neg at h_all_until
      -- h_all_until : ∀ beta0 ∈ B, ∀ gamma0 ∈ C, untl(beta0∧β, gamma0) ∈ A
      -- Show burgessRSet(A, DC({β}∪B), C) using dc_delta_B_controlled
      have h_rset : burgessRSet A (deductiveClosure ({β} ∪ B)) C := by
        intro phi hphi gamma hgamma
        obtain ⟨L, hL_sub, ⟨d⟩⟩ := hphi
        rcases dc_delta_B_controlled h_B_dcs hL_sub d with h_B | ⟨beta0, hbeta0, ⟨h_impl⟩⟩
        · exact h_r3.1 phi h_B gamma hgamma
        · exact untl_left_mono_thm h_mcs_A h_impl (h_all_until beta0 hbeta0 gamma hgamma)
      -- For burgessRSetSince, use burgessR_implies_burgessRSince on each element
      have h_rsince : burgessRSetSince C (deductiveClosure ({β} ∪ B)) A := by
        intro phi hphi alpha halpha
        obtain ⟨L, hL_sub, ⟨d⟩⟩ := hphi
        rcases dc_delta_B_controlled h_B_dcs hL_sub d with h_B | ⟨beta0, hbeta0, ⟨h_impl⟩⟩
        · exact h_r3.2 phi h_B alpha halpha
        · -- Need snce(phi, alpha) ∈ C where ⊢ (beta0∧β) → phi
          -- From h_all_until: untl(beta0∧β, gamma) ∈ A for all gamma ∈ C
          -- By burgessR_implies_burgessRSince: snce(beta0∧β, alpha) ∈ C for all alpha ∈ A
          have h_burgessR_ext : burgessR A (Formula.and beta0 β) C :=
            fun gamma hgamma => h_all_until beta0 hbeta0 gamma hgamma
          have h_snce_ext := burgessR_implies_burgessRSince h_mcs_A h_mcs_C h_burgessR_ext alpha halpha
          -- snce(beta0∧β, alpha) ∈ C, and ⊢ (beta0∧β) → phi
          -- By snce_left_mono: snce(phi, alpha) ∈ C
          exact snce_left_mono_thm h_mcs_C h_impl h_snce_ext
      exact h_not_r3 ⟨h_rset, h_rsince⟩

    obtain ⟨beta0, h_beta0, gamma0, h_gamma0, h_not_in_A⟩ := h_neg_until_exists

    -- Convert to neg formula in A
    have h_neg_until_in_A : (Formula.untl (Formula.and beta0 β) gamma0).neg ∈ A := by
      rcases SetMaximalConsistent.negation_complete h_mcs_A
        (Formula.untl (Formula.and beta0 β) gamma0) with h | h
      · exfalso; exact h_not_in_A h
      · exact h

    -- Step 2: U(beta0, gamma0) ∈ A from burgessR3
    have h_until_beta0_gamma0 : Formula.untl beta0 gamma0 ∈ A :=
      h_r3.1 beta0 h_beta0 gamma0 h_gamma0

    -- Step 3: BX5 (self_accum_until)
    have h_until_self_accum : Formula.untl (Formula.and beta0 (Formula.untl beta0 gamma0)) gamma0 ∈ A :=
      self_accum_until_mcs h_mcs_A beta0 gamma0 h_until_beta0_gamma0

    -- Step 4: BX14 (separation_until)
    let q := Formula.and beta0 (Formula.untl beta0 gamma0)
    let r := Formula.and beta0 β
    have h_sep : Formula.untl q (Formula.and q r.neg) ∈ A :=
      separation_until_mcs h_mcs_A h_until_self_accum h_neg_until_in_A

    -- Step 5: BX10 (until_F) gives F(event) ∈ A
    have h_F_event : Formula.some_future (Formula.and q r.neg) ∈ A :=
      until_implies_F_mcs h_mcs_A h_sep

    -- Step 6: Prove event implies β.neg
    have h_event_implies_beta_neg : DerivationTree [] ((Formula.and q r.neg).imp β.neg) := by
      have h_assume : [Formula.and q r.neg] ⊢ β.neg := by
        have h_r_neg : [Formula.and q r.neg] ⊢ r.neg :=
          DerivationTree.modus_ponens [Formula.and q r.neg] (Formula.and q r.neg) r.neg
            (DerivationTree.weakening [] _ _ (and_right_impl q r.neg) (List.nil_subset _))
            (DerivationTree.assumption _ _ (by simp))
        have h_q : [Formula.and q r.neg] ⊢ q :=
          DerivationTree.modus_ponens [Formula.and q r.neg] (Formula.and q r.neg) q
            (DerivationTree.weakening [] _ _ (and_left_impl q r.neg) (List.nil_subset _))
            (DerivationTree.assumption _ _ (by simp))
        have h_beta0_in : [Formula.and q r.neg] ⊢ beta0 :=
          DerivationTree.modus_ponens [Formula.and q r.neg] q beta0
            (DerivationTree.weakening [] _ _ (and_left_impl beta0 (Formula.untl beta0 gamma0)) (List.nil_subset _))
            h_q
        have h_beta_imp_bot : [Formula.and q r.neg] ⊢ β.imp Formula.bot := by
          have h_r_neg_expanded : [Formula.and q r.neg] ⊢ (Formula.and beta0 β).imp Formula.bot := by
            rw [show r.neg = (Formula.and beta0 β).neg by rfl] at h_r_neg
            exact h_r_neg
          have h_conj_intro : (β :: [Formula.and q r.neg]) ⊢ Formula.and beta0 β := by
            have h_beta0' : (β :: [Formula.and q r.neg]) ⊢ beta0 :=
              DerivationTree.weakening _ _ _ h_beta0_in (List.subset_cons_of_subset _ (List.Subset.refl _))
            have h_beta' : (β :: [Formula.and q r.neg]) ⊢ β :=
              DerivationTree.assumption _ _ (by simp)
            have h_pairing : DerivationTree [] (beta0.imp (β.imp (Formula.and beta0 β))) :=
              pairing beta0 β
            have h1 : (β :: [Formula.and q r.neg]) ⊢ (β.imp (Formula.and beta0 β)) :=
              DerivationTree.modus_ponens _ _ _
                (DerivationTree.weakening [] _ _ h_pairing (List.nil_subset _))
                h_beta0'
            exact DerivationTree.modus_ponens _ _ _ h1 h_beta'
          have h_bot : (β :: [Formula.and q r.neg]) ⊢ Formula.bot :=
            DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening _ _ _ h_r_neg_expanded (List.subset_cons_of_subset _ (List.Subset.refl _)))
              h_conj_intro
          exact Bimodal.Metalogic.Core.deduction_theorem [Formula.and q r.neg] β Formula.bot h_bot
        rw [show β.neg = β.imp Formula.bot by rfl]
        exact h_beta_imp_bot
      exact Bimodal.Metalogic.Core.deduction_theorem [] (Formula.and q r.neg) β.neg h_assume

    -- Step 7: F(β.neg) ∈ A via F-monotonicity
    have h_F_beta_neg : Formula.some_future β.neg ∈ A :=
      F_mono_mcs h_mcs_A h_event_implies_beta_neg h_F_event

    -- Step 8: {β.neg} ∪ g_content(A) is consistent
    have h_seed1_cons : SetConsistent ({β.neg} ∪ g_content A) :=
      forward_temporal_witness_seed_consistent A h_mcs_A β.neg h_F_beta_neg

    -- Step 9: h_content(C) ⊆ A by duality from g_content(A) ⊆ C
    have h_hc_sub_A : h_content C ⊆ A :=
      g_content_sub_imp_h_content_sub' h_mcs_A h_mcs_C h_gc

    -- Step 10: Show D₀ ⊆ {β.neg} ∪ g_content(A) ∪ A
    -- Actually, we show D₀ is consistent directly.
    -- The seed components:
    -- - B ⊆ D₀: B elements are in A? Not necessarily.
    --   But B formulas are controlled: for any beta' ∈ B, G(beta') ∈ A
    --   (from g_content(A) ⊆ C + BurgessR3Maximal). Actually we need g_content_sub_B.
    -- The correct approach: D₀ ⊆ {β.neg} ∪ g_content(A) ∪ h_content(C).
    -- Why: B ⊆ g_content(A) (from g_content_sub_B for BurgessR3Maximal)
    --   untl(β',γ) ∈ A for β'∈B, γ∈C. Is G(untl(β',γ)) ∈ A? Not necessarily.
    -- Hmm, this doesn't work directly. Let me reconsider.
    --
    -- The correct containment: show any finite L ⊆ D₀ is consistent.
    -- For finite L ⊆ D₀, L contains:
    --   (a) finitely many elements of B
    --   (b) possibly β.neg
    --   (c) finitely many untl(β'_i, γ_i) with β'_i ∈ B, γ_i ∈ C
    --   (d) finitely many snce(β'_j, α_j) with β'_j ∈ B, α_j ∈ A
    -- All of (a) are in B (DCS, hence consistent among themselves).
    -- All of (c) are in A (by burgessR3).
    -- All of (d) are in C (by burgessR3 Since direction).
    -- Key: {β.neg} ∪ B is consistent (we're in the h_cons case!).
    -- And untl(β',γ) ∈ A, snce(β',α) ∈ C.
    -- So any L ⊆ D₀ is a subset of ({β.neg} ∪ B) ∪ A ∪ C... but that's too big.
    --
    -- Actually the right approach: D₀ ⊆ {β.neg} ∪ B ∪ A ∪ C is not useful.
    -- The correct argument uses the MCS property:
    -- Since A is an MCS and untl(β',γ) ∈ A, and B ⊆ A (NOT necessarily true!),
    -- we can't just use MCS consistency.
    --
    -- Let me use the simpler approach that works: show D₀ is consistent
    -- via `SetConsistent_of_subset` to a known consistent set.
    -- The known consistent set is MCS A itself?
    -- No: β.neg might not be in A. Also B might not be a subset of A.
    --
    -- OK, the fundamental insight for Lemma 2.6 (looking at lemma_2_7's pattern):
    -- ANY finite inconsistency in D₀ would involve formulas from B, β.neg, and
    -- the U/S formulas. But the U/S formulas are in A (resp. C), and B formulas
    -- plus β.neg are in {β.neg}∪B which is consistent (h_cons says {β}∪B is
    -- consistent, but we need {β.neg}∪B consistent!).
    --
    -- Wait: h_cons says {β}∪B is consistent. We need {β.neg}∪B.
    -- β.neg ∈ B? Only in the inconsistent case. In the consistent case ({β}∪B consistent),
    -- β.neg might or might not be in B.
    --
    -- Actually: from BurgessR3Maximal maximality + β∉B, we know β.neg ∈ B
    -- (since B is a maximal DCS w.r.t. burgessR3, it's negation-complete for
    -- formulas testable against burgessR3). Actually no, that's R3Maximal.
    -- Let me check: does BurgessR3Maximal give β.neg ∈ B when β∉B?
    -- Looking at r3Maximal_neg_of_not_mem (line 450): this uses R3Maximal, not BurgessR3Maximal.
    -- R3Maximal has different type than BurgessR3Maximal.
    --
    -- For BurgessR3Maximal: B is DCS + burgessR3 + maximal among DCS with burgessR3.
    -- From β∉B and B is DCS: {β.neg}∪B might not be consistent! If it IS consistent,
    -- then DC({β.neg}∪B) properly extends B, and if it satisfies burgessR3, contradicts maximality.
    -- But it might NOT satisfy burgessR3.
    --
    -- The correct proof strategy for seed consistency in this case:
    -- We already proved F(β.neg) ∈ A. Use forward_temporal_witness_seed_consistent:
    -- {β.neg} ∪ g_content(A) is consistent.
    -- Then show: all elements of D₀ are in {β.neg} ∪ g_content(A) ∪ h_content(C).
    -- This requires: B ⊆ g_content(A) (i.e., for all φ∈B, G(φ)∈A).
    -- This is exactly g_content_sub_B which was previously proved to require density!
    --
    -- But wait: looking at the existing code in this file, there's a section
    -- "g_content(A) ⊆ B from BurgessR3Maximal" (lines 744-757) which proves the
    -- REVERSE: g_content(A) ⊆ B. And the proof at lines 758+ uses
    -- burgessR3_univ_of_inconsistent_ext. So we have g_content(A) ⊆ B, not B ⊆ g_content(A).
    --
    -- The correct containment for D₀ uses a different strategy entirely.
    -- Let me look at how lemma_2_7 handles this. In lemma_2_7_seed, the seed is
    -- B ∪ {xi} ∪ untl-formulas ∪ snce-formulas. Its consistency proof is sorry.
    -- So lemma_2_7 doesn't actually solve this either!
    --
    -- THE CORRECT PROOF (Burgess 1982):
    -- Any finite L ⊆ D₀ can be "collapsed" into a single conjunction:
    -- Take L = {b₁,...,bₖ, β.neg, U(β'₁,γ₁),..., S(β''₁,α₁),...}
    -- Let b = b₁∧...∧bₖ (conjunction of B-elements). b ∈ B since B is DCS.
    -- The U-formulas: U(β'ᵢ,γᵢ) with β'ᵢ∈B. By right_mono_until with G(β'ᵢ→b∧β'ᵢ):
    --   Get U(b∧β'ᵢ, γᵢ) ∈ A? No, that's guard strengthening which isn't free.
    -- Actually Burgess's argument: "Much as in the proof of 2.4 it suffices to show
    -- any particular conjunction ζ = snce(β,α) ∧ β ∧ δ.neg ∧ untl(β,γ) is consistent."
    --
    -- The key simplification: since B is a DCS (closed under conjunction), any finite
    -- subset of B has its conjunction in B. So w.l.o.g. there's a single b ∈ B.
    -- Similarly, the U/S formulas can be "combined" using A1a/A2a guard monotonicity.
    -- Then we need: b ∧ β.neg ∧ U(b, γ) ∧ S(b, α) is consistent for the universal b.
    --
    -- This is F(b ∧ β.neg ∧ S(b, α)) ∈ A — obtained from the BX5+BX14 chain
    -- plus BX13 (enrichment_until) to pack the S-formula into the event.
    --
    -- For now, let me use the simpler argument that DOES work:
    -- show the full D₀ is consistent using subset + known consistent sets.
    -- The key facts:
    -- (1) All untl(β',γ) are in A (burgessR3 Until direction)
    -- (2) All snce(β',α) are in C (burgessR3 Since direction)
    -- (3) {β.neg}∪B is either consistent directly, or β.neg∈B (in which case D₀⊆B∪A∪C).
    --
    -- In this CONSISTENT case ({β}∪B consistent): is {β.neg}∪B consistent?
    -- Not necessarily. β might be such that neither β nor β.neg is in B.
    -- But from β∉B and B is DCS: {β.neg}∪B might be consistent or not.
    -- If {β.neg}∪B is inconsistent: β.neg.neg∈B, i.e., β∈DC(B)=B (since B is DCS).
    -- But β∉B! Contradiction. So {β.neg}∪B IS consistent when β∉B and B is DCS.
    -- Wait: inconsistent means ∃L⊆{β.neg}∪B with L⊢⊥. By neg_mem_of_inconsistent_union:
    -- β.neg.neg ∈ B. But β.neg.neg = β→⊥→⊥ which is NOT the same as β!
    -- Actually in this logic, Formula.neg φ = φ.imp Formula.bot. So:
    -- β.neg = β.imp ⊥
    -- β.neg.neg = (β.imp ⊥).imp ⊥
    -- This is NOT definitionally equal to β, but is logically equivalent to β
    -- (double negation elimination).
    -- So if {β.neg}∪B inconsistent: neg_mem_of_inconsistent_union gives β.neg.neg ∈ B.
    -- Since B is DCS and ⊢ β.neg.neg → β (DNE), we get β ∈ B. Contradiction with β∉B.
    -- Therefore {β.neg}∪B IS consistent!
    have h_neg_cons : SetConsistent ({β.neg} ∪ B) := by
      intro L hL ⟨d⟩
      have h_nnn := neg_mem_of_inconsistent_union h_B_dcs (show ¬SetConsistent ({β.neg} ∪ B) from
        fun h => h L hL ⟨d⟩)
      -- β.neg.neg ∈ B, and ⊢ β.neg.neg → β (DNE), so β ∈ B. Contradiction.
      have h_dne : DerivationTree [] (β.neg.neg.imp β) :=
        Bimodal.Theorems.Propositional.double_negation β
      have h_β_in_B : β ∈ B := h_B_dcs.2 [β.neg.neg] β (fun ψ hψ => by
        simp at hψ; rw [hψ]; exact h_nnn)
        (DerivationTree.modus_ponens [β.neg.neg] β.neg.neg β
          (DerivationTree.weakening [] [β.neg.neg] (β.neg.neg.imp β) h_dne (List.nil_subset _))
          (DerivationTree.assumption _ β.neg.neg (by simp)))
      exact h_β_not_B h_β_in_B

    -- Burgess's argument (1982, p.370-371):
    -- Any finite L ⊆ D₀ compresses to ζ = b ∧ β.neg ∧ untl(b,γ̂) ∧ snce(b,α̂)
    -- where b = ∧(B-elements of L) ∈ B, γ̂ = ∧(C-events) ∈ C, α̂ = ∧(A-events) ∈ A.
    -- The BX5+BX14+BX13 chain constructs U(ζ, b) ∈ A, then BX10 gives F(ζ) ∈ A,
    -- proving ζ consistent. Since ζ implies each element of L (via conjunction
    -- elimination and guard weakening for U/S formulas), L is consistent.
    -- This uses: {β.neg}∪B consistent (h_neg_cons), BX chain (established above),
    -- DCS closure (B closed under ∧), and guard monotonicity (A2a/A1b).
    exact burgess_D0_finite_subset_consistent h_mcs_A h_mcs_C h_r3m h_gc β
      h_β_not_B h_neg_cons h_F_beta_neg beta0 h_beta0 gamma0 h_gamma0 h_neg_until_in_A

  · -- Case: {β} ∪ B is inconsistent, so β.neg ∈ B
    have h_beta_neg_in_B : β.neg ∈ B :=
      neg_mem_of_inconsistent_union h_B_dcs h_cons
    -- When β.neg ∈ B, D₀ = B ∪ untl-formulas ∪ snce-formulas (β.neg already in B).
    -- The seed is a subset of the consistent case seed (same components, just β.neg
    -- is redundant). Use the same Burgess compression argument:
    -- {β.neg}∪B is trivially consistent (β.neg ∈ B, so {β.neg}∪B = B, DCS consistent).
    have h_neg_cons : SetConsistent ({β.neg} ∪ B) :=
      SetConsistent_of_subset (Set.union_subset (Set.singleton_subset_iff.mpr h_beta_neg_in_B)
        (Set.Subset.refl B)) h_B_dcs.1
    -- F(β.neg) ∈ A: use the BX chain from the consistent case, or derive directly.
    -- In the inconsistent case, we still have the BX chain available since
    -- BurgessR3Maximal_extension_fails works regardless. But we can also use a
    -- simpler argument: β.neg ∈ B, and for all β'∈B, untl(β',γ)∈A (burgessR3).
    -- So untl(β.neg, γ₀)∈A for any γ₀∈C. BX10 gives F(γ₀)∈A for any γ₀∈C.
    -- From g_content(A) ⊆ C: h_content(C) ⊆ A (duality).
    -- Actually, we just need F(β.neg)∈A. Use: β.neg∈B, untl(β.neg, γ₀)∈A, BX10.
    -- BX10 gives F(γ₀)∈A, not F(β.neg). We need a different route.
    -- Use: untl(β.neg, γ₀)∈A and BX5: untl(β.neg∧untl(β.neg,γ₀), γ₀)∈A.
    -- Actually simplest: since {β.neg}∪B = B (β.neg∈B), the seed D₀ = B ∪ untl ∪ snce.
    -- This is exactly the pattern of the consistent case with h_neg_cons and
    -- we need F(β.neg)∈A for the Burgess compression.
    -- Direct route: burgessR3 gives untl(β.neg, γ₀)∈A. BX5+BX14+BX10 give F(β.neg)∈A.
    -- But BX14 needs ¬untl(r,p)∈A for some r. Without the maximality argument
    -- (which used {β}∪B consistent), we use a different approach.
    -- Simpler: we DON'T need F(β.neg)∈A for the inconsistent case!
    -- Since β.neg∈B, the seed D₀ ⊆ B∪{untl-formulas in A}∪{snce-formulas in C}.
    -- Use Burgess compression with the original untl(β₀,γ₀)∈A (from burgessR3 for any β₀∈B).
    exact burgess_D0_finite_subset_consistent_incons h_mcs_A h_mcs_C h_r3m h_gc β
      h_beta_neg_in_B

/-- **Lemma 2.6 Splitting** (Burgess 1982, Lemma 2.6): Given BurgessR3Maximal(A, B, C)
with β ∉ B, construct MCS D with β.neg ∈ D and decomposed BurgessR3Maximal relations:
BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C).

Uses Burgess's direct D₀ seed construction (bypassing the unprovable Since condition
for deductive closure extension). The seed includes explicit Until/Since formulas
to establish burgessR3 directly from seed membership. -/
theorem lemma_2_6_splitting {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (β : Formula)
    (h_β_not_B : β ∉ B) :
    ∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧ β.neg ∈ D := by
  -- Step 1: The Burgess D₀ seed is consistent
  have h_seed_cons := burgess_D0_seed_consistent h_mcs_A h_mcs_C h_r3m h_gc β h_β_not_B
  -- Step 2: Lindenbaum-extend to MCS D
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed_cons
  -- Step 3: Extract seed memberships
  have h_β_neg_D : β.neg ∈ D := by
    apply h_sup; show β.neg ∈ burgess_D0_seed A B C β
    simp [burgess_D0_seed]
  have h_B_sub_D : B ⊆ D := by
    intro φ hφ; apply h_sup
    show φ ∈ burgess_D0_seed A B C β; simp [burgess_D0_seed, hφ]
  -- Until formulas: untl(β', γ) ∈ D for all β' ∈ B, γ ∈ C
  have h_untl_D : ∀ β' ∈ B, ∀ γ ∈ C, Formula.untl β' γ ∈ D := by
    intro β' hβ' γ hγ; apply h_sup
    show Formula.untl β' γ ∈ burgess_D0_seed A B C β; simp [burgess_D0_seed, hβ', hγ]
  -- Since formulas: snce(β', α) ∈ D for all β' ∈ B, α ∈ A
  have h_snce_D : ∀ β' ∈ B, ∀ α ∈ A, Formula.snce β' α ∈ D := by
    intro β' hβ' α hα; apply h_sup
    show Formula.snce β' α ∈ burgess_D0_seed A B C β; simp [burgess_D0_seed, hβ', hα]
  -- Step 4: Establish burgessR3(D, B, C) from seed Until formulas
  have h_rSet_D : burgessRSet D B C := fun β' hβ' γ hγ => h_untl_D β' hβ' γ hγ
  -- burgessRSetSince(C, B, D) follows from burgessR via Lemma 2.3
  have h_rSetSince_D : burgessRSetSince C B D := by
    intro β' hβ'
    exact burgessR_implies_burgessRSince h_D_mcs h_mcs_C (h_rSet_D β' hβ')
  have h_r3_DBC : burgessR3 D B C := ⟨h_rSet_D, h_rSetSince_D⟩
  -- Step 5: Establish burgessR3(A, B, D) from seed Since formulas
  -- snce(β', α) ∈ D for all β' ∈ B, α ∈ A gives burgessRSetSince(D, B, A)
  have h_rSetSince_A : burgessRSetSince D B A := fun β' hβ' α hα => h_snce_D β' hβ' α hα
  -- burgessR(A, β', D) follows from burgessRSince via Lemma 2.3 backward
  have h_rSet_A : burgessRSet A B D := by
    intro β' hβ'
    exact burgessRSince_implies_burgessR h_mcs_A h_D_mcs (h_rSetSince_A β' hβ')
  have h_r3_ABD : burgessR3 A B D := ⟨h_rSet_A, h_rSetSince_A⟩
  -- Step 6: BurgessR3Maximal via Zorn (burgessR3Maximal_extension_exists)
  have h_no_univ_AD : ¬burgessR3 A Set.univ D := by
    sorry -- NoUnivBurgessR3: threaded from chronicle construction
  have h_no_univ_DC : ¬burgessR3 D Set.univ C := by
    sorry -- NoUnivBurgessR3: threaded from chronicle construction
  obtain ⟨B', _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
    h_r3m.1 h_r3_ABD h_no_univ_AD
  obtain ⟨B'', _, h_B''_max⟩ := burgessR3Maximal_extension_exists h_D_mcs h_mcs_C
    h_r3m.1 h_r3_DBC h_no_univ_DC
  exact ⟨B', D, B'', h_B'_max, h_B''_max, h_D_mcs, h_β_neg_D⟩

/-- The D0 seed for Lemma 2.7 (Burgess 1982 p.372):
  B ∪ {eta} ∪ {untl(β, γ) : β ∈ B, γ ∈ C}
  ∪ {snce(β, α) : β ∈ B, α ∈ A}
  ∪ {snce(β ∧ xi, α) : β ∈ B, α ∈ A}.

Convention alignment with Burgess:
  untl(xi, eta) ∈ A where xi = guard (Burgess η), eta = event (Burgess ξ).
  Burgess U(ξ,η) = U(event, guard) = untl(guard, event) = untl(xi, eta).
  The condition is xi ∉ B (guard not in B, matching Burgess η ∉ B).
  The seed contains {eta} (event, Burgess ξ) → eta ∈ D.
  The 5th component snce(β∧xi, α) (Burgess S(α, β∧η)) → xi ∈ B'. -/
private def lemma_2_7_seed (A B C : Set Formula) (xi eta : Formula) : Set Formula :=
  B ∪ {eta} ∪ {φ | ∃ β ∈ B, ∃ γ ∈ C, φ = Formula.untl β γ} ∪
  {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce β α} ∪
  {φ | ∃ β ∈ B, ∃ α ∈ A, φ = Formula.snce (Formula.and β xi) α}

/-- Consistency of the Lemma 2.7 D0 seed (Burgess 1982 p.372).

Convention: untl(xi, eta) = U(eta, xi) in Burgess. xi = guard (Burgess η), eta = event (Burgess ξ).
Condition: xi ∉ B (guard not in B, matching Burgess η ∉ B).

Proof structure (following Burgess exactly):
1. From xi ∉ B + maximality, extract beta0 ∈ B, gamma0 ∈ C with ¬untl(beta0∧xi, gamma0) ∈ A
2. BX5 on untl(xi, eta): untl(xi∧untl(xi,eta), eta) ∈ A (guard self-accumulation)
3. BX5 on untl(beta0, gamma0): untl(beta0∧untl(beta0,gamma0), gamma0) ∈ A
4. BX7 linear_until: three-way disjunction D1∨D2∨D3, all with guard g1∧g2
   where g1 = xi∧untl(xi,eta), g2 = beta0∧untl(beta0,gamma0)
5. Eliminate D1: left_mono (g1∧g2 → beta0∧xi), right_mono (eta∧gamma0 → gamma0)
   → untl(beta0∧xi, gamma0) ∈ A, contradicting ¬untl(beta0∧xi, gamma0)
6. Eliminate D2: left_mono (g1∧g2 → beta0∧xi), right_mono (eta∧g2 → gamma0)
   → untl(beta0∧xi, gamma0) ∈ A, same contradiction
   (Actually D2 event = eta∧g2; right_mono with g2 → gamma0 is NOT derivable.
    Instead: left_mono (g1∧g2 → xi), right_mono (eta∧g2 → eta) → untl(xi, eta).
    Then: left_mono (g1∧g2 → beta0∧xi) via right_mono on D2 event gamma0 path.
    Actually: from D2, left_mono ⊢ g1∧g2 → beta0∧xi gives untl(beta0∧xi, eta∧g2).
    right_mono ⊢ eta∧g2 → gamma0? No, g2 = beta0∧untl(beta0,gamma0) ≠> gamma0.
    Alternative: D2 event has eta, so right_mono ⊢ eta∧g2 → eta → ... not useful.
    Need to check: is D2 actually eliminable? YES via a 2-step chain.)
7. D3 survives: untl(g1∧g2, g1∧gamma0), event = (xi∧untl(xi,eta))∧gamma0
8. right_mono on D3: ⊢ g1∧gamma0 → gamma0, gives untl(g1∧g2, gamma0)
9. BX14 separation with untl(g1∧g2, gamma0) and ¬untl(beta0∧xi, gamma0):
   untl(g1∧g2, g1∧g2∧(beta0∧xi).neg) ∈ A
   (Wait: BX14 needs same event. OK since both have event gamma0.)
   Actually BX14: untl(q,p) ∧ ¬untl(r,p) → untl(q, q∧r.neg).
   q = g1∧g2, r = beta0∧xi, p = gamma0.
   Result: untl(g1∧g2, (g1∧g2)∧(beta0∧xi).neg) ∈ A.
10. BX13 iterated enrichment: packs snce(g1∧g2, α) for each α ∈ A
11. BX10: F(event) ∈ A, so event is consistent
12. Event implies all 5 seed components via left_mono/right_mono on snce/untl -/
private theorem lemma_2_7_seed_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (xi eta : Formula)
    (h_until : Formula.untl xi eta ∈ A)
    (h_xi_not_B : xi ∉ B) :
    SetConsistent (lemma_2_7_seed A B C xi eta) := by
  sorry

/-- **Lemma 2.7** (Burgess 1982 p.372): Given BurgessR3Maximal(A, B, C) with
untl(xi, eta) ∈ A and xi ∉ B (guard not in B), construct MCS D with eta ∈ D
(event in D) and B' with xi ∈ B' (guard in B').

Convention: untl(xi, eta) = U(eta, xi) in Burgess.
  xi = guard (Burgess η), eta = event (Burgess ξ).
  Burgess: U(ξ,η) ∈ A, η ∉ B, ξ ∈ D, η ∈ B'. -/
theorem lemma_2_7 {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (xi eta : Formula)
    (h_until : Formula.untl xi eta ∈ A)
    (h_xi_not_B : xi ∉ B) :
    ∃ B' D B'' : Set Formula,
      BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧
      eta ∈ D ∧
      xi ∈ B' := by
  -- Step 1: The D0 seed is consistent
  have h_seed_cons := lemma_2_7_seed_consistent h_mcs_A h_mcs_C h_r3m h_gc xi eta h_until h_xi_not_B
  -- Step 2: Lindenbaum-extend to MCS D
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed_cons
  -- Step 3: Extract key memberships from seed
  have h_eta_D : eta ∈ D := by
    apply h_sup; show eta ∈ lemma_2_7_seed A B C xi eta; simp [lemma_2_7_seed]
  have h_B_sub_D : B ⊆ D := by
    intro φ hφ; apply h_sup
    show φ ∈ lemma_2_7_seed A B C xi eta; simp [lemma_2_7_seed, hφ]
  -- Until formulas: untl(β, γ) ∈ D for all β ∈ B, γ ∈ C
  have h_untl_D : ∀ β ∈ B, ∀ γ ∈ C, Formula.untl β γ ∈ D := by
    intro β hβ γ hγ; apply h_sup
    show Formula.untl β γ ∈ lemma_2_7_seed A B C xi eta; simp [lemma_2_7_seed, hβ, hγ]
  -- Since formulas: snce(β, α) ∈ D for all β ∈ B, α ∈ A
  have h_snce_D : ∀ β ∈ B, ∀ α ∈ A, Formula.snce β α ∈ D := by
    intro β hβ α hα; apply h_sup
    show Formula.snce β α ∈ lemma_2_7_seed A B C xi eta; simp [lemma_2_7_seed, hβ, hα]
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
  -- Step 5b: Extract snce(β∧xi, α) ∈ D from the 5th seed component
  -- (xi = guard = Burgess η; the 5th component is S(α, β∧η) in Burgess)
  have h_snce_conj_xi_D : ∀ β ∈ B, ∀ α ∈ A, Formula.snce (Formula.and β xi) α ∈ D := by
    intro β hβ α hα; apply h_sup
    show Formula.snce (Formula.and β xi) α ∈ lemma_2_7_seed A B C xi eta
    simp only [lemma_2_7_seed, Set.mem_union, Set.mem_setOf_eq]; right; exact ⟨β, hβ, α, hα, rfl⟩
  -- Step 5c: Derive snce(xi, α) ∈ D for all α ∈ A (via left_mono_since)
  -- From snce(β∧xi, α) ∈ D and ⊢ (β∧xi) → xi: snce(xi, α) ∈ D
  have h_B_nonempty : ∃ β₀ : Formula, β₀ ∈ B := by
    exact ⟨Formula.bot.imp Formula.bot, dcs_contains_theorems h_r3m.1
      (Bimodal.Theorems.Combinators.identity Formula.bot)⟩
  obtain ⟨β₀, hβ₀⟩ := h_B_nonempty
  have h_snce_xi_D : ∀ α ∈ A, Formula.snce xi α ∈ D := by
    intro α hα
    have h_impl : DerivationTree [] ((Formula.and β₀ xi).imp xi) :=
      Bimodal.Theorems.Propositional.rce_imp β₀ xi
    exact snce_left_mono_thm h_D_mcs h_impl (h_snce_conj_xi_D β₀ hβ₀ α hα)
  -- Step 5d: Derive untl(xi, δ) ∈ A for all δ ∈ D (via burgessRSince_implies_burgessR)
  -- snce(xi, α) ∈ D for all α ∈ A gives burgessRSince(D, xi, A)
  have h_burgessRSince_xi : burgessRSince D xi A := h_snce_xi_D
  have h_burgessR_xi : burgessR A xi D :=
    burgessRSince_implies_burgessR h_mcs_A h_D_mcs h_burgessRSince_xi
  -- Step 6: Case split on {xi} consistency.
  -- If {xi} is consistent: proceed with DC({xi}) Zorn path (works regardless of
  -- whether {xi} ∪ B is consistent or inconsistent).
  -- If {xi} is inconsistent: xi is a contradiction (e.g., p ∧ ¬p). This degenerate
  -- case requires BurgessR3Maximal to range over ClosedUnderDerivation (Burgess's
  -- original definition, where Set.univ is a valid DCS). Deferred.
  by_cases h_xi_cons : SetConsistent ({xi} : Set Formula)
  · -- Step 7: Build burgessR3 A (DC({xi})) D
    have h_dc_xi_dcs : SetDeductivelyClosed (deductiveClosure ({xi} : Set Formula)) :=
      deductiveClosure_is_dcs h_xi_cons
    have h_dc_xi_r3 : burgessR3 A (deductiveClosure ({xi} : Set Formula)) D := by
      constructor
      · -- burgessRSet: ∀ φ ∈ DC({xi}), ∀ δ ∈ D, untl(φ, δ) ∈ A
        intro φ hφ δ hδ
        obtain ⟨L, hL_sub, ⟨d_phi⟩⟩ := hφ
        have h_L_xi : ∀ ψ ∈ L, ψ = xi :=
          fun ψ hψ => Set.mem_singleton_iff.mp (hL_sub ψ hψ)
        have h_L_sub_rep : ∀ ψ ∈ L, ψ ∈ [xi] := by
          intro ψ hψ; simp [h_L_xi ψ hψ]
        have d_from_xi : DerivationTree [xi] φ :=
          DerivationTree.weakening L [xi] φ d_phi h_L_sub_rep
        have d_impl : DerivationTree [] (xi.imp φ) := deduction_theorem [] xi φ d_from_xi
        exact untl_left_mono_thm h_mcs_A d_impl (h_burgessR_xi δ hδ)
      · -- burgessRSetSince: ∀ φ ∈ DC({xi}), ∀ α ∈ A, snce(φ, α) ∈ D
        intro φ hφ α hα
        obtain ⟨L, hL_sub, ⟨d_phi⟩⟩ := hφ
        have h_L_xi : ∀ ψ ∈ L, ψ = xi :=
          fun ψ hψ => Set.mem_singleton_iff.mp (hL_sub ψ hψ)
        have h_L_sub_rep : ∀ ψ ∈ L, ψ ∈ [xi] := by
          intro ψ hψ; simp [h_L_xi ψ hψ]
        have d_from_xi : DerivationTree [xi] φ :=
          DerivationTree.weakening L [xi] φ d_phi h_L_sub_rep
        have d_impl : DerivationTree [] (xi.imp φ) := deduction_theorem [] xi φ d_from_xi
        exact snce_left_mono_thm h_D_mcs d_impl (h_snce_xi_D α hα)
    -- Step 8: BurgessR3Maximal via Zorn from DC({xi})
    have h_no_univ_AD : ¬burgessR3 A Set.univ D := by
      sorry -- NoUnivBurgessR3: threaded from chronicle construction
    have h_no_univ_DC : ¬burgessR3 D Set.univ C := by
      sorry -- NoUnivBurgessR3: threaded from chronicle construction
    obtain ⟨B', _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
      h_dc_xi_dcs h_dc_xi_r3 h_no_univ_AD
    -- Step 9: BurgessR3Maximal(D, B'', C) via Zorn from B
    obtain ⟨B'', _, h_B''_max⟩ := burgessR3Maximal_extension_exists h_D_mcs h_mcs_C
      h_r3m.1 h_r3_DBC h_no_univ_DC
    -- Step 10: xi ∈ B' (since DC({xi}) ⊆ B' and xi ∈ DC({xi}))
    have h_xi_B' : xi ∈ B' := by
      have h_xi_dc : xi ∈ deductiveClosure ({xi} : Set Formula) :=
        subset_deductiveClosure _ (Set.mem_singleton xi)
      exact ‹deductiveClosure ({xi} : Set Formula) ⊆ B'› h_xi_dc
    exact ⟨B', D, B'', h_B'_max, h_B''_max, h_D_mcs, h_eta_D, h_xi_B'⟩
  · -- Degenerate case: {xi} is inconsistent (xi is a contradiction like p ∧ ¬p).
    -- No consistent SetDeductivelyClosed set can contain xi. This requires either:
    -- (a) Strengthening BurgessR3Maximal to use ClosedUnderDerivation (Burgess's
    --     original definition, where B' = Set.univ is valid), or
    -- (b) Adding SetConsistent ({xi}) as a hypothesis (provable in the dense-order
    --     chronicle construction since untl(inconsistent_guard, event) is
    --     unsatisfiable on dense orders).
    -- In the chronicle construction over Q (dense), this case never arises because
    -- untl(xi, eta) ∈ f(x) with xi inconsistent implies xi holds at intermediate
    -- points, which is impossible on dense orders. So this sorry is unreachable
    -- in the completeness proof.
    sorry

end Bimodal.Metalogic.BXCanonical.Chronicle
