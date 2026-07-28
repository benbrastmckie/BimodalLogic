/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty
import Mathlib.Data.Finset.Powerset
import Mathlib.Data.Finset.Prod

/-!
# T2 — The Time-Type Bound and the Pigeonhole

T1 (`SubformulaProperty.lean`) says expansion never leaves a `TableauClosed` stock `C`. This file
draws the consequence the fuel argument needs: **a branch whose formulas all lie in `C` has at
most `2 ^ (2 * |C|)` distinguishable times**, so a chain of times longer than that must repeat a
time type, and blocking fires.

## Why counting time *types* rather than times

`Branch.isSubsetBlocked` compares the `(sign, formula)` pairs carried at two times, and
`isTemporallyBlocked` fires when a time's pairs are contained in an ancestor's. So the quantity
to bound is not the number of times — which is unbounded, since witness rules mint fresh ones —
but the number of *distinct sets of pairs* a time can carry. Under T1 every pair is drawn from
`signedStock C`, whose cardinality is `2 * |C|`, so a time type is an element of
`(signedStock C).powerset` and there are at most `2 ^ (2 * |C|)` of them.

This is the pigeonhole shape the plan's constraint 5 forces: no depth or rank measure can work
for the modal dimension (cslib mechanized the falsity of that route), so termination is bought by
counting against a fixed finite universe.

## What the caller must supply, and why each hypothesis is real

`blocking_fires_of_card_lt` is stated over an arbitrary finite set `ts` of times rather than over
"the branch's times", because two of its hypotheses are genuinely about the *shape* of `ts` and
cannot be read off the branch:

* `hchain` — pigeonhole alone gives two times with equal type, but `isTemporallyBlocked` needs one
  of them to be an *ancestor* of the other. Two incomparable times with the same type block
  nothing. So the caller must present a chain. `Fuel.lean` gets this from the expansion history:
  fresh times are minted as successors of the time being expanded.
* `hev` — blocking is guarded by `allEventualitiesFulfilledOrDuplicated`, which is not a
  consequence of type equality. This is the guard that Phase 1.3 made genuine, and it is
  deliberately not assumed away here: `blocking_fires_of_card_lt_empty` discharges it for the
  empty tracker, and any caller running with a live tracker owes the real thing.

## Main definitions

- `signedStock` — the `2 * |C|` signed pairs available over a formula stock `C`.
- `Branch.timeTypeFinset` — the engine's `Branch.timeType` list, as a `Finset`.

## Main theorems

- `card_signedStock` — `|signedStock C| = 2 * |C|`.
- `exists_ne_timeType_eq` — the pigeonhole: more than `2 ^ (2 * |C|)` times force a repeat.
- `blocking_fires_of_card_lt` — a long enough chain of times makes `findBlockedTime` fire.
- `tableauClosed_of_closureStep_subset` — `TableauClosed C` reduces to the decidable containment
  `closureStep C ⊆ C`, so a caller exhibits a stock and runs a check instead of reproving seven
  fields.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-! ## The signed stock over a formula stock -/

/--
The signed pairs available over a formula stock `C`: each formula of `C` with each sign.

This is the universe a time type is drawn from once T1 has pinned every branch formula to `C`.
-/
def signedStock (C : Finset Formula) : Finset (Sign × Formula) :=
  ({Sign.pos, Sign.neg} : Finset Sign) ×ˢ C

@[simp] theorem mem_signedStock {C : Finset Formula} {p : Sign × Formula} :
    p ∈ signedStock C ↔ p.2 ∈ C := by
  obtain ⟨s, φ⟩ := p
  cases s <;> simp [signedStock]

/-- The sign dimension contributes a factor of two and nothing else. -/
theorem card_signedStock (C : Finset Formula) : (signedStock C).card = 2 * C.card := by
  simp [signedStock, Finset.card_product]

/-! ## Time types as finite sets -/

/--
The time type at `t`, as a `Finset`.

The engine's `Branch.timeType` is a deduplicated `List`, which is the right representation for
`decide`-style execution but the wrong one for counting: two lists can carry the same pairs in
different orders. Cardinality arguments need the quotient, so this file works with the `Finset`
and relates it back to the list form in `isSubsetBlocked_of_timeTypeFinset_subset`.
-/
def Branch.timeTypeFinset (b : Branch) (t : TimeIndex) : Finset (Sign × Formula) :=
  (b.timeType t).toFinset

@[simp] theorem Branch.mem_timeTypeFinset {b : Branch} {t : TimeIndex} {p : Sign × Formula} :
    p ∈ b.timeTypeFinset t ↔ p ∈ b.timeType t := List.mem_toFinset

/-- A pair carried at some time is a signed branch formula. -/
theorem exists_mem_of_mem_timeType {b : Branch} {t : TimeIndex} {p : Sign × Formula}
    (hp : p ∈ b.timeType t) : ∃ sf ∈ b, sf.sign = p.1 ∧ sf.formula = p.2 := by
  rw [Branch.timeType, List.mem_eraseDups, List.mem_map] at hp
  obtain ⟨sf, hsf, rfl⟩ := hp
  rw [Branch.formulasAtTime, List.mem_filter] at hsf
  exact ⟨sf, hsf.1, rfl, rfl⟩

/--
T1's consequence at the level of time types: if the branch stays inside `C`, every time type is
a subset of `signedStock C`.
-/
theorem timeTypeFinset_subset_signedStock {C : Finset Formula} {b : Branch}
    (hb : ∀ x ∈ b, x.formula ∈ C) (t : TimeIndex) :
    b.timeTypeFinset t ⊆ signedStock C := by
  intro p hp
  obtain ⟨sf, hsf, -, hform⟩ := exists_mem_of_mem_timeType (Branch.mem_timeTypeFinset.mp hp)
  exact mem_signedStock.mpr (hform ▸ hb sf hsf)

/-! ## The pigeonhole -/

/--
**T2.** More than `2 ^ (2 * |C|)` times on a branch confined to `C` force two of them to carry
exactly the same time type.

The bound is the plan's `2 ^ (2 * |signedClosure φ|)`: a time type is an element of
`(signedStock C).powerset`, and `|signedStock C| = 2 * |C|`.
-/
theorem exists_ne_timeType_eq {C : Finset Formula} {b : Branch}
    (hb : ∀ x ∈ b, x.formula ∈ C) (ts : Finset TimeIndex)
    (hcard : 2 ^ (2 * C.card) < ts.card) :
    ∃ t₁ ∈ ts, ∃ t₂ ∈ ts, t₁ ≠ t₂ ∧ b.timeTypeFinset t₁ = b.timeTypeFinset t₂ := by
  refine Finset.exists_ne_map_eq_of_card_lt_of_maps_to (t := (signedStock C).powerset) ?_ ?_
  · rw [Finset.card_powerset, card_signedStock]
    exact hcard
  · intro t _
    exact Finset.mem_powerset.mpr (timeTypeFinset_subset_signedStock hb t)

/-! ## From equal time types to blocking -/

/-- The `Finset` comparison implies the engine's list-level subset test. -/
theorem isSubsetBlocked_of_timeTypeFinset_subset {b : Branch} {t₁ t₂ : TimeIndex}
    (h : b.timeTypeFinset t₁ ⊆ b.timeTypeFinset t₂) : b.isSubsetBlocked t₁ t₂ = true := by
  rw [Branch.isSubsetBlocked]
  simp only [List.all_eq_true, List.any_eq_true, beq_iff_eq]
  intro p hp
  exact ⟨p, Branch.mem_timeTypeFinset.mp (h (Branch.mem_timeTypeFinset.mpr hp)), rfl⟩

/-- Blocking fires at `t` as soon as some ancestor dominates its type and the guard permits. -/
theorem isTemporallyBlocked_of_ancestor {b : Branch} {ord : TimeOrdering}
    {tracker : EventualityTracker} {t t_anc : TimeIndex}
    (hanc : t_anc ∈ ancestorTimes ord t)
    (hsub : b.timeTypeFinset t ⊆ b.timeTypeFinset t_anc)
    (hev : allEventualitiesFulfilledOrDuplicated tracker t t_anc = true) :
    isTemporallyBlocked b t ord tracker = true := by
  rw [isTemporallyBlocked]
  simp only [List.any_eq_true, Bool.and_eq_true]
  exact ⟨t_anc, hanc, isSubsetBlocked_of_timeTypeFinset_subset hsub, hev⟩

/--
**T2, in the form the fuel argument consumes.** A chain of more than `2 ^ (2 * |C|)` times on a
branch confined to `C` cannot be expanded further: `findBlockedTime` returns a time.

See the module docstring for why `hchain` and `hev` are genuine obligations rather than
bookkeeping.
-/
theorem blocking_fires_of_card_lt {C : Finset Formula} {b : Branch} {ord : TimeOrdering}
    {tracker : EventualityTracker}
    (hb : ∀ x ∈ b, x.formula ∈ C) (ts : Finset TimeIndex)
    (hts : ∀ t ∈ ts, t ∈ b.knownTimes)
    (hchain : ∀ t₁ ∈ ts, ∀ t₂ ∈ ts, t₁ ≠ t₂ →
      t₁ ∈ ancestorTimes ord t₂ ∨ t₂ ∈ ancestorTimes ord t₁)
    (hev : ∀ t₁ ∈ ts, ∀ t₂ ∈ ts, allEventualitiesFulfilledOrDuplicated tracker t₁ t₂ = true)
    (hcard : 2 ^ (2 * C.card) < ts.card) :
    (findBlockedTime b ord tracker).isSome = true := by
  obtain ⟨t₁, h₁, t₂, h₂, hne, heq⟩ := exists_ne_timeType_eq hb ts hcard
  rw [findBlockedTime, List.isSome_find?]
  simp only [List.any_eq_true]
  rcases hchain t₁ h₁ t₂ h₂ hne with h | h
  · exact ⟨t₂, hts t₂ h₂,
      isTemporallyBlocked_of_ancestor h (le_of_eq heq.symm) (hev t₂ h₂ t₁ h₁)⟩
  · exact ⟨t₁, hts t₁ h₁,
      isTemporallyBlocked_of_ancestor h (le_of_eq heq) (hev t₁ h₁ t₂ h₂)⟩

/--
The empty-tracker specialisation: with nothing pending, the eventuality guard is vacuous and the
pigeonhole alone forces blocking.
-/
theorem blocking_fires_of_card_lt_empty {C : Finset Formula} {b : Branch} {ord : TimeOrdering}
    (hb : ∀ x ∈ b, x.formula ∈ C) (ts : Finset TimeIndex)
    (hts : ∀ t ∈ ts, t ∈ b.knownTimes)
    (hchain : ∀ t₁ ∈ ts, ∀ t₂ ∈ ts, t₁ ≠ t₂ →
      t₁ ∈ ancestorTimes ord t₂ ∨ t₂ ∈ ancestorTimes ord t₁)
    (hcard : 2 ^ (2 * C.card) < ts.card) :
    (findBlockedTime b ord EventualityTracker.empty).isSome = true :=
  blocking_fires_of_card_lt hb ts hts hchain
    (fun _ _ _ _ => by simp [allEventualitiesFulfilledOrDuplicated,
      EventualityTracker.pendingAtTime, EventualityTracker.empty]) hcard

/-! ## A concrete closure operator

`blocking_fires_of_card_lt` counts against an arbitrary `TableauClosed C`. This section supplies
the operator that produces one, and reduces "`C` is `TableauClosed`" to a single **decidable**
containment, `closureStep C ⊆ C`.

The split is deliberate. `TableauClosed` is a seven-field predicate whose fields quantify over
formulas; `closureStep C ⊆ C` is a computation on a `Finset`. Reducing the former to the latter
means a caller never has to reprove the seven fields — it exhibits a `C` and runs the check. It
also makes the remaining termination obligation precise and isolated: *is there an `n` with
`closureStep (closureIter n seed) ⊆ closureIter n seed`?* The `#eval` probes at the end of this
section answer "yes, in one or two rounds" for concrete inputs, which is what keeps the
development from resting on an operator nobody has ever seen halt.
-/

/-- The subformulas of `φ`, as a `Finset`. -/
def subformulasFinset (φ : Formula) : Finset Formula := (Formula.subformulas φ).toFinset

/--
The two Dedekind emissions keyed on a conjunction `a ∧ b`, plus separation.

