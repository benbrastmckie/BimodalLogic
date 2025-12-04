# Implementation Plan: 'Always' Operator Cruft Cleanup

## Metadata

- **Feature**: Clean up cruft from incorrect 'always' operator definition alignment
- **Status**: [NOT STARTED]
- **Complexity**: 2 (Low-Medium)
- **Estimated Hours**: 3-5 hours
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/Logos
- **Lean File**: Logos/Metalogic/Soundness.lean

## Summary

After aligning the `always` operator with the JPL paper definition (`Pφ ∧ φ ∧ Fφ`), the TL, MF, and TF axiom proofs no longer require frame constraints. This plan removes the unused `BackwardPersistence` and `ModalTemporalPersistence` definitions and updates all associated documentation.

## Research References

- [001-always-operator-cruft-analysis.md](../reports/001-always-operator-cruft-analysis.md)

---

## Phase 1: Remove Unused Frame Constraint Definitions [NOT STARTED]

**Objective**: Remove dead code definitions from Soundness.lean

**Lean File**: Logos/Metalogic/Soundness.lean

### Tasks

- [ ] `task_remove_backward_persistence`: Remove BackwardPersistence definition
  - Goal: Delete lines 99-123 (definition and docstring)
  - Strategy: Direct deletion, verify build passes
  - Complexity: Simple
  - Dependencies: []

- [ ] `task_remove_modal_temporal_persistence`: Remove ModalTemporalPersistence definition
  - Goal: Delete lines 125-149 (definition and docstring)
  - Strategy: Direct deletion, verify build passes
  - Complexity: Simple
  - Dependencies: [task_remove_backward_persistence]

### Success Criteria

- [ ] BackwardPersistence definition removed from Soundness.lean
- [ ] ModalTemporalPersistence definition removed from Soundness.lean
- [ ] `lake build` succeeds with zero errors
- [ ] No remaining references to removed definitions in Logos/

### Verification

```bash
# Verify definitions removed
grep -c "def BackwardPersistence" Logos/Metalogic/Soundness.lean  # Should be 0
grep -c "def ModalTemporalPersistence" Logos/Metalogic/Soundness.lean  # Should be 0

# Verify build
lake build
```

---

## Phase 2: Update Soundness.lean Module Docstring [NOT STARTED]

**Objective**: Update the module-level docstring to accurately reflect current implementation

**Lean File**: Logos/Metalogic/Soundness.lean (lines 1-70)

### Tasks

- [ ] `task_update_module_docstring`: Rewrite module docstring
  - Goal: Remove all references to conditional validity and frame constraints
  - Strategy: Edit docstring to reflect that all axioms are now unconditionally proven
  - Complexity: Simple
  - Dependencies: [Phase 1]

### Content Changes

**Remove these sections**:
- "conditionally valid, requiring specific frame properties" (lines 18-20)
- "conditional on BackwardPersistence" references (line 33)
- "conditional on ModalTemporalPersistence" references (lines 34-35)
- "Conditional Proofs" section (lines 44-51)
- "Frame Constraint Analysis" section (lines 52-57)
- "MVP Approach" description (lines 59-62)

**Update to reflect**:
- All 10 axioms are now proven valid unconditionally
- TL uses `always` = `Pφ ∧ φ ∧ Fφ` definition
- MF and TF use time-shift invariance

### Success Criteria

- [ ] No mentions of "frame constraint" in module docstring
- [ ] No mentions of "conditional" validity
- [ ] No mentions of BackwardPersistence or ModalTemporalPersistence
- [ ] Docstring accurately describes all proofs as complete

---

## Phase 3: Update Individual Theorem Docstrings [NOT STARTED]

**Objective**: Update docstrings for temp_l_valid, modal_future_valid, temp_future_valid

**Lean File**: Logos/Metalogic/Soundness.lean

### Tasks

- [ ] `task_update_temp_l_docstring`: Update temp_l_valid docstring (lines 329-346)
  - Goal: Remove conditional language, document actual proof strategy
  - Strategy: Rewrite to explain how `always` definition makes proof trivial
  - Complexity: Simple
  - Dependencies: [Phase 2]

