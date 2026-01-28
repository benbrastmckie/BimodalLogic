# Implementation Plan: Task #658 (Revised v5)

- **Task**: 658 - Prove indexed family coherence conditions
- **Version**: 005 (Post-Task 681 Integration)
- **Status**: [PLANNED]
- **Effort**: 1-2 hours
- **Priority**: Medium
- **Dependencies**: Task 681 (COMPLETED)
- **Research Inputs**:
  - specs/658_prove_indexed_family_coherence_conditions/reports/research-004.md
  - specs/681_redesign_construct_indexed_family_coherent_approach/plans/implementation-006.md
  - specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-20260128-v4.md
- **Artifacts**: plans/implementation-005.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Executive Summary

**Context Change**: Task 681 is now COMPLETED. The original plan v4 was written when 681 was a prerequisite; now it's done and we can integrate its work.

### What Task 681 Accomplished

1. Created `CoherentConstruction.lean` with the coherent family approach
2. Documented all non-critical sorries in the module docstring gap table
3. Proved the two critical cases (forward_G Case 1, backward_H Case 4)
4. Marked `construct_indexed_family` in IndexedMCSFamily.lean as SUPERSEDED
5. Created comprehensive Boneyard and README documentation

### Task 658's New Role

Task 681's summary states: "All four coherence sorries (lines 609-627) are SUPERSEDED by CoherentConstruction."

However, **the physical sorries still exist in IndexedMCSFamily.lean**. The current state is:
- `construct_indexed_family` is documented as SUPERSEDED with comments
- The four `sorry` statements remain in place
- `construct_coherent_family` exists as the recommended replacement
- No actual code removal or replacement has been done

**This task completes the integration** by either:
- Option A: Removing `construct_indexed_family` entirely (if no external dependents)
- Option B: Replacing its body with a call to `construct_coherent_family.toIndexedMCSFamily`
- Option C: Keeping it as documentation (if useful for historical reference)

## Goals & Non-Goals

**Goals**:
- Determine how `construct_indexed_family` is used downstream
- Either replace, remove, or archive the function appropriately
- Ensure `lake build` passes with zero new sorries
- Update documentation to reflect final state

