/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop35Chain
import FormalSystem.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import FormalSystem.Metalogic.WeakCanonical.Kamp.IntervalType
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure
import FormalSystem.Metalogic.WeakCanonical.Kamp.PerFormulaRender
import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas

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
- **Fin layer (per-formula representation)**: `efPointTPFin` / `efIntervalSetTPFin` (+ `_eval`),
  `translateProp35Fin` / `translateProp35Fin_correct`, and the Vee lift `translateVeeProp35Fin` /
  `translateVeeProp35Fin_correct` — the Prop 3.5 translation on the per-formula finite
  representation (`ExistsForallFormulaFin`, `PerFormulaExistsForall.lean`), every render THROUGH
  the per-formula renderer `unaryToFormulaFin` (`PerFormulaRender.lean`). No
  `Fintype (sigE sig F).preds` / `DecidableEq (sigE sig F).preds` and no full-alphabet
  `Finset.univ` anywhere in the Fin layer: every enumeration is over the formula's own
  mentioned-atom set `M` or a per-formula `Finset (UnaryTypeFin sig F M)`, so the layer survives
  the infinite E[Σ] of Def 4.1 (p.5). The correctness proof is the render micro-gate proof
  (`PerFormulaRenderProbe.lean`, VERDICT GO) promoted onto the production object, with the
  probe-local `EFFin` (parameter `M`) replaced by the production `ExistsForallFormulaFin`
  (bundled `M`).

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

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula Atom)
open FormalSystem.Metalogic.WeakCanonical

