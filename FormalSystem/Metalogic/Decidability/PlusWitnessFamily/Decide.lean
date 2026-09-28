/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Predicates
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Decide
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Window

/-!
# The Combined Window at L⁺

Every one of the L⁺ certificate's conditions quantifies over all of `ℤ`. Each is nonetheless
decidable, because the family's whole per-time datum — the representative map together with
every lasso's label — is *eventually periodic in both directions*, so checking a bounded window
of times decides the condition at every time.

This module is that window arithmetic, re-indexed once at `PlusFormula` so that the per-condition
collapses downstream are transcriptions rather than arithmetic.

## What delegated to the skeleton and what did not

The plan for this module was to delegate every label-free lemma to `SharingSkeleton` and
re-index only what reads the label row. The actual split is narrower than that, for one concrete
reason, and it is worth recording:

* **The combined periods do not factor through the skeleton.** `perBack` is
  `|repBack| * ∏ᵢ |lassoᵢ.back|` — a join of the skeleton's representative-segment lengths with
  the *lassos'* label-segment lengths. `NB`, `NF`, `NM`, `cohWindowLo` and `cohWindowHi` are all
  built from it, so none of them is a function of `SharingSkeleton` alone, and neither is
  anything defined over the window. They are re-indexed here.
* **`rep_congr_back` and `rep_congr_fwd` are label-free in substance** — they instantiate
  `Periodic.unrollOf_congr_back`/`_fwd` at the representative segments — but they cannot be
  sited on `SharingSkeleton` either, because those two `Periodic` lemmas are declared in
  `WitnessFamily/Sharing/Decide.lean`, which is downstream of `Skeleton.lean` in the import
  order. They are stated here as three-line instantiations, exactly as on the `Formula` side.
* **What *is* inherited** is everything the window is *about*: `share`, the threads, the frame
  and its histories, all of `SharingSkeleton`. The window is arithmetic over the certificate's
  own data; the branching structure is the skeleton's.

`emod_of_dvd`, `LabelledLasso.emod_shift` and `LabelledLasso.reduce_emod` are pure `ℤ` facts and
are reused from the `Formula` side rather than restated.

## Two periods wide, not one

`cohWindowLo`/`cohWindowHi` are two combined periods wide on each side rather than one, because
(C1') reads `t - 1` and `t + 1` as well as `t`: a representative must have its whole one-step
neighbourhood inside the periodic region, not merely itself.

## Main Definitions

- `PlusSharingWitnessFamily.perBack` / `perFwd` / `perMid` — the combined periods
- `PlusSharingWitnessFamily.cohWindowLo` / `cohWindowHi` — the combined window

## Main Results

- `PlusSharingWitnessFamily.data_congr_back` / `data_congr_fwd` — the whole per-time datum reads
  only its residue
- `PlusSharingWitnessFamily.exists_window_repr` — every time has a window representative carrying
  the same data at its whole one-step neighbourhood
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusLabelledLasso

variable {C : Finset PlusFormula}

/-! ## One-step periodicity, in the four convenient directions -/

/-- One step of rightward label periodicity, in the subtractive direction. -/
theorem lab_sub_nf (Λ : PlusLabelledLasso C) {t : ℤ} (ht : Λ.nm ≤ t - Λ.nf) :
    Λ.lab (t - Λ.nf) = Λ.lab t := by
  simpa using (Λ.lab_add_fwd_length (t := t - Λ.nf) ht).symm

/-- One step of leftward label periodicity, in the additive direction. -/
theorem lab_add_nb (Λ : PlusLabelledLasso C) {t : ℤ} (ht : t + Λ.nb < 0) :
    Λ.lab (t + Λ.nb) = Λ.lab t := by
  simpa using (Λ.lab_sub_back_length (t := t + Λ.nb) ht).symm

/-! ## Canonical representatives -/

/--
**Rightward canonical representative.** Every position at or beyond the window has the label of
its representative `nm + (w - nm) % nf`, which lies in `[nm, nm + nf)`.
-/
theorem lab_reduce_fwd (Λ : PlusLabelledLasso C) :
    ∀ (d : ℕ) (w : ℤ), (w - Λ.nm).toNat = d → Λ.nm ≤ w →
      Λ.lab w = Λ.lab (Λ.nm + (w - Λ.nm) % Λ.nf) := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro w hd hw
    have hnf := Λ.nf_pos
    by_cases hlt : w < Λ.nm + Λ.nf
    · rw [Int.emod_eq_of_lt (by omega) (by omega)]
      congr 1
      omega
    · push Not at hlt
      have hstep : Λ.lab (w - Λ.nf) = Λ.lab w := Λ.lab_sub_nf (by omega)
      have hres : (w - Λ.nf - Λ.nm) % Λ.nf = (w - Λ.nm) % Λ.nf := by
        rw [show w - Λ.nf - Λ.nm = (w - Λ.nm) + (-1) * Λ.nf by omega]
        exact Periodic.emod_add_mul _ _ _
      rw [← hstep, ih ((w - Λ.nf - Λ.nm).toNat) (by omega) (w - Λ.nf) rfl (by omega), hres]

/--
**Leftward canonical representative.** Every negative position has the label of its
representative `w % nb - nb`, which lies in `[-nb, 0)`.
-/
theorem lab_reduce_back (Λ : PlusLabelledLasso C) :
    ∀ (d : ℕ) (w : ℤ), (-w).toNat = d → w < 0 →
      Λ.lab w = Λ.lab (w % Λ.nb - Λ.nb) := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro w hd hw
    have hnb := Λ.nb_pos
    by_cases hge : -Λ.nb ≤ w
    · have hres : (w + Λ.nb) % Λ.nb = w % Λ.nb := by simp
      have hval : w % Λ.nb = w + Λ.nb := by
        rw [← hres]
        exact Int.emod_eq_of_lt (by omega) (by omega)
      rw [hval]
      congr 1
      omega
    · push Not at hge
      have hstep : Λ.lab (w + Λ.nb) = Λ.lab w := Λ.lab_add_nb (by omega)
      have hres : (w + Λ.nb) % Λ.nb = w % Λ.nb := by simp
      rw [← hstep, ih ((-(w + Λ.nb)).toNat) (by omega) (w + Λ.nb) rfl (by omega), hres]

/-- Positions at or beyond the window with equal residues modulo the forward period carry equal
labels. -/
theorem lab_congr_fwd (Λ : PlusLabelledLasso C) {u v : ℤ} (hu : Λ.nm ≤ u) (hv : Λ.nm ≤ v)
    (h : (u - Λ.nm) % Λ.nf = (v - Λ.nm) % Λ.nf) : Λ.lab u = Λ.lab v := by
  rw [Λ.lab_reduce_fwd _ u rfl hu, Λ.lab_reduce_fwd _ v rfl hv, h]

/-- Negative positions with equal residues modulo the backward period carry equal labels. -/
theorem lab_congr_back (Λ : PlusLabelledLasso C) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % Λ.nb = v % Λ.nb) : Λ.lab u = Λ.lab v := by
  rw [Λ.lab_reduce_back _ u rfl hu, Λ.lab_reduce_back _ v rfl hv, h]

