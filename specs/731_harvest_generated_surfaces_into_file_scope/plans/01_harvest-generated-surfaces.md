# Implementation Plan: Task #731

- **Task**: 731 - Make plan-time file_scope harvest include the generated surfaces that any .lean edit forces
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/731_harvest_generated_surfaces_into_file_scope/reports/01_harvest-generated-surfaces.md
- **Artifacts**: plans/01_harvest-generated-surfaces.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

`plan-file-scope-harvest.sh` is extended with a single post-processing stage that fires only when
the harvested path list already contains at least one `.lean` path AND the repository actually
carries the two generators in question. When it fires it appends `typst/generated/status.typ`,
every generated-inventory README on the edited paths' directory-ancestor chains, and two
narrow-glob surfaces (`automation-module-map.typ`, `machine-appendix.{jsonl,typ}`). Because seven
independent consumers already shell out to this one script as a subprocess, no caller changes.
The surface-detection logic deliberately mirrors `check-module-invariants.sh`'s own marker
parsing — anchored `BEGIN GENERATED: inventory` regex, fence awareness, the same directory
exclusions — so the harvester's notion of "generated surface" cannot drift from the generator's.

### Research Integration

The report's four load-bearing findings are carried into the phase structure directly:

- **`status.typ` is forced by essentially any `.lean` edit**, because
  `FORMALSYSTEM_FILE/LINE_COUNT`, `TESTS_FILE/LINE_COUNT`, and `TOOLS_FILE/LINE_COUNT` cover the
  *entirety* of `FormalSystem/`, `Tests/`, and `BimodalTools/` recursively. This justifies the
  unconditional (gate-subject) append in Phase 2.
- **The README-inventory surface is not a fixed 2-file set** but a directory-ancestor-chain
  membership test on each block's `dir=` token. The report verified this reproduces exactly the
  3-README set the second precedent task actually had to regenerate, including the
  pinned-`../FormalSystem.lean`-row edge case, with no false positives. Phase 3 implements the
  plain ancestor-chain test and deliberately does not replicate `rows=`/`cols=` semantics.
- **Two further surfaces are narrow, not universal**: `automation-module-map.typ` (a three-glob
  scope) and `machine-appendix.{jsonl,typ}` (tied to `Axioms.lean`/`Derivation.lean`'s constructor
  blocks, and costly to regenerate because it needs a Lean build). Phase 4 appends both, each
  behind its own glob gate rather than alongside `status.typ`.
- **Capability gating, not task-type gating**, is the sibling-repo protection: probe for
  `scripts/check-module-invariants.sh` and `scripts/typst-sync-check.sh` at the repo root and skip
  the entire addition if either is absent. Phase 1 implements this.

Three things this plan establishes that the report did not:

