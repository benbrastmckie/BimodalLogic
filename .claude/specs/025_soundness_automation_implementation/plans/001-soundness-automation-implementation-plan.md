# Soundness and Automation Implementation Plan

## Metadata
- **Date**: 2025-12-03 (Revised: 2025-12-03)
- **Feature**: Complete soundness proofs and implement core automation tactics for TM bimodal logic
- **Status**: [COMPLETE]
- **Estimated Hours**: 70-105 hours
- **Complexity Score**: 180
- **Structure Level**: 0
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/Soundness.lean
- **Research Reports**:
  - [Soundness Automation Research](../reports/001-soundness-automation-implementation-research.md)

## Overview

This implementation plan covers four high/medium-priority tasks from Logos TODO.md:

1. **Task 5**: Fix Modal K and Temporal K Rule Implementations (CRITICAL - code-paper alignment)
2. **Task 5b**: Complete Temporal Duality Soundness
3. **Task 7**: Implement Core Automation - 4 tactics (apply_axiom, modal_t, tm_auto, assumption_search)
4. **Task 12**: Create Comprehensive Tactic Test Suite (concurrent with Task 7)

### Critical Issue Discovered

**The Modal K and Temporal K rules are implemented in the WRONG DIRECTION from the paper!**

- **Paper MK** (line 1030): If `Γ ⊢ φ`, then `□Γ ⊢ □φ`
- **Paper TK** (line 1037): If `Γ ⊢ φ`, then `FΓ ⊢ Fφ`
- **Current Code**: Rules are reversed - this must be fixed BEFORE proving soundness

## Research Summary

Key findings from research report:
- Modal K and Temporal K rules in Derivation.lean (lines 90-102) do not match paper definitions
- Current implementation: `□Γ ⊢ φ → Γ ⊢ □φ` (wrong direction)
- Paper definition: `Γ ⊢ φ → □Γ ⊢ □φ` (correct direction)
- After fixing rules, soundness proofs become straightforward with no restrictions
- Temporal duality requires symmetric frame assumption (documented limitation)
- Automation tactics are currently stubs only - full implementation required

## Success Criteria
- [ ] Modal K rule in Derivation.lean matches paper definition (line 1030)
- [ ] Temporal K rule in Derivation.lean matches paper definition (line 1037)
- [ ] All soundness proofs compile with zero `sorry` in rule cases
- [ ] Temporal duality soundness documented with symmetric frame restriction
- [ ] 4 core tactics implemented: apply_axiom, modal_t, tm_auto, assumption_search
- [ ] TMLogic Aesop rule set declared with axiom/perpetuity rules
- [ ] Comprehensive test suite with ≥50 tests for automation package
- [ ] All tests pass with `lake test`
- [ ] Documentation updated (IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md)
- [ ] `lake build` succeeds with zero warnings

## Technical Design

### Architecture Overview

**Phase 0 (Rule Fix)**: Modify `Logos/ProofSystem/Derivation.lean` to fix rule directions:
- Change modal_k: `Derivable Γ φ → Derivable (Γ.map box) (box φ)`
- Change temporal_k: `Derivable Γ φ → Derivable (Γ.map future) (future φ)`

**Phases 1-3 (Soundness)**: Update `Logos/Metalogic/Soundness.lean`:
- After rule fix, soundness proofs use standard modal logic techniques
- Modal K: If `Γ ⊨ φ` then `□Γ ⊨ □φ` (direct from semantics)
- Temporal K: If `Γ ⊨ φ` then `FΓ ⊨ Fφ` (parallel structure)
- Temporal Duality: Requires symmetric frame constraint (documented restriction)

**Phases 4-6 (Automation)**: Replace stubs in `Logos/Automation/Tactics.lean`:
- apply_axiom: Macro-based axiom application
- modal_t: elab_rules pattern-matched tactic
- tm_auto: Aesop integration with TMLogic rule set
- assumption_search: TacticM with context iteration

### Component Interactions

```
Derivation.lean (rules) → Soundness.lean (proofs) → Tactics.lean (automation)
                                                  ↓
                                            TacticsTest.lean (tests)
```

### Key Dependencies
- Phase 0 must complete before Phases 1-3 (rule fix enables correct soundness proofs)
- Phases 4-7 can run in parallel with Phases 1-3
- Phase 8 depends on all other phases completing

## Implementation Phases

### Phase 0: Fix Modal K and Temporal K Rule Definitions [IN PROGRESS]
dependencies: []

**Objective**: Fix the inference rule definitions in Derivation.lean to match the paper's §sec:Appendix definitions

**Complexity**: Medium

Tasks:
- [ ] Read Derivation.lean lines 82-112 to understand current rule structure
- [ ] Change modal_k rule signature from `Derivable (Γ.map box) φ → Derivable Γ (box φ)` to `Derivable Γ φ → Derivable (Γ.map box) (box φ)`
- [ ] Change temporal_k rule signature from `Derivable (Γ.map future) φ → Derivable Γ (future φ)` to `Derivable Γ φ → Derivable (Γ.map future) (future φ)`
- [ ] Update docstrings with paper references (lines 1030, 1037)
- [ ] Search for and update all code using modal_k/temporal_k (grep verification)
- [ ] Update Soundness.lean to align with new rule signatures
- [ ] Run `lake build` to verify no type errors
- [ ] Run existing tests to verify no regressions
- [ ] Update KNOWN_LIMITATIONS.md to remove code-paper alignment warnings

