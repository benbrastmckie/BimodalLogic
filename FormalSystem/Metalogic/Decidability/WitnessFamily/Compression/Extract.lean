/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Fulfil

/-!
# One History, One Labelled Lasso

This module is the ℤ geometry of the compression half: it compresses an arbitrary world history
of an arbitrary `FrameOver intOrder` model into a genuine `LabelledLasso (closureOf (Γ ++ Del))`
whose decoded label function is locally coherent, fulfilling, bounded, and carries the history's
type at the time of interest.

## The three segments

`BiLasso/Extraction.lean`'s `exists_annot_of_truth` is the in-tree precedent for exactly this
geometry; its three-segment table is transcribed here with the state component deleted:

| lasso times | segment | source |
|---|---|---|
| `[-nb, -1]` | `back` | the good **backward** cycle, read outward from time `-1` |
| `[0, nm)` | `mid` | shortened walk: backward base → *point of interest* → forward base |
| `[nm, nm + nf)` | `fwd` | the good **forward** cycle |

The mid walk is shortened in **two pieces** — base-to-point and point-to-base — precisely so that
the point of interest survives as a marked interior position; shortening the whole stretch at
once would be free to excise it. Its first leg additionally takes one real step before any
shortening, which keeps the leg length at least one and hence keeps the recorded position
non-negative.

## Why the witness is delivered at a position, not at the origin

A `LabelledLasso`'s origin is **pinned**: `Periodic.unrollOf` decodes `back` repeated strictly
left of `0`, `mid` on `[0, |mid|)`, and `fwd` repeated at or past `|mid|`, so there is no left
prefix. A two-sided pigeonhole therefore forces the lasso's origin to sit at the *backward
repeat*, and the point of interest lands wherever the compressed mid segment puts it — not at
position `0`.

The marked position is delivered in the **closed** interval `[0, nm]`, not the half-open
`[0, nm)`: the corner `i = nm` is exactly where the witness lands when the mid walk's second leg
collapses, which is the defect `BiLasso/Extraction.lean`'s `witness_pos_mem_cohWindow` records.

## The bound is an upper bound, and that is load-bearing

Every bound below reads "segment lengths **at most** `B`", never "at least `f(|C|)`". The
consuming model checker folds `back`/`mid`/`fwd` bounds by exact modulus, so a search at bound
`n` represents exactly the periods dividing `n`: representability, not magnitude, is what the
folding decides, and a lower bound transfers nothing. `Enumerate.lean` sweeps the whole grid
`[0, B]³` for the same reason.

## Main Definitions

- `midBoundC` — the mid-segment bound: twice one full residue system
- `compressionBound` — the enumeration bound, the `max` of the two derived bounds

## Main Results

- `localCoherentSeqLab_of_edges` — **the splice lemma**, presentation-free
- `periodic_rel_of_windowC` — one full window suffices for any relation on the decoding
- `exists_labelledLasso_of_history` — **one history compresses to one bounded labelled lasso**

