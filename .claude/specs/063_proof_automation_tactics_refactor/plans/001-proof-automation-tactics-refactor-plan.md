# Lean Implementation Plan: Proof Automation Tactics Refactor

## Metadata
- **Date**: 2025-12-09
- **Feature**: Systematic codebase improvement for Logos Lean 4 project
- **Scope**: Derive axioms as theorems, eliminate sorry placeholders, consolidate tactics, refactor large modules, standardize naming/documentation
- **Status**: [NOT STARTED]
- **Estimated Hours**: 34-48 hours
- **Complexity Score**: 4 (High - multiple subsystems, proof derivations, tactic consolidation)
- **Structure Level**: 0
- **Estimated Phases**: 8
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [001-mathlib-theorems.md](../reports/001-mathlib-theorems.md): 5 axioms can be derived, 11 sorry placeholders need proofs
  - [002-proof-strategies.md](../reports/002-proof-strategies.md): 50+ axiom boilerplate patterns, 150+ modus ponens chains, tactic duplication
  - [003-project-structure.md](../reports/003-project-structure.md): Perpetuity.lean (1,889 lines) should split into 3 modules
  - [004-style-guide.md](../reports/004-style-guide.md): 7 camelCase functions need snake_case rename, 4 files lack module docstrings
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Executive Summary

This plan addresses systematic improvements to the Logos Lean 4 project across four priority tiers:

1. **HIGHEST Priority**: Proof automation tactics consolidation (Phase 5)
2. **HIGH Priority**: Axiom derivation (Phases 1-2, 4) and sorry elimination (Phase 3)
3. **MEDIUM Priority**: Module refactoring (Phase 6) and proof pattern standardization (Phase 7)
4. **LOWER Priority**: Naming conventions and documentation (Phase 8)

**Key Dependencies**:
- Phase 1 (dni) enables Phase 2 (always_dni, always_dne)
- Phase 3 (DeductionTheorem) enables Phase 4 (future_k_dist, always_mono)
- Phases 5-8 are relatively independent and can proceed in parallel after Phases 1-4

## Success Criteria

### Module Completion
- [ ] All 5 axioms (dni, always_dni, always_dne, future_k_dist, always_mono) proven as theorems
- [ ] All 11 sorry cases resolved (3 in DeductionTheorem, rest implicit)
- [ ] Tactic code reduced by 60-80 lines (70% reduction in duplication)
- [ ] Perpetuity.lean split into 3 modules (~768 core lines)
- [ ] 7 camelCase functions renamed to snake_case (100% compliance)
- [ ] 4 missing module docstrings added (100% coverage)

### Quality Standards
- [ ] Zero `#lint` warnings in modified modules
- [ ] Build time <3 minutes total
- [ ] All new theorems have docstrings with mathematical statements
- [ ] Zero test failures after each phase (`lake test`)
- [ ] Zero build errors (`lake build` succeeds after each phase)

### Documentation
- [ ] IMPLEMENTATION_STATUS.md updated with axiom count (13 → 8)
- [ ] SORRY_REGISTRY.md updated (11 entries resolved)
- [ ] TACTIC_DEVELOPMENT.md updated with factory patterns
- [ ] TODO.md updated with completed tasks

---

## Implementation Phases

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
| 3 | lean | lean-implementer |
| 4 | lean | lean-implementer |
| 5 | lean | lean-implementer |
| 6 | software | implementer-coordinator |
| 7 | lean | lean-implementer |
| 8 | software | implementer-coordinator |

---

### Phase 1: Derive dni Axiom [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
dependencies: []

**Effort**: 2-3 hours

**Objective**: Replace `axiom dni` with theorem using propositional reasoning

**Background**:
The `dni` (Double Negation Introduction) axiom `⊢ A → ¬¬A` can be derived from the existing propositional axioms using the S combinator and reductio pattern.

**Theorems**:

- [ ] `dni`: Double Negation Introduction
  - Goal: `(A : Formula) → ⊢ A.imp A.neg.neg`
  - Strategy:
    1. Apply `prop_s A (A.neg)` to get `⊢ A → (¬A → A)`
    2. Derive `(¬A → A) → ((¬A → ¬A) → ¬¬A)` via reductio
    3. Use `identity (A.neg)` for `⊢ ¬A → ¬A`
    4. Apply modus ponens chain to conclude `⊢ A → ¬¬A`
  - Complexity: Medium
  - Dependencies: `prop_s`, `identity`, `Derivable.modus_ponens`
  - Reference: Report 001 Section 1.1, lines 21-45

**Tasks**:
- [ ] Remove axiom declaration (line 523): Delete `axiom dni (A : Formula) : ⊢ A.imp A.neg.neg`
- [ ] Prove `dni` theorem using S axiom + reductio pattern
- [ ] Verify dni usage: Check all references in codebase for type compatibility
- [ ] Run `lake test` to verify no breakage

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
lake test
```

**Expected Duration**: 2-3 hours

---

### Phase 2: Derive always_dni and always_dne Axioms [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
dependencies: [1]

**Effort**: 3-4 hours

**Objective**: Replace temporal double negation axioms with theorems

**Background**:
These temporal axioms extend dni/dne to the `always` operator by applying double negation to each temporal component (past, present, future).

**Theorems**:

- [ ] `always_dni`: Always Double Negation Introduction
  - Goal: `(φ : Formula) → ⊢ φ.always.imp φ.neg.neg.always`
  - Strategy:
    1. Decompose `always φ` into `H φ ∧ φ ∧ G φ`
    2. Apply `dni` to each component
    3. Recombine using temporal composition
  - Complexity: Medium
  - Dependencies: `dni` (Phase 1), temporal composition lemmas
  - Reference: Report 001 Section 1.3, lines 90-128

- [ ] `always_dne`: Always Double Negation Elimination
  - Goal: `(φ : Formula) → ⊢ φ.neg.neg.always.imp φ.always`
  - Strategy:
    1. Decompose `always(¬¬φ)` into `H(¬¬φ) ∧ ¬¬φ ∧ G(¬¬φ)`
    2. Apply `double_negation` axiom to each component
    3. Recombine into `always φ`
  - Complexity: Medium
  - Dependencies: `Axiom.double_negation`, temporal composition lemmas
  - Reference: Report 001 Section 1.4, lines 130-165

**Tasks**:
- [ ] Derive `always_dni` theorem (line 1504)
- [ ] Remove `always_dni` axiom declaration
- [ ] Derive `always_dne` theorem (line 1570)
- [ ] Remove `always_dne` axiom declaration
- [ ] Update SORRY_REGISTRY.md: Mark dni, always_dni, always_dne as derived
- [ ] Run `lake test` to verify correctness

**Testing**:
```bash
lake build
grep -c "axiom" Logos/Core/Theorems/Perpetuity.lean
lake test
```

**Expected Duration**: 3-4 hours

---

### Phase 3: Complete DeductionTheorem.lean Sorry Placeholders [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean
dependencies: []

**Effort**: 8-12 hours

**Objective**: Resolve 3 sorry cases in deduction theorem using well-founded recursion

**Background**:
The deduction theorem has three incomplete cases that require well-founded recursion on derivation tree size.

**Theorems**:

- [ ] `Derivable.size`: Termination metric
  - Goal: `Derivable Γ φ → Nat`
  - Strategy: Define size as derivation tree depth
  - Complexity: Medium
  - Reference: Report 001 Section 2.1, lines 273-291

- [ ] `deduction_theorem` modal_k case (lines 164-370)
  - Goal: Handle boxed context transformation
  - Strategy:
    1. Prove helper: `(A' :: Γ'') ⊢ φ → (map box Γ'') ⊢ (box A').imp (box φ)`
    2. Apply well-founded recursion on sub-derivation
    3. Convert boxed result to main goal
  - Complexity: Complex
  - Dependencies: `Derivable.size`, auxiliary boxed deduction theorem
  - Reference: Report 001 Section 2.1, lines 241-291

- [ ] `deduction_theorem` temporal_k case (lines 371-383)
  - Goal: Handle future-mapped context
  - Strategy: Identical to modal_k but with `all_future` operator
  - Complexity: Complex
  - Dependencies: `Derivable.size`, temporal analog of boxed deduction
  - Reference: Report 001 Section 2.2, lines 296-326

- [ ] `deduction_theorem` weakening case (lines 388-438)
  - Goal: Handle A ∈ Γ' scenario
  - Strategy:
    1. Prove `derivable_permutation`: context order doesn't affect derivability
    2. Reorder Γ' to put A at head when A ∈ Γ'
    3. Apply deduction theorem to reordered derivation
  - Complexity: Medium
  - Dependencies: Exchange lemma
  - Reference: Report 001 Section 2.3, lines 328-378

**Tasks**:
- [ ] Implement well-founded recursion framework with `Derivable.size` metric
- [ ] Resolve modal_k case with auxiliary boxed deduction theorem
- [ ] Resolve temporal_k case with temporal analog
- [ ] Resolve weakening case with exchange lemma
- [ ] Verify deduction theorem completeness: Test all derivation cases
- [ ] Update SORRY_REGISTRY.md: Mark 3 sorry cases as resolved

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Metalogic/DeductionTheorem.lean
# Expected: 0
lake test
```

