/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.GoodCycle
import FormalSystem.Metalogic.Decidability.BiLasso.Decide

/-!
# The Small-Model Theorem, in the Windowed Shape

This module assembles the annotated bi-lasso a satisfying history is compressed into, and proves
the small-model theorem `exists_annot_of_truth`.

## Why the witness is delivered at a position, not at the origin

A `BiLasso`'s origin is **pinned**: `Basic.lean` decodes `back` repeated strictly left of `0`,
`mid` on `[0, |mid|)`, and `fwd` repeated at or past `|mid|`, so there is no left prefix. A
two-sided pigeonhole therefore forces the lasso's origin to sit at the *backward repeat*, and the
point of interest lands wherever the compressed mid segment puts it — not at position `0`.

Demanding otherwise demands a recurrence of the *type* at the point of interest, and no such
recurrence need exist. That is machine-checked, not conjectured:
`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase10-origin-anchoring-obstruction.lean`
exhibits a total history whose closure formula `prev⁵ w` has truth set exactly `{0}`, so the type
at `0` recurs at no earlier time.

**Shifting the history does not rescue anchoring**, and it is worth saying why, because it looks
as though it should. `Semantics.TimeShift.time_shift_preserves_truth` (`Semantics/Truth.lean`)
moves truth along a time shift, and `WorldHistory.timeShift` of a total history is total. But the
decision procedure enumerates *lassos*, not histories: `timeShift τ i` is a perfectly good total
history and is simply not the `unroll` of any enumerated `BiLasso` whose origin sits where the
shift put it. So the extra degree of freedom has to live in the *consumer* — hence the `∃ i` in
the window below.

The concurrent effective-periodic-extension work makes the same degree of freedom structural, by
carrying an explicit `origin` alongside the lasso. The two are the same freedom expressed twice;
unifying them belongs to whichever layer owns the shared abstraction and is not done here.

## The assembly

Three walks in the realised-datum graph of `Realized.lean`, laid end to end:

| lasso times | segment | source |
|---|---|---|
| `[-nb, -1]` | `back` | the good **backward** cycle, read outward from time `-1` |
| `[0, nm)` | `mid` | the shortened walk from the backward cycle's base, *through the point of interest*, to the forward cycle's base |
| `[nm, nm + nf)` | `fwd` | the good **forward** cycle |

The mid walk is shortened in **two pieces** — base-to-point and point-to-base — precisely so that
the point of interest survives as a marked interior position; shortening the whole stretch at once
would be free to excise it. Its first leg additionally takes one real step before any shortening,
which keeps the leg length at least one and hence keeps the recorded position non-negative.

## Main Definitions

- `bound` — the enumeration bound `check` calls `boundedAnnots` at, as a closed arithmetic
  expression in `P.card` and `subformulaClosureCard φ`

## Main Results

- `coherent_of_window_step` — the converse of `BiLasso.step_of_mem_window`
- `periodic_rel_of_window` — any relation holding across one full window of a three-segment
  periodic decoding holds across every consecutive pair
- `witness_pos_mem_cohWindow` — a position in `[0, nm]` lies in the derived coherence window
- `exists_annot_of_truth` — **the small-model theorem**

