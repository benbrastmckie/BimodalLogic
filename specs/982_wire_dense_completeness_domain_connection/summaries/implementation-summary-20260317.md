# Implementation Summary: Task 982 - Wire Dense Completeness Domain Connection

**Date**: 2026-03-17
**Sessions**: sess_1773773089_a7e2f9 (earlier), sess_1773776521_d8f4a2 (latest)
**Status**: Partial (Analysis complete, implementation blocked by domain mismatch)
**Plan Version**: v6 (Domain Transfer Approach)

## Completed Work

### Phase 1-2: Core Linking and FMCS (Pre-existing)
- `timelineQuot_lt_implies_canonicalR`: Links TimelineQuot ordering to CanonicalR
- `timelineQuotFMCS`: FMCS structure over TimelineQuot with forward_G/backward_H

### Phase 3: Witness Family Constructor (COMPLETED)
**File**: `Theories/Bimodal/Metalogic/StagedConstruction/WitnessChainFMCS.lean`

Created witness MCS construction primitives:
- `buildWitnessMCS`: Construct witness MCS from Diamond formula membership
- `buildWitnessMCS_contains_psi`: Witness contains the required formula
- `buildWitnessMCS_is_mcs`: Witness is maximal consistent
- `buildWitnessMCS_contains_boxcontent`: Witness preserves BoxContent
- `boxcontent_subset_implies_box_forward`: BoxContent containment implies modal forward

**Build Status**: Zero sorries, zero axioms introduced.