1. **Fence awareness is mandatory, not optional.** `check-module-invariants.sh` toggles an
   `in_fence` flag and refuses to match `BEGIN_RE` inside a fenced block. Without the same
   behavior the scan picks up `docs/reference/readme-standard.md`, whose line-start
   `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation -->` sits inside a
   ` ```markdown ` fence as documentation of the marker syntax. That file is a false positive the
   generator itself excludes.
2. **There are seven consumers, not four.** Beyond `orchestrator-postflight.sh`,
   `reconcile-task-status.sh`, `skill-base.sh`, and `skill-reviser/SKILL.md`, the string also
   appears in `update-task-status.sh`, `backfill-file-scope.sh`, and `orchestrate-batch-admit.sh`
   (the last as advisory remedy text only). This strengthens the single-point-fix argument rather
   than changing it.
3. **The appended surfaces are shared, and `file_scope` is what the overlap machinery reads.**
   See Decisions and Risks below — this is the one genuinely new consequence found at plan time.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- Extend `plan-file-scope-harvest.sh` (source store) so a harvest whose result contains any
  `.lean` path also contains the generated surfaces that `.lean` edit mechanically forces.
- Make the addition inert in a repository lacking the two generators, and inert for a plan with no
  `.lean` path at all.
- Mirror `check-module-invariants.sh`'s marker parsing rather than re-deriving it, so the two
  cannot drift.
- Prove the fix against both precedent plans: re-running the harvester on them must now yield the
  surfaces each had to add by hand.
- Lock the behavior into `test-plan-file-scope-harvest.sh` so the next change cannot silently
  regress it.

**Non-Goals**:

- No change to any generator or to what it emits.
- No change to `typst-sync-check.sh`'s pre-commit behavior — it is correctly refusing the commit.
- No retroactive edit to either precedent task's `file_scope`.
- No change to any of the seven consumers of the harvester.
- No change to `scripts/lib/file-scope-overlap.sh` or `task-lock.sh` (see Risks: the parallelism
  consequence is documented and accepted, not engineered around).
- No edit to `.claude/context/formats/plan-format.md` — a concurrent sibling task declares it.

## Decisions

- **Mechanism: extend the harvester, not the plan template.** The dispatch prefers the mechanical
  option and the evidence is decisive: the checklist approach was effectively tried once (the
  second precedent task named `status.typ` in its own plan after being forewarned) and it still
  missed the *other* generated surface. A reminder that works only for the surface you already
  know about is not a fix.
- **Append rather than annotate.** `file_scope` is schema-typed as a flat `array` of `string`
  (`context/schemas/state-schema.json`, `projectEntry.properties.file_scope`), with no per-entry
  kind or provenance field. Marking appended surfaces as "shared/advisory" would require a schema
  change and a change to every overlap consumer — out of scope. The appended paths are ordinary
  `file_scope` entries.
- **Accept the overlap consequence instead of exempting the shared surfaces.** Two concurrent
  Lean tasks will now both carry `typst/generated/status.typ` and the root `README.md`, so
  `orchestrate-batch-admit.sh` will return a `file_scope_collision` DEFER for the second one and
  `task-lock.sh` will see contention. This is not a false positive: both tasks really do
  regenerate `status.typ`, and both really do fight the same pre-commit gate for it. Serializing
  them is the correct outcome, and `batch-orchestration-guardrails.md` already treats
  serialization to width 1 as a normal batching result rather than a failure. Adding a
  shared-surface exclusion list to `scripts/lib/file-scope-overlap.sh` would suppress a real
  collision in the one library that `task-lock.sh` and three other call sites splice verbatim —
  far more blast radius than this task's problem warrants.
- **Mirror the generator's parsing; do not reimplement its semantics.** The scan replicates
  `BEGIN_RE` (anchored, `-->`-terminated), the `in_fence` toggle, and `markdown_targets()`'s
  directory exclusions (`.git`, `specs`, `.claude`, `.lake`, `node_modules`), and then does a
  plain string-equality ancestor-chain test on the `dir=` token. It deliberately does *not* read
  `rows=`, `cols=`, `filter=`, `sort=`, or the recursive-aggregation behavior in `live_walk.py`:
  the report demonstrated the plain test already reproduces the observed set, and over-inclusion
  in a prospective, non-filesystem-validated field is cheap.
- **Resolve the repo root from the plan file's own directory, with an env override.** The script
  today has no filesystem dependency beyond its single argument, and its test suite drives the
  *source-store* copy — which lives in a different git repository that has no
  `scripts/check-module-invariants.sh`, so the capability gate there would close and the new
  behavior would be untestable. `PLAN_FILE_SCOPE_HARVEST_ROOT` makes the new logic drivable
  against a synthetic fixture repo without threading a flag through seven callers.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Appended shared surfaces make concurrent Lean tasks collide in `batch-admit`/`task-lock`, serializing a batch that previously ran wide | M | H | Accepted deliberately (see Decisions); documented in the harvester header and in `state-management-schema.md`'s file-scope section so the next reader of a `file_scope_collision` on `status.typ` understands why it is there and that it is genuine |
| Fence-unaware marker scan picks up `docs/reference/readme-standard.md` and any future doc that quotes the marker syntax | M | H | Phase 3 implements the `in_fence` toggle exactly as `check-module-invariants.sh` does, and Phase 3's test asserts a fenced marker in a fixture doc contributes nothing |
| New repo-root dependency in a script whose own test suite advertises "no bogus-root risk" | M | M | Root resolution is itself fail-soft: `git -C "$(dirname "$PLAN_FILE")" rev-parse --show-toplevel`, then a CWD-based retry, then *skip the entire addition* — never an error, never a guessed root. The capability probe is a second independent guard |
| Over-firing on a `general`/`markdown`/`meta` plan that merely mentions a `.lean` path | L | M | The trigger is "the harvested array contains a `*.lean` path", which is exactly the condition under which the generators are genuinely forced; the no-`.lean` no-op case is a dedicated regression test in Phase 3 |
| Repo-wide markdown grep on every harvest call adds latency to plan postflight, reconcile, reviser, and backfill | L | M | The scan runs only after the `.lean` short-circuit, over ~40 markdown files with the heavy directories pruned; the output feeds lake-build-backed gates whose cost dominates it by orders of magnitude. Phase 5 records a wall-clock figure rather than asserting "fast" |
| Territory collision with the concurrent sibling task holding `plan-format.md`, `update-task-status.sh`, `skill-base.sh`, `orchestrator-postflight.sh` | M | L | This plan's declared scope intersects none of them: the contract documentation goes in the harvester header and `state-management-schema.md`, and the single-point fix needs no caller change. Phase 5 re-reads every file immediately before editing per the dispatch's concurrency note |
| Deploy step (`deploy-headless.sh`) rewrites the whole `.claude/` tree, far beyond this task's scope | L | M | `.claude/` is gitignored at this repo root (`.gitignore:106`), so the deploy tree is never staged here; the committed change is the source-store edit in its own repository. Deploy is a propagation step, not an edit |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Every phase edits the same single script, so the chain is strictly linear by construction — no
two phases may run in parallel.

### Phase 1: Root resolution, capability gate, and fixture harness [COMPLETED]

**Goal**: Give the harvester a fail-soft repo root and a capability probe, plus the test-side
machinery to drive both, while leaving stdout byte-identical in every existing case.

**Tasks**:

- [x] Re-read the source-store harvester immediately before editing (concurrency note). *(completed)*
- [x] Add a `resolve_repo_root()` helper: honor `PLAN_FILE_SCOPE_HARVEST_ROOT` if set and a *(completed)*
      directory; else `git -C "$(dirname "$PLAN_FILE")" rev-parse --show-toplevel`; else
      `git rev-parse --show-toplevel` from CWD; else echo nothing and return non-zero. Never
      `exit`, never write to stderr on the empty case — an unresolvable root is a skip, not an
      error.
- [x] Add a `generated_surfaces_available()` helper returning success only when BOTH *(completed)*
      `$root/scripts/check-module-invariants.sh` and `$root/scripts/typst-sync-check.sh` are
      regular files.
- [x] Add the post-processing stage shell: capture the existing pipeline's JSON into a variable, *(completed)*
      and emit it unchanged unless (a) the array contains at least one entry matching `*.lean`,
      (b) a root resolved, and (c) the capability probe passed. Append nothing yet.
- [x] Extend the header comment block with a new "Generated-surface appending" subsection stating *(completed)*
      the trigger condition, the two guards, the env override, and the
      `file_scope`-overlap consequence from Decisions.
- [x] In `tests/test-plan-file-scope-harvest.sh`, add a `make_fake_repo()` helper that mktemps a *(completed)*
      directory containing `scripts/check-module-invariants.sh` and `scripts/typst-sync-check.sh`
      stubs plus a `specs/` subdirectory for fixture plans, and a `make_bare_repo()` helper that
      creates the same tree *without* the two scripts.
- [x] Add Case 11: a `.lean`-containing fixture plan under `make_bare_repo()` (capability gate *(completed)*
      closed) returns exactly the same array as it does with no root at all.
- [x] Add Case 12: `PLAN_FILE_SCOPE_HARVEST_ROOT` pointing at a nonexistent path falls back *(completed)*
      without error and exits 0.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-plan-file-scope-harvest.sh,test-backfill-file-scope.sh,test-skill-base-lifecycle.sh` is the covering check — `suite_selection_select` resolves `scripts/plan-file-scope-harvest.sh` to exactly those three suites, and this phase changes one file with no externally visible contract change (stdout is byte-identical in every pre-existing case).

