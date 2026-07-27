/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop42ExistsForall
import FormalSystem.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas
import FormalSystem.Metalogic.WeakCanonical.Kamp.IntervalType
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import FormalSystem.Metalogic.WeakCanonical.Kamp.Translation
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.VecEANegFix

/-!
# Proposition 4.2 on an ARBITRARY-pin two-free-variable `∃∀`-object (Rabinovich 2014, PDF p.7)

`Prop42ExistsForall.lean` negates only the endpoint-pinned, trivial-cap canonical form
(`EndpointPinnedCapTrivial`). Rabinovich's Proposition 4.2 proof (Section 5, PDF p.7) negates a
*general* two-free-variable `∃∀`-object — arbitrary pins `z₀ = x_m`, `z₁ = x_k`, contentful caps
`β₀`, `β_{n+1}` — by **splitting its single ordered chain at the two pinned points into three
consecutive pieces** and negating each independently, reassembling by **disjunction**:

```
ψ(z₀,z₁)  ≡  ψ₀(z₀)  ∧  φ(z₀,z₁)  ∧  ψ₁(z₁)          (PDF p.7, m < k case)
¬ψ        ≡  ¬ψ₀     ∨  ¬φ         ∨  ¬ψ₁
```

* `ψ₀(z₀)` — the below piece `x₀ < … < x_m` with the before-cap `β₀`; a **one-free-variable**
  `∃∀` (free var pinned to the RIGHT endpoint `x_m`). Negated via Prop 3.5 (`translateProp35`):
  it is equivalent to a `TL(Until,Since)` formula, whose negation is realized directly as a
  single endpoint `TemporalPred` (this module's `negLeftClause`).
* `ψ₁(z₁)` — the above piece `x_k < … < x_n` with the after-cap `β_{n+1}`; a one-free-variable
  `∃∀` (free var pinned to the LEFT endpoint `x_k`). Symmetric (`negRightClause`).
* `φ(z₀,z₁)` — the middle chain `x_m < … < x_k` with **no caps**; an **endpoint-pinned**
  two-free-variable `∃∀` (both pins at its own endpoints) realized as a bounded, cap-free
  `BracketFormula`/`VecEA2` (`middleBracket`). Its negation is realized directly by the Lemma 5.1
  engine `VVecEA2.negFix_iff` (INF/`K⁺` machinery, gated on Dedekind completeness), NOT via
  `efSat`/`EndpointPinnedCapTrivial`. This is the TL-level repair path: standalone `efSat` objects
  mandatorily carry two universal exterior caps that have no home in a general `N`, so the pieces
  are built at the TL-formula + bounded-`VecEA2` level, the encoding vehicle that faithfully
  expresses Rabinovich's cap-free / one-sided pieces.

The `¬ψ₀`, `¬ψ₁` end pieces are `TL`-formula negations lifted to `TemporalPred` endpoint clauses;
the middle `¬φ` is the `VVecEA2.negFix_iff` negation. The three combine by `VVecEA2.disj`. There is
no conjunction closure and no order-preserving interleaving anywhere on this path — the split is of
a
single chain at two *known* points (fixed order `below < x_m < middle < x_k < above`), the same
"glue along shared pins" technique as `ExistsForallLemmas.gluedChain`.

Off the live import path (imported by nothing live) until it is wired into the Prop 4.3 negation
case, mirroring how `Prop42ExistsForall.lean` and `Prop43.lean` already sit off-path.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.2 statement (p.6), proof and the
  three-way chain split + Lemma 5.1 (p.7). Cited by PDF page; the companion markdown
  transcription is corrupt.
- `Prop42ExistsForall.lean`: `EndpointPinnedCapTrivial`, `prop42_veeSat_negation` (middle piece).
- `Prop35Assembly.lean`: `translateProp35`, `translateProp35_correct` (end pieces).
- `ExistsForallLemmas.lean`: `gluedChain` family (backward gluing template).
- `VecEAFormula.lean`: `VVecEA2`, `VecEA2`, `BracketFormula.trivial`, `VVecEA2.disj`.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula Atom)
open FormalSystem.Metalogic.WeakCanonical

/-! ## 6. Fin layer: clause constructors on the per-formula representation

Fin counterparts of sections 1, 2, and 5's clause constructors on
`ExistsForallFormulaFin`/`efSatFin` (`PerFormulaExistsForall.lean`): renders switch to
`translateProp35Fin`/`efPointTPFin`/`efIntervalSetTPFin` (`Prop35Assembly.lean` Fin section),
interval slots read the bundled partial types `ψ.intervalType`. The `VVecEA2`/`VecEA2`/
`BracketFormula`/`TemporalPred` target layer is representation-independent and reused verbatim.
NO alphabet instances. The section-3/4 decompose mirrors and the final assembly
(`prop42_efSat_negation_generalFin`) are the remaining Fin obligations of this module. -/

section FinLayer

/-- Fin-variant of `negLeftClause`: the `VVecEA2` clause witnessing `¬ efSatFin N ![z₀] ψ`,
placing the negated Prop 3.5 Fin formula at the **left** endpoint. -/
noncomputable def negLeftClauseFin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 1) : VVecEA2 :=
  { disjuncts :=
      [⟨0, { endpointLeft := ⟨Formula.neg (translateProp35Fin atomMap nameOf ψ)⟩
             endpointRight := TemporalPred.top
             bracket := BracketFormula.trivial TemporalPred.top }⟩] }

/-- Fin-variant of `negLeftClause_holds`. -/
theorem negLeftClauseFin_holds {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (ψ : ExistsForallFormulaFin sig F 1) (z0 z1 : N.carrier) :
    (negLeftClauseFin atomMap nameOf ψ).holds N atomMap z0 z1 ↔ ¬ efSatFin N ![z0] ψ := by
  simp only [negLeftClauseFin, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.holds]
  have hcorr := translateProp35Fin_correct N atomMap nameOf hName ![z0] ψ
  simp only [Matrix.cons_val_zero] at hcorr
  constructor
  · rintro ⟨hL, _, _⟩
    rw [TemporalPred.EvalAt, temporal_truth_neg] at hL
    exact fun hsat => hL (hcorr.mp hsat)
  · intro hneg
    refine ⟨?_, TemporalPred.eval_at_top N atomMap z1, ?_⟩
    · rw [TemporalPred.EvalAt, temporal_truth_neg]
      exact fun htt => hneg (hcorr.mpr htt)
    · rw [BracketFormula.trivial_holds]
      exact fun y _ _ => TemporalPred.eval_at_top N atomMap y

/-- Fin-variant of `negRightClause`: the negated Prop 3.5 Fin formula at the **right**
endpoint. -/
noncomputable def negRightClauseFin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 1) : VVecEA2 :=
  { disjuncts :=
      [⟨0, { endpointLeft := TemporalPred.top
             endpointRight := ⟨Formula.neg (translateProp35Fin atomMap nameOf ψ)⟩
             bracket := BracketFormula.trivial TemporalPred.top }⟩] }

/-- Fin-variant of `negRightClause_holds`. -/
theorem negRightClauseFin_holds {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (ψ : ExistsForallFormulaFin sig F 1) (z0 z1 : N.carrier) :
    (negRightClauseFin atomMap nameOf ψ).holds N atomMap z0 z1 ↔ ¬ efSatFin N ![z1] ψ := by
  simp only [negRightClauseFin, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.holds]
  have hcorr := translateProp35Fin_correct N atomMap nameOf hName ![z1] ψ
  simp only [Matrix.cons_val_zero] at hcorr
  constructor
  · rintro ⟨_, hR, _⟩
    rw [TemporalPred.EvalAt, temporal_truth_neg] at hR
    exact fun hsat => hR (hcorr.mp hsat)
  · intro hneg
    refine ⟨TemporalPred.eval_at_top N atomMap z0, ?_, ?_⟩
    · rw [TemporalPred.EvalAt, temporal_truth_neg]
      exact fun htt => hneg (hcorr.mpr htt)
    · rw [BracketFormula.trivial_holds]
      exact fun y _ _ => TemporalPred.eval_at_top N atomMap y

/-- Fin-variant of `belowFormula` (Rabinovich formula (1), PDF p.7): the below one-sided
`TL(Since)` piece with the free variable at the RIGHT endpoint `x_m = z₀`, before-cap only,
rendered through `efPointTPFin`/`efIntervalSetTPFin` on the bundled partial types. -/
noncomputable def belowFormulaFin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 2) : Formula :=
  Formula.and
    (efPointTPFin atomMap nameOf (ψ.pointType (ψ.pin 0))).formula
    (buildLeft
      ((List.finRange (ψ.pin 0).val).map (fun i =>
        (efPointTPFin atomMap nameOf (ψ.pointType ⟨(ψ.pin 0).val - 1 - i.val, by omega⟩),
         efIntervalSetTPFin atomMap nameOf
           (ψ.intervalType ⟨(ψ.pin 0).val - 1 - i.val + 1, by omega⟩))))
      (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨0, by omega⟩)))

