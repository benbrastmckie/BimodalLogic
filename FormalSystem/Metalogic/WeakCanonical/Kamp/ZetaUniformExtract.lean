/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop43Translate
import FormalSystem.Metalogic.WeakCanonical.Kamp.ZetaPriorTransfer
import FormalSystem.Metalogic.WeakCanonical.Kamp.MonadicFormulaMap

/-!
# The `M`-uniform `∨∃∀` extraction on the per-formula layer (Rabinovich Thm 4.4, PDF p.6)

`translate_correctFin` (`Prop43Translate.lean`) and the negation chain
(`VeeSatNegation.lean` / `EFSatNegationGeneral.lean`) emit, per model `N`, a per-formula
`∨∃∀`-formula `Ψ` equivalent to the input monadic FO formula. The completeness spine
(`kamp_prior_expressive_completeness`) instead needs a *single* formula uniform over all models.
This module bridges that uniformity gap on the per-formula (Fin) layer.

## Why uniformity is now free of any capture parameter

Under the infinite E[Σ] alphabet (Def 4.1, p.5) the only formerly model-dependent choice in the
whole pipeline — the capture interval obtained from the threaded `hCapture` — is gone: capture is
CONSTRUCTED as the direct `capTypeFin (esigmaPred A)` (`ESigmaCapture.lean`), a syntactic
function of the captured formula alone (the readback IS an atom of the expansion — the p.6
collapse note). Every object the chain emits is therefore a function of the input formula and the
fixed `atomMap`/`nameOf` parameters, and this module hoists the `∃`-witness *outside* the model
quantifier (`∃Ψ`-outside-`∀N`), threading the per-model premises — the atom-naming fact `hNamed`
(discharged at the ζ site by `canonExpand_atom_named`), `HasAttainedINF`/`HasAttainedSUP`
(discharged by `ZetaPriorTransfer.lean`), and `Nonempty N.carrier` — *inside* the `∀N`.

The proof bodies are the per-`N` Fin-layer proofs verbatim, re-entered after `intro N`.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 4.3 / Theorem 4.4 (p.6),
  Definition 4.1 (p.5), collapse-to-atom note (p.6). Cited by PDF page; the companion markdown
  transcription is corrupt.
- `ESigmaCapture.lean`: `capTypeFin`, `capTypeFin_atomNamed` (the direct capture).
- `Prop43Translate.lean`: `translate_correctFin`, `ex_closure_translateFin` (the per-`N` forms).
- `EFSatNegationGeneral.lean` / `VeeSatNegation.lean`: the per-`N` negation stack.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula Atom)
open FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The low-arity negation leaves, in uniform shape -/

/-- **Uniform arity-1 negation object.** `∃Φ`-outside-`∀N` form of `efSat_negation_diagonalFin`:
the negation formula is the `pointEF1Fin`-disjunction over the direct capture interval of the
negated readback — a fixed per-formula `∨∃∀`-formula (no model input) realizing
`¬ efSatFin N env ξ` on every `N` satisfying the atom-naming premise. -/
theorem efSat_negation_diagonal_uniformFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ξ : ExistsForallFormulaFin sig F 1) :
    ∃ Φ : VeeExistsForallFin sig F 1,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A) →
        ∀ env : Fin 1 → N.carrier, (veeSatFin N env Φ ↔ ¬ efSatFin N env ξ) := by
  classical
  refine ⟨(capTypeFin (esigmaPred (F := F) (translateProp35Fin atomMap nameOf ξ).neg)).toList.map
      (fun τ => pointEF1Fin τ), ?_⟩
  intro N hName hNamed env
  set S := capTypeFin (esigmaPred (F := F) (translateProp35Fin atomMap nameOf ξ).neg) with hSdef
  have hS : ∀ y : N.carrier, intervalHoldsFin N S y ↔
      temporal_truth N atomMap y (translateProp35Fin atomMap nameOf ξ).neg :=
    fun y => capTypeFin_atomNamed N atomMap hNamed _ y
  have hveeLHS : veeSatFin N env (S.toList.map (fun τ => pointEF1Fin τ)) ↔
      intervalHoldsFin N S (env 0) := by
    simp only [veeSatFin, List.mem_map, Finset.mem_toList, intervalHoldsFin]
    constructor
    · rintro ⟨ψ, ⟨τ, hτ, rfl⟩, hsat⟩
      exact ⟨τ, hτ, (pointEF1Fin_efSat N τ env).mp hsat⟩
    · rintro ⟨τ, hτ, hu⟩
      exact ⟨pointEF1Fin τ, ⟨τ, hτ, rfl⟩, (pointEF1Fin_efSat N τ env).mpr hu⟩
  rw [hveeLHS, hS (env 0), temporal_truth_neg,
    translateProp35Fin_correct N atomMap nameOf hName env ξ]

/-- **Uniform arity-0 negation object.** `∃Φ`-outside-`∀N` form of `efSat_negation_existenceFin`:
the negation formula is the `univSentenceFin`-disjunction over the direct capture interval of the
negated pinned readback. `hne` is threaded per-`N` (mandatory: the arity-0 negation is false on
an empty carrier). -/
theorem efSat_negation_existence_uniformFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ξ : ExistsForallFormulaFin sig F 0) :
    ∃ Φ : VeeExistsForallFin sig F 0,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A) →
        Nonempty N.carrier →
        (veeSatFin N ![] Φ ↔ ¬ efSatFin N ![] ξ) := by
  classical
  refine ⟨(capTypeFin
        (esigmaPred (F := F) (translateProp35Fin atomMap nameOf (pinFirstFin ξ)).neg)).toList.map
      (fun τ => univSentenceFin τ (capTypeFin
        (esigmaPred (F := F) (translateProp35Fin atomMap nameOf (pinFirstFin ξ)).neg))), ?_⟩
  intro N hName hNamed hne
  set S := capTypeFin
    (esigmaPred (F := F) (translateProp35Fin atomMap nameOf (pinFirstFin ξ)).neg) with hSdef
  have hS : ∀ y : N.carrier, intervalHoldsFin N S y ↔
      temporal_truth N atomMap y (translateProp35Fin atomMap nameOf (pinFirstFin ξ)).neg :=
    fun y => capTypeFin_atomNamed N atomMap hNamed _ y
  have hRHS : (¬ efSatFin N ![] ξ) ↔ (∀ z : N.carrier, intervalHoldsFin N S z) := by
    rw [pinFirstFin_efSat N ξ, not_exists]
    apply forall_congr'
    intro z
    rw [translateProp35Fin_correct N atomMap nameOf hName ![z] (pinFirstFin ξ), ←
        temporal_truth_neg,
      ← hS (![z] 0)]
    simp
  have hLHS : veeSatFin N ![] (S.toList.map (fun τ => univSentenceFin τ S)) ↔
      (∀ z : N.carrier, intervalHoldsFin N S z) := by
    rw [← order_point_forall_iff N hne (intervalHoldsFin N S)]
    have step : veeSatFin N ![] (S.toList.map (fun τ => univSentenceFin τ S)) ↔
        ∃ τ ∈ S, efSatFin N ![] (univSentenceFin τ S) := by
      simp only [veeSatFin, List.mem_map, Finset.mem_toList]
      constructor
      · rintro ⟨ψ, ⟨τ, hτ, rfl⟩, hsat⟩; exact ⟨τ, hτ, hsat⟩
      · rintro ⟨τ, hτ, hsat⟩; exact ⟨univSentenceFin τ S, ⟨τ, hτ, rfl⟩, hsat⟩
    rw [step]
    simp only [univSentenceFin_efSat]
    constructor
    · rintro ⟨τ, hτ, x0, hτx0, hb, ha⟩
      exact ⟨x0, ⟨τ, hτ, hτx0⟩, hb, ha⟩
    · rintro ⟨x0, hx0, hb, ha⟩
      obtain ⟨τ, hτ, hτx0⟩ := hx0
      exact ⟨τ, hτ, x0, hτx0, hb, ha⟩
  rw [hLHS, hRHS]

