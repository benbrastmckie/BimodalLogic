# Implementation Plan: Task #623

- **Task**: 623 - Build FMP-tableau connection infrastructure
- **Status**: [PARTIAL]
- **Effort**: 6 hours
- **Priority**: High
- **Dependencies**: Task 490 (parent task)
- **Research Inputs**: specs/623_build_fmp_tableau_connection_infrastructure/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements infrastructure connecting Finite Model Property (FMP) bounds to tableau semantics. The work involves completing two sorries in `expansion_decreases_measure`, implementing a substantive `branchTruthLemma` for countermodel extraction, and proving `tableau_complete` using FMP bounds. The research report identified clear proof strategies leveraging existing infrastructure in FiniteModelProperty.lean and SemanticCanonicalModel.lean.

### Research Integration

Key findings from research-001.md:
- FMP infrastructure is mature with explicit bounds (2^closureSize)
- `expansion_decreases_measure` has two sorries at lines 773 and 813 of Saturation.lean
- `branchTruthLemma` in CountermodelExtraction.lean is a trivial placeholder needing substantive implementation
- Existing lemmas `applyRule_decreases_complexity` and `foldl_conditional_mono` provide the proof patterns

## Goals & Non-Goals

**Goals**:
- Complete `expansion_decreases_measure` proof (fill 2 sorries)
- Implement substantive `branchTruthLemma` connecting saturated open branches to countermodels
- Prove `open_saturated_implies_satisfiable` using `branchTruthLemma`
- Prove `valid_implies_no_open_branch` as contrapositive
- Prove `fmpFuel_sufficient_termination` connecting fuel to measure bounds
- Enable `tableau_complete` proof by providing required lemmas

**Non-Goals**:
- Proving `semantic_truth_implies_truth_at` (route through `semantic_weak_completeness` instead)
- Optimizing tableau performance for large formulas
- Proving `decide_complete` (separate task building on this infrastructure)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Complex case analysis in branchTruthLemma | H | M | Follow existing `applyRule_decreases_complexity` pattern (147 lines) |
| Termination measure bounds tightness | M | L | Use existing `foldl_conditional_mono` and `foldl_filter_le` lemmas |
| Truth bridge dependency | M | M | Route through `semantic_weak_completeness` which is fully proven |
| Unforeseen dependencies in FMP chain | M | L | Research identified complete dependency chain; test incrementally |

## Implementation Phases

### Phase 1: Complete expansion_decreases_measure [COMPLETED]

**Goal**: Fill the two sorries in expansion_decreases_measure theorem (Saturation.lean lines 773, 813)

**Tasks**:
- [ ] Read current `expansion_decreases_measure` implementation and understand proof structure
- [ ] Fill sorry at line 773 (linear rule application case)
  - Extract `sf in b` from `findUnexpanded` returning `some sf`
  - Show `sf.formula.complexity > 0` using `unexpanded_contributes`
  - Show result formulas have total complexity < `sf.formula.complexity` using `applyRule_decreases_complexity`
  - Use `foldl_filter_le` for list arithmetic
- [ ] Fill sorry at line 813 (branching rule case)
  - Similar pattern for branching case
  - Handle multiple branches using the same complexity decrease argument
- [ ] Verify no new diagnostics introduced

**Timing**: 1.5 hours

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` - lines 773, 813

**Verification**:
- `lean_diagnostic_messages` on Saturation.lean shows no sorry errors for expansion_decreases_measure
- `lean_goal` at end of theorem shows "no goals"

---

### Phase 2: Implement substantive branchTruthLemma [PARTIAL]

**Goal**: Replace trivial branchTruthLemma with a substantive proof connecting saturated open branches to model satisfaction

**Tasks**:
- [ ] Read current `branchTruthLemma` in CountermodelExtraction.lean and understand extraction infrastructure
- [ ] Study `extractTrueAtoms` and `extractFalseAtoms` functions for building valuation
- [ ] Define or locate `extractedModel` function that builds FiniteWorldState from branch
- [ ] Prove by structural induction on formula:
  - If `T(psi) in b` then `extractedModel b |= psi`
  - If `F(psi) in b` then `extractedModel b |/= psi`
- [ ] Use saturation condition (`findUnexpanded b = none`) to handle compound formulas
- [ ] Use openness condition (`findClosure b = none`) to ensure consistency
- [ ] Verify the theorem compiles without sorry

**Timing**: 2 hours

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` - branchTruthLemma

**Verification**:
- `lean_diagnostic_messages` shows no sorry in CountermodelExtraction.lean
- `lean_goal` at end of branchTruthLemma shows "no goals"