**Expected Duration**: 8-12 hours

---

### Phase 4: Derive future_k_dist and always_mono Axioms [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
dependencies: [3]

**Effort**: 4-6 hours

**Objective**: Replace temporal K distribution axioms with theorems

**Background**:
These axioms can be derived using the temporal_k rule and the complete deduction theorem.

**Theorems**:

- [ ] `future_k_dist`: Temporal K Distribution
  - Goal: `(A B : Formula) → ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future)`
  - Strategy:
    1. From `[A → B, A] ⊢ B` (by modus ponens)
    2. Apply temporal_k: `[F(A → B), FA] ⊢ FB`
    3. Apply deduction theorem twice to lift context
    4. Get `⊢ F(A → B) → (FA → FB)`
  - Complexity: Medium
  - Dependencies: `deduction_theorem` (Phase 3), `Derivable.temporal_k`
  - Reference: Report 001 Section 1.2, lines 47-86

- [ ] `always_mono`: Always Monotonicity
  - Goal: `{A B : Formula} → (h : ⊢ A.imp B) → ⊢ A.always.imp B.always`
  - Strategy:
    1. Decompose `always` into `past ∧ present ∧ future`
    2. Apply past_k_dist and future_k_dist
    3. Use transitivity to chain implications
    4. Recombine into `always A → always B`
  - Complexity: Complex
  - Dependencies: `future_k_dist`, `past_k_dist` (if exists), temporal composition
  - Reference: Report 001 Section 1.5, lines 167-224

**Tasks**:
- [ ] Derive `future_k_dist` theorem (lines 1233-1234)
- [ ] Remove `future_k_dist` axiom declaration
- [ ] Derive `always_mono` theorem (line 1670)
- [ ] Remove `always_mono` axiom declaration
- [ ] Verify temporal reasoning: Run temporal logic tests
- [ ] Update IMPLEMENTATION_STATUS.md: Update axiom count (13 → 8)

**Testing**:
```bash
lake build
grep -c "axiom" Logos/Core/Theorems/Perpetuity.lean
lake test
```

**Expected Duration**: 4-6 hours

---

### Phase 5: Consolidate Tactic Implementations [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: []

**Effort**: 6-8 hours

**Objective**: Reduce tactic code duplication through parameterization

**Background**:
Research found significant code duplication across tactic implementations. Parameterized factories can consolidate repeated patterns.

**Theorems**:

- [ ] `make_operator_k`: Operator K Tactic Factory
  - Goal: Unify `modal_k_tactic` and `temporal_k_tactic` into single parameterized implementation
  - Strategy:
    1. Define `make_operator_k (name : String) (op_const : Name) : TacticM Unit`
    2. Parameterize operator matching (`Formula.box` vs `Formula.all_future`)
    3. Replace modal_k_tactic (lines 216-241) with factory instance
    4. Replace temporal_k_tactic (lines 260-285) with factory instance
  - Complexity: Medium
  - Estimated reduction: ~25 lines
  - Reference: Report 002 Section 3.1, lines 206-242

