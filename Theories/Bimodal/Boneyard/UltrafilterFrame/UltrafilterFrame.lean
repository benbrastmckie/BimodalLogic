-- ARCHIVED (Task 21, 2026-05-20): Jonsson-Tarski ultrafilter frame and chain infrastructure.
-- UltrafilterFrame commented out from Algebraic.lean due to elaboration conflicts;
-- has 2 sorries for temp_4 (Gφ -> GGφ). Recoverable via git history for task 125.
import Bimodal.Boneyard.UltrafilterFrame.TenseS5Algebra
import Bimodal.Metalogic.Algebraic.UltrafilterMCS
import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Theorems.Perpetuity
import Bimodal.Theorems.TemporalDerived

/-!
# Ultrafilter Frame Infrastructure

This module defines the ultrafilter frame relations R_G, R_H, R_Box and proves their
key properties. It also provides the UltrafilterChain structure for building temporally
connected chains of ultrafilters, and the F/P resolution theorems for constructing
successor/predecessor ultrafilters.

## Provenance

Recovered from Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean (Phase 1,
lines 56-1519). Phase 2 (box-class BFMCS construction, lines 1520+) remains in the
Boneyard. This module is a prerequisite for the Jonsson-Tarski representation theorem
(task 125).

## Structure

### Generic (any STSA α)

- `R_G`, `R_H`, `R_Box`: Accessibility relations on ultrafilters
- `R_Box_refl`, `R_Box_euclidean`, `R_Box_symm`, `R_Box_trans`: S5 properties of R_Box
- `R_G_R_H_converse`: G/H temporal duality via sigma
- `G_preimage`, `H_preimage`: Preimage filter definitions
- `G_preimage_upward`, `H_preimage_upward`: Upward closure

### LindenbaumAlg-specific

- `R_G_trans`, `R_H_trans`: Transitivity (requires temp_4)
- `G_preimage_top/inf`, `H_preimage_top/inf`: Filter properties (require formula-level proofs)
- `ultrafilter_F_resolution`, `ultrafilter_P_resolution`: F/P witness existence
- `UltrafilterChain`: Int-indexed chains with R_G connectivity
- `UltrafilterChain_to_FMCS`: Conversion to FMCS Int

## Known Sorries

Two sorries for `temp_4` (Gφ → GGφ, derivable from BX1+K but removed during axiom cleanup):
1. In `R_G_trans` at the `STSA.G a ≤ STSA.G (STSA.G a)` step
2. In `UltrafilterChain.forward_G` at the G-persistence step
-/

namespace Bimodal.Metalogic.Algebraic.UltrafilterFrame

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient
open Bimodal.Metalogic.Algebraic.BooleanStructure
open Bimodal.Metalogic.Algebraic.InteriorOperators
open Bimodal.Metalogic.Algebraic.TenseS5Algebra
open Bimodal.Metalogic.Algebraic.UltrafilterMCS
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/-!
## Generic Accessibility Relations (any STSA α)
-/

section Generic

variable {α : Type*} [STSA α]

/--
Temporal accessibility relation R_G on ultrafilters.

R_G(U, V) holds iff for all a, G(a) ∈ U implies a ∈ V.
This is the preimage containment: V contains all elements whose G is in U.
-/
def R_G (U V : Ultrafilter α) : Prop :=
  ∀ a : α, STSA.G a ∈ U → a ∈ V

/--
Modal accessibility relation R_Box on ultrafilters.

R_Box(U, V) holds iff for all a, □a ∈ U implies a ∈ V.
-/
def R_Box (U V : Ultrafilter α) : Prop :=
  ∀ a : α, STSA.box a ∈ U → a ∈ V

/--
Backward temporal accessibility relation R_H on ultrafilters.

R_H(U, V) holds iff for all a, H(a) ∈ U implies a ∈ V.
-/
def R_H (U V : Ultrafilter α) : Prop :=
  ∀ a : α, STSA.H a ∈ U → a ∈ V

/-!
### R_Box Properties (generic)
-/

/--
R_Box is reflexive: every ultrafilter is R_Box-related to itself.

Proof: From box_deflationary, we have □a ≤ a. Since □a ∈ U and U is
upward closed, a ∈ U follows.
-/
theorem R_Box_refl (U : Ultrafilter α) : R_Box U U := by
  intro a h_boxa_in
  have h_le : STSA.box a ≤ a := STSA.box_deflationary a
  exact U.mem_of_le h_boxa_in h_le

/--
R_Box is Euclidean: R_Box(U, V) and R_Box(U, W) imply R_Box(V, W).

The correct S5 Euclidean proof:
- Assume □a ∈ V. We show a ∈ W.
- Case 1: □a ∈ U. Then by R_Box(U, W): a ∈ W. Done.
- Case 2: □a ∉ U. Then (□a)ᶜ ∈ U.
  By S5 collapse: (□a)ᶜ ≤ □(□a)ᶜ, so □(□a)ᶜ ∈ U.
  By R_Box(U, V): (□a)ᶜ ∈ V.
  But □a ∈ V, contradiction.
-/
theorem R_Box_euclidean {U V W : Ultrafilter α}
    (h_UV : R_Box U V) (h_UW : R_Box U W) : R_Box V W := by
  intro a h_boxa_in_V
  by_contra h_a_notin_W
  have h_ac_in_W : aᶜ ∈ W := by
    cases W.compl_or a with
    | inl h => exact absurd h h_a_notin_W
    | inr h => exact h
  have h_boxac_notin_V : (STSA.box a)ᶜ ∉ V := V.compl_not (STSA.box a) h_boxa_in_V
  have h_s5 : (STSA.box a)ᶜ ≤ STSA.box ((STSA.box a)ᶜ) := STSA.box_s5 a
  by_cases h_boxa_in_U : STSA.box a ∈ U
  · exact h_a_notin_W (h_UW a h_boxa_in_U)
  · have h_boxac_in_U : (STSA.box a)ᶜ ∈ U := by
      cases U.compl_or (STSA.box a) with
      | inl h => exact absurd h h_boxa_in_U
      | inr h => exact h
    have h_box_boxac_in_U : STSA.box ((STSA.box a)ᶜ) ∈ U :=
      U.mem_of_le h_boxac_in_U h_s5
    have h_boxac_in_V : (STSA.box a)ᶜ ∈ V := h_UV ((STSA.box a)ᶜ) h_box_boxac_in_U
    exact V.compl_not (STSA.box a) h_boxa_in_V h_boxac_in_V

/--
R_Box is symmetric: R_Box(U, V) implies R_Box(V, U).

Proof using Euclidean + reflexive:
R_Box(U, V) and R_Box(U, U) (reflexivity) imply R_Box(V, U) by Euclidean.
-/
theorem R_Box_symm {U V : Ultrafilter α} (h : R_Box U V) : R_Box V U :=
  R_Box_euclidean h (R_Box_refl U)

/--
R_Box is transitive: R_Box(U, V) and R_Box(V, W) imply R_Box(U, W).

Proof using symmetric + Euclidean:
R_Box(U, V) implies R_Box(V, U) by symmetry.
R_Box(V, U) and R_Box(V, W) imply R_Box(U, W) by Euclidean.
-/
theorem R_Box_trans {U V W : Ultrafilter α}
    (h_UV : R_Box U V) (h_VW : R_Box V W) : R_Box U W :=
  R_Box_euclidean (R_Box_symm h_UV) h_VW

/-!
### R_G / R_H Duality (generic)
-/

/--
R_G and R_H are converses: R_G(U, V) iff R_H(V, U).