/-- Fin-variant of `aboveFormula` (Rabinovich formula (2), PDF p.7): the above one-sided
`TL(Until)` piece with the free variable at the LEFT endpoint `x_k = z₁`, after-cap only. -/
noncomputable def aboveFormulaFin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 2) : Formula :=
  Formula.and
    (efPointTPFin atomMap nameOf (ψ.pointType (ψ.pin 1))).formula
    (buildRight
      ((List.finRange (ψ.n - (ψ.pin 1).val)).map (fun i =>
        (efPointTPFin atomMap nameOf (ψ.pointType ⟨(ψ.pin 1).val + 1 + i.val, by omega⟩),
         efIntervalSetTPFin atomMap nameOf
           (ψ.intervalType ⟨(ψ.pin 1).val + 1 + i.val, by omega⟩))))
      (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨ψ.n + 1, by omega⟩)))

/-- Fin-variant of `middleBracket` (Rabinovich formula (3), PDF p.7 = Lemma 5.1's object):
cap-free single-disjunct `VVecEA2` middle piece on the bundled partial types. -/
noncomputable def middleBracketFin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 2) : VVecEA2 :=
  { disjuncts :=
      [⟨(ψ.pin 1).val - (ψ.pin 0).val - 1,
        { endpointLeft := efPointTPFin atomMap nameOf (ψ.pointType (ψ.pin 0))
          endpointRight := efPointTPFin atomMap nameOf (ψ.pointType (ψ.pin 1))
          bracket :=
            { pointTypes := fun i =>
                efPointTPFin atomMap nameOf (ψ.pointType ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩)
              segmentTypes := fun i =>
                efIntervalSetTPFin atomMap nameOf
                  (ψ.intervalType ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩) } }⟩] }

/-- Fin-variant of `negLeftClauseTL`: the negated `belowFormulaFin` at the **left** endpoint. -/
noncomputable def negLeftClauseTLFin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 2) : VVecEA2 :=
  { disjuncts :=
      [⟨0, { endpointLeft := ⟨Formula.neg (belowFormulaFin atomMap nameOf ψ)⟩
             endpointRight := TemporalPred.top
             bracket := BracketFormula.trivial TemporalPred.top }⟩] }

