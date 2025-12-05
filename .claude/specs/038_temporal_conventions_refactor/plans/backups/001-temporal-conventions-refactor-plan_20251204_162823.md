# Implementation Plan: Temporal Operator Convention Refactoring and Repository Cleanup

**Plan ID**: 038-001
**Created**: 2025-12-04
**Status**: [NOT STARTED]
**Estimated Hours**: 5-7 hours
**Complexity**: Medium-High

---

## Metadata

- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: Logos/Core/Syntax/Formula.lean (primary target)
- **Research Report**: [001-temporal-conventions-research.md](../reports/001-temporal-conventions-research.md)
- **TODO Reference**: Task 14 (expanded scope)

---

## Summary

This plan implements a comprehensive refactoring to:
1. Remove unused `BackwardPersistence` and `ModalTemporalPersistence` frame constraint definitions
2. Rename temporal operator constructors from `past`/`future` to standard `H`/`G` notation
3. Rename derived temporal operators from `sometime_past`/`sometime_future` to `P`/`F`
4. Update all code, tests, archive examples, and documentation for consistency

---

## Phase 0: Pre-Flight Verification [NOT STARTED]

**Goal**: Verify codebase state before making changes

**Estimated Time**: 15 minutes

### Success Criteria
- [ ] `lake build` succeeds with no errors
- [ ] `lake test` passes all tests
- [ ] Git working tree is clean (or changes are committed)

### Tasks
- [ ] `task_verify_build`: Run `lake build` and confirm success
- [ ] `task_verify_tests`: Run `lake test` and confirm all tests pass
- [ ] `task_git_status`: Verify clean working tree or commit pending changes

### Verification
```bash
lake build && lake test
git status --short
```

---

## Phase 1: Remove Unused Frame Constraint Cruft [NOT STARTED]

**Goal**: Delete BackwardPersistence and ModalTemporalPersistence definitions and update documentation

**Estimated Time**: 45 minutes
**Dependencies**: Phase 0

### Success Criteria
- [ ] `BackwardPersistence` definition removed from Soundness.lean
- [ ] `ModalTemporalPersistence` definition removed from Soundness.lean
- [ ] Module docstring updated to remove outdated conditional validity claims
- [ ] Individual theorem docstrings updated (temp_l_valid, modal_future_valid, temp_future_valid)
- [ ] `lake build` succeeds
- [ ] No grep matches for "BackwardPersistence" or "ModalTemporalPersistence" in Logos/

### Tasks

#### 1.1 Remove BackwardPersistence Definition
- [ ] `task_remove_backward_persistence`: Delete lines 99-123 in Soundness.lean
  - Goal: Remove unused `BackwardPersistence` definition
  - Strategy: Direct deletion with build verification
  - Complexity: Simple

#### 1.2 Remove ModalTemporalPersistence Definition
- [ ] `task_remove_modal_temporal_persistence`: Delete lines 125-149 in Soundness.lean
  - Goal: Remove unused `ModalTemporalPersistence` definition
  - Strategy: Direct deletion with build verification
  - Complexity: Simple

#### 1.3 Update Module Docstring
- [ ] `task_update_soundness_docstring`: Update lines 1-70 module docstring
  - Goal: Remove references to conditional validity and frame constraints
  - Strategy: Rewrite docstring to reflect current unconditional validity
  - Complexity: Simple

#### 1.4 Update Axiom Docstrings
- [ ] `task_update_temp_l_docstring`: Update temp_l_valid docstring (around line 348)
  - Goal: Remove "Frame Constraint Required: BackwardPersistence"
  - Strategy: Document as unconditionally valid

- [ ] `task_update_modal_future_docstring`: Update modal_future_valid docstring (around line 399)
  - Goal: Remove "Frame Constraint Required: ModalTemporalPersistence"
  - Strategy: Document as unconditionally valid

