# Phase 4 decompose-slices handoff — 4a-4..N consumer migration COMPLETE (items 6+7 landed)

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Commits this dispatch**: 7 green commits on top of `18ebba24e`, EVERY slice first-pass green:
  `a0f5a690c` (Prop42NegationGeneral Fin §3 forward mirrors),
  `520d2d526` (§4 backward mirror — the ~340-line `efSatFin_of_decompose_tl` atomic transcription
  + `efSatFin_decompose_tl`),
  `94d3f10c6` (§5 assembly `prop42_efSat_negation_generalFin`),
  `152a89cea` (EFSatNegation `efSat_negation_pairFin` = engine ∘ `vvecea2_collapse_bridgeFin`),
  `0cdb8cb3d` (`veeSatFin_append` + EFSatNegationGeneral §8 `efSat_negation_generalFin` assembly),
  `2a621a618` (VeeSatNegation Fin layer: `veeSat_negationFin` + `efArbFin` over `M = ∅`),
  `8b4d4f69e` (Prop43Translate §4 FinLayer: `translate_correctFin` — item 7 COMPLETE).
  Full `lake build` EXIT 0 (1772 jobs) at wrap-up.

## Immediate Next Action

**Phase 4c: switchover + deletions** (next sub-phase in the settled order; then 4-flip, then
Phase 5). The 4a-4..N consumer migration is COMPLETE — every scheduled Fin-variant plus the
unscheduled `Prop42NegationGeneral` gate is landed. 4c is a structurally DIFFERENT kind of work
(deleting total-alphabet lemmas, switching consumers to the Fin layer) — read the plan's Phase 4c
section before touching anything; it was deliberately NOT started in this dispatch.

## Current State

- **Prop42NegationGeneral.lean Fin layer COMPLETE** (§6.3/§6.4/§6.5 added):
  `belowFormulaFin_of_efSatFin` / `aboveFormulaFin_of_efSatFin` / `middleBracketFin_of_efSatFin` /
  `efSatFin_decompose_tl_forward` (§3 mirrors); `efSatFin_of_decompose_tl` +
  `efSatFin_decompose_tl` (§4 mirror — verbatim transcription, `efSatFin_interval_iff` exposes the
  identical six-conjunct witness shape); `prop42_efSat_negation_generalFin` (§5 mirror —
  `VVecEA2.negFix_iff`/`disj_holds`/`trivialTrue_holds` reused verbatim, TemporalPred-level).
- **EFSatNegation.lean**: `efSat_negation_pairFin` landed (M-relative capture threaded).
- **ExistsForallLemmas.lean**: `veeSatFin_append` added (§9.3, mirror of `veeSat_append`).
- **EFSatNegationGeneral.lean §8**: `efSat_negation_generalFin` landed — trichotomy reindexing
  over `pairwiseProjectionsFin`, `k>l` folded by `pairProject_swap_efSatFin`, diagonal via
  `diagProjectFin_efSat_iff`, chained `veeSatFin_append ×2 + veeSatFin_flatMap` against
  `efSatFin_negation_demorgan`; pin-mono invariant on every disjunct.
- **VeeSatNegation.lean Fin layer**: `veeSatFin_nil`/`veeSatFin_cons`/`efArbFin`(+pin_strictMono,
  `M = ∅`)/`veeSat_negationFin` (induction on the disjunct list, `veeConjFin_iff` reassembly).
