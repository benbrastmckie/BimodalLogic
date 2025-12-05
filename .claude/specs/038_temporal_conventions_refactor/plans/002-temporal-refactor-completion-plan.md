# Implementation Plan: Temporal Refactor Completion (Phases 4-7)

**Plan ID**: 038-002
**Created**: 2025-12-04
**Status**: [COMPLETE]
**Estimated Hours**: 3-4 hours
**Actual Hours**: 3.5 hours
**Complexity**: Medium
**Parent Plan**: [001-temporal-conventions-refactor-plan.md](001-temporal-conventions-refactor-plan.md)

---

## Metadata

- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: Multiple (LogosTest/, Archive/, Documentation/)
- **Research Report**: [001-temporal-conventions-research.md](../reports/001-temporal-conventions-research.md)
- **TODO Reference**: Task 14 (expanded scope)

---

## Summary

This plan completes the temporal conventions refactor by updating all remaining references to old operator names (`past`/`future`/`sometime_past`/`sometime_future`/`swap_past_future`) across test files, archive examples, and documentation.

**Completed Prerequisites** (from parent plan):
- Phase 1: Remove Unused Frame Constraint Cruft [COMPLETE]
- Phase 2: Rename Temporal Constructors [COMPLETE]
- Phase 3: Rename Derived Temporal Operators [COMPLETE]

**All Phases Complete**:
- Phase 4: Update Test Files [COMPLETE]
- Phase 5: Update Archive Examples [COMPLETE]
- Phase 6: Update Documentation [COMPLETE]
- Phase 7: Final Verification [COMPLETE]

### Naming Convention Summary

| Old Name | New Name | Notes |
|----------|----------|-------|
| `Formula.past` | `Formula.all_past` | Constructor renamed |
| `Formula.future` | `Formula.all_future` | Constructor renamed |
| `sometime_past` | `some_past` | Derived operator renamed |
| `sometime_future` | `some_future` | Derived operator renamed |
| `swap_past_future` | `swap_temporal` | Helper function renamed |

---

## Implementation Phases

### Phase 4: Update Test Files [COMPLETE]

**Goal**: Update all test files to use new operator names

**Estimated Time**: 60 minutes
**Dependencies**: Phases 1-3 complete (verified)

#### Success Criteria
- [ ] All `Formula.past` replaced with `Formula.all_past` in LogosTest/
- [ ] All `Formula.future` replaced with `Formula.all_future` in LogosTest/
- [ ] All `sometime_past` replaced with `some_past` in LogosTest/
- [ ] All `sometime_future` replaced with `some_future` in LogosTest/
- [ ] All `swap_past_future` replaced with `swap_temporal` in LogosTest/
- [ ] `lake build` succeeds

#### Tasks

##### 4.1 Update FormulaTest.lean
- [ ] `task_update_formula_test`: Update LogosTest/Core/Syntax/FormulaTest.lean
  - Goal: Replace old temporal operator references
  - Strategy: sed-style replacements with build verification
  - Complexity: Simple
  - Changes needed:
    - Line 36: `Formula.past` → `Formula.all_past`
    - Line 39: `Formula.future` → `Formula.all_future`
    - Lines 92-97: `sometime_past`/`sometime_future` → `some_past`/`some_future`
    - Line 159: `swap_past_future` → `swap_temporal`

##### 4.2 Update ContextTest.lean
- [ ] `task_update_context_test`: Update LogosTest/Core/Syntax/ContextTest.lean
  - Goal: Replace `Formula.future` references
  - Strategy: Direct replacement
  - Complexity: Simple
  - Changes needed:
    - Lines 73-74: `Formula.future` → `Formula.all_future`

##### 4.3 Update DerivationTest.lean
- [ ] `task_update_derivation_test`: Update LogosTest/Core/ProofSystem/DerivationTest.lean
  - Goal: Replace temporal operator references
  - Strategy: Direct replacement
  - Complexity: Simple
  - Changes needed:
    - Lines 45, 55, 60, 65: `Formula.future` → `Formula.all_future`
    - Line 50: `sometime_past` → `some_past`
    - Line 55: `Formula.past` → `Formula.all_past`
    - Line 164: `swap_past_future` → `swap_temporal`

