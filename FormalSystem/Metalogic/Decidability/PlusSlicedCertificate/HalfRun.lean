/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Tail

/-!
# Half-Runs: One-Directional Liveness from an Explicit Half-Line

`Bridge.lean`'s `live_of_mem_liveT` turns computed liveness into declarative liveness and consumes
**both** halves of `liveT`, for the reason its own docstring gives: `FwdLive` and `BwdLive` each
demand a bi-infinite run, so one half of the fixpoint cannot produce one on its own. A caller that
already *has* the other direction explicitly — as a position family on a closed half-line — needs
strictly less, and that is what this module supplies.

## What is here, and why none of it is in `Tail.lean`

Three pairs, each a mirror pair:

* **The converse of `exists_chain_of_mem_iterBack`.** `Tail.lean` makes explicit the chain that a
  membership in an iterate witnesses; a *producer* of such a membership needs the other direction,
  and a run is already a chain — its positions sit at their own slices and step along `succP`.
* **The two unrollings.** `LiveFix.lean`'s fair walk lives in the **rolled** carrier: its vertices
  carry window times reached by `nextTime` / `prevTime` wraps. Each unrolling below reads that walk
  onto the genuine time line at any fold-equivalent root. The root may be shifted for the same
  reason `bwdVertFold`'s may be — fold-equivalent times carry the same slice, hence the same
  positions and the same one-step graph — and the shift is not a convenience: it is what lets a
  caller place the walk's origin where its *own* half-line's seam is.
* **The two three-region splices.** `Tail.lean`'s `tailPos` / `headPos` splice a run, a chain and a
  run. These splice a **half-run**, a chain and a run, and that is the whole difference: the far
  region is a half-line position family rather than a *shifted* run, so no periodicity of the slice
  sequence is consumed there and the construction is available at every residue — including the
  residue `0` at which `tailPos`'s far-region shift would cross the origin and the slice congruence
  it rests on would fail.

## Main results

- `PlusSlicedCertificate.mem_iterBack_of_run` / `mem_iterFwd_of_run` — a run is a chain
- `PlusSlicedCertificate.exists_bwdHalfRun_of_mem_bwdLiveT` /
  `exists_fwdHalfRun_of_mem_fwdLiveT` — the rolled fair walk, unrolled at a fold-equivalent root
- `PlusSlicedCertificate.live_of_bwdHalf_chain_run` / `live_of_run_chain_fwdHalf` — liveness from a
  half-run, a chain, and a reference run

## Tags

plus-language · certificate · time-sliced · liveness · half-run
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## A run is a chain -/

/--
**A run's position `k` steps to the left lies in the `k`-fold leftward transfer** of any set
containing the run's position at the reference time.

