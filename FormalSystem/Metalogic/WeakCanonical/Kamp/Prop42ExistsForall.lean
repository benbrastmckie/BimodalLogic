/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop35Assembly
import FormalSystem.Metalogic.WeakCanonical.Kamp.Section5Correspondence

/-!
# Proposition 4.2 on the ∃∀-Formula Object (Rabinovich 2014, PDF p.6)

Bridges the Phase-3 `ExistsForallFormula` object (two free variables) to the already-landed,
sorry-free legacy Prop 4.2 negation-closure engine (`VecEA2`/`VVecEA2`, `VVecEA2.negFix_iff`,
`prop42_contentful_of_attained`). This mirrors, for the two-endpoint canonical form, what
`Prop35Assembly.lean` did for Prop 3.5 (one free variable → temporal formula): it re-targets the
Phase-3 object onto the pre-existing engine rather than re-deriving negation closure.

## The endpoint-pinned canonical form

Rabinovich's Proposition 4.2 (p.6) works with the two-free-variable **canonical form**
`ψ₀(z₀) ∧ ψ₁(z₁) ∧ [bracket](z₀,z₁)` — exactly the shape of `VecEA2` (`VecEAFormula.lean`). This
is the `ExistsForallFormula sig F 2` whose two pins are the **endpoints** of its own ordered
point-chain: `pin 0 = 0` (the first point `x₀`) and `pin 1 = Fin.last ψ.n` (the last point
`x_{ψ.n}`). The `ψ.n − 1` interior points `x₁ < … < x_{ψ.n−1}` become the bracket's interior
witnesses; the two endpoints become `endpointLeft`/`endpointRight`.

**Caps.** `efSat` carries two **unbounded** universal caps — `β₀` on `(−∞, x₀)` and `β_{n+1}` on
`(x_{ψ.n}, +∞)` — that `VecEA2.holds` (a purely bounded interval predicate) does not. Rabinovich's
canonical two-endpoint form has these caps **vacuously true**; a faithful biconditional therefore
carries them as explicit semantic hypotheses `capTrivialLeft`/`capTrivialRight` (the cap types are
realized at every point), stated in `EndpointPinnedCapTrivial`. Under those hypotheses `efSat`
reduces exactly to the endpoint + bracket content of `VecEA2.holds`. We do **not** extend `VecEA2`
to carry caps — that would be canonical-form machinery beyond Rabinovich.

## Contents

- `translateProp42` / `translateProp42_correct`: single endpoint-pinned `ExistsForallFormula … 2`
  → `VecEA2`, with the biconditional against `efSat` under `EndpointPinnedCapTrivial`.
- `translateVeeProp42` / `translateVeeProp42_correct`: the lift through `VeeExistsForall` →
`VVecEA2`.
- `prop42_veeSat_negation`: the Prop 4.2 negation-closure corollary on the Phase-3 object, wiring
  `translateVeeProp42_correct` to `prop42_contentful_of_attained` (`Section5Correspondence.lean`).

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.2 (p.6), proved Section 5 pp.7-11.
  Cited by PDF page; the companion markdown transcription is corrupt.
- `Prop35Assembly.lean`: `efPointTP`, `efIntervalTP` (rendering `UnaryType`s as `TemporalPred`s).
- `VecEAFormula.lean`: `VecEA2`, `BracketFormula`, `VVecEA2`; `ExistsForallNF.lean`:
  `IntervalPattern.holds`, `holds_eq_zero`, `holds_eq_succ`.
- `Section5Correspondence.lean`: `prop42_contentful_of_attained`; `Prop42Contentful.lean`:
  `Prop42Contentful`; `VecEANegFix.lean`: `VVecEA2.negFix`, `VVecEA2.negFix_iff`.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula Atom)
open FormalSystem.Metalogic.WeakCanonical

/-! ## 5. Fin layer: the endpoint-pinned canonical translation on the per-formula representation

