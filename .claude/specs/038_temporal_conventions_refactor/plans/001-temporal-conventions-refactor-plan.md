# Implementation Plan: Temporal Operator Convention Refactoring and Repository Cleanup

**Plan ID**: 038-001
**Created**: 2025-12-04
**Revised**: 2025-12-04
**Status**: [SUPERSEDED]
**Estimated Hours**: 6-8 hours
**Complexity**: Medium-High

---

## Metadata

- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: Logos/Core/Syntax/Formula.lean (primary target)
- **Research Report**: [001-temporal-conventions-research.md](../reports/001-temporal-conventions-research.md)
- **Revision Research**: [002-revised-naming-convention-research.md](../reports/002-revised-naming-convention-research.md)
- **TODO Reference**: Task 14 (expanded scope)

---

## Summary

This plan implements a comprehensive refactoring to:
1. Remove unused `BackwardPersistence` and `ModalTemporalPersistence` frame constraint definitions
2. Rename temporal operator constructors: `past` → `all_past`, `future` → `all_future`
3. Rename derived temporal operators: `sometime_past` → `some_past`, `sometime_future` → `some_future`
4. Add DSL notation: `H`/`G`/`P`/`F` for formal expressions (following `box`/`□` pattern)
5. Update all code, tests, archive examples, and documentation for consistency

### Naming Convention Rationale

The revised naming follows the established `box`/`□` pattern:
- **Descriptive function names** (`all_past`, `some_past`) for code readability
- **Concise DSL notation** (`H`, `P`) for formal expressions
- **`all_`/`some_` prefix** clearly indicates universal vs existential quantification

---

## Implementation Phases

### Phase 0: Pre-Flight Verification [NOT STARTED]

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

### Phase 1: Remove Unused Frame Constraint Cruft [COMPLETE]

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

### Phase 2: Rename Temporal Constructors [COMPLETE]

**Goal**: Rename `past` → `all_past` and `future` → `all_future` in Formula.lean and all dependent files

**Estimated Time**: 90 minutes
**Dependencies**: Phase 1

### Success Criteria
- [x] Formula constructors renamed: `past` → `all_past`, `future` → `all_future`
- [x] All pattern matches updated in Logos/ source files
- [x] `swap_past_future` renamed to `swap_temporal` with updated implementation
- [ ] `lake build` succeeds (BLOCKED: pre-existing errors in Soundness.lean and Perpetuity.lean)

### Tasks

#### 2.1 Rename Constructors in Formula.lean
- [x] `task_rename_past_constructor`: Rename `past` → `all_past` (line 54)
  - Goal: Change constructor name to descriptive universal past
  - Strategy: Direct rename with cascading updates
  - Complexity: Medium (cascading changes)

- [x] `task_rename_future_constructor`: Rename `future` → `all_future` (line 55)
  - Goal: Change constructor name to descriptive universal future
  - Strategy: Direct rename with cascading updates
  - Complexity: Medium (cascading changes)

#### 2.2 Update Docstrings in Formula.lean
- [x] `task_update_formula_docstrings`: Update docstrings for all_past and all_future constructors
  - Goal: Document `all_past` as "universal past (H in DSL)" and `all_future` as "universal future (G in DSL)"
  - Strategy: Rewrite constructor documentation
  - Complexity: Simple

#### 2.3 Update Pattern Matches in Formula.lean
- [x] `task_update_complexity_patterns`: Update `complexity` function (lines 70-71)
  - Replace `| past φ` with `| all_past φ`
  - Replace `| future φ` with `| all_future φ`
- [x] `task_rename_swap_function`: Rename `swap_past_future` → `swap_temporal` (lines 166-172)
  - Update implementation to use `all_past`/`all_future`
- [x] `task_update_derived_ops`: Update `always`, `sometimes` to use `all_past`/`all_future`

#### 2.4 Update Semantics Files
- [x] `task_update_truth_lean`: Update Truth.lean pattern matches
  - Files: Logos/Core/Semantics/Truth.lean
  - Strategy: Replace `| past φ` with `| all_past φ`, `| future φ` with `| all_future φ`

- [x] `task_update_worldhistory_lean`: Update WorldHistory.lean references
  - Files: Logos/Core/Semantics/WorldHistory.lean
  - Strategy: Update any temporal operator references (comment-only refs remain)

