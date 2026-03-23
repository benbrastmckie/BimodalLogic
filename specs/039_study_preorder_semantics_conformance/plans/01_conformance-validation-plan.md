# Implementation Plan: Task #39

- **Task**: 39 - Study preorder semantics conformance with Task Semantics specifications
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (research completed)
- **Research Inputs**:
  - reports/01_teammate-a-findings.md
  - reports/01_teammate-b-findings.md
  - reports/02_team-synthesis.md
  - reports/03_parametric-taskframe-research.md
- **Artifacts**: plans/01_conformance-validation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task validates that the preorder semantics adopted for the FMCS/CanonicalMCS construction correctly conforms to the Task Semantics specifications. Based on comprehensive research, the architecture uses a **two-layer design** where:

1. **Layer 1 (FMCS/CanonicalMCS)**: Uses Preorder only for TruthLemma proof
2. **Layer 2 (ParametricCanonicalTaskFrame)**: Provides full TaskFrame conformance with W/D separation

The implementation focuses on documentation validation, deprecation cleanup, and creating a specification document that demonstrates TaskFrame conformance.

### Research Integration

Key findings from 4 research reports:
- The Preorder FMCS does NOT need TaskFrame conformance (intentional design)
- `ParametricCanonicalTaskFrame` provides W/D separation (W = all MCSs, D = parameter type)
- All three TaskFrame axioms (nullity_identity, forward_comp, converse) are sorry-free
- Deprecated `denseCanonicalTaskFrame` has W=D conflation error and should not be used

## Goals & Non-Goals

**Goals**:
- Verify Bundle/README.md accurately reflects the two-layer architecture
- Document ParametricCanonicalTaskFrame as the recommended approach for TaskFrame conformance
- Update or mark deprecated references to old W=D constructions
- Create clear specification document showing TaskFrame axiom satisfaction

**Non-Goals**:
- Modifying the Lean proof structure (already verified as correct)
- Proving additional lemmas (TaskFrame axioms already sorry-free)
- Removing deprecated code (may break dependent modules)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Documentation inconsistencies | Medium | Medium | Cross-reference multiple source files |
| Deprecated code still referenced | Low | Medium | Add clear deprecation notices rather than removing |

## Implementation Phases

### Phase 1: Documentation Verification [NOT STARTED]

**Goal**: Verify existing documentation accurately describes the two-layer architecture

**Tasks**:
- [ ] Verify Bundle/README.md describes two-layer architecture correctly
- [ ] Check CanonicalDomain.lean deprecation notices are clear
- [ ] Verify ParametricCanonical.lean module docstring is accurate
- [ ] Review SeparatedTaskFrame.lean documentation for W/D separation explanation

**Timing**: 45 minutes

**Files to review**:
- `Theories/Bimodal/Metalogic/Bundle/README.md` - Main architecture docs
- `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean` - Deprecated W=D construction
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` - W/D separated construction
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedTaskFrame.lean` - TimelineQuot instantiation

**Verification**:
- All reviewed files describe the same architectural pattern consistently
- Deprecated constructions are clearly marked

---

### Phase 2: Create Conformance Specification Document [NOT STARTED]

**Goal**: Create a clear specification document showing how the system conforms to Task Semantics

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/TaskFrameConformance.md`
- [ ] Document the TaskFrame type class and its three axioms
- [ ] Show how ParametricCanonicalTaskFrame satisfies each axiom
- [ ] Explain the W/D separation principle
- [ ] Cross-reference to TaskFrame.lean specification

**Timing**: 1 hour

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Algebraic/TaskFrameConformance.md` - new specification document

**Verification**:
- Document clearly explains TaskFrame conformance
- All three axioms (nullity_identity, forward_comp, converse) are addressed
- W/D separation is explained with examples

---

### Phase 3: Update Deprecation Notices [NOT STARTED]

**Goal**: Ensure deprecated constructions have clear warnings pointing to recommended alternatives

**Tasks**:
- [ ] Review CanonicalDomain.lean deprecation warning for denseCanonicalTaskFrame
- [ ] Add reference to ParametricCanonicalTaskFrame as replacement
- [ ] Verify canonicalR_irreflexive_axiom deprecation status is documented
- [ ] Add module-level note about W=D conflation error if missing

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean` - enhance deprecation notices

**Verification**:
- All deprecated constructions clearly point to ParametricCanonicalTaskFrame
- W=D conflation error is explicitly mentioned
- No ambiguity about which construction to use

---

### Phase 4: Update Algebraic README [NOT STARTED]

**Goal**: Create or update Algebraic module README to document the recommended approach

**Tasks**:
- [ ] Check if Theories/Bimodal/Metalogic/Algebraic/README.md exists
- [ ] Create or update README with ParametricCanonicalTaskFrame as primary construction
- [ ] Document the D-parametric design (Int, Rat, TimelineQuot instantiations)
- [ ] Cross-reference to Bundle/README.md for Layer 1 (FMCS) documentation

**Timing**: 45 minutes

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - module documentation

**Verification**:
- README clearly states ParametricCanonicalTaskFrame is the recommended approach
- Instantiation examples are provided
- Architecture relationship to Bundle module is explained

---

## Testing & Validation

- [ ] `lake build` succeeds after documentation changes
- [ ] All markdown files render correctly (no broken links)
- [ ] Grep for "denseCanonicalTaskFrame" usage shows appropriate deprecation awareness
- [ ] TaskFrameConformance.md is self-contained and understandable

## Artifacts & Outputs

- `plans/01_conformance-validation-plan.md` - This implementation plan
- `Theories/Bimodal/Metalogic/Algebraic/TaskFrameConformance.md` - Conformance specification
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - Module documentation (new or updated)
- Updated deprecation notices in `CanonicalDomain.lean`

## Rollback/Contingency

All changes are documentation-only. Rollback via git revert if any documentation introduces errors. No Lean code changes are planned, so lake build should not be affected.
