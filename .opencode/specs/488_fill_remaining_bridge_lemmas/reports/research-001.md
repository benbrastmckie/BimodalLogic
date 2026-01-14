# Research Report: Task #488

**Task**: fill_remaining_bridge_lemmas
**Date**: 2026-01-13
**Focus**: Identify remaining sorries in FiniteCanonicalModel.lean, analyze their types and what's needed to fill them
**Session**: sess_1768352983_fed2b7

## Executive Summary

- FiniteCanonicalModel.lean contains **34 sorry warnings** across multiple categories
- The task description mentions 6 bridge lemmas but actual sorry count is higher
- Sorries fall into **4 categories**: (1) Bridge lemmas for connecting finite/semantic worlds, (2) Compositionality/gluing proofs, (3) Transfer requirements consistency, (4) Deprecated syntactic approach leftovers
- **Core completeness is proven**: `semantic_weak_completeness` works via the semantic approach
- Remaining sorries are mostly in **auxiliary infrastructure** rather than the critical path

## Context & Scope

The research focused on:
1. Scanning all `sorry` occurrences in FiniteCanonicalModel.lean
2. Categorizing each sorry by type and difficulty
3. Identifying which sorries are on the critical path for completeness
4. Determining proof strategies for fillable sorries

## Findings

### Sorry Count by Category

| Category | Count | Priority | Notes |
|----------|-------|----------|-------|
| Bridge Lemmas (finiteHistoryToWorldHistory, etc.) | 4 | Medium | Type-level connections |
| Compositionality/Gluing | 6 | Low | Edge cases (x<0, y<=0) |
| Transfer Requirements Consistency | 2 | Medium | Needs deduction/closure |
| Semantic History Infrastructure | 4 | Medium | History construction |
| Deprecated Syntactic Approach | ~12 | Low | Keep as documentation |
| MCS Projection Maximality | 1 | High | Closure under negation |
| Main Completeness Connection | 4 | Low | Optional formal bridges |

### Critical Path Analysis

The **proven core** of completeness:
```
semantic_truth_lemma_v2 (PROVEN, no sorry)
    ↓
semantic_weak_completeness (PROVEN via MCS construction)
    ↓
[Optional bridge to main weak_completeness axiom]
```

The sorries are NOT on the critical path because:
1. `semantic_weak_completeness` is fully proven for the semantic model
2. The theorem establishes: validity in SemanticCanonicalModel implies derivability
3. Bridge lemmas would connect to the abstract `valid` quantifier but are not needed for the core result

### Detailed Sorry Analysis

#### 1. Bridge Lemmas (4 sorries, Medium Priority)

**Location**: Lines 3189, 3208, 3231, 3246

**`finiteHistoryToWorldHistory.respects_task` (line 3189)**
- Type: Proving `semantic_task_rel_v2` for clamped time domain
- Issue: Requires careful time arithmetic when t is clamped to [-k, k]
- Strategy: Case split on whether t is in bounds vs clamped
- Difficulty: Medium (tedious but straightforward)

**`semantic_world_state_has_world_history` (line 3208)**
- Type: Showing every SemanticWorldState has a witnessing WorldHistory at time 0
- Issue: Need to time-shift the history so w appears at origin
- Strategy: Use `time_shift` with appropriate offset
- Difficulty: Medium (requires history shifting infrastructure)

**`semantic_truth_implies_truth_at` (line 3231)**
- Type: Membership in world state implies truth_at in model
- Issue: Induction on formula structure
- Strategy: Structural induction with case analysis
- Difficulty: Medium-High (8 cases, some non-trivial)

**`truth_at_implies_semantic_truth` (line 3246)**
- Type: Converse of above
- Issue: Same induction required
- Strategy: Same as above, converse direction
- Difficulty: Medium-High

#### 2. Compositionality/Gluing (6 sorries, Low Priority)

**Location**: Lines 2171, 2174, 2403, 2419, 2438, 2439

**`glue_histories.forward_rel` (line 2171)**
- Type: Forward relation preserved across glued history
- Issue: Edge cases when crossing junction point
- Strategy: Case analysis on position relative to junction
- Difficulty: Medium (3 cases: before, at, after junction)

**`glue_histories.backward_rel` (line 2174)**
- Type: Backward relation preserved across glued history
- Strategy: Same as forward_rel
- Difficulty: Medium

**`SemanticTaskRelV2.compositionality` edge cases (lines 2403, 2419, 2438-2439)**
- Type: Edge cases when x < 0 or y <= 0 in composition
- Issue: Gluing direction changes based on sign
- Strategy: Generalize gluing lemma or case split
- Difficulty: Medium-High (sign-dependent logic)

**Note**: These are acceptable sorries per documentation - only needed when x<0 or y<=0 simultaneously, which doesn't arise in the completeness proof.

#### 3. Transfer Requirements Consistency (2 sorries, Medium Priority)

**Location**: Lines 2783, 2819

