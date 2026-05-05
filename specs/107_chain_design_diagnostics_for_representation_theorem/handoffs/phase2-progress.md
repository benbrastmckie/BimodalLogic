# Handoff: Phase 2 Progress -- BurgessR3Maximal Definition Gap

## Session: sess_1778014444_dca927
## Date: 2026-05-05
## Status: Phase 2 PARTIAL

## What Was Done

### Sorry #3 (Lemma 2.7 inconsistent case): Restructured

Changed the case split in `lemma_2_7` from `SetConsistent ({xi} ∪ B)` to
`SetConsistent ({xi})`. The consistent-xi case now covers BOTH:
- Old consistent case: `{xi} ∪ B` consistent (implies `{xi}` consistent)
- NEW: `{xi} ∪ B` inconsistent BUT `{xi}` consistent (xi.neg in B, but xi itself is not contradictory)

The DC({xi}) approach works for both sub-cases because:
1. `SetConsistent ({xi})` gives `SetDeductivelyClosed (DC({xi}))`
2. `burgessR A xi D` + left_mono gives `burgessRSet(A, DC({xi}), D)` 
3. `burgessRSince D xi A` + left_mono gives `burgessRSetSince(D, DC({xi}), A)`
4. Combined: `burgessR3(A, DC({xi}), D)` -- Zorn gives B' with xi in B'

Remaining sorry at line 2869: the degenerate case where `{xi}` is ITSELF inconsistent
(xi is a contradiction like `p AND not p`). This requires BurgessR3Maximal to range
over ClosedUnderDerivation (Burgess's original def where Set.univ is valid DCS).
In the chronicle construction over Q (dense), this case never arises because
`untl(inconsistent_guard, event)` is unsatisfiable on dense orders.

### Sorry #1 (Lemma 2.6 Case B pos sub-case): BLOCKED

Confirmed that sorry #1 is a genuine mathematical gap caused by the
BurgessR3Maximal definition discrepancy with Burgess 1982.

## Root Cause Analysis: BurgessR3Maximal Definition

### The Problem

Burgess 1982 defines R(A, B, C) with B maximal among ALL deductively closed sets
(DCSs), including inconsistent ones. Our `BurgessR3Maximal` restricts maximality
to `SetDeductivelyClosed` sets (consistent + closed), excluding Set.univ.

This creates a gap when B is MCS (maximal consistent set):

**Burgess's framework**: When B is MCS and delta not in B:
- DC({delta} union B) = Set.univ (inconsistent extension)
- Set.univ IS a DCS in Burgess's sense
- Maximality of B requires NOT(r(A, Set.univ, C))
- From NOT(r(A, Set.univ, C)): neg-until witness exists
- PROOF GOES THROUGH

**Our framework**: When B is MCS and delta not in B:
- DC({delta} union B) = Set.univ (inconsistent extension)
- Set.univ is NOT SetDeductivelyClosed
- Maximality is vacuous (no consistent proper extension exists)
- NO neg-until witness extractable
- PROOF BLOCKED

### Why We Can't Simply Fix the Definition

**Option: Change to ClosedUnderDerivation**
Requires `NoUnivBurgessR3` (not(burgessR3(A, Set.univ, C))) during Zorn construction.
But `NoUnivBurgessR3` is NOT a J0 theorem:
- Counterexample: 2-point discrete order {0,1}, A = MCS at 0, C = MCS at 1
- `untl(phi, gamma)` at 0 iff gamma at 1 (vacuous guard on empty interval)
- `burgessR3(A, Set.univ, C)` holds (all Until and Since formulas satisfied trivially)

**Option: Add neg-until witness to definition**
Can't prove during Zorn construction for the inconsistent extension case.

**Option: Add hypothesis not(SetMaximalConsistent B)**
The Zorn maximum CAN be MCS (no way to prevent it).

### Concrete Counterexample

D0 seed for Lemma 2.6 is INCONSISTENT when B is MCS:
- B = A = MCS at point 0 on {0,1}
- C = MCS at point 1
- D0 = B union {beta.neg} union {untl(beta', gamma)} union {snce(beta', alpha)}
- snce(beta', alpha) at point 0: requires y < 0 (impossible on {0,1})
- So (snce(beta', alpha)).neg in A = B
- D0 contains both snce(beta', alpha) and its negation: INCONSISTENT

### Recommended Fix

**Two-tier maximality**: Separate the concerns:

```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B AND
  burgessR3 A B C AND
  (forall D, SetDeductivelyClosed D -> B subset D -> not(burgessR3 A D C)) AND
  not(burgessR3 A Set.univ C)  -- Burgess alignment clause
```

The fourth conjunct can be proved:
1. During Zorn: if burgessR3(A, Set.univ, C) held, Set.univ would be in the
   ClosedUnderDerivation extension family. The Zorn maximum among SetDeductivelyClosed
   sets is NOT Set.univ, but maximality among consistent sets + not(burgessR3(A,Set.univ,C))
   gives maximality among ALL deductively closed sets.

2. NOT provable for all A, C. But provable for SPECIFIC A, C in the chronicle
   construction if we can derive it from the construction properties.

**Alternative**: Thread `not(burgessR3 A Set.univ C)` as a hypothesis through the
construction. When the chronicle is built over Q, this can be proved for each
adjacent pair because on dense orders, untl(bot, gamma) is unsatisfiable.

## Sorry Count

- Before: 12 sorries (PI:3, CE:7, CTC:2)
- After: 12 sorries (PI:3, CE:7, CTC:2) -- count unchanged
  - Sorry #1 (PI:1968): STILL OPEN (blocked by definition gap)
  - Sorry #2 (PI:2734): STILL OPEN (seed consistency, Phase 3)
  - Sorry #3 (PI:2869): RESTRUCTURED (now only covers degenerate xi-inconsistent case)

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Lines 2812-2869: Restructured case split in lemma_2_7

## Build Status

`lake build` passes with 0 errors.

## Recommended Next Steps

1. **For sorry #1**: Implement the two-tier maximality fix:
   - Add `not(burgessR3 A Set.univ C)` as the fourth conjunct of BurgessR3Maximal
   - Update Zorn construction to also prove this conjunct
   - Use it in burgess_D0_finite_subset_consistent_incons to extract neg-until witness
   - This requires proving `not(burgessR3(A, Set.univ, C))` during construction

2. **For sorry #3 degenerate case**: Follows from the same fix (ClosedUnderDerivation
   maximality allows B' = Set.univ when xi is inconsistent)

3. **Alternative**: Add `not(burgessR3 A Set.univ C)` as a HYPOTHESIS to
   lemma_2_6_splitting and lemma_2_7. Prove it at the chronicle construction level
   where the g_content/density properties are available.

4. **For sorry #2 (Phase 3)**: Independent of this blocker. Can proceed in parallel.

## Convention Reminder

Our `untl(guard, event)` = Burgess `U(event, guard)`. Arguments are SWAPPED.
