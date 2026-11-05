# Implementation Plan: Task #769

- **Task**: 769 - plan-format: blocked decision gates and plan-level Status ownership
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/769_plan_format_blocked_gate_and_status_ownership/reports/01_blocked-gate-and-status-ownership.md
- **Artifacts**: plans/01_blocked-gate-and-status-ownership.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add two prose provisions to `context/formats/plan-format.md`, each closing a documented
ambiguity confirmed by research: one admitting a decision-gate phase that is already `[BLOCKED]`
when the plan is authored and reconciling it against the file's own final-phase
transitive-dependency rule, and one stating that the plan-level `- **Status**:` field is owned by
`update-plan-status.sh` and must never be set from a phase checklist item, with a sanctioned
alternative. Both edits land in the `core` extension's source store
(`/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md`) per
`.claude/rules/source-store-deploy-boundary.md`, then reach the deployed tree through
`deploy-headless.sh`. Definition of done: a reader of `plan-format.md` alone can settle both
questions, the deploy lands clean, and no mechanical consumer of the phase-marker enum or the
`### Phase N: {name} [STATUS]` heading contract is touched.

### Research Integration

The research report settles every open question this plan would otherwise have to resolve at
implement time, and its findings are carried into the phases below rather than re-derived:

- **Both gaps confirmed by direct read.** The "Decision gates and contingency branches"
  subsection covers only a gate that *executes and measures inside* the plan; it is silent on a
  gate already measured and failed before any phase runs. The "Plan-level vs. phase-level
  markers" subsection documents the two status vocabularies but never names a write owner for
  the plan-level field.
- **The exact prose is drafted** in the report's Decisions 1 and 2, and the phases below adopt it
  as the normative content to land. The implementer may smooth phrasing but must not weaken the
  normative claims enumerated in each phase's verification criteria.
- **Both insertion points are pinned by surrounding verbatim text**, not by line number: Provision
  1 goes after the paragraph beginning "**Do not leave the bypassed phases `[NOT STARTED]`.**" and
  before `## Status Marker Requirements`; Provision 2 goes after the four-bullet vocabulary list
  under "Plan-level vs. phase-level markers" and before
  `#### Trailing annotations on the plan-level Status line`.
- **Provision 1's shape comes from an archived precedent** that resolved the same conflict ad hoc:
  the blocked gate sat in wave 1 with `Depends on: none` beside the first executable phase, and
  the final phase's `full`-tier verification re-observed the gate's own measurement through the
  wired probe instead of depending on it. Provision 1 generalizes exactly that mechanism:
  exemption from the literal depends-on edge, discharged by re-observation inside the final
  phase's own verification criteria.
- **`context/contracts/plan-status-ownership.md` already asserts** that `plan-format.md`'s
  "Plan-level vs. phase-level markers" subsection is the authority for the ownership split. It
  currently is not. Provision 2 closes that existing forward reference at the exact location the
  fragment points at, rather than introducing a new concept or a second home for the rule.
- **`agents/planner-agent.md` is dropped from the edit set** on the report's Decision 3: its
  plan-authoring template contains no instruction or example that invites a
  plan-level-Status-setting checklist item, the originating defect was freeform phase-body prose
  for one task rather than a template default, and the file already instructs following
  `plan-format.md` structure exactly while always loading it. The dispatch required this
  ambiguity be resolved one way or the other; it is resolved here as "`plan-format.md` alone is
  sufficient", so the planner-agent path is intentionally absent from every phase's edit set
  below.
- **Staleness check**: the `core` extension is flagged stale overall, but both candidate edit
  targets were confirmed byte-identical between the deployed tree and the source store, so no
  pre-edit reconciliation is needed. Phase 1 re-confirms this for the one file actually edited.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was provided in this dispatch; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- A reader of `plan-format.md` alone can determine whether a plan containing a pre-decided
  `[BLOCKED]` decision gate conforms, and can predict where that gate sits in the wave table.
