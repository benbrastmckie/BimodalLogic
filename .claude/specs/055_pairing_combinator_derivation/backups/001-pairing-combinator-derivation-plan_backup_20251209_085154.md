# Implementation Plan: Derive Pairing Combinator from K and S Axioms

## Metadata

- **Feature**: Derive pairing combinator (`A → B → A ∧ B`) from K and S propositional axioms
- **Status**: [NOT STARTED]
- **Created**: 2025-12-09
- **Complexity**: 3 (Deep - requires intricate combinator calculus derivations)
- **Estimated Effort**: 8-12 hours
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
- **TODO Reference**: Task 21 - Derive Pairing Combinator

## Summary

This plan derives the `pairing` axiom as a theorem using combinator calculus. The pairing combinator has type `A → B → A ∧ B` (conjunction introduction) and is currently axiomatized in Perpetuity.lean. The derivation uses the Vireo combinator pattern `V = λx.λy.λf.(f x y)` translated to SKI combinators.

## Background

### Current Status

From `Perpetuity.lean` (line ~171):
```lean
axiom pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))
```

### Conjunction Definition

From `Formula.lean`:
```lean
def and (φ ψ : Formula) : Formula := (φ.imp ψ.neg).neg
-- Expanded: A ∧ B = ((A → (B → ⊥)) → ⊥)
```

### Goal Expanded

We need to prove:
```lean
⊢ A → (B → ((A → (B → ⊥)) → ⊥))
```

### Combinator Correspondence

| Logos Name | Combinator | Type |
|------------|------------|------|
| `prop_s` (K) | K | `A → B → A` |
| `prop_k` (S) | S | `(A → B → C) → (A → B) → A → C` |
| `identity` (I) | I = SKK | `A → A` |
| `b_combinator` (B) | B = S(KS)K | `(B → C) → (A → B) → A → C` |
| `flip` (C) | C = S(BBS)(KK) | `(A → B → C) → B → A → C` |
| `pairing` (V) | V = S(S(KS)(S(KK)I))(KI) | `A → B → (A → B → C) → C` |

## Implementation Phases

### Phase 1: Derive Flip Combinator (C) [NOT STARTED]

**Goal**: Derive the C (flip) combinator: `⊢ (A → B → C) → (B → A → C)`

- **Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
- **Goal**: `{A B C : Formula} : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))`
- **Strategy**: Use S and K axioms with B combinator to swap argument order
- **Complexity**: Medium (20-25 lines)
- **dependencies**: []

**Tasks**:

- [ ] `theorem_flip` - Derive flip combinator
  - Goal: `⊢ (A → B → C) → (B → A → C)`
  - Strategy:
    1. Use K axiom: `⊢ (A → B → C) → (B → (A → B → C))`
    2. Use S axiom to redistribute: `⊢ (B → (A → B → C)) → ((B → A) → (B → C))`
    3. Compose with B combinator for final form
  - Complexity: Medium

**Success Criteria**:
- [ ] `lake build` succeeds
- [ ] Flip compiles with example instantiation
- [ ] No lint warnings

---

### Phase 2: Derive Single Application Lemma [NOT STARTED]

**Goal**: Derive single argument application: `⊢ A → (A → B) → B`

- **Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
- **Goal**: `{A B : Formula} : ⊢ A.imp ((A.imp B).imp B)`
- **Strategy**: This is flip applied to identity: `flip identity` where `identity : (A → B) → A → B`
- **Complexity**: Simple (10-15 lines)
- **dependencies**: [Phase 1]

**Tasks**:

- [ ] `theorem_app1` - Derive single application lemma
  - Goal: `⊢ A → (A → B) → B`
  - Strategy:
    1. Use flip on the identity function
    2. `identity : ⊢ (A → B) → (A → B)`
    3. `flip identity : ⊢ A → (A → B) → B`
  - Complexity: Simple

**Success Criteria**:
- [ ] `lake build` succeeds
- [ ] App1 compiles with example instantiation
- [ ] Proof uses flip from Phase 1

---

### Phase 3: Derive Double Application Lemma [NOT STARTED]

