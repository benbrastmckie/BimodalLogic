# Implementation Plan: Standardize command templates and migrate command docs
- **Task**: 152 - Standardize command templates and migrate command docs
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/152_standardize_command_templates_and_migrate_command_docs/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Research Inputs
- [specs/152_standardize_command_templates_and_migrate_command_docs/reports/research-001.md](../reports/research-001.md)

## Overview
Create a unified command documentation standard and template, then migrate all existing command docs and meta templates from legacy YAML/@subagent/XML markup to the new Markdown metadata and section order. Ensure commands explicitly cover status markers, lazy directory creation, registry sync expectations, and language/routing rules. Keep directories lazily created (project root + plans only when writing this plan) and align references with state schema and artifact management standards.

## Goals & Non-Goals
- **Goals**:
  - Publish a commands.md standard aligned with tasks/plan/status/artifact rules.
  - Add a reusable command-template.md in templates/ with the required metadata/sections.
  - Migrate all .opencode/command docs (and README) to the new format without legacy YAML/@ tags.
  - Update /meta-related templates/guides to emit the new structure and guidance.
- **Non-Goals**:
  - Changing command behaviors beyond documentation and template alignment.
  - Modifying registry files (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md) beyond documenting sync expectations.

## Risks & Mitigations
- Residual legacy YAML/@context/@subagent tags remain after migration → Run targeted grep/link checks and manual review per command.
- Inconsistent metadata/section ordering across commands → Enforce template-driven rewrite with checklist per doc.
- Missing lazy-creation/registry guidance in commands standard → Cross-link artifact-management/tasks/status-markers and include explicit bullets.
- Meta templates drift from new standard → Update meta templates in the same pass and include regression checklist.

## Implementation Phases

### Phase 1: Confirm scope and baseline requirements [NOT STARTED]
- **Goal:** Lock the standard/template requirements using research and current standards.
- **Tasks:**
  - [ ] Review research-001 and current standards (tasks, plan, artifact-management, state-schema, status-markers).
  - [ ] Inventory command docs and meta templates to confirm migration targets and legacy markers.
  - [ ] Define acceptance for language routing, lazy creation, and registry sync coverage.
- **Timing:** 1 hour

### Phase 2: Draft commands standard and command template [NOT STARTED]
- **Goal:** Author commands.md and command-template.md aligned with research outline and status/lazy-creation rules.
- **Tasks:**
  - [ ] Write commands.md covering scope, status markers, metadata, invocation, routing/context loading, artifact/state/registry updates, error handling, and examples.
  - [ ] Write command-template.md with Markdown metadata bullets and required sections (purpose, invocation, context, workflow, artifacts/state/registry, error handling, examples, related standards).
  - [ ] Cross-link tasks.md, plan.md, artifact-management.md, status-markers.md, patterns (if referenced).
- **Timing:** 1.5 hours

### Phase 3: Migrate .opencode/command docs and README [NOT STARTED]
- **Goal:** Apply the new template to all command docs and README.
- **Tasks:**
  - [ ] Remove YAML/front-matter and XML/@ tags; convert metadata to Markdown bullets per template.
  - [ ] Normalize section order and include language routing, lazy-creation, artifact/state/registry sync notes, and examples.
  - [ ] Update .opencode/command/README.md to reference the new standard/template and remove legacy language.
- **Timing:** 1.5 hours

### Phase 4: Update /meta templates and guidance [NOT STARTED]
- **Goal:** Align meta templates/guides with the new command standard.
- **Tasks:**
  - [ ] Update meta-related templates (e.g., meta-guide/orchestrator-template/subagent-template) to remove YAML/XML/@ syntax and reference the new command standard/template.
  - [ ] Add guidance for status markers, language routing, lazy creation, and registry sync expectations in meta outputs.
  - [ ] Ensure any /meta generation examples mirror the new command structure.
- **Timing:** 1 hour

### Phase 5: Validation and drift checks [NOT STARTED]
- **Goal:** Verify migrations and references are clean and consistent.
- **Tasks:**
  - [ ] Run grep sweep for legacy YAML front matter and @context/@subagent/XML markers in .opencode/command/ and meta templates; remediate stragglers.
  - [ ] Check links and paths for new commands.md/template references; ensure lazy-creation notes are present.
  - [ ] Final consistency review against research-001 acceptance points and status-marker alignment.
- **Timing:** 1 hour

## Testing & Validation
- [ ] Manual review of commands.md and command-template.md against research-001 and standards.
- [ ] Diff/grep to confirm removal of YAML/@ tags and presence of required metadata/sections.
- [ ] Link/path validation for cross-references to standards and templates.
- [ ] Spot-check examples for correct status markers, lazy-creation, and registry sync notes.

## Artifacts & Outputs
- plans/implementation-001.md (this plan)
- .opencode/context/core/standards/commands.md (new)
- .opencode/context/core/templates/command-template.md (new)
- Migrated .opencode/command/*.md and README.md (updated)
- Updated meta templates/guides (if present) aligned to new standard

## Rollback/Contingency
- If template/standard changes regress usability, revert updated command/meta docs to prior version via git and reapply using the template incrementally.
- If legacy tags remain, isolate offending files via grep and re-run Phase 3/4 tasks before proceeding.