Testing:
```bash
# Verify rule signatures changed
grep -A2 "| modal_k" Logos/ProofSystem/Derivation.lean
grep -A2 "| temporal_k" Logos/ProofSystem/Derivation.lean

# Build verification
lake build Logos.ProofSystem.Derivation
lake build
```

**Expected Duration**: 8-10 hours

---

### Phase 1: Modal K Rule Soundness [NOT STARTED]
dependencies: [0]

**Objective**: Prove soundness of the CORRECTED modal_k inference rule

**Complexity**: Medium

Tasks:
- [ ] Read corrected modal_k rule to understand new semantics
- [ ] Implement soundness proof: If `Γ ⊨ φ` then `□Γ ⊨ □φ`
- [ ] Replace `sorry` at Soundness.lean line ~535 with complete proof
- [ ] Verify proof compiles without `sorry`
- [ ] Add test cases for modal_k soundness

Testing:
```bash
grep -n "sorry" Logos/Metalogic/Soundness.lean | grep -v temporal_duality
lake build Logos.Metalogic.Soundness
```

**Expected Duration**: 3-5 hours

---

### Phase 2: Temporal K Rule Soundness [NOT STARTED]
dependencies: [0]

**Objective**: Prove soundness of the CORRECTED temporal_k inference rule

**Complexity**: Medium

Tasks:
- [ ] Read corrected temporal_k rule to understand new semantics
- [ ] Implement soundness proof: If `Γ ⊨ φ` then `FΓ ⊨ Fφ`
- [ ] Replace `sorry` at Soundness.lean line ~553 with complete proof
- [ ] Verify proof compiles without `sorry`
- [ ] Add test cases for temporal_k soundness

Testing:
```bash
grep -n "sorry" Logos/Metalogic/Soundness.lean
lake build Logos.Metalogic.Soundness
```

**Expected Duration**: 3-5 hours

---

### Phase 3: Temporal Duality Soundness [NOT STARTED]
dependencies: [0]

**Objective**: Prove soundness of temporal_duality rule for symmetric frames

**Complexity**: High

Tasks:
- [ ] Define SymmetricFrame constraint in new helper file TemporalDuality.lean
- [ ] Prove swap_past_future_preserves_validity_symmetric lemma
- [ ] Implement temporal_duality soundness proof using symmetric frame assumption
- [ ] Replace `sorry` at Soundness.lean line ~571 with conditional proof
- [ ] Document symmetric frame restriction in KNOWN_LIMITATIONS.md
- [ ] Add test cases for temporal_duality soundness

Testing:
```bash
lake build Logos.Metalogic.Soundness
lake build Logos.Metalogic.TemporalDuality
grep -n "sorry" Logos/Metalogic/Soundness.lean
```

**Expected Duration**: 5-10 hours

---

### Phase 4: Basic Tactics (apply_axiom + modal_t) [NOT STARTED]
dependencies: []

**Objective**: Implement two foundational tactics using LEAN 4 metaprogramming

**Complexity**: Medium

Tasks:
- [ ] Add required imports to Tactics.lean (Lean.Elab.Tactic, Lean.Meta.Basic)
- [ ] Remove axiom stubs (modal_k_tactic_stub, etc.)
- [ ] Implement apply_axiom macro: `macro "apply_axiom" ax:ident : tactic => ...`
- [ ] Implement modal_t elab_rules with goal pattern matching
- [ ] Add comprehensive docstrings with usage examples
- [ ] Create TacticsTest.lean with unit tests (TDD approach)
- [ ] Test apply_axiom with all 8 axioms
- [ ] Test modal_t pattern matching and error messages

Testing:
```bash
lake build Logos.Automation.Tactics
lake test LogosTest.Automation.TacticsTest
```

**Expected Duration**: 5-8 hours

---

### Phase 5: Aesop Integration (tm_auto) [NOT STARTED]
dependencies: [4]

**Objective**: Integrate Aesop proof search framework with TMLogic rule set

**Complexity**: Medium

Tasks:
- [ ] Add Aesop import to Tactics.lean
- [ ] Declare TMLogic rule set: `declare_aesop_rule_sets [TMLogic]`
- [ ] Add `@[aesop safe [TMLogic]]` to all 10 axiom validity theorems in Soundness.lean
- [ ] Add `@[aesop safe [TMLogic]]` to all 6 perpetuity theorems in Perpetuity.lean
- [ ] Implement tm_auto macro: `macro "tm_auto" : tactic => ...`
- [ ] Add integration tests for tm_auto with various proof goals
- [ ] Add performance tests to verify bounded search behavior

Testing:
```bash
# Verify Aesop attributes
grep -c "@\[aesop safe \[TMLogic\]\]" Logos/Metalogic/Soundness.lean
grep -c "@\[aesop safe \[TMLogic\]\]" Logos/Theorems/Perpetuity.lean

lake build Logos.Automation.Tactics
lake test LogosTest.Automation.TacticsTest
```

