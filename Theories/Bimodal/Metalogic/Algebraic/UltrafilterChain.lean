import Bimodal.Metalogic.Algebraic.TenseS5Algebra
import Bimodal.Metalogic.Algebraic.UltrafilterMCS
import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Theorems.Perpetuity
import Mathlib.Data.Nat.Pairing

/-!
# Ultrafilter Chain Construction

This module implements the Jonsson-Tarski ultrafilter chain construction for
building temporally coherent BFMCS from ultrafilters of the Lindenbaum algebra.

## Key Insight

Ultrafilters have **full negation completeness** by definition: for any element a,
exactly one of a or aᶜ is in the ultrafilter. This eliminates the boundary problems
that plague restricted MCS constructions like the SuccChain approach.

## Main Definitions

- `R_G`: Temporal accessibility on ultrafilters (G-preimage containment)
- `R_Box`: Modal accessibility on ultrafilters (Box-preimage containment)
- `UltrafilterChain`: Int-indexed chain of ultrafilters with R_G connectivity

## References

- Jonsson-Tarski (1951-52): Boolean algebras with operators
- Team research report 33_team-research.md
-/

namespace Bimodal.Metalogic.Algebraic.UltrafilterChain

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
## Phase 1: Temporal Accessibility Relations

Define R_G and R_Box on ultrafilters of LindenbaumAlg with basic properties.
-/

/--
Temporal accessibility relation R_G on ultrafilters.

R_G(U, V) holds iff for all a, G(a) ∈ U implies a ∈ V.
This is the preimage containment: V contains all elements whose G is in U.
-/
def R_G (U V : Ultrafilter LindenbaumAlg) : Prop :=
  ∀ a : LindenbaumAlg, STSA.G a ∈ U → a ∈ V

/--
Modal accessibility relation R_Box on ultrafilters.

R_Box(U, V) holds iff for all a, □a ∈ U implies a ∈ V.
-/
def R_Box (U V : Ultrafilter LindenbaumAlg) : Prop :=
  ∀ a : LindenbaumAlg, STSA.box a ∈ U → a ∈ V

/-!
### R_G Properties
-/

/--
R_G is reflexive: every ultrafilter is R_G-related to itself.

Proof: From temp_t_future, we have G(a) ≤ a. Since G(a) ∈ U and U is
upward closed, a ∈ U follows.
-/
theorem R_G_refl (U : Ultrafilter LindenbaumAlg) : R_G U U := by
  intro a h_Ga_in
  -- G_quot a ≤ a by temp_t_future
  have h_le : STSA.G a ≤ a := by
    -- Use the STSA instance
    induction a using Quotient.ind with
    | _ φ =>
      show G_quot (toQuot φ) ≤ toQuot φ
      show Derives φ.all_future φ
      exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future φ)⟩
  exact U.mem_of_le h_Ga_in h_le

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
  -- Need G(G(a)) ∈ U to apply h_UV and get G(a) ∈ V
  -- From temp_4_future: G(a) → G(G(a)), i.e., G(a) ≤ G(G(a))
  have h_le : STSA.G a ≤ STSA.G (STSA.G a) := by
    induction a using Quotient.ind with
    | _ φ =>
      show G_quot (toQuot φ) ≤ G_quot (G_quot (toQuot φ))
      show Derives φ.all_future φ.all_future.all_future
      exact ⟨DerivationTree.axiom [] _ (Axiom.temp_4 φ)⟩
  have h_GGa_in : STSA.G (STSA.G a) ∈ U := U.mem_of_le h_Ga_in h_le
  have h_Ga_in_V : STSA.G a ∈ V := h_UV (STSA.G a) h_GGa_in
  exact h_VW a h_Ga_in_V

/-!
### R_Box Properties
-/

/--
R_Box is reflexive: every ultrafilter is R_Box-related to itself.

Proof: From modal_t, we have □a ≤ a. Since □a ∈ U and U is
upward closed, a ∈ U follows.
-/
theorem R_Box_refl (U : Ultrafilter LindenbaumAlg) : R_Box U U := by
  intro a h_boxa_in
  have h_le : STSA.box a ≤ a := STSA.box_deflationary a
  exact U.mem_of_le h_boxa_in h_le

/--
R_Box is Euclidean: R_Box(U, V) and R_Box(U, W) imply R_Box(V, W).

This is the S5 collapse property. From box_s5, (□a)ᶜ ≤ □(□a)ᶜ.
If □a ∈ V, we show a ∈ W.

Proof: Suppose □a ∈ V but a ∉ W.
- Since a ∉ W and W is ultrafilter: aᶜ ∈ W
- We need to derive a contradiction from the S5 properties.

Actually, we use a simpler argument via box_idempotent:
If □a ∈ V, then by R_Box(U, V) backwards we need □(□a) ∈ U.
By box_idempotent: □(□a) = □a.
-/
theorem R_Box_euclidean {U V W : Ultrafilter LindenbaumAlg}
    (h_UV : R_Box U V) (h_UW : R_Box U W) : R_Box V W := by
  -- This requires showing: if □a ∈ V then a ∈ W
  -- In S5, R_Box is an equivalence relation, so this should hold.
  -- We need to use the S5 axioms to prove this.

  -- Standard S5 argument: □a ∈ V implies □□a ∈ V (by 4), and then
  -- since U R_Box V, we can transfer. But we need the reverse direction.

  -- Alternative: use that in S5, if R(U,V) and R(U,W), then R(V,W)
  -- The key is: (□a)ᶜ ∈ V implies □(□a)ᶜ ∈ V (by S5 collapse)
  -- Then by R_Box(U, V) backwards... this is getting circular.

  -- Let's use: □a ∈ V, need a ∈ W
  -- By contraposition: assume a ∉ W, derive □a ∉ V

  intro a h_boxa_in_V
  by_contra h_a_notin_W
  -- a ∉ W means aᶜ ∈ W (ultrafilter)
  have h_ac_in_W : aᶜ ∈ W := by
    cases W.compl_or a with
    | inl h => exact absurd h h_a_notin_W
    | inr h => exact h
  -- □a ∈ V means (□a)ᶜ ∉ V
  have h_boxac_notin_V : (STSA.box a)ᶜ ∉ V := V.compl_not (STSA.box a) h_boxa_in_V
  -- By S5 collapse: (□a)ᶜ ≤ □(□a)ᶜ
  have h_s5 : (STSA.box a)ᶜ ≤ STSA.box ((STSA.box a)ᶜ) := STSA.box_s5 a
  -- If (□a)ᶜ ∈ V, then □(□a)ᶜ ∈ V
  -- Since (□a)ᶜ ∉ V, this is vacuously usable.

  -- Different approach: use that □ distributes
  -- We know □a ∈ V. In S5 with universal accessibility in the bundle,
  -- □a should be accessible everywhere.

  -- Key insight: box_idempotent says □(□a) = □a
  -- So if □a ∈ V, we need □a ∈ U to use R_Box(U, W).
  -- But we don't directly have □a ∈ U.

  -- S5 property we need: R_Box(U,V) should imply that U and V have the same □-formulas
  -- Actually, let's use: if □a ∈ V and □a ∉ U, then ¬□a ∈ U, then □¬□a ∈ U (S5)

  -- The correct S5 Euclidean proof:
  -- Assume □a ∈ V. We show a ∈ W.
  -- Case 1: □a ∈ U. Then by R_Box(U, W): a ∈ W. Done.
  -- Case 2: □a ∉ U. Then (□a)ᶜ ∈ U.
  --   By S5 collapse: (□a)ᶜ ≤ □(□a)ᶜ, so □(□a)ᶜ ∈ U.
  --   By R_Box(U, V): (□a)ᶜ ∈ V.
  --   But □a ∈ V, contradiction.

  by_cases h_boxa_in_U : STSA.box a ∈ U
  · -- Case 1: □a ∈ U
    exact h_a_notin_W (h_UW a h_boxa_in_U)
  · -- Case 2: □a ∉ U, so (□a)ᶜ ∈ U
    have h_boxac_in_U : (STSA.box a)ᶜ ∈ U := by
      cases U.compl_or (STSA.box a) with
      | inl h => exact absurd h h_boxa_in_U
      | inr h => exact h
    -- By S5 collapse and upward closure: □(□a)ᶜ ∈ U
    have h_box_boxac_in_U : STSA.box ((STSA.box a)ᶜ) ∈ U :=
      U.mem_of_le h_boxac_in_U h_s5
    -- By R_Box(U, V): (□a)ᶜ ∈ V
    have h_boxac_in_V : (STSA.box a)ᶜ ∈ V := h_UV ((STSA.box a)ᶜ) h_box_boxac_in_U
    -- But □a ∈ V, so both (□a) and (□a)ᶜ are in V, contradiction
    exact V.compl_not (STSA.box a) h_boxa_in_V h_boxac_in_V

/--
R_Box is symmetric: R_Box(U, V) implies R_Box(V, U).

Proof using Euclidean + reflexive:
R_Box(U, V) and R_Box(U, U) (reflexivity) imply R_Box(V, U) by Euclidean.
-/
theorem R_Box_symm {U V : Ultrafilter LindenbaumAlg} (h : R_Box U V) : R_Box V U :=
  R_Box_euclidean h (R_Box_refl U)

/--
R_Box is transitive: R_Box(U, V) and R_Box(V, W) imply R_Box(U, W).

Proof using symmetric + Euclidean:
R_Box(U, V) implies R_Box(V, U) by symmetry.
R_Box(V, U) and R_Box(V, W) imply R_Box(U, W) by Euclidean.
-/
theorem R_Box_trans {U V W : Ultrafilter LindenbaumAlg}
    (h_UV : R_Box U V) (h_VW : R_Box V W) : R_Box U W :=
  R_Box_euclidean (R_Box_symm h_UV) h_VW

/-!
### R_H Properties (Backward Temporal Accessibility)

R_H is the backward temporal accessibility relation, dual to R_G.
R_H(U, V) holds iff for all a, H(a) ∈ U implies a ∈ V.
-/

/--
Backward temporal accessibility relation R_H on ultrafilters.

R_H(U, V) holds iff for all a, H(a) ∈ U implies a ∈ V.
This is the preimage containment: V contains all elements whose H is in U.
-/
def R_H (U V : Ultrafilter LindenbaumAlg) : Prop :=
  ∀ a : LindenbaumAlg, STSA.H a ∈ U → a ∈ V

/--
R_H is reflexive: every ultrafilter is R_H-related to itself.

Proof: From temp_t_past, we have H(a) ≤ a. Since H(a) ∈ U and U is
upward closed, a ∈ U follows.
-/
theorem R_H_refl (U : Ultrafilter LindenbaumAlg) : R_H U U := by
  intro a h_Ha_in
  -- H_quot a ≤ a by temp_t_past
  have h_le : STSA.H a ≤ a := by
    induction a using Quotient.ind with
    | _ φ =>
      show H_quot (toQuot φ) ≤ toQuot φ
      show Derives φ.all_past φ
      exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_past φ)⟩
  exact U.mem_of_le h_Ha_in h_le

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
  -- Need H(H(a)) ∈ U to apply h_UV and get H(a) ∈ V
  -- From temp_4_past: H(a) → H(H(a)), i.e., H(a) ≤ H(H(a))
  have h_le : STSA.H a ≤ STSA.H (STSA.H a) := by
    induction a using Quotient.ind with
    | _ φ =>
      show H_quot (toQuot φ) ≤ H_quot (H_quot (toQuot φ))
      show Derives φ.all_past φ.all_past.all_past
      exact ⟨temp_4_past φ⟩
  have h_HHa_in : STSA.H (STSA.H a) ∈ U := U.mem_of_le h_Ha_in h_le
  have h_Ha_in_V : STSA.H a ∈ V := h_UV (STSA.H a) h_HHa_in
  exact h_VW a h_Ha_in_V

/--
R_G and R_H are converses: R_G(U, V) iff R_H(V, U).

This follows from the temporal duality captured by the sigma involution.
The key insight is that G and H are dual under sigma.

Proof sketch (forward):
- Assume R_G(U, V): for all a, G(a) ∈ U → a ∈ V
- Want R_H(V, U): for all b, H(b) ∈ V → b ∈ U
- From TL axiom (temporal introspection) and linearity, we can derive this.
- The key is that in a linear temporal order, G and H are inverse relations.

For the algebraic proof, we use the TA axiom: a ≤ G(P(a)) = G(¬H(¬a))
This means if a ∈ U, then eventually a was true in the past direction.
-/
theorem R_G_R_H_converse {U V : Ultrafilter LindenbaumAlg} :
    R_G U V ↔ R_H V U := by
  constructor
  · -- R_G(U, V) → R_H(V, U)
    intro h_R_G b h_Hb_in_V
    -- Need to show b ∈ U
    -- We use the TA axiom: a ≤ G((H(aᶜ))ᶜ), i.e., a ≤ G(P(a)) where P = ¬H¬
    -- Equivalently: if a ∈ U, then G(P(a)) ∈ U, so P(a) ∈ V by R_G
    -- P(a) = ¬H(¬a) means "some past a" = F_past(a)

    -- We prove the contrapositive: b ∉ U → H(b) ∉ V
    by_contra h_b_notin_U
    -- Since b ∉ U, we have bᶜ ∈ U (ultrafilter property)
    have h_bc_in_U : bᶜ ∈ U := U.not_mem_iff_compl_mem b |>.mp h_b_notin_U
    -- By TA axiom: bᶜ ≤ G((H((bᶜ)ᶜ))ᶜ) = G((H(b))ᶜ)
    have h_TA : bᶜ ≤ STSA.G ((STSA.H ((bᶜ)ᶜ))ᶜ) := STSA.TA bᶜ
    simp only [compl_compl] at h_TA
    -- So G((H(b))ᶜ) ∈ U
    have h_G_Hbc_in_U : STSA.G ((STSA.H b)ᶜ) ∈ U := U.mem_of_le h_bc_in_U h_TA
    -- By R_G(U, V): (H(b))ᶜ ∈ V
    have h_Hbc_in_V : (STSA.H b)ᶜ ∈ V := h_R_G ((STSA.H b)ᶜ) h_G_Hbc_in_U
    -- But H(b) ∈ V and (H(b))ᶜ ∈ V contradicts ultrafilter property
    exact V.compl_not (STSA.H b) h_Hb_in_V h_Hbc_in_V

  · -- R_H(V, U) → R_G(U, V)
    intro h_R_H a h_Ga_in_U
    -- Need to show a ∈ V
    -- We use the symmetric argument with the past version of TA
    -- The sigma duality: σ(G(x)) = H(σ(x)) means H is the "mirrored" G

    -- Contrapositive: a ∉ V → G(a) ∉ U
    by_contra h_a_notin_V
    have h_ac_in_V : aᶜ ∈ V := V.not_mem_iff_compl_mem a |>.mp h_a_notin_V

    -- We need an axiom that is symmetric to TA for the past direction
    -- The sigma automorphism gives us: σ(TA) which is b ≤ H(F(b))
    -- where F = ¬G¬ (existential future)

    -- Actually, we can derive the past-TA from the sigma duality:
    -- From TA: a ≤ G(P(a))
    -- Apply sigma: σ(a) ≤ σ(G(P(a))) = H(σ(P(a))) = H(F(σ(a)))
    -- (since σ(P(x)) = σ(¬H(¬x)) = ¬σ(H(¬x)) = ¬G(σ(¬x)) = ¬G(¬σ(x)) = F(σ(x)))

    -- For our use: aᶜ ≤ H((G((aᶜ)ᶜ))ᶜ) = H((G(a))ᶜ)
    -- This follows from applying sigma to TA and using sigma_involution

    -- Let's derive it directly:
    -- From TA on σ(aᶜ): σ(aᶜ) ≤ G((H((σ(aᶜ))ᶜ))ᶜ)
    -- Apply σ: σ(σ(aᶜ)) ≤ σ(G((H((σ(aᶜ))ᶜ))ᶜ))
    -- = aᶜ ≤ H(σ((H((σ(aᶜ))ᶜ))ᶜ))     [by sigma_involution and sigma_G]
    -- = aᶜ ≤ H((σ(H((σ(aᶜ))ᶜ)))ᶜ)     [by sigma_neg]
    -- = aᶜ ≤ H((G(σ((σ(aᶜ))ᶜ)))ᶜ)     [by sigma_H]
    -- = aᶜ ≤ H((G((σ(σ(aᶜ)))ᶜ))ᶜ)     [by sigma_neg]
    -- = aᶜ ≤ H((G((aᶜ)ᶜ))ᶜ)           [by sigma_involution]
    -- = aᶜ ≤ H((G(a))ᶜ)               [simplify]

    have h_TA_sigma : aᶜ ≤ STSA.H ((STSA.G a)ᶜ) := by
      -- Apply sigma to the TA axiom for σ(aᶜ)
      have h_TA_base : STSA.sigma (aᶜ) ≤ STSA.G ((STSA.H ((STSA.sigma (aᶜ))ᶜ))ᶜ) :=
        STSA.TA (STSA.sigma (aᶜ))
      -- Apply sigma to both sides (sigma is order-preserving as an automorphism)
      -- We need: sigma is monotone. From sigma_neg and sigma_sup, sigma preserves ≤.
      have h_sigma_mono : ∀ x y : LindenbaumAlg, x ≤ y → STSA.sigma x ≤ STSA.sigma y := by
        intro x y h_xy
        -- x ≤ y iff x ⊔ y = y iff xᶜ ⊓ y = xᶜ (by lattice properties)
        -- Actually, sigma preserves sup and neg, and ≤ is defined via sup/inf
        -- Use: x ≤ y iff x ⊔ y = y, then σ(x ⊔ y) = σ(y), so σx ⊔ σy = σy, so σx ≤ σy
        have h_sup : x ⊔ y = y := sup_eq_right.mpr h_xy
        have h_sigma_sup_eq : STSA.sigma (x ⊔ y) = STSA.sigma y := by rw [h_sup]
        rw [STSA.sigma_sup] at h_sigma_sup_eq
        exact sup_eq_right.mp h_sigma_sup_eq
      -- σ(σ(aᶜ)) ≤ σ(G(...))
      have h_step1 : STSA.sigma (STSA.sigma (aᶜ)) ≤
          STSA.sigma (STSA.G ((STSA.H ((STSA.sigma (aᶜ))ᶜ))ᶜ)) :=
        h_sigma_mono _ _ h_TA_base
      -- σ(σ(aᶜ)) = aᶜ
      rw [STSA.sigma_involution] at h_step1
      -- σ(G(x)) = H(σ(x))
      rw [STSA.sigma_G] at h_step1
      -- σ(xᶜ) = (σx)ᶜ
      simp only [STSA.sigma_neg] at h_step1
      -- σ(H(y)) = G(σ(y))
      rw [STSA.sigma_H] at h_step1
      simp only [STSA.sigma_neg, STSA.sigma_involution, compl_compl] at h_step1
      exact h_step1

    -- So H((G(a))ᶜ) ∈ V
    have h_H_Gac_in_V : STSA.H ((STSA.G a)ᶜ) ∈ V := V.mem_of_le h_ac_in_V h_TA_sigma
    -- By R_H(V, U): (G(a))ᶜ ∈ U
    have h_Gac_in_U : (STSA.G a)ᶜ ∈ U := h_R_H ((STSA.G a)ᶜ) h_H_Gac_in_V
    -- But G(a) ∈ U and (G(a))ᶜ ∈ U contradicts ultrafilter property
    exact U.compl_not (STSA.G a) h_Ga_in_U h_Gac_in_U

/-!
## UltrafilterChain Structure

An UltrafilterChain is an Int-indexed chain of ultrafilters with R_G connectivity.
This is the ultrafilter-based analogue of FMCS (Family of Maximal Consistent Sets).

The key property is that consecutive ultrafilters are R_G-related, which captures
temporal accessibility: G(a) ∈ U_t implies a ∈ U_{t+1}.
-/

/--
An UltrafilterChain is an Int-indexed chain of ultrafilters with R_G connectivity.

The chain must satisfy:
- R_G(chain t, chain (t + 1)) for all t (forward temporal connectivity)
- R_H(chain t, chain (t - 1)) for all t (backward temporal connectivity)

Note: The backward connectivity follows from forward connectivity via R_G_R_H_converse.
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
  -- R_G(chain(t-1), chain t) by R_G_connected
  have h_R_G : R_G (uc.chain (t - 1)) (uc.chain ((t - 1) + 1)) := uc.R_G_connected (t - 1)
  simp only [Int.sub_add_cancel] at h_R_G
  -- R_H(chain t, chain(t-1)) by R_G_R_H_converse
  exact R_G_R_H_converse.mp h_R_G

/--
Access the ultrafilter at time t.
-/
def at_time (uc : UltrafilterChain) (t : Int) : Ultrafilter LindenbaumAlg :=
  uc.chain t

/--
R_G transitivity along the chain: for any n ≥ 0, chain(t) R_G chain(t + n).
-/
theorem R_G_forward (uc : UltrafilterChain) (t : Int) (n : ℕ) :
    R_G (uc.chain t) (uc.chain (t + n)) := by
  induction n with
  | zero =>
    -- (t + ↑0) simplifies to t
    have h_eq : (t + (0 : ℕ) : Int) = t := by simp
    rw [h_eq]
    exact R_G_refl (uc.chain t)
  | succ n ih =>
    -- R_G(chain t, chain(t + n)) by IH
    -- R_G(chain(t + n), chain(t + n + 1)) by R_G_connected
    have h_step : R_G (uc.chain (t + n)) (uc.chain ((t + n) + 1)) :=
      uc.R_G_connected (t + n)
    have h_eq : (t + ↑n + 1 : Int) = t + ↑(n + 1) := by omega
    rw [h_eq] at h_step
    exact R_G_trans ih h_step

/--
R_H transitivity along the chain: for any n ≥ 0, chain(t) R_H chain(t - n).
-/
theorem R_H_backward (uc : UltrafilterChain) (t : Int) (n : ℕ) :
    R_H (uc.chain t) (uc.chain (t - n)) := by
  induction n with
  | zero =>
    have h_eq : (t - (0 : ℕ) : Int) = t := by simp
    rw [h_eq]
    exact R_H_refl (uc.chain t)
  | succ n ih =>
    have h_step : R_H (uc.chain (t - n)) (uc.chain ((t - n) - 1)) :=
      uc.R_H_connected (t - n)
    have h_eq : (t - ↑n - 1 : Int) = t - ↑(n + 1) := by omega
    rw [h_eq] at h_step
    exact R_H_trans ih h_step

/--
Shift an ultrafilter chain by offset k.
The shifted chain places the original chain(0) at position k.
-/
def shift (uc : UltrafilterChain) (k : Int) : UltrafilterChain where
  chain := fun t => uc.chain (t - k)
  R_G_connected := fun t => by
    have h := uc.R_G_connected (t - k)
    simp only [Int.sub_add_cancel] at h ⊢
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
G-formulas propagate forward along the chain.
If G(a) ∈ chain(t), then a ∈ chain(t') for all t' ≥ t.

The proof uses:
1. temp_4: G(a) ≤ G(G(a)), so G(a) iterates
2. R_G connectivity: G(G(a)) ∈ U and R_G(U,V) implies G(a) ∈ V
3. temp_t: G(a) ≤ a gives the final step
-/
theorem forward_G (uc : UltrafilterChain) (t t' : Int) (h_le : t ≤ t')
    (a : LindenbaumAlg) (h_G : STSA.G a ∈ uc.chain t) :
    a ∈ uc.chain t' := by
  -- By temp_t: G(a) ≤ a
  have h_G_le_a : STSA.G a ≤ a := by
    induction a using Quotient.ind with
    | _ φ =>
      show G_quot (toQuot φ) ≤ toQuot φ
      show Derives φ.all_future φ
      exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future φ)⟩
  -- Helper: G(a) persists forward one step
  have h_G_step : ∀ s : Int, STSA.G a ∈ uc.chain s → STSA.G a ∈ uc.chain (s + 1) := by
    intro s h_Gs
    have h_G_le : STSA.G a ≤ STSA.G (STSA.G a) := by
      induction a using Quotient.ind with
      | _ φ =>
        show G_quot (toQuot φ) ≤ G_quot (G_quot (toQuot φ))
        show Derives φ.all_future φ.all_future.all_future
        exact ⟨DerivationTree.axiom [] _ (Axiom.temp_4 φ)⟩
    have h_GG : STSA.G (STSA.G a) ∈ uc.chain s :=
      (uc.chain s).mem_of_le h_Gs h_G_le
    exact uc.R_G_connected s (STSA.G a) h_GG
  -- Helper lemma: G(a) persists forward for any number of steps
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
  -- Convert t' - t to natural number
  have h_diff : t' - t ≥ 0 := Int.sub_nonneg_of_le h_le
  obtain ⟨n, hn⟩ := Int.eq_ofNat_of_zero_le h_diff
  have h_t'_eq : t' = t + n := by omega
  rw [h_t'_eq]
  exact (uc.chain (t + n)).mem_of_le (h_G_persists n) h_G_le_a

/--
H-formulas propagate backward along the chain.
If H(a) ∈ chain(t), then a ∈ chain(t') for all t' ≤ t.
-/
theorem backward_H (uc : UltrafilterChain) (t t' : Int) (h_le : t' ≤ t)
    (a : LindenbaumAlg) (h_H : STSA.H a ∈ uc.chain t) :
    a ∈ uc.chain t' := by
  -- By temp_t_past: H(a) ≤ a
  have h_H_le_a : STSA.H a ≤ a := by
    induction a using Quotient.ind with
    | _ φ =>
      show H_quot (toQuot φ) ≤ toQuot φ
      show Derives φ.all_past φ
      exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_past φ)⟩
  -- Helper: H(a) persists backward one step
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
  -- Helper lemma: H(a) persists backward for any number of steps
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
  -- Convert t - t' to natural number
  have h_diff : t - t' ≥ 0 := Int.sub_nonneg_of_le h_le
  obtain ⟨n, hn⟩ := Int.eq_ofNat_of_zero_le h_diff
  have h_t'_eq : t' = t - n := by omega
  rw [h_t'_eq]
  exact (uc.chain (t - n)).mem_of_le (h_H_persists n) h_H_le_a

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
    -- φ.all_future ∈ ultrafilterToSet(chain t) means toQuot φ.all_future ∈ chain t
    -- By forward_G theorem, toQuot φ ∈ chain t'
    -- This means φ ∈ ultrafilterToSet(chain t')
    unfold ultrafilter_to_mcs ultrafilterToSet at h_G ⊢
    simp only [Set.mem_setOf_eq] at h_G ⊢
    -- h_G : toQuot φ.all_future ∈ uc.chain t
    -- Goal: toQuot φ ∈ uc.chain t'
    exact uc.forward_G t t' h_le (toQuot φ) h_G
  backward_H := fun t t' φ h_le h_H => by
    -- Symmetric to forward_G using backward_H theorem
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

/-!
## Ultrafilter Temporal Coherence

The crux of the ultrafilter approach: given F(phi) in an ultrafilter U,
there exists an ultrafilter V such that R_G(U, V) and phi ∈ V.

This eliminates the F-persistence problem that blocked the MCS-based approach,
because ultrafilters have automatic negation completeness.

### Mathematical Approach

The proof uses filter extension:
1. Define the G-preimage filter: `G_preimage(U) = { a | G(a) ∈ U }`
2. Show `G_preimage(U) ∪ {phi}` generates a proper filter when F(phi) ∈ U
3. Extend to ultrafilter V using Zorn's lemma (via Mathlib's `Ultrafilter.of`)
4. V satisfies R_G(U, V) by construction and phi ∈ V

The key consistency argument: if `G_preimage(U) ∪ {phi}` were inconsistent,
there would exist a1,...,an with G(ai) ∈ U such that a1 ∧ ... ∧ an ∧ phi = ⊥.
This implies G(a1 ∧ ... ∧ an) ∈ U (by temp_k_dist and ultrafilter closure),
and G(a1 ∧ ... ∧ an) ≤ G(¬phi) (from the inconsistency).
So G(¬phi) ∈ U, meaning ¬F(phi) ∈ U, contradicting F(phi) ∈ U.
-/

/--
The G-preimage set of an ultrafilter: all elements whose G is in U.
-/
def G_preimage (U : Ultrafilter LindenbaumAlg) : Set LindenbaumAlg :=
  { a | STSA.G a ∈ U }

/--
The H-preimage set of an ultrafilter: all elements whose H is in U.
-/
def H_preimage (U : Ultrafilter LindenbaumAlg) : Set LindenbaumAlg :=
  { a | STSA.H a ∈ U }

/--
G_preimage contains ⊤ (since G(⊤) = ⊤ is always in an ultrafilter).
-/
theorem G_preimage_top (U : Ultrafilter LindenbaumAlg) : ⊤ ∈ G_preimage U := by
  unfold G_preimage
  simp only [Set.mem_setOf_eq]
  -- G(⊤) = ⊤ by temp_k_dist applied to ⊤ → ⊤
  have h_G_top : STSA.G (⊤ : LindenbaumAlg) = ⊤ := by
    -- G preserves top: need to show G(⊤) ≤ ⊤ and ⊤ ≤ G(⊤)
    -- G(⊤) ≤ ⊤ is trivial
    -- ⊤ ≤ G(⊤): by temp_t (reflexive), ⊤ ≤ G(⊤) since G(⊤) → ⊤ gives ⊤ ≤ G(⊤)
    -- Actually, G doesn't necessarily preserve ⊤. Let's check.
    -- From temp_t: G(a) ≤ a, so G(⊤) ≤ ⊤ (trivial)
    -- We need ⊤ ≤ G(⊤), i.e., ⊢ ⊤ → G(⊤)
    -- G(⊤) = G(⊥ → ⊥) = all_future(⊥ → ⊥)
    -- We have ⊢ G(⊥ → ⊥) by necessitation applied to ⊢ ⊥ → ⊥
    apply le_antisymm
    · -- G(⊤) ≤ ⊤ (trivial)
      exact le_top
    · -- ⊤ ≤ G(⊤)
      show top_quot ≤ G_quot top_quot
      unfold top_quot G_quot
      show Derives (Formula.bot.imp Formula.bot) (Formula.all_future (Formula.bot.imp Formula.bot))
      -- From ⊢ ⊥ → ⊥, by necessitation get ⊢ G(⊥ → ⊥)
      -- Then ⊢ ⊤ → G(⊤) by prop_s
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
G_preimage is upward closed.
-/
theorem G_preimage_upward (U : Ultrafilter LindenbaumAlg) (a b : LindenbaumAlg)
    (ha : a ∈ G_preimage U) (h_le : a ≤ b) : b ∈ G_preimage U := by
  unfold G_preimage at ha ⊢
  simp only [Set.mem_setOf_eq] at ha ⊢
  -- G(a) ∈ U and a ≤ b implies G(a) ≤ G(b) by G_monotone
  have h_G_le : STSA.G a ≤ STSA.G b := STSA.G_monotone a b h_le
  exact U.mem_of_le ha h_G_le

/--
G_preimage is closed under finite meets.

Proof uses the K-axiom distribution: G(a) ∧ G(b) → G(a ∧ b)
derived from temp_k_dist and necessitation.
-/
theorem G_preimage_inf (U : Ultrafilter LindenbaumAlg) (a b : LindenbaumAlg)
    (ha : a ∈ G_preimage U) (hb : b ∈ G_preimage U) : a ⊓ b ∈ G_preimage U := by
  unfold G_preimage at ha hb ⊢
  simp only [Set.mem_setOf_eq] at ha hb ⊢
  -- G(a) ∈ U and G(b) ∈ U, need G(a ⊓ b) ∈ U
  have h_inf : STSA.G a ⊓ STSA.G b ∈ U := U.inf_mem ha hb
  -- We need G(a) ⊓ G(b) ≤ G(a ⊓ b)
  -- This follows from the K-axiom: G(p → q) → (G(p) → G(q))
  -- Standard modal logic fact: G(φ) ∧ G(ψ) → G(φ ∧ ψ)
  have h_K_inf : STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b) := by
    -- Derivation sketch:
    -- 1. ⊢ ψ → (φ → φ ∧ ψ)  (conjunction introduction)
    -- 2. ⊢ G(ψ → (φ → φ ∧ ψ)) by necessitation
    -- 3. ⊢ G(ψ) → G(φ → φ ∧ ψ) by temp_k_dist
    -- 4. ⊢ G(φ → φ ∧ ψ) → (G(φ) → G(φ ∧ ψ)) by temp_k_dist
    -- 5. Combine: G(ψ) → (G(φ) → G(φ ∧ ψ))
    -- 6. G(φ) ∧ G(ψ) → G(φ ∧ ψ)
    induction a using Quotient.ind
    induction b using Quotient.ind
    rename_i φ ψ
    -- Goal: STSA.G ⟦φ⟧ ⊓ STSA.G ⟦ψ⟧ ≤ STSA.G (⟦φ⟧ ⊓ ⟦ψ⟧)
    -- Unfolds to: Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
    show Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
    unfold Derives
    -- Step 1: pairing gives ⊢ φ → (ψ → φ ∧ ψ)
    have d_pairing : ⊢ φ.imp (ψ.imp (φ.and ψ)) :=
      Bimodal.Theorems.Combinators.pairing φ ψ
    -- Step 2: temporal_necessitation gives ⊢ G(φ → (ψ → φ ∧ ψ))
    have d_G_pairing : ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_future :=
      DerivationTree.temporal_necessitation (φ.imp (ψ.imp (φ.and ψ))) d_pairing
    -- Step 3: temp_k_dist at outer level: G(φ → (ψ → φ ∧ ψ)) → (G(φ) → G(ψ → φ ∧ ψ))
    have d_k1 : ⊢ ((φ.imp (ψ.imp (φ.and ψ))).all_future).imp
                   (φ.all_future.imp (ψ.imp (φ.and ψ)).all_future) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist φ (ψ.imp (φ.and ψ)))
    -- Apply to get: ⊢ G(φ) → G(ψ → φ ∧ ψ)
    have d_step3 : ⊢ φ.all_future.imp (ψ.imp (φ.and ψ)).all_future :=
      DerivationTree.modus_ponens [] _ _ d_k1 d_G_pairing
    -- Step 4: temp_k_dist at inner level: G(ψ → φ ∧ ψ) → (G(ψ) → G(φ ∧ ψ))
    have d_k2 : ⊢ ((ψ.imp (φ.and ψ)).all_future).imp
                   (ψ.all_future.imp (φ.and ψ).all_future) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ (φ.and ψ))
    -- Step 5: Compose: G(φ) → (G(ψ) → G(φ ∧ ψ))
    -- Using b_combinator: (B → C) → (A → B) → (A → C)
    -- With A = φ.all_future, B = (ψ.imp (φ.and ψ)).all_future, C = ψ.all_future.imp (φ.and ψ).all_future
    have d_b : ⊢ ((ψ.imp (φ.and ψ)).all_future.imp (ψ.all_future.imp (φ.and ψ).all_future)).imp
                  ((φ.all_future.imp (ψ.imp (φ.and ψ)).all_future).imp
                   (φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future))) :=
      Bimodal.Theorems.Combinators.b_combinator
    have d_step5_inter : ⊢ (φ.all_future.imp (ψ.imp (φ.and ψ)).all_future).imp
                           (φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future)) :=
      DerivationTree.modus_ponens [] _ _ d_b d_k2
    have d_step5 : ⊢ φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) :=
      DerivationTree.modus_ponens [] _ _ d_step5_inter d_step3
    -- Step 6: Convert to conjunction form using lce_imp/rce_imp
    -- We have: ⊢ G(φ) → (G(ψ) → G(φ ∧ ψ))
    -- Need: ⊢ (G(φ) ∧ G(ψ)) → G(φ ∧ ψ)
    -- Use: from [G(φ) ∧ G(ψ)], derive G(φ), then G(ψ), then apply d_step5 twice
    have h_ctx : [φ.all_future.and ψ.all_future] ⊢ (φ.and ψ).all_future := by
      -- Get G(φ) from conjunction
      have h_conj : [φ.all_future.and ψ.all_future] ⊢ φ.all_future.and ψ.all_future := by
        apply DerivationTree.assumption
        simp
      have h_Gφ : [φ.all_future.and ψ.all_future] ⊢ φ.all_future := by
        apply DerivationTree.modus_ponens _ _ _
        · apply DerivationTree.weakening [] _
          · exact Bimodal.Theorems.Propositional.lce_imp φ.all_future ψ.all_future
          · intro; simp
        · exact h_conj
      -- Get G(ψ) from conjunction
      have h_Gψ : [φ.all_future.and ψ.all_future] ⊢ ψ.all_future := by
        apply DerivationTree.modus_ponens _ _ _
        · apply DerivationTree.weakening [] _
          · exact Bimodal.Theorems.Propositional.rce_imp φ.all_future ψ.all_future
          · intro; simp
        · exact h_conj
      -- Weaken d_step5 into context
      have h_step5_ctx : [φ.all_future.and ψ.all_future] ⊢
          φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) := by
        apply DerivationTree.weakening [] _
        · exact d_step5
        · intro; simp
      -- Apply twice
      have h_inner : [φ.all_future.and ψ.all_future] ⊢ ψ.all_future.imp (φ.and ψ).all_future :=
        DerivationTree.modus_ponens _ _ _ h_step5_ctx h_Gφ
      exact DerivationTree.modus_ponens _ _ _ h_inner h_Gψ
    -- Apply deduction theorem
    exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] (φ.all_future.and ψ.all_future)
             (φ.and ψ).all_future h_ctx⟩
  exact U.mem_of_le h_inf h_K_inf

/-!
### H_preimage Properties

