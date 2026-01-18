# Implementation Plan: Task #577

- **Task**: 577 - prove_compound_formula_bridge_cases
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: 576 (completed)
- **Research Inputs**: specs/577_prove_compound_formula_bridge_cases/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/formats/plan-format.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete the 4 compound formula cases in `truth_at_implies_semantic_truth` theorem in FiniteCanonicalModel.lean. The cases (imp, box, all_past, all_future) establish the bridge between MCS membership and semantic truth for compound formulas. This task builds on the proven `closure_mcs_negation_complete` from task 576.

### Research Integration

Key findings from research-001.md:
- `closure_mcs_negation_complete` (line 681) is PROVEN and enables all cases
- `mcs_imp_iff_material` (lines 1365-1400) has 2 sorries that must be filled first
- Box case uses `mcs_box_accessibility` from CanonicalModel.lean (PROVEN)
- Temporal cases have potential reflexivity issue (strict vs reflexive semantics)
- Alternative path via `representation_theorem_backward_empty` exists as fallback

## Goals & Non-Goals

**Goals**:
- Prove `mcs_imp_iff_material` by filling 2 sorries using negation completeness
- Prove imp case in `truth_at_implies_semantic_truth` using material implication equivalence
- Prove box case using modal accessibility properties
- Assess and prove temporal cases (all_past, all_future) where possible

**Non-Goals**:
- Restructuring the overall completeness architecture
- Proving alternative completeness paths (already proven via Strategy C)
- Modifying the temporal semantics (strict semantics are architectural)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Temporal reflexivity mismatch | High | Medium | Document as limitation, rely on alternative path |
| Proof complexity escalation | Medium | Low | Start with imp case as proof of concept |
| Unexpected dependencies | Medium | Low | Research identified all required theorems |
| Type mismatch in MCS bridge | Medium | Low | Use `worldStateFromClosureMCS_models_iff` patterns |

## Implementation Phases

### Phase 1: Complete mcs_imp_iff_material [NOT STARTED]

**Goal**: Fill the 2 sorries in `mcs_imp_iff_material` theorem to establish material implication equivalence for MCS

**Tasks**:
- [ ] Read current state of `mcs_imp_iff_material` (lines 1365-1400)
- [ ] Fill forward direction sorry (line 1388) using `closure_mcs_imp_closed`
- [ ] Fill backward direction sorry (line 1400) using `closure_mcs_negation_complete` and consistency argument
- [ ] Verify theorem compiles with no errors

**Timing**: 1.5 hours

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModel/FiniteCanonicalModel.lean` - lines 1365-1400

**Proof Strategy**:
- Forward: If `(psi -> chi) in S` and `psi in S`, then `chi in S` by `closure_mcs_imp_closed`
- Backward: Contrapositive - if `(psi -> chi) not in S`, by negation completeness `(psi -> chi).neg in S`, then derive `psi in S` and `chi not in S`

**Verification**:
- `lake build Logos` compiles without errors
- `lean_diagnostic_messages` shows no errors in mcs_imp_iff_material

---

### Phase 2: Prove imp case in truth_at_implies_semantic_truth [NOT STARTED]

**Goal**: Complete the imp case (line 3959) using the proven `mcs_imp_iff_material`

**Tasks**:
- [ ] Read current state of `truth_at_implies_semantic_truth` imp case
- [ ] Connect `truth_at` semantics to MCS membership via world state construction
- [ ] Apply `mcs_imp_iff_material` to establish material implication equivalence
- [ ] Use `worldStateFromClosureMCS_models_iff` to bridge to `FiniteWorldState.models`
- [ ] Verify imp case compiles without sorry

**Timing**: 1 hour

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModel/FiniteCanonicalModel.lean` - line 3959

**Proof Sketch**:
```
| Formula.imp psi chi =>
  -- h_truth : truth_at (SemanticCanonicalModel phi) tau 0 (psi.imp chi)
  -- Goal: (tau.states 0 ht).toFiniteWorldState.models (psi.imp chi) h_mem
  -- Use: MCS-derived world state has mcs_imp_iff_material property
  -- Use: worldStateFromClosureMCS_models_iff connects membership to models
```

**Verification**:
- `lean_goal` shows no remaining goals at imp case
- `lean_diagnostic_messages` shows no errors

---

### Phase 3: Prove box case in truth_at_implies_semantic_truth [NOT STARTED]

**Goal**: Complete the box case (line 3969) using modal accessibility properties

**Tasks**:
- [ ] Read current state of box case
- [ ] Identify how SemanticCanonicalModel handles box accessibility
- [ ] Apply `mcs_box_accessibility` from CanonicalModel.lean
- [ ] Connect box semantics (all worlds satisfy psi) to MCS membership
- [ ] Verify box case compiles without sorry

**Timing**: 1 hour

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModel/FiniteCanonicalModel.lean` - line 3969

**Key Theorems**:
- `mcs_box_accessibility` (CanonicalModel.lean, line 315): For MCS, box accessibility transfers formulas
- `closure_mcs_negation_complete`: Either `box psi in S` or `(box psi).neg in S`

**Verification**:
- `lean_goal` shows no remaining goals at box case
- `lean_diagnostic_messages` shows no errors

---

### Phase 4: Prove or document temporal cases [NOT STARTED]

**Goal**: Attempt temporal cases (all_past, all_future) and document any architectural limitations

**Tasks**:
- [ ] Read current state of all_past case (line 3975)
- [ ] Read current state of all_future case (line 3980)
- [ ] Analyze temporal accessibility in `finite_task_rel` (lines 1442-1450)
- [ ] Attempt proof using temporal consistency properties
- [ ] If reflexivity mismatch blocks proof:
  - [ ] Document limitation in code comments
  - [ ] Verify alternative path via `representation_theorem_backward_empty` is intact
  - [ ] Mark cases as [PARTIAL] with explanation

**Timing**: 1.5 hours

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModel/FiniteCanonicalModel.lean` - lines 3975-3983

**Potential Issue**: TM logic uses strict temporal semantics (forall s < t, forall s > t) which may not align with MCS temporal closure properties.

**Verification**:
- If successful: `lean_diagnostic_messages` shows no errors
- If blocked: Comments document limitation, alternative path remains sound

---

## Testing & Validation

- [ ] `lake build Logos` compiles without errors
- [ ] `mcs_imp_iff_material` has zero sorries
- [ ] `truth_at_implies_semantic_truth` has reduced sorry count (imp, box filled)
- [ ] If temporal cases complete: zero sorries in truth_at_implies_semantic_truth
- [ ] `main_weak_completeness` and `main_provable_iff_valid` remain sound
- [ ] No new type errors introduced

## Artifacts & Outputs

- Modified: `Logos/Metalogic_v2/FiniteModel/FiniteCanonicalModel.lean`
  - `mcs_imp_iff_material` - filled 2 sorries
  - `truth_at_implies_semantic_truth` - imp and box cases filled
  - Temporal cases either filled or documented with limitation
- Created: `specs/577_prove_compound_formula_bridge_cases/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If proofs become intractable:
1. Revert FiniteCanonicalModel.lean to pre-implementation state via git
2. The proven `representation_theorem_backward_empty` provides completeness independently
3. Document which cases are blocked and why in the summary
4. Task 578 can proceed using alternative completeness path
