# Implementation Plan: Task #925

- **Task**: 925 - Clear the C16 env_linter unusedArguments lint debt in RaySummary/LadderPump.lean
- **Status**: [NOT STARTED]
- **Effort**: 2.25 hours
- **Dependencies**: None. No live record holds `LadderPump.lean` or
  `scripts/nolint-attribute-allowlist.txt`; the two concurrent siblings this cycle (918 on
  `LadderWindow.lean`/`LadderModel.lean` plus the generated surfaces, 924 on
  `LadderChain.lean`/`LadderCell.lean`) have no entry covering either file.
- **Research Inputs**: `specs/925_ladderpump_c16_unused_arguments_lint_debt/reports/01_ladderpump-c16-unusedarguments-clear.md`
- **Artifacts**: plans/01_ladderpump-c16-unusedarguments-clear.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md,
  plan-compliance.md, lean4.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`lake exe runLinter FormalSystem` exits 1 on exactly two `unusedArguments` findings, three dead
binders, both in `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean`, which makes
C16's `env_linter` group red for every task in the module. The two declarations get **different**
dispositions on the merits: `exists_idleSpliced_ladderPath`'s `[Fintype Q]` and `[Nonempty Q]` are
removed outright (zero term-level consumers, and nothing in the body takes any finiteness
instance), while `exists_idleTypeBlock_of_budget_le_run`'s `hg` is exempted via
`@[nolint unusedArguments]` plus a reasoned `scripts/nolint-attribute-allowlist.txt` entry
(removing it relocates the finding into `LadderWindow.lean`, which a sibling owns this cycle).
Done means: `runLinter FormalSystem` prints `-- Linting passed for FormalSystem.`, a full
`check-module-invariants.sh` exits 0 with `PASS C16` and `PASS C26`, and `LadderPump.lean` is
still exactly 1,931 lines so no generated surface moves.

### Research Integration

The report is integrated in full, with one correction and one addition:

- **Mechanism**: attribute + allowlist, not a `scripts/nolints.json` row. The report dated the
  evidence (`a0e46af49` added the gate's own "prefer the non-destructive fix" note on 2026-11-09;
  three records paired attribute+allowlist exemptions on 2026-11-10, one of them
  `unusedArguments:insRegionStart_trichotomy` in the sibling file `LadderAgree.lean`). The
  archived `ladderchain_c16_unusedarguments_clear` record is precedent for the *analysis*, not
  for the *mechanism*.
- **Asymmetric disposition**: adopted as the report recommends, for the reasons it measured.
- **CORRECTION, net-zero line budget.** The report's recommendation 4 prescribes a 5-line
  replacement comment A and a 5 -> 6 line comment B. That sums to 11 and leaves a `+1` delta.
  Re-derived here from the exact line numbers: comment A is lines 1819-1823 (5 lines),
  `set_option linter.unusedFintypeInType false in` is 1824, comment B is 1862-1866 (5 lines),
  `set_option linter.unusedVariables false in` is 1867, the docstring is 1868-1872, and
  `theorem exists_idleTypeBlock_of_budget_le_run` is 1873. The delta is
  `(A_new - 5) + (-1) + (B_new - 5) + (+1) = A_new + B_new - 10`, so the budget is
  **`A_new + B_new = 10`**, not 11. Phase 2 uses 5 and 5.
- **ADDITION, edit order is mechanically determined.** Reading C26 half two's own source
  (`scripts/check-module-invariants.sh:5151-5280`) settles an ordering the report left open: an
  in-source nolint attribute with no allowlist entry is a blocking `FAIL  C26`, whereas an
  allowlist entry matching nothing in the tree is only an `INFO  C26 ... match nothing in the
  tree` line that does not affect the exit status. So the allowlist entry lands **first**, and
  every intermediate commit stays green on C26 without needing an atomic batch across the two
  files.
- **Stale carried figure, re-derived.** The report measured "4 `unusedArguments:` entries" in the
  allowlist; there are **6** now (`sepZ_sepClauses`, `insRegionStart_trichotomy`,
  `exists_histMorphism_of_isZTime`, `plus_invariance_of_isZTime`, `coneF_surjective`,
  `aa_sound_int`), the file is 118 lines, and neither target appears. Two records appended
  between the research phase and this one.
- **Stale claim in the source comment itself.** The existing comment at 1819-1823 asserts
  "`exists_ladderPath_of_walk_of_pins` reads only `Finite Q`". It reads no instance at all:
  `LadderAgree.lean:1322`'s signature takes none, and `section Path`'s `variable {Q : Type}
  {step : Q → Bool} {pend : Q → Bool}` (`LadderAgree.lean:617`) supplies none. The linter's own
  verdict corroborates this, since an unused argument is one the elaborated term does not
  mention. The replacement comment must not carry the stale claim forward.

### Prior Plan Reference

No prior plan for this task. The archived `ladderchain_c16_unusedarguments_clear` record's plan is
precedent, consulted via the research report, and contributes two calibrations rather than
structure: it planned two files and closed six because a net `.lean` line-count change cascades
into README inventory rows and `typst/generated/status.typ`, and it recorded "the finding is
relocated, not resolved" as the test to run before deleting a binder. Both are honored here — the
first by the net-zero budget, the second by the asymmetric disposition.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap phases are required.
`specs/ROADMAP.md` was not consulted or modified.

## Goals & Non-Goals

**Goals**:

- `exists_idleSpliced_ladderPath`, `idleSpliceCnt` -- re-pin the generalized
  `exists_idleSpliced_ladderPath` signature (the two instance-implicit binders dropped) as this
  task's contract, with `idleSpliceCnt` re-declared unchanged alongside it only to give the
  pinned statement its type context. See `## Lean Challenge Statements`.
- `check-module-invariants.sh`'s C16 `env_linter` group reaches exit 0 with no `unusedArguments`
  finding in `LadderPump.lean`.
- The `hg` exemption is reviewable: an in-source attribute paired with an allowlist entry
  carrying the full admission-bar reason.
- `LadderPump.lean` stays at exactly 1,931 lines, so no README inventory row and no
  `typst/generated/status.typ` figure moves — all of which a sibling owns this cycle.

**Non-Goals**:

- The one genuine `:= trivial` at `FormalSystem/Examples/TemporalStructures.lean:495`. Excluded by
  the dispatch, and excluded on correct grounds twice over: it is a vacuous-pattern census item
  that C16 never sees, so it cannot affect this gate's exit code.
- Any edit to `scripts/nolints.json`. The ledger route is superseded, and the file is held by a
  record at status `hold`.
- Any edit to the generated/inventory surfaces (`RaySummary/README.md`, `FormalSystem/README.md`,
  `README.md`, `typst/generated/status.typ`). The net-zero budget exists precisely so none is
  needed; they are in task 918's declared `file_scope` this cycle.
- `lake exe runLinter --update`. It rewrites `nolints.json` wholesale from current findings for
  the named roots only (observed: 914 lines -> 237), grandfathering any genuine regression.
- Promoting the report's two Context Extension Recommendations into `context/`. Worth doing, not
  this task's scope.
- Redeploying the stale `.claude/` tree. The dispatch reports core/lean/literature/memory/typst
  stale; that predates this task and is not its regression.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `exists_idleSpliced_ladderPath` fails to elaborate without `[Fintype Q]`/`[Nonempty Q]` | H | L | Phase 2's scoped guarded build is the decisive check, run before the commit. Evidence it will pass: `exists_ladderPath_of_walk_of_pins` (`LadderAgree.lean:1322`) takes no instance, `section Path` and `section Inputs` supply none, and the linter reports both binders as unmentioned by the elaborated term. If it does fail, the binder is live, the linter's premise is wrong, and the phase goes `[BLOCKED]` rather than silently reverting to an exemption. |
