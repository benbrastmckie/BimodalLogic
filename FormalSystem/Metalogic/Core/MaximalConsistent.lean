/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem
import FormalSystem.Semantics
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Theorems.Propositional.Core
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Order.Zorn
import Mathlib.Data.Finite.Defs
import Mathlib.Order.Preorder.Chain

/-!
# Maximal Consistent Sets for TM Bimodal Logic

This module provides the theory of maximal consistent sets (MCS) for the
TM bimodal logic system. These are foundational for canonical model construction.

## Main Results

- `Consistent`: List-based consistency definition
- `MaximalConsistent`: List-based maximal consistency definition
- `SetConsistent`: Set-based consistency definition
- `SetMaximalConsistent`: Set-based maximal consistency definition
- `exists_maximal_of_chainClosed`: Generic Zorn argument for chain-closed predicates
- `set_lindenbaum`: Lindenbaum's lemma - every consistent set extends to MCS
- Chain consistency lemmas for Zorn's lemma application

## Layer Dependencies

Core.MaximalConsistent depends on:
- FormalSystem.ProofSystem (derivation trees)
- FormalSystem.Metalogic.Core.DeductionTheorem (deduction theorem)
- Mathlib.Order.Zorn (Zorn's lemma)

## History

Originally developed in Metalogic_v2, consolidated into active Core module
as part of the boneyard archive.
-/

namespace FormalSystem.Metalogic.Core

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics
    FormalSystem.Theorems.Combinators
  FormalSystem.Theorems.Propositional

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
def Consistent {fc : FrameClass} (Γ : Context) : Prop := ¬Derivable fc Γ Formula.bot

/--
A context `Γ` is **maximal consistent** if it's consistent and adding any
formula not already in `Γ` makes it inconsistent.

Formally: `MaximalConsistent Γ ↔ Consistent Γ ∧ ∀ φ, φ ∉ Γ → ¬Consistent (φ :: Γ)`

**Properties** (to be proven):
- Deductively closed: `Γ ⊢ φ → φ ∈ Γ`
- Negation complete: `φ ∉ Γ → ¬φ ∈ Γ`
- Implication property: `(φ → ψ) ∈ Γ → (φ ∈ Γ → ψ ∈ Γ)`
-/
def MaximalConsistent {fc : FrameClass} (Γ : Context) : Prop :=
  Consistent (fc := fc) Γ ∧ ∀ φ : Formula, φ ∉ Γ → ¬Consistent (fc := fc) (φ :: Γ)

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
def SetConsistent {fc : FrameClass} (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent (fc := fc) L

/--
Set-based maximal consistency: A set is maximally consistent if it is consistent
and cannot be properly extended while remaining consistent.
-/
def SetMaximalConsistent {fc : FrameClass} (S : Set Formula) : Prop :=
  SetConsistent (fc := fc) S ∧ ∀ φ : Formula, φ ∉ S → ¬SetConsistent (fc := fc) (insert φ S)

/--
ConsistentExtensions represents the set of all consistent extensions of a base set.
-/
def ConsistentExtensions {fc : FrameClass} (base : Set Formula) : Set (Set Formula) :=
  {S | base ⊆ S ∧ SetConsistent (fc := fc) S}

/--
The base set is in its own consistent extensions (given it's consistent).
-/
lemma base_mem_consistent_extensions {fc : FrameClass} {base : Set Formula}
    (h : SetConsistent (fc := fc) base) :
    base ∈ ConsistentExtensions (fc := fc) base :=
  ⟨Set.Subset.refl base, h⟩

/--
Context to Set conversion: Convert a list-based context to a set.
-/
def contextToSet (Γ : Context) : Set Formula := {φ | φ ∈ Γ}

/--
List-based consistency implies set-based consistency for the corresponding set.
-/
lemma consistent_implies_set_consistent {fc : FrameClass} {Γ : Context}
    (h : Consistent (fc := fc) Γ) :
    SetConsistent (fc := fc) (contextToSet Γ) := by
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
def usedFormulas {fc : FrameClass} {Γ : Context} {φ : Formula} : DerivationTree fc Γ φ →
    List Formula
  | DerivationTree.axiom _ _ _ _ => []
  | DerivationTree.assumption _ ψ _ => [ψ]
  | DerivationTree.modus_ponens _ _ _ d1 d2 => usedFormulas d1 ++ usedFormulas d2
  | DerivationTree.necessitation _ d => usedFormulas d
  | DerivationTree.temporal_necessitation _ d => usedFormulas d
  | DerivationTree.temporal_duality _ d => usedFormulas d
  | DerivationTree.weakening _ _ _ d _ => usedFormulas d

/--
All formulas used in a derivation come from the context.
-/
lemma usedFormulas_subset {fc : FrameClass} {Γ : Context} {φ : Formula}
    (d : DerivationTree fc Γ φ) : ∀ ψ ∈ usedFormulas d, ψ ∈ Γ := by
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
theorem derivation_uses_finite_context {fc : FrameClass} {Γ : Context} {φ : Formula}
    (d : DerivationTree fc Γ φ) :
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
theorem consistent_chain_union {fc : FrameClass} {C : Set (Set Formula)}
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, SetConsistent (fc := fc) S) : SetConsistent (fc := fc) (⋃₀ C) := by
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
Generic Zorn argument for a chain-closed predicate on sets of formulas.

If `P` is preserved by unions of nonempty chains, then every set satisfying `P`
extends to one that is maximal with respect to `P`: no formula can be added
without falsifying `P`.

Both Lindenbaum lemmas in this development (`set_lindenbaum` here, and
`restricted_lindenbaum` in `RestrictedMCS/Basic.lean`) are instantiations of
this lemma; the closure restriction of the restricted variant belongs in the
instantiation, not in the statement.
-/
theorem exists_maximal_of_chainClosed {P : Set Formula → Prop}
    (hchain : ∀ C : Set (Set Formula), (∀ T ∈ C, P T) → IsChain (· ⊆ ·) C → C.Nonempty →
      P (⋃₀ C))
    {S : Set Formula} (hS : P S) :
    ∃ M : Set Formula, S ⊆ M ∧ P M ∧ ∀ ψ : Formula, ψ ∉ M → ¬ P (insert ψ M) := by
  let CS : Set (Set Formula) := {T | S ⊆ T ∧ P T}
  have hch : ∀ C ⊆ CS, IsChain (· ⊆ ·) C → C.Nonempty → ∃ ub ∈ CS, ∀ T ∈ C, T ⊆ ub := by
    intro C hCsub hCchain hCne
    refine ⟨⋃₀ C, ⟨?_, ?_⟩, fun T hT => Set.subset_sUnion_of_mem hT⟩
    · obtain ⟨T, hT⟩ := hCne
      exact Set.Subset.trans (hCsub hT).1 (Set.subset_sUnion_of_mem hT)
    · exact hchain C (fun T hT => (hCsub hT).2) hCchain hCne
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty CS hch S ⟨Set.Subset.refl S, hS⟩
  refine ⟨M, hSM, hmax.prop.2, ?_⟩
  intro ψ hψ hP
  exact hψ (hmax.le_of_ge ⟨Set.Subset.trans hSM (Set.subset_insert ψ M), hP⟩
    (Set.subset_insert ψ M) (Set.mem_insert ψ M))

/--
Set-based Lindenbaum's Lemma: Every consistent set can be extended to a
set-maximal consistent set.

Uses `zorn_subset_nonempty` from Mathlib.Order.Zorn.
-/
theorem set_lindenbaum {fc : FrameClass} (S : Set Formula) (hS : SetConsistent (fc := fc) S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent (fc := fc) M := by
  obtain ⟨M, hSM, hM, hmax⟩ :=
    exists_maximal_of_chainClosed (P := SetConsistent (fc := fc))
      (fun _C hc hchain hne => consistent_chain_union hchain hne hc) hS
  exact ⟨M, hSM, hM, hmax⟩

/-!
## Helper Lemmas for MCS Properties
-/

/--
If a context is inconsistent, it derives bottom.

This is essentially the definition of inconsistency unwrapped into a derivation.
-/
lemma inconsistent_derives_bot {fc : FrameClass} {Γ : Context}
    (h : ¬Consistent (fc := fc) Γ) :
    Derivable fc Γ Formula.bot := by
  unfold Consistent at h
  push Not at h
  exact h

/--
If extending a consistent context with φ makes it inconsistent, then the original
context derives ¬φ (i.e., φ → ⊥).

This is a key lemma for proving MCS closure properties. It uses the deduction theorem.
-/
lemma derives_neg_from_inconsistent_extension {fc : FrameClass} {Γ : Context} {φ : Formula}
    (h_incons : ¬Consistent (fc := fc) (φ :: Γ)) :
    Derivable fc Γ (Formula.neg φ) := by
  -- Get the derivation of ⊥ from φ :: Γ
  have ⟨d_bot⟩ := inconsistent_derives_bot h_incons
  -- Apply deduction theorem: (φ :: Γ) ⊢ ⊥ implies Γ ⊢ φ → ⊥
  have d_neg : (φ :: Γ) ⊢[fc] Formula.bot := d_bot
  have d_imp := deductionTheorem (fc := fc) Γ φ Formula.bot d_neg
  -- φ → ⊥ is exactly neg φ by definition
  exact ⟨d_imp⟩

/--
From Γ ⊢ φ and Γ ⊢ ¬φ (i.e., φ → ⊥), derive Γ ⊢ ⊥.

This combines a formula and its negation to produce a contradiction.
-/
def derivesBotFromPhiNegPhi {fc : FrameClass} {Γ : Context} {φ : Formula}
    (h_phi : DerivationTree fc Γ φ)
    (h_neg : DerivationTree fc Γ (Formula.neg φ)) :
    DerivationTree fc Γ Formula.bot :=
  -- neg φ = φ.imp bot, so we apply modus ponens
  DerivationTree.modus_ponens Γ φ Formula.bot h_neg h_phi

/--
For maximal consistent sets, if φ ∉ Γ then the extension φ :: Γ is inconsistent.

This is one direction of the maximality definition, made into a lemma for convenience.
-/
lemma maximal_extends_inconsistent {fc : FrameClass} {Γ : Context} {φ : Formula}
    (h_max : MaximalConsistent (fc := fc) Γ) (h_not_mem : φ ∉ Γ) :
    ¬Consistent (fc := fc) (φ :: Γ) :=
  h_max.2 φ h_not_mem

/--
Bridge lemma: SetMaximalConsistent (fc := fc) implies consistency for any finite
subset.

For any list L whose elements are all in a SetMaximalConsistent (fc := fc) set S,
the list L is Consistent.
-/
lemma SetMaximalConsistent.finite_subset_consistent {fc : FrameClass} {S : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) S) (L : List Formula) (h_sub : ∀ φ ∈ L, φ ∈ S) :
    Consistent (fc := fc) L :=
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
theorem maximal_consistent_closed {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h_max : MaximalConsistent (fc := fc) Γ) (h_deriv : DerivationTree fc Γ φ) : φ ∈ Γ := by
  -- Proof by contradiction: assume φ ∉ Γ and derive a contradiction
  by_contra h_not_mem
  -- By maximality, (φ :: Γ) is inconsistent
  have h_incons : ¬Consistent (φ :: Γ) := maximal_extends_inconsistent h_max h_not_mem
  -- So we can derive ¬φ from Γ (using deduction theorem)
  have ⟨h_neg_deriv⟩ := derives_neg_from_inconsistent_extension h_incons
  -- Combine Γ ⊢ φ and Γ ⊢ ¬φ to get Γ ⊢ ⊥
  have h_bot : DerivationTree fc Γ Formula.bot :=
    derivesBotFromPhiNegPhi h_deriv h_neg_deriv
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
theorem maximal_negation_complete {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h_max : MaximalConsistent (fc := fc) Γ) (h_not_mem : φ ∉ Γ) : Formula.neg φ ∈ Γ := by
  -- By maximality, (φ :: Γ) is inconsistent
  have h_incons : ¬Consistent (φ :: Γ) := maximal_extends_inconsistent h_max h_not_mem
  -- So we can derive ¬φ from Γ (using deduction theorem)
  have ⟨h_neg_deriv⟩ := derives_neg_from_inconsistent_extension h_incons
  -- By closure property, ¬φ ∈ Γ
  exact maximal_consistent_closed Γ (Formula.neg φ) h_max h_neg_deriv

/-!
## Theorem Membership

Theorems (formulas derivable from empty context) are members of every MCS.
-/

/--
Theorems (formulas derivable from empty context) are in every maximal consistent set.

**Strategy**: By contradiction using maximality.
1. Assume φ ∉ S (where S is MCS)
2. By maximality, insert φ S is inconsistent
3. There exists L ⊆ insert φ S that derives ⊥
4. Let Γ = L.filter (· ≠ φ). Then (φ :: Γ) ⊢ ⊥
5. By deduction theorem, Γ ⊢ ¬φ
6. But also [] ⊢ φ weakens to Γ ⊢ φ
7. Combining gives Γ ⊢ ⊥, contradicting S being consistent
-/
theorem theorem_in_mcs {fc : FrameClass} {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) S)
    (h_deriv : DerivationTree fc [] φ) : φ ∈ S := by
  by_contra h_not_in
  -- By maximality, insert φ S is inconsistent
  have h_incons : ¬SetConsistent (fc := fc) (insert φ S) := h_mcs.2 φ h_not_in
  -- Unfold ¬SetConsistent to get a witness list
  unfold SetConsistent at h_incons
  push Not at h_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons
  -- L is inconsistent, so L ⊢ ⊥
  have h_bot : Derivable fc L Formula.bot := inconsistent_derives_bot h_L_incons
  obtain ⟨d_bot⟩ := h_bot
  -- Define Γ = L.filter (· ≠ φ)
  let Γ := L.filter (· ≠ φ)
  -- Show Γ ⊆ S
  have h_Γ_in_S : ∀ ψ ∈ Γ, ψ ∈ S := by
    intro ψ hψ
    have hψ' := List.mem_filter.mp hψ
    have hψL := hψ'.1
    have hψne : ψ ≠ φ := by simpa using hψ'.2
    specialize h_L_sub ψ hψL
    simp only [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in_S
    · exact absurd rfl hψne
    · exact h_in_S
  -- L ⊆ φ :: Γ
  have h_L_sub_phiGamma : L ⊆ φ :: Γ := by
    intro ψ hψ
    by_cases hψφ : ψ = φ
    · simp [hψφ]
    · simp only [List.mem_cons]
      right
      exact List.mem_filter.mpr ⟨hψ, by simpa⟩
  -- Weaken derivation from L to φ :: Γ
  have d_bot' : DerivationTree fc (φ :: Γ) Formula.bot :=
    DerivationTree.weakening L (φ :: Γ) Formula.bot d_bot h_L_sub_phiGamma
  -- By deduction theorem, Γ ⊢ ¬φ
  have d_neg : DerivationTree fc Γ (Formula.neg φ) := deductionTheorem Γ φ Formula.bot d_bot'
  -- Weaken [] ⊢ φ to Γ ⊢ φ
  have d_phi : DerivationTree fc Γ φ := DerivationTree.weakening [] Γ φ h_deriv (by simp)
  -- Combine to get Γ ⊢ ⊥
  have d_bot_Γ : DerivationTree fc Γ Formula.bot := derivesBotFromPhiNegPhi d_phi d_neg
  -- This contradicts SetConsistent S (since Γ ⊆ S)
  have h_Γ_cons : Consistent (fc := fc) Γ := h_mcs.1 Γ h_Γ_in_S
  exact h_Γ_cons ⟨d_bot_Γ⟩

end FormalSystem.Metalogic.Core
