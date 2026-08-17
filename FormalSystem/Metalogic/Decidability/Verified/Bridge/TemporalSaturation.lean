/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.BranchOrder
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation

/-!
# The positive temporal witnesses, with their position kept

`CountermodelExtraction.lean`'s `sat_untl_pos` concludes

```
∃ t' ∈ b.knownTimes, T(event) @ (w,t') ∨ (T(guard) @ (w,t') ∧ T(U(event,guard)) @ (w,t'))
```

and says **nothing about where `t'` sits relative to `t`**. The truth lemma's `untl` case cannot
use that: `TruthAt … (untl φ ψ)` demands a witness strictly *after* the evaluation point, so a
witness with no recorded position is no witness at all.

The position is not missing from the argument — it is discarded from the statement. `untlPos`
mints a fresh time and is therefore suppressed only when `witnessPresent` finds one, and
`witnessPresent .untlPos` scans `timeOrd.futureOf l.time`. The existing proof obtains exactly
`⟨t', ht', hcont⟩` from that scan and then binds `ht'` to `_`, replacing it with the weaker
`mem_knownTimes_of_mem`. The two lemmas here are that same proof with `ht'` kept and reported as
`strictBefore` — the bridge's own order primitive, which is `futureOf` read as a relation
(`Bridge/BranchOrder.lean`), so no translation step is involved.

They live here rather than in `CountermodelExtraction.lean` for the reason `Bridge/
PropSaturation.lean` gives for `sat_imp_pos`: both unfold `applyRule` and so force the whole
`allRulesForFC` table to reduce, which is why they carry a raised heartbeat budget. Isolating
them keeps that budget off the engine file.

**Note on `mem_knownTimes_of_mem`.** The membership `t' ∈ b.knownTimes` is still derived from the
witness formula's own label, not from `futureOf`: `futureOf` is a closure over the *ordering*
constraints and can name a time no branch formula mentions, so the two facts are independent and
both are reported.
-/

set_option maxHeartbeats 1600000

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

/-- `findUnexpanded b = none` says every formula on `b` is expanded.

`CountermodelExtraction.lean` and `Bridge/BoxSaturation.lean` each carry this three-line unfolding
as a `private` helper; a third copy is the established precedent here rather than a promotion,
since promoting it would move a declaration on the engine file. -/
private theorem all_expanded_of_saturated (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none) :
    ∀ sf ∈ b, isExpanded sf b (timeOrd := timeOrd) = true := by
  intro sf hsf
  unfold findUnexpanded at hSat
  have h := List.find?_eq_none.mp hSat sf hsf
  simp only [Bool.not_eq_true, Bool.decide_eq_false, Bool.not_eq_eq_eq_not, Bool.not_true,
    Bool.not_eq_false] at h
  exact h

