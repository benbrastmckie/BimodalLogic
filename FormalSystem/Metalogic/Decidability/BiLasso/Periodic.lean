/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.List.Basic

/-!
# Generic Ultimately-Periodic Decoding in Both Directions

`BiLasso/Basic.lean` decodes three lists of *states* into a bi-infinite function `ℤ → Fin P.card`.
The annotation layer needs the identical decoding for three lists of *type labels*, and the two
must agree position for position or every clause relating a label to a state is off by one. This
module supplies the decoding once, at an arbitrary `[Inhabited α]`, so that both consumers are
instances of one scheme rather than two hand-aligned copies.

## Indexing convention

Identical to `Basic.lean`'s, and deliberately so:

```
 …  back[0] … back[|back|-1]   mid[0] … mid[|mid|-1]   fwd[0] … fwd[|fwd|-1]   fwd[0] …
                          ↑t = -1  ↑t = 0                              ↑t = |mid|+|fwd|-1
```

Both cycles are indexed left to right in time. `Int.emod` is non-negative at a positive modulus,
so `cyc` is already total at negative indices with no case split.

## Deliberate duplication against `Basic.lean`

`Basic.lean` is **held stable** for the benefit of the concurrent effective-periodic-extension
work, which is expected to consume it unchanged; refactoring its `cyc` / `unrollOf` onto the
generic definitions below is therefore explicitly out of scope here. The cost is that the `emod`
arithmetic appears twice — once at `Fin P.card` in `Basic.lean`, once at arbitrary `α` here.

That duplication is small (four short arithmetic lemmas and two periodicity proofs) and is
recorded rather than hidden. **The trigger that retires it**: once a shared periodic-sequence
presentation lands from the effective-periodic-extension work, `Basic.lean`'s `cyc` and
`unrollOf` should be redefined as the `Fin P.card` instances of this file's, and the duplicated
arithmetic deleted. That refactor belongs to whichever task owns the shared abstraction, not to
this one.

## Main Definitions

- `Periodic.cyc` — cyclic lookup into a non-empty list at an arbitrary integer index
- `Periodic.unrollOf` — the three-segment decoding

## Main Results

- `Periodic.unrollOf_sub_back_length` — leftward periodicity, period `|back|`, threshold `t < 0`
- `Periodic.unrollOf_add_fwd_length` — rightward periodicity, period `|fwd|`, threshold `|mid| ≤ t`
-/

namespace FormalSystem.Metalogic.Decidability.Periodic

variable {α : Type*} [Inhabited α]

/-- Cyclic lookup: `cyc l i` is `l` at index `i` reduced modulo `l.length`. `Int.emod` is
non-negative at a positive modulus, so this is already total on negative indices. -/
def cyc (l : List α) (i : ℤ) : α :=
  l.getD (i % (l.length : ℤ)).toNat default

omit [Inhabited α] in
/-- A non-empty list has positive length, as an integer. -/
theorem length_pos_int {l : List α} (hl : l ≠ []) : (0 : ℤ) < (l.length : ℤ) := by
  have : l.length ≠ 0 := fun h => hl (List.eq_nil_of_length_eq_zero h)
  exact_mod_cast Nat.pos_of_ne_zero this

/-- `cyc` reads only the residue of its index. -/
theorem cyc_congr {l : List α} {i j : ℤ}
    (h : i % (l.length : ℤ) = j % (l.length : ℤ)) : cyc l i = cyc l j := by
  simp only [cyc, h]

/-- Shifting by a multiple of the modulus does not change the residue. -/
theorem emod_add_mul (x k n : ℤ) : (x + k * n) % n = x % n := by
  rw [Int.add_mul_emod_self_right]

/--
The three-segment decoding: `back` repeated leftward of the origin, `mid` on the window
`[0, |mid|)`, and `fwd` repeated rightward from `|mid|`.

Stated as a function of the three lists rather than of a structure, so that a structure's own
coherence field can mention it — the same reason `BiLasso.unrollOf` is stated this way.
-/
def unrollOf (back mid fwd : List α) (t : ℤ) : α :=
  if t < 0 then cyc back t
  else if t < (mid.length : ℤ) then mid.getD t.toNat default
  else cyc fwd (t - (mid.length : ℤ))

/-- On the negatives the decoding is the leftward cycle. -/
theorem unrollOf_neg (back mid fwd : List α) {t : ℤ} (ht : t < 0) :
    unrollOf back mid fwd t = cyc back t := by
  simp [unrollOf, ht]

/-- On the window `[0, |mid|)` the decoding reads `mid` directly. -/
theorem unrollOf_mid (back mid fwd : List α) {t : ℤ} (h0 : 0 ≤ t)
    (ht : t < (mid.length : ℤ)) :
    unrollOf back mid fwd t = mid.getD t.toNat default := by
  simp [unrollOf, not_lt.mpr h0, ht]

/-- At or past `|mid|` the decoding is the rightward cycle. -/
theorem unrollOf_fwd (back mid fwd : List α) {t : ℤ} (ht : (mid.length : ℤ) ≤ t) :
    unrollOf back mid fwd t = cyc fwd (t - (mid.length : ℤ)) := by
  have hnn : (0 : ℤ) ≤ (mid.length : ℤ) := Int.natCast_nonneg _
  have h0 : ¬ t < 0 := by omega
  simp [unrollOf, h0, not_lt.mpr ht]

/-- **Leftward periodicity.** Strictly left of the origin the decoding has period `|back|`. -/
theorem unrollOf_sub_back_length (back mid fwd : List α) (hb : back ≠ []) {t : ℤ} (ht : t < 0) :
    unrollOf back mid fwd (t - (back.length : ℤ)) = unrollOf back mid fwd t := by
  have hlen := length_pos_int (l := back) hb
  rw [unrollOf_neg back mid fwd (by omega), unrollOf_neg back mid fwd ht]
  refine cyc_congr ?_
  rw [show t - (back.length : ℤ) = t + (-1) * (back.length : ℤ) by omega]
  exact emod_add_mul t (-1) _

/-- **Rightward periodicity.** At or past `|mid|` the decoding has period `|fwd|`. -/
theorem unrollOf_add_fwd_length (back mid fwd : List α) (hf : fwd ≠ []) {t : ℤ}
    (ht : (mid.length : ℤ) ≤ t) :
    unrollOf back mid fwd (t + (fwd.length : ℤ)) = unrollOf back mid fwd t := by
  have hlen := length_pos_int (l := fwd) hf
  rw [unrollOf_fwd back mid fwd (by omega), unrollOf_fwd back mid fwd ht]
  refine cyc_congr ?_
  rw [show t + (fwd.length : ℤ) - (mid.length : ℤ)
      = (t - (mid.length : ℤ)) + 1 * (fwd.length : ℤ) by omega]
  exact emod_add_mul _ 1 _

end FormalSystem.Metalogic.Decidability.Periodic
