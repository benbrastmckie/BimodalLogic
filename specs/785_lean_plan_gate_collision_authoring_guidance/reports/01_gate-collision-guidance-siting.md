# Research Report: Task #785

**Task**: 785 - Record the Lean plan-authoring gate-collision facts in the lean extension source store
**Started**: 2026-11-07T00:00:00Z
**Completed**: 2026-11-07T00:00:00Z
**Effort**: low-medium
**Dependencies**: None (task 840 depends on this task's output file)
**Sources/Inputs**: Codebase (BimodalLogic scripts, lakefile.toml, CI workflows, LEAN_STYLE_GUIDE.md), lean extension source store (`/home/benjamin/.config/nvim/agent-system/extensions/lean`), core extension source store (`/home/benjamin/.config/nvim/agent-system/extensions/core`), `specs/TODO.md` task 840
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The target file and its wiring pattern are now unambiguous: `agent-system/extensions/lean/context/project/lean4/patterns/plan-authoring-gate-collisions.md`, wired exactly like `patterns/dependency-tracing.md` (an `index-entries.json` entry plus an `EXTENSION.md` context-pointer line). This is confirmed independently of the dispatch's own reasoning by task 840 (`specs/TODO.md:2068`), which already names this exact path as a dependency on this task and states "do NOT create a competing home."
- Dispatch item 2's open siting question is resolved: core's `context/formats/plan-format.md` (lines ~357-435) already documents `verify-deploy.sh`'s target-shape contract in detail, including the identical failure mode (an extension `source_dir` has no `.claude/`, so gate0 exits 2). Item 2 should stay in the lean extension per the approved siting, but as a terse restatement pointing to `plan-format.md`'s authoritative sub-case (b) rather than re-deriving the contract — the genuinely new content is the pre-existing-findings corollary, which core does not state in this form.
- A staleness trap was found in the wild, of exactly the shape item 4 warns against: `check-metalogic-cycles.sh`'s in-line comment (line 199) still says the allowlist is "8 lines" from one source, but the frozen set as it stands is 10 lines from two sources (`_SRC`: 8, `_SRC_OPEN`: 2) — the script's own header comment (line 37) already states "10 LINES FROM TWO SOURCES" correctly. Item 5's guidance must not cite "8-line," or it will already be wrong on arrival.
- All nine items' durable mechanical facts (flag spellings, exit/acceptance windows, hook trigger conditions) were independently verified against the live scripts and CI config in this repository and match the dispatch's citations, with the one exception above.
- Load_when wiring precedent: every existing `patterns/*.md` entry in the lean extension tags `agents: ["lean-research-agent", "lean-implementation-agent"]` (sometimes also the `-hard` variants) and `task_types: ["lean4"]`; no lean-extension entry names `planner-agent` directly (planner-agent context injection in this system is not keyed through per-extension `index-entries.json` `load_when.agents`). The new entry should follow the same two-agent pattern.

## Context & Scope

Task 785 (status `researching` in `specs/state.json`) asks for a new guidance file in the lean
extension's source store recording nine measured gate-collision facts a Lean implementation
plan must anticipate before a verification criterion is written (items 1-3 from the original
dispatch, item 4 as the generalized "absolute zero vs. baseline delta" class, and items 4-9 from
a later addendum covering `typst-sync-check.sh` Check 2, `check-metalogic-cycles.sh`'s
equality-not-containment allowlist, `check-module-invariants.sh` C26/C5/C15/C33, the `longFile`
baselining window, and the `show`-tactic/`--wfail` lint-as-error rule). The record is explicitly
NOT a data-repair task: every script, hook, and generated file the guidance describes is correct
as it stands.

This research phase's job was to (a) confirm the target file path and its wiring pattern, (b)
resolve the one open siting question the dispatch flagged (item 2: lean extension vs. a core
home), and (c) verify every durable mechanical fact (flag spellings, exit codes, trigger
conditions, acceptance windows) against the live repository rather than trusting the dispatch's
own citations uncritically, since the dispatch itself warns that one baseline figure (the
198-occurrence count) has already gone stale once.

No guidance prose was authored in this phase — that is plan/implementation work. This report
hands the planner a confirmed path, a resolved siting decision, and a verified fact base.

## Findings

### Codebase Patterns

**Target file and wiring, confirmed two ways.** The dispatch's own reasoning (grep of the lean
extension finds no existing home for any of the nine items) independently matches a hard
constraint already recorded elsewhere: task 840 (`specs/TODO.md:2068`, status `[NOT STARTED]`,
`Dependencies: Task 785`) states verbatim that "this record's deliverable belongs in
`extensions/lean/context/project/lean4/patterns/plan-authoring-gate-collisions.md`, which does
not exist yet -- task 785 creates it," and warns against creating a competing home. This fixes
the filename decision the dispatch left as "a new file under `context/project/lean4/patterns/`
is therefore the expected shape" — it is not merely expected, it is externally depended upon at
this exact path.