##### 4.4 Update AxiomsTest.lean
- [ ] `task_update_axioms_test`: Update LogosTest/Core/ProofSystem/AxiomsTest.lean
  - Goal: Replace `sometime_past` references
  - Strategy: Direct replacement
  - Complexity: Simple
  - Changes needed:
    - Lines 109, 112: `sometime_past` → `some_past`

##### 4.5 Update SoundnessTest.lean
- [ ] `task_update_soundness_test`: Update LogosTest/Core/Metalogic/SoundnessTest.lean
  - Goal: Replace temporal operator references
  - Strategy: Direct replacement
  - Complexity: Simple
  - Changes needed:
    - Lines 33-34, 57, 85-87: `sometime_past` → `some_past`, `Formula.future` → `Formula.all_future`

##### 4.6 Update TacticsTest.lean
- [ ] `task_update_tactics_test`: Update LogosTest/Core/Automation/TacticsTest.lean
  - Goal: Replace all temporal operator references
  - Strategy: Direct replacement
  - Complexity: Medium (many occurrences)
  - Changes needed:
    - All `Formula.future` → `Formula.all_future`
    - All `sometime_past` → `some_past`

#### Verification
```bash
lake build
grep -rn "Formula\.past\|Formula\.future\|sometime_past\|sometime_future\|swap_past_future" LogosTest/
# Should return no matches
```

---

### Phase 5: Update Archive Examples [COMPLETE]

**Goal**: Update pedagogical examples in Archive/

**Estimated Time**: 30 minutes
**Dependencies**: Phase 4

#### Success Criteria
- [ ] All `sometime_past` replaced with `some_past` in Archive/
- [ ] All `Formula.past`/`Formula.future` replaced in Archive/
- [ ] Examples remain pedagogically clear
- [ ] `lake build` succeeds

#### Tasks

##### 5.1 Update TemporalProofs.lean
- [ ] `task_update_temporal_proofs`: Update Archive/TemporalProofs.lean
  - Goal: Replace all old temporal operator references
  - Strategy: Update comments and code
  - Complexity: Simple
  - Changes needed:
    - Line 15: Update comment `sometime_past` → `some_past`
    - Line 21: Update comment
    - Line 40: Update comment
    - Lines 93-105: `sometime_past` → `some_past`
    - Line 203: `sometime_past` → `some_past`, `.past` → `.all_past`
    - Lines 240, 280: Update references

#### Verification
```bash
lake build
grep -rn "sometime_past\|sometime_future" Archive/
# Should return no matches (except possibly in logos-original/ which is historical)
```

---

### Phase 6: Update Documentation [COMPLETE]

**Goal**: Update all markdown documentation for consistency

**Estimated Time**: 60 minutes
**Dependencies**: Phase 5

#### Success Criteria
- [ ] All documentation uses new operator names
- [ ] Code examples updated to compile with new names
- [ ] H/G/P/F notation documented alongside function names
- [ ] CLAUDE.md updated

#### Tasks

##### 6.1 Update Reference Documentation
- [ ] `task_update_operators_md`: Update Documentation/Reference/OPERATORS.md
  - Goal: Document `all_past`/`all_future`/`some_past`/`some_future`
  - Strategy: Update operator table and code examples
  - Complexity: Simple

- [ ] `task_update_glossary_md`: Update Documentation/Reference/GLOSSARY.md
  - Goal: Update function name column
  - Strategy: Replace `sometime_past`/`sometime_future` with `some_past`/`some_future`
  - Complexity: Simple

##### 6.2 Update User Guide
- [ ] `task_update_architecture_md`: Update Documentation/UserGuide/ARCHITECTURE.md
  - Goal: Update all code examples and definitions
  - Strategy: Replace old names with new names
  - Complexity: Medium (many occurrences)

- [ ] `task_update_tutorial_md`: Update Documentation/UserGuide/TUTORIAL.md
  - Goal: Update temporal operator examples
  - Strategy: Direct replacement
  - Complexity: Simple