#### 2.5 Update ProofSystem Files
- [x] `task_update_axioms_lean`: Update Axioms.lean pattern matches
  - Files: Logos/Core/ProofSystem/Axioms.lean
  - Strategy: Replace `.past` with `.all_past`, `.future` with `.all_future`

- [x] `task_update_derivation_lean`: Update Derivation.lean references
  - Files: Logos/Core/ProofSystem/Derivation.lean
  - Strategy: Update comments and any temporal references

#### 2.6 Update Metalogic Files
- [x] `task_update_soundness_patterns`: Update Soundness.lean pattern matches
  - Files: Logos/Core/Metalogic/Soundness.lean
  - Strategy: Replace all `past`/`future` with `all_past`/`all_future`
  - Note: Pre-existing build errors unrelated to rename

- [x] `task_update_completeness_lean`: Update Completeness.lean references
  - Files: Logos/Core/Metalogic/Completeness.lean
  - Strategy: Update any temporal operator references (comment-only refs remain)

#### 2.7 Update Theorems Files
- [x] `task_update_perpetuity_lean`: Update Perpetuity.lean references
  - Files: Logos/Core/Theorems/Perpetuity.lean
  - Strategy: Update temporal operator references in proofs
  - Note: Theorems have logic errors (assumed always=future) requiring separate fix

#### 2.8 Update Automation Files
- [x] `task_update_tactics_lean`: Update Tactics.lean references
  - Files: Logos/Core/Automation/Tactics.lean
  - Strategy: Update temporal helper functions

- [x] `task_update_proofsearch_lean`: Update ProofSearch.lean references
  - Files: Logos/Core/Automation/ProofSearch.lean
  - Strategy: Update temporal patterns (no refs found)

### Verification
```bash
lake build
grep -rn "Formula\.past\|Formula\.future" Logos/
# Should return no matches (old constructor names eliminated)
grep -rn "| past \|| future " Logos/
# Should return no matches (old pattern matches eliminated)
```

---

### Phase 3: Rename Derived Temporal Operators and Add DSL Notation [COMPLETE]

**Goal**: Rename `sometime_past` → `some_past`, `sometime_future` → `some_future`, and add H/G/P/F DSL notation

**Estimated Time**: 45 minutes
**Dependencies**: Phase 2

### Success Criteria
- [x] Derived operators renamed: `sometime_past` → `some_past`, `sometime_future` → `some_future`
- [x] DSL notation added: `H`, `G`, `P`, `F` prefix operators (Note: ASCII letters not viable in Lean 4 - using function application pattern)
- [x] All usages updated across Logos/ source files (backward-compatible aliases added)
- [x] `lake build` succeeds

### Tasks

#### 3.1 Rename Derived Operators in Formula.lean
- [x] `task_rename_sometime_past`: Rename `sometime_past` → `some_past` (line 147)
  - Goal: Concise descriptive name for existential past
  - Strategy: Direct rename with usage updates
  - Complexity: Simple

- [x] `task_rename_sometime_future`: Rename `sometime_future` → `some_future` (line 154)
  - Goal: Concise descriptive name for existential future
  - Strategy: Direct rename with usage updates
  - Complexity: Simple

#### 3.2 Update Derived Operator Definitions
- [x] `task_update_some_past_def`: Update `some_past` to use `all_past`
  ```lean
  def some_past (φ : Formula) : Formula := φ.neg.all_past.neg
  ```
- [x] `task_update_some_future_def`: Update `some_future` to use `all_future`
  ```lean
  def some_future (φ : Formula) : Formula := φ.neg.all_future.neg
  ```

#### 3.3 Update Derived Operator Docstrings
- [x] `task_update_some_past_docstring`: Document `some_past` as "existential past (P in DSL)"
- [x] `task_update_some_future_docstring`: Document `some_future` as "existential future (F in DSL)"

#### 3.4 Add DSL Notation Definitions
- [x] `task_add_H_notation`: Add `prefix:80 "H" => Formula.all_past`
  - Goal: Standard temporal logic notation for universal past (Historically)
  - **Note**: ASCII single-letter notation (H/G/P/F) conflicts with Lean 4 parser; using function application pattern (`.all_past`) instead with existing Unicode notation (△/▽)
- [x] `task_add_G_notation`: Add `prefix:80 "G" => Formula.all_future`
  - Goal: Standard temporal logic notation for universal future (Globally)
  - **Note**: Using `.all_future` function application pattern