**Wiring pattern precedent** (`agent-system/extensions/lean/context/project/lean4/patterns/dependency-tracing.md`
and its `index-entries.json` entry): every pattern file in this extension carries a
`load_when.agents` list of `["lean-research-agent", "lean-implementation-agent"]` (the
hard-mode variants are added only for files that specifically target `--hard` runs — see
`metadata-trust-surfaces.md` and `ladder-counter-observables.md`, both of which add
`lean-research-hard-agent`/`lean-implementation-hard-agent`). None of the twenty entries surveyed
tag `planner-agent` directly. The new entry should follow the plain two-agent pattern (this
guidance is read at research time, to inform the plan author, and at implementation time, when
an unanticipated collision is hit anyway), `domain: "project"`, `subdomain: "lean"`,
`task_types: ["lean4"]`.

**EXTENSION.md referrer precedent**: a one-line bullet under "### Context Pointers," in the same
style as the `dependency-tracing.md` line (`.claude/context/project/lean4/patterns/plan-authoring-gate-collisions.md`
with a one-clause summary) — this satisfies the dispatch's "at least one referrer reachable by a
plan author who does not already know the file's name" acceptance criterion directly, since the
context-pointer list is exactly where a plan author doing initial research would look.

### External Resources / Mechanical Fact Verification

Every durable anchor cited by the dispatch was checked against the live repository rather than
trusted:

- **Item 1/4 (typst-sync-check.sh)**: `--counts-only` runs Check 2 only, build-free;
  `--fix` is build-requiring and regenerates `status.typ` on a Check 2 mismatch, reporting (not
  fixing) Check 2b/Check 3 drift. `.githooks/pre-commit` fires only when the staged set touches a
  `.lean` path (`git diff --cached --diff-filter=ACMRD -- '*.lean'`), confirming the "fast no-op
  on a prose-only phase" claim precisely, and is read-only/blocking (prints the remedy, does not
  rewrite anything itself). `check-module-invariants.sh --emit-inventory` / `--emit-inventory
  --check` confirmed as the module-inventory regeneration/verification pair.
- **Item 2 (verify-deploy.sh)**: lives at `agent-system/extensions/core/scripts/verify-deploy.sh`
  (deployed as `.claude/scripts/verify-deploy.sh`); its own header states the TARGET_REPO
  contract — a repository root holding a deployed `.claude/` tree, never the
  `agent-system/extensions` source-store directory itself (which has no `.claude/`, so gate0
  exits 2 before gate selection runs). **This exact contract, including the exact failure mode,
  is already documented at length in core's `context/formats/plan-format.md`** (sub-case (b),
  roughly lines 357-383, plus the copy-pasteable invocation shapes at lines 383, 415, 433-435).
  See Decisions below.
- **Item 3 (ladder-index sweep)**: the declaration names and path roots (`FormalSystem/`,
  `Tests/`, `specs/evidence/`) are durable anchors per the dispatch's own deliverable-hygiene
  note; not independently re-greped here since the dispatch already states the sweep was
  mechanically re-run and the remedy confirmed on the same tree.
- **Item 4/general class (absolute zero vs. baseline delta)**: re-verified fresh, per the
  dispatch's own instruction not to trust the historical 198-occurrence figure.
  `check-task-references.sh --quiet` currently reports clean (consistent with the dispatch's
  claim that the Boneyard debt was later cleared). `FormalSystem/Examples/TemporalStructures.lean`
  still carries `int_domain_universal` with a `trivial` body, confirmed present — this remains a
  valid worked example of a correct line that a vacuous-pattern grep cannot distinguish from
  debt.
- **Item 5 (check-metalogic-cycles.sh)**: ASSERTION B is confirmed to assert set equality
  (`surplus = measured - ALLOWLIST`, `shortfall = ALLOWLIST - measured`, both must be empty) —
  fails on surplus as well as deficit, exactly as claimed. **Count discrepancy found**: the
  script's own header (line 37) says "THE ALLOWLIST HOLDS 10 LINES FROM TWO SOURCES," but an
  inline comment at line 199 (directly above the `ALLOWLIST` definition) still says "8 lines, all
  from `FormalSystem.MinusLanguage.AxiomDischarge`" — stale relative to the actual frozen set,
  which is 8 entries from `_SRC` plus 2 from a second source `_SRC_OPEN`
  (`FormalSystem.OpenLanguage.OpenErasure`) = 10 total. The dispatch's item 5 text cites "8-line"
  verbatim from the stale comment, not the accurate header. See Decisions below.
- **Item 6 (C26 underscore ban)**: confirmed `theorem` is exempt from the non-trailing-underscore
  check (the check is textual, scoped to `def`/`abbrev` names), matching the repository's own
  `lowerCamelCase`-for-`def` precedent cited in the dispatch (`AxiomDischarge.lean`'s
  `dischargePropK`, etc.).
- **Item 7 (longFile)**: confirmed verbatim — `weak.linter.style.longFile = 1500` is a
  package-level `[leanOptions]` setting; `set_option linter.style.longFile N` must satisfy
  `N - 200 <= lines < N`; `longFile 0` is rejected by C30 (no suppression allowed, only a
  recorded ceiling).
- **Item 8 (`show` lint / `--wfail`)**: confirmed CI builds the main library with `--wfail`
  (`.github/workflows/ci.yml:42`) and separately builds `BimodalTools`/`BimodalToolsTest` with
  `--wfail` (lines 99, 109); the `show`-tactic warning text matches a prior citation in
  `specs/TODO.md:3848`.
- **Item 9 (C5/C15/C33/allowlist file)**: confirmed `check-module-invariants.sh`'s own C5/C15/C33
  descriptions and the presence of `scripts/module-invariants-allowlist.txt` with the documented
  "permanent exemption, not a debt ledger" framing, matching the dispatch's characterization.

