/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.CountermodelExtraction
import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel

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

/-! ## `BoxContextClosed` is the wrong invariant, and this is why

`BoxContextClosed` was named as the residual on the strength of `boxDiamondPersistence`
(`Tableau.lean:434`). Reading the six call sites settles that it is **not** what the construction
maintains, on two independent counts. Both are recorded below as theorems about the engine's own
definitions rather than as prose.

1. *Time-minting copies the box context only at one world-time.* Every call site passes
   `boxDiamondPersistence branch l.world l.time freshTime`, and that function reads
   `branch.boxPosAtWorldTime l.world l.time` — the `T(□B)` sitting at the *triggering* label, not
   at every label. A `T(□φ)` at a different world is not copied to the fresh time.
2. *World-minting does not copy box formulas at all — it copies their contents.* `boxNeg` and
   `diamondPos` (`Tableau.lean:535`, `:577`) run `branch.boxPosFormulas.filterMap` with the arm
   `| .box inner => SignedFormula.pos inner { world := freshWorld, time := bsf.label.time }`, so
   the fresh world receives `T(B)`, never `T(□B)`. `BoxContextClosed` therefore fails at the
   first minted world whenever any `T(□φ)` is on the branch — which is exactly the case it was
   introduced to serve.

Nor does saturation repair the gap: the fresh-label rules are suppressed by `witnessPresent`
(`Tableau.lean:1670`), whose test for `boxNeg`/`diamondPos` is the *witness* alone — `F(ψ)` (resp.
`T(ψ)`) at some known world. The auto-propagation outputs are outside the test, so a saturated
branch is under no obligation to carry them.

What the truth lemma actually needs is not `T(□φ)` everywhere but `T(φ)` everywhere, and the
weakest branch fact that delivers it — given saturation, which already supplies `boxPos`,
`boxTemporal`, `allFuturePos` and `allPastPos` — is that the *temporal* consequences of a box
formula are present at every known world at the box formula's own time. That is
`BoxTemporalSpread`, and it is strictly weaker than `BoxContextClosed`
(`boxTemporalSpread_of_boxContextClosed`).
-/

