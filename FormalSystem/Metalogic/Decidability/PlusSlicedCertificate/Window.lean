/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Basic
import Mathlib.Data.Int.ModEq
import Mathlib.Data.Int.Interval

/-!
# The Combined Window: Folding the Slice Sequence and the Target Path Together

`Basic.lean`'s `exists_window_eq` folds `G.slice` and nothing else, and `forall_slab_iff_window`
folds `G.slab` and nothing else. **Neither folds a pair.** This module supplies the window that
does: one finite interval of times on which the slice sequence *and* the target path are both
decided.

## Why a combined window is needed at all

`PlusSlicedCertificate` carries `target : PlusGraphPath G.n (plusClosureOf (Γ ++ Del))` and **no
field whatsoever** relating the target path's periods to the certificate's own. `PlusGraphPath` has
its own `nb` / `nm` / `nf`, so `G.target.nb` and `G.nb` are unrelated integers. Any clause reading
the two objects *at the same time* — and the checker's existential side does exactly that, demanding
that the target path agree with `G.slab` on the state formulas at **every** time — is therefore a
`∀ t` claim over a conjunction with two independent period triples, and no single-source window
reduces it.

`NB` and `NF` are least common multiples of the certificate's own segment lengths and `NM` is a
maximum of them. They are quantities computed **from** the certificate, exactly as `-G.nb` and
`G.nm + G.nf` already are. **Nothing here bounds `n`, a period, or a lasso count**, and no theorem
below states such an inequality.

## Why the endpoints are doubled

`Fixture.live_not_determined_by_slice` proves that liveness at a time is not a function of the slice
at that time: in that certificate the slice and the position set at `-1` are literally those at
`-2`, and yet a position live at `-1` is occupied by no run at any time `≤ -2`. So the single-period
lower endpoint `-NB` is unsound — a fold that makes `-NB` its own predecessor asserts liveness at
`-1` on behalf of `-2` — while `-2 * NB` separates them, and the fixture's
`Fixture.not_exists_labRun_of_le_neg_two` holds uniformly on the whole left tail, so the doubled
endpoint is faithful there rather than merely wider.

The two demands are **independent and both are met here**: the combining absorbs the target path's
periods, the doubling separates the tail's first period from the rest. Every lemma below that a
later phase consumes is stated from the *generic* inequalities `winLo_le_neg_NB` and `le_winHi`,
never from the literal factor `2`, so a widening that a future fixture forces is a local change to
`winLo` / `winHi` alone.

## Main definitions

- `PlusSlicedCertificate.NB` / `NF` / `NM` — the combined periods and window length
- `PlusSlicedCertificate.winLo` / `winHi` — the doubled combined window's endpoints
- `PlusSlicedCertificate.winTimes` — that window as a `Finset ℤ`

## Main results

- the six compatibility facts `nb_dvd_NB`, `target_nb_dvd_NB`, `nf_dvd_NF`, `target_nf_dvd_NF`,
  `nm_le_NM`, `target_nm_le_NM` — the sliced-side counterpart of `SharingWindow`'s
  `nbr_dvd_NB` / `nfr_dvd_NF` / `nmr_le_NM`
- `PlusSlicedCertificate.exists_combined_window_eq` — every time has a **single-period** combined
  window representative agreeing on the slice *and* on the target datum
- `PlusSlicedCertificate.exists_win_eq` — the same inside the doubled window
- `PlusSlicedCertificate.forall_iff_win` — **the lemma Phase 17 needs**: any predicate on times that
  factors through the slice and the target datum has its `∀ t` form decided on the window

## Tags

plus-language · certificate · time-sliced · window · combined-periods
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## Residues under a divisor of the modulus

The one arithmetic fact every fold below rests on: agreeing modulo the combined period implies
agreeing modulo each component period.
-/

