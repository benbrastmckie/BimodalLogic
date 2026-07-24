# Phase 4b handoff — LiftPair Fin lifts LANDED (item-7 gating check recorded; 4b COMPLETE)

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Commits this dispatch**: 4 green commits on top of `d371e7e2e`:
  `b2de4ae3e` (4b slice 1: skelRFin + liftPairFin membership interface + item-7 gating record),
  `0b0c3f804` (4b slice 2: liftPairFin forward/backward/iff + liftPairVFin),
  `1d3fe0f69` (4b slice 3: liftSentenceFin forward/backward/iff),
  `a0a28b373` (4b slice 4: liftSingleFin family + pin-strictMono layer) —
  every slice first-pass green, per-file build at each step, full `lake build` EXIT 0
  (1772 jobs) after slice 4.

## Immediate Next Action

Per the settled sequencing recorded on the 4a-4 item-7 checklist entry, the next dispatch is
**(iii) the `EFSatNegation.lean` Fin layer**: `pairProjectFin` / `pairwiseProjectionsFin` /
`efSatFin_negation_demorgan` / `pairProject_swap_efSatFin` / `efSat_negation_pairFin`
(~110-line file, small). Then **(iv) the item-6 remainder** (`diagProjectFin` iff +
`liftSentenceV`-Fin analog + `efSat_negation_generalFin` in `EFSatNegationGeneral.lean`, then
`VeeSatNegation.lean`, then `VVecEA2Collapse.lean`), then **(v) item 7 `Prop43Translate.lean`**
(gating check DONE this dispatch: it consumes `veeSat_negation` at :596/:620/:623/:631, so it
comes after the negation stack), then 4c (switchover + deletions) and 4-flip.

## Current State

- **4a-4 item-7 gating check DONE** (recorded on the plan checklist): `Prop43Translate.lean`
  imports `VeeSatNegation` and consumes `veeSat_negation` directly — GATED like the item-6
  remainder. Settled sequencing for the Phase-4 remainder annotated inline in the plan.
- **Phase 4b COMPLETED** (marked in plan; all three checklist tasks checked with annotations).
  `LiftPair.lean` +1,087 lines, new §11 (`namespace Kamp`, `section FinLayer`, fresh variables
  `sig₀`/`F₀` dodging the file-level `[Fintype sig.preds] [DecidableEq sig.preds]` block):
  - §11.1 `exists_partialHolds` (charTypeFin/partialHolds_charTypeFin consumed from
    `PerFormulaType.lean`, not re-derived).
  - §11.2 `skelDisjunctFin`/`skelRFin`/`skelRFin_sat` — tuple skeleton over
    `Finset.univ : Finset (Fin (m+1) → UnaryTypeFin sig₀ F₀ M)`, finite from `M` alone
    (report-22 class (c) verdict held; NO return-to-gate needed); ⊤ slots `intervalTopFin M`.
  - §11.3-11.5 `liftCrossConsistentFin` (σ over `UnaryTypeFin sig₀ F₀ ξ.M` — `M`-relative
    completions, Rabinovich Lemma 3.2(1) p.4), `liftMergedPointTypeFin` (+`_xi`/`_skel`),
    `liftMergedFormulaFin` (M := ξ.M, intervals := `chainIntervalTypeFin`), `liftPairFin` +
    membership assembly + reverse extraction.
  - §11.6 `liftPairFin_forward`/`_backward`/`_iff`, `liftPairVFin`(+`_iff`).
  - §11.7 `liftSentenceFin` family (validS, no pin coincidence).
  - §11.8 `liftSingleFin` family + `liftSingleVFin`(+`_iff`).
  - §11.9 seven `_pin_strictMono` Fin mirrors (T1 invariant support for the gated
    Prop43Translate migration).
- `LiftMergePair` + `valid`/`valid1`/`validS` + Fintype/Decidable instances REUSED VERBATIM
  (pure index structures, alphabet-free) — no Fin re-declaration needed.
- ZERO alphabet instances in all §11 content; no full-alphabet `Finset.univ`.
- Axioms of `liftPairFin_iff`/`liftSentenceFin_iff`/`liftSingleVFin_iff`/`skelRFin_sat`:
  `[propext, Classical.choice, Quot.sound]` (lean_verify).
- `completeness_discrete` axioms: single `sorryAx` (KampPrior `_k+2` residual) — spine
  byte-untouched (this dispatch edited only `LiftPair.lean` + specs/).
