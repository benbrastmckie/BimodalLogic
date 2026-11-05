# Implementation Summary: Task #878

- **Task**: 878 - Make the paper proof of L-plus ZTime decidability rigorous
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T19:16:16Z
- **Completed**: 2026-11-05T19:29:00Z
- **Effort**: ~13 minutes across 4 phases (plan estimate: 2.5 hours)
- **Dependencies**: None (the theorem it propagates is conditional on task 870's lemma, but no
  phase was gated on 870 landing)
- **Artifacts**: plans/01_propagate-ztime-decidability-proof.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This task's own deliverable — a rigorous paper proof that L⁺ validity at ZTime is decidable —
was already produced by the research dispatch and linked in `state.json`. This implementation
propagated that report's verdict into the three live records that named it as their pending
measurement: report 03 (the argument itself), report 866 (the open-modal reading), and
`specs/ROADMAP.md` (four sentences naming this task as outstanding). All edits are purely
additive markdown; no Lean file, no `FormalSystem/` or `Tests/` path, and no `.typ` chapter was
touched, honoring the dispatch's "report only" constraint.

## What Changed

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` —
  appended a dated amendment at the end of §1.3 (after the existing 2026-11-05 amendment, before
  `#### 1.4`) recording: the G1 repair (re-justification via compiled `PlusTruth.stab_state_only`
  / `PlusTruth.box_global`), the step reorder (cover first, countable model second, forced by
  `FrameOver.IsRegular` bundling `saturation`), the G2 repair (explicit new-root coding with the
  load-bearing `¬Rt(meet(y,x))` guard on `⊑`), Rabin held at Thomas 1997 Thm 6.20/6.19/6.18
  (`S2S` suffices; `SωS`/Gurevich-Shelah/Muchnik-Walukiewicz not needed), the conditional
  reinstatement of the withdrawn consequence sentence (existence of a recursive axiomatization
  closed affirmatively, Craig not needed; Craig held at Chagrov & Zakharyaschev 1997 Thm 16.10
  for the weaker r.e.-only case), and the finite-vs-regular-model sharpening. A separate note
  appended at the end of §1.2 flags that task 870's stated hypothesis (directed-path uniqueness)
  is weaker than what §1.2's own step 4 consumes (an underlying undirected forest).
- `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md` —
  appended a dated correction to finding 5: indexing witnesses by (walk, time, diamond
  subformula) does **not** give a countable closure for `▷`/`◁`, because the error is itself an
  instance of gap G1; states the mechanism (backward-ray index vs. state index) and what survives
  (step 4's encoding, the cover step).
- `specs/ROADMAP.md` — five edits answering the four pending-measurement sentences: the
  "MSO/Rabin route reaches ZTime only" ruling's closing sentence replaced with the verdict (both
  gaps repaired, Rabin held at `S2S`, theorem stated, conditional on (H5)/870, still no
  constructive `Decidable`), folding in the citable-theorem record and its four negative results;
  the "MSO decidability formalization is refused outright" entry updated to state the refusal is
  unchanged and rests on Mathlib's inventory, not on G1; both `870` run-order annotations (in
  `## Run these next` and `## Next batches`) extended with the oriented-forest hypothesis flag;
  the "Decidability before completeness" ruling given an additive r.e.-versus-recursive clause,
  original text/direction/caveat untouched. The `**Coverage appendix (uncovered tasks)**:` marker
  and everything after it are unchanged; no `## ` heading was added, removed or renamed.
- `specs/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md` —
  added a minimal `## Recommendations` section (R1: `/revise` task 870 at oriented-forest
  strength; R2: optional typst chapter write-up, not filed) to satisfy `validate-artifact.sh`'s
  required-section check, which the report lacked since its research-dispatch authoring.

## Decisions

- Completed all per-task checklist items of Phases 1-3 as single coherent writing passes (each
  phase's Tasks list is one semantic amendment unit written against one re-read of the current
  text) rather than splitting into multiple commits — each phase closed with its one phase-commit
  per the Commit-Per-Green-Substep Mandate.
