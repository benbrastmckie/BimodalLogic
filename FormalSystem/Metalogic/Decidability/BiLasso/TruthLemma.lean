/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Annotation

/-!
# The Truth Lemma for Annotated Bi-Lassos

Along a locally coherent, fulfilling annotated bi-lasso, and relative to a sound box oracle,
truth at a position **equals membership in that position's label**, for every formula in the
closure. Evaluation is replaced by a read-off.

## Why fulfilment is a hypothesis and not a construction

This is the lasso instance of the general "truth along a fulfilling structure" lemma the
filtration-side development will need, and the reason it goes through here is structural:
`Fulfilling` is **carried by the structure** and only ever *consumed* by the induction below.

Earlier abandoned attempts in this repository — `RoundRobinChain`, `OracleStep`,
`OracleCoherence`, `ScheduleBasedBFMCS` — tried instead to *establish* fulfilment inside the
truth-lemma induction, by scheduling eventuality discharge as the induction proceeded. That
cannot work, and the obstruction is not technical: fulfilment is not a local property. Whether
an `untl` at a position is ever discharged depends on unboundedly much of the structure to the
right of that position, so no amount of local bookkeeping inside an induction on formula
structure can produce it. Separating the two — a local condition (`LocalCoherent`) plus a
global one (`Fulfilling`), both hypotheses — is what makes the induction routine.

`BiLasso/Examples.lean` shows the separation is real: `negAnnot` is locally coherent and not
fulfilling.

## The two nested inductions

The `untl` case's `→` direction carries the only genuine difficulty, and it runs **two** nested
inductions which are kept textually separate below:

- the **outer** induction is on the formula `ψ`, generalised over the time `t`;
- the **inner** induction, isolated as `untl_mem_label_of_witness`, is on the *distance*
  `(s - t).toNat` from the position to the semantic witness.

Conflating them is the standard way this proof goes wrong: the inner induction needs the outer
induction hypotheses for `g` and `e` **at every time**, which is exactly why the outer statement
is `∀ t` rather than fixed-`t`.

The `←` direction is immediate — `Fulfilling` hands over the witness directly.

## Argument order

Guard first: `Formula.untl g e` has guard `g`, event `e`, matching `Semantics/Truth.lean`.

## Main Results

- `truth_along_annot` — truth equals label membership on the closure
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {P : IntPresentation} {φ : Formula} {bx : Formula → Bool}

namespace Annot

/-- The decoded history of an annotated bi-lasso, as the `WorldHistory` that `TruthAt` consumes. -/
abbrev hist (A : Annot P φ) : WorldHistory P.toTaskFrame := A.lasso.toHF.val

/-- The decoded history is total: `toHF` is built from a bi-infinite step path. -/
theorem hist_isTotal (A : Annot P φ) : A.hist.IsTotal := A.lasso.toHF.property

/-- The decoded history's state at a time is the lasso's decoded state. -/
theorem hist_states (A : Annot P φ) (t : ℤ) (ht : A.hist.domain t) :
    A.hist.states t ht = A.lasso.unroll t := rfl

end Annot

/--
**The inner induction of the `untl` case**: a semantic witness at distance `d` forces the
eventuality into the label.

Stated as a standalone lemma over the witness distance, with the outer induction's hypotheses
for the guard `g` and the event `e` passed in as `hg` and `he` — *at every time*, which is what
the recursion at `t + 1` requires. Keeping this separate from the induction on formula structure
is deliberate; see the module docstring.

