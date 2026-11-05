# Implementation Plan: Task #872

- **Task**: 872 - Open language transfer ledger
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: `specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md`
- **Artifacts**: plans/01_transfer-ledger-conclusion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

The ledger itself is landed: the research report enumerates 64 rows across three recorded
enumeration sources, assigns each a status from the dispatch's closed set, answers the three
prose questions, and records a re-runnable command for every count. What is not yet discharged is
the dispatch's own VERIFICATION clause — nothing has independently re-run those commands — and
the recommendations exist only as prose, in a form whatever files them must re-derive from
scratch. This plan covers exactly that conclusion work: audit the ledger's reproducibility, render
the six recommendations as a backlog-reconciled proposal packet, and put the findings into the one
channel `/orchestrate`'s conclusion stage actually reads. Definition of done: every asserted count
in the report is confirmed or corrected against a re-run of its own recorded command; a
file-ready, reconciled proposal set exists with its dependency edges stated; and no task has been
filed and nothing under `FormalSystem/` has been edited.

### Research Integration

Four findings from the report shape the phases below rather than being restated by them:

- **The reduction vehicle is `openValidIn_ofPlus_iff` / `plusDerivable_openDerivable_iff`, not the
  ZTime/RTime translations.** Both are unconditional and class-generic (`{fc : FrameClass}`); the
  translations carry `SeparationOver` and apply only at ZTime/RTime. Any proposal description
  written in Phase 2 that names a reduction must name the right one — getting this backwards is
  the single error that would make a proposal's scope wrong.
- **Thirteen of the 24 OWED rows have no owner**, concentrated in the state-locality fragment and
  the semantics-layer support lemmas. Those are the proposals Phase 2 renders (T1–T6).
- **Two ordering hazards are already identified**: the direct L→L^▷ embedding (T4) is a
  prerequisite of task 874 and of task 856's conservativity-over-TM phase, both of which are
  filed and gated the other way; and T2 shares `OpenLanguage/`/`Semantics/` territory with task
  869. Both must survive into the packet as explicit edges, not as prose a later reader may miss.
- **Every negative existence claim rests on a recorded grep, not on the LSP index**
  (`lean_local_search` reported `index: warming`). That is exactly why Phase 1 exists: the
  proposals in Phase 2 are built on those negatives, so they are re-verified before being
  rendered rather than after.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- Discharge the dispatch's VERIFICATION clause: every count and declaration name asserted in the
  report reproduces from a command recorded in the report itself, re-run at a pinned tree state,
  with any divergence corrected in place and attributed to the command that produced the new value.
- Render the report's six recommendations as a machine-readable proposal set in
  `audit-task-proposals.sh`'s own input shape, with narrow `file_scope` per proposal, the
  Component 0 task-count reasoning recorded, and the Component 4b backlog reconciliation run and
  its verdicts preserved as evidence.
- Render the Component 7 confirmation table the user will act on, including the two ordering
  edges the report flags, so the filing decision is a single read rather than a re-derivation.