/-- Fin-variant of `negLeftClauseTL_holds`. -/
theorem negLeftClauseTLFin_holds {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (_hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (ψ : ExistsForallFormulaFin sig F 2) (z0 z1 : N.carrier) :
    (negLeftClauseTLFin atomMap nameOf ψ).holds N atomMap z0 z1 ↔
      ¬ TemporalTruth N atomMap z0 (belowFormulaFin atomMap nameOf ψ) := by
  simp only [negLeftClauseTLFin, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.holds]
  constructor
  · rintro ⟨hL, _, _⟩
    rw [TemporalPred.EvalAt, temporal_truth_neg] at hL
    exact hL
  · intro hneg
    refine ⟨?_, TemporalPred.eval_at_top N atomMap z1, ?_⟩
    · rw [TemporalPred.EvalAt, temporal_truth_neg]; exact hneg
    · rw [BracketFormula.trivial_holds]
      exact fun y _ _ => TemporalPred.eval_at_top N atomMap y

/-- Fin-variant of `negRightClauseTL`: the negated `aboveFormulaFin` at the **right**
endpoint. -/
noncomputable def negRightClauseTLFin {sig : MonadicSignature} {F : Finset Formula}
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 2) : VVecEA2 :=
  { disjuncts :=
      [⟨0, { endpointLeft := TemporalPred.top
             endpointRight := ⟨Formula.neg (aboveFormulaFin atomMap nameOf ψ)⟩
             bracket := BracketFormula.trivial TemporalPred.top }⟩] }

/-- Fin-variant of `negRightClauseTL_holds`. -/
theorem negRightClauseTLFin_holds {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (_hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (ψ : ExistsForallFormulaFin sig F 2) (z0 z1 : N.carrier) :
    (negRightClauseTLFin atomMap nameOf ψ).holds N atomMap z0 z1 ↔
      ¬ TemporalTruth N atomMap z1 (aboveFormulaFin atomMap nameOf ψ) := by
  simp only [negRightClauseTLFin, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.holds]
  constructor
  · rintro ⟨_, hR, _⟩
    rw [TemporalPred.EvalAt, temporal_truth_neg] at hR
    exact hR
  · intro hneg
    refine ⟨TemporalPred.eval_at_top N atomMap z0, ?_, ?_⟩
    · rw [TemporalPred.EvalAt, temporal_truth_neg]; exact hneg
    · rw [BracketFormula.trivial_holds]
      exact fun y _ _ => TemporalPred.eval_at_top N atomMap y

/-- Fin-variant of `efSat_pin_lt`: under `z₀ < z₁` the pins of a satisfied per-formula object
are strictly ordered. -/
theorem efSatFin_pin_lt {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2)
    (h : efSatFin N env ψ) (henv : env 0 < env 1) :
    (ψ.pin 0).val < (ψ.pin 1).val := by
  obtain ⟨x, hmono, hpin, _⟩ := h
  rw [hpin 0, hpin 1] at henv
  exact hmono.lt_iff_lt.mp henv

/-! ### 6.3 Fin forward decomposition (mirror of section 3 on the partial relations)

Transcriptions of `belowFormula_of_efSat`/`aboveFormula_of_efSat`/`middleBracket_of_efSat`/
`efSat_decompose_tl_forward` onto `efSatFin`: renders read back through `efPointTPFin_eval`
(`partialHolds`) and `efIntervalSetTPFin_eval` (`intervalHoldsFin`), interval slots come from
the bundled `ψ.intervalType`. The chain manipulation is identical — `efSatFin_interval_iff`
exposes the same six-conjunct witness shape as `efSat_interval_iff`. -/

/-- Fin-variant of `belowFormula_of_efSat`: from `efSatFin`, the below `TL(Since)` formula holds
at `z₀ = env 0`. Independent of `ψ.pin 1`. -/
theorem belowFormulaFin_of_efSatFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2) (h : efSatFin N env ψ) :
    TemporalTruth N atomMap (env 0) (belowFormulaFin atomMap nameOf ψ) := by
  rw [efSatFin_interval_iff] at h
  obtain ⟨x, hmono, hpin, hpt, hbefore, hbetween, _hafter⟩ := h
  simp only [belowFormulaFin]
  set k : Fin (ψ.n + 1) := ψ.pin 0 with hk_def
  have hpin0 : env 0 = x k := hpin 0
  rw [temporal_truth_and]
  refine ⟨?_, ?_⟩
  · change (efPointTPFin atomMap nameOf (ψ.pointType k)).EvalAt N atomMap (env 0)
    rw [efPointTPFin_eval (hName := hName), hpin0]
    exact hpt k
  · rw [buildLeft_correct]
    set alphaL : Nat → TemporalPred :=
      fun m => efPointTPFin atomMap nameOf (ψ.pointType ⟨k.val - 1 - m, by omega⟩) with halphaL_def
    set betaL : Nat → TemporalPred :=
      fun m => efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨k.val - 1 - m + 1, by omega⟩)
      with hbetaL_def
    have hleft_eq :
        (List.finRange k.val).map (fun i =>
          (efPointTPFin atomMap nameOf (ψ.pointType ⟨k.val - 1 - i.val, by omega⟩),
           efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨k.val - 1 - i.val + 1, by omega⟩))) =
        (List.finRange k.val).map (fun i => (alphaL i.val, betaL i.val)) := by
      apply List.map_congr_left; intro i _; simp only [halphaL_def, hbetaL_def]
    rw [hleft_eq, buildLeft_spec_iff_chain]
    refine ⟨fun m => x ⟨k.val - m, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
    · change x ⟨k.val - 0, by omega⟩ = env 0
      simp only [Nat.sub_zero]; exact hpin0.symm
    · intro i j hij hjd
      change x ⟨k.val - j, by omega⟩ < x ⟨k.val - i, by omega⟩
      exact hmono (show (⟨k.val - j, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val - i, by omega⟩ by
        simp only [Fin.lt_def]; omega)
    · intro i hi
      change TemporalPred.EvalAt N atomMap (alphaL i) (x ⟨k.val - (i + 1), by omega⟩)
      simp only [halphaL_def]
      have e : k.val - (i + 1) = k.val - 1 - i := by omega
      simp only [e]; rw [efPointTPFin_eval (hName := hName)]; exact hpt ⟨k.val - 1 - i, by omega⟩
    · intro i hi y hy1 hy2
      show TemporalPred.EvalAt N atomMap (betaL i) y
      simp only [hbetaL_def]; rw [efIntervalSetTPFin_eval (hName := hName)]
      have e : k.val - (i + 1) = k.val - 1 - i := by omega
      have e' : k.val - 1 - i + 1 = k.val - i := by omega
      have hy1' : x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).castSucc < y := by
        change x ⟨k.val - 1 - i, by omega⟩ < y
        rw [show (⟨k.val - 1 - i, by omega⟩ : Fin (ψ.n + 1)) = ⟨k.val - (i + 1), by omega⟩ from by
          simp only [e]]
        exact hy1
      have hy2' : y < x (⟨k.val - 1 - i, by omega⟩ : Fin ψ.n).succ := by
        change y < x ⟨k.val - 1 - i + 1, by omega⟩
        rw [show (⟨k.val - 1 - i + 1, by omega⟩ : Fin (ψ.n + 1)) = ⟨k.val - i, by omega⟩ from by
          simp only [e']]
        exact hy2
      exact hbetween ⟨k.val - 1 - i, by omega⟩ y hy1' hy2'
    · intro y hy
      change TemporalPred.EvalAt N atomMap
        (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨0, by omega⟩)) y
      rw [efIntervalSetTPFin_eval (hName := hName)]
      have h0 : k.val - k.val = 0 := by omega
      have hy' : y < x (⟨0, by omega⟩ : Fin (ψ.n + 1)) := by
        rw [show (⟨0, by omega⟩ : Fin (ψ.n + 1)) = ⟨k.val - k.val, by omega⟩ from by
          simp only [h0]]
        exact hy
      exact hbefore y hy'

/-- Fin-variant of `aboveFormula_of_efSat`: from `efSatFin`, the above `TL(Until)` formula holds
at `z₁ = env 1`. Independent of `ψ.pin 0`. -/
theorem aboveFormulaFin_of_efSatFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2) (h : efSatFin N env ψ) :
    TemporalTruth N atomMap (env 1) (aboveFormulaFin atomMap nameOf ψ) := by
  rw [efSatFin_interval_iff] at h
  obtain ⟨x, hmono, hpin, hpt, _hbefore, hbetween, hafter⟩ := h
  simp only [aboveFormulaFin]
  set k : Fin (ψ.n + 1) := ψ.pin 1 with hk_def
  have hpin1 : env 1 = x k := hpin 1
  rw [temporal_truth_and]
  refine ⟨?_, ?_⟩
  · change (efPointTPFin atomMap nameOf (ψ.pointType k)).EvalAt N atomMap (env 1)
    rw [efPointTPFin_eval (hName := hName), hpin1]
    exact hpt k
  · rw [buildRight_correct]
    set alphaR : Nat → TemporalPred :=
      fun m => efPointTPFin atomMap nameOf (ψ.pointType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
      with halphaR_def
    set betaR : Nat → TemporalPred :=
      fun m => efIntervalSetTPFin atomMap nameOf
          (ψ.intervalType ⟨min (k.val + 1 + m) ψ.n, by omega⟩)
      with hbetaR_def
    have hright_eq :
        (List.finRange (ψ.n - k.val)).map (fun i =>
          (efPointTPFin atomMap nameOf (ψ.pointType ⟨k.val + 1 + i.val, by omega⟩),
           efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨k.val + 1 + i.val, by omega⟩))) =
        (List.finRange (ψ.n - k.val)).map (fun i => (alphaR i.val, betaR i.val)) := by
      apply List.map_congr_left; intro i _
      simp only [halphaR_def, hbetaR_def]
      have e : min (k.val + 1 + i.val) ψ.n = k.val + 1 + i.val := by omega
      simp only [e]
    rw [hright_eq, buildRight_spec_iff_chain]
    refine ⟨fun m => x ⟨min (k.val + m) ψ.n, by omega⟩, ?_, ?_, ?_, ?_, ?_⟩
    · change x ⟨min (k.val + 0) ψ.n, by omega⟩ = env 1
      have e0 : min (k.val + 0) ψ.n = k.val := by omega
      simp only [e0]; exact hpin1.symm
    · intro i j hij hjd
      change x ⟨min (k.val + i) ψ.n, by omega⟩ < x ⟨min (k.val + j) ψ.n, by omega⟩
      have ei : min (k.val + i) ψ.n = k.val + i := by omega
      have ej : min (k.val + j) ψ.n = k.val + j := by omega
      simp only [ei, ej]
      exact hmono (show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) < ⟨k.val + j, by omega⟩ by
        simp only [Fin.lt_def]; omega)
    · intro i hi
      change TemporalPred.EvalAt N atomMap (alphaR i) (x ⟨min (k.val + (i + 1)) ψ.n, by omega⟩)
      simp only [halphaR_def]
      have e1 : min (k.val + (i + 1)) ψ.n = k.val + 1 + i := by omega
      have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
      simp only [e1, e2]; rw [efPointTPFin_eval (hName := hName)]; exact hpt
          ⟨k.val + 1 + i, by omega⟩
    · intro i hi y hy1 hy2
      show TemporalPred.EvalAt N atomMap (betaR i) y
      simp only [hbetaR_def]
      have e2 : min (k.val + 1 + i) ψ.n = k.val + 1 + i := by omega
      simp only [e2]; rw [efIntervalSetTPFin_eval (hName := hName)]
      have eidx : k.val + 1 + i = k.val + i + 1 := by omega
      simp only [eidx]
      have ei : min (k.val + i) ψ.n = k.val + i := by omega
      have ei1 : min (k.val + (i + 1)) ψ.n = k.val + i + 1 := by omega
      have hy1' : x (⟨k.val + i, by omega⟩ : Fin ψ.n).castSucc < y := by
        change x ⟨k.val + i, by omega⟩ < y
        rw [show (⟨k.val + i, by omega⟩ : Fin (ψ.n + 1)) = ⟨min (k.val + i) ψ.n, by omega⟩ from by
          simp only [ei]]
        exact hy1
      have hy2' : y < x (⟨k.val + i, by omega⟩ : Fin ψ.n).succ := by
        change y < x ⟨k.val + i + 1, by omega⟩
        rw [show (⟨k.val + i + 1, by omega⟩ : Fin (ψ.n + 1)) = ⟨min (k.val + (i + 1)) ψ.n, by omega⟩
          from by simp only [ei1]]
        exact hy2
      exact hbetween ⟨k.val + i, by omega⟩ y hy1' hy2'
    · intro y hy
      change TemporalPred.EvalAt N atomMap
        (efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨ψ.n + 1, by omega⟩)) y
      rw [efIntervalSetTPFin_eval (hName := hName)]
      have ed : min (k.val + (ψ.n - k.val)) ψ.n = ψ.n := by omega
      have hy' : x (Fin.last ψ.n) < y := by
        rw [show (Fin.last ψ.n) = (⟨min (k.val + (ψ.n - k.val)) ψ.n, by omega⟩ : Fin (ψ.n + 1))
            from by
          apply Fin.ext; simp only [ed, Fin.val_last]]
        exact hy
      exact hafter y hy'

