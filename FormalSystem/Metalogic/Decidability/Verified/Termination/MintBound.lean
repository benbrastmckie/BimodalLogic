/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel

/-!
# The mint bound — an independent ceiling on fresh-time minting

`Fuel.lean` (T3) turns the formula stock (T1) and the time-type bound (T2) into a fuel figure at
which `expandBranchWithFuel` cannot exhaust, but its totality theorem
`expandBranchWithFuel_isSome_of_noSplit` is scoped to runs that never branch. Lifting that scope
needs a bound on the number of **fresh-time mints** along a run that is independent of branch
growth, because at an ordered split's third arm (`Branch.identifyTime`) the branch shrinks as a
set and the branch-cardinality measure the extending case relies on is not available.

This module supplies that bound in four blocks.

## A. The irreflexivity invariant (`IrreflOrd`)

Witness preservation across the identification arm is **conditional** on the ordering carrying no
self-loop. That is not a convenience hypothesis: `TimeOrdering.identifyTime` drops every
constraint whose two components rename to the same index, including a pre-existing `(a, a)`, and
a witness reachable only around such a self-loop is destroyed. The counterexample
`witnessPresent_identifyTime_unconditional_false` below refutes the unconditional form outright.
`IrreflOrd` is therefore established as an engine-level run invariant before anything is built on
top of it.

## B. Reachability transport and witness preservation

`futureOf`/`pastOf` reachability transports along the identification renaming `rho`, length
preserving, so a witness found at one fuel figure is re-found at the same one. That lifts to
`witnessPresent` for all eight fresh-label rules, with every other rule covered by a *proved*
vacuity rather than an assumed one.

## C. The mint potential

The count of `(rule, signed formula)` pairs still eligible to mint. Witness preservation makes it
non-increasing along a run and a mint makes it strictly decrease, which is what converts "each
pair mints at most once" into a per-state measure an induction can carry.

## D. The amortized counting chain

`#mints`, `#identifications`, total shrinkage, and `#extensions`, each bounded absolutely, feeding
the branch-budget-carrying restatement of the totality theorem and its terminus at
`buildTableauAt`.

## Placement

Everything here is downstream of `Fuel.lean` and purely additive: no declaration in
`Fuel.lean`, `Saturation.lean`, or `Tableau.lean` is edited, and in particular `buildTableau`,
its default fuel, and `expandBranchWithFuel`'s default branch cap are untouched.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-! ## A. The renaming and the irreflexivity invariant -/

/-- The renaming induced by identifying `src` into `tgt`. -/
def rho (src tgt t : TimeIndex) : TimeIndex := if t = src then tgt else t

/-- The signed-formula half of the renaming. -/
def rhoSF (src tgt : TimeIndex) (sf : SignedFormula) : SignedFormula :=
  { sf with label := { sf.label with time := rho src tgt sf.label.time } }

/-- Irreflexivity of the constraint list: no ordering edge asserts `t < t`. -/
def IrreflOrd (ord : TimeOrdering) : Prop := ∀ p ∈ ord.constraints, p.1 ≠ p.2

/-- Identification preserves irreflexivity, by construction (collapses are dropped). -/
theorem irreflOrd_identifyTime (ord : TimeOrdering) (src tgt : TimeIndex) :
    IrreflOrd (ord.identifyTime src tgt) := by
  rintro ⟨a, b⟩ hp
  simp only [TimeOrdering.identifyTime, List.mem_eraseDups, List.mem_filterMap] at hp
  obtain ⟨⟨x, y⟩, -, hres⟩ := hp
  by_cases hAB : (if x = src then tgt else x) = (if y = src then tgt else y)
  · rw [if_pos (by simpa using hAB)] at hres
    exact absurd hres (by simp)
  · rw [if_neg (by simpa using hAB)] at hres
    simp only [Option.some.injEq, Prod.mk.injEq] at hres
    obtain ⟨rfl, rfl⟩ := hres
    simpa using hAB

