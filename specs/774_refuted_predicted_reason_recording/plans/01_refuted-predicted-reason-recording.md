# Implementation Plan: Task #774

- **Task**: 774 - EVALUATE (AND BE WILLING TO DECLINE): should plan guidance require a refuted
  predicted REASON to be recorded distinctly from a refuted predicted OUTCOME?
- **Status**: [IMPLEMENTING]
- **Effort**: 0.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/774_refuted_predicted_reason_recording/reports/01_refuted-predicted-reason-recording.md
- **Artifacts**: plans/01_refuted-predicted-reason-recording.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md,
  source-store-deploy-boundary.md, no-task-references-in-deliverables.md,
  no-record-versioning-in-deliverables.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The research phase re-verified all four grounding findings against the live source store and
reached a **decline** verdict: no system document is edited by this task. The existing
`design-record defect or ambiguity` seed class in `context/formats/issue-log.md` already covers a
refuted predicted mechanism, the `claim_invalidations` structure in
`context/formats/return-metadata-file.md` is a cross-task forward-pointing mechanism and a type
mismatch for a same-task plan-versus-measurement divergence, and promoting `plan-accuracy` into
the 15-class seed enum is recurrence-gated by the Unknown-Class Tally mechanism the taxonomy
already documents — a bar one `minor`-severity single occurrence does not meet.

This plan therefore implements the decline, not a change. Its single phase closes the record: it
re-confirms at implement time that the decline still holds (the source store is under concurrent
edit by sibling tasks this same cycle), writes the decision and its precedent into the task's own
summary artifact so the next occurrence can be judged against stated reasoning rather than
re-litigated, and runs the final gate. **Zero files outside `specs/774_refuted_predicted_reason_recording/`
are touched; no source-store edit and no redeploy are in scope.**

### Research Integration

The research report is consumed, not re-derived. Its load-bearing contributions:

- The cited issue-log entry was read verbatim and matches the dispatch's summary word for word.
  It now lives at `specs/archive/773_ladder_cell_index_factorization/issues.jsonl` (line 6) —
  the owning task has been archived since the dispatch was composed, so the dispatch's active
  path no longer resolves. The implementer should use the archive path.
- **Grounding finding 1 confirmed and widened.** `context/formats/plan-format.md` has no
  predicted-outcome or predicted-reason field of any kind. A fifth check the dispatch did not ask
  for — a repo-wide sweep of the entire source store for "falsify-first", "predicted reason",
  "predicted outcome", "both-outcomes"/"both outcomes" — returned zero genuine hits across all
  loaded extensions (core, lean, formal, typst, literature, memory). The two string matches found
  are coincidental English usage in unrelated test comments. The falsify-first both-outcomes style
  was authored locally by the owning task, not instantiated from any documented standard, so the
  contemplated change would mean *introducing* a plan-authoring convention.
- **Grounding finding 2 confirmed.** Every "outcome" occurrence in
  `context/contracts/phase-closure.md` refers to terminal dispatch outcomes or status markers,
  never to plan predictions.
- **Grounding finding 3 confirmed, with a decisive added nuance.** `claim_invalidations` exists
  exactly as described, and its consumer `scripts/sweep-invalidated-claims.sh` matches
  `declaration_names` literally against *other tasks'* title/description. It flags a claim that
  might mislead a different task; it does not record a same-task divergence between a plan's own
  predicted mechanism and what that same implementation measured. There is no second task whose
  claim needs invalidating here. This is a type mismatch, not an awkward fit — stronger grounds
  for declining than the paraphrase-precision caveat the dispatch flagged.
- **Grounding finding 4 confirmed.** `plan-accuracy` is absent from the 15-class seed enum; the
  enum is explicitly open (`scripts/issue-record.sh` warns on an unrecognized class but never
  refuses); and the Unknown-Class Tally section names recurrence as the promotion criterion,
  assigning the tally to the conclusion stage. `design-record defect or ambiguity`'s gloss reads
  naturally over the observed case: the plan was wrong about *which* mechanism would hold even
  though it was right about the outcome.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in this dispatch's delegation fields; no ROADMAP.md consultation
was performed and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- Close the record with an explicit **decline**: no plan-format field, no new issue-log class, no
  new `.return-meta.json` field, no source-store edit at all.
- Record the decision and its reasoning durably in the task's summary artifact, in a form a
  future research dispatch can cite the way this one cited the originating issue-log entry.
- Record the forward precedent explicitly: a future refuted-predicted-mechanism finding is
  classified under `design-record defect or ambiguity` (or `plan-accuracy`, the enum being open),
  is left to the conclusion stage's cross-task tally rather than legislated against, and is not
  routed through `claim_invalidations`.
