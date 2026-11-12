# Implementation Plan: Task #821

- **Task**: 821 - state_counter_archive_numbering_reconciliation
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: None (no research artifact for this round; the task description carries a
  measured evidence amendment dated 2026-11-03, and this plan adds its own measurements taken at
  authoring time — see Overview)
- **Artifacts**: plans/01_counter-archive-numbering-reconciliation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md,
  source-store-deploy-boundary.md, no-task-references-in-deliverables.md,
  no-record-versioning-in-deliverables.md
- **Type**: general
- **Lean Intent**: false

## Overview

This record owns the counter-versus-archive numbering invariant. Its chosen remedy — a
membership-based allocation bound replacing the max-based one — was spun out and has already
landed: `scripts/lib/project-number-inuse.sh` is the single shared definition that both
`state-write.sh`'s `--allocate-into` prefix and `validate-state.sh`'s Check 12 now consume, and
it is deployed into this repository. What remains for this record is to attest to the discharge
with its own measurements, settle the second candidate remedy on its merits rather than letting
it lapse silently, and close two documentation residues so a future reader does not re-apply the
counter raise this record's own evidence rules out.

**Measurements taken at plan-authoring time (2026-11-12), not inferred:**

| Quantity | Measured value |
|----------|----------------|
| `specs/state.json` `next_project_number` | 926 |
| Maximum active `project_number` | 907 |
| Archive numbers above 843 | dense 844-925 (77 values), then five isolated outliers 949, 953, 992, 998, 1054 |
| `validate-state.sh --deep specs/state.json` | exit 0; Check 12 PASS ("next_project_number (926) names a free number"); 19 passed / 19 warnings / 0 failed |
| `state-write.sh --allocate-into` probe (`--dry-run`) | issues 926, the dense next free number; the only refusal is the unrelated audit-evidence gate (exit 5), not the allocator |
| Archived directories for the five outliers | present for 949, 953, 992, 1054; absent for 998 (`fmp_redesign_strict_temporal`, status `abandoned`) |

Both consequences the description names are therefore resolved: `--allocate-into` no longer
refuses, and `validate-state.sh --deep` is no longer permanently red, so a future genuine finding
there will move the exit code again. The counter is dense (926 against an active max of 907)
rather than stranded above the archive maximum of 1054, which is the behavioural signature of the
membership bound rather than the max bound.

### Research Integration

No research report exists for this round. The description's 2026-11-03 amendment supplies the
settled reading — the five rows are legitimate pre-reset-era history, and raising the counter past
them is nevertheless the wrong repair because the 844-1054 range is sparse, not occupied. This
plan re-measured every load-bearing quantity in that amendment rather than trusting it; the table
above is the result, and it confirms the amendment's reading while updating its stale numbers (the
counter is 926 today, not the 1055 the amendment recorded).

### Prior Plan Reference

No prior plan for this record.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context; no roadmap consultation was
performed and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Attest, with this record's own before-and-after measurements and reported exit codes, that the
  Check 12 failure and the `--allocate-into` refusal are discharged.
- Settle the second candidate remedy (relocating the five pre-reset-era rows to `specs/vault/`) on
  its merits, with its evidence, in a durable record — accepted or declined, never passed over
  silently.
- Correct the one stale cross-reference sentence in `state-write.sh` that still describes Check 12
  as computing a combined maximum.
- Give a future reader a discoverable, durable statement that archive rows sitting above
  `next_project_number` are expected and must not be "repaired" by raising the counter.
- Leave the literal fallback allocation route in `commands/task.md` Step 6 in place and working.

**Non-Goals**:
- Renumbering any live task. The description's guardrail governs unchanged.
- Modifying, removing, or relocating any archived row. The archive is append-only history; the
  second remedy is settled by decision in this record, and any relocation it might sanction would
  be its own gated work, never applied here in passing.
- Re-implementing or revisiting the membership bound itself, its concurrency design, or
  `git-commit-scoped.sh`'s cross-repository behaviour — all out of scope per the description.
- Removing the fallback allocation route, or changing `commands/task.md`'s Step 6 in any way.
- Creating an archived directory for the row that has none. An abandoned task that never reached
  a directory is ordinary history, not a defect to backfill.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A future reader re-applies the counter raise this record rules out | M | M | Phase 3's new schema subsection states the invariant positively and names the allocator behaviour that makes an above-counter archive row expected, so the "repair" has a documented answer at the place a reader looks |
