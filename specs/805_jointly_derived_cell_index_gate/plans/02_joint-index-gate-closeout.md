# Implementation Plan: Task #805

- **Task**: 805 - Jointly derived cell index gate
- **Status**: [COMPLETED]
- **Effort**: 2.25 hours
- **Dependencies**: None
- **Research Inputs**:
  - `specs/805_jointly_derived_cell_index_gate/reports/02_joint-index-gate-verdict.md` (the verdict)
  - `specs/805_jointly_derived_cell_index_gate/reports/01_jointly-derived-index-gate.md` (seed round)
- **Artifacts**: plans/02_joint-index-gate-closeout.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md,
  plan-compliance.md (Statement Fidelity), source-store-deploy-boundary.md, summary-format.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round returned the verdict this task was dispatched to obtain: the six-coordinate
cell index at parameters derived from the object and the formula **jointly**, in the sense the
parameter-origin rule states, is **REFUTED** — gates 1-3 pass, gates 4 and 5 are disarmed by the
formula-derived threshold and the formula-coupled modulus, and a sixth mechanism (a formula can
carve out a sub-object its letters cannot name, by forbidding a pattern instead of a letter)
refutes the modulus clause. Every deliverable the dispatch asked for (steps 1-4) already landed
and is committed: the wired probe, its registration, and the corrected parent record. Step (5)
was conditional on the gate being survived and is removed by the verdict, not deferred.

What remains is therefore a **close-out round, not a proof round**: re-measure the landed evidence
in this dispatch rather than trusting the research round's "measured this session" claims,
confirm the three records that carry the verdict are mutually consistent and that no weakened
substitute was published anywhere, and write the completion summary. Definition of done: the
probe gate is green under this dispatch's own measurement, the records agree with the verdict,
the summary artifact exists and validates, and the full gate set passes.

### Research Integration

- **The verdict is the deliverable and it is already written.** `reports/02` is committed; this
  plan does not reopen, restate, or soften it. No phase below re-derives a gate.
- **The refutation's own scope caveat is load-bearing and must survive into the summary**: it
  refutes the modulus clause *as the rule states it* (quantified over letter-definable
  sub-objects), not every jointly-derived parameter triple. The strictly stronger necessary
  condition the round leaves standing — the modulus a multiple of the period of every sub-object
  the formula's **closure** carves out, i.e. the object-closure product — is a *necessary*
  condition whose sufficiency is asserted nowhere.
