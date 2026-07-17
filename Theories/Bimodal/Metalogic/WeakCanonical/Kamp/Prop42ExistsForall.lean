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
noncomputable def translateProp42 {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ψ : ExistsForallFormula sig F 2) : VecEA2 (ψ.n - 1) :=
  { endpointLeft := efPointTP atomMap h_surj (ψ.pointType 0)
    endpointRight := efPointTP atomMap h_surj (ψ.pointType (Fin.last ψ.n))
    bracket :=
      { pointTypes := fun i => efPointTP atomMap h_surj (ψ.pointType ⟨i.val + 1, by omega⟩)
        segmentTypes := fun j => efIntervalTP atomMap h_surj (ψ.intervalType ⟨j.val + 1, by omega⟩) } }

/-- Structural + semantic hypotheses under which `efSat` collapses to the endpoint-pinned
`VecEA2` canonical form of Prop 4.2: the two free variables are pinned to the chain endpoints,
the chain has at least one interval (`1 ≤ ψ.n`, so the two endpoints are distinct), and the two
unbounded caps are realized at every point (Rabinovich's vacuous caps, stated semantically). -/
structure EndpointPinnedCapTrivial {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F)) (ψ : ExistsForallFormula sig F 2) : Prop where
  /-- At least one interval: the two endpoints `x₀`, `x_{ψ.n}` are distinct. -/
  posN : 1 ≤ ψ.n
  /-- Left free variable pinned to the first point `x₀`. -/
  pinLeft : ψ.pin 0 = 0
  /-- Right free variable pinned to the last point `x_{ψ.n}`. -/
  pinRight : ψ.pin 1 = Fin.last ψ.n
  /-- The before-cap type `β₀` is realized at every point (Rabinovich's vacuous cap). -/
  capTrivialLeft : ∀ y : N.carrier, unaryHolds N (ψ.intervalType 0) y
  /-- The after-cap type `β_{n+1}` is realized at every point (Rabinovich's vacuous cap). -/
  capTrivialRight : ∀ y : N.carrier, unaryHolds N (ψ.intervalType (Fin.last (ψ.n + 1))) y

/-! ## 2. Correctness of the translation -/

/-- Forward direction of `translateProp42_correct`: a satisfied endpoint-pinned `∃∀`-formula
yields its `VecEA2` canonical form. Needs only the pinning/positivity data — the caps are
dropped, so `capTrivialLeft`/`capTrivialRight` are unused here. -/
theorem translateProp42_forward {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
    (hep : EndpointPinnedCapTrivial N ψ)
    (h : efSat N env ψ) :
    (translateProp42 atomMap h_surj ψ).holds N atomMap (env 0) (env 1) := by
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
        (efIntervalTP atomMap h_surj (ψ.intervalType ⟨0 + 1, by omega⟩)) y
      rw [efIntervalTP_eval]
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
          (efIntervalTP atomMap h_surj (ψ.intervalType ⟨0 + 1, by omega⟩)) y
        rw [efIntervalTP_eval]
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
          (efIntervalTP atomMap h_surj (ψ.intervalType ⟨i.val + 1 + 1, by omega⟩)) y
        rw [efIntervalTP_eval]
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
          (efIntervalTP atomMap h_surj (ψ.intervalType ⟨k + 1 + 1, by omega⟩)) y
        rw [efIntervalTP_eval]
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

end Bimodal.Metalogic.WeakCanonical.Kamp