/-- A `foldr`-of-`disj` temporal predicate holds at `y` iff some list element does (the empty fold
is `⊥`, which never holds). Instance-free: shared by the total-type section and the Fin layer. -/
private theorem eval_at_foldr_disj {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (atomMap : Formula → (sigE sig F).preds)
    (L : List TemporalPred) (y : N.carrier) :
    (L.foldr TemporalPred.disj TemporalPred.bot).eval_at N atomMap y ↔
      ∃ tp ∈ L, tp.eval_at N atomMap y := by
  induction L with
  | nil => simp [TemporalPred.eval_at, TemporalPred.bot, temporal_truth]
  | cons hd tl ih =>
    rw [List.foldr_cons, TemporalPred.eval_at_disj, ih]
    constructor
    · rintro (h | ⟨tp, htp, hev⟩)
      · exact ⟨hd, by simp, h⟩
      · exact ⟨tp, by simp [htp], hev⟩
    · rintro ⟨tp, htp, hev⟩
      rcases List.mem_cons.mp htp with rfl | htl
      · exact Or.inl hev
      · exact Or.inr ⟨tp, htl, hev⟩
/-! ## 5. Fin layer: the Prop 3.5 translation on the per-formula representation

The render micro-gate content (`PerFormulaRenderProbe.lean`, VERDICT GO) promoted onto the
production per-formula object `ExistsForallFormulaFin` (`PerFormulaExistsForall.lean`): point
types `UnaryTypeFin sig F M`, interval types `IntervalTypeFin sig F M`, all rendered by the
per-formula renderer `unaryToFormulaFin` (`PerFormulaRender.lean`). The probe's `EFFin` carried
`M` as a type parameter; the production object bundles `M` as a field — the statements and
proofs are otherwise the gate proofs verbatim. NO `Fintype (sigE sig F).preds`, NO
`DecidableEq (sigE sig F).preds`, NO full-alphabet `Finset.univ`: every enumeration is
`M`-relative (Def 4.1, p.5 compatible), and NO correctness statement is weakened — `efSatFin`
is the literal Def 3.1 (p.4) satisfaction on the partial relations. -/

/-- Render a partial 1-type over the mentioned-atom set `M` as a `TemporalPred` via the
per-formula renderer `unaryToFormulaFin`. The Fin counterpart of `efPointTP`. -/
noncomputable def efPointTPFin {sig : MonadicSignature} {F : Finset Formula}
    (_atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (c : UnaryTypeFin sig F M) : TemporalPred :=
  ⟨unaryToFormulaFin nameOf c⟩

/-- `efPointTPFin` reads back exactly as `partialHolds` — this is `unaryToFormulaFin_correct`
verbatim. -/
theorem efPointTPFin_eval {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (c : UnaryTypeFin sig F M) (t : N.carrier) :
    (efPointTPFin atomMap nameOf c).eval_at N atomMap t ↔ partialHolds N c t := by
  unfold efPointTPFin TemporalPred.eval_at
  exact unaryToFormulaFin_correct N atomMap nameOf hName c t

/-- The disjunction of the per-completion `efPointTPFin` translations of a per-formula
interval type `S`, folding `TemporalPred.disj` over `S.toList` with unit `TemporalPred.bot`.
The Fin counterpart of `efIntervalSetTP`; the enumeration is over the per-formula `Finset`
`S`, never over the whole alphabet. -/
noncomputable def efIntervalSetTPFin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (S : IntervalTypeFin sig F M) : TemporalPred :=
  (S.toList.map (efPointTPFin atomMap nameOf)).foldr TemporalPred.disj TemporalPred.bot

/-- `efIntervalSetTPFin` reads back exactly as `intervalHoldsFin`: the disjunction of the
per-completion translations holds at `y` iff some admissible partial completion in `S` is
realized at `y` — each disjunct THROUGH `unaryToFormulaFin_correct` (via
`efPointTPFin_eval`). -/
theorem efIntervalSetTPFin_eval {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    {M : Finset (AtomKind (sigE sig F) 1)}
    (S : IntervalTypeFin sig F M) (y : N.carrier) :
    (efIntervalSetTPFin atomMap nameOf S).eval_at N atomMap y ↔ intervalHoldsFin N S y := by
  rw [efIntervalSetTPFin, eval_at_foldr_disj]
  simp only [List.mem_map, Finset.mem_toList, intervalHoldsFin]
  constructor
  · rintro ⟨tp, ⟨c, hcS, rfl⟩, htp⟩
    exact ⟨c, hcS, (efPointTPFin_eval N atomMap nameOf hName c y).mp htp⟩
  · rintro ⟨c, hcS, hc⟩
    exact ⟨efPointTPFin atomMap nameOf c, ⟨c, hcS, rfl⟩,
      (efPointTPFin_eval N atomMap nameOf hName c y).mpr hc⟩

/-- **The per-formula Prop 3.5 translation.** `translateEF1` pinned at the free variable's
witness point, with point types rendered via `efPointTPFin` and interval types rendered via
`efIntervalSetTPFin` — every render THROUGH `unaryToFormulaFin`, all enumeration
`M`-relative. The Fin counterpart of `translateProp35`. -/
noncomputable def translateProp35Fin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 1) : Formula :=
  translateEF1 ψ.n (ψ.pin 0)
    (fun j => efPointTPFin atomMap nameOf (ψ.pointType j))
    (fun i => efIntervalSetTPFin atomMap nameOf (ψ.intervalType i))

/-- **Render correctness, end-to-end (the promoted micro-gate obligation).** The per-formula
Prop 3.5 translation is fully correct: `efSatFin N env ψ ↔ temporal_truth N atomMap (env 0)
(translateProp35Fin … ψ)`. The proof routes every point-type clause through
`efPointTPFin_eval` and every interval clause through `efIntervalSetTPFin_eval` — i.e.
end-to-end THROUGH `unaryToFormulaFin_correct` — and reuses the representation-independent
chain machinery (`translateEF1_correct`, `buildRight_spec_iff_chain`,
`buildLeft_spec_iff_chain`) unchanged. Mirrors `translateProp35_correct` with the total-type
interfaces replaced by the per-formula ones; NO correctness statement is weakened and no
`Fintype`/`DecidableEq` instance on the alphabet is consumed. Promoted from the render
micro-gate (`PerFormulaRenderProbe.lean`, VERDICT GO). -/
theorem translateProp35Fin_correct {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 1 → N.carrier) (ψ : ExistsForallFormulaFin sig F 1) :
    efSatFin N env ψ ↔
      temporal_truth N atomMap (env 0) (translateProp35Fin atomMap nameOf ψ) := by
  rw [translateProp35Fin, translateEF1_correct]
  set k : Fin (ψ.n + 1) := ψ.pin 0 with hk_def
  set alphaR : Nat → TemporalPred :=
    fun m => efPointTPFin atomMap nameOf (ψ.pointType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
    with halphaR_def
  set betaR : Nat → TemporalPred :=
    fun m => efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
    with hbetaR_def
  set alphaL : Nat → TemporalPred :=
    fun m => efPointTPFin atomMap nameOf (ψ.pointType ⟨k.val - 1 - m, by omega⟩)
    with halphaL_def
  set betaL : Nat → TemporalPred :=
    fun m => efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨k.val - 1 - m + 1, by omega⟩)
    with hbetaL_def
  have hright_eq :
      (List.finRange (ψ.n - k.val)).map (fun i =>
        let idx := k.val + 1 + i.val
        (efPointTPFin atomMap nameOf (ψ.pointType ⟨idx, by omega⟩),
         efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨idx, by omega⟩))) =
      (List.finRange (ψ.n - k.val)).map (fun i => (alphaR i.val, betaR i.val)) := by
    apply List.map_congr_left
    intro i _
    simp only [halphaR_def, hbetaR_def]
    have e : min (k.val + 1 + i.val) ψ.n = k.val + 1 + i.val := by omega
    simp only [e]
  have hleft_eq :
      (List.finRange k.val).map (fun i =>
        let idx := k.val - 1 - i.val
        (efPointTPFin atomMap nameOf (ψ.pointType ⟨idx, by omega⟩),
         efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨idx + 1, by omega⟩))) =
      (List.finRange k.val).map (fun i => (alphaL i.val, betaL i.val)) := by
    apply List.map_congr_left
    intro i _
    simp only [halphaL_def, hbetaL_def]
  rw [hright_eq, hleft_eq, buildRight_spec_iff_chain, buildLeft_spec_iff_chain]
  constructor
  · intro h
    rw [efSatFin_interval_iff] at h
    obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, hafter⟩ := h
    have hpin0 : env 0 = x k := hpin 0
    refine ⟨?_, ?_, ?_⟩
    · rw [hpin0]
      exact (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType k) (x k)).mpr (hpt k)
    · refine ⟨fun m => x ⟨min (k.val + m) ψ.n, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
      · change x ⟨min (k.val + 0) ψ.n, by omega⟩ = env 0
        have e0 : min (k.val + 0) ψ.n = k.val := by omega
        simp only [e0]
        exact hpin0.symm
      · intro i j hij hjd
        change x ⟨min (k.val + i) ψ.n, by omega⟩ < x ⟨min (k.val + j) ψ.n, by omega⟩
        have ei : min (k.val + i) ψ.n = k.val + i := by omega
        have ej : min (k.val + j) ψ.n = k.val + j := by omega
        simp only [ei, ej]
        exact hmono (show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val + j, by omega⟩ by
          simp only [Fin.lt_def]; omega)
      · intro i hi
        change TemporalPred.eval_at N atomMap (alphaR i) (x ⟨min (k.val + (i + 1)) ψ.n, by omega⟩)
        have e1 : min (k.val + (i + 1)) ψ.n = k.val + 1 + i := by omega
        simp only [halphaR_def, e1]
        have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
        simp only [e2]
        rw [efPointTPFin_eval (hName := hName)]
        exact hpt ⟨k.val + 1 + i, by omega⟩
      · intro i hi y hy1 hy2
        show TemporalPred.eval_at N atomMap (betaR i) y
        simp only [hbetaR_def]
        have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
        simp only [e2]
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have eidx : k.val + 1 + i = k.val + i + 1 := by omega
        simp only [eidx]
        have ei : min (k.val + i) ψ.n = k.val + i := by omega
        have ei1 : min (k.val + (i + 1)) ψ.n = k.val + i + 1 := by omega
        have hy1' : x (⟨k.val + i, by omega⟩ : Fin ψ.n).castSucc < y := by
          change x ⟨k.val + i, by omega⟩ < y
          rw [show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨min (k.val + i) ψ.n, by omega⟩ from by simp only [ei]]
          exact hy1
        have hy2' : y < x (⟨k.val + i, by omega⟩ : Fin ψ.n).succ := by
          change y < x ⟨k.val + i + 1, by omega⟩
          rw [show (⟨k.val + i + 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨min (k.val + (i + 1)) ψ.n, by omega⟩ from by simp only [ei1]]
          exact hy2
        exact hbetween ⟨k.val + i, by omega⟩ y hy1' hy2'
      · intro y hy
        change TemporalPred.eval_at N atomMap
          (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨ψ.n + 1, by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have ed : min (k.val + (ψ.n - k.val)) ψ.n = ψ.n := by omega
        have hy' : x (Fin.last ψ.n) < y := by
          rw [show (Fin.last ψ.n) = (⟨min (k.val + (ψ.n - k.val)) ψ.n, by omega⟩ : Fin (ψ.n + 1))
              from by apply Fin.ext; simp only [ed, Fin.val_last]]
          exact hy
        exact hafter y hy'
    · refine ⟨fun m => x ⟨k.val - m, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
      · change x ⟨k.val - 0, by omega⟩ = env 0
        simp only [Nat.sub_zero]
        exact hpin0.symm
      · intro i j hij hjd
        change x ⟨k.val - j, by omega⟩ < x ⟨k.val - i, by omega⟩
        exact hmono (show (⟨k.val - j, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val - i, by omega⟩ by
          simp only [Fin.lt_def]; omega)
      · intro i hi
        change TemporalPred.eval_at N atomMap (alphaL i) (x ⟨k.val - (i + 1), by omega⟩)
        simp only [halphaL_def]
        have e : k.val - (i + 1) = k.val - 1 - i := by omega
        simp only [e]
        rw [efPointTPFin_eval (hName := hName)]
        exact hpt ⟨k.val - 1 - i, by omega⟩
      · intro i hi y hy1 hy2
        show TemporalPred.eval_at N atomMap (betaL i) y
        simp only [hbetaL_def]
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have e : k.val - (i + 1) = k.val - 1 - i := by omega
        have e' : k.val - 1 - i + 1 = k.val - i := by omega
        have hy1' : x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).castSucc < y := by
          change x ⟨k.val - 1 - i, by omega⟩ < y
          rw [show (⟨k.val - 1 - i, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨k.val - (i + 1), by omega⟩ from by simp only [e]]
          exact hy1
        have hy2' : y < x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).succ := by
          change y < x ⟨k.val - 1 - i + 1, by omega⟩
          rw [show (⟨k.val - 1 - i + 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨k.val - i, by omega⟩ from by simp only [e']]
          exact hy2
        exact hbetween ⟨k.val - 1 - i, by omega⟩ y hy1' hy2'
      · intro y hy
        change TemporalPred.eval_at N atomMap
          (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨0, by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have h0 : k.val - k.val = 0 := by omega
        have hy' : y < x (⟨0, by omega⟩ : Fin (ψ.n + 1)) := by
          rw [show (⟨0, by omega⟩ : Fin (ψ.n + 1)) = (⟨k.val - k.val, by omega⟩ : Fin (ψ.n + 1))
              from by simp only [h0]]
          exact hy
        exact hbefore y hy'
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
    rw [efSatFin_interval_iff]
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
          exact (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType k) (env 0)).mp hpt0
        · have hmk : k.val - j.val - 1 < k.val := by omega
          have halph := hx''alpha (k.val - j.val - 1) hmk
          have hm1 : k.val - j.val - 1 + 1 = k.val - j.val := by omega
          rw [hm1] at halph
          simp only [halphaL_def] at halph
          have hidx : k.val - 1 - (k.val - j.val - 1) = j.val := by omega
          simp only [hidx] at halph
          rw [efPointTPFin_eval (hName := hName)] at halph
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
        rw [efPointTPFin_eval (hName := hName)] at halph
        exact halph
    · -- before clause
      intro y hy
      rw [hx0] at hy
      have hb := hx''cap y hy
      exact (efIntervalSetTPFin_eval N atomMap nameOf hName
        (ψ.intervalType (⟨0, by omega⟩ : Fin (ψ.n + 2))) y).mp hb
    · -- between clause
      intro i y hy1 hy2
      show intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y
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
        rw [efIntervalSetTPFin_eval (hName := hName)] at hbeta
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
        rw [efIntervalSetTPFin_eval (hName := hName)] at hbeta
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
        rw [efIntervalSetTPFin_eval (hName := hName)] at hbeta
        exact hbeta
    · -- after clause
      intro y hy
      rw [hxlast] at hy
      have hb := hx'cap y hy
      exact (efIntervalSetTPFin_eval N atomMap nameOf hName
        (ψ.intervalType (⟨ψ.n + 1, by omega⟩ : Fin (ψ.n + 2))) y).mp hb

/-! ## 6. Fin layer: lift through the per-formula Vee (Def 3.3, p.4) -/

/-- The Prop 3.5 translation of a per-formula `∨∃∀`-formula: fold `translateProp35Fin` over
the disjuncts via `translateVEF1`. The Fin counterpart of `translateVeeProp35`; each disjunct
carries its own mentioned-atom set `M`. -/
noncomputable def translateVeeProp35Fin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (Ψ : VeeExistsForallFin sig F 1) : Formula :=
  translateVEF1 (Ψ.map (translateProp35Fin atomMap nameOf))

/-- **Proposition 3.5 (full, PDF p.5), per-formula representation.** A per-formula
`∨∃∀`-formula with one free variable is satisfied (`veeSatFin`) iff its Prop 3.5 translation
holds as temporal truth. The Fin counterpart of `translateVeeProp35_correct`; disjunct-wise by
`translateProp35Fin_correct`. -/
theorem translateVeeProp35Fin_correct {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 1 → N.carrier) (Ψ : VeeExistsForallFin sig F 1) :
    veeSatFin N env Ψ ↔
      temporal_truth N atomMap (env 0) (translateVeeProp35Fin atomMap nameOf Ψ) := by
  unfold translateVeeProp35Fin veeSatFin
  rw [translateVEF1_correct]
  constructor
  · rintro ⟨ψ, hmem, hsat⟩
    exact ⟨translateProp35Fin atomMap nameOf ψ, List.mem_map_of_mem hmem,
      (translateProp35Fin_correct N atomMap nameOf hName env ψ).mp hsat⟩
  · rintro ⟨f, hmem, htt⟩
    obtain ⟨ψ, hmem', rfl⟩ := List.mem_map.mp hmem
    exact ⟨ψ, hmem', (translateProp35Fin_correct N atomMap nameOf hName env ψ).mpr htt⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