- Kamp-zone literal sorries: exactly the 3 permitted. Full `lake build` EXIT 0.

## Key Decisions Made

1. **σ ranges over `UnaryTypeFin sig₀ F₀ ξ.M`** (the lifted formula's own mentioned set): the
   merged formula bundles `M := ξ.M` — the skeleton contributes ⊤ (`M`-free) so no `mergedM`
   union is needed, unlike ConjInterleave. This keeps every lift disjunct on ξ's own atom set.
2. **Uniqueness engine**: `partialHolds_eq_charTypeFin` replaces `nf_eval_unique` in the
   forward cross-consistency discharge (`rw [← partialHolds_eq_charTypeFin N hchold]`).
3. **`open Classical in` on Fin definitions with filters/univ** (skelRFin, liftPairFin,
   liftSentenceFin, liftSingleFin, liftMergedPointTypeFin) — the classical route confined to
   definitions, matching ConjInterleave §10; proofs open with `classical`.
4. **No Decidable instance for `liftCrossConsistentFin`** — classical filters make it
   unnecessary (the total file's Decidable instances were vestigial for the Fin layer).
5. Section shape per the item-6a handoff Decisions 2/3: `namespace Kamp` + `section FinLayer`
   + fresh `sig₀`/`F₀`; zero `omit` needed since no shared helper was touched.

## What NOT to Try (carried forward + new)

- The item-6 remainder still needs the `EFSatNegation.lean` Fin layer BEFORE
  `efSat_negation_generalFin` can assemble — do the ~110-line file first (see Immediate Next
  Action). The 4b gate (LiftPair Fin lifts) is now DISCHARGED.
- Do NOT re-derive `charTypeFin`/`partialHolds_charTypeFin` — consume from `PerFormulaType`.
- Do NOT thread alphabet instances into Fin declarations; beware `variable`-block auto-capture
  (LiftPair's block at :52 carries the instances — the fresh-variables device handled it; no
  `omit` was needed because no §1-10 helper was modified).
- All task-level prohibitions hold: no chain_split; EANegation charter anchors untouchable
  (:1090/:1249 by declaration); no full-alphabet `Finset.univ`; amended sorry gate = the 3
  permitted only; per-file-build every off-path file touched; cite Rabinovich by PDF page only.

## Remaining Goals (plan v24, Phase 4)

- [ ] `EFSatNegation.lean` Fin layer (`pairProjectFin`/`pairwiseProjectionsFin`/
      `efSatFin_negation_demorgan`/`pairProject_swap_efSatFin`/`efSat_negation_pairFin`) —
      unscheduled in the 4a-4 list; the settled sequencing inserts it here.
- [ ] Item 6 remainder: `EFSatNegationGeneral` general assembly + `VeeSatNegation` +
      `VVecEA2Collapse` Fin (now UN-gated on the LiftPair side).
- [ ] Item 7: `Prop43Translate.lean` Fin-variant (gated on the item-6 remainder; preserve the
      `StrictMono psi.pin` conclusion-strengthening — the §11.9 pin lemmas feed it).
- [ ] Phase 4c: switchover + deletions. [ ] Phase 4-flip: `sigE` summand flip. Then Phase 5.

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted literal sorries (`KampPrior.lean:562`
`nf_nvar_exist_all_depths | _k+2` arm; `EANegation.lean:1090`; `EANegation.lean:1249` — anchor
by declaration, positions drift). Nothing introduced this dispatch (all §11 content
sorry-free).

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
- Prior handoffs: `phase-4a-4-item6a-handoff-20260723.md` (the gating finding this dispatch
  actioned), `phase-4a-4-item3-handoff-20260723.md`, `phase-4a-1-handoff-20260723.md`
- Key files: `Kamp/LiftPair.lean` §11 (this dispatch), `Kamp/EFSatNegation.lean` (NEXT),
  `Kamp/EFSatNegationGeneral.lean` §5-6 (the waiting assembly), `Kamp/PerFormulaType.lean`
  (charTypeFin home), `Kamp/ConjInterleave.lean` §10.4 (slot-placement Fin mirrors consumed)
- Rabinovich anchors: Def 3.1 (p.4), Lemma 3.2(1) (p.4), Lemma 3.4 (p.5), Prop 3.5 (p.5) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt).
