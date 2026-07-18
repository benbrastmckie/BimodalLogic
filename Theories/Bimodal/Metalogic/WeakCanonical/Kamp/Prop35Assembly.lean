import Bimodal.Metalogic.WeakCanonical.Kamp.Prop35Chain
import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.Kamp.IntervalType

/-!
# Proposition 3.5: specialization and assembly (Rabinovich 2014, PDF p.5)

Completes Proposition 3.5 on the Phase-3 `ExistsForallFormula` object: every `∃∀`-formula with
one free variable is equivalent to a `TL(Until, Since)` formula. This module specializes the
generic machinery already landed — the atomic layer (`unaryToFormula`, `Prop35ExistsForall.lean`)
and the generic Until/Since chain bridge (`buildRight_spec_iff_chain` / `buildLeft_spec_iff_chain`,
`Prop35Chain.lean`) — to `ψ`'s own `Fin`-indexed point/interval types, assembles the full
biconditional against `efSat`, and lifts the result through `VeeExistsForall` (Def 3.3, p.4).

## Contents

- `efPointTP` / `efIntervalTP`: render `ψ.pointType` / `ψ.intervalType` (already `UnaryType`s) as
  `TemporalPred`s via `unaryToFormula`.
- `translateProp35`: the Prop 3.5 translation of a single `ExistsForallFormula` with one free
  variable, via `translateEF1` pinned at the free variable's witness point.
- `translateProp35_correct`: `efSat N env ψ ↔ temporal_truth N atomMap (env 0) (translateProp35 …
  ψ)`.
- `translateVeeProp35` / `translateVeeProp35_correct`: the lift through `VeeExistsForall` (Def
  3.3, p.4), mirroring the legacy `VVecEA2.translateRight`'s own `translateVEF1` wrapper.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 3.5 (p.5), Definition 3.3 (p.4).
  Cited by PDF page; the companion markdown transcription is corrupt.
- `Prop35ExistsForall.lean`: `unaryToFormula`, `unaryToFormula_correct`.
- `Prop35Chain.lean`: `buildRight_spec_iff_chain`, `buildLeft_spec_iff_chain`.
- `Translation.lean`: `translateEF1`, `translateEF1_correct`.
- `ExistsForallFormula.lean`: `ExistsForallFormula`, `efSat`.
- `VeeExistsForall.lean`: `VeeExistsForall`, `veeSat`.
- `ExistsForallNF.lean`: `translateVEF1`, `translateVEF1_correct`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

/-! ## 1. Rendering point/interval types as temporal predicates -/

/-- Render a `ψ.pointType` unary type as a `TemporalPred` via `unaryToFormula`. -/
noncomputable def efPointTP {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) : TemporalPred :=
  ⟨unaryToFormula atomMap h_surj τ⟩

/-- Render a `ψ.intervalType` unary type as a `TemporalPred` via `unaryToFormula`. -/
noncomputable def efIntervalTP {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) : TemporalPred :=
  ⟨unaryToFormula atomMap h_surj τ⟩

/-- `efPointTP` reads back exactly as `unaryHolds`. -/
theorem efPointTP_eval {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) (t : N.carrier) :
    (efPointTP atomMap h_surj τ).eval_at N atomMap t ↔ unaryHolds N τ t := by
  unfold efPointTP TemporalPred.eval_at
  exact unaryToFormula_correct N atomMap h_surj τ t

