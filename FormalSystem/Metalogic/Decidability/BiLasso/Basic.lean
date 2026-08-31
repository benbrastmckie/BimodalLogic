/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.IntPresentation

/-!
# `BiLasso` — a Finitely Presented Bi-Infinite Ultimately-Periodic Step Path

A decision procedure for a presented ℤ-frame cannot quantify over `H_F` directly: over ℤ that set
is exactly the bi-infinite step-paths (`ParamTaskFrame.mem_HF_iff_adjacent`), and there are uncountably
many. This module supplies the finite presentation such a procedure enumerates instead.

A `BiLasso` is three lists of states — `back`, `mid`, `fwd` — decoded into a function
`ℤ → Fin P.card` that is `mid` on the window `[0, |mid|)`, `fwd` repeated rightward, and `back`
repeated leftward.

## The lasso must be bi-infinite

`H_F` over ℤ is the set of *bi-infinite* step-paths, and `Formula.snce` quantifies leftward
without bound. A right-only lasso — a finite prefix followed by a cycle, the shape a
one-directional Büchi construction uses — would leave the `snce` case of any evaluator with an
unbounded backward search. Hence `back`, and hence `back_ne` alongside `fwd_ne`: both cycles must
be non-empty for the decoding to be total.

## Indexing convention

Both cyclic segments are indexed **left to right in time**, through `BiLasso.cyc`, which is
`Int.emod`-based and so already non-negative at negative arguments:

```
 …  back[0] … back[|back|-1]   mid[0] … mid[|mid|-1]   fwd[0] … fwd[|fwd|-1]   fwd[0] …
                          ↑t = -1  ↑t = 0                              ↑t = |mid|+|fwd|-1
```

so `unroll (-1)` is the *last* entry of `back` and `unroll (-|back|)` its first. This is what
makes `coherent` a single contiguous window rather than a pile of seam and wrap-around clauses:
adjacency at every `t` in `[-|back|-1, |mid|+|fwd|)` covers the two within-segment chains, the two
seams, and the two wrap-arounds at once, and every other `t` reduces into that window modulo the
relevant cycle length.

The window is indexed by `Fin (|back| + 1 + |mid| + |fwd|)` rather than by a `Finset.Ico` over ℤ,
so that `coherent` is decidable by `Fintype.decidableForallFintype` alone.

## Main Definitions

- `BiLasso.cyc` — cyclic lookup into a non-empty list at an arbitrary integer index
- `BiLasso.unrollOf` — the decoding, as a function of the three lists (so that `coherent` can
  mention it)
- `BiLasso.windowTime` — the window index-to-time map
- `BiLasso` — the structure: `back`, `mid`, `fwd`, `back_ne`, `fwd_ne`, `coherent`
- `BiLasso.unroll` — `unrollOf` at the structure's own fields
- `BiLasso.toHF` — the decoded path as an element of `H_F`

## Main Results

- `BiLasso.unroll_sub_back_length` / `BiLasso.unroll_add_fwd_length` — the two periodicities
- `BiLasso.unroll_isStepPath` — the decoding is a step path of the presented frame

`coherent` is not vacuous: `flipBiLasso` exhibits a witness discharged by `decide` against the
real adjacency matrix, and the worked section also exhibits a *failing* candidate.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

namespace BiLasso

variable (P : IntPresentation)

/-- A default state, forced by `IntPresentation.card_pos`. Only ever consumed by `List.getD` at
indices that are in range, so it never appears in a decoded path. -/
instance instInhabitedFin : Inhabited (Fin P.card) := ⟨⟨0, P.card_pos⟩⟩

/-- Cyclic lookup: `cyc l i` is `l` at index `i` reduced modulo `l.length`. `Int.emod` is
non-negative at a positive modulus, so this is already total on negative indices. -/
def cyc (l : List (Fin P.card)) (i : ℤ) : Fin P.card :=
  l.getD (i % (l.length : ℤ)).toNat default

/-- A non-empty list has positive length, as an integer. -/
theorem length_pos_int {l : List (Fin P.card)} (hl : l ≠ []) : (0 : ℤ) < (l.length : ℤ) := by
  have : l.length ≠ 0 := fun h => hl (List.eq_nil_of_length_eq_zero h)
  exact_mod_cast Nat.pos_of_ne_zero this

