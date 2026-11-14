# Implementation Plan: Task #929

- **Task**: 929 - Discharge the `I = 1` idle-run sub-regime so `ForwardSlackWitnessed` becomes unconditional
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: None blocking. Territory-concurrent with task 930 (no declared file scope).
- **Research Inputs**: specs/929_idle_run_length_one_forward_slack_discharge/reports/01_idle-run-one-forward-slack.md
- **Artifacts**: plans/01_idle-run-one-forward-slack.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The task's stated goal is REFUTED, not dischargeable, and the refutation is already compiled
(`specs/929_idle_run_length_one_forward_slack_discharge/evidence/i-one-ceiling.lean`, sorry-free,
standard axioms). The task description itself admits a refutation as an equally reportable outcome
provided it is compiled, so this plan executes the refutation's disposition rather than an
`I = 1` discharge: promote the probe into the tracked evidence collection and wire it into CI,
land its headline declarations in `LadderIdle.lean` beside task 924's conditional discharge, and
restate the frontier at the three docstring sites that currently assert the `I = 1` case is
"dischargeable on the pumpable side, not refuted outright" — a claim the compiled result
falsifies for the every-amount shape. `LadderCell.lean` is NOT edited: all five depth-`0`
cell-equality schemas keep `ForwardSlackWitnessed`, because the refutation does not reach their
instantiation. `certStabK`'s restatement obligation stays PROVISIONAL, not permanent.

### Premise Re-Validation (Carried-Figure Discipline)

Every trigger-class line in the dispatch `## Description` was checked against the research report
and against live state. Results, stated explicitly including the confirmations:

| Carried claim | Verdict |
|---|---|
| `forwardSlackWitnessed_of_cell_idleRunPumpable` at `LadderIdle.lean:1035` | CONFIRMED — the `theorem` line is at 1035 today |
| `hno` (the stab-free closure hypothesis) at `LadderIdle.lean:1040` | CONFIRMED — `(hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)` is at 1040 |
| Five depth-`0` cell-equality schemas in `LadderCell.lean` (`_of_forwardSlack` + `_commonShift_`, `_monotone_`, `_antitone_`, `_antitone_bounded_`) | CONFIRMED — all five are named in `LadderCell.lean`'s module docstring and in `RaySummary/README.md` |
| `(K1)` quantifies `prodCycleLens`, `objCycleLens`, `satPeriod`, never `idleCycleLens` | CONFIRMED — restated verbatim in `LadderIdle.lean:1025-1026` and `LadderChain.lean:133-135` |
| Reserved name `cellLE_zero_const_of_kappa_eq` claimed by nothing | CONFIRMED — every occurrence in `FormalSystem/` is a docstring assertion that it is unclaimed; no declaration carries it |
| "Closing it is dischargeable on the pumpable side rather than refuted" | **FALSIFIED** — the research dispatch compiled `forwardSlackWitnessed_refuted_I_one`, a cell-level refutation of `ForwardSlackWitnessed` at amount `4` on a serial, idle-cycle-free object. This is the single premise change that reshapes the whole plan |
| `certStabK`'s obligation PROVISIONAL rather than permanent | CONFIRMED as the current wording (`LadderChain.lean:139-142`, `:1391-1393`) and PRESERVED by this plan — the refutation reaches the every-amount shape only, not the consumer instantiation (`ceiling_slack_at_consumer_amount`) |
| Research report's "move the wired total `55 → 56`" | **CORRECTED** — the live tables hold 57 `WIRED` entries plus 1 `WIRED_REPO` entry, so the total moves `58 → 59`; and no hardcoded total exists to edit, because `check-evidence-probes.sh:2692` computes `wired_total` from the array lengths. The plan therefore schedules no numeric edit for this |

### Research Integration

Four findings from the research report are load-bearing here:

1. **The ceiling is the whole mechanism.** `hasForwardSlack_amount_le` (`LadderChain.lean:1628`)
   forces `(l : ℤ) ≤ n + cntAt g z + I` whenever a genuine next region exists. On an object with
   no idle self-loop every idle run has length exactly `1` on every path, so the ceiling binds
   uniformly over all paths through a state — which closes the "existential over paths" escape
   `LadderChain.lean`'s docstring records as the reason the pin-cascade refutation stops at the
   path level.
