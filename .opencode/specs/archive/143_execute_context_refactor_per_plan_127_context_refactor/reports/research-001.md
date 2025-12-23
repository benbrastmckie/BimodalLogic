# Research Report: Execute context refactor per plan 127_context_refactor
- **Task**: 143 - Execute context refactor per plan 127_context_refactor
- **Status**: [COMPLETED]
- **Started**: 2025-12-22T00:00:00Z
- **Completed**: 2025-12-22T00:00:00Z
- **Effort**: 0.5h (research)
- **Priority**: Medium
- **Dependencies**: Context refactor plan placeholder (`.opencode/specs/127_context_refactor/plans/context-refactor-plan-001.md`); Task 144 (context references remap after refactor)
- **Sources/Inputs**:
  - `.opencode/specs/127_context_refactor/plans/context-refactor-plan-001.md` (placeholder)
  - `.opencode/specs/127_context_refactor/plans/context-references-plan-001.md`
  - `.opencode/context/index.md`
  - `.opencode/context/README.md`
  - `.opencode/context/common/system/context-guide.md`
  - `.opencode/context/common/system/artifact-management.md`
  - `.opencode/context/common/standards/report.md`
- **Artifacts**: `.opencode/specs/143_execute_context_refactor_per_plan_127_context_refactor/reports/research-001.md`
- **Standards**: status-markers.md; artifact-management.md; report.md; tasks.md

## Executive Summary
- The linked refactor plan is a placeholder with no target structure, so executing Task 143 requires drafting a concrete mapping before edits.
- Current context layout already follows a `common/` vs `project/` split with Lean, Logic, Math, Physics, and Repo subtrees; index.md provides a quick map but will need alignment once a mapping is defined.
- A companion context-references plan (task 144 input) exists but defers all edits until a real refactor structure is produced; it lists affected agent/command files and currently assumes identity mapping.
- Acceptance criteria center on relocating/renaming per plan, updating index and domain READMEs, removing duplicates, and running link/dependency checks; none can be fulfilled until the plan defines the new layout.
- Recommended path: author a real refactor mapping that deduplicates Lean vs Logic guidance, specifies new paths, and defines verification steps; then execute moves, update index/READMEs, run link checks, and hand off to task 144 for reference updates.

## Context & Scope
Task 143 aims to apply the context refactor described in plan 127 to `.opencode/context/` (common + project trees), refresh `index.md`, and consolidate overlapping Logic/Lean guidance. The supplied plan is empty, so this research outlines what is needed to satisfy the acceptance criteria and stages the execution approach.

## Findings
- **Plan gap**: `.opencode/specs/127_context_refactor/plans/context-refactor-plan-001.md` is a placeholder; no target structure, mapping, or rename list is defined, blocking direct execution.
- **Current layout**: `common/` holds standards, system guides, templates, workflows; `project/` holds domain trees (`lean4/`, `logic/`, `math/`, `physics/`, `repo/`). `index.md` maps quick loads by category and priorities.
- **References plan**: `.opencode/specs/127_context_refactor/plans/context-references-plan-001.md` inventories agent/command context loads and narratives; all edits are deferred pending a real mapping.
- **Acceptance expectations** (from TODO 143): relocate/rename per plan with updated index and no broken links; update per-domain READMEs with canonical logic standards and trimmed Lean4 guidance; resolve outdated references/verbosity; run plan verification checks for links/dependencies.
- **Dependencies**: Task 144 depends on the refactor output to remap references; executing 143 without a defined mapping risks churn and breakage.

## Decisions
- Treat the refactor plan as missing and require creation of a concrete mapping before any filesystem changes.
- Use the existing context-guide and current layout as baselines for drafting the new structure and deduplication rules.

## Recommendations (prioritized)
1. **Author the real refactor mapping**: Define target tree, file moves/renames, dedup rules for Lean vs Logic, and which standards/READMEs to trim or merge. Include link-impact notes per file.
2. **Stage refactor execution**: Apply moves/renames in `.opencode/context/common/` and `.opencode/context/project/` per mapping; adjust internal anchors and table-of-contents sections as needed.
3. **Update `index.md` and domain READMEs**: Reflect new paths, quick maps, and priorities; ensure Lean guidance is trimmed where Logic standards cover the content; keep canonical logic standards highlighted.
4. **Run verification pass**: Link/dependency checks against the new structure (index cross-links, README links, and any intra-doc references); document fixes.
5. **Coordinate with Task 144**: Supply the finalized mapping to the context-references workflow so agent/command files can be updated without guessing.

## Risks & Mitigations
- **Risk: Plan still absent** → Mitigation: Block execution until mapping exists; draft mapping with explicit before/after paths.
- **Risk: Broken links after moves** → Mitigation: Run link verification across index and domain READMEs; include a checklist of affected anchors.
- **Risk: Duplicate guidance persists** → Mitigation: During mapping, mark which Lean files defer to Logic standards; remove or merge overlaps with citations.
- **Risk: Scope creep** → Mitigation: Constrain to files listed in TODO and mapping; defer agent/command updates to Task 144.

## Checklist aligned to acceptance criteria
- [ ] Files relocated/renamed per finalized plan mapping; index entries updated; links verified (no broken links).
- [ ] Per-domain READMEs updated with canonical logic standards and trimmed Lean4 guidance as specified in the mapping.
- [ ] Outdated references and verbosity hotspots resolved per plan; duplicates removed or merged.
- [ ] Plan verification checks for links and dependency references executed and documented; issues fixed.

## Appendix
- References: `.opencode/context/index.md`, `.opencode/context/README.md`, `.opencode/context/common/system/context-guide.md`, `.opencode/context/common/system/artifact-management.md`, `.opencode/specs/127_context_refactor/plans/context-references-plan-001.md`, `.opencode/context/common/standards/report.md`.
