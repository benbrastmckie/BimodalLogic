import Logos.Core.ProofSystem.Derivation
import Logos.Core.Theorems.Combinators

/-!
# Deduction Theorem - Hilbert System Deduction Infrastructure

This module proves the deduction theorem for the TM logic Hilbert system.

## Main Results

- `deduction_axiom`: If φ is an axiom, then `Γ ⊢ A → φ`
- `deduction_assumption_same`: `Γ ⊢ A → A` (identity)
- `deduction_assumption_other`: If `B ∈ Γ`, then `Γ ⊢ A → B`
- `deduction_mp`: Modus ponens under implication
- `deduction_theorem`: If `A :: Γ ⊢ B` then `Γ ⊢ A → B`

## Implementation Notes

The deduction theorem for Hilbert systems requires induction on the derivation structure.
We handle each case of the Derivable relation:
- Base case: axiom
- Base case: assumption (splits into same vs other)
- Inductive case: modus ponens
- Inductive case: weakening (reduces to subderivation)
- Modal/temporal K rules and temporal duality do not apply with non-empty contexts

## References

* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
* [Combinators.lean](../Theorems/Combinators.lean) - Combinator infrastructure
-/

namespace Logos.Core.Metalogic

open Logos.Core.Syntax
open Logos.Core.ProofSystem

open Logos.Core.Theorems.Combinators

/-! ## Helper Lemmas -/

/--
Helper: Apply implication introduction pattern.
If `⊢ φ` then `⊢ A → φ` for any A.

This uses the S axiom (weakening): `φ → (A → φ)`.
-/
private def weaken_under_imp {φ A : Formula} (h : ⊢ φ) : ⊢ A.imp φ := by
  have s_ax : ⊢ φ.imp (A.imp φ) := DerivationTree.axiom [] _ (Axiom.prop_s φ A)
  exact DerivationTree.modus_ponens [] φ (A.imp φ) s_ax h

/--
Helper: Lift weakening to contexts.
If `Γ ⊢ φ` then `Γ ⊢ A → φ` for formulas φ that are axioms.
-/
private def weaken_under_imp_ctx {Γ : Context} {φ A : Formula}
    (h : Axiom φ) : Γ ⊢ A.imp φ := by
  have ax_deriv : ⊢ φ := DerivationTree.axiom [] φ h
  have weakened : ⊢ A.imp φ := weaken_under_imp ax_deriv
  exact DerivationTree.weakening [] Γ (A.imp φ) weakened (List.nil_subset Γ)

/--
Exchange lemma: Derivability is preserved under context permutation.

If `Γ ⊢ φ` and `Γ'` is a permutation of `Γ` (same elements, different order),
then `Γ' ⊢ φ`.

