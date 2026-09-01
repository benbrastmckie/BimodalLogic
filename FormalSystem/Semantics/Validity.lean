/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Syntax.Context
import FormalSystem.Semantics.FrameClassValidity
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean

/-!
# Validity - Semantic Validity and Consequence

This module defines semantic validity and consequence for TM formulas.

## Main Definitions

- `valid`: A formula is valid if true at every **total** history, in every model
- `SemanticConsequence`: Semantic consequence relation, quantified over total histories
- `satisfiable`: A context is satisfiable if consistent (exists some temporal type)
- Notation: `⊨ φ` for validity, `Γ ⊨ φ` for semantic consequence

## Main Results

- Basic validity lemmas
- Relationship between validity and semantic consequence

## Implementation Notes

- Validity quantifies over all temporal types `D : Type*` with `LinearOrderedAddCommGroup D`
- Validity and consequence quantify over the **total** histories: `τ.IsTotal`, i.e. `∀ t, τ.domain t`.
  There is no admissible-history parameter and no shift-closure side condition anywhere in this
  module, and `TruthAt` itself no longer carries a set argument to supply.
- No shift-closure hypothesis is needed in the *statement* of validity or consequence, because
  totality is trivially preserved by `timeShift` (`WorldHistory.isTotal_timeShift`), so
  time-shift invariance no longer has a side condition to carry.
- Satisfiability existentially quantifies over a total witness history.
- Semantic consequence: truth in all models where premises true
- Used in soundness theorem: `Γ ⊢ φ → Γ ⊨ φ`
- Temporal types include Int, Rat, Real, and custom bounded types

## Paper Alignment

`def:logical-consequence` reads verbatim:

> A conclusion phi is a *logical consequence* of a set of premises Gamma --- written
> Gamma |= phi --- just in case for all models M, possible worlds tau in H_F, and times x in D,
> if M,tau,x |= gamma for all premises gamma in Gamma, then M,tau,x |= phi. A sentence phi is
> *valid* just in case |= phi.

`H_F` is the set of total histories of the frame `F`, so `τ ∈ H_F` is rendered as `τ.IsTotal`.
Our polymorphic quantification over `LinearOrderedAddCommGroup D` renders "for all models M"
and "times x in D".

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - Validity specification
* [Truth.lean](Truth.lean) - Truth evaluation
* [Context.lean](../Syntax/Context.lean) - Proof contexts
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/--
A formula is valid if it is true in all models, at all times, at every **total** history, for
every temporal type `D` satisfying `LinearOrderedAddCommGroup`.

Formally: for every temporal type `D`, every task frame `F` over `D`, every model `M` over
`F`, every history `τ` with `τ.IsTotal`, and every time `t : D`, the formula is true at
`(M, τ, t)`.

**Definition of record — `def:logical-consequence`**, verbatim:

> A conclusion phi is a *logical consequence* of a set of premises Gamma --- written
> Gamma |= phi --- just in case for all models M, possible worlds tau in H_F, and times x in D,
> if M,tau,x |= gamma for all premises gamma in Gamma, then M,tau,x |= phi. A sentence phi is
> *valid* just in case |= phi.

The "possible worlds tau in H_F" of that clause are the frame's **total** histories, which is
what `τ.IsTotal` says. There is no admissible-history parameter and no shift-closure side
condition: a shift-closure hypothesis is unnecessary in the statement of validity because
totality is trivially preserved by `timeShift` (`WorldHistory.isTotal_timeShift`), so time-shift
invariance carries no side condition to quantify over. `TruthAt` takes no set argument.

Validity also quantifies over all `x ∈ D` (all times in the temporal order), not just times in
`dom(τ)` — for a total history those coincide.

Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs.
-/
def valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    TruthAt M τ t φ

/--
Notation for validity: `⊨ φ` means `valid φ`.
-/
notation:50 "⊨ " φ:50 => valid φ

/--
Semantic consequence: `Γ ⊨ φ` means φ is true in all models where all of `Γ` are true,
for every temporal type `D` satisfying `LinearOrderedAddCommGroup`.

Formally: for every temporal type `D`, at every model, **total** history and time where all
formulas in `Γ` are true, formula `φ` is also true.

**Definition of record — `def:logical-consequence`**, verbatim:

> A conclusion phi is a *logical consequence* of a set of premises Gamma --- written
> Gamma |= phi --- just in case for all models M, possible worlds tau in H_F, and times x in D,
> if M,tau,x |= gamma for all premises gamma in Gamma, then M,tau,x |= phi. A sentence phi is
> *valid* just in case |= phi.

This is that clause on the nose: "possible worlds tau in H_F" is `τ.IsTotal`, and the
quantification is over all `x ∈ D` (all times in the temporal order), not just times in
`dom(τ)`. No admissible-history parameter, no shift-closure side condition.

Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs.
-/
def SemanticConsequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) →
    TruthAt M τ t φ

/--
Notation for semantic consequence: `Γ ⊨ φ`.
-/
notation:50 Γ:50 " ⊨ " φ:50 => SemanticConsequence Γ φ

/--
A context is satisfiable in temporal type `D` if there exists a model where all formulas
in the context are true.

The witness history is required to be **total** (`τ.IsTotal`), which is the exact dual of the
totality constraint in `valid`: `satisfiable D Γ` and validity-style quantification range over
the same class of histories, so `¬satisfiable` and consequence line up (see
`unsatisfiable_implies_all`).

**No paper anchor.** Unlike `valid` and `SemanticConsequence`, which render
`def:logical-consequence` verbatim, satisfiability has no counterpart in the definitions of
record. Its totality constraint and its `[Nontrivial D]` binder are a **design decision**
inherited from `valid` so that the two notions are duals over one and the same history class —
not a reconciliation finding, and not attributable to any definition anchor.

This is the semantic notion of consistency relative to a temporal type.
For absolute satisfiability (exists in some type), use `∃ D, satisfiable D Γ`.