- [ ] `make_axiom_tactic`: Axiom Iteration Factory
  - Goal: Consolidate modal_4, modal_b, temp_4 tactics
  - Strategy:
    1. Define `make_axiom_tactic (axiom_name : String) (axiom_fn : Formula → Axiom) (pattern_check : Formula → Formula → Bool)`
    2. Replace modal_4_tactic (lines 306-339)
    3. Replace modal_b_tactic (lines 354-385)
    4. Replace temp_4_tactic (lines 406-439)
  - Complexity: Medium
  - Estimated reduction: ~77 lines (97 → 20)
  - Reference: Report 002 Section 4.1 Priority 3, lines 387-423

- [ ] `apply_axiom` enhancement
  - Goal: Replace basic macro with intelligent axiom detection
  - Strategy:
    1. Match goal against all 13 axiom patterns
    2. Try each axiom via unification
    3. Provide diagnostic error messages
    4. Merge modal_t functionality into unified apply_axiom
  - Complexity: Medium
  - Reference: Report 002 Section 4.1 Priority 1, lines 311-351

**Tasks**:
- [ ] Extract operator K tactic factory (unify modal_k/temporal_k)
- [ ] Extract axiom iteration factory (unify modal_4/modal_b/temp_4)
- [ ] Enhance apply_axiom tactic with pattern matching and diagnostics
- [ ] Verify tactic backward compatibility: Run TacticsTest.lean suite (110+ tests)
- [ ] Update TACTIC_DEVELOPMENT.md: Document new factory patterns

**Testing**:
```bash
lake build
lake test
# Verify all 110+ TacticsTest.lean tests pass
```

**Expected Duration**: 6-8 hours

---

### Phase 6: Refactor Perpetuity.lean into Modules [NOT STARTED]
implementer: software
dependencies: [1, 2]

**Effort**: 4-6 hours

**Objective**: Split 1,889-line monolith into 3 focused modules

**Background**:
Perpetuity.lean has grown too large. Splitting into Helpers, Principles, and Bridge modules improves maintainability.

**Target Files**:
- `Logos/Core/Theorems/Perpetuity.lean` (refactored parent)
- `Logos/Core/Theorems/Perpetuity/Helpers.lean` (new, ~388 lines)
- `Logos/Core/Theorems/Perpetuity/Principles.lean` (new, ~180 lines)
- `Logos/Core/Theorems/Perpetuity/Bridge.lean` (new, ~200 lines)

**Tasks**:

- [ ] Create Helpers.lean module (lines 65-558)
  - Content: imp_trans, mp, identity, b_combinator, theorem_flip, theorem_app1, theorem_app2, pairing, combine_imp_conj, dne, box_dne, temporal decomposition lemmas
  - Imports: Derivation, Formula
  - Reference: Report 003 Section 2.1, lines 206-248

- [ ] Create Principles.lean module (lines 604-1415)
  - Content: P1-P5 perpetuity principles + supporting lemmas
  - Imports: Helpers module
  - Reference: Report 003 Section 2.1, lines 250-289

- [ ] Create Bridge.lean module (lines 1416-1782)
  - Content: Modal/temporal duality, monotonicity, P6
  - Imports: Helpers, Principles
  - Reference: Report 003 Section 2.1, lines 291-325

- [ ] Refactor parent Perpetuity.lean as aggregator with re-exports
  - Keep module-level documentation (lines 1-58)
  - Import all 3 submodules
  - Open namespaces to re-export definitions
  - Reference: Report 003 Section 2.1, lines 327-341

- [ ] Update external imports in dependent files
  - Propositional.lean: Import Helpers
  - ModalS4.lean: Import Bridge
  - ModalS5.lean: Import Bridge
  - DeductionTheorem.lean: Import Helpers
  - Reference: Report 003 Section 1.3, lines 130-152

- [ ] Run build verification: `lake build`
- [ ] Update documentation: CLAUDE.md project structure, IMPLEMENTATION_STATUS.md

**Testing**:
```bash
lake build
lake test
```

**Expected Duration**: 4-6 hours

---

### Phase 7: Standardize Proof Patterns with Helper Lemmas [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity/Helpers.lean
dependencies: [6]

**Effort**: 4-5 hours

**Objective**: Reduce boilerplate in theorem proofs via abstraction