| A net line-count change escapes and cascades into five sibling-owned files | M | M | `A_new + B_new = 10` budget, with `wc -l` = 1931 asserted as a Phase 2 verification criterion before staging, and `git status --short` checked in Phase 3 to confirm only the two intended files are dirty. |
| An intermediate state leaves C26 red (attribute present, allowlist entry absent) | M | L | Phase ordering: the allowlist entry lands in Phase 1, the attribute in Phase 2. The reverse order is the only one that goes red, and C26's source was read to confirm the asymmetry. |
| A sibling edits `LadderPump.lean` mid-phase | M | L | No live record declares it, but Phase 2's first task re-reads both regions immediately before editing, and staging is an explicit two-file list — never a directory or glob add. |
| `runLinter` collides with task 918's concurrent guarded build | M | M | Every `lake` invocation routes through `lake-build-guard.sh`, which serializes on a project-granular `flock` and can replay a matching completed result. An unexplained failure in a file outside this task's `file_scope` is treated as possible sibling in-flight work, reported, not assumed to be this task's regression. |
| `lean-challenge-snapshot.sh --check` reports drift against the 911 pin | L | H (expected) | The drift is the deliberate generalization. `plan-compliance.md` makes `--check`'s verdict ADVISORY ONLY; re-pinning in this plan's own `## Lean Challenge Statements` is the sanctioned way to make the new signature the contract. Record it as expected output, never as a failure. |
| A full `verify-deploy.sh` run flags the stale deployed `.claude/` tree | L | H (expected) | Pre-existing, reported by this dispatch's own deploy-freshness probe for five extensions, and out of scope. Record it as a pre-existing finding attributed to the stale deploy, do not hand-patch anything under `.claude/**`, and do not let it mask or be masked by this task's own result. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Land the reasoned allowlist entry ahead of the attribute [NOT STARTED]

**Goal**: `scripts/nolint-attribute-allowlist.txt` carries a reasoned
`unusedArguments:exists_idleTypeBlock_of_budget_le_run` entry, so that when Phase 2 adds the
in-source attribute there is no intermediate state in which C26 half two fails.

**Tasks**:

- [ ] Re-read the allowlist's tail (`sed -n '92,118p' scripts/nolint-attribute-allowlist.txt`) to
      confirm the house entry shape immediately before writing: a `#` comment block, then a
      `# <Module>/<File>.lean.` locator line, then the bare `<linter>:<declaration-as-written>`
      key. The two live precedents to copy are `coneF_surjective` and `aa_sound_int`.
- [ ] Re-derive the before-state: `grep -c '^unusedArguments:' scripts/nolint-attribute-allowlist.txt`
      (expect 6) and `wc -l` (expect 118).
- [ ] Append a `#` comment block carrying the full admission-bar reason. It must state all five
      elements the bar requires: (a) `hg` is unread and the linter is correct; (b) the declaration
      cannot conform, because `hg` is consumed by pass-through one layer up —
      `exists_idleBlock_of_hasIdleRunBelow` (`LadderWindow.lean:430`) takes its own
      `hg : IsLadderPath step pend g` and passes it positionally at `:443`, so dropping it here
      relocates the finding into that file rather than clearing it; (c) why `hg` is dead *here*
      specifically — the idle mirror hypothesizes the run's idleness directly via `hrun`, where
      the pending form reads it off `cntAt_sub_of_pend` and so needs the path condition; (d) the
      pending twin `exists_typeBlock_of_budget_le_cnt` is already exempted at
      `scripts/nolints.json:900`, so this keeps the pair symmetric; (e) the paired source-level
      suppression is the scoped `set_option linter.unusedVariables false in` at the same site.
      Close with the locator line `# Metalogic/Decidability/RaySummary/LadderPump.lean.`
