# Implementation Summary: Task #701

- **Task**: 701 - port_substrate_lessons_to_model_checker
- **Status**: [COMPLETED]
- **Started**: 2026-09-29T16:53:00Z
- **Completed**: 2026-09-29T18:10:00Z
- **Effort**: ~4 hours
- **Dependencies**: 696 (BimodalLogic, `completed` — verified landed in-tree, re-confirmed below)
- **Artifacts**: plans/01_substrate-lessons-for-model-checker.md, reports/01_substrate-lessons-for-model-checker.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md, no-task-references-in-deliverables.md

## Overview

This task ports the lessons of BimodalLogic task 696's landed stability-modal substrate
redesign into ModelChecker's bimodal theory, entirely by producing ready-to-file text for
ModelChecker's own task system. No ModelChecker source and no BimodalLogic source outside this
task's own `specs/` subtree was touched. The research phase found that 696 completed mid-research
(not merely was designed) and that ModelChecker's own task 200 and task 219 artifacts, though
already substantially and correctly re-scoped once by an earlier pass, are now one increment
stale against the landed tree. This implementation phase re-verifies every one of those factual
claims against the live trees at write time (Phase 1 below), then writes the corrected,
ready-to-file replacement text for task 200, a reopen-and-amend for task 219, one new
documentation-only task description, a record of two candidate items deliberately not filed, and
a phased now-versus-later proposal (Phases 2-5).

## Verification Snapshot

Re-run at implementation time (see timestamp), independently of the research report's own
snapshot, per this task's cross-repository staleness risk (the report's #1 recorded risk, and
already observed once during planning when task 703 moved from `researching` to `planning`).
Every command below was executed against the live trees during this phase; two further drifts
were found beyond what planning had already caught.

**Timestamp**: 2026-09-29T16:53Z (BimodalLogic repository); ModelChecker checks run against the
same working copy at the same wall-clock time, no separate checkout.

### BimodalLogic checks

| Check | Command | Result |
|---|---|---|
| Task 696 status | `jq -r '.active_projects[] \| select(.project_number==696) \| {status,last_updated}' specs/state.json` | `status: "completed"`, `last_updated: "2026-09-29T16:18:36Z"` — matches the research report's F0 exactly. |
| `trans*`/`Liftable` presence | `grep -n "transBack\|transMid\|transFwd\|Liftable" FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` | Present. `SharingSkeleton` (struct, line 653) carries `transBack`/`transMid`/`transFwd : List (Fin n → Fin n → Bool)` (lines 671-675) and a `lift : LiftableRaw n repBack repMid repFwd transBack transMid transFwd` field (line 689). The field is named `LiftableRaw`/`lift`, not bare `Liftable` — a naming detail, not a presence gap; `LiftableRaw` is the definition (line 316) and `lift` is the skeleton's own field name for it. |
| Gate-family examples presence | `grep -n "plusCertifies_stabSnce_example\|plusCertifies_stabUntl_example" FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` | Present. `plusCertifies_stabSnce_example : (famA p).PlusCertifies 0` at line 816; `plusCertifies_stabUntl_example : (famB p).PlusCertifies 0` at line 1192. Both are landed theorems, not archived probes. |
| Task 703 status | `jq -r '.active_projects[] \| select(.project_number==703) \| {status,last_updated,dependencies}' specs/state.json` | `status: "implementing"`, `last_updated: "2026-09-29T16:50:46Z"`, `dependencies: [695, 696]`. **Drift beyond planning**: the plan's own "Research Integration" section recorded 703 as having moved from `researching` (report time) to `planning` (plan time); it has since moved again, to `implementing`. The substance of every downstream claim ("703 supplies the compression bound; 703 is not yet complete; the blocker on task 200 narrows to 703 alone") is unaffected — `implementing` is still not `completed` — but the exact status word used in the ready-to-file text below reflects `implementing`, not `researching` or `planning`, to avoid re-propagating a now-stale status word into ModelChecker's task system. |

### BimodalLogic dangling-citation checks