Each arm reproduces the corresponding `applyRule` guard exactly: `priorUGap` tests
`a = U(e, g)` with `e = ⊤` and `b = F(¬g)`; `priorSGap` is its past dual; `sepRule` tests
`a = K⁺ψ` (whose raw shape is `¬U(⊤, ¬ψ)`) with `b = ¬K⁺(ψ ∧ U(ψ, ¬ψ))`. Every arm is a *whole*
trigger, which is what makes the operator's output fail to re-trigger it — see the finiteness
discussion in `SubformulaProperty.lean`.
-/
def conjEmissions (a b : Formula) : Finset Formula :=
  match a with
  | .untl e g =>
      if e = Formula.top ∧ b = Formula.someFuture g.neg then
        {Formula.untl (Formula.or g.neg (Formula.kPlus g.neg)) g}
      else ∅
  | .snce e g =>
      if e = Formula.top ∧ b = Formula.somePast g.neg then
        {Formula.snce (Formula.or g.neg (Formula.kMinus g.neg)) g}
      else ∅
  | .imp (.untl e (.imp ψ .bot)) .bot =>
      if e = Formula.top ∧
          b = Formula.neg (Formula.kPlus (Formula.and ψ (Formula.untl ψ ψ.neg))) then
        {Formula.kPlus (Formula.and (Formula.kPlus ψ) (Formula.kMinus ψ))}
      else ∅
  | _ => ∅

/--
Everything one formula obliges the stock to contain: its subformulas, and the non-analytic
emission of whichever rule it triggers.

`boxTemporal` is keyed on `□ψ`; `priorUZ`/`priorSZ` on `Fψ = U(ψ, ⊤)` and `Pψ = S(ψ, ⊤)`; the
three Dedekind rules on conjunctions, via `conjEmissions`. `serialityRule` has no trigger at all,
so it contributes to `closureStep` rather than here.
-/
def emissions (φ : Formula) : Finset Formula :=
  subformulasFinset φ
    ∪ (match φ with
       | .box ψ => {ψ.allFuture, ψ.allPast}
       | .untl ψ χ => if χ = Formula.top then {Formula.untl ψ ψ.neg} else ∅
       | .snce ψ χ => if χ = Formula.top then {Formula.snce ψ ψ.neg} else ∅
       | _ => ∅)
    ∪ (match asAnd? φ with
       | some (a, b) => conjEmissions a b
       | none => ∅)

/-- One round of closure: everything the current stock obliges, plus the two seriality formulas. -/
def closureStep (C : Finset Formula) : Finset Formula :=
  C ∪ C.biUnion emissions ∪ {Formula.top.someFuture, Formula.top.somePast}

/-- `n` rounds of closure. -/
def closureIter : Nat → Finset Formula → Finset Formula
  | 0, C => C
  | n + 1, C => closureIter n (closureStep C)

theorem subset_closureStep (C : Finset Formula) : C ⊆ closureStep C := by
  intro φ hφ
  exact Finset.mem_union_left _ (Finset.mem_union_left _ hφ)

theorem mem_closureStep_of_mem_emissions {C : Finset Formula} {φ ψ : Formula}
    (hφ : φ ∈ C) (hψ : ψ ∈ emissions φ) : ψ ∈ closureStep C :=
  Finset.mem_union_left _ (Finset.mem_union_right _ (Finset.mem_biUnion.mpr ⟨φ, hφ, hψ⟩))

/--
**The satisfiability reduction.** A stock closed under one round of `closureStep` satisfies every
field of `TableauClosed`.

Each field is discharged by exhibiting its conclusion inside `emissions` of its own trigger, so
the seven-way case analysis happens once, here, instead of at every use site.
-/
theorem tableauClosed_of_closureStep_subset {C : Finset Formula} (h : closureStep C ⊆ C) :
    TableauClosed C where
  sub φ hφ ψ hψ :=
    h (mem_closureStep_of_mem_emissions hφ
      (Finset.mem_union_left _ (Finset.mem_union_left _ (List.mem_toFinset.mpr hψ))))
  boxTemp ψ hψ := by
    refine ⟨h (mem_closureStep_of_mem_emissions hψ ?_), h (mem_closureStep_of_mem_emissions hψ ?_)⟩
    · exact Finset.mem_union_left _ (Finset.mem_union_right _ (by simp))
    · exact Finset.mem_union_left _ (Finset.mem_union_right _ (by simp))
  serialFuture := h (Finset.mem_union_right _ (by simp))
  serialPast := h (Finset.mem_union_right _ (by simp))
  priorU ψ hψ :=
    h (mem_closureStep_of_mem_emissions hψ
      (Finset.mem_union_left _ (Finset.mem_union_right _ (by simp [Formula.someFuture]))))
  priorS ψ hψ :=
    h (mem_closureStep_of_mem_emissions hψ
      (Finset.mem_union_left _ (Finset.mem_union_right _ (by simp [Formula.somePast]))))
  gapU g hg :=
    h (mem_closureStep_of_mem_emissions hg
      (Finset.mem_union_right _ (by simp [conjEmissions, asAnd?, Formula.and,
        Formula.neg, Formula.top])))
  gapS g hg :=
    h (mem_closureStep_of_mem_emissions hg
      (Finset.mem_union_right _ (by simp [conjEmissions, asAnd?, Formula.and,
        Formula.neg, Formula.top])))
  sep ψ hψ :=
    h (mem_closureStep_of_mem_emissions hψ
      (Finset.mem_union_right _ (by simp [conjEmissions, asAnd?, Formula.and,
        Formula.neg, Formula.top, Formula.kPlus])))

/-- The `n`-round iterate is `TableauClosed` as soon as round `n + 1` adds nothing. -/
theorem tableauClosed_closureIter {C : Finset Formula} {n : Nat}
    (h : closureStep (closureIter n C) ⊆ closureIter n C) :
    TableauClosed (closureIter n C) :=
  tableauClosed_of_closureStep_subset h

/-! ### Stabilisation probes

A closure operator nobody has watched halt is not evidence of anything, so the reduction above is
committed together with executable rows that run it. Each row reports the round at which
`closureStep` stops adding formulas, starting from the subformula closure of `φ`, together with the
resulting `|C|` — which is the exponent in the `2 ^ (2 * |C|)` bound.

These are probes, not proofs: they witness that the operator halts on concrete inputs and that
`tableauClosed_of_closureStep_subset` is therefore not vacuously stated. The general
termination theorem is the remaining T2 obligation, tracked in the plan.
-/

section Probes

private def probeAtom (s : String) : Formula := Formula.atom (Atom.mkBase s)

/-- First round at which `closureStep` adds nothing, searching up to `fuel` rounds. -/
private def stabilisesAt (φ : Formula) (fuel : Nat) : Option (Nat × Nat) :=
  let rec go : Nat → Nat → Finset Formula → Option (Nat × Nat)
    | 0, _, _ => none
    | k + 1, n, C => if closureStep C ⊆ C then some (n, C.card) else go k (n + 1) (closureStep C)
  go fuel 0 (subformulasFinset φ)

-- `p`
/-- info: some (3, 8) -/
#guard_msgs in
#eval stabilisesAt (probeAtom "p") 8

-- `□p` — exercises `boxTemp`.
/-- info: some (4, 17) -/
#guard_msgs in
#eval stabilisesAt (Formula.box (probeAtom "p")) 8

-- `F p` — exercises `priorU`.
/-- info: some (3, 11) -/
#guard_msgs in
#eval stabilisesAt (Formula.someFuture (probeAtom "p")) 8

-- `G p` — `G` carries `F(¬p)` as a subformula, so this exercises `priorU` one level down.
/-- info: some (3, 13) -/
#guard_msgs in
#eval stabilisesAt (Formula.allFuture (probeAtom "p")) 8

-- `U(⊤, p) ∧ F(¬p)` — the real `priorUGap` trigger.
/-- info: some (3, 20) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.and (Formula.untl Formula.top (probeAtom "p"))
    (Formula.someFuture (probeAtom "p").neg)) 8

-- `K⁺p ∧ ¬K⁺(p ∧ U(p, ¬p))` — the real `sepRule` trigger.
/-- info: some (3, 30) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.and (Formula.kPlus (probeAtom "p"))
    (Formula.neg (Formula.kPlus
      (Formula.and (probeAtom "p") (Formula.untl (probeAtom "p") (probeAtom "p").neg))))) 8

/-! #### Cascade rows

The rows above start from formulas whose emission triggers are all visible in the seed. The rows
below are the adversarial ones: they are *built* so that a trigger only appears **after** a round
of closure, which is the shape that could in principle make the operator run away.

`probeGapBody g` is the raw implication whose negation is exactly the `priorUGap` trigger
`U(⊤, g) ∧ F(¬g)`. So `F (probeGapBody g)` carries no trigger at all in its subformulas, but
`priorUZ` emits `U(probeGapBody g, ¬probeGapBody g)`, and that emission's second component *is*
the trigger — one round late. Nesting `probeGapBody` inside itself stacks the construction, and
putting a `□` on top routes it through `allFuture` (whose `U(_, ⊤)` subformula is itself a
`priorUZ` trigger) as well.

The measured answer is the reason the confinement route below is worth pursuing: **the round count
stays at 4 no matter how deep the nesting goes**, while only `|C|` grows. Delaying a trigger does
not compound, because the delayed trigger's own emission introduces no further trigger.
-/

/-- The raw implication whose negation is the `priorUGap` trigger `U(⊤, g) ∧ F(¬g)`. -/
private def probeGapBody (g : Formula) : Formula :=
  Formula.imp (Formula.untl Formula.top g) (Formula.neg (Formula.someFuture g.neg))

-- `F(U(⊤,p) → ¬F(¬p))` — the trigger appears only after `priorUZ` fires.
/-- info: some (4, 22) -/
#guard_msgs in
#eval stabilisesAt (Formula.untl (probeGapBody (probeAtom "p")) Formula.top) 8

-- The same construction nested twice: still round 4.
/-- info: some (4, 33) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.untl (probeGapBody (probeGapBody (probeAtom "p"))) Formula.top) 8

-- Nested three deep: still round 4. Depth of delay does not compound.
/-- info: some (4, 44) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.untl (probeGapBody (probeGapBody (probeGapBody (probeAtom "p")))) Formula.top) 8

-- `□` routes the same delayed trigger through `allFuture`.
/-- info: some (4, 28) -/
#guard_msgs in
#eval stabilisesAt (Formula.box (probeGapBody (probeAtom "p"))) 8

-- `□` on top of the doubly-nested delay.
/-- info: some (4, 42) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.box (Formula.untl (probeGapBody (probeGapBody (probeAtom "p"))) Formula.top)) 8

-- The degenerate `g = ⊤` gap, where the emission `U(X, ⊤)` is itself a `priorUZ` trigger.
/-- info: some (3, 19) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.and (Formula.untl Formula.top Formula.top)
    (Formula.someFuture Formula.top.neg)) 8

end Probes

/-! ## 4.2d — the closure operator terminates, given a bound

The outstanding piece of T2 is `∃ n, closureStep (closureIter n seed) ⊆ closureIter n seed` in
general. It has two halves, and they are of very different difficulty:

1. **stabilisation** — a `⊆`-increasing chain of `Finset`s confined to a fixed finite set has to
   stop growing, and where it stops is a fixed point of `closureStep`;
2. **confinement** — exhibiting a finite `M` with `closureStep M ⊆ M`.

Half 1 is discharged here, unconditionally. It reduces the whole obligation to half 2: *any*
finite emission-closed superset of the seed, however crude, yields the fixed point, and the
iteration then finds one **at or below** it — which is what makes the reduction worth having
rather than circular. (`closureStep M ⊆ M` would already give `TableauClosed M` directly via
`tableauClosed_of_closureStep_subset`; the point of iterating from the seed is that
`closureIter n seed` is the *smaller* stock, and it is `|C|` that T2's `2 ^ (2 * |C|)` is
exponential in.)