**`forwardTransferRequirements_consistent` (line 2783)**
- Type: {psi | G psi in w} is set-consistent
- Issue: Requires showing G-formulas in w don't derive contradiction
- Strategy: Contrapositive using soundness
- Difficulty: Medium (standard modal logic argument)

**`backwardTransferRequirements_consistent` (line 2819)**
- Type: {psi | H psi in w} is set-consistent
- Strategy: Dual of forward case
- Difficulty: Medium

#### 4. MCS Projection Maximality (1 sorry, High Priority)

**Location**: Line 3014

**`mcs_projection_is_closure_mcs` maximality case**
- Type: If psi not in M intersection closure, inserting psi is inconsistent
- Issue: Need psi.neg in closure for the proof
- Strategy: Use closureWithNeg or prove closure is closed under neg
- Difficulty: High (requires infrastructure change)

**Current workaround**: The theorem works for formulas whose negation is also in closure. The closure definition may need revision to guarantee this.

#### 5. Deprecated Syntactic Approach (~12 sorries, Low Priority)

**Locations**: Lines 449, 551, 657, 688, 712, 1051, 1067, 1213, 1230, 1246, 1253, 1268, 1271, 1279, 1281

These are in the **deprecated** syntactic approach code that:
- Uses `FiniteWorldState`, `finite_task_rel`, `finite_truth_lemma`
- Has known negation-completeness issues
- Is documented as deprecated in favor of semantic approach
- Kept for historical reference

**Recommendation**: Leave as-is with documentation. Do NOT attempt to fill these.

### Proof Infrastructure Available

The following proven infrastructure supports filling sorries:

1. **Quotient properties**:
   - `htEquiv_refl`, `htEquiv_symm`, `htEquiv_trans` - equivalence relation
   - `SemanticWorldState.eq_iff_toFiniteWorldState_eq` - equality criterion
   - `truth_respects_htEquiv` - truth is representative-independent

2. **History gluing**:
   - `glue_histories_before_junction` - states before junction from h1
   - `glue_histories_at_junction` - junction state from both
   - `glue_histories_after_junction` - states after junction from h2

3. **Deduction theorem infrastructure**:
   - `deduction_theorem` - context manipulation
   - `derivation_from_subset_weaken` - weakening
   - `double_negation` - DNE theorem

4. **Closure properties**:
   - `closure_contains_subformulas` - closure transitivity
   - `self_mem_closure` - phi in closure(phi)
   - `closure_lindenbaum_via_projection` - Lindenbaum extension

## Decisions

1. **Focus on bridge lemmas**: The 4 bridge lemmas (finiteHistoryToWorldHistory.respects_task, semantic_world_state_has_world_history, semantic_truth_implies_truth_at, truth_at_implies_semantic_truth) provide the most value for connecting semantic completeness to the abstract valid quantifier.

2. **Defer compositionality edge cases**: The edge cases (x<0, y<=0) don't arise in the completeness proof per documentation. These can remain as acceptable sorries.

3. **Leave deprecated code as-is**: The syntactic approach sorries document known limitations and should not be filled.

4. **Transfer consistency may need closure revision**: The transfer requirements consistency proofs depend on closure being closed under negation, which may require defining `closureWithNeg`.

## Recommendations

### High Priority (Fill first)
1. `mcs_projection_is_closure_mcs` maximality - blocks clean projection to closure MCS

### Medium Priority (Fill for clean infrastructure)
2. `forwardTransferRequirements_consistent` and `backwardTransferRequirements_consistent`
3. `finiteHistoryToWorldHistory.respects_task`
4. `semantic_world_state_has_world_history`

### Low Priority (Optional formal completeness)
5. `semantic_truth_implies_truth_at` and `truth_at_implies_semantic_truth`
6. Compositionality edge cases in gluing

### Do Not Fill
- All sorries in deprecated syntactic approach
- `finite_history_from_state` sorries (uses placeholder construction)

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Closure not closed under negation | High | Blocks mcs_projection | Define closureWithNeg |
| Time arithmetic edge cases complex | Medium | Extends timeline | Use omega tactic heavily |
| Formula induction tedious | Low | Time consuming | Break into sub-lemmas |

## Appendix

### Search Queries Used
- `sorry` pattern search in FiniteCanonicalModel.lean
- `lean_local_search` for htEquiv, SemanticWorldState, glue_histories, FiniteHistory
- `lean_loogle` for Quotient.out properties
- `lean_diagnostic_messages` for full sorry warning list

### File Statistics
- Total lines: ~3800
- Sorry warnings: 34
- Proven core theorems: semantic_truth_lemma_v2, semantic_weak_completeness
- Axioms remaining: finite_forward_existence, finite_backward_existence (compatibility)

### References
- FiniteCanonicalModel.lean header documentation (lines 13-95)
- Task 473 implementation summary
- Task 481/482 (finite_history_from_state and history gluing)
