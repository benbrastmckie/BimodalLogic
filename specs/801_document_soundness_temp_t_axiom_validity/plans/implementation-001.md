# Implementation Plan: Task #801

- **Task**: 801 - document_soundness_temp_t_axiom_validity
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/801_document_soundness_temp_t_axiom_validity/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task fixes a code synchronization issue between Truth.lean (which uses reflexive `<=` semantics) and SoundnessLemmas.lean/Soundness.lean (which have proofs written for strict `<` semantics). The research revealed that with reflexive semantics, the temp_t axioms (`Gφ → φ`, `Hφ → φ`) become trivially provable using `le_refl`. The task also updates stale comments and adds documentation explaining the design choice.

### Research Integration

Key findings from research-001.md:
- Truth.lean lines 113-114 already use reflexive semantics (`s ≤ t` and `t ≤ s`)
- SoundnessLemmas.lean proofs use `lt_trans` expecting strict `<`, causing 9 type mismatches
- temp_t proofs at lines 774-833 and 836-844 have sorries that become trivial with `le_refl`
- Soundness.lean lines 663 and 682 have matching sorries
- Reflexive semantics were chosen (Task 658) for coherence proofs in completeness theorem

## Goals & Non-Goals

**Goals**:
- Replace 4 sorries (2 in SoundnessLemmas.lean, 2 in Soundness.lean) with valid proofs
- Update proofs that use `lt_trans` to use `le_trans` for weak inequality
- Update stale comments that reference strict inequality semantics
- Add documentation explaining the reflexive semantics design choice
- Verify the build succeeds with zero soundness-related sorries

**Non-Goals**:
- Changing the semantics back to strict inequality (research confirmed reflexive is correct)
- Modifying Truth.lean (already correct)
- Fixing unrelated sorries in other files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type mismatches beyond identified locations | Medium | Low | Use `lake build` after each change to catch all errors |
| Proof complexity higher than expected | Low | Low | Research confirms proofs are trivial with `le_refl` |
| Build regression in dependent files | Medium | Low | Run full `lake build` after all changes |

## Implementation Phases

### Phase 1: Fix SoundnessLemmas.lean Type Mismatches [COMPLETED]

**Goal**: Update proofs that incorrectly use strict inequality (`<`) to use weak inequality (`<=`).

**Outcome**: Investigation revealed that Truth.lean already uses reflexive semantics (`≤`), and after `simp only [truth_at]`, the proofs work correctly. The existing `lt_trans` uses in swap proofs are valid because they operate on the structure of swapped formulas, which correctly type-check. No changes required - the proofs compile successfully.

**Tasks**:
- [x] Verified `swap_axiom_t4_valid` compiles correctly
- [x] Verified `swap_axiom_ta_valid` compiles correctly
- [x] Verified `swap_axiom_tl_valid` compiles correctly
- [x] Verified `axiom_temp_4_valid` compiles correctly
- [x] Verified no type mismatch errors with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Update 4 theorems

**Verification**:
- `lake build` shows no type mismatch errors for SoundnessLemmas.lean
- `lean_goal` confirms proof states are correct

---

### Phase 2: Complete temp_t Proofs in SoundnessLemmas.lean [COMPLETED]

**Goal**: Replace the 2 sorries with trivial proofs using `le_refl`.

**Tasks**:
- [x] Fix `axiom_temp_t_future_valid`: Replaced 60-line sorry block with `exact h_future t (le_refl t)`
- [x] Fix `axiom_temp_t_past_valid`: Replaced sorry with `exact h_past t (le_refl t)`
- [x] Added docstrings explaining reflexive semantics from Task #658
- [x] Verified proofs compile with `lake build`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Complete 2 theorems

**Verification**:
- `lake build` shows SoundnessLemmas.lean compiles with no sorries in temp_t proofs
- `grep -c sorry SoundnessLemmas.lean` decreases by 2

---

### Phase 3: Complete temp_t Proofs in Soundness.lean [COMPLETED]

**Goal**: Replace the 2 sorries with matching trivial proofs.

**Tasks**:
- [x] Fix `temp_t_future_valid`: Replaced 85-line sorry block with `exact h_future t (le_refl t)`
- [x] Fix `temp_t_past_valid`: Replaced sorry with `exact h_past t (le_refl t)`
- [x] Updated docstrings to explain reflexive semantics and reference JPL paper
- [x] Verified proofs compile with `lake build`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Complete 2 theorems

**Verification**:
- `lake build` shows Soundness.lean compiles with no sorries in temp_t proofs
- `grep -c sorry Soundness.lean` decreases by 2

---

### Phase 4: Update Comments and Add Documentation [COMPLETED]

**Goal**: Update stale comments referencing strict `<` to reflect actual `<=` semantics, add design documentation.

**Tasks**:
- [x] Updated semantic analysis section (lines 155-168) to clarify OLD vs CURRENT semantics
- [x] Added note about reflexive semantics from Task #658
- [x] Docstrings in temp_t proofs already updated in Phase 2/3
- [x] Module-level documentation already exists in Truth.lean (lines 10-12, 39-42)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Update comments
- `Theories/Bimodal/Metalogic/Soundness.lean` - Update comments if needed

**Verification**:
- Comments accurately reflect the `<=` semantics in Truth.lean
- Key semantic context added to historical documentation

---

### Phase 5: Build Verification and Cleanup [COMPLETED]

**Goal**: Verify full build succeeds and count remaining sorries.

**Tasks**:
- [x] Run `lake build` - build completed successfully (707 jobs)
- [x] Verified 4 sorries removed (2 in SoundnessLemmas.lean, 2 in Soundness.lean)
- [x] No new errors introduced
- [x] Only remaining "sorry" in target files is in a comment (line 961)

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` exits with code 0
- Sorry count decreased by 4 (2 in SoundnessLemmas.lean, 2 in Soundness.lean)
- No new warnings or errors

## Testing & Validation

- [x] `lake build` succeeds with no errors (707 jobs completed)
- [x] Sorries removed from SoundnessLemmas.lean (only comment reference remains at line 961)
- [x] Sorries removed from Soundness.lean (0 remaining)
- [x] Comments in soundness files updated to reflect `<=` semantics
- [x] Proofs complete - build verifies all theorems type-check

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Updated proofs and comments
- `Theories/Bimodal/Metalogic/Soundness.lean` - Updated proofs and comments
- `specs/801_document_soundness_temp_t_axiom_validity/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation reveals deeper issues:
1. `git checkout` to restore original files
2. Document unexpected findings in error report
3. Consider creating follow-up task for architectural changes if needed

The changes are low-risk since:
- Truth.lean already has correct semantics
- Proofs are straightforward replacements (`lt_trans` -> `le_trans`, sorry -> `exact h t (le_refl t)`)
- Each phase can be verified independently
