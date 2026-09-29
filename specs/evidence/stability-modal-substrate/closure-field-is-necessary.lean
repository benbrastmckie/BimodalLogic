/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples

/-!
# The `lift` Field Is a Genuine Obligation, Not a Defensive One

This file records, machine-checked, why `SharingSkeleton` carries `lift : LiftableRaw ...` as a
field that every producer must discharge, rather than as a fact derivable from the other data.
It contains **no `sorry`** and asserts nothing it does not prove.

## The decision this holds in place

When succession *was* `share (u + 1)`, the histories characterization `total_eq_thread` — every
world history of the presented frame is a thread's trace — came free: a `Step`-path's own
intermediates already formed a thread. Once succession became a separate, possibly sparser
relation, that stopped being automatic, and `SharingSkeleton` gained the `lift` field to demand
it. The obvious objection is that the field is defensive: perhaps every reasonable producer
satisfies it anyway, and the obligation could be discharged once and for all.

It could not. `stabFamily` — the landed (C5) non-vacuity witness of
`PlusWitnessFamily/Examples.lean`, which shares a world state at `u = 0` and nowhere else —
admits a frame `Step`-path that no index-identity succession path tracks. So a producer that
chose the no-hopping bundle for this family could not discharge `lift` at all, and the field is
load-bearing.

## The argument

`crossPath` rides lasso `0` strictly before the origin and lasso `1` from the origin on. It is a
`Step`-path: away from the origin each step is reflexive, and the one crossing step at `u = -1`
goes through the shared state at `0`, which is exactly what `Step u i j := ∃ i', share u i i' ∧
share (u+1) i' j` permits.

No index-identity path tracks it. Such a path is constant, because `transId` relates an index
only to itself; but tracking forces the path to agree with `crossPath` up to `share` at every
time, and at `u = -1` and `u = 1` the sharing relation is equality. So the path would have to be
both `0` and `1`.

## Why this is not weakened to a statement about the current tree

`stabFamily` as it stands supplies the *free-succession* bundle `transFullOf`, and its `lift`
field is discharged by `liftable_of_transFullOf`. The theorem below therefore does not say that
the landed family fails an obligation. It says that the obligation has content: swap that
family's succession datum for the no-hopping bundle, changing nothing else, and `LiftableRaw`
becomes false. That is a refutation of a named alternative design, not a restatement of the
field's existence.

## Relation to the gate families

`Examples.lean`'s Family A and Family B both DO use the no-hopping bundle, and both discharge
`lift`. What separates them from `stabFamily` is the shape of their sharing: each is discrete on
one side of a cut and total on the other, so a `Step`-path is pinned on the discrete side and
tracked by a constant on the total side. `stabFamily` shares at a single time, with discreteness
on both sides of it, and a path can cross there and never be caught.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage FormalSystem.Syntax

namespace PlusSharingWitnessFamily

section ClosureNecessary

variable (p : Atom)

/-- The `Step`-path that rides lasso 0 strictly before the origin and lasso 1 from it on. -/
def crossPath : ℤ → Fin (stabFamily p).lassos.length :=
  fun u => if u < 0 then ⟨0, stabFamily_zero_lt p⟩ else ⟨1, stabFamily_one_lt p⟩

/-- **The crossing path is a frame path.** Away from the origin each step is reflexive; the one
crossing step at `u = -1` goes through the state shared at `0`. -/
theorem crossPath_step (u : ℤ) :
    (stabFamily p).skeleton.Step u (crossPath p u) (crossPath p (u + 1)) := by
  unfold crossPath
  rcases lt_trichotomy u (-1) with hu | hu | hu
  · rw [if_pos (by omega), if_pos (by omega)]
    exact SharingSkeleton.step_refl _ _ _
  · subst hu
    rw [if_pos (by omega), if_neg (by omega)]
    refine ⟨⟨0, stabFamily_zero_lt p⟩, (stabFamily p).share_refl _ _, ?_⟩
    rw [show (-1 : ℤ) + 1 = 0 by norm_num]
    exact stabFamily_share_zero p _ _
  · rw [if_neg (by omega), if_neg (by omega)]
    exact SharingSkeleton.step_refl _ _ _

/--
**The `lift` obligation has content: `stabFamily` cannot discharge it at index-identity
succession.**

Take the landed (C5) witness and replace its free-succession matrices by the no-hopping bundle,
changing nothing else. `LiftableRaw` is then false: `crossPath` is a `Step`-path of the same
frame, and every index-identity path is constant, while tracking `crossPath` would force such a
path to be `0` at `u = -1` and `1` at `u = 1`, where sharing is equality.

This is why `lift` is a structure field rather than a derived lemma.
-/
theorem stabFamily_not_liftable_at_transId :
    ¬ LiftableRaw (stabFamily p).lassos.length
        (stabFamily p).repBack (stabFamily p).repMid (stabFamily p).repFwd
        (transIdOf (stabFamily p).lassos.length (stabFamily p).repBack)
        (transIdOf (stabFamily p).lassos.length (stabFamily p).repMid)
        (transIdOf (stabFamily p).lassos.length (stabFamily p).repFwd) := by
  intro hlift
  obtain ⟨τ, htrans, hshare⟩ := hlift (crossPath p) (crossPath_step p)
  -- An index-identity path is constant.
  have hstep : ∀ u : ℤ, τ u = τ (u + 1) := by
    intro u
    have h := (htrans u).1
    rw [transMatOf_id] at h
    exact transId_eq h
  have hconst : ∀ (n : ℕ) (w : ℤ), τ (w + n) = τ w := by
    intro n
    induction n with
    | zero => intro w; simp
    | succ n ih =>
      intro w
      rw [show w + ((n + 1 : ℕ) : ℤ) = w + n + 1 by omega, ← hstep, ih w]
  have hc : τ (-1) = τ 1 := by
    have := hconst 2 (-1)
    rw [show (-1 : ℤ) + ((2 : ℕ) : ℤ) = 1 by norm_num] at this
    exact this.symm
  -- Tracking pins the path to `crossPath` at every time where sharing is equality.
  have h1 : crossPath p (-1) = τ (-1) :=
    (stabFamily_share_ne p (by norm_num) _ _).mp (hshare (-1))
  have h2 : crossPath p 1 = τ 1 :=
    (stabFamily_share_ne p (by norm_num) _ _).mp (hshare 1)
  rw [← h1, ← h2] at hc
  simp [crossPath] at hc

end ClosureNecessary

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