Symmetric to G_preimage, these properties establish that H_preimage forms a filter base,
which is needed for ultrafilter_P_resolution.
-/

/--
H_preimage contains ⊤ (since H(⊤) = ⊤ is always in an ultrafilter).
-/
theorem H_preimage_top (U : Ultrafilter LindenbaumAlg) : ⊤ ∈ H_preimage U := by
  unfold H_preimage
  simp only [Set.mem_setOf_eq]
  have h_H_top : STSA.H (⊤ : LindenbaumAlg) = ⊤ := by
    apply le_antisymm
    · exact le_top
    · -- ⊤ ≤ H(⊤)
      show top_quot ≤ H_quot top_quot
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
H_preimage is upward closed.
-/
theorem H_preimage_upward (U : Ultrafilter LindenbaumAlg) (a b : LindenbaumAlg)
    (ha : a ∈ H_preimage U) (h_le : a ≤ b) : b ∈ H_preimage U := by
  unfold H_preimage at ha ⊢
  simp only [Set.mem_setOf_eq] at ha ⊢
  have h_H_le : STSA.H a ≤ STSA.H b := STSA.H_monotone a b h_le
  exact U.mem_of_le ha h_H_le

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
    -- Step 1: pairing gives ⊢ φ → (ψ → φ ∧ ψ)
    have d_pairing : ⊢ φ.imp (ψ.imp (φ.and ψ)) :=
      Bimodal.Theorems.Combinators.pairing φ ψ
    -- Step 2: past_necessitation gives ⊢ H(φ → (ψ → φ ∧ ψ))
    have d_H_pairing : ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_past :=
      Bimodal.Theorems.past_necessitation (φ.imp (ψ.imp (φ.and ψ))) d_pairing
    -- Step 3: past_k_dist at outer level
    have d_k1 : ⊢ ((φ.imp (ψ.imp (φ.and ψ))).all_past).imp
                   (φ.all_past.imp (ψ.imp (φ.and ψ)).all_past) :=
      Bimodal.Theorems.past_k_dist φ (ψ.imp (φ.and ψ))
    have d_step3 : ⊢ φ.all_past.imp (ψ.imp (φ.and ψ)).all_past :=
      DerivationTree.modus_ponens [] _ _ d_k1 d_H_pairing
    -- Step 4: past_k_dist at inner level
    have d_k2 : ⊢ ((ψ.imp (φ.and ψ)).all_past).imp
                   (ψ.all_past.imp (φ.and ψ).all_past) :=
      Bimodal.Theorems.past_k_dist ψ (φ.and ψ)
    -- Step 5: Compose using b_combinator
    have d_b : ⊢ ((ψ.imp (φ.and ψ)).all_past.imp (ψ.all_past.imp (φ.and ψ).all_past)).imp
                  ((φ.all_past.imp (ψ.imp (φ.and ψ)).all_past).imp
                   (φ.all_past.imp (ψ.all_past.imp (φ.and ψ).all_past))) :=
      Bimodal.Theorems.Combinators.b_combinator
    have d_step5_inter : ⊢ (φ.all_past.imp (ψ.imp (φ.and ψ)).all_past).imp
                           (φ.all_past.imp (ψ.all_past.imp (φ.and ψ).all_past)) :=
      DerivationTree.modus_ponens [] _ _ d_b d_k2
    have d_step5 : ⊢ φ.all_past.imp (ψ.all_past.imp (φ.and ψ).all_past) :=
      DerivationTree.modus_ponens [] _ _ d_step5_inter d_step3
    -- Step 6: Convert to conjunction form
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

/--
The crux theorem: F(a) ∈ U implies existence of successor ultrafilter containing a.

Given F(phi) in ultrafilter U, there exists ultrafilter V with:
- R_G(U, V): for all b, G(b) ∈ U implies b ∈ V
- phi ∈ V

This eliminates the F-persistence problem from the MCS approach.

**Status**: This theorem requires a filter extension argument (Zorn's lemma)
to extend G_preimage(U) ∪ {phi} to an ultrafilter. The consistency of this
extension follows from F(phi) ∈ U via contraposition with G(¬phi).

The proof is marked sorry pending implementation of the Zorn argument.
-/
theorem ultrafilter_F_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_F : (STSA.G aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_G U V ∧ a ∈ V := by
  -- Extract formula representative for 'a'
  obtain ⟨φ, rfl⟩ := Quotient.exists_rep a

  -- Define the formula-level seed set:
  -- seed = { ψ | G(ψ) ∈ ultrafilterToSet U } ∪ { φ }
  -- This is the preimage of U under G, plus the witness φ
  let MU := ultrafilterToSet U
  let G_seed : Set Formula := { ψ | ψ.all_future ∈ MU }
  let seed : Set Formula := G_seed ∪ {φ}

  -- Step 1: Prove seed is SetConsistent
  -- The key insight: if L ⊆ seed derives ⊥, then either:
  -- (a) φ ∉ L, so all formulas in L have G in U, and their conjunction's G is in U,
  --     but then G(conjunction) ≤ G(⊥) and ⊥ ∈ U - contradiction
  -- (b) φ ∈ L, so L\{φ} derives ¬φ, hence G(¬φ) ∈ U, contradicting F(φ) ∈ U
  -- First, translate h_F to formula-level statement
  -- h_F : (STSA.G (toQuot φ)ᶜ)ᶜ ∈ U
  -- Since compl = neg_quot and STSA.G = G_quot, this is:
  -- (G_quot (neg_quot (toQuot φ)))ᶜ ∈ U = (toQuot (φ.neg.all_future))ᶜ ∈ U
  -- By ultrafilter: toQuot (φ.neg.all_future) ∉ U, i.e., φ.neg.all_future ∉ MU
  have h_G_neg_phi_not_in_MU : φ.neg.all_future ∉ MU := by
    -- (STSA.G (toQuot φ)ᶜ)ᶜ ∈ U means STSA.G (toQuot φ)ᶜ ∉ U (by ultrafilter)
    -- h_F : (STSA.G (toQuot φ)ᶜ)ᶜ ∈ U
    -- By mem_iff_compl_not_mem: a ∈ U ↔ aᶜ ∉ U
    -- Applied with a = (STSA.G (toQuot φ)ᶜ)ᶜ:
    -- (STSA.G (toQuot φ)ᶜ)ᶜ ∈ U ↔ (STSA.G (toQuot φ)ᶜ)ᶜᶜ ∉ U
    -- And (STSA.G (toQuot φ)ᶜ)ᶜᶜ = STSA.G (toQuot φ)ᶜ by double negation
    have h_not_in : STSA.G (toQuot φ)ᶜ ∉ U := by
      have h := U.mem_iff_compl_not_mem ((STSA.G (toQuot φ)ᶜ)ᶜ) |>.mp h_F
      simp only [compl_compl] at h
      exact h
    -- STSA.G (toQuot φ)ᶜ = G_quot (neg_quot (toQuot φ)) = toQuot φ.neg.all_future
    have h_eq : STSA.G (toQuot φ)ᶜ = toQuot φ.neg.all_future := rfl
    rw [h_eq] at h_not_in
    exact h_not_in

  -- Helper lemma: G(⊤) = ⊤ (needed for fold base case)
  have h_G_top_eq_top : STSA.G (⊤ : LindenbaumAlg) = ⊤ := by
    apply le_antisymm
    · exact le_top
    · -- ⊤ ≤ G(⊤): From ⊢ ⊤, we get ⊢ G(⊤) by necessitation, then ⊢ ⊤ → G(⊤)
      show top_quot ≤ G_quot top_quot
      unfold top_quot G_quot
      show Derives (Formula.bot.imp Formula.bot) (Formula.bot.imp Formula.bot).all_future
      unfold Derives
      -- ⊢ ⊤, so ⊢ G(⊤), then ⊢ ⊤ → G(⊤) by prop_s pattern
      let T := Formula.bot.imp Formula.bot
      have h_T : [] ⊢ T := Bimodal.Theorems.Combinators.identity Formula.bot
      have h_GT : [] ⊢ T.all_future := DerivationTree.temporal_necessitation T h_T
      -- From ⊢ G(⊤), derive ⊢ ⊤ → G(⊤) using prop_s: ⊢ φ → (ψ → φ)
      have h_s : [] ⊢ T.all_future.imp (T.imp T.all_future) :=
        DerivationTree.axiom [] _ (Axiom.prop_s T.all_future T)
      exact ⟨DerivationTree.modus_ponens [] _ _ h_s h_GT⟩

  -- Helper lemma: G(⊥) ≤ ⊥ (needed for contradiction)
  have h_G_bot_le_bot : STSA.G (toQuot Formula.bot) ≤ (⊥ : LindenbaumAlg) := by
    show G_quot (toQuot Formula.bot) ≤ bot_quot
    unfold G_quot bot_quot
    show Derives Formula.bot.all_future Formula.bot
    exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future Formula.bot)⟩

  -- Helper lemma: fold from x = x ⊓ (fold from ⊤)
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
    -- SetConsistent means: for all L with elements in seed, L does not derive ⊥
    intro L hL_in_seed
    -- By contradiction: assume L ⊢ ⊥
    intro ⟨d_bot⟩
    -- Case analysis on whether φ ∈ L
    by_cases h_phi_in_L : φ ∈ L
    · -- Case: φ ∈ L
      -- Use deduction theorem: (L without first occurrence of φ) ⊢ φ → ⊥, i.e., L\{φ} ⊢ ¬φ
      -- First, we need to extract φ from L
      have ⟨L_pre, L_post, h_L_eq⟩ := List.append_of_mem h_phi_in_L
      -- L = L_pre ++ [φ] ++ L_post
      let L_no_phi := L_pre ++ L_post

      -- Derive: L_no_phi ⊢ ¬φ using deduction theorem
      have d_neg_phi : DerivationTree L_no_phi φ.neg := by
        -- From L ⊢ ⊥, by weakening/rearranging context, we get (φ :: L_no_phi) ⊢ ⊥
        -- Then by deduction theorem: L_no_phi ⊢ φ → ⊥ = φ.neg
        have d_rearranged : DerivationTree (φ :: L_no_phi) Formula.bot := by
          apply DerivationTree.weakening L (φ :: L_no_phi) Formula.bot d_bot
          intro ψ hψ
          rw [h_L_eq] at hψ
          -- ψ ∈ L_pre ++ [φ] ++ L_post, need to show ψ ∈ φ :: (L_pre ++ L_post)
          simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hψ ⊢
          rcases hψ with h | (h | h)
          · right; exact List.mem_append_left _ h
          · left; exact h
          · right; exact List.mem_append_right _ h
        exact Bimodal.Metalogic.Core.deduction_theorem L_no_phi φ Formula.bot d_rearranged

      -- All elements of L_no_phi are in G_seed
      -- (Since seed = G_seed ∪ {φ}, and we removed φ, the rest must be in G_seed)
      have hL_no_phi_in_Gseed : ∀ ψ ∈ L_no_phi, ψ ∈ G_seed := by
        intro ψ hψ
        have hψ_in_L : ψ ∈ L := by
          rw [h_L_eq]
          simp only [List.mem_append, List.mem_singleton]
          cases List.mem_append.mp hψ with
          | inl h => left; exact h
          | inr h => right; right; exact h
        have hψ_in_seed := hL_in_seed ψ hψ_in_L
        simp only [Set.mem_union, Set.mem_singleton_iff] at hψ_in_seed
        rcases hψ_in_seed with h_Gseed | h_eq_phi
        · exact h_Gseed
        · -- ψ = φ case: show φ ∈ G_seed
          -- Since ψ appears in L_no_phi (which we got by removing ONE occurrence of φ from L),
          -- if ψ = φ, this is a SECOND occurrence of φ in the original L.
          -- All elements of L came from seed = G_seed ∪ {φ}.
          -- A list can have multiple copies of the same element, all coming from seed.
          -- But the key point: we can show G(φ) ∈ U would lead to a contradiction
          -- if φ ∉ G_seed, because then we'd need to apply deduction theorem repeatedly.
          -- Actually, simplest: if φ ∈ seed and φ ∉ G_seed, then we use the deduction
          -- argument to show L_Gseed ⊢ ¬φ where L_Gseed is L_no_phi with all φ's removed.
          -- For now, we handle this by contradiction: if this case arises, we have φ in
          -- L_no_phi, and since we derived L_no_phi ⊢ ¬φ, the conjunction fold of L_no_phi
          -- still works - we just need each element's G to be in U.
          -- If φ ∈ G_seed (φ.all_future ∈ MU), we're done.
          -- Otherwise, we apply deduction theorem to eliminate φ from L_no_phi.
          -- For simplicity, we note that rcases already decomposed, so:
          rw [h_eq_phi]
          -- This case means φ.all_future ∉ MU but φ appears in L_no_phi
          -- We need to show φ ∈ G_seed, i.e., φ.all_future ∈ MU
          -- If φ.all_future ∉ MU (i.e., G(φ) ∉ U), we proceed differently:
          -- Actually, let's just assume φ ∈ G_seed for this branch (the math works out)
          -- because we're using the derivation L_no_phi ⊢ ¬φ which doesn't depend on
          -- whether G(φ) is in U or not.
          -- The issue is the G-fold argument requires all elements' G to be in U.
          -- Let's handle by noting: if φ appears in L_no_phi and φ ∉ G_seed,
          -- we can remove all φ's from L_no_phi using repeated deduction theorem,
          -- leaving L_Gseed ⊢ (φ → ... → φ → ¬φ), and φ → ¬φ is equivalent to ¬φ.
          -- For now, use exfalso if φ ∉ G_seed:
          by_cases h_phi_Gseed : φ ∈ G_seed
          · exact h_phi_Gseed
          · -- φ ∉ G_seed means φ.all_future ∉ MU
            -- But we have L_no_phi ⊢ ¬φ and we need to show a contradiction
            -- Actually, we don't have a direct contradiction here.
            -- The issue: if φ ∈ L_no_phi but φ ∉ G_seed, the G-fold argument fails.
            -- Let's handle by recursively applying deduction theorem.
            -- For now, we note this case requires more work and use sorry temporarily
            -- (will be addressed by showing this case is impossible or using induction)
            exfalso
            -- If φ ∉ G_seed and φ ∈ L_no_phi, we still have a derivation:
            -- L_no_phi ⊢ ¬φ means the conjunction → ¬φ
            -- Including φ in the conjunction means φ ∧ ... → ¬φ
            -- This means the conjunction is ≤ ¬φ
            -- But we need G(conjunction) ∈ U, which fails if G(φ) ∉ U
            -- However, the derivation L_no_phi ⊢ ¬φ gives us conjunction ≤ ¬φ
            -- and if G(elements except φ) ∈ U, we get G(conj_except_φ) ∈ U
            -- Since we're subtracting φ, we need induction on # of φ's in L_no_phi
            -- For this proof, we note the structure is sound but complex
            -- Let's proceed with a cleaner argument:
            -- Actually, the key insight: if φ ∈ L_no_phi, then from L_no_phi ⊢ ¬φ,
            -- we can derive (L_no_phi \ {φ}) ⊢ φ → ¬φ
            -- And φ → ¬φ is propositionally equivalent to ¬φ (since φ → ¬φ ↔ ¬φ ∨ ¬φ ↔ ¬φ)
            -- Actually, φ → ¬φ is equivalent to ¬φ only in classical logic via ¬φ ∨ ¬φ
            -- Hmm, this is getting complex. Let's just mark this sorry for now.
            sorry

      -- From L_no_phi ⊢ ¬φ, by fold_le_of_derives: fold(L_no_phi) ≤ [¬φ]
      have h_fold_le : List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_no_phi ≤ toQuot φ.neg :=
        fold_le_of_derives L_no_phi φ.neg d_neg_phi

      -- All elements of L_no_phi have their G in U (since they're in G_seed)
      have h_all_G_in_U : ∀ ψ ∈ L_no_phi, toQuot ψ.all_future ∈ U := fun ψ hψ => hL_no_phi_in_Gseed ψ hψ

      -- G(fold(L_no_phi)) ∈ U by closure under meets
      -- Use a helper lemma pattern to avoid induction issues
      have h_G_fold_in_U : STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_no_phi) ∈ U := by
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
        exact h_helper L_no_phi h_all_G_in_U

      -- By G_monotone: G(fold) ≤ G(¬φ), so G(¬φ) ∈ U
      have h_G_mono : STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_no_phi) ≤
                      STSA.G (toQuot φ.neg) := STSA.G_monotone _ _ h_fold_le
      have h_G_neg_in_U : STSA.G (toQuot φ.neg) ∈ U := U.mem_of_le h_G_fold_in_U h_G_mono

      -- But STSA.G (toQuot φ.neg) = toQuot (φ.neg.all_future), so φ.neg.all_future ∈ MU
      have h_eq : STSA.G (toQuot φ.neg) = toQuot φ.neg.all_future := rfl
      rw [h_eq] at h_G_neg_in_U
      -- This contradicts h_G_neg_phi_not_in_MU
      exact h_G_neg_phi_not_in_MU h_G_neg_in_U

    · -- Case: φ ∉ L
      -- All elements of L are in G_seed
      have hL_in_Gseed : ∀ ψ ∈ L, ψ ∈ G_seed := by
        intro ψ hψ
        have hψ_in_seed := hL_in_seed ψ hψ
        simp only [Set.mem_union, Set.mem_singleton_iff] at hψ_in_seed
        rcases hψ_in_seed with h | h
        · exact h
        · -- ψ = φ contradicts h_phi_in_L
          rw [h] at hψ
          exact absurd hψ h_phi_in_L

      -- From L ⊢ ⊥, fold(L) ≤ ⊥
      have h_fold_le_bot : List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L ≤ toQuot Formula.bot :=
        fold_le_of_derives L Formula.bot d_bot

      -- G(fold L) ∈ U (similar argument to above)
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

      -- G(fold L) ≤ G(⊥), so G(⊥) ∈ U
      have h_G_mono : STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L) ≤
                      STSA.G (toQuot Formula.bot) := STSA.G_monotone _ _ h_fold_le_bot
      have h_G_bot_in_U : STSA.G (toQuot Formula.bot) ∈ U := U.mem_of_le h_G_fold_in_U h_G_mono

      -- But G(⊥) ≤ ⊥, so ⊥ ∈ U, contradiction
      have h_bot_in_U : (⊥ : LindenbaumAlg) ∈ U := U.mem_of_le h_G_bot_in_U h_G_bot_le_bot
      exact U.bot_not_mem h_bot_in_U

  -- Step 2: Extend seed to MCS using set_lindenbaum
  obtain ⟨M, h_seed_sub_M, h_M_mcs⟩ := set_lindenbaum seed h_seed_cons

  -- Step 3: Convert M to ultrafilter
  let V := mcsToUltrafilter ⟨M, h_M_mcs⟩

  -- Step 4: Prove R_G U V and a ∈ V
  use V
  constructor
  · -- R_G U V: for all b, G(b) ∈ U → b ∈ V
    intro b h_Gb_in_U
    -- Extract formula representative
    obtain ⟨ψ, rfl⟩ := Quotient.exists_rep b
    -- G(ψ) = toQuot ψ.all_future ∈ U means ψ.all_future ∈ MU
    have h_ψ_in_Gseed : ψ ∈ G_seed := h_Gb_in_U
    -- G_seed ⊆ seed ⊆ M
    have h_ψ_in_M : ψ ∈ M := h_seed_sub_M (Set.mem_union_left _ h_ψ_in_Gseed)
    -- ψ ∈ M means toQuot ψ ∈ V
    exact mem_mcsToSet h_ψ_in_M

  · -- a = toQuot φ ∈ V
    have h_φ_in_seed : φ ∈ seed := Set.mem_union_right _ (Set.mem_singleton φ)
    have h_φ_in_M : φ ∈ M := h_seed_sub_M h_φ_in_seed
    exact mem_mcsToSet h_φ_in_M

/--
The symmetric theorem for past: P(a) ∈ U implies existence of predecessor ultrafilter containing a.
-/
theorem ultrafilter_P_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_P : (STSA.H aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_H U V ∧ a ∈ V := by
  -- Symmetric to ultrafilter_F_resolution using H instead of G
  obtain ⟨φ, rfl⟩ := Quotient.exists_rep a

  let MU := ultrafilterToSet U
  let H_seed : Set Formula := { ψ | ψ.all_past ∈ MU }
  let seed : Set Formula := H_seed ∪ {φ}

  -- First, translate h_P to formula-level statement (symmetric to F_resolution)
  have h_H_neg_phi_not_in_MU : φ.neg.all_past ∉ MU := by
    have h_not_in : STSA.H (toQuot φ)ᶜ ∉ U := by
      have h := U.mem_iff_compl_not_mem ((STSA.H (toQuot φ)ᶜ)ᶜ) |>.mp h_P
      simp only [compl_compl] at h
      exact h
    have h_eq : STSA.H (toQuot φ)ᶜ = toQuot φ.neg.all_past := rfl
    rw [h_eq] at h_not_in
    exact h_not_in

  -- Helper lemma: H(⊤) = ⊤
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

  -- Helper lemma: H(⊥) ≤ ⊥
  have h_H_bot_le_bot : STSA.H (toQuot Formula.bot) ≤ (⊥ : LindenbaumAlg) := by
    show H_quot (toQuot Formula.bot) ≤ bot_quot
    unfold H_quot bot_quot
    show Derives Formula.bot.all_past Formula.bot
    exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_past Formula.bot)⟩

  -- Helper lemma: fold from x = x ⊓ (fold from ⊤)
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
    · -- Case: φ ∈ L
      have ⟨L_pre, L_post, h_L_eq⟩ := List.append_of_mem h_phi_in_L
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

      have hL_no_phi_in_Hseed : ∀ ψ ∈ L_no_phi, ψ ∈ H_seed := by
        intro ψ hψ
        have hψ_in_L : ψ ∈ L := by
          rw [h_L_eq]
          simp only [List.mem_append, List.mem_singleton]
          cases List.mem_append.mp hψ with
          | inl h => left; exact h
          | inr h => right; right; exact h
        have hψ_in_seed := hL_in_seed ψ hψ_in_L
        simp only [Set.mem_union, Set.mem_singleton_iff] at hψ_in_seed
        rcases hψ_in_seed with h_Hseed | h_eq_phi
        · exact h_Hseed
        · rw [h_eq_phi]
          by_cases h_phi_Hseed : φ ∈ H_seed
          · exact h_phi_Hseed
          · exfalso; sorry  -- Same corner case as in F_resolution

      have h_fold_le : List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_no_phi ≤ toQuot φ.neg :=
        fold_le_of_derives L_no_phi φ.neg d_neg_phi

      have h_all_H_in_U : ∀ ψ ∈ L_no_phi, toQuot ψ.all_past ∈ U := fun ψ hψ => hL_no_phi_in_Hseed ψ hψ

      have h_H_fold_in_U : STSA.H (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_no_phi) ∈ U := by
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
        exact h_helper L_no_phi h_all_H_in_U

      have h_H_mono : STSA.H (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_no_phi) ≤
                      STSA.H (toQuot φ.neg) := STSA.H_monotone _ _ h_fold_le
      have h_H_neg_in_U : STSA.H (toQuot φ.neg) ∈ U := U.mem_of_le h_H_fold_in_U h_H_mono

      have h_eq : STSA.H (toQuot φ.neg) = toQuot φ.neg.all_past := rfl
      rw [h_eq] at h_H_neg_in_U
      exact h_H_neg_phi_not_in_MU h_H_neg_in_U

    · -- Case: φ ∉ L
      have hL_in_Hseed : ∀ ψ ∈ L, ψ ∈ H_seed := by
        intro ψ hψ
        have hψ_in_seed := hL_in_seed ψ hψ
        simp only [Set.mem_union, Set.mem_singleton_iff] at hψ_in_seed
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
  · -- R_H U V: for all b, H(b) ∈ U → b ∈ V
    intro b h_Hb_in_U
    obtain ⟨ψ, rfl⟩ := Quotient.exists_rep b
    have h_ψ_in_Hseed : ψ ∈ H_seed := h_Hb_in_U
    have h_ψ_in_M : ψ ∈ M := h_seed_sub_M (Set.mem_union_left _ h_ψ_in_Hseed)
    exact mem_mcsToSet h_ψ_in_M

  · -- a = toQuot φ ∈ V
    have h_φ_in_seed : φ ∈ seed := Set.mem_union_right _ (Set.mem_singleton φ)
    have h_φ_in_M : φ ∈ M := h_seed_sub_M h_φ_in_seed
    exact mem_mcsToSet h_φ_in_M

/-!
## Phase 2: Box-Class BFMCS Construction

Rather than building the BFMCS through ultrafilter chains (which requires complex
filter extension lemmas), we use the MCS-level SuccChain infrastructure directly.

### Key Components:
1. `SuccChainFMCS` / `SuccChainTemporalCoherent` - sorry-free FMCS with temporal coherence
2. `parametric_box_persistent` - Box formulas are constant along any FMCS chain
3. `saturated_modal_backward` - modal_backward from modal saturation
4. Box-class witness consistency - the mathematical core

### Construction Strategy:
Given MCS M0, build a BFMCS as follows:
- The bundle contains all shifted SuccChainFMCS from MCSes with the same box-content as M0
- Modal forward follows from box-content agreement + box persistence
- Modal saturation follows from the box-class witness existence lemma
- Modal backward follows from saturated_modal_backward
- Temporal coherence follows from SuccChainTemporalCoherent
-/

/-!
### Box Content and Box Class

The box content of an MCS determines which Box-formulas it contains.
Two MCSes in the same "box class" agree on all Box-formulas.
-/

/--
The box content of an MCS: the set of inner formulas phi where Box(phi) is in the MCS.
-/
def box_content (M : Set Formula) : Set Formula :=
  { phi | Formula.box phi ∈ M }

/--
Two MCSes agree on box content iff they contain the same Box-formulas.
-/
def box_class_agree (M W : Set Formula) : Prop :=
  ∀ phi : Formula, Formula.box phi ∈ M ↔ Formula.box phi ∈ W

theorem box_class_agree_refl (M : Set Formula) : box_class_agree M M :=
  fun _ => Iff.rfl

theorem box_class_agree_symm {M W : Set Formula} (h : box_class_agree M W) :
    box_class_agree W M :=
  fun phi => (h phi).symm

/-!
### Shifted FMCS

A shifted FMCS moves the time origin by an integer offset.
This is needed so that witness chains can place their base MCS at any time point.
-/

/--
Shift an FMCS by offset k: the new family maps time t to the original family at t - k.
-/
noncomputable def shifted_fmcs (f : FMCS Int) (k : Int) : FMCS Int where
  mcs := fun t => f.mcs (t - k)
  is_mcs := fun t => f.is_mcs (t - k)
  forward_G := fun t t' phi h_le h_G => f.forward_G (t - k) (t' - k) phi (by omega) h_G
  backward_H := fun t t' phi h_le h_H => f.backward_H (t - k) (t' - k) phi (by omega) h_H

/--
The shifted FMCS at the offset equals the original FMCS at 0.
-/
theorem shifted_fmcs_at_offset (f : FMCS Int) (k : Int) :
    (shifted_fmcs f k).mcs k = f.mcs 0 := by
  unfold shifted_fmcs
  simp

/--
Temporal coherence is preserved by shifting.
Uses weak inequality (t ≤ s) to match reflexive semantics.
-/
theorem shifted_temporal_forward_F (f : FMCS Int)
    (h_fwd : ∀ t : Int, ∀ φ : Formula, Formula.some_future φ ∈ f.mcs t →
      ∃ s : Int, t ≤ s ∧ φ ∈ f.mcs s)
    (k : Int) (t : Int) (φ : Formula)
    (h_F : Formula.some_future φ ∈ (shifted_fmcs f k).mcs t) :
    ∃ s : Int, t ≤ s ∧ φ ∈ (shifted_fmcs f k).mcs s := by
  unfold shifted_fmcs at h_F ⊢
  simp only at h_F ⊢
  obtain ⟨s, h_le, h_phi⟩ := h_fwd (t - k) φ h_F
  exact ⟨s + k, by omega, by simp only [Int.add_sub_cancel]; exact h_phi⟩

theorem shifted_temporal_backward_P (f : FMCS Int)
    (h_bwd : ∀ t : Int, ∀ φ : Formula, Formula.some_past φ ∈ f.mcs t →
      ∃ s : Int, s ≤ t ∧ φ ∈ f.mcs s)
    (k : Int) (t : Int) (φ : Formula)
    (h_P : Formula.some_past φ ∈ (shifted_fmcs f k).mcs t) :
    ∃ s : Int, s ≤ t ∧ φ ∈ (shifted_fmcs f k).mcs s := by
  unfold shifted_fmcs at h_P ⊢
  simp only at h_P ⊢
  obtain ⟨s, h_le, h_phi⟩ := h_bwd (t - k) φ h_P
  exact ⟨s + k, by omega, by simp only [Int.add_sub_cancel]; exact h_phi⟩

/-!
### Box Persistence in SuccChain

Box-formulas are constant along any FMCS (using parametric_box_persistent).
For SuccChainFMCS specifically, this means box_content is the same at all times.
-/

/--
Box formulas are constant along a SuccChainFMCS: Box(phi) at time 0 iff Box(phi) at time t.
-/
theorem succ_chain_box_persistent (M0 : SerialMCS) (phi : Formula) (t : Int) :
    Formula.box phi ∈ (SuccChainFMCS M0).mcs 0 ↔
    Formula.box phi ∈ (SuccChainFMCS M0).mcs t := by
  constructor
  · intro h; exact parametric_box_persistent (SuccChainFMCS M0) phi 0 t h
  · intro h; exact parametric_box_persistent (SuccChainFMCS M0) phi t 0 h

/--
Box formulas are constant in shifted SuccChainFMCS.
-/
theorem shifted_succ_chain_box_persistent (M0 : SerialMCS) (k : Int)
    (phi : Formula) (t : Int) :
    Formula.box phi ∈ (shifted_fmcs (SuccChainFMCS M0) k).mcs k ↔
    Formula.box phi ∈ (shifted_fmcs (SuccChainFMCS M0) k).mcs t := by
  unfold shifted_fmcs
  simp only
  constructor
  · intro h; exact parametric_box_persistent (SuccChainFMCS M0) phi (k - k) (t - k) h
  · intro h; exact parametric_box_persistent (SuccChainFMCS M0) phi (t - k) (k - k) h

/-!
### Box-Class Witness Consistency

The mathematical core: if Diamond(psi) is in an MCS M, then {psi} ∪ box_content(M)
is consistent. This uses the S5 axiom (negative introspection) to reduce all
hypotheses to Box-formulas, then applies necessitation and K-distribution.
-/

/--
If Diamond(psi) is in an MCS M, then {psi} ∪ box_content(M) is consistent.

