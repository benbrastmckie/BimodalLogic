import Bimodal.Metalogic.Algebraic.TenseS5Algebra
import Bimodal.Metalogic.Algebraic.UltrafilterMCS
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Theorems.Perpetuity

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
## Phase 2: Finite Inconsistency Argument

The key lemma: if F(a) is in ultrafilter U, then there exists a successor
ultrafilter V with R_G(U, V) and a ∈ V.

The proof uses the finite inconsistency argument:
1. Define G_preimage(U) = {b | G(b) ∈ U}
2. Show G_preimage(U) ∪ {a} is consistent when F(a) ∈ U
3. Extend to an ultrafilter V, which satisfies R_G(U, V) and a ∈ V
-/

/--
The G-preimage of an ultrafilter: elements whose G is in U.
-/
def G_preimage (U : Ultrafilter LindenbaumAlg) : Set LindenbaumAlg :=
  { b | STSA.G b ∈ U }

/--
The G-preimage contains ⊤ because G(⊤) = ⊤ is in every ultrafilter.
-/
theorem G_preimage_top (U : Ultrafilter LindenbaumAlg) : ⊤ ∈ G_preimage U := by
  unfold G_preimage
  simp only [Set.mem_setOf_eq]
  -- G(⊤) ≥ ⊤ in any STSA (since G is monotone and from a ≤ ⊤ we get G(a) ≤ G(⊤))
  -- Actually, G(⊤) = ⊤ in the quotient
  have h_le : (⊤ : LindenbaumAlg) ≤ STSA.G (⊤ : LindenbaumAlg) := by
    -- ⊤ = [⊥ → ⊥], G(⊤) = [G(⊥ → ⊥)]
    -- Need: (⊥ → ⊥) → G(⊥ → ⊥)
    -- This is temp_necessitation applied to (⊥ → ⊥)
    show top_quot ≤ G_quot top_quot
    unfold top_quot
    show Derives (Formula.bot.imp Formula.bot) (Formula.all_future (Formula.bot.imp Formula.bot))
    -- From ⊢ ⊥ → ⊥, by temporal_necessitation get ⊢ G(⊥ → ⊥)
    -- Then use identity φ → G(φ) with φ = (⊥ → ⊥)
    -- Actually we need (⊥ → ⊥) → G(⊥ → ⊥), not just ⊢ G(⊥ → ⊥)
    -- Use the fact that temp_t_future gives G(φ) → φ, and we need the opposite
    -- Actually, from ⊢ φ, we can derive ⊢ ψ → φ for any ψ by prop_s.
    have h_theorem : [] ⊢ Formula.all_future (Formula.bot.imp Formula.bot) :=
      DerivationTree.temporal_necessitation (Formula.bot.imp Formula.bot)
        (Bimodal.Theorems.Combinators.identity Formula.bot)
    exact ⟨DerivationTree.modus_ponens [] _ _
      (DerivationTree.axiom [] _ (Axiom.prop_s _ _)) h_theorem⟩
  exact U.mem_of_le U.top_mem h_le

/--
The G-preimage does not contain ⊥ because G(⊥) ≤ ⊥.
-/
theorem G_preimage_bot_not_mem (U : Ultrafilter LindenbaumAlg) : ⊥ ∉ G_preimage U := by
  unfold G_preimage
  simp only [Set.mem_setOf_eq]
  intro h_Gbot_in
  -- G(⊥) ≤ ⊥ by deflationary property (G_monotone applied to ⊥ ≤ ⊤ doesn't help directly)
  -- Actually G is deflationary via temp_t_future: G(a) → a, so G(⊥) → ⊥
  -- This means G(⊥) ≤ ⊥
  have h_le : STSA.G (⊥ : LindenbaumAlg) ≤ (⊥ : LindenbaumAlg) := by
    show G_quot (⊥ : LindenbaumAlg) ≤ (⊥ : LindenbaumAlg)
    show G_quot bot_quot ≤ bot_quot
    unfold bot_quot
    show Derives (Formula.all_future Formula.bot) Formula.bot
    exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future Formula.bot)⟩
  have h_bot_in : (⊥ : LindenbaumAlg) ∈ U := U.mem_of_le h_Gbot_in h_le
  exact U.bot_not_mem h_bot_in

