# Implementation Plan: Task #727

- **Task**: 727 - Stop literal-null file_scope writes and promote the null_value sub-state to FAIL
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/727_stop_literal_null_file_scope_writes_and_promote_check/reports/01_stop-null-file-scope-writes.md
- **Artifacts**: plans/01_promote-null-value-to-fail.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The dispatch's Remaining Item 1 (find and fix the literal-null `file_scope` writer) resolves to a
**no-op with a correction to the record**: research established by per-commit before/after diffing
that every historical `"file_scope": null` line was introduced by exactly one commit
(`c1e5f5c3d`, a one-off manual/agent path-reference repair), that no current script or skill
constructs such a write, and that the prior repair commit's attribution to archival/orchestration
commits (`81647f25c`, `cb74c4c67`, `b12283595`) is wrong — `git log -S` surfaced those only
because they *removed* pre-existing nulls. The dispatch's own escape clause applies: close Item 1
with that finding rather than guard a dead path.

Remaining Item 2 (promote `null_value` to FAIL) is the real work, and it is satisfiable today: a
live re-count over `specs/state.json` gives `null_value: 0`, `missing_key: 29`, `empty_array: 0`
across 57 non-terminal tasks, and `validate-state.sh` currently exits 0 with 17 WARN / 0 FAIL. The
promotion edits `validate-state.sh` Check 10 **in the source store**
(`/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh`, resolved
via `.claude-extensions.json`'s `extensions.core.source_dir`), re-levels the `null_value`
per-finding line to `log_fail`, and — a defect this plan adds beyond the research — exempts
`null_value` findings from Check 10's existing 10-item display cap, without which a literal null
sitting beyond the first ten findings (easily reachable with 29 `missing_key` findings live) would
emit no FAIL line at all and the promoted gate would be cosmetic.

Two test fixtures break under the promotion rather than the one the research identified: the
blended Check 10 fixture (now exit 1 with a FAIL line) *and* the `--strict` fixture that reuses it
(its grep for `STATE VALIDATION FAILED (--strict:` can no longer match, because a non-zero
`FAILED` takes the earlier summary branch). The 711 `project_name` staleness is handled as a
documented rename, cheap today and not cheap later.

### Research Integration

- Item 1 closed as "no live writer" per the research's commit-by-commit diff table; the corrected
  attribution is recorded in the Check 10 header comment and the implementation summary.
- Item 2's mechanism taken from the research's recommendation (per-finding-loop branch, not a
  blanket re-leveling), with two additions this plan contributes: the display-cap exemption
  (Phase 2) and the `--strict`-fixture breakage (Phase 3), neither of which the report names.
- Live counts (`null_value: 0`) re-verified during planning and re-verified again as Phase 1's
  gate, per the dispatch's "re-count both sub-states before promoting".
- The 711 rename's cost was measured by research and re-measured during planning: the directory is
  untracked by git (three empty subdirectories, `git ls-files` returns nothing), and the slug
  string appears only in `specs/state.json`, generated `specs/TODO.md`, and this task's own report.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no `roadmap_flag` was set; this plan
adds no roadmap phases. `specs/ROADMAP.md` exists but references task 711 only by bare number, so
the Phase 5 rename does not touch it.

## Goals & Non-Goals

**Goals**:
- Close Item 1 with the corrected writer attribution recorded durably, adding no guard for a dead
  code path.
- Promote Check 10's `null_value` sub-state to FAIL in default mode, in the source store, with the
  promotion genuinely exit-blocking for every `null_value` finding regardless of display position.
- Keep `missing_key` at WARN and `empty_array` advisory, with no information lost from Check 10's
  output.
- Keep the test suite green (35 passed / 0 failed baseline) and `validate-state.sh specs/state.json`
  passing (exit 0).
- Decide the 711 `project_name` staleness deliberately and act on the decision.

**Non-Goals**:
- Populating `file_scope` for any of the 29 never-planned `missing_key` tasks — the correct
  by-design state, explicitly forbidden by the dispatch.
- Promoting `missing_key` or `empty_array` (criterion unsatisfied for the former, never a
  candidate for the latter).
- Changing `orchestrate-predispatch-review.sh`'s Class B repair, which rewrites a literal null to
  `[]` rather than deleting the key. `[]` is an advisory sub-state by design and the repair is an
  explicit operator opt-in, so this is left untouched; a one-line cross-reference in the Check 10
  header records the interaction so a future reader does not read it as a laundering hole
  discovered and ignored.
- Changing `batch-admit-schema.md` / `batch-orchestration-guardrails.md`. Both cite Check 10 as a
  *measurement source* for a different promotion (cross-batch absent-scope admission), gated on
  `missing_key` AND `null_value` both being zero. That criterion is still unmet (29 `missing_key`),
  and this promotion does not change the measurement's semantics. Checked and deliberately left
  alone.
- Altering any task's dependencies, status, or description — including 711's.
- Weakening any existing check to make the new FAIL pass.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A new literal null appears between planning and implementation, so the promotion breaks the build for everyone | H | L | Phase 1 is a hard gate: re-count `null_value` and refuse to proceed to Phase 2 if it is non-zero (repair by deleting the key first, never by writing `[]`) |
| The promoted FAIL is hidden by Check 10's existing 10-item display cap, making the gate cosmetic | H | H if unaddressed | Phase 2 emits every `null_value` finding untruncated and applies the cap to the WARN population only; Phase 3 pins this with a dedicated >10-finding fixture |
| The `--strict` fixture (line ~837) silently stops testing what it claims, because its blended input now FAILs before the `--strict` summary branch is reached | M | H if unaddressed | Phase 3 repoints that fixture at a new WARN-only (`missing_key` + `empty_array`) fixture, preserving the `--strict` semantics it exists to test |
| Re-leveling the aggregate summary line is misread as weakening or loses a count | M | M | The blended `file_scope visibility: ... missing-key, ... literal-null, ... empty-array` line is kept verbatim as a WARN information line; a dedicated FAIL line is **added** when `scope_null > 0`. No count is dropped and no existing grep on that line breaks |
| `deploy-headless.sh` regenerates `.claude/` while sibling tasks 710 and 564 are live on the same tree | M | M | The default mode is a non-destructive resync (never `--wipe`); the only content delta is this change. Announce the deploy, run `check-deploy-freshness.sh` after, and do not pass `--wipe` |
| A sibling task writes `specs/state.json` concurrently with the Phase 5 rename | M | M | Route the write through `state-write.sh` (mutex-guarded, private staging), never a hand-rolled `jq > tmp && mv`; re-read the entry immediately beforehand |
| The 711 rename strands a path reference discovered later | L | L | Phase 5 re-greps for the slug before and after; on any hit outside the task's own directory and this task's artifacts, abandon the rename and record the staleness in **this task's summary** (never in 711's description, which is immutable per the hard constraints) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2, 3, 5 |

