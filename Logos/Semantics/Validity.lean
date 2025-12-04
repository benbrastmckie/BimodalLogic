import Logos.Semantics.Truth
import Logos.Syntax.Context

/-!
# Validity - Semantic Validity and Consequence

This module defines semantic validity and consequence for TM formulas.

## Main Definitions

- `valid`: A formula is valid if true in all models (quantifies over all temporal types)
- `semantic_consequence`: Semantic consequence relation (quantifies over all temporal types)
- `satisfiable`: A context is satisfiable if consistent (exists some temporal type)
- Notation: `⊨ φ` for validity, `Γ ⊨ φ` for semantic consequence

## Main Results

- Basic validity lemmas
- Relationship between validity and semantic consequence

## Implementation Notes

- Validity quantifies over all temporal types `T : Type*` with `LinearOrderedAddCommGroup T`
- Semantic consequence: truth in all models where premises true
- Used in soundness theorem: `Γ ⊢ φ → Γ ⊨ φ`
- Temporal types include Int, Rat, Real, and custom bounded types

## Paper Alignment

JPL paper §app:TaskSemantics defines validity as truth at all task frames with totally ordered
abelian group T = ⟨T, +, ≤⟩. Our polymorphic quantification over `LinearOrderedAddCommGroup T`
captures this exactly.

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - Validity specification
* [Truth.lean](Truth.lean) - Truth evaluation
* [Context.lean](../Syntax/Context.lean) - Proof contexts
-/

namespace Logos.Semantics

open Logos.Syntax

/--
A formula is valid if it is true in all models at all times in all histories,
for every temporal type `T` satisfying `LinearOrderedAddCommGroup`.

Formally: for every temporal type `T`, every task frame `F : TaskFrame T`,
every model `M` over `F`, every world history `τ`, every time `t : T` where
`τ.domain t`, the formula is true at `(M, τ, t)`.

This matches the JPL paper's definition where validity is relative to all
possible time groups T = ⟨T, +, ≤⟩.

Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs.
-/
def valid (φ : Formula) : Prop :=
  ∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    truth_at M τ t ht φ

/--
Notation for validity: `⊨ φ` means `valid φ`.
-/
notation:50 "⊨ " φ:50 => valid φ

/--
Semantic consequence: `Γ ⊨ φ` means φ is true in all models where all of `Γ` are true,
for every temporal type `T` satisfying `LinearOrderedAddCommGroup`.

Formally: for every temporal type `T`, for every model-history-time where all formulas
in `Γ` are true, formula `φ` is also true.

Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs.
-/
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    (∀ ψ ∈ Γ, truth_at M τ t ht ψ) →
    truth_at M τ t ht φ

/--
Notation for semantic consequence: `Γ ⊨ φ`.
-/
notation:50 Γ:50 " ⊨ " φ:50 => semantic_consequence Γ φ

/--
A context is satisfiable in temporal type `T` if there exists a model where all formulas
in the context are true.

This is the semantic notion of consistency relative to a temporal type.
For absolute satisfiability (exists in some type), use `∃ T, satisfiable T Γ`.
-/
def satisfiable (T : Type*) [LinearOrderedAddCommGroup T] (Γ : Context) : Prop :=
  ∃ (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    ∀ φ ∈ Γ, truth_at M τ t ht φ

/--
A context is absolutely satisfiable if it is satisfiable in some temporal type.
-/
def satisfiable_abs (Γ : Context) : Prop :=
  ∃ (T : Type) (_ : LinearOrderedAddCommGroup T), satisfiable T Γ

namespace Validity

/--
Valid formulas are semantic consequences of empty context.
-/
theorem valid_iff_empty_consequence (φ : Formula) :
    (⊨ φ) ↔ ([] ⊨ φ) := by
  constructor
  · intro h T inst F M τ t ht _
    exact h T F M τ t ht
  · intro h T inst F M τ t ht
    exact h T F M τ t ht (by intro ψ hψ; exact absurd hψ (List.not_mem_nil ψ))

/--
Semantic consequence is monotonic: adding premises preserves consequences.
-/
theorem consequence_monotone {Γ Δ : Context} {φ : Formula} :
    Γ ⊆ Δ → (Γ ⊨ φ) → (Δ ⊨ φ) := by
  intro h_sub h_cons T inst F M τ t ht h_delta
  apply h_cons T F M τ t ht
  intro ψ hψ
  exact h_delta ψ (h_sub hψ)

/--
If a formula is valid, it is a semantic consequence of any context.
-/
theorem valid_consequence (φ : Formula) (Γ : Context) :
    (⊨ φ) → (Γ ⊨ φ) :=
  fun h T _ F M τ t ht _ => h T F M τ t ht

/--
Context with all formulas true implies each formula individually true.
-/
theorem consequence_of_member {Γ : Context} {φ : Formula} :
    φ ∈ Γ → (Γ ⊨ φ) := by
  intro h _ _ F M τ t ht h_all
  exact h_all φ h

/--
Unsatisfiable context (in ALL temporal types) semantically implies anything.
This is the correct formulation for polymorphic validity: if a context is
unsatisfiable in every temporal type, then it implies anything.

Note: For the weaker statement that unsatisfiability in a SPECIFIC type implies
consequence in that type, see `unsatisfiable_implies_all_fixed`.
-/
theorem unsatisfiable_implies_all {Γ : Context} {φ : Formula} :
    (∀ (T : Type) [LinearOrderedAddCommGroup T], ¬satisfiable T Γ) → (Γ ⊨ φ) :=
  fun h_unsat T _ F M τ t ht h_all =>
    absurd ⟨F, M, τ, t, ht, h_all⟩ (h_unsat T)

/--
Unsatisfiable context in a fixed temporal type implies consequence in that type.
This is the type-specific version of explosion.
-/
theorem unsatisfiable_implies_all_fixed {T : Type*} [LinearOrderedAddCommGroup T]
    {Γ : Context} {φ : Formula} :
    ¬satisfiable T Γ → ∀ (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F)
      (t : T) (ht : τ.domain t), (∀ ψ ∈ Γ, truth_at M τ t ht ψ) → truth_at M τ t ht φ := by
  intro h_unsat F M τ t ht h_all
  exfalso
  apply h_unsat
  exact ⟨F, M, τ, t, ht, h_all⟩

end Validity

end Logos.Semantics