Half 2 is where the real work is, and the shape is known: the only chains that could diverge are
`priorU`/`priorS` re-firing through a `someFuture` subformula of their own conclusion
(`conjEmissions`' first two arms), and there the recursion descends. It remains outstanding, and
as before it is carried as a hypothesis, never a `sorry`.
-/

/-- `closureIter` applies its step on the outside as well as the inside. Needed because the
recursion is stated with `closureStep` under the recursive call, while the chain argument wants it
on top. -/
theorem closureIter_succ (n : Nat) (C : Finset Formula) :
    closureIter (n + 1) C = closureStep (closureIter n C) := by
  induction n generalizing C with
  | zero => rfl
  | succ m ih => simpa [closureIter] using ih (closureStep C)

/-- The chain is `⊆`-increasing. -/
theorem closureIter_subset_succ (n : Nat) (C : Finset Formula) :
    closureIter n C ⊆ closureIter (n + 1) C := by
  rw [closureIter_succ]
  exact subset_closureStep _

/-- Every iterate stays inside any emission-closed superset of the seed. -/
theorem closureIter_subset_of_closed {seed M : Finset Formula}
    (hseed : seed ⊆ M) (hM : closureStep M ⊆ M) (n : Nat) : closureIter n seed ⊆ M := by
  induction n with
  | zero => exact hseed
  | succ m ih =>
      rw [closureIter_succ]
      refine subset_trans ?_ hM
      intro φ hφ
      simp only [closureStep, Finset.mem_union, Finset.mem_biUnion] at hφ ⊢
      rcases hφ with (h | ⟨ψ, hψ, hem⟩) | h
      · exact Or.inl (Or.inl (ih h))
      · exact Or.inl (Or.inr ⟨ψ, ih hψ, hem⟩)
      · exact Or.inr h

/--
**4.2d, reduced to a bound.** Given *any* finite emission-closed superset of the seed, the
closure iteration reaches a fixed point — so `TableauClosed` is available at the iterate, by
`tableauClosed_of_closureStep_subset`, with no further case analysis.

The argument is the finite-monotone one: cardinalities are non-decreasing along the chain and
capped by `|M|`, so a strict increase cannot persist for `|M| + 1` rounds; at the first round
where the cardinality repeats, `Finset.eq_of_subset_of_card_le` upgrades the inclusion to an
equality, and that equality *is* the fixed point.
-/
theorem exists_closureStep_subset {seed M : Finset Formula}
    (hseed : seed ⊆ M) (hM : closureStep M ⊆ M) :
    ∃ n, closureStep (closureIter n seed) ⊆ closureIter n seed := by
  by_contra hcon
  simp only [not_exists] at hcon
  -- No fixed point means the cardinality strictly increases at every round.
  have hstrict : ∀ n, (closureIter n seed).card < (closureIter (n + 1) seed).card := by
    intro n
    rcases lt_or_eq_of_le (Finset.card_le_card (closureIter_subset_succ n seed)) with h | h
    · exact h
    · exact absurd (by
        rw [← closureIter_succ]
        exact (Finset.eq_of_subset_of_card_le (closureIter_subset_succ n seed) h.ge).ge)
        (hcon n)
  -- Hence it exceeds any bound, contradicting confinement to `M`.
  have hgrow : ∀ n, n ≤ (closureIter n seed).card := by
    intro n
    induction n with
    | zero => exact Nat.zero_le _
    | succ m ih => exact Nat.lt_of_le_of_lt ih (hstrict m)
  have hbound : (closureIter (M.card + 1) seed).card ≤ M.card :=
    Finset.card_le_card (closureIter_subset_of_closed hseed hM _)
  exact absurd (hgrow (M.card + 1)) (by omega)

/-- The packaged form: a bound yields `TableauClosed` at a stock the iteration computes. -/
theorem exists_tableauClosed_closureIter {seed M : Finset Formula}
    (hseed : seed ⊆ M) (hM : closureStep M ⊆ M) :
    ∃ n, TableauClosed (closureIter n seed) := by
  obtain ⟨n, hn⟩ := exists_closureStep_subset hseed hM
  exact ⟨n, tableauClosed_of_closureStep_subset hn⟩

/-! ### Confinement: the surviving half, and its algebra

`exists_tableauClosed_closureIter` reduces everything to *confinement*: exhibit a finite
`M ⊇ seed` with `closureStep M ⊆ M`. This section develops that obligation rather than assuming
it, in three moves.

1. **Confinement is an algebra.** `Confining` sets are closed under union
   (`Confining.union`), because `closureStep` distributes over union (`closureStep_union`).
   That is the structural fact that makes the obligation decomposable at all: a confining stock
   can be *assembled* out of independently-confining pieces instead of being verified in one
   go. `Confining.extendEmissions` is the working form — bolt a batch `A` onto a confining `B`,
   checking only `A`'s own emissions.
2. **Confinement reduces to single formulas.** `exists_confining_of_forall` turns the
   seed-level obligation into a formula-level one (`ConfinesFormula`), by induction on the seed
   with `constCore` as the base. This is the reduction that makes the remaining work a
   structural induction on *one* formula rather than a statement about arbitrary finite sets.
3. **Confinement is computable for any concrete seed.** `stableAt` searches for the first stable
   iterate and `exists_confining_of_stableAt` converts a successful search into the confining
   stock. So no consumer with a concrete input is blocked: the hypothesis discharges by
   computation, and the `#guard_msgs` rows above are exactly that computation being run.

What is still open is the *uniform* statement `∀ φ, ConfinesFormula φ`. The probe rows say the
round count is 4 regardless of nesting depth, and the reason is structural: a delayed trigger's
emission introduces no further trigger. Turning that into a proof is a structural induction whose
cases are the six emission templates; the algebra in this section is what makes those cases
independent of one another.
-/

/-- A stock that one round of closure cannot leave. -/
def Confining (M : Finset Formula) : Prop := closureStep M ⊆ M

/-- `closureStep` distributes over union — the fact that makes confinement compositional. -/
theorem closureStep_union (A B : Finset Formula) :
    closureStep (A ∪ B) = closureStep A ∪ closureStep B := by
  ext φ
  simp only [closureStep, Finset.mem_union, Finset.mem_biUnion, Finset.mem_insert,
    Finset.mem_singleton]
  constructor
  · rintro ((h | ⟨ψ, hψ, hem⟩) | h)
    · exact h.imp (fun h => Or.inl (Or.inl h)) (fun h => Or.inl (Or.inl h))
    · rcases hψ with hψ | hψ
      · exact Or.inl (Or.inl (Or.inr ⟨ψ, hψ, hem⟩))
      · exact Or.inr (Or.inl (Or.inr ⟨ψ, hψ, hem⟩))
    · exact Or.inl (Or.inr h)
  · rintro (((h | ⟨ψ, hψ, hem⟩) | h) | ((h | ⟨ψ, hψ, hem⟩) | h))
    · exact Or.inl (Or.inl (Or.inl h))
    · exact Or.inl (Or.inr ⟨ψ, Or.inl hψ, hem⟩)
    · exact Or.inr h
    · exact Or.inl (Or.inl (Or.inr h))
    · exact Or.inl (Or.inr ⟨ψ, Or.inr hψ, hem⟩)
    · exact Or.inr h

/-- Confining stocks are closed under union. -/
theorem Confining.union {A B : Finset Formula} (hA : Confining A) (hB : Confining B) :
    Confining (A ∪ B) := by
  intro φ hφ
  rw [closureStep_union] at hφ
  rcases Finset.mem_union.mp hφ with h | h
  · exact Finset.mem_union_left _ (hA h)
  · exact Finset.mem_union_right _ (hB h)

/-- Grow a confining stock by a batch whose own closure round already lands inside the result. -/
theorem Confining.extend {A B : Finset Formula} (hB : Confining B)
    (hA : closureStep A ⊆ A ∪ B) : Confining (A ∪ B) := by
  intro φ hφ
  rw [closureStep_union] at hφ
  rcases Finset.mem_union.mp hφ with h | h
  · exact hA h
  · exact Finset.mem_union_right _ (hB h)

/-- The iteration is monotone in the round count. -/
theorem closureIter_subset_mono {m n : Nat} (h : m ≤ n) (C : Finset Formula) :
    closureIter m C ⊆ closureIter n C := by
  induction n with
  | zero => simp [Nat.le_zero.mp h]
  | succ k ih =>
      rcases Nat.lt_or_ge m (k + 1) with hlt | hge
      · exact subset_trans (ih (Nat.lt_succ_iff.mp hlt)) (closureIter_subset_succ k C)
      · simp [Nat.le_antisymm h hge]

/--
The constant core: the closure of the *empty* stock. Every confining stock contains it, because
`closureStep` adds the two seriality formulas unconditionally. It is the base case of the
seed induction, and it is confining by kernel computation — seven formulas, checked, not assumed.
-/
def constCore : Finset Formula := closureIter 3 (∅ : Finset Formula)

theorem confining_constCore : Confining constCore := by
  show closureStep constCore ⊆ constCore
  decide

/-- Search for the first stable iterate, up to `fuel` rounds. -/
def stableAt : Nat → Finset Formula → Option Nat
  | 0, _ => none
  | k + 1, C => if closureStep C ⊆ C then some 0 else (stableAt k (closureStep C)).map (· + 1)

/-- A successful search is a proof: the reported round is a fixed point of `closureStep`. -/
theorem closureStep_closureIter_of_stableAt :
    ∀ (fuel : Nat) (C : Finset Formula) (n : Nat), stableAt fuel C = some n →
      closureStep (closureIter n C) ⊆ closureIter n C := by
  intro fuel
  induction fuel with
  | zero => intro C n h; exact absurd h (by simp [stableAt])
  | succ k ih =>
      intro C n h
      rw [stableAt] at h
      by_cases hc : closureStep C ⊆ C
      · rw [if_pos hc] at h
        obtain rfl : n = 0 := by simpa using h.symm
        simpa [closureIter] using hc
      · rw [if_neg hc, Option.map_eq_some_iff] at h
        obtain ⟨m, hm, rfl⟩ := h
        exact ih (closureStep C) m hm

/-- **Confinement by computation.** Any concrete seed whose search succeeds gets its confining
stock, so the `exists_tableauClosed_closureIter` hypothesis is never a barrier in practice. -/
theorem exists_confining_of_stableAt {seed : Finset Formula} {fuel n : Nat}
    (h : stableAt fuel seed = some n) : ∃ M, seed ⊆ M ∧ Confining M :=
  ⟨closureIter n seed, by simpa [closureIter] using closureIter_subset_mono (Nat.zero_le n) seed,
    closureStep_closureIter_of_stableAt fuel seed n h⟩

/-- Every confining stock carries the future seriality formula. -/
theorem serialFuture_mem_of_confining {B : Finset Formula} (hB : Confining B) :
    Formula.top.someFuture ∈ B :=
  hB (Finset.mem_union_right _ (by simp))

/-- Every confining stock carries the past seriality formula. -/
theorem serialPast_mem_of_confining {B : Finset Formula} (hB : Confining B) :
    Formula.top.somePast ∈ B :=
  hB (Finset.mem_union_right _ (by simp))

/-- The working form of `Confining.extend`: only the batch's emissions need checking, since the
seriality pair is already in any confining `B`. -/
theorem Confining.extendEmissions {A B : Finset Formula} (hB : Confining B)
    (h : ∀ φ ∈ A, emissions φ ⊆ A ∪ B) : Confining (A ∪ B) := by
  refine hB.extend ?_
  intro φ hφ
  simp only [closureStep, Finset.mem_union, Finset.mem_biUnion] at hφ
  rcases hφ with (hφ | ⟨ψ, hψ, hem⟩) | hφ
  · exact Finset.mem_union_left _ hφ
  · exact h ψ hψ hem
  · refine Finset.mem_union_right _ ?_
    rcases Finset.mem_insert.mp hφ with rfl | hφ
    · exact serialFuture_mem_of_confining hB
    · rw [Finset.mem_singleton] at hφ
      subst hφ
      exact serialPast_mem_of_confining hB

/-- Confinement of a single formula: the unit the seed-level obligation decomposes into. -/
def ConfinesFormula (φ : Formula) : Prop := ∃ M, φ ∈ M ∧ Confining M

/-- **Confinement is compositional.** A finite seed is confined as soon as each of its formulas
is, because confining stocks are closed under union. This is what reduces the remaining T2
obligation from a statement about arbitrary finite sets to a structural induction on one
formula. -/
theorem exists_confining_of_forall :
    ∀ seed : Finset Formula, (∀ φ ∈ seed, ConfinesFormula φ) → ∃ M, seed ⊆ M ∧ Confining M := by
  classical
  intro seed
  induction seed using Finset.induction_on with
  | empty => exact fun _ => ⟨constCore, by simp, confining_constCore⟩
  | insert a s ha ih =>
      intro h
      obtain ⟨M₁, hM₁, hc₁⟩ := h a (Finset.mem_insert_self a s)
      obtain ⟨M₂, hM₂, hc₂⟩ := ih (fun φ hφ => h φ (Finset.mem_insert_of_mem hφ))
      refine ⟨M₁ ∪ M₂, ?_, hc₁.union hc₂⟩
      intro φ hφ
      rcases Finset.mem_insert.mp hφ with rfl | hφ
      · exact Finset.mem_union_left _ hM₁
      · exact Finset.mem_union_right _ (hM₂ hφ)

/-- Atoms emit only themselves. -/
theorem emissions_atom (a : Atom) : emissions (Formula.atom a) = {Formula.atom a} := by
  simp [emissions, subformulasFinset, Formula.subformulas, asAnd?]

/-- `⊥` emits only itself. -/
theorem emissions_bot : emissions Formula.bot = {Formula.bot} := by
  simp [emissions, subformulasFinset, Formula.subformulas, asAnd?]

/-! ### Structural bookkeeping for the confinement induction

`emissions` splits three ways, so the induction's cases need the three splits available as
equations rather than as folded `match`es. These are those equations, plus the monotonicity of
the operator and the fact that `constCore` sits inside every confining stock.
-/

theorem subformulasFinset_atom (a : Atom) :
    subformulasFinset (Formula.atom a) = {Formula.atom a} := by
  simp [subformulasFinset, Formula.subformulas]

theorem subformulasFinset_bot : subformulasFinset Formula.bot = {Formula.bot} := by
  simp [subformulasFinset, Formula.subformulas]

theorem subformulasFinset_box (ψ : Formula) :
    subformulasFinset (Formula.box ψ) = insert (Formula.box ψ) (subformulasFinset ψ) := by
  simp [subformulasFinset, Formula.subformulas]

theorem subformulasFinset_imp (ψ χ : Formula) :
    subformulasFinset (Formula.imp ψ χ)
      = insert (Formula.imp ψ χ) (subformulasFinset ψ ∪ subformulasFinset χ) := by
  simp [subformulasFinset, Formula.subformulas]

theorem subformulasFinset_untl (ψ χ : Formula) :
    subformulasFinset (Formula.untl ψ χ)
      = insert (Formula.untl ψ χ) (subformulasFinset ψ ∪ subformulasFinset χ) := by
  simp [subformulasFinset, Formula.subformulas]

theorem subformulasFinset_snce (ψ χ : Formula) :
    subformulasFinset (Formula.snce ψ χ)
      = insert (Formula.snce ψ χ) (subformulasFinset ψ ∪ subformulasFinset χ) := by
  simp [subformulasFinset, Formula.subformulas]

theorem closureStep_mono {A B : Finset Formula} (h : A ⊆ B) : closureStep A ⊆ closureStep B := by
  intro φ hφ
  simp only [closureStep, Finset.mem_union, Finset.mem_biUnion] at hφ ⊢
  rcases hφ with (hφ | ⟨ψ, hψ, hem⟩) | hφ
  · exact Or.inl (Or.inl (h hφ))
  · exact Or.inl (Or.inr ⟨ψ, h hψ, hem⟩)
  · exact Or.inr hφ

theorem closureIter_mono {A B : Finset Formula} (h : A ⊆ B) (n : Nat) :
    closureIter n A ⊆ closureIter n B := by
  induction n generalizing A B with
  | zero => exact h
  | succ k ih => exact ih (closureStep_mono h)

/-- Every confining stock contains the constant core. -/
theorem constCore_subset_of_confining {B : Finset Formula} (hB : Confining B) : constCore ⊆ B :=
  subset_trans (closureIter_mono (Finset.empty_subset B) 3)
    (closureIter_subset_of_closed (Finset.Subset.refl B) hB 3)

theorem bot_mem_of_confining {B : Finset Formula} (hB : Confining B) : Formula.bot ∈ B :=
  constCore_subset_of_confining hB (by decide)

theorem top_mem_of_confining {B : Finset Formula} (hB : Confining B) : Formula.top ∈ B :=
  constCore_subset_of_confining hB (by decide)

/-- `M` carries every subformula of `φ` together with each subformula's negation.

The negations are carried because they are *needed*: `□ψ` emits `Gψ = ¬F(¬ψ)`, whose own
`priorUZ` trigger `U(¬ψ, ⊤)` mentions `¬ψ`, which is not a subformula of `□ψ`. Strengthening the
induction to carry negations is what keeps that case from needing a second induction. -/
def Carries (M : Finset Formula) (φ : Formula) : Prop :=
  ∀ ζ ∈ subformulasFinset φ, ζ ∈ M ∧ ζ.neg ∈ M

/-- The single-formula confinement obligation, in the form the induction proves. -/
def SubConfining (φ : Formula) : Prop := ∃ M, Confining M ∧ Carries M φ

theorem confinesFormula_of_subConfining {φ : Formula} (h : SubConfining φ) :
    ConfinesFormula φ := by
  obtain ⟨M, hM, hc⟩ := h
  exact ⟨M, (hc φ (by simp [subformulasFinset, Formula.self_mem_subformulas])).1, hM⟩

theorem subConfining_bot : SubConfining Formula.bot := by
  refine ⟨constCore, confining_constCore, ?_⟩
  intro ζ hζ
  rw [subformulasFinset_bot, Finset.mem_singleton] at hζ
  subst hζ
  exact ⟨by decide, by decide⟩

theorem subConfining_atom (a : Atom) : SubConfining (Formula.atom a) := by
  refine ⟨{Formula.atom a, (Formula.atom a).neg} ∪ constCore,
    confining_constCore.extendEmissions ?_, ?_⟩
  · intro θ hθ
    simp only [Finset.mem_insert, Finset.mem_singleton] at hθ
    rcases hθ with rfl | rfl
    · rw [emissions_atom]
      intro x hx
      rw [Finset.mem_singleton] at hx
      subst hx
      simp
    · intro x hx
      simp only [emissions, Formula.neg, subformulasFinset_imp, subformulasFinset_atom,
        subformulasFinset_bot, asAnd?, Finset.union_empty, Finset.mem_insert,
        Finset.mem_union, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl | rfl
      · simp [Formula.neg]
      · simp
      · exact Finset.mem_union_right _ (by decide)
  · intro ζ hζ
    rw [subformulasFinset_atom, Finset.mem_singleton] at hζ
    subst hζ
    exact ⟨by simp, by simp⟩

theorem self_mem_subformulasFinset (φ : Formula) : φ ∈ subformulasFinset φ := by
  simp [subformulasFinset, Formula.self_mem_subformulas]

theorem subformulasFinset_top :
    subformulasFinset Formula.top = insert Formula.top ({Formula.bot} : Finset Formula) := by
  simp [Formula.top, subformulasFinset_imp, subformulasFinset_bot]

theorem subformulasFinset_neg (φ : Formula) :
    subformulasFinset φ.neg
      = insert φ.neg (subformulasFinset φ ∪ ({Formula.bot} : Finset Formula)) := by
  simp [Formula.neg, subformulasFinset_imp, subformulasFinset_bot]

theorem emissions_box (ψ : Formula) :
    emissions (Formula.box ψ)
      = insert (Formula.box ψ) (subformulasFinset ψ) ∪ {ψ.allFuture, ψ.allPast} := by
  simp [emissions, subformulasFinset_box, asAnd?]

theorem emissions_imp_of_asAnd_eq_none {ψ χ : Formula} (h : asAnd? (Formula.imp ψ χ) = none) :
    emissions (Formula.imp ψ χ)
      = insert (Formula.imp ψ χ) (subformulasFinset ψ ∪ subformulasFinset χ) := by
  simp [emissions, subformulasFinset_imp, h]

theorem emissions_untl_top (ψ : Formula) :
    emissions (Formula.untl ψ Formula.top)
      = insert (Formula.untl ψ Formula.top)
          (subformulasFinset ψ ∪ subformulasFinset Formula.top)
        ∪ {Formula.untl ψ ψ.neg} := by
  simp [emissions, subformulasFinset_untl, asAnd?]

theorem emissions_untl_of_ne {ψ χ : Formula} (h : χ ≠ Formula.top) :
    emissions (Formula.untl ψ χ)
      = insert (Formula.untl ψ χ) (subformulasFinset ψ ∪ subformulasFinset χ) := by
  simp [emissions, subformulasFinset_untl, asAnd?, h]

theorem emissions_snce_top (ψ : Formula) :
    emissions (Formula.snce ψ Formula.top)
      = insert (Formula.snce ψ Formula.top)
          (subformulasFinset ψ ∪ subformulasFinset Formula.top)
        ∪ {Formula.snce ψ ψ.neg} := by
  simp [emissions, subformulasFinset_snce, asAnd?]

theorem emissions_snce_of_ne {ψ χ : Formula} (h : χ ≠ Formula.top) :
    emissions (Formula.snce ψ χ)
      = insert (Formula.snce ψ χ) (subformulasFinset ψ ∪ subformulasFinset χ) := by
  simp [emissions, subformulasFinset_snce, asAnd?, h]

/--
The `□` case. `□ψ` emits `Gψ = ¬F(¬ψ)` and `Hψ`, and `Gψ` carries `U(¬ψ, ⊤)` as a subformula,
which is itself a `priorUZ` trigger emitting `U(¬ψ, ¬¬ψ)`. The batch is therefore nine formulas
wide, and it closes: `¬¬ψ` is never a conjunction (`asAnd?` would need `¬ψ`'s consequent to be a
negation, and it is `⊥`), and `U(¬ψ, ¬¬ψ)` is not a `priorUZ` trigger because `¬¬ψ ≠ ⊤`.
-/
theorem subConfining_box {ψ : Formula} (h : SubConfining ψ) : SubConfining (Formula.box ψ) := by
  classical
  obtain ⟨B, hB, hc⟩ := h
  have hself := hc ψ (self_mem_subformulasFinset ψ)
  have hsub : subformulasFinset ψ ⊆ B := fun ζ hζ => (hc ζ hζ).1
  have hbot : Formula.bot ∈ B := bot_mem_of_confining hB
  have htop : Formula.top ∈ B := top_mem_of_confining hB
  have hsubtop : subformulasFinset Formula.top ⊆ B := by
    rw [subformulasFinset_top]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl
    · exact htop
    · exact hbot
  have hsubneg : subformulasFinset ψ.neg ⊆ B := by
    rw [subformulasFinset_neg]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · exact hself.2
    · exact hsub hx
    · exact hbot
  have hnn : ψ.neg.neg ≠ Formula.top := by simp [Formula.neg, Formula.top]
  have hsubnn : ∀ x ∈ subformulasFinset ψ.neg.neg, x = ψ.neg.neg ∨ x ∈ B := by
    intro x hx
    rw [subformulasFinset_neg (φ := ψ.neg)] at hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · exact Or.inl rfl
    · exact Or.inr (hsubneg hx)
    · exact Or.inr hbot
  have hand₁ : asAnd? (Formula.imp (Formula.box ψ) Formula.bot) = none := rfl
  have hand₂ : asAnd? (Formula.imp (Formula.untl ψ.neg Formula.top) Formula.bot) = none := rfl
  have hand₃ : asAnd? (Formula.imp (Formula.snce ψ.neg Formula.top) Formula.bot) = none := rfl
  have hand₄ : asAnd? (Formula.imp ψ.neg Formula.bot) = none := rfl
  refine ⟨({Formula.box ψ, (Formula.box ψ).neg, ψ.allFuture, ψ.allPast,
      Formula.untl ψ.neg Formula.top, Formula.snce ψ.neg Formula.top,
      Formula.untl ψ.neg ψ.neg.neg, Formula.snce ψ.neg ψ.neg.neg,
      ψ.neg.neg} : Finset Formula) ∪ B, hB.extendEmissions ?_, ?_⟩
  · intro θ hθ
    simp only [Finset.mem_insert, Finset.mem_singleton] at hθ
    rcases hθ with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · rw [emissions_box]
      intro x hx
      simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with (rfl | hx) | rfl | rfl
      · simp
      · exact Finset.mem_union_right _ (hsub hx)
      · simp
      · simp
    · rw [Formula.neg, emissions_imp_of_asAnd_eq_none hand₁, subformulasFinset_box,
        subformulasFinset_bot]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
      rcases hx with rfl | (rfl | hx) | rfl
      · simp [Formula.neg]
      · simp
      · exact Finset.mem_union_right _ (hsub hx)
      · exact Finset.mem_union_right _ hbot
    · rw [Formula.allFuture, Formula.someFuture, Formula.neg,
        emissions_imp_of_asAnd_eq_none hand₂, subformulasFinset_untl, subformulasFinset_bot]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
      rcases hx with rfl | (rfl | hx | hx) | rfl
      · simp [Formula.neg]
      · simp
      · exact Finset.mem_union_right _ (hsubneg hx)
      · exact Finset.mem_union_right _ (hsubtop hx)
      · exact Finset.mem_union_right _ hbot
    · rw [Formula.allPast, Formula.somePast, Formula.neg,
        emissions_imp_of_asAnd_eq_none hand₃, subformulasFinset_snce, subformulasFinset_bot]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
      rcases hx with rfl | (rfl | hx | hx) | rfl
      · simp [Formula.neg]
      · simp
      · exact Finset.mem_union_right _ (hsubneg hx)
      · exact Finset.mem_union_right _ (hsubtop hx)
      · exact Finset.mem_union_right _ hbot
    · rw [emissions_untl_top]
      intro x hx
      simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with (rfl | hx | hx) | rfl
      · simp
      · exact Finset.mem_union_right _ (hsubneg hx)
      · exact Finset.mem_union_right _ (hsubtop hx)
      · simp
    · rw [emissions_snce_top]
      intro x hx
      simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with (rfl | hx | hx) | rfl
      · simp
      · exact Finset.mem_union_right _ (hsubneg hx)
      · exact Finset.mem_union_right _ (hsubtop hx)
      · simp
    · rw [emissions_untl_of_ne hnn]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union] at hx
      rcases hx with rfl | hx | hx
      · simp
      · exact Finset.mem_union_right _ (hsubneg hx)
      · rcases hsubnn x hx with rfl | hx'
        · simp
        · exact Finset.mem_union_right _ hx'
    · rw [emissions_snce_of_ne hnn]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union] at hx
      rcases hx with rfl | hx | hx
      · simp
      · exact Finset.mem_union_right _ (hsubneg hx)
      · rcases hsubnn x hx with rfl | hx'
        · simp
        · exact Finset.mem_union_right _ hx'
    · rw [Formula.neg, emissions_imp_of_asAnd_eq_none hand₄, subformulasFinset_bot]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
      rcases hx with rfl | hx | rfl
      · simp [Formula.neg]
      · exact Finset.mem_union_right _ (hsubneg hx)
      · exact Finset.mem_union_right _ hbot
  · intro ζ hζ
    rw [subformulasFinset_box] at hζ
    rcases Finset.mem_insert.mp hζ with rfl | hζ
    · exact ⟨by simp, by simp⟩
    · exact ⟨Finset.mem_union_right _ (hc ζ hζ).1, Finset.mem_union_right _ (hc ζ hζ).2⟩

