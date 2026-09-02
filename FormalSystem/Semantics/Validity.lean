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

/-! ### The finite-context consequence layer, indexed by frame predicate and by `FrameClass`

The two-layer shape `ValidOnFrames` / `ValidIn` gives validity, applied to consequence from a
finite context: a predicate-indexed primitive, and a `FrameClass`-tagged abbreviation over it.
`Metalogic/SetConsequence.lean` carries the `Γ : Set Formula` twin of this pair
(`SetConsequenceOnFrames` / `SetSemanticConsequenceOn`). The two layers are deliberately distinct
types — the set form is the vocabulary of the strong-completeness statements, this one is the
finite-context relation the consequence theorems in `Metalogic/StrongCompleteness.lean` actually
discharge. -/

/-- Semantic consequence from a finite context, over every frame satisfying `P`: the
predicate-indexed primitive, mirroring `ValidOnFrames`. Indexing by a bare frame predicate rather
than by a `FrameClass` tag is what lets one definition serve every class. -/
def ConsequenceOnFrames (P : TaskFrame → Prop) (Γ : Context) (φ : Formula) : Prop :=
  ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-- `cor:tm-completeness`'s class-restricted consequence `Γ ⊨_C φ` at a finite context: the
mirror of `ValidIn`, over the same `FrameClass.Sat`. The four named consequence relations —
`SemanticConsequence` here, and `SemanticConsequenceDense` / `SemanticConsequenceDiscrete` /
`SemanticConsequenceDedekind` in `Metalogic/StrongCompleteness.lean` — are its four
instances. -/
def SemanticConsequenceIn (fc : ProofSystem.FrameClass) (Γ : Context) (φ : Formula) : Prop :=
  ConsequenceOnFrames fc.Sat Γ φ

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

**`SemanticConsequence` is `SemanticConsequenceIn` at the unconstrained class**, exactly as
`valid` is `ValidIn .Base`: `Sat FrameClass.Base` is `True`, so the tag attaches no frame
condition and "all carriers" *is* the class. The pre-abbreviation binder shape is reachable
through `SemanticConsequence.of_forall` / `.apply` below.

Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs.
-/
def SemanticConsequence (Γ : Context) (φ : Formula) : Prop :=
  SemanticConsequenceIn ProofSystem.FrameClass.Base Γ φ

/--
Notation for semantic consequence: `Γ ⊨ φ`.
-/
notation:50 Γ:50 " ⊨ " φ:50 => SemanticConsequence Γ φ

/-! ### Binder-shape adapters

The pre-collapse binder shapes, restored. `ConsequenceOnFrames` already quantifies over the
unbundled `(τ : WorldHistory F) (_ : τ.IsTotal)` pair, so — unlike `ValidOnFrames`, which bundles
the history into `TaskFrame.HF` — no history-shape adapter is needed at the generic layer. What
each `of_forall` restores is the *frame condition*, putting it back into the local context in the
form typeclass resolution can see: `Sat .Dense F` is `TaskFrame.IsDense F`, whose head symbol is
not `DenselyOrdered`, so a bare hypothesis of that type is invisible to instance search. The three
class-restricted pairs live beside their definitions in `Metalogic/StrongCompleteness.lean`. -/