The converse of `exists_chain_of_mem_iterBack`, and the only way this subtree ever *enters* an
iterate: the chain is the run itself.
-/
theorem mem_iterBack_of_run (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (t : ℤ)
    {X : Finset G.Pos} (hX : R.pos t ∈ X) :
    ∀ k : ℕ, R.pos (t - (k : ℤ)) ∈ G.iterBack t X k := by
  intro k
  induction k with
  | zero => simpa using hX
  | succ k ih =>
    have hcast : t - ((k + 1 : ℕ) : ℤ) = t - (k : ℤ) - 1 := by push_cast; omega
    rw [iterBack_succ, hcast, mem_stepBack]
    refine ⟨R.pos_mem_posAt _, R.pos (t - (k : ℤ)), ?_, ih⟩
    have h := R.pos_mem_succP (t - (k : ℤ) - 1)
    rwa [show t - (k : ℤ) - 1 + 1 = t - (k : ℤ) from by omega] at h

/-- **The mirror**: a run's position `k` steps to the right lies in the `k`-fold rightward
transfer. -/
theorem mem_iterFwd_of_run (G : PlusSlicedCertificate Γ Del) (R : G.LabRun) (t : ℤ)
    {X : Finset G.Pos} (hX : R.pos t ∈ X) :
    ∀ k : ℕ, R.pos (t + (k : ℤ)) ∈ G.iterFwd t X k := by
  intro k
  induction k with
  | zero => simpa using hX
  | succ k ih =>
    have hcast : t + ((k + 1 : ℕ) : ℤ) = t + (k : ℤ) + 1 := by push_cast; omega
    rw [iterFwd_succ, hcast, mem_stepFwd]
    exact ⟨R.pos_mem_posAt _, R.pos (t + (k : ℤ)), R.pos_mem_predP (t + (k : ℤ)), ih⟩

/-! ## Unrolling the fair walk at a fold-equivalent root -/

/--
**A backward half-run out of the computed backward fixpoint**, read at a `FoldB`-equivalent root.

`Pb k` is the position at genuine time `s' - k`: it lies at that slice, it is a `predP`-predecessor
of its neighbour, and the walk's own fairness is its backward fulfilment.
-/
theorem exists_bwdHalfRun_of_mem_bwdLiveT (G : PlusSlicedCertificate Γ Del) {s s' : ℤ}
    (hs : s ∈ G.winTimes) (hfold : G.FoldB s s') {q : G.Pos} (hq : (q, s) ∈ G.bwdLiveT) :
    ∃ Pb : ℕ → G.Pos, Pb 0 = q ∧ (∀ k : ℕ, Pb k ∈ G.posAt (s' - (k : ℤ))) ∧
      (∀ k : ℕ, Pb (k + 1) ∈ G.predP (s' - (k : ℤ)) (Pb k)) ∧
      ∀ (k : ℕ) (g e : PlusFormula), PlusFormula.snce g e ∈ (Pb k).2.1 →
        ∃ j, k < j ∧ e ∈ (Pb j).2.1 ∧ ∀ i, k < i → i < j → g ∈ (Pb i).2.1 := by
  obtain ⟨f, hf0, hfL, hfs, hfair⟩ := G.exists_bwdLive_walk hq
  have hsnd : ∀ k : ℕ, (f k).2 = G.bwdOrbit s k := by
    intro k
    induction k with
    | zero => rw [hf0]; rfl
    | succ k ih => rw [G.snd_of_mem_predT (hfs k), ih]; rfl
  refine ⟨fun k => (f k).1, by simp only [hf0], ?_, ?_, hfair⟩
  · intro k
    have h := G.fst_mem_posAt_of_mem_verts (G.bwdLiveT_subset (hfL k))
    rw [hsnd k] at h
    rwa [G.foldB_posAt (G.foldB_bwdOrbit_fold hs hfold k)] at h
  · intro k
    have h := G.fst_mem_predP_of_mem_predT (hfs k)
    rw [hsnd k] at h
    rwa [G.foldB_predP (G.foldB_bwdOrbit_fold hs hfold k)] at h

/-- **A forward half-run out of the computed forward fixpoint**, the mirror. -/
theorem exists_fwdHalfRun_of_mem_fwdLiveT (G : PlusSlicedCertificate Γ Del) {s s' : ℤ}
    (hs : s ∈ G.winTimes) (hfold : G.FoldF s s') {q : G.Pos} (hq : (q, s) ∈ G.fwdLiveT) :
    ∃ Pf : ℕ → G.Pos, Pf 0 = q ∧ (∀ k : ℕ, Pf k ∈ G.posAt (s' + (k : ℤ))) ∧
      (∀ k : ℕ, Pf (k + 1) ∈ G.succP (s' + (k : ℤ)) (Pf k)) ∧
      ∀ (k : ℕ) (g e : PlusFormula), PlusFormula.untl g e ∈ (Pf k).2.1 →
        ∃ j, k < j ∧ e ∈ (Pf j).2.1 ∧ ∀ i, k < i → i < j → g ∈ (Pf i).2.1 := by
  obtain ⟨f, hf0, hfL, hfs, hfair⟩ := G.exists_fwdLive_walk hq
  have hsnd : ∀ k : ℕ, (f k).2 = G.fwdOrbit s k := by
    intro k
    induction k with
    | zero => rw [hf0]; rfl
    | succ k ih => rw [G.snd_of_mem_succT (hfs k), ih]; rfl
  refine ⟨fun k => (f k).1, by simp only [hf0], ?_, ?_, hfair⟩
  · intro k
    have h := G.fst_mem_posAt_of_mem_verts (G.fwdLiveT_subset (hfL k))
    rw [hsnd k] at h
    rwa [G.foldF_posAt (G.foldF_fwdOrbit_fold hs hfold k)] at h
  · intro k
    have h := G.fst_mem_succP_of_mem_succT (hfs k)
    rw [hsnd k] at h
    rwa [G.foldF_succP (G.foldF_fwdOrbit_fold hs hfold k)] at h

/-! ## The two three-region splices -/

/--
**Liveness from a backward half-run, a finite chain, and a forward reference run.**

The chain runs rightward from `a` to `a + m`, where the reference run takes over; the half-run owns
everything at or left of `a`. Fulfilment is read off one region each: forward off `Rq`, which is
fulfilling to begin with, and backward off the half-run's own fairness.
-/
theorem live_of_bwdHalf_chain_run (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (a : ℤ) (m : ℕ) (Pb : ℕ → G.Pos) (c : ℕ → G.Pos) (Rq : G.LabRun)
    (hPbpos : ∀ k : ℕ, Pb k ∈ G.posAt (a - (k : ℤ)))
    (hPbstep : ∀ k : ℕ, Pb (k + 1) ∈ G.predP (a - (k : ℤ)) (Pb k))
    (hPbfair : ∀ (k : ℕ) (g e : PlusFormula), PlusFormula.snce g e ∈ (Pb k).2.1 →
      ∃ j, k < j ∧ e ∈ (Pb j).2.1 ∧ ∀ i, k < i → i < j → g ∈ (Pb i).2.1)
    (hcpos : ∀ j ≤ m, c j ∈ G.posAt (a + (j : ℤ)))
    (hcstep : ∀ j < m, c (j + 1) ∈ G.succP (a + (j : ℤ)) (c j))
    (hRqf : PlusFwdFulfilling Rq.lab)
    (h0 : Pb 0 = c 0) (hm : c m = Rq.pos (a + (m : ℤ))) :
    G.Live a (c 0) := by
  classical
  set P : ℤ → G.Pos := fun u =>
    if u < a then Pb (a - u).toNat
    else if u ≤ a + (m : ℤ) then c (u - a).toNat
    else Rq.pos u with hPdef
  have hPmid : ∀ u : ℤ, a ≤ u → u ≤ a + (m : ℤ) → P u = c (u - a).toNat := by
    intro u h1 h2
    rw [hPdef]
    simp only [if_neg (show ¬ u < a from by omega), if_pos h2]
  have hPle : ∀ u : ℤ, u ≤ a → P u = Pb (a - u).toNat := by
    intro u hu
    rcases lt_or_eq_of_le hu with h | h
    · rw [hPdef]; simp only [if_pos h]
    · have hua : a - u = 0 := by omega
      have hau : u - a = 0 := by omega
      rw [hPmid u (by omega) (by omega), hua, hau, show (0 : ℤ).toNat = 0 from rfl, h0]
  have hPge : ∀ u : ℤ, a + (m : ℤ) ≤ u → P u = Rq.pos u := by
    intro u hu
    rcases lt_or_eq_of_le hu with h | h
    · rw [hPdef]
      simp only [if_neg (show ¬ u < a from by omega),
        if_neg (show ¬ u ≤ a + (m : ℤ) from by omega)]
    · rw [hPmid u (by omega) (by omega), show u - a = (m : ℤ) from by omega,
        Int.toNat_natCast, hm, show a + (m : ℤ) = u from by omega]
  have hP : ∀ u : ℤ, P u ∈ G.posAt u := by
    intro u
    rcases le_or_gt u a with hu | hu
    · rw [hPle u hu]
      have h := hPbpos (a - u).toNat
      rwa [Int.toNat_of_nonneg (show (0 : ℤ) ≤ a - u from by omega),
        show a - (a - u) = u from by omega] at h
    · rcases le_or_gt u (a + (m : ℤ)) with hu2 | hu2
      · rw [hPmid u (by omega) hu2]
        have h := hcpos (u - a).toNat (by omega)
        rwa [Int.toNat_of_nonneg (show (0 : ℤ) ≤ u - a from by omega),
          show a + (u - a) = u from by omega] at h
      · rw [hPge u (by omega)]
        exact Rq.pos_mem_posAt u
  have hS : ∀ u : ℤ, P (u + 1) ∈ G.succP u (P u) := by
    intro u
    rcases le_or_gt (u + 1) a with hu | hu
    · have hstep := hPbstep (a - u - 1).toNat
      rw [Int.toNat_of_nonneg (show (0 : ℤ) ≤ a - u - 1 from by omega),
        show a - (a - u - 1) = u + 1 from by omega] at hstep
      have hPu : P u = Pb ((a - u - 1).toNat + 1) := by
        rw [hPle u (by omega), show (a - u).toNat = (a - u - 1).toNat + 1 from by omega]
      have hPu1 : P (u + 1) = Pb (a - u - 1).toNat := by
        rw [hPle (u + 1) hu, show a - (u + 1) = a - u - 1 from by omega]
      exact (G.mem_succP_iff_mem_predP u (P u) (P (u + 1)) (hP u) (hP (u + 1))).mpr
        (by rw [hPu, hPu1]; exact hstep)
    · rcases le_or_gt (u + 1) (a + (m : ℤ)) with hu2 | hu2
      · have hstep := hcstep (u - a).toNat (by omega)
        rw [Int.toNat_of_nonneg (show (0 : ℤ) ≤ u - a from by omega),
          show a + (u - a) = u from by omega] at hstep
        rw [hPmid u (by omega) (by omega), hPmid (u + 1) (by omega) hu2,
          show (u + 1 - a).toNat = (u - a).toNat + 1 from by omega]
        exact hstep
      · rw [hPge u (by omega), hPge (u + 1) (by omega)]
        exact Rq.pos_mem_succP u
  set R := runOfPos hbox hP hS with hR
  have hRlab : ∀ u : ℤ, R.lab u = (P u).2.1 := fun u => rfl
  have hfwd : PlusFwdFulfilling R.lab := by
    refine plusFwdFulfilling_of_ge R.coherent R.lab_sub (a + (m : ℤ)) ?_
    intro u hu g e hmem
    rw [hRlab, hPge u hu] at hmem
    obtain ⟨r, hr1, hr2, hr3⟩ := hRqf u g e hmem
    refine ⟨r, hr1, ?_, ?_⟩
    · rw [hRlab, hPge r (by omega)]; exact hr2
    · intro v hv1 hv2
      rw [hRlab, hPge v (by omega)]
      exact hr3 v hv1 hv2
  have hbwd : PlusBwdFulfilling R.lab := by
    refine plusBwdFulfilling_of_le R.coherent R.lab_sub a ?_
    intro u hu g e hmem
    rw [hRlab, hPle u hu] at hmem
    obtain ⟨j, hj1, hj2, hj3⟩ := hPbfair (a - u).toNat g e hmem
    refine ⟨a - (j : ℤ), by omega, ?_, ?_⟩
    · rw [hRlab, hPle (a - (j : ℤ)) (by omega),
        show a - (a - (j : ℤ)) = (j : ℤ) from by omega, Int.toNat_natCast]
      exact hj2
    · intro v hv1 hv2
      rw [hRlab, hPle v (by omega)]
      exact hj3 (a - v).toNat (by omega) (by omega)
  have hpos : R.pos a = c 0 := by
    rw [hR, runOfPos_pos, hPmid a le_rfl (by omega), show a - a = 0 from by omega]
    rfl
  rw [← hpos]
  exact G.live_of_path R ⟨hfwd, hbwd⟩ a

/--
**Liveness from a backward reference run, a finite chain, and a forward half-run** — the mirror.

The chain runs leftward from `b` to `b - m`, where the reference run takes over; the half-run owns
everything at or right of `b`.
-/
theorem live_of_run_chain_fwdHalf (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (b : ℤ) (m : ℕ) (Pf : ℕ → G.Pos) (c : ℕ → G.Pos) (Rp : G.LabRun)
    (hPfpos : ∀ k : ℕ, Pf k ∈ G.posAt (b + (k : ℤ)))
    (hPfstep : ∀ k : ℕ, Pf (k + 1) ∈ G.succP (b + (k : ℤ)) (Pf k))
    (hPffair : ∀ (k : ℕ) (g e : PlusFormula), PlusFormula.untl g e ∈ (Pf k).2.1 →
      ∃ j, k < j ∧ e ∈ (Pf j).2.1 ∧ ∀ i, k < i → i < j → g ∈ (Pf i).2.1)
    (hcpos : ∀ j ≤ m, c j ∈ G.posAt (b - (j : ℤ)))
    (hcstep : ∀ j < m, c (j + 1) ∈ G.predP (b - (j : ℤ)) (c j))
    (hRpf : PlusBwdFulfilling Rp.lab)
    (h0 : Pf 0 = c 0) (hm : c m = Rp.pos (b - (m : ℤ))) :
    G.Live b (c 0) := by
  classical
  set P : ℤ → G.Pos := fun u =>
    if b < u then Pf (u - b).toNat
    else if b - (m : ℤ) ≤ u then c (b - u).toNat
    else Rp.pos u with hPdef
  have hPmid : ∀ u : ℤ, b - (m : ℤ) ≤ u → u ≤ b → P u = c (b - u).toNat := by
    intro u h1 h2
    rw [hPdef]
    simp only [if_neg (show ¬ b < u from by omega), if_pos h1]
  have hPge : ∀ u : ℤ, b ≤ u → P u = Pf (u - b).toNat := by
    intro u hu
    rcases lt_or_eq_of_le hu with h | h
    · rw [hPdef]; simp only [if_pos h]
    · have hub : u - b = 0 := by omega
      have hbu : b - u = 0 := by omega
      rw [hPmid u (by omega) (by omega), hub, hbu, show (0 : ℤ).toNat = 0 from rfl, h0]
  have hPle : ∀ u : ℤ, u ≤ b - (m : ℤ) → P u = Rp.pos u := by
    intro u hu
    rcases lt_or_eq_of_le hu with h | h
    · rw [hPdef]
      simp only [if_neg (show ¬ b < u from by omega),
        if_neg (show ¬ b - (m : ℤ) ≤ u from by omega)]
    · rw [hPmid u (by omega) (by omega), show b - u = (m : ℤ) from by omega,
        Int.toNat_natCast, hm, show b - (m : ℤ) = u from by omega]
  have hP : ∀ u : ℤ, P u ∈ G.posAt u := by
    intro u
    rcases le_or_gt b u with hu | hu
    · rw [hPge u hu]
      have h := hPfpos (u - b).toNat
      rwa [Int.toNat_of_nonneg (show (0 : ℤ) ≤ u - b from by omega),
        show b + (u - b) = u from by omega] at h
    · rcases le_or_gt (b - (m : ℤ)) u with hu2 | hu2
      · rw [hPmid u hu2 (by omega)]
        have h := hcpos (b - u).toNat (by omega)
        rwa [Int.toNat_of_nonneg (show (0 : ℤ) ≤ b - u from by omega),
          show b - (b - u) = u from by omega] at h
      · rw [hPle u (by omega)]
        exact Rp.pos_mem_posAt u
  have hS : ∀ u : ℤ, P (u + 1) ∈ G.succP u (P u) := by
    intro u
    rcases le_or_gt b u with hu | hu
    · have hstep := hPfstep (u - b).toNat
      rw [Int.toNat_of_nonneg (show (0 : ℤ) ≤ u - b from by omega),
        show b + (u - b) = u from by omega] at hstep
      rw [hPge u hu, hPge (u + 1) (by omega),
        show (u + 1 - b).toNat = (u - b).toNat + 1 from by omega]
      exact hstep
    · rcases le_or_gt (b - (m : ℤ)) u with hu2 | hu2
      · have hstep := hcstep (b - u - 1).toNat (by omega)
        rw [Int.toNat_of_nonneg (show (0 : ℤ) ≤ b - u - 1 from by omega),
          show b - (b - u - 1) = u + 1 from by omega] at hstep
        have hPu : P u = c ((b - u - 1).toNat + 1) := by
          rw [hPmid u hu2 (by omega), show (b - u).toNat = (b - u - 1).toNat + 1 from by omega]
        have hPu1 : P (u + 1) = c (b - u - 1).toNat := by
          rw [hPmid (u + 1) (by omega) (by omega), show b - (u + 1) = b - u - 1 from by omega]
        exact (G.mem_succP_iff_mem_predP u (P u) (P (u + 1)) (hP u) (hP (u + 1))).mpr
          (by rw [hPu, hPu1]; exact hstep)
      · rw [hPle u (by omega), hPle (u + 1) (by omega)]
        exact Rp.pos_mem_succP u
  set R := runOfPos hbox hP hS with hR
  have hRlab : ∀ u : ℤ, R.lab u = (P u).2.1 := fun u => rfl
  have hbwd : PlusBwdFulfilling R.lab := by
    refine plusBwdFulfilling_of_le R.coherent R.lab_sub (b - (m : ℤ)) ?_
    intro u hu g e hmem
    rw [hRlab, hPle u hu] at hmem
    obtain ⟨r, hr1, hr2, hr3⟩ := hRpf u g e hmem
    refine ⟨r, hr1, ?_, ?_⟩
    · rw [hRlab, hPle r (by omega)]; exact hr2
    · intro v hv1 hv2
      rw [hRlab, hPle v (by omega)]
      exact hr3 v hv1 hv2
  have hfwd : PlusFwdFulfilling R.lab := by
    refine plusFwdFulfilling_of_ge R.coherent R.lab_sub b ?_
    intro u hu g e hmem
    rw [hRlab, hPge u hu] at hmem
    obtain ⟨j, hj1, hj2, hj3⟩ := hPffair (u - b).toNat g e hmem
    refine ⟨b + (j : ℤ), by omega, ?_, ?_⟩
    · rw [hRlab, hPge (b + (j : ℤ)) (by omega),
        show b + (j : ℤ) - b = (j : ℤ) from by omega, Int.toNat_natCast]
      exact hj2
    · intro v hv1 hv2
      rw [hRlab, hPge v (by omega)]
      exact hj3 (v - b).toNat (by omega) (by omega)
  have hpos : R.pos b = c 0 := by
    rw [hR, runOfPos_pos, hPmid b (by omega) le_rfl, show b - b = 0 from by omega]
    rfl
  rw [← hpos]
  exact G.live_of_path R ⟨hfwd, hbwd⟩ b

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
