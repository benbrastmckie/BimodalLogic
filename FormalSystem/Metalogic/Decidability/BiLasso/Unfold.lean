/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import Mathlib.Algebra.Order.Group.Int

/-!
# The Exact One-Step Unfolding of `TruthAt` over ℤ-Time

`Formula.untl` and `Formula.snce` are stated in `Semantics/Truth.lean` as *unbounded* interval
quantifications: `untl g e` at `t` asserts a witness `s > t` at which the **event** `e` holds,
with the **guard** `g` holding throughout the open interval `(t, s)`. Over a discrete duration
type that existential is equivalent to a single recursive step, because `t + 1` is the least
element strictly above `t` and the open interval `(t, s)` decomposes as `{t + 1} ∪ (t + 1, s)`.
This module proves the two resulting equivalences.

## Argument order: guard first

The live clauses (`Semantics/Truth.lean`) are

```
| Formula.untl ψ φ => ∃ s, t < s ∧ TruthAt M τ s φ ∧ ∀ r, t < r → r < s → TruthAt M τ r ψ
| Formula.snce ψ φ => ∃ s, s < t ∧ TruthAt M τ s φ ∧ ∀ r, s < r → r < t → TruthAt M τ r ψ
```

so the **first** constructor argument is the guard and the **second** is the event. Everything
below is written `Formula.untl g e` / `Formula.snce g e` with `g` the guard and `e` the event.
See `specs/decisions/untl-snce-argument-order.md` for the migration that fixed this order.

## Why this scopes the development to ℤ-time

The unfolding is an *equivalence*, not merely an implication, and that is what a
Hintikka-style local-coherence condition needs: a label may decide `untl g e` at a position by
consulting only the position one step later. The forward direction of the `untl` equivalence
uses `t < s → t + 1 ≤ s`, i.e. that nothing lies strictly between `t` and `t + 1`. Over a dense
duration type that step fails outright — a witness may sit arbitrarily close to `t` with no
successor position to hand the obligation to — so no finite local condition can characterise
`untl`, and the whole annotated-lasso decision layer is confined to ℤ-time by this lemma and
not by any incidental choice elsewhere.

The same exactness is why `subformulaClosure` is adequate here with no Fischer–Ladner
enlargement: unfolding `untl g e` produces only `e`, `g`, and `untl g e` **itself**, all of
which are already in the closure of any formula containing `untl g e`. No new compound formula
is manufactured by the unfolding, so the closure is genuinely closed under the recursion that
`LocalCoherent` performs.

## Main Results

- `truth_untl_succ` — `untl g e` at `t` iff `e` at `t+1`, or `g` at `t+1` and `untl g e` at `t+1`
- `truth_snce_pred` — `snce g e` at `t` iff `e` at `t-1`, or `g` at `t-1` and `snce g e` at `t-1`
- `Int.rightInduction` / `Int.leftInduction` — the ℤ-distance induction principles, thin
  specialisations of Mathlib's `Int.leInduction` / `Int.leInductionDown`

## Generality

These are facts about ℤ-time semantics alone. They are quantified over every `TaskModel` over
ℤ, every history, every time, and every pair of formulas — no closure restriction, no
frame-class side condition, no lasso. They are stated at that generality deliberately, because
the small-model construction and the eventual filtration-side truth lemma both consume them.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

section Unfolding

variable {F : FrameOver intOrder} {M : TaskModel F} {τ : WorldHistory F}

/--
**The exact one-step unfolding of `untl` over ℤ.**

`untl g e` holds at `t` exactly when either the event `e` is already true at `t + 1`, or the
guard `g` holds at `t + 1` and the eventuality is passed on to `t + 1`.

Forward: a witness `s > t` satisfies `t + 1 ≤ s`. If `s = t + 1` the event holds at `t + 1`.
Otherwise `t + 1 < s`, the guard obligation at `t + 1` is discharged by the original guard, and
the *same* `s` witnesses `untl g e` at `t + 1` — its guard interval `(t + 1, s)` is contained
in `(t, s)`.

Backward: the left disjunct supplies the witness `t + 1`, whose guard obligation is vacuous
because no `r` satisfies `t < r < t + 1`. The right disjunct supplies a witness `s > t + 1`;
its guard interval `(t, s)` is `{t + 1} ∪ (t + 1, s)`, and both pieces are in hand.
-/
theorem truth_untl_succ (t : ℤ) (g e : Formula) :
    TruthAt M τ t (Formula.untl g e) ↔
      TruthAt M τ (t + 1) e ∨
        (TruthAt M τ (t + 1) g ∧ TruthAt M τ (t + 1) (Formula.untl g e)) := by
  constructor
  · rintro ⟨s, hts, hse, hguard⟩
    have hts' : @LT.lt ℤ _ t s := hts
    replace hguard : ∀ r : ℤ, @LT.lt ℤ _ t r → @LT.lt ℤ _ r s → TruthAt M τ r g := hguard
    rcases eq_or_lt_of_le (show @LE.le ℤ _ (t + 1) s by omega) with heq | hlt
    · exact Or.inl (heq ▸ hse)
    · refine Or.inr ⟨hguard (t + 1) (by omega) hlt, s, hlt, hse, ?_⟩
      intro r hr1 hr2
      have h1 : @LT.lt ℤ _ (t + 1) r := hr1
      have h2 : @LT.lt ℤ _ r s := hr2
      exact hguard r (by omega) h2
  · rintro (h | ⟨hg, s, hts, hse, hguard⟩)
    · refine ⟨t + 1, ?_, h, ?_⟩
      · show @LT.lt ℤ _ t (t + 1)
        omega
      · intro r hr1 hr2
        have h1 : @LT.lt ℤ _ t r := hr1
        have h2 : @LT.lt ℤ _ r (t + 1) := hr2
        exact absurd (show False by omega) not_false
    · have hts' : @LT.lt ℤ _ (t + 1) s := hts
      replace hguard :
          ∀ r : ℤ, @LT.lt ℤ _ (t + 1) r → @LT.lt ℤ _ r s → TruthAt M τ r g := hguard
      refine ⟨s, ?_, hse, ?_⟩
      · show @LT.lt ℤ _ t s
        omega
      · intro r hr1 hr2
        have h1 : @LT.lt ℤ _ t r := hr1
        have h2 : @LT.lt ℤ _ r s := hr2
        rcases eq_or_lt_of_le (show @LE.le ℤ _ (t + 1) r by omega) with heq | hlt
        · exact heq ▸ hg
        · exact hguard r hlt h2