end PlusLabelledLasso

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/-! ## The combined periods -/

/-- A product of positive naturals is positive. -/
private theorem plus_list_prod_pos {l : List ℕ} (h : ∀ a ∈ l, 0 < a) : 0 < l.prod := by
  induction l with
  | nil => simp
  | cons a t ih =>
      rw [List.prod_cons]
      exact Nat.mul_pos (h a (by simp)) (ih fun b hb => h b (by simp [hb]))

/-- A member of a list of naturals is at most the list's sum. -/
private theorem plus_le_sum_of_mem {l : List ℕ} {a : ℕ} (h : a ∈ l) : a ≤ l.sum := by
  induction l with
  | nil => cases h
  | cons b t ih =>
      rw [List.sum_cons]
      rcases List.mem_cons.mp h with rfl | h'
      · exact Nat.le_add_right _ _
      · exact le_trans (ih h') (Nat.le_add_left _ _)

/-- A lasso's index is a member of the family's lasso list. -/
theorem get_mem (S : PlusSharingWitnessFamily Γ Del) (i : Fin S.lassos.length) :
    S.lassos.get i ∈ S.lassos := by
  rw [List.get_eq_getElem]
  exact List.getElem_mem i.isLt

/--
**The combined backward period**: a positive common multiple of `|repBack|` and of every
lasso's `|back|`.
-/
def perBack (S : PlusSharingWitnessFamily Γ Del) : ℕ :=
  S.repBack.length * (S.lassos.map (fun Λ => Λ.back.length)).prod

/-- **The combined forward period**, the rightward mirror of `perBack`. -/
def perFwd (S : PlusSharingWitnessFamily Γ Del) : ℕ :=
  S.repFwd.length * (S.lassos.map (fun Λ => Λ.fwd.length)).prod

/--
**The combined window offset**: at or past it, every rightward decoding of the family — labels
and representative maps alike — is in its periodic region. A sum rather than a maximum, so that
`plus_le_sum_of_mem` discharges the comparisons.
-/
def perMid (S : PlusSharingWitnessFamily Γ Del) : ℕ :=
  S.repMid.length + (S.lassos.map (fun Λ => Λ.mid.length)).sum

/-- The combined backward period, as an integer. -/
abbrev NB (S : PlusSharingWitnessFamily Γ Del) : ℤ := (S.perBack : ℤ)

/-- The combined forward period, as an integer. -/
abbrev NF (S : PlusSharingWitnessFamily Γ Del) : ℤ := (S.perFwd : ℤ)

/-- The combined window offset, as an integer. -/
abbrev NM (S : PlusSharingWitnessFamily Γ Del) : ℤ := (S.perMid : ℤ)

/-- The backward representative-cycle length, as an integer. -/
abbrev nbr (S : PlusSharingWitnessFamily Γ Del) : ℤ := (S.repBack.length : ℤ)

/-- The representative-window length, as an integer. -/
abbrev nmr (S : PlusSharingWitnessFamily Γ Del) : ℤ := (S.repMid.length : ℤ)

/-- The forward representative-cycle length, as an integer. -/
abbrev nfr (S : PlusSharingWitnessFamily Γ Del) : ℤ := (S.repFwd.length : ℤ)

theorem NB_pos (S : PlusSharingWitnessFamily Γ Del) : 0 < S.NB := by
  refine Int.natCast_pos.mpr (Nat.mul_pos ?_ (plus_list_prod_pos ?_))
  · exact List.length_pos_of_ne_nil S.repBack_ne
  · intro a ha
    obtain ⟨Λ, _, rfl⟩ := List.mem_map.mp ha
    exact List.length_pos_of_ne_nil Λ.back_ne

theorem NF_pos (S : PlusSharingWitnessFamily Γ Del) : 0 < S.NF := by
  refine Int.natCast_pos.mpr (Nat.mul_pos ?_ (plus_list_prod_pos ?_))
  · exact List.length_pos_of_ne_nil S.repFwd_ne
  · intro a ha
    obtain ⟨Λ, _, rfl⟩ := List.mem_map.mp ha
    exact List.length_pos_of_ne_nil Λ.fwd_ne

theorem NM_nonneg (S : PlusSharingWitnessFamily Γ Del) : 0 ≤ S.NM := Int.natCast_nonneg _

theorem nbr_dvd_NB (S : PlusSharingWitnessFamily Γ Del) : S.nbr ∣ S.NB :=
  Int.natCast_dvd_natCast.mpr ⟨_, rfl⟩

theorem nfr_dvd_NF (S : PlusSharingWitnessFamily Γ Del) : S.nfr ∣ S.NF :=
  Int.natCast_dvd_natCast.mpr ⟨_, rfl⟩

theorem nmr_le_NM (S : PlusSharingWitnessFamily Γ Del) : S.nmr ≤ S.NM := by
  exact_mod_cast Nat.le_add_right S.repMid.length _

theorem lasso_nb_dvd_NB (S : PlusSharingWitnessFamily Γ Del) (i : Fin S.lassos.length) :
    (S.lassos.get i).nb ∣ S.NB := by
  refine Int.natCast_dvd_natCast.mpr (Dvd.dvd.mul_left ?_ _)
  exact List.dvd_prod (List.mem_map.mpr ⟨_, S.get_mem i, rfl⟩)

theorem lasso_nf_dvd_NF (S : PlusSharingWitnessFamily Γ Del) (i : Fin S.lassos.length) :
    (S.lassos.get i).nf ∣ S.NF := by
  refine Int.natCast_dvd_natCast.mpr (Dvd.dvd.mul_left ?_ _)
  exact List.dvd_prod (List.mem_map.mpr ⟨_, S.get_mem i, rfl⟩)

theorem lasso_nm_le_NM (S : PlusSharingWitnessFamily Γ Del) (i : Fin S.lassos.length) :
    (S.lassos.get i).nm ≤ S.NM := by
  have h : (S.lassos.get i).mid.length ≤ S.perMid := by
    refine le_trans ?_ (Nat.le_add_left _ _)
    exact plus_le_sum_of_mem (List.mem_map.mpr ⟨_, S.get_mem i, rfl⟩)
  exact_mod_cast h

/-! ## The representative maps read only their residue -/

theorem rep_congr_back (S : PlusSharingWitnessFamily Γ Del) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % S.nbr = v % S.nbr) : S.rep u = S.rep v :=
  Periodic.unrollOf_congr_back (repIdInhabited _) S.repBack S.repMid S.repFwd hu hv h