- A reader of `plan-format.md` alone can determine that the plan-level `- **Status**:` field is
  not writable from a phase checklist item, and can find the sanctioned alternative for a plan
  expected to come to rest at `[BLOCKED]`.
- Provision 1 reconciles the blocked gate against the final-phase transitive-dependency rule
  explicitly, so a plan validator and a human reader reach the same verdict.
- Both edits land at the source store and reach the deployed tree through a clean deploy.

**Non-Goals**:

- No change to the closed six-value phase-heading enum or the
  `### Phase N: {name} [STATUS]` heading contract.
- No change to any mechanical consumer (`update-phase-status.sh`, `update-plan-status.sh`,
  `update-task-status.sh --phase-check`, `plan-file-scope-harvest.sh`).
- No change to the plan-level six-value `Status` vocabulary or its trailing-annotation rule.
- No edit to `agents/planner-agent.md` (resolved: `plan-format.md` alone is sufficient).
- No edit to `context/contracts/plan-status-ownership.md` or
  `context/standards/status-markers.md`; both are cited, not restated or amended.
- No new context file; both provisions land inside the existing canonical home.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Provision 1's "re-observe by name" requirement reads as advisory and plans keep skipping it | M | L | Land it as a MUST scoped to the final phase's own verification criteria, with the wave-table note also a MUST; Phase 1 verification reads the inserted text back for both MUSTs |
| Provision 2's wording is read as restating `status-markers.md`'s target-argument / resting-state rule, contradicting acceptance criterion (3) | M | L | Keep the citation scoped to "invoked from `update-task-status.sh` postflight" only — the phrasing the canonical ownership fragment already uses — with no target-argument language; Phase 2 verification greps the inserted text for any target-argument wording |
| A paragraph lands in the wrong subsection, muddying which gate shape governs which rule | L | L | Both insertion points are pinned by verbatim surrounding text, not line number; each phase verifies the paragraph's position relative to its named anchors |
| The inserted prose trips the no-task-references or record-versioning lints (both files are outside `specs/**`) | M | L | Drafts use durable anchors only (file names, section headings, script names); Phase 3 runs both lints via the gate set |
| A hand edit is made under `.claude/**` instead of the source store and is wiped by the next deploy | H | L | Every phase's edit target is the absolute source-store path; Phase 3 confirms the change is present in the deployed tree only as deploy output, never as a hand edit |
| Deploy reports a result other than `landed_verify_clean` | M | L | Phase 3 treats any other RESULT as blocking, reports it verbatim in the handoff, and does not hand-patch `.claude/**` as a substitute |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. Provisions 1 and 2 are logically independent
and could land in either order, but they edit two regions of the **same file**, so they are
serialized into separate waves rather than placed in one wave: same-file concurrent edits are
exactly the collision the wave model's parallelism promise would otherwise invite. Phase 3 is the
final phase; it depends on 2 and transitively on 1, and its `full` gate observes both provisions
through the deployed tree.

---

### Phase 1: Provision 1 -- blocked decision gate reconciled with the final-phase rule [COMPLETED]

**Goal**: Add one paragraph to `plan-format.md`'s "Decision gates and contingency branches"
subsection admitting a decision gate already `[BLOCKED]` at plan-authoring time and stating
explicitly how it relates to the final phase's transitive-dependency requirement.

**Tasks**:

- [x] Resolve `source_dir` for the `core` extension from
      `/home/benjamin/Projects/BimodalLogic/.claude-extensions.json` and confirm it is
      `/home/benjamin/.config/nvim/agent-system/extensions/core`. *(completed)*
- [x] Confirm the deployed `.claude/context/formats/plan-format.md` and the source-store copy are
      still byte-identical (`diff -q`); if they have diverged since research, stop and report
      rather than overwriting either copy. *(completed: diff -q reported no difference)*
- [x] Locate the insertion point by verbatim anchor: the paragraph beginning
      `**Do not leave the bypassed phases `[NOT STARTED]`.**` inside
      `### Decision gates and contingency branches`, immediately before the
      `## Status Marker Requirements` heading. *(completed)*
