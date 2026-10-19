# Implementation Summary: Task #761

- **Task**: 761 - The ladder realization theorem (presentation (a), the fibre equation over `Dmax`)
- **Status**: [BLOCKED]
- **Started**: 2026-10-19T10:26:21Z
- **Completed**: 2026-10-19T10:42:51Z
- **Effort**: ~16 minutes of wall clock, one dispatch (seq 19)
- **Dependencies**: 760, 775, 805, 806, 819, 820 — all discharged
- **Artifacts**: plans/05_ladder-truth-transport-layer.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 11.1's open half — half (ii), splice invariance of the realized stab-free type — is not
open. It is FALSE as stated, and this dispatch compiled and wired the separating pair rather than
spending another attempt on it. The phase closes `[BLOCKED]` on its own declared refuting branch:
the refutation is of the PUMPING ROUTE, not of half (i) and not of the presentation.

## What Changed

- `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean` — Created. The
  forty-fifth wired probe (`Probe761S`), 19 printed theorems. Headline:
  `splice_type_invariance_refuted : ¬ SpliceTypeInvariance`, where `SpliceTypeInvariance` writes
  out half (ii) with every hypothesis the plan records (`ParamsOk`, the stab-free closure
  condition, `0 < l`, `pend (objAt g a) = true`, `l ≤ cntAt g a`,
  `objAt g a = objAt g (a + l)`, `l ∣ P + 1`, the spliced path's existence with its object and
  countdown equations, and `Tc ≤ |a - z|`). Supporting: `fwdS`/`bwdS` (seriality discharged on a
  three-state object), `exists_gS` (the walk lifted by `exists_ladderPath_of_walk`, pin side
  condition vacuous), `two_mem_objCycleLensS`/`two_dvd_PS_succ`/`paramsOkS` (the divisibility and
  the parameters discharged through `(K1)` and `paramsOk_params`), `chiS_false_of_orig`,
  `chiS_true_of_twoHits`/`chiS_true_of_spliced`, `twoHits_of_spliced`/`twoHits_iterate`/
  `spliced_rehypotheses` (the iterated surgery), and `exists_separating_splice` (the full
  separating instance with non-vacuity on both sides as conjuncts).
- `scripts/check-evidence-probes.sh` — One `WIRED` row plus its documentation block. 45 of 45
  wired probes PASS.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — The module docstring's
  "NO SPLICE INVARIANCE" bullet upgraded from "not landed" to "REFUTED, not merely absent", citing
  the probe and naming what the refutation does and does not touch. Docstring only: no declaration
  added, changed or removed.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md`, `typst/generated/status.typ` — Generated inventory blocks and the live line count
  resynced (`--emit-inventory`; `371433 → 371441`).
- `specs/761_ladder_realization_theorem/plans/05_ladder-truth-transport-layer.md` — Phase 11.1
  `[IN PROGRESS] → [BLOCKED]`, the status record replaced with the HALF (i) MET, HALF (ii) REFUTED
  record, a structured `BLOCKER` entry added, and the two unchecked checklist items re-annotated.

## Decisions

- **The refuting branch was entered instead of a third attempt at half (ii).** The plan's own
  Verification section declares this a complete, reportable outcome, so this is execution of the
  plan rather than a substitution. The decisive observation: nested `U` reads an occurrence COUNT
  at unbounded distance, so the preceding round's "distance budget per nesting depth" intelligence
  cannot work, and the counterexample it predicts is cheap to compile.
- **The refutation is checked against the ITERATED surgery, not one application.** The preceding
  round's own correction records that `kappa`'s residue coordinate returns only after `(P + 1) / l`
  repetitions, so a refutation of a single splice would have been answerable. `twoHits_iterate`
  and `spliced_rehypotheses` close that gap.
- **No library port of the refutation.** The plan's refuting branch names exactly two files for it
  (the probe, new; `check-evidence-probes.sh`, one wiring row). Porting the ~300-line object into
  `LadderAgree.lean` with its axiom-test pins would have been invented scope; the probe is the
  oracle and the module docstring is the library-side record.
- **No edit to any recorded Challenge statement.** `tpOf_stabFree_eq_of_splice` is not a pinned
  Challenge statement; `cellAt_const_of_kappa_eq`, which is, is untouched and NOT refuted by this
  probe.

## Plan Deviations

- **Phase 11.1, task "(ii) Splice invariance"** blocked: REFUTED rather than unproved. Annotated
  inline; the schema with every recorded hypothesis is refuted by
  `Probe761S.splice_type_invariance_refuted`.
- **Phase 11.1, task "Instantiate (ii) in the regime that needs no cascade"** blocked: not reached
  and now unreachable — it instantiates (ii). Annotated inline. The refuting instance is itself in
  the pending-forever regime and is produced by `exists_spliced_ladderPath_of_pend_past`, so that
  regime is where the refutation runs.
- **Process deviation, artifact numbering**: this summary is `06`, not the dispatch's pinned `04`.
  `04` is the preceding decomposition round's record and `05` the preceding dispatch's; the live
  plan is `05` and this is the second round against it.
- **Process deviation, commit scope**: `LadderAgree.lean` and the new probe are both outside the
  task's declared `file_scope`, so they are committed separately as a declared excursion (without
  `--task`), exactly as the two preceding rounds did for `LadderAgree.lean`.

## Verification

- Build: Success — full guarded `lake build` exit 0, 2892 jobs, 0 `error:` and 0 `warning:` across
  both captured streams; `LadderAgree.olean` newer than its source. Test target
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: exit 0, 2361 jobs.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: 1 — the repository's long-standing single single-line match, unchanged; the only
  `.lean` change under the source roots this dispatch is a docstring.
- Axiom count: 14 `^axiom ` occurrences, unchanged for the same reason.
- `#print axioms` on all 19 printed probe theorems: `[propext, Classical.choice, Quot.sound]`. No
  `sorryAx`, no custom axiom, no `native_decide`.