**Expected Duration**: 6-8 hours

---

### Phase 6: Advanced Tactics (assumption_search) [NOT STARTED]
dependencies: [4]

**Objective**: Implement assumption_search using TacticM with context iteration

**Complexity**: High

Tasks:
- [ ] Implement assumption_search_impl function with local context iteration
- [ ] Add definitional equality checking (isDefEq)
- [ ] Implement goal assignment on match
- [ ] Add clear error messages for no-match case
- [ ] Create elab declaration for assumption_search tactic
- [ ] Add unit tests for single/multiple assumption cases
- [ ] Add integration tests combining assumption_search with other tactics
- [ ] Document tactic in TACTIC_DEVELOPMENT.md

Testing:
```bash
lake build Logos.Automation.Tactics
lake test LogosTest.Automation.TacticsTest
```

**Expected Duration**: 8-12 hours

---

### Phase 7: Test Suite Development [NOT STARTED]
dependencies: []

**Objective**: Create comprehensive test suite for automation package following TDD

**Complexity**: Medium

Tasks:
- [ ] Create TacticsTest.lean with test structure
- [ ] Write unit tests for apply_axiom (10+ tests)
- [ ] Write unit tests for modal_t (10+ tests)
- [ ] Write integration tests for tm_auto (15+ tests)
- [ ] Write unit tests for assumption_search (10+ tests)
- [ ] Write negative tests for error handling (10+ tests)
- [ ] Write performance tests for tm_auto depth limits (5+ tests)
- [ ] Create ProofSearchTest.lean placeholder for future work
- [ ] Verify test coverage ≥80% for Automation package

Testing:
```bash
grep -c "def test_" LogosTest/Automation/TacticsTest.lean
lake test
```

**Expected Duration**: 10-15 hours

---

### Phase 8: Documentation Sync [NOT STARTED]
dependencies: [0, 1, 2, 3, 4, 5, 6, 7]

**Objective**: Synchronize all documentation with completed implementation changes

**Complexity**: Low

Tasks:
- [ ] Update IMPLEMENTATION_STATUS.md with Soundness module status (100%)
- [ ] Update IMPLEMENTATION_STATUS.md with Automation module status (40%)
- [ ] Update KNOWN_LIMITATIONS.md - remove code-paper alignment warnings
- [ ] Update KNOWN_LIMITATIONS.md - add symmetric frame restriction for temporal duality
- [ ] Update TACTIC_DEVELOPMENT.md with implemented tactic examples
- [ ] Update TODO.md with completion dates for Tasks 5, 5b, 7, 12
- [ ] Update CLAUDE.md overview to reflect completed work
- [ ] Verify all cross-references and file paths accurate

Testing:
```bash
# Verify documentation updates
grep "Soundness.*100%" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep "Automation.*40%" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep -c "RESOLVED" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
```

**Expected Duration**: 3-5 hours

## Testing Strategy

### Unit Testing
- Each tactic has dedicated unit tests in TacticsTest.lean
- Test correct behavior for valid inputs
- Test error messages for invalid inputs
- Test edge cases (empty context, nested formulas)

### Integration Testing
- Test tactic combinations (modal_t + assumption_search)
- Test tm_auto with complex proof goals
- Test soundness theorems with implemented tactics

### Performance Testing
- Verify tm_auto completes within reasonable time (< 1 second per goal)
- Test deeply nested formulas (depth 5+)
- Benchmark Aesop search depth limits

### Regression Testing
- All existing tests must continue passing
- Run full test suite after each phase completion

## Documentation Requirements

### Files to Update
1. **IMPLEMENTATION_STATUS.md**: Update Soundness (→ 100%) and Automation (→ 40%) status
2. **KNOWN_LIMITATIONS.md**: Remove code-paper alignment warnings, add frame restrictions
3. **TACTIC_DEVELOPMENT.md**: Add implemented tactic examples and usage patterns
4. **TODO.md**: Mark Tasks 5, 5b, 7, 12 as complete with dates
5. **CLAUDE.md**: Update overview sections for Metalogic and Automation packages

### Documentation Standards
- All docstrings follow LEAN_STYLE_GUIDE.md format
- Paper references include line numbers (e.g., "line 1030")
- Verification commands provided for each claim

## Dependencies

### External Dependencies
- Aesop library (for tm_auto integration)
- LEAN 4 metaprogramming API (Lean.Elab.Tactic, Lean.Meta)

### Internal Dependencies
- Phase 0 must complete before Phases 1-3 (rule fix enables soundness proofs)
- Phase 4 must complete before Phase 5 (Aesop builds on basic tactics)
- Phase 8 depends on all previous phases (documentation sync)

### Parallel Execution
- Phases 1, 2, 3 can run in parallel (after Phase 0)
- Phases 4, 5, 6, 7 can run in parallel with Phases 1-3
- Optimal with 2 developers: one on soundness track (0→1→2→3→8), one on automation track (4→5→6→7)