- **Four proof obligations stay named and unmet**: eventual periodicity of the realizable types in
  the countdown over the product of the object with the closure (which mechanism (6) promoted from
  a proof step to a necessary condition on the index's own parameter); a region-length pumping
  lemma for `untl`/`snce`-depth-bounded formulas; the next deadline's coupling through `Drift`;
  the `box`/`stab` letters through `box_mem_tpOf_iff` and `stab_mem_tpOf_iff`.
- **The recorded user ruling (R1) has already been acted on by a sibling record.** The ruling
  relayed on this dispatch — a set-valued per-state datum over a quotient, opened research-first
  with the object-closure-product periodicity obligation first — is task 806
  (`specs/806_set_valued_cell_quotient_index/`), which is already `completed` with its own
  reports, plan and summary. This plan therefore files **no** successor task: doing so would
  duplicate an existing, finished record.
- **One carried figure from the report is already stale and is corrected here rather than
  repeated**: the report records `PASS all 34 wired probe(s) compile`; the `WIRED` array at
  `scripts/check-evidence-probes.sh:1234` holds **36** entries as of this plan's authoring
  (re-derived at plan time), the three additions being the sibling round's own probes. Phase 1
  confirms the current figure from the gate's own output rather than carrying either number.

### Prior Plan Reference

No prior plan. `specs/805_jointly_derived_cell_index_gate/plans/` was empty before this file; the
task ran research-first across two rounds with no intervening plan.

### Roadmap Alignment

No roadmap context was provided to this dispatch (no `roadmap_path`, no `roadmap_flag`), so no
roadmap item is claimed and no roadmap phase is added.

## Goals & Non-Goals

**Goals**:
- Re-measure, in this dispatch, that `specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`
  compiles `sorry`-free with no new axiom, and that the whole probe gate is green.
- Confirm the three records carrying the verdict agree with it and with each other: the probe's
  own header, its registration row in `scripts/check-evidence-probes.sh`, and the corrected
  `specs/761_ladder_realization_theorem/.blocker-research.json`; plus the source-store guidance
  note the round strengthened.
- Attest mechanically that no weakened, same-named substitute for `ladderRealized`, `LadderCons`
  or `ladderCons_localRun` was published anywhere, under that name or another, and that the
  `box`/`stab` clause is untouched.
- Write the completion summary artifact and pass the full gate set.
- Name, as operator actions rather than silently dropped work, the two items this repository's
  commit path cannot carry: the source-store guidance commit in `~/.config/nvim/agent-system/`,
  and the redeploy that reconciles the stale deployed `.claude/` mirror.

**Non-Goals**:
- **No positive factorization lemma, in any shape, and no sketch of one.** Step (5) of the
  dispatch was conditional on survival and the verdict removes it.
- **No weakened substitute for `ladderRealized` or `LadderCons`**, under those names or any
  other, and no `LadderCons` without the `box`/`stab` clause (plan-compliance.md Statement
  Fidelity; `stab_mem_tpOf_iff` pins the stab letter per cell).
- **No seventh coordinate, no wider tuple, and no new gate.** Re-running the refuted candidate at
  a different parameter origin is exactly the loop the record closes.
- **No gate of the object-closure-product modulus as if it were this candidate.** It is a
  different candidate; gate 6 is what it would have to be run against, and nothing on record says
  it is computable or would suffice.
- No edits under `FormalSystem/` or `Tests/` (dispatch scope), and no new Lean declaration — hence
  no `## Lean Challenge Statements` section, whose identifier set would be empty.
- No new task: the R1 successor record (task 806) already exists and is completed.
- No change to task 761's status or dependency edges; it stays `[BLOCKED]` on the corrected
  record, which says so itself.
- No commit inside `~/.config/nvim/agent-system/` and no `deploy-headless.sh` run from this task
  (see Risks).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The probe gate's whole-collection run is long and holds the shared `.lake` lock, colliding with the sibling task dispatched this same cycle | M | M | Run it detached with a hard timeout and writer-liveness polling per `context/patterns/bounded-build-waiter.md`; the gate takes the build-guard lock itself, so a wait is correct behaviour, not a hang. Treat a failure in a file outside this task's `file_scope` as possibly the sibling's in-flight edit (Territory) |
| A green probe gate is read as sufficiency credit for the candidate | H | L | Phase 2 re-reads the probe header's "What this probe does NOT say" and the registration row's withholdings, and the summary restates the standing lesson: a gate probing one coordinate certifies one coordinate only |
| The close-out round is mistaken for licence to attempt the removed step (5) | H | L | Non-Goals above are explicit; no phase has a proof task; Phase 2's attestation greps for exactly the three forbidden declaration names |
| A record is edited to "tidy" the verdict and weakens it | H | L | Phase 2's edits are conditional on a found discrepancy and are repairs *toward* the committed verdict; the no-weakening rule in the probe gate's own header governs any probe-header change |
| The source-store guidance edit is left uncommitted and is lost to a redeploy or a foreign reset | M | M | It is named as an operator action in the summary's Follow-ups with its exact path; this task does not commit in a foreign repository whose tree already carries many other writers' uncommitted modifications |
| The deployed `.claude/` guidance note disagrees with the source store until the next deploy | L | H (already true) | The source store is the authority per `source-store-deploy-boundary.md`; the remedy command is recorded in the summary rather than run from this task, since a redeploy regenerates the whole tree under a concurrently-dispatched sibling |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Re-measure the Landed Evidence [COMPLETED]

**Goal**: Establish, by this dispatch's own measurement, that the sixteenth probe compiles
`sorry`-free with no new axiom and that the whole wired probe collection is green.

**Tasks**:
- [x] Compile the probe alone first, through the guarded entry point:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`,
      detached via `Bash(run_in_background: true)` with output captured to a log; expect exit `0`
      with no output other than the file's own `#print axioms` lines.
- [x] Read the captured `#print axioms` lines and confirm no new axiom: `[propext]`,
      `[propext, Quot.sound]`, and `[propext, Classical.choice, Quot.sound]` only.
- [x] Confirm the probe carries no `sorry`, no `axiom`, no `native_decide`, and no vacuous
      definition (`grep -n 'sorry\|^axiom\|native_decide\|:= True$\|:= trivial$'` over the file;
      the only expected hits are the header's own prose about their absence).
- [x] Run the authoritative collection gate detached with a bounded waiter:
      `bash scripts/check-evidence-probes.sh`; require exit `0` and the line
      `seam-gluing-ray-product/ladder-joint-index-refutation   PASS` in its output.
- [x] Record the gate's own reported wired-probe count from this run, rather than carrying either
      the report's `34` or this plan's `36`. *(measured: the gate reports `PASS  all 37 wired
      probe(s) compile`, with 37 `PASS` lines; the `WIRED` array itself holds 36 entries and the
      37th is the separately-listed archived path at `scripts/check-evidence-probes.sh:1302`, so
      neither plan-time figure is restated)*
- [x] Confirm the probe is tracked, not merely present: `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`.

**Timing**: 0.75 hours (dominated by the detached collection run and its bounded wait)

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the `WIRED` array at `scripts/check-evidence-probes.sh:1234`
holds 36 entries (re-derived at plan-authoring time, superseding the `34` carried in
`reports/02`'s Mechanical state section) and that the probe is 1580 lines (re-derived at
plan-authoring time, matching the report). Confirm both from the gate's own output and `wc -l` in
this dispatch; report the measured figures and do not restate a plan-time number that the run
contradicts.

**Tier Justification**: The phase edits nothing and its covering check is the repository's own
probe-rot entry point, `bash scripts/check-evidence-probes.sh`, which compile-checks every wired
probe under the shared build-guard lock — no broader gate reaches a file outside the Lake build
graph.

**Files to modify**:
- none planned — this phase is measurement only and edits no file.

**Verification**:
- Both commands exited `0`, read from the guard's own `result` or the captured log's exit status
  (never a pipe's exit code).
- The probe's `PASS` line is present in the collection gate's output, and the reported count of
  wired probes is recorded verbatim from this run.
- The axiom lines, `sorry`/`axiom`/`native_decide` sweep, and `git ls-files` check are all as
  stated above.

---

### Phase 2: Record-Consistency Sweep and the No-Substitute Attestation [COMPLETED]

**Goal**: Confirm the four records carrying the verdict agree with it and with each other, and
attest mechanically that nothing weakened-substitute-shaped was published.

**Tasks**:
- [x] Re-read the probe's header sections — "What was asked", "The verdict", the six gate
      sections, "What the refutation leaves standing", "What this probe does NOT say" — and
      confirm they state the verdict of `reports/02` with the letter-definable-vs-closure
      distinction intact.
- [x] Re-read the probe's registration row and decision row in `scripts/check-evidence-probes.sh`
      and confirm the row's withholdings match the probe's own: no factorization lemma in any
      shape, no seventh coordinate, the earlier negatives untouched, the acceptance clause never
      dropped, the successor design not chosen by this record.
- [x] Validate `specs/761_ladder_realization_theorem/.blocker-research.json` parses
      (`jq empty <path>`) and confirm its `solution_path` recommends **no** index candidate, names
      the strengthened modulus clause (closure, not letters), and carries `corrected_on`,
      `corrected_by` and `supersedes`.
- [x] Confirm the source-store guidance note
      `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
      carries mechanism (6), the sixth gate-table row, the strengthened modulus clause, and a
      "what is still open" statement naming the object-closure-product modulus as the open
      candidate rather than a refuted one.
- [x] Attest the no-substitute condition mechanically: `grep -rn 'ladderRealized\|LadderCons\|ladderCons_localRun' FormalSystem/ Tests/ specs/evidence/`
      shows no declaration of any of the three (citations in prose and in probe headers are
      expected; a `theorem`/`def`/`structure` line is not), and `git status --short FormalSystem/ Tests/`
      shows this task changed nothing there.
- [x] Only if a discrepancy is found: repair it in the record that is wrong, toward the committed
      verdict, under the probe gate's own no-weakening rule — never by restating or softening an
      obstruction to make a record agree.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts the sweep covers exactly four records — the probe header,
the registration/decision rows in `scripts/check-evidence-probes.sh`, task 761's
`.blocker-research.json`, and the source-store guidance note — and that all four are already
correct, so the expected edit count is zero. Confirm by reading each of the four in this dispatch;
if any is wrong, the repair is in scope and must be reported as an edit, not as a clean sweep.

**Tier Justification**: Every edit this phase could make is prose or JSON with no compile or
elaboration surface, covered by a diff read-through plus `jq empty` on the JSON record and, for
the source-store markdown, `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system`
(explicit TARGET, since the bare form would run both gates' SKIP branch in this consumer repo).

**Files to modify**:
- `specs/761_ladder_realization_theorem/.blocker-research.json` - conditional: only if the sweep
  finds its corrected text disagrees with the verdict
- `scripts/check-evidence-probes.sh` - conditional: the probe's registration/decision rows only,
  if they disagree with the probe header
- `specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean` - conditional: header
  comment text only, never a statement or a proof
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md` -
  conditional: only if mechanism (6), the sixth gate row, or the strengthened modulus clause is
  missing or misstated (source store, per source-store-deploy-boundary.md; never the deployed
  `.claude/` mirror)

**Verification**:
- `jq empty specs/761_ladder_realization_theorem/.blocker-research.json` exits `0`.
- The four records are each read in this dispatch and reported as agreeing with the verdict, or
  the specific disagreement and its repair are named.
- The `grep -rn` attestation output is reported: no declaration of the three forbidden names, and
  `git status --short FormalSystem/ Tests/` clean of this task's work.
- If any file above was edited, a diff read-through confirms every changed hunk is prose/JSON, and
  the source-store gate subset above exits `0` for a guidance-note edit.

---

### Phase 3: Completion Summary and Full Gate Set [COMPLETED]

**Goal**: Write the task's completion summary carrying the verdict, the four unmet obligations and
the two operator actions, and close the task under the complete gate set.

**Tasks**:
- [x] Write `specs/805_jointly_derived_cell_index_gate/summaries/02_joint-index-gate-verdict-summary.md`
      with all six required sections (Overview, What Changed, Decisions, Plan Deviations, Impacts,
      Follow-ups) plus References, per `summary-format.md`.
- [x] In it: state the verdict as the successful outcome; state what the refutation does NOT say
      (it refutes the modulus clause as the rule states it, not every jointly-derived triple);
      record the strictly stronger necessary condition (object-closure-product modulus, sufficiency
      asserted nowhere); list the four unmet obligations verbatim; record that step (5) was removed
      by the verdict rather than deferred; and record that no weakened substitute was produced.
- [x] In Follow-ups, name the two operator actions with their exact commands: the source-store
      guidance commit inside `~/.config/nvim/agent-system/` (outside this repository, so this
      repo's scoped-commit path cannot carry it), and
      `timeout 540 bash .claude/scripts/deploy-headless.sh` to reconcile the stale deployed
      `.claude/` tree for the `core` and `lean` extensions.
- [x] In Follow-ups, record that the R1 ruling is already discharged by task 806 (completed), so
      no successor task is filed by this record.
- [x] Carry Phase 1's measured figures (gate verdict, wired-probe count, axiom sets) into the
      summary as measured in this dispatch, not as carried from `reports/02`.
- [x] Validate the artifact: `bash .claude/scripts/validate-artifact.sh specs/805_jointly_derived_cell_index_gate/summaries/02_joint-index-gate-verdict-summary.md summary`.
- [x] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh` and require exit `0`
      (detached with a bounded waiter; read the exit status, not a stdout diff).
      *(deviation: altered — per this dispatch's Batch Gate Deferral directive the full set is
      deferred to the batch stage of this multi-task /orchestrate invocation and the narrowing
      invocation `bash .claude/scripts/verify-deploy.sh --only-gate 4,10` ran instead, exit `0`,
      1 check run, 0 failures: gate 4 PASS, gate 10 SKIP as a deploy consumer. The phase's
      `**Verification Tier**: full` field is unedited; the full gate set is deferred, never
      forgiven, and is attributed back to this task by its own `modified_files`.)*
- [x] Commit this task's own hunks only, with an explicit file list (never `git add -A`, never a
      directory or glob pathspec), per the concurrency note on this dispatch.

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the summary is this round's artifact `02` (round 2 reuses
the research round's number; `next_artifact_number` is 3) and that it is the only file created.
Confirm the artifact number against `specs/state.json`'s entry for this task before writing, and
report any additional file the phase ends up touching.

**Files to modify**:
- `specs/805_jointly_derived_cell_index_gate/summaries/02_joint-index-gate-verdict-summary.md` -
  new: the completion summary
- `specs/805_jointly_derived_cell_index_gate/plans/02_joint-index-gate-closeout.md` - phase status
  markers updated as phases close

**Verification**:
- `bash .claude/scripts/validate-artifact.sh <summary path> summary` exits `0`.
- The complete gate set — `bash .claude/scripts/verify-deploy.sh`, the aggregator of every gate
  this repository runs — exits `0`, read from its own exit status; no `--skip-slow`, no
  `--only-gate` subset, since this is the final phase and the full set is owed here.
- `bash scripts/check-evidence-probes.sh` is green (re-confirmed by the gate set or re-run).
- The summary contains all six required sections and carries this dispatch's own measured figures.
- `git status --short` and `git diff --staged` reviewed before the commit; staged paths are this
  task's own files only.

## Testing & Validation

- [x] The sixteenth probe compiles `sorry`-free, with no new axiom, measured in this dispatch.
- [x] `bash scripts/check-evidence-probes.sh` exits `0` with the probe's `PASS` line present.
- [x] `jq empty specs/761_ladder_realization_theorem/.blocker-research.json` exits `0` and its
      `solution_path` recommends no index candidate.
- [x] No declaration of `ladderRealized`, `LadderCons` or `ladderCons_localRun` exists anywhere in
      `FormalSystem/`, `Tests/` or `specs/evidence/`, and the `box`/`stab` clause is untouched.
- [x] No file under `FormalSystem/` or `Tests/` was changed by this task.
- [x] The summary artifact validates and names the four unmet obligations and the two operator
      actions.
- [x] `bash .claude/scripts/verify-deploy.sh` exits `0`. *(deviation: altered — discharged as
      `--only-gate 4,10`, exit `0`; the full set is deferred to this invocation's batch stage per
      the Batch Gate Deferral directive.)*

## Artifacts & Outputs

- `specs/805_jointly_derived_cell_index_gate/summaries/02_joint-index-gate-verdict-summary.md` (new)
- `specs/805_jointly_derived_cell_index_gate/plans/02_joint-index-gate-closeout.md` (this plan,
  phase markers updated as phases close)
- Measured evidence recorded in the summary, not new files: the probe's compile verdict, the
  collection gate's verdict and wired-probe count, the axiom sets.
- Unchanged and not reopened: `reports/01`, `reports/02`, the probe itself, its registration, and
  the corrected `.blocker-research.json` (edited only on a found discrepancy, per Phase 2).

## Rollback/Contingency

- **Nothing in this plan is hard to revert**: Phase 1 edits no file; Phase 2's edits are
  conditional prose/JSON repairs; Phase 3 adds one summary artifact. A bad edit is reverted by
  `git checkout` of the single path *after* an explicit `bash .claude/scripts/git-snapshot.sh 805 --no-revert`
  checkpoint — never the reverting default form, which the concurrency note on this dispatch
  forbids outright this cycle.
- **If Phase 1's collection gate is red on a probe other than this task's**: that is a
  possible sibling in-flight edit or an ENVIRONMENT-class failure, not necessarily a regression
  here. Read the gate's own three diagnostic classes, report it, and do not repair another
  record's probe from this task.
- **If Phase 1's collection gate is red on *this* probe**: mark the phase `[BLOCKED]`, report the
  rot class, and repair the citation under the no-weakening rule. Do not delete or restate the
  obstruction to make the gate pass.
- **If a record disagrees with the verdict in a way a prose repair cannot settle**: mark Phase 2
  `[BLOCKED]` and raise it rather than choosing a reading. The verdict is committed; a record
  disagreeing with it is a record defect, and deciding which is right is not a close-out call.
