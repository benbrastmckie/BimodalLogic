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

/-! ## A6. `OrdTimesLeMaxTime` at the branching shapes

This is the mirrored half of R1. A `.branching` step hands the *same* new ordering to every arm,
so an arm whose formula list omitted the fresh witness would hold an ordering edge to a time
absent from its own branch, and that arm's `nextTime` could then collide with the minted time.

The reading of the four branching mint sites is that this does not happen: `untlPos`, `sncePos`,
and the ACTIVE arms of `untlNeg` and `snceNeg` all build **both** arms at `freshLabel`, so each
arm's head already sits at the fresh time and dominates it. That reading is what the proof below
discharges — the `rfl` supplied for `hg` in each mint case is exactly the claim "this arm's head
sits at `b.nextTime`". -/

/-- The successor branches of a **branching** rule result. The `Option` analogue for the
non-branching shapes is `nonBranchingResultBranch`; the same goal-side phrasing applies, and for
the same reason. -/
def branchingResultBranches (b : Branch) : RuleResult → List Branch
  | .branching bss => bss.map (fun fs => fs ++ b)
  | _ => []

set_option maxHeartbeats 4000000 in
/-- **`applyRule` preserves `OrdTimesLeMaxTime` at the `.branching` result shape**, for every arm.

The `.branchingOrdered` shape is deliberately not covered here: its per-arm orderings live in the
*result* rather than the second component, so it is handled at engine level where the arm list is
visible. -/
theorem applyRule_ordTimes_branching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesLeMaxTime b ord) :
    ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1,
      OrdTimesLeMaxTime nb (applyRule rule sf b ord).2 := by
  have ht : sf.label.time ≤ b.maxTime := le_maxTime hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             -- At a non-branching result `branchingResultBranches` is `[]`, so this `simp only`
             -- turns `hnb` into `False` and closes the goal outright; `all_goals` is what lets
             -- the branching alternatives below run only where a goal survives.
             simp only [branchingResultBranches, List.mem_map, List.not_mem_nil] at hnb
             all_goals first
               | (obtain ⟨fs, hfs, rfl⟩ := hnb
                  simp only [List.mem_cons, List.not_mem_nil, or_false] at hfs
                  rcases hfs with rfl | rfl <;>
                    first
                      | exact ordTimes_addFuture_cons haux ht rfl
                      | exact ordTimes_addPast_cons haux ht rfl)
               | (obtain ⟨fs, -, rfl⟩ := hnb
                  exact ordTimes_mono haux (maxTime_le_append _ _))))

/-- The successor branches of a step at the two shapes that carry the step's **own** ordering:
`.extended` reports one, `.split` reports its arms, and every arm of a split shares the single
ordering in the step's second component. `.splitOrdered` is excluded by construction — it carries
per-arm orderings inside the result, and `expandOnceUnblocked_splitOrdered_shape` is the lemma
that exposes them. -/
def unorderedSuccessorBranches : ExpansionResult → List Branch
  | .extended nb => [nb]
  | .split bs => bs
  | _ => []

/-- The branches a pick hands on, assembled from the two per-shape selectors. -/
private def pickBranches (b : Branch) :
    Option (TableauRule × RuleResult × TimeOrdering) → List Branch
  | none => []
  | some (_, res, _) => (nonBranchingResultBranch b res).toList ++ branchingResultBranches b res

/-- The branch half of `pick_ord_eq`: uniformly across all five `RuleResult` shapes, the
result-tail's successor branches are `pickBranches`. -/
private theorem pick_branches_eq {b : Branch} {ord : TimeOrdering}
    {pick : Option (TableauRule × RuleResult × TimeOrdering)} :
    unorderedSuccessorBranches
      (match pick with
        | none => (ExpansionResult.saturated, ord)
        | some (_, result, newOrd) =>
          match result with
          | .linear fs => (ExpansionResult.extended (fs ++ b), newOrd)
          | .branching bss => (ExpansionResult.split (bss.map fun fs => fs ++ b), newOrd)
          | .branchingOrdered bs' => (ExpansionResult.splitOrdered bs', newOrd)
          | .persistent fs => (ExpansionResult.extended (fs ++ b), newOrd)
          | .notApplicable => (ExpansionResult.saturated, newOrd)).1
      = pickBranches b pick := by
  rcases pick with _ | ⟨r, res, o⟩
  · rfl
  · cases res <;> rfl

/-- **The three-stage pick reports `applyRule`'s own pair for some formula on the branch.**

Packaging the three stages here, with the pick equation in a *hypothesis*, is what keeps the
engine-level proofs free of the nested-`match` reduction problem: `rw … at h` on an equation
hypothesis is the pattern `expandOnceUnblocked_extended_mem` already uses, whereas case-splitting
the same `match` in the goal leaves outer `match none with …` layers that block unification at the
application site. No `none` case is needed — the statement quantifies over a `some`. -/
private theorem pick_stage_source (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) :
    ∀ r res o,
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
           | none => none) = some (r, res, o) →
      ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) := by
  intro r res o h
  rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  · rw [hpick] at h
    rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                             && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
    · rw [hser] at h
      rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
      · rw [hlin] at h
        simp only at h
        exact absurd h (by simp)
      · rw [hlin] at h
        simp only at h
        exact ⟨sf3, List.mem_of_find?_eq_some hlin,
          findApplicableLinearityRule_applyRule_pair h⟩
    · rw [hser] at h
      simp only at h
      exact ⟨sf2, List.mem_of_find?_eq_some hser, findApplicableSerialRule_applyRule_pair h⟩
  · rw [hpick] at h
    simp only at h
    have hmem : sf ∈ b := by
      unfold findUnexpandedUnblockedWith at hpick
      exact List.mem_of_find?_eq_some hpick
    exact ⟨sf, hmem, findApplicableRule_applyRule_pair h⟩

/-- One pick stage preserves `OrdTimesLeMaxTime` at every successor branch it reports. This is
where the non-branching and branching `applyRule` lemmas are joined. -/
private theorem pickBranches_ordTimes {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (haux : OrdTimesLeMaxTime b ord)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ nb ∈ pickBranches b p, OrdTimesLeMaxTime nb (pickOrd ord p) := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA⟩ := hp r res o rfl
    have h1 := applyRule_ordTimes_nonbranching (rule := r) (sf := sf) (b := b) (ord := ord)
      hsf haux
    have h2 := applyRule_ordTimes_branching (rule := r) (sf := sf) (b := b) (ord := ord)
      hsf haux
    rw [hA] at h1 h2
    intro nb hnb
    simp only [pickBranches] at hnb
    rcases List.mem_append.mp hnb with h | h
    · exact h1 nb (by simpa using h)
    · exact h2 nb h

/-- **Engine-level `OrdTimesLeMaxTime`, at `.extended` and at every arm of a `.split`.**

This is the mirrored half of R1 discharged: a `.branching` step does hand the same new ordering
to every arm, and every arm nonetheless dominates the minted time, because all four branching
mint sites build both arms at `freshLabel`. `.saturated` and `.splitOrdered` contribute no
successor branch here by construction. -/
theorem expandOnceUnblocked_ordTimes {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesLeMaxTime b ord) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      OrdTimesLeMaxTime nb (expandOnceUnblocked b ord fc tr).2 := by
  have keyO : (expandOnceUnblocked b ord fc tr).2
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
  have keyB : unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1
      = pickBranches b
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
               | none => none) := pick_branches_eq
  rw [keyO, keyB]
  exact pickBranches_ordTimes haux (pick_stage_source b ord fc tr)

/-! ### `OrdTimesLeMaxTime` is REFUTED at the ordered split's identification arm

The statement above stops at `.extended` and `.split` for a reason that is a **fact, not a gap**.
`Branch.identifyTime t₂ t₁` can *lower* `Branch.maxTime` — it does so exactly when `t₂` was the
branch's largest time and `t₁` is smaller — while `TimeOrdering.identifyTime` leaves any
constraint not mentioning `t₂` completely untouched. A constraint whose times sit strictly
between `t₁` and `t₂` therefore survives the arm while the bound it was measured against drops
below it.

The refuting configuration below is machine-checked, and it belongs on the do-not-re-attempt
register alongside `witnessPresent_identifyTime_unconditional_false`: a future reader who assumes
`OrdTimesLeMaxTime` is a run invariant across *every* engine step will be re-attempting a refuted
statement.

**What this does and does not say.** It says the invariant *as defined* is not preserved by the
identification arm. It does not say the configuration is reachable from `initialBranch` — the
constraint `(3, 4)` mentions two times no formula on the branch carries, and every ordering edge
the engine actually builds runs between a branch time and a freshly minted one. Closing that gap
needs a **strictly stronger** invariant ("every ordering time is a *known branch time*", not
merely "≤ `maxTime`"), which is preserved at the arm because `rho` maps known times to known
times. That strengthening is not made here: `OrdTimesLeMaxTime` is what the landed density and
non-branching results already consume, and changing it would reopen them. -/

/-- **Counterexample: the identification arm does not preserve `OrdTimesLeMaxTime`.**

All four conjuncts are decided. The first three establish that the configuration is a *genuine*
ordered-split trigger satisfying both standing hypotheses — the ordering is irreflexive, the
invariant holds before the step, and `firstIncomparablePair` really does select `(0, 5)` — so the
failure in the fourth conjunct is attributable to the arm itself rather than to a violated
precondition. The branch's largest time `5` is the one identified away, and the surviving
constraint `(3, 4)` then exceeds the collapsed `maxTime` of `0`. -/
theorem ordTimes_identifyTime_arm3_false :
    letI p : Formula := .atom ⟨"p", none⟩
    letI q : Formula := .atom ⟨"q", none⟩
    letI b : Branch := [⟨.pos, p, ⟨0, 0⟩⟩, ⟨.pos, q, ⟨0, 5⟩⟩]
    letI ord : TimeOrdering := ⟨[(3, 4)]⟩
    IrreflOrd ord ∧ OrdTimesLeMaxTime b ord ∧
      firstIncomparablePair b ord = some (0, 5) ∧
      ¬ OrdTimesLeMaxTime (b.identifyTime 5 0) (ord.identifyTime 5 0) := by
  refine ⟨?_, ?_, by decide, ?_⟩
  · unfold IrreflOrd; decide
  · unfold OrdTimesLeMaxTime; decide
  · unfold OrdTimesLeMaxTime; decide

/-! ## A7. `OrdTimesKnown` — the strengthened ordering-times invariant

### Do-not-re-attempt

The preservation of `OrdTimesLeMaxTime` across the ordered split's identification arm is
**REFUTED**, not merely unproved: `ordTimes_identifyTime_arm3_false` just above decides a
configuration in which both standing hypotheses hold, `firstIncomparablePair` really does fire,
and the invariant nonetheless fails after the arm. A reader who assumes `OrdTimesLeMaxTime` is a
run invariant across *every* engine step — or who later "simplifies" the run invariant back to the
`≤ maxTime` form — is re-attempting a refuted statement.

The settled repair is `OrdTimesKnown` below, with `ordTimesKnown_identifyTime` supplying the arm-3
preservation the weak form cannot have. `ordTimesLeMaxTime_of_ordTimesKnown` records that this is a
**strengthening** rather than a weakening: every landed `OrdTimesLeMaxTime` result stays true, stays
in source, and stays reachable.

Root cause of the refutation, restated so the repair is legible: `Branch.identifyTime` measures the
ordering against a bound (`Branch.maxTime`) that the arm is free to move *downward* underneath a
surviving constraint. Membership in `Branch.knownTimes` has no such defect, because the arm relabels
the branch and the ordering by the **same** function `rho`, so the two move together. -/

/-- **The strengthened ordering-times invariant**: every time mentioned by the ordering is a
*known branch time*, rather than merely `≤ b.maxTime`.

