/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.SourceLanguage.Sentence
import FormalSystem.Semantics.Truth
import Mathlib.Order.Cover
import Mathlib.Order.SuccPred.Basic

/-!
# `Sat` and `sat_iff` — the source language's own semantics, and the agreement theorem

`Sat` is a native truth evaluation for `Sentence`, one clause per constructor, mirroring the
companion ModelChecker repository's own reference evaluator for its source AST. `sat_iff` proves
that `Sat` agrees with `Semantics.TruthAt` of the translation at **every** frame, model, world
history and time:

```
Sat M τ t φ ↔ TruthAt M τ t (tr φ)
```

This is the verified half of the obligation that the source repository's elimination of its defined
operators preserves truth. It is stated against `TruthAt` itself — the definition this library's
soundness and completeness results and the certificate re-checker are stated against — rather than
against a second transcription of the semantics, which is the whole point: agreement is with the
trusted semantics, not with another hand-written evaluator that could share a misreading.

## Main Definitions

- `Sat` — the native source-side truth evaluation, 18 clauses

## Main Results

- `sat_iff` — the agreement theorem
- `next_iff_covBy`, `prev_iff_covBy` — `Formula.next`/`Formula.prev` characterized
  unconditionally, over any temporal order
- `next_iff_succ`, `prev_iff_pred` — the same on a discrete carrier, as corollaries

## `CovBy` is the theorem; `succ`/`pred` are corollaries

`Formula.next φ` is `Formula.untl Formula.bot φ`, so its unconditional meaning is "`φ` holds at some
`s` later than `t` with nothing strictly in between" — exactly `∃ s, t ⋖ s ∧ …`, which is
`next_iff_covBy`, and which needs no discreteness assumption. The source repository's reference
evaluator reads `\next` as `t + 1`, i.e. as `Order.succ t`; that is `next_iff_succ`, and it holds
only under `[SuccOrder]` and `[NoMaxOrder]`.

The order matters, and this is not a stylistic choice. On a **dense** carrier `next φ` is
unsatisfiable — `FormalSystem/Metalogic/DedekindNonCompactness.lean` records the phenomenon — so a
reference that stated the `succ` reading unconditionally would be false. A reference that stated
only the `CovBy` reading would be true but would not visibly certify what the source repository
actually computes. Both are therefore stated, in that dependency order; the source repository's
integer-time instantiation is what makes the corollary the operative reading there.

`FormalSystem/Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff` states the same
`succ`-form fact, and its own docstring already notes that its natural home is elsewhere. The
duplication here is deliberate and unresolved: consolidating the two would mean importing
`FormalSystem/Metalogic/` from this layer-1 module, which is an upward edge that
`scripts/check-metalogic-cycles.sh` exists to prevent. Promotion of one shared lemma into
`FormalSystem/Semantics/Truth.lean` is the eventual fix and is a separate concern.

## The box clause is this library's, not the source repository's

`TruthAt`'s box clause quantifies over every world history at the **same** time, and `Sat`'s does
too. The source repository's reference evaluators quantify over every history **and every
position**, which in this library is `□△φ`, characterized by `Semantics.Truth.box_always_iff`. The
two coincide because the certificate framework's history family is closed under time shift
(`FormalSystem/Semantics/ShiftSet.lean`, and `FormalSystem/Semantics/TruthTransport.lean`'s
`timeShift_preserves_truth`), but they are **not the same clause**. A future reader must not "fix"
the Lean side to match a Python evaluator that is only extensionally equivalent under a frame
property; the clause used here is the one the soundness chain uses.

## What this theorem certifies, and what it does not

It certifies the **encoding**: that the seventeen-operator source language, evaluated natively,
means the same as `TruthAt` of its six-primitive image. It is an independent verified reference the
source repository can validate its own implementation against — which replaces
agreement-with-itself by agreement-with-a-theorem.

It does **not** certify that repository's implementation. Nothing about its translation's
memoization, its identity-keyed caches or its defined-operator expansion pass is inside this
theorem's scope; the conformance channel of `BimodalTools/README.md` is the only thing that connects
the theorem to running code. And it does not relieve that repository of its own verification
obligation for its translation: that obligation is about an implementation, it stays where it is,
and nothing here licenses removing it.

## References

* `FormalSystem/SourceLanguage/Sentence.lean` — `Sentence` and `tr`
* `FormalSystem/Semantics/Truth.lean` — `TruthAt` and the per-operator characterization family this
  proof runs on
