/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity
import FormalSystem.ProofSystem.Derivable

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
`Metalogic/DiscreteNonCompactness.lean`, by `notCompactDiscrete` and
`notStrongCompletenessDiscrete`. The Base/Dense statements and the Discrete ones must not
be read as sharing a status — the Base and Dense questions are settled positively, the Discrete
one negatively.

## Design

* `SetDerivable` is deliberately shaped to match `Core.SetConsistent`
  (`Metalogic/Core/MaximalConsistent.lean`) so that the two compose without an adapter: a
  derivation is a finite object and can cite only finitely many premises, so finitary
  set-derivability is the only derivability notion a finitary proof system can support over
  `Set Formula`. This module does **not** import `Core/MaximalConsistent.lean` — the shaping is a
  design constraint honoured here, not a dependency; the bridge lemmas that did consume that
  import had no consumers of their own and were deleted with it.
* Each `SetSemanticConsequence*` predicate is the corresponding validity predicate's binder list
  taken verbatim from `FormalSystem/Semantics/Validity.lean`, with the premise hypothesis
  `(∀ ψ ∈ Γ, TruthAt M τ t ψ)` inserted before the conclusion — the same surgery that
  `SemanticConsequenceDedekind` (`StrongCompleteness.lean:129`) performs on
  `ValidDedekind`. `Γ : Set Formula` rather than `Γ : Context` is the only difference from
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

/-- Set-based semantic consequence over `FrameClass.Discrete`. Stated for completeness of the
layer; strong completeness at this class is refuted by non-compactness. -/
def SetSemanticConsequenceDiscrete (Γ : Set Formula) (φ : Formula) : Prop :=
  SetSemanticConsequenceOn FrameClass.Discrete Γ φ

/-- Set-based semantic consequence over dense Dedekind-complete frames — the
`soundness_dedekind` target class. Non-compact. -/
def SetSemanticConsequenceDedekind (Γ : Set Formula) (φ : Formula) : Prop :=
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

/-- **A pointed model of `Γ` over the frames of `fc`.** The witness data that satisfiability
asserts the existence of, as a named structure with named fields rather than a seven-component
anonymous existential.

`SatisfiableSet fc Γ` below is `Nonempty` of this. The change is one of presentation, not of
content: `rcases`/`obtain` auto-flattens through `Nonempty` plus a single-constructor structure,
so every existing destructuring site — `compact_of_modelExistence`, `archWitness_not_satisfiable`,
`dedWitness_not_satisfiable`, the refutation skeleton, `modelExistence{Base,Dense}`'s `refine` —
compiles against the old pattern unchanged. What the structure buys is the *other* direction: a
proof that wants one component can now write `P.time` or `P.inClass` instead of destructuring
seven binders to reach it, and a docstring can name a field instead of counting positions.

The `inClass` field holds the frame condition. At `.Discrete` that is
`TaskFrame.IsSuccArchDiscrete Frame` (`Semantics/FrameProperty.lean`), itself a four-component
nested existential which neither the structure nor the anonymous constructor unfolds, so a
destructuring pattern still needs exactly one nesting pair there. -/
structure PointedModel (fc : FrameClass) (Γ : Set Formula) where
  /-- The witnessing frame. -/
  Frame : TaskFrame
  /-- Its membership in the class: `fc`'s frame condition, read off the tag by `FrameClass.Sat`. -/
  inClass : fc.Sat Frame
  /-- A model over that frame. -/
  Model : TaskModel Frame
  /-- The history at which `Γ` is witnessed. -/
  hist : WorldHistory Frame
  /-- That history is total. -/
  htotal : hist.IsTotal
  /-- The time at which `Γ` is witnessed. -/
  time : Frame.Duration
  /-- Every member of `Γ` is true there. -/
  models : ∀ ψ ∈ Γ, TruthAt Model hist time ψ

/-- Satisfiability of a possibly-infinite set over the frames of `fc`: some frame satisfying
`fc`, together with a model, a total history and a time, makes every member of `Γ` true at
once. This is `FormulaSatisfiable` (`Validity.lean`) at `ValidIn fc`'s binder list, with the
conclusion generalised from a single formula to `∀ ψ ∈ Γ`.

