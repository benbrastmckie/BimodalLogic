# Implementation Plan: Derive Pairing Combinator from K and S Axioms

## Metadata

- **Date**: 2025-12-09
- **Feature**: Derive pairing combinator (`A → B → A ∧ B`) from K and S propositional axioms
- **Scope**: Combinator calculus derivation proving pairing axiom as theorem using flip, app1, app2 lemmas. Transforms `axiom pairing` into `theorem pairing` using only prop_k (K) and prop_s (S) axioms.
- **Status**: [IN PROGRESS]
- **Estimated Hours**: 8-12 hours
- **Complexity Score**: 51
- **Structure Level**: 0
- **Estimated Phases**: 6
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Mathlib Theorems](../reports/001-mathlib-theorems.md)
  - [Proof Strategies](../reports/002-proof-strategies.md)
  - [Project Structure](../reports/003-project-structure.md)
  - [Lean Plan Standards Gap Analysis](../reports/1-does_not_follow_the_lean_plan_.md)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
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

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
| 3 | lean | lean-implementer |
| 4 | lean | lean-implementer |
| 5 | software | implementer-coordinator |
| 6 | software | implementer-coordinator |

---

### Phase 1: Derive Flip Combinator (C) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
dependencies: []

**Objective**: Derive the C (flip) combinator: `⊢ (A → B → C) → (B → A → C)`

**Complexity**: Medium

**Theorems**:
- [x] `theorem_flip`: Derive flip combinator (C = S(BBS)(KK))
  - Goal: `{A B C : Formula} : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))`
  - Strategy: Apply prop_k for initial setup, then prop_s to redistribute, compose with b_combinator
  - Complexity: Medium
  - Estimated: 2 hours

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
```

**Expected Duration**: 2 hours

---

### Phase 2: Derive Single Application Lemma [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
dependencies: [1]

**Objective**: Derive single argument application: `⊢ A → (A → B) → B`

**Complexity**: Low

**Theorems**:
- [x] `theorem_app1`: Derive single application lemma (flip applied to identity)
  - Goal: `{A B : Formula} : ⊢ A.imp ((A.imp B).imp B)`
  - Strategy: Apply theorem_flip to identity combinator (prop_s applied to prop_k twice)
  - Complexity: Simple
  - Prerequisites: theorem_flip
  - Estimated: 1 hour

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
```

**Expected Duration**: 1 hour

---

### Phase 3: Derive Double Application Lemma [IN PROGRESS]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
dependencies: [1, 2]

**Objective**: Derive double argument application: `⊢ A → B → (A → B → C) → C`

**Complexity**: Medium

**Theorems**:
- [ ] `theorem_app2`: Derive double application lemma (Vireo combinator pattern)
  - Goal: `{A B C : Formula} : ⊢ A.imp (B.imp ((A.imp (B.imp C)).imp C))`
  - Strategy: Compose theorem_app1 with prop_s redistribution, use identity for final form
  - Complexity: Medium
  - Prerequisites: theorem_flip, theorem_app1
  - Estimated: 2 hours

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
```

**Expected Duration**: 2 hours

---

### Phase 4: Derive Pairing Theorem [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
dependencies: [3]

**Objective**: Replace `axiom pairing` with `theorem pairing`

**Complexity**: Low

**Theorems**:
- [ ] `theorem_pairing`: Derive pairing from app2 with C = ⊥
  - Goal: `(A B : Formula) : ⊢ A.imp (B.imp (A.and B))`
  - Strategy: Instantiate theorem_app2 with Formula.bot, apply conjunction definition (A ∧ B = (A → B → ⊥) → ⊥)
  - Complexity: Simple
  - Prerequisites: theorem_app2
  - Estimated: 0.5 hours

- [ ] `cleanup_axiom`: Replace axiom declaration with theorem
  - Goal: Change `axiom pairing` to `theorem pairing` with proof body
  - Strategy: Delete axiom line, add theorem with proof using derived lemmas
  - Complexity: Simple
  - Prerequisites: theorem_pairing
  - Estimated: 0.5 hours

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
# Verify axiom is gone
grep -c "axiom pairing" Logos/Core/Theorems/Perpetuity.lean | test $(cat) -eq 0
```

**Expected Duration**: 1 hour

---

### Phase 5: Add Tests [NOT STARTED]
implementer: software
dependencies: [4]

**Objective**: Add comprehensive tests for all new lemmas

**Complexity**: Low

**Tasks**:
- [ ] `test_flip`: Test flip combinator instantiation
  - Goal: Verify flip with atomic and compound formula types
  - Strategy: Add example declarations in PerpetuityTest.lean
  - Complexity: Simple
  - Estimated: 0.5 hours

- [ ] `test_app1`: Test single application lemma
  - Goal: Verify app1 with (atom "p"), (atom "q") and compound formulas
  - Strategy: Add example declarations exercising app1
  - Complexity: Simple
  - Estimated: 0.5 hours

- [ ] `test_app2`: Test double application lemma
  - Goal: Verify app2 with various formula combinations
  - Strategy: Add example declarations exercising app2
  - Complexity: Simple
  - Estimated: 0.5 hours

- [ ] `test_pairing_derivation`: Test derived pairing theorem
  - Goal: Verify pairing regression tests pass with theorem (not axiom)
  - Strategy: Run existing tests, verify no behavioral changes
  - Complexity: Simple
  - Estimated: 0.5 hours

**Testing**:
```bash
lake build LogosTest.Core.Theorems.PerpetuityTest
lake test
```

**Expected Duration**: 2 hours

---

### Phase 6: Update Documentation [NOT STARTED]
implementer: software
dependencies: [4, 5]

**Objective**: Update documentation to reflect completed derivation

**Complexity**: Low

**Tasks**:
- [ ] `doc_perpetuity_lean`: Update Perpetuity.lean docstrings
  - Goal: Update module header and pairing docstring to reference theorem
  - Strategy: Change "axiom" references to "theorem" in doc comments
  - Complexity: Simple
  - Estimated: 0.5 hours

- [ ] `doc_todo`: Update TODO.md
  - Goal: Mark Task 21 as COMPLETE
  - Strategy: Edit TODO.md completion status and add completion note
  - Complexity: Simple
  - Estimated: 0.25 hours

- [ ] `doc_implementation_status`: Update IMPLEMENTATION_STATUS.md
  - Goal: Update axiom count (reduce by 1), update theorem count
  - Strategy: Edit axiom/theorem counts in Implementation Status section
  - Complexity: Simple
  - Estimated: 0.25 hours

- [ ] `doc_claude_md`: Update CLAUDE.md Theorems Package section
  - Goal: Note pairing is now derived theorem, not axiom
  - Strategy: Update Theorems Package description in CLAUDE.md
  - Complexity: Simple
  - Estimated: 0.25 hours

**Testing**:
```bash
# Verify no axiom pairing references remain
grep -r "axiom pairing" Documentation/ CLAUDE.md | wc -l | test $(cat) -eq 0
```

**Expected Duration**: 1.25 hours

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
