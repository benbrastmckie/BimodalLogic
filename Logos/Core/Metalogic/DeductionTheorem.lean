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

/-! ## Derivation Height Measure -/

/--
Height of a derivation tree.

The height is defined as the maximum depth of the derivation tree:
- Base cases (axiom, assumption): height 0
- Unary rules (necessitation, temporal_necessitation, temporal_duality, weakening):
  height of subderivation + 1
- Binary rules (modus_ponens): max of both subderivations + 1

This measure is used for well-founded recursion in the deduction theorem proof.
-/
def Derivable.height : {Γ : Context} → {φ : Formula} → Derivable Γ φ → ℕ
  | _, _, axiom _ => 0
  | _, _, assumption _ => 0
  | _, _, modus_ponens d1 d2 => max d1.height d2.height + 1
  | _, _, necessitation d => d.height + 1
  | _, _, temporal_necessitation d => d.height + 1
  | _, _, temporal_duality d => d.height + 1
  | _, _, weakening d _ => d.height + 1

/-! ## Height Properties -/

/--
Weakening increases height by exactly 1.

This is a definitional equality, but we state it as a theorem for clarity.
-/
theorem Derivable.weakening_height_succ {Γ' Δ : Context} {φ : Formula}
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    (Derivable.weakening Γ' Δ φ d h).height = d.height + 1 := by
  rfl

/--
Subderivations in weakening have strictly smaller height.

This is the key lemma for proving termination of well-founded recursion
in the deduction theorem.
-/
theorem Derivable.subderiv_height_lt {Γ' Δ : Context} {φ : Formula}
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    d.height < (Derivable.weakening Γ' Δ φ d h).height := by
  rw [weakening_height_succ]
  omega

/--
Modus ponens height is strictly greater than both subderivations.
-/
theorem Derivable.mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : Derivable Γ (φ.imp ψ)) (d2 : Derivable Γ φ) :
    d1.height < (Derivable.modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

theorem Derivable.mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : Derivable Γ (φ.imp ψ)) (d2 : Derivable Γ φ) :
    d2.height < (Derivable.modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/-! ## Helper Lemmas -/

/--
Helper: Apply implication introduction pattern.
If `⊢ φ` then `⊢ A → φ` for any A.

This uses the S axiom (weakening): `φ → (A → φ)`.
-/
private theorem weaken_under_imp {φ A : Formula} (h : ⊢ φ) : ⊢ A.imp φ := by
  have s_ax : ⊢ φ.imp (A.imp φ) := Derivable.axiom [] _ (Axiom.prop_s φ A)
  exact Derivable.modus_ponens [] φ (A.imp φ) s_ax h

/--
Helper: Lift weakening to contexts.
If `Γ ⊢ φ` then `Γ ⊢ A → φ` for formulas φ that are axioms.
-/
private theorem weaken_under_imp_ctx {Γ : Context} {φ A : Formula}
    (h : Axiom φ) : Γ ⊢ A.imp φ := by
  have ax_deriv : ⊢ φ := Derivable.axiom [] φ h
  have weakened : ⊢ A.imp φ := weaken_under_imp ax_deriv
  exact Derivable.weakening [] Γ (A.imp φ) weakened (List.nil_subset Γ)

/--
Exchange lemma: Derivability is preserved under context permutation.

If `Γ ⊢ φ` and `Γ'` is a permutation of `Γ` (same elements, different order),
then `Γ' ⊢ φ`.

This is proven by showing that both `Γ ⊆ Γ'` and `Γ' ⊆ Γ` when they have
the same elements, then using weakening.
-/
private theorem exchange {Γ Γ' : Context} {φ : Formula}
    (h : Γ ⊢ φ)
    (h_perm : ∀ x, x ∈ Γ ↔ x ∈ Γ') :
    Γ' ⊢ φ := by
  apply Derivable.weakening Γ Γ' φ h
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
theorem deduction_axiom (Γ : Context) (A φ : Formula) (h_ax : Axiom φ) :
    Γ ⊢ A.imp φ := by
  exact weaken_under_imp_ctx h_ax

/--
Deduction case for same assumption: `Γ ⊢ A → A`.

**Strategy**: Use identity theorem (already proven in Perpetuity.lean).
-/
theorem deduction_assumption_same (Γ : Context) (A : Formula) :
    Γ ⊢ A.imp A := by
  have id : ⊢ A.imp A := identity A
  exact Derivable.weakening [] Γ (A.imp A) id (List.nil_subset Γ)

/--
Deduction case for other assumptions: If `B ∈ Γ`, then `Γ ⊢ A → B`.

**Strategy**: Use S axiom to weaken assumption B under implication A.
-/
theorem deduction_assumption_other (Γ : Context) (A B : Formula)
    (h_mem : B ∈ Γ) : Γ ⊢ A.imp B := by
  have b_deriv : Γ ⊢ B := Derivable.assumption Γ B h_mem
  have s_ax : ⊢ B.imp (A.imp B) := Derivable.axiom [] _ (Axiom.prop_s B A)
  have s_weak : Γ ⊢ B.imp (A.imp B) :=
    Derivable.weakening [] Γ (B.imp (A.imp B)) s_ax (List.nil_subset Γ)
  exact Derivable.modus_ponens Γ B (A.imp B) s_weak b_deriv

/--
Deduction case for modus ponens:
If `Γ ⊢ A → (C → D)` and `Γ ⊢ A → C` then `Γ ⊢ A → D`.

**Strategy**: Use K axiom distribution: `(A → C → D) → ((A → C) → (A → D))`.
-/
theorem deduction_mp (Γ : Context) (A C D : Formula)
    (h1 : Γ ⊢ A.imp (C.imp D))
    (h2 : Γ ⊢ A.imp C) :
    Γ ⊢ A.imp D := by
  -- K axiom: (A → C → D) → ((A → C) → (A → D))
  have k_ax : ⊢ (A.imp (C.imp D)).imp ((A.imp C).imp (A.imp D)) :=
    Derivable.axiom [] _ (Axiom.prop_k A C D)
  have k_weak : Γ ⊢ (A.imp (C.imp D)).imp ((A.imp C).imp (A.imp D)) :=
    Derivable.weakening [] Γ _ k_ax (List.nil_subset Γ)
  -- Apply modus ponens twice
  have step1 : Γ ⊢ (A.imp C).imp (A.imp D) :=
    Derivable.modus_ponens Γ (A.imp (C.imp D)) ((A.imp C).imp (A.imp D)) k_weak h1
  exact Derivable.modus_ponens Γ (A.imp C) (A.imp D) step1 h2

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
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  -- Pattern match on the derivation structure
  match h with
  | Derivable.axiom _ φ h_ax =>
      -- Case: φ is an axiom
      -- By deduction_axiom, Γ ⊢ A → φ
      exact deduction_axiom Γ A φ h_ax

  | Derivable.assumption _ φ h_mem =>
      -- Case: φ is in the context A :: Γ
      -- Need to check if φ = A (identity case) or φ ∈ Γ (other assumption)
      cases h_mem with
      | head =>
          -- φ = A, so we need Γ ⊢ A → A (identity)
          exact deduction_assumption_same Γ A
      | tail _ h_tail =>
          -- φ ∈ Γ, so we need Γ ⊢ A → φ (weakening)
          exact deduction_assumption_other Γ A φ h_tail

  | Derivable.modus_ponens _ φ ψ h1 h2 =>
      -- Case: ψ derived by modus ponens from φ → ψ and φ
      -- Recursive calls on subderivations (both have smaller height)
      have ih1 : Γ ⊢ A.imp (φ.imp ψ) := deduction_theorem Γ A (φ.imp ψ) h1
      have ih2 : Γ ⊢ A.imp φ := deduction_theorem Γ A φ h2
      -- Use deduction_mp to combine: Γ ⊢ A → ψ
      exact deduction_mp Γ A φ ψ ih1 ih2

  | Derivable.necessitation φ h_deriv =>
      -- Case: Derivation uses necessitation rule
      -- necessitation requires empty context: [] ⊢ φ implies [] ⊢ □φ
      -- But we have A :: Γ ⊢ B, so this case is impossible
      -- The match will fail here, which is correct
      nomatch h_deriv  -- h_deriv : Derivable [] φ, but we need Derivable (A :: Γ) _

  | Derivable.temporal_necessitation φ h_deriv =>
      -- Case: Derivation uses temporal_necessitation rule
      -- temporal_necessitation requires empty context: [] ⊢ φ implies [] ⊢ Fφ
      -- But we have A :: Γ ⊢ B, so this case is impossible
      nomatch h_deriv

  | Derivable.temporal_duality φ h_deriv =>
      -- Case: Temporal duality only applies to empty context
      -- But we have A :: Γ ⊢ B, so this case is impossible
      nomatch h_deriv

  | Derivable.weakening Γ' _ φ h1 h2 =>
      -- Weakening case: (A :: Γ) ⊢ φ came from Γ' ⊢ φ with Γ' ⊆ A :: Γ
      -- h1 : Γ' ⊢ φ (subderivation with smaller height)
      -- h2 : Γ' ⊆ A :: Γ
      -- Goal: Γ ⊢ A.imp φ

      -- Subcase 1: Check if Γ' = A :: Γ (then we can recurse directly)
      by_cases h_eq : Γ' = A :: Γ
      · -- Γ' = A :: Γ, so h1 : (A :: Γ) ⊢ φ
        subst h_eq
        exact deduction_theorem Γ A φ h1

      · -- Γ' ≠ A :: Γ, so Γ' is a proper subset of A :: Γ
        -- Subcase 2: Check if A ∈ Γ'
        by_cases hA : A ∈ Γ'
        · -- A ∈ Γ' but Γ' ≠ A :: Γ
          -- This is the KEY CASE that requires well-founded recursion
          --
          -- Strategy:
          -- 1. Use exchange to move A to the front: A :: removeAll Γ' A ⊢ φ
          -- 2. Apply deduction theorem recursively (smaller height!)
          -- 3. Weaken the result to Γ

          -- Step 1: Permute context to move A to front
          have h_perm : ∀ x, x ∈ A :: removeAll Γ' A ↔ x ∈ Γ' :=
            cons_removeAll_perm hA
          have h_exch : (A :: removeAll Γ' A) ⊢ φ :=
            exchange h1 h_perm

          -- Step 2: Apply deduction theorem recursively
          -- This terminates because h1.height < (weakening ...).height
          have ih : removeAll Γ' A ⊢ A.imp φ :=
            deduction_theorem (removeAll Γ' A) A φ h_exch

          -- Step 3: Weaken to Γ
          have h_sub : removeAll Γ' A ⊆ Γ :=
            removeAll_subset hA h2
          exact Derivable.weakening (removeAll Γ' A) Γ (A.imp φ) ih h_sub

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
          have h_weak : Γ ⊢ φ := Derivable.weakening Γ' Γ φ h1 h_sub

          -- Use S axiom to get Γ ⊢ A → φ
          have s_ax : ⊢ φ.imp (A.imp φ) :=
            Derivable.axiom [] _ (Axiom.prop_s φ A)
          have s_weak : Γ ⊢ φ.imp (A.imp φ) :=
            Derivable.weakening [] Γ _ s_ax (List.nil_subset Γ)
          exact Derivable.modus_ponens Γ φ (A.imp φ) s_weak h_weak

termination_by h.height
decreasing_by
  -- Prove that all recursive calls are on derivations with smaller height
  all_goals simp_wf
  -- For modus ponens cases
  · exact Derivable.mp_height_gt_left h1 h2
  · exact Derivable.mp_height_gt_right h1 h2
  -- For weakening case with Γ' = A :: Γ
  · exact Derivable.subderiv_height_lt h1 h2
  -- For weakening case with A ∈ Γ' but Γ' ≠ A :: Γ
  · exact Derivable.subderiv_height_lt h1 h2

end Logos.Core.Metalogic