Stated as `Nonempty (PointedModel fc Γ)` rather than as a bare `∃`-chain, so that the witness
data carries field names — see `PointedModel` directly above, including why this is source-
compatible with the existing destructuring sites. `PointedModel.of` / `SatisfiableSet.of_forall`
below restore the flat binder shape at introduction sites. -/
def SatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop :=
  Nonempty (PointedModel fc Γ)

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

/-- **Weak completeness at `fc`** — the single-formula statement: every `fc`-valid formula is
derivable from the empty context at `fc`.

This is the third member of the family, sitting below `StrongCompleteness` above and beside
`Compact`, and it is the name the rest of the tree was missing. Every theorem in
`Metalogic/StrongCompleteness.lean` and `Metalogic/Conservativity/TMCompletenessReduction.lean` that used to
carry a longhand `engine : ∀ ψ : Formula, ValidIn fc ψ → Derivable fc [] ψ` hypothesis now
quotes this one name instead; the four hypotheses were the same predicate written out four
times.

**The four `BXCanonical` engines inhabit it on the nose**, with no transport and no `rfl`
lemma: `Valid`, `ValidDense`, `ValidDiscrete` and `ValidDedekind` are all abbreviations over
`ValidIn` at a literal tag (`Semantics/Validity.lean`), so `completeness_base`,
`completeness_dense`, `completeness_discrete` and `completeness_dedekind`
(`Metalogic/StrongCompleteness.lean`) *are* `WeakCompleteness .Base` / `.Dense` / `.Discrete` /
`.Dedekind` by type rather than by convention.

Stating it here rather than in `Metalogic/StrongCompleteness.lean` costs nothing: its two
ingredients `ValidIn` and `Derivable` are already imported by this module (`:8`, `:10`), and
placing it beside `StrongCompleteness` keeps the whole `Prop`-valued vocabulary of the
completeness programme in one layer. The `strongCompleteness_iff_compact` bridge that consumes
it must still live downstream, for the same import-cycle reason recorded under `## Downstream`
above. -/
def WeakCompleteness (fc : FrameClass) : Prop :=
  ∀ ψ : Formula, ValidIn fc ψ → Derivable fc [] ψ

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

The pre-collapse binder shapes, restored — **once, generically**, not once per tag. The frame
condition travels as the single `fc.Sat F` argument, and a proof that needs it taken apart calls
`sat_intro` (`Semantics/FrameClassValidity.lean`), which registers the density instance at
`.Dense`/`.Dedekind` and destructures `TaskFrame.IsSuccArchDiscrete` at `.Discrete`. The four
per-class `SetSemanticConsequence*.{of_forall, apply}` pairs that used to live here existed only
because a `Sat .Dense F` hypothesis was once invisible to instance search; `FrameClass.Sat` is now
`@[reducible]`, so they were deleted rather than maintained. -/

/-- Introduce `SetSemanticConsequenceOn` at an arbitrary tag from the frame-condition-explicit
binder shape. The body is `h`: `SetConsequenceOnFrames` already quantifies over the unbundled
`(τ : WorldHistory F) (_ : τ.IsTotal)` pair. This replaced the four class-specific
`SetSemanticConsequence{Base,Dense,Discrete,DedekindDense}.of_forall` adapters, each of which was
this lemma at a fixed tag. -/
theorem SetSemanticConsequenceOn.of_forall_total {fc : FrameClass} {Γ : Set Formula}
    {φ : Formula}
    (h : ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F),
           τ.IsTotal → ∀ t : F.Duration, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :
    SetSemanticConsequenceOn fc Γ φ :=
  h

