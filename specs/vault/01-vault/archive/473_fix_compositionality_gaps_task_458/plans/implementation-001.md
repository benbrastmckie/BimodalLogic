# Implementation Plan: Task #473

- **Task**: 473 - Fix compositionality gaps from Task 458
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Priority**: Medium
- **Dependencies**: Task 472 (Lindenbaum extension - COMPLETED)
- **Research Inputs**: specs/473_fix_compositionality_gaps_task_458/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the 17 sorry gaps identified in FiniteCanonicalModel.lean from Task 458. The gaps fall into three categories: compositionality (7 gaps in mixed-sign duration cases), truth lemma (8 gaps requiring negation-completeness), and history construction (2 gaps requiring witness construction). Task 472 completed the Lindenbaum extension infrastructure which provides the foundation for the truth lemma gaps. The compositionality gaps are fundamentally tied to the pointwise transfer approach and will be documented as limitations. The implementation leverages `ClosureConsistent`, `ClosureMaximalConsistent`, `worldStateFromClosureMCS`, `closure_mcs_negation_complete`, and the existence theorems from Task 472.

### Research Integration

Key findings from research-001.md:
- Root cause: `IsLocallyConsistent` captures soundness only, not negation-completeness
- Primary solution: Bridge to `SetMaximalConsistent` via Task 472 infrastructure
- Compositionality gaps are fundamental to pointwise approach (accept as limitation)
- Truth lemma backward directions require negation-completeness

## Goals & Non-Goals

**Goals**:
- Complete truth lemma proofs using negation-completeness from closure MCS
- Fill derivation-related sorry gaps from Task 472
- Complete history construction using existence theorems
- Document compositionality limitations clearly
- Reduce overall sorry count in FiniteCanonicalModel.lean

**Non-Goals**:
- Solve mixed-sign compositionality fundamentally (requires path-based construction)
- Achieve zero sorry gaps (some are blocked on proof system consistency)
- Restructure the finite model approach

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Derivation manipulation complexity | Medium | Medium | Use existing Completeness.lean lemmas |
| Negation closure gaps | Medium | Low | closureWithNeg already defined in Task 472 |
| Task relation verification | Medium | Medium | Systematic case analysis |
| Build time increase | Low | Medium | Modular structure, incremental testing |

## Implementation Phases

### Phase 1: Derivation Infrastructure [NOT STARTED]

**Goal**: Complete derivation-related sorry gaps that block truth lemma and existence proofs

**Tasks**:
- [ ] Fill `closure_consistent_empty` - Prove empty set is closure-consistent
- [ ] Complete `closure_mcs_imp_closed` - Prove implication closure property
- [ ] Complete `closure_mcs_negation_complete` derivation manipulation
- [ ] Add helper lemmas for derivation/set conversion if needed

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Lines 950-1050 (Closure MCS section)

**Verification**:
- `lake build` succeeds with fewer sorry gaps
- Can invoke `closure_mcs_negation_complete` in truth lemma proofs

---

### Phase 2: Local Consistency from MCS [NOT STARTED]

**Goal**: Complete the bridge from ClosureMCS to FiniteWorldState via local consistency

**Tasks**:
- [ ] Fill `closure_mcs_implies_locally_consistent` T axiom case
- [ ] Fill `closure_mcs_implies_locally_consistent` temporal reflexivity cases
- [ ] Complete `worldStateFromClosureMCS_models_iff` - membership equals truth

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Lines 1070-1150 (Bridge section)

**Verification**:
- `worldStateFromClosureMCS` works without sorry for standard cases
- Can construct world states from any closure MCS

---

### Phase 3: Truth Lemma Backward Directions [NOT STARTED]

**Goal**: Complete the 8 truth lemma sorry gaps using negation-completeness

**Tasks**:
- [ ] Fill implication backward case (line 1296) - Use `closure_mcs_imp_closed`
- [ ] Fill implication negation case (line 1300) - Use negation-completeness
- [ ] Fill box backward case (line 1328) - Use canonical property
- [ ] Fill box negation case (line 1338) - Use negation-completeness
- [ ] Fill future backward case (line 1360) - Use temporal existence
- [ ] Fill past backward case (line 1382) - Use temporal existence

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Lines 1241-1382 (Truth Lemma section)

**Verification**:
- Truth lemma compiles with only forward-direction cases needing attention
- Each connective case has both directions proven (or documented limitation)

---

### Phase 4: Existence Theorem Completion [NOT STARTED]

**Goal**: Complete the existence theorems for successor/predecessor states

**Tasks**:
- [ ] Fill `forwardTransferRequirements_consistent` - Show requirements are consistent
- [ ] Fill `backwardTransferRequirements_consistent` - Show requirements are consistent
- [ ] Complete `finite_forward_existence_thm` - Task relation verification
- [ ] Complete `finite_backward_existence_thm` - Task relation verification

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Lines 1170-1230 (Existence section)

**Verification**:
- Existence theorems provide usable witnesses
- Can construct successor/predecessor states from any world state

---

### Phase 5: History Construction [NOT STARTED]

**Goal**: Complete the history construction using existence theorems

**Tasks**:
- [ ] Fill `finite_history_from_state` first sorry (line 1131) - Forward construction
- [ ] Fill `finite_history_from_state` second sorry (line 1134) - Backward construction
- [ ] Verify recursive termination via finite time domain

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Lines 1119-1150 (History Construction section)

**Verification**:
- `finite_history_from_state` returns valid history
- History satisfies all task relation requirements

---

### Phase 6: Compositionality Documentation [NOT STARTED]

**Goal**: Document compositionality gaps as known limitations with clear explanation

**Tasks**:
- [ ] Add section comment explaining mixed-sign limitation
- [ ] Reference Task 464 Strategy A analysis
- [ ] Note that semantic correctness holds despite syntactic gaps
- [ ] Consider adding `compositionality_limitation` declaration as documentation

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Lines 773-877 (Compositionality section)

**Verification**:
- Clear documentation of why gaps exist
- Reference to research for future work

---

### Phase 7: Final Verification and Cleanup [NOT STARTED]

**Goal**: Verify complete build and document remaining gaps

**Tasks**:
- [ ] Run full `lake build` and capture diagnostics
- [ ] Count remaining sorry gaps and categorize
- [ ] Update implementation summary with gap inventory
- [ ] Verify truth lemma can be invoked from completeness theorem

**Timing**: 1 hour

**Files to modify**:
- Summary artifact creation

**Verification**:
- Clean build with documented sorry count
- All critical gaps addressed or documented

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness.FiniteCanonicalModel` succeeds
- [ ] Sorry count reduced from ~17 to <10 (core gaps only)
- [ ] Truth lemma backward directions work for implication, box, temporal
- [ ] Existence theorems can be invoked without sorry dependency
- [ ] History construction uses existence theorems properly

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (completion summary)
- Modified: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

## Rollback/Contingency

If implementation introduces regressions:
1. Revert to commit `b95fdc1b` (Task 472 complete)
2. Preserve working partial progress in branch
3. Create new plan version focusing on subset of gaps

If certain gaps prove intractable:
1. Accept as documented limitations (compositionality model)
2. Create follow-up task for alternative approach
3. Note dependency for downstream tasks (449, 450)
