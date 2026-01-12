# Implementation Plan: Task #357

**Task**: Fix ModalS5.lean noncomputable cascade
**Version**: 001
**Created**: 2026-01-10
**Language**: lean

## Overview

Add `noncomputable` keyword to 5 definitions in `Bimodal/Theorems/ModalS5.lean` that depend on noncomputable functions from `Propositional.lean`. This is a straightforward fix requiring only keyword additions at specific line numbers.

## Phases

### Phase 1: Add noncomputable markers

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add `noncomputable` keyword to all 5 affected definitions
2. Verify the build succeeds with no errors

**Files to modify**:
- `Bimodal/Theorems/ModalS5.lean` - Add `noncomputable` to 5 definitions

**Steps**:
1. Add `noncomputable` to `classical_merge` (line 63)
   - Change: `def classical_merge` → `noncomputable def classical_merge`

2. Add `noncomputable` to `box_disj_intro` (line 203)
   - Change: `def box_disj_intro` → `noncomputable def box_disj_intro`

3. Add `noncomputable` to `box_iff_intro` (line 379)
   - Change: `def box_iff_intro` → `noncomputable def box_iff_intro`

4. Add `noncomputable` to `box_conj_iff` (line 514)
   - Change: `def box_conj_iff` → `noncomputable def box_conj_iff`

5. Add `noncomputable` to `diamond_disj_iff` (line 621)
   - Change: `def diamond_disj_iff` → `noncomputable def diamond_disj_iff`

6. Run `lake build Bimodal.Theorems.ModalS5` to verify no errors

**Verification**:
- `lean_diagnostic_messages` shows no errors for ModalS5.lean
- `lake build Bimodal.Theorems.ModalS5` succeeds

---

## Dependencies

- None - this is a standalone fix

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Additional definitions need marking | Low | Low | Check for cascade errors after fix |
| Breaks downstream code | Low | Very Low | These are proof terms, not runtime code |

## Success Criteria

- [ ] All 5 definitions have `noncomputable` keyword
- [ ] `lean_diagnostic_messages` returns 0 errors for ModalS5.lean (excluding the existing `sorry` warning)
- [ ] `lake build Bimodal.Theorems.ModalS5` succeeds

## Rollback Plan

Revert the 5 edits by removing the `noncomputable` keyword from each definition. The file is under git version control.