- Put the ledger's actionable findings into `issues.jsonl` with `suggested_channel:
  follow_up_task`, since that log is the sole payload source for the conclusion stage's follow-up
  channel — a recommendation that never reaches it is invisible to the stage the dispatch defers to.

**Non-Goals**:

- **Filing any task.** No `state-write.sh` call, no task-number allocation, no edit to
  `specs/state.json` or `specs/TODO.md`. The dispatch defers filing to the conclusion stage and
  Component 7's confirmation is mandatory and foreground-only; an autonomous dispatch cannot
  satisfy it, and must not route around it.
- **Any edit under `FormalSystem/`.** Including `FormalSystem/OpenLanguage/README.md`, whose
  "semantic only" claim the report found false — that surface is owned by task 856 phase 15 and
  is recorded here, not fixed here.
- **Any new Lean declaration**, any rename or mutation of `PlusFormula`/`PlusAxiom`/
  `PlusDerivationTree`, any deletion under `PlusLanguage/`, and any completeness or decidability
  claim.
- **Re-doing the enumeration.** Phase 1 audits the recorded commands; it does not re-enumerate
  the L⁺ surface from scratch or re-adjudicate a row's status.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The tree moved under the report: it was written at `4c52993c1`, HEAD is now `e90a674f7`, and `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` carries an uncommitted modification from another writer. A Layer-4 declaration list or a `Metalogic/` count may no longer reproduce. | M | M | Phase 1 pins the tree state it audits at (`git rev-parse --short HEAD` plus `git status --porcelain FormalSystem/`) and records it in the audit subsection. A divergence traceable to that one file is reported as a tree-state note, not silently absorbed into the count. |
| The uncommitted `OpenAxiomValidity.lean` change belongs to another session and must never be staged, reverted, or committed by this task. | H | L | Every phase's commit stages only its own enumerated `specs/**` files by explicit path. No `git add -A`, no directory pathspec, no destructive git on the dirty tree. Phase 3's verification asserts `git status --porcelain FormalSystem/` is unchanged from what Phase 1 recorded. |
| A negative existence claim the proposals rest on has since become false (e.g. task 856 landed something), making a proposal's scope wrong. | M | L | Phase 2 depends on Phase 1 precisely so the negative-existence block is re-run first. A proposal whose premise Phase 1 falsified is dropped from the packet with the reason recorded, not rendered. |
| `audit-task-proposals.sh` emits `scope-blind` unconditionally for every corpus record with no `file_scope`, which can dominate the verdict list against this backlog. | L | H | Documented noise trade-off, not a defect. Phase 2 collapses `scope-blind` to a count in the rendered table (sanctioned by Component 7) while preserving every verdict verbatim in the NDJSON evidence file. |
| The packet is read as a filing authorization. | M | M | `proposals.md` states in its own first line that nothing is filed and that Component 7 confirmation is outstanding; the packet carries no allocated task numbers, so it cannot be mistaken for state. |
| T5 duplicates work task 860 may already discharge; T6 is explicitly recommended for absorption rather than filing. | L | H | Component 0's task-count test is applied in Phase 2 before the packet is written, and the resolution of both is recorded per proposal with its divide reason — rather than six rows being carried forward unexamined. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phase 2's
proposals rest on the negative-existence claims Phase 1 re-verifies, and Phase 3 records what
Phase 2 produced.

### Phase 1: Reproducibility audit of the ledger's recorded commands [COMPLETED]

**Goal**: Independently discharge the dispatch's VERIFICATION clause — re-run every command block
the report records, confirm or correct each asserted value, and pin the tree state the audit was
performed at.

**Tasks**:

- [x] Pin the tree state: record `git rev-parse --short HEAD` and `git status --porcelain FormalSystem/`
      verbatim. Both go into the audit subsection; the second is the baseline Phase 3 re-asserts.
      *(completed: not a single static pin — the foreign dirty set changed shape 3 times during
      the audit; recorded as a timeline instead, see `## Reproducibility Audit` in the report)*
- [x] Re-run the Source A block (file counts, total declaration counts, per-file declaration
      counts, inductive sizes) and compare each printed value against its inline `# N` comment.
      *(completed: all reproduced exactly)*
- [x] Re-run the Source B block (`docs/theorem-index.md` row counts) and the Source C block
      (`FormalSystem/Metalogic/README.md`'s TM⁺ metatheory table) the same way. *(completed: both
      reproduced exactly against committed state; a live uncommitted edit to theorem-index.md was
      observed and excluded as evidence)*
- [x] Re-run the negative-existence block — the ~37-name loop plus the `OpenFormula` abbreviation
      loop — and confirm every name still prints `0` except the documented `openComplete`
      exception. This block is load-bearing for Phase 2: a name that now prints non-zero
      invalidates the proposal built on it. *(completed: 2 exceptions found — `forward_open`,
      `openDerivable_ofPlus_iff` — both tree movement from task 856 phase 13 landing R50, neither
      touching a T1-T6 premise)*
- [x] Re-run the direct-embedding block and confirm the composite `OpenLanguage.ofPlus ∘
      PlusLanguage.ofFormula` still occurs nowhere, and that the nine `ofPlus (ofFormula` hits are
      still all `StarLanguage.ofPlus`. *(completed: corrected — the committed count was always 16,
      not 9 (authoring-time undercount); the unnamed composite also now appears 11 times in a
      newly-landed file, task 856 phase 13, still no single named declaration)*
- [x] Re-run the unformalized-hypotheses block and confirm `grep -rnE '^axiom '` still returns no
      `axiom` declaration, and that `hmarkers`, `hinexpr` and `SeparationOver` are still the three.
      *(completed: reproduced exactly)*
- [x] Re-run the stale-surface block and confirm `OpenLanguage/README.md` still says "semantic
      only" and still lists six files against nine on disk. *(completed: reproduced exactly against
      committed state; a live uncommitted edit already correcting this claim was observed, task 856
      phase 15, excluded as evidence since uncommitted)*
- [x] Append one `## Reproducibility Audit` subsection to the report: the pinned tree state, one
      line per command block (`reproduced` / `diverged: <old> -> <new>`), and for every divergence
      the command that produced the new value. Where a count diverged, correct the asserted number
      in the body of the report too — never leave the body and the audit disagreeing. *(completed)*
- [x] Record an `issue-record.sh` entry for any divergence found (`--class 'plan scope-hypothesis
      wrong'` if a count was wrong, `--class 'design-record defect or ambiguity'` if a claim was),
      or a `kind: win` entry attesting the ledger reproduced clean if nothing diverged. *(completed:
      1 issue entry for the Star-side undercount, 2 win entries — clean reproduction of the
      remaining blocks, and the tree-movement confirmation of the OWED-row ownership table)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: Every touched path lies under `specs/**` and the edit is appended prose
plus corrected numerals in one markdown file with no executable surface, so per plan-format.md's
`__FULL_SWEEP__` sub-case (a) the covering check is `bash .claude/scripts/validate-artifact.sh
specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md report`
together with the diff read-through; the commands the phase runs are all reads.

**Scope Hypothesis**: The report asserts roughly 14 command blocks' worth of counts and names, and
the hypothesis is that all reproduce except possibly the Layer-4 declaration list for
`FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean`, which carries an uncommitted
modification. Confirm by diffing each block's actual output against its recorded inline comment
one block at a time — never by spot-checking a few and generalizing.

**Files to modify**:

- `specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md` - append a `## Reproducibility Audit` subsection; correct any asserted count the re-run falsified
- `specs/872_open_language_transfer_ledger/issues.jsonl` - append the divergence or clean-reproduction entry (written only via `issue-record.sh`, never by hand)

**Verification**:

- Every command block in the report's Verification Commands section has exactly one line in the
  new audit subsection, and no block is unaccounted for.
- No number appears in two different values across the report body and the audit subsection.
- `bash .claude/scripts/validate-artifact.sh specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md report` passes.
- `git status --porcelain FormalSystem/` is byte-identical to the baseline recorded at the phase's
  start.

---

### Phase 2: The reconciled proposal packet [NOT STARTED]

**Goal**: Render the report's recommendations as a file-ready, backlog-reconciled proposal set with
its dependency edges stated — discharging Components 0, 4a and 4b of the multi-task creation
standard — while filing nothing.

**Tasks**:

- [ ] Apply Component 0's task-count test to T1–T6 before writing anything. The default is
      consolidation; a row survives as its own proposal only under a named divide reason (a)
      disjoint file scope, (b) different task_type or owning domain, (c) real dependency ordering,
      (d) size exceeding one dispatch. Two resolutions are already indicated by the report and must
      be made explicitly rather than deferred: T6 (the discrete/`⊡` abbreviations) is recommended
      for absorption into T2 or task 873 rather than filing; T5 (`hmarkers`) is contingent on
      whether task 860 already discharges its load-bearing step — check `FormalSystem/Semantics/
      Frames/TranslationProduct.lean` and task 860's own artifacts before deciding whether T5 is a
      proposal or an application note.
- [ ] Drop any proposal whose premise Phase 1's negative-existence re-run falsified, recording the
      reason in the packet. Do not render a proposal for a declaration that now exists.
- [ ] Write `proposals.json`: a JSON array in `audit-task-proposals.sh`'s set-mode shape — `id`,
      `title`, `description`, `file_scope` per element, and **no** `project_number` (these are
      not-yet-created proposals). Each `description` is the one-paragraph scope the dispatch asks
      for, and names the correct reduction vehicle where it names one.
- [ ] Declare the narrowest currently-known `file_scope` per proposal from the files the report
      actually names — `FormalSystem/OpenLanguage/OpenStateLocal.lean`,
      `FormalSystem/OpenLanguage/OpenIntTransfer.lean`, `FormalSystem/OpenLanguage/Formula.lean`,
      `FormalSystem/OpenLanguage/OpenValidity.lean`, `FormalSystem/OpenLanguage/OpenReversal.lean`,
      `FormalSystem/OpenLanguage/OpenTruth.lean`, `FormalSystem/OpenLanguage/OpenAxioms.lean`,
      `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean`. Never a directory root:
      `FormalSystem/OpenLanguage/` as an entry would trip `validate-state.sh` Check 8 and
      manufacture a false collision against every sibling proposal.
- [ ] Run `bash .claude/scripts/audit-task-proposals.sh --proposals-file
      specs/872_open_language_transfer_ledger/proposals.json >
      specs/872_open_language_transfer_ledger/proposals-audit.ndjson` and read every verdict line.
      Treat a `duplicate-of-open` / `subset-of-open` / `covered-by-closed` verdict as a disposition
      to render for the user, never as grounds to auto-drop or auto-apply.
- [ ] Run the Component 4a pairwise overlap check across the packet's own `file_scope` arrays and
      note the serializing edge each overlapping pair implies.
- [ ] Write `proposals.md`, opening with an explicit line stating that nothing has been filed and
      that Component 7 confirmation is outstanding, then the confirmation table in the standard's
      own columns — `# | Title | Task Type | Effort | Dependencies | Backlog Check` — with `#` left
      unallocated. Annotate every auto-derived edge `(auto: file overlap)`. Collapse `scope-blind`
      to a count with a pointer to the NDJSON. Render every other non-`genuinely-new` verdict with
      its target record and the operator action, citing a closed record by `project_name` plus the
      discharging artifact's path rather than an archived number.
- [ ] State the two ordering constraints as rows of their own beneath the table: the
      direct-embedding proposal must be sequenced **before** task 874 and before task 856's
      conservativity-over-TM phase; the semantics-support proposal shares `OpenLanguage/` and
      `Semantics/` territory with task 869 and must be batched with it or given an explicit edge,
      never dispatched concurrently.
- [ ] Add a short closing section listing the four rows the report flags as blocked on open
      mathematics (TM⁺ completeness, TM⁺ decidability, the 35-row ZTime certificate front, and
      `hinexpr`) under a heading that says plainly these are **not** proposed as tasks — so the
      packet's remaining-work count is never read as a to-do list.
- [ ] Do not call `state-write.sh`. Do not allocate a task number. Do not edit `specs/state.json`
      or `specs/TODO.md`.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Every touched path lies under `specs/**` and the phase writes two data
files plus one markdown file with no executable surface, so per plan-format.md's `__FULL_SWEEP__`
sub-case (a) the covering check is `jq -e . ` over each line of `proposals-audit.ndjson` and
`jq -e 'type == "array"' proposals.json` together with the diff read-through — no suite maps to
these paths and none is claimed.

**Scope Hypothesis**: The packet is expected to carry between three and five proposals rather than
the report's six prose recommendations, because Component 0's test is expected to absorb T6 and
may absorb T5. Confirm by recording the surviving count and the named divide reason per row in
`proposals.md`; a packet that happens to carry all six must say under which divide reason each
survived, not default to six because the report listed six.

**Files to modify**:

- `specs/872_open_language_transfer_ledger/proposals.json` - new; the proposal set in `audit-task-proposals.sh`'s set-mode input shape
- `specs/872_open_language_transfer_ledger/proposals-audit.ndjson` - new; the backlog-reconciliation verdicts, preserved verbatim as Component 4b evidence
- `specs/872_open_language_transfer_ledger/proposals.md` - new; the Component 7 confirmation table, the two ordering edges, and the open-mathematics exclusions

**Verification**:

- `jq -e 'type == "array" and length > 0' specs/872_open_language_transfer_ledger/proposals.json`
  passes, and every element has `title`, `description` and `file_scope` and no `project_number`.
- Every line of `proposals-audit.ndjson` parses as JSON and the file has exactly as many lines as
  `proposals.json` has elements.
- No `file_scope` entry in the packet is a bare directory (every entry ends in `.lean`).
- Every proposal row in `proposals.md` carries a Backlog Check cell, and every non-`genuinely-new`
  verdict in the NDJSON appears somewhere in the rendered table or in its collapsed `scope-blind`
  count.
- `git diff --stat specs/state.json specs/TODO.md` is empty — the phase filed nothing.

---

### Phase 3: Issue-log bridge and close-out [NOT STARTED]

**Goal**: Put the ledger's actionable findings into `issues.jsonl`, the sole payload source for
the conclusion stage's follow-up channel, and close the task with the full gate set green and the
no-edit scope attested.

**Tasks**:

- [ ] Record one `issue-record.sh` entry per surviving proposal: `--kind issue`,
      `--suggested-channel follow_up_task`, `--resolution open`, `--phase implement`,
      `--dispatch-seq` as dispatched, `--evidence-path` pointing at
      `specs/872_open_language_transfer_ledger/proposals.md`, and `--severity` reflecting the
      report's own value ordering (the state-locality fragment and the direct embedding are the
      high-value rows; the abbreviation row is not). `--what-happened` states the gap and names the
      L⁺ counterpart it is owed against, in one or two sentences — the entry is a pointer into the
      packet, not a second copy of it.
- [ ] Record the two ordering hazards as their own entries, both `--class 'cross-task
      ownership/territory'`: the direct-embedding proposal being a prerequisite of task 874 and of
      task 856's conservativity-over-TM phase, which are filed and gated the other way; and the
      semantics-support proposal sharing `OpenLanguage/`/`Semantics/` territory with task 869.
- [ ] Record the stale-surface finding as `--class 'design-record defect or ambiguity'`,
      `--suggested-channel follow_up_task`: `FormalSystem/OpenLanguage/README.md` states "L^▷ is
      semantic only: it has no proof system" and lists six files against nine on disk, while
      `FormalSystem/Metalogic/Conservativity/Open.lean`'s docstring is accurate — the two surfaces
      disagree. Name task 856 phase 15 as the existing owner in the entry, so the conclusion stage
      does not propose a duplicate.
- [ ] Record the `PlusLanguage/README.md` `<!-- TODO: add description -->` inventory row for
      `Subformulas.lean` as a single low-severity entry, or state in the handoff that it was
      judged too small to carry — but do not leave it silently dropped.
- [ ] Attest explicitly in the handoff summary: nothing under `FormalSystem/` was edited, no task
      was filed, no Lean declaration was added, and no completeness or decidability claim was made.
- [ ] Run the complete gate set and record the result.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: The phase expects to append one entry per surviving proposal (three to five,
per Phase 2's own hypothesis) plus exactly two ordering-hazard entries plus one stale-surface
entry — so six to eight new lines in `issues.jsonl`. Confirm by counting the file's lines before
and after and reconciling the delta against `proposals.json`'s element count plus three, rather
than by assuming the packet carried the number Phase 2 predicted.

**Files to modify**:

- `specs/872_open_language_transfer_ledger/issues.jsonl` - append the proposal, ordering-hazard and stale-surface entries (via `issue-record.sh` only, never by hand)
- `specs/872_open_language_transfer_ledger/.orchestrator-handoff.json` - the dispatch's own handoff, carrying the scope attestation in `summary`

**Verification**:

- The complete gate set for the repository: `bash .claude/scripts/verify-deploy.sh`. Note which
  gates SKIP and why — this repo's `.claude-extensions.json` declares no `source_dir`, so the
  source-store gates have nothing to check here; a skip is recorded, never read as a pass.
- `bash .claude/scripts/validate-artifact.sh specs/872_open_language_transfer_ledger/plans/01_transfer-ledger-conclusion.md plan`
  and the same for the report, both passing.
- `bash .claude/scripts/validate-state.sh` passes (or its pre-existing WARNs are unchanged).
- Every line of `specs/872_open_language_transfer_ledger/issues.jsonl` parses:
  `while read -r l; do printf '%s' "$l" | jq -e . >/dev/null; done < .../issues.jsonl`.
- `git status --porcelain FormalSystem/` matches Phase 1's recorded baseline exactly — the
  uncommitted `OpenAxiomValidity.lean` modification belonging to another writer is untouched,
  unstaged and uncommitted.
- `git diff --stat specs/state.json specs/TODO.md` is empty.
- No `lake build` is in this gate set, and that is deliberate rather than an omission: no file
  under `FormalSystem/` is touched by any phase of this plan, so the Lean build surface is
  unaffected. Were a phase to touch one, the plan would be out of the dispatch's declared scope.

---

## Testing & Validation

- [ ] Every command block in the report's Verification Commands section has been re-run and has a
      verdict line in the Reproducibility Audit subsection.
- [ ] No count appears at two different values anywhere in the report.
- [ ] `proposals.json` is a non-empty JSON array whose every element carries `title`,
      `description` and `file_scope`, and no element carries `project_number`.
- [ ] `proposals-audit.ndjson` has one parseable line per proposal.
- [ ] No `file_scope` entry anywhere in the packet names a directory rather than a `.lean` file.
- [ ] `proposals.md`'s first line states that nothing has been filed.
- [ ] The two ordering constraints and the four open-mathematics exclusions both appear in
      `proposals.md`.
- [ ] `issues.jsonl` carries one entry per surviving proposal plus the two ordering-hazard entries
      plus the stale-surface entry, each parseable, each with `suggested_channel: follow_up_task`.
- [ ] `specs/state.json` and `specs/TODO.md` are unmodified by this task.
- [ ] `git status --porcelain FormalSystem/` is unchanged from Phase 1's baseline.
- [ ] `bash .claude/scripts/verify-deploy.sh` green, with any SKIP recorded and explained.

## Artifacts & Outputs

- `specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md` — amended
  with a `## Reproducibility Audit` subsection and any corrected count (existing file).
- `specs/872_open_language_transfer_ledger/proposals.json` — the proposal set in
  `audit-task-proposals.sh`'s set-mode input shape (new).
- `specs/872_open_language_transfer_ledger/proposals-audit.ndjson` — the Component 4b
  backlog-reconciliation verdicts, preserved verbatim as evidence (new).
- `specs/872_open_language_transfer_ledger/proposals.md` — the Component 7 confirmation table, the
  two ordering edges, and the open-mathematics exclusions (new).
- `specs/872_open_language_transfer_ledger/issues.jsonl` — extended with the follow-up-channel
  entries (existing file, append-only via `issue-record.sh`).
- `specs/872_open_language_transfer_ledger/summaries/01_transfer-ledger-conclusion-summary.md` —
  the execution summary, written at implement postflight.

## Rollback/Contingency

Every file this plan writes is under `specs/872_open_language_transfer_ledger/`, and the three
packet files are new, so rollback is removal of the new files plus reverting the one appended
subsection in the report — with no effect on the Lean build, on `specs/state.json`, or on any
other task's artifacts.

Because the working tree is dirty with another writer's uncommitted change to
`FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean`, a whole-tree revert is
forbidden here: `git checkout -- .`, `git reset --hard` and `git clean -fd` would all discard that
change. Roll back by explicit path only — remove the three new packet files and `git checkout --
specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md` for the one
amended file, each named individually. If a genuine snapshot-then-rollback is ever needed instead,
follow `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation
shape and its out-of-scope override flag rather than improvising one; a bare precautionary
checkpoint, if wanted before Phase 1, is `bash .claude/scripts/git-snapshot.sh 872 --no-revert`,
which is durable without reverting the working tree.

`issues.jsonl` is append-only provenance and is deliberately **not** rolled back: an entry
recording what was found stays true regardless of whether the packet it points at survives.