**Goal**: Derive double argument application: `⊢ A → B → (A → B → C) → C`

- **Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
- **Goal**: `{A B C : Formula} : ⊢ A.imp (B.imp ((A.imp (B.imp C)).imp C))`
- **Strategy**: Compose app1 twice with appropriate argument handling
- **Complexity**: Medium (15-20 lines)
- **dependencies**: [Phase 1, Phase 2]

**Tasks**:

- [ ] `theorem_app2` - Derive double application lemma
  - Goal: `⊢ A → B → (A → B → C) → C`
  - Strategy:
    1. Build from app1: `⊢ A → (A → B → C) → (B → C)`
    2. Compose with: `⊢ (B → C) → B → C` (identity)
    3. Use S axiom to combine: `⊢ A → B → (A → B → C) → C`
  - Complexity: Medium

**Success Criteria**:
- [ ] `lake build` succeeds
- [ ] App2 compiles with example instantiation
- [ ] Proof uses flip and app1 from earlier phases

---

### Phase 4: Derive Pairing Theorem [NOT STARTED]

**Goal**: Replace `axiom pairing` with `theorem pairing`

- **Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
- **Goal**: `(A B : Formula) : ⊢ A.imp (B.imp (A.and B))`
- **Strategy**: Pairing is app2 with C = ⊥ (since A ∧ B = (A → B → ⊥) → ⊥)
- **Complexity**: Simple (5-10 lines)
- **dependencies**: [Phase 3]

**Tasks**:

- [ ] `theorem_pairing` - Replace axiom with theorem
  - Goal: `⊢ A → B → A ∧ B`
  - Strategy:
    1. Instantiate app2 with `C = Formula.bot`
    2. Apply definitional equality: `A ∧ B = (A → B → ⊥) → ⊥`
    3. Result: `⊢ A → B → (A → B → ⊥) → ⊥ = A → B → A ∧ B`
  - Complexity: Simple

- [ ] `cleanup_axiom` - Remove axiom declaration
  - Goal: Delete `axiom pairing` line
  - Strategy: Change `axiom` to `theorem` with proof body
  - Complexity: Trivial

**Success Criteria**:
- [ ] `axiom pairing` replaced with `theorem pairing`
- [ ] `lake build` succeeds
- [ ] All existing uses of `pairing` still compile
- [ ] No lint warnings

---

### Phase 5: Add Tests [NOT STARTED]

**Goal**: Add comprehensive tests for all new lemmas