**Scope Hypothesis**: Seven files reference `plan-file-scope-harvest` and this phase asserts none
of them needs to change. Confirm at implementation time with
`grep -rln "plan-file-scope-harvest" .claude/ --include="*.sh" --include="*.md"` and verify each
hit is either the script itself, its two test suites, a caller invoking it as an unchanged
subprocess, or prose.

**Files to modify**:

- `agent-system/extensions/core/scripts/plan-file-scope-harvest.sh` - add root resolution,
  capability probe, inert post-processing stage, header documentation
- `agent-system/extensions/core/scripts/tests/test-plan-file-scope-harvest.sh` - add fake-repo
  helpers and Cases 11-12

**Verification**:

- `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-plan-file-scope-harvest.sh,test-backfill-file-scope.sh,test-skill-base-lifecycle.sh`
  exits 0 with every pre-existing case still passing.
- Diffing the harvester's output for both precedent plans against the baselines recorded in the
  research report's Appendix shows no change yet.

---

### Phase 2: Append `typst/generated/status.typ` [NOT STARTED]

**Goal**: The one surface the dispatch's evidence shows recurring in both precedents is appended
whenever a `.lean` path is harvested in a capable repo.

**Tasks**:

- [ ] Inside the gated stage, append the literal `typst/generated/status.typ` when
      `$root/typst/generated/status.typ` exists as a regular file.