/-- Congruence modulo `m` descends to any divisor `k` of `m`. -/
theorem emod_eq_of_dvd_of_emod_eq {a b m k : ℤ} (hk : k ∣ m) (h : a % m = b % m) :
    a % k = b % k :=
  Int.ModEq.of_dvd hk h

/-! ## The combined periods -/

/-- The combined back period, as a natural number: the least common multiple of the slice
sequence's back period and the target path's. -/
def NBnat (G : PlusSlicedCertificate Γ Del) : ℕ :=
  Nat.lcm G.back.length G.target.back.length

/-- The combined forward period, as a natural number. -/
def NFnat (G : PlusSlicedCertificate Γ Del) : ℕ :=
  Nat.lcm G.fwd.length G.target.fwd.length

/-- **The combined back period.** -/
def NB (G : PlusSlicedCertificate Γ Del) : ℤ := (G.NBnat : ℤ)

/-- **The combined forward period.** -/
def NF (G : PlusSlicedCertificate Γ Del) : ℤ := (G.NFnat : ℤ)

/-- **The combined window length**: long enough to contain both objects' non-periodic regions. -/
def NM (G : PlusSlicedCertificate Γ Del) : ℤ := max G.nm G.target.nm

theorem back_length_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.back.length :=
  Nat.pos_of_ne_zero fun h => G.back_ne (List.eq_nil_of_length_eq_zero h)

theorem fwd_length_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.fwd.length :=
  Nat.pos_of_ne_zero fun h => G.fwd_ne (List.eq_nil_of_length_eq_zero h)

theorem target_back_length_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.target.back.length :=
  Nat.pos_of_ne_zero fun h => G.target.back_ne (List.eq_nil_of_length_eq_zero h)

theorem target_fwd_length_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.target.fwd.length :=
  Nat.pos_of_ne_zero fun h => G.target.fwd_ne (List.eq_nil_of_length_eq_zero h)

theorem NB_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.NB := by
  rw [NB, NBnat]
  exact_mod_cast Nat.lcm_pos G.back_length_pos G.target_back_length_pos

theorem NF_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.NF := by
  rw [NF, NFnat]
  exact_mod_cast Nat.lcm_pos G.fwd_length_pos G.target_fwd_length_pos

theorem NM_nonneg (G : PlusSlicedCertificate Γ Del) : 0 ≤ G.NM :=
  le_trans G.nm_nonneg (le_max_left _ _)

/-! ### The six compatibility facts

The sliced-side counterpart of `SharingWindow`'s `nbr_dvd_NB` / `nfr_dvd_NF` / `nmr_le_NM`. Each is
one `Nat.lcm` projection away, which is the whole point of taking response (α): the facts are
theorems about the certificate's own data rather than fields demanded of its author.
-/

theorem nb_dvd_NB (G : PlusSlicedCertificate Γ Del) : G.nb ∣ G.NB :=
  Int.natCast_dvd_natCast.mpr (Nat.dvd_lcm_left _ _)

theorem target_nb_dvd_NB (G : PlusSlicedCertificate Γ Del) : G.target.nb ∣ G.NB :=
  Int.natCast_dvd_natCast.mpr (Nat.dvd_lcm_right _ _)

theorem nf_dvd_NF (G : PlusSlicedCertificate Γ Del) : G.nf ∣ G.NF :=
  Int.natCast_dvd_natCast.mpr (Nat.dvd_lcm_left _ _)

theorem target_nf_dvd_NF (G : PlusSlicedCertificate Γ Del) : G.target.nf ∣ G.NF :=
  Int.natCast_dvd_natCast.mpr (Nat.dvd_lcm_right _ _)

theorem nm_le_NM (G : PlusSlicedCertificate Γ Del) : G.nm ≤ G.NM := le_max_left _ _

theorem target_nm_le_NM (G : PlusSlicedCertificate Γ Del) : G.target.nm ≤ G.NM := le_max_right _ _

/-! ## The window -/

/-- **The window's lower endpoint**, the combined back period doubled. -/
def winLo (G : PlusSlicedCertificate Γ Del) : ℤ := -2 * G.NB