This is proven by showing that both `Γ ⊆ Γ'` and `Γ' ⊆ Γ` when they have
the same elements, then using weakening.
-/
private def exchange {Γ Γ' : Context} {φ : Formula}
    (h : Γ ⊢ φ)
    (h_perm : ∀ x, x ∈ Γ ↔ x ∈ Γ') :
    Γ' ⊢ φ := by
  apply DerivationTree.weakening Γ Γ' φ h
  intro x hx
  exact (h_perm x).mp hx

/--
Helper: Remove an element from a list.

Returns the list with all occurrences of `a` removed.
-/
private def removeAll {α : Type _} [DecidableEq α] (l : List α) (a : α) : List α :=
  l.filter (· ≠ a)

/--
Helper: If `A ∈ Γ'` and `Γ' ⊆ A :: Γ`, then `removeAll Γ' A ⊆ Γ`.

This shows that removing A from Γ' gives a subset of Γ.
-/
private theorem removeAll_subset {A : Formula} {Γ Γ' : Context}
    (_h_mem : A ∈ Γ')
    (h_sub : Γ' ⊆ A :: Γ) :
    removeAll Γ' A ⊆ Γ := by
  intro x hx
  unfold removeAll at hx
  simp [List.filter] at hx
  have ⟨h_in, h_ne⟩ := hx
  have := h_sub h_in
  simp at this
  cases this with
  | inl h_eq =>
    -- x = A, but x ≠ A from h_ne
    exact absurd h_eq h_ne
  | inr h_mem => exact h_mem

/--
Helper: If `A ∈ Γ'`, then `A :: removeAll Γ' A` has the same elements as `Γ'`.

This shows that we can move A to the front of the list.
-/
private theorem cons_removeAll_perm {A : Formula} {Γ' : Context}
    (h_mem : A ∈ Γ') :
    ∀ x, x ∈ A :: removeAll Γ' A ↔ x ∈ Γ' := by
  intro x
  constructor
  · intro h
    simp at h
    cases h with
    | inl h_eq =>
      subst h_eq
      exact h_mem
    | inr h_in =>
      unfold removeAll at h_in
      simp [List.filter] at h_in
      exact h_in.1
  · intro h
    by_cases hx : x = A
    · subst hx
      simp
    · simp
      right
      unfold removeAll
      simp [List.filter]
      exact ⟨h, hx⟩

/-! ## Deduction Theorem Cases -/

/--
Deduction case for axioms: If φ is an axiom, then `Γ ⊢ A → φ`.

**Strategy**: Use S axiom to weaken φ under implication A.
-/
def deduction_axiom (Γ : Context) (A φ : Formula) (h_ax : Axiom φ) :
    Γ ⊢ A.imp φ := by
  exact weaken_under_imp_ctx h_ax



/--
Deduction case for same assumption: `Γ ⊢ A → A`.

**Strategy**: Use identity theorem (already proven in Perpetuity.lean).
-/
def deduction_assumption_same (Γ : Context) (A : Formula) :
    Γ ⊢ A.imp A := by
  have id : ⊢ A.imp A := identity A
  exact DerivationTree.weakening [] Γ (A.imp A) id (List.nil_subset Γ)

/--
Deduction case for other assumptions: If `B ∈ Γ`, then `Γ ⊢ A → B`.

**Strategy**: Use S axiom to weaken assumption B under implication A.
-/
def deduction_assumption_other (Γ : Context) (A B : Formula)
    (h_mem : B ∈ Γ) : Γ ⊢ A.imp B := by
  have b_deriv : Γ ⊢ B := DerivationTree.assumption Γ B h_mem
  have s_ax : ⊢ B.imp (A.imp B) := DerivationTree.axiom [] _ (Axiom.prop_s B A)
  have s_weak : Γ ⊢ B.imp (A.imp B) :=
    DerivationTree.weakening [] Γ (B.imp (A.imp B)) s_ax (List.nil_subset Γ)
  exact DerivationTree.modus_ponens Γ B (A.imp B) s_weak b_deriv

/--
Deduction case for modus ponens:
If `Γ ⊢ A → (C → D)` and `Γ ⊢ A → C` then `Γ ⊢ A → D`.

**Strategy**: Use K axiom distribution: `(A → C → D) → ((A → C) → (A → D))`.
-/
def deduction_mp (Γ : Context) (A C D : Formula)
    (h1 : Γ ⊢ A.imp (C.imp D))
    (h2 : Γ ⊢ A.imp C) :
    Γ ⊢ A.imp D := by
  -- K axiom: (A → C → D) → ((A → C) → (A → D))
  have k_ax : ⊢ (A.imp (C.imp D)).imp ((A.imp C).imp (A.imp D)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k A C D)
  have k_weak : Γ ⊢ (A.imp (C.imp D)).imp ((A.imp C).imp (A.imp D)) :=
    DerivationTree.weakening [] Γ _ k_ax (List.nil_subset Γ)
  -- Apply modus ponens twice
  have step1 : Γ ⊢ (A.imp C).imp (A.imp D) :=
    DerivationTree.modus_ponens Γ (A.imp (C.imp D)) ((A.imp C).imp (A.imp D)) k_weak h1
  exact DerivationTree.modus_ponens Γ (A.imp C) (A.imp D) step1 h2

/--
Deduction theorem for contexts where A appears in the middle.

If `Γ' ⊢ φ` and `A ∈ Γ'`, then `(removeAll Γ' A) ⊢ A → φ`.

This is the key lemma for handling the weakening case where A appears in Γ'
but not at the front. By recursing on the structure of the derivation (not using
exchange), all recursive calls have strictly smaller height.
-/
private def deduction_with_mem (Γ' : Context) (A φ : Formula)
    (h : Γ' ⊢ φ) (hA : A ∈ Γ') :
    (removeAll Γ' A) ⊢ A.imp φ := by
  match h with
  | DerivationTree.axiom _ ψ h_ax =>
      -- ψ is an axiom
      exact deduction_axiom (removeAll Γ' A) A ψ h_ax

  | DerivationTree.assumption _ ψ h_mem =>
      -- ψ ∈ Γ'
      -- Check if ψ = A or ψ ∈ removeAll Γ' A
      by_cases h_eq : ψ = A
      · -- ψ = A, need (removeAll Γ' A) ⊢ A → A
        rw [← h_eq]
        exact deduction_assumption_same (removeAll Γ' ψ) ψ
      · -- ψ ≠ A, so ψ ∈ removeAll Γ' A
        have h_mem' : ψ ∈ removeAll Γ' A := by
          unfold removeAll
          simp [List.filter]
          exact ⟨h_mem, h_eq⟩
        exact deduction_assumption_other (removeAll Γ' A) A ψ h_mem'

  | DerivationTree.modus_ponens _ ψ χ h1 h2 =>
      -- Recursive calls on subderivations
      have ih1 : (removeAll Γ' A) ⊢ A.imp (ψ.imp χ) :=
        deduction_with_mem Γ' A (ψ.imp χ) h1 hA
      have ih2 : (removeAll Γ' A) ⊢ A.imp ψ :=
        deduction_with_mem Γ' A ψ h2 hA
      exact deduction_mp (removeAll Γ' A) A ψ χ ih1 ih2

  | DerivationTree.necessitation ψ h_deriv =>
      -- Necessitation has type: DerivationTree [] (Formula.box ψ)
      -- So Γ' = [] and φ = Formula.box ψ
      -- But hA : A ∈ Γ' = A ∈ [], which is false
      -- In the match context, Lean knows Γ' = []
      simp at hA

  | DerivationTree.temporal_necessitation ψ h_deriv =>
      -- Temporal necessitation has type: DerivationTree [] (Formula.all_future ψ)
      -- So Γ' = [] and φ = Formula.all_future ψ
      -- But hA : A ∈ [] is false
      simp at hA

  | DerivationTree.temporal_duality ψ h_deriv =>
      -- Temporal duality has type: DerivationTree [] (Formula.swap_past_future ψ)
      -- So Γ' = [] and φ = Formula.swap_past_future ψ
      -- But hA : A ∈ [] is false
      simp at hA

  | DerivationTree.weakening Γ'' _ ψ h1 h2 =>
      -- Γ'' ⊢ ψ with Γ'' ⊆ Γ'
      -- Check if A ∈ Γ''
      by_cases hA' : A ∈ Γ''
      · -- A ∈ Γ'', recurse on h1
        have ih : (removeAll Γ'' A) ⊢ A.imp ψ :=
          deduction_with_mem Γ'' A ψ h1 hA'
        -- Weaken to removeAll Γ' A
        have h_sub : removeAll Γ'' A ⊆ removeAll Γ' A := by
          intro x hx
          unfold removeAll at hx ⊢
          simp [List.filter] at hx ⊢
          exact ⟨h2 hx.1, hx.2⟩
        exact DerivationTree.weakening (removeAll Γ'' A) (removeAll Γ' A) (A.imp ψ) ih h_sub
      · -- A ∉ Γ'', so Γ'' ⊆ removeAll Γ' A
        have h_sub : Γ'' ⊆ removeAll Γ' A := by
          intro x hx
          unfold removeAll
          simp [List.filter]
          exact ⟨h2 hx, by
            intro h_eq
            subst h_eq
            exact absurd hx hA'⟩
        -- Γ'' ⊢ ψ and Γ'' ⊆ removeAll Γ' A
        have h_weak : (removeAll Γ' A) ⊢ ψ :=
          DerivationTree.weakening Γ'' (removeAll Γ' A) ψ h1 h_sub
        -- Use S axiom
        have s_ax : ⊢ ψ.imp (A.imp ψ) :=
          DerivationTree.axiom [] _ (Axiom.prop_s ψ A)
        have s_weak : (removeAll Γ' A) ⊢ ψ.imp (A.imp ψ) :=
          DerivationTree.weakening [] (removeAll Γ' A) _ s_ax (List.nil_subset _)
        exact DerivationTree.modus_ponens (removeAll Γ' A) ψ (A.imp ψ) s_weak h_weak

termination_by h.height
decreasing_by
  -- Prove termination for each recursive call
  -- The recursive calls are:
  -- 1. modus_ponens case: deduction_with_mem Γ' A (ψ.imp χ) h1 hA
  -- 2. modus_ponens case: deduction_with_mem Γ' A ψ h2 hA
  -- 3. weakening case (A ∈ Γ''): deduction_with_mem Γ'' A ψ h1 hA'
  simp_wf
  · -- Goal 1: h1.height < h.height (modus_ponens left)
    exact DerivationTree.mp_height_gt_left h1 h2
  · -- Goal 2: h2.height < h.height (modus_ponens right)
    exact DerivationTree.mp_height_gt_right h1 h2
  · -- Goal 3: h1.height < h.height (weakening with A ∈ Γ'')
    exact DerivationTree.subderiv_height_lt h1 h2

/-! ## Main Deduction Theorem -/

/--
The Deduction Theorem: If `A :: Γ ⊢ B` then `Γ ⊢ A → B`.

This fundamental metatheorem allows converting derivations with assumptions
into implicational theorems.

**Proof Strategy**: Well-founded recursion on derivation height.
- Axiom case: Use S axiom to weaken
- Assumption case: Identity if same, S axiom if different
- Modus ponens case: Use K axiom distribution with recursive calls
- Weakening case: Handle three subcases:
  1. `Γ' = A :: Γ`: Apply recursion directly
  2. `A ∉ Γ'`: Use S axiom (A not needed)
  3. `A ∈ Γ'` but `Γ' ≠ A :: Γ`: Use recursion on permuted context (KEY CASE)
- Modal/temporal necessitation: Cannot occur (require empty context)
- Temporal duality: Cannot occur (requires empty context)

**Well-Founded Recursion**: The recursion terminates because:
- In modus ponens: both subderivations have strictly smaller height
- In weakening: the subderivation has strictly smaller height
- All recursive calls are on derivations with smaller height

**Complexity**: Core metatheorem for Hilbert systems. Uses well-founded recursion
to handle the complex weakening case where A appears in the middle of the context.
-/
def deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  -- Pattern match on the derivation structure
  match h with
  | DerivationTree.axiom _ φ h_ax =>
      -- Case: φ is an axiom
      -- By deduction_axiom, Γ ⊢ A → φ
      exact deduction_axiom Γ A φ h_ax

  | DerivationTree.assumption _ φ h_mem =>
      -- Case: φ is in the context A :: Γ
      -- Need to check if φ = A (identity case) or φ ∈ Γ (other assumption)
      by_cases h_eq : φ = A
      · -- φ = A, so we need Γ ⊢ A → A (identity)
        subst h_eq
        exact deduction_assumption_same Γ φ
      · -- φ ≠ A, so φ must be in Γ
        have h_tail : φ ∈ Γ := by
          cases h_mem with
          | head => exact absurd rfl h_eq
          | tail _ h => exact h
        exact deduction_assumption_other Γ A φ h_tail

  | DerivationTree.modus_ponens _ φ ψ h1 h2 =>
      -- Case: ψ derived by modus ponens from φ → ψ and φ
      -- Recursive calls on subderivations (both have smaller height)
      have ih1 : Γ ⊢ A.imp (φ.imp ψ) := deduction_theorem Γ A (φ.imp ψ) h1
      have ih2 : Γ ⊢ A.imp φ := deduction_theorem Γ A φ h2
      -- Use deduction_mp to combine: Γ ⊢ A → ψ
      exact deduction_mp Γ A φ ψ ih1 ih2

  | DerivationTree.weakening Γ' _ φ h1 h2 =>
      -- Weakening case: (A :: Γ) ⊢ φ came from Γ' ⊢ φ with Γ' ⊆ A :: Γ
      -- h1 : Γ' ⊢ φ (subderivation with smaller height)
      -- h2 : Γ' ⊆ A :: Γ
      -- Goal: Γ ⊢ A.imp φ

      -- Subcase 1: Check if Γ' = A :: Γ (then we can recurse directly)
      by_cases h_eq : Γ' = A :: Γ
      · -- Γ' = A :: Γ, so h1 : (A :: Γ) ⊢ φ after cast
        exact deduction_theorem Γ A φ (h_eq ▸ h1)
      · -- Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
        -- Subcase 2: Check if A ∈ Γ'
        by_cases hA : A ∈ Γ'
        ·
          -- A ∈ Γ' but Γ' ≠ A :: Γ
          -- This is the KEY CASE that requires well-founded recursion
          --
          -- Strategy:
          -- 1. Weaken h1 from Γ' to A :: removeAll Γ' A
          -- 2. Apply deduction theorem recursively on the weakened derivation
          -- 3. Weaken the result to Γ
          --
          -- Key insight: We weaken h1 (which has height < h.height) to get
          -- a derivation with height h1.height + 1 = h.height. But we then
          -- recurse on this NEW derivation, which still has height = h.height.
          -- This doesn't work!
          --
          -- Better strategy:
          -- 1. Use the fact that Γ' has the same elements as A :: removeAll Γ' A
          -- 2. Weaken h1 : Γ' ⊢ φ to (A :: removeAll Γ' A) ⊢ φ
          -- 3. Apply deduction theorem to get (removeAll Γ' A) ⊢ A → φ
          -- 4. Weaken to Γ
          --
          -- The problem is step 2 creates a derivation with height h1.height + 1,
          -- and step 3 recurses on it. Since h.height = h1.height + 1, we're
          -- recursing on a derivation with the SAME height as h!
          --
          -- SOLUTION: Don't use exchange! Instead, prove a helper lemma that
          -- directly shows: if Γ' ⊢ φ and A ∈ Γ', then (removeAll Γ' A) ⊢ A → φ
          -- This helper will recurse on h1, which has strictly smaller height.
          
          have ih : removeAll Γ' A ⊢ A.imp φ :=
            deduction_with_mem Γ' A φ h1 hA

          -- Weaken to Γ
          have h_sub : removeAll Γ' A ⊆ Γ :=
            removeAll_subset hA h2
          exact DerivationTree.weakening (removeAll Γ' A) Γ (A.imp φ) ih h_sub

        · -- A ∉ Γ', so φ is derivable from Γ' without using A
          -- h2 : Γ' ⊆ A :: Γ and A ∉ Γ' implies Γ' ⊆ Γ
          have h_sub : Γ' ⊆ Γ := by
            intro x hx
            have := h2 hx
            simp at this
            cases this with
            | inl h_eq =>
              -- x = A, but A ∉ Γ', contradiction
              subst h_eq
              exact absurd hx hA
            | inr h_mem => exact h_mem

          -- Now Γ' ⊢ φ and Γ' ⊆ Γ, so Γ ⊢ φ
          have h_weak : Γ ⊢ φ := DerivationTree.weakening Γ' Γ φ h1 h_sub

          -- Use S axiom to get Γ ⊢ A → φ
          have s_ax : ⊢ φ.imp (A.imp φ) :=
            DerivationTree.axiom [] _ (Axiom.prop_s φ A)
          have s_weak : Γ ⊢ φ.imp (A.imp φ) :=
            DerivationTree.weakening [] Γ _ s_ax (List.nil_subset Γ)
          exact DerivationTree.modus_ponens Γ φ (A.imp φ) s_weak h_weak

termination_by h.height
decreasing_by
  -- Prove that all recursive calls are on derivations with smaller height
  simp_wf
  -- Modus ponens cases: both subderivations have strictly smaller height
  · exact DerivationTree.mp_height_gt_left _ _
  · exact DerivationTree.mp_height_gt_right _ _
  -- Weakening case (Γ' = A :: Γ): subderivation has strictly smaller height
  · -- The cast h_eq ▸ h1 has the same height as h1
    -- The original h was (DerivationTree.weakening Γ' (A :: Γ) φ h1 h2)
    -- which has height 1 + h1.height
    -- So we need to prove (h_eq ▸ h1).height < 1 + h1.height
    -- This is h1.height < 1 + h1.height, which is trivially true
    have : (h_eq ▸ h1).height = h1.height := by
      subst h_eq
      rfl
    simp [this, DerivationTree.height]

end Logos.Core.Metalogic
