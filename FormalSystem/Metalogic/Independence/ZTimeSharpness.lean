/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Metalogic.Soundness
-- The bare `realOrder` used in the `.RTime` results below resolves uniquely to
-- `FormalSystem.Semantics.realOrder` only while `FormalSystem.Metalogic.DedekindNonCompactness`
-- (which declares a second `realOrder` in a namespace this file also opens) stays out of this
-- module's import closure; importing it here reintroduces an `Ambiguous term realOrder` error.
import FormalSystem.Semantics.Correspondence.RigidityReal

/-!
# Sharpness of the `.ZTime` tag of `Axiom.minFrameClass`

`Axiom.minFrameClass` (`FormalSystem/ProofSystem/Axioms.lean`) assigns each axiom constructor the
*smallest* frame class at which that axiom is meant to be valid, and `axiom_validIn_min`
(`FormalSystem/Metalogic/Soundness.lean`) proves the **upper** bound: every axiom really is valid
at its own tag. Nothing in that theorem says the tag could not have been *lower*. For the two
axioms tagged `.ZTime` — `Axiom.prior_UZ` and `Axiom.z1`, `def:BX-z`'s ℤ-time narrowing — this
module supplies the missing **lower** bound, and then some: neither is valid at
`FrameClass.Base`, hence (by `eq_base_of_lt_ztime`, `.Base` being the unique class strictly below
`.ZTime`) neither is valid at any class strictly below `.ZTime`; and neither is valid at `.Dense`
or at `.RTime`, the two classes incomparable with `.ZTime`. Taken together with
`axiom_validIn_min`, that is not merely minimality of the tag but a full *characterization*:
`prior_UZ_validIn_iff_ztime` and `z1_validIn_iff_ztime` state that each axiom's atomic instance is
valid at `fc` exactly when `fc = .ZTime`.

## What is refuted is discreteness, not the Archimedean property

Both countermodels are the translation frame (`Semantics/Frames/Standard.lean`) over a duration
group that is **densely ordered**, with the `translationHist`/`translationModel`/
`translation_realizes` atom-realisation layer of `Semantics/Correspondence/DurationFrames.lean`.
The two generic lemmas `not_validOn_prior_UZ_dense` and `not_validOn_z1_dense` are stated at an
arbitrary `(D : TemporalOrder) [DenselyOrdered ↑D]`; `ztimeSharpOrder := TemporalOrder.of ℚ`
instantiates them to reach `.Base`, whose only structural requirement is regularity.

So the property doing the work is *non-discreteness*: between any two times there is a third, so
`Axiom.prior_UZ`'s `U(¬p, p)` can never find a first `p`-time with a `¬p`-guarded initial
segment, and `Axiom.z1`'s `FGp → Gp` collapse fails at a threshold with no immediate predecessor.
It is **not** the Archimedean property, and no claim is made here that either axiom is refutable
specifically over ℚ, or specifically over a non-Archimedean order, beyond what the written
statements say. The non-Archimedean discrete carriers are a different story, told by
`Independence/LexIntWitness.lean`.

## The `z1` half has an antecedent in the neighbouring L-minus language

`Metalogic/Conservativity/DenseObstructionTransfer.lean` runs the dense obstruction for the
L-minus schema `Z1` on the derivability side. This module is the same story told semantically and
in the native language: it refutes `ValidIn` of `Axiom.z1`'s own formula, so nothing has to be
transferred across `MinusLanguage.tr` and the `tr_ne_untl` mismatch recorded in
`Metalogic/Conservativity.lean` — `Formula.someFuture` is a top-level `untl` and nothing in the
range of `tr` is — simply never arises. The two modules should be read as one result at two
levels.

## The frame-versus-model obstruction does not bite here

`Independence/CoNotPriorU.lean` records that its own result had to be restated over a *fixed*
`TaskModel`, because frame-validity quantifies over all valuations, and on a flow rich enough to
realize an arbitrary set of times, frame-validity of `CO` already forces gap-freeness and so
forces Prior-U valid too. That obstruction arises only because that statement must simultaneously
**validate** something (`CO`) while refuting something else. A bare non-validity claim validates
nothing, so the obstruction does not apply, and the proofs below are in fact frame-level
(`¬ F.ValidOn φ`) — strictly stronger than a model-fixed refutation.