- [ ] `task_update_temp_future_docstring`: Update temp_future_valid docstring (around line 452)
  - Goal: Remove "Frame Constraint Required: ModalTemporalPersistence"
  - Strategy: Document as unconditionally valid

### Verification
```bash
lake build
grep -rn "BackwardPersistence\|ModalTemporalPersistence" Logos/
# Should return no matches
```

---

## Phase 2: Rename Temporal Constructors [NOT STARTED]

**Goal**: Rename `past` → `H` and `future` → `G` in Formula.lean and all dependent files

**Estimated Time**: 90 minutes
**Dependencies**: Phase 1

### Success Criteria
- [ ] Formula constructors renamed: `past` → `H`, `future` → `G`
- [ ] All pattern matches updated in Logos/ source files
- [ ] `swap_past_future` implementation updated (or renamed to `swap_H_G`)
- [ ] `lake build` succeeds

### Tasks

#### 2.1 Rename Constructors in Formula.lean
- [ ] `task_rename_past_constructor`: Rename `past` → `H` (line 54)
  - Goal: Change constructor name to standard temporal notation
  - Strategy: Direct rename with cascading updates
  - Complexity: Medium (cascading changes)

- [ ] `task_rename_future_constructor`: Rename `future` → `G` (line 55)
  - Goal: Change constructor name to standard temporal notation
  - Strategy: Direct rename with cascading updates
  - Complexity: Medium (cascading changes)

#### 2.2 Update Docstrings in Formula.lean
- [ ] `task_update_formula_docstrings`: Update docstrings for H and G constructors
  - Goal: Document H as "historically/universal past" and G as "globally/universal future"
  - Strategy: Rewrite constructor documentation
  - Complexity: Simple

#### 2.3 Update Pattern Matches in Formula.lean
- [ ] `task_update_complexity_patterns`: Update `complexity` function (lines 70-71)
- [ ] `task_update_swap_patterns`: Update `swap_past_future` function (lines 166-172)
- [ ] `task_update_derived_ops`: Update `always`, `sometimes`, `sometime_past`, `sometime_future`

#### 2.4 Update Semantics Files
- [ ] `task_update_truth_lean`: Update Truth.lean pattern matches
  - Files: Logos/Core/Semantics/Truth.lean
  - Strategy: Replace `past φ` with `H φ`, `future φ` with `G φ`

- [ ] `task_update_worldhistory_lean`: Update WorldHistory.lean references
  - Files: Logos/Core/Semantics/WorldHistory.lean
  - Strategy: Update any temporal operator references

#### 2.5 Update ProofSystem Files
- [ ] `task_update_axioms_lean`: Update Axioms.lean pattern matches
  - Files: Logos/Core/ProofSystem/Axioms.lean
  - Strategy: Replace temporal operator references

- [ ] `task_update_derivation_lean`: Update Derivation.lean references
  - Files: Logos/Core/ProofSystem/Derivation.lean
  - Strategy: Update comments and any temporal references

#### 2.6 Update Metalogic Files
- [ ] `task_update_soundness_patterns`: Update Soundness.lean pattern matches
  - Files: Logos/Core/Metalogic/Soundness.lean
  - Strategy: Replace all `past`/`future` with `H`/`G`

- [ ] `task_update_completeness_lean`: Update Completeness.lean references
  - Files: Logos/Core/Metalogic/Completeness.lean
  - Strategy: Update any temporal operator references

#### 2.7 Update Theorems Files
- [ ] `task_update_perpetuity_lean`: Update Perpetuity.lean references
  - Files: Logos/Core/Theorems/Perpetuity.lean
  - Strategy: Update temporal operator references in proofs

#### 2.8 Update Automation Files
- [ ] `task_update_tactics_lean`: Update Tactics.lean references
  - Files: Logos/Core/Automation/Tactics.lean
  - Strategy: Update temporal helper functions

- [ ] `task_update_proofsearch_lean`: Update ProofSearch.lean references
  - Files: Logos/Core/Automation/ProofSearch.lean
  - Strategy: Update temporal patterns