theorem rep_congr_fwd (S : PlusSharingWitnessFamily Γ Del) {u v : ℤ} (hu : S.nmr ≤ u)
    (hv : S.nmr ≤ v) (h : (u - S.nmr) % S.nfr = (v - S.nmr) % S.nfr) : S.rep u = S.rep v :=
  Periodic.unrollOf_congr_fwd (repIdInhabited _) S.repBack S.repMid S.repFwd hu hv h

/-! ## The family's whole per-time datum reads only its residue -/

/--
**Leftward data congruence.** At two negative times congruent modulo the combined backward
period, the representative map and every lasso's label agree.
-/
theorem data_congr_back (S : PlusSharingWitnessFamily Γ Del) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % S.NB = v % S.NB) : S.rep u = S.rep v ∧ ∀ i, S.L i u = S.L i v := by
  refine ⟨S.rep_congr_back hu hv (emod_of_dvd S.nbr_dvd_NB h), fun i => ?_⟩
  exact (S.lassos.get i).lab_congr_back hu hv (emod_of_dvd (S.lasso_nb_dvd_NB i) h)

/--
**Rightward data congruence.** At or past the combined window offset, at two times congruent
modulo the combined forward period, the representative map and every lasso's label agree.
-/
theorem data_congr_fwd (S : PlusSharingWitnessFamily Γ Del) {u v : ℤ} (hu : S.NM ≤ u)
    (hv : S.NM ≤ v) (h : (u - S.NM) % S.NF = (v - S.NM) % S.NF) :
    S.rep u = S.rep v ∧ ∀ i, S.L i u = S.L i v := by
  have shift : ∀ (m n : ℤ), n ∣ S.NF → (u - m) % n = (v - m) % n := by
    intro m n hdvd
    have h1 : (u - S.NM) % n = (v - S.NM) % n := emod_of_dvd hdvd h
    have h2 : ((u - S.NM) + (S.NM - m)) % n = ((v - S.NM) + (S.NM - m)) % n :=
      LabelledLasso.emod_shift h1
    rwa [show (u - S.NM) + (S.NM - m) = u - m by omega,
      show (v - S.NM) + (S.NM - m) = v - m by omega] at h2
  refine ⟨S.rep_congr_fwd (le_trans S.nmr_le_NM hu) (le_trans S.nmr_le_NM hv)
    (shift S.nmr S.nfr S.nfr_dvd_NF), fun i => ?_⟩
  exact (S.lassos.get i).lab_congr_fwd (le_trans (S.lasso_nm_le_NM i) hu)
    (le_trans (S.lasso_nm_le_NM i) hv)
    (shift (S.lassos.get i).nm (S.lassos.get i).nf (S.lasso_nf_dvd_NF i))

/-! ## The combined window -/

/-- Lower end of the combined window. -/
def cohWindowLo (S : PlusSharingWitnessFamily Γ Del) : ℤ := -2 * S.NB

/-- Upper end (exclusive) of the combined window. -/
def cohWindowHi (S : PlusSharingWitnessFamily Γ Del) : ℤ := S.NM + 2 * S.NF

/-!
### The window as a `SharingWindow`

The header above records that the combined periods do not factor through `SharingSkeleton`.
They do factor through `SharingWindow` (`Sharing/Window.lean`) — the skeleton together with the
triple `(NB, NF, NM)` carried as *data* — and the projection below is what supplies it.