/-- **The window's upper endpoint**, the combined forward period doubled past the window length. -/
def winHi (G : PlusSlicedCertificate Γ Del) : ℤ := G.NM + 2 * G.NF

/-- **The window as a `Finset`.** -/
def winTimes (G : PlusSlicedCertificate Γ Del) : Finset ℤ := Finset.Ico G.winLo G.winHi

theorem mem_winTimes (G : PlusSlicedCertificate Γ Del) (u : ℤ) :
    u ∈ G.winTimes ↔ G.winLo ≤ u ∧ u < G.winHi := Finset.mem_Ico

/-- **The generic lower inequality.** Every fold below cites this rather than the factor `2`. -/
theorem winLo_le_neg_NB (G : PlusSlicedCertificate Γ Del) : G.winLo ≤ -G.NB := by
  have := G.NB_pos
  rw [winLo]
  omega

/-- **The generic upper inequality.** -/
theorem le_winHi (G : PlusSlicedCertificate Γ Del) : G.NM + G.NF ≤ G.winHi := by
  have := G.NF_pos
  rw [winHi]
  omega

theorem winLo_lt_winHi (G : PlusSlicedCertificate Γ Del) : G.winLo < G.winHi := by
  have h1 := G.NB_pos
  have h2 := G.NF_pos
  have h3 := G.NM_nonneg
  rw [winLo, winHi]
  omega

/-! ## The combined fold

The single statement `Basic.lean` cannot make: one representative time at which **both** the slice
and the target datum agree with their values at an arbitrary time.
-/

/--
**Every time has a combined single-period window representative.**

The window is `[-NB, NM + NF)`. Proved by residue in each of the three regions, exactly as
`exists_window_eq` is, with one extra step: the representative is chosen modulo the **combined**
period, and the component residues follow because each component period divides it
(`emod_eq_of_dvd_of_emod_eq`).
-/
theorem exists_combined_window_eq (G : PlusSlicedCertificate Γ Del) (t : ℤ) :
    ∃ s : ℤ, -G.NB ≤ s ∧ s < G.NM + G.NF ∧ G.slice s = G.slice t ∧
      G.target.datum s = G.target.datum t := by
  have hB := G.NB_pos
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hnm := G.nm_le_NM
  have htnm := G.target_nm_le_NM
  by_cases ht : t < 0
  · -- The negatives: both objects read their back cycles.
    have hnn : 0 ≤ t % G.NB := Int.emod_nonneg t (by omega)
    have hlt : t % G.NB < G.NB := Int.emod_lt_of_pos t hB
    refine ⟨t % G.NB - G.NB, by omega, by omega, ?_, ?_⟩
    · have hres : (t % G.NB - G.NB) % G.NB = t % G.NB := by
        rw [show t % G.NB - G.NB = t % G.NB + (-1) * G.NB from by omega,
          Periodic.emod_add_mul, Int.emod_emod_of_dvd t (dvd_refl _)]
      rw [G.slice_neg (by omega : t % G.NB - G.NB < 0), G.slice_neg ht]
      exact Periodic.cyc_congr (emod_eq_of_dvd_of_emod_eq G.nb_dvd_NB hres)
    · have hres : (t % G.NB - G.NB) % G.NB = t % G.NB := by
        rw [show t % G.NB - G.NB = t % G.NB + (-1) * G.NB from by omega,
          Periodic.emod_add_mul, Int.emod_emod_of_dvd t (dvd_refl _)]
      rw [G.target.datum_neg (by omega : t % G.NB - G.NB < 0), G.target.datum_neg ht]
      exact @Periodic.cyc_congr _ G.target.inh _ _ _
        (emod_eq_of_dvd_of_emod_eq G.target_nb_dvd_NB hres)
  · by_cases htm : t < G.NM
    · exact ⟨t, by omega, by omega, rfl, rfl⟩
    · -- At or past the combined window length: both objects read their forward cycles.
      have htM : G.NM ≤ t := not_lt.mp htm
      have hnn : 0 ≤ (t - G.NM) % G.NF := Int.emod_nonneg _ (by omega)
      have hlt : (t - G.NM) % G.NF < G.NF := Int.emod_lt_of_pos _ hF
      have hres : (G.NM + (t - G.NM) % G.NF) % G.NF = t % G.NF := by
        have h1 : (t - G.NM) % G.NF % G.NF = (t - G.NM) % G.NF :=
          Int.emod_emod_of_dvd _ (dvd_refl _)
        have h2 : (G.NM + (t - G.NM) % G.NF) % G.NF = (G.NM + (t - G.NM)) % G.NF :=
          Int.ModEq.add_left G.NM h1
        rw [h2, show G.NM + (t - G.NM) = t from by omega]
      refine ⟨G.NM + (t - G.NM) % G.NF, by omega, by omega, ?_, ?_⟩
      · rw [G.slice_fwd (by omega : G.nm ≤ G.NM + (t - G.NM) % G.NF),
          G.slice_fwd (le_trans G.nm_le_NM htM)]
        exact Periodic.cyc_congr
          (Int.ModEq.sub_right G.nm (emod_eq_of_dvd_of_emod_eq G.nf_dvd_NF hres))
      · rw [G.target.datum_fwd (by omega : G.target.nm ≤ G.NM + (t - G.NM) % G.NF),
          G.target.datum_fwd (le_trans G.target_nm_le_NM htM)]
        exact @Periodic.cyc_congr _ G.target.inh _ _ _
          (Int.ModEq.sub_right G.target.nm
            (emod_eq_of_dvd_of_emod_eq G.target_nf_dvd_NF hres))

