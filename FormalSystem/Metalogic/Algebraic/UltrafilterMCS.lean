/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Algebraic.InteriorOperators
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.ForMathlib.Order.PFilter
import Mathlib.Order.PrimeIdeal

/-!
# Ultrafilter-MCS Correspondence

This module establishes the bijection between ultrafilters of the Lindenbaum algebra
and maximal consistent sets. Ultrafilters are encoded Mathlib-natively as prime filters,
`Order.PrimeFilter LindenbaumAlg` (on a Boolean algebra the two notions coincide); the generic
proper/maximal/prime-filter API comes from `FormalSystem/ForMathlib/Order/PFilter.lean`.

## Main Results

- `mcsToUltrafilter`: MCS → `Order.PrimeFilter LindenbaumAlg` (via `mcsToPFilter`)
- `ultrafilterToMcs`: `Order.PrimeFilter LindenbaumAlg` → MCS (via `ultrafilterToSet`)
- `SetMaximalConsistent.ultrafilterEquiv`: the two maps assembled into an `Equiv`
- `SetMaximalConsistent.ultrafilter_correspondence`: the existential corollary

## Status

Phase 5 of the algebraic completeness theorem.
-/

namespace FormalSystem.Metalogic.Algebraic.UltrafilterMCS

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Algebraic.LindenbaumQuotient
open FormalSystem.Metalogic.Algebraic.BooleanStructure
open FormalSystem.Metalogic.Core
open Order

/-!
## MCS to Ultrafilter Direction

Given a maximal consistent set Γ, we construct an ultrafilter on LindenbaumAlg.
-/

/--
The set of equivalence classes corresponding to formulas in an MCS.

Given MCS Γ, this is `{ [φ] | φ ∈ Γ }`.
-/
def mcsToSet (Γ : Set Formula) : Set LindenbaumAlg :=
  { a | ∃ φ ∈ Γ, a = toQuot φ }

/--
If Γ is an MCS and φ ∈ Γ, then [φ] is in the corresponding set.
-/
theorem mem_mcsToSet {Γ : Set Formula} {φ : Formula} (h : φ ∈ Γ) :
    toQuot φ ∈ mcsToSet Γ :=
  ⟨φ, h, rfl⟩

/--
mcsToSet Γ contains the top element.
-/
theorem mcsToSet_top {Γ : Set Formula} (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) Γ) :
    ⊤ ∈ mcsToSet Γ := by
  have d_id : DerivationTree FrameClass.Base [] (Formula.bot.imp Formula.bot) :=
    FormalSystem.Theorems.Combinators.identity Formula.bot
  have h : Formula.bot.imp Formula.bot ∈ Γ := theorem_in_mcs h_mcs d_id
  exact ⟨Formula.bot.imp Formula.bot, h, rfl⟩

/--
mcsToSet Γ does not contain ⊥.

For an MCS Γ, the set `{ [φ] | φ ∈ Γ }` cannot contain ⊥ = [⊥],
because MCS is consistent and ⊥ ∈ Γ would derive ⊥ from a finite subset.
-/
theorem mcsToSet_bot_not_mem {Γ : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) Γ) :
    ⊥ ∉ mcsToSet Γ := by
  intro ⟨φ, h_mem, h_eq⟩
  -- h_eq : ⊥ = toQuot φ
  -- This means [φ] = [⊥], i.e., ⊢ φ ↔ ⊥
  -- In particular, ⊢ φ → ⊥ (i.e., ⊢ ¬φ)
  have h_le : toQuot φ ≤ (⊥ : LindenbaumAlg) := by
    rw [← h_eq]
  -- toQuot φ ≤ ⊥ means Derives φ ⊥, i.e., ⊢ φ → ⊥
  have h_derives : Derives φ Formula.bot := h_le
  obtain ⟨d_neg⟩ := h_derives
  -- So [φ] ⊢ ⊥
  have h_phi_incons : ¬Consistent (fc := FrameClass.Base) [φ] := by
    intro h_cons
    have d_phi : [φ] ⊢ φ := DerivationTree.assumption [φ] φ (by simp)
    have d_bot : [φ] ⊢ Formula.bot := DerivationTree.modus_ponens [φ] φ Formula.bot
      (DerivationTree.weakening [] [φ] (Formula.neg φ) d_neg (by simp)) d_phi
    exact h_cons ⟨d_bot⟩
  -- But φ ∈ Γ and Γ is MCS, so [φ] should be consistent
  have h_cons : Consistent (fc := FrameClass.Base) [φ] := h_mcs.1 [φ] (by simp [h_mem])
  exact h_phi_incons h_cons

/--
mcsToSet Γ is upward closed: if [a] ∈ mcsToSet Γ and a ≤ b, then [b] ∈ mcsToSet Γ.

