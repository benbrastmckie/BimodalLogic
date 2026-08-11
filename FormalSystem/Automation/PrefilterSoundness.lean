/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.DatasetGenerator
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity

/-!
# PrefilterSoundness: Soundness Proofs for Invalid Pattern Recognizers

This module provides formal soundness proofs for each invalid-pattern recognizer
function defined in `DatasetGenerator.lean`. These proofs establish
that the structural invalid prefilter is sound: if it labels a formula as invalid,
then the formula is indeed not valid in the TM logic.

## Main Results

- `isUnsatBotTemporal_not_truth`: If `isUnsatBotTemporal φ = true`, then `φ` is false
  at every world/time whose evaluation history is total.
- `unfulfillable_until_not_truth`: If `G(¬event)` holds at time t, then
  `U(event, guard)` is false at time t.
- `unfulfillable_since_not_truth`: If `H(¬event)` holds at time t, then
  `S(event, guard)` is false at time t.

## Design Notes

The soundness proofs focus on the semantic level: they show that the detected
patterns correspond to formulas that evaluate to False at specific model points.
Combined with the observation that non-trivially-false antecedents admit models
where they are true, this establishes invalidity (the negation of universal
validity).

The `box` case in `isUnsatBotTemporal` requires `τ.IsTotal` so that the box
quantifier — which under `def:BL-semantics` ranges over the total histories
`H_F` — is instantiable at the evaluation history itself. This is automatically
satisfied in the validity definition, where `τ.IsTotal` is a premise.

No declaration in this module carries an admissible-history (`Ω`) parameter or a
`ShiftClosed` hypothesis. `TruthAt`'s remaining set argument is inert (see
`truthAt_carrier_irrelevant` in `Semantics/Validity.lean`) and is supplied here as
`Set.univ`, matching `valid`'s own call shape; it is scheduled for deletion outright.
-/

set_option autoImplicit false

namespace FormalSystem.Automation.PrefilterSoundness

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Automation

/-!
## Core Lemma: isUnsatBotTemporal implies falsity

The key soundness lemma: any formula recognized as "always false" by
`isUnsatBotTemporal` is indeed false at every evaluation point, provided
the evaluation history is total (needed for the box case).
-/

/--
If `isUnsatBotTemporal φ = true`, then `φ` evaluates to `False` at every
model point `(M, τ, t)` where `τ` is total.

This is the core soundness lemma for the invalid prefilter. It establishes
that `isUnsatBotTemporal` is a sound "always false" recognizer.

Proof by structural induction on `φ`:
- `bot`: `TruthAt` for `bot` is `False` by definition.
- `untl event guard`: If `isUnsatBotTemporal event = true`, then by IH,
  `event` is false at all times. But `U(event, guard)` requires `∃ s > t,
  TruthAt ... s event`, which is impossible.
- `snce event guard`: Symmetric to Until.
- `box a`: If `isUnsatBotTemporal a = true`, then by IH, `a` is false
  at every model point whose history is total. Since `τ` is total
  and `box(a)` requires `∀ σ, σ.IsTotal → TruthAt ... σ t a`, choosing
  `σ = τ` gives `TruthAt ... τ t a`, which contradicts the IH.
-/
theorem isUnsatBotTemporal_not_truth
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F}
    {τ : WorldHistory F} (hτ : τ.IsTotal) {t : D}
    {φ : Formula} (h : isUnsatBotTemporal φ = true) :
    ¬ TruthAt M Set.univ τ t φ := by
  induction φ generalizing τ t with
  | bot => exact Truth.bot_false Set.univ
  | untl event guard ih_event _ih_guard =>
    simp only [isUnsatBotTemporal] at h
    intro ⟨s, _hts, h_event, _h_guard⟩
    exact ih_event hτ h h_event
  | snce event guard ih_event _ih_guard =>
    simp only [isUnsatBotTemporal] at h
    intro ⟨s, _hst, h_event, _h_guard⟩
    exact ih_event hτ h h_event
  | box a ih_a =>
    simp only [isUnsatBotTemporal] at h
    intro h_box
    exact ih_a hτ h (h_box τ hτ)
  | atom _ => simp [isUnsatBotTemporal] at h
  | imp _ _ => simp [isUnsatBotTemporal] at h

/-!
## Unfulfillable Eventuality Lemma

If `G(¬event)` holds at time t (event is never true in the future), then
`U(event, guard)` is false at time t. This establishes soundness of
`hasUnfulfillableEventuality` for the Until case.
-/

/--
If `G(¬event)` holds at time t, then `U(event, guard)` is false at time t.

`G(¬event) = (¬event).allFuture` means `∀ s > t, ¬event(s)`.
`U(event, guard)` requires `∃ s > t, event(s)`. These are contradictory.
-/
theorem unfulfillable_until_not_truth
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F}
    {τ : WorldHistory F} {t : D}
    {event guard : Formula}
    (h_g_neg : TruthAt M Set.univ τ t (Formula.allFuture event.neg)) :
    ¬ TruthAt M Set.univ τ t (Formula.untl event guard) := by
  rw [Truth.future_iff] at h_g_neg
  intro ⟨s, hts, h_event_s, _h_guard⟩
  have h_neg_event_s := h_g_neg s hts
  -- h_neg_event_s : TruthAt M Set.univ τ s event.neg = (TruthAt ... event → False)
  exact h_neg_event_s h_event_s

/--
If `H(¬event)` holds at time t, then `S(event, guard)` is false at time t.
Symmetric past version of `unfulfillable_until_not_truth`.

`H(¬event) = (¬event).allPast` means `∀ s < t, ¬event(s)`.
`S(event, guard)` requires `∃ s < t, event(s)`. These are contradictory.
-/
theorem unfulfillable_since_not_truth
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F}
    {τ : WorldHistory F} {t : D}
    {event guard : Formula}
    (h_h_neg : TruthAt M Set.univ τ t (Formula.allPast event.neg)) :
    ¬ TruthAt M Set.univ τ t (Formula.snce event guard) := by
  rw [Truth.past_iff] at h_h_neg
  intro ⟨s, hst, h_event_s, _h_guard⟩
  have h_neg_event_s := h_h_neg s hst
  exact h_neg_event_s h_event_s

/-!
## False Consequent Invalidity

If the consequent of an implication is always false, the implication fails
at any model point where the antecedent is true. This is the semantic
foundation for the `invalid_false_consequent` pattern.
-/

/--
If `φ` is always false (at points where `τ` is total), then `antecedent → φ`
is false at any point where `antecedent` is true.

This is immediate: `antecedent → φ` evaluated as `TruthAt ... antecedent →
TruthAt ... φ`, so if `antecedent` is true and `φ` is false, the implication
is false.
-/
theorem false_consequent_not_truth
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F}
    {τ : WorldHistory F} (hτ : τ.IsTotal) {t : D}
    {antecedent consequent : Formula}
    (h_false : isUnsatBotTemporal consequent = true)
    (h_ante_true : TruthAt M Set.univ τ t antecedent) :
    ¬ TruthAt M Set.univ τ t (Formula.imp antecedent consequent) := by
  intro h_imp
  have h_conseq := h_imp h_ante_true
  exact isUnsatBotTemporal_not_truth hτ h_false h_conseq

end FormalSystem.Automation.PrefilterSoundness
