# Implementation Plan: Task #934

- **Task**: 934 - Depth-0 reachability probe: is `ForwardSlackWitnessed` satisfiable at the consumer instantiation
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None. Consumes landed declarations of tasks 917 and 929 and edits none of them.
- **Research Inputs**: specs/934_depth_zero_reachability_probe/reports/01_consumer-shape-reachability-probe.md
- **Artifacts**: plans/01_consumer-shape-reachability-probe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Research already compiled the probe: `ForwardSlackWitnessed` HOLDS at the consumer shape
`(q, c + m*(P+1), n)` at the positive amount `m*(P+1)` on the object `stepOr` at `φ = ⊥`, and
the restricted schema `cellLE_zero_const_of_kappa_eq_of_forwardSlack` fires there at the
periodicity fixpoint's own `ParamsOk` parameters. This plan promotes that compiled draft to the
tracked evidence collection, wires it into the CI probe guard, and records a verdict stated at
exactly the draft's reach. Definition of done: the probe is tracked, compiled by
`scripts/check-evidence-probes.sh`, documented in that script's table, and the written verdict
names which lifting event the result supports without taking the Stage 0 gate ruling.

### Premise Re-Validation (Carried-Figure Discipline)

Every figure the description carries was checked against the live tree in this dispatch:

| Carried claim | Result |
|---|---|
| `CellLEZeroConstOfKappaEqForwardSlack` at `LadderCell.lean:1492`, hypothesis at `:1503-1508` | CONFIRMED unchanged (`def` at 1492; the two `ForwardSlackWitnessed` hypotheses span 1503-1508; regime hypotheses at 1502) |
| `ForwardSlackWitnessed` at `LadderCell.lean:998-1010` | CONFIRMED unchanged |
| `hasForwardSlack_amount_le` at `LadderChain.lean:1656` | CONFIRMED unchanged |
| `ceiling_slack_at_consumer_amount` at `LadderIdle.lean:1306` | CONFIRMED unchanged |
| "the ceiling cannot bite at the consumer shape" | CONFIRMED, and now superseded in strength by the research draft: the hypothesis is not merely immune to the ceiling there, it is compiled satisfiable on one object |
| 929's `xState = (true, 2, 0)` "may be put in consumer shape" | REFUTED by research (report, Executive Summary bullet 4): `c ≥ 2` with countdown `2` forces `m*(P+1) = 0`. The witness moves to the plateau at height `c + m*(P+1)`; the object, labelling and plateau path are reused as landed |
| "Either outcome decides the gate in one direction" | NARROWED by research: a singleton-cell instance at `φ = ⊥` decides the crux as `specs/ROADMAP.md` Stage 0 states it (satisfiable at SOME reached state at a positive amount) and does NOT discharge the hypothesis in general. The verdict is worded to that bound |

The wired-probe total was also measured live: 60 `WIRED` + 1 `WIRED_REPO` = 61 today.

### Research Integration

- The compiled draft `specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean`
  is the source of the promoted probe. Its five headline declarations, in order:
  `fsw_consumer_shape`, `plateau_next_region`, `consumer_fires`, `climbC_isLadderPath`,
  `climbC_not_hasForwardSlack`. Research compiled it sorry-free through
  `lake-build-guard.sh ... env lean`, axioms a subset of `[propext, Classical.choice, Quot.sound]`.
- The draft `open`s `IdleRunOne` instead of copying the object. Kept: copying would shadow.
- The bound on reach (singleton cell `{∅}` at `φ = ⊥`; existence evidence only; no general
  discharge; no refutation; reserved name unclaimed) is mandatory content of both the module
  docstring and the documentation-table row.
- The failure direction is ARGUED, NOT COMPILED in the report. The plan carries it into the
  verdict with that label and does not upgrade it.
- A multi-type-cell instance is explicitly excluded (it needs the route-4 argument on that
  instance); it is recorded as a possible follow-up, not attempted.

### Prior Plan Reference

No prior plan for this task. The archived plan of task 929
(`specs/archive/929_idle_run_length_one_forward_slack_discharge/plans/01_idle-run-one-forward-slack.md`,
Phase 1) was read for calibration only: promoting and wiring a compiled probe took about one
hour there, the wired total is computed by the script (no hardcoded figure to edit), and the
repository's `full` gate set is the CI step list run directly.

### Roadmap Alignment

Advances `specs/ROADMAP.md` Stage 0's depth-0 gate crux by supplying compiled evidence on the
half recorded as "claimed in neither direction". This plan does NOT edit `specs/ROADMAP.md` and
does NOT take the ruling, which is reserved to the user.