/-- `cyc` reads only the residue of its index. -/
theorem cyc_congr {l : List (Fin P.card)} {i j : ℤ}
    (h : i % (l.length : ℤ) = j % (l.length : ℤ)) : cyc P l i = cyc P l j := by
  simp only [cyc, h]

/-- Shifting by a multiple of the modulus does not change the residue. -/
theorem emod_add_mul (x k n : ℤ) : (x + k * n) % n = x % n := by
  rw [Int.add_mul_emod_self_right]

/-- The canonical representative of `i` in `[a, a + n)` has residue `i % n`. -/
theorem reduce_emod (n a i : ℤ) : (a + (i - a) % n) % n = i % n := by
  conv_rhs => rw [show i = a + (i - a) by omega]
  rw [Int.add_emod a ((i - a) % n) n, Int.emod_emod_of_dvd _ (dvd_refl n), ← Int.add_emod]

/-- Residue equality is preserved by the successor. -/
theorem emod_succ_congr {n x y : ℤ} (h : x % n = y % n) : (x + 1) % n = (y + 1) % n := by
  rw [Int.add_emod, h, ← Int.add_emod]

/-- The canonical representative of `i` in the window `[a, a + l.length)` decodes the same. -/
theorem cyc_reduce {l : List (Fin P.card)} (a i : ℤ) :
    cyc P l (a + (i - a) % (l.length : ℤ)) = cyc P l i :=
  cyc_congr P (reduce_emod _ a i)

/-- The reduction of `i` into `[a, a + l.length)` really lands there. -/
theorem reduce_mem {l : List (Fin P.card)} (hl : l ≠ []) (a i : ℤ) :
    a ≤ a + (i - a) % (l.length : ℤ) ∧
      a + (i - a) % (l.length : ℤ) < a + (l.length : ℤ) := by
  have hlen := length_pos_int P hl
  have h0 : 0 ≤ (i - a) % (l.length : ℤ) := Int.emod_nonneg _ (by omega)
  have h1 : (i - a) % (l.length : ℤ) < (l.length : ℤ) := Int.emod_lt_of_pos _ hlen
  omega

/--
The decoding, as a function of the three segment lists.

Stated separately from the structure so that the structure's `coherent` field can mention it —
`unroll` below is this function at the structure's own fields.
-/
def unrollOf (back mid fwd : List (Fin P.card)) (t : ℤ) : Fin P.card :=
  if t < 0 then cyc P back t
  else if t < (mid.length : ℤ) then mid.getD t.toNat default
  else cyc P fwd (t - (mid.length : ℤ))

/-- The window index-to-time map: index `0` is time `-|back| - 1`. -/
def windowTime (back : List (Fin P.card)) (i : ℕ) : ℤ := (i : ℤ) - (back.length : ℤ) - 1

end BiLasso

open BiLasso in
/--
A **bi-lasso** over an `IntPresentation`: a finitely presented, bi-infinite, ultimately-periodic
walk in the presentation's adjacency matrix.

`coherent` is a quantifier over a `Fin`, hence decidable, hence usable as the filter of the
bounded enumeration. It is *not* vacuous: see `flipBiLasso`.
-/
structure BiLasso (P : IntPresentation) where
  /-- The leftward cycle, indexed left-to-right in time: `back[|back|-1]` sits at `t = -1`. -/
  back : List (Fin P.card)
  /-- The finite window `[0, |mid|)`. May be empty. -/
  mid : List (Fin P.card)
  /-- The rightward cycle, indexed left-to-right in time: `fwd[0]` sits at `t = |mid|`. -/
  fwd : List (Fin P.card)
  /-- The leftward cycle is non-empty — without it the decoding is not total on the negatives. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty. -/
  fwd_ne : fwd ≠ []
  /-- Adjacency across one full window `[-|back|-1, |mid|+|fwd|)`. Every other time reduces into
  this window modulo the relevant cycle length, which is what `BiLasso.unroll_isStepPath`
  establishes. -/
  coherent : ∀ i : Fin (back.length + 1 + mid.length + fwd.length),
    P.step (unrollOf P back mid fwd (windowTime P back i))
      (unrollOf P back mid fwd (windowTime P back i + 1)) = true

namespace BiLasso

variable {P : IntPresentation}

/-- The decoded bi-infinite path. -/
def unroll (L : BiLasso P) : ℤ → Fin P.card := unrollOf P L.back L.mid L.fwd

