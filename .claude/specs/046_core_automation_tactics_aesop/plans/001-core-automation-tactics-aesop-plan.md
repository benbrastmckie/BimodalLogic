# Core Automation Tactics and Aesop Integration - Implementation Plan

## Metadata
- **Date**: 2025-12-08
- **Feature**: Complete Task 7 Core Automation Implementation
- **Scope**: Complete Logos TM automation with 8 remaining tactics (modal_k_tactic, temporal_k_tactic, modal_4_tactic, modal_b_tactic, temp_4_tactic, temp_a_tactic, modal_search, temporal_search) and test suite expansion from 77 to 100+ tests. Current state: 4/12 tactics implemented (apply_axiom, modal_t, tm_auto, assumption_search), Aesop integration complete with no Batteries compatibility issues.
- **Status**: [COMPLETE]
- **Estimated Hours**: 30-40 hours
- **Complexity Score**: 51 (Base: 10 [extend existing], Tactics: 8×3=24, Files: 2×2=4, Complex: 2×5=10, Test: 3)
- **Structure Level**: 0
- **Estimated Phases**: 10
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Lean Mathlib Research Report](../reports/001-lean-mathlib-research.md)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Implementation Phases

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
| 3 | lean | lean-implementer |
| 4 | lean | lean-implementer |
| 5 | lean | lean-implementer |
| 6 | lean | lean-implementer |
| 7 | lean | lean-implementer |
| 8 | lean | lean-implementer |
| 9 | lean | lean-implementer |
| 10 | lean | lean-implementer |

### Phase 1: Implement Inference Rule Tactics (modal_k_tactic, temporal_k_tactic) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: []

**Objective**: Implement tactics for applying modal K and temporal K inference rules with context transformation and goal pattern matching.

**Complexity**: Medium

**Theorems**:
- [x] `modal_k_tactic`: Apply modal K rule from `Γ ⊢ φ` to `□Γ ⊢ □φ`
  - Goal: `TacticM Unit` (elab tactic, no explicit type signature)
  - Strategy: Pattern match goal `Derivable (□Γ) (□φ)`, construct subgoal `Derivable Γ φ`, apply `Derivable.modal_k` with context transformation
  - Complexity: Medium (requires context transformation and subgoal creation)
  - Implementation Pattern: Use `elab_rules` with goal destructuring, `MVarId.apply` for subgoal generation
  - Estimated: 6-8 hours

- [x] `temporal_k_tactic`: Apply temporal K rule from `Γ ⊢ φ` to `FΓ ⊢ Fφ`
  - Goal: `TacticM Unit` (elab tactic, no explicit type signature)
  - Strategy: Pattern match goal `Derivable (FΓ) (Fφ)`, construct subgoal `Derivable Γ φ`, apply `Derivable.temporal_k` with context transformation
  - Complexity: Medium (mirrors modal_k_tactic for temporal operators)
  - Implementation Pattern: Use `elab_rules` with goal destructuring, mirror modal_k_tactic structure
  - Estimated: 6-8 hours

**Testing**:
```bash
# Verify compilation
lake build Logos.Core.Automation.Tactics

# Run test suite (will add tests in Phase 9)
lake build LogosTest.Core.Automation.TacticsTest

# Check no diagnostics
grep -c "sorry" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
```

**Expected Duration**: 12-16 hours

---

### Phase 2: Implement Modal Axiom Tactics (modal_4_tactic, modal_b_tactic) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: []

**Objective**: Implement tactics for applying modal 4 and modal B axioms with formula pattern matching.

**Complexity**: Low

**Theorems**:
- [x] `modal_4_tactic`: Apply modal 4 axiom `□φ → □□φ`
  - Goal: `TacticM Unit` (elab tactic)
  - Strategy: Pattern match goal `Derivable Γ (□φ → □□φ)`, apply `Derivable.axiom` with `Axiom.modal_4 φ`, use `isDefEq` to verify inner formulas match
  - Complexity: Simple (direct axiom application with pattern matching)
  - Implementation Pattern: Use `elab_rules` following modal_t template from TACTIC_DEVELOPMENT.md
  - Estimated: 4-6 hours