/-- Eliminate `SetSemanticConsequenceOn` at an arbitrary tag into the frame-condition-explicit
binder shape. This replaced the four class-specific `.apply` adapters. -/
theorem SetSemanticConsequenceOn.apply_total {fc : FrameClass} {Γ : Set Formula} {φ : Formula}
    (h : SetSemanticConsequenceOn fc Γ φ) (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (hΓ : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  h F hF M τ hτ t hΓ

/-! ### `SatisfiableSet` binder-shape adapter

The same service `SetSemanticConsequenceOn.of_forall_total` above performs, on the introduction
side of `SatisfiableSet`, and likewise a single `fc`-indexed declaration where four tag-specific
ones used to stand. It takes the frame condition in the single `fc.Sat F` slot; a site holding
the four discrete instances flat reaches that slot through
`TaskFrame.isSuccArchDiscrete_of_instances` (`Semantics/FrameProperty.lean`). It serves every
`SatisfiableSet` name stated at the end of this module (`SatisfiableBaseSet`,
`SatisfiableDenseSet`, `SatisfiableDiscreteSet`, `SatisfiableDedekindSet`) and is what both
`Metalogic/DedekindNonCompactness.lean` and `Metalogic/DiscreteNonCompactness.lean` use at their
introduction sites. -/

/-- Build a `PointedModel` from the flat binder shape: a witness frame, its frame condition, and
a model/history/time at which every member of `Γ` is true. A `def`, not a `theorem` —
`PointedModel` lives in `Type`, so a `theorem` here fails with "type of theorem is not a
proposition". -/
def PointedModel.of {fc : FrameClass} {Γ : Set Formula} (F : TaskFrame)
    (hF : fc.Sat F) (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : PointedModel fc Γ :=
  ⟨F, hF, M, τ, hτ, t, h⟩

/-- Introduce `SatisfiableSet` at an arbitrary tag from the same flat binder shape — `PointedModel.of`
wrapped in `Nonempty.intro`, retained under its original name because every introduction site in
the tree calls it. This replaced the four
`SatisfiableSet.{base,dense,discrete,dedekind}_of_forall` adapters: each of those was this lemma
at a fixed tag with `fc.Sat F` unfolded to that class's frame condition, which is the only thing
that made four copies look necessary. -/
theorem SatisfiableSet.of_forall {fc : FrameClass} {Γ : Set Formula} (F : TaskFrame)
    (hF : fc.Sat F) (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : SatisfiableSet fc Γ :=
  ⟨PointedModel.of F hF M τ hτ t h⟩

/-! ### Monotonicity and finite satisfiability -/

/-- **A pointed model of `Δ` is a pointed model of every subset of `Δ`.** Only the `models` field
changes; the frame, model, history and time are carried across untouched. A `def`, not a
`theorem`, for the same `Type`-valued reason as `PointedModel.of`. -/
def PointedModel.mono {fc : FrameClass} {Γ Δ : Set Formula} (h_sub : Γ ⊆ Δ)
    (P : PointedModel fc Δ) : PointedModel fc Γ :=
  { P with models := fun ψ hψ => P.models ψ (h_sub hψ) }

/-- **Satisfiability is antitone in the premise set**: a model of a larger set models any subset
of it. `PointedModel.mono` under `Nonempty`. -/
theorem SatisfiableSet.mono {fc : FrameClass} {Γ Δ : Set Formula} (h_sub : Γ ⊆ Δ)
    (h : SatisfiableSet fc Δ) : SatisfiableSet fc Γ :=
  h.elim fun P => ⟨P.mono h_sub⟩

/-- **Finite satisfiability**: every finite sublist of `Γ` is satisfiable. The hypothesis of
`ModelExistence` and of `not_compact_of_witness` (`Metalogic/StrongCompleteness.lean`), named so
that compactness can be read as "satisfiable iff finitely satisfiable" rather than as a
quantifier chain. -/
def FinitelySatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableSet fc {ψ | ψ ∈ L}

/-- **Satisfiable implies finitely satisfiable**, unconditionally and at every class. The easy
direction of the equivalence; `SatisfiableSet.mono` is the whole proof. -/
theorem SatisfiableSet.finitelySatisfiable {fc : FrameClass} {Γ : Set Formula}
    (h : SatisfiableSet fc Γ) : FinitelySatisfiableSet fc Γ :=
  fun _ hL => h.mono (fun ψ hψ => hL ψ hψ)

/-- **Model existence is exactly the converse direction**, by unfolding. Recorded as an `Iff.rfl`
so that `ModelExistence fc` can be quoted in either phrasing without a transport step. -/
theorem modelExistence_iff_finitelySatisfiable {fc : FrameClass} :
    ModelExistence fc ↔ ∀ Γ : Set Formula, FinitelySatisfiableSet fc Γ → SatisfiableSet fc Γ :=
  Iff.rfl

/-- **"Satisfiable iff finitely satisfiable"** — compactness in its model-theoretic phrasing, at
any class supplying model existence.

The `mp` direction is unconditional (`SatisfiableSet.finitelySatisfiable`); the `mpr` direction
*is* model existence. Given `Compact fc` instead, route through `compact_iff_modelExistence`
(`Metalogic/StrongCompleteness.lean`) to obtain the `hme` this wants. -/
theorem satisfiableSet_iff_finitelySatisfiable {fc : FrameClass} (hme : ModelExistence fc)
    (Γ : Set Formula) : SatisfiableSet fc Γ ↔ FinitelySatisfiableSet fc Γ :=
  ⟨SatisfiableSet.finitelySatisfiable, hme Γ⟩

/-- **Set-consequence is refutation-unsatisfiability**, at any class: `Γ ⊨ φ` exactly when
`Γ ∪ {¬φ}` has no model.

`Formula.neg φ` is `φ.imp ⊥` (`Syntax/Formula.lean`) and `TruthAt M τ t ⊥` is `False`
(`Semantics/Truth.lean`), so `TruthAt M τ t φ.neg` is *definitionally* `TruthAt M τ t φ → False`;
no `truthAt_neg` lemma is needed or exists, in either direction of this proof.

`setConsequence_of_not_satisfiable` (`Metalogic/StrongCompleteness.lean`) is the special case
where `Γ` itself is already unsatisfiable, and is kept separately because that is the form all
four refutations consume. -/
theorem setConsequence_iff_not_satisfiable {fc : FrameClass} {Γ : Set Formula} {φ : Formula} :
    SetSemanticConsequenceOn fc Γ φ ↔ ¬ SatisfiableSet fc (Γ ∪ {φ.neg}) := by
  constructor
  · rintro h ⟨F, hF, M, τ, hτ, t, hsat⟩
    exact hsat φ.neg (Set.mem_union_right _ rfl)
      (h F hF M τ hτ t (fun ψ hψ => hsat ψ (Set.mem_union_left _ hψ)))
  · intro h
    refine SetSemanticConsequenceOn.of_forall_total ?_
    intro F hF M τ hτ t hall
    by_contra hnφ
    refine h (SatisfiableSet.of_forall F hF M τ hτ t ?_)
    rintro ψ (hψ | rfl)
    · exact hall ψ hψ
    · exact hnφ

/-! ## Monotonicity -/

/-- **The one monotonicity-in-`Γ` lemma.** Set-consequence over any frame predicate is monotone
in the premise set. The four per-class copies below are one-line corollaries; before the collapse
each was a separate four-line proof differing only in how many binders its `intro` consumed. -/
theorem setConsequenceOnFrames_mono {P : TaskFrame → Prop} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetConsequenceOnFrames P Γ φ) : SetConsequenceOnFrames P Δ φ := by
  intro F hF M τ hτ t h_all
  exact h F hF M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

/-! ## Finite restriction and agreement with the finite-context layer -/

/-- Every set-derivation restricts to a finite context. Definitional, but worth naming: it is
    the statement the compactness argument consumes. -/
theorem setDerivable_iff_exists_finite {fc : FrameClass} (Γ : Set Formula) (φ : Formula) :
    SetDerivable fc Γ φ ↔ ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ :=
  Iff.rfl

/-! ## Strong completeness, compactness and model existence for `FrameClass.Base`

These four definitions are **statements**, exactly as their Dense siblings below are. None of
them is discharged in this module; all four are discharged in
`Metalogic/Compactness.lean`. `CompactBase` was for a long time the entire remaining
obligation for Base strong completeness — the single-formula engine hypothesis of
`strongCompleteness_of_compact` (`StrongCompleteness.lean`) being independently dischargeable at
`BXCanonical.completeness`, and kept live there precisely so that `CompactBase` was isolated as
the whole of what remained. `compactBase` now supplies it, and
`strongCompletenessBase` collects the result.

Each definition is its Dense sibling with `SetSemanticConsequenceOn .Base` / `Valid` in place of
`SetSemanticConsequenceOn .Dense` / `ValidDense` and the `[DenselyOrdered D]` binder dropped —
there is no third axis of variation.

Base's status is **proved**, the same status as Dense and distinct from both Discrete and
Dedekind, which are refuted below (in `Metalogic/DiscreteNonCompactness.lean` and
`Metalogic/DedekindNonCompactness.lean` respectively). Proved and refuted must not be read as
sharing a status.
-/

/-- **Strong completeness for `FrameClass.Base`** — the statement. The
    `StrongCompletenessDense` statement with `SetSemanticConsequenceOn .Base` in place of
    `SetSemanticConsequenceOn .Dense` and `FrameClass.Base` as the derivability target. Proved as
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
    `FrameClass.Base`. This is `FormulaSatisfiable` (`Validity.lean`) at `Valid`'s binder list,
    with the conclusion generalised from a single formula to `∀ ψ ∈ Γ`; equivalently
    `SatisfiableDenseSet` with the `DenselyOrdered` binder dropped.

    **One binder slot was absorbed by the collapse.** `SatisfiableSet` carries the frame
    condition as an anonymous `fc.Sat F` binder, and `Sat .Base` is `True`, so this predicate
    has one existential component more than its pre-collapse form did — a `∃ _ : True`. The two
    forms are propositionally equivalent but not definitionally equal. An introduction site that
    used to write `⟨F, M, τ, hτ, t, h⟩` should call `SatisfiableSet.of_forall` with `trivial`
    in the frame-condition slot; an elimination site adds one `_` to its pattern. -/
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
    target for the `SetSemanticConsequenceOn .Dense` relation. -/
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
`notCompactDiscrete` and `notStrongCompletenessDiscrete` respectively, which
exhibit the premise set `{F p} ∪ {¬Xⁿ p : n ∈ ℕ}` as finitely satisfiable over `ℤ` yet
unsatisfiable over every Archimedean discrete carrier. Nothing about those refutations is
imported here; this module supplies only the vocabulary they are stated in.

No import change is required for these: `IsSuccArchimedean` and `IsPredArchimedean` are already
in scope via `SetSemanticConsequenceDiscrete` above.
-/

/-- **Strong completeness for `FrameClass.Discrete`** — the `StrongCompletenessDense` statement
    with `SetSemanticConsequenceDiscrete` in place of `SetSemanticConsequenceOn .Dense`.

    **This statement is false.** See `notStrongCompletenessDiscrete`. It is stated here so
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
    introduction site should call `SatisfiableSet.of_forall` with
    `TaskFrame.isSuccArchDiscrete_of_instances` (`Semantics/FrameProperty.lean`) in the
    frame-condition slot, and an elimination pattern needs exactly one nesting pair,
    `⟨F, ⟨_, _, _, _⟩, M, τ, hτ, t, h⟩` — or a single `hF` passed straight back to
    `ValidIn.apply_total`.
 -/
def SatisfiableDiscreteSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Discrete Γ

/-- Semantic compactness of the Discrete consequence relation, in the same shape as
    `CompactDense`: a set-consequence yields a *finite* premise list whose `foldr`-implication
    into the conclusion is Discrete-valid.

    **This statement is false.** See `notCompactDiscrete`. -/
def CompactDiscrete : Prop := Compact FrameClass.Discrete

/-! ## Strong completeness, compactness, satisfiability and model existence for
`FrameClass.Dedekind`

The fourth and last row of the `FrameClass`-indexed family, completing the table. Like the
Discrete block above, these are **statements, not results**, and two of them are settled
*negatively*: `CompactDedekind` and `StrongCompletenessDedekind` are *refuted* downstream in
`Metalogic/DedekindNonCompactness.lean`, by `notCompactDedekind` and
`notStrongCompletenessDedekind` respectively, which exhibit the premise set
`{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤ : n ∈ ℕ}` as finitely satisfiable over `ℝ` yet unsatisfiable over
every Dedekind-complete carrier. That witness is a *new* one: `DiscreteNonCompactness.lean`'s
`archWitness` does not port, because `Formula.next` is vacuously false on a densely ordered
carrier.

Naming the row costs nothing beyond the four instantiations below: the binder-shape adapters it
needs (`SatisfiableSet.of_forall`, `SetSemanticConsequenceOn.of_forall_total` / `.apply_total`)
are the generic, `fc`-indexed ones above, so no new adapter and no new binder list is introduced
here — and none is introduced for any other tag either.

No import change is required: `DenselyOrdered` is already in scope via
`SetSemanticConsequenceDedekind` above.
-/

/-- **Strong completeness for `FrameClass.Dedekind`** — the `StrongCompletenessDense` statement
    with `SetSemanticConsequenceDedekind` in place of `SetSemanticConsequenceOn .Dense` and
    `FrameClass.Dedekind` as the derivability target.

    **This statement is false.** See `notStrongCompletenessDedekind` in
    `Metalogic/DedekindNonCompactness.lean`. It is stated here so that the refutation has
    something to name; it is not a reserved obligation. Reynolds 1992 §9 Theorem 7 remains
    correctly cited elsewhere as the *weak* completeness result for this class — the refutation
    does not contradict it, it explains why only weak completeness is available. -/
def StrongCompletenessDedekind : Prop := StrongCompleteness FrameClass.Dedekind

/-- Semantic compactness of the Dedekind consequence relation, in the same shape as
    `CompactDense`: a set-consequence yields a *finite* premise list whose `foldr`-implication
    into the conclusion is Dedekind-valid.

    **This statement is false.** See `notCompactDedekind` in
    `Metalogic/DedekindNonCompactness.lean`. -/
def CompactDedekind : Prop := Compact FrameClass.Dedekind

/-- Satisfiability of a possibly-infinite set over Dedekind-complete dense carriers —
    `SatisfiableSet` at `FrameClass.Dedekind`. This is `FormulaSatisfiable` (`Validity.lean`)
    with `ValidDedekind`'s binder list — `[DenselyOrdered D]` together with the
    least-upper-bound hypothesis — in place of `ValidDense`'s `DenselyOrdered` alone, and the
    conclusion generalised from a single formula to `∀ ψ ∈ Γ`.

    `Sat .Dedekind` is `TaskFrame.IsDedekind`, i.e. `IsDense ∧ IsComplete`, so a destructuring
    pattern needs exactly one nesting pair here, `⟨F, ⟨hd, hlub⟩, M, τ, hτ, t, h⟩`, and an
    introduction site should call `SatisfiableSet.of_forall` above. The destructured
    `hd : F.IsDense` **is** visible to instance search: `TaskFrame.IsDense` is an `abbrev` and
    `FrameClass.Sat` is `@[reducible]`, so the whole chain down to `DenselyOrdered F.Duration`
    unfolds at reducible transparency and no `haveI : DenselyOrdered F.Duration := hd` is needed
    before a `soundness_dedekind` call. (That `haveI` was previously required and was safe here,
    unlike in the Discrete case, because no `DenselyOrdered` instance is baked into `F`'s or
    `M`'s type; it is now simply redundant.) -/
def SatisfiableDedekindSet (Γ : Set Formula) : Prop := SatisfiableSet FrameClass.Dedekind Γ

/-- The model-existence form at `FrameClass.Dedekind` — `ModelExistence` at that tag.

    **This statement is false.** See `modelExistenceDedekind_refuted` in
    `Metalogic/DedekindNonCompactness.lean`, which draws it as the immediate corollary it always
    was: `ModelExistence fc → Compact fc` is `compact_of_modelExistence`
    (`Metalogic/StrongCompleteness.lean`), and `CompactDedekind` is refuted, so a model-existence
    proof at this class would yield the very compactness `notCompactDedekind`
    denies. The refutation lives in that module rather than beside this definition because it
    consumes `notCompactDedekind`, and that module imports this one. -/
def ModelExistenceDedekind : Prop := ModelExistence FrameClass.Dedekind

end FormalSystem.Metalogic
