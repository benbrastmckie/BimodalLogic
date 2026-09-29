/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Decide
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Predicates

/-!
# Deciding the State-Sharing Certificate Predicates

`Sharing/Predicates.lean` states (C0) `AtomCoherent` and (C1') `LocalCoherentShare`, both
quantified over all of `ℤ`. This module collapses each to a finite window scan, exactly as
`WitnessFamily/Decide.lean` does for the deterministic conditions, and derives the two
`Decidable` instances.

## Why a *combined* window, and not one window per lasso

`Decide.lean`'s `decidableLocalCoherentLab` decomposes the family condition into one condition
per lasso (`localCoherentLab_iff_lassos`) and scans each lasso's own window
`[-2|back_i|, |mid_i| + 2|fwd_i|)`. That decomposition is available there precisely because the
deterministic conditions never mention two lassos at once.

Both sharing conditions do. `AtomCoherent` compares `L i u` with `L j u`, and
`LocalCoherentShare`'s temporal clauses compare `L i t` with `L j (t ± 1)` across a
`share`-linked pair. The per-lasso decomposition is therefore unavailable, and the reduction
needs a **single** window on which *every* lasso's labels and the representative maps are all
simultaneously periodic.

That is what `perBack`, `perFwd` and `perMid` supply:

* `perBack` is `|repBack|` times the product of every `|back_i|`, hence a positive common
  multiple of all of them;
* `perFwd` is the same for the rightward cycles;
* `perMid` is `|repMid|` plus the sum of every `|mid_i|`, hence at least each of them, so past
  `perMid` every rightward decoding — labels and representatives alike — is in its periodic
  region.

Common *multiple* rather than least common multiple: nothing below needs minimality, and the
product is a one-line definition whose divisibility facts are `List.dvd_prod` off the shelf.
The window is wider than necessary; the reduction it licenses is the same.

## The scope hypothesis this phase was given, and what was found

The phase asserted that the combined window is "the label window widened only by the `share`
period". That is right in direction and wrong in detail, and the correction is recorded here
rather than silently absorbed: the label windows of *different lassos* also have to be
reconciled with each other, not only with the `share` period, because the sharing conditions
couple lassos. Hence a common multiple across the whole family, not a widening of one lasso's
window.

It also asserted that four of the existing `Decidable` instances apply to a sharing family's
`toWitnessFamily` unchanged. That is confirmed at the foot of this module by `#check`:
`decidableBoxFaithful`, `instDecidableMemAll`, `instDecidableBoxClause` and `decidableTarget`
all elaborate at `S.toWitnessFamily`, and in fact so do `decidableLocalCoherentLab`,
`decidableFulfillingLab` and `decidableCertifies` — the count is seven, not four, because
nothing in `Decide.lean` looks at the sharing datum at all.

## Closure-gated clauses, and why the atom condition needs one

(C0) as stated quantifies over `∀ p : Atom`, and `Atom` is `Infinite`. The condition is still
decidable, because a label is a subset of `closureOf (Γ ++ Del)` and so an atom outside that
closure is absent from both sides. `atomClauseAt` is the closure-member form, and
`atomCoherent_iff_at` is the equivalence; the same device turns (C1')'s four
`∀ a b : Formula, … ∈ closureOf …` clauses into a scan of a `Finset`, as `labClauseAt` does for
the deterministic condition.

## Main Definitions

- `SharingWitnessFamily.perBack` / `perFwd` / `perMid` — the combined periods
- `SharingWitnessFamily.AtomCoherentAt` / `CoherentShareAt` — the two conditions at one time
- `SharingWitnessFamily.cohWindowLo` / `cohWindowHi` — the combined window

## Main Results

- `SharingWitnessFamily.exists_window_repr` — every time has a data-equal window representative
- `SharingWitnessFamily.atomCoherent_iff_window` — (C0) collapses to the window
- `SharingWitnessFamily.localCoherentShare_iff_window` — (C1') collapses to the window
- `SharingWitnessFamily.decidableAtomCoherent` / `decidableLocalCoherentShare`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

namespace Periodic

variable {α : Type*}

/--
Negative positions with equal residues modulo the backward period decode equally.

Stated with the `Inhabited` argument **explicit**: the representative-map decoding of
`Sharing/Basic.lean` runs at `repIdInhabited`, which is deliberately not an instance.
-/
theorem unrollOf_congr_back (inst : Inhabited α) (back mid fwd : List α) {u v : ℤ}
    (hu : u < 0) (hv : v < 0)
    (h : u % (back.length : ℤ) = v % (back.length : ℤ)) :
    @unrollOf α inst back mid fwd u = @unrollOf α inst back mid fwd v := by
  rw [@unrollOf_neg α inst back mid fwd u hu, @unrollOf_neg α inst back mid fwd v hv]
  exact @cyc_congr α inst back u v h

/-- Positions at or beyond the window with equal residues modulo the forward period decode
equally. -/
theorem unrollOf_congr_fwd (inst : Inhabited α) (back mid fwd : List α) {u v : ℤ}
    (hu : (mid.length : ℤ) ≤ u) (hv : (mid.length : ℤ) ≤ v)
    (h : (u - (mid.length : ℤ)) % (fwd.length : ℤ)
        = (v - (mid.length : ℤ)) % (fwd.length : ℤ)) :
    @unrollOf α inst back mid fwd u = @unrollOf α inst back mid fwd v := by
  rw [@unrollOf_fwd α inst back mid fwd u hu, @unrollOf_fwd α inst back mid fwd v hv]
  exact @cyc_congr α inst fwd _ _ h

end Periodic

/-- Equal residues at a multiple descend to equal residues at a divisor. -/
theorem emod_of_dvd {n N u v : ℤ} (hd : n ∣ N) (h : u % N = v % N) : u % n = v % n := by
  rw [← Int.emod_emod_of_dvd u hd, h, Int.emod_emod_of_dvd v hd]

namespace SharingWitnessFamily

variable {Γ Del : Context}

/-! ## The combined periods -/

/-- A product of positive naturals is positive. -/
private theorem list_prod_pos {l : List ℕ} (h : ∀ a ∈ l, 0 < a) : 0 < l.prod := by
  induction l with
  | nil => simp
  | cons a t ih =>
      rw [List.prod_cons]
      exact Nat.mul_pos (h a (by simp)) (ih fun b hb => h b (by simp [hb]))

/-- A member of a list of naturals is at most the list's sum. -/
private theorem le_sum_of_mem {l : List ℕ} {a : ℕ} (h : a ∈ l) : a ≤ l.sum := by
  induction l with
  | nil => cases h
  | cons b t ih =>
      rw [List.sum_cons]
      rcases List.mem_cons.mp h with rfl | h'
      · exact Nat.le_add_right _ _
      · exact le_trans (ih h') (Nat.le_add_left _ _)

/-- A lasso's index is a member of the family's lasso list. -/
theorem get_mem (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) :
    S.lassos.get i ∈ S.lassos := by
  rw [List.get_eq_getElem]
  exact List.getElem_mem i.isLt

/--
**The combined backward period**: a positive common multiple of `|repBack|` and of every
lasso's `|back|`. See this module's header for why a family-wide multiple is needed.
-/
def perBack (S : SharingWitnessFamily Γ Del) : ℕ :=
  S.repBack.length * (S.lassos.map (fun Λ => Λ.back.length)).prod

/-- **The combined forward period**, the rightward mirror of `perBack`. -/
def perFwd (S : SharingWitnessFamily Γ Del) : ℕ :=
  S.repFwd.length * (S.lassos.map (fun Λ => Λ.fwd.length)).prod

/--
**The combined window offset**: at or past it, every rightward decoding of the family — labels
and representative maps alike — is in its periodic region. A sum rather than a maximum, so that
`List.single_le_sum` discharges the comparisons.
-/
def perMid (S : SharingWitnessFamily Γ Del) : ℕ :=
  S.repMid.length + (S.lassos.map (fun Λ => Λ.mid.length)).sum

/-- The combined backward period, as an integer. -/
abbrev NB (S : SharingWitnessFamily Γ Del) : ℤ := (S.perBack : ℤ)

/-- The combined forward period, as an integer. -/
abbrev NF (S : SharingWitnessFamily Γ Del) : ℤ := (S.perFwd : ℤ)

/-- The combined window offset, as an integer. -/
abbrev NM (S : SharingWitnessFamily Γ Del) : ℤ := (S.perMid : ℤ)

theorem NB_pos (S : SharingWitnessFamily Γ Del) : 0 < S.NB := by
  refine Int.natCast_pos.mpr (Nat.mul_pos ?_ (list_prod_pos ?_))
  · exact List.length_pos_of_ne_nil S.repBack_ne
  · intro a ha
    obtain ⟨Λ, _, rfl⟩ := List.mem_map.mp ha
    exact List.length_pos_of_ne_nil Λ.back_ne

theorem NF_pos (S : SharingWitnessFamily Γ Del) : 0 < S.NF := by
  refine Int.natCast_pos.mpr (Nat.mul_pos ?_ (list_prod_pos ?_))
  · exact List.length_pos_of_ne_nil S.repFwd_ne
  · intro a ha
    obtain ⟨Λ, _, rfl⟩ := List.mem_map.mp ha
    exact List.length_pos_of_ne_nil Λ.fwd_ne

theorem NM_nonneg (S : SharingWitnessFamily Γ Del) : 0 ≤ S.NM := Int.natCast_nonneg _

theorem nbr_dvd_NB (S : SharingWitnessFamily Γ Del) : S.nbr ∣ S.NB :=
  Int.natCast_dvd_natCast.mpr ⟨_, rfl⟩

theorem nfr_dvd_NF (S : SharingWitnessFamily Γ Del) : S.nfr ∣ S.NF :=
  Int.natCast_dvd_natCast.mpr ⟨_, rfl⟩

theorem nmr_le_NM (S : SharingWitnessFamily Γ Del) : S.nmr ≤ S.NM := by
  exact_mod_cast Nat.le_add_right S.repMid.length _

theorem lasso_nb_dvd_NB (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) :
    (S.lassos.get i).nb ∣ S.NB := by
  refine Int.natCast_dvd_natCast.mpr (Dvd.dvd.mul_left ?_ _)
  exact List.dvd_prod (List.mem_map.mpr ⟨_, S.get_mem i, rfl⟩)

theorem lasso_nf_dvd_NF (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) :
    (S.lassos.get i).nf ∣ S.NF := by
  refine Int.natCast_dvd_natCast.mpr (Dvd.dvd.mul_left ?_ _)
  exact List.dvd_prod (List.mem_map.mpr ⟨_, S.get_mem i, rfl⟩)

theorem lasso_nm_le_NM (S : SharingWitnessFamily Γ Del) (i : Fin S.lassos.length) :
    (S.lassos.get i).nm ≤ S.NM := by
  have h : (S.lassos.get i).mid.length ≤ S.perMid := by
    refine le_trans ?_ (Nat.le_add_left _ _)
    exact le_sum_of_mem (List.mem_map.mpr ⟨_, S.get_mem i, rfl⟩)
  exact_mod_cast h

/-! ## The representative maps read only their residue -/

theorem rep_congr_back (S : SharingWitnessFamily Γ Del) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % S.nbr = v % S.nbr) : S.rep u = S.rep v :=
  Periodic.unrollOf_congr_back (repIdInhabited _) S.repBack S.repMid S.repFwd hu hv h

theorem rep_congr_fwd (S : SharingWitnessFamily Γ Del) {u v : ℤ} (hu : S.nmr ≤ u)
    (hv : S.nmr ≤ v) (h : (u - S.nmr) % S.nfr = (v - S.nmr) % S.nfr) : S.rep u = S.rep v :=
  Periodic.unrollOf_congr_fwd (repIdInhabited _) S.repBack S.repMid S.repFwd hu hv h

/-! ## The succession matrices read only their residue

The `rep_congr_*` family's twin for the fourth datum. The length fields make the succession
cycles carry the representatives' own periods, so these need no divisibility hypothesis of their
own beyond the ones `nbr_dvd_NB` and `nfr_dvd_NF` already supply.
-/

/-- Negative times with equal residues modulo the succession cycle decode equally. -/
theorem transRaw_congr_back (S : SharingWitnessFamily Γ Del) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % S.nbr = v % S.nbr) : S.transRaw u = S.transRaw v :=
  Periodic.unrollOf_congr_back (transEqInhabited _) S.transBack S.transMid S.transFwd hu hv
    (by rw [S.transBack_len]; exact h)

/-- Times at or past the window with equal residues modulo the succession cycle decode equally. -/
theorem transRaw_congr_fwd (S : SharingWitnessFamily Γ Del) {u v : ℤ} (hu : S.nmr ≤ u)
    (hv : S.nmr ≤ v) (h : (u - S.nmr) % S.nfr = (v - S.nmr) % S.nfr) :
    S.transRaw u = S.transRaw v :=
  Periodic.unrollOf_congr_fwd (transEqInhabited _) S.transBack S.transMid S.transFwd
    (by rw [S.transMid_len]; exact hu) (by rw [S.transMid_len]; exact hv)
    (by rw [S.transMid_len, S.transFwd_len]; exact h)

/-- **Leftward congruence at the combined period**, for succession. -/
theorem transRaw_congr_NB (S : SharingWitnessFamily Γ Del) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % S.NB = v % S.NB) : S.transRaw u = S.transRaw v :=
  S.transRaw_congr_back hu hv (emod_of_dvd S.nbr_dvd_NB h)

/-- **Rightward congruence at the combined period**, for succession. -/
theorem transRaw_congr_NF (S : SharingWitnessFamily Γ Del) {u v : ℤ} (hu : S.NM ≤ u)
    (hv : S.NM ≤ v) (h : (u - S.NM) % S.NF = (v - S.NM) % S.NF) :
    S.transRaw u = S.transRaw v := by
  have h1 : (u - S.NM) % S.nfr = (v - S.NM) % S.nfr := emod_of_dvd S.nfr_dvd_NF h
  have h2 : ((u - S.NM) + (S.NM - S.nmr)) % S.nfr = ((v - S.NM) + (S.NM - S.nmr)) % S.nfr :=
    LabelledLasso.emod_shift h1
  rw [show (u - S.NM) + (S.NM - S.nmr) = u - S.nmr by omega,
    show (v - S.NM) + (S.NM - S.nmr) = v - S.nmr by omega] at h2
  exact S.transRaw_congr_fwd (le_trans S.nmr_le_NM hu) (le_trans S.nmr_le_NM hv) h2

/-! ## The family's whole per-time datum reads only its residue -/

/--
**Leftward data congruence.** At two negative times congruent modulo the combined backward
period, the representative map and every lasso's label agree.
-/
theorem data_congr_back (S : SharingWitnessFamily Γ Del) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % S.NB = v % S.NB) : S.rep u = S.rep v ∧ ∀ i, S.L i u = S.L i v := by
  refine ⟨S.rep_congr_back hu hv (emod_of_dvd S.nbr_dvd_NB h), fun i => ?_⟩
  exact (S.lassos.get i).lab_congr_back hu hv (emod_of_dvd (S.lasso_nb_dvd_NB i) h)

