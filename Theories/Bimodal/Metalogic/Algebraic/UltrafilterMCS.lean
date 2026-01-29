import Bimodal.Metalogic.Algebraic.InteriorOperators
import Bimodal.Metalogic.Core.MaximalConsistent

/-!
# Ultrafilter-MCS Correspondence

This module establishes the bijection between ultrafilters of the Lindenbaum algebra
and maximal consistent sets.

## Main Results

- `mcs_to_ultrafilter`: MCS → Ultrafilter LindenbaumAlg
- `ultrafilter_to_mcs`: Ultrafilter LindenbaumAlg → MCS
- The two maps are inverses

## Status

Phase 5 of Task 700. Contains sorries pending MCS helper lemmas.
-/

namespace Bimodal.Metalogic.Algebraic.UltrafilterMCS

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient
open Bimodal.Metalogic.Algebraic.BooleanStructure
open Bimodal.Metalogic.Core

/-!
## Ultrafilter Definition for Boolean Algebras

An ultrafilter on a Boolean algebra is a proper filter that contains exactly one
of each element and its complement.
-/

/--
An ultrafilter on a Boolean algebra.
-/
structure Ultrafilter (α : Type*) [BooleanAlgebra α] where
  /-- The carrier set of the ultrafilter -/
  carrier : Set α
  /-- Ultrafilters contain ⊤ -/
  top_mem : ⊤ ∈ carrier
  /-- Ultrafilters don't contain ⊥ -/
  bot_not_mem : ⊥ ∉ carrier
  /-- Ultrafilters are upward closed -/
  mem_of_le : ∀ {a b}, a ∈ carrier → a ≤ b → b ∈ carrier
  /-- Ultrafilters are closed under finite meets -/
  inf_mem : ∀ {a b}, a ∈ carrier → b ∈ carrier → a ⊓ b ∈ carrier
  /-- For each element, exactly one of it or its complement is in the ultrafilter -/
  compl_or : ∀ a, a ∈ carrier ∨ aᶜ ∈ carrier
  /-- An element and its complement cannot both be in the ultrafilter -/
  compl_not : ∀ a, a ∈ carrier → aᶜ ∉ carrier

/--
Membership in an ultrafilter's carrier.
-/
instance instMembershipUltrafilter {α : Type*} [BooleanAlgebra α] :
    Membership α (Ultrafilter α) where
  mem U a := a ∈ U.carrier

/--
An ultrafilter doesn't contain ⊥.
-/
theorem Ultrafilter.empty_not_mem {α : Type*} [BooleanAlgebra α] (U : Ultrafilter α) :
    ⊥ ∉ U.carrier := U.bot_not_mem

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
theorem mcsToSet_top {Γ : Set Formula} (h_mcs : SetMaximalConsistent Γ) :
    ⊤ ∈ mcsToSet Γ := by
  have d_id : DerivationTree [] (Formula.bot.imp Formula.bot) :=
    Bimodal.Theorems.Combinators.identity Formula.bot
  have h : Formula.bot.imp Formula.bot ∈ Γ := theorem_in_mcs h_mcs d_id
  exact ⟨Formula.bot.imp Formula.bot, h, rfl⟩

/--
mcsToSet Γ does not contain ⊥.

For an MCS Γ, the set `{ [φ] | φ ∈ Γ }` cannot contain ⊥ = [⊥],
because MCS is consistent and ⊥ ∈ Γ would derive ⊥ from a finite subset.
-/
theorem mcsToSet_bot_not_mem {Γ : Set Formula} (h_mcs : SetMaximalConsistent Γ) :
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
  have h_phi_incons : ¬Consistent [φ] := by
    intro h_cons
    have d_phi : [φ] ⊢ φ := DerivationTree.assumption [φ] φ (by simp)
    have d_bot : [φ] ⊢ Formula.bot := DerivationTree.modus_ponens [φ] φ Formula.bot
      (DerivationTree.weakening [] [φ] (Formula.neg φ) d_neg (by simp)) d_phi
    exact h_cons ⟨d_bot⟩
  -- But φ ∈ Γ and Γ is MCS, so [φ] should be consistent
  have h_cons : Consistent [φ] := h_mcs.1 [φ] (by simp [h_mem])
  exact h_phi_incons h_cons