## Goals & Non-Goals

**Goals**:

- Promote the compiled consumer-shape witness into the tracked evidence collection under the
  forward-slack-pin-cascade directory, with the Apache header and a module docstring stating
  what it establishes and the compiled bound on its reach.
- Wire it into the CI probe guard as a tracked WIRED entry with its documentation-table row.
- Record a written verdict naming which of the depth-0 gate's two lifting events the result
  supports, worded at exactly the probe's reach.

**Non-Goals**:

- Taking the depth-0 gate ruling (`specs/ROADMAP.md` Stage 0, reserved to the user), or editing
  `specs/ROADMAP.md` at all.
- Editing any file under `FormalSystem/**`. In particular `LadderCell.lean` stays byte-unchanged
  and no declaration is promoted into the library; consequently no module-inventory block and no
  `typst/generated/status.typ` count moves.
- Claiming the reserved name `cellLE_zero_const_of_kappa_eq`, or stating that the gate is decided.
- Restating the probe over the per-path form (already refuted by
  `ClimbWitness.hasForwardSlack_refuted_unconditional`), or retrying the pin-layer discharge
  route (refuted by `pin-cascade-straddle.lean`).
- A richer-formula (multi-type cell) instance, a general discharge of `ForwardSlackWitnessed`,
  or route 4 (simultaneous multi-region shortening).
- `real_certStabK`, which belongs to task 761's chain.

## Decisions

- **Zero Lean goals.** The plan's theorems live in a probe under `specs/evidence/`, outside every
  Lake source root by design (the probe guard, not `lake build`, compiles it). A Goals identifier
  would be searched for in the resolved Lean source roots and could never be found there, so the
  plan declares zero Lean goals and pins the five headline names in Phase 1's verification
  instead.
- **Positive direction only.** The compiled positive witness is reported; the failure direction
  stays labelled argued-not-compiled. No attempt is made to compile a non-ceiling failure.
- **Namespace `ProbeConsumerShape`** replaces the draft's task-numbered `Probe934`. The probe file
  is under `specs/**` and exempt either way; the rename keeps the name stable under task
  renumbering and keeps a task number out of anything the script's table might quote.
- **Verdict carriers.** The durable carriers are the probe's module docstring and the script's
  documentation-table row (both compiled or CI-adjacent and tracked); the implementation summary
  restates it for the task record. `specs/ROADMAP.md` is not a carrier.
- **Task-local draft is deleted after promotion**, because `scripts/check-evidence-probes.sh`'s
  header forbids a probe living under a task directory, and a second copy would drift.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The result is over-read as a general discharge or as deciding the gate | H | M | Bound on reach is mandatory in docstring, table row and verdict, in a "What it does NOT establish" shape; Phase 2 greps for forbidden phrasings |
| Text in `scripts/check-evidence-probes.sh` (outside `specs/**`) carries a task number or draft-history phrasing ("previously", "no longer") | M | M | Row cites declaration names and filenames only; `verify-deploy.sh --only-gate 4` run in Phase 1 |
| Rename `Probe934` → `ProbeConsumerShape` misses the trailing `open ... Probe934` line | L | M | Phase 1 verification greps the promoted file for `Probe934` and requires zero hits |
| A landed declaration the draft cites has drifted since research (other agents are live on this repository) | M | L | The probe guard recompiles the promoted file in Phase 1; on failure repair the citation under the no-weakening rule, never weaken a statement |
| Pre-commit hook blocks the Phase 1 commit: it fires on any staged `.lean` and runs `scripts/typst-sync-check.sh --counts-only`, which reads the WORKING TREE, so a concurrent agent's uncommitted `FormalSystem/**` edit can show as drift | M | M | This plan moves no `FormalSystem/**` line; if the hook reports drift, confirm with `git status --short` that the drifted files are foreign, do NOT run `--fix` to absorb foreign drift, record via `issue-record.sh`, and retry after a bounded wait; if still blocked, return `partial` naming the foreign writer |
| Concurrent `lake` invocations collide | M | M | Compile only through `bash .claude/scripts/lake-build-guard.sh`; `check-evidence-probes.sh` failures labelled ENVIRONMENT are retried, not repaired |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Promote and wire the consumer-shape witness probe [COMPLETED]

**Goal**: The compiled witness lives at the collection path a probe belongs at, is tracked by git,
is compiled on every CI run, and states its own reach.

**Tasks**:

