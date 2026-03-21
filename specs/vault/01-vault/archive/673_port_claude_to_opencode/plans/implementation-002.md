# Implementation Plan: Improve .opencode parity with .claude
- **Task**: 673 - Port .claude agent system to .opencode (parity upgrades)
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-002.md, plans/parity-matrix.md
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview
Improve the .opencode port to match the functional depth and quality of the .claude system while preserving opencode conventions. Scope focuses on closing gaps between agent/skill/command specs, restoring detailed workflows, aligning ProofChecker .opencode conventions with OpenAgents high-standard patterns (context loading gates, delegation rules, frontmatter consistency, context index guidance), and verifying supporting assets for feature parity. Definition of done is a validated .opencode system with no material behavior regressions against .claude, documented exceptions, and updated validation checks reflecting OpenAgents conventions.

## Goals & Non-Goals
- **Goals**:
  - Align .opencode agent specifications with .claude detail and functionality.
  - Align .opencode skills and command docs with .claude equivalents for full workflow parity.
  - Preserve OpenAgents patterns for critical context gating, delegation criteria, and stage-based workflow execution.
  - Incorporate OpenAgents-style context index usage and lazy-loading guidance where ProofChecker workflows lack it.
  - Standardize frontmatter/tool permissions against OpenAgents expectations while maintaining ProofChecker rules.
  - Remove model-specific fields (e.g., `model: claude-opus-4-5-20251101`) from .opencode files to preserve provider neutrality.
  - Document and justify any intentional differences between .claude and .opencode.
  - Validate .opencode for missing references and parity gaps.
- **Non-Goals**:
  - Refactor unrelated code or alter task data in specs/TODO.md or specs/state.json.
  - Change .claude source content beyond comparison and auditing.
  - Collapse ProofChecker-specific domain context (Lean/logic/math) into OpenAgents structure.

## Risks & Mitigations
- Risk: Porting changes degrade opencode-specific conventions. Mitigation: preserve opencode frontmatter and routing while extending content only where needed.
- Risk: Missing parity issues due to incomplete diff. Mitigation: build full diff matrix for agents/skills/commands and track completion.
- Risk: Scope creep into unrelated documentation. Mitigation: limit updates to .opencode system files and targeted docs.
- Risk: Mixing OpenAgents patterns without ProofChecker constraints causes conflicts. Mitigation: explicitly map which OpenAgents patterns are adopted (context index, delegation gates, return schemas) and which stay ProofChecker-specific (skills, rules, domain contexts).
- Risk: Overloading routing by adding heavy context. Mitigation: adopt OpenAgents lazy-loading guidance and keep routing stages context-free.

## OpenAgents Parity Checklist
- [x] Context index quick map matches OpenAgents pattern (routing vs execution guidance, triggers, deps). See `.opencode/context/index.md`, `.opencode/context/core/system/context-guide.md`.
- [x] Critical context loading gates documented for agents/skills (pre-execution requirements). See `.opencode/agent/AGENT.md`, `.opencode/agent/meta-builder-agent.md`, `.opencode/skills/*/SKILL.md`.
- [x] Delegation criteria align with OpenAgents thresholds (4+ files, >60 minutes, specialized knowledge). See `.opencode/agent/AGENT.md`, `.opencode/rules/workflows.md`.
- [x] Command lifecycle docs align with checkpoint-based preflight/execute/postflight model. See `.opencode/rules/workflows.md`, `.opencode/context/index.md`.
- [x] Return schema guidance aligns with OpenAgents formats (required fields, status markers). See `.opencode/rules/artifact-formats.md`, `.opencode/rules/state-management.md`.
- [x] Frontmatter fields and tool permissions standardized (no model-specific fields). See `.opencode/agent/*.md`, `.opencode/command/*.md`, `.opencode/skills/*/SKILL.md`.
- [x] Context loading guidance emphasizes lazy loading during routing. See `.opencode/context/index.md`, `.opencode/rules/workflows.md`.
- [x] Validation steps document context dependencies and reference audits. See `.opencode/rules/workflows.md`, `.opencode/rules/error-handling.md`.

