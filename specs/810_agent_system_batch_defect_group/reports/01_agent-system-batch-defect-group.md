# Research Report: Task #810

**Task**: 810 - agent_system_batch_defect_group
**Started**: 2026-11-04T19:19:13Z
**Completed**: 2026-11-04T19:55:00Z
**Effort**: medium
**Dependencies**: None (task 768, previously flagged as a file_scope collision, has already
landed on `extensions/lean/scripts/lean-challenge-snapshot.sh` and its test file; see Findings,
Defect 2)
**Sources/Inputs**: Source store (`/home/benjamin/.config/nvim/agent-system/extensions/{core,lean,literature}`),
this repo's deployed `.claude/` tree, `specs/state.json`, `specs/archive/{465,805,780}*`, git
history of the source-store repo, direct mechanical reproduction of three of the five defects
against scratch fixtures
**Artifacts**: - `specs/810_agent_system_batch_defect_group/reports/01_agent-system-batch-defect-group.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All five defects are confirmed real and root-caused with file:line anchors in the source
  store; three (Defects 2, 4, and partially 1) were additionally confirmed by mechanical
  reproduction against live scratch fixtures, not just by inspection.
- **Defect 2's headline ("vacuous pass") is factually wrong as currently coded.** A measured
  `--dry-run` against a reproduction fixture shows the parenthesised-Goals-header bug produces a
  **loud exit 71** ("no identifiers found under `**Goals**:`"), not a silent pass — because the
  non-empty guard on `$GOALS_FILE` runs unconditionally before cross-validation, independent of
  the R1/R2 route. The underlying extraction-anchor bug (`START_RE` requiring the colon
  immediately after `**Goals**`) is still real and still needs fixing — precedent plans in this
  repo's own `specs/archive/` overwhelmingly use multi-line parenthetical Goals headers where the
  colon is not even on the same line — and a widened regex fix was verified to resolve both the
  single-line and multi-line parenthetical shapes.
- **Defect 5's evidence addendum contains one factually incorrect claim.** `extensions/lean/manifest.json`
  does **not** currently carry a null-valued `routing_hard` key (confirmed via `jq`/`python3`
  key-presence checks on both the source-store and deployed copies); that key was fully removed
  from every manifest by an unrelated, much earlier commit (`ba2536209`, "task 127 phase 3: remove
  routing and routing_hard from every manifest", 2026-10-02). The "free partial fix" the addendum
  proposes does not apply. Gate16 trips on `routing_agents_hard` alone.
- The full `routing_agents_hard` -> some-other-key migration the gate's own comment anticipates
  is a substantially larger undertaking than this defect's "smaller" framing suggests: 19 files
  across four extensions (`core`, `lean`, `cslib`, `books`) reference `routing_agents_hard`. This
  research recommends resolving the *batch-blocking* symptom narrowly (stop `warn()` from
  appending to `FINDINGS_LIST`) rather than performing that cross-extension migration inside this
  task — see Decisions.
- Defect 4 is fully verified end-to-end: an unpatched `--read` against a real `caleiro_2013`
  chunk reproduces the reported failure exactly, and a one-line fix (adding a
  `sources/<doc_id>/<basename>` resolution candidate, mirroring the script's own existing
  `load_fidelity_map()` derivation) was confirmed to return real chunk content.
- Defect 3's fix surface is partly undocumented by the Acceptance clause's test-suite claim: the
  plan-compliance spot-check lives as inline bash inside `lean-implementation-agent.md` prose,
  with no existing standalone test file to extend. Planning should decide whether to extract it
  into a testable script.

## Context & Scope

This is a five-defect, single-edit-target meta task consolidating findings from a prior batch
`/orchestrate` run. Per `rules/source-store-deploy-boundary.md`, every fix lands in the source
store (`~/.config/nvim/agent-system/extensions/<ext>`, confirmed via `.claude-extensions.json`'s
`source_dir` fields: `core`, `lean`, `literature` all resolve under
`/home/benjamin/.config/nvim/agent-system/extensions/`), never under this repo's deployed
`.claude/**`. No source-store file was edited during this research dispatch; all reproductions
ran against scratch copies in `/tmp`.

Research scope per the dispatch: settle Defect 2's "apparent tension" (vacuous pass vs. loud
guard) definitively; determine Defect 5's actual manifest state and the right-sized fix; confirm
Defect 4's path-resolution bug and fix with a measured `--read`; map Defect 1's hardcoded-path
bug and its established in-file fix convention; and surface Defect 3's polarity-inversion
mechanism and its consumer surface, reconciled against sibling task 780.

## Findings

### Defect 1 — Batch Gate Deferral directive names source-store-only paths

**Location**: `extensions/core/scripts/orchestrate-build-dispatch.sh` lines 628-633 (the `##
Batch Gate Deferral` directive's literal `echo` text) and `extensions/core/context/formats/plan-format.md`
line 339 (a parallel example in the "Batch-aware deferral" documentation).

**Confirmed**: `agent-system/` does not exist in this repo (`ls agent-system` -> "No such file or
directory"); the deployed mirrors `.claude/scripts/tests/run-all.sh` and `.claude/scripts/verify-deploy.sh`
both exist and both support the narrowing flags the directive names (`--only`, `--only-gate`).

**Established in-file fix convention, already present nearby**: `orchestrate-build-dispatch.sh`
lines 264-274 resolve `phase-heartbeat-lib.sh` via a two-candidate array —
`"${SKILL_REPO_ROOT}/.claude/scripts/lib/phase-heartbeat-lib.sh"` tried first, falling back to
`"${SKILL_REPO_ROOT}/agent-system/extensions/core/scripts/lib/phase-heartbeat-lib.sh"` — picking
whichever exists. The Batch Gate Deferral directive's hardcoded `agent-system/extensions/core/scripts/...`
strings should be replaced with a resolution using this same candidate-array pattern (deployed
path preferred, source-store path as fallback for when the dispatch composer itself runs inside
the agent-system repo), with the **resolved** path interpolated into the directive text rather
than the literal source-store string.

**Mechanism B is unaffected**: `orchestrate-batch-gate.sh` (the actual once-per-batch full-gate
runner) already resolves `VERIFY_DEPLOY_PATH="${SCRIPT_DIR}/verify-deploy.sh"` relative to its
own script directory — this is correct by construction and needs no change. Only Mechanism A's
advisory narrowing text is broken.

**Existing test to extend**: `extensions/core/scripts/tests/test-orchestrate-build-dispatch.sh`,
"Group 19: --batch-gate-deferral emits '## Batch Gate Deferral' ONLY on implement" (starting
line 1289). Current assertions (`assert_contains ... "run-all.sh"`, `assert_contains ...
"--only-gate"`) are weak enough to still pass after the fix; a fix-confirming assertion should
additionally check for the deployed-path string (e.g. `.claude/scripts/tests/run-all.sh`) and/or
`assert_not_contains` the bare `agent-system/extensions/core/scripts/` string.

### Defect 2 — lean-challenge-snapshot.sh Goals-header anchor (confirmed: loud failure, not vacuous pass)

**Location**: `extensions/lean/scripts/lean-challenge-snapshot.sh`, `extract_goal_names()`'s
`START_RE = re.compile(r'^-?\s?\*\*Goals\*\*:')` (current line ~465, post-task-768).

Note for the record: task 768 ("lean_challenge_snapshot_chunk_and_unicode_defects") has already
fully landed in the source store (commits `8c2ef5eae` through `e3f93eb87`, all titled "task 768
phase N: ..." / "task 768: complete implementation"). Its six phases covered the chunk-boundary,
Unicode-identifier, and keyword-denylist defects — none of them touch `START_RE`. The dispatch's
SCHEDULING note about a collision with task 768 is therefore moot; there is no live conflict,
and the parenthetical-header bug below is still present in the current, post-768 script
(confirmed by direct reproduction, not by reading task 768's commit messages).

**Mechanical reproduction** (scratch git repo, plan carrying `**Goals** (parenthetical):`
immediately followed by one leading-identifier bullet, plus a matching `## Lean Challenge
Statements` section):

```
$ bash lean-challenge-snapshot.sh 999 "$(pwd)" --dry-run
ERROR: no identifiers found under **Goals**: in specs/999_test/plans/01_test.md -- nothing to snapshot.
exit 71
```

This settles the dispatch's "apparent tension": the guard `if [ ! -s "$GOALS_FILE" ]; then ...
exit 71; fi` (current script, immediately after the R1/R2 if/elif/else block) runs
**unconditionally**, on both the R1 (plan-declared) and R2 (git-baseline) routes, strictly
*before* `cross_validate_identifiers` is ever called. `extract_r1()`'s own `names_out` write is
correctly conditional on `declared_names` being non-empty (produces a true 0-byte file when
empty), so the comparison never reaches a state where both files are simultaneously
non-empty-but-vacuously-equal. **No vacuous pass is reachable via the current main (snapshot)
flow.** `--check` mode is unaffected by this bug entirely — it reads `theorem_names` out of the
already-written `manifest.json` rather than re-running `extract_goal_names()`.

One related-but-separate latent inconsistency, found while tracing this: `extract_r2()`'s
`names_out` write (near end of that function) is `"\n".join(sorted(names)) + "\n"` —
**unconditional** trailing newline, unlike `extract_r1()`'s conditional form. On an empty
`names` list this produces a 1-byte file (`"\n"`) rather than a true 0-byte file. This is
currently inconsequential (the `$GOALS_FILE` guard fires first regardless of route), but is worth
fixing for consistency/defense-in-depth while touching this function.

**Root cause of the actual symptom** (loud failure requiring a header rewrite, per the task 465
issue-log entry `iss_1792200647620_RbNe6M`, recorded at plan phase, severity minor): `START_RE`
requires the literal substring `**Goals**:` with nothing between `**Goals**` and the colon. This
repo's own precedent plans overwhelmingly use a parenthetical form, and several span the
parenthetical across multiple lines before the colon appears at all, e.g.
`specs/archive/463_.../plans/01_....md`:
```
**Goals** (the identifier set this plan commits to proving; see `## Lean Challenge Statements`
for exact signatures):
```

**Fix verified**: widening `START_RE` to `re.compile(r'^-?\s?\*\*Goals\*\*')` (dropping the
trailing-colon requirement entirely) was patched into a scratch copy and confirmed, against both
the single-line `**Goals** (parenthetical):` fixture and a reproduction of the exact multi-line
precedent shape above, to correctly extract the identifier and pass with exit 0. This works
because the already-existing (task-768-introduced) "PREAMBLE" rule — any line before the first
bulleted line is never scanned for identifiers — already handles arbitrary intervening prose
once `start_idx` is established; the only broken piece was establishing `start_idx` at all.
`END_RE` (`^-?\s?\*\*[^G]`) needs no change — it is unaffected by a parenthetical since it only
tests the character immediately after `**`.

**Existing tests to extend**: `extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh`
already has Cases R1-R9 covering the list-item form, preamble paragraphs, and Unicode names
(R6-R9, lines ~258-330) but none test a parenthetical-before-colon header shape. A new case
exercising both the single-line and multi-line parenthetical shapes should be added there.

### Defect 3 — plan-compliance spot-check polarity inversion on refutation tasks

**Location**: `extensions/lean/agents/lean-implementation-agent.md`, Final Verification Stage
step 5 ("Plan compliance spot-check", lines ~372-404).

Confirmed the extraction in this step is **independent of, and cruder than**, the Python
extraction in `lean-challenge-snapshot.sh`: it is a bare `sed -n '/^\*\*Goals\*\*:/,/^\*\*[^G]/p'
| grep -oP` that (a) shares the exact same colon-anchoring fragility as Defect 2's pre-fix
`START_RE` (not in scope here per the dispatch's framing, but worth flagging as a related
fragility in the same family), and (b) harvests **every** backticked token anywhere in the
matched block, not just a leading-bullet-identifier run, and applies **no keyword denylist** —
confirmed against task 805's archived plan prose, where `sorry` and `box` appear backticked in
descriptive sentences and would be harvested as names to search for via
`grep -rq "^\(noncomputable \)\?\(theorem\|def\|lemma\|instance\) ${name}\b"`, a pattern that
will essentially never match a reserved word, inflating the apparent miss count regardless of
polarity.

**Polarity mechanism**: on a refutation task (task 805's case), the Goals block names identifiers
that must be **absent** from the tree (`ladderRealized`, `LadderCons`, `ladderCons_localRun`,
plus `sorry`/`box`/`stab` per the dispatch). The literal check's existence-grep reports every one
`[MISSING]`, unconditionally sets `compliance_failed=true`, hence `compliance_check="failed"` —
inverted for exactly the cases where absence is the goal. Task 805 avoided this by hand-recording
`compliance_check: "skipped"` with a stated reason, bypassing the automated check rather than
letting it fabricate a verdict.

**Consumer surface, verified**: both `extensions/lean/skills/skill-lean-implementation/SKILL.md`
Stage 6b (lines 184-208) and `skill-lean-implementation-hard/SKILL.md` Stage 6a (lines 305-330)
read `compliance_check` via an identical three-way `case` — `"failed"` -> `status="partial"`,
`"passed"` -> informational pass, and a **catch-all `"skipped"|*)`** -> informational
"proceeding" message. This catch-all means: if the chosen fix is "detect a refutation-shaped
plan and auto-set `compliance_check="skipped"` with a reason," **neither consumer file needs any
code change** — the existing default branch already handles it correctly. A change would only
be required if the fix instead introduces a new, *positively confirming* status value (e.g. a
hypothetical `"confirmed_absent"`) that should render a distinct message rather than falling into
the generic "skipped" wording; that is a design choice for planning, not settled by this
research.

**Reconciliation with task 780** (`plan_compliance_spotcheck_probe_scope`, `not_started`, no
`file_scope` set): confirmed orthogonal axes — 780 widens the grep **scope** (source roots vs.
`specs/evidence/**`), this defect concerns grep **polarity** (must-exist vs. must-be-absent).
Both touch the exact same bash block in the exact same file, so whichever lands second should be
written as a diff against the other's landed state, or the two should be planned as one
sequenced pair of phases against this one block — not as independently drafted, conflicting
rewrites.

**Gap relative to the Acceptance clause's test-suite claim**: no existing test file under
`extensions/lean/scripts/tests/` covers this inline bash snippet (it is embedded prose inside an
agent `.md` file, not a standalone script) — confirmed via a recursive grep for
`compliance_check`/"spot-check" across that directory, zero hits. Planning should decide between
(a) extracting the spot-check into a standalone, testable script (also directly benefiting task
780's fix) or (b) a markdown-embedded-snippet test harness, or (c) accepting scenario-based
evidence only for this one defect.

### Defect 4 — literature-search.sh `--read` path resolution (fully verified, fix measured)

**Location**: `extensions/literature/scripts/literature-search.sh`, `do_read()`'s embedded
Python chunk-file resolution (current lines ~1193-1286).

**Reproduced against the real literature database** (`~/Projects/Literature/.literature.db`,
`caleiro_2013` doc, chunk `fd8fba3d5eb37a3f`, `source_path` column value
`sec04_32-mosaics-and-satisfiability.md`):

```
$ bash literature-search.sh --read fd8fba3d5eb37a3f
...
"content": "[Chunk file not found: /home/benjamin/Projects/Literature/sec04_32-mosaics-and-satisfiability.md]"
```

Both existing candidates miss: `os.path.join(db_dir, source_path)` (no `sources/` prefix at all)
and the `os.path.join(db_dir, doc_id, chunk_file_basename)` fallback (missing the `sources/`
directory component). The real file lives at
`~/Projects/Literature/sources/caleiro_2013/sec04_32-mosaics-and-satisfiability.md` (confirmed
present on disk).

**Fix verified**: adding a third candidate, `os.path.join(db_dir, "sources", doc_id,
chunk_file_basename)`, mirroring `load_fidelity_map()`'s own existing `sources/<dir>/` derivation
earlier in the same function (which already assumes `doc_id` equals the directory name under
`sources/` — confirmed consistent with the measured row), was patched into a scratch copy and
confirmed to return the full chunk content (the real paper text) for the same chunk ID that
previously failed. This fully satisfies the Acceptance clause's required evidence shape for this
defect ("a measured `--read` of a caleiro_2013 chunk returning content").

### Defect 5 — Gate 16 / `routing_agents_hard` (addendum partially stale; scope recommendation below)

**Location**: `extensions/core/scripts/verify-deploy.sh` `gate16_run()` (current lines
1418-1437), `extensions/core/scripts/verify-deploy.sh` `warn()` (lines 595-613),
`extensions/lean/manifest.json`.

**Correction to the dispatch's evidence addendum**: point (2) of the addendum claims
`extensions/lean/manifest.json` "carries `\"routing_hard\": null` alongside a populated
`routing_agents_hard`." This is **not true of the current file**, verified two ways:
`jq -r 'has("routing_hard")'` returns `false` on both the source-store copy and this repo's
deployed copy, and a direct `python3 json.load` key listing shows the manifest's keys are
`name, version, description, task_type, dependencies, provides, routing_agents,
routing_agents_hard, merge_targets` — no `routing_hard` key at all. Git history on the
source-store repo shows `routing_hard` was fully **removed** (not nulled) from every manifest,
including lean's, by commit `ba2536209` ("task 127 phase 3: remove routing and routing_hard from
every manifest", 2026-10-02-21:56:48 -0700) — well before this batch task was authored. (My
first attempt at checking this made the exact mistake the addendum likely did: `jq
'{routing_hard, routing_agents_hard}' manifest.json` renders an *absent* key as `"routing_hard":
null` in its constructed output, which looks identical to a genuinely-null-valued declared key
but is not one — `has()` is the correct test.) **There is no free, zero-risk `routing_hard`
deletion available; the entire gate trip for lean is the `routing_agents_hard` key alone.**

**Confirmed mechanism for why a `warn()`-level finding still blocks the batch**: `warn()` (the
only caller of which, repo-wide, is `gate16_run`) increments `CHECKS` but never `FAILURES` —
correct, non-blocking by the verifier's own exit code — but when `FINDINGS=true` it appends to
`FINDINGS_LIST` using the exact same `"FINDING $CURRENT_GATE ..."` string shape every `fail()`
call uses, and the findings interface carries no severity field anywhere. A batch-gate consumer
reading `FINDINGS_LIST` (as `orchestrate-batch-gate.sh` does, via `deploy-baseline-lib.sh`'s
attribution functions) cannot distinguish this nudge from a real failure.

**Scope of the "real" migration the gate's comment defers**: a repo-wide grep for
`routing_agents_hard` across the source store returns 19 files spanning four extensions (`core`,
`lean`, `cslib`, `books`), including `manifest-routing-lib.sh`, `command-route-agent.sh`,
`lint-routing-wiring.sh`, `test-routing-resolution.sh`, `manifest-routing-schema.md`, and
`hard-mode-routing.md`. This matches the gate's own comment describing it as a "remaining
follow-on" not yet ready to land, and is a materially larger undertaking than this defect's
"smaller" characterization in the dispatch. Note also that in *this* repo's deployed tree, only
the `lean` extension is loaded (`.claude/extensions/{core,filetypes,formal,lean,literature,memory,typst}`),
so `books` and `cslib` never even reach `gate16_run()`'s loop here — the observed finding in this
repo's batch run is caused by `lean` alone.

## Decisions

- **Defect 2's "vacuous pass" framing is superseded by this research's mechanical reproduction**:
  treat it as "loud exit 71 on a header shape this repo's own precedent plans use," not a
  silent-failure mode. Fix the `START_RE` anchor (verified widening:
  `re.compile(r'^-?\s?\*\*Goals\*\*')`); do not spend effort hardening the `$GOALS_FILE`
  non-empty guard itself, which is already airtight for this bug. Separately tidy
  `extract_r2()`'s unconditional-trailing-newline write for consistency with `extract_r1()`'s
  conditional form (latent, not currently exploitable).
- **Defect 5: recommend the narrow fix, not the cross-extension migration.** Stop `warn()` from
  appending to `FINDINGS_LIST` at all (keep its `[WARN]` stderr narrative and its
  `GATE_DIRTY_LIST` effect) rather than attempting the `routing_agents_hard` -> new-key rename
  across all four extensions and ~19 files inside this task. Rationale: the rename is explicitly
  described by the gate's own comment as a deferred, not-yet-ready follow-on; `warn()` has
  exactly one caller repo-wide (`gate16_run`), so narrowing its `FINDINGS_LIST` behavior is a
  small, contained, low-risk change; and this defect is explicitly framed in the dispatch as
  "smaller" relative to the other four. This recommendation does **not** make `gate16_run` reach
  its own `pass()` branch (it still `warn()`s, since `routing_agents_hard` remains declared and
  genuinely consulted) — it resolves the batch-blocking *symptom* the dispatch's evidence
  addendum centers on, which is the concrete, currently-reproducing harm. The literal "Gate 16
  passes (no extension manifest declares...)" Acceptance wording should be read, per the
  addendum's own later and more specific framing, as "Gate 16 no longer blocks the batch,"
  not as a mandate to reach the `pass()` code path in this task. Planning should record a
  separate, explicit follow-up task for the full `routing_agents_hard` migration (the real target
  the gate's comment names) rather than silently dropping it.
- **Defect 3's fix target is a polarity/detection mechanism, not a full rewrite.** Given the
  three-way `case` catch-all already treats any non-`"failed"`/`"passed"` value as informational,
  the lowest-risk fix is: detect a refutation-shaped plan (heuristic candidates: an explicit
  marker convention in the plan's Goals block, or a title/Non-Goals keyword check) and set
  `compliance_check="skipped"` with a recorded reason — requiring zero consumer-file changes.
  Adding the keyword denylist (reusing `lean-challenge-snapshot.sh`'s `LEAN_KEYWORDS` set, or a
  shared constant) is an independent, always-safe improvement regardless of which polarity
  mechanism planning chooses.

## Recommendations

1. **Defect 1**: In `orchestrate-build-dispatch.sh`'s Batch Gate Deferral directive (lines
   628-633), resolve the two narrowing-invocation paths via the same two-candidate,
   existence-checked pattern already used for `phase-heartbeat-lib.sh` (lines 264-274), and
   interpolate the *resolved* path into the directive's echoed text. Apply the matching fix to
   `plan-format.md` line 339's parallel example (give it the same explicit source-store/deployed
   dual-form line 302 already uses). Extend `test-orchestrate-build-dispatch.sh` Group 19 with an
   assertion on the resolved deployed-path string.
2. **Defect 2**: Widen `START_RE` in `extract_goal_names()` to `re.compile(r'^-?\s?\*\*Goals\*\*')`.
   Add a new case to `test-lean-challenge-snapshot.sh` covering both a single-line
   `**Goals** (parenthetical):` header and the multi-line precedent shape found in
   `specs/archive/463_.../plans/01_....md`. Optionally tidy `extract_r2()`'s names-file write to
   match `extract_r1()`'s conditional-newline form.
3. **Defect 3**: Add a polarity-detection or explicit-declaration mechanism to the step-5 spot
   check in `lean-implementation-agent.md`, defaulting to `compliance_check="skipped"` (with
   reason) on a detected refutation-shaped plan; add the keyword denylist independently. Decide
   with task 780 at plan time whether to extract the shared bash block into a standalone,
   testable script (`extensions/lean/scripts/lean-plan-compliance-check.sh` or similar) — this
   would also close the Acceptance clause's test-suite gap noted above. Sequence the two tasks'
   edits to the same block explicitly rather than drafting independently.
4. **Defect 4**: Add the `sources/<doc_id>/<basename>` resolution candidate to `do_read()`,
   verified working against the `caleiro_2013` chunk. Low risk; single, additive code path.
5. **Defect 5**: Remove `warn()`'s `FINDINGS_LIST` append (both branches, lines ~608-612),
   leaving its stderr `[WARN]` output and `GATE_DIRTY_LIST` side effect intact. File a separate
   follow-up task for the full `routing_agents_hard` -> new-key migration across `core`, `lean`,
   `cslib`, and `books` (19 files), explicitly deferred per the gate's own comment. Do not attempt
   to delete a `routing_hard` key from lean's manifest — it does not exist.

## Risks & Mitigations

- **Risk**: widening Defect 2's `START_RE` could accidentally match an unintended label.
  **Mitigation**: verified the widened regex cannot match `**Non-Goals**` (the literal substring
  `Goals` must be immediately followed by `**`, which `Non-Goals**` never satisfies at the
  required offset) or a word like `**Goalsetting**` (the closing `**` must immediately follow
  `Goals`, not an extended word). No existing test in `test-lean-challenge-snapshot.sh` relies on
  `START_RE` failing to match as its pass/fail signal (confirmed by inspection of R1-R9).
- **Risk**: Defect 5's narrow fix (removing `warn()`'s `FINDINGS_LIST` append) could be read as
  "silencing the gate," which the dispatch explicitly forbids. **Mitigation**: the forbidden
  action is deleting the *manifest declaration* to silence the gate; this fix instead changes how
  a non-blocking finding is surfaced at the findings-interface layer, with `gate16`'s own
  `[WARN]` stderr narrative, `CHECKS` increment, and `GATE_DIRTY_LIST` effect all left intact —
  the manifest keeps declaring `routing_agents_hard`, and the gate keeps warning about it on
  every run; only its escalation into the batch-blocking `FINDINGS_LIST` channel changes. Planning
  should state this distinction explicitly in the plan file so it is auditable against the
  dispatch's prohibition.
- **Risk**: Defect 3 and task 780 land out of sequence, each overwriting the other's edit to the
  same bash block. **Mitigation**: flagged explicitly above and in Decisions; planning should
  either combine both into one task's phases or declare an explicit dependency edge
  (`update-task-status.sh --depends-on-add`).
- **Risk**: no automated test harness currently exists for Defect 3's fix.
  **Mitigation**: flagged as a planning decision point (extract to script vs. accept
  scenario-based evidence); not resolved by this research, which is appropriately a planning
  call given it affects task 780's future testability too.

## Context Extension Recommendations

- None identified as missing *documentation* gaps distinct from the code defects themselves —
  this is a meta/defect-fix task where the relevant context (`batch-gate-stage.md`,
  `manifest-routing-schema.md`, `plan-format.md`'s Verification Tiers section) already exists and
  is largely accurate; the defects are code/text bugs within already-documented mechanisms, not
  missing documentation.

## Appendix

Key commands run during this research (all against scratch copies/fixtures in `/tmp`, never
against the source store):

- `jq -r '.extensions.{core,lean,literature}.source_dir' .claude-extensions.json` — resolved
  source-store roots.
- `bash <scratch-copy-of>lean-challenge-snapshot.sh 999 "$(pwd)" --dry-run` against a fixture
  plan with a `**Goals** (parenthetical):` header and a matching `## Lean Challenge Statements`
  section — reproduced exit 71 against the unpatched script; exit 0 with correct
  `theorem_names: fooBar` against a copy with `START_RE` widened, for both the single-line and
  multi-line-parenthetical header shapes.
- `bash literature-search.sh --read fd8fba3d5eb37a3f` against the real
  `~/Projects/Literature/.literature.db` — reproduced `[Chunk file not found: ...]` against the
  unpatched script; returned full chunk content against a copy with the `sources/<doc_id>/`
  candidate added.
- `jq -r 'has("routing_hard")'` / `python3 -c "... 'routing_hard' in json.load(...)"` against
  both the source-store and deployed `extensions/lean/manifest.json` — both `false`/absent.
- `git log -- extensions/lean/manifest.json` (source-store repo) — located commit `ba2536209`
  removing `routing_hard` from every manifest, 2026-10-02.
- `grep -rl "routing_agents_hard" ~/.config/nvim/agent-system` — 19 files across `core`, `lean`,
  `cslib`, `books`.
- `git log --all --oneline | grep -i 768` (this repo) — confirmed task 768 fully landed, six
  phases, none touching `START_RE`.

References: `extensions/core/context/contracts/batch-gate-stage.md`,
`extensions/core/context/formats/plan-format.md` (Verification Tiers / Batch-aware deferral),
`extensions/core/context/guides/manifest-routing-schema.md`,
`specs/archive/465_complete_terminus_restatement_family/issues.jsonl`,
`specs/archive/805_jointly_derived_cell_index_gate/plans/02_joint-index-gate-closeout.md`,
`specs/state.json` (task 780 full description).
