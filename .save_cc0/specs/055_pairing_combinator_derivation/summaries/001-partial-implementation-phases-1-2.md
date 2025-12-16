# Pairing Combinator Derivation - Partial Implementation Summary

## Date
2025-12-09

## Status
PARTIAL COMPLETION - Phases 1-2 Complete, Phase 3 Blocked

## Overview
This summary documents the partial implementation of the pairing combinator derivation from K and S axioms. Phases 1 and 2 were successfully completed, proving the flip combinator (C) and single application lemma (app1). Phase 3 (double application lemma - app2) encountered significant complexity issues that exceeded practical implementation time.

## Completed Work

### Phase 1: Flip Combinator (C) - COMPLETE
**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
**Lines**: ~137-241 (105 lines)
**Theorem**: `theorem_flip {A B C : Formula} : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))`

**Description**:
The flip combinator swaps the order of arguments to a binary function, transforming `(A → B → C)` to `(B → A → C)`. This is a key building block for deriving the pairing combinator.

**Proof Strategy**:
1. Use prop_s (S axiom) to weaken: `(A → B → C) → (B → (A → B → C))`
2. Use prop_k (K axiom) to distribute at multiple levels
3. Compose using b_combinator and transitivity via imp_trans
4. Apply modus ponens to chain the transformations

**Build Status**: ✓ Compiles successfully
**Test Status**: Not yet tested
**Complexity**: Medium (13 proof steps, ~105 LOC including comments)

### Phase 2: Single Application Lemma (app1) - COMPLETE
**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
**Lines**: ~243-297 (55 lines)
**Theorem**: `theorem_app1 {A B : Formula} : ⊢ A.imp ((A.imp B).imp B)`

**Description**:
The single application lemma allows applying a function to an argument, corresponding to evaluation in lambda calculus. Given a value of type A and a function `A → B`, we can produce B.

**Proof Strategy**:
1. Use identity combinator at type `(A → B)`: `⊢ (A → B) → (A → B)`
2. Apply flip combinator with the substitution:
   - A := (A → B)
   - B := A
   - C := B
3. This gives: `((A → B) → A → B) → (A → (A → B) → B)`
4. Apply modus ponens to combine identity with flip

**Build Status**: ✓ Compiles successfully
**Test Status**: Not yet tested
**Complexity**: Simple (2 main proof steps, ~55 LOC including comments)

**Key Insight**: The proof elegantly uses flip applied to the identity function, showing that having a value and a function allows application.

## Blocked Work

### Phase 3: Double Application Lemma (app2) - BLOCKED
**Target Theorem**: `theorem_app2 {A B C : Formula} : ⊢ A.imp (B.imp ((A.imp (B.imp C)).imp C))`

**Goal**: Prove that given A, B, and a binary function `f : A → B → C`, we can produce C by applying f to both arguments.

**Attempted Approaches**:
1. **Direct composition** using b_combinator
   - Issue: Type instantiation complexity at nested implication levels

2. **Lifting with prop_s and prop_k**
   - Issue: Required deeply nested applications of K and S axioms
   - Challenge: Managing intermediate types at multiple implication levels

3. **Pattern matching from combine_imp_conj**
   - Issue: The pattern doesn't directly translate to our use case
   - The conjunction introduction uses pairing directly, which is what we're trying to derive

**Specific Technical Challenges**:
1. **Type Level Management**: Working at the `(A → B)` level with prop_k creates complex nested types
2. **Currying/Uncurrying**: `(A → B → C)` vs `((A → B) → C)` are different types in Lean's type theory
3. **prop_k Instantiation**: prop_k has signature `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`, making it difficult to compose at nested levels
4. **Intermediate Steps**: The composition requires threading `(A → B → C)` through `(B → C)` to reach C, which requires precise management of intermediate lemmas

**Compilation Errors Encountered**:
- Type mismatch in prop_k application (expected different nesting of implications)
- Axiom.prop_s application failures due to incorrect formula structure
- Modus ponens argument type mismatches