**Non-Goals**:
- Proving additional sorries in CoherentConstruction (Task 681 determined they're non-critical)
- Modifying the representation theorem chain
- Creating new infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `construct_indexed_family` has dependents | Medium | Medium | Check with Grep before removal |
| Type parameter mismatch (D vs ℤ) | Low | Low | CoherentConstruction already handles ℤ |
| Architectural documentation loss | Low | Low | Function is already well-documented |

## Implementation Phases

### Phase 1: Dependency Analysis [NOT STARTED]

**Goal**: Determine if `construct_indexed_family` is used anywhere.

**Tasks**:
- [ ] Search for `construct_indexed_family` references across the codebase
- [ ] Check `UniversalCanonicalModel.lean` for usage
- [ ] Check imports and re-exports

**Decision Tree**:
```
If no references outside IndexedMCSFamily.lean:
  → Proceed to Phase 2A (Clean Removal)
If referenced but can use construct_coherent_family instead:
  → Proceed to Phase 2B (Replacement)
If referenced and must keep signature:
  → Proceed to Phase 2C (Wrapper Delegation)
```

**Timing**: 15 minutes

---

### Phase 2A: Clean Removal [NOT STARTED]

**Condition**: No external references to `construct_indexed_family`.

**Goal**: Remove the superseded function entirely since CoherentConstruction is the canonical approach.

**Tasks**:
- [ ] Remove `construct_indexed_family` definition (lines ~400-600)
- [ ] Remove helper definitions used only by `construct_indexed_family`:
  - `time_seed`
  - `time_indexed_mcs`
  - Related lemmas
- [ ] Keep `IndexedMCSFamily` structure (used by `CoherentIndexedFamily.toIndexedMCSFamily`)
- [ ] Update module docstring to reflect removal
- [ ] Run `lake build` to verify

**Timing**: 30 minutes

---

### Phase 2B: Replacement [NOT STARTED]

**Condition**: External references exist but callers can accept `construct_coherent_family`.

**Goal**: Replace the function body with a delegation.

**Tasks**:
- [ ] Update function signature if needed (D → ℤ specialization)
- [ ] Replace body with:
  ```lean
  (construct_coherent_family Gamma h_mcs h_no_G_bot h_no_H_bot).toIndexedMCSFamily
  ```
- [ ] Remove obsolete helper definitions
- [ ] Update docstring to document the delegation
- [ ] Run `lake build` to verify

**Timing**: 30 minutes

---

### Phase 2C: Wrapper Delegation [NOT STARTED]

**Condition**: Must preserve exact signature for API compatibility.

**Goal**: Make `construct_indexed_family` a thin wrapper around `construct_coherent_family`.

**Tasks**:
- [ ] Keep function signature exactly as-is
- [ ] Replace sorry-based coherence proofs with extraction from coherent family:
  ```lean
  where
    mcs := (construct_coherent_family ...).mcs
    is_mcs := (construct_coherent_family ...).is_mcs
    forward_G := by
      intro t t' φ h_lt h_mem
      exact (construct_coherent_family ...).pairwise_coherent t t' |>.1 h_lt φ h_mem
    -- ... similar for other three conditions
  ```
- [ ] Run `lake build` to verify

**Timing**: 45 minutes

---

### Phase 3: Final Verification [NOT STARTED]

**Goal**: Ensure all changes compile and documentation is accurate.

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Verify sorry count has not increased
- [ ] Update `Representation/README.md` if needed (already says "SUPERSEDED")
- [ ] Check that `UniversalCanonicalModel.lean` still compiles

**Timing**: 15 minutes

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` passes
- [ ] `lake build Bimodal.Metalogic.Representation.UniversalCanonicalModel` passes
- [ ] `lake build` full project passes
- [ ] No new sorries introduced

## Artifacts & Outputs

- `specs/658_prove_indexed_family_coherence_conditions/plans/implementation-005.md` (this plan)
- Modified: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- `specs/658_prove_indexed_family_coherence_conditions/summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Previous Plan Analysis

**implementation-004.md Status**: [PLANNED] → SUPERSEDED

**What Changed**:
- v4 was written when Task 681 was a prerequisite (not yet complete)
- v4 described the integration *once 681 completed*
- Task 681 is now COMPLETED, so v4's preconditions are met

**What v5 Adds**:
- Specific phase breakdown for the integration work
- Dependency analysis to determine best approach
- Three options (removal, replacement, wrapper) based on usage patterns
- Post-Task 681 context (exactly what was built, what files exist)

## Key Insight from Task 681

From implementation-summary-20260128-v4.md:

> "All four coherence sorries (lines 609-627) are SUPERSEDED by CoherentConstruction."

The `construct_indexed_family` function still exists with its sorries, but it's now properly documented as superseded. This task completes the transition by ensuring the codebase reflects this supersession in code, not just comments.

## Success Criteria

1. ✅ `construct_indexed_family` is either removed, replaced, or properly delegating
2. ✅ Zero new sorries in IndexedMCSFamily.lean (sorries moved to CoherentConstruction are fine)
3. ✅ `lake build` passes for full project
4. ✅ Documentation accurately reflects final architecture

## Timeline

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1 (Analysis) | 15 min | 15 min |
| Phase 2 (A, B, or C) | 30-45 min | 45-60 min |
| Phase 3 (Verification) | 15 min | 60-75 min |
| **Total** | **~1-1.25 hours** | |

## References

- Task 681 summary: specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-20260128-v4.md
- Representation README: Theories/Bimodal/Metalogic/Representation/README.md
- CoherentConstruction: Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean
