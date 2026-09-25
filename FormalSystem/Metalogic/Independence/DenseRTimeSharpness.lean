/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Semantics.Correspondence.Indicator
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Independence.CoNotPriorU

/-!
# Sharpness of the `.Dense` and `.RTime` tags of `Axiom.minFrameClass`

`Axiom.minFrameClass` (`FormalSystem/ProofSystem/Axioms.lean`) assigns each axiom constructor the
*smallest* frame class at which that axiom is meant to be valid, and `axiom_validIn_min`
(`FormalSystem/Metalogic/Soundness.lean`) proves the **upper** bound only: every axiom really is
valid at its own tag. Nothing in that theorem rules out the tag having been set too high. The
`.ZTime` row is closed in both directions by `Independence/ZTimeSharpness.lean`; this module
closes three of the four remaining non-`.Base` rows — `Axiom.density` and
`Axiom.dense_indicator`, both tagged `.Dense`, and `Axiom.prior_U_gap`, tagged `.RTime` — and
records a *proved* obstruction for the fourth, `Axiom.sep`.

## What each result claims, exactly

No claim here is stronger than what is written. In particular:

* For the two `.Dense` rows the result is a full **characterization**, not merely minimality:
  `density_validIn_iff` and `dense_indicator_validIn_iff` state `ValidIn fc φ ↔ .Dense ≤ fc`,
  exhausting all four frame classes by `cases fc`. This comes out of the same single refutation
  that minimality needs, because the integer carrier witnesses `.Base` and `.ZTime` at once and
  those are the only two classes not above `.Dense`.
* For the `.RTime` row the result is **minimality only**: `prior_U_gap_minFrameClass_sharp` says
  the axiom is not valid at any class strictly below `.RTime`, i.e. at neither `.Base` nor
  `.Dense`. Nothing is claimed about `.ZTime`, which is incomparable with `.RTime` rather than
  below it; `Axiom.prior_U_gap` looks valid there, but that is a conjecture this module does not
  assert.
* Nothing is claimed about `ℚ` specifically. The `prior_U_gap` refutation happens to run over
  `clockFrame`, whose duration group is `ℚ`, but the statements speak of `.Base` and `.Dense`
  only — the same line `Independence/ZTimeSharpness.lean` deliberately holds for its own carrier.
* The `.Dense` rows are refuted over a *discrete* carrier, `denseSharpOrder := TemporalOrder.of ℤ`
  (via `translationFrame` of `Semantics/Frames/Standard.lean` and the
  `translationHist`/`translationModel`/`translation_realizes` layer of
  `Semantics/Correspondence/DurationFrames.lean`). What does the work in both is the failure of
  `DenselyOrdered`, packaged once as `not_denselyOrdered_of_isLeastPos`: a least positive duration
  is exactly what a densely ordered group cannot have.

## The frame-versus-model obstruction does not bite here

`Independence/CoNotPriorU.lean` records that its own result had to be restated over a *fixed*
`TaskModel`, because frame-validity quantifies over all valuations, and on a densely ordered flow
rich enough to realize an arbitrary set of times, frame-validity of `CO` already forces
gap-freeness and so forces Prior-U valid too. That obstruction arises only where a statement must
*simultaneously validate* something on a valuation-rich flow while refuting something else. A bare
non-validity claim validates nothing and is therefore never obstructed. Every result below is a
bare non-validity claim, so every refutation here is frame-level (`¬ F.ValidOn φ`) — strictly
weaker to assume and strictly stronger to conclude than the model-fixed form, and in the
`prior_U_gap` case it is *derived* from `CoNotPriorU.lean`'s model-fixed
`priorUGapFormula_false` by exhibiting that one model.

## Every statement is at an atomic instance, and that is forced

A schematic `∀ φ` non-validity claim can be outright false: `Axiom.prior_UZ ⊥` has an
unsatisfiable antecedent and *is* valid at `.Base`. Each parametrised result below is therefore
stated at `Formula.atom a`. The shape pins in the next section make formula-transcription
fidelity a compiler obligation: a refutation of a formula that has drifted from its constructor's
is true but vacuous.

## The `sep` row

`Axiom.sep` is **not** closed here. What is proved instead is a boundary:
`not_kPlus_of_isLeastPos` and `sep_validOn_of_isLeastPos` show `Axiom.sep` is vacuously valid on
every frame with a least positive duration, so by `Semantics.duration_dense_or_least_pos` no
discrete witness for it can exist and any refutation must run over a densely ordered duration
group. The section docstring for that pair records the two candidate routes.

## Main results

