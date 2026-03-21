# Implementation Plan: Task #453

- **Task**: 453 - Add Ability and Free Choice Modal Extension to Logos
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Priority**: Medium
- **Dependencies**: Task 451 (completed)
- **Research Inputs**: specs/453_add_ability_free_choice_modal_extension/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/formats/plan-format.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true (stub only, no proofs required)

## Overview

This task adds the Agential Extension to Logos, implementing ability modals and free choice modals as a stub layer following the established pattern of Epistemic, Normative, and Spatial extensions. The research phase identified that "Agential" is the appropriate naming (broader scope than just "Ability"), and that ability modals require dependence domains while free choice modals fit naturally with Logos's hyperintensional foundation.

### Research Integration

Key findings from research-001.md integrated into this plan:
- **Extension name**: "Agential" (encompasses both ability and free choice)
- **Position**: Agential layer (requires at least one middle extension as prerequisite)
- **Operators**: Can_a, Able_a (ability); FP, FF, Ch (free choice)
- **Semantic approach**: Dependence domains for ability; hyperintensional for free choice
- **Template pattern**: Follow existing Spatial.lean stub structure (most detailed existing stub)

## Goals & Non-Goals

**Goals**:
- Create Agential Extension stub file following existing pattern
- Document ability operators (Can_a, Able_a) with semantic intuitions
- Document free choice operators (FP, FF, Ch) with semantic intuitions
- Add Section 6 content to layer-extensions.md for Agential Extension
- Add semantic clauses placeholders to recursive-semantics.md
- Update IMPLEMENTATION_STATUS.md to include Agential stub
- Update ROADMAP.md to include Agential Extension phase
- Add new terms to GLOSSARY.md
- Ensure lake build succeeds

**Non-Goals**:
- Implement actual semantics (stub only)
- Create proofs or theorems
- Add STIT branching-time semantics (noted as future extension)
- Implement interaction axioms between ability and other operators

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Namespace conflicts with existing code | Medium | Low | Use established SubTheories.Agential namespace pattern |
| Build failure from imports | Medium | Low | Follow existing stub patterns exactly; test build after stub creation |
| Documentation inconsistencies | Low | Medium | Cross-reference layer-extensions.md with recursive-semantics.md during updates |
| Missing glossary terms | Low | Medium | Review research report for all new terms to add |

## Implementation Phases

### Phase 1: Create Agential Extension Stub [COMPLETED]

**Goal**: Create the Lean stub file for Agential Extension following the Spatial.lean pattern

**Tasks**:
- [ ] Create directory `Theories/Logos/SubTheories/Agential/`
- [ ] Create `Theories/Logos/SubTheories/Agential/Agential.lean` stub file with:
  - Module docstring explaining extension purpose and operators
  - Operator table for ability modals (Can_a, Able_a, Cannot_a)
  - Operator table for free choice modals (FP, FF, Ch)
  - Frame extension documentation (Agent set, Choice function, Capacity assignment, Dependence relation)
  - Key axioms (tentative) with schemas
  - Status, prerequisites, and timeline information
  - Namespace with extension point comments
- [ ] Create `Theories/Logos/SubTheories/Agential.lean` re-export file
- [ ] Verify `lake build` succeeds

**Timing**: 1 hour

**Files to modify**:
- `Theories/Logos/SubTheories/Agential/Agential.lean` - NEW
- `Theories/Logos/SubTheories/Agential.lean` - NEW (re-export)

**Verification**:
- `lake build` completes without errors
- Stub file follows pattern established by Spatial.lean

---

### Phase 2: Update layer-extensions.md [COMPLETED]

**Goal**: Add comprehensive Section 6 documentation for Agential Extension