/-! ## 2. The arity-2 negation object in uniform shape (engine + collapse bridge) -/

/-- **Uniform arity-2 model-side engine.** `∃v'`-outside-`∀N` form of
`prop42_efSat_negation_generalFin`: the `VVecEA2` witness is the `ψ`-determined disjunctive
reassembly (its construction never mentions `N`, `h_INF`, or `h_SUP` — those enter only the
`negFix_iff` correctness step), so the same `v'` realizes `¬ efSatFin ξ` on strictly-ordered
pairs for every attained-INF/SUP `N`. -/
theorem prop42_efSat_negation_general_uniformFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 2) :
    ∃ v' : VVecEA2, ∀ (N : OrderedMonadicStructure (sigE sig F)),
      (∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y) →
      HasAttainedINF N atomMap → HasAttainedSUP N atomMap →
      ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSatFin N env ψ) := by
  by_cases hlt : (ψ.pin 0).val < (ψ.pin 1).val
  · refine ⟨VVecEA2.disj
      (VVecEA2.disj (negLeftClauseTLFin atomMap nameOf ψ)
        (middleBracketFin atomMap nameOf ψ).negFix)
      (negRightClauseTLFin atomMap nameOf ψ), ?_⟩
    intro N hName h_INF h_SUP env henv
    rw [VVecEA2.disj_holds, VVecEA2.disj_holds, negLeftClauseTLFin_holds (_hName := hName),
      VVecEA2.negFix_iff N atomMap h_INF h_SUP _ (env 0) (env 1) henv, negRightClauseTLFin_holds
          (_hName := hName),
      efSatFin_decompose_tl N atomMap nameOf hName env ψ hlt henv]
    tauto
  · refine ⟨VVecEA2.trivialTrue, ?_⟩
    intro N _ _ _ env henv
    constructor
    · intro _ hsat
      exact hlt (efSatFin_pin_lt N env ψ hsat henv)
    · intro _
      exact VVecEA2.trivialTrue_holds N atomMap (env 0) (env 1)

