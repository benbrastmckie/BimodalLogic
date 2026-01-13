# Implementation Plan: Task #458 - Extend canonical_history to Full Domain

- **Task**: 458 - Extend canonical_history from singleton domain to full domain
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Priority**: High
- **Dependencies**: Task 448 (Build canonical_history - singleton domain MVP - COMPLETED)
- **Research Inputs**: .claude/specs/458_extend_canonical_history_full_domain/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The singleton domain `canonical_history` (Task 448) makes temporal operators `G phi` and `H phi` vacuously true at time 0, breaking the truth lemma correspondence. For correctness, we need `G phi in S iff G phi true` but singleton gives `G phi always true`. This implementation extends `canonical_history` to full domain by: (1) completing temporal compositionality in Task 447, (2) implementing forward/backward existence lemmas using seed set + Lindenbaum pattern, and (3) constructing a full domain history using `Classical.choice`.

### Research Integration

Key findings from research-001.md:
- Singleton domain makes all future quantifiers vacuously true (no times > 0 in domain)
- Temporal compositionality has sorry placeholders at lines 2120, 2131 blocking full domain proof
- Existence lemmas require seed set consistency proofs using MCS closure properties
- `set_mcs_all_future_all_future` and `set_mcs_all_past_all_past` already proven (G-4 and H-4 analogs)
- Full domain construction requires `Classical.choice` for `states` function (acceptable for metalogic)

## Goals & Non-Goals

**Goals**:
- Complete temporal compositionality proof in `canonical_compositionality`
- Implement `forward_extension` lemma: given MCS S and d > 0, construct MCS T with `canonical_task_rel S d T`
- Implement `backward_extension` lemma: given MCS S and d > 0, construct MCS T with `canonical_task_rel T d S`
- Replace singleton `canonical_history` with full domain version
- Ensure truth lemma temporal cases work with new history

**Non-Goals**:
- Proving the full truth lemma (separate task 449)
- Optimizing for computability (noncomputable is acceptable)
- Supporting non-standard temporal structures

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Temporal compositionality requires definition change | High | Medium | Try proof-only fix first; if blocked, propose minimal definition refinement |
| Seed set consistency proof complexity | Medium | Medium | Leverage existing `set_mcs_all_future_all_future` and `set_mcs_box_box` lemmas |
| Classical.choice complicates downstream proofs | Low | Low | Standard in modal logic completeness; document choice dependencies |
| Case analysis explosion in compositionality | Medium | Medium | Use structured proof with helper lemmas for each case |

## Implementation Phases

### Phase 1: Temporal Persistence Lemmas [COMPLETED]

**Goal**: Prove that G-formulas persist forward and H-formulas persist backward through the task relation. These lemmas are key to completing temporal compositionality.

**Tasks**:
- [ ] Analyze why temporal compositionality currently fails (lines 2093-2131)
- [ ] Prove `future_formula_persistence`: If `canonical_task_rel S d T` with `d > 0` and `G phi in S`, then `G phi in T`
  - Strategy: From `G phi in S`, get `G G phi in S` via `set_mcs_all_future_all_future`
  - Then `G phi in T` via future_transfer on `G G phi`
- [ ] Prove `past_formula_persistence`: If `canonical_task_rel S d T` with `d < 0` and `H phi in S`, then `H phi in T`
  - Strategy: From `H phi in S`, get `H H phi in S` via `set_mcs_all_past_all_past`
  - Then `H phi in T` via past_transfer on `H H phi`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add persistence lemmas after line 2056

**Verification**:
- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds with new lemmas
- [ ] `lean_diagnostic_messages` shows no errors for persistence lemmas

---

### Phase 2: Complete Temporal Compositionality [PARTIAL]

**Goal**: Fill in the sorry placeholders in `canonical_compositionality` (lines 2120, 2131) using the persistence lemmas from Phase 1.

**Tasks**:
- [ ] Complete future transfer case (lines 2095-2120):
  - Case 1: If `x > 0`, use `future_formula_persistence` to get `G phi in T`, then `hTU_future` if `y > 0`
  - Case 2: If `x <= 0` and `x + y > 0`, then `y > 0`; need to handle this case carefully
  - May need additional case analysis on signs of x, y
