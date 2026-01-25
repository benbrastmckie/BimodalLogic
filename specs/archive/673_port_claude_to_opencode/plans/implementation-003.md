# Implementation Plan: Normalize OpenCode .opencode Standards
- **Task**: 673 - Port .claude agent system to .opencode (standards cleanup)
- **Status**: [COMPLETED]
- **Effort**: 6-10 hours
- **Priority**: High
- **Dependencies**: plans/implementation-002.md
- **Research Inputs**: None
- **Artifacts**: plans/implementation-003.md
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview
Establish and enforce canonical OpenCode formatting for all .opencode command, agent, skill,
context, and rules files. Align YAML frontmatter to format standards, introduce XML-based
structure standards for agent and skill files, and normalize OpenCode naming across the
system. Definition of done is a fully compliant .opencode tree with consistent frontmatter,
validated context references, and a documented audit trail of any intentional exceptions.

## Goals & Non-Goals
- **Goals**:
  - Ensure all command files follow `.opencode/context/core/formats/command-structure.md`.
  - Add format standards for agents and skills under `.opencode/context/core/formats/`.
  - Normalize all remaining "Claude" references to "OpenCode" across .opencode.
  - Ensure YAML frontmatter blocks contain only YAML fields (no markdown headings).
  - Document compliance updates and remaining exceptions.
- **Non-Goals**:
  - Change ProofChecker task data in specs/TODO.md or specs/state.json.
  - Modify .claude source content.
  - Redesign workflow semantics beyond standard alignment.

## Risks & Mitigations
- Risk: Frontmatter changes introduce invalid YAML. Mitigation: validate frontmatter by re-reading after edits and keeping YAML-only blocks.
- Risk: Context name changes break cross-references. Mitigation: track replacements and update referenced locations in docs.
- Risk: XML structure changes create doc drift. Mitigation: document exceptions explicitly if files remain markdown-only.

## Implementation Phases
### Phase 1: Frontmatter compliance audit [COMPLETED]
- **Goal:** Identify frontmatter violations and required fixes.
- **Tasks:**
  - [x] Scan all command, agent, and skill files for YAML frontmatter compliance.
  - [x] Identify missing required fields per format standards.
  - [x] List files with markdown content inside frontmatter blocks.
  - [x] Record compliance gaps in a checklist.
- **Timing:** 1-2 hours
- **Completed**: 2026-01-23

### Phase 2: Command standardization [COMPLETED]
- **Goal:** Align commands to command-structure.md format.
- **Tasks:**
  - [x] Ensure every command file includes `command`, `version`, `arguments`, `allowed-tools`, `argument-hint`, and delegation fields.
  - [x] Add `context_loading` blocks with lazy strategy and required context.
  - [x] Validate command frontmatter has YAML-only content.
- **Timing:** 1-2 hours
- **Completed**: 2026-01-23

### Phase 3: Agent standardization [COMPLETED]
- **Goal:** Align agent files to agent-structure.md format.
- **Tasks:**
  - [x] Add required frontmatter fields (`name`, `version`, `agent_type`, `permissions`, etc.).
  - [x] Add `context_loading`, `delegation`, and `lifecycle` sections.
  - [x] Ensure XML block structure aligns with xml-structure.md.
- **Timing:** 2-3 hours
- **Started:** 2026-01-23
- **Completed:** 2026-01-23

### Phase 4: Skill standardization [COMPLETED]
- **Goal:** Align skill files to skill-structure.md format.
- **Tasks:**
  - [x] Ensure skill frontmatter matches thin-wrapper or direct execution template.
  - [x] Add XML structure for execution flow where missing.
  - [x] Confirm context references are kept in body (not in frontmatter).
- **Timing:** 1-2 hours
- **Started:** 2026-01-23
- **Completed:** 2026-01-23

### Phase 5: OpenCode naming normalization [COMPLETED]
- **Goal:** Replace remaining "Claude" references in .opencode.
- **Tasks:**
  - [x] Replace "Claude" with "OpenCode" in scripts, rules, context, outputs.
  - [x] Update co-author lines to `OpenCode <noreply@opencode.ai>`.
  - [x] Validate any brand-specific references and document exceptions.
- **Timing:** 1 hour
- **Completed**: 2026-01-23

### Phase 6: Validation and audit closure [COMPLETED]
- **Goal:** Ensure all changes comply with standards.
- **Tasks:**
  - [x] Re-scan .opencode for frontmatter format violations (command README excluded).
  - [x] Validate command/agent/skill format alignment.
  - [x] Update implementation-003 status markers and summarize changes.
- **Timing:** 1-2 hours
- **Completed**: 2026-01-23

## Testing & Validation
- [x] Validate frontmatter blocks contain only YAML fields (command README excluded).
- [x] Confirm commands align with command-structure.md.
- [x] Confirm agents align with agent-structure.md.
- [x] Confirm skills align with skill-structure.md.
- [x] Ensure no remaining "Claude" references.

## Artifacts & Outputs
- plans/implementation-003.md

## Rollback/Contingency
- Revert to last known good .opencode snapshot if validation fails.
