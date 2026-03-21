# Research Report: Task #658 - Dependency Chain Analysis

**Task**: 658 - Prove indexed family coherence conditions
**Date**: 2026-01-29
**Focus**: Trace dependency from representation_theorem to construction function; identify refactoring needs
**Session**: sess_1769646323_6a0334

## Executive Summary

**Critical Finding**: The `representation_theorem` in UniversalCanonicalModel.lean currently calls `construct_indexed_family` (which has 4 sorries), NOT `construct_coherent_family` (which has the sorry-free path). This is a code-documentation mismatch that needs to be fixed.

**Key Findings**:
1. README documentation shows the intended path through `construct_coherent_family`
2. Actual code uses the superseded `construct_indexed_family`
3. The call is also incomplete (missing `h_no_G_bot`, `h_no_H_bot` arguments)
4. Fix requires updating UniversalCanonicalModel.lean to use the coherent construction

## Context & Scope

### Research Focus
Trace the actual dependency chain from `representation_theorem` back to see which construction function is used, with the goal of achieving a clean, well-structured metalogic.

### Files Examined
1. `UniversalCanonicalModel.lean` - Contains `representation_theorem`
2. `IndexedMCSFamily.lean` - Contains `construct_indexed_family` (superseded)
3. `CoherentConstruction.lean` - Contains `construct_coherent_family` (intended)
4. `Representation/README.md` - Documents intended architecture

## Findings

### 1. Current Code Path (Incorrect)

**UniversalCanonicalModel.lean:77**:
```lean
let family := construct_indexed_family D Gamma h_mcs
```

**Problem 1**: This calls `construct_indexed_family` which has 4 sorries for coherence conditions.

**Problem 2**: The call is missing required arguments. The function signature is:
```lean
noncomputable def construct_indexed_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)  -- MISSING
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :  -- MISSING
    IndexedMCSFamily D
```

### 2. Intended Code Path (from README)

The README shows this architecture:
```
representation_theorem
    │
    ▼
construct_coherent_family
    │
    ▼
CoherentIndexedFamily.toIndexedMCSFamily
    │
    ▼
IndexedMCSFamily (sorry-free for completeness cases)
```

### 3. construct_indexed_family Status

**Location**: IndexedMCSFamily.lean:623-657

**Sorries**: 4 (forward_G, backward_H, forward_H, backward_G)

**Documentation Status**: Marked as SUPERSEDED with comments:
```lean
-- SUPERSEDED by CoherentConstruction.lean
-- Independent Lindenbaum extensions cannot satisfy this
```

**Problem**: Still actively called by `representation_theorem`

### 4. construct_coherent_family Status

**Location**: CoherentConstruction.lean:725-732

**Sorries**: Only for cross-origin cases (never exercised by completeness)
- forward_G Cases 3-4 (cross-origin)
- backward_H Cases 1-2 (cross-origin)
- forward_H (all cases - only needed for backward Truth Lemma)
- backward_G Cases 3-4 (cross-origin)

