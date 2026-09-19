# Implementation Summary: Task #627

- **Task**: 627 - Research cslib as a Lean engineering reference model and produce a publication-standard refactor plan for BimodalLogic / FormalSystem
- **Status**: [COMPLETED]
- **Started**: 2026-09-19T06:41:38Z
- **Completed**: 2026-09-19T07:05:00Z
- **Effort**: ~25 minutes wall clock (4 phases, 4 commits)
- **Dependencies**: None
- **Artifacts**: plans/01_cslib-refactor-plan.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The research report's refactor programme now has a durable home and a re-runnable measurement
behind every number it relies on. This task landed a committed import-graph library and
measurement script, the programme document under `docs/development/`, and two Proposed ADRs
(ADR-010 archive-at-root, ADR-011 Expressiveness extraction) cross-linked from ADR-009 and
ADR-006. No file under `FormalSystem/` or `Tests/` was modified; every phase left `lake build`,
`lake build BimodalTest` and the full invariant harness green.

## What Changed

- `scripts/lib/import_graph.py` — new: module/path mapping, leading-import-block parser (skips
  docstring `import` examples, which a naive grep turns into a false self-cycle on the root),
  transitive closure with an exclusion set, reverse index, comment-aware first-namespace reader.
- `scripts/measure-refactor-partitions.py` — new: `upward-edges`, `weakcanonical-partition`,
  `automation-partition`, `namespace-audit`, `all`, `--json`, and `--check` (exit 1 if the
  Expressiveness set leaks into the residual set or `BXCanonical`). Header records the measured
  numbers and every discrepancy against the report.
- `docs/development/PUBLICATION_REFACTOR.md` — new: purpose, path-naming convention, 23-row
  convention map, target layout + lakefile shape + namespace map, header/citation/CITATION/README
  templates, measurements, Phases 0-9 (each with `[CITE]` status, acceptance checks and ADR;
  Phase 6 split 6.1/6.2), dependency order and publication gate, nine paste-ready follow-ups.
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md` — new, Proposed.
- `docs/architecture/ADR-011-Extract-Expressiveness.md` — new, Proposed.
- `docs/architecture/README.md` — catalog rows, details paragraphs, Proposed-status note.
- `docs/architecture/ADR-006-*.md`, `ADR-009-*.md` — one Status paragraph each pointing at the
  proposing ADR; `**Accepted**` unchanged.
- `docs/development/MODULE_INVARIANTS.md` — sibling-script catalogue entry; `README.md` index row.

## Decisions

- Phase order 1 -> 3 -> 2 -> 4 rather than 1 -> 2 -> 3 -> 4: Phase 3 was the cheaper closure
  and writing the ADRs first let the programme document link to them without a dangling C13
  link (the ADRs name the programme document in backticks only).
- The namespace audit compares against the *directory* module (the report's definition), not
  the file's module; the file-level comparison gives 35/430 and is not what the programme uses.
- The four user-facing tactic modules are classified as library API (a third bucket), not
  tooling, matching the report's stated intent; `TraceExport` is counted with the tooling.
- `specs/` disposition: keep tracked while the programme runs; untrack the whole non-deliverable
  set in one commit at the publication gate (recorded as a non-blocking `user_decision`).
- `scripts/move-modules.py` stays a follow-up paired with the archive move (follow-up A).
- The single vacuous-pattern grep hit (`int_domain_universal := trivial` in
  `Examples/TemporalStructures.lean`) is a pre-existing, genuine proof of a `Set.univ`
  membership, last changed before this dispatch; recorded, not counted.

## Plan Deviations

- **Phase 2, allowlist item** skipped: no fully-qualified hypothetical path was needed, so
  `scripts/markdown-slash-path-allowlist.txt` stays empty.
- **Phase 2, convention map** altered: transcribed at 23 rows (the report's real count), not
  the 26 the Scope Hypothesis assumed.
- **Phase ordering** altered: 3 executed before 2 (see Decisions).

## Verification

- Build: Success — `lake build` exit 0 and `lake build BimodalTest` exit 0 (guarded, detached,
  no-op rebuild on a warm cache); full `bash scripts/check-module-invariants.sh` ALL CHECKS
  PASSED (exit 0); `bash scripts/check-metalogic-cycles.sh` exactly 1 cycle (exit 0);
  `scripts/readme-lint.sh` PASS.
- Sorry count: 0 (live tree; every census hit is under `Boneyard/`, as C3 asserts)
- Vacuous count: 0 after review (raw single-line grep: 1, pre-existing legitimate `trivial`
  proof in `Examples/`, no `.lean` touched by this task)
- Axiom count: 12 (unchanged from commit 220e94ea4; must not have increased — it did not)
- Tests: Passed (`lake build BimodalTest` runs the `#eval` suites: all reported 0 failed)
- Files verified: Yes — `git status --porcelain -- FormalSystem Tests` shows only the two
  one-line README edits that were already dirty when the dispatch started
  (`FormalSystem/Semantics/Ultraproduct/README.md`, `FormalSystem/Syntax/README.md`); not staged.
- Reconciled counts (script is the source of truth; documents agree): Expressiveness 141 files /
  104,087 lines, residual 38 / 28,472, 150 of 179 BXCanonical-free, 0 leaking edges; 16 upward
  lines into Automation (11 attribute-only); 4 Theorems -> Metalogic files; 29 Metalogic ->
  Theorems files (47 lines); 9 / 4 / 25 Automation modules; 279 / 187 / 24 / 43 namespaces.
- Discrepancies against the report, resolved to the script: 16 not 17 upward lines and 11 not
  12 attribute-only; 15 not 17 language-extension files among the 24 unrelated namespaces;
  C6 manifest 15 entries not 26; 8 probe test files not 9; convention map 23 rows not 26.

## Impacts

- Programme Phase 6's pre-move gate is now an executable command (`--check`), and every count
  the follow-ups will cite regenerates from the tree.
- ADR-006 and ADR-009 now carry explicit pointers to their proposed supersessions; nothing is
  superseded until the corresponding follow-up lands.
- `docs/development/` gains the programme; `docs/architecture/` gains two Proposed records.

## Follow-ups

- Create the nine follow-up tasks from `docs/development/PUBLICATION_REFACTOR.md` Section 9
  (A: move tool + archive relocation; B: deliverable hygiene; C: `BimodalTools` split;
  D: upward edges; E: language-extension directories + probe tests; F: Expressiveness
  extraction; G: docstring/citation normalisation; H: CI parity, root collapse, publication
  gate; I: post-publication). Dependency order 0 -> 1 -> 2 -> {3, 4} -> 5 -> 6 -> 7 -> 8 -> 9.
- User decision (non-blocking, recommended: untrack at the gate): whether `specs/` is untracked
  at the publication gate, kept published, or moved to a separate branch.
- The two pre-existing dirty `FormalSystem/**/README.md` one-liners belong to another session
  and were left unstaged.

## References

- specs/627_research_cslib_lean_engineering_refactor_plan/plans/01_cslib-refactor-plan.md
- specs/627_research_cslib_lean_engineering_refactor_plan/reports/01_cslib-refactor-plan.md
- specs/627_research_cslib_lean_engineering_refactor_plan/handoffs/ (phase 1, 3, 2 handoffs)
- docs/development/PUBLICATION_REFACTOR.md
- docs/architecture/ADR-010-Boneyard-At-Repository-Root.md
- docs/architecture/ADR-011-Extract-Expressiveness.md
- Commits: 315881d31 (phase 1), f0cae1239 (phase 3), 8de4f26ef (phase 2)