/-- `futureOf` membership, as the bridge's order primitive. -/
theorem strictBefore_of_mem_futureOf {ord : TimeOrdering} {t t' : TimeIndex}
    (h : t' ∈ ord.futureOf t) : strictBefore ord t t' = true := by
  simp [strictBefore, h]

/--
**The converse of `orderDual_holds`.** `Verified/Termination/Fuel.lean` proves
`t₂ ∈ futureOf t₁ → t₁ ∈ pastOf t₂` for every ordering; the `snce` witness arrives in the other
form, and the same three steps prove it — backward BFS soundness gives a constraint path,
`PathN.reverse` against the converse of `mem_directFutureOf_iff` turns it round, and forward BFS
at the same fuel finds it.
-/
theorem orderDual_converse (ord : TimeOrdering) {t₁ t₂ : TimeIndex}
    (h : t₁ ∈ ord.pastOf t₂) : t₂ ∈ ord.futureOf t₁ := by
  rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [t₂] [] h with hv | ⟨s, hs, n, hn1, hn2, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hs
    subst hs
    rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq]
    exact TimeOrdering.bfsClosure_complete _
      (TimeOrdering.PathN.reverse
        (fun x y => (TimeOrdering.mem_directFutureOf_iff ord y x).symm) hp) hn1 hn2

/-- `pastOf` membership, as the bridge's order primitive. -/
theorem strictBefore_of_mem_pastOf {ord : TimeOrdering} {t t' : TimeIndex}
    (h : t ∈ ord.pastOf t') : strictBefore ord t t' = true :=
  strictBefore_of_mem_futureOf (orderDual_converse ord h)

/--
**Until positive saturation, with the witness's position kept.**

`sat_untl_pos` strengthened by the one fact its own proof already has: the witness lies strictly
after the until's own time in the branch's order.

**The ordered-witness disjunct.** Suppression is `witnessPresent … || trivialEventWitnessed …`
(`Tableau.lean:1956-1957`, `:1980-1981`). The second disjunct fires on exactly one trigger shape,
`untl ⊤ ⊤` (that is, `F ⊤`), and on it the test consults the *ordering* alone: an already-ordered
strictly-later time discharges the obligation because `⊤` holds there, so no witness formula need
be on the branch. On that shape the old conclusion — a `t'` at which the event or the guard is
literally on the branch — is false, so the statement is widened rather than asserted past its
truth.

The widening is not a claim consumers cannot use. `strictBefore timeOrd t t'` is delivered in
**both** cases and so is unconditional; what the trivial case trades away is `t' ∈ b.knownTimes`
plus branch membership, in exchange for `event = ⊤`, whose semantic obligation is immediate at
every label of every model. What is lost, and deliberately so, is `t' ∈ b.knownTimes` in the
trivial case: `futureOf` is a closure over the ordering constraints and can name a time no branch
formula mentions (see the note at the head of this file), so that membership is not available
there and is not asserted.
-/
theorem sat_untl_pos_future (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .untl guard event, ⟨w, t⟩⟩ ∈ b) :
    ∃ t', strictBefore timeOrd t t' = true ∧
      ((t' ∈ b.knownTimes ∧
          ((⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
            (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .untl guard event, ⟨w, t'⟩⟩ ∈ b)))
        ∨ (event = Formula.top ∧ guard = Formula.top)) := by
  have hExp :=
    all_expanded_of_saturated b timeOrd hSat ⟨.pos, .untl guard event, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  by_cases hg : guard = Formula.top
  · subst hg
    have h := hExp .someFuturePos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .someFuturePos ⟨.pos, .untl Formula.top event, ⟨w, t⟩⟩ b timeOrd = true
        ∨ trivialEventWitnessed .someFuturePos ⟨.pos, .untl Formula.top event, ⟨w, t⟩⟩ b timeOrd
            = true := by
      by_contra hc
      rw [not_or] at hc
      obtain ⟨hc1, hc2⟩ := hc
      rw [Bool.not_eq_true] at hc1 hc2
      -- `simp` unfolds `Formula.top` inside `h`; unfold it in the refutations too so they match.
      simp only [Formula.top] at hc1 hc2
      simp [isApplicable, asSomeFuture?, Formula.top, applyRule, ruleMintsFreshLabel,
        hc1, hc2] at h
    rcases hwit with hwit | htriv
    · simp only [witnessPresent, asSomeFuture?, Formula.top, List.any_eq_true] at hwit
      obtain ⟨t', hfut, hcont⟩ := hwit
      have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains hcont
      exact ⟨t', strictBefore_of_mem_futureOf hfut,
        Or.inl ⟨mem_knownTimes_of_mem hmem', Or.inl hmem'⟩⟩
    · -- `F ⊤`: the ordering carries the witness; the branch need carry nothing.
      have hev : event = Formula.top := by
        by_contra hne
        simp [trivialEventWitnessed, hne] at htriv
      obtain ⟨t', ht'⟩ : ∃ t', t' ∈ timeOrd.futureOf t := by
        cases hfl : timeOrd.futureOf t with
        | nil => simp [trivialEventWitnessed, hfl] at htriv
        | cons a l => exact ⟨a, by simp⟩
      exact ⟨t', strictBefore_of_mem_futureOf ht', Or.inr ⟨hev, rfl⟩⟩
  · have hg' : (guard == Formula.top) = false := by simp [hg]
    have h := hExp .untlPos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    -- The genuine-Until branch: `trivialEventWitnessed` needs `guard == ⊤`, which `hg'` refutes,
    -- so the suppression test collapses back to `witnessPresent` alone.
    have htriv : trivialEventWitnessed .untlPos ⟨.pos, .untl guard event, ⟨w, t⟩⟩ b timeOrd
        = false := by simp [trivialEventWitnessed, hg']
    have hwit :
        witnessPresent .untlPos ⟨.pos, .untl guard event, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      rw [Bool.not_eq_true] at hc
      simp only [isApplicable, asUntil?, hg', applyRule, ruleMintsFreshLabel,
        ruleSelfGuarded, if_true] at h
      exact absurd h (by simp [hc, htriv])
    simp only [witnessPresent, asUntil?, hg', Bool.false_eq_true, if_false, List.any_eq_true,
      Bool.or_eq_true, Bool.and_eq_true] at hwit
    obtain ⟨t', hfut, hcont⟩ := hwit
    rcases hcont with he | ⟨hgd, hu⟩
    · have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains he
      exact ⟨t', strictBefore_of_mem_futureOf hfut,
        Or.inl ⟨mem_knownTimes_of_mem hmem', Or.inl hmem'⟩⟩
    · have hmemG : (⟨.pos, guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains hgd
      have hmemU : (⟨.pos, .untl guard event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b :=
        mem_of_branch_contains hu
      exact ⟨t', strictBefore_of_mem_futureOf hfut,
        Or.inl ⟨mem_knownTimes_of_mem hmemG, Or.inr ⟨hmemG, hmemU⟩⟩⟩

/-- **Since positive saturation, with the witness's position kept.** The past-directed mirror,
ordered-witness disjunct included; there the trigger shape is `P ⊤` (`snce ⊤ ⊤`) and the ordering
fact comes from `timeOrd.pastOf t`. -/
theorem sat_snce_pos_past (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .snce guard event, ⟨w, t⟩⟩ ∈ b) :
    ∃ t', strictBefore timeOrd t' t = true ∧
      ((t' ∈ b.knownTimes ∧
          ((⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
            (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .snce guard event, ⟨w, t'⟩⟩ ∈ b)))
        ∨ (event = Formula.top ∧ guard = Formula.top)) := by
  have hExp :=
    all_expanded_of_saturated b timeOrd hSat ⟨.pos, .snce guard event, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  by_cases hg : guard = Formula.top
  · subst hg
    have h := hExp .somePastPos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .somePastPos ⟨.pos, .snce Formula.top event, ⟨w, t⟩⟩ b timeOrd = true
        ∨ trivialEventWitnessed .somePastPos ⟨.pos, .snce Formula.top event, ⟨w, t⟩⟩ b timeOrd
            = true := by
      by_contra hc
      rw [not_or] at hc
      obtain ⟨hc1, hc2⟩ := hc
      rw [Bool.not_eq_true] at hc1 hc2
      -- `simp` unfolds `Formula.top` inside `h`; unfold it in the refutations too so they match.
      simp only [Formula.top] at hc1 hc2
      simp [isApplicable, asSomePast?, Formula.top, applyRule, ruleMintsFreshLabel,
        hc1, hc2] at h
    rcases hwit with hwit | htriv
    · simp only [witnessPresent, asSomePast?, Formula.top, List.any_eq_true] at hwit
      obtain ⟨t', hpast, hcont⟩ := hwit
      have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains hcont
      exact ⟨t', strictBefore_of_mem_pastOf hpast,
        Or.inl ⟨mem_knownTimes_of_mem hmem', Or.inl hmem'⟩⟩
    · -- `P ⊤`: the ordering carries the witness; the branch need carry nothing.
      have hev : event = Formula.top := by
        by_contra hne
        simp [trivialEventWitnessed, hne] at htriv
      obtain ⟨t', ht'⟩ : ∃ t', t' ∈ timeOrd.pastOf t := by
        cases hpl : timeOrd.pastOf t with
        | nil => simp [trivialEventWitnessed, hpl] at htriv
        | cons a l => exact ⟨a, by simp⟩
      exact ⟨t', strictBefore_of_mem_pastOf ht', Or.inr ⟨hev, rfl⟩⟩
  · have hg' : (guard == Formula.top) = false := by simp [hg]
    have h := hExp .sncePos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    -- Mirror of the `untlPos` branch: `hg'` refutes the `trivialEventWitnessed` disjunct.
    have htriv : trivialEventWitnessed .sncePos ⟨.pos, .snce guard event, ⟨w, t⟩⟩ b timeOrd
        = false := by simp [trivialEventWitnessed, hg']
    have hwit :
        witnessPresent .sncePos ⟨.pos, .snce guard event, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      rw [Bool.not_eq_true] at hc
      simp only [isApplicable, asSince?, hg', applyRule, ruleMintsFreshLabel,
        ruleSelfGuarded, if_true] at h
      exact absurd h (by simp [hc, htriv])
    simp only [witnessPresent, asSince?, hg', Bool.false_eq_true, if_false, List.any_eq_true,
      Bool.or_eq_true, Bool.and_eq_true] at hwit
    obtain ⟨t', hpast, hcont⟩ := hwit
    rcases hcont with he | ⟨hgd, hu⟩
    · have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains he
      exact ⟨t', strictBefore_of_mem_pastOf hpast,
        Or.inl ⟨mem_knownTimes_of_mem hmem', Or.inl hmem'⟩⟩
    · have hmemG : (⟨.pos, guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains hgd
      have hmemU : (⟨.pos, .snce guard event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b :=
        mem_of_branch_contains hu
      exact ⟨t', strictBefore_of_mem_pastOf hpast,
        Or.inl ⟨mem_knownTimes_of_mem hmemG, Or.inr ⟨hmemG, hmemU⟩⟩⟩

end FormalSystem.Metalogic.Decidability.Verified.Bridge