**Core Cases Proven**:
- forward_G Case 1 (both t, t' ≥ 0) ✅
- backward_H Case 4 (both t, t' < 0) ✅

### 5. Redundant Code Identified

| Location | Status | Recommendation |
|----------|--------|----------------|
| `construct_indexed_family` | SUPERSEDED | Remove or keep as documentation only |
| `time_seed` | Only used by superseded | Remove if unused elsewhere |
| `mcs_at_time` | Only used by superseded | Remove if unused elsewhere |
| Helper lemmas | Various | Audit for dead code |

### 6. Build Status

The codebase currently has build errors in:
- `GeneralizedNecessitation.lean` - Missing `Bimodal.Metalogic_v2.Core` namespace
- `Propositional.lean` - Missing `deduction_theorem` references

These errors appear to be from ongoing Task 731 refactoring work, not related to Task 658.

## Recommended Refactoring

### Phase 1: Fix representation_theorem (Critical)

**File**: UniversalCanonicalModel.lean

**Change**:
```lean
-- Before (line 77):
let family := construct_indexed_family D Gamma h_mcs

-- After:
-- Need to prove h_no_G_bot and h_no_H_bot first
have h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma := by
  -- Proof from h_mcs and h_cons
  sorry  -- Task 658 will address this
have h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma := by
  sorry  -- Task 658 will address this
let coherent := construct_coherent_family Gamma h_mcs h_no_G_bot h_no_H_bot
let family := coherent.toIndexedMCSFamily
```

**Alternative** (simpler but with specific sorry):
```lean
let coherent := construct_coherent_family Gamma h_mcs sorry sorry
let family := coherent.toIndexedMCSFamily
```

### Phase 2: Remove or Archive Dead Code

After switching to coherent construction:
1. Move `construct_indexed_family` and helpers to Boneyard (historical reference)
2. Or delete entirely if not needed for documentation

### Phase 3: Update Documentation

1. Update module docstrings to reflect actual code path
2. Remove "SUPERSEDED" markers (after code is actually removed)
3. Ensure README accurately reflects implementation

## Decision Points

### Q1: How to handle h_no_G_bot and h_no_H_bot?

**Options**:
1. **Prove them**: Show that any MCS extended from {φ} doesn't contain G⊥ or H⊥
   - Requires: Show singleton consistent formulas don't imply G⊥ or H⊥
   - Effort: Medium (proof may be complex)

2. **Accept sorry**: Mark as known gap, document in README
   - Effort: Low
   - Trade-off: Proof has explicit gap

3. **Handle bounded case**: If MCS contains G⊥ or H⊥, use bounded endpoint construction
   - Effort: High (requires separate code path)
   - Trade-off: More complete but complex

**Recommendation**: Option 1 or 2 depending on proof complexity. Option 3 is out of scope.

### Q2: What to do with construct_indexed_family?

**Options**:
1. **Delete entirely**: Clean codebase, no dead code
2. **Move to Boneyard**: Preserve for historical reference
3. **Keep in place as documentation**: With clear "unused" markers

**Recommendation**: Option 2 - Move to Boneyard/Metalogic_v3 with other deprecated coherence code.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Proving h_no_G_bot/h_no_H_bot is complex | Medium | Accept sorry as fallback |
| Other code depends on construct_indexed_family | Medium | Search for all callers before removal |
| Build currently broken | Blocks testing | Wait for Task 731 to fix |

## Success Criteria

1. ✅ `representation_theorem` uses `construct_coherent_family`
2. ✅ No unnecessary sorries in completeness path
3. ✅ Dead code removed or archived
4. ✅ Documentation matches implementation
5. ✅ `lake build` passes (after Task 731 fixes)

## Appendix: Dependency Diagram

```
                    representation_theorem
                            │
                            ▼
          ┌─────────────────────────────────┐
          │  CURRENT (incorrect)            │
          │  construct_indexed_family       │
          │  (4 sorries for coherence)      │
          └─────────────────────────────────┘

                    representation_theorem
                            │
                            ▼
          ┌─────────────────────────────────┐
          │  INTENDED (to implement)        │
          │  construct_coherent_family      │──▶ CoherentIndexedFamily
          │  (only cross-origin sorries)    │         │
          └─────────────────────────────────┘         │
                                                      ▼
                                              .toIndexedMCSFamily
                                                      │
                                                      ▼
                                              IndexedMCSFamily
                                              (sorry-free for
                                               completeness cases)
```

## Next Steps

1. **Immediate**: Update implementation plan v7 with specific refactoring steps
2. **Implementation**: Modify UniversalCanonicalModel.lean to use coherent construction
3. **Cleanup**: Move/remove superseded code
4. **Verification**: Ensure build passes and completeness path is sorry-free

## References

- UniversalCanonicalModel.lean - representation_theorem (line 70-89)
- IndexedMCSFamily.lean - construct_indexed_family (line 623-657)
- CoherentConstruction.lean - construct_coherent_family (line 725-732)
- Representation/README.md - Intended architecture documentation
