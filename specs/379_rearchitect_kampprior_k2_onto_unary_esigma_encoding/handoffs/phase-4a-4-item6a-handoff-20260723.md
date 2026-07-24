# Phase 4a-4 items 4-6a handoff — Prop35/Prop42 Fin chain landed; negation-stack core landed

- **Task**: 379 — plan v24 (`plans/24_restore-offpath-chain-then-bridge.md`)
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Commits this dispatch**: 3 green commits on top of `4e6d3fa54`:
  `90b573d6d` (item 4: Prop35 Fin layer promoted into Prop35Assembly),
  `d1f592c4d` (item 5: Prop42ExistsForall Fin variant),
  `878161a53` (item 6 first slice: EFSatNegationGeneral Fin core) — every item first-pass green
  except one predicted instance-capture RED (fixed forward in-dispatch via `omit`), per-file
  build at each step, full `lake build` EXIT 0 after each commit.

## Immediate Next Action

**Phase 4a-4 item 6 remainder + item 7 need a SCOPING DECISION first** (see Dependency Finding
below). The un-gated next moves are, in plan order:

1. **Item 7 `Prop43Translate.lean`** (`M`-relative delta-translate filter Fin-variant,
   preserving the `StrictMono psi.pin` conclusion-strengthening) — check its dependencies
   first; if it consumes `efSat_negation_general`/`veeSat_negation` it is gated like item 6's
   remainder; if it only needs the Prop35/Prop42 Fin chain (landed) it can proceed now.
2. **Phase 4b `LiftPair.lean`** (hardest, last and alone) — now ALSO carries the item-6
   remainder's gate (see below): its task list already includes the `liftPairV`/`liftSentence`
   wrappers + `_iff` lemmas.

## Dependency Finding (the item-6 scoping crux — needs plan attention)

The plan's item 6 (`EFSatNegationGeneral`/`VeeSatNegation`/`VVecEA2Collapse` Fin-variants)
CANNOT complete before 4b, and needs a file the 4a-4 list does not schedule:

- `efSat_negation_generalFin` (the assembly) consumes `liftPairV`/`liftSingleV`/`liftSentence`
  + `_iff` + `_pin_strictMono` — ALL `LiftPair.lean` content, scheduled at **4b**.
- It ALSO consumes `pairProject`/`pairwiseProjections`/`efSat_negation_demorgan`/
  `pairProject_swap_efSat`/`efSat_negation_pair` — all `EFSatNegation.lean` content, which is
  in NO migration list (it was binder-threaded green at 4a-1, but has no Fin layer).
- `VeeSatNegation.lean` consumes `efSat_negation_general` → same gates.
- `VVecEA2Collapse.lean` is a completions-machinery site (`bracket_completion_iff`,
  `exists_piFinset_forall_iff` over `Fintype ι`) — its Fin re-encode is a genuine re-proof,
  closer in kind to 4b than to the transcription items.

**Recommended resolution** (for `/revise` or the next dispatch's judgment): move the item-6
remainder AFTER 4b as "4b+ negation-stack assembly", and add an explicit
"`EFSatNegation.lean` Fin layer (`pairProjectFin`, `pairwiseProjectionsFin`,
`efSatFin_negation_demorgan`, `pairProject_swap_efSatFin`, `efSat_negation_pairFin`)" item —
either folded into 4b or as its own sub-step immediately after. What is ALREADY landed
(this dispatch) is the LiftPair-independent core, so the remainder is pure assembly once the
lifts and pair objects exist.

## Current State

- **4a-4 item 4 COMPLETED** (`90b573d6d`). `Prop35Assembly.lean` +417 lines (§5-6):
  - `RenderGate.translateProp35Fin`/`translateProp35Fin_correct` PROMOTED from
    `PerFormulaRenderProbe.lean` onto the production `ExistsForallFormulaFin` (bundled `M`) —
    NOT re-derived; the probe file is untouched and remains the gate record.
  - `efPointTPFin`/`efIntervalSetTPFin` (+`_eval`), §6 Vee lift `translateVeeProp35Fin`/
    `_correct` on `VeeExistsForallFin` (via `translateVEF1`, representation-independent).
  - `Prop35ExistsForall.lean`/`Prop35Chain.lean` needed NO edits (renderer counterpart already
    in `PerFormulaRender.lean`; chain lemmas `buildRight/Left_spec_iff_chain` carry zero
    alphabet instances) — deviation annotated in the plan.
  - The private `eval_at_foldr_disj` had its vestigial instance binders dropped (statement
    unchanged, now shared by total + Fin sections).
- **4a-4 item 5 COMPLETED** (`d1f592c4d`). `Prop42ExistsForall.lean` +401 lines (§5-8):
  `translateProp42Fin`/`EndpointPinnedCapTrivialFin`/`_forward`/`_backward`/`_correct`,
  `translateVeeProp42Fin`/`_correct`, `prop42_veeSatFin_negation`. The
  `VecEA2`/`BracketFormula`/`VVecEA2`/`negFix` target layer is TemporalPred-level, so every
  proof is the total proof with renders/satisfaction substituted (`ψ.intervalSet` →
  `ψ.intervalType`).
