# Implementation Plan: Task #961 (v005)

- **Task**: 961 - quotient_density_iteration_no_max_min_dense
- **Status**: [PARTIAL]
- **Effort**: 2.5 hours
- **Dependencies**: Task 956 (D Construction strategy), Task 957 (density_frame_condition)
- **Research Inputs**: research-005.md (deep investigation - quotient-level "no covers" approach)
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v005 supersedes v004; uses quotient-level "no covers" proof to bypass Case B1 endpoint return issue

## Overview

**What Changed (v004 -> v005)**:
- research-005.md identified root cause: Case B1 in `density_frame_condition` returns W = M' (endpoint) when M' is reflexive
- Discovered Mathlib's `toAntisymmetrization_lt_toAntisymmetrization_iff`: `[a] < [b] ↔ a < b`
- New approach: Prove DenselyOrdered at **quotient level** via "no covers" argument
- Bypasses need for strict MCS-level intermediates entirely

**New Approach**: Prove `timelineQuot_no_covBy` (no adjacent elements in quotient), then derive DenselyOrdered. Works at quotient level using Mathlib infrastructure.

### Research Integration

- **research-005.md**: Recommends quotient-level "no covers" proof (Approach F)
- **Key Mathlib theorem**: `toAntisymmetrization_lt_toAntisymmetrization_iff`

## Goals & Non-Goals

**Goals**:
- Prove DenselyOrdered, NoMaxOrder, NoMinOrder for TimelineQuot
- Zero sorries in CantorApplication.lean
- `lake build` passes

