# Research Report: Task #393

**Task**: Remove incorrect causal operator definition
**Date**: 2026-01-12
**Focus**: Identify incorrect causal semantics and determine removal strategy

## Summary

The current implementation of the causal operator (A ○→ B) in `Truth.lean` uses the simple Lewis (1973) counterfactual analysis of causation. However, the project paper "Counterfactual Worlds" (Brast-McKie 2025) specifies a much more sophisticated semantics at line 626 involving three complex conditions with expected evolutions and minimal subevolutions. The current implementation should be removed and replaced with a stub to enable systematic future implementation of the correct semantics from the paper.

## Findings

### Current Implementation (Incorrect)

**Location**: `Theories/Logos/SubTheories/Explanatory/Truth.lean` lines 148-161

**Current semantics**:
```lean
| Formula.causal φ ψ =>
    -- A ○→ B: A causes B
    -- Semantic definition follows counterfactual analysis of causation (Lewis 1973):
    -- A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)
    truthAt M τ t ht σ idx φ ∧
    (∃ y, ∃ hy : y ∈ τ.domain, y > t ∧ truthAt M τ y hy σ idx ψ) ∧
    truthAt M τ t ht σ idx (Formula.counterfactual (Formula.neg φ) (Formula.neg (Formula.some_future ψ)))
```

This defines "A causes B" as:
1. A is true now
2. B is true at some future time
3. If A were not the case, B would not occur in the future

### Paper Specification (Correct)

**Location**: `/home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex` line 626

**Paper semantics** (simplified from LaTeX):
```
M, c ⊨ A ○→ B iff:
(1) |A| ⊑ β(x) and |B| ⊑ β(y)
    [cause and effect are included in background assumptions]

(2) For all s ∈ β(x)⁺ and τ ∈ ⟨s⟩ₓ, there is some δ ⊑* τ where δ(y) ∈ ⟦B⟧⁺
    and for every γ ⊑* δ, if γ(y) ∈ ⟦B⟧⁺, then γ(x) ∈ ⟦A⟧⁺
    [cause makes substantial contribution via minimal subevolutions]

(3) For every t ∈ (β(y)/|B|)⁺ and λ ∈ ⟨t⟩ᵧ, if λ(x) ∈ ⟦A⟧⁺, then there
    is some d ⊑ λ(x) where d ∈ ⟦A⟧⁺ and ω(y) ∈ ⟦B⟧⁺ for all ω ∈ ⟨d⟩ₓ
    [counterfactual dependence via expected evolutions]
```

Where:
- `c = ⟨x, y, β⟩` is a context with time of cause x, time of effect y, and background assumptions β
- `⟨s⟩ₓ` is the set of expected evolutions occupying state s at time x
- `δ ⊑* τ` means δ is an expected subevolution of τ
- `β(y)/|B|` is the result of inverting the effect in the background assumption

### Key Differences

| Aspect | Current (Lewis 1973) | Paper (Brast-McKie 2025) |
|--------|---------------------|-------------------------|
| **Complexity** | Simple 3-conjunct | Complex 3-condition |
| **Context** | None | ⟨time_cause, time_effect, background⟩ |
| **Evolutions** | None | Expected evolutions + subevolutions |
| **Contribution** | None | Minimal subevolution requirement |
| **Counterfactual** | Simple ¬A □→ ¬FB | Complex inverted effect condition |
| **Handles preemption** | No | Yes |
| **Handles overdetermination** | No | Yes |

### Why Current Implementation is Wrong

1. **Missing context parameter**: The paper semantics requires a context `c = ⟨x, y, β⟩` specifying the time of cause, time of effect, and background assumptions. The current implementation uses the evaluation time and some future time, but has no background assumption structure.

2. **No evolution structure**: The paper uses expected evolutions (discrete evolutions where successor states are "expected") and subevolutions. The current implementation uses only world-histories.

3. **No substantial contribution**: The paper requires condition (2) that the cause makes a "substantial contribution" via minimal subevolutions. The Lewis analysis cannot distinguish cases of preemption.

4. **Oversimplified counterfactual**: Condition (3) in the paper handles cases where the effect fails to occur despite the cause occurring, requiring analysis of "preventers". The Lewis analysis just checks simple counterfactual dependence.

### Files Affected

1. **Syntax.lean** (lines 73-77, 167, 202): Contains the `causal` constructor and notation
   - The `causal` constructor can remain (syntax is correct)
   - The docstring references counterfactual analysis and should be updated

2. **Truth.lean** (lines 148-161): Contains the incorrect semantic definition
   - The entire `Formula.causal` case should be replaced with a stub

### Related Components

- The counterfactual conditional (□→) at lines 138-147 is correctly implemented as a primitive
- The causal operator should also be primitive, not defined in terms of counterfactuals
- Task 394 will implement the correct semantics from the paper

## Recommendations

### 1. Remove semantic definition in Truth.lean

Replace the current implementation with a `sorry`-based stub:

```lean
| Formula.causal φ ψ =>
    -- A ○→ B: A causes B
    -- STUB: Awaiting implementation of correct semantics from
    -- "Counterfactual Worlds" (Brast-McKie 2025), line 626.
    --
    -- The causal operator is PRIMITIVE (like the counterfactual conditional),
    -- NOT defined in terms of the counterfactual.
    --
    -- Correct semantics requires:
    -- - Context parameter ⟨time_cause, time_effect, background_assumptions⟩
    -- - Expected evolution structure over state space
    -- - Three conditions: inclusion, substantial contribution, difference-making
    --
    -- See Task 394 for implementation details.
    sorry
```

### 2. Update docstring in Syntax.lean

Change the docstring for the `causal` constructor from:
```lean
/-- Causation: A ○→ B (A causes B)
    Semantic definition follows counterfactual analysis:
    A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)
    See "Counterfactual Worlds" (Brast-McKie 2025) for hyperintensional foundation. -/
```

To:
```lean
/-- Causation: A ○→ B (A causes B)

    This operator is PRIMITIVE (like the counterfactual conditional □→).

    AWAITING IMPLEMENTATION: The correct semantics from "Counterfactual Worlds"
    (Brast-McKie 2025) line 626 requires context parameters and expected evolutions.
    See Task 394 for research on porting the paper semantics. -/
```

### 3. Update module docstring in Truth.lean

Remove the reference to counterfactual analysis in the module docstring (line 27).

### 4. Preserve syntax and notation

Keep all syntax elements:
- The `Formula.causal` constructor
- The `complexity` case
- The `○→` notation

These are correct and will be used by Task 394's implementation.

## References

- `Theories/Logos/SubTheories/Explanatory/Truth.lean` - Current incorrect implementation
- `Theories/Logos/SubTheories/Explanatory/Syntax.lean` - Causal operator syntax
- `/home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex` line 626 - Correct semantics
- `specs/381_add_causal_semantics_infrastructure/` - Parent task artifacts
- Task 394 - Follow-up task to implement correct semantics

## Next Steps

1. Create implementation plan with specific edits
2. Remove the incorrect semantic definition
3. Update docstrings to indicate primitive status and awaiting implementation
4. Ensure the code still compiles (with sorry)
5. Verify Task 394's description accurately captures the implementation work
