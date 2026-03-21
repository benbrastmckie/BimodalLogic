# Teammate B: Alternative Approaches Analysis

**Task**: 881 - Construct modally saturated BMCS
**Session**: sess_1771302909_fb93d5
**Date**: 2026-02-16
**Focus**: Analyze alternatives to bypass `buildSeedForList_propagates_box` blocker

## Key Findings

1. **The blocker is fundamental to the current architecture**: `createNewFamily` creates a brand new seed entry with ONLY the witness formula. It does NOT copy BoxContent from existing families, so when later Box formulas are processed, they only propagate to families that exist AT THAT MOMENT.

2. **`buildSeedForList_propagates_box` is NOT strictly needed for the final goal**: The lemma serves `modal_forward` in SeedBMCS.lean, but SaturatedConstruction.lean has an alternative path via `exists_fullySaturated_extension` that handles box_coherence differently.

3. **Processing order (Box-last) does not fully solve the problem**: While it would help for formulas in the initial list, recursive `buildSeedAux` calls create families mid-processing, so ordering the top-level list doesn't prevent the issue.

4. **The existing codebase has two proven approaches for box_coherence**:
   - `FamilyCollection` structure with explicit `box_coherence` field
   - Lindenbaum extension combined with MCS negation completeness

## Option B: Remove the Lemma

### Analysis

`buildSeedForList_propagates_box` exists to support `modal_forward` in the seed-based BMCS construction (SeedBMCS.lean line 89). However, examining the dependency chain:

**Downstream usage**:
- `SeedBMCS.buildSeedBMCS` uses it for `modal_forward` (line 89, sorry)
- This flows to `seedBMCS_modal_forward` theorem

**Alternative paths in codebase**:
- `SaturatedConstruction.FamilyCollection.toBMCS` (line 278) achieves `modal_forward` via the `box_coherence` field of `FamilyCollection`, NOT through seed propagation
- The `exists_fullySaturated_extension` theorem (line 873) is SORRY-FREE and provides full modal saturation

**Critical insight**: The final goal `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:822) does NOT require seed-based construction. It needs:
1. A temporally coherent initial family
2. Modal saturation (witness families for all Diamond formulas)
3. Box coherence across all families

The FamilyCollection approach provides (2) and (3) directly. Only (1) requires RecursiveSeed.

### Verdict

**YES, we can potentially remove this lemma** by restructuring:
- Use RecursiveSeed ONLY for the eval_family's temporal coherence
- Use FamilyCollection + Zorn (exists_fullySaturated_extension) for modal saturation
- Box coherence comes from FamilyCollection's `box_coherence` field, not seed propagation

### Proof Structure Without This Lemma

```
fully_saturated_bmcs_exists_int
  |
  +-- Step 1: Build temporally coherent eval_family
  |     Use: buildSeed for single formula, seedToIndexedFamily
  |     (No buildSeedForList needed - one formula at a time)
  |
  +-- Step 2: Create initial FamilyCollection
  |     Use: initialFamilyCollection with box_coherence = trivial
  |     (Single constant family trivially satisfies box_coherence)
  |
  +-- Step 3: Saturate via Zorn
  |     Use: exists_fullySaturated_extension (SORRY-FREE!)
  |     box_coherence maintained by construction (see line 880)
  |
  +-- Result: BMCS via FamilyCollection.toBMCS
```

## Option C: Constrain Processing Order

### Analysis

**Box-last processing approach**:
1. Partition input formulas: `(non_box_formulas, box_formulas)`
2. Process non-box first (creates families)
3. Process box formulas last (propagates to all existing families)

**Why this doesn't fully work**:

```lean
-- When processing neg(Box psi), createNewFamily is called
| Formula.imp (Formula.box psi) Formula.bot, famIdx, timeIdx, seed =>
    let (seed2, newFamIdx) := seed1.createNewFamily timeIdx (Formula.neg psi)
    buildSeedAux (Formula.neg psi) newFamIdx timeIdx seed2  -- RECURSIVE!
```

The recursion can create new families DURING processing of any formula, not just at the top level. Even if we sort the input list, the recursive calls don't respect ordering.

**Partial solution**:
- Sort only delays the problem
- Would need to fundamentally restructure `buildSeedAux` to:
  1. Collect ALL families that will be created first (without adding formulas)
  2. Then propagate Box content to all collected families
  3. Finally add formulas to families

This is essentially Option D (different architecture).

### Verdict

**NOT recommended as standalone fix**. Ordering helps marginally but doesn't address the fundamental issue that families are created during recursive processing.

## Option D: Alternative Architecture

### Pattern 1: FamilyCollection with Explicit box_coherence

The codebase already has this pattern in SaturatedConstruction.lean:

```lean
structure FamilyCollection (D : Type*) (phi : Formula) where
  families : Set (IndexedMCSFamily D)
  nonempty : families.Nonempty
  eval_family : IndexedMCSFamily D
  eval_family_mem : eval_family ∈ families
  box_coherence : forall fam in families, forall psi t,
    Formula.box psi in fam.mcs t -> forall fam' in families, psi in fam'.mcs t
