# Spec 072: Complete Deduction Theorem

**Created**: 2025-12-14  
**Status**: Not Started (BLOCKED - requires expert)  
**Priority**: High (blocks Tasks 45, 42)  
**Task**: Task 46 in TODO.md

## Overview

Complete the deduction theorem proof by resolving the sorry in `DeductionTheorem.lean`. This requires expertise in Lean 4 well-founded recursion and structural induction.

## Problem Statement

The deduction theorem states: `(Γ, A ⊢ B) → (Γ ⊢ A → B)`

**Current State**:
- File: `Logos/Core/Metalogic/DeductionTheorem.lean`
- Infrastructure: Complete (helper lemmas for basic cases)
- Blocking Issue: 1 sorry in complex recursion case

**Technical Challenge**:
- Well-founded recursion on derivation structure
- Circular dependencies: Bridge → DeductionTheorem → Perpetuity
- Structural induction with nested contexts

## Blocking Impact

### High Priority (2 tasks blocked)
1. **Task 45**: Complete Inference Rule Refactoring
   - Cannot derive generalized necessitation rules without deduction theorem
   - 5 sorry waiting for resolution

2. **Task 42 Phases 2, 4**: Proof Automation Completion
   - Phase 2: Temporal K infrastructure
   - Phase 4: Temporal axiom derivation

### Medium Priority
- Proof automation improvements
- Theorem derivation capabilities

## Required Expertise

**Skills Needed**:
1. Lean 4 well-founded recursion
2. Structural induction on inductive types
3. Termination proofs
4. Circular dependency resolution

**Estimated Time**: 4-6 hours (expert session)

## Resolution Options

### Option A: Expert Consultation (Recommended)
- Schedule session with Lean 4 recursion expert
- Pair programming to resolve well-founded recursion
- Direct path to resolution
- **Estimated**: 4-6 hours

### Option B: Architectural Refactoring
- Extract problematic cases to separate lemmas
- Simplify recursion structure
- May require significant restructuring
- **Estimated**: 8-12 hours
- **Risk**: May not resolve core issue

### Option C: Alternative Proof Strategy
- Research alternative deduction theorem proofs
- Implement using different induction principle
- **Estimated**: 10-15 hours
- **Risk**: High, may not work

## Success Criteria

- [ ] Sorry removed from `DeductionTheorem.lean`
- [ ] Deduction theorem proven for all inference rules
- [ ] Works with new necessitation rules (not just old modal_k)
- [ ] No circular dependencies introduced
- [ ] No performance regressions
- [ ] Task 45 unblocked (can derive generalized rules)
- [ ] Task 42 Phases 2, 4 unblocked

## Files

**Primary**:
- `Logos/Core/Metalogic/DeductionTheorem.lean` - Main file with sorry

**Dependencies**:
- `Logos/Core/ProofSystem/Derivation.lean` - Derivable inductive type
- `Logos/Core/Theorems/Perpetuity/` - Uses deduction theorem

**Blocked Files**:
- `Logos/Core/Theorems/GeneralizedNecessitation.lean` - 2 sorry
- `Logos/Core/Automation/AesopRules.lean` - 2 sorry
- `Logos/Core/Theorems/Perpetuity/Bridge.lean` - 1 sorry

## References

- [Research Report: Well-Founded Recursion Approach](research-report-well-founded-recursion.md) - **COMPREHENSIVE IMPLEMENTATION GUIDE**
- [Partial Completion Summary](summary-partial-completion.md) - Current state analysis
- [Task 42 Plan](../065_proof_automation_temporal_deduction/plans/001-proof-automation-completion-plan.md)
- [Task 44 Plan](../071_inference_rule_refactoring_necessitation/plans/001-inference-rule-refactoring-plan.md)
- [Deduction Theorem - Wikipedia](https://en.wikipedia.org/wiki/Deduction_theorem)
- [Lean 4 Well-Founded Recursion](https://lean-lang.org/theorem_proving_in_lean4/induction_and_recursion.html#well-founded-recursion-and-induction)

## Research Findings

A comprehensive research report has been completed analyzing the best approach to completing the deduction theorem. Key findings:

**Recommended Approach**: Well-Founded Recursion with Height Measure (Option A)
- **Time Estimate**: 3.5-4.5 hours
- **Risk Level**: Low
- **Success Probability**: >90%

**Implementation Plan**: 4 phases
1. Define height measure (30 min)
2. Prove height properties (60 min)
3. Reformulate main theorem with `termination_by` (90-120 min)
4. Testing and validation (30 min)

**Key Insights**:
- Mathlib provides proven patterns for this exact problem
- Height measure on derivations enables well-founded recursion
- The problematic weakening case is solvable with context permutation + recursion
- Multiple fallback options available if primary approach fails

See [research-report-well-founded-recursion.md](research-report-well-founded-recursion.md) for complete details.

## Next Steps

1. ✅ **COMPLETE**: Research best approach (comprehensive report available)
2. **Immediate**: Review research report and implementation plan
3. **Short-term**: Implement Phase 1 (height measure) - 30 minutes
4. **Medium-term**: Complete Phases 2-4 following research plan - 3-4 hours
5. **Long-term**: Unblock dependent tasks (45, 42) and remove 5 sorry
