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
compactness, satisfiability and model existence.

**Those four statements are now one `FrameClass`-indexed family**, `SatisfiableSet`,
`ModelExistence`, `Compact` and `StrongCompleteness`, each taking the class tag as a parameter
and reading its frame condition off it through `FrameClass.Sat`. The per-class names this module
used to define by hand — `StrongCompletenessBase` / `CompactBase` / `SatisfiableBaseSet` /
`ModelExistenceBase`, their Dense siblings, and the three Discrete ones — are retained, with
their statements unchanged, as instantiations of that family. **The `.Dedekind` row is now named
here too**, by the same instantiation: `StrongCompletenessDedekind`, `CompactDedekind`,
`SatisfiableDedekindSet` and `ModelExistenceDedekind` at the end of this module. All four rows of
the family are therefore stated in this layer; none of the four required a new adapter or a new
binder list.

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
pointwise currying lemma `truthAt_foldr_imp` with it, two *theorems* stated in this module's
vocabulary live there rather than here: the strong-completeness reduction
`strongCompleteness_of_compact` and the model-existence-to-compactness bridge
`compact_of_modelExistence`. Both are generic in the `FrameClass`, so between them they carry
what used to be four per-class theorems. Placing either in this module would be an import
cycle; the reason is the same in both cases.
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

/-! ## The `FrameClass`-indexed compactness family

The satisfiability / model-existence / compactness / strong-completeness row, defined **once**
and indexed by the same `FrameClass` tag that `SetDerivable` and `SetSemanticConsequenceOn`
above already carry. Before this collapse each of the three live classes carried its own
hand-written copy of the whole row, with the frame condition inlined into a hand-maintained
binder list. The condition is now read off the tag by `FrameClass.Sat`
(`Semantics/FrameClassValidity.lean`), so there is nothing left to keep in sync — and the
`.Dedekind` row, absent from this layer entirely, becomes available by instantiation.

Nothing here is proved or refuted; these are `Prop`-valued statements only. The per-class names
further down are instantiations of these four, and each inherits its status from where it is
discharged (Base and Dense: proved, in `Metalogic/Compactness.lean`; Discrete: refuted, in
`Metalogic/DiscreteNonCompactness.lean`). -/

/-- Satisfiability of a possibly-infinite set over the frames of `fc`: some frame satisfying
`fc`, together with a model, a total history and a time, makes every member of `Γ` true at
once. This is `FormulaSatisfiable` (`Validity.lean`) at `ValidIn fc`'s binder list, with the
conclusion generalised from a single formula to `∀ ψ ∈ Γ`.

The frame condition sits in an **anonymous** existential binder holding `fc.Sat F`. At
`.Discrete` that is `TaskFrame.IsSuccArchDiscrete F` (`Semantics/FrameProperty.lean`), itself a
four-component nested existential which the anonymous constructor does not unfold, so a
destructuring pattern needs exactly one nesting pair there. The `SatisfiableSet.*_of_forall`
adapters below restore the pre-collapse flat binder shape at introduction sites. -/
def SatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop :=
  ∃ (F : TaskFrame) (_ : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

/-- The model-existence form, which is what an ultraproduct construction proves directly: finite
satisfiability of every finite sublist lifts to satisfiability of the whole set. Uniform in `fc`
because `SatisfiableSet` is. `ModelExistence fc → Compact fc` is `compact_of_modelExistence`
(`Metalogic/StrongCompleteness.lean`), which is stated once for all `fc` rather than once per
class. -/
def ModelExistence (fc : FrameClass) : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableSet fc {ψ | ψ ∈ L}) →
    SatisfiableSet fc Γ

/-- Semantic compactness of the `fc` consequence relation, in the form the completeness
derivation actually consumes: a set-consequence yields a *finite* premise list whose
`foldr`-implication into the conclusion is `fc`-valid.

`CompactBase`, `CompactDense` and `CompactDiscrete` below are this definition at a fixed tag,
recovered by `rfl` — see the definitional-equality note after `StrongCompleteness`. -/
def Compact (fc : FrameClass) : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceOn fc Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidIn fc (L.foldr Formula.imp φ)