- Re-confirm the decline at implement time rather than trusting the research snapshot, because
  the source store is under concurrent edit by sibling tasks during this same cycle.

**Non-Goals**:

- No edit to any file under the resolved source store (`/home/benjamin/.config/nvim/agent-system/extensions/core`),
  and none under `.claude/**`. The dispatch's `file_scope` names deployed paths only so the
  overlap gate can see the collision surface; nothing there is an edit target in this plan.
- No redeploy. The deployed tree is independently stale for six extensions (see the Risks table);
  that staleness predates this task, is not caused by it, and regenerating the whole tree while
  sibling tasks hold live source-store edits would be a whole-tree scope claim this plan
  deliberately does not make.
- No change to the originating task's landed work, which is complete and correct — its probe
  records the right mechanism.
- No re-opening of the ladder/cell-index factorization result.
- No new issue-log class invented without applying the recurrence criterion the taxonomy already
  specifies.
- No document edit introduced merely to make the record look productive. The dispatch states
  twice that declining is a fully acceptable outcome and warns against manufacturing a change;
  that warning is honored, not worked around.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A "no change" close reads as under-delivery | L | M | The dispatch states explicitly, twice, that declining is a genuinely available and fully acceptable conclusion and warns against manufacturing a change. The deliverable the dispatch actually asked for in its Scope item (3) is written reasoning, which Phase 1 produces. |
| The four grounding findings drift between research and implement, because siblings are editing the source store this same cycle | M | L | Phase 1 re-greps the four load-bearing claims against the live source store before attesting, rather than trusting the research snapshot. The nearest sibling (lean plan-authoring gate-collision guidance) touches a different extension and a different document, so a genuine collision is unlikely but is checked, not assumed. |
| The final `full` gate fails on pre-existing deploy staleness and is misread as this task's regression | M | M | This task changes nothing outside `specs/774_refuted_predicted_reason_recording/`, so by construction any gate failure is pre-existing or sibling-caused. Phase 1's verification criteria require confirming that `git status --porcelain` shows no modification outside this task's own directory before attributing any gate failure, and require reporting such a failure rather than repairing it here. |
| The precedent lives only in a `specs/**` artifact and a future implementer never finds it | M | M | Accepted deliberately, with the alternative stated: a system-document edit was considered and declined because it would introduce standing guidance from a single minor occurrence — exactly the manufactured change the dispatch warns against. The Unknown-Class Tally mechanism, which already runs across tasks, is the intended discovery path for the second occurrence; this record is what that occurrence gets judged against. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Re-confirm the decline, record the decision and precedent, close [COMPLETED]

**Goal**: Attest at implement time that no in-tree change is warranted, write the decision and
its forward precedent into the task's summary artifact, and close the record with the final gate
run.

**Tasks**:

- [x] Read the originating issue-log entry verbatim at its live location,
  `specs/archive/773_ladder_cell_index_factorization/issues.jsonl` (grep for
  `iss_1791780659461_iJw5zy`). Confirm `class: plan-accuracy`, `severity: minor`,
  `phase: implement`, `resolution: null`, `evidence_path: null`, `suggested_channel: null`.
- [x] Re-confirm grounding finding 1 against the live source store: grep
  `agent-system/extensions/core/context/formats/plan-format.md` for `predict`, `expected
  outcome`, `both-outcome`, `falsify` and confirm the per-phase required-field list is still
  Goal / Tasks / Timing / Depends on / Verification Tier (+ optional Commit Mode and conditional
  Scope Hypothesis / Tier Justification / Files to modify), with no predicted-outcome field.
- [x] Re-confirm grounding finding 2: confirm every `outcome` occurrence in
  `agent-system/extensions/core/context/contracts/phase-closure.md` still refers to terminal
  dispatch outcomes or status markers, not plan predictions.
- [x] Re-confirm grounding finding 3: confirm `claim_invalidations` in
  `agent-system/extensions/core/context/formats/return-metadata-file.md` still carries the four
  documented keys and that its consumer `scripts/sweep-invalidated-claims.sh` still matches
  `declaration_names` literally against other tasks' title/description.
- [x] Re-confirm grounding finding 4: confirm the Seed Class Enum in
  `agent-system/extensions/core/context/formats/issue-log.md` still lists exactly 15 classes with
  `plan-accuracy` absent, that the Extensibility Rule still makes `class` an open vocabulary, and
  that the Unknown-Class Tally still names recurrence as the promotion criterion.