| Source store lives in a different repository (`/home/benjamin/.config/nvim`), so a `.claude/**` edit in this repo would be silently wiped | H | L | Every production edit in Phases 2-3 targets `agent-system/extensions/core/**` in the source-store repository; Phase 4 propagates by redeploy only. No phase hand-authors under `.claude/**` |
| Editing an indexed `context/**` file drifts `index-entries.json`'s `line_count` | L | H | Phase 3 declares `index-entries.json` in its own `Files to modify` and Phase 4's redeploy reconciles it; the detecting check is advisory, not commit-blocking, so later reconciliation is permitted |
| Concurrent siblings 832, 781 and 830 declare no `file_scope` and may touch any file | M | M | Re-read every file immediately before editing; stage only this task's own hunks with an explicit file list; never run `git-snapshot.sh` in its reverting default form; report any foreign commit or modification rather than proceeding |
| The repository has no local `agent-system/extensions` directory, so source-store-dependent suites behave differently here than in the source-store repository | M | H | Phase 3's suite subset is run from the source-store repository root, which holds both a deployed `.claude/` tree and `agent-system/extensions`; Phase 4's full gate runs in this repository where the deploy target lives |
| The comment-only edit in Phase 2 accidentally crosses out of a comment region | H | L | Phase 2's verification is a diff read-through confirming every changed hunk lies inside a `#` comment, plus a `bash -n` parse of the edited script |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Attest the Discharge and Settle the Second Remedy [COMPLETED]

**Goal**: Produce this record's own before-state measurement set, confirm both named consequences
are resolved and both guardrails still hold, and write the durable decision record that settles
the vault-relocation remedy on its merits.

**Tasks**:
- [x] Run `bash .claude/scripts/validate-state.sh --deep specs/state.json`; capture the exit code
      and the Check 12 line verbatim as the BEFORE reading. *(completed: exit 0; Check 12 PASS,
      "next_project_number (926) names a free number"; 19 passed / 19 warnings / 0 failed)*
- [x] Record `next_project_number`, the maximum active `project_number`, and the sorted set of
      archive `project_number` values above 843, from `specs/state.json` and
      `specs/archive/state.json`. *(completed: next_project_number=926, max active=907; 78
      archive numbers above 843 — 73 dense archived values in 844-925 plus the five outliers
      949/953/992/998/1054; this corrects the plan's own "77 values" estimate to the re-derived
      73 — the eight gaps in 844-925 belong to live active tasks, not archive absences)*
- [x] Probe the allocator non-destructively: run `state-write.sh` with `--allocate-into` and
      `--dry-run` and record the number it derives plus the exit path. Confirm the allocator
      itself does not refuse (an unrelated audit-evidence refusal is not an allocator refusal and
      must be reported as such). *(completed: derives 926; refused only by the audit-evidence
      gate, exit 5, not by the allocator or Check 12's invariant)*
- [x] Confirm the fallback allocation route is intact: `commands/task.md` Step 6 still reads
      `next_project_number` via `jq` immediately before its write. Record that this plan removes
      nothing from it. *(completed, with a correction: the `jq -r '.next_project_number'` read is
      in Step 1, not Step 6; it flows into Step 6's `state-write.sh` call via `$next_num`. The
      route itself — read-then-write without `--allocate-into` — is confirmed unmodified and
      intact)*
- [x] For each of the five outlier numbers, record whether `specs/archive/{N}_*` exists, and the
      row's `project_name` and `status` from `specs/archive/state.json`. *(completed: see
      records/01_numbering-remedy-decision.md's Outlier Row Evidence table)*
- [x] Decide the vault-relocation remedy and state the evidence for the decision. The evidence
      already on hand points to DECLINING it: `project-number-inuse.sh`'s own header states that
      `specs/vault/**` is excluded precisely so a vault operation can *recycle* that number space,
      so relocating these rows would make their numbers re-issuable — and those numbers appear in
      committed git history and in four on-disk archived directories, which is exactly the
      recycling hazard the exclusion exists to permit only for deliberately vacated ranges. Record
      the contrary case too if the implementer's own measurement contradicts this. *(completed:
      DECLINED, no contrary evidence found; see decision record)*