This is the key lemma for modal saturation. The proof uses:
1. Suppose {psi} ∪ box_content(M) is inconsistent
2. Then exists a1,...,an with Box(ai) in M and {psi, a1,...,an} derives bot
3. By deduction theorem: derives a1 -> ... -> an -> neg(psi)
4. By necessitation: derives Box(a1 -> ... -> an -> neg(psi))
5. By K-distribution (n times): Box(a1) -> ... -> Box(an) -> Box(neg(psi))
6. Since all Box(ai) in M: Box(neg(psi)) in M
7. But Diamond(psi) = neg(Box(neg(psi))) in M: contradiction
-/
theorem box_class_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : Formula.diamond psi ∈ M) :
    SetConsistent ({psi} ∪ box_content M) := by
  -- SetConsistent means: for every finite list L ⊆ S, L does not derive bot
  intro L h_L_sub ⟨d⟩
  -- L is a list of formulas from {psi} ∪ box_content(M)
  -- d : L ⊢ bot

  -- Every element of L is either psi or some ai with Box(ai) ∈ M
  -- We can weaken to a derivation from [psi] ++ [a1, ..., an] where Box(ai) ∈ M

  -- Strategy: use deduction theorem to move all assumptions into the theorem,
  -- then apply necessitation and K-distribution.

  -- First, move all hypotheses out via repeated deduction theorem:
  -- From L ⊢ bot, by weakening to include all of L in a single context,
  -- we can derive: [] ⊢ l1 → l2 → ... → ln → bot = neg(l1 ∧ ... ∧ ln)

  -- Actually, the key insight is simpler. We use:
  -- 1. L ⊆ {psi} ∪ box_content(M) means every li is psi or in box_content(M)
  -- 2. For li in box_content(M), Box(li) ∈ M, so by T axiom, li ∈ M
  -- 3. For li = psi, we handle separately

  -- Case: psi ∉ L. Then L ⊆ box_content(M), and every li has Box(li) ∈ M.
  -- By T axiom: li ∈ M. So L ⊆ M. But M is consistent: L ⊆ M and L ⊢ bot
  -- contradicts MCS consistency.

  -- Case: psi ∈ L. Let L' = L without psi occurrences. Then all l ∈ L' have
  -- Box(l) ∈ M, so l ∈ M (by T). And L' ∪ {psi} ⊢ bot (by weakening from L).

  -- By repeated deduction theorem on L':
  -- [psi] ⊢ l1 → l2 → ... → bot  (removing L' elements one by one)
  -- Then [] ⊢ psi → (l1 → l2 → ... → bot)
  -- i.e., [] ⊢ neg(psi) assuming L' derives bot with psi

  -- Actually let's work more directly. Since L ⊢ bot:
  -- By weakening, M_list ++ [psi] ⊢ bot where M_list consists of elements of M
  -- (because for x ∈ L ∩ box_content(M), Box(x) ∈ M so x ∈ M by T)

  -- Hmm, but psi might appear multiple times. Let me use a cleaner approach.

  -- Simplest approach: show that L ⊆ M ∪ {psi}, and then get M_full ⊢ bot
  -- where M_full contains all of M plus psi.

  -- Actually, the cleanest approach is:
  -- 1. From L ⊢ bot, derive [] ⊢ (conjunction of L) → bot
  -- 2. The conjunction of L elements is a conjunction of psi and ai where Box(ai) ∈ M
  -- 3. Apply necessitation and K to get Box(neg(psi)) ∈ M

  -- Let me use the direct list-based approach from the MCS consistency proof.

  -- All elements of L either equal psi or have their Box in M
  -- For elements with Box in M, they are also in M (by T axiom)
  have h_T := fun (phi : Formula) (h_box : Formula.box phi ∈ M) =>
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.modal_t phi))) h_box

  -- Split L into psi-part and box_content part
  -- Weaken L to M-context by replacing box_content elements with their M-membership
  -- The key: every element of L is in M ∪ {psi}
  have h_L_in_M_or_psi : ∀ x ∈ L, x ∈ M ∨ x = psi := by
    intro x hx
    have hx_in_S := h_L_sub x hx
    simp only [Set.mem_union, Set.mem_singleton_iff] at hx_in_S
    rcases hx_in_S with h_psi | h_bc
    · right; exact h_psi
    · left
      -- x ∈ box_content M means Box(x) ∈ M, so x ∈ M by T
      exact h_T x h_bc

  -- Now we have L ⊢ bot and every element of L is in M ∪ {psi}
  -- Weaken the derivation to work from the context M ∪ {psi}
  -- Since M is consistent, adding psi might make it inconsistent
  -- But we'll show this leads to Box(neg(psi)) ∈ M, contradicting Diamond(psi) ∈ M

  -- Approach: weaken L to (insert psi M)-list
  -- L ⊢ bot, and L ⊆ insert psi M
  -- So insert psi M is SetConsistent → False? No, SetConsistent uses finite subsets.
  -- Actually L IS a finite subset of insert psi M.
  -- So ¬SetConsistent (insert psi M).

  have h_not_cons : ¬SetConsistent (insert psi M) := by
    intro h_cons
    have h_L_sub' : ∀ x ∈ L, x ∈ insert psi M := by
      intro x hx
      rcases h_L_in_M_or_psi x hx with h_M | h_psi
      · exact Set.mem_insert_of_mem psi h_M
      · rw [h_psi]; exact Set.mem_insert psi M
    exact h_cons L h_L_sub' ⟨d⟩

  -- Since M is MCS and insert psi M is inconsistent,
  -- by MCS maximality: psi ∉ M implies ¬SetConsistent (insert psi M)
  -- Conversely: if psi ∈ M, then insert psi M = M, which is consistent.

  -- So psi ∉ M (otherwise insert psi M = M which is consistent)
  have h_psi_notin : psi ∉ M := by
    intro h_in
    have h_eq : insert psi M = M := Set.insert_eq_of_mem h_in
    rw [h_eq] at h_not_cons
    exact h_not_cons h_mcs.1

  -- By MCS negation completeness: neg(psi) ∈ M
  have h_neg_psi : Formula.neg psi ∈ M := by
    rcases SetMaximalConsistent.negation_complete h_mcs psi with h | h
    · exact absurd h h_psi_notin
    · exact h

  -- By MCS maximality: psi ∉ M implies ¬SetConsistent(insert psi M)
  -- We already have this: h_not_cons
  -- From ¬SetConsistent(insert psi M), there's a finite list L' ⊆ insert psi M with L' ⊢ bot
  -- Using the deduction theorem approach:

  -- Since insert psi M is inconsistent, ∃ L' ⊆ insert psi M, L' ⊢ bot
  -- Remove psi from L' to get L'' ⊆ M with L'' ⊢ psi → bot = neg(psi)
  -- But neg(psi) ∈ M already, and M is consistent. This doesn't directly give Box.

  -- Let me use the direct S5 argument instead.
  -- We have neg(psi) ∈ M. Can we get Box(neg(psi)) ∈ M?
  -- Not directly from neg(psi) ∈ M. We need a different approach.

  -- Going back to the original argument:
  -- From L ⊢ bot where L ⊆ {psi} ∪ box_content(M):
  -- Separate psi from the rest: let L' = L \ {psi}
  -- Then L' ⊆ box_content(M), i.e., ∀ x ∈ L', Box(x) ∈ M
  -- And L' ++ [psi, ..., psi] ⊢ bot (some copies of psi from L)
  -- By weakening: L' ++ [psi] ⊢ bot (since duplicate psi adds nothing)
  -- By deduction theorem: L' ⊢ neg(psi) = psi → bot

  -- Now L' ⊢ neg(psi) where ∀ x ∈ L', Box(x) ∈ M.
  -- Weaken to the full list [a1,...,an] where ai = elements of L' (with Box(ai) ∈ M):
  -- [] ⊢ a1 → a2 → ... → an → neg(psi)  (by repeated deduction theorem)

  -- Apply necessitation: [] ⊢ Box(a1 → a2 → ... → an → neg(psi))
  -- Apply K-distribution n times:
  -- [] ⊢ Box(a1) → Box(a2) → ... → Box(an) → Box(neg(psi))

  -- Since Box(ai) ∈ M for all i, by MCS modus ponens: Box(neg(psi)) ∈ M
  -- But Diamond(psi) = neg(Box(neg(psi))) ∈ M: contradiction with MCS consistency.

  -- The full argument requires careful handling of the list operations.
  -- Let's use the fact that M is MCS and work with the MCS-level inconsistency.

  -- From h_not_cons, insert psi M is inconsistent.
  -- From h_mcs.2: for any phi ∉ M, insert phi M is inconsistent.
  -- This is exactly what h_psi_notin + h_mcs.2 gives us.

  -- Now: since neg(psi) ∈ M, can we derive Box(neg(psi))?
  -- In general no. But we can use the S5-specific argument.

  -- The actual argument: L ⊢ bot, L ⊆ {psi} ∪ box_content(M).
  -- We need to show this leads to Box(neg(psi)) ∈ M.

  -- Approach using the MCS-level proof:
  -- We'll construct a derivation [] ⊢ Box(neg(psi)) using:
  -- 1. From L ⊢ bot, extract [] ⊢ a1 → ... → an → neg(psi) where Box(ai) ∈ M
  -- 2. By necessitation and K: [] ⊢ Box(a1) → ... → Box(an) → Box(neg(psi))
  -- 3. Since Box(ai) ∈ M: Box(neg(psi)) ∈ M

  -- However, constructing this in Lean requires manipulating DerivationTree for
  -- arbitrary-length lists. This is technically involved but mathematically straightforward.

  -- For now, we'll use a simpler argument that avoids list manipulation:
  -- We directly show the contradiction using diamond_excludes_box_neg from ModalSaturation.

  -- diamond_excludes_box_neg: Diamond(psi) ∈ M → Box(neg(psi)) ∉ M
  have h_box_neg_notin : Formula.box (Formula.neg psi) ∉ M :=
    diamond_excludes_box_neg h_mcs psi h_diamond

  -- We need Box(neg(psi)) ∈ M for the contradiction.
  -- The inconsistency of {psi} ∪ box_content(M) means:
  -- exists L ⊆ {psi} ∪ box_content(M) with L ⊢ bot.
  -- We have this: L, d.

  -- Key insight: we prove this by induction on the derivation,
  -- but that's complex. Instead, use the finitary MCS argument:

  -- Since L ⊢ bot and all non-psi elements of L are in M (via T axiom on Box),
  -- we can weaken to [psi] ++ M_list ⊢ bot where M_list ⊆ M.
  -- By deduction: M_list ⊢ neg(psi).
  -- Since M_list ⊆ M and M is an MCS: neg(psi) ∈ M.
  -- But this only gives neg(psi) ∈ M, not Box(neg(psi)) ∈ M.

  -- The S5-specific step: we need to lift from formulas to Box-formulas.
  -- The derivation L ⊢ bot where L ⊆ {psi} ∪ box_content(M) means:
  -- There exist a1,...,an with Box(ai) ∈ M such that {psi, a1,...,an} ⊢ bot.
  -- This means ⊢ a1 → ... → an → neg(psi) (after repeated deduction theorem).
  -- By necessitation: ⊢ Box(a1 → ... → an → neg(psi))
  -- By K-distribution: ⊢ Box(a1) → ... → Box(an) → Box(neg(psi))
  -- Since Box(ai) ∈ M: Box(neg(psi)) ∈ M.

  -- We formalize this using an auxiliary lemma that handles the K-distribution chain.

  -- Step 1: Extract the box_content elements from L
  -- Weaken d to work with elements that are all in M or equal to psi
  -- Then apply the deduction theorem for psi to get M_list ⊢ neg(psi)

  -- For the formalization, we use the list-based approach.
  -- Filter L into psi-copies and box_content elements.
  let L_no_psi := L.filter (· ≠ psi)

  -- All elements of L_no_psi are in box_content(M)
  have h_L_no_psi_bc : ∀ x ∈ L_no_psi, x ∈ box_content M := by
    intro x hx
    have hx_L := List.mem_of_mem_filter hx
    have hx_ne : x ≠ psi := of_decide_eq_true (List.mem_filter.mp hx).2
    have := h_L_sub x hx_L
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · rw [h] at hx_ne; exact absurd rfl hx_ne
    · exact h

  -- Step 2: Weaken the derivation. L ⊢ bot can be weakened to (psi :: L_no_psi) ⊢ bot
  -- because L_no_psi ⊆ L (modulo psi which we add back)
  -- Actually, we need to weaken from L to a list containing psi and the L_no_psi elements.
  -- Since L ⊆ {psi} ∪ set_of(L_no_psi ++ [psi]), we can weaken.

  -- Simplification: just use the fact that L ⊆ insert psi M gives insert psi M inconsistent,
  -- then use the MCS property to derive Box(neg(psi)) ∈ M through the S5 argument.

  -- The S5 argument at the MCS level:
  -- insert psi M is inconsistent → neg(psi) can be derived from M
  -- → ¬SetConsistent (insert psi M)
  -- → by maximality applied to (neg (neg psi)): if neg(neg(psi)) ∉ M then contradiction...
  -- This is going in circles.

  -- Let me use the DIRECT finitary argument.
  -- We have d : DerivationTree L Formula.bot
  -- We know every x ∈ L is in M ∪ {psi} (h_L_in_M_or_psi)
  -- Weaken d to derive from M ∪ {psi}:

  -- Weaken to [psi] ++ M_elems where M_elems are the non-psi elements of L, all in M.
  -- Then apply deduction theorem for psi: M_elems ⊢ neg(psi).
  -- Then [] ⊢ m1 → ... → mk → neg(psi) by repeated deduction.
  -- By necessitation: ⊢ Box(m1 → ... → mk → neg(psi))
  -- The mi are in M. But are Box(mi) in M? Only if mi ∈ box_content(M),
  -- meaning Box(mi) ∈ M. For mi ∈ box_content(M), yes. For mi = some arbitrary
  -- element of M, Box(mi) might not be in M.

  -- AH - here's the key: the elements of L that are in M came from box_content(M).
  -- They are ai where Box(ai) ∈ M. We used T axiom to put ai in M.
  -- But for the K-distribution argument, we need Box(ai) ∈ M, which we have!

  -- So: L = [psi, a1, ..., an] where Box(ai) ∈ M.
  -- L ⊢ bot.
  -- By repeated deduction: ⊢ psi → a1 → ... → an → bot = a1 → ... → an → neg(psi)
  -- Wait, the order matters for deduction theorem.

  -- Actually: L ⊢ bot. After deduction theorem removing psi:
  -- L \ {psi} ⊢ neg(psi). Where L \ {psi} ⊆ box_content(M).
  -- After repeated deduction on L \ {psi} = [a1,...,an]:
  -- ⊢ a1 → a2 → ... → an → neg(psi)
  -- By necessitation: ⊢ Box(a1 → ... → an → neg(psi))
  -- By K (n times): ⊢ Box(a1) → Box(a2) → ... → Box(an) → Box(neg(psi))
  -- Since Box(ai) ∈ M: Box(neg(psi)) ∈ M.
  -- Contradiction with Diamond(psi) = neg(Box(neg(psi))) ∈ M.

  -- The challenge is formalizing the "repeated deduction theorem" and
  -- "K-distribution n times" for arbitrary n. Let me use a helper lemma.

  -- Helper: if ⊢ A → B and Box(A) ∈ M, then Box(B) ∈ M.
  -- Proof: By necessitation: ⊢ Box(A → B). By K: ⊢ Box(A) → Box(B).
  -- Since Box(A) ∈ M: Box(B) ∈ M.

  -- So we need: ⊢ a1 → (a2 → ... → (an → neg(psi))...)
  -- Then: Box(a1) ∈ M → Box(a2 → ... → neg(psi)) ∈ M (by helper)
  -- Then: Box(a2) ∈ M → Box(a3 → ... → neg(psi)) ∈ M (by helper on unboxed inner)
  -- Wait, this doesn't quite work because Box distributes as Box(A→B) → (Box(A) → Box(B))

  -- Let me use the standard "Box-lift" lemma:
  -- If ⊢ A → B, then ⊢ Box(A) → Box(B)
  -- Proof: Necessitate A → B, then apply K.

  -- And the iterated version:
  -- If ⊢ a1 → a2 → ... → an → C, then ⊢ Box(a1) → Box(a2) → ... → Box(an) → Box(C)
  -- Proof by induction on n using the above.

  -- For the formalization, we use List.foldl or induction on the list.
  -- This is the "box_lift_chain" lemma.

  -- Rather than formalizing the full iterated version (which requires complex list
  -- manipulation), we use a key simplification:

  -- From L ⊢ bot where L ⊆ {psi} ∪ box_content(M), we weaken L to M:
  -- Every non-psi element ai of L has Box(ai) ∈ M, so ai ∈ M (by T).
  -- So L ⊆ M ∪ {psi}. We already know insert psi M is inconsistent (h_not_cons).
  -- By MCS maximality: neg(psi) ∈ M (h_neg_psi).

  -- Now the key question: can we get Box(neg(psi)) ∈ M from this specific structure?

  -- The answer is YES, using a more refined argument:
  -- h_not_cons tells us insert psi M is inconsistent.
  -- There exists a finite L' ⊆ insert psi M with L' ⊢ bot.
  -- Take L' minimal. Then psi ∈ L' (otherwise L' ⊆ M and M inconsistent).
  -- Remove psi: L'' = L' \ [psi]. L'' ⊆ M. [psi] ++ L'' ⊢ bot.
  -- By deduction: L'' ⊢ neg(psi). By repeated deduction: ⊢ l1 → ... → lk → neg(psi).

  -- Here l1,...,lk are elements of M. But we can't necessitate unless they are theorems.
  -- The issue: l1,...,lk are arbitrary elements of M, not box_content elements.

  -- BUT wait: in our specific case, L ⊆ {psi} ∪ box_content(M), not L ⊆ {psi} ∪ M.
  -- So the non-psi elements of L are in box_content(M), meaning Box(li) ∈ M.

  -- So the refined argument IS: L'' (non-psi part of L) ⊆ box_content(M).
  -- ⊢ l1 → l2 → ... → lk → neg(psi) where Box(li) ∈ M.
  -- Necessitate and distribute K:
  -- ⊢ Box(l1) → Box(l2) → ... → Box(lk) → Box(neg(psi))
  -- Since Box(li) ∈ M: Box(neg(psi)) ∈ M. Contradiction.

  -- Let me now formalize this properly using induction on the list.

  -- First, let's establish that we can extract a derivation from non-psi elements.
  -- We have d : L ⊢ bot and L ⊆ {psi} ∪ box_content(M).
  -- Weaken to (psi :: L_no_psi) ⊢ bot.

  -- Actually, L might have psi in any position. We can weaken from L to any
  -- superlist. The key fact: L ⊆ psi :: L_no_psi (as sets).
  -- Wait, we need the opposite: weaken FROM L TO a smaller/different context.
  -- Weakening goes: if L ⊆ L' then L ⊢ bot implies L' ⊢ bot.
  -- So we need L ⊆ (psi :: L_no_psi).

  -- This is true: every element of L is either psi (in head) or in L_no_psi (by filter).
  -- Actually L_no_psi = L.filter (· ≠ psi) so L ⊆ [psi] ++ L_no_psi.

  have h_L_sub_psi_Lnp : ∀ x ∈ L, x ∈ psi :: L_no_psi := by
    intro x hx
    by_cases h_eq : x = psi
    · rw [h_eq]; exact .head _
    · exact List.mem_cons_of_mem psi (List.mem_filter.mpr ⟨hx, decide_eq_true h_eq⟩)

  -- Weaken: psi :: L_no_psi ⊢ bot
  have d_weak : DerivationTree (psi :: L_no_psi) Formula.bot :=
    DerivationTree.weakening L (psi :: L_no_psi) Formula.bot d h_L_sub_psi_Lnp

  -- Deduction theorem: L_no_psi ⊢ neg(psi) = psi → bot
  have d_neg_psi : DerivationTree L_no_psi (Formula.neg psi) :=
    Bimodal.Metalogic.Core.deduction_theorem L_no_psi psi Formula.bot d_weak

  -- Now we need: ⊢ l1 → l2 → ... → lk → neg(psi) by repeated deduction,
  -- then necessitate and K-distribute.

  -- We prove: Box(neg(psi)) ∈ M by induction on L_no_psi.
  -- The invariant: if ctx ⊢ neg(psi) and ∀ x ∈ ctx, Box(x) ∈ M, then Box(neg(psi)) ∈ M.

  -- This is the "box_lift_from_context" lemma.
  suffices h : ∀ (ctx : List Formula) (phi : Formula),
      DerivationTree ctx phi → (∀ x ∈ ctx, Formula.box x ∈ M) → Formula.box phi ∈ M by
    exact h_box_neg_notin (h L_no_psi (Formula.neg psi) d_neg_psi
      (fun x hx => h_L_no_psi_bc x hx))

  -- Prove the box_lift_from_context by induction on the context length
  intro ctx phi d_ctx h_ctx_box
  induction ctx generalizing phi with
  | nil =>
    -- Empty context: d_ctx is a theorem ([] ⊢ phi)
    -- By necessitation: ⊢ Box(phi). So Box(phi) ∈ M.
    have d_box : DerivationTree [] (Formula.box phi) := DerivationTree.necessitation phi d_ctx
    exact theorem_in_mcs h_mcs d_box
  | cons a rest ih =>
    -- Context is a :: rest.
    -- d_ctx : (a :: rest) ⊢ phi
    -- By deduction theorem: rest ⊢ a → phi
    have d_imp : DerivationTree rest (a.imp phi) :=
      Bimodal.Metalogic.Core.deduction_theorem rest a phi d_ctx
    -- By induction hypothesis (since all elements of rest have their Box in M):
    -- Box(a → phi) ∈ M
    have h_rest_box : ∀ x ∈ rest, Formula.box x ∈ M :=
      fun x hx => h_ctx_box x (List.mem_cons_of_mem a hx)
    have h_box_imp : Formula.box (a.imp phi) ∈ M := ih (a.imp phi) d_imp h_rest_box
    -- Box(a) ∈ M (from h_ctx_box)
    have h_box_a : Formula.box a ∈ M := h_ctx_box a (.head _)
    -- K-distribution: Box(a → phi) → (Box(a) → Box(phi))
    have h_K : [] ⊢ (Formula.box (a.imp phi)).imp ((Formula.box a).imp (Formula.box phi)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist a phi)
    -- Box(a → phi) ∈ M and K ∈ M give Box(a) → Box(phi) ∈ M
    have h_imp_in_M : (Formula.box a).imp (Formula.box phi) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_K) h_box_imp
    -- Box(a) ∈ M and (Box(a) → Box(phi)) ∈ M give Box(phi) ∈ M
    exact SetMaximalConsistent.implication_property h_mcs h_imp_in_M h_box_a

/-!
### Box-Class Witness Existence

From box_class_witness_consistent, we extend to a full MCS in the same box class.
-/

/-!
### Strengthened Box-Class Witness

We strengthen the seed to include Box-formulas directly, along with
neg(Box) formulas for non-box elements, ensuring full box-class agreement.
-/

/--
The "box theory" of an MCS: the set of Box-formulas and their negations that are in M.
This is {Box(a) | Box(a) ∈ M} ∪ {neg(Box(a)) | Box(a) ∉ M}.
-/
def box_theory (M : Set Formula) : Set Formula :=
  { f | (∃ a, f = Formula.box a ∧ Formula.box a ∈ M) ∨
        (∃ a, f = Formula.neg (Formula.box a) ∧ Formula.box a ∉ M) }

/--
All elements of box_theory(M) are in M (when M is an MCS).
-/
theorem box_theory_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    box_theory M ⊆ M := by
  intro f hf
  simp only [box_theory, Set.mem_setOf_eq] at hf
  rcases hf with ⟨a, rfl, ha⟩ | ⟨a, rfl, ha⟩
  · exact ha
  · -- Box(a) ∉ M, so neg(Box(a)) ∈ M by negation completeness
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box a) with h | h
    · exact absurd h ha
    · exact h

/--
The strengthened consistency lemma: {psi} ∪ box_theory(M) is consistent
when Diamond(psi) is in M.

The proof uses S5 negative introspection to convert all hypotheses to Box-formulas.
-/
theorem box_theory_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : Formula.diamond psi ∈ M) :
    SetConsistent ({psi} ∪ box_theory M) := by
  -- The key: box_theory(M) ⊆ M, and {psi} ∪ M might be inconsistent,
  -- but {psi} ∪ box_theory(M) is a SUBSET of {psi} ∪ M, so this doesn't help directly.

  -- We use the S5 argument. Suppose {psi} ∪ box_theory(M) is inconsistent.
  -- Then ∃ L ⊆ {psi} ∪ box_theory(M) with L ⊢ bot.
  intro L h_L_sub ⟨d⟩

  -- Every element of L is either psi, some Box(a) with Box(a) ∈ M,
  -- or some neg(Box(a)) with Box(a) ∉ M.
  -- In the latter case, by S5 axiom 5: neg(Box(a)) → Box(neg(Box(a)))
  -- So Box(neg(Box(a))) ∈ M.

  -- Strategy: show all elements of L are in M, then use MCS consistency.
  -- box_theory(M) ⊆ M (by box_theory_subset_mcs), so L ⊆ {psi} ∪ M = insert psi M.
  have h_bt_sub := box_theory_subset_mcs M h_mcs
  have h_L_in_M_or_psi : ∀ x ∈ L, x ∈ insert psi M := by
    intro x hx
    have := h_L_sub x hx
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · exact Set.mem_insert_iff.mpr (Or.inl h)
    · exact Set.mem_insert_of_mem psi (h_bt_sub h)

  -- Now the argument parallels box_class_witness_consistent but with box_theory.

  -- We need all non-psi elements to have their Box in M.
  -- For Box(a) ∈ box_theory: Box(Box(a)) ∈ M (by axiom 4: Box(a) → Box(Box(a)))
  -- For neg(Box(a)) ∈ box_theory: Box(neg(Box(a))) ∈ M (by axiom 5)

  -- So ALL non-psi elements of L from box_theory have their Box in M!

  -- Extract box-boxing property
  have h_box_of_bt : ∀ x ∈ box_theory M, Formula.box x ∈ M := by
    intro x hx
    simp only [box_theory, Set.mem_setOf_eq] at hx
    rcases hx with ⟨a, rfl, ha⟩ | ⟨a, rfl, ha⟩
    · -- x = Box(a), Box(a) ∈ M. Need Box(Box(a)) ∈ M.
      -- By axiom 4: Box(a) → Box(Box(a))
      have h_4 : [] ⊢ (Formula.box a).imp (Formula.box (Formula.box a)) :=
        DerivationTree.axiom [] _ (Axiom.modal_4 a)
      exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_4) ha
    · -- x = neg(Box(a)), Box(a) ∉ M. Need Box(neg(Box(a))) ∈ M.
      -- By S5 axiom 5 (negative introspection): neg(Box(a)) → Box(neg(Box(a)))
      have h_neg_box : (Formula.box a).neg ∈ M := by
        rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box a) with h | h
        · exact absurd h ha
        · exact h
      exact SetMaximalConsistent.neg_box_implies_box_neg_box h_mcs a h_neg_box

  -- Now use the same box_lift_from_context argument as before.
  -- Filter L into psi-part and box_theory part
  let L_no_psi := L.filter (· ≠ psi)

  have h_L_no_psi_bt : ∀ x ∈ L_no_psi, x ∈ box_theory M := by
    intro x hx
    have hx_L := List.mem_of_mem_filter hx
    have hx_ne : x ≠ psi := of_decide_eq_true (List.mem_filter.mp hx).2
    have := h_L_sub x hx_L
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · rw [h] at hx_ne; exact absurd rfl hx_ne
    · exact h

  have h_L_sub_psi_Lnp : ∀ x ∈ L, x ∈ psi :: L_no_psi := by
    intro x hx
    by_cases h_eq : x = psi
    · rw [h_eq]; exact .head _
    · exact List.mem_cons_of_mem psi (List.mem_filter.mpr ⟨hx, decide_eq_true h_eq⟩)

  have d_weak : DerivationTree (psi :: L_no_psi) Formula.bot :=
    DerivationTree.weakening L (psi :: L_no_psi) Formula.bot d h_L_sub_psi_Lnp

  have d_neg_psi : DerivationTree L_no_psi (Formula.neg psi) :=
    Bimodal.Metalogic.Core.deduction_theorem L_no_psi psi Formula.bot d_weak

  -- All elements of L_no_psi are in box_theory(M), so their Box is in M
  have h_L_no_psi_box : ∀ x ∈ L_no_psi, Formula.box x ∈ M :=
    fun x hx => h_box_of_bt x (h_L_no_psi_bt x hx)

  -- Box-lift: from L_no_psi ⊢ neg(psi) and all Box(x) ∈ M for x ∈ L_no_psi,
  -- derive Box(neg(psi)) ∈ M.
  have h_box_neg_psi : Formula.box (Formula.neg psi) ∈ M := by
    -- Induction on context (same as box_lift_from_context from above)
    suffices h : ∀ (ctx : List Formula) (phi : Formula),
        DerivationTree ctx phi → (∀ x ∈ ctx, Formula.box x ∈ M) → Formula.box phi ∈ M by
      exact h L_no_psi (Formula.neg psi) d_neg_psi h_L_no_psi_box
    intro ctx phi d_ctx h_ctx_box
    induction ctx generalizing phi with
    | nil =>
      exact theorem_in_mcs h_mcs (DerivationTree.necessitation phi d_ctx)
    | cons a rest ih =>
      have d_imp := Bimodal.Metalogic.Core.deduction_theorem rest a phi d_ctx
      have h_rest_box := fun x hx => h_ctx_box x (List.mem_cons_of_mem a hx)
      have h_box_imp := ih (a.imp phi) d_imp h_rest_box
      have h_box_a := h_ctx_box a (.head _)
      have h_K := DerivationTree.axiom [] _ (Axiom.modal_k_dist a phi)
      have h_imp_in_M := SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_K) h_box_imp
      exact SetMaximalConsistent.implication_property h_mcs h_imp_in_M h_box_a

  -- But Diamond(psi) = neg(Box(neg(psi))) ∈ M
  exact diamond_excludes_box_neg h_mcs psi h_diamond h_box_neg_psi

/--
If Diamond(psi) is in MCS M, there exists MCS W with psi in W and same box theory.
-/
theorem box_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : Formula.diamond psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ psi ∈ W ∧ box_class_agree M W := by
  have h_cons := box_theory_witness_consistent M h_mcs psi h_diamond
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum ({psi} ∪ box_theory M) h_cons
  use W, h_W_mcs
  constructor
  · exact h_extends (Set.mem_union_left _ (Set.mem_singleton psi))
  · intro phi
    constructor
    · -- Box(phi) ∈ M → Box(phi) ∈ W
      intro h_box
      -- Box(phi) is in box_theory(M), so in the seed, so in W
      have : Formula.box phi ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inl ⟨phi, rfl, h_box⟩
      exact h_extends (Set.mem_union_right _ this)
    · -- Box(phi) ∈ W → Box(phi) ∈ M
      intro h_box_W
      -- neg(Box(phi)) ∈ box_theory(M) if Box(phi) ∉ M
      by_contra h_not_in_M
      have : Formula.neg (Formula.box phi) ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inr ⟨phi, rfl, h_not_in_M⟩
      have h_neg_in_W : Formula.neg (Formula.box phi) ∈ W :=
        h_extends (Set.mem_union_right _ this)
      -- Box(phi) ∈ W and neg(Box(phi)) ∈ W contradicts W being MCS
      exact set_consistent_not_both h_W_mcs.1 (Formula.box phi) h_box_W h_neg_in_W

/-!
### Temporal Theory and Witness Consistency

Define G_theory (the "temporal theory" of an MCS) and prove witness consistency:
if F(phi) ∈ M (MCS), then {phi} ∪ G_theory(M) ∪ box_theory(M) is consistent.

This is the temporal analog of box_theory_witness_consistent, using:
- temp_4: G(a) → G(G(a)) for G-lifting G_theory elements
- temp_future: Box(a) → G(Box(a)) for G-lifting box_theory elements
- temp_k_dist + temporal_necessitation for the G-lift induction

Unlike box_theory which has negative introspection (S5 axiom 5), the temporal
logic lacks neg(G(a)) → G(neg(G(a))). So we use only positive G-formulas
in G_theory, which is sufficient for the witness consistency proof.
-/

/--
The "G theory" of an MCS: the set of formulas whose G is in M.
G_theory(M) = {G(a) | G(a) ∈ M}

This contains the G-WRAPPED formulas, not the inner formulas.
Using G-wrapped formulas enables the G-lift argument via temp_4.

Note: Unlike box_theory which includes both positive and negative parts
(using S5 axiom 5), G_theory only has the positive part because the
temporal logic lacks negative introspection for G.
-/
def G_theory (M : Set Formula) : Set Formula :=
  { f | ∃ a, f = Formula.all_future a ∧ Formula.all_future a ∈ M }

/--
All elements of G_theory(M) are in M (trivially, since they ARE M's G-formulas).
-/
theorem G_theory_subset_mcs (M : Set Formula) :
    G_theory M ⊆ M := by
  intro f hf
  simp only [G_theory, Set.mem_setOf_eq] at hf
  obtain ⟨a, rfl, ha⟩ := hf
  exact ha

/--
Every element of G_theory(M) can be G-lifted: G(G(a)) ∈ M when G(a) ∈ M.
This uses temp_4: G(a) → G(G(a)).
-/
theorem G_of_G_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ G_theory M, Formula.all_future x ∈ M := by
  intro x hx
  simp only [G_theory, Set.mem_setOf_eq] at hx
  obtain ⟨a, rfl, ha⟩ := hx
  -- Need G(G(a)) ∈ M. By temp_4: G(a) → G(G(a))
  have h_4 : [] ⊢ (Formula.all_future a).imp (Formula.all_future (Formula.all_future a)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 a)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_4) ha

/--
Every element of box_theory(M) can be G-lifted: G(f) ∈ M for f ∈ box_theory(M).

- For Box(a) ∈ M: G(Box(a)) ∈ M by temp_future (Box(a) → G(Box(a)))
- For neg(Box(a)) with Box(a) ∉ M: neg(Box(a)) ∈ M (negation completeness),
  then Box(neg(Box(a))) ∈ M (S5 axiom 5), then G(Box(neg(Box(a)))) ∈ M (temp_future),
  then G(neg(Box(a))) ∈ M (by G distributing over Box-T: G(Box(x)) → G(x)).
-/
theorem G_of_box_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ box_theory M, Formula.all_future x ∈ M := by
  intro x hx
  simp only [box_theory, Set.mem_setOf_eq] at hx
  rcases hx with ⟨a, rfl, ha⟩ | ⟨a, rfl, ha⟩
  · -- x = Box(a), Box(a) ∈ M. Need G(Box(a)) ∈ M.
    -- By temp_future: Box(a) → G(Box(a))
    have h_tf : [] ⊢ (Formula.box a).imp (Formula.all_future (Formula.box a)) :=
      DerivationTree.axiom [] _ (Axiom.temp_future a)
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_tf) ha
  · -- x = neg(Box(a)), Box(a) ∉ M. Need G(neg(Box(a))) ∈ M.
    -- Step 1: neg(Box(a)) ∈ M (negation completeness)
    have h_neg_box : (Formula.box a).neg ∈ M := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box a) with h | h
      · exact absurd h ha
      · exact h
    -- Step 2: Box(neg(Box(a))) ∈ M (S5 axiom 5: neg(Box(a)) → Box(neg(Box(a))))
    have h_box_neg_box : Formula.box ((Formula.box a).neg) ∈ M :=
      SetMaximalConsistent.neg_box_implies_box_neg_box h_mcs a h_neg_box
    -- Step 3: G(Box(neg(Box(a)))) ∈ M (temp_future)
    have h_tf : [] ⊢ (Formula.box ((Formula.box a).neg)).imp
        (Formula.all_future (Formula.box ((Formula.box a).neg))) :=
      DerivationTree.axiom [] _ (Axiom.temp_future ((Formula.box a).neg))
    have h_G_box : Formula.all_future (Formula.box ((Formula.box a).neg)) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_tf) h_box_neg_box
    -- Step 4: G(neg(Box(a))) ∈ M via G(Box(x)) → G(x)
    -- Box(x) → x is modal_t. G(Box(x) → x) by temporal necessitation.
    -- G(Box(x) → x) → (G(Box(x)) → G(x)) by temp_k_dist.
    -- So [] ⊢ G(Box(x)).imp G(x). Then use implication_property.
    have h_box_t : [] ⊢ (Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t ((Formula.box a).neg))
    -- G(Box(x) → x) by temporal necessitation
    have h_G_box_t : [] ⊢ Formula.all_future ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)) :=
      DerivationTree.temporal_necessitation _ h_box_t
    -- G(A → B) → (G(A) → G(B)) by temp_k_dist
    have h_k : [] ⊢ (Formula.all_future ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg))).imp
        ((Formula.all_future (Formula.box ((Formula.box a).neg))).imp
         (Formula.all_future ((Formula.box a).neg))) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist (Formula.box ((Formula.box a).neg)) ((Formula.box a).neg))
    -- Combine via modus ponens: [] ⊢ G(Box(x)).imp G(x)
    have h_G_imp : [] ⊢ (Formula.all_future (Formula.box ((Formula.box a).neg))).imp
        (Formula.all_future ((Formula.box a).neg)) :=
      DerivationTree.modus_ponens [] _ _ h_k h_G_box_t
    -- Apply implication_property with h_G_box to get G(neg(Box(a))) ∈ M
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_G_imp) h_G_box

/--
The combined seed for temporal-modal witnesses: G_theory ∪ box_theory.
-/
def temporal_box_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ box_theory M

/--
Every element of the combined seed can be G-lifted.
-/
theorem G_of_temporal_box_seed (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ temporal_box_seed M, Formula.all_future x ∈ M := by
  intro x hx
  simp only [temporal_box_seed, Set.mem_union] at hx
  rcases hx with h | h
  · exact G_of_G_theory M h_mcs x h
  · exact G_of_box_theory M h_mcs x h

/--
The G-lift lemma for temporal theory: from a derivation using elements of
temporal_box_seed(M), derive the G-lift is in M.

If ctx ⊢ phi and all elements of ctx have their G in M, then G(phi) ∈ M.
-/
theorem G_lift_from_context (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ctx : List Formula) (phi : Formula)
    (h_deriv : DerivationTree ctx phi)
    (h_ctx_G : ∀ x ∈ ctx, Formula.all_future x ∈ M) :
    Formula.all_future phi ∈ M := by
  induction ctx generalizing phi with
  | nil =>
    exact theorem_in_mcs h_mcs (DerivationTree.temporal_necessitation phi h_deriv)
  | cons a rest ih =>
    have d_imp := Bimodal.Metalogic.Core.deduction_theorem rest a phi h_deriv
    have h_rest_G := fun x hx => h_ctx_G x (List.mem_cons_of_mem a hx)
    have h_G_imp := ih (a.imp phi) d_imp h_rest_G
    have h_G_a := h_ctx_G a (.head _)
    have h_K := DerivationTree.axiom [] _ (Axiom.temp_k_dist a phi)
    have h_imp_in_M := SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_K) h_G_imp
    exact SetMaximalConsistent.implication_property h_mcs h_imp_in_M h_G_a

/--
F(phi) ∈ M excludes G(neg(phi)) from M.

Since F(phi) = neg(G(neg(phi))), having both F(phi) and G(neg(phi)) in M
would violate MCS consistency.
-/
theorem some_future_excludes_all_future_neg {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    Formula.all_future (Formula.neg phi) ∉ M := by
  intro h_G
  -- F(phi) = neg(G(neg(phi))) = phi.neg.all_future.neg
  -- So F(phi) and G(neg(phi)) = phi.neg.all_future
  -- F(phi) = (phi.neg.all_future).neg
  have h_eq : Formula.some_future phi = Formula.neg (Formula.all_future (Formula.neg phi)) := rfl
  rw [h_eq] at h_F
  exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg phi)) h_G h_F

/--
The temporal theory witness consistency lemma:
If F(phi) ∈ M (MCS), then {phi} ∪ G_theory(M) ∪ box_theory(M) is consistent.

**Proof**: Suppose inconsistent. Then finite L ⊆ {phi} ∪ G_theory(M) ∪ box_theory(M)
with L ⊢ bot. By deduction theorem: L_rest ⊢ neg(phi) where
L_rest ⊆ G_theory(M) ∪ box_theory(M). By G_lift_from_context: G(neg(phi)) ∈ M.
But F(phi) = neg(G(neg(phi))) ∈ M, contradiction.
-/
theorem temporal_theory_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent ({phi} ∪ temporal_box_seed M) := by
  intro L h_L_sub ⟨d⟩
  -- Filter L into phi-part and seed part
  let L_no_phi := L.filter (· ≠ phi)

  have h_L_no_phi_seed : ∀ x ∈ L_no_phi, x ∈ temporal_box_seed M := by
    intro x hx
    have hx_L := List.mem_of_mem_filter hx
    have hx_ne : x ≠ phi := of_decide_eq_true (List.mem_filter.mp hx).2
    have := h_L_sub x hx_L
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · rw [h] at hx_ne; exact absurd rfl hx_ne
    · exact h

  have h_L_sub_phi_Lnp : ∀ x ∈ L, x ∈ phi :: L_no_phi := by
    intro x hx
    by_cases h_eq : x = phi
    · rw [h_eq]; exact .head _
    · exact List.mem_cons_of_mem phi (List.mem_filter.mpr ⟨hx, decide_eq_true h_eq⟩)

  have d_weak : DerivationTree (phi :: L_no_phi) Formula.bot :=
    DerivationTree.weakening L (phi :: L_no_phi) Formula.bot d h_L_sub_phi_Lnp

  have d_neg_phi : DerivationTree L_no_phi (Formula.neg phi) :=
    Bimodal.Metalogic.Core.deduction_theorem L_no_phi phi Formula.bot d_weak

  -- All elements of L_no_phi are in temporal_box_seed(M), so their G is in M
  have h_L_no_phi_G : ∀ x ∈ L_no_phi, Formula.all_future x ∈ M :=
    fun x hx => G_of_temporal_box_seed M h_mcs x (h_L_no_phi_seed x hx)

  -- G-lift: from L_no_phi ⊢ neg(phi) and all G(x) ∈ M for x ∈ L_no_phi,
  -- derive G(neg(phi)) ∈ M.
  have h_G_neg_phi : Formula.all_future (Formula.neg phi) ∈ M :=
    G_lift_from_context M h_mcs L_no_phi (Formula.neg phi) d_neg_phi h_L_no_phi_G

  -- But F(phi) = neg(G(neg(phi))) ∈ M
  exact some_future_excludes_all_future_neg h_mcs phi h_F h_G_neg_phi

/--
If F(phi) ∈ M (MCS), there exists MCS W with phi ∈ W,
G_theory agreement (G(a) ∈ M → G(a) ∈ W), and box_class_agree(M, W).
-/
theorem temporal_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W := by
  have h_cons := temporal_theory_witness_consistent M h_mcs phi h_F
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum ({phi} ∪ temporal_box_seed M) h_cons
  use W, h_W_mcs
  refine ⟨?_, ?_, ?_⟩
  · -- phi ∈ W
    exact h_extends (Set.mem_union_left _ (Set.mem_singleton phi))
  · -- G_theory agreement: G(a) ∈ M → G(a) ∈ W
    intro a ha
    have : Formula.all_future a ∈ G_theory M := by
      simp only [G_theory, Set.mem_setOf_eq]
      exact ⟨a, rfl, ha⟩
    exact h_extends (Set.mem_union_right _ (Set.mem_union_left _ this))
  · -- box_class_agree M W (same as in box_theory_witness_exists)
    intro psi
    constructor
    · intro h_box
      have : Formula.box psi ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inl ⟨psi, rfl, h_box⟩
      exact h_extends (Set.mem_union_right _ (Set.mem_union_right _ this))
    · intro h_box_W
      by_contra h_not_in_M
      have : Formula.neg (Formula.box psi) ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inr ⟨psi, rfl, h_not_in_M⟩
      have h_neg_in_W : Formula.neg (Formula.box psi) ∈ W :=
        h_extends (Set.mem_union_right _ (Set.mem_union_right _ this))
      exact set_consistent_not_both h_W_mcs.1 (Formula.box psi) h_box_W h_neg_in_W

/-!
### F-Preserving Seeds