### Verification
```bash
lake build
grep -rn "\.past\|\.future" Logos/ | grep -v "swap_past_future" | grep -v "sometime"
# Should return minimal or no matches (only in comments/docstrings)
```

---

## Phase 3: Rename Derived Temporal Operators [NOT STARTED]

**Goal**: Rename `sometime_past` → `P` and `sometime_future` → `F`

**Estimated Time**: 30 minutes
**Dependencies**: Phase 2

### Success Criteria
- [ ] Derived operators renamed: `sometime_past` → `P`, `sometime_future` → `F`
- [ ] All usages updated across Logos/ source files
- [ ] `lake build` succeeds

### Tasks

#### 3.1 Rename Derived Operators in Formula.lean
- [ ] `task_rename_sometime_past`: Rename `sometime_past` → `P` (line 147)
  - Goal: Change function name to standard notation
  - Strategy: Direct rename with usage updates
  - Complexity: Simple

- [ ] `task_rename_sometime_future`: Rename `sometime_future` → `F` (line 154)
  - Goal: Change function name to standard notation
  - Strategy: Direct rename with usage updates
  - Complexity: Simple

#### 3.2 Update Derived Operator Docstrings
- [ ] `task_update_P_docstring`: Document P as existential past operator
- [ ] `task_update_F_docstring`: Document F as existential future operator

#### 3.3 Update Usages Across Codebase
- [ ] `task_update_derived_usages`: Search and replace all `sometime_past`/`sometime_future` references

### Verification
```bash
lake build
grep -rn "sometime_past\|sometime_future" Logos/
# Should return no matches
```

---

## Phase 4: Update Test Files [NOT STARTED]

**Goal**: Update all test files to use new operator names

**Estimated Time**: 45 minutes
**Dependencies**: Phase 3

### Success Criteria
- [ ] All test files updated with new operator names
- [ ] `lake test` passes all tests

### Tasks

#### 4.1 Update Syntax Tests
- [ ] `task_update_formula_tests`: Update FormulaTest.lean
  - Files: LogosTest/Core/Syntax/FormulaTest.lean
  - Strategy: Replace `past`/`future`/`sometime_*` with `H`/`G`/`P`/`F`

#### 4.2 Update ProofSystem Tests
- [ ] `task_update_axioms_tests`: Update AxiomsTest.lean
- [ ] `task_update_derivation_tests`: Update DerivationTest.lean

#### 4.3 Update Metalogic Tests
- [ ] `task_update_soundness_tests`: Update SoundnessTest.lean

#### 4.4 Update Automation Tests
- [ ] `task_update_tactics_tests`: Update TacticsTest.lean

#### 4.5 Update Theorems Tests
- [ ] `task_update_perpetuity_tests`: Update PerpetuityTest.lean

### Verification
```bash
lake test
```

---

## Phase 5: Update Archive Examples [NOT STARTED]

**Goal**: Update pedagogical examples in Archive/

**Estimated Time**: 20 minutes
**Dependencies**: Phase 4

### Success Criteria
- [ ] All archive files use new operator names
- [ ] Examples remain pedagogically clear
- [ ] `lake build` includes Archive without errors

### Tasks

- [ ] `task_update_temporal_proofs`: Update Archive/TemporalProofs.lean
- [ ] `task_update_bimodal_proofs`: Update Archive/BimodalProofs.lean
- [ ] `task_update_temporal_structures`: Update Archive/TemporalStructures.lean

### Verification
```bash
lake build
```

---

## Phase 6: Update Documentation [NOT STARTED]

**Goal**: Update all markdown documentation for consistency

**Estimated Time**: 60 minutes
**Dependencies**: Phase 5

### Success Criteria
- [ ] OPERATORS.md uses consistent H/G/P/F terminology
- [ ] GLOSSARY.md verified for consistency
- [ ] ARCHITECTURE.md updated with new operator names
- [ ] CLAUDE.md updated
- [ ] README.md updated
- [ ] All other documentation files updated

