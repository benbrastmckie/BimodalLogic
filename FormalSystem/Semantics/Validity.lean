/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.Syntax.Context
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean

/-!
# Validity - Semantic Validity and Consequence

This module defines semantic validity and consequence for TM formulas.

## Main Definitions

- `valid`: A formula is valid if true in all models with shift-closed Omega
- `SemanticConsequence`: Semantic consequence relation (with shift-closed Omega)
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

* [architecture.md](../../../docs/user-guide/architecture.md) - Validity specification
* [Truth.lean](Truth.lean) - Truth evaluation
* [Context.lean](../Syntax/Context.lean) - Proof contexts
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

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
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ

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
def SemanticConsequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) →
    TruthAt M Omega τ t φ

/--
Notation for semantic consequence: `Γ ⊨ φ`.
-/
notation:50 Γ:50 " ⊨ " φ:50 => SemanticConsequence Γ φ

/--
A context is satisfiable in temporal type `D` if there exists a model where all formulas
in the context are true.

Existentially quantifies over a set of admissible histories `Omega` and requires
the witness history `τ ∈ Omega`. This ensures satisfiability witnesses are
consistent with the Omega parameter in `TruthAt`.

This is the semantic notion of consistency relative to a temporal type.
For absolute satisfiability (exists in some type), use `∃ D, satisfiable D Γ`.

**Note**: Satisfiability quantifies over all times `t : D`, not just domain times.
-/
def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (Γ : Context) :
    Prop :=
  ∃ (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    ∀ φ ∈ Γ, TruthAt M Omega τ t φ

/--
A context is absolutely satisfiable if it is satisfiable in some temporal type.
-/
def SatisfiableAbs (Γ : Context) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D), satisfiable D Γ

/--
A single formula is satisfiable if there exists a model where it is true at some point.

This is the single-formula version of `satisfiable` (which works on contexts).
A formula is satisfiable if there exists some temporal type D, some task frame,
some model, some world history, and some time where the formula evaluates to true.

**Usage**: Used in the Finite Model Property to connect formula satisfiability
to the existence of finite models.

