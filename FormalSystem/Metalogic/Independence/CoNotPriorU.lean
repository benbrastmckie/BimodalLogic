/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.LoopingDuration
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Metalogic.Soundness
import Mathlib.NumberTheory.Real.Irrational
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# `CO` does not derive Prior-U

The paper's `CO` principle (`Formula.co`, `△(Hφ → F(Hφ)) → (Hφ → Gφ)`) is a *theorem* over the
Reynolds Dedekind triple — that direction is `FormalSystem.Theorems.DedekindDerived.co_derived`.
This file establishes the converse **failure**: over the dense base, `CO` does not derive
`Axiom.prior_U_gap`.

## The witness

The countermodel is the periodic clock frame of `ClockFrame.lean` carrying the *symmetric
irrational arc* valuation: an atom is true at a circle point exactly when that point has a
representative within `α := √2 / 4` of `0`. Since `α` is irrational and `0 < α < 1/2`, the arc has
no rational endpoint, and `Axiom.prior_U_gap` — which asserts that a `φ`-region reached from the
present has a *definable* upper endpoint — fails at time `0` along the reference history. Every
`CO` instance is nonetheless true everywhere, by `LoopingDuration.lean`'s Lemma C.

## Why this is a statement about a model, not a frame

`def:frame-validity` quantifies over **all** valuations. On a densely ordered flow rich enough to
realize an arbitrary set of times, frame-validity of `CO` already forces gap-freeness, and hence
forces Prior-U valid too — so no frame-level countermodel can exist, for any frame whatever. The
theorem therefore has to be stated over a **fixed** `TaskModel`, which is exactly the shape of
Reynolds' own printed caveat (1992, p.169): the gap axioms enforce only a *definably*
Dedekind-complete flow, "there may be gaps in the order but ... you wouldn't know that just
looking at the behaviour of temporal formulas".

## Pre-empting the "degenerate model" objection

The clock model validates `Hψ → Gψ`, which the intended reading of the logic does not. That is
expected of an independence witness and does not weaken the result: the underlying frame
discharges all four of `def:frame`'s axioms (see `ClockFrame.lean`), `ℚ` is densely ordered, and
therefore every base and density axiom is true in this model for free by `soundness_dense`. The
only principle assumed beyond the dense base is `CO` itself.

## The refuted predecessor sketch

An earlier pen-and-paper sketch (recorded in `Axioms.lean`'s Layer 9 and corrected there) proposed
a ℚ-flow with isolated `¬φ` points accumulating at an irrational from above. That witness is
**refuted**, not merely unverified: in it, `ξ := ¬U(¬p, p) ∧ F(U(¬p, p))` has truth set
`{t : t < √2}`, so `ξ` *defines the cut* and `CO(ξ)` is false at `0`. Hiding an accumulation point
does not work — some `U`/`S` formula always recovers the cut. What works instead is
**homogeneity**: the clock frame's time translation by `1` fixes every world state, so no formula
can see a distinguished time at all.
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.ProofSystem

/-! ## The irrational radius -/

/-- The arc's radius: `√2 / 4`, irrational and strictly between `1/4` and `1/2`. -/
noncomputable def arcRadius : ℝ := Real.sqrt 2 / 4

theorem arcRadius_pos : 0 < arcRadius := by
  have h : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  unfold arcRadius; linarith

theorem arcRadius_lt_half : arcRadius < 1 / 2 := by
  have h : Real.sqrt 2 < 2 := by
    have h2 : Real.sqrt 2 < Real.sqrt 4 := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    rwa [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 2)] at h2
  unfold arcRadius; linarith

theorem quarter_lt_arcRadius : (1 / 4 : ℝ) < arcRadius := by
  have h : (1 : ℝ) < Real.sqrt 2 := by
    have h1 : Real.sqrt 1 < Real.sqrt 2 := by apply Real.sqrt_lt_sqrt <;> norm_num
    rwa [Real.sqrt_one] at h1
  unfold arcRadius; linarith

