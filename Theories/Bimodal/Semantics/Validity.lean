import Bimodal.Semantics.Truth
import Bimodal.Syntax.Context

/-!
# Validity - Semantic Validity and Consequence

This module defines semantic validity and consequence for TM formulas.

## Main Definitions

- `valid`: A formula is valid if true in all models with shift-closed Omega
- `semantic_consequence`: Semantic consequence relation (with shift-closed Omega)
- `satisfiable`: A context is satisfiable if consistent (exists some temporal type)
- Notation: `⊨ φ` for validity, `Γ ⊨ φ` for semantic consequence

## Main Results

- Basic validity lemmas
- Relationship between validity and semantic consequence

## Implementation Notes

- Validity quantifies over all temporal types `D : Type*` with `LinearOrderedAddCommGroup D`
- Validity and consequence quantify over all shift-closed Omega and histories in Omega
- This parameterization is equivalent to using `Set.univ` (since `Set.univ` is shift-closed)
  but enables completeness proofs to provide a matching Omega
- Satisfiability existentially quantifies over Omega with a membership constraint `τ ∈ Omega`
- Semantic consequence: truth in all models where premises true
- Used in soundness theorem: `Γ ⊢ φ → Γ ⊨ φ`
- Temporal types include Int, Rat, Real, and custom bounded types

## Paper Alignment

JPL paper §app:TaskSemantics defines validity as truth at all task frames with totally ordered
abelian group D = ⟨D, +, ≤⟩. Our polymorphic quantification over `LinearOrderedAddCommGroup D`
captures this exactly. The ShiftClosed Omega condition ensures time-shift invariance holds,
which is implicit in the paper's use of the full universe of histories.

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - Validity specification
* [Truth.lean](Truth.lean) - Truth evaluation
* [Context.lean](../Syntax/Context.lean) - Proof contexts
-/

namespace Bimodal.Semantics

open Bimodal.Syntax

/--
A formula is valid if it is true in all models at all times in all histories within
any shift-closed set of histories, for every temporal type `D` satisfying
`LinearOrderedAddCommGroup`.

Formally: for every temporal type `D`, every task frame `F : TaskFrame D`,
every model `M` over `F`, every shift-closed set `Omega` of histories,
every history `τ ∈ Omega`, and every time `t : D`,
the formula is true at `(M, Omega, τ, t)`.

The `ShiftClosed Omega` condition ensures that time-shift invariance properties
hold, which is required for soundness of the MF and TF axioms. This condition
is equivalent to the standard definition using `Set.univ` (since `Set.univ` is
trivially shift-closed and `τ ∈ Set.univ` holds for all `τ`), but enables
completeness proofs to provide a matching Omega.

**Paper Reference (lines 924, 2272-2273)**: Logical consequence quantifies over
all `x ∈ D` (all times in the temporal order), not just times in dom(τ).

Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs.
-/
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ

/--
Notation for validity: `⊨ φ` means `valid φ`.
-/
notation:50 "⊨ " φ:50 => valid φ

/--
Semantic consequence: `Γ ⊨ φ` means φ is true in all models where all of `Γ` are true,
for every temporal type `D` satisfying `LinearOrderedAddCommGroup`.

Formally: for every temporal type `D`, for every model-history-time with shift-closed Omega
where all formulas in `Γ` are true, formula `φ` is also true.

**Paper Reference (lines 924, 2272-2273)**: Logical consequence quantifies over
all `x ∈ D` (all times in the temporal order), not just times in dom(τ).

Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs.
-/
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) →
    truth_at M Omega τ t φ

/--
Notation for semantic consequence: `Γ ⊨ φ`.
-/
notation:50 Γ:50 " ⊨ " φ:50 => semantic_consequence Γ φ

/--
A context is satisfiable in temporal type `D` if there exists a model where all formulas
in the context are true.

Existentially quantifies over a set of admissible histories `Omega` and requires
the witness history `τ ∈ Omega`. This ensures satisfiability witnesses are
consistent with the Omega parameter in `truth_at`.