* `eq_base_of_lt_dense` — `.Base` is the unique frame class strictly below `.Dense`
* `base_or_dense_of_lt_rtime` — `.Base` and `.Dense` are the only classes strictly below `.RTime`
* `not_denselyOrdered_of_isLeastPos`, `not_validOn_density_of_isLeastPos`,
  `not_validOn_dense_indicator_of_isLeastPos` — the generic frame-level machinery, in any
  duration group with a least positive element
* `denseSharpOrder`, `isLeast_one_denseSharpOrder`, `sat_base_denseSharpFrame`,
  `sat_ztime_denseSharpFrame` — the integer carrier and its class memberships
* `not_validIn_base_density`, `not_validIn_ztime_density`, `density_minFrameClass_sharp`,
  `density_validIn_iff`, `not_derivable_base_density` — the `density` row
* `not_validIn_base_dense_indicator`, `not_validIn_ztime_dense_indicator`,
  `dense_indicator_minFrameClass_sharp`, `dense_indicator_validIn_iff`,
  `not_derivable_base_dense_indicator` — the `dense_indicator` row
* `not_validOn_prior_U_gap_clock`, `not_validIn_base_prior_U_gap`,
  `not_validIn_dense_prior_U_gap`, `prior_U_gap_minFrameClass_sharp`,
  `not_derivable_dense_prior_U_gap` — the `prior_U_gap` row
* `not_kPlus_of_isLeastPos`, `sep_validOn_of_isLeastPos` — the proved obstruction for the open
  `sep` row

## Tags

independence · sharpness · minimality · dense · rtime · density · dense_indicator · prior_U_gap
-/

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.Independence

/-! ## Shape pins

Each `example` below type-checks only if the formula this module refutes is *exactly* the one the
matching `Axiom` constructor produces. Without them a mis-transcribed formula would yield a true
but entirely vacuous non-validity result about some other formula.
-/

/-- Shape pin: the formula refuted below is exactly `Axiom.density`'s. -/
example (φ : Formula) : Axiom (φ.allFuture.allFuture.imp φ.allFuture) := Axiom.density φ

/-- Shape pin: the formula refuted below is exactly `Axiom.dense_indicator`'s. -/
example : Axiom (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  Axiom.dense_indicator

/-- Shape pin: the formula refuted below is exactly `Axiom.prior_U_gap`'s. -/
example (φ : Formula) :
    Axiom ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
      (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg)))) := Axiom.prior_U_gap φ

/-! ## Order facts

`by decide` **fails** on `FrameClass` `<`: only `≤` carries a `DecidableRel` instance, so each
strict-order arm routes through `absurd h.le (by decide)`.
-/

/-- `FrameClass.Base` is the unique frame class strictly below `FrameClass.Dense`. -/
theorem eq_base_of_lt_dense {fc : FrameClass} (h : fc < FrameClass.Dense) :
    fc = FrameClass.Base := by
  cases fc with
  | Base => rfl
  | Dense => exact absurd rfl h.ne
  | ZTime => exact absurd h.le (by decide)
  | RTime => exact absurd h.le (by decide)

/-- `FrameClass.Base` and `FrameClass.Dense` are the only frame classes strictly below
`FrameClass.RTime`. -/
theorem base_or_dense_of_lt_rtime {fc : FrameClass} (h : fc < FrameClass.RTime) :
    fc = FrameClass.Base ∨ fc = FrameClass.Dense := by
  cases fc with
  | Base => exact Or.inl rfl
  | Dense => exact Or.inr rfl
  | ZTime => exact absurd h.le (by decide)
  | RTime => exact absurd rfl h.ne

/-! ## Generic machinery -/

/-- A duration group with a least positive element is not densely ordered: density would supply
a point strictly between `0` and that least positive element. -/
theorem not_denselyOrdered_of_isLeastPos {D : TemporalOrder} {p : (D : Type)}
    (hp : IsLeast {x : (D : Type) | 0 < x} p) : ¬ DenselyOrdered (D : Type) := by
  intro h
  obtain ⟨c, h1, h2⟩ := h.dense 0 p hp.1
  exact absurd (hp.2 h1) (not_le.mpr h2)