/-- `efIntervalTP` reads back exactly as `unaryHolds`. -/
theorem efIntervalTP_eval {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (τ : UnaryType sig F) (t : N.carrier) :
    (efIntervalTP atomMap h_surj τ).eval_at N atomMap t ↔ unaryHolds N τ t := by
  unfold efIntervalTP TemporalPred.eval_at
  exact unaryToFormula_correct N atomMap h_surj τ t

/-! ## 2. The Prop 3.5 translation -/

/-- The Prop 3.5 translation of a single `∃∀`-formula with one free variable: `translateEF1`
pinned at the free variable's witness point, with point/interval types rendered via
`efPointTP`/`efIntervalTP`. -/
noncomputable def translateProp35 {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 1) : Formula :=
  translateEF1 ψ.n (ψ.pin 0)
    (fun j => efPointTP atomMap h_surj (ψ.pointType j))
    (fun i => efIntervalTP atomMap h_surj (ψ.intervalType i))

theorem translateProp35_correct {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 1 → N.carrier) (ψ : ExistsForallFormula sig F 1) :
    efSat N env ψ ↔ temporal_truth N atomMap (env 0) (translateProp35 atomMap h_surj ψ) := by
  rw [translateProp35, translateEF1_correct]
  set k : Fin (ψ.n + 1) := ψ.pin 0 with hk_def
  set alphaR : Nat → TemporalPred :=
    fun m => efPointTP atomMap h_surj (ψ.pointType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
    with halphaR_def
  set betaR : Nat → TemporalPred :=
    fun m => efIntervalTP atomMap h_surj (ψ.intervalType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
    with hbetaR_def
  set alphaL : Nat → TemporalPred :=
    fun m => efPointTP atomMap h_surj (ψ.pointType ⟨k.val - 1 - m, by omega⟩)
    with halphaL_def
  set betaL : Nat → TemporalPred :=
    fun m => efIntervalTP atomMap h_surj (ψ.intervalType ⟨k.val - 1 - m + 1, by omega⟩)
    with hbetaL_def
  have hright_eq :
      (List.finRange (ψ.n - k.val)).map (fun i =>
        let idx := k.val + 1 + i.val
        (efPointTP atomMap h_surj (ψ.pointType ⟨idx, by omega⟩),
         efIntervalTP atomMap h_surj (ψ.intervalType ⟨idx, by omega⟩))) =
      (List.finRange (ψ.n - k.val)).map (fun i => (alphaR i.val, betaR i.val)) := by
    apply List.map_congr_left
    intro i _
    simp only [halphaR_def, hbetaR_def]
    have e : min (k.val + 1 + i.val) ψ.n = k.val + 1 + i.val := by omega
    simp only [e]
  have hleft_eq :
      (List.finRange k.val).map (fun i =>
        let idx := k.val - 1 - i.val
        (efPointTP atomMap h_surj (ψ.pointType ⟨idx, by omega⟩),
         efIntervalTP atomMap h_surj (ψ.intervalType ⟨idx + 1, by omega⟩))) =
      (List.finRange k.val).map (fun i => (alphaL i.val, betaL i.val)) := by
    apply List.map_congr_left
    intro i _
    simp only [halphaL_def, hbetaL_def]
  rw [hright_eq, hleft_eq, buildRight_spec_iff_chain, buildLeft_spec_iff_chain]
  constructor
  · intro h
    rw [efSat_interval_iff] at h
    obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
    have hpin0 : env 0 = x k := hpin 0
    refine ⟨?_, ?_, ?_⟩
    · rw [hpin0]
      exact (efPointTP_eval N atomMap h_surj (ψ.pointType k) (x k)).mpr (hpt k)
    · refine ⟨fun m => x ⟨min (k.val + m) ψ.n, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
      · show x ⟨min (k.val + 0) ψ.n, by omega⟩ = env 0
        have e0 : min (k.val + 0) ψ.n = k.val := by omega
        simp only [e0]
        exact hpin0.symm
      · intro i j hij hjd
        show x ⟨min (k.val + i) ψ.n, by omega⟩ < x ⟨min (k.val + j) ψ.n, by omega⟩
        have ei : min (k.val + i) ψ.n = k.val + i := by omega
        have ej : min (k.val + j) ψ.n = k.val + j := by omega
        simp only [ei, ej]
        exact hmono (show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val + j, by omega⟩ by
          simp only [Fin.lt_def]; omega)
      · intro i hi
        show TemporalPred.eval_at N atomMap (alphaR i) (x ⟨min (k.val + (i + 1)) ψ.n, by omega⟩)
        have e1 : min (k.val + (i + 1)) ψ.n = k.val + 1 + i := by omega
        simp only [halphaR_def, e1]
        have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
        simp only [e2]
        rw [efPointTP_eval]
        exact hpt ⟨k.val + 1 + i, by omega⟩
      · intro i hi y hy1 hy2
        show TemporalPred.eval_at N atomMap (betaR i) y
        simp only [hbetaR_def]
        have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
        simp only [e2]
        rw [efIntervalTP_eval]
        have eidx : k.val + 1 + i = k.val + i + 1 := by omega
        simp only [eidx]
        have ei : min (k.val + i) ψ.n = k.val + i := by omega
        have ei1 : min (k.val + (i + 1)) ψ.n = k.val + i + 1 := by omega
        have hy1' : x (⟨k.val + i, by omega⟩ : Fin ψ.n).castSucc < y := by
          show x ⟨k.val + i, by omega⟩ < y
          rw [show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨min (k.val + i) ψ.n, by omega⟩ from by simp only [ei]]
          exact hy1
        have hy2' : y < x (⟨k.val + i, by omega⟩ : Fin ψ.n).succ := by
          show y < x ⟨k.val + i + 1, by omega⟩
          rw [show (⟨k.val + i + 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨min (k.val + (i + 1)) ψ.n, by omega⟩ from by simp only [ei1]]
          exact hy2
        exact (ψ.intervalSet_holds_iff N _ y).mp (hbetween ⟨k.val + i, by omega⟩ y hy1' hy2')
      · intro y hy
        show TemporalPred.eval_at N atomMap
          (efIntervalTP atomMap h_surj (ψ.intervalType ⟨ψ.n + 1, by omega⟩)) y
        rw [efIntervalTP_eval]
        have ed : min (k.val + (ψ.n - k.val)) ψ.n = ψ.n := by omega
        have hy' : x (Fin.last ψ.n) < y := by
          rw [show (Fin.last ψ.n) = (⟨min (k.val + (ψ.n - k.val)) ψ.n, by omega⟩ : Fin (ψ.n + 1))
              from by apply Fin.ext; simp only [ed, Fin.val_last]]
          exact hy
        exact (ψ.intervalSet_holds_iff N _ y).mp (hafter y hy')
    · refine ⟨fun m => x ⟨k.val - m, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
      · show x ⟨k.val - 0, by omega⟩ = env 0
        simp only [Nat.sub_zero]
        exact hpin0.symm
      · intro i j hij hjd
        show x ⟨k.val - j, by omega⟩ < x ⟨k.val - i, by omega⟩
        exact hmono (show (⟨k.val - j, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val - i, by omega⟩ by
          simp only [Fin.lt_def]; omega)
      · intro i hi
        show TemporalPred.eval_at N atomMap (alphaL i) (x ⟨k.val - (i + 1), by omega⟩)
        simp only [halphaL_def]
        have e : k.val - (i + 1) = k.val - 1 - i := by omega
        simp only [e]
        rw [efPointTP_eval]
        exact hpt ⟨k.val - 1 - i, by omega⟩
      · intro i hi y hy1 hy2
        show TemporalPred.eval_at N atomMap (betaL i) y
        simp only [hbetaL_def]
        rw [efIntervalTP_eval]
        have e : k.val - (i + 1) = k.val - 1 - i := by omega
        have e' : k.val - 1 - i + 1 = k.val - i := by omega
        have hy1' : x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).castSucc < y := by
          show x ⟨k.val - 1 - i, by omega⟩ < y
          rw [show (⟨k.val - 1 - i, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨k.val - (i + 1), by omega⟩ from by simp only [e]]
          exact hy1
        have hy2' : y < x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).succ := by
          show y < x ⟨k.val - 1 - i + 1, by omega⟩
          rw [show (⟨k.val - 1 - i + 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨k.val - i, by omega⟩ from by simp only [e']]
          exact hy2
        exact (ψ.intervalSet_holds_iff N _ y).mp (hbetween ⟨k.val - 1 - i, by omega⟩ y hy1' hy2')
      · intro y hy
        show TemporalPred.eval_at N atomMap
          (efIntervalTP atomMap h_surj (ψ.intervalType ⟨0, by omega⟩)) y
        rw [efIntervalTP_eval]
        have h0 : k.val - k.val = 0 := by omega
        have hy' : y < x (⟨0, by omega⟩ : Fin (ψ.n + 1)) := by
          rw [show (⟨0, by omega⟩ : Fin (ψ.n + 1)) = (⟨k.val - k.val, by omega⟩ : Fin (ψ.n + 1))
              from by simp only [h0]]
          exact hy
        exact (ψ.intervalSet_holds_iff N _ y).mp (hbefore y hy')
  · rintro ⟨hpt0, ⟨x', hx'0, hx'mono, hx'alpha, hx'beta, hx'cap⟩,
      ⟨x'', hx''0, hx''mono, hx''alpha, hx''beta, hx''cap⟩⟩
    set x : Fin (ψ.n + 1) → N.carrier :=
      fun j => if j.val ≤ k.val then x'' (k.val - j.val) else x' (j.val - k.val) with hx_def
    have hx_left : ∀ j : Fin (ψ.n + 1), j.val ≤ k.val → x j = x'' (k.val - j.val) := by
      intro j hj; simp only [hx_def, if_pos hj]
    have hx_right : ∀ j : Fin (ψ.n + 1), ¬ j.val ≤ k.val → x j = x' (j.val - k.val) := by
      intro j hj; simp only [hx_def, if_neg hj]
    have hxk : x k = env 0 := by
      rw [hx_left k (le_refl _), Nat.sub_self, hx''0]
    have hx0 : x (0 : Fin (ψ.n + 1)) = x'' k.val := by
      have hj : (0 : Fin (ψ.n + 1)).val ≤ k.val := by
        have e : (0 : Fin (ψ.n + 1)).val = 0 := rfl
        omega
      rw [hx_left 0 hj]
      have e : (0 : Fin (ψ.n + 1)).val = 0 := rfl
      rw [e, Nat.sub_zero]
    have hxlast : x (Fin.last ψ.n) = x' (ψ.n - k.val) := by
      by_cases h : (Fin.last ψ.n).val ≤ k.val
      · have hval : (Fin.last ψ.n).val = ψ.n := Fin.val_last ψ.n
        have hkeq : k.val = ψ.n := by omega
        rw [hx_left (Fin.last ψ.n) h, hval]
        have e1 : k.val - ψ.n = 0 := by omega
        have e2 : ψ.n - k.val = 0 := by omega
        rw [e1, e2, hx''0, hx'0]
      · have hval : (Fin.last ψ.n).val = ψ.n := Fin.val_last ψ.n
        rw [hx_right (Fin.last ψ.n) h, hval]
    rw [efSat_interval_iff]
    refine ⟨x, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- StrictMono x
      intro a b hab
      have hab' : a.val < b.val := by simp only [Fin.lt_def] at hab; omega
      by_cases ha : a.val ≤ k.val <;> by_cases hb : b.val ≤ k.val
      · rw [hx_left a ha, hx_left b hb]
        exact hx''mono (k.val - b.val) (k.val - a.val) (by omega) (by omega)
      · rw [hx_left a ha, hx_right b hb]
        have h1 : x'' (k.val - a.val) ≤ env 0 := by
          by_cases haeq : a.val = k.val
          · have : x'' (k.val - a.val) = env 0 := by rw [haeq, Nat.sub_self, hx''0]
            exact le_of_eq this
          · have hstep := hx''mono 0 (k.val - a.val) (by omega) (by omega)
            rw [hx''0] at hstep
            exact le_of_lt hstep
        have h2 : env 0 < x' (b.val - k.val) := by
          have hstep := hx'mono 0 (b.val - k.val) (by omega) (by omega)
          rwa [hx'0] at hstep
        exact lt_of_le_of_lt h1 h2
      · exact absurd hab' (by omega)
      · rw [hx_right a ha, hx_right b hb]
        exact hx'mono (a.val - k.val) (b.val - k.val) (by omega) (by omega)
    · -- pin condition
      intro m
      have hm0 : m = 0 := Subsingleton.elim m 0
      rw [hm0, ← hk_def]
      exact hxk.symm
    · -- pointType
      intro j
      by_cases hj : j.val ≤ k.val
      · rw [hx_left j hj]
        by_cases hjk : j.val = k.val
        · have hzero : k.val - j.val = 0 := by omega
          rw [hzero, hx''0]
          have hjeqk : j = k := Fin.ext hjk
          rw [hjeqk]
          exact (efPointTP_eval N atomMap h_surj (ψ.pointType k) (env 0)).mp hpt0
        · have hmk : k.val - j.val - 1 < k.val := by omega
          have halph := hx''alpha (k.val - j.val - 1) hmk
          have hm1 : k.val - j.val - 1 + 1 = k.val - j.val := by omega
          rw [hm1] at halph
          simp only [halphaL_def] at halph
          have hidx : k.val - 1 - (k.val - j.val - 1) = j.val := by omega
          simp only [hidx] at halph
          rw [efPointTP_eval] at halph
          exact halph
      · rw [hx_right j hj]
        have hjk : k.val < j.val := by omega
        have hmd : j.val - k.val - 1 < ψ.n - k.val := by omega
        have halph := hx'alpha (j.val - k.val - 1) hmd
        have hm1 : j.val - k.val - 1 + 1 = j.val - k.val := by omega
        rw [hm1] at halph
        simp only [halphaR_def] at halph
        have hidx : min (k.val + 1 + (j.val - k.val - 1)) ψ.n = j.val := by omega
        simp only [hidx] at halph
        rw [efPointTP_eval] at halph
        exact halph
    · -- hbefore
      intro y hy
      rw [ψ.intervalSet_holds_iff]
      rw [hx0] at hy
      have hb := hx''cap y hy
      exact (efIntervalTP_eval N atomMap h_surj (ψ.intervalType (⟨0, by omega⟩ : Fin (ψ.n + 2))) y).mp hb
    · -- hbetween
      intro i y hy1 hy2
      rw [ψ.intervalSet_holds_iff]
      show unaryHolds N (ψ.intervalType i.succ.castSucc) y
      have hcs : i.castSucc.val = i.val := rfl
      have hsc : i.succ.val = i.val + 1 := rfl
      rcases lt_trichotomy i.val k.val with hlt | heq | hgt
      · have h1 : i.castSucc.val ≤ k.val := by rw [hcs]; omega
        have h2 : i.succ.val ≤ k.val := by rw [hsc]; omega
        rw [hx_left i.castSucc h1, hcs] at hy1
        rw [hx_left i.succ h2, hsc] at hy2
        have hmk : k.val - i.val - 1 < k.val := by omega
        have hm1 : k.val - i.val - 1 + 1 = k.val - i.val := by omega
        have hbeta := hx''beta (k.val - i.val - 1) hmk y (by rw [hm1]; exact hy1) hy2
        simp only [hbetaL_def] at hbeta
        have hidx : k.val - 1 - (k.val - i.val - 1) + 1 = i.val + 1 := by omega
        simp only [hidx] at hbeta
        rw [efIntervalTP_eval] at hbeta
        exact hbeta
      · have h1 : i.castSucc.val ≤ k.val := by rw [hcs]; omega
        have h2 : ¬ i.succ.val ≤ k.val := by rw [hsc]; omega
        rw [hx_left i.castSucc h1, hcs, heq, Nat.sub_self, hx''0] at hy1
        rw [hx_right i.succ h2, hsc] at hy2
        have hd0 : 0 < ψ.n - k.val := by omega
        have hidx0 : i.val + 1 - k.val = 1 := by omega
        have hbeta := hx'beta 0 hd0 y (by rw [hx'0]; exact hy1) (by rw [hidx0] at hy2; exact hy2)
        simp only [hbetaR_def] at hbeta
        have hidx : min (k.val + 1 + 0) ψ.n = i.val + 1 := by omega
        simp only [hidx] at hbeta
        rw [efIntervalTP_eval] at hbeta
        exact hbeta
      · have h1 : ¬ i.castSucc.val ≤ k.val := by rw [hcs]; omega
        have h2 : ¬ i.succ.val ≤ k.val := by rw [hsc]; omega
        rw [hx_right i.castSucc h1, hcs] at hy1
        rw [hx_right i.succ h2, hsc] at hy2
        have hmd : i.val - k.val < ψ.n - k.val := by omega
        have hidx1 : i.val + 1 - k.val = i.val - k.val + 1 := by omega
        have hbeta := hx'beta (i.val - k.val) hmd y hy1 (by rw [hidx1] at hy2; exact hy2)
        simp only [hbetaR_def] at hbeta
        have hidx : min (k.val + 1 + (i.val - k.val)) ψ.n = i.val + 1 := by omega
        simp only [hidx] at hbeta
        rw [efIntervalTP_eval] at hbeta
        exact hbeta
    · -- hafter
      intro y hy
      rw [ψ.intervalSet_holds_iff]
      rw [hxlast] at hy
      have hb := hx'cap y hy
      exact (efIntervalTP_eval N atomMap h_surj (ψ.intervalType (⟨ψ.n + 1, by omega⟩ : Fin (ψ.n + 2))) y).mp hb

/-! ## 4. Lift through VeeExistsForall (Def 3.3, p.4) -/

/-- The Prop 3.5 translation of a `∨∃∀`-formula: fold `translateProp35` over the disjuncts via
`translateVEF1`, mirroring the legacy `VVecEA2.translateRight`'s own `translateVEF1` wrapper. -/
noncomputable def translateVeeProp35 {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (Ψ : VeeExistsForall sig F 1) : Formula :=
  translateVEF1 (Ψ.map (translateProp35 atomMap h_surj))

/-- **Proposition 3.5 (full, PDF p.5).** A `∨∃∀`-formula with one free variable is satisfied iff
its Prop 3.5 translation holds as temporal truth. -/
theorem translateVeeProp35_correct {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 1 → N.carrier) (Ψ : VeeExistsForall sig F 1) :
    veeSat N env Ψ ↔ temporal_truth N atomMap (env 0) (translateVeeProp35 atomMap h_surj Ψ) := by
  unfold translateVeeProp35 veeSat
  rw [translateVEF1_correct]
  constructor
  · rintro ⟨ψ, hmem, hsat⟩
    exact ⟨translateProp35 atomMap h_surj ψ, List.mem_map_of_mem hmem,
      (translateProp35_correct N atomMap h_surj env ψ).mp hsat⟩
  · rintro ⟨f, hmem, htt⟩
    obtain ⟨ψ, hmem', rfl⟩ := List.mem_map.mp hmem
    exact ⟨ψ, hmem', (translateProp35_correct N atomMap h_surj env ψ).mpr htt⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
