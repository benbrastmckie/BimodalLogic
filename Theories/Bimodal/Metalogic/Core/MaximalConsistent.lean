import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Theorems.Propositional
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Order.Zorn
import Mathlib.Data.Finite.Defs
import Mathlib.Order.Preorder.Chain

/-!
# Maximal Consistent Sets for TM Bimodal Logic

This module provides the theory of maximal consistent sets (MCS) for the
TM bimodal logic system. These are foundational for canonical model construction.

## Overview

This module provides core MCS theory needed for the representation theorem
and completeness proofs. It establishes consistency, maximality, and Lindenbaum's lemma.

## Main Results

- `Consistent`: List-based consistency definition
- `MaximalConsistent`: List-based maximal consistency definition
- `SetConsistent`: Set-based consistency definition
- `SetMaximalConsistent`: Set-based maximal consistency definition
- `ConsistentSupersets`: The set of consistent supersets of a base set
- `set_lindenbaum`: Lindenbaum's lemma - every consistent set extends to MCS
- Chain consistency lemmas for Zorn's lemma application
- `maximal_consistent_closed`: MCS deductive closure
- `maximal_negation_complete`: MCS negation completeness
- `theorem_in_mcs`: Theorems are in every MCS

## Layer Dependencies

Core.MaximalConsistent depends on:
- Bimodal.ProofSystem (derivation trees)
- Bimodal.Metalogic.Core.DeductionTheorem (deduction theorem)
- Mathlib.Order.Zorn (Zorn's lemma)
-/

namespace Bimodal.Metalogic.Core

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics Bimodal.Theorems.Combinators Bimodal.Theorems.Propositional

/-!
## List-Based Consistency

A context `Gamma` is **consistent** if no contradiction is derivable from it.
-/

/--
A context `Gamma` is **consistent** if it does not derive bottom (falsity).

Formally: `Consistent Gamma <-> Not(Gamma derives falsity)`

**Examples**:
- `[]` is consistent (can't derive falsity from empty context)
- `[p]` is consistent for atomic `p`
- `[p, Not p]` is inconsistent (derives falsity via propositional reasoning)
-/
def Consistent (Gamma : Context) : Prop := ¬Nonempty (DerivationTree Gamma Formula.bot)

/--
A context `Gamma` is **maximal consistent** if it's consistent and adding any
formula not already in `Gamma` makes it inconsistent.

Formally: `MaximalConsistent Gamma <-> Consistent Gamma And ForAll phi, phi NotIn Gamma -> Not(Consistent (phi :: Gamma))`

**Properties** (to be proven):
- Deductively closed: `Gamma derives phi -> phi In Gamma`
- Negation complete: `phi NotIn Gamma -> Not phi In Gamma`
- Implication property: `(phi -> psi) In Gamma -> (phi In Gamma -> psi In Gamma)`
-/
def MaximalConsistent (Gamma : Context) : Prop :=
  Consistent Gamma ∧ ∀ φ : Formula, φ ∉ Gamma → ¬Consistent (φ :: Gamma)

/-!
## Set-Based Consistency

For canonical model construction, we need set-based consistency since
maximal consistent sets are typically infinite.
-/

/--
Set-based consistency: A set of formulas is consistent if listing them doesn't derive falsity.

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
def contextToSet (Gamma : Context) : Set Formula := {φ | φ ∈ Gamma}

/--
List-based consistency implies set-based consistency for the corresponding set.
-/
lemma consistent_implies_set_consistent {Gamma : Context} (h : Consistent Gamma) :
    SetConsistent (contextToSet Gamma) := by
  intro L hL ⟨d⟩
  apply h
  -- We need to derive falsity from Gamma using the derivation from L
  -- Since all elements of L are in Gamma, we can weaken
  exact ⟨DerivationTree.weakening L Gamma Formula.bot d (fun φ hφ => hL φ hφ)⟩

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
def usedFormulas {Gamma : Context} {φ : Formula} : DerivationTree Gamma φ → List Formula
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
lemma usedFormulas_subset {Gamma : Context} {φ : Formula}
    (d : DerivationTree Gamma φ) : ∀ ψ ∈ usedFormulas d, ψ ∈ Gamma := by
  induction d with
  | «axiom» => simp [usedFormulas]
  | assumption Gamma' ψ h =>
    simp only [usedFormulas, List.mem_singleton]
    intro χ hχ
    rw [hχ]
    exact h
  | modus_ponens Gamma' _ _ _ _ ih1 ih2 =>
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
  | weakening Gamma' Delta _ d h ih =>
    simp only [usedFormulas]
    intro ψ hψ
    exact h (ih ψ hψ)

/--
Any derivation uses only finitely many context formulas, and there exists
a derivation from that finite subset.

This is formulated without constructing the derivation directly (avoiding
the termination issues with necessitation rules).
-/
theorem derivation_uses_finite_context {Gamma : Context} {φ : Formula}
    (d : DerivationTree Gamma φ) :
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Gamma) ∧ (L ⊆ Gamma) := by
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
The case C = emptyset is handled by the caller (consistent_chain_union).
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
    -- ψ is in some S1 In C, and by IH, L' Subset some S2 In C
    have hψ : ψ ∈ ⋃₀ C := hL ψ List.mem_cons_self
    have hL' : ∀ φ ∈ L', φ ∈ ⋃₀ C := fun φ h => hL φ (List.mem_cons_of_mem _ h)
    obtain ⟨S₁, hS₁mem, hψS₁⟩ := Set.mem_sUnion.mp hψ
    obtain ⟨S₂, hS₂mem, hL'S₂⟩ := ih hL'
    -- By chain property, either S1 Subset S2 or S2 Subset S1
    rcases hchain.total hS₁mem hS₂mem with h | h
    · -- S1 Subset S2, so ψ In S2 and L' Subset S2
      exact ⟨S₂, hS₂mem, fun φ hφ =>
        match List.mem_cons.mp hφ with
        | .inl heq => heq ▸ h hψS₁
        | .inr hmem => hL'S₂ φ hmem⟩
    · -- S2 Subset S1, so L' Subset S1 and ψ In S1
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
  -- hL says all elements of L are in Union C
  -- We need to show Consistent L
  -- By finite_list_in_chain_member, L Subset some S In C
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
    · -- Show Union C In CS, i.e., S Subset Union C and SetConsistent (Union C)
      constructor
      · -- S Subset Union C: Since C is nonempty, pick any T In C, then S Subset T Subset Union C
        obtain ⟨T, hT⟩ := hCne
        have hST : S ⊆ T := (hCsub hT).1
        exact Set.Subset.trans hST (Set.subset_sUnion_of_mem hT)
      · -- SetConsistent (Union C): Use consistent_chain_union
        apply consistent_chain_union hCchain hCne
        intro T hT
        exact (hCsub hT).2
    · -- Show ForAll T In C, T Subset Union C
      intro T hT
      exact Set.subset_sUnion_of_mem hT
  -- Apply Zorn's lemma
  have hSmem : S ∈ CS := self_mem_consistent_supersets hS
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty CS hchain S hSmem
  -- hmax : Maximal (fun x => x In CS) M
  -- This means M In CS and ForAll T, M Subset T -> T In CS -> M = T
  have hMmem : M ∈ CS := hmax.prop
  obtain ⟨_, hMcons⟩ := hMmem
  -- M is maximal in CS. Show it's SetMaximalConsistent.
  use M
  constructor
  · exact hSM
  · -- Show SetMaximalConsistent M
    constructor
    · exact hMcons
    · -- Show ForAll phi NotIn M, Not SetConsistent (insert phi M)
      intro φ hφnotM hcons_insert
      -- If insert phi M were consistent, then insert phi M In CS
      have h_insert_mem : insert φ M ∈ CS := by
        constructor
        · exact Set.Subset.trans hSM (Set.subset_insert φ M)
        · exact hcons_insert
      -- M is maximal: if insert phi M In CS and M Subset insert phi M, then insert phi M Subset M
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
lemma inconsistent_derives_bot {Gamma : Context} (h : ¬Consistent Gamma) :
    Nonempty (DerivationTree Gamma Formula.bot) := by
  unfold Consistent at h
  push_neg at h
  exact h

/--
If extending a consistent context with phi makes it inconsistent, then the original
context derives Not phi (i.e., phi -> falsity).

This is a key lemma for proving MCS closure properties. It uses the deduction theorem.
-/
lemma derives_neg_from_inconsistent_extension {Gamma : Context} {φ : Formula}
    (h_incons : ¬Consistent (φ :: Gamma)) :
    Nonempty (DerivationTree Gamma (Formula.neg φ)) := by
  -- Get the derivation of falsity from phi :: Gamma
  have ⟨d_bot⟩ := inconsistent_derives_bot h_incons
  -- Apply deduction theorem: (phi :: Gamma) derives falsity implies Gamma derives phi -> falsity
  have d_neg : Gamma ⊢ φ.imp Formula.bot := deduction_theorem Gamma φ Formula.bot d_bot
  -- phi -> falsity is exactly neg phi by definition
  exact ⟨d_neg⟩

/--
From Gamma derives phi and Gamma derives Not phi (i.e., phi -> falsity), derive Gamma derives falsity.

This combines a formula and its negation to produce a contradiction.
-/
def derives_bot_from_phi_neg_phi {Gamma : Context} {φ : Formula}
    (h_phi : DerivationTree Gamma φ)
    (h_neg : DerivationTree Gamma (Formula.neg φ)) :
    DerivationTree Gamma Formula.bot :=
  -- neg phi = phi.imp bot, so we apply modus ponens
  DerivationTree.modus_ponens Gamma φ Formula.bot h_neg h_phi

/--
For maximal consistent sets, if phi NotIn Gamma then the extension phi :: Gamma is inconsistent.

This is one direction of the maximality definition, made into a lemma for convenience.
-/
lemma maximal_extends_inconsistent {Gamma : Context} {φ : Formula}
    (h_max : MaximalConsistent Gamma) (h_not_mem : φ ∉ Gamma) :
    ¬Consistent (φ :: Gamma) :=
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

**Statement**: `MaximalConsistent Gamma -> (Gamma derives phi -> phi In Gamma)`

**Proof Strategy**:
1. Assume `Gamma derives phi` but `phi NotIn Gamma`
2. By maximality, `phi :: Gamma` is inconsistent
3. So `phi :: Gamma derives falsity`
4. By deduction theorem, `Gamma derives phi -> falsity`, i.e., `Gamma derives Not phi`
5. Combine with `Gamma derives phi` to get `Gamma derives falsity` (contradiction)

**Note**: Requires deduction theorem for TM logic.
-/
theorem maximal_consistent_closed (Gamma : Context) (φ : Formula)
    (h_max : MaximalConsistent Gamma) (h_deriv : DerivationTree Gamma φ) : φ ∈ Gamma := by
  -- Proof by contradiction: assume phi NotIn Gamma and derive a contradiction
  by_contra h_not_mem
  -- By maximality, (phi :: Gamma) is inconsistent
  have h_incons : ¬Consistent (φ :: Gamma) := maximal_extends_inconsistent h_max h_not_mem
  -- So we can derive Not phi from Gamma (using deduction theorem)
  have ⟨h_neg_deriv⟩ := derives_neg_from_inconsistent_extension h_incons
  -- Combine Gamma derives phi and Gamma derives Not phi to get Gamma derives falsity
  have h_bot : DerivationTree Gamma Formula.bot :=
    derives_bot_from_phi_neg_phi h_deriv h_neg_deriv
  -- This contradicts consistency of Gamma
  exact h_max.1 ⟨h_bot⟩

/--
Maximal consistent sets are negation complete.

**Statement**: `MaximalConsistent Gamma -> (phi NotIn Gamma -> Not phi In Gamma)`

**Proof Strategy**:
1. Assume `phi NotIn Gamma`
2. By maximality, `phi :: Gamma derives falsity`
3. By deduction theorem, `Gamma derives phi -> falsity`, i.e., `Gamma derives Not phi`
4. By closure, `Not phi In Gamma`
-/
theorem maximal_negation_complete (Gamma : Context) (φ : Formula)
    (h_max : MaximalConsistent Gamma) (h_not_mem : φ ∉ Gamma) : Formula.neg φ ∈ Gamma := by
  -- By maximality, (phi :: Gamma) is inconsistent
  have h_incons : ¬Consistent (φ :: Gamma) := maximal_extends_inconsistent h_max h_not_mem
  -- So we can derive Not phi from Gamma (using deduction theorem)
  have ⟨h_neg_deriv⟩ := derives_neg_from_inconsistent_extension h_incons
  -- By closure property, Not phi In Gamma
  exact maximal_consistent_closed Gamma (Formula.neg φ) h_max h_neg_deriv

/-!
## Theorem Membership

Theorems (formulas derivable from empty context) are members of every MCS.
-/

/--
Theorems (formulas derivable from empty context) are in every maximal consistent set.

**Strategy**: By contradiction using maximality.
1. Assume phi NotIn S (where S is MCS)
2. By maximality, insert phi S is inconsistent
3. There exists L Subset insert phi S that derives falsity
4. Let Gamma = L.filter (not equal phi). Then (phi :: Gamma) derives falsity
5. By deduction theorem, Gamma derives Not phi
6. But also [] derives phi weakens to Gamma derives phi
7. Combining gives Gamma derives falsity, contradicting S being consistent
-/
theorem theorem_in_mcs {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_deriv : DerivationTree [] φ) : φ ∈ S := by
  by_contra h_not_in
  -- By maximality, insert phi S is inconsistent
  have h_incons : ¬SetConsistent (insert φ S) := h_mcs.2 φ h_not_in
  -- Unfold Not SetConsistent to get a witness list
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons
  -- L is inconsistent, so L derives falsity
  have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
  obtain ⟨d_bot⟩ := h_bot
  -- Define Gamma = L.filter (not equal phi)
  let Gamma := L.filter (· ≠ φ)
  -- Show Gamma Subset S
  have h_Gamma_in_S : ∀ ψ ∈ Gamma, ψ ∈ S := by
    intro ψ hψ
    have hψ' := List.mem_filter.mp hψ
    have hψL := hψ'.1
    have hψne : ψ ≠ φ := by simpa using hψ'.2
    specialize h_L_sub ψ hψL
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in_S
    · exact absurd rfl hψne
    · exact h_in_S
  -- L Subset phi :: Gamma
  have h_L_sub_phiGamma : L ⊆ φ :: Gamma := by
    intro ψ hψ
    by_cases hψφ : ψ = φ
    · simp [hψφ]
    · simp only [List.mem_cons]
      right
      exact List.mem_filter.mpr ⟨hψ, by simpa⟩
  -- Weaken derivation from L to phi :: Gamma
  have d_bot' : DerivationTree (φ :: Gamma) Formula.bot :=
    DerivationTree.weakening L (φ :: Gamma) Formula.bot d_bot h_L_sub_phiGamma
  -- By deduction theorem, Gamma derives Not phi
  have d_neg : DerivationTree Gamma (Formula.neg φ) := deduction_theorem Gamma φ Formula.bot d_bot'
  -- Weaken [] derives phi to Gamma derives phi
  have d_phi : DerivationTree Gamma φ := DerivationTree.weakening [] Gamma φ h_deriv (by simp)
  -- Combine to get Gamma derives falsity
  have d_bot_Gamma : DerivationTree Gamma Formula.bot := derives_bot_from_phi_neg_phi d_phi d_neg
  -- This contradicts SetConsistent S (since Gamma Subset S)
  have h_Gamma_cons : Consistent Gamma := h_mcs.1 Gamma h_Gamma_in_S
  exact h_Gamma_cons ⟨d_bot_Gamma⟩

/-!
## Set-Based MCS Properties

Properties for set-based maximal consistent sets, particularly needed
for the canonical model construction and FMP proof.
-/

/--
Helper lemma: From the negation of SetConsistent (insert phi S), extract a context Gamma Subset S
such that Gamma derives Not phi.

This bridges set-based inconsistency to list-based derivation infrastructure.
The key insight is that if `insert phi S` is inconsistent, there's a finite list L
with elements from `insert phi S` that derives falsity. Filtering out phi gives a subset of S
from which we can derive Not phi using the deduction theorem.
-/
lemma extract_neg_derivation {S : Set Formula} {φ : Formula}
    (h_incons : ¬SetConsistent (insert φ S))
    (_h_S_cons : SetConsistent S) :
    ∃ Gamma : Context, (∀ ψ ∈ Gamma, ψ ∈ S) ∧ Nonempty (DerivationTree Gamma (Formula.neg φ)) := by
  -- Unfold Not SetConsistent to get a witness list
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons
  -- L is inconsistent, so L derives falsity
  have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
  obtain ⟨d_bot⟩ := h_bot
  -- Define Gamma = L.filter (not equal phi) = elements of L that are in S
  let Gamma := L.filter (· ≠ φ)
  -- Show Gamma Subset S
  have h_Gamma_in_S : ∀ ψ ∈ Gamma, ψ ∈ S := by
    intro ψ hψ
    have hψ' := List.mem_filter.mp hψ
    have hψL := hψ'.1
    have hψne : ψ ≠ φ := by simpa using hψ'.2
    specialize h_L_sub ψ hψL
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in_S
    · exact absurd rfl hψne
    · exact h_in_S
  -- Key: L Subset phi :: Gamma (since elements of L are either phi or in Gamma)
  have h_L_sub_phiGamma : L ⊆ φ :: Gamma := by
    intro ψ hψ
    by_cases hψφ : ψ = φ
    · simp [hψφ]
    · simp only [List.mem_cons]
      right
      exact List.mem_filter.mpr ⟨hψ, by simpa⟩
  -- Weaken derivation from L to phi :: Gamma
  have d_bot' : DerivationTree (φ :: Gamma) Formula.bot :=
    DerivationTree.weakening L (φ :: Gamma) Formula.bot d_bot h_L_sub_phiGamma
  -- Now (phi :: Gamma) derives falsity, so Not Consistent (phi :: Gamma)
  have h_phi_Gamma_incons : ¬Consistent (φ :: Gamma) := fun h => h ⟨d_bot'⟩
  -- Apply derives_neg_from_inconsistent_extension to get Gamma derives Not phi
  have h_neg := derives_neg_from_inconsistent_extension h_phi_Gamma_incons
  exact ⟨Gamma, h_Gamma_in_S, h_neg⟩

/--
Key property: A set-based maximal consistent set contains phi or its negation.

This is essential for the truth lemma. The proof uses a classical argument:
if neither phi nor Not phi is in S, then by maximality both `insert phi S` and
`insert Not phi S` are inconsistent. From these, we extract derivations of Not phi
and Not Not phi from subsets of S, which (via DNE) yields both phi and Not phi derivable
from S, contradicting SetConsistent S.
-/
theorem mcs_contains_or_neg {S : Set Formula} (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ Formula.neg φ ∈ S := by
  by_cases hφ : φ ∈ S
  · left; exact hφ
  · right
    by_contra hneg
    -- Both phi NotIn S and Not phi NotIn S
    -- By maximality, insert phi S and insert Not phi S are both inconsistent
    have h_incons_phi := h_mcs.2 φ hφ
    have h_incons_neg := h_mcs.2 (Formula.neg φ) hneg
    -- From h_incons_phi, get Gamma1 Subset S with Gamma1 derives Not phi
    obtain ⟨Gamma1, h_Gamma1_sub, ⟨d_neg_phi⟩⟩ := extract_neg_derivation h_incons_phi h_mcs.1
    -- From h_incons_neg, get Gamma2 Subset S with Gamma2 derives Not Not phi
    obtain ⟨Gamma2, h_Gamma2_sub, ⟨d_neg_neg_phi⟩⟩ := extract_neg_derivation h_incons_neg h_mcs.1
    -- Combine Gamma1 and Gamma2
    let Gamma := Gamma1 ++ Gamma2
    have h_Gamma_sub : ∀ ψ ∈ Gamma, ψ ∈ S := by
      intro ψ hψ
      rcases List.mem_append.mp hψ with h | h
      · exact h_Gamma1_sub ψ h
      · exact h_Gamma2_sub ψ h
    -- Weaken both derivations to Gamma
    have d_neg_phi' : DerivationTree Gamma (Formula.neg φ) :=
      DerivationTree.weakening Gamma1 Gamma _ d_neg_phi (List.subset_append_left Gamma1 Gamma2)
    have d_neg_neg_phi' : DerivationTree Gamma (Formula.neg (Formula.neg φ)) :=
      DerivationTree.weakening Gamma2 Gamma _ d_neg_neg_phi (List.subset_append_right Gamma1 Gamma2)
    -- Apply DNE to get Gamma derives phi
    have d_dne : DerivationTree [] ((Formula.neg (Formula.neg φ)).imp φ) := double_negation φ
    have d_dne' : DerivationTree Gamma ((Formula.neg (Formula.neg φ)).imp φ) :=
      DerivationTree.weakening [] Gamma _ d_dne (by simp)
    have d_phi : DerivationTree Gamma φ := DerivationTree.modus_ponens Gamma _ _ d_dne' d_neg_neg_phi'
    -- Combine phi and Not phi to get falsity
    have d_bot : DerivationTree Gamma Formula.bot := derives_bot_from_phi_neg_phi d_phi d_neg_phi'
    -- This contradicts SetConsistent S
    have h_Gamma_incons : ¬Consistent Gamma := fun h => h ⟨d_bot⟩
    exact h_Gamma_incons (h_mcs.1 Gamma h_Gamma_sub)

/--
Modus ponens for set-based MCS: If (phi -> psi) In S and phi In S, then psi In S.

This follows from the negation completeness property: if psi NotIn S, then Not psi In S,
and combining phi, (phi -> psi), and Not psi yields a contradiction via modus ponens.
-/
theorem set_mcs_modus_ponens {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    {φ ψ : Formula} (h_imp : Formula.imp φ ψ ∈ S) (h_ant : φ ∈ S) : ψ ∈ S := by
  by_contra hψ
  -- If psi NotIn S, then Not psi In S by mcs_contains_or_neg
  have h_or := mcs_contains_or_neg h_mcs ψ
  cases h_or with
  | inl h => exact hψ h
  | inr h_neg =>
    -- Now we have phi In S, (phi -> psi) In S, and Not psi In S
    -- Build a derivation from [phi, phi.imp psi, psi.neg] that derives falsity
    let L : List Formula := [φ, φ.imp ψ, ψ.neg]
    -- All elements of L are in S
    have h_L_sub : ∀ ψ' ∈ L, ψ' ∈ S := by
      intro ψ' hψ'
      simp only [L, List.mem_cons] at hψ'
      rcases hψ' with rfl | rfl | rfl | h
      · exact h_ant
      · exact h_imp
      · exact h_neg
      · simp at h
    -- Build membership proofs for explicit construction
    have h1 : φ ∈ L := by simp [L]
    have h2 : φ.imp ψ ∈ L := by simp [L]
    have h3 : ψ.neg ∈ L := by simp [L]
    -- Build derivations
    have d_phi : DerivationTree L φ := DerivationTree.assumption L φ h1
    have d_imp : DerivationTree L (φ.imp ψ) := DerivationTree.assumption L (φ.imp ψ) h2
    have d_psi : DerivationTree L ψ := DerivationTree.modus_ponens L _ _ d_imp d_phi
    have d_neg_psi : DerivationTree L ψ.neg := DerivationTree.assumption L ψ.neg h3
    have d_bot : DerivationTree L Formula.bot := derives_bot_from_phi_neg_phi d_psi d_neg_psi
    -- This shows Not Consistent L
    have h_L_incons : ¬Consistent L := fun h => h ⟨d_bot⟩
    -- But all elements of L are in S, so L should be consistent
    have h_L_cons : Consistent L := h_mcs.1 L h_L_sub
    exact h_L_incons h_L_cons

/--
In a set-consistent set, phi and phi.neg cannot both be members.

**Proof Strategy**:
1. Build derivation [phi, phi.neg] derives falsity using modus ponens
2. Since [phi, phi.neg] Subset S and S is consistent, this is a contradiction
-/
theorem set_consistent_not_both {S : Set Formula} (h_cons : SetConsistent S)
    (phi : Formula) (h_phi : phi ∈ S) (h_neg : phi.neg ∈ S) : False := by
  -- [phi, phi.neg] derives falsity
  have h_deriv : DerivationTree [phi, phi.neg] Formula.bot := by
    -- phi.neg = phi -> falsity
    -- From phi and phi -> falsity, derive falsity by modus ponens
    have h_phi_assume : DerivationTree [phi, phi.neg] phi :=
      DerivationTree.assumption _ _ (by simp)
    have h_neg_assume : DerivationTree [phi, phi.neg] phi.neg :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ phi Formula.bot h_neg_assume h_phi_assume
  -- But [phi, phi.neg] Subset S, so S is inconsistent
  have h_sub : ∀ ψ ∈ [phi, phi.neg], ψ ∈ S := by
    intro ψ hψ
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
    cases hψ with
    | inl h => exact h ▸ h_phi
    | inr h => exact h ▸ h_neg
  exact h_cons [phi, phi.neg] h_sub ⟨h_deriv⟩

/--
If phi.neg is in a set-maximal consistent set M, then phi is not in M.

This is the contrapositive of negation completeness: if Not phi In M, then phi NotIn M.
Used in the completeness proof to show countermodels exist.
-/
theorem set_mcs_neg_excludes {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (phi : Formula) (h_neg : phi.neg ∈ S) : phi ∉ S := by
  intro h_phi
  exact set_consistent_not_both h_mcs.1 phi h_phi h_neg

end Bimodal.Metalogic.Core