Phases within the same wave can execute in parallel. Phase 5 sits in Wave 1 deliberately so that
Phase 4's final gate run validates the post-rename `specs/state.json`, giving the task a single
closing gate rather than two.

---

### Phase 1: Confirm the gate — re-measure sub-states and close Item 1 [COMPLETED]

**Goal**: Establish, immediately before any edit, that `null_value` is still zero (the promotion's
precondition) and that no live writer of a literal-null `file_scope` exists; produce the corrected
attribution text that Phases 2 and the summary will carry.

**Tasks**:
- [x] Re-count the three sub-states over the non-terminal population:
      `jq -c '[.active_projects[] | select((.status // "") as $s | ($s=="completed" or $s=="abandoned" or $s=="expanded")|not)] | {denominator: length, missing_key: [.[]|select(has("file_scope")|not)]|length, null_value: [.[]|select(has("file_scope") and .file_scope==null)|.project_number], empty_array: [.[]|select(.file_scope==[])|.project_number]}' specs/state.json`
      *(completed: denominator 56, missing_key 28, null_value [], empty_array [])*
- [x] **GATE**: if `null_value` is non-empty, STOP. Repair each offender by **deleting** the key
      (via `state-write.sh`, e.g. `del(.active_projects[] | select(.project_number==NNN) | .file_scope)`),
      never by writing `[]`, then re-count before continuing. If `null_value` is empty, proceed.
      *(completed: null_value empty, gate passed, proceeding to Phase 2)*