/-- **Uniform collapse bridge.** `∃Φ`-outside-`∀N` form of `vvecea2_collapse_bridgeFin`: with
capture constructed directly (`capTypeFin`), the lifted per-formula `∨∃∀`-object is a genuine
function of `v'` and the fixed parameters alone (no model input), realizing `v'.holds` on
strictly-ordered pairs for every `N` satisfying the atom-naming premise. Proof body is the
per-`N` bridge verbatim, with the per-clause reverse translation inlined. -/
theorem vvecea2_collapse_bridge_uniformFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (v' : VVecEA2) :
    ∃ Φ : VeeExistsForallFin sig F 2,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A) →
        ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (veeSatFin N env Φ ↔ v'.holds N atomMap (env 0) (env 1)) := by
  classical
  -- The direct capture data: all model-free.
  let Mcap : Formula → Finset (AtomKind (sigE sig F) 1) := fun A =>
    {AtomKind.pred (esigmaPred (F := F) A) (0 : Fin 1)}
  let Scap : ∀ A : Formula, IntervalTypeFin sig F (Mcap A) := fun A =>
    capTypeFin (esigmaPred (F := F) A)
  -- Ambient mentioned set of one clause: union of all its captured sets' mentioned sets.
  let MA : (Σ n, VecEA2 n) → Finset (AtomKind (sigE sig F) 1) := fun vea =>
    ((Mcap vea.2.endpointLeft.formula ∪ Mcap vea.2.endpointRight.formula) ∪
      Finset.univ.sup fun i : Fin vea.1 => Mcap (vea.2.bracket.pointTypes i).formula) ∪
      Finset.univ.sup fun j : Fin (vea.1 + 1) => Mcap (vea.2.bracket.segmentTypes j).formula
  have subL : ∀ vea : Σ n, VecEA2 n, Mcap vea.2.endpointLeft.formula ⊆ MA vea := fun vea =>
    (Finset.subset_union_left.trans Finset.subset_union_left).trans Finset.subset_union_left
  have subR : ∀ vea : Σ n, VecEA2 n, Mcap vea.2.endpointRight.formula ⊆ MA vea := fun vea =>
    (Finset.subset_union_right.trans Finset.subset_union_left).trans Finset.subset_union_left
  have subP : ∀ (vea : Σ n, VecEA2 n) (i : Fin vea.1),
      Mcap (vea.2.bracket.pointTypes i).formula ⊆ MA vea := fun vea i =>
    ((Finset.le_sup
        (f := fun i => Mcap (vea.2.bracket.pointTypes i).formula) (Finset.mem_univ i))).trans
      (Finset.subset_union_right.trans Finset.subset_union_left)
  have subS : ∀ (vea : Σ n, VecEA2 n) (j : Fin (vea.1 + 1)),
      Mcap (vea.2.bracket.segmentTypes j).formula ⊆ MA vea := fun vea j =>
    ((Finset.le_sup
        (f := fun j => Mcap (vea.2.bracket.segmentTypes j).formula) (Finset.mem_univ j))).trans
      Finset.subset_union_right
  refine ⟨v'.disjuncts.flatMap (fun vea =>
      ((intervalExpandFin (subL vea) (Scap vea.2.endpointLeft.formula)) ×ˢ
        (intervalExpandFin (subR vea) (Scap vea.2.endpointRight.formula)) ×ˢ
        Fintype.piFinset (fun i =>
          intervalExpandFin (subP vea i) (Scap (vea.2.bracket.pointTypes i).formula))).toList.map
        (fun t => collapseEFFin
          (fun j => intervalExpandFin (subS vea j) (Scap (vea.2.bracket.segmentTypes j).formula))
          t.1 t.2.1 t.2.2)), ?_⟩
  intro N hName hNamed env henv
  have hcap : ∀ (A : Formula) (y : N.carrier),
      intervalHoldsFin N (Scap A) y ↔ temporal_truth N atomMap y A :=
    fun A y => capTypeFin_atomNamed N atomMap hNamed A y
  -- Per-clause reverse translation (the body of the per-N bridge, inlined).
  have htrans : ∀ vea ∈ v'.disjuncts, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      ((∃ ψ ∈ (fun vea =>
          ((intervalExpandFin (subL vea) (Scap vea.2.endpointLeft.formula)) ×ˢ
            (intervalExpandFin (subR vea) (Scap vea.2.endpointRight.formula)) ×ˢ
            Fintype.piFinset (fun i =>
              intervalExpandFin (subP vea i)
                (Scap (vea.2.bracket.pointTypes i).formula))).toList.map
            (fun t => collapseEFFin
              (fun j => intervalExpandFin (subS vea j)
                (Scap (vea.2.bracket.segmentTypes j).formula))
              t.1 t.2.1 t.2.2)) vea, efSatFin N env ψ)
        ↔ vea.2.holds N atomMap (env 0) (env 1)) := by
    rintro ⟨m, vc⟩ hvea env henv
    dsimp only
    set S_L := intervalExpandFin (subL ⟨m, vc⟩) (Scap vc.endpointLeft.formula) with hSL
    set S_R := intervalExpandFin (subR ⟨m, vc⟩) (Scap vc.endpointRight.formula) with hSR
    set Sp := fun i : Fin m =>
      intervalExpandFin (subP ⟨m, vc⟩ i) (Scap (vc.bracket.pointTypes i).formula) with hSp_def
    set Ss := fun j : Fin (m + 1) =>
      intervalExpandFin (subS ⟨m, vc⟩ j) (Scap (vc.bracket.segmentTypes j).formula) with hSs_def
    have hcorrect : ∀ (τ_L τ_R : UnaryTypeFin sig F (MA ⟨m, vc⟩))
        (g : Fin m → UnaryTypeFin sig F (MA ⟨m, vc⟩)),
        efSatFin N env (collapseEFFin Ss τ_L τ_R g) ↔
          partialHolds N τ_L (env 0) ∧ partialHolds N τ_R (env 1) ∧
          (BracketFormula.mk (fun i => efPointTPFin atomMap nameOf (g i))
            (fun j => efIntervalSetTPFin atomMap nameOf (Ss j))).holds N atomMap
              (env 0) (env 1) := by
      intro τ_L τ_R g
      rw [translateProp42Fin_correct N atomMap nameOf hName env (collapseEFFin Ss τ_L τ_R g)
            (collapseEFFin_cap N Ss τ_L τ_R g) henv,
          collapseEFFin_translate atomMap nameOf Ss τ_L τ_R g]
      constructor
      · rintro ⟨hL, hR, hbr⟩
        exact ⟨(efPointTPFin_eval N atomMap nameOf hName τ_L (env 0)).mp hL,
               (efPointTPFin_eval N atomMap nameOf hName τ_R (env 1)).mp hR, hbr⟩
      · rintro ⟨hL, hR, hbr⟩
        exact ⟨(efPointTPFin_eval N atomMap nameOf hName τ_L (env 0)).mpr hL,
               (efPointTPFin_eval N atomMap nameOf hName τ_R (env 1)).mpr hR, hbr⟩
    have hSpcap : ∀ (i : Fin m) (y : N.carrier),
        intervalHoldsFin N (Sp i) y ↔ (vc.bracket.pointTypes i).eval_at N atomMap y := fun i y =>
      (intervalHoldsFin_expandFin_iff N (subP ⟨m, vc⟩ i) _ y).trans
        (hcap (vc.bracket.pointTypes i).formula y)
    have hSscap : ∀ (j : Fin (m + 1)) (y : N.carrier),
        intervalHoldsFin N (Ss j) y ↔ (vc.bracket.segmentTypes j).eval_at N atomMap y :=
      fun j y =>
      (intervalHoldsFin_expandFin_iff N (subS ⟨m, vc⟩ j) _ y).trans
        (hcap (vc.bracket.segmentTypes j).formula y)
    rw [VecEA2.holds]
    constructor
    · rintro ⟨ψ, hψmem, hsat⟩
      rw [List.mem_map] at hψmem
      obtain ⟨t, htmem, rfl⟩ := hψmem
      rw [Finset.mem_toList, Finset.mem_product, Finset.mem_product] at htmem
      obtain ⟨htL, htR, htg⟩ := htmem
      rw [hcorrect] at hsat
      obtain ⟨huL, huR, hbr⟩ := hsat
      refine ⟨?_, ?_, ?_⟩
      · exact (hcap vc.endpointLeft.formula (env 0)).mp
          ((intervalHoldsFin_expandFin_iff N (subL ⟨m, vc⟩) _ (env 0)).mp ⟨t.1, htL, huL⟩)
      · exact (hcap vc.endpointRight.formula (env 1)).mp
          ((intervalHoldsFin_expandFin_iff N (subR ⟨m, vc⟩) _ (env 1)).mp ⟨t.2.1, htR, huR⟩)
      · exact (bracket_completion_iffFin N atomMap nameOf hName vc.bracket Sp Ss hSpcap hSscap
          (env 0) (env 1)).mp ⟨t.2.2, htg, hbr⟩
    · rintro ⟨heL, heR, hbrk⟩
      have hiL : intervalHoldsFin N S_L (env 0) :=
        (intervalHoldsFin_expandFin_iff N (subL ⟨m, vc⟩) _ (env 0)).mpr
          ((hcap vc.endpointLeft.formula (env 0)).mpr heL)
      have hiR : intervalHoldsFin N S_R (env 1) :=
        (intervalHoldsFin_expandFin_iff N (subR ⟨m, vc⟩) _ (env 1)).mpr
          ((hcap vc.endpointRight.formula (env 1)).mpr heR)
      obtain ⟨τ_L, hτL, huL⟩ := hiL
      obtain ⟨τ_R, hτR, huR⟩ := hiR
      obtain ⟨g, hg, hbr⟩ := (bracket_completion_iffFin N atomMap nameOf hName vc.bracket Sp Ss
        hSpcap hSscap (env 0) (env 1)).mpr hbrk
      refine ⟨collapseEFFin Ss τ_L τ_R g, ?_, ?_⟩
      · rw [List.mem_map]
        exact ⟨(τ_L, τ_R, g), by
          rw [Finset.mem_toList, Finset.mem_product, Finset.mem_product]
          exact ⟨hτL, hτR, hg⟩, rfl⟩
      · rw [hcorrect]
        exact ⟨huL, huR, hbr⟩
  simp only [veeSatFin, VVecEA2.holds, List.mem_flatMap]
  constructor
  · rintro ⟨ψ, ⟨vea, hvea, hψ⟩, hsat⟩
    exact ⟨vea, hvea, (htrans vea hvea env henv).mp ⟨ψ, hψ, hsat⟩⟩
  · rintro ⟨vea, hvea, hholds⟩
    obtain ⟨ψ, hψ, hsat⟩ := (htrans vea hvea env henv).mpr hholds
    exact ⟨ψ, ⟨vea, hvea, hψ⟩, hsat⟩

