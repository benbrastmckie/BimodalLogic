# Implementation Plan: Task #931 (v2)

- **Task**: 931 - remove_bmcs_truth_lemma_mcs_nonstandard_validity
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Notes**: Added Phase 3B to remove dead `eval_bmcs_*` code from BFMCSTruth.lean

## Overview

Remove all non-standard MCS-membership validity definitions from `ChainBundleBFMCS.lean` AND dead `eval_bmcs_*` code from `BFMCSTruth.lean`. Archive both in Boneyard with ban notices. The research report identified:
- 14 symbols (4 definitions, 10 theorems) on lines 350-691 in ChainBundleBFMCS.lean
- Dead `eval_bmcs_*` code in BFMCSTruth.lean (lines 334-477, per research-001.md)

### Research Integration

Key findings from research-001.md:
- All 14 non-standard `_mcs` symbols are in ONE file: `ChainBundleBFMCS.lean`
- Lines 350-691 (341 lines) to be removed
- Zero external dependents confirmed
- Lines 1-349 contain valuable sorry-free infrastructure to KEEP
- Dead `eval_bmcs_*` code in `BFMCSTruth.lean` (lines 334-477) is unused but uses standard semantics
- Boneyard target: `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean`

## Goals & Non-Goals

**Goals**:
- Remove all 14 non-standard `_mcs` symbols from ChainBundleBFMCS.lean
- Remove dead `eval_bmcs_*` code from BFMCSTruth.lean
- Archive removed code to Boneyard with ban notice explaining why these approaches are forbidden
- Update module docstrings to reflect reduced scope
- Verify `lake build` passes after changes
- Ensure no references to `_mcs` symbols remain in Metalogic module

**Non-Goals**:
- Modify any standard validity definitions
- Change the CanonicalBC construction (lines 1-349)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependency on _mcs symbols | Medium | Low | Research confirmed zero external dependents; verify with grep |
| Hidden dependency on eval_bmcs_* | Medium | Low | Verify with grep before removal |
| Import removal breaks build | Low | Low | Keep all imports initially; let lake build determine safe removals |
| Incomplete removal leaves traces | Medium | Low | Final grep verification |

## Sorry Characterization

### Pre-existing Sorries
- None in scope. The code being removed is complete (no sorries).
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
- [ ] Read `BFMCSTruth.lean` to identify exact line numbers for `eval_bmcs_*` code
- [ ] Verify no external files import or reference `_mcs` or `eval_bmcs_*` symbols with grep

**Timing:** 10 minutes

**Files to examine:**
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` - verify line numbers
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - identify eval_bmcs_* boundaries

**Verification:**
- `lake build` passes
- Lines 350-691 boundaries confirmed in ChainBundleBFMCS.lean
- `eval_bmcs_*` boundaries confirmed in BFMCSTruth.lean
- `grep -rn "_mcs\|eval_bmcs" Theories/` shows only target files

---

### Phase 2: Create Boneyard File [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Archive non-standard code with ban notice

**Tasks:**
- [ ] Create `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean`
- [ ] Add comprehensive ban notice header explaining why MCS-membership box semantics is forbidden
- [ ] Copy lines 350-691 from ChainBundleBFMCS.lean (with necessary imports)
- [ ] Add section for `eval_bmcs_*` code from BFMCSTruth.lean with its own ban notice
- [ ] Comment out imports that would cause build issues

**Timing:** 20 minutes

**Files to create:**
- `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean` - archived code with ban notices

**Verification:**
- File exists with proper headers
- All 14 `_mcs` symbols present in archived file
- All `eval_bmcs_*` symbols present in archived file
- Ban notices clearly explain the problems with these approaches

---

### Phase 3A: Remove _mcs code from ChainBundleBFMCS.lean [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Delete non-standard _mcs code from active codebase

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

### Phase 3B: Remove eval_bmcs_* code from BFMCSTruth.lean [NOT STARTED]

- **Dependencies:** Phase 3A
- **Goal:** Delete dead eval_bmcs_* code from active codebase

**Tasks:**
- [ ] Identify exact boundaries of `eval_bmcs_*` code section
- [ ] Delete the section (expected lines ~334-477)
- [ ] Verify remaining code is intact
- [ ] Run `lake build` to confirm remaining code compiles

**Timing:** 15 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - delete eval_bmcs_* section

**Verification:**
- `lake build` passes
- `grep -n "eval_bmcs" BFMCSTruth.lean` returns empty

---

### Phase 4: Update Documentation [NOT STARTED]

- **Dependencies:** Phase 3B
- **Goal:** Remove references to deleted definitions from docstrings

**Tasks:**
- [ ] Update module docstring in ChainBundleBFMCS.lean to remove _mcs references
- [ ] Update module docstring in BFMCSTruth.lean to remove eval_bmcs_* references
- [ ] Check and update `Metalogic.lean` documentation comment if it references removed symbols
- [ ] Verify no other documentation in Metalogic/ references removed symbols

**Timing:** 10 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` - update module docstring
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - update module docstring
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
- [ ] Run `grep -rn "_mcs\|eval_bmcs" Theories/Bimodal/Metalogic/` - must return empty (excluding Boneyard)
- [ ] Verify all removed symbols are ONLY in Boneyard
- [ ] Verify no sorries were introduced

**Timing:** 10 minutes

**Files to verify:**
- All files in `Theories/Bimodal/Metalogic/` (excluding Boneyard)

**Verification:**
- `lake build` passes with no errors
- Zero `_mcs` or `eval_bmcs` references in active Metalogic code
- Zero new sorries introduced
- All removed symbols present in Boneyard file only

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` shows no new sorries
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/` shows no new axioms
- [ ] All remaining proofs verified (implicitly via lake build)

### Removal-Specific Verification
- [ ] `grep -rn "_mcs\|eval_bmcs" Theories/Bimodal/Metalogic/` returns only Boneyard matches
- [ ] Boneyard file contains ban notices with clear explanations

## Artifacts & Outputs

- `specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/plans/implementation-002.md` (this file)
- `specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/summaries/implementation-summary-YYYYMMDD.md` (upon completion)
- `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean` (new archived file)

## Rollback/Contingency

If removal causes unexpected build failures:
1. Restore deleted code from git history
2. Investigate which external file unexpectedly depends on removed symbols
3. Update research report with new findings
4. Revise plan to handle the dependency

The Boneyard file can be deleted if the removal is rolled back, as it's purely archival.