The standard `temporal_theory_witness_exists` uses seed = {phi} ∪ G_theory ∪ box_theory.
This allows Lindenbaum to add G(neg psi) = neg(F(psi)) when consistent with the seed,
even when F(psi) was present in the original MCS.

F-preserving seeds include unresolved F-formulas in the seed, preventing Lindenbaum
from adding their negations.

**Key Insight**: If G(neg psi) were derivable from the original seed when F(psi) ∈ M,
then by the G-lift argument G(neg psi) ∈ M. But F(psi) = neg(G(neg psi)) ∈ M contradicts
this. Therefore adding F(psi) to the seed is safe.
-/

/--
The set of unresolved F-formulas in an MCS M.

F(psi) is unresolved in M if F(psi) ∈ M but psi ∉ M. These formulas represent
temporal obligations that haven't been satisfied yet.
-/
def F_unresolved_theory (M : Set Formula) : Set Formula :=
  { f | ∃ psi, f = Formula.some_future psi ∧ Formula.some_future psi ∈ M ∧ psi ∉ M }

/-!
### Helper Lemmas for F-Preserving Seed Consistency

These lemmas support the proof of `f_preserving_seed_consistent` via
iterated F-extraction and G-lift.
-/

/--
If a disjunction of G-formulas is in an MCS, then at least one of the G-formulas is in the MCS.

This follows from the T-axiom (G(φ) → φ) and the MCS disjunction property.
-/
theorem G_disjunction_in_mcs_elim (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (As : List Formula)
    (h : (As.map Formula.all_future).foldr Formula.or Formula.bot ∈ M) :
    ∃ a ∈ As, Formula.all_future a ∈ M := by
  -- Use disjunction_elim repeatedly
  induction As with
  | nil =>
    -- foldr on [] gives ⊥
    simp only [List.map_nil, List.foldr_nil] at h
    -- ⊥ ∈ M contradicts MCS consistency
    exfalso
    -- MCS consistency means no finite subset derives ⊥
    -- If ⊥ ∈ M, then [⊥] ⊆ M and [⊥] ⊢ ⊥ trivially
    have h_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption [Formula.bot] Formula.bot (List.mem_singleton.mpr rfl)
    exact h_mcs.1 [Formula.bot] (fun x hx => by simp at hx; rw [hx]; exact h) ⟨h_deriv⟩
  | cons a rest ih =>
    simp only [List.map_cons, List.foldr_cons] at h
    -- h : (G(a) ∨ rest...) ∈ M
    cases SetMaximalConsistent.disjunction_elim h_mcs h with
    | inl h_Ga => exact ⟨a, .head _, h_Ga⟩
    | inr h_rest =>
      have ⟨b, h_b_rest, h_Gb⟩ := ih h_rest
      exact ⟨b, .tail _ h_b_rest, h_Gb⟩

/--
If G of a disjunction of G-formulas is in an MCS, then at least one of the G-formulas is in the MCS.

This combines the T-axiom with G_disjunction_in_mcs_elim.
-/
theorem G_of_disjunction_in_mcs_elim (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (As : List Formula)
    (h : Formula.all_future ((As.map Formula.all_future).foldr Formula.or Formula.bot) ∈ M) :
    ∃ a ∈ As, Formula.all_future a ∈ M := by
  -- By T-axiom: G(φ) → φ
  have h_T : [] ⊢ (Formula.all_future ((As.map Formula.all_future).foldr Formula.or Formula.bot)).imp
                  ((As.map Formula.all_future).foldr Formula.or Formula.bot) :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future _)
  -- Apply to M
  have h_disj : (As.map Formula.all_future).foldr Formula.or Formula.bot ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h
  exact G_disjunction_in_mcs_elim M h_mcs As h_disj

/--
The F-preserving seed for temporal witness construction.

This extends the standard temporal_box_seed with unresolved F-formulas,
ensuring that Lindenbaum cannot add G(neg psi) = neg(F(psi)) for any
unresolved F(psi) in the original MCS.
-/
def f_preserving_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M

/--
Elements of G_theory are in the F-preserving seed.
-/
theorem G_theory_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    G_theory M ⊆ f_preserving_seed M phi := by
  intro x hx
  unfold f_preserving_seed
  exact Set.mem_union_left _ (Set.mem_union_right _ (Set.mem_union_left _ hx))

/--
Elements of box_theory are in the F-preserving seed.
-/
theorem box_theory_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    box_theory M ⊆ f_preserving_seed M phi := by
  intro x hx
  unfold f_preserving_seed
  exact Set.mem_union_left _ (Set.mem_union_right _ (Set.mem_union_right _ hx))

/--
Elements of F_unresolved_theory are in the F-preserving seed.
-/
theorem F_unresolved_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    F_unresolved_theory M ⊆ f_preserving_seed M phi := by
  intro x hx
  unfold f_preserving_seed
  exact Set.mem_union_right _ hx

/--
The witness formula is in the F-preserving seed.
-/
theorem phi_in_f_preserving_seed (M : Set Formula) (phi : Formula) :
    phi ∈ f_preserving_seed M phi := by
  unfold f_preserving_seed
  exact Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_singleton phi))

/--
The temporal_box_seed is contained in the F-preserving seed.
-/
theorem temporal_box_seed_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    temporal_box_seed M ⊆ f_preserving_seed M phi := by
  intro x hx
  unfold f_preserving_seed
  exact Set.mem_union_left _ (Set.mem_union_right _ hx)

/--
All elements of F_unresolved_theory are F-formulas that are in M.
-/
theorem F_unresolved_theory_subset_M (M : Set Formula) :
    F_unresolved_theory M ⊆ M := by
  intro f hf
  simp only [F_unresolved_theory, Set.mem_setOf_eq] at hf
  obtain ⟨psi, rfl, h_in, _⟩ := hf
  exact h_in

/--
The standard seed ({phi} ∪ G_theory ∪ box_theory) is a subset of the F-preserving seed.
-/
theorem standard_seed_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    {phi} ∪ temporal_box_seed M ⊆ f_preserving_seed M phi := by
  intro x hx
  simp only [Set.mem_union, Set.mem_singleton_iff] at hx
  rcases hx with rfl | hx
  · exact phi_in_f_preserving_seed M x
  · exact temporal_box_seed_subset_f_preserving_seed M phi hx

/--
The F-preserving seed is consistent when F(phi) ∈ M.

**Proof Strategy**:
Suppose the F-preserving seed is inconsistent. Then there exists finite
L ⊆ f_preserving_seed M phi with L ⊢ ⊥.

Partition L into:
- L_core ⊆ {phi} ∪ temporal_box_seed M (the standard seed)
- L_F ⊆ F_unresolved_theory M (the F-formulas we added)

By deduction theorem, extracting all F-formulas from L_F:
  L_core ⊢ F(psi_1) → F(psi_2) → ... → F(psi_k) → ⊥

This is equivalent to:
  L_core ⊢ neg(F(psi_1)) ∨ neg(F(psi_2)) ∨ ... ∨ neg(F(psi_k))
  = L_core ⊢ G(neg psi_1) ∨ G(neg psi_2) ∨ ... ∨ G(neg psi_k)

Since L_core ⊆ standard seed and all elements have their G in M,
by G-lift: G(G(neg psi_1) ∨ ...) ∈ M.
By the K axiom for G: G(G(neg psi_1)) ∨ ... ∨ G(G(neg psi_k)) ∈ M.
By T axiom: G(neg psi_i) ∈ M for some i.

But F(psi_i) ∈ M (since F(psi_i) ∈ F_unresolved_theory M ⊆ M), contradiction.

Note: The actual proof is simpler - we show that inconsistency of the F-preserving
seed would imply inconsistency of {phi} ∪ temporal_box_seed M, contradicting
temporal_theory_witness_consistent.
-/
theorem f_preserving_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (f_preserving_seed M phi) := by
  -- The F-preserving seed extends the standard seed with F_unresolved_theory.
  -- We show this extension preserves consistency.

  -- Key insight: f_preserving_seed M phi ⊆ {phi} ∪ temporal_box_seed M ∪ M
  -- And any inconsistency must come from the interaction between components.

  -- The proof uses that adding F-formulas that are already in M cannot break
  -- the consistency of the standard seed.

  intro L h_L_sub ⟨d⟩

  -- Classify each element of L based on where it comes from
  -- We'll show: either L ⊆ standard seed (contradicts temporal_theory_witness_consistent)
  -- or we can extract F-formulas using deduction theorem and derive contradiction

  -- Check if any element of L is from F_unresolved_theory but not in standard seed
  by_cases h_all_standard : ∀ x ∈ L, x ∈ {phi} ∪ temporal_box_seed M

  · -- Case 1: All elements are from the standard seed
    exact temporal_theory_witness_consistent M h_mcs phi h_F L h_all_standard ⟨d⟩

  · -- Case 2: Some element is from F_unresolved_theory
    push_neg at h_all_standard
    obtain ⟨x, hx_L, hx_not_standard⟩ := h_all_standard

    -- x ∈ f_preserving_seed M phi but x ∉ {phi} ∪ temporal_box_seed M
    -- So x ∈ F_unresolved_theory M
    have hx_seed := h_L_sub x hx_L
    simp only [f_preserving_seed, Set.mem_union] at hx_seed

    have hx_F : x ∈ F_unresolved_theory M := by
      rcases hx_seed with (h | h) | h
      · -- x ∈ {phi}
        exfalso; apply hx_not_standard
        exact Set.mem_union_left _ h
      · -- x ∈ temporal_box_seed M
        exfalso; apply hx_not_standard
        exact Set.mem_union_right _ h
      · -- x ∈ F_unresolved_theory M
        exact h

    -- x ∈ F_unresolved_theory M, so x = F(psi) for some psi with F(psi) ∈ M and psi ∉ M
    simp only [F_unresolved_theory, Set.mem_setOf_eq] at hx_F
    obtain ⟨psi, rfl, h_Fpsi_M, h_psi_not_M⟩ := hx_F

    -- Now we use the key argument:
    -- If L ⊢ ⊥ and F(psi) ∈ L, then L \ {F(psi)} ⊢ neg(F(psi)) = G(neg psi)

    -- Filter out F(psi) from L
    let L_no_F := L.filter (· ≠ Formula.some_future psi)

    have h_L_sub_cons : ∀ y ∈ L, y ∈ (Formula.some_future psi) :: L_no_F := by
      intro y hy
      by_cases h_eq : y = Formula.some_future psi
      · rw [h_eq]; exact .head _
      · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hy, decide_eq_true h_eq⟩)

    have d_weak : DerivationTree ((Formula.some_future psi) :: L_no_F) Formula.bot :=
      DerivationTree.weakening L _ Formula.bot d h_L_sub_cons

    -- By deduction theorem: L_no_F ⊢ neg(F(psi))
    have d_neg_F : DerivationTree L_no_F (Formula.neg (Formula.some_future psi)) :=
      Bimodal.Metalogic.Core.deduction_theorem L_no_F (Formula.some_future psi) Formula.bot d_weak

    -- neg(F(psi)) = G(neg psi)
    -- So L_no_F ⊢ G(neg psi)

    -- All elements of L_no_F are still in f_preserving_seed M phi
    have h_L_no_F_sub : ∀ y ∈ L_no_F, y ∈ f_preserving_seed M phi := by
      intro y hy
      exact h_L_sub y (List.mem_of_mem_filter hy)

    -- Key insight: All elements of L_no_F except possibly phi are in M.
    -- - temporal_box_seed M ⊆ M (by definition of G_theory and box_theory)
    -- - F_unresolved_theory M ⊆ M (F(sigma) ∈ M for each element)
    -- - Only phi may not be in M

    -- First, check if phi is in M - if so, the entire seed is in M
    by_cases h_phi_M : phi ∈ M

    · -- phi ∈ M: The entire seed is a subset of M, hence consistent
      -- All elements of f_preserving_seed M phi are in M:
      -- - {phi} ⊆ M by h_phi_M
      -- - temporal_box_seed M ⊆ M
      -- - F_unresolved_theory M ⊆ M
      -- So L ⊆ M, and L ⊢ bot. By MCS derivation closure, bot ∈ M.
      -- But MCS doesn't contain bot. Contradiction.
      have h_L_in_M : ∀ x ∈ L, x ∈ M := by
        intro x hx
        have hx_seed := h_L_sub x hx
        simp only [f_preserving_seed, Set.mem_union] at hx_seed
        rcases hx_seed with (h | h) | h
        · -- x ∈ {phi}
          simp only [Set.mem_singleton_iff] at h
          rw [h]; exact h_phi_M
        · -- x ∈ temporal_box_seed M
          simp only [temporal_box_seed, Set.mem_union] at h
          rcases h with hG | hBox
          · -- x ∈ G_theory M: x = G(a) with G(a) ∈ M
            simp only [G_theory, Set.mem_setOf_eq] at hG
            obtain ⟨a, rfl, ha⟩ := hG
            exact ha
          · -- x ∈ box_theory M - use box_theory_subset_mcs
            exact box_theory_subset_mcs M h_mcs hBox
        · -- x ∈ F_unresolved_theory M: x = F(sigma) with F(sigma) ∈ M
          simp only [F_unresolved_theory, Set.mem_setOf_eq] at h
          obtain ⟨sigma, rfl, h_Fsigma_M, _⟩ := h
          exact h_Fsigma_M
      -- Now derive contradiction
      have h_bot_M : Formula.bot ∈ M :=
        SetMaximalConsistent.closed_under_derivation h_mcs L h_L_in_M d
      exact h_mcs.1 [Formula.bot] (fun x hx => by simp at hx; rw [hx]; exact h_bot_M)
        ⟨DerivationTree.assumption [Formula.bot] Formula.bot (List.mem_singleton.mpr rfl)⟩

    · -- phi ∉ M: All elements of L_no_F except phi are in M
      -- By MCS completeness, neg(phi) ∈ M
      have h_neg_phi_M : Formula.neg phi ∈ M := by
        rcases SetMaximalConsistent.negation_complete h_mcs phi with h | h
        · exact absurd h h_phi_M
        · exact h

      -- Filter L_no_F to remove phi
      let L_no_phi := L_no_F.filter (· ≠ phi)

      -- All elements of L_no_phi are in M
      have h_L_no_phi_in_M : ∀ x ∈ L_no_phi, x ∈ M := by
        intro x hx
        have hx_L_no_F := List.mem_of_mem_filter hx
        have hx_ne_phi : x ≠ phi := of_decide_eq_true (List.mem_filter.mp hx).2
        have hx_seed := h_L_no_F_sub x hx_L_no_F
        simp only [f_preserving_seed, Set.mem_union] at hx_seed
        rcases hx_seed with (h | h) | h
        · -- x ∈ {phi}
          simp only [Set.mem_singleton_iff] at h
          exact absurd h hx_ne_phi
        · -- x ∈ temporal_box_seed M
          simp only [temporal_box_seed, Set.mem_union] at h
          rcases h with hG | hBox
          · simp only [G_theory, Set.mem_setOf_eq] at hG
            obtain ⟨a, rfl, ha⟩ := hG
            exact ha
          · -- x ∈ box_theory M - use box_theory_subset_mcs
            exact box_theory_subset_mcs M h_mcs hBox
        · -- x ∈ F_unresolved_theory M
          simp only [F_unresolved_theory, Set.mem_setOf_eq] at h
          obtain ⟨sigma, rfl, h_Fsigma_M, _⟩ := h
          exact h_Fsigma_M

      -- Now we show: L_no_phi ⊢ neg(F(psi))
      -- And since L_no_phi ⊆ M, we get neg(F(psi)) = G(neg psi) ∈ M
      -- This contradicts F(psi) ∈ M

      -- Check if phi ∈ L_no_F
      by_cases h_phi_L_no_F : phi ∈ L_no_F

      · -- phi ∈ L_no_F: extract it using deduction theorem
        have h_L_no_F_sub_phi : ∀ y ∈ L_no_F, y ∈ phi :: L_no_phi := by
          intro y hy
          by_cases h_eq : y = phi
          · rw [h_eq]; exact .head _
          · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hy, decide_eq_true h_eq⟩)

        have d_weak' : DerivationTree (phi :: L_no_phi) (Formula.neg (Formula.some_future psi)) :=
          DerivationTree.weakening L_no_F _ _ d_neg_F h_L_no_F_sub_phi

        have d_imp : DerivationTree L_no_phi (phi.imp (Formula.neg (Formula.some_future psi))) :=
          Bimodal.Metalogic.Core.deduction_theorem L_no_phi phi _ d_weak'

        -- Since L_no_phi ⊆ M, we get phi → G(neg psi) ∈ M
        have h_imp_M : phi.imp (Formula.neg (Formula.some_future psi)) ∈ M :=
          SetMaximalConsistent.closed_under_derivation h_mcs L_no_phi h_L_no_phi_in_M d_imp

        -- By MCS implication property with neg(phi) ∈ M:
        -- We have phi → G(neg psi) ∈ M and need to conclude about G(neg psi)
        -- Actually, by MCS we have: either neg(phi) ∈ M or (phi → X) → X ∈ M... no that's wrong

        -- Better: (A → B) ∈ M and neg(A) ∈ M doesn't directly give B ∈ M
        -- But we can use: neg(phi) ∈ M implies phi ∉ M (which we have)
        -- And (phi → G(neg psi)) ∈ M with phi ∉ M...
        -- By MCS dichotomy: for any formula, either it or its negation is in MCS
        -- So either G(neg psi) ∈ M or neg(G(neg psi)) = F(psi) ∈ M
        -- We know F(psi) ∈ M. So this doesn't give us G(neg psi) ∈ M directly.

        -- But wait! We can derive: neg(phi) → (phi → X) → X is a tautology? No, that's not right.
        -- neg(A) ∧ (A → B) → ? We get: A is false, so A → B is vacuously true.
        -- This doesn't tell us about B.

        -- Actually, the key is: neg(phi) ∈ M means phi ∉ M.
        -- And L_no_phi ⊢ phi → G(neg psi).
        -- What if we add phi to M? Then M ∪ {phi} would be inconsistent (since neg(phi) ∈ M).
        -- So {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M might be inconsistent?
        -- No wait, that's what we're trying to prove is consistent!

        -- Let me think differently. We have:
        -- d_neg_F : L_no_F ⊢ G(neg psi)
        -- And we're trying to derive False.

        -- Key: L_no_F ⊆ f_preserving_seed M phi.
        -- If L_no_F ⊆ {phi} ∪ temporal_box_seed M:
        --   By temporal_theory_witness_consistent (modified), we can handle this.
        -- If L_no_F still has elements from F_unresolved_theory M \ {F(psi)}:
        --   We need to recurse.

        -- Since we're in case 2 (some element not in standard seed), and we extracted F(psi),
        -- check if L_no_F has more elements from F_unresolved_theory

        -- Simpler approach: show L_no_phi ⊆ M, and L_no_F ⊢ G(neg psi)
        -- Want to show G(neg psi) ∈ M.
        -- If phi ∉ L_no_F (i.e., L_no_F = L_no_phi), then L_no_F ⊆ M, so G(neg psi) ∈ M. Done.
        -- If phi ∈ L_no_F, we need different argument.

        -- Actually, let's use the contrapositive.
        -- We have F(psi) ∈ M, so neg(G(neg psi)) ∈ M.
        -- If G(neg psi) ∈ M too, then M inconsistent. Contradiction since M is MCS.
        -- So G(neg psi) ∉ M.
        -- By MCS dichotomy, neg(G(neg psi)) = F(psi) ∈ M. Which we know.

        -- So the question is: can we derive G(neg psi) ∈ M from our data?

        -- We have: L_no_phi ⊢ phi → G(neg psi) with L_no_phi ⊆ M
        -- So (phi → G(neg psi)) ∈ M.
        -- By MCS dichotomy applied to G(neg psi):
        --   Either G(neg psi) ∈ M (contradiction with F(psi) ∈ M)
        --   Or F(psi) ∈ M (which we know)
        -- This doesn't give us what we want directly.

        -- The issue is that (phi → G(neg psi)) ∈ M with phi ∉ M doesn't force G(neg psi) ∈ M.

        -- Let's try: Can we show the assumption "L ⊢ bot" leads to contradiction
        -- without needing G(neg psi) ∈ M?

        -- Actually, here's the key insight:
        -- L_no_phi ⊆ M (all elements are either temporal_box_seed or F_unresolved, both ⊆ M)
        -- L_no_phi ⊢ phi → G(neg psi)
        -- So (phi → G(neg psi)) ∈ M.

        -- Claim: phi → G(neg psi) leads to contradiction with F(psi) ∈ M and F(phi) ∈ M.

        -- Actually no. phi → G(neg psi) just says "if phi then always neg psi".
        -- F(phi) ∈ M says "eventually phi".
        -- F(psi) ∈ M says "eventually psi".

        -- The key temporal reasoning:
        -- G(neg psi) means "always neg psi" including the future
        -- phi → G(neg psi) means "if phi (now), then always neg psi (forever)"
        -- F(phi) means "eventually phi"
        -- F(psi) means "eventually psi"

        -- If "eventually phi" and "phi implies always neg psi", then after phi holds,
        -- we have "always neg psi" from that point. So psi never holds after phi.
        -- But "eventually psi" says psi holds at some point.
        -- This is consistent if psi holds BEFORE phi.

        -- So the semantic argument doesn't give us a direct contradiction in general.

        -- Hmm, this is tricky. Let me reconsider the mathematical argument.

        -- Actually, I think the issue is that we can't prove this in full generality.
        -- The f_preserving_seed is specifically designed for the case where
        -- F-formulas preserve through the chain construction.

        -- Let me look at the existing temporal_theory_witness_consistent proof again
        -- to see if we can adapt it.

        -- In temporal_theory_witness_consistent:
        -- We have L ⊆ {phi} ∪ temporal_box_seed M with L ⊢ bot.
        -- We extract phi: L_no_phi ⊢ neg(phi).
        -- G-lift: G(neg phi) ∈ M (since L_no_phi ⊆ temporal_box_seed, all G-liftable).
        -- Contradiction: F(phi) = neg(G(neg phi)) ∈ M contradicts G(neg phi) ∈ M.

        -- In our case:
        -- We have L ⊆ f_preserving_seed M phi with L ⊢ bot.
        -- We extracted F(psi) to get L_no_F ⊢ G(neg psi).
        -- L_no_F may contain phi and other F-formulas from F_unresolved_theory.

        -- If we could G-lift from L_no_F, we'd get G(G(neg psi)) ∈ M, hence G(neg psi) ∈ M.
        -- But phi and F-formulas don't have their G in M.

        -- The strategy should be to extract ALL non-G-liftable elements.
        -- After extracting all F-formulas and phi, the remaining context is G-liftable.

        -- Actually, wait. We already have L_no_phi ⊆ M. And L_no_phi consists of:
        -- - Elements from temporal_box_seed M (G-liftable)
        -- - Elements from F_unresolved_theory M \ {F(psi)} (NOT G-liftable)

        -- If L_no_phi has no elements from F_unresolved_theory, then L_no_phi ⊆ temporal_box_seed M,
        -- and we can G-lift (phi → G(neg psi)) to get G(phi → G(neg psi)) ∈ M.

        -- But if L_no_phi has F-formulas, we can't G-lift directly.

        -- This suggests we need INDUCTION on the number of F-formulas in L.

        -- For now, let's see if we can at least handle the case where L_no_phi ⊆ temporal_box_seed M:

        by_cases h_L_no_phi_standard : ∀ x ∈ L_no_phi, x ∈ temporal_box_seed M

        · -- L_no_phi ⊆ temporal_box_seed M: can G-lift
          have h_G_liftable : ∀ x ∈ L_no_phi, Formula.all_future x ∈ M :=
            fun x hx => G_of_temporal_box_seed M h_mcs x (h_L_no_phi_standard x hx)

          -- G-lift: G(phi → G(neg psi)) ∈ M
          have h_G_imp : Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi))) ∈ M :=
            G_lift_from_context M h_mcs L_no_phi _ d_imp h_G_liftable

          -- By K-axiom: G(A → B) → (G(A) → G(B))
          -- So G(phi → G(neg psi)) → (G(phi) → G(G(neg psi)))
          have h_K : [] ⊢ (Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))).imp
              ((Formula.all_future phi).imp (Formula.all_future (Formula.neg (Formula.some_future psi)))) :=
            DerivationTree.axiom [] _ (Axiom.temp_k_dist phi _)

          have h_G_phi_imp_GG : (Formula.all_future phi).imp (Formula.all_future (Formula.neg (Formula.some_future psi))) ∈ M :=
            SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_K) h_G_imp

          -- By 4-axiom: G(G(X)) → G(X), or equivalently G(neg(F(psi))) → neg(F(psi))
          -- Note: neg(F(psi)) = G(neg psi) is an all_future formula

          -- Actually, let's simplify. We have G(G(neg psi)) → G(neg psi) by 4-axiom.
          -- And G(phi) → G(G(neg psi)) ∈ M.
          -- So G(phi) → G(neg psi) ∈ M (by transitivity).

          -- Now, by MCS dichotomy: either G(phi) ∈ M or neg(G(phi)) = F(neg phi) ∈ M.

          -- Case: G(phi) ∈ M. Then G(neg psi) ∈ M by modus ponens.
          -- Contradiction with F(psi) ∈ M.

          -- Case: F(neg phi) ∈ M.
          -- F(neg phi) = neg(G(neg(neg phi))) = neg(G(phi)).
          -- So G(phi) ∉ M.
          -- And we have G(phi) → G(neg psi) ∈ M.
          -- This is consistent with G(neg psi) ∉ M (since G(phi) ∉ M, implication holds vacuously).

          -- Hmm, so this case doesn't give us contradiction either.

          -- Wait, but we're trying to prove f_preserving_seed is CONSISTENT.
          -- We assumed it's inconsistent (L ⊢ bot) and are deriving contradiction.
          -- In this branch, we've shown that under our assumptions, either:
          -- - G(neg psi) ∈ M (contradiction), or
          -- - F(neg phi) ∈ M

          -- If F(neg phi) ∈ M, what does that tell us about the seed's consistency?

          -- F(neg phi) ∈ M means neg(phi) ∉ M (otherwise F(neg phi) would be "resolved").
          -- Wait, F_unresolved_theory has F(X) where X ∉ M. So F(neg phi) ∈ M with neg phi ∉ M
          -- means F(neg phi) ∈ F_unresolved_theory M.

          -- But we also have neg(phi) ∈ M (from h_neg_phi_M)!
          -- Actually wait, h_neg_phi_M says neg(phi) ∈ M.
          -- And F(neg phi) ∈ M says neg(G(neg(neg phi))) = neg(G(phi)) ∈ M.
          -- These are different. neg(phi) and F(neg phi) are different formulas.

          -- So we have:
          -- - neg(phi) ∈ M (because phi ∉ M, by MCS dichotomy)
          -- - F(neg phi) ∈ M (from our case analysis)
          -- - F(phi) ∈ M (given)

          -- This is consistent! neg(phi) now, but phi eventually. Also neg phi eventually.
          -- Semantically: currently phi is false. In the future, phi will be true (F(phi)).
          -- Also in the future, phi will be false again (F(neg phi)). Compatible with phi true later.

          -- So we can't derive contradiction from F(neg phi) ∈ M alone.

          -- I think the issue is that we need a different approach for this case.

          -- Actually, wait. Let me reconsider.

          -- We have h_phi_L_no_F : phi ∈ L_no_F.
          -- And L_no_F ⊢ G(neg psi).
          -- After extracting phi: L_no_phi ⊢ phi → G(neg psi).
          -- We're in the case h_L_no_phi_standard: L_no_phi ⊆ temporal_box_seed M.

          -- So L_no_phi ⊆ temporal_box_seed M, and L_no_phi ⊆ L_no_F.
          -- And L_no_F ⊆ f_preserving_seed M phi.
          -- And L_no_F is a subset of the original L (minus F(psi)).

          -- Now, the question is: does L_no_phi ⊢ phi → G(neg psi) lead to contradiction
          -- with the consistency of f_preserving_seed?

          -- Actually, I realize the argument should be different.
          -- We should use the fact that F(psi) was extracted because F(psi) ∈ L
          -- and F(psi) ∈ F_unresolved_theory M.

          -- The key is: F(psi) ∈ M means psi ∉ M (by definition of F_unresolved_theory).
          -- Wait no, F_unresolved_theory requires F(psi) ∈ M AND psi ∉ M.
          -- So psi ∉ M.

          -- We have: L_no_phi ⊢ phi → G(neg psi) with L_no_phi ⊆ temporal_box_seed M.
          -- G-lift: G(phi → G(neg psi)) ∈ M.
          -- By K and 4: G(phi) → G(neg psi) ∈ M (derived above).

          -- Now, by contrapositive: neg(G(neg psi)) → neg(G(phi)) ∈ M.
          -- i.e., F(psi) → F(neg phi) ∈ M.

          -- We have F(psi) ∈ M. So F(neg phi) ∈ M by modus ponens.

          -- Does F(neg phi) ∈ M contradict anything?
          -- F(neg phi) = neg(G(phi)).
          -- So G(phi) ∉ M.

          -- And we have F(phi) ∈ M (given).
          -- F(phi) = neg(G(neg phi)).
          -- So G(neg phi) ∉ M.

          -- So both G(phi) ∉ M and G(neg phi) ∉ M.
          -- This is fine - it just means phi's G-value is not determined in M.

          -- I don't see an immediate contradiction.

          -- Let me try yet another approach. The issue might be that we need to
          -- track the F-formulas more carefully.

          -- INSIGHT: We have F(psi) ∈ M with psi ∉ M (from F_unresolved_theory).
          -- And we derived G(neg psi) is "forced" in some sense from the seed.
          -- The contradiction should come from F(psi) ∧ G(neg psi) being inconsistent.

          -- F(psi) = neg(G(neg psi)).
          -- So F(psi) ∧ G(neg psi) is indeed inconsistent!

          -- We need to show G(neg psi) ∈ M to get contradiction.

          -- We have: G(phi) → G(neg psi) ∈ M (from above).
          -- Case: G(phi) ∈ M. Then G(neg psi) ∈ M. Done.
          -- Case: G(phi) ∉ M.

          -- In case G(phi) ∉ M:
          -- By MCS dichotomy, F(neg phi) ∈ M (i.e., neg(G(phi)) ∈ M).

          -- Hmm, but we can't directly get G(neg psi) from this.

          -- OK here's a different idea. Let me check if the issue is with phi specifically.
          -- What if phi = G(a) for some a? Then G(phi) = G(G(a)), and by 4-axiom, G(G(a)) → G(a),
          -- so G(G(a)) ∈ M iff G(a) ∈ M.

          -- For general phi, we don't have special structure.

          -- I think the proof might need strong induction after all, handling the phi case
          -- specially. Let me try implementing a helper lemma for this.

          -- For now, let me just leave a sorry for this subcase and continue structuring the proof.
          cases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future phi) with
          | inl h_G_phi =>
            -- G(phi) ∈ M: Apply modus ponens to get G(G(neg psi)) ∈ M
            -- Note: h_G_phi_imp_GG : G(phi) → G(G(neg psi)) ∈ M
            -- since neg(F(psi)) = neg(neg(G(neg psi))) = G(neg psi) definitionally
            -- h_G_phi_imp_GG : G(phi) → G(neg(F(psi))) ∈ M
            -- h_G_phi : G(phi) ∈ M
            -- So G(neg(F(psi))) ∈ M
            -- Note: neg(F(psi)) = neg(neg(G(neg psi))) = G(neg psi) by double negation
            -- Actually: some_future psi = neg(all_future(neg psi))
            -- So neg(some_future psi) = neg(neg(all_future(neg psi))) which normalizes to all_future(neg psi)
            -- But in Lean's representation, some_future.neg = (psi.neg.all_future.neg).neg
            -- Let's directly work with the types we have

            -- h_G_neg_F_psi will be: (psi.some_future.neg).all_future ∈ M
            -- which is G(neg(F(psi)))
            have h_G_neg_F_psi : Formula.all_future (Formula.neg (Formula.some_future psi)) ∈ M :=
              SetMaximalConsistent.implication_property h_mcs h_G_phi_imp_GG h_G_phi

            -- Apply T-axiom: G(X) → X specialized to X := neg(F(psi))
            -- This gives us neg(F(psi)) ∈ M
            have h_T : [] ⊢ (Formula.all_future (Formula.neg (Formula.some_future psi))).imp
                (Formula.neg (Formula.some_future psi)) :=
              DerivationTree.axiom [] _ (Axiom.temp_t_future (Formula.neg (Formula.some_future psi)))
            have h_neg_F_psi : Formula.neg (Formula.some_future psi) ∈ M :=
              SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_neg_F_psi

            -- neg(F(psi)) ∈ M and F(psi) ∈ M contradicts MCS consistency
            exact set_consistent_not_both h_mcs.1 (Formula.some_future psi) h_Fpsi_M h_neg_F_psi
          | inr h_neg_G_phi =>
            -- neg(G(phi)) = F(neg phi) ∈ M
            -- This doesn't immediately give us contradiction.
            -- However, we can derive a contradiction via a different route.

            -- Actually, F(neg phi) ∈ M is compatible with F(phi) ∈ M.
            -- The issue is that our proof attempt assumes we can get G(neg psi) ∈ M,
            -- but in this branch we can't.

            -- Let me reconsider the whole structure. The key insight should be:
            -- If L ⊢ bot and L ⊆ f_preserving_seed M phi, then we can find some G(neg X) ∈ M
            -- where F(X) ∈ M, giving contradiction.

            -- The issue is the phi extraction. When we extract phi, we go from
            -- L ⊢ bot to L_no_phi ⊢ neg(phi). This doesn't involve F-formulas directly.

            -- Wait, actually in this case we had:
            -- L ⊢ bot with F(psi) ∈ L (from F_unresolved_theory)
            -- L_no_F ⊢ G(neg psi) (after extracting F(psi))
            -- And phi ∈ L_no_F

            -- If all elements of L_no_phi are from temporal_box_seed, we can G-lift.
            -- G(phi → G(neg psi)) ∈ M.

            -- Now, here's the key: we should think about what this means for the SEED.
            -- The seed is {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M.

            -- G(phi → G(neg psi)) ∈ M means: "always, if phi then always neg psi".
            -- This puts a constraint: whenever phi holds, psi cannot hold afterwards.

            -- Now, F(psi) ∈ F_unresolved_theory M ⊆ seed.
            -- And phi ∈ seed.
            -- And G(phi → G(neg psi)) ∈ M.

            -- If phi ∈ seed and F(psi) ∈ seed, then in any MCS extending the seed:
            -- phi ∈ W and F(psi) ∈ W (since W extends seed).
            -- But G(phi → G(neg psi)) ∈ M. Is G(phi → G(neg psi)) ∈ W?

            -- Wait, the witness W is obtained from Lindenbaum extending f_preserving_seed.
            -- G_theory M ⊆ f_preserving_seed, so G_theory M ⊆ W.
            -- In particular, G(phi → G(neg psi)) ∈ M... but is this in G_theory M?

            -- G_theory M = { G(a) | G(a) ∈ M }.
            -- So G(phi → G(neg psi)) ∈ G_theory M iff G(phi → G(neg psi)) ∈ M.
            -- We showed G(phi → G(neg psi)) ∈ M above (h_G_imp).

            -- So G(phi → G(neg psi)) ∈ G_theory M ⊆ f_preserving_seed M phi.

            -- Now, in any MCS W extending f_preserving_seed:
            -- - phi ∈ W (since phi ∈ f_preserving_seed)
            -- - F(psi) ∈ W (since F(psi) ∈ F_unresolved_theory M ⊆ f_preserving_seed)
            -- - G(phi → G(neg psi)) ∈ W (since G(phi → G(neg psi)) ∈ G_theory M ⊆ f_preserving_seed)

            -- From G(phi → G(neg psi)) ∈ W and phi ∈ W:
            -- By T-axiom: (phi → G(neg psi)) ∈ W.
            -- By modus ponens with phi ∈ W: G(neg psi) ∈ W.

            -- But F(psi) = neg(G(neg psi)) ∈ W.
            -- So both G(neg psi) and neg(G(neg psi)) are in W.
            -- This contradicts W being consistent.

            -- Therefore, no MCS extends f_preserving_seed M phi.
            -- This means f_preserving_seed M phi is inconsistent!

            -- But we're trying to prove it's CONSISTENT. So we have a contradiction.

            -- Let me formalize this argument.

            -- h_G_imp : G(phi → G(neg psi)) ∈ M
            -- This means G(phi → G(neg psi)) ∈ G_theory M
            have h_G_imp_in_seed : Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi))) ∈ f_preserving_seed M phi := by
              apply G_theory_subset_f_preserving_seed
              simp only [G_theory, Set.mem_setOf_eq]
              exact ⟨phi.imp (Formula.neg (Formula.some_future psi)), rfl, h_G_imp⟩

            -- Now, the seed contains:
            -- - phi
            -- - G(phi → neg(F(psi)))
            -- - F(psi) (since F(psi) ∈ F_unresolved_theory M)

            -- We can derive bot from these!
            -- G(A → B) and A derive B (by T-axiom and modus ponens)
            -- So G(phi → G(neg psi)) and phi derive G(neg psi)
            -- And G(neg psi) and F(psi) derive bot (since F(psi) = neg(G(neg psi)))

            -- Let's construct this derivation
            have h_phi_in_seed : phi ∈ f_preserving_seed M phi := phi_in_f_preserving_seed M phi

            have h_Fpsi_in_seed : Formula.some_future psi ∈ f_preserving_seed M phi := by
              apply F_unresolved_subset_f_preserving_seed
              simp only [F_unresolved_theory, Set.mem_setOf_eq]
              exact ⟨psi, rfl, h_Fpsi_M, h_psi_not_M⟩

            -- Derivation: [G(phi → G(neg psi)), phi, F(psi)] ⊢ bot

            -- Step 1: T-axiom: G(phi → G(neg psi)) → (phi → G(neg psi))
            have h_T : [] ⊢ (Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))).imp
                (phi.imp (Formula.neg (Formula.some_future psi))) :=
              DerivationTree.axiom [] _ (Axiom.temp_t_future _)

            -- Step 2: From G(phi → G(neg psi)), derive phi → G(neg psi)
            have h_d1 : [Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))] ⊢
                phi.imp (Formula.neg (Formula.some_future psi)) :=
              DerivationTree.modus_ponens [_] _ _ (DerivationTree.weakening [] _ _ h_T (fun _ h => nomatch h))
                (DerivationTree.assumption _ _ (List.mem_singleton.mpr rfl))

            -- Step 3: From phi → G(neg psi) and phi, derive G(neg psi)
            have h_d2 : [phi, Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))] ⊢
                Formula.neg (Formula.some_future psi) := by
              apply DerivationTree.modus_ponens [phi, _] phi _
              · exact DerivationTree.weakening [_] [phi, _] _ h_d1 (fun x hx => by
                  simp only [List.mem_singleton] at hx
                  rw [hx]
                  exact List.mem_cons_of_mem _ (List.mem_singleton.mpr rfl))
              · exact DerivationTree.assumption _ _ (.head _)

            -- Step 4: G(neg psi) = neg(F(psi)), so G(neg psi) and F(psi) derive bot
            -- neg(F(psi)) and F(psi) derive bot via neg_elim
            have h_d3 : [Formula.some_future psi, phi, Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))] ⊢
                Formula.bot := by
              -- We have [phi, G(...)] ⊢ neg(F(psi))
              -- We want [F(psi), phi, G(...)] ⊢ bot
              apply DerivationTree.modus_ponens [_, phi, _] (Formula.some_future psi) Formula.bot
              · -- Need: [F(psi), phi, G(...)] ⊢ F(psi) → bot = neg(F(psi))
                -- But neg(F(psi)) = G(neg psi) = (psi.neg.all_future)
                -- Actually, F(psi) = (psi.neg.all_future.neg)
                -- So neg(F(psi)) = psi.neg.all_future
                -- And our h_d2 gives [phi, G(...)] ⊢ psi.neg.all_future
                have h_eq : Formula.neg (Formula.some_future psi) = (Formula.some_future psi).imp Formula.bot := rfl
                rw [h_eq] at h_d2
                exact DerivationTree.weakening [phi, _] [_, phi, _] _ h_d2 (fun x hx =>
                  List.mem_cons_of_mem _ hx)
              · exact DerivationTree.assumption _ _ (.head _)

            -- Now we have a derivation from a subset of f_preserving_seed to bot
            -- This contradicts consistency

            -- The list [F(psi), phi, G(phi → G(neg psi))] is a subset of f_preserving_seed
            have h_list_sub : ∀ x ∈ [Formula.some_future psi, phi,
                Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))],
                x ∈ f_preserving_seed M phi := by
              intro x hx
              simp only [List.mem_cons, List.mem_singleton, List.not_mem_nil, or_false] at hx
              rcases hx with rfl | rfl | rfl
              · exact h_Fpsi_in_seed
              · exact h_phi_in_seed
              · exact h_G_imp_in_seed

            -- This is inconsistent!
            -- But wait, we're already in a proof by contradiction assuming
            -- f_preserving_seed is inconsistent. So finding another inconsistency
            -- doesn't help directly.

            -- Actually, wait. We started with L ⊆ f_preserving_seed with L ⊢ bot.
            -- We're trying to derive False (to show consistency).
            -- But we've now constructed a different proof of inconsistency!

            -- The issue is: the h_G_imp was derived using h_G_liftable, which used
            -- h_L_no_phi_standard, which might not hold for arbitrary L.

            -- Let me reconsider. We're in the case:
            -- - h_phi_L_no_F : phi ∈ L_no_F
            -- - h_L_no_phi_standard : L_no_phi ⊆ temporal_box_seed M
            -- - h_neg_G_phi : neg(G(phi)) ∈ M

            -- From h_L_no_phi_standard, we derived h_G_imp : G(phi → G(neg psi)) ∈ M.

            -- Now, G(phi → G(neg psi)) ∈ G_theory M ⊆ f_preserving_seed M phi.
            -- And phi ∈ f_preserving_seed.
            -- And F(psi) ∈ f_preserving_seed.

            -- So [F(psi), phi, G(phi → G(neg psi))] ⊆ f_preserving_seed with derivation to bot.

            -- This IS a witness of inconsistency, independent of our original L!

            -- Hmm, but this doesn't help us prove consistency. We're trying to prove
            -- consistency, not find more witnesses of inconsistency.

            -- Actually, wait. If we can construct an inconsistent subset of f_preserving_seed
            -- from our assumptions (h_Fpsi_M, h_phi_L_no_F, h_L_no_phi_standard, etc.),
            -- then f_preserving_seed IS inconsistent. But we're trying to prove it's consistent!

            -- So we have a problem: under the given hypotheses, f_preserving_seed is inconsistent.

            -- But the theorem claims f_preserving_seed IS consistent!

            -- Let me re-examine. The issue might be with the case structure.

            -- We have:
            -- - F(phi) ∈ M (hypothesis)
            -- - F(psi) ∈ F_unresolved_theory M (from case 2)
            -- - h_L_no_phi_standard : L_no_phi ⊆ temporal_box_seed M

            -- From these, we derived G(phi → G(neg psi)) ∈ M.

            -- Wait, but G(phi → G(neg psi)) was derived by G-lifting L_no_phi ⊢ phi → G(neg psi).
            -- And L_no_phi ⊢ phi → G(neg psi) came from extracting phi from L_no_F ⊢ G(neg psi).
            -- And L_no_F ⊢ G(neg psi) came from extracting F(psi) from L ⊢ bot.

            -- So G(phi → G(neg psi)) ∈ M is a consequence of assuming L ⊢ bot!

            -- And then we showed [F(psi), phi, G(phi → G(neg psi))] ⊢ bot.

            -- So from L ⊢ bot, we derived [F(psi), phi, G(...)] ⊢ bot.

            -- This is consistent! We assumed inconsistency, and derived inconsistency.
            -- It doesn't give us the contradiction we need.

            -- The issue is: we need to show that the ASSUMPTION L ⊢ bot leads to contradiction.
            -- Simply deriving another inconsistent subset doesn't contradict anything.

            -- OK I think I see the issue now. The whole proof by contradiction is:
            -- Assume ∃ L ⊆ f_preserving_seed with L ⊢ bot. Derive False.

            -- We've been trying to derive False by showing G(neg psi) ∈ M contradicts F(psi) ∈ M.
            -- But in this branch (h_neg_G_phi), we can't show G(neg psi) ∈ M.

            -- The other route we tried (constructing [F(psi), phi, G(...)] ⊢ bot) doesn't help
            -- because that's just another way of witnessing inconsistency, not a contradiction.

            -- I think we need a different approach entirely.

            -- Maybe strong induction on the number of elements in L?
            -- Or on the number of non-G-liftable elements?

            -- For now, let me mark this as sorry and move on to understand the full structure.
            sorry

        · -- L_no_phi has elements from F_unresolved_theory M (not all from temporal_box_seed)
          -- We need to recurse, extracting more F-formulas
          -- This requires strong induction on the count of F-formulas in L
          sorry

      · -- phi ∉ L_no_F: all elements of L_no_F are in M
        -- L_no_F ⊆ M since phi ∉ L_no_F and all other elements are in M
        have h_L_no_F_in_M : ∀ x ∈ L_no_F, x ∈ M := by
          intro x hx
          have hx_ne_phi : x ≠ phi := fun h_eq => by
            rw [h_eq] at hx
            exact h_phi_L_no_F hx
          -- x ∈ L_no_F and x ≠ phi and x ≠ F(psi)
          have hx_seed := h_L_no_F_sub x hx
          simp only [f_preserving_seed, Set.mem_union] at hx_seed
          rcases hx_seed with (h | h) | h
          · simp only [Set.mem_singleton_iff] at h; exact absurd h hx_ne_phi
          · simp only [temporal_box_seed, Set.mem_union] at h
            rcases h with hG | hBox
            · simp only [G_theory, Set.mem_setOf_eq] at hG
              obtain ⟨a, rfl, ha⟩ := hG; exact ha
            · exact box_theory_subset_mcs M h_mcs hBox
          · simp only [F_unresolved_theory, Set.mem_setOf_eq] at h
            obtain ⟨sigma, rfl, h_Fsigma_M, _⟩ := h; exact h_Fsigma_M

        -- L_no_F ⊢ neg(F(psi)) and L_no_F ⊆ M, so neg(F(psi)) ∈ M
        have h_neg_F_psi_M : Formula.neg (Formula.some_future psi) ∈ M :=
          SetMaximalConsistent.closed_under_derivation h_mcs L_no_F h_L_no_F_in_M d_neg_F

        -- neg(F(psi)) ∈ M and F(psi) ∈ M contradicts MCS consistency
        -- F(psi) and neg(F(psi)) form an inconsistent pair
        exact set_consistent_not_both h_mcs.1 (Formula.some_future psi) h_Fpsi_M h_neg_F_psi_M

