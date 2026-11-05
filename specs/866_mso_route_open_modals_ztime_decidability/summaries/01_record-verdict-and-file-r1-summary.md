# Implementation Summary: Task #866

- **Task**: 866 - MSO route: do the open modals ride the encoding that decides L⁺ validity at ZTime?
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T06:08:26Z
- **Completed**: 2026-11-05T06:31:00Z
- **Effort**: ~45 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_record-verdict-and-file-r1.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Executed the three-phase propagation plan in full. This task's own research deliverable (a
verdict report on whether the open-future/open-past modals `▷`/`◁` ride report 03 §1.3's MSO
encoding) was already written and linked prior to this dispatch; the implementation work was
propagation, not discovery, exactly as the plan framed it. No Lean work was performed and no
new mathematical claim was made — every edit is additive `specs/**` markdown.

## What Changed

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` — appended a 53-line amendment block to the end of section 1.3 (before the `#### 1.4` heading), recording: the step-4 `▷`/`◁` translation clauses and their first-order, component-local restriction; the correction to step 1's per-state witness economy (unsound for `▷`/`◁`, countability survives on a coarser indexing); pre-existing gaps G1 (induction-scope fixpoint) and G2 (forest-vs-tree); and an explicit scope/guardrail paragraph. No existing sentence was deleted or reworded.
- `specs/ROADMAP.md` — rewrote the Stage-1 gating prose bullet on `866` from a pending-measurement framing to the settled verdict (YES at step 4, amended at step 1, ZTime only, paper result, independent of Gabbay separation and the ladder front); answered the `867` Stage-2 annotation (the MSO route makes `SeparationOver TaskFrame.IsZTime` unnecessary for the decidability question only, leaving `tr`'s expressiveness value intact); added R1 as a filing-ready prose proposal and R2 as a do-not-file note, both outside the fenced `/orchestrate` block in the `## Next batches` section. The `**Coverage appendix (uncovered tasks)**:` marker and everything after it inside the run-order section are byte-identical to their pre-edit state.

## Decisions

- Framed the step-1 witness-economy issue in report 03's amendment as a *correction* rather than
  a mere gap: the stated shift-invariance justification was never actually load-bearing for `⊡`
  either, it is simply never exercised there.
- Placed the R1/R2 roadmap prose immediately after the `## Next batches` explanatory paragraph
  (outside the fenced block, since R1 has no task number yet) rather than inside
  `## Not scoped as tasks`, matching the plan's "alongside the Stage 2 note" option.
- Honored this dispatch's Batch Gate Deferral directive in Phase 3 rather than independently
  running `verify-deploy.sh`: `suite_selection_select` on both touched paths returned
  `__FULL_SWEEP__` (no scoped suite/gate covers `specs/**` markdown content), so
  `validate-artifact.sh` — the mechanically applicable check — was run directly on both reports
  and passed, with the full gate sweep deferred to the once-per-batch stage.

## Plan Deviations

- **Task 3.5** (Phase 3's "run the complete gate set" item) altered: superseded by the dispatch's
  Batch Gate Deferral directive. See Decisions above and `progress/phase-3-progress.json`'s
  `deviations` array for the full record.

## Verification

- Build: N/A (no Lean file touched)
- Tests: N/A (no code touched)
- `validate-artifact.sh` on this task's report and on the amended report 03: both `[PASS]`, 0 warnings
- Diff read-throughs on both touched files confirmed additive-only edits (report 03: 53 insertions, 0 deletions outside the two superseded sentences in ROADMAP.md explicitly sanctioned by the plan)
- `grep -n "Coverage appendix (uncovered tasks)"` confirms the marker and the run-order section below it are unchanged
- All four dispatch guardrails confirmed by direct re-read and grep across all three records (no verification claim, no finite model property claim, no conflation with `decidableValidZTime`/`decidableDerivableZTime`, Base/Dense/RTime stated open at report 03 §1.4)
- Files verified: Yes

## Impacts

- The MSO/Rabin route is now recorded as settling L^▷ ZTime decidability (as a paper result, not
  formalized), independent of the ladder/`RaySummary` front and of Gabbay separation
  (`SeparationOver TaskFrame.IsZTime`). `867`'s Stage-2 annotation no longer poses an unresolved
  "weigh against 866 first" question — its own `tr`-expressiveness value stands independently.
- Any future attempt to make report 03 §1.3 rigorous now starts at gap G1 (the induction-scope
  fixpoint), rather than re-discovering the per-state witness economy's unsoundness.
- `specs/ROADMAP.md`'s `## Next batches` section carries R1 (the `▷`/`◁` invariance lemma, est.
  150-350 lines) as a filing-ready Lean proposal, independent of G1/G2/Rabin/Gabbay/the ladder,
  ready for a single `/task` call at the conclusion stage.

## Follow-ups

- File R1 as its own Lean task at the conclusion stage, per the settled decision in
  `.decisions.json` ("file R1 now as a separate Lean task").
- Gaps G1 and G2 remain open in report 03 §1.3 (pre-existing, not caused by the open modals);
  G1 is report 03's own recommendation R4, explicitly "not now".
- The full repository gate set (`verify-deploy.sh`) was deferred to the once-per-batch stage per
  this dispatch's Batch Gate Deferral directive rather than run independently here; its result
  attributes back to this task via `modified_files`.

## References

- `specs/866_mso_route_open_modals_ztime_decidability/plans/01_record-verdict-and-file-r1.md`
- `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
- `specs/ROADMAP.md`
- `specs/866_mso_route_open_modals_ztime_decidability/handoffs/phase-1-handoff-20261105T061500Z.md`, `phase-2-handoff-20261105T062200Z.md`, `phase-3-handoff-20261105T063000Z.md`
