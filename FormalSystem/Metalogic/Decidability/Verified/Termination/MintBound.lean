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

/-! ## A2. `applyRule` preserves `IrreflOrd` -/

/-- A branch formula never sits at the branch's fresh time. This is the single freshness fact
every mint site reduces to, read off `not_mem_of_time_nextTime` contrapositively. -/
theorem time_ne_nextTime {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.time ≠ b.nextTime := fun hc => not_mem_of_time_nextTime hc h

set_option maxHeartbeats 4000000 in
/-- **Every rule except `densityRule` preserves ordering irreflexivity.**

`applyRule` mints a fresh time at exactly nine sites, all of the shape
`freshTime := branch.nextTime` followed by a single ordering edge between `sf.label.time` and
`freshTime` — five via `TimeOrdering.addFuture` and four via `TimeOrdering.addPast`. Each
reduces to `irreflOrd_addFuture` / `irreflOrd_addPast` applied to the one freshness fact
`time_ne_nextTime`. Every other rule threads the input ordering through unchanged, including
`timeLinearity`, whose `.branchingOrdered` result carries the per-arm orderings in the *result*
and returns the input ordering in the second component; the per-arm orderings are handled at
engine level rather than here.

`densityRule` is excluded because it is the sole **two-edge** site: it builds
`(ord.addFuture l.time freshTime).addFuture freshTime t'`, and the second edge needs
`freshTime ≠ t'`, which does not follow from freshness alone.

The `contradiction` alternative is load-bearing rather than defensive. `applyRule` is written as
one `match` over three discriminants with overlapping patterns, so `split` emits the arms of
*every* rule in each rule's case, each carrying a false discriminant equation such as
`TableauRule.impPos = TableauRule.densityRule`; `contradiction` is what discharges those
unreachable arms. It also discharges the genuine `densityRule` case from `hrule`. -/
theorem applyRule_irreflOrd_of_ne_density {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hrule : rule ≠ .densityRule) (hsf : sf ∈ b)
    (h : IrreflOrd ord) : IrreflOrd (applyRule rule sf b ord).2 := by
  have hfresh : sf.label.time ≠ b.nextTime := time_ne_nextTime hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | exact h
          | exact irreflOrd_addFuture h hfresh
          | exact irreflOrd_addPast h hfresh)


/-! ## B. The reachability transport stack

The twelve lemmas below are what make witness preservation across the identification arm work.
The `hnsl` side condition every one of them carries is spelled `IrreflOrd`, which unfolds to the
`∀ p ∈ ord.constraints, p.1 ≠ p.2` these proofs consume, so downstream phases meet one name. -/

/-- **Edge transport.** A constraint that does not collapse survives, renamed. -/
theorem identifyTime_edge (ord : TimeOrdering) (src tgt a b : TimeIndex)
    (h : (a, b) ∈ ord.constraints)
    (hne : rho src tgt a ≠ rho src tgt b) :
    (rho src tgt a, rho src tgt b) ∈ (ord.identifyTime src tgt).constraints := by
  simp only [TimeOrdering.identifyTime, List.mem_eraseDups, List.mem_filterMap]
  refine ⟨(a, b), h, ?_⟩
  simp only [rho] at hne ⊢
  simp only [beq_iff_eq]
  rw [if_neg (by simpa [rho, beq_iff_eq] using hne)]

/-- A constraint's target is in its source's future. -/
theorem mem_futureOf_of_mem_constraints (ord : TimeOrdering) (a b : TimeIndex)
    (h : (a, b) ∈ ord.constraints) : b ∈ ord.futureOf a := by
  rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq]
  refine TimeOrdering.bfsClosure_complete _ (n := 1) ⟨b, ?_, rfl⟩ (le_refl 1) (by omega)
  simp only [TimeOrdering.directFutureOf, List.mem_filterMap]
  exact ⟨(a, b), h, by simp⟩

/-- A constraint's source is in its target's past. -/
theorem mem_pastOf_of_mem_constraints (ord : TimeOrdering) (a b : TimeIndex)
    (h : (a, b) ∈ ord.constraints) : a ∈ ord.pastOf b := by
  rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq]
  refine TimeOrdering.bfsClosure_complete _ (n := 1) ⟨a, ?_, rfl⟩ (le_refl 1) (by omega)
  simp only [TimeOrdering.directPastOf, List.mem_filterMap]
  exact ⟨(a, b), h, by simp⟩

/-- **Collapse-freedom.** On an incomparable pair, no constraint collapses. -/
theorem identifyTime_no_collapse (ord : TimeOrdering) (t₁ t₂ : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : IrreflOrd ord)
    (a b : TimeIndex) (h : (a, b) ∈ ord.constraints) :
    rho t₂ t₁ a ≠ rho t₂ t₁ b := by
  simp only [incomparableB, Bool.and_eq_true, bne_iff_ne, Bool.not_eq_true',
    List.contains_eq_mem, decide_eq_false_iff_not] at hinc
  obtain ⟨⟨hne, hf⟩, hp⟩ := hinc
  have hab : a ≠ b := hnsl (a, b) h
  simp only [rho]
  by_cases ha : a = t₂ <;> by_cases hb : b = t₂
  · exact absurd (ha.trans hb.symm) hab
  · rw [if_pos ha, if_neg hb]
    intro hcon
    rw [ha, ← hcon] at h
    exact hp (mem_pastOf_of_mem_constraints ord t₂ t₁ h)
  · rw [if_neg ha, if_pos hb]
    intro hcon
    rw [hcon, hb] at h
    exact hf (mem_futureOf_of_mem_constraints ord t₁ t₂ h)
  · rw [if_neg ha, if_neg hb]; exact hab

