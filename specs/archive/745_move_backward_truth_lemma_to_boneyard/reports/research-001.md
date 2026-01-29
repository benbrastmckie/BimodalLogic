# Research Report: Task #745

**Task**: Move backward Truth Lemma cases to Boneyard with documentation
**Date**: 2026-01-29
**Focus**: Understand TruthLemma.lean structure, identify what needs moving

## Summary

TruthLemma.lean contains a mutual induction proof with four blocked sorries: two in the box case (both directions) and two in the backward temporal cases (all_past and all_future). The backward temporal cases (lines 435, 459) are blocked by the omega-rule limitation. TemporalCompleteness.lean already exists to support these cases but is NOT REQUIRED for completeness. The task should move TemporalCompleteness.lean to Boneyard and update TruthLemma.lean documentation, but keep the structure intact since `truth_lemma_forward` correctly derives from the mutual induction.

## Findings

### TruthLemma.lean Structure

The file uses **mutual induction** to prove both directions simultaneously:

```lean
theorem truth_lemma_mutual (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t ↔ truth_at ... phi
```

This allows using backward IH in forward proofs (especially for the `imp` case).

**Sorries in TruthLemma.lean**:
| Line | Case | Direction | Reason |
|------|------|-----------|--------|
| 383 | box | Forward | Architectural limitation - quantifies over ALL histories |
| 406 | box | Backward | Architectural limitation - same issue |
| 435 | all_past | **Backward** | Omega-rule limitation |
| 459 | all_future | **Backward** | Omega-rule limitation |

**Key insight**: The task description mentions lines 423 and 441, but the actual sorries are at lines 435 and 459. Lines 420-435 and 449-459 contain the backward temporal cases with their documentation comments.

### Forward Direction Works

The **forward temporal cases** are fully proven:
- `all_past` forward (lines 410-419): Uses `backward_H` coherence from IndexedMCSFamily
- `all_future` forward (lines 439-448): Uses `forward_G` coherence from IndexedMCSFamily

The theorems `truth_lemma_forward`, `truth_lemma_backward`, and `truth_lemma` all derive from the mutual induction. The forward direction works because:
1. The box case isn't exercised by temporal formulas
2. The temporal forward cases have complete proofs

### TemporalCompleteness.lean

Located at: `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean`

Contains infrastructure for backward temporal cases:
- `H_completeness` - sorry (blocked by omega-rule)
- `G_completeness` - sorry (blocked by omega-rule)
- `witness_from_not_H` - complete proof using contrapositive
- `witness_from_not_G` - complete proof using contrapositive

**Import**: Only imported by TruthLemma.lean (line 3)

### Representation Theorem Usage

`UniversalCanonicalModel.lean` line 99 uses `truth_lemma` (biconditional), but only applies `.mp` to it:
```lean
exact (truth_lemma Z family 0 phi).mp h_phi_in
```

This confirms only the forward direction is actually used in the completeness proof path.

### Existing Boneyard Structure

Boneyard already has Metalogic_v3 with TruthLemma documentation:
```
Theories/Bimodal/Boneyard/Metalogic_v3/
├── Coherence/CrossOriginCases.lean  -- Documentation only
└── TruthLemma/BackwardDirection.lean -- Documentation only (updated by Task 741)
```

These are **documentation files** (no compilable Lean code), not actual module files.

### What Needs Moving

1. **Move**: `TemporalCompleteness.lean` to Boneyard (has sorries, not required)
2. **Update**: TruthLemma.lean to remove the import
3. **Update**: Documentation in BackwardDirection.lean with cross-references
4. **Clarify**: TruthLemma.lean header to emphasize only forward direction needed

### What Should NOT Be Moved

The backward temporal **cases** within `truth_lemma_mutual` should remain in TruthLemma.lean because:
1. The mutual induction structure requires all cases
2. Removing them would break the `truth_lemma_backward` theorem
3. The sorries are already well-documented as not required

## Recommendations

1. **Move TemporalCompleteness.lean** to `Boneyard/Metalogic_v3/TruthLemma/TemporalCompleteness.lean`
   - Keep as compilable Lean (not just docs) for future reference
   - Update Boneyard README if present

2. **Update TruthLemma.lean**:
   - Remove import of TemporalCompleteness
   - Update header documentation to clarify `truth_lemma_forward` is the primary API
   - Keep backward cases with sorry + documentation as-is

3. **Update BackwardDirection.lean**:
   - Add reference to moved TemporalCompleteness.lean
   - Cross-reference Task 745

4. **Update UniversalCanonicalModel.lean**:
   - Optionally change `truth_lemma` to `truth_lemma_forward` for clarity (line 99)

## Project Context

### Directory Structure
```
Theories/Bimodal/Metalogic/Representation/
├── IndexedMCSFamily.lean      -- Core family structure
├── CoherentConstruction.lean  -- Family construction
├── CanonicalHistory.lean      -- Canonical history definition
├── CanonicalWorld.lean        -- World state definition
├── TruthLemma.lean           -- Main truth lemma (KEEP)
├── TemporalCompleteness.lean -- Witness extraction (MOVE TO BONEYARD)
├── UniversalCanonicalModel.lean -- Representation theorem
└── TaskRelation.lean         -- Task-theoretic relations
```

### Related Tasks
- **Task 741**: Created TemporalCompleteness.lean, documented omega-rule limitation
- **Task 681**: Original coherence redesign, created Boneyard docs

## References

- TruthLemma.lean backward cases: lines 420-435 (all_past), 449-459 (all_future)
- TemporalCompleteness.lean: full file for witness extraction infrastructure
- Task 741 summary: `specs/741_.../summaries/implementation-summary-20260129.md`
- Boneyard docs: `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean`

## Next Steps

1. Create implementation plan with 2-3 phases:
   - Phase 1: Move TemporalCompleteness.lean to Boneyard
   - Phase 2: Update TruthLemma.lean (remove import, update docs)
   - Phase 3: Update Boneyard documentation files
2. Verify `lake build` succeeds after changes
3. Create implementation summary
