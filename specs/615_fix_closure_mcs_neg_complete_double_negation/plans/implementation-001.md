# Implementation Plan: Task #615

- **Task**: 615 - Fix closure_mcs_neg_complete double negation edge case
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/615_fix_closure_mcs_neg_complete_double_negation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix the sorry in `closure_mcs_neg_complete` theorem at Closure.lean:484 by restricting the theorem hypothesis from `psi in closureWithNeg phi` to `psi in closure phi`. This eliminates the double negation edge case where `chi.neg.neg` is not in `closureWithNeg`. The fix follows the working pattern from the old Metalogic's `closure_mcs_negation_complete` theorem at FiniteCanonicalModel.lean:713.

### Research Integration

From research-001.md:
- The problem occurs when `psi = chi.neg` for `chi in closure`, because `psi.neg = chi.neg.neg` is NOT in `closureWithNeg`
- The old Metalogic restricts to `psi in closure phi`, avoiding the issue entirely
- Callers in `closure_mcs_imp_iff` already have `closure` membership available via `closure_imp_left` and `closure_imp_right`

## Goals & Non-Goals

**Goals**:
- Remove the sorry at Closure.lean:484
- Maintain correctness of dependent theorems (`closure_mcs_imp_iff`)
- Follow existing proof patterns from old Metalogic

**Non-Goals**:
- Extending `closureWithNeg` to include double negations (rejected due to ripple effects)
- Restructuring the completeness proof architecture
- Modifying any theorems outside Closure.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Caller signature mismatch | Medium | Low | Callers already have `closure` membership via `h_imp_clos` |
| Proof structure changes | Low | Low | Follow old Metalogic pattern exactly |
| Build failures | Medium | Low | Incremental changes with `lean_diagnostic_messages` checks |

## Implementation Phases

### Phase 1: Modify Theorem Signature [COMPLETED]

**Goal**: Change `closure_mcs_neg_complete` hypothesis from `closureWithNeg` to `closure`

**Tasks**:
- [ ] Change parameter `h_clos : psi in closureWithNeg phi` to `h_clos : psi in closure phi`
- [ ] Update the theorem docstring to reflect the new constraint
- [ ] Verify the signature change compiles (expect proof to break)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - line 266-267

**Verification**:
- Run `lean_diagnostic_messages` to confirm signature is valid
- Proof body will now have errors (expected)

---

### Phase 2: Fix the Proof Body [COMPLETED]

**Goal**: Complete the proof without sorry by leveraging the restricted hypothesis

**Tasks**:
- [ ] Add `have h_neg : psi.neg in closureWithNeg phi := closureWithNeg_neg_mem h_clos` early in proof
- [ ] Use `closure_subset_closureWithNeg` to get `psi in closureWithNeg phi` from `h_clos`
- [ ] Remove Case 2 (chi.neg case) entirely - no longer applicable with restricted hypothesis
- [ ] Simplify proof structure following old Metalogic pattern
- [ ] Remove the sorry at line 484
- [ ] Verify with `lean_goal` at key proof points

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - lines 266-534

**Verification**:
- `lean_diagnostic_messages` shows no errors in theorem
- `lean_goal` shows "no goals" at proof end
- No sorry remains in theorem

---

### Phase 3: Update Callers [COMPLETED]

**Goal**: Update `closure_mcs_imp_iff` to use `closure` membership instead of `closureWithNeg`

**Tasks**:
- [ ] At line 798: Replace `h_chi_clos` with `closure_imp_right phi psi chi h_imp_clos`
- [ ] At line 834: Use `h_imp_clos` directly (already `closure` membership)
- [ ] At line 844: Replace `h_psi_clos` with `closure_imp_left phi psi chi h_imp_clos`
- [ ] Remove now-unnecessary `h_psi_clos : psi in closureWithNeg phi` and `h_chi_clos : chi in closureWithNeg phi` parameters from theorem signature if not used elsewhere

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - lines 784-933

**Verification**:
- `lean_diagnostic_messages` shows no errors in `closure_mcs_imp_iff`
- All caller sites compile successfully

---

### Phase 4: Verification and Cleanup [COMPLETED]

**Goal**: Ensure the entire file builds without errors or sorries

**Tasks**:
- [ ] Run `lake build Logos.Theories.Bimodal.Metalogic_v2.Representation.Closure`
- [ ] Search for any remaining `sorry` in Closure.lean
- [ ] Verify no new warnings introduced
- [ ] Remove any obsolete comments about the double negation edge case
- [ ] Update README.md if it documents this as a known sorry

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - cleanup comments
- `Theories/Bimodal/Metalogic_v2/README.md` - remove known issue if documented

**Verification**:
- `lake build` succeeds
- `grep -n "sorry" Closure.lean` returns no matches for this theorem
- No regression in dependent theorems

## Testing & Validation

- [ ] `lean_diagnostic_messages` shows no errors in modified file
- [ ] `lake build` completes successfully for the module
- [ ] No new sorries introduced
- [ ] `closure_mcs_imp_iff` theorem still compiles and proves correctly
- [ ] Check downstream dependencies (if any) still build

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - modified theorem and callers
- `specs/615_fix_closure_mcs_neg_complete_double_negation/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If the restricted hypothesis breaks downstream theorems:
1. Revert signature change
2. Create new theorem `closure_mcs_neg_complete_closure` with restricted hypothesis
3. Keep original theorem with sorry for `closureWithNeg` case
4. Gradually migrate callers to use the new theorem