- [ ] `task_update_modal_future_docstring`: Update modal_future_valid docstring (lines 386-407)
  - Goal: Remove "Frame Constraint Required" and MVP approach text
  - Strategy: Document time-shift proof strategy
  - Complexity: Simple
  - Dependencies: [task_update_temp_l_docstring]

- [ ] `task_update_temp_future_docstring`: Update temp_future_valid docstring (lines 434-460)
  - Goal: Remove "Frame Constraint" and MVP approach text
  - Strategy: Document time-shift proof strategy
  - Complexity: Simple
  - Dependencies: [task_update_modal_future_docstring]

### Success Criteria

- [ ] temp_l_valid docstring explains `always` definition proof
- [ ] modal_future_valid docstring documents time-shift strategy
- [ ] temp_future_valid docstring documents time-shift strategy
- [ ] No "Frame Constraint Required" text in any docstring

---

## Phase 4: Update External Documentation [NOT STARTED]

**Objective**: Update CLAUDE.md and related documentation files

### Tasks

- [ ] `task_update_claude_md`: Update CLAUDE.md implementation status
  - Goal: Remove "require frame constraints" from axiom descriptions
  - Strategy: Edit line 191 and related sections
  - Complexity: Simple
  - Dependencies: [Phase 3]

- [ ] `task_review_implementation_status`: Review IMPLEMENTATION_STATUS.md
  - Goal: Update any outdated frame constraint references
  - Strategy: Search and update relevant sections
  - Complexity: Simple
  - Dependencies: [task_update_claude_md]

- [ ] `task_review_known_limitations`: Review KNOWN_LIMITATIONS.md
  - Goal: Remove or update frame constraint limitation sections
  - Strategy: Review and update as needed
  - Complexity: Simple
  - Dependencies: [task_review_implementation_status]

### Success Criteria

- [ ] CLAUDE.md accurately describes axiom proof status
- [ ] IMPLEMENTATION_STATUS.md reflects current state
- [ ] KNOWN_LIMITATIONS.md has no outdated frame constraint info

---

## Phase 5: Final Verification [NOT STARTED]

**Objective**: Ensure all cleanup is complete and consistent

### Tasks

- [ ] `task_final_grep_check`: Search for any remaining cruft
  - Goal: No remaining references to removed definitions
  - Strategy: Grep for BackwardPersistence, ModalTemporalPersistence in source
  - Complexity: Simple
  - Dependencies: [Phase 4]

- [ ] `task_build_and_test`: Run full build and tests
  - Goal: All tests pass
  - Strategy: `lake build && lake test`
  - Complexity: Simple
  - Dependencies: [task_final_grep_check]

### Verification Commands

```bash
# Check no remaining references in source
grep -r "BackwardPersistence" Logos/ --include="*.lean"  # Should be empty
grep -r "ModalTemporalPersistence" Logos/ --include="*.lean"  # Should be empty

# Check documentation
grep -r "require.*frame constraint" Documentation/ CLAUDE.md README.md | grep -v ".claude/"

# Full build and test
lake build && lake test
```

### Success Criteria

- [ ] No remaining BackwardPersistence references in Logos/
- [ ] No remaining ModalTemporalPersistence references in Logos/
- [ ] `lake build` succeeds
- [ ] `lake test` passes (if tests exist)

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Build breaks after removal | Low | Medium | Verify grep shows no usage before deletion |
| Documentation inconsistency | Low | Low | Systematic grep-based review |
| Missing related cruft | Medium | Low | Comprehensive search patterns |

---

## Notes

- The `.claude/specs/` historical files contain references but don't need active cleanup (they're historical artifacts)
- The definitions were never used in actual proofs, only documented as "required"
- After cleanup, the codebase will more accurately reflect the mathematical reality

---

## Completion Checklist

- [ ] Phase 1: Frame constraint definitions removed
- [ ] Phase 2: Module docstring updated
- [ ] Phase 3: Theorem docstrings updated
- [ ] Phase 4: External documentation updated
- [ ] Phase 5: Final verification passed
- [ ] All `lake build` passes
- [ ] No remaining cruft references in source files
