# Implementation Summary: Task #731

- **Task**: 731 - Make plan-time file_scope harvest include the generated surfaces that any .lean edit forces
- **Status**: [COMPLETED]
- **Started**: 2026-10-10T19:28:00Z
- **Completed**: 2026-10-10T21:20:00Z
- **Effort**: ~4.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_harvest-generated-surfaces.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Extended `plan-file-scope-harvest.sh` (in the `agent-system` source store at
`/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/`) with a capability-gated
post-processing stage that appends the generated/derived surfaces any `.lean` edit mechanically
forces: the typst status table, every generated-inventory README on the edited file's
ancestor-directory chain, and two narrow-glob typst surfaces (the automation module map and the
machine-readable axiom appendix). The addition is inert in a repository lacking the two
generators it mirrors (`check-module-invariants.sh`, `typst-sync-check.sh`), and in a plan with
no `.lean` path at all. Deployed into BimodalLogic and verified against both precedent tasks
(749, 750) that originally had to add these surfaces to their `file_scope` by hand.

## What Changed

- `agent-system/extensions/core/scripts/plan-file-scope-harvest.sh` (source store) — added
  `resolve_repo_root()` (fail-soft, `PLAN_FILE_SCOPE_HARVEST_ROOT` override, git-resolve
  fallback), `generated_surfaces_available()` (capability gate), `generated_inventory_readmes()`
  (fence-aware `BEGIN_RE`/`dir=` ancestor-chain scan mirroring `check-module-invariants.sh`'s own
  parsing), and the gated append logic for `status.typ`, the ancestor-chain READMEs, and the two
  narrow-glob surfaces. Header gains a "Generated-surface appending" subsection documenting the
  trigger, both guards, the env override, the `file_scope`-overlap consequence, and the
  universal-vs-narrow gating distinction.
- `agent-system/extensions/core/scripts/tests/test-plan-file-scope-harvest.sh` (source store) —
  added `make_fake_repo()`/`make_bare_repo()` fixture helpers and 11 new regression cases
  (11-21) covering the capability gate, root-resolution fallback, each surface's
  existence-conditional append, the no-`.lean` no-op, the three-level ancestor chain, fence
  exclusion, sibling-directory exclusion, hand-maintained opt-out exclusion, and both narrow
  globs' positive/negative cases. All 32 cases (21 pre-existing + 11 new) pass.
- `agent-system/extensions/core/context/reference/state-management-schema.md` (source store) —
  File Scope Field section gains a subsection recording that generated-surface entries are
  ordinary `file_scope` entries with no provenance tag, and that a `file_scope_collision` on a
  shared generated surface between two concurrent `.lean`-touching tasks is expected and genuine.
- Deployed into BimodalLogic via `deploy-headless.sh` (`RESULT=landed_verify_clean`); the three
  deployed files are byte-identical to their source-store counterparts.
- `specs/731_harvest_generated_surfaces_into_file_scope/plans/01_harvest-generated-surfaces.md`
  (this repo) — all 5 phases marked `[COMPLETED]`, checklist items checked off with completion/
  deviation annotations.

## Decisions

- Mechanism: extended the harvester (not the plan template), per the dispatch's own evidence
  that the checklist approach had already been tried once and still missed a second surface.
- Capability-gated, not task-type-gated: probes for the two generator scripts at the resolved
  repo root, so the addition is inert in any sibling repository lacking them.
- Ancestor-chain README scan mirrors `check-module-invariants.sh`'s own `BEGIN_RE`/fence/`dir=`
  parsing exactly (implemented as an inline python3 heredoc for parity with the generator's own
  language), never its rendering semantics (`rows=`/`cols=`/`filter=`/`sort=`).
- The two narrow surfaces (`automation-module-map.typ`, `machine-appendix.{jsonl,typ}`) are
  glob-gated to their own generators' declared scope rather than appended unconditionally, since
  most `.lean` edits cannot make them stale.
- The `file_scope`-overlap consequence (two concurrent `.lean`-touching tasks will now collide
  on shared generated surfaces in `orchestrate-batch-admit.sh`/`task-lock.sh`) is accepted and
  documented, not engineered around — serializing such tasks is the correct outcome.

## Plan Deviations

- **Phase 1**: Cases 11-21 (and their fixture helpers) were drafted together in one batched edit
  for coherence, rather than incrementally across Phases 1-4 as the plan's per-phase Tasks lists
  specify. Correctness was preserved by splitting the batched cases back into phase-appropriate
  groups before each phase's own commit, verifying the suite was green at each checkpoint before
  committing.
- **Phase 3, Task 3.3**: implemented as a direct ancestor-chain-set membership test rather than
  materializing an intermediate `<path>\t<dir value>` pairs list; output and behavior are
  identical, confirmed by Cases 16-19 and the real-repo replay.
