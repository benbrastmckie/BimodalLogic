# Implementation Plan: Task #907

- **Task**: 907 - Phase 1: Add Omega parameter to truth_at
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: None (Phase 1 of parent task 906)
- **Research Inputs**: specs/907_phase1_truth_omega_parameter/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Add an `Omega : Set (WorldHistory F)` parameter to `truth_at` in Truth.lean. The Box case will quantify over `sigma in Omega` instead of all histories. Define a `ShiftClosed` predicate and prove `Set.univ` is shift-closed. Update all TimeShift lemmas to thread Omega, with `time_shift_preserves_truth` requiring a `ShiftClosed` hypothesis for its Box case proof.

### Research Integration

From research-001.md:
- Verified code snippets for new `truth_at` definition compile
- Identified 7-step change order to minimize intermediate errors
- Confirmed `truth_double_shift_cancel` Box case remains `rfl` (no ShiftClosed needed)
- Only `time_shift_preserves_truth` requires ShiftClosed hypothesis
- Downstream files (Validity, Soundness) NOT in Phase 1 scope

## Goals & Non-Goals

**Goals**:
- Add `Omega : Set (WorldHistory F)` parameter to `truth_at` definition
- Update Box case to `forall sigma in Omega, truth_at M Omega sigma t phi`
- Define `ShiftClosed` predicate and prove `Set.univ_shift_closed`
- Update all Truth namespace lemmas (bot_false through future_iff)
- Update all TimeShift namespace lemmas with Omega parameter
- Update `time_shift_preserves_truth` with ShiftClosed hypothesis
- Truth.lean compiles without errors

**Non-Goals**:
- Updating downstream files (Validity.lean, Soundness.lean, etc.)
- Updating test files
- Updating Boneyard files (deprecated, expected to break)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box case proof changes in `time_shift_preserves_truth` | High | Medium | Research verified structure; need `h_sc` for shifted history membership |
| Recursive termination checker issues | Medium | Low | Omega passed unchanged; verified in research |
| simp/unfold behavior changes | Low | Low | Verified in research; `simp only [truth_at]` still works |

## Sorry Characterization

### Pre-existing Sorries
- 0 sorries in `Truth.lean` (file is complete)

### Expected Resolution
- N/A (no sorries to resolve)

### New Sorries
- None expected. All changes are mechanical parameter threading or verified proof updates.

### Remaining Debt
- 0 sorries expected after implementation
- Downstream files will have compilation errors until Phases 2-4 complete (expected)

## Implementation Phases

### Phase 1: Update truth_at Definition [COMPLETED]

- **Dependencies:** None
- **Goal:** Add Omega parameter to `truth_at` and update Box case

**Tasks:**
- [ ] Modify `truth_at` signature (line 108) to add `(Omega : Set (WorldHistory F))` after `M`
- [ ] Update Box case (line 112) to `forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi`
- [ ] Update all recursive calls to thread Omega (imp, all_past, all_future cases)
- [ ] Update docstring to mention Omega parameter

**Code Changes:**

Line 108, change:
```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
```
to:
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
```

Lines 109-114, update the cases:
```lean
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

**Timing:** 15 minutes

**Verification:**
- File parses without immediate errors (Truth namespace lemmas will show errors until Phase 2)

---

### Phase 2: Update Truth Namespace Lemmas [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add Omega parameter to all Truth namespace lemmas (lines 119-212)

**Tasks:**
- [ ] Update `bot_false` (lines 124-130) - add Omega parameter
- [ ] Update `imp_iff` (lines 135-142) - add Omega parameter
- [ ] Update `atom_iff_of_domain` (lines 148-161) - add Omega parameter
- [ ] Update `atom_false_of_not_domain` (lines 166-174) - add Omega parameter
- [ ] Update `box_iff` (lines 179-186) - add Omega parameter AND update statement
- [ ] Update `past_iff` (lines 191-198) - add Omega parameter
- [ ] Update `future_iff` (lines 203-210) - add Omega parameter

**Code Changes:**

For `box_iff` (lines 179-186), change to:
```lean
theorem box_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {tau : WorldHistory F}
    {t : D}
    (Omega : Set (WorldHistory F))
    (phi : Formula) :
    (truth_at M Omega tau t phi.box) <->
      forall (sigma : WorldHistory F), sigma in Omega -> (truth_at M Omega sigma t phi) := by
  rfl
```

For other lemmas, add `(Omega : Set (WorldHistory F))` parameter and update `truth_at M` to `truth_at M Omega`. All proofs remain unchanged (rfl, intro/exact patterns).

