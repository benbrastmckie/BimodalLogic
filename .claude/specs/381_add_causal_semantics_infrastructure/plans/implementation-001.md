# Implementation Plan: Task #381

**Task**: Add causal semantics infrastructure
**Version**: 001
**Created**: 2026-01-12
**Language**: lean

## Overview

Add the causal operator (A ○→ B, "A causes B") to the Explanatory Extension layer. The documentation in layer-extensions.md specifies this operator but it is not yet implemented in the Lean codebase. This plan adds the syntax, semantics, notation, and complexity function for the causal operator, following the existing patterns for counterfactual (□→) which provides the semantic foundation.

## Phases

### Phase 1: Add Causal Operator to Syntax.lean

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add the `causal` constructor to the `Formula` inductive type
2. Add notation for the causal operator (○→)
3. Update the complexity function to handle the causal case

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Syntax.lean`

**Steps**:
1. Add new constructor after `counterfactual`:
   ```lean
   /-- Causation: A ○→ B (A causes B) -/
   | causal : Formula → Formula → Formula
   ```

2. Add complexity case after `counterfactual`:
   ```lean
   | causal φ ψ => 1 + φ.complexity + ψ.complexity
   ```

3. Add notation in the Notation section:
   ```lean
   /-- Notation for causation -/
   infixr:50 " ○→ " => Formula.causal
   ```

**Verification**:
- Run `lake build Logos.SubTheories.Explanatory.Syntax` to verify compilation
- Use `lean_diagnostic_messages` to check for errors

---

### Phase 2: Add Causal Semantics to Truth.lean

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add truth conditions for the causal operator
2. Document the semantic interpretation with appropriate TODO comments

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Truth.lean`

**Steps**:
1. Add the causal case to `truthAt` after the `counterfactual` case:
   ```lean
   | Formula.causal φ ψ =>
     -- A ○→ B: A causes B
     -- Semantic definition: A is true now, B is true at some future time,
     -- and if A were not the case, B would not be the case in the future.
     -- This follows the counterfactual analysis of causation:
     -- A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)
     --
     -- TODO: Full causal semantics should incorporate:
     -- - Temporal precedence (cause precedes effect)
     -- - Counterfactual dependence
     -- - Possible interventionist refinements (see Woodward 2003)
     -- See "Counterfactual Worlds" (Brast-McKie 2025) for the hyperintensional
     -- foundation underlying this operator.
     truthAt M τ t ht σ idx φ ∧
     (∃ y, ∃ hy : y ∈ τ.domain, y > t ∧ truthAt M τ y hy σ idx ψ) ∧
     truthAt M τ t ht σ idx (Formula.counterfactual (Formula.neg φ) (Formula.neg (Formula.some_future ψ)))
   ```

2. Ensure the case compiles without errors

**Verification**:
- Run `lake build Logos.SubTheories.Explanatory.Truth` to verify compilation
- Use `lean_goal` to inspect type correctness
- Use `lean_diagnostic_messages` to check for errors

---

### Phase 3: Update Documentation and Tests

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update module docstrings to reference causal operator
2. Verify the operator works in simple examples

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Syntax.lean` (docstring update)
- `Theories/Logos/SubTheories/Explanatory/Truth.lean` (docstring update)

**Steps**:
1. Update the module docstring in Syntax.lean to include:
   ```
   - Causal operator: ○→ (causation)
   ```

2. Update the module docstring in Truth.lean to reference the causal operator

3. Verify end-to-end by creating a simple example formula using the causal operator notation

**Verification**:
- Build succeeds with `lake build`
- Documentation is clear and consistent
- Example formulas compile

---

### Phase 4: Final Verification and Build

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Run full build to ensure no regressions
2. Verify all diagnostics are clean

**Files to modify**: None (verification only)

**Steps**:
1. Run `lake build` on the full project
2. Check for any warnings or errors related to the new operator
3. Verify the causal operator appears in IDE completions

**Verification**:
- Full project builds successfully
- No new warnings introduced
- Causal operator is usable from external modules

---

## Dependencies

- Counterfactual conditional (□→) must be implemented (already present)
- Temporal operators (F, some_future) must be implemented (already present)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Semantic definition too simplistic | Medium | Add comprehensive TODO comments documenting refinements needed; the current implementation follows standard counterfactual analysis |
| Termination checking for recursive definition | Low | The causal operator uses existing operators; pattern follows counterfactual which already works |
| Symbol conflict with ○→ notation | Low | Check for existing uses; Unicode circle-arrow is distinctive |

## Success Criteria

- [x] Causal operator constructor added to Formula inductive
- [ ] Notation ○→ works for causal formulas
- [ ] Complexity function handles causal case
- [ ] Truth conditions implemented with counterfactual analysis
- [ ] Documentation updated to reference causal operator
- [ ] Full project builds without errors
- [ ] No regressions in existing functionality

## Notes

The semantic definition follows the standard counterfactual analysis of causation (Lewis 1973, refined by many others):

> A causes B iff A occurred, B occurred later, and if A had not occurred, B would not have occurred.

In our formalization:
- `A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)`

This is a starting point. Future refinements may incorporate:
1. **Interventionist semantics** (Woodward 2003): Focus on manipulability
2. **Structural equations** (Pearl 2000): Causal models with do-calculus
3. **Hyperintensional refinements** (Brast-McKie 2025): The mereological semantics already in place

The TODO comments in the implementation point to these potential enhancements while providing a working baseline.