- **4a-4 item 6 IN PROGRESS — first slice landed** (`878161a53`). `EFSatNegationGeneral.lean`
  +213 lines (§5-6, `section FinLayer` with fresh variables `sig₀`/`F₀` to dodge the file's
  instance-carrying `variable` block):
  - `pointEF1Fin`/`pinFirstFin`/`univSentenceFin` (+`_efSat`) — caps via `intervalTopFin`.
  - `efSat_negation_diagonalFin`, `efSat_negation_existenceFin` — the two low-arity negation
    objects, via `translateProp35Fin_correct` + the **`M`-relative capture hypothesis**
    `hCapture : ∀ A, ∃ M, ∃ S : IntervalTypeFin sig F M, ∀ y, intervalHoldsFin N S y ↔
    temporal_truth N atomMap y A` (adopted this dispatch: the ONLY capture shape that exists
    without alphabet finiteness; matches the bundled-`M` design; the ζ-discharge site will
    have to supply this form).
  - `order_point_forall_iff` made instance-free via `omit [Fintype sig.preds]
    [DecidableEq sig.preds] in` (it had auto-captured the section instances; statement
    unchanged, existing callers unaffected).
  - NOT landed: `diagProjectFin` + iff (needs `pairProjectFin`), `liftSentenceV` Fin,
    `efSat_negation_generalFin` (gated per the Dependency Finding).
- ZERO alphabet instances in all new Fin content; no full-alphabet `Finset.univ`.
- Axioms of every new theorem: `[propext, Classical.choice, Quot.sound]`.
- `#print axioms completeness_discrete` unchanged (single `sorryAx` = the KampPrior `_k+2`
  residual; spine untouched — all work off-path).
- Full `lake build` EXIT 0 (1772 jobs). Kamp-zone live sorries: exactly the 3 permitted.

## Key Decisions Made

1. **`M`-relative capture hypothesis shape** (`∃ M, ∃ S : IntervalTypeFin sig F M, …`) for the
   Fin negation objects — forced by the no-alphabet-finiteness requirement + bundled-`M`
   `ExistsForallFormulaFin`; per-disjunct `M`s can differ inside one `VeeExistsForallFin`
   (it is a `List` of objects each bundling its own `M`).
2. **`section FinLayer` + fresh variable names** in files with an instance-carrying top-level
   `variable` block — prevents accidental instance capture in Fin declarations. Files with
   per-declaration binders (Prop35Assembly, Prop42ExistsForall) need no section.
3. **`omit … in` for shared instance-free helpers** rather than duplicating them into the Fin
   section (`order_point_forall_iff`; `eval_at_foldr_disj` handled by binder removal since it
   had explicit per-decl binders). Watch for the same auto-capture RED in later files with
   `variable` blocks (LiftPair has one? check before editing).
4. The item-3 handoff's conventions all held (Fin suffix, same-file additive sections,
   per-file build, `git commit -F` for hyphenated multi-line messages).

## What NOT to Try (carried forward + new)

- Do NOT attempt `efSat_negation_generalFin`/`VeeSatNegation`/`VVecEA2Collapse` Fin before the
  LiftPair Fin lifts AND an EFSatNegation Fin layer exist (Dependency Finding above).
- Do NOT re-derive promoted proofs; do NOT touch `PerFormulaRenderProbe.lean` (gate record).
- Do NOT thread `[Fintype sig.preds]`/`DecidableEq sig.preds` into any Fin-layer declaration;
  beware `variable`-block auto-capture (Decision 2/3).
- All task-level prohibitions hold: no chain_split; EANegation charter anchors (:1090/:1249 by
  declaration) untouchable; no full-alphabet `Finset.univ`; a red obligation is STOP + handoff.
- Per-file-build every off-path file touched.

## Remaining Goals (plan v24, 4a-4 checklist)

- [ ] Item 6 remainder: `EFSatNegationGeneral` general assembly + `VeeSatNegation` +
      `VVecEA2Collapse` Fin — GATED (see Dependency Finding; scoping decision needed).
- [ ] Item 7: `Prop43Translate.lean` Fin-variant (check gating first — see Immediate Next
      Action).
- Then Phase 4b (`LiftPair.lean`, + the EFSatNegation Fin layer if folded there), 4c
  (switchover + deletions), 4-flip (`sigE` summand flip), Phase 5.

## Sorry Inventory

Unchanged: exactly the 3 spine-permitted literal sorries (`KampPrior.lean:562`
`nf_nvar_exist_all_depths | _k+2` arm; `EANegation.lean:1090`; `EANegation.lean:1249` — anchor
by declaration, positions drift). Nothing introduced this dispatch (all new content
sorry-free).

## References

- Plan: `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/plans/24_restore-offpath-chain-then-bridge.md`
- Prior handoffs: `phase-4a-4-item3-handoff-20260723.md` (ConjInterleave §10 + the item-4
  promotion instruction this dispatch executed), `phase-4a-4-item2-handoff-20260723.md`,
  `phase-4a-4-handoff-20260723.md`, `phase-4a-1-handoff-20260723.md`
- Key files: `Kamp/Prop35Assembly.lean` §5-6 (this dispatch), `Kamp/Prop42ExistsForall.lean`
  §5-8 (this dispatch), `Kamp/EFSatNegationGeneral.lean` §5-6 FinLayer (this dispatch),
  `Kamp/PerFormulaRenderProbe.lean` (gate record, untouched), `Kamp/LiftPair.lean` +
  `Kamp/EFSatNegation.lean` (the item-6 gate files, NEXT after scoping)
- Rabinovich anchors: Def 3.1 (PDF p.4), Def 3.3 (p.4), Prop 3.5 (p.5), Prop 4.2 (p.6),
  Prop 4.3 ¬-case (p.6), Def 4.1 (p.5) —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (PDF pages only; companion .md corrupt).
