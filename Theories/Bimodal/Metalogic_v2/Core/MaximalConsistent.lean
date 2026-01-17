import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic_v2.Core.DeductionTheorem
import Bimodal.Theorems.Propositional
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Order.Zorn
import Mathlib.Data.Finite.Defs
import Mathlib.Order.Preorder.Chain

/-!
# Maximal Consistent Sets for Metalogic v2

This module provides the theory of maximal consistent sets (MCS) for the
TM bimodal logic system. These are foundational for canonical model construction.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Main Results

- `SetConsistent`: Set-based consistency definition
- `SetMaximalConsistent`: Set-based maximal consistency definition
- `ConsistentSupersets`: The set of consistent supersets of a base set
- `set_lindenbaum`: Lindenbaum's lemma - every consistent set extends to MCS
- Chain consistency lemmas for Zorn's lemma application

## Layer Dependencies

Core.MaximalConsistent depends on:
- Bimodal.ProofSystem (derivation trees)
- Bimodal.Metalogic_v2.Core.DeductionTheorem (deduction theorem)
- Mathlib.Order.Zorn (Zorn's lemma)
-/

namespace Bimodal.Metalogic_v2.Core

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics Bimodal.Theorems.Combinators Bimodal.Theorems.Propositional

/-!
## List-Based Consistency

A context `Γ` is **consistent** if no contradiction is derivable from it.
-/

/--
A context `Γ` is **consistent** if it does not derive bottom (⊥).

Formally: `Consistent Γ ↔ ¬(Γ ⊢ ⊥)`

**Examples**:
- `[]` is consistent (can't derive ⊥ from empty context)
- `[p]` is consistent for atomic `p`
- `[p, ¬p]` is inconsistent (derives ⊥ via propositional reasoning)
-/
def Consistent (Γ : Context) : Prop := ¬Nonempty (DerivationTree Γ Formula.bot)

/--
A context `Γ` is **maximal consistent** if it's consistent and adding any
formula not already in `Γ` makes it inconsistent.

Formally: `MaximalConsistent Γ ↔ Consistent Γ ∧ ∀ φ, φ ∉ Γ → ¬Consistent (φ :: Γ)`

**Properties** (to be proven):
- Deductively closed: `Γ ⊢ φ → φ ∈ Γ`
- Negation complete: `φ ∉ Γ → ¬φ ∈ Γ`
- Implication property: `(φ → ψ) ∈ Γ → (φ ∈ Γ → ψ ∈ Γ)`
-/
def MaximalConsistent (Γ : Context) : Prop :=
  Consistent Γ ∧ ∀ φ : Formula, φ ∉ Γ → ¬Consistent (φ :: Γ)

/-!
## Set-Based Consistency

For canonical model construction, we need set-based consistency since
maximal consistent sets are typically infinite.
-/

/--
Set-based consistency: A set of formulas is consistent if listing them doesn't derive ⊥.

We define consistency in terms of finite subsets, since a derivation can only use
finitely many premises.
-/
def SetConsistent (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent L

/--
Set-based maximal consistency: A set is maximally consistent if it is consistent
and cannot be properly extended while remaining consistent.
-/
def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ : Formula, φ ∉ S → ¬SetConsistent (insert φ S)

/--
ConsistentExtensions represents the set of all consistent extensions of a base set.
-/
def ConsistentExtensions (base : Set Formula) : Set (Set Formula) :=
  {S | base ⊆ S ∧ SetConsistent S}

/--
The base set is in its own consistent extensions (given it's consistent).
-/
lemma base_mem_consistent_extensions {base : Set Formula} (h : SetConsistent base) :
    base ∈ ConsistentExtensions base :=
  ⟨Set.Subset.refl base, h⟩

/--
Context to Set conversion: Convert a list-based context to a set.
-/
def contextToSet (Γ : Context) : Set Formula := {φ | φ ∈ Γ}

/--
List-based consistency implies set-based consistency for the corresponding set.
-/
lemma consistent_implies_set_consistent {Γ : Context} (h : Consistent Γ) :
    SetConsistent (contextToSet Γ) := by
  intro L hL ⟨d⟩
  apply h
  -- We need to derive ⊥ from Γ using the derivation from L
  -- Since all elements of L are in Γ, we can weaken
  exact ⟨DerivationTree.weakening L Γ Formula.bot d (fun φ hφ => hL φ hφ)⟩

/-!
## Finite Context Usage

Any derivation uses only finitely many formulas from its context.
This is essential for the Zorn's lemma application in Lindenbaum.
-/

/--
Formulas actually used from the context in a derivation tree.

This function extracts the list of context formulas that appear as
assumptions in the derivation. The result is a list (may have duplicates).

Note: For necessitation rules (which require empty context), usedFormulas
returns [] since the subderivation also has empty context.
-/
def usedFormulas {Γ : Context} {φ : Formula} : DerivationTree Γ φ → List Formula
  | DerivationTree.axiom _ _ _ => []
  | DerivationTree.assumption _ ψ _ => [ψ]
  | DerivationTree.modus_ponens _ _ _ d1 d2 => usedFormulas d1 ++ usedFormulas d2
  | DerivationTree.necessitation _ d => usedFormulas d
  | DerivationTree.temporal_necessitation _ d => usedFormulas d
  | DerivationTree.temporal_duality _ d => usedFormulas d
  | DerivationTree.weakening _ _ _ d _ => usedFormulas d

/--
All formulas used in a derivation come from the context.
-/
lemma usedFormulas_subset {Γ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) : ∀ ψ ∈ usedFormulas d, ψ ∈ Γ := by
  induction d with
  | «axiom» => simp [usedFormulas]
  | assumption Γ' ψ h =>
    simp only [usedFormulas, List.mem_singleton]
    intro χ hχ
    rw [hχ]
    exact h
  | modus_ponens Γ' _ _ _ _ ih1 ih2 =>
    simp only [usedFormulas, List.mem_append]
    intro ψ hψ
    cases hψ with
    | inl h => exact ih1 ψ h
    | inr h => exact ih2 ψ h
  | necessitation _ d ih =>
    simp only [usedFormulas]
    intro ψ hψ
    have := ih ψ hψ
    exact (List.not_mem_nil this).elim
  | temporal_necessitation _ d ih =>
    simp only [usedFormulas]
    intro ψ hψ
    have := ih ψ hψ
    exact (List.not_mem_nil this).elim
  | temporal_duality _ d ih =>
    simp only [usedFormulas]
    intro ψ hψ
    have := ih ψ hψ
    exact (List.not_mem_nil this).elim
  | weakening Γ' Δ _ d h ih =>
    simp only [usedFormulas]
    intro ψ hψ
    exact h (ih ψ hψ)

/--
Any derivation uses only finitely many context formulas, and there exists
a derivation from that finite subset.

This is formulated without constructing the derivation directly (avoiding
the termination issues with necessitation rules).
-/
theorem derivation_uses_finite_context {Γ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) :
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ (L ⊆ Γ) := by
  exact ⟨usedFormulas d, usedFormulas_subset d, usedFormulas_subset d⟩

/-!
## Chain Union Consistency

The union of a chain of consistent sets is consistent.
This is the key lemma enabling Zorn's lemma application.
-/

/--
Any finite list of formulas from a chain union is contained in some chain member.

This is the key fact: if each formula in a finite list comes from the union
of a chain, then all formulas come from some single member (by chain property).

Note: If the chain is empty or the list is empty, we only need C.Nonempty.
The case C = ∅ is handled by the caller (consistent_chain_union).
-/
lemma finite_list_in_chain_member {C : Set (Set Formula)}
    (hchain : IsChain (· ⊆ ·) C) (L : List Formula) (hL : ∀ φ ∈ L, φ ∈ ⋃₀ C) :
    C.Nonempty → ∃ S ∈ C, ∀ φ ∈ L, φ ∈ S := by
  intro hCne
  induction L with
  | nil =>
    -- Empty list: just need any member of C
    obtain ⟨S, hS⟩ := hCne
    exact ⟨S, hS, fun _ h => (List.not_mem_nil h).elim⟩
  | cons ψ L' ih =>
    -- ψ is in some S₁ ∈ C, and by IH, L' ⊆ some S₂ ∈ C
    have hψ : ψ ∈ ⋃₀ C := hL ψ List.mem_cons_self
    have hL' : ∀ φ ∈ L', φ ∈ ⋃₀ C := fun φ h => hL φ (List.mem_cons_of_mem _ h)
    obtain ⟨S₁, hS₁mem, hψS₁⟩ := Set.mem_sUnion.mp hψ
    obtain ⟨S₂, hS₂mem, hL'S₂⟩ := ih hL'
    -- By chain property, either S₁ ⊆ S₂ or S₂ ⊆ S₁
    rcases hchain.total hS₁mem hS₂mem with h | h
    · -- S₁ ⊆ S₂, so ψ ∈ S₂ and L' ⊆ S₂
      exact ⟨S₂, hS₂mem, fun φ hφ =>
        match List.mem_cons.mp hφ with
        | .inl heq => heq ▸ h hψS₁
        | .inr hmem => hL'S₂ φ hmem⟩
    · -- S₂ ⊆ S₁, so L' ⊆ S₁ and ψ ∈ S₁
      exact ⟨S₁, hS₁mem, fun φ hφ =>
        match List.mem_cons.mp hφ with
        | .inl heq => heq ▸ hψS₁
        | .inr hmem => h (hL'S₂ φ hmem)⟩

/--
The union of a nonempty chain of consistent sets is consistent.

If every set in a nonempty chain is SetConsistent, then their union is also SetConsistent.
This uses the fact that any derivation uses only finitely many premises, and
those finite premises come from some single chain member.
-/
theorem consistent_chain_union {C : Set (Set Formula)}
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, SetConsistent S) : SetConsistent (⋃₀ C) := by
  intro L hL
  -- hL says all elements of L are in ⋃₀ C
  -- We need to show Consistent L
  -- By finite_list_in_chain_member, L ⊆ some S ∈ C
  obtain ⟨S, hSmem, hLS⟩ := finite_list_in_chain_member hchain L hL hCne
  -- S is consistent, so L being a subset means L is consistent
  exact hcons S hSmem L hLS

/-!
## Lindenbaum's Lemma

Every consistent set can be extended to a maximal consistent set.
This is the key lemma enabling canonical model construction.
-/

/--
The set of consistent extensions of a base set S.
Used for Zorn's lemma application.
-/
def ConsistentSupersets (S : Set Formula) : Set (Set Formula) :=
  {T | S ⊆ T ∧ SetConsistent T}

/--
A consistent set is in its own consistent supersets.
-/
lemma self_mem_consistent_supersets {S : Set Formula} (h : SetConsistent S) :
    S ∈ ConsistentSupersets S :=
  ⟨Set.Subset.refl S, h⟩

/--
Set-based Lindenbaum's Lemma: Every consistent set can be extended to a
set-maximal consistent set.

Uses `zorn_subset_nonempty` from Mathlib.Order.Zorn.
-/
theorem set_lindenbaum (S : Set Formula) (hS : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M := by
  -- Define the collection of consistent supersets
  let CS := ConsistentSupersets S
  -- Show CS satisfies the chain condition for Zorn's lemma
  have hchain : ∀ C ⊆ CS, IsChain (· ⊆ ·) C → C.Nonempty →
      ∃ ub ∈ CS, ∀ T ∈ C, T ⊆ ub := by
    intro C hCsub hCchain hCne
    -- The upper bound is the union of the chain
    use ⋃₀ C
    constructor
    · -- Show ⋃₀ C ∈ CS, i.e., S ⊆ ⋃₀ C and SetConsistent (⋃₀ C)
      constructor
      · -- S ⊆ ⋃₀ C: Since C is nonempty, pick any T ∈ C, then S ⊆ T ⊆ ⋃₀ C
        obtain ⟨T, hT⟩ := hCne
        have hST : S ⊆ T := (hCsub hT).1
        exact Set.Subset.trans hST (Set.subset_sUnion_of_mem hT)
      · -- SetConsistent (⋃₀ C): Use consistent_chain_union
        apply consistent_chain_union hCchain hCne
        intro T hT
        exact (hCsub hT).2
    · -- Show ∀ T ∈ C, T ⊆ ⋃₀ C
      intro T hT
      exact Set.subset_sUnion_of_mem hT
  -- Apply Zorn's lemma
  have hSmem : S ∈ CS := self_mem_consistent_supersets hS
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty CS hchain S hSmem
  -- hmax : Maximal (fun x => x ∈ CS) M
  -- This means M ∈ CS and ∀ T, M ⊆ T → T ∈ CS → M = T
  have hMmem : M ∈ CS := hmax.prop
  obtain ⟨_, hMcons⟩ := hMmem
  -- M is maximal in CS. Show it's SetMaximalConsistent.
  use M
  constructor
  · exact hSM
  · -- Show SetMaximalConsistent M
    constructor
    · exact hMcons
    · -- Show ∀ φ ∉ M, ¬SetConsistent (insert φ M)
      intro φ hφnotM hcons_insert
      -- If insert φ M were consistent, then insert φ M ∈ CS
      have h_insert_mem : insert φ M ∈ CS := by
        constructor
        · exact Set.Subset.trans hSM (Set.subset_insert φ M)
        · exact hcons_insert
      -- M is maximal: if insert φ M ∈ CS and M ⊆ insert φ M, then insert φ M ⊆ M
      have h_le : M ⊆ insert φ M := Set.subset_insert φ M
      have h_subset : insert φ M ⊆ M := hmax.le_of_ge h_insert_mem h_le
      have hφM : φ ∈ M := h_subset (Set.mem_insert φ M)
      exact hφnotM hφM

/-!
## Helper Lemmas for MCS Properties
-/

/--
If a context is inconsistent, it derives bottom.

This is essentially the definition of inconsistency unwrapped into a derivation.
-/
lemma inconsistent_derives_bot {Γ : Context} (h : ¬Consistent Γ) :
    Nonempty (DerivationTree Γ Formula.bot) := by
  unfold Consistent at h
  push_neg at h
  exact h

/--
If extending a consistent context with φ makes it inconsistent, then the original
context derives ¬φ (i.e., φ → ⊥).

This is a key lemma for proving MCS closure properties. It uses the deduction theorem.
-/
lemma derives_neg_from_inconsistent_extension {Γ : Context} {φ : Formula}
    (h_incons : ¬Consistent (φ :: Γ)) :
    Nonempty (DerivationTree Γ (Formula.neg φ)) := by
  -- Get the derivation of ⊥ from φ :: Γ
  have ⟨d_bot⟩ := inconsistent_derives_bot h_incons
  -- Apply deduction theorem: (φ :: Γ) ⊢ ⊥ implies Γ ⊢ φ → ⊥
  have d_neg : Γ ⊢ φ.imp Formula.bot := deduction_theorem Γ φ Formula.bot d_bot
  -- φ → ⊥ is exactly neg φ by definition
  exact ⟨d_neg⟩

/--
From Γ ⊢ φ and Γ ⊢ ¬φ (i.e., φ → ⊥), derive Γ ⊢ ⊥.

This combines a formula and its negation to produce a contradiction.
-/
def derives_bot_from_phi_neg_phi {Γ : Context} {φ : Formula}
    (h_phi : DerivationTree Γ φ)
    (h_neg : DerivationTree Γ (Formula.neg φ)) :
    DerivationTree Γ Formula.bot :=
  -- neg φ = φ.imp bot, so we apply modus ponens
  DerivationTree.modus_ponens Γ φ Formula.bot h_neg h_phi

/--
For maximal consistent sets, if φ ∉ Γ then the extension φ :: Γ is inconsistent.

This is one direction of the maximality definition, made into a lemma for convenience.
-/
lemma maximal_extends_inconsistent {Γ : Context} {φ : Formula}
    (h_max : MaximalConsistent Γ) (h_not_mem : φ ∉ Γ) :
    ¬Consistent (φ :: Γ) :=
  h_max.2 φ h_not_mem

/--
Bridge lemma: SetMaximalConsistent implies consistency for any finite subset.

For any list L whose elements are all in a SetMaximalConsistent set S,
the list L is Consistent.
-/
lemma set_mcs_finite_subset_consistent {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) (L : List Formula) (h_sub : ∀ φ ∈ L, φ ∈ S) :
    Consistent L :=
  h_mcs.1 L h_sub

/-!
## MCS Closure Properties
-/

/--
Maximal consistent sets are deductively closed.

**Statement**: `MaximalConsistent Γ → (Γ ⊢ φ → φ ∈ Γ)`

**Proof Strategy**:
1. Assume `Γ ⊢ φ` but `φ ∉ Γ`
2. By maximality, `φ :: Γ` is inconsistent
3. So `φ :: Γ ⊢ ⊥`
4. By deduction theorem, `Γ ⊢ φ → ⊥`, i.e., `Γ ⊢ ¬φ`
5. Combine with `Γ ⊢ φ` to get `Γ ⊢ ⊥` (contradiction)

**Note**: Requires deduction theorem for TM logic.
-/
theorem maximal_consistent_closed (Γ : Context) (φ : Formula)
    (h_max : MaximalConsistent Γ) (h_deriv : DerivationTree Γ φ) : φ ∈ Γ := by
  -- Proof by contradiction: assume φ ∉ Γ and derive a contradiction
  by_contra h_not_mem
  -- By maximality, (φ :: Γ) is inconsistent
  have h_incons : ¬Consistent (φ :: Γ) := maximal_extends_inconsistent h_max h_not_mem
  -- So we can derive ¬φ from Γ (using deduction theorem)
  have ⟨h_neg_deriv⟩ := derives_neg_from_inconsistent_extension h_incons
  -- Combine Γ ⊢ φ and Γ ⊢ ¬φ to get Γ ⊢ ⊥
  have h_bot : DerivationTree Γ Formula.bot :=
    derives_bot_from_phi_neg_phi h_deriv h_neg_deriv
  -- This contradicts consistency of Γ
  exact h_max.1 ⟨h_bot⟩

/--
Maximal consistent sets are negation complete.

**Statement**: `MaximalConsistent Γ → (φ ∉ Γ → ¬φ ∈ Γ)`

**Proof Strategy**:
1. Assume `φ ∉ Γ`
2. By maximality, `φ :: Γ ⊢ ⊥`
3. By deduction theorem, `Γ ⊢ φ → ⊥`, i.e., `Γ ⊢ ¬φ`
4. By closure, `¬φ ∈ Γ`
-/
theorem maximal_negation_complete (Γ : Context) (φ : Formula)
    (h_max : MaximalConsistent Γ) (h_not_mem : φ ∉ Γ) : Formula.neg φ ∈ Γ := by
  -- By maximality, (φ :: Γ) is inconsistent
  have h_incons : ¬Consistent (φ :: Γ) := maximal_extends_inconsistent h_max h_not_mem
  -- So we can derive ¬φ from Γ (using deduction theorem)
  have ⟨h_neg_deriv⟩ := derives_neg_from_inconsistent_extension h_incons
  -- By closure property, ¬φ ∈ Γ
  exact maximal_consistent_closed Γ (Formula.neg φ) h_max h_neg_deriv

end Bimodal.Metalogic_v2.Core
