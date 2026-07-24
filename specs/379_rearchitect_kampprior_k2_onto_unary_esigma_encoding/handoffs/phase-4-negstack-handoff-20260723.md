# Phase 4 negation-stack handoff — EFSatNegation Fin core + VVecEA2Collapse Fin bridge LANDED

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Commits this dispatch**: 4 green commits on top of `474b7bd26`:
  `3cf074559` (EFSatNegation Fin layer: demorgan + swap),
  `46d13f07f` (EFSatNegationGeneral Fin: diagProjectFin + liftSentenceVFin),
  `f69a33848` (VVecEA2Collapse Fin: M-relative collapse bridge, COMPLETE),
  `047294634` (Prop42NegationGeneral Fin: clause-constructors slice) —
  every sub-step per-file green (two trivial subset-lemma fixes on 4.6b-3, rest first-pass),
  full `lake build` EXIT 0 (1772 jobs) at wrap-up.

## Immediate Next Action

**Prop42NegationGeneral.lean Fin layer, decompose slices** — the ONLY remaining gate for the
whole Phase-4 negation-stack remainder. In slice order (each its own green commit):

1. **§3 forward mirrors**: `belowFormulaFin_of_efSatFin` / `aboveFormulaFin_of_efSatFin` /
   `middleBracketFin_of_efSatFin` + `efSatFin_decompose_tl_forward` (total counterparts at
   :242/:313/:398/:521 — transcriptions on the partial relations; substitutions:
   `efSat→efSatFin`, `unaryHolds→partialHolds`, `intervalHolds→intervalHoldsFin`,
   `efPointTP→efPointTPFin`, `efIntervalSetTP→efIntervalSetTPFin`, `ψ.intervalSet→ψ.intervalType`).
2. **§4 backward mirror**: `efSatFin_of_decompose_tl` (total at :546, ~340 lines — the big one)
   + `efSatFin_decompose_tl` (:887).
3. **§5 assembly**: `prop42_efSat_negation_generalFin` (total at :989 — 25 lines once 1-2 exist;
   consumes the landed `negLeftClauseTLFin_holds`/`negRightClauseTLFin_holds`/`middleBracketFin`/
   `VVecEA2.negFix_iff` (TemporalPred-level, reused verbatim) + `efSatFin_pin_lt` (landed)).

Then, in the settled order, each now UN-gated as soon as its predecessor lands:
4. `efSat_negation_pairFin` in `EFSatNegation.lean` (mirror of :51-63: engine ∘
   `vvecea2_collapse_bridgeFin` (LANDED this dispatch) with the M-relative capture hypothesis).
5. `efSat_negation_generalFin` assembly in `EFSatNegationGeneral.lean` (mirror of :380-498;
   ALL its inputs except the pair object are landed: demorgan/swap/diagProjectFin/
   liftSentenceVFin/liftPairVFin/liftSingleVFin + iffs + pin_strictMonos +
   `efSat_negation_diagonalFin`/`efSat_negation_existenceFin`; NOTE `veeSatFin_append` does
   NOT exist yet (grep-verified) — mirror `veeSat_append` first (~15 lines);
   `veeSatFin_flatMap` is in ConjInterleave §10).
6. `VeeSatNegation.lean` Fin (147-line file, thin wrapper over 5).
7. Item 7 `Prop43Translate.lean` Fin (preserve the `StrictMono psi.pin` strengthening; §11.9
   pin lemmas + the landed pin_strictMono mirrors feed it).
Then 4c (switchover + deletions) and 4-flip.

## Current State

- **EFSatNegation.lean Fin layer**: `efSatFin_negation_demorgan` + `pairProject_swap_efSatFin`
  LANDED (via `augTargetFin_iff`; `pairProjectFin`/`pairwiseProjectionsFin`/
  `existenceSentenceFin` already existed in `ExistsForallLemmas.lean` Fin section — consumed,
  not re-derived; the item-6a handoff's 5-item list was 2/5 already done).
  `efSat_negation_pairFin` NOT landed — gated (see Dependency Finding).
- **EFSatNegationGeneral.lean**: §7 added — `diagProjectFin`(+`_efSat_iff`),
  `liftSentenceVFin`(+`_iff`, `_pin_strictMono`). The general assembly §8 remains.
- **VVecEA2Collapse.lean Fin layer COMPLETE**: `vvecea2_collapse_of_perClauseFin`/
  `_perClauseListFin`, `intervalTypeFin_captures_temporalPred`, **`intervalExpandFin`**
  (+`mem_`/`intervalHoldsFin_expandFin_iff` — the one-factor analog of `intervalGlueFin`),
  `bracket_completion_iffFin` (single ambient `M`; generic `exists_piFinset_forall_iff` reused
  verbatim), `collapseEFFin`(+`_cap`/`_translate` via `translateProp42Fin`), and
  **`vvecea2_collapse_bridgeFin`** — M-relative capture; each clause's captured sets expanded
  to the clause's ambient union `M` (4-component union: endpoints + `Finset.univ.sup` over
  point/segment formulas); per-disjunct `M`s differ freely in the output `VeeExistsForallFin`.
  Axioms `[propext, Classical.choice, Quot.sound]` (lean_verify).
- **Prop42NegationGeneral.lean §6 (FinLayer) first slice**: `negLeftClauseFin`/
  `negRightClauseFin`(+`_holds` via `translateProp35Fin_correct`), `belowFormulaFin`/
  `aboveFormulaFin`/`middleBracketFin`, `negLeftClauseTLFin`/`negRightClauseTLFin`(+`_holds`),
  `efSatFin_pin_lt`. §3/§4 decompose mirrors + final assembly remain.