theorem arcRadius_irrational : Irrational arcRadius := by
  have h2 : Irrational (Real.sqrt 2 / (4 : ℕ)) :=
    Irrational.div_natCast irrational_sqrt_two (by norm_num)
  simpa [arcRadius] using h2

/-- No rational hits the arc's endpoint. This is what stops the `φ`-region from having a
definable upper endpoint, and it is the whole content of the countermodel. -/
theorem rat_ne_arcRadius (q : ℚ) : (q : ℝ) ≠ arcRadius := fun h => arcRadius_irrational ⟨q, h⟩

/-! ## The arc model -/

/--
The arc: circle points with a representative of absolute value below `arcRadius`.

Stated as an existential over representatives rather than through `Quotient.lift`, so that
well-definedness on the quotient holds by construction and no lifting obligation arises.
-/
def OnArc (w : ClockState) : Prop := ∃ q : ℚ, cmk q = w ∧ |(q : ℝ)| < arcRadius

/--
**The countermodel.** The clock frame with the symmetric arc valuation.

The valuation ignores the atom: every atom is true exactly on the arc. That is deliberate — the
refutation needs only one atom, and a uniform valuation keeps the model manifestly symmetric under
`w ↦ -w`, which is what the `temporal_duality` closure below consumes.
-/
def clockModel : TaskModel clockFrame where
  valuation := fun w _ => OnArc w

/-- The set of *times* at which atoms are true along the reference history: the union of the
open intervals `(n - α, n + α)` over the integers. -/
def ArcTime (t : ℚ) : Prop := ∃ n : ℤ, |(t : ℝ) - (n : ℝ)| < arcRadius

/-- The arc characterization along `clockHistory`. -/
@[simp] theorem clock_atom_truth (a : Atom) (t : ℚ) :
    TruthAt clockModel clockHistory t (Formula.atom a) ↔ ArcTime t := by
  constructor
  · rintro ⟨_, hq⟩
    obtain ⟨q, hqe, hqlt⟩ := hq
    obtain ⟨n, hn⟩ := (cmk_eq_cmk_iff q t).mp hqe
    refine ⟨-n, ?_⟩
    have hcast : (q : ℝ) - (t : ℝ) = ((n : ℤ) : ℝ) := by exact_mod_cast hn
    have heq : (t : ℝ) - ((-n : ℤ) : ℝ) = (q : ℝ) := by push_cast at hcast ⊢; linarith
    rw [heq]
    exact hqlt
  · rintro ⟨n, hn⟩
    refine ⟨trivial, ?_⟩
    show OnArc (cmk t)
    refine ⟨t - (n : ℚ), ?_, ?_⟩
    · rw [cmk_eq_cmk_iff]
      exact ⟨-n, by push_cast; ring⟩
    · have hc : ((t - (n : ℚ) : ℚ) : ℝ) = (t : ℝ) - ((n : ℤ) : ℝ) := by push_cast; ring
      rwa [hc]

/-- Everything within `arcRadius` of `0` is on the arc. -/
theorem arcTime_of_abs_lt (t : ℚ) (h : |(t : ℝ)| < arcRadius) : ArcTime t :=
  ⟨0, by simpa using h⟩

/-- The gap between consecutive arcs: nothing strictly between `α` and `1 - α` is on the arc. -/
theorem not_arcTime_of_mem_gap (r : ℚ) (h1 : arcRadius < (r : ℝ))
    (h2 : (r : ℝ) < 1 - arcRadius) : ¬ ArcTime r := by
  rintro ⟨n, hn⟩
  rcases le_or_gt n 0 with hle | hgt
  · have hn0 : ((n : ℤ) : ℝ) ≤ 0 := by exact_mod_cast hle
    have : arcRadius < (r : ℝ) - ((n : ℤ) : ℝ) := by linarith
    have habs : (r : ℝ) - ((n : ℤ) : ℝ) ≤ |(r : ℝ) - ((n : ℤ) : ℝ)| := le_abs_self _
    linarith
  · have hn1 : (1 : ℝ) ≤ ((n : ℤ) : ℝ) := by exact_mod_cast hgt
    have : arcRadius < ((n : ℤ) : ℝ) - (r : ℝ) := by linarith
    have habs : ((n : ℤ) : ℝ) - (r : ℝ) ≤ |(r : ℝ) - ((n : ℤ) : ℝ)| := by
      rw [abs_sub_comm]; exact le_abs_self _
    linarith