- [x] `modal_b_tactic`: Apply modal B axiom `φ → □◇φ`
  - Goal: `TacticM Unit` (elab tactic)
  - Strategy: Pattern match goal `Derivable Γ (φ → □◇φ)`, apply `Derivable.axiom` with `Axiom.modal_b φ`, handle `diamond` derived operator
  - Complexity: Simple (direct axiom application with derived operator)
  - Implementation Pattern: Use `elab_rules` with formula destructuring for derived operators
  - Estimated: 4-6 hours

**Testing**:
```bash
lake build Logos.Core.Automation.Tactics
lake build LogosTest.Core.Automation.TacticsTest
grep -c "sorry" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
```

**Expected Duration**: 8-12 hours

---

### Phase 3: Implement Temporal Axiom Tactics (temp_4_tactic, temp_a_tactic) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: []

**Objective**: Implement tactics for applying temporal 4 and temporal A axioms with temporal operator pattern matching.

**Complexity**: Low

**Theorems**:
- [x] `temp_4_tactic`: Apply temporal 4 axiom `Fφ → FFφ`
  - Goal: `TacticM Unit` (elab tactic)
  - Strategy: Pattern match goal `Derivable Γ (Fφ → FFφ)`, apply `Derivable.axiom` with `Axiom.temp_4 φ`, mirror modal_4_tactic for temporal operators
  - Complexity: Simple (direct axiom application, mirrors modal_4_tactic)
  - Implementation Pattern: Use `elab_rules` with `all_future` constructor matching
  - Estimated: 4-6 hours

- [x] `temp_a_tactic`: Apply temporal A axiom `φ → F(Pφ)`
  - Goal: `TacticM Unit` (elab tactic)
  - Strategy: Pattern match goal `Derivable Γ (φ → F(Pφ))`, apply `Derivable.axiom` with `Axiom.temp_a φ`, handle `some_past` derived operator
  - Complexity: Simple (direct axiom application with derived operator)
  - Implementation Pattern: Use `elab_rules` with nested formula destructuring for `some_past`
  - Estimated: 4-6 hours

**Testing**:
```bash
lake build Logos.Core.Automation.Tactics
lake build LogosTest.Core.Automation.TacticsTest
grep -c "sorry" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
```

**Expected Duration**: 8-12 hours

---

### Phase 4: Implement Modal Proof Search (modal_search) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: [1, 2]

**Objective**: Implement bounded depth-first search for modal formulas using recursive tactic invocation.

**Complexity**: High

**Theorems**:
- [x] `modal_search`: Bounded proof search for modal formulas
  - Goal: `TacticM Unit` (elab tactic with depth parameter)
  - Strategy: Recursive TacticM implementation with depth limit, heuristic ordering (axioms → assumptions → MP → modal K), backtracking via `try...catch`
  - Complexity: Complex (requires recursive tactic invocation, goal management, backtracking)
  - Implementation Pattern: Use partial def for recursive helper, `elab` for syntax entry point, `evalTactic` for sub-tactic invocation
  - Dependencies: Requires `modal_t`, `modal_4_tactic`, `modal_b_tactic`, `modal_k_tactic`, `assumption_search`
  - Estimated: 8-12 hours

**Testing**:
```bash
lake build Logos.Core.Automation.Tactics
lake build LogosTest.Core.Automation.TacticsTest

# Verify ProofSearch.lean helpers are used
grep -n "bounded_search\|heuristic_score" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
```

**Expected Duration**: 8-12 hours

---

### Phase 5: Implement Temporal Proof Search (temporal_search) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: [1, 3]

**Objective**: Implement bounded depth-first search for temporal formulas using recursive tactic invocation.

