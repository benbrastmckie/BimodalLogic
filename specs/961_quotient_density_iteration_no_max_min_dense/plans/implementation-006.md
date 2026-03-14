# Implementation Plan: Task #961 (v006)

- **Task**: 961 - quotient_density_iteration_no_max_min_dense
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: Task 956 (D Construction strategy), Task 957 (density_frame_condition), Task 962 (dense_timeline_has_strict_intermediate)
- **Research Inputs**: research-006.md (team research - denselyOrdered_iff_forall_not_covBy architecture)
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v006 supersedes v005; uses `denselyOrdered_iff_forall_not_covBy` architecture from Mathlib.Order.Cover

## Overview

**What Changed (v005 -> v006)**:
- research-006.md (team research) identified cleaner architecture: use Mathlib's `denselyOrdered_iff_forall_not_covBy`
- Key insight: prove `DenselyOrdered` by showing no covering relations exist (contradiction structure)
- `dense_timeline_has_strict_intermediate` (from task 962) provides asymmetric iteration with guaranteed target separation
- Reflexivity propagation: `c ~ p` implies `c` is reflexive, enabling guaranteed escape from target class

**Architecture**: Instead of constructing a strict intermediate (which requires termination), assume covering `[p] < [q]` and derive contradiction from density + reflexivity structure. The `denselyOrdered_iff_forall_not_covBy` theorem converts this to `DenselyOrdered`.

### Research Integration

- **research-006.md**: Recommends `denselyOrdered_iff_forall_not_covBy` as top-level structure
- **Key Mathlib theorem**: `denselyOrdered_iff_forall_not_covBy : DenselyOrdered α <-> forall a b, not (a covBy b)`
- **Key project theorem**: `dense_timeline_has_strict_intermediate` (DenseTimeline.lean)

## Goals & Non-Goals

**Goals**:
- Prove `DenselyOrdered (TimelineQuot root_mcs root_mcs_proof)`
- Prove `NoMaxOrder (TimelineQuot root_mcs root_mcs_proof)`
- Prove `NoMinOrder (TimelineQuot root_mcs root_mcs_proof)`
- Zero sorries in CantorApplication.lean
- `lake build` passes