/-- The antipode `1/2` is off the arc: it is the farthest point from every integer. -/
theorem not_arcTime_half : ¬ ArcTime (1 / 2 : ℚ) := by
  refine not_arcTime_of_mem_gap (1 / 2 : ℚ) ?_ ?_
  · have := arcRadius_lt_half; push_cast; linarith
  · have := arcRadius_lt_half; push_cast; linarith

/-! ## Truth of the derived connectives

`Formula.and`, `Formula.or` and `Formula.top` are abbreviations over `imp`/`bot`; the semantics
module carries no characterization theorems for them, so the three needed here are proved locally.
-/

section Connectives

variable {D : TemporalOrder}
  {F : FrameOver D} {M : TaskModel F} {τ : WorldHistory F} {t : ↑D}

/-- `⊤` is true everywhere. -/
theorem truth_top : TruthAt M τ t Formula.top := fun h => h

/-- `φ ∨ ψ` is true iff one disjunct is. -/
theorem truth_or_iff (A B : Formula) :
    TruthAt M τ t (Formula.or A B) ↔ (TruthAt M τ t A ∨ TruthAt M τ t B) := by
  constructor
  · intro h
    by_cases hA : TruthAt M τ t A
    · exact Or.inl hA
    · exact Or.inr (h hA)
  · rintro (ha | hb) hna
    · exact absurd ha hna
    · exact hb

end Connectives

/-! ## The Prior-U gap formula -/

/--
`Axiom.prior_U_gap φ`'s formula, transcribed from `FormalSystem/ProofSystem/Axioms.lean`
character-for-character:
`(U(⊤, φ) ∧ F(¬φ)) → U(¬φ ∨ K⁺(¬φ), φ)`.
-/
def priorUGapFormula (φ : Formula) : Formula :=
  (Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
    (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg)))

/-- The transcription **is** the axiom's formula: `Axiom.prior_U_gap` elaborates at it directly,
which is the acceptance test for the transcription being character-for-character. -/
def priorUGapFormula_isAxiom (φ : Formula) : Axiom (priorUGapFormula φ) := Axiom.prior_U_gap φ

/-! ## The three membership facts -/