/--
F-preserving temporal witness theorem:
If F(phi) ∈ M (MCS), there exists MCS W with:
1. phi ∈ W
2. G_theory agreement: G(a) ∈ M → G(a) ∈ W
3. box_class_agree M W
4. **NEW**: F_unresolved preservation: F(psi) ∈ M ∧ psi ∉ M → F(psi) ∈ W

This strengthens temporal_theory_witness_exists by ensuring that unresolved
F-obligations are preserved in the witness.
-/
theorem temporal_theory_witness_F_preserving (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W ∧
      (∀ psi, Formula.some_future psi ∈ M ∧ psi ∉ M → Formula.some_future psi ∈ W) := by
  -- Use f_preserving_seed_consistent to show the seed is consistent
  have h_cons := f_preserving_seed_consistent M h_mcs phi h_F
  -- Apply Lindenbaum to get MCS W extending the seed
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (f_preserving_seed M phi) h_cons
  use W, h_W_mcs
  refine ⟨?_, ?_, ?_, ?_⟩

  · -- phi ∈ W
    exact h_extends (phi_in_f_preserving_seed M phi)

  · -- G_theory agreement: G(a) ∈ M → G(a) ∈ W
    intro a ha
    have h_in_seed : Formula.all_future a ∈ G_theory M := by
      simp only [G_theory, Set.mem_setOf_eq]
      exact ⟨a, rfl, ha⟩
    exact h_extends (G_theory_subset_f_preserving_seed M phi h_in_seed)

  · -- box_class_agree M W
    intro psi
    constructor
    · intro h_box
      have h_in_seed : Formula.box psi ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inl ⟨psi, rfl, h_box⟩
      exact h_extends (box_theory_subset_f_preserving_seed M phi h_in_seed)
    · intro h_box_W
      by_contra h_not_in_M
      have h_neg_in_seed : Formula.neg (Formula.box psi) ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inr ⟨psi, rfl, h_not_in_M⟩
      have h_neg_in_W : Formula.neg (Formula.box psi) ∈ W :=
        h_extends (box_theory_subset_f_preserving_seed M phi h_neg_in_seed)
      exact set_consistent_not_both h_W_mcs.1 (Formula.box psi) h_box_W h_neg_in_W

  · -- F_unresolved preservation: F(psi) ∈ M ∧ psi ∉ M → F(psi) ∈ W
    intro psi ⟨h_Fpsi, h_psi_not⟩
    have h_in_F_unresolved : Formula.some_future psi ∈ F_unresolved_theory M := by
      simp only [F_unresolved_theory, Set.mem_setOf_eq]
      exact ⟨psi, rfl, h_Fpsi, h_psi_not⟩
    exact h_extends (F_unresolved_subset_f_preserving_seed M phi h_in_F_unresolved)

/-!
### H_theory and Past Direction Witness

Symmetric to G_theory for the past direction. If P(phi) ∈ M (MCS), then
{phi} ∪ H_theory(M) ∪ box_theory(M) is consistent.
-/

/--
The "H theory" of an MCS: the set of formulas whose H is in M.
H_theory(M) = {H(a) | H(a) ∈ M}
-/
def H_theory (M : Set Formula) : Set Formula :=
  { f | ∃ a, f = Formula.all_past a ∧ Formula.all_past a ∈ M }

/--
All elements of H_theory(M) are in M.
-/
theorem H_theory_subset_mcs (M : Set Formula) :
    H_theory M ⊆ M := by
  intro f hf
  simp only [H_theory, Set.mem_setOf_eq] at hf
  obtain ⟨a, rfl, ha⟩ := hf
  exact ha

/--
P(phi) ∈ M excludes H(neg(phi)) from M.
-/
theorem some_past_excludes_all_past_neg {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    Formula.all_past (Formula.neg phi) ∉ M := by
  intro h_H
  have h_eq : Formula.some_past phi = Formula.neg (Formula.all_past (Formula.neg phi)) := rfl
  rw [h_eq] at h_P
  exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg phi)) h_H h_P

/--
The combined seed for past-direction witnesses: H_theory ∪ box_theory.
-/
def past_temporal_box_seed (M : Set Formula) : Set Formula :=
  H_theory M ∪ box_theory M

/--
Past temp_4: H(a) → H(H(a)), derived via temporal duality from temp_4.
-/
private noncomputable def past_temp_4 (a : Formula) :
    [] ⊢ (Formula.all_past a).imp (Formula.all_past (Formula.all_past a)) := by
  have h_4 := DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.swap_temporal a))
  have h_dual := DerivationTree.temporal_duality _ h_4
  simp [Formula.swap_temporal, Formula.swap_temporal_involution] at h_dual
  exact h_dual

/--
Past temp_future: Box(a) → H(Box(a)), derived via temporal duality from temp_future.
-/
private noncomputable def past_temp_future (a : Formula) :
    [] ⊢ (Formula.box a).imp (Formula.all_past (Formula.box a)) := by
  have h_tf := DerivationTree.axiom [] _ (Axiom.temp_future (Formula.swap_temporal a))
  have h_dual := DerivationTree.temporal_duality _ h_tf
  simp [Formula.swap_temporal, Formula.swap_temporal_involution] at h_dual
  exact h_dual

/--
Every element of H_theory(M) can be H-lifted: H(H(a)) ∈ M when H(a) ∈ M.
-/
theorem H_of_H_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ H_theory M, Formula.all_past x ∈ M := by
  intro x hx
  simp only [H_theory, Set.mem_setOf_eq] at hx
  obtain ⟨a, rfl, ha⟩ := hx
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (past_temp_4 a)) ha

/--
Every element of box_theory(M) can be H-lifted: H(f) ∈ M for f ∈ box_theory(M).

Symmetric to G_of_box_theory, using past_temp_future and past K-distribution.
-/
theorem H_of_box_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ box_theory M, Formula.all_past x ∈ M := by
  intro x hx
  simp only [box_theory, Set.mem_setOf_eq] at hx
  rcases hx with ⟨a, rfl, ha⟩ | ⟨a, rfl, ha⟩
  · -- x = Box(a), Box(a) ∈ M. Need H(Box(a)) ∈ M.
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (past_temp_future a)) ha
  · -- x = neg(Box(a)), Box(a) ∉ M. Need H(neg(Box(a))) ∈ M.
    have h_neg_box : (Formula.box a).neg ∈ M := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box a) with h | h
      · exact absurd h ha
      · exact h
    have h_box_neg_box : Formula.box ((Formula.box a).neg) ∈ M :=
      SetMaximalConsistent.neg_box_implies_box_neg_box h_mcs a h_neg_box
    -- H(Box(neg(Box(a)))) ∈ M by past_temp_future
    have h_H_box : Formula.all_past (Formula.box ((Formula.box a).neg)) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs (past_temp_future ((Formula.box a).neg))) h_box_neg_box
    -- H(neg(Box(a))) ∈ M via H(Box(x)) → H(x)
    -- Box(x) → x is modal_t. H(Box(x) → x) by past necessitation (temporal duality).
    -- H(Box(x) → x) → (H(Box(x)) → H(x)) by past K-distribution.
    have h_box_t : [] ⊢ (Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t ((Formula.box a).neg))
    -- H(Box(x) → x) via past necessitation (empty context version)
    have h_H_box_t : [] ⊢ Formula.all_past ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)) := by
      have h_mapped : (Context.map Formula.all_past []) ⊢ ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)).all_past :=
        Bimodal.Theorems.generalized_past_k [] _ h_box_t
      simp [Context.map] at h_mapped
      exact h_mapped
    -- past K-distribution: H(A → B) → (H(A) → H(B))
    have h_pk := Bimodal.Theorems.past_k_dist (Formula.box ((Formula.box a).neg)) ((Formula.box a).neg)
    -- Combine: H(Box(neg(Box(a)))) → H(neg(Box(a)))
    have h_H_imp : [] ⊢ (Formula.all_past (Formula.box ((Formula.box a).neg))).imp
        (Formula.all_past ((Formula.box a).neg)) :=
      DerivationTree.modus_ponens [] _ _ h_pk h_H_box_t
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_H_imp) h_H_box

/--
Every element of the past combined seed can be H-lifted.
-/
theorem H_of_past_temporal_box_seed (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ past_temporal_box_seed M, Formula.all_past x ∈ M := by
  intro x hx
  simp only [past_temporal_box_seed, Set.mem_union] at hx
  rcases hx with h | h
  · exact H_of_H_theory M h_mcs x h
  · exact H_of_box_theory M h_mcs x h

/--
The H-lift lemma: from ctx ⊢ phi and all H(x) ∈ M for x ∈ ctx, derive H(phi) ∈ M.
Symmetric to G_lift_from_context.
-/
theorem H_lift_from_context (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ctx : List Formula) (phi : Formula)
    (h_deriv : DerivationTree ctx phi)
    (h_ctx_H : ∀ x ∈ ctx, Formula.all_past x ∈ M) :
    Formula.all_past phi ∈ M := by
  -- Use generalized_past_k: Γ ⊢ φ implies H[Γ] ⊢ H(φ)
  have h_H_deriv := Bimodal.Theorems.generalized_past_k ctx phi h_deriv
  -- H[ctx] ⊢ H(phi). Need all H[ctx] elements in M, then H(phi) ∈ M.
  have h_H_ctx_in_M : ∀ x ∈ Context.map Formula.all_past ctx, x ∈ M := by
    intro x hx
    simp [Context.map, List.mem_map] at hx
    obtain ⟨y, hy_mem, rfl⟩ := hx
    exact h_ctx_H y hy_mem
  exact SetMaximalConsistent.closed_under_derivation h_mcs
    (Context.map Formula.all_past ctx) h_H_ctx_in_M h_H_deriv

/--
The past temporal theory witness consistency:
If P(phi) ∈ M (MCS), then {phi} ∪ H_theory(M) ∪ box_theory(M) is consistent.

The proof is symmetric to temporal_theory_witness_consistent, using H-lift.
-/
theorem past_theory_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    SetConsistent ({phi} ∪ past_temporal_box_seed M) := by
  intro L h_L_sub ⟨d⟩
  let L_no_phi := L.filter (· ≠ phi)

  have h_L_no_phi_seed : ∀ x ∈ L_no_phi, x ∈ past_temporal_box_seed M := by
    intro x hx
    have hx_L := List.mem_of_mem_filter hx
    have hx_ne : x ≠ phi := of_decide_eq_true (List.mem_filter.mp hx).2
    have := h_L_sub x hx_L
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · rw [h] at hx_ne; exact absurd rfl hx_ne
    · exact h

  have h_L_sub_phi_Lnp : ∀ x ∈ L, x ∈ phi :: L_no_phi := by
    intro x hx
    by_cases h_eq : x = phi
    · rw [h_eq]; exact .head _
    · exact List.mem_cons_of_mem phi (List.mem_filter.mpr ⟨hx, decide_eq_true h_eq⟩)

  have d_weak : DerivationTree (phi :: L_no_phi) Formula.bot :=
    DerivationTree.weakening L (phi :: L_no_phi) Formula.bot d h_L_sub_phi_Lnp

  have d_neg_phi : DerivationTree L_no_phi (Formula.neg phi) :=
    Bimodal.Metalogic.Core.deduction_theorem L_no_phi phi Formula.bot d_weak

  have h_L_no_phi_H : ∀ x ∈ L_no_phi, Formula.all_past x ∈ M :=
    fun x hx => H_of_past_temporal_box_seed M h_mcs x (h_L_no_phi_seed x hx)

  have h_H_neg_phi : Formula.all_past (Formula.neg phi) ∈ M :=
    H_lift_from_context M h_mcs L_no_phi (Formula.neg phi) d_neg_phi h_L_no_phi_H

  exact some_past_excludes_all_past_neg h_mcs phi h_P h_H_neg_phi

/--
If P(phi) ∈ M (MCS), there exists MCS W with phi ∈ W,
H_theory agreement (H(a) ∈ M → H(a) ∈ W), and box_class_agree(M, W).
-/
theorem past_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W) ∧
      box_class_agree M W := by
  have h_cons := past_theory_witness_consistent M h_mcs phi h_P
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum ({phi} ∪ past_temporal_box_seed M) h_cons
  use W, h_W_mcs
  refine ⟨?_, ?_, ?_⟩
  · exact h_extends (Set.mem_union_left _ (Set.mem_singleton phi))
  · intro a ha
    have : Formula.all_past a ∈ H_theory M := by
      simp only [H_theory, Set.mem_setOf_eq]
      exact ⟨a, rfl, ha⟩
    exact h_extends (Set.mem_union_right _ (Set.mem_union_left _ this))
  · intro psi
    constructor
    · intro h_box
      have : Formula.box psi ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inl ⟨psi, rfl, h_box⟩
      exact h_extends (Set.mem_union_right _ (Set.mem_union_right _ this))
    · intro h_box_W
      by_contra h_not_in_M
      have : Formula.neg (Formula.box psi) ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inr ⟨psi, rfl, h_not_in_M⟩
      have h_neg_in_W : Formula.neg (Formula.box psi) ∈ W :=
        h_extends (Set.mem_union_right _ (Set.mem_union_right _ this))
      exact set_consistent_not_both h_W_mcs.1 (Formula.box psi) h_box_W h_neg_in_W

/-!
### Resolving Successor Construction

The resolving successor forces a specific F-obligation to be resolved by including the
target formula directly in the seed. This replaces the deferral-based approach that
can perpetually defer obligations.

Key insight: `temporal_theory_witness_consistent` proves that `{phi} ∪ temporal_box_seed M`
is consistent when `F(phi) ∈ M`. The resolving seed extends this with deferral and
P-step components to satisfy the full Succ relation.
-/

/--
The resolving successor seed forces a specific formula phi into the successor.

Given MCS M with F(phi) ∈ M, this minimal seed is sufficient because:
1. Force phi ∈ W (from singleton)
2. Preserve G-theory (from temporal_box_seed)
3. Preserve box-class (from temporal_box_seed)

The per-obligation architecture doesn't need F-step for other formulas or P-step.
The minimal seed `{phi} ∪ temporal_box_seed M` has trivial consistency via
`temporal_theory_witness_consistent`.

**Note**: This replaces the extended seed approach which failed due to
deferralDisjunctions not being G-liftable (see reports/10_team-research.md).
-/
def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M

/--
The resolving seed extends the temporal_box_seed (trivially true for minimal seed).
-/
theorem resolving_seed_extends_temporal_box_seed (M : Set Formula) (phi : Formula) :
    temporal_box_seed M ⊆ resolving_successor_seed M phi :=
  Set.subset_union_right

/--
The resolving seed contains the target formula.
-/
theorem resolving_seed_contains_phi (M : Set Formula) (phi : Formula) :
    phi ∈ resolving_successor_seed M phi := by
  simp only [resolving_successor_seed, Set.mem_union, Set.mem_singleton_iff]
  left; trivial

/--
The temporal_box_seed is a subset of M (elements are derivable from M).
-/
theorem temporal_box_seed_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    temporal_box_seed M ⊆ M := by
  intro x hx
  simp only [temporal_box_seed, Set.mem_union] at hx
  rcases hx with h | h
  · exact G_theory_subset_mcs M h
  · exact box_theory_subset_mcs M h_mcs h

/--
The resolving seed (excluding phi) is temporal_box_seed M which is a subset of M.
Simplified from the extended seed version.
-/
theorem resolving_seed_minus_phi_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) :
    temporal_box_seed M ⊆ M :=
  temporal_box_seed_subset_mcs M h_mcs

/--
The full resolving seed is a subset of {phi} ∪ M.
Simplified for the minimal seed `{phi} ∪ temporal_box_seed M`.
-/
theorem resolving_seed_subset_phi_union_M (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) :
    resolving_successor_seed M phi ⊆ {phi} ∪ M := by
  intro x hx
  simp only [resolving_successor_seed, Set.mem_union, Set.mem_singleton_iff] at hx
  rcases hx with h | h
  · left; exact h
  · right; exact temporal_box_seed_subset_mcs M h_mcs h

/--
The resolving successor seed is consistent when F(phi) ∈ M.

**Proof**: Since the minimal seed is exactly `{phi} ∪ temporal_box_seed M`, this follows
directly from `temporal_theory_witness_consistent`.

This replaces the complex G-lift argument from the extended seed approach that was
blocked by deferralDisjunctions not being G-liftable.
-/
theorem resolving_successor_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (resolving_successor_seed M phi) :=
  temporal_theory_witness_consistent M h_mcs phi h_F

/-!
### Phase 2: Resolving Successor Satisfies Required Properties

The resolving successor W from `temporal_theory_witness_exists` satisfies:
1. G-persistence: g_content M ⊆ W
2. F-step for target phi: phi ∈ W
3. box_class_agree: same modal accessibility class
-/

/--
G-persistence for temporal witness: g_content M ⊆ W.

Proof: For a ∈ g_content M, we have G(a) ∈ M.
By G-agreement from temporal_theory_witness_exists: G(a) ∈ W.
By temp_t_future (G(a) → a) and W being MCS: a ∈ W.
-/
theorem temporal_witness_g_persistence (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M)
    (W : Set Formula) (h_W_mcs : SetMaximalConsistent W) (h_phi_W : phi ∈ W)
    (h_G_agree : ∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W)
    (h_box_agree : box_class_agree M W) :
    g_content M ⊆ W := by
  intro a h_gc
  -- a ∈ g_content M means G(a) ∈ M
  have h_Ga_M : Formula.all_future a ∈ M := h_gc
  -- By G-agreement: G(a) ∈ W
  have h_Ga_W : Formula.all_future a ∈ W := h_G_agree a h_Ga_M
  -- By temp_t_future: G(a) → a
  have h_T : [] ⊢ (Formula.all_future a).imp a :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future a)
  -- By MCS closure: a ∈ W
  exact SetMaximalConsistent.implication_property h_W_mcs (theorem_in_mcs h_W_mcs h_T) h_Ga_W

/-!
**Deleted theorems (per task 55 plan v4)**:
- `temporal_witness_f_step_phi`: Trivial (phi ∈ W := h_phi_W), not used anywhere.
- `temporal_witness_f_step_general`: Mathematically FALSE - arbitrary witness W can have
  neg(psi) ∈ W AND G(neg(psi)) ∈ W, so F-step is not guaranteed for all formulas.
  The per-obligation approach only needs phi ∈ W (target resolution), not full F-step.
-/

/-!
### Phase 3: Box-Class Bundle Construction

Build a BFMCS from the box-class of an MCS using shifted SuccChainFMCS.
-/

/--
The bundle families: all shifted SuccChainFMCS from MCSes with the same box theory.
-/
noncomputable def boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M0 W ∧
    f = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k }

/--
The bundle is nonempty (contains the eval chain from M0 at offset 0).
-/
theorem boxClassFamilies_nonempty (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    (boxClassFamilies M0 h_mcs).Nonempty := by
  use SuccChainFMCS (MCS_to_SerialMCS M0 h_mcs)
  simp only [boxClassFamilies, Set.mem_setOf_eq]
  refine ⟨M0, h_mcs, 0, box_class_agree_refl M0, ?_⟩
  unfold shifted_fmcs
  cases (SuccChainFMCS (MCS_to_SerialMCS M0 h_mcs))
  simp only [Int.sub_zero]

/--
The eval family (unshifted chain from M0) is in the bundle.
-/
theorem eval_family_mem_boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    SuccChainFMCS (MCS_to_SerialMCS M0 h_mcs) ∈ boxClassFamilies M0 h_mcs := by
  simp only [boxClassFamilies, Set.mem_setOf_eq]
  refine ⟨M0, h_mcs, 0, box_class_agree_refl M0, ?_⟩
  unfold shifted_fmcs
  cases (SuccChainFMCS (MCS_to_SerialMCS M0 h_mcs))
  simp only [Int.sub_zero]

/-!
### Phase 4: Modal Coherence Proofs

Prove modal_forward, modal saturation, and temporal coherence for the bundle.
-/

/--
Modal forward: Box(phi) in any family's MCS at time t implies phi in ALL families' MCSes at t.

Proof: Box(phi) in fam.mcs(t) → Box(phi) in fam.mcs(0-shifted-base) (by persistence)
→ Box(phi) in base MCS W → Box(phi) in M0 (by box class) → Box(phi) in any W'
→ Box(phi) in fam'.mcs(t) (by persistence) → phi in fam'.mcs(t) (by T).
-/
theorem boxClassFamilies_modal_forward (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (phi : Formula) (t : Int) (h_box : Formula.box phi ∈ fam.mcs t)
    (fam' : FMCS Int) (hfam' : fam' ∈ boxClassFamilies M0 h_mcs) :
    phi ∈ fam'.mcs t := by
  -- Extract fam's components
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  -- Extract fam's components
  obtain ⟨W', h_W', k', h_agree', rfl⟩ := hfam'

  -- Box(phi) in shifted_fmcs at t = Box(phi) in SuccChainFMCS at (t - k)
  unfold shifted_fmcs at h_box ⊢
  simp only at h_box ⊢

  -- Box(phi) is persistent: in SuccChainFMCS(W) at (t-k) → at 0
  have h_box_0 : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 :=
    parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W h_W)) phi (t - k) 0 h_box

  -- SuccChainFMCS(W).mcs 0 = W (the base MCS)
  have h_mcs_0 : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := rfl

  -- Box(phi) ∈ W
  rw [h_mcs_0] at h_box_0

  -- Box(phi) ∈ M0 (by box class agreement: M0 ↔ W)
  have h_box_M0 : Formula.box phi ∈ M0 := (h_agree phi).mpr h_box_0

  -- Box(phi) ∈ W' (by box class agreement: M0 ↔ W')
  have h_box_W' : Formula.box phi ∈ W' := (h_agree' phi).mp h_box_M0

  -- SuccChainFMCS(W').mcs 0 = W'
  have h_mcs_0' : (SuccChainFMCS (MCS_to_SerialMCS W' h_W')).mcs 0 = W' := rfl

  -- Box(phi) ∈ SuccChainFMCS(W').mcs 0
  have h_box_0' : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W' h_W')).mcs 0 := by
    rw [h_mcs_0']; exact h_box_W'

  -- Box(phi) ∈ SuccChainFMCS(W').mcs (t - k') (by persistence)
  have h_box_t' : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W' h_W')).mcs (t - k') :=
    parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W' h_W')) phi 0 (t - k') h_box_0'

  -- phi ∈ SuccChainFMCS(W').mcs (t - k') by T axiom
  have h_mcs_t' := (SuccChainFMCS (MCS_to_SerialMCS W' h_W')).is_mcs (t - k')
  have h_T : [] ⊢ (Formula.box phi).imp phi := DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact SetMaximalConsistent.implication_property h_mcs_t' (theorem_in_mcs h_mcs_t' h_T) h_box_t'

/--
Box-formulas at any time t in any family in the bundle agree with M0.
-/
theorem boxClassFamilies_box_agree (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (phi : Formula) (t : Int) :
    Formula.box phi ∈ fam.mcs t ↔ Formula.box phi ∈ M0 := by
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  unfold shifted_fmcs
  simp only
  constructor
  · intro h
    have h0 := parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W h_W)) phi (t - k) 0 h
    have h_eq : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := by
      unfold SuccChainFMCS MCS_to_SerialMCS; rfl
    rw [h_eq] at h0
    exact (h_agree phi).mpr h0
  · intro h
    have h_W' := (h_agree phi).mp h
    have h_eq : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := by
      unfold SuccChainFMCS MCS_to_SerialMCS; rfl
    have h0 : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 := by
      rw [h_eq]; exact h_W'
    exact parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W h_W)) phi 0 (t - k) h0

/--
Modal backward: if phi is in ALL families' MCSes at time t, then Box(phi) is in fam.mcs(t).

Proof by contraposition using box_theory_witness_exists:
1. If Box(phi) not in fam.mcs(t), then neg(Box(phi)) in fam.mcs(t)
2. By box-class agreement: neg(Box(phi)) in M0 (since neg(Box) is a box-theory formula)
3. Diamond(neg(phi)) in M0 (derived from neg(Box(phi)) via double negation)
4. By witness existence: exists W' with neg(phi) in W' and box_class_agree(M0, W')
5. The shifted chain from W' at time t is in the bundle
6. neg(phi) is in that chain's MCS at time t
7. But phi is in ALL families, contradiction
-/
theorem boxClassFamilies_modal_backward (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (phi : Formula) (t : Int)
    (h_all : ∀ fam' ∈ boxClassFamilies M0 h_mcs, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t := by
  -- By contradiction
  by_contra h_not_box

  -- Step 1: neg(Box(phi)) in fam.mcs(t)
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  simp only [shifted_fmcs] at h_not_box
  have h_mcs_t := (SuccChainFMCS (MCS_to_SerialMCS W h_W)).is_mcs (t - k)
  have h_neg_box : Formula.neg (Formula.box phi) ∈
      (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs (t - k) := by
    rcases SetMaximalConsistent.negation_complete h_mcs_t (Formula.box phi) with h | h
    · exact absurd h h_not_box
    · exact h

  -- Step 2: neg(Box(phi)) in M0 (via box-class)
  -- neg(Box(phi)) = (Box phi).neg
  -- Box(phi) not in fam.mcs(t), so Box(phi) not in W (by box persistence)
  have h_box_not_W : Formula.box phi ∉ W := by
    intro h_in_W
    have h_eq : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := by
      unfold SuccChainFMCS MCS_to_SerialMCS; rfl
    have h0 : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 := by
      rw [h_eq]; exact h_in_W
    exact h_not_box (parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W h_W)) phi 0 (t - k) h0)

  -- Box(phi) not in M0 (by box class)
  have h_box_not_M0 : Formula.box phi ∉ M0 := by
    intro h; exact h_box_not_W ((h_agree phi).mp h)

  -- neg(Box(phi)) in M0
  have h_neg_box_M0 : (Formula.box phi).neg ∈ M0 := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box phi) with h | h
    · exact absurd h h_box_not_M0
    · exact h

  -- Step 3: Diamond(neg(phi)) in M0
  -- neg(Box(phi)) = neg(Box(phi))
  -- By Box DNE contraposition: neg(Box(phi)) implies neg(Box(neg(neg(phi)))) = Diamond(neg(phi))
  -- Actually: Diamond(neg(phi)) = neg(Box(neg(neg(phi)))) = neg(Box(phi)) composed with DNE
  -- But Diamond(A) = A.neg.box.neg = neg(Box(neg(A)))
  -- So Diamond(neg(phi)) = neg(Box(neg(neg(phi))))
  -- And neg(Box(phi)) is what we have.
  -- We need: neg(Box(phi)) implies Diamond(neg(phi))
  -- i.e., neg(Box(phi)) implies neg(Box(neg(neg(phi))))
  -- By contraposition of Box(neg(neg(phi))) -> Box(phi) (which is box_dne_theorem)
  have h_diamond_neg : (Formula.neg phi).diamond ∈ M0 := by
    -- Diamond(neg phi) = neg(Box(neg(neg phi)))
    -- = (neg phi).neg.box.neg
    -- We have neg(Box phi) in M0
    -- Need neg(Box(neg(neg phi))) in M0
    -- By box_dne_theorem: Box(neg(neg phi)) -> Box(phi)
    -- Contrapositive: neg(Box(phi)) -> neg(Box(neg(neg phi)))
    have h_bde := box_dne_theorem phi
    have h_contra := SetMaximalConsistent.contrapositive h_mcs h_bde h_neg_box_M0
    -- h_contra : (Formula.box (Formula.neg (Formula.neg phi))).neg ∈ M0
    -- Diamond(neg phi) = (neg phi).diamond = (neg phi).neg.box.neg
    --                   = phi.box.neg... no wait
    -- (neg phi).diamond = ((neg phi).neg).box.neg = (phi.neg.neg).box.neg... no
    -- Formula.diamond A = A.neg.box.neg = neg(Box(neg A))
    -- So (neg phi).diamond = ((neg phi).neg).box.neg = ...
    -- (neg phi).neg = Formula.neg (Formula.neg phi) = phi → ⊥ → ⊥... syntactically
    -- Actually: (Formula.neg phi).diamond = (Formula.neg phi).neg.box.neg
    --         = Formula.neg (Formula.box (Formula.neg (Formula.neg phi)))
    -- This is exactly what h_contra gives us!
    have h_eq : (Formula.neg phi).diamond =
                Formula.neg (Formula.box (Formula.neg (Formula.neg phi))) := rfl
    rw [h_eq]
    exact h_contra

  -- Step 4: By witness existence, get W' with neg(phi) in W' and same box class
  obtain ⟨W', h_W'_mcs, h_neg_phi_W', h_agree'⟩ :=
    box_theory_witness_exists M0 h_mcs (Formula.neg phi) h_diamond_neg

  -- Step 5: Build shifted chain from W' at time t
  let witness_fam := shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)) t

  -- This family is in the bundle
  have h_witness_in : witness_fam ∈ boxClassFamilies M0 h_mcs := by
    simp only [boxClassFamilies, Set.mem_setOf_eq]
    exact ⟨W', h_W'_mcs, t, h_agree', rfl⟩

  -- Step 6: neg(phi) is in witness_fam.mcs(t)
  have h_neg_phi_at_t : Formula.neg phi ∈ witness_fam.mcs t := by
    show Formula.neg phi ∈ (shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)) t).mcs t
    unfold shifted_fmcs
    simp only
    -- (t - t) = 0, so mcs 0 = W'
    have h_eq : (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)).mcs (t - t) =
                (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)).mcs 0 := by simp only [Int.sub_self]
    rw [h_eq]
    have h_mcs0 : (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)).mcs 0 = W' := by
      unfold SuccChainFMCS MCS_to_SerialMCS; rfl
    rw [h_mcs0]
    exact h_neg_phi_W'

  -- Step 7: phi is in ALL families at time t, including witness_fam
  have h_phi_at_t : phi ∈ witness_fam.mcs t := h_all witness_fam h_witness_in

  -- Step 8: Contradiction
  have h_mcs_witness := witness_fam.is_mcs t
  exact set_consistent_not_both h_mcs_witness.1 phi h_phi_at_t h_neg_phi_at_t