/--
mcsToSet Γ is upward closed: if [a] ∈ mcsToSet Γ and a ≤ b, then [b] ∈ mcsToSet Γ.

This follows from MCS being deductively closed: a ≤ b means ⊢ a → b,
so a ∈ Γ and ⊢ a → b implies b ∈ Γ (by closure under modus ponens).
-/
theorem mcsToSet_mem_of_le {Γ : Set Formula} (h_mcs : SetMaximalConsistent Γ)
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
      have h_incons : ¬SetConsistent (insert ψ Γ) := h_mcs.2 ψ h_not
      unfold SetConsistent at h_incons
      push_neg at h_incons
      obtain ⟨L, hL, hL_incons⟩ := h_incons
      -- hL_incons: ¬Consistent L
      have ⟨d_bot⟩ := Bimodal.Metalogic_v2.Core.inconsistent_derives_bot hL_incons
      -- Since [] ⊢ φ → ψ and φ ∈ Γ, we have that any list containing ψ
      -- can replace ψ with φ and φ → ψ and still derive ⊥
      -- Actually, we need to construct a derivation from L \ {ψ} ∪ {φ}
      -- This is getting complex; let's use a different approach.
      -- Since ⊢ φ → ψ, we have ⊢ ¬ψ → ¬φ by contraposition
      -- If ψ ∉ Γ, by negation completeness ¬ψ ∈ Γ
      -- Then from ⊢ φ → ψ and ¬ψ ∈ Γ, we'd get ¬φ ∈ Γ
      -- But φ ∈ Γ and ¬φ ∈ Γ contradicts consistency

      -- We need contraposition: ⊢ (φ → ψ) → (¬ψ → ¬φ)
      have d_contra : DerivationTree [] ((φ.imp ψ).imp (ψ.neg.imp φ.neg)) :=
        Bimodal.Theorems.Propositional.contrapose_imp φ ψ
      have d_neg_ψ_to_neg_φ : DerivationTree [] (ψ.neg.imp φ.neg) :=
        DerivationTree.modus_ponens [] _ _ d_contra d_imp

      -- Since ψ ∉ Γ and Γ is MCS...
      -- We need set-based negation completeness. Let's prove it directly.
      -- If ψ ∉ Γ, then insert ψ Γ is inconsistent.
      -- This means there's a list L ⊆ insert ψ Γ with L ⊢ ⊥
      -- From this we can derive Γ ⊢ ¬ψ
      -- Actually, the theorem_in_mcs and closure require List-based MCS properties.
      -- Let's show ¬ψ ∈ Γ using the structure of set-based consistency.

      -- By maximality of Γ: since ψ ∉ Γ, insert ψ Γ is inconsistent
      -- There exists L ⊆ insert ψ Γ with ¬Consistent L
      -- We already have this from h_incons

      -- Let Γ' = L.filter (· ≠ ψ). Then Γ' ⊆ Γ and L ⊆ ψ :: Γ'
      let Γ' := L.filter (· ≠ ψ)
      have h_Γ'_sub : ∀ χ ∈ Γ', χ ∈ Γ := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχL := hχ'.1
        have hχne : χ ≠ ψ := by simpa using hχ'.2
        specialize hL χ hχL
        simp [Set.mem_insert_iff] at hL
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
      have d_bot' : DerivationTree (ψ :: Γ') Formula.bot :=
        DerivationTree.weakening L (ψ :: Γ') Formula.bot d_bot h_L_sub
      -- By deduction theorem: Γ' ⊢ ¬ψ
      have d_neg_ψ : DerivationTree Γ' ψ.neg :=
        Bimodal.Metalogic.Core.deduction_theorem Γ' ψ Formula.bot d_bot'
      -- Weaken to add φ: (φ :: Γ') ⊢ ¬ψ
      have d_neg_ψ' : DerivationTree (φ :: Γ') ψ.neg :=
        DerivationTree.weakening Γ' (φ :: Γ') ψ.neg d_neg_ψ (fun x hx => List.mem_cons_of_mem φ hx)
      -- We also have (φ :: Γ') ⊢ φ → ψ
      have d_imp' : DerivationTree (φ :: Γ') (φ.imp ψ) :=
        DerivationTree.weakening [] (φ :: Γ') (φ.imp ψ) d_imp (by simp)
      -- And (φ :: Γ') ⊢ φ
      have d_φ : DerivationTree (φ :: Γ') φ :=
        DerivationTree.assumption (φ :: Γ') φ (by simp)
      -- So (φ :: Γ') ⊢ ψ by modus ponens
      have d_ψ : DerivationTree (φ :: Γ') ψ :=
        DerivationTree.modus_ponens (φ :: Γ') φ ψ d_imp' d_φ
      -- And (φ :: Γ') ⊢ ⊥ from ψ and ¬ψ
      have d_bot'' : DerivationTree (φ :: Γ') Formula.bot :=
        DerivationTree.modus_ponens (φ :: Γ') ψ Formula.bot d_neg_ψ' d_ψ
      -- But φ :: Γ' ⊆ Γ (since φ ∈ Γ and Γ' ⊆ Γ)
      have h_cons_list : Consistent (φ :: Γ') := by
        apply h_mcs.1 (φ :: Γ')
        intro χ hχ
        simp at hχ
        rcases hχ with rfl | hχ'
        · exact h_phi_mem
        · exact h_Γ'_sub χ hχ'
      exact h_cons_list ⟨d_bot''⟩
    exact ⟨ψ, h_psi_in, rfl⟩

/--
mcsToSet Γ is closed under finite meets.
-/
theorem mcsToSet_inf_mem {Γ : Set Formula} (h_mcs : SetMaximalConsistent Γ)
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
    have h_incons : ¬SetConsistent (insert (φ.and ψ) Γ) := h_mcs.2 (φ.and ψ) h_not
    unfold SetConsistent at h_incons
    push_neg at h_incons
    obtain ⟨L, hL, hL_incons⟩ := h_incons
    have ⟨d_bot⟩ := Bimodal.Metalogic_v2.Core.inconsistent_derives_bot hL_incons

    -- Similar to above, extract the part without φ ∧ ψ
    let Γ' := L.filter (· ≠ φ.and ψ)
    have h_Γ'_sub : ∀ χ ∈ Γ', χ ∈ Γ := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχL := hχ'.1
      have hχne : χ ≠ φ.and ψ := by simpa using hχ'.2
      specialize hL χ hχL
      simp [Set.mem_insert_iff] at hL
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
    have d_bot' : DerivationTree ((φ.and ψ) :: Γ') Formula.bot :=
      DerivationTree.weakening L ((φ.and ψ) :: Γ') Formula.bot d_bot h_L_sub
    have d_neg : DerivationTree Γ' (φ.and ψ).neg :=
      Bimodal.Metalogic.Core.deduction_theorem Γ' (φ.and ψ) Formula.bot d_bot'

    -- But from φ, ψ ∈ Γ, we can derive φ ∧ ψ
    -- Add φ and ψ to Γ' (they're in Γ)
    have d_neg' : DerivationTree (ψ :: φ :: Γ') (φ.and ψ).neg :=
      DerivationTree.weakening Γ' (ψ :: φ :: Γ') (φ.and ψ).neg d_neg
        (fun x hx => by simp; right; right; exact hx)
    have d_φ : DerivationTree (ψ :: φ :: Γ') φ :=
      DerivationTree.assumption (ψ :: φ :: Γ') φ (by simp)
    have d_ψ : DerivationTree (ψ :: φ :: Γ') ψ :=
      DerivationTree.assumption (ψ :: φ :: Γ') ψ (by simp)
    -- Derive φ ∧ ψ using conjunction introduction
    -- φ.and ψ = (φ.imp ψ.neg).neg
    -- Need to show: from φ and ψ, derive ¬(φ → ¬ψ)
    -- Strategy: assume (φ → ¬ψ), from φ get ¬ψ, but we have ψ, contradiction
    have d_and : DerivationTree (ψ :: φ :: Γ') (φ.and ψ) := by
      -- φ.and ψ = (φ.imp ψ.neg).neg
      -- To prove ¬(φ → ¬ψ), assume (φ → ¬ψ) and derive ⊥
      -- Then apply deduction theorem
      let ctx := ψ :: φ :: Γ'
      let hyp := φ.imp ψ.neg
      -- In (hyp :: ctx), we have φ → ¬ψ, φ, and ψ
      have d_hyp : DerivationTree (hyp :: ctx) hyp :=
        DerivationTree.assumption (hyp :: ctx) hyp (by simp)
      have d_φ' : DerivationTree (hyp :: ctx) φ :=
        DerivationTree.assumption (hyp :: ctx) φ (by simp [ctx])
      have d_ψ' : DerivationTree (hyp :: ctx) ψ :=
        DerivationTree.assumption (hyp :: ctx) ψ (by simp [ctx])
      -- From φ → ¬ψ and φ, get ¬ψ
      have d_neg_ψ' : DerivationTree (hyp :: ctx) ψ.neg :=
        DerivationTree.modus_ponens (hyp :: ctx) φ ψ.neg d_hyp d_φ'
      -- From ψ and ¬ψ = ψ → ⊥, get ⊥
      have d_bot' : DerivationTree (hyp :: ctx) Formula.bot :=
        DerivationTree.modus_ponens (hyp :: ctx) ψ Formula.bot d_neg_ψ' d_ψ'
      -- By deduction theorem, ctx ⊢ ¬hyp = ctx ⊢ (φ → ¬ψ) → ⊥
      exact Bimodal.Metalogic.Core.deduction_theorem ctx hyp Formula.bot d_bot'
    -- From φ ∧ ψ and ¬(φ ∧ ψ), derive ⊥
    have d_bot'' : DerivationTree (ψ :: φ :: Γ') Formula.bot :=
      DerivationTree.modus_ponens (ψ :: φ :: Γ') (φ.and ψ) Formula.bot d_neg' d_and

    -- But ψ :: φ :: Γ' ⊆ Γ
    have h_cons : Consistent (ψ :: φ :: Γ') := by
      apply h_mcs.1 (ψ :: φ :: Γ')
      intro χ hχ
      simp at hχ
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
theorem mcsToSet_compl_or {Γ : Set Formula} (h_mcs : SetMaximalConsistent Γ)
    (a : LindenbaumAlg) : a ∈ mcsToSet Γ ∨ aᶜ ∈ mcsToSet Γ := by
  induction a using Quotient.ind with
  | _ φ =>
    -- Either φ ∈ Γ or ¬φ ∈ Γ (by set-based negation completeness)
    by_cases h : φ ∈ Γ
    · left; exact ⟨φ, h, rfl⟩
    · right
      -- If φ ∉ Γ, show ¬φ ∈ Γ using maximality
      have h_incons : ¬SetConsistent (insert φ Γ) := h_mcs.2 φ h
      unfold SetConsistent at h_incons
      push_neg at h_incons
      obtain ⟨L, hL, hL_incons⟩ := h_incons
      have ⟨d_bot⟩ := Bimodal.Metalogic_v2.Core.inconsistent_derives_bot hL_incons

      -- Extract Γ' = L.filter (· ≠ φ)
      let Γ' := L.filter (· ≠ φ)
      have h_Γ'_sub : ∀ χ ∈ Γ', χ ∈ Γ := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχL := hχ'.1
        have hχne : χ ≠ φ := by simpa using hχ'.2
        specialize hL χ hχL
        simp [Set.mem_insert_iff] at hL
        rcases hL with rfl | h_in_Γ
        · exact absurd rfl hχne
        · exact h_in_Γ
      have h_L_sub : L ⊆ φ :: Γ' := by
        intro χ hχ
        by_cases hχeq : χ = φ
        · simp [hχeq]
        · simp only [List.mem_cons]; right
          exact List.mem_filter.mpr ⟨hχ, by simpa⟩

      have d_bot' : DerivationTree (φ :: Γ') Formula.bot :=
        DerivationTree.weakening L (φ :: Γ') Formula.bot d_bot h_L_sub
      have d_neg : DerivationTree Γ' φ.neg :=
        Bimodal.Metalogic.Core.deduction_theorem Γ' φ Formula.bot d_bot'

      -- Show ¬φ ∈ Γ by closure
      have h_neg_in : φ.neg ∈ Γ := by
        by_contra h_neg_not
        -- If ¬φ ∉ Γ, then insert ¬φ Γ is inconsistent
        have h_incons' : ¬SetConsistent (insert φ.neg Γ) := h_mcs.2 φ.neg h_neg_not
        unfold SetConsistent at h_incons'
        push_neg at h_incons'
        obtain ⟨L', hL', hL'_incons⟩ := h_incons'
        have ⟨d_bot'⟩ := Bimodal.Metalogic_v2.Core.inconsistent_derives_bot hL'_incons

        let Γ'' := L'.filter (· ≠ φ.neg)
        have h_Γ''_sub : ∀ χ ∈ Γ'', χ ∈ Γ := by
          intro χ hχ
          have hχ' := List.mem_filter.mp hχ
          have hχne : χ ≠ φ.neg := by simpa using hχ'.2
          specialize hL' χ hχ'.1
          simp [Set.mem_insert_iff] at hL'
          rcases hL' with rfl | h_in_Γ
          · exact absurd rfl hχne
          · exact h_in_Γ
        have h_L'_sub : L' ⊆ φ.neg :: Γ'' := by
          intro χ hχ
          by_cases hχeq : χ = φ.neg
          · simp [hχeq]
          · simp only [List.mem_cons]; right
            exact List.mem_filter.mpr ⟨hχ, by simp [hχeq]⟩

        have d_bot'' : DerivationTree (φ.neg :: Γ'') Formula.bot :=
          DerivationTree.weakening L' (φ.neg :: Γ'') Formula.bot d_bot' h_L'_sub
        have d_neg_neg : DerivationTree Γ'' φ.neg.neg :=
          Bimodal.Metalogic.Core.deduction_theorem Γ'' φ.neg Formula.bot d_bot''

        -- From ¬¬φ derive φ (double negation elimination)
        have d_dne := Bimodal.Theorems.Propositional.double_negation φ
        have d_dne' : DerivationTree Γ'' (φ.neg.neg.imp φ) :=
          DerivationTree.weakening [] Γ'' _ d_dne (by simp)
        have d_φ : DerivationTree Γ'' φ :=
          DerivationTree.modus_ponens Γ'' φ.neg.neg φ d_dne' d_neg_neg

        -- Now we have Γ'' ⊢ ¬φ (from earlier, weaken d_neg)
        -- and Γ'' ⊢ φ, deriving ⊥
        -- Actually, d_neg is from Γ', not Γ''
        -- We need to unify these. Let's combine Γ' and Γ''

        -- Both Γ' ⊆ Γ and Γ'' ⊆ Γ
        -- Use Γ' ∪ Γ'' which is still a subset of Γ
        -- Actually simpler: weaken both to a combined list

        -- Check: Γ' ⊆ Γ, so we can add Γ'' to get (Γ'' ++ Γ') ⊢ ¬φ
        have d_neg_combined : DerivationTree (Γ'' ++ Γ') φ.neg :=
          DerivationTree.weakening Γ' (Γ'' ++ Γ') φ.neg d_neg (by simp)
        have d_φ_combined : DerivationTree (Γ'' ++ Γ') φ :=
          DerivationTree.weakening Γ'' (Γ'' ++ Γ') φ d_φ (by simp)
        have d_bot_combined : DerivationTree (Γ'' ++ Γ') Formula.bot :=
          DerivationTree.modus_ponens (Γ'' ++ Γ') φ Formula.bot d_neg_combined d_φ_combined

        -- But Γ'' ++ Γ' ⊆ Γ
        have h_combined_cons : Consistent (Γ'' ++ Γ') := by
          apply h_mcs.1 (Γ'' ++ Γ')
          intro χ hχ
          simp at hχ
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
theorem mcsToSet_compl_not {Γ : Set Formula} (h_mcs : SetMaximalConsistent Γ)
    {a : LindenbaumAlg} (ha : a ∈ mcsToSet Γ) : aᶜ ∉ mcsToSet Γ := by
  obtain ⟨φ, h_phi_mem, h_a_eq⟩ := ha
  intro ⟨ψ, h_psi_mem, h_compl_eq⟩
  -- h_compl_eq : aᶜ = toQuot ψ
  -- aᶜ = (toQuot φ)ᶜ = toQuot φ.neg
  rw [h_a_eq] at h_compl_eq
  -- So [φ]ᶜ = [ψ], i.e., [φ.neg] = [ψ]
  -- This means ⊢ φ.neg ↔ ψ, so ⊢ ψ → ¬φ
  -- The complement (toQuot φ)ᶜ = neg_quot (toQuot φ) = toQuot φ.neg
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
  have h_cons : Consistent [φ, ψ] := by
    apply h_mcs.1 [φ, ψ]
    intro χ hχ
    simp at hχ
    rcases hχ with rfl | rfl
    · exact h_phi_mem
    · exact h_psi_mem
  exact h_cons ⟨d_bot⟩

/-!
## Fold-Derives Lemma

The key lemma relating list derivation to the quotient algebra ordering.
-/

/--
If L derives ψ, then the meet of quotients of L is ≤ [ψ].

This is the key lemma for showing that ultrafilterToSet is consistent:
from `L ⊢ ⊥` we get `fold L ≤ ⊥`, so if `fold L ∈ U`, then `⊥ ∈ U` by upward closure.
-/
theorem fold_le_of_derives (L : List Formula) (ψ : Formula)
    (h : DerivationTree L ψ) :
    List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ≤ toQuot ψ := by
  induction L generalizing ψ with
  | nil =>
    -- [] ⊢ ψ means ⊢ ψ (a theorem), so ⊤ ≤ [ψ]
    -- Need to show: ⊤ ≤ toQuot ψ
    -- ⊤ = toQuot (⊥ → ⊥), so need ⊢ (⊥ → ⊥) → ψ
    simp only [List.foldl_nil]
    -- Since h : [] ⊢ ψ, we have ⊢ ψ
    -- From ⊢ ψ, derive ⊢ ⊤ → ψ (where ⊤ = ⊥ → ⊥)
    show top_quot ≤ toQuot ψ
    unfold top_quot
    -- Need to show: [⊥ → ⊥] ≤ [ψ], i.e., ⊢ (⊥ → ⊥) → ψ
    show Derives (Formula.bot.imp Formula.bot) ψ
    unfold Derives
    -- From h : [] ⊢ ψ, we get ⊢ ψ. Then ⊢ T → ψ by prop_s.
    have d_s : DerivationTree [] (ψ.imp ((Formula.bot.imp Formula.bot).imp ψ)) :=
      DerivationTree.axiom [] _ (Axiom.prop_s ψ (Formula.bot.imp Formula.bot))
    exact ⟨DerivationTree.modus_ponens [] _ _ d_s h⟩
  | cons φ L' ih =>
    -- (φ :: L') ⊢ ψ, need to show: ⊤ ⊓ [φ] ⊓ fold(L') ≤ [ψ]
    -- Use deduction theorem: L' ⊢ φ → ψ
    -- By IH: fold(L') ≤ [φ → ψ]
    -- Then: ⊤ ⊓ [φ] ⊓ fold(L') ≤ [φ] ⊓ [φ → ψ] ≤ [ψ]
    simp only [List.foldl_cons]
    -- Apply deduction theorem to get L' ⊢ φ → ψ
    have d_imp : DerivationTree L' (φ.imp ψ) :=
      Bimodal.Metalogic.Core.deduction_theorem L' φ ψ h
    -- By IH: fold(L') ≤ [φ → ψ]
    have ih_applied : List.foldl (fun acc χ => acc ⊓ toQuot χ) ⊤ L' ≤ toQuot (φ.imp ψ) :=
      ih (φ.imp ψ) d_imp
    -- We have: List.foldl ... (⊤ ⊓ toQuot φ) L' ≤ [ψ]
    -- The left side is fold(L') starting from ⊤ ⊓ [φ]
    -- We need to relate fold from (⊤ ⊓ [φ]) with fold from ⊤

    -- Lemma: fold from x = x ⊓ (fold from ⊤)
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
        -- Need: x ⊓ (toQuot m ⊓ fold(M')) = x ⊓ toQuot m ⊓ fold(M')
        -- This is associativity
        rw [← inf_assoc]

    rw [fold_from_x L' (⊤ ⊓ toQuot φ)]
    simp only [top_inf_eq]
    -- Now we have: [φ] ⊓ fold(L') ≤ [ψ]
    -- We know fold(L') ≤ [φ → ψ]
    -- And [φ] ⊓ [φ → ψ] ≤ [ψ] (modus ponens in the algebra)
    -- So [φ] ⊓ fold(L') ≤ [φ] ⊓ [φ → ψ] ≤ [ψ]

    -- First show: [φ] ⊓ [φ → ψ] ≤ [ψ]
    have mp_le : toQuot φ ⊓ toQuot (φ.imp ψ) ≤ toQuot ψ := by
      -- [φ ∧ (φ → ψ)] ≤ [ψ] means ⊢ (φ ∧ (φ → ψ)) → ψ
      show and_quot (toQuot φ) (toQuot (φ.imp ψ)) ≤ toQuot ψ
      -- The BooleanAlgebra instance gives us: inf = and_quot
      -- and_quot [φ] [φ → ψ] = [φ ∧ (φ → ψ)]
      -- Actually, the inf is defined in the BooleanAlgebra as and_quot
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
            · exact Bimodal.Theorems.Propositional.lce_imp φ (φ.imp ψ)
            · intro; simp
          · exact h_conj
        have h_imp : [φ.and (φ.imp ψ)] ⊢ φ.imp ψ := by
          apply DerivationTree.modus_ponens [φ.and (φ.imp ψ)] _ _
          · apply DerivationTree.weakening [] [φ.and (φ.imp ψ)]
            · exact Bimodal.Theorems.Propositional.rce_imp φ (φ.imp ψ)
            · intro; simp
          · exact h_conj
        exact DerivationTree.modus_ponens [φ.and (φ.imp ψ)] φ ψ h_imp h_φ
      exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] (φ.and (φ.imp ψ)) ψ h_ctx⟩

    -- Now use monotonicity: [φ] ⊓ fold(L') ≤ [φ] ⊓ [φ → ψ] ≤ [ψ]
    calc toQuot φ ⊓ List.foldl (fun acc χ => acc ⊓ toQuot χ) ⊤ L'
        ≤ toQuot φ ⊓ toQuot (φ.imp ψ) := inf_le_inf_left (toQuot φ) ih_applied
      _ ≤ toQuot ψ := mp_le

/-!
## Ultrafilter to MCS Direction

Given an ultrafilter U on LindenbaumAlg, we construct an MCS.
-/

/--
The set of formulas whose equivalence classes are in an ultrafilter.

Given ultrafilter U, this is `{ φ | [φ] ∈ U }`.
-/
def ultrafilterToSet (U : Ultrafilter LindenbaumAlg) : Set Formula :=
  { φ | toQuot φ ∈ U }

/--
ultrafilterToSet U is an MCS.
-/
theorem ultrafilterToSet_mcs (U : Ultrafilter LindenbaumAlg) :
    SetMaximalConsistent (ultrafilterToSet U) := by
  constructor
  · -- Consistency: for any L ⊆ ultrafilterToSet U, L is consistent (¬(L ⊢ ⊥))
    intro L hL
    -- Assume L ⊢ ⊥ and derive contradiction
    intro ⟨d_bot⟩
    -- Key insight: If L ⊢ ⊥ and each [φᵢ] ∈ U, then the meet ⨅[φᵢ] ∈ U,
    -- and since L ⊢ ⊥ gives us [⨀L] ≤ ⊥, we get ⊥ ∈ U (by upward closure).
    -- This contradicts U.bot_not_mem.

    -- Helper: the meet of quotients of list elements is in U
    have h_meet_in_U : ∀ M : List Formula, (∀ ψ ∈ M, toQuot ψ ∈ U.carrier) →
        List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ M ∈ U.carrier := by
      intro M
      induction M with
      | nil =>
        intro _
        exact U.top_mem
      | cons ψ M ih =>
        intro hM
        have h_ψ : toQuot ψ ∈ U.carrier := hM ψ (by simp)
        have h_rest : ∀ φ ∈ M, toQuot φ ∈ U.carrier := fun φ hφ => hM φ (by simp [hφ])
        -- fold (ψ :: M) from ⊤ = fold M from (⊤ ⊓ [ψ])
        simp only [List.foldl_cons]
        -- Prove by inner induction: fold from any x ∈ U stays in U if all quotients in U
        have h_fold_preserves : ∀ N : List Formula, (∀ φ ∈ N, toQuot φ ∈ U.carrier) →
            ∀ x : LindenbaumAlg, x ∈ U.carrier →
            List.foldl (fun acc φ => acc ⊓ toQuot φ) x N ∈ U.carrier := by
          intro N
          induction N with
          | nil => intro _ x hx; simp; exact hx
          | cons m N ih_N =>
            intro hN x hx
            simp only [List.foldl_cons]
            apply ih_N (fun φ hφ => hN φ (by simp [hφ]))
            apply U.inf_mem hx (hN m (by simp))
        apply h_fold_preserves M h_rest
        apply U.inf_mem U.top_mem h_ψ
    -- Now use this to show ⊥ ∈ U
    have h_all_in_U : ∀ ψ ∈ L, toQuot ψ ∈ U.carrier := hL
    have h_meet : List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ∈ U.carrier := h_meet_in_U L h_all_in_U
    -- From L ⊢ ⊥ and fold_le_of_derives, we get fold L ≤ [⊥] = ⊥
    have h_le_bot : List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ≤ toQuot Formula.bot :=
      fold_le_of_derives L Formula.bot d_bot
    -- Since fold L ∈ U and fold L ≤ ⊥, by upward closure ⊥ ∈ U
    -- Note: toQuot Formula.bot = ⊥ in the BooleanAlgebra
    have h_bot_eq : toQuot Formula.bot = ⊥ := rfl
    rw [h_bot_eq] at h_le_bot
    have h_bot_in_U : (⊥ : LindenbaumAlg) ∈ U.carrier := U.mem_of_le h_meet h_le_bot
    -- But this contradicts U.bot_not_mem
    exact U.bot_not_mem h_bot_in_U
  · -- Maximality: φ ∉ ultrafilterToSet U implies ¬SetConsistent (insert φ (ultrafilterToSet U))
    intro φ hφ
    -- hφ : φ ∉ ultrafilterToSet U, i.e., [φ] ∉ U
    unfold ultrafilterToSet at hφ
    simp only [Set.mem_setOf_eq] at hφ
    -- By ultrafilter completeness, either [φ] ∈ U or [φ]ᶜ ∈ U
    -- Since [φ] ∉ U, we have [φ]ᶜ ∈ U
    have h_compl : (toQuot φ)ᶜ ∈ U.carrier := by
      cases U.compl_or (toQuot φ) with
      | inl h => exact absurd h hφ
      | inr h => exact h
    -- [φ]ᶜ = [¬φ] in the Boolean algebra
    have h_neg_phi : toQuot φ.neg ∈ U.carrier := h_compl
    -- So ¬φ ∈ ultrafilterToSet U
    have h_neg_in : φ.neg ∈ ultrafilterToSet U := h_neg_phi
    -- Now show insert φ (ultrafilterToSet U) is inconsistent
    -- It contains both φ and ¬φ
    intro h_cons
    -- h_cons says insert φ (ultrafilterToSet U) is SetConsistent
    -- This means for all L ⊆ insert φ S, L is Consistent
    -- Take L = [φ, ¬φ], which is ⊆ insert φ (ultrafilterToSet U)
    have h_neg_in_insert : φ.neg ∈ insert φ (ultrafilterToSet U) := Set.mem_insert_of_mem φ h_neg_in
    have h_phi_in_insert : φ ∈ insert φ (ultrafilterToSet U) := Set.mem_insert φ (ultrafilterToSet U)
    -- Apply h_cons to L = [φ, ¬φ]
    have h_L_cons : Consistent [φ, φ.neg] := by
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

The two directions are inverses.
-/

/--
Placeholder for the bijection proof.
-/
theorem mcs_ultrafilter_correspondence :
    ∃ (f : {Γ : Set Formula // SetMaximalConsistent Γ} → Ultrafilter LindenbaumAlg)
      (g : Ultrafilter LindenbaumAlg → {Γ : Set Formula // SetMaximalConsistent Γ}),
      Function.LeftInverse g f ∧ Function.RightInverse g f := by
  sorry

end Bimodal.Metalogic.Algebraic.UltrafilterMCS