- [ ] Complete past transfer case (lines 2122-2131):
  - Mirror structure of future transfer case
  - Use `past_formula_persistence` similarly
- [ ] Add detailed case analysis helper lemmas if needed for clarity
- [ ] Ensure compositionality proof compiles without sorry

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace sorry at lines 2120, 2131

**Verification**:
- [ ] `canonical_compositionality` compiles without sorry
- [ ] `canonical_frame` definition compiles without warnings
- [ ] All downstream definitions still compile

---

### Phase 3: Forward Existence Lemma [IN PROGRESS]

**Goal**: Prove that for any MCS S and positive duration d, there exists an MCS T such that `canonical_task_rel S d T`.

**Tasks**:
- [ ] Define `forward_seed`:
  ```lean
  def forward_seed (S : CanonicalWorldState) : Set Formula :=
    {phi | Formula.all_future phi in S.val} ∪ {phi | Formula.box phi in S.val}
  ```
- [ ] Prove `forward_seed_consistent`:
  - Assume inconsistent: exists finite L subset of forward_seed deriving bot
  - Each phi in L is either G-content or box-content from S
  - By propositional manipulation, this contradicts S being MCS
  - Use `set_mcs_finite_subset_consistent` and deduction theorem
- [ ] Prove `forward_extension`:
  ```lean
  lemma forward_extension (S : CanonicalWorldState) (d : Duration) (hd : d > 0) :
      exists T : CanonicalWorldState, canonical_task_rel S d T
  ```
  - Get MCS T from `set_lindenbaum` applied to `forward_seed S`
  - Verify `canonical_task_rel S d T` holds:
    - Modal transfer: `box phi in S -> phi in forward_seed -> phi in T`
    - Future transfer: `G phi in S -> phi in forward_seed -> phi in T`
    - Past transfer: vacuously true (d > 0)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add after `canonical_compositionality`

**Verification**:
- [ ] `forward_seed` definition compiles
- [ ] `forward_seed_consistent` proof compiles without sorry
- [ ] `forward_extension` proof compiles without sorry
- [ ] Types align with `CanonicalWorldState` and `canonical_task_rel`

---

### Phase 4: Backward Existence Lemma [NOT STARTED]

**Goal**: Prove that for any MCS S and positive duration d, there exists an MCS T such that `canonical_task_rel T d S` (T is "before" S by duration d).

**Tasks**:
- [ ] Define `backward_seed`:
  ```lean
  def backward_seed (S : CanonicalWorldState) : Set Formula :=
    {phi | Formula.all_past phi in S.val} ∪ {phi | Formula.box phi in S.val}
  ```
- [ ] Prove `backward_seed_consistent`:
  - Similar structure to forward case
  - Use H-formulas instead of G-formulas
- [ ] Prove `backward_extension`:
  ```lean
  lemma backward_extension (S : CanonicalWorldState) (d : Duration) (hd : d > 0) :
      exists T : CanonicalWorldState, canonical_task_rel T d S
  ```
  - Get MCS T from `set_lindenbaum` applied to `backward_seed S`
  - Verify `canonical_task_rel T d S` holds:
    - Modal transfer: Need `box phi in T -> phi in S`
    - This requires careful analysis: T is constructed to contain box-content of S
    - Key insight: `box phi in T` implies `phi in T` (by modal T), and by construction `phi in S`
  - May need auxiliary lemmas about modal closure

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add after `forward_extension`

**Verification**:
- [ ] `backward_seed` definition compiles
- [ ] `backward_seed_consistent` proof compiles without sorry
- [ ] `backward_extension` proof compiles without sorry
- [ ] Symmetry with forward case is maintained

---

### Phase 5: Full Domain Canonical History [NOT STARTED]

**Goal**: Replace singleton domain `canonical_history` with full domain version using existence lemmas and Classical.choice.