### Phase 4: Closure-Saturated BFMCS Construction (PARTIAL)
**File**: `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
**File**: `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` (iteration 2)

#### Iteration 1 Progress:
- `timelineQuot_modal_forward_singleton` (PROVEN): T-axiom closure for singleton
- `timelineQuotFMCS_forward_F` signature (SORRY): Temporal forward F coherence
- `timelineQuotFMCS_backward_P` signature (SORRY): Temporal backward P coherence
- `timelineQuotSingletonBFMCS` structure (SORRY in modal_backward)
- `timelineQuotSingletonBFMCS_temporally_coherent` (depends on forward_F/backward_P)

#### Iteration 2 Progress:
- Added `forward_witness_at_stage_with_phi` (CantorPrereqs): Witness contains phi
- Added `backward_witness_at_stage_with_phi` (CantorPrereqs): Symmetric
- **MAIN CASE PROVEN**: `timelineQuotFMCS_forward_F` for m <= 2k (point in build before formula processed)
- **EDGE CASES BLOCKED**: m > 2k case requires F-witness chaining lemmas
- **EDGE CASES BLOCKED**: Density point case requires additional infrastructure

**Key Findings**:
1. **Constant witness families are flawed**: Cannot satisfy temporal coherence when F(phi) in M but phi not in M
2. **Singleton BFMCS cannot satisfy modal_backward**: Fundamental limitation without saturation
3. **Need multi-family modal saturation**: Use `saturated_modal_backward` (proven axiom-free)
4. **Main case forward_F works**: When point p is in build at stage m <= 2k, witness exists at stage 2k+1
5. **Edge case gap**: Points added after formula phi is processed (m > 2k) need F-witness chaining

**Build Status**: 4 sorries (2 edge cases in forward_F, backward_P, modal_backward)

## Current Blockers

### Blocker 1: timelineQuotFMCS_forward_F (Edge Cases)
**Main case (m <= 2k)**: PROVEN
**Edge case (m > 2k)**: Blocked - need F-witness chaining lemmas
**Edge case (density points)**: Blocked - need similar chaining

**Issue**: When point p enters the staged build at stage m > 2k (where k = encode(phi)), the formula phi was already processed. The direct `forward_witness_at_stage` approach doesn't apply.

**Path**: Prove F-witness chaining: if P generates witness M at stage m, and P has witness W for phi at stage 2k+1 < m, then either:
- CanonicalR(M, W) (M can reach W), or
- There's an intermediate witness reachable from M

### Blocker 2: timelineQuotFMCS_backward_P
**Issue**: Symmetric to forward_F
**Path**: Add `backward_witness_at_stage_with_phi` (done), prove symmetric cases

### Blocker 3: timelineQuotSingletonBFMCS.modal_backward
**Issue**: Singleton BFMCS cannot satisfy modal_backward.
**Path**: Build multi-family BFMCS with modal saturation, use `saturated_modal_backward`.

## Architectural Analysis

### Why Constant Families Fail

The plan (v5) suggested constant FMCS (same MCS at every time) for witness families. This is flawed:
- If F(phi) in M but phi not in M, then {F(phi), neg(phi)} is in M
- Constant family with MCS=M has phi not at any time
- Therefore forward_F fails for that family

Evidence: ModalSaturation.lean:193-209 explicitly warns against constant witness families.

### Why Singleton BFMCS Fails

For singleton BFMCS:
- `modal_forward`: Box phi in mcs(t) -> phi in mcs(t) (T-axiom) - WORKS
- `modal_backward`: phi in mcs(t) -> Box phi in mcs(t) - FAILS in general

Not every formula has its Box in the MCS. Need saturation.

### Correct Approach

1. Build witness families following TimelineQuot structure (not constant)
2. Each witness rooted at Lindenbaum-extended MCS
3. Use `saturated_modal_backward` for modal_backward (proven axiom-free)

## Files Modified This Session

| File | Change |
|------|--------|
| `StagedConstruction/ClosureSaturation.lean` | Added singleton BFMCS infrastructure; partial forward_F proof |
| `StagedConstruction/CantorPrereqs.lean` | Added `forward_witness_at_stage_with_phi`, `backward_witness_at_stage_with_phi` |
| `plans/implementation-005.md` | Updated Phase 4 progress |
| `handoffs/phase-4-handoff-20260317.md` | NEW - Handoff document |

## Sorries Status

| File | Sorries |
|------|---------|
| TimelineQuotCompleteness.lean | 1 (unchanged - the main sorry) |
| ClosureSaturation.lean | 4 (2 edge cases in forward_F, backward_P, modal_backward) |
| WitnessChainFMCS.lean | 0 |
| CantorPrereqs.lean | 0 (new lemmas are complete) |

## Next Steps

1. **Resolve forward_F edge cases**: Add F-witness chaining lemmas or use alternative approach
2. **Prove timelineQuotFMCS_backward_P**: Symmetric to forward_F
3. **Build multi-family BFMCS**: With witness families for modal saturation
4. **Prove modal_backward via saturation**: Use saturated_modal_backward
5. **Complete Phase 5**: Apply parametric_representation_from_neg_membership
6. **Complete Phase 6**: Resolve the main sorry

## Alternative Approaches

If the edge cases prove too complex, consider:
1. **Use canonicalMCSBFMCS**: Work with the space of ALL MCSs, transfer results via Cantor iso
2. **Restrict evaluation domain**: Prove forward_F only for MCSs added before a certain stage
3. **Modify staged construction**: Ensure all F-formulas are processed for each new point

## Handoff

See `handoffs/phase-4-handoff-20260317.md` for detailed continuation instructions.

---

## Session 2: Plan v6 Analysis (sess_1773776521_d8f4a2)

### Key Analysis Findings

#### The Domain Mismatch Problem

| Infrastructure | Domain | LinearOrder? | forward_F/backward_P |
|----------------|--------|--------------|----------------------|
| canonicalMCSBFMCS | CanonicalMCS | NO (Preorder only) | PROVEN |
| timelineQuotFMCS | TimelineQuot | YES | NOT PROVEN (edge cases) |
| valid_over D | Any D | REQUIRED | N/A |

The mismatch:
1. `canonicalMCSBFMCS` has proven forward_F/backward_P but CanonicalMCS is not LinearOrder
2. `valid_over D` requires D : LinearOrder
3. Transferring to Rat via TimelineQuot inherits the TimelineQuot gaps

#### Plan v6 Approach Assessment

The domain transfer approach (via Cantor isomorphism TimelineQuot ≃o Rat) was analyzed:

1. **ratFMCS construction**: Maps Rat -> TimelineQuot -> MCS via canonicalIso.symm
2. **forward_F/backward_P gap**: The witness from canonical_forward_F is an MCS W, but W may not be in TimelineQuot
3. **Same edge cases**: The m > 2k problem affects both TimelineQuot directly and the Rat transfer

#### Existing Sorries (8 total)

| File | Line | Description |
|------|------|-------------|
| CanonicalEmbedding.lean | 181 | ratFMCS_forward_F |
| CanonicalEmbedding.lean | 192 | ratFMCS_backward_P |
| CanonicalEmbedding.lean | 231 | ratBFMCS.modal_backward |
| CanonicalEmbedding.lean | 280 | ratFMCS_root_eq |
| CanonicalEmbedding.lean | 299 | construct_bfmcs_rat_for_root |
| IntBFMCS.lean | 572 | intChain_backward_H |
| IntBFMCS.lean | 583 | intFMCS_forward_F |
| TimelineQuotCompleteness.lean | 127 | timelineQuot_not_valid_of_neg_consistent |

### Recommendations

1. **Resolve F-content preservation**: Prove that F-content transfers along CanonicalR chains (or show it doesn't and find workaround)
2. **Alternative formulation**: Consider completeness relative to Preorder domains
3. **Different countermodel**: Find countermodel construction that doesn't require BFMCS over LinearOrder

### Session Status

- **Phases Completed**: 0 (Phase 1 partial - analysis only)
- **Files Modified**: Plan file, summary file
- **Sorries Changed**: 0 (analysis session)
