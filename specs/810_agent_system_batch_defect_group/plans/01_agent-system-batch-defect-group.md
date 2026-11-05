# Implementation Plan: Task #810

- **Task**: 810 - agent_system_batch_defect_group
- **Status**: [IMPLEMENTING]
- **Effort**: 8.5 hours
- **Dependencies**: None (task 768, previously flagged as a `file_scope` collision on
  `lean-challenge-snapshot.sh`, has already fully landed — see Research Integration)
- **Research Inputs**: specs/810_agent_system_batch_defect_group/reports/01_agent-system-batch-defect-group.md
- **Artifacts**: plans/01_agent-system-batch-defect-group.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Five independent agent-system defects, all fixed in the resolved **source store** — never under
this repository's `.claude/**`, which `rules/source-store-deploy-boundary.md` defines as a
gitignored, disposable deploy artifact. The source store resolves from
`<project-root>/.claude-extensions.json`'s `source_dir` fields; its reading at plan time is
`/home/benjamin/.config/nvim/agent-system/extensions/<ext>`, and that resolution MUST be
re-derived at implementation time rather than trusted from this note. Every `Files to modify`
path below is written in the repository-relative `agent-system/extensions/...` form this task's
existing `file_scope` already uses; it maps onto the resolved source store one-for-one.

The five defects touch three extensions (`core`, `lean`, `literature`) and four largely disjoint
code regions, so four of the seven phases are independent (Wave 1). Definition of done: each
defect's fix is in the source store with the evidence its own defect admits (an extended or new
test suite for Defects 1, 2, 3, and 5; a measured `--read` for Defect 4), the Gate 16 finding no
longer blocks a batch, no `.claude/**` file was hand-authored, and staging was narrow and
explicit throughout.

### Research Integration

The research report changed three of this task's premises, and the plan below is built on the
corrected versions rather than the dispatch's authored text:

1. **Defect 2 is not a vacuous pass.** A measured `--dry-run` against a reproduction fixture
   shows the parenthesised-Goals-header bug produces a **loud `exit 71`** ("no identifiers found
   under `**Goals**:`"), because the `[ ! -s "$GOALS_FILE" ]` guard
   (`lean-challenge-snapshot.sh:909`) runs unconditionally on both the R1 and R2 routes, strictly
   before `cross_validate_identifiers` (`:914`). The dispatch's instruction to "fix the extraction
   anchor AND the guard coverage" is therefore discharged by fixing the anchor alone and
   recording that the guard needs no change because it is already airtight for this bug — the
   tension the dispatch asked research to settle is settled, not deferred.
2. **Defect 5's "free partial fix" does not exist.** `extensions/lean/manifest.json` carries no
   `routing_hard` key at all (`jq -r 'has("routing_hard")'` → `false` on both the source-store
   and deployed copies; the key was removed from every manifest by an earlier commit, not
   nulled). Gate 16 trips on `routing_agents_hard` alone. The evidence addendum's point (2) was
   produced by `jq '{routing_hard, ...}'`, which renders an *absent* key as `null` in its
   constructed output — `has()` is the correct test. No deletion step is planned.
3. **Defect 3 has no existing test suite to extend.** The spot-check is inline bash embedded in
   `lean-implementation-agent.md` prose; a recursive grep for `compliance_check` across
   `extensions/lean/scripts/tests/` returns zero hits. The Acceptance clause's "extend the
   existing suites" requirement is therefore met by **extracting** the block into a standalone,
   testable script (Phase 5) before fixing its polarity (Phase 6) — see Decisions.

The research additionally verified both substantive fixes end-to-end against scratch copies (the
widened `START_RE` on single-line and multi-line parenthetical headers; the
`sources/<doc_id>/<basename>` candidate returning real `caleiro_2013` chunk content), and
confirmed that task 768 fully landed in the source store with none of its six phases touching
`START_RE` — so the dispatch's SCHEDULING collision note is moot and this plan declares no
dependency on 768.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap flag was set; ROADMAP.md was not
consulted and is not modified.

## Goals & Non-Goals

**Goals**:
- Defect 1: the `## Batch Gate Deferral` directive's two narrowing invocations resolve through
  the deploy/source-store boundary instead of hardcoding `agent-system/...` paths that cannot
  exist in a deploy-target repository.
- Defect 2: `extract_goal_names()`'s `START_RE` matches the parenthetical Goals-header shapes
  this repository's own precedent plans use, single-line and multi-line alike.
- Defect 3: the plan-compliance spot-check lives in a standalone, tested script and reaches a
  correct verdict on a refutation-shaped plan instead of failing the task for achieving its goal.
- Defect 4: `literature-search.sh --read <chunk_id>` resolves a chunk under `sources/<doc_id>/`
  and returns content.
- Defect 5: Gate 16's `warn()`-level notice stops escalating into the batch-blocking findings
  channel, without the manifest declaration having been deleted out from under its live consumer.
- Every fix lands in the resolved source store; no `.claude/**` file is hand-authored; staging is
  narrow and explicit (never a directory or glob pathspec).

**Non-Goals**:
- The full `routing_agents_hard` → `hard_contracts` migration. Research measured its real scope
  at 19 files across four extensions (`core`, `lean`, `cslib`, `books`), and `verify-deploy.sh`'s
  own gate-16 comment block describes it as a deferred follow-on that is not yet ready to land.
  This plan's final phase surfaces it as a recommended follow-up task in the completion summary
  rather than attempting it or silently dropping it.
- Reaching Gate 16's own `pass()` branch. That branch is unreachable while `routing_agents_hard`
  remains declared and consulted, and reaching it would require either the migration above or the
  declaration deletion the dispatch explicitly forbids. See Decisions for how the Acceptance
  clause's literal "Gate 16 passes" wording is read against the addendum's own later and more
  specific "stays blocking at batch level" framing.
- Task 780's grep-**scope** widening (`plan_compliance_spotcheck_probe_scope`). Orthogonal axis;
  see Decisions for the sequencing obligation this plan records in its place.
- Fixing the colon-anchoring fragility anywhere outside the two sites this plan already touches.

## Decisions

Four design calls this plan makes, each recorded here so it is auditable against the dispatch's
own constraints:

**D1 — Defect 5 is fixed at the findings-interface layer with a severity-distinguishing prefix,
not by deleting the append.** The dispatch's evidence addendum offers exactly two routes and asks
that one be chosen and the reason recorded: "either the findings interface gains a severity
distinction (so WARN-level findings stop escalating to batch-blocking), or gate16 stops emitting
a finding." This plan takes the **severity distinction**, implemented as a distinct line prefix.
The findings interface is a plaintext line protocol, and its sole automated consumer filters it
with `grep '^FINDING '` (`deploy-baseline-lib.sh`'s `deploy_findings_snapshot`, line 184, reached
from `orchestrate-batch-gate.sh:112`). A `warn()` that appends a line beginning with a different
token is therefore invisible to that consumer **with zero consumer-side change**, while remaining
visible on stdout for a human reader or a future severity-aware reader. Research recommended the
cheaper "remove the append entirely"; the prefix variant is the same diff size and loses strictly
less information, which is why it is preferred here.

This is **not** the silencing the dispatch forbids, and the distinction is stated explicitly so
it can be audited: the forbidden action is deleting the **manifest declaration** to make the gate
stop noticing. Here the manifest keeps declaring `routing_agents_hard`, `gate16_run()` keeps
running and keeps emitting its `[WARN]` stderr narrative, its `CHECKS` increment, and its
`GATE_DIRTY_LIST` cache-ineligibility side effect — all unchanged. Only the escalation of a
deliberately non-blocking warning into the batch-blocking channel changes. Correspondingly, the
Acceptance clause's literal "Gate 16 passes (no extension manifest declares
routing_hard/routing_agents_hard)" is read, per the addendum's own later framing, as **"Gate 16
no longer blocks the batch"** — the concrete, twice-reproduced harm — not as a mandate to reach
the `pass()` code path, which is unreachable without the out-of-scope migration.