This strengthens `OrdTimesLeMaxTime`, and `ordTimesLeMaxTime_of_ordTimesKnown` is the witness —
the weak form is derivable from this one, so every landed `OrdTimesLeMaxTime` consumer keeps
working and none of its producers is disturbed. The strengthening is necessary rather than
cosmetic: the weak form is **refuted** at the ordered split's identification arm by
`ordTimes_identifyTime_arm3_false`, while this form survives it unconditionally
(`ordTimesKnown_identifyTime`). -/
def OrdTimesKnown (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes

/-! ### Basic `knownTimes` facts -/

/-- A branch formula's time is a known time. -/
theorem mem_knownTimes_of_mem {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.time ∈ b.knownTimes := by
  simp only [Branch.knownTimes, List.mem_eraseDups, List.mem_map]
  exact ⟨sf, h, rfl⟩

/-- Conversely, a known time is carried by some branch formula. -/
theorem exists_mem_of_mem_knownTimes {b : Branch} {t : TimeIndex} (h : t ∈ b.knownTimes) :
    ∃ sf ∈ b, sf.label.time = t := by
  simp only [Branch.knownTimes, List.mem_eraseDups, List.mem_map] at h
  obtain ⟨sf, hsf, hEq⟩ := h
  exact ⟨sf, hsf, hEq⟩

/-- A known time is at or below `maxTime`. -/
theorem le_maxTime_of_mem_knownTimes {b : Branch} {t : TimeIndex} (h : t ∈ b.knownTimes) :
    t ≤ b.maxTime := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  exact le_maxTime hsf

/-- **The strengthening witness.** The strong invariant implies the weak one.

This is what makes the move to `OrdTimesKnown` a *strengthening* rather than the forbidden
weakening: every landed `OrdTimesLeMaxTime` consumer — `applyRule_irreflOrd` above chief among
them — keeps working unchanged, reached from the strong form through this one lemma. None of the
weak form's four producer lemmas is deleted, renamed, or restated; they remain true and simply go
unused by the strong chain. -/
theorem ordTimesLeMaxTime_of_ordTimesKnown {b : Branch} {ord : TimeOrdering}
    (h : OrdTimesKnown b ord) : OrdTimesLeMaxTime b ord := fun p hp =>
  ⟨le_maxTime_of_mem_knownTimes (h p hp).1, le_maxTime_of_mem_knownTimes (h p hp).2⟩

/-- **The refuting configuration dies under the strengthened invariant.**

The exact branch and ordering that refute `OrdTimesLeMaxTime` preservation at the identification
arm (`ordTimes_identifyTime_arm3_false` above) fail `OrdTimesKnown` at their *input*: the
constraint `(3, 4)` mentions two times no formula on the branch carries. So the counterexample
does not transfer, and the strengthening is not merely a different statement but a live repair. -/
theorem counterexample_dies :
    letI p : Formula := .atom ⟨"p", none⟩
    letI q : Formula := .atom ⟨"q", none⟩
    letI b : Branch := [⟨.pos, p, ⟨0, 0⟩⟩, ⟨.pos, q, ⟨0, 5⟩⟩]
    letI ord : TimeOrdering := ⟨[(3, 4)]⟩
    ¬ OrdTimesKnown b ord := by
  unfold OrdTimesKnown; decide

/-! ### Arm-3 preservation — the crux

`Branch.identifyTime` relabels by `rho src tgt`; `TimeOrdering.identifyTime` relabels its
constraint components by the same function. So the two move together, and membership survives. -/

/-- The branch half of the renaming acts on known times exactly as `rho` does. -/
theorem mem_knownTimes_identifyTime {b : Branch} {src tgt t : TimeIndex}
    (h : t ∈ b.knownTimes) : rho src tgt t ∈ (b.identifyTime src tgt).knownTimes := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  refine mem_knownTimes_of_mem (sf := rhoSF src tgt sf) ?_
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map]
  refine ⟨sf, hsf, ?_⟩
  by_cases hc : sf.label.time = src
  · simp [rhoSF, rho, hc]
  · simp [rhoSF, rho, hc]

/-- **Arm-3 preservation.** `OrdTimesKnown` IS preserved by the ordered split's identification arm.

Note it needs **no trigger hypotheses at all** — not `firstIncomparablePair`, not `IrreflOrd`. It
is a pure structural fact about branch and ordering being relabelled by the same `rho`, which is
strictly better than the weak form: `ordTimes_identifyTime_arm3_false` shows the weak form fails
here even *with* both hypotheses in hand. -/
theorem ordTimesKnown_identifyTime {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : OrdTimesKnown b ord) :
    OrdTimesKnown (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁) := by
  rintro ⟨a, c⟩ hp
  simp only [TimeOrdering.identifyTime, List.mem_eraseDups, List.mem_filterMap] at hp
  obtain ⟨⟨x, y⟩, hxy, hres⟩ := hp
  by_cases hAB : (if x == t₂ then t₁ else x) = (if y == t₂ then t₁ else y)
  · rw [if_pos (by simpa using hAB)] at hres
    exact absurd hres (by simp)
  · rw [if_neg (by simpa using hAB)] at hres
    simp only [Option.some.injEq, Prod.mk.injEq] at hres
    obtain ⟨rfl, rfl⟩ := hres
    obtain ⟨hx, hy⟩ := h (x, y) hxy
    constructor
    · have := mem_knownTimes_identifyTime (src := t₂) (tgt := t₁) hx
      simpa only [rho, beq_iff_eq] using this
    · have := mem_knownTimes_identifyTime (src := t₂) (tgt := t₁) hy
      simpa only [rho, beq_iff_eq] using this

/-! ### Preservation at the mint sites

It is no use fixing arm 3 if the stronger invariant breaks at a mint site where the weaker one
held. The mint sites state their invariant against the POST-step branch `g :: rest ++ b`, where
`g` is the witness sitting at `b.nextTime`. -/

/-- Known times survive branch growth. -/
theorem knownTimes_mono {b nb : Branch} {t : TimeIndex} (hsub : ∀ x ∈ b, x ∈ nb)
    (h : t ∈ b.knownTimes) : t ∈ nb.knownTimes := by
  obtain ⟨sf, hsf, rfl⟩ := exists_mem_of_mem_knownTimes h
  exact mem_knownTimes_of_mem (hsub sf hsf)

/-- The strong invariant survives branch growth on its own, when the ordering does not change.
The `OrdTimesKnown` analogue of `ordTimes_mono`. -/
theorem ordTimesKnown_mono {b nb : Branch} {ord : TimeOrdering}
    (haux : OrdTimesKnown b ord) (hsub : ∀ x ∈ b, x ∈ nb) : OrdTimesKnown nb ord :=
  fun p hp => ⟨knownTimes_mono hsub (haux p hp).1, knownTimes_mono hsub (haux p hp).2⟩

/-- A mint step's new branch KNOWS the fresh time, because the witness sits there.
The `OrdTimesKnown` analogue of `nextTime_le_maxTime_cons`. -/
theorem nextTime_mem_knownTimes_cons {b : Branch} {g : SignedFormula}
    {rest : List SignedFormula} (hg : g.label.time = b.nextTime) :
    b.nextTime ∈ Branch.knownTimes (g :: rest ++ b) :=
  hg ▸ mem_knownTimes_of_mem (List.mem_append_left b List.mem_cons_self)

/-- Branch growth by prepending any list. Stated for a general `fs` rather than the `g :: rest`
shape, so it also covers the `.linear []` / `.persistent []` arms where the branch is unchanged. -/
private theorem sub_append {b : Branch} {fs : List SignedFormula} :
    ∀ x ∈ b, x ∈ (fs ++ b) := fun _ hx => List.mem_append_right _ hx

/-- Single-edge `addFuture` mint step preserves the strong invariant. -/
theorem ordTimesKnown_addFuture_cons {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime) :
    OrdTimesKnown (g :: rest ++ b) (ord.addFuture t b.nextTime) := by
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | hp
  · exact ⟨knownTimes_mono sub_append ht, nextTime_mem_knownTimes_cons hg⟩
  · exact ordTimesKnown_mono haux sub_append p hp

/-- Single-edge `addPast` mint step preserves the strong invariant. -/
theorem ordTimesKnown_addPast_cons {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime) :
    OrdTimesKnown (g :: rest ++ b) (ord.addPast t b.nextTime) := by
  intro p hp
  simp only [TimeOrdering.addPast, List.mem_cons] at hp
  rcases hp with rfl | hp
  · exact ⟨nextTime_mem_knownTimes_cons hg, knownTimes_mono sub_append ht⟩
  · exact ordTimesKnown_mono haux sub_append p hp

/-- `densityRule`'s two-edge mint step preserves the strong invariant.
The extra obligation is `t' ∈ b.knownTimes`, supplied by the invariant applied to the constraint
that put `t'` in the reach. -/
theorem ordTimesKnown_density_cons {b : Branch} {ord : TimeOrdering} {t t' : TimeIndex}
    {P : TimeIndex → Bool} {tail : List TimeIndex}
    {g : SignedFormula} {rest : List SignedFormula}
    (haux : OrdTimesKnown b ord) (ht : t ∈ b.knownTimes)
    (hg : g.label.time = b.nextTime)
    (heq : (ord.futureOf t).filter P = t' :: tail) :
    OrdTimesKnown (g :: rest ++ b) ((ord.addFuture t b.nextTime).addFuture b.nextTime t') := by
  have hmem : t' ∈ ord.futureOf t :=
    List.mem_of_mem_filter (by rw [heq]; exact List.mem_cons_self)
  obtain ⟨x, hx⟩ := exists_constraint_to_of_mem_futureOf ord t t' hmem
  have ht' : t' ∈ b.knownTimes := (haux (x, t') hx).2
  intro p hp
  simp only [TimeOrdering.addFuture, List.mem_cons] at hp
  rcases hp with rfl | rfl | hp
  · exact ⟨nextTime_mem_knownTimes_cons hg, knownTimes_mono sub_append ht'⟩
  · exact ⟨knownTimes_mono sub_append ht, nextTime_mem_knownTimes_cons hg⟩
  · exact ordTimesKnown_mono haux sub_append p hp

set_option maxHeartbeats 4000000 in
/-- **`applyRule` preserves `OrdTimesKnown` at the non-branching result shapes** — the strong
analogue of `applyRule_ordTimes_nonbranching`, proved by the same tactic skeleton with the three
`_cons` lemmas swapped for their strong forms.

This is the load-bearing check: the strong invariant survives every one of the nine mint sites, so
nothing that held under the weak form is lost by strengthening. -/
theorem applyRule_ordTimesKnown_nonbranching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ nonBranchingResultBranch b (applyRule rule sf b ord).1,
      OrdTimesKnown nb (applyRule rule sf b ord).2 := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
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
                    | exact ordTimesKnown_mono haux sub_append
                    | exact ordTimesKnown_addFuture_cons haux ht rfl
                    | exact ordTimesKnown_addPast_cons haux ht rfl
                    | exact ordTimesKnown_density_cons haux ht rfl (by assumption))
               | exact absurd hnb (by simp)))

/-- **Both non-identification arms of the ordered split preserve the strong invariant.**

Arms 1 and 2 keep the branch literally and add one ordering edge between the incomparable pair.
The strong invariant needs `t₁, t₂ ∈ b.knownTimes`, and the trigger supplies exactly that —
`firstIncomparablePair` scans `b.knownTimes`, so `firstIncomparablePair_spec` hands the two
membership facts over directly. This engine-level site is therefore free. -/
theorem ordTimesKnown_splitOrdered_arms12 {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (haux : OrdTimesKnown b ord) :
    OrdTimesKnown b (ord.addFuture t₁ t₂) ∧ OrdTimesKnown b (ord.addFuture t₂ t₁) := by
  obtain ⟨h1, h2, -, -, -⟩ := firstIncomparablePair_spec htrig
  constructor <;> (intro p hp
                   simp only [TimeOrdering.addFuture, List.mem_cons] at hp
                   rcases hp with rfl | hp)
  · exact ⟨h1, h2⟩
  · exact haux p hp
  · exact ⟨h2, h1⟩
  · exact haux p hp

/-! ### The strong form re-derives the weak form's consumers unchanged -/

/-- `applyRule_irreflOrd` — the headline irreflexivity result above — is reachable from the strong
invariant with **no change to its proof**, by composing with `ordTimesLeMaxTime_of_ordTimesKnown`.
This is the concrete evidence that adding `OrdTimesKnown` alongside `OrdTimesLeMaxTime` touches no
already-proved result. -/
theorem applyRule_irreflOrd_from_known {rule : TableauRule} {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} (hsf : sf ∈ b) (hord : IrreflOrd ord)
    (haux : OrdTimesKnown b ord) : IrreflOrd (applyRule rule sf b ord).2 :=
  applyRule_irreflOrd hsf hord (ordTimesLeMaxTime_of_ordTimesKnown haux)

/-- Likewise the density second-edge fact. -/
theorem ne_nextTime_from_known {b : Branch} {ord : TimeOrdering} {s t : TimeIndex}
    (haux : OrdTimesKnown b ord) (h : t ∈ ord.futureOf s) : b.nextTime ≠ t :=
  ne_nextTime_of_mem_futureOf (ordTimesLeMaxTime_of_ordTimesKnown haux) h

/-- **The initial condition.** The strong invariant holds at the engine's seed ordering.

This is **vacuously true, and the vacuity is a property of the seed rather than of a narrowed
statement**: `TimeOrdering.empty` is defined with `constraints := []`, and every engine run starts
there — both `buildTableauAt` and `buildTableau` call `expandBranchWithFuel` with
`TimeOrdering.empty` as the initial ordering. So there is no constraint to check, for any branch
whatsoever.

The distinction matters enough to state. A later reader meeting a base case that discharges by
`simp` must be able to tell, without re-deriving anything, that nothing was weakened to make it
close. The base case is vacuous; the inductive step — `applyRule_ordTimesKnown_nonbranching`,
`ordTimesKnown_splitOrdered_arms12`, and `ordTimesKnown_identifyTime` — carries all the content,
and none of those three is vacuous. -/
theorem ordTimesKnown_empty (b : Branch) : OrdTimesKnown b TimeOrdering.empty := by
  intro p hp
  simp [TimeOrdering.empty] at hp

/-! ### `OrdTimesKnown` at the branching shapes and at engine level

The weak engine-level twins just above — `applyRule_ordTimes_branching`, `pickBranches_ordTimes`,
`expandOnceUnblocked_ordTimes`, `expandOnceUnblocked_irreflOrd` — are **retained and still true**.
They are not superseded in the sense of being wrong; they are what the strong forms compose
through, and `expandOnceUnblocked_irreflOrd_of_known` below is literally one line of composition
over `expandOnceUnblocked_irreflOrd`.

The strong forms exist for one reason only: the weak invariant is **not carryable across the
ordered split's identification arm**, by `ordTimes_identifyTime_arm3_false`. An engine-level
statement threaded through `OrdTimesLeMaxTime` therefore cannot become a run invariant, however
many result shapes it covers. -/

set_option maxHeartbeats 4000000 in
/-- **`applyRule` preserves `OrdTimesKnown` at the `.branching` result shape**, for every arm —
the strong analogue of `applyRule_ordTimes_branching`.

Proved by that theorem's own tactic skeleton, with `le_maxTime hsf` replaced by
`mem_knownTimes_of_mem hsf`, the two `_cons` lemmas replaced by their `ordTimesKnown_*` twins, and
the ordering-unchanged case discharged by `ordTimesKnown_mono … sub_append` where the weak form
used `ordTimes_mono … (maxTime_le_append _ _)`. Branch growth is identical: every arm is `fs ++ b`.

As with the weak twin, the `.branchingOrdered` shape is deliberately not covered here — its
per-arm orderings live in the *result* rather than the second component, so it is handled at
engine level where the arm list is visible. -/
theorem applyRule_ordTimesKnown_branching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1,
      OrdTimesKnown nb (applyRule rule sf b ord).2 := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             -- At a non-branching result `branchingResultBranches` is `[]`, so this `simp only`
             -- turns `hnb` into `False` and closes the goal outright; `all_goals` is what lets
             -- the branching alternatives below run only where a goal survives.
             simp only [branchingResultBranches, List.mem_map, List.not_mem_nil] at hnb
             all_goals first
               | (obtain ⟨fs, hfs, rfl⟩ := hnb
                  simp only [List.mem_cons, List.not_mem_nil, or_false] at hfs
                  rcases hfs with rfl | rfl <;>
                    first
                      | exact ordTimesKnown_addFuture_cons haux ht rfl
                      | exact ordTimesKnown_addPast_cons haux ht rfl)
               | (obtain ⟨fs, -, rfl⟩ := hnb
                  exact ordTimesKnown_mono haux sub_append)))

/-- One pick stage preserves `OrdTimesKnown` at every successor branch it reports. This is where
the non-branching and branching `applyRule` lemmas are joined, exactly as `pickBranches_ordTimes`
joins their weak twins. `pick_stage_source` is reused unchanged — it is invariant-agnostic. -/
private theorem pickBranches_ordTimesKnown {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (haux : OrdTimesKnown b ord)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ nb ∈ pickBranches b p, OrdTimesKnown nb (pickOrd ord p) := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA⟩ := hp r res o rfl
    have h1 := applyRule_ordTimesKnown_nonbranching (rule := r) (sf := sf) (b := b) (ord := ord)
      hsf haux
    have h2 := applyRule_ordTimesKnown_branching (rule := r) (sf := sf) (b := b) (ord := ord)
      hsf haux
    rw [hA] at h1 h2
    intro nb hnb
    simp only [pickBranches] at hnb
    rcases List.mem_append.mp hnb with h | h
    · exact h1 nb (by simpa using h)
    · exact h2 nb h

/-- **Engine-level `OrdTimesKnown`, at `.extended` and at every arm of a `.split`.**

The strong analogue of `expandOnceUnblocked_ordTimes`, reusing the invariant-agnostic `pick_ord_eq`
and `pick_branches_eq` unchanged. `.saturated` contributes no successor branch; `.splitOrdered`
carries per-arm orderings inside the result and is handled by
`expandOnceUnblocked_splitOrdered_ordTimesKnown`. -/
theorem expandOnceUnblocked_ordTimesKnown {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      OrdTimesKnown nb (expandOnceUnblocked b ord fc tr).2 := by
  have keyO : (expandOnceUnblocked b ord fc tr).2
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
  have keyB : unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1
      = pickBranches b
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
               | none => none) := pick_branches_eq
  rw [keyO, keyB]
  exact pickBranches_ordTimesKnown haux (pick_stage_source b ord fc tr)

/-- **Engine-level irreflexivity from the strong invariant.**

No case analysis is re-done here: this composes the landed `expandOnceUnblocked_irreflOrd` with
`ordTimesLeMaxTime_of_ordTimesKnown`. It exists so that a run carrying `OrdTimesKnown` can feed
irreflexivity without also carrying the weak invariant separately. -/
theorem expandOnceUnblocked_irreflOrd_of_known {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hord : IrreflOrd ord) (haux : OrdTimesKnown b ord) :
    IrreflOrd (expandOnceUnblocked b ord fc tr).2 :=
  expandOnceUnblocked_irreflOrd hord (ordTimesLeMaxTime_of_ordTimesKnown haux)

/-! ## A8. The run invariant

This section closes the obligation the weak invariant could not meet.

`OrdTimesLeMaxTime` is **refuted** at the ordered split's identification arm
(`ordTimes_identifyTime_arm3_false`), so no amount of engine-level plumbing could have made the
pair `(IrreflOrd, OrdTimesLeMaxTime)` into a run invariant: a single ordered split destroys the
second component, and `IrreflOrd`'s own preservation at `applyRule` consumes it. The repair is
`ordTimesKnown_identifyTime`, which survives that same arm **unconditionally** — with neither the
`firstIncomparablePair` trigger nor `IrreflOrd` in hand — because branch and ordering are relabelled
by the same `rho`.

With arm 3 supplied, all three ordered-split arms close (`ordTimesKnown_splitOrdered_arms12` for
arms 1-2), and `RunInvariant` below is carryable across **every** expansion step. -/

/-- **The ordered split preserves `OrdTimesKnown` at all three arms** — the deliverable the
strengthening exists for.

`expandOnceUnblocked_splitOrdered_shape` supplies the exact three-arm list together with the
trigger. Arms 1-2 keep the branch literally and add one edge between the incomparable pair, closed
by `ordTimesKnown_splitOrdered_arms12` from the trigger alone; arm 3 is `ordTimesKnown_identifyTime`,
which needs neither the trigger nor `IrreflOrd`. -/
theorem expandOnceUnblocked_splitOrdered_ordTimesKnown
    {b : Branch} {bs : List (Branch × TimeOrdering)} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord)
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∀ p ∈ bs, OrdTimesKnown p.1 p.2 := by
  obtain ⟨t₁, t₂, htrig, rfl⟩ := expandOnceUnblocked_splitOrdered_shape h
  obtain ⟨harm1, harm2⟩ := ordTimesKnown_splitOrdered_arms12 htrig haux
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact harm1
  · exact harm2
  · exact ordTimesKnown_identifyTime haux

/-- **The run invariant.** Irreflexivity of the ordering, plus every ordering time being a known
branch time.

Bundled under one name so the fuel induction and its consumers carry a single hypothesis rather
than spelling out a two-element bundle at every call site. The weak form `OrdTimesLeMaxTime` is
available from it by projection (`RunInvariant.ordTimesLeMaxTime`) wherever a landed consumer wants
it, so bundling loses nothing. -/
def RunInvariant (b : Branch) (ord : TimeOrdering) : Prop :=
  IrreflOrd ord ∧ OrdTimesKnown b ord

/-- The irreflexivity component. -/
theorem RunInvariant.irreflOrd {b : Branch} {ord : TimeOrdering} (h : RunInvariant b ord) :
    IrreflOrd ord := h.1

/-- The ordering-times component, in its strong form. -/
theorem RunInvariant.ordTimesKnown {b : Branch} {ord : TimeOrdering} (h : RunInvariant b ord) :
    OrdTimesKnown b ord := h.2

/-- The ordering-times component in the **weak** form the landed `OrdTimesLeMaxTime` consumers
take. This is the projection that keeps every already-proved result reachable. -/
theorem RunInvariant.ordTimesLeMaxTime {b : Branch} {ord : TimeOrdering} (h : RunInvariant b ord) :
    OrdTimesLeMaxTime b ord := ordTimesLeMaxTime_of_ordTimesKnown h.2

/-- **The run invariant holds at every successor of an unblocked expansion step**, across all four
`ExpansionResult` shapes.

The first conjunct covers `.extended` (one successor) and `.split` (its arms), which share the
step's own second-component ordering. The second conjunct covers `.splitOrdered`, whose per-arm
orderings live inside the result. `.saturated` produces no successor branch and satisfies both
conjuncts vacuously — by absence of successors, not by any weakening of the statement. -/
theorem expandOnceUnblocked_runInvariant {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hinv : RunInvariant b ord) :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        RunInvariant nb (expandOnceUnblocked b ord fc tr).2) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, RunInvariant p.1 p.2) := by
  obtain ⟨hord, haux⟩ := hinv
  constructor
  · intro nb hnb
    exact ⟨expandOnceUnblocked_irreflOrd_of_known hord haux,
      expandOnceUnblocked_ordTimesKnown haux nb hnb⟩
  · intro bs h p hp
    exact ⟨expandOnceUnblocked_splitOrdered_irreflOrd hord h p hp,
      expandOnceUnblocked_splitOrdered_ordTimesKnown haux h p hp⟩

/-- **The initial condition.** The run invariant holds at the engine's seed ordering, for every
branch.

Both components are **vacuously true, and the vacuity is a property of the seed rather than of a
narrowed statement**: `TimeOrdering.empty` has `constraints := []`, so there is no constraint to be
irreflexive about and none whose times need to be known. Every engine run starts there — both
`buildTableauAt` and `buildTableau` seed `expandBranchWithFuel` with `TimeOrdering.empty`.

Stated with the same care as `ordTimesKnown_empty`: a base case discharged by `simp` here is not
evidence that anything was weakened to make it close. The content lives in
`expandOnceUnblocked_runInvariant`, whose three ordered-split arms and nine mint sites are each
discharged by a non-vacuous lemma. -/
theorem runInvariant_initial (b : Branch) : RunInvariant b TimeOrdering.empty := by
  refine ⟨?_, ordTimesKnown_empty b⟩
  intro t ht
  simp [TimeOrdering.empty] at ht

/-! ## B4. `witnessPresent` monotonicity

Every clause of `witnessPresent` is a **positive** combination of `Branch.contains` tests and
`knownWorlds` / `futureOf` / `pastOf` membership tests, joined only by `any`, `||` and `&&`. There
is no negation anywhere in its body, so it is monotone in the branch and monotone in the ordering
separately. That is what makes "a witness, once present, stays present" available to the counting
argument, and it is read off the definition rather than assumed. -/

/-- `Branch.contains` is monotone in the branch. -/
theorem contains_mono {b nb : Branch} {sf : SignedFormula} (hsub : ∀ x ∈ b, x ∈ nb)
    (h : b.contains sf = true) : nb.contains sf = true := by
  simp only [Branch.contains, List.any_eq_true] at h ⊢
  obtain ⟨x, hx, hxe⟩ := h
  exact ⟨x, hsub x hx, hxe⟩

