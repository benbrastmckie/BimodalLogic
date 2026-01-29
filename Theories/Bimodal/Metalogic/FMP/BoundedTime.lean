import Mathlib.Algebra.Group.Basic
import Mathlib.Algebra.Order.Group.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.Fintype.Fin
import Mathlib.Order.Basic

/-!
# Parametric Bounded Time Domain for FMP

This module defines `BoundedTime k`, a finite time domain for the
Finite Model Property construction. `BoundedTime k` represents a finite set
of time points with 2k+1 elements, corresponding to integer offsets from -k to +k.

## Design Philosophy

The key insight is that the Finite Model Property bound (2^closureSize) is purely
combinatorial - it counts subsets of the subformula closure. The time domain used
for finite model construction just needs to be finite with a known cardinality.

We use Fin (2*k+1) as the canonical finite time domain. This gives us:

1. **Automatic Fintype**: `BoundedTime k` is definitionally `Fin (2*k+1)`
2. **Known cardinality**: `Fintype.card (BoundedTime k) = 2*k+1`
3. **Integer interpretation**: `toInt : BoundedTime k → Int` maps to [-k, k]

The connection to a parametric duration type D is handled at a higher level
in the FMP construction, not in this module.

## Main Definitions

- `BoundedTime k`: Finite time domain with 2k+1 elements
- `BoundedTime.toInt`: Convert to integer offset in [-k, k]
- `BoundedTime.origin`: The zero time point (maps to 0)
- `BoundedTime.ofInt?`: Construct from integer offset

## Usage in FMP

In the FMP construction, we use `BoundedTime (temporalBound φ)` as the time
domain for finite histories.

## References

- Original `FiniteTime` in Boneyard/Metalogic_v2/Representation/FiniteWorldState.lean
-/

namespace Bimodal.Metalogic.FMP

/-!
## Bounded Time Definition

We define `BoundedTime` as `Fin (2*k+1)` to get automatic Fintype instance.
-/

/--
Bounded time domain with 2k+1 elements, representing time offsets from -k to +k.

This is definitionally `Fin (2*k+1)`, so it automatically has:
- `Fintype` instance
- `DecidableEq` instance
- `LinearOrder` instance
- Cardinality exactly `2*k+1`
-/
abbrev BoundedTime (k : Nat) := Fin (2 * k + 1)

namespace BoundedTime

/-!
## Core Operations
-/

/--
The origin (time 0) in the bounded time domain.
This is the middle element k of the range [0, 2k].
-/
def origin (k : Nat) : BoundedTime k :=
  ⟨k, by omega⟩

/--
Convert to a centered integer offset.
Maps index i ∈ [0, 2k] to integer i - k ∈ [-k, k].
-/
def toInt (k : Nat) (t : BoundedTime k) : Int :=
  (t.val : Int) - (k : Int)

/--
Construct a bounded time from an integer offset in range [-k, k].
Returns none if the offset is out of range.
-/
def ofInt? (k : Nat) (n : Int) : Option (BoundedTime k) :=
  let i := n + k
  if h : 0 ≤ i ∧ i < 2 * k + 1 then
    some ⟨i.toNat, by omega⟩
  else
    none

/--
Construct a bounded time from a natural number index.
-/
def ofNat (k : Nat) (n : Nat) (h : n < 2 * k + 1) : BoundedTime k :=
  ⟨n, h⟩

/-!
## Basic Properties
-/

/--
The origin maps to 0 under toInt.
-/
theorem origin_toInt (k : Nat) : toInt k (origin k) = 0 := by
  simp [origin, toInt]

/--
toInt is injective.
-/
theorem toInt_injective (k : Nat) : Function.Injective (toInt k) := by
  intros t1 t2 h
  simp [toInt] at h
  ext
  omega

/--
The range of toInt is [-k, k].
-/
theorem toInt_range (k : Nat) (t : BoundedTime k) :
    -(k : Int) ≤ toInt k t ∧ toInt k t ≤ (k : Int) := by
  constructor
  · simp only [toInt]; omega
  · simp only [toInt]
    have : t.val ≤ 2 * k := Nat.lt_succ_iff.mp t.isLt
    omega

/--
Lower bound of toInt range.
-/
theorem toInt_lower (k : Nat) (t : BoundedTime k) : -(k : Int) ≤ toInt k t := by
  exact (toInt_range k t).1