| Cited name | Declaration search | Result |
|---|---|---|
| `not_plusCertifies_stabSnce` | `grep -rn "\bnot_plusCertifies_stabSnce\b" FormalSystem/` | No `theorem`/`lemma` declaration anywhere in `FormalSystem/`. Two hits, both inside `Incompleteness.lean`'s own module docstring, referring to it in past tense as a name that used to be recorded. **Dangling, confirmed.** |
| `not_plusCertifies_stabSnce_premise` | `grep -rn "\bnot_plusCertifies_stabSnce_premise\b" FormalSystem/` | One hit, inside the same docstring line as above. **Dangling, confirmed.** |
| `snce_share_congr` | `grep -rn "\bsnce_share_congr\b" FormalSystem/` | Four hits, all in prose (`Predicates.lean`, `Agreement.lean` x2, `Incompleteness.lean`), every one explicitly describing it as *retired* or as what a new theorem *replaces*. No declaration site. **Dangling, confirmed.** |

What stands in their place, confirmed present as landed declarations: `not_snce_share_congr`
(`Incompleteness.lean:115`), `not_untl_shift_share_congr` (`Incompleteness.lean:149`),
`not_plusValidZTime_stabSnce` (`Incompleteness.lean:181`), `not_plusValidZTime_stabUntl`
(`Incompleteness.lean:212`). Exactly the three dangling names the plan's Scope Hypothesis
predicted, no fourth, no reinstatement — the hypothesis holds unchanged.

### ModelChecker checks

| Check | Command | Result |
|---|---|---|
| Task 200 status | `jq -r '.active_projects[] \| select(.project_number==200) \| {status,last_updated,dependencies}' specs/state.json` (ModelChecker) | `status: "blocked"`, `last_updated: "2026-09-29T11:28:06Z"`, `dependencies: [193, 194, 197]` (ModelChecker-local numbers, already flagged as an unrelated pre-existing mismatch by the task's own current text — left uncorrected below, per that text's own scope note). |
| Task 219 status | `jq -r '.active_projects[] \| select(.project_number==219) \| {status,last_updated}' specs/state.json` (ModelChecker) | `status: "completed"`, `last_updated: "2026-09-29T15:03:54Z"`. |
| THEORY-LIMITS header block anchor | `grep -n "THEORY-LIMITS" examples.py` | Section banner at line 1335; header comment block runs 1335-1427. |
| `TL_CM_1`/`TL_CM_2` anchors | `grep -n "TL_CM_1\|TL_CM_2" examples.py` | `TL_CM_1_*` defined at lines 1429-1449; `TL_CM_2_*` defined at lines 1451-1469; both registered in `countermodel_examples` (lines 1503-1504) and `unit_tests` (lines 1613-1614). Exactly two entries, no Until-side entries anywhere in the file — confirmed by a full-file grep for `Untl`/`stabUntl`/`Fp ->`, which returns only three docstring mentions in the header's own "Box-versus-stability question" prose, none of them a probe entry. |
| `trans*` keys in wire fixtures | `grep -l "trans" tests/fixtures/certificates/*.json` | No match in any of the four fixtures (`01_positive_box.json`, `02_infinite_postponement.json`, `03_box_unfaithful.json`, `04_window_discriminator_coherence.json`). Confirms Q4's "nothing must change now" wire-level finding still holds. |

### Dangling-citation cross-check inside the THEORY-LIMITS block itself

The three dangling names are not merely dangling in the abstract — they are the exact three
names the live `examples.py` THEORY-LIMITS block currently cites as evidence for its "FACT 2"
and shape-mechanism claims: `not_plusCertifies_stabSnce` and `not_plusCertifies_stabSnce_premise`
appear in the FACT 2 comment (citing them for "the certificate class is EMPTY for this schema"),
and `snce_share_congr` appears in the shape-mechanism comment. Phase 3 below treats correcting
these three citations as a distinct defect from the framing correction, matching the plan's own
analysis.

### Net effect on the deliverable below

Every fact this deliverable asserts was re-checked against the live trees at write time, not
carried over unchecked from the research report or the plan. One status word (703's) needed
updating from what planning recorded; everything else the report and plan predicted held exactly
as stated, including the precise Scope Hypothesis of "three dangling names, no more, no fewer."