That is not a bookkeeping nicety. Everything the position graph of (C2') is built from — the
window's times, the vertices, the two wrapped time-steps, the two edge relations, the folding
relations and the walk layer — is a function of this projection alone, so the whole of that
layer is **inherited** rather than re-indexed at `PlusFormula`. What is re-indexed downstream is
exactly what reads a label.
-/

/--
**The family's combined window**, as the label-free structure the position graph runs on.

Marked `@[reducible]` for the same reason `skeleton` is: without it, `Fin S.window.n` and
`Fin S.lassos.length` fail to unify at the transparency keyed matching uses, and rewrites whose
pattern mentions `share` fail against terms whose indices came from a thread.
-/
@[reducible]
def window (S : PlusSharingWitnessFamily Γ Del) : SharingWindow where
  toSharingSkeleton := S.skeleton
  NB := S.NB
  NF := S.NF
  NM := S.NM
  NB_pos := S.NB_pos
  NF_pos := S.NF_pos
  NM_nonneg := S.NM_nonneg
  nbr_dvd_NB := S.nbr_dvd_NB
  nfr_dvd_NF := S.nfr_dvd_NF
  nmr_le_NM := S.nmr_le_NM

/-- The window's substrate is the family's skeleton, definitionally. -/
theorem window_toSharingSkeleton (S : PlusSharingWitnessFamily Γ Del) :
    S.window.toSharingSkeleton = S.skeleton := rfl

/-- The window's representative map is the family's, definitionally. -/
theorem window_rep (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) : S.window.rep u = S.rep u := rfl

/-- The window's sharing relation is the family's, definitionally. -/
theorem window_share (S : PlusSharingWitnessFamily Γ Del) (u : ℤ)
    (i j : Fin S.lassos.length) : S.window.share u i j ↔ S.share u i j := Iff.rfl

theorem window_NB (S : PlusSharingWitnessFamily Γ Del) : S.window.NB = S.NB := rfl

theorem window_NF (S : PlusSharingWitnessFamily Γ Del) : S.window.NF = S.NF := rfl

theorem window_NM (S : PlusSharingWitnessFamily Γ Del) : S.window.NM = S.NM := rfl

theorem window_cohWindowLo (S : PlusSharingWitnessFamily Γ Del) :
    S.window.cohWindowLo = S.cohWindowLo := rfl

theorem window_cohWindowHi (S : PlusSharingWitnessFamily Γ Del) :
    S.window.cohWindowHi = S.cohWindowHi := rfl

/--
**Every time has a representative in the combined window carrying the same data**, at the
representative's whole one-step neighbourhood.

Two periods wide on each side rather than one: (C1') reads `t - 1` and `t + 1` as well as `t`,
so a representative must have its whole neighbourhood inside the periodic region.
-/
theorem exists_window_repr (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) :
    ∃ t' : ℤ, S.cohWindowLo ≤ t' ∧ t' < S.cohWindowHi ∧
      S.rep t = S.rep t' ∧ S.rep (t + 1) = S.rep (t' + 1) ∧
      (∀ i, S.L i (t - 1) = S.L i (t' - 1)) ∧ (∀ i, S.L i t = S.L i t') ∧
      (∀ i, S.L i (t + 1) = S.L i (t' + 1)) := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  rcases lt_or_ge t (-1) with hfar | hmid
  · -- far left: represent `t` in `[-2·NB, -NB)`, whose whole neighbourhood is negative
    refine ⟨t % S.NB - 2 * S.NB, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
      set t' : ℤ := t % S.NB - 2 * S.NB with ht'
    all_goals {
      have h0 : 0 ≤ t % S.NB := Int.emod_nonneg _ (by omega)
      have h1 : t % S.NB < S.NB := Int.emod_lt_of_pos _ hNB
      have hres : t % S.NB = t' % S.NB := by
        have hrw : t' = t % S.NB + (-2) * S.NB := by omega
        rw [hrw, Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]
      have hresp : (t + 1) % S.NB = (t' + 1) % S.NB := LabelledLasso.emod_shift hres
      have hresm : (t - 1) % S.NB = (t' - 1) % S.NB := by
        have := LabelledLasso.emod_shift (k := -1) hres
        rwa [show t + -1 = t - 1 by omega, show t' + -1 = t' - 1 by omega] at this
      first
        | (simp only [cohWindowLo]; omega)
        | (simp only [cohWindowHi]; omega)
        | exact (S.data_congr_back (by omega) (by omega) hres).1
        | exact (S.data_congr_back (by omega) (by omega) hresp).1
        | exact (S.data_congr_back (by omega) (by omega) hresm).2
        | exact (S.data_congr_back (by omega) (by omega) hres).2
        | exact (S.data_congr_back (by omega) (by omega) hresp).2
    }
  rcases le_or_gt t S.NM with hin | hfar
  · -- middle: already inside the window
    exact ⟨t, by simp only [cohWindowLo]; omega, by simp only [cohWindowHi]; omega,
      rfl, rfl, fun _ => rfl, fun _ => rfl, fun _ => rfl⟩
  · -- far right: represent `t` in `[NM + NF, NM + 2·NF)`
    refine ⟨S.NM + (t - S.NM) % S.NF + S.NF, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
      set t' : ℤ := S.NM + (t - S.NM) % S.NF + S.NF with ht'
    all_goals {
      have h0 : 0 ≤ (t - S.NM) % S.NF := Int.emod_nonneg _ (by omega)
      have h1 : (t - S.NM) % S.NF < S.NF := Int.emod_lt_of_pos _ hNF
      have hres : (t - S.NM) % S.NF = (t' - S.NM) % S.NF := by
        have hrw : t' - S.NM = (t - S.NM) % S.NF + 1 * S.NF := by omega
        rw [hrw, Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]
      have hresp : (t + 1 - S.NM) % S.NF = (t' + 1 - S.NM) % S.NF := by
        have := LabelledLasso.emod_shift (k := 1) hres
        rwa [show t - S.NM + 1 = t + 1 - S.NM by omega,
          show t' - S.NM + 1 = t' + 1 - S.NM by omega] at this
      have hresm : (t - 1 - S.NM) % S.NF = (t' - 1 - S.NM) % S.NF := by
        have := LabelledLasso.emod_shift (k := -1) hres
        rwa [show t - S.NM + -1 = t - 1 - S.NM by omega,
          show t' - S.NM + -1 = t' - 1 - S.NM by omega] at this
      first
        | (simp only [cohWindowLo]; omega)
        | (simp only [cohWindowHi]; omega)
        | exact (S.data_congr_fwd (by omega) (by omega) hres).1
        | exact (S.data_congr_fwd (by omega) (by omega) hresp).1
        | exact (S.data_congr_fwd (by omega) (by omega) hresm).2
        | exact (S.data_congr_fwd (by omega) (by omega) hres).2
        | exact (S.data_congr_fwd (by omega) (by omega) hresp).2
    }

/-! ## (C0) at a single time

`PlusAtomCoherent` quantifies over `∀ p : Atom`, and `Atom` is `Infinite`. The closure-gated form
below is equivalent — an atom outside `plusClosureOf (Γ ++ Del)` is absent from both labels, since
every label is a subset of the closure — and it is the form that decides.
-/

/-- The atom clause a single closure member imposes at a pair of labels. -/
def plusAtomClauseAt (Li Lj : Finset PlusFormula) : PlusFormula → Prop
  | PlusFormula.atom p => (PlusFormula.atom p ∈ Li ↔ PlusFormula.atom p ∈ Lj)
  | PlusFormula.bot => True
  | PlusFormula.imp _ _ => True
  | PlusFormula.box _ => True
  | PlusFormula.untl _ _ => True
  | PlusFormula.snce _ _ => True
  | PlusFormula.stab _ => True

/-- `plusAtomClauseAt` is decidable at every formula. -/
instance instDecidablePlusAtomClauseAt (Li Lj : Finset PlusFormula) :
    DecidablePred (plusAtomClauseAt Li Lj) := by
  intro ψ
  cases ψ <;> (dsimp only [plusAtomClauseAt]; infer_instance)

/--
(C0)'s content at explicit data: one representative map and one label per lasso.

Stated at the data rather than at `S` and `t`, so that the window congruence is a `rw` of the
two arguments rather than a hand-transport through the quantifiers.
-/
def plusAtomCoherentData {n : ℕ} (C : Finset PlusFormula) (rt : Fin n → Fin n)
    (Lt : Fin n → Finset PlusFormula) : Prop :=
  ∀ i j : Fin n, rt i = rt j → ∀ ψ ∈ C, plusAtomClauseAt (Lt i) (Lt j) ψ

instance instDecidablePlusAtomCoherentData {n : ℕ} (C : Finset PlusFormula)
    (rt : Fin n → Fin n) (Lt : Fin n → Finset PlusFormula) :
    Decidable (plusAtomCoherentData C rt Lt) := by
  dsimp only [plusAtomCoherentData]
  infer_instance

/-- **(C0) at a single time.** -/
def PlusAtomCoherentAt (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) : Prop :=
  plusAtomCoherentData (plusClosureOf (Γ ++ Del)) (S.rep t) (fun i => S.L i t)

instance decidablePlusAtomCoherentAt (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) :
    Decidable (S.PlusAtomCoherentAt t) := by
  dsimp only [PlusAtomCoherentAt]
  infer_instance

/-- **(C0) is exactly its closure-gated form at every time.** -/
theorem plusAtomCoherent_iff_at (S : PlusSharingWitnessFamily Γ Del) :
    S.PlusAtomCoherent ↔ ∀ t : ℤ, S.PlusAtomCoherentAt t := by
  constructor
  · intro h t i j hij ψ _
    cases ψ with
    | atom p => exact h t i j hij p
    | bot => trivial
    | imp _ _ => trivial
    | box _ => trivial
    | untl _ _ => trivial
    | snce _ _ => trivial
    | stab _ => trivial
  · intro h t i j hij p
    by_cases hc : PlusFormula.atom p ∈ plusClosureOf (Γ ++ Del)
    · exact h t i j hij _ hc
    · constructor
      · intro hm; exact absurd (S.subset_plusClosureOf i t hm) hc
      · intro hm; exact absurd (S.subset_plusClosureOf j t hm) hc

/-- The per-time check reads only the representative map and the labels at that time. -/
theorem plusAtomCoherentAt_congr (S : PlusSharingWitnessFamily Γ Del) {t t' : ℤ}
    (hr : S.rep t = S.rep t') (hL : ∀ i, S.L i t = S.L i t') :
    S.PlusAtomCoherentAt t ↔ S.PlusAtomCoherentAt t' := by
  have hLf : (fun i => S.L i t) = (fun i => S.L i t') := funext hL
  simp only [PlusAtomCoherentAt, hr, hLf]

/-! ## (C1') at a single time -/

/--
The local clause a single closure member imposes on a sharing family, at explicit data.

`rt`, `rp` are the representative maps at `t` and `t + 1`; `Lm`, `Lt`, `Lp` the per-lasso labels
at `t - 1`, `t` and `t + 1`. The `untl` and `snce` clauses quantify over the shared successors
and predecessors respectively.

The `stab` arm is `True`: the stability modal is (C5)'s, and a non-trivial arm here would be the
weaker, wrongly-shaped duplicate `Predicates.lean`'s header warns against.
-/
def plusShareClauseAt {n : ℕ} (bx : PlusFormula → Bool) (rt rp : Fin n → Fin n)
    (Lm Lt Lp : Fin n → Finset PlusFormula) (i : Fin n) : PlusFormula → Prop
  | PlusFormula.atom _ => True
  | PlusFormula.bot => True
  | PlusFormula.imp a b => (PlusFormula.imp a b ∈ Lt i ↔ (a ∈ Lt i → b ∈ Lt i))
  | PlusFormula.box χ => (PlusFormula.box χ ∈ Lt i ↔ bx χ = true)
  | PlusFormula.untl g e => ∀ j : Fin n, rp i = rp j →
      (PlusFormula.untl g e ∈ Lt i ↔ (e ∈ Lp j ∨ (g ∈ Lp j ∧ PlusFormula.untl g e ∈ Lp j)))
  | PlusFormula.snce g e => ∀ k : Fin n, rt i = rt k →
      (PlusFormula.snce g e ∈ Lt i ↔ (e ∈ Lm k ∨ (g ∈ Lm k ∧ PlusFormula.snce g e ∈ Lm k)))
  | PlusFormula.stab _ => True

/-- `plusShareClauseAt` is decidable at every formula: the two quantifiers range over a
`Fintype`. -/
instance instDecidablePlusShareClauseAt {n : ℕ} (bx : PlusFormula → Bool)
    (rt rp : Fin n → Fin n) (Lm Lt Lp : Fin n → Finset PlusFormula) (i : Fin n) :
    DecidablePred (plusShareClauseAt bx rt rp Lm Lt Lp i) := by
  intro ψ
  cases ψ <;> (dsimp only [plusShareClauseAt]; infer_instance)

/-- (C1')'s content at explicit data. -/
def plusCoherentShareData {n : ℕ} (bx : PlusFormula → Bool) (C : Finset PlusFormula)
    (rt rp : Fin n → Fin n) (Lm Lt Lp : Fin n → Finset PlusFormula) : Prop :=
  ∀ i : Fin n, PlusFormula.bot ∉ Lt i ∧ ∀ ψ ∈ C, plusShareClauseAt bx rt rp Lm Lt Lp i ψ

instance instDecidablePlusCoherentShareData {n : ℕ} (bx : PlusFormula → Bool)
    (C : Finset PlusFormula) (rt rp : Fin n → Fin n)
    (Lm Lt Lp : Fin n → Finset PlusFormula) :
    Decidable (plusCoherentShareData bx C rt rp Lm Lt Lp) := by
  dsimp only [plusCoherentShareData]
  infer_instance

/-- **(C1') at a single time.** -/
def PlusCoherentShareAt (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) : Prop :=
  plusCoherentShareData S.bx (plusClosureOf (Γ ++ Del)) (S.rep t) (S.rep (t + 1))
    (fun i => S.L i (t - 1)) (fun i => S.L i t) (fun i => S.L i (t + 1))

instance decidablePlusCoherentShareAt (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) :
    Decidable (S.PlusCoherentShareAt t) := by
  dsimp only [PlusCoherentShareAt]
  infer_instance

/-- **(C1') is exactly its closure-gated form at every time.** -/
theorem plusLocalCoherentShare_iff_at (S : PlusSharingWitnessFamily Γ Del) :
    S.PlusLocalCoherentShare ↔ ∀ t : ℤ, S.PlusCoherentShareAt t := by
  constructor
  · intro h t i
    obtain ⟨hbot, himp, hbox, huntl, hsnce⟩ := h i t
    refine ⟨hbot, fun ψ hψ => ?_⟩
    cases ψ with
    | atom _ => trivial
    | bot => trivial
    | imp a b => exact himp a b hψ
    | box χ => exact hbox χ hψ
    | untl g e => exact fun j hj => huntl j hj g e hψ
    | snce g e => exact fun k hk => hsnce k hk g e hψ
    | stab _ => trivial
  · intro h i t
    obtain ⟨hbot, hcl⟩ := h t i
    exact ⟨hbot, fun a b hab => hcl _ hab, fun χ hχ => hcl _ hχ,
      fun j hj g e hge => hcl _ hge j hj, fun k hk g e hge => hcl _ hge k hk⟩

/-- The per-position check reads only the representative maps at `t` and `t + 1` and the labels
at `t - 1`, `t` and `t + 1`. -/
theorem plusCoherentShareAt_congr (S : PlusSharingWitnessFamily Γ Del) {t t' : ℤ}
    (hr0 : S.rep t = S.rep t') (hr1 : S.rep (t + 1) = S.rep (t' + 1))
    (hm : ∀ i, S.L i (t - 1) = S.L i (t' - 1)) (h0 : ∀ i, S.L i t = S.L i t')
    (hp : ∀ i, S.L i (t + 1) = S.L i (t' + 1)) :
    S.PlusCoherentShareAt t ↔ S.PlusCoherentShareAt t' := by
  have em : (fun i => S.L i (t - 1)) = (fun i => S.L i (t' - 1)) := funext hm
  have e0 : (fun i => S.L i t) = (fun i => S.L i t') := funext h0
  have ep : (fun i => S.L i (t + 1)) = (fun i => S.L i (t' + 1)) := funext hp
  simp only [PlusCoherentShareAt, hr0, hr1, em, e0, ep]

/-! ## The two window collapses, and the two instances -/

/-- **(C0) collapses to the combined window.** -/
theorem plusAtomCoherent_iff_window (S : PlusSharingWitnessFamily Γ Del) :
    S.PlusAtomCoherent ↔
      ∀ t : ℤ, S.cohWindowLo ≤ t → t < S.cohWindowHi → S.PlusAtomCoherentAt t := by
  rw [S.plusAtomCoherent_iff_at]
  constructor
  · intro h t _ _; exact h t
  · intro h t
    obtain ⟨t', hlo, hhi, hr0, _, _, hL0, _⟩ := S.exists_window_repr t
    exact (S.plusAtomCoherentAt_congr hr0 hL0).mpr (h t' hlo hhi)

/-- **(C1') collapses to the combined window.** -/
theorem plusLocalCoherentShare_iff_window (S : PlusSharingWitnessFamily Γ Del) :
    S.PlusLocalCoherentShare ↔
      ∀ t : ℤ, S.cohWindowLo ≤ t → t < S.cohWindowHi → S.PlusCoherentShareAt t := by
  rw [S.plusLocalCoherentShare_iff_at]
  constructor
  · intro h t _ _; exact h t
  · intro h t
    obtain ⟨t', hlo, hhi, hr0, hr1, hm, h0, hp⟩ := S.exists_window_repr t
    exact (S.plusCoherentShareAt_congr hr0 hr1 hm h0 hp).mpr (h t' hlo hhi)

/-- **(C0) decides** by a bounded scan of the combined window. -/
instance decidablePlusAtomCoherent (S : PlusSharingWitnessFamily Γ Del) :
    Decidable S.PlusAtomCoherent :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico S.cohWindowLo S.cohWindowHi, S.PlusAtomCoherentAt t)
    (by
      rw [S.plusAtomCoherent_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

/-- **(C1') decides** by a bounded scan of the combined window. -/
instance decidablePlusLocalCoherentShare (S : PlusSharingWitnessFamily Γ Del) :
    Decidable S.PlusLocalCoherentShare :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico S.cohWindowLo S.cohWindowHi, S.PlusCoherentShareAt t)
    (by
      rw [S.plusLocalCoherentShare_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

/-! ## (C5) at a single time, and its window collapse

The hard constraint on this task was that decidability must be preserved: the branching frame
has infinitely many walks, and no condition may quantify over them. (C5) does not — it quantifies
over `Fin S.lassos.length` at one fixed time — and this section discharges that mechanically
rather than arguing it.

(C5) has (C0)'s quantifier signature exactly: **one** representative map and **one** label row,
against (C1')'s two and three. So the per-time datum is the same `(C, rt, L)` triple `(C0)` uses,
no new datum type is introduced, and the collapse runs against the **same** `cohWindowLo` /
`cohWindowHi` and the same `exists_window_repr`. (C5) is therefore cheaper to decide than (C1'),
not more expensive.
-/

/--
The stability clause a single closure member imposes at a position, at explicit data.

`rt` is the representative map at the time and `Lt` the per-lasso labels there. Only the `stab`
arm is non-trivial; every other constructor is the business of (C0), (C1') or (C3).
-/
def stabClauseAt {n : ℕ} (rt : Fin n → Fin n) (Lt : Fin n → Finset PlusFormula) (i : Fin n) :
    PlusFormula → Prop
  | PlusFormula.atom _ => True
  | PlusFormula.bot => True
  | PlusFormula.imp _ _ => True
  | PlusFormula.box _ => True
  | PlusFormula.untl _ _ => True
  | PlusFormula.snce _ _ => True
  | PlusFormula.stab φ => (PlusFormula.stab φ ∈ Lt i ↔ ∀ j : Fin n, rt i = rt j → φ ∈ Lt j)

/-- `stabClauseAt` is decidable at every formula: its one quantifier ranges over a `Fintype`. -/
instance instDecidableStabClauseAt {n : ℕ} (rt : Fin n → Fin n)
    (Lt : Fin n → Finset PlusFormula) (i : Fin n) : DecidablePred (stabClauseAt rt Lt i) := by
  intro ψ
  cases ψ <;> (dsimp only [stabClauseAt]; infer_instance)

/-- (C5)'s content at explicit data — the same `(C, rt, Lt)` triple `plusAtomCoherentData`
takes. -/
def stabFaithfulData {n : ℕ} (C : Finset PlusFormula) (rt : Fin n → Fin n)
    (Lt : Fin n → Finset PlusFormula) : Prop :=
  ∀ i : Fin n, ∀ ψ ∈ C, stabClauseAt rt Lt i ψ

instance instDecidableStabFaithfulData {n : ℕ} (C : Finset PlusFormula) (rt : Fin n → Fin n)
    (Lt : Fin n → Finset PlusFormula) : Decidable (stabFaithfulData C rt Lt) := by
  dsimp only [stabFaithfulData]
  infer_instance

/-- **(C5) at a single time.** -/
def StabFaithfulAt (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) : Prop :=
  stabFaithfulData (plusClosureOf (Γ ++ Del)) (S.rep t) (fun i => S.L i t)

instance decidableStabFaithfulAt (S : PlusSharingWitnessFamily Γ Del) (t : ℤ) :
    Decidable (S.StabFaithfulAt t) := by
  dsimp only [StabFaithfulAt]
  infer_instance

/-- **(C5) is exactly its closure-gated form at every time.** -/
theorem stabFaithful_iff_at (S : PlusSharingWitnessFamily Γ Del) :
    S.StabFaithful ↔ ∀ t : ℤ, S.StabFaithfulAt t := by
  constructor
  · intro h t i ψ hψ
    cases ψ with
    | atom _ => trivial
    | bot => trivial
    | imp _ _ => trivial
    | box _ => trivial
    | untl _ _ => trivial
    | snce _ _ => trivial
    | stab φ => exact h i t φ hψ
  · intro h i u φ hc
    exact h u i _ hc

/-- The per-time check reads only the representative map and the labels at that time — the same
two arguments `plusAtomCoherentAt_congr` reads. -/
theorem stabFaithfulAt_congr (S : PlusSharingWitnessFamily Γ Del) {t t' : ℤ}
    (hr : S.rep t = S.rep t') (hL : ∀ i, S.L i t = S.L i t') :
    S.StabFaithfulAt t ↔ S.StabFaithfulAt t' := by
  have hLf : (fun i => S.L i t) = (fun i => S.L i t') := funext hL
  simp only [StabFaithfulAt, hr, hLf]

/-- **(C5) collapses to the combined window**, against the same window and the same
`exists_window_repr` as (C0). -/
theorem stabFaithful_iff_window (S : PlusSharingWitnessFamily Γ Del) :
    S.StabFaithful ↔
      ∀ t : ℤ, S.cohWindowLo ≤ t → t < S.cohWindowHi → S.StabFaithfulAt t := by
  rw [S.stabFaithful_iff_at]
  constructor
  · intro h t _ _; exact h t
  · intro h t
    obtain ⟨t', hlo, hhi, hr0, _, _, hL0, _⟩ := S.exists_window_repr t
    exact (S.stabFaithfulAt_congr hr0 hL0).mpr (h t' hlo hhi)

/--
**(C5) decides**, by a bounded scan of the combined window.

This is the hard constraint discharged: the condition is decided by finitely many checks, each
over `Fin S.lassos.length × Fin S.lassos.length` at one time, and the branching frame's
infinitely many walks are nowhere in the computation.
-/
instance decidableStabFaithful (S : PlusSharingWitnessFamily Γ Del) : Decidable S.StabFaithful :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico S.cohWindowLo S.cohWindowHi, S.StabFaithfulAt t)
    (by
      rw [S.stabFaithful_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

section Instances

variable (S : PlusSharingWitnessFamily Γ Del)

example : Decidable S.PlusAtomCoherent := inferInstance
example : Decidable S.PlusLocalCoherentShare := inferInstance
example : Decidable S.StabFaithful := inferInstance

end Instances

/-! ## A computed smoke test

The `#guard`s below are not a proof of anything about the device; they are a check that the three
`Decidable` instances **compute** rather than merely elaborate. Each names its instance explicitly
rather than letting synthesis pick one, so what runs is the instance this module exports.

The family is the one-lasso family at the closure of `⊡p`, whose target closure is `{⊡p, p}`.
The (C5) check is therefore not vacuous: it has a `stab` closure member to test, and on this
family it passes because `⊡p` and `p` are both labelled everywhere.
-/

section SmokeTest

open FormalSystem.Syntax

/-- The atom the smoke test runs at. -/
private def smokeAtom : Atom := Atom.mkBase "p"

/-- The context the smoke-test family certifies against: `⊡p` alone. -/
private def smokeCtx : PlusContext := [PlusFormula.stab (PlusFormula.atom smokeAtom)]

/-- The one lasso of the smoke-test family: every position labelled with the whole closure. -/
private def smokeLasso :
    PlusLabelledLasso (plusClosureOf (smokeCtx ++ ([] : PlusContext))) where
  back := [plusClosureOf (smokeCtx ++ ([] : PlusContext))]
  mid := []
  fwd := [plusClosureOf (smokeCtx ++ ([] : PlusContext))]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = plusClosureOf (smokeCtx ++ ([] : PlusContext)) := by simpa using hX
    subst hE
    exact Finset.Subset.refl _

/-- The smoke-test family: one lasso, identity representatives. -/
private def smokeFamily : PlusSharingWitnessFamily smokeCtx ([] : PlusContext) where
  bx := fun _ => false
  lassos := [smokeLasso]
  lassos_ne := by simp
  repBack := [id]
  repMid := []
  repFwd := [id]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf
    have hI : f = id := by simpa using hf
    subst hI
    intro i
    rfl

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
set_option linter.hashCommand false in
#guard @Decidable.decide _ (PlusSharingWitnessFamily.decidableStabFaithful smokeFamily)

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
set_option linter.hashCommand false in
#guard @Decidable.decide _ (PlusSharingWitnessFamily.decidablePlusAtomCoherent smokeFamily)

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
set_option linter.hashCommand false in
#guard @Decidable.decide _ (PlusSharingWitnessFamily.decidablePlusLocalCoherentShare smokeFamily)

end SmokeTest

end PlusSharingWitnessFamily

/-! ## The global-membership window, and the (C3)/(C4) instances

(C3) `PlusBoxFaithful` reads `bx χ = true ↔ ∀ i t, χ ∈ W.L i t` — an unbounded quantifier over
ℤ on the right — and (C4) `PlusTarget` reads two list scans at a single time. Both are decided
here rather than in the earlier condition-by-condition sections, because (C3)'s collapse is the
one window argument in this module that reads **no neighbours**: one period on each side
suffices, where the local checks need two.
-/

namespace PlusLabelledLasso

variable {C : Finset PlusFormula}

/-- A formula present throughout one full backward period is present at **every** negative
position. -/
theorem mem_all_neg_of_period (Λ : PlusLabelledLasso C) {g : PlusFormula} {a : ℤ}
    (ha : a + Λ.nb < 0) (h : ∀ r : ℤ, a < r → r ≤ a + Λ.nb → g ∈ Λ.lab r) :
    ∀ r : ℤ, r < 0 → g ∈ Λ.lab r := by
  intro r hr
  have hnb := Λ.nb_pos
  set r' : ℤ := (a + 1) + (r - (a + 1)) % Λ.nb with hr'
  have hlo : a + 1 ≤ r' := by
    have : 0 ≤ (r - (a + 1)) % Λ.nb := Int.emod_nonneg _ (by omega)
    omega
  have hhi : r' < (a + 1) + Λ.nb := by
    have : (r - (a + 1)) % Λ.nb < Λ.nb := Int.emod_lt_of_pos _ hnb
    omega
  have hres : r' % Λ.nb = r % Λ.nb := LabelledLasso.reduce_emod Λ.nb (a + 1) r
  have hlab : Λ.lab r = Λ.lab r' := Λ.lab_congr_back hr (by omega) hres.symm
  rw [hlab]
  exact h r' (by omega) (by omega)

/-- A formula present throughout one full forward period is present at **every** position at or
beyond the window. -/
theorem mem_all_fwd_of_period (Λ : PlusLabelledLasso C) {g : PlusFormula} {b : ℤ}
    (hb : Λ.nm ≤ b) (h : ∀ r : ℤ, b ≤ r → r < b + Λ.nf → g ∈ Λ.lab r) :
    ∀ r : ℤ, Λ.nm ≤ r → g ∈ Λ.lab r := by
  intro r hr
  have hnf := Λ.nf_pos
  set r' : ℤ := b + (r - b) % Λ.nf with hr'
  have hlo : b ≤ r' := by
    have : 0 ≤ (r - b) % Λ.nf := Int.emod_nonneg _ (by omega)
    omega
  have hhi : r' < b + Λ.nf := by
    have : (r - b) % Λ.nf < Λ.nf := Int.emod_lt_of_pos _ hnf
    omega
  have hres : r' % Λ.nf = r % Λ.nf := LabelledLasso.reduce_emod Λ.nf b r
  have hres' : (r' - Λ.nm) % Λ.nf = (r - Λ.nm) % Λ.nf := by
    rw [Int.sub_emod, Int.sub_emod r, hres]
  have hlab : Λ.lab r = Λ.lab r' := Λ.lab_congr_fwd hr (by omega) hres'.symm
  rw [hlab]
  exact h r' (by omega) (by omega)

/-- **Global label membership collapses to one finite window** of width
`|back| + |mid| + |fwd|`. -/
theorem mem_all_iff_window (Λ : PlusLabelledLasso C) (χ : PlusFormula) :
    (∀ t : ℤ, χ ∈ Λ.lab t) ↔ ∀ t ∈ Finset.Ico (-Λ.nb) (Λ.nm + Λ.nf), χ ∈ Λ.lab t := by
  have hnb := Λ.nb_pos
  have hnf := Λ.nf_pos
  have hnm := Λ.nm_nonneg
  constructor
  · intro h t _; exact h t
  · intro h
    have hwin : ∀ r : ℤ, -Λ.nb ≤ r → r < Λ.nm + Λ.nf → χ ∈ Λ.lab r :=
      fun r h1 h2 => h r (Finset.mem_Ico.mpr ⟨h1, h2⟩)
    intro t
    rcases lt_or_ge t 0 with hneg | hnn
    · refine Λ.mem_all_neg_of_period (a := -Λ.nb - 1) (by omega) ?_ t hneg
      intro r hr1 hr2
      exact hwin r (by omega) (by omega)
    rcases lt_or_ge t Λ.nm with hmid | hfar
    · exact hwin t (by omega) (by omega)
    · refine Λ.mem_all_fwd_of_period (b := Λ.nm) le_rfl ?_ t hfar
      intro r hr1 hr2
      exact hwin r (by omega) (by omega)

end PlusLabelledLasso

namespace PlusWitnessFamily

variable {Γ Del : PlusContext}

/-- Global membership along one lasso collapses to that lasso's own window. Stated at `W.L` so
that instance search matches the form `PlusBoxFaithful` actually uses. -/
theorem mem_all_iff_window (W : PlusWitnessFamily Γ Del) (i : Fin W.lassos.length)
    (χ : PlusFormula) :
    (∀ t : ℤ, χ ∈ W.L i t) ↔
      ∀ t ∈ Finset.Ico (-(W.lassos.get i).nb) ((W.lassos.get i).nm + (W.lassos.get i).nf),
        χ ∈ W.L i t :=
  PlusLabelledLasso.mem_all_iff_window (W.lassos.get i) χ

/-- Global membership along one lasso is decidable. -/
instance instDecidablePlusMemAll (W : PlusWitnessFamily Γ Del) (i : Fin W.lassos.length)
    (χ : PlusFormula) : Decidable (∀ t : ℤ, χ ∈ W.L i t) :=
  decidable_of_iff _ (W.mem_all_iff_window i χ).symm

/-- The box-faithfulness clause a single closure member imposes. Only boxed formulas impose
anything; this is what turns `PlusBoxFaithful`'s unbounded `∀ χ : PlusFormula` into a `Finset`
quantifier. The `stab` case is `True` here — `⊡` is not history- and time-independent, and (C5)
is what pins it. -/
def plusBoxClause (W : PlusWitnessFamily Γ Del) : PlusFormula → Prop
  | PlusFormula.box χ => (W.bx χ = true ↔ ∀ (i : Fin W.lassos.length) (t : ℤ), χ ∈ W.L i t)
  | _ => True

/-- `plusBoxClause` is decidable at every L⁺ formula, by `instDecidablePlusMemAll` and
finiteness of the lasso index. -/
instance instDecidablePlusBoxClause (W : PlusWitnessFamily Γ Del) :
    DecidablePred W.plusBoxClause := by
  intro ψ
  cases ψ <;> (dsimp only [plusBoxClause]; infer_instance)

/-- Box faithfulness is exactly `plusBoxClause` at every closure member. -/
theorem plusBoxFaithful_iff_forall (W : PlusWitnessFamily Γ Del) :
    W.PlusBoxFaithful ↔ ∀ ψ ∈ plusClosureOf (Γ ++ Del), W.plusBoxClause ψ := by
  constructor
  · intro h ψ hψ
    cases ψ with
    | atom p => trivial
    | bot => trivial
    | imp a b => trivial
    | box χ => exact h χ hψ
    | untl g e => trivial
    | snce g e => trivial
    | stab χ => trivial
  · intro h χ hχ
    exact h (PlusFormula.box χ) hχ

/-- **(C3) decides** by the `mid` window plus the two periodicities. -/
instance decidablePlusBoxFaithful (W : PlusWitnessFamily Γ Del) : Decidable W.PlusBoxFaithful :=
  decidable_of_iff _ (W.plusBoxFaithful_iff_forall).symm

/-- **(C4) decides** outright, by two list scans. -/
instance decidablePlusTarget (W : PlusWitnessFamily Γ Del) (t : ℤ) :
    Decidable (W.PlusTarget t) := by
  dsimp only [PlusTarget]
  infer_instance

end PlusWitnessFamily

end FormalSystem.Metalogic.Decidability