/--
Upper bound of toInt range.
-/
theorem toInt_upper (k : Nat) (t : BoundedTime k) : toInt k t ≤ (k : Int) := by
  exact (toInt_range k t).2

/-!
## Fintype Properties

Since `BoundedTime k = Fin (2*k+1)`, these are automatic from Fin.
-/

/--
Cardinality of bounded time is exactly 2k+1.
-/
theorem card (k : Nat) : Fintype.card (BoundedTime k) = 2 * k + 1 := by
  simp [Fintype.card_fin]

/--
Bounded time is nonempty (has at least origin).
-/
instance instNonempty (k : Nat) : Nonempty (BoundedTime k) := ⟨origin k⟩

/--
Bounded time is inhabited with origin.
-/
instance instInhabited (k : Nat) : Inhabited (BoundedTime k) := ⟨origin k⟩

/-!
## Successor/Predecessor Operations

These are partial operations that stay within bounds.
-/

/--
Try to add 1 to the time index (move forward in time).
Returns none if at maximum bound.
-/
def succ? (t : BoundedTime k) : Option (BoundedTime k) :=
  if h : t.val + 1 < 2 * k + 1 then
    some ⟨t.val + 1, h⟩
  else
    none

/--
Try to subtract 1 from the time index (move backward in time).
Returns none if at minimum bound (index 0).
-/
def pred? (t : BoundedTime k) : Option (BoundedTime k) :=
  if h : t.val > 0 then
    some ⟨t.val - 1, by omega⟩
  else
    none

/--
Successor increases toInt by 1.
-/
theorem succ_toInt {k : Nat} {t t' : BoundedTime k}
    (h : succ? t = some t') : toInt k t' = toInt k t + 1 := by
  simp only [succ?] at h
  split_ifs at h with h'
  · simp only [Option.some_inj] at h
    simp [toInt, h]
  · simp at h

/--
Predecessor decreases toInt by 1.
-/
theorem pred_toInt {k : Nat} {t t' : BoundedTime k}
    (h : pred? t = some t') : toInt k t' = toInt k t - 1 := by
  simp only [pred?] at h
  split_ifs at h with h'
  · simp only [Option.some_inj] at h
    simp [toInt, h]
    omega
  · simp at h

/-!
## Order Properties

BoundedTime inherits linear order from Fin.
-/

/--
toInt preserves order.
-/
theorem toInt_mono {k : Nat} {t1 t2 : BoundedTime k}
    (h : t1 ≤ t2) : toInt k t1 ≤ toInt k t2 := by
  simp only [toInt]
  omega

/--
toInt reflects order.
-/
theorem le_of_toInt_le {k : Nat} {t1 t2 : BoundedTime k}
    (h : toInt k t1 ≤ toInt k t2) : t1 ≤ t2 := by
  simp only [toInt] at h
  exact h

/--
toInt is strictly monotone.
-/
theorem toInt_strictMono {k : Nat} {t1 t2 : BoundedTime k}
    (h : t1 < t2) : toInt k t1 < toInt k t2 := by
  simp only [toInt]
  omega

/--
toInt strictly reflects order.
-/
theorem lt_of_toInt_lt {k : Nat} {t1 t2 : BoundedTime k}
    (h : toInt k t1 < toInt k t2) : t1 < t2 := by
  simp only [toInt] at h
  exact Fin.lt_iff_val_lt_val.mpr (by omega)

/-!
## Enumeration

Enumerate all bounded time points.
-/

/--
The minimum bounded time (index 0, maps to -k).
-/
def min (k : Nat) : BoundedTime k :=
  ⟨0, by omega⟩

/--
The maximum bounded time (index 2k, maps to +k).
-/
def max (k : Nat) : BoundedTime k :=
  ⟨2 * k, by omega⟩

/--
Minimum maps to -k.
-/
theorem min_toInt (k : Nat) : toInt k (min k) = -(k : Int) := by
  simp [min, toInt]

/--
Maximum maps to +k.
-/
theorem max_toInt (k : Nat) : toInt k (max k) = (k : Int) := by
  simp [max, toInt]
  omega

/--
Origin is between min and max.
-/
theorem min_le_origin (k : Nat) : min k ≤ origin k := by
  simp [min, origin]

theorem origin_le_max (k : Nat) : origin k ≤ max k := by
  simp only [origin, max]
  omega

end BoundedTime

end Bimodal.Metalogic.FMP
