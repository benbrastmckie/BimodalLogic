/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity
import FormalSystem.ProofSystem.Derivable
import FormalSystem.Metalogic.Core.MaximalConsistent

/-!
# The Set-Based Consequence Layer

This module supplies the **vocabulary** for consequence from a possibly-infinite premise set
`Γ : Set Formula`: the finitary derivability relation `SetDerivable`, the four per-class
set-based semantic consequence predicates, the basic lemmas relating them to the finite-context
(`Γ : Context`) layer, and the statements — not the proofs — of strong completeness,
compactness, satisfiability and model existence for `FrameClass.Base` and `FrameClass.Dense`,
together with the strong-completeness, satisfiability and compactness statements for
`FrameClass.Discrete`.

It is vocabulary only. **No compactness result is proved or refuted here**, and no existing
proof gap anywhere in the tree is closed by this module. `CompactBase`, `ModelExistenceBase`,
`CompactDense` and `ModelExistenceDense` are `Prop`-valued definitions that name **open
obligations**; discharging them is future work. `CompactDiscrete` and
`StrongCompletenessDiscrete` are different in kind: they are not open but **refuted**, in
`Metalogic/DiscreteNonCompactness.lean`, by `discrete_consequence_not_compact` and
`strongCompletenessDiscrete_refuted`. The Base/Dense statements and the Discrete ones must not
be read as sharing a status — the Base and Dense questions are unsettled, the Discrete one is
settled negatively.

## Design

* `SetDerivable` is deliberately shaped to match `Core.SetConsistent`
  (`Core/MaximalConsistent.lean:96`) so that the two compose without an adapter: a derivation is
  a finite object and can cite only finitely many premises, so finitary set-derivability is the
  only derivability notion a finitary proof system can support over `Set Formula`.
* Each `SetSemanticConsequence*` predicate is the corresponding validity predicate's binder list
  taken verbatim from `FormalSystem/Semantics/Validity.lean`, with the premise hypothesis
  `(∀ ψ ∈ Γ, TruthAt M τ t ψ)` inserted before the conclusion — the same surgery that
  `SemanticConsequenceDedekindDense` (`StrongCompleteness.lean:129`) performs on
  `ValidDedekindDense`. `Γ : Set Formula` rather than `Γ : Context` is the only difference from
  those finite-context forms; `∀ ψ ∈ Γ` elaborates identically for `Set` and `List`.
* Nothing here imports `FormalSystem/Metalogic/BXCanonical/`. The set layer is vocabulary; the
  chronicle machinery is a countermodel engine, and the two are deliberately kept unentangled.

## Downstream

`FormalSystem/Metalogic/StrongCompleteness.lean` imports this module. Because that module owns
the `foldr`-implication bridge between finite-context and empty-context derivability, the two
*theorems* of the strong-completeness group — `strongCompletenessBase_of_compact` and
`strongCompletenessDense_of_compact` — live there rather than here; placing them in this module
would be an import cycle.
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/-! ## Finitary set-derivability -/

