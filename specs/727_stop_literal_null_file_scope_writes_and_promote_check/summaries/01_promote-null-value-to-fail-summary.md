# Implementation Summary: Task #727

- **Task**: 727 - Stop literal-null file_scope writes and promote the null_value sub-state to FAIL
- **Status**: [COMPLETED]
- **Started**: 2026-10-03T00:00:00Z
- **Completed**: 2026-10-03T01:20:00Z
- **Effort**: ~3 hours
- **Dependencies**: None
- **Artifacts**: plans/01_promote-null-value-to-fail.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Closed the dispatch's "literal-null writer" item as a no-op (no live writer exists; one historical
commit introduced every null, already remediated), and promoted `validate-state.sh` Check 10's
`null_value` sub-state from WARN to FAIL in default mode, with a display-cap exemption so the
promotion is genuinely exit-blocking rather than cosmetic. Updated the test suite for the new
posture (three fixtures broke, not two; all three fixed, two new fixtures added), deployed the
change, ran the full gate set against the deployed tree, and renamed task 711's stale
`project_name`.

## What Changed

- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh` (**source
  store**, outside this repository) — Check 10's reporting block split by level: `null_value`
  findings now emit `log_fail`, untruncated, independent of the pre-existing 10-item WARN display
  cap; `missing_key`/`empty_array` findings stay `log_warn`, capped as before, with the "N more"
  arithmetic recomputed against the WARN population only. Three header/comment locations (exit
  codes block, the `--help`-sourced base-mode bullet, the Check 10 banner/D2/PROMOTION comment)
  updated to record the split posture, the performed promotion (2026-10-03, justified by a live
  `null_value: 0` count), and the corrected writer attribution. A one-line cross-reference notes
  `orchestrate-predispatch-review.sh`'s Class B repair (null → `[]`) is intentional and untouched.
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-validate-state.sh`
  (**source store**) — the blended Check 10 fixture re-asserted to exit 1 with the new FAIL lines;
  the `--strict` fixture repointed at a new `scope10-warnonly-fixture.json` (no `null_value`
  entry) so it still tests what it claims; two new fixtures added
  (`scope10-nullonly-fixture.json`, `scope10-displaycap-fixture.json`); and a third,
  **previously unidentified** fixture fixed — the `--fix` non-manufacture fixture's exit-code
  assertion (its deliberately-untouched null-valued project 3 now flips that run's own exit code
  from 0 to 1).
- `.claude/scripts/validate-state.sh`, `.claude/scripts/tests/test-validate-state.sh` — regenerated
  by `deploy-headless.sh` (default, non-destructive mode); never hand-edited.
- `specs/state.json`, `specs/TODO.md` — task 711's `project_name` changed from
  `omega_automata_determinization_substrate` to `universal_summary_substrate_stab_fibre`
  (`state-write.sh`, mutex-guarded).
- `specs/711_omega_automata_determinization_substrate/` → `specs/711_universal_summary_substrate_stab_fibre/`
  — directory renamed via plain `mv` (untracked by git; no git rename recorded). Three empty
  subdirectories (`plans/`, `reports/`, `summaries/`) survived intact.

## Decisions