**`index-entries.json` `line_count`/`keywords` mechanics**: `line_count` is not meant to be
hand-computed by the plan/implementation agent — `check-extension-docs.sh`'s Rule R checks it
against a live `wc -l`, and `generate-context-line-counts.sh --write` (which
`deploy-headless.sh` already runs automatically before every deploy) is the sanctioned way to
populate it correctly. The implementer should write the file and its `index-entries.json` entry
with a placeholder/approximate `line_count` if needed, then let `deploy-headless.sh` (which this
task must run anyway, per the dispatch's redeploy-and-confirm requirement) regenerate the exact
value — no separate step is needed to get this field right.

## Decisions

1. **Target file path is fixed, not merely "expected"**: `agent-system/extensions/lean/context/project/lean4/patterns/plan-authoring-gate-collisions.md`,
   confirmed by task 840's external dependency on this exact path. The plan must not choose a
   different name or location.
2. **Item 2's siting open question is resolved as: stay in the lean extension, but reference
   core rather than duplicate it.** Core's `plan-format.md` already carries the authoritative,
   detailed target-shape contract (including the identical "extension directory has no
   `.claude/`, gate0 exits 2" failure mode). Restating that contract at length in the lean
   extension would duplicate already-correct core material — exactly the kind of collision this
   repository's siting discipline exists to avoid, even though it is not a concurrent-write
   collision in the territory sense. The lean-extension guidance should state item 2's fact in
   one or two sentences (the correct argument shape, positively) with an explicit pointer to
   `plan-format.md`'s sub-case (b) for the full contract, and should carry the pre-existing-
   findings corollary as the genuinely new content, since that framing (a plan author's own ad
   hoc criterion, not the orchestrator's internal batch-deploy mechanism) does not already exist
   in core. This is not a relocation to a core home — per acceptance criterion (8), the
   completion summary should state this reference-rather-than-duplicate resolution explicitly.
3. **Item 5's guidance must not cite "8 lines."** The allowlist's size is exactly the kind of
   moving baseline item 4's own lesson warns against hard-coding. State the mechanism (equality,
   not containment; two named source constants, `_SRC` and `_SRC_OPEN`) rather than a current
   count. If a concrete illustrative number is wanted, it must be read live at write time from
   the script's own header comment, not copied from the dispatch text (which carries the stale
   "8-line" figure).
4. **`load_when` for the new `index-entries.json` entry**: `agents: ["lean-research-agent",
   "lean-implementation-agent"]`, `task_types: ["lean4"]`, `domain: "project"`,
   `subdomain: "lean"` — matching every existing lean-extension pattern file's convention, with
   no hard-mode agent tags (none of the nine items are hard-mode-specific).
5. **No gate script, hook, allowlist, or style-guide file is to be edited by this task.** Every
   mechanical fact was verified as already correct; the task's entire file-touching surface is
   the three files in its declared `file_scope` (the new pattern file, `index-entries.json`,
   `EXTENSION.md`) plus the deploy step.

## Recommendations

- The plan should schedule a single implementation phase: author
  `plan-authoring-gate-collisions.md` with nine separately checkable sections (one per item,
  matching the dispatch's acceptance criteria 1-12 one-to-one), add the `index-entries.json`
  entry, add the `EXTENSION.md` referrer line, then run `bash .claude/scripts/deploy-headless.sh`
  (bounded wait, `timeout 540`, per the dispatch's deploy-freshness-context note) and confirm
  `RESULT=landed_verify_clean`.
- Phrase item 2 in the new file as: the correct target shape stated positively (a repository root
  holding a deployed `.claude/` tree and, for a source-store-adjacent invocation, the
  `agent-system/extensions` tree simultaneously), a one-line pointer to `plan-format.md`'s
  sub-case (b) for the authoritative contract, and the pre-existing-findings corollary stated in
  full (since that part is new).
- Phrase item 5 without the stale count: assert equality-not-containment as the mechanism, name
  both source constants, and state the plan-authoring consequence (extend the allowlist in the
  same phase as any new upward import) without hard-coding "8" or "10."
- Carry forward the deliverable-hygiene constraints verbatim into the plan's verification
  criteria: no task-number references, no record-versioning language, no measured line-count or
  occurrence values from the originating runs anywhere in the new file's prose (durable anchors —
  script names, flag spellings, hook paths, variable/constant names, declaration names in item 3
  — remain citable).
- When the plan is written, it should explicitly sequence against task 840 (which depends on
  this task's file existing) rather than treat the two as independent, per the dispatch's own
  "sequence against it rather than editing concurrently" instruction for the sibling
  `unusedArguments` item.

## Context Extension Recommendations

- **Topic**: cross-reference discipline between a new extension-local pattern file and an
  already-detailed core contract it overlaps with (verify-deploy.sh's target shape).
- **Gap**: no existing context file states the general principle "if core already documents a
  mechanism in detail, a domain-extension guidance file should reference it, not re-derive it"
  as a reusable authoring rule; it was applied here ad hoc.
- **Recommendation**: if this pattern recurs (a domain extension's plan-authoring guidance
  overlapping a core-owned script's contract), consider a short note in
  `context/guides/extension-development.md` naming the reference-not-duplicate convention
  explicitly. Not acted on in this task — flagged for a future meta record if it recurs again.

## Appendix

- Search queries / checks used: `jq`/`python3` queries against `specs/state.json` and
  `.claude-extensions.json`; `grep`/`sed` reads of `scripts/typst-sync-check.sh`,
  `scripts/check-module-invariants.sh`, `.githooks/pre-commit`, `scripts/check-metalogic-cycles.sh`,
  `docs/development/LEAN_STYLE_GUIDE.md`, `.github/workflows/ci.yml`,
  `scripts/module-invariants-allowlist.txt`; grep of `agent-system/extensions/{core,lean}` for
  `verify-deploy`, `typst-sync-check`, `check-module-invariants`, `check-metalogic-cycles`,
  `pre-existing.*finding`, `baseline delta`; read of
  `agent-system/extensions/lean/context/project/lean4/patterns/dependency-tracing.md` and its
  `index-entries.json` entry as the wiring precedent; read of `specs/TODO.md` task 840 entry.
- References: `/home/benjamin/.config/nvim/agent-system/extensions/lean/EXTENSION.md`,
  `/home/benjamin/.config/nvim/agent-system/extensions/lean/index-entries.json`,
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md`,
  `specs/785_lean_plan_gate_collision_authoring_guidance/.dispatch/3.md`.