**Complexity**: High

**Theorems**:
- [x] `temporal_search`: Bounded proof search for temporal formulas
  - Goal: `TacticM Unit` (elab tactic with depth parameter)
  - Strategy: Recursive TacticM implementation with depth limit, heuristic ordering (axioms → assumptions → MP → temporal K), mirror modal_search for temporal operators
  - Complexity: Complex (requires recursive tactic invocation, goal management, backtracking)
  - Implementation Pattern: Use partial def for recursive helper, `elab` for syntax entry point, `evalTactic` for sub-tactic invocation
  - Dependencies: Requires `temp_4_tactic`, `temp_a_tactic`, `temporal_k_tactic`, `assumption_search`
  - Estimated: 8-12 hours

**Testing**:
```bash
lake build Logos.Core.Automation.Tactics
lake build LogosTest.Core.Automation.TacticsTest

# Verify all 12 tactics implemented
grep -c "elab\|macro" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
# Expected: 12
```

**Expected Duration**: 8-12 hours

---

### Phase 6: Add Tests for modal_k_tactic and temporal_k_tactic [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
dependencies: [1]

**Objective**: Add 6-10 tests for inference rule tactics (modal_k_tactic, temporal_k_tactic) with positive and negative cases.

**Complexity**: Low

**Theorems**:
- [x] Test 78: Basic modal K application `Derivable [] p → Derivable [] (□p)`
  - Goal: Test passes with `modal_k_tactic`
  - Strategy: Apply modal_k_tactic to goal with simple formula
  - Complexity: Simple (direct test)
  - Estimated: 0.5 hours

- [x] Test 79: Modal K with compound formula `Derivable [] (p → q) → Derivable [] (□(p → q))`
  - Goal: Test passes with `modal_k_tactic`
  - Strategy: Apply modal_k_tactic to goal with implication
  - Complexity: Simple
  - Estimated: 0.5 hours

- [x] Test 80: Modal K negative test (non-box goal should fail)
  - Goal: Test uses `fail_if_success modal_k_tactic`
  - Strategy: Attempt modal_k_tactic on goal not matching `□Γ ⊢ □φ`
  - Complexity: Simple
  - Estimated: 0.5 hours

- [x] Test 81: Basic temporal K application `Derivable [] p → Derivable [] (Fp)`
  - Goal: Test passes with `temporal_k_tactic`
  - Strategy: Apply temporal_k_tactic to goal with simple formula
  - Complexity: Simple
  - Estimated: 0.5 hours

- [x] Test 82: Temporal K with compound formula
  - Goal: Test passes with `temporal_k_tactic`
  - Strategy: Apply temporal_k_tactic to goal with implication
  - Complexity: Simple
  - Estimated: 0.5 hours

- [x] Test 83: Temporal K negative test (non-future goal should fail)
  - Goal: Test uses `fail_if_success temporal_k_tactic`
  - Strategy: Attempt temporal_k_tactic on goal not matching `FΓ ⊢ Fφ`
  - Complexity: Simple
  - Estimated: 0.5 hours

**Testing**:
```bash
lake build LogosTest.Core.Automation.TacticsTest
grep -c "Test 7[8-9]\|Test 8[0-3]" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
# Expected: 6
```

**Expected Duration**: 3 hours

---

### Phase 7: Add Tests for Axiom Tactics [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
dependencies: [2, 3]

**Objective**: Add 12 tests for axiom tactics (modal_4_tactic, modal_b_tactic, temp_4_tactic, temp_a_tactic) with pattern matching validation.

**Complexity**: Low

**Theorems**:
- [x] Test 84-86: modal_4_tactic tests (basic, compound, negative)
  - Goal: Test passes with `modal_4_tactic`
  - Strategy: Apply modal_4_tactic to `□φ → □□φ` goals
  - Complexity: Simple
  - Estimated: 1.5 hours

