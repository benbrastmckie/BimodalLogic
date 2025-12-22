# Plan: Upgrade `.opencode_new` with Lean 4 utilities

## Summary
Integrate Lean-specific commands and specialist subagents from `.opencode/` into `.opencode_new/` without altering existing non-Lean workflows. Add Lean plan/task routing via metadata flags, introduce the `/lean` command using the multi-phase workflow, and align contexts (including an updated project overview) so Lean vs non-Lean tasks load the right files without overloading context.

## Objectives
- Add Lean 4 specialist subagents (full list below) and Lean implementation routing to `.opencode_new`.
- Add `/lean` command to `.opencode_new/command/` with the multi-phase workflow adapted to new context paths.
- Extend `/plan` to tag Lean plans (metadata `lean: true/false`) and expose the flag for routing.
- Extend `/task` to delegate Lean-tagged plans to Lean implementation paths while preserving current routing/batch semantics.
- Update context files (notably `context/project/repo/project-overview.md`) and ensure commands/agents load minimal, correct context (Lean vs non-Lean) without overload.

## Scope
- In scope: `.opencode_new/agent/subagents/`, `.opencode_new/command/{plan,task,lean}.md`, context references under `.opencode_new/context/project/lean4` and `.../logic`, and `context/project/repo/project-overview.md` refresh; minimal additions under `context/common` if strictly needed for Lean routing metadata.
- Out of scope: Changing non-Lean command semantics, unrelated context files, or batch/atomic update semantics beyond adding Lean awareness.

## Assumptions
- `.opencode_new/context/project/lean4` and `.../logic` are usable for Lean specialists; shared standards exist under `context/common`.
- Plan metadata can include `lean: true/false` without breaking current consumers.
- Either the existing implementation orchestrator can be extended or a dedicated Lean orchestrator can be added with minimal disruption.
- All changes will follow existing `.opencode_new/` patterns:
  - **Commands**: YAML frontmatter, succinct description, Context Loaded block, numbered workflow, Usage/Examples sections matching house style.
  - **Agents/Subagents**: Frontmatter with `mode`, `temperature`, `tools` matching existing subagent template; hierarchical XML sections (context → role → task → workflow_execution → routing_intelligence → quality/validation/principles) consistent with current files.
  - **Context files**: Concise Markdown with scoped coverage; reuse existing structure under `context/project/{lean4,logic,repo}` and `context/common/standards`; avoid new directories unless necessary; keep line-length and sectioning consistent with peers.

## Deliverables
- New/updated subagent files for Lean specialists and Lean implementation routing.
- `/command/lean.md` in `.opencode_new/command/` with adapted contexts and routes.
- Updated `/command/plan.md` with Lean plan tagging and documentation of the flag.
- Updated `/command/task.md` with Lean-aware delegation based on plan metadata.
- Updated `context/project/repo/project-overview.md` and any minimal new/updated context notes to support Lean vs non-Lean routing.

## Detailed Lean Specialist/Subagent Port List
To be added under `.opencode_new/agent/subagents/` (align frontmatter/tools/context with existing template; reference `.opencode_new/context/project/lean4` and `.../logic`, plus `context/common` standards as needed):
- proof-developer
- tactic-specialist
- term-mode-specialist
- metaprogramming-specialist
- syntax-validator
- error-diagnostics
- proof-simplifier
- proof-optimizer
- performance-profiler
- example-builder
- documentation-generator
- doc-analyzer
- library-navigator
- proof-strategy-advisor
- tactic-recommender
- verification-specialist
- code-reviewer
- complexity-analyzer
- dependency-mapper
- dependency-analyzer
- git-workflow-manager
- batch-status-manager
- task-dependency-analyzer

## Implementation Steps
1) **Source alignment and mapping**
   - Review `.opencode/command/lean.md` phases and routing to identify required specialists and context references.
   - Map all legacy context paths to `.opencode_new/context/project/lean4` and `.opencode_new/context/project/logic`, plus `context/common/standards/*` for tests/style/tasks.
   - Inventory any source Lean subagent-specific context expectations (e.g., documentation standards, tactic patterns) and confirm equivalents exist in `.opencode_new`.

2) **Add Lean specialist subagents**
   - Create the 23 subagent files listed above under `.opencode_new/agent/subagents/` using the existing subagent template (frontmatter, `mode: subagent`, tools block matching house style; preserve XML ordering: context → role → task → workflow_execution → routing_intelligence/validation/principles).
   - For each, update routing/context references to `.opencode_new/context/project/lean4` and `.opencode_new/context/project/logic`; for style/test/doc standards, reference `.opencode_new/context/common/standards/{code,tests,documentation}.md` where applicable.
   - Ensure each specialist declares expected outputs (reports/summaries) and keeps responses concise to avoid context overload.