**Non-Goals**:
- Modifying `density_frame_condition` (keep it sorry-free)
- MCS-level strict density proof (bypassed by quotient approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| "No covers" still needs iteration | MEDIUM | MEDIUM | Use Classical existence for base case |
| Type mismatch with Mathlib | LOW | LOW | Use explicit coercions |
| Quotient structure compatibility | LOW | LOW | Mathlib Antisymmetrization is well-supported |

## Sorry Characterization

### Current Sorries (7)
- `CantorApplication.lean`:
  - Lines 226, 248, 253, 274, 278: strict_intermediate_aux iteration branches
  - Line 423: NoMaxOrder reflexive case
  - Line 482: NoMinOrder reflexive case

### Expected Resolution
- Phase 1: Prove `timelineQuot_no_covBy` -> enables Phase 2
- Phase 2: Derive `DenselyOrdered TimelineQuot` from no-covers -> resolves DenselyOrdered sorries
- Phase 3: Prove NoMaxOrder/NoMinOrder using density -> resolves lines 423, 482

### New Sorries
- None. If proof cannot be completed, mark [BLOCKED] with requires_user_review: true.

## Implementation Phases

### Phase 1: Prove timelineQuot_no_covBy [PARTIAL]
**Started**: 2026-03-13T14:00:00Z
**Updated**: 2026-03-13T15:30:00Z

- **Dependencies:** None
- **Goal:** Prove that TimelineQuot has no covering pairs (no adjacent elements)

**Mathematical Strategy**:
A covering pair `[a] CovBy [b]` means `[a] < [b]` and no element strictly between them. We show this is impossible using:
1. `dense_timeline_has_intermediate`: gives non-strict intermediate c
2. `intermediate_not_both_equiv`: c can't be ~ both p and q
3. Case analysis on c ~ p vs c ~ q
4. Classical existence for the base case

**Key Insight**: We only need to find ONE element strictly between [a] and [b] to refute the cover. We don't need to construct it - just prove it exists.

**Implementation**:
```lean
/-- TimelineQuot has no covering pairs. -/
theorem timelineQuot_no_covBy (a b : TimelineQuot root_mcs root_mcs_proof) :
    ¬(a ⋖ b) := by
  intro ⟨hab, h_adj⟩
  -- hab : a < b
  -- h_adj : ∀ c, a < c → b ≤ c
  -- Get representatives
  induction a using Quotient.inductionOn with
  | _ p =>
    induction b using Quotient.inductionOn with
    | _ q =>
      -- hab : [p] < [q]
      -- Translate to preorder
      rw [Antisymmetrization.lt_def] at hab
      -- hab : p < q in preorder
      -- Get non-strict intermediate
      obtain ⟨c, hc_mem, hpc, hcq⟩ := dense_timeline_has_intermediate p q hab.1 hab.2
      -- c cannot be ~ both p and q
      have h_not_both := intermediate_not_both_equiv p q c hpc hcq
      -- Case split
      by_cases hcp : AntisymmRel (· ≤ ·) c p
      · -- c ~ p: [c] = [p] = a
        by_cases hcq' : AntisymmRel (· ≤ ·) c q
        · -- c ~ both: contradiction
          exact h_not_both ⟨hcp, hcq'⟩
        · -- c ~ p, c ≁ q: iterate on (c, q)
          -- Use Classical existence: strict intermediate exists
          classical
          by_contra h_none
          -- Show contradiction via quotient collapse
          sorry -- Fill with quotient collapse argument
      · -- c ≁ p
        by_cases hcq' : AntisymmRel (· ≤ ·) c q
        · -- c ≁ p, c ~ q: iterate on (p, c)
          sorry -- Symmetric case
        · -- c ≁ p, c ≁ q: c is strict intermediate!
          -- [p] < [c] < [q]
          have hac : a < ⟦c⟧ := by
            rw [Antisymmetrization.lt_def]
            exact ⟨hpc, fun h => hcp ⟨hpc, h⟩⟩
          have hcb_le : ⟦c⟧ ≤ b := by
            rw [Antisymmetrization.le_def]
            exact hcq
          have hcb_not_ge : ¬(b ≤ ⟦c⟧) := by
            rw [Antisymmetrization.le_def]
            intro h
            exact hcq' ⟨hcq, h⟩
          -- h_adj says: a < [c] → b ≤ [c]
          exact hcb_not_ge (h_adj ⟦c⟧ hac)
```

**Tasks:**
- [x] Add `strict_intermediate_exists` theorem structure
- [ ] Fill the c ~ p case (line 367): requires showing strict MCS is in timeline
- [ ] Fill the d ~ p nested case (line 386): same issue
- [ ] Fill the d ~ q nested case (line 398): same issue
- [ ] Verify with `lean_goal`
- [x] Verify with `lake build` (passes with warnings)

**Progress:**

**Session: 2026-03-13, sess_1773628894_7c3e2f**
- Added: `strict_intermediate_exists` theorem with 3 sorry cases
- Removed: Broken helper theorems `timeline_intermediate_quotient_lt` (had IsPreorder synthesis issues)
- Fixed: Build now passes (was failing due to undefined `strict_intermediate_exists`)
- Sorries: 7 -> 5 (but 3 new sorries in new theorem)
- Analysis: The core blocker is that `density_frame_condition_reflexive_source` gives an MCS that may not be in `denseTimelineUnion`. The timeline uses `density_frame_condition.choose` which can return endpoint (Case B1).

**Blocker Analysis:**
The remaining sorries all require showing that when the source p is reflexive:
1. `density_frame_condition_reflexive_source(p, q)` gives MCS W with ¬CanonicalR q W
2. This W must be demonstrated to exist in `denseTimelineUnion`
3. But `denseTimelineUnion` is built using `densityIntermediateMCS` which uses `density_frame_condition.choose`
4. These might give different MCSs (one is strict, one might be endpoint)

**Options to complete:**
A. Modify `DenseTimeline.lean` to use `density_frame_condition_reflexive_source` when applicable
B. Prove non-constructively that the strict MCS must appear somewhere in the timeline
C. Use a different proof strategy that doesn't require explicit strict intermediate construction

**Timing:** 1.5 hours estimated, 2.0 hours actual (partial)

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes (with sorry warnings)
- `strict_intermediate_exists` compiles with 3 sorries

---

### Phase 2: Derive DenselyOrdered Instance [PARTIAL]

- **Dependencies:** Phase 1
- **Goal:** Derive DenselyOrdered from the no-covers property

**Mathematical Strategy**:
For linear orders, DenselyOrdered is equivalent to having no covering pairs. Mathlib provides `denselyOrdered_iff_no_covBy` or similar.

**Implementation**:
```lean
instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) where
  dense := by
    intro a b hab
    -- Need: ∃ c, a < c ∧ c < b
    -- Use timelineQuot_no_covBy: ¬(a ⋖ b)
    -- Since a < b and no cover, there exists strict intermediate
    by_contra h_none
    push_neg at h_none
    -- h_none : ∀ c, ¬(a < c) ∨ ¬(c < b)
    --        = ∀ c, a < c → b ≤ c
    apply timelineQuot_no_covBy a b
    exact ⟨hab, fun c hac => le_of_not_lt (h_none c (Or.inl hac))⟩
```

**Tasks:**
- [ ] Add DenselyOrdered instance using `timelineQuot_no_covBy`
- [ ] Remove or update old `strict_intermediate_exists` machinery
- [ ] Verify with `lean_goal`
- [ ] Verify with `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- DenselyOrdered instance compiles without sorry

---

### Phase 3: NoMaxOrder and NoMinOrder [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove NoMaxOrder and NoMinOrder using density

**Mathematical Strategy**:
Once we have DenselyOrdered, NoMaxOrder and NoMinOrder follow from seriality:
1. NoMaxOrder: Given p, get q with p -> q (seriality). Either [p] < [q] (done) or [p] = [q]. If all futures are ~ p, use density to find strict future.
2. NoMinOrder: Symmetric using past direction.

**Implementation**:
```lean
instance : NoMaxOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    -- Get representative
    induction a using Quotient.inductionOn with
    | _ p =>
      -- Get future via seriality
      obtain ⟨q, hq_mem, hpq⟩ := dense_timeline_has_future p
      by_cases hqp : CanonicalR q.mcs p.mcs
      · -- q ~ p: [q] = [p], need different witness
        -- Use density to find element above [p]
        -- Since timeline is infinite and not all in [p], such element exists
        sorry -- Use DenselyOrdered + seriality
      · -- q ≁ p: [p] < [q]
        use ⟦⟨q, hq_mem⟩⟧
        rw [Antisymmetrization.lt_def]
        exact ⟨hpq, hqp⟩

instance : NoMinOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_lt := by
    intro a
    -- Symmetric to NoMaxOrder
    sorry
```

**Tasks:**
- [ ] Prove NoMaxOrder using density + seriality
- [ ] Prove NoMinOrder symmetrically
- [ ] Handle the reflexive case using DenselyOrdered
- [ ] Verify with `lean_goal`
- [ ] Verify with `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` returns empty

---

### Phase 4: Cleanup and Verification [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Remove obsolete code and verify

**Tasks:**
- [ ] Remove or archive `strict_intermediate_aux` (no longer needed)
- [ ] Remove obsolete helper functions
- [ ] Run `lake build` - must pass
- [ ] Run `grep -rn "\bsorry\b" CantorApplication.lean` - must return empty
- [ ] Verify `cantor_iso` theorem compiles

**Timing:** 0.25 hours

**Verification:**
- All checks pass
- Zero sorries in `CantorApplication.lean`

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" CantorApplication.lean` returns empty (zero-debt gate)
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] `timelineQuot_no_covBy` compiles without sorry
- [ ] DenselyOrdered instance has no sorries
- [ ] NoMaxOrder instance has no sorries
- [ ] NoMinOrder instance has no sorries

## Artifacts & Outputs

- `plans/implementation-005.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

## Comparison: v004 vs v005

| Aspect | v004 | v005 |
|--------|------|------|
| **Approach** | MCS-level bounded iteration | Quotient-level "no covers" |
| **Key Theorem** | strict_intermediate_aux | timelineQuot_no_covBy |
| **Mathlib Integration** | Limited | Uses toAntisymmetrization_lt_iff |
| **Bypasses Case B1** | No (blocked by it) | Yes (works at quotient level) |
| **Proof Style** | Constructive iteration | Classical existence |