- [x] Test 87-89: modal_b_tactic tests (basic, compound, negative)
  - Goal: Test passes with `modal_b_tactic`
  - Strategy: Apply modal_b_tactic to `φ → □◇φ` goals
  - Complexity: Simple
  - Estimated: 1.5 hours

- [x] Test 90-92: temp_4_tactic tests (basic, compound, negative)
  - Goal: Test passes with `temp_4_tactic`
  - Strategy: Apply temp_4_tactic to `Fφ → FFφ` goals
  - Complexity: Simple
  - Estimated: 1.5 hours

- [x] Test 93-95: temp_a_tactic tests (basic, compound, negative)
  - Goal: Test passes with `temp_a_tactic`
  - Strategy: Apply temp_a_tactic to `φ → F(Pφ)` goals
  - Complexity: Simple
  - Estimated: 1.5 hours

**Testing**:
```bash
lake build LogosTest.Core.Automation.TacticsTest
grep -c "Test 8[4-9]\|Test 9[0-5]" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
# Expected: 12
```

**Expected Duration**: 6 hours

---

### Phase 8: Add Tests for Proof Search Tactics [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
dependencies: [4, 5]

**Objective**: Add 10-15 tests for proof search tactics (modal_search, temporal_search) with depth variations and complex formulas.

**Complexity**: Medium

**Theorems**:
- [x] Test 96-100: modal_search tests (depth 1-3, depth limit, complex nested)
  - Goal: Test passes with `modal_search`
  - Strategy: Apply modal_search with varying depth limits to modal formulas
  - Complexity: Medium (requires understanding of search depth)
  - Estimated: 2.5 hours

- [x] Test 101-105: temporal_search tests (depth 1-3, depth limit, complex nested)
  - Goal: Test passes with `temporal_search`
  - Strategy: Apply temporal_search with varying depth limits to temporal formulas
  - Complexity: Medium
  - Estimated: 2.5 hours

**Testing**:
```bash
lake build LogosTest.Core.Automation.TacticsTest
grep -c "Test 9[6-9]\|Test 10[0-5]" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
# Expected: 10
```

**Expected Duration**: 5 hours

---

### Phase 9: Add Integration Tests and Complex Bimodal Tests [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
dependencies: [1, 2, 3, 4, 5]

**Objective**: Add 5-10 integration tests combining multiple tactics for complex TM proofs (perpetuity principles, bimodal interactions).

**Complexity**: Medium

**Theorems**:
- [x] Test 106: Bimodal proof `□Fp → F□p` using multiple tactics
  - Goal: Test passes with tactic combination
  - Strategy: Use modal_k_tactic, temporal_k_tactic, and axiom tactics in sequence
  - Complexity: Medium (multi-step proof)
  - Estimated: 1 hour

- [x] Test 107: Perpetuity principle derivation using automation
  - Goal: Test passes with tm_auto or proof search
  - Strategy: Attempt to derive P1 or P2 using automation
  - Complexity: Medium (requires multiple steps)
  - Estimated: 1 hour

- [x] Test 108-110: Long derivation chains (5+ steps) with mixed modal/temporal
  - Goal: Test passes with tactic combination or proof search
  - Strategy: Build multi-step proofs using axioms and inference rules
  - Complexity: Medium (complex proof structure)
  - Estimated: 3 hours

**Testing**:
```bash
lake build LogosTest.Core.Automation.TacticsTest
wc -l /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
# Expected: 600+ lines (currently 469, target 100+ tests)

grep -c "example\|theorem" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
# Expected: 105+ (currently 77)
```

**Expected Duration**: 5 hours

---

### Phase 10: Final Integration and Documentation Update [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: [1, 2, 3, 4, 5, 6, 7, 8, 9]

**Objective**: Final build verification, documentation updates, and TODO.md task completion marking.

**Complexity**: Low

