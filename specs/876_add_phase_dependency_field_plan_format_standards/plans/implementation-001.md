# Implementation Plan: Task #876

- **Task**: 876 - Add phase dependency field to plan format standards
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/876_add_phase_dependency_field_plan_format_standards/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add explicit phase dependency notation to plan format standards, enabling direct DAG representation for parallel phase execution in team-implement. The notation `Dependencies: None | Phase {N} | Phase {N}, Phase {M}` will be added as an optional field between phase heading and Goal field. Backward compatibility is maintained by treating missing fields as `None` (phase can start immediately).

### Research Integration

Research report identified:
- Current skill-team-implement uses heuristic analysis to infer phase dependencies
- Industry DAG systems (Argo, Airflow, dbt) use explicit dependency declarations
- Notation should match existing task-level Dependencies field style
- Field must be optional for backward compatibility with existing plans

## Goals & Non-Goals

**Goals**:
- Add `Dependencies` field specification to plan-format.md phase format section
- Add `Dependencies` field to artifact-formats.md Implementation Plans template
- Document the notation syntax: `None`, `Phase {N}`, `Phase {N}, Phase {M}`
- Ensure backward compatibility (field is optional, missing = None)
- Provide example showing multi-phase dependencies

**Non-Goals**:
- Updating skill-team-implement to parse explicit dependencies (separate task)
- Updating planner-agent to generate dependencies (separate task)
- DAG validation or cycle detection (future enhancement)
- Visual dependency graph generation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent notation between files | Medium | Low | Use identical wording in both files |
| Breaking existing plan parsing | High | Low | Field is optional, no parsing changes needed |
| Ambiguous notation | Medium | Low | Provide clear examples and syntax definition |

## Implementation Phases

### Phase 1: Update plan-format.md [NOT STARTED]

- **Dependencies**: None
- **Goal**: Add Dependencies field to Implementation Phases format section in plan-format.md
- **Tasks**:
  - [ ] Add `- **Dependencies**: None | Phase {N} | Phase {N}, Phase {M}` line after phase heading, before Goal
  - [ ] Add notation explanation with examples
  - [ ] Update example skeleton to include Dependencies field
  - [ ] Note backward compatibility (field is optional)
- **Timing**: 30 minutes
- **Files to modify**:
  - `.claude/context/core/formats/plan-format.md` - Add Dependencies field (lines 76-83), update example skeleton (lines 218-227)
- **Verification**:
  - Dependencies field appears in format specification
  - All three notation variants documented
  - Example skeleton includes the field

---

### Phase 2: Update artifact-formats.md [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Add Dependencies field to Implementation Plans template in artifact-formats.md
- **Tasks**:
  - [ ] Add `**Dependencies**: None` line to Phase 1 template section
  - [ ] Add brief comment noting the field is optional
- **Timing**: 20 minutes
- **Files to modify**:
  - `.claude/rules/artifact-formats.md` - Add Dependencies field to Phase format (lines 74-89)
- **Verification**:
  - Dependencies field appears in artifact template
  - Field placement matches plan-format.md

---

### Phase 3: Verify Consistency and Document [NOT STARTED]

- **Dependencies**: Phase 1, Phase 2
- **Goal**: Verify both files are consistent and cross-reference each other
- **Tasks**:
  - [ ] Compare Dependencies field placement and wording between files
  - [ ] Ensure notation syntax is identical
  - [ ] Verify backward compatibility statement is present
- **Timing**: 15 minutes
- **Files to modify**:
  - None (verification only, may edit if inconsistencies found)
- **Verification**:
  - Both files use identical notation syntax
  - Field placement is consistent
  - Optional nature documented in both

## Testing & Validation

- [ ] Read updated plan-format.md and confirm Dependencies field is documented
- [ ] Read updated artifact-formats.md and confirm Dependencies field is in template
- [ ] Verify notation syntax is identical in both files
- [ ] Existing plans without Dependencies field remain valid (no breaking changes)

## Artifacts & Outputs

- `.claude/context/core/formats/plan-format.md` - Updated with Dependencies field
- `.claude/rules/artifact-formats.md` - Updated with Dependencies field
- `specs/876_add_phase_dependency_field_plan_format_standards/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the changes cause issues:
1. The Dependencies field is optional, so removal does not break existing plans
2. Revert changes to both files via git revert
3. Existing skill-team-implement heuristic parsing continues working unchanged
