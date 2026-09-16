/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness
import FormalSystem.Metalogic.Algebraic.FlowFrame
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# The valuation-only chain-bundle truth lemma

A base-language formula evaluated on the flow frames of `Metalogic/Algebraic/FlowFrame.lean` can
see only a very simple Kripke structure: an indexed family of copies of the duration order, with
`H`/`G` quantifying *within* a copy and `□` quantifying over *everything*. This module states that
structure as a bare satisfaction predicate `chainSat` over `FamIdx × ↑D` — no maximal-consistent
sets, no proof-theoretic data, just a valuation — and proves that `MinusTruthAt` along a translate
history agrees with it pointwise.

## Why `□` is universal and carries no time argument

`chainSat`'s `box` clause is `∀ q', chainSat v q' φ`, quantifying **both** coordinates and taking
no time argument at all. That is not a simplification: it is what
`Conservativity/MinusLanguageSoundness.lean`'s `minus_box_universal` establishes. `MinusTruthAt`'s box
clause is history-blind by definition (it does not mention `τ`) and time-blind by
`Semantics.Truth.box_const`, so `□φ` holds at one total history-and-time exactly when `φ` holds at
every total history and every time. On a flow frame the total histories are *exactly* the
translates (`multiFamGen_total_eq_range`), so "every total history, every time" is "every point of
`FamIdx × ↑D`".

A `box` clause carrying a time argument would therefore be a mis-transcription, and would make L⁻
over task frames look like a product logic with same-time alignment validities, which it is not.

## What this module is, and what it is not

It is **the transfer half** of the standard route to a completeness theorem over the dense or
Dedekind classes: given a chain-model refutation of `φ`, produce a task-frame refutation. That
half is closed here, generically in `D` and `FamIdx`, and `not_minusValidIn_of_not_chainSat` is the
single interface any future canonical-model work consumes. The frame construction the route also
needs was already in-tree and generic (`multiFamTaskFrameGen` discharges all four frame axioms for
an arbitrary temporal order), so no frame-building appears here either.

It is **not** a completeness proof and does not approach one. The missing content is entirely on
the other side: a canonical model built from base-language maximal-consistent sets, canonicity for
the eleven Base axioms plus `DN`, bulldozing, and a countable-ℚ realization. None of that is here,
no theorem in this module concludes in `TMMinusComplete _` or `Forward _`, and the standing prohibition
in `Metalogic/Conservativity.lean` — never state a completeness or forward-conservativity theorem
and discharge it with `sorry` — applies in full. The current four-row status is recorded in
`Conservativity/TMCompletenessReduction.lean`'s module docstring.

In particular, the converse of `not_minusValidIn_of_not_chainSat` is **not** proved and is not
available: nothing here says that a formula underivable in the system has a chain-model
refutation. That implication is the completeness direction itself.

## Main Results

- `chainSat` — Kripke satisfaction on a disjoint union of `D`-chains, with `□` universal over all
  points and `H`/`G` quantifying the second coordinate within a fixed first coordinate
- `chainBundle_truth_lemma` — `MinusTruthAt` along `multiFamHistoryGen f w₀` at time `t` matches
  `chainSat` at the point `(f, w₀ + t)`
- `not_minusValidIn_of_not_chainSat` — the transfer corollary: a chain-model refutation refutes
  `MinusValidIn fc` at every `fc` the flow frame satisfies
- `not_minusValidDense_of_not_chainSat`, `not_minusValidRTime_of_not_chainSat` — its instantiations at
  ℚ and at ℝ, so the transfer step is closed for both of the two open rows

## References

* `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` — `multiFamTaskFrameGen`,
  `multiFamHistoryGen`, `multiFamHistoryGen_total`, `multiFamGen_total_eq_range`
* `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` — `minus_box_universal`
* `FormalSystem/Semantics/MinusLanguage/MinusTruth.lean` — the six `MinusTruthAt` clauses `chainSat` mirrors
* `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` — the four-row status table

## Tags

chain-bundle · truth-lemma · flow-frame · universal-modality · base-language
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

variable {D : TemporalOrder} {FamIdx : Type} [Nonempty FamIdx]

/--
**Kripke satisfaction on a disjoint union of `D`-chains.**

Points are pairs `(f, x)`: `f` names the chain, `x` the position along it. Six clauses, one per
`MinusFormula` constructor, mirroring `Semantics.MinusTruthAt`:

* `atom` — read off the bare valuation `v`. Unlike `MinusTruthAt`'s atom clause there is no domain
  side condition, because a chain point is always in the "domain" of its own chain.
* `bot`, `imp` — as usual.
* `box` — `∀ q', chainSat v q' φ`, over **all** points of **all** chains, with no time argument.
  See the module docstring: this is `minus_box_universal`, not a simplification.