**Non-Goals**:
- Modifying `density_frame_condition` (keep it sorry-free)
- Constructive strict intermediate (use contradiction/non-constructive approach)
- MCS-level strict density proof (bypassed by quotient-level approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Termination argument incomplete | HIGH | MEDIUM | Use `density_escapes_source_class` lemma (Phase 1) |
| Mathlib `CovBy` API mismatch | LOW | LOW | Use explicit coercions, check Mathlib docs |
| Type synthesis issues | MEDIUM | LOW | Use explicit type annotations |
| Proof stuck on escape lemma | HIGH | MEDIUM | Mark [BLOCKED] with review_reason if stuck |

## Sorry Characterization

### Current Sorries (8)
- `CantorApplication.lean`:
  - Line 304: strict_intermediate_exists iteration termination
  - Line 419: strict_intermediate_exists nested termination
  - Line 509: strict_intermediate_exists nested termination
  - Line 573: strict_intermediate_exists nested termination
  - Lines 733-734: NoMaxOrder reflexive loop termination
  - Lines 792-793: NoMinOrder termination

### Expected Resolution
- Phase 1: Add `density_escapes_source_class` lemma to DenseTimeline.lean
- Phase 2: Prove `timelineQuot_no_covBy` using contradiction structure
- Phase 3: Derive `DenselyOrdered` via `denselyOrdered_iff_forall_not_covBy`
- Phase 4: Prove `NoMaxOrder`, `NoMinOrder` using density
- Phase 5: Cleanup, remove obsolete iteration code

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

## Implementation Phases

### Phase 1: Add density_escapes_source_class Lemma [NOT STARTED]

- **Dependencies:** None
- **Goal:** Prove that when source is reflexive and `[source] < [target]`, the density construction produces an element not equivalent to source

**Mathematical Argument**:
When source `p` is reflexive and `[p] < [q]` (strict in quotient), `dense_timeline_has_strict_intermediate` gives `c` with:
1. `p <= c <= q` (in preorder)
2. `not (q ~ c)` (c not equivalent to target)

The key insight: if `c ~ p`, then by reflexivity propagation, `c` is reflexive. Apply `dense_timeline_has_strict_intermediate` again from `c` to `q`:
- Get `d` with `c <= d <= q` and `not (q ~ d)`
- Either `d ~ p` (iterate) or `d not ~ p` (escape found)

**Termination**: The distinguishing formula between `[p]` and `[q]` constrains iterations. Each step uses `density_frame_condition` which constructs via Lindenbaum extension. The formula content of the distinguishing set is finite (bounded by `subformulaClosure(delta).card`), so iteration terminates.

**Implementation**:
```lean
/-- When source is reflexive and strictly below target in quotient,
    there exists a strict intermediate not equivalent to source. -/
theorem density_escapes_source_class
    (p q : StagedPoint)
    (hp : p ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (hq : q ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (h_lt : ⟦⟨p, hp⟩⟧ < ⟦⟨q, hq⟩⟧)
    (h_refl : CanonicalR p.mcs p.mcs) :
    ∃ c : DenseTimelineElem root_mcs root_mcs_proof,
      ⟦⟨p, hp⟩⟧ < ⟦c⟧ ∧ ⟦c⟧ < ⟦⟨q, hq⟩⟧ := by
  -- Use dense_timeline_has_strict_intermediate + reflexivity argument
  sorry -- This is THE key lemma to prove
```

**Tasks:**
- [ ] Add theorem statement `density_escapes_source_class` in DenseTimeline.lean
- [ ] Prove using `dense_timeline_has_strict_intermediate` + reflexivity propagation
- [ ] If stuck after 1 hour, mark [BLOCKED] with review_reason: "termination argument needs formula wellfoundedness formalization"
- [ ] Verify with `lean_goal`
- [ ] Verify with `lake build`

**Timing:** 1.5 hours (with escape valve)

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`

**Verification:**
- `lake build` passes
- `density_escapes_source_class` compiles without sorry
- Alternatively: phase marked [BLOCKED] if proof stuck

---

### Phase 2: Prove timelineQuot_no_covBy [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove that TimelineQuot has no covering pairs

**Mathematical Strategy**:
A covering `[p] covBy [q]` means `[p] < [q]` and no element strictly between. We derive contradiction:

1. From `[p] < [q]`, get representative MCS with `p < q` in preorder
2. By density, exists `c` with `p <= c <= q`
3. Case split:
   - If `c ~ p` AND `c ~ q`: impossible by `intermediate_not_both_equiv`
   - If `c ~ p` AND `c not ~ q`: p is reflexive (by equivalence), apply Phase 1 lemma
   - If `c not ~ p` AND `c ~ q`: symmetric
   - If `c not ~ p` AND `c not ~ q`: `[p] < [c] < [q]`, contradicts covering

**Implementation**:
```lean
import Mathlib.Order.Cover

/-- TimelineQuot has no covering pairs. -/
theorem timelineQuot_no_covBy (a b : TimelineQuot root_mcs root_mcs_proof) :
    ¬ (a covBy b) := by
  intro h_cov
  obtain ⟨hab, h_no_between⟩ := h_cov
  -- hab : a < b
  -- h_no_between : forall c, a < c -> not (c < b)
  induction a using Quotient.inductionOn with
  | _ p =>
    induction b using Quotient.inductionOn with
    | _ q =>
      -- Get intermediate from density
      -- Case split on equivalence
      -- Use density_escapes_source_class for the reflexive case
      sorry
```

**Tasks:**
- [ ] Add `timelineQuot_no_covBy` theorem to CantorApplication.lean
- [ ] Import `Mathlib.Order.Cover`
- [ ] Implement case split structure
- [ ] Use `density_escapes_source_class` for reflexive case
- [ ] Verify with `lean_goal`
- [ ] Verify with `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `timelineQuot_no_covBy` compiles without sorry

---

### Phase 3: Derive DenselyOrdered Instance [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Derive DenselyOrdered from the no-covers property

**Mathematical Strategy**:
Use Mathlib's `denselyOrdered_iff_forall_not_covBy`:
```
DenselyOrdered α <-> forall a b : α, not (a covBy b)
```

**Implementation**:
```lean
instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) :=
  denselyOrdered_iff_forall_not_covBy.mpr timelineQuot_no_covBy
```

**Tasks:**
- [ ] Add DenselyOrdered instance using `denselyOrdered_iff_forall_not_covBy`
- [ ] Verify API compatibility (may need explicit type coercions)
- [ ] Verify with `lean_goal`
- [ ] Verify with `lake build`

**Timing:** 0.25 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- DenselyOrdered instance compiles without sorry

---

### Phase 4: Prove NoMaxOrder and NoMinOrder [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove NoMaxOrder and NoMinOrder using DenselyOrdered

**Mathematical Strategy**:
With DenselyOrdered proven, NoMaxOrder/NoMinOrder follow from seriality:

**NoMaxOrder**: Given [p], use `dense_timeline_has_future` to get q with `p -> q`. Either:
- `[p] < [q]`: done, [q] is strictly greater
- `[p] = [q]`: p is reflexive. By DenselyOrdered + has_future, strict upper bound exists

**NoMinOrder**: Symmetric using `dense_timeline_has_past`.

**Implementation**:
```lean
instance : NoMaxOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    induction a using Quotient.inductionOn with
    | _ p =>
      obtain ⟨q, hq_mem, hpq⟩ := dense_timeline_has_future root_mcs root_mcs_proof p.1 p.2
      by_cases hqp : CanonicalR q.mcs p.1.mcs
      · -- q ~ p: use density to escape
        have h_refl : CanonicalR p.1.mcs p.1.mcs := CanonicalR.trans hpq hqp
        -- Use DenselyOrdered.dense or seriality to get strict upper bound
        sorry
      · -- q not ~ p: [p] < [q]
        exact ⟨⟦⟨q, hq_mem⟩⟧, by rw [Antisymmetrization.lt_def]; exact ⟨hpq, hqp⟩⟩

instance : NoMinOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_lt := by
    intro a
    -- Symmetric to NoMaxOrder using has_past
    sorry
```

**Tasks:**
- [ ] Prove NoMaxOrder using seriality + density escape
- [ ] Prove NoMinOrder symmetrically
- [ ] Verify with `lean_goal`
- [ ] Verify with `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- NoMaxOrder instance compiles without sorry
- NoMinOrder instance compiles without sorry

---

### Phase 5: Cleanup and Final Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Remove obsolete code, verify zero sorries

**Tasks:**
- [ ] Remove or comment out `strict_intermediate_exists` and `strict_intermediate_aux` (no longer needed)
- [ ] Remove obsolete helper lemmas from v004/v005 approach
- [ ] Run `lake build` - must pass
- [ ] Run `grep -rn "\bsorry\b" CantorApplication.lean` - must return empty
- [ ] Run `grep -rn "\bsorry\b" DenseTimeline.lean` - must return empty
- [ ] Verify `cantor_iso` theorem still compiles

**Timing:** 0.25 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" CantorApplication.lean DenseTimeline.lean` returns empty (zero-debt gate)
- All instances compile without sorry

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" CantorApplication.lean` returns empty (zero-debt gate)
- [ ] `grep -rn "\bsorry\b" DenseTimeline.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] `density_escapes_source_class` compiles without sorry (or phase marked [BLOCKED])
- [ ] `timelineQuot_no_covBy` compiles without sorry
- [ ] `DenselyOrdered` instance has no sorries
- [ ] `NoMaxOrder` instance has no sorries
- [ ] `NoMinOrder` instance has no sorries
- [ ] `cantor_iso` theorem compiles

## Artifacts & Outputs

- `plans/implementation-006.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`

## Comparison: v005 vs v006

| Aspect | v005 | v006 |
|--------|------|------|
| **Top-level structure** | Constructive strict intermediate | `denselyOrdered_iff_forall_not_covBy` |
| **Key Theorem** | `strict_intermediate_exists` | `timelineQuot_no_covBy` |
| **Proof style** | Bounded iteration (4 levels) | Contradiction from covering assumption |
| **Termination** | Wellfoundedness of formula set (unproven) | `density_escapes_source_class` lemma |
| **Escape valve** | None | Phase 1 [BLOCKED] if termination stuck |
| **Research basis** | research-005.md | research-006.md (team research) |

## Rollback/Contingency

If implementation fails:
1. Phase 1 blocked: Keep v005 structure, mark task [BLOCKED] with termination research needed
2. Phase 2-4 blocked: Revert to v005, investigate specific failure point
3. Git: `git checkout -- Theories/Bimodal/Metalogic/StagedConstruction/*.lean`
4. Alternative: Non-constructive quotient density argument (research-006 Option 2)