/-- Known worlds survive branch growth. The `knownWorlds` mirror of `knownTimes_mono`. -/
theorem knownWorlds_mono {b nb : Branch} {w : WorldIndex} (hsub : ∀ x ∈ b, x ∈ nb)
    (h : w ∈ b.knownWorlds) : w ∈ nb.knownWorlds := by
  simp only [Branch.knownWorlds, List.mem_eraseDups, List.mem_map] at h ⊢
  obtain ⟨sf, hsf, rfl⟩ := h
  exact ⟨sf, hsub sf hsf, rfl⟩

/-- **`witnessPresent` is monotone in the branch.** A witness found on a branch is still found on
any larger branch: each of the eight real arms is a `knownWorlds`/`futureOf`/`pastOf` search whose
body is a positive combination of `Branch.contains` tests, and only the `contains` tests and the
`knownWorlds` search depend on the branch. -/
theorem witnessPresent_branch_mono {rule : TableauRule} {sf : SignedFormula}
    {b nb : Branch} {ord : TimeOrdering} (hsub : ∀ x ∈ b, x ∈ nb) :
    witnessPresent rule sf b ord = true → witnessPresent rule sf nb ord = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> cases sign <;> simp only [witnessPresent] <;> (repeat' split) <;>
      (try simp only [List.any_eq_true, Bool.or_eq_true, Bool.and_eq_true]) <;>
      first
        | exact fun h => Bool.noConfusion h
        | (rintro ⟨x, hx, hc⟩
           refine ⟨x, ?_, ?_⟩
           · first
               | exact hx
               | exact knownWorlds_mono hsub hx
           · first
               | exact contains_mono hsub hc
               | (rcases hc with hc | ⟨h1, h2⟩
                  · exact Or.inl (contains_mono hsub hc)
                  · exact Or.inr ⟨contains_mono hsub h1, contains_mono hsub h2⟩))

set_option maxHeartbeats 4000000 in
/-- **`witnessPresent` is monotone in the ordering.** Only the `futureOf` / `pastOf` searches
depend on the ordering, and both are monotone in the constraint list by the landed `futureOf_mono`
and `pastOf_mono`. The `knownWorlds` arms do not mention the ordering at all.

Carries the module's standing `maxHeartbeats 4000000`: the reachability-monotonicity lemmas are
tried by `first` across every arm of the 36-constructor × 2-sign split, and `futureOf_mono`'s
unification is not cheap. The figure is the one already established elsewhere in this module; it is
not raised. -/
theorem witnessPresent_ord_mono {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord ord' : TimeOrdering}
    (hsub : ∀ p ∈ ord.constraints, p ∈ ord'.constraints) :
    witnessPresent rule sf b ord = true → witnessPresent rule sf b ord' = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> cases sign <;> simp only [witnessPresent] <;> (repeat' split) <;>
      (try simp only [List.any_eq_true, Bool.or_eq_true, Bool.and_eq_true]) <;>
      first
        | exact fun h => Bool.noConfusion h
        | (rintro ⟨x, hx, hc⟩
           refine ⟨x, ?_, hc⟩
           first
             | exact hx
             | exact TimeOrdering.futureOf_mono hsub _ _ hx
             | exact TimeOrdering.pastOf_mono hsub _ _ hx)

/-! ## B5. Engine-level growth, and one-step witness preservation

The two monotonicity lemmas above are stated against **abstract** growth hypotheses. Applying them
at an expansion step needs both growth facts supplied at engine level, and only one of the two was
available:

* **Branch growth** — `expandOnceUnblocked_split_subset` covers `.split`, and the `.extended`
  shape is `fs ++ b`; `expandOnceUnblocked_extended_shape` below records that shape and
  `expandOnceUnblocked_branch_mono` joins the two.
* **Ordering growth** — nothing like it was landed. `applyRule_ord_mono` proves it at rule level
  by the same case analysis the invariant lemmas use, and `expandOnceUnblocked_ord_mono` lifts it
  through the three pick stages.

Arm 3 of the ordered split is the one place where **neither** growth fact holds: the ordering is
*relabelled* there rather than extended, and the branch is `Branch.identifyTime`, which is not a
superset of the branch it came from. That arm is supplied instead by `arm3_preserves_witness`, and
it is why the `.splitOrdered` half of the statement below carries a disjunction over the
renaming. -/

/-- **`applyRule` never deletes an ordering constraint.**

Every rule either hands `ord` straight back, or prepends one edge (`addFuture` at the five forward
mint sites, `addPast` at the four backward ones), or prepends two (`densityRule`). `timeLinearity`
returns `ord` itself in this component — its per-arm orderings live inside the result, and their
growth is read off `expandOnceUnblocked_splitOrdered_shape` instead.

This is the ordering half of the growth `witnessPresent_ord_mono` consumes, and it did not exist
before: the landed `addFuture_constraints_mono` is a fact about one `TimeOrdering` operation, not
about `applyRule`'s ordering component. -/
theorem applyRule_ord_mono (rule : TableauRule) (sf : SignedFormula)
    (b : Branch) (ord : TimeOrdering) :
    ∀ q ∈ ord.constraints, q ∈ (applyRule rule sf b ord).2.constraints := by
  cases sf with
  | mk sign formula label =>
    cases rule <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro q hq
             first
               | exact hq
               | (simp only [TimeOrdering.addFuture, TimeOrdering.addPast, List.mem_cons]
                  tauto)))

/-- One pick stage never deletes an ordering constraint. The `none` stage threads `ord` through
unchanged; a `some` stage hands on `applyRule`'s own ordering, and `pick_stage_source` supplies the
formula it was called with. -/
private theorem pickOrd_mono {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ q ∈ ord.constraints, q ∈ (pickOrd ord p).constraints := by
  rcases p with _ | ⟨r, res, o⟩
  · exact fun _ hq => hq
  · obtain ⟨sf, -, hA⟩ := hp r res o rfl
    have h1 := applyRule_ord_mono r sf b ord
    rw [hA] at h1
    exact h1

/-- **Engine-level ordering growth.** An unblocked expansion step never deletes an ordering
constraint from the step's own second component.

The `.splitOrdered` per-arm orderings are *not* covered by this — arm 3 relabels rather than
extends — and they are handled directly from `expandOnceUnblocked_splitOrdered_shape` in
`expandOnceUnblocked_preserves_witness`. -/
theorem expandOnceUnblocked_ord_mono {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    ∀ q ∈ ord.constraints, q ∈ (expandOnceUnblocked b ord fc tr).2.constraints := by
  have keyO : (expandOnceUnblocked b ord fc tr).2
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
  rw [keyO]
  exact pickOrd_mono (pick_stage_source b ord fc tr)

/-- **Engine-level shape of an `.extended` step**: the reported branch is the picked rule's formula
list appended to the branch. The `.extended` mirror of `expandOnceUnblocked_split_shape`, which
`Fuel.lean` supplies for `.split` but not for `.extended`. -/
theorem expandOnceUnblocked_extended_shape {b nb : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb) :
    ∃ fs : List SignedFormula, nb = fs ++ b := by
  unfold expandOnceUnblocked at h
  obtain ⟨_, fs, _, -, hnb⟩ := pick_extended h
  exact ⟨fs, hnb⟩

/-- **Engine-level branch growth**, at `.extended` and at every arm of a `.split`. Both shapes
append to the branch rather than replacing it: `.extended` by the shape lemma just above, `.split`
by the landed `expandOnceUnblocked_split_subset`. `.saturated` and `.splitOrdered` contribute no
unordered successor, so they hold by absence. -/
theorem expandOnceUnblocked_branch_mono {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ b, x ∈ nb := by
  rcases hres : (expandOnceUnblocked b ord fc tr).1 with _ | nb' | bs | bs
  · simp [unorderedSuccessorBranches]
  · obtain ⟨fs, rfl⟩ := expandOnceUnblocked_extended_shape hres
    intro nb hnb x hx
    simp only [unorderedSuccessorBranches, List.mem_cons, List.not_mem_nil, or_false] at hnb
    subst hnb
    exact List.mem_append_right fs hx
  · intro nb hnb x hx
    simp only [unorderedSuccessorBranches] at hnb
    exact expandOnceUnblocked_split_subset hres hnb x hx
  · simp [unorderedSuccessorBranches]

/-- **One expansion step preserves a present witness**, across all four `ExpansionResult` shapes.

The first conjunct covers `.extended` (one successor) and `.split` (its arms), which share the
step's own ordering: the branch only grows (`expandOnceUnblocked_branch_mono`) and the ordering only
grows (`expandOnceUnblocked_ord_mono`), so the two monotonicity lemmas compose.

The second conjunct covers `.splitOrdered`, whose per-arm orderings live inside the result. Arms 1
and 2 keep the branch literally and add one edge between the incomparable pair, so ordering
monotonicity alone suffices; **arm 3** relabels both branch and ordering, and is
`arm3_preserves_witness` — which is why the arm-3 disjunct is about `rhoSF t₂ t₁ sf` rather than
`sf`. That renaming is not a weakening: it is the same formula carried along the identification the
arm performs, and it is the same form in which
`expandOnceUnblocked_splitOrdered_no_deletion` states non-deletion.

`.saturated` produces no successor branch and satisfies both conjuncts by absence of successors,
not by any weakening of the statement.

`RunInvariant` enters for one reason only: arm 3's `IrreflOrd` side condition. Both monotonicity
lemmas are invariant-free. -/
theorem expandOnceUnblocked_preserves_witness {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {rule : TableauRule} {sf : SignedFormula}
    (hinv : RunInvariant b ord) (h : witnessPresent rule sf b ord = true) :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        witnessPresent rule sf nb (expandOnceUnblocked b ord fc tr).2 = true) ∧
    (∀ bs t₁ t₂, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        firstIncomparablePair b ord = some (t₁, t₂) →
        ∀ p ∈ bs, witnessPresent rule sf p.1 p.2 = true ∨
          witnessPresent rule (rhoSF t₂ t₁ sf) p.1 p.2 = true) := by
  constructor
  · intro nb hnb
    exact witnessPresent_branch_mono (expandOnceUnblocked_branch_mono nb hnb)
      (witnessPresent_ord_mono expandOnceUnblocked_ord_mono h)
  · intro bs t₁ t₂ hbs htrig
    obtain ⟨u₁, u₂, htrig', rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
    rw [htrig] at htrig'
    obtain ⟨rfl, rfl⟩ : t₁ = u₁ ∧ t₂ = u₂ := by simpa using htrig'
    intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl
    · exact Or.inl (witnessPresent_ord_mono (addFuture_constraints_mono ord t₁ t₂) h)
    · exact Or.inl (witnessPresent_ord_mono (addFuture_constraints_mono ord t₂ t₁) h)
    · exact Or.inr (arm3_preserves_witness htrig hinv.irreflOrd rule sf h)

/-- **`witnessPresent` never flips `true → false` along a run**, up to the arm-3 renaming — the
corollary in the form the mint counting consumes.

Contrapositive of `expandOnceUnblocked_preserves_witness`. Read forwards: if a successor reports no
witness then the step it came from reported none either. At an ordered split, "the successor
reports no witness" has to mean *both* the formula and its arm-3 rename report none — that is what
makes the statement true at arm 3 rather than merely unrefuted there.

Stated against `RunInvariant` rather than a standalone `IrreflOrd` hypothesis, so a fuel induction
carrying the single bundled invariant can consume it directly. -/
theorem witnessPresent_no_flip {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {rule : TableauRule} {sf : SignedFormula} (hinv : RunInvariant b ord) :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        witnessPresent rule sf nb (expandOnceUnblocked b ord fc tr).2 = false →
          witnessPresent rule sf b ord = false) ∧
    (∀ bs t₁ t₂, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        firstIncomparablePair b ord = some (t₁, t₂) →
        ∀ p ∈ bs, witnessPresent rule sf p.1 p.2 = false →
          witnessPresent rule (rhoSF t₂ t₁ sf) p.1 p.2 = false →
            witnessPresent rule sf b ord = false) := by
  constructor
  · intro nb hnb hfalse
    rcases hw : witnessPresent rule sf b ord with _ | _
    · rfl
    · rw [(expandOnceUnblocked_preserves_witness hinv hw).1 nb hnb] at hfalse
      exact Bool.noConfusion hfalse
  · intro bs t₁ t₂ hbs htrig p hp h1 h2
    rcases hw : witnessPresent rule sf b ord with _ | _
    · rfl
    · rcases (expandOnceUnblocked_preserves_witness hinv hw).2 bs t₁ t₂ hbs htrig p hp with ht | ht
      · rw [ht] at h1; exact Bool.noConfusion h1
      · rw [ht] at h2; exact Bool.noConfusion h2

/-! ## C1. The world dimension, and a time bound that does not go through the mint chain

Two independent obligations meet here.

**The time bound must not be circular.** `|U| = |signedUniverse C L|` with `L = worlds × times`,
while times grow by minting — so a time bound derived *from* the mint count would make the whole
chain circular. `timeFinset_card_le_of_mem_stock` below is the non-circular route, and it is
non-circular for a reason that can be read off its hypotheses rather than argued: branch-confined-
to-stock, linearity-saturated, eventuality-fulfilled, blocking-silent. **Not one of the four
mentions a world, a mint, or `|U|`.** Its conclusion `2 ^ (2 * |C|)` is a function of the stock
alone.

**The world dimension.** `worldFinset_card_le` turns the fresh-world discipline `WorldWitness`
into `|worlds| ≤ |S| + 2·|C|·|times|`, and `Branch.card_labelFinset_le` multiplies the two
dimensions into the label bound that `expandBranchWithFuel_isSome_at_worldFuel'` takes as `hL`.
`labelFinset_card_le_of_worldWitness` assembles exactly that, and `seedWorlds_card` pins `s = 1`
at the engine's own seed.

**What is discharged here and what is not, stated plainly.** `WorldWitness` is discharged **at the
seed branch** (`worldWitness_seedBranch`), which is what fixes `s = 1`. It is **not** discharged as
a run-level invariant: `chain_le_worldFuel'` wants `WorldWitness C S (run n)` at step `n`, and
establishing that is an induction over `applyRule`'s 36 constructors whose content is the
injectivity clause — a second world minted for the same sign/formula/time would have found the
first one's witness and been suppressed, which is `witnessPresent`'s world-indifference. That
induction is not attempted here. The residual is therefore exactly one named hypothesis,
`WorldWitness C (seedBranch φ).worldFinset b`, and every result below carries it visibly in its
statement rather than absorbing it. -/

/-- **The engine's seed branch.** Both `buildTableauAt` and `buildTableau` open with the single
signed formula `¬φ` at `Label.initial` and hand it to `expandBranchWithFuel` together with
`TimeOrdering.empty`. Named here so the seed-side facts cite one shape instead of repeating it. -/
def seedBranch (φ : Formula) : Branch := [SignedFormula.neg φ Label.initial]

/-- **The seed mentions exactly one world**, world `0` — which is what makes `s = 1` the right
instantiation of the world bound's seed parameter, rather than a figure chosen for convenience. -/
theorem seedWorlds_card (φ : Formula) : (seedBranch φ).worldFinset.card = 1 := rfl

/-- **`WorldWitness` at the seed.** Discharged, not assumed: at `S := (seedBranch φ).worldFinset`
every world of the branch lies in `S`, so both clauses of the discipline are satisfied by absence
of a non-seed world.

This is `worldWitness_self` at the seed, and — unlike the degenerate reading its docstring warns
about — it is *not* empty here, because `seedWorlds_card` computes `|S| = 1`. The world bound's
first summand is therefore a constant, which is the whole point of scoping to the seed. -/
theorem worldWitness_seedBranch (C : Finset Formula) (φ : Formula) :
    WorldWitness C (seedBranch φ).worldFinset (seedBranch φ) :=
  worldWitness_self C (seedBranch φ)

/-- **T2, in the form this chain consumes, and demonstrably not circular.**

`timeFinset_card_le_of_not_blocked` wants `TimeChain b ord`; `timeChain_of_linearity_saturated`
supplies it from the linearity stage's own silence, since `timeLinearity` is self-suppressing and
fires exactly while an incomparable pair remains. Composing the two leaves four hypotheses, and the
reason the mint bound may rest on this is that **none of them mentions a world, a mint, or the
signed universe**: the bound `2 ^ (2 * |C|)` is a function of the stock alone. -/
theorem timeFinset_card_le_of_mem_stock {C : Finset Formula} {b : Branch} {ord : TimeOrdering}
    {tracker : EventualityTracker}
    (hb : ∀ x ∈ b, x.formula ∈ C)
    (hlin : firstIncomparablePair b ord = none)
    (hev : ∀ t₁ ∈ b.knownTimes, ∀ t₂ ∈ b.knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime b ord tracker = none) :
    b.timeFinset.card ≤ 2 ^ (2 * C.card) :=
  timeFinset_card_le_of_not_blocked hb (timeChain_of_linearity_saturated hlin) hev hnb

/-- **The label bound, in the exact shape `expandBranchWithFuel_isSome_at_worldFuel'` takes as
`hL`.** The two dimensions multiply: `worldFinset_card_le` bounds the world component by
`|S| + 2·|C|·|times|`, the time component is bounded by `htime`, and `Branch.card_labelFinset_le`
injects labels into their two components. -/
theorem labelFinset_card_le_of_worldWitness {C : Finset Formula} {S : Finset WorldIndex}
    {b : Branch} {s : Nat}
    (hww : WorldWitness C S b) (hs : S.card ≤ s)
    (htime : b.timeFinset.card ≤ 2 ^ (2 * C.card)) :
    b.labelFinset.card ≤ (s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card) := by
  refine le_trans (Branch.card_labelFinset_le b) ?_
  have hw : b.worldFinset.card ≤ s + 2 * C.card * 2 ^ (2 * C.card) :=
    le_trans (worldFinset_card_le hww)
      (Nat.add_le_add hs (Nat.mul_le_mul_left _ htime))
  exact Nat.mul_le_mul hw htime

/-- **The label bound at `s = 1`**, the figure the engine's own seed supplies.

The one input not discharged in this module is `hww` — the fresh-world discipline **at the run's
branch `b`**, not at the seed. It is carried explicitly rather than absorbed, so that a consumer
can see precisely what remains: `worldWitness_seedBranch` gives the `n = 0` case, and the step case
is the 36-constructor induction described in the section preamble. -/
theorem labelFinset_card_le_at_seed_worlds {C : Finset Formula} {φ : Formula} {b : Branch}
    (hww : WorldWitness C (seedBranch φ).worldFinset b)
    (htime : b.timeFinset.card ≤ 2 ^ (2 * C.card)) :
    b.labelFinset.card ≤ (1 + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card) :=
  labelFinset_card_le_of_worldWitness hww (le_of_eq (seedWorlds_card φ)) htime

/-! ## C2. The fresh-world discipline is preserved by a rule application

`WorldWitness` as `Fuel.lean` states it is **not inductive**: its witness function `wit` is
constrained only by `(wit w).formula ∈ C` and `(wit w).label.time ∈ b.timeFinset`, and is not
required to lie on the branch or to sit at the world it witnesses. The preservation argument needs
both: at a fresh-world mint, the new world's witness is distinct from every existing one *because*
an existing witness **on the branch** carrying the same sign, formula and time would have made
`witnessPresent` true and suppressed the mint. With `wit w` free-floating there is nothing to feed
the guard.

The repair is the same shape as this file's `OrdTimesKnown` repair: `WorldWitnessKnown` below
carries `wit w ∈ b ∧ (wit w).label.world = w` alongside the existing clauses,
`worldWitness_of_known` derives the weak form from it (the strengthening witness, mirroring
`ordTimesLeMaxTime_of_ordTimesKnown`), and the induction runs on the strong form. `Fuel.lean` is
not edited.

The world dimension is much narrower than the times dimension: of `TableauRule`'s 36
constructors exactly **two** — `boxNeg` and `diamondPos` — mint a world, and both do it by
emitting at `Branch.nextWorld`. `applyRule_emitted_world_mem` discharges the other 34 in one
split; the two minting rules are then handled by name, with the guard supplying the injectivity
clause. -/

/-- Identification relabels times only, so it never introduces a world. -/
theorem mem_identifyTime_world {b : Branch} {src tgt : TimeIndex} {g : SignedFormula}
    (h : g ∈ b.identifyTime src tgt) : g.label.world ∈ b.worldFinset := by
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map] at h
  obtain ⟨x, hx, rfl⟩ := h
  by_cases hc : x.label.time = src <;> simp only [hc, if_true, if_false, beq_iff_eq] <;>
    exact Branch.mem_worldFinset hx

/-- World-level analogue of `mem_filterMap_sub`: a propagation block that reads formulas off the
branch through a `List.filter` selector and relabels them emits nothing at a new world. The
hypothesis `hF` is discharged per block by opening the block's own `match`/`if`. -/
theorem mem_filterMap_world {b : Branch} {P : SignedFormula → Bool}
    {F : SignedFormula → Option SignedFormula} {g : SignedFormula}
    (hF : ∀ x y, F x = some y → y.label.world = x.label.world)
    (h : g ∈ (b.filter P).filterMap F) : g.label.world ∈ b.worldFinset := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  rw [hF x g hxg]
  exact Branch.mem_worldFinset (List.mem_of_mem_filter hx)

/-- The same shape with a constant target world, for the two rules that emit at `nextWorld`. -/
theorem mem_filterMap_const_world {l : List SignedFormula}
    {F : SignedFormula → Option SignedFormula} {w : WorldIndex} {g : SignedFormula}
    (hF : ∀ x y, F x = some y → y.label.world = w) (h : g ∈ l.filterMap F) :
    g.label.world = w := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  exact hF x g hxg

set_option maxHeartbeats 4000000 in
/-- **Only `boxNeg` and `diamondPos` leave the branch's worlds.** Every other rule emits at a
world the branch already mentions: the propositional and temporal rules at the trigger's own
world, the persistent-universal rules at a `knownWorlds` entry, the fresh-*time* rules at the
trigger's world (their `boxDiamondPersistence` block included, by
`mem_boxDiamondPersistence_label`), and `timeLinearity`'s identification arm by
`mem_identifyTime_world`.

The full 34 × 2 split, stated against `RuleResult.emitted` so that one statement covers all five
result shapes at once. -/
theorem applyRule_emitted_world_mem {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (h1 : rule ≠ .boxNeg) (h2 : rule ≠ .diamondPos) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.world ∈ b.worldFinset := by
  have hw : sf.label.world ∈ b.worldFinset := Branch.mem_worldFinset hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;> first
      | exact absurd rfl h1
      | exact absurd rfl h2
      | (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
          (try contradiction) <;>
          intro g hg <;>
          repeat' first
            | exact hw
            | exact Branch.mem_worldFinset hg
            | exact mem_identifyTime_world hg
            | (rw [(mem_boxDiamondPersistence_label hg).1]; exact hw)
            | (obtain ⟨x, hx, rfl⟩ := mem_filterMap_guarded hg
               first
                 | exact hw
                 | exact List.mem_toFinset.mpr hx)
            | (refine mem_filterMap_world ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
                 Branch.allFuturePosFormulas, Branch.allPastPosFormulas,
                 Branch.someFutureNegFormulas, Branch.somePastNegFormulas,
                 Branch.untlNegFormulas, Branch.snceNegFormulas,
                 List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil,
                 List.append_nil, List.mem_cons, List.mem_append, List.not_mem_nil,
                 or_false, List.mem_filter] at hg)
            | (subst hg; exact hw)
            | (rcases hg with hg | hg)
            | (obtain ⟨hg, -⟩ := hg))

set_option maxHeartbeats 1000000 in
/-- `boxNeg` emits **only** at `Branch.nextWorld`: the witness and both auto-propagation blocks
carry the fresh world. -/
theorem applyRule_boxNeg_emitted_world {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} :
    ∀ g ∈ (applyRule .boxNeg sf b ord).1.emitted, g.label.world = b.nextWorld := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;> (try contradiction) <;>
      intro g hg <;>
      repeat' first
        | rfl
        | (refine mem_filterMap_const_world ?_ hg
           clear hg
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | (subst hy; rfl)
             | (simp only [reduceCtorEq] at hy))
        | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
             List.mem_cons, List.mem_append, List.not_mem_nil, or_false] at hg)
        | (subst hg; rfl)
        | (rcases hg with hg | hg)