/-- **Strong completeness at `fc`** — the statement: `Γ ⊨_fc φ → Γ ⊢_fc φ` for a
possibly-infinite `Γ : Set Formula`. The semantic mirror of `SetDerivable fc` closed under the
consequence relation indexed by the same tag.

`StrongCompletenessBase`, `StrongCompletenessDense` and `StrongCompletenessDiscrete` below are
this definition at a fixed tag, recovered by `rfl`. -/
def StrongCompleteness (fc : FrameClass) : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceOn fc Γ φ → SetDerivable fc Γ φ

/-! ### What the per-class recoveries cost

Six of the ten per-class names below are recovered from these four definitions **on the nose**,
by `rfl`:

```
Compact .Base = CompactBase                     StrongCompleteness .Base = StrongCompletenessBase
Compact .Dense = CompactDense                   StrongCompleteness .Dense = StrongCompletenessDense
Compact .Discrete = CompactDiscrete             StrongCompleteness .Discrete = StrongCompletenessDiscrete
```

and so are `SatisfiableSet .Dense = SatisfiableDenseSet` and
`ModelExistence .Dense = ModelExistenceDense`, for eight in total. This is what
`Semantics/Validity.lean`'s `valid := ValidIn .Base`, `ValidDense := ValidIn .Dense` and
`ValidDiscrete := ValidIn .Discrete` bought: the per-class validity predicates are plain
abbreviations over `ValidIn`, so `ValidIn fc (…)` at a literal tag *is* the per-class predicate,
with no transport.

The two exceptions are `SatisfiableBaseSet` and `SatisfiableDiscreteSet`, whose pre-collapse
binder lists differ from `SatisfiableSet`'s by the frame-condition slot — `Sat .Base` is `True`,
which the old Base list simply omitted, and `Sat .Discrete` nests its four class witnesses inside
`TaskFrame.IsSuccArchDiscrete` where the old Discrete list held them flat. Both are *stated* as
instantiations below; the pre-collapse shape is restored at call sites by the adapters. -/

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

/-! ### `SatisfiableSet` binder-shape adapters

The same service the `SetSemanticConsequence*.of_forall` adapters above perform, on the
introduction side of `SatisfiableSet`. Each takes the pre-collapse binder shape — the frame
condition as typeclass instances or as a plain hypothesis, in the position it occupied before
the collapse — and packages it into the single `fc.Sat F` slot. The `.Dedekind` adapter serves
the `.Dedekind` names stated at the end of this module (`SatisfiableDedekindSet` and its three
siblings), and is what `Metalogic/DedekindNonCompactness.lean` uses at both of its introduction
sites. -/

