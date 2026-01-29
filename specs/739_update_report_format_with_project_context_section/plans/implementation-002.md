# Implementation Plan: Task #739

- **Task**: 739 - update_report_format_with_project_context_section
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Summary

**Previous version**: implementation-001.md (generic Project Context section for all reports)

**Key change**: The Project Context section is now **Lean-specific** and focuses on **proof dependencies** rather than generic project orientation. The goal is to help researchers see how a topic fits into the Lean codebase by documenting:
- What depends on this result (downstream)
- What this result depends on (upstream)
- Alternative paths or extraneous elements
- Potential new directions

This provides a big-picture perspective by describing relationships to existing or planned results.

## Overview

This task adds a **Lean-specific** "Project Context" section to the research report template in report-format.md. The section appears after metadata and before Executive Summary, but is **only relevant for Lean research reports** where understanding proof dependencies is essential. For other languages, the section may be omitted.

## Goals & Non-Goals

**Goals**:
- Add a "Project Context" section conditional on `language: lean`
- Focus fields on proof dependency relationships:
  - Upstream dependencies (what this depends on)
  - Downstream dependents (what depends on this)
  - Alternative paths (where elements provide redundancy)
  - Potential extensions (new directions this enables)
- Position between Metadata and Executive Summary for early orientation
- Clarify this section is optional for non-Lean reports

**Non-Goals**:
- Making this section mandatory for all report types
- Adding integration point or module location fields (the original generic approach)
- Modifying existing research reports

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Researchers unsure when to include section | Low | Medium | Add clear guidance that section is for Lean reports only |
| Fields too abstract without examples | Low | Low | Provide concrete example showing proof dependencies |

## Implementation Phases

### Phase 1: Add Lean-Specific Project Context Section [NOT STARTED]

**Goal**: Insert a conditional Project Context section into report-format.md that focuses on proof dependency relationships for Lean research.

**Tasks**:
- [ ] Add "Project Context (Lean only)" to the Structure section with conditional guidance
- [ ] Define the four dependency-focused fields:
  1. **Upstream Dependencies**: Existing or planned theorems/definitions this builds upon
  2. **Downstream Dependents**: Existing or planned results that will use this
  3. **Alternative Paths**: Where this provides redundancy or different approaches
  4. **Potential Extensions**: New directions this enables or suggests
- [ ] Update the Example Skeleton with a Lean-oriented Project Context example
- [ ] Add note clarifying section is optional for non-Lean reports

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/context/core/formats/report-format.md` - Add conditional Project Context section

**Verification**:
- [ ] Section clearly marked as Lean-specific
- [ ] All four dependency-focused fields are defined
- [ ] Example shows proof relationships (e.g., "depends on `Soundness`, enables `Completeness`")
- [ ] Non-Lean reports guidance clarifies section can be omitted

---

## Testing & Validation

- [ ] report-format.md renders correctly in markdown preview
- [ ] Section guidance clearly indicates Lean-only applicability
- [ ] Field descriptions emphasize dependency/relationship tracking
- [ ] Example demonstrates proof dependency documentation

## Artifacts & Outputs

- Modified `.claude/context/core/formats/report-format.md` with Lean-specific Project Context section

## Rollback/Contingency

Revert changes to report-format.md using git if the new section causes issues. The change is isolated to a single file.
