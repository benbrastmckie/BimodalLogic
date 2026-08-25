# Research Report: Task #487

**Task**: 487 - Fix 128KB argv ceiling in roadmap-integration.sh and state-write.sh
**Started**: 2026-08-25T20:16:52Z
**Completed**: 2026-08-25
**Effort**: Medium (two scripts, one narrow fix + one structural fix + one heuristic fix + tests)
**Dependencies**: None
**Sources/Inputs**: Codebase (agent-system/extensions/core/scripts/, .claude/scripts/ deployed copies, skill-todo/SKILL.md, commands/todo.md, commands/review.md), live reproduction against the current repo's specs/ROADMAP.md and specs/state.json
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Both defects are real and currently live in the source store (`/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/`, which is byte-identical today to the deployed `.claude/scripts/` copies). Both were reproduced live in this session, non-destructively.
- **Defect 1** (`roadmap-integration.sh:788`): the final `jq -n --argjson roadmap_state ... --argjson roadmap_matches ...` call passes the full payload through argv. Reproduced against the live repo: `bash .claude/scripts/roadmap-integration.sh --roadmap specs/ROADMAP.md --state specs/state.json` exits **126**, `jq: Argument list too long`, even in parse-only mode (no `--annotate`).
- Notably, an *earlier* stage of the same script (the `ROADMAP_STATE`/`ALL_COMPLETED` cross-reference at lines ~363-373) was **already fixed** in a prior pass — it writes both payloads to temp files and reads them with Python `open()`/`json.load()`, with an in-file comment pointing forward to "the analogous fix" at the final `jq -n`. That forward-pointing fix was never actually made. The final `jq -n` block (lines 788-800) is the only remaining argv-based payload passthrough in this script, and it is the actual crash site.
- **Defect 2** (`state-write.sh`): `--argjson NAME VALUE` is parsed into `JQ_ARGS+=(--argjson "$2" "$3")` and forwarded unchanged to `jq "${JQ_ARGS[@]}" "$JQ_FILTER" "$STATE_FILE"` (line 349, also in the `--dry-run` branch at line 282). This is a **generic pass-through** — state-write.sh has no fixed schema of known payloads (unlike roadmap-integration.sh), so any caller's oversized value trips the same ceiling. Reproduced live: a 160,002-byte JSON array passed via `--argjson stuff "$big_json" --dry-run` fails with exit 126, `Argument list too long`, before jq even runs (the shell itself cannot exec a command with a >128KB single argv token).
- The one caller known to have hit this in production is the `/todo` archival batch write in `skill-todo/SKILL.md` (Stage 10, ~line 459-465) and its mirror in `commands/todo.md` (~line 534-541): both build `archivable_tasks_json` from the full task-archival batch and pass it as `--argjson tasks "$archivable_tasks_json"`. The task description records this hit 168,180 bytes and was manually worked around by splitting into 4 batches.
- The codebase already has an established convention for large single-payload jq inputs: `--slurpfile` (used in `install-extension.sh`, `orchestrate-batch-admit.sh`, `orchestrate-triage-classify.sh`, `orchestrate-predispatch-review.sh`, `system-defect-record.sh`, `validate-context-budgets.sh`, and roadmap-integration.sh's own already-fixed mid-script step). The fix for both defects should follow this precedent rather than invent a new file-passing mechanism.
- Requirement 2 (atomicity) is a distinct, larger issue from requirement 1 (argv size): today, each annotation in `roadmap-integration.sh`'s `--annotate` loop is applied directly to `$ROADMAP_PATH` in place (via per-iteration `mktemp` + `mv`), one at a time, and the crash-prone final `jq -n` report-building step runs only *after* the entire annotate loop has already mutated the real file. Fixing only the argv-size bug does not, by itself, satisfy the task's stated acceptance bar ("A forced mid-run failure leaves ROADMAP.md byte-identical to its pre-run state") — that requires routing every annotation through a staging copy and moving it into place only once, after the report is fully constructed.
- Requirement 3 (tighten `explicit_task_ref`) needs a data-shape change, not just a regex tweak: today `find_match()` only ever sees `all_completed` (completed + archived tasks) and uses `re.search` (first match only) against `\(task (\d+)`. Enforcing "no sibling/follow-on task referenced by the same item is still non-terminal" requires (a) finding *all* task-number references in the item text, not just the first, and (b) checking each against the full set of active (non-terminal) tasks, which the python matching step currently has no visibility into at all — only `$STATE_PATH`'s `completed`-status projects and the archive are read into `all_completed`/`task_by_number`.

## Context & Scope

Task 487 requires two coordinated fixes plus a heuristic tightening plus regression tests, scoped to `agent-system/extensions/core/scripts/roadmap-integration.sh` and `agent-system/extensions/core/scripts/state-write.sh` in the source store (per `.claude/rules/source-store-deploy-boundary.md`, `.claude/` itself must never be hand-edited). This report covers investigation only — no code was changed.

Both scripts were read in full. The failure was reproduced live against the real, current `specs/ROADMAP.md` / `specs/state.json` (roadmap-integration.sh, parse-only mode — no mutation risk since `--annotate` was not passed) and against a synthetic oversized payload for state-write.sh (`--dry-run`, no mutation).

## Findings

### Defect 1: roadmap-integration.sh

**Location**: `roadmap-integration.sh:788-800` (source-store path: `agent-system/extensions/core/scripts/roadmap-integration.sh`, identical in `.claude/scripts/roadmap-integration.sh`).

```bash
jq -n \
  --argjson roadmap_state "$ROADMAP_STATE" \
  --argjson roadmap_matches "$ROADMAP_MATCHES" \
  --argjson annotations_made "$ANNOTATIONS_MADE" \
  ...
```

`$ROADMAP_STATE` (produced at line 165-298) and `$ROADMAP_MATCHES` (produced at line 373-531) are both unbounded-size JSON blobs — `$ROADMAP_STATE` embeds every parsed phase/checkbox/table row including `raw_line` text; `$ROADMAP_MATCHES` embeds one object per candidate match, several of which additionally carry `line_index`/`raw_line`/`status_index` for the table-row annotation path. Both are passed as single argv tokens via `--argjson`.

**Live reproduction** (parse-only, no `--annotate`, non-destructive):
```
$ bash .claude/scripts/roadmap-integration.sh --roadmap specs/ROADMAP.md --state specs/state.json
<!-- roadmap-structure phases=7 checkboxes=39 table_rows=57 parseable=true -->
.claude/scripts/roadmap-integration.sh: line 788: /home/benjamin/.nix-profile/bin/jq: Argument list too long
$ echo $?
126
```
This confirms the crash fires unconditionally on the live repo, even without `--annotate` — i.e. defect (a) from the task description ("silent degradation" masquerading as "nothing to do" in `/review`/`/todo`'s error contract) is currently live on every invocation against the real `specs/ROADMAP.md`, not just an edge case.

**Partial prior fix, misleadingly labeled**: An earlier step in the same script (constructing `ROADMAP_MATCHES` from `ROADMAP_STATE` and `ALL_COMPLETED`) already had this exact defect and was already fixed, at lines 363-373:
```bash
# ROADMAP_STATE and ALL_COMPLETED can each exceed Linux's MAX_ARG_STRLEN (131,072 bytes) ...
# Pass both via temp files instead and json.load() them in python ...
TMP_ROADMAP_STATE=$(mktemp)
TMP_ALL_COMPLETED=$(mktemp)
trap 'rm -f "$TMP_ROADMAP_STATE" "$TMP_ALL_COMPLETED"' EXIT
printf '%s' "$ROADMAP_STATE" > "$TMP_ROADMAP_STATE"
printf '%s' "$ALL_COMPLETED" > "$TMP_ALL_COMPLETED"
ROADMAP_MATCHES=$(python3 - "$TMP_ROADMAP_STATE" "$TMP_ALL_COMPLETED" << 'PYEOF' ...)
```
A comment at line 172 explicitly says "see defect 1, line ~238 for the analogous fix on the ALL_COMPLETED/ROADMAP_STATE payloads" — but no such fix exists at the final `jq -n` (line 788). The comment is aspirational/forward-referencing and was never followed through. This is useful context for the planner: the fix pattern (temp file + read, `trap ... EXIT` cleanup) is already established *in this exact file*, one call site over — the final `jq -n` needs the same treatment (temp files + `--slurpfile`, since the final step is `jq`, not Python, so `--rawfile`/`--slurpfile` is the natural analogue rather than argv).

**Consequence (b) — partial mutation — confirmed structurally**: In `--annotate` mode, the annotate loop (lines 557-757) writes each accepted annotation directly into `$ROADMAP_PATH` via `mv "$TMPFILE" "$ROADMAP_PATH"` (checkbox branch, line 638; table-row branch, line 728) *before* the final `jq -n` report step runs. If the final `jq -n` crashes (as it does today, unconditionally, once the payload is large enough), every annotation already applied in that run has landed on disk, but the process exits 126 having printed no JSON at all. This is exactly the task's documented incident (the BimodalReference roadmap item wrongly checked off, later manually reverted).

**Requirement 2 is not satisfied merely by fixing requirement 1.** Even after removing the argv-size crash at line 788, the annotate loop still writes directly to `$ROADMAP_PATH` one annotation at a time, with no staging/rollback. Any other mid-loop failure (a bad `sed`/`awk` interaction, a killed process, an unrelated crash) still leaves `ROADMAP.md` half-annotated. The acceptance criterion "A forced mid-run failure leaves ROADMAP.md byte-identical to its pre-run state" requires routing all writes in `--annotate` mode through a private staging copy (e.g. `mktemp`, seeded with a copy of `$ROADMAP_PATH`, all `awk`/`mv` operations in the loop retargeted at the staging file instead of `$ROADMAP_PATH`) and doing exactly one `mv staging_file "$ROADMAP_PATH"` at the very end, only after the full JSON report has been successfully constructed. This is a structural change to the annotate loop, not a one-line fix.

**Requirement 3 — explicit_task_ref heuristic** (`find_match()`, lines 407-451, Check 1 at 411-418):
```python
task_ref = re.search(r'\(task (\d+)', item_text, re.IGNORECASE)
if task_ref:
    task_num = int(task_ref.group(1))
    if task_num in task_by_number:
        return task_by_number[task_num], "high", "explicit_task_ref"
```
Two gaps relative to the required fix:
1. `re.search` finds only the *first* `(task N` occurrence in `item_text`. The task's own example ("tasks 314-318 in flight/not-started") shows an item can reference several task numbers in prose; only the first is ever inspected.
2. `task_by_number` is built exclusively from `all_completed` (line 386-388), itself sourced only from `COMPLETED_TASKS` (state.json `active_projects[]` filtered to `status == "completed"`, line 334-343) plus `ARCHIVED_TASKS` (archive `completed_projects[]`, line 349-358). The python matching step has **no visibility at all** into non-terminal (in-flight/not-started/blocked) tasks — `state.json`'s full `active_projects[]` is never passed to this step, only the completed subset. Enforcing "no sibling/follow-on task referenced by the same item is still non-terminal" therefore requires plumbing the full active-task list (numbers + statuses, not necessarily full records) into this python step as a new input, in addition to `all_completed`. This is a data-flow change to the `ROADMAP_STATE`/`ALL_COMPLETED` → matching-step call (lines 373-381), not just a regex edit.

**Requirement 4 (optional, "consider")**: per-match payload trimming. Only `roadmap_matches` fields consumed downstream are read via plain `jq '.roadmap_matches'` passthrough by `/review` (`commands/review.md:88`) and rendered into a "Current Focus" table using `roadmap_state.phases` and `roadmap_matches` (per `commands/review.md:330-331`) — i.e. consumers currently take the whole array, not a filtered subset, so no consumer contract is broken by trimming, but no consumer forces the currently-present fields (`line_index`/`raw_line`/`status_index`) to be dropped either, since the annotate loop reads them straight out of `ROADMAP_MATCHES`. This is a genuine size-reduction opportunity but is explicitly framed as optional in the task description ("Consider trimming...") and is separable from the required fixes — flagging for the planner to scope in/out rather than resolving here.

### Defect 2: state-write.sh

**Location**: `state-write.sh:179-187` (arg parsing) and `state-write.sh:280,282,347,349` (both dry-run and real transform call sites).

```bash
--argjson)
  ...
  JQ_ARGS+=(--argjson "$2" "$3")
  shift 3
  ;;
...
transform_err=$(jq "${JQ_ARGS[@]}" "$JQ_FILTER" "$STATE_FILE" 2>&1 > "$STAGE_FILE") || transform_status=$?
```

Unlike `roadmap-integration.sh`, this script has **no fixed schema** — `--argjson NAME VALUE` is a fully generic passthrough used by ~10 different callers across the codebase for arbitrary payloads, most of them small (single task numbers, small objects). The one call site known to exceed the ceiling is the `/todo` archival batch:

- `skill-todo/SKILL.md` (Stage 10, ~lines 454-465):
  ```bash
  archivable_tasks_json=$(printf '%s\n' "${archivable_tasks[@]}" | jq -s '.')
  bash .claude/scripts/state-write.sh \
    '.completed_projects = ([$tasks[] | select(...)] + .completed_projects) | ...' \
    --state-file specs/archive/state.json \
    --session-id "$todo_session_id" \
    --arg ts "..." \
    --argjson tasks "$archivable_tasks_json"
  ```
- `commands/todo.md` (~lines 534-541) mirrors the identical shape — both files must be updated in tandem, since `commands/todo.md` documents the same Step 5A call the skill executes.

The task description records this payload reaching 168,180 bytes when archiving 21 tasks in one run, worked around at the time by manually splitting into 4 batches (an unfixed, brittle workaround still baked into whatever ran that day — not present in the current SKILL.md/todo.md text, which shows the single-call, non-batched shape above).

**Live reproduction** (`--dry-run`, no mutation):
```
$ big_json=$(python3 -c "print('[' + ','.join(['\"x\"']*40000) + ']')")  # 160,002 bytes
$ bash .claude/scripts/state-write.sh '.' --session-id "test_sess_repro" --argjson stuff "$big_json" --dry-run
/run/current-system/sw/bin/bash: line 4: /run/current-system/sw/bin/bash: Argument list too long
$ echo $?
126
```
Note the failure here happens even earlier than in defect 1 — the shell cannot even `exec` the `bash .claude/scripts/state-write.sh ...` command line itself, because one of its own argv tokens (the `$big_json` value passed positionally to `--argjson`) already exceeds `MAX_ARG_STRLEN` (131,072 bytes) on its own. This confirms the root cause is exactly as described: a **single argv entry** over 128KB, independent of the total `ARG_MAX` (2MB on this system) — batching into smaller argv entries doesn't help if any single one is still over the per-entry cap, but splitting into multiple *invocations* (as the manual workaround did) sidesteps it by keeping each call's largest single token under the ceiling.

**Codebase precedent for the fix**: `--slurpfile` is the established convention for exactly this situation elsewhere in the same scripts directory — e.g. `orchestrate-batch-admit.sh:493` (`--slurpfile state_arr "$STATE_FILE"`), `orchestrate-triage-classify.sh:254`, `system-defect-record.sh:298` (explicit comment: "state.json can be large ... read it via --slurpfile (a file argument) rather than argv"), `validate-context-budgets.sh:374`, and `install-extension.sh:206,220`.

**Design consideration for the planner — two viable shapes, both explicitly named in the task description**:
1. **Explicit new flag** (`--argjson-file NAME PATH`, task's suggested name) mapping to `jq --slurpfile NAME PATH`, requiring the jq filter to reference `$NAME[0]` instead of `$NAME` (since `--slurpfile` always binds an array of all JSON values in the file) — OR the flag's implementation could inject a `($NAME[0]) as $NAME |` prefix into the filter so caller syntax is unaffected. This requires updating the two known call sites (`skill-todo/SKILL.md`, `commands/todo.md`) to use the new flag for the archival-batch payload specifically.
2. **Transparent auto-spill**: have the existing `--argjson NAME VALUE` handling measure `${#VALUE}` and, above a safe threshold (comfortably under 131,072 bytes, e.g. 100,000), write `VALUE` to a private per-call `mktemp` file instead of putting it in `JQ_ARGS` directly, add a `--slurpfile` binding for a synthetic private name instead, and prefix the eventual `jq` invocation's filter string with a `($__private_name[0]) as $NAME |` binding — so `$NAME` continues to resolve exactly as callers already expect, with **zero changes required at any of the ~10 existing call sites** (including future callers). This mirrors the "have the existing --argjson spill oversized values to a temp file transparently" option the task description names explicitly, and is more robust against the next caller that happens to construct an oversized payload without knowing about a special flag.

Either shape must preserve: fail-closed mutex acquisition, the private-mktemp staging path (already separate from any new spill file), the `--init`/`--state-file`/`--regen-todo` refusal logic (D3/D4 checks, lines 225-257), and the documented exit-code contract (0/1/2/3/4) — none of these are touched by either shape, since the change is confined to how `JQ_ARGS` is built and how the `jq` invocation's filter/flags are assembled at lines 280-283 and 346-350 (both the dry-run and real-transform call sites need the identical treatment, since dry-run also forwards `"${JQ_ARGS[@]}"` and would otherwise still crash under `--dry-run` on an oversized payload, as reproduced above).

## Decisions

- No code changes were made in this research pass; the task explicitly calls this out as tooling repair, not exploratory analysis, and the planner should own the concrete flag/spill design choice (see the two-shape comparison above).
- Verified both defects are live in the current source-store code (not already partially fixed apart from the one already-fixed roadmap-integration.sh mid-script step noted above).
- Confirmed the two known call sites needing updates for the state-write.sh fix (`skill-todo/SKILL.md` Stage 10, `commands/todo.md` Step 5A) — these are the only two places currently constructing a payload known to exceed 128KB; other `--argjson` callers pass small scalars/objects and would be unaffected by either fix shape.

## Risks & Mitigations

- **Risk**: fixing only the argv-size crash (requirement 1) without addressing atomicity (requirement 2) would leave the "half-annotated ROADMAP.md" failure mode intact for any *other* future mid-loop failure, even though the specific historical incident (E2BIG at the final `jq -n`) would no longer reproduce. **Mitigation**: scope the plan to cover both explicitly; the acceptance criteria in the task description already requires the "forced mid-run failure" test, which only passes once the staging-copy design is implemented.
- **Risk**: the transparent auto-spill design for state-write.sh (Shape 2 above) mutates the caller-supplied `$JQ_FILTER` string (prefixing a `... as $NAME |` binding) — a filter that itself starts with something order-sensitive (e.g. relies on `.` referring to top-level input before any `as` binding) should still work, since `X as $Y | <original filter>` doesn't change what `.` refers to inside `<original filter>`, but this should be covered by a positive test (spilled value used both as a scalar binding and inside `select()`/array-construction contexts) rather than assumed correct.
- **Risk**: requirement 3's data-flow change (passing active/non-terminal task numbers into the python matching step) touches the same script section already carrying two other planned changes (argv fix, atomicity fix) — sequencing these as separate phases in the plan, in the order argv-fix -> atomicity -> heuristic tightening, reduces the chance of one change's diff obscuring another's during review.
- **Risk**: `commands/todo.md` and `skill-todo/SKILL.md` currently show byte-identical `--argjson tasks` call shapes for the archival batch; a fix that updates only one of the two documents would leave them inconsistent. **Mitigation**: explicitly flagged above as "must be updated in tandem."

## Context Extension Recommendations

None — this is a tooling/meta task with no gap in existing `.claude/context/` documentation; the relevant convention (`--slurpfile` for large jq payloads) is already discoverable by grepping the scripts directory, which is how it was found here.

## Appendix

**Files read in full**: `agent-system/extensions/core/scripts/roadmap-integration.sh` (818 lines), `agent-system/extensions/core/scripts/state-write.sh` (388 lines).

**Files grepped/partially read**: `skill-todo/SKILL.md` (Stage 10 archival section), `commands/todo.md` (Step 5A/5E), `commands/review.md` (roadmap-integration.sh consumer section), `orchestrate-batch-admit.sh`, `reconcile-task-status.sh`, `reconcile-artifacts.sh`, `manage-topics.sh`, `system-defect-record.sh`, `install-extension.sh`, `test-state-write-concurrency.sh`, `tests/test-roadmap-items-producer.sh`.

**Live reproductions performed** (both non-destructive):
```
bash .claude/scripts/roadmap-integration.sh --roadmap specs/ROADMAP.md --state specs/state.json
# -> exit 126, "jq: Argument list too long", line 788

bash .claude/scripts/state-write.sh '.' --session-id "test_sess_repro" --argjson stuff "$big_json" --dry-run
# -> exit 126, "Argument list too long" (with a 160,002-byte synthetic payload)
```

**Source store location** (not `agent-system/` under this repo — it does not exist here; confirmed via `.claude-extensions.json`'s `source_dir` fields): `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/`. This is a separate git-tracked location shared across projects; `.claude/scripts/` in this repo is its deployed, gitignored copy and was confirmed byte-identical to the source store for both files at research time.

**Existing test-file conventions to follow for the required regression tests**:
- `state-write.sh`: top-level `scripts/test-state-write-*.sh` isolated-temp-root suites (e.g. `test-state-write-concurrency.sh` — copies the script under test byte-for-byte into a throwaway `$TMPROOT`, never touches the real `specs/` tree, `pass()`/`fail()` counters, exits 0/1 on suite result). A new case (or new file following the same pattern) exercising a >128KB `--argjson` payload fits this convention directly.
- `roadmap-integration.sh`: `scripts/tests/test-roadmap-items-producer.sh` is the closest existing end-to-end fixture suite (builds a fixture repo, drives the real matching/annotation chain) but targets the `roadmap_items` producer path specifically, not the argv-size crash. A new oversized-payload case would need enough fixture phases/table rows to push `ROADMAP_STATE`/`ROADMAP_MATCHES` past 128KB — plausible by generating many synthetic phases/checkboxes in the fixture `ROADMAP.md`, mirroring how the live repo naturally reached ~497KB with only 24 matches (each match/table-row averaging ~20KB due to embedded `raw_line`/full-column data).