- [x] Confirm the correction/promotion source exists:
      `specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean`
      (confirmed present and git-tracked at plan time). If it is absent, STOP and return
      `partial`; do not re-derive the probe from the report's prose.
- [x] Create `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean` from the
      draft: keep the Apache header, both imports, every declaration and proof body VERBATIM,
      and the trailing `#print axioms` section for the five headlines. Rename the namespace
      `Probe934` to `ProbeConsumerShape` at all three sites (`namespace`, `end`, and the trailing
      `open ... .Probe934`).
- [x] Insert a `/-! ... -/` module docstring directly after the imports, in the shape of the
      sibling `idle-run-one-ceiling.lean`, with these sections:
      (a) **POSITIVE** headline: `ForwardSlackWitnessed` holds at the consumer shape
      `(true, c + m*(P+1), 0)` at amount `m*(P+1)`, for every `c`, `m`, `P`, on `stepOr` at
      `φ = ⊥` (`fsw_consumer_shape`), and the slack premise is inhabited on the witness path by a
      genuine next region at idle-run length `1` (`plateau_next_region`), so the regime is not
      met vacuously;
      (b) the restricted schema fires: `consumer_fires` inhabits the whole hypothesis set of
      `cellLE_zero_const_of_kappa_eq_of_forwardSlack` at `Tcof/Tnof/Pof/Bof` (so `ParamsOk` by
      `paramsOk_params`), `c := Tc + B + 2`, `m := 1`, and applies the theorem;
      (c) the existential over paths is doing real work: `climbC_isLadderPath` and
      `climbC_not_hasForwardSlack` give a second ladder path through the same state with no
      forward slack at any positive amount, so the per-path form fails where the cell-level form
      holds;
      (d) two reading aids the report asks the docstring to carry: at `c' = c + l` the regime
      reduces to "the next region's countdown is at most `n + c + I`", and the upward cell
      inclusion (`cellAt_subset_of_shift_of_pend_past`) is unconditional, so only the reverse
      inclusion consumes the hypothesis;
      (e) **What this probe does NOT establish**: the cell at `φ = ⊥` is the singleton `{∅}`, so
      one path witnesses every type; this is existence evidence at one object and NOT a general
      discharge of `ForwardSlackWitnessed`; it refutes nothing about `CellLEZeroConstOfKappaEq`;
      the reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing in the file; the
      five depth-0 schemas keep the hypothesis; no non-ceiling failure mechanism is compiled in
      either direction;
      (f) **Verdict**: supports the `cellLE_zero_const_of_kappa_eq`-lands-as-a-theorem lifting
      event, as existence evidence only; the gate ruling is not taken here. *(deviation: altered — the docstring verdict says "a theorem resting on no placeholder axiom" instead of "sorryAx-free", so this phase's own `grep -c 'sorry...'` gate stays at 0)*
- [x] `git add -- specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean` so the
      probe is TRACKED before the guard runs (`check_probe` tests `git ls-files --error-unmatch`).
- [x] Add `"forward-slack-pin-cascade/consumer-shape-witness"` to the `WIRED` array in
      `scripts/check-evidence-probes.sh`, directly after
      `"forward-slack-pin-cascade/idle-run-one-ceiling"`, AND add its row to the documentation
      table in the comment block above the array, directly after the `idle-run-one-ceiling` row,
      in the same two-column `# probe | the decision it holds in place` shape and 59-column
      left gutter. The row states the positive headline, names the five headline declarations,
      carries the "What it does NOT establish" clause from (e), and ends with the axioms line.
      It cites declaration names and filenames only: no task number, and no draft-history
      phrasing ("previously", "no longer", "formerly"). *(deviation: altered — the pre-edit wired total (61) was read from the WIRED/WIRED_REPO array lengths at HEAD, which is the script's own `wired_total` computation, instead of a second full pre-edit guard run; the post-edit run printed `PASS  all 62 wired probe(s) compile`)*
- [x] Delete the task-local draft
      `specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean` with
      `git rm` (single explicit path), after the promoted copy has compiled.
- [x] Add a one-line forward pointer to the promoted path in the research report's
      `**Artifacts**` line, so its citation of the draft does not go stale.
- [x] Record any deviation or win via `issue-record.sh` as it arises (dispatch contract).

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the wired total moves `61 → 62` (60 `WIRED` + 1 `WIRED_REPO` measured at
plan time), with NO hardcoded total to edit because the script computes `wired_total` from the two
array lengths. Other agents are live, so the starting figure may have moved: the implementer
confirms by reading the script's `PASS  all N wired probe(s) compile` line before and after the
edit and requiring `after = before + 1`, not the literal `62`. The edit set is hypothesised to be
exactly the four paths below, none under `FormalSystem/**`; confirm with `git status --short`.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for both
`scripts/check-evidence-probes.sh` and the new probe path (run at plan time), so no shell suite
covers them, and the covering checks are `bash scripts/check-evidence-probes.sh` (byte-for-byte
CI step `evidence-probes`: compiles the promoted file through `lake env lean` and tests its
tracked status) plus `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4` for the
task-reference lint over the script's new comment rows.

**Files to modify**:
- `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean` - CREATED: promoted probe, verbatim proofs, renamed namespace, module docstring with reach bound and verdict
- `scripts/check-evidence-probes.sh` - EXISTS (confirmed): one `WIRED` entry plus its documentation-table row
- `specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean` - EXISTS (confirmed, tracked): DELETED after promotion
- `specs/934_depth_zero_reachability_probe/reports/01_consumer-shape-reachability-probe.md` - EXISTS (confirmed): one forward-pointer added to the `**Artifacts**` line

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits `0` and its `PASS` line names one more wired
  probe than the pre-edit run. A line labelled ENVIRONMENT is retried, not treated as rot.
- `git ls-files --error-unmatch specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean`
  exits `0`.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 500 -- env lean specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean`
  exits `0`; its output carries no `sorry` warning, and each of the five `#print axioms` lines
  (`fsw_consumer_shape`, `plateau_next_region`, `consumer_fires`, `climbC_isLadderPath`,
  `climbC_not_hasForwardSlack`) lists a subset of `[propext, Classical.choice, Quot.sound]` with
  no `sorryAx`.
- `grep -c 'sorry\|native_decide\|Probe934' specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean`
  returns `0`.
- The promoted file's declarations diff against the draft (read from `git show HEAD:<draft path>`)
  differs only in the namespace name and the added docstring.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4` reports no task-reference
  finding naming `scripts/check-evidence-probes.sh`; pre-existing findings in other files are
  enumerated, not fixed.
- `git diff --stat -- FormalSystem/` attributable to this task is empty.

---

### Phase 2: Record the verdict and run the full gate set [NOT STARTED]

**Goal**: The written verdict is on the task record at exactly the probe's reach, and the
repository's complete gate set is green or its every red is enumerated as pre-existing and
outside this plan's file scope.

**Tasks**:

- [ ] Write the verdict section of the implementation summary with this content and no more:
      (1) the question, as `specs/ROADMAP.md` Stage 0 states the crux; (2) the compiled answer:
      satisfiable at the consumer shape at a positive amount, non-vacuously, and the restricted
      schema fires there under `ParamsOk`, citing the five headline names and the probe path;
      (3) which lifting event it supports: `cellLE_zero_const_of_kappa_eq` landing as a
      sorryAx-free theorem, AS EXISTENCE EVIDENCE ONLY; (4) what it does not do: no general
      discharge (singleton cell at `φ = ⊥`), no refutation of `CellLEZeroConstOfKappaEq` under
      `ParamsOk`, reserved name unclaimed, hypothesis still carried by all five depth-0 schemas,
      `certStabK`'s restatement obligation unchanged; (5) the failure direction, labelled ARGUED
      NOT COMPILED, with the report's observation that a failure of the hypothesis would not by
      itself refute the schema (a refutation needs a type in the higher cell absent from the
      lower one); (6) an explicit line that the Stage 0 ruling is NOT taken and that the
      roadmap's "claimed in neither direction" wording is left for the user or a `/roadmap` pass;
      (7) the candidate follow-up (a multi-type-cell instance, equivalent to route 4 at the cell
      level), named but not filed.
- [ ] Check the three verdict carriers (probe docstring, script table row, summary) say the same
      thing: none contains "gate is decided", "discharged" without "NOT", or a claim on the
      reserved name.
- [ ] Run the complete gate set below and record each outcome as a delta against the pre-task
      commit.
- [ ] Confirm the out-of-scope constraints held: `git diff <pre-task-sha> -- FormalSystem/` and
      `git diff <pre-task-sha> -- specs/ROADMAP.md` show nothing authored by this task.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `specs/934_depth_zero_reachability_probe/summaries/01_consumer-shape-reachability-probe-summary.md` - CREATED: implementation summary carrying the written verdict

**Verification**:

The complete repository gate set: `bash .claude/scripts/verify-deploy.sh` (the agent-system
aggregator) and the steps `.github/workflows/ci.yml` runs, each invoked directly:

- `bash .claude/scripts/verify-deploy.sh` — result recorded; findings naming this plan's touched
  files are distinguished from the deploy tree's standing baseline (the dispatch reports the
  deployed `core` extension as stale, so pre-existing reds there are expected and are enumerated,
  not repaired, and no `.claude/**` file is hand-patched).
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits `0` with no new
  `error:` or `warning:` (CI builds with `--wfail`), and `lake test` passes. No `FormalSystem/**`
  file is touched, so this is a regression check, not a first compile.
- `bash scripts/check-evidence-probes.sh` exits `0` with the wired total one above the pre-task
  figure.
- `bash scripts/check-module-invariants.sh --no-build` and
  `bash scripts/check-module-invariants.sh --emit-inventory --check` (no block would change).
- `bash scripts/check-copyright-headers.sh --strict`.
- `bash scripts/readme-lint.sh`.
- `bash scripts/check-metalogic-cycles.sh`.
- `bash scripts/typst-sync-check.sh`.
- `bash scripts/check-paper-definitions.sh`.
- `lake exe mk_all --lib FormalSystem --check`.
- `lake exe lint-style`.
- `bash .claude/scripts/validate-artifact.sh` on the summary.

Each gate is reported as a DELTA: a gate whose only findings are pre-existing and name no file in
this plan's scope is a recorded PASS for this phase with the findings enumerated (task 929's
record shows `lint-style` and `check-paper-definitions.sh` red for reasons outside any probe
task; re-measure, do not assume). It is not a blocker and not grounds to edit an out-of-scope file.

## Lean Challenge Statements

This plan has no theorem deliverable in any Lake source root: its declarations live in an
evidence probe under `specs/evidence/`, compiled by the probe guard. See `## Decisions`.

<!-- lean-challenge-statements:none -->

## Testing & Validation

- [ ] The promoted probe compiles sorry-free through the probe guard, axioms a subset of
      `[propext, Classical.choice, Quot.sound]` on all five headlines.
- [ ] The probe is tracked, wired, and has its documentation-table row; wired total is `+1`.
- [ ] `FormalSystem/**` (in particular `LadderCell.lean`) and `specs/ROADMAP.md` carry no change
      from this task.
- [ ] `cellLE_zero_const_of_kappa_eq` is declared by nothing this task added (exact-name grep of
      the promoted probe for `theorem cellLE_zero_const_of_kappa_eq ` and
      `def cellLE_zero_const_of_kappa_eq ` returns nothing; the `..._of_forwardSlack` application
      inside `consumer_fires` is a use, not a declaration).
- [ ] The verdict names the supported lifting event, is worded as existence evidence, labels the
      failure direction argued-not-compiled, and does not take the gate ruling.
- [ ] No file outside `specs/**` gains a task-number reference or draft-history phrasing.
- [ ] Full gate set recorded per Phase 2, every red enumerated as pre-existing or fixed.

## Artifacts & Outputs

- `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean` (new, tracked probe)
- `scripts/check-evidence-probes.sh` (one `WIRED` entry, one table row)
- `specs/934_depth_zero_reachability_probe/summaries/01_consumer-shape-reachability-probe-summary.md` (written verdict)
- `specs/934_depth_zero_reachability_probe/reports/01_consumer-shape-reachability-probe.md` (forward pointer)
- Removed: `specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean`

## Rollback/Contingency

- **The promoted probe does not compile** (a cited declaration drifted): repair the citation only;
  never weaken a statement or delete a headline to pass. If a headline genuinely no longer holds,
  STOP, leave the `WIRED` entry out, keep the task-local draft, and return `partial` with the
  failing goal — that is a finding about the verdict, not a wiring problem.
- **Revert of landed work**: every edit is additive and confined to four paths, so revert is
  `git revert` of this task's phase commits; no working-tree-discarding command is needed. If a
  rollback of uncommitted work is ever required, follow `context/contracts/recovery.md`'s rollback
  rung rather than a bare snapshot.
- **Pre-commit hook blocked by foreign count drift**: see Risks; do not absorb foreign drift with
  `--fix`, do not use `--no-verify`.
- **A Phase 2 gate is red for a pre-existing reason**: enumerate, show each touched file passes
  individually, record PASS-with-enumeration.
- **A foreign commit or foreign uncommitted modification touches this plan's four paths**: STOP
  and report; do not absorb or overwrite it.