/-- `Axiom.density`'s atomic instance fails on the translation frame over any duration group with
a least positive element `p`: let the atom hold everywhere except at `p`. Then `GG p` holds at `0`
— every time reachable in two positive steps is at least `2p > p` — while `G p` fails, because `p`
itself is a future time where the atom is false. -/
theorem not_validOn_density_of_isLeastPos (D : TemporalOrder) {p : (D : Type)}
    (hp : IsLeast {x : (D : Type) | 0 < x} p) (a : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) := by
  intro h
  set A : Set (D : Type) := {x | x ≠ p} with hA
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom a).allFuture.allFuture := by
    rw [Truth.future_iff]
    intro s hs
    rw [translation_realizes_allFuture]
    intro r hsr
    exact ne_of_gt (lt_of_le_of_lt (hp.2 hs) hsr)
  exact (translation_realizes_allFuture D A a 0).mp (hval hant) p hp.1 rfl

/-- `Axiom.dense_indicator`'s formula is definitionally `(Formula.next Formula.top).neg`, so
`Semantics.validOn_neg_nextTop_iff` turns its frame-validity into `DenselyOrdered` of the duration
group — which `not_denselyOrdered_of_isLeastPos` refutes. -/
theorem not_validOn_dense_indicator_of_isLeastPos (D : TemporalOrder) {p : (D : Type)}
    (hp : IsLeast {x : (D : Type) | 0 < x} p) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun h => not_denselyOrdered_of_isLeastPos hp
    ((validOn_neg_nextTop_iff (translationFrame D).toTaskFrame).mp h)

/-! ## The integer carrier

`ℤ` is the cheapest carrier that witnesses `.Base` and `.ZTime` simultaneously, which is exactly
what the two `.Dense` characterizations need: `.Base` and `.ZTime` are the only frame classes not
above `.Dense`.
-/

/-- The integer duration order, carrier for both `.Dense`-row refutations. -/
noncomputable abbrev denseSharpOrder : TemporalOrder := TemporalOrder.of ℤ

/-- `1` is the least positive integer duration. -/
theorem isLeast_one_denseSharpOrder : IsLeast {x : (denseSharpOrder : Type) | 0 < x} 1 :=
  ⟨show (0 : ℤ) < 1 by omega, fun _ (hx : (0 : ℤ) < _) => show (1 : ℤ) ≤ _ by omega⟩

/-- The integer translation frame is a `.Base` frame. -/
theorem sat_base_denseSharpFrame :
    FrameClass.Sat FrameClass.Base (translationFrame denseSharpOrder).toTaskFrame :=
  inferInstance

/-- The integer translation frame is a `.ZTime` frame. `IsZTime` is a nested four-component
existential, so the second component goes through `TaskFrame.isZTime_of_instances` rather than a
bare `constructor`. -/
theorem sat_ztime_denseSharpFrame :
    FrameClass.Sat FrameClass.ZTime (translationFrame denseSharpOrder).toTaskFrame :=
  ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩

/-! ## Row 1: density -/

/-- `Axiom.density`'s atomic instance is not valid at `FrameClass.Base`. -/
theorem not_validIn_base_density (a : Atom) :
    ¬ ValidIn FrameClass.Base
      ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) :=
  fun h => not_validOn_density_of_isLeastPos denseSharpOrder isLeast_one_denseSharpOrder a
    (h _ sat_base_denseSharpFrame)

/-- `Axiom.density`'s atomic instance is not valid at `FrameClass.ZTime`, which is incomparable
with `FrameClass.Dense` rather than below it. -/
theorem not_validIn_ztime_density (a : Atom) :
    ¬ ValidIn FrameClass.ZTime
      ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) :=
  fun h => not_validOn_density_of_isLeastPos denseSharpOrder isLeast_one_denseSharpOrder a
    (h _ sat_ztime_denseSharpFrame)

/-- Minimality of `Axiom.density`'s `.Dense` tag: its atomic instance is not valid at any frame
class strictly below `FrameClass.Dense`. -/
theorem density_minFrameClass_sharp (a : Atom) {fc : FrameClass} (hfc : fc < FrameClass.Dense) :
    ¬ ValidIn fc ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) :=
  eq_base_of_lt_dense hfc ▸ not_validIn_base_density a

/-- The full characterization for the `density` row: its atomic instance is valid at `fc` exactly
when `fc` is at least `FrameClass.Dense`. -/
theorem density_validIn_iff (a : Atom) (fc : FrameClass) :
    ValidIn fc ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture)
      ↔ FrameClass.Dense ≤ fc := by
  refine ⟨fun h => ?_, fun h => ValidIn.mono h (density_valid (Formula.atom a))⟩
  cases fc with
  | Base => exact absurd h (not_validIn_base_density a)
  | Dense => exact le_refl _
  | ZTime => exact absurd h (not_validIn_ztime_density a)
  | RTime => exact (by decide : FrameClass.Dense ≤ FrameClass.RTime)