/-- Fin-variant of `middleBracket_of_efSat`: from `efSatFin` with `m < k`, the cap-free middle
bracket holds on `(z₀, z₁)`. Case-split on whether there are interior points. -/
theorem middleBracketFin_of_efSatFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2)
    (hlt : (ψ.pin 0).val < (ψ.pin 1).val) (h : efSatFin N env ψ) :
    (middleBracketFin atomMap nameOf ψ).holds N atomMap (env 0) (env 1) := by
  rw [efSatFin_interval_iff] at h
  obtain ⟨x, hmono, hpin, hpt, _hbefore, hbetween, _hafter⟩ := h
  have hpin0 : env 0 = x (ψ.pin 0) := hpin 0
  have hpin1 : env 1 = x (ψ.pin 1) := hpin 1
  -- `env 0 = x ⟨m⟩`, `env 1 = x ⟨k⟩` in explicit-index form.
  have he0 : env 0 = x ⟨(ψ.pin 0).val, (ψ.pin 0).isLt⟩ := by rw [hpin0]
  have he1 : env 1 = x ⟨(ψ.pin 1).val, (ψ.pin 1).isLt⟩ := by rw [hpin1]
  simp only [middleBracketFin, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.holds]
  refine ⟨?_, ?_, ?_⟩
  · change (efPointTPFin atomMap nameOf (ψ.pointType (ψ.pin 0))).EvalAt N atomMap (env 0)
    rw [efPointTPFin_eval (hName := hName), hpin0]; exact hpt (ψ.pin 0)
  · change (efPointTPFin atomMap nameOf (ψ.pointType (ψ.pin 1))).EvalAt N atomMap (env 1)
    rw [efPointTPFin_eval (hName := hName), hpin1]; exact hpt (ψ.pin 1)
  · simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
    by_cases hp0 : (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0
    · -- No interior points: k = m + 1. The single segment `β_{m+1}` on (x_m, x_{m+1}).
      rw [IntervalPattern.holds_eq_zero N atomMap _ _ (env 0) (env 1) hp0]
      intro y hy1 hy2
      change TemporalPred.EvalAt N atomMap
        (efIntervalSetTPFin atomMap nameOf
          (ψ.intervalType ⟨(ψ.pin 0).val + 1 + (0 : Fin 1).val, by omega⟩)) y
      rw [efIntervalSetTPFin_eval (hName := hName)]
      have hmn : (ψ.pin 0).val < ψ.n := by omega
      have hy1' : x (⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).castSucc < y := by
        change x ⟨(ψ.pin 0).val, by omega⟩ < y; rw [← he0]; exact hy1
      have hy2' : y < x (⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).succ := by
        change y < x ⟨(ψ.pin 0).val + 1, by omega⟩
        rw [show (⟨(ψ.pin 0).val + 1, by omega⟩ : Fin (ψ.n + 1)) =
            ⟨(ψ.pin 1).val, (ψ.pin 1).isLt⟩ from by apply Fin.ext; simp only; omega, ← he1]
        exact hy2
      have hb := hbetween ⟨(ψ.pin 0).val, hmn⟩ y hy1' hy2'
      rw [show ((⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).succ.castSucc) =
          (⟨(ψ.pin 0).val + 1 + (0 : Fin 1).val, by omega⟩ : Fin (ψ.n + 2)) from by
        apply Fin.ext; simp only [Fin.val_succ, Fin.val_castSucc]; omega] at hb
      exact hb
    · -- Interior points x_{m+1}, …, x_{k-1}.
      have hk' : (ψ.pin 1).val - (ψ.pin 0).val - 1 = ((ψ.pin 1).val - (ψ.pin 0).val - 2) + 1 := by
        omega
      rw [IntervalPattern.holds_eq_succ N atomMap _ _ (env 0) (env 1) hk']
      refine ⟨fun i => x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro i j hij
        change x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ < x ⟨(ψ.pin 0).val + 1 + j.val, by omega⟩
        exact hmono (show (⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ : Fin (ψ.n + 1)) <
          ⟨(ψ.pin 0).val + 1 + j.val, by omega⟩ by
              simp only [Fin.lt_def]; simp only [Fin.lt_def] at hij; omega)
      · intro i
        refine ⟨?_, ?_⟩
        · change env 0 < x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩
          rw [he0]
          exact hmono (show (⟨(ψ.pin 0).val, (ψ.pin 0).isLt⟩ : Fin (ψ.n + 1)) <
            ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ by simp only [Fin.lt_def]; omega)
        · change x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ < env 1
          rw [he1]
          exact hmono (show (⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ : Fin (ψ.n + 1)) <
            ⟨(ψ.pin 1).val, (ψ.pin 1).isLt⟩ by simp only [Fin.lt_def]; omega)
      · intro i
        change TemporalPred.EvalAt N atomMap
          (efPointTPFin atomMap nameOf (ψ.pointType ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩))
          (x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩)
        rw [efPointTPFin_eval (hName := hName)]; exact hpt ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩
      · intro y hy1 hy2
        change TemporalPred.EvalAt N atomMap
          (efIntervalSetTPFin atomMap nameOf
            (ψ.intervalType ⟨(ψ.pin 0).val + 1 + 0, by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have hmn : (ψ.pin 0).val < ψ.n := by omega
        have hy1' : x (⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).castSucc < y := by
          change x ⟨(ψ.pin 0).val, by omega⟩ < y; rw [← he0]; exact hy1
        have hy2' : y < x (⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).succ := by
          change y < x ⟨(ψ.pin 0).val + 1, by omega⟩
          simpa using hy2
        have hb := hbetween ⟨(ψ.pin 0).val, hmn⟩ y hy1' hy2'
        rw [show ((⟨(ψ.pin 0).val, hmn⟩ : Fin ψ.n).succ.castSucc) =
            (⟨(ψ.pin 0).val + 1 + 0, by omega⟩ : Fin (ψ.n + 2)) from by
          apply Fin.ext; simp only [Fin.val_succ, Fin.val_castSucc]] at hb
        exact hb
      · intro i y hy1 hy2
        change TemporalPred.EvalAt N atomMap
          (efIntervalSetTPFin atomMap nameOf
            (ψ.intervalType ⟨(ψ.pin 0).val + 1 + (i.val + 1), by omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have hmn : (ψ.pin 0).val + 1 + i.val < ψ.n := by omega
        have hy1' : x (⟨(ψ.pin 0).val + 1 + i.val, hmn⟩ : Fin ψ.n).castSucc < y := by
          change x ⟨(ψ.pin 0).val + 1 + i.val, by omega⟩ < y; simpa using hy1
        have hy2' : y < x (⟨(ψ.pin 0).val + 1 + i.val, hmn⟩ : Fin ψ.n).succ := by
          -- `exact`, not `simpa`: the two indices differ only by `a + (b + 1)` vs `a + b + 1`,
          -- which is definitional but no longer survives `simp`'s normalisation as a match.
          change y < x ⟨(ψ.pin 0).val + 1 + i.val + 1, by omega⟩; exact hy2
        have hb := hbetween ⟨(ψ.pin 0).val + 1 + i.val, hmn⟩ y hy1' hy2'
        rw [show ((⟨(ψ.pin 0).val + 1 + i.val, hmn⟩ : Fin ψ.n).succ.castSucc) =
            (⟨(ψ.pin 0).val + 1 + (i.val + 1), by omega⟩ : Fin (ψ.n + 2)) from by
          apply Fin.ext; simp only [Fin.val_succ, Fin.val_castSucc]; omega] at hb
        exact hb
      · intro y hy1 hy2
        change TemporalPred.EvalAt N atomMap
          (efIntervalSetTPFin atomMap nameOf
            (ψ.intervalType ⟨(ψ.pin 0).val + 1 + ((ψ.pin 1).val - (ψ.pin 0).val - 2 + 1), by
                omega⟩)) y
        rw [efIntervalSetTPFin_eval (hName := hName)]
        have hkm1 : (ψ.pin 1).val - 1 < ψ.n := by omega
        have hidxeq : (ψ.pin 1).val - 1 + 1 = (ψ.pin 1).val := by omega
        have hy1' : x (⟨(ψ.pin 1).val - 1, hkm1⟩ : Fin ψ.n).castSucc < y := by
          change x ⟨(ψ.pin 1).val - 1, by omega⟩ < y
          rw [show (⟨(ψ.pin 1).val - 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨(ψ.pin 0).val + 1 + ((ψ.pin 1).val - (ψ.pin 0).val - 2), by omega⟩ from by
            apply Fin.ext; simp only; omega]
          exact hy1
        have hy2' : y < x (⟨(ψ.pin 1).val - 1, hkm1⟩ : Fin ψ.n).succ := by
          change y < x ⟨(ψ.pin 1).val - 1 + 1, by omega⟩
          rw [show (⟨(ψ.pin 1).val - 1 + 1, by omega⟩ : Fin (ψ.n + 1)) =
              ⟨(ψ.pin 1).val, (ψ.pin 1).isLt⟩ from by apply Fin.ext; simp only; omega, ← he1]
          exact hy2
        have hb := hbetween ⟨(ψ.pin 1).val - 1, hkm1⟩ y hy1' hy2'
        rw [show ((⟨(ψ.pin 1).val - 1, hkm1⟩ : Fin ψ.n).succ.castSucc) =
            (⟨(ψ.pin 0).val + 1 + ((ψ.pin 1).val - (ψ.pin 0).val - 2 + 1), by omega⟩ : Fin
                (ψ.n + 2))
            from by apply Fin.ext; simp only [Fin.val_succ, Fin.val_castSucc]; omega] at hb
        exact hb

/-- Fin-variant of `efSat_decompose_tl_forward` (`m < k`): from `efSatFin` derive all three
TL-level factors. -/
theorem efSatFin_decompose_tl_forward {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2)
    (hlt : (ψ.pin 0).val < (ψ.pin 1).val) (h : efSatFin N env ψ) :
    TemporalTruth N atomMap (env 0) (belowFormulaFin atomMap nameOf ψ) ∧
    (middleBracketFin atomMap nameOf ψ).holds N atomMap (env 0) (env 1) ∧
    TemporalTruth N atomMap (env 1) (aboveFormulaFin atomMap nameOf ψ) :=
  ⟨belowFormulaFin_of_efSatFin N atomMap nameOf hName env ψ h,
   middleBracketFin_of_efSatFin N atomMap nameOf hName env ψ hlt h,
   aboveFormulaFin_of_efSatFin N atomMap nameOf hName env ψ h⟩

/-! ### 6.4 Fin backward decomposition (mirror of section 4 on the partial relations)

Transcription of `efSat_of_decompose_tl`: glue the three TL-level factors into one `efSatFin`
witness by concatenating the below chain, the middle interior witnesses, and the above chain at
the shared pinned endpoints (fixed order `below < x_m < middle < x_k < above`, no interleaving). -/

/-- Fin-variant of `efSat_of_decompose_tl` (`m < k`, `z₀ < z₁`): glue the three TL-level factors
into one `efSatFin` witness. -/
theorem efSatFin_of_decompose_tl {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2)
    (hlt : (ψ.pin 0).val < (ψ.pin 1).val) (henv : env 0 < env 1)
    (hb : TemporalTruth N atomMap (env 0) (belowFormulaFin atomMap nameOf ψ))
    (hm : (middleBracketFin atomMap nameOf ψ).holds N atomMap (env 0) (env 1))
    (ha : TemporalTruth N atomMap (env 1) (aboveFormulaFin atomMap nameOf ψ)) :
    efSatFin N env ψ := by
  have hkn : (ψ.pin 1).val ≤ ψ.n := by have := (ψ.pin 1).isLt; omega
  -- Below chain xb (antitone, pinned at env 0 = x_m).
  simp only [belowFormulaFin] at hb
  rw [temporal_truth_and] at hb
  obtain ⟨hb_pt, hb_chain⟩ := hb
  rw [buildLeft_correct] at hb_chain
  set alphaL : Nat → TemporalPred :=
    fun i => efPointTPFin atomMap nameOf (ψ.pointType ⟨(ψ.pin 0).val - 1 - i, by omega⟩)
    with halphaL_def
  set betaL : Nat → TemporalPred :=
    fun i => efIntervalSetTPFin atomMap nameOf
        (ψ.intervalType ⟨(ψ.pin 0).val - 1 - i + 1, by omega⟩)
    with hbetaL_def
  have hleft_eq :
      (List.finRange (ψ.pin 0).val).map (fun i =>
        (efPointTPFin atomMap nameOf (ψ.pointType ⟨(ψ.pin 0).val - 1 - i.val, by omega⟩),
         efIntervalSetTPFin atomMap nameOf (ψ.intervalType
             ⟨(ψ.pin 0).val - 1 - i.val + 1, by omega⟩))) =
      (List.finRange (ψ.pin 0).val).map (fun i => (alphaL i.val, betaL i.val)) := by
    apply List.map_congr_left; intro i _; simp only [halphaL_def, hbetaL_def]
  rw [hleft_eq, buildLeft_spec_iff_chain] at hb_chain
  obtain ⟨xb, hxb0, hxb_anti, hxb_alpha, hxb_beta, hxb_cap⟩ := hb_chain
  -- Above chain xa (monotone, pinned at env 1 = x_k).
  simp only [aboveFormulaFin] at ha
  rw [temporal_truth_and] at ha
  obtain ⟨ha_pt, ha_chain⟩ := ha
  rw [buildRight_correct] at ha_chain
  set alphaR : Nat → TemporalPred :=
    fun i => efPointTPFin atomMap nameOf (ψ.pointType ⟨min ((ψ.pin 1).val + 1 + i) ψ.n, by omega⟩)
    with halphaR_def
  set betaR : Nat → TemporalPred :=
    fun i => efIntervalSetTPFin atomMap nameOf
        (ψ.intervalType ⟨min ((ψ.pin 1).val + 1 + i) ψ.n, by omega⟩)
    with hbetaR_def
  have hright_eq :
      (List.finRange (ψ.n - (ψ.pin 1).val)).map (fun i =>
        (efPointTPFin atomMap nameOf (ψ.pointType ⟨(ψ.pin 1).val + 1 + i.val, by omega⟩),
         efIntervalSetTPFin atomMap nameOf (ψ.intervalType ⟨(ψ.pin 1).val + 1 + i.val, by omega⟩)))
             =
      (List.finRange (ψ.n - (ψ.pin 1).val)).map (fun i => (alphaR i.val, betaR i.val)) := by
    apply List.map_congr_left; intro i _
    simp only [halphaR_def, hbetaR_def]
    have e : min ((ψ.pin 1).val + 1 + i.val) ψ.n = (ψ.pin 1).val + 1 + i.val := by omega
    simp only [e]
  rw [hright_eq, buildRight_spec_iff_chain] at ha_chain
  obtain ⟨xa, hxa0, hxa_mono, hxa_alpha, hxa_beta, hxa_cap⟩ := ha_chain
  -- Middle interior witnesses wN (from the cap-free bracket), packaged uniformly over the interior
  -- count `c`; the two boundary segments use the `if c = 0` collapse.
  simp only [middleBracketFin, VVecEA2.holds, List.mem_singleton, exists_eq_left] at hm
  rw [VecEA2.holds] at hm
  obtain ⟨_hm_left, _hm_right, hm_br⟩ := hm
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at hm_br
  obtain ⟨wN, hwN_mono, hwN_bound, hwN_pt, hwN_first, hwN_mid, hwN_last⟩ :
      ∃ wN : Nat → N.carrier,
        (∀ i j, i < j → j < (ψ.pin 1).val - (ψ.pin 0).val - 1 → wN i < wN j) ∧
        (∀ i, i < (ψ.pin 1).val - (ψ.pin 0).val - 1 → env 0 < wN i ∧ wN i < env 1) ∧
        (∀ i, i < (ψ.pin 1).val - (ψ.pin 0).val - 1 →
          (efPointTPFin atomMap nameOf
            (ψ.pointType ⟨min ((ψ.pin 0).val + 1 + i) ψ.n, by omega⟩)).EvalAt N atomMap (wN i)) ∧
        (∀ y, env 0 < y →
          y < (if (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0 then env 1 else wN 0) →
          (efIntervalSetTPFin atomMap nameOf
            (ψ.intervalType ⟨(ψ.pin 0).val + 1, by omega⟩)).EvalAt N atomMap y) ∧
        (∀ ii, ii + 1 < (ψ.pin 1).val - (ψ.pin 0).val - 1 → ∀ y, wN ii < y → y < wN (ii + 1) →
          (efIntervalSetTPFin atomMap nameOf
            (ψ.intervalType ⟨min ((ψ.pin 0).val + 2 + ii) (ψ.n + 1), by omega⟩)).EvalAt N atomMap
                y) ∧
        (∀ y, (if (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0 then env 0
                else wN ((ψ.pin 1).val - (ψ.pin 0).val - 1 - 1)) < y → y < env 1 →
          (efIntervalSetTPFin atomMap nameOf
            (ψ.intervalType ⟨(ψ.pin 1).val, by omega⟩)).EvalAt N atomMap y) := by
    by_cases hp0 : (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0
    · rw [IntervalPattern.holds_eq_zero N atomMap _ _ (env 0) (env 1) hp0] at hm_br
      refine ⟨fun _ => env 1, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro i j hij hjc; omega
      · intro i hi; omega
      · intro i hi; omega
      · intro y hy1 hy2
        rw [if_pos hp0] at hy2
        exact hm_br y hy1 hy2
      · intro ii hii; omega
      · intro y hy1 hy2
        rw [if_pos hp0] at hy1
        have hz := hm_br y hy1 hy2
        rw [efIntervalSetTPFin_eval (hName := hName)] at hz ⊢
        rw [show (⟨(ψ.pin 1).val, by omega⟩ : Fin (ψ.n + 2)) =
            ⟨(ψ.pin 0).val + 1 + (0 : Fin 1).val, by omega⟩ from Fin.ext (by simp; omega)]
        exact hz
    · have hc' : (ψ.pin 1).val - (ψ.pin 0).val - 1 =
          ((ψ.pin 1).val - (ψ.pin 0).val - 2) + 1 := by omega
      rw [IntervalPattern.holds_eq_succ N atomMap _ _ (env 0) (env 1) hc'] at hm_br
      obtain ⟨wit, hwit_mono, hwit_bound, hwit_alpha, hwit_first, hwit_mid, hwit_last⟩ := hm_br
      refine ⟨fun i => wit ⟨min i ((ψ.pin 1).val - (ψ.pin 0).val - 2), by omega⟩,
        ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro i j hij hjc
        have ei : min i ((ψ.pin 1).val - (ψ.pin 0).val - 2) = i := by omega
        have ej : min j ((ψ.pin 1).val - (ψ.pin 0).val - 2) = j := by omega
        simp only [ei, ej]
        exact hwit_mono ⟨i, by omega⟩ ⟨j, by omega⟩ (Fin.mk_lt_mk.mpr hij)
      · intro i hi
        have ei : min i ((ψ.pin 1).val - (ψ.pin 0).val - 2) = i := by omega
        simp only [ei]
        exact hwit_bound ⟨i, by omega⟩
      · intro i hi
        have ei : min i ((ψ.pin 1).val - (ψ.pin 0).val - 2) = i := by omega
        have emin : min ((ψ.pin 0).val + 1 + i) ψ.n = (ψ.pin 0).val + 1 + i := by omega
        simp only [ei, emin]
        exact hwit_alpha ⟨i, by omega⟩
      · intro y hy1 hy2
        rw [if_neg hp0] at hy2
        have e0 : min 0 ((ψ.pin 1).val - (ψ.pin 0).val - 2) = 0 := by omega
        simp only [e0] at hy2
        exact hwit_first y hy1 hy2
      · intro ii hii y hy1 hy2
        have eii : min ii ((ψ.pin 1).val - (ψ.pin 0).val - 2) = ii := by omega
        have eii1 : min (ii + 1) ((ψ.pin 1).val - (ψ.pin 0).val - 2) = ii + 1 := by omega
        simp only [eii] at hy1
        simp only [eii1] at hy2
        have hmid := hwit_mid ⟨ii, by omega⟩ y hy1 hy2
        have emin : min ((ψ.pin 0).val + 2 + ii) (ψ.n + 1) = (ψ.pin 0).val + 2 + ii := by omega
        simp only [emin]
        rw [efIntervalSetTPFin_eval (hName := hName)] at hmid ⊢
        rw [show (⟨(ψ.pin 0).val + 2 + ii, by omega⟩ : Fin (ψ.n + 2)) =
            ⟨(ψ.pin 0).val + 1 + (ii + 1), by omega⟩ from Fin.ext (by simp; omega)]
        exact hmid
      · intro y hy1 hy2
        rw [if_neg hp0] at hy1
        have ecm : min ((ψ.pin 1).val - (ψ.pin 0).val - 1 - 1)
            ((ψ.pin 1).val - (ψ.pin 0).val - 2) = (ψ.pin 1).val - (ψ.pin 0).val - 2 := by omega
        simp only [ecm] at hy1
        have hl := hwit_last y hy1 hy2
        rw [efIntervalSetTPFin_eval (hName := hName)] at hl ⊢
        rw [show (⟨(ψ.pin 1).val, by omega⟩ : Fin (ψ.n + 2)) =
            ⟨(ψ.pin 0).val + 1 + ((ψ.pin 1).val - (ψ.pin 0).val - 2 + 1), by omega⟩
            from Fin.ext (by simp; omega)]
        exact hl
  -- The glued chain.
  set x : Fin (ψ.n + 1) → N.carrier :=
    fun j => if j.val ≤ (ψ.pin 0).val then xb ((ψ.pin 0).val - j.val)
             else if j.val < (ψ.pin 1).val then wN (j.val - (ψ.pin 0).val - 1)
             else xa (j.val - (ψ.pin 1).val) with hx_def
  have hx_below : ∀ j : Fin (ψ.n + 1), j.val ≤ (ψ.pin 0).val →
      x j = xb ((ψ.pin 0).val - j.val) := by
    intro j hj; simp only [hx_def, if_pos hj]
  have hx_mid : ∀ j : Fin (ψ.n + 1), (ψ.pin 0).val < j.val → j.val < (ψ.pin 1).val →
      x j = wN (j.val - (ψ.pin 0).val - 1) := by
    intro j hj1 hj2
    simp only [hx_def, if_neg (by omega : ¬ j.val ≤ (ψ.pin 0).val), if_pos hj2]
  have hx_above : ∀ j : Fin (ψ.n + 1), (ψ.pin 1).val ≤ j.val →
      x j = xa (j.val - (ψ.pin 1).val) := by
    intro j hj
    simp only [hx_def, if_neg (by omega : ¬ j.val ≤ (ψ.pin 0).val),
      if_neg (by omega : ¬ j.val < (ψ.pin 1).val)]
  have hxm : x (ψ.pin 0) = env 0 := by
    rw [hx_below (ψ.pin 0) (le_refl _), Nat.sub_self, hxb0]
  have hxk : x (ψ.pin 1) = env 1 := by
    rw [hx_above (ψ.pin 1) (le_refl _), Nat.sub_self, hxa0]
  -- Region anchor inequalities.
  have below_le : ∀ a : Fin (ψ.n + 1), a.val ≤ (ψ.pin 0).val → x a ≤ env 0 := by
    intro a ha
    rw [hx_below a ha]
    by_cases h : a.val = (ψ.pin 0).val
    · rw [show (ψ.pin 0).val - a.val = 0 from by omega, hxb0]
    · have := hxb_anti 0 ((ψ.pin 0).val - a.val) (by omega) (by omega)
      rw [hxb0] at this; exact le_of_lt this
  have above_ge : ∀ b : Fin (ψ.n + 1), (ψ.pin 1).val ≤ b.val → env 1 ≤ x b := by
    intro b hb
    rw [hx_above b hb]
    by_cases h : b.val = (ψ.pin 1).val
    · rw [show b.val - (ψ.pin 1).val = 0 from by omega, hxa0]
    · have := hxa_mono 0 (b.val - (ψ.pin 1).val) (by omega) (by omega)
      rw [hxa0] at this; exact le_of_lt this
  have hmid_lo : ∀ a : Fin (ψ.n + 1), (ψ.pin 0).val < a.val → a.val < (ψ.pin 1).val →
      env 0 < x a := by
    intro a h1 h2
    rw [hx_mid a h1 h2]
    exact (hwN_bound (a.val - (ψ.pin 0).val - 1) (by omega)).1
  have hmid_hi : ∀ a : Fin (ψ.n + 1), (ψ.pin 0).val < a.val → a.val < (ψ.pin 1).val →
      x a < env 1 := by
    intro a h1 h2
    rw [hx_mid a h1 h2]
    exact (hwN_bound (a.val - (ψ.pin 0).val - 1) (by omega)).2
  rw [efSatFin_interval_iff]
  refine ⟨x, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- StrictMono x
    intro a b hab
    rw [Fin.lt_def] at hab
    rcases le_or_gt (ψ.pin 1).val b.val with hbk | hbk
    · rcases le_or_gt a.val (ψ.pin 0).val with ham | ham
      · exact lt_of_le_of_lt (below_le a ham) (lt_of_lt_of_le henv (above_ge b hbk))
      · rcases lt_or_ge a.val (ψ.pin 1).val with hak | hak
        · exact lt_of_lt_of_le (hmid_hi a ham hak) (above_ge b hbk)
        · rw [hx_above a hak, hx_above b hbk]
          exact hxa_mono (a.val - (ψ.pin 1).val) (b.val - (ψ.pin 1).val) (by omega) (by omega)
    · rcases le_or_gt b.val (ψ.pin 0).val with hbm | hbm
      · rw [hx_below a (by omega), hx_below b hbm]
        exact hxb_anti ((ψ.pin 0).val - b.val) ((ψ.pin 0).val - a.val) (by omega) (by omega)
      · rcases le_or_gt a.val (ψ.pin 0).val with ham | ham
        · exact lt_of_le_of_lt (below_le a ham) (hmid_lo b hbm hbk)
        · rw [hx_mid a ham (by omega), hx_mid b hbm hbk]
          exact hwN_mono (a.val - (ψ.pin 0).val - 1) (b.val - (ψ.pin 0).val - 1)
            (by omega) (by omega)
  · -- pin condition
    rw [Fin.forall_fin_two]
    exact ⟨hxm.symm, hxk.symm⟩
  · -- pointType
    intro j
    rcases le_or_gt j.val (ψ.pin 0).val with hjm | hjm
    · by_cases hjeq : j.val = (ψ.pin 0).val
      · have hjp : j = ψ.pin 0 := Fin.ext hjeq
        rw [hjp, hxm]
        exact (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType (ψ.pin 0)) (env 0)).mp hb_pt
      · rw [hx_below j hjm]
        have halph := hxb_alpha ((ψ.pin 0).val - j.val - 1) (by omega)
        simp only [halphaL_def] at halph
        have e1 : (ψ.pin 0).val - 1 - ((ψ.pin 0).val - j.val - 1) = j.val := by omega
        have e2 : (ψ.pin 0).val - j.val - 1 + 1 = (ψ.pin 0).val - j.val := by omega
        simp only [e1, e2] at halph
        rw [efPointTPFin_eval (hName := hName)] at halph
        exact halph
    · rcases le_or_gt (ψ.pin 1).val j.val with hjk | hjk
      · by_cases hjeq : j.val = (ψ.pin 1).val
        · have hjp : j = ψ.pin 1 := Fin.ext hjeq
          rw [hjp, hxk]
          exact (efPointTPFin_eval N atomMap nameOf hName (ψ.pointType (ψ.pin 1)) (env 1)).mp ha_pt
        · rw [hx_above j hjk]
          have halph := hxa_alpha (j.val - (ψ.pin 1).val - 1) (by omega)
          simp only [halphaR_def] at halph
          have e1 : min ((ψ.pin 1).val + 1 + (j.val - (ψ.pin 1).val - 1)) ψ.n = j.val := by omega
          have e2 : j.val - (ψ.pin 1).val - 1 + 1 = j.val - (ψ.pin 1).val := by omega
          simp only [e1, e2] at halph
          rw [efPointTPFin_eval (hName := hName)] at halph
          exact halph
      · rw [hx_mid j hjm hjk]
        have hpt := hwN_pt (j.val - (ψ.pin 0).val - 1) (by omega)
        have emin : min ((ψ.pin 0).val + 1 + (j.val - (ψ.pin 0).val - 1)) ψ.n = j.val := by omega
        simp only [emin] at hpt
        rw [efPointTPFin_eval (hName := hName)] at hpt
        exact hpt
  · -- before-cap
    intro y hy
    have hval0 : (0 : Fin (ψ.n + 1)).val = 0 := rfl
    rw [hx_below 0 (by rw [hval0]; omega), hval0, Nat.sub_zero] at hy
    have hbef := hxb_cap y hy
    rw [efIntervalSetTPFin_eval (hName := hName)] at hbef
    exact hbef
  · -- between
    intro i y hy1 hy2
    have hcs : (Fin.castSucc i).val = i.val := Fin.val_castSucc i
    have hsc : (Fin.succ i).val = i.val + 1 := Fin.val_succ i
    rcases lt_trichotomy i.val (ψ.pin 0).val with hreg | hreg | hreg
    · -- both below
      rw [hx_below i.castSucc (by rw [hcs]; omega), hcs] at hy1
      rw [hx_below i.succ (by rw [hsc]; omega), hsc] at hy2
      have e1 : (ψ.pin 0).val - i.val - 1 + 1 = (ψ.pin 0).val - i.val := by omega
      have e2 : (ψ.pin 0).val - (i.val + 1) = (ψ.pin 0).val - i.val - 1 := by omega
      have hbeta := hxb_beta ((ψ.pin 0).val - i.val - 1) (by omega) y
        (by rw [e1]; exact hy1) (by rw [e2] at hy2; exact hy2)
      simp only [hbetaL_def] at hbeta
      have e3 : (ψ.pin 0).val - 1 - ((ψ.pin 0).val - i.val - 1) + 1 = i.val + 1 := by omega
      simp only [e3] at hbeta
      rw [efIntervalSetTPFin_eval (hName := hName)] at hbeta
      rw [show i.succ.castSucc = (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 2)) from
        Fin.ext (by rw [Fin.val_castSucc, Fin.val_succ])]
      exact hbeta
    · -- boundary below/middle at i.val = m
      have hcast_pin : i.castSucc = ψ.pin 0 := Fin.ext (by rw [hcs]; omega)
      rw [hcast_pin, hxm] at hy1
      rw [show i.succ.castSucc = (⟨(ψ.pin 0).val + 1, by omega⟩ : Fin (ψ.n + 2)) from
        Fin.ext (by simp; omega)]
      by_cases hp0 : (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0
      · have hsucc_pin : i.succ = ψ.pin 1 := Fin.ext (by rw [hsc]; omega)
        rw [hsucc_pin, hxk] at hy2
        have := hwN_first y hy1 (by rw [if_pos hp0]; exact hy2)
        rw [efIntervalSetTPFin_eval (hName := hName)] at this
        exact this
      · have hsucc_mid : x i.succ = wN 0 := by
          rw [hx_mid i.succ (by rw [hsc]; omega) (by rw [hsc]; omega)]
          congr 1; rw [hsc]; omega
        rw [hsucc_mid] at hy2
        have := hwN_first y hy1 (by rw [if_neg hp0]; exact hy2)
        rw [efIntervalSetTPFin_eval (hName := hName)] at this
        exact this
    · -- i.val > m
      rcases lt_trichotomy (i.val + 1) (ψ.pin 1).val with hreg2 | hreg2 | hreg2
      · -- interior middle
        rw [hx_mid i.castSucc (by rw [hcs]; omega) (by rw [hcs]; omega), hcs] at hy1
        rw [hx_mid i.succ (by rw [hsc]; omega) (by rw [hsc]; omega), hsc] at hy2
        have e1 : i.val - (ψ.pin 0).val - 1 + 1 = i.val + 1 - (ψ.pin 0).val - 1 := by omega
        have hmid := hwN_mid (i.val - (ψ.pin 0).val - 1) (by omega) y hy1
          (by rw [e1]; exact hy2)
        have emin : min ((ψ.pin 0).val + 2 + (i.val - (ψ.pin 0).val - 1)) (ψ.n + 1) = i.val +
            1 := by
          omega
        simp only [emin] at hmid
        rw [efIntervalSetTPFin_eval (hName := hName)] at hmid
        rw [show i.succ.castSucc = (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 2)) from
          Fin.ext (by rw [Fin.val_castSucc, Fin.val_succ])]
        exact hmid
      · -- boundary middle/above at i.val = k - 1
        have hp0 : ¬ (ψ.pin 1).val - (ψ.pin 0).val - 1 = 0 := by omega
        rw [hx_mid i.castSucc (by rw [hcs]; omega) (by rw [hcs]; omega), hcs] at hy1
        have hsucc_pin : i.succ = ψ.pin 1 := Fin.ext (by rw [hsc]; omega)
        rw [hsucc_pin, hxk] at hy2
        have ecm : i.val - (ψ.pin 0).val - 1 = (ψ.pin 1).val - (ψ.pin 0).val - 1 - 1 := by omega
        rw [ecm] at hy1
        have hl := hwN_last y (by rw [if_neg hp0]; exact hy1) hy2
        rw [efIntervalSetTPFin_eval (hName := hName)] at hl
        rw [show i.succ.castSucc = (⟨(ψ.pin 1).val, by omega⟩ : Fin (ψ.n + 2)) from
          Fin.ext (by simp; omega)]
        exact hl
      · -- both above
        rw [hx_above i.castSucc (by rw [hcs]; omega), hcs] at hy1
        rw [hx_above i.succ (by rw [hsc]; omega), hsc] at hy2
        have e1 : i.val - (ψ.pin 1).val + 1 = i.val + 1 - (ψ.pin 1).val := by omega
        have hbeta := hxa_beta (i.val - (ψ.pin 1).val) (by omega) y hy1
          (by rw [e1]; exact hy2)
        simp only [hbetaR_def] at hbeta
        have emin : min ((ψ.pin 1).val + 1 + (i.val - (ψ.pin 1).val)) ψ.n = i.val + 1 := by omega
        simp only [emin] at hbeta
        rw [efIntervalSetTPFin_eval (hName := hName)] at hbeta
        rw [show i.succ.castSucc = (⟨i.val + 1, by omega⟩ : Fin (ψ.n + 2)) from
          Fin.ext (by rw [Fin.val_castSucc, Fin.val_succ])]
        exact hbeta
  · -- after-cap
    intro y hy
    rw [hx_above (Fin.last ψ.n) (by rw [Fin.val_last]; omega), Fin.val_last] at hy
    have haf := hxa_cap y hy
    rw [efIntervalSetTPFin_eval (hName := hName)] at haf
    exact haf

/-- Fin-variant of `efSat_decompose_tl` (`m < k`, `z₀ < z₁`): the per-formula two-free-variable
`∃∀`-object is satisfied iff its three TL-level factors hold — Rabinovich's
`ψ ≡ ψ₀(z₀) ∧ φ(z₀,z₁) ∧ ψ₁(z₁)` (Prop 4.2, `m < k` case, PDF p.7) on the partial relations. -/
theorem efSatFin_decompose_tl {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (env : Fin 2 → N.carrier) (ψ : ExistsForallFormulaFin sig F 2)
    (hlt : (ψ.pin 0).val < (ψ.pin 1).val) (henv : env 0 < env 1) :
    efSatFin N env ψ ↔
      TemporalTruth N atomMap (env 0) (belowFormulaFin atomMap nameOf ψ) ∧
      (middleBracketFin atomMap nameOf ψ).holds N atomMap (env 0) (env 1) ∧
      TemporalTruth N atomMap (env 1) (aboveFormulaFin atomMap nameOf ψ) :=
  ⟨efSatFin_decompose_tl_forward N atomMap nameOf hName env ψ hlt,
   fun ⟨hb, hm, ha⟩ => efSatFin_of_decompose_tl N atomMap nameOf hName env ψ hlt henv hb hm ha⟩

/-! ### 6.5 Fin disjunctive negation assembly (mirror of section 5)

`¬ψ = ¬ψ₀ ∨ ¬φ ∨ ¬ψ₁` (Rabinovich Prop 4.2, PDF p.7) on the per-formula representation: the end
negations are `negLeftClauseTLFin`/`negRightClauseTLFin`, the middle is
`(middleBracketFin ψ).negFix` via the Lemma 5.1 engine `VVecEA2.negFix_iff` (TemporalPred-level,
reused verbatim — no Fin variant needed). -/

/-- **Fin-variant of `prop42_efSat_negation_general` (Rabinovich Prop 4.2, PDF p.7).** For any
per-formula two-free-variable `∃∀`-object `ψ` (arbitrary pins, contentful caps), there is a
`VVecEA2` object `v'` (the disjunctive reassembly `¬ψ₀ ∨ ¬φ ∨ ¬ψ₁`) whose satisfaction on any
strictly ordered pair `(z₀, z₁)` is exactly the failure of `ψ`. Gated on Dedekind-completeness
of the carrier (`h_INF`/`h_SUP`), consumed by the Lemma 5.1 middle engine `VVecEA2.negFix_iff`. -/
theorem prop42_efSat_negation_generalFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (hName : ∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (ψ : ExistsForallFormulaFin sig F 2) :
    ∃ v' : VVecEA2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSatFin N env ψ) := by
  by_cases hlt : (ψ.pin 0).val < (ψ.pin 1).val
  · -- `m < k`: disjunctive reassembly of the three-piece split.
    refine ⟨VVecEA2.disj
      (VVecEA2.disj (negLeftClauseTLFin atomMap nameOf ψ)
          (middleBracketFin atomMap nameOf ψ).negFix)
      (negRightClauseTLFin atomMap nameOf ψ), ?_⟩
    intro env henv
    rw [VVecEA2.disj_holds, VVecEA2.disj_holds, negLeftClauseTLFin_holds (_hName := hName),
      VVecEA2.negFix_iff N atomMap h_INF h_SUP _ (env 0) (env 1) henv, negRightClauseTLFin_holds
          (_hName := hName),
      efSatFin_decompose_tl N atomMap nameOf hName env ψ hlt henv]
    tauto
  · -- `m ≥ k`: unsatisfiable under `z₀ < z₁`, so its negation is trivially realized.
    refine ⟨VVecEA2.trivialTrue, ?_⟩
    intro env henv
    constructor
    · intro _ hsat
      exact hlt (efSatFin_pin_lt N env ψ hsat henv)
    · intro _
      exact VVecEA2.trivialTrue_holds N atomMap (env 0) (env 1)

end FinLayer

end FormalSystem.Metalogic.WeakCanonical.Kamp
