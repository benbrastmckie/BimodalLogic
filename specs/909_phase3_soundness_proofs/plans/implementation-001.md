# Implementation Plan: Task #909

- **Task**: 909 - Phase 3: Soundness Proofs Update (Omega Parameter Threading)
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: Tasks 907, 908 (completed)
- **Research Inputs**: specs/909_phase3_soundness_proofs/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task threads `Omega = Set.univ` through SoundnessLemmas.lean (~35 theorems) and Soundness.lean (~20 theorems) following the Omega parameter addition to `truth_at` in Task 907. The changes are entirely mechanical: inserting `Set.univ` as the Omega argument to `truth_at` calls, and providing `Set.univ_shift_closed` to `time_shift_preserves_truth` calls. No proof strategies or mathematical arguments change - the proof structure is identical, only explicit parameters differ.

### Research Integration

- **Research Report**: specs/909_phase3_soundness_proofs/reports/research-001.md (integrated in this plan version)
- **Key Finding 1**: 58 total theorems need mechanical updates (35 in SoundnessLemmas.lean, 20 in Soundness.lean)
- **Key Finding 2**: 6 call sites to `time_shift_preserves_truth` need `Set.univ_shift_closed` discharge
- **Key Finding 3**: Box case proofs need `simp only [Set.mem_univ, true_implies]` after `simp only [truth_at]`

## Goals & Non-Goals

**Goals**:
- Update `is_valid` definition in SoundnessLemmas.lean to use `truth_at M Set.univ tau t phi`
- Update all 35 theorems in SoundnessLemmas.lean to compile with new `truth_at` signature
- Update all 20 theorems in Soundness.lean to compile with new `truth_at` signature
- Verify clean build with no sorries or new axioms

**Non-Goals**:
- Changing proof strategies (all changes are mechanical parameter insertions)
- Updating downstream files beyond SoundnessLemmas.lean and Soundness.lean
- Updating Boneyard files (they are historical and expected to break)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box case proofs require more than simp | Medium | Low | Use `intro sigma _` pattern to absorb `Set.mem_univ` hypothesis |
| Hidden dependencies in proof structure | Low | Low | Research confirms all changes are mechanical |
| Build errors in downstream files | Low | N/A | Downstream files (Completeness, FMP, etc.) are out of scope - Tasks 910+ handle them |

## Sorry Characterization

### Pre-existing Sorries
- 0 sorries in SoundnessLemmas.lean
- 0 sorries in Soundness.lean

### Expected Resolution
- N/A (no sorries to resolve)

### New Sorries
- None expected. All changes are mechanical parameter insertions with no proof modifications.

### Remaining Debt
- 0 sorries expected in both files after implementation
- No sorry propagation to dependents

## Implementation Phases

### Phase 1: SoundnessLemmas.lean Core Updates [COMPLETED]

- **Dependencies:** None
- **Goal:** Update `is_valid` definition and utility theorems (3 items)

**Tasks:**
- [ ] Update `is_valid` definition (line 76-78): `truth_at M tau t phi` -> `truth_at M Set.univ tau t phi`
- [ ] Update `valid_at_triple` theorem (line 89-91): Insert `Set.univ` in signature
- [ ] Update `truth_at_swap_swap` theorem (lines 100-138): Insert `Set.univ` in signature and update box case with `simp only [truth_at, Set.mem_univ, true_implies]`

**Exact Changes:**

For `is_valid` (line 78):
```lean
-- Before:
    truth_at M tau t phi
-- After:
    truth_at M Set.univ tau t phi
```

For `valid_at_triple` (line 91):
```lean
-- Before:
    truth_at M tau t phi := h_valid F M tau t
-- After:
    truth_at M Set.univ tau t phi := h_valid F M tau t
```

For `truth_at_swap_swap` - box case (lines 119-124):
```lean
-- Before:
  | box phi ih =>
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h sigma
-- After:
  | box phi ih =>
    simp only [Formula.swap_temporal, truth_at, Set.mem_univ, true_implies]
    constructor <;> intro h sigma
```

**Timing:** 20 minutes

**Verification:**
- Run `lake build Theories.Bimodal.Metalogic.SoundnessLemmas` - may still have errors (other theorems)
- Verify `is_valid` definition compiles without error

---

### Phase 2: SoundnessLemmas.lean Swap Axiom Validity [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update 8 swap axiom theorems (lines 199-397)