/-- `addFuture` preserves irreflexivity exactly when the two times differ. -/
theorem irreflOrd_addFuture {ord : TimeOrdering} (h : IrreflOrd ord) {t t' : TimeIndex}
    (hne : t ≠ t') : IrreflOrd (ord.addFuture t t') := by
  rintro ⟨a, b⟩ hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with hp | hp
  · simp only [Prod.mk.injEq] at hp; obtain ⟨rfl, rfl⟩ := hp; exact hne
  · exact h _ hp

/-- `addPast` preserves irreflexivity exactly when the two times differ.

The mirror of `irreflOrd_addFuture`: `TimeOrdering.addPast t t_new` conses `(t_new, t)` rather
than `(t, t_new)`, so the obligation is the same with the pair flipped. Four of the nine
fresh-time mint sites in `applyRule` build their ordering this way. -/
theorem irreflOrd_addPast {ord : TimeOrdering} (h : IrreflOrd ord) {t t' : TimeIndex}
    (hne : t ≠ t') : IrreflOrd (ord.addPast t t') := by
  rintro ⟨a, b⟩ hp
  simp only [TimeOrdering.addPast, List.mem_cons] at hp
  rcases hp with hp | hp
  · simp only [Prod.mk.injEq] at hp; obtain ⟨rfl, rfl⟩ := hp; exact hne.symm
  · exact h _ hp

/-- The incomparability side condition is free at an ordered split: it is the trigger's own
guarantee, read off `firstIncomparablePair_spec`. -/
theorem incomparableB_of_firstIncomparablePair {b : Branch} {ord : TimeOrdering}
    {t₁ t₂ : TimeIndex} (h : firstIncomparablePair b ord = some (t₁, t₂)) :
    incomparableB ord (t₁, t₂) = true := by
  obtain ⟨-, -, hne, hf, hp⟩ := firstIncomparablePair_spec h
  simp only [incomparableB, Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
    List.contains_eq_mem, decide_eq_false_iff_not]
  exact ⟨⟨hne, hf⟩, hp⟩

/-! ### `IrreflOrd` is NECESSARY, not merely convenient

`TimeOrdering.identifyTime` drops **every** constraint that collapses, including a pre-existing
self-loop `(a, a)` with `a ∉ {src, tgt}` — its two components rename to the same index. So a
witness reachable only around a self-loop is destroyed by the identification arm, and the
`IrreflOrd`-free form of `witnessPresent_identifyTime` is **false**, not merely unproved.

The four examples below are the machine-checked record of that. They belong on the
do-not-re-attempt register: a future reader who takes `IrreflOrd` for a cosmetic hypothesis and
drops it will be re-attempting a refuted statement. -/

/-- A self-loop carries reachability before identification. -/
example : (5 : TimeIndex) ∈ (TimeOrdering.mk [(5, 5)]).futureOf 5 := by decide

/-- …and that reachability is gone after it, because the self-loop is dropped. -/
example : (5 : TimeIndex) ∉ ((TimeOrdering.mk [(5, 5)]).identifyTime 1 0).futureOf 5 := by decide

/-- The incomparability side condition still holds in that configuration, so the failure is
attributable to the self-loop alone rather than to a violated trigger guarantee. -/
example : incomparableB (TimeOrdering.mk [(5, 5)]) (0, 1) = true := by decide

/-- **Counterexample to the `IrreflOrd`-free form of witness preservation.** With the
irreflexivity hypothesis dropped, `witnessPresent` for `allFutureNeg` is `true` before the
identification and `false` after it. -/
theorem witnessPresent_identifyTime_unconditional_false :
    letI p : Formula := .atom ⟨"p", none⟩
    letI sf : SignedFormula := ⟨.neg, Formula.allFuture p, ⟨0, 5⟩⟩
    letI wit : SignedFormula := ⟨.neg, p, ⟨0, 5⟩⟩
    letI b : Branch := [sf, wit]
    letI ord : TimeOrdering := ⟨[(5, 5)]⟩
    witnessPresent .allFutureNeg sf b ord = true ∧
      witnessPresent .allFutureNeg ⟨.neg, Formula.allFuture p, ⟨0, rho 1 0 5⟩⟩
        (b.identifyTime 1 0) (ord.identifyTime 1 0) = false := by
  constructor <;> rfl

end FormalSystem.Metalogic.Decidability