- ZERO alphabet instances in all new Fin content; no full-alphabet `Finset.univ`; the file-level
  totals untouched (deletions are 4c).
- `VVecEA2Collapse.lean` gained `import …ConjInterleave` (for `weaken`/`partialHolds_weaken`/
  `partialHolds_eq_charTypeFin`/`weaken_charTypeFin`) — no cycle.
- Full `lake build` EXIT 0. Kamp-zone live sorries: exactly the 3 permitted. Vacuous defs: 0.
  New axioms: 0. Spine byte-untouched (only Kamp off-path files + specs edited).

## Dependency Finding (recorded in the plan item-6 annotation)

`efSat_negation_pairFin` mirrors `efSat_negation_pair` = `prop42_efSat_negation_general` ∘
`vvecea2_collapse_bridge`. The bridge Fin is now LANDED; the engine
(`Prop42NegationGeneral.lean`, ~1000 lines) is in NO migration list — an unscheduled gate. Its
clause layer is landed this dispatch; the §3/§4 decompose mirrors (~700 lines of transcription)
are deliberately NOT half-started (full-dispatch scale).

## Key Decisions Made

1. **`intervalExpandFin` cross-`M` device**: the M-relative capture gives per-formula `M`s, but
   one `collapseEFFin` clause needs a single `M`; expansion to the clause's ambient union
   (filter on `weaken`-restriction membership) with `intervalHoldsFin_expandFin_iff` preserving
   satisfaction (charTypeFin + `partialHolds_eq_charTypeFin` backward). Slots in ONE clause
   share the ambient `M`; different disjuncts keep their own.
2. **`bracket_completion_iffFin` over a single ambient `M`** — the caller expands first; the
   generic `exists_piFinset_forall_iff` needed no Fin variant.
3. **Subset-into-sup lemmas**: `Finset.le_sup` needs `Finset.le_iff_subset.mp` + explicit
   `(f := …)` to unify against `⊆` goals (the only RED this dispatch, fixed forward in 2 edits).
4. Section shapes: files with per-declaration binders (EFSatNegation, VVecEA2Collapse,
   Prop42NegationGeneral) take plain `section FinLayer` + per-decl `{sig} {F}` binders WITHOUT
   instances; EFSatNegationGeneral's existing fresh-variable FinLayer section extended in place.

## What NOT to Try (carried forward + new)

- Do NOT attempt `efSat_negation_pairFin`/`efSat_negation_generalFin`/`VeeSatNegation` Fin
  before `prop42_efSat_negation_generalFin` lands (Dependency Finding above).
- Do NOT half-start the §4 backward mirror (`efSat_of_decompose_tl`, ~340 lines) at low budget —
  it is one atomic proof; slice boundary is §3 (three independent lemmas) vs §4 vs §5.
- Do NOT re-derive `pairProjectFin`/`pairwiseProjectionsFin`/`augTargetFin_iff` (ExistsForallLemmas),
  `translateProp35Fin`/`efPointTPFin`/`efIntervalSetTPFin` (Prop35Assembly),
  `translateProp42Fin`(+`_correct`)/`EndpointPinnedCapTrivialFin`/`prop42_veeSatFin_negation`
  (Prop42ExistsForall), or the weaken/charTypeFin engine (ConjInterleave §10).
- `VVecEA2.negFix_iff`/`VVecEA2.disj_holds`/`VVecEA2.trivialTrue_holds` are TemporalPred-level —
  reuse verbatim in the §5 assembly mirror, NO Fin variants needed.
- All task-level prohibitions hold: no chain_split; EANegation charter anchors (:1090/:1249 by
  declaration) untouchable; no full-alphabet `Finset.univ`; amended sorry gate = the 3 permitted
  only; per-file build every touched file; cite Rabinovich by PDF page only (companion .md
  corrupt); no task-number pointers in Theories/**.

## Remaining Goals (plan v24, Phase 4)

- [ ] Prop42NegationGeneral Fin §3 forward mirrors (next dispatch, slice 1)
- [ ] Prop42NegationGeneral Fin §4 backward mirror + `efSatFin_decompose_tl` (slice 2)
- [ ] `prop42_efSat_negation_generalFin` + `efSat_negation_pairFin` (slice 3)
- [ ] `efSat_negation_generalFin` assembly + `VeeSatNegation` Fin
- [ ] Item 7 `Prop43Translate.lean` Fin
- [ ] Phase 4c switchover + deletions; Phase 4-flip; then Phase 5.

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted literal sorries (`KampPrior.lean:562`
`nf_nvar_exist_all_depths | _k+2` arm; `EANegation.lean:1090`; `EANegation.lean:1249` — anchor
by declaration, positions drift). Nothing introduced this dispatch (all new content sorry-free).

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
- Prior handoffs: `phase-4b-handoff-20260723.md` (the sequencing this dispatch executed),
  `phase-4a-4-item6a-handoff-20260723.md` (the item-6 dependency finding this dispatch extended)
- Key files: `Kamp/EFSatNegation.lean` (Fin core, this dispatch), `Kamp/VVecEA2Collapse.lean`
  FinLayer (this dispatch, COMPLETE), `Kamp/Prop42NegationGeneral.lean` §6 FinLayer (this
  dispatch, first slice; §3-4 totals at :242-897 are the transcription sources),
  `Kamp/EFSatNegationGeneral.lean` §7-8 (assembly site)
- Rabinovich anchors: Prop 4.2 (PDF p.6-7, three-piece split p.7), Prop 4.3 ¬-case (p.6),
  Def 4.1 (p.5-6), Lemma 3.2(2) (p.4) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt).