/--
**The exact one-step unfolding of `snce` over ℤ** — the leftward mirror of `truth_untl_succ`.

Proved directly rather than by appeal to a duality transport: `temporal_duality` is a statement
about *derivability* in the proof system, not about `TruthAt`, so it does not apply here, and
"by symmetry" is not a proof. The argument is the exact reflection of the `untl` one, with
`t - 1` the greatest position strictly below `t`.
-/
theorem truth_snce_pred (t : ℤ) (g e : Formula) :
    TruthAt M τ t (Formula.snce g e) ↔
      TruthAt M τ (t - 1) e ∨
        (TruthAt M τ (t - 1) g ∧ TruthAt M τ (t - 1) (Formula.snce g e)) := by
  constructor
  · rintro ⟨s, hst, hse, hguard⟩
    have hst' : @LT.lt ℤ _ s t := hst
    replace hguard : ∀ r : ℤ, @LT.lt ℤ _ s r → @LT.lt ℤ _ r t → TruthAt M τ r g := hguard
    rcases eq_or_lt_of_le (show @LE.le ℤ _ s (t - 1) by omega) with heq | hlt
    · exact Or.inl (heq ▸ hse)
    · refine Or.inr ⟨hguard (t - 1) hlt (by omega), s, hlt, hse, ?_⟩
      intro r hr1 hr2
      have h1 : @LT.lt ℤ _ s r := hr1
      have h2 : @LT.lt ℤ _ r (t - 1) := hr2
      exact hguard r h1 (by omega)
  · rintro (h | ⟨hg, s, hst, hse, hguard⟩)
    · refine ⟨t - 1, ?_, h, ?_⟩
      · show @LT.lt ℤ _ (t - 1) t
        omega
      · intro r hr1 hr2
        have h1 : @LT.lt ℤ _ (t - 1) r := hr1
        have h2 : @LT.lt ℤ _ r t := hr2
        exact absurd (show False by omega) not_false
    · have hst' : @LT.lt ℤ _ s (t - 1) := hst
      replace hguard :
          ∀ r : ℤ, @LT.lt ℤ _ s r → @LT.lt ℤ _ r (t - 1) → TruthAt M τ r g := hguard
      refine ⟨s, ?_, hse, ?_⟩
      · show @LT.lt ℤ _ s t
        omega
      · intro r hr1 hr2
        have h1 : @LT.lt ℤ _ s r := hr1
        have h2 : @LT.lt ℤ _ r t := hr2
        rcases eq_or_lt_of_le (show @LE.le ℤ _ r (t - 1) by omega) with heq | hlt
        · exact heq ▸ hg
        · exact hguard r h1 hlt

end Unfolding

/-!
## The ℤ-distance induction principles

The truth lemma's substantive `untl` direction walks from a semantic witness at `s` back to the
position `t` it is claimed at, one step at a time. Mathlib already supplies the recursors —
`Int.leInduction` rightward and `Int.leInductionDown` leftward (the older names
`Int.le_induction` / `Int.le_induction_down` are deprecated aliases). The two wrappers below
restate them at `Prop` in the exact shape that argument consumes, so the consuming proof reads
as a distance induction rather than as a motive-with-proof-argument dependent eliminator.

Nothing is re-proved here: both wrappers are one-line applications.
-/

namespace Int

/-- **Rightward ℤ-induction.** A property true at `t` and preserved by the successor at every
point at or beyond `t` holds everywhere at or beyond `t`. A `Prop`-level restatement of
Mathlib's `Int.leInduction`. -/
theorem rightInduction {P : ℤ → Prop} {t : ℤ} (base : P t)
    (step : ∀ u : ℤ, t ≤ u → P u → P (u + 1)) :
    ∀ s : ℤ, t ≤ s → P s :=
  fun s hs => Int.leInduction base step s hs

/-- **Leftward ℤ-induction.** A property true at `t` and preserved by the predecessor at every
point at or below `t` holds everywhere at or below `t`. A `Prop`-level restatement of Mathlib's
`Int.leInductionDown`. -/
theorem leftInduction {P : ℤ → Prop} {t : ℤ} (base : P t)
    (step : ∀ u : ℤ, u ≤ t → P u → P (u - 1)) :
    ∀ s : ℤ, s ≤ t → P s :=
  fun s hs => Int.leInductionDown base step s hs

end Int

end FormalSystem.Metalogic.Decidability
