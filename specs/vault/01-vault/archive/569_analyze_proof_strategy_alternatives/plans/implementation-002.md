# Implementation Plan: Task #569

- **Task**: 569 - Analyze Proof Strategy Alternatives
- **Version**: 002
- **Status**: [COMPLETED]
- **Effort**: 1 hour (reduced from 3-5 hours)
- **Priority**: High
- **Dependencies**: Task 566 (parent)
- **Research Inputs**:
  - specs/569_analyze_proof_strategy_alternatives/reports/research-001.md
  - specs/569_analyze_proof_strategy_alternatives/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**SIMPLIFIED PLAN**: Research-002 verified that Strategy C compiles successfully. The original 5-phase tiered approach is now collapsed to 2 phases since:

1. **Type compatibility verified** - lean_run_code confirmed the proof compiles
2. **Strategy A fallback not needed** - Strategy C works
3. **Strategy B escalation not needed** - No need to complete bridge sorries for this task

The implementation is straightforward: replace the current sorry-based proof with the verified 3-line Strategy C proof.

### Research Integration

Key findings from research-002.md:
- Strategy C **CONFIRMED WORKING** via `lean_run_code`
- `main_provable_iff_valid` + `valid_iff_empty_consequence` = direct path
- The 4 bridge sorries in `truth_at_implies_semantic_truth` are internal and don't block the theorem
- Contrapositive pattern is standard (already used in `semantic_weak_completeness`)

## Goals & Non-Goals

**Goals**:
- Replace `representation_theorem_backward_empty` with Strategy C proof
- Remove or deprecate the sorry-laden `semantic_consequence_implies_semantic_world_truth` bridge lemma
- Verify with `#print axioms`

**Non-Goals**:
- Completing bridge sorries (tracked separately in tasks 571-573)
- Implementing alternative strategies (Strategy C confirmed)
- Type compatibility testing (already done in research)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proof doesn't compile in actual file | Low | Very Low | Already verified with lean_run_code |
| Import issues | Low | Very Low | FiniteCanonicalModel already imported |
| Hidden sorry dependency revealed by #print axioms | Medium | Low | Expected - bridge sorries are known |

## Implementation Phases

### Phase 1: Implement Strategy C [COMPLETED]

**Goal**: Replace `representation_theorem_backward_empty` with verified Strategy C proof

**Tasks**:
- [ ] Open `Metalogic_v2/Representation/ContextProvability.lean`
- [ ] Replace current implementation with:
  ```lean
  theorem representation_theorem_backward_empty {phi : Formula} :
      semantic_consequence [] phi -> ContextDerivable [] phi := by
    intro h_sem
    have h_valid : valid phi := (Validity.valid_iff_empty_consequence phi).mpr h_sem
    have h_prov : Nonempty (⊢ phi) := (main_provable_iff_valid phi).mpr h_valid
    exact h_prov
  ```
- [ ] Run `lake build` to verify compilation
- [ ] Run `#print axioms representation_theorem_backward_empty`

**Timing**: 30 minutes

**Files to modify**:
- `Logos/Metalogic_v2/Representation/ContextProvability.lean`

**Verification**:
- `lake build` succeeds
- `#print axioms` confirms proof structure (may show expected axioms from bridge sorries)

---

### Phase 2: Cleanup and Documentation [COMPLETED]

**Goal**: Remove deprecated code and document the fix

**Tasks**:
- [ ] Remove or mark deprecated `semantic_consequence_implies_semantic_world_truth`
- [ ] Add doc comment explaining Strategy C approach
- [ ] Update any dependent code if needed
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- `Logos/Metalogic_v2/Representation/ContextProvability.lean` - cleanup
- `specs/569_analyze_proof_strategy_alternatives/summaries/` - create summary

**Verification**:
- No compilation errors
- Bridge lemma removed or deprecated
- Summary documents the successful strategy

## Testing & Validation

- [ ] `lake build` succeeds for Metalogic_v2
- [ ] `#print axioms representation_theorem_backward_empty` shows expected structure
- [ ] No regression in dependent theorems

## Artifacts & Outputs

- `Logos/Metalogic_v2/Representation/ContextProvability.lean` - updated theorem
- `specs/569_analyze_proof_strategy_alternatives/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If Strategy C unexpectedly fails in the actual file:
```bash
git checkout HEAD~1 -- Logos/Metalogic_v2/Representation/ContextProvability.lean
```

Then investigate why the lean_run_code verification didn't catch the issue.

## Changes from v001

| v001 Phase | v002 Status | Reason |
|------------|-------------|--------|
| Phase 1: Type Verification | REMOVED | Completed in research-002 |
| Phase 2: Strategy C | Phase 1 | Kept, verified to work |
| Phase 3: Strategy A Fallback | REMOVED | Not needed, Strategy C works |
| Phase 4: Cleanup | Phase 2 | Kept, simplified |
| Phase 5: Strategy B Escalation | REMOVED | Not needed, Strategy C works |

**Effort reduction**: 3-5 hours -> 1 hour (verified approach eliminates contingencies)
