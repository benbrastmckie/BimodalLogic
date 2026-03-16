# Research Report: Teammate B - Alternative Approaches and Existing Infrastructure

**Task**: 979 - Remove discrete_Icc_finite_axiom and prove stage-bounding lemma
**Focus**: Alternative proof paths and existing infrastructure analysis
**Date**: 2026-03-16

## Executive Summary

Analysis of existing infrastructure reveals that the stage-bounding approach is the most viable path. The key insight is that `discreteStagedBuild` produces finite sets at each stage, and every quotient element has a representative at some finite stage. The proof reduces to showing that elements in an interval `Icc a b` must have representatives no later than `max(minStage a, minStage b)`.

## Existing Infrastructure

### Core Definitions (StagedExecution.lean)

| Definition | Location | Purpose |
|------------|----------|---------|
| `discreteStagedBuild` | Line 1005 | Recursive construction: stage 0 = root, stage n+1 = evenStage(stage n, n, n+1) |
| `discreteStagedBuild_monotone` | Line 1016 | `stage n` subset of `stage n+1` |
| `discreteStagedBuild_monotone_le` | Line 1023 | `m <= n` implies `stage m` subset of `stage n` |
| `discreteStagedBuild_linear` | Line 1093 | Every stage is linearly ordered |
| `buildDiscreteStagedTimeline` | Line 1140 | StagedTimeline wrapper with union |

### Core Definitions (DiscreteTimeline.lean)

| Definition | Location | Purpose |
|------------|----------|---------|
| `DiscreteTimelineElem` | Line 76 | `{ p : StagedPoint // p in timeline.union }` |
| `DiscreteTimelineQuot` | Line 105 | `Antisymmetrization DiscreteTimelineElem (<=)` |
| `minStage` | Line 200 | Minimum stage where quotient element has representative |
| `minStage_spec` | Line 204 | At minStage, there exists a representative |
| `discrete_Icc_finite_axiom` | Line 244 | **THE AXIOM TO ELIMINATE** |

### CanonicalR Properties (CanonicalFrame.lean, StagedExecution.lean)

| Property | Status | Notes |
|----------|--------|-------|
| `CanonicalR` transitive | Not proven directly | Follows from G-closure |
| `CanonicalR_irreflexive` | Axiomatized | In CanonicalIrreflexivityAxiom.lean |
| `canonical_forward_reachable_linear` | Proven | Line 181 - key linearity |
| `canonical_backward_reachable_linear` | Proven | Line 287 - symmetric |

### Mathlib Infrastructure

| Component | Location | Relevance |
|-----------|----------|-----------|
| `LocallyFiniteOrder.ofFiniteIcc` | Mathlib | Exactly what the code uses |
| `OrderEmbedding.locallyFiniteOrder` | Mathlib | Transfer via embedding - alternative path |
| `Antisymmetrization` | Mathlib | **No LocallyFiniteOrder instance exists** |
| `orderIsoIntOfLinearSuccPredArch` | Mathlib | Used in DurationTransfer for final isomorphism |
| `LinearLocallyFiniteOrder.succFn` | Mathlib | GLB of Ioi - used for SuccOrder |

## Alternative Approaches Analysis

### Approach 1: Direct Stage Bounding (RECOMMENDED)

**Concept**: Prove that for any `c in Set.Icc a b`, the representative of `c` appears at stage `<= max(minStage a, minStage b)`.

**Key Insight**: The quotient ordering respects stage membership in a controlled way:
- If `c` is in `Icc a b`, then `c`'s representative must be "between" representatives of `a` and `b`
- The discreteStagedBuild adds points monotonically (no removal)
- New points are added as F/P witnesses for existing points

**Required Lemma**:
```lean
theorem stage_bounding_for_interval
    (a b c : DiscreteTimelineQuot root_mcs root_mcs_proof)
    (hc : c in Set.Icc a b) :
    minStage c <= max (minStage a) (minStage b)
```

**Proof Strategy**:
1. Let `N = max(minStage a, minStage b)`
2. Representatives of `a`, `b` exist at stage `N`
3. If `c`'s representative first appeared at stage `M > N`, it was added as a witness for some formula
4. That witness would be "beyond" the interval `[a, b]` by construction
5. Contradiction with `c in Icc a b`

**Difficulty**: Medium-High. The main challenge is formalizing step 4.

### Approach 2: Order Embedding to Integers