- [x] Insert one new paragraph there (not an edit to the existing worked example) carrying the
      normative content drafted in the research report's Decision 1: a gate already `[BLOCKED]`
      at plan-authoring time is exempt from the literal depends-on edge that the final phase's
      transitive-dependency rule would otherwise require, because no executable phase may depend
      on a phase that will never complete; such a gate is placed in wave 1 with
      `Depends on: none` alongside the plan's first executable phase; in exchange the final phase
      MUST re-observe the blocked gate's own measurement by name inside its own verification
      criteria, and the Dependency Analysis wave-table note MUST say so explicitly. *(completed)*
- [x] Ensure the paragraph closes by distinguishing its own case (a gate already `[BLOCKED]` when
      the plan is written) from the subsection's existing worked example (a gate that executes
      and is measured inside the same plan), so the two shapes are not conflated. *(completed)*
- [x] Re-read the inserted hunk and confirm it names the final-phase rule explicitly — a
      provision that permits the shape without reconciling it against that rule leaves the
      ambiguity in place and does not satisfy this phase. *(completed)*
- [x] Confirm the inserted prose carries no task-number reference and no record-versioning
      language (durable anchors only: file names, section headings, script names). *(completed)*
- [x] Run the Phase 1 covering check *(deviation: altered — the plan's exact invocation
      `verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system/extensions/core`
      errors (exit 2, "no deploy tree") because `verify-deploy.sh` requires TARGET to be the nvim
      config repo root, which contains both `agent-system/extensions/` and `.claude/` — not the
      `core` extension's own source-store subdirectory. Ran with
      `TARGET=/home/benjamin/.config/nvim` instead; also ran
      `generate-context-line-counts.sh --write` there first to clear a transient gate-3 line-count
      mismatch the new paragraph introduced (self-healing, normally cleared by
      `deploy-headless.sh` before every deploy). Both gates then passed clean. Logged as an issue,
      entry class `plan-contract-conflict`.)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly one file is edited
(`/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md`) and
exactly one new paragraph is added, with no change to the existing worked example or to the
`## Status Marker Requirements` heading. Confirm at implement time with `git diff` (or `diff`
against the pre-edit deployed copy) showing a single added hunk inside the
`### Decision gates and contingency branches` subsection.

**Tier Justification**: `prose` covers a pure-prose insertion into a guidance markdown file with
no executable surface, and the covering check for this source-store, non-`specs/**` markdown edit
is `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system/extensions/core`
(doc-lint plus task-reference lint, with the explicit source-store `TARGET` the no-argument form
would skip).

**Files to modify**:

- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md` -
  one new paragraph appended to the `### Decision gates and contingency branches` subsection.

**Verification**:

- Diff read-through confirming the single added hunk lies entirely inside the
  `### Decision gates and contingency branches` subsection, above
  `## Status Marker Requirements`, and changes no surrounding line.
- `grep` the inserted paragraph and confirm it asserts all four normative elements: the exemption
  from the literal depends-on edge, the wave-1 / `Depends on: none` placement, the final phase's
  MUST to re-observe the gate's measurement by name in its own verification criteria, and the
  wave-table note's MUST.
- `grep` the inserted paragraph and confirm it does not introduce or alter any phase-heading
  marker value, and does not mention `update-phase-status.sh`, `update-plan-status.sh`, or
  `update-task-status.sh --phase-check` in a way that changes their contract.
- `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system/extensions/core`
  passes (doc-lint and task-reference lint over the source store).

---

### Phase 2: Provision 2 -- plan-level Status field ownership and its sanctioned alternative [COMPLETED]

**Goal**: Add one paragraph to `plan-format.md`'s "Plan-level vs. phase-level markers" subsection
stating that the plan-level `- **Status**:` field is owned by `update-plan-status.sh`, that no
phase checklist item or verification criterion may instruct a writer to set it, and what a
planner writes instead when a plan is expected to come to rest at `[BLOCKED]`.