- `check-evidence-probes.sh`: exit 0, 45 of 45 wired probes PASS, no existing probe modified.
- `check-module-invariants.sh`: ALL CHECKS PASSED (exit 0), after `--emit-inventory` resynced three
  generated blocks. `typst-sync-check.sh`: PASS (all 4 checks), after the line count was resynced.
  `readme-lint.sh`: PASS. `check-task-references.sh`: 0 unexempted occurrences outside `specs/`.
- `git diff --stat` on `CounterQuotient.lean`: EMPTY. No parameter added, no parameter source
  strengthened, `ParamsOk` untouched.
- Certificate-freedom grep on `LadderAgree.lean`: zero occurrences; import list unchanged.
- Tests: Passed (the axiom-test target above).
- Files verified: Yes.

## Addendum: the blocker research, and its STEP 0 settled

The blocker research at `specs/761_ladder_realization_theorem/.blocker-research.json` landed after
this dispatch started and was relayed mid-dispatch. It is consistent with the refutation and
complementary to it: it diagnoses the pumped block as only an OBJECT cycle, not a unit of
type-invariance, and the refutation is the compiled witness that the diagnosis is right and that
the statement is false rather than merely unproved. One correction of emphasis — the research says
the repair claim `truth(g', v) ↔ truth(g, spliceIdx v)` is false inside the block; the refutation
says the stronger thing, that half (ii)'s own CONCLUSION is false.

Two things were added in response, both compiled:

- `Probe761S.splice_block_not_type_respecting` (the probe now carries 21 printed theorems): the
  refuted block's two endpoints carry the SAME object state and DIFFERENT realized types, so the
  refutation is confined to the object-cycle splice by construction rather than by silence and
  leaves a splice at a TYPE-RESPECTING block entirely open.
- `specs/761_ladder_realization_theorem/prototype/step0-budget-check.lean` — the research's STEP 0,
  the one feasibility question it says to settle before any surgery, **settled affirmatively**.
  Four theorems, all on `[propext, Classical.choice, Quot.sound]`, compiled standalone through the
  build guard. **NOT a wired probe and NOT gate-covered**; the revision should land them in the
  library. `card_prodState` is an identity, not an estimate:
  `Fintype.card (ProdState Q φ) = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card` — the type
  pigeonhole's budget IS the cardinality of the certificate product carrier — while
  `cascadeBound pend φ = 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2)` carries that budget as
  its own EXPONENT. `budget_le_Tc` then goes through `(K2)`'s `cascadeBound` conjunct ALONE, and
  `budget_le_cnt` lands it at the compared countdowns via the landed `eq_or_both_ge_of_min_eq`. No
  new parameter, no `ParamsOk` change, no raised `Tc`, and none of the prohibited certificate-side
  identifiers cited.

What STEP 0 does not settle: the research's own RISK note, that its Step 2 needs the endpoint type
equality to propagate to the block's INTERIOR positions. The fallback it names (a pigeonhole for a
loop whose interior types match pairwise) carries a LARGER budget, and the four facts above are
stated at `card (ProdState Q φ) + 1`. That re-derivation should be settled before Step 2 is built,
for the same reason STEP 0 was.

## Impacts

- Phases 11.2, 11.3 and 11.4 consume half (ii) as decomposed and cannot proceed as written;
  Phase 11.4's Goal `cellAt_const_of_kappa_eq`, and through it Phases 12-18, are gated on a route
  decision. The Goal itself is NOT refuted: a cell is the set of types realized by ALL histories
  through a state, and the probe compares two particular histories.
- The replacement layer of Phase 11 keeps its value: the refutation uses its machinery
  (`exists_ladderPath_of_walk`, `exists_spliced_ladderPath_of_pend_past`) and runs against the
  record's own surgery, so what is settled is the TYPE-BLINDNESS of that surgery, not its
  admissibility content.

## Follow-ups

- A revision of Phases 11.1-11.4 to the TYPE-RESPECTING-BLOCK route the blocker research names:
  pigeonhole on `(objAt v, tpOf v)` PAIRS so the block's endpoint types agree, then repair
  `kappa`'s residue by iterating the splice `P + 1` times rather than by `l ∣ P + 1` — which is
  what answers the objection the preceding round recorded against this route, since the iterated
  form needs no divisibility and hence no `l ≤ Fintype.card Q`. Its STEP 0 is settled above; its
  interior-propagation risk is not.
- The cell-level route (argue `cellAt_const_of_kappa_eq` over the set of all histories the Goal
  names) remains available as a fallback and is refuted by nothing.
- No estimate is offered for either, and none is to be invented.

## References

- `specs/761_ladder_realization_theorem/plans/05_ladder-truth-transport-layer.md` (live plan,
  Phase 11.1)
- `specs/761_ladder_realization_theorem/handoffs/phase-11.1-handoff-20261019T100500Z.md` (the
  preceding round, which recorded the intelligence this dispatch refuted)
- `specs/761_ladder_realization_theorem/handoffs/phase-11.1-handoff-20261019T104251Z.md` (this
  round)
- `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean` (the probe)
- `specs/761_ladder_realization_theorem/.blocker-research.json` (the blocker research relayed
  mid-dispatch)
- `specs/761_ladder_realization_theorem/prototype/step0-budget-check.lean` (STEP 0, compiled, not
  gate-covered)
- `specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md`