theorem Carries.mono {M M' : Finset Formula} {φ : Formula} (h : Carries M φ) (hs : M ⊆ M') :
    Carries M' φ := fun ζ hζ => ⟨hs (h ζ hζ).1, hs (h ζ hζ).2⟩

theorem subformulasFinset_subset_of_mem {ζ φ : Formula} (h : ζ ∈ subformulasFinset φ) :
    subformulasFinset ζ ⊆ subformulasFinset φ := by
  intro x hx
  rw [subformulasFinset, List.mem_toFinset] at hx h ⊢
  exact Formula.subformulas_trans hx h

theorem Carries.sub {M : Finset Formula} {φ ζ : Formula} (h : Carries M φ)
    (hζ : ζ ∈ subformulasFinset φ) : Carries M ζ :=
  fun x hx => h x (subformulasFinset_subset_of_mem hζ hx)

/-- The `⊤`/`⊥` members and the subformula/negation stock any confining carrier supplies. -/
theorem Carries.subformulas_subset {M : Finset Formula} {φ : Formula} (h : Carries M φ) :
    subformulasFinset φ ⊆ M := fun ζ hζ => (h ζ hζ).1

theorem subformulasFinset_neg_subset {M : Finset Formula} {φ : Formula} (h : Carries M φ)
    (hbot : Formula.bot ∈ M) : subformulasFinset φ.neg ⊆ M := by
  rw [subformulasFinset_neg]
  intro x hx
  simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
  rcases hx with rfl | hx | rfl
  · exact (h φ (self_mem_subformulasFinset φ)).2
  · exact (h x hx).1
  · exact hbot