- [ ] Re-sort and re-deduplicate through the same `jq ... unique` so output ordering stays a
      single sorted set rather than "harvested set, then appendix".
- [ ] Add Case 13: a fixture plan whose only entry is `FormalSystem/Foo.lean`, driven against a
      `make_fake_repo()` that contains `typst/generated/status.typ`, yields exactly
      `["FormalSystem/Foo.lean","typst/generated/status.typ"]`.
- [ ] Add Case 14: the same fixture against a fake repo *without* `typst/generated/status.typ`
      yields only the harvested path (existence-conditional, per the research recommendation).
- [ ] Add Case 15: a fixture plan with only `.md` and `.sh` entries, in a fully capable fake repo,
      appends nothing — the no-`.lean` regression guard.

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: Same three-suite `run-all.sh --only` selection covers this file, and the
change is one append inside the gate established in Phase 1 — no new surface, no new caller
contract.

**Files to modify**:

- `agent-system/extensions/core/scripts/plan-file-scope-harvest.sh` - append `status.typ` under
  the gate
- `agent-system/extensions/core/scripts/tests/test-plan-file-scope-harvest.sh` - add Cases 13-15

**Verification**:

- The three-suite `run-all.sh --only` selection exits 0.
- Running the harvester against both precedent plans in the real repo now shows
  `typst/generated/status.typ` present in both outputs and nothing else changed yet.

---

### Phase 3: Ancestor-chain generated-README scan [NOT STARTED]

**Goal**: Every README whose generated-inventory block can go stale from an edited `.lean` path is
appended, derived by mirroring the generator's own marker parsing.

**Tasks**:

- [ ] Add a `generated_inventory_readmes()` helper that walks `$root` for `*.md` files, pruning
      `.git`, `specs`, `.claude`, `.lake`, and `node_modules` exactly as the generator's
      `markdown_targets()` does.
