# Research Report: Task #988

**Task**: dense_algebraic_completeness
**Date**: 2026-03-18
**Focus**: In light of completing task 982, research the most mathematically correct and elegant completion path

## Summary

Task 982's completion fundamentally changes the landscape for task 988. The dovetailed construction now provides sorry-free coverage lemmas (`has_future`, `has_past`), resolving the primary blockers identified in earlier research. This report analyzes the remaining gap and recommends the mathematically cleanest resolution path.

## Current State Analysis

### Task 982 Deliverables (COMPLETED)

| File | Sorries | Key Theorems |
|------|---------|--------------|
| `DovetailedCoverage.lean` | 0 | `dovetailedTimeline_has_future`, `dovetailedTimeline_has_past` |
| `DovetailedBuild.lean` | 0 | Core dovetailed construction |
| `Dovetailing.lean` | 0 | Infrastructure and helpers |
| `DovetailedCompleteness.lean` | 3 | `dovetailed_dense_completeness` (uses sorry) |

**Key Insight**: The density argument (F^i formulas with unboundedly growing encodings) ensures every timeline point eventually gets processed, providing sorry-free forward/backward seriality.

### Remaining Sorry: `timelineQuot_not_valid_of_neg_consistent`

Location: `TimelineQuotCompleteness.lean:127`

```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (φ : Formula) (h_cons : ContextConsistent [φ.neg]) :
    let M₀ := lindenbaumMCS [φ.neg] h_cons
    let h_M₀_mcs := lindenbaumMCS_is_mcs [φ.neg] h_cons
    let D := TimelineQuot M₀ h_M₀_mcs
    ...
    ¬@valid_over D acg inferInstance oam φ := by
  sorry
```

**What it needs**: Construct a countermodel over TimelineQuot showing φ is not valid when φ.neg is consistent.

### Task 988's Original Blockers (Status Update)

| Blocker | Previous Status | Current Status |
|---------|-----------------|----------------|
| `forward_F` witness gap | BLOCKED | **RESOLVED** by DovetailedCoverage |
| `backward_P` witness gap | BLOCKED | **RESOLVED** by DovetailedCoverage |
| `modal_backward` singleton | BLOCKED | **STILL AN ISSUE** (architectural) |

## Mathematical Analysis

### The Two-Path Architecture

