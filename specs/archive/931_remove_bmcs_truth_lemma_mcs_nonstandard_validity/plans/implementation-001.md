# Implementation Plan: Task #931

- **Task**: 931 - remove_bmcs_truth_lemma_mcs_nonstandard_validity
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove all non-standard MCS-membership validity definitions from `ChainBundleBFMCS.lean` and archive them in Boneyard with a ban notice. The research report identified exactly 14 symbols (4 definitions, 10 theorems) on lines 350-691 that use a non-standard box semantics (`phi in fam'.mcs t` instead of recursive truth). These have zero external dependents and can be safely removed. The valuable CanonicalBC construction (lines 1-349) will be preserved.

### Research Integration

Key findings from research-001.md:
- All 14 non-standard `_mcs` symbols are in ONE file: `ChainBundleBFMCS.lean`
- Lines 350-691 (341 lines) to be removed
- Zero external dependents confirmed
- Lines 1-349 contain valuable sorry-free infrastructure to KEEP
- Boneyard target: `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean`

## Goals & Non-Goals

**Goals**:
- Remove all 14 non-standard `_mcs` symbols from active codebase
- Archive removed code to Boneyard with ban notice explaining why this approach is forbidden
- Update module docstrings to reflect reduced scope
- Verify `lake build` passes after changes
- Ensure no references to `_mcs` symbols remain in Metalogic module

**Non-Goals**:
- Remove dead `eval_bmcs_*` code from BFMCSTruth.lean (separate cleanup task)
- Modify any standard validity definitions
- Change the CanonicalBC construction (lines 1-349)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependency on _mcs symbols | Medium | Low | Research confirmed zero external dependents; verify with grep |
| Import removal breaks build | Low | Low | Keep all imports initially; let lake build determine safe removals |
| Incomplete removal leaves traces | Medium | Low | Final grep verification for _mcs symbols |

## Sorry Characterization

### Pre-existing Sorries
- None in scope. The `_mcs` code being removed is complete (no sorries).
- Lines 1-349 being preserved are sorry-free.

### Expected Resolution
- N/A (removal task, not proof completion)

### New Sorries
- None. This is a removal task. NEVER introduce new sorries.

### Remaining Debt
- After this implementation: 0 new sorries introduced
- No changes to existing sorry count in Metalogic module

## Implementation Phases

### Phase 1: Pre-flight Verification [NOT STARTED]

- **Dependencies:** None
- **Goal:** Confirm current build state and exact line numbers

**Tasks:**
- [ ] Run `lake build` to confirm clean starting state
- [ ] Read `ChainBundleBFMCS.lean` to verify lines 350-691 contain all _mcs code
- [ ] Verify no external files import or reference `_mcs` symbols with grep

**Timing:** 10 minutes

**Files to examine:**
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` - verify line numbers

**Verification:**
- `lake build` passes
- Lines 350-691 boundaries confirmed
- `grep -rn "_mcs" Theories/` shows only ChainBundleBFMCS.lean

---

### Phase 2: Create Boneyard File [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Archive non-standard code with ban notice

**Tasks:**
- [ ] Create `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean`
- [ ] Add comprehensive ban notice header explaining why MCS-membership box semantics is forbidden
- [ ] Copy lines 350-691 from ChainBundleBFMCS.lean (with necessary imports)
- [ ] Comment out imports that would cause build issues

**Timing:** 15 minutes

**Files to create:**
- `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean` - archived code with ban notice

**Verification:**
- File exists with proper header
- All 14 `_mcs` symbols present in archived file
- Ban notice clearly explains the problem with this approach

---

### Phase 3: Remove from ChainBundleBFMCS.lean [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Delete non-standard code from active codebase

**Tasks:**
- [ ] Delete lines 350-691 (all `_mcs` definitions and theorems)
- [ ] Delete the "Modified Truth Definition" section header and subsequent section headers
- [ ] Verify remaining code (lines 1-349) is intact
- [ ] Run `lake build` to confirm remaining code compiles

**Timing:** 15 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` - delete lines 350-691

**Verification:**
- `lake build` passes
- File ends around line 350
- `grep -n "_mcs" ChainBundleBFMCS.lean` returns empty

---

### Phase 4: Update Documentation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Remove references to deleted definitions from docstrings

**Tasks:**
- [ ] Update module docstring in ChainBundleBFMCS.lean to remove _mcs references
- [ ] Check and update `Metalogic.lean` documentation comment (line 64) if it references removed symbols
- [ ] Verify no other documentation in Metalogic/ references _mcs symbols

**Timing:** 10 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` - update module docstring
- `Theories/Bimodal/Metalogic/Metalogic.lean` - update doc comment if needed

**Verification:**
- Module docstrings accurately describe remaining code
- No dangling references to removed symbols in documentation

---

### Phase 5: Final Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Confirm complete removal and clean build

**Tasks:**
- [ ] Run `lake build` - must pass with no errors
- [ ] Run `grep -rn "_mcs" Theories/Bimodal/Metalogic/` - must return empty (excluding Boneyard)
- [ ] Verify `bmcs_truth_at_mcs`, `bmcs_valid_mcs`, `bmcs_consequence_mcs`, `ContextDerivable_mcs` are ONLY in Boneyard
- [ ] Verify no sorries were introduced: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean`

**Timing:** 10 minutes

**Files to verify:**
- All files in `Theories/Bimodal/Metalogic/` (excluding Boneyard)

**Verification:**
- `lake build` passes with no errors
- Zero `_mcs` references in active Metalogic code
- Zero new sorries introduced
- All 14 symbols present in Boneyard file only

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` returns empty (no new sorries)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` shows no new axioms
- [ ] All remaining proofs verified (implicitly via lake build)

### Removal-Specific Verification
- [ ] `grep -rn "_mcs" Theories/Bimodal/Metalogic/` returns only Boneyard matches
- [ ] `grep -rn "bmcs_truth_at_mcs\|bmcs_valid_mcs\|bmcs_consequence_mcs\|ContextDerivable_mcs" Theories/Bimodal/Metalogic/` returns only Boneyard matches
- [ ] Boneyard file contains ban notice with clear explanation

## Artifacts & Outputs

- `specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/plans/implementation-001.md` (this file)
- `specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/summaries/implementation-summary-YYYYMMDD.md` (upon completion)
- `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean` (new archived file)

## Rollback/Contingency

If removal causes unexpected build failures:
1. Restore deleted lines from git history: `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean`
2. Investigate which external file unexpectedly depends on _mcs symbols
3. Update research report with new findings
4. Revise plan to handle the dependency

The Boneyard file can be deleted if the removal is rolled back, as it's purely archival.
