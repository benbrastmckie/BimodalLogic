# Research Report: Task #764

**Task**: 764 - Specs only gate and task reference lint debt
**Started**: 2026-10-12T00:00:00Z
**Completed**: 2026-10-12T00:00:00Z
**Effort**: medium (two independent findings; one closed by a dependency task, one requires a
source-store code fix plus a planning-guidance fix)
**Dependencies**: Task 771 (completed) — carried the task-reference-lint-debt half
**Sources/Inputs**:
- `agent-system/extensions/core/scripts/verify-deploy.sh` (gates 1-22, `pass()`/`fail()`/`gate_selected()`, exit-code logic)
- `agent-system/extensions/core/scripts/check-task-references.sh` and `check-extension-docs.sh` (run directly against this deploy-consumer repo)
- `agent-system/extensions/core/scripts/lib/task-reference-patterns.sh`, `suite-selection-lib.sh`
- `agent-system/extensions/core/scripts/deploy-root-guard.sh`
- `agent-system/extensions/core/context/formats/plan-format.md` (`## Verification Tiers`, `__FULL_SWEEP__` guidance)
- `agent-system/extensions/core/context/standards/task-reference-exemptions.md` (exemption taxonomy)
- `agent-system/extensions/core/scripts/tests/test-verify-deploy-gate-selection.sh`
- `specs/757_lplus_decidability_successor_task_set/issues.jsonl` (originating evidence)
- `specs/771_task_reference_lint_debt_boneyard_tests/reports/01_lint-debt-already-cleared.md`, `.../summaries/01_verify-lint-gate-green-summary.md`
- `specs/720_promote_fmp_width_refutations_to_evidence/plans/01_ci-repair-and-citation-repoint.md`, `.../summaries/01_ci-repair-and-citation-repoint-summary.md`
- `specs/state.json` (project 764/766/771 status, dependencies, `file_scope`)
- `.claude-extensions.json` (`source_dir` resolution)
**Artifacts**:
- `specs/764_specs_only_gate_and_task_reference_lint_debt/reports/01_specs-only-gate-and-lint-debt.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Finding (2), the task-reference lint debt, is already fully closed.** Dependency task 766
  rewrote all 198 pre-existing citations to durable anchors; dependency task 771 verified the
  gate at 0 occurrences and closed `[COMPLETED]` (most recent commit on `main`:
  `67c1887fc task 771: complete implementation`). An independent re-run in this research pass
  confirms `check-task-references.sh --quiet` still exits 0, repo-wide, right now. **No file
  edit is needed to satisfy finding (2)'s literal acceptance test.** The one open sub-question —
  whether to extend the exemption taxonomy with a `Boneyard/**` path-level category — is
  explicitly homed at this task by both 766 and 771, and this report argues against adding it
  (see Decisions).
- **Finding (1) is real, and root-caused one level deeper than the dispatch description states.**
  `verify-deploy.sh` gate 4's own SKIP guard (`! -d "$TARGET/agent-system/extensions"`) is
  **factually wrong for `check-task-references.sh`** — that script runs a real, meaningful check
  in any deploy-consumer repo (verified directly against this repo: real output, exit 0, zero
  reliance on `agent-system/extensions`). The SKIP guard was copy-pasted/mirrored from gate 3
  (doc-lint), where the same guard is **correct** — `check-extension-docs.sh` genuinely errors
  (exit 1) without `agent-system/extensions` present. Gate 4's guard inherited gate 3's premise
  without re-verifying it held for a different script, and it does not.
- **The zero-checks-exits-0 defect is systemic, not specific to gates 3/4.** 18 of
  `verify-deploy.sh`'s 22 gates carry an identical `[SKIP]`-on-deploy-consumer guard. Any
  `--only-gate` selection drawn only from that set of 18, against any deploy-consumer repo, hits
  the same silent "PASS -- 0 check(s), 0 failure(s)" result — not a specs/**-specific bug.
- **The same vacuous pattern has already fired once outside the specs/**-only case named in the
  dispatch description.** Task 720's plan/summary invoke `verify-deploy.sh --only-gate 3,4`
  (no explicit `TARGET`) as the covering check for a **source-store** markdown edit — but
  `TARGET` defaults to `$(pwd)`, which for a dispatch running inside this repo is always the
  deploy-consumer root, never the source store. That invocation also ran 0 real checks; the
  summary recorded "exit 0" without noticing. `plan-format.md`'s `__FULL_SWEEP__` guidance
  ("ordinarily `--only-gate 3,4`") never tells the author to point `TARGET` at the resolved
  source store, so it is silently vacuous from the overwhelmingly common dispatch cwd, for any
  unmapped-path phase — not only specs/**-only ones.
- **Recommended disposition for (1)**: (a) fix gate 4's SKIP guard in `verify-deploy.sh` so it
  actually invokes `check-task-references.sh` against `TARGET` unconditionally (gate 3 keeps its
  guard — it is correct); (b) add a generic "0 checks ran under an active `--only-gate` filter"
  detection to `verify-deploy.sh`'s end-of-run summary, reusing the existing exit-code-2
  "cannot run, must be treated as failure" semantics, so any future all-SKIP selection fails
  loudly instead of passing silently; (c) correct `plan-format.md`'s `__FULL_SWEEP__` guidance so
  it no longer recommends `--only-gate 3,4` uniformly — a specs/**-only phase's real covering
  check is `validate-artifact.sh <path> <type>` (for report/plan/summary files) plus the
  already-defined `prose`-tier diff read-through, never gate 3/4 (specs/** is the task-reference
  lint's own exempt tree by design, so even a fixed gate 4 cannot inspect a new specs/** file's
  own content); a source-store non-specs edit's guidance must additionally name the resolved
  `source_dir` as the explicit `TARGET`.

## Context & Scope

This is the research dispatch (phase=research) for task 764, a meta-task closing two
verification-gap findings recorded during a prior orchestration round (`specs/757_...`'s
`issues.jsonl`). Task 764 depends on task 771, which depends on task 766 — both completed before
this dispatch began. The scope here is: re-derive both findings from first principles (not from
prior artifacts' prose), determine what, if anything, remains open, and recommend a disposition
for the plan phase. Per the dispatch's SCOPE section, any resulting code change belongs in the
agent-system source store (resolved via `.claude-extensions.json`'s `source_dir`,
`/home/benjamin/.config/nvim/agent-system/extensions/core`), never hand-authored under
`.claude/**` in this repo.

## Findings

### Finding (2): task-reference lint debt — already resolved, nothing to implement

Re-run directly in this research pass (not carried from any prior artifact):

```
$ bash .claude/scripts/check-task-references.sh
Scanning repo (excluding specs/) ...
  repo (excluding specs/): 0 occurrence(s)
PASS: 0 unexempted task-reference occurrences
$ echo $?
0
```

`specs/state.json` confirms: `764` depends on `[771]`; `771` (completed) depended on `[766]`
(completed); `771`'s own `file_scope` names `Boneyard/`, `Tests/BimodalTest/`,
`scripts/check-task-references.sh` — the same tree 766 cleaned. 771's report
(`reports/01_lint-debt-already-cleared.md`) and summary
(`summaries/01_verify-lint-gate-green-summary.md`) both record: 766 rewrote all 198 occurrences
across 53 files to durable anchors (filenames, section headings, named theorem/refactor
references), added **zero** `task-ref-ok` exemption markers, and 771 verified the gate at 0
occurrences repo-wide and scoped to both directories, then closed `[COMPLETED]`. The most recent
commits on `main` (`67c1887fc task 771: complete implementation`,
`23e75df1d task 771 phase 1: verify lint gate green and attribute the fix`) are this closure.

**No file under `scripts/check-task-references.sh`, `scripts/lib/task-reference-patterns.sh`, or
`context/standards/task-reference-exemptions.md` needs to change to make the lint pass** — it
already passes. The only thing 766/771 deliberately left open and explicitly assigned to 764 is
the taxonomy-extension question below.

### The `Boneyard/**`-exemption question: argued against, not assumed

The task description's preference order was "exempt (preferred for archival citations) or
clean." 766 chose clean exclusively. 771's summary states explicitly: "The
`Boneyard/**`-as-named-exempt-path-class taxonomy question remains out of scope and is homed at
task 764, not here." This research argues the taxonomy should **not** be extended with a
`Boneyard/**` category, for three reasons:

1. **The debt no longer exists.** A taxonomy category exists to classify a *recurring* class of
   legitimate citation, not to retroactively justify a one-time already-paid-down debt. 766's
   198 rewrites are evidence that durable-anchor rewriting is *achievable* for every occurrence
   in this path class — there is no residual case the taxonomy needs to excuse.
2. **An exemption only loosens enforcement going forward, with no compensating benefit.** The
   write-time guard hook (`hooks/validate-no-task-references.sh`, same shared library) already
   blocks a *new* task-number citation landing in `Boneyard/**` regardless of whether a
   path-level exemption exists for it. Adding the category would not close any present gap — it
   would only re-permit, for future archival READMEs, exactly the pattern that durable-anchor
   rewriting just replaced at real cost (53 files).
3. **Category 1 (`specs/**`) is exempt because task numbers are the intrinsic subject matter of
   that tree** (task-management artifacts citing their own task number is not a citation
   problem, it is the tree's purpose). `Boneyard/**` tombstone READMEs do not have that
   property — 766 already demonstrated every one of them can cite a durable anchor instead (a
   filename, a section heading, a named refactor) just as well as live code can. The bar
   category 1 clears is not one `Boneyard/**` clears by the same argument.

**Recommendation**: leave the taxonomy unchanged (7 categories, as today); record this decision
(with the three reasons above) in 764's own plan/summary as the explicit closure of the open
question 766/771 left for it. No script or standards-file edit follows from this half of the
task. A "baseline mode" for `check-task-references.sh` (the dispatch's third named option) is
likewise unnecessary now that the standing count is 0 — there is nothing for a baseline to
distinguish a new occurrence from.

### Finding (1): the specs-only covering-check gap — confirmed, and one level deeper than described

Reproduced directly against this repo (a deploy consumer: `.claude-extensions.json` is present,
`.claude/` is deployed, not hand-authored):

```
$ bash .claude/scripts/verify-deploy.sh --only-gate 3,4 .
[verify-deploy] Target: /home/benjamin/Projects/BimodalLogic

3. Doc-lint (check-extension-docs.sh --quiet)
  [SKIP] ... is a deploy consumer, not the source store -- doc-lint does not apply

4. Task-reference lint (check-task-references.sh --quiet)
  [SKIP] ... is a deploy consumer, not the source store -- task-reference lint does not apply
[verify-deploy] PASS -- 0 check(s), 0 failure(s)
$ echo $?
0
```

This exactly reproduces the originating `issues.jsonl` entry
(`iss_1791674781045_8cIfU1`, task 757/760 round): an exit-0 result with 0 checks, cited as a
covering check for a `specs/**`-only phase.

#### Root cause 1 (new in this research): gate 4's SKIP guard is factually wrong for its own underlying script

`verify-deploy.sh` gate 3 (line 415 area, "Doc-lint gate") and gate 4 ("Task-reference lint
gate") carry an **identical** guard shape:

```bash
if [ ! -d "$TARGET/agent-system/extensions" ]; then
  say "  [SKIP] $TARGET is a deploy consumer, not the source store -- ... does not apply"
```

Gate 4's own comment states the justification: "Only meaningful in the source-store repo,
**mirroring the Doc-lint gate above**." This research tested both underlying scripts directly,
run from this deploy-consumer repo's root, with no gate wrapper:

```
$ bash .claude/scripts/check-extension-docs.sh --quiet
ERROR: /home/benjamin/Projects/BimodalLogic/agent-system/extensions does not exist
$ echo $?
1
```
```
$ bash .claude/scripts/check-task-references.sh
Scanning repo (excluding specs/) ...
  repo (excluding specs/): 0 occurrence(s)
PASS: 0 unexempted task-reference occurrences
$ echo $?
0
```

`check-extension-docs.sh` genuinely cannot run without `agent-system/extensions` — gate 3's guard
is **correct**. `check-task-references.sh` runs a real, meaningful, repo-appropriate scan with
**no dependency whatsoever** on `agent-system/extensions` — gate 4's guard is **incorrect**. This
is not specific to this repo: `check-task-references.sh`'s own header states it is
"repo-appropriate by construction... a consumer repo with a different source-tree layout... is
scanned in full rather than scanning nothing," and its only structural precondition
(`deploy-root-guard.sh`) checks the *script's own deployed path shape*
(`.claude/scripts/` or `.opencode/scripts/`), which every deploy-consumer repo satisfies by
definition. Gate 4's SKIP guard was copied from gate 3 without re-verifying the premise held for
a different script — it does not.

**This is the primary, lowest-risk fix for finding (1).** Removing (or correcting) gate 4's SKIP
condition in `verify-deploy.sh` makes `--only-gate 4` (and `--only-gate 3,4`, for its gate-4
half) run a real check in every deploy-consumer repo this system is deployed into, not only the
source store. `test-verify-deploy-gate-selection.sh`'s existing case (b) only exercises
`--only-gate N` for every `N` against `FIXTURE_RICH` (the source-store-shaped fixture, where
gates 3/4 both already run for real); it does not assert the SKIP behavior for `FIXTURE_CHEAP`
(the deploy-consumer-shaped fixture) under `--only-gate`, so no existing test encodes the
behavior this fix would change. The caveat: 18 of 22 gates carry this same
source-store-conditioned SKIP guard (gates 3,5,6,7,8,9,10,11,12,13,15,17,18,19,20,21,22); each
would need the same per-script "does this guard's premise actually hold?" audit before removing
it — this research only confirmed gate 4's premise is wrong, not any of the other 17 (several,
e.g. gate 5's manifest-driven `verify.lua` diff or gate 8's shell-suite runner, plausibly *do*
need the source store and would keep a correct SKIP).

**A caveat on what a fixed gate 4 would and would not prove for a specs/**-only phase**:
`check-task-references.sh`'s own exemption taxonomy (category 1) excludes `specs/**` from the
scan entirely. A real, passing gate-4 run would confirm "the rest of the repo has no new
citation regression" — it would **never** inspect the content of the new `specs/**` file itself,
by design. This matters for deciding what a specs/**-only phase's covering check should actually
attest to (next subsection) — fixing gate 4 closes the "silently exits 0 having run nothing"
defect, but does not, on its own, supply a check of the new document's own correctness.

#### Root cause 2: `plan-format.md`'s `__FULL_SWEEP__` guidance recommends a check that cannot be meaningful from the dispatch's own cwd

`context/formats/plan-format.md`'s `## Verification Tiers` section states, for any touched path
`suite_selection_select` cannot map to a suite (the `__FULL_SWEEP__` sentinel — confirmed by
reading `suite-selection-lib.sh`: it maps only `scripts/tests/test-*.sh` / flat `test-*.sh`
basenames under the scripts tree it is sourced from, so **any** `specs/**` or `context/**.md`
path is always unmappable):

> "the honest covering check in that case is a gate subset — ordinarily
> `bash .claude/scripts/verify-deploy.sh --only-gate 3,4`"

This text names no `TARGET`. `verify-deploy.sh`'s `TARGET` defaults to `$(pwd)` (confirmed:
`TARGET="${TARGET:-$(pwd)}"`). A dispatch's cwd is the consumer repo root (confirmed by this
session's own environment: "Primary working directory: /home/benjamin/Projects/BimodalLogic") —
never the nvim source-store checkout — for every ordinary dispatch in this and every other
consumer repo. The guidance is therefore silently vacuous (today, pre-fix: 0 checks; even after
the gate-4 fix above: gate 3 alone still SKIPs, and gate 4 alone cannot see `specs/**` content)
**independent of whether the touched file is under `specs/**` or under the source store** — the
dispatch description's framing ("a newly written `specs/**` document") names one instance of a
broader guidance gap.

This is independently confirmed by task 720's artifacts: its covering check for a **source-store**
markdown edit (`/home/benjamin/.config/nvim/agent-system/extensions/core/context/patterns/task-abandon-mode.md`,
explicitly "outside this repository") was `bash .claude/scripts/verify-deploy.sh --only-gate 3,4`
with no `TARGET` argument — run from this repo's cwd, this also produces 0 real checks (same
defect). Task 720's summary records "exit 0" for that line without noting the check count,
unlike 757's round, which did catch and log it. The guidance text's omission of an explicit
`TARGET` is the common root cause behind both occurrences.

### What a specs/**-only phase's covering check should actually attest to

Given the above, the honest covering check for a phase whose entire `Files to modify` lies under
`specs/**` is **not** `verify-deploy.sh --only-gate 3,4` under any TARGET choice (specs/** is the
task-reference lint's own exempt tree by design; doc-lint has nothing to do with specs/**
content either). The actual mechanical backstop that inspects a new specs/** artifact's own
content already exists and is already used elsewhere in the lifecycle:

- **`validate-artifact.sh <path> <type>`** (types `report`, `plan`, `summary`) — checks required
  metadata fields and required section headings against the live format standards
  (`report-format.md`/`plan-format.md`/`summary-format.md`). This is the same check
  `skill-base.sh` and `orchestrator-postflight.sh` already run (non-blocking) after every
  artifact write. For a specs/**-only phase producing a report/plan/summary, this is a real,
  content-sensitive, non-vacuous check — unlike a gate-3/4 invocation.
- For a `specs/**` file that is not one of those three types (e.g. a handoff JSON, a progress
  file, `issues.jsonl`, a decisions note), the already-defined `prose` verification tier's own
  in-phase check — "diff read-through confirming every changed hunk lies inside a
  comment/string/prose region" — is the correct, already-documented fallback; it requires no
  gate invocation at all, since specs/** markdown has zero compile/elaboration surface by
  construction.

## Decisions

- **Finding (2) requires no code change.** It is already resolved by tasks 766/771. This task
  should record that disposition (with the three-point argument above) and close the
  `Boneyard/**`-exemption question by **declining** to extend the taxonomy — the lint already
  passes, and the write-time hook already guards the future without an exemption.
- **Finding (1)'s primary fix is in `verify-deploy.sh` itself, not only in planning guidance.**
  Gate 4's SKIP guard is demonstrably wrong (mirrors gate 3's correct-but-inapplicable premise);
  correcting it is in scope per the dispatch's SCOPE/NON-GOALS ("make the chosen gate... run real
  checks in a consumer tree," "no change to any gate's pass criteria beyond what (1) and (2)
  name" — this *is* what (1) names).
- **A generic "0 checks ran under `--only-gate`" detection in `verify-deploy.sh` is recommended
  as defense-in-depth**, independent of the gate-4 fix, because 17 other gates carry the same
  source-store-conditioned SKIP guard and a future `--only-gate` selection drawn only from that
  set would still hit the same silent-pass trap. Reusing the script's own existing exit-code-2
  "cannot run, an automated gate MUST treat this as failure" semantics is the lowest-risk
  mechanism (no new exit code to document, and it changes behavior only when `GATES_FILTER` is
  non-empty and `CHECKS` stayed 0 — the default, no-flag full-battery path is never affected,
  since at least gates 1/2/14/16 always contribute checks).
- **`plan-format.md`'s `__FULL_SWEEP__` guidance needs correcting on two axes**: (a) stop
  uniformly recommending `--only-gate 3,4` for a `specs/**`-only phase — name
  `validate-artifact.sh`/the `prose`-tier diff read-through instead; (b) for a genuine
  source-store, non-specs unmapped-path phase, require the guidance to name the resolved
  `source_dir` as an explicit `TARGET` argument, since the dispatch cwd default is silently
  wrong.
- These are plan-phase decisions to execute, not further research questions — this report
  recommends but does not mandate sequencing; per the dispatch, "Each half may be done
  independently."

## Recommendations

1. **Plan phase, Finding (2)**: a documentation-only phase (no source edit) recording the
   already-closed disposition and the taxonomy-extension decline, citing 766/771's artifacts and
   this report's independent re-verification (0 occurrences, confirmed fresh).
2. **Plan phase, Finding (1), source-store edits** (via `source_dir`, never hand-authored under
   `.claude/**`):
   - Remove or correct gate 4's SKIP guard in `verify-deploy.sh` so it invokes
     `check-task-references.sh` against `TARGET` unconditionally (mirroring gates 1/2/14/16's
     no-guard shape); keep gate 3's guard unchanged (it is correct).
   - Add a "0 checks ran while `GATES_FILTER` was non-empty" detection at the end-of-run summary,
     exiting with the script's existing exit-code-2 semantics and a distinguishable message
     (e.g. naming which selected gate id(s) all SKIPped) instead of `PASS -- 0 check(s), 0
     failure(s)`.
   - Correct `plan-format.md`'s `__FULL_SWEEP__` guidance per the two axes in Decisions above.
   - Add or extend `test-verify-deploy-gate-selection.sh` with a case exercising `--only-gate 4`
     against `FIXTURE_CHEAP` (expect a real, non-SKIP, passing check) and a case exercising an
     all-SKIP-only selection (e.g. `--only-gate 3`) against `FIXTURE_CHEAP` (expect the new
     distinguishable non-pass result), so the fix has its own regression net.
3. **Verification for the plan's final phase**: full `verify-deploy.sh --skip-slow` against this
   repo (expect `CHECKS` to increase by exactly one real gate-4 check versus today's baseline,
   with gate 3 still `[SKIP]`), plus `test-verify-deploy-gate-selection.sh` green.
4. Since the gate-4 fix changes `verify-deploy.sh`'s behavior for **every** deploy-consumer repo
   this system deploys into (not only this one), flag in the plan's Risks section that other
   consumer repos may have their own, currently-SKIP-masked task-reference citation debt that
   would newly surface as a real `[FAIL]` once they redeploy — this is the fix working as
   intended, not a regression, but it is a real migration consideration for those repos'
   maintainers, not something this task can resolve on their behalf.

## Risks & Mitigations

- **Risk**: removing gate 4's SKIP guard surfaces real task-reference citation debt in other
  deploy-consumer repos on their next redeploy (this repo's own debt is already 0, but other
  repos sharing this source store have not necessarily run the same cleanup).
  **Mitigation**: this is the intended effect of fixing a gate that previously attested to
  nothing; document it plainly in the plan/summary as an expected, not a regressive, consequence.
  Not a reason to decline the fix — a loud new `[FAIL]` elsewhere is strictly better than a
  silent, uninspected `[SKIP]`.
- **Risk**: a planner, following this report's recommendation, removes gate 4's guard without
  re-auditing the other 17 source-store-conditioned gates, and a future contributor assumes "the
  SKIP pattern is now generally suspect" and strips guards that are actually correct (e.g. gate 5
  or gate 8, which plausibly do need the source store).
  **Mitigation**: this report explicitly scopes the fix to gate 4 only, names the specific
  evidence (`check-extension-docs.sh` errors without `agent-system/extensions`;
  `check-task-references.sh` does not), and flags the other 17 as unaudited rather than
  presumed-safe-to-change.
- **Risk**: the generic "0 checks under `--only-gate`" detection accidentally fires on a
  legitimate use (e.g. a caller intentionally passing a gate id that happens to SKIP everywhere,
  for a reason this report did not anticipate).
  **Mitigation**: no such legitimate use was found in this research — `--only-gate` has exactly
  one documented production consumer (the `plan-format.md` guidance text itself, being corrected
  by this same task) and one test suite, neither of which relies on the current silent-pass
  behavior. The detection is additive and opt-in by construction (it only changes output when
  `GATES_FILTER` is non-empty), so the full, no-flag battery path is unaffected regardless.

## Context Extension Recommendations

- **Topic**: `plan-format.md`'s `__FULL_SWEEP__` guidance does not distinguish "unmapped path
  under the source store" from "unmapped path under `specs/**`" from "unmapped path requiring an
  explicit, non-default `TARGET`."
  **Gap**: the current single sentence ("ordinarily `--only-gate 3,4`") is the only guidance a
  planner sees for every `__FULL_SWEEP__` case, and this research found it silently wrong for two
  of the three sub-cases it is actually asked to cover.
  **Recommendation**: the plan phase for this task should fold the three-way distinction from
  this report's Findings section directly into `plan-format.md`'s own text (not a separate
  context file) — it is one coherent correction to one existing guidance paragraph, not a new
  standing document.

## Appendix

- Commands run (all against this repo's working tree, a deploy consumer):
  `bash .claude/scripts/check-task-references.sh`;
  `bash .claude/scripts/verify-deploy.sh --only-gate 3,4 .`;
  `bash .claude/scripts/check-extension-docs.sh --quiet`.
- Source-store files read (via `.claude-extensions.json`'s `source_dir`,
  `/home/benjamin/.config/nvim/agent-system/extensions/core`): `scripts/verify-deploy.sh` (header,
  `pass`/`fail`/`gate_selected`, gates 1-22's SKIP-guard presence/absence, end-of-run summary),
  `scripts/check-task-references.sh`, `scripts/lib/task-reference-patterns.sh`,
  `scripts/lib/suite-selection-lib.sh`, `scripts/deploy-root-guard.sh`,
  `scripts/tests/test-verify-deploy-gate-selection.sh`, `context/formats/plan-format.md`,
  `context/standards/task-reference-exemptions.md`, `context/standards/shell-script-testing.md`,
  `context/workflows/task-breakdown.md` (grepped, no relevant hits).
- Repo artifacts read: `specs/757_lplus_decidability_successor_task_set/issues.jsonl`,
  `specs/771_task_reference_lint_debt_boneyard_tests/{reports,summaries}/*`,
  `specs/766_clear_task_reference_citation_debt/summaries/*` (via 771's citation),
  `specs/720_promote_fmp_width_refutations_to_evidence/{plans,summaries}/*`, `specs/state.json`.