- **Item 1 (the writer) closed as a no-op.** Every historical `"file_scope": null` traces to one
  commit, `c1e5f5c3d` (2026-07-27, "specs: repair stale Theories/Bimodal path references after
  library rename"), independently re-verified via `git show --stat c1e5f5c3d -- specs/state.json`
  (58 insertions / 46 deletions, consistent with a bulk path-reference repair). It was remediated
  by `3f4599425` (2026-10-03). The three archival/orchestration commits previously blamed
  (`81647f25c`, `cb74c4c67`, `b12283595`) never wrote a null — `git log -S` surfaced them only
  because they *removed* pre-existing nulls (by archiving the affected tasks), confirmed by
  `git log --oneline -S'"file_scope": null' -- specs/state.json` showing the removal commit
  (`3f4599425`) immediately followed by the three archival commits in descending removal order.
  No current script constructs a `file_scope: null` write; every live occurrence of the literal
  string in the source store is a test fixture (5 files) or one worked example in
  `context/contracts/territory.md`.
- **Promotion scope: `null_value` alone, not `missing_key`.** Live re-count at Phase 1:
  `null_value: 0`, `missing_key: 28`, `empty_array: 0` across 56 non-terminal tasks (counts drift
  upward from the dispatch's historical "22" / planning's "28/29" as new tasks accrue — expected
  and harmless). Only `null_value` satisfies the stated promotion criterion today; `missing_key`
  remains WARN and `empty_array` remains advisory indefinitely, per the hard constraints.
- **Display-cap exemption, not a blanket re-level.** Without exempting `null_value` findings from
  the existing 10-item display cap, a literal null sorting past the first 10 findings (easily
  reached with 28 live `missing_key` findings) would print no FAIL line, leaving `FAILED` at 0 and
  making the promotion cosmetic. Verified empirically: with the exemption artificially disabled in
  a scratch copy, the display-cap fixture's specific per-finding grep
  (`file_scope null_value: project_number 999 (cand-null-high)`) failed to match even though the
  aggregate FAIL line and overall exit code were unaffected — proving the per-finding exemption,
  not just the aggregate line, is load-bearing.
- **Task 711 renamed, not left stale.** All three preconditions (untracked directory, three empty
  subdirectories, slug referenced only in `specs/state.json`/`specs/TODO.md`/this task's own
  artifacts) held exactly as planning measured. 711's `description`, `status` (`blocked`),
  `dependencies`, and `task_type` are byte-identical/unchanged (diffed against git HEAD before the
  edit).

## Plan Deviations

- **Task 4.7** (`verify-deploy.sh --deep`) altered: `--deep` is not a flag this script recognizes
  (confirmed via `--help`); ran the equivalent full/default invocation (no `--skip-slow`) instead,
  which is the deepest mode the script supports. Result: PASS, 14 checks, 0 failures.
- **A third broken test fixture was found and fixed**, beyond the plan's Scope Hypothesis estimate
  of two. The `--fix` non-manufacture fixture (pre-existing, testing that `--fix` does not mutate a
  null-valued `file_scope`) invokes the validator in `--fix` mode against a fixture carrying a
  deliberate null; that null is now FAIL-promoted, flipping the `--fix` run's own exit code from 0
  to 1. Fixed per the plan's own contingency instruction ("if a third fixture fails, fix that one
  too rather than treating the count as closed") by changing the assertion to `rc -eq 1` and
  adding a grep for the FAIL line, with a comment explaining this is Check 10 firing correctly, not
  a `--fix` regression.
- **Observation, no action taken**: task 727's own `file_scope` array (in `specs/state.json`)
  declares `specs/711_omega_automata_determinization_substrate/` as an in-scope path from
  plan-time harvest. After the Phase 5 rename this string no longer resolves to an existing
  directory. Left untouched per `file_scope`'s documented contract
  (`.claude/context/reference/state-management-schema.md` / `state-management.md`: the field is
  "descriptive/anticipated (not filesystem-validated)... never mutated by status-sync"); updating
  it was outside Phase 5's stated task list and is not required by any acceptance criterion.

## Verification

- Build: N/A (meta task; no Lean build touched)
- Tests: Passed — source-store and deployed `test-validate-state.sh` both report `38 passed, 0
  failed` (baseline 35 + 3: `scope10-warnonly-fixture`, `scope10-nullonly-fixture`,
  `scope10-displaycap-fixture`; the `--fix` fixture's assertion was corrected in place, not added).
- `bash -n` clean on both edited source-store scripts.
- `bash .claude/scripts/validate-state.sh specs/state.json` (dispatch's acceptance command): exit
  0, Passed 8 / Warnings 17 / Failed 0 — matches the Phase 1 baseline exactly (`null_value` was
  already 0 in live data, so the promotion is a no-op against this repo's current state).
- `bash .claude/scripts/validate-state.sh --strict specs/state.json`: exit 1, `(--strict: 17
  warning(s) promoted to exit-blocking)` — unchanged from before the promotion.
- `bash .claude/scripts/check-deploy-freshness.sh`: exit 0.
- Diff of both source-store files against their deployed counterparts: empty (byte-identical).
- `bash .claude/scripts/verify-deploy.sh` (full/default mode): PASS, 14 checks, 0 failures (one
  pre-existing, unrelated WARN about the lean extension's `routing_hard` migration notice).
- Files verified: yes (all edits re-read after writing; rename confirmed via `ls -R` and `git
  ls-files`).

## Impacts

- Any future PR or commit that introduces a literal-null `file_scope` into
  `specs/state.json` (in this repo or any other deploy consumer of the source store, once
  redeployed) now fails `validate-state.sh` in default mode, not just under `--strict`.
- `missing_key` (28 never-planned tasks) and `empty_array` remain WARN/advisory and untouched; no
  task gained a fabricated `file_scope`.
- Task 711 is now discoverable under its current name (`specs/711_universal_summary_substrate_stab_fibre/`);
  any external reference to the old directory path (none found live) would need updating, but none
  exists outside this task's own artifacts and the regenerated `specs/TODO.md`.
- The source-store edits are **not yet committed** in the `agent-system` repository
  (`/home/benjamin/.config/nvim/agent-system`) — that repository's working tree carries substantial
  unrelated uncommitted changes from other concurrent work, so this task deliberately left its two
  edited files (`scripts/validate-state.sh`, `scripts/tests/test-validate-state.sh`) as
  uncommitted local changes there rather than committing alongside unrelated dirty state. The
  plan's own Phase 4/Rollback sections describe only an in-repo (BimodalLogic) commit with a
  note of the out-of-repo edit, consistent with this. Pre-edit source-store HEAD for rollback
  reference: `3cf79cccdc75a574aeb6cd0750bd6f4d1e62bb70`.

## Follow-ups

- None required for acceptance. Optionally: someone with write access to
  `/home/benjamin/.config/nvim/agent-system` should commit the two edited source-store files
  (`scripts/validate-state.sh`, `scripts/tests/test-validate-state.sh`) once that repository's
  unrelated dirty state is otherwise resolved, so the change is durable there rather than only
  deployed.
- `missing_key`'s own promotion criterion (zero non-terminal tasks lacking `file_scope`) remains
  unmet (28 remaining, all by-design never-planned tasks) and is not a candidate for this task.

## References

- `specs/727_stop_literal_null_file_scope_writes_and_promote_check/plans/01_promote-null-value-to-fail.md`
- `specs/727_stop_literal_null_file_scope_writes_and_promote_check/reports/01_stop-null-file-scope-writes.md`
- `specs/727_stop_literal_null_file_scope_writes_and_promote_check/progress/phase-{1,2,3,4,5}-progress.json`
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh` (source
  store, edited, uncommitted in that repo)
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-validate-state.sh`
  (source store, edited, uncommitted in that repo)
