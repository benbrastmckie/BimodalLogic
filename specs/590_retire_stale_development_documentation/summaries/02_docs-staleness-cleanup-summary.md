# Implementation Summary: Task #590

- **Task**: 590 - Retire stale development documentation (widened: `docs/` staleness audit)
- **Status**: [COMPLETED]
- **Started**: 2026-09-17T08:10:43Z
- **Completed**: 2026-09-17T11:45:00Z
- **Effort**: ~3.5 hours
- **Dependencies**: 595 (durable-records-home, completed; settled nothing in this plan's file set)
- **Artifacts**: plans/02_docs-staleness-cleanup.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Cleared every unmarked task-number citation under `docs/` (C9D: 142 -> 0), retired the obsolete
`PHASED_IMPLEMENTATION.md` roadmap, rewrote the fictional per-theory `LATEX_STANDARDS.md` layout
doc to describe the real frozen `latex/` edition, rewrote the tactic-reference documentation
against the real 7-tactic surface (`apply_axiom`, `modal_t`, `assumption_search`, `propDecide`,
`deduction`, `undischarge`, `modal_search`), reframed the `leansearch-*.md` research notes as
historical design provenance, refreshed `implementation-status.md`, aligned naming prose in
`CLAUDE.md` and the installation guides, and flipped `ENFORCE_C9_DOCS` to enforced by default.
All 8 plan phases completed; all named gates (C5, C9D, C12, C13, readme-lint, both
`ENFORCE_C9_DOCS` invocations) pass.

## What Changed

- `docs/development/PHASED_IMPLEMENTATION.md` — Deleted (obsolete Layer-0 roadmap, all goals met); index entries removed from `docs/README.md` and `docs/development/README.md`
- `docs/development/LATEX_STANDARDS.md` — Rewritten as a short, accurate note describing the frozen `latex/` edition
- `docs/README.md`, `docs/development/README.md`, `docs/development/CONTRIBUTING.md` — Description updates for the frozen LaTeX edition
- `latex/README.md` — Added a frozen-edition banner; updated Typst cross-reference wording
- `docs/training/PIPELINE.md` — De-cited provenance line and downstream table with durable slugs/anchors
- `docs/research/NONCOMPUTABLE.md` — De-cited 5 "task 192" mentions (vault casualty) with the `GeneralizedNecessitation.lean` durable anchor
- `docs/project-info/MAINTENANCE.md` — De-cited example commands and a "Task 169" fact with placeholders/plain prose
- `docs/architecture/ADR-004-Remove-Project-Level-State-Files.md` — De-cited dead task-276 citations and paths
- `docs/architecture/ADR-001-Classical-Logic-Noncomputable.md`, `docs/development/NONCOMPUTABLE_GUIDE.md`, `docs/development/DOC_QUALITY_CHECKLIST.md`, `docs/architecture/BFMCS_ARCHITECTURE.md`, `docs/research/DEDUCTION_THEOREM_NECESSITY.md` — Cleared 10 additional citations not itemized in any phase but required for the C9D=0 gate; also corrected ADR-001/NONCOMPUTABLE_GUIDE.md's stale "needs fixing" claims (the fix has long been complete)
- `docs/reference/API_REFERENCE.md` — Rewrote tactic tables, removed `tm_auto` and the six nonexistent operator-specific tactics, added `propDecide`/`deduction`/`undischarge` sections, cleared 2 Task-176 citations
- `docs/project-info/tactic-registry.md` — Rewrote the body against the real tactic inventory
- `docs/project-info/FEATURE_REGISTRY.md` — Replaced the nonexistent `Helpers.lean` with the actual six-file list
- `docs/user-guide/tutorial.md`, `docs/user-guide/examples.md`, `docs/user-guide/troubleshooting.md`, `docs/user-guide/tactic-development.md` — Retargeted `tm_auto` examples/prose to `modal_search`; reframed a `modal_4_tactic` section that falsely claimed to be real source as illustrative
- `docs/development/METAPROGRAMMING_GUIDE.md` — Fixed worked examples, cleared a Task-7 citation, removed a fictional `temporal_t` row
- `docs/research/leansearch-{api-specification,best-first-search,priority-queue,proof-caching-memoization}.md` — Added historical-design-research banners
- `docs/research/README.md` — Added the reframing note; cleared 3 stray Task-192/199 citations
- `docs/project-info/implementation-status.md` — Fresh statistics (scoped to `FormalSystem`+`Tests`, avoiding `specs/`/`.claude` scratch-file pollution), rewrote the Layer 4 Automation section, dropped the unverifiable "bounded search timeout" claim
- `CLAUDE.md` — Retitled and added a "Names" key reflecting the completed lakefile.toml migration (Lake package `BimodalLogic`, not the plan's stale "Logos" assumption)
- `docs/installation/BASIC_INSTALLATION.md` — Fixed literal `ProofChecker` directory paths to `BimodalLogic`
- `docs/research/proof-search-automation.md` — Fixed a hardcoded absolute local-filesystem report path
- `scripts/check-module-invariants.sh` — Flipped `ENFORCE_C9_DOCS` default to 1; updated surrounding comments
- `docs/development/MODULE_INVARIANTS.md` — Rewrote the flag-example paragraph (cites `ENFORCE_C16_ROOTS` as the remaining soft-default example)
- `docs/development/CI_CD_PROCESS.md` — Added a gating note for C9D
- `docs/reference/README.md` — Fixed a live-presented `temporal_search` row found during the final validation grep

## Decisions

- `PHASED_IMPLEMENTATION.md`: delete outright — its Tasks 1-11 roadmap is fully met, everything is
  axiom-pinned, and sections 6-7/References were skimmed and contained no unrestated durable content
- `latex/`: kept as a frozen historical edition (not archived), since `README.md` links its PDF as
  the superseded-but-retained edition
- `leansearch-*.md`: kept and reframed as design provenance rather than deleted or moved
- Naming: recorded the mapping in a `CLAUDE.md` "Names" key rather than mass-renaming the
  "ProofChecker" role name; only concretely wrong directory-path usages were fixed
- Dead citations (tasks 276, 169, 192, 199, 914-916, 176): replaced with durable facts, never
  marked `task-ref-ok` (they resolve to different or nonexistent tasks post-vault-operation)
- `PIPELINE.md` provenance: dropped numeric prefixes, kept slugs as the durable anchor
- `ENFORCE_C9_DOCS` CI wiring: flipping the script default plus a documentation note was
  sufficient; no workflow edit needed since `ci.yml` invokes the script bare

## Plan Deviations

- **Phase 3** extended beyond its four named files to also de-cite 5 additional files
  (`ADR-001-Classical-Logic-Noncomputable.md`, `NONCOMPUTABLE_GUIDE.md`, `DOC_QUALITY_CHECKLIST.md`,
  `BFMCS_ARCHITECTURE.md`, `DEDUCTION_THEOREM_NECESSITY.md`) found by the full-repo C9D re-grep,
  not itemized in the plan but required for the eventual C9D=0 gate
- **Phase 4** also cleared 2 stray Task-176 citations in `API_REFERENCE.md`, found while
  rewriting the tactic tables
- **Phase 5** also reframed a `modal_4_tactic` "actual working implementation from Tactics.lean"
  section that falsely claimed to be real source, and cleared a Task-7 citation plus a fictional
  `temporal_t` row in `METAPROGRAMMING_GUIDE.md`
- **Phase 6** also cleared 3 stray Task-192/199 citations in `research/README.md`
- **Phase 7**: the plan's Decision 4 assumed the Lake package would be named `Logos`; task 578's
  toml migration completed concurrently during this dispatch and committed the package as
  `BimodalLogic`, so the `CLAUDE.md` naming key reflects that ground truth instead. Also fixed an
  additional hardcoded absolute path in `proof-search-automation.md` found by the plan's own
  literal-path grep
- **Phase 8** also fixed a live-presented `temporal_search` row in `docs/reference/README.md`
  found during the final validation grep required by this phase's own acceptance test

None of these deviations altered scope in a way that reduced the task's goals; each closed a gap
the mechanical verification (C9D re-grep, tm_auto/temporal_search grep) surfaced but the plan's
itemized file lists had not anticipated.

## Verification

- Build: N/A (markdown/docs task; `--no-build` structural checks only)
- Tests: N/A
- Files verified: Yes — `bash scripts/check-module-invariants.sh --no-build` reports `ALL CHECKS
  PASSED` (C5, C9D, C12, C13 all PASS); `ENFORCE_C9_DOCS=1 bash scripts/check-module-invariants.sh
  --no-build` and the default invocation both exit 0; `bash scripts/readme-lint.sh` PASS;
  `bash .claude/scripts/check-task-references.sh` PASS (0 unexempted occurrences); `grep -n ENFORCE
  .github/workflows/ci.yml` empty (no override); changed runnable Lean snippets verified with
  `lake env lean` against a scratch file

## Impacts

- CI now gates on zero task-number citations under `docs/` by default, closing the last soft
  pocket of the C9 family (the sibling `FormalSystem/`, `lakefile.lean`/`.toml`, `README.md`,
  `scripts/` check was already hard-gated)
- Documentation readers will no longer be misled into using retired tactics (`tm_auto`,
  `temporal_search`, `propositional_search`) or nonexistent ones (six operator-specific tactics,
  `modal_4_tactic`, `temporal_t`)
- `implementation-status.md`'s statistics and Automation section now match the live tree

## Follow-ups

- None blocking. The package-name decision itself (Lake package `BimodalLogic`) belongs to task
  578's toml migration, which completed concurrently with this task; this task's `CLAUDE.md`
  naming key only records the current value

## References

- Plan: `specs/590_retire_stale_development_documentation/plans/02_docs-staleness-cleanup.md`
- Reports: `specs/590_retire_stale_development_documentation/reports/01_stale-docs-and-task-citations.md`, `specs/590_retire_stale_development_documentation/reports/02_widened-docs-staleness-audit.md`
- Progress files: `specs/590_retire_stale_development_documentation/progress/phase-{1..8}-progress.json`