At distance `1` the event is already at `t + 1` and the local clause's left disjunct fires. At
distance `d + 1` the guard is at `t + 1` by the interval hypothesis, the same witness `s` serves
at `t + 1` at distance `d`, and the clause's right disjunct fires.
-/
theorem untl_mem_label_of_witness (A : Annot P φ)
    (hloc : LocalCoherent P φ bx A) {g e : Formula}
    (hge : Formula.untl g e ∈ subformulaClosure φ)
    (hg : ∀ u : ℤ, TruthAt P.toModel A.hist u g ↔ g ∈ A.label u)
    (he : ∀ u : ℤ, TruthAt P.toModel A.hist u e ↔ e ∈ A.label u) :
    ∀ (d : ℕ) (t s : ℤ), s - t = (d : ℤ) → t < s →
      TruthAt P.toModel A.hist s e →
      (∀ r : ℤ, t < r → r < s → TruthAt P.toModel A.hist r g) →
      Formula.untl g e ∈ A.label t := by
  intro d
  induction d with
  | zero =>
    intro t s hd hts _ _
    omega
  | succ n ih =>
    intro t s hd hts hse hguard
    have hclause := (hloc t).2.2.2.2.1 g e hge
    rcases eq_or_lt_of_le (show t + 1 ≤ s by omega) with heq | hlt
    · -- the witness is the very next position: left disjunct
      refine hclause.mpr (Or.inl ?_)
      exact (he (t + 1)).mp (heq ▸ hse)
    · -- the witness is further out: guard at `t + 1`, and recurse there at distance `n`
      refine hclause.mpr (Or.inr ⟨(hg (t + 1)).mp (hguard (t + 1) (by omega) hlt), ?_⟩)
      exact ih (t + 1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r (by omega) hr2)

/--
**The inner induction of the `snce` case** — the leftward mirror of
`untl_mem_label_of_witness`, over the distance `(t - s).toNat` to a witness in the past.
-/
theorem snce_mem_label_of_witness (A : Annot P φ)
    (hloc : LocalCoherent P φ bx A) {g e : Formula}
    (hge : Formula.snce g e ∈ subformulaClosure φ)
    (hg : ∀ u : ℤ, TruthAt P.toModel A.hist u g ↔ g ∈ A.label u)
    (he : ∀ u : ℤ, TruthAt P.toModel A.hist u e ↔ e ∈ A.label u) :
    ∀ (d : ℕ) (t s : ℤ), t - s = (d : ℤ) → s < t →
      TruthAt P.toModel A.hist s e →
      (∀ r : ℤ, s < r → r < t → TruthAt P.toModel A.hist r g) →
      Formula.snce g e ∈ A.label t := by
  intro d
  induction d with
  | zero =>
    intro t s hd hts _ _
    omega
  | succ n ih =>
    intro t s hd hst hse hguard
    have hclause := (hloc t).2.2.2.2.2 g e hge
    rcases eq_or_lt_of_le (show s ≤ t - 1 by omega) with heq | hlt
    · refine hclause.mpr (Or.inl ?_)
      exact (he (t - 1)).mp (heq ▸ hse)
    · refine hclause.mpr (Or.inr ⟨(hg (t - 1)).mp (hguard (t - 1) hlt (by omega)), ?_⟩)
      exact ih (t - 1) s (by omega) hlt hse (fun r hr1 hr2 => hguard r hr1 (by omega))

/--
**The truth lemma.** Along a locally coherent, fulfilling annotated bi-lasso, and relative to a
sound box oracle, `TruthAt` at a position is exactly membership in that position's label, for
every formula in `subformulaClosure φ`.