/--
Finitary derivability from a possibly-infinite premise set. A derivation is a finite object
and can cite only finitely many premises, so this is the only derivability notion a finitary
proof system can support over `Set Formula`.
-/
def SetDerivable (fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop :=
  ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ

/-! ## Per-class set-based semantic consequence -/

/-- Set-based semantic consequence over `FrameClass.Base`. Binder list: `valid`
    (`Validity.lean:94`). -/
def SetSemanticConsequenceBase (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-- Set-based semantic consequence over `FrameClass.Dense`. Binder list: `ValidDense`
    (`Validity.lean:206`). -/
def SetSemanticConsequenceDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-- Set-based semantic consequence over `FrameClass.Discrete`. Binder list: `ValidDiscrete`
    (`Validity.lean:243`). Stated for completeness of the layer; strong completeness at this
    class is refuted by non-compactness. -/
def SetSemanticConsequenceDiscrete (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-- Set-based semantic consequence over dense Dedekind-complete carriers. Binder list:
    `ValidDedekindDense` (`Validity.lean:331`) — the `soundness_dedekind` target. Non-compact. -/
def SetSemanticConsequenceDedekindDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-! ## Monotonicity -/

/-- Set-derivability is monotone in the premise set: a derivation citing finitely many
    premises from `Γ` cites those same premises from any superset. -/
theorem setDerivable_mono {fc : FrameClass} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetDerivable fc Γ φ) : SetDerivable fc Δ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact ⟨L, fun ψ hψ => h_sub (hL ψ hψ), hd⟩

/-- Base set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceBase_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceBase Γ φ) : SetSemanticConsequenceBase Δ φ := by
  intro D _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-- Dense set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceDense_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDense Γ φ) : SetSemanticConsequenceDense Δ φ := by
  intro D _ _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-- Discrete set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceDiscrete_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDiscrete Γ φ) :
    SetSemanticConsequenceDiscrete Δ φ := by
  intro D _ _ _ _ _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-- Dense Dedekind-complete set-consequence is monotone in the premise set. The
    least-upper-bound hypothesis is an explicit binder, so it is threaded to `h` by name. -/
theorem setSemanticConsequenceDedekindDense_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDedekindDense Γ φ) :
    SetSemanticConsequenceDedekindDense Δ φ := by
  intro D _ _ _ _ _ hlub F M τ hτ t h_all
  exact h D hlub F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-! ## Finite restriction and agreement with the finite-context layer -/

/-- Every set-derivation restricts to a finite context. Definitional, but worth naming: it is
    the statement the compactness argument consumes. -/
theorem setDerivable_iff_exists_finite {fc : FrameClass} (Γ : Set Formula) (φ : Formula) :
    SetDerivable fc Γ φ ↔ ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ :=
  Iff.rfl

/-- A finite context is set-derivable from its own carrier set. -/
theorem setDerivable_of_derivable {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : Derivable fc Γ φ) : SetDerivable fc (Core.contextToSet Γ) φ :=
  ⟨Γ, fun _ hψ => hψ, h⟩

/-- …and conversely, so the set layer is a conservative extension of the finite layer.

    `Derivable.weaken` (`ProofSystem/Derivable.lean:147`) wants a `Context` subset relation
    `L ⊆ Γ`, whereas the set-derivation supplies `∀ ψ ∈ L, ψ ∈ Core.contextToSet Γ`. Since
    `Core.contextToSet Γ = {φ | φ ∈ Γ}` (`Core/MaximalConsistent.lean:123`) these are
    definitionally the same statement, and the eta-expansion below is all that is needed. -/
theorem derivable_of_setDerivable_contextToSet {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : SetDerivable fc (Core.contextToSet Γ) φ) : Derivable fc Γ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact hd.weaken (fun _ hx => hL _ hx)

/-- Membership gives derivability: the singleton context `[φ]` derives `φ` by the assumption
    rule (`ProofSystem/Derivation.lean:105`), and `Derivable` is `Nonempty (DerivationTree …)`
    (`ProofSystem/Derivable.lean:69`), so the outer anonymous constructor is `Nonempty.intro`. -/
theorem setDerivable_of_mem {fc : FrameClass} {Γ : Set Formula} {φ : Formula} (h : φ ∈ Γ) :
    SetDerivable fc Γ φ :=
  ⟨[φ], by simpa using h, ⟨DerivationTree.assumption _ _ (by simp)⟩⟩

/-! ## The bridge to `Core.SetConsistent` -/

/-- Deriving `⊥` from a set refutes its consistency. `Core.SetConsistent`
    (`Core/MaximalConsistent.lean:96`) unfolds to `∀ L, (∀ φ ∈ L, φ ∈ S) → Consistent L` and
    `Consistent` (`:67`) to `¬Derivable fc Γ Formula.bot`, both definitionally, so the finite
    witness of the set-derivation applies directly. -/
