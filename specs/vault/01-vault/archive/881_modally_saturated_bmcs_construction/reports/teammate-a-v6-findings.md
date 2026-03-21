# Teammate A: Construction Fix Analysis (v6)

**Date**: 2026-02-16
**Session**: sess_1771302909_fb93d5
**Focus**: Analyze how to fix the current construction to prove buildSeedForList_propagates_box

## Key Findings

The issue with `buildSeedForList_propagates_box` stems from a fundamental design problem in how `createNewFamily` works:

1. **`createNewFamily` does NOT copy BoxContent from existing families** - it creates a completely fresh family with only the witness formula
2. **Box processing happens via `addToAllFamilies`** which only adds psi to families that exist AT THAT MOMENT
3. **New families created after Box processing miss the Box content** - the processing order in foldl creates a timing problem

## createNewFamily Analysis

### Current Implementation (lines 305-310)

```lean
def ModelSeed.createNewFamily (seed : ModelSeed) (timeIdx : Int)
    (phi : Formula) : ModelSeed × Nat :=
  let newFamIdx := seed.nextFamilyIdx
  let newEntry : SeedEntry := { familyIdx := newFamIdx, timeIdx := timeIdx,
                                formulas := {phi}, entryType := .modal_witness }
  ({ entries := seed.entries ++ [newEntry], nextFamilyIdx := newFamIdx + 1 }, newFamIdx)
```

### What it does:
- Creates a new entry with `familyIdx = nextFamilyIdx`
- Sets formulas to a singleton set containing only `phi` (the witness formula)
- Appends this entry to the existing entries
- Increments `nextFamilyIdx`

### What needs to change:
The new family needs to include ALL BoxContent from existing families at `timeIdx`. The modified version would need to:

1. Collect BoxContent: `{psi | Box psi ∈ seed.getFormulas famIdx timeIdx}` for all existing families
2. Include this in the new entry's formulas: `{phi} ∪ BoxContent`

## The Timing Problem Illustrated

Processing `[Box beta, negBox alpha]` at family 0, time 0:

**Step 1: Box beta processing**
- Adds `Box beta` to family 0 at time 0
- Calls `addToAllFamilies 0 beta` - adds `beta` to family 0 (only family that exists)
- Result: family 0 has `{Box beta, beta}`

**Step 2: negBox alpha processing**
- Adds `negBox alpha` to family 0 at time 0
- Creates family 1 via `createNewFamily 0 (neg alpha)` - family 1 has only `{neg alpha}`
- **PROBLEM**: family 1 should also have `beta` (since `Box beta` is in family 0)

## Recommended Approach

### Option A: Modify createNewFamily to propagate BoxContent (RECOMMENDED)

```lean
def ModelSeed.createNewFamilyWithBoxContent (seed : ModelSeed) (timeIdx : Int)
    (phi : Formula) : ModelSeed × Nat :=
  let newFamIdx := seed.nextFamilyIdx
  -- Collect BoxContent from all existing families at timeIdx
  let boxContent := seed.collectBoxContentAt timeIdx
  let newEntry : SeedEntry := {
    familyIdx := newFamIdx,
    timeIdx := timeIdx,
    formulas := insert phi boxContent,  -- Include BoxContent!
    entryType := .modal_witness
  }
  ({ entries := seed.entries ++ [newEntry], nextFamilyIdx := newFamIdx + 1 }, newFamIdx)

def ModelSeed.collectBoxContentAt (seed : ModelSeed) (timeIdx : Int) : Set Formula :=
  { psi | ∃ famIdx ∈ seed.familyIndices, Formula.box psi ∈ seed.getFormulas famIdx timeIdx }
```

**Pros**:
- Clean fix at the source of the problem
- Only affects new family creation
- Matches the semantic requirement (all accessible worlds share Box content)

**Cons**:
- Must update `createNewFamily_preserves_*` theorems (about 15 theorems)
- Must prove new `collectBoxContentAt` lemmas
- Changes signature/behavior of core function

### Option B: Post-process to propagate BoxContent after buildSeedForList