- **Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Theorems/PerpetuityTest.lean`
- **dependencies**: [Phase 4]

**Tasks**:

- [ ] `test_flip` - Test flip combinator
  - Goal: Verify flip with various formula instantiations
  - Strategy: Add example declarations
  - Complexity: Simple

- [ ] `test_app1` - Test single application
  - Goal: Verify app1 with atomic and compound formulas
  - Strategy: Add example declarations
  - Complexity: Simple

- [ ] `test_app2` - Test double application
  - Goal: Verify app2 with various formulas
  - Strategy: Add example declarations
  - Complexity: Simple

- [ ] `test_pairing_derivation` - Test derived pairing
  - Goal: Verify pairing still works with existing test patterns
  - Strategy: Run existing tests, add new ones
  - Complexity: Simple

**Success Criteria**:
- [ ] `lake build LogosTest.Core.Theorems.PerpetuityTest` succeeds
- [ ] Coverage for all new lemmas
- [ ] Existing pairing tests still pass

---

### Phase 6: Update Documentation [NOT STARTED]

**Goal**: Update documentation to reflect completed derivation

- **dependencies**: [Phase 4, Phase 5]

**Tasks**:

- [ ] `doc_perpetuity_lean` - Update Perpetuity.lean docstrings
  - Goal: Update module header and pairing docstring
  - Strategy: Change "axiom" references to "theorem"
  - Complexity: Simple

- [ ] `doc_todo` - Update TODO.md
  - Goal: Mark Task 21 as COMPLETE
  - Strategy: Edit TODO.md with completion status
  - Complexity: Simple

- [ ] `doc_implementation_status` - Update IMPLEMENTATION_STATUS.md
  - Goal: Update axiom count (reduce by 1)
  - Strategy: Edit Implementation Status section
  - Complexity: Simple

- [ ] `doc_claude_md` - Update CLAUDE.md
  - Goal: Update pairing status in Theorems Package section
  - Strategy: Note pairing is now derived, not axiomatized
  - Complexity: Simple

**Success Criteria**:
- [ ] All documentation consistent
- [ ] Axiom counts accurate
- [ ] No references to `axiom pairing` remain

## Testing Strategy

### Unit Tests

- Flip combinator instantiation tests
- App1 with atomic formulas (atom "p", atom "q")
- App2 with atomic and compound formulas
- Pairing regression tests (existing tests)

### Integration Tests

- Full `lake build` succeeds
- `lake test` passes
- All perpetuity theorems still compile
- No breaking changes to API

### Regression Tests

- `combine_imp_conj` still works (uses pairing)
- `combine_imp_conj_3` still works
- P1 proof still compiles (uses pairing internally)
- All existing example declarations compile

## Risk Assessment

### High Risk

1. **Flip derivation complexity**
   - Risk: May be more complex than estimated
   - Mitigation: Incremental approach, test each step
   - Contingency: Document attempted approach, keep axiom

### Medium Risk

2. **Proof length exceeds estimates**
   - Risk: Derivation may be 60+ lines instead of 40-55
   - Mitigation: Accept longer proof if readable
   - Contingency: Add extensive comments for clarity

3. **Type unification issues**
   - Risk: Lean may struggle with complex formula substitutions
   - Mitigation: Use explicit type annotations
   - Contingency: Add intermediate lemmas

### Low Risk

4. **Test failures**
   - Risk: Existing tests may fail with theorem vs axiom
   - Mitigation: API preserved (same name, same type)
   - Note: Should not occur if type signature unchanged

## Verification

### Completeness Checks

After implementation:
- [ ] `flip` lemma proven (no sorry)
- [ ] `app1` lemma proven (no sorry)
- [ ] `app2` lemma proven (no sorry)
- [ ] `pairing` is theorem (not axiom)
- [ ] Zero sorry in Perpetuity.lean

### Soundness Verification

- [ ] `lake build` succeeds
- [ ] `lake test` succeeds
- [ ] `lake lint` has no warnings

### Documentation Verification

- [ ] Perpetuity.lean docstrings updated
- [ ] TODO.md Task 21 marked complete
- [ ] IMPLEMENTATION_STATUS.md axiom count reduced
- [ ] CLAUDE.md updated

## Fallback Plan

If derivation proves intractable after 8 hours:

1. Document the attempted approach in detail
2. Note specific blocking issues
3. Keep `axiom pairing` with enhanced semantic justification
4. Add comment explaining derivation complexity
5. Mark Task 21 as SKIPPED (deferred to future work)

This is acceptable because:
- Pairing has semantic justification (sound in task semantics)
- The derivation adds no mathematical insight
- Other axioms (`dni`) also remain axiomatized

## Summary

| Phase | Description | Est. Lines | Complexity |
|-------|-------------|------------|------------|
| 1 | Flip combinator | 20-25 | Medium |
| 2 | Single application | 10-15 | Simple |
| 3 | Double application | 15-20 | Medium |
| 4 | Pairing theorem | 5-10 | Simple |
| 5 | Tests | 30-40 | Simple |
| 6 | Documentation | N/A | Simple |

**Total estimated proof lines**: 50-70

## References

### Research Reports

- `001-mathlib-theorems.md` - Mathlib search results and combinator background
- `002-proof-strategies.md` - Detailed derivation strategies and algorithms
- `003-project-structure.md` - Project conventions and implementation guidelines

### External References

- [SKI combinator calculus - Wikipedia](https://en.wikipedia.org/wiki/SKI_combinator_calculus)
- [Combinatory Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-combinatory/)
- [Curry-Howard correspondence](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence)

### Project Files

- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` - Main implementation
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean` - K and S axioms
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md` - Task 21 definition
