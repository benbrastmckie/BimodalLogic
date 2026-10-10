# Research Report: Task #754

**Task**: 754 - Make the plan-postflight file_scope widening observable instead of silent
**Started**: 2026-10-10T00:00:00Z
**Completed**: 2026-10-10T00:00:00Z
**Effort**: small (single-file notice addition, no semantic change)
**Dependencies**: None
**Sources/Inputs**: Codebase (`.claude/scripts/update-task-status.sh`, `.claude/scripts/skill-base.sh`, `.claude/scripts/orchestrator-postflight.sh`, `.claude/scripts/plan-file-scope-harvest.sh`), `specs/TODO.md` (sibling records 731, 751), deploy verification (`deploy-headless.sh`)
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The harvest-and-widen mechanism the originating change request asked for already exists and
  already works: `plan-file-scope-harvest.sh` unions every phase's `Files to modify` list, and
  `update-task-status.sh`'s jq clause additively union-merges it into `file_scope`
  (`(.file_scope) |= ((. // []) + $add | unique)`). No change to this grammar or semantics is in
  scope.
- The actual defect is narrow: the union-merge produces **no runtime output at all** on the real
  (non-`--dry-run`) write path — not in the no-op branch, not in the main `PHASE 3` write. Only
  `--dry-run` echoes it (`"[dry-run] state.json: file_scope union-merge -> add ..."`).
- There is exactly **one** live call site that reaches this merge: `skill_postflight_update` in
  `.claude/scripts/skill-base.sh`, invoked from `orchestrate-stage5-postflight.sh` and
  `orchestrate-cycle-postflight.sh`. `orchestrator-postflight.sh`'s own Stage 7 branch (which
  also forwards `--file-scope-add`) has no live caller — confirmed by its own header comment
  ("historical; this script has no current caller").
- Recommended fix is option (a) from the dispatch: emit a single non-blocking notice from
  `update-task-status.sh` itself, gated on the actual post-merge delta (not the raw forwarded
  list), at the two places inside `update_state_json()` where the file_scope merge can fire: the
  no-op branch (~line 1007) and the shared real-write branch that closes the function (~line
  1156). This covers the one live caller (and any future caller) from a single choke point,
  matches the existing `[phase-check]`/`[deploy-check]` bracket-tag notice convention already
  used in this file, and requires no change to `skill-base.sh` or `orchestrator-postflight.sh`.

## Context & Scope

The originating change request asked for a reconciliation step comparing a plan's `Files to
modify` field against the task's declared `file_scope` at plan postflight, with divergence
either harvested or surfaced. That reconciliation already runs today via
`plan-file-scope-harvest.sh` + the additive union-merge in `update-task-status.sh`. This research
re-derives that claim from the code (not merely trusts the dispatch's framing) and then narrows
to the actual residue: the merge is real but **silent** on every live path, which this task is
scoped to fix by adding observability only — no grammar change, no semantics change, no new gate,
no blocking behavior.

Out of scope, per the dispatch's explicit non-goals and confirmed against `specs/TODO.md`:
- Task 731 ("Harvest generated surfaces into file scope") — owns `plan-file-scope-harvest.sh`
  and the `.lean`-forced derived generated surfaces (README inventory blocks, `status.typ`).
- Task 751 ("File scope declaration hygiene remediation") — owns coarse/absent `file_scope`
  declarations feeding the same admission gate (`validate-state.sh` Checks 8/9).

Both are confirmed present in `specs/TODO.md` as distinct, non-overlapping records with no
file-territory intersection with this one (neither touches `update-task-status.sh` or
`skill-base.sh`). No dependency edge is warranted, matching the dispatch's framing.

## Findings

### Codebase Patterns

**The merge itself (confirmed in `.claude/scripts/update-task-status.sh`)**:
- `FILE_SCOPE_ADD_LEN` is computed once (`jq 'length'` on the validated `--file-scope-add` JSON
  array) and used as the sole gate for every file_scope-related branch — a genuinely empty/absent
  flag is a byte-for-byte no-op.
- The merge fires in exactly two places inside `update_state_json()`:
  1. The no-op branch (`state_is_noop == true`, ~line 1003-1016): a dedicated
     `state-write.sh` call whose jq filter is `(.file_scope) |= ((. // []) + $add | unique)`.
  2. The main write branch (~line 1106-1112): the SAME jq clause is appended to the shared
     status-write filter, riding inside the one `state-write.sh` call that closes
     `update_state_json()` at line ~1156-1159.
- In BOTH cases, the only existing output is the `--dry-run` echo at line 976-978
  (`"[dry-run] state.json: file_scope union-merge -> add ${FILE_SCOPE_ADD}"`), which never
  executes on a real write (the dry-run branch returns 0 before either of the two real-write
  branches is reached).

**The one live call site (confirmed by cross-reference)**:
- `skill_postflight_update()` in `.claude/scripts/skill-base.sh` (~line 921-1023) is the
  function that forwards `--file-scope-add` to `update-task-status.sh` on a real postflight. Its
  own header comment states explicitly: *"this function is the OTHER, actually-live
  plan-postflight path — `orchestrator-postflight.sh` itself has no live callers; see its own
  header note — so both must carry the harvest, not only the orphaned one."*
- `orchestrator-postflight.sh`'s Stage 7 branch (line 325) carries the identical header note:
  *"implement did this inline in the now-deleted base lifecycle implement skill before calling
  this script (historical; this script has no current caller — see the header comment)"*. This
  independently confirms the dispatch's framing that option (b) (duplicating the notice at the
  two call sites) is the wrong altitude — one of the two "sites" has no live caller at all.
- `skill_postflight_update` is called, in turn, from `orchestrate-stage5-postflight.sh` (lines
  145/148/161) and `orchestrate-cycle-postflight.sh` (lines 1168/1197/1264/1352/1403) — i.e.
  every live orchestration path funnels through the single function, which funnels through the
  single `update-task-status.sh` choke point. A notice placed inside `update-task-status.sh`
  therefore covers every present and future caller without duplication.

**Existing notice-style convention in this same file** (precedent for phrasing/placement):
- `[phase-check]` notices (lines 767-776): non-blocking, informational, `>&2`, prefixed with a
  bracketed tag naming the subsystem, e.g. `"[phase-check] Task $task_number: ... -- proceeding."`
- `[deploy-check]` notices (lines 848-951): same bracket-tag pattern, same `>&2` destination,
  same "inconclusive, passing through" / "proceeding" phrasing for the non-blocking case.
- A natural analogous tag for this fix is `[file-scope]`, keeping the same bracket-tag,
  stderr-only, non-blocking convention already established twice in this file.

**Delta computation (the "actually added" requirement)**:
- The dispatch is explicit that a notice must report the **post-merge delta**, not the raw
  forwarded `--file-scope-add` list, because `unique` means most forwarded paths are usually
  already present (re-running the harvester on an already-widened task reproduces paths that are
  already in `file_scope`). Printing the raw input every time would fire on every postflight
  regardless of whether anything actually changed — exactly the "cry wolf" failure mode the
  dispatch warns against.
- The delta is computable with the state already in hand at the point of either merge: read the
  task's current (pre-merge) `file_scope` array from `$STATE_FILE` (a single `jq` query keyed by
  `task_number`, the same lookup pattern `DEPENDS_ON_ADD`'s own dry-run branch already uses at
  line ~987-991 to preview its resulting array), then compute `($add - $old | length)` — jq's
  array-difference operator applied to the forwarded list against the current list gives exactly
  the count of genuinely new paths, independent of `unique`-driven duplicates within `$add`
  itself.