theorem subformulasFinset_top_subset {M : Finset Formula} (hM : Confining M) :
    subformulasFinset Formula.top ⊆ M := by
  rw [subformulasFinset_top]
  intro x hx
  simp only [Finset.mem_insert, Finset.mem_singleton] at hx
  rcases hx with rfl | rfl
  · exact top_mem_of_confining hM
  · exact bot_mem_of_confining hM

/--
The `U` case. `U(ψ, χ)` emits the `priorUZ` conclusion `U(ψ, ¬ψ)` exactly when `χ = ⊤`, and that
conclusion is closed: its own `priorUZ` guard asks for `¬ψ = ⊤`, in which case the conclusion is
the formula itself. Neither `U(ψ, χ)` nor its negation is a conjunction, so no Dedekind arm fires.
-/
theorem subConfining_untl {ψ χ : Formula} (hψ : SubConfining ψ) (hχ : SubConfining χ) :
    SubConfining (Formula.untl ψ χ) := by
  classical
  obtain ⟨B₁, hB₁, hc₁⟩ := hψ
  obtain ⟨B₂, hB₂, hc₂⟩ := hχ
  have hB : Confining (B₁ ∪ B₂) := hB₁.union hB₂
  have hcψ : Carries (B₁ ∪ B₂) ψ := hc₁.mono Finset.subset_union_left
  have hcχ : Carries (B₁ ∪ B₂) χ := hc₂.mono Finset.subset_union_right
  have hbot := bot_mem_of_confining hB
  have hsubψ := hcψ.subformulas_subset
  have hsubχ := hcχ.subformulas_subset
  have hsubψn := subformulasFinset_neg_subset hcψ hbot
  have hsubtop := subformulasFinset_top_subset hB
  have hand : asAnd? (Formula.imp (Formula.untl ψ χ) Formula.bot) = none := rfl
  refine ⟨({Formula.untl ψ χ, (Formula.untl ψ χ).neg,
      Formula.untl ψ ψ.neg} : Finset Formula) ∪ (B₁ ∪ B₂), hB.extendEmissions ?_, ?_⟩
  · intro θ hθ
    simp only [Finset.mem_insert, Finset.mem_singleton] at hθ
    rcases hθ with rfl | rfl | rfl
    · by_cases h : χ = Formula.top
      · subst h
        rw [emissions_untl_top]
        intro x hx
        simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
        rcases hx with (rfl | hx | hx) | rfl
        · simp
        · exact Finset.mem_union_right _ (hsubψ hx)
        · exact Finset.mem_union_right _ (hsubtop hx)
        · simp
      · rw [emissions_untl_of_ne h]
        intro x hx
        simp only [Finset.mem_insert, Finset.mem_union] at hx
        rcases hx with rfl | hx | hx
        · simp
        · exact Finset.mem_union_right _ (hsubψ hx)
        · exact Finset.mem_union_right _ (hsubχ hx)
    · rw [Formula.neg, emissions_imp_of_asAnd_eq_none hand, subformulasFinset_untl,
        subformulasFinset_bot]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
      rcases hx with rfl | (rfl | hx | hx) | rfl
      · simp [Formula.neg]
      · simp
      · exact Finset.mem_union_right _ (hsubψ hx)
      · exact Finset.mem_union_right _ (hsubχ hx)
      · exact Finset.mem_union_right _ hbot
    · by_cases h : ψ.neg = Formula.top
      · rw [h, emissions_untl_top]
        intro x hx
        simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
        rcases hx with (rfl | hx | hx) | rfl
        · simp
        · exact Finset.mem_union_right _ (hsubψ hx)
        · exact Finset.mem_union_right _ (hsubtop hx)
        · simp [h]
      · rw [emissions_untl_of_ne h]
        intro x hx
        simp only [Finset.mem_insert, Finset.mem_union] at hx
        rcases hx with rfl | hx | hx
        · simp
        · exact Finset.mem_union_right _ (hsubψ hx)
        · exact Finset.mem_union_right _ (hsubψn hx)
  · intro ζ hζ
    rw [subformulasFinset_untl] at hζ
    simp only [Finset.mem_insert, Finset.mem_union] at hζ
    rcases hζ with rfl | hζ | hζ
    · exact ⟨by simp, by simp⟩
    · exact ⟨Finset.mem_union_right _ (hcψ ζ hζ).1, Finset.mem_union_right _ (hcψ ζ hζ).2⟩
    · exact ⟨Finset.mem_union_right _ (hcχ ζ hζ).1, Finset.mem_union_right _ (hcχ ζ hζ).2⟩

/-- The `S` case, dual to `subConfining_untl`. -/
theorem subConfining_snce {ψ χ : Formula} (hψ : SubConfining ψ) (hχ : SubConfining χ) :
    SubConfining (Formula.snce ψ χ) := by
  classical
  obtain ⟨B₁, hB₁, hc₁⟩ := hψ
  obtain ⟨B₂, hB₂, hc₂⟩ := hχ
  have hB : Confining (B₁ ∪ B₂) := hB₁.union hB₂
  have hcψ : Carries (B₁ ∪ B₂) ψ := hc₁.mono Finset.subset_union_left
  have hcχ : Carries (B₁ ∪ B₂) χ := hc₂.mono Finset.subset_union_right
  have hbot := bot_mem_of_confining hB
  have hsubψ := hcψ.subformulas_subset
  have hsubχ := hcχ.subformulas_subset
  have hsubψn := subformulasFinset_neg_subset hcψ hbot
  have hsubtop := subformulasFinset_top_subset hB
  have hand : asAnd? (Formula.imp (Formula.snce ψ χ) Formula.bot) = none := rfl
  refine ⟨({Formula.snce ψ χ, (Formula.snce ψ χ).neg,
      Formula.snce ψ ψ.neg} : Finset Formula) ∪ (B₁ ∪ B₂), hB.extendEmissions ?_, ?_⟩
  · intro θ hθ
    simp only [Finset.mem_insert, Finset.mem_singleton] at hθ
    rcases hθ with rfl | rfl | rfl
    · by_cases h : χ = Formula.top
      · subst h
        rw [emissions_snce_top]
        intro x hx
        simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
        rcases hx with (rfl | hx | hx) | rfl
        · simp
        · exact Finset.mem_union_right _ (hsubψ hx)
        · exact Finset.mem_union_right _ (hsubtop hx)
        · simp
      · rw [emissions_snce_of_ne h]
        intro x hx
        simp only [Finset.mem_insert, Finset.mem_union] at hx
        rcases hx with rfl | hx | hx
        · simp
        · exact Finset.mem_union_right _ (hsubψ hx)
        · exact Finset.mem_union_right _ (hsubχ hx)
    · rw [Formula.neg, emissions_imp_of_asAnd_eq_none hand, subformulasFinset_snce,
        subformulasFinset_bot]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
      rcases hx with rfl | (rfl | hx | hx) | rfl
      · simp [Formula.neg]
      · simp
      · exact Finset.mem_union_right _ (hsubψ hx)
      · exact Finset.mem_union_right _ (hsubχ hx)
      · exact Finset.mem_union_right _ hbot
    · by_cases h : ψ.neg = Formula.top
      · rw [h, emissions_snce_top]
        intro x hx
        simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
        rcases hx with (rfl | hx | hx) | rfl
        · simp
        · exact Finset.mem_union_right _ (hsubψ hx)
        · exact Finset.mem_union_right _ (hsubtop hx)
        · simp [h]
      · rw [emissions_snce_of_ne h]
        intro x hx
        simp only [Finset.mem_insert, Finset.mem_union] at hx
        rcases hx with rfl | hx | hx
        · simp
        · exact Finset.mem_union_right _ (hsubψ hx)
        · exact Finset.mem_union_right _ (hsubψn hx)
  · intro ζ hζ
    rw [subformulasFinset_snce] at hζ
    simp only [Finset.mem_insert, Finset.mem_union] at hζ
    rcases hζ with rfl | hζ | hζ
    · exact ⟨by simp, by simp⟩
    · exact ⟨Finset.mem_union_right _ (hcψ ζ hζ).1, Finset.mem_union_right _ (hcψ ζ hζ).2⟩
    · exact ⟨Finset.mem_union_right _ (hcχ ζ hζ).1, Finset.mem_union_right _ (hcχ ζ hζ).2⟩

