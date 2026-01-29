# Implementation Plan: Task #658 (Revised v7)

- **Task**: 658 - Prove indexed family coherence conditions
- **Version**: 007 (Post-Research-005 - Concrete Refactoring)
- **Status**: [IMPLEMENTING]
- **Effort**: 30-45 minutes
- **Priority**: Medium
- **Dependencies**: Task 681 (COMPLETED), Task 697 (COMPLETED)
- **Research Inputs**:
  - specs/658_prove_indexed_family_coherence_conditions/reports/research-005.md
  - specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-20260128-v4.md
- **Artifacts**: plans/implementation-007.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Executive Summary

**Critical Finding from Research-005**: `representation_theorem` on line 77 of UniversalCanonicalModel.lean incorrectly calls `construct_indexed_family` (4 sorries) instead of `construct_coherent_family` (sorry-free for completeness cases).

This is a straightforward refactoring task: update the call site to use the coherent construction that Task 681 created.

### Code-Documentation Mismatch

| Aspect | Documentation (README) | Actual Code |
|--------|------------------------|-------------|
| Construction used | `construct_coherent_family` | `construct_indexed_family` |
| Sorries in path | Only cross-origin (not exercised) | 4 full coherence sorries |

## Goals & Non-Goals

**Goals**:
- Switch `representation_theorem` to use `construct_coherent_family`
- Handle the required `h_no_G_bot` and `h_no_H_bot` arguments
- Verify `lake build` passes
- Optionally clean up superseded code

**Non-Goals**:
- Proving the backward direction of Truth Lemma
- Proving cross-origin coherence cases
- Modifying any other files in the representation module

## Implementation Phases

### Phase 1: Update representation_theorem [NOT STARTED]

**Goal**: Switch from `construct_indexed_family` to `construct_coherent_family`.

**File**: `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean`

**Current Code** (lines 77-84):
```lean
let family := construct_indexed_family D Gamma h_mcs
-- Step 3: phi ∈ family.mcs 0
have h_phi_in : phi ∈ family.mcs 0 := by
  -- family.mcs 0 is the extension of time_seed D Gamma 0
  -- time_seed D Gamma 0 = Gamma (when t = 0)
  -- And h_extends says phi ∈ Gamma
  apply construct_indexed_family_origin D Gamma h_mcs phi
  exact h_extends (Set.mem_singleton phi)
```

**Required Changes**:
1. Add required arguments for `construct_coherent_family`:
   - `h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma`
   - `h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma`

2. Switch construction:
   ```lean
   let coherent := construct_coherent_family D Gamma h_mcs h_no_G_bot h_no_H_bot
   let family := coherent.toIndexedMCSFamily
   ```

3. Update the membership proof to use `construct_coherent_family_origin`

**Approach for h_no_G_bot/h_no_H_bot**:
- First attempt: Prove from MCS properties (G⊥ and H⊥ are inconsistent)
- Fallback: Use `sorry` to unblock, document as known gap

**Timing**: 20 minutes

---

### Phase 2: Verify Build [NOT STARTED]

**Goal**: Ensure the refactoring compiles correctly.

**Tasks**:
- [ ] Run `lake build`
- [ ] Verify `UniversalCanonicalModel.lean` compiles
- [ ] Check that `truth_lemma` call still works with new family

**Expected Result**: Build passes. The `toIndexedMCSFamily` conversion provides the same interface that `truth_lemma_forward` expects.

**Timing**: 5 minutes

---

### Phase 3: Cleanup Superseded Code (Optional) [NOT STARTED]

**Goal**: Remove dead code now that the call site is updated.

**Analysis Needed**:
- Search for other callers of `construct_indexed_family`
- If none found: Move to Boneyard or delete

**Files to Potentially Clean**:
- `IndexedMCSFamily.lean`: `construct_indexed_family` function (lines 623-657)
- Related helpers: `time_seed`, `mcs_at_time` if unused elsewhere

**Decision Point**: Skip this phase if time-constrained; can be a follow-up task.

**Timing**: 10 minutes (if performed)

---

### Phase 4: Update Documentation [NOT STARTED]

**Goal**: Ensure documentation matches implementation.

**Tasks**:
- [ ] Update UniversalCanonicalModel.lean docstring if needed
- [ ] Verify Representation/README.md matches actual code path
- [ ] Remove any "SUPERSEDED" markers if code is actually removed

**Timing**: 5 minutes

---

## Key Technical Details

### construct_coherent_family Signature

From CoherentConstruction.lean:
```lean
noncomputable def construct_coherent_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
    CoherentIndexedFamily D
```

### toIndexedMCSFamily Conversion

The `CoherentIndexedFamily.toIndexedMCSFamily` function converts to the interface expected by TruthLemma, with proven coherence for critical cases.

### Membership Proof

Need to find/verify the corresponding origin membership lemma for coherent construction:
- Expected: `construct_coherent_family_origin` or similar
- Fallback: Prove directly from construction definition

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Proving h_no_G_bot/h_no_H_bot complex | Medium | Accept sorry as fallback |
| Missing origin membership lemma | Low | Prove directly from definitions |
| Build currently has other errors | Blocks | Check build status first |

## Success Criteria

1. ✅ `representation_theorem` uses `construct_coherent_family`
2. ✅ `lake build` passes for UniversalCanonicalModel.lean
3. ✅ No regression in existing functionality
4. ✅ Documentation updated if needed

## Timeline

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1 (Update) | 20 min | 20 min |
| Phase 2 (Verify) | 5 min | 25 min |
| Phase 3 (Cleanup) | 10 min | 35 min |
| Phase 4 (Docs) | 5 min | 40 min |
| **Total** | **~40 min** | |

## References

- Research report: specs/658_prove_indexed_family_coherence_conditions/reports/research-005.md
- Task 681 summary: specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-20260128-v4.md
- UniversalCanonicalModel.lean: Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean
- CoherentConstruction.lean: Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean
- Representation/README.md: Theories/Bimodal/Metalogic/Representation/README.md