set_option maxHeartbeats 1000000 in
/-- The `diamondPos` mirror of `applyRule_boxNeg_emitted_world`. -/
theorem applyRule_diamondPos_emitted_world {sf : SignedFormula} {b : Branch} {ord : TimeOrdering} :
    ∀ g ∈ (applyRule .diamondPos sf b ord).1.emitted, g.label.world = b.nextWorld := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;> (try contradiction) <;>
      intro g hg <;>
      repeat' first
        | rfl
        | (refine mem_filterMap_const_world ?_ hg
           clear hg
           intro x y hy
           repeat' first
             | split at hy
             | simp only [Option.some.injEq] at hy
           all_goals first
             | (subst hy; rfl)
             | (simp only [reduceCtorEq] at hy))
        | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
             List.mem_cons, List.mem_append, List.not_mem_nil, or_false] at hg)
        | (subst hg; rfl)
        | (rcases hg with hg | hg)

set_option maxHeartbeats 1000000 in
/-- If `boxNeg` emitted anything at all, the trigger had the shape the rule is keyed on. This is
what turns "a new world appeared" into a statement about the *rule's own* witness. -/
theorem applyRule_boxNeg_shape {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {g : SignedFormula} (hg : g ∈ (applyRule .boxNeg sf b ord).1.emitted) :
    ∃ ψ, sf.formula = Formula.box ψ ∧ sf.sign = Sign.neg := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] at hg <;> (repeat' split at hg) <;>
      first
        | contradiction
        | exact ⟨_, rfl, rfl⟩
        | (simp only [RuleResult.emitted, List.not_mem_nil] at hg)

set_option maxHeartbeats 1000000 in
/-- The `diamondPos` mirror of `applyRule_boxNeg_shape`. -/
theorem applyRule_diamondPos_shape {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {g : SignedFormula} (hg : g ∈ (applyRule .diamondPos sf b ord).1.emitted) :
    ∃ ψ, asDiamond? sf.formula = some ψ ∧ sf.sign = Sign.pos := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] at hg <;> (repeat' split at hg) <;>
      first
        | contradiction
        | exact ⟨_, by assumption, rfl⟩
        | (simp only [RuleResult.emitted, List.not_mem_nil] at hg)

/-- At its own trigger shape, `boxNeg` returns a `.linear` result — so its successor is the single
branch `fs ++ b`, and everything it emitted is on that branch. -/
theorem applyRule_boxNeg_eq {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg) :
    ∃ fs, (applyRule .boxNeg sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    exact ⟨_, rfl⟩

/-- The `diamondPos` mirror of `applyRule_boxNeg_eq`. -/
theorem applyRule_diamondPos_eq {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos) :
    ∃ fs, (applyRule .diamondPos sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    rw [asDiamond?_eq_iff] at hf
    subst hf
    exact ⟨_, rfl⟩

/-- Independently of the trigger's shape, `boxNeg` returns either nothing or a `.linear` result —
never `.persistent` and never a split. Consumed where a rule's result shape has to be excluded
without first knowing that the rule fired. -/
theorem applyRule_boxNeg_result (sf : SignedFormula) (b : Branch) (ord : TimeOrdering) :
    (applyRule .boxNeg sf b ord).1 = RuleResult.notApplicable ∨
      ∃ fs, (applyRule .boxNeg sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
      first
        | contradiction
        | exact Or.inl rfl
        | exact Or.inl trivial
        | exact Or.inr ⟨_, rfl⟩

/-- The `diamondPos` mirror of `applyRule_boxNeg_result`. -/
theorem applyRule_diamondPos_result (sf : SignedFormula) (b : Branch) (ord : TimeOrdering) :
    (applyRule .diamondPos sf b ord).1 = RuleResult.notApplicable ∨
      ∃ fs, (applyRule .diamondPos sf b ord).1 = RuleResult.linear fs := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
      first
        | contradiction
        | exact Or.inl rfl
        | exact Or.inl trivial
        | exact Or.inr ⟨_, rfl⟩

/-- The `witness` of the rule's own conclusion is the head of what `boxNeg` emits. -/
theorem applyRule_boxNeg_witness {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg) :
    SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time }
      ∈ (applyRule .boxNeg sf b ord).1.emitted := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    simp only [applyRule, RuleResult.emitted]
    exact List.mem_cons_self

/-- The `diamondPos` mirror of `applyRule_boxNeg_witness`. -/
theorem applyRule_diamondPos_witness {sf : SignedFormula} {ψ : Formula} {b : Branch}
    {ord : TimeOrdering} (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos) :
    SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time }
      ∈ (applyRule .diamondPos sf b ord).1.emitted := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    rw [asDiamond?_eq_iff] at hf
    subst hf
    simp only [applyRule, RuleResult.emitted]
    exact List.mem_cons_self

/-! ### The strengthened discipline -/

/-- **The fresh-world discipline, strengthened so that it is inductive.**

`WorldWitness` (`Fuel.lean`) says only that each non-seed world's witness has a stock formula and
a branch time. This adds the two clauses the preservation argument needs and the weak form omits:
the witness lies **on the branch**, and it sits at the world it witnesses. Both are what let the
`witnessPresent` guard be applied at a mint — the guard scans the branch for a formula at a known
world, so a witness that is neither on the branch nor at its own world cannot be fed to it.

`worldWitness_of_known` recovers the weak form, so every landed `WorldWitness` consumer keeps
working. This is a strengthening, not a weakening. -/
def WorldWitnessKnown (C : Finset Formula) (S : Finset WorldIndex) (b : Branch) : Prop :=
  ∃ wit : WorldIndex → SignedFormula,
    (∀ w ∈ b.worldFinset, w ∉ S →
      wit w ∈ b ∧ (wit w).label.world = w ∧ (wit w).formula ∈ C) ∧
    (∀ w₁ ∈ b.worldFinset, w₁ ∉ S → ∀ w₂ ∈ b.worldFinset, w₂ ∉ S →
      witnessSig (wit w₁) = witnessSig (wit w₂) → w₁ = w₂)

/-- **The strengthening witness.** The strong discipline implies the weak one, with the same
witness function: the time clause the weak form asks for follows from branch membership. This is
what makes `WorldWitnessKnown` a strengthening of `WorldWitness` rather than a different
condition, and it is what `worldFinset_card_le` is reached through. -/
theorem worldWitness_of_known {C : Finset Formula} {S : Finset WorldIndex} {b : Branch}
    (h : WorldWitnessKnown C S b) : WorldWitness C S b := by
  obtain ⟨wit, hwit, hinj⟩ := h
  refine ⟨wit, ?_, hinj⟩
  intro w hw hs
  obtain ⟨hmem, -, hC⟩ := hwit w hw hs
  exact ⟨hC, Branch.mem_timeFinset hmem⟩

/-- A world the branch mentions is mentioned by one of its formulas. -/
theorem exists_mem_of_mem_worldFinset {b : Branch} {w : WorldIndex} (h : w ∈ b.worldFinset) :
    ∃ x ∈ b, x.label.world = w := by
  simp only [Branch.worldFinset, List.mem_toFinset, Branch.knownWorlds, List.mem_eraseDups,
    List.mem_map] at h
  obtain ⟨x, hx, hxw⟩ := h
  exact ⟨x, hx, hxw⟩

/-- `Branch.nextWorld` is fresh, as a `worldFinset` statement. -/
theorem nextWorld_not_mem_worldFinset (b : Branch) : b.nextWorld ∉ b.worldFinset := by
  intro h
  obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset h
  exact not_mem_of_world_nextWorld hxw hx

/-- The converse of `mem_of_branch_contains`. -/
theorem contains_of_mem {b : Branch} {x : SignedFormula} (h : x ∈ b) : b.contains x = true := by
  simp only [Branch.contains, List.any_eq_true]
  exact ⟨x, h, beq_self_eq_true x⟩

/-- A branch formula's world is a known world, in list form. -/
theorem mem_knownWorlds_of_mem {b : Branch} {x : SignedFormula} (h : x ∈ b) :
    x.label.world ∈ b.knownWorlds :=
  List.mem_eraseDups.mpr (List.mem_map_of_mem h)

/-- **A step that introduces no world keeps the discipline**, with the same witness function.
This is the case of 34 of the 36 rules. -/
theorem worldWitnessKnown_of_no_new_world {C : Finset Formula} {S : Finset WorldIndex}
    {b nb : Branch} (hww : WorldWitnessKnown C S b) (hsub : ∀ x ∈ b, x ∈ nb)
    (hworlds : ∀ x ∈ nb, x.label.world ∈ b.worldFinset) : WorldWitnessKnown C S nb := by
  obtain ⟨wit, hwit, hinj⟩ := hww
  have key : ∀ w ∈ nb.worldFinset, w ∈ b.worldFinset := by
    intro w hw
    obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
    exact hworlds x hx
  refine ⟨wit, ?_, ?_⟩
  · intro w hw hs
    obtain ⟨hm, hl, hc⟩ := hwit w (key w hw) hs
    exact ⟨hsub _ hm, hl, hc⟩
  · intro w₁ h1 hs1 w₂ h2 hs2 heq
    exact hinj w₁ (key w₁ h1) hs1 w₂ (key w₂ h2) hs2 heq

/-- **A step that mints exactly one world keeps the discipline**, provided the minted world's own
witness carries a signature no branch formula carries.

That last hypothesis is the whole content of the invariant, and it is exactly what the engine's
`witnessPresent` guard supplies at a fresh-world rule: had any branch formula carried the same
sign, formula and time, the guard would have reported a witness and the rule would not have
fired. The new witness function is the old one updated at the minted world. -/
theorem worldWitnessKnown_mint {C : Finset Formula} {S : Finset WorldIndex}
    {b nb : Branch} {w₀ : WorldIndex} {x₀ : SignedFormula}
    (hww : WorldWitnessKnown C S b) (hsub : ∀ x ∈ b, x ∈ nb)
    (hworlds : ∀ x ∈ nb, x.label.world ∈ b.worldFinset ∨ x.label.world = w₀)
    (hfresh : w₀ ∉ b.worldFinset)
    (hx₀ : x₀ ∈ nb) (hx₀w : x₀.label.world = w₀) (hx₀C : x₀.formula ∈ C)
    (hsig : ∀ y ∈ b, witnessSig y ≠ witnessSig x₀) : WorldWitnessKnown C S nb := by
  classical
  obtain ⟨wit, hwit, hinj⟩ := hww
  refine ⟨Function.update wit w₀ x₀, ?_, ?_⟩
  · intro w hw hs
    by_cases hw0 : w = w₀
    · subst hw0
      simpa [Function.update_self] using ⟨hx₀, hx₀w, hx₀C⟩
    · obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
      have hb : x.label.world ∈ b.worldFinset := (hworlds x hx).resolve_right hw0
      obtain ⟨hm, hl, hc⟩ := hwit _ hb hs
      simpa [Function.update_of_ne hw0] using ⟨hsub _ hm, hl, hc⟩
  · intro w₁ h1 hs1 w₂ h2 hs2 heq
    have hb : ∀ w ∈ nb.worldFinset, w ≠ w₀ → w ∈ b.worldFinset := by
      intro w hw hne
      obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
      exact (hworlds x hx).resolve_right hne
    by_cases e1 : w₁ = w₀ <;> by_cases e2 : w₂ = w₀
    · rw [e1, e2]
    · exfalso
      subst e1
      rw [Function.update_self, Function.update_of_ne e2] at heq
      exact hsig _ (hwit _ (hb _ h2 e2) hs2).1 heq.symm
    · exfalso
      subst e2
      rw [Function.update_self, Function.update_of_ne e1] at heq
      exact hsig _ (hwit _ (hb _ h1 e1) hs1).1 heq
    · rw [Function.update_of_ne e1, Function.update_of_ne e2] at heq
      exact hinj _ (hb _ h1 e1) hs1 _ (hb _ h2 e2) hs2 heq

/-! ### The guard, read as a statement about witness signatures -/

/-- **`boxNeg`'s guard, in signature form.** `witnessPresent .boxNeg` scans `knownWorlds` for the
rule's conclusion at the trigger's own time; the scan is world-indifferent, so its failure says
precisely that no branch formula shares the minted witness's signature. -/
theorem boxNeg_guard_sig {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : sf.formula = Formula.box ψ) (hs : sf.sign = Sign.neg)
    (hguard : witnessPresent .boxNeg sf b ord = false) :
    ∀ y ∈ b, witnessSig y
      ≠ witnessSig (SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time }) := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hf; subst hs
    simp only [witnessPresent] at hguard
    intro y hy heq
    have h1 : y.sign = Sign.neg := congrArg SignedFormula.sign heq
    have h2 : y.formula = ψ := congrArg SignedFormula.formula heq
    have h3 : y.label.time = label.time := congrArg (fun z => z.label.time) heq
    have hy' : y = SignedFormula.neg ψ { world := y.label.world, time := label.time } := by
      obtain ⟨ys, yf, yl⟩ := y
      obtain ⟨yw, yt⟩ := yl
      simp_all [SignedFormula.neg]
    have hcontains : b.contains
        (SignedFormula.neg ψ { world := y.label.world, time := label.time }) = true := by
      rw [← hy']; exact contains_of_mem hy
    have hany : (b.knownWorlds.any fun w =>
        b.contains (SignedFormula.neg ψ { world := w, time := label.time })) = true :=
      List.any_eq_true.mpr ⟨y.label.world, mem_knownWorlds_of_mem hy, hcontains⟩
    rw [hany] at hguard
    exact Bool.noConfusion hguard

/-- The `diamondPos` mirror of `boxNeg_guard_sig`. -/
theorem diamondPos_guard_sig {sf : SignedFormula} {ψ : Formula} {b : Branch} {ord : TimeOrdering}
    (hf : asDiamond? sf.formula = some ψ) (hs : sf.sign = Sign.pos)
    (hguard : witnessPresent .diamondPos sf b ord = false) :
    ∀ y ∈ b, witnessSig y
      ≠ witnessSig (SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time }) := by
  cases sf with
  | mk sign formula label =>
    simp only at hf hs
    subst hs
    simp only [witnessPresent, hf] at hguard
    intro y hy heq
    have h1 : y.sign = Sign.pos := congrArg SignedFormula.sign heq
    have h2 : y.formula = ψ := congrArg SignedFormula.formula heq
    have h3 : y.label.time = label.time := congrArg (fun z => z.label.time) heq
    have hy' : y = SignedFormula.pos ψ { world := y.label.world, time := label.time } := by
      obtain ⟨ys, yf, yl⟩ := y
      obtain ⟨yw, yt⟩ := yl
      simp_all [SignedFormula.pos]
    have hcontains : b.contains
        (SignedFormula.pos ψ { world := y.label.world, time := label.time }) = true := by
      rw [← hy']; exact contains_of_mem hy
    have hany : (b.knownWorlds.any fun w =>
        b.contains (SignedFormula.pos ψ { world := w, time := label.time })) = true :=
      List.any_eq_true.mpr ⟨y.label.world, mem_knownWorlds_of_mem hy, hcontains⟩
    rw [hany] at hguard
    exact Bool.noConfusion hguard

/-- Every successor branch a rule result reports extends the branch, and everything on it is
either emitted by the rule or was already there. Stated once for the two per-shape selectors
`nonBranchingResultBranch` and `branchingResultBranches` that `pickBranches` is assembled from. -/
theorem resultBranch_sub {b nb : Branch} {res : RuleResult}
    (h : nb ∈ (nonBranchingResultBranch b res).toList ++ branchingResultBranches b res) :
    (∀ x ∈ b, x ∈ nb) ∧ (∀ x ∈ nb, x ∈ res.emitted ∨ x ∈ b) := by
  cases res with
  | linear fs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.mem_append,
      List.mem_cons, List.not_mem_nil, or_false, List.append_nil] at h
    subst h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp id id⟩
  | persistent fs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.mem_append,
      List.mem_cons, List.not_mem_nil, or_false, List.append_nil] at h
    subst h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp id id⟩
  | branching bss =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.mem_map] at h
    obtain ⟨fs, hfs, rfl⟩ := h
    exact ⟨fun x hx => List.mem_append_right _ hx,
      fun x hx => (List.mem_append.mp hx).imp
        (fun hh => List.mem_flatten.mpr ⟨fs, hfs, hh⟩) id⟩
  | branchingOrdered bs =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.not_mem_nil] at h
  | notApplicable =>
    simp only [nonBranchingResultBranch, branchingResultBranches, Option.toList, List.nil_append,
      List.not_mem_nil] at h