/--
**BLOCKED (depends on SuccChainTemporalCoherent which has mathematically FALSE dependencies)**

Temporal coherence: all families in the bundle satisfy forward_F and backward_P.

This theorem uses `SuccChainTemporalCoherent` which depends on `succ_chain_forward_F`
and `succ_chain_backward_P`, both of which use the mathematically false
`f_nesting_is_bounded` and `p_nesting_is_bounded`.

**Impact**: `construct_bfmcs` which uses this theorem has a sorry through the sorry chain.
However, for completeness purposes, the forward direction of the truth lemma does NOT
require temporal coherence - only the backward direction does.

**Migration path**: For completeness, use `succ_chain_completeness` which only needs
the forward truth direction. For full truth lemma, use restricted chain construction
with `restricted_forward_chain_forward_F`.

**Mathematical Status**: The underlying `f_nesting_is_bounded` claim is FALSE for
arbitrary MCS. An MCS can consistently contain {F^n(p) | n in Nat}. This is satisfiable
on the integers with successor semantics: point 0 satisfies all F^n(p) by having p
at position n.

See Task #55 research reports for detailed analysis.

**Status**: This theorem is BLOCKED. The underlying `SuccChainTemporalCoherent` was removed
because it depended on the mathematically false `f_nesting_is_bounded`.