The Prop 4.2 translation on the per-formula finite object `ExistsForallFormulaFin`
(`PerFormulaExistsForall.lean`): the SHAPE of sections 1-4 survives verbatim — the target
`VecEA2`/`BracketFormula`/`VVecEA2` layer is `TemporalPred`-level and representation-independent
— with the point/interval renders switched to `efPointTPFin`/`efIntervalSetTPFin`
(`Prop35Assembly.lean` §5, THROUGH `unaryToFormulaFin`) and satisfaction stated on the partial
relations `partialHolds`/`intervalHoldsFin`. NO `Fintype (sigE sig F).preds`, NO
`DecidableEq (sigE sig F).preds`, NO full-alphabet `Finset.univ`: every enumeration is
`M`-relative (Def 4.1, p.5 compatible), and NO correctness statement is weakened. -/

/-- Fin-variant of `translateProp42`: the Prop 4.2 translation of an endpoint-pinned
two-free-variable per-formula `∃∀`-formula into the legacy `VecEA2` canonical form. The two
endpoints `x₀`, `x_{ψ.n}` become `endpointLeft`/`endpointRight`; the `ψ.n − 1` interior points
become the bracket witnesses; the bounded interval types become the bracket's segment types.
The two unbounded caps are dropped — see the module docstring. -/
noncomputable def translateProp42Fin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 2) : VecEA2 (ψ.n - 1) :=
  { endpointLeft := efPointTPFin atomMap nameOf (ψ.pointType 0)
    endpointRight := efPointTPFin atomMap nameOf (ψ.pointType (Fin.last ψ.n))
    bracket :=
      { pointTypes := fun i => efPointTPFin atomMap nameOf (ψ.pointType ⟨i.val + 1, by omega⟩)
        segmentTypes := fun j => efIntervalSetTPFin atomMap nameOf
            (ψ.intervalType ⟨j.val + 1, by omega⟩) } }

