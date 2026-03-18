# Research Report: Task #988

**Task**: 988 - dense_algebraic_completeness
**Date**: 2026-03-18
**Focus**: Evaluating approaches to avoid the CanonicalR-Order Bridge lemma while achieving zero sorries

## Summary

After analyzing the existing codebase, I identified that the current plan's bridge lemma approach is actually the mathematically cleanest solution. The alternative approaches either create more complexity or encounter fundamental architectural barriers. However, the dovetailed construction in DovetailedCoverage.lean provides an alternative path that bypasses TimelineQuot entirely.

## Findings

### 1. Current Architecture Analysis

The codebase has two parallel constructions:

**DenseTimeline/TimelineQuot Path**:
- `DenseTimeline.lean`: Dense staged construction using `StagedPoint`
- `CantorApplication.lean`: `TimelineQuot` as antisymmetrization of dense timeline
- `TimelineQuotAlgebra.lean`: Transfers AddCommGroup structure from Q
- `TimelineQuotCanonical.lean`: `timelineQuot_lt_implies_canonicalR` bridge (already proven!)
- `TimelineQuotCompleteness.lean`: Contains the sorry `timelineQuot_not_valid_of_neg_consistent`

**DovetailedBuild Path**:
- `DovetailedBuild.lean`: Dovetailed construction using `DovetailedPoint`
- `DovetailedCoverage.lean`: Sorry-free `dovetailedTimeline_has_future/past`
- `DovetailedCompleteness.lean`: Uses TimelineQuotCompleteness (inherits its sorry)

### 2. The Bridge Already Exists

The current plan proposes building a bridge lemma `canonicalR_implies_lt`. This is partially a misunderstanding:

1. **`timelineQuot_lt_implies_canonicalR`**: Already proven in `TimelineQuotCanonical.lean` (lines 109-201)
2. **`canonicalR_implies_timelineQuot_le`**: Already proven in same file (lines 208-257)

These lemmas establish:
- `t < t'` in TimelineQuot implies `CanonicalR (timelineQuotMCS t) (timelineQuotMCS t')`
- `CanonicalR (timelineQuotMCS t) (timelineQuotMCS t')` implies `t <= t'`

The bridge is already built. The problem is elsewhere.

### 3. The Real Blocker: forward_F/backward_P for TimelineQuotFMCS

Examining `ClosureSaturation.lean`, the actual sorries are in:
- `timelineQuotFMCS_forward_F` (line 658-659)
- `timelineQuotFMCS_backward_P` (line 679)

These require showing that when `F(phi)` is in an MCS at time t, there exists time s > t with `phi` in the MCS at s. The difficulty is that:

1. The TimelineQuot/DenseTimeline construction processes formulas by encoding order
2. Points added late (stage m > 2k+1 for formula with encoding k) miss having their F(phi) obligations processed
3. The `canonical_forward_F` lemma gives an arbitrary MCS, not one in the timeline

This is precisely what the dovetailed construction fixes, but DovetailedBuild uses `DovetailedPoint`, not `StagedPoint`/TimelineQuot.

### 4. Alternative Proof Paths Analyzed

**Option A: Direct DovetailedFMCS (Recommended)**

Build an FMCS directly over the dovetailed timeline, bypassing TimelineQuot:

```lean
noncomputable def dovetailedFMCS (root_mcs root_mcs_proof) : FMCS D where
  -- Use D = a custom type based on DovetailedPoint quotient
  mcs t := (extract_mcs_from_dovetailed t)
  forward_G := -- from dovetailedTimeline properties
  backward_H := -- from dovetailedTimeline properties
```

**Advantages**:
- DovetailedCoverage already has sorry-free `has_future`/`has_past`
- Directly uses the dovetailing that solved the coverage gap
- No need for TimelineQuot bridge complexity

**Challenges**:
- Need to define `DovetailedTimelineQuot` (antisymmetrization of dovetailed points)
- Need to transfer AddCommGroup structure via Cantor isomorphism
- Forward_F/backward_P proofs need adaptation

**Option B: Prove forward_F for TimelineQuot via Dovetailed Construction**

Show that every point in DenseTimeline is also in DovetailedTimeline:
1. `denseTimelineUnion subset dovetailedTimelineUnion` (needs proof)
2. Use DovetailedCoverage's coverage for forward_F

**Challenges**:
- The two constructions use different point types (`StagedPoint` vs `DovetailedPoint`)
- Requires isomorphism between the two timeline constructions

**Option C: Fix TimelineQuotFMCS_forward_F Directly**