/-- **Uniform arity-2 negation object (engine ∘ bridge).** `∃Φ`-outside-`∀N` form of
`efSat_negation_pairFin`: compose the uniform engine (model-independent `v'`) with the uniform
collapse bridge (model-independent `Φ`). -/
theorem efSat_negation_pair_uniformFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ξ : ExistsForallFormulaFin sig F 2) :
    ∃ Φ : VeeExistsForallFin sig F 2,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A) →
        HasAttainedINF N atomMap → HasAttainedSUP N atomMap →
        ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (veeSatFin N env Φ ↔ ¬ efSatFin N env ξ) := by
  obtain ⟨v', hv'⟩ := prop42_efSat_negation_general_uniformFin atomMap nameOf ξ
  obtain ⟨Φ, hΦ⟩ := vvecea2_collapse_bridge_uniformFin atomMap nameOf v'
  refine ⟨Φ, fun N hName hNamed h_INF h_SUP env henv => ?_⟩
  exact (hΦ N hName hNamed env henv).trans (hv' N hName h_INF h_SUP env henv)

/-! ## 3. The general negation object (β) in uniform shape -/

/-- **Uniform `efSat_negation_generalFin` (β).** `∃Φ`-outside-`∀N` form: the disjunct list is
assembled from the three model-independent leaves `P`/`D`/`E`, so it is a fixed per-formula
`∨∃∀`-formula and its pin-monotonicity holds before any `N`. The De Morgan trichotomy
correctness is proved per-`N`, threading `hNamed` / `h_INF` / `h_SUP` / `hne`. -/
theorem efSat_negation_general_uniformFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {r : Nat} (ψ : ExistsForallFormulaFin sig F r) :
    ∃ Φ : VeeExistsForallFin sig F r, (∀ φ ∈ Φ, StrictMono φ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A) →
        HasAttainedINF N atomMap → HasAttainedSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin r → N.carrier, StrictMono env →
        (¬ efSatFin N env ψ ↔ veeSatFin N env Φ) := by
  classical
  have hpair := fun (k l : Fin r) =>
    efSat_negation_pair_uniformFin atomMap nameOf (pairProjectFin ψ k l)
  choose P hPspec using hpair
  have hdiag := fun (k : Fin r) =>
    efSat_negation_diagonal_uniformFin atomMap nameOf (diagProjectFin ψ k)
  choose D hDspec using hdiag
  obtain ⟨E, hEspec⟩ :=
    efSat_negation_existence_uniformFin atomMap nameOf (existenceSentenceFin ψ)
  refine ⟨((List.finRange r).flatMap fun k => (List.finRange r).flatMap fun l =>
            if k < l then liftPairVFin (P k l) k l else [])
          ++ ((List.finRange r).flatMap fun k => liftSingleVFin (D k) k)
          ++ liftSentenceVFin E, ?_, ?_⟩
  · -- Pin-monotonicity of every disjunct (model-independent).
    intro φ hφ
    rw [List.mem_append, List.mem_append] at hφ
    rcases hφ with (hφ | hφ) | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      rw [List.mem_flatMap] at hφ
      obtain ⟨l, _, hφ⟩ := hφ
      by_cases hkl : k < l
      · rw [if_pos hkl] at hφ
        exact liftPairVFin_pin_strictMono (P k l) k l φ hφ
      · rw [if_neg hkl] at hφ
        exact absurd hφ List.not_mem_nil
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      exact liftSingleVFin_pin_strictMono (D k) k φ hφ
    · exact liftSentenceVFin_pin_strictMono E φ hφ
  · intro N hName hNamed h_INF h_SUP hne env h
    set A := (List.finRange r).flatMap (fun k => (List.finRange r).flatMap fun l =>
              if k < l then liftPairVFin (P k l) k l else []) with hAdef
    set B := (List.finRange r).flatMap (fun k => liftSingleVFin (D k) k) with hBdef
    set C := liftSentenceVFin E with hCdef
    have hA : veeSatFin N env A ↔
        ∃ k l : Fin r, k < l ∧ ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l) := by
      rw [hAdef, veeSatFin_flatMap]
      constructor
      · rintro ⟨k, -, hk⟩
        rw [veeSatFin_flatMap] at hk
        obtain ⟨l, -, hl⟩ := hk
        by_cases hkl : k < l
        · rw [if_pos hkl, liftPairVFin_iff N env h (P k l) k l hkl,
            hPspec k l N hName hNamed h_INF h_SUP ![env k, env l] (by simpa using h hkl)] at hl
          exact ⟨k, l, hkl, hl⟩
        · rw [if_neg hkl] at hl
          simp [veeSatFin] at hl
      · rintro ⟨k, l, hkl, hnp⟩
        refine ⟨k, List.mem_finRange k, ?_⟩
        rw [veeSatFin_flatMap]
        refine ⟨l, List.mem_finRange l, ?_⟩
        rw [if_pos hkl, liftPairVFin_iff N env h (P k l) k l hkl,
          hPspec k l N hName hNamed h_INF h_SUP ![env k, env l] (by simpa using h hkl)]
        exact hnp
    have hB : veeSatFin N env B ↔
        ∃ k : Fin r, ¬ efSatFin N ![env k, env k] (pairProjectFin ψ k k) := by
      rw [hBdef, veeSatFin_flatMap]
      constructor
      · rintro ⟨k, -, hk⟩
        rw [liftSingleVFin_iff N env h (D k) k, hDspec k N hName hNamed ![env k],
          ← diagProjectFin_efSat_iff N env ψ k] at hk
        exact ⟨k, hk⟩
      · rintro ⟨k, hk⟩
        refine ⟨k, List.mem_finRange k, ?_⟩
        rw [liftSingleVFin_iff N env h (D k) k, hDspec k N hName hNamed ![env k],
          ← diagProjectFin_efSat_iff N env ψ k]
        exact hk
    have hC : veeSatFin N env C ↔ ¬ efSatFin N ![] (existenceSentenceFin ψ) := by
      rw [hCdef, liftSentenceVFin_iff N env h E, hEspec N hName hNamed hne]
    have hDemPairs : (∃ p ∈ pairwiseProjectionsFin ψ, ¬ efSatFin N ![env p.1, env p.2.1] p.2.2)
        ↔ ∃ k l : Fin r, ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l) := by
      constructor
      · rintro ⟨p, hp, hnp⟩
        unfold pairwiseProjectionsFin at hp
        rw [List.mem_flatMap] at hp
        obtain ⟨k, -, hp⟩ := hp
        rw [List.mem_map] at hp
        obtain ⟨l, -, rfl⟩ := hp
        exact ⟨k, l, hnp⟩
      · rintro ⟨k, l, hnp⟩
        refine ⟨(k, l, pairProjectFin ψ k l), ?_, hnp⟩
        unfold pairwiseProjectionsFin
        rw [List.mem_flatMap]
        exact ⟨k, List.mem_finRange k, by rw [List.mem_map]; exact ⟨l, List.mem_finRange l, rfl⟩⟩
    have hTri : (∃ k l : Fin r, ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l))
        ↔ (∃ k l : Fin r, k < l ∧ ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l))
          ∨ (∃ k : Fin r, ¬ efSatFin N ![env k, env k] (pairProjectFin ψ k k)) := by
      constructor
      · rintro ⟨k, l, hnp⟩
        rcases lt_trichotomy k l with hkl | hkl | hkl
        · exact Or.inl ⟨k, l, hkl, hnp⟩
        · subst hkl; exact Or.inr ⟨_, hnp⟩
        · refine Or.inl ⟨l, k, hkl, ?_⟩
          rw [← pairProject_swap_efSatFin N env ψ k l]
          exact hnp
      · rintro (⟨k, l, -, hnp⟩ | ⟨k, hnp⟩)
        · exact ⟨k, l, hnp⟩
        · exact ⟨k, k, hnp⟩
    rw [efSatFin_negation_demorgan N env ψ, hDemPairs, veeSatFin_append, veeSatFin_append,
      hA, hB, hC, hTri]