* `allPast`, `allFuture` — quantify the second coordinate strictly below/above `q.2`, holding the
  first coordinate `q.1` fixed. This is the sense in which the chains are disjoint for `H`/`G`
  while being merged for `□`.
-/
def chainSat (v : FamIdx × (D : Type) → Atom → Prop) :
    FamIdx × (D : Type) → MinusFormula → Prop
  | q, .atom p => v q p
  | _, .bot => False
  | q, .imp φ ψ => chainSat v q φ → chainSat v q ψ
  | _, .box φ => ∀ q' : FamIdx × (D : Type), chainSat v q' φ
  | q, .allPast φ => ∀ s : (D : Type), s < q.2 → chainSat v (q.1, s) φ
  | q, .allFuture φ => ∀ s : (D : Type), q.2 < s → chainSat v (q.1, s) φ

/--
**The truth lemma.** L⁻ truth along the translate history `multiFamHistoryGen f w₀`, at time `t`,
is `chainSat` at the point `(f, w₀ + t)`.

Induction on `φ`, `generalizing f w₀ t` — mandatory, since three of the six cases need the
hypothesis at a different point: `box` at a different chain *and* a different base point,
`allPast`/`allFuture` at a different time.

Case by case:

* `atom` — the model's valuation at `multiFamHistoryGen f w₀`'s state at `t`, which is
  definitionally `(f, w₀ + t)`. The domain conjunct is `trivial` (`multiFamHistoryGen` carries
  `domain := fun _ => True`).
* `bot`, `imp` — `Iff.rfl` and congruence.
* `box` — the two interesting halves. Forwards, `minus_box_universal` turns `□φ` at `(τ, t)` into
  truth at *every* total history and *every* time, so it can be instantiated at
  `multiFamHistoryGen q'.1 q'.2` and time `0`, landing on `chainSat v (q'.1, q'.2 + 0)`.
  Backwards, an arbitrary total `σ` is a translate by `multiFamGen_total_eq_range`, and the
  hypothesis covers every point.
* `allPast`, `allFuture` — the quantified variable is reindexed along the order-isomorphism
  `s ↦ w₀ + s` of `↑D`, whose two directions are `lt_of_add_lt_add_left` and
  `add_lt_add_iff_left`. This is where the chains stay separate: the translation moves the
  position within the chain `f` and never leaves it.
-/
theorem chainBundle_truth_lemma (M : TaskModel (multiFamTaskFrameGen D FamIdx))
    (f : FamIdx) (w₀ t : (D : Type)) (φ : MinusFormula) :
    MinusTruthAt M (multiFamHistoryGen (D := D) f w₀) t φ ↔ chainSat M.valuation (f, w₀ + t) φ := by
  induction φ generalizing f w₀ t with
  | atom p =>
      constructor
      · rintro ⟨_, h⟩; exact h
      · intro h; exact ⟨trivial, h⟩
  | bot => exact Iff.rfl
  | imp φ ψ ih1 ih2 => exact imp_congr (ih1 f w₀ t) (ih2 f w₀ t)
  | box φ ih =>
      constructor
      · intro h q'
        have huniv := (minus_box_universal M _ t (multiFamHistoryGen_total f w₀) φ).mp h
        have hq := (ih q'.1 q'.2 0).mp
          (huniv (multiFamHistoryGen q'.1 q'.2) (multiFamHistoryGen_total _ _) 0)
        simpa using hq
      · intro h σ hσ
        have hmem :
            σ ∈ Set.range (fun (p : FamIdx × (D : Type)) => multiFamHistoryGen p.1 p.2) := by
          rw [← multiFamGen_total_eq_range (D := D) FamIdx]; exact hσ
        obtain ⟨⟨f', w₀'⟩, rfl⟩ := hmem
        exact (ih f' w₀' t).mpr (h (f', w₀' + t))
  | allPast φ ih =>
      constructor
      · intro h u hu
        have hlt : w₀ + (u - w₀) < w₀ + t := by simpa using hu
        have hu' := (ih f w₀ (u - w₀)).mp (h (u - w₀) (lt_of_add_lt_add_left hlt))
        simpa using hu'
      · intro h s hs
        exact (ih f w₀ s).mpr (h (w₀ + s) (show w₀ + s < w₀ + t from
          (add_lt_add_iff_left w₀).mpr hs))
  | allFuture φ ih =>
      constructor
      · intro h u hu
        have hlt : w₀ + t < w₀ + (u - w₀) := by simpa using hu
        have hu' := (ih f w₀ (u - w₀)).mp (h (u - w₀) (lt_of_add_lt_add_left hlt))
        simpa using hu'
      · intro h s hs
        exact (ih f w₀ s).mpr (h (w₀ + s) (show w₀ + t < w₀ + s from
          (add_lt_add_iff_left w₀).mpr hs))

