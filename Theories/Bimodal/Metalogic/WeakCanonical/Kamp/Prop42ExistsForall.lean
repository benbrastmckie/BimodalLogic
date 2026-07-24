import Bimodal.Metalogic.WeakCanonical.Kamp.Prop35Assembly
import Bimodal.Metalogic.WeakCanonical.Kamp.Section5Correspondence

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
- `translateVeeProp42` / `translateVeeProp42_correct`: the lift through `VeeExistsForall` → `VVecEA2`.
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

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

/-! ## 1. The endpoint-pinned canonical translation -/

/-- The Prop 4.2 translation of an endpoint-pinned two-free-variable `∃∀`-formula into the legacy
`VecEA2` canonical form. The two endpoints `x₀`, `x_{ψ.n}` become `endpointLeft`/`endpointRight`;
the `ψ.n − 1` interior points become the bracket witnesses; the bounded interval types
`intervalType 1 … intervalType ψ.n` become the bracket's `ψ.n` segment types. The two unbounded
caps (`intervalType 0`, `intervalType (ψ.n+1)`) are dropped — see the module docstring. -/
noncomputable def translateProp42 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 2) : VecEA2 (ψ.n - 1) :=
  { endpointLeft := efPointTP atomMap h_surj (ψ.pointType 0)
    endpointRight := efPointTP atomMap h_surj (ψ.pointType (Fin.last ψ.n))
    bracket :=
      { pointTypes := fun i => efPointTP atomMap h_surj (ψ.pointType ⟨i.val + 1, by omega⟩)
        segmentTypes := fun j => efIntervalSetTP atomMap h_surj (ψ.intervalSet ⟨j.val + 1, by omega⟩) } }