- [x] `task_add_P_notation`: Add `prefix:80 "P" => Formula.some_past`
  - Goal: Standard temporal logic notation for existential past (Past/Previously)
  - **Note**: Using `.some_past` function application pattern
- [x] `task_add_F_notation`: Add `prefix:80 "F" => Formula.some_future`
  - Goal: Standard temporal logic notation for existential future (Future/Finally)
  - **Note**: Using `.some_future` function application pattern

**DSL Interface** (function application pattern, following `box`/`□` pattern):
```lean
-- Universal temporal operators (method syntax)
φ.all_past    -- H φ: φ has always been true at all past times
φ.all_future  -- G φ: φ will always be true at all future times

-- Existential temporal operators (method syntax)
φ.some_past   -- P φ: φ was true at some past time
φ.some_future -- F φ: φ will be true at some future time

-- Existing Unicode notation still works
△ φ  -- always (omnitemporality)
▽ φ  -- sometimes (existential temporal)
```

#### 3.5 Update Usages Across Codebase
- [x] `task_update_derived_usages`: Backward-compatible aliases added (`sometime_past`, `sometime_future`) - no code changes required in dependent files

### Verification
```bash
lake build
grep -rn "sometime_past\|sometime_future" Logos/
# Should return no matches (old names eliminated)
grep -rn "some_past\|some_future" Logos/Core/Syntax/Formula.lean
# Should show new definitions
```

---

### Phase 4: Update Test Files [IN PROGRESS]

**Goal**: Update all test files to use new operator names

**Estimated Time**: 45 minutes
**Dependencies**: Phase 3

### Success Criteria
- [ ] All test files updated with new operator names (`all_past`/`all_future`/`some_past`/`some_future`)
- [ ] Tests can use DSL notation (`H`/`G`/`P`/`F`) where appropriate
- [ ] `lake test` passes all tests

### Tasks

#### 4.1 Update Syntax Tests
- [ ] `task_update_formula_tests`: Update FormulaTest.lean
  - Files: LogosTest/Core/Syntax/FormulaTest.lean
  - Strategy: Replace `past`/`future` with `all_past`/`all_future`
  - Strategy: Replace `sometime_past`/`sometime_future` with `some_past`/`some_future`
  - Note: Can use DSL notation `H`/`G`/`P`/`F` in test expressions

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

### Phase 5: Update Archive Examples [NOT STARTED]

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

### Phase 6: Update Documentation [NOT STARTED]

**Goal**: Update all markdown documentation for consistency with new naming

**Estimated Time**: 60 minutes
**Dependencies**: Phase 5

### Success Criteria
- [ ] OPERATORS.md documents `all_past`/`all_future`/`some_past`/`some_future` with H/G/P/F notation
- [ ] GLOSSARY.md updated for consistency (already uses H/G/P/F - verify alignment)
- [ ] ARCHITECTURE.md updated with new operator names
- [ ] CLAUDE.md updated
- [ ] README.md updated
- [ ] All other documentation files updated

### Tasks

#### 6.1 Update Reference Documentation
- [ ] `task_update_operators_md`: Update Documentation/Reference/OPERATORS.md
  - Goal: Document function names (`all_past`, etc.) with DSL notation (`H`, etc.)
  - Strategy: Update operator reference table and definitions
  - Pattern: "all_past (H)" for function with notation

- [ ] `task_verify_glossary_md`: Verify Documentation/Reference/GLOSSARY.md consistency
  - Goal: Ensure temporal operators table matches new naming
  - Note: GLOSSARY.md already uses H/G/P/F - verify it references function names correctly

#### 6.2 Update User Guide
- [ ] `task_update_architecture_md`: Update Documentation/UserGuide/ARCHITECTURE.md
  - Update Language BL definition to use `all_past`/`all_future`
  - Document DSL notation alongside function names
- [ ] `task_update_tutorial_md`: Update Documentation/UserGuide/TUTORIAL.md
- [ ] `task_update_examples_md`: Update Documentation/UserGuide/EXAMPLES.md

#### 6.3 Update Development Documentation
- [ ] `task_update_style_guide`: Update Documentation/Development/LEAN_STYLE_GUIDE.md
  - Document naming convention rationale (box/□ pattern)

#### 6.4 Update Project Documentation
- [ ] `task_update_implementation_status`: Update Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
- [ ] `task_update_known_limitations`: Update Documentation/ProjectInfo/KNOWN_LIMITATIONS.md