2. **The refutation's reach is bounded and the bound is compiled.**
   `ceiling_slack_at_consumer_amount` shows `m·(P+1) ≤ n + (c + m·(P+1)) + I` for `0 < I`, so the
   five depth-`0` schemas' instantiation at the higher state is untouched. Every library
   statement of the refutation must cite it.
3. **Consistency with task 924 is compiled, not argued.** `not_idleRunPumpable` shows
   `IdleRunPumpable` is unsatisfiable on the whole object, so `hprem` is false there and the two
   results cannot collide.
4. **The surviving frontier is route 4 at the cell level** (simultaneous multi-region shortening),
   with three enumerated, undischarged obligations. The plan records it; it does not attempt it.

### Prior Plan Reference

No prior plan for this task. Task 924's archived summary
(`specs/archive/924_forward_slack_witnessed_frontier_disposition/summaries/01_forward-slack-frontier-disposition-summary.md`)
was read by the research dispatch for the frontier statement this plan now corrects; no phase
structure is carried over from it.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch's delegation context and the `roadmap_flag` is
not set, so no roadmap phases are added. `specs/ROADMAP.md` is not read, modified, or created by
this plan.

## Goals & Non-Goals

**Goals**:

- Promote the compiled refutation probe into `specs/evidence/` and wire it into the CI probe
  guard, so the obstruction it records cannot silently rot.
- Land the probe's declarations in `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean`
  as a self-contained `section IOne`, stated at exactly their reach and no further.
- Restate the `I = 1` frontier at the three sites that currently assert it is dischargeable:
  `LadderChain.lean`'s module docstring, `LadderChain.lean`'s
  `exists_deleted_ladderPath_of_next_region_nxt` docstring, and `LadderIdle.lean`'s module
  docstring and item `(ii)`/`(iii)` block.
- Keep every coupled generated surface in step, in the phase that moves its input.

**Non-Goals**:

- An `I = 1` discharge at every amount. It is refuted; attempting it is forbidden by the
  evidence, not merely out of scope.
- The `(K1)` amendment constraining spanning-block length. PROHIBITED by the task description and
  explicitly declined by task 924.
- Claiming the reserved name `cellLE_zero_const_of_kappa_eq`, on any branch.
- Editing `LadderCell.lean` or any of its five depth-`0` schemas. The refutation does not reach
  their instantiation, so no hypothesis is removed and no signature is touched. Task 761's Phase
  11.6 depth-`0` gate is untouched.
- Flipping `certStabK`'s restatement obligation from PROVISIONAL to permanent. The compiled
  result does not support it.
- Pursuing route 4 (simultaneous multi-region shortening). It is recorded as the surviving
  frontier; discharging it is a follow-on task.
- Adding a `docs/theorem-index.md` row. The new declarations are an obstruction record, not an
  index-worthy positive result; C15's obligation runs row → `Paper:` line, so adding no row
  incurs no `Paper:` obligation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `LadderChain.lean` crosses 3000 lines under the docstring restatement, invalidating its declared `set_option linter.style.longFile 3000` | H | M | At 2956 lines today the accepted baseline set is `{3000, 3100}`; at 3000+ it becomes `{3100, 3200}`. Phase 3 carries the headroom measurement and re-tightens in the same phase if crossed. CI builds with `--wfail`, so this would be a hard failure, not a note |