theorem not_setConsistent_of_setDerivable_bot {fc : FrameClass} {Γ : Set Formula}
    (h : SetDerivable fc Γ Formula.bot) : ¬ Core.SetConsistent (fc := fc) Γ := by
  obtain ⟨L, hL, hd⟩ := h
  exact fun hcons => hcons L hL hd

/-! ## Strong completeness, compactness and model existence for `FrameClass.Base`

These four definitions are **statements, not results**, exactly as their Dense siblings below
are. None of them is discharged in this module, and `CompactBase` in particular is the entire
remaining obligation for Base strong completeness: the single-formula engine hypothesis of
`strongCompletenessBase_of_compact` (`StrongCompleteness.lean`) is already dischargeable at
`BXCanonical.completeness`, and is kept live there precisely so that `CompactBase` is isolated
as the whole of what remains.

Each definition is its Dense sibling with `SetSemanticConsequenceBase` / `valid` in place of
`SetSemanticConsequenceDense` / `ValidDense` and the `[DenselyOrdered D]` binder dropped —
there is no third axis of variation.

Base's status is **open**, the same status as Dense and distinct from both Discrete (refuted,
below) and Dedekind (unavailable on its primary source's own terms). The three must not be read
as sharing a status.
-/

/-- **Strong completeness for `FrameClass.Base`** — the reserved statement, an **open
    obligation**. The `StrongCompletenessDense` statement with `SetSemanticConsequenceBase` in
    place of `SetSemanticConsequenceDense` and `FrameClass.Base` as the derivability target.
    Neither proved nor refuted here or anywhere in this tree. -/
def StrongCompletenessBase : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceBase Γ φ → SetDerivable FrameClass.Base Γ φ

/-- Semantic compactness of the Base consequence relation, stated in the form the completeness
    derivation actually consumes: a set-consequence yields a *finite* premise list whose
    `foldr`-implication into the conclusion is valid. An **open obligation** — this is the whole
    of what `strongCompletenessBase_of_compact` still needs. -/
def CompactBase : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceBase Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ valid (L.foldr Formula.imp φ)

/-- Satisfiability of a possibly-infinite set over arbitrary carriers. This is
    `FormulaSatisfiable` (`Validity.lean:190`) at `valid`'s binder list, with the conclusion
    generalised from a single formula to `∀ ψ ∈ Γ`; equivalently `SatisfiableDenseSet` with the
    `DenselyOrdered` binder dropped. -/
def SatisfiableBaseSet (Γ : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

/-- The model-existence form, which is what an ultraproduct construction proves directly:
    finite satisfiability of every finite sublist lifts to satisfiability of the whole set.
    `ModelExistenceBase → CompactBase` is a contraposition through the `Formula.neg` clause of
    `TruthAt` together with `truthAt_foldr_imp` (`StrongCompleteness.lean`); that implication is
    future work and is not proved here. An **open obligation**. -/
def ModelExistenceBase : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableBaseSet {ψ | ψ ∈ L}) →
    SatisfiableBaseSet Γ

/-! ## Strong completeness, compactness and model existence for `FrameClass.Dense`

These four definitions are **statements, not results**. None of them is discharged in this
module, and `CompactDense` in particular is the entire remaining obligation for Dense strong
completeness (the single-formula engine hypothesis is already dischargeable — see the note on
`strongCompletenessDense_of_compact` in `StrongCompleteness.lean`).
-/

/-- **Strong completeness for `FrameClass.Dense`** — the reserved statement. Note that
    `FrameClass` (`ProofSystem/Axioms.lean:519`) has constructors `Base | Dense | Discrete |
    Dedekind`; there is no `.DedekindDense` constructor, and `FrameClass.Dense` is the correct
    target for the `SetSemanticConsequenceDense` relation. -/
def StrongCompletenessDense : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceDense Γ φ → SetDerivable FrameClass.Dense Γ φ

/-- Semantic compactness of the Dense consequence relation, stated in the form the
    completeness derivation actually consumes: a set-consequence yields a *finite* premise list
    whose `foldr`-implication into the conclusion is Dense-valid. -/
def CompactDense : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDense Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidDense (L.foldr Formula.imp φ)

/-- Satisfiability of a possibly-infinite set over dense carriers. This is
    `FormulaSatisfiable` (`Validity.lean:190`) with `(_ : DenselyOrdered D)` inserted in
    `ValidDense`'s binder position and the conclusion generalised from a single formula to
    `∀ ψ ∈ Γ`. -/
def SatisfiableDenseSet (Γ : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : DenselyOrdered D) (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

/-- The model-existence form, which is what an ultraproduct construction proves directly:
    finite satisfiability of every finite sublist lifts to satisfiability of the whole set.
    `ModelExistenceDense → CompactDense` is a contraposition through the `Formula.neg` clause of
    `TruthAt` together with `truthAt_foldr_imp` (`StrongCompleteness.lean:147`); that
    implication is future work and is not proved here. -/
def ModelExistenceDense : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableDenseSet {ψ | ψ ∈ L}) →
    SatisfiableDenseSet Γ

/-! ## Strong completeness, satisfiability and compactness for `FrameClass.Discrete`

These three definitions are **statements, not results** — but unlike their Dense counterparts
above they do not name open obligations. Both `CompactDiscrete` and `StrongCompletenessDiscrete`
are *refuted* downstream in `Metalogic/DiscreteNonCompactness.lean`, by
`discrete_consequence_not_compact` and `strongCompletenessDiscrete_refuted` respectively, which
exhibit the premise set `{F p} ∪ {¬Xⁿ p : n ∈ ℕ}` as finitely satisfiable over `ℤ` yet
unsatisfiable over every Archimedean discrete carrier. Nothing about those refutations is
imported here; this module supplies only the vocabulary they are stated in.

No import change is required for these: `IsSuccArchimedean` and `IsPredArchimedean` are already
in scope via `SetSemanticConsequenceDiscrete` above.
-/

/-- **Strong completeness for `FrameClass.Discrete`** — the `StrongCompletenessDense` statement
    with `SetSemanticConsequenceDiscrete` in place of `SetSemanticConsequenceDense`.

    **This statement is false.** See `strongCompletenessDiscrete_refuted`. It is stated here so
    that the refutation has something to name; it is not a reserved obligation. -/
def StrongCompletenessDiscrete : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceDiscrete Γ φ → SetDerivable FrameClass.Discrete Γ φ

/-- Satisfiability of a possibly-infinite set over discrete carriers. This is
    `FormulaSatisfiable` (`Validity.lean:190`) with `ValidDiscrete`'s binder list
    (`Validity.lean:243`) — `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean`
    — in place of `ValidDense`'s `DenselyOrdered`, and the conclusion generalised from a single
    formula to `∀ ψ ∈ Γ`.

    The five extra class binders are written as **anonymous** existential binders. When this
    existential is destructured, use bare `_` names for them and let instance synthesis recover
    them: naming them and re-installing with `haveI` drops the value and breaks definitional
    equality with the instances baked into `F`'s and `M`'s types. -/
def SatisfiableDiscreteSet (Γ : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : SuccOrder D) (_ : PredOrder D) (_ : IsSuccArchimedean D) (_ : IsPredArchimedean D)
    (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

/-- Semantic compactness of the Discrete consequence relation, in the same shape as
    `CompactDense`: a set-consequence yields a *finite* premise list whose `foldr`-implication
    into the conclusion is Discrete-valid.

    **This statement is false.** See `discrete_consequence_not_compact`. -/
def CompactDiscrete : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDiscrete Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidDiscrete (L.foldr Formula.imp φ)

end FormalSystem.Metalogic
