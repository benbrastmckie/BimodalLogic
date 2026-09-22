/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.MinusCanonicalFrame
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Data.Finset.Max
import Mathlib.Data.Countable.Basic
import Mathlib.Data.Rat.Encodable
import Mathlib.Data.Nat.Pairing

/-!
# ℚ-chronicles through a TM⁻_d maximal consistent set

The step-by-step construction of Burgess, *Basic Tense Logic* (1984), §2.5 — the tense logic of
ℚ — transposed to the L⁻ canonical relations of `Conservativity/MinusCanonicalFrame.lean`. From
any maximal TM⁻_d-consistent seed `Γ₀`, an ω-sequence of finite-support partial labellings
`ℚ → Option (MPoint .Dense)` is built, each stage coherent for `canR`, each requirement
(label a rational; witness an `F`- or `P`-formula at a labelled rational) recurring infinitely
often in the enumeration; the union is a total labelling `ℚ → MPoint .Dense` that is coherent
and `F`/`P`-witnessing — a **chronicle** — with `Γ₀` at `0`.

**Nothing here generalises beyond `FrameClass.Dense`.** The interpolation lemma `fill` consumes
`exists_canR_between`, the one density lemma, and every declaration below is stated at
`MPoint FrameClass.Dense` (`DPoint`). A "for all `fc`" chronicle theorem would be false at
`.Base` and `.ZTime`.

## Design

* A `Stage` is a labelling `s : ℚ → Option DPoint` with a `Finset` support and a coherence
  proof; `Stage.upd` is the raw single-point update and `Stage.extend` re-packages it with its
  coherence proof. `coherent_upd_of` reduces coherence of an update at `r` to two one-sided
  conditions (below `r`, above `r`), which is what the three placement lemmas supply.
* `insert_future` / `insert_past` place a `canR`-successor / predecessor of a labelled point
  either at an already-labelled rational or at a fresh one, using weak linearity to find the
  slot; `fill` labels a fresh rational using density, or seriality at the ends.
* Reflexive points may label many rationals: coherence needs only `canR`, never injectivity.

## Main Results

* `Stage.insert_future`, `Stage.insert_past`, `Stage.fill` — the single-stage lemmas
* `exists_chronicle_through` — every `Γ₀ : DPoint` lies at `0` on some `Chronicle`
* `chronicle_canBox_closed` — a chronicle stays inside one `canBox`-class

## References

* Burgess, *Basic Tense Logic* (1984), §2.5 — the step-by-step construction over ℚ
* `FormalSystem/Metalogic/Conservativity/MinusCanonicalFrame.lean` — the relations consumed

## Tags

conservativity · base-language · chronicle · step-by-step · rationals
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.MinusLanguage

/-- Maximal TM⁻_d-consistent sets: the only points this module labels rationals with. -/
abbrev DPoint := MPoint FrameClass.Dense

/-- A partial labelling is coherent when labelled rationals in order stand in `canR`. -/
def coherent (s : ℚ → Option DPoint) : Prop :=
  ∀ q q' Γ Δ, q < q' → s q = some Γ → s q' = some Δ → canR Γ.1 Δ.1

/-- A finite-support coherent partial labelling of ℚ. -/
structure Stage where
  /-- The labelling. -/
  s : ℚ → Option DPoint
  /-- Its support. -/
  supp : Finset ℚ
  /-- `supp` is exactly the labelled rationals. -/
  supp_spec : ∀ q, q ∈ supp ↔ (s q).isSome
  /-- Coherence. -/
  coh : coherent s

namespace Stage

