# Research Report: Task #881 (v10 - Team Research)

**Task**: Construct modally saturated BMCS to eliminate fully_saturated_bmcs_exists axiom
**Date**: 2026-02-16
**Mode**: Team Research (2 teammates)
**Session**: sess_1771302909_fb93d5

## Summary

Team research analyzing the `buildSeedForList_propagates_box` blocker identified **two viable paths forward**. After synthesis, **Option D (FamilyCollection architecture)** is recommended over fixing the current construction.

## The Blocker

`buildSeedForList_propagates_box` is UNPROVABLE with current construction because:
- `createNewFamily` creates entries with ONLY the witness formula
- `addToAllFamilies` propagates Box content only to families that exist AT THAT MOMENT
- New families created after Box processing miss the Box content

**Example**: Processing `[Box beta, negBox alpha]`:
1. `Box beta` adds `beta` to family 0
2. `negBox alpha` creates family 1 WITHOUT `beta`
3. Family 1 should have `beta` (since `Box beta` is in family 0) but doesn't

## Options Analyzed

### Option A: Modify createNewFamily (Teammate A)

**Approach**: Make `createNewFamily` collect and include BoxContent from existing families.

```lean
def ModelSeed.createNewFamilyWithBoxContent (seed : ModelSeed) (timeIdx : Int)
    (phi : Formula) : ModelSeed × Nat :=
  let boxContent := seed.collectBoxContentAt timeIdx
  let newEntry := { formulas := insert phi boxContent, ... }
  ...
```

**Pros**: Clean fix at source, matches semantics
**Cons**: Must update 15+ theorems, 8-12 hours effort
**Confidence**: HIGH (Teammate A)

### Option B: Remove the Lemma

**Analysis**: `buildSeedForList_propagates_box` is only needed for seed-based multi-family construction. `SaturatedConstruction.lean` has alternative path via `exists_fullySaturated_extension`.

**Verdict**: Viable if we restructure to use FamilyCollection approach.

### Option C: Constrain Processing Order

**Analysis**: Process Box formulas last.

**Verdict**: NOT viable - recursive `buildSeedAux` creates families mid-processing, so ordering top-level list doesn't prevent the issue.

### Option D: Alternative Architecture (Teammate B - RECOMMENDED)

**Approach**: Use existing `FamilyCollection` + `exists_fullySaturated_extension` instead of seed-based multi-family construction.

```
fully_saturated_bmcs_exists_int
  |
  +-- Step 1: Build temporally coherent eval_family
  |     Use: buildSeed for SINGLE formula, seedToIndexedFamily
  |
  +-- Step 2: Create initial FamilyCollection
  |     Use: initialFamilyCollection (single family = trivial box_coherence)
  |
  +-- Step 3: Saturate via Zorn
  |     Use: exists_fullySaturated_extension (SORRY-FREE!)
  |
  +-- Result: BMCS via FamilyCollection.toBMCS
```

**Key insight**: `exists_fullySaturated_extension` is ALREADY SORRY-FREE and handles box_coherence as a collection invariant, not through seed propagation.

**Pros**:
- Leverages existing sorry-free infrastructure
- Reduces scope rather than adding complexity
- Aligns with proven architecture in SaturatedConstruction.lean
- Only needs RecursiveSeed for temporal coherence of ONE family

**Cons**:
- Requires plan revision to abandon buildSeedForList approach
- Still need temporally coherent witness families (separate challenge)

**Confidence**: HIGH (Teammate B)

## Synthesis: Conflict Resolution

| Teammate | Recommendation | Approach |
|----------|----------------|----------|
| A | Option A | Fix createNewFamily to propagate BoxContent |
| B | Option D | Bypass with FamilyCollection architecture |

**Resolution**: **Option D is recommended** because:

1. **Sorry-free path**: `exists_fullySaturated_extension` is already proven; Option A requires proving 15+ new theorems

2. **Scope reduction**: Option D uses existing infrastructure; Option A adds complexity

3. **Architectural precedent**: FamilyCollection is the "official" path in SaturatedConstruction.lean

4. **Risk management**: If witness temporal coherence proves difficult (remaining challenge), we've still made less investment than Option A

## Implementation Impact

### Plan Revision Needed

Phase 1 scope should be narrowed:
- **Keep**: `buildSeed` (single formula), `seedToIndexedFamily` (single family)
- **Remove/Archive**: `buildSeedForList` machinery and its 3 remaining sorries
- **Add**: Wire to `initialFamilyCollection` and `exists_fullySaturated_extension`

### Remaining Sorries After Revision

| Location | Status |
|----------|--------|
| `foldl_buildSeedAux_preserves_seedConsistent` | REMOVE (not needed with new approach) |
| `buildSeedForList_consistent` | REMOVE (not needed) |
| `buildSeedForList_propagates_box` | REMOVE (not needed) |

### New Dependencies

| Component | Status | Location |
|-----------|--------|----------|
| `exists_fullySaturated_extension` | SORRY-FREE | SaturatedConstruction.lean:873 |
| `FamilyCollection.toBMCS` | PROVEN | SaturatedConstruction.lean:278 |
| `constantWitnessFamily` | PROVEN | SaturatedConstruction.lean:469 |

## Remaining Challenge

The one challenge that Option D does NOT solve: **witness families need temporally coherent MCSes**.

For constant families (all times have same MCS), this requires `TemporalForwardSaturated`:
- `F psi in M -> psi in M`
- `P psi in M -> psi in M`

This is a DIFFERENT problem from `buildSeedForList_propagates_box`, and is addressed separately by using constant families with the existing `constantWitnessFamily` infrastructure.

## Recommendations

1. **Revise Plan v4 to v5**: Abandon buildSeedForList approach, adopt FamilyCollection architecture

2. **Archive buildSeedForList**: Move to separate file or mark as deprecated

3. **Phase 1 new scope**: Single-formula seed building + seedToIndexedFamily

4. **Phase 2 new scope**: initialFamilyCollection wrapping eval_family

5. **Phase 3-4**: Wire to exists_fullySaturated_extension

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Construction Fix | completed | HIGH | Option A: modify createNewFamily (8-12 hours) |
| B | Alternatives | completed | HIGH | Option D: use FamilyCollection (sorry-free path) |

## References

- Teammate A findings: `specs/881_modally_saturated_bmcs_construction/reports/teammate-a-v6-findings.md`
- Teammate B findings: `specs/881_modally_saturated_bmcs_construction/reports/teammate-b-findings.md`
- `exists_fullySaturated_extension`: SaturatedConstruction.lean:873-1160
- `FamilyCollection`: SaturatedConstruction.lean:220-285
- `createNewFamily`: RecursiveSeed.lean:305-310
- `buildSeedForList_propagates_box`: RecursiveSeed.lean:5917-5923