**Tasks**:

- [x] Locate the insertion point by verbatim anchor: immediately after the four-bullet status
      vocabulary list under `### Plan-level vs. phase-level markers` (the bullet ending with the
      cross-reference to `status-markers.md`'s `[COMPLETED WITH EXCLUSIONS]` subsection) and
      immediately before `#### Trailing annotations on the plan-level Status line`. *(completed)*
- [x] Insert one new paragraph there carrying the normative content drafted in the research
      report's Decision 2: the plan-level `- **Status**:` field is owned by
      `update-plan-status.sh`, invoked from `update-task-status.sh` postflight, and never by a
      phase's own checklist, verification criteria, or other phase-body prose; no phase
      `**Tasks**:` item or `**Verification**:` criterion may instruct a writer to hand-set it; an
      implementation agent's refusal of such an instruction (per
      `context/contracts/plan-status-ownership.md`) is exactly correct, and the defect lies in
      authoring the instruction at all. *(completed)*
- [x] Include the sanctioned alternative in the same paragraph — the clause is load-bearing, since
      a prohibition with no alternative will be worked around: when a plan is expected to come to
      rest at `[BLOCKED]`, mark the relevant phase heading `[BLOCKED]` (or close bypassed phases
      `[COMPLETED WITH EXCLUSIONS]` with their `#### Reasoned Exclusions` record, whichever shape
      the plan calls for), and let the implementer's return (`.return-meta.json` status, the
      handoff's `blockers[]`) carry the outcome forward for postflight to stamp. *(completed)*