/-- Structural + semantic hypotheses under which `efSat` collapses to the endpoint-pinned
`VecEA2` canonical form of Prop 4.2: the two free variables are pinned to the chain endpoints,
the chain has at least one interval (`1 ≤ ψ.n`, so the two endpoints are distinct), and the two
unbounded caps are realized at every point (Rabinovich's vacuous caps, stated semantically). -/
structure EndpointPinnedCapTrivial {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (ψ : ExistsForallFormula sig F 2) : Prop where
  /-- At least one interval: the two endpoints `x₀`, `x_{ψ.n}` are distinct. -/
  posN : 1 ≤ ψ.n
  /-- Left free variable pinned to the first point `x₀`. -/
  pinLeft : ψ.pin 0 = 0
  /-- Right free variable pinned to the last point `x_{ψ.n}`. -/
  pinRight : ψ.pin 1 = Fin.last ψ.n
  /-- The before-cap type `β₀` is realized at every point (Rabinovich's vacuous cap). -/
  capTrivialLeft : ∀ y : N.carrier, intervalHolds N (ψ.intervalSet 0) y
  /-- The after-cap type `β_{n+1}` is realized at every point (Rabinovich's vacuous cap). -/
  capTrivialRight : ∀ y : N.carrier, intervalHolds N (ψ.intervalSet (Fin.last (ψ.n + 1))) y

/-! ## 2. Correctness of the translation -/

/-- Forward direction of `translateProp42_correct`: a satisfied endpoint-pinned `∃∀`-formula
yields its `VecEA2` canonical form. Needs only the pinning/positivity data — the caps are
dropped, so `capTrivialLeft`/`capTrivialRight` are unused here. -/
theorem translateProp42_forward {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
    (hep : EndpointPinnedCapTrivial N ψ)
    (h : efSat N env ψ) :
    (translateProp42 atomMap h_surj ψ).holds N atomMap (env 0) (env 1) := by
  rw [efSat_interval_iff] at h
  obtain ⟨x, hmono, hpin, hpt, _hbefore, hbetween, _hafter⟩ := h
  have hpos1 : 1 ≤ ψ.n := hep.posN
  have henv0 : env 0 = x 0 := by rw [hpin 0, hep.pinLeft]
  have henv1 : env 1 = x (Fin.last ψ.n) := by rw [hpin 1, hep.pinRight]
  refine ⟨?_, ?_, ?_⟩
  · -- endpointLeft at env 0 = x 0
    rw [henv0]
    exact (efPointTP_eval N atomMap h_surj (ψ.pointType 0) (x 0)).mpr (hpt 0)
  · -- endpointRight at env 1 = x (Fin.last ψ.n)
    rw [henv1]
    exact (efPointTP_eval N atomMap h_surj (ψ.pointType (Fin.last ψ.n)) (x (Fin.last ψ.n))).mpr
      (hpt (Fin.last ψ.n))
  · -- bracket on (env 0, env 1)
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
    rcases Nat.eq_zero_or_pos (ψ.n - 1) with hz | hpos
    · -- no interior witnesses
      rw [IntervalPattern.holds_eq_zero (h := hz)]
      intro y hy0 hy1
      -- segmentTypes ⟨0⟩ = efIntervalTP (intervalType ⟨1⟩); use hbetween at i = 0
      show TemporalPred.eval_at N atomMap
        (efIntervalSetTP atomMap h_surj (ψ.intervalSet ⟨0 + 1, by omega⟩)) y
      rw [efIntervalSetTP_eval]
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
        show TemporalPred.eval_at N atomMap
          (efPointTP atomMap h_surj (ψ.pointType ⟨i.val + 1, by omega⟩)) (x ⟨i.val + 1, by omega⟩)
        rw [efPointTP_eval]; exact hpt ⟨i.val + 1, by omega⟩
      · intro y hy0 hy1
        show TemporalPred.eval_at N atomMap
          (efIntervalSetTP atomMap h_surj (ψ.intervalSet ⟨0 + 1, by omega⟩)) y
        rw [efIntervalSetTP_eval]
        have hi : (⟨0, by omega⟩ : Fin ψ.n).succ.castSucc = (⟨0 + 1, by omega⟩ : Fin (ψ.n + 2)) := by
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
        show TemporalPred.eval_at N atomMap
          (efIntervalSetTP atomMap h_surj (ψ.intervalSet ⟨i.val + 1 + 1, by omega⟩)) y
        rw [efIntervalSetTP_eval]
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
        show TemporalPred.eval_at N atomMap
          (efIntervalSetTP atomMap h_surj (ψ.intervalSet ⟨k + 1 + 1, by omega⟩)) y
        rw [efIntervalSetTP_eval]
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

/-- Backward direction of `translateProp42_correct`: the `VecEA2` canonical form, together with
the endpoint-pinning data and the two trivial caps, reconstructs a satisfied `∃∀`-formula. The
caps are supplied by `capTrivialLeft`/`capTrivialRight`; the interior chain is glued from the two
endpoints (`env 0`, `env 1`) and the bracket witnesses. -/
theorem translateProp42_backward {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
    (hep : EndpointPinnedCapTrivial N ψ) (henv : env 0 < env 1)
    (hV : (translateProp42 atomMap h_surj ψ).holds N atomMap (env 0) (env 1)) :
    efSat N env ψ := by
  have hpos1 : 1 ≤ ψ.n := hep.posN
  simp only [translateProp42, VecEA2.holds, BracketFormula.holds,
    BracketFormula.toIntervalPattern] at hV
  obtain ⟨hLraw, hRraw, hbr⟩ := hV
  have hL : unaryHolds N (ψ.pointType 0) (env 0) :=
    (efPointTP_eval N atomMap h_surj (ψ.pointType 0) (env 0)).mp hLraw
  have hR : unaryHolds N (ψ.pointType (Fin.last ψ.n)) (env 1) :=
    (efPointTP_eval N atomMap h_surj (ψ.pointType (Fin.last ψ.n)) (env 1)).mp hRraw
  rcases Nat.eq_zero_or_pos (ψ.n - 1) with hz | hpos
  · -- ψ.n = 1: two points, no interior witnesses
    rw [IntervalPattern.holds_eq_zero (h := hz)] at hbr
    -- hbr : ∀ y, env 0 < y → y < env 1 → segmentTypes ⟨0⟩ eval y
    have hn1 : ψ.n = 1 := by omega
    rw [efSat_interval_iff]
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
      · simp only [hj, if_neg hj]
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
      show intervalHolds N (ψ.intervalSet i.succ.castSucc) y
      have hidx : i.succ.castSucc = (⟨0 + 1, by omega⟩ : Fin (ψ.n + 2)) := by
        apply Fin.ext; simp only [Fin.coe_castSucc, Fin.val_succ]; omega
      rw [hidx, ← efIntervalSetTP_eval N atomMap h_surj]
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
      show (if (Fin.last ψ.n).val = 0 then env 0
          else if (Fin.last ψ.n).val = ψ.n then env 1 else w' ((Fin.last ψ.n).val - 1)) = env 1
      rw [Fin.val_last, if_neg (by omega), if_pos rfl]
    have hxmid : ∀ j : Fin (ψ.n + 1), 0 < j.val → j.val < ψ.n → x j = w' (j.val - 1) := by
      intro j hj0 hjn
      simp only [hx_def]
      rw [if_neg (by omega), if_neg (by omega)]
    rw [efSat_interval_iff]
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
          have hu := (efPointTP_eval N atomMap h_surj
            (ψ.pointType ⟨(j.val - 1) + 1, by omega⟩) (w ⟨j.val - 1, by omega⟩)).mp hpt
          have he : (⟨(j.val - 1) + 1, by omega⟩ : Fin (ψ.n + 1)) = j := by
            apply Fin.ext; simp only; omega
          rw [he] at hu; exact hu
    · -- before-cap
      intro y _hy
      exact hep.capTrivialLeft y
    · -- between
      intro i y hy0 hy1
      have hcs : i.castSucc.val = i.val := Fin.coe_castSucc i
      have hsc : i.succ.val = i.val + 1 := Fin.val_succ i
      suffices hu : intervalHolds N (ψ.intervalSet ⟨i.val + 1, by omega⟩) y by
        have he : (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 2)) = i.succ.castSucc := by
          apply Fin.ext; simp only [Fin.coe_castSucc, Fin.val_succ]
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
        have hu := (efIntervalSetTP_eval N atomMap h_surj (ψ.intervalSet ⟨0 + 1, by omega⟩) y).mp hseg
        have he : (ψ.intervalSet (⟨0 + 1, by omega⟩ : Fin (ψ.n + 2))) =
            ψ.intervalSet ⟨i.val + 1, by omega⟩ := by congr 1; apply Fin.ext; simp only; omega
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
          have hu := (efIntervalSetTP_eval N atomMap h_surj
            (ψ.intervalSet ⟨(k + 1) + 1, by omega⟩) y).mp hseg
          have he : (ψ.intervalSet (⟨(k + 1) + 1, by omega⟩ : Fin (ψ.n + 2))) =
              ψ.intervalSet ⟨i.val + 1, by omega⟩ := by congr 1; apply Fin.ext; simp only; omega
          rwa [he] at hu
        · -- interior interval (w ⟨i.val-1⟩, w ⟨(i.val-1)+1⟩)
          rw [hxmid i.castSucc (by rw [hcs]; omega) (by rw [hcs]; omega),
            hw'val (i.castSucc.val - 1) (by rw [hcs]; omega)] at hy0
          rw [show x i.succ = w ⟨(i.val - 1) + 1, by omega⟩ from by
            rw [hxmid i.succ (by rw [hsc]; omega) (by rw [hsc]; omega),
              hw'val (i.succ.val - 1) (by rw [hsc]; omega)]
            congr 1; apply Fin.ext; simp only [hsc]; omega] at hy1
          have hseg := hsegmidW ⟨i.val - 1, by omega⟩ y hy0 hy1
          have hu := (efIntervalSetTP_eval N atomMap h_surj
            (ψ.intervalSet ⟨((i.val - 1) + 1) + 1, by omega⟩) y).mp hseg
          have he : (ψ.intervalSet (⟨((i.val - 1) + 1) + 1, by omega⟩ : Fin (ψ.n + 2))) =
              ψ.intervalSet ⟨i.val + 1, by omega⟩ := by congr 1; apply Fin.ext; simp only; omega
          rwa [he] at hu
    · -- after-cap
      intro y _hy
      exact hep.capTrivialRight y

/-- **Proposition 4.2 translation, correctness** (Rabinovich 2014, PDF p.6). An endpoint-pinned
two-free-variable `∃∀`-formula with trivial caps is satisfied at `(env 0, env 1)` iff its `VecEA2`
canonical form holds there. -/
theorem translateProp42_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
    (hep : EndpointPinnedCapTrivial N ψ) (henv : env 0 < env 1) :
    efSat N env ψ ↔ (translateProp42 atomMap h_surj ψ).holds N atomMap (env 0) (env 1) :=
  ⟨translateProp42_forward N atomMap h_surj env ψ hep,
   translateProp42_backward N atomMap h_surj env ψ hep henv⟩

/-! ## 3. Lift through VeeExistsForall (Def 3.3, p.4) -/

/-- The Prop 4.2 translation of a `∨∃∀`-formula (every disjunct endpoint-pinned): map
`translateProp42` over the disjuncts into a `VVecEA2`. -/
noncomputable def translateVeeProp42 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (Ψ : VeeExistsForall sig F 2) : VVecEA2 :=
  ⟨Ψ.map (fun ψ => ⟨ψ.n - 1, translateProp42 atomMap h_surj ψ⟩)⟩

/-- **Proposition 4.2 translation correctness, `∨∃∀` lift.** A `∨∃∀`-formula (every disjunct
endpoint-pinned, `env 0 < env 1`) is satisfied iff its `VVecEA2` translation holds. -/
theorem translateVeeProp42_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (Ψ : VeeExistsForall sig F 2)
    (hep : ∀ ψ ∈ Ψ, EndpointPinnedCapTrivial N ψ) (hlt : env 0 < env 1) :
    veeSat N env Ψ ↔ (translateVeeProp42 atomMap h_surj Ψ).holds N atomMap (env 0) (env 1) := by
  unfold translateVeeProp42 veeSat VVecEA2.holds
  constructor
  · rintro ⟨ψ, hmem, hsat⟩
    exact ⟨⟨ψ.n - 1, translateProp42 atomMap h_surj ψ⟩, List.mem_map_of_mem hmem,
      (translateProp42_correct N atomMap h_surj env ψ (hep ψ hmem) hlt).mp hsat⟩
  · rintro ⟨vea, hmem, hholds⟩
    obtain ⟨ψ, hψmem, heq⟩ := List.mem_map.mp hmem
    refine ⟨ψ, hψmem, (translateProp42_correct N atomMap h_surj env ψ (hep ψ hψmem) hlt).mpr ?_⟩
    rw [← heq] at hholds
    exact hholds

/-! ## 4. The Prop 4.2 negation-closure corollary -/

/-- **Proposition 4.2 (Rabinovich 2014, PDF p.6), on the Phase-3 object, endpoint-pinned +
attained.** The negation of a `∨∃∀`-formula (every disjunct endpoint-pinned with trivial caps)
is captured by a single `VVecEA2` witness `v'`, depending on `Ψ` alone and uniform in the points:
this wires `translateVeeProp42_correct` (the Phase-3 ↔ `VVecEA2` bridge) to the already-landed
Section 5 negation engine (`VVecEA2.negFix_iff`, `Section5Correspondence.lean`). The witness `v'`
is itself `VVecEA2`-valued (not re-expressed back as a Phase-3 object) — Prop 4.3's structural
induction (Phase 7) composes this at the `VVecEA2` level for the endpoint-pinned fragment; see
this module's docstring for the scope this covers. -/
theorem prop42_veeSat_negation {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (Ψ : VeeExistsForall sig F 2) (hep : ∀ ψ ∈ Ψ, EndpointPinnedCapTrivial N ψ) :
    ∃ v' : VVecEA2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (v'.holds N atomMap (env 0) (env 1) ↔ ¬ veeSat N env Ψ) := by
  refine ⟨(translateVeeProp42 atomMap h_surj Ψ).negFix, fun env hlt => ?_⟩
  rw [VVecEA2.negFix_iff N atomMap h_INF h_SUP _ (env 0) (env 1) hlt,
      translateVeeProp42_correct N atomMap h_surj env Ψ hep hlt]


end Bimodal.Metalogic.WeakCanonical.Kamp