```

Box coherence is a PROPERTY OF THE COLLECTION, not something that needs to be proven through seed propagation.

**How it's maintained**:
- `exists_fullySaturated_extension` (line 873) uses Zorn's lemma
- The set `S` is defined to include `box_coherence_pred` (line 880)
- New families are only added if they preserve box_coherence
- Witness construction explicitly ensures box_coherence (line ~1000)

### Pattern 2: Constant Families with Lindenbaum

```lean
-- From SaturatedConstruction.lean
def allConstant (families : Set (IndexedMCSFamily D)) : Prop :=
  forall fam in families, isConstant fam

def isConstant (fam : IndexedMCSFamily D) : Prop :=
  forall t t' : D, fam.mcs t = fam.mcs t'
```

For constant families, box_coherence is achievable because:
1. MCS at all times are identical
2. If Box psi is in one MCS, it's in all MCSes of that family
3. New witness families are built with `BoxContent` included in the MCS

### Pattern 3: Two-Phase Construction

From the implementation plan Phase 3 design:

```lean
def buildModalWitnessFamily
    (psi : Formula)
    (BoxContent : Set Formula)
    (h_cons : SetConsistent ({psi} union BoxContent)) : IndexedMCSFamily Int :=
  let seed := buildSeed psi  -- Start with psi
  let seedWithBox := seed.addBoxContent BoxContent  -- Add BoxContent at all positions
  seedToIndexedFamily seedWithBox (by ... prove consistency ...)
```

This approach:
1. Computes `BoxContent` from existing families FIRST
2. Adds BoxContent to ALL positions in the new seed
3. Avoids the timing issue (content added after families exist)

### Recommended Architecture

**Hybrid approach**:
1. Use `buildSeed` for SINGLE-FORMULA temporal coherence (eval_family only)
2. Use `FamilyCollection` with explicit `box_coherence` field for multi-family structure
3. Use `exists_fullySaturated_extension` for saturation (Zorn's lemma)
4. Witness families created via `constantWitnessFamily` with BoxContent

This avoids `buildSeedForList_propagates_box` entirely because:
- Single-formula buildSeed doesn't need cross-family box propagation
- Multi-family box_coherence is a FamilyCollection invariant
- Witness construction explicitly includes BoxContent

## Recommended Path Forward

**Option D (Alternative Architecture) is recommended**, specifically:

1. **Abandon `buildSeedForList_propagates_box` entirely** - it's fighting the architecture

2. **Narrow Phase 1 scope** to single-formula seed building:
   - Keep `buildSeed` (single formula)
   - Keep `seedToIndexedFamily` (single family)
   - Remove/archive `buildSeedForList` machinery

3. **Use FamilyCollection for multi-family structure**:
   - Initial collection: single constant family from eval_family
   - Saturation: `exists_fullySaturated_extension` (SORRY-FREE!)
   - Box coherence: maintained by FamilyCollection invariant

4. **Phase 2-4 wire to FamilyCollection**:
   - `seedToIndexedFamily` produces eval_family
   - `initialFamilyCollection` wraps it
   - `saturate` applies Zorn extension
   - `toBMCS` produces final BMCS

**Why this works**:
- `exists_fullySaturated_extension` is ALREADY SORRY-FREE
- Box coherence is an invariant of FamilyCollection, not a property to prove through seeds
- We only need RecursiveSeed for temporal coherence of ONE family

## Confidence Level

**HIGH confidence** for the following reasons:

1. **Existing infrastructure**: `exists_fullySaturated_extension` is sorry-free and proven to work

2. **Clear dependency analysis**: `buildSeedForList_propagates_box` is only needed if we insist on seed-based multi-family construction, which is not the only path

3. **Architectural precedent**: The FamilyCollection approach is already the "official" path in SaturatedConstruction.lean

4. **Scope reduction**: This approach REDUCES the problem from "prove box propagation through complex foldl" to "wire existing infrastructure together"

**Risk**: The one remaining challenge is ensuring witness families are temporally coherent (constant families need temporally saturated MCS). This is the same challenge noted in Phase 3-4 of the plan, but it's a DIFFERENT problem from `buildSeedForList_propagates_box`.

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (lines 300-310, 560-590, 5912-5924)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` (lines 220-285, 873-1160)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean` (lines 85-95)
- `/home/benjamin/Projects/ProofChecker/specs/881_modally_saturated_bmcs_construction/plans/implementation-004.md`