**D2 — Defect 3 is fixed by extracting the spot-check to a script, then giving it an explicit,
opt-in polarity declaration.** Extraction (Phase 5) is what makes the Acceptance clause's
"extend the existing suites rather than asserting the fix by inspection" satisfiable at all, and
it also gives task 780 a testable target. The polarity mechanism is an **explicit plan-level
declaration**, not a heuristic: a heuristic that guesses wrong silently inverts a verdict, which
is the very failure being fixed. The field is absent by default, so every existing plan keeps
today's must-exist behaviour unchanged. On a declared refutation polarity the predicate inverts
and the check reaches a **positively confirming** verdict — all named identifiers absent →
`compliance_check="passed"`; any one present → `"failed"` — rather than the `"skipped"` bypass
task 805 had to hand-record. Because this reuses the existing `passed`/`failed` vocabulary,
**neither consumer file needs any change**: research verified that
`skill-lean-implementation/SKILL.md` Stage 6b and `skill-lean-implementation-hard/SKILL.md`
Stage 6a read the field through an identical three-way `case` whose `"skipped"|*)` arm is a
catch-all. Those two files are consequently listed nowhere in this plan's `Files to modify`
blocks; Phase 6 verifies they still read correctly rather than editing them.

**D3 — Task 780 is reconciled by a recorded sequencing obligation, not a state.json edge.** The
sanctioned primitive for an unordered territory overlap is
`update-task-status.sh --depends-on-add=<json-array>`, but that flag is valid **only** on a call
resolving to the dependent's current status as a no-op replay (`update-task-status.sh:632-639`),
and `map_status()` has no `operation:target_status` combination that maps to `not_started` —
which is task 780's status. The edge is therefore not addable with the sanctioned primitive
today, and hand-editing `specs/state.json` is not an acceptable substitute. In its place: this
plan's Phase 5 **removes the inline bash block 780 was filed against**, so 780's fix must be
written as a diff against `lean-plan-compliance-check.sh`. Phase 7 records that fact in the
completion summary as a user-facing note. (Recorded in this task's issue log at plan time.)

**D4 — Defect 2's `$GOALS_FILE` guard is deliberately left alone.** Research proved it already
fires unconditionally ahead of cross-validation on both routes, so "fix the guard coverage too"
has nothing to fix. Phase 2 instead adds a regression test asserting the guard still fires on a
genuinely empty Goals block after the anchor is widened, which is the real risk the widening
introduces, and separately tidies `extract_r2()`'s unconditional trailing-newline write to match
`extract_r1()`'s conditional form (latent, not currently exploitable, but cheap while in the
function).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Widening `START_RE` matches an unintended label (`**Non-Goals**`, `**Goalsetting**`) | H | L | Research verified neither can match: the closing `**` must immediately follow `Goals`. Phase 2 adds explicit negative test cases for both shapes rather than relying on that reasoning alone. |
| D1's prefix change is read as "silencing the gate", which the dispatch forbids | H | M | Rationale stated in full in D1 and restated in the source comment Phase 4 writes; gate behaviour (`[WARN]` stderr, `CHECKS`, `GATE_DIRTY_LIST`, manifest declaration) all provably unchanged. Phase 4's test asserts the `[WARN]` line still appears. |
| D1 breaks a test asserting gate16 emits a `^FINDING ` line | M | L | Grepped at plan time: no test under `extensions/core/scripts/tests/` asserts gate16's finding line (only `test-verify-deploy-gate-selection.sh` mentions gate16, and only in a comment about minimal-tree skipping). Fallback if one surfaces: the research-recommended removal of the append entirely, which satisfies the addendum's other route. |
| Phase 5's extraction changes spot-check behaviour while claiming to preserve it | H | M | Phase 5 is explicitly behaviour-preserving and is verified by a characterization test written **against the pre-extraction behaviour** (including the existing colon-anchoring and no-denylist quirks) before Phase 6 changes anything. Polarity and denylist changes are confined to Phase 6. |
| Defect 3 and task 780 land out of sequence and overwrite each other | M | M | D3: the inline block 780 targets ceases to exist, forcing 780 to be rewritten against the extracted script; recorded in the completion summary. |
| Defect 4's `sources/<doc_id>/` assumption (doc_id == directory name) does not hold for some corpus entry | M | L | The candidate is **additive**: appended after the two existing candidates, so any row they already resolve is untouched. `load_fidelity_map()` in the same function already makes the same assumption. |
| This repository's deployed `.claude/` tree is stale for `core` and `lean`, so a gate run here measures the old code | M | H (already true) | Phase 7 redeploys via `deploy-headless.sh` under the bounded-wait idiom before the final gate run, and declares `` `__WHOLE_TREE__` `` accordingly. |
| An edit lands under `.claude/**` by habit and is silently wiped | H | M | Every phase's `Files to modify` names only `agent-system/extensions/...`; Phase 7 greps the staged set for a `.claude/` path as an explicit acceptance check. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 5 | -- |
| 2 | 4, 6 | 3 (Phase 4); 3 and 5 (Phase 6) |
| 3 | 7 | 1, 2, 3, 4, 5, 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Defect 4 — literature-search.sh `--read` chunk-path resolution [COMPLETED]

