# Implementation Plan: Remove Misleading Omega-Rule Comments

- **Task**: 858 - Remove misleading omega-rule comments from Bundle/ modules
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: Task 857 (temporal_backward_G/H properties)
- **Research Inputs**: specs/858_remove_omega_rule_misleading_comments/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

This task removes misleading comments that claim omega-saturation is a "fundamental limitation" for proving temporal backward directions (G/H operators). The research report identifies that the Bundled approach uses structural properties (like modal_backward) rather than omega-saturation. Task 857 adds the analogous temporal_backward_G/H properties, enabling the same proof pattern. This task updates all affected documentation to reflect the accurate technical explanation.

### Research Integration

From research-001.md:
- Identified 3 files with misleading comments: TruthLemma.lean (primary), Completeness.lean, README.md
- Documented exact line locations and replacement text for each
- Key insight: temporal backward uses MCS maximality by contraposition, same as modal_backward
- The omega-rule characterization is incorrect because the proof is structural, not infinitary

## Goals & Non-Goals

**Goals**:
- Remove all references to omega-saturation as being "required" for temporal backward
- Replace misleading comments with accurate technical explanations
- Reference Task 857 as the solution providing temporal_backward_G/H properties
- Correct the sorry count in Completeness.lean (4 -> 2)

**Non-Goals**:
- Modifying any proof code (this is documentation only)
- Resolving the sorries themselves (that is Task 857's responsibility)
- Restructuring file organization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect line numbers from research | Medium | Low | Verify line numbers before editing; use surrounding context |
| Doc comments break compilation | Medium | Low | Run `lake build` after changes to verify no syntax errors |
| Missing additional misleading comments | Low | Low | Grep for "omega" terms before marking complete |

## Implementation Phases

### Phase 1: Update TruthLemma.lean Module Docstring [COMPLETED]

**Goal**: Replace the misleading omega-saturation section in the module-level documentation

**Tasks**:
- [ ] Read TruthLemma.lean to verify line numbers
- [ ] Replace lines 58-77 (module docstring section) with corrected explanation
- [ ] Verify the file compiles with `lake build`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Module docstring section

**Verification**:
- Module docstring no longer mentions omega-saturation as "required"
- New text explains temporal_backward_G/H structural approach
- File compiles without errors

---

### Phase 2: Update TruthLemma.lean Inline Comments [COMPLETED]

**Goal**: Replace mid-file notes and sorry-location comments with accurate explanations

**Tasks**:
- [ ] Replace mid-file note (around lines 145-155) with structural property explanation
- [ ] Replace comment at line 381 (G backward sorry) with Task 857 reference
- [ ] Replace comment at line 393 (H backward sorry) with Task 857 reference
- [ ] Replace summary section (around lines 445-450) with corrected characterization
- [ ] Verify the file compiles

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Inline comments at 4 locations

**Verification**:
- All sorry comments reference Task 857, not omega-saturation
- Mid-file note explains structural property approach
- Summary section removes "fundamental limitation" language

---

### Phase 3: Update Completeness.lean and README.md [COMPLETED]

**Goal**: Correct the supporting documentation files

**Tasks**:
- [ ] Update Completeness.lean line 445 to reference "pending Task 857" instead of "(omega-saturation)"
- [ ] Correct the sorry count from 4 to 2 in Completeness.lean
- [ ] Update README.md line 164 to reference "temporal_backward_G/H properties (Task 857)"
- [ ] Verify both files compile/render correctly

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Line 445
- `Theories/Bimodal/Metalogic/Bundle/README.md` - Line 164

**Verification**:
- Completeness.lean sorry count is accurate (2, not 4)
- README.md future work section references Task 857 approach
- Both files compile/render without errors

---

### Phase 4: Verify and Final Validation [COMPLETED]

**Goal**: Ensure all misleading comments are removed and build is clean

**Tasks**:
- [ ] Run `grep -r "omega-saturation" Theories/Bimodal/Metalogic/Bundle/` to find any remaining references
- [ ] Run `grep -r "omega-rule" Theories/Bimodal/Metalogic/Bundle/` to find any remaining references
- [ ] Run `grep -r "fundamental limitation" Theories/Bimodal/Metalogic/Bundle/` to find any remaining incorrect claims
- [ ] Run `lake build Theories/Bimodal/Metalogic/Bundle/` to verify clean build
- [ ] Create implementation summary

**Timing**: 10 minutes

**Files to modify**:
- None (validation only)
- `specs/858_remove_omega_rule_misleading_comments/summaries/implementation-summary-YYYYMMDD.md` - Create summary

**Verification**:
- No remaining misleading omega-saturation language
- Clean build of Bundle/ modules
- Implementation summary documents all changes

## Testing & Validation

- [ ] All modified .lean files compile without errors
- [ ] No grep matches for "omega-saturation" in Bundle/ (except accurate historical mentions)
- [ ] No grep matches for "fundamental limitation" in temporal backward context
- [ ] README.md renders correctly with updated future work section

## Artifacts & Outputs

- `specs/858_remove_omega_rule_misleading_comments/plans/implementation-001.md` (this file)
- `specs/858_remove_omega_rule_misleading_comments/summaries/implementation-summary-YYYYMMDD.md` (created at completion)

## Rollback/Contingency

All changes are documentation-only (comments and docstrings). If issues arise:
1. Git revert to the pre-implementation commit
2. No proof code is affected, so no logical rollback needed
3. Changes can be re-applied incrementally if needed
