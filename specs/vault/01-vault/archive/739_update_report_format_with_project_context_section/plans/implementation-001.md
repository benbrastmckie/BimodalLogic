# Implementation Plan: Task #739

- **Task**: 739 - update_report_format_with_project_context_section
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task adds a "Project Context" section to the research report template in report-format.md. The new section will appear after metadata and before Executive Summary, providing researchers with early orientation about how their work fits into the broader project. This is a straightforward template modification affecting a single file.

## Goals & Non-Goals

**Goals**:
- Add a new "Project Context" section to report-format.md
- Position the section between Metadata and Executive Summary
- Define clear fields: relation to project goals, component location, relevant modules, and integration points
- Update the example skeleton to demonstrate the new section

**Non-Goals**:
- Modifying existing research reports (they will use old format)
- Changing artifact-formats.md (that has its own simpler template)
- Adding validation logic for the new fields

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistency with artifact-formats.md | Low | Medium | Review both files; artifact-formats.md has simpler template that doesn't need this section |
| Unclear field descriptions | Low | Low | Provide clear guidance and examples for each field |

## Implementation Phases

### Phase 1: Add Project Context Section [NOT STARTED]

**Goal**: Insert the new Project Context section into report-format.md between Metadata and Executive Summary, with clear field definitions and example content.

**Tasks**:
- [ ] Add "Project Context" to the Structure section (after Metadata, before Executive Summary)
- [ ] Define the four required fields with descriptions
- [ ] Update the Example Skeleton with a Project Context section
- [ ] Ensure consistent formatting with existing sections

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/context/core/formats/report-format.md` - Add Project Context section definition and example

**Verification**:
- [ ] New section appears in Structure list at position 2 (after Metadata)
- [ ] All four fields are defined: relation to project goals, component location, relevant modules, integration points
- [ ] Example skeleton includes the new section with placeholder content
- [ ] Formatting is consistent with other sections

---

## Testing & Validation

- [ ] report-format.md renders correctly in markdown preview
- [ ] New section position is logical (after metadata, before executive summary)
- [ ] Field descriptions are clear and actionable
- [ ] Example skeleton demonstrates proper usage

## Artifacts & Outputs

- Modified `.claude/context/core/formats/report-format.md` with new Project Context section

## Rollback/Contingency

Revert changes to report-format.md using git if the new section causes issues with existing workflows. The change is isolated to a single file with no dependencies.