**Goal**: `literature-search.sh --read <chunk_id>` resolves a chunk file that lives under
`sources/<doc_id>/` and returns its content instead of `[Chunk file not found: ...]`.

**Tasks**:
- [x] Re-derive the `literature` source store from `.claude-extensions.json`'s
  `.extensions.literature.source_dir`; confirm the edit target is not under `.claude/**`.
  *(completed: resolved to /home/benjamin/.config/nvim/agent-system/extensions/literature)*
- [x] In `do_read()`'s embedded Python chunk-file resolution, append a **third** resolution
  candidate `os.path.join(db_dir, "sources", doc_id, chunk_file_basename)`, tried only after the
  two existing candidates both miss, mirroring `load_fidelity_map()`'s own `sources/<dir>/`
  derivation earlier in the same function. *(completed)*
- [x] Add a short comment naming `load_fidelity_map()` as the in-file precedent for the
  `doc_id == directory-name-under-sources/` assumption, so the two cannot drift apart silently.
  *(completed)*
- [x] Capture the measured evidence the Acceptance clause requires: run `--read` against a real
  `caleiro_2013` chunk and record that it returns paper content, not the not-found string.
  *(completed: chunk fd8fba3d5eb37a3f, pre-fix "[Chunk file not found: ...]", post-fix real content)*
- [x] Stage and commit with an explicit single-file pathspec. *(completed)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The edit is one additive fallback branch inside one function of one
file, with no signature change, and `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-lit-pipeline.sh`
is the suite `suite_selection_select` resolves for `extensions/literature/scripts/literature-search.sh`.

**Scope Hypothesis**: The pre-fix failure and the post-fix success were both measured during
research against chunk `fd8fba3d5eb37a3f` of `caleiro_2013`, whose `source_path` column value was
`sec04_32-mosaics-and-satisfiability.md` (source: `reports/01_agent-system-batch-defect-group.md`,
Findings/Defect 4). Both are CARRIED figures from that report and from a scratch copy, not from
the source store. Confirm at implementation time by re-running `--read` on that chunk id against
the **unpatched** script (expect the not-found string) and again after the edit (expect content);
if that chunk id no longer exists, select any current `caleiro_2013` chunk from
`~/Projects/Literature/.literature.db` and record the substituted id.

**Files to modify**:
- `agent-system/extensions/literature/scripts/literature-search.sh` - add the
  `sources/<doc_id>/<basename>` candidate to `do_read()`'s chunk-file resolution, plus the
  precedent comment.

**Verification**:
- `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-lit-pipeline.sh` passes.
- A measured `--read` of a `caleiro_2013` chunk prints real chunk content; the same command
  against the pre-edit script printed `[Chunk file not found: ...]`. Both outputs recorded in the
  phase's verification notes.
- `bash -n` on the edited script, and the embedded Python compiles (the `--read` run exercises it).

---

### Phase 2: Defect 2 — lean-challenge-snapshot.sh Goals-header anchor [NOT STARTED]

**Goal**: `extract_goal_names()` establishes `start_idx` on a Goals header carrying a
parenthetical before the colon — single-line and multi-line — so a plan using this repository's
own precedent header shape no longer hard-exits 71.

**Tasks**:
- [ ] Re-derive the `lean` source store from `.claude-extensions.json`.
- [ ] Widen `START_RE` from `re.compile(r'^-?\s?\*\*Goals\*\*:')` to
  `re.compile(r'^-?\s?\*\*Goals\*\*')`, dropping the trailing-colon requirement. The
  already-present PREAMBLE rule (any line before the first bulleted line is never scanned for
  identifiers) handles arbitrary intervening prose once `start_idx` exists, so no second change
  is needed; `END_RE` (`^-?\s?\*\*[^G]`) is unaffected because it only tests the character
  immediately after `**`.
- [ ] Update the "ACCEPTED GOALS SURFACE" comment block above the extractor (currently describing
  the range as starting at a `**Goals**:` form) to state the widened, colon-optional shape, so
  the documented contract and the regex agree.
- [ ] Per D4, make no change to the `[ ! -s "$GOALS_FILE" ]` guard; add a one-line comment at the
  guard recording that it fires unconditionally on both the R1 and R2 routes ahead of
  cross-validation, so a future reader does not re-litigate the "vacuous pass" theory.