**Background**:
Research found 50+ axiom boilerplate patterns and 150+ modus ponens chains that can be abstracted.

**Theorems**:

- [ ] `axiom_in_context`: Eliminate weakening boilerplate
  - Goal: `(Γ : Context) → (φ : Formula) → (h : Axiom φ) → Γ ⊢ φ`
  - Strategy: Wrapper around `Derivable.weakening [] Γ φ (Derivable.axiom [] φ h) (by intro; simp)`
  - Complexity: Simple
  - Reference: Report 002 Section 3.1 Abstraction B, lines 224-242

- [ ] `apply_axiom_to`: Combine axiom + modus ponens
  - Goal: `{A B : Formula} → (axiom_proof : Axiom (A.imp B)) → (h : ⊢ A) → ⊢ B`
  - Strategy: `Derivable.modus_ponens [] A B (Derivable.axiom [] (A.imp B) axiom_proof) h`
  - Complexity: Simple
  - Reference: Report 002 Section 3.1 Abstraction A, lines 206-222

- [ ] `apply_axiom_in_context`: Context-aware axiom application
  - Goal: `(Γ : Context) → {A B : Formula} → (axiom_proof : Axiom (A.imp B)) → (h : Γ ⊢ A) → Γ ⊢ B`
  - Strategy: Combine axiom_in_context + modus_ponens
  - Complexity: Simple
  - Reference: Report 002 Section 3.1 Abstraction B, lines 233-242

**Tasks**:
- [ ] Create `axiom_in_context` helper lemma
- [ ] Create `apply_axiom_to` helper definition
- [ ] Create `apply_axiom_in_context` helper definition
- [ ] Refactor Propositional.lean: Apply helpers to 30+ patterns
- [ ] Refactor ModalS5.lean: Apply helpers to modal theorems
- [ ] Verify proof equivalence: Run theorem tests
- [ ] Estimate code reduction: Calculate lines saved

**Testing**:
```bash
lake build
lake test
wc -l Logos/Core/Theorems/Propositional.lean
# Compare before/after line counts
```

**Expected Duration**: 4-5 hours

---

### Phase 8: Standardize Naming and Documentation [NOT STARTED]
implementer: software
dependencies: []

**Effort**: 3-4 hours

**Objective**: Fix camelCase violations and complete documentation coverage

**Target Files**:
- `Logos/Core/Semantics/TaskModel.lean` (rename 3 functions)
- `Logos/Core/Semantics/WorldHistory.lean` (rename 1 function)
- `Logos/Core/Semantics/TaskFrame.lean` (rename 3 functions)
- `Logos.lean` (add docstring)
- `Logos/Core.lean` (add docstring)
- `Logos/Core/Core.lean` (add docstring)

**Tasks**:

- [ ] Rename camelCase functions in TaskModel.lean (3 violations)
  - `allFalse → all_false`
  - `allTrue → all_true`
  - `fromList → from_list`
  - Create deprecation aliases for backward compatibility
  - Reference: Report 004 Section 1.1, lines 23-46

- [ ] Rename camelCase functions in WorldHistory.lean (1 violation)
  - `stateAt → state_at`
  - Reference: Report 004 Section 1.1, lines 48-53

- [ ] Rename camelCase functions in TaskFrame.lean (3 violations)
  - `trivialFrame → trivial_frame`
  - `identityFrame → identity_frame`
  - `natFrame → nat_frame`
  - Reference: Report 004 Section 1.1, lines 55-73

- [ ] Add module docstring to Logos.lean
  - Content: Library overview, getting started, module listing
  - Reference: Report 004 Section 5.2 Priority 2, lines 462-479

- [ ] Add module docstring to Logos/Core.lean
  - Content: Core layer scope and submodule composition
  - Reference: Report 004 Section 2.3, lines 200-212

- [ ] Add module docstring to Logos/Core/Core.lean
  - Content: Core subpackage composition and relationships
  - Reference: Report 004 Section 2.3, lines 200-212

- [ ] Run lint checks: `lake lint` for naming/doc warnings
- [ ] Update CHANGELOG.md: Document breaking changes (camelCase renames)

**Testing**:
```bash
lake build
lake lint
lake test
```

