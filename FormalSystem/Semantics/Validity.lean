/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Syntax.Context
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

Formally: for every temporal type `D`, every task frame `F : ParamTaskFrame D`, every model `M` over
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
def satisfiable (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] (Γ : Context) :
    Prop :=
  ∃ (F : ParamTaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    ∀ φ ∈ Γ, TruthAt M τ t φ

/--
A context is absolutely satisfiable if it is satisfiable in some temporal type.

Carries `Nontrivial` alongside the other structure binders so that `satisfiable` applies; see
the "No paper anchor" note on `satisfiable`.
-/
def SatisfiableAbs (Γ : Context) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : Nontrivial D), satisfiable D Γ

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

/--
A formula is valid over dense temporal orders if it is true in all models where D is
densely ordered, at all total histories, and all times.

This restricts `valid` to temporal types with `DenselyOrdered D`, capturing the
frame condition for the density axiom DN: `F(phi) -> F(F(phi))`.

**Notation**: `⊨_dense φ`
-/
def ValidDense (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    TruthAt M τ t φ

/--
A formula is valid over discrete temporal orders if it is true in all models where D
has successor and predecessor structure, at all total histories, and all times.

This restricts `valid` to temporal types with `SuccOrder D` and `PredOrder D`,
capturing the frame condition for the discreteness axioms DF/DP.

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
  requires normalizing `D` to `ℤ` and transporting `ParamTaskFrame`, `TaskModel`, `WorldHistory`, and
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
def ValidDiscrete (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
    [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration]
    (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    TruthAt M τ t φ

/--
A formula is valid over **Dedekind-complete** temporal orders if it is true in all models
whose temporal type `D` has the least-upper-bound property, at all total histories, and all
times.

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
  ∀ (F : TaskFrame)
    (_ : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    TruthAt M τ t φ

/--
A formula is valid over **dense Dedekind-complete** temporal orders: `ValidDedekind` with
`[DenselyOrdered D]` added to the binder list. This is the real-flow predicate, and sharply so:
up to order-and-group isomorphism `ℝ` is the *only* nontrivial model, not merely a paradigm one.

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
def ValidDedekindDense (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) [DenselyOrdered F.Duration]
    (_ : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    TruthAt M τ t φ

namespace Validity

/--
Validity implies validity over dense orders: every valid formula is ValidDense.
-/
theorem valid_implies_valid_dense {φ : Formula} (h : valid φ) : ValidDense φ := by
  intro F _ M τ hτ t
  exact h F M τ hτ t

/--
Validity implies validity over discrete orders: every valid formula is ValidDiscrete.
-/
theorem valid_implies_valid_discrete {φ : Formula} (h : valid φ) : ValidDiscrete φ :=
  fun F _ _ _ _ M τ hτ t => h F M τ hτ t

/--
Validity implies validity over Dedekind-complete orders: every valid formula is
`ValidDedekind`. The least-upper-bound hypothesis is simply discarded — `valid` already
quantifies over every `D` satisfying the weaker binder set.
-/
theorem valid_implies_validDedekind {φ : Formula} (h : valid φ) : ValidDedekind φ :=
  fun F h_lub M τ hτ t => h F M τ hτ t

/--
Validity implies validity over dense Dedekind-complete orders: every valid formula is
`ValidDedekindDense`.
-/
theorem valid_implies_validDedekindDense {φ : Formula} (h : valid φ) : ValidDedekindDense φ :=
  fun F _ h_lub M τ hτ t => h F M τ hτ t

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
  fun F _ h_lub M τ hτ t => h F h_lub M τ hτ t

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
    (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D],
      ¬satisfiable D Γ) →
      (Γ ⊨ φ) :=
  fun h_unsat F M τ hτ t h_all =>
    absurd ⟨F.toParam, M, τ, hτ, t, h_all⟩ (h_unsat F.Duration)

/--
Unsatisfiable context in a fixed temporal type implies consequence in that type.
This is the type-specific version of explosion.
-/
theorem unsatisfiable_implies_all_fixed {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D]
    {Γ : Context} {φ : Formula} :
    ¬satisfiable D Γ → ∀ (F : ParamTaskFrame D) (M : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal)
      (t : D), (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ := by
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

/-! ## Frame-relative validity `⊨_F` (`def:frame-validity`)

Charter §8's optional deliverable. Everything above quantifies over *all* frames; this section
adds the notion that holds a single frame fixed.

**Definition of record — `def:frame-validity`**, verbatim:

> A well-formed sentence phi of BL is *valid over a task frame* F = ⟨W, D, ⇒⟩ which we may write
> |=_F phi if and only if M,tau,x |= phi for every model M = ⟨W, D, ⇒, |·|⟩ where
> F = ⟨W, D, ⇒⟩, possible world tau in H_F, and time x in D.

**No notation is introduced for `⊨_F`.** `Truth.lean` records that a `TruthAt` notation was
dropped because it conflicts with the `⊨` validity notation in this file; a subscripted variant
would sit in the same parser neighbourhood for no gain. The ASCII name `ParamTaskFrame.ValidOn` is
used instead, and dot-notation (`F.ValidOn φ`) reads as the paper's `⊨_F φ` does.

**This is not a parallel validity notion.** `valid_iff_forall_validOn` below proves the two are
related by quantification over frames, so `ValidOn` is a specialization of the one validity
predicate rather than a competitor to it — the same discipline `ParamTaskFrame.HF` follows with
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
arguments: `ParamTaskFrame` carries them as structure fields, and `cor:occurrence` reads them off the
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

This is the theorem that keeps `ParamTaskFrame.ValidOn` from being a second, competing validity
notion. `valid` (`def:logical-consequence`'s closing clause) and `ParamTaskFrame.ValidOn`
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

end FormalSystem.Semantics
