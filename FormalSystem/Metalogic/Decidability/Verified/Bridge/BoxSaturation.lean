/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.CountermodelExtraction

/-!
# O3: the modal-temporal saturation facts

`CountermodelExtraction.lean` supplies `sat_box_pos`: `T(□φ) @ (w,t)` on a saturated branch puts
`T(φ)` at `(w', t)` for **every known world** `w'`, at the *same* time. The `box` case of the truth
lemma needs more than that, because `truthAt_box_iff_base` (`Bridge/Omega.lean`) makes `□` the
universal modality over *both* coordinates: every world **and** every point of the carrier.

This file adds the three facts that the same saturation hypothesis does yield, kept in a separate
module because each unfolds `applyRule` and so forces the whole `allRulesForFC` table to reduce —
the reason `sat_box_pos` carries `maxHeartbeats 1600000`. Isolating them means a heartbeat or
memory failure here cannot take down `Bridge/Valuation.lean` or anything else already green.

* `sat_box_temporal` — `T(□φ) @ l` puts `T(G φ) @ l` and `T(H φ) @ l` on the branch. This is the
  `boxTemporal` rule (`Tableau.lean:635`), sound by `boxToFuture`/`boxToPast`, and it is the
  lemma the Phase 7 handoff names as missing.
* `sat_all_future_pos` / `sat_all_past_pos` — `T(G φ) @ (w,t)` puts `T(φ)` at every `t'` in
  `timeOrd.futureOf t`, and dually for `H`.
* `sat_box_cross` — the composition: `T(□φ) @ (w,t)` reaches every label that differs from `(w,t)`
  in **at most one** coordinate.

## What is still missing, stated exactly

`sat_box_cross` is a *cross*, not a grid. It does not reach a label `(w', t')` differing in both
coordinates, and no strengthening of the saturation hypothesis will make it: `boxPos` emits
`T(φ)`, never `T(□φ)`, so there is nothing at `(w', t)` to run `boxTemporal` on.

The engine nevertheless closes `□p → □Gp`, `□p → □□p`, `□p → G□p` and `□p → ¬◇F¬p`, and the
mechanism is visible in `Tableau.lean`: the label-minting rules copy the box/diamond context to
the label they mint (`boxDiamondPersistence`, `Tableau.lean:434`, which appears in the output of
six rules). So "`T(□φ)` is present at every known label" is a **branch invariant established at
rule-application time**, not a consequence of `findUnexpanded = none`. `BoxContextClosed` below
names that invariant; discharging it is an induction over tableau construction, not over the rule
table, and it is the form the truth lemma's `box` case should consume.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

/-! ## Local copies of the saturation plumbing

`CountermodelExtraction.lean`'s versions are `private`. Restated here rather than de-privatised
there, so that this module is additive and the engine-adjacent file is untouched.
-/

/-- `findUnexpanded b = none` says every formula on `b` is expanded. -/
private theorem all_expanded_of_saturated (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none) :
    ∀ sf ∈ b, isExpanded sf b (timeOrd := timeOrd) = true := by
  intro sf hsf
  unfold findUnexpanded at hSat
  have h := List.find?_eq_none.mp hSat sf hsf
  simp only [Bool.not_eq_true, Bool.decide_eq_false, Bool.not_eq_eq_eq_not, Bool.not_true,
    Bool.not_eq_false] at h
  exact h

private theorem mem_iff_contains (b : Branch) (sf : SignedFormula) :
    Branch.contains b sf = true ↔ sf ∈ b := by
  simp only [Branch.contains, List.any_eq_true]
  constructor
  · rintro ⟨x, hx, heq⟩
    exact beq_iff_eq.mp heq ▸ hx
  · intro h
    exact ⟨sf, h, beq_self_eq_true _⟩

/-! ## The modal-temporal interaction rule -/

set_option maxHeartbeats 1600000 in
/--
**Box-temporal saturation.** `T(□φ)` at a label on a saturated branch puts `T(G φ)` and `T(H φ)`
at that same label.