## OpenAgents Reference Set
- `.opencode/agent/AGENT.md`
- `.opencode/agent/orchestrators/openagents-orchestrator.md`
- `.opencode/context/index.md`
- `.opencode/context/core/system/context-guide.md`
- `.opencode/context/core/workflows/delegation.md`
- `.opencode/context/core/workflows/task-breakdown.md`
- `.opencode/context/core/workflows/review.md`
- `.opencode/context/core/standards/docs.md`
- `.opencode/context/core/standards/tests.md`
- `.opencode/context/core/standards/code.md`

## Implementation Phases
### Phase 1: Audit parity gaps [COMPLETED]
- **Goal:** Create a comprehensive diff matrix between .claude and .opencode system files plus OpenAgents conventions to adopt.
- **Tasks:**
  - [x] Compare each .claude agent to its .opencode counterpart and record missing sections.
  - [x] Compare each .claude skill and command to .opencode equivalents for workflow gaps.
  - [x] Identify missing context references, tool lists, or return schema differences.
  - [x] Inventory model-specific fields in .opencode files that need removal.
  - [x] Review OpenAgents .opencode patterns (context index, context loading gates, delegation rules, frontmatter conventions) and map to ProofChecker gaps.
  - [x] Produce a prioritized upgrade list with severity tags, including OpenAgents-alignment tasks.
- **Timing:** 1-2 hours
- **Completed**: 2026-01-23

### Phase 2: Upgrade high-gap agents [COMPLETED]
- **Goal:** Port missing depth for the most reduced agents (e.g., document-converter-agent) and align with OpenAgents orchestration patterns.
- **Tasks:**
  - [x] Expand .opencode/document-converter-agent.md to include supported conversions, tool detection, validation, and return schema.
  - [x] Update other agents with major content gaps (meta-builder, planner, research, implementation) based on Phase 1 matrix.
  - [x] Align agent workflow stages with OpenAgents patterns (context gates, approval gates, delegation criteria) where applicable to ProofChecker rules.
  - [x] Ensure each upgraded agent references .opencode context paths and uses lazy loading guidance via context index.
  - [x] Remove model-specific fields from updated agent frontmatter.
- **Timing:** 2-3 hours
- **Completed**: 2026-01-23

### Phase 3: Align skills and commands [COMPLETED]
- **Goal:** Ensure skills and commands align with upgraded agent specs, behaviors, and OpenAgents-style orchestration patterns.
- **Tasks:**
  - [x] Update skill docs to reflect expanded agent behaviors, return formats, and required context loading (lazy-loaded via context index).
  - [x] Verify command docs align with updated skills and agent return expectations, including preflight/postflight steps.
  - [x] Align command lifecycle guidance in rules/workflows.md with OpenAgents checkpoint model where appropriate.
  - [x] Remove model-specific fields from skills and command frontmatter.
  - [x] Document any intentional divergence between .claude and .opencode behavior.
- **Timing:** 1-2 hours
- **Completed**: 2026-01-23

### Phase 4: Validation and reference audit [COMPLETED]
- **Goal:** Confirm parity targets are met and .opencode references are consistent.
- **Tasks:**
  - [x] Re-run .opencode reference audit to ensure no missing paths or tooling references.
  - [x] Validate that sample outputs and docs reference the upgraded content correctly.
  - [x] Confirm no model-specific fields remain in .opencode files.
  - [x] Verify ProofChecker context index references OpenAgents-style quick map, dependency notes, and routing vs execution guidance.
  - [x] Update plan status markers and summarize completed parity upgrades.
- **Timing:** 1-2 hours
- **Completed**: 2026-01-23

## Testing & Validation
- [x] Confirm updated agent files include required return schema guidance and explicit context loading gates.
- [x] Verify skill/command docs reference updated agent paths, context index usage, and preflight/postflight steps.
- [x] Re-scan .opencode for missing or broken references.
- [x] Scan .opencode for model-specific fields (model: ...), ensure removal.
- [x] Validate command lifecycle documentation aligns with OpenAgents checkpoint guidance without breaking ProofChecker rules.

## Artifacts & Outputs
- specs/673_port_claude_to_opencode/plans/implementation-002.md
- .opencode/agent/* (updated parity content)
- .opencode/skills/* (aligned workflow guidance)
- .opencode/command/* (aligned command specs)

## Rollback/Contingency
- Revert updated .opencode files to pre-upgrade state using git checkout if parity changes introduce regressions.