---

### Phase 3: Prove open_saturated_implies_satisfiable [NOT STARTED]

**Goal**: Prove that a saturated open branch yields a finite countermodel

**Tasks**:
- [ ] Define theorem signature:
  ```lean
  theorem open_saturated_implies_satisfiable (b : Branch)
      (hSat : findUnexpanded b = none) (hOpen : findClosure b = none) :
      exists (M : FiniteModel), satisfies_branch M b
  ```
- [ ] Use `branchTruthLemma` to show all formulas in branch are satisfied by extracted model
- [ ] Connect to `SemanticWorldState` construction from SemanticCanonicalModel.lean
- [ ] Use `semantic_world_state_has_world_history` to ensure model reachability
- [ ] Verify finiteness using closure bound

**Timing**: 1 hour

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` - new theorem

**Verification**:
- New theorem compiles without sorry
- `lean_hover_info` confirms expected type signature

---

### Phase 4: Prove valid_implies_no_open_branch [NOT STARTED]

**Goal**: Prove contrapositive - valid formulas have no open saturated branches

**Tasks**:
- [ ] Define theorem signature:
  ```lean
  theorem valid_implies_no_open_branch (phi : Formula) (hValid : valid phi) :
      forall b, buildTableau phi fuel = some (.hasOpen b _) -> False
  ```
- [ ] Apply contrapositive reasoning:
  - Assume open branch exists for `F(phi)`
  - By Phase 3, this yields finite model where `phi` is false
  - This contradicts validity of `phi`
- [ ] Use `formula_satisfiable` and FMP connection

**Timing**: 45 minutes

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - new theorem

**Verification**:
- Theorem compiles without sorry
- Connects logically to Phase 3 result

---

### Phase 5: Prove fmpFuel_sufficient_termination [NOT STARTED]

**Goal**: Prove that `fmpBasedFuel phi` is sufficient for tableau termination

**Tasks**:
- [ ] Define theorem signature:
  ```lean
  theorem fmpFuel_sufficient_termination (phi : Formula) :
      (buildTableau phi (fmpBasedFuel phi)).isSome
  ```
- [ ] Connect fuel to expansion measure:
  - Phase 1 proved `expansion_decreases_measure`
  - Measure bounded by `closureSize phi * phi.complexity`
  - `fmpBasedFuel phi = 2^closureSize phi * 2` exceeds this
- [ ] Use well-founded induction on the measure
- [ ] Case analysis on `expandBranchWithFuel` outcomes

**Timing**: 45 minutes

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - new theorem

**Verification**:
- Theorem compiles without sorry
- `buildTableau` with `fmpBasedFuel` never returns `none`

---

### Phase 6: Enable tableau_complete proof [NOT STARTED]

**Goal**: Complete the `tableau_complete` theorem using the infrastructure from previous phases

**Tasks**:
- [ ] Review current `tableau_complete` theorem (Correctness.lean lines 114-135)
- [ ] Use `fmpBasedFuel phi` as the fuel witness
- [ ] Apply `fmpFuel_sufficient_termination` to show termination
- [ ] Case split on result:
  - `allClosed` case: tableau is valid (existing soundness)
  - `hasOpen` case: contradicts validity (Phase 4)
- [ ] Fill the sorry in `tableau_complete`

**Timing**: 1 hour

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - tableau_complete theorem

**Verification**:
- `tableau_complete` compiles without sorry
- `lean_diagnostic_messages` on Correctness.lean shows no sorry errors

## Testing & Validation

- [ ] `lean_diagnostic_messages` on Saturation.lean shows no sorry for expansion_decreases_measure
- [ ] `lean_diagnostic_messages` on CountermodelExtraction.lean shows no sorry
- [ ] `lean_diagnostic_messages` on Correctness.lean shows no sorry for tableau_complete
- [ ] Build entire project with `lake build` succeeds
- [ ] New theorems have correct type signatures per `lean_hover_info`

## Artifacts & Outputs

- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` - completed expansion_decreases_measure
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` - substantive branchTruthLemma, open_saturated_implies_satisfiable
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - valid_implies_no_open_branch, fmpFuel_sufficient_termination, completed tableau_complete
- Implementation summary at `specs/623_build_fmp_tableau_connection_infrastructure/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If proofs become intractable:
1. Preserve partial progress by committing completed phases
2. Mark blocked phases [BLOCKED] with specific blocker description
3. Consider decomposing into smaller subtasks (e.g., separate task for branchTruthLemma induction)
4. Fall back to `sorry` with detailed comments explaining the gap for future work
5. Coordinate with parent task 490 about priority and dependencies