This is the semantic notion of consistency relative to a temporal type.
For absolute satisfiability (exists in some type), use `∃ D, satisfiable D Γ`.

**Note**: Satisfiability quantifies over all times `t : D`, not just domain times.
-/
def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (Γ : Context) : Prop :=
  ∃ (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    ∀ φ ∈ Γ, truth_at M Omega τ t φ

/--
A context is absolutely satisfiable if it is satisfiable in some temporal type.
-/
def satisfiable_abs (Γ : Context) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D), satisfiable D Γ

/--
A single formula is satisfiable if there exists a model where it is true at some point.

This is the single-formula version of `satisfiable` (which works on contexts).
A formula is satisfiable if there exists some temporal type D, some task frame,
some model, some world history, and some time where the formula evaluates to true.

**Usage**: Used in the Finite Model Property to connect formula satisfiability
to the existence of finite models.

**Relationship to Context Satisfiability**:
`formula_satisfiable φ ↔ satisfiable Int [φ]` (for Int time, but holds for any D)
-/
def formula_satisfiable (φ : Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ

namespace Validity

/--
Valid formulas are semantic consequences of empty context.
-/
theorem valid_iff_empty_consequence (φ : Formula) :
    (⊨ φ) ↔ ([] ⊨ φ) := by
  constructor
  · intro h D _ _ _ F M Omega h_sc τ h_mem t _
    exact h D F M Omega h_sc τ h_mem t
  · intro h D _ _ _ F M Omega h_sc τ h_mem t
    exact h D F M Omega h_sc τ h_mem t (by intro ψ hψ; exact absurd hψ List.not_mem_nil)

/--
Semantic consequence is monotonic: adding premises preserves consequences.
-/
theorem consequence_monotone {Γ Δ : Context} {φ : Formula} :
    Γ ⊆ Δ → (Γ ⊨ φ) → (Δ ⊨ φ) := by
  intro h_sub h_cons D _ _ _ F M Omega h_sc τ h_mem t h_delta
  apply h_cons D F M Omega h_sc τ h_mem t
  intro ψ hψ
  exact h_delta ψ (h_sub hψ)

/--
If a formula is valid, it is a semantic consequence of any context.
-/
theorem valid_consequence (φ : Formula) (Γ : Context) :
    (⊨ φ) → (Γ ⊨ φ) :=
  fun h D _ _ _ F M Omega h_sc τ h_mem t _ => h D F M Omega h_sc τ h_mem t

/--
Context with all formulas true implies each formula individually true.
-/
theorem consequence_of_member {Γ : Context} {φ : Formula} :
    φ ∈ Γ → (Γ ⊨ φ) := by
  intro h _ _ _ _ F M Omega h_sc τ h_mem t h_all
  exact h_all φ h

/--
Unsatisfiable context (in ALL temporal types) semantically implies anything.
This is the correct formulation for polymorphic validity: if a context is
unsatisfiable in every temporal type, then it implies anything.

Note: For the weaker statement that unsatisfiability in a SPECIFIC type implies
consequence in that type, see `unsatisfiable_implies_all_fixed`.
-/
theorem unsatisfiable_implies_all {Γ : Context} {φ : Formula} :
    (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D], ¬satisfiable D Γ) → (Γ ⊨ φ) :=
  fun h_unsat D _ _ _ F M Omega _h_sc τ h_mem t h_all =>
    absurd ⟨F, M, Omega, τ, h_mem, t, h_all⟩ (h_unsat D)

/--
Unsatisfiable context in a fixed temporal type implies consequence in that type.
This is the type-specific version of explosion.
-/
theorem unsatisfiable_implies_all_fixed {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {Γ : Context} {φ : Formula} :
    ¬satisfiable D Γ → ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory F) (h_mem : τ ∈ Omega)
      (t : D), (∀ ψ ∈ Γ, truth_at M Omega τ t ψ) → truth_at M Omega τ t φ := by
  intro h_unsat F M Omega _h_sc τ h_mem t h_all
  exfalso
  apply h_unsat
  exact ⟨F, M, Omega, τ, h_mem, t, h_all⟩

end Validity

end Bimodal.Semantics