- [ ] Append the bare key `unusedArguments:exists_idleTypeBlock_of_budget_le_run` on its own
      line. Length is free in this file — `typst-sync-check.sh` counts only `FormalSystem/`,
      `Tests/` and `BimodalTools/`, never `scripts/`.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build`. Expect exit 0 and `PASS C26`,
      plus one new `INFO  C26  1 allow-list entr(y/ies) match nothing in the tree` line naming
      exactly `unusedArguments:exists_idleTypeBlock_of_budget_le_run`. That INFO is the expected,
      correct output of this intermediate state and does not affect the exit status.
- [ ] Commit with an explicit single-file pathspec:
      `git add -- scripts/nolint-attribute-allowlist.txt`, reviewed via `git status --short` and
      `git diff --staged` first. Never a directory or glob add.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the allowlist holds 118 lines and 6 `^unusedArguments:` keys, with no key
for either target declaration — re-derived at plan-authoring time by `wc -l` and `grep -c`,
superseding the research report's carried "4 entries" figure, which two sibling records have made
stale. Confirm at implementation time with the same two commands before editing, and expect 7
keys after.

**Tier Justification**: `bash scripts/check-module-invariants.sh --no-build` is the covering
check — C26 half two is the only consumer in the repository that reads this file, and the edit
touches no Lean source, so no build or elaboration surface moves; `suite_selection_select` returns
`__FULL_SWEEP__` for `scripts/nolint-attribute-allowlist.txt`, so no Gate 8 suite covers it and
none is claimed.

**Files to modify**:

- `scripts/nolint-attribute-allowlist.txt` - append a `#` reason block carrying the full
  admission-bar justification plus the bare key
  `unusedArguments:exists_idleTypeBlock_of_budget_le_run`.

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` exits 0.
- Its output contains `PASS  C26` and an `INFO  C26` stale line naming exactly the one new key.
- `grep -c '^unusedArguments:' scripts/nolint-attribute-allowlist.txt` reads 7.
- `git status --short` shows exactly one modified file before staging.

### Phase 2: Both LadderPump dispositions, under the net-zero line budget [NOT STARTED]

**Goal**: `exists_idleSpliced_ladderPath` loses its two dead instance binders and
`exists_idleTypeBlock_of_budget_le_run` gains the in-source `@[nolint unusedArguments]`, with
`LadderPump.lean` still exactly 1,931 lines and `runLinter FormalSystem` green.

**Tasks**:

- [ ] Re-read both regions immediately before editing — `sed -n '1817,1836p'` and
      `sed -n '1859,1876p'` on `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` —
      in case a sibling has touched the file since Phase 1, and re-confirm
      `wc -l` reads 1931.
- [ ] Re-confirm the consumer sweep before deleting binders:
      `grep -rn exists_idleSpliced_ladderPath --include=*.lean FormalSystem/ Tests/` must return
      only the declaration itself plus the four docstring mentions
      (`LadderWindow.lean:181,425`, `LadderIdle.lean:19,75`) and zero term-level applications.
      If a term-level application has appeared, stop and treat the removal half as `[BLOCKED]`.
- [ ] Edit A: delete lines 1819-1824 — the 5-line `linter.unusedFintypeInType` comment and the
      `set_option linter.unusedFintypeInType false in` line — and change the signature's first
      line to `theorem exists_idleSpliced_ladderPath {Q : Type}`, leaving every other binder
      untouched.
- [ ] Edit A, replacement comment: write a **5-line** `--` comment immediately above the
      docstring recording why the binders were removed rather than exempted: the body takes no
      finiteness or nonemptiness instance anywhere
      (`exists_ladderPath_of_walk_of_pins` at `LadderAgree.lean:1322` takes none, and
      `section Path`/`section Inputs` supply none), the declaration has no term-level call site,
      and dropping instance-implicit binders generalizes the statement, so no future call site can
      break — instance arguments are supplied by synthesis, not positionally. Do **not** carry
      forward the deleted comment's stale claim that `exists_ladderPath_of_walk_of_pins` "reads
      only `Finite Q`"; it reads no instance at all.
- [ ] Edit B: rewrite the 1862-1866 comment to **5 lines** so it names the environment linter and
      its separate remedy — that the scoped `set_option linter.unusedVariables false in` cannot
      reach a Batteries `@[env_linter]`, which runs post-hoc over an imported environment where no
      source-level `set_option` is in scope, hence the paired attribute and allowlist entry. Keep
      the `set_option linter.unusedVariables false in` line at 1867 exactly as it is: it is the
      paired source-level suppression the allowlist entry cites.
- [ ] Edit B, attribute: insert `@[nolint unusedArguments]` on its own line between the
      docstring's closing `-/` and `theorem exists_idleTypeBlock_of_budget_le_run`, exactly as
      `LadderAgree.lean:2046` does for `insRegionStart_trichotomy`.
- [ ] Assert the budget: `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean`
      must read exactly **1931**. The arithmetic is
      `(A_new - 5) - 1 + (B_new - 5) + 1 = A_new + B_new - 10`, and `5 + 5 = 10`. If it reads
      anything else, adjust comment length — never the README row or `status.typ`.
- [ ] Scoped guarded build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`,
      as a plain foreground `timeout 600 ...` call with the Bash tool `timeout` parameter raised to
      600000; if it does not fit one call, detach it as a shell-level background job and block on
      it with the bounded single-call idiom from `context/patterns/bounded-build-waiter.md`. Never
      a bare `lake`.
