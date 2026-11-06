# Implementation Summary: Task #889

- **Task**: 889 - Clear the live C16 (env_linter) gate failure so `scripts/check-module-invariants.sh` exits 0 again
- **Status**: [COMPLETED]
- **Started**: 2026-11-06T09:59:00Z
- **Completed**: 2026-11-06T10:19:00Z
- **Effort**: 0.35 hours
- **Dependencies**: None
- **Artifacts**: plans/01_ladderchain-c16-unusedarguments-clear.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

One live `unusedArguments` finding — `mem_cellAt_of_shift_of_hasForwardSlack`'s argument 23,
`hslk` — made C16 exit 1 in `scripts/check-module-invariants.sh`, so every Lean task running that
gate had to either narrow its verification tier or carry a Reasoned Exclusions row for a failure
it did not cause. The repair is the two disjoint edits the plan specified: a repaired reason
comment at the declaration site naming both linters that see the binder, and one hand-written row
appended to `scripts/nolints.json`. `check-module-invariants.sh` now reports `ALL CHECKS PASSED`
and exits 0. No statement, proof term, or axiom profile changed, and `lake exe runLinter --update`
was never run.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the three-line `--` reason
  comment above `set_option linter.unusedVariables false in` replaced by a fourteen-line block.
  Comment-only: `git diff <base>..HEAD` on this file yields **zero** non-comment lines, so the
  docstring, the signature, the `set_option` line, and the proof term of
  `mem_cellAt_of_shift_of_hasForwardSlack` are byte-identical. No theorem or lemma was proved,
  restated, or weakened here. The new block records four things the old one did not: that `hslk`
  is slack the `_exact` form does not need once the regime amount is `m · (P + 1)`, so the proof
  does not read it; that the statement is kept verbatim because it is a pinned Challenge
  statement, dropping the binder being same-name-different-signature drift against that pin; that
  TWO linters see this binder and each needs a different remedy — the frontend
  `linter.unusedVariables` silenced by the `set_option ... in` line, and Batteries'
  `@[env_linter] unusedArguments` exempted instead by `scripts/nolints.json`, which no
  `set_option linter.*` can reach; and that `lake exe runLinter --update` must not be used to
  regenerate that ledger. The old comment named only the frontend linter, which is precisely the
  gap that let the environment-linter finding reach the gate.
- `scripts/nolints.json` — one row appended in the file's own existing two-element-array format:
  `["unusedArguments", "FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_shift_of_hasForwardSlack"]`.
  227 rows → 228, all of category `unusedArguments`. Diff is 4 insertions, 0 deletions; no
  existing row was reformatted, re-sorted, or re-serialized.
- `typst/generated/status.typ` — regenerated via `scripts/typst-sync-check.sh --fix`. The comment
  edit's 11 net added lines moved `formalsystem-line-count` 388946 → 388957, and the
  `typst-sync-check.sh` Check 2 pre-commit hook blocks any staged `.lean` change whose line count
  the committed `status.typ` no longer reflects.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`,
  `FormalSystem/Metalogic/README.md`, `README.md` — generated inventory blocks regenerated via
  `scripts/check-module-invariants.sh --emit-inventory`. Three one-number diffs, each +11
  (`LadderChain.lean` 2,216 → 2,227; `Decidability/` 112,436 → 112,447; root live comment lines
  132,979 → 132,990).

## Decisions

- **Disposition: a hand-inserted ledger row plus a repaired comment.** The two rejected options,
  each on its own merits rather than by elimination. *Removing `hslk` from the signature* is the
  route that would retire the finding outright instead of recording it, and it is unavailable
  here: the statement is a pinned Challenge statement carrying `hslk` written out verbatim, so
  removal is same-name-different-signature drift against that pin — a deliberate decision about
  an existing pin, not a lint repair. *Consuming `hslk` in the proof* would make the binder
  genuinely live and need no ledger entry at all, which is the strongest form of the fix where it
  applies; it does not apply here, because the only available consumption moves the deadness onto
  `hgap` and the linter then reports argument 20 instead of 23 — the finding is relocated, not
  resolved. An in-source `@[nolint unusedArguments]` attribute is mechanically valid and would
  keep the exemption beside the declaration it exempts, but it splits one linter's exemption
  inventory across two mechanisms, so the 228-row ledger stays the single place to look.
- **`lake exe runLinter --update` was not run**, and the prohibition is now recorded in the
  comment at the declaration rather than only in task records, so it travels with the code. It
  rewrites the whole ledger from current findings in a different serialization, grandfathering any
  genuine regression alongside the intended row.
- **The `INV` failure was repaired, not reported.** The plan's risk table pre-attributed the three
  README surfaces to a concurrent sibling and directed that such a failure be reported under the
  territory contract. The attribution test was run rather than assumed, and overturned it: the
  inventory blocks record per-file line counts, `LadderChain.lean` stood recorded at 2,216 against
  a live 2,227, the task that held those READMEs is `completed` in `state.json` rather than live,
  the only contention manifest on disk is from an unrelated session and names only
  `docs/theorem-index.md`, and `git status` showed no uncommitted README edits. Self-caused
  staleness is repaired.
- **Both cascades were repaired by their own sanctioned generators**
  (`typst-sync-check.sh --fix`, `check-module-invariants.sh --emit-inventory`), never hand-patched,
  and the `typst-sync-check.sh` hook's `--no-verify` bypass — reserved for drift another writer
  caused on a shared tree — was not used, because this drift was self-caused and exactly accounted
  for at +11 lines.

## Plan Deviations

- **Phase 1** altered: staging extended from the planned single file to include
  `typst/generated/status.typ`, because the `typst-sync-check.sh` Check 2 pre-commit hook blocks a
  staged `.lean` change whose net line count the committed `status.typ` no longer reflects.
- **Phase 2** altered: the plan's verification asked for the literal `Found 0 errors`. `runLinter`
  emits its `Found N errors in M declarations` line only on a FAILING run, so that string cannot
  appear on a clean one; the green verdict actually read was `-- Linting passed for FormalSystem.`
  with guard `exit_status=0`.
- **Phase 3** altered: the `INV` failure was repaired rather than reported, on the measured
  attribution recorded under Decisions above.
- **Phase 3** altered: the full gate set was discharged against a SCOPED tier
  (`verify-deploy.sh --only-gate 4`) per the dispatch's Batch Gate Deferral directive. The phase's
  `**Verification Tier**: full` field is unedited; the complete set runs once for the whole batch
  at the end of the /orchestrate invocation and is attributed back by this task's
  `modified_files`. Gate 4, the task-reference lint, is the only `verify-deploy.sh` gate covering a
  file this task touched — every other gate lints the `.claude/` deploy tree or the agent-system
  source store, and this task touched no path under either.
- **Phase 3** altered: the file count closed at six, not the planned two. The four beyond
  `LadderChain.lean` and `scripts/nolints.json` are the generated-artifact cascade of the comment
  edit's net line count.

## Verification

- Build: **Success**. Full guarded `lake build`: 2958 jobs, `Build completed successfully`, guard
  `exit_status=0`. Scoped guarded build of
  `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` green beforehand (2013/2013, 6.5s).
  The full gate set was deferred to the batch stage per the dispatch directive, not independently
  run; the scoped narrowing `verify-deploy.sh --only-gate 4` was run in its place and passed with
  1 check, 0 failures, nothing skipped under filter.
- `lake exe runLinter FormalSystem` through the build guard: `-- Linting passed for FormalSystem.`,
  guard `exit_status=0`. The finding at `LadderChain.lean:2136` is gone.
- `bash scripts/check-module-invariants.sh`: `ALL CHECKS PASSED`, exit 0, with
  `PASS C16 env_linter batch (defsWithUnderscore, docBlame, simpNF, structureInType, tacticDocs,
  unusedArguments) has no un-nolisted finding`. This is the condition the task exists to restore.
  C16's second, reporting-only half behind `ENFORCE_C16_ROOTS` still reports 230 findings across
  15 of 18 non-`FormalSystem` roots — unchanged, out of scope, and not exit-code-affecting.
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots).
- Vacuous count: **1 measured, 1 at the base commit, 0 introduced**. Recorded as measured rather
  than as the contract's bare 0, because the single match is neither new nor a placeholder:
  `FormalSystem/Examples/TemporalStructures.lean:495`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`, a genuine theorem
  whose conclusion is universally true, in a file this task never touched and byte-identical at
  the base commit.
