# Phase 2 Results: Close Easy Sorry Sites

## Status: COMPLETED

## Summary

Closed all 4 easy sorry sites in the Burgess chronicle construction. All proofs compile and `lake build` succeeds with no errors.

## Sorry Sites Closed

### 1. `exists_rat_gt_finset` (CounterexampleElimination.lean, was line 78)

**Proof strategy**: Case split on `S.Nonempty`. For non-empty sets, use `S.max' h + 1` as the witness. `Finset.le_max'` gives `s <= max'` for all `s in S`, and `lt_add_one` gives `max' < max' + 1`. The bound is strict so the witness is not in S (otherwise `max' + 1 <= max'`, contradiction via `linarith`). For empty sets, any value works (0).

**New imports added**: `Mathlib.Algebra.Order.Ring.Rat` (for `LinearOrder` on rationals), `Mathlib.Data.Finset.Max` (for `Finset.max'`, `Finset.le_max'`), `Mathlib.Tactic.Linarith` (for `linarith`).

### 2. `exists_rat_lt_finset` (CounterexampleElimination.lean, was line 89)

**Proof strategy**: Mirror of above using `S.min' h - 1`. `sub_one_lt` gives `min' - 1 < min'`, and `Finset.min'_le` gives `min' <= s` for all `s in S`. Strict lower bound ensures witness is not in S.

### 3. `counterexample_enum` (ChronicleConstruction.lean, was line 115)

**Proof strategy**: Established `Denumerable PotentialCounterexample` via:
1. `Countable PotentialCounterexample` -- injection into `Rat x Rat x Formula x Formula x PotentialCounterexampleKind` (all countable)
2. `Infinite PotentialCounterexample` -- injection from `Rat` (fix all other fields)
3. `Denumerable PotentialCounterexample` -- via `nonempty_denumerable` (countable + infinite)

Then defined `counterexample_enum n := Denumerable.ofNat PotentialCounterexample n`.

**New imports added**: `Mathlib.Data.Rat.Denumerable` (for `Denumerable Rat`).

**Additional change**: Added `Countable` to the deriving clause of `PotentialCounterexampleKind`.

### 4. `counterexample_enum_surjective` (ChronicleConstruction.lean, was line 123)

**Proof strategy**: Direct application of `Denumerable.ofNat_encode` -- for any `pc`, the witness is `Encodable.encode pc`.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
  - Added 3 imports: `Mathlib.Algebra.Order.Ring.Rat`, `Mathlib.Data.Finset.Max`, `Mathlib.Tactic.Linarith`
  - Replaced sorry in `exists_rat_gt_finset` with proof (13 lines)
  - Replaced sorry in `exists_rat_lt_finset` with proof (13 lines)
  - Added `Countable` to `PotentialCounterexampleKind` deriving clause

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
  - Added 1 import: `Mathlib.Data.Rat.Denumerable`
  - Added `Countable PotentialCounterexample` instance
  - Added `Infinite PotentialCounterexample` instance
  - Added `Denumerable PotentialCounterexample` instance
  - Replaced sorry in `counterexample_enum` with definition using `Denumerable.ofNat`
  - Replaced sorry in `counterexample_enum_surjective` with proof using `Denumerable.ofNat_encode`

## Verification

- `lake build` succeeds (1055 jobs, no errors)
- No sorry remains in `exists_rat_gt_finset`, `exists_rat_lt_finset`, `counterexample_enum`, `counterexample_enum_surjective`
- No new axioms introduced (0 axiom declarations in Theories/)
- 17 sorry sites remain in Chronicle/ (all belong to other phases)