**Tasks**:
- [ ] Define noncomputable `states` function:
  ```lean
  noncomputable def canonical_states (S : CanonicalWorldState) (t : Duration) : CanonicalWorldState :=
    if h : t = 0 then S
    else if ht : t > 0 then
      Classical.choose (forward_extension S t ht)
    else
      Classical.choose (backward_extension S (-t) (neg_pos.mpr (lt_of_not_ge (not_le.mpr (lt_of_not_ge ...)))))
  ```
- [ ] Define updated `canonical_history`:
  ```lean
  noncomputable def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
    domain := fun _ => True  -- Full domain
    convex := fun _ _ _ _ _ _ _ => trivial
    states := fun t _ => canonical_states S t
    respects_task := ...
  ```
- [ ] Prove `respects_task` property:
  - For s <= t, need `canonical_task_rel (states s) (t - s) (states t)`
  - Use compositionality to combine relations from 0 to s and s to t
  - This is where Phase 2 completion is critical
- [ ] Remove old singleton domain version (lines 2223-2241)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace `canonical_history` definition

**Verification**:
- [ ] `canonical_history` marked `noncomputable`
- [ ] Full domain `domain := fun _ => True` in place
- [ ] `respects_task` proof compiles without sorry
- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] No regressions in downstream files

---

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Verify the implementation works correctly and clean up any redundant code.

**Tasks**:
- [ ] Run full project build: `lake build`
- [ ] Verify `canonical_model` and related definitions still work
- [ ] Check that truth_lemma axiom placeholder is still compatible
- [ ] Add documentation comments explaining:
  - Why full domain is needed for truth lemma
  - Why noncomputable is acceptable
  - How existence lemmas relate to standard modal logic completeness proofs
- [ ] Remove any temporary helper lemmas or commented-out code
- [ ] Update any outdated comments referencing singleton domain

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Documentation and cleanup

**Verification**:
- [ ] `lake build` succeeds with no warnings related to Completeness.lean
- [ ] No sorry placeholders in modified code
- [ ] Documentation is complete and accurate

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds after each phase
- [ ] `lean_diagnostic_messages` shows no errors in Completeness.lean
- [ ] `canonical_compositionality` compiles without sorry
- [ ] `forward_extension` and `backward_extension` compile without sorry
- [ ] `canonical_history` has `domain := fun _ => True`
- [ ] `respects_task` proof in `canonical_history` compiles without sorry
- [ ] Full project `lake build` succeeds
- [ ] No regressions in dependent files (Soundness, Truth, etc.)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness.lean` - Updated with:
  - `future_formula_persistence` lemma
  - `past_formula_persistence` lemma
  - Completed `canonical_compositionality` (no sorry)
  - `forward_seed` definition
  - `forward_seed_consistent` lemma
  - `forward_extension` lemma
  - `backward_seed` definition
  - `backward_seed_consistent` lemma
  - `backward_extension` lemma
  - Updated `canonical_history` with full domain
- `.claude/specs/458_extend_canonical_history_full_domain/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation fails or creates regressions:
1. **Git rollback**: `git checkout HEAD -- Theories/Bimodal/Metalogic/Completeness.lean`
2. **Partial progress preservation**: Each phase commits independently, allowing rollback to last working phase
3. **Alternative approach**: If compositionality cannot be completed with current definition, document blocking issue and propose definition refinement as separate task
4. **Singleton fallback**: If full domain proves too complex, retain singleton domain with documented limitations for truth lemma workaround

## Key Code References

| Component | Location | Purpose |
|-----------|----------|---------|
| `canonical_task_rel` | Lines 2014-2017 | Three-part transfer relation |
| `canonical_compositionality` | Lines 2076-2131 | Sorried temporal cases |
| `canonical_history` (singleton) | Lines 2223-2241 | Current implementation to replace |
| `set_mcs_all_future_all_future` | Lines 1041-1070 | G-4 axiom for persistence |
| `set_mcs_all_past_all_past` | Lines 1101-1130 | H-4 axiom for persistence |
| `set_mcs_box_box` | Lines 1010-1039 | Modal 4 axiom |
| `set_lindenbaum` | Lines 352-407 | MCS extension tool |