* `FormalSystem/PlusLanguage/PlusValidity.lean` `plusTruthAt_ofFormula`,
  `FormalSystem/QuantLanguage/QuantTruth.lean` `quantTruthAt_ofFormula` — the bridge template
* `FormalSystem/Metalogic/DiscreteNonCompactness.lean` `truthAt_next_iff` — the pre-existing
  `succ`-form characterization, duplicated here for the reason above
-/

namespace FormalSystem.SourceLanguage

open FormalSystem.Syntax FormalSystem.Semantics

variable {F : TaskFrame}

/--
The source language's own truth evaluation, one clause per constructor, mirroring the companion
ModelChecker repository's reference evaluator for its source AST.

Two clauses depart from that evaluator deliberately, and each departure is argued in the module
docstring:

- `box` quantifies over every world history at the **same** time, which is `TruthAt`'s clause. The
  source repository's evaluator quantifies over every history and every position, which is `□△φ`
  here; the two coincide only because the certificate framework's history family is shift-closed.
- `next`/`prev` use the covering relation `⋖` rather than `t ± 1`. The successor reading is
  `next_iff_succ`/`prev_iff_pred`, corollaries on a discrete carrier.

Every other clause is the evaluator's, literally. `untl`/`snce` are guard-first with a strict
witness and an open guard interval, matching `TruthAt`.
-/
def Sat (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : Sentence → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .neg A => ¬ Sat M τ t A
  | .wedge A B => Sat M τ t A ∧ Sat M τ t B
  | .vee A B => Sat M τ t A ∨ Sat M τ t B
  | .box A => ∀ σ : WorldHistory F, Sat M σ t A
  | .allFut A => ∀ s : F.Duration, t < s → Sat M τ s A
  | .allPast A => ∀ s : F.Duration, s < t → Sat M τ s A
  | .untl g e => ∃ s : F.Duration, t < s ∧ Sat M τ s e ∧
      ∀ r : F.Duration, t < r → r < s → Sat M τ r g
  | .snce g e => ∃ s : F.Duration, s < t ∧ Sat M τ s e ∧
      ∀ r : F.Duration, s < r → r < t → Sat M τ r g
  | .cond A B => Sat M τ t A → Sat M τ t B
  | .bicond A B => Sat M τ t A ↔ Sat M τ t B
  | .top => True
  | .dia A => ∃ σ : WorldHistory F, Sat M σ t A
  | .someFut A => ∃ s : F.Duration, t < s ∧ Sat M τ s A
  | .somePast A => ∃ s : F.Duration, s < t ∧ Sat M τ s A
  | .next A => ∃ s : F.Duration, t ⋖ s ∧ Sat M τ s A
  | .prev A => ∃ s : F.Duration, s ⋖ t ∧ Sat M τ s A

/-! ### `Formula.next` and `Formula.prev`, characterized

The unconditional statements first, then the discrete corollaries. See the module docstring for why
the dependency runs in that direction and not the other. -/

/--
**The unconditional characterization of `Formula.next`.** `Formula.next φ` is
`Formula.untl Formula.bot φ`, whose guard is unsatisfiable, so the empty-gap condition says exactly
that the witness *covers* the present time.

No discreteness is assumed. On a dense carrier the right-hand side is empty, which is the correct
reading: `next φ` is unsatisfiable there.
-/
theorem next_iff_covBy (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.next φ) ↔ ∃ s : F.Duration, t ⋖ s ∧ TruthAt M τ s φ := by
  simp only [Formula.next, Truth.untl_iff, Truth.bot_false]
  constructor
  · rintro ⟨s, hts, hs, hgap⟩
    exact ⟨s, ⟨hts, fun _r hr hrs => hgap _ hr hrs⟩, hs⟩
  · rintro ⟨s, hcov, hs⟩
    exact ⟨s, hcov.1, hs, fun _r hr hrs => hcov.2 hr hrs⟩

/-- **The unconditional characterization of `Formula.prev`**, dual of `next_iff_covBy`. -/
theorem prev_iff_covBy (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.prev φ) ↔ ∃ s : F.Duration, s ⋖ t ∧ TruthAt M τ s φ := by
  simp only [Formula.prev, Truth.snce_iff, Truth.bot_false]
  constructor
  · rintro ⟨s, hst, hs, hgap⟩
    exact ⟨s, ⟨hst, fun _r hr hrt => hgap _ hr hrt⟩, hs⟩
  · rintro ⟨s, hcov, hs⟩
    exact ⟨s, hcov.1, hs, fun _r hr hrt => hcov.2 hr hrt⟩

/--
**The discrete corollary for `Formula.next`.** On a carrier with successors and no maximum, the
covering witness of `next_iff_covBy` is `Order.succ t`, so `next φ` is `φ` at the successor.

This is the reading the source repository's integer-time instantiation computes. It is a corollary
and not the statement: see the module docstring, and
`FormalSystem/Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff`, which states the same
fact for its own consumer.
-/
theorem next_iff_succ [SuccOrder F.Duration] [NoMaxOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.next φ) ↔ TruthAt M τ (Order.succ t) φ := by
  rw [next_iff_covBy]
  constructor
  · rintro ⟨s, hcov, hs⟩
    rcases lt_or_eq_of_le (Order.succ_le_of_lt hcov.1) with h | h
    · exact absurd h (hcov.2 (Order.lt_succ t))
    · exact h ▸ hs
  · intro h
    exact ⟨Order.succ t, ⟨Order.lt_succ t, fun _r hr hrs =>
      absurd hr (not_lt.mpr (Order.le_of_lt_succ hrs))⟩, h⟩

/-- **The discrete corollary for `Formula.prev`**, dual of `next_iff_succ`. -/
theorem prev_iff_pred [PredOrder F.Duration] [NoMinOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.prev φ) ↔ TruthAt M τ (Order.pred t) φ := by
  rw [prev_iff_covBy]
  constructor
  · rintro ⟨s, hcov, hs⟩
    rcases lt_or_eq_of_le (Order.le_pred_of_lt hcov.1) with h | h
    · exact absurd (Order.pred_lt t) (hcov.2 h)
    · exact h ▸ hs
  · intro h
    exact ⟨Order.pred t, ⟨Order.pred_lt t, fun _r hr =>
      not_lt.mpr (Order.le_of_pred_lt hr)⟩, h⟩

/-! ### The agreement theorem -/

/--
**The source language's native semantics agrees with `TruthAt` of the translation.**

Quantified over every `TaskFrame`, every `TaskModel` on it, every `WorldHistory`, every time and
every `Sentence` — which is what a theorem buys over a differential test against a corpus, together
with the fact that the right-hand side is `TruthAt` itself rather than a second hand-written
evaluator.

The `∀ τ t` sits after the colon rather than as binders because generalizing over both is required,
not cosmetic: the `box`/`dia` cases need the inductive hypothesis at a *different history*, and the
four tense cases together with `untl`/`snce`/`next`/`prev` need it at a *different time*.
`FormalSystem/PlusLanguage/PlusValidity.lean`'s `plusTruthAt_ofFormula` and
`FormalSystem/QuantLanguage/QuantTruth.lean`'s `quantTruthAt_ofFormula` are the template.

`cond` and `bicond` are the two cases that need a classical propositional step after the rewrite:
the source clause is a `→`/`↔` while the image is `Formula.or`/`Formula.and`, so there is nothing
left to rewrite and `tauto` finishes.
-/
theorem sat_iff (M : TaskModel F) (φ : Sentence) :
    ∀ (τ : WorldHistory F) (t : F.Duration), Sat M τ t φ ↔ TruthAt M τ t (tr φ) := by
  induction φ with
  | atom p => intro τ t; exact Iff.rfl
  | bot => intro τ t; exact Iff.rfl
  | neg A ih => intro τ t; simp [Sat, tr, ih]
  | wedge A B ihA ihB => intro τ t; simp [Sat, tr, ihA, ihB]
  | vee A B ihA ihB => intro τ t; simp [Sat, tr, ihA, ihB]
  | box A ih => intro τ t; simp [Sat, tr, ih]
  | allFut A ih => intro τ t; simp [Sat, tr, ih]
  | allPast A ih => intro τ t; simp [Sat, tr, ih]
  | untl g e ihg ihe => intro τ t; simp [Sat, tr, ihg, ihe]
  | snce g e ihg ihe => intro τ t; simp [Sat, tr, ihg, ihe]
  | cond A B ihA ihB => intro τ t; simp [Sat, tr, ihA, ihB]; tauto
  | bicond A B ihA ihB => intro τ t; simp [Sat, tr, ihA, ihB]; tauto
  | top => intro τ t; simp [Sat, tr]
  | dia A ih => intro τ t; simp [Sat, tr, ih]
  | someFut A ih => intro τ t; simp [Sat, tr, ih]
  | somePast A ih => intro τ t; simp [Sat, tr, ih]
  | next A ih => intro τ t; simp [Sat, tr, ih, next_iff_covBy]
  | prev A ih => intro τ t; simp [Sat, tr, ih, prev_iff_covBy]

end FormalSystem.SourceLanguage