set_option maxHeartbeats 1000000 in
/-- **One rule application preserves the strengthened fresh-world discipline**, at every successor
branch the result reports.

Three cases, and only the first two have any content. For 34 of the 36 rules
`applyRule_emitted_world_mem` says no world is introduced, so the witness function carries over
untouched. For `boxNeg` and `diamondPos` either no world was introduced — same argument — or
`Branch.nextWorld` appears, in which case the trigger had the rule's own shape
(`applyRule_boxNeg_shape`), the result is `.linear` (`applyRule_boxNeg_eq`), the rule's own
witness is on the successor (`applyRule_boxNeg_witness`), its formula is in the stock by
subformula closure, and its signature is unmatched on the branch by the guard
(`boxNeg_guard_sig`).

`hguard` is demanded only at the two minting rules, which is the only place it is available:
`findApplicableRule` tests `witnessPresent` exactly at the eight `ruleMintsFreshLabel` rules. -/
theorem applyRule_worldWitnessKnown {C : Finset Formula} {S : Finset WorldIndex}
    {rule : TableauRule} {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    (hC : TableauClosed C) (hstock : ∀ x ∈ b, x.formula ∈ C) (hsf : sf ∈ b)
    (hguard : rule = .boxNeg ∨ rule = .diamondPos → witnessPresent rule sf b ord = false)
    (hww : WorldWitnessKnown C S b) :
    ∀ nb ∈ (nonBranchingResultBranch b (applyRule rule sf b ord).1).toList
             ++ branchingResultBranches b (applyRule rule sf b ord).1,
      WorldWitnessKnown C S nb := by
  intro nb hnb
  obtain ⟨hsub, hmem⟩ := resultBranch_sub hnb
  by_cases hbn : rule = .boxNeg
  · subst hbn
    by_cases hnew : b.nextWorld ∈ nb.worldFinset
    · obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset hnew
      have hxe : x ∈ (applyRule .boxNeg sf b ord).1.emitted := by
        rcases hmem x hx with h | h
        · exact h
        · exact absurd (hxw ▸ Branch.mem_worldFinset h) (nextWorld_not_mem_worldFinset b)
      obtain ⟨ψ, hf, hs⟩ := applyRule_boxNeg_shape hxe
      obtain ⟨fs, hres⟩ := applyRule_boxNeg_eq (b := b) (ord := ord) hf hs
      have hnbeq : nb = fs ++ b := by
        rw [hres] at hnb
        simpa [nonBranchingResultBranch, branchingResultBranches] using hnb
      have hWfs : SignedFormula.neg ψ { world := b.nextWorld, time := sf.label.time } ∈ fs := by
        have hW := applyRule_boxNeg_witness (b := b) (ord := ord) hf hs
        rwa [hres, RuleResult.emitted_linear] at hW
      refine worldWitnessKnown_mint hww hsub ?_ (nextWorld_not_mem_worldFinset b)
        (hnbeq ▸ List.mem_append_left _ hWfs) rfl
        (hC.box_inner (hf ▸ hstock sf hsf)) (boxNeg_guard_sig hf hs (hguard (Or.inl rfl)))
      intro y hy
      rcases hmem y hy with h | h
      · exact Or.inr (applyRule_boxNeg_emitted_world y h)
      · exact Or.inl (Branch.mem_worldFinset h)
    · refine worldWitnessKnown_of_no_new_world hww hsub ?_
      intro y hy
      rcases hmem y hy with h | h
      · exact absurd (applyRule_boxNeg_emitted_world y h ▸ Branch.mem_worldFinset hy) hnew
      · exact Branch.mem_worldFinset h
  · by_cases hdp : rule = .diamondPos
    · subst hdp
      by_cases hnew : b.nextWorld ∈ nb.worldFinset
      · obtain ⟨x, hx, hxw⟩ := exists_mem_of_mem_worldFinset hnew
        have hxe : x ∈ (applyRule .diamondPos sf b ord).1.emitted := by
          rcases hmem x hx with h | h
          · exact h
          · exact absurd (hxw ▸ Branch.mem_worldFinset h) (nextWorld_not_mem_worldFinset b)
        obtain ⟨ψ, hf, hs⟩ := applyRule_diamondPos_shape hxe
        obtain ⟨fs, hres⟩ := applyRule_diamondPos_eq (b := b) (ord := ord) hf hs
        have hnbeq : nb = fs ++ b := by
          rw [hres] at hnb
          simpa [nonBranchingResultBranch, branchingResultBranches] using hnb
        have hWfs : SignedFormula.pos ψ { world := b.nextWorld, time := sf.label.time } ∈ fs := by
          have hW := applyRule_diamondPos_witness (b := b) (ord := ord) hf hs
          rwa [hres, RuleResult.emitted_linear] at hW
        refine worldWitnessKnown_mint hww hsub ?_ (nextWorld_not_mem_worldFinset b)
          (hnbeq ▸ List.mem_append_left _ hWfs) rfl
          (hC.diamond_inner (asDiamond?_eq_iff.mp hf ▸ hstock sf hsf))
          (diamondPos_guard_sig hf hs (hguard (Or.inr rfl)))
        intro y hy
        rcases hmem y hy with h | h
        · exact Or.inr (applyRule_diamondPos_emitted_world y h)
        · exact Or.inl (Branch.mem_worldFinset h)
      · refine worldWitnessKnown_of_no_new_world hww hsub ?_
        intro y hy
        rcases hmem y hy with h | h
        · exact absurd (applyRule_diamondPos_emitted_world y h ▸ Branch.mem_worldFinset hy) hnew
        · exact Branch.mem_worldFinset h
    · refine worldWitnessKnown_of_no_new_world hww hsub ?_
      intro y hy
      rcases hmem y hy with h | h
      · exact applyRule_emitted_world_mem hsf hbn hdp y h
      · exact Branch.mem_worldFinset h


/-! ### The guard, extracted from the pick

`witnessPresent` is tested by `findApplicableRule` **only** at the eight `ruleMintsFreshLabel`
rules, and only in its `.linear` and `.branching` arms. Both world-minting rules live there —
`applyRule_boxNeg_result` and `applyRule_diamondPos_result` rule out the two unguarded arms — so
the guard is recoverable exactly where the fresh-world discipline needs it. The seriality and
linearity stages need no guard at all: they run one rule each, and neither is world-minting. -/

set_option maxHeartbeats 1000000 in
/-- **The ordinary-rule pick carries its own guard, at the two world-minting rules.** -/
theorem findApplicableRule_guard_mint {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, res, o))
    (hm : r = .boxNeg ∨ r = .diamondPos) :
    witnessPresent r sf b ord = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  rcases hm with rfl | rfl <;>
    (repeat' split at hr) <;>
    simp_all [ruleMintsFreshLabel]
  all_goals first
    | (rcases applyRule_boxNeg_result sf b ord with h' | ⟨fs', h'⟩ <;> simp_all)
    | (rcases applyRule_diamondPos_result sf b ord with h' | ⟨fs', h'⟩ <;> simp_all)

/-- The seriality stage runs exactly one rule. -/
theorem findApplicableSerialRule_rule {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableSerialRule sf b ord = some (r, res, o)) :
    r = TableauRule.serialityRule := by
  unfold findApplicableSerialRule serialityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  rcases hA : applyRule TableauRule.serialityRule sf b ord with ⟨res', o'⟩
  rw [hA] at h
  simp only at h
  cases res' <;> simp_all

/-- The linearity stage runs exactly one rule. -/
theorem findApplicableLinearityRule_rule {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (h : findApplicableLinearityRule sf b ord = some (r, res, o)) :
    r = TableauRule.timeLinearity := by
  unfold findApplicableLinearityRule linearityRules at h
  simp only [List.findSome?_cons, List.findSome?_nil] at h
  rcases hA : applyRule TableauRule.timeLinearity sf b ord with ⟨res', o'⟩
  rw [hA] at h
  simp only at h
  cases res' <;> simp_all

/-- **`pick_stage_source` with the fresh-world guard attached.** The three stages differ only in
how the guard arrives: stage one has it from `findApplicableRule_guard_mint`, stages two and
three by the rule they run not being a world-minting rule at all. -/
private theorem pick_stage_source_guarded (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) :
    ∀ r res o,
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
           | none => none) = some (r, res, o) →
      ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
        (r = .boxNeg ∨ r = .diamondPos → witnessPresent r sf b ord = false) := by
  intro r res o h
  rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  · rw [hpick] at h
    rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                             && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
    · rw [hser] at h
      rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
      · rw [hlin] at h
        simp only at h
        exact absurd h (by simp)
      · rw [hlin] at h
        simp only at h
        refine ⟨sf3, List.mem_of_find?_eq_some hlin,
          findApplicableLinearityRule_applyRule_pair h, ?_⟩
        intro hm
        have hr := findApplicableLinearityRule_rule h
        rcases hm with rfl | rfl <;> exact absurd hr (by simp)
    · rw [hser] at h
      simp only at h
      refine ⟨sf2, List.mem_of_find?_eq_some hser,
        findApplicableSerialRule_applyRule_pair h, ?_⟩
      intro hm
      have hr := findApplicableSerialRule_rule h
      rcases hm with rfl | rfl <;> exact absurd hr (by simp)
  · rw [hpick] at h
    simp only at h
    have hmem : sf ∈ b := by
      unfold findUnexpandedUnblockedWith at hpick
      exact List.mem_of_find?_eq_some hpick
    exact ⟨sf, hmem, findApplicableRule_applyRule_pair h,
      fun hm => findApplicableRule_guard_mint h hm⟩

/-- One pick stage preserves the strengthened fresh-world discipline at every successor branch it
reports. The join of the `applyRule`-level lemma with the guarded source. -/
private theorem pickBranches_worldWitnessKnown {C : Finset Formula} {S : Finset WorldIndex}
    {b : Branch} {ord : TimeOrdering} {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hC : TableauClosed C) (hstock : ∀ x ∈ b, x.formula ∈ C)
    (hww : WorldWitnessKnown C S b)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
      (r = .boxNeg ∨ r = .diamondPos → witnessPresent r sf b ord = false)) :
    ∀ nb ∈ pickBranches b p, WorldWitnessKnown C S nb := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA, hg⟩ := hp r res o rfl
    have h1 := applyRule_worldWitnessKnown (rule := r) (sf := sf) (b := b) (ord := ord)
      hC hstock hsf hg hww
    rw [hA] at h1
    intro nb hnb
    simp only [pickBranches] at hnb
    exact h1 nb hnb

/-- **Engine-level preservation of the strengthened fresh-world discipline**, at `.extended` and
at every arm of a `.split`.

`.saturated` contributes no successor. `.splitOrdered` is **deliberately not covered**, and the
reason is a real limitation rather than an omission — see the note below. It is also not needed:
`ExtendStep`, which is what every run this feeds is built from, is `.extended`-only. -/
theorem expandOnceUnblocked_worldWitnessKnown {C : Finset Formula} {S : Finset WorldIndex}
    {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hC : TableauClosed C) (hstock : ∀ x ∈ b, x.formula ∈ C)
    (hww : WorldWitnessKnown C S b) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      WorldWitnessKnown C S nb := by
  have keyB : unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1
      = pickBranches b
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
               | none => none) := pick_branches_eq
  rw [keyB]
  exact pickBranches_worldWitnessKnown hC hstock hww (pick_stage_source_guarded b ord fc tr)

/-! ### Why the ordered split is excluded, stated rather than glossed

The identification arm relabels every branch formula by `rho`, and `rho` **merges** two times.
Two non-seed worlds whose witnesses differ only in carrying the merged pair of times have
*distinct* signatures before the arm and the *same* signature after it, so the injectivity clause
of `WorldWitnessKnown` is not transported along `rhoSF`. That is a genuine failure of the
invariant at arm 3, of exactly the kind `ordTimes_identifyTime_arm3_false` records for the
ordering-times invariant — not a gap in this proof.

It costs nothing here. `ExtendStep` (`Fuel.lean`) is defined as
`(expandOnceUnblocked b ord fc tr).1 = .extended nb`, so every run that `chain_le_worlds_bounded`
and `chain_le_worldFuel'` quantify over is `.extended`-only: no split of either kind occurs along
it, and `expandOnceUnblocked_worldWitnessKnown` covers every step such a run can take. A consumer
that needs the discipline **across** an ordered split would need a repair of the same shape as
`OrdTimesKnown`, and does not have one. -/

/-- **The strengthened discipline at the engine's seed.** Every world of the seed lies in `S`, so
both clauses hold by absence of a non-seed world — the same reason `worldWitness_seedBranch`
holds, and not by any weakening. -/
theorem worldWitnessKnown_seedBranch (C : Finset Formula) (φ : Formula) :
    WorldWitnessKnown C (seedBranch φ).worldFinset (seedBranch φ) := by
  refine ⟨fun _ => ⟨Sign.pos, .bot, { world := 0, time := 0 }⟩, ?_, ?_⟩
  · intro w hw hns; exact absurd hw hns
  · intro w₁ hw₁ hns₁ _ _ _ _; exact absurd hw₁ hns₁

/-- **The run-level discharge — `WorldWitnessKnown` is an invariant of an `ExtendStep` chain.**

Base case: the hypothesis at step 0. Step case: `expandOnceUnblocked_worldWitnessKnown`, with the
stock hypothesis supplied at each intermediate branch by `branchStock_chain` (T1). This is the
induction the world bound needed and did not have. -/
theorem worldWitnessKnown_chain {C : Finset Formula} {S : Finset WorldIndex}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0))
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hww : WorldWitnessKnown C S (run 0)) : WorldWitnessKnown C S (run n) := by
  induction n with
  | zero => exact hww
  | succ n ih =>
      have hstep' : ∀ i < n, ExtendStep (run i) (run (i + 1)) := fun i hi => hstep i (by omega)
      have hprev := ih hstep'
      have hstock := (branchStock_chain hC hT run n h0 hstep').mem
      obtain ⟨ord, fc, tr, hs⟩ := hstep n (by omega)
      refine expandOnceUnblocked_worldWitnessKnown (ord := ord) (fc := fc) (tr := tr)
        hC hstock hprev (run (n + 1)) ?_
      rw [hs]
      simp [unorderedSuccessorBranches]

/-- **The weak form at every step of a seed run — the residual `chain_le_worldFuel'` names is
gone.** `WorldWitness C S (run n)` is now a theorem about runs out of the engine's own seed
rather than a hypothesis a caller must supply. -/
theorem worldWitness_chain_of_seed {C : Finset Formula} {φ : Formula}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0)) (hseed : run 0 = seedBranch φ)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1))) :
    WorldWitness C (seedBranch φ).worldFinset (run n) :=
  worldWitness_of_known
    (worldWitnessKnown_chain hC hT run n h0 hstep (hseed ▸ worldWitnessKnown_seedBranch C φ))

/-- **The label bound along a seed run, with no `WorldWitness` hypothesis left.**

This is `labelFinset_card_le_at_seed_worlds` with its one carried input discharged: the fresh-world
discipline is supplied by `worldWitness_chain_of_seed` rather than assumed, and `s = 1` by
`seedWorlds_card`. -/
theorem labelFinset_card_le_of_seed_run {C : Finset Formula} {φ : Formula}
    (hC : TableauClosed C) (hT : TrichStock C) (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0)) (hseed : run 0 = seedBranch φ)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (htime : (run n).timeFinset.card ≤ 2 ^ (2 * C.card)) :
    (run n).labelFinset.card ≤ (1 + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card) :=
  labelFinset_card_le_at_seed_worlds (worldWitness_chain_of_seed hC hT run n h0 hseed hstep) htime