/-- **Membership fact 1**: `U(⊤, p)` holds at time `0` — witness `s = 1/4`, which is inside the
arc because `1/4 < α`. -/
theorem untl_top_atom_true (a : Atom) :
    TruthAt clockModel clockHistory 0 (Formula.untl (Formula.atom a) Formula.top) := by
  refine ⟨1 / 4, by norm_num, truth_top, ?_⟩
  intro r hr1 hr2
  rw [clock_atom_truth]
  refine arcTime_of_abs_lt r ?_
  have hr1' : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr1
  have hr2' : (r : ℝ) < ((1 / 4 : ℚ) : ℝ) := by exact_mod_cast hr2
  push_cast at hr2'
  rw [abs_of_pos hr1']
  linarith [quarter_lt_arcRadius]

/-- **Membership fact 2**: `F(¬p)` holds at time `0` — witness `s = 1/2`, the antipode. -/
theorem someFuture_neg_atom_true (a : Atom) :
    TruthAt clockModel clockHistory 0 (Formula.atom a).neg.someFuture := by
  refine ⟨1 / 2, by norm_num, ?_, fun _ _ _ => truth_top⟩
  intro hp
  exact not_arcTime_half ((clock_atom_truth a (1 / 2)).mp hp)

/-- The antecedent of `Axiom.prior_U_gap p` holds at time `0`. -/
theorem priorUGap_antecedent_true (a : Atom) :
    TruthAt clockModel clockHistory 0
      (Formula.and (Formula.untl (Formula.atom a) Formula.top)
        (Formula.atom a).neg.someFuture) :=
  (Truth.and_iff _ _).mpr ⟨untl_top_atom_true a, someFuture_neg_atom_true a⟩

/--
**Membership fact 3** — the substantive one: the consequent `U(¬p ∨ K⁺(¬p), p)` fails at `0`.

No rational `s > 0` can serve as a witness. If `s` overshoots the arc (`α < s`) then density of ℚ
puts a rational in the gap `(α, 1 - α)` below `s`, where `p` is false, so the guard fails. If `s`
falls short (`s < α` — equality is impossible, `α` being irrational) then `p` is true at `s`, so
`¬p` fails there, and any rational in `(s, α)` witnesses `U(⊤, ¬¬p)` at `s`, so `K⁺(¬p)` fails
there too; the event disjunction is therefore false at `s`.
-/
theorem priorUGap_consequent_false (a : Atom) :
    ¬ TruthAt clockModel clockHistory 0
      (Formula.untl (Formula.atom a)
        (Formula.or (Formula.atom a).neg (Formula.kPlus (Formula.atom a).neg))) := by
  rintro ⟨s, hs, hev, hg⟩
  have hs' : (0 : ℝ) < (s : ℝ) := by exact_mod_cast hs
  by_cases hcase : arcRadius < (s : ℝ)
  · -- The guard fails: a rational in the gap sits strictly between `0` and `s`.
    have hlt : arcRadius < min (s : ℝ) (1 - arcRadius) :=
      lt_min hcase (by linarith [arcRadius_lt_half])
    obtain ⟨r, hr1, hr2⟩ := exists_rat_btwn hlt
    have hrs : (r : ℝ) < (s : ℝ) := lt_of_lt_of_le hr2 (min_le_left _ _)
    have hrgap : (r : ℝ) < 1 - arcRadius := lt_of_lt_of_le hr2 (min_le_right _ _)
    have hr0 : (0 : ℝ) < (r : ℝ) := lt_trans arcRadius_pos hr1
    have hguard := hg r (by exact_mod_cast hr0) (by exact_mod_cast hrs)
    exact not_arcTime_of_mem_gap r hr1 hrgap ((clock_atom_truth a r).mp hguard)
  · -- The event fails: `p` holds at `s`, and `K⁺(¬p)` is refuted by a rational in `(s, α)`.
    have hslt : (s : ℝ) < arcRadius :=
      lt_of_le_of_ne (not_lt.mp hcase) (rat_ne_arcRadius s)
    have hp_s : TruthAt clockModel clockHistory s (Formula.atom a) := by
      rw [clock_atom_truth]
      refine arcTime_of_abs_lt s ?_
      rw [abs_of_pos hs']
      exact hslt
    rcases (truth_or_iff _ _).mp hev with hneg | hk
    · exact hneg hp_s
    · -- `K⁺(¬p) = ¬U(⊤, ¬¬p)`; a rational `u ∈ (s, α)` supplies the refuting witness.
      obtain ⟨u, hu1, hu2⟩ := exists_rat_btwn hslt
      refine hk ⟨u, by exact_mod_cast hu1, truth_top, ?_⟩
      intro r hr1 hr2
      have hr0 : (0 : ℝ) < (r : ℝ) := lt_trans hs' (by exact_mod_cast hr1)
      have hru : (r : ℝ) < arcRadius := lt_trans (by exact_mod_cast hr2) hu2
      have hpr : TruthAt clockModel clockHistory r (Formula.atom a) := by
        rw [clock_atom_truth]
        refine arcTime_of_abs_lt r ?_
        rw [abs_of_pos hr0]
        exact hru
      exact fun hn => hn hpr

/--
**The refutation.** `Axiom.prior_U_gap p` is false at time `0` of the arc model.

Every `CO` instance is true in this same model (`clock_co_true`), which is what makes the pair an
independence witness.
-/
theorem priorUGapFormula_false (a : Atom) :
    ¬ TruthAt clockModel clockHistory 0 (priorUGapFormula (Formula.atom a)) :=
  fun h => priorUGap_consequent_false a (h (priorUGap_antecedent_true a))

/-! ## Statement S1 — the context form -/

/--
**`CO` does not derive Prior-U (context form).**

Over the dense base, no context of `CO` instances derives `Axiom.prior_U_gap p`. Since a context
is a finite list and every derivation is finite, this already says: *no finite set of `CO`
instances, together with the dense base, derives Prior-U.*

**What is and is not claimed.**

* Claimed: `FrameClass.Dense`'s axioms plus finitely many `CO` instances as assumptions do not
  derive `priorUGapFormula p`. The witness is `clockModel` at `clockHistory`, time `0`.
* Also claimed, and strictly stronger: the schema-level statement
  `co_not_derives_prior_U_gap_schema` below, which closes the gap left by this one — a context
  cannot appear under `necessitation`, `temporal_necessitation` or `temporal_duality`, since
  `DerivationTree`'s rule constructors are restricted to the empty context.
* **Not** claimed, and in fact false: any *frame*-level statement. `def:frame-validity`
  quantifies over all valuations, and under that quantifier frame-validity of `CO` on a dense
  flow forces gap-freeness and hence Prior-U. See this module's docstring.
-/
theorem co_not_derives_prior_U_gap (a : Atom) (Γ : Context)
    (hΓ : ∀ ψ ∈ Γ, ∃ χ, ψ = Formula.co χ) :
    ¬ Derivable FrameClass.Dense Γ (priorUGapFormula (Formula.atom a)) := by
  rintro ⟨d⟩
  refine priorUGapFormula_false a ?_
  refine soundness_dense Γ _ d clockFrame clockModel clockHistory clockHistory_isTotal 0 ?_
  intro ψ hψ
  obtain ⟨χ, rfl⟩ := hΓ ψ hψ
  exact clock_co_true clockModel χ clockHistory clockHistory_isTotal 0

/-! ## The time-reversal mirror

`temporal_duality` (`⊢ φ` gives `⊢ φ.swapTemporal`) is the one closure rule whose soundness over a
*fixed* model is not automatic: it needs the model to be isomorphic to its own time reversal. The
clock model is, and that is precisely why the arc was centred at `0`: negation `w ↦ -w` is an
automorphism of the circle that preserves the arc and reverses durations. An asymmetric arc would
break this, and must not be substituted.
-/

/-- Transporting a history's state assignment along an equality of times. -/
theorem states_congr {D : TemporalOrder}
    {F : FrameOver D} {τ : WorldHistory F} {a b : ↑D} (h : a = b)
    (ha : τ.domain a) (hb : τ.domain b) : τ.states a ha = τ.states b hb := by
  subst h; rfl

/--
Negation on the clock's world states.

A named wrapper rather than bare `-`: `clockFrame.WorldState` does not elaborate as `ClockState`
when it appears as the type of a history's state, so the group operation is not directly
available there, whereas an application of this function unifies by definitional unfolding.
-/
def cneg (w : ClockState) : ClockState := -w

@[simp] theorem cneg_cneg (w : ClockState) : cneg (cneg w) = w := neg_neg w

/-- The arc is symmetric about `0`, so negation preserves the valuation. -/
theorem onArc_neg (w : ClockState) : OnArc (cneg w) ↔ OnArc w := by
  show OnArc (-w) ↔ OnArc w
  constructor
  · rintro ⟨q, hq, hlt⟩
    refine ⟨-q, ?_, ?_⟩
    · rw [cmk_neg, hq, neg_neg]
    · push_cast; rwa [abs_neg]
  · rintro ⟨q, hq, hlt⟩
    refine ⟨-q, ?_, ?_⟩
    · rw [cmk_neg, hq]
    · push_cast; rwa [abs_neg]

/-- Negation on the circle reverses durations: it is an automorphism of the clock relation. -/
theorem clockRel_neg {a b : ClockState} {d : ℚ} (h : clockRel a d b) :
    clockRel (cneg a) (-d) (cneg b) := by
  show cneg b = cneg a + cmk (-d)
  have hb : b = a + cmk d := h
  simp only [cneg, hb, cmk_neg]
  abel

theorem reflect_respects (τ : WorldHistory clockFrame) (hτ : τ.IsTotal) (s t : ℚ) :
    clockRel (cneg (τ.states (-s) (hτ (-s)))) (t - s) (cneg (τ.states (-t) (hτ (-t)))) := by
  have h2 := clockRel_neg (a := τ.states (-s) (hτ (-s))) (b := τ.states (-t) (hτ (-t)))
    (d := -t - -s) (τ.respects_task (-s) (-t) (hτ (-s)) (hτ (-t)))
  have he : -(-t - -s) = t - s := by ring
  rwa [he] at h2

/--
The **time reversal** of a total history: `t ↦ -τ(-t)`.

It is again a history of the clock frame — negation on `ℚ ⧸ ℤ` reverses durations, so
task-respect at `(-s, -t)` becomes task-respect at `(s, t)`.
-/
def reflect (τ : WorldHistory clockFrame) (hτ : τ.IsTotal) : WorldHistory clockFrame where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => cneg (τ.states (-t) (hτ (-t)))
  respects_task := fun s t _ _ => reflect_respects τ hτ s t
  convex := by intro _ _ _ _ _ _ _; trivial

theorem reflect_isTotal (τ : WorldHistory clockFrame) (hτ : τ.IsTotal) :
    (reflect τ hτ).IsTotal := fun _ => trivial

/-- Reflecting twice is the identity on total histories: `-(-t) = t` in the times and
`cneg (cneg w) = w` in the states. This is what makes `reflect` an **equivalence** on `H_F`
rather than merely a map, which is what `TruthAntiIso.hist` requires. -/
private theorem reflect_reflect (τ : clockFrame.HF) :
    reflect (reflect τ.val τ.property) (reflect_isTotal _ _) = τ.val := by
  refine ShiftSet.wh_ext
    (funext fun z => propext ⟨fun _ => τ.property z, fun _ => trivial⟩) ?_
  intro r _ h'
  show cneg (cneg (τ.val.states (-(-r)) (τ.property (-(-r))))) = τ.val.states r h'
  exact (cneg_cneg _).trans
    (WorldHistory.states_eq_of_time_eq τ.val (-(-r)) r (neg_neg r) _ h')

/-- Time reversal as an involutive equivalence of `H_clockFrame`. -/
noncomputable def clockReflectEquiv : clockFrame.HF ≃ clockFrame.HF where
  toFun := fun τ => ⟨reflect τ.val τ.property, reflect_isTotal _ _⟩
  invFun := fun τ => ⟨reflect τ.val τ.property, reflect_isTotal _ _⟩
  left_inv := fun τ => Subtype.ext (reflect_reflect τ)
  right_inv := fun τ => Subtype.ext (reflect_reflect τ)

/--
**The clock frame's time-reversal anti-isomorphism.**

`dur` is negation on `ℚ` — order-reversing, which is exactly what `TruthAntiIso` asks for and
what `TruthIso` cannot express — `hist` is `clockReflectEquiv`, and `atom` is `onArc_neg`: the
arc valuation is symmetric under `w ↦ -w`, which is the whole reason this countermodel was built
with a uniform valuation.
-/
noncomputable def clockMirrorIso : TruthAntiIso clockModel clockModel where
  dur := Equiv.neg ℚ
  dur_rev := fun _ _ => neg_lt_neg_iff
  hist := clockReflectEquiv
  atom := by
    intro τ t _
    have hstates : τ.val.states (-(-t)) (τ.property (-(-t))) = τ.val.states t (τ.property t) :=
      WorldHistory.states_eq_of_time_eq τ.val (-(-t)) t (neg_neg t) _ _
    show OnArc (τ.val.states t (τ.property t)) ↔
      OnArc (cneg (τ.val.states (-(-t)) (τ.property (-(-t)))))
    calc OnArc (τ.val.states t (τ.property t))
        ↔ OnArc (τ.val.states (-(-t)) (τ.property (-(-t)))) := by rw [hstates]
      _ ↔ OnArc (cneg (τ.val.states (-(-t)) (τ.property (-(-t))))) := (onArc_neg _).symm

/--
**The mirror lemma.** If `σ` is the time reversal of `τ` — pointwise, `σ(-x) = -τ(x)` — then `σ`
at `-t` satisfies `φ.swapTemporal` exactly when `τ` at `t` satisfies `φ`.

An instantiation of `Truth.truthAt_of_truthAntiIso` at `clockMirrorIso`, replacing the 80-line
hand-written six-case induction this used to carry. The statement is unchanged, relational form
included: it still quantifies over a *pair* of histories tied by the reversal equation rather
than over `reflect` alone. Collapsing the pair to `reflect` is now one extensionality step,
where before it was what made the `□` case work in both directions — that job has moved into
`TruthAntiIso.hist` being an honest equivalence.
-/
theorem truthAt_mirror (φ : Formula) :
    ∀ (τ σ : WorldHistory clockFrame) (hτ : τ.IsTotal) (hσ : σ.IsTotal),
      (∀ x : ℚ, σ.states (-x) (hσ (-x)) = cneg (τ.states x (hτ x))) →
      ∀ t : ℚ, (TruthAt clockModel σ (-t) φ.swapTemporal ↔ TruthAt clockModel τ t φ) := by
  intro τ σ hτ hσ hrel t
  have hσeq : σ = reflect τ hτ := by
    refine ShiftSet.wh_ext (funext fun z => propext ⟨fun _ => trivial, fun _ => hσ z⟩) ?_
    intro r h _
    show σ.states r h = cneg (τ.states (-r) (hτ (-r)))
    have hx := hrel (-r)
    rw [neg_neg] at hx
    exact hx
  subst hσeq
  exact (Truth.truthAt_of_truthAntiIso clockMirrorIso φ ⟨τ, hτ⟩ t).symm

/--
The form `temporal_duality` consumes: a formula true at every total history and every time of the
clock model has a temporal dual with the same property.
-/
theorem truthAt_swapTemporal (φ : Formula)
    (h : ∀ (σ : WorldHistory clockFrame), σ.IsTotal → ∀ t : ℚ, TruthAt clockModel σ t φ)
    (τ : WorldHistory clockFrame) (hτ : τ.IsTotal) (t : ℚ) :
    TruthAt clockModel τ t φ.swapTemporal := by
  have hrel : ∀ x : ℚ,
      τ.states (-x) (hτ (-x)) = cneg ((reflect τ hτ).states x (reflect_isTotal τ hτ x)) := by
    intro x
    exact (cneg_cneg (τ.states (-x) (hτ (-x)))).symm
  have hm := truthAt_mirror φ (reflect τ hτ) τ (reflect_isTotal τ hτ) hτ hrel (-t)
  rw [neg_neg] at hm
  exact hm.mpr (h (reflect τ hτ) (reflect_isTotal τ hτ) (-t))

/-! ## Statement S2 — the CO-closed derivation system -/

/--
The **`CO`-closed schema system**: the dense base, every instance of `CO`, and closure under
every rule of `DerivationTree` that the empty-context schema form admits.

`DerivationTree`'s `necessitation`, `temporal_necessitation` and `temporal_duality` constructors
all require `Γ = []`, so no `CO` instance supplied as a *context* can ever appear under them. That
is exactly the gap `co_not_derives_prior_U_gap` leaves open and this system closes: here the `CO`
instances are axioms of the system, not assumptions, so they sit under every rule.

`assumption` and `weakening` are absent because they are context rules with nothing to act on in
the schema form. `temporal_duality` is present and must stay present: dropping it would silently
weaken what the theorem below claims.
-/
inductive CoDerivation : Formula → Type where
  /-- Any axiom admissible at `FrameClass.Dense`. -/
  | «axiom» (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Dense) :
      CoDerivation φ
  /-- Every instance of the paper's `CO` schema. -/
  | co (χ : Formula) : CoDerivation (Formula.co χ)
  /-- Modus ponens. -/
  | modus_ponens (φ ψ : Formula) (d₁ : CoDerivation (φ.imp ψ)) (d₂ : CoDerivation φ) :
      CoDerivation ψ
  /-- Modal necessitation. -/
  | necessitation (φ : Formula) (d : CoDerivation φ) : CoDerivation (Formula.box φ)
  /-- Temporal necessitation. -/
  | temporal_necessitation (φ : Formula) (d : CoDerivation φ) :
      CoDerivation (Formula.allFuture φ)
  /-- Temporal duality. -/
  | temporal_duality (φ : Formula) (d : CoDerivation φ) : CoDerivation φ.swapTemporal

/--
**Soundness of the `CO`-closed system over the arc model.**

The axiom case is `soundness_dense` applied to the one-step derivation; the `co` case is
`LoopingDuration.lean`'s Lemma C; `temporal_duality` is the mirror lemma. The conclusion is
universally quantified over the history and the time, which is what the three rule cases need.
-/
theorem coDerivation_sound (φ : Formula) (d : CoDerivation φ) :
    ∀ (τ : WorldHistory clockFrame), τ.IsTotal → ∀ t : ℚ, TruthAt clockModel τ t φ := by
  induction d with
  | «axiom» ψ h h_fc =>
      intro τ hτ t
      exact soundness_dense [] ψ (DerivationTree.axiom [] ψ h h_fc) clockFrame clockModel τ hτ t
        (by simp)
  | co χ => intro τ hτ t; exact clock_co_true clockModel χ τ hτ t
  | modus_ponens _ _ _ _ ih₁ ih₂ => intro τ hτ t; exact (ih₁ τ hτ t) (ih₂ τ hτ t)
  | necessitation _ _ ih => intro τ hτ t; exact fun σ hσ => ih σ hσ t
  | temporal_necessitation ψ _ ih =>
      intro τ hτ t
      exact (Truth.future_iff ψ).mpr fun s _ => ih τ hτ s
  | temporal_duality ψ _ ih => intro τ hτ t; exact truthAt_swapTemporal ψ ih τ hτ t

/--
**`CO` does not derive Prior-U (schema form).** The unqualified statement.

There is no derivation of `Axiom.prior_U_gap p` in the system consisting of the dense base, the
whole `CO` schema, modus ponens, modal and temporal necessitation, and temporal duality. Unlike
`co_not_derives_prior_U_gap`, this leaves no residue: the `CO` instances here are axioms, so they
are available under every rule, including the three that `DerivationTree` restricts to the empty
context.

Still not claimed, and still false, is any *frame*-level statement — see this module's docstring.
-/
theorem co_not_derives_prior_U_gap_schema (a : Atom) :
    ¬ Nonempty (CoDerivation (priorUGapFormula (Formula.atom a))) := by
  rintro ⟨d⟩
  exact priorUGapFormula_false a
    (coDerivation_sound _ d clockHistory clockHistory_isTotal 0)

end FormalSystem.Metalogic.Independence