theorem unroll_def (L : BiLasso P) (t : ℤ) :
    L.unroll t = unrollOf P L.back L.mid L.fwd t := rfl

/-- On the negatives the decoding is the leftward cycle. -/
theorem unroll_neg (L : BiLasso P) {t : ℤ} (ht : t < 0) : L.unroll t = cyc P L.back t := by
  simp [unroll, unrollOf, ht]

/-- At or past `|mid|` the decoding is the rightward cycle. -/
theorem unroll_fwd (L : BiLasso P) {t : ℤ} (ht : (L.mid.length : ℤ) ≤ t) :
    L.unroll t = cyc P L.fwd (t - (L.mid.length : ℤ)) := by
  have hnn : (0 : ℤ) ≤ (L.mid.length : ℤ) := Int.natCast_nonneg _
  have h0 : ¬ t < 0 := by omega
  simp [unroll, unrollOf, h0, not_lt.mpr ht]

/-- **Leftward periodicity.** Strictly left of the origin the decoding has period `|back|`. -/
theorem unroll_sub_back_length (L : BiLasso P) {t : ℤ} (ht : t < 0) :
    L.unroll (t - (L.back.length : ℤ)) = L.unroll t := by
  have hlen := length_pos_int P L.back_ne
  rw [unroll_neg L (by omega), unroll_neg L ht]
  refine cyc_congr P ?_
  rw [show t - (L.back.length : ℤ) = t + (-1) * (L.back.length : ℤ) by omega]
  exact emod_add_mul t (-1) _

/-- **Rightward periodicity.** At or past `|mid|` the decoding has period `|fwd|`. -/
theorem unroll_add_fwd_length (L : BiLasso P) {t : ℤ} (ht : (L.mid.length : ℤ) ≤ t) :
    L.unroll (t + (L.fwd.length : ℤ)) = L.unroll t := by
  have hlen := length_pos_int P L.fwd_ne
  rw [unroll_fwd L (by omega), unroll_fwd L ht]
  refine cyc_congr P ?_
  rw [show t + (L.fwd.length : ℤ) - (L.mid.length : ℤ)
      = (t - (L.mid.length : ℤ)) + 1 * (L.fwd.length : ℤ) by omega]
  exact emod_add_mul _ 1 _

/-- `coherent`, restated at a time in the window rather than at a `Fin` index. -/
theorem step_of_mem_window (L : BiLasso P) {t : ℤ}
    (h1 : -(L.back.length : ℤ) - 1 ≤ t)
    (h2 : t < (L.mid.length : ℤ) + (L.fwd.length : ℤ)) :
    P.step (L.unroll t) (L.unroll (t + 1)) = true := by
  have hlt : (t + (L.back.length : ℤ) + 1).toNat
      < L.back.length + 1 + L.mid.length + L.fwd.length := by omega
  have hcoh := L.coherent ⟨(t + (L.back.length : ℤ) + 1).toNat, hlt⟩
  have hw : windowTime P L.back ((t + (L.back.length : ℤ) + 1).toNat) = t := by
    simp only [windowTime]
    omega
  rw [hw] at hcoh
  simpa [unroll_def] using hcoh

/--
**The decoding is a step path of the presented frame.**