**Timing:** 30 minutes

**Verification:**
- `lake build Bimodal.Semantics.Truth` compiles Truth namespace without errors

---

### Phase 3: Add ShiftClosed Definition [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Define `ShiftClosed` predicate and prove `Set.univ_shift_closed`

**Tasks:**
- [ ] Add `ShiftClosed` definition after line 212 (end of Truth namespace), before TimeShift section
- [ ] Add `Set.univ_shift_closed` theorem

**Code to Insert (after line 212, before line 214):**

```lean
/--
A set of world histories is shift-closed if shifting any history by any amount
keeps it in the set. This is required for time_shift_preserves_truth to work
with the box modality, since we need shifted histories to remain in Omega.
-/
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), WorldHistory.time_shift sigma Delta in Omega

/--
The universal set of world histories is trivially shift-closed.
-/
theorem Set.univ_shift_closed : ShiftClosed (Set.univ : Set (WorldHistory F)) := by
  intro sigma _ Delta
  exact Set.mem_univ _
```

**Timing:** 10 minutes

**Verification:**
- Definitions compile without errors

---

### Phase 4: Update truth_history_eq and truth_double_shift_cancel [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Add Omega parameter to the first two TimeShift lemmas

**Tasks:**
- [ ] Update `truth_history_eq` (lines 235-239) - add Omega parameter
- [ ] Update `truth_double_shift_cancel` (lines 247-294) - add Omega parameter

**Code Changes:**

For `truth_history_eq` (line 235):
```lean
theorem truth_history_eq (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau1 tau2 : WorldHistory F) (t : D)
    (h_eq : tau1 = tau2) (phi : Formula) :
    truth_at M Omega tau1 t phi <-> truth_at M Omega tau2 t phi := by
  cases h_eq
  rfl
```

For `truth_double_shift_cancel` (line 247):
```lean
theorem truth_double_shift_cancel (M : TaskModel F) (Omega : Set (WorldHistory F))
    (sigma : WorldHistory F) (Delta : D) (t : D)
    (phi : Formula) :
    truth_at M Omega (WorldHistory.time_shift (WorldHistory.time_shift sigma Delta) (-Delta)) t phi <->
    truth_at M Omega sigma t phi := by
```

Update all recursive IH calls within the proof to use `ih t` with Omega threading:
- `ih_psi t` and `ih_chi t` in imp case (lines 268-276)
- Box case (lines 277-280) remains `rfl` or trivial (both sides expand to same Omega)
- `ih s` calls in all_past and all_future cases (lines 281-294)

**Note:** Box case closes automatically because both sides are `forall sigma in Omega, truth_at M Omega sigma t psi` - definitionally equal regardless of outer history.

**Timing:** 30 minutes

**Verification:**
- Both lemmas compile without errors

---

### Phase 5: Update time_shift_preserves_truth [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Add Omega and ShiftClosed parameters, update Box case proof

**Tasks:**
- [ ] Update signature (line 315) with `(Omega : Set (WorldHistory F))` and `(h_sc : ShiftClosed Omega)`
- [ ] Update all recursive IH calls to thread Omega
- [ ] Update Box case forward direction (lines 357-362) to use h_sc for membership
- [ ] Update Box case backward direction (lines 363-382) to use h_sc for membership
- [ ] Update calls to `truth_history_eq` and `truth_double_shift_cancel` to include Omega

**Code Changes:**

Signature (lines 315-317):
```lean
theorem time_shift_preserves_truth (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (sigma : WorldHistory F) (x y : D)
    (phi : Formula) :
    truth_at M Omega (WorldHistory.time_shift sigma (y - x)) x phi <-> truth_at M Omega sigma y phi := by
```