/-- **T3's step bound for a seed run, with the fresh-world discipline discharged.**

`chain_le_worldFuel'` carries `hww : WorldWitness C S (run n)` as an undischarged invariant. Out
of the engine's own seed it is no longer undischarged: `worldWitness_chain_of_seed` proves it, and
`seedWorlds_card` fixes `S.card = 1`, so the figure is `worldFuel' φ 1`. -/
theorem chain_le_worldFuel'_of_seed {C : Finset Formula} {φ : Formula}
    {ord : TimeOrdering} {tracker : EventualityTracker}
    (hC : TableauClosed C) (hT : TrichStock C)
    (run : Nat → Branch) (n : Nat)
    (h0 : BranchStock C (run 0)) (hseed : run 0 = seedBranch φ)
    (hstep : ∀ i < n, ExtendStep (run i) (run (i + 1)))
    (hlin : firstIncomparablePair (run n) ord = none)
    (hev : ∀ t₁ ∈ (run n).knownTimes, ∀ t₂ ∈ (run n).knownTimes,
      allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hnb : findBlockedTime (run n) ord tracker = none)
    (hφ : C.card = (FormalSystem.Syntax.subformulaClosure φ).card) :
    n ≤ worldFuel' φ 1 := by
  have h := chain_le_worldFuel' (S := (seedBranch φ).worldFinset) (ord := ord) (tracker := tracker)
    hC hT run n h0 hstep hlin hev hnb
    (worldWitness_chain_of_seed hC hT run n h0 hseed hstep) hφ
  rwa [seedWorlds_card] at h

/-! ## C3. The mint potential

The count of `(rule, signed formula)` pairs still eligible to mint. Witness preservation makes it
non-increasing along a run, and a mint makes it strictly decrease, which is what turns "each pair
mints at most once" into a *per-state* quantity a fuel induction can carry.

### The carried renaming is not decoration — read this before simplifying it away

The obvious measure filters `freshLabelRules ×ˢ U` by `witnessPresent r sf b ord = false` at the
current state. **That measure is not available at the ordered split's identification arm**, and the
reason is the same non-injectivity that `ordTimes_identifyTime_arm3_false` exhibits for the
ordering-times invariant. `rhoSF t₂ t₁` merges `t₂` into `t₁`, so it is not injective on `U`, and a
counting argument at arm 3 would need an injection from the after-false set into the before-false
set. The map that suggests itself is not one: after the arm the branch carries **nothing** at `t₂`,
so every pair whose formula sits at `t₂` reports no witness at the successor, while a pair at `t₂`
whose witness also sat at `t₂` reported one before — a local *increase*, with no partner to absorb
it. Whether the simultaneous decreases at `t₁` dominate is not decided here in either direction.

`mintPotential` therefore carries the accumulated renaming `σ` as an explicit parameter and
filters on `witnessPresent r (σ sf) b ord = false`. The index set `freshLabelRules ×ˢ U` is then
**fixed for the whole run**, so successive potentials are cardinalities of subsets of one finset
and compare directly, and each of the two step shapes is a pointwise *subset* fact needing no
injection:

* an ordinary step keeps `σ` and grows branch and ordering — `mintPotential_le_of_grow`, from the
  two `witnessPresent` monotonicity lemmas;
* arm 3 post-composes `rhoSF t₂ t₁` onto `σ` — `mintPotential_identifyTime`, from
  `arm3_preserves_witness` read contrapositively.

Post-composition is what makes the measure compose along a run carrying **any number** of
identifications, rather than only the first one: `σ` is a parameter of the measure, not a fixed
choice inside it. `mints_le_eight_mul` is that composition, in the form the counting consumes.
Instantiating `σ := id` recovers the intrinsic measure at any prefix of the run before the first
ordered split, so nothing is lost relative to the simpler shape where the simpler shape works.

### The residual, named rather than absorbed

`mintPotential_lt_of_mint` — the strict decrease — asks that the minting pair be **`σ`-hit**: the
formula the rule fires on must be `σ sf` for some `sf ∈ U`. `σ`'s image omits exactly the times
earlier identifications merged away, so the obligation is precisely that a minting formula does
not sit at a merged-away time. That is a question about **time reuse**, not about the measure:
`Branch.nextTime` is `Branch.maxTime + 1` and `Branch.identifyTime` can *lower* `Branch.maxTime`
(the configuration `ordTimes_identifyTime_arm3_false` decides drops it from `5` to `0`), so a
fresh time can in principle re-issue a value an earlier identification removed. The equivalent
"live times" reformulation of the potential — filter additionally on the formula's time being a
fixed point of `σ` — carries the identical obligation, which is what shows it is intrinsic to the
situation rather than an artifact of this measure's shape. Discharging it is the first obligation
of the once-only bound, and it is stated in `mintPotential_lt_of_mint`'s hypotheses rather than
assumed anywhere.

### Why the three-component impossibility does not apply

The measured obstruction recorded against the split-aware fuel figure rules out the *linear
three-component family* `Ψ = A · (|U| − |b|) + B · |knownTimes| + C · |incompPairs|`: no choice of
the three coefficients decreases on every arm, because the identification arm moves the second and
third components in opposite directions from the first. `mintPotential` is a **fourth component
outside that family** — it mentions neither `b.toFinset.card`, nor `Branch.knownTimes`, nor the
incomparable-pair count, and it is not a linear combination of them. It is a count over a fixed
index set of *witness tests*, and it is bounded by `8 * U.card` outright. The impossibility is
therefore not evidence against this measure; it is evidence against the family this measure is
not in.

### The time bound is not circular

`|U| = |signedUniverse C L|` grows with the times, and the times grow by minting, so a `Tmax`
derived from the mint count would make the chain circular. It is not derived that way:
`timeFinset_card_le_of_mem_stock` above bounds `Branch.timeFinset.card` by `2 ^ (2 * |C|)` from
branch-confined-to-stock, linearity-saturated, eventuality-fulfilled and blocking-silent. **Not
one of those four hypotheses mentions a world, a mint, or `|U|`.** The mint chain may rest on it. -/

/-- **The eight rules that mint a fresh label**, as a `Finset`, so the potential's index set is a
product. The list is exactly `ruleMintsFreshLabel`'s `true` arms — `mem_freshLabelRules` proves the
agreement rather than asserting it, so the two can never drift apart silently. -/
def freshLabelRules : Finset TableauRule :=
  {TableauRule.boxNeg, TableauRule.diamondPos, TableauRule.allFutureNeg, TableauRule.allPastNeg,
   TableauRule.someFuturePos, TableauRule.somePastPos, TableauRule.untlPos, TableauRule.sncePos}

/-- There are exactly eight, decided rather than counted by hand. -/
theorem freshLabelRules_card : freshLabelRules.card = 8 := by decide

/-- The `Finset` and the `Bool` predicate agree, over all thirty-six constructors. -/
theorem mem_freshLabelRules {r : TableauRule} :
    r ∈ freshLabelRules ↔ ruleMintsFreshLabel r = true := by
  cases r <;> simp [freshLabelRules, ruleMintsFreshLabel]

/-- **The mint potential**: the number of `(rule, formula)` pairs drawn from the fixed index set
`freshLabelRules ×ˢ U` that report **no** witness at the current state, with the formula carried
through the accumulated renaming `σ`.

`σ` is the composition of the `rhoSF`s of the ordered splits taken so far; it is `id` before the
first one. Carrying it keeps the index set fixed across the whole run — see the section note above
for why the `σ`-free form is not available at the identification arm. -/
def mintPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  ((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 (σ p.2) b ord = false)).card

/-- **`mintPotential ≤ 8 · |U|`**, immediately, for every state and every renaming: the filter
cannot exceed its index set, and the index set is a product with an eight-element left factor. This
is the ceiling the once-only bound reads off. -/
theorem mintPotential_le_eight_mul (U : Finset SignedFormula)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) :
    mintPotential U σ b ord ≤ 8 * U.card := by
  refine le_trans (Finset.card_filter_le _ _) ?_
  rw [Finset.card_product, freshLabelRules_card]

