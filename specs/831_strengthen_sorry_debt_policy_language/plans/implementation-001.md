# Implementation Plan: Strengthen sorry-debt-policy language and guidance

- **Task**: 831 - strengthen_sorry_debt_policy_language
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/831_strengthen_sorry_debt_policy_language/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task revises the sorry-debt-policy.md to eliminate language that normalizes sorries as "acceptable" and adds explicit guidance on how to characterize sorries in reports and plans. The research identified 2 instances of problematic language in the policy file, 1 in verification-workflow.md, and 20+ examples of "acceptable sorry" patterns in archived artifacts. The implementation adds a new "Characterizing Sorries" section, strengthens the transitive inheritance guidance, and renames the problematic category from "Acceptable for Development" to "Tolerated During Development (Technical Debt)".

### Research Integration

Key findings from research-001.md:
- Line 34: "Construction Assumptions (Acceptable for Development)" must be renamed
- Line 35: "Accepted as axiomatic" normalizes acceptance language
- Lines 19-30: Transitive inheritance section lacks reporting guidance
- verification-workflow.md line 320: "acceptable if" language needs reframing
- Proposed new section with prohibited/required framing patterns

## Goals & Non-Goals

**Goals**:
- Replace "Acceptable for Development" category name with "Tolerated During Development (Technical Debt)"
- Add new section "Characterizing Sorries in Reports and Plans" with explicit guidance
- Strengthen transitive inheritance section with reporting requirements
- Update verification-workflow.md to remove "acceptable if" language

**Non-Goals**:
- Retroactively updating archived reports/plans (archives are historical records)
- Adding automated linting for "acceptable sorry" patterns (future enhancement)
- Modifying agent prompt templates (separate task if needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| New guidance too verbose | Medium | Medium | Use tables for examples, keep prose concise |
| Agents ignore new guidance | Medium | Low | Policy is already referenced from agent files |
| Cross-reference breakage | Low | Low | Only renaming category, not file paths |

## Implementation Phases

### Phase 1: Rename Category and Strengthen Description [NOT STARTED]

**Goal**: Replace "Acceptable for Development" with "Tolerated During Development (Technical Debt)" and update associated description

**Tasks**:
- [ ] Read sorry-debt-policy.md to confirm current state
- [ ] Change line 34 heading from "Construction Assumptions (Acceptable for Development)" to "Construction Assumptions (Tolerated During Development - Technical Debt)"
- [ ] Change line 35 from "Accepted as axiomatic" to "Treated as axiomatic within the current architecture. **This is still mathematical debt that must be documented and tracked.**"

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - category heading and description

**Verification**:
- Grep for "Acceptable" in sorry-debt-policy.md should return only the prohibition line 17
- Category heading includes "Technical Debt" label

---

### Phase 2: Strengthen Transitive Inheritance Section [NOT STARTED]

**Goal**: Add explicit reporting requirements to transitive inheritance section

**Tasks**:
- [ ] Replace lines 19-30 transitive section with strengthened version from research
- [ ] Add bullet points explaining inheritance mechanics
- [ ] Add "NO EXCEPTIONS" emphasis to publication requirement
- [ ] Add reporting requirement checklist

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - lines 19-30

**Verification**:
- Section includes "NO EXCEPTIONS" for publication
- Section includes 4-item reporting requirement checklist

---

### Phase 3: Add "Characterizing Sorries" Section [NOT STARTED]

**Goal**: Insert new comprehensive section before "## Sorry Categories" providing explicit guidance on sorry characterization in reports/plans

**Tasks**:
- [ ] Insert new section after line 31 (before Sorry Categories heading)
- [ ] Include "Guiding Principle" statement: "Document what exists, explain WHY it exists, specify the remediation path - never call a sorry acceptable"
- [ ] Include "Required Elements" checklist (5 items)
- [ ] Include "Prohibited Framing" list with specific phrases to avoid
- [ ] Include "Required Framing" list with replacement phrases
- [ ] Include "Example Transformations" table
- [ ] Include "Transitive Inheritance in Reports" subsection

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - insert section before Sorry Categories

**Verification**:
- New section appears before "## Sorry Categories"
- Contains prohibited patterns table
- Contains example transformations table

---

### Phase 4: Update verification-workflow.md [NOT STARTED]

**Goal**: Replace "acceptable if" language with "tolerated during development" framing

**Tasks**:
- [ ] Read verification-workflow.md to confirm line 320 context
- [ ] Replace "Exception" heading with "Development tolerance"
- [ ] Replace "acceptable if:" with "may be tolerated during development if:"
- [ ] Add critical note: "These sorries are NEVER acceptable for publication"
- [ ] Strengthen the bullet points to include "WHY" and "remediation path"

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/logic/processes/verification-workflow.md` - lines 320-324

**Verification**:
- No "acceptable if" pattern in file
- Contains "NEVER acceptable for publication" statement

---

### Phase 5: Final Verification [NOT STARTED]

**Goal**: Verify all changes are consistent and complete

**Tasks**:
- [ ] Grep for remaining "acceptable" occurrences in both files
- [ ] Verify sorry-debt-policy.md structure is intact
- [ ] Verify verification-workflow.md structure is intact
- [ ] Read both files end-to-end to confirm coherence

**Timing**: 10 minutes

**Files to modify**: None (verification only)

**Verification**:
- "acceptable" appears only in prohibition contexts (e.g., "never acceptable")
- Both files maintain valid markdown structure
- No orphaned cross-references

---

## Testing & Validation

- [ ] Grep for "Acceptable for Development" returns no results
- [ ] Grep for "acceptable if" returns no results in verification-workflow.md
- [ ] Grep for "Tolerated During Development" finds the renamed category
- [ ] New "Characterizing Sorries" section exists before "## Sorry Categories"
- [ ] Both files render valid markdown

## Artifacts & Outputs

- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - Updated policy with strengthened language
- `.claude/context/project/logic/processes/verification-workflow.md` - Updated with reframed sorry guidance
- `specs/831_strengthen_sorry_debt_policy_language/plans/implementation-001.md` - This plan file
- `specs/831_strengthen_sorry_debt_policy_language/summaries/implementation-summary-YYYYMMDD.md` - Summary upon completion

## Rollback/Contingency

Both files are tracked in git. If changes cause issues:
1. `git checkout HEAD -- .claude/context/project/lean4/standards/sorry-debt-policy.md`
2. `git checkout HEAD -- .claude/context/project/logic/processes/verification-workflow.md`

The changes are purely documentation updates with no code dependencies.