This follows from MCS being deductively closed: a ≤ b means ⊢ a → b,
so a ∈ Γ and ⊢ a → b implies b ∈ Γ (by closure under modus ponens).
-/
theorem mcsToSet_mem_of_le {Γ : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) Γ)
    {a b : LindenbaumAlg} (ha : a ∈ mcsToSet Γ) (h_le : a ≤ b) :
    b ∈ mcsToSet Γ := by
  -- a is represented by some φ ∈ Γ
  obtain ⟨φ, h_phi_mem, h_a_eq⟩ := ha
  -- b is some equivalence class [ψ]
  -- Use Quotient.ind to get a representative for b
  induction b using Quotient.ind with
  | _ ψ =>
    -- h_le : toQuot φ ≤ toQuot ψ means Derives φ ψ, i.e., ⊢ φ → ψ
    rw [h_a_eq] at h_le
    have h_derives : Derives φ ψ := h_le
    obtain ⟨d_imp⟩ := h_derives
    -- From φ ∈ Γ and ⊢ φ → ψ, we derive ψ ∈ Γ
    -- Since Γ is MCS, it's deductively closed in the set sense
    -- We need [φ] ⊢ ψ to show ψ ∈ Γ
    have h_psi_in : ψ ∈ Γ := by
      -- Apply modus ponens: from φ ∈ Γ and ⊢ φ → ψ, derive ψ ∈ Γ
      -- Need to show that if we assume ψ ∉ Γ, we get contradiction
      by_contra h_not
      -- By MCS, ψ ∉ Γ implies insert ψ Γ is inconsistent
      have h_incons : ¬SetConsistent (fc := FrameClass.Base) (insert ψ Γ) := h_mcs.2 ψ h_not
      unfold SetConsistent at h_incons
      push Not at h_incons
      obtain ⟨L, hL, hL_incons⟩ := h_incons
      -- hL_incons: ¬Consistent (fc := FrameClass.Base) L
      have ⟨d_bot⟩ := FormalSystem.Metalogic.Core.inconsistent_derives_bot hL_incons
      -- Since [] ⊢ φ → ψ and φ ∈ Γ, we have that any list containing ψ
      -- can replace ψ with φ and φ → ψ and still derive ⊥
      -- Actually, we need to construct a derivation from L \ {ψ} ∪ {φ}
      -- This is getting complex; let's use a different approach.
      -- Since ⊢ φ → ψ, we have ⊢ ¬ψ → ¬φ by contraposition
      -- If ψ ∉ Γ, by negation completeness ¬ψ ∈ Γ
      -- Then from ⊢ φ → ψ and ¬ψ ∈ Γ, we'd get ¬φ ∈ Γ
      -- But φ ∈ Γ and ¬φ ∈ Γ contradicts consistency

      -- We need contraposition: ⊢ (φ → ψ) → (¬ψ → ¬φ)
      have d_contra : DerivationTree FrameClass.Base [] ((φ.imp ψ).imp (ψ.neg.imp φ.neg)) :=
        FormalSystem.Theorems.Propositional.contraposeImp φ ψ
      have d_neg_ψ_to_neg_φ : DerivationTree FrameClass.Base [] (ψ.neg.imp φ.neg) :=
        DerivationTree.modus_ponens [] _ _ d_contra d_imp
      -- Since ψ ∉ Γ and Γ is MCS...
      -- We need set-based negation completeness. Let's prove it directly.
      -- If ψ ∉ Γ, then insert ψ Γ is inconsistent.
      -- This means there's a list L ⊆ insert ψ Γ with L ⊢ ⊥
      -- From this we can derive Γ ⊢ ¬ψ
      -- Actually, the theorem_in_mcs and closure require List-based MCS properties.
      -- Let's show ¬ψ ∈ Γ using the structure of set-based consistency.

      -- By maximality of Γ: since ψ ∉ Γ, insert ψ Γ is inconsistent
      -- There exists L ⊆ insert ψ Γ with ¬Consistent (fc := FrameClass.Base) L
      -- We already have this from h_incons

      -- Let Γ' = L.filter (· ≠ ψ). Then Γ' ⊆ Γ and L ⊆ ψ :: Γ'
      let Γ' := L.filter (· ≠ ψ)
      have h_Γ'_sub : ∀ χ ∈ Γ', χ ∈ Γ := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχL := hχ'.1
        have hχne : χ ≠ ψ := by simpa using hχ'.2
        specialize hL χ hχL
        simp only [Set.mem_insert_iff] at hL
        rcases hL with rfl | h_in_Γ
        · exact absurd rfl hχne
        · exact h_in_Γ
      have h_L_sub : L ⊆ ψ :: Γ' := by
        intro χ hχ
        by_cases hχψ : χ = ψ
        · simp [hχψ]
        · simp only [List.mem_cons]
          right
          exact List.mem_filter.mpr ⟨hχ, by simpa⟩
      -- Weaken L ⊢ ⊥ to (ψ :: Γ') ⊢ ⊥
      have d_bot' : DerivationTree FrameClass.Base (ψ :: Γ') Formula.bot :=
        DerivationTree.weakening L (ψ :: Γ') Formula.bot d_bot h_L_sub
      -- By deduction theorem: Γ' ⊢ ¬ψ
      have d_neg_ψ : DerivationTree FrameClass.Base Γ' ψ.neg :=
        FormalSystem.Metalogic.Core.deductionTheorem Γ' ψ Formula.bot d_bot'
      -- Weaken to add φ: (φ :: Γ') ⊢ ¬ψ
      have d_neg_ψ' : DerivationTree FrameClass.Base (φ :: Γ') ψ.neg :=
        DerivationTree.weakening Γ' (φ :: Γ') ψ.neg d_neg_ψ (fun x hx => List.mem_cons_of_mem φ hx)
      -- We also have (φ :: Γ') ⊢ φ → ψ
      have d_imp' : DerivationTree FrameClass.Base (φ :: Γ') (φ.imp ψ) :=
        DerivationTree.weakening [] (φ :: Γ') (φ.imp ψ) d_imp (by simp)
      -- And (φ :: Γ') ⊢ φ
      have d_φ : DerivationTree FrameClass.Base (φ :: Γ') φ :=
        DerivationTree.assumption (φ :: Γ') φ (by simp)
      -- So (φ :: Γ') ⊢ ψ by modus ponens
      have d_ψ : DerivationTree FrameClass.Base (φ :: Γ') ψ :=
        DerivationTree.modus_ponens (φ :: Γ') φ ψ d_imp' d_φ
      -- And (φ :: Γ') ⊢ ⊥ from ψ and ¬ψ
      have d_bot'' : DerivationTree FrameClass.Base (φ :: Γ') Formula.bot :=
        DerivationTree.modus_ponens (φ :: Γ') ψ Formula.bot d_neg_ψ' d_ψ
      -- But φ :: Γ' ⊆ Γ (since φ ∈ Γ and Γ' ⊆ Γ)
      have h_cons_list : Consistent (fc := FrameClass.Base) (φ :: Γ') := by
        apply h_mcs.1 (φ :: Γ')
        intro χ hχ
        simp only [List.mem_cons] at hχ
        rcases hχ with rfl | hχ'
        · exact h_phi_mem
        · exact h_Γ'_sub χ hχ'
      exact h_cons_list ⟨d_bot''⟩
    exact ⟨ψ, h_psi_in, rfl⟩

/--
mcsToSet Γ is closed under finite meets.
-/
theorem mcsToSet_inf_mem {Γ : Set Formula} (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) Γ)
    {a b : LindenbaumAlg} (ha : a ∈ mcsToSet Γ) (hb : b ∈ mcsToSet Γ) :
    a ⊓ b ∈ mcsToSet Γ := by
  obtain ⟨φ, h_phi_mem, h_a_eq⟩ := ha
  obtain ⟨ψ, h_psi_mem, h_b_eq⟩ := hb
  -- a ⊓ b = [φ] ⊓ [ψ] = [φ ∧ ψ]
  -- Need to show φ ∧ ψ ∈ Γ
  have h_and_in : φ.and ψ ∈ Γ := by
    -- From φ ∈ Γ and ψ ∈ Γ, derive φ ∧ ψ ∈ Γ
    by_contra h_not
    -- If φ ∧ ψ ∉ Γ, then insert (φ ∧ ψ) Γ is inconsistent
    have h_incons : ¬SetConsistent (fc := FrameClass.Base) (insert (φ.and ψ) Γ) := h_mcs.2
        (φ.and ψ) h_not
    unfold SetConsistent at h_incons
    push Not at h_incons
    obtain ⟨L, hL, hL_incons⟩ := h_incons
    have ⟨d_bot⟩ := FormalSystem.Metalogic.Core.inconsistent_derives_bot hL_incons
    -- Similar to above, extract the part without φ ∧ ψ
    let Γ' := L.filter (· ≠ φ.and ψ)
    have h_Γ'_sub : ∀ χ ∈ Γ', χ ∈ Γ := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχL := hχ'.1
      have hχne : χ ≠ φ.and ψ := by simpa using hχ'.2
      specialize hL χ hχL
      simp only [Set.mem_insert_iff] at hL
      rcases hL with rfl | h_in_Γ
      · exact absurd rfl hχne
      · exact h_in_Γ
    have h_L_sub : L ⊆ (φ.and ψ) :: Γ' := by
      intro χ hχ
      by_cases hχeq : χ = φ.and ψ
      · simp [hχeq]
      · simp only [List.mem_cons]; right
        exact List.mem_filter.mpr ⟨hχ, by simpa⟩
    -- Weaken and apply deduction theorem
    have d_bot' : DerivationTree FrameClass.Base ((φ.and ψ) :: Γ') Formula.bot :=
      DerivationTree.weakening L ((φ.and ψ) :: Γ') Formula.bot d_bot h_L_sub
    have d_neg : DerivationTree FrameClass.Base Γ' (φ.and ψ).neg :=
      FormalSystem.Metalogic.Core.deductionTheorem Γ' (φ.and ψ) Formula.bot d_bot'
    -- But from φ, ψ ∈ Γ, we can derive φ ∧ ψ
    -- Add φ and ψ to Γ' (they're in Γ)
    have d_neg' : DerivationTree FrameClass.Base (ψ :: φ :: Γ') (φ.and ψ).neg :=
      DerivationTree.weakening Γ' (ψ :: φ :: Γ') (φ.and ψ).neg d_neg
        (fun x hx => by simp only [List.mem_cons]; right; right; exact hx)
    have d_φ : DerivationTree FrameClass.Base (ψ :: φ :: Γ') φ :=
      DerivationTree.assumption (ψ :: φ :: Γ') φ (by simp)
    have d_ψ : DerivationTree FrameClass.Base (ψ :: φ :: Γ') ψ :=
      DerivationTree.assumption (ψ :: φ :: Γ') ψ (by simp)
    -- Derive φ ∧ ψ using conjunction introduction
    -- φ.and ψ = (φ.imp ψ.neg).neg
    -- Need to show: from φ and ψ, derive ¬(φ → ¬ψ)
    -- Strategy: assume (φ → ¬ψ), from φ get ¬ψ, but we have ψ, contradiction
    have d_and : DerivationTree FrameClass.Base (ψ :: φ :: Γ') (φ.and ψ) := by
      -- φ.and ψ = (φ.imp ψ.neg).neg
      -- To prove ¬(φ → ¬ψ), assume (φ → ¬ψ) and derive ⊥
      -- Then apply deduction theorem
      let ctx := ψ :: φ :: Γ'
      let hyp := φ.imp ψ.neg
      -- In (hyp :: ctx), we have φ → ¬ψ, φ, and ψ
      have d_hyp : DerivationTree FrameClass.Base (hyp :: ctx) hyp :=
        DerivationTree.assumption (hyp :: ctx) hyp (by simp)
      have d_φ' : DerivationTree FrameClass.Base (hyp :: ctx) φ :=
        DerivationTree.assumption (hyp :: ctx) φ (by simp [ctx])
      have d_ψ' : DerivationTree FrameClass.Base (hyp :: ctx) ψ :=
        DerivationTree.assumption (hyp :: ctx) ψ (by simp [ctx])
      -- From φ → ¬ψ and φ, get ¬ψ
      have d_neg_ψ' : DerivationTree FrameClass.Base (hyp :: ctx) ψ.neg :=
        DerivationTree.modus_ponens (hyp :: ctx) φ ψ.neg d_hyp d_φ'
      -- From ψ and ¬ψ = ψ → ⊥, get ⊥
      have d_bot' : DerivationTree FrameClass.Base (hyp :: ctx) Formula.bot :=
        DerivationTree.modus_ponens (hyp :: ctx) ψ Formula.bot d_neg_ψ' d_ψ'
      -- By deduction theorem, ctx ⊢ ¬hyp = ctx ⊢ (φ → ¬ψ) → ⊥
      exact FormalSystem.Metalogic.Core.deductionTheorem ctx hyp Formula.bot d_bot'
    -- From φ ∧ ψ and ¬(φ ∧ ψ), derive ⊥
    have d_bot'' : DerivationTree FrameClass.Base (ψ :: φ :: Γ') Formula.bot :=
      DerivationTree.modus_ponens (ψ :: φ :: Γ') (φ.and ψ) Formula.bot d_neg' d_and
    -- But ψ :: φ :: Γ' ⊆ Γ
    have h_cons : Consistent (fc := FrameClass.Base) (ψ :: φ :: Γ') := by
      apply h_mcs.1 (ψ :: φ :: Γ')
      intro χ hχ
      simp only [List.mem_cons] at hχ
      rcases hχ with rfl | rfl | hχ'
      · exact h_psi_mem
      · exact h_phi_mem
      · exact h_Γ'_sub χ hχ'
    exact h_cons ⟨d_bot''⟩
  -- Show a ⊓ b = [φ ∧ ψ]
  use φ.and ψ, h_and_in
  rw [h_a_eq, h_b_eq]
  rfl

/--
For any a, either a ∈ mcsToSet Γ or aᶜ ∈ mcsToSet Γ.

This follows from MCS being negation-complete: for any φ, either φ ∈ Γ or ¬φ ∈ Γ.
-/
theorem mcsToSet_compl_or {Γ : Set Formula} (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) Γ)
    (a : LindenbaumAlg) : a ∈ mcsToSet Γ ∨ aᶜ ∈ mcsToSet Γ := by
  induction a using Quotient.ind with
  | _ φ =>
    -- Either φ ∈ Γ or ¬φ ∈ Γ (by set-based negation completeness)
    by_cases h : φ ∈ Γ
    · left; exact ⟨φ, h, rfl⟩
    · right
      -- If φ ∉ Γ, show ¬φ ∈ Γ using maximality
      have h_incons : ¬SetConsistent (fc := FrameClass.Base) (insert φ Γ) := h_mcs.2 φ h
      unfold SetConsistent at h_incons
      push Not at h_incons
      obtain ⟨L, hL, hL_incons⟩ := h_incons
      have ⟨d_bot⟩ := FormalSystem.Metalogic.Core.inconsistent_derives_bot hL_incons
      -- Extract Γ' = L.filter (· ≠ φ)
      let Γ' := L.filter (· ≠ φ)
      have h_Γ'_sub : ∀ χ ∈ Γ', χ ∈ Γ := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχL := hχ'.1
        have hχne : χ ≠ φ := by simpa using hχ'.2
        specialize hL χ hχL
        simp only [Set.mem_insert_iff] at hL
        rcases hL with rfl | h_in_Γ
        · exact absurd rfl hχne
        · exact h_in_Γ
      have h_L_sub : L ⊆ φ :: Γ' := by
        intro χ hχ
        by_cases hχeq : χ = φ
        · simp [hχeq]
        · simp only [List.mem_cons]; right
          exact List.mem_filter.mpr ⟨hχ, by simpa⟩
      have d_bot' : DerivationTree FrameClass.Base (φ :: Γ') Formula.bot :=
        DerivationTree.weakening L (φ :: Γ') Formula.bot d_bot h_L_sub
      have d_neg : DerivationTree FrameClass.Base Γ' φ.neg :=
        FormalSystem.Metalogic.Core.deductionTheorem Γ' φ Formula.bot d_bot'
      -- Show ¬φ ∈ Γ by closure
      have h_neg_in : φ.neg ∈ Γ := by
        by_contra h_neg_not
        -- If ¬φ ∉ Γ, then insert ¬φ Γ is inconsistent
        have h_incons' : ¬SetConsistent (fc := FrameClass.Base) (insert φ.neg Γ) := h_mcs.2 φ.neg
            h_neg_not
        unfold SetConsistent at h_incons'
        push Not at h_incons'
        obtain ⟨L', hL', hL'_incons⟩ := h_incons'
        have ⟨d_bot'⟩ := FormalSystem.Metalogic.Core.inconsistent_derives_bot hL'_incons
        let Γ'' := L'.filter (· ≠ φ.neg)
        have h_Γ''_sub : ∀ χ ∈ Γ'', χ ∈ Γ := by
          intro χ hχ
          have hχ' := List.mem_filter.mp hχ
          have hχne : χ ≠ φ.neg := by simpa using hχ'.2
          specialize hL' χ hχ'.1
          simp only [Set.mem_insert_iff] at hL'
          rcases hL' with rfl | h_in_Γ
          · exact absurd rfl hχne
          · exact h_in_Γ
        have h_L'_sub : L' ⊆ φ.neg :: Γ'' := by
          intro χ hχ
          by_cases hχeq : χ = φ.neg
          · simp [hχeq]
          · simp only [List.mem_cons]; right
            exact List.mem_filter.mpr ⟨hχ, by simp [hχeq]⟩
        have d_bot'' : DerivationTree FrameClass.Base (φ.neg :: Γ'') Formula.bot :=
          DerivationTree.weakening L' (φ.neg :: Γ'') Formula.bot d_bot' h_L'_sub
        have d_neg_neg : DerivationTree FrameClass.Base Γ'' φ.neg.neg :=
          FormalSystem.Metalogic.Core.deductionTheorem Γ'' φ.neg Formula.bot d_bot''
        -- From ¬¬φ derive φ (double negation elimination)
        have d_dne : DerivationTree FrameClass.Base [] (φ.neg.neg.imp φ) :=
            FormalSystem.Theorems.Propositional.doubleNegation φ
        have d_dne' : DerivationTree FrameClass.Base Γ'' (φ.neg.neg.imp φ) :=
          DerivationTree.weakening [] Γ'' _ d_dne (by simp)
        have d_φ : DerivationTree FrameClass.Base Γ'' φ :=
          DerivationTree.modus_ponens Γ'' φ.neg.neg φ d_dne' d_neg_neg
        -- Now we have Γ'' ⊢ ¬φ (from earlier, weaken d_neg)
        -- and Γ'' ⊢ φ, deriving ⊥
        -- Actually, d_neg is from Γ', not Γ''
        -- We need to unify these. Let's combine Γ' and Γ''

        -- Both Γ' ⊆ Γ and Γ'' ⊆ Γ
        -- Use Γ' ∪ Γ'' which is still a subset of Γ
        -- Actually simpler: weaken both to a combined list

        -- Check: Γ' ⊆ Γ, so we can add Γ'' to get (Γ'' ++ Γ') ⊢ ¬φ
        have d_neg_combined : DerivationTree FrameClass.Base (Γ'' ++ Γ') φ.neg :=
          DerivationTree.weakening Γ' (Γ'' ++ Γ') φ.neg d_neg (by simp)
        have d_φ_combined : DerivationTree FrameClass.Base (Γ'' ++ Γ') φ :=
          DerivationTree.weakening Γ'' (Γ'' ++ Γ') φ d_φ (by simp)
        have d_bot_combined : DerivationTree FrameClass.Base (Γ'' ++ Γ') Formula.bot :=
          DerivationTree.modus_ponens (Γ'' ++ Γ') φ Formula.bot d_neg_combined d_φ_combined
        -- But Γ'' ++ Γ' ⊆ Γ
        have h_combined_cons : Consistent (fc := FrameClass.Base) (Γ'' ++ Γ') := by
          apply h_mcs.1 (Γ'' ++ Γ')
          intro χ hχ
          simp only [List.mem_append] at hχ
          rcases hχ with hχ'' | hχ'
          · exact h_Γ''_sub χ hχ''
          · exact h_Γ'_sub χ hχ'
        exact h_combined_cons ⟨d_bot_combined⟩
      use φ.neg, h_neg_in
      rfl

/--
If a ∈ mcsToSet Γ, then aᶜ ∉ mcsToSet Γ.

An element and its complement cannot both be in mcsToSet, because that would
mean both φ and ¬φ are in Γ, contradicting consistency.
-/
theorem mcsToSet_compl_not {Γ : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) Γ)
    {a : LindenbaumAlg} (ha : a ∈ mcsToSet Γ) : aᶜ ∉ mcsToSet Γ := by
  obtain ⟨φ, h_phi_mem, h_a_eq⟩ := ha
  intro ⟨ψ, h_psi_mem, h_compl_eq⟩
  -- h_compl_eq : aᶜ = toQuot ψ
  -- aᶜ = (toQuot φ)ᶜ = toQuot φ.neg
  rw [h_a_eq] at h_compl_eq
  -- So [φ]ᶜ = [ψ], i.e., [φ.neg] = [ψ]
  -- This means ⊢ φ.neg ↔ ψ, so ⊢ ψ → ¬φ
  -- The complement (toQuot φ)ᶜ = negQuot (toQuot φ) = toQuot φ.neg
  have h_eq : toQuot φ.neg = toQuot ψ := h_compl_eq
  have h_le1 : toQuot ψ ≤ toQuot φ.neg := by
    rw [← h_eq]
  -- ψ ≤ φ.neg means ⊢ ψ → ¬φ
  obtain ⟨d_imp⟩ := (h_le1 : Derives ψ φ.neg)
  -- φ.neg ≤ ψ means ⊢ ¬φ → ψ (not needed actually)

  -- Now [φ, ψ] ⊢ ⊥
  have d_φ : [φ, ψ] ⊢ φ := DerivationTree.assumption [φ, ψ] φ (by simp)
  have d_ψ : [φ, ψ] ⊢ ψ := DerivationTree.assumption [φ, ψ] ψ (by simp)
  have d_imp' : [φ, ψ] ⊢ ψ.imp φ.neg :=
    DerivationTree.weakening [] [φ, ψ] (ψ.imp φ.neg) d_imp (by simp)
  have d_neg : [φ, ψ] ⊢ φ.neg :=
    DerivationTree.modus_ponens [φ, ψ] ψ φ.neg d_imp' d_ψ
  have d_bot : [φ, ψ] ⊢ Formula.bot :=
    DerivationTree.modus_ponens [φ, ψ] φ Formula.bot d_neg d_φ
  -- But [φ, ψ] ⊆ Γ
  have h_cons : Consistent (fc := FrameClass.Base) [φ, ψ] := by
    apply h_mcs.1 [φ, ψ]
    intro χ hχ
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hχ
    rcases hχ with rfl | rfl
    · exact h_phi_mem
    · exact h_psi_mem
  exact h_cons ⟨d_bot⟩

/--
`[φ] ∈ mcsToSet Γ ↔ φ ∈ Γ` for an MCS `Γ`: the forward direction uses that `[φ] = [ψ]` with
`ψ ∈ Γ` gives `⊢ ψ → φ`, which is in `Γ` by `theorem_in_mcs`, so `φ ∈ Γ` by closure under
modus ponens (`implication_property`). This is the single fact both halves of the correspondence
used to re-prove by hand.
-/
theorem toQuot_mem_mcsToSet_iff {Γ : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) Γ) (φ : Formula) :
    toQuot φ ∈ mcsToSet Γ ↔ φ ∈ Γ := by
  refine ⟨fun ⟨ψ, hψ, h_eq⟩ => ?_, mem_mcsToSet⟩
  obtain ⟨d_imp⟩ := (show toQuot ψ ≤ toQuot φ by rw [← h_eq] : Derives ψ φ)
  exact h_mcs.implication_property (theorem_in_mcs h_mcs d_imp) hψ

/-!
## MCS to Ultrafilter Construction

Using the helper lemmas, we construct an ultrafilter from an MCS.
-/

/--
`mcsToSet Γ` is a filter (`Order.IsPFilter`) for an MCS `Γ`: it is nonempty (`⊤`), downward
directed (closed under `⊓`), and upward closed. The three witnesses are the existing
`mcsToSet_top`, `mcsToSet_inf_mem`, `mcsToSet_mem_of_le`, reused unchanged.
-/
theorem mcsToSet_isPFilter {Γ : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) Γ) : IsPFilter (mcsToSet Γ) :=
  IsPFilter.of_def ⟨⊤, mcsToSet_top h_mcs⟩
    (fun a ha b hb => ⟨a ⊓ b, mcsToSet_inf_mem h_mcs ha hb, inf_le_left, inf_le_right⟩)
    (fun hle ha => mcsToSet_mem_of_le h_mcs ha hle)

/--
The bundled filter `{ [φ] | φ ∈ Γ }` on the Lindenbaum algebra, for an MCS `Γ`.
-/
def mcsToPFilter (Γ : {S : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) S}) :
    PFilter LindenbaumAlg := (mcsToSet_isPFilter Γ.2).toPFilter

/--
Membership in `mcsToPFilter Γ` is membership in `mcsToSet Γ`, definitionally.
-/
theorem mem_mcsToPFilter_iff
    (Γ : {S : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) S})
    (a : LindenbaumAlg) : a ∈ mcsToPFilter Γ ↔ a ∈ mcsToSet Γ.1 := Iff.rfl

/--
`mcsToPFilter Γ` is proper: `⊥ ∉ mcsToSet Γ` (`mcsToSet_bot_not_mem`, reused unchanged).
-/
instance mcsToPFilter_isProper
    (Γ : {S : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) S}) :
    (mcsToPFilter Γ).IsProper :=
  PFilter.isProper_of_notMem (mcsToSet_bot_not_mem Γ.2)

/--
`mcsToPFilter Γ` is prime (= an ultrafilter of the Boolean algebra): for every `a`, `a` or `aᶜ`
is in it (`mcsToSet_compl_or`, reused unchanged).
-/
instance mcsToPFilter_isPrime
    (Γ : {S : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) S}) :
    (mcsToPFilter Γ).IsPrime :=
  PFilter.isPrime_of_mem_or_compl_mem fun {a} => mcsToSet_compl_or Γ.2 a

/--
Convert an MCS to a prime filter (= ultrafilter) on the Lindenbaum algebra.

Given a maximal consistent set Γ, the set `{ [φ] | φ ∈ Γ }` is a prime filter:
`mcsToPFilter Γ` bundled with its `IsPrime` instance.
-/
def mcsToUltrafilter (Γ : {S : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) S}) :
    PrimeFilter LindenbaumAlg := ⟨mcsToPFilter Γ, inferInstance⟩

/--
Membership in mcsToUltrafilter iff formula-class in mcsToSet (definitional).
-/
theorem mem_mcsToUltrafilter_iff (Γ : {S : Set Formula // SetMaximalConsistent
    (fc := FrameClass.Base) S}) (a : LindenbaumAlg) :
    a ∈ mcsToUltrafilter Γ ↔ a ∈ mcsToSet Γ.val := Iff.rfl

/-!
## Fold-Derives Lemma

The key lemma relating list derivation to the quotient algebra ordering.
-/

/--
If L derives ψ, then the meet (`Multiset.inf`) of the quotients of L is ≤ [ψ].

This is the key lemma for showing that ultrafilterToSet is consistent:
from `L ⊢ ⊥` we get `inf L ≤ ⊥`, so if `inf L ∈ U`, then `⊥ ∈ U` by upward closure.
-/
theorem fold_le_of_derives (L : List Formula) (ψ : Formula)
    (h : DerivationTree FrameClass.Base L ψ) :
    ((L.map toQuot : List LindenbaumAlg) : Multiset LindenbaumAlg).inf ≤ toQuot ψ := by
  induction L generalizing ψ with
  | nil =>
    -- [] ⊢ ψ means ⊢ ψ (a theorem), so ⊤ ≤ [ψ]
    -- ⊤ = toQuot (⊥ → ⊥), so need ⊢ (⊥ → ⊥) → ψ
    simp only [List.map_nil, Multiset.coe_nil, Multiset.inf_zero]
    change topQuot ≤ toQuot ψ
    unfold topQuot
    change Derives (Formula.bot.imp Formula.bot) ψ
    unfold Derives
    -- From h : [] ⊢ ψ, we get ⊢ ψ. Then ⊢ T → ψ by prop_s.
    have d_s : DerivationTree FrameClass.Base [] (ψ.imp ((Formula.bot.imp Formula.bot).imp ψ)) :=
      DerivationTree.axiom [] _ (Axiom.prop_s ψ (Formula.bot.imp Formula.bot)) trivial
    exact ⟨DerivationTree.modus_ponens [] _ _ d_s h⟩
  | cons φ L' ih =>
    -- (φ :: L') ⊢ ψ, need to show: [φ] ⊓ inf(L') ≤ [ψ]
    -- Use deduction theorem: L' ⊢ φ → ψ
    -- By IH: inf(L') ≤ [φ → ψ]
    -- Then: [φ] ⊓ inf(L') ≤ [φ] ⊓ [φ → ψ] ≤ [ψ]
    simp only [List.map_cons, ← Multiset.cons_coe, Multiset.inf_cons]
    -- Apply deduction theorem to get L' ⊢ φ → ψ
    have d_imp : DerivationTree FrameClass.Base L' (φ.imp ψ) :=
      FormalSystem.Metalogic.Core.deductionTheorem L' φ ψ h
    -- By IH: inf(L') ≤ [φ → ψ]
    have ih_applied : ((L'.map toQuot : List LindenbaumAlg) : Multiset LindenbaumAlg).inf ≤
        toQuot (φ.imp ψ) := ih (φ.imp ψ) d_imp
    -- First show: [φ] ⊓ [φ → ψ] ≤ [ψ]
    have mp_le : toQuot φ ⊓ toQuot (φ.imp ψ) ≤ toQuot ψ := by
      -- [φ ∧ (φ → ψ)] ≤ [ψ] means ⊢ (φ ∧ (φ → ψ)) → ψ
      change andQuot (toQuot φ) (toQuot (φ.imp ψ)) ≤ toQuot ψ
      -- The BooleanAlgebra instance gives us: inf = andQuot
      -- andQuot [φ] [φ → ψ] = [φ ∧ (φ → ψ)]
      -- Actually, the inf is defined in the BooleanAlgebra as andQuot
      -- Let's unfold carefully
      change Derives (φ.and (φ.imp ψ)) ψ
      unfold Derives
      -- Need: ⊢ (φ ∧ (φ → ψ)) → ψ
      -- From [φ ∧ (φ → ψ)] we get φ and φ → ψ, then ψ by MP
      have h_ctx : [φ.and (φ.imp ψ)] ⊢ ψ := by
        have h_conj : [φ.and (φ.imp ψ)] ⊢ φ.and (φ.imp ψ) := by
          apply DerivationTree.assumption; simp
        have h_φ : [φ.and (φ.imp ψ)] ⊢ φ := by
          apply DerivationTree.modus_ponens [φ.and (φ.imp ψ)] _ _
          · apply DerivationTree.weakening [] [φ.and (φ.imp ψ)]
            · exact FormalSystem.Theorems.Propositional.lceImp φ (φ.imp ψ)
            · intro; simp
          · exact h_conj
        have h_imp : [φ.and (φ.imp ψ)] ⊢ φ.imp ψ := by
          apply DerivationTree.modus_ponens [φ.and (φ.imp ψ)] _ _
          · apply DerivationTree.weakening [] [φ.and (φ.imp ψ)]
            · exact FormalSystem.Theorems.Propositional.rceImp φ (φ.imp ψ)
            · intro; simp
          · exact h_conj
        exact DerivationTree.modus_ponens [φ.and (φ.imp ψ)] φ ψ h_imp h_φ
      exact ⟨FormalSystem.Metalogic.Core.deductionTheorem [] (φ.and (φ.imp ψ)) ψ h_ctx⟩
    -- Now use monotonicity: [φ] ⊓ inf(L') ≤ [φ] ⊓ [φ → ψ] ≤ [ψ]
    calc toQuot φ ⊓ ((L'.map toQuot : List LindenbaumAlg) : Multiset LindenbaumAlg).inf
        ≤ toQuot φ ⊓ toQuot (φ.imp ψ) := inf_le_inf_left (toQuot φ) ih_applied
      _ ≤ toQuot ψ := mp_le

/-!
## Ultrafilter to MCS Direction

Given a prime filter (= ultrafilter) U on LindenbaumAlg, we construct an MCS.
-/

/--
The set of formulas whose equivalence classes are in a prime filter.

Given prime filter U, this is `{ φ | [φ] ∈ U }`.
-/
def ultrafilterToSet (U : PrimeFilter LindenbaumAlg) : Set Formula :=
  { φ | toQuot φ ∈ U }

/--
ultrafilterToSet U is an MCS.
-/
theorem ultrafilterToSet_mcs (U : PrimeFilter LindenbaumAlg) :
    SetMaximalConsistent (fc := FrameClass.Base) (ultrafilterToSet U) := by
  constructor
  · -- Consistency: for any L ⊆ ultrafilterToSet U, L is consistent (¬(L ⊢ ⊥))
    -- Assume L ⊢ ⊥ and derive contradiction
    intro L hL ⟨d_bot⟩
    -- Key insight: If L ⊢ ⊥ and each [φᵢ] ∈ U, then the meet ⨅[φᵢ] ∈ U,
    -- and since L ⊢ ⊥ gives us [⨀L] ≤ ⊥, we get ⊥ ∈ U (by upward closure).
    -- This contradicts properness (⊥ ∉ U).

    -- Helper: the meet of quotients of list elements is in U
    have h_meet_in_U : ∀ M : List Formula, (∀ ψ ∈ M, toQuot ψ ∈ U) →
        ((M.map toQuot : List LindenbaumAlg) : Multiset LindenbaumAlg).inf ∈ U := by
      intro M
      induction M with
      | nil =>
        intro _
        simp only [List.map_nil, Multiset.coe_nil, Multiset.inf_zero]
        exact PFilter.top_mem
      | cons ψ M ih =>
        intro hM
        simp only [List.map_cons, ← Multiset.cons_coe, Multiset.inf_cons]
        exact PFilter.inf_mem (hM ψ (by simp)) (ih (fun φ hφ => hM φ (by simp [hφ])))
    -- Now use this to show ⊥ ∈ U
    have h_all_in_U : ∀ ψ ∈ L, toQuot ψ ∈ U := hL
    have h_meet : ((L.map toQuot : List LindenbaumAlg) : Multiset LindenbaumAlg).inf ∈ U :=
      h_meet_in_U L h_all_in_U
    -- From L ⊢ ⊥ and fold_le_of_derives, we get inf L ≤ [⊥] = ⊥
    have h_le_bot : ((L.map toQuot : List LindenbaumAlg) : Multiset LindenbaumAlg).inf ≤
        toQuot Formula.bot :=
      fold_le_of_derives L Formula.bot d_bot
    -- Since fold L ∈ U and fold L ≤ ⊥, by upward closure ⊥ ∈ U
    -- Note: toQuot Formula.bot = ⊥ in the BooleanAlgebra
    have h_bot_eq : toQuot Formula.bot = ⊥ := rfl
    rw [h_bot_eq] at h_le_bot
    have h_bot_in_U : (⊥ : LindenbaumAlg) ∈ U := PFilter.mem_of_le h_le_bot h_meet
    -- But this contradicts properness (⊥ ∉ U)
    exact U.2.toIsProper.bot_notMem h_bot_in_U
  · -- Maximality: φ ∉ ultrafilterToSet U implies ¬SetConsistent (fc := FrameClass.Base) (insert φ
  -- (ultrafilterToSet U))
    intro φ hφ
    -- hφ : φ ∉ ultrafilterToSet U, i.e., [φ] ∉ U
    unfold ultrafilterToSet at hφ
    simp only [Set.mem_setOf_eq] at hφ
    -- By primality, either [φ] ∈ U or [φ]ᶜ ∈ U
    -- Since [φ] ∉ U, we have [φ]ᶜ ∈ U
    have h_compl : (toQuot φ)ᶜ ∈ U := U.2.compl_mem_of_notMem hφ
    -- [φ]ᶜ = [¬φ] in the Boolean algebra
    have h_neg_phi : toQuot φ.neg ∈ U := h_compl
    -- So ¬φ ∈ ultrafilterToSet U
    have h_neg_in : φ.neg ∈ ultrafilterToSet U := h_neg_phi
    -- Now show insert φ (ultrafilterToSet U) is inconsistent
    -- It contains both φ and ¬φ
    intro h_cons
    -- h_cons says insert φ (ultrafilterToSet U) is SetConsistent
    -- This means for all L ⊆ insert φ S, L is Consistent
    -- Take L = [φ, ¬φ], which is ⊆ insert φ (ultrafilterToSet U)
    have h_neg_in_insert : φ.neg ∈ insert φ (ultrafilterToSet U) := Set.mem_insert_of_mem φ h_neg_in
    have h_phi_in_insert : φ ∈ insert φ (ultrafilterToSet U) := Set.mem_insert φ
        (ultrafilterToSet U)
    -- Apply h_cons to L = [φ, ¬φ]
    have h_L_cons : Consistent (fc := FrameClass.Base) [φ, φ.neg] := by
      apply h_cons [φ, φ.neg]
      intro ψ hψ
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hψ
      cases hψ with
      | inl h => rw [h]; exact h_phi_in_insert
      | inr h => rw [h]; exact h_neg_in_insert
    -- But [φ, ¬φ] is inconsistent
    apply h_L_cons
    -- Need: [φ, ¬φ] ⊢ ⊥
    -- From φ and ¬φ = φ → ⊥, derive ⊥ via modus ponens
    have h_phi : [φ, φ.neg] ⊢ φ := by
      apply DerivationTree.assumption
      simp
    have h_neg : [φ, φ.neg] ⊢ φ.neg := by
      apply DerivationTree.assumption
      simp
    exact ⟨DerivationTree.modus_ponens [φ, φ.neg] φ Formula.bot h_neg h_phi⟩

/-!
## Bijection

The two directions are inverses; the bijection is packaged as the `Equiv`
`SetMaximalConsistent.ultrafilterEquiv`, and the existential `ultrafilter_correspondence` is its
corollary.
-/

/--
The MCS/ultrafilter correspondence as an `Equiv` between maximal consistent sets and prime
filters (= ultrafilters) of the Lindenbaum algebra: `mcsToUltrafilter` and `ultrafilterToSet` are
inverse to each other.
-/
noncomputable def SetMaximalConsistent.ultrafilterEquiv :
    {Γ : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) Γ} ≃
      PrimeFilter LindenbaumAlg where
  toFun := mcsToUltrafilter
  invFun U := ⟨ultrafilterToSet U, ultrafilterToSet_mcs U⟩
  left_inv Γ := Subtype.ext (Set.ext fun φ => toQuot_mem_mcsToSet_iff Γ.2 φ)
  right_inv U := by
    apply PrimeFilter.ext
    intro a
    constructor
    · rintro ⟨φ, h_phi_in, h_eq⟩
      rw [show a = toQuot φ from h_eq]
      exact h_phi_in
    · intro h_mem
      induction a using Quotient.ind with
      | _ φ => exact ⟨φ, h_mem, rfl⟩

/--
The MCS-ultrafilter correspondence is a bijection.

`mcsToUltrafilter` and `ultrafilterToSet` are inverses of each other; corollary of
`SetMaximalConsistent.ultrafilterEquiv`.
-/
theorem SetMaximalConsistent.ultrafilter_correspondence :
    ∃ (f : {Γ : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) Γ} → PrimeFilter
        LindenbaumAlg)
      (g : PrimeFilter LindenbaumAlg → {Γ : Set Formula // SetMaximalConsistent
          (fc := FrameClass.Base) Γ}),
      Function.LeftInverse g f ∧ Function.RightInverse g f :=
  ⟨SetMaximalConsistent.ultrafilterEquiv, SetMaximalConsistent.ultrafilterEquiv.symm,
    SetMaximalConsistent.ultrafilterEquiv.left_inv, SetMaximalConsistent.ultrafilterEquiv.right_inv⟩

/-!
## Helper Lemmas for Prime-Filter Properties

These lemmas make it easier to work with prime filters (= ultrafilters) in the context of
temporal and modal accessibility relations. The generic facts (`a ∈ U ↔ aᶜ ∉ U`,
`a ∉ U ↔ aᶜ ∈ U`) live in `FormalSystem/ForMathlib/Order/PFilter.lean` as
`Order.PFilter.IsPrime.mem_iff_compl_notMem` / `compl_mem_iff_notMem`.
-/

/--
For formulas: [φ] ∈ U iff [¬φ] ∉ U.

This is the formula-level version of prime-filter negation completeness
(`(toQuot φ)ᶜ = toQuot φ.neg` is `rfl`).
-/
theorem ultrafilter_neg_iff (U : PrimeFilter LindenbaumAlg) (φ : Formula) :
    toQuot φ ∈ U ↔ toQuot φ.neg ∉ U := U.2.mem_iff_compl_notMem

/--
For formulas: [¬φ] ∈ U iff [φ] ∉ U.
-/
theorem ultrafilter_neg_iff' (U : PrimeFilter LindenbaumAlg) (φ : Formula) :
    toQuot φ.neg ∈ U ↔ toQuot φ ∉ U := U.2.compl_mem_iff_notMem (x := toQuot φ)

/--
Convenience: wrap ultrafilterToSet result with its MCS proof
(definitionally `SetMaximalConsistent.ultrafilterEquiv.symm U`).
-/
noncomputable def ultrafilterToMcs (U : PrimeFilter LindenbaumAlg) :
    {Γ : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) Γ} :=
  ⟨ultrafilterToSet U, ultrafilterToSet_mcs U⟩

/--
The carrier of ultrafilterToMcs.
-/
@[simp]
theorem ultrafilter_to_mcs_val (U : PrimeFilter LindenbaumAlg) :
    (ultrafilterToMcs U).val = ultrafilterToSet U := rfl

end FormalSystem.Metalogic.Algebraic.UltrafilterMCS
