# Implementation Plan: Task #569

- **Task**: 569 - Analyze Proof Strategy Alternatives
- **Status**: [NOT STARTED]
- **Effort**: 3-5 hours
- **Priority**: High
- **Dependencies**: Task 566 (parent)
- **Research Inputs**: specs/569_analyze_proof_strategy_alternatives/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements a tiered approach to completing the semantic embedding in task 566. The research identified three strategies with different effort levels and success probabilities. We will attempt Strategy C first (using proven theorems `main_provable_iff_valid` and `valid_iff_empty_consequence`), fall back to Strategy A (contrapositive approach) if C fails, and only pursue Strategy B (completing bridge sorries) if both A and C fail.

### Research Integration

Key findings from research-001.md:
- `main_provable_iff_valid` (PROVEN) establishes: `Nonempty (Provable phi) <-> valid phi`
- `valid_iff_empty_consequence` (PROVEN) establishes: `valid phi <-> semantic_consequence [] phi`
- These can be chained to bypass all bridge lemma sorries
- Strategy C estimated at 1-2 hours vs 4-6 hours for Strategy B

## Goals & Non-Goals

**Goals**:
- Implement a working proof for `representation_theorem_backward_empty` without sorries
- Validate type compatibility between `main_provable_iff_valid`, `valid_iff_empty_consequence`, and `ContextDerivable`
- Remove or deprecate the sorry-laden `semantic_consequence_implies_semantic_world_truth` bridge lemma
- Document the successful proof strategy for future reference

**Non-Goals**:
- Completing all sorries in `truth_at_implies_semantic_truth` (deferred unless necessary)
- Modifying `FiniteCanonicalModel.lean` beyond what's strictly needed
- Proving additional completeness variants beyond `representation_theorem_backward_empty`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Universe level mismatch between theorems | High | Low | Both use `Type` not `Type*`; check with `#check` first |
| Import cycle issues | Medium | Low | FiniteCanonicalModel already imported |
| `Nonempty` vs `Prop` coercion issues | Low | Medium | Use standard elimination pattern `h_prov.elim` |
| Strategy C definitional equivalence fails | Medium | Low | Fall back to Strategy A immediately |
| Strategy A also fails | High | Low | Create subtask for Strategy B |

## Implementation Phases

### Phase 1: Type Compatibility Verification [NOT STARTED]

**Goal**: Verify that Strategy C is viable by checking type signatures and imports

**Tasks**:
- [ ] Open `ContextProvability.lean` and add `#check` statements for `main_provable_iff_valid` and `Validity.valid_iff_empty_consequence`
- [ ] Verify universe levels are compatible (both should use `Type`)
- [ ] Verify `semantic_consequence [] phi` aligns with `valid phi` definition
- [ ] Check that `ContextDerivable [] phi` can wrap `Nonempty (Provable phi)`
- [ ] Document any type mismatches found

**Timing**: 30 minutes

**Files to modify**:
- `Logos/Metalogic_v2/Representation/ContextProvability.lean` - add temporary `#check` statements

**Verification**:
- No errors from `#check` statements
- Types align as expected in research report

---

### Phase 2: Implement Strategy C [NOT STARTED]

**Goal**: Rewrite `representation_theorem_backward_empty` using `main_provable_iff_valid` and `valid_iff_empty_consequence`

**Tasks**:
- [ ] Comment out or remove the existing sorry-based proof
- [ ] Implement new proof body:
  ```lean
  theorem representation_theorem_backward_empty : semantic_consequence [] phi -> ContextDerivable [] phi := by
    intro h_sem
    have h_valid : valid phi := (Validity.valid_iff_empty_consequence phi).mpr h_sem
    have h_prov : Nonempty (Provable phi) := (main_provable_iff_valid phi).mpr h_valid
    exact h_prov.elim (fun d => ⟨d⟩)
  ```
- [ ] Run `lake build` to verify compilation
- [ ] Run `#print axioms representation_theorem_backward_empty` to verify no sorries

**Timing**: 1 hour

