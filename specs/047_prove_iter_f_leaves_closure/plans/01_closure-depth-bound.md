# Implementation Plan: Prove iter_F Leaves Closure

- **Task**: 47 - prove_iter_f_leaves_closure
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (existing infrastructure is sufficient)
- **Research Inputs**: specs/036_prove_f_nesting_boundary/reports/02_spawn-analysis.md
- **Artifacts**: plans/01_closure-depth-bound.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Prove that for any formula phi, the sequence iter_F 1 phi, iter_F 2 phi, ... eventually leaves the subformula closure closureWithNeg(phi). This establishes that in any RestrictedMCS over phi, the F-iteration sequence must be bounded because formulas outside the closure cannot be in the MCS. The key insight from the spawn analysis is that iter_F produces formulas with strictly increasing complexity, while closureWithNeg is finite, creating a natural bound.

### Research Integration

Key findings from the parent task 36 spawn analysis:
- Pure MCS reasoning is insufficient for arbitrary MCS (may be dense/continuous)
- closureWithNeg is a Finset (finite), enabling pigeonhole-style arguments
- iter_F complexity formula: `complexity(iter_F n phi) = 5*n + complexity(phi)`
- iter_F is injective: distinct depths produce distinct formulas
- RestrictedMCS is bounded by closureWithNeg, so closure-leaving implies MCS-leaving

## Goals & Non-Goals

**Goals**:
- Define `max_F_depth`: maximum F-nesting depth that stays within closureWithNeg
- Prove `iter_F_leaves_closure`: iter_F (max_depth + 1) phi is NOT in closureWithNeg(phi)
- Establish foundation for proving RestrictedMCS boundedness in Task 48

**Non-Goals**:
- Proving boundedness for arbitrary MCS (requires Task 48 for succ_chain_fam)
- Replacing the sorry in f_nesting_is_bounded (that's Task 48's goal)
- Full integration with p_nesting (symmetric, can follow same pattern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Complexity argument may not directly bound closure membership | High | Medium | Alternative: use Finset.card bound + injectivity |
| some_future definition complicates nesting depth | Medium | Low | Existing some_future_complexity lemma already handles this |
| Lean automation may struggle with Finset membership | Medium | Medium | Manual witness construction when needed |

## Implementation Phases

### Phase 1: F-Nesting Depth Definition [COMPLETED]

**Goal**: Define the maximum F-nesting depth of formulas in closureWithNeg(phi).

**Tasks**:
- [ ] Define `f_nesting_depth : Formula -> Nat` to count F-nesting levels
- [ ] Define `max_F_depth_in_closure : Formula -> Nat` as maximum over closureWithNeg
- [ ] Prove `f_nesting_depth_some_future`: f_nesting_depth(F(psi)) = 1 + f_nesting_depth(psi)
- [ ] Prove basic properties: f_nesting_depth >= 0 for all formulas

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Add f_nesting_depth and max_F_depth

**Verification**:
- `lake build Theories.Bimodal.Syntax.SubformulaClosure`
- No errors on new definitions

---

### Phase 2: Closure Membership via F-Depth [COMPLETED]

**Goal**: Prove that iter_F increases F-nesting depth beyond any fixed closure bound.

**Tasks**:
- [ ] Prove `iter_F_f_nesting_depth`: f_nesting_depth(iter_F n phi) = n + f_nesting_depth(phi)
- [ ] Prove `closure_bounded_f_depth`: For all psi in closureWithNeg(phi), f_nesting_depth(psi) <= max_F_depth_in_closure(phi)
- [ ] Prove `iter_F_exceeds_bound`: For n > max_F_depth_in_closure(phi) - f_nesting_depth(phi), f_nesting_depth(iter_F n phi) > max_F_depth_in_closure(phi)

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Add depth lemmas

**Verification**:
- `lake build Theories.Bimodal.Syntax.SubformulaClosure`
- Lemmas type-check without sorry

---

### Phase 3: Main Theorem iter_F Leaves Closure [COMPLETED]

**Goal**: Prove the main result that iter_F eventually produces formulas outside closureWithNeg.

**Tasks**:
- [ ] Prove `iter_F_not_mem_closureWithNeg`: For large enough n, iter_F n phi is not in closureWithNeg(phi)
- [ ] Define `closure_F_bound : Formula -> Nat` as the concrete bound value
- [ ] Prove `iter_F_leaves_closure`: iter_F (closure_F_bound phi + 1) phi is not in closureWithNeg(phi)
- [ ] Prove helper `f_depth_mem_closure`: if psi in closureWithNeg(phi), then f_nesting_depth(psi) <= max_F_depth_in_closure(phi)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Add main theorem

**Verification**:
- `lake build Theories.Bimodal.Syntax.SubformulaClosure`
- Main theorem compiles without sorry
- Check with `lean_verify` for axiom usage

---

### Phase 4: RestrictedMCS Application [IN PROGRESS]

**Goal**: Connect closure bounds to RestrictedMCS membership to enable Task 48.

**Tasks**:
- [ ] Prove `restricted_mcs_iter_F_bound`: For RestrictedMCS M over phi, there exists n such that iter_F n phi not in M
- [ ] Prove `restricted_mcs_F_bounded`: If F(phi) in RestrictedMCS M, then exists d >= 1 with iter_F d phi in M and iter_F (d+1) phi not in M
- [ ] Document how this supports Task 48's goal of proving f_nesting_is_bounded for succ_chain_fam

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Add F-boundedness lemmas

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Core.RestrictedMCS`
- Lemmas connect to existing RestrictedMCS infrastructure

## Testing & Validation

- [ ] `lake build` succeeds for all modified files
- [ ] `lake build Theories.Bimodal` full module builds
- [ ] New lemmas have no sorry or axiom dependencies
- [ ] API is compatible with existing iter_F usage in CanonicalTaskRelation.lean

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - f_nesting_depth, max_F_depth, closure bound lemmas
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - RestrictedMCS F-boundedness
- `specs/047_prove_iter_f_leaves_closure/summaries/01_closure-depth-summary.md` - Execution summary

## Rollback/Contingency

If the f_nesting_depth approach proves difficult:
1. Alternative: Use direct complexity comparison (iter_F_complexity vs max complexity in closure)
2. Alternative: Use Finset cardinality + iter_F injectivity (pigeonhole)
3. If RestrictedMCS integration is complex, deliver Phase 3 result as standalone

The core result (iter_F leaves closureWithNeg) is the essential deliverable; RestrictedMCS integration is a bonus that simplifies Task 48.