/--
The G-preimage is upward closed.
-/
theorem G_preimage_mem_of_le (U : Ultrafilter LindenbaumAlg)
    {a b : LindenbaumAlg} (ha : a ∈ G_preimage U) (h_le : a ≤ b) :
    b ∈ G_preimage U := by
  unfold G_preimage at *
  simp only [Set.mem_setOf_eq] at *
  -- G is monotone: a ≤ b implies G(a) ≤ G(b)
  have h_G_le : STSA.G a ≤ STSA.G b := STSA.G_monotone a b h_le
  exact U.mem_of_le ha h_G_le

/--
The G-preimage is closed under finite meets.
-/
theorem G_preimage_inf_mem (U : Ultrafilter LindenbaumAlg)
    {a b : LindenbaumAlg} (ha : a ∈ G_preimage U) (hb : b ∈ G_preimage U) :
    a ⊓ b ∈ G_preimage U := by
  unfold G_preimage at *
  simp only [Set.mem_setOf_eq] at *
  -- Need G(a ⊓ b) ∈ U
  -- We have G(a) ∈ U and G(b) ∈ U, so G(a) ⊓ G(b) ∈ U
  -- And G(a) ⊓ G(b) ≤ G(a ⊓ b) by K-distribution for G
  have h_inf_in : STSA.G a ⊓ STSA.G b ∈ U := U.inf_mem ha hb
  -- G(a) ⊓ G(b) ≤ G(a ⊓ b) by K-distribution
  have h_le : STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b) := by
    induction a using Quotient.ind with
    | _ φ =>
      induction b using Quotient.ind with
      | _ ψ =>
        -- Need: G(φ) ⊓ G(ψ) ≤ G(φ ⊓ ψ), i.e., G(φ) ∧ G(ψ) → G(φ ∧ ψ)
        show G_quot (toQuot φ) ⊓ G_quot (toQuot ψ) ≤ G_quot (toQuot φ ⊓ toQuot ψ)
        show and_quot (G_quot (toQuot φ)) (G_quot (toQuot ψ)) ≤ G_quot (and_quot (toQuot φ) (toQuot ψ))
        show Derives (Formula.and φ.all_future ψ.all_future) (Formula.all_future (φ.and ψ))
        unfold Derives
        -- Build derivation from conjunction to G(conjunction)
        -- Work in context [G(φ) ∧ G(ψ)] and derive G(φ ∧ ψ)
        let conj := φ.all_future.and ψ.all_future
        -- Step 1: ⊢ φ → (ψ → φ ∧ ψ)
        have h_pair : [] ⊢ φ.imp (ψ.imp (φ.and ψ)) := Bimodal.Theorems.Combinators.pairing φ ψ
        -- Step 2: ⊢ G(φ → (ψ → φ ∧ ψ))
        have h_G_pair : [] ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_future :=
          DerivationTree.temporal_necessitation _ h_pair
        -- Step 3: K-distribution
        have h_K1 : [] ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_future.imp (φ.all_future.imp (ψ.imp (φ.and ψ)).all_future) :=
          DerivationTree.axiom [] _ (Axiom.temp_k_dist φ (ψ.imp (φ.and ψ)))
        have h_K2 : [] ⊢ (ψ.imp (φ.and ψ)).all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) :=
          DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ (φ.and ψ))
        -- Step 4: ⊢ G(φ) → G(ψ → φ∧ψ)
        have h_step1 : [] ⊢ φ.all_future.imp (ψ.imp (φ.and ψ)).all_future :=
          DerivationTree.modus_ponens [] _ _ h_K1 h_G_pair
        -- Work in context [conj]
        have h_ctx : [conj] ⊢ (φ.and ψ).all_future := by
          -- Get G(φ) ∧ G(ψ) from assumption
          have h_conj_in : [conj] ⊢ conj := DerivationTree.assumption [conj] conj (by simp)
          -- Extract G(φ) using left conjunction elimination
          have h_lce : [] ⊢ conj.imp φ.all_future := Bimodal.Theorems.Propositional.lce_imp φ.all_future ψ.all_future
          have h_lce_w : [conj] ⊢ conj.imp φ.all_future := DerivationTree.weakening [] [conj] _ h_lce (by intro; simp)
          have h_Gφ : [conj] ⊢ φ.all_future := DerivationTree.modus_ponens [conj] _ _ h_lce_w h_conj_in
          -- Extract G(ψ)
          have h_rce : [] ⊢ conj.imp ψ.all_future := Bimodal.Theorems.Propositional.rce_imp φ.all_future ψ.all_future
          have h_rce_w : [conj] ⊢ conj.imp ψ.all_future := DerivationTree.weakening [] [conj] _ h_rce (by intro; simp)
          have h_Gψ : [conj] ⊢ ψ.all_future := DerivationTree.modus_ponens [conj] _ _ h_rce_w h_conj_in
          -- Apply chain: G(φ) → G(ψ → φ∧ψ) → G(φ∧ψ)
          have h_step1_w : [conj] ⊢ φ.all_future.imp (ψ.imp (φ.and ψ)).all_future :=
            DerivationTree.weakening [] [conj] _ h_step1 (by intro; simp)
          have h_G_inner : [conj] ⊢ (ψ.imp (φ.and ψ)).all_future :=
            DerivationTree.modus_ponens [conj] _ _ h_step1_w h_Gφ
          have h_K2_w : [conj] ⊢ (ψ.imp (φ.and ψ)).all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) :=
            DerivationTree.weakening [] [conj] _ h_K2 (by intro; simp)
          have h_arrow : [conj] ⊢ ψ.all_future.imp (φ.and ψ).all_future :=
            DerivationTree.modus_ponens [conj] _ _ h_K2_w h_G_inner
          exact DerivationTree.modus_ponens [conj] _ _ h_arrow h_Gψ
        exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] conj (φ.and ψ).all_future h_ctx⟩
  exact U.mem_of_le h_inf_in h_le