Every `t : ℤ` reduces into the `coherent` window: times `≤ -2` reduce modulo `|back|` into
`[-|back|-1, -1)`, times `≥ |mid|` reduce modulo `|fwd|` into `[|mid|, |mid|+|fwd|)`, and the
remaining `t ∈ [-1, |mid|)` are in the window already.
-/
theorem unroll_isStepPath (L : BiLasso P) : IsStepPath P.toTaskFrame L.unroll := by
  have hb := length_pos_int P L.back_ne
  have hf := length_pos_int P L.fwd_ne
  have hm : (0 : ℤ) ≤ (L.mid.length : ℤ) := Int.natCast_nonneg _
  rw [P.isStepPath_iff]
  intro t
  rcases (by omega : t < -1 ∨ -1 ≤ t) with hlt | hge
  · -- `t ≤ -2`: reduce modulo `|back|` into `[-|back|-1, -1)`.
    set a : ℤ := -(L.back.length : ℤ) - 1 with ha
    set t' : ℤ := a + (t - a) % (L.back.length : ℤ) with ht'
    obtain ⟨hlo, hhi⟩ := reduce_mem P L.back_ne a t
    have hres : t' % (L.back.length : ℤ) = t % (L.back.length : ℤ) :=
      reduce_emod _ a t
    have hcoh := L.step_of_mem_window (t := t') (by omega) (by omega)
    have e1 : L.unroll t' = L.unroll t := by
      rw [unroll_neg L (by omega), unroll_neg L (by omega)]
      exact cyc_congr P hres
    have e2 : L.unroll (t' + 1) = L.unroll (t + 1) := by
      rw [unroll_neg L (by omega), unroll_neg L (by omega)]
      exact cyc_congr P (emod_succ_congr hres)
    rw [← e1, ← e2]
    exact hcoh
  rcases (by omega : t < (L.mid.length : ℤ) ∨ (L.mid.length : ℤ) ≤ t) with hmid | hmid
  · -- `-1 ≤ t < |mid|`: already in the window.
    exact L.step_of_mem_window (by omega) (by omega)
  · -- `t ≥ |mid|`: reduce modulo `|fwd|` into `[|mid|, |mid|+|fwd|)`.
    set a : ℤ := (L.mid.length : ℤ) with ha
    set t' : ℤ := a + (t - a) % (L.fwd.length : ℤ) with ht'
    obtain ⟨hlo, hhi⟩ := reduce_mem P L.fwd_ne a t
    have hres : (t' - a) % (L.fwd.length : ℤ) = (t - a) % (L.fwd.length : ℤ) := by
      have : t' - a = (t - a) % (L.fwd.length : ℤ) := by rw [ht']; omega
      rw [this]
      exact Int.emod_emod_of_dvd _ (dvd_refl _)
    have hcoh := L.step_of_mem_window (t := t') (by omega) (by omega)
    have e1 : L.unroll t' = L.unroll t := by
      rw [unroll_fwd L (by omega), unroll_fwd L hmid]
      exact cyc_congr P hres
    have e2 : L.unroll (t' + 1) = L.unroll (t + 1) := by
      rw [unroll_fwd L (by omega), unroll_fwd L (by omega)]
      refine cyc_congr P ?_
      have h1 : t' + 1 - a = (t' - a) + 1 := by omega
      have h2 : t + 1 - a = (t - a) + 1 := by omega
      rw [h1, h2]
      exact emod_succ_congr hres
    rw [← e1, ← e2]
    exact hcoh

/-- The decoded path as an element of `H_F` — the form `TruthAt` consumes. -/
def toHF (L : BiLasso P) : TaskFrame.HF P.toTaskFrame :=
  ParamTaskFrame.HFofStepPath P.toTaskFrame L.unroll L.unroll_isStepPath

@[simp]
theorem toHF_path (L : BiLasso P) : L.toHF.path = L.unroll := rfl

end BiLasso

/-!
## Worked instance

`coherent` is not `True`. The two-state cycle `flipPresentation`
(`Decidability/IntPresentation.lean`) carries the alternating bi-lasso below, and `decide`
discharges its `coherent` field against the real adjacency matrix.
-/

section WorkedInstance

/-- The alternating bi-infinite path `… 0 1 0 1 …` over `flipPresentation`, with the origin at a
`0`. Empty `mid`; both cycles are the two-element list `[0, 1]`. -/
def flipBiLasso : BiLasso flipPresentation where
  back := [0, 1]
  mid := []
  fwd := [0, 1]
  back_ne := by simp
  fwd_ne := by simp
  coherent := by decide

example : flipBiLasso.unroll 0 = 0 := by decide
example : flipBiLasso.unroll 1 = 1 := by decide
example : flipBiLasso.unroll (-1) = 1 := by decide
example : flipBiLasso.unroll (-2) = 0 := by decide

/-- The `coherent` field asserts the presentation's own adjacency, not a tautology: the constant
path fails it over `flipPresentation`, because `step w w = false` there. -/
example : ¬ (∀ i : Fin ([(0 : Fin 2)].length + 1 + ([] : List (Fin 2)).length + [(0 : Fin 2)].length),
    flipPresentation.step
        (BiLasso.unrollOf flipPresentation [0] [] [0]
          (BiLasso.windowTime flipPresentation [0] i))
        (BiLasso.unrollOf flipPresentation [0] [] [0]
          (BiLasso.windowTime flipPresentation [0] i + 1)) = true) := by decide

end WorkedInstance

end FormalSystem.Metalogic.Decidability