`boxTemporal` is persistent and emits `[T(Gφ), T(Hφ)]` filtered against the branch, returning
`.notApplicable` exactly when nothing new remains — so on a saturated branch both conclusions are
already present. Sound by `boxToFuture` (`□φ → Gφ`) and `boxToPast` (`□φ → Hφ`).
-/
theorem sat_box_temporal (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (φ : Formula) (l : Label) (hmem : ⟨.pos, .box φ, l⟩ ∈ b) :
    ⟨.pos, Formula.allFuture φ, l⟩ ∈ b ∧ ⟨.pos, Formula.allPast φ, l⟩ ∈ b := by
  have hExp := all_expanded_of_saturated b timeOrd hSat ⟨.pos, .box φ, l⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have h := hExp .boxTemporal (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  simp only [isApplicable, applyRule] at h
  simp only [ite_true] at h
  by_cases hg : Branch.contains b (SignedFormula.pos (Formula.allFuture φ) l) = true
  · by_cases hh : Branch.contains b (SignedFormula.pos (Formula.allPast φ) l) = true
    · exact ⟨(mem_iff_contains b _).mp hg, (mem_iff_contains b _).mp hh⟩
    · exfalso
      simp [hg, hh] at h
  · exfalso
    simp [hg] at h

/-! ## The temporal universals -/

set_option maxHeartbeats 1600000 in
/--
**`G` positive saturation.** `T(G φ) @ (w,t)` on a saturated branch puts `T(φ)` at `(w, t')` for
every `t'` the ordering records as future of `t`.
-/
theorem sat_all_future_pos (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, Formula.allFuture φ, ⟨w, t⟩⟩ ∈ b) :
    ∀ t' ∈ timeOrd.futureOf t, ⟨.pos, φ, ⟨w, t'⟩⟩ ∈ b := by
  have hExp := all_expanded_of_saturated b timeOrd hSat ⟨.pos, Formula.allFuture φ, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have h := hExp .allFuturePos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  simp only [Formula.allFuture, Formula.someFuture, Formula.neg, Formula.top, isApplicable,
    applyRule] at h
  simp only [ite_true] at h
  set fm := (timeOrd.futureOf t).filterMap fun t' =>
    if Branch.contains b (SignedFormula.pos φ { world := w, time := t' }) = true then none
    else some (SignedFormula.pos φ { world := w, time := t' }) with hfm_def
  by_cases hfm : fm.isEmpty
  · intro t' ht'
    by_contra habs
    have hNot : Branch.contains b ⟨.pos, φ, ⟨w, t'⟩⟩ = false := by
      simp only [Bool.eq_false_iff]
      exact fun hc => habs ((mem_iff_contains b _).mp hc)
    have hmem_fm : SignedFormula.pos φ ⟨w, t'⟩ ∈ fm := by
      rw [hfm_def, List.mem_filterMap]
      exact ⟨t', ht', by simp [SignedFormula.pos, hNot]⟩
    rw [List.isEmpty_iff.mp hfm] at hmem_fm
    exact absurd hmem_fm (by simp)
  · exfalso
    simp [hfm] at h

set_option maxHeartbeats 1600000 in
/-- **`H` positive saturation**, the mirror image of `sat_all_future_pos`. -/
theorem sat_all_past_pos (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, Formula.allPast φ, ⟨w, t⟩⟩ ∈ b) :
    ∀ t' ∈ timeOrd.pastOf t, ⟨.pos, φ, ⟨w, t'⟩⟩ ∈ b := by
  have hExp := all_expanded_of_saturated b timeOrd hSat ⟨.pos, Formula.allPast φ, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have h := hExp .allPastPos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  simp only [Formula.allPast, Formula.somePast, Formula.neg, Formula.top, isApplicable,
    applyRule] at h
  simp only [ite_true] at h
  set fm := (timeOrd.pastOf t).filterMap fun t' =>
    if Branch.contains b (SignedFormula.pos φ { world := w, time := t' }) = true then none
    else some (SignedFormula.pos φ { world := w, time := t' }) with hfm_def
  by_cases hfm : fm.isEmpty
  · intro t' ht'
    by_contra habs
    have hNot : Branch.contains b ⟨.pos, φ, ⟨w, t'⟩⟩ = false := by
      simp only [Bool.eq_false_iff]
      exact fun hc => habs ((mem_iff_contains b _).mp hc)
    have hmem_fm : SignedFormula.pos φ ⟨w, t'⟩ ∈ fm := by
      rw [hfm_def, List.mem_filterMap]
      exact ⟨t', ht', by simp [SignedFormula.pos, hNot]⟩
    rw [List.isEmpty_iff.mp hfm] at hmem_fm
    exact absurd hmem_fm (by simp)
  · exfalso
    simp [hfm] at h

/-! ## The composition, and the residual invariant -/

/--
**`T(□φ)` reaches the whole cross through its label.** Every label differing from `(w,t)` in at
most one coordinate carries `T(φ)`: the other worlds at time `t` by `sat_box_pos`, the other
times in world `w` by `sat_box_temporal` followed by `sat_all_future_pos`/`sat_all_past_pos`.
-/
theorem sat_box_cross (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .box φ, ⟨w, t⟩⟩ ∈ b) :
    (∀ w' ∈ b.knownWorlds, ⟨.pos, φ, ⟨w', t⟩⟩ ∈ b) ∧
      (∀ t' ∈ timeOrd.futureOf t, ⟨.pos, φ, ⟨w, t'⟩⟩ ∈ b) ∧
      (∀ t' ∈ timeOrd.pastOf t, ⟨.pos, φ, ⟨w, t'⟩⟩ ∈ b) := by
  obtain ⟨hG, hH⟩ := sat_box_temporal b timeOrd hSat φ ⟨w, t⟩ hmem
  exact ⟨sat_box_pos b timeOrd hSat φ w t hmem,
    sat_all_future_pos b timeOrd hSat φ w t hG,
    sat_all_past_pos b timeOrd hSat φ w t hH⟩

/--
**The residual invariant, named.** The truth lemma's `box` case needs `T(□φ)` at *every* known
label, not merely at the one it was found on — that is what turns `sat_box_cross` from a cross
into the full grid, via one further application of `sat_box_pos` at each time.

It is not a saturation fact. `boxPos` emits `T(φ)`, never `T(□φ)`, so no rule table argument can
produce it. It is established when labels are *minted*: `boxDiamondPersistence`
(`Tableau.lean:434`) copies the world's box/diamond context onto every freshly minted time, and
the world-minting rules copy it onto every freshly minted world. Discharging `BoxContextClosed`
is therefore an induction over tableau construction.
-/
def BoxContextClosed (b : Branch) : Prop :=
  ∀ (φ : Formula) (l : Label), (⟨.pos, .box φ, l⟩ : SignedFormula) ∈ b →
    ∀ w' ∈ b.knownWorlds, ∀ t' ∈ b.knownTimes, (⟨.pos, .box φ, ⟨w', t'⟩⟩ : SignedFormula) ∈ b

/--
**The grid, from the cross plus the invariant.** With `BoxContextClosed` in hand, `T(□φ)`
anywhere puts `T(φ)` at every known label — the exact hypothesis
`truthAt_box_iff_base` consumes.
-/
theorem sat_box_all_labels (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none) (hBC : BoxContextClosed b)
    (φ : Formula) (l : Label) (hmem : ⟨.pos, .box φ, l⟩ ∈ b) :
    ∀ w' ∈ b.knownWorlds, ∀ t' ∈ b.knownTimes, (⟨.pos, φ, ⟨w', t'⟩⟩ : SignedFormula) ∈ b := by
  intro w' hw' t' ht'
  have hbox : (⟨.pos, .box φ, ⟨w', t'⟩⟩ : SignedFormula) ∈ b := hBC φ l hmem w' hw' t' ht'
  exact sat_box_pos b timeOrd hSat φ w' t' hbox w' hw'

end FormalSystem.Metalogic.Decidability.Verified.Bridge
