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
-/
theorem sat_untl_pos_future (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .untl event guard, ⟨w, t⟩⟩ ∈ b) :
    ∃ t' ∈ b.knownTimes, strictBefore timeOrd t t' = true ∧
      ((⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
        (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .untl event guard, ⟨w, t'⟩⟩ ∈ b)) := by
  have hExp :=
    all_expanded_of_saturated b timeOrd hSat ⟨.pos, .untl event guard, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  by_cases hg : guard = Formula.top
  · subst hg
    have h := hExp .someFuturePos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .someFuturePos ⟨.pos, .untl event Formula.top, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      simp only [Bool.not_eq_true, Formula.top] at hc
      simp [isApplicable, asSomeFuture?, Formula.top, applyRule, ruleMintsFreshLabel, hc] at h
    simp only [witnessPresent, asSomeFuture?, Formula.top, List.any_eq_true] at hwit
    obtain ⟨t', hfut, hcont⟩ := hwit
    have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains hcont
    exact ⟨t', mem_knownTimes_of_mem hmem', strictBefore_of_mem_futureOf hfut, Or.inl hmem'⟩
  · have hg' : (guard == Formula.top) = false := by simp [hg]
    have h := hExp .untlPos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .untlPos ⟨.pos, .untl event guard, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      simp only [isApplicable, asUntil?, hg', applyRule, ruleMintsFreshLabel,
        ruleSelfGuarded, if_true, if_neg hc] at h
      exact absurd h (by simp)
    simp only [witnessPresent, asUntil?, hg', Bool.false_eq_true, if_false, List.any_eq_true,
      Bool.or_eq_true, Bool.and_eq_true] at hwit
    obtain ⟨t', hfut, hcont⟩ := hwit
    rcases hcont with he | ⟨hgd, hu⟩
    · have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains he
      exact ⟨t', mem_knownTimes_of_mem hmem', strictBefore_of_mem_futureOf hfut, Or.inl hmem'⟩
    · have hmemG : (⟨.pos, guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains hgd
      have hmemU : (⟨.pos, .untl event guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b :=
        mem_of_branch_contains hu
      exact ⟨t', mem_knownTimes_of_mem hmemG, strictBefore_of_mem_futureOf hfut,
        Or.inr ⟨hmemG, hmemU⟩⟩

/-- **Since positive saturation, with the witness's position kept.** The past-directed mirror. -/
theorem sat_snce_pos_past (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .snce event guard, ⟨w, t⟩⟩ ∈ b) :
    ∃ t' ∈ b.knownTimes, strictBefore timeOrd t' t = true ∧
      ((⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
        (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .snce event guard, ⟨w, t'⟩⟩ ∈ b)) := by
  have hExp :=
    all_expanded_of_saturated b timeOrd hSat ⟨.pos, .snce event guard, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  by_cases hg : guard = Formula.top
  · subst hg
    have h := hExp .somePastPos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .somePastPos ⟨.pos, .snce event Formula.top, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      simp only [Bool.not_eq_true, Formula.top] at hc
      simp [isApplicable, asSomePast?, Formula.top, applyRule, ruleMintsFreshLabel, hc] at h
    simp only [witnessPresent, asSomePast?, Formula.top, List.any_eq_true] at hwit
    obtain ⟨t', hpast, hcont⟩ := hwit
    have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains hcont
    exact ⟨t', mem_knownTimes_of_mem hmem', strictBefore_of_mem_pastOf hpast, Or.inl hmem'⟩
  · have hg' : (guard == Formula.top) = false := by simp [hg]
    have h := hExp .sncePos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .sncePos ⟨.pos, .snce event guard, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      simp only [isApplicable, asSince?, hg', applyRule, ruleMintsFreshLabel,
        ruleSelfGuarded, if_true, if_neg hc] at h
      exact absurd h (by simp)
    simp only [witnessPresent, asSince?, hg', Bool.false_eq_true, if_false, List.any_eq_true,
      Bool.or_eq_true, Bool.and_eq_true] at hwit
    obtain ⟨t', hpast, hcont⟩ := hwit
    rcases hcont with he | ⟨hgd, hu⟩
    · have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains he
      exact ⟨t', mem_knownTimes_of_mem hmem', strictBefore_of_mem_pastOf hpast, Or.inl hmem'⟩
    · have hmemG : (⟨.pos, guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := mem_of_branch_contains hgd
      have hmemU : (⟨.pos, .snce event guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b :=
        mem_of_branch_contains hu
      exact ⟨t', mem_knownTimes_of_mem hmemG, strictBefore_of_mem_pastOf hpast,
        Or.inr ⟨hmemG, hmemU⟩⟩

end FormalSystem.Metalogic.Decidability.Verified.Bridge