theorem emissions_imp_of_asAnd {ψ χ a b : Formula} (h : asAnd? (Formula.imp ψ χ) = some (a, b)) :
    emissions (Formula.imp ψ χ)
      = insert (Formula.imp ψ χ) (subformulasFinset ψ ∪ subformulasFinset χ)
        ∪ conjEmissions a b := by
  simp [emissions, subformulasFinset_imp, h]

theorem subformulasFinset_or (a b : Formula) :
    subformulasFinset (Formula.or a b)
      = insert (Formula.or a b) (subformulasFinset a.neg ∪ subformulasFinset b) := by
  rw [Formula.or, subformulasFinset_imp]

theorem subformulasFinset_kPlus (a : Formula) :
    subformulasFinset (Formula.kPlus a)
      = insert (Formula.kPlus a)
          (subformulasFinset (Formula.untl Formula.top a.neg) ∪ {Formula.bot}) := by
  rw [Formula.kPlus, subformulasFinset_neg]

theorem subformulasFinset_kMinus (a : Formula) :
    subformulasFinset (Formula.kMinus a)
      = insert (Formula.kMinus a)
          (subformulasFinset (Formula.snce Formula.top a.neg) ∪ {Formula.bot}) := by
  rw [Formula.kMinus, subformulasFinset_neg]

/--
**The `priorUGap` batch.** The conclusion `U(¬g ∨ K⁺¬g, g)` is the one emission strictly bigger
than its trigger, so it is where a runaway chain would have to start. It does not start: the six
formulas the conclusion drags in close under `emissions`.