Box case forward direction (after line 355):
```lean
  | box psi ih =>
    simp only [truth_at]
    constructor
    . intro h_box_x rho h_rho_mem
      -- rho in Omega, need truth at (rho, y)
      -- time_shift rho (y - x) is in Omega by h_sc
      have h_shifted_mem : WorldHistory.time_shift rho (y - x) in Omega :=
        h_sc rho h_rho_mem (y - x)
      have h1 := h_box_x (WorldHistory.time_shift rho (y - x)) h_shifted_mem
      exact (ih rho x y).mp h1
    . intro h_box_y rho h_rho_mem
      -- rho in Omega, need truth at (rho, x)
      -- time_shift rho (x - y) is in Omega by h_sc
      have h_shifted_mem : WorldHistory.time_shift rho (x - y) in Omega :=
        h_sc rho h_rho_mem (x - y)
      have h1 := h_box_y (WorldHistory.time_shift rho (x - y)) h_shifted_mem
      -- Apply IH with time_shift rho (x - y) instead of sigma
      have h2 := (ih (WorldHistory.time_shift rho (x - y)) x y).mpr h1
      -- h2 : truth_at M Omega (time_shift (time_shift rho (x-y)) (y-x)) x psi
      -- Need: truth_at M Omega rho x psi
      have h_cancel : y - x = -(x - y) := (neg_sub x y).symm
      have h_hist_eq :
        WorldHistory.time_shift (WorldHistory.time_shift rho (x - y)) (y - x) =
        WorldHistory.time_shift (WorldHistory.time_shift rho (x - y)) (-(x - y)) := by
        exact WorldHistory.time_shift_congr
          (WorldHistory.time_shift rho (x - y)) (y - x) (-(x - y)) h_cancel
      have h2' := (truth_history_eq M Omega _ _ x h_hist_eq psi).mp h2
      exact (truth_double_shift_cancel M Omega rho (x - y) x psi).mp h2'
```

**Timing:** 45 minutes

**Verification:**
- `time_shift_preserves_truth` compiles without errors
- `lean_goal` shows proof state progresses correctly

---

### Phase 6: Update exists_shifted_history [COMPLETED]

- **Dependencies:** Phase 5
- **Goal:** Add Omega and ShiftClosed parameters to final lemma

**Tasks:**
- [ ] Update signature (lines 475-478) with Omega and h_sc parameters
- [ ] Update body to pass h_sc to time_shift_preserves_truth

**Code Changes:**

```lean
theorem exists_shifted_history (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (sigma : WorldHistory F) (x y : D)
    (phi : Formula) :
    truth_at M Omega sigma y phi <->
    truth_at M Omega (WorldHistory.time_shift sigma (y - x)) x phi := by
  exact (time_shift_preserves_truth M Omega h_sc sigma x y phi).symm
```

**Timing:** 5 minutes

**Verification:**
- `lake build Bimodal.Semantics.Truth` compiles entire file without errors

---

### Phase 7: Final Verification and Cleanup [COMPLETED]

- **Dependencies:** Phase 6
- **Goal:** Verify entire file compiles and no loose ends

**Tasks:**
- [ ] Run `lake build Bimodal.Semantics.Truth` for isolated verification
- [ ] Verify no sorries introduced
- [ ] Review docstrings are updated for new parameters
- [ ] Verify module compiles in isolation (downstream files expected to fail)

**Timing:** 15 minutes

**Verification:**
- `lake build Bimodal.Semantics.Truth` succeeds
- No sorries in Truth.lean
- `grep -n "sorry" Theories/Bimodal/Semantics/Truth.lean` returns nothing

**Progress:**

**Session: 2026-02-19, sess_1771539369_566e30**
- Added: `Omega : Set (WorldHistory F)` parameter to `truth_at` definition
- Added: `ShiftClosed` predicate and `Set.univ_shift_closed` theorem
- Refactored: All Truth namespace lemmas to thread Omega parameter
- Refactored: All TimeShift namespace lemmas to thread Omega parameter
- Refactored: `time_shift_preserves_truth` Box case to use ShiftClosed for membership
- Refactored: `exists_shifted_history` to thread Omega and ShiftClosed
- Completed: `lake build Bimodal.Semantics.Truth` succeeds (669 jobs, 0 errors, 0 sorries)

---

## Testing & Validation

- [x] `lake build Bimodal.Semantics.Truth` succeeds
- [x] No new sorries introduced in Truth.lean
- [x] No new axioms introduced
- [x] ShiftClosed and Set.univ_shift_closed definitions present
- [x] All TimeShift lemmas have Omega parameter
- [x] time_shift_preserves_truth has ShiftClosed hypothesis

## Artifacts & Outputs

- `Theories/Bimodal/Semantics/Truth.lean` - Modified with Omega parameter
- `specs/907_phase1_truth_omega_parameter/summaries/implementation-summary-20260219.md` - After completion

## Rollback/Contingency

If implementation fails:
1. `git checkout Theories/Bimodal/Semantics/Truth.lean` to restore original
2. Review error messages and update plan
3. Consider breaking Phase 5 into smaller sub-phases if Box case proof is complex

If Box case proof structure differs from research expectations:
1. Use `lean_goal` to understand actual proof state
2. Adjust proof strategy based on actual requirements
3. May need additional helper lemmas (add to Phase 5)