**Files to modify**:
- `Logos/Metalogic_v2/Representation/ContextProvability.lean` - rewrite theorem proof

**Verification**:
- `lake build` succeeds with no errors
- `#print axioms` shows no `sorry` dependency
- Proof compiles without universe level errors

---

### Phase 3: Strategy A Fallback (Conditional) [NOT STARTED]

**Goal**: If Strategy C fails, implement contrapositive approach using `semantic_weak_completeness`

**Tasks**:
- [ ] Only execute if Phase 2 fails
- [ ] Implement contrapositive proof:
  ```lean
  theorem representation_theorem_backward_empty : semantic_consequence [] phi -> ContextDerivable [] phi := by
    apply Function.mtr  -- Mathlib contrapositive helper
    intro h_not_deriv
    -- Use contrapositive of semantic_weak_completeness
    -- Construct falsifying SemanticWorldState
    -- Instantiate semantic_consequence with concrete D, F
    sorry -- Fill in based on actual types
  ```
- [ ] Use `lean_multi_attempt` to test alternative tactic sequences
- [ ] Complete proof or document blocking issues

**Timing**: 1.5 hours

**Files to modify**:
- `Logos/Metalogic_v2/Representation/ContextProvability.lean`

**Verification**:
- Proof compiles or clear documentation of why it cannot

---

### Phase 4: Cleanup and Documentation [NOT STARTED]

**Goal**: Remove deprecated code and document the successful strategy

**Tasks**:
- [ ] Remove or mark deprecated the `semantic_consequence_implies_semantic_world_truth` bridge lemma (if no longer needed)
- [ ] Add doc comments to `representation_theorem_backward_empty` explaining the proof approach
- [ ] Update task 566's plan/status with the successful strategy
- [ ] Verify `#print axioms` for the entire `ContextProvability.lean` module

**Timing**: 30 minutes

**Files to modify**:
- `Logos/Metalogic_v2/Representation/ContextProvability.lean` - cleanup and docs
- `specs/566_complete_semantic_embedding_for_completeness_proof/` - status update

**Verification**:
- No remaining sorries in `representation_theorem_backward_empty`
- Doc comments explain the proof strategy
- Task 566 plan updated

---

### Phase 5: Strategy B Escalation (Conditional) [NOT STARTED]

**Goal**: If Strategies A and C both fail, create subtask for completing bridge sorries

**Tasks**:
- [ ] Only execute if both Phase 2 and Phase 3 fail
- [ ] Document why Strategies A and C failed
- [ ] Create Task 571 for completing the 4 compound formula sorries in `truth_at_implies_semantic_truth`
- [ ] Update task 569 summary with failure analysis

**Timing**: 30 minutes

**Files to modify**:
- `specs/state.json` - create new task 571
- `specs/TODO.md` - add task 571 entry
- `specs/569_analyze_proof_strategy_alternatives/summaries/` - failure analysis

**Verification**:
- Task 571 exists with clear scope
- Failure reasons documented

## Testing & Validation

- [ ] `lake build` succeeds with no errors for Metalogic_v2
- [ ] `#print axioms representation_theorem_backward_empty` shows no `sorry`
- [ ] `#print axioms ContextProvability` (full module) shows minimal/expected axioms
- [ ] No regression in other theorems that depend on `representation_theorem_backward_empty`

## Artifacts & Outputs

- `Logos/Metalogic_v2/Representation/ContextProvability.lean` - updated theorem proof
- `specs/569_analyze_proof_strategy_alternatives/summaries/implementation-summary-YYYYMMDD.md` - completion summary
- (Conditional) `specs/571_complete_bridge_sorries/` - new task if escalation needed

## Rollback/Contingency

If the new proof causes regressions:
1. Restore the original sorry-based `representation_theorem_backward_empty` from git
2. Keep the deprecated `semantic_consequence_implies_semantic_world_truth` lemma
3. Document the regression cause
4. Escalate to Strategy B (Task 571)

The original code is preserved in git history and can be restored with:
```bash
git checkout HEAD~1 -- Logos/Metalogic_v2/Representation/ContextProvability.lean
```