Two syntactic facts do the work, both checked by `rfl` below. First, `¬(¬g ∨ K⁺¬g)` *is* a
conjunction — `asAnd?` reads it as `¬¬g ∧ U(⊤, ¬¬g)` — but no Dedekind arm fires on it, because
the left conjunct is an implication rather than a `U`, an `S`, or a raw `K⁺`. Second,
`¬¬g ≠ ⊤`, so `U(⊤, ¬¬g)` is not a `priorUZ` trigger. Together: the conclusion emits nothing new,
which is exactly what the `#guard_msgs` cascade rows measure.
-/
theorem exists_confining_gapU {g : Formula} {B : Finset Formula} (hB : Confining B)
    (hcg : Carries B g) (hcgn : Carries B g.neg) :
    ∃ M, Confining M ∧ B ⊆ M ∧
      Formula.untl (Formula.or g.neg (Formula.kPlus g.neg)) g ∈ M := by
  classical
  have hbot := bot_mem_of_confining hB
  have hsubg := hcg.subformulas_subset
  have hsubnn : subformulasFinset g.neg.neg ⊆ B := subformulasFinset_neg_subset hcgn hbot
  have hsubtop := subformulasFinset_top_subset hB
  have hnn : g.neg.neg ≠ Formula.top := by simp [Formula.neg, Formula.top]
  have hYne : (Formula.or g.neg (Formula.kPlus g.neg)).neg ≠ Formula.top := by
    simp [Formula.neg, Formula.top, Formula.or]
  -- the three `emissions` splits, folded through definitional equality
  have eX : emissions (Formula.or g.neg (Formula.kPlus g.neg))
      = insert (Formula.or g.neg (Formula.kPlus g.neg))
          (subformulasFinset g.neg.neg ∪ subformulasFinset (Formula.kPlus g.neg)) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eK : emissions (Formula.kPlus g.neg)
      = insert (Formula.kPlus g.neg)
          (subformulasFinset (Formula.untl Formula.top g.neg.neg)
            ∪ subformulasFinset Formula.bot) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eY : emissions (Formula.or g.neg (Formula.kPlus g.neg)).neg
      = insert (Formula.or g.neg (Formula.kPlus g.neg)).neg
          (subformulasFinset (Formula.or g.neg (Formula.kPlus g.neg))
            ∪ subformulasFinset Formula.bot)
        ∪ conjEmissions g.neg.neg (Formula.untl Formula.top g.neg.neg) :=
    emissions_imp_of_asAnd rfl
  have hconj : conjEmissions g.neg.neg (Formula.untl Formula.top g.neg.neg) = ∅ := rfl
  have sX : subformulasFinset (Formula.or g.neg (Formula.kPlus g.neg))
      = insert (Formula.or g.neg (Formula.kPlus g.neg))
          (subformulasFinset g.neg.neg ∪ subformulasFinset (Formula.kPlus g.neg)) :=
    subformulasFinset_imp _ _
  have sK : subformulasFinset (Formula.kPlus g.neg)
      = insert (Formula.kPlus g.neg)
          (subformulasFinset (Formula.untl Formula.top g.neg.neg)
            ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  have sY : subformulasFinset (Formula.or g.neg (Formula.kPlus g.neg)).neg
      = insert (Formula.or g.neg (Formula.kPlus g.neg)).neg
          (subformulasFinset (Formula.or g.neg (Formula.kPlus g.neg))
            ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  set A : Finset Formula :=
    {Formula.untl (Formula.or g.neg (Formula.kPlus g.neg)) g,
      Formula.or g.neg (Formula.kPlus g.neg),
      Formula.kPlus g.neg,
      Formula.untl Formula.top g.neg.neg,
      (Formula.or g.neg (Formula.kPlus g.neg)).neg,
      Formula.untl (Formula.or g.neg (Formula.kPlus g.neg))
        (Formula.or g.neg (Formula.kPlus g.neg)).neg} with hAdef
  have hsubK : subformulasFinset (Formula.kPlus g.neg) ⊆ A ∪ B := by
    rw [sK, subformulasFinset_untl, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubnn hx)
    · exact Finset.mem_union_right _ hbot
  have hsubXm : subformulasFinset (Formula.or g.neg (Formula.kPlus g.neg)) ⊆ A ∪ B := by
    rw [sX]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubnn hx)
    · exact hsubK hx
  have hsubYm : subformulasFinset (Formula.or g.neg (Formula.kPlus g.neg)).neg ⊆ A ∪ B := by
    rw [sY, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubXm hx
    · exact Finset.mem_union_right _ hbot
  refine ⟨A ∪ B, hB.extendEmissions ?_, Finset.subset_union_right, by simp [hAdef]⟩
  intro θ hθ
  rw [hAdef] at hθ
  simp only [Finset.mem_insert, Finset.mem_singleton] at hθ
  rcases hθ with rfl | rfl | rfl | rfl | rfl | rfl
  · by_cases h : g = Formula.top
    · subst h
      rw [emissions_untl_top]
      intro x hx
      simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with (rfl | hx | hx) | rfl
      · simp [hAdef]
      · exact hsubXm hx
      · exact Finset.mem_union_right _ (hsubtop hx)
      · simp [hAdef]
    · rw [emissions_untl_of_ne h]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union] at hx
      rcases hx with rfl | hx | hx
      · simp [hAdef]
      · exact hsubXm hx
      · exact Finset.mem_union_right _ (hsubg hx)
  · rw [eX]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubnn hx)
    · exact hsubK hx
  · rw [eK, subformulasFinset_untl, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubnn hx)
    · exact Finset.mem_union_right _ hbot
  · rw [emissions_untl_of_ne hnn]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubnn hx)
  · rw [eY, hconj, Finset.union_empty, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubXm hx
    · exact Finset.mem_union_right _ hbot
  · rw [emissions_untl_of_ne hYne]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact hsubXm hx
    · exact hsubYm hx

/--
**The `priorSGap` batch**, the past-directed mirror of `exists_confining_gapU`.
The conclusion `S(¬g ∨ K⁻¬g, g)` is the one emission strictly bigger
than its trigger, so it is where a runaway chain would have to start. It does not start: the six
formulas the conclusion drags in close under `emissions`.

Two syntactic facts do the work, both checked by `rfl` below. First, `¬(¬g ∨ K⁻¬g)` *is* a
conjunction — `asAnd?` reads it as `¬¬g ∧ S(⊤, ¬¬g)` — but no Dedekind arm fires on it, because
the left conjunct is an implication rather than a `U`, an `S`, or a raw `K⁻`. Second,
`¬¬g ≠ ⊤`, so `S(⊤, ¬¬g)` is not a `priorSZ` trigger. Together: the conclusion emits nothing new,
which is exactly what the `#guard_msgs` cascade rows measure.
-/
theorem exists_confining_gapS {g : Formula} {B : Finset Formula} (hB : Confining B)
    (hcg : Carries B g) (hcgn : Carries B g.neg) :
    ∃ M, Confining M ∧ B ⊆ M ∧
      Formula.snce (Formula.or g.neg (Formula.kMinus g.neg)) g ∈ M := by
  classical
  have hbot := bot_mem_of_confining hB
  have hsubg := hcg.subformulas_subset
  have hsubnn : subformulasFinset g.neg.neg ⊆ B := subformulasFinset_neg_subset hcgn hbot
  have hsubtop := subformulasFinset_top_subset hB
  have hnn : g.neg.neg ≠ Formula.top := by simp [Formula.neg, Formula.top]
  have hYne : (Formula.or g.neg (Formula.kMinus g.neg)).neg ≠ Formula.top := by
    simp [Formula.neg, Formula.top, Formula.or]
  -- the three `emissions` splits, folded through definitional equality
  have eX : emissions (Formula.or g.neg (Formula.kMinus g.neg))
      = insert (Formula.or g.neg (Formula.kMinus g.neg))
          (subformulasFinset g.neg.neg ∪ subformulasFinset (Formula.kMinus g.neg)) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eK : emissions (Formula.kMinus g.neg)
      = insert (Formula.kMinus g.neg)
          (subformulasFinset (Formula.snce Formula.top g.neg.neg)
            ∪ subformulasFinset Formula.bot) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eY : emissions (Formula.or g.neg (Formula.kMinus g.neg)).neg
      = insert (Formula.or g.neg (Formula.kMinus g.neg)).neg
          (subformulasFinset (Formula.or g.neg (Formula.kMinus g.neg))
            ∪ subformulasFinset Formula.bot)
        ∪ conjEmissions g.neg.neg (Formula.snce Formula.top g.neg.neg) :=
    emissions_imp_of_asAnd rfl
  have hconj : conjEmissions g.neg.neg (Formula.snce Formula.top g.neg.neg) = ∅ := rfl
  have sX : subformulasFinset (Formula.or g.neg (Formula.kMinus g.neg))
      = insert (Formula.or g.neg (Formula.kMinus g.neg))
          (subformulasFinset g.neg.neg ∪ subformulasFinset (Formula.kMinus g.neg)) :=
    subformulasFinset_imp _ _
  have sK : subformulasFinset (Formula.kMinus g.neg)
      = insert (Formula.kMinus g.neg)
          (subformulasFinset (Formula.snce Formula.top g.neg.neg)
            ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  have sY : subformulasFinset (Formula.or g.neg (Formula.kMinus g.neg)).neg
      = insert (Formula.or g.neg (Formula.kMinus g.neg)).neg
          (subformulasFinset (Formula.or g.neg (Formula.kMinus g.neg))
            ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  set A : Finset Formula :=
    {Formula.snce (Formula.or g.neg (Formula.kMinus g.neg)) g,
      Formula.or g.neg (Formula.kMinus g.neg),
      Formula.kMinus g.neg,
      Formula.snce Formula.top g.neg.neg,
      (Formula.or g.neg (Formula.kMinus g.neg)).neg,
      Formula.snce (Formula.or g.neg (Formula.kMinus g.neg))
        (Formula.or g.neg (Formula.kMinus g.neg)).neg} with hAdef
  have hsubK : subformulasFinset (Formula.kMinus g.neg) ⊆ A ∪ B := by
    rw [sK, subformulasFinset_snce, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubnn hx)
    · exact Finset.mem_union_right _ hbot
  have hsubXm : subformulasFinset (Formula.or g.neg (Formula.kMinus g.neg)) ⊆ A ∪ B := by
    rw [sX]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubnn hx)
    · exact hsubK hx
  have hsubYm : subformulasFinset (Formula.or g.neg (Formula.kMinus g.neg)).neg ⊆ A ∪ B := by
    rw [sY, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubXm hx
    · exact Finset.mem_union_right _ hbot
  refine ⟨A ∪ B, hB.extendEmissions ?_, Finset.subset_union_right, by simp [hAdef]⟩
  intro θ hθ
  rw [hAdef] at hθ
  simp only [Finset.mem_insert, Finset.mem_singleton] at hθ
  rcases hθ with rfl | rfl | rfl | rfl | rfl | rfl
  · by_cases h : g = Formula.top
    · subst h
      rw [emissions_snce_top]
      intro x hx
      simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with (rfl | hx | hx) | rfl
      · simp [hAdef]
      · exact hsubXm hx
      · exact Finset.mem_union_right _ (hsubtop hx)
      · simp [hAdef]
    · rw [emissions_snce_of_ne h]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union] at hx
      rcases hx with rfl | hx | hx
      · simp [hAdef]
      · exact hsubXm hx
      · exact Finset.mem_union_right _ (hsubg hx)
  · rw [eX]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubnn hx)
    · exact hsubK hx
  · rw [eK, subformulasFinset_snce, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubnn hx)
    · exact Finset.mem_union_right _ hbot
  · rw [emissions_snce_of_ne hnn]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubnn hx)
  · rw [eY, hconj, Finset.union_empty, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubXm hx
    · exact Finset.mem_union_right _ hbot
  · rw [emissions_snce_of_ne hYne]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact hsubXm hx
    · exact hsubYm hx

/--
**The `sepRule` batch.** The conclusion `K⁺(K⁺ψ ∧ K⁻ψ)` unfolds to ten formulas. The one that
could re-fire is the conjunction `K⁺ψ ∧ K⁻ψ` itself, which `asAnd?` does read as a conjunction
with a raw `K⁺` on the left — the exact shape `sepRule` keys on. It does not fire: the rule also
demands the right conjunct be `¬K⁺(ψ ∧ U(ψ, ¬ψ))`, and `K⁻ψ` is an `S`-formula under a negation,
not that. The `rfl` for `conjEmissions (K⁺ψ) (K⁻ψ) = ∅` below is that comparison, decided at the
outermost differing constructor.
-/
theorem exists_confining_sep {ψ₀ : Formula} {B : Finset Formula} (hB : Confining B)
    (hcψn : Carries B ψ₀.neg) :
    ∃ M, Confining M ∧ B ⊆ M ∧
      Formula.kPlus (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)) ∈ M := by
  classical
  have hbot := bot_mem_of_confining hB
  have hsubψn : subformulasFinset ψ₀.neg ⊆ B := hcψn.subformulas_subset
  have hsubtop := subformulasFinset_top_subset hB
  have hFtn : Formula.untl Formula.top Formula.top.neg ∈ B :=
    constCore_subset_of_confining hB (by decide)
  have hPtn : Formula.snce Formula.top Formula.top.neg ∈ B :=
    constCore_subset_of_confining hB (by decide)
  have hCne : (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg ≠ Formula.top := by
    simp [Formula.neg, Formula.top, Formula.and]
  have hconjPQ : conjEmissions (Formula.kPlus ψ₀) (Formula.kMinus ψ₀) = ∅ := rfl
  have eO : emissions (Formula.kPlus (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)))
      = insert (Formula.kPlus (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)))
          (subformulasFinset (Formula.untl Formula.top
              (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg)
            ∪ subformulasFinset Formula.bot) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eCn : emissions (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg
      = insert (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg
          (subformulasFinset (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀))
            ∪ subformulasFinset Formula.bot) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eC : emissions (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀))
      = insert (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀))
          (subformulasFinset (Formula.imp (Formula.kPlus ψ₀) (Formula.kMinus ψ₀).neg)
            ∪ subformulasFinset Formula.bot)
        ∪ conjEmissions (Formula.kPlus ψ₀) (Formula.kMinus ψ₀) :=
    emissions_imp_of_asAnd rfl
  have ePQ : emissions (Formula.imp (Formula.kPlus ψ₀) (Formula.kMinus ψ₀).neg)
      = insert (Formula.imp (Formula.kPlus ψ₀) (Formula.kMinus ψ₀).neg)
          (subformulasFinset (Formula.kPlus ψ₀) ∪ subformulasFinset (Formula.kMinus ψ₀).neg) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eP : emissions (Formula.kPlus ψ₀)
      = insert (Formula.kPlus ψ₀)
          (subformulasFinset (Formula.untl Formula.top ψ₀.neg) ∪ subformulasFinset Formula.bot) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eQ : emissions (Formula.kMinus ψ₀)
      = insert (Formula.kMinus ψ₀)
          (subformulasFinset (Formula.snce Formula.top ψ₀.neg) ∪ subformulasFinset Formula.bot) :=
    emissions_imp_of_asAnd_eq_none rfl
  have eQn : emissions (Formula.kMinus ψ₀).neg
      = insert (Formula.kMinus ψ₀).neg
          (subformulasFinset (Formula.kMinus ψ₀) ∪ subformulasFinset Formula.bot) :=
    emissions_imp_of_asAnd_eq_none rfl
  have sP : subformulasFinset (Formula.kPlus ψ₀)
      = insert (Formula.kPlus ψ₀)
          (subformulasFinset (Formula.untl Formula.top ψ₀.neg) ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  have sQ : subformulasFinset (Formula.kMinus ψ₀)
      = insert (Formula.kMinus ψ₀)
          (subformulasFinset (Formula.snce Formula.top ψ₀.neg) ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  have sQn : subformulasFinset (Formula.kMinus ψ₀).neg
      = insert (Formula.kMinus ψ₀).neg
          (subformulasFinset (Formula.kMinus ψ₀) ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  have sPQ : subformulasFinset (Formula.imp (Formula.kPlus ψ₀) (Formula.kMinus ψ₀).neg)
      = insert (Formula.imp (Formula.kPlus ψ₀) (Formula.kMinus ψ₀).neg)
          (subformulasFinset (Formula.kPlus ψ₀) ∪ subformulasFinset (Formula.kMinus ψ₀).neg) :=
    subformulasFinset_imp _ _
  have sC : subformulasFinset (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀))
      = insert (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀))
          (subformulasFinset (Formula.imp (Formula.kPlus ψ₀) (Formula.kMinus ψ₀).neg)
            ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  have sCn : subformulasFinset (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg
      = insert (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg
          (subformulasFinset (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀))
            ∪ subformulasFinset Formula.bot) :=
    subformulasFinset_imp _ _
  set A : Finset Formula :=
    {Formula.kPlus (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)),
      Formula.untl Formula.top (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg,
      (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg,
      Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀),
      Formula.imp (Formula.kPlus ψ₀) (Formula.kMinus ψ₀).neg,
      Formula.kPlus ψ₀, Formula.kMinus ψ₀, (Formula.kMinus ψ₀).neg,
      Formula.untl Formula.top ψ₀.neg, Formula.snce Formula.top ψ₀.neg} with hAdef
  have hsubP : subformulasFinset (Formula.kPlus ψ₀) ⊆ A ∪ B := by
    rw [sP, subformulasFinset_untl, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubψn hx)
    · exact Finset.mem_union_right _ hbot
  have hsubQ : subformulasFinset (Formula.kMinus ψ₀) ⊆ A ∪ B := by
    rw [sQ, subformulasFinset_snce, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubψn hx)
    · exact Finset.mem_union_right _ hbot
  have hsubQn : subformulasFinset (Formula.kMinus ψ₀).neg ⊆ A ∪ B := by
    rw [sQn, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubQ hx
    · exact Finset.mem_union_right _ hbot
  have hsubPQ : subformulasFinset (Formula.imp (Formula.kPlus ψ₀) (Formula.kMinus ψ₀).neg)
      ⊆ A ∪ B := by
    rw [sPQ]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact hsubP hx
    · exact hsubQn hx
  have hsubC : subformulasFinset (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀))
      ⊆ A ∪ B := by
    rw [sC, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubPQ hx
    · exact Finset.mem_union_right _ hbot
  have hsubCn : subformulasFinset (Formula.and (Formula.kPlus ψ₀) (Formula.kMinus ψ₀)).neg
      ⊆ A ∪ B := by
    rw [sCn, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubC hx
    · exact Finset.mem_union_right _ hbot
  refine ⟨A ∪ B, hB.extendEmissions ?_, Finset.subset_union_right, by simp [hAdef]⟩
  intro θ hθ
  rw [hAdef] at hθ
  simp only [Finset.mem_insert, Finset.mem_singleton] at hθ
  rcases hθ with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · rw [eO, subformulasFinset_untl, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact hsubCn hx
    · exact Finset.mem_union_right _ hbot
  · rw [emissions_untl_of_ne hCne]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact hsubCn hx
  · rw [eCn, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubC hx
    · exact Finset.mem_union_right _ hbot
  · rw [eC, hconjPQ, Finset.union_empty, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubPQ hx
    · exact Finset.mem_union_right _ hbot
  · rw [ePQ]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union] at hx
    rcases hx with rfl | hx | hx
    · simp [hAdef]
    · exact hsubP hx
    · exact hsubQn hx
  · rw [eP, subformulasFinset_untl, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubψn hx)
    · exact Finset.mem_union_right _ hbot
  · rw [eQ, subformulasFinset_snce, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | (rfl | hx | hx) | rfl
    · simp [hAdef]
    · simp [hAdef]
    · exact Finset.mem_union_right _ (hsubtop hx)
    · exact Finset.mem_union_right _ (hsubψn hx)
    · exact Finset.mem_union_right _ hbot
  · rw [eQn, subformulasFinset_bot]
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at hx
    rcases hx with rfl | hx | rfl
    · simp [hAdef]
    · exact hsubQ hx
    · exact Finset.mem_union_right _ hbot
  · by_cases h : ψ₀.neg = Formula.top
    · rw [h, emissions_untl_top]
      intro x hx
      simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with (rfl | hx | hx) | rfl
      · simp [hAdef, h]
      · exact Finset.mem_union_right _ (hsubtop hx)
      · exact Finset.mem_union_right _ (hsubtop hx)
      · exact Finset.mem_union_right _ hFtn
    · rw [emissions_untl_of_ne h]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union] at hx
      rcases hx with rfl | hx | hx
      · simp [hAdef]
      · exact Finset.mem_union_right _ (hsubtop hx)
      · exact Finset.mem_union_right _ (hsubψn hx)
  · by_cases h : ψ₀.neg = Formula.top
    · rw [h, emissions_snce_top]
      intro x hx
      simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with (rfl | hx | hx) | rfl
      · simp [hAdef, h]
      · exact Finset.mem_union_right _ (hsubtop hx)
      · exact Finset.mem_union_right _ (hsubtop hx)
      · exact Finset.mem_union_right _ hPtn
    · rw [emissions_snce_of_ne h]
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_union] at hx
      rcases hx with rfl | hx | hx
      · simp [hAdef]
      · exact Finset.mem_union_right _ (hsubtop hx)
      · exact Finset.mem_union_right _ (hsubψn hx)

/-- `emissions` of an implication, in the form the `→` case of the induction consumes: the
subformula part and the Dedekind part are checked separately. -/
theorem emissions_imp_subset {ψ χ : Formula} {M : Finset Formula}
    (hsub : insert (Formula.imp ψ χ) (subformulasFinset ψ ∪ subformulasFinset χ) ⊆ M)
    (hcon : ∀ a b, asAnd? (Formula.imp ψ χ) = some (a, b) → conjEmissions a b ⊆ M) :
    emissions (Formula.imp ψ χ) ⊆ M := by
  cases h : asAnd? (Formula.imp ψ χ) with
  | none => rw [emissions_imp_of_asAnd_eq_none h]; exact hsub
  | some p =>
      obtain ⟨a, b⟩ := p
      rw [emissions_imp_of_asAnd h]
      exact Finset.union_subset hsub (hcon a b h)

/--
**The Dedekind dispatcher.** `conjEmissions` fires on exactly three trigger shapes, and each has
its batch lemma above. Everything else is `∅`, decided by the outermost constructor — which is
why the twenty-odd `triv` lines below are all `rfl`.
-/
theorem exists_confining_conjEmissions {a b : Formula} {B : Finset Formula} (hB : Confining B)
    (hca : Carries B a) (hcb : Carries B b) :
    ∃ M, Confining M ∧ B ⊆ M ∧ conjEmissions a b ⊆ M := by
  classical
  have triv : ∀ c d : Formula, conjEmissions c d = ∅ →
      ∃ M, Confining M ∧ B ⊆ M ∧ conjEmissions c d ⊆ M :=
    fun c d h => ⟨B, hB, Finset.Subset.refl B, by rw [h]; exact Finset.empty_subset B⟩
  cases a with
  | atom c => exact triv _ _ rfl
  | bot => exact triv _ _ rfl
  | box p => exact triv _ _ rfl
  | untl e g =>
      by_cases h : e = Formula.top ∧ b = Formula.someFuture g.neg
      · obtain ⟨rfl, rfl⟩ := h
        have hcg : Carries B g :=
          hca.sub (by rw [subformulasFinset_untl]; simp [self_mem_subformulasFinset])
        have hcgn : Carries B g.neg :=
          hcb.sub (by
            rw [Formula.someFuture, subformulasFinset_untl]
            simp [self_mem_subformulasFinset])
        obtain ⟨M, hM, hs, hmem⟩ := exists_confining_gapU hB hcg hcgn
        exact ⟨M, hM, hs, by simp [conjEmissions, hmem]⟩
      · exact ⟨B, hB, Finset.Subset.refl B, by simp [conjEmissions, h]⟩
  | snce e g =>
      by_cases h : e = Formula.top ∧ b = Formula.somePast g.neg
      · obtain ⟨rfl, rfl⟩ := h
        have hcg : Carries B g :=
          hca.sub (by rw [subformulasFinset_snce]; simp [self_mem_subformulasFinset])
        have hcgn : Carries B g.neg :=
          hcb.sub (by
            rw [Formula.somePast, subformulasFinset_snce]
            simp [self_mem_subformulasFinset])
        obtain ⟨M, hM, hs, hmem⟩ := exists_confining_gapS hB hcg hcgn
        exact ⟨M, hM, hs, by simp [conjEmissions, hmem]⟩
      · exact ⟨B, hB, Finset.Subset.refl B, by simp [conjEmissions, h]⟩
  | imp p q =>
      cases p with
      | atom c => exact triv _ _ rfl
      | bot => exact triv _ _ rfl
      | imp r t => exact triv _ _ rfl
      | box r => exact triv _ _ rfl
      | snce e r => exact triv _ _ rfl
      | untl e r =>
          cases r with
          | atom c => exact triv _ _ rfl
          | bot => exact triv _ _ rfl
          | box t => exact triv _ _ rfl
          | untl t u => exact triv _ _ rfl
          | snce t u => exact triv _ _ rfl
          | imp ψ₀ w =>
              cases w with
              | atom c => exact triv _ _ rfl
              | imp t u => exact triv _ _ rfl
              | box t => exact triv _ _ rfl
              | untl t u => exact triv _ _ rfl
              | snce t u => exact triv _ _ rfl
              | bot =>
                  cases q with
                  | atom c => exact triv _ _ rfl
                  | imp t u => exact triv _ _ rfl
                  | box t => exact triv _ _ rfl
                  | untl t u => exact triv _ _ rfl
                  | snce t u => exact triv _ _ rfl
                  | bot =>
                      by_cases h : e = Formula.top ∧
                          b = Formula.neg (Formula.kPlus
                            (Formula.and ψ₀ (Formula.untl ψ₀ ψ₀.neg)))
                      · obtain ⟨rfl, rfl⟩ := h
                        have hcψn : Carries B ψ₀.neg :=
                          hca.sub (by
                            rw [subformulasFinset_imp, subformulasFinset_untl]
                            simp [Formula.neg, self_mem_subformulasFinset])
                        obtain ⟨M, hM, hs, hmem⟩ := exists_confining_sep hB hcψn
                        exact ⟨M, hM, hs, by simp [conjEmissions, hmem]⟩
                      · exact ⟨B, hB, Finset.Subset.refl B, by simp [conjEmissions, h]⟩

/--
The `→` case. Two conjunctions can appear: `ψ → χ` may itself be one (when `χ = ⊥`), and its
negation may be one (when `χ` is a negation). Both are absorbed by the dispatcher before the
formula and its negation are laid on top, and in both cases the Dedekind components are
subformulas of `ψ` or `χ`, so the induction hypotheses already carry them.
-/
theorem subConfining_imp {ψ χ : Formula} (hψ : SubConfining ψ) (hχ : SubConfining χ) :
    SubConfining (Formula.imp ψ χ) := by
  classical
  obtain ⟨B₁, hB₁, hc₁⟩ := hψ
  obtain ⟨B₂, hB₂, hc₂⟩ := hχ
  have hB0 : Confining (B₁ ∪ B₂) := hB₁.union hB₂
  have hcψ0 : Carries (B₁ ∪ B₂) ψ := hc₁.mono Finset.subset_union_left
  have hcχ0 : Carries (B₁ ∪ B₂) χ := hc₂.mono Finset.subset_union_right
  obtain ⟨B₃, hB₃, hs₃, hcon₃⟩ :
      ∃ M, Confining M ∧ (B₁ ∪ B₂) ⊆ M ∧
        ∀ a b, asAnd? (Formula.imp ψ χ) = some (a, b) → conjEmissions a b ⊆ M := by
    cases hsplit : asAnd? (Formula.imp ψ χ) with
    | none =>
        exact ⟨B₁ ∪ B₂, hB0, Finset.Subset.refl _, by intro a b hab; simp at hab⟩
    | some pr =>
        obtain ⟨a, b⟩ := pr
        have hshape := asAnd?_eq_iff.mp hsplit
        have hψeq : ψ = Formula.imp a (Formula.imp b Formula.bot) := by
          injection hshape with h1 _
        have hca : Carries (B₁ ∪ B₂) a :=
          hcψ0.sub (by rw [hψeq, subformulasFinset_imp]; simp [self_mem_subformulasFinset])
        have hcb : Carries (B₁ ∪ B₂) b :=
          hcψ0.sub (by
            rw [hψeq, subformulasFinset_imp, subformulasFinset_imp]
            simp [self_mem_subformulasFinset])
        obtain ⟨M, hM, hs, hmem⟩ := exists_confining_conjEmissions hB0 hca hcb
        refine ⟨M, hM, hs, ?_⟩
        intro a' b' hab
        simp only [Option.some.injEq, Prod.mk.injEq] at hab
        obtain ⟨rfl, rfl⟩ := hab
        exact hmem
  obtain ⟨B₄, hB₄, hs₄, hcon₄⟩ :
      ∃ M, Confining M ∧ B₃ ⊆ M ∧
        ∀ a b, asAnd? (Formula.imp (Formula.imp ψ χ) Formula.bot) = some (a, b) →
          conjEmissions a b ⊆ M := by
    cases hsplit : asAnd? (Formula.imp (Formula.imp ψ χ) Formula.bot) with
    | none =>
        exact ⟨B₃, hB₃, Finset.Subset.refl _, by intro a b hab; simp at hab⟩
    | some pr =>
        obtain ⟨a, b⟩ := pr
        have hshape := asAnd?_eq_iff.mp hsplit
        have h1 : Formula.imp ψ χ = Formula.imp a (Formula.imp b Formula.bot) := by
          injection hshape with h1 _
        have hψeq : ψ = a := by injection h1 with h2 _
        have hχeq : χ = Formula.imp b Formula.bot := by injection h1 with _ h3
        have hca : Carries B₃ a := (hcψ0.mono hs₃).sub (by rw [← hψeq]; exact self_mem_subformulasFinset ψ)
        have hcb : Carries B₃ b :=
          (hcχ0.mono hs₃).sub (by rw [hχeq, subformulasFinset_imp]; simp [self_mem_subformulasFinset])
        obtain ⟨M, hM, hs, hmem⟩ := exists_confining_conjEmissions hB₃ hca hcb
        refine ⟨M, hM, hs, ?_⟩
        intro a' b' hab
        simp only [Option.some.injEq, Prod.mk.injEq] at hab
        obtain ⟨rfl, rfl⟩ := hab
        exact hmem
  have hcψ : Carries B₄ ψ := (hcψ0.mono hs₃).mono hs₄
  have hcχ : Carries B₄ χ := (hcχ0.mono hs₃).mono hs₄
  have hbot : Formula.bot ∈ B₄ := bot_mem_of_confining hB₄
  set A : Finset Formula := {Formula.imp ψ χ, (Formula.imp ψ χ).neg} with hAdef
  refine ⟨A ∪ B₄, hB₄.extendEmissions ?_, ?_⟩
  · intro θ hθ
    rw [hAdef] at hθ
    simp only [Finset.mem_insert, Finset.mem_singleton] at hθ
    rcases hθ with rfl | rfl
    · refine emissions_imp_subset ?_ ?_
      · intro x hx
        simp only [Finset.mem_insert, Finset.mem_union] at hx
        rcases hx with rfl | hx | hx
        · simp [hAdef]
        · exact Finset.mem_union_right _ (hcψ.subformulas_subset hx)
        · exact Finset.mem_union_right _ (hcχ.subformulas_subset hx)
      · intro a b hab
        exact subset_trans (hcon₃ a b hab) (subset_trans hs₄ Finset.subset_union_right)
    · refine emissions_imp_subset (ψ := Formula.imp ψ χ) (χ := Formula.bot) ?_ ?_
      · intro x hx
        simp only [Finset.mem_insert, Finset.mem_union] at hx
        rcases hx with rfl | hx | hx
        · simp [hAdef, Formula.neg]
        · rw [subformulasFinset_imp] at hx
          simp only [Finset.mem_insert, Finset.mem_union] at hx
          rcases hx with rfl | hx | hx
          · simp [hAdef]
          · exact Finset.mem_union_right _ (hcψ.subformulas_subset hx)
          · exact Finset.mem_union_right _ (hcχ.subformulas_subset hx)
        · rw [subformulasFinset_bot, Finset.mem_singleton] at hx
          subst hx
          exact Finset.mem_union_right _ hbot
      · intro a b hab
        exact subset_trans (hcon₄ a b hab) Finset.subset_union_right
  · intro ζ hζ
    rw [subformulasFinset_imp] at hζ
    simp only [Finset.mem_insert, Finset.mem_union] at hζ
    rcases hζ with rfl | hζ | hζ
    · exact ⟨by simp [hAdef], by simp [hAdef]⟩
    · exact ⟨Finset.mem_union_right _ (hcψ ζ hζ).1, Finset.mem_union_right _ (hcψ ζ hζ).2⟩
    · exact ⟨Finset.mem_union_right _ (hcχ ζ hζ).1, Finset.mem_union_right _ (hcχ ζ hζ).2⟩

/-! ### 4.2d, discharged

The six cases assemble into the structural induction, and the induction closes the confinement
half. `exists_tableauClosed_closureIter_of_seed` is the unconditional form: no hypothesis, no
`sorry`, no appeal to a stock the caller must invent.
-/

/-- Every formula has a confining carrier. -/
theorem subConfining (φ : Formula) : SubConfining φ := by
  induction φ with
  | atom a => exact subConfining_atom a
  | bot => exact subConfining_bot
  | imp ψ χ ihψ ihχ => exact subConfining_imp ihψ ihχ
  | box ψ ih => exact subConfining_box ih
  | untl ψ χ ihψ ihχ => exact subConfining_untl ihψ ihχ
  | snce ψ χ ihψ ihχ => exact subConfining_snce ihψ ihχ

theorem confinesFormula (φ : Formula) : ConfinesFormula φ :=
  confinesFormula_of_subConfining (subConfining φ)

/-- **Confinement.** Every finite seed sits inside a finite emission-closed stock. -/
theorem exists_confining (seed : Finset Formula) : ∃ M, seed ⊆ M ∧ Confining M :=
  exists_confining_of_forall seed (fun φ _ => confinesFormula φ)

/--
**4.2d, unconditional.** The closure iteration from any finite seed reaches a `TableauClosed`
stock. Confinement supplies the bound and `exists_closureStep_subset` finds the fixed point at or
below it, so the T2 counting argument now runs against a stock the iteration computes rather than
against one a caller must exhibit.
-/
theorem exists_tableauClosed_closureIter_of_seed (seed : Finset Formula) :
    ∃ n, TableauClosed (closureIter n seed) := by
  obtain ⟨M, hseed, hM⟩ := exists_confining seed
  exact exists_tableauClosed_closureIter hseed hM

end FormalSystem.Metalogic.Decidability