Argument order is **guard first**: `Formula.untl g e`, `Formula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {C : Finset Formula}

/-! ## List plumbing -/

/-- `List.getD` commutes with `List.map` when the map preserves the default. -/
theorem getD_mapC {α β : Type*} [Inhabited α] [Inhabited β] (f : α → β)
    (hf : f default = default) (l : List α) (i : ℕ) :
    (l.map f).getD i default = f (l.getD i default) := by
  rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD, List.getElem?_map]
  cases l[i]? with
  | none => simpa using hf.symm
  | some a => simp

/-- Reading a `List.range`-map at an in-range index returns the mapped value. -/
theorem getD_range_mapC {α : Type*} [Inhabited α] (n : ℕ) (g : ℕ → α) {i : ℕ} (h : i < n) :
    ((List.range n).map g).getD i default = g i := by
  have hlt : i < ((List.range n).map g).length := by simpa using h
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hlt]
  simp

/-- The type component of a decoded datum is the decoded label. -/
theorem typeOfT_unrollOf (bD mD fD : List (TypeState C)) (t : ℤ) :
    typeOfT (Periodic.unrollOf bD mD fD t)
      = Periodic.unrollOf (bD.map typeOfT) (mD.map typeOfT) (fD.map typeOfT) t := by
  have hd : typeOfT (default : TypeState C) = (default : Finset Formula) := rfl
  have hcyc : ∀ (l : List (TypeState C)) (i : ℤ),
      typeOfT (Periodic.cyc l i) = Periodic.cyc (l.map typeOfT) i := by
    intro l i
    simp only [Periodic.cyc, List.length_map]
    exact (getD_mapC typeOfT hd l _).symm
  simp only [Periodic.unrollOf, List.length_map]
  split_ifs with h1 h2
  · exact hcyc bD t
  · exact (getD_mapC typeOfT hd mD _).symm
  · exact hcyc fD _

/-! ## Arithmetic helpers

Both are pure `Int.emod` facts, restated here under `C`-suffixed names so that this module needs
no import from the presentation layer and no name collides with `WitnessFamily/Decide.lean`'s own
copies.
-/

/-- Reducing an index into an interval anchored at `a` does not change its residue. -/
theorem reduce_emodC (n a i : ℤ) : (a + (i - a) % n) % n = i % n := by
  conv_rhs => rw [show i = a + (i - a) by omega]
  rw [Int.add_emod a ((i - a) % n) n, Int.emod_emod_of_dvd _ (dvd_refl n), ← Int.add_emod]

/-- Residue equality is preserved by the successor. -/
theorem emod_succ_congrC {n x y : ℤ} (h : x % n = y % n) : (x + 1) % n = (y + 1) % n := by
  rw [Int.add_emod, h, ← Int.add_emod]

/-! ## The window is enough -/

/--
**One full window suffices for any relation on a three-segment periodic decoding.**

Every integer reduces into `[-|back| - 1, |mid| + |fwd|)` modulo the relevant cycle length, and
the decoding depends only on the residue. Stated at an arbitrary carrier and an arbitrary
relation, exactly as `BiLasso/Extraction.lean`'s `periodic_rel_of_window` is, because the datum
sequence and the label sequence both need it.
-/
theorem periodic_rel_of_windowC {α : Type*} [Inhabited α] {R : α → α → Prop}
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
    have hres : t' % (back.length : ℤ) = t % (back.length : ℤ) := reduce_emodC _ a t
    have hcoh := hw t' (by omega) (by omega)
    have e1 : Periodic.unrollOf back mid fwd t' = Periodic.unrollOf back mid fwd t := by
      rw [Periodic.unrollOf_neg _ _ _ (by omega), Periodic.unrollOf_neg _ _ _ (by omega)]
      exact Periodic.cyc_congr hres
    have e2 : Periodic.unrollOf back mid fwd (t' + 1)
        = Periodic.unrollOf back mid fwd (t + 1) := by
      rw [Periodic.unrollOf_neg _ _ _ (by omega), Periodic.unrollOf_neg _ _ _ (by omega)]
      exact Periodic.cyc_congr (emod_succ_congrC hres)
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
      exact emod_succ_congrC hres
    rw [← e1, ← e2]
    exact hcoh

/-! ## Reading the three segments back off the decoding -/

/--
The `back` segment decodes to the backward cycle, read outward from time `-1`.

At `T = -1` this is the cycle's base, at `T = -|back|` its last entry, and at `T = -|back| - 1` it
wraps to the base again — which is why the cycle's own closure `qb Lb = qb 0` is a hypothesis.
-/
theorem readout_backC {α : Type*} [Inhabited α] (Lb : ℕ) (hLb : 1 ≤ Lb) (qb : ℕ → α)
    (hcyc : qb Lb = qb 0) (mD fD : List α) {T : ℤ} (h1 : -(Lb : ℤ) - 1 ≤ T) (h2 : T ≤ -1) :
    Periodic.unrollOf ((List.range Lb).map (fun i => qb (Lb - 1 - i))) mD fD T
      = qb (-1 - T).toNat := by
  rw [Periodic.unrollOf_neg _ _ _ (by omega : T < 0)]
  simp only [Periodic.cyc, List.length_map, List.length_range]
  rcases (by omega : T = -(Lb : ℤ) - 1 ∨ -(Lb : ℤ) ≤ T) with rfl | h3
  · have hmod : (-(Lb : ℤ) - 1) % (Lb : ℤ) = (Lb : ℤ) - 1 := by
      have h := Periodic.emod_add_mul (-(Lb : ℤ) - 1) 2 (Lb : ℤ)
      rw [← h, show -(Lb : ℤ) - 1 + 2 * (Lb : ℤ) = (Lb : ℤ) - 1 by omega]
      exact Int.emod_eq_of_lt (by omega) (by omega)
    rw [hmod, getD_range_mapC Lb _ (by omega : ((Lb : ℤ) - 1).toNat < Lb),
      show Lb - 1 - ((Lb : ℤ) - 1).toNat = 0 by omega,
      show (-1 - (-(Lb : ℤ) - 1)).toNat = Lb by omega, hcyc]
  · have hmod : T % (Lb : ℤ) = T + (Lb : ℤ) := by
      have h := Periodic.emod_add_mul T 1 (Lb : ℤ)
      rw [one_mul] at h
      rw [← h]
      exact Int.emod_eq_of_lt (by omega) (by omega)
    rw [hmod, getD_range_mapC Lb _ (by omega : (T + (Lb : ℤ)).toNat < Lb)]
    congr 1
    omega

/-- The `mid` segment decodes to the interior of the mid walk. -/
theorem readout_midC {α : Type*} [Inhabited α] (bD fD : List α) (nm : ℕ) (w : ℕ → α)
    {T : ℤ} (h1 : 0 ≤ T) (h2 : T < (nm : ℤ)) :
    Periodic.unrollOf bD ((List.range nm).map (fun i => w (i + 1))) fD T = w (T.toNat + 1) := by
  rw [Periodic.unrollOf_mid _ _ _ h1 (by simpa using h2),
    getD_range_mapC nm _ (by omega : T.toNat < nm)]

/--
The `fwd` segment decodes to the forward cycle, read outward from time `|mid|`.

Stated up to and including `|mid| + Lf`, where the decoding wraps back to the cycle's base — hence
the hypothesis `pf Lf = pf 0`. That one extra position is exactly where the good cycle's last
mark can sit, so excluding it would lose a witness.
-/
theorem readout_fwdC {α : Type*} [Inhabited α] (Lf : ℕ) (hLf : 1 ≤ Lf) (pf : ℕ → α)
    (hcyc : pf Lf = pf 0) (bD mD : List α) {T : ℤ}
    (h1 : (mD.length : ℤ) ≤ T) (h2 : T ≤ (mD.length : ℤ) + (Lf : ℤ)) :
    Periodic.unrollOf bD mD ((List.range Lf).map (fun i => pf i)) T
      = pf (T - (mD.length : ℤ)).toNat := by
  rw [Periodic.unrollOf_fwd _ _ _ h1]
  simp only [Periodic.cyc, List.length_map, List.length_range]
  rcases (by omega : T = (mD.length : ℤ) + (Lf : ℤ) ∨ T < (mD.length : ℤ) + (Lf : ℤ)) with rfl | h3
  · have hmod : ((mD.length : ℤ) + (Lf : ℤ) - (mD.length : ℤ)) % (Lf : ℤ) = 0 := by
      rw [show (mD.length : ℤ) + (Lf : ℤ) - (mD.length : ℤ) = 0 + 1 * (Lf : ℤ) by omega,
        Periodic.emod_add_mul]
      exact Int.emod_eq_of_lt (by omega) (by omega)
    rw [hmod, getD_range_mapC Lf _ (by omega : (0 : ℤ).toNat < Lf),
      show ((mD.length : ℤ) + (Lf : ℤ) - (mD.length : ℤ)).toNat = Lf by omega, hcyc]
    rfl
  · have hmod : (T - (mD.length : ℤ)) % (Lf : ℤ) = T - (mD.length : ℤ) :=
      Int.emod_eq_of_lt (by omega) (by omega)
    rw [hmod, getD_range_mapC Lf _ (by omega : (T - (mD.length : ℤ)).toNat < Lf)]

/-! ## The splice lemma, presentation-free -/

/--
**A label sequence whose every consecutive pair is realised by the model is locally coherent.**

`BiLasso/Realized.lean`'s `localCoherentSeq_of_edges` with the atom clause and the state sequence
deleted. The reason cutting and pasting is sound is unchanged and worth restating: every clause
of `LocalCoherentSeqLab` at a position `t` reads only

- that position's label (`bot`, `imp`, `box`),
- the label one step to the right (`untl`),
- the label one step to the left (`snce`),

and nothing else. No clause reaches two steps away and no clause mentions `t` itself. So a
sequence assembled by jumping from a model time `u` to a model time `v + 1` whenever the types
agree still satisfies every clause: the seam edge is literally an edge the history realised.
-/
theorem localCoherentSeqLab_of_edges {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (bx : Formula → Bool)
    (hbx : ∀ χ : Formula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) (lab : ℤ → Finset Formula)
    (hedge : ∀ T : ℤ, ∃ u : ℤ,
      lab T = typeAtM M Γ Del τ u ∧ lab (T + 1) = typeAtM M Γ Del τ (u + 1)) :
    LocalCoherentSeqLab Γ Del bx lab := by
  have hmodel := typeAtM_localCoherentSeqLab M Γ Del bx hbx τ
  intro t
  obtain ⟨u, hu0, hu1⟩ := hedge t
  obtain ⟨v, hv0, hv1⟩ := hedge (t - 1)
  rw [show t - 1 + 1 = t by omega] at hv1
  obtain ⟨hbot, himp, hbox, huntl, -⟩ := hmodel u
  obtain ⟨-, -, -, -, hsnce⟩ := hmodel (v + 1)
  rw [show v + 1 - 1 = v by omega] at hsnce
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · rw [hu0]; exact hbot
  · rw [hu0]; exact himp
  · rw [hu0]; exact hbox
  · rw [hu0, hu1]; exact huntl
  · rw [hv1, hv0]; exact hsnce

/-! ## The bounds -/

/--
The mid-segment bound: twice one full residue system.

The mid walk is shortened in two legs, each to fewer than `Nat.card (TypeState C)` steps, and the
recorded segment is one shorter than their sum.
-/
def midBoundC (C : Finset Formula) : ℕ := 2 * 2 ^ C.card

theorem midBoundC_eq (C : Finset Formula) :
    midBoundC C = 2 * Nat.card (TypeState C) := by
  rw [midBoundC, natCard_typeState]

/--
**The enumeration bound**: the length `cands` sweeps the grid up to.

The maximum of the two derived bounds, taken unconditionally exactly as
`BiLasso/Extraction.lean`'s `bound` is, so that no closure-cardinality lemma is needed here and
the definition stays correct with no side condition.
-/
def compressionBound (Γ Del : Context) : ℕ :=
  max (cycleBoundC (closureOf (Γ ++ Del))) (midBoundC (closureOf (Γ ++ Del)))

theorem cycleBoundC_le_compressionBound (Γ Del : Context) :
    cycleBoundC (closureOf (Γ ++ Del)) ≤ compressionBound Γ Del := le_max_left _ _

theorem midBoundC_le_compressionBound (Γ Del : Context) :
    midBoundC (closureOf (Γ ++ Del)) ≤ compressionBound Γ Del := le_max_right _ _

/-! ## One history to one labelled lasso -/

/--
**One history compresses to one bounded labelled lasso.**

From an arbitrary world history `τ` of an arbitrary `FrameOver intOrder` model and an arbitrary
time `t`, produce a `LabelledLasso (closureOf (Γ ++ Del))` with all three segments bounded by
`compressionBound Γ Del`, whose decoded label function is locally coherent and fulfilling, and
which carries `τ`'s type at `t` at a position in the closed interval `[0, nm]`.

The proof compresses `τ` into three walks in the type graph and reassembles them:

- **`fwd`** is a good forward cycle through a type recurring at arbitrarily large times;
- **`back`** is a good backward cycle through a type recurring at arbitrarily small times,
  obtained from the *same* generic construction at the reversed sequence `fun u => d (-u)`;
- **`mid`** is the walk between the two, shortened in two legs so that the position of `t`
  survives as a marked interior point — and whose first leg takes one real step before
  shortening, so that the marked position is never negative.

Local coherence comes from `localCoherentSeqLab_of_edges` fed by `periodic_rel_of_windowC`;
fulfilment from `fulfillingSeqLab_of_good_cycles`.
-/
theorem exists_labelledLasso_of_history_realized {F : FrameOver intOrder}
    (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (bx : Formula → Bool)
    (hbx : ∀ χ : Formula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ∃ (Λ : LabelledLasso (closureOf (Γ ++ Del))) (i : ℤ),
      Λ.back.length ≤ compressionBound Γ Del ∧
      Λ.mid.length ≤ compressionBound Γ Del ∧
      Λ.fwd.length ≤ compressionBound Γ Del ∧
      0 ≤ i ∧ i ≤ Λ.nm ∧
      Λ.lab i = typeAtM M Γ Del τ t ∧
      LocalCoherentSeqLab Γ Del bx Λ.lab ∧ FulfillingSeqLab Λ.lab ∧
      (∀ j : ℤ, ∃ u : ℤ, Λ.lab j = typeAtM M Γ Del τ u) := by
  classical
  set C : Finset Formula := closureOf (Γ ++ Del) with hC
  -- ### The type sequence of the history, as a datum sequence
  set d : ℤ → TypeState C := fun u =>
    ⟨typeAtM M Γ Del τ u, Finset.mem_powerset.mpr (typeAtM_subset M Γ Del τ u)⟩ with hd
  have hdtype : ∀ u : ℤ, typeOfT (d u) = typeAtM M Γ Del τ u := fun _ => rfl
  have hful := typeAtM_fulfillingSeqLab (M := M) Γ Del τ
  -- ### The two good cycles
  have hfulf : ∀ (u : ℤ) (f e : Formula), f ∈ (d u).1 → untlEventT f = some e →
      ∃ s : ℤ, u < s ∧ e ∈ (d s).1 := by
    intro u f e hfm hev
    obtain ⟨g, rfl⟩ := untlEventT_eq_some hev
    obtain ⟨s, hs, hes, -⟩ := hful.1 u g e hfm
    exact ⟨s, hs, hes⟩
  have hfulb : ∀ (u : ℤ) (f e : Formula), f ∈ (d (-u)).1 → snceEventT f = some e →
      ∃ s : ℤ, u < s ∧ e ∈ (d (-s)).1 := by
    intro u f e hfm hev
    obtain ⟨g, rfl⟩ := snceEventT_eq_some hev
    obtain ⟨s, hs, hes, -⟩ := hful.2 (-u) g e hfm
    refine ⟨-s, by omega, ?_⟩
    rw [show -(-s) = s by omega]
    exact hes
  obtain ⟨xf, hrecf⟩ := exists_recurring_typeState d
  obtain ⟨Lf, pf, hLf1, hLfB, hpf0, hpfL, hpfst, hpfgood⟩ :=
    exists_good_cycle_of_typeSeq C d untlEventT xf hrecf hfulf
  obtain ⟨xb, hrecb⟩ := exists_recurring_typeState (fun u => d (-u))
  obtain ⟨Lb, qb, hLb1, hLbB, hqb0, hqbL, hqbst', hqbgood⟩ :=
    exists_good_cycle_of_typeSeq C (fun u => d (-u)) snceEventT xb hrecb hfulb
  -- the backward cycle's steps, read in the forward direction
  have hqbst : ∀ j, j < Lb → SeqStepT d (qb (j + 1)) (qb j) := by
    intro j hj
    obtain ⟨u, hu1, hu2⟩ := hqbst' j hj
    refine ⟨-u - 1, ?_, ?_⟩
    · rw [← hu2]; congr 1; omega
    · rw [← hu1]; congr 1; omega
  -- ### The mid walk, shortened in two legs around the point of interest
  obtain ⟨ub, hubge, hubd⟩ := hrecb (1 - t)
  have hitA : iter (SeqStepT d) (t - (-ub + 1)).toNat (d (-ub + 1)) (d t) := by
    have h := iter_seqStepT d (-ub + 1) (t - (-ub + 1)).toNat
    rwa [show -ub + 1 + (((t - (-ub + 1)).toNat : ℕ) : ℤ) = t by omega] at h
  obtain ⟨a, ha, haiter⟩ := exists_iterT_lt_card (SeqStepT d) hitA
  obtain ⟨pa, hpa0, hpaa, hpast⟩ := exists_path_of_iter (SeqStepT d) a _ _ haiter
  obtain ⟨uf, hufge, hufd⟩ := hrecf (t + 1)
  have hitB : iter (SeqStepT d) (uf - t).toNat (d t) xf := by
    have h := iter_seqStepT d t (uf - t).toNat
    rwa [show t + (((uf - t).toNat : ℕ) : ℤ) = uf by omega, hufd] at h
  obtain ⟨b, hb, hbiter⟩ := exists_iterT_lt_card (SeqStepT d) hitB
  obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (SeqStepT d) b _ _ hbiter
  -- the first leg, with one real step prepended so that its length is at least one
  obtain ⟨wA, hwA⟩ : ∃ f : ℕ → TypeState C,
      f = fun j => if j = 0 then xb else pa (j - 1) := ⟨_, rfl⟩
  have hwA0 : wA 0 = xb := by rw [hwA]; simp
  have hwAa : wA (a + 1) = d t := by rw [hwA]; simpa using hpaa
  have hwAst : ∀ j, j < a + 1 → SeqStepT d (wA j) (wA (j + 1)) := by
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
  obtain ⟨w, hw⟩ : ∃ f : ℕ → TypeState C, f = joinPathT wA pb (a + 1) := ⟨_, rfl⟩
  have hseam : wA (a + 1) = pb 0 := by rw [hwAa, hpb0]
  have hw0 : w 0 = xb := by rw [hw, joinPathT_left wA pb (Nat.zero_le _), hwA0]
  have hwmark : w (a + 1) = d t := by rw [hw, joinPathT_left wA pb (le_refl _), hwAa]
  have hwend : w (a + 1 + b) = xf := by rw [hw, joinPathT_right wA pb (a + 1) hseam b, hpbb]
  have hwst : ∀ j, j < a + 1 + b → SeqStepT d (w j) (w (j + 1)) := by
    rw [hw]; exact joinPathT_steps wA pb (a + 1) b hseam hwAst hpbst
  -- ### The three segments
  obtain ⟨nm, hnm⟩ : ∃ n : ℕ, n = a + b := ⟨_, rfl⟩
  have hnmw : w (nm + 1) = xf := by rw [hnm, show a + b + 1 = a + 1 + b by omega, hwend]
  have hnmst : ∀ j, j < nm + 1 → SeqStepT d (w j) (w (j + 1)) := by
    rw [hnm, show a + b + 1 = a + 1 + b by omega]; exact hwst
  obtain ⟨bD, hbD⟩ : ∃ l : List (TypeState C),
      l = (List.range Lb).map (fun i => qb (Lb - 1 - i)) := ⟨_, rfl⟩
  obtain ⟨mD, hmD⟩ : ∃ l : List (TypeState C),
      l = (List.range nm).map (fun i => w (i + 1)) := ⟨_, rfl⟩
  obtain ⟨fD, hfD⟩ : ∃ l : List (TypeState C),
      l = (List.range Lf).map (fun i => pf i) := ⟨_, rfl⟩
  have hbDlen : bD.length = Lb := by rw [hbD]; simp
  have hmDlen : mD.length = nm := by rw [hmD]; simp
  have hfDlen : fD.length = Lf := by rw [hfD]; simp
  -- ### Reading the decoding back off the three walks
  have hback : ∀ T : ℤ, -(Lb : ℤ) - 1 ≤ T → T ≤ -1 →
      Periodic.unrollOf bD mD fD T = qb (-1 - T).toNat := by
    intro T h1 h2
    rw [hbD]
    exact readout_backC Lb hLb1 qb (by rw [hqbL, hqb0]) mD fD h1 h2
  have hfwd : ∀ T : ℤ, (nm : ℤ) ≤ T → T ≤ (nm : ℤ) + (Lf : ℤ) →
      Periodic.unrollOf bD mD fD T = pf (T - (nm : ℤ)).toNat := by
    intro T h1 h2
    rw [hfD]
    have hr := readout_fwdC Lf hLf1 pf (by rw [hpfL, hpf0]) bD mD (T := T)
      (by rw [hmDlen]; exact h1) (by rw [hmDlen]; exact h2)
    rwa [hmDlen] at hr
  have hmidall : ∀ T : ℤ, -1 ≤ T → T ≤ (nm : ℤ) →
      Periodic.unrollOf bD mD fD T = w (T + 1).toNat := by
    intro T h1 h2
    rcases (by omega : T = -1 ∨ (0 ≤ T ∧ T < (nm : ℤ)) ∨ T = (nm : ℤ)) with rfl | ⟨h3, h4⟩ | rfl
    · rw [hback (-1) (by omega) (by omega),
        show (-1 - (-1 : ℤ)).toNat = 0 by omega, show ((-1 : ℤ) + 1).toNat = 0 by omega,
        hqb0, hw0]
    · rw [hmD, readout_midC bD fD nm w h3 h4]
      congr 1
      omega
    · rw [hfwd (nm : ℤ) (by omega) (by omega), show ((nm : ℤ) - (nm : ℤ)).toNat = 0 by omega,
        hpf0, show (((nm : ℤ)) + 1).toNat = nm + 1 by omega, hnmw]
  -- ### Every consecutive pair of decoded data is realised by the history
  have hbDne : bD ≠ [] := by
    intro hnil; rw [hnil] at hbDlen; simp at hbDlen; omega
  have hfDne : fD ≠ [] := by
    intro hnil; rw [hnil] at hfDlen; simp at hfDlen; omega
  have hEstep : ∀ T : ℤ,
      SeqStepT d (Periodic.unrollOf bD mD fD T) (Periodic.unrollOf bD mD fD (T + 1)) := by
    refine periodic_rel_of_windowC bD mD fD hbDne hfDne ?_
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
  -- ### Assemble the labelled lasso
  have hbackne : bD.map typeOfT ≠ [] := by
    intro hnil
    have hl : (bD.map typeOfT).length = Lb := by rw [List.length_map, hbDlen]
    rw [hnil] at hl; simp at hl; omega
  have hfwdne : fD.map typeOfT ≠ [] := by
    intro hnil
    have hl : (fD.map typeOfT).length = Lf := by rw [List.length_map, hfDlen]
    rw [hnil] at hl; simp at hl; omega
  obtain ⟨Λ, hΛ⟩ : ∃ Λ : LabelledLasso C, Λ =
      { back := bD.map typeOfT
        mid := mD.map typeOfT
        fwd := fD.map typeOfT
        back_ne := hbackne
        fwd_ne := hfwdne
        label_sub := by
          intro S hS
          simp only [List.mem_append, List.mem_map] at hS
          rcases hS with (⟨x, -, rfl⟩ | ⟨x, -, rfl⟩) | ⟨x, -, rfl⟩ <;> exact typeOfT_subset x } :=
    ⟨_, rfl⟩
  have hΛlab : ∀ T : ℤ, Λ.lab T = typeOfT (Periodic.unrollOf bD mD fD T) := by
    intro T; rw [hΛ, LabelledLasso.lab_def, typeOfT_unrollOf]
  have hΛnb : Λ.back.length = Lb := by rw [hΛ, List.length_map, hbDlen]
  have hΛnm : Λ.mid.length = nm := by rw [hΛ, List.length_map, hmDlen]
  have hΛnf : Λ.fwd.length = Lf := by rw [hΛ, List.length_map, hfDlen]
  -- ### Local coherence, from the splice lemma
  have hloc : LocalCoherentSeqLab Γ Del bx Λ.lab := by
    refine localCoherentSeqLab_of_edges M Γ Del bx hbx τ Λ.lab (fun T => ?_)
    obtain ⟨u, hu1, hu2⟩ := hEstep T
    exact ⟨u, by rw [hΛlab, ← hu1, hdtype], by rw [hΛlab, ← hu2, hdtype]⟩
  -- ### The three segment lengths, as integers
  have hnbZ : Λ.nb = (Lb : ℤ) := by simp only [LabelledLasso.nb, hΛnb]
  have hnmZ : Λ.nm = (nm : ℤ) := by simp only [LabelledLasso.nm, hΛnm]
  have hnfZ : Λ.nf = (Lf : ℤ) := by simp only [LabelledLasso.nf, hΛnf]
  -- ### Fulfilment, from the two good cycles
  have hfulΛ : FulfillingSeqLab Λ.lab := by
    refine fulfillingSeqLab_of_good_cycles (bx := bx) hloc (fun T => Λ.lab_subset T)
      (nb := Λ.nb) (nf := Λ.nf) (nm := Λ.nm) Λ.nb_pos Λ.nf_pos
      (fun T hT => Λ.lab_sub_back_length hT) (fun T hT => Λ.lab_add_fwd_length hT) ?_ ?_
    · intro g e hge
      have hlabnm : Λ.lab Λ.nm = typeOfT (pf 0) := by
        rw [hnmZ, hΛlab, hfwd (nm : ℤ) (le_refl _) (by omega),
          show ((nm : ℤ) - (nm : ℤ)).toNat = 0 by omega]
      rw [hlabnm, hpf0] at hge
      obtain ⟨j, hj, hjmem⟩ := hpfgood _ e hge rfl
      refine ⟨(nm : ℤ) + (j : ℤ) + 1, by rw [hnmZ]; omega, by rw [hnmZ, hnfZ]; omega, ?_⟩
      rw [hΛlab, hfwd _ (by omega) (by omega),
        show ((nm : ℤ) + (j : ℤ) + 1 - (nm : ℤ)).toNat = j + 1 by omega]
      exact hjmem
    · intro g e hge
      have hlabm1 : Λ.lab (-1) = typeOfT (qb 0) := by
        rw [hΛlab, hback (-1) (by omega) (by omega), show (-1 - (-1 : ℤ)).toNat = 0 by omega]
      rw [hlabm1, hqb0] at hge
      obtain ⟨j, hj, hjmem⟩ := hqbgood _ e hge rfl
      refine ⟨-2 - (j : ℤ), by rw [hnbZ]; omega, by omega, ?_⟩
      rw [hΛlab, hback _ (by omega) (by omega),
        show (-1 - (-2 - (j : ℤ))).toNat = j + 1 by omega]
      exact hjmem
  -- ### The bounds
  have hcard : Nat.card (TypeState C) = 2 ^ C.card := natCard_typeState C
  have hcbU : (2 * C.card + 1) * 2 ^ C.card ≤ compressionBound Γ Del := by
    have h : cycleBoundC C ≤ compressionBound Γ Del := by
      rw [hC]; exact cycleBoundC_le_compressionBound Γ Del
    exact h
  have hmbU : 2 * 2 ^ C.card ≤ compressionBound Γ Del := by
    have h : midBoundC C ≤ compressionBound Γ Del := by
      rw [hC]; exact midBoundC_le_compressionBound Γ Del
    exact h
  have ha' : a < 2 ^ C.card := by rwa [hcard] at ha
  have hb' : b < 2 ^ C.card := by rwa [hcard] at hb
  -- ### The witness position
  have hreal : ∀ j : ℤ, ∃ u : ℤ, Λ.lab j = typeAtM M Γ Del τ u := by
    intro j
    obtain ⟨u, hu1, -⟩ := hEstep j
    exact ⟨u, by rw [hΛlab, ← hu1, hdtype]⟩
  refine ⟨Λ, (a : ℤ), ?_, ?_, ?_, by omega, ?_, ?_, hloc, hfulΛ, hreal⟩
  · rw [hΛnb]; exact le_trans hLbB hcbU
  · rw [hΛnm]; omega
  · rw [hΛnf]; exact le_trans hLfB hcbU
  · rw [hnmZ]; omega
  · rw [hΛlab, hmidall (a : ℤ) (by omega) (by rw [hnm]; omega),
      show ((a : ℤ) + 1).toNat = a + 1 by omega, hwmark, hdtype]

/--
**One history compresses to one bounded labelled lasso** — the pinned form.

`exists_labelledLasso_of_history_realized` with its last conjunct dropped. That conjunct records
that every decoded label is the type of a genuine position of the same model; it is what
`Family.lean` spends on the forward direction of `BoxFaithful`, and it is carried by the
strengthened form rather than by this one so that this statement stays exactly as the plan pins
it.
-/
theorem exists_labelledLasso_of_history {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (bx : Formula → Bool)
    (hbx : ∀ χ : Formula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ∃ (Λ : LabelledLasso (closureOf (Γ ++ Del))) (i : ℤ),
      Λ.back.length ≤ compressionBound Γ Del ∧
      Λ.mid.length ≤ compressionBound Γ Del ∧
      Λ.fwd.length ≤ compressionBound Γ Del ∧
      0 ≤ i ∧ i ≤ Λ.nm ∧
      Λ.lab i = typeAtM M Γ Del τ t ∧
      LocalCoherentSeqLab Γ Del bx Λ.lab ∧ FulfillingSeqLab Λ.lab := by
  obtain ⟨Λ, i, h1, h2, h3, h4, h5, h6, h7, h8, -⟩ :=
    exists_labelledLasso_of_history_realized M Γ Del bx hbx τ t
  exact ⟨Λ, i, h1, h2, h3, h4, h5, h6, h7, h8⟩

/--
**Transporting local coherence across a box guess that agrees on the closure.**

`LocalCoherentSeqLab`'s only use of `bx` is its box clause, which is guarded by
`Formula.box χ ∈ closureOf (Γ ++ Del)`. So two guesses agreeing on exactly those `χ` are
interchangeable. This is what lets the compression build its lassos against the (noncomputable,
unguarded) truth oracle and then hand the family the canonical, *enumerable* guess
`fun χ => decide (χ ∈ S)`.
-/
theorem localCoherentSeqLab_congr_bx {Γ Del : Context} {bx₁ bx₂ : Formula → Bool}
    {lab : ℤ → Finset Formula}
    (hagree : ∀ χ : Formula, Formula.box χ ∈ closureOf (Γ ++ Del) → bx₁ χ = bx₂ χ)
    (hco : LocalCoherentSeqLab Γ Del bx₁ lab) :
    LocalCoherentSeqLab Γ Del bx₂ lab := by
  intro t
  obtain ⟨hbot, himp, hbox, huntl, hsnce⟩ := hco t
  refine ⟨hbot, himp, fun χ hχ => ?_, huntl, hsnce⟩
  rw [hbox χ hχ, hagree χ hχ]

end FormalSystem.Metalogic.Decidability