**Expected Duration**: 3-4 hours

---

## Risk Assessment

### Low Risk
- **Phase 1 (dni)**: Well-understood propositional derivation
- **Phase 8 (Naming/Docs)**: Mechanical refactoring with deprecation aliases

### Medium Risk
- **Phase 2 (always_dni/dne)**: Requires temporal composition; builds on Phase 1
- **Phase 4 (future_k_dist/always_mono)**: Depends on complete deduction theorem
- **Phase 5 (Tactic Consolidation)**: Requires careful backward compatibility testing
- **Phase 6 (Perpetuity Refactor)**: Module splitting must maintain import compatibility
- **Phase 7 (Helper Lemmas)**: Many files to update; risk of incomplete refactoring

### Higher Risk
- **Phase 3 (DeductionTheorem)**: Most complex; well-founded recursion on derivations

### Mitigation
- Phase 3 can proceed independently; if blocked, other phases continue
- Phase 6 uses parent re-export pattern for backward compatibility
- Phase 8 uses deprecation aliases to avoid breaking changes
- All phases include build/test verification before completion

---

## Rollback Plan

If any phase encounters blocking issues:

1. **Phase 1-2 (Axiom Derivations)**: Revert to axiom declarations, document blockers in SORRY_REGISTRY.md
2. **Phase 3 (DeductionTheorem)**: Keep sorry placeholders, document well-founded recursion as future work
3. **Phase 4 (Temporal Axioms)**: Revert to axiom declarations, note dependency on Phase 3
4. **Phase 5 (Tactic Consolidation)**: Keep original tactic implementations, document consolidation as future work
5. **Phase 6 (Perpetuity Refactoring)**: Revert to monolithic file, add module split to TODO.md
6. **Phase 7 (Helper Lemmas)**: Keep manual proof patterns, document helpers as optimization opportunity
7. **Phase 8 (Naming/Docs)**: Defer to next version, deprecation aliases maintain compatibility

**Git Strategy**: Create feature branch for each phase, merge to main only after tests pass.

---

## Documentation Updates Required

After completion:

- [ ] **IMPLEMENTATION_STATUS.md**: Update axiom count (13 → 8), module listing, line counts
- [ ] **SORRY_REGISTRY.md**: Remove 11 resolved sorry entries
- [ ] **TACTIC_DEVELOPMENT.md**: Document new factory patterns (make_operator_k, make_axiom_tactic)
- [ ] **CLAUDE.md**: Update "Project Structure" section with new module layout
- [ ] **TODO.md**: Remove completed tasks, add any deferred work
- [ ] **CHANGELOG.md**: Add v0.3.0 section with breaking changes (camelCase renames)

---

## Appendix A: Testing Strategy

1. **After Phase 1-2**: Run LogosTest/Theorems/Perpetuity tests for dni, always_dni, always_dne
2. **After Phase 3**: Run LogosTest/Metalogic/DeductionTheorem tests for all derivation cases
3. **After Phase 4**: Run LogosTest/Theorems/Perpetuity tests for temporal reasoning
4. **After Phase 5**: Run LogosTest/Automation/TacticsTest suite (110+ tests)
5. **After Phase 6**: Run full `lake build` to verify modularization
6. **After Phase 7**: Run LogosTest/Theorems/ suite to verify proof equivalence
7. **After Phase 8**: Run `lake lint` for naming/documentation compliance

**Continuous Integration**: Run `lake test` after each task completion to catch regressions early.

---

## Appendix B: Notes

- **Prioritization Rationale**: User specified proof automation (HIGHEST), axiom derivation (HIGH), sorry elimination (HIGH) take precedence over refactoring (MEDIUM) and naming/docs (LOWER)
- **Theorem Granularity**: Each axiom derivation is a separate task with explicit proof strategy
- **Dependency Management**: Phases 1-4 must complete sequentially; Phases 5-8 can proceed in parallel after Phase 4
- **Backward Compatibility**: Phase 6 (Perpetuity split) maintains compatibility via parent re-export; Phase 8 (naming) uses deprecation aliases

---

**Plan Created**: 2025-12-09
**Plan Version**: 2.0 (Revised to lean-plan format)