**Tasks:**
- [ ] Update `swap_axiom_mt_valid` (line 199-207): Add `Set.mem_univ, true_implies` to simp
- [ ] Update `swap_axiom_m4_valid` (line 217-223): Add `Set.mem_univ, true_implies` to simp
- [ ] Update `swap_axiom_mb_valid` (line 233-241): Update `simp` for box
- [ ] Update `swap_axiom_t4_valid` (line 253-264): No box, should work as-is
- [ ] Update `swap_axiom_ta_valid` (line 278-284): No box, should work as-is
- [ ] Update `swap_axiom_tl_valid` (line 306-343): Update box handling in `by_cases` branches
- [ ] Update `swap_axiom_mf_valid` (line 360-372): Add `Set.univ Set.univ_shift_closed` to `time_shift_preserves_truth`
- [ ] Update `swap_axiom_tf_valid` (line 386-397): Add `Set.univ Set.univ_shift_closed` to `time_shift_preserves_truth`

**Exact Changes:**

For box-related theorems (MT, M4, MB), the pattern is:
```lean
-- Before:
    simp only [Formula.swap_temporal, truth_at]
-- After:
    simp only [Formula.swap_temporal, truth_at, Set.mem_univ, true_implies]
```

For `swap_axiom_mf_valid` (line 372):
```lean
-- Before:
  exact (TimeShift.time_shift_preserves_truth M sigma t s phi.swap_past_future).mp h_at_shifted
-- After:
  exact (TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed sigma t s phi.swap_past_future).mp h_at_shifted
```

For `swap_axiom_tf_valid` (line 397):
```lean
-- Before:
  exact (TimeShift.time_shift_preserves_truth M sigma t s phi.swap_past_future).mp h_at_shifted
-- After:
  exact (TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed sigma t s phi.swap_past_future).mp h_at_shifted
```

**Timing:** 25 minutes

**Verification:**
- Run `lake build` and check error count decreases

---

### Phase 3: SoundnessLemmas.lean Rule Preservation and Master Theorem [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Update rule preservation theorems (5) and axiom_swap_valid (1)

**Tasks:**
- [ ] Update `mp_preserves_swap_valid` (line 416-422): May need simp update
- [ ] Update `modal_k_preserves_swap_valid` (line 432-438): Add `Set.mem_univ, true_implies` for box
- [ ] Update `temporal_k_preserves_swap_valid` (line 448-454): No box, should work as-is
- [ ] Update `weakening_preserves_swap_valid` (line 465-467): Identity, no change needed
- [ ] Update `axiom_swap_valid` (line 483-589): Update each case's simp for box handling

**Exact Changes:**

For `modal_k_preserves_swap_valid` (lines 436-437):
```lean
-- Before:
    simp only [Formula.swap_temporal, truth_at]
    intro sigma
-- After:
    simp only [Formula.swap_temporal, truth_at, Set.mem_univ, true_implies]
    intro sigma
```

For `axiom_swap_valid` case bodies with `simp only [truth_at]`:
- prop_k case (line 491): Add `Set.mem_univ, true_implies`
- prop_s case (line 499): Add `Set.mem_univ, true_implies`
- modal_5_collapse case (line 511): Add `Set.mem_univ, true_implies`
- ex_falso case (line 525): Add `Set.mem_univ, true_implies`
- peirce case (line 535): Add `Set.mem_univ, true_implies`
- modal_k_dist case (line 552): Add `Set.mem_univ, true_implies`
- temp_k_dist case (line 562): Add `Set.mem_univ, true_implies`

**Timing:** 15 minutes

**Verification:**
- Run `lake build` and check remaining errors

---

### Phase 4: SoundnessLemmas.lean Local Axiom Validity and Combined Theorem [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Update 17 local axiom validity theorems, `axiom_locally_valid`, and `derivable_implies_valid_and_swap_valid`

**Tasks:**
- [ ] Update `axiom_prop_k_valid` through `axiom_temp_t_past_valid` (lines 598-802): Add `Set.mem_univ, true_implies` to simp for box cases
- [ ] Update `axiom_modal_future_valid` (line 747-757): Add `Set.univ Set.univ_shift_closed` to `time_shift_preserves_truth`
- [ ] Update `axiom_temp_future_valid` (line 760-770): Add `Set.univ Set.univ_shift_closed` to `time_shift_preserves_truth`
- [ ] Update `axiom_locally_valid` (line 805-824): Should work once individual theorems fixed
- [ ] Update `derivable_implies_valid_and_swap_valid` (line 848-941): Update proof body simp calls for box