This follows from the temporal duality captured by the sigma involution.
The forward direction uses TA: a ≤ G(P(a)) where P = ¬H¬.
The backward direction uses the sigma-dual of TA.
-/
theorem R_G_R_H_converse {U V : Ultrafilter α} :
    R_G U V ↔ R_H V U := by
  constructor
  · -- R_G(U, V) → R_H(V, U)
    intro h_R_G b h_Hb_in_V
    by_contra h_b_notin_U
    have h_bc_in_U : bᶜ ∈ U := U.not_mem_iff_compl_mem b |>.mp h_b_notin_U
    -- By TA: bᶜ ≤ G((H((bᶜ)ᶜ))ᶜ) = G((H(b))ᶜ)
    have h_TA : bᶜ ≤ STSA.G ((STSA.H ((bᶜ)ᶜ))ᶜ) := STSA.TA bᶜ
    simp only [compl_compl] at h_TA
    have h_G_Hbc_in_U : STSA.G ((STSA.H b)ᶜ) ∈ U := U.mem_of_le h_bc_in_U h_TA
    have h_Hbc_in_V : (STSA.H b)ᶜ ∈ V := h_R_G ((STSA.H b)ᶜ) h_G_Hbc_in_U
    exact V.compl_not (STSA.H b) h_Hb_in_V h_Hbc_in_V

  · -- R_H(V, U) → R_G(U, V)
    intro h_R_H a h_Ga_in_U
    by_contra h_a_notin_V
    have h_ac_in_V : aᶜ ∈ V := V.not_mem_iff_compl_mem a |>.mp h_a_notin_V

    -- Derive the past-TA from sigma duality: aᶜ ≤ H((G(a))ᶜ)
    have h_TA_sigma : aᶜ ≤ STSA.H ((STSA.G a)ᶜ) := by
      have h_TA_base : STSA.sigma (aᶜ) ≤ STSA.G ((STSA.H ((STSA.sigma (aᶜ))ᶜ))ᶜ) :=
        STSA.TA (STSA.sigma (aᶜ))
      have h_sigma_mono : ∀ x y : α, x ≤ y → STSA.sigma x ≤ STSA.sigma y := by
        intro x y h_xy
        have h_sup : x ⊔ y = y := sup_eq_right.mpr h_xy
        have h_sigma_sup_eq : STSA.sigma (x ⊔ y) = STSA.sigma y := by rw [h_sup]
        rw [STSA.sigma_sup] at h_sigma_sup_eq
        exact sup_eq_right.mp h_sigma_sup_eq
      have h_step1 : STSA.sigma (STSA.sigma (aᶜ)) ≤
          STSA.sigma (STSA.G ((STSA.H ((STSA.sigma (aᶜ))ᶜ))ᶜ)) :=
        h_sigma_mono _ _ h_TA_base
      rw [STSA.sigma_involution] at h_step1
      rw [STSA.sigma_G] at h_step1
      simp only [STSA.sigma_neg] at h_step1
      rw [STSA.sigma_H] at h_step1
      simp only [STSA.sigma_neg, STSA.sigma_involution, compl_compl] at h_step1
      exact h_step1

    have h_H_Gac_in_V : STSA.H ((STSA.G a)ᶜ) ∈ V := V.mem_of_le h_ac_in_V h_TA_sigma
    have h_Gac_in_U : (STSA.G a)ᶜ ∈ U := h_R_H ((STSA.G a)ᶜ) h_H_Gac_in_V
    exact U.compl_not (STSA.G a) h_Ga_in_U h_Gac_in_U

/-!
### Preimage Sets (generic definitions, generic upward closure)
-/

/--
The G-preimage set of an ultrafilter: all elements whose G is in U.
-/
def G_preimage (U : Ultrafilter α) : Set α :=
  { a | STSA.G a ∈ U }

/--
The H-preimage set of an ultrafilter: all elements whose H is in U.
-/
def H_preimage (U : Ultrafilter α) : Set α :=
  { a | STSA.H a ∈ U }

/--
G_preimage is upward closed.
-/
theorem G_preimage_upward (U : Ultrafilter α) (a b : α)
    (ha : a ∈ G_preimage U) (h_le : a ≤ b) : b ∈ G_preimage U := by
  unfold G_preimage at ha ⊢
  simp only [Set.mem_setOf_eq] at ha ⊢
  have h_G_le : STSA.G a ≤ STSA.G b := STSA.G_monotone a b h_le
  exact U.mem_of_le ha h_G_le

/--
H_preimage is upward closed.
-/
theorem H_preimage_upward (U : Ultrafilter α) (a b : α)
    (ha : a ∈ H_preimage U) (h_le : a ≤ b) : b ∈ H_preimage U := by
  unfold H_preimage at ha ⊢
  simp only [Set.mem_setOf_eq] at ha ⊢
  have h_H_le : STSA.H a ≤ STSA.H b := STSA.H_monotone a b h_le
  exact U.mem_of_le ha h_H_le

end Generic

/-!
## LindenbaumAlg-Specific Properties

The following properties require formula-level reasoning and are specific to
the Lindenbaum algebra instance of STSA.
-/

/-!
### R_G / R_H Transitivity (LindenbaumAlg-specific)
-/

-- R_G is NOT reflexive under strict semantics (G quantifies over s > t).

/--
R_G is transitive: R_G(U, V) and R_G(V, W) imply R_G(U, W).

Proof: If G(a) ∈ U and R_G(U, V), then we need a ∈ W.
From temp_4_future: G(a) ≤ G(G(a)), so G(G(a)) ∈ U.
By R_G(U, V): G(a) ∈ V.
By R_G(V, W): a ∈ W.
-/
theorem R_G_trans {U V W : Ultrafilter LindenbaumAlg}
    (h_UV : R_G U V) (h_VW : R_G V W) : R_G U W := by
  intro a h_Ga_in
  have h_le : STSA.G a ≤ STSA.G (STSA.G a) := by
    induction a using Quotient.ind with
    | _ φ =>
      show G_quot (toQuot φ) ≤ G_quot (G_quot (toQuot φ))
      show Derives φ.all_future φ.all_future.all_future
      exact ⟨sorry /- temp_4: Gφ → GGφ, derivable from BX1+K but removed during axiom cleanup -/⟩
  have h_GGa_in : STSA.G (STSA.G a) ∈ U := U.mem_of_le h_Ga_in h_le
  have h_Ga_in_V : STSA.G a ∈ V := h_UV (STSA.G a) h_GGa_in
  exact h_VW a h_Ga_in_V

-- R_H is NOT reflexive under strict semantics (H quantifies over s < t).

/--
R_H is transitive: R_H(U, V) and R_H(V, W) imply R_H(U, W).

Proof: If H(a) ∈ U and R_H(U, V), then we need a ∈ W.
From temp_4_past: H(a) ≤ H(H(a)), so H(H(a)) ∈ U.
By R_H(U, V): H(a) ∈ V.
By R_H(V, W): a ∈ W.
-/
theorem R_H_trans {U V W : Ultrafilter LindenbaumAlg}
    (h_UV : R_H U V) (h_VW : R_H V W) : R_H U W := by
  intro a h_Ha_in
  have h_le : STSA.H a ≤ STSA.H (STSA.H a) := by
    induction a using Quotient.ind with
    | _ φ =>
      show H_quot (toQuot φ) ≤ H_quot (H_quot (toQuot φ))
      show Derives φ.all_past φ.all_past.all_past
      exact ⟨temp_4_past φ⟩
  have h_HHa_in : STSA.H (STSA.H a) ∈ U := U.mem_of_le h_Ha_in h_le
  have h_Ha_in_V : STSA.H a ∈ V := h_UV (STSA.H a) h_HHa_in
  exact h_VW a h_Ha_in_V

/-!
### G/H Preimage Filter Properties (LindenbaumAlg-specific)
-/

/--
G_preimage contains ⊤ (since G(⊤) = ⊤ is always in an ultrafilter).
-/
theorem G_preimage_top (U : Ultrafilter LindenbaumAlg) : ⊤ ∈ G_preimage U := by
  unfold G_preimage
  simp only [Set.mem_setOf_eq]
  have h_G_top : STSA.G (⊤ : LindenbaumAlg) = ⊤ := by
    apply le_antisymm
    · exact le_top
    · show top_quot ≤ G_quot top_quot
      unfold top_quot G_quot
      show Derives (Formula.bot.imp Formula.bot) (Formula.all_future (Formula.bot.imp Formula.bot))
      have h_id : [] ⊢ Formula.bot.imp Formula.bot :=
        Bimodal.Theorems.Combinators.identity Formula.bot
      have h_nec : [] ⊢ Formula.all_future (Formula.bot.imp Formula.bot) :=
        DerivationTree.temporal_necessitation (Formula.bot.imp Formula.bot) h_id
      have h_s : [] ⊢ (Formula.all_future (Formula.bot.imp Formula.bot)).imp
          ((Formula.bot.imp Formula.bot).imp (Formula.all_future (Formula.bot.imp Formula.bot))) :=
        DerivationTree.axiom [] _ (Axiom.prop_s _ _)
      exact ⟨DerivationTree.modus_ponens [] _ _ h_s h_nec⟩
  rw [h_G_top]
  exact U.top_mem