/-- The extension order: every label of `s` is a label of `s'`. -/
def le (s s' : Stage) : Prop := ∀ q Γ, s.s q = some Γ → s'.s q = some Γ

theorem le_refl (s : Stage) : s.le s := fun _ _ h => h

theorem le_trans {s₁ s₂ s₃ : Stage} (h₁ : s₁.le s₂) (h₂ : s₂.le s₃) : s₁.le s₃ :=
  fun q Γ h => h₂ q Γ (h₁ q Γ h)

theorem mem_supp_of_some (s : Stage) {q : ℚ} {Γ : DPoint} (h : s.s q = some Γ) : q ∈ s.supp :=
  (s.supp_spec q).mpr (by simp [h])

theorem exists_some_of_mem (s : Stage) {q : ℚ} (h : q ∈ s.supp) : ∃ Γ, s.s q = some Γ :=
  Option.isSome_iff_exists.mp ((s.supp_spec q).mp h)

theorem eq_none_of_notMem (s : Stage) {q : ℚ} (h : q ∉ s.supp) : s.s q = none := by
  cases hq : s.s q with
  | none => rfl
  | some Γ => exact absurd (s.mem_supp_of_some hq) h

/-- The raw single-point update `s[r ↦ Δ]`. -/
def upd (s : Stage) (r : ℚ) (Δ : DPoint) : ℚ → Option DPoint :=
  Function.update s.s r (some Δ)

@[simp] theorem upd_self (s : Stage) (r : ℚ) (Δ : DPoint) : s.upd r Δ r = some Δ := by
  unfold upd
  exact Function.update_self r (some Δ) s.s

theorem upd_of_ne (s : Stage) {q r : ℚ} (h : q ≠ r) (Δ : DPoint) : s.upd r Δ q = s.s q := by
  unfold upd
  exact Function.update_of_ne h (some Δ) s.s

/-- Re-package an update whose coherence has been established. -/
def extend (s : Stage) (r : ℚ) (Δ : DPoint) (hcoh : coherent (s.upd r Δ)) : Stage where
  s := s.upd r Δ
  supp := insert r s.supp
  supp_spec := by
    intro q
    by_cases hq : q = r
    · subst hq; simp
    · rw [Finset.mem_insert, upd_of_ne s hq, s.supp_spec]
      simp [hq]
  coh := hcoh

@[simp] theorem extend_s (s : Stage) (r : ℚ) (Δ : DPoint) (hcoh : coherent (s.upd r Δ)) :
    (s.extend r Δ hcoh).s = s.upd r Δ := rfl

theorem le_extend (s : Stage) {r : ℚ} (Δ : DPoint) (hcoh : coherent (s.upd r Δ))
    (hr : s.s r = none) : s.le (s.extend r Δ hcoh) := by
  intro q Γ hq
  have hne : q ≠ r := by
    rintro rfl
    rw [hr] at hq
    exact absurd hq (by simp)
  rw [extend_s, upd_of_ne s hne]
  exact hq

/-- Coherence of `s[r ↦ Δ]` at an unlabelled `r` reduces to the two one-sided conditions. -/
theorem coherent_upd_of (s : Stage) (r : ℚ) (Δ : DPoint) (hr : s.s r = none)
    (hbelow : ∀ q Θ, q < r → s.s q = some Θ → canR Θ.1 Δ.1)
    (habove : ∀ q Θ, r < q → s.s q = some Θ → canR Δ.1 Θ.1) : coherent (s.upd r Δ) := by
  intro q q' Γ Θ hlt hq hq'
  by_cases hqr : q = r
  · subst hqr
    rw [upd_self] at hq
    rw [upd_of_ne s (ne_of_gt hlt)] at hq'
    obtain rfl := Option.some.inj hq
    exact habove q' Θ hlt hq'
  · by_cases hq'r : q' = r
    · subst hq'r
      rw [upd_self] at hq'
      rw [upd_of_ne s hqr] at hq
      obtain rfl := Option.some.inj hq'
      exact hbelow q Γ hlt hq
    · rw [upd_of_ne s hqr] at hq
      rw [upd_of_ne s hq'r] at hq'
      exact s.coh q q' Γ Θ hlt hq hq'

/-! ## Placement -/

/-- **Future placement.** A `canR`-successor `Δ` of the label at `q` is either already the label
of some `q' > q`, or can be placed coherently at a fresh `r > q`. The slot is found by weak
linearity: among labelled points after `q` whose label does not reach `Δ`, the least one, `q₁`,
either equals `Δ` or lies `canR`-above it, and then `r` goes just below `q₁`; if there is no
such point, `r` goes above the whole support. -/
theorem insert_future (s : Stage) {q : ℚ} {Γ Δ : DPoint} (hq : s.s q = some Γ)
    (hR : canR Γ.1 Δ.1) :
    (∃ q' > q, s.s q' = some Δ) ∨ (∃ r > q, s.s r = none ∧ coherent (s.upd r Δ)) := by
  classical
  let U := s.supp.filter (fun q' => q < q' ∧ ∀ Θ : DPoint, s.s q' = some Θ → ¬ canR Θ.1 Δ.1)
  have hqsupp : q ∈ s.supp := s.mem_supp_of_some hq
  have hbelow_gen : ∀ q'' Θ, q'' ≤ q → s.s q'' = some Θ → canR Θ.1 Δ.1 := by
    intro q'' Θ hle hq''
    rcases lt_or_eq_of_le hle with hlt | rfl
    · exact canR_trans (s.coh q'' q Θ Γ hlt hq'' hq) hR
    · rw [hq] at hq''
      obtain rfl := Option.some.inj hq''
      exact hR
  have hnotU : ∀ q'' Θ, q < q'' → q'' ∉ U → s.s q'' = some Θ → canR Θ.1 Δ.1 := by
    intro q'' Θ hgt hnot hq''
    by_contra hn
    exact hnot (Finset.mem_filter.mpr ⟨s.mem_supp_of_some hq'', hgt, fun Θ' h' => by
      rw [hq''] at h'
      obtain rfl := Option.some.inj h'
      exact hn⟩)
  by_cases hU : U = ∅
  · obtain ⟨r, hr⟩ := exists_gt (s.supp.max' ⟨q, hqsupp⟩)
    have hrnot : r ∉ s.supp := fun hmem => absurd (s.supp.le_max' r hmem) (not_le.mpr hr)
    have hrq : q < r := lt_of_le_of_lt (s.supp.le_max' q hqsupp) hr
    have hrnone := s.eq_none_of_notMem hrnot
    refine Or.inr ⟨r, hrq, hrnone, s.coherent_upd_of r Δ hrnone ?_ ?_⟩
    · intro q'' Θ _ hq''
      rcases le_or_gt q'' q with hle | hgt
      · exact hbelow_gen q'' Θ hle hq''
      · exact hnotU q'' Θ hgt (by simp [hU]) hq''
    · intro q'' Θ hlt hq''
      exact absurd (s.supp.le_max' q'' (s.mem_supp_of_some hq''))
        (not_le.mpr (lt_trans hr hlt))
  · have hUne : U.Nonempty := Finset.nonempty_iff_ne_empty.mpr hU
    obtain ⟨hq₁supp, hqq₁, hq₁bad⟩ := Finset.mem_filter.mp (U.min'_mem hUne)
    obtain ⟨Θ₁, hΘ₁⟩ := s.exists_some_of_mem hq₁supp
    have hnot : ¬ canR Θ₁.1 Δ.1 := hq₁bad Θ₁ hΘ₁
    have hΓΘ₁ : canR Γ.1 Θ₁.1 := s.coh q _ Γ Θ₁ hqq₁ hq hΘ₁
    rcases canR_weakLinear_right hΓΘ₁ hR with heq | hΘΔ | hΔΘ
    · exact Or.inl ⟨U.min' hUne, hqq₁, heq ▸ hΘ₁⟩
    · exact absurd hΘΔ hnot
    · let B := s.supp.filter (· < U.min' hUne)
      have hqB : q ∈ B := Finset.mem_filter.mpr ⟨hqsupp, hqq₁⟩
      have hBne : B.Nonempty := ⟨q, hqB⟩
      have hmlt : B.max' hBne < U.min' hUne := (Finset.mem_filter.mp (B.max'_mem hBne)).2
      have hqm : q ≤ B.max' hBne := B.le_max' q hqB
      obtain ⟨r, hmr, hrq₁⟩ := exists_between hmlt
      have hrnot : r ∉ s.supp := by
        intro hmem
        exact absurd (B.le_max' r (Finset.mem_filter.mpr ⟨hmem, hrq₁⟩)) (not_le.mpr hmr)
      have hrnone := s.eq_none_of_notMem hrnot
      refine Or.inr ⟨r, lt_of_le_of_lt hqm hmr, hrnone, s.coherent_upd_of r Δ hrnone ?_ ?_⟩
      · intro q'' Θ hlt hq''
        rcases le_or_gt q'' q with hle | hgt
        · exact hbelow_gen q'' Θ hle hq''
        · have hq''q₁ : q'' < U.min' hUne := lt_trans hlt hrq₁
          exact hnotU q'' Θ hgt
            (fun hmem => absurd (U.min'_le q'' hmem) (not_le.mpr hq''q₁)) hq''
      · intro q'' Θ hlt hq''
        have hnotB : q'' ∉ B :=
          fun hmem => absurd (B.le_max' q'' hmem) (not_le.mpr (lt_trans hmr hlt))
        have hq₁le : U.min' hUne ≤ q'' :=
          le_of_not_gt (fun h => hnotB (Finset.mem_filter.mpr ⟨s.mem_supp_of_some hq'', h⟩))
        rcases lt_or_eq_of_le hq₁le with hlt' | heq
        · exact canR_trans hΔΘ (s.coh _ q'' Θ₁ Θ hlt' hΘ₁ hq'')
        · rw [← heq, hΘ₁] at hq''
          obtain rfl := Option.some.inj hq''
          exact hΔΘ

/-- **Past placement**, the mirror of `insert_future` with `canR_weakLinear_left`. -/
theorem insert_past (s : Stage) {q : ℚ} {Γ Δ : DPoint} (hq : s.s q = some Γ)
    (hR : canR Δ.1 Γ.1) :
    (∃ q' < q, s.s q' = some Δ) ∨ (∃ r < q, s.s r = none ∧ coherent (s.upd r Δ)) := by
  classical
  let U := s.supp.filter (fun q' => q' < q ∧ ∀ Θ : DPoint, s.s q' = some Θ → ¬ canR Δ.1 Θ.1)
  have hqsupp : q ∈ s.supp := s.mem_supp_of_some hq
  have habove_gen : ∀ q'' Θ, q ≤ q'' → s.s q'' = some Θ → canR Δ.1 Θ.1 := by
    intro q'' Θ hle hq''
    rcases lt_or_eq_of_le hle with hlt | rfl
    · exact canR_trans hR (s.coh q q'' Γ Θ hlt hq hq'')
    · rw [hq] at hq''
      obtain rfl := Option.some.inj hq''
      exact hR
  have hnotU : ∀ q'' Θ, q'' < q → q'' ∉ U → s.s q'' = some Θ → canR Δ.1 Θ.1 := by
    intro q'' Θ hlt hnot hq''
    by_contra hn
    exact hnot (Finset.mem_filter.mpr ⟨s.mem_supp_of_some hq'', hlt, fun Θ' h' => by
      rw [hq''] at h'
      obtain rfl := Option.some.inj h'
      exact hn⟩)
  by_cases hU : U = ∅
  · obtain ⟨r, hr⟩ := exists_lt (s.supp.min' ⟨q, hqsupp⟩)
    have hrnot : r ∉ s.supp := fun hmem => absurd (s.supp.min'_le r hmem) (not_le.mpr hr)
    have hrq : r < q := lt_of_lt_of_le hr (s.supp.min'_le q hqsupp)
    have hrnone := s.eq_none_of_notMem hrnot
    refine Or.inr ⟨r, hrq, hrnone, s.coherent_upd_of r Δ hrnone ?_ ?_⟩
    · intro q'' Θ hlt hq''
      exact absurd (s.supp.min'_le q'' (s.mem_supp_of_some hq''))
        (not_le.mpr (lt_trans hlt hr))
    · intro q'' Θ _ hq''
      rcases le_or_gt q q'' with hle | hlt
      · exact habove_gen q'' Θ hle hq''
      · exact hnotU q'' Θ hlt (by simp [hU]) hq''
  · have hUne : U.Nonempty := Finset.nonempty_iff_ne_empty.mpr hU
    obtain ⟨hq₁supp, hq₁q, hq₁bad⟩ := Finset.mem_filter.mp (U.max'_mem hUne)
    obtain ⟨Θ₁, hΘ₁⟩ := s.exists_some_of_mem hq₁supp
    have hnot : ¬ canR Δ.1 Θ₁.1 := hq₁bad Θ₁ hΘ₁
    have hΘ₁Γ : canR Θ₁.1 Γ.1 := s.coh _ q Θ₁ Γ hq₁q hΘ₁ hq
    rcases canR_weakLinear_left hΘ₁Γ hR with heq | hΘΔ | hΔΘ
    · exact Or.inl ⟨U.max' hUne, hq₁q, heq ▸ hΘ₁⟩
    · let A := s.supp.filter (U.max' hUne < ·)
      have hqA : q ∈ A := Finset.mem_filter.mpr ⟨hqsupp, hq₁q⟩
      have hAne : A.Nonempty := ⟨q, hqA⟩
      have hnlt : U.max' hUne < A.min' hAne := (Finset.mem_filter.mp (A.min'_mem hAne)).2
      have hnq : A.min' hAne ≤ q := A.min'_le q hqA
      obtain ⟨r, hq₁r, hrn⟩ := exists_between hnlt
      have hrnot : r ∉ s.supp := by
        intro hmem
        exact absurd (A.min'_le r (Finset.mem_filter.mpr ⟨hmem, hq₁r⟩)) (not_le.mpr hrn)
      have hrnone := s.eq_none_of_notMem hrnot
      refine Or.inr ⟨r, lt_of_lt_of_le hrn hnq, hrnone, s.coherent_upd_of r Δ hrnone ?_ ?_⟩
      · intro q'' Θ hlt hq''
        have hnotA : q'' ∉ A :=
          fun hmem => absurd (A.min'_le q'' hmem) (not_le.mpr (lt_trans hlt hrn))
        have hq''le : q'' ≤ U.max' hUne :=
          le_of_not_gt (fun h => hnotA (Finset.mem_filter.mpr ⟨s.mem_supp_of_some hq'', h⟩))
        rcases lt_or_eq_of_le hq''le with hlt' | heq
        · exact canR_trans (s.coh q'' _ Θ Θ₁ hlt' hq'' hΘ₁) hΘΔ
        · rw [heq, hΘ₁] at hq''
          obtain rfl := Option.some.inj hq''
          exact hΘΔ
      · intro q'' Θ hlt hq''
        rcases le_or_gt q q'' with hle | hlt'
        · exact habove_gen q'' Θ hle hq''
        · have hq₁q'' : U.max' hUne < q'' := lt_trans hq₁r hlt
          exact hnotU q'' Θ hlt'
            (fun hmem => absurd (U.le_max' q'' hmem) (not_le.mpr hq₁q'')) hq''
    · exact absurd hΔΘ hnot

/-- **Interpolation.** An unlabelled rational of a stage with non-empty support can be labelled
coherently: by density between the nearest labels on either side, by seriality (or its mirror)
when there is a label on one side only. -/
theorem fill (s : Stage) {r : ℚ} (hr : s.s r = none) (hne : s.supp.Nonempty) :
    ∃ Θ : DPoint, coherent (s.upd r Θ) := by
  classical
  let B := s.supp.filter (· < r)
  let A := s.supp.filter (r < ·)
  have hbelowOf : ∀ (hB : B.Nonempty) (Θm Θ : DPoint), s.s (B.max' hB) = some Θm →
      canR Θm.1 Θ.1 → ∀ q Θ', q < r → s.s q = some Θ' → canR Θ'.1 Θ.1 := by
    intro hB Θm Θ hm hRm q Θ' hqr hq
    have hqB : q ∈ B := Finset.mem_filter.mpr ⟨s.mem_supp_of_some hq, hqr⟩
    rcases lt_or_eq_of_le (B.le_max' q hqB) with hlt | heq
    · exact canR_trans (s.coh q _ Θ' Θm hlt hq hm) hRm
    · have hmq : s.s q = some Θm := by rw [heq]; exact hm
      rw [hmq] at hq
      obtain rfl := Option.some.inj hq
      exact hRm
  have haboveOf : ∀ (hA : A.Nonempty) (Θn Θ : DPoint), s.s (A.min' hA) = some Θn →
      canR Θ.1 Θn.1 → ∀ q Θ', r < q → s.s q = some Θ' → canR Θ.1 Θ'.1 := by
    intro hA Θn Θ hn hRn q Θ' hrq hq
    have hqA : q ∈ A := Finset.mem_filter.mpr ⟨s.mem_supp_of_some hq, hrq⟩
    rcases lt_or_eq_of_le (A.min'_le q hqA) with hlt | heq
    · exact canR_trans hRn (s.coh _ q Θn Θ' hlt hn hq)
    · have hnq : s.s q = some Θn := by rw [← heq]; exact hn
      rw [hnq] at hq
      obtain rfl := Option.some.inj hq
      exact hRn
  have hbelowEmpty : ¬ B.Nonempty → ∀ q (Θ' : DPoint), q < r → s.s q = some Θ' → False :=
    fun hB q Θ' hqr hq => hB ⟨q, Finset.mem_filter.mpr ⟨s.mem_supp_of_some hq, hqr⟩⟩
  have haboveEmpty : ¬ A.Nonempty → ∀ q (Θ' : DPoint), r < q → s.s q = some Θ' → False :=
    fun hA q Θ' hrq hq => hA ⟨q, Finset.mem_filter.mpr ⟨s.mem_supp_of_some hq, hrq⟩⟩
  by_cases hB : B.Nonempty <;> by_cases hA : A.Nonempty
  · obtain ⟨Θm, hm⟩ := s.exists_some_of_mem (Finset.mem_filter.mp (B.max'_mem hB)).1
    obtain ⟨Θn, hn⟩ := s.exists_some_of_mem (Finset.mem_filter.mp (A.min'_mem hA)).1
    have hmn : B.max' hB < A.min' hA :=
      lt_trans (Finset.mem_filter.mp (B.max'_mem hB)).2 (Finset.mem_filter.mp (A.min'_mem hA)).2
    obtain ⟨Θ, h₁, h₂⟩ := exists_canR_between (s.coh _ _ Θm Θn hmn hm hn)
    exact ⟨Θ, s.coherent_upd_of r Θ hr (hbelowOf hB Θm Θ hm h₁) (haboveOf hA Θn Θ hn h₂)⟩
  · obtain ⟨Θm, hm⟩ := s.exists_some_of_mem (Finset.mem_filter.mp (B.max'_mem hB)).1
    obtain ⟨Θ, h₁⟩ := exists_canR_serial Θm
    exact ⟨Θ, s.coherent_upd_of r Θ hr (hbelowOf hB Θm Θ hm h₁)
      (fun q Θ' hrq hq => (haboveEmpty hA q Θ' hrq hq).elim)⟩
  · obtain ⟨Θn, hn⟩ := s.exists_some_of_mem (Finset.mem_filter.mp (A.min'_mem hA)).1
    obtain ⟨Θ, h₂⟩ := exists_canR_serial_past Θn
    exact ⟨Θ, s.coherent_upd_of r Θ hr (fun q Θ' hqr hq => (hbelowEmpty hB q Θ' hqr hq).elim)
      (haboveOf hA Θn Θ hn h₂)⟩
  · exfalso
    obtain ⟨q, hq⟩ := hne
    obtain ⟨Θ', hΘ'⟩ := s.exists_some_of_mem hq
    rcases lt_trichotomy q r with hlt | rfl | hgt
    · exact hbelowEmpty hB q Θ' hlt hΘ'
    · rw [hr] at hΘ'
      exact absurd hΘ' (by simp)
    · exact haboveEmpty hA q Θ' hgt hΘ'

end Stage

/-! ## Requirements and their enumeration -/

/-- A requirement: label the rational (`inl r`), or witness an `F`-formula (`inr (q, ψ, true)`)
or a `P`-formula (`inr (q, ψ, false)`) at the rational `q`. -/
abbrev Req := ℚ ⊕ (ℚ × MinusFormula × Bool)

instance : Nonempty Req := ⟨Sum.inl 0⟩

/-- Enumeration in which every requirement recurs at arbitrarily late stages: compose a
surjection `ℕ → R` with `Nat.unpair`'s first projection. -/
theorem exists_enum_infinitely_often {R : Type} [Countable R] [Nonempty R] :
    ∃ e : ℕ → R, ∀ r : R, ∀ m : ℕ, ∃ n, m ≤ n ∧ e n = r := by
  obtain ⟨f, hf⟩ := exists_surjective_nat R
  refine ⟨fun n => f (Nat.unpair n).1, fun r m => ?_⟩
  obtain ⟨k, hk⟩ := hf r
  refine ⟨Nat.pair k m, Nat.right_le_pair k m, ?_⟩
  simp only [Nat.unpair_pair]
  exact hk

/-- A fixed enumeration of requirements in which each recurs infinitely often. -/
noncomputable def enum : ℕ → Req :=
  Classical.choose (exists_enum_infinitely_often (R := Req))

theorem enum_spec (r : Req) (m : ℕ) : ∃ n, m ≤ n ∧ enum n = r :=
  Classical.choose_spec (exists_enum_infinitely_often (R := Req)) r m

/-! ## The step function

Each branch either leaves the stage alone or extends it at a fresh rational with a coherence
proof supplied by the Phase-A lemmas. Everything is noncomputable through `Classical.choose`. -/

namespace Stage

open Classical in
/-- Place a `canR`-successor `Δ` of the label at `q`: no-op if some `q' > q` already carries
`Δ`, else extend at the fresh slot `insert_future` provides. -/
noncomputable def placeF (s : Stage) {q : ℚ} {Γ Δ : DPoint} (hq : s.s q = some Γ)
    (hR : canR Γ.1 Δ.1) : Stage :=
  if h₁ : ∃ q' > q, s.s q' = some Δ then s
  else
    let h₂ := (s.insert_future hq hR).resolve_left h₁
    s.extend (Classical.choose h₂) Δ (Classical.choose_spec h₂).2.2

theorem le_placeF (s : Stage) {q : ℚ} {Γ Δ : DPoint} (hq : s.s q = some Γ)
    (hR : canR Γ.1 Δ.1) : s.le (s.placeF hq hR) := by
  unfold placeF
  by_cases h₁ : ∃ q' > q, s.s q' = some Δ
  · rw [dif_pos h₁]; exact s.le_refl
  · rw [dif_neg h₁]
    exact s.le_extend Δ _ (Classical.choose_spec ((s.insert_future hq hR).resolve_left h₁)).2.1

theorem placeF_spec (s : Stage) {q : ℚ} {Γ Δ : DPoint} (hq : s.s q = some Γ)
    (hR : canR Γ.1 Δ.1) : ∃ q' > q, (s.placeF hq hR).s q' = some Δ := by
  unfold placeF
  by_cases h₁ : ∃ q' > q, s.s q' = some Δ
  · rw [dif_pos h₁]; exact h₁
  · rw [dif_neg h₁]
    refine ⟨Classical.choose ((s.insert_future hq hR).resolve_left h₁),
      (Classical.choose_spec ((s.insert_future hq hR).resolve_left h₁)).1, ?_⟩
    rw [extend_s, upd_self]

open Classical in
/-- Place a `canR`-predecessor `Δ` of the label at `q`, mirror of `placeF`. -/
noncomputable def placeP (s : Stage) {q : ℚ} {Γ Δ : DPoint} (hq : s.s q = some Γ)
    (hR : canR Δ.1 Γ.1) : Stage :=
  if h₁ : ∃ q' < q, s.s q' = some Δ then s
  else
    let h₂ := (s.insert_past hq hR).resolve_left h₁
    s.extend (Classical.choose h₂) Δ (Classical.choose_spec h₂).2.2

theorem le_placeP (s : Stage) {q : ℚ} {Γ Δ : DPoint} (hq : s.s q = some Γ)
    (hR : canR Δ.1 Γ.1) : s.le (s.placeP hq hR) := by
  unfold placeP
  by_cases h₁ : ∃ q' < q, s.s q' = some Δ
  · rw [dif_pos h₁]; exact s.le_refl
  · rw [dif_neg h₁]
    exact s.le_extend Δ _ (Classical.choose_spec ((s.insert_past hq hR).resolve_left h₁)).2.1

theorem placeP_spec (s : Stage) {q : ℚ} {Γ Δ : DPoint} (hq : s.s q = some Γ)
    (hR : canR Δ.1 Γ.1) : ∃ q' < q, (s.placeP hq hR).s q' = some Δ := by
  unfold placeP
  by_cases h₁ : ∃ q' < q, s.s q' = some Δ
  · rw [dif_pos h₁]; exact h₁
  · rw [dif_neg h₁]
    refine ⟨Classical.choose ((s.insert_past hq hR).resolve_left h₁),
      (Classical.choose_spec ((s.insert_past hq hR).resolve_left h₁)).1, ?_⟩
    rw [extend_s, upd_self]

open Classical in
/-- The `inl r` branch: label `r` by `fill` if it is unlabelled. -/
noncomputable def stepFill (s : Stage) (r : ℚ) : Stage :=
  if hr : s.s r = none then
    if hne : s.supp.Nonempty then
      s.extend r (Classical.choose (s.fill hr hne)) (Classical.choose_spec (s.fill hr hne))
    else s
  else s

theorem le_stepFill (s : Stage) (r : ℚ) : s.le (s.stepFill r) := by
  unfold stepFill
  by_cases hr : s.s r = none
  · by_cases hne : s.supp.Nonempty
    · rw [dif_pos hr, dif_pos hne]; exact s.le_extend _ _ hr
    · rw [dif_pos hr, dif_neg hne]; exact s.le_refl
  · rw [dif_neg hr]; exact s.le_refl

theorem stepFill_spec (s : Stage) (r : ℚ) (hne : s.supp.Nonempty) :
    ∃ Γ, (s.stepFill r).s r = some Γ := by
  unfold stepFill
  by_cases hr : s.s r = none
  · rw [dif_pos hr, dif_pos hne]
    exact ⟨_, by rw [extend_s, upd_self]⟩
  · rw [dif_neg hr]
    exact Option.ne_none_iff_exists'.mp hr

open Classical in
/-- The `inr (q, ψ, true)` branch: if `q` is labelled and `Fψ` holds there, place a witness. -/
noncomputable def stepF (s : Stage) (q : ℚ) (ψ : MinusFormula) : Stage :=
  if h : ∃ Γ : DPoint, s.s q = some Γ ∧ ψ.someFuture ∈ Γ.1 then
    s.placeF (Classical.choose_spec h).1
      (Classical.choose_spec (exists_canR_of_F _ (Classical.choose_spec h).2)).1
  else s

theorem le_stepF (s : Stage) (q : ℚ) (ψ : MinusFormula) : s.le (s.stepF q ψ) := by
  unfold stepF
  by_cases h : ∃ Γ : DPoint, s.s q = some Γ ∧ ψ.someFuture ∈ Γ.1
  · rw [dif_pos h]; exact s.le_placeF _ _
  · rw [dif_neg h]; exact s.le_refl

theorem stepF_spec (s : Stage) {q : ℚ} {Γ : DPoint} (ψ : MinusFormula) (hq : s.s q = some Γ)
    (hψ : ψ.someFuture ∈ Γ.1) :
    ∃ q' > q, ∃ Δ : DPoint, (s.stepF q ψ).s q' = some Δ ∧ ψ ∈ Δ.1 := by
  have h : ∃ Γ : DPoint, s.s q = some Γ ∧ ψ.someFuture ∈ Γ.1 := ⟨Γ, hq, hψ⟩
  unfold stepF
  rw [dif_pos h]
  obtain ⟨q', hq', hΔ⟩ := s.placeF_spec (Classical.choose_spec h).1
    (Classical.choose_spec (exists_canR_of_F _ (Classical.choose_spec h).2)).1
  exact ⟨q', hq', _, hΔ, (Classical.choose_spec (exists_canR_of_F _ (Classical.choose_spec h).2)).2⟩

open Classical in
/-- The `inr (q, ψ, false)` branch: if `q` is labelled and `Pψ` holds there, place a witness. -/
noncomputable def stepP (s : Stage) (q : ℚ) (ψ : MinusFormula) : Stage :=
  if h : ∃ Γ : DPoint, s.s q = some Γ ∧ ψ.somePast ∈ Γ.1 then
    s.placeP (Classical.choose_spec h).1
      (Classical.choose_spec (exists_canR_of_P _ (Classical.choose_spec h).2)).1
  else s

theorem le_stepP (s : Stage) (q : ℚ) (ψ : MinusFormula) : s.le (s.stepP q ψ) := by
  unfold stepP
  by_cases h : ∃ Γ : DPoint, s.s q = some Γ ∧ ψ.somePast ∈ Γ.1
  · rw [dif_pos h]; exact s.le_placeP _ _
  · rw [dif_neg h]; exact s.le_refl

theorem stepP_spec (s : Stage) {q : ℚ} {Γ : DPoint} (ψ : MinusFormula) (hq : s.s q = some Γ)
    (hψ : ψ.somePast ∈ Γ.1) :
    ∃ q' < q, ∃ Δ : DPoint, (s.stepP q ψ).s q' = some Δ ∧ ψ ∈ Δ.1 := by
  have h : ∃ Γ : DPoint, s.s q = some Γ ∧ ψ.somePast ∈ Γ.1 := ⟨Γ, hq, hψ⟩
  unfold stepP
  rw [dif_pos h]
  obtain ⟨q', hq', hΔ⟩ := s.placeP_spec (Classical.choose_spec h).1
    (Classical.choose_spec (exists_canR_of_P _ (Classical.choose_spec h).2)).1
  exact ⟨q', hq', _, hΔ, (Classical.choose_spec (exists_canR_of_P _ (Classical.choose_spec h).2)).2⟩

/-- One construction step, dispatching on the requirement. -/
noncomputable def step (s : Stage) : Req → Stage
  | Sum.inl r => s.stepFill r
  | Sum.inr (q, ψ, true) => s.stepF q ψ
  | Sum.inr (q, ψ, false) => s.stepP q ψ

theorem le_step (s : Stage) (r : Req) : s.le (s.step r) := by
  rcases r with r | ⟨q, ψ, _ | _⟩
  · exact s.le_stepFill r
  · exact s.le_stepP q ψ
  · exact s.le_stepF q ψ

end Stage

/-! ## The ω-sequence of stages from a seed -/

section Construction

variable (Γ₀ : DPoint)

/-- The seed stage `{0 ↦ Γ₀}`. -/
noncomputable def seed : Stage where
  s := fun q => if q = 0 then some Γ₀ else none
  supp := {0}
  supp_spec := by
    intro q
    by_cases h : q = 0 <;> simp [h]
  coh := by
    intro q q' Γ Δ hlt hq hq'
    simp only at hq hq'
    split_ifs at hq hq' with h h'
    · subst h; subst h'; exact absurd hlt (lt_irrefl _)

@[simp] theorem seed_zero : (seed Γ₀).s 0 = some Γ₀ := by simp [seed]

/-- The stages: iterate `step` along the enumeration from the seed. -/
noncomputable def stages : ℕ → Stage
  | 0 => seed Γ₀
  | n + 1 => (stages n).step (enum n)

theorem stages_succ (n : ℕ) : stages Γ₀ (n + 1) = (stages Γ₀ n).step (enum n) := rfl

theorem stages_mono {m n : ℕ} (h : m ≤ n) : (stages Γ₀ m).le (stages Γ₀ n) := by
  induction h with
  | refl => exact Stage.le_refl _
  | step _ ih => exact Stage.le_trans ih (Stage.le_step _ _)

theorem stages_zero_label (n : ℕ) : (stages Γ₀ n).s 0 = some Γ₀ :=
  stages_mono Γ₀ (Nat.zero_le n) 0 Γ₀ (seed_zero Γ₀)

theorem stages_supp_nonempty (n : ℕ) : (stages Γ₀ n).supp.Nonempty :=
  ⟨0, (stages Γ₀ n).mem_supp_of_some (stages_zero_label Γ₀ n)⟩

/-- Every rational is labelled at some stage: the `inl q` requirement recurs, and `fill`
labels `q` the first time it fires while `q` is unlabelled. -/
theorem exists_stage_labelled (q : ℚ) : ∃ n Γ, (stages Γ₀ n).s q = some Γ := by
  obtain ⟨n, -, hn⟩ := enum_spec (Sum.inl q) 0
  obtain ⟨Γ, hΓ⟩ := (stages Γ₀ n).stepFill_spec q (stages_supp_nonempty Γ₀ n)
  refine ⟨n + 1, Γ, ?_⟩
  rw [stages_succ, hn]
  exact hΓ

/-! ## The limit -/

/-- The limit labelling: the (eventually constant) label of `q` along the stages. -/
noncomputable def limitChain (q : ℚ) : DPoint :=
  Classical.choose (Classical.choose_spec (exists_stage_labelled Γ₀ q))

theorem limitChain_spec (q : ℚ) : ∃ n, (stages Γ₀ n).s q = some (limitChain Γ₀ q) :=
  ⟨_, Classical.choose_spec (Classical.choose_spec (exists_stage_labelled Γ₀ q))⟩

/-- Labels never change once placed, so any stage's label of `q` is the limit label. -/
theorem limit_eq_of_labelled {n : ℕ} {q : ℚ} {Γ : DPoint} (h : (stages Γ₀ n).s q = some Γ) :
    limitChain Γ₀ q = Γ := by
  obtain ⟨n', hn'⟩ := limitChain_spec Γ₀ q
  have h₁ := stages_mono Γ₀ (Nat.le_max_left n n') q Γ h
  have h₂ := stages_mono Γ₀ (Nat.le_max_right n n') q _ hn'
  rw [h₁] at h₂
  exact (Option.some.inj h₂).symm

theorem limit_coh {q q' : ℚ} (h : q < q') :
    canR (limitChain Γ₀ q).1 (limitChain Γ₀ q').1 := by
  obtain ⟨n, hn⟩ := limitChain_spec Γ₀ q
  obtain ⟨n', hn'⟩ := limitChain_spec Γ₀ q'
  exact (stages Γ₀ (max n n')).coh q q' _ _ h
    (stages_mono Γ₀ (Nat.le_max_left n n') q _ hn)
    (stages_mono Γ₀ (Nat.le_max_right n n') q' _ hn')

/-- `F`-witnessing of the limit: once `q` is labelled, the requirement `(q, ψ, true)` recurs,
and `stepF` places a witness above `q`. -/
theorem limit_witF (q : ℚ) (ψ : MinusFormula) (hψ : ψ.someFuture ∈ (limitChain Γ₀ q).1) :
    ∃ q', q < q' ∧ ψ ∈ (limitChain Γ₀ q').1 := by
  obtain ⟨n₀, hn₀⟩ := limitChain_spec Γ₀ q
  obtain ⟨n, hn₀n, hn⟩ := enum_spec (Sum.inr (q, ψ, true)) n₀
  have hq : (stages Γ₀ n).s q = some (limitChain Γ₀ q) := stages_mono Γ₀ hn₀n q _ hn₀
  obtain ⟨q', hq', Δ, hΔ, hψΔ⟩ := (stages Γ₀ n).stepF_spec ψ hq hψ
  refine ⟨q', hq', ?_⟩
  have hlab : (stages Γ₀ (n + 1)).s q' = some Δ := by
    rw [stages_succ, hn]
    exact hΔ
  rw [limit_eq_of_labelled Γ₀ hlab]
  exact hψΔ

/-- `P`-witnessing of the limit, the mirror of `limit_witF`. -/
theorem limit_witP (q : ℚ) (ψ : MinusFormula) (hψ : ψ.somePast ∈ (limitChain Γ₀ q).1) :
    ∃ q', q' < q ∧ ψ ∈ (limitChain Γ₀ q').1 := by
  obtain ⟨n₀, hn₀⟩ := limitChain_spec Γ₀ q
  obtain ⟨n, hn₀n, hn⟩ := enum_spec (Sum.inr (q, ψ, false)) n₀
  have hq : (stages Γ₀ n).s q = some (limitChain Γ₀ q) := stages_mono Γ₀ hn₀n q _ hn₀
  obtain ⟨q', hq', Δ, hΔ, hψΔ⟩ := (stages Γ₀ n).stepP_spec ψ hq hψ
  refine ⟨q', hq', ?_⟩
  have hlab : (stages Γ₀ (n + 1)).s q' = some Δ := by
    rw [stages_succ, hn]
    exact hΔ
  rw [limit_eq_of_labelled Γ₀ hlab]
  exact hψΔ

end Construction

/-! ## Chronicles -/

/-- A ℚ-chronicle: a coherent, `F`/`P`-witnessing labelling of ℚ by maximal TM⁻_d-consistent
sets. The chain the truth lemma runs along; the bundle index of
`Conservativity/MinusChainCompleteness.lean` is the subtype of these lying in one
`canBox`-class. Reflexive points may label many rationals; no injectivity is required. -/
structure Chronicle where
  /-- The labelling. -/
  c : ℚ → DPoint
  /-- Coherence: `q < q' ⟹ c q R c q'`. -/
  coh : ∀ q q', q < q' → canR (c q).1 (c q').1
  /-- Every `F`-formula at `q` is witnessed above `q`. -/
  witF : ∀ q ψ, ψ.someFuture ∈ (c q).1 → ∃ q', q < q' ∧ ψ ∈ (c q').1
  /-- Every `P`-formula at `q` is witnessed below `q`. -/
  witP : ∀ q ψ, ψ.somePast ∈ (c q).1 → ∃ q', q' < q ∧ ψ ∈ (c q').1

/-- **Chronicle existence** (`.Dense` only): every maximal TM⁻_d-consistent set lies at `0` on
some ℚ-chronicle — the limit of the stages seeded at it. -/
theorem exists_chronicle_through (Γ₀ : DPoint) : ∃ c : Chronicle, c.c 0 = Γ₀ :=
  ⟨⟨limitChain Γ₀, fun _ _ h => limit_coh Γ₀ h, limit_witF Γ₀, limit_witP Γ₀⟩,
    limit_eq_of_labelled Γ₀ (stages_zero_label Γ₀ 0)⟩

/-- A chronicle stays inside one `canBox`-class: `Γ ~ c q₀` gives `Γ ~ c q` for every `q`, by
MF along the chain (`canBox_of_canR`) and its mirror. -/
theorem chronicle_canBox_closed (c : Chronicle) {Γ : DPoint} {q₀ : ℚ}
    (h : canBox Γ.1 (c.c q₀).1) : ∀ q, canBox Γ.1 (c.c q).1 := by
  intro q
  rcases lt_trichotomy q₀ q with hlt | rfl | hgt
  · exact canBox_of_canR h (c.coh q₀ q hlt)
  · exact h
  · exact canBox_of_canR_rev h (c.coh q q₀ hgt)

end FormalSystem.Metalogic.Conservativity