Complete the sorry in ClosureSaturation.lean by showing:
- Density axiom ensures `F^n(phi)` for large n has encoding > stage when point entered
- That large-encoded formula's witness contains phi transitively

**Challenges**:
- Complex induction on witness chains
- Need to track formula content through CanonicalR

### 5. The Cleanest Mathematical Path

The mathematically cleanest solution recognizes:

1. **DovetailedBuild** already solves the coverage problem
2. **TimelineQuot** provides algebraic structure (AddCommGroup via Cantor)
3. The missing link is: dovetailed points should index TimelineQuot times

**Key Insight**: Build a `DovetailedTimelineQuot` directly:
```lean
-- Antisymmetrization of dovetailed timeline using DovetailedPoint.le
def DovetailedTimelineQuot :=
  Antisymmetrization (DovetailedTimelineElem root_mcs root_mcs_proof) (· <= ·)
```

Then:
- Cantor prerequisites (countable, dense, no endpoints) follow from DovetailedCoverage
- Forward_F and backward_P follow from `dovetailedTimeline_has_future/past`
- Truth lemma over this structure completes the proof

### 6. Sorries to Fill

| File | Sorry | Resolution Path |
|------|-------|-----------------|
| `TimelineQuotCompleteness.lean:127` | `timelineQuot_not_valid_of_neg_consistent` | Main target |
| `ClosureSaturation.lean:658,679` | `timelineQuotFMCS_forward_F`, `backward_P` | Use dovetailed coverage |
| `ClosureSaturation.lean:724` | `modal_backward` | Singleton BFMCS issue |
| `TimelineQuotCanonical.lean:397` | `timelineQuotMCS_at_zero_eq_root` | Needs root point tracking |

## Recommendations

### Primary Recommendation: DovetailedTimelineQuot Approach

**Phase 1: Define DovetailedTimelineQuot (3h)**
1. Create `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
2. Define `DovetailedTimelineElem` as subtype of `DovetailedPoint`
3. Define `DovetailedTimelineQuot` as antisymmetrization
4. Prove Cantor prerequisites using DovetailedBuild lemmas

**Phase 2: Cantor Isomorphism (2h)**
1. Prove `DovetailedTimelineQuot ≃o Q` via `Order.iso_of_countable_dense`
2. Transfer AddCommGroup, IsOrderedAddMonoid from Q
3. Establish DenseTemporalFrame instance

**Phase 3: DovetailedFMCS Construction (4h)**
1. Define FMCS over DovetailedTimelineQuot
2. Prove forward_G, backward_H using existing DovetailedCoverage theorems
3. Prove forward_F, backward_P from `dovetailedTimeline_has_future/past`

**Phase 4: Truth Lemma over DovetailedTimelineQuot (6h)**
1. Adapt `ParametricTruthLemma` to DovetailedTimelineQuot
2. Use TemporalCoherentFamily structure
3. Complete box case via singleton or multi-family BFMCS

**Phase 5: Fill timelineQuot_not_valid_of_neg_consistent (4h)**
1. Connect DovetailedTimelineQuot to the original TimelineQuot
2. Or: redefine dense completeness theorem to use DovetailedTimelineQuot directly

### Alternative: Bypass TimelineQuot Entirely

A cleaner architectural approach:
1. Delete TimelineQuotCompleteness.lean
2. Modify DovetailedCompleteness.lean to use DovetailedTimelineQuot directly
3. State completeness as: `valid_over DovetailedTimelineQuot phi -> provable phi`

This avoids the need to connect two separate constructions.

## Risk Assessment

| Approach | Risk | Effort | Cleanliness |
|----------|------|--------|-------------|
| DovetailedTimelineQuot (recommended) | Low | 19h | High |
| Fix TimelineQuotFMCS_forward_F | Medium | 15h | Medium |
| Connect two constructions | High | 22h | Low |

## Next Steps

1. Create DovetailedTimelineQuot.lean with basic definitions
2. Prove Cantor prerequisites (leveraging existing DovetailedCoverage)
3. Establish algebraic transfer from Q
4. Build FMCS with forward_F/backward_P from coverage lemmas
5. Adapt truth lemma infrastructure
6. Complete dense completeness theorem

## References

- `DovetailedCoverage.lean`: Sorry-free coverage lemmas
- `DovetailedBuild.lean`: Dovetailed construction infrastructure
- `TimelineQuotCanonical.lean`: Existing bridge lemmas
- `ClosureSaturation.lean`: Documents the forward_F gap
- `ParametricTruthLemma.lean`: Template for truth lemma

## Context Extension Recommendations

None - the architecture is well-documented in existing files.