/--
G_preimage is closed under finite meets.

Proof uses the K-axiom distribution: G(a) ∧ G(b) → G(a ∧ b)
derived from temp_k_dist and necessitation.
-/
theorem G_preimage_inf (U : Ultrafilter LindenbaumAlg) (a b : LindenbaumAlg)
    (ha : a ∈ G_preimage U) (hb : b ∈ G_preimage U) : a ⊓ b ∈ G_preimage U := by
  unfold G_preimage at ha hb ⊢
  simp only [Set.mem_setOf_eq] at ha hb ⊢
  have h_inf : STSA.G a ⊓ STSA.G b ∈ U := U.inf_mem ha hb
  have h_K_inf : STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b) := by
    induction a using Quotient.ind
    induction b using Quotient.ind
    rename_i φ ψ
    show Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
    unfold Derives
    have d_pairing : ⊢ φ.imp (ψ.imp (φ.and ψ)) :=
      Bimodal.Theorems.Combinators.pairing φ ψ
    have d_G_pairing : ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_future :=
      DerivationTree.temporal_necessitation (φ.imp (ψ.imp (φ.and ψ))) d_pairing
    have d_k1 : ⊢ ((φ.imp (ψ.imp (φ.and ψ))).all_future).imp
                   (φ.all_future.imp (ψ.imp (φ.and ψ)).all_future) :=
      Bimodal.Theorems.Perpetuity.future_k_dist _ _
    have d_step3 : ⊢ φ.all_future.imp (ψ.imp (φ.and ψ)).all_future :=
      DerivationTree.modus_ponens [] _ _ d_k1 d_G_pairing
    have d_k2 : ⊢ ((ψ.imp (φ.and ψ)).all_future).imp
                   (ψ.all_future.imp (φ.and ψ).all_future) :=
      Bimodal.Theorems.Perpetuity.future_k_dist _ _
    have d_b : ⊢ ((ψ.imp (φ.and ψ)).all_future.imp (ψ.all_future.imp (φ.and ψ).all_future)).imp
                  ((φ.all_future.imp (ψ.imp (φ.and ψ)).all_future).imp
                   (φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future))) :=
      Bimodal.Theorems.Combinators.b_combinator
    have d_step5_inter : ⊢ (φ.all_future.imp (ψ.imp (φ.and ψ)).all_future).imp
                           (φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future)) :=
      DerivationTree.modus_ponens [] _ _ d_b d_k2
    have d_step5 : ⊢ φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) :=
      DerivationTree.modus_ponens [] _ _ d_step5_inter d_step3
    have h_ctx : [φ.all_future.and ψ.all_future] ⊢ (φ.and ψ).all_future := by
      have h_conj : [φ.all_future.and ψ.all_future] ⊢ φ.all_future.and ψ.all_future := by
        apply DerivationTree.assumption
        simp
      have h_Gφ : [φ.all_future.and ψ.all_future] ⊢ φ.all_future := by
        apply DerivationTree.modus_ponens _ _ _
        · apply DerivationTree.weakening [] _
          · exact Bimodal.Theorems.Propositional.lce_imp φ.all_future ψ.all_future
          · intro; simp
        · exact h_conj
      have h_Gψ : [φ.all_future.and ψ.all_future] ⊢ ψ.all_future := by
        apply DerivationTree.modus_ponens _ _ _
        · apply DerivationTree.weakening [] _
          · exact Bimodal.Theorems.Propositional.rce_imp φ.all_future ψ.all_future
          · intro; simp
        · exact h_conj
      have h_step5_ctx : [φ.all_future.and ψ.all_future] ⊢
          φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) := by
        apply DerivationTree.weakening [] _
        · exact d_step5
        · intro; simp
      have h_inner : [φ.all_future.and ψ.all_future] ⊢ ψ.all_future.imp (φ.and ψ).all_future :=
        DerivationTree.modus_ponens _ _ _ h_step5_ctx h_Gφ
      exact DerivationTree.modus_ponens _ _ _ h_inner h_Gψ
    exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] (φ.all_future.and ψ.all_future)
             (φ.and ψ).all_future h_ctx⟩
  exact U.mem_of_le h_inf h_K_inf

/--
H_preimage contains ⊤ (since H(⊤) = ⊤ is always in an ultrafilter).
-/
theorem H_preimage_top (U : Ultrafilter LindenbaumAlg) : ⊤ ∈ H_preimage U := by
  unfold H_preimage
  simp only [Set.mem_setOf_eq]
  have h_H_top : STSA.H (⊤ : LindenbaumAlg) = ⊤ := by
    apply le_antisymm
    · exact le_top
    · show top_quot ≤ H_quot top_quot
      unfold top_quot H_quot
      show Derives (Formula.bot.imp Formula.bot) (Formula.all_past (Formula.bot.imp Formula.bot))
      have h_id : [] ⊢ Formula.bot.imp Formula.bot :=
        Bimodal.Theorems.Combinators.identity Formula.bot
      have h_nec : [] ⊢ Formula.all_past (Formula.bot.imp Formula.bot) :=
        Bimodal.Theorems.past_necessitation (Formula.bot.imp Formula.bot) h_id
      have h_s : [] ⊢ (Formula.all_past (Formula.bot.imp Formula.bot)).imp
          ((Formula.bot.imp Formula.bot).imp (Formula.all_past (Formula.bot.imp Formula.bot))) :=
        DerivationTree.axiom [] _ (Axiom.prop_s _ _)
      exact ⟨DerivationTree.modus_ponens [] _ _ h_s h_nec⟩
  rw [h_H_top]
  exact U.top_mem

/--
H_preimage is closed under finite meets.