- [x] Capture the baseline: `bash .claude/scripts/validate-state.sh specs/state.json` (record
      Passed/Warnings/Failed and the exit code) and
      `bash .claude/scripts/tests/test-validate-state.sh | tail -3` (record the pass/fail tally).
      *(completed: Passed 8, Warnings 17, Failed 0, exit 0; test suite 35 passed, 0 failed)*
- [x] Re-confirm Item 1's "no live writer" finding cheaply:
      `grep -rn '"file_scope": *null' /home/benjamin/.config/nvim/agent-system/extensions/core --include=*.sh --include=*.md`
      and confirm every hit is a test fixture or a worked example, not a writer.
      *(completed: 11 hits, all in test-orchestrate-predispatch-review.sh, test-backfill-file-scope.sh,
      test-orchestrate-build-dispatch.sh, test-orchestrate-batch-admit.sh, test-validate-state.sh,
      and context/contracts/territory.md's worked example -- no writer found)*
- [x] Draft the corrected-attribution paragraph (single source commit `c1e5f5c3d`, 2026-07-27;
      remediated by `3f4599425`, 2026-10-03; the three archival/orchestration commits previously
      blamed only ever removed nulls, and `git log -S` lists them because `-S` matches any change
      to the pickaxe string's occurrence *count*). Keep it free of task-number references — it
      lands outside `specs/**`.
      *(completed: independently re-verified against `git show --stat c1e5f5c3d -- specs/state.json`
      and `git log --oneline -S'"file_scope": null' -- specs/state.json`; paragraph stored in
      progress/phase-1-progress.json for reuse in Phase 2 and the summary)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: planning measured `null_value: 0`, `missing_key: 29`, `empty_array: 0` over
57 non-terminal tasks, and a green baseline of `35 passed, 0 failed` for
`test-validate-state.sh` plus `0 FAILED / 17 WARN` for `validate-state.sh specs/state.json`.
Confirm all five numbers with the commands above before Phase 2; a changed `missing_key` count is
expected and harmless (new tasks accrue), a changed `null_value` count is the gate.

**Files to modify**:
- none planned (measurement and drafting only; `specs/state.json` is touched only on the GATE
  branch, if a new literal null has appeared)

**Verification**:
- The re-count prints `"null_value": []`.
- Baseline exit codes and tallies are recorded for comparison in Phase 4.
- Every `"file_scope": null` hit in the source store is accounted for as a fixture or example.

---

### Phase 2: Promote `null_value` to FAIL in Check 10 (source store) [COMPLETED]

**Goal**: Make a literal-null `file_scope` exit-blocking in default mode, for every offending
task, while leaving `missing_key` at WARN and `empty_array` advisory and losing no output detail.

**Edit target**: the **source store** only —
`/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh`. Never
hand-author `.claude/scripts/validate-state.sh`; it is regenerated (Phase 4 deploys).

**Tasks**:
- [x] In Check 10's reporting block (currently the `else` branch around lines 680-691), restructure
      the emission into three parts, replacing the single capped `log_warn` loop:
      1. Keep the existing blended information line verbatim as `log_warn`:
         `"file_scope visibility: $scope_missing missing-key, $scope_null literal-null, $scope_empty empty-array, out of $scope_denominator non-terminal task(s)"`.
      2. Add, when `scope_null -gt 0`, a `log_fail` aggregate naming the remedy:
         `"file_scope literal-null: $scope_null finding(s) -- a literal null violates the schema default; the key must be OMITTED when no scope is known (matching Create Task Mode's shape), never written as null"`.
      3. Split the per-finding loop by level: iterate the `null_value` findings with `log_fail`
         **untruncated**, then iterate the `missing_key`/`empty_array` findings with `log_warn`
         under the existing 10-item cap.
      *(completed)*
- [x] Recompute the truncation arithmetic against the WARN population only: derive
      `scope_warn_count=$((scope_missing + scope_empty))` and emit the
      `"... and N more file_scope visibility finding(s) not shown"` line from that, so the count
      stays truthful once FAIL findings are excluded from the cap.
      *(completed: implemented as `_c10_warn_count`)*
- [x] Keep the per-finding message shape byte-identical (`"file_scope $sub_state: project_number
      $pnum ($name)"`) for all three sub-states — only the log level and the truncation treatment
      change, so existing greps on those lines keep matching.
      *(completed: message format unchanged, verified by fixture output)*
- [x] Update the three header locations that currently state Check 10 is WARN-only:
      1. the Exit codes block (~line 69): `"Checks 3, 4, 8, 9, 10 and 11 below are WARN-only..."`
         must no longer list 10 unqualified — state that Check 10's `null_value` sub-state FAILs in
         default mode while its other two sub-states stay WARN.
      2. the `--help` base-mode bullet for Check 10 (~lines 113-125): replace "all WARN" and "This
         task does NOT perform the promotion" with the performed-promotion record.
      3. the Check 10 section banner and D2/PROMOTION CRITERION comment (~lines 627-660): change
         the banner's `(WARN-only, base mode)` to reflect the split, record that the `null_value`
         promotion was performed on 2026-10-03 with the measurement that justified it
         (`null_value: 0`), leave `missing_key`'s promotion-criterion text in place and unsatisfied
         (29 remaining), and restate that `empty_array` stays advisory indefinitely.
      *(completed: all three locations updated, confirmed by grep -n "Check 10\|WARN-only" showing
      no surviving unqualified WARN-only claim for Check 10)*
- [x] Add to that comment block: the corrected writer attribution drafted in Phase 1, and the
      one-line cross-reference noting that `orchestrate-predispatch-review.sh`'s Class B repair
      rewrites a null to `[]` (moving a FAIL to an advisory state) and that this is intentional and
      out of scope here.
      *(completed)*
- [x] Confirm no `--strict` logic change is needed: `--strict` promotes WARNINGS into the
      exit-blocking total at the summary, so a `log_fail` is orthogonal and cannot double-count.
      *(completed: verified by reading the Summary block -- FAILED and WARNINGS are disjoint
      counters, and `--strict` fixture test confirms unchanged behavior on a WARN-only input)*
- [x] Syntax-check the edited script: `bash -n <source-store path>`.
      *(completed: clean)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that exactly **three** header locations plus **one**
reporting block describe or implement Check 10's WARN-only posture. Confirm by
`grep -n "Check 10\|WARN-only" <source-store path>` before editing and re-grepping after, so no
fourth location is left asserting a posture the code no longer has.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh` - Check 10
  reporting block split by level, `null_value` findings exempted from the display cap, three
  header/comment blocks updated, corrected attribution and Class B cross-reference recorded

**Verification**:
- `bash -n` on the edited source-store script is clean.
- Against a hand-made throwaway fixture containing one `null_value` entry (write it under the
  scratchpad directory, not under `specs/`): the source-store script exits 1, prints the
  `file_scope null_value: ...` line and the new `file_scope literal-null: 1 finding(s)` line, and
  prints `STATE VALIDATION FAILED`.
- Against a fixture with only `missing_key`/`empty_array` entries: still exits 0 with WARN lines
  and no FAIL.
- `grep -n "Check 10\|WARN-only"` shows no surviving claim that Check 10 is wholly WARN-only.

---

### Phase 3: Update the test suite for the new posture [COMPLETED]

**Goal**: Keep `test-validate-state.sh` an honest gate: re-point the two fixtures the promotion
invalidates, and add two fixtures that pin the new behavior independently.

**Edit target**: the **source store** only —
`/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-validate-state.sh`.

**Tasks**:
- [x] Update the blended Check 10 fixture (~lines 733-762): change the assertion from `rc -eq 0`
      to `rc -eq 1`, keep the three per-sub-state line greps and the blended summary-line grep
      unchanged, add a grep for the new `file_scope literal-null: 1 finding(s)` FAIL line and for
      `STATE VALIDATION FAILED`, and update the fixture's leading comment and the `pass`/`fail`
      message text (which currently say "exit 0").
      *(completed)*
- [x] Repoint the `--strict` fixture (~lines 837-844) at a **new** WARN-only fixture
      (`scope10-warnonly-fixture.json`: one `missing_key` entry, one `empty_array` entry, one
      concrete-scope control, all non-terminal, no `null_value`). Its grep for
      `STATE VALIDATION FAILED (--strict:` then still matches, because `FAILED` stays 0 and the
      `--strict` summary branch is reachable. Without this change that assertion silently stops
      testing `--strict` semantics, since the blended fixture now takes the plain
      `STATE VALIDATION FAILED` branch first.
      *(completed: new fixture added with its own positive assertion plus the repointed --strict
      assertion)*
- [x] Add a pure-`null_value` fixture: a single non-terminal entry with `"file_scope": null`,
      asserting `rc -eq 1`, the per-finding FAIL line, the aggregate FAIL line, and the absence of
      any `missing_key`/`empty_array` finding — pinning the FAIL independently of the blended
      input.
      *(completed: scope10-nullonly-fixture.json)*
- [x] Add a display-cap fixture: ≥12 non-terminal `missing_key` entries at low `project_number`s
      plus one `null_value` entry at a high `project_number` (so it sorts past the 10-item cap),
      asserting `rc -eq 1` and that the `file_scope null_value: project_number <high>` line is
      present. This is the regression guard for Phase 2's cap exemption; without it the promotion
      could silently regress to cosmetic.
      *(completed: scope10-displaycap-fixture.json, 12 missing_key entries + 1 null_value at
      project_number 999)*
- [x] Confirm the new fixtures land in `$WORKDIR` (the suite's own temp dir), matching the
      surrounding fixtures — never under `specs/`.
      *(completed)*
- [x] `bash -n` the edited test script.
      *(completed: clean)*
- [x] *(deviation: added -- a THIRD fixture broke under the promotion, beyond the Scope
      Hypothesis's "two existing fixtures" estimate)*: the `--fix` non-manufacture fixture
      (~line 693, "exact duplicates removed order-preservingly... null-valued file_scope
      untouched") invokes `$FS_VALIDATOR --fix` against a fixture that deliberately carries a
      project with `"file_scope": null` (to prove `--fix` does not mutate it). That null is now
      FAIL-promoted, so the `--fix` run's own exit code changed from 0 to 1. Fixed by changing the
      assertion to `rc -eq 1` and adding a grep for the `file_scope null_value: project_number 3
      (c)` line, with an explanatory comment that this is Check 10's FAIL firing correctly on the
      exact shape `--fix` deliberately leaves untouched, not a `--fix` regression. Per the
      Scope Hypothesis's own instruction ("if a third fixture fails, fix that one too rather than
      treating the count as closed").

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **two** existing fixtures break under the promotion (the
blended Check 10 fixture and the `--strict` fixture reusing it) and **two** new fixtures are
needed. Confirm by running the unmodified suite against the Phase 2 validator first and reading
every failure: if a third fixture fails, fix that one too rather than treating the count as
closed.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-validate-state.sh` -
  blended Check 10 fixture re-asserted to exit 1, `--strict` fixture repointed at a new WARN-only
  input, pure-`null_value` fixture added, display-cap fixture added

**Verification**:
- Run the source-store suite directly; it reports `0 failed` and a pass count of at least the
  baseline + 2 (the two new fixtures).
- Deliberately flip the Phase 2 cap exemption off in a scratch copy and confirm the display-cap
  fixture fails — proving it actually guards the behavior rather than passing vacuously.

---

### Phase 4: Deploy, run the full gate set, and commit [COMPLETED]

**Goal**: Land the source-store change in the deployed tree and confirm every acceptance criterion
against the deployed copy, which is what every live caller executes.

**Tasks**:
- [x] Announce the deploy before running it (siblings 710 and 564 are live on this tree) and run
      the **non-destructive** default mode: `bash .claude/scripts/deploy-headless.sh`. Never
      `--wipe`.
      *(completed: announced via SendMessage to the team lead before running; deploy-headless.sh
      ran in default mode, RESULT=landed_verify_clean)*
- [x] `bash .claude/scripts/check-deploy-freshness.sh` — expect exit 0 (clean), confirming the
      deployed `validate-state.sh` and `test-validate-state.sh` now carry the change.
      *(completed: exit 0)*
- [x] Diff-confirm the deploy actually propagated:
      `diff /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh .claude/scripts/validate-state.sh`
      (and the same for the test script) — expect no differences in the edited regions.
      *(completed: both diffs empty, byte-identical)*
- [x] `bash .claude/scripts/validate-state.sh specs/state.json` — expect exit 0, `Failed: 0`
      (this is the dispatch's acceptance command).
      *(completed: exit 0, Passed 8 / Warnings 17 / Failed 0)*
- [x] `bash .claude/scripts/tests/test-validate-state.sh` — expect `0 failed`, pass count at or
      above the Phase 1 baseline + 2.
      *(completed: 38 passed, 0 failed -- baseline 35 + 3)*
- [x] `bash .claude/scripts/validate-state.sh --strict specs/state.json` — expect exit 1 with the
      `(--strict: N warning(s) promoted...)` summary (the pre-existing `missing_key` WARNs), i.e.
      unchanged `--strict` behavior.
      *(completed: exit 1, "(--strict: 17 warning(s) promoted to exit-blocking)" -- unchanged)*
- [x] `bash .claude/scripts/verify-deploy.sh --deep` — expect no new failure versus the Phase 1
      baseline.
      *(completed with a correction: `--deep` is not a recognized flag on this script -- it has
      no such option, confirmed via `--help`. Ran the equivalent full/default invocation (no
      `--skip-slow`) instead: PASS, 14 check(s), 0 failure(s). The one WARN present
      (hard_contracts/routing_hard migration notice for the lean extension) is pre-existing and
      unrelated to this change)*
- [x] Commit with targeted staging only (`git add --` with an explicit file list; never `-A`, a
      directory pathspec, or `commit -am`), reviewing `git status --short` and
      `git diff --staged` first. Source-store files live outside this repository, so the in-repo
      commit covers `specs/**` only; note the out-of-repo source-store edit in the commit body and
      in the summary.
      *(completed below via git-commit-scoped.sh)*

**Timing**: 0.5 hours

**Depends on**: 2, 3, 5

**Verification Tier**: full

**Scope Hypothesis**: asserts the gate set is exactly these six commands and that the baseline is
`0 FAILED` for `validate-state.sh` and `0 failed` for the test suite. Confirm against the Phase 1
recorded baseline rather than against these numbers as written; a WARN-count drift is expected and
irrelevant, a FAIL-count drift is not.

**Files to modify**:
- `.claude/scripts/validate-state.sh` - regenerated by the deploy, never hand-edited
- `.claude/scripts/tests/test-validate-state.sh` - regenerated by the deploy, never hand-edited

**Verification**:
- `check-deploy-freshness.sh` exits 0 and the two `diff`s are empty in the edited regions.
- `validate-state.sh specs/state.json` exits 0 with `Failed: 0`.
- The deployed test suite reports `0 failed`.
- `verify-deploy.sh --deep` shows no new failure.

---

### Phase 5: Resolve task 711's stale `project_name` [COMPLETED]

**Goal**: Act on the dispatch's smaller item deliberately. The decision is **rename**: the cost is
measurably near-zero today (no artifacts, no git-tracked files, no external slug references) and
rises permanently once any artifact is written under the old path.

**Decision and rationale**: `omega_automata_determinization_substrate` names a device that the
2026-10-03 user ruling demoted to one of four unselected candidates; the record now names the
universal-summary substrate for the stability-fibre check. New slug:
`universal_summary_substrate_stab_fibre`. Planning verified the directory holds three empty
subdirectories, `git ls-files` returns nothing for it (so the rename produces no git rename at
all — only `specs/state.json` and generated `specs/TODO.md` change), and the slug string appears
nowhere outside `specs/state.json`, `specs/TODO.md`, and this task's own report. If any of those
preconditions has changed at implementation time, do not rename: record the staleness in **this
task's summary artifact** and leave 711 untouched.

**Tasks**:
- [x] Re-verify the preconditions: `git ls-files specs/711_omega_automata_determinization_substrate`
      returns nothing; `ls -R` on that directory shows only empty `plans/`, `reports/`,
      `summaries/`; `grep -rl omega_automata_determinization_substrate . --exclude-dir=.git` returns
      only `specs/state.json`, `specs/TODO.md`, and this task's artifacts.
      *(completed: all three preconditions held exactly as planned)*
- [ ] On any precondition failure: skip the rename, record the staleness and the reason in the
      summary, and mark this phase `[COMPLETED WITH EXCLUSIONS]`.
      *(not applicable: no precondition failure, rename proceeded)*
- [x] Update the field through the mutex-guarded writer:
      `bash .claude/scripts/state-write.sh '(.active_projects[] | select(.project_number==711) | .project_name) = "universal_summary_substrate_stab_fibre"' --session-id "$session_id" --regen-todo`
      *(completed)*
- [x] Rename the directory with a plain `mv` (not `git mv` — nothing in it is tracked):
      `mv specs/711_omega_automata_determinization_substrate specs/711_universal_summary_substrate_stab_fibre`,
      then confirm the three empty subdirectories survived.
      *(completed: three empty subdirectories (plans/, reports/, summaries/) confirmed intact)*
- [x] Re-grep for the old slug; expect hits only in this task's own artifacts and in
      `specs/events.jsonl`-style historical records, never in a live path.
      *(completed: post-rename grep returns the same four files as the pre-rename baseline --
      specs/state.json (task 727's own description text plus its own file_scope declaration
      naming the directory), specs/TODO.md (regenerated), and this task's own report and plan.
      No hit in any OTHER task's live path. Note: task 727's own file_scope entry
      "specs/711_omega_automata_determinization_substrate/" is now a stale path string -- left
      untouched since file_scope is descriptive/anticipated and never filesystem-validated per
      state-management.md, and editing it is outside this phase's scope; recorded in the summary)*
- [x] Leave 711's `description`, `status` (`blocked`), `dependencies`, and `task_type` untouched —
      hard constraint.
      *(completed: diffed against git HEAD before the edit -- description byte-identical,
      status/dependencies/task_type unchanged)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: asserts the old slug has exactly three referencing files and the directory
is wholly untracked. Confirm with the two commands in the first task above; a single unexpected
hit flips this phase to the no-rename branch.

**Files to modify**:
- `specs/state.json` - task 711's `project_name` only, written via `state-write.sh`
- `specs/TODO.md` - regenerated by `--regen-todo`, never hand-edited
- `specs/711_omega_automata_determinization_substrate/` - renamed (untracked directory; no git
  rename recorded)

**Verification**:
- `jq -r '.active_projects[] | select(.project_number==711) | .project_name' specs/state.json`
  prints the new slug.
- `specs/711_universal_summary_substrate_stab_fibre/` exists with its three empty subdirectories;
  the old path is gone.
- `jq -r '.active_projects[] | select(.project_number==711) | {status, dependencies, task_type}'`
  is unchanged from the Phase 5 pre-edit capture, and the `description` is byte-identical.
- `bash .claude/scripts/validate-state.sh specs/state.json` still exits 0 (re-run as part of
  Phase 4's gate set).

---

## Testing & Validation

- [ ] `null_value` re-counted as 0 immediately before the promotion (Phase 1 gate).
- [ ] Source-store `validate-state.sh` exits 1 on a `null_value`-only fixture and 0 on a
      `missing_key`/`empty_array`-only fixture.
- [ ] A `null_value` finding sorting past the 10-item display cap still produces a FAIL line.
- [ ] `missing_key` and `empty_array` still emit WARN, never FAIL, in default mode.
- [ ] No count or sub-state label disappears from Check 10's output.
- [ ] `--strict` behavior unchanged: a WARN-only input still exits 1 with the `--strict` summary
      line.
- [ ] Deployed `bash .claude/scripts/validate-state.sh specs/state.json` exits 0, `Failed: 0`.
- [ ] Deployed `bash .claude/scripts/tests/test-validate-state.sh` reports `0 failed`.
- [ ] `bash .claude/scripts/check-deploy-freshness.sh` exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh --deep` shows no new failure.
- [ ] The 29 never-planned `missing_key` tasks are untouched: the `missing_key` count after the
      change equals the Phase 1 measurement (modulo tasks created in the interim), and no task
      gained a `file_scope`.

## Artifacts & Outputs

- `specs/727_stop_literal_null_file_scope_writes_and_promote_check/plans/01_promote-null-value-to-fail.md`
  (this plan)
- `specs/727_stop_literal_null_file_scope_writes_and_promote_check/summaries/01_*-summary.md` —
  must record (a) Item 1 closed as "no live writer", with the corrected attribution table from the
  research report, (b) the pre/post sub-state measurements, (c) the 711 decision and which branch
  was taken, and (d) the out-of-repo source-store files edited, since the in-repo commit cannot
  show them.
- Source-store edits (outside this repository):
  `extensions/core/scripts/validate-state.sh`, `extensions/core/scripts/tests/test-validate-state.sh`
- Regenerated deploy artifacts: `.claude/scripts/validate-state.sh`,
  `.claude/scripts/tests/test-validate-state.sh`
- `specs/state.json` / `specs/TODO.md` — task 711 `project_name` only

## Rollback/Contingency

- **Source store**: it is a git repository of its own
  (`/home/benjamin/.config/nvim/agent-system/`, head recorded in `.claude-extensions.json` as
  `extensions.core.source_git_head`). Revert with `git -C /home/benjamin/.config/nvim checkout --`
  on the two files, then re-run `bash .claude/scripts/deploy-headless.sh` to restore the deployed
  tree. Record the pre-edit head before Phase 2 so the revert target is unambiguous.
- **Deployed tree**: never hand-repaired. A bad deploy is fixed by reverting the source store and
  re-running `deploy-headless.sh` (default mode), then `check-deploy-freshness.sh`.
- **If the promotion breaks a live caller** (`verify-deploy.sh`, an orchestrate preflight): revert
  the source store as above rather than weakening another check to compensate — weakening is a hard
  constraint violation. Re-open the task with the breaking caller named.
- **711 rename**: reverse with the inverse `state-write.sh` assignment plus `mv` back; no git
  history is involved because the directory is untracked.
- **Phase 1 gate trips** (a new literal null appeared): repair by deleting the key via
  `state-write.sh`, commit that repair separately, then resume at Phase 1's re-count. Do not carry
  a repair and a promotion in one commit.