/-! ## 4. Negation closure of per-formula `∨∃∀`-formulas (γ) in uniform shape -/

/-- **Uniform `veeSat_negationFin` (γ).** `∃Φ'`-outside-`∀N` form: each `¬φᵢ` is the uniform
β-negation, the conjunction reassembled by `veeConjFin_iff`. The emitted `Φ'` and its
pin-monotonicity are fixed before any `N`. -/
theorem veeSat_negation_uniformFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {r : Nat} (Φ : VeeExistsForallFin sig F r) :
    ∃ Φ' : VeeExistsForallFin sig F r, (∀ ψ ∈ Φ', StrictMono ψ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A) →
        HasAttainedINF N atomMap → HasAttainedSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin r → N.carrier, StrictMono env →
        (¬ veeSatFin N env Φ ↔ veeSatFin N env Φ') := by
  classical
  induction Φ with
  | nil =>
    obtain ⟨Gd, hGdmono, hGd⟩ :=
      efSat_negation_general_uniformFin atomMap nameOf (efArbFin sig F r)
    refine ⟨Gd ++ [efArbFin sig F r], ?_, ?_⟩
    · intro φ hφ
      rw [List.mem_append] at hφ
      rcases hφ with hφ | hφ
      · exact hGdmono φ hφ
      · rw [List.mem_singleton] at hφ
        subst hφ
        exact efArbFin_pin_strictMono sig F r
    · intro N hName hNamed h_INF h_SUP hne env hmono
      constructor
      · intro _
        rw [veeSatFin_append]
        by_cases hd : efSatFin N env (efArbFin sig F r)
        · exact Or.inr ⟨efArbFin sig F r, by simp, hd⟩
        · exact Or.inl ((hGd N hName hNamed h_INF h_SUP hne env hmono).mp hd)
      · intro _
        exact veeSatFin_nil N env
  | cons ψ rest ih =>
    obtain ⟨Gψ, hGψmono, hGψ⟩ :=
      efSat_negation_general_uniformFin atomMap nameOf ψ
    obtain ⟨Φrest, hrestmono, hrest⟩ := ih
    refine ⟨veeConjFin Gψ Φrest, ?_, ?_⟩
    · exact fun χ hχ => veeConjFin_pin_strictMono Gψ Φrest hGψmono χ hχ
    · intro N hName hNamed h_INF h_SUP hne env hmono
      rw [veeSatFin_cons, not_or, hGψ N hName hNamed h_INF h_SUP hne env hmono,
        hrest N hName hNamed h_INF h_SUP hne env hmono, veeConjFin_iff N env Gψ Φrest]

/-! ## 5. The `∃`-closure assembly in uniform shape -/

/-- **Uniform `ex_closure_translateFin`.** `∃Ψ`-outside-`∀N` form: the emitted per-formula
`∨∃∀`-formula and its pin-monotonicity are functions of `Ψg`/`Ψt` alone; the per-`N` gap/tie
translation correctness is threaded as hypotheses inside `∀N`. Proof body copied verbatim from
`ex_closure_translateFin`. -/
theorem ex_closure_translate_uniformFin {m : Nat}
    (α : MonadicFormula (sigE sig F) (m + 1))
    (Ψg : Fin (m + 1) → VeeExistsForallFin sig F (m + 1))
    (hΨgmono : ∀ p, ∀ ψ ∈ Ψg p, StrictMono ψ.pin)
    (Ψt : Fin m → VeeExistsForallFin sig F m)
    (hΨtmono : ∀ i, ∀ ψ ∈ Ψt i, StrictMono ψ.pin) :
    ∃ Ψ : VeeExistsForallFin sig F m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ (p : Fin (m + 1)) (env : Fin (m + 1) → N.carrier), StrictMono env →
            (veeSatFin N env (Ψg p) ↔
              eval N env (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1))))) →
        (∀ (i : Fin m) (env : Fin m → N.carrier), StrictMono env →
            (veeSatFin N env (Ψt i) ↔ eval N env (α.subst0 i))) →
        ∀ env : Fin m → N.carrier, StrictMono env →
        (veeSatFin N env Ψ ↔ ∃ x : N.carrier, eval N (Fin.cons x env) α) := by
  classical
  refine ⟨((List.finRange (m + 1)).flatMap fun p =>
             ((Ψg p).map (ExistsForallFormulaFin.renamePin
               (insertPerm p : Fin (m + 1) → Fin (m + 1)))).map dropPinFin)
          ++ ((List.finRange m).flatMap fun i => Ψt i), ?_, ?_⟩
  · intro φ hφ
    rw [List.mem_append] at hφ
    rcases hφ with hφ | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨p, _, hφ⟩ := hφ
      rw [List.mem_map] at hφ
      obtain ⟨χ, hχmem, rfl⟩ := hφ
      rw [List.mem_map] at hχmem
      obtain ⟨ψ, hψmem, rfl⟩ := hχmem
      have hcomp : (dropPinFin (ExistsForallFormulaFin.renamePin
          (insertPerm p : Fin (m + 1) → Fin (m + 1)) ψ)).pin
          = ψ.pin ∘ (fun k : Fin m => (insertPerm p : Fin (m + 1) → Fin (m + 1)) k.succ) := rfl
      rw [hcomp]
      have hsucc : (fun k : Fin m => (insertPerm p : Fin (m + 1) → Fin (m + 1)) k.succ)
          = p.succAbove := by funext k; exact insertPerm_succ p k
      rw [hsucc]
      exact (hΨgmono p ψ hψmem).comp (Fin.strictMono_succAbove p)
    · rw [List.mem_flatMap] at hφ
      obtain ⟨i, _, hφ⟩ := hφ
      exact hΨtmono i φ hφ
  · intro N hΨg hΨt env hmono
    rw [veeSatFin_append]
    constructor
    · rintro (hgapv | htiev)
      · rw [veeSatFin_flatMap] at hgapv
        obtain ⟨p, _, hpv⟩ := hgapv
        rw [← veeSatFin_exists] at hpv
        obtain ⟨a, hav⟩ := hpv
        rw [veeSatFin_renamePin, cons_comp_insertPerm_symm] at hav
        have hsm : StrictMono (Fin.insertNth p a env) :=
          strictMono_of_veeSatFin_pin_mono N _ (Ψg p) (hΨgmono p) hav
        have heval := (hΨg p (Fin.insertNth p a env) hsm).mp hav
        rw [eval_insertNth_rename] at heval
        exact ⟨a, heval⟩
      · rw [veeSatFin_flatMap] at htiev
        obtain ⟨i, _, hiv⟩ := htiev
        have heval := (hΨt i env hmono).mp hiv
        rw [eval_subst0] at heval
        exact ⟨env i, heval⟩
    · rintro ⟨x, hx⟩
      rcases witness_classification env hmono x with ⟨i, rfl⟩ | ⟨p, hsm⟩
      · rw [← eval_subst0] at hx
        have hiv := (hΨt i env hmono).mpr hx
        refine Or.inr ?_
        rw [veeSatFin_flatMap]
        exact ⟨i, List.mem_finRange i, hiv⟩
      · rw [← eval_insertNth_rename N p x env α] at hx
        have hpv := (hΨg p (Fin.insertNth p x env) hsm).mpr hx
        rw [← cons_comp_insertPerm_symm p x env, ← veeSatFin_renamePin] at hpv
        refine Or.inl ?_
        rw [veeSatFin_flatMap]
        refine ⟨p, List.mem_finRange p, ?_⟩
        rw [← veeSatFin_exists]
        exact ⟨x, hpv⟩