### Tasks

#### 6.1 Update Reference Documentation
- [ ] `task_update_operators_md`: Update Documentation/Reference/OPERATORS.md
  - Goal: Standardize all temporal operator references to H/G/P/F
  - Strategy: Replace Past/Future/past/future with H/G/P/F

- [ ] `task_verify_glossary_md`: Verify Documentation/Reference/GLOSSARY.md consistency

#### 6.2 Update User Guide
- [ ] `task_update_architecture_md`: Update Documentation/UserGuide/ARCHITECTURE.md
- [ ] `task_update_tutorial_md`: Update Documentation/UserGuide/TUTORIAL.md
- [ ] `task_update_examples_md`: Update Documentation/UserGuide/EXAMPLES.md

#### 6.3 Update Development Documentation
- [ ] `task_update_style_guide`: Update Documentation/Development/LEAN_STYLE_GUIDE.md

#### 6.4 Update Project Documentation
- [ ] `task_update_implementation_status`: Update Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
- [ ] `task_update_known_limitations`: Update Documentation/ProjectInfo/KNOWN_LIMITATIONS.md

#### 6.5 Update Root Documentation
- [ ] `task_update_claude_md`: Update CLAUDE.md
- [ ] `task_update_readme_md`: Update README.md
- [ ] `task_update_todo_md`: Update TODO.md (mark Task 14 complete)

### Verification
```bash
grep -rn "Past φ\|Future φ" Documentation/ | grep -v "H φ\|G φ"
# Should return minimal matches (only in historical context)
```

---

## Phase 7: Final Verification and Cleanup [NOT STARTED]

**Goal**: Comprehensive verification that all changes are complete and consistent

**Estimated Time**: 20 minutes
**Dependencies**: Phase 6

### Success Criteria
- [ ] `lake build` succeeds
- [ ] `lake test` passes all tests
- [ ] `lake lint` passes (or documents expected warnings)
- [ ] No stale references to old operator names in Logos/ or LogosTest/
- [ ] Documentation is consistent

### Tasks

- [ ] `task_final_build`: Run `lake build`
- [ ] `task_final_test`: Run `lake test`
- [ ] `task_final_lint`: Run `lake lint`
- [ ] `task_grep_verification`: Run comprehensive grep checks
- [ ] `task_commit_changes`: Commit all changes with descriptive message

### Verification Commands
```bash
# Build verification
lake build && lake test && lake lint

# Stale reference checks
grep -rn "\.past\|\.future" Logos/ LogosTest/ | grep -v "swap_past_future"
grep -rn "sometime_past\|sometime_future" Logos/ LogosTest/
grep -rn "BackwardPersistence\|ModalTemporalPersistence" Logos/ LogosTest/

# Documentation consistency
grep -rn "Past φ\|Future φ" Documentation/
```

---

## Rollback Plan

If issues arise during implementation:

1. **Phase 1-2 Issues**: `git checkout -- Logos/Core/`
2. **Test Failures**: `git checkout -- LogosTest/`
3. **Documentation Issues**: `git checkout -- Documentation/ CLAUDE.md README.md`
4. **Complete Rollback**: `git reset --hard HEAD~1` (after commit)

---

## Notes

### Decision: Keep `always`/`sometimes` Names
The derived operators `always` (△) and `sometimes` (▽) will keep their current names as they are more readable than single-letter alternatives like `A`/`E`, and the triangle notation is already established.

### Decision: Keep `swap_past_future` Function Name
Although the implementation will change to use `H`/`G`, the function name `swap_past_future` remains clear and descriptive. It can be updated to `swap_H_G` if preferred.

### Breaking Change Warning
This is a breaking change for any external code depending on the `past`/`future` constructor names or `sometime_past`/`sometime_future` function names. Since Logos is self-contained, this only affects internal code.

---

**Plan Ready for Implementation**

Use `/lean-implement` to execute this plan.
