# Research Report: Revise Lean Source Code for Logos Theory Definitions
- **Task**: 666 - Revise Lean Source Code for Logos Theory Definitions
- **Started**: 2026-01-23
- **Completed**: 2026-01-23
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**: 
  - Theories/Logos/latex/subfiles/01-ConstitutiveFoundation.tex (lines 78, 91, 93)
  - Theories/Logos/SubTheories/Foundation/Interpretation.lean (lines 91, 93)
  - Theories/Logos/SubTheories/Foundation/Frame.lean
  - Theories/Logos/SubTheories/Foundation/Proposition.lean
  - Theories/Logos/SubTheories/Foundation/Semantics.lean
  - Lean 4 documentation on Set vs Prop relationship
- **Artifacts**: 
  - specs/666_revise_lean_source_code_logos_theory_definitions/reports/research-003.md
- **Standards**: report-format.md

## Executive Summary
- Previous research report (research-002.md) incorrectly claimed that Lean implementation matches LaTeX definitions
- There is a **critical mathematical discrepancy**: LaTeX defines predicate types as `((Fin n → State) → State) → Prop` while Lean uses `Set ((Fin n → State) → State)`
- In Lean 4, `Set α` is defined as `α → Prop`, making these **mathematically equivalent** but **semantically different**
- The Lean implementation is **mathematically sound** but does not match the LaTeX specification's semantic intent
- Documentation updates are needed to reflect the actual implementation and its mathematical correctness

## Context & Scope
- **Objective**: Investigate discrepancies between LaTeX and Lean implementations of Logos theory definitions
- **Scope**: Focus on Set vs Prop discrepancy in predicate types and overall mathematical correctness
- **Key Issue**: Line 78 in LaTeX vs lines 91,93 in Lean implementation

## Findings

### 1. Set vs Prop Mathematical Relationship in Lean 4

**Critical Discovery**: In Lean 4, `Set α` is literally defined as `α → Prop`
- `Set α := α → Prop` (from Mathlib/Data/Set/Basic.lean)
- Therefore `Set ((Fin n → State) → State)` is equivalent to `((Fin n → State) → State) → Prop`
- **Mathematical equivalence holds**: Both formulations define the same mathematical object

### 2. Semantic Differences Despite Mathematical Equivalence

**LaTeX Semantic Intent** (line 78):
```latex
\verifiertype{F}, \falsifiertype{F} : ((\Fin\;n \to \statespace) \to \statespace) \to \Prop
```
- Directly uses predicate notation: "functions from functions to propositions"
- Emphasizes the **logical nature** of verifier/falsifier predicates

**Lean Implementation** (lines 91, 93):
```lean
verifierFns : Set ((Fin n → F.State) → F.State)
falsifierFns : Set ((Fin n → F.State) → F.State)
```
- Uses set notation: "sets of functions satisfying certain properties"
- Emphasizes the **collectional nature** of verifier/falsifier functions

### 3. Mathematical Soundness Analysis

**The Lean implementation is mathematically correct** because:
- `Set ((Fin n → State) → State)` = `((Fin n → State) → State) → Prop`
- Both define predicates on functions from argument tuples to states
- The implementation correctly captures the intended mathematical structure

### 4. Impact on Formal Correctness

**No impact on formal correctness**:
- Verification/falsification semantics in `Semantics.lean` work correctly with Set-based definition
- Mereological constraints (fusion closure, input fusion) are properly implemented
- The bilateral proposition framework remains sound

### 5. Other Alignment Issues Found

**Complete structural match confirmed**:
- Function symbol types: `((Fin n → S) → S)` ✓
- Mereological constraints: fusion closure and input fusion ✓
- Sentence letter specialization: `State → Prop` correctly handles 0-ary case ✓

## Decisions

1. **Lean implementation is mathematically sound** - no logical revision required
2. **Documentation must be updated** to clarify the Set/Prop equivalence
3. **LaTeX specification should acknowledge** the alternative Set-based formulation
4. **Previous research conclusion was incorrect** - there is a discrepancy, but it's benign

## Recommendations

### 1. Update LaTeX Documentation
- Add explanatory note about Set vs Prop equivalence in Lean 4
- Acknowledge that `Set α := α → Prop` makes formulations mathematically equivalent
- Update the outdated TODO comment (line 70) to reflect current implementation status

### 2. Add Lean Documentation Comments
- Include explicit comment in `Interpretation.lean` explaining the Set/Prop relationship
- Add remark about why Set formulation was chosen (emphasizes collectional aspect)
- Reference the mathematical equivalence with LaTeX predicate notation

### 3. Consider Semantic Clarification
- Evaluate whether the predicate-based LaTeX notation better captures theoretical intent
- Consider adding Lean notation aliases for clarity if needed
- Document the design decision in both LaTeX and Lean

## Risks & Mitigations

### Risk: Confusion about Set/Prop Equivalence
- **Mitigation**: Add explicit documentation and comments explaining the relationship
- **Impact**: Low - mainly affects readability and understanding

### Risk: Theoretical Misalignment
- **Risk**: Despite mathematical equivalence, semantic emphasis differs (logical vs collectional)
- **Mitigation**: Document the design decision and theoretical rationale
- **Impact**: Very low - no impact on formal correctness

## Appendix

### Technical Notes
- Lean's `Set α` is defined in `Mathlib/Data/Set/Basic.lean` as `α → Prop`
- This is a fundamental design choice in Lean's type theory
- The equivalence `Set ((Fin n → State) → State) = ((Fin n → State) → State) → Prop` holds by definition
- Proof: By substituting `α := ((Fin n → State) → State)` in `Set α := α → Prop`

### References
- Lean 4 Documentation: Sets and set-like objects (community)
- Mathlib Source: Mathlib/Data/Set/Basic.lean
- Task 666 Specification: Revise Lean source code for Logos theory definitions
- Previous Research: research-002.md (incorrectly concluded no discrepancy)