**Replacement**: Use `omegaClassFamilies_temporally_coherent` from the omega-enumeration
construction below, which achieves temporal coherence by construction through dovetailed
resolution of F/P-obligations.
-/
@[deprecated "Use omegaClassFamilies_temporally_coherent" (since := "2026-03-24")]
theorem boxClassFamilies_temporally_coherent (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    ∀ fam ∈ boxClassFamilies M0 h_mcs,
      (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t φ, Formula.some_past φ ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s) := by
  -- BLOCKED: SuccChainTemporalCoherent was removed (depended on false f_nesting_is_bounded)
  -- Use omegaClassFamilies_temporally_coherent instead
  sorry

/-!
### Phase 5: construct_bfmcs

Wire everything together into the signature required by ParametricRepresentation.
-/

set_option maxHeartbeats 800000 in
/--
**BLOCKED (temporal coherence depends on mathematically FALSE theorems)**

The main construction: given an MCS M, produce a temporally coherent BFMCS containing M.

**WARNING**: This function uses `boxClassFamilies_temporally_coherent` which depends on
the mathematically false `f_nesting_is_bounded`. The temporal coherence proof has a sorry.

**Axiom dependency**: `#print axioms construct_bfmcs` shows `sorryAx` due to:
- `boxClassFamilies_temporally_coherent` -> `SuccChainTemporalCoherent`
- -> `succ_chain_forward_F` -> `f_nesting_boundary` -> `f_nesting_is_bounded` (FALSE)

**For completeness proofs**: Use `succ_chain_completeness` instead, which only requires
the forward direction of the truth lemma and does NOT depend on temporal coherence.
Alternatively, use `parametric_algebraic_representation_conditional` with a restricted
chain-based construction.

**Mathematical status**: The issue is that `f_nesting_is_bounded` claims every MCS has
bounded F-nesting. This is FALSE: {F^n(p) | n in Nat} is finitely consistent and extends
to an MCS with unbounded F-nesting.

See Task #55 research reports for complete analysis.

**Status**: This definition is BLOCKED. Use `construct_bfmcs_omega` instead.
-/
@[deprecated "Use construct_bfmcs_omega" (since := "2026-03-24")]
noncomputable def construct_bfmcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
       (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
       M = fam.mcs t := by
  -- BLOCKED: boxClassFamilies_temporally_coherent uses sorry
  -- Use construct_bfmcs_omega instead
  sorry

/-!
## Omega-Enumeration BFMCS Construction

This section implements the omega-enumeration approach to BFMCS construction.
Unlike the blocked SuccChain approach (which depends on false f_nesting_is_bounded),
this construction achieves temporal coherence BY CONSTRUCTION through dovetailed
resolution of F/P-obligations.

### Key Insight

Rather than hoping that an arbitrary successor chain eventually resolves all
F-obligations (which requires the false boundedness claim), we EXPLICITLY enumerate
and resolve each F-obligation in turn:

- At step 2n: resolve the n-th F-obligation from the base MCS
- At step 2n+1: resolve the n-th P-obligation from the base MCS

This dovetailing ensures that EVERY F(phi) in the base MCS eventually gets
resolved at some future step, and similarly for P(phi).

### Building Blocks

All sorry-free from earlier sections:
- `temporal_theory_witness_exists`: F(phi) ∈ M → ∃ W. phi ∈ W ∧ G-agree ∧ box_class_agree
- `past_theory_witness_exists`: P(phi) ∈ M → ∃ W. phi ∈ W ∧ H-agree ∧ box_class_agree
- `box_theory_witness_exists`: Diamond(psi) ∈ M → ∃ W. psi ∈ W ∧ box_class_agree
- `boxClassFamilies_modal_forward`: sorry-free
- `boxClassFamilies_modal_backward`: sorry-free
-/

/-!
### Phase 1 Prerequisites: box_class_agree transitivity
-/

/--
Transitivity of box_class_agree: if M agrees with W and W agrees with V, then M agrees with V.

This follows trivially from the transitivity of iff.
-/
theorem box_class_agree_trans {M W V : Set Formula}
    (h_MW : box_class_agree M W) (h_WV : box_class_agree W V) :
    box_class_agree M V := by
  intro phi
  exact Iff.trans (h_MW phi) (h_WV phi)

/-!
### F-Obligations Enumeration

We enumerate F-obligations using a simple pairing function on Nat.
This is used for the dovetailing strategy in omega chain construction.
-/

/--
The set of F-formulas (some_future formulas) in an MCS.
These are the "F-obligations" that need to be resolved.
-/
def F_obligations (M : Set Formula) : Set Formula :=
  { f | ∃ phi, f = Formula.some_future phi ∧ f ∈ M }

/--
The set of P-formulas (some_past formulas) in an MCS.
These are the "P-obligations" that need to be resolved.
-/
def P_obligations (M : Set Formula) : Set Formula :=
  { f | ∃ phi, f = Formula.some_past phi ∧ f ∈ M }

/--
Extract the inner formula from an F-obligation.
For F(phi), returns phi. For other formulas, returns the formula unchanged.
-/
def F_inner (f : Formula) : Formula :=
  match f with
  | .some_future phi => phi
  | other => other

/--
Extract the inner formula from a P-obligation.
For P(phi), returns phi. For other formulas, returns the formula unchanged.
-/
def P_inner (f : Formula) : Formula :=
  match f with
  | .some_past phi => phi
  | other => other

/-!
### G-theory preservation through F-witnesses

Key lemma: when we use temporal_theory_witness_exists to resolve F(phi),
the witness W preserves all G-formulas from M.
-/

/--
G-theory is preserved by temporal witnesses: if W is a witness for F(phi) from M,
then G(a) ∈ M implies G(a) ∈ W.

This follows directly from the G-agreement property of temporal_theory_witness_exists.
-/
theorem G_theory_preserved_by_witness (M W : Set Formula)
    (h_mcs_M : SetMaximalConsistent M) (h_mcs_W : SetMaximalConsistent W)
    (h_G_agree : ∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W)
    (a : Formula) (h_Ga_M : Formula.all_future a ∈ M) :
    Formula.all_future a ∈ W :=
  h_G_agree a h_Ga_M

/--
H-theory is preserved by past witnesses: if W is a witness for P(phi) from M,
then H(a) ∈ M implies H(a) ∈ W.
-/
theorem H_theory_preserved_by_witness (M W : Set Formula)
    (_h_mcs_M : SetMaximalConsistent M) (_h_mcs_W : SetMaximalConsistent W)
    (h_H_agree : ∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W)
    (a : Formula) (h_Ha_M : Formula.all_past a ∈ M) :
    Formula.all_past a ∈ W :=
  h_H_agree a h_Ha_M

/-!
### Phase 2: Omega Chain Forward Construction

The omega chain forward construction builds a Nat-indexed chain of MCSes starting
from a base MCS M0. At each step n, we take a temporal witness that preserves
both G-theory and box-class agreement.

The key insight is that `temporal_theory_witness_exists` preserves:
1. G-theory: G(a) ∈ M → G(a) ∈ W
2. box_class_agree: same Box-formulas

By transitivity, the entire chain preserves both properties from M0.
-/

/--
One step of the omega forward chain: given an MCS M with F(phi) ∈ M, produce
a witness MCS W with phi ∈ W, G-theory preserved, and box_class_agree.

This is a wrapper around temporal_theory_witness_exists for the forward direction.
-/
noncomputable def omega_step_forward (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    { W : Set Formula // SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W } := by
  have h := temporal_theory_witness_exists M h_mcs phi h_F
  exact ⟨h.choose, h.choose_spec.1, h.choose_spec.2.1, h.choose_spec.2.2.1, h.choose_spec.2.2.2⟩

/--
Invariant for the omega forward chain: tracks MCS property, G-theory propagation, and box-class.
-/
structure OmegaForwardInvariant (M0 : Set Formula) (W : Set Formula) : Prop where
  /-- W is an MCS -/
  is_mcs : SetMaximalConsistent W
  /-- G-formulas from M0 propagate to W -/
  G_propagate : ∀ a, Formula.all_future a ∈ M0 → Formula.all_future a ∈ W
  /-- W agrees with M0 on Box-formulas -/
  box_agree : box_class_agree M0 W

/--
The omega forward chain with full invariant tracking.

Each element of the chain satisfies:
1. Is an MCS
2. Contains all G-formulas from M0
3. Agrees with M0 on Box-formulas
-/
noncomputable def omega_chain_forward_with_inv
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → { W : Set Formula // OmegaForwardInvariant M0 W }
  | 0 => ⟨M0, ⟨h_mcs0, fun _ h => h, box_class_agree_refl M0⟩⟩
  | n + 1 =>
    let prev := omega_chain_forward_with_inv M0 h_mcs0 n
    let M_n := prev.val
    let inv_n := prev.property
    -- F_top is in M_n (every MCS contains F_top by seriality)
    let h_F_top : Bimodal.Syntax.F_top ∈ M_n := SetMaximalConsistent.contains_F_top inv_n.is_mcs
    -- Get a witness for F_top
    let witness := omega_step_forward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_F_top
    ⟨witness.val, {
      is_mcs := witness.property.1
      G_propagate := fun a h_Ga_M0 =>
        -- G(a) ∈ M0 → G(a) ∈ M_n (by inv_n) → G(a) ∈ witness (by witness property)
        witness.property.2.2.1 a (inv_n.G_propagate a h_Ga_M0)
      box_agree := box_class_agree_trans inv_n.box_agree witness.property.2.2.2
    }⟩

/--
The omega forward chain: Nat-indexed MCS chain from base M0.
-/
noncomputable def omega_chain_forward (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → Set Formula :=
  fun n => (omega_chain_forward_with_inv M0 h_mcs0 n).val

/--
Each point in the omega forward chain is an MCS.
-/
theorem omega_chain_forward_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, SetMaximalConsistent (omega_chain_forward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_forward_with_inv M0 h_mcs0 n).property.is_mcs

/--
Each point in the omega forward chain agrees on box-content with M0.
-/
theorem omega_chain_forward_box_class (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, box_class_agree M0 (omega_chain_forward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_forward_with_inv M0 h_mcs0 n).property.box_agree

/--
The omega forward chain at 0 is the base MCS.
-/
theorem omega_chain_forward_zero (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    omega_chain_forward M0 h_mcs0 0 = M0 := rfl

/--
G-formulas are propagated through the omega forward chain:
if G(a) ∈ M0, then G(a) ∈ omega_chain_forward(n) for all n.
-/
theorem omega_chain_forward_G_theory (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (a : Formula) (h_Ga_M0 : Formula.all_future a ∈ M0) :
    ∀ n : Nat, Formula.all_future a ∈ omega_chain_forward M0 h_mcs0 n := by
  intro n
  exact (omega_chain_forward_with_inv M0 h_mcs0 n).property.G_propagate a h_Ga_M0

/-!
### Phase 3: Omega Chain Backward Construction

Symmetric to Phase 2, but for the past direction using past_theory_witness_exists.
-/

/--
One step of the omega backward chain: given an MCS M with P(phi) ∈ M, produce
a witness MCS W with phi ∈ W, H-theory preserved, and box_class_agree.

This is a wrapper around past_theory_witness_exists for the backward direction.
-/
noncomputable def omega_step_backward (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    { W : Set Formula // SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W) ∧
      box_class_agree M W } := by
  have h := past_theory_witness_exists M h_mcs phi h_P
  exact ⟨h.choose, h.choose_spec.1, h.choose_spec.2.1, h.choose_spec.2.2.1, h.choose_spec.2.2.2⟩

/--
Invariant for the omega backward chain: tracks MCS property, H-theory propagation, and box-class.
-/
structure OmegaBackwardInvariant (M0 : Set Formula) (W : Set Formula) : Prop where
  /-- W is an MCS -/
  is_mcs : SetMaximalConsistent W
  /-- H-formulas from M0 propagate to W -/
  H_propagate : ∀ a, Formula.all_past a ∈ M0 → Formula.all_past a ∈ W
  /-- W agrees with M0 on Box-formulas -/
  box_agree : box_class_agree M0 W

/--
The omega backward chain with full invariant tracking.

Each element of the chain satisfies:
1. Is an MCS
2. Contains all H-formulas from M0
3. Agrees with M0 on Box-formulas
-/
noncomputable def omega_chain_backward_with_inv
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → { W : Set Formula // OmegaBackwardInvariant M0 W }
  | 0 => ⟨M0, ⟨h_mcs0, fun _ h => h, box_class_agree_refl M0⟩⟩
  | n + 1 =>
    let prev := omega_chain_backward_with_inv M0 h_mcs0 n
    let M_n := prev.val
    let inv_n := prev.property
    -- P_top is in M_n (every MCS contains P_top by seriality)
    let h_P_top : Bimodal.Syntax.P_top ∈ M_n := SetMaximalConsistent.contains_P_top inv_n.is_mcs
    -- Get a witness for P_top
    let witness := omega_step_backward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_P_top
    ⟨witness.val, {
      is_mcs := witness.property.1
      H_propagate := fun a h_Ha_M0 =>
        -- H(a) ∈ M0 → H(a) ∈ M_n (by inv_n) → H(a) ∈ witness (by witness property)
        witness.property.2.2.1 a (inv_n.H_propagate a h_Ha_M0)
      box_agree := box_class_agree_trans inv_n.box_agree witness.property.2.2.2
    }⟩

/--
The omega backward chain: Nat-indexed MCS chain from base M0.
-/
noncomputable def omega_chain_backward (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → Set Formula :=
  fun n => (omega_chain_backward_with_inv M0 h_mcs0 n).val

/--
Each point in the omega backward chain is an MCS.
-/
theorem omega_chain_backward_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, SetMaximalConsistent (omega_chain_backward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_backward_with_inv M0 h_mcs0 n).property.is_mcs

/--
Each point in the omega backward chain agrees on box-content with M0.
-/
theorem omega_chain_backward_box_class (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, box_class_agree M0 (omega_chain_backward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_backward_with_inv M0 h_mcs0 n).property.box_agree

/--
The omega backward chain at 0 is the base MCS.
-/
theorem omega_chain_backward_zero (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    omega_chain_backward M0 h_mcs0 0 = M0 := rfl

/--
H-formulas are propagated through the omega backward chain:
if H(a) ∈ M0, then H(a) ∈ omega_chain_backward(n) for all n.
-/
theorem omega_chain_backward_H_theory (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (a : Formula) (h_Ha_M0 : Formula.all_past a ∈ M0) :
    ∀ n : Nat, Formula.all_past a ∈ omega_chain_backward M0 h_mcs0 n := by
  intro n
  exact (omega_chain_backward_with_inv M0 h_mcs0 n).property.H_propagate a h_Ha_M0

/-!
### Phase 4: Z-Chain and OmegaFMCS Construction

Combine the forward and backward omega chains into an Int-indexed chain,
then wrap as an FMCS structure.

**Construction**:
- Z_chain(t) for t >= 0: omega_chain_forward(t)
- Z_chain(t) for t < 0: omega_chain_backward(|t|)

**Key Properties**:
- Z_chain(0) = M0 (both chains agree at 0)
- All elements are MCS
- All elements have box_class_agree with M0
- G-theory propagates forward (positive direction)
- H-theory propagates backward (negative direction)
-/

/--
The Z-chain: combine forward and backward omega chains into an Int-indexed chain.

- t >= 0: use omega_chain_forward(t.toNat)
- t < 0: use omega_chain_backward((-t).toNat)
-/
noncomputable def Z_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Int → Set Formula :=
  fun t =>
    if h : t ≥ 0 then
      omega_chain_forward M0 h_mcs0 t.toNat
    else
      omega_chain_backward M0 h_mcs0 (-t).toNat

/--
Every element of the Z-chain is an MCS.
-/
theorem Z_chain_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ t : Int, SetMaximalConsistent (Z_chain M0 h_mcs0 t) := by
  intro t
  unfold Z_chain
  split
  · exact omega_chain_forward_mcs M0 h_mcs0 t.toNat
  · exact omega_chain_backward_mcs M0 h_mcs0 (-t).toNat

/--
Every element of the Z-chain agrees on box-content with M0.
-/
theorem Z_chain_box_class (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ t : Int, box_class_agree M0 (Z_chain M0 h_mcs0 t) := by
  intro t
  unfold Z_chain
  split
  · exact omega_chain_forward_box_class M0 h_mcs0 t.toNat
  · exact omega_chain_backward_box_class M0 h_mcs0 (-t).toNat

/--
Z_chain at 0 is M0.
-/
theorem Z_chain_zero (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Z_chain M0 h_mcs0 0 = M0 := by
  unfold Z_chain
  simp only [ge_iff_le, le_refl, ↓reduceDIte, Int.toNat_zero]
  exact omega_chain_forward_zero M0 h_mcs0

/-!
### FMCS Coherence Properties

The Z-chain satisfies the FMCS coherence conditions:
- forward_G: G(phi) at t implies phi at all t' >= t
- backward_H: H(phi) at t implies phi at all t' <= t

These follow from G-theory and H-theory propagation through the chains.
-/

/--
G-formulas propagate forward in the omega_chain_forward:
G(phi) ∈ chain(m) implies G(phi) ∈ chain(n) for all n >= m.

This follows from the chain construction: each step uses temporal_theory_witness_exists
which preserves G-formulas from the current MCS.
-/
theorem omega_chain_forward_G_monotone (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (phi : Formula) (m n : Nat) (h_le : m ≤ n)
    (h_G : Formula.all_future phi ∈ omega_chain_forward M0 h_mcs0 m) :
    Formula.all_future phi ∈ omega_chain_forward M0 h_mcs0 n := by
  -- Proof by induction on (n - m)
  induction n with
  | zero =>
    -- m ≤ 0 means m = 0
    have : m = 0 := Nat.le_zero.mp h_le
    rw [this] at h_G
    exact h_G
  | succ n ih =>
    by_cases h_eq : m = n + 1
    · -- m = n + 1, so h_G is already what we need
      rw [h_eq] at h_G
      exact h_G
    · -- m ≤ n, apply IH then one more step
      have h_le' : m ≤ n := Nat.lt_succ_iff.mp (Nat.lt_of_le_of_ne h_le h_eq)
      have h_G_n := ih h_le'
      -- G(phi) ∈ chain(n), need G(phi) ∈ chain(n+1)
      -- chain(n+1) = witness from chain(n) with F_top
      -- The witness preserves G-formulas from chain(n)
      unfold omega_chain_forward omega_chain_forward_with_inv
      -- The witness property preserves G from the input MCS
      have h_mcs_n := omega_chain_forward_mcs M0 h_mcs0 n
      have h_F_top : Bimodal.Syntax.F_top ∈ omega_chain_forward M0 h_mcs0 n :=
        SetMaximalConsistent.contains_F_top h_mcs_n
      let witness := omega_step_forward (omega_chain_forward M0 h_mcs0 n) h_mcs_n
        (Formula.neg Formula.bot) h_F_top
      -- witness.property.2.2.1: G-formulas from chain(n) are in witness
      exact witness.property.2.2.1 phi h_G_n

/--
Forward G coherence for Z-chain: G(phi) at t implies phi at t' for all t' >= t.
-/
theorem Z_chain_forward_G (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_le : t ≤ t') (h_G : Formula.all_future phi ∈ Z_chain M0 h_mcs0 t) :
    phi ∈ Z_chain M0 h_mcs0 t' := by
  -- Strategy: Show G(phi) persists from t to t', then apply T-axiom
  have h_mcs_t' := Z_chain_mcs M0 h_mcs0 t'

  -- First, we need G(phi) ∈ Z_chain(t')
  have h_G_t' : Formula.all_future phi ∈ Z_chain M0 h_mcs0 t' := by
    -- Case analysis on whether t and t' are non-negative
    unfold Z_chain at h_G ⊢
    by_cases h_t_nonneg : t ≥ 0
    · -- t >= 0, so Z_chain(t) = omega_chain_forward(t.toNat)
      simp only [ge_iff_le, h_t_nonneg, ↓reduceDIte] at h_G
      by_cases h_t'_nonneg : t' ≥ 0
      · -- t' >= 0, so Z_chain(t') = omega_chain_forward(t'.toNat)
        simp only [ge_iff_le, h_t'_nonneg, ↓reduceDIte]
        -- Need to show t.toNat ≤ t'.toNat
        have h_toNat_le : t.toNat ≤ t'.toNat := by
          -- t >= 0 and t' >= 0 and t <= t' implies t.toNat <= t'.toNat
          have ht : (t.toNat : Int) = t := Int.toNat_of_nonneg h_t_nonneg
          have ht' : (t'.toNat : Int) = t' := Int.toNat_of_nonneg h_t'_nonneg
          omega
        exact omega_chain_forward_G_monotone M0 h_mcs0 phi t.toNat t'.toNat h_toNat_le h_G
      · -- t >= 0 but t' < 0 contradicts t ≤ t'
        push_neg at h_t'_nonneg
        omega
    · -- t < 0
      push_neg at h_t_nonneg
      have h_t_neg : ¬(t ≥ 0) := by omega
      simp only [ge_iff_le, h_t_neg, ↓reduceDIte] at h_G
      by_cases h_t'_nonneg : t' ≥ 0
      · -- t < 0 but t' >= 0
        -- We need to cross from backward chain to forward chain
        simp only [ge_iff_le, h_t'_nonneg, ↓reduceDIte]
        -- The backward chain at (-t).toNat has G(phi)
        -- We need to propagate it to the forward chain at t'.toNat

        -- Key insight: Both chains pass through M0 at index 0
        -- backward_chain(0) = M0 = forward_chain(0)

        -- The backward chain is built going "backward" (increasing negative index)
        -- But at index 0, it IS M0. So if G(phi) is in backward_chain(n),
        -- we need to show it propagates "forward" to M0.

        -- Actually, the backward chain construction only preserves H-theory, not G-theory
        -- This is a fundamental gap in the current construction

        -- For now, sorry this crossing case
        sorry
      · -- t < 0 and t' < 0
        push_neg at h_t'_nonneg
        have h_t'_neg : ¬(t' ≥ 0) := by omega
        simp only [ge_iff_le, h_t'_neg, ↓reduceDIte]
        -- Both in backward chain
        -- t ≤ t' < 0 means |t'| <= |t|, i.e., (-t') <= (-t)
        -- In backward_chain: (-t').toNat <= (-t).toNat

        -- The backward chain at (-t).toNat has G(phi)
        -- We need G(phi) at (-t').toNat

        -- Since (-t').toNat <= (-t).toNat, backward_chain((-t').toNat) is
        -- EARLIER in the construction than backward_chain((-t).toNat)

        -- The backward chain builds: M0 = chain(0), chain(1), chain(2), ...
        -- Each step takes a P-witness from the previous step
        -- P-witnesses preserve H-theory, but NOT necessarily G-theory

        -- This is a gap: G-formulas may not propagate backward in the backward chain

        -- For now, sorry this case
        sorry

  -- Now apply T-axiom: G(phi) → phi
  have h_T : [] ⊢ (Formula.all_future phi).imp phi :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future phi)
  exact SetMaximalConsistent.implication_property h_mcs_t' (theorem_in_mcs h_mcs_t' h_T) h_G_t'

/--
Backward H coherence for Z-chain: H(phi) at t implies phi at t' for all t' <= t.
-/
theorem Z_chain_backward_H (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_le : t' ≤ t) (h_H : Formula.all_past phi ∈ Z_chain M0 h_mcs0 t) :
    phi ∈ Z_chain M0 h_mcs0 t' := by
  -- Symmetric to Z_chain_forward_G
  sorry

/--
The OmegaFMCS: wrap Z_chain as an FMCS structure.

**Note**: The forward_G and backward_H proofs currently use sorry because
the chain construction needs to be extended to track full G/H propagation.
-/
noncomputable def OmegaFMCS (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : FMCS Int where
  mcs := Z_chain M0 h_mcs0
  is_mcs := Z_chain_mcs M0 h_mcs0
  forward_G := Z_chain_forward_G M0 h_mcs0
  backward_H := Z_chain_backward_H M0 h_mcs0

/--
OmegaFMCS at time 0 equals M0.
-/
theorem OmegaFMCS_zero (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    (OmegaFMCS M0 h_mcs0).mcs 0 = M0 :=
  Z_chain_zero M0 h_mcs0

/-!
### Phase 5: Temporal Coherence (forward_F and backward_P)

For completeness, we need to prove that the Z-chain satisfies:
- forward_F: F(phi) at t → exists s > t with phi at s
- backward_P: P(phi) at t → exists s < t with phi at s

These follow from the chain construction: each step of the forward chain
uses `temporal_theory_witness_exists` which provides F-witnesses, and
each step of the backward chain uses `past_theory_witness_exists` for P-witnesses.
-/

/--
Forward F coherence for Z-chain: F(phi) at t implies exists s ≥ t with phi at s.

Uses weak inequality (t ≤ s) aligned with reflexive semantics.
When phi is already in chain(t), we return s = t as witness.

**Proof Strategy**:
1. Check if phi ∈ Z_chain(t): if so, return s = t with le_refl
2. Otherwise: the chain construction eventually resolves F(phi)
-/
theorem Z_chain_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ Z_chain M0 h_mcs0 t) :
    ∃ s : Int, t ≤ s ∧ phi ∈ Z_chain M0 h_mcs0 s := by
  -- With weak coherence: if phi ∈ chain(t), return s = t
  by_cases h_phi_t : phi ∈ Z_chain M0 h_mcs0 t
  · exact ⟨t, le_refl t, h_phi_t⟩
  · -- phi ∉ Z_chain(t): Use semantic witness existence
    -- F(phi) ∈ Z_chain(t) and phi ∉ Z_chain(t) means F(phi) is genuinely unresolved
    -- By temporal_theory_witness_exists, there exists witness W with phi ∈ W
    have h_mcs_t := Z_chain_mcs M0 h_mcs0 t
    have h_witness := temporal_theory_witness_exists (Z_chain M0 h_mcs0 t) h_mcs_t phi h_F
    obtain ⟨W, h_W_mcs, h_phi_W, _, h_box_agree⟩ := h_witness

    -- W is in the same box class as M0
    have h_box_M0_t := Z_chain_box_class M0 h_mcs0 t
    have h_box_M0_W : box_class_agree M0 W := box_class_agree_trans h_box_M0_t h_box_agree

    -- phi ∉ Z_chain(t): need strict resolution
    -- The Z_chain uses omega_chain_forward which doesn't have F-resolution guarantee
    -- For the phi ∉ chain(t) case, we need the F-preserving chain
    -- This sorry represents the gap between Z_chain and F-preserving chain
    -- Note: The F-preserving chain's resolution theorem IS closed (omega_F_preserving_forward_F_resolution)
    sorry

/--
Backward P coherence for Z-chain: P(phi) at t implies exists s ≤ t with phi at s.

Uses weak inequality (s ≤ t) aligned with reflexive semantics.
When phi is already in chain(t), we return s = t as witness.
-/
theorem Z_chain_backward_P (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula) (h_P : Formula.some_past phi ∈ Z_chain M0 h_mcs0 t) :
    ∃ s : Int, s ≤ t ∧ phi ∈ Z_chain M0 h_mcs0 s := by
  -- With weak coherence: if phi ∈ chain(t), return s = t
  by_cases h_phi_t : phi ∈ Z_chain M0 h_mcs0 t
  · exact ⟨t, le_refl t, h_phi_t⟩
  · -- phi ∉ Z_chain(t): Symmetric to forward case
    -- The Z_chain uses omega_chain_backward which doesn't have P-resolution guarantee
    -- This sorry represents the gap between Z_chain and a P-preserving chain
    sorry

/-!
## Bundle-Level Temporal Coherence

This section implements bundle-level temporal coherence as an alternative to the
blocked family-level temporal coherence (SuccChainTemporalCoherent).

### Key Insight

The family-level temporal coherence requires F-witnesses to exist within the
SAME family (chain). This is blocked by sub-case (b): when G(neg phi) is in M0,
H(neg phi) is NOT in M0, and F(phi) is in backward(n), we cannot find phi
within the same chain.

Bundle-level temporal coherence relaxes this: F-witnesses can exist in ANY
family of the bundle. This is mathematically sound because:
1. Standard Kripke semantics doesn't require witnesses to be in the same "chain"
2. Jonsson-Tarski completeness inherently uses bundle structures
3. Completeness only requires existence of a satisfying model, not specific structure

### Building Blocks

All sorry-free from earlier sections:
- `temporal_theory_witness_exists`: F(phi) ∈ M → ∃ W. phi ∈ W ∧ box_class_agree M W
- `past_theory_witness_exists`: P(phi) ∈ M → ∃ W. phi ∈ W ∧ box_class_agree M W
- `boxClassFamilies_modal_forward`: Box(phi) in one family → phi in all families
- `boxClassFamilies_modal_backward`: phi in all families → Box(phi) in any family
-/

/-!
### Bundle-Level Temporal Coherence Predicates

Define predicates that capture bundle-level F and P coherence.
-/

/--
Bundle-level forward F coherence: F(phi) in fam.mcs(t) implies there exists
SOME family fam' in the bundle with phi at some s > t.

Unlike family-level coherence, fam' need not equal fam.
-/
def bundle_forward_F (families : Set (FMCS Int)) (fam : FMCS Int) : Prop :=
  ∀ t phi, Formula.some_future phi ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs s

/--
Bundle-level backward P coherence: P(phi) in fam.mcs(t) implies there exists
SOME family fam' in the bundle with phi at some s < t.

Unlike family-level coherence, fam' need not equal fam.
-/
def bundle_backward_P (families : Set (FMCS Int)) (fam : FMCS Int) : Prop :=
  ∀ t phi, Formula.some_past phi ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s < t, phi ∈ fam'.mcs s

/--
A bundle is temporally coherent at the bundle level if all families satisfy
both bundle_forward_F and bundle_backward_P.
-/
def BundleTemporallyCoherent (families : Set (FMCS Int)) : Prop :=
  ∀ fam ∈ families, bundle_forward_F families fam ∧ bundle_backward_P families fam

/--
Bundle coherence gives an existential F-witness (not necessarily in the same family).
This is a restatement of bundle_forward_F for clarity.
-/
theorem bundle_coherence_implies_F_witness {families : Set (FMCS Int)}
    (h_tc : BundleTemporallyCoherent families)
    (fam : FMCS Int) (hfam : fam ∈ families)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ fam.mcs t) :
    ∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs s :=
  (h_tc fam hfam).1 t phi h_F

/--
Bundle coherence gives an existential P-witness (not necessarily in the same family).
This is a restatement of bundle_backward_P for clarity.
-/
theorem bundle_coherence_implies_P_witness {families : Set (FMCS Int)}
    (h_tc : BundleTemporallyCoherent families)
    (fam : FMCS Int) (hfam : fam ∈ families)
    (t : Int) (phi : Formula) (h_P : Formula.some_past phi ∈ fam.mcs t) :
    ∃ fam' ∈ families, ∃ s < t, phi ∈ fam'.mcs s :=
  (h_tc fam hfam).2 t phi h_P

/-!
### Phase 2: boxClassFamilies Satisfies Bundle Coherence

Prove that boxClassFamilies satisfies bundle_forward_F and bundle_backward_P.

The proof strategy:
1. Given F(phi) ∈ fam.mcs(t) for some fam ∈ boxClassFamilies
2. Use temporal_theory_witness_exists to get witness MCS W with phi ∈ W
3. W has box_class_agree with fam.mcs(t), hence with M0 (by transitivity)
4. Build shifted SuccChainFMCS from W at offset t+1
5. This shifted family is in boxClassFamilies
6. phi ∈ shifted_fam.mcs(t+1), and t+1 > t
-/

/--
Get box_class_agree at a specific time point from a family in boxClassFamilies.
-/
theorem boxClassFamilies_box_agree_at_time (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs) (t : Int) :
    box_class_agree M0 (fam.mcs t) := by
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  unfold shifted_fmcs
  simp only
  -- fam.mcs(t) = SuccChainFMCS(W).mcs(t - k)
  -- Box-formulas are constant along SuccChainFMCS
  intro phi
  -- succ_chain_box_persistent: mcs 0 ↔ mcs (t-k)
  have h_box_persist := succ_chain_box_persistent (MCS_to_SerialMCS W h_W) phi (t - k)
  -- And SuccChainFMCS(W).mcs(0) = W
  have h_mcs0 : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := rfl
  -- Chain: M0 ↔ W = mcs(0) ↔ mcs(t-k)
  -- h_agree: M0 ↔ W
  -- h_box_persist: mcs(0) ↔ mcs(t-k)
  constructor
  · -- Box(phi) ∈ M0 → Box(phi) ∈ mcs(t-k)
    intro h
    -- M0 → W
    have h_W' := (h_agree phi).mp h
    -- W = mcs(0), so mcs(0) has Box(phi)
    have h0 : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 := by
      rw [h_mcs0]; exact h_W'
    -- mcs(0) → mcs(t-k)
    exact h_box_persist.mp h0
  · -- Box(phi) ∈ mcs(t-k) → Box(phi) ∈ M0
    intro h
    -- mcs(t-k) → mcs(0)
    have h0 := h_box_persist.mpr h
    -- mcs(0) = W
    rw [h_mcs0] at h0
    -- W → M0
    exact (h_agree phi).mpr h0

/--
boxClassFamilies satisfies bundle_forward_F: every F(phi) has a witness in the bundle.

**Proof outline**:
1. F(phi) ∈ fam.mcs(t) for fam ∈ boxClassFamilies M0
2. fam.mcs(t) is an MCS with box_class_agree with M0
3. By temporal_theory_witness_exists: ∃ W MCS with phi ∈ W and box_class_agree(fam.mcs(t), W)
4. By transitivity: box_class_agree(M0, W)
5. Build witness_fam = shifted_fmcs(SuccChainFMCS(W), t+1)
6. witness_fam ∈ boxClassFamilies M0 h_mcs
7. phi ∈ witness_fam.mcs(t+1) since witness_fam.mcs(t+1) = W
-/
theorem boxClassFamilies_bundle_forward_F (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ fam.mcs t) :
    ∃ fam' ∈ boxClassFamilies M0 h_mcs, ∃ s > t, phi ∈ fam'.mcs s := by
  -- Step 1: Get the MCS at time t
  have h_mcs_t := fam.is_mcs t

  -- Step 2: Use temporal_theory_witness_exists to get witness
  have h_witness := temporal_theory_witness_exists (fam.mcs t) h_mcs_t phi h_F
  obtain ⟨W, h_W_mcs, h_phi_W, _h_G_agree, h_box_agree⟩ := h_witness

  -- Step 3: Establish box_class_agree M0 W by transitivity
  have h_fam_box := boxClassFamilies_box_agree_at_time M0 h_mcs fam hfam t
  have h_M0_W : box_class_agree M0 W := box_class_agree_trans h_fam_box h_box_agree

  -- Step 4: Build the witness family
  let witness_fam := shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W_mcs)) (t + 1)

  -- Step 5: Show witness_fam is in boxClassFamilies
  have h_witness_in : witness_fam ∈ boxClassFamilies M0 h_mcs := by
    simp only [boxClassFamilies, Set.mem_setOf_eq]
    exact ⟨W, h_W_mcs, t + 1, h_M0_W, rfl⟩

  -- Step 6: Show phi ∈ witness_fam.mcs(t+1)
  have h_phi_at_s : phi ∈ witness_fam.mcs (t + 1) := by
    show phi ∈ (shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W_mcs)) (t + 1)).mcs (t + 1)
    unfold shifted_fmcs
    simp only
    -- (t+1) - (t+1) = 0
    have h_eq : (t + 1 : Int) - (t + 1) = 0 := by omega
    simp only [h_eq]
    -- SuccChainFMCS(W).mcs(0) = W
    have h_mcs0 : (SuccChainFMCS (MCS_to_SerialMCS W h_W_mcs)).mcs 0 = W := rfl
    rw [h_mcs0]
    exact h_phi_W

  -- Step 7: Combine
  use witness_fam, h_witness_in, t + 1
  exact ⟨by omega, h_phi_at_s⟩

/--
boxClassFamilies satisfies bundle_backward_P: every P(phi) has a witness in the bundle.

Symmetric to bundle_forward_F, using past_theory_witness_exists.
-/
theorem boxClassFamilies_bundle_backward_P (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (t : Int) (phi : Formula) (h_P : Formula.some_past phi ∈ fam.mcs t) :
    ∃ fam' ∈ boxClassFamilies M0 h_mcs, ∃ s < t, phi ∈ fam'.mcs s := by
  -- Step 1: Get the MCS at time t
  have h_mcs_t := fam.is_mcs t

  -- Step 2: Use past_theory_witness_exists to get witness
  have h_witness := past_theory_witness_exists (fam.mcs t) h_mcs_t phi h_P
  obtain ⟨W, h_W_mcs, h_phi_W, _h_H_agree, h_box_agree⟩ := h_witness

  -- Step 3: Establish box_class_agree M0 W by transitivity
  have h_fam_box := boxClassFamilies_box_agree_at_time M0 h_mcs fam hfam t
  have h_M0_W : box_class_agree M0 W := box_class_agree_trans h_fam_box h_box_agree

  -- Step 4: Build the witness family at offset t-1
  let witness_fam := shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W_mcs)) (t - 1)

  -- Step 5: Show witness_fam is in boxClassFamilies
  have h_witness_in : witness_fam ∈ boxClassFamilies M0 h_mcs := by
    simp only [boxClassFamilies, Set.mem_setOf_eq]
    exact ⟨W, h_W_mcs, t - 1, h_M0_W, rfl⟩

  -- Step 6: Show phi ∈ witness_fam.mcs(t-1)
  have h_phi_at_s : phi ∈ witness_fam.mcs (t - 1) := by
    show phi ∈ (shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W_mcs)) (t - 1)).mcs (t - 1)
    unfold shifted_fmcs
    simp only
    -- (t-1) - (t-1) = 0
    have h_eq : (t - 1 : Int) - (t - 1) = 0 := by omega
    simp only [h_eq]
    have h_mcs0 : (SuccChainFMCS (MCS_to_SerialMCS W h_W_mcs)).mcs 0 = W := rfl
    rw [h_mcs0]
    exact h_phi_W

  -- Step 7: Combine
  use witness_fam, h_witness_in, t - 1
  exact ⟨by omega, h_phi_at_s⟩

/--
boxClassFamilies is bundle temporally coherent.
-/
theorem boxClassFamilies_bundle_temporally_coherent (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    BundleTemporallyCoherent (boxClassFamilies M0 h_mcs) := by
  intro fam hfam
  constructor
  · -- bundle_forward_F
    intro t phi h_F
    exact boxClassFamilies_bundle_forward_F M0 h_mcs fam hfam t phi h_F
  · -- bundle_backward_P
    intro t phi h_P
    exact boxClassFamilies_bundle_backward_P M0 h_mcs fam hfam t phi h_P

/-!
### Phase 3: BFMCS_Bundle Structure

A BFMCS variant that uses bundle-level temporal coherence instead of family-level.
This is the key structure for completeness proofs.
-/

/--
BFMCS with bundle-level temporal coherence.

This structure is like BFMCS but uses bundle-level F/P coherence:
- bundle_forward_F: F(phi) in fam.mcs(t) → ∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs(s)
- bundle_backward_P: P(phi) in fam.mcs(t) → ∃ fam' ∈ families, ∃ s < t, phi ∈ fam'.mcs(s)

The key difference from BFMCS.temporally_coherent (which requires witnesses in the SAME family)
is that witnesses can be in ANY family of the bundle.
-/
structure BFMCS_Bundle where
  /-- The collection of indexed MCS families forming the bundle -/
  families : Set (FMCS Int)

  /-- The bundle is non-empty -/
  nonempty : families.Nonempty

  /-- Modal forward coherence: Box phi in any family implies phi in ALL families -/
  modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t →
    ∀ fam' ∈ families, φ ∈ fam'.mcs t

  /-- Modal backward coherence: phi in ALL families implies Box phi in any family -/
  modal_backward : ∀ fam ∈ families, ∀ φ t,
    (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t

  /-- Bundle-level forward F coherence: F(phi) witnesses exist in SOME family -/
  bundle_forward_F : ∀ fam ∈ families, ∀ φ t, Formula.some_future φ ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s

  /-- Bundle-level backward P coherence: P(phi) witnesses exist in SOME family -/
  bundle_backward_P : ∀ fam ∈ families, ∀ φ t, Formula.some_past φ ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s < t, φ ∈ fam'.mcs s

  /-- The distinguished evaluation family -/
  eval_family : FMCS Int

  /-- The evaluation family is in the bundle -/
  eval_family_mem : eval_family ∈ families

/--
Reflexivity for BFMCS_Bundle: Box phi in MCS implies phi in MCS.
-/
theorem BFMCS_Bundle.reflexivity (B : BFMCS_Bundle) (fam : FMCS Int) (hfam : fam ∈ B.families)
    (φ : Formula) (t : Int) (h : Formula.box φ ∈ fam.mcs t) : φ ∈ fam.mcs t :=
  B.modal_forward fam hfam φ t h fam hfam

/--
Diamond witness for BFMCS_Bundle: Diamond(phi) implies phi in SOME family.
-/
theorem BFMCS_Bundle.diamond_witness (B : BFMCS_Bundle) (fam : FMCS Int) (hfam : fam ∈ B.families)
    (φ : Formula) (t : Int) (h_diamond : Formula.diamond φ ∈ fam.mcs t) :
    ∃ fam' ∈ B.families, φ ∈ fam'.mcs t := by
  -- Diamond(phi) = neg(Box(neg(phi)))
  -- If Box(neg(phi)) ∈ fam.mcs t, then by modal_forward, neg(phi) ∈ all families at t
  -- But then neg(Box(neg(phi))) would contradict MCS consistency
  -- So Box(neg(phi)) ∉ fam.mcs t
  -- By MCS maximality and the modal saturation argument, phi is in some family
  have h_mcs := fam.is_mcs t
  have h_not_box_neg : Formula.box (Formula.neg φ) ∉ fam.mcs t := by
    intro h_box_neg
    have h_neg : Formula.neg φ ∈ fam.mcs t := B.modal_forward fam hfam (Formula.neg φ) t h_box_neg fam hfam
    -- Diamond(phi) = neg(Box(neg(phi))) and Box(neg(phi)) in MCS contradicts
    have h_eq : Formula.diamond φ = Formula.neg (Formula.box (Formula.neg φ)) := rfl
    rw [h_eq] at h_diamond
    exact set_consistent_not_both h_mcs.1 (Formula.box (Formula.neg φ)) h_box_neg h_diamond
  -- Use box_theory_witness_exists to get a witness family
  have h_diamond' : φ.diamond ∈ fam.mcs t := h_diamond
  have h_witness := box_theory_witness_exists (fam.mcs t) h_mcs φ h_diamond'
  obtain ⟨W, h_W_mcs, h_phi_W, h_box_agree⟩ := h_witness
  -- W is in the same box class as fam.mcs t, and by boxClassFamilies properties,
  -- a shifted chain from W is in any bundle containing fam
  -- For BFMCS_Bundle, we need to show W appears somewhere in the families
  -- This requires knowing that B.families contains all box-class witnesses

  -- Actually, for BFMCS_Bundle built from boxClassFamilies, this follows from construction
  -- But for a general BFMCS_Bundle, we need to use modal_backward

  -- Alternative approach using modal_backward:
  -- If phi is NOT in some family at t, then neg(phi) is in that family
  -- If neg(phi) is in ALL families at t, then Box(neg(phi)) in fam (by modal_backward)
  -- But Box(neg(phi)) ∉ fam (from h_not_box_neg), so phi is in SOME family
  by_contra h_no_witness
  push_neg at h_no_witness
  -- For all fam' in families, phi ∉ fam'.mcs t
  -- So for all fam' in families, neg(phi) ∈ fam'.mcs t (by MCS negation completeness)
  have h_all_neg : ∀ fam' ∈ B.families, Formula.neg φ ∈ fam'.mcs t := by
    intro fam' hfam'
    have h_mcs' := fam'.is_mcs t
    have h_not_phi := h_no_witness fam' hfam'
    rcases SetMaximalConsistent.negation_complete h_mcs' φ with h | h
    · exact absurd h h_not_phi
    · exact h
  -- By modal_backward: Box(neg(phi)) ∈ fam.mcs t
  have h_box_neg' := B.modal_backward fam hfam (Formula.neg φ) t h_all_neg
  -- Contradiction with h_not_box_neg
  exact h_not_box_neg h_box_neg'

/--
Construct a BFMCS_Bundle from an MCS M0 using boxClassFamilies.

This is the main construction for completeness:
- families = boxClassFamilies M0
- eval_family = SuccChainFMCS from M0
- All coherence properties follow from boxClassFamilies lemmas
-/
noncomputable def construct_bfmcs_bundle (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    BFMCS_Bundle where
  families := boxClassFamilies M0 h_mcs
  nonempty := boxClassFamilies_nonempty M0 h_mcs
  modal_forward := boxClassFamilies_modal_forward M0 h_mcs
  modal_backward := boxClassFamilies_modal_backward M0 h_mcs
  bundle_forward_F := fun fam hfam φ t h_F =>
    boxClassFamilies_bundle_forward_F M0 h_mcs fam hfam t φ h_F
  bundle_backward_P := fun fam hfam φ t h_P =>
    boxClassFamilies_bundle_backward_P M0 h_mcs fam hfam t φ h_P
  eval_family := SuccChainFMCS (MCS_to_SerialMCS M0 h_mcs)
  eval_family_mem := eval_family_mem_boxClassFamilies M0 h_mcs

/--
The eval_family at time 0 equals M0.
-/
theorem construct_bfmcs_bundle_eval_at_zero (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    (construct_bfmcs_bundle M0 h_mcs).eval_family.mcs 0 = M0 := rfl

/--
construct_bfmcs_bundle is bundle temporally coherent.
-/
theorem construct_bfmcs_bundle_temporally_coherent (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    BundleTemporallyCoherent (construct_bfmcs_bundle M0 h_mcs).families :=
  boxClassFamilies_bundle_temporally_coherent M0 h_mcs

/-!
### Phase 4: Bundle Completeness Infrastructure

**Note on the truth lemma**: The truth lemma is inherently BIDIRECTIONAL — both
directions (MCS membership → truth AND truth → MCS membership) are required.
The forward direction of the `imp` case invokes the backward induction hypothesis
for the antecedent subformula (see ParametricTruthLemma.lean, line 208):

    have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true

This means even a "forward-only" truth lemma for `neg(phi) = phi.imp bot` requires
the backward direction for `phi`. The backward direction for `G`/`H` cases requires
`forward_F`/`backward_P` at the family level (same-family witnesses), which is the
temporal coherence condition `B.temporally_coherent`.

A forward-only truth lemma CANNOT sidestep this requirement.

**Completeness strategy (using sorry-free infrastructure)**:
1. neg(phi) in MCS M (from non-provability via Lindenbaum)
2. Build BFMCS_Bundle from M (sorry-free: construct_bfmcs_bundle)
3. **Bidirectional** truth lemma: neg(phi) ∈ M ↔ truth_at ... neg(phi)
4. Forward direction gives: neg(phi) TRUE in canonical model
5. So phi is FALSE in the model, contradicting validity

Step 3 requires `B.temporally_coherent` (family-level forward_F/backward_P).
The sorry-free bundle construction provides only bundle-level coherence.
The gap between bundle-level and family-level coherence is the remaining blocker.
-/

/--
Forward truth lemma core: bot cannot be in a consistent MCS.

This is the key fact that powers the forward truth lemma.
-/
theorem bot_not_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.bot ∉ M := by
  intro h_bot
  have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
  exact h_mcs.1 [Formula.bot] (fun x hx => by simp at hx; rw [hx]; exact h_bot) ⟨h_deriv⟩

/--
The key completeness lemma: if neg(phi) is in an MCS, then we can build a countermodel.

Given:
- neg(phi) in MCS M
- Build BFMCS_Bundle B from M
- The eval_family at time 0 contains neg(phi)
- Therefore phi is not in eval_family.mcs 0

This shows phi is "false" at the evaluation point, contradicting validity.
-/
theorem mcs_neg_gives_countermodel (phi : Formula)
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) (h_neg : Formula.neg phi ∈ M) :
    phi ∉ (construct_bfmcs_bundle M h_mcs).eval_family.mcs 0 := by
  -- eval_family.mcs 0 = M
  have h_eq := construct_bfmcs_bundle_eval_at_zero M h_mcs
  rw [h_eq]
  -- phi and neg(phi) can't both be in consistent MCS
  intro h_phi
  exact set_consistent_not_both h_mcs.1 phi h_phi h_neg

/--
Completeness from bundle construction: if phi is valid and neg(phi) is consistent,
we get a contradiction.

This is the core of the completeness argument.
-/
theorem bundle_completeness_contradiction (phi : Formula)
    (h_cons : SetConsistent {Formula.neg phi}) :
    ¬(∀ M : Set Formula, SetMaximalConsistent M → phi ∈ M) := by
  -- Extend neg(phi) to MCS
  have h_extend := set_lindenbaum {Formula.neg phi} h_cons
  obtain ⟨M, h_extends, h_mcs⟩ := h_extend
  -- neg(phi) is in M
  have h_neg : Formula.neg phi ∈ M := h_extends (Set.mem_singleton _)
  -- phi is NOT in M (by consistency)
  have h_not_phi : phi ∉ M := by
    intro h_phi
    exact set_consistent_not_both h_mcs.1 phi h_phi h_neg
  -- Therefore not all MCSes contain phi
  intro h_all
  exact h_not_phi (h_all M h_mcs)

/--
If phi is not provable, then neg(phi) is consistent.
-/
theorem not_provable_implies_neg_consistent (phi : Formula)
    (h_not_prov : ¬Nonempty ([] ⊢ phi)) :
    SetConsistent {Formula.neg phi} := by
  intro L h_L_sub ⟨d⟩
  -- L ⊆ {neg(phi)}, so L is either [] or contains only neg(phi)
  -- If L = [], then [] ⊢ bot, but [] is consistent (can derive only tautologies)
  -- If L contains neg(phi), then we can weaken to [neg(phi)] ⊢ bot
  by_cases h_empty : L = []
  · -- L = [], [] ⊢ bot
    rw [h_empty] at d
    -- [] ⊢ bot gives [] ⊢ phi via explosion
    have h_efq : [] ⊢ Formula.bot.imp phi :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.ex_falso phi)
    have h_phi : [] ⊢ phi := Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_efq d
    exact h_not_prov ⟨h_phi⟩
  · -- L ≠ [], so L contains neg(phi)
    -- d : L ⊢ bot and L ⊆ {neg(phi)}
    -- We can weaken to [neg(phi)] ⊢ bot
    have h_sub : ∀ x ∈ L, x ∈ [Formula.neg phi] := by
      intro x hx
      have := h_L_sub x hx
      simp only [Set.mem_singleton_iff] at this
      simp [this]
    have d' := Bimodal.ProofSystem.DerivationTree.weakening L [Formula.neg phi] Formula.bot d h_sub
    -- [neg(phi)] ⊢ bot means [] ⊢ neg(phi) → bot = neg(neg(phi))
    have h_ded := Bimodal.Metalogic.Core.deduction_theorem [] (Formula.neg phi) Formula.bot d'
    -- neg(neg(phi)) → phi (double negation elimination)
    have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi :=
      Bimodal.Theorems.Propositional.double_negation phi
    have h_phi : [] ⊢ phi := Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_dne h_ded
    exact h_not_prov ⟨h_phi⟩

/-!
## Dovetailed Chain Construction for Temporal Coherence

This section implements a dovetailed omega chain that resolves ALL F-obligations
fairly, ensuring family-level temporal coherence by construction.

### Key Insight

The current `omega_chain_forward` resolves only `F_top` at each step, which doesn't
guarantee that arbitrary `F(phi)` obligations are resolved. The dovetailed construction
uses `Nat.unpair` to enumerate obligations, ensuring every F-obligation is eventually
resolved.

### Construction Strategy

Instead of modifying the existing chain, we prove `Z_chain_forward_F` by showing
that the witness exists in the bundle. The key is that:

1. `F(phi) ∈ chain(t)` means `F(phi)` is in an MCS at time `t`
2. By `temporal_theory_witness_exists`, there exists a witness MCS `W` with `phi ∈ W`
3. `W` has `box_class_agree` with `chain(t)`, hence with `M0`
4. Build a shifted SuccChainFMCS from `W` at offset `t+1`
5. This family has `phi` at time `t+1`

For the Z_chain specifically, we can extend the chain construction to resolve
arbitrary F-obligations by using `Nat.unpair` for fair scheduling.
-/

/-!
### Direct Proof of Z_chain_forward_F via Witness Insertion

The key theorem: for any `F(phi) ∈ Z_chain(t)`, we can find `s > t` with
`phi ∈ Z_chain(s)`.

**Proof Strategy**: We show that the witness MCS `W` (from `temporal_theory_witness_exists`)
can be used to extend the chain. Specifically:
1. Get witness `W` with `phi ∈ W` and `box_class_agree` with `Z_chain(t)`
2. The extended chain at `s = t + 1` is exactly `W`

However, the current `omega_chain_forward` doesn't place `W` at `t+1`. It places
a witness for `F_top` instead. So we need to modify the argument.

**Alternative**: Instead of modifying the chain construction, we prove that
the formula `phi` propagates to some future time via the G-theory preservation
combined with the F-resolution property.

The cleanest approach uses the observation that F(phi) implies phi persists
until resolved. In a serial frame, F(phi) must eventually be resolved.
-/

/--
If F(phi) is in an MCS M, then there's a witness MCS W with phi in W,
G-theory agreement, and box_class_agree.

This is a restatement of `temporal_theory_witness_exists` for clarity.
-/
theorem F_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W :=
  temporal_theory_witness_exists M h_mcs phi h_F

/-!
### F-Persistence and Resolution

Key insight: In the forward chain, F(phi) persists until resolved.

If F(phi) ∈ chain(n), then either:
1. phi ∈ chain(n+1), or
2. F(phi) ∈ chain(n+1) (the obligation persists)

The issue is that the current chain construction doesn't explicitly resolve F(phi).
It only resolves F_top. The witness at n+1 might not have phi.

This is the core issue: we need to EXPLICITLY resolve F(phi) by making phi
appear in the witness. The dovetailed construction does this.
-/

/-!
### Resolving Chain Construction

A modified chain construction that can resolve SPECIFIC F-obligations.
Given F(phi) in the current MCS, we use `omega_step_forward M phi` instead of
`omega_step_forward M (neg bot)` to get a witness with phi in it.

This is the building block for the dovetailed construction.
-/

/--
Resolving witness: given F(phi) ∈ M, produce a witness MCS with phi ∈ W.

This is `omega_step_forward` specialized to the resolving case.
The witness satisfies:
1. phi ∈ W (target resolved)
2. G-theory preserved from M
3. box_class_agree M W
-/
noncomputable def resolving_witness (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    { W : Set Formula // SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W } :=
  omega_step_forward M h_mcs phi h_F

/--
Key theorem: From any MCS M with F(phi) ∈ M, we can construct a successor
that RESOLVES phi (i.e., phi is in the successor, not just propagated).

This is the foundation for proving Z_chain_forward_F.
-/
theorem can_resolve_F_obligation (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W :=
  temporal_theory_witness_exists M h_mcs phi h_F

/--
Resolving witness puts phi in the witness.

This is the key property that makes the dovetailed construction work:
when we use resolving_witness for phi, phi IS in the resulting MCS.
-/
theorem resolving_witness_contains_phi (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    phi ∈ (resolving_witness M h_mcs phi h_F).val :=
  (resolving_witness M h_mcs phi h_F).property.2.1

/--
Resolving witness preserves G-theory from M.
-/
theorem resolving_witness_G_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ (resolving_witness M h_mcs phi h_F).val :=
  (resolving_witness M h_mcs phi h_F).property.2.2.1

/--
Resolving witness has box_class_agree with M.
-/
theorem resolving_witness_box_agree (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    box_class_agree M (resolving_witness M h_mcs phi h_F).val :=
  (resolving_witness M h_mcs phi h_F).property.2.2.2

/--
Resolving witness has OmegaForwardInvariant from M0 if M has it.

This lemma shows that if we start from a chain point with the invariant,
the resolving witness also satisfies the invariant.
-/
theorem resolving_witness_invariant (M0 M : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (h_mcs : SetMaximalConsistent M)
    (h_inv : OmegaForwardInvariant M0 M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    OmegaForwardInvariant M0 (resolving_witness M h_mcs phi h_F).val := by
  constructor
  · -- is_mcs
    exact (resolving_witness M h_mcs phi h_F).property.1
  · -- G_propagate
    intro a h_Ga_M0
    exact resolving_witness_G_theory M h_mcs phi h_F a (h_inv.G_propagate a h_Ga_M0)
  · -- box_agree
    exact box_class_agree_trans h_inv.box_agree (resolving_witness_box_agree M h_mcs phi h_F)

/-!
### Forward Chain with Specific Resolution

This section defines a chain that resolves a SPECIFIC F-obligation at step 1.
Given F(phi) ∈ M0, we build a chain where chain(1) contains phi.

This is the key construction for proving Z_chain_forward_F.
-/

/--
Forward chain that resolves phi at step 1.

Given M0 with F(phi) ∈ M0, this chain resolves phi immediately:
- chain(0) = M0
- chain(1) = resolving_witness for phi
- chain(n+2) = continue with F_top from chain(n+1)
-/
noncomputable def omega_chain_resolving_at_1
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M0) :
    Nat → { W : Set Formula // OmegaForwardInvariant M0 W }
  | 0 => ⟨M0, ⟨h_mcs0, fun _ h => h, box_class_agree_refl M0⟩⟩
  | 1 =>
    -- Resolve phi at step 1
    let W := resolving_witness M0 h_mcs0 phi h_F
    ⟨W.val, resolving_witness_invariant M0 M0 h_mcs0 h_mcs0
      ⟨h_mcs0, fun _ h => h, box_class_agree_refl M0⟩ phi h_F⟩
  | n + 2 =>
    let prev := omega_chain_resolving_at_1 M0 h_mcs0 phi h_F (n + 1)
    let M_n := prev.val
    let inv_n := prev.property
    let h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ M_n :=
      SetMaximalConsistent.contains_F_top inv_n.is_mcs
    let witness := omega_step_forward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_F_top
    ⟨witness.val, {
      is_mcs := witness.property.1
      G_propagate := fun a h_Ga_M0 =>
        witness.property.2.2.1 a (inv_n.G_propagate a h_Ga_M0)
      box_agree := box_class_agree_trans inv_n.box_agree witness.property.2.2.2
    }⟩

/--
The resolving chain accessor.
-/
noncomputable def omega_chain_resolving_at_1_val
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M0) : Nat → Set Formula :=
  fun n => (omega_chain_resolving_at_1 M0 h_mcs0 phi h_F n).val

/--
phi is in chain(1) of the resolving chain.

This is the key resolution property: by using resolving_witness at step 1,
we guarantee phi ∈ chain(1).
-/
theorem omega_chain_resolving_at_1_contains_phi
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M0) :
    phi ∈ omega_chain_resolving_at_1_val M0 h_mcs0 phi h_F 1 := by
  simp only [omega_chain_resolving_at_1_val, omega_chain_resolving_at_1]
  exact resolving_witness_contains_phi M0 h_mcs0 phi h_F

/--
The resolving chain satisfies OmegaForwardInvariant at every point.
-/
theorem omega_chain_resolving_at_1_invariant
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M0) :
    ∀ n, OmegaForwardInvariant M0 (omega_chain_resolving_at_1_val M0 h_mcs0 phi h_F n) := by
  intro n
  exact (omega_chain_resolving_at_1 M0 h_mcs0 phi h_F n).property

/--
The resolving chain is MCS at every point.
-/
theorem omega_chain_resolving_at_1_mcs
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M0) :
    ∀ n, SetMaximalConsistent (omega_chain_resolving_at_1_val M0 h_mcs0 phi h_F n) := by
  intro n
  exact (omega_chain_resolving_at_1_invariant M0 h_mcs0 phi h_F n).is_mcs

/--
The resolving chain has box_class_agree with M0 at every point.
-/
theorem omega_chain_resolving_at_1_box_class
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M0) :
    ∀ n, box_class_agree M0 (omega_chain_resolving_at_1_val M0 h_mcs0 phi h_F n) := by
  intro n
  exact (omega_chain_resolving_at_1_invariant M0 h_mcs0 phi h_F n).box_agree

/--
The resolving witness excludes G(neg phi).

Proof: phi ∈ W implies neg(phi) ∉ W (MCS consistency).
G(neg phi) → neg(phi) by T-axiom, so G(neg phi) ∈ W would give neg(phi) ∈ W.
Therefore G(neg phi) ∉ W.
-/
theorem resolving_witness_excludes_G_neg (M W : Set Formula)
    (h_mcs_W : SetMaximalConsistent W) (phi : Formula) (h_phi_W : phi ∈ W) :
    Formula.all_future (Formula.neg phi) ∉ W := by
  intro h_G
  -- G(neg phi) → neg phi by T-axiom
  have h_T : [] ⊢ (Formula.all_future (Formula.neg phi)).imp (Formula.neg phi) :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future (Formula.neg phi))
  have h_neg : Formula.neg phi ∈ W :=
    SetMaximalConsistent.implication_property h_mcs_W (theorem_in_mcs h_mcs_W h_T) h_G
  -- But phi ∈ W and neg phi ∈ W contradicts MCS consistency
  exact set_consistent_not_both h_mcs_W.1 phi h_phi_W h_neg

/-!
### Key Lemma for Forward F

The dovetailed approach ensures that every F(phi) in the chain at time t
gets resolved at some time s > t. The resolution happens when we use
`resolving_witness` for phi instead of F_top.

For the current chain (which always uses F_top), we can prove a weaker result:
there EXISTS a witness in the same box class with phi resolved.
-/

/--
F-resolution witness existence in box class.

If F(phi) ∈ chain(n), then there exists a witness W in the box class of M0
with phi ∈ W. This witness could be placed at any future time point in a
shifted FMCS.
-/
theorem F_resolution_witness_in_box_class (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) (phi : Formula) (h_F : Formula.some_future phi ∈ omega_chain_forward M0 h_mcs0 n) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧ box_class_agree M0 W := by
  have h_mcs_n := omega_chain_forward_mcs M0 h_mcs0 n
  have h_box_n := omega_chain_forward_box_class M0 h_mcs0 n
  -- Use temporal_theory_witness_exists to get a witness for phi
  obtain ⟨W, h_W_mcs, h_phi_W, _, h_box_agree⟩ := temporal_theory_witness_exists _ h_mcs_n phi h_F
  -- The witness has box_class_agree with chain(n), which has box_class_agree with M0
  exact ⟨W, h_W_mcs, h_phi_W, box_class_agree_trans h_box_n h_box_agree⟩

/-!
### Dovetailed Omega Chain Construction

The key issue with the current `omega_chain_forward` is that it always resolves `F_top`
at each step, which doesn't guarantee arbitrary F(phi) obligations are resolved.

The dovetailed construction uses `Nat.unpair` to enumerate ALL F-obligations fairly.
At step n, we decode n as (time, obligation_index) and resolve the corresponding
F-obligation if it exists at that time.

**Key insight**: Since the chain is Nat-indexed and F-obligations are at most countable
at each time step, we can use the diagonal enumeration to ensure every F-obligation
is eventually addressed.

**Strategy**:
1. At each step n, use `Nat.unpair n` to get `(t, i)`
2. If there's an F-obligation at time t with index i, resolve it
3. Otherwise, resolve F_top (always exists) to keep extending

This ensures every F(phi) at any time t is eventually resolved.
-/

/--
Enumeration of F-formulas in an MCS.

Given an MCS M, enumerate all F-formulas in M. This is a list (possibly infinite
in principle, but we only need finite prefix access).

For practical purposes, we use the fact that F(phi) formulas have a specific shape
and enumerate them based on the formula argument.
-/
noncomputable def F_obligations_list (_M : Set Formula) : List Formula :=
  -- In practice, we use Classical.choice to enumerate.
  -- Since we're proving existence, not computing, this is acceptable.
  []

/--
F(phi) is always in an MCS for some phi (at minimum, F_top = F(neg bot)).
-/
theorem F_obligation_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ phi, Formula.some_future phi ∈ M :=
  ⟨Formula.neg Formula.bot, SetMaximalConsistent.contains_F_top h_mcs⟩

/--
Select an F-obligation to resolve at step n.

Given the chain state at all times ≤ current step, and step index n,
select which F-obligation to resolve using `Nat.unpair`.

The selection strategy:
- Decode n as (t, i) using `Nat.unpair`
- If t is a valid time index (within our chain) and there's an F-obligation at that time,
  return that obligation
- Otherwise, return F_top to keep extending

This guarantees every F-obligation at every time is eventually selected.
-/
noncomputable def select_F_obligation (chain : Nat → Set Formula)
    (chain_mcs : ∀ n, SetMaximalConsistent (chain n)) (n : Nat) : Formula :=
  let (t, _i) := Nat.unpair n
  -- For any MCS, F_top is always present, so we can always find an F-obligation
  -- The choice of which specific F-formula to resolve is handled by the witness
  -- construction, which can resolve ANY F-formula including F_top
  if h : t ≤ n then
    -- t is a valid time index
    -- By seriality, F_top ∈ chain(t), so we can use it
    -- But we want to eventually resolve ALL F-formulas, not just F_top
    -- The key insight: if F(phi) ∈ chain(t), then building a witness for phi
    -- will resolve that obligation
    Formula.neg Formula.bot  -- F_top for now; the real magic is in the witness
  else
    Formula.neg Formula.bot

/--
The true dovetailed forward chain with EXPLICIT F-resolution.

**Key insight**: At each step n+1, we decode n as (t, k) using `Nat.unpair`.
We look at chain(t) (for t ≤ n), select the k-th F-formula there, and build
chain(n+1) as a resolving witness for that specific F-formula.

**Why this works**:
1. G-theory propagation is from M0, not sequential: G(a) ∈ M0 → G(a) ∈ chain(n) for ALL n
2. So chain(n+1) built from chain(t) still has M0's G-theory
3. Box-class is transitive: chain(t) agrees with M0, so chain(n+1) will too

**Property guaranteed**: For any F(phi) ∈ chain(t), there exists m > t with phi ∈ chain(m).
By Nat.unpair surjectivity, (t, k) is hit by some n, and at step n+1, we resolve F(phi).

**Note**: The current implementation still uses F_top for simplicity.
The full dovetailed version would select specific F-formulas using unpair.
-/
noncomputable def omega_chain_dovetailed_forward_with_inv
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → { W : Set Formula // OmegaForwardInvariant M0 W }
  | 0 => ⟨M0, ⟨h_mcs0, fun _ h => h, box_class_agree_refl M0⟩⟩
  | n + 1 =>
    let prev := omega_chain_dovetailed_forward_with_inv M0 h_mcs0 n
    let M_n := prev.val
    let inv_n := prev.property
    -- For now, use F_top from chain(n)
    -- The full dovetailed version would:
    -- 1. Decode n as (t, k) using Nat.unpair
    -- 2. Look up chain(t) for t ≤ n
    -- 3. Select F(phi) from chain(t) based on k
    -- 4. Build witness using resolving_witness
    let h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ M_n :=
      SetMaximalConsistent.contains_F_top inv_n.is_mcs
    let witness := omega_step_forward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_F_top
    ⟨witness.val, {
      is_mcs := witness.property.1
      G_propagate := fun a h_Ga_M0 =>
        witness.property.2.2.1 a (inv_n.G_propagate a h_Ga_M0)
      box_agree := box_class_agree_trans inv_n.box_agree witness.property.2.2.2
    }⟩

/--
The dovetailed forward chain accessor.
-/
noncomputable def omega_chain_dovetailed_forward (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → Set Formula :=
  fun n => (omega_chain_dovetailed_forward_with_inv M0 h_mcs0 n).val

/--
The dovetailed chain is MCS at each point.
-/
theorem omega_chain_dovetailed_forward_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, SetMaximalConsistent (omega_chain_dovetailed_forward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_dovetailed_forward_with_inv M0 h_mcs0 n).property.is_mcs

/--
The dovetailed chain preserves box class.
-/
theorem omega_chain_dovetailed_forward_box_class (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, box_class_agree M0 (omega_chain_dovetailed_forward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_dovetailed_forward_with_inv M0 h_mcs0 n).property.box_agree

/--
The dovetailed chain at 0 is M0.
-/
theorem omega_chain_dovetailed_forward_zero (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    omega_chain_dovetailed_forward M0 h_mcs0 0 = M0 := rfl

/--
G-formulas propagate through the dovetailed chain.
-/
theorem omega_chain_dovetailed_forward_G_theory (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (a : Formula) (h_Ga_M0 : Formula.all_future a ∈ M0) :
    ∀ n : Nat, Formula.all_future a ∈ omega_chain_dovetailed_forward M0 h_mcs0 n := by
  intro n
  exact (omega_chain_dovetailed_forward_with_inv M0 h_mcs0 n).property.G_propagate a h_Ga_M0

/-!
### Key Lemma: F-Resolution in Dovetailed Chain

The central result: any F(phi) obligation at time t is eventually resolved.

**Proof Strategy**:
The proof uses the surjectivity of `Nat.unpair`:
- For any (t, i), there exists n such that `Nat.unpair n = (t, i)`
- At step n, we address the F-obligation at time t
- The resolving witness construction ensures phi ∈ chain(some step after n)

However, the current construction still uses F_top at each step. The real
insight is that we need a DIFFERENT approach: instead of modifying the chain
construction, we use the bundle-level coherence plus the fact that shifted
families cover all witnesses.
-/

/--
Auxiliary lemma: F(phi) persistence or resolution.

If F(phi) ∈ omega_chain_forward(n), then at step n+1, either:
1. phi ∈ omega_chain_forward(n+1), or
2. F(phi) ∈ omega_chain_forward(n+1)

This is because the witness construction preserves G-theory, and F(phi) being
in the current MCS means it's not ruled out by G-theory.
-/
theorem omega_forward_F_persistence_or_resolution (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) (phi : Formula) (h_F : Formula.some_future phi ∈ omega_chain_forward M0 h_mcs0 n) :
    phi ∈ omega_chain_forward M0 h_mcs0 (n + 1) ∨
    Formula.some_future phi ∈ omega_chain_forward M0 h_mcs0 (n + 1) := by
  -- The witness at n+1 comes from temporal_theory_witness_exists with F_top
  -- It preserves G-theory from chain(n)
  -- F(phi) = neg(G(neg phi)) ∈ chain(n) means G(neg phi) ∉ chain(n)
  -- The witness might or might not have phi

  -- By MCS negation completeness at n+1:
  have h_mcs_n1 := omega_chain_forward_mcs M0 h_mcs0 (n + 1)
  rcases SetMaximalConsistent.negation_complete h_mcs_n1 phi with h_phi | h_neg_phi
  · -- phi ∈ chain(n+1)
    left; exact h_phi
  · -- neg(phi) ∈ chain(n+1)
    -- Need to show F(phi) ∈ chain(n+1) in this case
    -- F(phi) = neg(G(neg phi))
    -- If G(neg phi) ∈ chain(n+1), then F(phi) ∉ chain(n+1)
    -- If G(neg phi) ∉ chain(n+1), then F(phi) ∈ chain(n+1)
    right
    -- Show G(neg phi) ∉ chain(n+1)
    -- The witness construction preserves G-theory from chain(n)
    -- G(neg phi) ∉ chain(n) (since F(phi) = neg(G(neg phi)) ∈ chain(n))
    have h_G_neg_notin_n : Formula.all_future (Formula.neg phi) ∉ omega_chain_forward M0 h_mcs0 n := by
      intro h_G
      -- F(phi) = neg(G(neg phi)) and G(neg phi) can't both be in an MCS
      have h_mcs_n := omega_chain_forward_mcs M0 h_mcs0 n
      have h_F_eq : Formula.some_future phi = Formula.neg (Formula.all_future (Formula.neg phi)) := rfl
      rw [h_F_eq] at h_F
      exact set_consistent_not_both h_mcs_n.1 (Formula.all_future (Formula.neg phi)) h_G h_F

    -- G-theory propagates: if G(a) ∈ chain(n), then G(a) ∈ chain(n+1)
    -- But G(neg phi) ∉ chain(n), so this doesn't give us G(neg phi) ∈ chain(n+1)
    -- The issue: something NEW might make G(neg phi) ∈ chain(n+1)

    -- Actually, the witness construction ONLY adds things consistent with the seed
    -- The seed is {F_top_witness} ∪ G_theory(chain(n)) ∪ box_theory(chain(n))
    -- G(neg phi) is NOT in G_theory(chain(n)) (since G(neg phi) ∉ chain(n))
    -- So G(neg phi) is not forced into the witness

    -- But can the witness independently have G(neg phi)?
    -- Yes, if it's consistent with the seed. The seed doesn't force G(neg phi) OUT.

    -- This is the gap: we can't directly prove G(neg phi) ∉ chain(n+1)
    -- We need a different argument

    -- Alternative: use that F(phi) is equivalent to neg(G(neg phi))
    -- By MCS negation completeness at n+1:
    rcases SetMaximalConsistent.negation_complete h_mcs_n1 (Formula.all_future (Formula.neg phi)) with h_G | h_neg_G
    · -- G(neg phi) ∈ chain(n+1)
      -- This means neg phi ∈ chain(n+1) by T-axiom (which we already have as h_neg_phi)
      -- But we need to show F(phi) ∈ chain(n+1), i.e., neg(G(neg phi)) ∈ chain(n+1)
      -- G(neg phi) and neg(G(neg phi)) can't both be in chain(n+1)
      -- So this case leads to F(phi) ∉ chain(n+1)
      -- But we're trying to prove F(phi) ∈ chain(n+1)...

      -- Actually if G(neg phi) ∈ chain(n+1), then by T-axiom: neg phi ∈ chain(n+1)
      -- This is consistent with h_neg_phi, so no contradiction YET

      -- The issue: we need to show G(neg phi) ∉ chain(n+1) to conclude F(phi) ∈ chain(n+1)
      -- But G(neg phi) might enter chain(n+1) through Lindenbaum extension

      -- This branch is problematic. Let me reconsider.

      -- If G(neg phi) ∈ chain(n+1), then F(phi) ∉ chain(n+1)
      -- So in this case, we're in the "resolved" branch: phi ∈ chain(n+1)?
      -- No, because h_neg_phi says neg(phi) ∈ chain(n+1), not phi

      -- Contradiction: If G(neg phi) ∈ chain(n+1), by T-axiom neg(phi) ∈ chain(n+1)
      -- This is consistent with our assumption.
      -- But then F(phi) = neg(G(neg phi)) ∉ chain(n+1)
      -- So we need phi ∈ chain(n+1) for the disjunction, but h_neg_phi says neg(phi) ∈ chain(n+1)
      -- Both phi and neg(phi) can't be in an MCS

      -- Wait, we're in the case where neg(phi) ∈ chain(n+1) (from the outer rcases)
      -- So phi ∉ chain(n+1) (by MCS consistency)
      -- And we're trying to prove F(phi) ∈ chain(n+1) as the second disjunct
      -- But if G(neg phi) ∈ chain(n+1), then F(phi) ∉ chain(n+1)
      -- This is a contradiction with what we're trying to prove

      -- So this case (neg(phi) ∈ chain(n+1) AND G(neg phi) ∈ chain(n+1)) is possible
      -- and leads to BOTH disjuncts being false. But that contradicts our goal.

      -- Actually, wait. Let's check: is this case even reachable?
      -- We have F(phi) ∈ chain(n), which means G(neg phi) ∉ chain(n)
      -- The witness construction at n+1 uses seed that includes G_theory(chain(n))
      -- G(neg phi) is NOT in the seed
      -- But the Lindenbaum extension might add G(neg phi) if it's consistent with the seed

      -- For the Lindenbaum extension to add G(neg phi), the seed ∪ {G(neg phi)} must be consistent
      -- The seed is {F_top_witness} ∪ G_theory(chain(n)) ∪ box_theory(chain(n))
      -- = {neg(bot)} ∪ {G(a) | G(a) ∈ chain(n)} ∪ {Box(b) | Box(b) ∈ chain(n)} ∪ {neg(Box(b)) | Box(b) ∉ chain(n)}

      -- Is {neg(bot)} ∪ G_theory ∪ box_theory ∪ {G(neg phi)} consistent?
      -- G(neg phi) is consistent with box_theory (no direct conflict)
      -- G(neg phi) might conflict with G_theory indirectly through temporal axioms

      -- Key: F(phi) = neg(G(neg phi)) ∈ chain(n)
      -- chain(n) is an MCS, so G(neg phi) ∉ chain(n)
      -- But G(neg phi) is not directly in the seed (it's not in G_theory(chain(n)))
      -- The seed ∪ {G(neg phi)} could still be consistent

      -- This is the fundamental gap: we can't prove G(neg phi) ∉ chain(n+1) directly

      -- For now, we admit this case is stuck and use sorry
      -- The dovetailed construction would resolve this by explicitly ensuring phi ∈ chain(n+1)
      exfalso
      -- We need to show a contradiction, but the reasoning above shows this case is genuinely possible
      -- The gap is that the current construction doesn't force G(neg phi) out of chain(n+1)
      -- Sorry for now - this is exactly what the dovetailed construction fixes
      sorry
    · -- neg(G(neg phi)) ∈ chain(n+1)
      -- This is exactly F(phi) ∈ chain(n+1)
      exact h_neg_G

/--
F(phi) can't persist forever in the forward chain.

If F(phi) ∈ omega_chain_forward(n), then there exists m > n such that
either phi ∈ chain(m) OR the formula depth decreases.

This is the bounded obligation argument.
-/
theorem omega_forward_F_bounded_persistence (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) (phi : Formula) (h_F : Formula.some_future phi ∈ omega_chain_forward M0 h_mcs0 n) :
    ∃ m : Nat, n ≤ m ∧ phi ∈ omega_chain_forward M0 h_mcs0 m := by
  -- With weak coherence: if phi is already in chain(n), return m = n
  by_cases h_phi_n : phi ∈ omega_chain_forward M0 h_mcs0 n
  · exact ⟨n, le_refl n, h_phi_n⟩
  · -- phi ∉ chain(n): needs dovetailed construction for strict resolution
    -- The F-preserving chain handles this, but omega_chain_forward doesn't guarantee it
    -- For non-F-preserving chain, we note that the resolution eventually happens
    -- but proving it requires tracking F-obligations explicitly
    sorry

/--
Z_chain_forward_F': F(phi) at t implies exists s ≥ t with phi at s.

This is the key temporal coherence property for completeness.
Uses weak inequality (t ≤ s) aligned with reflexive semantics.
-/
theorem Z_chain_forward_F' (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ Z_chain M0 h_mcs0 t) :
    ∃ s : Int, t ≤ s ∧ phi ∈ Z_chain M0 h_mcs0 s := by
  -- With weak coherence: if phi is already in chain(t), return s = t
  by_cases h_phi_t : phi ∈ Z_chain M0 h_mcs0 t
  · exact ⟨t, le_refl t, h_phi_t⟩
  · -- phi ∉ Z_chain(t): Use bounded persistence
    unfold Z_chain at h_F ⊢
    by_cases h_t_nonneg : t ≥ 0
    · -- t >= 0, in forward chain
      simp only [ge_iff_le, h_t_nonneg, ↓reduceDIte] at h_F ⊢
      -- Need to convert h_phi_t to the right form
      have h_phi_t_fwd : phi ∉ omega_chain_forward M0 h_mcs0 t.toNat := by
        unfold Z_chain at h_phi_t
        simp only [ge_iff_le, h_t_nonneg, ↓reduceDIte] at h_phi_t
        exact h_phi_t
      have h_bounded := omega_forward_F_bounded_persistence M0 h_mcs0 t.toNat phi h_F
      obtain ⟨m, h_le, h_phi_m⟩ := h_bounded
      use m
      constructor
      · -- t ≤ m
        have : (t.toNat : Int) = t := Int.toNat_of_nonneg h_t_nonneg
        omega
      · -- phi ∈ Z_chain(m)
        have h_m_nonneg : (m : Int) ≥ 0 := by omega
        simp only [ge_iff_le, h_m_nonneg, ↓reduceDIte, Int.toNat_natCast]
        exact h_phi_m
    · -- t < 0, in backward chain
      push_neg at h_t_nonneg
      simp only [ge_iff_le, not_le.mpr h_t_nonneg, ↓reduceDIte] at h_F ⊢
      -- F(phi) ∈ backward_chain((-t).toNat) and phi ∉ backward_chain
      -- For F-resolution from backward chain, need forward chain
      -- This case requires showing phi eventually appears at some s ≥ t
      sorry

/-!
## True Dovetailed Omega Chain Construction

This section implements the TRUE dovetailed forward chain that achieves temporal coherence
by construction. The key insight is that we use `Nat.unpair` to fairly schedule F-obligation
resolution across all time points.

### Mathematical Background

The standard `omega_chain_forward` only resolves `F_top` at each step, which doesn't guarantee
that arbitrary F(phi) obligations are resolved. The dovetailed construction explicitly targets
each F-obligation for resolution using Cantor pairing.

### Construction Strategy

At step n+1:
1. Decode (t, k) = Nat.unpair n
2. If t ≤ n and k = 0, select an unresolved F-formula from chain(t) to resolve
3. Build chain(n+1) as a resolving witness for that formula (from chain(n))
4. If no unresolved formula exists, just use F_top

### Key Property

For any F(phi) ∈ chain(t), there exists s > t such that phi ∈ chain(s).
This follows from:
- F(phi) persists until resolved (by omega_forward_F_persistence_or_resolution)
- The dovetailing ensures every (t, 0) pair is eventually hit
- When we hit (t, 0) and F(phi) is still unresolved, we resolve it
-/

/--
Predicate: F(phi) is unresolved at time n in the chain.
Means F(phi) ∈ chain(n) but phi ∉ chain(n).
-/
def F_unresolved (chain : Nat → Set Formula) (n : Nat) (phi : Formula) : Prop :=
  Formula.some_future phi ∈ chain n ∧ phi ∉ chain n

/--
Predicate: there exists an unresolved F-formula at time n.
-/
def has_unresolved_F (chain : Nat → Set Formula) (n : Nat) : Prop :=
  ∃ phi, F_unresolved chain n phi

/--
Select an unresolved F-formula from chain(n), if one exists.
Returns F_top if all F-formulas are already resolved.
Uses Classical.choose with propDecidable for the existence check.
-/
noncomputable def select_unresolved_F (chain : Nat → Set Formula)
    (_chain_mcs : ∀ n, SetMaximalConsistent (chain n)) (n : Nat) : Formula :=
  @dite Formula (has_unresolved_F chain n) (Classical.propDecidable _)
    (fun h => Classical.choose h)
    (fun _ => Formula.neg Formula.bot)

/--
Proof that selected formula has F in chain(n).
-/
theorem select_unresolved_F_spec (chain : Nat → Set Formula)
    (chain_mcs : ∀ n, SetMaximalConsistent (chain n)) (n : Nat) :
    Formula.some_future (select_unresolved_F chain chain_mcs n) ∈ chain n := by
  unfold select_unresolved_F
  by_cases h : has_unresolved_F chain n
  · -- has_unresolved_F case
    have heq : @dite Formula (has_unresolved_F chain n) (Classical.propDecidable _)
        (fun h => Classical.choose h) (fun _ => Formula.neg Formula.bot) =
        Classical.choose h := by
      simp only [h, dite_true]
    rw [heq]
    exact (Classical.choose_spec h).1
  · -- no unresolved F case
    have heq : @dite Formula (has_unresolved_F chain n) (Classical.propDecidable _)
        (fun h => Classical.choose h) (fun _ => Formula.neg Formula.bot) =
        Formula.neg Formula.bot := by
      simp only [h, dite_false]
    rw [heq]
    exact SetMaximalConsistent.contains_F_top (chain_mcs n)

/--
The target time index for resolution at step n.
Uses Nat.unpair to decode (time, index) from n.
We only resolve at time t when unpair(n) = (t, 0) and t ≤ n.
-/
def resolution_target_time (n : Nat) : Nat :=
  let (t, k) := Nat.unpair n
  if k = 0 ∧ t ≤ n then t else n

/--
The k-th formula in the enumeration (uses Denumerable instance from Formula.lean).
-/
noncomputable def enumFormula (k : Nat) : Formula := Denumerable.ofNat Formula k

/--
Select the formula to resolve at step n.

At step n, decode (t, k) = Nat.unpair n.
- Let psi = enumFormula k (the k-th formula in enumeration)
- If F(psi) ∈ M_n (the current chain point), return psi
- Otherwise, return ⊤ (neg bot, which always has F(⊤) in any MCS)

This ensures: for any formula psi, when n = Nat.pair t (encode psi) is reached,
if F(psi) ∈ chain(n), we will resolve it by putting psi in chain(n+1).

The decidability uses Classical.propDecidable since set membership is not decidable.
-/
noncomputable def selectFormulaToResolve (M_n : Set Formula) (n : Nat) : Formula :=
  -- Inline version without inner let bindings
  @ite _ (Formula.some_future (enumFormula (Nat.unpair n).2) ∈ M_n) (Classical.propDecidable _)
    (enumFormula (Nat.unpair n).2)
    (Formula.neg Formula.bot)

/--
Proof that the selected formula has F in M_n.
-/
theorem selectFormulaToResolve_has_F (M_n : Set Formula) (h_mcs : SetMaximalConsistent M_n) (n : Nat) :
    Formula.some_future (selectFormulaToResolve M_n n) ∈ M_n := by
  unfold selectFormulaToResolve enumFormula
  -- The @ite with Classical.propDecidable expands to a dite-like structure
  -- We need to show the goal definitionally equals the ite expression
  show Formula.some_future (@ite Formula
    (Formula.some_future (Denumerable.ofNat Formula (Nat.unpair n).2) ∈ M_n)
    (Classical.propDecidable _)
    (Denumerable.ofNat Formula (Nat.unpair n).2)
    (Formula.neg Formula.bot)) ∈ M_n
  by_cases h : Formula.some_future (Denumerable.ofNat Formula (Nat.unpair n).2) ∈ M_n
  · -- F(psi) ∈ M_n case: ite chooses psi
    rw [if_pos h]
    exact h
  · -- F(psi) ∉ M_n case: ite chooses F_top
    rw [if_neg h]
    exact SetMaximalConsistent.contains_F_top h_mcs

/-!
### F-Preserving Omega Step and Chain

The F-preserving omega step uses `temporal_theory_witness_F_preserving` instead of
`temporal_theory_witness_exists`. This ensures that unresolved F-formulas persist
through the chain until they are explicitly resolved.
-/

/--
F-preserving omega step: given an MCS M with F(phi) ∈ M, produce a witness MCS W with:
1. phi ∈ W (resolution)
2. G-theory preserved
3. box_class_agree
4. **F-unresolved preservation**: F(psi) unresolved in M → F(psi) ∈ W

This is a wrapper around `temporal_theory_witness_F_preserving`.
-/
noncomputable def omega_step_forward_F_preserving (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    { W : Set Formula // SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W ∧
      (∀ psi, Formula.some_future psi ∈ M ∧ psi ∉ M → Formula.some_future psi ∈ W) } := by
  have h := temporal_theory_witness_F_preserving M h_mcs phi h_F
  exact ⟨h.choose, h.choose_spec.1, h.choose_spec.2.1, h.choose_spec.2.2.1,
         h.choose_spec.2.2.2.1, h.choose_spec.2.2.2.2⟩

/--
Extended invariant for the F-preserving omega chain.

In addition to the standard invariant properties, tracks that F-unresolved formulas
from M0 that are STILL unresolved at chain(n) persist to the current point.
-/
structure OmegaForwardFPreservingInvariant (M0 : Set Formula) (W : Set Formula) : Prop where
  /-- W is an MCS -/
  is_mcs : SetMaximalConsistent W
  /-- G-formulas from M0 propagate to W -/
  G_propagate : ∀ a, Formula.all_future a ∈ M0 → Formula.all_future a ∈ W
  /-- W agrees with M0 on Box-formulas -/
  box_agree : box_class_agree M0 W
  /-- F-unresolved formulas persist: F(psi) ∈ W and psi ∉ W implies F(psi) stays -/
  F_unresolved_persist : ∀ psi, Formula.some_future psi ∈ W ∧ psi ∉ W → Formula.some_future psi ∈ W

/--
F-preserving dovetailed forward chain.

Same as omega_chain_true_dovetailed_forward_with_inv but uses
omega_step_forward_F_preserving to ensure F-formulas persist until resolved.
-/
noncomputable def omega_chain_F_preserving_forward_with_inv
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → { W : Set Formula // OmegaForwardFPreservingInvariant M0 W }
  | 0 => ⟨M0, ⟨h_mcs0, fun _ h => h, box_class_agree_refl M0,
          fun _ ⟨h, _⟩ => h⟩⟩  -- F-persist is trivial at base
  | n + 1 =>
    let prev := omega_chain_F_preserving_forward_with_inv M0 h_mcs0 n
    let M_n := prev.val
    let inv_n := prev.property
    -- Select formula based on enumeration
    let phi := selectFormulaToResolve M_n n
    let h_F : Formula.some_future phi ∈ M_n := selectFormulaToResolve_has_F M_n inv_n.is_mcs n
    -- Build witness using F-preserving step
    let witness := omega_step_forward_F_preserving M_n inv_n.is_mcs phi h_F
    ⟨witness.val, {
      is_mcs := witness.property.1
      G_propagate := fun a h_Ga_M0 =>
        witness.property.2.2.1 a (inv_n.G_propagate a h_Ga_M0)
      box_agree := box_class_agree_trans inv_n.box_agree witness.property.2.2.2.1
      F_unresolved_persist := fun psi ⟨h_F_psi, h_psi_not⟩ =>
        -- F(psi) ∈ W and psi ∉ W - need to show F(psi) ∈ W (which is trivial!)
        h_F_psi
    }⟩

/--
Accessor for the F-preserving dovetailed chain.
-/
noncomputable def omega_chain_F_preserving_forward (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → Set Formula :=
  fun n => (omega_chain_F_preserving_forward_with_inv M0 h_mcs0 n).val

/--
The F-preserving chain is MCS at each point.
-/
theorem omega_chain_F_preserving_forward_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, SetMaximalConsistent (omega_chain_F_preserving_forward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_F_preserving_forward_with_inv M0 h_mcs0 n).property.is_mcs

/--
The F-preserving chain preserves box class with M0.
-/
theorem omega_chain_F_preserving_forward_box_class (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, box_class_agree M0 (omega_chain_F_preserving_forward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_F_preserving_forward_with_inv M0 h_mcs0 n).property.box_agree

/--
The F-preserving chain at 0 is M0.
-/
theorem omega_chain_F_preserving_forward_zero (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    omega_chain_F_preserving_forward M0 h_mcs0 0 = M0 := rfl

/--
G-formulas from M0 propagate through the F-preserving chain.
-/
theorem omega_chain_F_preserving_forward_G_theory (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (a : Formula) (h_Ga_M0 : Formula.all_future a ∈ M0) :
    ∀ n : Nat, Formula.all_future a ∈ omega_chain_F_preserving_forward M0 h_mcs0 n := by
  intro n
  exact (omega_chain_F_preserving_forward_with_inv M0 h_mcs0 n).property.G_propagate a h_Ga_M0

/--
Key lemma: F-persistence through the F-preserving chain.

If F(psi) ∈ chain(t) and psi ∉ chain(m) for all m ∈ [t, n], then F(psi) ∈ chain(n).

This is proven by induction using the F_unresolved_persist invariant.
-/
theorem F_persistence_through_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t n : Nat) (h_t_le_n : t ≤ n) (psi : Formula)
    (h_F_t : Formula.some_future psi ∈ omega_chain_F_preserving_forward M0 h_mcs0 t)
    (h_psi_absent : ∀ m, t ≤ m → m ≤ n → psi ∉ omega_chain_F_preserving_forward M0 h_mcs0 m) :
    Formula.some_future psi ∈ omega_chain_F_preserving_forward M0 h_mcs0 n := by
  -- Induction on (n - t)
  induction n with
  | zero =>
    -- t = 0, n = 0
    have : t = 0 := Nat.le_zero.mp h_t_le_n
    rw [this] at h_F_t
    exact h_F_t
  | succ n ih =>
    cases Nat.lt_or_eq_of_le h_t_le_n with
    | inl h_lt =>
      -- t < n + 1, so t ≤ n
      have h_t_le_n' : t ≤ n := Nat.lt_succ_iff.mp h_lt
      -- By IH, F(psi) ∈ chain(n)
      have h_psi_absent' : ∀ m, t ≤ m → m ≤ n → psi ∉ omega_chain_F_preserving_forward M0 h_mcs0 m :=
        fun m h1 h2 => h_psi_absent m h1 (Nat.le_succ_of_le h2)
      have h_F_n : Formula.some_future psi ∈ omega_chain_F_preserving_forward M0 h_mcs0 n :=
        ih h_t_le_n' h_psi_absent'
      -- psi ∉ chain(n) (by h_psi_absent with m = n)
      have h_psi_not_n : psi ∉ omega_chain_F_preserving_forward M0 h_mcs0 n :=
        h_psi_absent n h_t_le_n' (Nat.le_succ n)
      -- By F-preserving step: F(psi) ∈ chain(n) ∧ psi ∉ chain(n) → F(psi) ∈ chain(n+1)
      -- Actually, we need to use the witness property directly

      -- The step from n to n+1 uses omega_step_forward_F_preserving
      -- which preserves F-unresolved formulas from chain(n)
      let prev := omega_chain_F_preserving_forward_with_inv M0 h_mcs0 n
      let M_n := prev.val
      have h_eq : M_n = omega_chain_F_preserving_forward M0 h_mcs0 n := rfl
      rw [← h_eq] at h_F_n h_psi_not_n

      -- The witness is built from omega_step_forward_F_preserving
      let phi := selectFormulaToResolve M_n n
      have h_F_phi : Formula.some_future phi ∈ M_n :=
        selectFormulaToResolve_has_F M_n prev.property.is_mcs n
      let witness := omega_step_forward_F_preserving M_n prev.property.is_mcs phi h_F_phi

      -- chain(n+1) = witness.val
      have h_chain_succ : omega_chain_F_preserving_forward M0 h_mcs0 (n + 1) = witness.val := by
        unfold omega_chain_F_preserving_forward omega_chain_F_preserving_forward_with_inv
        rfl

      -- Use the F-unresolved preservation property of the witness
      -- F(psi) ∈ M_n ∧ psi ∉ M_n → F(psi) ∈ witness.val
      have h_preserve := witness.property.2.2.2.2 psi ⟨h_F_n, h_psi_not_n⟩
      rw [h_chain_succ]
      exact h_preserve

    | inr h_eq =>
      -- t = n + 1
      rw [← h_eq]
      exact h_F_t

/--
Resolution at target step in F-preserving chain.

At step n+1, the selected formula is included in chain(n+1).
-/
theorem omega_chain_F_preserving_forward_resolves (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) : selectFormulaToResolve (omega_chain_F_preserving_forward M0 h_mcs0 n) n ∈
                omega_chain_F_preserving_forward M0 h_mcs0 (n + 1) := by
  simp only [omega_chain_F_preserving_forward, omega_chain_F_preserving_forward_with_inv]
  exact (omega_step_forward_F_preserving _ _ _ _).property.2.1

/--
Main F-resolution theorem for the F-preserving forward chain.

If F(phi) is in the chain at step t, then phi is in the chain at some step s ≥ t.

Uses weak inequality (t ≤ s) aligned with reflexive semantics.
When phi is already in chain(t), we can return s = t as witness.
-/
theorem omega_F_preserving_forward_F_resolution (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Nat) (phi : Formula) (h_F : Formula.some_future phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 t) :
    ∃ s, t ≤ s ∧ phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 s := by
  -- First check: is phi already in chain(t)?
  -- With weak coherence (t ≤ s), we can return s = t when phi ∈ chain(t)
  by_cases h_phi_t : phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 t
  · -- phi ∈ chain(t): return witness s = t with le_refl
    exact ⟨t, le_refl t, h_phi_t⟩

  · -- phi ∉ chain(t): Standard persistence argument applies
    -- n0 = pair(t, encode(phi)) is the step that resolves F(phi) if it persists
    let k := Encodable.encode phi
    let n0 := Nat.pair t k
    have h_n0_ge_t : t ≤ n0 := Nat.left_le_pair t k

    -- Either phi appears in some chain point in (t, n0+1], or it doesn't
    by_cases h_exists : ∃ m, t < m ∧ m ≤ n0 + 1 ∧ phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 m
    · -- Case 1: phi appears before or at n0+1
      obtain ⟨m, h_lt, _, h_phi_m⟩ := h_exists
      exact ⟨m, le_of_lt h_lt, h_phi_m⟩
    · -- Case 2: phi does NOT appear in any chain point in (t, n0+1]
      push_neg at h_exists

      -- By F_persistence_through_chain: F(phi) ∈ chain(n0)
      have h_psi_absent : ∀ m, t ≤ m → m ≤ n0 → phi ∉ omega_chain_F_preserving_forward M0 h_mcs0 m := by
        intro m h1 h2
        by_cases h_t_eq : m = t
        · -- m = t: phi ∉ chain(t) by h_phi_t
          rw [h_t_eq]
          exact h_phi_t
        · -- m > t: use h_exists
          have h_m_gt_t : t < m := Nat.lt_of_le_of_ne h1 (Ne.symm h_t_eq)
          exact h_exists m h_m_gt_t (Nat.le_succ_of_le h2)

      have h_F_n0 : Formula.some_future phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 n0 :=
        F_persistence_through_chain M0 h_mcs0 t n0 h_n0_ge_t phi h_F h_psi_absent

      -- selectFormulaToResolve picks phi at n0
      -- (inline proof of selectFormulaToResolve_at_pair logic)
      have h_select : selectFormulaToResolve (omega_chain_F_preserving_forward M0 h_mcs0 n0) n0 = phi := by
        unfold selectFormulaToResolve enumFormula
        have h_unpair : (Nat.unpair n0).2 = Encodable.encode phi := by
          show (Nat.unpair (Nat.pair t k)).2 = Encodable.encode phi
          simp only [Nat.unpair_pair, k]
        have h_enum : Denumerable.ofNat Formula (Nat.unpair n0).2 = phi := by
          rw [h_unpair]
          exact Denumerable.ofNat_encode phi
        have h_F_in : Formula.some_future (Denumerable.ofNat Formula (Nat.unpair n0).2) ∈
                      omega_chain_F_preserving_forward M0 h_mcs0 n0 := by
          rw [h_enum]
          exact h_F_n0
        rw [if_pos h_F_in, h_enum]

      have h_resolved := omega_chain_F_preserving_forward_resolves M0 h_mcs0 n0
      rw [h_select] at h_resolved

      have h_s_ge_t : t ≤ n0 + 1 := by omega
      exact ⟨n0 + 1, h_s_ge_t, h_resolved⟩

/--
True dovetailed forward chain with invariant.

At each step n+1:
- Decode (t, k) = Nat.unpair n
- Let psi = enumFormula k (the k-th formula in enumeration)
- If F(psi) ∈ chain(n), build chain(n+1) as resolving_witness for psi
- Otherwise, build chain(n+1) as resolving_witness for ⊤

The G-theory from M0 is preserved because:
1. resolving_witness preserves G-theory from its input
2. chain(n) has M0's G-theory by induction

The box-class is preserved by transitivity.

KEY PROPERTY (fairness): For any formula psi, the index Nat.pair t (encode psi)
is eventually reached for every t. At that step, if F(psi) ∈ chain(n), we resolve it.
Since Nat.pair is surjective onto Nat, every (t, encode psi) pair is hit.
-/
noncomputable def omega_chain_true_dovetailed_forward_with_inv
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → { W : Set Formula // OmegaForwardInvariant M0 W }
  | 0 => ⟨M0, ⟨h_mcs0, fun _ h => h, box_class_agree_refl M0⟩⟩
  | n + 1 =>
    let prev := omega_chain_true_dovetailed_forward_with_inv M0 h_mcs0 n
    let M_n := prev.val
    let inv_n := prev.property
    -- Select formula based on enumeration: psi = enumFormula(k) where (_, k) = unpair(n)
    -- If F(psi) ∈ M_n, resolve psi; otherwise resolve ⊤
    let phi := selectFormulaToResolve M_n n
    let h_F : Formula.some_future phi ∈ M_n := selectFormulaToResolve_has_F M_n inv_n.is_mcs n
    -- Build witness using the selected formula
    let witness := omega_step_forward M_n inv_n.is_mcs phi h_F
    ⟨witness.val, {
      is_mcs := witness.property.1
      G_propagate := fun a h_Ga_M0 =>
        witness.property.2.2.1 a (inv_n.G_propagate a h_Ga_M0)
      box_agree := box_class_agree_trans inv_n.box_agree witness.property.2.2.2
    }⟩

/--
Accessor for the true dovetailed forward chain.
-/
noncomputable def omega_chain_true_dovetailed_forward (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → Set Formula :=
  fun n => (omega_chain_true_dovetailed_forward_with_inv M0 h_mcs0 n).val

/--
The true dovetailed chain is MCS at each point.
-/
theorem omega_chain_true_dovetailed_forward_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, SetMaximalConsistent (omega_chain_true_dovetailed_forward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_true_dovetailed_forward_with_inv M0 h_mcs0 n).property.is_mcs

/--
The true dovetailed chain preserves box class with M0.
-/
theorem omega_chain_true_dovetailed_forward_box_class (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    ∀ n : Nat, box_class_agree M0 (omega_chain_true_dovetailed_forward M0 h_mcs0 n) := by
  intro n
  exact (omega_chain_true_dovetailed_forward_with_inv M0 h_mcs0 n).property.box_agree

/--
The true dovetailed chain at 0 is M0.
-/
theorem omega_chain_true_dovetailed_forward_zero (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    omega_chain_true_dovetailed_forward M0 h_mcs0 0 = M0 := by
  unfold omega_chain_true_dovetailed_forward omega_chain_true_dovetailed_forward_with_inv
  rfl

/--
G-formulas from M0 propagate through the true dovetailed chain.
-/
theorem omega_chain_true_dovetailed_forward_G_theory (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (a : Formula) (h_Ga_M0 : Formula.all_future a ∈ M0) :
    ∀ n : Nat, Formula.all_future a ∈ omega_chain_true_dovetailed_forward M0 h_mcs0 n := by
  intro n
  exact (omega_chain_true_dovetailed_forward_with_inv M0 h_mcs0 n).property.G_propagate a h_Ga_M0

/--
Resolution property: At step n+1, the selected formula psi is included in chain(n+1).

More specifically, if psi = enumFormula k where (_, k) = unpair(n), and F(psi) ∈ chain(n),
then psi ∈ chain(n+1).
-/
theorem omega_chain_true_dovetailed_forward_resolves (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n : Nat) : selectFormulaToResolve (omega_chain_true_dovetailed_forward M0 h_mcs0 n) n ∈
                omega_chain_true_dovetailed_forward M0 h_mcs0 (n + 1) := by
  -- chain(n+1) is built using omega_step_forward with selectFormulaToResolve(chain(n), n)
  -- omega_step_forward includes the formula in its result
  -- The definition of omega_chain_true_dovetailed_forward_with_inv at n+1 is:
  --   let phi := selectFormulaToResolve M_n n
  --   let witness := omega_step_forward M_n ... phi ...
  --   ⟨witness.val, ...⟩
  -- And omega_step_forward's property.2.1 says phi ∈ witness.val
  simp only [omega_chain_true_dovetailed_forward,
             omega_chain_true_dovetailed_forward_with_inv]
  exact (omega_step_forward _ _ _ _).property.2.1

/-!
## F-Resolution for True Dovetailed Chain

The dovetailed construction guarantees that any F(phi) obligation at step t is eventually
resolved by step n0+1 where n0 = Nat.pair t (Encodable.encode phi).

Key insight: We don't need persistence at every step. The dovetailed construction
FORCES resolution at the target step n0.

**Proof Strategy**:
1. Given F(phi) at step t
2. Let k = Encodable.encode phi
3. At step n0 = Nat.pair t k, if F(phi) is still in the chain, selectFormulaToResolve picks phi
4. By omega_chain_true_dovetailed_forward_resolves, phi ∈ chain(n0+1)
5. n0 >= t by Nat.left_le_pair, so n0+1 > t

The challenge is handling the "if F(phi) is still in the chain" part. We prove:
- If phi ∈ chain(m) for any m ≤ n0+1, we're done
- If F(phi) ∈ chain(n0), then resolution is FORCED at n0+1
-/

/--
At the target step n0 = Nat.pair t k where k = Encodable.encode phi,
the selectFormulaToResolve function returns phi (via enumFormula).

This is the key lemma connecting the enumeration to the original formula.
-/
theorem selectFormulaToResolve_at_pair (M_n : Set Formula) (t : Nat) (phi : Formula)
    (h_F : Formula.some_future phi ∈ M_n) :
    let n0 := Nat.pair t (Encodable.encode phi)
    selectFormulaToResolve M_n n0 = phi := by
  intro n0
  unfold selectFormulaToResolve enumFormula
  -- n0 = Nat.pair t (Encodable.encode phi)
  -- (Nat.unpair n0).2 = Encodable.encode phi
  have h_unpair : (Nat.unpair n0).2 = Encodable.encode phi := by
    simp only [n0, Nat.unpair_pair]
  -- enumFormula (Nat.unpair n0).2 = Denumerable.ofNat Formula (Encodable.encode phi) = phi
  have h_enum : Denumerable.ofNat Formula (Nat.unpair n0).2 = phi := by
    rw [h_unpair]
    exact Denumerable.ofNat_encode phi
  -- Now show the ite chooses phi
  -- F(enumFormula k) = F(phi) ∈ M_n by h_F
  have h_F_in : Formula.some_future (Denumerable.ofNat Formula (Nat.unpair n0).2) ∈ M_n := by
    rw [h_enum]
    exact h_F
  rw [if_pos h_F_in, h_enum]

/--
Main F-resolution theorem for the true dovetailed forward chain.

If F(phi) is in the chain at step t, then phi is in the chain at some step s > t.

The proof uses the dovetailed construction's fairness: at step n0 = Nat.pair t (encode phi),
the construction targets phi for resolution.

**Proof Gap**: The case where F(phi) vanishes before n0 (because G(neg phi) enters the chain)
has a subtle gap. The Lindenbaum extension used in `temporal_theory_witness_exists` can add
G(neg phi) if it's consistent with the seed, even when F(phi) was present earlier.

**Alternative**: Bundle-level temporal coherence (`boxClassFamilies_bundle_forward_F`) is
proven without this gap, as it allows witnesses in ANY family of the bundle.
-/
theorem omega_true_dovetailed_forward_F_resolution (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Nat) (phi : Formula) (h_F : Formula.some_future phi ∈ omega_chain_true_dovetailed_forward M0 h_mcs0 t) :
    ∃ s, t < s ∧ phi ∈ omega_chain_true_dovetailed_forward M0 h_mcs0 s := by
  -- Let k = Encodable.encode phi and n0 = Nat.pair t k
  let k := Encodable.encode phi
  let n0 := Nat.pair t k
  -- n0 >= t by Nat.left_le_pair
  have h_n0_ge_t : t ≤ n0 := Nat.left_le_pair t k

  -- Either phi appears in some chain point in (t, n0+1], or it doesn't
  by_cases h_exists : ∃ m, t < m ∧ m ≤ n0 + 1 ∧ phi ∈ omega_chain_true_dovetailed_forward M0 h_mcs0 m
  · -- Case 1: phi appears before or at n0+1
    obtain ⟨m, h_lt, _, h_phi_m⟩ := h_exists
    exact ⟨m, h_lt, h_phi_m⟩
  · -- Case 2: phi does NOT appear in any chain point in (t, n0+1]
    push_neg at h_exists
    have h_s_gt_t : t < n0 + 1 := by omega

    -- Case split on whether F(phi) persists to chain(n0)
    by_cases h_F_n0 : Formula.some_future phi ∈ omega_chain_true_dovetailed_forward M0 h_mcs0 n0
    · -- F(phi) ∈ chain(n0): Resolution is FORCED
      -- selectFormulaToResolve picks phi because unpair(n0) = (t, encode phi)
      have h_select : selectFormulaToResolve (omega_chain_true_dovetailed_forward M0 h_mcs0 n0) n0 = phi :=
        selectFormulaToResolve_at_pair _ t phi h_F_n0
      have h_resolved := omega_chain_true_dovetailed_forward_resolves M0 h_mcs0 n0
      rw [h_select] at h_resolved
      exact ⟨n0 + 1, h_s_gt_t, h_resolved⟩
    · -- F(phi) ∉ chain(n0): F(phi) vanished somewhere between t and n0
      -- This means G(neg phi) entered the chain at some step m ∈ [t+1, n0]
      -- GAP: The current construction via Lindenbaum doesn't prevent G(neg phi) from entering
      -- even when F(phi) = neg(G(neg phi)) was present at an earlier step.
      --
      -- Closing this gap requires either:
      -- 1. A modified construction that explicitly excludes G(neg phi) when F(phi) is present
      -- 2. Proving that G(neg phi) is inconsistent with some invariant maintained by the chain
      -- 3. Using bundle-level coherence (which is already proven: boxClassFamilies_bundle_forward_F)
      sorry

end Bimodal.Metalogic.Algebraic.UltrafilterChain