- [ ] Tidy `extract_r2()`'s `names_out` write to `extract_r1()`'s conditional-trailing-newline
  form, so an empty name set produces a true 0-byte file on both routes rather than a 1-byte
  `"\n"` on R2.
- [ ] Extend `test-lean-challenge-snapshot.sh` with cases covering: (a) a single-line
  `**Goals** (parenthetical):` header; (b) the multi-line precedent shape where the colon is not
  on the `**Goals**` line at all; (c) a negative case asserting `**Non-Goals**` still does not
  establish `start_idx`; (d) a regression case asserting the `exit 71` guard still fires on a
  Goals block with no conforming bullet.
- [ ] Stage and commit with an explicit two-file pathspec.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: Both edited files are covered by the single suite
`bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-lean-challenge-snapshot.sh`,
which `suite_selection_select` resolves for `extensions/lean/scripts/lean-challenge-snapshot.sh`,
and the change alters no externally visible interface of the script.

**Scope Hypothesis**: The current `START_RE` line number (~465), the guard line (~909), and the
existing test coverage (cases R1-R9, none exercising a parenthetical header) are CARRIED from
`reports/01_agent-system-batch-defect-group.md`, Findings/Defect 2. The script is 1067 lines and
has been edited recently by task 768, so confirm each anchor by grep (`grep -n 'START_RE\|GOALS_FILE'`)
before editing rather than seeking those line numbers.

**Files to modify**:
- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` - widen `START_RE`; update the
  ACCEPTED GOALS SURFACE comment; add the guard-route comment; tidy `extract_r2()`'s names write.
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` - add the four
  cases above.

**Verification**:
- `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-lean-challenge-snapshot.sh`
  passes, with the four new cases present and passing.
- The new parenthetical cases **fail** against the pre-edit script (confirming they are real
  regression tests, not vacuous ones) — recorded in the phase's verification notes.
- `bash -n` on both edited files.

---

### Phase 3: Defect 1 — Batch Gate Deferral narrowing paths resolve across the deploy boundary [NOT STARTED]

**Goal**: The `## Batch Gate Deferral` directive an implement dispatch receives names narrowing
invocations that exist in the repository the dispatch is actually running in, so it is followable
as written instead of requiring each agent to improvise a substitute.

**Tasks**:
- [ ] In `orchestrate-build-dispatch.sh`'s `batch_gate_deferral_flag` block, replace the two
  hardcoded `agent-system/extensions/core/scripts/...` strings with paths resolved at compose
  time, using the **same two-candidate, existence-checked pattern the same script already uses
  for `phase-heartbeat-lib.sh`**: try `"${SKILL_REPO_ROOT}/.claude/scripts/..."` first, fall back
  to `"${SKILL_REPO_ROOT}/agent-system/extensions/core/scripts/..."` (for when the composer runs
  inside the agent-system repo itself), and interpolate the **resolved** path into the echoed
  directive text.