- Axiom count: **14**, identical to the base commit's 14 — no increase. This task changed no proof
  term, so no axiom profile could move.
- `scripts/nolints.json` parses under `json.load`; 228 rows against a 227-row baseline, exactly one
  more; `git diff --numstat` reports 4 insertions, 0 deletions.
- `validate-artifact.sh <this plan> plan`: `[PASS] plan artifact is valid (0 warning(s))`, exit 0.
- `check-task-references.sh`: `PASS: 0 unexempted task-reference occurrences`, exit 0.
- Tests: N/A — no test surface is in scope; `runLinter` and `check-module-invariants.sh` are this
  task's own checks.
- Files verified: Yes. `git status --short` is empty for all six files, and the three commits
  (30fe201d4, 116c6c2af, 0d3454284) list exactly those six and nothing else.

## Impacts

- `scripts/check-module-invariants.sh` exits 0 again, so no downstream Lean task has to narrow its
  verification tier or carry a Reasoned Exclusions row for a failure it did not cause. That is the
  whole point of the task, and it is the one impact that matters.
- The `unusedArguments` grandfather ledger grows by one row, to 228. Nothing diffs its length
  against a baseline, so no second check moved.
- A reader at the declaration site now learns both linters and both remedies from the comment
  itself, so the frontend-only mistake that produced this finding is harder to repeat at the next
  dead binder in a pinned statement.

## Follow-ups

- **A net line-count change to any `.lean` file is never a one-file commit in this repository.**
  It fans out to `typst/generated/status.typ` (via the `typst-sync-check.sh` Check 2 pre-commit
  hook, which blocks the commit) and to every aggregator README inventory block above the file
  (via `check-module-invariants.sh`'s `INV` group, which fails the gate). Both cascades are
  mechanical and have sanctioned generators, but neither is discoverable from the plan: this task
  planned two files and closed six. A plan touching Lean source should name both generated
  surfaces in its file list up front.
- The 227 pre-existing `unusedArguments` rows are untouched. Burning them down, or migrating the
  category to in-source `@[nolint unusedArguments]`, remains a separate and larger decision.
- `scripts/check-module-invariants.sh` carries two stale "217 findings" header comments now
  understating a live 228. Left alone deliberately: no check reads them, and the file was outside
  this task's scope.

## References

- `specs/889_ladderchain_c16_unusedarguments_clear/plans/01_ladderchain-c16-unusedarguments-clear.md`
- `specs/889_ladderchain_c16_unusedarguments_clear/reports/01_ladderchain-c16-unusedarguments-clear.md`
- `specs/889_ladderchain_c16_unusedarguments_clear/handoffs/` — three phase-end handoffs
- `specs/889_ladderchain_c16_unusedarguments_clear/issues.jsonl`
- `scripts/check-module-invariants.sh` — the C16 block's own header, which records the `--update`
  prohibition independently
- `docs/development/NAMING_CONVENTION_DEVIATION.md` — the evidence behind `unusedArguments` being
  the sole permanently-grandfathered category