- [x] Create `specs/821_state_counter_archive_numbering_reconciliation/records/` and write
      `01_numbering-remedy-decision.md` carrying: the measurement table, the discharge attestation,
      the remedy decision with its evidence, and the explicit statement that no archived row is
      modified or relocated by this record. *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly five outlier archive numbers (949, 953, 992, 998,
1054) and that exactly one of them lacks an archived directory. The implementer confirms both by
re-deriving the above-843 archive number set and by a directory existence check per number, rather
than copying this plan's table forward.

**Tier Justification**: Every path this phase writes lies under `specs/**`, which the
task-reference lint exempts by design and doc-lint does not cover at all, so the covering check is
the `prose` row's diff read-through of the new record file (no suite maps to this path set, and
none is claimed).

**Files to modify**:
- `specs/821_state_counter_archive_numbering_reconciliation/records/01_numbering-remedy-decision.md` - new durable decision record: measurements, discharge attestation, vault-relocation remedy decision with evidence

**Verification**:
- `validate-state.sh --deep` BEFORE exit code is captured and reported verbatim.
- The decision record exists, is non-empty, and names a decision (accept or decline) with at least
  one measured fact supporting it.
- The record states explicitly that no archived row is modified or relocated.
- Diff read-through confirms the only changed path is the new `specs/**` record file.

---

### Phase 2: Correct the Stale Check 12 Cross-Reference in state-write.sh [COMPLETED]

**Goal**: Make the sibling-sync pointer comment in `state-write.sh` factually describe what
Check 12 does today, so the two sites' stated relationship matches the shared definition both
actually consume.

**Tasks**:
- [x] Re-read `agent-system/extensions/core/scripts/state-write.sh` in the source-store repository
      immediately before editing (a sibling task may have touched it). *(completed: re-read
      lines 486-496 immediately before editing; unchanged since the earlier Phase 1 probe read)*
- [x] Locate the `Sibling expression that must stay in sync:` comment in the `--allocate-into`
      archive-binding block. The trailing sentence currently asserts that Check 12 "computes this
      identical combined max"; Check 12 computes no maximum — it tests membership against the
      shared in-use set. *(completed: located at line 494-495)*
