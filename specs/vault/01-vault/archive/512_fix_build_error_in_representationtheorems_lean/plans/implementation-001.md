# Implementation Plan: Fix Build Error in RepresentationTheorems.lean

## METADATA
- **Task Number**: 512
- **Task Description**: Fix build error in RepresentationTheorems.lean
- **Language**: lean
- **Proof Strategy**: Type correction and variable renaming
- **Complexity**: simple
- **Total Estimated Effort Hours**: 0.5
- **Research Integrated**: true
- **Research Report**: [specs/512_fix_build_error_in_representationtheorems_lean/reports/research-001.md](../reports/research-001.md)

## OVERVIEW

### Problem Statement
Fix the application type mismatch error in `RepresentationTheorems.lean` at line 110. The function `h_entails` expects a `TaskFrame D` as its second argument, but variable `F` has type `AddCommGroup D` due to incorrect variable binding.

### Scope
- Fix the type mismatch in `representation_theorem_backward_empty` theorem
- Ensure proper variable binding with correct types
- Verify build success after fix

### Lean-Specific Constraints
- Must respect Lean's type class inference system
- Variable binding must match `semantic_consequence` signature
- No changes to public API or theorem logic

### Definition of Done
- [ ] Build error resolved with no type mismatches
- [ ] Lake build RepresentationTheorems.lean succeeds
- [ ] No regressions in existing functionality
- [ ] Variable types correctly aligned with function signatures

## PROOF STRATEGY

### High-Level Approach
Direct type correction through proper variable binding. The issue is a variable name conflict where `F` is being interpreted as a type class instance instead of a `TaskFrame`.

### Key Tactics to Use
- `intro` with explicit type annotations
- Variable renaming to avoid conflicts
- Type-directed variable binding

### Mathlib Theorems to Leverage
- None required (internal type fixing)

### Potential Pitfalls and Mitigation
- **Pitfall**: Variable name conflicts with type classes
  **Mitigation**: Use explicit type annotations or different variable names
- **Pitfall**: Breaking existing theorem logic
  **Mitigation**: Preserve exact logical structure, only fix types

## IMPLEMENTATION PHASES

### Phase 1: Analyze Current Variable Binding
- [NOT STARTED]
**Objective**: Understand current variable introduction and type inference
**Lean-Specific Tasks**:
- Examine `intro D F M τ t` pattern in theorem
- Identify type class inference causing `F : AddCommGroup D`
- Document expected vs actual types

**Acceptance Criteria**: Variable binding issue clearly documented
**Estimated Hours**: 0.25

### Phase 2: Fix Variable Types
- [NOT STARTED]
**Objective**: Correct variable binding to match `semantic_consequence` signature
**Lean-Specific Tasks**:
- Fix variable introduction with proper types
- Ensure `F` has type `TaskFrame D` not `AddCommGroup D`
- Maintain theorem logic unchanged

**Implementation Options**:
1. Use explicit type annotations: `intro (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D)`
2. Use different variable names to avoid conflicts

**Acceptance Criteria**: Variable types match `semantic_consequence` signature
**Estimated Hours**: 0.25

### Phase 3: Verify Build Success
- [NOT STARTED]
**Objective**: Confirm fix resolves build error
**Lean-Specific Tasks**:
- Run `lake build RepresentationTheorems.lean`
- Verify no type mismatch errors
- Check for any new warnings or errors

**Acceptance Criteria**: Clean build with no errors
**Estimated Hours**: 0.25

### Phase 4: Final Validation
- [NOT STARTED]
**Objective**: Ensure no regressions
**Lean-Specific Tasks**:
- Review any new warnings
- Verify theorem logic unchanged
- Check related files still compile

**Acceptance Criteria**: No regressions, clean build
**Estimated Hours**: 0.25

## MATHLIB INTEGRATION

### Required Imports
- None required (existing imports sufficient)

### Relevant Namespaces
- `Bimodal.Semantics.Validity` (for `semantic_consequence`)
- `Bimodal.Metalogic.RepresentationTheorems` (current file)

### API Usage Patterns
- `semantic_consequence` function signature with type classes
- Standard variable binding patterns in Lean theorems

### Version Compatibility Notes
- Compatible with existing mathlib version
- No new dependencies introduced

## TESTING AND VALIDATION

### Type Checking
- **Primary Test**: `lake build RepresentationTheorems.lean`
- **Expected Outcome**: Clean compilation with no errors

### Unit Tests
- None applicable (type fixing only)

### Property Testing
- None applicable (no logic changes)

### Example Usage Verification
- Verify theorem can still be applied correctly
- Check that `semantic_consequence [] φ` usage works as expected

### Documentation Review
- No documentation changes needed
- Variable names should remain clear after fix

## ARTIFACTS

### Lean Source Files
- `Theories/Bimodal/Metalogic/RepresentationTheorems.lean` (lines ~109-110)

### Test Files
- None required

### Documentation
- None required (internal fix)

## ROLLBACK

### Git Commit Strategy
- Single focused commit: "Fix type mismatch in representation_theorem_backward_empty"
- Commit message should reference task number

### Revert Procedure if Fix Blocked
1. If explicit type annotations fail: try variable renaming approach
2. If both approaches fail: research alternative `semantic_consequence` usage patterns
3. Document blocking issues for alternative solutions

### Alternative Approaches if Primary Strategy Fails
- **Approach B**: Use different variable names entirely
- **Approach C**: Restructure theorem to avoid variable binding conflicts
- **Approach D**: Consult existing patterns in other representation theorems

## PHASE SUMMARY

| Phase | Status | Effort (hrs) | Key Deliverable |
|-------|--------|--------------|-----------------|
| Phase 1 | [NOT STARTED] | 0.25 | Variable binding analysis |
| Phase 2 | [NOT STARTED] | 0.25 | Type correction implementation |
| Phase 3 | [NOT STARTED] | 0.25 | Build verification |
| Phase 4 | [NOT STARTED] | 0.25 | Regression testing |
| **Total** | | **1.0** | **Fixed build error** |

*Note: Estimated effort rounded up from 0.5 hours for safety margin*

---

**Next Steps**: Execute Phase 1 to analyze current variable binding and determine optimal fix approach.