- [x] Cross-reference the Provision 1 paragraph from Phase 1 by section name ("Decision gates and
      contingency branches") as the example of a plan containing a pre-decided `[BLOCKED]` gate,
      so the two provisions read as one coherent rule. *(completed)*
- [x] Confirm the inserted prose cites only "invoked from `update-task-status.sh` postflight" and
      introduces no target-argument / resting-state language, leaving
      `context/standards/status-markers.md`'s "Target Arguments vs. Resting States" distinction
      textually intact and unduplicated. *(completed: grep -niE "target argument|resting state"
      returns nothing)*
- [x] Confirm the inserted prose does not alter the plan-level six-value `Status` vocabulary, the
      `#### Trailing annotations on the plan-level Status line` rule, or the phase-heading enum.
      *(completed: diff shows no change outside the single added hunk)*
- [x] Confirm the inserted prose carries no task-number reference and no record-versioning
      language. *(completed)*
- [x] Record in the implementation notes that `agents/planner-agent.md` is deliberately NOT edited
      (the report's Decision 3: its template invites no such checklist item, and the
      `plan-format.md` rule governs every plan author uniformly). *(completed: recorded here per
      plan — agents/planner-agent.md is intentionally untouched by this task)*
- [x] Ran the Phase 2 covering check with `TARGET=/home/benjamin/.config/nvim` (same corrected
      invocation as Phase 1's deviation; `generate-context-line-counts.sh --write` run first) —
      both gates passed clean. *(completed)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly one file is edited (the same source-store `plan-format.md` Phase 1
touched) and exactly one new paragraph is added, with no change to the four-bullet vocabulary
list above it or the `#### Trailing annotations on the plan-level Status line` subsection below
it. Confirm at implement time with a `git diff` / `diff` showing a single added hunk between
those two anchors.

**Tier Justification**: `prose` covers a pure-prose insertion into a guidance markdown file with
no executable surface, and the covering check for this source-store, non-`specs/**` markdown edit
is `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system/extensions/core`
(doc-lint plus task-reference lint, with the explicit source-store `TARGET`).

**Files to modify**:

- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md` -
  one new paragraph inserted into the `### Plan-level vs. phase-level markers` subsection.

**Verification**:

- Diff read-through confirming the single added hunk lies between the four-bullet vocabulary list
  and `#### Trailing annotations on the plan-level Status line`, and changes no surrounding line.
- `grep` the inserted paragraph and confirm all three normative elements are present: the named
  owner (`update-plan-status.sh`, invoked from `update-task-status.sh` postflight), the
  prohibition on any phase checklist item or verification criterion setting the field, and the
  sanctioned alternative (mark the phase heading; let the implementer's return carry the outcome
  for postflight to stamp).
- A `grep -niE "target argument|resting state"` over the inserted hunk returns nothing,
  confirming no duplication of or conflict with `status-markers.md`'s own distinction.
- `grep` confirms the plan-level six-value vocabulary bullets and the trailing-annotation rule are
  byte-unchanged.
- `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system/extensions/core`
  passes.

---

### Phase 3: Deploy, verify the full gate set, and confirm both provisions read correctly from the deployed tree [NOT STARTED]

**Goal**: Land both provisions in the deployed `.claude/` tree through the sanctioned deploy path,
confirm `RESULT=landed_verify_clean`, run the complete gate set, and confirm the two acceptance
criteria hold for a reader of the deployed `plan-format.md` alone.

**Tasks**:

- [ ] Run `timeout 540 bash /home/benjamin/Projects/BimodalLogic/.claude/scripts/deploy-headless.sh`
      with the Bash tool `timeout` parameter raised to 600000 (not its 120000 ms default), per
      `context/patterns/external-process-wait.md` Rule 1.
- [ ] Confirm the deploy reports `RESULT=landed_verify_clean`. Any other RESULT is blocking:
      report it verbatim in the handoff's `blockers[]` and do NOT hand-patch any file under
      `.claude/**` as a substitute, which would mask the divergence instead of fixing it.
- [ ] Confirm `diff -q` between the source-store `plan-format.md` and the deployed
      `.claude/context/formats/plan-format.md` reports no difference, i.e. both paragraphs reached
      the deployed tree as deploy output rather than as a hand edit.
- [ ] Run the complete gate set: `bash /home/benjamin/Projects/BimodalLogic/.claude/scripts/verify-deploy.sh`.
- [ ] Run `bash /home/benjamin/Projects/BimodalLogic/.claude/scripts/check-task-references.sh` and
      `bash /home/benjamin/Projects/BimodalLogic/.claude/scripts/check-record-versioning.sh`;
      confirm no BLOCKING finding attributable to either new paragraph (advisory
      record-versioning findings never affect exit status and are reported, not fixed, unless
      they name one of the two new hunks).
- [ ] Run `bash /home/benjamin/Projects/BimodalLogic/.claude/scripts/validate-state.sh` and confirm
      no new finding attributable to this record — in particular no coarse-declaration finding
      arising from this plan's `Files to modify` declarations.
- [ ] Acceptance read-through of the deployed `plan-format.md`, reading only that file: determine
      (a) whether a plan containing a pre-decided `[BLOCKED]` gate conforms and where that gate
      sits in the wave table, and (b) that the plan-level `Status` field is not writable from a
      phase checklist item, together with the sanctioned alternative. Record both verdicts in the
      handoff summary.
- [ ] Confirm by read-through that neither new paragraph contradicts
      `context/contracts/plan-status-ownership.md` or `context/standards/status-markers.md`, and
      that status-markers.md's target-argument / resting-state distinction is intact.
- [ ] Confirm no change to the six-value phase-heading enum, the `### Phase N: {name} [STATUS]`
      heading contract, or any of the three mechanical consumers of that contract.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the deploy's only `plan-format.md` delta in the deployed tree is the two
paragraphs added by Phases 1 and 2; the deploy regenerates the whole tree, so other deployed
files may legitimately change as a consequence of the pre-existing `core` staleness flagged in
this dispatch. Confirm at implement time by diffing the deployed `plan-format.md` against its
pre-deploy state and by reading the deploy's own summary of what it regenerated; report any
unexpected `plan-format.md` delta rather than absorbing it silently.

**Files to modify**:

- `__WHOLE_TREE__` - this phase invokes whole-tree regeneration via `deploy-headless.sh`, which
  is an implicit scope claim over the entire deployed tree that no real declared path can
  express.
- `/home/benjamin/Projects/BimodalLogic/.claude/context/formats/plan-format.md` - updated as
  deploy output only, never by hand.

**Verification**:

- `deploy-headless.sh` reports `RESULT=landed_verify_clean`.
- `bash .claude/scripts/verify-deploy.sh` (the complete gate set, no `--skip-slow`, no
  `--only-gate` narrowing) exits clean. This is the final phase's `full` tier: the full battery
  runs, and no cheaper subset from Phases 1 and 2 is read as discharging it.
- `bash .claude/scripts/check-task-references.sh` exits 0.
- `bash .claude/scripts/check-record-versioning.sh` reports no BLOCKING finding.
- `bash .claude/scripts/validate-state.sh` reports no new finding attributable to this record.
- `diff -q` between the source-store and deployed `plan-format.md` reports no difference.
- Re-observation of both provisions' acceptance criteria by reading the deployed
  `plan-format.md` alone, with both verdicts recorded in the handoff summary.

---

## Testing & Validation

- [ ] Both new paragraphs exist in the source-store `plan-format.md` at their named insertion
      points, each a single added hunk.
- [ ] Provision 1 states the exemption from the literal depends-on edge, the wave-1 /
      `Depends on: none` placement, the final phase's re-observation MUST, and the wave-table
      note's MUST.
- [ ] Provision 2 states the named owner, the prohibition on phase-body instructions, and the
      sanctioned alternative.
- [ ] Neither paragraph introduces target-argument / resting-state language.
- [ ] Phase-heading enum, plan-level `Status` vocabulary, trailing-annotation rule, and
      `### Phase N: {name} [STATUS]` heading contract all byte-unchanged.
- [ ] `agents/planner-agent.md` unchanged (decision recorded, not silently omitted).
- [ ] `deploy-headless.sh` reports `RESULT=landed_verify_clean`.
- [ ] `verify-deploy.sh` full gate set clean; `check-task-references.sh` exit 0;
      `check-record-versioning.sh` no BLOCKING finding; `validate-state.sh` no new finding.
- [ ] Deployed and source-store `plan-format.md` byte-identical after deploy.

## Artifacts & Outputs

- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md` -
  two new paragraphs (one per provision).
- `/home/benjamin/Projects/BimodalLogic/.claude/context/formats/plan-format.md` - regenerated
  deploy output carrying both paragraphs.
- `specs/769_plan_format_blocked_gate_and_status_ownership/summaries/01_blocked-gate-and-status-ownership-summary.md`
  at implementation completion.
- Issue-log entries in `specs/769_plan_format_blocked_gate_and_status_ownership/issues.jsonl`
  recorded as they arise.

## Rollback/Contingency

Each phase is a single additive paragraph in one file, so rollback is per-phase and cheap: revert
the one added hunk at the source store and re-run `deploy-headless.sh` to regenerate the deployed
copy. No script, schema, or enum change is involved, so no consumer can be left in an
intermediate state.

If a rollback must discard uncommitted working-tree changes, follow
`context/contracts/recovery.md`'s rollback rung for the exact snapshot-then-rollback invocation
shape, including its out-of-scope override flag — the source-store path lies outside this
repository's tree and therefore outside the task's declared `file_scope`, so that override is the
relevant case here. For an ordinary defensive checkpoint before editing (not a rollback), use
`git-snapshot.sh --no-revert`, which is durable without reverting the working tree.

If Phase 3's deploy reports any RESULT other than `landed_verify_clean`, stop: leave both
source-store paragraphs in place, report the RESULT verbatim in the handoff's `blockers[]`, and
do not hand-patch `.claude/**`. The source-store edits are the durable artifact; the deployed
tree is regenerable.