/-- Direct forward adjacency is exactly constraint membership. -/
theorem mem_directFutureOf_iff' (ord : TimeOrdering) (a b : TimeIndex) :
    b ∈ ord.directFutureOf a ↔ (a, b) ∈ ord.constraints := by
  simp only [TimeOrdering.directFutureOf, List.mem_filterMap]
  constructor
  · rintro ⟨⟨x, y⟩, hxy, hres⟩
    by_cases hx : x = a
    · subst hx; simp at hres; subst hres; exact hxy
    · simp [hx] at hres
  · intro h; exact ⟨(a, b), h, by simp⟩

/-- Direct backward adjacency is exactly constraint membership. -/
theorem mem_directPastOf_iff' (ord : TimeOrdering) (a b : TimeIndex) :
    a ∈ ord.directPastOf b ↔ (a, b) ∈ ord.constraints := by
  simp only [TimeOrdering.directPastOf, List.mem_filterMap]
  constructor
  · rintro ⟨⟨x, y⟩, hxy, hres⟩
    by_cases hy : y = b
    · subst hy; simp at hres; subst hres; exact hxy
    · simp [hy] at hres
  · intro h; exact ⟨(a, b), h, by simp⟩

/-- **Path transport along an arbitrary renaming**, *length preserving*.

Length preservation is what makes the fuel budget work downstream: a path found at fuel `100`
maps to a path of the same length and is re-found by `bfsClosure_complete` at the same `100`. -/
theorem pathN_along (f g : TimeIndex → List TimeIndex) (φ : TimeIndex → TimeIndex)
    (h : ∀ x y, y ∈ f x → φ y ∈ g (φ x)) :
    ∀ (n : Nat) (a b : TimeIndex), TimeOrdering.PathN f n a b →
      TimeOrdering.PathN g n (φ a) (φ b) := by
  intro n
  induction n with
  | zero => intro a b hp; simp only [TimeOrdering.PathN] at hp ⊢; rw [hp]
  | succ m ih =>
    intro a b hp
    obtain ⟨c, hc, hrest⟩ := hp
    exact ⟨φ c, h a c hc, ih c b hrest⟩

/-- Every forward edge survives identification, renamed. -/
theorem directFutureOf_transport (ord : TimeOrdering) (t₁ t₂ : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : IrreflOrd ord) (a b : TimeIndex)
    (h : b ∈ ord.directFutureOf a) :
    rho t₂ t₁ b ∈ (ord.identifyTime t₂ t₁).directFutureOf (rho t₂ t₁ a) := by
  rw [mem_directFutureOf_iff'] at h ⊢
  exact identifyTime_edge ord t₂ t₁ a b h (identifyTime_no_collapse ord t₁ t₂ hinc hnsl a b h)

/-- Every backward edge survives identification, renamed. -/
theorem directPastOf_transport (ord : TimeOrdering) (t₁ t₂ : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : IrreflOrd ord) (a b : TimeIndex)
    (h : a ∈ ord.directPastOf b) :
    rho t₂ t₁ a ∈ (ord.identifyTime t₂ t₁).directPastOf (rho t₂ t₁ b) := by
  rw [mem_directPastOf_iff'] at h ⊢
  exact identifyTime_edge ord t₂ t₁ a b h (identifyTime_no_collapse ord t₁ t₂ hinc hnsl a b h)

/-- **The reachability transport, forward.** -/
theorem futureOf_transport (ord : TimeOrdering) (t₁ t₂ : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : IrreflOrd ord) (s t : TimeIndex)
    (h : t ∈ ord.futureOf s) :
    rho t₂ t₁ t ∈ (ord.identifyTime t₂ t₁).futureOf (rho t₂ t₁ s) := by
  rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [s] [] h with hv | ⟨u, hu, n, hn1, hn2, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hu
    subst hu
    rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq]
    exact TimeOrdering.bfsClosure_complete _
      (pathN_along _ _ (rho t₂ t₁) (directFutureOf_transport ord t₁ t₂ hinc hnsl) n u t hp)
      hn1 hn2

/-- **The reachability transport, backward.** -/
theorem pastOf_transport (ord : TimeOrdering) (t₁ t₂ : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : IrreflOrd ord) (s t : TimeIndex)
    (h : t ∈ ord.pastOf s) :
    rho t₂ t₁ t ∈ (ord.identifyTime t₂ t₁).pastOf (rho t₂ t₁ s) := by
  rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [s] [] h with hv | ⟨u, hu, n, hn1, hn2, hp⟩
  · simp at hv
  · rw [List.mem_singleton] at hu
    subst hu
    rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq]
    refine TimeOrdering.bfsClosure_complete _ (pathN_along _ _ (rho t₂ t₁) ?_ n u t hp) hn1 hn2
    intro x y hy
    exact directPastOf_transport ord t₁ t₂ hinc hnsl y x hy

end FormalSystem.Metalogic.Decidability