Argument order is **guard first**: `Formula.untl g e`, `Formula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {P : IntPresentation} {φ : Formula} {bx : Formula → Bool}

/-! ## List plumbing -/

/-- `List.getD` commutes with `List.map` when the map preserves the default. -/
theorem getD_map {α β : Type*} [Inhabited α] [Inhabited β] (f : α → β)
    (hf : f default = default) (l : List α) (i : ℕ) :
    (l.map f).getD i default = f (l.getD i default) := by
  rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD, List.getElem?_map]
  cases l[i]? with
  | none => simpa using hf.symm
  | some a => simp

/-- Reading a `List.range`-map at an in-range index returns the mapped value. -/
theorem getD_range_map {α : Type*} [Inhabited α] (n : ℕ) (g : ℕ → α) {i : ℕ} (h : i < n) :
    ((List.range n).map g).getD i default = g i := by
  have hlt : i < ((List.range n).map g).length := by simpa using h
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hlt]
  simp

@[simp]
theorem length_range_map {α : Type*} (n : ℕ) (g : ℕ → α) :
    ((List.range n).map g).length = n := by simp

/-! ## The two decodings agree under projection -/

/-- The state component of a decoded datum is the decoded state. -/
theorem stateOf_unrollOf (bD mD fD : List (PigeonState P φ)) (t : ℤ) :
    stateOf (Periodic.unrollOf bD mD fD t)
      = BiLasso.unrollOf P (bD.map stateOf) (mD.map stateOf) (fD.map stateOf) t := by
  have hcyc : ∀ (l : List (PigeonState P φ)) (i : ℤ),
      stateOf (Periodic.cyc l i) = BiLasso.cyc P (l.map stateOf) i := by
    intro l i
    simp only [Periodic.cyc, BiLasso.cyc, List.length_map]
    exact (getD_map stateOf rfl l _).symm
  simp only [Periodic.unrollOf, BiLasso.unrollOf, List.length_map]
  split_ifs with h1 h2
  · exact hcyc bD t
  · exact (getD_map stateOf rfl mD _).symm
  · exact hcyc fD _

/-- The type component of a decoded datum is the decoded label. -/
theorem typeOf_unrollOf (bD mD fD : List (PigeonState P φ)) (t : ℤ) :
    typeOf (Periodic.unrollOf bD mD fD t)
      = Periodic.unrollOf (bD.map typeOf) (mD.map typeOf) (fD.map typeOf) t := by
  have hcyc : ∀ (l : List (PigeonState P φ)) (i : ℤ),
      typeOf (Periodic.cyc l i) = Periodic.cyc (l.map typeOf) i := by
    intro l i
    simp only [Periodic.cyc, List.length_map]
    exact (getD_map typeOf rfl l _).symm
  simp only [Periodic.unrollOf, List.length_map]
  split_ifs with h1 h2
  · exact hcyc bD t
  · exact (getD_map typeOf rfl mD _).symm
  · exact hcyc fD _

/-! ## The window is enough -/

/--
**The converse of `BiLasso.step_of_mem_window`.**

`coherent` is a quantifier over `Fin (|back| + 1 + |mid| + |fwd|)` routed through
`BiLasso.windowTime`, whose image is exactly `[-|back| - 1, |mid| + |fwd|)`. So a statement over
that integer interval discharges the structure field directly.

This is index bookkeeping, deliberately isolated so that the assembly below never has to touch
`Basic.lean` — which is held stable for the concurrent effective-periodic-extension work.
-/
theorem coherent_of_window_step (back mid fwd : List (Fin P.card))
    (h : ∀ t : ℤ, -(back.length : ℤ) - 1 ≤ t → t < (mid.length : ℤ) + (fwd.length : ℤ) →
        P.step (BiLasso.unrollOf P back mid fwd t)
          (BiLasso.unrollOf P back mid fwd (t + 1)) = true) :
    ∀ i : Fin (back.length + 1 + mid.length + fwd.length),
      P.step (BiLasso.unrollOf P back mid fwd (BiLasso.windowTime P back i))
        (BiLasso.unrollOf P back mid fwd (BiLasso.windowTime P back i + 1)) = true := by
  intro i
  have hi := i.isLt
  exact h _ (by simp only [BiLasso.windowTime]; omega)
    (by simp only [BiLasso.windowTime]; omega)

/--
**One full window suffices for any relation on a three-segment periodic decoding.**

Every integer reduces into `[-|back| - 1, |mid| + |fwd|)` modulo the relevant cycle length, and
the decoding depends only on the residue. This is `BiLasso.unroll_isStepPath`'s reduction, stated
once at an arbitrary carrier and an arbitrary relation so that the datum sequence can use it too —
the state sequence is not the only thing that has to step correctly at every time.
-/
theorem periodic_rel_of_window {α : Type*} [Inhabited α] {R : α → α → Prop}
    (back mid fwd : List α) (hb : back ≠ []) (hf : fwd ≠ [])
    (hw : ∀ t : ℤ, -(back.length : ℤ) - 1 ≤ t → t < (mid.length : ℤ) + (fwd.length : ℤ) →
        R (Periodic.unrollOf back mid fwd t) (Periodic.unrollOf back mid fwd (t + 1))) :
    ∀ t : ℤ, R (Periodic.unrollOf back mid fwd t) (Periodic.unrollOf back mid fwd (t + 1)) := by
  have hbl := Periodic.length_pos_int (l := back) hb
  have hfl := Periodic.length_pos_int (l := fwd) hf
  have hm : (0 : ℤ) ≤ (mid.length : ℤ) := Int.natCast_nonneg _
  intro t
  rcases (by omega : t < -1 ∨ -1 ≤ t) with hlt | hge
  · -- `t ≤ -2`: reduce modulo `|back|` into `[-|back| - 1, -1)`
    set a : ℤ := -(back.length : ℤ) - 1 with ha
    set t' : ℤ := a + (t - a) % (back.length : ℤ) with ht'
    have h0 : 0 ≤ (t - a) % (back.length : ℤ) := Int.emod_nonneg _ (by omega)
    have h1 : (t - a) % (back.length : ℤ) < (back.length : ℤ) := Int.emod_lt_of_pos _ hbl
    have hres : t' % (back.length : ℤ) = t % (back.length : ℤ) := BiLasso.reduce_emod _ a t
    have hcoh := hw t' (by omega) (by omega)
    have e1 : Periodic.unrollOf back mid fwd t' = Periodic.unrollOf back mid fwd t := by
      rw [Periodic.unrollOf_neg _ _ _ (by omega), Periodic.unrollOf_neg _ _ _ (by omega)]
      exact Periodic.cyc_congr hres
    have e2 : Periodic.unrollOf back mid fwd (t' + 1)
        = Periodic.unrollOf back mid fwd (t + 1) := by
      rw [Periodic.unrollOf_neg _ _ _ (by omega), Periodic.unrollOf_neg _ _ _ (by omega)]
      exact Periodic.cyc_congr (BiLasso.emod_succ_congr hres)
    rw [← e1, ← e2]
    exact hcoh
  rcases (by omega : t < (mid.length : ℤ) ∨ (mid.length : ℤ) ≤ t) with hmid | hmid
  · -- already inside the window
    exact hw t (by omega) (by omega)
  · -- `t ≥ |mid|`: reduce modulo `|fwd|` into `[|mid|, |mid| + |fwd|)`
    set a : ℤ := (mid.length : ℤ) with ha
    set t' : ℤ := a + (t - a) % (fwd.length : ℤ) with ht'
    have h0 : 0 ≤ (t - a) % (fwd.length : ℤ) := Int.emod_nonneg _ (by omega)
    have h1 : (t - a) % (fwd.length : ℤ) < (fwd.length : ℤ) := Int.emod_lt_of_pos _ hfl
    have hres : (t' - a) % (fwd.length : ℤ) = (t - a) % (fwd.length : ℤ) := by
      have hta : t' - a = (t - a) % (fwd.length : ℤ) := by rw [ht']; omega
      rw [hta]
      exact Int.emod_emod_of_dvd _ (dvd_refl _)
    have hcoh := hw t' (by omega) (by omega)
    have e1 : Periodic.unrollOf back mid fwd t' = Periodic.unrollOf back mid fwd t := by
      rw [Periodic.unrollOf_fwd _ _ _ (by omega), Periodic.unrollOf_fwd _ _ _ hmid]
      exact Periodic.cyc_congr hres
    have e2 : Periodic.unrollOf back mid fwd (t' + 1)
        = Periodic.unrollOf back mid fwd (t + 1) := by
      rw [Periodic.unrollOf_fwd _ _ _ (by omega), Periodic.unrollOf_fwd _ _ _ (by omega)]
      refine Periodic.cyc_congr ?_
      rw [show t' + 1 - a = (t' - a) + 1 by omega, show t + 1 - a = (t - a) + 1 by omega]
      exact BiLasso.emod_succ_congr hres
    rw [← e1, ← e2]
    exact hcoh

/-! ## Reading the three segments back off the decoding -/

/--
The `back` segment decodes to the backward cycle, read outward from time `-1`.

At `T = -1` this is the cycle's base, at `T = -|back|` its last entry, and at `T = -|back| - 1` it
wraps to the base again — which is why the cycle's own closure `qb Lb = qb 0` is a hypothesis.
-/
theorem readout_back (Lb : ℕ) (hLb : 1 ≤ Lb) (qb : ℕ → PigeonState P φ) (hcyc : qb Lb = qb 0)
    (mD fD : List (PigeonState P φ)) {T : ℤ} (h1 : -(Lb : ℤ) - 1 ≤ T) (h2 : T ≤ -1) :
    Periodic.unrollOf ((List.range Lb).map (fun i => qb (Lb - 1 - i))) mD fD T
      = qb (-1 - T).toNat := by
  rw [Periodic.unrollOf_neg _ _ _ (by omega : T < 0)]
  simp only [Periodic.cyc, length_range_map]
  rcases (by omega : T = -(Lb : ℤ) - 1 ∨ -(Lb : ℤ) ≤ T) with rfl | h3
  · have hmod : (-(Lb : ℤ) - 1) % (Lb : ℤ) = (Lb : ℤ) - 1 := by
      have h := Periodic.emod_add_mul (-(Lb : ℤ) - 1) 2 (Lb : ℤ)
      rw [← h, show -(Lb : ℤ) - 1 + 2 * (Lb : ℤ) = (Lb : ℤ) - 1 by omega]
      exact Int.emod_eq_of_lt (by omega) (by omega)
    rw [hmod, getD_range_map Lb _ (by omega : ((Lb : ℤ) - 1).toNat < Lb),
      show Lb - 1 - ((Lb : ℤ) - 1).toNat = 0 by omega,
      show (-1 - (-(Lb : ℤ) - 1)).toNat = Lb by omega, hcyc]
  · have hmod : T % (Lb : ℤ) = T + (Lb : ℤ) := by
      have h := Periodic.emod_add_mul T 1 (Lb : ℤ)
      rw [one_mul] at h
      rw [← h]
      exact Int.emod_eq_of_lt (by omega) (by omega)
    rw [hmod, getD_range_map Lb _ (by omega : (T + (Lb : ℤ)).toNat < Lb)]
    congr 1
    omega

/-- The `mid` segment decodes to the interior of the mid walk. -/
theorem readout_mid (bD fD : List (PigeonState P φ)) (nm : ℕ) (w : ℕ → PigeonState P φ)
    {T : ℤ} (h1 : 0 ≤ T) (h2 : T < (nm : ℤ)) :
    Periodic.unrollOf bD ((List.range nm).map (fun i => w (i + 1))) fD T = w (T.toNat + 1) := by
  rw [Periodic.unrollOf_mid _ _ _ h1 (by simpa using h2),
    getD_range_map nm _ (by omega : T.toNat < nm)]

/--
The `fwd` segment decodes to the forward cycle, read outward from time `|mid|`.

Stated up to and including `|mid| + Lf`, where the decoding wraps back to the cycle's base — hence
the hypothesis `pf Lf = pf 0`. That one extra position is exactly where the good cycle's last mark
can sit, so excluding it would lose a witness.
-/
theorem readout_fwd (Lf : ℕ) (hLf : 1 ≤ Lf) (pf : ℕ → PigeonState P φ) (hcyc : pf Lf = pf 0)
    (bD mD : List (PigeonState P φ)) {T : ℤ}
    (h1 : (mD.length : ℤ) ≤ T) (h2 : T ≤ (mD.length : ℤ) + (Lf : ℤ)) :
    Periodic.unrollOf bD mD ((List.range Lf).map (fun i => pf i)) T
      = pf (T - (mD.length : ℤ)).toNat := by
  rw [Periodic.unrollOf_fwd _ _ _ h1]
  simp only [Periodic.cyc, length_range_map]
  rcases (by omega : T = (mD.length : ℤ) + (Lf : ℤ) ∨ T < (mD.length : ℤ) + (Lf : ℤ)) with rfl | h3
  · have hmod : ((mD.length : ℤ) + (Lf : ℤ) - (mD.length : ℤ)) % (Lf : ℤ) = 0 := by
      rw [show (mD.length : ℤ) + (Lf : ℤ) - (mD.length : ℤ) = 0 + 1 * (Lf : ℤ) by omega,
        Periodic.emod_add_mul]
      exact Int.emod_eq_of_lt (by omega) (by omega)
    rw [hmod, getD_range_map Lf _ (by omega : (0 : ℤ).toNat < Lf),
      show ((mD.length : ℤ) + (Lf : ℤ) - (mD.length : ℤ)).toNat = Lf by omega, hcyc]
    rfl
  · have hmod : (T - (mD.length : ℤ)) % (Lf : ℤ) = T - (mD.length : ℤ) :=
      Int.emod_eq_of_lt (by omega) (by omega)
    rw [hmod, getD_range_map Lf _ (by omega : (T - (mD.length : ℤ)).toNat < Lf)]

/-! ## The bound -/

/--
The mid-segment bound: twice one full residue system.

The mid walk is shortened in two legs, each to fewer than `Nat.card (PigeonState P φ)` steps, and
the recorded segment is one shorter than their sum.
-/
def midBound (P : IntPresentation) (φ : Formula) : ℕ :=
  2 * (P.card * 2 ^ subformulaClosureCard φ)

/--
**The enumeration bound**: the length `check` calls `boundedAnnots` at.

A closed arithmetic expression in `P.card` and `subformulaClosureCard φ` — not an existentially
quantified `n`, which `check` could not consume. `Check.lean` reads *this definition*; it never
restates the arithmetic.

The maximum of the two derived bounds. The cycle term dominates whenever
`subformulaClosureCard φ ≥ 1` — which always holds, since a formula belongs to its own closure —
so in practice `bound = cycleBound`; the `max` is taken anyway so that no closure lemma is needed
here and the definition stays correct unconditionally.
-/
def bound (P : IntPresentation) (φ : Formula) : ℕ := max (cycleBound P φ) (midBound P φ)

theorem cycleBound_le_bound (P : IntPresentation) (φ : Formula) :
    cycleBound P φ ≤ bound P φ := le_max_left _ _

theorem midBound_le_bound (P : IntPresentation) (φ : Formula) :
    midBound P φ ≤ bound P φ := le_max_right _ _

theorem midBound_eq (P : IntPresentation) (φ : Formula) :
    midBound P φ = 2 * Nat.card (PigeonState P φ) := by
  rw [midBound, natCard_pigeonState]

/--
**A position in `[0, |mid|]` lies in the derived coherence window.**

This is the formal content of "the windowed shape loses nothing": the extraction delivers its
witness somewhere in `[0, |mid|]`, and `Decide.lean`'s coherence window `[-2·nb, nm + 2·nf)`
contains that interval **unconditionally**, because `nb ≥ 1` and `nf ≥ 1` (`BiLasso.back_ne`,
`BiLasso.fwd_ne`). Note that a naive `Finset.Ico 0 A.nm` would silently drop the corner
`i = A.nm`, which is exactly where the witness lands when the mid walk's second leg collapses.
-/
theorem witness_pos_mem_cohWindow (A : Annot P φ) {i : ℤ} (h0 : 0 ≤ i) (h1 : i ≤ A.nm) :
    i ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A) := by
  have hb := A.nb_pos
  have hf := A.nf_pos
  simp only [Finset.mem_Ico, cohWindowLo, cohWindowHi]
  omega

end FormalSystem.Metalogic.Decidability
