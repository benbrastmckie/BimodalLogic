import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.DeductionTheorem
import Bimodal.Theorems.Propositional
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Order.Zorn
import Mathlib.Data.Finite.Defs

/-!
# Completeness for TM Bimodal Logic

This module proves the completeness theorem for the TM (Tense and Modality)
bimodal logic system via canonical model construction.

## Main Results

- `set_lindenbaum`: Every consistent set can be extended to a maximal consistent set
  (uses Zorn's lemma, proven)
- `weak_completeness`: `⊨ φ → ⊢ φ` (valid implies provable)
- `strong_completeness`: `Γ ⊨ φ → Γ ⊢ φ` (semantic consequence implies syntactic)

## Canonical Model Construction

The completeness proof follows the standard canonical model approach using
**set-based** maximal consistent sets (`Set Formula`) rather than list-based contexts:

1. **Set-Based Consistency**: `SetConsistent S` and `SetMaximalConsistent S` for sets
2. **Lindenbaum's Lemma**: `set_lindenbaum` extends any consistent set to maximal
   (proven using Zorn's lemma)
3. **Canonical Frame**: Build frame from set-based maximal consistent sets
   - World states: `{S : Set Formula // SetMaximalConsistent S}`
   - Times: Integers (representing temporal structure)
   - Task relation: Defined via consistency with modal/temporal operators
4. **Canonical Model**: Add valuation function using set membership
5. **Truth Lemma**: By induction, `φ ∈ S.val ↔ M_can, τ_can, 0 ⊨ φ`
6. **Completeness**: If `Γ ⊨ φ` then `φ ∈ closure(Γ)`, so `Γ ⊢ φ`

**Why Set-Based?** Maximal consistent sets are typically infinite (containing
every formula or its negation), so they cannot be represented as finite lists.
The set-based approach is the mathematically correct formulation.

## Implementation Status

**Infrastructure Complete**: This module provides:
- Proven: `set_lindenbaum` (Zorn's lemma application)
- Axioms: `weak_completeness`, `strong_completeness`, canonical model definitions
- Infrastructure: Derivation tree utilities, chain consistency lemmas

Full implementation of axioms requires:
1. **Canonical Frame Construction**: Prove frame properties (nullity, compositionality)
2. **Truth Lemma**: Complex mutual induction on formula structure
3. **Set-Based Properties**: Deduction theorem and closure for set-based consistency

Estimated effort: 60-80 hours of focused metalogic development.

## Design Decisions

- **Set-Based World States**: `{S : Set Formula // SetMaximalConsistent S}` (not list-based)
- **Time Structure**: Use integers (ℤ) for canonical temporal ordering
- **Task Relation**: Define via formula reachability through modal/temporal chains
- **Valuation**: Atomic formula `p` true iff `p ∈ S.val` (set membership)
- **Countable Formulas**: `Countable Formula` instance enables enumeration when needed

## References

* Modal Logic, Blackburn et al., Chapter 4 (Canonical Models)
* Handbook of Modal Logic, van Benthem & Blackburn (2006)
* LEAN Completeness Proofs: Mathlib's propositional completeness
-/

namespace Bimodal.Metalogic

open Syntax ProofSystem Semantics Theorems.Combinators Theorems.Propositional

/-!
## Consistent Sets

A set of formulas Γ is consistent if no contradiction can be derived from it.
-/

/--
A context `Γ` is **consistent** if no contradiction is derivable from it.

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
## Lindenbaum Infrastructure

Definitions and lemmas supporting the Zorn's lemma application for Lindenbaum's lemma.
We work with `Set Formula` internally for cleaner chain properties, then convert back
to `List Formula` for the final result.
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
For empty context derivations, usedFormulas must be empty.
-/
lemma usedFormulas_empty_context {φ : Formula}
    (d : DerivationTree [] φ) : usedFormulas d = [] := by
  have h := usedFormulas_subset d
  cases heq : usedFormulas d with
  | nil => rfl
  | cons ψ L' =>
    exfalso
    have hmem : ψ ∈ usedFormulas d := by rw [heq]; exact List.mem_cons_self
    exact (List.not_mem_nil (h ψ hmem))

/--
For necessitation rules, usedFormulas is empty (since subproof context is []).
-/
lemma usedFormulas_necessitation_eq_nil {φ : Formula} (d : DerivationTree [] φ) :
    usedFormulas (DerivationTree.necessitation φ d) = [] := by
  simp only [usedFormulas]
  exact usedFormulas_empty_context d

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

/--
A derivation from a subset can be weakened to the superset.
-/
def derivation_from_subset_weaken {Γ Δ : Context} {φ : Formula}
    (d : DerivationTree Γ φ) (h : Γ ⊆ Δ) : DerivationTree Δ φ :=
  DerivationTree.weakening Γ Δ φ d h

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
## Maximal Consistent Set Properties

These lemmas establish the deductive closure and completeness properties
of maximal consistent sets.
-/

/-!
### Helper Lemmas for MCS Proofs

These helper lemmas establish foundational facts needed for the main MCS properties.
They provide bridging between inconsistency, derivation, and the deduction theorem.
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

/-!
### Set-Based MCS Properties

These lemmas establish properties of SetMaximalConsistent sets, which are used
for the canonical model construction. They parallel the list-based properties
but work with infinite sets of formulas.
-/

/--
Helper: If `A ∈ Γ'`, then `A :: Γ'.filter (fun x => decide (x ≠ A))` has the same elements as `Γ'`.
-/
private lemma cons_filter_neq_perm {A : Formula} {Γ' : Context}
    (h_mem : A ∈ Γ') : ∀ x, x ∈ A :: Γ'.filter (fun y => decide (y ≠ A)) ↔ x ∈ Γ' := by
  intro x
  constructor
  · intro h
    simp only [List.mem_cons] at h
    cases h with
    | inl h_eq =>
      subst h_eq
      exact h_mem
    | inr h_in =>
      simp only [List.mem_filter, decide_eq_true_eq] at h_in
      exact h_in.1
  · intro h
    by_cases hx : x = A
    · subst hx
      simp only [List.mem_cons, true_or]
    · simp only [List.mem_cons, List.mem_filter, decide_eq_true_eq]
      right
      exact ⟨h, hx⟩

/--
Exchange lemma for derivations: If Γ and Γ' have the same elements, derivation is preserved.
-/
private def derivation_exchange {Γ Γ' : Context} {φ : Formula}
    (h : Γ ⊢ φ) (h_perm : ∀ x, x ∈ Γ ↔ x ∈ Γ') : Γ' ⊢ φ :=
  DerivationTree.weakening Γ Γ' φ h (fun x hx => (h_perm x).mp hx)

/--
For set-based MCS, derivable formulas are in the set.

If S is SetMaximalConsistent and L ⊆ S derives φ, then φ ∈ S.
-/
lemma set_mcs_closed_under_derivation {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ S)
    (h_deriv : DerivationTree L φ) : φ ∈ S := by
  -- By contradiction: assume φ ∉ S
  by_contra h_not_mem
  -- By SetMaximalConsistent definition, insert φ S is inconsistent
  have h_incons : ¬SetConsistent (insert φ S) := h_mcs.2 φ h_not_mem
  -- SetConsistent means all finite subsets are consistent
  -- We have L ⊆ S and L ⊢ φ
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons
  -- L' ⊆ insert φ S and L' is inconsistent
  -- If φ ∉ L', then L' ⊆ S, contradicting S consistent.
  -- So φ ∈ L'. Then by deduction theorem, L' \ {φ} ⊢ φ → ⊥.
  -- Combined with L ⊢ φ, we can derive ⊥ from L ∪ (L' \ {φ}) ⊆ S.
  by_cases h_phi_in_L' : φ ∈ L'
  · -- φ ∈ L'. Use exchange to put φ first, then deduction theorem.
    -- We have L' ⊢ ⊥ (since L' is inconsistent)
    have ⟨d_bot⟩ : Nonempty (DerivationTree L' Formula.bot) := by
      unfold Consistent at h_L'_incons
      push_neg at h_L'_incons
      exact h_L'_incons
    -- Exchange to put φ first: L' has same elements as φ :: L'.filter (fun x => x ≠ φ)
    let L'_filt := L'.filter (fun y => decide (y ≠ φ))
    have h_perm := cons_filter_neq_perm h_phi_in_L'
    have d_bot_reord : DerivationTree (φ :: L'_filt) Formula.bot :=
      derivation_exchange d_bot (fun x => (h_perm x).symm)
    -- Apply deduction theorem
    have d_neg_phi : DerivationTree L'_filt (Formula.neg φ) :=
      deduction_theorem L'_filt φ Formula.bot d_bot_reord
    -- L'_filt ⊆ S
    have h_filt_sub : ∀ ψ, ψ ∈ L'_filt → ψ ∈ S := by
      intro ψ h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L' : ψ ∈ L' := h_and.1
      have h_ne : ψ ≠ φ := by
        simp only [decide_eq_true_eq] at h_and
        exact h_and.2
      have := h_L'_sub ψ h_in_L'
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq h_ne
      | inr h_in_S => exact h_in_S
    -- From L ⊢ φ (weakened) and L'_filt ⊢ ¬φ, derive ⊥ from L ∪ L'_filt
    -- Weaken both to L ++ L'_filt
    let Γ := L ++ L'_filt
    have h_Γ_sub : ∀ ψ ∈ Γ, ψ ∈ S := by
      intro ψ h_mem
      cases List.mem_append.mp h_mem with
      | inl h_L => exact h_sub ψ h_L
      | inr h_filt => exact h_filt_sub ψ h_filt
    have d_phi_Γ : DerivationTree Γ φ :=
      DerivationTree.weakening L Γ φ h_deriv (List.subset_append_left L _)
    have d_neg_Γ : DerivationTree Γ (Formula.neg φ) :=
      DerivationTree.weakening L'_filt Γ (Formula.neg φ) d_neg_phi
        (List.subset_append_right L _)
    have d_bot_Γ : DerivationTree Γ Formula.bot :=
      derives_bot_from_phi_neg_phi d_phi_Γ d_neg_Γ
    -- This contradicts S being consistent
    exact h_mcs.1 Γ h_Γ_sub ⟨d_bot_Γ⟩
  · -- φ ∉ L', so L' ⊆ S
    have h_L'_in_S : ∀ ψ ∈ L', ψ ∈ S := by
      intro ψ h_mem
      have := h_L'_sub ψ h_mem
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq (fun h' => h_phi_in_L' (h' ▸ h_mem))
      | inr h_in_S => exact h_in_S
    -- L' ⊆ S and L' is inconsistent contradicts S consistent
    unfold Consistent at h_L'_incons
    push_neg at h_L'_incons
    exact h_mcs.1 L' h_L'_in_S h_L'_incons

/--
Set-based MCS implication property: modus ponens is reflected in membership.

If (φ → ψ) ∈ S and φ ∈ S for a SetMaximalConsistent S, then ψ ∈ S.
-/
theorem set_mcs_implication_property {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_imp : (φ.imp ψ) ∈ S) (h_phi : φ ∈ S) : ψ ∈ S := by
  -- Use set_mcs_closed_under_derivation with L = [φ, φ.imp ψ]
  have h_sub : ∀ χ ∈ [φ, φ.imp ψ], χ ∈ S := by
    intro χ h_mem
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at h_mem
    cases h_mem with
    | inl h_eq => exact h_eq ▸ h_phi
    | inr h_eq => exact h_eq ▸ h_imp
  -- Derive ψ from [φ, φ → ψ]
  have h_deriv : DerivationTree [φ, φ.imp ψ] ψ := by
    have h_assume_phi : [φ, φ.imp ψ] ⊢ φ :=
      DerivationTree.assumption [φ, φ.imp ψ] φ (by simp)
    have h_assume_imp : [φ, φ.imp ψ] ⊢ φ.imp ψ :=
      DerivationTree.assumption [φ, φ.imp ψ] (φ.imp ψ) (by simp)
    exact DerivationTree.modus_ponens [φ, φ.imp ψ] φ ψ h_assume_imp h_assume_phi
  exact set_mcs_closed_under_derivation h_mcs [φ, φ.imp ψ] h_sub h_deriv

/--
Set-based MCS: negation completeness.

For SetMaximalConsistent S, either φ ∈ S or (¬φ) ∈ S.
-/
theorem set_mcs_negation_complete {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ (Formula.neg φ) ∈ S := by
  by_cases h : φ ∈ S
  · left; exact h
  · right
    -- If φ ∉ S, then insert φ S is inconsistent
    have h_incons : ¬SetConsistent (insert φ S) := h_mcs.2 φ h
    unfold SetConsistent at h_incons
    push_neg at h_incons
    obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons
    -- L' is inconsistent and L' ⊆ insert φ S
    -- If φ ∉ L', then L' ⊆ S contradicts S consistent
    -- So φ ∈ L'. By deduction theorem on L' (reordered to have φ first):
    -- L' \ {φ} ⊢ φ → ⊥, i.e., L' \ {φ} ⊢ ¬φ
    by_cases h_phi_in_L' : φ ∈ L'
    · -- φ ∈ L'. Use exchange and deduction theorem.
      have ⟨d_bot⟩ : Nonempty (DerivationTree L' Formula.bot) := by
        unfold Consistent at h_L'_incons
        push_neg at h_L'_incons
        exact h_L'_incons
      -- Exchange to put φ first using filter
      let L'_filt := L'.filter (fun y => decide (y ≠ φ))
      have h_perm := cons_filter_neq_perm h_phi_in_L'
      have d_bot_reord : DerivationTree (φ :: L'_filt) Formula.bot :=
        derivation_exchange d_bot (fun x => (h_perm x).symm)
      -- Apply deduction theorem
      have d_neg_phi : DerivationTree L'_filt (Formula.neg φ) :=
        deduction_theorem L'_filt φ Formula.bot d_bot_reord
      -- L'_filt ⊆ S
      have h_filt_sub : ∀ ψ, ψ ∈ L'_filt → ψ ∈ S := by
        intro ψ h_mem
        have h_and := List.mem_filter.mp h_mem
        have h_in_L' : ψ ∈ L' := h_and.1
        have h_ne : ψ ≠ φ := by
          simp only [decide_eq_true_eq] at h_and
          exact h_and.2
        have := h_L'_sub ψ h_in_L'
        cases Set.mem_insert_iff.mp this with
        | inl h_eq => exact absurd h_eq h_ne
        | inr h_in_S => exact h_in_S
      -- Now derive ¬φ ∈ S using set_mcs_closed_under_derivation
      exact set_mcs_closed_under_derivation h_mcs L'_filt h_filt_sub d_neg_phi
    · -- φ ∉ L', so L' ⊆ S
      have h_L'_in_S : ∀ ψ ∈ L', ψ ∈ S := by
        intro ψ h_mem
        have := h_L'_sub ψ h_mem
        cases Set.mem_insert_iff.mp this with
        | inl h_eq => exact absurd h_eq (fun h' => h_phi_in_L' (h' ▸ h_mem))
        | inr h_in_S => exact h_in_S
      -- L' ⊆ S and L' is inconsistent contradicts S consistent
      unfold Consistent at h_L'_incons
      push_neg at h_L'_incons
      exact absurd h_L'_incons (h_mcs.1 L' h_L'_in_S)

/--
Set-based MCS: disjunction property (forward direction).

If φ ∈ S or ψ ∈ S, then (φ ∨ ψ) ∈ S.
Note: `φ.or ψ = φ.neg.imp ψ`
-/
theorem set_mcs_disjunction_intro {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : φ ∈ S ∨ ψ ∈ S) : (φ.or ψ) ∈ S := by
  -- φ.or ψ = φ.neg.imp ψ
  -- We need to show that φ.neg.imp ψ ∈ S
  cases h with
  | inl h_phi =>
    -- φ ∈ S. We derive (¬φ → ψ) from the axiom (φ → ¬φ → ψ) and modus ponens.
    -- Actually, we derive ¬φ → ψ by: from φ, derive ¬¬φ, then ¬¬φ → (¬φ → ψ) is tautology
    -- Simpler: by set_mcs_negation_complete, either φ.neg ∈ S or φ.neg.neg ∈ S
    -- Since φ ∈ S, we show φ.neg ∉ S (else inconsistent)
    -- So φ.neg.neg ∈ S is not directly helpful...
    -- Better: use the theorem that derives ¬φ → ψ from φ using weakening
    -- From [φ, φ.neg] we derive ψ via EFQ. Then φ :: [φ.neg] ⊢ ψ.
    -- By deduction theorem: [φ] ⊢ φ.neg → ψ, i.e., [φ] ⊢ φ.or ψ
    -- Then by closure: if [φ] ⊆ S, then φ.or ψ ∈ S.
    have h_deriv : DerivationTree [φ] (φ.or ψ) := by
      -- Need: [φ] ⊢ φ.neg.imp ψ
      -- Use deduction theorem: need φ.neg :: [φ] ⊢ ψ
      -- From φ.neg :: [φ] we have φ and φ.neg, so we get ⊥, then ψ by EFQ
      have h_inner : DerivationTree (φ.neg :: [φ]) ψ := by
        have h_phi_assume : (φ.neg :: [φ]) ⊢ φ :=
          DerivationTree.assumption _ _ (by simp)
        have h_neg_assume : (φ.neg :: [φ]) ⊢ φ.neg :=
          DerivationTree.assumption _ _ (by simp)
        have h_bot : (φ.neg :: [φ]) ⊢ Formula.bot :=
          derives_bot_from_phi_neg_phi h_phi_assume h_neg_assume
        -- EFQ: ⊥ → ψ (via ex_falso axiom, weakened to context)
        have h_efq_thm : [] ⊢ Formula.bot.imp ψ :=
          DerivationTree.axiom [] _ (Axiom.ex_falso ψ)
        have h_efq : (φ.neg :: [φ]) ⊢ Formula.bot.imp ψ :=
          DerivationTree.weakening [] _ _ h_efq_thm (by intro; simp)
        exact DerivationTree.modus_ponens _ _ _ h_efq h_bot
      exact deduction_theorem [φ] φ.neg ψ h_inner
    have h_sub : ∀ χ ∈ [φ], χ ∈ S := by simp [h_phi]
    exact set_mcs_closed_under_derivation h_mcs [φ] h_sub h_deriv
  | inr h_psi =>
    -- ψ ∈ S. We derive (¬φ → ψ) from the axiom ψ → (¬φ → ψ).
    have h_deriv : DerivationTree [ψ] (φ.or ψ) := by
      -- ψ → (φ.neg → ψ) is prop_s axiom (φ → (ψ → φ)) instantiated as ψ → (φ.neg → ψ)
      have h_prop_s_thm : [] ⊢ ψ.imp (φ.neg.imp ψ) :=
        DerivationTree.axiom [] _ (Axiom.prop_s ψ φ.neg)
      have h_prop_s : [ψ] ⊢ ψ.imp (φ.neg.imp ψ) :=
        DerivationTree.weakening [] _ _ h_prop_s_thm (by intro; simp)
      have h_psi_assume : [ψ] ⊢ ψ :=
        DerivationTree.assumption _ _ (by simp)
      exact DerivationTree.modus_ponens _ _ _ h_prop_s h_psi_assume
    have h_sub : ∀ χ ∈ [ψ], χ ∈ S := by simp [h_psi]
    exact set_mcs_closed_under_derivation h_mcs [ψ] h_sub h_deriv

/--
Set-based MCS: disjunction property (backward direction).

If (φ ∨ ψ) ∈ S, then φ ∈ S or ψ ∈ S.
-/
theorem set_mcs_disjunction_elim {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : (φ.or ψ) ∈ S) : φ ∈ S ∨ ψ ∈ S := by
  -- By negation completeness: either φ ∈ S or φ.neg ∈ S
  cases set_mcs_negation_complete h_mcs φ with
  | inl h_phi => exact Or.inl h_phi
  | inr h_neg_phi =>
    -- φ.neg ∈ S and (φ.or ψ) = (φ.neg.imp ψ) ∈ S
    -- By modus ponens: ψ ∈ S
    right
    exact set_mcs_implication_property h_mcs h h_neg_phi

/--
Set-based MCS: disjunction iff property.

(φ ∨ ψ) ∈ S iff (φ ∈ S or ψ ∈ S).
-/
theorem set_mcs_disjunction_iff {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    (φ.or ψ) ∈ S ↔ (φ ∈ S ∨ ψ ∈ S) :=
  ⟨set_mcs_disjunction_elim h_mcs, set_mcs_disjunction_intro h_mcs⟩

/--
Set-based MCS: conjunction property (forward direction).

If φ ∈ S and ψ ∈ S, then (φ ∧ ψ) ∈ S.
Note: `φ.and ψ = (φ.imp ψ.neg).neg`
-/
theorem set_mcs_conjunction_intro {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_phi : φ ∈ S) (h_psi : ψ ∈ S) : (φ.and ψ) ∈ S := by
  -- φ.and ψ = (φ.imp ψ.neg).neg
  -- We need (φ.imp ψ.neg).neg ∈ S
  -- By negation completeness, either (φ.imp ψ.neg) ∈ S or (φ.imp ψ.neg).neg ∈ S
  -- Assume (φ.imp ψ.neg) ∈ S. Then with φ ∈ S, by implication property: ψ.neg ∈ S.
  -- But ψ ∈ S, and ψ.neg = ψ.imp ⊥ ∈ S would give ⊥ ∈ S, contradiction.
  cases set_mcs_negation_complete h_mcs (φ.imp ψ.neg) with
  | inr h_neg => exact h_neg
  | inl h_imp =>
    -- (φ → ¬ψ) ∈ S and φ ∈ S, so ¬ψ ∈ S
    have h_neg_psi : ψ.neg ∈ S := set_mcs_implication_property h_mcs h_imp h_phi
    -- ψ ∈ S and ¬ψ ∈ S gives ⊥ derivable from S
    -- This contradicts consistency
    exfalso
    have h_deriv : DerivationTree [ψ, ψ.neg] Formula.bot := by
      have h_psi_assume : [ψ, ψ.neg] ⊢ ψ :=
        DerivationTree.assumption _ _ (by simp)
      have h_neg_assume : [ψ, ψ.neg] ⊢ ψ.neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h_psi_assume h_neg_assume
    have h_sub : ∀ χ ∈ [ψ, ψ.neg], χ ∈ S := by
      intro χ h_mem
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at h_mem
      cases h_mem with
      | inl h_eq => exact h_eq ▸ h_psi
      | inr h_eq => exact h_eq ▸ h_neg_psi
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs [ψ, ψ.neg] h_sub h_deriv
    -- ⊥ ∈ S contradicts consistency of S
    have h_cons := h_mcs.1
    unfold SetConsistent at h_cons
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    have h_bot_sub : ∀ χ ∈ [Formula.bot], χ ∈ S := by simp [h_bot_in_S]
    exact h_cons [Formula.bot] h_bot_sub ⟨h_bot_deriv⟩

/--
Set-based MCS: conjunction property (backward direction).

If (φ ∧ ψ) ∈ S, then φ ∈ S and ψ ∈ S.
-/
theorem set_mcs_conjunction_elim {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : (φ.and ψ) ∈ S) : φ ∈ S ∧ ψ ∈ S := by
  -- (φ.and ψ) = (φ.imp ψ.neg).neg ∈ S
  -- This means φ → ¬ψ ∉ S (otherwise its negation wouldn't be there)
  -- By negation completeness and the fact that (φ → ¬ψ).neg ∈ S:
  -- If (φ → ¬ψ) ∈ S, then (φ → ¬ψ).neg ∉ S (else both in, inconsistent)
  -- So (φ → ¬ψ) ∉ S
  -- Now we show φ ∈ S:
  -- Suppose φ ∉ S. Then φ.neg ∈ S by negation completeness.
  -- We show this leads to (φ → ¬ψ) derivable from {φ.neg}, which would put it in S
  -- Actually, we derive φ → ¬ψ from ¬φ via: ¬φ → (φ → ¬ψ) which is a tautology
  -- Let's verify: from ¬φ, assume φ, then we have φ and ¬φ, derive ⊥, derive anything
  constructor
  · -- Show φ ∈ S
    by_contra h_phi_not
    have h_neg_phi : φ.neg ∈ S := by
      cases set_mcs_negation_complete h_mcs φ with
      | inl h => exact absurd h h_phi_not
      | inr h => exact h
    -- From φ.neg we derive φ.imp ψ.neg
    have h_deriv : DerivationTree [φ.neg] (φ.imp ψ.neg) := by
      -- Need: [¬φ] ⊢ φ → ¬ψ
      -- By deduction theorem: need φ :: [¬φ] ⊢ ¬ψ
      have h_inner : DerivationTree (φ :: [φ.neg]) ψ.neg := by
        -- From φ and ¬φ we get ⊥, then ¬ψ = ψ → ⊥ via K1 and constant function
        have h_phi_assume : (φ :: [φ.neg]) ⊢ φ :=
          DerivationTree.assumption _ _ (by simp)
        have h_neg_assume : (φ :: [φ.neg]) ⊢ φ.neg :=
          DerivationTree.assumption _ _ (by simp)
        have h_bot : (φ :: [φ.neg]) ⊢ Formula.bot :=
          derives_bot_from_phi_neg_phi h_phi_assume h_neg_assume
        -- ¬ψ = ψ → ⊥. Need: (φ :: [φ.neg]) ⊢ ψ → ⊥
        -- Use deduction theorem: need ψ :: φ :: [φ.neg] ⊢ ⊥
        -- We already have h_bot, weaken it
        have h_bot_weak : (ψ :: φ :: [φ.neg]) ⊢ Formula.bot :=
          DerivationTree.weakening (φ :: [φ.neg]) (ψ :: φ :: [φ.neg]) _ h_bot
            (fun x hx => List.mem_cons_of_mem ψ hx)
        exact deduction_theorem (φ :: [φ.neg]) ψ Formula.bot h_bot_weak
      exact deduction_theorem [φ.neg] φ ψ.neg h_inner
    have h_sub : ∀ χ ∈ [φ.neg], χ ∈ S := by simp [h_neg_phi]
    have h_imp_in : (φ.imp ψ.neg) ∈ S :=
      set_mcs_closed_under_derivation h_mcs [φ.neg] h_sub h_deriv
    -- Now (φ.imp ψ.neg) ∈ S and (φ.imp ψ.neg).neg ∈ S, contradiction
    have h_deriv_bot : DerivationTree [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] Formula.bot := by
      have h1 : [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] ⊢ (φ.imp ψ.neg) :=
        DerivationTree.assumption _ _ (by simp)
      have h2 : [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] ⊢ (φ.imp ψ.neg).neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [(φ.imp ψ.neg), (φ.imp ψ.neg).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_imp_in
      | inr h_eq => exact h_eq ▸ h
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩
  · -- Show ψ ∈ S (similar argument)
    by_contra h_psi_not
    have h_neg_psi : ψ.neg ∈ S := by
      cases set_mcs_negation_complete h_mcs ψ with
      | inl h => exact absurd h h_psi_not
      | inr h => exact h
    -- From ψ.neg we derive φ.imp ψ.neg via prop_s: ψ.neg → (φ → ψ.neg)
    have h_deriv : DerivationTree [ψ.neg] (φ.imp ψ.neg) := by
      have h_prop_s_thm : [] ⊢ ψ.neg.imp (φ.imp ψ.neg) :=
        DerivationTree.axiom [] _ (Axiom.prop_s ψ.neg φ)
      have h_prop_s : [ψ.neg] ⊢ ψ.neg.imp (φ.imp ψ.neg) :=
        DerivationTree.weakening [] _ _ h_prop_s_thm (by intro; simp)
      have h_assume : [ψ.neg] ⊢ ψ.neg :=
        DerivationTree.assumption _ _ (by simp)
      exact DerivationTree.modus_ponens _ _ _ h_prop_s h_assume
    have h_sub : ∀ χ ∈ [ψ.neg], χ ∈ S := by simp [h_neg_psi]
    have h_imp_in : (φ.imp ψ.neg) ∈ S :=
      set_mcs_closed_under_derivation h_mcs [ψ.neg] h_sub h_deriv
    -- Now (φ.imp ψ.neg) ∈ S and (φ.imp ψ.neg).neg ∈ S, contradiction
    have h_deriv_bot : DerivationTree [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] Formula.bot := by
      have h1 : [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] ⊢ (φ.imp ψ.neg) :=
        DerivationTree.assumption _ _ (by simp)
      have h2 : [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] ⊢ (φ.imp ψ.neg).neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [(φ.imp ψ.neg), (φ.imp ψ.neg).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_imp_in
      | inr h_eq => exact h_eq ▸ h
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/--
Set-based MCS: conjunction iff property.

(φ ∧ ψ) ∈ S iff (φ ∈ S and ψ ∈ S).
-/
theorem set_mcs_conjunction_iff {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    (φ.and ψ) ∈ S ↔ (φ ∈ S ∧ ψ ∈ S) :=
  ⟨set_mcs_conjunction_elim h_mcs, fun ⟨h1, h2⟩ => set_mcs_conjunction_intro h_mcs h1 h2⟩

/-!
### Modal Closure Properties

These lemmas establish modal closure properties for SetMaximalConsistent sets,
using the Modal T axiom (□φ → φ) to derive that necessity implies truth.
-/

/--
Set-based MCS: box closure property.

If □φ ∈ S for a SetMaximalConsistent S, then φ ∈ S.

**Proof Strategy**:
1. Modal T axiom: □φ → φ
2. With □φ ∈ S, derive φ via modus ponens
3. By closure: φ ∈ S

This is a fundamental property: what is necessarily true is actually true.
-/
theorem set_mcs_box_closure {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_box : Formula.box φ ∈ S) : φ ∈ S := by
  -- Modal T axiom: □φ → φ
  have h_modal_t_thm : [] ⊢ (Formula.box φ).imp φ :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ)
  -- Weaken to context [□φ]
  have h_modal_t : [Formula.box φ] ⊢ (Formula.box φ).imp φ :=
    DerivationTree.weakening [] _ _ h_modal_t_thm (by intro; simp)
  -- Assume □φ in context
  have h_box_assume : [Formula.box φ] ⊢ Formula.box φ :=
    DerivationTree.assumption _ _ (by simp)
  -- Apply modus ponens to get φ
  have h_deriv : [Formula.box φ] ⊢ φ :=
    DerivationTree.modus_ponens _ _ _ h_modal_t h_box_assume
  -- By closure: φ ∈ S
  have h_sub : ∀ χ ∈ [Formula.box φ], χ ∈ S := by simp [h_box]
  exact set_mcs_closed_under_derivation h_mcs [Formula.box φ] h_sub h_deriv

/--
Set-based MCS: diamond-box duality (forward direction).

If ¬(□φ) ∈ S, then ◇(¬φ) ∈ S.

Note: ◇ψ = ¬□(¬ψ), so ◇(¬φ) = ¬□(¬¬φ).
-/
theorem set_mcs_neg_box_implies_diamond_neg {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : (Formula.box φ).neg ∈ S) : φ.neg.diamond ∈ S := by
  -- ◇(¬φ) = ¬□(¬¬φ)
  -- We have ¬□φ ∈ S. We need ¬□(¬¬φ) ∈ S.
  -- These are not directly equal, but we can derive the equivalence.
  -- Actually, ◇(¬φ) = (¬φ).neg.box.neg = ¬□(¬¬φ), which simplifies to ¬□φ
  -- if we have double negation elimination.
  -- But actually: ◇(¬φ) = (¬φ).diamond = ((¬φ).neg).box.neg = (φ.neg.neg).box.neg
  -- So ◇(¬φ) = ¬□(¬¬φ) = ¬□φ under double negation (classically).
  -- Let's prove: ¬□φ ↔ ◇¬φ classically.
  -- ◇¬φ = ¬□¬¬φ. So we need ¬□φ → ¬□¬¬φ.
  -- This follows from □¬¬φ → □φ (by □ distributing over →¬¬φ → φ).
  -- Actually, let's just unfold diamond: φ.neg.diamond = φ.neg.neg.box.neg
  -- We need to show: (φ.neg.neg).box.neg ∈ S
  -- By negation completeness: either (φ.neg.neg).box ∈ S or (φ.neg.neg).box.neg ∈ S
  -- If (φ.neg.neg).box ∈ S:
  --   We can derive (φ.neg.neg).box → φ.box (using □(¬¬φ → φ) and modal K distribution)
  --   Then φ.box ∈ S, contradicting (φ.box).neg ∈ S
  -- So (φ.neg.neg).box.neg ∈ S
  unfold Formula.diamond
  cases set_mcs_negation_complete h_mcs (φ.neg.neg.box) with
  | inr h_neg => exact h_neg
  | inl h_dne_box =>
    -- □(¬¬φ) ∈ S. We derive □φ from this, contradicting ¬□φ ∈ S.
    exfalso
    -- We need: □(¬¬φ → φ) which by Modal K gives □(¬¬φ) → □φ
    -- First, derive ¬¬φ → φ (double negation elimination)
    have h_dne : ⊢ φ.neg.neg.imp φ := double_negation φ
    -- Apply necessitation to get □(¬¬φ → φ)
    have h_nec_dne : ⊢ (φ.neg.neg.imp φ).box := DerivationTree.necessitation _ h_dne
    -- Modal K distribution: □(A → B) → (□A → □B)
    have h_modal_k : ⊢ (φ.neg.neg.imp φ).box.imp ((φ.neg.neg.box).imp (φ.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.neg φ)
    -- Apply modus ponens to get □(¬¬φ) → □φ
    have h_impl : ⊢ (φ.neg.neg.box).imp (φ.box) :=
      DerivationTree.modus_ponens [] _ _ h_modal_k h_nec_dne
    -- Now we have □(¬¬φ) ∈ S and □(¬¬φ) → □φ derivable
    -- So □φ ∈ S
    have h_sub : ∀ χ ∈ [φ.neg.neg.box], χ ∈ S := by simp [h_dne_box]
    have h_impl_ctx : [φ.neg.neg.box] ⊢ (φ.neg.neg.box).imp (φ.box) :=
      DerivationTree.weakening [] _ _ h_impl (by intro; simp)
    have h_assume : [φ.neg.neg.box] ⊢ φ.neg.neg.box :=
      DerivationTree.assumption _ _ (by simp)
    have h_deriv : [φ.neg.neg.box] ⊢ φ.box :=
      DerivationTree.modus_ponens _ _ _ h_impl_ctx h_assume
    have h_box_in_S : φ.box ∈ S :=
      set_mcs_closed_under_derivation h_mcs [φ.neg.neg.box] h_sub h_deriv
    -- Now φ.box ∈ S and (φ.box).neg ∈ S, contradiction
    have h_deriv_bot : DerivationTree [φ.box, (φ.box).neg] Formula.bot := by
      have h1 : [φ.box, (φ.box).neg] ⊢ φ.box :=
        DerivationTree.assumption _ _ (by simp)
      have h2 : [φ.box, (φ.box).neg] ⊢ (φ.box).neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [φ.box, (φ.box).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_box_in_S
      | inr h_eq => exact h_eq ▸ h
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/--
Set-based MCS: diamond-box duality (backward direction).

If ◇(¬φ) ∈ S, then ¬(□φ) ∈ S.
-/
theorem set_mcs_diamond_neg_implies_neg_box {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : φ.neg.diamond ∈ S) : (Formula.box φ).neg ∈ S := by
  -- ◇(¬φ) = ¬□(¬¬φ) ∈ S
  -- We need ¬□φ ∈ S
  -- By negation completeness: either □φ ∈ S or ¬□φ ∈ S
  -- If □φ ∈ S, then by box_closure, φ ∈ S
  -- We show this leads to a contradiction with ◇(¬φ) ∈ S
  -- Actually, from □φ, we can derive □(¬¬φ) (since φ → ¬¬φ derivable)
  -- Then □(¬¬φ) ∈ S contradicts ¬□(¬¬φ) = ◇(¬φ) ∈ S
  unfold Formula.diamond at h
  cases set_mcs_negation_complete h_mcs (Formula.box φ) with
  | inr h_neg => exact h_neg
  | inl h_box =>
    -- □φ ∈ S. We derive □(¬¬φ), contradicting ¬□(¬¬φ) ∈ S.
    exfalso
    -- We need: □(φ → ¬¬φ) which by Modal K gives □φ → □(¬¬φ)
    -- First derive φ → ¬¬φ (double negation introduction)
    have h_dni : ⊢ φ.imp φ.neg.neg := dni φ
    -- Apply necessitation
    have h_nec_dni : ⊢ (φ.imp φ.neg.neg).box := DerivationTree.necessitation _ h_dni
    -- Modal K distribution: □(A → B) → (□A → □B)
    have h_modal_k : ⊢ (φ.imp φ.neg.neg).box.imp ((φ.box).imp (φ.neg.neg.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist φ φ.neg.neg)
    -- Apply modus ponens to get □φ → □(¬¬φ)
    have h_impl : ⊢ (φ.box).imp (φ.neg.neg.box) :=
      DerivationTree.modus_ponens [] _ _ h_modal_k h_nec_dni
    -- Now we have □φ ∈ S and □φ → □(¬¬φ) derivable
    -- So □(¬¬φ) ∈ S
    have h_sub : ∀ χ ∈ [φ.box], χ ∈ S := by simp [h_box]
    have h_impl_ctx : [φ.box] ⊢ (φ.box).imp (φ.neg.neg.box) :=
      DerivationTree.weakening [] _ _ h_impl (by intro; simp)
    have h_assume : [φ.box] ⊢ φ.box :=
      DerivationTree.assumption _ _ (by simp)
    have h_deriv : [φ.box] ⊢ φ.neg.neg.box :=
      DerivationTree.modus_ponens _ _ _ h_impl_ctx h_assume
    have h_dne_box_in_S : φ.neg.neg.box ∈ S :=
      set_mcs_closed_under_derivation h_mcs [φ.box] h_sub h_deriv
    -- Now φ.neg.neg.box ∈ S and (φ.neg.neg.box).neg ∈ S, contradiction
    have h_deriv_bot : DerivationTree [φ.neg.neg.box, (φ.neg.neg.box).neg] Formula.bot := by
      have h1 : [φ.neg.neg.box, (φ.neg.neg.box).neg] ⊢ φ.neg.neg.box :=
        DerivationTree.assumption _ _ (by simp)
      have h2 : [φ.neg.neg.box, (φ.neg.neg.box).neg] ⊢ (φ.neg.neg.box).neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [φ.neg.neg.box, (φ.neg.neg.box).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_dne_box_in_S
      | inr h_eq => exact h_eq ▸ h
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/--
Set-based MCS: diamond-box duality iff property.

¬(□φ) ∈ S iff ◇(¬φ) ∈ S.

This establishes the classical duality between box and diamond:
¬□φ ↔ ◇¬φ (equivalently, □φ ↔ ¬◇¬φ).
-/
theorem set_mcs_diamond_box_duality {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    (Formula.box φ).neg ∈ S ↔ φ.neg.diamond ∈ S :=
  ⟨set_mcs_neg_box_implies_diamond_neg h_mcs, set_mcs_diamond_neg_implies_neg_box h_mcs⟩

/-!
### Saturation Lemmas (Stubs)

These lemmas characterize the saturation properties of maximal consistent sets
for modal and temporal operators. They are essential for the truth lemma.

**Dependencies**:
- Modal saturation: Requires canonical frame construction (Task 447)
- Temporal saturation: Requires canonical history construction (Task 450)

The forward directions are proven where possible; backward directions are
left as `sorry` placeholders pending the dependent phases.
-/

/--
Modal saturation (forward): If □φ ∈ S, then φ holds at all accessible worlds.

**Statement**: For all T accessible from S via canonical_task_rel at time 0,
if □φ ∈ S then φ ∈ T.

**Note**: This follows from the box closure property: □φ ∈ S implies φ ∈ S
by Modal T, and the task relation transfers this appropriately.

**Full Version** (with canonical frame):
```
SetMaximalConsistent S →
  (□φ ∈ S ↔ ∀ T : CanonicalWorldState, canonical_task_rel S 0 T → φ ∈ T.val)
```
-/
theorem set_mcs_modal_saturation_forward {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_box : Formula.box φ ∈ S) : φ ∈ S :=
  -- Forward direction: Use box closure (Modal T axiom)
  set_mcs_box_closure h_mcs h_box

/--
Modal saturation (backward): If φ holds at all accessible worlds, then □φ ∈ S.

**Status**: STUB - requires canonical frame construction (Task 447)

**Proof Strategy** (to be implemented):
1. Assume for all T : CanonicalWorldState, canonical_task_rel S 0 T → φ ∈ T.val
2. By contrapositive: assume □φ ∉ S
3. Then (□φ).neg ∈ S by negation completeness
4. Construct witness T where ¬φ ∈ T.val, contradicting the assumption
5. The witness construction requires the canonical frame from Task 447

**Dependencies**: Task 447 (Canonical Frame Construction)
-/
theorem set_mcs_modal_saturation_backward {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_all : ∀ T : {T : Set Formula // SetMaximalConsistent T},
      -- Placeholder for canonical_task_rel S 0 T condition
      True →
      φ ∈ T.val) :
    Formula.box φ ∈ S := by
  -- STUB: Requires canonical frame construction (Task 447)
  -- The proof needs to construct a witness world from ¬□φ ∈ S
  sorry

/--
Temporal future saturation (stub): Fφ ∈ S iff φ holds at some future time.

**Status**: STUB - requires canonical history construction (Task 450)

**Full Statement**:
```
SetMaximalConsistent S →
  (Fφ ∈ S ↔ ∃ t > 0, ∃ h : WorldHistory, φ ∈ (history_at h t).val)
```

**Proof Strategy** (to be implemented):
- Forward: If Fφ ∈ S, construct a future world where φ holds
- Backward: If φ holds at some future time, derive Fφ ∈ S

**Dependencies**: Task 450 (Canonical History Construction)
-/
theorem set_mcs_temporal_future_saturation {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    Formula.all_future φ ∈ S ↔
      -- Placeholder condition: true for now, will be replaced with proper temporal semantics
      (∀ T : {T : Set Formula // SetMaximalConsistent T}, True → φ ∈ T.val) := by
  -- STUB: Requires canonical history construction (Task 450)
  sorry

/--
Temporal past saturation (stub): Hφ ∈ S iff φ holds at some past time.

**Status**: STUB - requires canonical history construction (Task 450)

**Full Statement**:
```
SetMaximalConsistent S →
  (Hφ ∈ S ↔ ∃ t < 0, ∃ h : WorldHistory, φ ∈ (history_at h t).val)
```

**Proof Strategy** (to be implemented):
- Forward: If Hφ ∈ S, construct a past world where φ holds
- Backward: If φ holds at some past time, derive Hφ ∈ S

**Dependencies**: Task 450 (Canonical History Construction)
-/
theorem set_mcs_temporal_past_saturation {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    Formula.all_past φ ∈ S ↔
      -- Placeholder condition: true for now, will be replaced with proper temporal semantics
      (∀ T : {T : Set Formula // SetMaximalConsistent T}, True → φ ∈ T.val) := by
  -- STUB: Requires canonical history construction (Task 450)
  sorry

/-!
## Canonical Frame

The canonical frame is constructed from maximal consistent sets.
-/

/--
Canonical world states are set-based maximal consistent sets.

**Representation**: Type synonym for `{S : Set Formula // SetMaximalConsistent S}`

**Justification**: Each maximal consistent set represents a "possible world"
describing one complete, consistent way the universe could be. Using `Set Formula`
instead of `List Formula` is essential because maximal consistent sets are typically
infinite, while lists are finite. The set-based `set_lindenbaum` theorem (proven
using Zorn's lemma) ensures every consistent set can be extended to a maximal one.

**Note**: The list-based `Context` representation cannot capture true maximal
consistency because lists are inherently finite.
-/
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}

/--
Canonical time structure uses integers.

**Justification**: Integers form an ordered additive group, required for
temporal operators (past/future) and task relation compositionality.
-/
def CanonicalTime : Type := Int

/--
Canonical task relation between set-based world states.

**Definition**: `task_rel S t T` holds iff all formulas of certain modal/temporal
forms transfer appropriately between S and T relative to time offset t.

where `S, T : CanonicalWorldState` are set-based maximal consistent sets.

**Properties** (to be proven):
- Nullity: `task_rel S 0 S`
- Compositionality: `task_rel S t₁ T → task_rel T t₂ U → task_rel S (t₁+t₂) U`

**Full Definition** (to be implemented):
```
task_rel S t T ↔
  (∀ φ, □φ ∈ S.val → φ ∈ T.val) ∧           -- Modal transfer
  (t > 0 → ∀ φ, Fφ ∈ S.val → φ ∈ T.val) ∧   -- Future transfer (positive time)
  (t < 0 → ∀ φ, Pφ ∈ S.val → φ ∈ T.val)     -- Past transfer (negative time)
```

**Note**: The set-based representation allows membership testing for potentially
infinite sets, which is essential for the canonical model construction.
-/
axiom canonical_task_rel : CanonicalWorldState → CanonicalTime → CanonicalWorldState → Prop

/--
The canonical frame for TM logic using set-based maximal consistent sets.

**Construction**: Combines set-based maximal consistent sets, integers, and task relation.

**Proof Obligations**:
- Show `canonical_task_rel` satisfies nullity
- Show `canonical_task_rel` satisfies compositionality

**Note**: `CanonicalWorldState` is now `{S : Set Formula // SetMaximalConsistent S}`,
using the set-based consistency definitions that allow true maximality.
-/
axiom canonical_frame : TaskFrame Int
  -- where
  --   WorldState := CanonicalWorldState
  --   Time := CanonicalTime
  --   time_group := Int.orderedAddCommGroup
  --   task_rel := canonical_task_rel
  --   nullity := sorry  -- Prove: ∀ w, task_rel w 0 w
  --   compositionality := sorry  -- Prove composition property

/-!
## Canonical Model and Valuation

The canonical model assigns truth values to atomic propositions based on
membership in maximal consistent sets.
-/

/--
Canonical valuation: An atom is true at a world state iff it's in the
set-based maximal consistent set.

**Definition**: `canonical_val S p ↔ (Formula.atom p) ∈ S.val`

where `S : CanonicalWorldState` is a set-based maximal consistent set
(subtype of `Set Formula`).

**Justification**: This makes atomic formulas "true by definition" in their
maximal consistent sets, enabling the truth lemma. The set-based representation
ensures we can express true maximality (every formula or its negation is in the set).
-/
axiom canonical_valuation : CanonicalWorldState → String → Bool

/--
The canonical model for TM logic.

**Construction**: Canonical frame with canonical valuation.
-/
axiom canonical_model : TaskModel canonical_frame
  -- where
  --   valuation := canonical_valuation

/-!
## Canonical World Histories

World histories in the canonical model map times to set-based maximal consistent sets.
-/

/--
A canonical world history is constructed from a set-based maximal consistent set.

**Construction** (planned):
- Domain: All integers (representing all times)
- States: Map each time `t` to a set-based maximal consistent set Sₜ
- Convexity: Automatically satisfied (domain = ℤ)
- Task relation respect: By construction of canonical_task_rel

**Complexity**: Requires showing histories respect task relation.

**Note**: `S : CanonicalWorldState` is now a set-based maximal consistent set
(`{S : Set Formula // SetMaximalConsistent S}`), which is the mathematically
correct representation for completeness proofs.
-/
axiom canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame

/-!
## Truth Lemma

The truth lemma establishes the correspondence between syntactic membership
and semantic truth in the canonical model.
-/

/--
**Truth Lemma**: In the canonical model, a formula φ is true at a set-based maximal
consistent set S and time t if and only if an appropriate time-shifted
version of φ is in S.

**Statement**: `φ ∈ S.val ↔ truth_at canonical_model (canonical_history S) 0 φ`

where `S : CanonicalWorldState` is a set-based maximal consistent set
(subtype of `Set Formula`), and `S.val : Set Formula` is the underlying set.

**Proof Strategy** (to be implemented):
By induction on formula structure:
- **Base (atom)**: By definition of canonical_valuation
- **Bottom**: `⊥ ∉ S` by consistency; `¬(M ⊨ ⊥)` by truth definition
- **Implication**: Use set-based maximal consistent implication property
- **Box**: Use modal saturation property of maximal sets
- **Past**: Use temporal consistency backward
- **Future**: Use temporal consistency forward

**Complexity**: ~25-30 hours (most complex proof in completeness)

**Dependencies**:
- Modal saturation lemma (for set-based maximal consistent sets)
- Temporal consistency lemmas
- Properties of set-based maximal consistent sets (from `set_lindenbaum`)

**Note**: Full truth lemma requires dependent type handling for WorldHistory.
The set-based representation ensures true maximality (every formula or its
negation is in the set), which is essential for the proof.
-/
axiom truth_lemma (S : CanonicalWorldState) (φ : Formula) :
  φ ∈ S.val -- Canonical model truth correspondence (placeholder)

/-!
## Completeness Theorems

The main results connecting semantic validity with syntactic derivability.
-/

/--
**Weak Completeness**: Every valid formula is provable.

**Statement**: `valid φ → DerivationTree [] φ`

Equivalently: `(∀ F M τ t, truth_at M τ t φ) → (⊢ φ)`

**Proof Strategy**:
1. Assume `valid φ` (i.e., `∀ F M τ t, truth_at M τ t φ`)
2. Assume (for contradiction) `¬(⊢ φ)`
3. Then `[]` is consistent (else would derive everything including φ)
4. By Lindenbaum, extend `[]` to maximal consistent Γ
5. Since `¬(Γ ⊢ φ)` and Γ closed, `φ ∉ Γ`
6. Build canonical model M_can with Γ
7. By truth lemma, `¬(M_can ⊨ φ)` at Γ
8. Contradicts validity of φ
9. Therefore `⊢ φ`

**Complexity**: ~10-15 hours (builds on truth lemma)
-/
axiom weak_completeness (φ : Formula) : valid φ → DerivationTree [] φ

/--
**Strong Completeness**: Semantic consequence implies syntactic derivability.

**Statement**: `semantic_consequence Γ φ → DerivationTree Γ φ`

Equivalently: `(∀ F M τ t, (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ) → (Γ ⊢ φ)`

**Proof Strategy**:
1. Assume `Γ ⊨ φ` and (for contradiction) `¬(Γ ⊢ φ)`
2. Then `Γ ∪ {¬φ}` is consistent (else `Γ ⊢ φ`)
3. Extend to maximal consistent Δ ⊇ Γ ∪ {¬φ}
4. Build canonical model M_can with Δ
5. By truth lemma, all formulas in Γ true at Δ, but φ false
6. Contradicts `Γ ⊨ φ`
7. Therefore `Γ ⊢ φ`

**Complexity**: ~10-15 hours (similar to weak completeness)
-/
axiom strong_completeness (Γ : Context) (φ : Formula) :
  semantic_consequence Γ φ → DerivationTree Γ φ

/-!
## Decidability (Optional Extension)

Completeness + Soundness enable decidability results.
-/

/--
**Soundness-Completeness Equivalence**: Provability and validity are equivalent.

**Statement**: `(⊢ φ) ↔ (⊨ φ)`

**Proof**: Combine `soundness` and `weak_completeness`.
-/
theorem provable_iff_valid (φ : Formula) : Nonempty (DerivationTree [] φ) ↔ valid φ := by
  constructor
  · intro ⟨h⟩
    -- Soundness direction
    have sem_conseq := soundness [] φ h
    -- semantic_consequence [] φ is equivalent to valid φ
    sorry
  · intro h
    exact ⟨weak_completeness φ h⟩

/-!
## Future Work: Decidability

With completeness proven, decidability can be established via:

1. **Finite Model Property**: Every satisfiable formula has a finite model
2. **Tableau Method**: Systematic search for satisfying models
3. **Decision Procedure**: Bounded tableau search decides validity

This is beyond Layer 0 scope but enabled by completeness proof.
-/

end Bimodal.Metalogic
