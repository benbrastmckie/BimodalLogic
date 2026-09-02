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
as though it should. `Semantics.TimeShift.timeShift_preserves_truth` (`Semantics/Truth.lean`)
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

/-! ## The small-model theorem -/

/--
**The small-model theorem, in the windowed shape.**

If a closure formula holds at *some* time of *some* total history, then one of the finitely many
annotated bi-lassos with segments bounded by `bound P φ` carries it, at a position inside that
lasso's own coherence window, over the same state.

The witness position is quantified rather than fixed at `0`, and that is forced rather than
convenient — see the module docstring and
`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase10-origin-anchoring-obstruction.lean`.
Nothing is weakened at the specification level: the predicate being decided is existential in the
time in either shape, since the hypothesis here is truth at an arbitrary `t`.

The proof compresses `τ` into three walks in the realised-datum graph and reassembles them:

- **`fwd`** is a good forward cycle through a datum recurring at arbitrarily large times;
- **`back`** is a good backward cycle through a datum recurring at arbitrarily small times;
- **`mid`** is the walk between the two, shortened in two legs so that the position of `t` survives
  as a marked interior point — and whose first leg takes one real step before shortening, so that
  the marked position is never negative.

Local coherence comes from `localCoherentSeq_of_edges` (the splice lemma) fed by
`coherentEdge_of_realizedStep`; fulfilment from `fulfilling_of_good_cycles`; the lasso's
`coherent` field from `coherent_of_window_step` fed by `realizedStep_step`.
-/
theorem exists_annot_of_truth (hbx : BoxOracleSound P bx)
    (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (t : ℤ)
    (hφ : TruthAt P.toModel τ t φ) :
    ∃ A ∈ boundedAnnots P φ bx (bound P φ),
      ∃ i ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A),
        A.lasso.unroll i = τ.states t (hτ t) ∧ φ ∈ A.label i := by
  classical
  -- ### The two good cycles
  obtain ⟨xf, hrecf⟩ := exists_recurring_datum (datum P φ τ hτ)
  obtain ⟨Lf, pf, hLf1, hLfB, hpf0, hpfL, hpfst, hpfgood⟩ := exists_good_fwd_cycle hτ xf hrecf
  obtain ⟨xb, hrecb⟩ := exists_recurring_datum (fun u => datum P φ τ hτ (-u))
  obtain ⟨Lb, qb, hLb1, hLbB, hqb0, hqbL, hqbst, hqbgood⟩ := exists_good_bwd_cycle hτ xb hrecb
  -- ### The mid walk, shortened in two legs around the point of interest
  obtain ⟨ub, hubge, hubd⟩ := hrecb (1 - t)
  have hitA : iter (SeqStep (datum P φ τ hτ)) (t - (-ub + 1)).toNat
      (datum P φ τ hτ (-ub + 1)) (datum P φ τ hτ t) := by
    have h := iter_seqStep (datum P φ τ hτ) (-ub + 1) (t - (-ub + 1)).toNat
    rwa [show -ub + 1 + (((t - (-ub + 1)).toNat : ℕ) : ℤ) = t by omega] at h
  obtain ⟨a, ha, haiter⟩ := exists_iter_lt_card (SeqStep (datum P φ τ hτ)) hitA
  obtain ⟨pa, hpa0, hpaa, hpast⟩ := exists_path_of_iter (SeqStep (datum P φ τ hτ)) a _ _ haiter
  obtain ⟨uf, hufge, hufd⟩ := hrecf (t + 1)
  have hitB : iter (SeqStep (datum P φ τ hτ)) (uf - t).toNat (datum P φ τ hτ t) xf := by
    have h := iter_seqStep (datum P φ τ hτ) t (uf - t).toNat
    rwa [show t + (((uf - t).toNat : ℕ) : ℤ) = uf by omega, hufd] at h
  obtain ⟨b, hb, hbiter⟩ := exists_iter_lt_card (SeqStep (datum P φ τ hτ)) hitB
  obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (SeqStep (datum P φ τ hτ)) b _ _ hbiter
  -- the first leg, with one real step prepended so that its length is at least one
  obtain ⟨wA, hwA⟩ : ∃ f : ℕ → PigeonState P φ,
      f = fun j => if j = 0 then xb else pa (j - 1) := ⟨_, rfl⟩
  have hwA0 : wA 0 = xb := by rw [hwA]; simp
  have hwAa : wA (a + 1) = datum P φ τ hτ t := by
    rw [hwA]; simpa using hpaa
  have hwAst : ∀ j, j < a + 1 → SeqStep (datum P φ τ hτ) (wA j) (wA (j + 1)) := by
    intro j hj
    rcases Nat.eq_zero_or_pos j with rfl | hjpos
    · rw [hwA]
      simp only [hpa0]
      exact ⟨-ub, hubd, rfl⟩
    · rw [hwA]
      simp only [if_neg (by omega : ¬ j = 0), if_neg (by omega : ¬ j + 1 = 0)]
      have := hpast (j - 1) (by omega)
      rwa [show j - 1 + 1 = j + 1 - 1 by omega] at this
  -- the whole mid walk
  obtain ⟨w, hw⟩ : ∃ f : ℕ → PigeonState P φ, f = joinPath wA pb (a + 1) := ⟨_, rfl⟩
  have hseam : wA (a + 1) = pb 0 := by rw [hwAa, hpb0]
  have hw0 : w 0 = xb := by rw [hw, joinPath_left wA pb (Nat.zero_le _), hwA0]
  have hwmark : w (a + 1) = datum P φ τ hτ t := by
    rw [hw, joinPath_left wA pb (le_refl _), hwAa]
  have hwend : w (a + 1 + b) = xf := by rw [hw, joinPath_right wA pb (a + 1) hseam b, hpbb]
  have hwst : ∀ j, j < a + 1 + b → SeqStep (datum P φ τ hτ) (w j) (w (j + 1)) := by
    rw [hw]; exact joinPath_steps wA pb (a + 1) b hseam hwAst hpbst
  -- ### The three segments
  obtain ⟨nm, hnm⟩ : ∃ n : ℕ, n = a + b := ⟨_, rfl⟩
  have hnmw : w (nm + 1) = xf := by rw [hnm, show a + b + 1 = a + 1 + b by omega, hwend]
  have hnmst : ∀ j, j < nm + 1 → SeqStep (datum P φ τ hτ) (w j) (w (j + 1)) := by
    rw [hnm, show a + b + 1 = a + 1 + b by omega]; exact hwst
  obtain ⟨bD, hbD⟩ : ∃ l : List (PigeonState P φ),
      l = (List.range Lb).map (fun i => qb (Lb - 1 - i)) := ⟨_, rfl⟩
  obtain ⟨mD, hmD⟩ : ∃ l : List (PigeonState P φ),
      l = (List.range nm).map (fun i => w (i + 1)) := ⟨_, rfl⟩
  obtain ⟨fD, hfD⟩ : ∃ l : List (PigeonState P φ),
      l = (List.range Lf).map (fun i => pf i) := ⟨_, rfl⟩
  have hbDlen : bD.length = Lb := by rw [hbD, length_range_map]
  have hmDlen : mD.length = nm := by rw [hmD, length_range_map]
  have hfDlen : fD.length = Lf := by rw [hfD, length_range_map]
  -- ### Reading the decoding back off the three walks
  have hback : ∀ T : ℤ, -(Lb : ℤ) - 1 ≤ T → T ≤ -1 →
      Periodic.unrollOf bD mD fD T = qb (-1 - T).toNat := by
    intro T h1 h2
    rw [hbD]
    exact readout_back Lb hLb1 qb (by rw [hqbL, hqb0]) mD fD h1 h2
  have hfwd : ∀ T : ℤ, (nm : ℤ) ≤ T → T ≤ (nm : ℤ) + (Lf : ℤ) →
      Periodic.unrollOf bD mD fD T = pf (T - (nm : ℤ)).toNat := by
    intro T h1 h2
    rw [hfD]
    have hr := readout_fwd Lf hLf1 pf (by rw [hpfL, hpf0]) bD mD (T := T)
      (by rw [hmDlen]; exact h1) (by rw [hmDlen]; exact h2)
    rwa [hmDlen] at hr
  have hmidall : ∀ T : ℤ, -1 ≤ T → T ≤ (nm : ℤ) →
      Periodic.unrollOf bD mD fD T = w (T + 1).toNat := by
    intro T h1 h2
    rcases (by omega : T = -1 ∨ (0 ≤ T ∧ T < (nm : ℤ)) ∨ T = (nm : ℤ)) with rfl | ⟨h3, h4⟩ | rfl
    · rw [hback (-1) (by omega) (by omega),
        show (-1 - (-1 : ℤ)).toNat = 0 by omega, show ((-1 : ℤ) + 1).toNat = 0 by omega,
        hqb0, hw0]
    · rw [hmD, readout_mid bD fD nm w h3 h4]
      congr 1
      omega
    · rw [hfwd (nm : ℤ) (by omega) (by omega), show ((nm : ℤ) - (nm : ℤ)).toNat = 0 by omega,
        hpf0, show (((nm : ℤ)) + 1).toNat = nm + 1 by omega, hnmw]
  -- ### Every consecutive pair of decoded data is a realised edge
  have hbDne : bD ≠ [] := by
    intro hnil; rw [hnil] at hbDlen; simp at hbDlen; omega
  have hfDne : fD ≠ [] := by
    intro hnil; rw [hnil] at hfDlen; simp at hfDlen; omega
  have hEstep : ∀ T : ℤ,
      RealizedStep P φ τ hτ (Periodic.unrollOf bD mD fD T)
        (Periodic.unrollOf bD mD fD (T + 1)) := by
    refine periodic_rel_of_window bD mD fD hbDne hfDne ?_
    intro T h1 h2
    rw [hbDlen] at h1
    rw [hmDlen, hfDlen] at h2
    rcases (by omega : T ≤ -2 ∨ (-1 ≤ T ∧ T ≤ (nm : ℤ) - 1) ∨ (nm : ℤ) ≤ T) with h3 | ⟨h3, h4⟩ | h3
    · rw [hback T (by omega) (by omega), hback (T + 1) (by omega) (by omega),
        show (-1 - T).toNat = (-1 - (T + 1)).toNat + 1 by omega]
      exact hqbst (-1 - (T + 1)).toNat (by omega)
    · rw [hmidall T (by omega) (by omega), hmidall (T + 1) (by omega) (by omega),
        show (T + 1 + 1).toNat = (T + 1).toNat + 1 by omega]
      exact hnmst (T + 1).toNat (by omega)
    · rw [hfwd T (by omega) (by omega), hfwd (T + 1) (by omega) (by omega),
        show (T + 1 - (nm : ℤ)).toNat = (T - (nm : ℤ)).toNat + 1 by omega]
      exact hpfst (T - (nm : ℤ)).toNat (by omega)
  -- ### Assemble the annotated bi-lasso
  have hbackne : bD.map stateOf ≠ [] := by
    intro hnil
    have hl : (bD.map stateOf).length = Lb := by rw [List.length_map, hbDlen]
    rw [hnil] at hl; simp at hl; omega
  have hfwdne : fD.map stateOf ≠ [] := by
    intro hnil
    have hl : (fD.map stateOf).length = Lf := by rw [List.length_map, hfDlen]
    rw [hnil] at hl; simp at hl; omega
  have hcoh : ∀ i : Fin ((bD.map stateOf).length + 1 + (mD.map stateOf).length +
        (fD.map stateOf).length),
      P.step (BiLasso.unrollOf P (bD.map stateOf) (mD.map stateOf) (fD.map stateOf)
          (BiLasso.windowTime P (bD.map stateOf) i))
        (BiLasso.unrollOf P (bD.map stateOf) (mD.map stateOf) (fD.map stateOf)
          (BiLasso.windowTime P (bD.map stateOf) i + 1)) = true := by
    refine coherent_of_window_step _ _ _ (fun T _ _ => ?_)
    have hs := realizedStep_step (hEstep T)
    rwa [stateOf_unrollOf, stateOf_unrollOf] at hs
  obtain ⟨A, hA⟩ : ∃ A : Annot P φ, A =
      { lasso := ⟨bD.map stateOf, mD.map stateOf, fD.map stateOf, hbackne, hfwdne, hcoh⟩
        backLab := bD.map typeOf
        midLab := mD.map typeOf
        fwdLab := fD.map typeOf
        backLab_length := by rw [List.length_map, List.length_map]
        midLab_length := by rw [List.length_map, List.length_map]
        fwdLab_length := by rw [List.length_map, List.length_map]
        label_sub := by
          intro S hS
          simp only [List.mem_append, List.mem_map] at hS
          rcases hS with (⟨x, -, rfl⟩ | ⟨x, -, rfl⟩) | ⟨x, -, rfl⟩ <;> exact typeOf_subset x } :=
    ⟨_, rfl⟩
  -- the two decodings, read off the datum decoding
  have hAst : ∀ T : ℤ, A.lasso.unroll T = stateOf (Periodic.unrollOf bD mD fD T) := by
    intro T; rw [hA, stateOf_unrollOf]; rfl
  have hAlab : ∀ T : ℤ, A.label T = typeOf (Periodic.unrollOf bD mD fD T) := by
    intro T; rw [hA, typeOf_unrollOf]; rfl
  have hAnb : A.lasso.back.length = Lb := by rw [hA, List.length_map, hbDlen]
  have hAnm : A.lasso.mid.length = nm := by rw [hA, List.length_map, hmDlen]
  have hAnf : A.lasso.fwd.length = Lf := by rw [hA, List.length_map, hfDlen]
  -- ### Local coherence, from the splice lemma
  have hloc : LocalCoherent P φ bx A := by
    rw [localCoherent_iff_seq]
    exact localCoherentSeq_of_edges (Periodic.unrollOf bD mD fD)
      (fun T => (hAst T).symm) (fun T => (hAlab T).symm)
      (fun T => coherentEdge_of_realizedStep hbx (hEstep T))
  -- ### Fulfilment, from the two good cycles
  have hful : Fulfilling P φ A := by
    rw [fulfilling_iff_seq]
    refine fulfilling_of_good_cycles (st := A.lasso.unroll) (bx := bx)
      ((localCoherent_iff_seq A).mp hloc) A.label_subset_closure
      (nb := A.nb) (nf := A.nf) (nm := A.nm) A.nb_pos A.nf_pos
      (fun T hT => A.label_sub_back_length hT) (fun T hT => A.label_add_fwd_length hT)
      ?_ ?_
    · intro g e hge
      have hlabnm : A.label A.nm = typeOf (pf 0) := by
        rw [hAlab, show A.nm = (nm : ℤ) by rw [Annot.nm, hAnm], hfwd (nm : ℤ) (by omega) (by omega),
          show ((nm : ℤ) - (nm : ℤ)).toNat = 0 by omega]
      rw [hlabnm, hpf0] at hge
      obtain ⟨j, hj, hjmem⟩ := hpfgood g e hge
      refine ⟨(nm : ℤ) + (j : ℤ) + 1, ?_, ?_, ?_⟩
      · rw [Annot.nm, hAnm]; omega
      · rw [Annot.nm, hAnm, Annot.nf, hAnf]; omega
      · rw [hAlab, hfwd _ (by omega) (by omega),
          show ((nm : ℤ) + (j : ℤ) + 1 - (nm : ℤ)).toNat = j + 1 by omega]
        exact hjmem
    · intro g e hge
      have hlabm1 : A.label (-1) = typeOf (qb 0) := by
        rw [hAlab, hback (-1) (by omega) (by omega), show (-1 - (-1 : ℤ)).toNat = 0 by omega]
      rw [hlabm1, hqb0] at hge
      obtain ⟨j, hj, hjmem⟩ := hqbgood g e hge
      refine ⟨-2 - (j : ℤ), ?_, by omega, ?_⟩
      · rw [Annot.nb, hAnb]; omega
      · rw [hAlab, hback _ (by omega) (by omega),
          show (-1 - (-2 - (j : ℤ))).toNat = j + 1 by omega]
        exact hjmem
  -- ### Membership in the bounded enumeration
  have hmem : A ∈ boundedAnnots P φ bx (bound P φ) := by
    refine mem_boundedAnnots A ?_ ?_ ?_ hloc hful
    · rw [hAnb]; exact le_trans hLbB (cycleBound_le_bound P φ)
    · rw [hAnm]
      refine le_trans ?_ (midBound_le_bound P φ)
      rw [midBound_eq]
      omega
    · rw [hAnf]; exact le_trans hLfB (cycleBound_le_bound P φ)
  -- ### The witness position
  refine ⟨A, hmem, (a : ℤ), witness_pos_mem_cohWindow A (by omega) ?_, ?_, ?_⟩
  · rw [Annot.nm, hAnm]; omega
  · rw [hAst, hmidall (a : ℤ) (by omega) (by rw [hnm]; omega),
      show ((a : ℤ) + 1).toNat = a + 1 by omega, hwmark]
    rfl
  · rw [hAlab, hmidall (a : ℤ) (by omega) (by rw [hnm]; omega),
      show ((a : ℤ) + 1).toNat = a + 1 by omega, hwmark, datum_type]
    exact mem_typeAt.mpr ⟨self_mem_subformulaClosure φ, hφ⟩

end FormalSystem.Metalogic.Decidability