- **Phase 5**: discovered and fixed a genuine environment-dependency defect in Cases 11-12
  (relied on `resolve_repo_root()`'s CWD-based git fallback silently resolving to whatever repo
  the test suite was invoked from) during this phase's own full-gate run against the deployed
  tree. Not a plan deviation in the narrow sense, but recorded here for completeness — this is
  exactly the class of gap Phase 5's "run the complete gate set and observe it green" step exists
  to catch, and it was caught before the task closed.

## Verification

- Build: N/A (meta task; no Lean build required)
- Tests: Passed — 32/32 cases in `test-plan-file-scope-harvest.sh`; three-suite
  `run-all.sh --only test-plan-file-scope-harvest.sh,test-backfill-file-scope.sh,test-skill-base-lifecycle.sh`
  exits 0; full `bash .claude/scripts/verify-deploy.sh` exits 0 (14 checks, 0 failures) — all
  confirmed in both the source-store checkout and the deployed BimodalLogic tree.
- Files verified: Yes (all created/modified files confirmed present and content-correct; deployed
  copies confirmed byte-identical to source-store originals via `diff -q`).

### Precedent-plan replay (dispatch scope item 4)

Both plans replayed against the deployed harvester:

- `specs/749_c_bound_half_model_a_presentation_size/plans/01_c-bound-half-model-a.md` →
  `["FormalSystem/Metalogic/Decidability/RaySummary.lean","FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean","FormalSystem/Metalogic/Decidability/RaySummary/README.md","FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean","FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean","FormalSystem/Metalogic/README.md","FormalSystem/README.md","README.md","Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean","docs/theorem-index.md","scripts/check-evidence-probes.sh","scripts/check-module-invariants.sh","specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean","specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean","typst/generated/status.typ"]`
- `specs/750_w_run_layer_closure_wide_lift/plans/01_w-run-layer-ladder-scheme.md` →
  `["FormalSystem.lean","FormalSystem/Metalogic/Decidability/RaySummary.lean","FormalSystem/Metalogic/Decidability/RaySummary/README.md","FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean","FormalSystem/Metalogic/README.md","FormalSystem/README.md","README.md","Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean","docs/theorem-index.md","scripts/check-evidence-probes.sh","scripts/check-module-invariants.sh","specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean","typst/generated/status.typ"]`

Both now contain `typst/generated/status.typ`, `README.md`, `FormalSystem/README.md`, and
`FormalSystem/Metalogic/README.md` in addition to every path from the pre-fix baseline recorded
in the research report's Appendix. Neither narrow surface fires on either precedent (neither
touches the Automation globs or the ProofSystem Axioms/Derivation pair).

Latency: one harvest call on task 750's plan measured ~0.147s wall-clock at Phase 1 (gate
present, no appends) and ~0.129s at Phase 5 (all four surface categories active) — the
difference is within measurement noise, confirming the Risks table's "orders of magnitude
smaller than lake-build-backed gates" claim.

Non-retroactive-mutation check: `git diff -- specs/state.json` shows no `file_scope` change for
either precedent task.

## Impacts

- Every future plan that harvests a `.lean` path in this repository will now automatically carry
  the generated surfaces that edit forces, eliminating the recurring undeclared-scope-extension
  pattern this task was opened to fix.
- Two concurrent `.lean`-touching tasks will now collide on shared generated surfaces (e.g.
  `typst/generated/status.typ`) in `orchestrate-batch-admit.sh`'s `file_scope_collision` check
  and in `task-lock.sh`, serializing them. This is documented as an accepted, correct
  consequence in `state-management-schema.md`'s file-scope section, not a defect.
- Seven existing consumers of `plan-file-scope-harvest.sh` (`orchestrator-postflight.sh`,
  `reconcile-task-status.sh`, `skill-base.sh`, `skill-reviser/SKILL.md`, `update-task-status.sh`,
  `backfill-file-scope.sh`, `orchestrate-batch-admit.sh`) need no change — they all invoke it as
  an unchanged subprocess.

## Follow-ups

- None required by this task's scope. The plan's own Rollback section names a narrowest-retreat
  path (drop the root-`README.md`-level and `status.typ` appends while keeping deeper per-module
  READMEs) should the overlap consequence prove more disruptive in practice than anticipated —
  not exercised here, since no such disruption was observed.

## References

- Plan: `specs/731_harvest_generated_surfaces_into_file_scope/plans/01_harvest-generated-surfaces.md`
- Research: `specs/731_harvest_generated_surfaces_into_file_scope/reports/01_harvest-generated-surfaces.md`
- Progress files: `specs/731_harvest_generated_surfaces_into_file_scope/progress/phase-{1..5}-progress.json`
- Handoffs: `specs/731_harvest_generated_surfaces_into_file_scope/handoffs/phase-{2..5}-handoff-*.md`
- Issue log: `specs/731_harvest_generated_surfaces_into_file_scope/issues.jsonl`
- Source-store commits (`/home/benjamin/.config/nvim`): `b9ebe1d42`, `bb29ef7c0`, `3c7a5a366`,
  `a9659b9ef`, `768420c41`