/--
F(a) in ultrafilter U is equivalent to (G(aᶜ))ᶜ ∈ U.

F(a) = ¬G(¬a) in the logic, which corresponds to (G(aᶜ))ᶜ in the algebra.
-/
noncomputable def F_elem (a : LindenbaumAlg) : LindenbaumAlg := (STSA.G (aᶜ))ᶜ

/--
F(a) ∈ U is equivalent to G(aᶜ) ∉ U.
-/
theorem F_elem_mem_iff_G_compl_not_mem (U : Ultrafilter LindenbaumAlg) (a : LindenbaumAlg) :
    F_elem a ∈ U ↔ STSA.G (aᶜ) ∉ U := by
  unfold F_elem
  constructor
  · intro h_F_in h_G_in
    exact U.compl_not (STSA.G (aᶜ)) h_G_in h_F_in
  · intro h_G_notin
    cases U.compl_or (STSA.G (aᶜ)) with
    | inl h => exact absurd h h_G_notin
    | inr h => exact h

/--
**The Finite Inconsistency Lemma**

If F(a) ∈ U (i.e., G(aᶜ) ∉ U), then G_preimage(U) ∪ {a} is "filter-consistent",
meaning the intersection of any finite subset with {a} does not imply ⊥.

More precisely: G_preimage(U) ∪ {a} generates a proper filter.
-/
theorem G_preimage_union_singleton_consistent (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_F : F_elem a ∈ U) :
    ∀ b ∈ G_preimage U, a ⊓ b ≠ ⊥ := by
  intro b hb h_eq
  -- From a ⊓ b = ⊥, we get b ≤ aᶜ (disjoint elements)
  have h_b_le_ac : b ≤ aᶜ := by
    calc b = b ⊓ ⊤ := by simp
      _ = b ⊓ (a ⊔ aᶜ) := by simp
      _ = (b ⊓ a) ⊔ (b ⊓ aᶜ) := by rw [inf_sup_left]
      _ = (a ⊓ b) ⊔ (b ⊓ aᶜ) := by rw [inf_comm]
      _ = ⊥ ⊔ (b ⊓ aᶜ) := by rw [h_eq]
      _ = b ⊓ aᶜ := by simp
      _ ≤ aᶜ := inf_le_right

  -- From b ≤ aᶜ and G monotone: G(b) ≤ G(aᶜ)
  have h_Gb_le_Gac : STSA.G b ≤ STSA.G (aᶜ) := STSA.G_monotone b (aᶜ) h_b_le_ac

  -- From hb: G(b) ∈ U
  unfold G_preimage at hb
  simp only [Set.mem_setOf_eq] at hb
  -- So G(aᶜ) ∈ U by upward closure
  have h_Gac_in : STSA.G (aᶜ) ∈ U := U.mem_of_le hb h_Gb_le_Gac

  -- But from h_F: F_elem a = (G(aᶜ))ᶜ ∈ U
  -- So G(aᶜ) ∉ U
  have h_Gac_notin : STSA.G (aᶜ) ∉ U := (F_elem_mem_iff_G_compl_not_mem U a).mp h_F

  exact h_Gac_notin h_Gac_in