/-- Introduce `SatisfiableSet FrameClass.Base` from its pre-collapse binder shape. `Sat .Base`
is `True`, so the absorbed slot is discharged by `trivial`. -/
theorem SatisfiableSet.base_of_forall {Γ : Set Formula} (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    SatisfiableSet FrameClass.Base Γ := ⟨F, trivial, M, τ, hτ, t, h⟩

/-- Introduce `SatisfiableSet FrameClass.Dense` from its pre-collapse binder shape, taking the
density witness as an instance argument. -/
theorem SatisfiableSet.dense_of_forall {Γ : Set Formula} (F : TaskFrame)
    [inst : DenselyOrdered F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    SatisfiableSet FrameClass.Dense Γ := ⟨F, inst, M, τ, hτ, t, h⟩

/-- Introduce `SatisfiableSet FrameClass.Discrete` from its pre-collapse binder shape: the four
class witnesses flat, as instance arguments, rather than nested inside
`TaskFrame.IsSuccArchDiscrete`. This is the adapter that keeps a `refine ⟨F, inferInstance,
inferInstance, inferInstance, inferInstance, M, …⟩` site reading as it did before the
collapse. -/
theorem SatisfiableSet.discrete_of_forall {Γ : Set Formula} (F : TaskFrame)
    [so : SuccOrder F.Duration] [po : PredOrder F.Duration]
    [hsa : IsSuccArchimedean F.Duration] [hpa : IsPredArchimedean F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    SatisfiableSet FrameClass.Discrete Γ := ⟨F, ⟨so, po, hsa, hpa⟩, M, τ, hτ, t, h⟩

/-- Introduce `SatisfiableSet FrameClass.Dedekind` from its pre-collapse binder shape. `Sat
.Dedekind` is `TaskFrame.IsDedekind`, i.e. `IsDense ∧ IsComplete`, so the slot takes the density
instance paired with the least-upper-bound hypothesis. -/
theorem SatisfiableSet.dedekind_of_forall {Γ : Set Formula} (F : TaskFrame)
    [inst : DenselyOrdered F.Duration]
    (hlub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    SatisfiableSet FrameClass.Dedekind Γ := ⟨F, ⟨inst, hlub⟩, M, τ, hτ, t, h⟩

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
`strongCompleteness_of_compact` (`StrongCompleteness.lean`) being independently dischargeable at
`BXCanonical.completeness`, and kept live there precisely so that `CompactBase` was isolated as
the whole of what remained. `compactBase` now supplies it, and
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
def StrongCompletenessBase : Prop := StrongCompleteness FrameClass.Base

/-- Semantic compactness of the Base consequence relation, stated in the form the completeness
    derivation actually consumes: a set-consequence yields a *finite* premise list whose
    `foldr`-implication into the conclusion is valid. This is the whole of what
    `strongCompleteness_of_compact` needs beyond its engine at this class; it is supplied by
    `compactBase` in `FormalSystem/Metalogic/Compactness.lean`. -/
def CompactBase : Prop := Compact FrameClass.Base

/-- Satisfiability of a possibly-infinite set over arbitrary carriers — `SatisfiableSet` at
    `FrameClass.Base`. This is `FormulaSatisfiable` (`Validity.lean`) at `valid`'s binder list,
    with the conclusion generalised from a single formula to `∀ ψ ∈ Γ`; equivalently
    `SatisfiableDenseSet` with the `DenselyOrdered` binder dropped.

    **One binder slot was absorbed by the collapse.** `SatisfiableSet` carries the frame
    condition as an anonymous `fc.Sat F` binder, and `Sat .Base` is `True`, so this predicate
    has one existential component more than its pre-collapse form did — a `∃ _ : True`. The two
    forms are propositionally equivalent but not definitionally equal. An introduction site that
    used to write `⟨F, M, τ, hτ, t, h⟩` should call `SatisfiableSet.base_of_forall`, which
    discharges the slot with `trivial`; an elimination site adds one `_` to its pattern. -/
def SatisfiableBaseSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Base Γ

/-- The model-existence form, which is what an ultraproduct construction proves directly:
    finite satisfiability of every finite sublist lifts to satisfiability of the whole set.
    `ModelExistenceBase → CompactBase` is a contraposition through the `Formula.neg` clause of
    `TruthAt` together with `truthAt_foldr_imp`, and it **is proved** — as the `.Base` instance
    of `compact_of_modelExistence` in `FormalSystem/Metalogic/StrongCompleteness.lean`. It is
    not proved *here* for the import-cycle reason recorded under `## Downstream` above:
    `truthAt_foldr_imp` is owned by that module, and that module imports this one.
    `ModelExistenceBase` itself is proved as `modelExistenceBase` in
    `FormalSystem/Metalogic/Compactness.lean`, by the ultraproduct construction this docstring
    anticipates. -/
def ModelExistenceBase : Prop := ModelExistence FrameClass.Base

/-! ## Strong completeness, compactness and model existence for `FrameClass.Dense`

These four definitions are **statements**. None of them is discharged in this module; all four
are discharged in `Metalogic/Compactness.lean`. `CompactDense` was for a long time the
entire remaining obligation for Dense strong completeness (the single-formula engine hypothesis
being independently dischargeable — see the note on `strongCompleteness_of_compact` in
`StrongCompleteness.lean`); `compactDense` now supplies it, and `strongCompletenessDense`
collects the result.
-/

/-- **Strong completeness for `FrameClass.Dense`** — the reserved statement. Note that
    `FrameClass` (`ProofSystem/Axioms.lean:519`) has constructors `Base | Dense | Discrete |
    Dedekind`; there is no `.DedekindDense` constructor, and `FrameClass.Dense` is the correct
    target for the `SetSemanticConsequenceDense` relation. -/
def StrongCompletenessDense : Prop := StrongCompleteness FrameClass.Dense

/-- Semantic compactness of the Dense consequence relation, stated in the form the
    completeness derivation actually consumes: a set-consequence yields a *finite* premise list
    whose `foldr`-implication into the conclusion is Dense-valid. -/
def CompactDense : Prop := Compact FrameClass.Dense

/-- Satisfiability of a possibly-infinite set over dense carriers. This is
    `FormulaSatisfiable` (`Validity.lean:190`) with `(_ : DenselyOrdered D)` inserted in
    `ValidDense`'s binder position and the conclusion generalised from a single formula to
    `∀ ψ ∈ Γ`. -/
def SatisfiableDenseSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Dense Γ

/-- The model-existence form, which is what an ultraproduct construction proves directly:
    finite satisfiability of every finite sublist lifts to satisfiability of the whole set.
    `ModelExistenceDense → CompactDense` is a contraposition through the `Formula.neg` clause of
    `TruthAt` together with `truthAt_foldr_imp` (`StrongCompleteness.lean`), and it **is
    proved** — as the `.Dense` instance of `compact_of_modelExistence` in that same module. It is
    not proved
    *here* for the import-cycle reason recorded under `## Downstream` above.
    `ModelExistenceDense` itself is proved as `modelExistenceDense` in
    `FormalSystem/Metalogic/Compactness.lean`, by the ultraproduct construction this docstring
    anticipates. -/
def ModelExistenceDense : Prop := ModelExistence FrameClass.Dense

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
def StrongCompletenessDiscrete : Prop := StrongCompleteness FrameClass.Discrete

/-- Satisfiability of a possibly-infinite set over discrete carriers — `SatisfiableSet` at
    `FrameClass.Discrete`. This is `FormulaSatisfiable` (`Validity.lean`) with `ValidDiscrete`'s
    binder list — `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean` — in place
    of `ValidDense`'s `DenselyOrdered`, and the conclusion generalised from a single formula to
    `∀ ψ ∈ Γ`.

    **The four class binders re-nested under the collapse.** `Sat .Discrete` is
    `TaskFrame.IsSuccArchDiscrete` (`Semantics/FrameProperty.lean`), a plain `def` wrapping
    `∃ (_ : SuccOrder D) (_ : PredOrder D), _ ∧ _`, and the anonymous constructor does not unfold
    it. So the flat ten-component tuple this predicate used to accept no longer elaborates: an
    introduction site should call `SatisfiableSet.discrete_of_forall`, which takes the four
    witnesses flat as instance arguments, and an elimination pattern needs exactly one nesting
    pair, `⟨F, ⟨_, _, _, _⟩, M, τ, hτ, t, h⟩`.

    Inside that nesting the four binders stay **anonymous**. When this existential is
    destructured, use bare `_` names and let instance synthesis recover them: naming them and
    re-installing with `haveI` drops the value and breaks definitional equality with the
    instances baked into `F`'s and `M`'s types. -/
def SatisfiableDiscreteSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Discrete Γ

/-- Semantic compactness of the Discrete consequence relation, in the same shape as
    `CompactDense`: a set-consequence yields a *finite* premise list whose `foldr`-implication
    into the conclusion is Discrete-valid.

    **This statement is false.** See `discrete_consequence_not_compact`. -/
def CompactDiscrete : Prop := Compact FrameClass.Discrete

/-! ## Strong completeness, compactness, satisfiability and model existence for
`FrameClass.Dedekind`

The fourth and last row of the `FrameClass`-indexed family, completing the table. Like the
Discrete block above, these are **statements, not results**, and two of them are settled
*negatively*: `CompactDedekind` and `StrongCompletenessDedekind` are *refuted* downstream in
`Metalogic/DedekindNonCompactness.lean`, by `dedekind_consequence_not_compact` and
`strongCompletenessDedekind_refuted` respectively, which exhibit the premise set
`{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤ : n ∈ ℕ}` as finitely satisfiable over `ℝ` yet unsatisfiable over
every Dedekind-complete carrier. That witness is a *new* one: `DiscreteNonCompactness.lean`'s
`archWitness` does not port, because `Formula.next` is vacuously false on a densely ordered
carrier.

Naming the row costs nothing beyond the four instantiations below: the `.Dedekind` binder-shape
adapters (`SatisfiableSet.dedekind_of_forall`, `SetSemanticConsequenceDedekindDense.of_forall` /
`.apply`) already exist above, so no new adapter and no new binder list is introduced here.

No import change is required: `DenselyOrdered` is already in scope via
`SetSemanticConsequenceDedekindDense` above.
-/

/-- **Strong completeness for `FrameClass.Dedekind`** — the `StrongCompletenessDense` statement
    with `SetSemanticConsequenceDedekindDense` in place of `SetSemanticConsequenceDense` and
    `FrameClass.Dedekind` as the derivability target.

    **This statement is false.** See `strongCompletenessDedekind_refuted` in
    `Metalogic/DedekindNonCompactness.lean`. It is stated here so that the refutation has
    something to name; it is not a reserved obligation. Reynolds 1992 §9 Theorem 7 remains
    correctly cited elsewhere as the *weak* completeness result for this class — the refutation
    does not contradict it, it explains why only weak completeness is available. -/
def StrongCompletenessDedekind : Prop := StrongCompleteness FrameClass.Dedekind

/-- Semantic compactness of the Dedekind consequence relation, in the same shape as
    `CompactDense`: a set-consequence yields a *finite* premise list whose `foldr`-implication
    into the conclusion is Dedekind-valid.

    **This statement is false.** See `dedekind_consequence_not_compact` in
    `Metalogic/DedekindNonCompactness.lean`. -/
def CompactDedekind : Prop := Compact FrameClass.Dedekind

/-- Satisfiability of a possibly-infinite set over Dedekind-complete dense carriers —
    `SatisfiableSet` at `FrameClass.Dedekind`. This is `FormulaSatisfiable` (`Validity.lean`)
    with `ValidDedekindDense`'s binder list — `[DenselyOrdered D]` together with the
    least-upper-bound hypothesis — in place of `ValidDense`'s `DenselyOrdered` alone, and the
    conclusion generalised from a single formula to `∀ ψ ∈ Γ`.

    `Sat .Dedekind` is `TaskFrame.IsDedekind`, i.e. `IsDense ∧ IsComplete`, so a destructuring
    pattern needs exactly one nesting pair here, `⟨F, ⟨hd, hlub⟩, M, τ, hτ, t, h⟩`, and an
    introduction site should call `SatisfiableSet.dedekind_of_forall` above. Note that the
    destructured `hd : F.IsDense` is **not** visible to instance search — `TaskFrame.IsDense` is
    a `def` whose head is not `DenselyOrdered` — so a `haveI : DenselyOrdered F.Duration := hd`
    is needed before any `ValidDedekindDense.apply` or `soundness_dedekind` call. Unlike the
    Discrete case, that `haveI` is safe: no `DenselyOrdered` instance is baked into `F`'s or
    `M`'s type. -/
def SatisfiableDedekindSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Dedekind Γ

/-- The model-existence form at `FrameClass.Dedekind` — `ModelExistence` at that tag.

    **Vocabulary only: nothing is proved or refuted about this statement anywhere in the tree.**
    It is stated so that the Dedekind row of the family is complete and symmetric with the other
    three. Note that it is *not* an open question of the same kind as the Base/Dense model
    existence results were: `ModelExistence fc → Compact fc` is `compact_of_modelExistence`
    (`Metalogic/StrongCompleteness.lean`), and `CompactDedekind` is refuted, so
    `ModelExistenceDedekind` is refutable as an immediate corollary. That corollary is simply
    not drawn here. -/
def ModelExistenceDedekind : Prop := ModelExistence FrameClass.Dedekind

end FormalSystem.Metalogic