Add a second pass that propagates BoxContent to all families:

```lean
def ModelSeed.propagateBoxContent (seed : ModelSeed) (timeIdx : Int) : ModelSeed :=
  let boxContent := seed.collectBoxContentAt timeIdx
  seed.familyIndices.foldl (fun s famIdx =>
    boxContent.fold (fun s' phi => s'.addFormula famIdx timeIdx phi .universal_target) s
  ) seed
```

**Pros**:
- Does not modify `createNewFamily`
- Simpler to implement incrementally
- Existing theorems remain valid

**Cons**:
- Adds complexity at usage sites
- Must call after every `buildSeedForList`
- May not compose well with incremental building

### Option C: Change buildSeedForList processing order

Process all Box formulas first, then process negBox formulas. This ensures all families exist before Box content is propagated.

**Pros**:
- No changes to core operations

**Cons**:
- Changes semantic order of processing
- May interact poorly with nested formulas
- Requires classifying formulas before processing

## Complexity Assessment

### Effort: Option A (Recommended)

| Component | Estimated Effort |
|-----------|------------------|
| Define `collectBoxContentAt` | 30 min |
| Modify `createNewFamily` → `createNewFamilyWithBoxContent` | 30 min |
| Update 15+ theorems referencing `createNewFamily` | 4-6 hours |
| Prove new BoxContent propagation lemmas | 2-3 hours |
| Fix integration points in `buildSeedAux` | 1-2 hours |
| Testing and verification | 1 hour |
| **Total** | **8-12 hours** |

### Risks

1. **Breaking existing proofs**: Many theorems depend on `createNewFamily` properties
   - Mitigation: Review all 15+ theorems, update systematically

2. **Infinite set issue**: `collectBoxContentAt` returns a `Set Formula`
   - Mitigation: In practice, seeds from finite formula lists have finite BoxContent

3. **Well-formedness changes**: New family entries have more formulas
   - Mitigation: Prove `collectBoxContentAt` produces consistent formulas

4. **Consistency preservation**: Must show BoxContent addition preserves SeedConsistent
   - Key lemma needed: If `Box psi ∈ fam.formulas` then `psi` is consistent with fam

### Dependencies

- `ModelSeed.getFormulas`
- `ModelSeed.familyIndices`
- `addFormula_preserves_*` family of theorems
- `buildSeedAux_preserves_*` family of theorems

## Alternative: Prove buildSeedForList_propagates_box Directly

Rather than modifying `createNewFamily`, we could try to prove the theorem directly by tracking Box formulas through the foldl:

The key insight is that `addToAllFamilies` adds `psi` to ALL families that exist when Box psi is processed. For families created AFTER that point, we need to show they were created from a seed that already had Box psi processed, and thus inherited the Box content through some other mechanism.

**Problem**: This is not true with current implementation. New families genuinely do NOT get the Box content.

## Confidence Level

**HIGH confidence** that Option A (modify createNewFamily) is the correct fix.

**Reasoning**:
1. The current behavior is clearly semantically incorrect - modal accessibility requires all accessible worlds to share Box content
2. The fix is localized to one function plus its theorems
3. The change aligns with the existing `BoxContent` infrastructure in SeedCompletion.lean and CoherentConstruction.lean
4. The alternative approaches (B, C) have worse composability

**MEDIUM confidence** on the 8-12 hour estimate.
- Could be faster if existing theorem infrastructure is more modular than expected
- Could be slower if there are hidden dependencies or proof brittleness

## References

- `ModelSeed.createNewFamily`: RecursiveSeed.lean lines 305-310
- `ModelSeed.addToAllFamilies`: RecursiveSeed.lean lines 271-274
- `buildSeedAux` (Box case): RecursiveSeed.lean lines 560-565
- `buildSeedAux` (negBox case): RecursiveSeed.lean lines 582-587
- `BoxContent` definition: SeedCompletion.lean line 144 and CoherentConstruction.lean line 109
- `buildSeedForList_propagates_box` (target): RecursiveSeed.lean lines 5917-5923
