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

/-! ## A3. `densityRule` and the ordering-times invariant

`densityRule` is the sole two-edge mint site. Its second edge runs from the fresh time to a
target `t'` drawn from `ord.futureOf l.time`, so irreflexivity there needs `t' ≠ freshTime`,
which freshness alone does not give. The auxiliary invariant below is what supplies it: if every
time the ordering mentions is a time the branch already knows, then `t'` sits at or below
`b.maxTime`, strictly below the fresh time. -/

/-- **Every time the ordering mentions is a branch time.** -/
def OrdTimesLeMaxTime (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ≤ b.maxTime ∧ p.2 ≤ b.maxTime

/-- A path of at least one edge has a last edge, so its endpoint is some constraint's target. -/
theorem exists_constraint_to_of_pathN (ord : TimeOrdering) :
    ∀ (n : Nat) (a t : TimeIndex), 1 ≤ n →
      TimeOrdering.PathN ord.directFutureOf n a t → ∃ x, (x, t) ∈ ord.constraints := by
  intro n
  induction n with
  | zero => intro a t hn; omega
  | succ m ih =>
    intro a t _ hp
    obtain ⟨c, hc, hrest⟩ := hp
    rcases Nat.eq_zero_or_pos m with rfl | hm
    · simp only [TimeOrdering.PathN] at hrest
      subst hrest
      exact ⟨a, (mem_directFutureOf_iff' ord a c).mp hc⟩
    · exact ih c t hm hrest

/-- Anything in a time's future is the target of some ordering constraint.

The `1 ≤ n` lower bound `bfsClosure_sound` carries is what makes this work: without it,
membership could be witnessed by the empty path, and a source with no incoming edge would be a
counterexample. -/
theorem exists_constraint_to_of_mem_futureOf (ord : TimeOrdering) (s t : TimeIndex)
    (h : t ∈ ord.futureOf s) : ∃ x, (x, t) ∈ ord.constraints := by
  rw [TimeOrdering.futureOf, TimeOrdering.reachableForward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [s] [] h with hv | ⟨u, hu, n, hn1, -, hp⟩
  · simp at hv
  · exact exists_constraint_to_of_pathN ord n u t hn1 hp

/-- **The `densityRule` second-edge fact.** A time in the ordering's reach is never the branch's
fresh time. -/
theorem ne_nextTime_of_mem_futureOf {b : Branch} {ord : TimeOrdering} {s t : TimeIndex}
    (haux : OrdTimesLeMaxTime b ord) (h : t ∈ ord.futureOf s) : b.nextTime ≠ t := by
  obtain ⟨x, hx⟩ := exists_constraint_to_of_mem_futureOf ord s t h
  have hle : t ≤ b.maxTime := (haux (x, t) hx).2
  -- `Branch.nextTime = maxTime + 1`. Note `omega` is not usable here: it reports "no usable
  -- constraints" on `TimeIndex` hypotheses even though `TimeIndex` is an `abbrev` for `Nat`.
  simp only [Branch.nextTime]
  exact Nat.ne_of_gt (Nat.lt_succ_of_le hle)

/-- The two-edge ordering `densityRule` builds is irreflexive.

`t'` is the head of a filtered sub-list of `ord.futureOf t`, hence itself in `ord.futureOf t`,
hence at or below `b.maxTime` by `OrdTimesLeMaxTime` and so distinct from the fresh time. The
filter predicate is left as a parameter because nothing here depends on which gaps the rule
selects — only on the fact that the selection is a sub-list of the reach. -/
theorem irreflOrd_density_newOrd {b : Branch} {ord : TimeOrdering} {t t' : TimeIndex}
    {P : TimeIndex → Bool} {tail : List TimeIndex}
    (hord : IrreflOrd ord) (haux : OrdTimesLeMaxTime b ord)
    (hfresh : t ≠ b.nextTime)
    (heq : (ord.futureOf t).filter P = t' :: tail) :
    IrreflOrd ((ord.addFuture t b.nextTime).addFuture b.nextTime t') := by
  have hmem : t' ∈ ord.futureOf t :=
    List.mem_of_mem_filter (by rw [heq]; exact List.mem_cons_self)
  exact irreflOrd_addFuture (irreflOrd_addFuture hord hfresh)
    (ne_nextTime_of_mem_futureOf haux hmem)

set_option maxHeartbeats 4000000 in
/-- **`applyRule` preserves ordering irreflexivity, with no rule excluded and no frame-class
restriction.** The `densityRule` case, the one `applyRule_irreflOrd_of_ne_density` leaves out, is
closed by `irreflOrd_density_newOrd` from the auxiliary invariant. -/
theorem applyRule_irreflOrd {rule : TableauRule} {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} (hsf : sf ∈ b) (hord : IrreflOrd ord)
    (haux : OrdTimesLeMaxTime b ord) : IrreflOrd (applyRule rule sf b ord).2 := by
  have hfresh : sf.label.time ≠ b.nextTime := time_ne_nextTime hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | exact hord
          | exact irreflOrd_addFuture hord hfresh
          | exact irreflOrd_addPast hord hfresh
          | exact irreflOrd_density_newOrd hord haux hfresh (by assumption))

/-! ### `OrdTimesLeMaxTime` is preserved at the non-branching result shapes

`Branch.maxTime` is a `foldl max`, and the two facts the preservation proof needs — that it is
monotone in the branch, and that it dominates the fresh time once the witness is on the branch —
are not exported by `Tableau.lean` (`le_foldl_max` / `mem_le_foldl_max` there are `private`), so
the `≤`-direction is re-proved locally. -/

private theorem foldl_max_le (f : SignedFormula → Nat) :
    ∀ (l : List SignedFormula) (a n : Nat), a ≤ n → (∀ s ∈ l, f s ≤ n) →
      l.foldl (fun x s => max x (f s)) a ≤ n := by
  intro l
  induction l with
  | nil => intro a n ha _; simpa using ha
  | cons x xs ih =>
    intro a n ha hall
    simp only [List.foldl_cons]
    exact ih _ n (max_le ha (hall x List.mem_cons_self))
      (fun s hs => hall s (List.mem_cons_of_mem _ hs))

/-- `Branch.maxTime` is the least upper bound of the branch's times. -/
theorem maxTime_le_of_forall {b : Branch} {n : Nat} (h : ∀ sf ∈ b, sf.label.time ≤ n) :
    b.maxTime ≤ n := foldl_max_le (fun s => s.label.time) b 0 n (Nat.zero_le _) h

/-- `Branch.maxTime` is monotone in the branch. -/
theorem maxTime_mono {b nb : Branch} (h : ∀ x ∈ b, x ∈ nb) : b.maxTime ≤ nb.maxTime :=
  maxTime_le_of_forall (fun _ hsf => le_maxTime (h _ hsf))

/-- Appending in front never lowers `maxTime`. -/
theorem maxTime_le_append (fs : List SignedFormula) (b : Branch) :
    b.maxTime ≤ Branch.maxTime (fs ++ b) :=
  maxTime_mono (fun _ hx => List.mem_append_right fs hx)

/-- The invariant survives branch growth on its own, when the ordering does not change. -/
theorem ordTimes_mono {b nb : Branch} {ord : TimeOrdering}
    (haux : OrdTimesLeMaxTime b ord) (hle : b.maxTime ≤ nb.maxTime) :
    OrdTimesLeMaxTime nb ord :=
  fun p hp => ⟨le_trans (haux p hp).1 hle, le_trans (haux p hp).2 hle⟩

/-- A mint step's new branch dominates the fresh time, because the witness sits there. -/
theorem nextTime_le_maxTime_cons {b : Branch} {g : SignedFormula} {rest : List SignedFormula}
    (hg : g.label.time = b.nextTime) : b.nextTime ≤ Branch.maxTime (g :: rest ++ b) :=
  hg ▸ le_maxTime (List.mem_append_left b List.mem_cons_self)

/-- Single-edge `addFuture` mint step: the invariant is preserved. -/
theorem ordTimes_addFuture_cons {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesLeMaxTime b ord) (ht : t ≤ b.maxTime)
    (hg : g.label.time = b.nextTime) :
    OrdTimesLeMaxTime (g :: rest ++ b) (ord.addFuture t b.nextTime) := by
  have hmono : b.maxTime ≤ Branch.maxTime (g :: rest ++ b) := maxTime_le_append _ _
  have hnext : b.nextTime ≤ Branch.maxTime (g :: rest ++ b) := nextTime_le_maxTime_cons hg
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | hp
  · exact ⟨le_trans ht hmono, hnext⟩
  · exact ordTimes_mono haux hmono p hp

/-- Single-edge `addPast` mint step: the invariant is preserved. -/
theorem ordTimes_addPast_cons {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesLeMaxTime b ord) (ht : t ≤ b.maxTime)
    (hg : g.label.time = b.nextTime) :
    OrdTimesLeMaxTime (g :: rest ++ b) (ord.addPast t b.nextTime) := by
  have hmono : b.maxTime ≤ Branch.maxTime (g :: rest ++ b) := maxTime_le_append _ _
  have hnext : b.nextTime ≤ Branch.maxTime (g :: rest ++ b) := nextTime_le_maxTime_cons hg
  intro p hp
  simp only [TimeOrdering.addPast, List.mem_cons] at hp
  rcases hp with rfl | hp
  · exact ⟨hnext, le_trans ht hmono⟩
  · exact ordTimes_mono haux hmono p hp

/-- `densityRule`'s two-edge mint step: the invariant is preserved. The extra obligation over the
single-edge case is `t' ≤ b.maxTime`, which is the invariant applied to the constraint that put
`t'` in the reach in the first place. -/
theorem ordTimes_density_cons {b : Branch} {ord : TimeOrdering} {t t' : TimeIndex}
    {P : TimeIndex → Bool} {tail : List TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesLeMaxTime b ord) (ht : t ≤ b.maxTime)
    (hg : g.label.time = b.nextTime)
    (heq : (ord.futureOf t).filter P = t' :: tail) :
    OrdTimesLeMaxTime (g :: rest ++ b) ((ord.addFuture t b.nextTime).addFuture b.nextTime t') := by
  have hmem : t' ∈ ord.futureOf t :=
    List.mem_of_mem_filter (by rw [heq]; exact List.mem_cons_self)
  obtain ⟨x, hx⟩ := exists_constraint_to_of_mem_futureOf ord t t' hmem
  have ht' : t' ≤ b.maxTime := (haux (x, t') hx).2
  have hmono : b.maxTime ≤ Branch.maxTime (g :: rest ++ b) := maxTime_le_append _ _
  have hnext : b.nextTime ≤ Branch.maxTime (g :: rest ++ b) := nextTime_le_maxTime_cons hg
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | rfl | hp
  · exact ⟨hnext, le_trans ht' hmono⟩
  · exact ⟨le_trans ht hmono, hnext⟩
  · exact ordTimes_mono haux hmono p hp

/-- The successor branch of a **non-branching** rule result, if there is one.

Phrasing the preservation statement against this `Option` keeps the whole obligation on the goal
side, so the rule case analysis reduces the result and the ordering *together*. A hypothesis of
the form `applyRule … = (.linear fs, ord')` cannot be split in step with the goal, because
`split` does not reach every `dite` once the equation has been oriented. -/
def nonBranchingResultBranch (b : Branch) : RuleResult → Option Branch
  | .linear fs => some (fs ++ b)
  | .persistent fs => some (fs ++ b)
  | _ => none

set_option maxHeartbeats 4000000 in
/-- **`applyRule` preserves `OrdTimesLeMaxTime` at the non-branching result shapes.**

The branching shapes (`.branching`, `.branchingOrdered`) are handled at engine level, where the
per-arm branches are visible. -/
theorem applyRule_ordTimes_nonbranching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesLeMaxTime b ord) :
    ∀ nb ∈ nonBranchingResultBranch b (applyRule rule sf b ord).1,
      OrdTimesLeMaxTime nb (applyRule rule sf b ord).2 := by
  have ht : sf.label.time ≤ b.maxTime := le_maxTime hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [nonBranchingResultBranch, Option.mem_def, Option.some.injEq] at hnb
             first
               | (subst hnb
                  first
                    | exact ordTimes_mono haux (maxTime_le_append _ _)
                    | exact ordTimes_addFuture_cons haux ht rfl
                    | exact ordTimes_addPast_cons haux ht rfl
                    | exact ordTimes_density_cons haux ht rfl (by assumption))
               | exact absurd hnb (by simp)))

/-! ## B2. Witness preservation across the identification arm

This is claim (i): the third arm of an ordered split does not destroy a witness. It is stated for
*every* `TableauRule`; the rules that do not mint a fresh label are covered because
`witnessPresent` returns `false` on them, and that vacuity is **proved**, not assumed. -/

/-- **No formula is deleted by identification**: every member survives, renamed. -/
theorem mem_identifyTime (b : Branch) (src tgt : TimeIndex) (sf : SignedFormula)
    (h : sf ∈ b) : rhoSF src tgt sf ∈ b.identifyTime src tgt := by
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map]
  refine ⟨sf, h, ?_⟩
  simp only [rhoSF, rho]
  by_cases hc : sf.label.time = src
  · simp [hc]
  · simp [hc]

/-- The `contains` form of the same fact. -/
theorem contains_identifyTime (b : Branch) (src tgt : TimeIndex) (sf : SignedFormula)
    (h : b.contains sf = true) :
    (b.identifyTime src tgt).contains (rhoSF src tgt sf) = true := by
  simp only [Branch.contains, List.any_eq_true, beq_iff_eq] at h ⊢
  obtain ⟨x, hx, hxe⟩ := h
  subst hxe
  exact ⟨_, mem_identifyTime b src tgt x hx, rfl⟩

/-- Identification touches no world: `knownWorlds` is preserved. -/
theorem knownWorlds_identifyTime (b : Branch) (src tgt : TimeIndex) (w : WorldIndex)
    (h : w ∈ b.knownWorlds) : w ∈ (b.identifyTime src tgt).knownWorlds := by
  simp only [Branch.knownWorlds, List.mem_eraseDups, List.mem_map] at h ⊢
  obtain ⟨sf, hsf, rfl⟩ := h
  exact ⟨rhoSF src tgt sf, mem_identifyTime b src tgt sf hsf, rfl⟩

/-- Transport of a `knownWorlds`-quantified test. -/
theorem any_knownWorlds_transport (b : Branch) (t₁ t₂ : TimeIndex) (P Q : WorldIndex → Bool)
    (hPQ : ∀ w, P w = true → Q w = true)
    (h : b.knownWorlds.any P = true) :
    (b.identifyTime t₂ t₁).knownWorlds.any Q = true := by
  simp only [List.any_eq_true] at h ⊢
  obtain ⟨w, hw, hPw⟩ := h
  exact ⟨w, knownWorlds_identifyTime b t₂ t₁ w hw, hPQ w hPw⟩

/-- Transport of a future-quantified test. -/
theorem any_futureOf_transport (ord : TimeOrdering) (t₁ t₂ : TimeIndex) (tm : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : IrreflOrd ord)
    (P Q : TimeIndex → Bool)
    (hPQ : ∀ t, P t = true → Q (rho t₂ t₁ t) = true)
    (h : (ord.futureOf tm).any P = true) :
    ((ord.identifyTime t₂ t₁).futureOf (rho t₂ t₁ tm)).any Q = true := by
  simp only [List.any_eq_true] at h ⊢
  obtain ⟨t, ht, hPt⟩ := h
  exact ⟨rho t₂ t₁ t, futureOf_transport ord t₁ t₂ hinc hnsl tm t ht, hPQ t hPt⟩

/-- Transport of a past-quantified test. -/
theorem any_pastOf_transport (ord : TimeOrdering) (t₁ t₂ : TimeIndex) (tm : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : IrreflOrd ord)
    (P Q : TimeIndex → Bool)
    (hPQ : ∀ t, P t = true → Q (rho t₂ t₁ t) = true)
    (h : (ord.pastOf tm).any P = true) :
    ((ord.identifyTime t₂ t₁).pastOf (rho t₂ t₁ tm)).any Q = true := by
  simp only [List.any_eq_true] at h ⊢
  obtain ⟨t, ht, hPt⟩ := h
  exact ⟨rho t₂ t₁ t, pastOf_transport ord t₁ t₂ hinc hnsl tm t ht, hPQ t hPt⟩

/-- `contains` at a relabelled point, in the exact shape the witness tests use. -/
theorem contains_at (b : Branch) (t₁ t₂ : TimeIndex) (s : Sign) (psi : Formula)
    (w : WorldIndex) (t : TimeIndex)
    (h : b.contains ⟨s, psi, ⟨w, t⟩⟩ = true) :
    (b.identifyTime t₂ t₁).contains ⟨s, psi, ⟨w, rho t₂ t₁ t⟩⟩ = true :=
  contains_identifyTime b t₂ t₁ ⟨s, psi, ⟨w, t⟩⟩ h

/-- **Claim (i): witness preservation across the identification arm of an ordered split.**

The `IrreflOrd` hypothesis is **load-bearing**, not cosmetic. Dropping it makes the statement
false, by the machine-checked counterexample
`witnessPresent_identifyTime_unconditional_false` above: `TimeOrdering.identifyTime` drops a
pre-existing self-loop, and a witness reachable only around that loop is destroyed.

Stated for *every* rule. The eight fresh-label rules (`boxNeg`, `diamondPos`, `allFutureNeg`,
`allPastNeg`, `someFuturePos`, `somePastPos`, `untlPos`, `sncePos` — exactly the `true` arms of
`ruleMintsFreshLabel`) are transported case by case; every other rule is covered by the final
case, where `witnessPresent` is `false` and the hypothesis is absurd. -/
theorem witnessPresent_identifyTime (rule : TableauRule) (b : Branch) (ord : TimeOrdering)
    (t₁ t₂ : TimeIndex) (s : Sign) (φ : Formula) (w : WorldIndex) (tm : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : IrreflOrd ord)
    (h : witnessPresent rule ⟨s, φ, ⟨w, tm⟩⟩ b ord = true) :
    witnessPresent rule ⟨s, φ, ⟨w, rho t₂ t₁ tm⟩⟩
      (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁) = true := by
  simp only [witnessPresent] at h ⊢
  split at h
  -- RULE 1 (modal): boxNeg
  case h_1 =>
    exact any_knownWorlds_transport (b := b) (t₁ := t₁) (t₂ := t₂) _ _
      (fun w' hw' => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .neg _ w' tm hw') h
  -- RULE 2 (modal): diamondPos
  case h_2 =>
    split at h
    case h_1 =>
      exact any_knownWorlds_transport (b := b) (t₁ := t₁) (t₂ := t₂) _ _
        (fun w' hw' => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w' tm hw') h
    case h_2 => exact Bool.noConfusion h
  -- RULE 3 (temporal): allFutureNeg
  case h_3 =>
    exact any_futureOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _
      (fun t ht => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .neg _ w t ht) h
  -- RULE 4 (temporal): allPastNeg
  case h_4 =>
    exact any_pastOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _
      (fun t ht => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .neg _ w t ht) h
  -- RULE 5 (temporal): someFuturePos
  case h_5 =>
    split at h
    case h_1 =>
      exact any_futureOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _
        (fun t ht => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht) h
    case h_2 => exact Bool.noConfusion h
  -- RULE 6 (temporal): somePastPos
  case h_6 =>
    split at h
    case h_1 =>
      exact any_pastOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _
        (fun t ht => contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht) h
    case h_2 => exact Bool.noConfusion h
  -- RULE 7 (temporal): untlPos — disjunctive witness, transported componentwise
  case h_7 =>
    split at h
    case h_1 =>
      refine any_futureOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _ ?_ h
      intro t ht
      simp only [Bool.or_eq_true, Bool.and_eq_true] at ht ⊢
      rcases ht with ht | ⟨ht1, ht2⟩
      · exact Or.inl (contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht)
      · exact Or.inr ⟨contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht1,
          contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht2⟩
    case h_2 => exact Bool.noConfusion h
  -- RULE 8 (temporal): sncePos — the past-directed mirror
  case h_8 =>
    split at h
    case h_1 =>
      refine any_pastOf_transport (ord := ord) (t₁ := t₁) (t₂ := t₂) tm hinc hnsl _ _ ?_ h
      intro t ht
      simp only [Bool.or_eq_true, Bool.and_eq_true] at ht ⊢
      rcases ht with ht | ⟨ht1, ht2⟩
      · exact Or.inl (contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht)
      · exact Or.inr ⟨contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht1,
          contains_at (b := b) (t₁ := t₁) (t₂ := t₂) .pos _ w t ht2⟩
    case h_2 => exact Bool.noConfusion h
  -- every other rule: `witnessPresent` is `false`, so the hypothesis is absurd
  case h_9 => exact Bool.noConfusion h

/-- **The full arm-3 preservation package**, in the form the mint bound consumes: the witness
survives under the same renaming that carries the source formula. Taking the trigger equation
rather than raw incomparability makes the `hinc` side condition free. -/
theorem arm3_preserves_witness {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂))
    (hnsl : IrreflOrd ord)
    (rule : TableauRule) (sf : SignedFormula)
    (h : witnessPresent rule sf b ord = true) :
    witnessPresent rule (rhoSF t₂ t₁ sf) (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁)
      = true := by
  cases sf with
  | mk s φ l =>
    cases l with
    | mk w tm =>
      exact witnessPresent_identifyTime rule b ord t₁ t₂ s φ w tm
        (incomparableB_of_firstIncomparablePair htrig) hnsl h

/-! ## B3. Non-deletion at engine level

Claim (ii): no expansion step deletes a formula. Stated as a **membership** fact
(`x ∈ b → x ∈ arm ∨ ρ_SF x ∈ arm`), which is deliberately *not* a cardinality fact. The third arm
still shrinks `Branch.toFinset.card`, because `Branch.identifyTime` is
`(b.map relabel).eraseDups` and the `eraseDups` merges two times into one; nothing here claims
otherwise, and the cardinality twin of the split-growth lemma is refuted, not merely unproved. -/

private theorem pick_splitOrdered' {b : Branch} {bs : List (Branch × TimeOrdering)}
    {ord : TimeOrdering} {pick : Option (TableauRule × RuleResult × TimeOrdering)}
    (h : (match pick with
          | none => (ExpansionResult.saturated, ord)
          | some (_, result, newOrd) =>
            match result with
            | .linear fs => (ExpansionResult.extended (fs ++ b), newOrd)
            | .branching bss => (ExpansionResult.split (bss.map fun fs => fs ++ b), newOrd)
            | .branchingOrdered bs' => (ExpansionResult.splitOrdered bs', newOrd)
            | .persistent fs => (ExpansionResult.extended (fs ++ b), newOrd)
            | .notApplicable => (ExpansionResult.saturated, newOrd)).1
         = ExpansionResult.splitOrdered bs) :
    ∃ r o, pick = some (r, RuleResult.branchingOrdered bs, o) := by
  rcases pick with _ | ⟨r, res, o⟩
  · simp at h
  · cases res with
    | notApplicable => simp at h
    | linear fs => simp at h
    | branching bss => simp at h
    | persistent fs => simp at h
    | branchingOrdered bs' => exact ⟨r, o, by simpa using h⟩

-- `linter.unusedTactic` fires on the `exact RuleResult.noConfusion h` inside the second
-- `first` alternative below and calls it dead. It is NOT dead: it is the alternative's
-- *failure* mechanism. In the goals where `simp only [] at h` makes progress but does not
-- close the goal, that `exact` is what makes the whole alternative fail so `first` falls
-- through to `simp_all`, which discharges them from the false rule equation in context.
-- Deleting the `exact` was tried and leaves 12 goals unsolved (`impPos`, `impNeg`, `boxPos`,
-- `boxNeg`, `boxTemporal`, `allFuturePos`, `allFutureNeg`, `allPastPos`, `allPastNeg`,
-- `denseIndicatorClosure`, `densityRule`, `z1Rule`).
set_option linter.unusedTactic false in
set_option maxHeartbeats 4000000 in
/-- `timeLinearity` is the ONLY rule that can produce an ordered split. -/
theorem applyRule_branchingOrdered_rule (rule : TableauRule) (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bs : List (Branch × TimeOrdering))
    (h : (applyRule rule sf b ord).1 = RuleResult.branchingOrdered bs) : rule = .timeLinearity := by
  cases sf with
  | mk sign formula label =>
    cases rule
    case timeLinearity => rfl
    all_goals (exfalso; revert h; cases sign <;> simp only [applyRule] <;> intro h <;>
      (repeat' split at h) <;>
      first
        | exact RuleResult.noConfusion h
        | (simp only [] at h; exact RuleResult.noConfusion h)
        | simp_all)

/-- **Engine-level shape of an ordered split.** Whichever of the three pick stages produced it,
an ordered split is `timeLinearity`'s three arms on the very branch and ordering it was called
with. -/
theorem expandOnceUnblocked_splitOrdered_shape {b : Branch} {bs : List (Branch × TimeOrdering)}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∃ t₁ t₂, firstIncomparablePair b ord = some (t₁, t₂) ∧
      bs = [ (b, ord.addFuture t₁ t₂), (b, ord.addFuture t₂ t₁),
             (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁) ] := by
  unfold expandOnceUnblocked at h
  obtain ⟨r, o, hpick⟩ := pick_splitOrdered' h
  have key : ∃ sf : SignedFormula, (applyRule r sf b ord).1 = RuleResult.branchingOrdered bs := by
    split at hpick
    · exact ⟨_, findApplicableRule_applyRule_eq hpick⟩
    · split at hpick
      · exact ⟨_, findApplicableSerialRule_applyRule_eq hpick⟩
      · split at hpick
        · exact ⟨_, findApplicableLinearityRule_applyRule_eq hpick⟩
        · exact absurd hpick (by simp)
  obtain ⟨sf, hsf⟩ := key
  cases applyRule_branchingOrdered_rule r sf b ord bs hsf
  exact applyRule_timeLinearity_arms_trigger sf b ord bs hsf

/-- **Claim (ii), engine level, `.splitOrdered` case.** No formula is deleted by an ordered
split: arms 1-2 keep the branch literally, arm 3 keeps every formula renamed. -/
theorem expandOnceUnblocked_splitOrdered_no_deletion
    {b : Branch} {bs : List (Branch × TimeOrdering)} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∃ t₁ t₂, ∀ p ∈ bs, ∀ x ∈ b,
      x ∈ p.1 ∨ rhoSF t₂ t₁ x ∈ p.1 := by
  obtain ⟨t₁, t₂, -, rfl⟩ := expandOnceUnblocked_splitOrdered_shape h
  refine ⟨t₁, t₂, ?_⟩
  intro p hp x hx
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact Or.inl hx
  · exact Or.inl hx
  · exact Or.inr (mem_identifyTime b t₂ t₁ x hx)

/-! ## A4. The pick bridges, carrying the ordering

`Fuel.lean`'s `findApplicable{,Serial,Linearity}Rule_applyRule_eq` report only the *result*
component of the pick. Lifting `applyRule_irreflOrd` to engine level needs the *ordering*
component too, since `expandOnceUnblocked` hands the pick's third component on as the step's new
ordering. These are the same three extraction lemmas strengthened to the full pair. -/

/-- The ordinary-rule stage reports the rule's own result **and ordering**. -/
theorem findApplicableRule_applyRule_pair
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    applyRule r sf b ord = (res, o) := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  repeat' split at hr
  all_goals simp_all

/-- The seriality stage reports the rule's own result **and ordering**. -/
theorem findApplicableSerialRule_applyRule_pair
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableSerialRule sf b ord = some (r, res, o)) :
    applyRule r sf b ord = (res, o) := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  rcases hA : applyRule TableauRule.serialityRule sf b ord with ⟨res', o'⟩
  rw [hA] at h
  simp only at h
  cases res' <;> simp only [Option.some.injEq, Prod.mk.injEq] at h
  all_goals first
    | (obtain ⟨rfl, rfl, rfl⟩ := h; exact hA)
    | exact absurd h (by simp)

/-- The linearity stage reports the rule's own result **and ordering**. -/
theorem findApplicableLinearityRule_applyRule_pair
    {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableLinearityRule sf b ord = some (r, res, o)) :
    applyRule r sf b ord = (res, o) := by
  unfold findApplicableLinearityRule linearityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  rcases hA : applyRule TableauRule.timeLinearity sf b ord with ⟨res', o'⟩
  rw [hA] at h
  simp only at h
  cases res' <;> simp only [Option.some.injEq, Prod.mk.injEq] at h
  all_goals first
    | (obtain ⟨rfl, rfl, rfl⟩ := h; exact hA)
    | exact absurd h (by simp)

/-! ## A5. Engine-level `IrreflOrd`, all four result shapes

`expandOnceUnblocked` hands the pick's third component on as the step's new ordering, and that
component is `(applyRule r sf b ord).2` at each of the three pick stages. So the engine-level
statement is `applyRule_irreflOrd` composed with the three pick bridges of A4, with `sf ∈ b`
coming from `List.mem_of_find?_eq_some` at each stage. -/

/-- The ordering a pick hands on: the input ordering when nothing was picked, and the picked
rule's own new ordering otherwise. -/
private def pickOrd (ord : TimeOrdering) :
    Option (TableauRule × RuleResult × TimeOrdering) → TimeOrdering
  | none => ord
  | some (_, _, o) => o

/-- The second component of `expandOnceUnblocked`'s result-tail is `pickOrd`, uniformly across
all five `RuleResult` shapes. Stated over an abstract `pick` for the same reason `pick_extended`
is: a hypothesis about the three-stage `match` as a whole is not something the per-stage lemmas
can consume. -/
private theorem pick_ord_eq {b : Branch} {ord : TimeOrdering}
    {pick : Option (TableauRule × RuleResult × TimeOrdering)} :
    (match pick with
      | none => (ExpansionResult.saturated, ord)
      | some (_, result, newOrd) =>
        match result with
        | .linear fs => (ExpansionResult.extended (fs ++ b), newOrd)
        | .branching bss => (ExpansionResult.split (bss.map fun fs => fs ++ b), newOrd)
        | .branchingOrdered bs' => (ExpansionResult.splitOrdered bs', newOrd)
        | .persistent fs => (ExpansionResult.extended (fs ++ b), newOrd)
        | .notApplicable => (ExpansionResult.saturated, newOrd)).2
      = pickOrd ord pick := by
  rcases pick with _ | ⟨r, res, o⟩
  · rfl
  · cases res <;> rfl

/-- One pick stage preserves irreflexivity, given that the stage reports `applyRule`'s own pair.
This is the single shape all three stages instantiate. -/
private theorem pickOrd_irreflOrd {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hsf : sf ∈ b) (hord : IrreflOrd ord) (haux : OrdTimesLeMaxTime b ord)
    (hp : ∀ r res o, p = some (r, res, o) → applyRule r sf b ord = (res, o)) :
    IrreflOrd (pickOrd ord p) := by
  rcases p with _ | ⟨r, res, o⟩
  · exact hord
  · have hI : IrreflOrd (applyRule r sf b ord).2 := applyRule_irreflOrd hsf hord haux
    rw [hp r res o rfl] at hI
    exact hI

/-- **Engine-level irreflexivity, all four `ExpansionResult` shapes.** The step's ordering
component is irreflexive whichever shape the step reports: `.saturated` threads the input
ordering through, `.extended` and `.split` hand the picked rule's ordering on unchanged, and
`.splitOrdered` returns the input ordering in this component (its per-arm orderings are the
subject of `expandOnceUnblocked_splitOrdered_irreflOrd` below).

`.split` needs nothing further: a `.branching` step hands the *same* ordering to every arm, so
this one statement covers every arm of a split. -/
theorem expandOnceUnblocked_irreflOrd {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hord : IrreflOrd ord) (haux : OrdTimesLeMaxTime b ord) :
    IrreflOrd (expandOnceUnblocked b ord fc tr).2 := by
  -- `pick_ord_eq` applies up to definitional unfolding of `expandOnceUnblocked`, so the equation
  -- is stated rather than rewritten into: `unfold` leaves the `let blocked := …` binder in place
  -- and `rw` then has nothing syntactic to match.
  have key : (expandOnceUnblocked b ord fc tr).2
      = pickOrd ord
          (match findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with
           | some sf => findApplicableRule sf b ord fc
           | none =>
             match b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                 && (findApplicableSerialRule sf b ord).isSome) with
             | some sf => findApplicableSerialRule sf b ord
             | none =>
               match b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                   && (findApplicableLinearityRule sf b ord).isSome) with
               | some sf => findApplicableLinearityRule sf b ord
               | none => none) := pick_ord_eq
  rw [key]
  rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  -- `rcases … : …` already substitutes the scrutinee in the goal, so no `rw [hpick]` here; the
  -- two inner stages are still unreduced under the outer `match`, hence their `rw`s remain.
  · rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                             && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
    · rw [hser]
      rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
      · rw [hlin]; exact hord
      · rw [hlin]
        exact pickOrd_irreflOrd (List.mem_of_find?_eq_some hlin) hord haux
          (fun _ _ _ h => findApplicableLinearityRule_applyRule_pair h)
    · rw [hser]
      exact pickOrd_irreflOrd (List.mem_of_find?_eq_some hser) hord haux
        (fun _ _ _ h => findApplicableSerialRule_applyRule_pair h)
  · have hmem : sf ∈ b := by
      unfold findUnexpandedUnblockedWith at hpick
      exact List.mem_of_find?_eq_some hpick
    exact pickOrd_irreflOrd hmem hord haux
      (fun _ _ _ h => findApplicableRule_applyRule_pair h)

/-- **The `.splitOrdered` per-arm orderings are irreflexive.** Arms 1-2 add a single edge between
the two incomparable times, distinct by `firstIncomparablePair_spec`; arm 3 identifies them, and
`irreflOrd_identifyTime` is unconditional. -/
theorem expandOnceUnblocked_splitOrdered_irreflOrd
    {b : Branch} {bs : List (Branch × TimeOrdering)} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hord : IrreflOrd ord)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, IrreflOrd p.2 := by
  obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape h
  obtain ⟨-, -, hne, -, -⟩ := firstIncomparablePair_spec htrig
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact irreflOrd_addFuture hord (Ne.symm hne)
  · exact irreflOrd_addFuture hord hne
  · exact irreflOrd_identifyTime _ _ _

end FormalSystem.Metalogic.Decidability