- [ ] `task_update_examples_md`: Update Documentation/UserGuide/EXAMPLES.md
  - Goal: Update all temporal operator examples
  - Strategy: Direct replacement
  - Complexity: Simple

- [ ] `task_update_integration_md`: Update Documentation/UserGuide/INTEGRATION.md
  - Goal: Update SMT-LIB export examples
  - Strategy: Direct replacement
  - Complexity: Simple

##### 6.3 Update Development Documentation
- [ ] `task_update_style_guide`: Update Documentation/Development/LEAN_STYLE_GUIDE.md
  - Goal: Update code examples
  - Strategy: Direct replacement
  - Complexity: Simple

- [ ] `task_update_tactic_dev`: Update Documentation/Development/TACTIC_DEVELOPMENT.md
  - Goal: Update code examples
  - Strategy: Direct replacement
  - Complexity: Simple

- [ ] `task_update_metaprogramming`: Update Documentation/Development/METAPROGRAMMING_GUIDE.md
  - Goal: Update pattern matching examples
  - Strategy: Direct replacement
  - Complexity: Simple

- [ ] `task_update_testing_standards`: Update Documentation/Development/TESTING_STANDARDS.md
  - Goal: Update test examples
  - Strategy: Direct replacement
  - Complexity: Simple

##### 6.4 Update Root Documentation
- [ ] `task_update_claude_md`: Update CLAUDE.md
  - Goal: Update temporal operator references in package descriptions
  - Strategy: Direct replacement
  - Complexity: Simple

- [ ] `task_update_todo_md`: Update TODO.md
  - Goal: Mark Task 14 complete
  - Strategy: Update task status
  - Complexity: Simple

#### Verification
```bash
grep -rn "sometime_past\|sometime_future" Documentation/
# Should return no matches
grep -rn "Formula\.past\|Formula\.future" Documentation/
# Should return no matches (new names: Formula.all_past, Formula.all_future)
```

---

### Phase 7: Final Verification [COMPLETE]

**Goal**: Comprehensive verification of all changes

**Estimated Time**: 20 minutes
**Dependencies**: Phase 6

#### Success Criteria
- [ ] `lake build` succeeds
- [ ] No stale references to old operator names anywhere
- [ ] Documentation is consistent
- [ ] Git commit created

#### Tasks

##### 7.1 Build Verification
- [ ] `task_final_build`: Run `lake build`
  - Goal: Verify all code compiles
  - Strategy: Execute build command
  - Complexity: Simple

##### 7.2 Stale Reference Check
- [ ] `task_grep_verification`: Run comprehensive grep checks
  - Goal: Ensure no old names remain
  - Strategy: Execute grep commands
  - Complexity: Simple

```bash
# These should all return no matches:
grep -rn "Formula\.past[^_]" Logos/ LogosTest/ Archive/ Documentation/
grep -rn "Formula\.future[^_]" Logos/ LogosTest/ Archive/ Documentation/
grep -rn "sometime_past\|sometime_future" Logos/ LogosTest/ Archive/ Documentation/
grep -rn "swap_past_future" Logos/ LogosTest/ Archive/ Documentation/
```

##### 7.3 Commit Changes
- [ ] `task_commit_changes`: Commit all changes
  - Goal: Create descriptive commit
  - Strategy: Stage and commit with message
  - Complexity: Simple

#### Verification
```bash
lake build
git status
git diff --stat
```

---

## Rollback Plan

If issues arise:
1. **Test failures**: `git checkout -- LogosTest/`
2. **Archive issues**: `git checkout -- Archive/`
3. **Documentation issues**: `git checkout -- Documentation/ CLAUDE.md`
4. **Complete rollback**: `git reset --hard HEAD`

---

## Notes

### Build Status
The project currently builds successfully. All Lean source files in Logos/Core/ have been updated in Phases 1-3.

### Test Status
Tests cannot be run (`lake test` reports "no test driver configured"), but the test files should compile after updates.

### Backward Compatibility
The source files include backward-compatible aliases (`sometime_past`, `sometime_future`), so test files will compile even before updates. However, documentation should use the new canonical names.

---

**Plan Ready for Implementation**

Use `/lean-implement 002-temporal-refactor-completion-plan.md` to execute this plan.