/-- **An ordinary step does not increase the potential.** The branch grows and the ordering grows,
so `witnessPresent` can only turn on; contrapositively the after-false set is a *subset* of the
before-false set inside the same index set, and no injection is needed. Covers `.extended`,
`.split`, and the ordered split's first two arms, all of which keep `σ`. -/
theorem mintPotential_le_of_grow {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b b' : Branch} {ord ord' : TimeOrdering}
    (hb : ∀ x ∈ b, x ∈ b') (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) :
    mintPotential U σ b' ord' ≤ mintPotential U σ b ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
  · rfl
  · rw [witnessPresent_branch_mono hb (witnessPresent_ord_mono hord hw)] at hp
    exact absurd hp.2 (by simp)

/-- **The identification arm does not increase the potential either** — the central obligation of
this block, and the one the plain measure cannot meet.

The successor is measured at `rhoSF t₂ t₁ ∘ σ` rather than at `σ`, which is exactly the renaming
the arm performs, and the proof is again a pointwise subset fact: the contrapositive of
`arm3_preserves_witness`. No injection from the after-false set into the before-false set is
required, and none is available — `rhoSF t₂ t₁` is not injective on `U`.

Because the renaming is *post-composed* onto the parameter, this lemma applies unchanged at a
second, third, or `n`-th identification along the same run. -/
theorem mintPotential_identifyTime {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    mintPotential U (fun x => rhoSF t₂ t₁ (σ x)) (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁)
      ≤ mintPotential U σ b ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
  · rfl
  · rw [arm3_preserves_witness htrig hirr p.1 (σ p.2) hw] at hp
    exact absurd hp.2 (by simp)

/-- **A mint strictly decreases the potential.**

The minting pair is in the before-false set (that is the guard `findApplicableRule` tests) and out
of the after-false set (the rule's own output is the witness), and the after-false set is contained
in the before-false set by the same argument as `mintPotential_le_of_grow`. A strict subset of a
finset has strictly smaller cardinality.

**The `σ`-hit hypotheses are the residual, and they are visible here rather than absorbed.** The
pair must be drawn from the index set — `hr`, `hsf` — and the formula the rule fires on must be
`σ sf`, not merely some branch formula. See the section note on time reuse for what discharging
that costs. -/
theorem mintPotential_lt_of_mint {U : Finset SignedFormula} {σ : SignedFormula → SignedFormula}
    {b b' : Branch} {ord ord' : TimeOrdering} {r : TableauRule} {sf : SignedFormula}
    (hb : ∀ x ∈ b, x ∈ b') (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints)
    (hr : r ∈ freshLabelRules) (hsf : sf ∈ U)
    (hbefore : witnessPresent r (σ sf) b ord = false)
    (hafter : witnessPresent r (σ sf) b' ord' = true) :
    mintPotential U σ b' ord' < mintPotential U σ b ord := by
  refine Finset.card_lt_card ?_
  refine (Finset.ssubset_iff_of_subset ?_).mpr ⟨(r, sf), ?_, ?_⟩
  · intro p hp
    simp only [Finset.mem_filter] at hp ⊢
    refine ⟨hp.1, ?_⟩
    rcases hw : witnessPresent p.1 (σ p.2) b ord with _ | _
    · rfl
    · rw [witnessPresent_branch_mono hb (witnessPresent_ord_mono hord hw)] at hp
      exact absurd hp.2 (by simp)
  · simp only [Finset.mem_filter, Finset.mem_product]
    exact ⟨⟨hr, hsf⟩, hbefore⟩
  · simp only [Finset.mem_filter, hafter]
    simp

/-- **Engine level, unordered successors.** `.extended` and every arm of a `.split` grow both
components of the state, so `mintPotential_le_of_grow` applies with the renaming unchanged.
`.saturated` and `.splitOrdered` contribute no unordered successor. -/
theorem mintPotential_expandOnceUnblocked {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2 ≤ mintPotential U σ b ord := by
  intro nb hnb
  exact mintPotential_le_of_grow (expandOnceUnblocked_branch_mono nb hnb)
    expandOnceUnblocked_ord_mono

/-- **Engine level, the ordered split's three arms.** Each arm reports which renaming the run
carries onward: arms 1 and 2 keep `σ` (the branch is literally unchanged and the ordering gains one
edge), arm 3 post-composes `rhoSF t₂ t₁`. The disjunction is the honest shape — the induction
chooses per arm, and both choices are supplied with the same bound. -/
theorem mintPotential_expandOnceUnblocked_splitOrdered {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    {bs : List (Branch × TimeOrdering)} {t₁ t₂ : TimeIndex}
    (hinv : RunInvariant b ord)
    (hbs : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs)
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ∀ p ∈ bs, ∃ σ' : SignedFormula → SignedFormula,
      (σ' = σ ∨ σ' = fun x => rhoSF t₂ t₁ (σ x)) ∧
        mintPotential U σ' p.1 p.2 ≤ mintPotential U σ b ord := by
  obtain ⟨u₁, u₂, htrig', rfl⟩ := expandOnceUnblocked_splitOrdered_shape hbs
  rw [htrig] at htrig'
  obtain ⟨rfl, rfl⟩ : t₁ = u₁ ∧ t₂ = u₂ := by simpa using htrig'
  intro p hp
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact ⟨σ, Or.inl rfl,
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₁ t₂)⟩
  · exact ⟨σ, Or.inl rfl,
      mintPotential_le_of_grow (fun _ hx => hx) (addFuture_constraints_mono ord t₂ t₁)⟩
  · exact ⟨_, Or.inr rfl, mintPotential_identifyTime htrig hinv.irreflOrd⟩

/-- **The mint budget's arithmetic, non-minting step.** The invariant is "mints used plus potential
remaining does not exceed the budget"; a step that does not mint leaves the first summand alone and
does not raise the second. The mirror of `extendBudget_preserved` for the mint dimension. -/
theorem mintBudget_preserved {used budget p p' : Nat}
    (hbud : used + p ≤ budget) (hle : p' ≤ p) : used + p' ≤ budget := by omega

/-- **The mint budget's arithmetic, minting step.** A mint spends one unit of budget and buys a
strict decrease in the potential, so the sum is again preserved. This is the mint dimension's
analogue of `splitBudget_preserved`, and it is where "each pair mints at most once" is cashed. -/
theorem mintBudget_preserved_mint {used budget p p' : Nat}
    (hbud : used + p ≤ budget) (hlt : p' < p) : (used + 1) + p' ≤ budget := by omega

/-- **`#mints ≤ 8 · |U|` along any run** — the composition, stated over an arbitrary sequence of
states, renamings and mint counts.

This is the piece the carried renaming buys. The hypothesis is exactly the two step shapes above
combined with the budget arithmetic: at every step, `mints + mintPotential` does not increase, with
the step free to choose the successor renaming (`σ (i+1)` is unconstrained here, and the two
engine-level lemmas supply the two admissible choices). Because the index set is fixed, the
potentials at different steps are comparable **without** any injection between them, and the run
may carry arbitrarily many identifications.

The conclusion mentions neither the branch, nor branch growth, nor the number of ordered splits. -/
theorem mints_le_eight_mul {U : Finset SignedFormula}
    (σ : Nat → SignedFormula → SignedFormula) (br : Nat → Branch) (og : Nat → TimeOrdering)
    (mints : Nat → Nat) (n : Nat) (h0 : mints 0 = 0)
    (hstep : ∀ i < n, mints (i + 1) + mintPotential U (σ (i + 1)) (br (i + 1)) (og (i + 1))
      ≤ mints i + mintPotential U (σ i) (br i) (og i)) :
    mints n ≤ 8 * U.card := by
  have key : ∀ m ≤ n, mints m + mintPotential U (σ m) (br m) (og m)
      ≤ mints 0 + mintPotential U (σ 0) (br 0) (og 0) := by
    intro m
    induction m with
    | zero => intro _; exact Nat.le_refl _
    | succ k ih =>
      intro hk
      exact le_trans (hstep k (Nat.lt_of_lt_of_le (Nat.lt_succ_self k) hk))
        (ih (Nat.le_of_succ_le hk))
  have h := key n (Nat.le_refl n)
  rw [h0] at h
  have hb : mintPotential U (σ 0) (br 0) (og 0) ≤ 8 * U.card :=
    mintPotential_le_eight_mul _ _ _ _
  omega

/-- **The budget-carrying restatement, as a fixed target.**

This is the statement the induction over fuel has to close, named here so the counting block has
something fixed to aim at and so the shape cannot drift while it is being built. **Nothing here
asserts it**: it is a `Prop`-valued definition, and it is discharged where the induction is closed,
not before.

Read against `expandBranchWithFuel_isSome_of_noSplit`, four things changed and each is deliberate:

* **The unbranching-run restriction is gone**, name and all — the predicate
  `expandBranchWithFuel_isSome_of_noSplit` carries does not appear here under any spelling.
  No hypothesis restricts which `ExpansionResult` shapes the run may take,
  which is the whole point; a theorem that only applied to unbranching runs would have removed the
  restriction in name only.
* **The mint budget is an explicit parameter**, `mintBudget`, constrained only by
  `8 * U.card ≤ mintBudget` — the ceiling `mintPotential_le_eight_mul` supplies outright. It is a
  parameter this development discharges, never a caller obligation.
* **The time bound is derived from it**, `b.knownTimes.toFinset.card + mintBudget ≤ Tmax`, rather
  than assumed: each identification drops the known-time count and each mint raises it by one, so
  the initial count plus the mint budget bounds it for the whole run.
* **`RunInvariant` is the carried side condition**, on the *initial* state only. It is
  re-established at every successor by `expandOnceUnblocked_runInvariant`, and at the engine's own
  seed it is discharged outright by `runInvariant_initial`.

The fuel figure is the landed `splitAwareFuel`, unmodified, and the branch budget is the
`β`-linear one that `splitBudget_preserved` preserves. -/
def BudgetedTotality (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (mintBudget Tmax D β : Nat) : Prop :=
  ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker) (applied : AppliedSet)
    (maxBranches branchesUsed : Nat),
    (∀ x ∈ b, x ∈ U) →
    RunInvariant b ord →
    8 * U.card ≤ mintBudget →
    b.knownTimes.toFinset.card + mintBudget ≤ Tmax →
    branchesUsed + β * splitAwareFuel U.card Tmax D β ≤ maxBranches →
    (expandBranchWithFuel b (splitAwareFuel U.card Tmax D β) ord fc tr applied
      maxBranches branchesUsed).isSome = true

/-! ## C4. The once-only bound — the guard before a mint, the witness after one

The mint potential decreases at a mint for two reasons that have to be read off the source rather
than assumed, and they are proved here in that order.

**Before.** `findApplicableRule` gates every `ruleMintsFreshLabel` rule on `witnessPresent`, in
both arms that can carry one, and **instead of** the output-presence test rather than in addition
to it. This reading was checked against the source before anything was built on it: the `.linear`
arm tests `witnessPresent` under `if ruleMintsFreshLabel rule`, with the `fs.all branch.contains`
test in the *else* branch; the `.branching` arm does the same behind the `ruleSelfGuarded` test,
and `not_selfGuarded_of_fresh` proves no fresh-label rule is self-guarded, so the guard is always
reached. The `.persistent` and `.branchingOrdered` arms carry no guard, which costs nothing here
because the two lemmas below take the result shape as a hypothesis and are only ever applied at
the two shapes that do.

An `&&`-composition of the two tests would have broken the once-only argument, because a pair
could then be re-selected after its witness existed. It is not one.

**After.** All eight constructors return a syntactic cons whose head is the witness at the fresh
label, and the rule's own ordering edge puts that label in reach: `addFuture l.time freshTime`
for the future-directed rules, `addPast` for the past-directed ones, and the two world-minting
rules need no edge at all because `witnessPresent` scans `Branch.knownWorlds`. So immediately
after a mint, the pair reports a witness — which is what makes the decrease strict rather than
merely non-increasing. -/

/-- No fresh-label rule is self-guarded, so the `.branching` arm's `ruleSelfGuarded` test never
diverts a mint away from its guard. Decided over all thirty-six constructors. -/
theorem not_selfGuarded_of_fresh {r : TableauRule} (h : ruleMintsFreshLabel r = true) :
    ruleSelfGuarded r = false := by
  cases r <;> simp_all [ruleMintsFreshLabel, ruleSelfGuarded]

/-- **The guard, at a `.linear` mint.** Generalises `findApplicableRule_guard_mint` from the two
world-minting rules to all eight fresh-label rules, by taking the result shape as a hypothesis
instead of excluding the unguarded shapes rule by rule. -/
theorem findApplicableRule_guard_linear {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {fs : List SignedFormula}
    {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, RuleResult.linear fs, o))
    (hfresh : ruleMintsFreshLabel r = true) :
    witnessPresent r sf b ord = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  (repeat' split at hr) <;> simp_all

/-- **The guard, at a `.branching` mint.** The `.linear` twin, through the `ruleSelfGuarded` test
that the `.branching` arm checks first. -/
theorem findApplicableRule_guard_branching {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule}
    {bss : List (List SignedFormula)} {o : TimeOrdering}
    (h : findApplicableRule sf b ord fc = some (r, RuleResult.branching bss, o))
    (hfresh : ruleMintsFreshLabel r = true) :
    witnessPresent r sf b ord = false := by
  unfold findApplicableRule at h
  obtain ⟨rule, -, hr⟩ := List.exists_of_findSome?_eq_some h
  (repeat' split at hr) <;> simp_all [not_selfGuarded_of_fresh]

set_option maxHeartbeats 4000000 in
/-- **After a fresh-label rule fires, its own pair reports a witness** — non-branching shapes.

The rule's emitted list is headed by the witness at the fresh label, and the second component
carries the edge that puts the fresh label in `witnessPresent`'s search: `futureOf` for the
future-directed rules, `pastOf` for the past-directed ones, `Branch.knownWorlds` for the two
world-minting rules, which need no edge. Proved by the same goal-side skeleton as
`applyRule_ordTimesKnown_nonbranching`, at the module's standing heartbeat figure — not above it. -/
theorem applyRule_fresh_witness_nonbranching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hfresh : ruleMintsFreshLabel rule = true) :
    ∀ nb ∈ nonBranchingResultBranch b (applyRule rule sf b ord).1,
      witnessPresent rule sf nb (applyRule rule sf b ord).2 = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [nonBranchingResultBranch, Option.mem_def, Option.some.injEq] at hnb
             first
               | (subst hnb
                  simp_all only [witnessPresent, TimeOrdering.addFuture, TimeOrdering.addPast,
                    List.cons_append, List.any_eq_true]
                  first
                    | exact ⟨_, mem_knownWorlds_of_mem List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩
                    | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩
                    | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                        contains_of_mem List.mem_cons_self⟩)
               | exact absurd hnb (by simp)))

set_option maxHeartbeats 4000000 in
/-- **After a fresh-label rule fires, its own pair reports a witness** — `.branching` shape, both
arms.

`untlPos` and `sncePos` are the only fresh-label rules that branch, and `witnessPresent`'s clause
for each is a disjunction matching the two arms exactly: arm 1 carries the event witness at the
fresh label, arm 2 carries the guard together with the Until/Since itself. Neither arm is the
weaker one — both are proved. -/
theorem applyRule_fresh_witness_branching {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hfresh : ruleMintsFreshLabel rule = true) :
    ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1,
      witnessPresent rule sf nb (applyRule rule sf b ord).2 = true := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> simp only [ruleMintsFreshLabel] at hfresh <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        first
          | contradiction
          | (intro nb hnb
             simp only [branchingResultBranches, List.mem_map, List.mem_cons, List.not_mem_nil,
               or_false] at hnb
             all_goals
               (obtain ⟨fs, hfs, rfl⟩ := hnb
                rcases hfs with rfl | rfl <;>
                  (simp_all only [witnessPresent, TimeOrdering.addFuture, TimeOrdering.addPast,
                     List.cons_append, List.any_eq_true, Bool.or_eq_true, Bool.and_eq_true]
                   all_goals first
                     | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                         Or.inl (contains_of_mem List.mem_cons_self)⟩
                     | exact ⟨_, mem_futureOf_of_mem_constraints _ _ _ List.mem_cons_self,
                         Or.inr ⟨contains_of_mem List.mem_cons_self,
                           contains_of_mem (List.mem_cons_of_mem _ List.mem_cons_self)⟩⟩
                     | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                         Or.inl (contains_of_mem List.mem_cons_self)⟩
                     | exact ⟨_, mem_pastOf_of_mem_constraints _ _ _ List.mem_cons_self,
                         Or.inr ⟨contains_of_mem List.mem_cons_self,
                           contains_of_mem (List.mem_cons_of_mem _ List.mem_cons_self)⟩⟩))))

/-! ### The two halves meet: a mint is a strict decrease

The guard puts the minting pair *in* the before-false set and the witness puts it *out* of the
after-false set, and the successor is a superset in both components, so the after-false set is a
strict subset of the before-false set. That is `mintPotential_lt_of_mint`, with its hypotheses now
supplied from the pick rather than assumed.

The two lemmas below are stated at the **pick**, not at the engine step, because that is where
both halves are available at once — `findApplicableRule_applyRule_pair` ties the pick's reported
result to `applyRule`'s, which is what lets the guard and the witness talk about the same rule
application. The engine's fuel induction consumes them through the pick-stage bridges.

With them, the once-only bound is complete: `mints_le_eight_mul` above turns "every step preserves
`mints + mintPotential`, and a mint pays one unit for a strict decrease" into
`#mints ≤ 8 · |U|` along a run of any length, carrying any number of ordered splits. The
conclusion mentions no branch and no branch growth, which is the property route (b) exists to
supply. -/

/-- **A `.linear` mint strictly decreases the potential.** -/
theorem mintPotential_lt_of_pick_linear {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {sf₀ sf : SignedFormula}
    {fs : List SignedFormula} {o : TimeOrdering}
    (hpick : findApplicableRule sf₀ b ord fc = some (r, RuleResult.linear fs, o))
    (hfresh : ruleMintsFreshLabel r = true) (hsfU : sf ∈ U) (hσ : σ sf = sf₀) :
    mintPotential U σ (fs ++ b) o < mintPotential U σ b ord := by
  have hpair : applyRule r sf₀ b ord = (RuleResult.linear fs, o) :=
    findApplicableRule_applyRule_pair hpick
  have hbefore : witnessPresent r (σ sf) b ord = false := by
    rw [hσ]; exact findApplicableRule_guard_linear hpick hfresh
  have hafter : witnessPresent r (σ sf) (fs ++ b) o = true := by
    rw [hσ]
    have := applyRule_fresh_witness_nonbranching (rule := r) (sf := sf₀) (b := b) (ord := ord)
      hfresh (fs ++ b) (by rw [hpair]; simp [nonBranchingResultBranch])
    rwa [hpair] at this
  have hord : ∀ q ∈ ord.constraints, q ∈ o.constraints := by
    have := applyRule_ord_mono r sf₀ b ord
    rwa [hpair] at this
  exact mintPotential_lt_of_mint (fun _ hx => List.mem_append_right fs hx) hord
    (mem_freshLabelRules.mpr hfresh) hsfU hbefore hafter

/-- **A `.branching` mint strictly decreases the potential, on every arm.** Both arms of
`untlPos` / `sncePos` carry the witness, so neither arm is the one that escapes the bound. -/
theorem mintPotential_lt_of_pick_branching {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {r : TableauRule} {sf₀ sf : SignedFormula}
    {bss : List (List SignedFormula)} {o : TimeOrdering}
    (hpick : findApplicableRule sf₀ b ord fc = some (r, RuleResult.branching bss, o))
    (hfresh : ruleMintsFreshLabel r = true) (hsfU : sf ∈ U) (hσ : σ sf = sf₀) :
    ∀ arm ∈ bss, mintPotential U σ (arm ++ b) o < mintPotential U σ b ord := by
  have hpair : applyRule r sf₀ b ord = (RuleResult.branching bss, o) :=
    findApplicableRule_applyRule_pair hpick
  have hbefore : witnessPresent r (σ sf) b ord = false := by
    rw [hσ]; exact findApplicableRule_guard_branching hpick hfresh
  have hord : ∀ q ∈ ord.constraints, q ∈ o.constraints := by
    have := applyRule_ord_mono r sf₀ b ord
    rwa [hpair] at this
  intro arm harm
  have hafter : witnessPresent r (σ sf) (arm ++ b) o = true := by
    rw [hσ]
    have := applyRule_fresh_witness_branching (rule := r) (sf := sf₀) (b := b) (ord := ord)
      hfresh (arm ++ b) (by rw [hpair]; exact List.mem_map_of_mem harm)
    rwa [hpair] at this
  exact mintPotential_lt_of_mint (fun _ hx => List.mem_append_right arm hx) hord
    (mem_freshLabelRules.mpr hfresh) hsfU hbefore hafter

/-! ## C5. The counting chain — identifications, shrinkage, extensions

Three inequalities, each **absolute**: none of them refers to how long the run is, and each is a
fold of one per-step fact over the run. `fold_le_of_step` is that fold, stated once and
instantiated three times — the additive form `f (i+1) + g i ≤ f i + g (i+1)` says "`f - g` does
not increase" without ever writing a `Nat` subtraction, which is what keeps `omega` in play at
every link.

**Link 1 — `#identifications ≤ |knownTimes|₀ + #mints`.** Each identification drops the known-time
count by at least one (`knownTimes_card_lt_at_arm3`, from the landed
`knownTimes_card_lt_identifyTime` with the trigger supplying its three hypotheses); each mint
raises it by at most one; every other step leaves it alone. The three per-step arithmetic facts
are `identStep_le`, `mintStep_le`, `plainStep_le`.

**The payoff is that the time bound is derived rather than assumed, and this is what makes the
mint budget a discharged parameter instead of a residual.** Composing link 1 with
`mints_le_eight_mul` bounds the known-time count along the whole run by
`|knownTimes|₀ + 8 * |U|`, which is `derivedTmax`. `BudgetedTotality`'s time hypothesis is
satisfied at that value by `derivedTmax_spec`, definitionally — nothing is assumed about `Tmax`
anywhere in this development.

**Link 2 — `total shrinkage ≤ #identifications · |U|`.** A single identification's `eraseDups`
merge cannot remove more than the branch had, and the branch is confined to `U`, so
`shrinkage_le_card` bounds one identification's loss by `|U|` outright.

**This is an UPPER bound on the loss, and it must not be confused with the refuted lower bound.**
Route (a) sought a *lower* bound on `(b.identifyTime t₂ t₁).toFinset.card` in terms of
`b.toFinset.card`, and that is dead by definition: `Branch.identifyTime` is
`(b.map relabel).eraseDups` and the merge is bounded only by `|U|` in the direction taken here.
Bounding the loss from above is available; bounding the survivors from below is not. A reader
meeting `shrinkage_le_card` and thinking it revives route (a) has the direction backwards.

**Link 3 — `#extensions ≤ |U| + total shrinkage`.** The branch-as-a-set grows by at least one per
extending step (`expandOnceUnblocked_card_lt`, and `expandOnceUnblocked_split_card_lt` for the
split arms) and can never exceed `|U|`; shrinkage is the only way that budget comes back.

**Assembly.** `path_le_of_links` combines the three, and `path_le_splitPathBound` checks the
result against the figure that already exists rather than introducing a new one: the assembled
bound `|U| + Tmax·|U| + Tmax` is below `splitPathBound |U| Tmax`, because `orderedRunBound` is
above `Tmax` (`orderedRunBound_ge`) and `splitPathBound` multiplies by `|U| + 1`. So Phase 13's
induction consumes `splitAwareFuel` unchanged, and **no divergence from the landed figure had to
be recorded**. -/

/-- **The fold every link of the chain uses.** If `f` gains no more than `g` does at each step,
then it has gained no more than `g` has over the whole run. Written additively so that no `Nat`
subtraction ever appears. -/
theorem fold_le_of_step (f g : Nat → Nat) (n : Nat)
    (hstep : ∀ i < n, f (i + 1) + g i ≤ f i + g (i + 1)) :
    f n + g 0 ≤ f 0 + g n := by
  induction n with
  | zero => exact Nat.le_refl _
  | succ k ih =>
    have hk := hstep k (Nat.lt_succ_self k)
    have hih := ih (fun i hi => hstep i (Nat.lt_succ_of_lt hi))
    omega

/-- An identification spends one unit of the identification counter and buys a strict drop in the
known-time count. -/
theorem identStep_le {ident kt mints ident' kt' : Nat}
    (hi : ident' = ident + 1) (hk : kt' < kt) :
    (ident' + kt') + mints ≤ (ident + kt) + mints := by omega

/-- A mint adds at most one known time and spends one unit of the mint counter. -/
theorem mintStep_le {ident kt mints kt' : Nat} (hk : kt' ≤ kt + 1) :
    (ident + kt') + mints ≤ (ident + kt) + (mints + 1) := by omega

/-- Every other step leaves the known-time count where it was, or lower. -/
theorem plainStep_le {ident kt mints kt' : Nat} (hk : kt' ≤ kt) :
    (ident + kt') + mints ≤ (ident + kt) + mints := by omega

/-- **An identification drops the known-time count**, with the trigger supplying the three
hypotheses `knownTimes_card_lt_identifyTime` asks for: both times are known and they are
distinct. -/
theorem knownTimes_card_lt_at_arm3 {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) :
    ((b.identifyTime t₂ t₁).knownTimes).toFinset.card < (b.knownTimes).toFinset.card := by
  obtain ⟨h1, h2, hne, -, -⟩ := firstIncomparablePair_spec htrig
  exact knownTimes_card_lt_identifyTime h1 h2 hne

/-- **Link 1**: `#identifications ≤ |knownTimes|₀ + #mints`. -/
theorem idents_le_knownTimes_add_mints (kt ident mints : Nat → Nat) (n : Nat)
    (h0 : ident 0 = 0) (hm0 : mints 0 = 0)
    (hstep : ∀ i < n, (ident (i + 1) + kt (i + 1)) + mints i
      ≤ (ident i + kt i) + mints (i + 1)) :
    ident n ≤ kt 0 + mints n := by
  have h := fold_le_of_step (fun i => ident i + kt i) mints n hstep
  omega

/-- **The derived time bound.** The initial known-time count plus the mint budget — *derived* from
link 1 and `mints_le_eight_mul`, never assumed. -/
def derivedTmax (kt0 Ucard : Nat) : Nat := kt0 + 8 * Ucard

/-- `BudgetedTotality`'s time hypothesis is satisfied at `derivedTmax`, definitionally. This is
what makes the mint budget a discharged parameter rather than a caller obligation. -/
theorem derivedTmax_spec (b : Branch) (U : Finset SignedFormula) :
    b.knownTimes.toFinset.card + 8 * U.card
      ≤ derivedTmax (b.knownTimes.toFinset.card) U.card := Nat.le_refl _

/-- **One identification's shrinkage is bounded by `|U|`** — an upper bound on the *loss*, which is
available; not a lower bound on the survivors, which is refuted. -/
theorem shrinkage_le_card {U : Finset SignedFormula} {b : Branch}
    (hU : ∀ x ∈ b, x ∈ U) (t₁ t₂ : TimeIndex) :
    b.toFinset.card - (b.identifyTime t₂ t₁).toFinset.card ≤ U.card :=
  Nat.le_trans (Nat.sub_le _ _) (card_le_of_subset_universe hU)

/-- **Link 2**: `total shrinkage ≤ #identifications · |U|`. -/
theorem shrinkage_total_le (shrink ident : Nat → Nat) (Ucard n : Nat)
    (h0 : shrink 0 = 0) (hi0 : ident 0 = 0)
    (hstep : ∀ i < n, shrink (i + 1) + ident i * Ucard
      ≤ shrink i + ident (i + 1) * Ucard) :
    shrink n ≤ ident n * Ucard := by
  have h := fold_le_of_step shrink (fun i => ident i * Ucard) n hstep
  simp only [hi0, h0, Nat.zero_mul] at h
  omega

/-- **Link 3**: `#extensions ≤ |U| + total shrinkage`. -/
theorem extensions_le (ext card shrink : Nat → Nat) (Ucard n : Nat)
    (h0 : ext 0 = 0) (hs0 : shrink 0 = 0) (hU : card n ≤ Ucard)
    (hstep : ∀ i < n, ext (i + 1) + (card i + shrink i)
      ≤ ext i + (card (i + 1) + shrink (i + 1))) :
    ext n ≤ Ucard + shrink n := by
  have h := fold_le_of_step ext (fun i => card i + shrink i) n hstep
  simp only [h0, hs0] at h
  omega

/-- **The three links assembled** into a bound on the path length, at the derived time bound. -/
theorem path_le_of_links (ext ident : Nat → Nat) (Ucard Tmax0 mintBudget shrinkN n : Nat)
    (hext : ext n ≤ Ucard + shrinkN)
    (hshrink : shrinkN ≤ ident n * Ucard)
    (hident : ident n ≤ Tmax0 + mintBudget) :
    ext n + ident n ≤ Ucard + (Tmax0 + mintBudget) * Ucard + (Tmax0 + mintBudget) := by
  have h1 : ident n * Ucard ≤ (Tmax0 + mintBudget) * Ucard := Nat.mul_le_mul_right _ hident
  omega

/-- `orderedRunBound` is above its argument, which is all the assembly needs of it. -/
theorem orderedRunBound_ge (Tmax : Nat) : Tmax ≤ orderedRunBound Tmax := by
  have h : Tmax * 1 ≤ Tmax * (Tmax * Tmax + 1) := Nat.mul_le_mul (Nat.le_refl _) (by omega)
  simp only [orderedRunBound]
  omega

/-- **The assembled figure fits inside the landed `splitPathBound`**, so the fuel induction
consumes `splitAwareFuel` unchanged and no new figure is introduced. -/
theorem path_le_splitPathBound (Ucard Tmax ext ident : Nat)
    (h : ext + ident ≤ Ucard + Tmax * Ucard + Tmax) :
    ext + ident ≤ splitPathBound Ucard Tmax := by
  have hO := orderedRunBound_ge Tmax
  have hmul : Ucard * Tmax ≤ Ucard * orderedRunBound Tmax :=
    Nat.mul_le_mul (Nat.le_refl _) hO
  have hexp : (Ucard + 1) * (orderedRunBound Tmax + 1)
      = Ucard * orderedRunBound Tmax + Ucard + orderedRunBound Tmax + 1 := by ring
  rw [Nat.mul_comm Tmax Ucard] at h
  simp only [splitPathBound, hexp]
  omega

/-! ## C6. The fuel induction, over an abstract measure

The induction that closes the branching case, stated once and over an **abstract** carried state,
measure and invariant. Separating it from any particular measure is what makes it checkable: the
statement below mentions no branch cardinality, no known-time count, no mint potential and no
ordering rank, and its proof therefore cannot smuggle in a fact about any of them. All four
`ExpansionResult` shapes are discharged here — `.saturated` by the engine's own return, `.extended`
by the inductive hypothesis at one less unit of fuel, and both split shapes through the landed
folds — so the only thing a concrete measure has to supply is the per-step obligation bundle
`StepDecreases`.

**Why the carried state is a parameter rather than a fixed measure.** The mint potential carries
the accumulated renaming `σ`, and `σ` changes at the ordered split's identification arm. A measure
of the shape `Ψ : Branch → TimeOrdering → Nat` therefore cannot express it. `StepDecreases` lets
each successor *choose* its own carried state (`∃ a'`), which is exactly the disjunction
`mintPotential_expandOnceUnblocked_splitOrdered` reports.

**The two residuals this section names rather than absorbs.**

* `ArmSettlement` — `resolveOpenArm` reports `none` on an arm that is neither closed nor
  blocking-aware saturated after the post-blocking pass. `Fuel.lean` records this outcome as
  **reachable**, not dead, and carries it as the per-arm hypothesis `hres` of both fold lemmas;
  nothing here discharges it, so it appears as a hypothesis under a name. It is stated exactly in
  the form the folds consume, quantified only over arms an engine run actually produces, so it is
  not the (false) blanket claim that `resolveOpenArm` never reports `none` — at `fuel = 0` and an
  unsaturated arm it plainly does.
* the difficulty and arity coefficients `D` and `β` — carried as `StepDecreases` clauses rather
  than computed, which is the interface `Fuel.lean`'s `splitAwareFuel` already documents:
  `temporalCount` and `modalCount` are `private` to `Saturation.lean`, so a bound on
  `estimateBranchDifficulty` cannot be *stated* from this file without editing that one. -/

/-- **The fuel a run of at most `N` engine steps needs**, at split arity `β` and per-arm difficulty
`D`.

`N` units would suffice if fuel were not divided at a split; `allocateFuelProportionally` hands an
arm only a proportional share, and `allocateFuelProportionally_ge` says an arm is guaranteed `m`
units only when `D * β * m ≤ fuel + 1`, so each split costs a factor of `D * β + 1`. Over a path of
`N` steps that is `(D * β + 1) ^ N`.

This is the landed `splitAwareFuel` with its path length made a parameter:
`fuelFigure D β (splitPathBound Ucard Tmax)` is `splitAwareFuel Ucard Tmax D β` **definitionally**
(`fuelFigure_splitAwareFuel`, by `rfl`). Nothing about the figure changes; only the path bound it
is evaluated at becomes visible. -/
def fuelFigure (D β N : Nat) : Nat := N * (D * β + 1) ^ N

/-- The landed figure is this one at the landed path bound, on the nose. -/
theorem fuelFigure_splitAwareFuel (Ucard Tmax D β : Nat) :
    fuelFigure D β (splitPathBound Ucard Tmax) = splitAwareFuel Ucard Tmax D β := rfl

/-- The decay factor is at least one, at every exponent. -/
theorem one_le_pow_succ (K N : Nat) : 1 ≤ (K + 1) ^ N := Nat.one_le_pow _ _ (Nat.succ_pos _)

/-- A nonzero path bound needs at least one unit of fuel — which is what lets the induction
destructure `fuel` and reach the engine's `fuel + 1` arm. -/
theorem fuelFigure_pos {D β N : Nat} (hN : 1 ≤ N) : 1 ≤ fuelFigure D β N := by
  simp only [fuelFigure]
  exact Nat.one_le_iff_ne_zero.mpr (by
    have := one_le_pow_succ (D * β) N
    exact Nat.mul_ne_zero (by omega) (by omega))

/-- **One step's worth of slack.** The figure at `N + 1` covers the figure at `N` plus the one unit
the step itself consumes. This is what re-establishes both the fuel hypothesis and the `β`-linear
branch-budget hypothesis at every successor. -/
theorem fuelFigure_succ (D β N : Nat) : fuelFigure D β N + 1 ≤ fuelFigure D β (N + 1) := by
  simp only [fuelFigure]
  have hp : 1 ≤ (D * β + 1) ^ N := one_le_pow_succ _ _
  have h1 : (N + 1) * (D * β + 1) ^ (N + 1)
      = (N + 1) * ((D * β + 1) ^ N * (D * β + 1)) := by rw [Nat.pow_succ]
  have h2 : (N + 1) * (D * β + 1) ^ N ≤ (N + 1) * ((D * β + 1) ^ N * (D * β + 1)) :=
    Nat.mul_le_mul_left _ (Nat.le_mul_of_pos_right _ (by omega))
  have h3 : (N + 1) * (D * β + 1) ^ N = N * (D * β + 1) ^ N + (D * β + 1) ^ N := by ring
  omega

/-- **The allocation condition, discharged from the figure.** `allocateFuelProportionally_ge` asks
for `T * m ≤ fuel + 1` with `T` the arms' total difficulty; `totalDifficulty_le` bounds `T` by
`D * β`, and this is the resulting arithmetic. It is the whole reason the figure carries a power
rather than a product. -/
theorem fuelFigure_alloc (D β N : Nat) :
    D * β * fuelFigure D β N ≤ fuelFigure D β (N + 1) := by
  simp only [fuelFigure]
  have h1 : D * β * (N * (D * β + 1) ^ N) = N * (D * β + 1) ^ N * (D * β) := by ring
  have h2 : (N + 1) * (D * β + 1) ^ (N + 1)
      = (N + 1) * (D * β + 1) ^ N * (D * β + 1) := by rw [Nat.pow_succ]; ring
  have h3 : N * (D * β + 1) ^ N * (D * β) ≤ (N + 1) * (D * β + 1) ^ N * (D * β + 1) :=
    Nat.mul_le_mul (Nat.mul_le_mul_right _ (by omega)) (by omega)
  omega

/-- The figure is monotone in the path bound, so a later, larger path bound never invalidates an
earlier, smaller one. -/
theorem fuelFigure_mono {D β N N' : Nat} (h : N ≤ N') :
    fuelFigure D β N ≤ fuelFigure D β N' :=
  Nat.mul_le_mul h (Nat.pow_le_pow_right (by omega) h)

/-- **The per-step obligation bundle.**

Everything a concrete measure has to supply, and nothing else. Each successor may choose its own
carried state `a'` — which is what lets the mint potential's renaming change at the ordered split's
identification arm — and every clause is stated at the engine step rather than at `applyRule`, so
no pick-stage reasoning leaks into the induction.

The `β` clauses bound the split arity and the `D` clauses bound a single arm's
`estimateBranchDifficulty`; both are the coefficients `splitAwareFuel` already carries. -/
def StepDecreases {α : Type} (fc : FormalSystem.ProofSystem.FrameClass)
    (P : α → Branch → TimeOrdering → Prop) (Ψ : α → Branch → TimeOrdering → Nat)
    (D β : Nat) : Prop :=
  ∀ (a : α) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker), P a b ord →
    (∀ nb, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.extended nb →
        ∃ a' : α, P a' nb (expandOnceUnblocked b ord fc tr).2 ∧
          Ψ a' nb (expandOnceUnblocked b ord fc tr).2 < Ψ a b ord) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.split bs →
        bs.length ≤ β ∧ (∀ nb ∈ bs, estimateBranchDifficulty nb ≤ D) ∧
        ∀ nb ∈ bs, ∃ a' : α, P a' nb (expandOnceUnblocked b ord fc tr).2 ∧
          Ψ a' nb (expandOnceUnblocked b ord fc tr).2 < Ψ a b ord) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        bs.length ≤ β ∧ (∀ p ∈ bs, estimateBranchDifficulty p.1 ≤ D) ∧
        ∀ p ∈ bs, ∃ a' : α, P a' p.1 p.2 ∧ Ψ a' p.1 p.2 < Ψ a b ord)

/-- **The arm-settlement residual, named rather than absorbed.**

Both split folds short-circuit on `resolveOpenArm` reporting `none`, and `Fuel.lean` records that
outcome as **reachable**: by `resolveOpenArm_eq_none_imp` the surviving route is its final "still
not saturated" arm, where the post-blocking pass returned an open branch that `findClosure` does
not close and that the arm's own recomputed tracker does not certify as blocking-aware saturated.
That is the configuration the refuted unconditional totality statement died on, so it is a live
outcome, not a dead one.

**The quantification is the honest one.** A blanket "`resolveOpenArm` never reports `none`" is
plainly false — at `fuel = 0` and an unsaturated arm it reports `none` — so this predicate is
restricted to arms an engine run actually hands the fold: `ob` is a branch some
`expandBranchWithFuel` call returned open, and `parentFuel` is the enclosing call's own fuel, which
dominates the arm's. Whether *that* is true is exactly the open question `Fuel.lean` records;
nothing in this file decides it in either direction, and it is a hypothesis everywhere it appears.

The gap it isolates is a disagreement between two eventuality trackers: the engine reports
`.saturated` against the tracker it has threaded through the run, while `resolveOpenArm` re-derives
one from the arm's own formulas (`armTracker`). The recomputed tracker is the *stricter* of the
two, so the engine's verdict does not transfer, and closing the gap means comparing the two blocked
sets — not adding fuel. -/
def ArmSettlement (fc : FormalSystem.ProofSystem.FrameClass) : Prop :=
  ∀ (b ob : Branch) (armFuel parentFuel : Nat) (ord oOrd : TimeOrdering)
    (tr : EventualityTracker) (ap oAp : AppliedSet) (mb bu : Nat),
    armFuel ≤ parentFuel →
    expandBranchWithFuel b armFuel ord fc tr ap mb bu = some (.inr (ob, oOrd, oAp)) →
    (resolveOpenArm ob oOrd oAp parentFuel fc).isSome = true

/--
**The fuel induction, `NoSplit`-free, over an abstract measure.**

Read against the landed `expandBranchWithFuel_isSome_of_noSplit`, exactly one thing is removed and
nothing is added in its place: the unbranching-run restriction is gone, name and all, and both
split shapes are discharged here rather than excluded. `.split` goes through
`expand_split_fold_isSome` with `allocateFuelProportionally_ge` and `totalDifficulty_le` supplying
the arm's fuel and `splitBudget_preserved` the arm's budget; `.splitOrdered` goes through
`expand_splitOrdered_fold_isSome` in the same shape, with each arm expanded under **its own**
ordering.

The measure is abstract, so this theorem asserts nothing about the engine's termination behaviour
by itself: it converts a per-step decrease into totality at the figure that decrease earns. The
mathematical content of the branching case lives in `StepDecreases`, and is supplied for the mint
potential further down.

`β ≥ 1` is not decoration. The engine's very first line returns `none` when
`branchesUsed ≥ maxBranches`, so a budget hypothesis has to be strict somewhere; `β * fuelFigure`
with `β ≥ 1` and a positive path bound is what makes it strict. `BudgetedTotality`'s
`β`-linear hypothesis is **not** strict at `β = 0`, which is why the naked statement is refutable
there (`budgetedTotality_beta_zero_false`).
-/
theorem expandBranchWithFuel_isSome_of_measure {α : Type}
    {fc : FormalSystem.ProofSystem.FrameClass} {P : α → Branch → TimeOrdering → Prop}
    {Ψ : α → Branch → TimeOrdering → Nat} {D β : Nat}
    (hβ : 1 ≤ β) (hstep : StepDecreases fc P Ψ D β) (harm : ArmSettlement fc) :
    ∀ (N : Nat) (a : α) (fuel : Nat) (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker)
      (applied : AppliedSet) (maxBranches branchesUsed : Nat),
      P a b ord → Ψ a b ord < N → fuelFigure D β N ≤ fuel →
      branchesUsed + β * fuelFigure D β N ≤ maxBranches →
      (expandBranchWithFuel b fuel ord fc tr applied maxBranches branchesUsed).isSome = true := by
  intro N
  induction N with
  | zero => intro _ _ _ _ _ _ _ _ _ hlt; exact absurd hlt (by omega)
  | succ M ih =>
    intro a fuel b ord tr applied mb bu hP hlt hfuel hbud
    have hFpos : 1 ≤ fuelFigure D β (M + 1) := fuelFigure_pos (by omega)
    have hsucc := fuelFigure_succ D β M
    have hβF : 1 ≤ β * fuelFigure D β (M + 1) :=
      Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega))
    rcases fuel with _ | f
    · omega
    have hfM : fuelFigure D β M ≤ f := by omega
    have hbudM : ∀ k, k ≤ β → bu + k + β * fuelFigure D β M ≤ mb := by
      intro k hk
      have : β * (fuelFigure D β M + 1) ≤ β * fuelFigure D β (M + 1) :=
        Nat.mul_le_mul_left _ (by omega)
      have h2 : β * (fuelFigure D β M + 1) = β * fuelFigure D β M + β := by ring
      omega
    rw [expandBranchWithFuel, if_neg (by omega : ¬ bu ≥ mb)]
    rcases hcl : findClosure b fc with _ | reason
    case some => simp
    case none =>
      simp only [expandOnceUnblockedWithApplied]
      obtain ⟨hext, hsp, hsso⟩ :=
        hstep a b ord (fulfillEventualities b (registerEventualities b tr)) hP
      rcases hres : (expandOnceUnblocked b ord fc
          (fulfillEventualities b (registerEventualities b tr))).1 with _ | nb | bs | bs
      · simp
      · obtain ⟨a', hP', hΨ'⟩ := hext nb hres
        simpa using ih a' f nb _ _ applied mb (bu + 1) hP' (by omega) hfM
          (by have := hbudM 1 hβ; omega)
      · obtain ⟨harity, hdiff, harms⟩ := hsp bs hres
        have hT : ((bs.map estimateBranchDifficulty).foldl (· + ·) 0) * fuelFigure D β M
            ≤ f + 1 := by
          have h1 := totalDifficulty_le bs D hdiff
          have h2 : D * bs.length ≤ D * β := Nat.mul_le_mul_left _ harity
          have h3 : ((bs.map estimateBranchDifficulty).foldl (· + ·) 0) * fuelFigure D β M
              ≤ (D * β) * fuelFigure D β M := Nat.mul_le_mul_right _ (by omega)
          have h4 := fuelFigure_alloc D β M
          omega
        refine expand_split_fold_isSome f _ fc _ _ mb _ _ ?_ ?_ _ (by simp)
        · intro pair hp
          obtain ⟨hb, hal⟩ := List.of_mem_zip hp
          obtain ⟨a', hP', hΨ'⟩ := harms pair.1 hb
          refine ih a' (min pair.2 f) pair.1 _ _ _ mb _ hP' (by omega) ?_ ?_
          · exact Nat.le_min.mpr
              ⟨allocateFuelProportionally_ge f bs _ _ hfM hT hal, hfM⟩
          · exact hbudM bs.length harity
        · intro pair hp ob oOrd oAp hexp
          exact harm _ _ _ _ _ _ _ _ _ _ _ (Nat.min_le_right _ _) hexp
      · obtain ⟨harity, hdiff, harms⟩ := hsso bs hres
        have hdiff' : ∀ nb ∈ bs.map Prod.fst, estimateBranchDifficulty nb ≤ D := by
          intro nb hnb
          obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hnb
          exact hdiff p hp
        have hT : (((bs.map Prod.fst).map estimateBranchDifficulty).foldl (· + ·) 0)
            * fuelFigure D β M ≤ f + 1 := by
          have h1 := totalDifficulty_le (bs.map Prod.fst) D hdiff'
          have hlen : (bs.map Prod.fst).length = bs.length := by simp
          have h2 : D * (bs.map Prod.fst).length ≤ D * β := by
            rw [hlen]; exact Nat.mul_le_mul_left _ harity
          have h3 : (((bs.map Prod.fst).map estimateBranchDifficulty).foldl (· + ·) 0)
              * fuelFigure D β M ≤ (D * β) * fuelFigure D β M :=
            Nat.mul_le_mul_right _ (by omega)
          have h4 := fuelFigure_alloc D β M
          omega
        refine expand_splitOrdered_fold_isSome f fc _ _ mb _ _ ?_ ?_ _ (by simp)
        · intro pair hp
          obtain ⟨hb, hal⟩ := List.of_mem_zip hp
          obtain ⟨a', hP', hΨ'⟩ := harms pair.1 hb
          refine ih a' (min pair.2 f) pair.1.1 pair.1.2 _ _ mb _ hP' (by omega) ?_ ?_
          · exact Nat.le_min.mpr
              ⟨allocateFuelProportionally_ge f (bs.map Prod.fst) _ _ hfM hT hal, hfM⟩
          · exact hbudM bs.length harity
        · intro pair hp ob oOrd oAp hexp
          exact harm _ _ _ _ _ _ _ _ _ _ _ (Nat.min_le_right _ _) hexp

end FormalSystem.Metalogic.Decidability
