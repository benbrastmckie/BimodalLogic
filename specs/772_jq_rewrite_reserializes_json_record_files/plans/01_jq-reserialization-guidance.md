# Implementation Plan: Task #772

- **Task**: 772 - jq rewrite reserializes JSON record files
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/772_jq_rewrite_reserializes_json_record_files/reports/01_jq-rewrite-reserialization-guidance.md
- **Artifacts**: plans/01_jq-reserialization-guidance.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add agent-system guidance documenting that a whole-file pipe through `jq` unconditionally
re-serializes every record's layout — including records a narrowly-scoped filter never touches —
and give a copyable, assertion-backed alternative for editing a formatting-sensitive JSON record
file. Research settled the siting question: extend the existing jq-pitfalls hub
(`context/patterns/jq-escaping-workarounds.md`) rather than create a sibling file, widen that
file's own opening framing so a second, unrelated hazard inside it is not a surprise, add one
pointer line to the merged `CLAUDE.md` "jq Command Safety" section, and bring the file's
`index-entries.json` entry back into agreement. All edits land in the `core` extension source
store at `/home/benjamin/.config/nvim/agent-system/extensions/core`; the deliverable is complete
only after a redeploy reports `RESULT=landed_verify_clean`.

### Research Integration

The research report fixed every open decision so this plan places text rather than re-derives
it. Carried forward as settled:

- **Siting is candidate (a)**, extending `context/patterns/jq-escaping-workarounds.md`. Measured
  grounds: that file has 27 referrers across 8 extensions and is named as "Full documentation" by
  the merged `CLAUDE.md` jq section. Candidate (b) — a new sibling pattern file — is rejected:
  zero day-one referrers plus referrer-wiring work this same change would then have to carry.
- **Both audiences are reached by this one siting.** The plan-author audience is reached through
  the merged `CLAUDE.md` jq section, which is auto-injected into every agent session's system
  context including plan-authoring dispatches (confirmed empirically during research — the
  injection is visible in this task's own dispatch context). The implementer audience is reached
  through any of the 27 existing referrers, which land a reader in the file where the widened
  framing makes the second section impossible to miss. Neither path requires the reader to know
  the term "re-serialization" in advance.
- **No helper script**, re-confirmed against `scripts/state-write.sh`'s actual source: that
  wrapper closes two failure channels (a fail-closed mutex, a private staging path) specific to
  many concurrent automated writers on one hot file. Neither channel exists for a record file
  edited by a single implementer inside one planned step.
- **No edit to `planner-agent.md`** and **no dependency edge** on its account: the plan-author
  audience is already reached via the `CLAUDE.md` injection path.
- **No dependency edge for the shared `index-entries.json` declaration.** Research found a real
  `file_scope` overlap with another active record on that path and classified it as the
  coarse-registration-file case the batching guardrail's narrowness qualifier explicitly exempts
  (disjoint entries within one registration array; the `manifest.json` precedent is directly
  analogous). That record is not among this cycle's concurrent siblings, so there is no same-cycle
  collision today either.
- **Exact recipe and trigger-condition wording** are specified in the report's Recommendations
  section and are to be placed, not re-invented.

Verified independently during this planning pass rather than assumed from the report:

- All three source-store target files exist at the resolved `source_dir`
  (`/home/benjamin/.config/nvim/agent-system/extensions/core`); the pattern file is 285 lines,
  matching its `index-entries.json` `line_count` today.
- The pattern file's current section layout ends with `## State Updates` then `## References`, so
  the new section has an unambiguous insertion point.
- `suite_selection_select` returns `__FULL_SWEEP__` for all three touched paths — **no test suite
  covers them**. This is the expected result for guidance markdown plus a registration manifest,
  not a tool failure, and it fixes the honest covering check for every non-final phase below.
- The source-store repository root is `/home/benjamin/.config/nvim`, which holds `.claude/`,
  `.claude-extensions.json`, and `agent-system/extensions` simultaneously. That makes it the one
  valid `TARGET` for a `--only-gate 3,4` invocation; `/home/benjamin/Projects/BimodalLogic` has no
  `agent-system/extensions` directory, so passing it as `TARGET` would make both gates silently
  SKIP and attest to nothing.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided to this dispatch and no roadmap phases are requested.

## Goals & Non-Goals

**Goals**:

- Document jq's unconditional whole-file re-serialization as a named failure class a reader can
  recognize before acting, with a checkable trigger condition and at least one concrete file
  shape that meets it.
- Provide the proven alternative as runnable, copyable lines: HEAD bytes as the starting point,
  a text-level field edit, an independently jq-computed intended result, a canonicalized
  JSON-equality assertion, and the move-into-place step.
- State plainly that the assertion is the load-bearing half, so the guidance cannot be followed
  as a bare "edit it by hand instead".
- Reach the plan-author audience (one line in the merged `CLAUDE.md` jq section) and the
  implementer audience (the extended pattern file reached from its existing referrers) through
  this single change.
- State the `specs/state.json` / `state-write.sh` relation so no reader goes looking for an
  equivalent wrapper for record files, and name the reopen condition for the script question.
- Bring the pattern file's `index-entries.json` entry back into agreement with the extended file.
- Land the change through a redeploy reporting `RESULT=landed_verify_clean`.

**Non-Goals**:

- No helper script, wrapper, or formatting-preserving JSON editor. Settled at filing time,
  re-confirmed by research; not reopened here.
- No re-edit of the originating record file. It was repaired in the originating run and is
  correct as it stands.
- No new sibling pattern file, and therefore no referrer-wiring or new `index-entries.json`
  entry creation.
- No edit to `agents/planner-agent.md` (claimed by another record; unnecessary on the merits).
- No generalization into "jq is unsafe for JSON edits". jq stays correct for `specs/state.json`
  through its wrapper, for computing the intended value inside the recipe, and for any file whose
  byte layout nobody depends on.
- No hand edit under `.claude/**`. That tree is a regenerated deploy artifact; the declared
  `.claude/**` path exists only so the admission overlap gate can see the collision surface.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Widened framing reads as narrating the file's own draft history, tripping the no-record-versioning rule | M | M | State the current two-part structure plainly ("this file documents two independent jq hazards: ... and ..."). No "originally", "previously", "now also covers", or "no longer" phrasing. Structural description only. |
| Guidance prose cites the originating task number or the issue entry_id | M | L | Those live in this record only. Cite durable anchors instead: the record file's path, the tool name, the field names, `state-write.sh`. Gate 4 (task-reference lint) in the covering check catches a slip. |
| An edit is hand-authored under `.claude/**` and silently wiped by the next deploy | H | L | Every edit targets the resolved `source_dir`. Phase 4's redeploy is the only thing that writes `.claude/**`. |
| `index-entries.json` edited by a whole-file jq rewrite, reproducing this record's own failure class inside the fix | M | M | It is a 98 KB hand-maintained registration array. Edit it as a text-level replacement of the three field values and assert `diff <(jq -S . before-with-intended-change) <(jq -S . after)` is empty, i.e. apply this record's own recipe. |
| Phase 4's whole-tree regeneration overwrites a concurrent sibling's in-flight deployed-tree state | M | M | The deploy regenerates the entire `.claude/` tree, so the phase declares `__WHOLE_TREE__`. Before deploying, check `git status --short -- .claude/` for foreign uncommitted modifications; if any are found, STOP and report rather than deploying over them. |
| The redeploy also lands other extensions' pending source changes (the tree is stale for `core formal lean literature memory typst`) | L | H | Expected, not a regression of this change. Verify `RESULT=landed_verify_clean` and note in the phase record that unrelated extensions were brought current by the same run. |
| `line_count` recorded before the file is final, leaving the index entry stale again | M | M | Phase 3 depends on Phase 1 and recomputes `line_count` with `wc -l` against the finished file rather than estimating it. |
| A `--only-gate 3,4` invocation is pointed at a `TARGET` lacking `agent-system/extensions`, making both gates SKIP and attest to nothing | M | M | `TARGET` is `/home/benjamin/.config/nvim` (verified to hold `.claude/`, `.claude-extensions.json`, and `agent-system/extensions`). Never `<source_dir>` itself, never the bare no-argument form from this repository. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

Throughout: concurrent siblings are dispatched this same cycle on this shared working tree
(see the dispatch file's Territory block). Re-read every file immediately before editing it,
stage only this record's own hunks with an explicit file list, never a directory or glob add,
and never run `git-snapshot.sh` in its reverting default mode.

---

### Phase 1: Widen the file's framing and add the re-serialization section [NOT STARTED]

**Goal**: The pattern file documents the whole-file re-serialization failure class with a
checkable trigger condition, the copyable assertion-backed recipe, the `state-write.sh` relation,
the reopen condition, and the explicit non-generalization — and its own opening framing names
both hazards it carries so the second section is not a surprise.

**Tasks**:

- [ ] Re-read `context/patterns/jq-escaping-workarounds.md` at the source store immediately
      before editing (a sibling may have touched the tree).
- [ ] Replace the single-sentence intro at line 3 with a structural statement naming both hazards
      the file documents: the Bash-tool escaping bug (Issue #1132) and jq's unconditional
      whole-file re-serialization. Structural phrasing only — no history narration.
- [ ] Add a new `##`-level section, inserted after `## State Updates` and before
      `## References`, with a heading that names the hazard in plain terms (e.g. "jq Rewrites
      Reflow Unrelated JSON Formatting") so a reader scrolling the file lands on it without
      knowing the term "re-serialization".
- [ ] In that section, state the **trigger condition** as two conditions a reader can check
      before acting: (i) the file is committed with a layout a bare `jq . file` round-trip would
      not byte-reproduce — hand-maintained per-record compaction, a deliberately preserved key
      order, mixed compact-and-expanded records — AND (ii) the edit is meant to touch a few
      fields rather than intentionally rewrite the file.
- [ ] Name at least one concrete file shape meeting the trigger: a dependency/record array where
      most entries are serialized compactly on one line while one or more have been hand-expanded
      for readability.
- [ ] State **why it bites**: jq parses its input to a value and prints that value back in jq's
      own fixed style; there is no flag that preserves input formatting, so a whole-file pipe
      reflows every record's layout whether or not the filter touches that record.
- [ ] Place the **five-step recipe** as a copyable fenced `bash` block: (1) `git show HEAD:"$path"`
      for the starting bytes; (2) the text-level field edit against a copy of those bytes;
      (3) the independently jq-computed intended result from the *same* starting bytes;
      (4) `diff <(jq -S . text-edited) <(jq -S . jq-output)`, which must be empty; (5) move the
      text-edited file into place only once step 4 is empty.
- [ ] State explicitly that **step 4 is the load-bearing half** — it buys back the guarantee a
      bare text edit gives up, namely that the result is well-formed JSON carrying exactly the
      intended values. Say that guidance omitting it is guidance to make the same class of
      mistake with a text editor instead of jq.
- [ ] State the **`state-write.sh` relation**: `specs/state.json` has a dedicated mutex-guarded
      writer built for a different problem (many concurrent automated callers on one hot file),
      jq remains the correct unchanged tool for every call routed through it, and record files
      edited by a single implementer inside one planned step have no such wrapper — deliberately,
      because a wrapper would buy no concurrency safety there.
- [ ] State the **reopen condition**: if some record file turns out to be edited often enough
      that this recipe is being retyped repeatedly, that is the signal to revisit the
      helper-script question — not before.
- [ ] State the **explicit non-generalization**: this is not "jq is unsafe for JSON edits"; jq
      stays correct for `specs/state.json` via its wrapper, for computing the intended value in
      step 3, and for any file whose byte-level layout nobody depends on.
- [ ] Add the new section to the file's `## References` list only if that list's existing shape
      calls for it; do not restructure the list.
- [ ] Re-read the finished section and confirm the prose carries no task-number reference, no
      issue entry_id, and no record-versioning phrasing.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one file is touched, with exactly two edit sites — the intro
paragraph at line 3 and one new `##` section inserted between `## State Updates` and
`## References`. Confirm by re-reading the file's heading map
(`grep -n '^#' <path>`) immediately before editing and again after, expecting one added `##`
heading and no other structural change.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this path, so no
test suite covers it; the honest covering check is the source-store gate subset
`bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`
(doc-lint and task-reference lint) run together with the single-file diff read-through this tier
prescribes.

**Files to modify**:

- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/patterns/jq-escaping-workarounds.md` - widen the opening framing to name both hazards; add the whole-file re-serialization section with trigger condition, recipe, assertion emphasis, `state-write.sh` relation, reopen condition, and non-generalization

**Verification**:

- `grep -n '^#' /home/benjamin/.config/nvim/agent-system/extensions/core/context/patterns/jq-escaping-workarounds.md`
  shows exactly one added `##` heading, positioned after `## State Updates`.
- The new section contains all five recipe steps, including the `diff <(jq -S . ...) <(jq -S . ...)`
  assertion line, inside a copyable fenced block.
- `bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`
  passes, with both gates reporting a real check rather than SKIP.
- Diff read-through confirms every changed hunk is prose/markdown with no executable surface, and
  carries no task number, no issue entry_id, and no record-versioning phrasing.

---

### Phase 2: Add the merged CLAUDE.md jq-section pointer [NOT STARTED]

**Goal**: The merged `CLAUDE.md` "jq Command Safety" section — auto-injected into every agent
session, which is what reaches the plan-author audience — names the re-serialization hazard in one
sentence and points at the new section for the trigger condition and the recipe.

**Tasks**:

- [ ] Re-read `merge-sources/claudemd.md` around its `## jq Command Safety` section at the source
      store immediately before editing.
- [ ] Add one sentence immediately after that section's existing `Full documentation:` line,
      stating that piping an entire JSON file through jq also reflows every record's formatting
      regardless of which fields the filter targets, and pointing at the new section in the same
      referenced file for the checkable trigger condition and the copyable recipe.
- [ ] Make no structural change to the section: no new heading, no reordering, no change to the
      existing escaping guidance or its code block.
- [ ] Confirm the added sentence names the new section by the heading text Phase 1 actually
      used, not a paraphrase.

**Timing**: 15 minutes

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one file, one added line, inside the existing
`## jq Command Safety` section and immediately after its `Full documentation:` line — no heading
added and no existing line altered. Confirm with `git diff -- <path>` showing a single-line
addition within that section's range.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this path, so the
honest covering check is the same source-store gate subset
`bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`,
run with the single-file diff read-through this tier prescribes.

**Files to modify**:

- `/home/benjamin/.config/nvim/agent-system/extensions/core/merge-sources/claudemd.md` - one sentence added to the existing `## jq Command Safety` section pointing at the new pattern-file section

**Verification**:

- `git diff -- agent-system/extensions/core/merge-sources/claudemd.md` (run from
  `/home/benjamin/.config/nvim`) shows exactly one added line, inside `## jq Command Safety`.
- The added sentence's section reference matches Phase 1's actual heading text verbatim.
- `bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`
  passes.

---

### Phase 3: Resync the index-entries.json entry [NOT STARTED]

**Goal**: The `patterns/jq-escaping-workarounds.md` entry in `core`'s `index-entries.json` agrees
with the extended file — accurate `line_count`, a `summary` describing both failure classes, and
`keywords` an implementer searching for this hazard would actually hit.

**Tasks**:

- [ ] Recompute the file's line count with
      `wc -l < /home/benjamin/.config/nvim/agent-system/extensions/core/context/patterns/jq-escaping-workarounds.md`
      against the finished Phase 1 output; do not estimate it.
- [ ] Re-read the entry block at `index-entries.json` immediately before editing (another record
      declares this same registration file, and a concurrently filed record adding a new context
      file would also append here).
- [ ] Update `line_count` to the measured value.
- [ ] Widen `summary` so it describes both hazards the file documents rather than only the
      escaping bug.
- [ ] Widen `keywords` to include terms an implementer would search by for this failure class
      (e.g. `reserialization`, `record-files`, `formatting`) alongside the existing `patterns`,
      `jq`, `escaping`.
- [ ] Leave `domain`, `subdomain`, `topics`, and `load_when` untouched, and add no new entry.
- [ ] Apply this record's own recipe rather than a whole-file jq rewrite: edit the three field
      values as a text-level replacement, then assert the result agrees as JSON with the
      jq-computed intended value under canonicalization
      (`diff <(jq -S . ...) <(jq -S . ...)` must be empty). This registration file is exactly the
      hand-maintained shape the new guidance describes.
- [ ] Confirm the file still parses (`jq empty <path>`) and that no entry other than this one
      changed.

**Timing**: 20 minutes

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one file and exactly one entry within it — the
`patterns/jq-escaping-workarounds.md` entry — with exactly three changed fields (`line_count`,
`summary`, `keywords`). Confirm with
`diff <(git show HEAD:agent-system/extensions/core/index-entries.json | jq -S '.entries | map(select(.path != "patterns/jq-escaping-workarounds.md"))') <(jq -S '.entries | map(select(.path != "patterns/jq-escaping-workarounds.md"))' agent-system/extensions/core/index-entries.json)`
being empty, i.e. every other entry byte-identical as JSON.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this path, so the
honest covering check is `jq empty` plus the all-other-entries-unchanged canonicalized diff above,
run together with the same source-store gate subset
`bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`.

**Files to modify**:

- `/home/benjamin/.config/nvim/agent-system/extensions/core/index-entries.json` - the `patterns/jq-escaping-workarounds.md` entry's `line_count`, `summary`, and `keywords`

**Verification**:

- `jq empty /home/benjamin/.config/nvim/agent-system/extensions/core/index-entries.json` exits 0.
- The entry's `line_count` equals `wc -l` on the finished pattern file.
- `keywords` includes the widened terms; `summary` names both failure classes.
- The all-other-entries canonicalized diff from the Scope Hypothesis is empty.
- `bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`
  passes.

---

### Phase 4: Redeploy, verify, and walk the acceptance criteria [NOT STARTED]

**Goal**: The source-store edits are landed in this repository's deployed `.claude/` tree with
`RESULT=landed_verify_clean`, the complete gate set is green, and every acceptance criterion is
checked against the deployed artifact rather than asserted.

**Tasks**:

- [ ] Before deploying, run `git status --short -- .claude/` in this repository and check for
      foreign uncommitted modifications. If any are found, confirm against `git log` that they
      are not this record's own work, then STOP and report rather than regenerating over a
      sibling's in-flight state.
- [ ] Run the redeploy with a bounded wait:
      `timeout 540 bash .claude/scripts/deploy-headless.sh` (Bash tool `timeout` parameter raised
      to 600000, not its 120000 ms default), per the external-process-wait Rule 1 idiom.
- [ ] Confirm the run reports `RESULT=landed_verify_clean`. Anything else is a failure of this
      phase, not a warning to note and move past.
- [ ] Note in the phase record that the same run also brought other stale extensions current
      (`core formal lean literature memory typst` were stale at dispatch time) — expected, and
      not a regression introduced by this change.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Confirm green.
- [ ] Acceptance criterion 1: confirm a reader arriving from the deployed `.claude/CLAUDE.md` jq
      section, or from any existing referrer of the deployed
      `.claude/context/patterns/jq-escaping-workarounds.md`, reaches the new section without
      knowing the term "re-serialization" in advance — check that the deployed `CLAUDE.md` jq
      section carries the added sentence and that the deployed pattern file's opening framing
      names both hazards.
- [ ] Acceptance criterion 2: confirm the deployed section carries the copyable recipe
      *including* the canonicalized JSON-equality assertion, not merely a prohibition.
- [ ] Acceptance criterion 3: confirm the deployed section states a checkable trigger condition
      and names at least one concrete file shape meeting it.
- [ ] Acceptance criterion 4: confirm the deployed section states the `state-write.sh` relation
      and does not imply a wrapper exists for record files.
- [ ] Acceptance criterion 5: confirm the extended file's `index-entries.json` entry
      (`line_count`, `keywords`, and the `summary` hygiene addition) agrees with the file. No new
      file was created, so the new-file half of this criterion does not apply.
- [ ] Confirm the deployed prose carries no task-number reference and no record-versioning
      phrasing (the task-reference lint runs inside the gate set; read the diff as well).
- [ ] Commit with an explicit file list scoped to this record's own hunks.

**Timing**: 30 minutes

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The two named deployed files are the only ones this change's content should
alter, but the redeploy's actual write set is whatever the deploy writes — it will also refresh
other extensions stale at dispatch time. Confirm the real set from the deploy output and
`git status --short` rather than assuming this list is exhaustive; treat a deployed-tree change
outside `core`'s own files as an expected consequence of the staleness noted above, not as this
change's footprint.

**Files to modify**:

- `__WHOLE_TREE__` - the redeploy regenerates this repository's entire deployed `.claude/` tree, which is an implicit scope claim over that whole tree
- `.claude/context/patterns/jq-escaping-workarounds.md` - regenerated from the source store (not hand-edited)
- `.claude/CLAUDE.md` - regenerated from the merge sources (not hand-edited)

**Verification**:

- `timeout 540 bash .claude/scripts/deploy-headless.sh` reports `RESULT=landed_verify_clean`.
- `bash .claude/scripts/verify-deploy.sh` — the complete gate set this tier requires, not a
  hand-picked subset — passes green.
- All five content acceptance criteria are checked against the deployed files as listed above.
- `git status --short` shows no unexpected modifications outside this record's declared scope and
  the regenerated deploy artifact.

---

## Testing & Validation

- [ ] `bash /home/benjamin/.config/nvim/.claude/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`
      passes after each source-store phase, with both gates reporting a real check rather than SKIP.
- [ ] `jq empty` on the edited `index-entries.json` exits 0, and every entry other than the one
      intended entry is byte-identical as canonicalized JSON.
- [ ] The pattern file's `index-entries.json` `line_count` equals the measured `wc -l` of the
      finished file.
- [ ] `timeout 540 bash .claude/scripts/deploy-headless.sh` reports `RESULT=landed_verify_clean`.
- [ ] `bash .claude/scripts/verify-deploy.sh` passes green.
- [ ] Deployed prose carries no task-number reference, no issue entry_id, and no
      record-versioning phrasing.
- [ ] The new section's recipe is copyable verbatim and includes the
      `diff <(jq -S . ...) <(jq -S . ...)` assertion step.

## Artifacts & Outputs

- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/patterns/jq-escaping-workarounds.md`
  — widened opening framing plus the new whole-file re-serialization section.
- `/home/benjamin/.config/nvim/agent-system/extensions/core/merge-sources/claudemd.md`
  — one sentence added to the existing `## jq Command Safety` section.
- `/home/benjamin/.config/nvim/agent-system/extensions/core/index-entries.json`
  — the pattern file's entry resynced (`line_count`, `summary`, `keywords`).
- This repository's regenerated `.claude/` tree, including
  `.claude/context/patterns/jq-escaping-workarounds.md` and `.claude/CLAUDE.md`.
- `specs/772_jq_rewrite_reserializes_json_record_files/summaries/01_jq-reserialization-guidance-summary.md`
  at completion.

## Rollback/Contingency

All three source-store edits are additive prose or single-field value changes in one git
repository (`/home/benjamin/.config/nvim`), so the ordinary contingency is to revert the
individual hunks there with a targeted, per-file edit and redeploy — fix forward, not a tree
rollback. No repository work product depends on this change, so a partial landing is inert rather
than breaking.

If a genuine working-tree rollback becomes necessary, follow
`context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
including its out-of-scope override flag for the deliberate whole-tree case. Do not emit a bare
reverting `git-snapshot.sh` as a routine precaution; an ordinary defensive checkpoint before
risky work uses `--no-revert`.

If the Phase 4 redeploy reports anything other than `RESULT=landed_verify_clean`, do not
hand-patch any file under `.claude/**` to make the tree look right — that masks the divergence.
Diagnose from the deploy output, correct the source store, and redeploy.