3) **Lean implementation routing**
   - Choose minimal-regression path:
     - Option A: Add `lean-implementation-orchestrator.md` under subagents to delegate to Lean specialists and coordinate phases.
     - Option B (if safe): Extend existing `implementation-orchestrator.md` with a Lean branch keyed on `plan.metadata.lean=true` that routes to `proof-developer` and related specialists; leave all current non-Lean branches untouched.
   - Implement chosen path with clear gating on the Lean flag and explicit context level selection (Level 1 default; Level 2 for combined strategy/tactic inputs; avoid Level 3 unless absolutely required).

4) **Add `/command/lean.md`**
   - Port the multi-phase Lean workflow from `.opencode/command/lean.md` to `.opencode_new/command/`, matching existing `.opencode_new` command structure (frontmatter, Context Loaded block, numbered workflow, Usage/Examples sections).
   - Update context block to load only the necessary Lean/logic contexts plus common standards: `@.opencode_new/context/project/lean4/**`, `@.opencode_new/context/project/logic/**`, and targeted `@.opencode_new/context/common/standards/{code,tests,documentation}.md` (avoid broad wildcards that overload context).
   - Route implementation to the Lean implementation path (Lean orchestrator or Lean branch) and ensure flag handling (`--fast`, `--skip-*`, `--full`, `--help`) mirrors source behavior.

5) **Extend `/command/plan.md` with Lean tagging**
   - Add Lean intent detection (keywords: lean, proof, theorem, lemma, tactic, mathlib) and/or explicit flag handling; set `lean: true/false` in plan metadata/frontmatter.
   - Document the new metadata field inside the command file and ensure plan artifacts record it in a consistent place (frontmatter or a clearly labeled metadata section).
   - Keep artifact locations and existing workflow unchanged.

6) **Extend `/command/task.md` routing**
   - When a task’s attached plan metadata indicates `lean: true`, delegate to the Lean implementation path (Lean orchestrator/proof-developer) instead of the general implementer.
   - Preserve batch handling, status updates, lazy directory creation, and non-Lean routing logic.
   - Add a short compatibility note describing the Lean branch trigger and fallback behavior.

7) **Context alignment and improvements**
   - Update `context/project/repo/project-overview.md` using existing style (short sections, repo snapshot, commands list) to reflect current repository naming, command set (including `/lean`), Lean vs non-Lean workflows, and correct context paths.
   - If any Lean specialist expects additional templates or standards not present, add minimal targeted files under `context/project/lean4` (e.g., a brief “lean-plan-metadata.md” note) or reuse existing ones; avoid broad duplication and keep sectioning consistent with current context files.
   - Ensure context loading per command/agent is minimal: `/lean` loads Lean/logic + needed standards; `/plan` loads task/standards + optionally Lean/logic when Lean intent is detected; `/task` loads TODO/state plus plan metadata and conditionally Lean contexts only when `lean: true`.

8) **Documentation touch (optional, only if enumerated lists exist)**
   - If `.opencode_new/README.md` or navigation files enumerate commands/subagents, add a brief note for `/lean` and Lean specialists; otherwise skip to avoid churn.

## Validation Plan
- **Command wiring**: Run `/command/lean --help` (or equivalent dry-run) to confirm phases, context loading, and routing paths are correct.
- **Plan tagging**: Run `/command/plan` on a Lean-focused task to confirm `lean: true` in the plan artifact; run on a non-Lean task to confirm `lean: false`/absent.
- **Task routing**: Execute `/command/task` with a Lean-tagged plan to verify delegation to the Lean implementation path; execute with a non-Lean plan to confirm legacy routing remains intact.
- **Context resolution**: Spot-check a Lean specialist file to ensure context references point to `.opencode_new` paths (no legacy `.opencode` paths) and that only minimal necessary files are loaded.
- **Orchestrator branch**: If extending the existing implementation orchestrator, smoke-test both Lean and general branches; if adding a dedicated Lean orchestrator, ensure it is reachable and delegates correctly.
- **Project overview accuracy**: Verify `context/project/repo/project-overview.md` reflects the final command set and workflows after changes.

## Risks & Guardrails
- **Routing regressions**: Mitigate by gating Lean behavior strictly on plan metadata; leave default routes untouched.
- **Context overload/drift**: Mitigate by explicitly listing minimal context files per command/agent and avoiding broad wildcards; double-check all Lean specialist references point to `.opencode_new/context/project/lean4` and `.../logic` plus `context/common` standards where needed.
- **Doc churn**: Limit documentation edits to the project overview and only add other notes where existing docs enumerate commands/subagents.
- **Rollback**: Revert modified command/orchestrator files and remove added Lean subagent files; the Lean flag keeps non-Lean flows unaffected.