- [x] If any of the five re-confirmations fails, STOP and report the divergence rather than *(completed: all five re-confirmations passed; no divergence found)*
  proceeding to attest — a changed premise invalidates the decline and the record needs
  re-deciding, not closing.
- [x] Write `specs/774_refuted_predicted_reason_recording/summaries/01_refuted-predicted-reason-recording-summary.md`
  recording: the decline verdict; the four re-confirmed grounding findings and the fifth
  source-store-wide sweep; the three reasons the contemplated change is declined (it would
  introduce rather than tighten a convention; `claim_invalidations` is a cross-task mechanism and
  a type mismatch for a same-task divergence; seed-enum promotion is recurrence-gated and this is
  one occurrence); and the forward precedent for the next occurrence.
- [x] Verify `git status --porcelain` reports no modification outside
  `specs/774_refuted_predicted_reason_recording/`, confirming the zero-in-tree-change claim.
- [x] Record the dispatch's issue-log entries as they arise via
  `bash .claude/scripts/issue-record.sh`, including an explicit attestation entry if this phase
  genuinely has nothing else to record.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that exactly one file is created
(`summaries/01_refuted-predicted-reason-recording-summary.md`) and that zero files outside
`specs/774_refuted_predicted_reason_recording/` are modified. Confirm by `git status --porcelain`
after the summary is written: the only non-`specs/774_*` entries should be the sibling tasks'
own in-flight paths named in this dispatch's Territory block, never a path this task touched.

**Files to modify**:

- `specs/774_refuted_predicted_reason_recording/summaries/01_refuted-predicted-reason-recording-summary.md` - created; records the decline verdict, the re-confirmed grounding, and the forward precedent

**Verification**:

- All five re-confirmation greps above pass, each against the live source store rather than the
  research snapshot.
- The summary artifact exists, is non-empty, and states the decline verdict, the declining
  reasons, and the forward precedent explicitly.
- `bash .claude/scripts/validate-artifact.sh specs/774_refuted_predicted_reason_recording/summaries/01_refuted-predicted-reason-recording-summary.md summary`
  exits 0 (exit status checked, not stdout diffed).
- The complete gate set runs green: `bash .claude/scripts/verify-deploy.sh`. This is the final
  phase, so the gate set is not narrowed — neither `--only-gate` nor `--skip-slow` is a
  substitute here. Because this task modifies nothing outside its own `specs/**` directory, a
  gate failure is by construction pre-existing (the deployed tree is independently stale for
  core, formal, lean, literature, memory and typst) or sibling-caused; such a failure is reported
  with its output, together with the `git status --porcelain` evidence that no file outside this
  task's directory was touched, and is NOT repaired inside this task.
- `git status --porcelain` shows no modification attributable to this task outside
  `specs/774_refuted_predicted_reason_recording/`.

---

## Testing & Validation

- [x] The originating issue-log entry is read verbatim at its archive path and matches the
  dispatch's summary.
- [x] Each of the four grounding findings is independently re-confirmed against the live source
  store, with the grep that confirmed it named.
- [x] The summary artifact passes `validate-artifact.sh` with exit status 0.
- [x] `bash .claude/scripts/verify-deploy.sh` is run and its result reported; any failure is
  attributed with evidence rather than repaired here. *(deviation: altered — per this phase's
  Batch Gate Deferral directive, the full gate is deferred to the once-per-invocation batch
  stage rather than independently run in this dispatch; this task touches nothing outside its
  own specs/** directory)*
- [x] No file under `agent-system/extensions/**` or `.claude/**` is modified by this task.

## Artifacts & Outputs

- `specs/774_refuted_predicted_reason_recording/plans/01_refuted-predicted-reason-recording.md`
  (this plan)
- `specs/774_refuted_predicted_reason_recording/summaries/01_refuted-predicted-reason-recording-summary.md`
  (the decline record and the forward precedent — the task's substantive deliverable)
- `specs/774_refuted_predicted_reason_recording/issues.jsonl` (appended entries, capture only)
- No in-tree deliverable. That absence is the decision, not an omission.

## Rollback/Contingency

Rollback is trivial by construction: the only file this plan creates is a new summary artifact
under this task's own directory, so reverting means deleting that one untracked file. No
source-store edit, no deployed-tree edit, and no redeploy occurs, so there is nothing for a
sibling task or a later deploy to collide with.

Contingency, if a re-confirmation grep fails and a grounding premise has genuinely changed: do
not close. Report the specific divergence (which finding, which file, what changed) and leave the
record open for re-decision, because the decline rests on those premises and a changed premise
means the question has not been answered. Do not substitute a document edit to salvage the
close — the dispatch's warning against manufacturing a change applies to that salvage move too.