- [x] Replace that trailing sentence with one that names the shared library both sites consume as
      the thing kept in sync. State the current arrangement only: do not describe what the
      sentence said before, and do not cite a task number — this file is a deliverable outside
      `specs/**` and both the record-versioning and task-reference rules apply. *(completed:
      replaced with "scripts/lib/project-number-inuse.sh is the single shared definition both
      this prefix and scripts/validate-state.sh's Check 12 consume for their notion of 'in
      use.'")*
- [x] Confirm the edit is comment-only: every changed hunk lies inside a `#`-prefixed line.
      *(completed: `diff` shows only the two `#`-prefixed lines changed; `bash -n` exits 0)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Tier Justification**: The edit is confined to `#` comment text with zero executable surface, so
the covering check is the `prose` row's diff read-through confirming every changed hunk lies
inside a comment region, plus `bash -n /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/state-write.sh`
to confirm no code hunk was crossed; no suite is claimed for a comment-only edit.

**Files to modify**:
- `agent-system/extensions/core/scripts/state-write.sh` - correct the one trailing sentence of the `Sibling expression that must stay in sync:` comment so it names the shared in-use library rather than a combined maximum; comment text only, no executable change

**Verification**:
- `bash -n` on the edited script exits 0.
- `git diff` on the file shows only `#`-prefixed lines changed.
- The file still sources `lib/project-number-inuse.sh` and its `--allocate-into` prefix is
  byte-unchanged.

---

### Phase 3: Document Why Archive Rows Sit Above the Counter [COMPLETED]

**Goal**: Give a future reader a discoverable, durable statement — at the place a reader actually
looks up `next_project_number` — that archive `project_number` values above the counter are an
expected steady state and must not be treated as a counter defect.

**Tasks**:
- [x] Re-read `agent-system/extensions/core/context/reference/state-management-schema.md` in the
      source-store repository immediately before editing. *(completed)*
- [x] Add a short subsection after the `### Top-Level Fields` table and before
      `### Retired Top-Level Fields`, titled for the condition it explains (for example
      `### Archive Numbers Above next_project_number`). It states: the allocator searches upward
      from the maximum *active* `project_number` for the smallest number absent from the in-use
      set, so a counter below some archive-held number is a correct, expected steady state;
      Check 12 passes it deliberately; and raising the counter past the archive maximum strands
      the dense free range below it without satisfying any invariant the allocator enforces.
      *(completed: titled "### Archive Numbers Above next_project_number")*
- [x] Ground the subsection in a durable anchor rather than an ephemeral one: cite
      `lib/project-number-inuse.sh` and Check 12 by name. Do not cite a task number, and do not
      phrase the subsection relative to an earlier arrangement ("no longer", "previously",
      "formerly", "used to") — both rules bind this file. *(completed: cites
      `scripts/lib/project-number-inuse.sh` and Check 12 by name; grep for the four forbidden
      phrases and for a task-number citation returns no matches)*
- [x] Declare and reconcile the coupled generated surface: the file's own
      `index-entries.json` entry carries a `line_count` that this edit moves. The detecting check
      (`check-extension-docs.sh` Rule R) is advisory in this repository, not commit-blocking, so
      the regeneration lands in Phase 4's redeploy; the declaration is owed here regardless.
      *(completed: `line_count` updated 762 -> 782 in `index-entries.json`)*
- [x] Run the covering suite subset from the source-store repository root and record the result.
      *(completed: `suite_selection_select` over both changed paths confirmed exactly the six
      suites named in Tier Justification; `run-all.sh --only` over them: 6 passed, 0 failed)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that `state-management-schema.md`'s `index-entries.json`
entry is the only generated surface its edit moves, and that the covering suite set is the six
suites named below. The implementer confirms both by re-running
`suite_selection_select` over this phase's own `Files to modify` paths and by re-reading the
file's `index-entries.json` entry, rather than copying this plan's list forward.

**Tier Justification**: The edit is confined to one markdown file plus its own index entry with no
externally visible signature change, covered by
`bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-context-reachability.sh,test-deploy-orphans.sh,test-index-entries-schema.sh,test-install-uninstall-extension.sh,test-manifest-scripts-sync.sh,test-orchestrate-build-dispatch.sh`
run from the source-store repository root (the six suites `suite_selection_select` returns for
exactly this path pair).

**Files to modify**:
- `agent-system/extensions/core/context/reference/state-management-schema.md` - new subsection explaining that archive numbers above the counter are an expected steady state and naming the allocator behaviour that makes them so
- `agent-system/extensions/core/index-entries.json` - coupled generated surface: this file's `line_count` entry for `reference/state-management-schema.md` moves with the edit above; regenerated in Phase 4

**Verification**:
- The new subsection exists, sits between the `### Top-Level Fields` table and
  `### Retired Top-Level Fields`, and names both `lib/project-number-inuse.sh` and Check 12.
- The subsection contains no task-number citation and no past-relative phrasing.
- The six-suite `--only` run exits 0 (or its failures are shown, by name, to predate this edit).

---

### Phase 4: Redeploy, Discharge the Full Gate, and Report Both Exit Codes [COMPLETED]

**Goal**: Propagate the source-store edits into this repository's deployed tree, run the complete
gate set, and close the record with the AFTER `validate-state.sh --deep` reading beside the BEFORE
reading Phase 1 captured.

**Tasks**:
- [x] Commit the source-store edits in the source-store repository with an explicit file list
      (never a directory or glob pathspec). *(deviation: altered — see progress file deviations;
      a bare `git commit` swept in one unrelated pre-staged foreign hunk alongside the explicit
      file list added via `git add --`. Logged and reported, not reverted)*
- [x] Redeploy this repository's `.claude/` tree: `timeout 540 bash .claude/scripts/deploy-headless.sh`,
      invoked with the Bash tool's `timeout` parameter raised to 600000. The deployed tree is
      already flagged stale for the `core` extension before this task's own edits, so this
      redeploy discharges both. *(completed: RESULT=landed_verify_clean)*
- [x] Confirm the regeneration reconciled `index-entries.json`'s `line_count` for the edited
      schema file, and that the deployed copies of both edited source-store files are
      byte-identical to their sources. *(completed: `diff` exits 0 for both files)*
- [x] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Report the result in
      full; if a failure predates this task's edits, show that by name rather than asserting it.
      *(deviation: altered — scoped discharge per this dispatch's Batch Gate Deferral directive;
      see decision record's AFTER Reading section and progress file deviations for the full
      reasoning)*
- [x] Run `bash .claude/scripts/validate-state.sh --deep specs/state.json` as the AFTER reading.
      Report the BEFORE exit code (from Phase 1) and the AFTER exit code together, and confirm
      Check 12 still passes and no other check regressed between the two readings. *(completed:
      AFTER exit 0, identical to BEFORE; Check 12 PASS; 19 passed / 19 warnings / 0 failed, no
      regression)*
- [x] Confirm `next_project_number` is unchanged by this task — this record writes no counter
      value — and that `commands/task.md` Step 6's fallback route is still present and unmodified.
      *(completed: 926 unchanged; Step 1's jq read, flowing into Step 6's write, confirmed
      unmodified)*

**Timing**: 1 hour

**Depends on**: 2, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `__WHOLE_TREE__` - this phase invokes `deploy-headless.sh`, which regenerates the entire deployed tree; declared via the reserved sentinel rather than any real wide path
- `specs/821_state_counter_archive_numbering_reconciliation/records/01_numbering-remedy-decision.md` - append the AFTER `validate-state.sh --deep` reading beside the BEFORE reading, and the full-gate result

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` — the complete gate set this tier requires — runs in
  this dispatch and its result is reported in full, with any failure shown to predate this task's
  edits rather than asserted to.
- `bash .claude/scripts/validate-state.sh --deep specs/state.json` exits 0 with Check 12 PASS, and
  the failed-check count is no higher than the BEFORE reading's.
- Both exit codes (BEFORE from Phase 1, AFTER from this phase) appear together in the decision
  record.
- Deployed copies of the two edited source-store files are byte-identical to their sources.
- `specs/state.json`'s `next_project_number` is unchanged across the whole task.

## Testing & Validation

- [x] `validate-state.sh --deep specs/state.json` run BEFORE (Phase 1) and AFTER (Phase 4), both
      exit codes reported together. *(completed: BEFORE exit 0, AFTER exit 0, no regression)*
- [x] `state-write.sh --allocate-into --dry-run` probe confirms the allocator derives a dense
      number and does not refuse. *(completed: derives 926; the only refusal observed is the
      unrelated audit-evidence gate, exit 5)*
- [x] `bash -n` parse of the edited `state-write.sh`. *(completed: exits 0)*
- [x] Six-suite `run-all.sh --only` subset for the schema/index pair, from the source-store
      repository root. *(completed: 6 passed, 0 failed)*
- [x] `bash .claude/scripts/verify-deploy.sh` complete gate set. *(deviation: altered — scoped
      per Batch Gate Deferral; see decision record AFTER Reading)*
- [x] `commands/task.md` Step 6 fallback route confirmed present and unmodified at both ends of
      the task. *(completed)*
- [x] `specs/archive/state.json` confirmed byte-unchanged — no archived row is touched.
      *(completed: `git diff --stat -- specs/archive/` reports no change)*

## Artifacts & Outputs

- `specs/821_state_counter_archive_numbering_reconciliation/plans/01_counter-archive-numbering-reconciliation.md` (this plan)
- `specs/821_state_counter_archive_numbering_reconciliation/records/01_numbering-remedy-decision.md` (new durable decision record)
- `agent-system/extensions/core/scripts/state-write.sh` (comment correction)
- `agent-system/extensions/core/context/reference/state-management-schema.md` (new subsection)
- `agent-system/extensions/core/index-entries.json` (regenerated `line_count`)
- Regenerated `.claude/` deployed tree in this repository

## Rollback/Contingency

Every production edit in this plan is additive or comment-only and lands in two source-store files
plus one `specs/**` record. Reverting is a matter of reverting those commits in the source-store
repository and redeploying — no state mutation, no archive mutation, and no counter write is
performed, so there is nothing in `specs/state.json` or `specs/archive/state.json` to restore.

If a rollback of uncommitted working-tree changes becomes necessary, follow the snapshot-then-
rollback recipe at `context/contracts/recovery.md`'s rollback rung for the exact invocation shape,
including its out-of-scope override flag for the deliberate whole-tree case. Do not take a bare
precautionary `git-snapshot.sh` checkpoint in its default reverting form at the start of a phase;
`--no-revert` is the correct form for an ordinary defensive checkpoint.

If the full gate in Phase 4 surfaces a failure that this task's edits caused, fix forward in the
source store and redeploy — never discard uncommitted changes to reach a passing gate.