Proof uses the K-axiom distribution for H: H(a) ∧ H(b) → H(a ∧ b)
derived from past_k_dist and past_necessitation.
-/
theorem H_preimage_inf (U : Ultrafilter LindenbaumAlg) (a b : LindenbaumAlg)
    (ha : a ∈ H_preimage U) (hb : b ∈ H_preimage U) : a ⊓ b ∈ H_preimage U := by
  unfold H_preimage at ha hb ⊢
  simp only [Set.mem_setOf_eq] at ha hb ⊢
  have h_inf : STSA.H a ⊓ STSA.H b ∈ U := U.inf_mem ha hb
  have h_K_inf : STSA.H a ⊓ STSA.H b ≤ STSA.H (a ⊓ b) := by
    induction a using Quotient.ind
    induction b using Quotient.ind
    rename_i φ ψ
    show Derives (φ.all_past.and ψ.all_past) (φ.and ψ).all_past
    unfold Derives
    have d_pairing : ⊢ φ.imp (ψ.imp (φ.and ψ)) :=
      Bimodal.Theorems.Combinators.pairing φ ψ
    have d_H_pairing : ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_past :=
      Bimodal.Theorems.past_necessitation (φ.imp (ψ.imp (φ.and ψ))) d_pairing
    have d_k1 : ⊢ ((φ.imp (ψ.imp (φ.and ψ))).all_past).imp
                   (φ.all_past.imp (ψ.imp (φ.and ψ)).all_past) :=
      Bimodal.Theorems.past_k_dist φ (ψ.imp (φ.and ψ))
    have d_step3 : ⊢ φ.all_past.imp (ψ.imp (φ.and ψ)).all_past :=
      DerivationTree.modus_ponens [] _ _ d_k1 d_H_pairing
    have d_k2 : ⊢ ((ψ.imp (φ.and ψ)).all_past).imp
                   (ψ.all_past.imp (φ.and ψ).all_past) :=
      Bimodal.Theorems.past_k_dist ψ (φ.and ψ)
    have d_b : ⊢ ((ψ.imp (φ.and ψ)).all_past.imp (ψ.all_past.imp (φ.and ψ).all_past)).imp
                  ((φ.all_past.imp (ψ.imp (φ.and ψ)).all_past).imp
                   (φ.all_past.imp (ψ.all_past.imp (φ.and ψ).all_past))) :=
      Bimodal.Theorems.Combinators.b_combinator
    have d_step5_inter : ⊢ (φ.all_past.imp (ψ.imp (φ.and ψ)).all_past).imp
                           (φ.all_past.imp (ψ.all_past.imp (φ.and ψ).all_past)) :=
      DerivationTree.modus_ponens [] _ _ d_b d_k2
    have d_step5 : ⊢ φ.all_past.imp (ψ.all_past.imp (φ.and ψ).all_past) :=
      DerivationTree.modus_ponens [] _ _ d_step5_inter d_step3
    have h_ctx : [φ.all_past.and ψ.all_past] ⊢ (φ.and ψ).all_past := by
      have h_conj : [φ.all_past.and ψ.all_past] ⊢ φ.all_past.and ψ.all_past := by
        apply DerivationTree.assumption
        simp
      have h_Hφ : [φ.all_past.and ψ.all_past] ⊢ φ.all_past := by
        apply DerivationTree.modus_ponens _ _ _
        · apply DerivationTree.weakening [] _
          · exact Bimodal.Theorems.Propositional.lce_imp φ.all_past ψ.all_past
          · intro; simp
        · exact h_conj
      have h_Hψ : [φ.all_past.and ψ.all_past] ⊢ ψ.all_past := by
        apply DerivationTree.modus_ponens _ _ _
        · apply DerivationTree.weakening [] _
          · exact Bimodal.Theorems.Propositional.rce_imp φ.all_past ψ.all_past
          · intro; simp
        · exact h_conj
      have h_step5_ctx : [φ.all_past.and ψ.all_past] ⊢
          φ.all_past.imp (ψ.all_past.imp (φ.and ψ).all_past) := by
        apply DerivationTree.weakening [] _
        · exact d_step5
        · intro; simp
      have h_inner : [φ.all_past.and ψ.all_past] ⊢ ψ.all_past.imp (φ.and ψ).all_past :=
        DerivationTree.modus_ponens _ _ _ h_step5_ctx h_Hφ
      exact DerivationTree.modus_ponens _ _ _ h_inner h_Hψ
    exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] (φ.all_past.and ψ.all_past)
             (φ.and ψ).all_past h_ctx⟩
  exact U.mem_of_le h_inf h_K_inf

/-!
## F/P Resolution Theorems

These are the crux theorems: F(a) ∈ U implies existence of successor ultrafilter
containing a, and P(a) ∈ U implies existence of predecessor ultrafilter containing a.
-/

/--
The crux theorem: F(a) ∈ U implies existence of successor ultrafilter containing a.

Given F(phi) in ultrafilter U, there exists ultrafilter V with:
- R_G(U, V): for all b, G(b) ∈ U implies b ∈ V
- phi ∈ V