/-- Fin-variant of `EndpointPinnedCapTrivial`: structural + semantic hypotheses under which
`efSatFin` collapses to the endpoint-pinned `VecEA2` canonical form of Prop 4.2, with the two
unbounded caps realized at every point on the PARTIAL relation `intervalHoldsFin`. -/
structure EndpointPinnedCapTrivialFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (ψ : ExistsForallFormulaFin sig F 2) : Prop where
  /-- At least one interval: the two endpoints `x₀`, `x_{ψ.n}` are distinct. -/
  posN : 1 ≤ ψ.n
  /-- Left free variable pinned to the first point `x₀`. -/
  pinLeft : ψ.pin 0 = 0
  /-- Right free variable pinned to the last point `x_{ψ.n}`. -/
  pinRight : ψ.pin 1 = Fin.last ψ.n
  /-- The before-cap type `β₀` is realized at every point (Rabinovich's vacuous cap). -/
  capTrivialLeft : ∀ y : N.carrier, intervalHoldsFin N (ψ.intervalType 0) y
  /-- The after-cap type `β_{n+1}` is realized at every point (Rabinovich's vacuous cap). -/
  capTrivialRight : ∀ y : N.carrier, intervalHoldsFin N (ψ.intervalType (Fin.last (ψ.n + 1))) y

/-! ## 6. Fin layer: correctness of the translation -/

/-- Fin-variant of `translateProp42_forward`: a satisfied endpoint-pinned per-formula
`∃∀`-formula yields its `VecEA2` canonical form. Needs only the pinning/positivity data — the
caps are dropped, so `capTrivialLeft`/`capTrivialRight` are unused here. -/
theorem translateProp42Fin_forward {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2)
    (hep : EndpointPinnedCapTrivialFin N ψ)
    (h : efSatFin N env ψ) :
    (translateProp42Fin atomMap nameOf ψ).holds N atomMap (env 0) (env 1) := by
  rw [efSatFin_interval_iff] at h
  obtain ⟨x, hmono, hpin, hpt, _hbefore, hbetween, _hafter⟩ := h
  have hpos1 : 1 ≤ ψ.n := hep.posN
  have henv0 : env 0 = x 0 := by rw [hpin 0, hep.pinLeft]
  have henv1 : env 1 = x (Fin.last ψ.n) := by rw [hpin 1, hep.pinRight]
  refine ⟨?_, ?_, ?_⟩
  · -- endpointLeft at env 0 = x 0
    rw [henv0]
    exact (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType 0) (x 0)).mpr (hpt 0)
  · -- endpointRight at env 1 = x (Fin.last ψ.n)
    rw [henv1]
    exact (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType (Fin.last ψ.n))
        (x (Fin.last ψ.n))).mpr
      (hpt (Fin.last ψ.n))
  · -- bracket on (env 0, env 1)
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
    rcases Nat.eq_zero_or_pos (ψ.n - 1) with hz | hpos
    · -- no interior witnesses
      rw [IntervalPattern.holds_eq_zero (h := hz)]
      intro y hy0 hy1
      change TemporalPred.EvalAt N atomMap
        (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨0 + 1, by omega⟩)) y
      rw [efIntervalSetTPFin_eval (hName := hName)]
      have hi : (⟨0, by omega⟩ : Fin ψ.n).succ.castSucc = (⟨0 + 1, by omega⟩ : Fin (ψ.n + 2)) := by
        apply Fin.ext; rfl
      rw [← hi]
      refine hbetween ⟨0, by omega⟩ y ?_ ?_
      · show x (⟨0, by omega⟩ : Fin ψ.n).castSucc < y
        have : (⟨0, by omega⟩ : Fin ψ.n).castSucc = (0 : Fin (ψ.n + 1)) := by apply Fin.ext; rfl
        rw [this, ← henv0]; exact hy0
      · show y < x (⟨0, by omega⟩ : Fin ψ.n).succ
        have hlast : (⟨0, by omega⟩ : Fin ψ.n).succ = Fin.last ψ.n := by
          apply Fin.ext; simp only [Fin.val_succ, Fin.val_last]; omega
        rw [hlast, ← henv1]; exact hy1
    · -- k'+1 interior witnesses
      obtain ⟨k, hk⟩ : ∃ k, ψ.n - 1 = k + 1 := ⟨ψ.n - 1 - 1, by omega⟩
      rw [IntervalPattern.holds_eq_succ (h := hk)]
      refine ⟨fun i => x ⟨i.val + 1, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro a b hab
        exact hmono (show (⟨a.val + 1, by omega⟩ : Fin (ψ.n + 1)) < ⟨b.val + 1, by omega⟩ by
          simp only [Fin.lt_def]; simp only [Fin.lt_def] at hab; omega)
      · intro i
        constructor
        · rw [henv0]
          exact hmono (show (0 : Fin (ψ.n + 1)) < ⟨i.val + 1, by omega⟩ by
            simp only [Fin.lt_def, Fin.val_zero]; omega)
        · rw [henv1]
          have hilt := i.isLt
          exact hmono (show (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 1)) < Fin.last ψ.n by
            simp only [Fin.lt_def, Fin.val_last]; omega)
      · intro i
        change TemporalPred.EvalAt N atomMap
          (efPointTPFin atomMap nameOf (ψ.pointType ⟨i.val + 1, by omega⟩))
              (x ⟨i.val + 1, by omega⟩)
        rw [efPointTPFin_eval (hName := hName)]; exact hpt ⟨i.val + 1, by omega⟩
      · intro y hy0 hy1
        change TemporalPred.EvalAt N atomMap
          (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨0 + 1, by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have hi : (⟨0, by omega⟩ : Fin ψ.n).succ.castSucc =
            (⟨0 + 1, by omega⟩ : Fin (ψ.n + 2)) := by
          apply Fin.ext; rfl
        rw [← hi]
        refine hbetween ⟨0, by omega⟩ y ?_ ?_
        · show x (⟨0, by omega⟩ : Fin ψ.n).castSucc < y
          have : (⟨0, by omega⟩ : Fin ψ.n).castSucc = (0 : Fin (ψ.n + 1)) := by apply Fin.ext; rfl
          rw [this, ← henv0]; exact hy0
        · show y < x (⟨0, by omega⟩ : Fin ψ.n).succ
          have he : (⟨0, by omega⟩ : Fin ψ.n).succ = (⟨0 + 1, by omega⟩ : Fin (ψ.n + 1)) := by
            apply Fin.ext; rfl
          rw [he]; exact hy1
      · intro i y hy0 hy1
        change TemporalPred.EvalAt N atomMap
          (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨i.val + 1 + 1, by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have hi : (⟨i.val + 1, by omega⟩ : Fin ψ.n).succ.castSucc =
            (⟨i.val + 1 + 1, by omega⟩ : Fin (ψ.n + 2)) := by apply Fin.ext; rfl
        rw [← hi]
        refine hbetween ⟨i.val + 1, by omega⟩ y ?_ ?_
        · show x (⟨i.val + 1, by omega⟩ : Fin ψ.n).castSucc < y
          have he : (⟨i.val + 1, by omega⟩ : Fin ψ.n).castSucc =
              (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 1)) := by apply Fin.ext; rfl
          rw [he]; exact hy0
        · show y < x (⟨i.val + 1, by omega⟩ : Fin ψ.n).succ
          have he : (⟨i.val + 1, by omega⟩ : Fin ψ.n).succ =
              (⟨i.val + 1 + 1, by omega⟩ : Fin (ψ.n + 1)) := by apply Fin.ext; rfl
          rw [he]; exact hy1
      · intro y hy0 hy1
        change TemporalPred.EvalAt N atomMap
          (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨k + 1 + 1, by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have hi : (⟨k + 1, by omega⟩ : Fin ψ.n).succ.castSucc =
            (⟨k + 1 + 1, by omega⟩ : Fin (ψ.n + 2)) := by apply Fin.ext; rfl
        rw [← hi]
        refine hbetween ⟨k + 1, by omega⟩ y ?_ ?_
        · show x (⟨k + 1, by omega⟩ : Fin ψ.n).castSucc < y
          have he : (⟨k + 1, by omega⟩ : Fin ψ.n).castSucc =
              (⟨k + 1, by omega⟩ : Fin (ψ.n + 1)) := by apply Fin.ext; rfl
          rw [he]; exact hy0
        · show y < x (⟨k + 1, by omega⟩ : Fin ψ.n).succ
          have he : (⟨k + 1, by omega⟩ : Fin ψ.n).succ = Fin.last ψ.n := by
            apply Fin.ext; simp only [Fin.val_succ, Fin.val_last]; omega
          rw [he, ← henv1]; exact hy1

/-- Fin-variant of `translateProp42_backward`: the `VecEA2` canonical form, together with the
endpoint-pinning data and the two trivial caps, reconstructs a satisfied per-formula
`∃∀`-formula. The caps are supplied by `capTrivialLeft`/`capTrivialRight`; the interior chain is
glued from the two endpoints (`env 0`, `env 1`) and the bracket witnesses. -/
theorem translateProp42Fin_backward {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2)
    (hep : EndpointPinnedCapTrivialFin N ψ) (henv : env 0 < env 1)
    (hV : (translateProp42Fin atomMap nameOf ψ).holds N atomMap (env 0) (env 1)) :
    efSatFin N env ψ := by
  have hpos1 : 1 ≤ ψ.n := hep.posN
  simp only [translateProp42Fin, VecEA2.holds, BracketFormula.holds,
    BracketFormula.toIntervalPattern] at hV
  obtain ⟨hLraw, hRraw, hbr⟩ := hV
  have hL : partialHolds N (ψ.pointType 0) (env 0) :=
    (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType 0) (env 0)).mp hLraw
  have hR : partialHolds N (ψ.pointType (Fin.last ψ.n)) (env 1) :=
    (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType (Fin.last ψ.n)) (env 1)).mp hRraw
  rcases Nat.eq_zero_or_pos (ψ.n - 1) with hz | hpos
  · -- ψ.n = 1: two points, no interior witnesses
    rw [IntervalPattern.holds_eq_zero (h := hz)] at hbr
    have hn1 : ψ.n = 1 := by omega
    rw [efSatFin_interval_iff]
    refine ⟨fun j => if j.val = 0 then env 0 else env 1, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab
      have hab' : a.val < b.val := by simp only [Fin.lt_def] at hab; exact hab
      have ha : a.val = 0 := by omega
      have hb : b.val = 1 := by omega
      simp only [ha, hb]; simpa using henv
    · intro m
      by_cases hm : m.val = 0
      · rw [show m = 0 from Fin.ext hm, hep.pinLeft]; simp
      · rw [show m = 1 from Fin.ext (by omega), hep.pinRight]
        have hv : (Fin.last ψ.n).val = 1 := by rw [Fin.val_last]; omega
        simp only [hv]; simp
    · intro j
      by_cases hj : j.val = 0
      · simp only [hj, if_pos]
        have : j = 0 := Fin.ext hj
        rw [this]; exact hL
      · simp only [hj]
        have hjl : j = Fin.last ψ.n := by apply Fin.ext; rw [Fin.val_last]; omega
        rw [hjl]; exact hR
    · intro y _hy
      exact hep.capTrivialLeft y
    · intro i y hy0 hy1
      have hics : (i.castSucc.val = 0) := by
        have : i.val = 0 := by omega
        simpa using this
      have hisc : ¬ (i.succ.val = 0) := by simp [Fin.val_succ]
      simp only [hics] at hy0
      simp only [hisc] at hy1
      change intervalHoldsFin N (ψ.intervalType i.succ.castSucc) y
      have hidx : i.succ.castSucc = (⟨0 + 1, by omega⟩ : Fin (ψ.n + 2)) := by
        apply Fin.ext; simp only [Fin.val_castSucc, Fin.val_succ]; omega
      rw [hidx, ← efIntervalSetTPFin_eval N atomMap nameOf hName]
      exact hbr y hy0 hy1
    · intro y _hy
      exact hep.capTrivialRight y
  · -- ψ.n = k+2: interior witnesses
    obtain ⟨k, hk⟩ : ∃ k, ψ.n - 1 = k + 1 := ⟨ψ.n - 1 - 1, by omega⟩
    rw [IntervalPattern.holds_eq_succ (h := hk)] at hbr
    obtain ⟨w, hmonoW, hrangeW, hptW, hseg0W, hsegmidW, hseglastW⟩ := hbr
    -- Total witness accessor (clamped index) so no bound obligation escapes an `if` guard.
    set w' : Nat → N.carrier := fun m => w ⟨min m k, by omega⟩ with hw'_def
    have hw'val : ∀ (m : Nat) (hm : m < k + 1), w' m = w ⟨m, hm⟩ := by
      intro m hm; simp only [hw'_def]; congr 1; apply Fin.ext; simp only; omega
    -- The glued chain: endpoints at 0 and ψ.n, interior witnesses in between.
    set x : Fin (ψ.n + 1) → N.carrier :=
      fun j => if j.val = 0 then env 0 else if j.val = ψ.n then env 1 else w' (j.val - 1)
      with hx_def
    have hx0 : x 0 = env 0 := by simp only [hx_def]; rfl
    have hxlast : x (Fin.last ψ.n) = env 1 := by
      change (if (Fin.last ψ.n).val = 0 then env 0
          else if (Fin.last ψ.n).val = ψ.n then env 1 else w' ((Fin.last ψ.n).val - 1)) = env 1
      rw [Fin.val_last, if_neg (by omega), if_pos rfl]
    have hxmid : ∀ j : Fin (ψ.n + 1), 0 < j.val → j.val < ψ.n → x j = w' (j.val - 1) := by
      intro j hj0 hjn
      simp only [hx_def]
      rw [if_neg (by omega), if_neg (by omega)]
    rw [efSatFin_interval_iff]
    refine ⟨x, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- StrictMono
      intro a b hab
      have hab' : a.val < b.val := by simp only [Fin.lt_def] at hab; exact hab
      have haN : a.val < ψ.n := by omega
      by_cases ha0 : a.val = 0
      · rw [show x a = env 0 from by rw [show a = 0 from Fin.ext ha0]; exact hx0]
        by_cases hbN : b.val = ψ.n
        · rw [show x b = env 1 from by
            rw [show b = Fin.last ψ.n from by apply Fin.ext; rw [Fin.val_last]; exact hbN]
            exact hxlast]
          exact henv
        · rw [hxmid b (by omega) (by omega), hw'val (b.val - 1) (by omega)]
          exact (hrangeW ⟨b.val - 1, by omega⟩).1
      · by_cases hbN : b.val = ψ.n
        · rw [hxmid a (by omega) haN, hw'val (a.val - 1) (by omega), show x b = env 1 from by
            rw [show b = Fin.last ψ.n from by apply Fin.ext; rw [Fin.val_last]; exact hbN]
            exact hxlast]
          exact (hrangeW ⟨a.val - 1, by omega⟩).2
        · rw [hxmid a (by omega) haN, hw'val (a.val - 1) (by omega),
            hxmid b (by omega) (by omega), hw'val (b.val - 1) (by omega)]
          exact hmonoW ⟨a.val - 1, by omega⟩ ⟨b.val - 1, by omega⟩ (by
            simp only [Fin.lt_def]; omega)
    · -- pin
      intro m
      by_cases hm : m.val = 0
      · rw [show m = 0 from Fin.ext hm, hep.pinLeft]; exact hx0.symm
      · rw [show m = 1 from Fin.ext (by omega), hep.pinRight]; exact hxlast.symm
    · -- pointType
      intro j
      by_cases hj0 : j.val = 0
      · rw [show j = 0 from Fin.ext hj0, hx0]; exact hL
      · by_cases hjn : j.val = ψ.n
        · rw [show j = Fin.last ψ.n from by apply Fin.ext; rw [Fin.val_last]; exact hjn, hxlast]
          exact hR
        · rw [hxmid j (by omega) (by omega), hw'val (j.val - 1) (by omega)]
          have hpt := hptW ⟨j.val - 1, by omega⟩
          have hu := (efPointTPFin_eval N atomMap nameOf hName
            (ψ.pointType ⟨(j.val - 1) + 1, by omega⟩) (w ⟨j.val - 1, by omega⟩)).mp hpt
          have he : (⟨(j.val - 1) + 1, by omega⟩ : Fin (ψ.n + 1)) = j := by
            apply Fin.ext; simp only; omega
          rw [he] at hu; exact hu
    · -- before-cap
      intro y _hy
      exact hep.capTrivialLeft y
    · -- between
      intro i y hy0 hy1
      have hcs : i.castSucc.val = i.val := Fin.val_castSucc i
      have hsc : i.succ.val = i.val + 1 := Fin.val_succ i
      suffices hu : intervalHoldsFin N (ψ.intervalType ⟨i.val + 1, by omega⟩) y by
        have he : (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 2)) = i.succ.castSucc := by
          apply Fin.ext; simp only [Fin.val_castSucc, Fin.val_succ]
        rwa [he] at hu
      by_cases hi0 : i.val = 0
      · -- interval (env 0, w ⟨0⟩)
        rw [show x i.castSucc = env 0 from by
          rw [show i.castSucc = 0 from by apply Fin.ext; rw [hcs]; exact hi0]; exact hx0] at hy0
        rw [show x i.succ = w ⟨0, by omega⟩ from by
          rw [hxmid i.succ (by rw [hsc]; omega) (by rw [hsc]; omega),
            hw'val (i.succ.val - 1) (by rw [hsc]; omega)]
          congr 1; apply Fin.ext; simp only [hsc]; omega] at hy1
        have hseg := hseg0W y hy0 hy1
        have hu := (efIntervalSetTPFin_eval N atomMap nameOf hName
            (ψ.intervalType ⟨0 + 1, by omega⟩) y).mp hseg
        have he : (ψ.intervalType (⟨0 + 1, by omega⟩ : Fin (ψ.n + 2))) =
            ψ.intervalType ⟨i.val + 1, by omega⟩ := by congr 1; apply Fin.ext; simp only; omega
        rwa [he] at hu
      · by_cases hik : i.val = ψ.n - 1
        · -- interval (w ⟨k⟩, env 1)
          rw [show x i.castSucc = w ⟨k, by omega⟩ from by
            rw [hxmid i.castSucc (by rw [hcs]; omega) (by rw [hcs]; omega),
              hw'val (i.castSucc.val - 1) (by rw [hcs]; omega)]
            congr 1; apply Fin.ext; simp only [hcs]; omega] at hy0
          rw [show x i.succ = env 1 from by
            rw [show i.succ = Fin.last ψ.n from by apply Fin.ext; rw [Fin.val_last, hsc]; omega]
            exact hxlast] at hy1
          have hseg := hseglastW y hy0 hy1
          have hu := (efIntervalSetTPFin_eval N atomMap nameOf hName
            (ψ.intervalType ⟨(k + 1) + 1, by omega⟩) y).mp hseg
          have he : (ψ.intervalType (⟨(k + 1) + 1, by omega⟩ : Fin (ψ.n + 2))) =
              ψ.intervalType ⟨i.val + 1, by omega⟩ := by congr 1; apply Fin.ext; simp only; omega
          rwa [he] at hu
        · -- interior interval (w ⟨i.val-1⟩, w ⟨(i.val-1)+1⟩)
          rw [hxmid i.castSucc (by rw [hcs]; omega) (by rw [hcs]; omega),
            hw'val (i.castSucc.val - 1) (by rw [hcs]; omega)] at hy0
          rw [show x i.succ = w ⟨(i.val - 1) + 1, by omega⟩ from by
            rw [hxmid i.succ (by rw [hsc]; omega) (by rw [hsc]; omega),
              hw'val (i.succ.val - 1) (by rw [hsc]; omega)]
            congr 1; apply Fin.ext; simp only [hsc]; omega] at hy1
          have hseg := hsegmidW ⟨i.val - 1, by omega⟩ y hy0 hy1
          have hu := (efIntervalSetTPFin_eval N atomMap nameOf hName
            (ψ.intervalType ⟨((i.val - 1) + 1) + 1, by omega⟩) y).mp hseg
          have he : (ψ.intervalType (⟨((i.val - 1) + 1) + 1, by omega⟩ : Fin (ψ.n + 2))) =
              ψ.intervalType ⟨i.val + 1, by omega⟩ := by congr 1; apply Fin.ext; simp only; omega
          rwa [he] at hu
    · -- after-cap
      intro y _hy
      exact hep.capTrivialRight y

/-- Fin-variant of `translateProp42_correct` (Rabinovich 2014, PDF p.6). An endpoint-pinned
two-free-variable per-formula `∃∀`-formula with trivial caps is satisfied at `(env 0, env 1)`
iff its `VecEA2` canonical form holds there. -/
theorem translateProp42Fin_correct {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2)
    (hep : EndpointPinnedCapTrivialFin N ψ) (henv : env 0 < env 1) :
    efSatFin N env ψ ↔ (translateProp42Fin atomMap nameOf ψ).holds N atomMap (env 0) (env 1) :=
  ⟨translateProp42Fin_forward N atomMap nameOf hName env ψ hep,
   translateProp42Fin_backward N atomMap nameOf hName env ψ hep henv⟩

/-! ## 7. Fin layer: lift through the per-formula Vee (Def 3.3, p.4) -/

/-- Fin-variant of `translateVeeProp42`: map `translateProp42Fin` over the disjuncts of a
per-formula `∨∃∀`-formula (every disjunct endpoint-pinned) into a `VVecEA2`. -/
noncomputable def translateVeeProp42Fin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (Ψ : VeeExistsForallFin sig F 2) : VVecEA2 :=
  ⟨Ψ.map (fun ψ => ⟨ψ.n - 1, translateProp42Fin atomMap nameOf ψ⟩)⟩

/-- Fin-variant of `translateVeeProp42_correct`. A per-formula `∨∃∀`-formula (every disjunct
endpoint-pinned, `env 0 < env 1`) is satisfied (`veeSatFin`) iff its `VVecEA2` translation
holds. -/
theorem translateVeeProp42Fin_correct {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (Ψ : VeeExistsForallFin sig F 2)
    (hep : ∀ ψ ∈ Ψ, EndpointPinnedCapTrivialFin N ψ) (hlt : env 0 < env 1) :
    veeSatFin N env Ψ ↔ (translateVeeProp42Fin atomMap nameOf Ψ).holds N atomMap (env 0)
        (env 1) := by
  unfold translateVeeProp42Fin veeSatFin VVecEA2.holds
  constructor
  · rintro ⟨ψ, hmem, hsat⟩
    exact ⟨⟨ψ.n - 1, translateProp42Fin atomMap nameOf ψ⟩, List.mem_map_of_mem hmem,
      (translateProp42Fin_correct N atomMap nameOf hName env ψ (hep ψ hmem) hlt).mp hsat⟩
  · rintro ⟨vea, hmem, hholds⟩
    obtain ⟨ψ, hψmem, heq⟩ := List.mem_map.mp hmem
    refine ⟨ψ, hψmem, (translateProp42Fin_correct N atomMap nameOf hName env ψ (hep ψ hψmem)
        hlt).mpr ?_⟩
    rw [← heq] at hholds
    exact hholds

/-! ## 8. Fin layer: the Prop 4.2 negation-closure corollary -/

/-- Fin-variant of `prop42_veeSat_negation` (Rabinovich 2014, PDF p.6, endpoint-pinned +
attained). The negation of a per-formula `∨∃∀`-formula (every disjunct endpoint-pinned with
trivial caps) is captured by a single `VVecEA2` witness `v'`, depending on `Ψ` alone and
uniform in the points: wires `translateVeeProp42Fin_correct` to the already-landed Section 5
negation engine (`VVecEA2.negFix_iff`, `Section5Correspondence.lean`), which is
`TemporalPred`-level and consumes no alphabet finiteness. -/
theorem prop42_veeSatFin_negation {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (Ψ : VeeExistsForallFin sig F 2) (hep : ∀ ψ ∈ Ψ, EndpointPinnedCapTrivialFin N ψ) :
    ∃ v' : VVecEA2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (v'.holds N atomMap (env 0) (env 1) ↔ ¬ veeSatFin N env Ψ) := by
  refine ⟨(translateVeeProp42Fin atomMap nameOf Ψ).negFix, fun env hlt => ?_⟩
  rw [VVecEA2.negFix_iff N atomMap h_INF h_SUP _ (env 0) (env 1) hlt,
      translateVeeProp42Fin_correct N atomMap nameOf hName env Ψ hep hlt]


end FormalSystem.Metalogic.WeakCanonical.Kamp