**Relationship to Context Satisfiability**:
`FormulaSatisfiable φ ↔ satisfiable Int [φ]` (for Int time, but holds for any D)
-/
def FormulaSatisfiable (φ : Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ

/--
A formula is valid over dense temporal orders if it is true in all models where D is
densely ordered, for all shift-closed Omega, all histories in Omega, and all times.

This restricts `valid` to temporal types with `DenselyOrdered D`, capturing the
frame condition for the density axiom DN: `F(phi) -> F(F(phi))`.

**Notation**: `⊨_dense φ`
-/
def ValidDense (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ

/--
A formula is valid over discrete temporal orders if it is true in all models where D
has successor and predecessor structure, for all shift-closed Omega, all histories
in Omega, and all times.

This restricts `valid` to temporal types with `SuccOrder D` and `PredOrder D`,
capturing the frame condition for the discreteness axioms DF/DP.

**Notation**: `⊨_discrete φ`
-/
def ValidDiscrete (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ

/--
A formula is valid over **Dedekind-complete** temporal orders if it is true in all models
whose temporal type `D` has the least-upper-bound property, for all shift-closed `Omega`,
all histories in `Omega`, and all times.

Dedekind completeness is expressed by the explicit Prop-valued hypothesis

  `∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`

rather than by swapping the tree's `[LinearOrder D]` binder for
`[ConditionallyCompleteLinearOrder D]`. This is deliberate and strictly less invasive: every
downstream `[LinearOrder D]`-indexed lemma continues to apply with no instance-unification
risk.

**`DenselyOrdered` is deliberately ABSENT from this binder list.** The integers carry a
Mathlib `ConditionallyCompleteLinearOrder` instance
(`Mathlib/Data/Int/ConditionallyCompleteOrder.lean`), so `ℤ` satisfies every binder of
`ValidDedekind`. Including density here would silently narrow the predicate to real flow
alone; the density-carrying variant is the separate `ValidDedekindDense` below.

**This predicate is NOT the target of `soundness_dedekind`, and that is not an oversight.**
`FrameClass.Dedekind` sits strictly above `FrameClass.Dense` (see the `FrameClass` docstring
in `FormalSystem/ProofSystem/Axioms.lean`), so `Axiom.density` (`GGφ → Gφ`) and
`Axiom.dense_indicator` (`¬U(⊤,⊥)`) are admissible in `DerivationTree FrameClass.Dedekind`.
Both are FALSE on `ℤ`: for `density`, take `φ` true exactly at times `≥ t + 2`, so `GGφ` holds
at `t` while `Gφ` fails; for `dense_indicator`, `U(⊤,⊥)` is true on `ℤ` because every point has
an immediate successor. Since `ℤ` also satisfies the binders above, a
`soundness_dedekind : DerivationTree .Dedekind … → ValidDedekind` would be refutable.
`soundness_dedekind` therefore targets `ValidDedekindDense`. This predicate is landed as the
strictly weaker statement and as the target of the forgetful bridge from `valid`.

**Source.** Reynolds 1992 (printed p.169) observes that the Prior axioms enforce only a
*definably* Dedekind-complete model: "there may be gaps in the order but ... you wouldn't know
that just looking at the behaviour of temporal formulas". So no single axiom characterises this
class; `Axiom.prior_U_gap` / `Axiom.prior_S_gap` / `Axiom.sep` are the definable-gap proxy.
-/
def ValidDedekind (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ

/--
A formula is valid over **dense Dedekind-complete** temporal orders: `ValidDedekind` with
`[DenselyOrdered D]` added to the binder list. This is the real-flow predicate — `ℝ` is the
paradigm model, and `ℤ` is excluded by the density binder.

**This is the target of `soundness_dedekind`**, not `ValidDedekind`. The reason is spelled out
in the `ValidDedekind` docstring above and is worth restating, because the weaker-looking
predicate is the wrong one: `FrameClass.Dedekind` lies above `FrameClass.Dense`, so `density`
and `dense_indicator` are admissible in a `.Dedekind` derivation, and both are false on `ℤ` —
which is Dedekind-complete. Do not "simplify" `soundness_dedekind` to target `ValidDedekind`;
the result would be refutable.

The placement of `Dedekind` above `Dense` is itself primary-source: Reynolds 1992 (printed
p.168) includes in US/R "axioms for density and no end points: `K⁺⊤`, `K⁻⊤`, `F⊤`, `P⊤`", and
`K⁺⊤ = ¬U(⊤,¬⊤) = ¬U(⊤,⊥)` is literally this tree's `Axiom.dense_indicator`.
-/
def ValidDedekindDense (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ

namespace Validity

/--
Validity implies validity over dense orders: every valid formula is ValidDense.
-/
theorem valid_implies_valid_dense {φ : Formula} (h : valid φ) : ValidDense φ := by
  intro D _ _ _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t

/--
Validity implies validity over discrete orders: every valid formula is ValidDiscrete.
-/
theorem valid_implies_valid_discrete {φ : Formula} (h : valid φ) : ValidDiscrete φ :=
  fun D _ _ _ _ _ _ _ _ F M Omega h_sc τ h_mem t => h D F M Omega h_sc τ h_mem t

/--
Validity implies validity over Dedekind-complete orders: every valid formula is
`ValidDedekind`. The least-upper-bound hypothesis is simply discarded — `valid` already
quantifies over every `D` satisfying the weaker binder set.
-/
theorem valid_implies_validDedekind {φ : Formula} (h : valid φ) : ValidDedekind φ :=
  fun D _ _ _ _ _ F M Omega h_sc τ h_mem t => h D F M Omega h_sc τ h_mem t

/--
Validity implies validity over dense Dedekind-complete orders: every valid formula is
`ValidDedekindDense`.
-/
theorem valid_implies_validDedekindDense {φ : Formula} (h : valid φ) : ValidDedekindDense φ :=
  fun D _ _ _ _ _ _ F M Omega h_sc τ h_mem t => h D F M Omega h_sc τ h_mem t

/--
`ValidDedekind` is strictly stronger than `ValidDedekindDense`: adding the `DenselyOrdered`
binder restricts the class of temporal types quantified over, so validity on all
Dedekind-complete orders entails validity on the dense ones.

This is the bridge that makes the SETTLED soundness target coherent: `soundness_dedekind`
proves the weaker `ValidDedekindDense`, and anything genuinely established at
`ValidDedekind` can be transported into it via this lemma.
-/
theorem validDedekindDense_of_validDedekind {φ : Formula} (h : ValidDedekind φ) :
    ValidDedekindDense φ :=
  fun D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t => h D h_lub F M Omega h_sc τ h_mem t

/--
Valid formulas are semantic consequences of empty context.
-/
theorem valid_iff_empty_consequence (φ : Formula) :
    (⊨ φ) ↔ ([] ⊨ φ) := by
  constructor
  · intro h D _ _ _ _ F M Omega h_sc τ h_mem t _
    exact h D F M Omega h_sc τ h_mem t
  · intro h D _ _ _ _ F M Omega h_sc τ h_mem t
    exact h D F M Omega h_sc τ h_mem t (by intro ψ hψ; exact absurd hψ List.not_mem_nil)

/--
Semantic consequence is monotonic: adding premises preserves consequences.
-/
theorem consequence_monotone {Γ Δ : Context} {φ : Formula} :
    Γ ⊆ Δ → (Γ ⊨ φ) → (Δ ⊨ φ) := by
  intro h_sub h_cons D _ _ _ _ F M Omega h_sc τ h_mem t h_delta
  apply h_cons D F M Omega h_sc τ h_mem t
  intro ψ hψ
  exact h_delta ψ (h_sub hψ)

/--
If a formula is valid, it is a semantic consequence of any context.
-/
theorem valid_consequence (φ : Formula) (Γ : Context) :
    (⊨ φ) → (Γ ⊨ φ) :=
  fun h D _ _ _ _ F M Omega h_sc τ h_mem t _ => h D F M Omega h_sc τ h_mem t

/--
Context with all formulas true implies each formula individually true.
-/
theorem consequence_of_member {Γ : Context} {φ : Formula} :
    φ ∈ Γ → (Γ ⊨ φ) := by
  intro h _ _ _ _ _ F M Omega h_sc τ h_mem t h_all
  exact h_all φ h

/--
Unsatisfiable context (in ALL temporal types) semantically implies anything.
This is the correct formulation for polymorphic validity: if a context is
unsatisfiable in every temporal type, then it implies anything.

Note: For the weaker statement that unsatisfiability in a SPECIFIC type implies
consequence in that type, see `unsatisfiable_implies_all_fixed`.
-/
theorem unsatisfiable_implies_all {Γ : Context} {φ : Formula} :
    (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D], ¬satisfiable D Γ) →
      (Γ ⊨ φ) :=
  fun h_unsat D _ _ _ _ F M Omega _h_sc τ h_mem t h_all =>
    absurd ⟨F, M, Omega, τ, h_mem, t, h_all⟩ (h_unsat D)

/--
Unsatisfiable context in a fixed temporal type implies consequence in that type.
This is the type-specific version of explosion.
-/
theorem unsatisfiable_implies_all_fixed {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D]
    {Γ : Context} {φ : Formula} :
    ¬satisfiable D Γ → ∀ (F : TaskFrame D) (M : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega)
      (t : D), (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ := by
  intro h_unsat F M Omega _h_sc τ h_mem t h_all
  exfalso
  apply h_unsat
  exact ⟨F, M, Omega, τ, h_mem, t, h_all⟩

/-! ### Validity Reduction Lemmas

These lemmas reduce validity of compound temporal/modal formulas to validity of
their subformulas. Relocated from the deleted `BXCanonical/CanonicalEmbedding.lean`.
-/

/--
If G(φ) is valid, then φ is valid.

Proof: G(φ) at time t means ∀ s ≥ t, TruthAt φ at s. Since t ≤ t (reflexive),
this gives TruthAt φ at t.
-/
theorem valid_of_valid_all_future {φ : Formula} (h : valid (Formula.allFuture φ)) :
    valid φ := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t
  -- G(φ) valid means ∀ t, ∀ s > t, φ(s). Pick r < t, then G(φ)(r) gives φ(t).
  have h_G := h D F M Omega h_sc τ h_mem
  obtain ⟨r, hrt⟩ := exists_lt t
  have := h_G r
  simp only [Truth.future_iff] at this
  exact this t hrt

/--
If H(φ) is valid, then φ is valid.
-/
theorem valid_of_valid_all_past {φ : Formula} (h : valid (Formula.allPast φ)) :
    valid φ := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t
  -- H(φ) valid at all times. Pick s > t, then H(φ)(s) gives φ(t) since t < s.
  have h_H := h D F M Omega h_sc τ h_mem
  obtain ⟨s, hts⟩ := exists_gt t
  have := h_H s
  simp only [Truth.past_iff] at this
  exact this t hts

/--
If □φ is valid, then φ is valid.

Proof: □φ at (τ, t) means ∀ σ ∈ Omega, TruthAt φ at (σ, t). Since τ ∈ Omega,
this gives TruthAt φ at (τ, t).
-/
theorem valid_of_valid_box {φ : Formula} (h : valid (Formula.box φ)) :
    valid φ := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t τ h_mem

end Validity

end FormalSystem.Semantics