**Key theorems with `time_shift_preserves_truth`:

For `axiom_modal_future_valid` (lines 755-756):
```lean
-- Before:
  have h_preserve := TimeShift.time_shift_preserves_truth M sigma t s phi
-- After:
  have h_preserve := TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed sigma t s phi
```

For `axiom_temp_future_valid` (lines 768-769):
```lean
-- Before:
  have h_preserve := TimeShift.time_shift_preserves_truth M sigma t s phi
-- After:
  have h_preserve := TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed sigma t s phi
```

**Timing:** 30 minutes

**Verification:**
- Run `lake build Theories.Bimodal.Metalogic.SoundnessLemmas` - should complete successfully

---

### Phase 5: Soundness.lean Updates [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Update all 20 theorems in Soundness.lean

**Tasks:**
- [ ] Update `prop_k_valid` through `peirce_valid` (lines 86-295): Add `Set.mem_univ, true_implies` to simp/unfold for box cases
- [ ] Update `modal_k_dist_valid` through `temp_l_valid` (lines 308-473): Same pattern
- [ ] Update `modal_future_valid` (lines 489-507): Add `Set.univ Set.univ_shift_closed` to `time_shift_preserves_truth`
- [ ] Update `temp_future_valid` (lines 527-545): Add `Set.univ Set.univ_shift_closed` to `time_shift_preserves_truth`
- [ ] Update `temp_t_future_valid` and `temp_t_past_valid` (lines 557-583): Should work as-is
- [ ] Update `axiom_valid` (lines 590-609): Should work once individual theorems fixed
- [ ] Update `soundness` (lines 625-707): Update proof body for box cases

**Key changes for `time_shift_preserves_truth` calls:

For `modal_future_valid` (line 506):
```lean
-- Before:
  have h_preserve := TimeShift.time_shift_preserves_truth M sigma t s phi
-- After:
  have h_preserve := TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed sigma t s phi
```

For `temp_future_valid` (line 544):
```lean
-- Before:
  have h_preserve := TimeShift.time_shift_preserves_truth M sigma t s phi
-- After:
  have h_preserve := TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed sigma t s phi
```

**Timing:** 35 minutes

**Verification:**
- Run `lake build Theories.Bimodal.Metalogic.Soundness` - should complete successfully

---

### Phase 6: Final Verification and Cleanup [COMPLETED]

- **Dependencies:** Phase 5
- **Goal:** Verify clean build of both files and document completion

**Tasks:**
- [ ] Run `lake build Theories.Bimodal.Metalogic.SoundnessLemmas` - verify no errors
- [ ] Run `lake build Theories.Bimodal.Metalogic.Soundness` - verify no errors
- [ ] Run `lake build` for full project - document any downstream errors (expected, not fixed in this task)
- [ ] Verify no new sorries or axioms introduced

**Timing:** 15 minutes

**Verification:**
- Both target files build successfully
- No sorries in either file (grep -c "sorry" on both files returns 0)
- No new axioms (grep -c "^axiom" on both files returns 0)

---

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.SoundnessLemmas` succeeds
- [ ] `lake build Theories.Bimodal.Metalogic.Soundness` succeeds
- [ ] No sorries in SoundnessLemmas.lean: `grep -c "sorry" Theories/Bimodal/Metalogic/SoundnessLemmas.lean` returns 0
- [ ] No sorries in Soundness.lean: `grep -c "sorry" Theories/Bimodal/Metalogic/Soundness.lean` returns 0
- [ ] No new axioms in either file

## Artifacts & Outputs

- `specs/909_phase3_soundness_proofs/plans/implementation-001.md` (this file)
- `specs/909_phase3_soundness_proofs/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean`

## Rollback/Contingency

If implementation encounters issues:
1. `git checkout -- Theories/Bimodal/Metalogic/SoundnessLemmas.lean Theories/Bimodal/Metalogic/Soundness.lean`
2. Review research report for alternative approaches (e.g., `intro sigma _` pattern instead of simp)
3. If structural changes needed, create task 909 revision with updated approach