- [ ] For each candidate, scan lines with a fence toggle (`^[ \t]*```` toggles `in_fence`) and
      match only non-fenced lines against the anchored marker pattern equivalent to the
      generator's `BEGIN_RE`; extract the `dir=` token with the same whitespace-split
      `key=value` option parsing the generator's `parse_opts()` uses.
- [ ] Emit `<repo-relative markdown path>\t<dir value>` pairs; build the edited paths' self-and-
      ancestor directory chain (each harvested `.lean` path's `dirname`, then each parent up to
      and including `.`/the repo root), and append every markdown path whose `dir=` value equals
      a chain member by exact string comparison after normalizing a trailing `/`.
- [ ] Add Case 16: a fake repo with generated-inventory READMEs registered at three nesting levels
      plus two deeper levels with no registration; a fixture plan naming one deep `.lean` file
      yields exactly the three registered READMEs and neither unregistered level.
- [ ] Add Case 17: the same fake repo gains a doc file whose line-start marker sits inside a
      ` ```markdown ` fence; assert it is NOT appended (fence awareness).
- [ ] Add Case 18: a fake repo with a README registered for a *sibling* directory not on the
      chain; assert it is NOT appended (string equality, not prefix matching).
- [ ] Add Case 19: a hand-maintained `<!-- INVENTORY: hand-maintained (dir=...) -->` opt-out
      marker is NOT treated as a generated block.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: Same three-suite `run-all.sh --only` selection covers this file, and the
scan's correctness is fully observable from fixture-repo assertions (Cases 16-19) plus the
precedent-plan replay — no other module's behavior changes.

**Scope Hypothesis**: This phase asserts the ancestor-chain test yields exactly `README.md`,
`FormalSystem/README.md`, and `FormalSystem/Metalogic/README.md` for a `.lean` file under
`FormalSystem/Metalogic/Decidability/RaySummary/`. Confirm at implementation time by running the
modified harvester against `specs/750_w_run_layer_closure_wide_lift/plans/01_w-run-layer-ladder-scheme.md`
in the real repo and diffing the appended set against those three paths; a fourth README or a
missing one means the chain construction or the `dir=` comparison is wrong, not that the
hypothesis is merely imprecise.

**Files to modify**:

- `agent-system/extensions/core/scripts/plan-file-scope-harvest.sh` - add the fence-aware marker
  scan and ancestor-chain membership test
- `agent-system/extensions/core/scripts/tests/test-plan-file-scope-harvest.sh` - add Cases 16-19

**Verification**:

- The three-suite `run-all.sh --only` selection exits 0 with Cases 16-19 passing.
- Real-repo replay on the second precedent plan appends exactly the three READMEs named in the
  Scope Hypothesis, and `docs/reference/readme-standard.md` is absent from the output.

---

### Phase 4: Narrow-glob conditional surfaces [NOT STARTED]

**Goal**: The two genuinely conditional surfaces are appended only on a glob match, so a plan that
cannot make them stale does not carry them.

**Tasks**:

- [ ] Append `typst/generated/automation-module-map.typ` only when a harvested path matches
      `FormalSystem/Automation/Tactics/*.lean`, `FormalSystem/Automation/ProofSearch/*.lean`, or
      equals `FormalSystem/Automation/SuccessPatterns.lean` — the generator's own declared glob
      scope, which excludes `Boneyard/`.
- [ ] Append `typst/generated/machine-appendix.jsonl` and `typst/generated/machine-appendix.typ`
      only when a harvested path equals `FormalSystem/ProofSystem/Axioms.lean` or
      `FormalSystem/ProofSystem/Derivation.lean`.
- [ ] Keep both appends existence-conditional on the file being present under `$root`, matching
      Phase 2's treatment of `status.typ`.
- [ ] Document in the header subsection why these two are glob-gated and `status.typ` is not, and
      that `machine-appendix` regeneration needs a Lean build (`lake env lean --run`), not a
      line-count scan — a cost the implementer of a future Axioms-touching task should expect.
- [ ] Add Case 20: a fixture naming `FormalSystem/Automation/Tactics/Foo.lean` appends
      `automation-module-map.typ`; a fixture naming `FormalSystem/Automation/Other/Foo.lean` does
      not.
- [ ] Add Case 21: a fixture naming `FormalSystem/ProofSystem/Axioms.lean` appends both
      `machine-appendix` paths; a fixture naming `FormalSystem/ProofSystem/Other.lean` appends
      neither.

**Timing**: 45 minutes

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: Same three-suite `run-all.sh --only` selection covers this file, and both
appends are glob-gated additions inside the already-tested stage, each with a positive and a
negative fixture case.

**Scope Hypothesis**: This phase asserts the `automation-module-map.typ` scope is exactly those
three globs and the `machine-appendix` scope is exactly those two files. Confirm at implementation
time by re-reading the header comments of `scripts/typst-module-map.sh` and
`scripts/typst-machine-appendix.sh` (and `typst-sync-check.sh`'s Check 2b/Check 3 bodies) rather
than trusting this plan's restatement of them.

**Files to modify**:

- `agent-system/extensions/core/scripts/plan-file-scope-harvest.sh` - add the two glob-gated
  appends and their header documentation
- `agent-system/extensions/core/scripts/tests/test-plan-file-scope-harvest.sh` - add Cases 20-21

**Verification**:

- The three-suite `run-all.sh --only` selection exits 0 with Cases 20-21 passing.
- Replay on both precedent plans shows neither narrow surface appended (neither precedent touches
  the Automation globs or the ProofSystem pair), confirming the gates do not over-fire.

---

### Phase 5: Documentation sync, deploy, precedent verification, full gate [NOT STARTED]

**Goal**: The new contract is written down where its consumers will look, the change is propagated
into the deploy tree, the dispatch's scope item 4 is satisfied against both precedent plans, and
the complete gate set is observed green.

**Tasks**:

- [ ] Re-read `context/reference/state-management-schema.md`'s file-scope section immediately
      before editing (concurrency note) and add a short subsection stating that a harvested
      `file_scope` for a `.lean`-touching plan also carries the generated surfaces those edits
      force, that these are ordinary entries the overlap machinery reads, and that a
      `file_scope_collision` on `typst/generated/status.typ` between two Lean tasks is therefore
      expected and genuine.
- [ ] Verify the harvester's header subsection written across Phases 1-4 reads as one coherent
      contract statement rather than four appended fragments; condense if not.
- [ ] Deploy: `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/deploy-headless.sh`
      (default non-destructive resync) and confirm
      `.claude/scripts/plan-file-scope-harvest.sh` now matches the source-store copy.
- [ ] Precedent verification (dispatch scope item 4): run the deployed harvester against
      `specs/749_c_bound_half_model_a_presentation_size/plans/01_c-bound-half-model-a.md` and
      `specs/750_w_run_layer_closure_wide_lift/plans/01_w-run-layer-ladder-scheme.md`; record both
      full outputs in the completion summary and assert each now contains
      `typst/generated/status.typ`, `README.md`, `FormalSystem/README.md`, and
      `FormalSystem/Metalogic/README.md`, with every path from the research report's recorded
      baseline still present.
- [ ] Measure and record the wall-clock delta of one harvest call on the second precedent plan
      (before vs. after), so the latency claim in the Risks table is a number rather than an
      adjective.
- [ ] Confirm no retroactive mutation happened: `git diff` shows no change to either precedent
      task's `file_scope` in `specs/state.json` (non-goal check).
- [ ] Run the complete gate set and observe it green.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:

- `agent-system/extensions/core/context/reference/state-management-schema.md` - file-scope section
  gains the generated-surface subsection
- `agent-system/extensions/core/scripts/plan-file-scope-harvest.sh` - header coherence pass only

**Verification**:

- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete gate set this aggregator runs,
  not a hand-picked subset of it, and not under `--skip-slow` or `--only-gate`.
- Both precedent-plan replays contain all four expected surfaces, with their recorded baselines
  preserved.
- `git diff -- specs/state.json` shows no `file_scope` change for either precedent task.

---

## Testing & Validation

- [ ] Every pre-existing case (1-10) in `test-plan-file-scope-harvest.sh` still passes unchanged.
- [ ] New cases 11-21 pass: capability gate closed, unresolvable root, `status.typ` present and
      absent, no-`.lean` no-op, three-level ancestor chain, fenced-marker exclusion, sibling-
      directory exclusion, hand-maintained opt-out exclusion, both narrow globs positive and
      negative.
- [ ] `bash agent-system/extensions/core/scripts/tests/run-all.sh --only test-plan-file-scope-harvest.sh,test-backfill-file-scope.sh,test-skill-base-lifecycle.sh`
      exits 0 after each of Phases 1-4.
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0 at Phase 5.
- [ ] Both precedent plans replay with the four expected generated surfaces appended.

## Artifacts & Outputs

- Modified `plan-file-scope-harvest.sh` in the source store, propagated to `.claude/scripts/`.
- Eleven new regression cases in `test-plan-file-scope-harvest.sh`.
- A new generated-surface subsection in `state-management-schema.md`'s file-scope documentation.
- A completion summary recording both precedent-plan replay outputs verbatim and the measured
  latency delta.

## Rollback/Contingency

The entire change is confined to one script plus its test suite and one documentation section, all
in the source-store git repository (`/home/benjamin/.config/nvim`), where each phase commits
separately. Reverting is `git revert` of the relevant source-store commits followed by a
`deploy-headless.sh` resync; the deploy tree at `.claude/` is gitignored here and carries no state
of its own. No generator, consumer, or task state is touched, so a revert cannot leave a
half-migrated consumer behind. If the overlap consequence in the Risks table proves more
disruptive in practice than the Decisions section anticipates, the narrowest retreat is to drop
the root-`README.md`-level and `status.typ` appends while keeping the deeper per-module READMEs —
that preserves most of the fix while removing the two paths every Lean task would share.
