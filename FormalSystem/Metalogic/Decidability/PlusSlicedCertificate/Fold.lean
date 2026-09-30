/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Timed

/-!
# Folding a ℤ-Time into the Combined Window

A walk in the timed graph is **not** literally a walk in the bi-infinite position space: at the two
window edges `nextTime` and `prevTime` wrap. `FoldF` is the equivalence the forward wrap generates
and `FoldB` the one the backward wrap generates, and the lemmas below say that neither can change
the slice sequence, the target path's datum, the edge relation, the position space, or the one-step
position graph. That is what will let a graph walk be read as a ℤ-indexed run and back.

Agreement of the *data* is not itself preserved by `+1` at the boundaries — two times may carry the
same slice by accident and diverge one step later — which is why each relation carries the residue
condition rather than the data agreement it implies. `foldF_succ` / `foldB_pred` are the lemmas that
would be false for the weaker relation.

## Why both objects, and why the combined period

Every fold lemma comes in a pair: one for `G.slice` and one for `G.target.datum`. A single-source
window could not state the pair at all, because one of the two objects would be folded by a period
that is not its own. `Window.lean`'s combined `NB` / `NF` / `NM` is what makes the pair statable,
and each half is a residue computation against a divisor of the combined period
(`nb_dvd_NB`, `nf_dvd_NF`, and the two target-side facts).

## Main definitions

- `PlusSlicedCertificate.FoldF` — the forward folding relation on times
- `PlusSlicedCertificate.FoldB` — the backward folding relation

## Main results

- `PlusSlicedCertificate.foldF_refl` / `foldF_symm` / `foldF_trans`, and the backward triple
- `PlusSlicedCertificate.foldF_slice` / `foldF_target_datum` / `foldF_edge` / `foldF_posAt` /
  `foldF_succP`, and the backward analogues ending in `foldB_predP`
- `PlusSlicedCertificate.foldF_succ` / `foldB_pred` — closure under a common step
- `PlusSlicedCertificate.foldF_nextTime` / `foldB_prevTime` — **each wrap is a fold**
- `PlusSlicedCertificate.exists_foldF` / `exists_foldB` — every time on the relevant half-line folds
  into the window

## Tags

plus-language · certificate · time-sliced · fold · window
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The two relations -/

/-- **The forward folding relation**: equal, or both at or past the combined window offset and
congruent modulo the combined forward period. -/
def FoldF (G : PlusSlicedCertificate Γ Del) (a b : ℤ) : Prop :=
  a = b ∨ (G.NM ≤ a ∧ G.NM ≤ b ∧ (a - G.NM) % G.NF = (b - G.NM) % G.NF)

/-- **The backward folding relation**, the leftward mirror of `FoldF`. -/
def FoldB (G : PlusSlicedCertificate Γ Del) (a b : ℤ) : Prop :=
  a = b ∨ (a < 0 ∧ b < 0 ∧ a % G.NB = b % G.NB)

theorem foldF_refl (G : PlusSlicedCertificate Γ Del) (a : ℤ) : G.FoldF a a := Or.inl rfl

theorem foldB_refl (G : PlusSlicedCertificate Γ Del) (a : ℤ) : G.FoldB a a := Or.inl rfl

theorem foldF_symm {G : PlusSlicedCertificate Γ Del} {a b : ℤ} (h : G.FoldF a b) :
    G.FoldF b a := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · exact Or.inr ⟨h2, h1, h3.symm⟩

theorem foldB_symm {G : PlusSlicedCertificate Γ Del} {a b : ℤ} (h : G.FoldB a b) :
    G.FoldB b a := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · exact Or.inr ⟨h2, h1, h3.symm⟩

theorem foldF_trans {G : PlusSlicedCertificate Γ Del} {a b c : ℤ} (h1 : G.FoldF a b)
    (h2 : G.FoldF b c) : G.FoldF a c := by
  rcases h1 with rfl | ⟨p1, p2, p3⟩
  · exact h2
  · rcases h2 with rfl | ⟨-, q2, q3⟩
    · exact Or.inr ⟨p1, p2, p3⟩
    · exact Or.inr ⟨p1, q2, p3.trans q3⟩

theorem foldB_trans {G : PlusSlicedCertificate Γ Del} {a b c : ℤ} (h1 : G.FoldB a b)
    (h2 : G.FoldB b c) : G.FoldB a c := by
  rcases h1 with rfl | ⟨p1, p2, p3⟩
  · exact h2
  · rcases h2 with rfl | ⟨-, q2, q3⟩
    · exact Or.inr ⟨p1, p2, p3⟩
    · exact Or.inr ⟨p1, q2, p3.trans q3⟩