| `typst/generated/status.typ`'s `formalsystem-line-count` drifts and `.githooks/pre-commit` refuses the phase's own commit | H | H | Each phase that changes a `FormalSystem/**` `.lean` line count runs `scripts/typst-sync-check.sh --fix` and carries `typst/generated/status.typ` in its OWN file list — never deferred to the final phase |
| Verbatim promotion of the probe's `def` names fails C26 (non-trailing underscores in `def`/`abbrev`) | M | L | Measured: the probe's three `def`s are `stepOr`, `labB`, `xState` — all lowerCamelCase, no underscores. The promotion is verbatim and C26-clean as it stands |
| The `Probe929` namespace lands inside `FormalSystem/` and violates the no-task-references rule | M | M | `specs/**` is exempt, so the promoted probe keeps `Probe929` (matching `Probe924B`/`Probe924C` precedent in the same directory). The `FormalSystem/` transcription uses `namespace IdleRunOne` instead — confirmed free of collisions, as are `stepOr`, `labB`, `xState` in the `RaySummary` namespace |
| The refutation is read as closing the whole `ForwardSlackWitnessed` programme | H | M | Every library statement of it cites `ceiling_slack_at_consumer_amount` in the same breath, so the limit is a compiled fact rather than a prose caveat; Phase 2's section docstring and Phase 3's restatements both carry it |
| A sibling task (930, no declared file scope) touches the same tree concurrently | M | M | Re-read every file immediately before editing; stage explicit file lists only, never a directory or glob; never `git-snapshot.sh` in its reverting default mode; treat an unexplained build failure outside this plan's file scope as possibly a sibling's in-flight edit and report rather than "fix" it |
| The research report's path citation to the probe goes stale when the probe is promoted | L | H | Phase 1 updates the report's `Artifacts` line with a forward pointer to the promoted path in the same phase as the move |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan's waves are each a single phase:
the chain is genuinely serial, because Phase 2's section docstring cites the promoted probe path
Phase 1 creates, Phase 3's restatements cite the declaration names Phase 2 lands, and Phase 4
regenerates inventory blocks from the line counts Phases 2 and 3 produce.

---

### Phase 1: Promote and wire the compiled refutation probe [COMPLETED]

**Goal**: The `I = 1` refutation lives at the collection path a probe belongs at, is tracked by
git, and is compiled on every CI run so it cannot rot.

**Tasks**:

- [x] Create `specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean` holding the
      task-local probe's content VERBATIM — all three `def`s and all ten theorems, the
      `Probe929` namespace, and the trailing `#print axioms` section (`#print axioms` in a probe
      has precedent: `seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` carries 8).
- [x] Prepend the four-line Apache copyright header the sibling probes in the same directory
      carry (`pin-cascade-straddle.lean`, `route-space-closure.lean`), and expand the file's
      one-line `/-! ... -/` into a module docstring naming (a) what the probe refutes, (b) that
      the refutation does NOT reach the five depth-`0` schemas, citing
      `ceiling_slack_at_consumer_amount`, and (c) that the reserved name
      `cellLE_zero_const_of_kappa_eq` is claimed by nothing in it.
- [x] `git add -- specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean` so the
      probe is TRACKED, not merely present — `check_probe` tests this with
      `git ls-files --error-unmatch` after the presence test.
- [x] Delete the task-local copy
      `specs/929_idle_run_length_one_forward_slack_discharge/evidence/i-one-ceiling.lean`;
      `check-evidence-probes.sh`'s own header forbids a probe living under a task directory.
- [x] Add `"forward-slack-pin-cascade/idle-run-one-ceiling"` to the `WIRED` array in
      `scripts/check-evidence-probes.sh`, beside the two existing
      `forward-slack-pin-cascade/*` entries, AND add its row to the documentation table in the
      comment block directly above the array, in the same
      `# probe | the decision it holds in place` two-column shape the neighbouring rows use.
- [x] Add a one-line forward pointer to the promoted path in the research report's `**Artifacts**`
      list, so the landed record's citation does not go stale.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the wired total moves `58 → 59` (57 `WIRED` entries + 1 `WIRED_REPO` entry
today), and NO hardcoded total exists anywhere to edit — `check-evidence-probes.sh:2692` computes
`wired_total` from the two array lengths. The implementer confirms both halves by reading the
script's own `PASS all N wired probe(s) compile` line after the edit, and by
`grep -rn "5[5-9] probe\|wired total"` over `scripts/` and `docs/` returning no hardcoded figure
to update. This supersedes the research report's "move the wired total `55 → 56`", which this
plan measured as wrong on both the figure and the existence of an edit site.

**Tier Justification**: `bash scripts/check-evidence-probes.sh` is byte-for-byte the gate CI runs
as step id `evidence-probes`, and it compiles the promoted file through `lake env lean` and tests
its git-tracked status — covering the whole of this phase's edit with no `FormalSystem/**` line
count moved and therefore no generated surface in play.