- Folded Phase 3's "record the citable theorem and its negative results" task into the same edit
  as the MSO/Rabin ruling's closing-sentence replacement, since that ruling is literally the
  roadmap's framing of the L⁺-at-ZTime decidability stage.
- Left the MSO/Rabin ruling's pre-existing "`▷`/`◁` do ride step 4's encoding, at the cost of an
  amendment at step 1" sentence untouched: it was not one of the plan's four named sentences, and
  remains literally true (they do ride step 4's encoding) even though the fuller negative verdict
  now lives in report 866's corrected finding 5.
- Did not extend Phase 2's edit into report 866's Decisions items 1/3 or Recommendations R2/R3,
  which still describe the pre-correction positive verdict — out of this phase's declared
  Files-to-modify scope; recorded as an issue instead of repaired.

## Plan Deviations

- **Phase 4** (Files to modify: none): this task's own report needed a minimal
  `## Recommendations` section added to satisfy the phase's own `validate-artifact.sh`
  verification criterion. Content restates exactly the two follow-up proposals named by the plan
  itself; no new substantive claim was introduced. Recorded in Phase 4's progress file and
  annotated inline on the plan.

## Verification

- Build: N/A (no Lean file touched)
- Tests: `bash .claude/scripts/tests/run-all.sh --only test-roadmap-generation.sh,test-engine-written-state-paths-lib.sh` — exit 0 (Phase 3)
- `bash .claude/scripts/validate-artifact.sh` — exit 0 on all three reports (this task's report,
  the amended report 03, the amended report 866)
- `bash .claude/scripts/verify-deploy.sh` (full gate set, Phase 4) — exit 0, 15 checks passed, 0
  failures; one pre-existing, unrelated `WARN` (lean extension's `hard_contracts` migration note)
- Six cross-record guardrails audited across all four records (report 878, amended report 03,
  amended report 866, amended ROADMAP.md): no machine-checked/unconditional/finite-model-property/
  reopened-formalization/decidableValidZTime-covers-stab claim found; Base/Dense/RTime left open
  with the obstruction at report 03 §1.4
- No claim added by Phases 1-3 is labelled *recalled*
- Files verified: Yes (all diffs purely additive except Phase 4's one format-compliance fix)

## Impacts

- The repository now has a single, citable (though paper-level, conditional-on-(H5)) theorem that
  L⁺ validity at ZTime is decidable, with every prior gap (G1, G2) repaired and every recalled
  citation replaced by a held one.
- `specs/ROADMAP.md` no longer frames this task as a pending measurement; it states the verdict,
  and names task 870's hypothesis-strength requirement for future readers of that task.
- Report 866's finding 5 no longer claims countability survives for the open modals; a future
  reader starting from that report will not re-walk into gap G1 via that path.

## Follow-ups

- **(a)** A `/revise` of task 870 restating its hypothesis at oriented-forest strength (the
  underlying undirected graph is a forest), not merely directed-path uniqueness. Not filed by
  this task.
- **(b)** A separate task to write the theorem of report 878 finding 7 into
  `typst/chapters/p3-decidability-frontier.typ` as a citable chapter-level result, with its own
  chapter-quality gate, if the user wants it beyond the report. Not filed by this task.
- Report 866's own Decisions items 1/3 and Recommendations R2/R3 still read as describing the
  pre-correction positive verdict on L^▷ MSO decidability (flagged as an issue, not repaired —
  out of this task's declared file-touch scope for report 866).

## References

- `specs/878_lplus_ztime_decidability_paper_proof_repair/plans/01_propagate-ztime-decidability-proof.md`
- `specs/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md`
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
- `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`
- `specs/ROADMAP.md`
- Phase handoffs: `handoffs/phase-1-handoff-20261105T191851Z.md`,
  `handoffs/phase-2-handoff-20261105T192056Z.md`, `handoffs/phase-3-handoff-20261105T192420Z.md`,
  `handoffs/phase-4-handoff-20261105T192814Z.md`