/-- Introduce `SemanticConsequence` from its pre-abbreviation binder shape; the `Sat .Base`
argument (`True`) is discharged here rather than at each call site. -/
theorem SemanticConsequence.of_forall {Γ : Context} {φ : Formula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal →
           ∀ t : F.Duration, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :
    SemanticConsequence Γ φ :=
  fun F _ M τ hτ t => h F M τ hτ t

/-- Eliminate `SemanticConsequence` into its pre-abbreviation binder shape. -/
theorem SemanticConsequence.apply {Γ : Context} {φ : Formula}
    (h : SemanticConsequence Γ φ) (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (hall : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  h F trivial M τ hτ t hall

/-- Introduce `SemanticConsequenceIn` at an arbitrary tag from the frame-condition-explicit
binder shape. The body is `h` — `ConsequenceOnFrames` already quantifies over the unbundled
`(τ : WorldHistory F) (_ : τ.IsTotal)` pair, so nothing has to be reshaped.

**This is why the per-class consequence adapters were boilerplate.** The three pairs that used
to live in `Metalogic/StrongCompleteness.lean` (`SemanticConsequenceDense`,
`SemanticConsequenceDiscrete`, `SemanticConsequenceDedekind`) were each this lemma at a fixed
tag with `fc.Sat F` unfolded to that class's frame condition; they are deleted, and a site now
writes the tag instead of picking a name. -/
theorem SemanticConsequenceIn.of_forall_total {fc : ProofSystem.FrameClass} {Γ : Context}
    {φ : Formula}
    (h : ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F),
           τ.IsTotal → ∀ t : F.Duration, (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :
    SemanticConsequenceIn fc Γ φ :=
  h

/-- Eliminate `SemanticConsequenceIn` at an arbitrary tag into the frame-condition-explicit
binder shape. The replacement for the three deleted class-specific `.apply` adapters. -/
theorem SemanticConsequenceIn.apply_total {fc : ProofSystem.FrameClass} {Γ : Context}
    {φ : Formula} (h : SemanticConsequenceIn fc Γ φ) (F : TaskFrame) (hF : fc.Sat F)
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (hΓ : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ :=
  h F hF M τ hτ t hΓ

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
**The bridge between the two validity shapes.**

`TaskFrame.ValidOn` quantifies over the bundled subtype `F.HF`; correspondence arguments are
naturally written with the history and its totality proof unbundled. One term in each direction,
because `TaskFrame.HF` is a subtype and `.val`/`.property` are its projections.

Stated here, beside `TaskFrame.ValidOn` itself, rather than in the one correspondence module that
first needed it: the unbundling is a fact about the definition, not about any particular
correspondence argument, and its callers now sit in more than one module.
-/
theorem validOn_iff_total (F : TaskFrame) (φ : Formula) :
    F.ValidOn φ ↔ ∀ (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal → ∀ t, TruthAt M τ t φ :=
  ⟨fun h M τ hτ t => h M ⟨τ, hτ⟩ t, fun h M τ t => h M τ.val τ.property t⟩

/--
Frame-relative validity is **never vacuous**: no frame validates `⊥`.

Without this, `F.ValidOn` would be satisfied trivially by any frame whose `H_F` happened to be
empty, and `F.ValidOn ⊥` would be a theorem rather than a refutation. What rules that out is
exactly `cor:occurrence`'s closing clause — `H_F ≠ ∅` — so the frame axioms it consumes appear
here as hypotheses.

**Wholly frame-intrinsic.** *Saturation*, *Seriality*, *Interpolation* and *Limit* are not
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
monotonicity lemma cover every validity bridge in the tree. `ValidComplete` is
`ValidOnFrames TaskFrame.IsComplete`, `def:frame-properties`' bare Complete clause, and no
`FrameClass` constructor denotes that class (see the `FrameClass` docstring in
`ProofSystem/Axioms.lean`), so it cannot be `ValidIn`-anything. Against a tag-only primitive it,
and the bridge from it to `ValidDedekind`, would have to stay hand-written outside the
collapse.
-/

/--
`φ` is valid on every frame satisfying `P`.

The frame-predicate-indexed primitive that every class-restricted validity notion in this module
is an instance of. `ValidIn` below is the instance at a `FrameClass` tag; `ValidComplete` is the
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

**`valid` is `ValidIn` at the unconstrained class.** The binder list above is no longer written
out here: `Sat FrameClass.Base` is `True`, so `ValidIn .Base` quantifies over every task frame
with no frame condition attached, which is exactly what `def:logical-consequence`'s closing
clause asks for. This completes the symmetry the `FrameClass` index exists to express — `valid`
stands to `Derivable .Base` as `ValidIn fc` stands to `Derivable fc`, with the class tag carried
in the same place on both sides.

The pre-abbreviation binder shape — `∀ (F) (M) (τ : WorldHistory F), τ.IsTotal → ∀ t` — is
reachable through `valid.of_forall_total` and `valid.apply` below, which discharge the `True`
argument so that no call site has to write `trivial`.
-/
def valid (φ : Formula) : Prop :=
  ValidIn ProofSystem.FrameClass.Base φ

/--
Notation for validity: `⊨ φ` means `valid φ`.
-/
notation:50 "⊨ " φ:50 => valid φ

/-- Introduce `valid` from the binder shape it carried before it became an abbreviation over
`ValidIn`. The `.Base` class imposes no frame condition, so this is `ValidIn.of_forall_total`
with the `Sat .Base` argument (`True`) discharged here rather than at each call site. -/
theorem valid.of_forall_total {φ : Formula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F),
           τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ) :
    valid φ :=
  fun F _ M τ t => h F M τ.val τ.property t

/-- Eliminate `valid` into the pre-abbreviation binder shape; the `Sat .Base` argument is
discharged here, not at the call site. -/
theorem valid.apply {φ : Formula} (h : valid φ) (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) : TruthAt M τ t φ :=
  h F trivial M ⟨τ, hτ⟩ t

/-- The contrapositive of `valid.of_forall_total`, in the shape a countermodel extraction wants:
from a failure of `valid` it hands back a failure of the pre-abbreviation ∀-statement, which
`push Not` can then take apart. This replaces the `unfold valid` that used to open the definition
directly — there is no longer a binder list there to open. The `.Base` instance of
`ValidIn.of_not`, with the `True` frame condition discharged here. -/
theorem valid.of_not {φ : Formula} (h : ¬ valid φ) :
    ¬ ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F),
        τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (valid.of_forall_total h')

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
    exact h F trivial M τ x
  · intro h F _ M τ x
    exact h F M τ x

/--
The forward half of `valid_iff_forall_validOn`, in the direction that gets used: a valid formula
is valid over any particular frame.
-/
theorem validOn_of_valid {φ : Formula} (h : valid φ) (F : TaskFrame) : F.ValidOn φ :=
  (valid_iff_forall_validOn φ).mp h F

end Validity

/--
**The one monotonicity lemma.** `ValidOnFrames` is antitone in its frame predicate: shrinking the
class of frames quantified over can only preserve validity.

Every validity bridge in the tree is a corollary of this one statement — the four `valid`-to-
class-restricted bridges, the `ValidComplete`-to-`ValidDedekind` bridge, and `ValidIn.mono`
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
elaborate against the other. The lemmas below are the shape adapters: a goal site becomes
`refine ValidOnFrames.of_forall_total ?_; intro F hF M τ hτ t`, and a hypothesis site becomes
`h.apply_total F hF M τ hτ t`.

**Two triples, and no more than two.** Every adapter in this file is indexed either by a bare
frame predicate `P : TaskFrame → Prop` (`ValidOnFrames.{of_forall_total, apply_total, of_not}`)
or by a `FrameClass` tag (`ValidIn.{of_forall_total, apply_total, of_not}`), and the second is
literally the first at `fc.Sat`. There was, until this pass, a third and fourth family: a
per-class copy of the triple at each of `.Dense`, `.Discrete` and `.Dedekind`, plus a `.Complete`
pair, twelve declarations existing only because `FrameClass.Sat` was a non-reducible `def` and a
`Sat .Dense F` hypothesis was therefore invisible to instance search. `FrameClass.Sat` is now
`@[reducible]` and `TaskFrame.IsDense` an `abbrev`, so the hypothesis registers itself on `intro`
and the tag-specific copies were deleted. **Do not reintroduce one.** If a tag needs its frame
condition taken apart, that is what the `sat_intro` tactic
(`Semantics/FrameClassValidity.lean`) is for; a new `ValidX.of_forall` is the thing this layer
exists to make unnecessary.

`valid.{of_forall_total, apply, of_not}` and `SemanticConsequence.{of_forall, apply}` survive for
a different reason, and are not exceptions to the rule above: they discharge `Sat .Base = True`
so that no `.Base` call site has to bind a vacuous `_`, which is a service the generic pair
cannot render. -/

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

/-- The contrapositive of `ValidOnFrames.of_forall_total`, at a bare frame predicate: from a
failure of `ValidOnFrames P` it hands back a failure of the unbundled ∀-statement, which
`push Not` can then take apart.

This is `ValidIn.of_not` one layer down, and it is the missing third of the `ValidOnFrames`
triple. It matters because `ValidComplete` is `ValidOnFrames TaskFrame.IsComplete` — a bare
predicate that no `FrameClass` tag denotes — so the `ValidOnFrames` triple *is* that predicate's
whole adapter family, and no class-specific declaration has to exist for it. -/
theorem ValidOnFrames.of_not {P : TaskFrame → Prop} {φ : Formula} (h : ¬ ValidOnFrames P φ) :
    ¬ ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F) (τ : WorldHistory F),
        τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (ValidOnFrames.of_forall_total h')

/-- The contrapositive of `ValidIn.of_forall_total`, in the shape a countermodel extraction
wants: from a failure of `ValidIn fc` it hands back a failure of the unbundled ∀-statement,
which `push Not` can then take apart.

This **is** the countermodel-extraction adapter for every tag. Three per-class contrapositives
used to sit beside it, one at each of `.Dense`, `.Discrete` and `.Dedekind`; each was this lemma
at a fixed tag with `fc.Sat F` unfolded to that class's frame condition, and all three were
deleted in favour of it. Only `valid.of_not` survives, because it discharges `Sat .Base = True`
rather than restating a frame condition. -/
theorem ValidIn.of_not {fc : ProofSystem.FrameClass} {φ : Formula} (h : ¬ ValidIn fc φ) :
    ¬ ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F),
        τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (ValidIn.of_forall_total h')

/--
A formula is valid over dense temporal orders if it is true in all models where D is
densely ordered, at all total histories, and all times.

This restricts `valid` to temporal types with `DenselyOrdered D`, capturing the
frame condition for the density axiom DN: `F(phi) -> F(F(phi))`.

**Now an abbreviation over `ValidIn`.** The frame constraint is no longer inlined here: it is
`FrameClass.Sat .Dense`, which is `TaskFrame.IsDense`, `def:frame-properties`' Dense clause. The
binder shape this definition used to have is recovered by the generic
`ValidIn.of_forall_total` / `ValidIn.apply_total`, and the density witness reaches typeclass
resolution directly: `Sat` is `@[reducible]` and `TaskFrame.IsDense` is an `abbrev`, so a
`Sat .Dense F` hypothesis registers as a `DenselyOrdered` instance the moment it is introduced.
No class-specific adapter is needed, and none exists.

**Notation**: `⊨_dense φ`
-/
def ValidDense (φ : Formula) : Prop := ValidIn ProofSystem.FrameClass.Dense φ

/--
A formula is valid over discrete temporal orders if it is true in all models where D
has successor and predecessor structure, at all total histories, and all times.

This restricts `valid` to temporal types with `SuccOrder D` and `PredOrder D`,
capturing the frame condition for the discreteness axioms DF/DP.

**Now an abbreviation over `ValidIn`.** The frame constraint is `FrameClass.Sat .Discrete`, which
is `TaskFrame.IsSuccArchDiscrete` — `def:TMplus-f`'s Hölder narrowing to ℤ-time, *not*
`def:frame-properties`' bare Discrete clause. Recording the narrowing in the tag's interpretation
rather than in a binder list here is what keeps `soundness_discrete` from silently widening its
frame class. The binder shape this definition used to have is recovered by the generic
`ValidIn.of_forall_total` / `ValidIn.apply_total` followed by `sat_intro`, which destructures the
`IsSuccArchDiscrete` existential into the four instances.

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

/--
**THE `ValidComplete` CAVEAT — canonical statement; every other site in the tree points here.**

`ValidComplete` is the **only** `Valid*` name in this development that is not `ValidIn` at the
tag its name suggests, and this paragraph is the only place that fact is argued. Every other
module that needs it carries a one-line pointer to here rather than a copy of the argument; if
you are about to write a second copy, write a pointer instead.

Since the rename pass, `ValidDense = ValidIn .Dense`, `ValidDiscrete = ValidIn .Discrete`,
`ValidDedekind = ValidIn .Dedekind` and `valid = ValidIn .Base` all hold definitionally. This
predicate is the sole exception: it is `ValidOnFrames TaskFrame.IsComplete` —
`def:frame-properties`' *bare* Complete clause, which `ℤ` satisfies — and it is deliberately not
a `ValidIn` tag, because no `FrameClass` constructor denotes the bare Complete class (see the
`FrameClass` docstring in `ProofSystem/Axioms.lean`).

**Do not retarget `soundness_dedekind` at it.** `FrameClass.Dedekind` sits strictly above
`FrameClass.Dense`, so `Axiom.density` (`GGφ → Gφ`) and `Axiom.dense_indicator` (`¬(⊥ U ⊤)`) are
admissible in a `.Dedekind` derivation. Both are FALSE on `ℤ`: for `density`, take `φ` true
exactly at times `≥ t + 2`, so `GGφ` holds at `t` while `Gφ` fails; for `dense_indicator`,
`⊥ U ⊤` is true on `ℤ` because every point has an immediate successor. `ℤ` satisfies every binder
of this predicate (Mathlib gives it a `ConditionallyCompleteLinearOrder`), so a
`soundness_dedekind : DerivationTree .Dedekind … → ValidComplete` would be **refutable**.
`soundness_dedekind` targets `ValidDedekind`; this predicate is landed as the strictly weaker
statement and as the target of the forgetful bridge from `valid`.

**Why the name still reads oddly, and why that is recorded rather than fixed.** The paper calls
the dense-and-complete class Complete; this tree calls it Dedekind, because "complete" is already
load-bearing here for *proof-theoretic* completeness. That naming deviation of record is stated
in full at `TaskFrame.IsDedekind` (`Semantics/FrameProperty.lean`) and is a *different* thing from
the trap this paragraph closes: the rename removed `ValidDedekind ≠ ValidIn .Dedekind`, it did not
remove the paper-versus-tree deviation, which stands.

A formula is valid over **Dedekind-complete** temporal orders if it is true in all models
whose temporal type `D` has the least-upper-bound property, at all total histories, and all
times.

**Now an abbreviation, not a hand-written binder list.** The class is named once, as
`TaskFrame.IsComplete`, and this predicate is `ValidOnFrames` at it. The generic
`ValidOnFrames.{of_forall_total, apply_total, of_not}` triple adapts between this shape and the
explicit-hypothesis shape the definition used to have — this predicate is exactly why that triple
must exist at the bare-predicate layer and not only at a `FrameClass` tag.

Dedekind completeness is expressed by the explicit Prop-valued hypothesis

  `∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`

rather than by swapping the tree's `[LinearOrder D]` binder for
`[ConditionallyCompleteLinearOrder D]`. This is deliberate and strictly less invasive: every
downstream `[LinearOrder D]`-indexed lemma continues to apply with no instance-unification
risk.

**`DenselyOrdered` is deliberately ABSENT from this binder list.** The integers carry a
Mathlib `ConditionallyCompleteLinearOrder` instance
(`Mathlib/Data/Int/ConditionallyCompleteOrder.lean`), so `ℤ` satisfies every binder of
`ValidComplete`. Including density here would silently narrow the predicate to real flow
alone; the density-carrying variant is the separate `ValidDedekind` below.

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
`soundness_dedekind : DerivationTree .Dedekind … → ValidComplete` would be refutable.
`soundness_dedekind` therefore targets `ValidDedekind`. This predicate is landed as the
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
def ValidComplete (φ : Formula) : Prop := ValidOnFrames TaskFrame.IsComplete φ

/--
A formula is valid over **dense Dedekind-complete** temporal orders. This is the real-flow
predicate, and sharply so: up to order-and-group isomorphism `ℝ` is the *only* nontrivial model,
not merely a paradigm one.

**This is `ValidIn .Dedekind`** — `FrameClass.Sat .Dedekind` is `TaskFrame.IsDedekind`, the
conjunction of `def:frame-properties`' Dense and Complete clauses — and it is therefore the
predicate the `.Dedekind` tag denotes, whatever its name may suggest about `ValidComplete`. The
binder shape this definition used to have is recovered by the generic
`ValidIn.of_forall_total` / `ValidIn.apply_total` followed by `sat_intro`, which splits
`IsDedekind` into the density instance and the least-upper-bound hypothesis.

**Why the density binder is exactly the right cut.** By
`FormalSystem.Semantics.complete_duration_discrete_or_dense`
(`Semantics/DurationClassification.lean`), a duration group satisfying the least-upper-bound
hypothesis is *either* `≃+o ℤ` *or* densely ordered, and by
`FormalSystem.Semantics.complete_not_dense_iso_int` those branches are exclusive. So adding
`DenselyOrdered` deletes precisely the `ℤ` branch of the Hölder dichotomy and nothing else —
which is why `ℤ` is excluded here even though it satisfies every binder of `ValidComplete`.
(Getting from "dense and complete" to a literal `≃+o ℝ` needs one further step this repository
does not carry; the composition path and the reason it is out of scope are recorded in the
`DurationClassification` module docstring.)

**This is the target of `soundness_dedekind`**, not `ValidComplete`, and retargeting it at the
weaker predicate yields a refutable theorem. See the `ValidComplete` caveat in `Semantics/Validity.lean` — the one place the `ValidComplete` / `ValidDedekind` distinction is argued in full.

The placement of `Dedekind` above `Dense` is itself primary-source: Reynolds 1992 (printed
p.168) includes in US/R "axioms for density and no end points: `K⁺⊤`, `K⁻⊤`, `F⊤`, `P⊤`", and
`K⁺⊤` is `¬(¬⊤ U ⊤)` in this tree's guard-first infix, which normalises (`¬⊤ ↝ ⊥`) to
`¬(⊥ U ⊤)`, this tree's `Axiom.dense_indicator`.
-/
def ValidDedekind (φ : Formula) : Prop := ValidIn ProofSystem.FrameClass.Dedekind φ

namespace Validity

/-! ### Equivalence with the `FrameClass`-indexed layer

Each class-restricted predicate above, matched against its `ValidIn` counterpart. Four of the five
are now `Iff.rfl`, because the predicate on the left *is* the one on the right by definition; they
are kept as named lemmas so that a call site can cite the correspondence explicitly, and so that a
future edit which pulls the two apart fails here rather than somewhere downstream.
`valid_iff_validIn_base` is the one that still carries a proof: `valid` is not yet an abbreviation.

Note the shape of the last one: `ValidComplete` is **not** `ValidIn .Dedekind`. See its own
docstring, and `TaskFrame.IsComplete`'s. -/

/-- `valid` is `ValidIn` at the unconstrained class: `Sat .Base` is `True`, so the tag imposes
nothing and the two quantify over the same frames. This is the symmetry claim
`valid = ValidIn .Base` beside `Derivable .Base`. -/
theorem valid_iff_validIn_base (φ : Formula) :
    valid φ ↔ ValidIn ProofSystem.FrameClass.Base φ := Iff.rfl

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

/-- `ValidDedekind` is `ValidIn .Dedekind`: its density binder together with its
least-upper-bound hypothesis is exactly the conjunction `TaskFrame.IsDedekind` that
`Sat .Dedekind` returns. This is the `soundness_dedekind` target. -/
theorem validDedekind_iff_validIn_dedekind (φ : Formula) :
    ValidDedekind φ ↔ ValidIn ProofSystem.FrameClass.Dedekind φ := Iff.rfl

/-- `ValidComplete` is `ValidOnFrames TaskFrame.IsComplete` — and therefore **not** any `ValidIn`.

`def:frame-properties`' bare Complete clause admits `ℤ`, and no `FrameClass` constructor denotes
that class (`ProofSystem/Axioms.lean`'s `FrameClass` docstring says so explicitly: there is no
axiom set here for `Th(ℤ) ∩ Th(ℝ)`). That this predicate still lands inside the collapse — with its
bridge to `ValidDedekind` falling out of `ValidOnFrames.mono` like every other bridge — is the
whole reason the primitive is indexed by a frame predicate rather than by a tag. -/
theorem validComplete_iff_validOnFrames_isComplete (φ : Formula) :
    ValidComplete φ ↔ ValidOnFrames TaskFrame.IsComplete φ := Iff.rfl

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
`ValidComplete`. The least-upper-bound hypothesis is simply discarded — `valid` already
quantifies over every `D` satisfying the weaker binder set.
-/
theorem valid_implies_validComplete {φ : Formula} (h : valid φ) : ValidComplete φ :=
  ValidOnFrames.mono (fun _ _ => trivial) ((valid_iff_validIn_base φ).mp h)

/--
Validity implies validity over dense Dedekind-complete orders: every valid formula is
`ValidDedekind`.
-/
theorem valid_implies_validDedekind {φ : Formula} (h : valid φ) : ValidDedekind φ :=
  ValidIn.mono (ProofSystem.FrameClass.base_le _) ((valid_iff_validIn_base φ).mp h)

/--
`ValidComplete` is strictly stronger than `ValidDedekind`: adding the `DenselyOrdered`
binder restricts the class of temporal types quantified over, so validity on all
Dedekind-complete orders entails validity on the dense ones.

This is the bridge that makes the SETTLED soundness target coherent: `soundness_dedekind`
proves the weaker `ValidDedekind`, and anything genuinely established at
`ValidComplete` can be transported into it via this lemma.
-/
theorem validDedekind_of_validComplete {φ : Formula} (h : ValidComplete φ) :
    ValidDedekind φ :=
  ValidOnFrames.mono (fun _ => TaskFrame.isComplete_of_isDedekind) h

/--
Valid formulas are semantic consequences of empty context.
-/
theorem valid_iff_empty_consequence (φ : Formula) :
    (⊨ φ) ↔ ([] ⊨ φ) := by
  constructor
  · intro h
    refine SemanticConsequence.of_forall ?_
    intro F M τ hτ t _
    exact h.apply F M τ hτ t
  · intro h
    refine valid.of_forall_total ?_
    intro F M τ hτ t
    exact h.apply F M τ hτ t (by intro ψ hψ; exact absurd hψ List.not_mem_nil)

/--
Semantic consequence is monotonic: adding premises preserves consequences.
-/
theorem consequence_monotone {Γ Δ : Context} {φ : Formula} :
    Γ ⊆ Δ → (Γ ⊨ φ) → (Δ ⊨ φ) := by
  intro h_sub h_cons
  refine SemanticConsequence.of_forall ?_
  intro F M τ hτ t h_delta
  exact h_cons.apply F M τ hτ t (fun ψ hψ => h_delta ψ (h_sub hψ))

/--
If a formula is valid, it is a semantic consequence of any context.
-/
theorem valid_consequence (φ : Formula) (Γ : Context) :
    (⊨ φ) → (Γ ⊨ φ) :=
  fun h => SemanticConsequence.of_forall fun F M τ hτ t _ => h.apply F M τ hτ t

/--
Context with all formulas true implies each formula individually true.
-/
theorem consequence_of_member {Γ : Context} {φ : Formula} :
    φ ∈ Γ → (Γ ⊨ φ) := by
  intro h
  refine SemanticConsequence.of_forall ?_
  intro F M τ hτ t h_all
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
  fun h_unsat => SemanticConsequence.of_forall fun F M τ hτ t h_all =>
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
  refine valid.of_forall_total ?_
  intro F M τ hτ t
  exact h.apply F M τ hτ t τ hτ

end Validity

end FormalSystem.Semantics