/-! ## 6. The uniform Proposition 4.3 translate (δ, `∃Ψ`-outside-`∀N`) -/

/-- **Uniform Proposition 4.3 translate (δ).** `∃Ψ`-outside-`∀N` form of `translate_correctFin`:
for a fixed `atomMap`/`nameOf` naming, every monadic FO formula `φ` over the E[Σ] alphabet has a
*single* per-formula `∨∃∀`-formula `Ψ` (a function of `φ` and the params alone — no model input)
that, on every `N` satisfying the atom-naming premise (with `h_INF`/`h_SUP`/`hne`), is
equivalent to `φ` on strictly increasing environments. This is the uniform translate the
completeness spine consumes at the ζ wire (Rabinovich Thm 4.4, p.6). -/
theorem translate_uniformFin
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {m : Nat} (φ : MonadicFormula (sigE sig F) m) :
    ∃ Ψ : VeeExistsForallFin sig F m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, temporal_truth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A) →
        HasAttainedINF N atomMap → HasAttainedSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin m → N.carrier, StrictMono env →
        (veeSatFin N env Ψ ↔ eval N env φ) := by
  classical
  match m, φ with
  | 0, .atom _ i => exact i.elim0
  | (m' + 1), .atom p i =>
      -- The p.6 collapse, inlined: `p` is named by the FORMULA `nameOf p` (at ζ the readback
      -- of a fresh pred IS its formula; a base pred is a chosen atom).
      refine ⟨atomEmitFin i (capTypeFin (esigmaPred (F := F) (nameOf p))), ?_, ?_⟩
      · intro φ' hφ'
        unfold atomEmitFin at hφ'
        rw [List.mem_map] at hφ'
        obtain ⟨σ, _, rfl⟩ := hφ'
        exact skelDisjunctFin_pin_strictMono σ
      · intro N hName hNamed _ _ _ env hmono
        rw [atomEmitFin_iff N i _ env hmono,
          capTypeFin_atomNamed N atomMap hNamed (nameOf p) (env i)]
        show temporal_truth N atomMap (env i) (nameOf p)
            ↔ eval N env (MonadicFormula.atom p i)
        simp only [eval]
        exact hName p (env i)
  | 0, .lt i _ => exact i.elim0
  | (m' + 1), .lt i j =>
      by_cases hij : i < j
      · refine ⟨skelRFin ∅ m', ?_, ?_⟩
        · exact fun φ' hφ' => skelRFin_pin_strictMono φ' hφ'
        · intro N _ _ _ _ _ env hmono
          change veeSatFin N env (skelRFin ∅ m') ↔ env i < env j
          constructor
          · intro _; exact hmono.lt_iff_lt.mpr hij
          · intro _; exact skelRFin_sat N env hmono
      · refine ⟨[], ?_, ?_⟩
        · intro φ' hφ'; exact absurd hφ' List.not_mem_nil
        · intro N _ _ _ _ _ env hmono
          change veeSatFin N env ([] : VeeExistsForallFin sig F (m' + 1)) ↔ env i < env j
          constructor
          · intro h; exact absurd h (veeSatFin_nil N env)
          · intro h; exact absurd (hmono.lt_iff_lt.mp h) hij
  | _, .not α =>
      obtain ⟨Ψα, _, hα⟩ := translate_uniformFin atomMap nameOf α
      obtain ⟨Ψ', hΨ'mono, hΨ'⟩ := veeSat_negation_uniformFin atomMap nameOf Ψα
      refine ⟨Ψ', hΨ'mono, ?_⟩
      intro N hName hNamed h_INF h_SUP hne env hmono
      change veeSatFin N env Ψ' ↔ ¬ eval N env α
      rw [← hΨ' N hName hNamed h_INF h_SUP hne env hmono, hα N hName hNamed h_INF h_SUP hne env
          hmono]
  | _, .and α β =>
      obtain ⟨Ψα, hαmono, hα⟩ := translate_uniformFin atomMap nameOf α
      obtain ⟨Ψβ, _, hβ⟩ := translate_uniformFin atomMap nameOf β
      refine ⟨veeConjFin Ψα Ψβ, ?_, ?_⟩
      · exact fun χ hχ => veeConjFin_pin_strictMono Ψα Ψβ hαmono χ hχ
      · intro N hName hNamed h_INF h_SUP hne env hmono
        change veeSatFin N env (veeConjFin Ψα Ψβ) ↔ eval N env α ∧ eval N env β
        rw [veeConjFin_iff N env Ψα Ψβ, hα N hName hNamed h_INF h_SUP hne env hmono,
          hβ N hName hNamed h_INF h_SUP hne env hmono]
  | m, .all α =>
      have hgap := fun p : Fin (m + 1) =>
        translate_uniformFin atomMap nameOf
          (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      choose Ψg hΨgmono hΨg using hgap
      have htie := fun i : Fin m =>
        translate_uniformFin atomMap nameOf (α.subst0 i)
      choose Ψt hΨtmono hΨt using htie
      have hgapN := fun p : Fin (m + 1) =>
        veeSat_negation_uniformFin atomMap nameOf (Ψg p)
      choose Ψg' hΨg'mono hΨg'neg using hgapN
      have htieN := fun i : Fin m =>
        veeSat_negation_uniformFin atomMap nameOf (Ψt i)
      choose Ψt' hΨt'mono hΨt'neg using htieN
      obtain ⟨Ψex, hΨexmono, hΨexcorr⟩ :=
        ex_closure_translate_uniformFin (.not α) Ψg' hΨg'mono Ψt' hΨt'mono
      obtain ⟨Ψall, hΨallmono, hΨallneg⟩ :=
        veeSat_negation_uniformFin atomMap nameOf Ψex
      refine ⟨Ψall, hΨallmono, ?_⟩
      intro N hName hNamed h_INF h_SUP hne env hmono
      have hΨex := hΨexcorr N
        (fun p env' h => (hΨg'neg p N hName hNamed h_INF h_SUP hne env' h).symm.trans
          (not_congr (hΨg p N hName hNamed h_INF h_SUP hne env' h)))
        (fun i env' h => (hΨt'neg i N hName hNamed h_INF h_SUP hne env' h).symm.trans
          (not_congr (hΨt i N hName hNamed h_INF h_SUP hne env' h)))
        env hmono
      rw [← hΨallneg N hName hNamed h_INF h_SUP hne env hmono, hΨex]
      exact not_exists_not
  | m, .ex α =>
      have hgap := fun p : Fin (m + 1) =>
        translate_uniformFin atomMap nameOf
          (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      choose Ψg hΨgmono hΨg using hgap
      have htie := fun i : Fin m =>
        translate_uniformFin atomMap nameOf (α.subst0 i)
      choose Ψt hΨtmono hΨt using htie
      obtain ⟨Ψex, hΨexmono, hΨexcorr⟩ :=
        ex_closure_translate_uniformFin α Ψg hΨgmono Ψt hΨtmono
      refine ⟨Ψex, hΨexmono, ?_⟩
      intro N hName hNamed h_INF h_SUP hne env hmono
      exact hΨexcorr N
        (fun p env' h => hΨg p N hName hNamed h_INF h_SUP hne env' h)
        (fun i env' h => hΨt i N hName hNamed h_INF h_SUP hne env' h)
        env hmono
termination_by φ.size
decreasing_by
  all_goals simp only [MonadicFormula.size, size_rename, size_subst0]
  all_goals omega

/-! ## 7. The ζ wire (Rabinovich Thm 4.4, PDF p.6, instantiated at the canonical expansion)

The terminal wire: for a base signature `sig` with a surjective object-language atom map
`g` (surjectivity onto `sig.preds` — which HOLDS for the base signature), the one-free-variable
existential over any depth-`k` arity-2 normal form is expressed by a single temporal formula,
uniformly over all Prior structures `M`. The pipeline is exactly Thm 4.4's:

1. the target is the monadic FO formula `∃x. sub_nf` (one free variable, `nf_to_formula`);
2. lift it to the infinite E[Σ] alphabet along `mapPreds oldPred` (`MonadicFormulaMap.lean`);
3. apply the uniform Prop 4.3 translate (`translate_uniformFin`) with the ζ naming
   `zetaNameOf`: a base predicate is named by a chosen atom (base `h_surj`), a fresh
   predicate `P_A` is named by the formula `A` ITSELF — the p.6 collapse;
4. per `M`, instantiate at the canonical expansion `N := canonExpand sig ∅ M sat` with
   `sat B := temporal_truth M g · B` (Def 4.1, p.5): the naming premise is
   `canonExpand_atom_named`, the attained-INF/SUP premises transfer by
   `ZetaPriorTransfer.lean`, and `hne` is witnessed by the evaluation point;
5. read the emitted `∨∃∀`-formula back as a temporal formula at arity 1
   (`translateVeeProp35Fin`), and descend from `N` to `M` by the conservativity bridge
   `temporal_truth_canonExpand` (the atom map factors through `oldPred`, so the emitted
   formula never mentions a fresh atom's interpretation except through its name).
-/

/-- **The ζ naming function (p.6 collapse).** A base predicate `Sum.inl q` is named by a chosen
atom mapping onto it (base-signature surjectivity — which holds); a fresh predicate
`Sum.inr A` is named by the formula `A` itself. Model-free. -/
noncomputable def zetaNameOf {sig : MonadicSignature} {F : Finset Formula}
    (g : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, g (.atom a) = p) :
    (sigE sig F).preds → Formula
  | .inl q => .atom (Classical.choose (h_surj q))
  | .inr A => A

/-- **`zetaNameOf` satisfies the naming premise** on any `N` that (a) evaluates the object
language through `atomMap = oldPred ∘ g` and (b) satisfies the fresh-atom naming fact
`hNamed`. At a base predicate the atom's temporal truth is its interpretation by `hMap` +
choice; at a fresh predicate this is `hNamed` verbatim (`esigmaPred A = Sum.inr A`). -/
theorem zetaNameOf_hName {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (g : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, g (.atom a) = p)
    (atomMap : Formula → (sigE sig F).preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hNamed : ∀ (A : Formula) (y : N.carrier),
        N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A) :
    ∀ p y, temporal_truth N atomMap y (zetaNameOf g h_surj p) ↔ N.interp p y := by
  intro p y
  match p with
  | .inl q =>
    change temporal_truth N atomMap y (.atom (Classical.choose (h_surj q))) ↔ N.interp (.inl q) y
    have hq := Classical.choose_spec (h_surj q)
    simp only [temporal_truth, hMap, hq, oldPred]
  | .inr A =>
    change temporal_truth N atomMap y A ↔ N.interp (.inr A) y
    exact (hNamed A y).symm

/-- **The ζ wire (Thm 4.4, p.6).** For any depth `k`, the one-free-variable existential over a
depth-`k` arity-2 normal form is expressed by a single temporal formula, uniformly over all
Prior structures: `temporal_truth M g t A ↔ ∃ x, sub_nf(x, t)`. The formula is a function of
`sub_nf`, `g`, and the base choice of names alone — no model input; every per-model premise of
the uniform translate is discharged at the canonical expansion. -/
theorem kampArm_zeta {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (g : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, g (.atom a) = p)
    {k : Nat} (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig),
        semantic_prior_UZ M g → semantic_prior_SZ M g →
        ∀ t : M.carrier,
        (temporal_truth M g t A ↔
          ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf) := by
  classical
  -- 1-2. The lifted monadic target `∃x. sub_nf` over the E[Σ] alphabet (stage index `∅`).
  set ψ : MonadicFormula sig 1 := .ex (nf_to_formula sub_nf) with hψdef
  set atomMapE : Formula → (sigE sig (∅ : Finset Formula)).preds :=
    fun φ => oldPred (g φ) with hatomMapE
  have hMap : ∀ φ, atomMapE φ = oldPred (g φ) := fun _ => rfl
  set nameOf : (sigE sig (∅ : Finset Formula)).preds → Formula :=
    zetaNameOf g h_surj with hnameOf
  -- 3. The uniform Prop 4.3 translate of the lifted target.
  obtain ⟨Ψ, _hΨmono, hΨ⟩ := translate_uniformFin atomMapE nameOf (ψ.mapPreds oldPred)
  refine ⟨translateVeeProp35Fin atomMapE nameOf Ψ, ?_⟩
  intro M hUZ hSZ t
  -- 4. Instantiate at the canonical expansion with `sat B := temporal_truth M g · B`.
  set sat : Formula → M.carrier → Prop := fun B x => temporal_truth M g x B with hsat
  set N : OrderedMonadicStructure (sigE sig (∅ : Finset Formula)) :=
    canonExpand sig ∅ M sat with hNdef
  have hNamed : ∀ (A : Formula) (y : N.carrier),
      N.interp (esigmaPred (F := (∅ : Finset Formula)) A) y ↔ temporal_truth N atomMapE y A :=
    fun A y => canonExpand_atom_named M atomMapE g hMap A y
  have hName : ∀ p y, temporal_truth N atomMapE y (nameOf p) ↔ N.interp p y :=
    zetaNameOf_hName N g h_surj atomMapE hMap hNamed
  have h_INF : HasAttainedINF N atomMapE :=
    canonExpand_hasAttainedINF M sat atomMapE g hMap hUZ
  have h_SUP : HasAttainedSUP N atomMapE :=
    canonExpand_hasAttainedSUP M sat atomMapE g hMap hSZ
  have hne : Nonempty N.carrier := ⟨t⟩
  have hmono1 : StrictMono (fun _ : Fin 1 => (t : N.carrier)) := by
    intro i j hij
    exact absurd (Subsingleton.elim i j) (Fin.ne_of_lt hij)
  -- 5. Chain: conservativity ∘ readback ∘ uniform-translate ∘ mapPreds ∘ nf_to_formula.
  calc temporal_truth M g t (translateVeeProp35Fin atomMapE nameOf Ψ)
      ↔ temporal_truth N atomMapE t (translateVeeProp35Fin atomMapE nameOf Ψ) :=
        (temporal_truth_canonExpand M sat atomMapE g hMap _ t).symm
    _ ↔ veeSatFin N (fun _ => t) Ψ :=
        (translateVeeProp35Fin_correct N atomMapE nameOf hName (fun _ => t) Ψ).symm
    _ ↔ eval N (fun _ => t) (ψ.mapPreds oldPred) :=
        hΨ N hName hNamed h_INF h_SUP hne (fun _ => t) hmono1
    _ ↔ eval M (fun _ => t) ψ := mapPreds_eval_iff M sat (fun _ => t) ψ
    _ ↔ ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf := by
        change (∃ x : M.carrier, eval M (Fin.cons x (fun _ => t)) (nf_to_formula sub_nf)) ↔ _
        exact exists_congr fun x => nf_to_formula_correct M _ sub_nf

end FormalSystem.Metalogic.WeakCanonical.Kamp