/-- Underivability corollary through soundness: `Axiom.density`'s atomic instance is not derivable
in the `.Base` system. -/
theorem not_derivable_base_density (a : Atom) :
    ¬ Derivable FrameClass.Base []
      ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) :=
  fun ⟨d⟩ => not_validIn_base_density a (soundness_validIn d)

/-! ## Row 2: dense_indicator -/

/-- `Axiom.dense_indicator` is not valid at `FrameClass.Base`. -/
theorem not_validIn_base_dense_indicator :
    ¬ ValidIn FrameClass.Base (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun h => not_validOn_dense_indicator_of_isLeastPos denseSharpOrder
    isLeast_one_denseSharpOrder (h _ sat_base_denseSharpFrame)

/-- `Axiom.dense_indicator` is not valid at `FrameClass.ZTime`, which is incomparable with
`FrameClass.Dense` rather than below it. -/
theorem not_validIn_ztime_dense_indicator :
    ¬ ValidIn FrameClass.ZTime (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun h => not_validOn_dense_indicator_of_isLeastPos denseSharpOrder
    isLeast_one_denseSharpOrder (h _ sat_ztime_denseSharpFrame)

/-- Minimality of `Axiom.dense_indicator`'s `.Dense` tag: it is not valid at any frame class
strictly below `FrameClass.Dense`. -/
theorem dense_indicator_minFrameClass_sharp {fc : FrameClass} (hfc : fc < FrameClass.Dense) :
    ¬ ValidIn fc (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  eq_base_of_lt_dense hfc ▸ not_validIn_base_dense_indicator

/-- The full characterization for the `dense_indicator` row: it is valid at `fc` exactly when `fc`
is at least `FrameClass.Dense`. -/
theorem dense_indicator_validIn_iff (fc : FrameClass) :
    ValidIn fc (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg
      ↔ FrameClass.Dense ≤ fc := by
  refine ⟨fun h => ?_, fun h => ValidIn.mono h dense_indicator_valid⟩
  cases fc with
  | Base => exact absurd h not_validIn_base_dense_indicator
  | Dense => exact le_refl _
  | ZTime => exact absurd h not_validIn_ztime_dense_indicator
  | RTime => exact (by decide : FrameClass.Dense ≤ FrameClass.RTime)

/-- Underivability corollary through soundness: `Axiom.dense_indicator` is not derivable in the
`.Base` system. -/
theorem not_derivable_base_dense_indicator :
    ¬ Derivable FrameClass.Base []
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun ⟨d⟩ => not_validIn_base_dense_indicator (soundness_validIn d)

/-! ## Row 3: prior_U_gap

One refutation covers both classes strictly below `.RTime`. `clockFrame`
(`Independence/ClockFrame.lean`) is densely ordered, so it witnesses `.Dense`, and every `.Dense`
frame is a `.Base` frame. This is the frame-level extraction from `CoNotPriorU.lean`'s
model-fixed `priorUGapFormula_false`: exhibiting that one model refutes `ValidOn`, and the
frame-versus-model obstruction recorded there does not apply because a bare non-validity claim
validates nothing.
-/

/-- `Axiom.prior_U_gap`'s atomic instance fails on the clock frame, by exhibiting
`CoNotPriorU.lean`'s `clockModel` at `clockHistory`, time `0`. -/
theorem not_validOn_prior_U_gap_clock (a : Atom) :
    ¬ clockFrame.toTaskFrame.ValidOn (priorUGapFormula (Formula.atom a)) :=
  fun h => priorUGapFormula_false a (h clockModel clockHistory 0)

/-- `Axiom.prior_U_gap`'s atomic instance is not valid at `FrameClass.Dense`. -/
theorem not_validIn_dense_prior_U_gap (a : Atom) :
    ¬ ValidIn FrameClass.Dense (priorUGapFormula (Formula.atom a)) :=
  fun h => not_validOn_prior_U_gap_clock a
    (h clockFrame.toTaskFrame ⟨inferInstance, inferInstance⟩)

/-- `Axiom.prior_U_gap`'s atomic instance is not valid at `FrameClass.Base`. -/
theorem not_validIn_base_prior_U_gap (a : Atom) :
    ¬ ValidIn FrameClass.Base (priorUGapFormula (Formula.atom a)) :=
  fun h => not_validOn_prior_U_gap_clock a (h clockFrame.toTaskFrame inferInstance)

/-- Minimality of `Axiom.prior_U_gap`'s `.RTime` tag: its atomic instance is not valid at any
frame class strictly below `FrameClass.RTime`. No claim is made about `FrameClass.ZTime`, which is
incomparable with `.RTime` rather than below it. -/
theorem prior_U_gap_minFrameClass_sharp (a : Atom) {fc : FrameClass}
    (hfc : fc < FrameClass.RTime) : ¬ ValidIn fc (priorUGapFormula (Formula.atom a)) := by
  rcases base_or_dense_of_lt_rtime hfc with rfl | rfl
  · exact not_validIn_base_prior_U_gap a
  · exact not_validIn_dense_prior_U_gap a

/-- Underivability corollary through soundness: `Axiom.prior_U_gap`'s atomic instance is not
derivable in the `.Dense` system. -/
theorem not_derivable_dense_prior_U_gap (a : Atom) :
    ¬ Derivable FrameClass.Dense [] (priorUGapFormula (Formula.atom a)) :=
  fun ⟨d⟩ => not_validIn_dense_prior_U_gap a (soundness_validIn d)

/-! ## Row 4: sep — the obstruction, not the refutation

`Axiom.sep`'s `.RTime` tag is **not** shown minimal here. What is shown is a boundary that fixes
where a refutation could possibly live.

`not_kPlus_of_isLeastPos` and `sep_validOn_of_isLeastPos` together establish that `Axiom.sep` is
*vacuously* valid on every frame whose duration group has a least positive element: on such a
frame `K⁺ψ` is false everywhere, because the immediate successor `t + p` leaves the open interval
`(t, t + p)` empty, so `sep`'s antecedent's first conjunct `K⁺φ` never holds. Combined with
`Semantics.duration_dense_or_least_pos` — every duration group is either densely ordered or has a
least positive element — this says **no discrete witness for `sep` can exist**. Any `.Base`
refutation must therefore run over a densely ordered duration group; and since `Sat .Dense F`
implies `Sat .Base F`, one dense witness would close both classes strictly below `.RTime` at
once, exactly the pattern `not_validIn_dense_prior_U_gap` follows for the `prior_U_gap` row.

Three candidate routes were surveyed, none attempted here:

1. The lexicographic configuration already written down in
   `Metalogic/SoundnessLemmas/Separability.lean` (`t = (0,1)` on the lex square, φ-region
   `{(a, 0) : 0 < a < 1}`) does **not** transfer as-is. A *group* has no fibre tops, so the
   antecedent collapses the problem back to the separable one-level case; the value group must
   itself be densely ordered.
2. The witness that does appear to work is `D = Lex (ℚ →₀ ℚ)` with φ-region
   `{toLex (Finsupp.single γ 1) : γ > 0}`. Its carrier instances were probed and are available
   except for `IsOrderedAddMonoid`, which is a short instance off Mathlib's
   `Finsupp.Lex.addLeftMono` / `Finsupp.Lex.addRightMono`.
3. An independent plain-`ℚ` route via a bespoke Cantor set, exploiting completeness rather than
   separability.
-/

/-- On a frame whose durations have a least positive element `p`, `K⁺φ` is false everywhere: the
immediate successor `t + p` makes the open interval `(t, t + p)` empty, so no witness to `K⁺` can
be found. -/
theorem not_kPlus_of_isLeastPos {F : TaskFrame} {p : F.Duration}
    (hp : IsLeast {x : F.Duration | 0 < x} p) (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : Formula) : ¬ TruthAt M τ t (Formula.kPlus φ) := by
  intro h
  refine h ⟨t + p, lt_add_of_pos_right t hp.1, fun hb => hb, ?_⟩
  intro r htr hrp
  exfalso
  have h1 : 0 < r - t := sub_pos.mpr htr
  have h2 : p ≤ r - t := hp.2 h1
  have : t + p ≤ r := by
    have := le_sub_iff_add_le.mp h2
    rwa [add_comm] at this
  exact absurd hrp (not_lt.mpr this)

/-- `Axiom.sep` is valid — vacuously — on every frame whose durations have a least positive
element: its antecedent's first conjunct `K⁺φ` fails everywhere there by
`not_kPlus_of_isLeastPos`. This is the proved obstruction to a discrete refutation of the `sep`
row. -/
theorem sep_validOn_of_isLeastPos {F : TaskFrame} {p : F.Duration}
    (hp : IsLeast {x : F.Duration | 0 < x} p) (φ : Formula) :
    F.ValidOn ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  intro M τ t hant
  exact absurd ((Truth.and_iff _ _).mp hant).1 (not_kPlus_of_isLeastPos hp M τ t φ)

end FormalSystem.Metalogic.Independence