/-- **The same representative, inside the doubled window.** Cited from the generic inequalities, not
from the factor `2`. -/
theorem exists_win_eq (G : PlusSlicedCertificate Γ Del) (t : ℤ) :
    ∃ s : ℤ, G.winLo ≤ s ∧ s < G.winHi ∧ G.slice s = G.slice t ∧
      G.target.datum s = G.target.datum t := by
  obtain ⟨s, h1, h2, h3, h4⟩ := G.exists_combined_window_eq t
  have hlo := G.winLo_le_neg_NB
  have hhi := G.le_winHi
  exact ⟨s, by omega, by omega, h3, h4⟩

/--
**The lemma Phase 17 needs.**

Any predicate on times that factors through the slice and the target datum — which is exactly the
shape of the checker's existential side — has its `∀ t` form decided on the window. `→` is
restriction; `←` is `exists_win_eq`.

Stated with the factoring as a hypothesis rather than with a concrete clause, so that the box
clause, the target-agreement clause and the universal side can each cite it without a second fold
lemma.
-/
theorem forall_iff_win (G : PlusSlicedCertificate Γ Del) {P : ℤ → Prop}
    (hP : ∀ s t : ℤ, G.slice s = G.slice t → G.target.datum s = G.target.datum t → (P s ↔ P t)) :
    (∀ t : ℤ, P t) ↔ (∀ t : ℤ, G.winLo ≤ t → t < G.winHi → P t) := by
  constructor
  · intro h t _ _
    exact h t
  · intro h t
    obtain ⟨s, hs1, hs2, hs3, hs4⟩ := G.exists_win_eq t
    exact (hP s t hs3 hs4).mp (h s hs1 hs2)

/-- **The slice-only fold, recovered from the combined one.** Confirms the combined window is a
refinement of `exists_window_eq`'s and not a different object. -/
theorem exists_win_eq_slice (G : PlusSlicedCertificate Γ Del) (t : ℤ) :
    ∃ s : ℤ, G.winLo ≤ s ∧ s < G.winHi ∧ G.slice s = G.slice t := by
  obtain ⟨s, h1, h2, h3, -⟩ := G.exists_win_eq t
  exact ⟨s, h1, h2, h3⟩

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