This eliminates the F-persistence problem from the MCS approach.
-/
theorem ultrafilter_F_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_F : (STSA.G aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_G U V ∧ a ∈ V := by
  obtain ⟨φ, rfl⟩ := Quotient.exists_rep a
  let MU := ultrafilterToSet U
  let G_seed : Set Formula := { ψ | ψ.all_future ∈ MU }
  let seed : Set Formula := G_seed ∪ {φ}

  have h_G_neg_phi_not_in_MU : φ.neg.all_future ∉ MU := by
    have h_not_in : STSA.G (toQuot φ)ᶜ ∉ U := by
      have h := U.mem_iff_compl_not_mem ((STSA.G (toQuot φ)ᶜ)ᶜ) |>.mp h_F
      simp only [compl_compl] at h
      exact h
    have h_eq : STSA.G (toQuot φ)ᶜ = toQuot φ.neg.all_future := rfl
    rw [h_eq] at h_not_in
    exact h_not_in

  have h_G_top_eq_top : STSA.G (⊤ : LindenbaumAlg) = ⊤ := by
    apply le_antisymm
    · exact le_top
    · show top_quot ≤ G_quot top_quot
      unfold top_quot G_quot
      show Derives (Formula.bot.imp Formula.bot) (Formula.bot.imp Formula.bot).all_future
      unfold Derives
      let T := Formula.bot.imp Formula.bot
      have h_T : [] ⊢ T := Bimodal.Theorems.Combinators.identity Formula.bot
      have h_GT : [] ⊢ T.all_future := DerivationTree.temporal_necessitation T h_T
      have h_s : [] ⊢ T.all_future.imp (T.imp T.all_future) :=
        DerivationTree.axiom [] _ (Axiom.prop_s T.all_future T)
      exact ⟨DerivationTree.modus_ponens [] _ _ h_s h_GT⟩

  have h_G_bot_le_bot : STSA.G (toQuot Formula.bot) ≤ (⊥ : LindenbaumAlg) := by
    show G_quot (toQuot Formula.bot) ≤ bot_quot
    unfold G_quot bot_quot
    show Derives Formula.bot.all_future Formula.bot
    exact ⟨sorry /- G_bot_absurd moved to OpenGuardInvalid archive -/⟩

  have fold_from_x : ∀ (M : List Formula) (x : LindenbaumAlg),
      List.foldl (fun acc χ => acc ⊓ toQuot χ) x M =
      x ⊓ List.foldl (fun acc χ => acc ⊓ toQuot χ) ⊤ M := by
    intro M
    induction M with
    | nil => intro x; simp
    | cons m M' ih_M =>
      intro x
      simp only [List.foldl_cons]
      rw [ih_M (x ⊓ toQuot m), ih_M (⊤ ⊓ toQuot m)]
      simp only [top_inf_eq]
      rw [← inf_assoc]

  have h_seed_cons : SetConsistent seed := by
    intro L hL_in_seed
    intro ⟨d_bot⟩
    by_cases h_phi_in_L : φ ∈ L
    · have ⟨L_pre, L_post, h_L_eq⟩ := List.append_of_mem h_phi_in_L
      let L_no_phi := L_pre ++ L_post

      have d_neg_phi : DerivationTree L_no_phi φ.neg := by
        have d_rearranged : DerivationTree (φ :: L_no_phi) Formula.bot := by
          apply DerivationTree.weakening L (φ :: L_no_phi) Formula.bot d_bot
          intro ψ hψ
          rw [h_L_eq] at hψ
          simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hψ ⊢
          rcases hψ with h | (h | h)
          · right; exact List.mem_append_left _ h
          · left; exact h
          · right; exact List.mem_append_right _ h
        exact Bimodal.Metalogic.Core.deduction_theorem L_no_phi φ Formula.bot d_rearranged

      let L_filt := L_no_phi.filter (fun ψ => decide (ψ ≠ φ))

      have hL_filt_in_Gseed : ∀ ψ ∈ L_filt, ψ ∈ G_seed := by
        intro ψ hψ_filt
        have hψ_neq_phi : ψ ≠ φ := by
          have := List.mem_filter.mp hψ_filt
          exact of_decide_eq_true this.2
        have hψ_in_L_no_phi : ψ ∈ L_no_phi := (List.mem_filter.mp hψ_filt).1
        have hψ_in_L : ψ ∈ L := by
          rw [h_L_eq]
          simp only [List.mem_append, List.mem_singleton]
          cases List.mem_append.mp hψ_in_L_no_phi with
          | inl h => left; exact h
          | inr h => right; right; exact h
        have hψ_in_seed := hL_in_seed ψ hψ_in_L
        simp only [Set.mem_union] at hψ_in_seed
        rcases hψ_in_seed with h_Gseed | h_eq_phi
        · exact h_Gseed
        · exact absurd h_eq_phi hψ_neq_phi

      have contraction : ∀ (A B : Formula), ⊢ (A.imp (A.imp B)).imp (A.imp B) := fun A B => by
        have k_inst : ⊢ (A.imp (A.imp B)).imp ((A.imp A).imp (A.imp B)) :=
          DerivationTree.axiom [] _ (Axiom.prop_k A A B)
        have id_A : ⊢ A.imp A := Bimodal.Theorems.Combinators.identity A
        have flip_thm : ⊢ ((A.imp (A.imp B)).imp ((A.imp A).imp (A.imp B))).imp
                          ((A.imp A).imp ((A.imp (A.imp B)).imp (A.imp B))) :=
          Bimodal.Theorems.Combinators.theorem_flip
        have step1 : ⊢ (A.imp A).imp ((A.imp (A.imp B)).imp (A.imp B)) :=
          DerivationTree.modus_ponens [] _ _ flip_thm k_inst
        exact DerivationTree.modus_ponens [] _ _ step1 id_A

      have filter_deduction : ∀ (ctx : List Formula) (B : Formula),
          DerivationTree ctx B → DerivationTree (ctx.filter (fun ψ => decide (ψ ≠ φ))) (φ.imp B) := by
        intro ctx B d
        induction ctx generalizing B with
        | nil =>
          simp only [List.filter_nil]
          have weak : ⊢ B.imp (φ.imp B) := DerivationTree.axiom [] _ (Axiom.prop_s B φ)
          exact DerivationTree.modus_ponens [] _ _ weak d
        | cons a rest ih =>
          simp only [List.filter_cons]
          by_cases h_eq : a = φ
          · rw [h_eq]
            simp only [ne_eq, not_true_eq_false, decide_false, ite_false]
            have d_rewritten : DerivationTree (φ :: rest) B := h_eq ▸ d
            have d_deduct : DerivationTree rest (φ.imp B) :=
              Bimodal.Metalogic.Core.deduction_theorem rest φ B d_rewritten
            have ih_applied := ih (φ.imp B) d_deduct
            let ctx := rest.filter (fun ψ => decide (ψ ≠ φ))
            have contr_weak : DerivationTree ctx ((φ.imp (φ.imp B)).imp (φ.imp B)) :=
              DerivationTree.weakening [] ctx _ (contraction φ B) (fun _ h => nomatch h)
            exact DerivationTree.modus_ponens _ _ _ contr_weak ih_applied
          · simp only [decide_eq_true_eq, ne_eq, h_eq, not_false_eq_true, decide_true, ite_true]
            have d_deduct : DerivationTree rest (a.imp B) :=
              Bimodal.Metalogic.Core.deduction_theorem rest a B d
            have ih_applied := ih (a.imp B) d_deduct
            let ctx := rest.filter (fun ψ => decide (ψ ≠ φ))
            have flip_weak : DerivationTree ctx ((φ.imp (a.imp B)).imp (a.imp (φ.imp B))) :=
              DerivationTree.weakening [] ctx _ Bimodal.Theorems.Combinators.theorem_flip
                (fun _ h => nomatch h)
            have flipped : DerivationTree ctx (a.imp (φ.imp B)) :=
              DerivationTree.modus_ponens _ _ _ flip_weak ih_applied
            have flipped_ext : DerivationTree (a :: ctx) (a.imp (φ.imp B)) :=
              DerivationTree.weakening ctx (a :: ctx) _ flipped (fun x hx => List.mem_cons_of_mem a hx)
            exact DerivationTree.modus_ponens _ _ _ flipped_ext (DerivationTree.assumption _ a (.head _))

      have d_imp_neg_phi : DerivationTree L_filt (φ.imp φ.neg) := filter_deduction L_no_phi φ.neg d_neg_phi

      have d_neg_phi_filt : DerivationTree L_filt φ.neg := by
        have contr_weak : DerivationTree L_filt ((φ.imp (φ.imp Formula.bot)).imp (φ.imp Formula.bot)) :=
          DerivationTree.weakening [] L_filt _ (contraction φ Formula.bot) (fun _ h => nomatch h)
        exact DerivationTree.modus_ponens _ _ _ contr_weak d_imp_neg_phi

      have h_fold_le : List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_filt ≤ toQuot φ.neg :=
        fold_le_of_derives L_filt φ.neg d_neg_phi_filt

      have h_all_G_in_U : ∀ ψ ∈ L_filt, toQuot ψ.all_future ∈ U := fun ψ hψ => hL_filt_in_Gseed ψ hψ

      have h_G_fold_in_U : STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_filt) ∈ U := by
        have h_helper : ∀ M : List Formula, (∀ χ ∈ M, toQuot χ.all_future ∈ U) →
            STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ M) ∈ U := by
          intro M
          induction M with
          | nil =>
            intro _
            simp only [List.foldl_nil]
            rw [h_G_top_eq_top]
            exact U.top_mem
          | cons ψ L' ih =>
            intro hM
            simp only [List.foldl_cons]
            have h_G_ψ_in_U : STSA.G (toQuot ψ) ∈ U := hM ψ (by simp)
            have ih_applied : STSA.G (List.foldl (fun acc χ => acc ⊓ toQuot χ) ⊤ L') ∈ U :=
              ih (fun χ hχ => hM χ (List.mem_cons_of_mem ψ hχ))
            have h_top_inf : ⊤ ⊓ toQuot ψ = toQuot ψ := top_inf_eq (toQuot ψ)
            rw [fold_from_x L' (⊤ ⊓ toQuot ψ), h_top_inf]
            exact G_preimage_inf U (toQuot ψ) _ h_G_ψ_in_U ih_applied
        exact h_helper L_filt h_all_G_in_U

      have h_G_mono : STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_filt) ≤
                      STSA.G (toQuot φ.neg) := STSA.G_monotone _ _ h_fold_le
      have h_G_neg_in_U : STSA.G (toQuot φ.neg) ∈ U := U.mem_of_le h_G_fold_in_U h_G_mono

      have h_eq : STSA.G (toQuot φ.neg) = toQuot φ.neg.all_future := rfl
      rw [h_eq] at h_G_neg_in_U
      exact h_G_neg_phi_not_in_MU h_G_neg_in_U

    · have hL_in_Gseed : ∀ ψ ∈ L, ψ ∈ G_seed := by
        intro ψ hψ
        have hψ_in_seed := hL_in_seed ψ hψ
        simp only [Set.mem_union] at hψ_in_seed
        rcases hψ_in_seed with h | h
        · exact h
        · rw [h] at hψ
          exact absurd hψ h_phi_in_L

      have h_fold_le_bot : List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L ≤ toQuot Formula.bot :=
        fold_le_of_derives L Formula.bot d_bot

      have h_G_fold_in_U : STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L) ∈ U := by
        have h_helper : ∀ M : List Formula, (∀ χ ∈ M, χ ∈ G_seed) →
            STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ M) ∈ U := by
          intro M
          induction M with
          | nil =>
            intro _
            simp only [List.foldl_nil]
            rw [h_G_top_eq_top]
            exact U.top_mem
          | cons ψ L' ih =>
            intro hM
            simp only [List.foldl_cons]
            have h_G_ψ_in_U : STSA.G (toQuot ψ) ∈ U := hM ψ (by simp)
            have ih_applied : STSA.G (List.foldl (fun acc χ => acc ⊓ toQuot χ) ⊤ L') ∈ U :=
              ih (fun χ hχ => hM χ (List.mem_cons_of_mem ψ hχ))
            have h_top_inf : ⊤ ⊓ toQuot ψ = toQuot ψ := top_inf_eq (toQuot ψ)
            rw [fold_from_x L' (⊤ ⊓ toQuot ψ), h_top_inf]
            exact G_preimage_inf U (toQuot ψ) _ h_G_ψ_in_U ih_applied
        exact h_helper L hL_in_Gseed

      have h_G_mono : STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L) ≤
                      STSA.G (toQuot Formula.bot) := STSA.G_monotone _ _ h_fold_le_bot
      have h_G_bot_in_U : STSA.G (toQuot Formula.bot) ∈ U := U.mem_of_le h_G_fold_in_U h_G_mono

      have h_bot_in_U : (⊥ : LindenbaumAlg) ∈ U := U.mem_of_le h_G_bot_in_U h_G_bot_le_bot
      exact U.bot_not_mem h_bot_in_U

  obtain ⟨M, h_seed_sub_M, h_M_mcs⟩ := set_lindenbaum seed h_seed_cons

  let V := mcsToUltrafilter ⟨M, h_M_mcs⟩

  use V
  constructor
  · intro b h_Gb_in_U
    obtain ⟨ψ, rfl⟩ := Quotient.exists_rep b
    have h_ψ_in_Gseed : ψ ∈ G_seed := h_Gb_in_U
    have h_ψ_in_M : ψ ∈ M := h_seed_sub_M (Set.mem_union_left _ h_ψ_in_Gseed)
    exact mem_mcsToSet h_ψ_in_M

  · have h_φ_in_seed : φ ∈ seed := Set.mem_union_right _ (Set.mem_singleton φ)
    have h_φ_in_M : φ ∈ M := h_seed_sub_M h_φ_in_seed
    exact mem_mcsToSet h_φ_in_M

/--
The symmetric theorem for past: P(a) ∈ U implies existence of predecessor ultrafilter containing a.
-/
theorem ultrafilter_P_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_P : (STSA.H aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_H U V ∧ a ∈ V := by
  obtain ⟨φ, rfl⟩ := Quotient.exists_rep a

  let MU := ultrafilterToSet U
  let H_seed : Set Formula := { ψ | ψ.all_past ∈ MU }
  let seed : Set Formula := H_seed ∪ {φ}

  have h_H_neg_phi_not_in_MU : φ.neg.all_past ∉ MU := by
    have h_not_in : STSA.H (toQuot φ)ᶜ ∉ U := by
      have h := U.mem_iff_compl_not_mem ((STSA.H (toQuot φ)ᶜ)ᶜ) |>.mp h_P
      simp only [compl_compl] at h
      exact h
    have h_eq : STSA.H (toQuot φ)ᶜ = toQuot φ.neg.all_past := rfl
    rw [h_eq] at h_not_in
    exact h_not_in

  have h_H_top_eq_top : STSA.H (⊤ : LindenbaumAlg) = ⊤ := by
    apply le_antisymm
    · exact le_top
    · show top_quot ≤ H_quot top_quot
      unfold top_quot H_quot
      show Derives (Formula.bot.imp Formula.bot) (Formula.bot.imp Formula.bot).all_past
      unfold Derives
      let T := Formula.bot.imp Formula.bot
      have h_T : [] ⊢ T := Bimodal.Theorems.Combinators.identity Formula.bot
      have h_HT : [] ⊢ T.all_past := Bimodal.Theorems.past_necessitation T h_T
      have h_s : [] ⊢ T.all_past.imp (T.imp T.all_past) :=
        DerivationTree.axiom [] _ (Axiom.prop_s T.all_past T)
      exact ⟨DerivationTree.modus_ponens [] _ _ h_s h_HT⟩

  have h_H_bot_le_bot : STSA.H (toQuot Formula.bot) ≤ (⊥ : LindenbaumAlg) := by
    show H_quot (toQuot Formula.bot) ≤ bot_quot
    unfold H_quot bot_quot
    show Derives Formula.bot.all_past Formula.bot
    exact ⟨sorry /- H_bot_absurd moved to OpenGuardInvalid archive -/⟩

  have fold_from_x : ∀ (M : List Formula) (x : LindenbaumAlg),
      List.foldl (fun acc χ => acc ⊓ toQuot χ) x M =
      x ⊓ List.foldl (fun acc χ => acc ⊓ toQuot χ) ⊤ M := by
    intro M
    induction M with
    | nil => intro x; simp
    | cons m M' ih_M =>
      intro x
      simp only [List.foldl_cons]
      rw [ih_M (x ⊓ toQuot m), ih_M (⊤ ⊓ toQuot m)]
      simp only [top_inf_eq]
      rw [← inf_assoc]

  have h_seed_cons : SetConsistent seed := by
    intro L hL_in_seed
    intro ⟨d_bot⟩
    by_cases h_phi_in_L : φ ∈ L
    · have ⟨L_pre, L_post, h_L_eq⟩ := List.append_of_mem h_phi_in_L
      let L_no_phi := L_pre ++ L_post

      have d_neg_phi : DerivationTree L_no_phi φ.neg := by
        have d_rearranged : DerivationTree (φ :: L_no_phi) Formula.bot := by
          apply DerivationTree.weakening L (φ :: L_no_phi) Formula.bot d_bot
          intro ψ hψ
          rw [h_L_eq] at hψ
          simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hψ ⊢
          rcases hψ with h | (h | h)
          · right; exact List.mem_append_left _ h
          · left; exact h
          · right; exact List.mem_append_right _ h
        exact Bimodal.Metalogic.Core.deduction_theorem L_no_phi φ Formula.bot d_rearranged

      let L_filt := L_no_phi.filter (fun ψ => decide (ψ ≠ φ))

      have hL_filt_in_Hseed : ∀ ψ ∈ L_filt, ψ ∈ H_seed := by
        intro ψ hψ_filt
        have hψ_neq_phi : ψ ≠ φ := by
          have := List.mem_filter.mp hψ_filt
          exact of_decide_eq_true this.2
        have hψ_in_L_no_phi : ψ ∈ L_no_phi := (List.mem_filter.mp hψ_filt).1
        have hψ_in_L : ψ ∈ L := by
          rw [h_L_eq]
          simp only [List.mem_append, List.mem_singleton]
          cases List.mem_append.mp hψ_in_L_no_phi with
          | inl h => left; exact h
          | inr h => right; right; exact h
        have hψ_in_seed := hL_in_seed ψ hψ_in_L
        simp only [Set.mem_union] at hψ_in_seed
        rcases hψ_in_seed with h_Hseed | h_eq_phi
        · exact h_Hseed
        · exact absurd h_eq_phi hψ_neq_phi

      have contraction : ∀ (A B : Formula), ⊢ (A.imp (A.imp B)).imp (A.imp B) := fun A B => by
        have k_inst : ⊢ (A.imp (A.imp B)).imp ((A.imp A).imp (A.imp B)) :=
          DerivationTree.axiom [] _ (Axiom.prop_k A A B)
        have id_A : ⊢ A.imp A := Bimodal.Theorems.Combinators.identity A
        have flip_thm : ⊢ ((A.imp (A.imp B)).imp ((A.imp A).imp (A.imp B))).imp
                          ((A.imp A).imp ((A.imp (A.imp B)).imp (A.imp B))) :=
          Bimodal.Theorems.Combinators.theorem_flip
        have step1 : ⊢ (A.imp A).imp ((A.imp (A.imp B)).imp (A.imp B)) :=
          DerivationTree.modus_ponens [] _ _ flip_thm k_inst
        exact DerivationTree.modus_ponens [] _ _ step1 id_A

      have filter_deduction : ∀ (ctx : List Formula) (B : Formula),
          DerivationTree ctx B → DerivationTree (ctx.filter (fun ψ => decide (ψ ≠ φ))) (φ.imp B) := by
        intro ctx B d
        induction ctx generalizing B with
        | nil =>
          simp only [List.filter_nil]
          have weak : ⊢ B.imp (φ.imp B) := DerivationTree.axiom [] _ (Axiom.prop_s B φ)
          exact DerivationTree.modus_ponens [] _ _ weak d
        | cons a rest ih =>
          simp only [List.filter_cons]
          by_cases h_eq : a = φ
          · rw [h_eq]
            simp only [ne_eq, not_true_eq_false, decide_false, ite_false]
            have d_rewritten : DerivationTree (φ :: rest) B := h_eq ▸ d
            have d_deduct : DerivationTree rest (φ.imp B) :=
              Bimodal.Metalogic.Core.deduction_theorem rest φ B d_rewritten
            have ih_applied := ih (φ.imp B) d_deduct
            let ctx := rest.filter (fun ψ => decide (ψ ≠ φ))
            have contr_weak : DerivationTree ctx ((φ.imp (φ.imp B)).imp (φ.imp B)) :=
              DerivationTree.weakening [] ctx _ (contraction φ B) (fun _ h => nomatch h)
            exact DerivationTree.modus_ponens _ _ _ contr_weak ih_applied
          · simp only [decide_eq_true_eq, ne_eq, h_eq, not_false_eq_true, decide_true, ite_true]
            have d_deduct : DerivationTree rest (a.imp B) :=
              Bimodal.Metalogic.Core.deduction_theorem rest a B d
            have ih_applied := ih (a.imp B) d_deduct
            let ctx := rest.filter (fun ψ => decide (ψ ≠ φ))
            have flip_weak : DerivationTree ctx ((φ.imp (a.imp B)).imp (a.imp (φ.imp B))) :=
              DerivationTree.weakening [] ctx _ Bimodal.Theorems.Combinators.theorem_flip
                (fun _ h => nomatch h)
            have flipped : DerivationTree ctx (a.imp (φ.imp B)) :=
              DerivationTree.modus_ponens _ _ _ flip_weak ih_applied
            have flipped_ext : DerivationTree (a :: ctx) (a.imp (φ.imp B)) :=
              DerivationTree.weakening ctx (a :: ctx) _ flipped (fun x hx => List.mem_cons_of_mem a hx)
            exact DerivationTree.modus_ponens _ _ _ flipped_ext (DerivationTree.assumption _ a (.head _))

      have d_imp_neg_phi : DerivationTree L_filt (φ.imp φ.neg) := filter_deduction L_no_phi φ.neg d_neg_phi

      have d_neg_phi_filt : DerivationTree L_filt φ.neg := by
        have contr_weak : DerivationTree L_filt ((φ.imp (φ.imp Formula.bot)).imp (φ.imp Formula.bot)) :=
          DerivationTree.weakening [] L_filt _ (contraction φ Formula.bot) (fun _ h => nomatch h)
        exact DerivationTree.modus_ponens _ _ _ contr_weak d_imp_neg_phi

      have h_fold_le : List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_filt ≤ toQuot φ.neg :=
        fold_le_of_derives L_filt φ.neg d_neg_phi_filt

      have h_all_H_in_U : ∀ ψ ∈ L_filt, toQuot ψ.all_past ∈ U := fun ψ hψ => hL_filt_in_Hseed ψ hψ

      have h_H_fold_in_U : STSA.H (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_filt) ∈ U := by
        have h_helper : ∀ M : List Formula, (∀ χ ∈ M, toQuot χ.all_past ∈ U) →
            STSA.H (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ M) ∈ U := by
          intro M
          induction M with
          | nil =>
            intro _
            simp only [List.foldl_nil]
            rw [h_H_top_eq_top]
            exact U.top_mem
          | cons ψ L' ih =>
            intro hM
            simp only [List.foldl_cons]
            have h_H_ψ_in_U : STSA.H (toQuot ψ) ∈ U := hM ψ (by simp)
            have ih_applied : STSA.H (List.foldl (fun acc χ => acc ⊓ toQuot χ) ⊤ L') ∈ U :=
              ih (fun χ hχ => hM χ (List.mem_cons_of_mem ψ hχ))
            have h_top_inf : ⊤ ⊓ toQuot ψ = toQuot ψ := top_inf_eq (toQuot ψ)
            rw [fold_from_x L' (⊤ ⊓ toQuot ψ), h_top_inf]
            exact H_preimage_inf U (toQuot ψ) _ h_H_ψ_in_U ih_applied
        exact h_helper L_filt h_all_H_in_U

      have h_H_mono : STSA.H (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_filt) ≤
                      STSA.H (toQuot φ.neg) := STSA.H_monotone _ _ h_fold_le
      have h_H_neg_in_U : STSA.H (toQuot φ.neg) ∈ U := U.mem_of_le h_H_fold_in_U h_H_mono

      have h_eq : STSA.H (toQuot φ.neg) = toQuot φ.neg.all_past := rfl
      rw [h_eq] at h_H_neg_in_U
      exact h_H_neg_phi_not_in_MU h_H_neg_in_U

    · have hL_in_Hseed : ∀ ψ ∈ L, ψ ∈ H_seed := by
        intro ψ hψ
        have hψ_in_seed := hL_in_seed ψ hψ
        rcases hψ_in_seed with h | h
        · exact h
        · rw [h] at hψ
          exact absurd hψ h_phi_in_L

      have h_fold_le_bot : List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L ≤ toQuot Formula.bot :=
        fold_le_of_derives L Formula.bot d_bot

      have h_H_fold_in_U : STSA.H (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L) ∈ U := by
        have h_helper : ∀ M : List Formula, (∀ χ ∈ M, χ ∈ H_seed) →
            STSA.H (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ M) ∈ U := by
          intro M
          induction M with
          | nil =>
            intro _
            simp only [List.foldl_nil]
            rw [h_H_top_eq_top]
            exact U.top_mem
          | cons ψ L' ih =>
            intro hM
            simp only [List.foldl_cons]
            have h_H_ψ_in_U : STSA.H (toQuot ψ) ∈ U := hM ψ (by simp)
            have ih_applied : STSA.H (List.foldl (fun acc χ => acc ⊓ toQuot χ) ⊤ L') ∈ U :=
              ih (fun χ hχ => hM χ (List.mem_cons_of_mem ψ hχ))
            have h_top_inf : ⊤ ⊓ toQuot ψ = toQuot ψ := top_inf_eq (toQuot ψ)
            rw [fold_from_x L' (⊤ ⊓ toQuot ψ), h_top_inf]
            exact H_preimage_inf U (toQuot ψ) _ h_H_ψ_in_U ih_applied
        exact h_helper L hL_in_Hseed

      have h_H_mono : STSA.H (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L) ≤
                      STSA.H (toQuot Formula.bot) := STSA.H_monotone _ _ h_fold_le_bot
      have h_H_bot_in_U : STSA.H (toQuot Formula.bot) ∈ U := U.mem_of_le h_H_fold_in_U h_H_mono

      have h_bot_in_U : (⊥ : LindenbaumAlg) ∈ U := U.mem_of_le h_H_bot_in_U h_H_bot_le_bot
      exact U.bot_not_mem h_bot_in_U

  obtain ⟨M, h_seed_sub_M, h_M_mcs⟩ := set_lindenbaum seed h_seed_cons

  let V := mcsToUltrafilter ⟨M, h_M_mcs⟩

  use V
  constructor
  · intro b h_Hb_in_U
    obtain ⟨ψ, rfl⟩ := Quotient.exists_rep b
    have h_ψ_in_Hseed : ψ ∈ H_seed := h_Hb_in_U
    have h_ψ_in_M : ψ ∈ M := h_seed_sub_M (Set.mem_union_left _ h_ψ_in_Hseed)
    exact mem_mcsToSet h_ψ_in_M

  · have h_φ_in_seed : φ ∈ seed := Set.mem_union_right _ (Set.mem_singleton φ)
    have h_φ_in_M : φ ∈ M := h_seed_sub_M h_φ_in_seed
    exact mem_mcsToSet h_φ_in_M

/-!
## UltrafilterChain Structure

An UltrafilterChain is an Int-indexed chain of ultrafilters with R_G connectivity.
This is the ultrafilter-based analogue of FMCS (Family of Maximal Consistent Sets).
-/

/--
An UltrafilterChain is an Int-indexed chain of ultrafilters with R_G connectivity.

The chain must satisfy:
- R_G(chain t, chain (t + 1)) for all t (forward temporal connectivity)
- R_H(chain t, chain (t - 1)) for all t (backward temporal connectivity, follows from forward)
-/
structure UltrafilterChain where
  /-- The Int-indexed family of ultrafilters -/
  chain : Int → Ultrafilter LindenbaumAlg
  /-- Forward R_G connectivity: chain(t) R_G chain(t+1) -/
  R_G_connected : ∀ t : Int, R_G (chain t) (chain (t + 1))

namespace UltrafilterChain

/--
Backward R_H connectivity follows from forward R_G connectivity.
-/
theorem R_H_connected (uc : UltrafilterChain) (t : Int) :
    R_H (uc.chain t) (uc.chain (t - 1)) := by
  have h_R_G : R_G (uc.chain (t - 1)) (uc.chain ((t - 1) + 1)) := uc.R_G_connected (t - 1)
  simp at h_R_G
  exact R_G_R_H_converse.mp h_R_G

/--
Access the ultrafilter at time t.
-/
def at_time (uc : UltrafilterChain) (t : Int) : Ultrafilter LindenbaumAlg :=
  uc.chain t

/--
R_G transitivity along the chain: for any n > 0, chain(t) R_G chain(t + n).
Under strict semantics, n = 0 is excluded (R_G is not reflexive).
-/
theorem R_G_forward (uc : UltrafilterChain) (t : Int) (n : ℕ) (hn : n > 0) :
    R_G (uc.chain t) (uc.chain (t + n)) := by
  induction n with
  | zero => omega
  | succ n ih =>
    by_cases hn0 : n = 0
    · subst hn0
      simp
      exact uc.R_G_connected t
    · have h_step : R_G (uc.chain (t + n)) (uc.chain ((t + n) + 1)) :=
        uc.R_G_connected (t + n)
      have h_eq : (t + ↑n + 1 : Int) = t + ↑(n + 1) := by omega
      rw [h_eq] at h_step
      exact R_G_trans (ih (by omega)) h_step

/--
R_H transitivity along the chain: for any n > 0, chain(t) R_H chain(t - n).
Under strict semantics, n = 0 is excluded (R_H is not reflexive).
-/
theorem R_H_backward (uc : UltrafilterChain) (t : Int) (n : ℕ) (hn : n > 0) :
    R_H (uc.chain t) (uc.chain (t - n)) := by
  induction n with
  | zero => omega
  | succ n ih =>
    by_cases hn0 : n = 0
    · subst hn0
      simp
      exact uc.R_H_connected t
    · have h_step : R_H (uc.chain (t - n)) (uc.chain ((t - n) - 1)) :=
        uc.R_H_connected (t - n)
      have h_eq : (t - ↑n - 1 : Int) = t - ↑(n + 1) := by omega
      rw [h_eq] at h_step
      exact R_H_trans (ih (by omega)) h_step

/--
Shift an ultrafilter chain by offset k.
The shifted chain places the original chain(0) at position k.
-/
def shift (uc : UltrafilterChain) (k : Int) : UltrafilterChain where
  chain := fun t => uc.chain (t - k)
  R_G_connected := fun t => by
    have h := uc.R_G_connected (t - k)
    simp at h ⊢
    convert h using 2
    omega

/--
The shifted chain at the offset equals the original chain at 0.
-/
theorem shift_at_offset (uc : UltrafilterChain) (k : Int) :
    (uc.shift k).chain k = uc.chain 0 := by
  unfold shift
  simp

/--
G-formulas propagate forward along the chain (strict semantics).
If G(a) ∈ chain(t), then a ∈ chain(t') for all t' > t.

Uses R_G connectivity and temp_4 for G-persistence.
Under irreflexive semantics, G quantifies over strictly future times,
so t = t' is excluded.
-/
theorem forward_G (uc : UltrafilterChain) (t t' : Int) (h_lt : t < t')
    (a : LindenbaumAlg) (h_G : STSA.G a ∈ uc.chain t) :
    a ∈ uc.chain t' := by
  have h_G_step : ∀ s : Int, STSA.G a ∈ uc.chain s → STSA.G a ∈ uc.chain (s + 1) := by
    intro s h_Gs
    have h_G_le : STSA.G a ≤ STSA.G (STSA.G a) := by
      induction a using Quotient.ind with
      | _ φ =>
        show G_quot (toQuot φ) ≤ G_quot (G_quot (toQuot φ))
        show Derives φ.all_future φ.all_future.all_future
        exact ⟨sorry /- temp_4: Gφ → GGφ, derivable from BX1+K but removed during axiom cleanup -/⟩
    have h_GG : STSA.G (STSA.G a) ∈ uc.chain s :=
      (uc.chain s).mem_of_le h_Gs h_G_le
    exact uc.R_G_connected s (STSA.G a) h_GG
  have h_G_persists : ∀ k : ℕ, STSA.G a ∈ uc.chain (t + k) := by
    intro k
    induction k with
    | zero =>
      have h_eq : (t + (0 : ℕ) : Int) = t := by simp
      rw [h_eq]
      exact h_G
    | succ m ih =>
      have h_eq : (t + ↑(m + 1) : Int) = t + ↑m + 1 := by omega
      rw [h_eq]
      exact h_G_step (t + m) ih
  obtain ⟨n, hn⟩ := Int.eq_ofNat_of_zero_le (by omega : t' - t - 1 ≥ 0)
  have h_t'_eq : t' = t + ↑n + 1 := by omega
  rw [h_t'_eq]
  exact uc.R_G_connected (t + n) a (h_G_persists n)

/--
H-formulas propagate backward along the chain (strict semantics).
If H(a) ∈ chain(t), then a ∈ chain(t') for all t' < t.

Under irreflexive semantics, H quantifies over strictly past times,
so t = t' is excluded.
-/
theorem backward_H (uc : UltrafilterChain) (t t' : Int) (h_lt : t' < t)
    (a : LindenbaumAlg) (h_H : STSA.H a ∈ uc.chain t) :
    a ∈ uc.chain t' := by
  have h_H_step : ∀ s : Int, STSA.H a ∈ uc.chain s → STSA.H a ∈ uc.chain (s - 1) := by
    intro s h_Hs
    have h_H_le : STSA.H a ≤ STSA.H (STSA.H a) := by
      induction a using Quotient.ind with
      | _ φ =>
        show H_quot (toQuot φ) ≤ H_quot (H_quot (toQuot φ))
        show Derives φ.all_past φ.all_past.all_past
        exact ⟨temp_4_past φ⟩
    have h_HH : STSA.H (STSA.H a) ∈ uc.chain s :=
      (uc.chain s).mem_of_le h_Hs h_H_le
    exact uc.R_H_connected s (STSA.H a) h_HH
  have h_H_persists : ∀ k : ℕ, STSA.H a ∈ uc.chain (t - k) := by
    intro k
    induction k with
    | zero =>
      have h_eq : (t - (0 : ℕ) : Int) = t := by simp
      rw [h_eq]
      exact h_H
    | succ m ih =>
      have h_eq : (t - ↑(m + 1) : Int) = t - ↑m - 1 := by omega
      rw [h_eq]
      exact h_H_step (t - m) ih
  obtain ⟨n, hn⟩ := Int.eq_ofNat_of_zero_le (by omega : t - t' - 1 ≥ 0)
  have h_t'_eq : t' = t - ↑n - 1 := by omega
  rw [h_t'_eq]
  exact uc.R_H_connected (t - ↑n) a (h_H_persists n)

end UltrafilterChain

/-!
## UltrafilterChain to FMCS Conversion

Convert an UltrafilterChain to an FMCS Int, enabling integration with
the existing parametric truth lemma infrastructure.
-/

/--
Convert an UltrafilterChain to an FMCS Int.

The MCS at each time point is obtained via `ultrafilter_to_mcs`,
and temporal coherence follows from `UltrafilterChain.forward_G`
and `UltrafilterChain.backward_H`.
-/
noncomputable def UltrafilterChain_to_FMCS (uc : UltrafilterChain) : FMCS Int where
  mcs := fun t => (ultrafilter_to_mcs (uc.chain t)).val
  is_mcs := fun t => (ultrafilter_to_mcs (uc.chain t)).property
  forward_G := fun t t' φ h_le h_G => by
    unfold ultrafilter_to_mcs ultrafilterToSet at h_G ⊢
    simp only [Set.mem_setOf_eq] at h_G ⊢
    exact uc.forward_G t t' h_le (toQuot φ) h_G
  backward_H := fun t t' φ h_le h_H => by
    unfold ultrafilter_to_mcs ultrafilterToSet at h_H ⊢
    simp only [Set.mem_setOf_eq] at h_H ⊢
    exact uc.backward_H t t' h_le (toQuot φ) h_H

/--
Bridge lemma: formula membership in ultrafilter_to_mcs corresponds to
quotient membership in the ultrafilter.
-/
theorem mem_UltrafilterChain_FMCS_iff (uc : UltrafilterChain) (t : Int) (φ : Formula) :
    φ ∈ (UltrafilterChain_to_FMCS uc).mcs t ↔ toQuot φ ∈ uc.chain t := by
  unfold UltrafilterChain_to_FMCS ultrafilter_to_mcs ultrafilterToSet
  simp only [Set.mem_setOf_eq]

end Bimodal.Metalogic.Algebraic.UltrafilterFrame