/-- Membership in `knownWorlds` for any formula on the branch. -/
theorem mem_knownWorlds_of_mem {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.world ∈ b.knownWorlds := by
  simp only [Branch.knownWorlds, List.mem_eraseDups]
  exact List.mem_map_of_mem h

/-- Membership in `knownTimes` for any formula on the branch. -/
theorem mem_knownTimes_of_mem {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.time ∈ b.knownTimes := by
  simp only [Branch.knownTimes, List.mem_eraseDups]
  exact List.mem_map_of_mem h

/-! ## The invariant the construction really maintains -/

/--
**The temporal spread of a box formula across worlds.** `T(□φ)` anywhere puts `T(Gφ)` and `T(Hφ)`
at *every known world*, at the box formula's own time.

This is what `boxNeg`/`diamondPos` do maintain: minting a world copies
`branch.allFuturePosAtTime l.time` and `branch.allPastPosAtTime l.time` — the `T(G·)` and `T(H·)`
formulas at the triggering time, **at every world** — onto the fresh world
(`Tableau.lean:553-559`). Combined with `boxTemporal`, which turns `T(□φ)` into exactly those two
formulas, it is the invariant form of "the box context follows the label".

It is strictly weaker than `BoxContextClosed`, and — unlike it — it is enough.
-/
def BoxTemporalSpread (b : Branch) : Prop :=
  ∀ (φ : Formula) (l : Label), (⟨.pos, .box φ, l⟩ : SignedFormula) ∈ b →
    ∀ w' ∈ b.knownWorlds,
      (⟨.pos, Formula.allFuture φ, ⟨w', l.time⟩⟩ : SignedFormula) ∈ b ∧
      (⟨.pos, Formula.allPast φ, ⟨w', l.time⟩⟩ : SignedFormula) ∈ b

/--
**Nothing is lost by the weakening.** On a saturated branch `BoxContextClosed` implies
`BoxTemporalSpread`: transport the box formula to `(w', l.time)` and run `boxTemporal` there.
-/
theorem boxTemporalSpread_of_boxContextClosed (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none) (hBC : BoxContextClosed b) :
    BoxTemporalSpread b := by
  intro φ l hmem w' hw'
  have hl : l.time ∈ b.knownTimes := mem_knownTimes_of_mem hmem
  have hbox : (⟨.pos, .box φ, ⟨w', l.time⟩⟩ : SignedFormula) ∈ b := hBC φ l hmem w' hw' l.time hl
  exact sat_box_temporal b timeOrd hSat φ ⟨w', l.time⟩ hbox

/-! ## Totality of the induced ordering, in both directions

`Saturation.timeOrderTotal` compares two known times using `futureOf` **only**: `t₁ = t₂`, or
`t₂ ∈ futureOf t₁`, or `t₁ ∈ futureOf t₂`. `sat_all_past_pos` consumes `pastOf`. Bridging the two
needs the converse law for the transitive closures, which is `TimeOrderConverse` below.

At the one-step level the converse is immediate and is proved here: `directFutureOf` and
`directPastOf` are the two projections of the *same* constraint list
(`mem_directFutureOf_iff_mem_constraints` / `mem_directPastOf_iff_mem_constraints`). Lifting it
through `reachableForward`/`reachableBackward` is a fuel-bounded breadth-first-search duality —
forward and backward shortest-path depths agree, so equal fuel suffices.

**That lifting is done, and `TimeOrderConverse` is no longer an assumption.** It is not proved
again here: `Verified/Termination/Fuel.lean` already carries it as `orderDual_holds`, for *every*
`TimeOrdering`, via the `open private reachableForward reachableBackward` route plus the shared
breadth-first shape `bfsClosure` (`bfsClosure_sound` for the forward half, `PathN.reverse` for the
edge-by-edge reversal, `bfsClosure_complete` and the `BfsInv` visited-set invariant for the
backward half). `OrderDual` and `TimeOrderConverse` are the same statement, so `timeOrderConverse`
below is a rename, and the consumers' `hConv` hypotheses are now dischargeable at every call site.
The two names are kept apart because the fuel module reaches the closure duality for a termination
purpose (`timeChain_of_linearity_saturated`) that has nothing to do with the box grid.
-/

theorem mem_directFutureOf_iff_mem_constraints (ord : TimeOrdering) (t t' : TimeIndex) :
    t' ∈ ord.directFutureOf t ↔ (t, t') ∈ ord.constraints := by
  simp only [TimeOrdering.directFutureOf, List.mem_filterMap]
  constructor
  · rintro ⟨⟨a, c⟩, hmem, heq⟩
    split at heq
    · next h =>
      have hc : c = t' := Option.some_inj.mp heq
      have ha : a = t := by simpa using h
      subst hc; subst ha; exact hmem
    · exact absurd heq (by simp)
  · intro h
    exact ⟨(t, t'), h, by simp⟩

theorem mem_directPastOf_iff_mem_constraints (ord : TimeOrdering) (t t' : TimeIndex) :
    t ∈ ord.directPastOf t' ↔ (t, t') ∈ ord.constraints := by
  simp only [TimeOrdering.directPastOf, List.mem_filterMap]
  constructor
  · rintro ⟨⟨a, c⟩, hmem, heq⟩
    split at heq
    · next h =>
      have ha : a = t := Option.some_inj.mp heq
      have hc : c = t' := by simpa using h
      subst ha; subst hc; exact hmem
    · exact absurd heq (by simp)
  · intro h
    exact ⟨(t, t'), h, by simp⟩

/-- **The one-step converse.** `t'` is an immediate successor of `t` exactly when `t` is an
immediate predecessor of `t'`; both say the constraint list carries the edge `(t, t')`. -/
theorem mem_directFutureOf_iff_mem_directPastOf (ord : TimeOrdering) (t t' : TimeIndex) :
    t' ∈ ord.directFutureOf t ↔ t ∈ ord.directPastOf t' := by
  rw [mem_directFutureOf_iff_mem_constraints, mem_directPastOf_iff_mem_constraints]

/--
**The converse law for the transitive closures.** True of every ordering the engine builds — the
two closures are breadth-first searches of one edge set in opposite directions, with the same fuel
bound — and named here because `timeOrderTotal` speaks only of `futureOf` while `sat_all_past_pos`
consumes `pastOf`.
-/
def TimeOrderConverse (ord : TimeOrdering) : Prop :=
  ∀ t t' : TimeIndex, t' ∈ ord.futureOf t → t ∈ ord.pastOf t'

/--
**The converse law holds, for every ordering** — so no consumer below is really hypothetical.

`OrderDual` (`Verified/Termination/Fuel.lean`) is this statement under another name, discharged
there for every `TimeOrdering`; this is the rename that lets the box-grid consumers apply it.
Anything carrying `TimeOrderConverse timeOrd` as a hypothesis may now be fed `timeOrderConverse
timeOrd` outright.
-/
theorem timeOrderConverse (ord : TimeOrdering) : TimeOrderConverse ord :=
  fun t t' h => orderDual_holds ord t t' h

/--
**Trichotomy at a fixed time.** Every known time is the given one, strictly after it, or strictly
before it — the form the grid argument consumes, with `pastOf` in place of the reversed `futureOf`
that `timeOrderTotal` records.
-/
theorem knownTime_trichotomy {b : Branch} {timeOrd : TimeOrdering}
    (hTot : timeOrderTotal b timeOrd = true) (hConv : TimeOrderConverse timeOrd)
    {t : TimeIndex} (ht : t ∈ b.knownTimes) {t' : TimeIndex} (ht' : t' ∈ b.knownTimes) :
    t' = t ∨ t' ∈ timeOrd.futureOf t ∨ t' ∈ timeOrd.pastOf t := by
  have h := (List.all_eq_true.mp hTot) t ht
  have h2 := (List.all_eq_true.mp h) t' ht'
  simp only [Bool.or_eq_true, beq_iff_eq, List.contains_iff_mem] at h2
  rcases h2 with (heq | hf) | hb
  · exact Or.inl heq.symm
  · exact Or.inr (Or.inl hf)
  · exact Or.inr (Or.inr (hConv t' t hb))

/-! ## The grid, from the corrected invariant -/

/--
**`T(□φ)` reaches every known label** — the exact hypothesis `truthAt_box_iff_base` consumes, and
the replacement for `sat_box_all_labels` that rests on an invariant the construction can actually
supply.

The three cases of `knownTime_trichotomy`, at an arbitrary known world `w'`:

* `t' = t` — `boxPos` at the box formula's own label already reaches every known world.
* `t' ∈ futureOf t` — `BoxTemporalSpread` puts `T(Gφ) @ (w', t)` on the branch, and
  `sat_all_future_pos` discharges it at `t'`.
* `t' ∈ pastOf t` — the mirror, through `T(Hφ) @ (w', t)` and `sat_all_past_pos`.

Note that no case needs `T(□φ)` anywhere other than where it was found.
-/
theorem sat_box_grid (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (hTot : timeOrderTotal b timeOrd = true) (hConv : TimeOrderConverse timeOrd)
    (hBTS : BoxTemporalSpread b)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : (⟨.pos, .box φ, ⟨w, t⟩⟩ : SignedFormula) ∈ b) :
    ∀ w' ∈ b.knownWorlds, ∀ t' ∈ b.knownTimes, (⟨.pos, φ, ⟨w', t'⟩⟩ : SignedFormula) ∈ b := by
  intro w' hw' t' ht'
  have ht : t ∈ b.knownTimes := mem_knownTimes_of_mem hmem
  obtain ⟨hG, hH⟩ := hBTS φ ⟨w, t⟩ hmem w' hw'
  rcases knownTime_trichotomy hTot hConv ht ht' with heq | hfut | hpast
  · rw [heq]
    exact sat_box_pos b timeOrd hSat φ w t hmem w' hw'
  · exact sat_all_future_pos b timeOrd hSat φ w' t hG t' hfut
  · exact sat_all_past_pos b timeOrd hSat φ w' t hH t' hpast

end FormalSystem.Metalogic.Decidability.Verified.Bridge