**Estimated Additional Effort**: 4-6 hours for a clean derivation, or acceptance that app2 should remain axiomatized

## Recommendation

Given the complexity encountered, there are two viable paths forward:

### Option 1: Accept app2 as Axiom (Recommended for MVP)
- Keep `axiom theorem_app2` with semantic justification
- Document the attempted derivation in comments
- Note that the derivation is theoretically possible but practically complex
- Focus implementation effort on higher-value features
- Estimated time savings: 4-6 hours

**Justification**:
- The semantic validity of app2 is clear (applying a binary function to two arguments)
- The construction from K and S alone, while possible, requires intricate combinator manipulation (~50+ lines)
- Other core axioms (like `dni`) also remain axiomatized in the current system
- The derivation adds no mathematical insight beyond what's already proven with flip and app1

### Option 2: Complete the Derivation (Lower Priority)
- Allocate focused 4-6 hour block for clean implementation
- Study more examples of multi-level prop_k composition from combinator calculus literature
- Build helper lemmas for managing nested implication types
- Test each intermediate step independently

**Prerequisites**:
- Review classical combinator calculus literature for V combinator construction
- Study Lean 4's implicit type unification for nested implications
- Create test cases for intermediate lemmas

## Files Modified

### Perpetuity.lean
**Lines Added**: ~160 (including comments)
**New Theorems**:
- `theorem_flip`: Flip combinator (C) - **COMPLETE**
- `theorem_app1`: Single application - **COMPLETE**
- `theorem_app2`: Double application - **INCOMPLETE** (partially implemented, does not compile)

### Build Status
- `lake build Logos.Core.Theorems.Perpetuity`: **FAILS** (due to incomplete app2)
- Phases 1-2 in isolation: **PASS**

## Next Steps

### If Accepting app2 as Axiom:
1. Remove partial app2 implementation
2. Add `axiom theorem_app2` with full semantic justification
3. Update comments to reference attempted derivation
4. Move to Phase 4: Derive pairing from app2
5. Complete Phases 5-6: Testing and documentation

### If Continuing Derivation:
1. Study combinator calculus literature for V combinator patterns
2. Create isolated test file for prop_k composition experiments
3. Build helper lemmas for type management
4. Implement clean version of app2 proof
5. Verify with comprehensive testing

## Lessons Learned

1. **Combinator Derivations are Complex**: Even "simple" combinators like V (app2) require intricate proofs when built from scratch
2. **Type Level Work is Hard**: Working at nested implication levels `(A → B → ...)` requires careful type management
3. **Lean's Type System is Strict**: Implicit type coercions that work in informal mathematics don't automatically work in Lean
4. **Iterative Approach Needed**: Complex proofs benefit from building and testing intermediate helper lemmas
5. **Pragmatic Trade-offs**: Sometimes axiomatization with semantic justification is more valuable than derivation

## References

### Internal
- Plan: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/055_pairing_combinator_derivation/plans/001-pairing-combinator-derivation-plan.md`
- Research Reports:
  - `001-mathlib-theorems.md`
  - `002-proof-strategies.md`
  - `003-project-structure.md`

### External
- [SKI combinator calculus - Wikipedia](https://en.wikipedia.org/wiki/SKI_combinator_calculus)
- [Combinatory Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-combinatory/)
- [To Mock a Mockingbird - Raymond Smullyan](https://en.wikipedia.org/wiki/To_Mock_a_Mockingbird) (V combinator discussion)

## Conclusion

Phases 1 and 2 were successfully completed, providing the flip combinator and single application lemma. These are valuable contributions that can be used throughout the codebase. Phase 3 (app2) proved significantly more complex than estimated, encountering fundamental challenges with type-level composition in Lean 4.

The recommendation is to accept app2 as an axiom for the MVP, similar to how `pairing` and `dni` are currently axiomatized. This pragmatic approach allows the project to maintain forward momentum while preserving the theoretical option to derive app2 in future work.

The completed work demonstrates the feasibility of combinator derivations in Logos and provides patterns for future combinator work, even if the full pairing derivation remains a stretch goal rather than an MVP requirement.
