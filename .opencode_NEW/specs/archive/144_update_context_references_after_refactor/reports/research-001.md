# Research Report: Update context references after refactor

**Project**: #144_update_context_references_after_refactor  
**Date**: 2025-12-23  
**Research Type**: context-reference audit (documentation/agent/command)  
**Inputs**: 143 implementation plan (specs/143_execute_context_refactor_per_plan_127_context_refactor/plans/implementation-001.md), prior references placeholder (specs/127_context_refactor/plans/context-references-plan-001.md), refreshed context index/README after refactor

## Research Question
Enumerate the concrete context references in agent/command documentation that must be updated to match the new `.opencode/context` structure after Task 143’s refactor, including old→new path mapping and per-file edit actions.

## Sources Consulted
- 143 implementation plan (completed) – refactor mapping, canonical vs overlay rules, index/README updates
- Context tree (post-refactor): `.opencode/context/` with `common/`, `project/{logic,lean4,math,physics,repo}`, refreshed `README.md` and `index.md`
- Lean overlay rename: `project/lean4/standards/proof-conventions-lean.md` (new) with legacy `proof-conventions.md` now a forwarding stub
- Prior placeholder references plan (127) to enumerate targeted files

## Key Findings
1. **Normalized structure**: Context root is `.opencode/context/` with `common/{standards,system,templates,workflows}` and `project/{logic,lean4,math,physics,repo}`; indexes/README reflect this (no `core/` or root `lean4/`).
2. **Canonical vs overlay**: Proof/notation rules are canonical in `project/logic/standards/{proof-conventions.md, notation-standards.md}`; Lean-specific overlay lives in `project/lean4/standards/proof-conventions-lean.md` (old `.../proof-conventions.md` now a redirect file).
3. **Indexes refreshed**: `index.md` and `README.md` now document the new layout and lean/logic split; references should align to these paths and avoid legacy prefixes.
4. **Link-check still pending** (from Task 143 plan Phase 3/testing): recommend running link/path validation after updating references.

## Old → New Path Mapping (post-refactor)
- `.opencode/context/core/...` → `.opencode/context/common/...` (standards/system/templates/workflows)
- `.opencode/context/lean4/...` or `.opencode/context/core/lean4/...` → `.opencode/context/project/lean4/...`
- `.opencode/context/logic/...` or `.opencode/context/core/logic/...` → `.opencode/context/project/logic/...`
- `.opencode/context/project/lean4/standards/proof-conventions.md` → `.opencode/context/project/lean4/standards/proof-conventions-lean.md` (Lean overlay)
- Canonical proof/notation references → `.opencode/context/project/logic/standards/{proof-conventions.md, notation-standards.md}`
- Context overview references → `.opencode/context/README.md` and `.opencode/context/index.md`

## Reference Updates Needed (Agents)
- `.opencode/agent/orchestrator.md`
  - Replace legacy `core/standards`, `core/processes`, `core/templates`, `core/patterns`, `domain/` mentions with the new layout: `core/standards/`, `core/workflows/`, `core/templates/`, and domain-specific `project/{logic|lean4}/...` (patterns/processes live under the relevant project domain; proof principles under `project/logic/...`, Lean overlays under `project/lean4/...`).
  - Update workflow routing/context selection examples to cite `core/system/{artifact-management,status-markers}` and `project/logic` (canonical) + `project/lean4` (overlay) rather than `core/`.
- `.opencode/agent/subagents/context-analyzer.md`
  - Clarify scanning targets to the new `common/` vs `project/{logic,lean4,...}` layout and the renamed Lean overlay file; avoid legacy `core/` or root `lean4/` language.
- `.opencode/agent/subagents/context-refactor.md` and `.opencode/agent/subagents/context-references.md`
  - Update narrative to reference `.opencode/context/README.md` and `index.md` as the authoritative map; ensure instructions look for `common/` and `project/` subtrees (not legacy `core/`), and note the Lean overlay rename.
- `.opencode/agent/subagents/lean-implementation-orchestrator.md`
  - Loaded context is already `project/{lean4,logic}` + `common/standards`; add note to use `project/lean4/standards/proof-conventions-lean.md` (overlay) plus canonical `project/logic/standards/proof-conventions.md` if citing proof conventions explicitly.

## Reference Updates Needed (Commands & Docs)
- `.opencode/command/meta.md`
  - Update “Context Loaded” and structure examples to the new layout (`.opencode/context/common/{templates,system/context-guide.md}` and `.opencode/context/project/{logic,lean4,math,physics,repo}`); replace generated structure block that still shows legacy `context/domain|processes|standards` tree with the normalized `common/` + `project/` layout.
  - In detection/merge steps, scan `common/` and `project/` subtrees (including `project/lean4/standards/proof-conventions-lean.md` and canonical logic standards) instead of legacy `context/` flat lists.
- `.opencode/command/document.md` and `.opencode/command/refactor.md`
  - Replace broad `@context/project/` load with explicit domain paths matching new structure: e.g., `@context/project/logic/` (canonical proof/notation/processes) plus `@context/project/lean4/` when Lean-specific; include `@context/core/standards/documentation.md`/`code.md` as primary anchors.
- `.opencode/command/review.md`
  - Context list uses `@context/project/`; align to `project/{logic,lean4}` (and `project/repo/project-overview.md`) plus `common/system` standards instead of legacy `project/` root to avoid ambiguous loads.
- `.opencode/command/README.md`
  - In “Context Allocation” section, replace generic `.opencode/context/` references with `common/` vs `project/{logic|lean4|math|physics|repo}` language reflecting the new index/README.
- `.opencode/command/context.md`
  - Consider adding `index.md`/`README.md` references in the workflow description when handing off to subagents so future plans use the updated map.

## Recommendations / Next Steps
- Apply the per-file edits above, ensuring all old prefixes (`core/`, root `lean4/`, legacy Lean proof conventions filename) are replaced with the canonical/common/project paths.
- After edits, run a link/path validation over `.opencode/context` and the touched agent/command files (Task 143 left link-check pending) to confirm no broken references.

## Specialist Reports
- No specialist subagent reports were generated; findings derived from the refactor plan, context tree, and updated index/README.