- **Prop43Translate.lean §4 FinLayer (item 7) COMPLETE**: `ExistsForallFormulaFin.renamePin` +
  `efSatFin_renamePin`/`veeSatFin_renamePin`, `skelDisjunctFin_efSat`, `atomEmitFin`(+`_iff` —
  enumeration ONLY over the captured set's `M`), `strictMono_of_veeSatFin_pin_mono`,
  `ex_closure_translateFin`, `translate_correctFin` (WF-size recursion, `StrictMono ψ.pin`
  strengthening preserved, `lt` case via `skelRFin ∅`). §0 eval substrate + §2c witness
  classification reused verbatim (alphabet-independent).
- Axioms on both capstones (`translate_correctFin`, `efSat_negation_generalFin`):
  `[propext, Classical.choice, Quot.sound]` (lean_verify, no warnings).
- ZERO alphabet instances in all new Fin content; no full-alphabet `Finset.univ` (the only univs
  are `M`-relative: `UnaryTypeFin _ _ M` function spaces); totals untouched (deletions are 4c).
- Full `lake build` EXIT 0. Task-zone live sorries: exactly the 3 permitted. Vacuous defs: 0 new.
  New axioms: 0. Spine untouched (only Kamp off-path files + specs edited).
- Plan updated: 4a-4..N heading `[COMPLETED]`; items 6 and 7 checked with completion annotations.

## Key Decisions Made

1. **§3/§4 mirrors are verbatim transcriptions** under the settled substitution table
   (`efSat→efSatFin`, `efSat_interval_iff→efSatFin_interval_iff`, `efPointTP(_eval)→efPointTPFin`,
   `efIntervalSetTP(_eval)→efIntervalSetTPFin`, `ψ.intervalSet→ψ.intervalType`, drop instance
   binders). Every index computation, `set`-abbreviation, and `Fin.ext` bridge carried over
   unchanged — all seven slices compiled first-pass.
2. **`veeSatFin_append` placed in `ExistsForallLemmas.lean` §9.3** next to `veeSatFin_exists`
   (the veeSatFin home), not in a consumer file.
3. **`efArbFin` bundles `M = ∅`**: point type `fun _ => false` is vacuous over the empty
   mentioned subtype; caps `intervalTopFin ∅`; pin `Fin.castSucc` keeps the T2 strict-mono
   invariant.
4. **`translate_correctFin` `lt`-case uses `skelRFin ∅`** (the skeleton needs SOME ambient `M`;
   the empty set is the faithful choice since `lt` mentions no atoms).
5. Fin declarations in files with file-level instance binders (VeeSatNegation, Prop43Translate)
   take `section FinLayer` + fresh `{sig₀} {F₀}` variables (per the prior handoff's decision 4).

## What NOT to Try (carried forward)

- Do NOT re-derive anything in the do-not-retry list (pairProjectFin/augTargetFin_iff/
  translateProp35Fin/translateProp42Fin/weaken engine/VVecEA2 TemporalPred-level lemmas).
- EANegation charter anchors (:1090/:1249 by declaration) untouchable; KampPrior `_k+2` arm
  residual stays. Amended sorry gate = exactly these 3.
- chain_split remains non-applicable at all seven zones.
- 4c deletions must NOT begin without reading the plan's 4c prohibited list; the totals are
  still consumed by the total-alphabet assemblies until the switchover commit lands.

## Remaining Goals (plan v24, Phase 4)

- [ ] Phase 4c: switchover + deletions (next)
- [ ] Phase 4-flip: terminal summand flip
- [ ] Then Phase 5 (ζ).

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted literal sorries (`KampPrior.lean:562`
`nf_nvar_exist_all_depths | _k+2` arm; `EANegation.lean:1090`; `EANegation.lean:1249` — anchor by
declaration, positions drift). Nothing introduced this dispatch (all 7 slices sorry-free).

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
- Prior handoff: `phase-4-negstack-handoff-20260723.md` (whose Immediate Next Action this
  dispatch executed in full, then continued through the un-gated items 5-7)
- Key files: `Kamp/Prop42NegationGeneral.lean` (§6.3-6.5, this dispatch),
  `Kamp/EFSatNegation.lean` (+pairFin), `Kamp/ExistsForallLemmas.lean` (+veeSatFin_append),
  `Kamp/EFSatNegationGeneral.lean` (§8), `Kamp/VeeSatNegation.lean` (Fin layer),
  `Kamp/Prop43Translate.lean` (§4 FinLayer)
- Rabinovich anchors: Prop 4.2 (PDF p.6-7, three-piece split p.7), Prop 4.3 ¬-case + structural
  translate (p.6), Lemma 3.4 (p.5), Def 3.1 (p.4) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt).