/-! ## The transfer corollary

The brief's route step (3) — "transform into a Dense task frame" — turns out to be *only* this
corollary. The frame construction it seems to call for was already in the tree and already
generic: `multiFamTaskFrameGen` discharges Compositionality, Seriality, Limit and Saturation for
an arbitrary temporal order, with singleton fibres, and `multiFamGen_total_eq_range` identifies
its possible worlds with the translates. So nothing is built here; the only content is crossing
from `chainSat` back to `MinusValidIn`. -/

/--
**A chain-model refutation is a task-frame refutation.**

The single interface a future base-language canonical model consumes. Given a valuation `v`, a
point `q` at which `φ` fails, and *any* frame-class tag the flow frame over `D` satisfies, `φ` is
not `fc`-L⁻-valid.

Every ingredient is already generic: the model is `⟨v⟩` (`TaskModel` has one field), the history
is `multiFamHistoryGen q.1 q.2`, its totality is `multiFamHistoryGen_total`, and the bridge is
`chainBundle_truth_lemma` read at time `0`, where `q.2 + 0 = q.2` puts the base point back at `q`.

**The converse is not proved here and is not available.** "Every `fc`-underivable formula has a
chain-model refutation" is the completeness direction, and is exactly what
`Conservativity/TMCompletenessReduction.lean` records as unasserted at all four tags.
-/
theorem not_minusValidIn_of_not_chainSat {fc : FrameClass}
    (hSat : fc.Sat (multiFamTaskFrameGen D FamIdx))
    (v : FamIdx × (D : Type) → Atom → Prop) (q : FamIdx × (D : Type)) (φ : MinusFormula)
    (h : ¬ chainSat v q φ) : ¬ MinusValidIn fc φ := by
  intro hvalid
  refine h ?_
  have htrue := MinusValidIn.apply_total hvalid (multiFamTaskFrameGen D FamIdx) hSat ⟨v⟩
    (multiFamHistoryGen q.1 q.2) (multiFamHistoryGen_total _ _) 0
  have h2 := (chainBundle_truth_lemma (D := D) ⟨v⟩ q.1 q.2 0 φ).mp htrue
  simpa using h2

/--
**The `.Dense` instantiation**, at chains of rationals.

`FrameClass.Sat .Dense` reduces to `DenselyOrdered ↑(TemporalOrder.of ℚ)` through the reducible
chain `Sat .Dense ⇝ TaskFrame.IsDense ⇝ DenselyOrdered`, so the side condition is
`inferInstance`. The `(fc := …)` ascription is required: `MinusValidDense` is a `def`, not an
`abbrev`, so the tag is not determined from the goal in time to elaborate `hSat`.
-/
theorem not_minusValidDense_of_not_chainSat
    (v : FamIdx × ((TemporalOrder.of ℚ) : Type) → Atom → Prop)
    (q : FamIdx × ((TemporalOrder.of ℚ) : Type)) (φ : MinusFormula)
    (h : ¬ chainSat v q φ) : ¬ MinusValidDense φ :=
  not_minusValidIn_of_not_chainSat (fc := FrameClass.Dense) (D := TemporalOrder.of ℚ)
    inferInstance v q φ h

/--
**The `.RTime` instantiation**, at chains of reals.

`FrameClass.Sat .RTime` is `TaskFrame.IsDense ∧ TaskFrame.IsComplete`, so unlike the `.Dense` case
the side condition is a pair. The density half is `inferInstance`; the completeness half is
`∀ s, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`, which is Mathlib's `Real.exists_isLUB` verbatim.
`Metalogic/DedekindNonCompactness.lean` already discharges `Sat .RTime` with the same term, so
this row costs one line and no new mathematics.

Landing both rows means the transfer step is closed for **both** open rows regardless of which is
pursued — but note what that does and does not settle. The Dedekind row's obstruction is on the
canonical-model side, not here; see `Conservativity/TMCompletenessReduction.lean`.
-/
theorem not_minusValidRTime_of_not_chainSat
    (v : FamIdx × ((TemporalOrder.of ℝ) : Type) → Atom → Prop)
    (q : FamIdx × ((TemporalOrder.of ℝ) : Type)) (φ : MinusFormula)
    (h : ¬ chainSat v q φ) : ¬ MinusValidRTime φ :=
  not_minusValidIn_of_not_chainSat (fc := FrameClass.RTime) (D := TemporalOrder.of ℝ)
    ⟨inferInstance, fun _ hne hbdd => Real.exists_isLUB hne hbdd⟩ v q φ h

end FormalSystem.Metalogic