**Files to modify**:
- `specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean` - CREATED: the promoted probe, verbatim content plus copyright header and expanded module docstring
- `scripts/check-evidence-probes.sh` - EXISTS (confirmed): one `WIRED` array entry plus its documentation-table row
- `specs/929_idle_run_length_one_forward_slack_discharge/evidence/i-one-ceiling.lean` - EXISTS (confirmed): DELETED, superseded by the promoted copy
- `specs/929_idle_run_length_one_forward_slack_discharge/reports/01_idle-run-one-forward-slack.md` - EXISTS (confirmed): one forward-pointer line added to the `**Artifacts**` list

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits `0` and its `PASS` line names 59 wired probes.
- `git ls-files --error-unmatch specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean`
  exits `0`.
- `grep -c sorry specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean` returns `0`.
- `git status --short` before staging shows only this phase's four paths among this task's own
  changes; any foreign modification is reported, not absorbed.

---

### Phase 2: Land the refutation in `LadderIdle.lean` as `section IOne` [COMPLETED]

**Goal**: The five headline declarations are part of the library, inside the module that holds
task 924's conditional discharge, stated at exactly their reach.

**Tasks**:

- [x] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` immediately before
      editing (sibling task 930 declares no file scope).
- [x] Open a new `section IOne` after the existing final section, with a section docstring that
      states: the refutation's statement and its object; that it is the repository's first
      CELL-level refutation of `ForwardSlackWitnessed` and why the existential-over-paths escape
      closes here (the ceiling is forced by the OBJECT, not by the path); that it does NOT reach
      the five depth-`0` schemas, citing `ceiling_slack_at_consumer_amount`; that `certStabK`'s
      obligation stays PROVISIONAL; that `LadderCell.lean` is not edited and no schema's
      signature is touched; and that `cellLE_zero_const_of_kappa_eq` is claimed by nothing here.
- [x] Inside it, open `namespace IdleRunOne` (confirmed free; chosen over the probe's `Probe929`
      because `.claude/rules/no-task-references-in-deliverables.md` forbids a task-number
      reference outside `specs/**`) and transcribe, in the probe's own order: `stepOr`,
      `stepOr_idle_idle`, `fwdOr`, `bwdOr`, `plateau_isLadderPath_stepOr`, `labB`, `xState`,
      `plateau_two_at_zero`, `next_pend_of_idle`, `not_hasForwardSlack_of_four`,
      `forwardSlackWitnessed_refuted_I_one`, `xState_regime`, `not_idleRunPumpable`,
      `ceiling_slack_at_consumer_amount`, `tpOf_bot_eq_empty`,
      `forwardSlackWitnessed_holds_below_ceiling`. *(deviation: altered — `next_pend_of_idle`'s
      `show objAt g (u + 1) = true` became `change ...`; the library build runs
      `linter.style.show`, which the standalone probe's `lake env lean` compile does not, and
      this phase's own criterion bars warnings. Proof text is otherwise verbatim.)*
- [x] Give each declaration its own doc comment. Add NO `Paper:` line and NO
      `docs/theorem-index.md` row — C15's obligation runs row → `Paper:` line, so adding no row
      incurs no obligation; record this as a deliberate choice in the section docstring.
- [x] Do NOT carry over the probe's trailing `#print axioms` section — run those checks as
      verification instead, so the library file emits no `info` output on every build.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` IN THIS
      PHASE. `.githooks/pre-commit` enforces this surface and fires on any staged `.lean` path,
      so drift here BLOCKS this phase's own commit and cannot be deferred.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: `LadderIdle.lean` goes from 1080 lines to roughly 1280, which stays under
the `linter.style.longFileDefValue` ceiling of 1500, so NO `set_option linter.style.longFile`
baseline is needed. The implementer confirms with `wc -l` after the edit; if the file does cross
1500, the baseline is added in this same phase at the linter's own
`candidate = max(1500, (lines / 100) * 100 + 200)`, never at an anticipated final value, since
only `{candidate - 100, candidate}` are accepted. No new `import` line is added (`ClimbWitness`
arrives via `LadderChain`, and `tpOf`/`cellAt`/`plusSubformulaClosure` via `LadderCell`, both
already imported), so `check-metalogic-cycles.sh` Assertion B's frozen allowlist is untouched —
confirm by `grep -n "^import" ` on the file showing the same two lines as before.

**Tier Justification**: the phase adds declarations to a module `LadderWindow.lean` imports, so a
build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle` plus its one direct
dependent `...LadderWindow` covers the full elaboration surface the edit can reach; the one
generated surface it moves (`typst/generated/status.typ`) is regenerated and checked inside this
same phase.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` - EXISTS (confirmed, 1080 lines): new `section IOne` / `namespace IdleRunOne` holding the sixteen transcribed declarations and the section docstring
- `typst/generated/status.typ` - EXISTS (confirmed): `formalsystem-line-count` regenerated via `scripts/typst-sync-check.sh --fix`, in this phase because the surface is pre-commit blocking

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle`
  exits `0` with zero `error:` AND zero `warning:` — CI builds with `--wfail`, so a warning is a
  failure, not a note.
- The same guarded build on `FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow` (the
  one direct dependent) exits `0`, same zero-warning bar.
- `#print axioms` on `forwardSlackWitnessed_refuted_I_one`,
  `forwardSlackWitnessed_holds_below_ceiling`, `not_idleRunPumpable`, `xState_regime` returns
  `[propext, Classical.choice, Quot.sound]`, and on `ceiling_slack_at_consumer_amount` returns
  `[propext, Quot.sound]`. No `sorryAx`, no non-standard axiom.
- `bash .claude/scripts/lean-sorry-census.sh` shows no new `sorry` relative to the pre-phase
  count (a delta against the baseline, not an absolute zero).
- `bash scripts/typst-sync-check.sh --counts-only` exits `0`.
- `grep -n "cellLE_zero_const_of_kappa_eq" FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean`
  shows the name only in docstring assertions that it is unclaimed — no declaration carries it or
  any prefix of it.
- `grep -niE "task [0-9]|Probe[0-9]" FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean`
  returns nothing (no task-number reference outside `specs/**`).

---

### Phase 3: Restate the `I = 1` frontier at the three asserting sites [COMPLETED]

**Goal**: No docstring in the library still asserts that the `I = 1` case is dischargeable on the
pumpable side; each instead names the compiled refutation and its exact reach.

**Tasks**:

- [x] Re-read each file immediately before editing (concurrent sibling task 930).
- [x] `LadderChain.lean` module docstring (the block ending at line 142): replace "but it is now
      blocked on a condition that IS dischargeable on the pumpable side, not on one refuted
      outright" with the compiled finding — the `I = 1` complement is REFUTED at the every-amount
      shape by `forwardSlackWitnessed_refuted_I_one` (`LadderIdle.lean`, `section IOne`) — while
      KEEPING the `certStabK` consequence PROVISIONAL, because
      `ceiling_slack_at_consumer_amount` compiles that the ceiling is slack at the consumer's own
      instantiation. Name route 4 (simultaneous multi-region shortening) as the surviving
      frontier, with its three undischarged obligations.
- [x] `LadderChain.lean`'s `exists_deleted_ladderPath_of_next_region_nxt` docstring (the "THE
      ROUTE THAT IS NOT REFUTED" block ending at line 1393): same correction, same preserved
      provisionality.
- [x] `LadderIdle.lean` module docstring (the `LadderWindow.lean imports this module` paragraph,
      lines ~35-42): add that this module now ALSO holds the `I = 1` refutation, and that
      `ForwardSlackWitnessed` stays a carried hypothesis on all five depth-`0` schemas for the
      reason `ceiling_slack_at_consumer_amount` compiles, not merely because they were not
      edited.
- [x] `LadderIdle.lean`'s `forwardSlackWitnessed_of_cell_idleRunPumpable` docstring items `(ii)`
      and `(iii)` (lines ~1028-1034): correct "What is open after this theorem is exactly the
      complementary side: the paths whose intervening idle run has length `1`" to name that
      complement as now REFUTED at the every-amount shape, and leave item `(iii)`'s reserved-name
      assertion unchanged. *(deviation: altered — this phase also rephrased one sentence of
      `section IOne`'s own docstring in the same file, which quoted the superseded
      "dischargeable on the pumpable side" wording verbatim; that quotation would have
      failed this phase's own grep criterion and is record-versioning language
      `no-record-versioning-in-deliverables.md` bars in a deliverable. No claim changed.)*
- [x] `FormalSystem/Metalogic/Decidability/RaySummary.lean`'s aggregator docstring: add the
      refutation to the `RaySummary` module's own account of the ladder layer, at the same reach.
- [x] Measure `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` after the
      edits. If it reached 3000 or more, re-tighten its `set_option linter.style.longFile` (line
      146) to the linter's newly computed `candidate` IN THIS PHASE. *(measured: 2984 lines,
      +28 from 2956; under 3000, so `candidate` stays 3100 and the declared 3000 remains
      accepted — no re-tightening applied.)*
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` IN THIS
      PHASE — docstring lines are still `.lean` lines, and the pre-commit hook is blocking.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `LadderChain.lean` is 2956 lines today against a declared
`set_option linter.style.longFile 3000`. The linter accepts a declared `N` only when
`N == candidate` or `N + 100 == candidate` for `candidate = max(1500, (lines / 100) * 100 + 200)`
— so at 2956 lines `candidate` is 3100 and `{3000, 3100}` are accepted, but at 3000 lines or more
`candidate` becomes 3200 and the declared 3000 FAILS. The headroom is therefore 43 added lines,
not an open budget. The implementer measures with `wc -l` after the edits and re-tightens in this
same phase if the file crossed; the linter's internals can drift with a toolchain bump, so a
disagreement between this arithmetic and the linter's own message is resolved in the linter's
favour and recorded via `issue-record.sh`.

**Tier Justification**: these are docstring-only edits with no signature change and no new
declaration, so the covering check is a guarded build of each of the three edited modules under
CI's `--wfail` parity — which is exactly what the `longFile` and style linters read — plus
`scripts/typst-sync-check.sh --counts-only` for the one generated surface the line-count change
moves; no dependent needs rebuilding because nothing externally visible changed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - EXISTS (confirmed, 2956 lines): module docstring block at ~137-142 and the `exists_deleted_ladderPath_of_next_region_nxt` docstring block at ~1383-1393; `set_option linter.style.longFile` at line 146 re-tightened only if the file crosses 3000 lines
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` - EXISTS (confirmed): module docstring paragraph at ~35-42 and the `(ii)`/`(iii)` items at ~1028-1034
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - EXISTS (confirmed, 292 lines): aggregator docstring account of the ladder layer
- `typst/generated/status.typ` - EXISTS (confirmed): `formalsystem-line-count` regenerated again, in this phase, for the same pre-commit-blocking reason as Phase 2

**Verification**:
- Guarded build of `...RaySummary.LadderChain`, `...RaySummary.LadderIdle` and
  `...Decidability.RaySummary` each exits `0` with zero `error:` and zero `warning:`.
- `grep -niE "dischargeable on the pumpable side" FormalSystem/Metalogic/Decidability/RaySummary/`
  returns nothing — the falsified claim is gone from every site.
- `grep -c "PROVISIONAL" FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` is
  unchanged or higher: the provisionality is PRESERVED, never flipped to permanent.
  `grep -niE "certStabK.*permanent|permanent.*certStabK"` returns no assertion that the
  obligation became permanent.
- `git diff --stat -- FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` is empty:
  `LadderCell.lean` is not edited and no schema signature is touched.
- `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` is recorded, and the
  declared `longFile` value matches the linter's accepted set for that length.
- `bash scripts/typst-sync-check.sh --counts-only` exits `0`.
- `grep -niE "task [0-9]" ` over the three edited `.lean` files returns nothing.

---

### Phase 4: Reconcile the generated inventories and run the full gate set [COMPLETED]

**Goal**: Every generated surface the preceding phases moved is back in step, and the repository's
complete gate set is green or its every red is enumerated as pre-existing and outside this
plan's file scope.

**Tasks**:

- [x] Run `bash scripts/check-module-invariants.sh --emit-inventory` to rewrite every registered
      `<!-- BEGIN GENERATED: inventory -->` block in place, picking up the `LadderIdle.lean` and
      `LadderChain.lean` line counts Phases 2 and 3 moved.
- [x] Update the HAND-WRITTEN trailing description of the `LadderIdle.lean` row in
      `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (the generator rewrites every
      other column but not this one) so it names the `I = 1` refutation, its exact reach, and
      that the five depth-`0` schemas keep `ForwardSlackWitnessed`.
- [x] Update the corresponding narrative paragraphs further down `RaySummary/README.md` that
      currently restate the frontier as dischargeable, matching Phase 3's corrections.
- [x] Run `bash scripts/typst-sync-check.sh --fix` once more and confirm it is a no-op or stage
      the delta. *(deviation: altered — a no-op; Phase 3 already settled `status.typ`, so this phase does not modify it and it is dropped from the staged file list)*
- [x] Run the complete gate set and record each outcome. *(deviation: altered — dispatch 10's Batch Gate Deferral directive applies; every one of the eleven criteria is UNMAPPABLE to `tests/run-all.sh --only` or `verify-deploy.sh --only-gate`, which reach agent-system surfaces only, so each named check was run DIRECTLY instead, per the directive's unmappable-criterion clause)*

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: four README files carry inventory blocks whose counts this plan's edits
move — `README.md` (`dir=FormalSystem rows=totals`), `FormalSystem/README.md`
(`dir=FormalSystem rows=loose`), `FormalSystem/Metalogic/README.md` (three blocks, including
`rows=subdirs cols=files-lines`), and `FormalSystem/Metalogic/Decidability/RaySummary/README.md`.
The `Boneyard/**` and `Tests/**` blocks range over directories this plan does not touch and
should come back byte-identical. The implementer confirms the actual set with
`git status --short` after `--emit-inventory` and reports any block outside this list as an
unexpected finding rather than absorbing it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - EXISTS (confirmed): generated inventory block regenerated, plus the hand-written `LadderIdle.lean` description and the frontier narrative corrected
- `README.md` - EXISTS (confirmed): generated inventory block regenerated
- `FormalSystem/README.md` - EXISTS (confirmed): generated inventory block regenerated
- `FormalSystem/Metalogic/README.md` - EXISTS (confirmed): generated inventory blocks regenerated
- `typst/generated/status.typ` - EXISTS (confirmed): final reconciliation pass

**Verification**:

The complete repository gate set — the ten steps `.github/workflows/ci.yml` runs — each invoked
directly and each outcome recorded:

- [x] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits `0` with
      zero `error:` and zero `warning:` (CI's `--wfail` parity), and `lake test` passes.
- [x] `bash scripts/check-evidence-probes.sh` exits `0`, `PASS` line names 59 probes.
- [x] `bash scripts/check-module-invariants.sh --no-build` exits `0`.
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits `0` (no block
      would change a byte).
- [x] `bash scripts/check-copyright-headers.sh --strict` exits `0`.
- [x] `bash scripts/readme-lint.sh` exits `0`.
- [x] `bash scripts/check-metalogic-cycles.sh` exits `0` — Assertion B asserts EQUALITY against a
      frozen allowlist and fails on surplus as well as deficit, so this confirms the
      no-new-import hypothesis of Phase 2.
- [x] `bash scripts/typst-sync-check.sh` exits `0`.
- [x] `bash scripts/check-paper-definitions.sh` *(deviation: altered — the premise was wrong. The paper repository IS visible on this machine, so the gate runs and exits `1` on 9 drifted definition anchors, all LaTeX list/spacing formatting in `/home/benjamin/Philosophy/Papers/.../possible_worlds.tex`. This plan touched no `.tex` and no `docs/reference/` file, so the drift is causally impossible to attribute here; recorded as a pre-existing, out-of-scope red per the plan's own contingency clause, not fixed)*
- [x] `lake exe mk_all --lib FormalSystem --check` exits `0` (no `FormalSystem/**` file was added
      or removed, so this should be a clean no-op).
- [x] `lake exe lint-style` *(deviation: altered — exits `1` on 4 pre-existing style errors, all at `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean:383,390,413,420`, a file outside this plan's scope and absent from this task's entire commit range. Enumerated as a pre-existing red per the contingency clause, not fixed)*

Each gate's result is reported as a DELTA against the pre-task baseline, not as an absolute zero:
a gate whose only findings are pre-existing and name no file in this plan's scope is a recorded
PASS for this phase, with the pre-existing findings enumerated. It is not a blocker and is not
grounds to edit an out-of-scope file to force a count to zero.

---

## Testing & Validation

- [x] `forwardSlackWitnessed_refuted_I_one` compiles in `FormalSystem/` and in the wired probe,
      sorry-free, axioms `[propext, Classical.choice, Quot.sound]`.
- [x] `ceiling_slack_at_consumer_amount` compiles and is cited at every site that states the
      refutation, so the limit on its reach is a compiled fact and not a prose caveat.
- [x] `not_idleRunPumpable` compiles, establishing that the refutation and task 924's conditional
      discharge cannot collide.
- [x] `LadderCell.lean` is byte-unchanged; all five depth-`0` schemas keep `ForwardSlackWitnessed`
      and their signatures.
- [x] `cellLE_zero_const_of_kappa_eq` is claimed by no declaration anywhere in the tree, on any
      branch.
- [x] `certStabK`'s restatement obligation is still worded PROVISIONAL, not permanent.
- [x] No `(K1)` condition is amended anywhere; `grep -n "spanning" ` over the edited files shows
      no new constraint on spanning-block length.
- [x] No file outside `specs/**` carries a task-number reference introduced by this work.
- [x] The full CI gate set result is recorded per Phase 4, with every red enumerated as
      pre-existing and out of scope or else fixed. *(two reds, both enumerated: `lint-style` on `NormalForm.lean` and `check-paper-definitions.sh` on an external `.tex`; neither names a file this plan touched)*

## Artifacts & Outputs

- `specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean` — the promoted, wired,
  compiled refutation probe.
- A `section IOne` in `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` holding
  the sixteen transcribed declarations.
- Corrected frontier statements in `LadderChain.lean` (two sites), `LadderIdle.lean` (two sites),
  `RaySummary.lean`, and `RaySummary/README.md`.
- A `WIRED` entry and documentation-table row in `scripts/check-evidence-probes.sh`.
- Regenerated `typst/generated/status.typ` and four README inventory blocks.
- `specs/929_idle_run_length_one_forward_slack_discharge/summaries/01_idle-run-one-forward-slack-summary.md`
  at completion.

## Rollback/Contingency

Each phase commits independently, so rollback is per-phase rather than wholesale. If a phase must
be reverted, take a non-reverting checkpoint first
(`bash .claude/scripts/git-snapshot.sh 929 --no-revert`) — never the reverting default form,
which is reserved for a genuine rollback and is additionally unsafe here because a sibling task
shares this working tree.

Phase-specific contingencies:

- **Phase 2 blocked** (a declaration will not transcribe into the library's namespace, e.g. an
  unanticipated instance-resolution difference between the probe's standalone elaboration and
  `LadderIdle.lean`'s open namespaces): mark the phase `[BLOCKED]` and raise it. Per
  `.claude/rules/plan-compliance.md`, a deviation on a `.lean` file is NOT covered by the
  general post-hoc annotation mechanism. Do not substitute a weaker statement under the same
  name. Phase 1's wired probe already preserves the refutation independently of whether the
  library transcription lands, so the record survives a Phase 2 block.
- **Phase 3 crosses the `longFile` boundary and the re-tightened value is still rejected**: read
  the linter's own message, which names the `candidate` it computed, and declare that value;
  record the arithmetic disagreement via `issue-record.sh` rather than disabling the linter.
  `set_option linter.style.longFile 0` is rejected by the style guide and is not a shortcut.
- **A gate in Phase 4 is red for a pre-existing reason**: enumerate the findings, show each file
  this plan touched passes individually, and record a PASS for the phase. Do not edit an
  out-of-scope file to force an absolute count to zero.
- **A foreign commit, foreign uncommitted modification, or foreign build is observed**: STOP and
  report it after checking `git log` to confirm the work is not this task's own — do not proceed
  and do not dismiss it as noise.
