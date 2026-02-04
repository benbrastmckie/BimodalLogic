# Implementation Plan: Task #859

- **Task**: 859 - establish_axiom_debt_policy
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/859_establish_axiom_debt_policy/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This implementation expands the existing sorry-debt-policy.md into a comprehensive proof-debt-policy.md that covers both sorries and axioms as forms of mathematical debt. The unified policy document will preserve all existing sorry content while adding parallel axiom content. Additionally, plan-format.md and report-format.md will be updated with "Axiom Characterization" sections mirroring the existing "Sorry Characterization" sections.

### Research Integration

- Research report analyzed existing sorry-debt-policy.md structure (9 sections, 187 lines)
- Identified axiom framing rules from Task 857 research ("Axioms are not an acceptable solution")
- Proposed axiom taxonomy: Construction Assumptions, Existence Assumptions, Documentation Examples, Fundamental Obstacles
- Defined unified "proof debt" terminology covering sorries + axioms

## Goals & Non-Goals

**Goals**:
- Rename sorry-debt-policy.md to proof-debt-policy.md
- Preserve all existing sorry documentation unchanged
- Add parallel axiom sections with appropriate framing rules
- Add Axiom Characterization sections to plan-format.md and report-format.md
- Establish consistent framing rules for axioms across all format files

**Non-Goals**:
- Modifying existing sorry framing rules
- Updating SORRY_REGISTRY.md (name retained for historical continuity)
- Changing repository health metrics computation
- Adding new automated axiom detection tooling

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| References to sorry-debt-policy.md become stale | Medium | Low | Search codebase for references and update |
| Parallel structure creates duplication | Low | Medium | Use clear section headers and cross-references |
| Cognitive overload from longer policy document | Low | Low | Maintain parallel structure for familiarity |

## Implementation Phases

### Phase 1: Rename and Expand Policy File [NOT STARTED]

**Goal**: Transform sorry-debt-policy.md into comprehensive proof-debt-policy.md covering both sorries and axioms.

**Tasks**:
- [ ] Rename `.claude/context/project/lean4/standards/sorry-debt-policy.md` to `proof-debt-policy.md`
- [ ] Update Overview section to cover both sorries and axioms
- [ ] Expand Philosophy section with unified "proof debt" concept
- [ ] Add "Characterizing Axioms in Reports and Plans" section (parallel to sorries section)
- [ ] Add "Axiom Categories" section with 4-category taxonomy
- [ ] Update "Discovery Protocol" to cover both sorries and axioms
- [ ] Update "Metrics Integration" to document both sorry_count and axiom_count
- [ ] Update "Usage Checklist" to cover both

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md` -> `proof-debt-policy.md` - Rename and expand with axiom content

**Verification**:
- File renamed successfully
- All existing sorry content preserved verbatim
- New axiom sections follow parallel structure
- Document compiles without formatting errors

---

### Phase 2: Update plan-format.md [NOT STARTED]

**Goal**: Add "Axiom Characterization (Lean plans only)" section to plan-format.md with framing rules parallel to Sorry Characterization.

**Tasks**:
- [ ] Add "Axiom Characterization (Lean plans only)" section after line 133 (after Sorry Characterization)
- [ ] Include Applicability, Purpose, Required Elements
- [ ] Add Framing Rules with prohibited/required phrases
- [ ] Add example showing proper axiom characterization format

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/formats/plan-format.md` - Add Axiom Characterization section

**Verification**:
- New section follows parallel structure to Sorry Characterization
- Framing rules are consistent with proof-debt-policy.md
- Example demonstrates proper usage

---

### Phase 3: Update report-format.md [NOT STARTED]

**Goal**: Add "Axiom Characterization (Lean reports only)" section to report-format.md with framing rules parallel to Sorry Characterization.

**Tasks**:
- [ ] Add "Axiom Characterization (Lean reports only)" section after line 85 (after Sorry Characterization)
- [ ] Include Applicability, Purpose, Required Elements
- [ ] Add Framing Rules with prohibited/required phrases
- [ ] Add example showing proper axiom characterization format

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/formats/report-format.md` - Add Axiom Characterization section

**Verification**:
- New section follows parallel structure to Sorry Characterization
- Required elements differ appropriately (Current State, Transitive Impact, Remediation Path, Publication Status)
- Example demonstrates proper usage

---

### Phase 4: Cross-Reference Validation [NOT STARTED]

**Goal**: Verify all references are updated and documentation is internally consistent.

**Tasks**:
- [ ] Search for references to sorry-debt-policy.md in codebase
- [ ] Update any found references to proof-debt-policy.md
- [ ] Verify cross-references between files are correct
- [ ] Confirm framing rules are consistent across all three files

**Timing**: 20 minutes

**Files to modify**:
- Any files referencing sorry-debt-policy.md (to be identified via grep)

**Verification**:
- No remaining references to sorry-debt-policy.md
- All cross-references resolve correctly
- Framing rules are consistent across proof-debt-policy.md, plan-format.md, and report-format.md

## Testing & Validation

- [ ] proof-debt-policy.md exists and contains both sorry and axiom documentation
- [ ] sorry-debt-policy.md no longer exists (renamed)
- [ ] plan-format.md contains Axiom Characterization section
- [ ] report-format.md contains Axiom Characterization section
- [ ] All prohibited phrases lists match across files
- [ ] All required phrases lists match across files
- [ ] No dangling references to old filename

## Artifacts & Outputs

- `.claude/context/project/lean4/standards/proof-debt-policy.md` - Expanded policy document
- `.claude/context/core/formats/plan-format.md` - Updated with Axiom Characterization
- `.claude/context/core/formats/report-format.md` - Updated with Axiom Characterization
- `specs/859_establish_axiom_debt_policy/summaries/implementation-summary-{DATE}.md` - Implementation summary

## Rollback/Contingency

If implementation fails:
1. Restore sorry-debt-policy.md from git (git checkout sorry-debt-policy.md)
2. Revert plan-format.md changes (git checkout plan-format.md)
3. Revert report-format.md changes (git checkout report-format.md)
4. Review failure reason and adjust approach