/-! ## Folded times carry the same data

The pair for each direction. Each is a residue computation against a divisor of the combined
period — citation of `Window.lean`'s compatibility facts, not new arithmetic.
-/

/-- **Forward-folded times carry the same slice.** -/
theorem foldF_slice (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldF a b) :
    G.slice a = G.slice b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · have hnm := G.nm_le_NM
    rw [G.slice_fwd (by omega), G.slice_fwd (by omega)]
    refine Periodic.cyc_congr ?_
    have hm : Int.ModEq G.nf (a - G.NM) (b - G.NM) := emod_eq_of_dvd_of_emod_eq G.nf_dvd_NF h3
    have hm2 : Int.ModEq G.nf a b := by
      have h4 := hm.add_right G.NM
      rwa [show a - G.NM + G.NM = a from by omega,
        show b - G.NM + G.NM = b from by omega] at h4
    exact hm2.sub_right G.nm

/-- **Forward-folded times carry the same target datum.** -/
theorem foldF_target_datum (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldF a b) :
    G.target.datum a = G.target.datum b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · have hnm := G.target_nm_le_NM
    rw [G.target.datum_fwd (by omega), G.target.datum_fwd (by omega)]
    refine @Periodic.cyc_congr _ G.target.inh _ _ _ ?_
    have hm : Int.ModEq G.target.nf (a - G.NM) (b - G.NM) :=
      emod_eq_of_dvd_of_emod_eq G.target_nf_dvd_NF h3
    have hm2 : Int.ModEq G.target.nf a b := by
      have h4 := hm.add_right G.NM
      rwa [show a - G.NM + G.NM = a from by omega,
        show b - G.NM + G.NM = b from by omega] at h4
    exact hm2.sub_right G.target.nm

/-- **Backward-folded times carry the same slice.** -/
theorem foldB_slice (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldB a b) :
    G.slice a = G.slice b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · rw [G.slice_neg h1, G.slice_neg h2]
    exact Periodic.cyc_congr (emod_eq_of_dvd_of_emod_eq G.nb_dvd_NB h3)

/-- **Backward-folded times carry the same target datum.** -/
theorem foldB_target_datum (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldB a b) :
    G.target.datum a = G.target.datum b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · rw [G.target.datum_neg h1, G.target.datum_neg h2]
    exact @Periodic.cyc_congr _ G.target.inh _ _ _
      (emod_eq_of_dvd_of_emod_eq G.target_nb_dvd_NB h3)

/-! ### The same, lifted to the graph layers

`edge`, `posAt` and `succP` / `predP` all depend on the time only through the slices they touch, so
each of these is the matching congruence of `Timed.lean` composed with the two lemmas above.
-/

theorem foldF_edge (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldF a b) (w u : Fin G.n) :
    G.edge a w u = G.edge b w u := G.edge_congr (G.foldF_slice h) w u

theorem foldB_edge (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldB a b) (w u : Fin G.n) :
    G.edge a w u = G.edge b w u := G.edge_congr (G.foldB_slice h) w u

theorem foldF_posAt (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldF a b) :
    G.posAt a = G.posAt b := G.posAt_congr (G.foldF_slice h)

theorem foldB_posAt (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldB a b) :
    G.posAt a = G.posAt b := G.posAt_congr (G.foldB_slice h)

/-! ## Closure under a common step

The property the residue condition is carried for. Data agreement alone would not survive a step.
-/

/-- **The forward relation is closed under a common successor.** -/
theorem foldF_succ {G : PlusSlicedCertificate Γ Del} {a b : ℤ} (h : G.FoldF a b) :
    G.FoldF (a + 1) (b + 1) := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · refine Or.inr ⟨by omega, by omega, ?_⟩
    have h4 : Int.ModEq G.NF (a - G.NM + 1) (b - G.NM + 1) := Int.ModEq.add_right 1 h3
    rwa [show a - G.NM + 1 = a + 1 - G.NM from by omega,
      show b - G.NM + 1 = b + 1 - G.NM from by omega] at h4

/-- **The backward relation is closed under a common predecessor.** -/
theorem foldB_pred {G : PlusSlicedCertificate Γ Del} {a b : ℤ} (h : G.FoldB a b) :
    G.FoldB (a - 1) (b - 1) := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · exact Or.inr ⟨by omega, by omega, Int.ModEq.sub_right 1 h3⟩