## Why the lower bound is wanted

The dual-verification architecture pairs this proof checker with a model checker whose bimodal
certificate search is, by design, permanently silent on the inferences tagged `.ZTime`: no
certificate can ever exist for `prior_UZ` or `z1`, since a certificate would exhibit a ℤ-time
countermodel contradicting `axiom_validIn_min`. That half of the adequacy argument was already
machine-checked. The other half — that these inferences are nonetheless refutable at a
non-discrete temporal order, so the silence is a genuine frame-class gap rather than an artefact
— was carried by a literature citation at exactly the point where the argument asserts a
permanent limit. `not_validIn_base_prior_UZ` and `not_validIn_base_z1` are that half, and the
gap is now proved rather than cited.

## The claim is a characterization, not only a lower bound

`prior_UZ_validIn_iff_ztime` and `z1_validIn_iff_ztime` say more than minimality of the tag:
each axiom's atomic instance is valid at `FrameClass.ZTime` and at **no other frame class at
all**. Minimality alone would leave `.Dense` and `.RTime` open, since neither is below `.ZTime`
in the frame-class order — that order is not linear, and `eq_base_of_lt_ztime` reaches only
`.Base`. `not_validIn_dense_prior_UZ` / `not_validIn_dense_z1` and `not_validIn_rtime_prior_UZ` /
`not_validIn_rtime_z1` close those two classes directly, over `ztimeSharpOrder` and `realOrder`
respectively, and a four-way `cases fc` then assembles the biconditional with `axiom_validIn_min`
supplying the one positive case. `.RTime` is worth stating separately because Dedekind
completeness is the strongest structure any of the four classes imposes, and it still buys the
axioms nothing: what they need is discreteness, which ℝ lacks exactly as ℚ does.

## Scope

