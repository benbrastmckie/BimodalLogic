# Research Report: Task #381

**Task**: Add causal semantics infrastructure
**Date**: 2026-01-11
**Focus**: General research

## Summary

The Explanatory Extension documentation specifies a causal operator (A ○→ B, "A causes B") as part of the layer, but this operator is not yet implemented in the Lean codebase. The existing implementation has the counterfactual conditional (□→) which provides the semantic foundation for causation, but the causal operator itself needs to be added to the Syntax.lean and Truth.lean files with appropriate stub definitions and documentation.

## Findings

### Documentation Specification

**layer-extensions.md** (lines 137-140) specifies:
```
| **Causation** | A ○→ B | "A causes B" |
```

**recursive-semantics.md** mentions causal operators in the Explanatory Extension header (line 29):
```
(modal, temporal, counterfactual, causal)
```

However, the detailed semantic specification for the causal operator is not provided in the documentation - only the counterfactual conditional (□→) has full semantic specification.

### Current Lean Implementation

**Syntax.lean** (Theories/Logos/SubTheories/Explanatory/Syntax.lean):
- Implements all modal operators (□, ◇)
- Implements all temporal operators (H, G, P, F, ◁, ▷)
- Implements counterfactual conditional (□→) and derived might-counterfactual (◇→)
- Implements store/recall operators (↑ⁱ, ↓ⁱ)
- **Missing**: Causal operator (○→)

**Truth.lean** (Theories/Logos/SubTheories/Explanatory/Truth.lean):
- Has semantic evaluation for all implemented operators
- Counterfactual is evaluated lines 137-146 with mereological approach
- **Missing**: Truth conditions for causal operator

### Semantic Foundation for Causation

Based on the documentation and academic references cited:
1. The counterfactual conditional (□→) provides the semantic primitives needed for causation
2. Causation can likely be defined in terms of counterfactuals plus temporal ordering
3. The standard analysis: "A causes B" ≈ "A occurred, then B occurred, and if A had not occurred, B would not have occurred"

Possible semantic definition:
```
A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)
```
"A is true now, B is true at some future time, and if A were not the case, B would not be the case in the future."

### Related Research References

From the README theoretical foundations:
- **"Counterfactual Worlds"** (Brast-McKie 2025) - Hyperintensional semantics for counterfactual conditionals
- This paper is listed as "Foundation for the explanatory layer extension (counterfactual □→ and causal ○→ operators)"

## Recommendations

1. **Add causal operator to Syntax.lean**:
   - Add new constructor `| causal : Formula → Formula → Formula` to the Formula inductive
   - Add notation `infixr:50 " ○→ " => Formula.causal`

2. **Add placeholder truth conditions to Truth.lean**:
   - Add case for `Formula.causal` in `truthAt`
   - Implement as derived operator: `A ∧ FB ∧ (¬A □→ ¬FB)` or use `sorry` with clear TODO comment

3. **Add documentation comments**:
   - Reference the "Counterfactual Worlds" paper
   - Note the relationship to counterfactual conditional
   - Mark as requiring full semantic specification from research

4. **Update complexity function** in Syntax.lean

## References

- Theories/Logos/docs/Research/recursive-semantics.md - Line 29 mentions causal
- Theories/Logos/docs/Research/layer-extensions.md - Lines 137-140 define causation operator
- Brast-McKie, "Counterfactual Worlds" (2025) - Foundation for causal operator semantics

## Next Steps

1. Create implementation plan with phased approach
2. Add syntax infrastructure first
3. Add semantic stub with appropriate TODO comments
4. Update all dependent files (complexity, etc.)