**Tasks**:
- [ ] Update Agential Extension section (currently placeholder at line 279-288) with:
  - Frame extension details (Agent set, Choice function, Dependence relation)
  - Ability operators table with notations and readings
  - Free choice operators table with notations and readings
  - Key axioms (tentative) with explanations
  - Example applications for AI planning scenarios
  - Free choice permission discussion (Kamp's paradox and hyperintensional solution)
  - Open questions about STIT semantics vs simpler approach
- [ ] Update Implementation Status table to show Agential with [DETAILS] status
- [ ] Ensure cross-references to recursive-semantics.md Section 6 are correct

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/docs/research/layer-extensions.md` - Section 6 expansion

**Verification**:
- Section follows structure of other extension sections
- Operator tables are complete and consistent with stub file

---

### Phase 3: Update recursive-semantics.md [COMPLETED]

**Goal**: Add semantic clause placeholders for Agential Extension operators

**Tasks**:
- [ ] Expand Agential Extension section (currently lines 567-585) with:
  - Frame extension formal specification (Agent set A, Choice function C, Dependence relation D)
  - Placeholder truth conditions for ability operators with [DETAILS] markers
  - Placeholder truth conditions for free choice operators with [DETAILS] markers
  - Open questions for semantic design decisions
- [ ] Ensure consistency with layer-extensions.md Section 6

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/docs/research/recursive-semantics.md` - Agential Extension section

**Verification**:
- Semantic placeholders match operator tables in layer-extensions.md
- [DETAILS] markers indicate pending specification

---

### Phase 4: Update Project Documentation [COMPLETED]

**Goal**: Update IMPLEMENTATION_STATUS.md, ROADMAP.md, and GLOSSARY.md

**Tasks**:
- [ ] Update `IMPLEMENTATION_STATUS.md`:
  - Add Agential/ section under Extension Modules (Stubs)
  - List planned content (ability operators, free choice operators)
  - Update "What's Not Implemented" section to include ability and free choice operators
- [ ] Update `ROADMAP.md`:
  - Add Phase 8: Agential Extension after Phase 7 Integration
  - Include estimated effort (30-40 hours)
  - List deliverables (ability operators, free choice operators, multi-agent interaction)
  - Add dependencies (requires at least one middle extension)
- [ ] Update `GLOSSARY.md`:
  - Add ability modal terms (ability modal, Can_a, Able_a, dependence domain)
  - Add free choice terms (free choice modal, FP, FF, Ch, free choice permission paradox)
  - Add STIT reference (STIT logic, sees to it that)
  - Add agent-related terms if missing

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/docs/project-info/IMPLEMENTATION_STATUS.md`
- `Theories/Logos/docs/project-info/ROADMAP.md`
- `Theories/Logos/docs/reference/GLOSSARY.md`

**Verification**:
- All new terms from research appear in GLOSSARY.md
- ROADMAP.md phase numbering is consistent
- IMPLEMENTATION_STATUS.md accurately reflects stub status

---

### Phase 5: Final Verification and Testing [COMPLETED]

**Goal**: Verify all changes work together and build succeeds

**Tasks**:
- [ ] Run `lake build` and verify no errors
- [ ] Verify all cross-references between documentation files work
- [ ] Review consistency between:
  - Stub file operators and layer-extensions.md operators
  - layer-extensions.md and recursive-semantics.md
  - GLOSSARY.md terms and documented operators
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds
- All documentation files have consistent operator naming
- No broken cross-references

## Testing & Validation

- [ ] `lake build` succeeds after stub file creation (Phase 1)
- [ ] `lake build` succeeds after all changes (Phase 5)
- [ ] Stub file follows Spatial.lean pattern
- [ ] Operator tables in stub match documentation
- [ ] All terms from research report appear in GLOSSARY.md
- [ ] ROADMAP.md phase numbers are sequential and dependencies correct
- [ ] Cross-references between layer-extensions.md and recursive-semantics.md are valid

## Artifacts & Outputs

- `Theories/Logos/SubTheories/Agential/Agential.lean` - Agential Extension stub
- `Theories/Logos/SubTheories/Agential.lean` - Re-export file
- `Theories/Logos/docs/research/layer-extensions.md` - Updated Section 6
- `Theories/Logos/docs/research/recursive-semantics.md` - Updated Agential section
- `Theories/Logos/docs/project-info/IMPLEMENTATION_STATUS.md` - Updated
- `Theories/Logos/docs/project-info/ROADMAP.md` - Updated with Phase 8
- `Theories/Logos/docs/reference/GLOSSARY.md` - New terms added
- `specs/453_add_ability_free_choice_modal_extension/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation fails:
1. Revert Lean stub files (new files, can simply delete)
2. Use git diff to identify documentation changes
3. Restore original documentation from git
4. Run `lake build` to verify clean state

All changes are additive (new files or expanded sections), so rollback is straightforward via git.