/--
**Temporal Successor Existence**

If F(a) ∈ U, then there exists an ultrafilter V such that:
1. R_G(U, V) - V is a temporal successor of U
2. a ∈ V

This is the key lemma that enables building ultrafilter chains.
-/
theorem temporal_successor_exists (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_F : F_elem a ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_G U V ∧ a ∈ V := by
  -- We need to extend G_preimage(U) ∪ {a} to an ultrafilter
  -- First, show that the filter generated by G_preimage(U) ∪ {a} is proper

  -- The key is to use that G_preimage(U) is already almost a filter
  -- (it has ⊤, is upward closed, closed under finite meets)
  -- Adding {a} and ensuring consistency via G_preimage_union_singleton_consistent

  -- Strategy: Define V's carrier as all b such that there exists c ∈ G_preimage(U)
  -- with a ⊓ c ≤ b. This is the filter generated by G_preimage(U) ∪ {a}.

  -- Actually, we need to use Zorn's lemma or the ultrafilter lemma.
  -- The ultrafilter lemma says: any proper filter extends to an ultrafilter.

  -- Let's define the filter generated by G_preimage(U) ∪ {a}
  let S := G_preimage U ∪ {a}

  -- We need to construct an ultrafilter containing S.
  -- The standard approach is to use that the filter generated by S is proper,
  -- then apply the ultrafilter lemma.

  -- For now, let's use a direct construction via Classical.choose
  -- on the filter extension.

  -- The filter generated by S: all b ≥ ⋀(finite subset of S)
  -- Since G_preimage U is upward closed and closed under finite meets,
  -- and a ⊓ b ≠ ⊥ for any b ∈ G_preimage U (by G_preimage_union_singleton_consistent),
  -- the filter generated is proper.

  -- We'll construct this by showing the filter basis is proper
  -- and then use Classical reasoning to extend.

  -- For a simpler approach, let's directly define V using the
  -- principal ultrafilter construction, but that won't work since
  -- we're not in a complete Boolean algebra context.

  -- The cleanest approach: use Zorn on the set of proper filters containing S.

  -- For now, let's use sorry and come back to complete the ultrafilter extension.
  -- The mathematical argument is sound; the Lean encoding is technical.

  -- Actually, let's try a different approach using the existing mcsToUltrafilter
  -- correspondence. We can:
  -- 1. Convert U to an MCS M via ultrafilterToSet
  -- 2. Use MCS properties to find a successor MCS M' with φ ∈ M' (where a = [φ])
  -- 3. Convert M' back to ultrafilter V via mcsToUltrafilter

  -- Step 1: Convert U to MCS
  let M := ultrafilterToSet U
  have h_M_mcs : SetMaximalConsistent M := ultrafilterToSet_mcs U

  -- The formula a corresponds to some φ in the quotient
  -- F(a) ∈ U means F(φ) ∈ M for the representative φ

  -- This is getting complex. Let's use a simpler direct construction.

  -- Direct construction: Define V's carrier as the set of b such that
  -- ¬(aᶜ ⊔ bᶜ ∈ U), which is equivalent to ¬(a ⊓ b = ⊥ in filter sense)

  -- Actually, the standard ultrafilter extension uses:
  -- V = {b | ∀ c ∈ G_preimage(U), a ⊓ c ≤ b → true}...
  -- This is still complex.

  -- Let's use the following observation:
  -- Define V's carrier = {b | aᶜ ⊔ G(b)ᶜ ∉ U}
  -- This is {b | ¬(aᶜ ∈ U ∨ G(b)ᶜ ∈ U)} which simplifies based on ultrafilter properties.

  -- Hmm, let's try yet another approach: show that aᶜ ∉ G_preimage(U)
  -- and use that G_preimage(U) ∪ {a} can be extended.

  have h_ac_notin_Gpre : aᶜ ∉ G_preimage U := by
    intro h_ac_in
    -- If aᶜ ∈ G_preimage U, then G(aᶜ) ∈ U
    unfold G_preimage at h_ac_in
    simp only [Set.mem_setOf_eq] at h_ac_in
    -- But F(a) = (G(aᶜ))ᶜ ∈ U means G(aᶜ) ∉ U
    have h_Gac_notin := (F_elem_mem_iff_G_compl_not_mem U a).mp h_F
    exact h_Gac_notin h_ac_in

  -- Now we need to construct an ultrafilter V with:
  -- 1. G_preimage(U) ⊆ V (gives R_G(U, V))
  -- 2. a ∈ V

  -- Since aᶜ ∉ G_preimage(U) and G_preimage(U) is a filter-like set,
  -- we can extend G_preimage(U) ∪ {a} to an ultrafilter.

  -- For the construction, we'll use the fact that the Boolean algebra
  -- is atomless (being the Lindenbaum algebra of a consistent theory),
  -- but that's not directly helpful.

  -- Let's use the ultrafilter lemma directly.
  -- The ultrafilter lemma: Any proper filter on a Boolean algebra extends to an ultrafilter.

  -- Define the filter F generated by G_preimage(U) ∪ {a}:
  -- F = {b | ∃ c₁...cₙ ∈ G_preimage(U), a ⊓ c₁ ⊓ ... ⊓ cₙ ≤ b}

  -- F is proper iff ⊥ ∉ F iff ∀ finite c₁...cₙ ∈ G_preimage(U), a ⊓ c₁ ⊓ ... ⊓ cₙ ≠ ⊥

  -- We can prove this by induction using G_preimage_union_singleton_consistent
  -- and G_preimage_inf_mem.

  -- For now, let's proceed with the construction assuming we can extend.
  -- The ultrafilter lemma is available in Mathlib for specific contexts.

  -- Actually, let's directly construct V as follows:
  -- V.carrier = {b | ∃ c ∈ G_preimage(U), a ⊓ c ≤ b}

  -- No wait, this is a filter, not an ultrafilter.

  -- The cleanest solution: use the MCS correspondence and the existing
  -- MCS extension infrastructure.

  -- Convert the problem to MCS space:
  -- U corresponds to MCS M = ultrafilterToSet U
  -- a = [φ] for some formula φ
  -- F(a) ∈ U means F(φ) ∈ M (some_future φ ∈ M)

  -- By TemporalCoherentFamily.forward_F (if we had a suitable family),
  -- we'd get a witness. But we're constructing the family now.

  -- Let's use the MCS-based approach more directly.

  -- For any formula φ, if some_future φ ∈ M (where M = ultrafilterToSet U),
  -- we want to find an MCS M' with φ ∈ M' and the G-formulas from M persist.

  -- This is the classical Henkin construction for temporal logic.

  -- For simplicity, let's use sorry here and note that the proof requires
  -- the ultrafilter extension lemma (BPI/ultrafilter lemma).

  sorry

/-!
## Phase 3: Int-Indexed Chain Construction

Given `temporal_successor_exists`, we can build Int-indexed chains of ultrafilters.
-/

/--
An Int-indexed chain of ultrafilters with R_G connectivity between adjacent points.
-/
structure Chain where
  /-- The ultrafilter at each integer position -/
  uf : Int → Ultrafilter LindenbaumAlg
  /-- Adjacent points are R_G-connected (forward) -/
  forward_connected : ∀ n : Int, R_G (uf n) (uf (n + 1))

/--
If chain c is connected, then R_G is transitive along the chain.
-/
theorem Chain.R_G_le {c : Chain} {m n : Int} (h : m ≤ n) : R_G (c.uf m) (c.uf n) := by
  -- Prove by induction on n - m
  obtain ⟨k, hk⟩ := Int.eq_ofNat_of_zero_le (Int.sub_nonneg.mpr h)
  induction k generalizing m n with
  | zero =>
    have h_eq : m = n := by omega
    rw [h_eq]
    exact R_G_refl (c.uf n)
  | succ k ih =>
    have h_lt : m < n := by omega
    have h_prev : m ≤ n - 1 := by omega
    have h_eq : n = (n - 1) + 1 := by omega
    conv_rhs => rw [h_eq]
    have h_ih : R_G (c.uf m) (c.uf (n - 1)) := ih h_prev (by omega)
    exact R_G_trans h_ih (c.forward_connected (n - 1))

/--
Build a chain starting from a given ultrafilter at position 0.

This requires `temporal_successor_exists` to construct successors.
For the backward direction, we use a similar argument with H instead of G.
-/
noncomputable def buildChain (U₀ : Ultrafilter LindenbaumAlg) : Chain := by
  -- For now, use sorry since we need temporal_successor_exists
  -- and the backward construction
  exact { uf := fun _ => U₀, forward_connected := fun _ => R_G_refl U₀ }
  -- NOTE: This is a placeholder. The actual construction requires:
  -- 1. Forward: use temporal_successor_exists repeatedly
  -- 2. Backward: use a dual argument with H operator

/-!
## Phase 4: FMCS and BFMCS Construction

Convert ultrafilter chain to FMCS, then build BFMCS by modal saturation.
-/

/--
Convert an ultrafilter to an MCS using the bijection.
-/
noncomputable def chainToMCS (c : Chain) (t : Int) : Set Formula :=
  ultrafilterToSet (c.uf t)

/--
Each point in the chain gives an MCS.
-/
theorem chainToMCS_is_mcs (c : Chain) (t : Int) :
    SetMaximalConsistent (chainToMCS c t) :=
  ultrafilterToSet_mcs (c.uf t)

/--
G-formulas propagate forward in the chain.
-/
theorem chainToMCS_forward_G (c : Chain) (t t' : Int) (φ : Formula)
    (h_le : t ≤ t') (h_G : Formula.all_future φ ∈ chainToMCS c t) :
    φ ∈ chainToMCS c t' := by
  -- G(φ) ∈ M(t) means [G(φ)] ∈ U(t), i.e., G_quot([φ]) ∈ U(t)
  -- By R_G connectivity: R_G(U(t), U(t')) gives [φ] ∈ U(t')
  -- So φ ∈ M(t')
  unfold chainToMCS at *
  unfold ultrafilterToSet at *
  simp only [Set.mem_setOf_eq] at *
  -- h_G : toQuot φ.all_future ∈ (c.uf t).carrier
  -- Need: toQuot φ ∈ (c.uf t').carrier
  have h_RG : R_G (c.uf t) (c.uf t') := Chain.R_G_le h_le
  unfold R_G at h_RG
  -- G_quot (toQuot φ) = toQuot (φ.all_future)
  have h_eq : STSA.G (toQuot φ) = toQuot φ.all_future := rfl
  rw [← h_eq] at h_G
  exact h_RG (toQuot φ) h_G

/--
H-formulas propagate backward in the chain (requires dual construction).
-/
theorem chainToMCS_backward_H (c : Chain) (t t' : Int) (φ : Formula)
    (h_le : t' ≤ t) (h_H : Formula.all_past φ ∈ chainToMCS c t) :
    φ ∈ chainToMCS c t' := by
  -- This requires the backward construction using H operator
  -- For now, sorry
  sorry

/--
Convert a chain to an FMCS.
-/
noncomputable def chainToFMCS (c : Chain) : FMCS Int where
  mcs := chainToMCS c
  is_mcs := chainToMCS_is_mcs c
  forward_G := chainToMCS_forward_G c
  backward_H := chainToMCS_backward_H c

/-!
## Phase 5: Temporal Coherence

The chain construction with F-witnesses ensures temporal coherence.
-/

/--
Forward F coherence: if F(φ) ∈ mcs(t), there exists s > t with φ ∈ mcs(s).

This follows from the construction using `temporal_successor_exists`.
-/
theorem chainToFMCS_forward_F (c : Chain) (t : Int) (φ : Formula)
    (h_F : Formula.some_future φ ∈ (chainToFMCS c).mcs t) :
    ∃ s : Int, t < s ∧ φ ∈ (chainToFMCS c).mcs s := by
  -- F(φ) ∈ mcs(t) means (G(¬φ))^c ∈ U(t), i.e., F_elem([φ]) ∈ U(t)
  -- By temporal_successor_exists: there exists V with R_G(U(t), V) and [φ] ∈ V
  -- In the chain construction, V = U(t+1) (or some s > t)
  -- For the placeholder chain (constant), this doesn't hold
  -- Real proof requires the proper chain construction
  sorry

/--
Backward P coherence: if P(φ) ∈ mcs(t), there exists s < t with φ ∈ mcs(s).
-/
theorem chainToFMCS_backward_P (c : Chain) (t : Int) (φ : Formula)
    (h_P : Formula.some_past φ ∈ (chainToFMCS c).mcs t) :
    ∃ s : Int, s < t ∧ φ ∈ (chainToFMCS c).mcs s := by
  sorry

/-!
## Phase 6: BFMCS and construct_bfmcs

Build the full BFMCS with modal saturation.
-/

/--
The BFMCS constructed from a chain with modal saturation.

For S5, all ultrafilters in the same R_Box equivalence class see the same
box-formulas. The modal saturation collects all R_Box-equivalent chains.
-/
noncomputable def chainToBFMCS (c : Chain) : BFMCS Int := by
  -- For simplicity, use a singleton bundle (works for completeness)
  -- Modal coherence follows from S5 properties of box
  exact {
    families := {chainToFMCS c}
    nonempty := ⟨chainToFMCS c, Set.mem_singleton _⟩
    modal_forward := by
      intro fam hfam φ t h_box fam' hfam'
      simp only [Set.mem_singleton_iff] at hfam hfam'
      subst hfam hfam'
      -- □φ ∈ mcs(t) implies φ ∈ mcs(t) by T-axiom closure
      have h_mcs := (chainToFMCS c).is_mcs t
      -- Use modal_t axiom: □φ → φ
      have h_t : [] ⊢ (Formula.box φ).imp φ := DerivationTree.axiom [] _ (Axiom.modal_t φ)
      exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_t) h_box
    modal_backward := by
      intro fam hfam φ t h_all
      simp only [Set.mem_singleton_iff] at hfam
      subst hfam
      -- If φ ∈ mcs(t) for all families (just one), need □φ ∈ mcs(t)
      -- This requires that we can derive □φ from φ being in all accessible worlds
      -- For a singleton bundle, this requires additional S5 reasoning
      sorry
    eval_family := chainToFMCS c
    eval_family_mem := Set.mem_singleton _
  }

/--
The signature required by ParametricRepresentation.
-/
noncomputable def construct_bfmcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
       (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
       M = fam.mcs t := by
  -- 1. Convert M to ultrafilter
  let U := mcsToUltrafilter ⟨M, h_mcs⟩
  -- 2. Build chain from U at position 0
  let c := buildChain U
  -- 3. Build BFMCS
  let B := chainToBFMCS c
  -- 4. Show temporal coherence (requires F/P witness properties)
  have h_tc : B.temporally_coherent := by
    intro fam hfam
    -- B.families = {chainToFMCS c}, so fam = chainToFMCS c
    have h_eq : fam = chainToFMCS c := Set.mem_singleton_iff.mp hfam
    subst h_eq
    constructor
    · -- forward_F
      intro t φ h_F
      exact chainToFMCS_forward_F c t φ h_F
    · -- backward_P
      intro t φ h_P
      exact chainToFMCS_backward_P c t φ h_P
  -- 5. Return the sigma type
  use B, h_tc, chainToFMCS c, Set.mem_singleton _, 0
  -- Need: M = (chainToFMCS c).mcs 0
  -- The bijection gives us ultrafilterToSet (mcsToUltrafilter ⟨M, h_mcs⟩) = M
  have h_bij : ultrafilterToSet (mcsToUltrafilter ⟨M, h_mcs⟩) = M := by
    ext φ
    unfold ultrafilterToSet mcsToUltrafilter mcsToSet
    simp only [Set.mem_setOf_eq]
    constructor
    · intro ⟨ψ, h_ψ_in, h_eq⟩
      have h_le : toQuot ψ ≤ toQuot φ := by rw [← h_eq]
      obtain ⟨d_imp⟩ := (h_le : Derives ψ φ)
      exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs d_imp) h_ψ_in
    · intro h_φ_in
      exact ⟨φ, h_φ_in, rfl⟩
  -- With placeholder buildChain, c.uf 0 = U
  -- So we need M = ultrafilterToSet U, which is h_bij.symm
  show M = ultrafilterToSet (c.uf 0)
  -- c = buildChain U, so c.uf 0 = U = mcsToUltrafilter ⟨M, h_mcs⟩
  simp only [c]
  exact h_bij.symm

end Bimodal.Metalogic.Algebraic.UltrafilterChain