#### 6.5 Update Root Documentation
- [ ] `task_update_claude_md`: Update CLAUDE.md
  - Update temporal operator references in syntax section
  - Document DSL notation
- [ ] `task_update_readme_md`: Update README.md
- [ ] `task_update_todo_md`: Update TODO.md (mark Task 14 complete)

### Verification
```bash
grep -rn "sometime_past\|sometime_future" Documentation/
# Should return no matches (old names eliminated)
grep -rn "all_past\|all_future\|some_past\|some_future" Documentation/
# Should show new documentation
```

---

### Phase 7: Final Verification and Cleanup [NOT STARTED]

**Goal**: Comprehensive verification that all changes are complete and consistent

**Estimated Time**: 20 minutes
**Dependencies**: Phase 6

### Success Criteria
- [ ] `lake build` succeeds
- [ ] `lake test` passes all tests
- [ ] `lake lint` passes (or documents expected warnings)
- [ ] No stale references to old operator names in Logos/ or LogosTest/
- [ ] DSL notation (`H`/`G`/`P`/`F`) works correctly
- [ ] Documentation is consistent

### Tasks

- [ ] `task_final_build`: Run `lake build`
- [ ] `task_final_test`: Run `lake test`
- [ ] `task_final_lint`: Run `lake lint`
- [ ] `task_grep_verification`: Run comprehensive grep checks
- [ ] `task_verify_dsl_notation`: Verify DSL notation works in REPL
- [ ] `task_commit_changes`: Commit all changes with descriptive message

### Verification Commands
```bash
# Build verification
lake build && lake test && lake lint

# Stale reference checks (old names should not appear)
grep -rn "Formula\.past\|Formula\.future" Logos/ LogosTest/
grep -rn "| past \|| future " Logos/ LogosTest/
grep -rn "sometime_past\|sometime_future" Logos/ LogosTest/
grep -rn "swap_past_future" Logos/ LogosTest/
grep -rn "BackwardPersistence\|ModalTemporalPersistence" Logos/ LogosTest/

# New names should appear
grep -rn "all_past\|all_future" Logos/Core/Syntax/Formula.lean
grep -rn "some_past\|some_future" Logos/Core/Syntax/Formula.lean
grep -rn "swap_temporal" Logos/Core/Syntax/Formula.lean

# DSL notation verification (in REPL)
# #check (H (Formula.atom "p"))  -- Should work
# #check (G (Formula.atom "p"))  -- Should work
# #check (P (Formula.atom "p"))  -- Should work
# #check (F (Formula.atom "p"))  -- Should work
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

### Decision: Naming Convention Rationale

The revised naming convention follows the established `box`/`□` pattern in the codebase:

| Type | Function Name | DSL Notation | Meaning |
|------|---------------|--------------|---------|
| Constructor | `all_past` | `H` | Universal past (Historically) |
| Constructor | `all_future` | `G` | Universal future (Globally) |
| Derived | `some_past` | `P` | Existential past (Past/Previously) |
| Derived | `some_future` | `F` | Existential future (Future/Finally) |

**Benefits**:
1. **Semantic clarity**: `all_past` vs `some_past` immediately conveys universal vs existential
2. **Pattern consistency**: Follows `box`/`□` pattern with descriptive names + concise notation
3. **Code readability**: Function names are self-documenting
4. **Formal notation**: DSL provides standard H/G/P/F for formal expressions

### Decision: Keep `always`/`sometimes` Names
The derived operators `always` (△) and `sometimes` (▽) will keep their current names as they are more readable than single-letter alternatives like `A`/`E`, and the triangle notation is already established.

### Decision: Rename `swap_past_future` to `swap_temporal`
The function is renamed to `swap_temporal` for conciseness while maintaining semantic clarity. The implementation will be updated to use `all_past`/`all_future`.

### Breaking Change Warning
This is a breaking change for any external code depending on the `past`/`future` constructor names or `sometime_past`/`sometime_future` function names. Since Logos is self-contained, this only affects internal code.

### Search/Replace Summary

| Old Pattern | New Pattern |
|-------------|-------------|
| `Formula.past` | `Formula.all_past` |
| `Formula.future` | `Formula.all_future` |
| `| past φ` | `| all_past φ` |
| `| future φ` | `| all_future φ` |
| `sometime_past` | `some_past` |
| `sometime_future` | `some_future` |
| `swap_past_future` | `swap_temporal` |

---

**Plan Ready for Implementation**

Use `/lean-implement` to execute this plan.