**Note**: Satisfiability quantifies over all times `t : D`, not just domain times.
-/
def satisfiable (D : TemporalOrder) (Γ : Context) : Prop :=
  ∃ (F : FrameOver D) (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (_ : τ.IsTotal) (t : ↑D),
    ∀ φ ∈ Γ, TruthAt M τ t φ

/--
A context is absolutely satisfiable if it is satisfiable in some temporal type.

Carries `Nontrivial` alongside the other structure binders so that `satisfiable` applies; see
the "No paper anchor" note on `satisfiable`.
-/
def SatisfiableAbs (Γ : Context) : Prop :=
  ∃ D : TemporalOrder, satisfiable D Γ

/--
A single formula is satisfiable if there exists a model where it is true at some point.

This is the single-formula version of `satisfiable` (which works on contexts).
A formula is satisfiable if there exists some temporal type D, some task frame,
some model, some world history, and some time where the formula evaluates to true.

**Usage**: Used in the Finite Model Property to connect formula satisfiability
to the existence of finite models.

**Relationship to Context Satisfiability**:
`FormulaSatisfiable φ ↔ satisfiable Int [φ]` (for Int time, but holds for any D)

**No paper anchor** — see the note on `satisfiable`. The totality constraint on the witness
history and the `Nontrivial` binder are inherited from `valid` as a design decision.
-/
def FormulaSatisfiable (φ : Formula) : Prop :=
  ∃ (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    TruthAt M τ t φ

/-! ## Frame-relative validity `⊨_F` (`def:frame-validity`)

Charter §8's optional deliverable. Everything above quantifies over *all* frames; this section
adds the notion that holds a single frame fixed.

**Definition of record — `def:frame-validity`**, verbatim:

> A well-formed sentence phi of BL is *valid over a task frame* F = ⟨W, D, ⇒⟩ which we may write
> |=_F phi if and only if M,tau,x |= phi for every model M = ⟨W, D, ⇒, |·|⟩ where
> F = ⟨W, D, ⇒⟩, possible world tau in H_F, and time x in D.

**No notation is introduced for `⊨_F`.** `Truth.lean` records that a `TruthAt` notation was
dropped because it conflicts with the `⊨` validity notation in this file; a subscripted variant
would sit in the same parser neighbourhood for no gain. The ASCII name `TaskFrame.ValidOn` is
used instead, and dot-notation (`F.ValidOn φ`) reads as the paper's `⊨_F φ` does.

**This is not a parallel validity notion.** `valid_iff_forall_validOn` below proves the two are
related by quantification over frames, so `ValidOn` is a specialization of the one validity
predicate rather than a competitor to it — the same discipline `TaskFrame.HF` follows with
respect to `WorldHistory.IsTotal`.
-/

/--
`def:frame-validity`: `φ` is **valid over the frame `F`** iff it is true at every model over `F`,
every possible world `τ ∈ H_F`, and every time `x ∈ D`.

Recorded source (`def:frame-validity`, verbatim): "A well-formed sentence $\varphi$ of $\BL$ is
\emph{valid over a task frame} $\F = \tuple{W, \D, \Rightarrow}$ which we may write
$\vDash_{\F} \varphi$ if and only if $\M,\tau,x \vDash \varphi$ for every model
$\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where $\F = \tuple{W, \D, \Rightarrow}$, possible
world $\tau \in H_{\F}$, and time $x \in D$."

Each of the three quantifiers is rendered on the nose:

* "every model `M = ⟨W, D, ⇒, |·|⟩` where `F = ⟨W, D, ⇒⟩`" is `∀ M : TaskModel F` — the frame is
  a *parameter* of `TaskModel`, so the side condition that `M`'s frame reduct is `F` is carried
  by the type rather than by a hypothesis.
* "possible world `τ ∈ H_F`" is `∀ τ : F.HF`, the bundled subtype. Per `WorldHistory.lean`'s
  encoding note, the bundled form is used exactly where `H_F` appears as an object in its own
  right, which is how the recorded text reads here.
* "time `x ∈ D`" is `∀ x : D` — all of the temporal order, not merely `dom(τ)`; for a total `τ`
  the two coincide.

Unlike `valid`, this carries no `[Nontrivial D]` binder: `valid` needs it to state its
quantification over temporal types, whereas here `D` and `F` are both already given.
-/
def TaskFrame.ValidOn (F : TaskFrame) (φ : Formula) : Prop :=
  ∀ (M : TaskModel F) (τ : TaskFrame.HF F) (x : F.Duration), TruthAt M τ.val x φ

namespace TaskFrame

/--
Frame-relative validity is **never vacuous**: no frame validates `⊥`.

Without this, `F.ValidOn` would be satisfied trivially by any frame whose `H_F` happened to be
empty, and `F.ValidOn ⊥` would be a theorem rather than a refutation. What rules that out is
exactly `cor:occurrence`'s closing clause — `H_F ≠ ∅` — so the frame axioms it consumes appear
here as hypotheses.

**Wholly frame-intrinsic.** *Spherical*, *Seriality*, *Interpolation* and *Limit* are not
arguments: `FrameOver` carries them as structure fields, and `cor:occurrence` reads them off the
frame. Neither is a world state: the carrier's nonemptiness is the `nonempty` field, so the
statement is the bare `¬ F.ValidOn ⊥` with `F` its only argument, exactly as `def:frame`'s
"nonempty set of world states" licenses.

The model witness is `TaskModel.allFalse`; any model would do, since `⊥`'s truth clause is
`False` independently of the valuation.
-/
theorem not_validOn_bot (F : TaskFrame) : ¬ F.ValidOn Formula.bot := by
  intro hvalid
  obtain ⟨τ, _⟩ := PartialHistory.occurrence F F.worldNonempty.some 0
  exact Truth.bot_false (hvalid TaskModel.allFalse τ 0)

/--
`cor:occurrence`'s closing clause restated in the shape this section consumes it: `H_F` has an
inhabitant, so the `∀ τ : F.HF` in `ValidOn` is a non-vacuous quantifier. Everything it rests
on — the four axioms and the carrier's nonemptiness — is a field of the frame.

This is a thin restatement of `PartialHistory.hF_nonempty`, kept here so the reason
`not_validOn_bot` holds is legible next to the statement itself.
-/
theorem hF_nonempty_of_frameAxioms (F : TaskFrame) : Nonempty (TaskFrame.HF F) :=
  PartialHistory.hF_nonempty F F.worldNonempty.some

end TaskFrame

namespace Validity

/--
Validity **is** validity on every frame: `⊨ φ` iff `φ` is valid over every frame of every
temporal type.

This is the theorem that keeps `TaskFrame.ValidOn` from being a second, competing validity
notion. `valid` (`def:logical-consequence`'s closing clause) and `TaskFrame.ValidOn`
(`def:frame-validity`) differ only in *which* quantifiers are discharged: `valid` closes over the
temporal type and the frame, `ValidOn` leaves both fixed. Stated as a theorem rather than
introduced as an abbreviation, exactly so that the equivalence is a proof obligation the build
checks and not a definitional identity asserted by fiat.

Both directions are the `.val`/`.property` bridge between `F.HF` and the predicate form
`(τ : WorldHistory F) (hτ : τ.IsTotal)` that `valid` uses — the two spellings of one and the same
`IsTotal` predicate, per `WorldHistory.lean`'s encoding note. No mathematical content is added in
either direction; that is the point of the statement.
-/
theorem valid_iff_forall_validOn (φ : Formula) :
    valid φ ↔ ∀ (F : TaskFrame), F.ValidOn φ := by
  constructor
  · intro h F M τ x
    exact h F M τ.val τ.property x
  · intro h F M τ hτ x
    exact h F M ⟨τ, hτ⟩ x

/--
The forward half of `valid_iff_forall_validOn`, in the direction that gets used: a valid formula
is valid over any particular frame.
-/
theorem validOn_of_valid {φ : Formula} (h : valid φ) (F : TaskFrame) : F.ValidOn φ :=
  (valid_iff_forall_validOn φ).mp h F

end Validity

/-! ## `FrameClass`-indexed validity

The proof side is parameterized by `ProofSystem.FrameClass` throughout — `Derivable fc`,
`DerivationTree fc`, and `DerivationTree.lift` along `fc₁ ≤ fc₂`. This section gives the semantic
side the same index, so that `ValidIn fc` stands to `Derivable fc` as `⊨` stands to `⊢`.

**Definition of record — `cor:tm-completeness`**: "Where `Γ ⊨_C φ` restricts
`def:logical-consequence` to models over task frames in a class `C` ...". `ValidIn fc` is that
`⊨_C`, with the class `C` read off the tag by `FrameClass.Sat`
(`Semantics/FrameClassValidity.lean`) rather than inlined as a binder list.
`TaskFrame.ValidOn` (`def:frame-validity`, above) stays the single frame-level primitive
underneath; nothing here duplicates it.

### Why the primitive takes a bare predicate rather than a tag

`ValidOnFrames` is stated over an arbitrary `P : TaskFrame → Prop`, and `ValidIn fc` is its
instance at `fc.Sat`. This is not generality for its own sake — it is what lets **one**
monotonicity lemma cover every validity bridge in the tree. `ValidDedekind` is
`ValidOnFrames TaskFrame.IsComplete`, `def:frame-properties`' bare Complete clause, and no
`FrameClass` constructor denotes that class (see the `FrameClass` docstring in
`ProofSystem/Axioms.lean`), so it cannot be `ValidIn`-anything. Against a tag-only primitive it,
and the bridge from it to `ValidDedekindDense`, would have to stay hand-written outside the
collapse.
-/

/--
`φ` is valid on every frame satisfying `P`.

The frame-predicate-indexed primitive that every class-restricted validity notion in this module
is an instance of. `ValidIn` below is the instance at a `FrameClass` tag; `ValidDedekind` is the
instance at `TaskFrame.IsComplete`, which no tag denotes.
-/
def ValidOnFrames (P : TaskFrame → Prop) (φ : Formula) : Prop :=
  ∀ F : TaskFrame, P F → F.ValidOn φ

/--
`cor:tm-completeness`'s class-restricted consequence `⊨_C`, at the empty premise set: `φ` is valid
on every frame in the class the tag `fc` denotes.

This is the semantic mirror of `Derivable fc`, and the definition this module's four
class-restricted predicates are abbreviations over. Its frame constraint is not written here at
all — it is `FrameClass.Sat fc`, which is where the interpretation of each tag is recorded once.
-/
def ValidIn (fc : ProofSystem.FrameClass) (φ : Formula) : Prop :=
  ValidOnFrames fc.Sat φ

/--
**The one monotonicity lemma.** `ValidOnFrames` is antitone in its frame predicate: shrinking the
class of frames quantified over can only preserve validity.

Every validity bridge in the tree is a corollary of this one statement — the four `valid`-to-
class-restricted bridges, the `ValidDedekind`-to-`ValidDedekindDense` bridge, and `ValidIn.mono`
below. Before this lemma each was written out by hand against its own inlined binder list.
-/
theorem ValidOnFrames.mono {P Q : TaskFrame → Prop} {φ : Formula} (h : ∀ F, Q F → P F)
    (hP : ValidOnFrames P φ) : ValidOnFrames Q φ :=
  fun F hF => hP F (h F hF)

/--
Validity is monotone in the `FrameClass` order: `fc₁ ≤ fc₂ → ValidIn fc₁ φ → ValidIn fc₂ φ`.

**This points the same direction as `DerivationTree.lift`** (`ProofSystem/Derivation.lean`), which
carries a derivation at `fc₁` up to any `fc₂ ≥ fc₁`. That the proof side and the semantic side
climb the order together is the symmetry this indexing exists to restore, and it holds because
`FrameClass.Sat` is *antitone*: a larger tag denotes a more constrained collection of frames.
The order-direction argument itself lives in `FrameClass.Sat.anti` and is not restated here.
-/
theorem ValidIn.mono {fc₁ fc₂ : ProofSystem.FrameClass} {φ : Formula} (h : fc₁ ≤ fc₂)
    (hv : ValidIn fc₁ φ) : ValidIn fc₂ φ :=
  ValidOnFrames.mono (fun _ => ProofSystem.FrameClass.Sat.anti h) hv

/-! ### The migration lever

`ValidOnFrames` is defined through `TaskFrame.ValidOn`, whose history quantifier is the bundled
`(τ : TaskFrame.HF F)`; every predicate this module states by hand instead uses the unbundled pair
`(τ : WorldHistory F) (_ : τ.IsTotal)`. `valid_iff_forall_validOn` already proves the two spellings
agree, but they are not *definitionally* equal, so a proof written against one shape does not
elaborate against the other. The two lemmas below are the shape adapters: a goal site becomes
`refine ValidOnFrames.of_forall_total ?_; intro F hF M τ hτ t`, and a hypothesis site becomes
`h.apply_total F hF M τ hτ t`. -/

/-- Introduce `ValidOnFrames` from the unbundled `(τ : WorldHistory F) (hτ : τ.IsTotal)` shape. -/
theorem ValidOnFrames.of_forall_total {P : TaskFrame → Prop} {φ : Formula}
    (h : ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F) (τ : WorldHistory F),
           τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ) :
    ValidOnFrames P φ :=
  fun F hF M τ t => h F hF M τ.val τ.property t

/-- Eliminate `ValidOnFrames` into the unbundled `(τ : WorldHistory F) (hτ : τ.IsTotal)` shape. -/
theorem ValidOnFrames.apply_total {P : TaskFrame → Prop} {φ : Formula} (h : ValidOnFrames P φ)
    (F : TaskFrame) (hF : P F) (M : TaskModel F) (τ : WorldHistory F)
    (hτ : τ.IsTotal) (t : F.Duration) : TruthAt M τ t φ :=
  h F hF M ⟨τ, hτ⟩ t

/-- `ValidOnFrames.of_forall_total` at a `FrameClass` tag. -/
theorem ValidIn.of_forall_total {fc : ProofSystem.FrameClass} {φ : Formula}
    (h : ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F),
           τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ) :
    ValidIn fc φ :=
  ValidOnFrames.of_forall_total h

/-- `ValidOnFrames.apply_total` at a `FrameClass` tag. -/
theorem ValidIn.apply_total {fc : ProofSystem.FrameClass} {φ : Formula} (h : ValidIn fc φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F) (τ : WorldHistory F)
    (hτ : τ.IsTotal) (t : F.Duration) : TruthAt M τ t φ :=
  ValidOnFrames.apply_total h F hF M τ hτ t

/--
A formula is valid over dense temporal orders if it is true in all models where D is
densely ordered, at all total histories, and all times.

This restricts `valid` to temporal types with `DenselyOrdered D`, capturing the
frame condition for the density axiom DN: `F(phi) -> F(F(phi))`.

**Now an abbreviation over `ValidIn`.** The frame constraint is no longer inlined here: it is
`FrameClass.Sat .Dense`, which is `TaskFrame.IsDense`, `def:frame-properties`' Dense clause. The
binder shape this definition used to have is recovered by `ValidDense.of_forall` /
`ValidDense.apply`, which is what keeps the density witness available to typeclass resolution
inside a migrated proof.

**Notation**: `⊨_dense φ`
-/
def ValidDense (φ : Formula) : Prop := ValidIn ProofSystem.FrameClass.Dense φ

/-- Introduce `ValidDense` from the binder shape it carried before it became an abbreviation over
`ValidIn`: an instance-implicit `[DenselyOrdered F.Duration]` and the unbundled history pair
`(τ : WorldHistory F) (hτ : τ.IsTotal)`.

The instance binder is the point. `Sat .Dense F` is `TaskFrame.IsDense F`, whose head symbol is
`TaskFrame.IsDense` rather than `DenselyOrdered`, so a hypothesis of that type is invisible to
typeclass resolution and every downstream `exists_between` would fail. Introducing the density
witness through this adapter puts it back in the local context as an instance, which is what lets
each migrated proof keep its body unchanged. -/
theorem ValidDense.of_forall {φ : Formula}
    (h : ∀ (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
           (τ : WorldHistory F), τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ) :
    ValidDense φ :=
  fun F hF M τ t => @h F hF M τ.val τ.property t

/-- Eliminate `ValidDense` into the pre-abbreviation binder shape. -/
theorem ValidDense.apply {φ : Formula} (h : ValidDense φ) (F : TaskFrame)
    [inst : DenselyOrdered F.Duration] (M : TaskModel F) (τ : WorldHistory F)
    (hτ : τ.IsTotal) (t : F.Duration) : TruthAt M τ t φ :=
  h F inst M ⟨τ, hτ⟩ t

/-- The contrapositive of `ValidDense.of_forall`, in the shape a countermodel extraction wants:
from a failure of `ValidDense` it hands back a failure of the pre-abbreviation ∀-statement, which
`push Not` can then take apart. This replaces the `unfold ValidDense` that used to open the
definition directly — there is no longer a binder list there to open. -/
theorem ValidDense.of_not {φ : Formula} (h : ¬ ValidDense φ) :
    ¬ ∀ (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
        (τ : WorldHistory F), τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (ValidDense.of_forall h')

/--
A formula is valid over discrete temporal orders if it is true in all models where D
has successor and predecessor structure, at all total histories, and all times.

This restricts `valid` to temporal types with `SuccOrder D` and `PredOrder D`,
capturing the frame condition for the discreteness axioms DF/DP.

**Now an abbreviation over `ValidIn`.** The frame constraint is `FrameClass.Sat .Discrete`, which
is `TaskFrame.IsSuccArchDiscrete` — `def:TMplus-f`'s Hölder narrowing to ℤ-time, *not*
`def:frame-properties`' bare Discrete clause. Recording the narrowing in the tag's interpretation
rather than in a binder list here is what keeps `soundness_discrete` from silently widening its
frame class. The binder shape this definition used to have is recovered by
`ValidDiscrete.of_forall` / `ValidDiscrete.apply`.

**Notation**: `⊨_discrete φ`

## The two directions cost differently, and only one needs a carrier lemma

The binder bundle below is instantiated by `ℤ` with **no instance work whatsoever** — no
`Archimedean`, no least-positive-element witness, nothing beyond what Mathlib already provides for
`ℤ`. Two consequences, which are easy to conflate and should not be:

- **Refuting** `ValidDiscrete φ` is free of any carrier lemma. A countermodel presented over `ℤ`
  — e.g. one built by `IntPresentation.toTaskFrame`, whose duration type *is* `ℤ` — discharges
  the `∀ D` binder by instantiating it at `ℤ` and applying the resulting truth to the
  countermodel's own history and time. Measured: that argument is five lines and elaborates at
  `[propext, Classical.choice, Quot.sound]`.
- **Establishing** `ValidDiscrete φ` from a statement about `ℤ`-frames alone is the direction that
  needs work, because there the `∀ D` binder must be *discharged for an arbitrary* `D`, which
  requires normalizing `D` to `ℤ` and transporting the frame, `TaskModel`, `WorldHistory`, and
  `TruthAt` across the resulting isomorphism.

`Semantics/IntNormalForm.lean`'s module docstring names the exact Mathlib route for that
normalization, and records why the order-only isomorphism is the wrong turn. The successor-based
analogue of `DurationClassification.lean`'s `archimedean_of_lub` — the input that route needs — is
now present: `DurationClassification.lean`'s `archimedean_of_succ` supplies the `Archimedean D`
instance from `[IsSuccArchimedean D]`, `isLeast_pos_succ_zero` supplies the least-positive-element
witness, and `intIso : D ≃+o ℤ` packages both into the additive transfer. The transport itself is
`Semantics/IntTransfer.lean`, whose `validDiscrete_iff_validInt : ValidDiscrete φ ↔ ValidInt φ`
closes this direction outright: establishing `ValidDiscrete φ` from a statement about ℤ-frames
alone is now a single rewrite.
-/
def ValidDiscrete (φ : Formula) : Prop := ValidIn ProofSystem.FrameClass.Discrete φ

/-- Introduce `ValidDiscrete` from the four-instance binder shape it carried before it became an
abbreviation over `ValidIn`.

`Sat .Discrete F` is the existential `TaskFrame.IsSuccArchDiscrete F` — `SuccOrder` and `PredOrder`
are data-carrying, so a `TaskFrame → Prop` cannot bind them as instances. This adapter destructures
that existential with `obtain` and passes the witnesses **positionally with `@`**, never with
`haveI`: routing them through the instance cache would break definitional equality against
instances already fixed in the types of `F` and `M`. -/
theorem ValidDiscrete.of_forall {φ : Formula}
    (h : ∀ (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
           [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] (M : TaskModel F)
           (τ : WorldHistory F), τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ) :
    ValidDiscrete φ := by
  intro F hF M τ t
  obtain ⟨so, po, hsa, hpa⟩ := hF
  exact @h F so po hsa hpa M τ.val τ.property t

/-- Eliminate `ValidDiscrete` into the pre-abbreviation binder shape. -/
theorem ValidDiscrete.apply {φ : Formula} (h : ValidDiscrete φ) (F : TaskFrame)
    [so : SuccOrder F.Duration] [po : PredOrder F.Duration]
    [hsa : IsSuccArchimedean F.Duration] [hpa : IsPredArchimedean F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) :
    TruthAt M τ t φ :=
  h F ⟨so, po, hsa, hpa⟩ M ⟨τ, hτ⟩ t

/-- The contrapositive of `ValidDiscrete.of_forall`; see `ValidDense.of_not`. -/
theorem ValidDiscrete.of_not {φ : Formula} (h : ¬ ValidDiscrete φ) :
    ¬ ∀ (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
        [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] (M : TaskModel F)
        (τ : WorldHistory F), τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (ValidDiscrete.of_forall h')

/--
**Read this first: `ValidDedekind` is NOT `ValidIn .Dedekind`.** The shared word is misleading and
the two denote different frame classes. `ValidDedekind` is `ValidOnFrames TaskFrame.IsComplete` —
`def:frame-properties`' *bare* Complete clause, which `ℤ` satisfies. `ValidIn .Dedekind` is
`ValidDedekindDense`, the dense-and-complete class, and **that** is the target of
`soundness_dedekind`. The mismatch follows from a naming decision recorded in full at
`TaskFrame.IsDedekind`: the paper calls the dense-and-complete class Complete, this tree calls it
Dedekind, because "complete" is already load-bearing here for *proof-theoretic* completeness. The
reciprocal pointer back to this predicate sits on `TaskFrame.IsComplete`
(`Semantics/FrameProperty.lean`). Retargeting `soundness_dedekind` at this predicate yields a
**refutable** theorem — see the paragraph on that below.

A formula is valid over **Dedekind-complete** temporal orders if it is true in all models
whose temporal type `D` has the least-upper-bound property, at all total histories, and all
times.

**Now an abbreviation, not a hand-written binder list.** The class is named once, as
`TaskFrame.IsComplete`, and this predicate is `ValidOnFrames` at it. `ValidDedekind.of_forall` and
`ValidDedekind.apply` adapt between this shape and the explicit-hypothesis shape the definition
used to have.

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

That "ℤ satisfies every binder" observation is not an isolated curiosity: it is the **discrete
branch of the Hölder dichotomy**. By `FormalSystem.Semantics.complete_duration_discrete_or_dense`
(`Semantics/DurationClassification.lean`) a duration group with the least-upper-bound hypothesis
is either `≃+o ℤ` or densely ordered, and by
`FormalSystem.Semantics.complete_not_dense_iso_int` the non-dense case is `≃+o ℤ` on the nose.
So this predicate's binder set is exactly the paper's **TM⁺_c** (complete simpliciter), whose
model class is `{ℤ, ℝ}` up to isomorphism and whose theory is `Th(ℤ) ∩ Th(ℝ)`. No `FrameClass`
element corresponds to it — see the `FrameClass` docstring in
`FormalSystem/ProofSystem/Axioms.lean`.

**This predicate is NOT the target of `soundness_dedekind`, and that is not an oversight.**
`FrameClass.Dedekind` sits strictly above `FrameClass.Dense` (see the `FrameClass` docstring
in `FormalSystem/ProofSystem/Axioms.lean`), so `Axiom.density` (`GGφ → Gφ`) and
`Axiom.dense_indicator` (`¬(⊥ U ⊤)`) are admissible in `DerivationTree FrameClass.Dedekind`.
Both are FALSE on `ℤ`: for `density`, take `φ` true exactly at times `≥ t + 2`, so `GGφ` holds
at `t` while `Gφ` fails; for `dense_indicator`, `⊥ U ⊤` is true on `ℤ` because every point has
an immediate successor. Since `ℤ` also satisfies `TaskFrame.IsComplete`, a
`soundness_dedekind : DerivationTree .Dedekind … → ValidDedekind` would be refutable.
`soundness_dedekind` therefore targets `ValidDedekindDense`. This predicate is landed as the
strictly weaker statement and as the target of the forgetful bridge from `valid`.

**The trap is now structural rather than merely documented.** Before this predicate became an
abbreviation, the wrong target differed from the right one by *one binder in an inlined list* —
delete `[DenselyOrdered F.Duration]` and the refutable statement typechecks, with nothing but this
docstring to say so. The two are now built from different frame predicates entirely
(`ValidOnFrames TaskFrame.IsComplete` against `ValidIn .Dedekind`, i.e. `TaskFrame.IsDedekind`), so
writing the refutable version requires naming a different predicate rather than dropping a binder.

**Source.** Reynolds 1992 (printed p.169) observes that the Prior axioms enforce only a
*definably* Dedekind-complete model: "there may be gaps in the order but ... you wouldn't know
that just looking at the behaviour of temporal formulas". So no single axiom characterises this
class; `Axiom.prior_U_gap` / `Axiom.prior_S_gap` / `Axiom.sep` are the definable-gap proxy.
-/
def ValidDedekind (φ : Formula) : Prop := ValidOnFrames TaskFrame.IsComplete φ

/-- Introduce `ValidDedekind` from the binder shape it carried before it became an abbreviation
over `ValidOnFrames`: the least-upper-bound hypothesis as an explicit argument, and the unbundled
history pair. -/
theorem ValidDedekind.of_forall {φ : Formula}
    (h : ∀ (F : TaskFrame),
           (∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) →
           ∀ (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal →
             ∀ t : F.Duration, TruthAt M τ t φ) :
    ValidDedekind φ :=
  fun F hF M τ t => h F hF M τ.val τ.property t

/-- Eliminate `ValidDedekind` into the pre-abbreviation binder shape. -/
theorem ValidDedekind.apply {φ : Formula} (h : ValidDedekind φ) (F : TaskFrame)
    (hlub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) :
    TruthAt M τ t φ :=
  h F hlub M ⟨τ, hτ⟩ t

/--
A formula is valid over **dense Dedekind-complete** temporal orders. This is the real-flow
predicate, and sharply so: up to order-and-group isomorphism `ℝ` is the *only* nontrivial model,
not merely a paradigm one.

**This is `ValidIn .Dedekind`** — `FrameClass.Sat .Dedekind` is `TaskFrame.IsDedekind`, the
conjunction of `def:frame-properties`' Dense and Complete clauses — and it is therefore the
predicate the `.Dedekind` tag denotes, whatever its name may suggest about `ValidDedekind`. The
binder shape this definition used to have is recovered by `ValidDedekindDense.of_forall` /
`ValidDedekindDense.apply`.

**Why the density binder is exactly the right cut.** By
`FormalSystem.Semantics.complete_duration_discrete_or_dense`
(`Semantics/DurationClassification.lean`), a duration group satisfying the least-upper-bound
hypothesis is *either* `≃+o ℤ` *or* densely ordered, and by
`FormalSystem.Semantics.complete_not_dense_iso_int` those branches are exclusive. So adding
`DenselyOrdered` deletes precisely the `ℤ` branch of the Hölder dichotomy and nothing else —
which is why `ℤ` is excluded here even though it satisfies every binder of `ValidDedekind`.
(Getting from "dense and complete" to a literal `≃+o ℝ` needs one further step this repository
does not carry; the composition path and the reason it is out of scope are recorded in the
`DurationClassification` module docstring.)

**This is the target of `soundness_dedekind`**, not `ValidDedekind`. The reason is spelled out
in the `ValidDedekind` docstring above and is worth restating, because the weaker-looking
predicate is the wrong one: `FrameClass.Dedekind` lies above `FrameClass.Dense`, so `density`
and `dense_indicator` are admissible in a `.Dedekind` derivation, and both are false on `ℤ` —
which is Dedekind-complete. Do not "simplify" `soundness_dedekind` to target `ValidDedekind`;
the result would be refutable.

The placement of `Dedekind` above `Dense` is itself primary-source: Reynolds 1992 (printed
p.168) includes in US/R "axioms for density and no end points: `K⁺⊤`, `K⁻⊤`, `F⊤`, `P⊤`", and
`K⁺⊤` is `¬(¬⊤ U ⊤)` in this tree's guard-first infix, which normalises (`¬⊤ ↝ ⊥`) to
`¬(⊥ U ⊤)`, this tree's `Axiom.dense_indicator`.
-/
def ValidDedekindDense (φ : Formula) : Prop := ValidIn ProofSystem.FrameClass.Dedekind φ

/-- Introduce `ValidDedekindDense` from the binder shape it carried before it became an
abbreviation over `ValidIn`: an instance-implicit density binder, the least-upper-bound hypothesis
as an explicit argument, and the unbundled history pair. -/
theorem ValidDedekindDense.of_forall {φ : Formula}
    (h : ∀ (F : TaskFrame) [DenselyOrdered F.Duration],
           (∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) →
           ∀ (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal →
             ∀ t : F.Duration, TruthAt M τ t φ) :
    ValidDedekindDense φ :=
  fun F hF M τ t => @h F hF.1 hF.2 M τ.val τ.property t

/-- Eliminate `ValidDedekindDense` into the pre-abbreviation binder shape. -/
theorem ValidDedekindDense.apply {φ : Formula} (h : ValidDedekindDense φ) (F : TaskFrame)
    [inst : DenselyOrdered F.Duration]
    (hlub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) :
    TruthAt M τ t φ :=
  h F ⟨inst, hlub⟩ M ⟨τ, hτ⟩ t

/-- The contrapositive of `ValidDedekindDense.of_forall`; see `ValidDense.of_not`. -/
theorem ValidDedekindDense.of_not {φ : Formula} (h : ¬ ValidDedekindDense φ) :
    ¬ ∀ (F : TaskFrame) [DenselyOrdered F.Duration],
        (∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) →
        ∀ (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal →
          ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (ValidDedekindDense.of_forall h')

namespace Validity

/-! ### Equivalence with the `FrameClass`-indexed layer

Each class-restricted predicate above, matched against its `ValidIn` counterpart. Four of the five
are now `Iff.rfl`, because the predicate on the left *is* the one on the right by definition; they
are kept as named lemmas so that a call site can cite the correspondence explicitly, and so that a
future edit which pulls the two apart fails here rather than somewhere downstream.
`valid_iff_validIn_base` is the one that still carries a proof: `valid` is not yet an abbreviation.

Note the shape of the last one: `ValidDedekind` is **not** `ValidIn .Dedekind`. See its own
docstring, and `TaskFrame.IsComplete`'s. -/

/-- `valid` is `ValidIn` at the unconstrained class: `Sat .Base` is `True`, so the tag imposes
nothing and the two quantify over the same frames. This is the symmetry claim
`valid = ValidIn .Base` beside `Derivable .Base`. -/
theorem valid_iff_validIn_base (φ : Formula) : valid φ ↔ ValidIn ProofSystem.FrameClass.Base φ := by
  constructor
  · intro h F _ M τ x
    exact h F M τ.val τ.property x
  · intro h F M τ hτ t
    exact h F trivial M ⟨τ, hτ⟩ t

/-- `ValidDense` is `ValidIn .Dense`: its `[DenselyOrdered F.Duration]` binder is exactly
`TaskFrame.IsDense`, which is what `Sat .Dense` returns. -/
theorem validDense_iff_validIn_dense (φ : Formula) :
    ValidDense φ ↔ ValidIn ProofSystem.FrameClass.Dense φ := Iff.rfl

/-- `ValidDiscrete` is `ValidIn .Discrete`: its four-instance binder bundle is exactly the
existential `TaskFrame.IsSuccArchDiscrete` that `Sat .Discrete` returns.

The forward direction destructures that existential and passes the witnesses **positionally with
`@`**, never with `haveI`: `F`'s and `M`'s types already carry instances, and re-introducing
`SuccOrder`/`PredOrder` through the instance cache would break definitional equality against them. -/
theorem validDiscrete_iff_validIn_discrete (φ : Formula) :
    ValidDiscrete φ ↔ ValidIn ProofSystem.FrameClass.Discrete φ := Iff.rfl

/-- `ValidDedekindDense` is `ValidIn .Dedekind`: its density binder together with its
least-upper-bound hypothesis is exactly the conjunction `TaskFrame.IsDedekind` that
`Sat .Dedekind` returns. This is the `soundness_dedekind` target. -/
theorem validDedekindDense_iff_validIn_dedekind (φ : Formula) :
    ValidDedekindDense φ ↔ ValidIn ProofSystem.FrameClass.Dedekind φ := Iff.rfl

/-- `ValidDedekind` is `ValidOnFrames TaskFrame.IsComplete` — and therefore **not** any `ValidIn`.

`def:frame-properties`' bare Complete clause admits `ℤ`, and no `FrameClass` constructor denotes
that class (`ProofSystem/Axioms.lean`'s `FrameClass` docstring says so explicitly: there is no
axiom set here for `Th(ℤ) ∩ Th(ℝ)`). That this predicate still lands inside the collapse — with its
bridge to `ValidDedekindDense` falling out of `ValidOnFrames.mono` like every other bridge — is the
whole reason the primitive is indexed by a frame predicate rather than by a tag. -/
theorem validDedekind_iff_validOnFrames_isComplete (φ : Formula) :
    ValidDedekind φ ↔ ValidOnFrames TaskFrame.IsComplete φ := Iff.rfl

/--
Validity implies validity over dense orders: every valid formula is ValidDense.
-/
theorem valid_implies_valid_dense {φ : Formula} (h : valid φ) : ValidDense φ :=
  ValidIn.mono (ProofSystem.FrameClass.base_le _) ((valid_iff_validIn_base φ).mp h)

/--
Validity implies validity over discrete orders: every valid formula is ValidDiscrete.
-/
theorem valid_implies_valid_discrete {φ : Formula} (h : valid φ) : ValidDiscrete φ :=
  ValidIn.mono (ProofSystem.FrameClass.base_le _) ((valid_iff_validIn_base φ).mp h)

/--
Validity implies validity over Dedekind-complete orders: every valid formula is
`ValidDedekind`. The least-upper-bound hypothesis is simply discarded — `valid` already
quantifies over every `D` satisfying the weaker binder set.
-/
theorem valid_implies_validDedekind {φ : Formula} (h : valid φ) : ValidDedekind φ :=
  ValidOnFrames.mono (fun _ _ => trivial) ((valid_iff_validIn_base φ).mp h)

/--
Validity implies validity over dense Dedekind-complete orders: every valid formula is
`ValidDedekindDense`.
-/
theorem valid_implies_validDedekindDense {φ : Formula} (h : valid φ) : ValidDedekindDense φ :=
  ValidIn.mono (ProofSystem.FrameClass.base_le _) ((valid_iff_validIn_base φ).mp h)

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
  ValidOnFrames.mono (fun _ => TaskFrame.isComplete_of_isDedekind) h

/--
Valid formulas are semantic consequences of empty context.
-/
theorem valid_iff_empty_consequence (φ : Formula) :
    (⊨ φ) ↔ ([] ⊨ φ) := by
  constructor
  · intro h F M τ hτ t _
    exact h F M τ hτ t
  · intro h F M τ hτ t
    exact h F M τ hτ t (by intro ψ hψ; exact absurd hψ List.not_mem_nil)

/--
Semantic consequence is monotonic: adding premises preserves consequences.
-/
theorem consequence_monotone {Γ Δ : Context} {φ : Formula} :
    Γ ⊆ Δ → (Γ ⊨ φ) → (Δ ⊨ φ) := by
  intro h_sub h_cons F M τ hτ t h_delta
  apply h_cons F M τ hτ t
  intro ψ hψ
  exact h_delta ψ (h_sub hψ)

/--
If a formula is valid, it is a semantic consequence of any context.
-/
theorem valid_consequence (φ : Formula) (Γ : Context) :
    (⊨ φ) → (Γ ⊨ φ) :=
  fun h F M τ hτ t _ => h F M τ hτ t

/--
Context with all formulas true implies each formula individually true.
-/
theorem consequence_of_member {Γ : Context} {φ : Formula} :
    φ ∈ Γ → (Γ ⊨ φ) := by
  intro h F M τ hτ t h_all
  exact h_all φ h

/--
Unsatisfiable context (in ALL temporal types) semantically implies anything.
This is the correct formulation for polymorphic validity: if a context is
unsatisfiable in every temporal type, then it implies anything.

Note: For the weaker statement that unsatisfiability in a SPECIFIC type implies
consequence in that type, see `unsatisfiable_implies_all_fixed`.

The hypothesis now carries `[Nontrivial D]`, matching both `satisfiable` and the binder list of
`SemanticConsequence`. Without it the two sides would range over different classes of temporal
type and the statement would be quantifying the antecedent over strictly more types than the
conclusion can use.
-/
theorem unsatisfiable_implies_all {Γ : Context} {φ : Formula} :
    (∀ D : TemporalOrder, ¬satisfiable D Γ) → (Γ ⊨ φ) :=
  fun h_unsat F M τ hτ t h_all =>
    absurd ⟨F.toFibre, M, τ, hτ, t, h_all⟩ (h_unsat F.Duration)

/--
Unsatisfiable context in a fixed temporal type implies consequence in that type.
This is the type-specific version of explosion.
-/
theorem unsatisfiable_implies_all_fixed {D : TemporalOrder}
    {Γ : Context} {φ : Formula} :
    ¬satisfiable D Γ → ∀ (F : FrameOver D) (M : TaskModel F.toTaskFrame)
      (τ : WorldHistory F.toTaskFrame) (_ : τ.IsTotal)
      (t : ↑D), (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ := by
  intro h_unsat F M τ hτ t h_all
  exfalso
  apply h_unsat
  exact ⟨F, M, τ, hτ, t, h_all⟩

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
  intro F M τ hτ t
  -- G(φ) valid means ∀ t, ∀ s > t, φ(s). Pick r < t, then G(φ)(r) gives φ(t).
  have h_G := h F M τ hτ
  obtain ⟨r, hrt⟩ := exists_lt t
  have := h_G r
  simp only [Truth.future_iff] at this
  exact this t hrt

/--
If H(φ) is valid, then φ is valid.
-/
theorem valid_of_valid_all_past {φ : Formula} (h : valid (Formula.allPast φ)) :
    valid φ := by
  intro F M τ hτ t
  -- H(φ) valid at all times. Pick s > t, then H(φ)(s) gives φ(t) since t < s.
  have h_H := h F M τ hτ
  obtain ⟨s, hts⟩ := exists_gt t
  have := h_H s
  simp only [Truth.past_iff] at this
  exact this t hts

/--
If □φ is valid, then φ is valid.

Proof: □φ at `(τ, t)` means `∀ σ, σ.IsTotal → TruthAt φ at (σ, t)` per `def:BL-semantics`
("M,τ,x ⊨ □φ *iff* M,σ,x ⊨ φ for all σ ∈ H_F"). Instantiating that at `σ := τ` needs exactly
`τ.IsTotal` — which is precisely the hypothesis `valid` now binds. So the step is the identity
move: feed `τ`'s own totality witness back in as the box witness.

**Formerly a strategic sorry; discharged by the validity-layer binder delta.** Before that delta,
`valid` bound its history as `τ ∈ Omega` while `TruthAt`'s box clause already bound `σ.IsTotal`,
and those two binders did not meet — `τ ∈ Omega` yielded `τ.IsTotal` under no hypothesis then in
scope, so the statement was not provable as written and no local tactic could rescue it. That was
a seam between the truth layer and the validity layer, not a gap in the argument, and the delta
closed it by construction: no new mathematical content was needed, only the corrected binder.
-/
theorem valid_of_valid_box {φ : Formula} (h : valid (Formula.box φ)) :
    valid φ := by
  intro F M τ hτ t
  exact h F M τ hτ t τ hτ

end Validity

end FormalSystem.Semantics
