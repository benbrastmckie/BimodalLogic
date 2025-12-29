# Implementation Plan v2 (Reversed): Standardize command templates and migrate command docs
- **Task**: 152 - Standardize command templates and migrate command docs
- **Status**: [COMPLETED]
- **Started**: 2025-12-23T14:05:00Z
- **Completed**: 2025-12-23T15:50:00Z
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: ../reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false
- **Delta (v2 vs v1)**: Reverse direction — migrate command docs and meta templates **from Markdown metadata/section order back to YAML front matter + @subagent/XML markup**, matching the styling in `.opencode/command/meta.md` and `.opencode/command/context.md`; update templates/standards to enforce this markup.

## Overview
Reorient the effort to restore YAML/@subagent/XML markup as the authoritative format for command docs and meta templates. Align all command documentation, templates, and meta outputs to the patterns demonstrated in `.opencode/command/meta.md` and `.opencode/command/context.md`, ensuring status markers, lazy directory rules, and registry/state sync guidance remain explicit. Preserve lazy creation (no new project roots/subdirs beyond this plan write) and keep references compliant with artifact management and state schema.

## Goals & Non-Goals
- **Goals**:
  - Publish a `commands.md` standard that prescribes YAML front matter and @subagent/XML workflow blocks consistent with `.opencode/command/meta.md` and `.opencode/command/context.md`.
  - Provide a `command-template.md` using YAML metadata and @subagent/XML sections (context, role, task, workflow) with status-marker hooks and lazy-creation notes.
  - Migrate all `.opencode/command/*.md` (and README) to the restored YAML/@subagent/XML format.
  - Update /meta templates/guides to emit the YAML/@subagent/XML structure and examples.
- **Non-Goals**:
  - Changing runtime behavior of commands; scope is documentation/templates.
  - Altering project numbering or creating new project directories.

## Risks & Mitigations
- **Residual Markdown metadata** remains → Grep for Markdown bullet metadata; enforce YAML headers and XML blocks per template.
- **Inconsistent section ordering** → Lock ordering to meta/context exemplars; provide checklist in template.
- **Lazy-creation/registry guidance omitted** → Embed explicit bullets in standard/template; cross-link artifact-management/tasks/status-markers.
- **Meta templates drift** → Update meta templates in same pass; add regression checklist.

## Implementation Phases

### Phase 1: Confirm scope and exemplars [COMPLETED] [PASS]
(Started: 2025-12-23T14:05:00Z)
(Completed: 2025-12-23T15:10:00Z)
- **Goal:** Lock requirements using research-001, standards, and exemplar command docs.
- **Tasks:**
  - [x] Review research-001 and current standards (tasks, plan, artifact-management, state-schema, status-markers).
  - [x] Inventory command docs and meta templates to identify Markdown metadata and missing YAML/@subagent/XML blocks.
  - [x] Extract required YAML keys/sections from `.opencode/command/meta.md` and `.opencode/command/context.md` as canonical ordering.
- **Timing:** 1 hour

### Phase 2: Draft commands standard and command template (YAML/XML) [COMPLETED] [PASS]
(Started: 2025-12-23T14:10:00Z)
(Completed: 2025-12-23T15:20:00Z)
- **Goal:** Author `commands.md` and `command-template.md` using YAML front matter + @subagent/XML workflow blocks.
- **Tasks:**
  - [x] Write `commands.md` covering scope, status markers, YAML metadata keys, @subagent/XML workflow patterns, invocation, routing/context loading, artifact/state/registry updates, error handling, and examples.
  - [x] Write `command-template.md` with YAML front matter (name, agent, description, language, context) and XML sections (context, role, task, workflow_execution, routing_intelligence, validation, quality_standards).
  - [x] Cross-link tasks.md, plan.md, artifact-management.md, status-markers.md, and patterns (if referenced).
- **Timing:** 1.5 hours

### Phase 3: Migrate `.opencode/command` docs and README to YAML/XML [COMPLETED] [PASS]
(Started: 2025-12-23T14:20:00Z)
(Completed: 2025-12-23T15:35:00Z)
- **Goal:** Apply the new template to all command docs and README.
- **Tasks:**
  - [x] Replace Markdown bullet metadata with YAML front matter; add @subagent/XML blocks mirroring meta/context exemplars.
  - [x] Normalize section order and include language routing, lazy-creation, artifact/state/registry sync notes, and examples.
  - [x] Update `.opencode/command/README.md` to reference the YAML/XML standard/template and remove Markdown-metadata guidance.
- **Timing:** 1.5 hours

### Phase 4: Update /meta templates and guidance to YAML/XML [COMPLETED] [PASS]
(Started: 2025-12-23T14:40:00Z)
(Completed: 2025-12-23T15:40:00Z)
- **Goal:** Align meta templates/guides with the YAML/@subagent/XML command standard.
- **Tasks:**
  - [x] Update meta templates (e.g., meta-guide/orchestrator-template/subagent-template) to emit YAML front matter and @subagent/XML workflow sections.
  - [x] Add guidance for status markers, language routing, lazy creation, and registry sync expectations in meta outputs.
  - [x] Ensure /meta generation examples mirror the restored command structure.
- **Timing:** 1 hour

### Phase 5: Validation and drift checks [COMPLETED] [PASS]
(Started: 2025-12-23T15:40:00Z)
(Completed: 2025-12-23T15:50:00Z)
- **Goal:** Verify migrations and references are clean and consistent.
- **Tasks:**
  - [x] Run grep sweep for Markdown metadata bullets and missing YAML headers; check for legacy Markdown-only section ordering.
  - [x] Run grep for missing @subagent/XML blocks; verify ordering matches meta/context exemplars.
  - [x] Final consistency review against research-001 acceptance points and status-marker alignment.
- **Timing:** 1 hour

## Testing & Validation
- [ ] Manual review of `commands.md` and `command-template.md` against research-001, meta/context exemplars, and standards.
- [ ] Diff/grep to confirm removal of Markdown metadata and presence of YAML front matter plus @subagent/XML blocks.
- [ ] Link/path validation for cross-references to standards and templates.
- [ ] Spot-check examples for correct status markers, lazy-creation, and registry sync notes.

## Artifacts & Outputs
- plans/implementation-002.md (this plan)
- .opencode/context/common/standards/commands.md (updated to YAML/@subagent/XML requirements)
- .opencode/context/common/templates/command-template.md (YAML/XML template)
- Migrated .opencode/command/*.md and README.md (updated)
- Updated meta templates/guides aligned to YAML/XML standard

## Rollback/Contingency
- If YAML/XML migrations regress usability, revert specific command/meta docs via git and reapply using the updated template incrementally.
- If Markdown metadata persists, isolate offending files via grep and re-run Phase 3/4 tasks before proceeding.
