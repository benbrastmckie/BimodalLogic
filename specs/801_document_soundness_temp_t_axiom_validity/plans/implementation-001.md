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

### Phase 1: Fix SoundnessLemmas.lean Type Mismatches [NOT STARTED]

**Goal**: Update proofs that incorrectly use strict inequality (`<`) to use weak inequality (`<=`).

**Tasks**:
- [ ] Update `swap_axiom_t4_valid` (lines 253-264): Replace `lt_trans` with `le_trans`, update variable names from `h_r_lt_t` to `h_r_le_t`
- [ ] Update `swap_axiom_ta_valid` (lines 278-288): Fix type annotations and proof logic for weak inequality
- [ ] Update `swap_axiom_tl_valid` (lines 310-363): Update case analysis from `<` to `<=`
- [ ] Update `axiom_temp_4_valid` (lines 700-706): Replace `lt_trans` with `le_trans`
- [ ] Verify no type mismatch errors with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Update 4 theorems

**Verification**:
- `lake build` shows no type mismatch errors for SoundnessLemmas.lean
- `lean_goal` confirms proof states are correct

---

### Phase 2: Complete temp_t Proofs in SoundnessLemmas.lean [NOT STARTED]

**Goal**: Replace the 2 sorries with trivial proofs using `le_refl`.

**Tasks**:
- [ ] Fix `axiom_temp_t_future_valid` (lines 774-833): Replace sorry with `exact h_future t (le_refl t)`
- [ ] Fix `axiom_temp_t_past_valid` (lines 836-844): Replace sorry with `exact h_past t (le_refl t)`
- [ ] Remove outdated comments about "strict inequality semantics" being invalid
- [ ] Verify proofs compile

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Complete 2 theorems

**Verification**:
- `lake build` shows SoundnessLemmas.lean compiles with no sorries in temp_t proofs
- `grep -c sorry SoundnessLemmas.lean` decreases by 2

---

### Phase 3: Complete temp_t Proofs in Soundness.lean [NOT STARTED]

**Goal**: Replace the 2 sorries with matching trivial proofs.

**Tasks**:
- [ ] Fix `temp_t_future_valid` (line 663): Replace sorry with `exact h_future t (le_refl t)`
- [ ] Fix `temp_t_past_valid` (line 682): Replace sorry with `exact h_past t (le_refl t)`
- [ ] Remove outdated comments about "strict inequality semantics"
- [ ] Verify proofs compile

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Complete 2 theorems

**Verification**:
- `lake build` shows Soundness.lean compiles with no sorries in temp_t proofs
- `grep -c sorry Soundness.lean` decreases by 2

---

### Phase 4: Update Comments and Add Documentation [NOT STARTED]

**Goal**: Update stale comments referencing strict `<` to reflect actual `<=` semantics, add design documentation.

**Tasks**:
- [ ] Update header comments in SoundnessLemmas.lean (lines 156-157) from `s < t`/`s > t` to `s ≤ t`/`t ≤ s`
- [ ] Update docstrings for swap_axiom_t4_valid, swap_axiom_ta_valid, swap_axiom_tl_valid (change `<` to `≤`)
- [ ] Add module-level documentation explaining reflexive semantics choice (reference Tasks 658, 730)
- [ ] Update any remaining comments with incorrect inequality references

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Update comments
- `Theories/Bimodal/Metalogic/Soundness.lean` - Update comments if needed

**Verification**:
- Comments accurately reflect the `<=` semantics in Truth.lean
- No references to "strict" inequality remain in soundness context

---

### Phase 5: Build Verification and Cleanup [NOT STARTED]

**Goal**: Verify full build succeeds and count remaining sorries.

**Tasks**:
- [ ] Run `lake build` to verify full project compiles
- [ ] Count sorries before/after: `grep -r "sorry" Theories/Bimodal/Metalogic/`
- [ ] Verify no new errors introduced
- [ ] Document sorry count reduction in summary

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` exits with code 0
- Sorry count decreased by 4 (2 in SoundnessLemmas.lean, 2 in Soundness.lean)
- No new warnings or errors

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -c sorry Theories/Bimodal/Metalogic/SoundnessLemmas.lean` decreases by 2
- [ ] `grep -c sorry Theories/Bimodal/Metalogic/Soundness.lean` decreases by 2
- [ ] Comments in soundness files match Truth.lean semantics (`<=`)
- [ ] `lean_goal` at temp_t proofs shows "no goals" (proofs complete)

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