**Theorems**:
- [x] Verify all 12 tactics implemented with zero sorry markers
  - Goal: `lake build` succeeds with zero errors
  - Strategy: Run full project build, verify all tactics compile
  - Complexity: Simple (verification only)
  - Estimated: 1 hour

- [x] Verify 100+ tests pass with comprehensive coverage
  - Goal: `lake test` succeeds with 100+ tests passing
  - Strategy: Run test suite, verify coverage of all tactics
  - Complexity: Simple (verification only)
  - Estimated: 0.5 hours

- [x] Update TACTIC_DEVELOPMENT.md with implementation notes
  - Goal: Documentation reflects all implemented tactics
  - Strategy: Add examples and usage notes for new tactics
  - Complexity: Simple (documentation only)
  - Estimated: 1 hour

- [x] Update TODO.md to mark Task 7 as COMPLETE
  - Goal: TODO.md reflects completion of Task 7
  - Strategy: Remove Task 7 from Medium Priority section, note completion in git history
  - Complexity: Simple (task tracking)
  - Estimated: 0.5 hours

**Testing**:
```bash
# Full project build
lake build

# Full test suite
lake test

# Verify tactic count
grep -c "elab\|macro" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
# Expected: 12

# Verify test count
grep -c "example\|theorem" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean
# Expected: 105+

# Verify no sorry markers in Tactics.lean
grep -c "sorry" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
# Expected: 0
```

**Expected Duration**: 3 hours

---

## Success Criteria

- [ ] All 12 tactics implemented (apply_axiom, modal_t, tm_auto, assumption_search, modal_k_tactic, temporal_k_tactic, modal_4_tactic, modal_b_tactic, temp_4_tactic, temp_a_tactic, modal_search, temporal_search)
- [ ] Zero sorry markers in Tactics.lean
- [ ] Test suite expanded from 77 to 100+ tests
- [ ] All tests pass with `lake test`
- [ ] Full project builds with `lake build` (zero errors)
- [ ] Documentation updated (TACTIC_DEVELOPMENT.md)
- [ ] TODO.md Task 7 marked COMPLETE

## Dependencies

- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean Toolchain**: leanprover/lean4 (version from lean-toolchain file)
- **External Dependencies**: Aesop (already integrated via AesopRules.lean)
- **Internal Dependencies**: ProofSystem (Axiom, Derivable), Syntax (Formula, Context)

## Risk Mitigation

**Risk 1: Aesop Batteries Compatibility** (MITIGATED)
- **Finding**: Research report confirms no Batteries dependency in Truth.lean or AesopRules.lean
- **Evidence**: AesopRules.lean already complete with forward chaining rules, zero Batteries imports
- **Action**: Verify with `lake build` (expect clean build)

**Risk 2: Proof Search Complexity** (MODERATE)
- **Finding**: ProofSearch.lean infrastructure incomplete (returns Bool, not proof terms)
- **Mitigation**: Use TacticM with `try...catch` for backtracking, delegate to existing tactics
- **Action**: Implement modal_search and temporal_search using recursive TacticM, not ProofSearch helpers

**Risk 3: Type Inference Failures** (LOW)
- **Finding**: Existing tactics use `mkAppM` (automatic inference) successfully
- **Mitigation**: Follow existing patterns, use explicit type annotations if needed
- **Action**: Use `isDefEq` for formula matching, mirror modal_t implementation

## Notes

- **Current State**: 4/12 tactics implemented (33% complete), 77 tests exist
- **Remaining Effort**: 30-40 hours for 8 tactics and test expansion
- **Aesop Integration**: Already complete (no blocker exists despite TODO.md claim)
- **Wave Structure**: Phases 1-3 can run in parallel (independent axiom/rule tactics), Phases 4-5 depend on Phases 1-3, Phases 6-9 are test-only (can run after corresponding implementation phases)
- **TDD Approach**: Each implementation phase (1-5) followed by corresponding test phase (6-9) for iterative validation