**Path A: TimelineQuot-native (Task 982's approach)**
```
TimelineQuot M₀
    |
    v
dovetailed_dense_completeness (uses timelineQuot_not_valid_of_neg_consistent)
    |
    v
valid_dense φ → provable φ
```

**Path B: D = Rat via Algebraic Path (Task 988's original)**
```
TimelineQuot M₀
    |
    | cantor_isomorphism
    v
BFMCS Rat
    |
    | dense_representation_conditional
    v
valid_dense φ → provable φ
```

### Why Path A is Mathematically Cleaner

1. **Directness**: No transport through Cantor isomorphism needed
2. **Infrastructure reuse**: Uses existing TimelineQuot algebraic instances
3. **Conceptual unity**: The countermodel domain matches the construction domain
4. **Avoids modal_backward**: Direct truth lemma construction doesn't require BFMCS multi-family structure

### The Key Mathematical Insight

The `timelineQuot_not_valid_of_neg_consistent` sorry requires constructing:

1. **TaskFrame F over TimelineQuot** - Already exists as `DenseCanonicalTaskFrame` specialized to TimelineQuot
2. **TaskModel M with MCS valuation** - Atom p true at world W iff p ∈ W.mcs
3. **Omega set (shift-closed)** - Standard canonical Omega construction
4. **History τ and time t** - From Lindenbaum MCS root

The dovetailed construction provides the missing piece: **temporal coherence for truth lemma backward direction**.

## Recommended Approach: Direct TimelineQuot Truth Lemma

### Overview

Fill `timelineQuot_not_valid_of_neg_consistent` directly using the dovetailed construction's coverage properties, without going through BFMCS transport.

### Architecture

```
lindenbaumMCS [φ.neg] h_cons
    |
    v
TimelineQuot M₀ h_M₀_mcs (D = TimelineQuot)
    |
    v
dovetailedFMCS : TemporalCoherentFamily (TimelineQuot M₀)
    |  - mcs t = MCS at TimelineQuot representative
    |  - forward_F from dovetailedTimeline_has_future
    |  - backward_P from dovetailedTimeline_has_past
    v
Direct truth lemma over TimelineQuot
    |
    v
φ.neg ∈ root MCS → ¬truth_at ... φ
    |
    v
¬valid_over TimelineQuot φ
```

### Key Construction: `dovetailedFMCS`

```lean
/-- FMCS over TimelineQuot using the dovetailed construction. -/
def dovetailedFMCS (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs) :
    TemporalCoherentFamily (TimelineQuot root_mcs root_mcs_proof) where
  mcs t := (ofAntisymmetrization (· ≤ ·) t).1.mcs
  is_mcs t := (ofAntisymmetrization (· ≤ ·) t).1.is_mcs
  root_contains_formulas := root_mcs_proof  -- adapted
  forward_F t φ h_F := by
    -- Use dovetailedTimeline_has_future
    -- Connect CanonicalR witness to TimelineQuot < order
    sorry  -- ~20 lines of proof
  backward_P t φ h_P := by
    -- Use dovetailedTimeline_has_past
    -- Connect CanonicalR witness to TimelineQuot < order
    sorry  -- ~20 lines of proof
```

### The CanonicalR-to-Order Connection

The key lemma needed:

```lean
/-- CanonicalR implies < in TimelineQuot order. -/
theorem canonicalR_implies_lt
    (p q : DenseTimelineElem root_mcs root_mcs_proof)
    (hp : p ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (hq : q ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (h_R : CanonicalR p.1.mcs q.mcs) :
    toAntisymmetrization (· ≤ ·) ⟨p, hp⟩ < toAntisymmetrization (· ≤ ·) ⟨q, hq⟩
```

This follows from the timeline construction invariants: CanonicalR alignment with the staged order.

## Implementation Plan

### Phase 1: CanonicalR-Order Bridge [4h]

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBridge.lean`

1. Define extraction of MCS from TimelineQuot element
2. Prove CanonicalR → < for timeline elements
3. Prove < → CanonicalR for timeline elements (if needed)

### Phase 2: dovetailedFMCS Construction [6h]

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean`

1. Define `dovetailedFMCS : TemporalCoherentFamily (TimelineQuot M₀)`
2. Prove `forward_F` using DovetailedCoverage + bridge
3. Prove `backward_P` using DovetailedCoverage + bridge

### Phase 3: Direct Truth Lemma [8h]

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean`

1. Define TaskFrame over TimelineQuot using parametric canonical frame
2. Define TaskModel with MCS valuation
3. Define Omega set (shift-closed canonical Omega)
4. Prove truth lemma: φ ∈ mcs t ↔ truth_at M Omega τ t φ

### Phase 4: Fill the Sorry [2h]

**File**: `TimelineQuotCompleteness.lean`

1. Apply truth lemma to show φ.neg ∈ root MCS implies ¬truth_at for φ
2. Complete `timelineQuot_not_valid_of_neg_consistent`

### Phase 5: Wire Dense Completeness [2h]

**File**: `DovetailedCompleteness.lean` or new `DenseCompletenessWiring.lean`

1. Verify `dovetailed_dense_completeness` now compiles without sorry
2. Add `dense_algebraic_completeness : valid_dense φ → provable φ`

## Estimated Effort

| Phase | Hours | Risk |
|-------|-------|------|
| Phase 1 | 4h | Low - straightforward order theory |
| Phase 2 | 6h | Medium - needs careful DovetailedCoverage integration |
| Phase 3 | 8h | Medium-High - largest component |
| Phase 4 | 2h | Low - mechanical application |
| Phase 5 | 2h | Low - wiring |
| **Total** | **22h** | |

## Alternative: BFMCS Transport Path

If the direct approach proves intractable, an alternative exists:

### Transport Path Architecture

```lean
-- Transport FMCS through order isomorphism
def fmcs_transport (iso : TimelineQuot ≃o Rat) (fam : FMCS TimelineQuot) : FMCS Rat where
  mcs r := fam.mcs (iso.symm r)
  is_mcs r := fam.is_mcs (iso.symm r)
  root_contains_formulas := ...

-- Transport BFMCS
def bfmcs_transport (iso : TimelineQuot ≃o Rat) (B : BFMCS TimelineQuot) : BFMCS Rat

-- Then apply dense_representation_conditional
```

**Advantages**: Reuses more existing parametric infrastructure
**Disadvantages**:
- Requires proving temporal coherence transport (~10h additional)
- Still needs to address modal_backward for BFMCS (singleton issue)
- More complex dependency chain

## Risk Analysis

| Risk | Impact | Mitigation |
|------|--------|------------|
| CanonicalR-order bridge is harder than expected | Medium | The staged construction already has invariants relating these; may need to expose them |
| Truth lemma induction on formula structure is complex | Medium | Can adapt existing ParametricTruthLemma structure |
| Shift-closed Omega construction is non-trivial | Low | Existing ShiftClosedParametricCanonicalOmega provides template |
| Timeline element extraction from quotient is tricky | Low | `ofAntisymmetrization` already provides this |

## Comparison with Previous Plans

| Aspect | Plan v6 | This Proposal |
|--------|---------|---------------|
| Primary path | Fix ClosureSaturation sorries | Direct TimelineQuot truth lemma |
| Leverages task 982 | Partially (expected DovetailedTimelineQuot) | Fully (uses DovetailedCoverage) |
| BFMCS approach | Singleton (problematic) | Avoids BFMCS entirely |
| Estimated hours | 17-20h | 22h |
| Architectural cleanliness | Moderate | High |
| Sorries addressed | 4 in ClosureSaturation | 1 in TimelineQuotCompleteness |

## Success Criteria

- [ ] `timelineQuot_not_valid_of_neg_consistent` filled with no sorry
- [ ] `dovetailed_dense_completeness` compiles with no sorry
- [ ] `dense_algebraic_completeness : valid_dense φ → provable φ` proved
- [ ] `lake build Bimodal` passes
- [ ] No new axioms introduced
- [ ] Sorry count in Theories/ decreases by at least 1

## Conclusion

Task 982's completion provides the critical coverage lemmas needed to resolve task 988. The recommended approach fills `timelineQuot_not_valid_of_neg_consistent` directly via a TimelineQuot-native truth lemma, avoiding the BFMCS modal_backward architectural issue entirely. This path is mathematically cleaner and architecturally simpler than the original BFMCS transport approach.

## Next Steps

1. `/plan 988` to create implementation plan based on this research
2. Implement Phase 1 (CanonicalR-Order Bridge) first as proof of concept
3. If Phase 1 succeeds cleanly, proceed with remaining phases

## References

- Task 982 completion summary: `specs/982_wire_dense_completeness_domain_connection/summaries/03_density-resolution-summary.md`
- DovetailedCoverage.lean: Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverage.lean
- TimelineQuotCompleteness.lean: Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean
- TemporalCoherence.lean: Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean
- DenseInstantiation.lean: Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean
