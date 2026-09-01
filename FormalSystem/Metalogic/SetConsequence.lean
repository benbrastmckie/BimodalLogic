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

It is vocabulary only. **No compactness result is proved or refuted here.** `CompactBase`,
`ModelExistenceBase`, `CompactDense` and `ModelExistenceDense` are `Prop`-valued definitions
stated here and **discharged elsewhere**: all four are proved in
`Metalogic/Compactness.lean`, by `compactBase`, `modelExistenceBase`, `compactDense` and
`modelExistenceDense`, via an ultraproduct construction. `CompactDiscrete` and
`StrongCompletenessDiscrete` are different in kind: they are not proved but **refuted**, in
`Metalogic/DiscreteNonCompactness.lean`, by `discrete_consequence_not_compact` and
`strongCompletenessDiscrete_refuted`. The Base/Dense statements and the Discrete ones must not
be read as sharing a status — the Base and Dense questions are settled positively, the Discrete
one negatively.

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
the `foldr`-implication bridge between finite-context and empty-context derivability, and the
pointwise currying lemma `truthAt_foldr_imp` with it, four *theorems* stated in this module's
vocabulary live there rather than here: the two strong-completeness reductions
`strongCompletenessBase_of_compact` and `strongCompletenessDense_of_compact`, and the two
model-existence-to-compactness bridges `compactBase_of_modelExistence` and
`compactDense_of_modelExistenceDense`. Placing any of them in this module would be an import
cycle; the reason is the same in all four cases.
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

/-! ## Set-based semantic consequence, defined once

`SetSemanticConsequenceOn fc` sits beside `SetDerivable fc` above and is indexed by the same
`FrameClass` tag, which is the point: before this collapse there were four byte-identical
definitions here, each carrying a hand-maintained binder list plus a docstring citing the
`Semantics/Validity.lean` line its list was copied from. Three of those four line citations had
since gone stale. The frame constraint is now read off the tag by `FrameClass.Sat`
(`Semantics/FrameClassValidity.lean`), so there is nothing left to keep in sync.

The four per-class names are retained as abbreviations — every existing call site still compiles
against them — but each is now one line, and the four monotonicity-in-`Γ` copies below have
collapsed onto `setConsequenceOnFrames_mono`. -/

/-- Set-based semantic consequence over every frame satisfying `P`: the predicate-indexed
primitive, mirroring `Semantics.ValidOnFrames`. -/
def SetConsequenceOnFrames (P : TaskFrame → Prop) (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-- `cor:tm-completeness`'s class-restricted consequence `Γ ⊨_C φ` at a possibly-infinite premise
set: the semantic mirror of `SetDerivable fc` above, indexed by the same tag. -/
def SetSemanticConsequenceOn (fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop :=
  SetConsequenceOnFrames fc.Sat Γ φ

/-- Set-based semantic consequence over `FrameClass.Base` — the unconstrained class, since
`Sat .Base` is `True`. -/
def SetSemanticConsequenceBase (Γ : Set Formula) (φ : Formula) : Prop :=
  SetSemanticConsequenceOn FrameClass.Base Γ φ

/-- Set-based semantic consequence over `FrameClass.Dense`. -/
def SetSemanticConsequenceDense (Γ : Set Formula) (φ : Formula) : Prop :=
  SetSemanticConsequenceOn FrameClass.Dense Γ φ

/-- Set-based semantic consequence over `FrameClass.Discrete`. Stated for completeness of the
layer; strong completeness at this class is refuted by non-compactness. -/
def SetSemanticConsequenceDiscrete (Γ : Set Formula) (φ : Formula) : Prop :=
  SetSemanticConsequenceOn FrameClass.Discrete Γ φ

/-- Set-based semantic consequence over dense Dedekind-complete frames — the
`soundness_dedekind` target class. Non-compact. -/
def SetSemanticConsequenceDedekindDense (Γ : Set Formula) (φ : Formula) : Prop :=
  SetSemanticConsequenceOn FrameClass.Dedekind Γ φ

/-! ### Binder-shape adapters

The pre-collapse binder shapes, restored. Each `of_forall` puts the frame condition back into the
local context in the form typeclass resolution can see — `Sat .Dense F` is `TaskFrame.IsDense F`,
whose head symbol is not `DenselyOrdered`, so a bare hypothesis of that type is invisible to
instance search. The `.Discrete` adapter destructures `TaskFrame.IsSuccArchDiscrete` with `obtain`
and passes its witnesses positionally with `@`, never through `haveI`. -/

/-- Introduce `SetSemanticConsequenceBase` from its pre-collapse binder shape. -/
theorem SetSemanticConsequenceBase.of_forall {Γ : Set Formula} {φ : Formula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal →
           ∀ t : F.Duration, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :
    SetSemanticConsequenceBase Γ φ :=
  fun F _ M τ hτ t => h F M τ hτ t

/-- Eliminate `SetSemanticConsequenceBase` into its pre-collapse binder shape. -/
theorem SetSemanticConsequenceBase.apply {Γ : Set Formula} {φ : Formula}
    (h : SetSemanticConsequenceBase Γ φ) (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (hall : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  h F trivial M τ hτ t hall

/-- Introduce `SetSemanticConsequenceDense` from its pre-collapse binder shape. -/
theorem SetSemanticConsequenceDense.of_forall {Γ : Set Formula} {φ : Formula}
    (h : ∀ (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
           (τ : WorldHistory F), τ.IsTotal →
           ∀ t : F.Duration, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :
    SetSemanticConsequenceDense Γ φ :=
  fun F hF M τ hτ t => @h F hF M τ hτ t

/-- Eliminate `SetSemanticConsequenceDense` into its pre-collapse binder shape. -/
theorem SetSemanticConsequenceDense.apply {Γ : Set Formula} {φ : Formula}
    (h : SetSemanticConsequenceDense Γ φ) (F : TaskFrame)
    [inst : DenselyOrdered F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (hall : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  h F inst M τ hτ t hall

/-- Introduce `SetSemanticConsequenceDiscrete` from its pre-collapse binder shape. -/
theorem SetSemanticConsequenceDiscrete.of_forall {Γ : Set Formula} {φ : Formula}
    (h : ∀ (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
           [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] (M : TaskModel F)
           (τ : WorldHistory F), τ.IsTotal →
           ∀ t : F.Duration, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :
    SetSemanticConsequenceDiscrete Γ φ := by
  intro F hF M τ hτ t hall
  obtain ⟨so, po, hsa, hpa⟩ := hF
  exact @h F so po hsa hpa M τ hτ t hall

/-- Eliminate `SetSemanticConsequenceDiscrete` into its pre-collapse binder shape. -/
theorem SetSemanticConsequenceDiscrete.apply {Γ : Set Formula} {φ : Formula}
    (h : SetSemanticConsequenceDiscrete Γ φ) (F : TaskFrame)
    [so : SuccOrder F.Duration] [po : PredOrder F.Duration]
    [hsa : IsSuccArchimedean F.Duration] [hpa : IsPredArchimedean F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (hall : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  h F ⟨so, po, hsa, hpa⟩ M τ hτ t hall

/-- Introduce `SetSemanticConsequenceDedekindDense` from its pre-collapse binder shape. -/
theorem SetSemanticConsequenceDedekindDense.of_forall {Γ : Set Formula} {φ : Formula}
    (h : ∀ (F : TaskFrame) [DenselyOrdered F.Duration],
           (∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) →
           ∀ (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal →
           ∀ t : F.Duration, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :
    SetSemanticConsequenceDedekindDense Γ φ :=
  fun F hF M τ hτ t => @h F hF.1 hF.2 M τ hτ t

/-- Eliminate `SetSemanticConsequenceDedekindDense` into its pre-collapse binder shape. -/
theorem SetSemanticConsequenceDedekindDense.apply {Γ : Set Formula} {φ : Formula}
    (h : SetSemanticConsequenceDedekindDense Γ φ) (F : TaskFrame)
    [inst : DenselyOrdered F.Duration]
    (hlub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (hall : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  h F ⟨inst, hlub⟩ M τ hτ t hall

/-! ## Monotonicity -/

/-- Set-derivability is monotone in the premise set: a derivation citing finitely many
    premises from `Γ` cites those same premises from any superset. -/
theorem setDerivable_mono {fc : FrameClass} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetDerivable fc Γ φ) : SetDerivable fc Δ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact ⟨L, fun ψ hψ => h_sub (hL ψ hψ), hd⟩

/-- **The one monotonicity-in-`Γ` lemma.** Set-consequence over any frame predicate is monotone
in the premise set. The four per-class copies below are one-line corollaries; before the collapse
each was a separate four-line proof differing only in how many binders its `intro` consumed. -/
theorem setConsequenceOnFrames_mono {P : TaskFrame → Prop} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetConsequenceOnFrames P Γ φ) : SetConsequenceOnFrames P Δ φ := by
  intro F hF M τ hτ t h_all
  exact h F hF M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-- **Monotonicity in the frame class**, the semantic analogue of `DerivationTree.lift`: a larger
class tag denotes a more constrained collection of frames, so consequence climbs the order. The
order-direction argument itself lives once, in `FrameClass.Sat.anti`. -/
theorem setSemanticConsequenceOn_mono_fc {fc₁ fc₂ : FrameClass} {Γ : Set Formula} {φ : Formula}
    (h_le : fc₁ ≤ fc₂) (h : SetSemanticConsequenceOn fc₁ Γ φ) :
    SetSemanticConsequenceOn fc₂ Γ φ :=
  fun F hF => h F (FrameClass.Sat.anti h_le hF)

/-- Base set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceBase_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceBase Γ φ) : SetSemanticConsequenceBase Δ φ :=
  setConsequenceOnFrames_mono h_sub h

/-- Dense set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceDense_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDense Γ φ) : SetSemanticConsequenceDense Δ φ :=
  setConsequenceOnFrames_mono h_sub h

/-- Discrete set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceDiscrete_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDiscrete Γ φ) :
    SetSemanticConsequenceDiscrete Δ φ :=
  setConsequenceOnFrames_mono h_sub h

/-- Dense Dedekind-complete set-consequence is monotone in the premise set. -/
theorem setSemanticConsequenceDedekindDense_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDedekindDense Γ φ) :
    SetSemanticConsequenceDedekindDense Δ φ :=
  setConsequenceOnFrames_mono h_sub h

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

These four definitions are **statements**, exactly as their Dense siblings below are. None of
them is discharged in this module; all four are discharged in
`Metalogic/Compactness.lean`. `CompactBase` was for a long time the entire remaining
obligation for Base strong completeness — the single-formula engine hypothesis of
`strongCompletenessBase_of_compact` (`StrongCompleteness.lean`) being independently
dischargeable at `BXCanonical.completeness`, and kept live there precisely so that `CompactBase`
was isolated as the whole of what remained. `compactBase` now supplies it, and
`strongCompletenessBase` collects the result.

Each definition is its Dense sibling with `SetSemanticConsequenceBase` / `valid` in place of
`SetSemanticConsequenceDense` / `ValidDense` and the `[DenselyOrdered D]` binder dropped —
there is no third axis of variation.

Base's status is **proved**, the same status as Dense and distinct from both Discrete (refuted,
below) and Dedekind (unavailable on its primary source's own terms). The three must not be read
as sharing a status.
-/

/-- **Strong completeness for `FrameClass.Base`** — the statement. The
    `StrongCompletenessDense` statement with `SetSemanticConsequenceBase` in place of
    `SetSemanticConsequenceDense` and `FrameClass.Base` as the derivability target. Proved as
    `strongCompletenessBase` in `FormalSystem/Metalogic/Compactness.lean`; not proved here,
    which supplies vocabulary only. -/
def StrongCompletenessBase : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceBase Γ φ → SetDerivable FrameClass.Base Γ φ

/-- Semantic compactness of the Base consequence relation, stated in the form the completeness
    derivation actually consumes: a set-consequence yields a *finite* premise list whose
    `foldr`-implication into the conclusion is valid. This is the whole of what
    `strongCompletenessBase_of_compact` needs beyond its engine; it is supplied by `compactBase`
    in `FormalSystem/Metalogic/Compactness.lean`. -/
def CompactBase : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceBase Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ valid (L.foldr Formula.imp φ)

/-- Satisfiability of a possibly-infinite set over arbitrary carriers. This is
    `FormulaSatisfiable` (`Validity.lean:190`) at `valid`'s binder list, with the conclusion
    generalised from a single formula to `∀ ψ ∈ Γ`; equivalently `SatisfiableDenseSet` with the
    `DenselyOrdered` binder dropped. -/
def SatisfiableBaseSet (Γ : Set Formula) : Prop :=
  ∃ (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

/-- The model-existence form, which is what an ultraproduct construction proves directly:
    finite satisfiability of every finite sublist lifts to satisfiability of the whole set.
    `ModelExistenceBase → CompactBase` is a contraposition through the `Formula.neg` clause of
    `TruthAt` together with `truthAt_foldr_imp`, and it **is proved** — as
    `compactBase_of_modelExistence` in `FormalSystem/Metalogic/StrongCompleteness.lean`. It is
    not proved *here* for the import-cycle reason recorded under `## Downstream` above:
    `truthAt_foldr_imp` is owned by that module, and that module imports this one.
    `ModelExistenceBase` itself is proved as `modelExistenceBase` in
    `FormalSystem/Metalogic/Compactness.lean`, by the ultraproduct construction this docstring
    anticipates. -/
def ModelExistenceBase : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableBaseSet {ψ | ψ ∈ L}) →
    SatisfiableBaseSet Γ

/-! ## Strong completeness, compactness and model existence for `FrameClass.Dense`

These four definitions are **statements**. None of them is discharged in this module; all four
are discharged in `Metalogic/Compactness.lean`. `CompactDense` was for a long time the
entire remaining obligation for Dense strong completeness (the single-formula engine hypothesis
being independently dischargeable — see the note on `strongCompletenessDense_of_compact` in
`StrongCompleteness.lean`); `compactDense` now supplies it, and `strongCompletenessDense`
collects the result.
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
  ∃ (F : TaskFrame) (_ : DenselyOrdered F.Duration) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

/-- The model-existence form, which is what an ultraproduct construction proves directly:
    finite satisfiability of every finite sublist lifts to satisfiability of the whole set.
    `ModelExistenceDense → CompactDense` is a contraposition through the `Formula.neg` clause of
    `TruthAt` together with `truthAt_foldr_imp` (`StrongCompleteness.lean`), and it **is
    proved** — as `compactDense_of_modelExistenceDense` in that same module. It is not proved
    *here* for the import-cycle reason recorded under `## Downstream` above.
    `ModelExistenceDense` itself is proved as `modelExistenceDense` in
    `FormalSystem/Metalogic/Compactness.lean`, by the ultraproduct construction this docstring
    anticipates. -/
def ModelExistenceDense : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableDenseSet {ψ | ψ ∈ L}) →
    SatisfiableDenseSet Γ

/-! ## Strong completeness, satisfiability and compactness for `FrameClass.Discrete`

These three definitions are **statements, not results** — and unlike their Base and Dense
counterparts above they are settled *negatively*. Both `CompactDiscrete` and
`StrongCompletenessDiscrete` are *refuted* downstream in
`Metalogic/DiscreteNonCompactness.lean`, by
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
  ∃ (F : TaskFrame) (_ : SuccOrder F.Duration) (_ : PredOrder F.Duration)
    (_ : IsSuccArchimedean F.Duration) (_ : IsPredArchimedean F.Duration)
    (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

/-- Semantic compactness of the Discrete consequence relation, in the same shape as
    `CompactDense`: a set-consequence yields a *finite* premise list whose `foldr`-implication
    into the conclusion is Discrete-valid.

    **This statement is false.** See `discrete_consequence_not_compact`. -/
def CompactDiscrete : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDiscrete Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidDiscrete (L.foldr Formula.imp φ)

end FormalSystem.Metalogic