- This read-before-write approach is safe because the merge is purely additive (`unique`, never
  overwrite) and the state-write happens inside `state-write.sh`'s own mutex — the pre-write read
  and the post-write notice bracket a single critical section with no intervening writer that
  could invalidate the delta between the two.

### External Resources

Not applicable — this is a self-contained shell/jq change to existing project scripts with no
external API, library, or documentation dependency.

## Decisions

- **Confirmed**: the harvest-and-widen mechanism (grammar + additive union-merge semantics)
  works correctly today and is explicitly out of scope for this task. No code in
  `plan-file-scope-harvest.sh` or the jq merge clause itself should change.
- **Confirmed**: there is exactly one live call site reaching the merge
  (`skill_postflight_update` in `skill-base.sh`), not two. `orchestrator-postflight.sh`'s
  parallel Stage 7 branch is dead code with no current caller.
- **Decision**: implement the dispatch's option (a) — a single notice inside
  `update-task-status.sh`'s `update_state_json()`, placed at both points where the file_scope
  merge can fire (the no-op branch and the shared real-write branch), gated on
  `FILE_SCOPE_ADD_LEN > 0` AND a non-zero post-merge delta. This is the smallest fix, covers
  every caller (present and future) from one choke point, and matches an existing in-file notice
  convention (`[phase-check]`, `[deploy-check]` bracket tags).
- **Decision against option (b)**: duplicating the notice at the two forwarding call sites is
  the wrong altitude — it duplicates a message that belongs to the writer, and one of the two
  sites (`orchestrator-postflight.sh`) has no live caller to exercise it.
- **Decision against option (c)**: a durable per-task record of what plan postflight added is
  heavier than justified here — no consumer for such a record currently exists, and the dispatch
  itself requires justifying (c) against (a) before choosing it. A stderr notice fully satisfies
  the stated consequences (operator visibility, replacing the originating task's hand-written
  issue-log entry, and tracing admission-gate territory growth) without adding durable state.
- **Phrasing decision**: use a `[file-scope]` bracket tag, `>&2`, reporting the task number and
  the delta count (and, space permitting, the actual new paths) — e.g. `"[file-scope] Task
  $task_number: file_scope widened by N path(s) via --file-scope-add."` — firing only when the
  delta is non-zero, never on a pure-duplicate forward.

## Recommendations

1. In `update-task-status.sh`'s `update_state_json()`, immediately before each of the two
   `state-write.sh` invocations that can carry the file_scope merge (the no-op branch's
   dedicated call, and the shared real-write call that closes the function), read the task's
   current `file_scope` array from `$STATE_FILE` and compute the delta count via jq array
   difference against `$FILE_SCOPE_ADD`.