/-- **Forward-folded times carry the same one-step successors.** Both slices `succP` touches are
folded, by `foldF_succ`. -/
theorem foldF_succP (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldF a b) (p : G.Pos) :
    G.succP a p = G.succP b p :=
  G.succP_congr (G.foldF_slice h) (G.foldF_slice (foldF_succ h)) p

/-- **Backward-folded times carry the same one-step predecessors.** -/
theorem foldB_predP (G : PlusSlicedCertificate Γ Del) {a b : ℤ} (h : G.FoldB a b) (q : G.Pos) :
    G.predP a q = G.predP b q :=
  G.predP_congr (G.foldB_slice (foldB_pred h)) q

/-! ## Each wrap is a fold

The two lemmas that connect the timed graph to the bi-infinite time line: a graph step from `u`
lands at a time folding-equivalent to the genuine `u ± 1`.
-/

/-- **The forward wrap is a fold.** -/
theorem foldF_nextTime (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.FoldF (G.nextTime u) (u + 1) := by
  have hNF := G.NF_pos
  have hNM := G.NM_nonneg
  by_cases hw : u + 1 < G.winHi
  · exact Or.inl (by simp only [nextTime, if_pos hw])
  · obtain ⟨hue, he⟩ := G.nextTime_edge hu hw
    refine Or.inr ?_
    rw [he, hue]
    refine ⟨by omega, by omega, ?_⟩
    rw [show G.NM + G.NF - G.NM = 0 + 1 * G.NF from by omega,
      show G.NM + 2 * G.NF - G.NM = 0 + 2 * G.NF from by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- **The backward wrap is a fold.** -/
theorem foldB_prevTime (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.FoldB (G.prevTime u) (u - 1) := by
  have hNB := G.NB_pos
  by_cases hw : G.winLo ≤ u - 1
  · exact Or.inl (by simp only [prevTime, if_pos hw])
  · obtain ⟨hue, he⟩ := G.prevTime_edge hu hw
    refine Or.inr ?_
    rw [he, hue]
    refine ⟨by omega, by omega, ?_⟩
    rw [show -G.NB - 1 = (-1 - G.NB) + 0 * G.NB from by omega,
      show -2 * G.NB - 1 = (-1 - G.NB) + (-1) * G.NB from by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-! ## Every time on the relevant half-line folds into the window -/

/-- **Every time at or after the window's left edge folds forward into the window.** -/
theorem exists_foldF (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : G.winLo ≤ t) :
    ∃ t' : ℤ, t' ∈ G.winTimes ∧ G.FoldF t' t := by
  have hNB := G.NB_pos
  have hNF := G.NF_pos
  have hNM := G.NM_nonneg
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  have hLo : G.winLo = -2 * G.NB := rfl
  by_cases hin : t < G.winHi
  · exact ⟨t, (G.mem_winTimes t).mpr ⟨ht, hin⟩, G.foldF_refl t⟩
  · have h0 : 0 ≤ (t - G.NM) % G.NF := Int.emod_nonneg _ (by omega)
    have h1 : (t - G.NM) % G.NF < G.NF := Int.emod_lt_of_pos _ hNF
    refine ⟨G.NM + (t - G.NM) % G.NF + G.NF, (G.mem_winTimes _).mpr (by omega), ?_⟩
    refine Or.inr ⟨by omega, by omega, ?_⟩
    rw [show G.NM + (t - G.NM) % G.NF + G.NF - G.NM = (t - G.NM) % G.NF + 1 * G.NF from by omega,
      Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]

/-- **Every time before the window's right edge folds backward into the window.** -/
theorem exists_foldB (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : t < G.winHi) :
    ∃ t' : ℤ, t' ∈ G.winTimes ∧ G.FoldB t' t := by
  have hNB := G.NB_pos
  have hNF := G.NF_pos
  have hNM := G.NM_nonneg
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  have hLo : G.winLo = -2 * G.NB := rfl
  by_cases hin : G.winLo ≤ t
  · exact ⟨t, (G.mem_winTimes t).mpr ⟨hin, ht⟩, G.foldB_refl t⟩
  · have h0 : 0 ≤ t % G.NB := Int.emod_nonneg _ (by omega)
    have h1 : t % G.NB < G.NB := Int.emod_lt_of_pos _ hNB
    refine ⟨t % G.NB - 2 * G.NB, (G.mem_winTimes _).mpr (by omega), ?_⟩
    refine Or.inr ⟨by omega, by omega, ?_⟩
    rw [show t % G.NB - 2 * G.NB = t % G.NB + (-2) * G.NB from by omega,
      Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
