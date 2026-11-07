# Implementation Plan: Task #827

- **Task**: 827 - Require a plan phase to agree with its own Scope Hypothesis and to name only artifacts that exist
- **Status**: [NOT STARTED]
- **Effort**: 2.75 hours
- **Dependencies**: 769, 772, 774 (task-level; none block this record's own `plan-format.md` edit territory)
- **Research Inputs**: specs/827_plan_self_consistency_and_artifact_existence/reports/01_plan-self-consistency-and-artifact-existence.md
- **Artifacts**: plans/01_plan-self-consistency-and-artifact-existence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Two plan-authoring truthfulness provisions land as prose in the core extension's
`context/formats/plan-format.md`, each beside the section that already owns its vocabulary: the
Scope-Hypothesis/task-list self-consistency pair sits beside "Counts-are-hypotheses obligation"
and connects backward to "Reasoned Exclusions"; the correction-target-existence pair sits inside
the `Files to modify` field documentation, which is the field whose entries name the targets in
question. Two short generation-time pointer items are added to `agents/planner-agent.md`
following the existing whole-tree-claim precedent, so both provisions reach the author at the
moment the phase is written rather than only at review time. A final phase reconciles
`index-entries.json`'s `line_count`, sweeps deliverable hygiene over the three edited files, and
redeploys to `RESULT=landed_verify_clean`.

### Research Integration

Research settled four things this plan depends on and does not re-litigate:

- **Source store resolved**: `core` resolves to `/home/benjamin/.config/nvim/agent-system/extensions/core`;
  all three edit/wiring targets exist there at the mirroring paths. Re-derive at implementation
  time rather than trusting this line, and if the store is unreachable or ambiguous, report and
  stop rather than editing the deploy tree.
- **Siting confirmed** for both items (see the per-phase anchors below), expressed as section
  names rather than line numbers, because the file's line count already moved once between
  dispatch authoring (784) and research (1020) and will move again under this plan's own edits.
- **Mechanical-check question DECIDED: no sound discrimination is buildable, and nothing is
  built.** The `Files to modify` grammar carries no structured intent signal — only an optional
  free-text annotation — and the live plan corpus shows no consistent vocabulary a keyword lint
  could key on without high false-positive and false-negative rates in both directions
  ("amendment" is already in correct live use for a pre-existing target; "update" is used
  ambiguously for both created and pre-existing targets). `plan-file-scope-harvest.sh`'s own
  header already states and defends the rejected alternative ("never filesystem-validates a
  harvested path... a creation-target path is exactly what must be harvested, not filtered
  out"), and a new plan-format field is out of scope by the dispatch's own terms. The prose-only
  outcome is therefore the complete deliverable; this decision and its reasoning belong in the
  completion summary, not inside `plan-format.md`.
- **Sibling cross-reference target**: the lean extension's `rules/plan-compliance.md` has a live
  "Statement Fidelity" section (confirmed present on disk), but the pinned-block precedence
  prose itself is not yet written anywhere. The cross-reference therefore points at that
  file/section as a *location* and states the non-transfer reasoning inline, and never cites
  prose that does not exist or the open record's task number.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no roadmap consultation performed.

## Goals & Non-Goals

**Goals**:

- State in `plan-format.md` the authoring obligation that a phase's task list is checked against
  that phase's own `**Scope Hypothesis**:` exclusions before the phase is written, and the
  implementer's rule for when the contradiction occurs anyway — as two separately checkable
  conditions, not one blurred paragraph.
- State explicitly why the pinned-block precedence reasoning from the lean extension's sibling
  rule does not transfer, with a pointer to that rule's location.
- State in `plan-format.md` the general rule that an artifact named as a correction, amendment or
  retirement target is confirmed to exist at authoring time with a stated fallback, and the
  stronger prohibition on making a phase goal turn on a dispatch-created orchestration sidecar,
  naming the durable record as the sanctioned carrier instead.
- Reach the plan author at generation time via two short `planner-agent.md` pointer items.
- Land every edit in the resolved source store, reconcile the index `line_count`, and redeploy
  clean.

**Non-Goals**:

- No mechanical check, lint, or hook is built (decided; see Research Integration above).
- No new plan-format field is added.
- No script behaviour changes: `plan-file-scope-harvest.sh`, `validate-artifact.sh`, and
  `verify-deploy.sh` are read-only here.
- The originating plan is not re-edited, and nothing in either repository is treated as broken.
- No restatement of `plan-format.md` content inside `planner-agent.md` — pointers only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Writing a guidance sentence that asserts the measured sidecar path is currently absent (the moving-quantity trap) | H | M | Every provision is written as a CLASS plus remedy, in the voice of what an author does and what an implementer does; no phase's prose names a specific path's current presence or absence. Phase 4 greps the landed prose for absence-asserting phrasing. |
| `plan-format.md`'s line count moves again before the index entry is reconciled | M | H | Phase 4 re-measures with `wc -l` on the landed file and writes that figure; no earlier figure is copied forward. The entry currently reads 1020, which matches the file *before* these edits and must not be reused. |
| Prose carries a task-number reference or record-versioning language (both forbidden outside `specs/**`) | M | M | Phase 4 runs the repo lints over the three edited files; the cross-reference names only the durable file/section location, never the open record's task number. |
| Hand-editing the deploy tree under `.claude/**` (silently wiped by the next deploy) | H | L | Every phase's `Files to modify` names source-store paths only. The store is re-derived from `.claude-extensions.json`'s per-extension `source_dir` at the start of Phase 1; the file has no top-level `source_dir` key, so a reader expecting one will not find it. |
| Two concurrent records declaring the same `plan-format.md` prose territory collide | M | M | Already expressed as a dependency edge rather than an exclusion, per the batching guardrail; the sequence is the orchestrator's to enforce, not this plan's. |
| Item 1(b) and "Reasoned Exclusions" drift into duplicated content | L | M | The existing section gains exactly one sentence of backward pointer; the new mode's content lives only in the new subsection. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Author the Scope-Hypothesis Self-Consistency Provisions [NOT STARTED]

**Goal**: `plan-format.md` carries item 1(a)'s authoring obligation and item 1(b)'s implementer
rule as two separately checkable conditions, plus the explicit non-transfer statement and the
sibling pointer, and "Reasoned Exclusions" gains a one-sentence backward pointer.

**Tasks**:

- [ ] Re-derive the `core` source store from `<project-root>/.claude-extensions.json`'s
  per-extension `source_dir` (there is no top-level key). If it is unreachable or ambiguous,
  record the issue, write a `blocked` handoff, and stop — do not fall back to editing `.claude/**`.
- [ ] Locate the `### Counts-are-hypotheses obligation` section and the
  `### Cross-phase ceiling consistency obligation` heading that follows it; the new subsection
  goes between them.
- [ ] Write the new subsection with a heading naming the self-consistency concern (not a
  task-derived name), opening with one sentence distinguishing it from the obligation above: the
  existing obligation governs a claim about the WORLD, repairable by implementation-time
  confirmation; this one governs a claim inconsistent with the plan's OWN instructions, which no
  confirmation can repair because the phase is unsatisfiable as written rather than mis-estimated.
- [ ] State condition (a), the authoring obligation, in its own labelled paragraph: a phase's
  `**Scope Hypothesis**:` and that phase's task list are two assertions by the same author about
  the same phase; an author whose Scope Hypothesis names what is deliberately EXCLUDED checks
  every task in that same phase against the exclusion before the phase is written.
- [ ] State condition (b), the implementer's rule, in its own labelled paragraph: preserve what
  the task list requires — the statement, the declaration, the thing the phase exists to produce
  — over the scope prediction; record the deviation in place with the reason; propagate any
  consequence to later phases that named the same identifiers. Include the two explicit
  prohibitions: never silently drop the task to protect the prediction, and never silently widen
  the prediction without saying so.
- [ ] Add the non-transfer paragraph: a sibling rule for a different surface pair resolves its
  contradiction by precedence, because one of its two surfaces is pinned and immutable by design
  after plan time; neither a `**Scope Hypothesis**:` nor a task list is pinned or immutable, so
  no immutability argument is available here, which is why condition (b) is argued from what the
  phase exists to produce instead. Point at the lean extension's `rules/plan-compliance.md`
  "Statement Fidelity" section by file and section name only.
- [ ] Add a one-sentence forward pointer from the new subsection to `## Reasoned Exclusions
  (format)` for the record-the-deviation half of (b).
- [ ] Add a one-sentence backward pointer in `## Reasoned Exclusions (format)`'s existing
  "Relationship to Scope Hypothesis" paragraph: alongside the overcount case it already
  describes, an exclusion record may close a Scope Hypothesis that contradicted the phase's own
  task list, with a pointer to the new subsection. Add nothing else there.
- [ ] Read the diff and confirm every changed hunk is prose, carries no task number, no
  record-versioning phrasing, and none of the originating run's declaration names or phase
  numbers.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` over
`agent-system/extensions/core/context/formats/plan-format.md` returns
`test-lean-challenge-snapshot.sh`, `test-phase-heading-patterns.sh`,
`test-plan-file-scope-harvest.sh`, `test-resume-scan-nonconformance.sh`, so the covering check is
`bash .claude/scripts/tests/run-all.sh --only test-lean-challenge-snapshot.sh,test-phase-heading-patterns.sh,test-plan-file-scope-harvest.sh,test-resume-scan-nonconformance.sh`
run alongside the `prose` row's diff read-through.

**Scope Hypothesis**: this phase is hypothesised to touch exactly two edit sites in one file —
the new subsection between the two named obligations, and one added sentence in "Reasoned
Exclusions"'s "Relationship to Scope Hypothesis" paragraph. Confirm at implementation time by
reading the diff's hunk list; if the non-transfer paragraph reads better as its own adjacent
subsection than as a paragraph inside the new one, write it that way and say so rather than
preserving the two-site prediction silently. Nothing in this phase's task list requires an edit
outside `plan-format.md`.

**Files to modify**:

- `agent-system/extensions/core/context/formats/plan-format.md` - new subsection between
  "Counts-are-hypotheses obligation" and "Cross-phase ceiling consistency obligation"; one
  added sentence in "Reasoned Exclusions"'s "Relationship to Scope Hypothesis" paragraph

**Verification**:

- Diff read-through confirms every changed hunk lies in prose with no executable surface.
- `bash .claude/scripts/tests/run-all.sh --only test-lean-challenge-snapshot.sh,test-phase-heading-patterns.sh,test-plan-file-scope-harvest.sh,test-resume-scan-nonconformance.sh`
  passes.
- Conditions (a) and (b) are separately labelled and separately checkable — a reviewer can point
  at each one independently.
- The non-transfer sentence and the `rules/plan-compliance.md` "Statement Fidelity" pointer are
  both present; no task number appears.

---

### Phase 2: Author the Correction-Target-Existence Provisions [NOT STARTED]

**Goal**: `plan-format.md` carries item 2(a)'s general confirm-at-authoring-time rule and item
2(b)'s stronger sidecar prohibition, with the durable record named as the sanctioned carrier.

**Tasks**:

- [ ] Locate the `Files to modify` field documentation's "Consumers of this field" subsection and
  the "Whole-tree-claim declaration rule" subsection that follows it; the new subsection goes
  after the consumers list, as additional authoring guidance about what an entry's annotation
  means, not a new field or a new consumer.
- [ ] State rule (a) in its own paragraph: when a plan names an existing artifact as the thing to
  CORRECT, AMEND or RETIRE — as distinct from one the phase will CREATE — the author confirms at
  authoring time that it exists, and the task says what the implementer does if it does not.
  Include the reason in one sentence: a correction task against an absent path is not a task; it
  is a sentence that cannot be executed, leaving the implementer only the choice of skipping it
  or inventing a target.
- [ ] State rule (b) in its own paragraph as the stronger prohibition: a plan MUST NOT make a
  phase's goal turn on correcting a machine-written orchestration sidecar whose existence is
  contingent on whether a particular auxiliary dispatch has run and whose content, if it appears,
  is written by that dispatch rather than by anyone the plan can consult. Name the sanctioned
  carrier for a route decision, a retirement or a withdrawn recommendation: the durable record —
  the task description in `specs/state.json`, or a file under the task's own `records/`
  directory.
- [ ] Add the one-sentence sharpest-argument line: an artifact's existence is a quantity the plan
  does not control, so a plan that assumes it is wrong the moment the quantity moves, in either
  direction. Write it as a general claim about the class; do not assert the current presence or
  absence of any specific path.
- [ ] Confirm the `.blocker-research.json` filename shape may be cited as a durable illustration
  of the sidecar CLASS only if no sentence around it asserts whether such a file is currently
  present; otherwise describe the class without the filename.
- [ ] Read the diff and confirm the new prose asserts no moving quantity as a live fact, carries
  no task number, no record-versioning phrasing, and no run-specific names or phase numbers.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` over
`agent-system/extensions/core/context/formats/plan-format.md` returns the same four suites as
Phase 1, so the covering check is
`bash .claude/scripts/tests/run-all.sh --only test-lean-challenge-snapshot.sh,test-phase-heading-patterns.sh,test-plan-file-scope-harvest.sh,test-resume-scan-nonconformance.sh`
run alongside the `prose` row's diff read-through.

**Scope Hypothesis**: this phase is hypothesised to touch exactly one file, adding one new
subsection and no edits to existing paragraphs — unlike Phase 1, no backward pointer into an
existing section is anticipated here. Confirm at implementation time by reading the diff's file
list and hunk count; if the consumers list or the whole-tree-claim subsection needs an adjoining
sentence to keep the new subsection readable in place, add it and say so rather than preserving
the one-file prediction silently.

**Files to modify**:

- `agent-system/extensions/core/context/formats/plan-format.md` - new subsection after the
  `Files to modify` "Consumers of this field" subsection

**Verification**:

- Diff read-through confirms every changed hunk lies in prose with no executable surface.
- `bash .claude/scripts/tests/run-all.sh --only test-lean-challenge-snapshot.sh,test-phase-heading-patterns.sh,test-plan-file-scope-harvest.sh,test-resume-scan-nonconformance.sh`
  passes.
- Rules (a) and (b) are separately labelled; (b) names both `specs/state.json`'s task description
  and a task's own `records/` directory as the sanctioned carriers.
- No sentence in the added prose asserts that any named path is currently absent or currently
  present.

---

### Phase 3: Add the Generation-Time Pointer Items to `planner-agent.md` [NOT STARTED]

**Goal**: the plan author meets both provisions while generating the phase, via two short pointer
items in `planner-agent.md`'s Stage 4 phase-authoring checklist, following the existing
whole-tree-claim item's shape.

**Tasks**:

- [ ] Read `agents/planner-agent.md`'s Stage 4 checklist item 9 ("Declare a Whole-Tree-Claim
  Phase Honestly") as the shape to mirror: a numbered item of one or two sentences stating the
  obligation, a `MUST NOT` bullet, and a pointer to the `plan-format.md` subsection carrying the
  full mechanism — never a restatement of it.
- [ ] Add one new numbered item for item 1(a): before writing a phase that carries a
  `**Scope Hypothesis**:` naming a deliberate exclusion, check every task in that same phase
  against the exclusion. Add a `MUST NOT` bullet forbidding a phase whose task list requires what
  its own Scope Hypothesis excludes. Point at the new `plan-format.md` subsection from Phase 1
  by section name.
- [ ] Add one new numbered item for items 2(a)/(b): confirm at authoring time that any artifact
  named as a correction, amendment or retirement target exists, and state in the task what the
  implementer does if it does not. Add a `MUST NOT` bullet forbidding a phase goal that turns on
  correcting a dispatch-created orchestration sidecar, naming the durable record as the carrier.
  Point at the new `plan-format.md` subsection from Phase 2 by section name.
- [ ] Renumber nothing that does not need renumbering: append the two items after the existing
  final checklist item rather than inserting them mid-list.
- [ ] Read the diff and confirm both items are pointer-shaped (one to two sentences plus a
  pointer), carry no task number, and duplicate no `plan-format.md` content.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` over
`agent-system/extensions/core/agents/planner-agent.md` returns
`test-plan-file-scope-harvest.sh`, so the covering check is
`bash .claude/scripts/tests/run-all.sh --only test-plan-file-scope-harvest.sh` run alongside the
`prose` row's diff read-through.

**Scope Hypothesis**: this phase is hypothesised to append exactly two numbered items to one
checklist in one file, with no renumbering of existing items. Confirm at implementation time by
reading the diff; if the checklist's existing numbering forces an insertion rather than an
append, renumber and say so rather than preserving the no-renumber prediction silently.

**Files to modify**:

- `agent-system/extensions/core/agents/planner-agent.md` - two appended numbered items in the
  Stage 4 phase-authoring checklist

**Verification**:

- Diff read-through confirms the edit is confined to the checklist's prose.
- `bash .claude/scripts/tests/run-all.sh --only test-plan-file-scope-harvest.sh` passes.
- Each new item is at most two sentences plus a `MUST NOT` bullet and a pointer; neither restates
  the `plan-format.md` subsection it points at.
- The two pointers name section headings that exist in the file as landed by Phases 1 and 2. If
  Phase 3 lands before them, the headings are the ones this plan specifies and Phase 4 re-checks
  the pointers resolve.

---

### Phase 4: Reconcile Wiring, Sweep Hygiene, Redeploy and Verify [NOT STARTED]

**Goal**: `index-entries.json`'s `line_count` agrees with the landed file, the three edited files
pass deliverable hygiene, the full gate set is green, and the deploy reports
`RESULT=landed_verify_clean`.

**Tasks**:

- [ ] Re-measure `wc -l` on the landed source-store `context/formats/plan-format.md` and write
  that exact figure into `index-entries.json`'s existing entry for `formats/plan-format.md`. Do
  not reuse any earlier figure.
- [ ] Confirm the two `planner-agent.md` pointers resolve to section headings that exist in the
  landed `plan-format.md`; correct either side if they do not.
- [ ] Grep the three edited files for task-number references and record-versioning language, and
  for absence-asserting phrasing about any named path ("does not exist", "no such file", "is
  missing", "is currently absent"). Nothing in the added prose may assert a moving quantity as a
  live fact.
- [ ] Confirm `agents/planner-agent.md` needs no `index-entries.json` entry (it is an agent
  file) and that no new context file was created; if one was created instead, add its entry plus
  at least one referrer.
- [ ] Redeploy: `timeout 540 bash .claude/scripts/deploy-headless.sh` (Bash tool `timeout`
  parameter raised to 600000, not its 120000ms default, per
  `context/patterns/external-process-wait.md` Rule 1). Confirm `RESULT=landed_verify_clean`. This
  also clears the lean extension's recorded deploy staleness.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. A selected subset does
  not discharge this phase.
- [ ] Record the mechanical-check decision in the completion summary: no sound
  correction-target-versus-creation-target discrimination is buildable from the current
  `Files to modify` grammar, and nothing was built — with the three reasons (no structured intent
  signal and no consistent corpus vocabulary; the harvester's own documented design already
  correctly treats a not-yet-existing path as a legitimate creation target, so a check flagging
  them would fire on every new-file phase; a new plan-format field is out of scope).
- [ ] Record any issues and wins from this phase via `issue-record.sh`, or attest explicitly that
  there were none.

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Scope Hypothesis**: this phase is hypothesised to change exactly one tracked value — the
`line_count` integer in one `index-entries.json` entry — with every other task being a read,
a grep, or a gate run. Confirm at implementation time by reading the diff; if a pointer
correction or a hygiene fix requires editing `plan-format.md` or `planner-agent.md` again, make
the edit and say so rather than preserving the one-value prediction silently.

**Files to modify**:

- `agent-system/extensions/core/index-entries.json` - `line_count` for
  `formats/plan-format.md` reconciled to the landed figure
- `agent-system/extensions/core/context/formats/plan-format.md` - only if a hygiene or pointer
  correction is needed
- `agent-system/extensions/core/agents/planner-agent.md` - only if a pointer correction is needed
- `__WHOLE_TREE__` - this phase invokes whole-tree regeneration via `deploy-headless.sh`

**Verification**:

- `bash .claude/scripts/verify-deploy.sh` reports the complete gate set green (this is the
  `full` tier's named check; no `--only-gate` or `--only` subset substitutes for it, and
  `--skip-slow` is not evidence that doc-sync pins hold).
- `timeout 540 bash .claude/scripts/deploy-headless.sh` reports `RESULT=landed_verify_clean`.
- `wc -l` on the landed `plan-format.md` equals `index-entries.json`'s `line_count` for
  `formats/plan-format.md`, read back after the edit.
- The hygiene greps return no task-number reference, no record-versioning phrasing, and no
  absence-asserting sentence in the three edited files.
- No file under `.claude/**` was hand-authored at any point in this plan.

## Testing & Validation

- [ ] Acceptance (1): `plan-format.md` states the authoring obligation and the implementer rule as
  two separately checkable conditions.
- [ ] Acceptance (2): the prose says explicitly why the pinned-block precedence reasoning does not
  transfer, and carries a pointer to the sibling rule's location.
- [ ] Acceptance (3): `plan-format.md` states the general correction-target-existence rule and the
  stronger sidecar prohibition, naming the durable record as the sanctioned carrier.
- [ ] Acceptance (4): the mechanical-check question is decided, with the decision and its reason
  in the completion summary; no new plan-format field was added.
- [ ] Acceptance (5): no guidance sentence asserts any named path is currently absent; no moving
  quantity is written as a live fact.
- [ ] Acceptance (6): every edit landed in the resolved source store at the mirroring path.
- [ ] Acceptance (7): `index-entries.json`'s `line_count` agrees with the file as landed.
- [ ] Acceptance (8): the prose carries no task-number references, no record-versioning language,
  and none of the run-specific declaration names or phase numbers.
- [ ] Acceptance (9): `bash .claude/scripts/deploy-headless.sh` reports
  `RESULT=landed_verify_clean`.

## Artifacts & Outputs

- Two new prose subsections in `agent-system/extensions/core/context/formats/plan-format.md`,
  plus one added sentence in its "Reasoned Exclusions" section.
- Two appended pointer items in `agent-system/extensions/core/agents/planner-agent.md`'s Stage 4
  checklist.
- A reconciled `line_count` in `agent-system/extensions/core/index-entries.json`.
- A completion summary carrying the mechanical-check decision and its reasoning.
- No new script, hook, lint, or plan-format field.

## Rollback/Contingency

Every edit is additive prose in three source-store files, all tracked by the source-store
repository's git. To revert, drop the added subsections, the added sentence, the two checklist
items, and restore the prior `line_count`, then redeploy to `RESULT=landed_verify_clean`. If the
source store is unreachable or its resolution is ambiguous at the start of Phase 1, no edit is
attempted at all: report that condition and stop, per the dispatch's own instruction, rather than
writing into the deploy tree. If the redeploy in Phase 4 does not reach
`RESULT=landed_verify_clean`, leave the source-store edits in place, record the failure, and hand
back `partial` with the deploy output rather than hand-patching anything under `.claude/**`.