2. After each of those two `state-write.sh` calls succeeds, if `FILE_SCOPE_ADD_LEN -gt 0` AND the
   computed delta is non-zero, print one `[file-scope]` notice to stderr naming the task number
   and the delta count (optionally the new paths themselves, since the count alone satisfies the
   "named count" requirement but the paths add no meaningful cost).
3. Do not touch `plan-file-scope-harvest.sh`, the jq merge filter's semantics, `skill-base.sh`'s
   `skill_postflight_update`, or `orchestrator-postflight.sh`'s Stage 7 branch — the fix is
   entirely contained to the two notice insertion points inside `update-task-status.sh`.
4. Add or extend a test in `.claude/scripts/tests/test-skill-base-lifecycle.sh` (which already
   exercises the plan-branch file_scope harvest at "Group 4a") to assert the new notice appears
   on stderr when a genuinely new path is merged, and does NOT appear when a re-run forwards only
   already-present paths (the cry-wolf case the dispatch warns against).
5. Edit at the source store, not the deployed tree: `source_dir` for the `core` extension
   resolves to `/home/benjamin/.config/nvim/agent-system/extensions/core` (confirmed via
   `.claude-extensions.json`); the deployed paths
   (`.claude/scripts/update-task-status.sh`, `.claude/scripts/tests/test-skill-base-lifecycle.sh`)
   are the mirror targets there. The deployed tree in this repository was redeployed and verified
   `RESULT=landed_verify_clean` during this research pass, so the current deployed copy may be
   reasoned about going forward, but the actual edit must still land in the source store.

## Risks & Mitigations

- **Risk**: a naive implementation prints the notice unconditionally whenever
  `FILE_SCOPE_ADD_LEN > 0`, regardless of whether the merge actually changed anything — exactly
  the cry-wolf failure the dispatch calls out as "worse than silence." **Mitigation**: gate the
  notice on the computed delta (`$add - $old | length > 0`), not on `FILE_SCOPE_ADD_LEN` alone.
- **Risk**: computing the delta via a separate pre-write `jq` read on `$STATE_FILE` introduces a
  TOCTOU window if another writer could mutate `file_scope` between the read and the
  `state-write.sh` call. **Mitigation**: the actual mutation is confined to `state-write.sh`'s
  own mutex-guarded critical section, and the merge is additive-only (`unique`), so even a stale
  pre-read delta is, at worst, an undercount (if a concurrent widen already added some of the
  same paths) — it can never report a false "nothing changed," and a false positive from mild
  staleness is cosmetic, not a correctness hazard for `file_scope` itself.
- **Risk**: adding a notice to the shared real-write branch at the end of `update_state_json()`
  could be miswired to also fire for the mutually-exclusive `research_questions` /
  `hold`/`unhold` / `depends-on-add` clauses that share the same `state-write.sh` call. 
  **Mitigation**: gate strictly on `FILE_SCOPE_ADD_LEN -gt 0`, which the file's own flag
  validation already guarantees is mutually exclusive with `RESEARCH_QUESTIONS_LEN` on any given
  invocation (per the existing header comments at lines ~1116-1118 and ~1046).
- **Risk**: exit-code or stdout pollution could be mistaken for a blocking signal by a caller
  parsing `update-task-status.sh`'s output. **Mitigation**: write to stderr only (matching
  `[phase-check]`/`[deploy-check]` precedent), and do not alter the function's return value.

## Context Extension Recommendations

None — this is a `meta` task touching existing scripts and their own test suite; no new
project-overview or context-file coverage gap was identified during this research.

## Appendix

- Search queries / commands used: `grep -n "file_scope\|FILE_SCOPE_ADD\|file-scope-add"
  .claude/scripts/update-task-status.sh`; `grep -n "file-scope-add\|file_scope" .claude/scripts/skill-base.sh`;
  `grep -n "file-scope-add\|file_scope\|Stage 7" .claude/scripts/orchestrator-postflight.sh`;
  `grep -rn "skill_postflight_update" .claude/skills .claude/scripts`; `bash
  .claude/scripts/deploy-headless.sh`; `grep -n "### 731\.\|### 751\." specs/TODO.md`.
- Key line references (deployed tree, post-redeploy):
  `.claude/scripts/update-task-status.sh:969-1160` (`update_state_json`), `:976-978` (existing
  dry-run echo), `:1003-1016` (no-op merge branch), `:1106-1112` (real-write merge clause),
  `:1156-1159` (shared `state-write.sh` call closing the function); `.claude/scripts/skill-base.sh:921-1023`
  (`skill_postflight_update`, the one live forwarding call site); `.claude/scripts/orchestrator-postflight.sh:323-351`
  (Stage 7 branch, confirmed dead/no-caller).
- Deploy verification: `bash .claude/scripts/deploy-headless.sh` run during this research pass
  returned `[deploy-headless] RESULT=landed_verify_clean`, confirming the deployed `.claude/` tree
  for the `core` extension is current before and after the code reading above.
