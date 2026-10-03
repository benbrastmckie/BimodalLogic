# Research Report: Task #727

**Task**: 727 - Stop literal-null file_scope writes and promote the null_value sub-state to FAIL
**Started**: 2026-10-03T18:11:00Z
**Completed**: 2026-10-03T18:40:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `.claude/scripts/validate-state.sh` (deployed) and
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh` (source
  store, resolved via `.claude-extensions.json`'s `source_dir`)
- `git log -S` archaeology on `specs/state.json`, full before/after `jq` diffs per candidate commit
- `.claude/scripts/tests/test-validate-state.sh` (source-store copy)
- `.claude/skills/skill-todo/SKILL.md` (archive/vault write paths)
- `.claude/docs/architecture/batch-admit-schema.md`, `context/patterns/batch-orchestration-guardrails.md`
- Live run of `bash .claude/scripts/validate-state.sh specs/state.json`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Remaining Item 1 (the writer): no live writer exists.** Exhaustive `git log -S` archaeology
  shows the historical `"file_scope": null` lines were introduced by exactly **one** commit,
  `c1e5f5c3d` ("specs: repair stale Theories/Bimodal path references after library rename",
  2026-07-27, by `benbrastmckie` with Claude Opus 5 as co-author) — a one-off interactive/agent
  path-reference repair, not a committed script. Every later commit the prior repair's own commit
  message (`3f4599425`) blamed — `81647f25c`, `cb74c4c67`, `b12283595` — only ever **removes or
  relocates** pre-existing nulls (archiving the entries away, or flipping one null to `[]`); none
  of them ever adds a `"file_scope": null` line. That prior attribution was incorrect; `git log -S`
  surfaces those commits only because they changed the total occurrence *count*, not because they
  wrote nulls. A full survey of every current script and skill that writes `specs/state.json`
  (`state-write.sh` callers in `skill-todo/SKILL.md`, `orchestrate-predispatch-review.sh`,
  `orchestrate-batch-admit.sh`, `task-lock.sh`, `plan-file-scope-harvest.sh`,
  `backfill-file-scope.sh`) found **zero** production code paths that construct a task/archive
  entry with a literal `"file_scope": null` key — every current writer either omits the key,
  preserves whatever the source object already had, or defensively guards against null with
  `// []` / `!= null` tests. The only places `"file_scope": null` appears in the source store
  today are test *fixtures* that simulate an already-broken input, never a writer. **Conclusion:
  there is nothing to fix for Item 1 — close it with this finding, per the dispatch's own
  escape clause** ("if later refactoring already removed the offending write, close with that
  finding rather than inventing a guard for a dead path").
- **Remaining Item 2 (the promotion): safe to perform today.** A live count confirms
  `null_value: 0` among all 57 non-terminal tasks (`missing_key: 29`, `empty_array: 0`), and a
  live run of `validate-state.sh` against `specs/state.json` passes today (`0 FAILED`,
  `17 WARN`). Promoting `null_value` alone to FAIL in default mode is satisfiable right now
  without breaking the build, but requires: (a) splitting Check 10's per-finding loop so a
  `null_value` finding calls `log_fail` while `missing_key`/`empty_array` keep calling `log_warn`;
  (b) deciding how the aggregate "file_scope visibility: N missing-key, M literal-null, K
  empty-array" summary line is leveled (see Decisions below); and (c) updating the one existing
  test fixture in `test-validate-state.sh` (around line 745) that currently asserts `rc -eq 0`
  for a fixture containing a `null_value` entry — that assertion will flip to `rc -eq 1` once the
  promotion lands, and the test's grep for `file_scope null_value: ...` must become a `[FAIL]`
  line expectation instead of `[WARN]`.
- **Second item (task 711 rename): low-risk, deferred to a plan-level decision.** Task 711's
  directory (`specs/711_omega_automata_determinization_substrate/`) has empty `plans/`,
  `reports/`, and `summaries/` subdirectories (no artifacts yet), and nothing outside that
  directory references the literal slug string `omega_automata_determinization_substrate` —
  `ROADMAP.md` cites the task only by number (711). A rename is cheap today; it will not stay
  cheap once artifacts exist under the old path.

## Context & Scope

Task 727 names two concrete remediation items plus one unrelated hygiene item, scoped against
`validate-state.sh` Check 10 (the existing missing/null/empty `file_scope` detector) and
`specs/state.json`. The task explicitly forbids inventing scopes for never-planned tasks,
altering dependencies/status/description, or weakening any existing check. This research
establishes: (1) whether a live writer of literal-null `file_scope` still exists anywhere in the
source store, (2) whether the `null_value` sub-state is safe to promote to FAIL in default mode
today, and (3) the current state of task 711's directory-rename question.

## Findings

### Codebase Patterns

**Check 10 (already built, confirmed correct)** — `validate-state.sh` lines ~627-691 (source
store: `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh`,
mirrored at `.claude/scripts/validate-state.sh` in the deployed tree). It already:
- Computes over the non-terminal population (`status` not in `{completed, abandoned, expanded}`).
- Classifies each entry into exactly one of `missing_key` (`has("file_scope") | not`), `null_value`
  (`has("file_scope") and .file_scope == null`, via an `if/elif` chain — equivalent to the `has()`
  test plus an explicit null check, not a bare `has()` presence test alone), or `empty_array`
  (`.file_scope == []`).
- Reports one aggregate `log_warn` summary line (`"file_scope visibility: $scope_missing
  missing-key, $scope_null literal-null, $scope_empty empty-array, out of $scope_denominator
  non-terminal task(s)"`) plus up to 10 individual per-finding `log_warn` lines
  (`"file_scope $sub_state: project_number $pnum ($name)"`), then a `"... and N more"` line if
  truncated.
- Already documents the exact promotion criterion this task executes, in its own header comment:
  promote `missing_key` and `null_value` from WARN to FAIL once no non-terminal task lacks a
  usable `file_scope`; `empty_array` stays advisory indefinitely.

**The writer archaeology** — `git log -S'"file_scope": null' --oneline --reverse -- specs/state.json`
returns six commits: `c1e5f5c3d`, `4545b0916`, `b12283595`, `cb74c4c67`, `81647f25c`, `3f4599425`.
Diffing each commit's before/after `specs/state.json` (via `git show <sha>^:...` /
`git show <sha>:...` and a `jq` presence/null query, not a line-count heuristic) shows:

| Commit | Message | Adds `"file_scope": null`? | What it actually does |
|---|---|---|---|
| `c1e5f5c3d` | specs: repair stale Theories/Bimodal path references | **Yes — all 12 instances** (project_numbers 125,127,128,161,165,175,179,219,231,318,377,378) | One-off path-reference repair, co-authored by Claude Opus 5; not a repo script |
| `4545b0916` | task: abandon tasks 318 | No | Removes the entry for an abandoned task (incidentally deletes a pre-existing null) |
| `b12283595` | todo: archive 11 completed tasks | No | Removes archived entries wholesale (relocates, doesn't rewrite the key) |
| `cb74c4c67` | task 165: orchestration paused | No | Flips one entry's existing `null` to `[]` elsewhere in the same diff |
| `81647f25c` | todo: archive 11 tasks and track 9 orphaned directories | No | Same removal pattern as `b12283595` |
| `3f4599425` | specs: drop literal-null file_scope keys on five never-planned tasks | No (this is the 2026-10-03 repair, net *removal* of the 5 survivors) | Deletes the key outright on 125/127/128/219/231 |

The prior repair commit's own message attributed the nulls to "archival/orchestration writes
(81647f25c, cb74c4c67, b12283595)" — that attribution does not hold up: none of those three ever
adds the literal string. They appear in `git log -S`'s output only because `-S` matches any
commit that changes the *occurrence count* of the pickaxe string, and all three change that count
by removing pre-existing nulls (via archiving entries away or flipping one to `[]`), not by
writing new ones.

**Current writer survey (zero live null-writers found)** — grepped every script/skill in the
source store (`agent-system/extensions/core/`) that writes `specs/state.json` for a literal
`"file_scope": null` construction:
- `skill-todo/SKILL.md`'s `ArchiveTasks` stage (around line 500) moves the **whole existing task
  object** into `completed_projects`, adding only `archived_at` — it preserves whatever
  `file_scope` shape the entry already had (including its absence); it never introduces one.
- `skill-todo/SKILL.md`'s TODO-orphan archival path (around line 558-572) constructs a
  **fixed-key** archive entry (`project_number`, `project_name`, `status`, `created_at`,
  `archived_at`) that deliberately **omits** `file_scope` entirely — this is the correct,
  Create-Task-Mode-matching shape the dispatch asks every writer to match, already implemented
  correctly here.
- `orchestrate-predispatch-review.sh`'s `--repair` mode (Class B) explicitly *removes* a literal
  null by rewriting it to `[]` — a repair tool, not a producer.
- `task-lock.sh`, `plan-file-scope-harvest.sh`, `backfill-file-scope.sh`, and
  `orchestrate-batch-admit.sh` all guard reads with `// []` or `!= null`/`== null` branches; none
  constructs a write containing a literal null `file_scope`.
- The only `"file_scope": null` literals left in the source store are inside test **fixtures**
  (`tests/test-validate-state.sh`, `tests/test-orchestrate-predispatch-review.sh`,
  `tests/test-orchestrate-batch-admit.sh`, `tests/test-backfill-file-scope.sh`,
  `context/contracts/territory.md`'s worked example) — these intentionally simulate an
  already-broken input to exercise detection/repair logic; they are not writers.

**Live counts (confirms Item 2 is safe today)**:
```
$ jq -c '... non-terminal ...' specs/state.json
{"denominator":57,"missing_key":[... 29 project numbers ...],"null_value":[],"empty_array":[]}

$ bash .claude/scripts/validate-state.sh specs/state.json
...
file_scope visibility: 29 missing-key, 0 literal-null, 0 empty-array, out of 57 non-terminal task(s)
...
Passed:   8
Warnings: 17
Failed:   0
STATE VALIDATION PASSED WITH WARNINGS
```
`null_value` is exactly zero; `missing_key` is 29, not the 22 the dispatch's historical figure
cites (the task set has grown since that measurement — 710-728 and a few others are newly
created, never-planned tasks, which is the correct by-design state, not a regression). Since
promotion is scoped to `null_value` alone, `missing_key`'s higher count does not block it.

**Test fixture requiring a companion update** — `tests/test-validate-state.sh` (source store),
the "Check 10 fixture" around line 733-759, asserts `rc -eq 0` for a fixture containing one
`missing_key`, one `null_value`, and one `empty_array` entry, with all three appearing as
`[WARN]` lines. Once `null_value` is promoted to FAIL in default mode, this exact fixture will
exit 1 (not 0) and its `null_value` line will render as `[FAIL]` rather than `[WARN]`. This test
must be updated in the same change that performs the promotion, or the test suite breaks.

**Task 711 directory state**:
```
$ jq -r '.active_projects[] | select(.project_number==711) | {project_name, status}' specs/state.json
{"project_name":"omega_automata_determinization_substrate","status":"blocked"}

$ ls specs/711_omega_automata_determinization_substrate/
plans/  reports/  summaries/        # all empty

$ grep -rln "omega_automata_determinization_substrate" specs/ .claude/ | grep -v "^specs/711_.../"
(no results)
```
`ROADMAP.md` references task 711 only by its bare number (`711`), in five places, never by the
directory slug. No artifact exists under the directory yet, so a rename today touches only the
directory name and the `project_name` field in `state.json` — no artifact-path citations to fix.

### External Resources

Not applicable — this is a pure in-repo mechanism/history investigation; no external
documentation was consulted.

## Recommendations

1. **Item 1 — close as "no writer exists."** Do not add a guard against a dead code path. The
   plan/implement phase should record, in the task's artifacts, the corrected attribution
   (single one-off commit `c1e5f5c3d`, not the three archival/orchestration commits the prior
   repair blamed) so a future reader does not re-open a search for a script that was never
   there.
2. **Item 2 — perform the promotion in `validate-state.sh` Check 10**, in the source store at
   `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-state.sh` (never
   the deployed `.claude/scripts/validate-state.sh` directly — it is regenerated). Concretely:
   - In the per-finding loop (`while IFS=$'\t' read -r _c10_pnum _c10_sub _c10_name; do ... done`),
     branch on `_c10_sub`: call `log_fail` when `_c10_sub == "null_value"`, `log_warn` otherwise
     (`missing_key`, `empty_array`).
   - Decide and document the aggregate summary line's level: since it already blends all three
     counts into one message, a reasonable approach that preserves full information without
     misclassifying a would-be-WARN task as FAIL in the common case where `null_value` is zero: emit
     the existing aggregate line via `log_warn` only when `scope_missing + scope_empty > 0` (today's
     WARN-worthy residue), and additionally emit a dedicated `log_fail` summary line
     (`"file_scope literal-null: $scope_null finding(s)"`) only when `scope_null > 0` — this keeps
     the three sub-states independently gated exactly as the header comment promises, and avoids a
     single aggregate line forcing a WARN/FAIL level mismatch with its own per-finding lines.
   - Update the header comment's "PROMOTION CRITERION" paragraph (already partially written) to
     record that the promotion has been performed for `null_value` only, with the date, leaving
     `missing_key`'s own promotion criterion text in place (it is not satisfied — 29 remaining).
   - Update `tests/test-validate-state.sh`'s Check 10 fixture (around line 733-759) to expect
     `rc -eq 1` and a `[FAIL]`-prefixed `null_value` line, while keeping `missing_key`/`empty_array`
     as `[WARN]`. Add or adjust a companion fixture that isolates a pure-`null_value` finding (no
     missing/empty) to pin the new FAIL/exit-1 behavior independently of the blended fixture.
   - Re-run `bash .claude/scripts/validate-state.sh specs/state.json` after deploying, to confirm
     it still exits 0 (expected, since live `null_value` is 0 today).
3. **Task 711 rename** — this is a judgment call for the user/plan phase, not mandated by Item 1
   or 2. Given the directory is currently empty of artifacts and nothing outside it cites the
   slug, renaming now (updating `project_name` in `state.json` plus `mv`-ing the directory) is
   low-risk; deferring the decision is equally safe since the status quo causes no breakage —
   only recommend doing it before any artifact is written under the current path, after which the
   rename stops being free.
4. Do not touch `missing_key` or `empty_array` enforcement levels, and do not populate
   `file_scope` for any of the 29 missing-key never-planned tasks — both explicitly out of scope
   per the dispatch's hard constraints and confirmed, by this research, to be the correct
   by-design state.

## Decisions

- **Item 1 is closed with a "no live writer" finding**, not a code change. The single historical
  write was a one-off manual/agent edit (commit `c1e5f5c3d`), already fully remediated by the
  2026-10-03 repair commit (`3f4599425`); no commit since has reintroduced a null, and no current
  script constructs one.
- **The prior repair commit's attribution of the nulls to archival/orchestration writes is
  incorrect** and should not be propagated further; this report's commit-by-commit diff table is
  the corrected record.
- **The `null_value` promotion is confirmed safe to implement now** (live count is zero); the
  concrete mechanism is a per-finding-loop branch plus a split aggregate-summary line, not a
  blanket re-leveling of Check 10.
- **The aggregate summary line must not simply flip to `log_fail` wholesale** — doing so would
  make every `missing_key`/`empty_array`-only state.json fail validation, which both breaks a
  passing build today (29 `missing_key` findings currently exist) and directly violates the
  dispatch's hard constraint against promoting `missing_key`/`empty_array`.
- **Task 711's rename is left as an explicit, deferred decision** for the plan phase rather than
  performed or ruled out here — it is not required by either Remaining Item and the dispatch asks
  only that it be decided "deliberately."

## Risks & Mitigations

- **Risk**: a future one-off manual/agent `jq` edit (like `c1e5f5c3d`) could reintroduce a literal
  null at any time, since no code path is actually being modified to prevent this (there is
  nothing to modify). **Mitigation**: this is exactly what the Check 10 promotion defends
  against — once `null_value` is FAIL in default mode, any future reintroduction (however it
  happens) is caught the next time `validate-state.sh` runs, including in `verify-deploy.sh`'s
  gate, rather than persisting silently for months as it did between 2026-07-27 and 2026-10-03.
- **Risk**: splitting Check 10's single aggregate WARN line into a WARN-conditional-plus-FAIL-
  conditional pair could be read as "weakening" the check if done carelessly (e.g., dropping a
  count). **Mitigation**: the recommendation above preserves both the full per-sub-state detail
  (same three individual per-finding lines, just re-leveled) and the aggregate counts (split into
  two conditionally-emitted lines rather than one blended line) — no information is lost, and the
  one existing passing-build guarantee (0 FAILED today) is explicitly re-verified before closing
  this task.
- **Risk**: the `test-validate-state.sh` Check 10 fixture is the one place this promotion has a
  blast radius; missing that update would leave CI/the test suite red. **Mitigation**: flagged
  explicitly above with the exact fixture location and the exact assertion that must change.

## Context Extension Recommendations

- **Topic**: Check 10's own header comment already documents the promotion criterion fully; no
  new context file is needed. The one gap worth noting: no existing context file records the
  corrected writer-attribution history established by this report (the prior repair commit's
  message blaming archival/orchestration commits). Recommend folding the corrected table above
  into the implementation summary this task produces, rather than creating a new standalone
  context file for a single historical correction.

## Appendix

Search queries / commands used:
```
git log -S'"file_scope": null' --oneline -- specs/state.json
git log -S'"file_scope": null' --oneline --reverse -- specs/state.json
git show <sha>^:specs/state.json / git show <sha>:specs/state.json  (per-commit before/after)
jq -c '... null_value/missing_key/empty_array counts over non-terminal tasks ...' specs/state.json
bash .claude/scripts/validate-state.sh specs/state.json
grep -rn "file_scope" .claude/scripts/*.sh .claude/scripts/lib/*.sh
grep -rn "file_scope" agent-system/extensions/core (source store, via .claude-extensions.json's source_dir)
grep -n "Check 10" -r agent-system/extensions/core
grep -rln "omega_automata_determinization_substrate" specs/ .claude/
```