No restriction to a temporal-nesting-free fragment, no modal-depth bound, and no frame-class
side condition: the statement is over the whole closure, which is what makes it usable as the
decision layer's correctness core.
-/
theorem truth_along_annot (hbx : BoxOracleSound P bx) (A : Annot P φ)
    (hloc : LocalCoherent P φ bx A) (hful : Fulfilling P φ A) :
    ∀ (ψ : Formula), ψ ∈ subformulaClosure φ →
      ∀ (t : ℤ), TruthAt P.toModel A.hist t ψ ↔ ψ ∈ A.label t := by
  intro ψ
  induction ψ with
  | atom p =>
    intro hmem t
    have hatom := (hloc t).1 p hmem
    rw [hatom]
    constructor
    · rintro ⟨ht, hval⟩
      rwa [A.hist_states t ht, P.toModel_valuation] at hval
    · intro hval
      refine ⟨A.hist_isTotal t, ?_⟩
      rw [A.hist_states t (A.hist_isTotal t), P.toModel_valuation]
      exact hval
  | bot =>
    intro _ t
    constructor
    · intro h; exact absurd h Truth.bot_false
    · intro h; exact absurd h (hloc t).2.1
  | imp a b iha ihb =>
    intro hmem t
    have ha := iha (closure_imp_left φ a b hmem) t
    have hb := ihb (closure_imp_right φ a b hmem) t
    rw [Truth.imp_iff, (hloc t).2.2.1 a b hmem]
    exact ⟨fun h hlab => hb.mp (h (ha.mpr hlab)), fun h htr => hb.mpr (h (ha.mp htr))⟩
  | box χ _ =>
    -- No induction hypothesis is needed: the oracle supplies the box facts wholesale, and
    -- `box_const` moves them from the evaluation time to the oracle's fixed time `0`.
    intro hmem t
    rw [(hloc t).2.2.2.1 χ hmem, hbx χ]
    exact Truth.box_time_const P.toModel A.hist (A.hist_isTotal) t 0 χ
  | untl g e ihg ihe =>
    intro hmem t
    have hgc : g ∈ subformulaClosure φ := closure_untl_right φ e g hmem
    have hec : e ∈ subformulaClosure φ := closure_untl_left φ e g hmem
    have hg := ihg hgc
    have he := ihe hec
    constructor
    · -- the substantive direction: an inner induction on the distance to the witness
      rintro ⟨s, hts, hse, hguard⟩
      exact untl_mem_label_of_witness A hloc hmem hg he (s - t).toNat t s
        (by omega) hts hse hguard
    · -- immediate: `Fulfilling` hands over the witness
      intro hlab
      obtain ⟨s, hts, hes, hgs⟩ := hful.1 t g e hlab
      exact ⟨s, hts, (he s).mpr hes, fun r hr1 hr2 => (hg r).mpr (hgs r hr1 hr2)⟩
  | snce g e ihg ihe =>
    intro hmem t
    have hgc : g ∈ subformulaClosure φ := closure_snce_right φ e g hmem
    have hec : e ∈ subformulaClosure φ := closure_snce_left φ e g hmem
    have hg := ihg hgc
    have he := ihe hec
    constructor
    · rintro ⟨s, hst, hse, hguard⟩
      exact snce_mem_label_of_witness A hloc hmem hg he (t - s).toNat t s
        (by omega) hst hse hguard
    · intro hlab
      obtain ⟨s, hst, hes, hgs⟩ := hful.2 t g e hlab
      exact ⟨s, hst, (he s).mpr hes, fun r hr1 hr2 => (hg r).mpr (hgs r hr1 hr2)⟩

/--
`truth_along_annot` with the position and the formula as ordinary leading arguments.

`truth_along_annot` itself must bind `ψ` outermost and `t` innermost, because the induction on
`ψ` needs its hypotheses at *every* time — the inner distance induction recurses at `t + 1`.
This restatement is the same proposition in the argument order call sites want, and
`A.lasso.toHF.val` is written out rather than abbreviated as `A.hist`.
-/
theorem truth_along_annot_at (hbx : BoxOracleSound P bx) (A : Annot P φ)
    (hloc : LocalCoherent P φ bx A) (hful : Fulfilling P φ A)
    (t : ℤ) (ψ : Formula) (hψ : ψ ∈ subformulaClosure φ) :
    TruthAt P.toModel A.lasso.toHF.val t ψ ↔ ψ ∈ A.label t :=
  truth_along_annot hbx A hloc hful ψ hψ t

end FormalSystem.Metalogic.Decidability