Only the two `.ZTime` axioms. The `.Dense` rows (`density`, `dense_indicator`) and the `.RTime`
rows (`prior_U_gap`, `sep`) of `Axiom.minFrameClass` remain upper-bound-only; nothing here speaks
to them. Every statement below is at `Formula.atom p` rather than schematic in `φ`, and that is
forced: `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and so is valid at every class, which
would falsify the `∀ φ` form of both the `.Base` results and the biconditionals.

## Main results

* `eq_base_of_lt_ztime` — `.Base` is the unique frame class strictly below `.ZTime`
* `not_validOn_prior_UZ_dense`, `not_validOn_z1_dense` — the frame-level refutations at an
  arbitrary densely ordered duration group
* `not_validIn_base_prior_UZ`, `not_validIn_base_z1` — the `.Base` non-validity results
* `prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp` — non-validity at every class strictly
  below `.ZTime`, i.e. minimality of the tag
* `not_derivable_base_prior_UZ`, `not_derivable_base_z1` — the underivability corollaries through
  soundness
* `not_validIn_dense_prior_UZ`, `not_validIn_dense_z1` — non-validity at `.Dense`, which is
  incomparable with `.ZTime` rather than below it
* `not_validIn_rtime_prior_UZ`, `not_validIn_rtime_z1` — the same at `.RTime`, over `realOrder`
* `prior_UZ_validIn_iff_ztime`, `z1_validIn_iff_ztime` — the full characterization,
  `ValidIn fc φ ↔ fc = .ZTime`, exhausting all four frame classes

## Tags

independence · sharpness · minimality · ztime · dense · def:BX-z
-/

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.Independence

/-! ## Shape pins

Each `example` below type-checks only if the formula this module refutes is *exactly* the one the
matching `Axiom` constructor produces. They make transcription fidelity a compiler obligation
rather than a reading: without them a mis-transcribed formula would yield a true but vacuous
non-validity result about some other formula.

Note in particular that `Axioms.lean`'s prose rendering of `prior_UZ`, `F(φ) → U(φ, ¬φ)`, writes
its two arguments in the opposite order to the constructor's `Formula.untl φ.neg φ`. That is not
a defect: `Axioms.lean`'s own notation block declares three renderings, of which the constructor
and the infix `φ U ψ` are guard-first while the *prefix* `U(e, g)` is deliberately event-first,
keyed to what `Formula.prettyPrint` emits (`Automation/Normalization.lean`) so that the
docstrings stay comparable line-for-line with `typst/generated/machine-appendix.jsonl`'s
`schema_string`. The prose is correct under that convention, and the pin below confirms it
against the constructor.
-/

/-- Shape pin: the formula below is exactly `Axiom.prior_UZ`'s. -/
example (φ : Formula) : Axiom (φ.someFuture.imp (Formula.untl φ.neg φ)) := Axiom.prior_UZ φ

/-- Shape pin: the formula below is exactly `Axiom.z1`'s. -/
example (φ : Formula) :
    Axiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) :=
  Axiom.z1 φ

/-! ## The order fact -/

/--
**`.Base` is the unique frame class strictly below `.ZTime`.**

This is what turns a single `.Base` refutation into a minimality statement: there is no other
class to check. `.Dense` and `.RTime` are not below `.ZTime` at all — the frame-class order is not
linear — and the two `decide` calls discharge exactly that.
-/
theorem eq_base_of_lt_ztime {fc : FrameClass} (h : fc < FrameClass.ZTime) :
    fc = FrameClass.Base := by
  cases fc with
  | Base => rfl
  | Dense => exact absurd h.le (by decide)
  | ZTime => exact absurd rfl h.ne
  | RTime => exact absurd h.le (by decide)

/-! ## The frame-level refutations, at an arbitrary densely ordered duration group -/

/--
**`Axiom.prior_UZ` fails on the translation frame over any densely ordered duration group.**

At an atom `p` realized by the set of strictly positive times, the antecedent `Fp` holds at `0`
(any `c > 0` witnesses it), but the consequent `U(¬p, p)` cannot: a witness would be a time
`s > 0` with `p` at `s` and `¬p` throughout `(0, s)`, and density supplies an `r` with
`0 < r < s`, at which `p` does hold. Discreteness is exactly what the consequent needs, and
density is exactly its failure.
-/
theorem not_validOn_prior_UZ_dense (D : TemporalOrder) [DenselyOrdered (D : Type)] (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := by
  intro h
  haveI := noMaxOrder_of_duration D
  obtain ⟨c, hc⟩ := exists_gt (0 : (D : Type))
  set A : Set (D : Type) := {x | 0 < x} with hA
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).someFuture := by
    rw [Truth.some_future_iff]
    exact ⟨c, hc, (translation_realizes D A p c).mpr hc⟩
  obtain ⟨s, h0s, _hps, hguard⟩ := hval hant
  obtain ⟨r, h0r, hrs⟩ := exists_between h0s
  have hne := hguard r h0r hrs
  rw [Truth.neg_iff] at hne
  exact hne ((translation_realizes D A p r).mpr h0r)

/--
**`Axiom.z1` fails on the translation frame over any densely ordered duration group.**

At an atom `p` realized by the upper set `{x | c ≤ x}` for some `c > 0`, the auxiliary `hG`
computes `Gp` at `t` to be exactly `c ≤ t` — the forward direction is where density is spent, via
an intermediate point between a putative `t < c` and `c`. The antecedent `G(Gp → p)` then holds at
`0`, and `FGp` holds at `0` with witness `c`; but `Gp` fails at `0`, since `0 < c`. So the
`.ZTime` instance `G(Gp → p) → (FGp → Gp)` is refuted.
-/
theorem not_validOn_z1_dense (D : TemporalOrder) [DenselyOrdered (D : Type)] (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := by
  intro h
  haveI := noMaxOrder_of_duration D
  obtain ⟨c, hc⟩ := exists_gt (0 : (D : Type))
  set A : Set (D : Type) := {x | c ≤ x} with hA
  have hG : ∀ t : (D : Type),
      TruthAt (translationModel D A) (translationHist D) t (Formula.atom p).allFuture
        ↔ c ≤ t := by
    intro t
    rw [translation_realizes_allFuture]
    refine ⟨fun hh => ?_, fun hh s hs => hh.trans hs.le⟩
    by_contra hcon
    push Not at hcon
    obtain ⟨s, hts, hsc⟩ := exists_between hcon
    exact absurd (hh s hts) (not_le.mpr hsc)
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      ((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture := by
    rw [Truth.future_iff]
    intro s _
    rw [Truth.imp_iff, hG]
    exact fun hs => (translation_realizes D A p s).mpr hs
  have hcons := hval hant
  rw [Truth.imp_iff] at hcons
  have hFGp : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).allFuture.someFuture := by
    rw [Truth.some_future_iff]
    exact ⟨c, hc, (hG c).mpr (le_refl c)⟩
  exact absurd ((hG 0).mp (hcons hFGp)) (not_le.mpr hc)

/-! ## Instantiation at `.Base` -/

/--
The duration group the two `.Base` results are read off at: the rationals, densely ordered, which
is all `FrameClass.Base` asks of a frame beyond regularity.

The name deliberately avoids `qD`, which
`Metalogic/Conservativity/DenseObstructionTransfer.lean` already declares in the enclosing
`FormalSystem.Metalogic` namespace.
-/
noncomputable abbrev ztimeSharpOrder : TemporalOrder := TemporalOrder.of ℚ

/--
**`Axiom.prior_UZ` is not valid at `FrameClass.Base`.**

The atomic instance is forced, not a convenience: the schematic `∀ φ` form of this statement is
false, since `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and so *is* `.Base`-valid.
-/
theorem not_validIn_base_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.Base
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun h => not_validOn_prior_UZ_dense ztimeSharpOrder p (h _ inferInstance)