/--
**Rightward data congruence.** At or past the combined window offset, at two times congruent
modulo the combined forward period, the representative map and every lasso's label agree.
-/
theorem data_congr_fwd (S : SharingWitnessFamily Γ Del) {u v : ℤ} (hu : S.NM ≤ u)
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
def cohWindowLo (S : SharingWitnessFamily Γ Del) : ℤ := -2 * S.NB

/-- Upper end (exclusive) of the combined window. -/
def cohWindowHi (S : SharingWitnessFamily Γ Del) : ℤ := S.NM + 2 * S.NF

/--
**Every time has a representative in the combined window carrying the same data**, at the
representative's whole one-step neighbourhood.

Two periods wide on each side rather than one, for the same reason as `coherent_iff_window`:
(C1') reads `t - 1` and `t + 1` as well as `t`, so a representative must have its whole
neighbourhood inside the periodic region.
-/
theorem exists_window_repr (S : SharingWitnessFamily Γ Del) (t : ℤ) :
    ∃ t' : ℤ, S.cohWindowLo ≤ t' ∧ t' < S.cohWindowHi ∧
      S.rep t = S.rep t' ∧ S.rep (t + 1) = S.rep (t' + 1) ∧
      S.transRaw t = S.transRaw t' ∧ S.transRaw (t - 1) = S.transRaw (t' - 1) ∧
      (∀ i, S.L i (t - 1) = S.L i (t' - 1)) ∧ (∀ i, S.L i t = S.L i t') ∧
      (∀ i, S.L i (t + 1) = S.L i (t' + 1)) := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  rcases lt_or_ge t (-1) with hfar | hmid
  · -- far left: represent `t` in `[-2·NB, -NB)`, whose whole neighbourhood is negative
    refine ⟨t % S.NB - 2 * S.NB, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
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
        | exact S.transRaw_congr_NB (by omega) (by omega) hres
        | exact S.transRaw_congr_NB (by omega) (by omega) hresm
        | exact (S.data_congr_back (by omega) (by omega) hresm).2
        | exact (S.data_congr_back (by omega) (by omega) hres).2
        | exact (S.data_congr_back (by omega) (by omega) hresp).2
    }
  rcases le_or_gt t S.NM with hin | hfar
  · -- middle: already inside the window
    exact ⟨t, by simp only [cohWindowLo]; omega, by simp only [cohWindowHi]; omega,
      rfl, rfl, rfl, rfl, fun _ => rfl, fun _ => rfl, fun _ => rfl⟩
  · -- far right: represent `t` in `[NM + NF, NM + 2·NF)`
    refine ⟨S.NM + (t - S.NM) % S.NF + S.NF, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
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
        | exact S.transRaw_congr_NF (by omega) (by omega) hres
        | exact S.transRaw_congr_NF (by omega) (by omega) hresm
        | exact (S.data_congr_fwd (by omega) (by omega) hresm).2
        | exact (S.data_congr_fwd (by omega) (by omega) hres).2
        | exact (S.data_congr_fwd (by omega) (by omega) hresp).2
    }

/-! ## (C0) at a single time

`AtomCoherent` quantifies over `∀ p : Atom`, and `Atom` is `Infinite`. The closure-gated form
below is equivalent — an atom outside `closureOf (Γ ++ Del)` is absent from both labels, since
every label is a subset of the closure — and it is the form that decides.
-/

/-- The atom clause a single closure member imposes at a pair of labels. -/
def atomClauseAt (Li Lj : Finset Formula) : Formula → Prop
  | Formula.atom p => (Formula.atom p ∈ Li ↔ Formula.atom p ∈ Lj)
  | Formula.bot => True
  | Formula.imp _ _ => True
  | Formula.box _ => True
  | Formula.untl _ _ => True
  | Formula.snce _ _ => True

/-- `atomClauseAt` is decidable at every formula. -/
instance instDecidableAtomClauseAt (Li Lj : Finset Formula) :
    DecidablePred (atomClauseAt Li Lj) := by
  intro ψ
  cases ψ <;> (dsimp only [atomClauseAt]; infer_instance)

/--
(C0)'s content at explicit data: one representative map and one label per lasso.

Stated at the data rather than at `S` and `t`, so that the window congruence is a `rw` of the
two arguments rather than a hand-transport through the quantifiers.
-/
def atomCoherentData {n : ℕ} (C : Finset Formula) (rt : Fin n → Fin n)
    (Lt : Fin n → Finset Formula) : Prop :=
  ∀ i j : Fin n, rt i = rt j → ∀ ψ ∈ C, atomClauseAt (Lt i) (Lt j) ψ

instance instDecidableAtomCoherentData {n : ℕ} (C : Finset Formula) (rt : Fin n → Fin n)
    (Lt : Fin n → Finset Formula) : Decidable (atomCoherentData C rt Lt) := by
  dsimp only [atomCoherentData]
  infer_instance

/-- **(C0) at a single time.** -/
def AtomCoherentAt (S : SharingWitnessFamily Γ Del) (t : ℤ) : Prop :=
  atomCoherentData (closureOf (Γ ++ Del)) (S.rep t) (fun i => S.L i t)

instance decidableAtomCoherentAt (S : SharingWitnessFamily Γ Del) (t : ℤ) :
    Decidable (S.AtomCoherentAt t) := by
  dsimp only [AtomCoherentAt]
  infer_instance

/-- **(C0) is exactly its closure-gated form at every time.** -/
theorem atomCoherent_iff_at (S : SharingWitnessFamily Γ Del) :
    S.AtomCoherent ↔ ∀ t : ℤ, S.AtomCoherentAt t := by
  constructor
  · intro h t i j hij ψ _
    cases ψ with
    | atom p => exact h t i j hij p
    | bot => trivial
    | imp _ _ => trivial
    | box _ => trivial
    | untl _ _ => trivial
    | snce _ _ => trivial
  · intro h t i j hij p
    by_cases hc : Formula.atom p ∈ closureOf (Γ ++ Del)
    · exact h t i j hij _ hc
    · constructor
      · intro hm; exact absurd (S.subset_closureOf i t hm) hc
      · intro hm; exact absurd (S.subset_closureOf j t hm) hc

/-- The per-time check reads only the representative map and the labels at that time. -/
theorem atomCoherentAt_congr (S : SharingWitnessFamily Γ Del) {t t' : ℤ}
    (hr : S.rep t = S.rep t') (hL : ∀ i, S.L i t = S.L i t') :
    S.AtomCoherentAt t ↔ S.AtomCoherentAt t' := by
  have hLf : (fun i => S.L i t) = (fun i => S.L i t') := funext hL
  simp only [AtomCoherentAt, hr, hLf]

/-! ## (C1') at a single time -/

/--
The local clause a single closure member imposes on a sharing family, at explicit data.

`rt`, `rp` are the representative maps at `t` and `t + 1`; `tt`, `tm` the succession matrices at
`t` and `t - 1`; `Lm`, `Lt`, `Lp` the per-lasso labels at `t - 1`, `t` and `t + 1`. The `untl`
and `snce` clauses quantify over succession out of and into `t` respectively — that is the whole
difference from `labClauseAt`.

Each temporal side condition is spelled out as the pair the arrival-pruned `trans` is: the raw
succession bit, and the arrival share as an equality of representatives. Both halves are stated
here rather than folded into `trans` so that `Fin n`'s `DecidableEq` closes the instance below
with no unfolding.
-/
def shareClauseAt {n : ℕ} (bx : Formula → Bool) (rt rp : Fin n → Fin n)
    (tt tm : Fin n → Fin n → Bool)
    (Lm Lt Lp : Fin n → Finset Formula) (i : Fin n) : Formula → Prop
  | Formula.atom _ => True
  | Formula.bot => True
  | Formula.imp a b => (Formula.imp a b ∈ Lt i ↔ (a ∈ Lt i → b ∈ Lt i))
  | Formula.box χ => (Formula.box χ ∈ Lt i ↔ bx χ = true)
  | Formula.untl g e => ∀ j : Fin n, (tt i j = true ∧ rp i = rp j) →
      (Formula.untl g e ∈ Lt i ↔ (e ∈ Lp j ∨ (g ∈ Lp j ∧ Formula.untl g e ∈ Lp j)))
  | Formula.snce g e => ∀ k : Fin n, (tm k i = true ∧ rt k = rt i) →
      (Formula.snce g e ∈ Lt i ↔ (e ∈ Lm k ∨ (g ∈ Lm k ∧ Formula.snce g e ∈ Lm k)))

/-- `shareClauseAt` is decidable at every formula: the two new quantifiers range over a
`Fintype`. -/
instance instDecidableShareClauseAt {n : ℕ} (bx : Formula → Bool) (rt rp : Fin n → Fin n)
    (tt tm : Fin n → Fin n → Bool)
    (Lm Lt Lp : Fin n → Finset Formula) (i : Fin n) :
    DecidablePred (shareClauseAt bx rt rp tt tm Lm Lt Lp i) := by
  intro ψ
  cases ψ <;> (dsimp only [shareClauseAt]; infer_instance)

/-- (C1')'s content at explicit data. -/
def coherentShareData {n : ℕ} (bx : Formula → Bool) (C : Finset Formula)
    (rt rp : Fin n → Fin n) (tt tm : Fin n → Fin n → Bool)
    (Lm Lt Lp : Fin n → Finset Formula) : Prop :=
  ∀ i : Fin n, Formula.bot ∉ Lt i ∧ ∀ ψ ∈ C, shareClauseAt bx rt rp tt tm Lm Lt Lp i ψ

instance instDecidableCoherentShareData {n : ℕ} (bx : Formula → Bool) (C : Finset Formula)
    (rt rp : Fin n → Fin n) (tt tm : Fin n → Fin n → Bool)
    (Lm Lt Lp : Fin n → Finset Formula) :
    Decidable (coherentShareData bx C rt rp tt tm Lm Lt Lp) := by
  dsimp only [coherentShareData]
  infer_instance

/-- **(C1') at a single time.** -/
def CoherentShareAt (S : SharingWitnessFamily Γ Del) (t : ℤ) : Prop :=
  coherentShareData S.bx (closureOf (Γ ++ Del)) (S.rep t) (S.rep (t + 1))
    (S.transRaw t) (S.transRaw (t - 1))
    (fun i => S.L i (t - 1)) (fun i => S.L i t) (fun i => S.L i (t + 1))

instance decidableCoherentShareAt (S : SharingWitnessFamily Γ Del) (t : ℤ) :
    Decidable (S.CoherentShareAt t) := by
  dsimp only [CoherentShareAt]
  infer_instance

/-- **(C1') is exactly its closure-gated form at every time.** -/
theorem localCoherentShare_iff_at (S : SharingWitnessFamily Γ Del) :
    S.LocalCoherentShare ↔ ∀ t : ℤ, S.CoherentShareAt t := by
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
    | snce g e => exact fun k hk => hsnce k ((S.trans_pred_iff t k i).mpr hk) g e hψ
  · intro h i t
    obtain ⟨hbot, hcl⟩ := h t i
    exact ⟨hbot, fun a b hab => hcl _ hab, fun χ hχ => hcl _ hχ,
      fun j hj g e hge => hcl _ hge j hj,
      fun k hk g e hge => hcl _ hge k ((S.trans_pred_iff t k i).mp hk)⟩

/-- The per-position check reads only the representative maps at `t` and `t + 1` and the labels
at `t - 1`, `t` and `t + 1`. -/
theorem coherentShareAt_congr (S : SharingWitnessFamily Γ Del) {t t' : ℤ}
    (hr0 : S.rep t = S.rep t') (hr1 : S.rep (t + 1) = S.rep (t' + 1))
    (ht0 : S.transRaw t = S.transRaw t') (htm : S.transRaw (t - 1) = S.transRaw (t' - 1))
    (hm : ∀ i, S.L i (t - 1) = S.L i (t' - 1)) (h0 : ∀ i, S.L i t = S.L i t')
    (hp : ∀ i, S.L i (t + 1) = S.L i (t' + 1)) :
    S.CoherentShareAt t ↔ S.CoherentShareAt t' := by
  have em : (fun i => S.L i (t - 1)) = (fun i => S.L i (t' - 1)) := funext hm
  have e0 : (fun i => S.L i t) = (fun i => S.L i t') := funext h0
  have ep : (fun i => S.L i (t + 1)) = (fun i => S.L i (t' + 1)) := funext hp
  simp only [CoherentShareAt, hr0, hr1, ht0, htm, em, e0, ep]

/-! ## The two window collapses, and the two instances -/

/-- **(C0) collapses to the combined window.** -/
theorem atomCoherent_iff_window (S : SharingWitnessFamily Γ Del) :
    S.AtomCoherent ↔
      ∀ t : ℤ, S.cohWindowLo ≤ t → t < S.cohWindowHi → S.AtomCoherentAt t := by
  rw [S.atomCoherent_iff_at]
  constructor
  · intro h t _ _; exact h t
  · intro h t
    obtain ⟨t', hlo, hhi, hr0, _, _, _, _, hL0, _⟩ := S.exists_window_repr t
    exact (S.atomCoherentAt_congr hr0 hL0).mpr (h t' hlo hhi)

/-- **(C1') collapses to the combined window.** -/
theorem localCoherentShare_iff_window (S : SharingWitnessFamily Γ Del) :
    S.LocalCoherentShare ↔
      ∀ t : ℤ, S.cohWindowLo ≤ t → t < S.cohWindowHi → S.CoherentShareAt t := by
  rw [S.localCoherentShare_iff_at]
  constructor
  · intro h t _ _; exact h t
  · intro h t
    obtain ⟨t', hlo, hhi, hr0, hr1, ht0, htm, hm, h0, hp⟩ := S.exists_window_repr t
    exact (S.coherentShareAt_congr hr0 hr1 ht0 htm hm h0 hp).mpr (h t' hlo hhi)

/-- **(C0) decides** by a bounded scan of the combined window. -/
instance decidableAtomCoherent (S : SharingWitnessFamily Γ Del) : Decidable S.AtomCoherent :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico S.cohWindowLo S.cohWindowHi, S.AtomCoherentAt t)
    (by
      rw [S.atomCoherent_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

/-- **(C1') decides** by a bounded scan of the combined window. -/
instance decidableLocalCoherentShare (S : SharingWitnessFamily Γ Del) :
    Decidable S.LocalCoherentShare :=
  decidable_of_iff
    (∀ t ∈ Finset.Ico S.cohWindowLo S.cohWindowHi, S.CoherentShareAt t)
    (by
      rw [S.localCoherentShare_iff_window]
      constructor
      · intro h t hlo hhi; exact h t (Finset.mem_Ico.mpr ⟨hlo, hhi⟩)
      · intro h t ht
        obtain ⟨hlo, hhi⟩ := Finset.mem_Ico.mp ht
        exact h t hlo hhi)

/-! ## The inherited instances, confirmed at a sharing family

The phase that produced this module asserted that four of `Decide.lean`'s instances apply to a
sharing family's `toWitnessFamily` unchanged. Seven do: nothing in `Decide.lean` reads the
sharing datum, so every instance it exports is inherited. The count is recorded here rather
than left as a claim.
-/

section Inherited

variable (S : SharingWitnessFamily Γ Del)

example : Decidable S.AtomCoherent := inferInstance
example : Decidable S.LocalCoherentShare := inferInstance
example : Decidable S.toWitnessFamily.BoxFaithful := inferInstance
example (i : Fin S.lassos.length) (χ : Formula) : Decidable (∀ t : ℤ, χ ∈ S.L i t) :=
  inferInstance
example : DecidablePred S.toWitnessFamily.boxClause := inferInstance
example (t : ℤ) : Decidable (S.toWitnessFamily.Target t) := inferInstance
example : Decidable S.toWitnessFamily.LocalCoherentLab := inferInstance
example : Decidable S.toWitnessFamily.FulfillingLab := inferInstance
example (t : ℤ) : Decidable (S.toWitnessFamily.Certifies t) := inferInstance

end Inherited

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