**Concept**: Since we already prove `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, use `orderIsoIntOfLinearSuccPredArch` to get `T ≃o Z`, then transfer `LocallyFiniteOrder` via the embedding.

**Obstacle**: CIRCULAR DEPENDENCY
- `orderIsoIntOfLinearSuccPredArch` requires `IsSuccArchimedean`
- `IsSuccArchimedean` in current code comes from `LocallyFiniteOrder` (line 166 in LinearLocallyFinite.lean)
- We need `LocallyFiniteOrder` to eliminate the axiom

**Alternative within this approach**: Prove `IsSuccArchimedean` directly without `LocallyFiniteOrder`, then use the embedding.

**Required**: Prove `IsSuccArchimedean` from:
1. NoMaxOrder + NoMinOrder (already have)
2. Discrete structure (no dense accumulation)

**Difficulty**: Very High. Would need to extract the DF frame condition at MCS level.

### Approach 3: Countable + Linear Implies Locally Finite?

**Concept**: The timeline is countable (`discrete_staged_timeline_countable`) and linear. Does this imply `LocallyFiniteOrder`?

**Result**: **NO**. Mathlib has:
- `Countable.of_linearOrder_locallyFiniteOrder` (line 444, LinearLocallyFinite.lean) - the CONVERSE
- LocallyFiniteOrder + LinearOrder implies Countable, not vice versa

**Counterexample**: Q (rationals) is countable and linear but NOT locally finite.

**Verdict**: This approach is not viable.

### Approach 4: Induction on Quotient Elements

**Concept**: Use well-founded induction on the stage structure.

**Observation**: The quotient elements are equivalence classes of `DiscreteTimelineElem`. The stage of a class could be defined as the minimum stage of any representative.

**Difficulty**: Medium. Similar to Approach 1 but structured differently.

### Approach 5: Direct Finset Construction

**Concept**: Instead of proving `Set.Icc a b` is finite, directly construct `Finset.Icc a b`.

**Method**:
1. Given `a, b : DiscreteTimelineQuot`, compute `N = max(minStage a, minStage b)`
2. Take `discreteStagedBuild N` (a Finset StagedPoint)
3. Filter to those between representatives of `a` and `b`
4. Map through the quotient

**Technical Issue**: The quotient map is not injective, so multiple StagedPoints may map to the same quotient element. Need to handle duplicates.

**Required**: Prove the filtered/mapped set equals `Set.Icc a b`.

**Difficulty**: Medium. More constructive than Approach 1.

## Recommended Path

**Primary**: Approach 1 (Direct Stage Bounding)

**Justification**:
1. Aligns with existing `minStage` infrastructure
2. Clear mathematical intuition: "witnesses don't escape intervals"
3. Avoids circular dependencies
4. Uses existing `discreteStagedBuild_monotone_le` lemma

**Secondary**: Approach 5 (Direct Finset Construction) as backup

**Key Lemmas Needed**:

1. `stage_bounding_for_interval` - the main theorem
2. `quotient_between_implies_rep_between` - helper relating quotient order to representative order
3. `witness_not_between_parents` - F/P witnesses are strictly beyond their parent

## Confidence Level

**Confidence**: 70%

**Risk Factors**:
- The "witness not between parents" property needs careful formalization
- Quotient complications may arise (same MCS at different stages = same quotient element)
- The `CanonicalR_irreflexive` axiom may be needed more heavily than expected

**Mitigation**:
- Can fall back to Approach 5 if stage bounding proves too complex
- Approach 5 is more constructive and may be easier to verify

## Appendix: Key Code References

### DiscreteTimeline.lean Line 244 (The Axiom)
```lean
axiom discrete_Icc_finite_axiom :
    ∀ (a b : DiscreteTimelineQuot root_mcs root_mcs_proof), (Set.Icc a b).Finite
```

### Current Usage (Line 258)
```lean
noncomputable instance : LocallyFiniteOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
  LocallyFiniteOrder.ofFiniteIcc (discrete_Icc_finite root_mcs root_mcs_proof)
```

### minStage Definition (Line 200)
```lean
noncomputable def minStage (a : DiscreteTimelineQuot root_mcs root_mcs_proof) : Nat :=
  Nat.find (exists_stage_of_quotient_elem root_mcs root_mcs_proof a)
```

### discreteStagedBuild (StagedExecution.lean Line 1005)
```lean
noncomputable def discreteStagedBuild : Nat -> Finset StagedPoint
  | 0 => stage0 root_mcs root_mcs_proof
  | n + 1 =>
    let prev := discreteStagedBuild n
    evenStage prev n (n + 1)
```