/--
**`Axiom.z1` is not valid at `FrameClass.Base`.**

As with `not_validIn_base_prior_UZ`, the instance is atomic by necessity rather than convenience.
-/
theorem not_validIn_base_z1 (p : Atom) :
    ¬ ValidIn FrameClass.Base
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun h => not_validOn_z1_dense ztimeSharpOrder p (h _ inferInstance)

/-! ## Minimality of the tag -/

/--
**The `.ZTime` tag of `Axiom.minFrameClass` is minimal for `prior_UZ`.**

No frame class strictly below `.ZTime` validates the axiom. With `axiom_validIn_min`
(`FormalSystem/Metalogic/Soundness.lean`) supplying the upper bound, this closes the `prior_UZ`
row of `Axiom.minFrameClass` in both directions.
-/
theorem prior_UZ_minFrameClass_sharp (p : Atom) {fc : FrameClass} (hfc : fc < FrameClass.ZTime) :
    ¬ ValidIn fc ((Formula.atom p).someFuture.imp
      (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  eq_base_of_lt_ztime hfc ▸ not_validIn_base_prior_UZ p

/--
**The `.ZTime` tag of `Axiom.minFrameClass` is minimal for `z1`.**

The `z1` counterpart of `prior_UZ_minFrameClass_sharp`, and with it the second half of the
`.ZTime` row.
-/
theorem z1_minFrameClass_sharp (p : Atom) {fc : FrameClass} (hfc : fc < FrameClass.ZTime) :
    ¬ ValidIn fc (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
      ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  eq_base_of_lt_ztime hfc ▸ not_validIn_base_z1 p

/-! ## Underivability at `.Base` -/

/--
**`Axiom.prior_UZ`'s atomic instance is not derivable from the `.Base` axioms.**

Soundness at `.Base` (`soundness_validIn`) plus `not_validIn_base_prior_UZ`. This is the form in
which the result bears on the proof system rather than on the semantics.
-/
theorem not_derivable_base_prior_UZ (p : Atom) :
    ¬ Derivable FrameClass.Base []
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun ⟨d⟩ => not_validIn_base_prior_UZ p (soundness_validIn d)

/--
**`Axiom.z1`'s atomic instance is not derivable from the `.Base` axioms.**

The `z1` counterpart of `not_derivable_base_prior_UZ`.
-/
theorem not_derivable_base_z1 (p : Atom) :
    ¬ Derivable FrameClass.Base []
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun ⟨d⟩ => not_validIn_base_z1 p (soundness_validIn d)

/-! ## Non-validity at the two incomparable classes -/

/--
**`Axiom.prior_UZ` is not valid at `FrameClass.Dense`.**

`.Dense` is not below `.ZTime` in the frame-class order, so this is not implied by
`prior_UZ_minFrameClass_sharp`; it is a separate refutation, and it is what makes the
characterization below exhaustive. The witness is the same `ztimeSharpOrder` frame as at `.Base`:
a densely ordered duration group satisfies `Sat .Dense` outright, both conjuncts by instance
search.
-/
theorem not_validIn_dense_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.Dense
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun h => not_validOn_prior_UZ_dense ztimeSharpOrder p (h _ ⟨inferInstance, inferInstance⟩)

/--
**`Axiom.z1` is not valid at `FrameClass.Dense`.**

The `z1` counterpart of `not_validIn_dense_prior_UZ`, over the same rational-duration witness.
-/
theorem not_validIn_dense_z1 (p : Atom) :
    ¬ ValidIn FrameClass.Dense
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun h => not_validOn_z1_dense ztimeSharpOrder p (h _ ⟨inferInstance, inferInstance⟩)

/--
**`Axiom.prior_UZ` is not valid at `FrameClass.RTime`.**

`.RTime` adds Dedekind completeness on top of density, and is likewise incomparable with `.ZTime`,
so it too needs its own refutation. Completeness rules the rationals out as a witness, so the
duration group here is `realOrder`; the third `Sat .RTime` component is `TaskFrame.IsComplete`,
discharged from `Real.exists_isLUB` exactly as `Metalogic/DedekindNonCompactness.lean` does.
Density is what the generic lemma consumes, and ℝ has it, so completeness buys the axiom nothing.
-/
theorem not_validIn_rtime_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.RTime
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) :=
  fun h => not_validOn_prior_UZ_dense realOrder p
    (h _ ⟨inferInstance, inferInstance, fun _ hne hbd => Real.exists_isLUB hne hbd⟩)

/--
**`Axiom.z1` is not valid at `FrameClass.RTime`.**

The `z1` counterpart of `not_validIn_rtime_prior_UZ`, over the same real-duration witness.
-/
theorem not_validIn_rtime_z1 (p : Atom) :
    ¬ ValidIn FrameClass.RTime
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) :=
  fun h => not_validOn_z1_dense realOrder p
    (h _ ⟨inferInstance, inferInstance, fun _ hne hbd => Real.exists_isLUB hne hbd⟩)

/-! ## The full characterization -/

/--
**`Axiom.prior_UZ`'s atomic instance is valid at exactly one frame class: `.ZTime`.**

This is the strongest form of the `prior_UZ` sharpness claim. The reverse direction is
`prior_UZ_valid` (through `axiom_validIn_min`'s upper bound); the forward direction runs a case
split over all four constructors of `FrameClass`, discharging `.Base`, `.Dense` and `.RTime`
against the three non-validity results. It deliberately does **not** route through
`eq_base_of_lt_ztime`: `.Dense` and `.RTime` are incomparable with `.ZTime`, not below it, so the
order fact covers only one of the three refuted classes.

The instance is atomic by necessity, not convenience: the schematic `∀ φ` form is false, since
`Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and so is valid everywhere.
-/
theorem prior_UZ_validIn_iff_ztime (p : Atom) (fc : FrameClass) :
    ValidIn fc ((Formula.atom p).someFuture.imp
      (Formula.untl (Formula.atom p).neg (Formula.atom p)))
      ↔ fc = FrameClass.ZTime := by
  refine ⟨fun h => ?_, ?_⟩
  · cases fc with
    | Base => exact absurd h (not_validIn_base_prior_UZ p)
    | Dense => exact absurd h (not_validIn_dense_prior_UZ p)
    | ZTime => rfl
    | RTime => exact absurd h (not_validIn_rtime_prior_UZ p)
  · rintro rfl
    exact prior_UZ_valid (Formula.atom p)

/--
**`Axiom.z1`'s atomic instance is valid at exactly one frame class: `.ZTime`.**

The `z1` counterpart of `prior_UZ_validIn_iff_ztime`, and with it the `.ZTime` row of
`Axiom.minFrameClass` is characterized rather than merely bounded on both sides.
-/
theorem z1_validIn_iff_ztime (p : Atom) (fc : FrameClass) :
    ValidIn fc (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
      ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture))
      ↔ fc = FrameClass.ZTime := by
  refine ⟨fun h => ?_, ?_⟩
  · cases fc with
    | Base => exact absurd h (not_validIn_base_z1 p)
    | Dense => exact absurd h (not_validIn_dense_z1 p)
    | ZTime => rfl
    | RTime => exact absurd h (not_validIn_rtime_z1 p)
  · rintro rfl
    exact z1_valid (Formula.atom p)

end FormalSystem.Metalogic.Independence