- [ ] Decide and implement the degradation when neither candidate exists: the directive must then
  state the full gate set as such (the dispatch's own sanctioned alternative) rather than printing
  a path that cannot resolve. Record the chosen wording in a comment.
- [ ] Apply the matching fix to the parallel example in `plan-format.md`'s "Batch-aware deferral"
  subsection, giving it the explicit source-store/deployed dual form the surrounding Verification
  Tiers text already uses for `verify-deploy.sh`.
- [ ] Update `batch-gate-stage.md`'s contract language so the narrowing-invocation paths it
  documents match what the composer now emits.
- [ ] Leave `orchestrate-batch-gate.sh` **unchanged**: research confirmed it already resolves
  `VERIFY_DEPLOY_PATH="${SCRIPT_DIR}/verify-deploy.sh"` relative to its own directory, which is
  correct by construction. Record this as a deliberate no-op so the declared `file_scope` entry
  is accounted for.
- [ ] Extend `test-orchestrate-build-dispatch.sh`'s Group 19 with assertions that the emitted
  directive contains the resolved deployed-path string and does **not** contain the bare
  `agent-system/extensions/core/scripts/` string when a deployed tree is present. The existing
  `assert_contains "run-all.sh"` / `assert_contains "--only-gate"` assertions are too weak to
  detect this fix either way and must not be relied on.
- [ ] Stage and commit with an explicit four-file pathspec.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The composer change is confined to one function's echoed text with no
signature change, and the covering invocation is
`bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-orchestrate-build-dispatch.sh,test-plan-file-scope-harvest.sh,test-phase-heading-patterns.sh`
— the suites `suite_selection_select` resolves for `orchestrate-build-dispatch.sh` and for
`context/formats/plan-format.md` respectively.

**Scope Hypothesis**: The directive text is asserted to sit at `orchestrate-build-dispatch.sh`
lines 620-641 and the `phase-heartbeat-lib.sh` candidate-array precedent at lines 266-276;
`plan-format.md`'s parallel example at roughly line 339; Group 19 of the test file at roughly line
1289. All four are CARRIED from `reports/01_agent-system-batch-defect-group.md`, Findings/Defect 1,
and from a plan-time read of the source store. Confirm each by grep for its anchor string
(`Batch Gate Deferral`, `hb_lib_candidates`, `Group 19`) before editing.

**Files to modify**:
- `agent-system/extensions/core/scripts/orchestrate-build-dispatch.sh` - resolve the two narrowing
  invocation paths via the existing candidate-array pattern; interpolate the resolved path.
- `agent-system/extensions/core/context/formats/plan-format.md` - fix the parallel example in the
  "Batch-aware deferral" subsection to the dual source-store/deployed form.
- `agent-system/extensions/core/context/contracts/batch-gate-stage.md` - align the documented
  narrowing-invocation paths with what the composer emits.
- `agent-system/extensions/core/scripts/tests/test-orchestrate-build-dispatch.sh` - strengthen
  Group 19 with resolved-path and negative assertions.

**Verification**:
- `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-orchestrate-build-dispatch.sh,test-plan-file-scope-harvest.sh,test-phase-heading-patterns.sh`
  passes.
- The new Group 19 assertions fail against the pre-edit composer, recorded in the phase notes.
- A composed dispatch file with `--batch-gate-deferral` set, generated against this repository's
  root, is read back and shown to name `.claude/scripts/tests/run-all.sh` and
  `.claude/scripts/verify-deploy.sh` — paths that exist here — with the resolved paths pasted into
  the phase notes.
- `bash -n` on the two edited shell files.

---

### Phase 4: Defect 5 — Gate 16's WARN finding stops escalating to batch-blocking [NOT STARTED]

**Goal**: A `warn()`-level gate notice is distinguishable from a `fail()`-level one on the
findings interface, so Gate 16's removal-is-coming nudge no longer blocks a batch — with the
manifest declaration and the gate's own behaviour left intact.

**Tasks**:
- [ ] Change `warn()`'s two `FINDINGS_LIST` appends from the `"FINDING $CURRENT_GATE ..."` shape
  to a distinct, severity-bearing prefix that the documented consumer filter `grep '^FINDING '`
  does not match (e.g. a `WARN-FINDING ` leading token). Leave every other `warn()` effect
  untouched: the `CHECKS` increment, the `GATE_RAN_LIST`/`GATE_DIRTY_LIST` appends, and the
  `[WARN]` stderr narrative.
- [ ] Update `warn()`'s own header comment to state the severity convention and why it exists
  (D1's rationale in one short paragraph, including the explicit statement that this is not a
  manifest-declaration deletion).
- [ ] Update the "Findings mode (--findings, additive-only)" header block's description of the
  line protocol so "every finding line begins with the literal token `FINDING `" remains true,
  and the WARN-level prefix is documented as a separate, non-blocking channel.
- [ ] Add the matching severity note to `batch-gate-stage.md`, so the batch-level consumer's
  contract documents which lines are blocking.
- [ ] Make **no change** to `extensions/lean/manifest.json`: research established it declares no
  `routing_hard` key (so there is nothing to delete), and deleting `routing_agents_hard` is
  forbidden while `command-route-agent.sh` still consults it. Record this as a deliberate no-op so
  the declared `file_scope` entry is accounted for.
- [ ] Extend a gate-findings test (`test-verify-deploy-gate-selection.sh`, or a new
  `test-verify-deploy-warn-severity.sh` if the existing fixture cannot reach gate16) with
  assertions that, against a tree whose lean manifest declares `routing_agents_hard`:
  (a) `--findings --quiet` emits **no** `^FINDING gate16` line; (b) the `[WARN]` stderr line is
  still emitted; (c) the exit code is unchanged; (d) a real `fail()`-level finding from another
  gate still appears on `^FINDING `.
- [ ] Stage and commit with an explicit pathspec listing each edited file.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Tier Justification**: The edit changes a cross-file string protocol whose direct consumers are
enumerable and few — `deploy-baseline-lib.sh`'s `deploy_findings_snapshot` and
`orchestrate-batch-gate.sh` — so the covering invocation is
`bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-deploy-baseline-lib.sh,test-orchestrate-batch-gate.sh,test-verify-deploy-gate-selection.sh,test-gate-cache-equivalence.sh`,
which exercises every enumerated one-hop dependent of that protocol.

**Scope Hypothesis**: `warn()` is asserted to be the only caller-visible WARN emitter repo-wide
and `gate16_run()` its only caller; `warn()`'s appends at roughly lines 608-612 and `gate16_run()`
at roughly 1418-1437; no existing test asserts gate16's `^FINDING ` line. All CARRIED from
`reports/01_agent-system-batch-defect-group.md`, Findings/Defect 5, plus a plan-time grep.
Confirm at implementation time with `grep -rn 'warn ' agent-system/extensions/core/scripts/verify-deploy.sh`
(single caller) and `grep -rn 'gate16' agent-system/extensions/core/scripts/tests/` (no
finding-line assertion). If a second `warn()` caller exists, re-check that the prefix change is
still correct for it before proceeding.

**Files to modify**:
- `agent-system/extensions/core/scripts/verify-deploy.sh` - severity-bearing prefix in `warn()`'s
  `FINDINGS_LIST` appends; `warn()` header rationale; findings-mode header protocol documentation.
- `agent-system/extensions/core/context/contracts/batch-gate-stage.md` - document which findings
  lines are batch-blocking.
- `agent-system/extensions/core/scripts/tests/test-verify-deploy-gate-selection.sh` - gate16
  severity assertions (or a new `test-verify-deploy-warn-severity.sh`, auto-discovered by
  `run-all.sh`'s `extensions/*/scripts/tests/test-*.sh` glob, if the existing fixture cannot reach
  gate16).

**Verification**:
- `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-deploy-baseline-lib.sh,test-orchestrate-batch-gate.sh,test-verify-deploy-gate-selection.sh,test-gate-cache-equivalence.sh`
  passes.
- `bash agent-system/extensions/core/scripts/verify-deploy.sh --findings --quiet <target> | grep '^FINDING gate16'`
  returns empty, while the same run's stderr still shows `[WARN] lean still declares
  routing_hard/routing_agents_hard`. Both recorded verbatim in the phase notes.
- `jq -r 'has("routing_agents_hard")'` on `extensions/lean/manifest.json` still returns `true`,
  demonstrating the gate was not silenced by deleting the declaration.
- `bash -n` on the edited shell files.

---

### Phase 5: Defect 3a — extract the plan-compliance spot-check into a testable script [NOT STARTED]

**Goal**: The spot-check moves from inline bash inside `lean-implementation-agent.md` prose into
a standalone script with its own test suite, **with its behaviour unchanged**, so Phase 6's
polarity fix has something testable to change and task 780 has something testable to diff against.

**Tasks**:
- [ ] Create `agent-system/extensions/lean/scripts/lean-plan-compliance-check.sh` containing the
  step-5 logic verbatim in behaviour: the Goals-block `sed` range extraction, the backticked-token
  harvest, the per-name declaration grep across the resolved Lean source roots, the
  `replacement_targets` integrity sweep, and the `passed`/`failed`/`skipped` verdict. Take the plan
  file and the Lean source roots as arguments; print the per-name `[OK]`/`[MISSING]`/
  `[INTEGRITY FAIL]` lines on stdout exactly as today and the verdict on a parseable last line.
- [ ] Create `agent-system/extensions/lean/scripts/tests/test-lean-plan-compliance-check.sh` as a
  **characterization** suite written against the pre-extraction behaviour — including the existing
  quirks (colon-anchored Goals range; no keyword denylist, so a backticked `sorry` is harvested
  as a name to find). These cases pin today's behaviour so Phase 6's changes are visible as
  deliberate diffs rather than silent drift. `run-all.sh` auto-discovers the file via its
  `extensions/*/scripts/tests/test-*.sh` glob, so no runner registration is needed.
- [ ] Rewrite `lean-implementation-agent.md`'s Final Verification Stage step 5 to invoke the
  script and read its verdict, keeping the `Record: compliance_check (...)` contract line and the
  `If "failed", set status: "partial"` instruction byte-identical in meaning.
- [ ] Verify — do not edit — that `skill-lean-implementation/SKILL.md` Stage 6b and
  `skill-lean-implementation-hard/SKILL.md` Stage 6a still read `compliance_check` correctly: the
  vocabulary is unchanged by this phase, so per D2 no consumer edit is due. Record the two
  stage locations checked.
- [ ] Stage and commit with an explicit three-file pathspec.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: Extraction creates a new invocation surface consumed by an enumerable
one-hop dependent set — `lean-implementation-agent.md`'s step 5 and the two SKILL.md verdict
readers — so the covering invocation is
`bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-lean-plan-compliance-check.sh,test-lint-agent-contracts.sh,test-lint-agent-contracts-heartbeat.sh,test-lint-agent-contracts-await-notification.sh`,
pairing the new suite with the three suites `suite_selection_select` resolves for
`extensions/lean/agents/lean-implementation-agent.md`.

**Scope Hypothesis**: The spot-check block is asserted to be ~33 lines at
`lean-implementation-agent.md` lines 372-404, and the two consumer `case` blocks at
`skill-lean-implementation/SKILL.md` lines 184-208 and `skill-lean-implementation-hard/SKILL.md`
lines 305-330 — all CARRIED from `reports/01_agent-system-batch-defect-group.md`, Findings/Defect 3.
Confirm by grepping for `Plan compliance spot-check` and `compliance_check` before editing. The
claim that **no** existing test covers this block is also carried; re-confirm with
`grep -rl 'compliance_check' agent-system/extensions/lean/scripts/tests/` returning nothing before
asserting the new suite is the first coverage.

**Files to modify**:
- `agent-system/extensions/lean/scripts/lean-plan-compliance-check.sh` - new; the extracted,
  behaviour-identical spot-check.
- `agent-system/extensions/lean/scripts/tests/test-lean-plan-compliance-check.sh` - new;
  characterization suite pinning pre-extraction behaviour.
- `agent-system/extensions/lean/agents/lean-implementation-agent.md` - step 5 invokes the script
  instead of inlining the bash.

**Verification**:
- `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-lean-plan-compliance-check.sh,test-lint-agent-contracts.sh,test-lint-agent-contracts-heartbeat.sh,test-lint-agent-contracts-await-notification.sh`
  passes.
- Behaviour-preservation evidence: the extracted script and the pre-extraction inline block are
  each run against the same two fixture plans (one must-exist plan that passes, one that has a
  genuinely missing declaration) and produce the same verdict and the same per-name lines. The
  paired outputs are recorded in the phase notes — an extraction asserted to be
  behaviour-preserving by inspection alone does not satisfy this phase.
- `bash -n` on both new shell files.

---

### Phase 6: Defect 3b — polarity declaration and keyword denylist [NOT STARTED]

**Goal**: A refutation-shaped plan — one whose Goals name identifiers that must be ABSENT —
reaches a correct, positively confirming verdict instead of being failed for achieving its goal;
and reserved Lean keywords stop being harvested as declarations to find.

**Tasks**:
- [ ] Add an explicit, opt-in polarity declaration to the extracted script: when the plan declares
  a refutation polarity, each harvested identifier must be ABSENT from the resolved source roots —
  all absent → `passed`; any present → `failed` (with the present ones named). When the field is
  absent, today's must-exist behaviour applies unchanged, so every existing plan is unaffected.
  Choose a single, grep-stable declaration shape (a plan-level `- **Goal Polarity**:` metadata
  line is the recommended form) and implement exactly one, not two.
- [ ] Define the mixed-polarity case explicitly rather than leaving it implicit: a plan whose
  Goals mix must-exist and must-be-absent identifiers declares no polarity and the script records
  `compliance_check="skipped"` with a stated reason — the honest outcome task 805 reached by hand,
  now reached mechanically.
- [ ] Add a reserved-keyword denylist to the identifier harvest, mirroring the `LEAN_KEYWORDS` set
  at `lean-challenge-snapshot.sh:474` (a Python set inside a heredoc there; this script needs its
  own bash-side list — do not attempt to share one across the two languages in this phase, and add
  a comment at both sites naming the other so a future consolidation can find them).
- [ ] Apply the same colon-optional widening Phase 2 made to `START_RE` to this script's own
  `sed -n '/^\*\*Goals\*\*:/,...'` range, so the two Goals-block readers no longer disagree about
  which headers they accept. Note the shared fragility in a comment at both sites.
- [ ] Document the polarity declaration in `plan-format.md` as an optional plan-level field, with
  its default and the mixed-polarity ruling stated.
- [ ] Extend `test-lean-plan-compliance-check.sh` with: a refutation plan whose identifiers are
  all absent → `passed`; a refutation plan with one identifier present → `failed` naming it; a
  must-exist plan unaffected by the new field's absence (asserting the characterization cases from
  Phase 5 still pass); a plan whose Goals block backticks `sorry`/`box` → those tokens are not
  harvested; a parenthetical Goals header → range established.
- [ ] Reproduce the original symptom as a regression test: the archived refutation plan's Goals
  shape (`ladderRealized`, `LadderCons`, `ladderCons_localRun`, `sorry`, `box`, `stab`) produces
  `failed` under the pre-fix script and `passed` under the fixed one with the polarity declared.
- [ ] Re-verify (do not edit) that both SKILL.md verdict readers handle `passed`/`failed`/`skipped`
  correctly, per D2.
- [ ] Stage and commit with an explicit three-file pathspec.

**Timing**: 1.5 hours

**Depends on**: 3, 5

**Verification Tier**: local

**Tier Justification**: The behavioural change is confined to the one script Phase 5 created plus
its own suite, with the verdict vocabulary (`passed`/`failed`/`skipped`) deliberately unchanged so
no consumer interface moves, and
`bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-lean-plan-compliance-check.sh,test-plan-file-scope-harvest.sh,test-phase-heading-patterns.sh`
covers both the script and the `plan-format.md` documentation edit.

**Scope Hypothesis**: Six identifiers are asserted to make up the archived refutation plan's Goals
set (`ladderRealized`, `LadderCons`, `ladderCons_localRun`, `sorry`, `box`, `stab`) — CARRIED from
this task's dispatch description and from `reports/01_...md`, Findings/Defect 3. Confirm against
`specs/archive/805_jointly_derived_cell_index_gate/plans/02_joint-index-gate-closeout.md` before
building the regression fixture; if that archived plan's Goals block differs, use its actual
content and record the substitution.

**Files to modify**:
- `agent-system/extensions/lean/scripts/lean-plan-compliance-check.sh` - polarity declaration
  handling, mixed-polarity ruling, keyword denylist, colon-optional Goals range.
- `agent-system/extensions/lean/scripts/tests/test-lean-plan-compliance-check.sh` - the five new
  cases plus the archived-plan regression case.
- `agent-system/extensions/core/context/formats/plan-format.md` - document the optional
  plan-level polarity field, its default, and the mixed-polarity ruling.

**Verification**:
- `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-lean-plan-compliance-check.sh,test-plan-file-scope-harvest.sh,test-phase-heading-patterns.sh`
  passes, with every Phase 5 characterization case still green except those the polarity and
  denylist changes deliberately supersede — each such supersession named explicitly in the phase
  notes rather than silently re-baselined.
- The archived-plan regression case demonstrably inverts: `failed` pre-fix, `passed` post-fix with
  polarity declared. Both runs recorded.
- `bash -n` on the edited shell files.

---

### Phase 7: Full gate set, redeploy, and consolidated acceptance evidence [NOT STARTED]

**Goal**: Every acceptance condition is demonstrated against a freshly deployed tree, the complete
gate set is green, and the deferred `routing_agents_hard` migration is surfaced as a named
follow-up rather than silently dropped.

**Tasks**:
- [ ] Run the complete source-store gate set from the source-store repository root (the directory
  containing both `agent-system/` and its own `.claude/`):
  `bash agent-system/extensions/core/scripts/verify-deploy.sh` with that root as `TARGET`. Record
  the full PASS/FAIL line and the findings set.
- [ ] Run the full shell suite: `bash agent-system/extensions/core/scripts/tests/run-all.sh` with
  no `--only`, confirming no suite regressed under the combined six phases. A per-phase narrowed
  pass is not evidence for this step.
- [ ] Clear this repository's stale deploy (the dispatch's deploy-freshness block reports `core`
  and `lean` stale) with the bounded-wait idiom:
  `timeout 540 bash .claude/scripts/deploy-headless.sh`, Bash-tool `timeout` parameter raised to
  600000, per `context/patterns/external-process-wait.md` Rule 1. This regenerates the whole
  deployed tree, which is why this phase declares `` `__WHOLE_TREE__` ``.
- [ ] Re-run `bash .claude/scripts/verify-deploy.sh` in this repository against the freshly
  deployed tree, and record both the verdict and
  `bash .claude/scripts/verify-deploy.sh --findings --quiet . | grep '^FINDING gate16'` returning
  empty — the measured discharge of Defect 5's batch-blocking symptom.
- [ ] Walk the Acceptance clause item by item and record the evidence for each in the completion
  summary: (1) all five fixed under the resolved source store; (2) Defects 1, 2, 3, 5 each carry
  an extended or new test suite, not an inspection claim; (3) Defect 4 carries a measured `--read`
  returning content; (4) Gate 16 no longer blocks the batch **and** `extensions/lean/manifest.json`
  still declares `routing_agents_hard` (so nothing was deleted out from under
  `command-route-agent.sh`); (5) no `.claude/**` file hand-authored; (6) staging narrow and
  explicit.
- [ ] Prove acceptance item (5) mechanically rather than by assertion: confirm no commit in this
  task's range staged a path under `.claude/`, e.g. by inspecting each phase commit's name-only
  diff for a `.claude/` prefix, and record the result.
- [ ] Surface two named follow-ups in the completion summary, per the Non-Goals and D3: (a) the
  full `routing_agents_hard` → `hard_contracts` migration across `core`, `lean`, `cslib`, and
  `books` (19 files, measured in research), which Gate 16's own comment names as the real target;
  (b) task 780's grep-scope fix must now be written as a diff against
  `lean-plan-compliance-check.sh`, because the inline block it was filed against no longer exists
  and the sanctioned `--depends-on-add` edge is not addable to a `not_started` task.
- [ ] Commit with an explicit pathspec.

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4, 5, 6

**Verification Tier**: full

**Scope Hypothesis**: The "19 files across four extensions" figure for the deferred migration is
CARRIED from `reports/01_agent-system-batch-defect-group.md`, Findings/Defect 5. Re-derive it with
`grep -rl routing_agents_hard <source-store-root>` before writing it into the follow-up
recommendation, and record the figure actually measured rather than repeating this one.

**Files to modify**:
- `__WHOLE_TREE__` - this phase invokes `deploy-headless.sh`, regenerating the entire deployed
  tree; the reserved sentinel declares that implicit whole-tree scope claim honestly.
- `specs/810_agent_system_batch_defect_group/summaries/01_agent-system-batch-defect-group-summary.md`
  - new; the consolidated acceptance evidence and the two follow-up recommendations.

**Verification**:
- `bash agent-system/extensions/core/scripts/verify-deploy.sh <source-store-root>` — the complete
  gate set, every gate, no `--skip-slow` and no `--only-gate` narrowing — reports PASS.
- `bash agent-system/extensions/core/scripts/tests/run-all.sh` (unnarrowed) passes.
- `bash .claude/scripts/verify-deploy.sh` in this repository, run after the redeploy, reports PASS,
  and its `--findings --quiet` output contains no `^FINDING gate16` line.
- Each of the six Acceptance items has a recorded, measured artifact (a command and its output)
  in the summary — never an assertion that it holds.

---

## Testing & Validation

- [ ] `bash agent-system/extensions/core/scripts/tests/run-all.sh` passes unnarrowed (Phase 7).
- [ ] `bash agent-system/extensions/core/scripts/verify-deploy.sh` passes over the source-store
  root, all gates, no narrowing flags (Phase 7).
- [ ] `bash .claude/scripts/verify-deploy.sh` passes in this repository after `deploy-headless.sh`
  (Phase 7).
- [ ] Each of Defects 1, 2, 3, and 5 has a test that **fails against the pre-fix code** — recorded
  per phase, so no fix rests on a test that would have passed anyway.
- [ ] Defect 4 has a measured `--read` of a `caleiro_2013` chunk returning paper content.
- [ ] `extensions/lean/manifest.json` still declares `routing_agents_hard` after Phase 4.
- [ ] No commit in this task's range stages a path under `.claude/`.

## Artifacts & Outputs

- `agent-system/extensions/literature/scripts/literature-search.sh` (modified)
- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` (modified)
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` (modified)
- `agent-system/extensions/core/scripts/orchestrate-build-dispatch.sh` (modified)
- `agent-system/extensions/core/scripts/tests/test-orchestrate-build-dispatch.sh` (modified)
- `agent-system/extensions/core/scripts/verify-deploy.sh` (modified)
- `agent-system/extensions/core/scripts/tests/test-verify-deploy-gate-selection.sh` (modified, or
  a new `test-verify-deploy-warn-severity.sh`)
- `agent-system/extensions/core/context/formats/plan-format.md` (modified)
- `agent-system/extensions/core/context/contracts/batch-gate-stage.md` (modified)
- `agent-system/extensions/lean/agents/lean-implementation-agent.md` (modified)
- `agent-system/extensions/lean/scripts/lean-plan-compliance-check.sh` (new)
- `agent-system/extensions/lean/scripts/tests/test-lean-plan-compliance-check.sh` (new)
- `specs/810_agent_system_batch_defect_group/summaries/01_agent-system-batch-defect-group-summary.md`
  (new)

**Declared-scope note**: this plan's `Files to modify` set adds four paths beyond this task's
current `file_scope` in `specs/state.json` — `extensions/core/context/formats/plan-format.md`,
`extensions/core/scripts/tests/test-verify-deploy-gate-selection.sh`, and the two new
`lean-plan-compliance-check.sh` files — and declares `` `__WHOLE_TREE__` `` for Phase 7's
redeploy. `plan-file-scope-harvest.sh` reads the `Files to modify` blocks, so the harvest should
reconcile this; the implementer should confirm the harvest ran (or add the paths via
`update-task-status.sh --file-scope-add`) before relying on `file_scope` for a snapshot or an
overlap check. Two `file_scope` entries are deliberate no-ops this plan accounts for rather than
edits: `orchestrate-batch-gate.sh` (already resolves correctly by construction) and
`extensions/lean/manifest.json` (nothing to delete; deleting would break its live consumer).

## Rollback/Contingency

Each phase commits independently with an explicit file-list pathspec, so reverting any single
defect's fix is a `git revert` of that phase's commit and never touches the others. The two new
files in Phases 5-6 are additive; reverting them restores the inline block in
`lean-implementation-agent.md` along with the agent-file commit.

Before any step that would discard uncommitted work in the source store, take a durable
checkpoint that does **not** revert the tree: `bash .claude/scripts/git-snapshot.sh 810 --no-revert`.
A genuine rollback — one that intentionally discards working-tree changes — uses the reverting
form and follows `context/contracts/recovery.md`'s rollback rung for the exact invocation shape,
including its out-of-scope override flag; do not emit the reverting form as a routine checkpoint.

Phase 7's `deploy-headless.sh` run regenerates this repository's `.claude/` tree, which is a
gitignored deploy artifact — there is nothing to roll back there, and a bad deploy is recovered by
redeploying from a corrected source store, never by hand-patching `.claude/**`.
