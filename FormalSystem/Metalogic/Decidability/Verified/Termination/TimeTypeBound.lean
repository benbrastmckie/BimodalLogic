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

end FormalSystem.Metalogic.Decidability
