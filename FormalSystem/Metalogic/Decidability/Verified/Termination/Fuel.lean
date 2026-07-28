/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.TimeTypeBound
import FormalSystem.Metalogic.Decidability.Saturation

/-!
# T3 — Justified Fuel

T1 (`SubformulaProperty.lean`) fixes the formula stock; T2 (`TimeTypeBound.lean`) bounds the
number of distinguishable times against it. T3 turns those two into a fuel figure at which
`buildTableau` cannot exhaust, so downstream phases only ever see genuinely saturated branches
rather than fuel-starved ones.

## The progress measure, and why it is set growth rather than length growth

`expandOnceUnblocked_adds_new` (landed in Phase 2.5) says an extending step is non-destructive
and adds at least one formula the branch did not carry: `b ⊆ nb ∧ ∃ g ∈ nb, g ∉ b`. Its weaker
sibling `expandOnceUnblocked_length_lt` says the *list* gets longer, and that is deliberately not
what this file consumes. The engine builds `nb = fs ++ b`, and `fs` may repeat formulas already
present, so `List.length` grows without ever approaching a ceiling. What has a ceiling is the
branch **as a set**: `Branch.toFinset` is strictly monotone along an extending step, so a run is
no longer than the finite universe the branch lives in.

`expandOnceUnblocked_card_lt` below is that observation, and it is the step T3's induction turns
into a bound. The universe it runs against has two dimensions:

* **formulas** — bounded by T1: every branch formula stays in a `TableauClosed` stock `C`;
* **labels** — *not* bounded by T1, because witness rules mint fresh times. This is exactly what
  blocking is for, and it is why T2 is a prerequisite rather than a convenience:
  `blocking_fires_of_card_lt` says a chain of more than `2 ^ (2 * |C|)` times cannot be extended,
  so the label dimension is bounded by the same T2 figure.

## Status

The progress measure and the fuel figure are landed here. `buildTableau_isSome` — the composition
of the two dimensions above into "expansion terminates at `soundFuel'`" — is the remaining T3
obligation; see the plan's Phase 4.3 note for its precise shape and prerequisites.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-! ## The progress measure in cardinality form -/

/--
**T3's step.** An extending expansion strictly grows the branch as a set.

This is `expandOnceUnblocked_adds_new` in the form an induction on a finite universe can consume:
a strictly increasing `Finset` cardinality bounded above by `|U|` admits at most `|U|` steps,
whereas the list-length form admits arbitrarily many.
-/
theorem expandOnceUnblocked_card_lt {b nb : Branch} {ord : TimeOrdering}
    {fc : ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    b.toFinset.card < nb.toFinset.card := by
  obtain ⟨hsub, g, hg, hgb⟩ := expandOnceUnblocked_adds_new h
  refine Finset.card_lt_card ⟨?_, ?_⟩
  · intro x hx
    exact List.mem_toFinset.mpr (hsub (List.mem_toFinset.mp hx))
  · intro hcon
    exact hgb (List.mem_toFinset.mp (hcon (List.mem_toFinset.mpr hg)))

/--
The step count out of `b` inside a universe `U` is bounded by `|U| - |b|`.

Stated as the single inequality the induction needs: an extending step both grows the branch and
keeps it inside `U`, so its cardinality is squeezed.
-/
theorem card_le_of_subset_universe {nb : Branch} {U : Finset SignedFormula}
    (hU : ∀ x ∈ nb, x ∈ U) : nb.toFinset.card ≤ U.card :=
  Finset.card_le_card (fun x hx => hU x (List.mem_toFinset.mp hx))

/-! ## The fuel figure -/

/--
The uncapped fuel figure, tied to the T2 bound.

`soundFuel` (`Saturation.lean`) is the *runtime* default and is deliberately capped at `100000`,
because blocking fires far earlier in practice and an uncapped exponential would make `#eval`
rows unusable. That cap is exactly what stops it from being a justified bound: a quadratic
constant cannot cover an exponential step count. `soundFuel'` removes the cap and multiplies the
two dimensions the module docstring names — at most `2 * n` signed formulas per time, and at most
`2 ^ (2 * n)` distinguishable times, with `n = |subformulaClosure φ|`.

The figure is *stated* here; the theorem that expansion cannot exhaust it
(`buildTableau_isSome`) is the remaining T3 obligation and is not claimed by this definition.
-/
def soundFuel' (φ : Formula) : Nat :=
  let n := (FormalSystem.Syntax.subformulaClosure φ).card
  2 * n * 2 ^ (2 * n)

/--
The uncapped figure dominates the capped runtime default, so keeping `soundFuel` as the `#eval`
default (plan constraint 11) never runs the engine *past* the justified bound — it only ever
stops earlier.
-/
theorem soundFuel_le_soundFuel' (φ : Formula) : soundFuel φ ≤ soundFuel' φ := by
  set n := (FormalSystem.Syntax.subformulaClosure φ).card with hn
  have hp : 2 ^ n ≤ 2 ^ (2 * n) := Nat.pow_le_pow_right (by omega) (by omega)
  have hmul : n * 2 ^ n ≤ 2 * n * 2 ^ (2 * n) :=
    le_trans (Nat.mul_le_mul_left n hp) (Nat.mul_le_mul_right _ (by omega))
  simpa [soundFuel, soundFuel', ← hn] using le_trans (min_le_left _ 100000) hmul

end FormalSystem.Metalogic.Decidability