- [ ] Dependent build, same guarded shape, for the two modules that import this one and mention
      the changed declaration:
      `-- build FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle` and
      `-- build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow`. These are
      **read-only builds**; `LadderWindow.lean` is in task 918's `file_scope` this cycle and must
      not be edited. A failure inside `LadderWindow.lean` itself is checked against `git log` and
      `git status` for sibling in-flight work before being attributed to this task.
- [ ] Guarded linter run:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- exe runLinter FormalSystem`.
      Expect exit 0 and `-- Linting passed for FormalSystem.`. Note that `Found 0 errors` can never
      appear — that line is printed only on a failing run — so its absence is not evidence of
      anything.
- [ ] Commit the file once, both regions together:
      `git add -- FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean`, reviewed via
      `git status --short` and `git diff --staged` first.

**Timing**: 1.0 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: three dead binders across exactly two declarations, and `LadderPump.lean`
at 1,931 lines — both carried from the research report and both re-derived at plan-authoring time
(`wc -l` reads 1931; the exact line numbers 1819-1824, 1862-1867 and 1873 were read from the
source). The declaration's consumer set is the hypothesis most worth re-confirming at
implementation time, since it is what licenses the removal: run the `grep -rn` sweep above and
require zero term-level applications before deleting either binder.

**Tier Justification**: the guarded `lake-build-guard.sh ... -- build
FormalSystem.Metalogic.Decidability.RaySummary.LadderPump` plus the same guarded build of its two
enumerated direct dependents (`...RaySummary.LadderIdle`, `...RaySummary.LadderWindow`) covers the
one externally visible change — two instance-implicit binders dropped from a declaration whose
only out-of-module mentions are four docstrings — and `suite_selection_select` returns
`__FULL_SWEEP__` for this path, so no Gate 8 suite covers it and none is claimed.

**Commit-mode note**: `atomic-batch` is declared because the net-zero line budget balances only
across both edits. After Edit A alone the file reads 1,930 lines, which is red against the
README inventory row and `status.typ`; that intermediate state is expected red and MUST NOT be
committed. One commit covers both regions.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - delete the
  `linter.unusedFintypeInType` comment and `set_option`, drop `[Fintype Q]` and `[Nonempty Q]`
  from `exists_idleSpliced_ladderPath`, write a 5-line replacement reason comment, rewrite the
  `linter.unusedVariables` comment to 5 lines naming the environment linter, and insert
  `@[nolint unusedArguments]` before `exists_idleTypeBlock_of_budget_le_run`.

**Verification**:

- `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` reads exactly `1931`.
- Guarded scoped build of `...RaySummary.LadderPump` exits 0.
- Guarded builds of `...RaySummary.LadderIdle` and `...RaySummary.LadderWindow` exit 0.
- Guarded `lake exe runLinter FormalSystem` exits 0 and prints
  `-- Linting passed for FormalSystem.`.
- `git status --short` shows only `LadderPump.lean` dirty from this phase.

### Phase 3: Full gate, cascade confirmation, and wrap-up [NOT STARTED]

**Goal**: the complete gate set is green, the generated surfaces are provably untouched, and the
task's durable record states what was done and what was deliberately left as pre-existing.

**Tasks**:

- [ ] Run the full `bash scripts/check-module-invariants.sh` — no `--no-build`, so the
      build-gated groups (C1, C2, C6, C24, C25, C36b) that the research phase explicitly did NOT
      run are covered here. Expect exit 0, `PASS  C16`, and `PASS  C26` with the pair count up by
      one and **no** `INFO  C26` stale line for
      `unusedArguments:exists_idleTypeBlock_of_budget_le_run` (Phase 1's expected INFO is
      extinguished by Phase 2's attribute; if it persists, the key and the as-written declaration
      name disagree).
- [ ] Run `bash scripts/typst-sync-check.sh`. Expect all four checks green and
      `MISMATCH_COUNT=0`.
- [ ] Confirm no cascade: `grep -n 'LadderPump.lean' FormalSystem/Metalogic/Decidability/RaySummary/README.md`
      still reads `1,931`, and `git status --short` shows exactly two modified files for this task
      — `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` and
      `scripts/nolint-attribute-allowlist.txt` — with `typst/generated/status.typ` and every
      README untouched.
- [ ] Run the agent-system aggregator `bash .claude/scripts/verify-deploy.sh` for the complete
      gate set. Record any stale-deploy finding as pre-existing: this dispatch's own
      deploy-freshness probe already reports core, lean, literature, memory and typst stale
      relative to `agent-system/extensions/`. Do **not** hand-patch any file under `.claude/**`
      to make a gate pass.
- [ ] Run `bash .claude/scripts/lean-challenge-snapshot.sh --check` if it resolves in this tree.
      A drift finding on `exists_idleSpliced_ladderPath` against the older `specs/911_...` pin is
      the **expected, correct** output of a deliberate generalization, and is ADVISORY ONLY per
      `plan-compliance.md` — it must not fail the phase, flip `verification_passed`, or downgrade
      a status. Record it as expected, naming this plan's `## Lean Challenge Statements` section
      as the re-pin.
- [ ] Record in the summary that `exists_idleSpliced_ladderPath` was **generalized**, with its new
      signature written out, so the next reader of the idle layer does not read the change as a
      weakening.
- [ ] Write `specs/925_ladderpump_c16_unused_arguments_lint_debt/summaries/01_ladderpump-c16-unusedarguments-clear-summary.md`,
      the `.orchestrator-handoff.json`, and the final `.return-meta.json`; commit with an explicit
      pathspec list.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:

- `specs/925_ladderpump_c16_unused_arguments_lint_debt/summaries/01_ladderpump-c16-unusedarguments-clear-summary.md` - the completion summary.

**Verification**:

- `bash scripts/check-module-invariants.sh` (full, build-gated groups included) exits 0, with
  `PASS  C16` and `PASS  C26` and no stale-entry INFO for this task's key.
- `bash scripts/typst-sync-check.sh` exits 0, all four checks green, `MISMATCH_COUNT=0`.
- Guarded `lake exe runLinter FormalSystem` exits 0: `-- Linting passed for FormalSystem.`
- `bash .claude/scripts/verify-deploy.sh` run to completion, its verdict recorded, with any
  stale-deploy finding attributed to the pre-existing divergence this dispatch reported rather
  than to this task.
- `git status --short` confirms exactly the two source files plus this task's own `specs/**`
  artifacts were touched.
- No `sorry`, no new axiom, no vacuous placeholder anywhere: the task changes one binder list, one
  attribute, two comments and one allowlist line, so no proof term and no axiom profile moves.

## Lean Challenge Statements

This section re-pins `exists_idleSpliced_ladderPath` with the two instance-implicit binders
dropped, which is how the generalized signature becomes this task's contract rather than drift
against the older pin in `specs/911_idle_cycle_sharpening_idle_gap_lengthening/plans/01_idle-cycle-sharpening.md:767`.
`idleSpliceCnt` is re-declared with its real body, unchanged and verbatim from
`LadderPump.lean:1676`, only because it lives in the module being edited and so cannot be
imported alongside the theorem being pinned; this task does not modify it.
`exists_idleTypeBlock_of_budget_le_run` is deliberately **not** pinned here — its signature is
unchanged by this task, and `## Lean Challenge Statements` fixes statements, not attributes.

Honesty note on authoring: every element below except the binder removal is copied verbatim from
compiling source. The block was **not** compile-verified at plan-authoring time, deliberately —
the one untested element is precisely whether the statement elaborates without `[Fintype Q]` and
`[Nonempty Q]`, and that is Phase 2's own scoped-build check, run under the build guard rather
than raced against a sibling's concurrent build this cycle.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-- The countdown the idle-block-duplicated walk forces: unchanged below the block's upper end,
and the original's `l` positions earlier from there on. -/
def idleSpliceCnt {Q : Type} {pend : Q → Bool} (g : ℤ → LadderState Q pend) (a : ℤ) (l : ℕ) :
    ℤ → ℕ :=
  fun v => if v < a + (l : ℤ) then cntAt g v else cntAt g (v - (l : ℤ))

theorem exists_idleSpliced_ladderPath {Q : Type}
    {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (a : ℤ) (l : ℕ) (hl : 0 < l)
    (hidle : ∀ i : ℕ, i < l → pend (objAt g (a + (i : ℤ))) = false)
    (hrep : objAt g a = objAt g (a + (l : ℤ))) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = spliceObj g a l v) ∧
      (∀ v : ℤ, cntAt g' v = idleSpliceCnt g a l v) := sorry
```

## Decisions

- **Attribute + allowlist, not a `nolints.json` row.** On dated evidence, not preference: the
  gate's own failure note names the attribute route, three records paired it on 2026-11-10 (one in
  this very module), and a `nolints.json` row is destroyed by any `--update` run whereas an
  attribute is immune.
- **Asymmetric disposition.** Removing both dead binder sets would be the strongest outcome and
  does not work — one removal relocates the finding into a sibling-owned file. Exempting both
  would be safest and is not honest — the allowlist's admission bar is unmet for a declaration
  with zero consumers and a body needing no instance, and the bar's own instruction for that case
  is to fix the declaration. The split follows the evidence, not a uniform policy.
- **Allowlist entry first, attribute second.** C26 half two fails on an attribute with no entry
  and only INFOs on an entry with no attribute, so this order is the only one with no red
  intermediate state. This replaces the need for a cross-file atomic batch.
- **Net-zero line delta is a hard constraint.** It is the single thing keeping this task to two
  files instead of seven, because every cascade target is in task 918's declared `file_scope` this
  cycle.
- **The 911 pin is re-pinned, not ignored.** An advisory `--check` drift finding is the expected
  output of a deliberate generalization; quietly editing the older plan's pin or quietly matching
  a more convenient statement are both barred by `plan-compliance.md`.
- **Three phases, not one.** The work is small, but the three closure points are genuinely
  different: a gate-ordering prerequisite (Phase 1), a compile-risk-bearing source edit under a
  line budget (Phase 2), and the build-gated group coverage the research phase explicitly did not
  run (Phase 3).

## Testing & Validation

- [ ] Guarded `lake exe runLinter FormalSystem` exits 0 with `-- Linting passed for FormalSystem.`
      and no `unusedArguments` finding anywhere in `LadderPump.lean`.
- [ ] Full `bash scripts/check-module-invariants.sh` exits 0 with `PASS  C16`.
- [ ] `PASS  C26` with the in-source attribute matched to its allowlist entry, and no `INFO  C26`
      stale line for this task's key.
- [ ] `bash scripts/typst-sync-check.sh` exits 0, four checks green, `MISMATCH_COUNT=0`.
- [ ] `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` reads `1931`, and
      `RaySummary/README.md`'s inventory row still reads `1,931`.
- [ ] Guarded scoped builds of `...RaySummary.LadderPump`, `...RaySummary.LadderIdle` and
      `...RaySummary.LadderWindow` all exit 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` run to completion with its verdict recorded.
- [ ] `git status --short` shows exactly two source files touched plus this task's `specs/**`
      artifacts.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` — two declarations retargeted,
  net zero lines.
- `scripts/nolint-attribute-allowlist.txt` — one reasoned entry appended, 6 -> 7
  `unusedArguments:` keys.
- `specs/925_ladderpump_c16_unused_arguments_lint_debt/plans/01_ladderpump-c16-unusedarguments-clear.md`
  — this plan.
- `specs/925_ladderpump_c16_unused_arguments_lint_debt/summaries/01_ladderpump-c16-unusedarguments-clear-summary.md`
  — completion summary, including the generalized signature written out and the advisory
  `--check` drift recorded as expected.
- `specs/925_ladderpump_c16_unused_arguments_lint_debt/.orchestrator-handoff.json` and
  `.return-meta.json`.

## Rollback/Contingency

Both source edits are tiny and individually revertible by targeted re-edit, which is the
preferred route: fix forward. Phase 1's allowlist entry is independently safe to leave in place if
Phase 2 is abandoned — it degrades to a C26 `INFO` stale line, never a failure — so no rollback is
needed for a Phase-2-only abandonment.

If the `exists_idleSpliced_ladderPath` binder removal fails to elaborate, the correct response is
**not** to fall back to an exemption for it: a live binder means the linter's premise is wrong,
which is a finding worth surfacing. Mark Phase 2 `[BLOCKED]`, record the elaboration error and the
goal state reached, and raise it — per `plan-compliance.md`, a would-be deviation on a `.lean`
file is escalated, not silently annotated.

If a genuine whole-tree rollback becomes necessary, take a durable non-reverting checkpoint first
(`bash .claude/scripts/git-snapshot.sh 925 --no-revert`) and follow
`context/contracts/recovery.md`'s rollback rung for the reverting invocation and its
out-of-scope override flag. Never emit a bare reverting `git-snapshot.sh 925` as a routine
start-of-phase precaution, and never discard uncommitted changes to reach a passing build.
