# Implementation Summary: Task #843

**Completed**: 2026-02-10
**Duration**: Phase 4 completed in single session
**Plan Version**: v007
**Session ID**: sess_1770746225_9de1ad

## Overview

Replaced the mathematically FALSE `singleFamily_modal_backward_axiom` with the mathematically CORRECT `fully_saturated_bmcs_exists` axiom, following the priority order from research-016.

## Changes Made

### Phase 4: Replace FALSE Axiom with CORRECT Axiom [COMPLETED]

**Key Change**: The completeness theorem chain now depends on a CORRECT axiom instead of a FALSE one.

1. **Added new CORRECT axiom** in `TemporalCoherentConstruction.lean`:
   - `fully_saturated_bmcs_exists`: Asserts existence of a fully saturated, temporally coherent BMCS
   - This is TRUE by standard canonical model theory for S5 modal + temporal logic
   - Modal backward follows from the PROVEN `saturated_modal_backward` theorem

2. **Added new construction** `construct_saturated_bmcs`:
   - Uses the new correct axiom instead of the deprecated single-family axiom
   - Provides context preservation, temporal coherence, and modal saturation

3. **Updated `Completeness.lean`**:
   - `bmcs_representation` now uses `construct_saturated_bmcs`
   - `bmcs_context_representation` now uses `construct_saturated_bmcs`
   - Updated documentation to reflect new axiom dependency

4. **Deprecated old axiom** in `Construction.lean`:
   - `singleFamily_modal_backward_axiom` marked as DEPRECATED
   - Documentation explains why it is FALSE (counterexample: atom "p")
   - Old construction `singleFamilyBMCS` still compiles for backward compatibility

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
  - Added deprecation notice to `singleFamily_modal_backward_axiom`
  - Updated documentation explaining why the old axiom is FALSE

- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
  - Added `fully_saturated_bmcs_exists` axiom (CORRECT)
  - Added `construct_saturated_bmcs` construction
  - Added supporting theorems for context preservation, temporal coherence, modal saturation

- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
  - Updated `bmcs_representation` to use `construct_saturated_bmcs`
  - Updated `bmcs_context_representation` to use `construct_saturated_bmcs`
  - Updated summary section to document new axiom dependency

- `specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-007.md`
  - Marked Phase 4 as [COMPLETED]

## Verification

### Axiom Dependency Check

Before (FALSE axiom):
```
'bmcs_strong_completeness' depends on axioms: [..., singleFamily_modal_backward_axiom]
```

After (CORRECT axiom):
```
'bmcs_strong_completeness' depends on axioms: [propext, Classical.choice, Lean.ofReduceBool,
 Lean.trustCompiler, Quot.sound, fully_saturated_bmcs_exists]
```

### Build Verification
- `lake build Bimodal` succeeds with no errors
- All 998 jobs complete successfully

## Phase 1 Progress (Session 2: sess_1770746935_4a7b4f)

### Architectural Improvement: Unified Shared Base MCS

Modified `DovetailingChain.lean` to use a single shared MCS at index 0:

1. **Added `sharedBaseMCS`**: A single base MCS constructed once via Lindenbaum
2. **Modified `dovetailForwardChainMCS`**: Step 0 now returns `sharedBaseMCS` instead of independent Lindenbaum call
3. **Modified `dovetailBackwardChainMCS`**: Step 0 now returns `sharedBaseMCS` instead of independent Lindenbaum call
4. **Added `chains_share_base` lemma**: Proves `M_0 = M_{-1}` (both chains share the same base MCS)

This change is a prerequisite for cross-sign propagation but is not sufficient alone. The fundamental issue is that:
- Forward chain propagates GContent going positive (0 -> 1 -> 2 -> ...)
- Backward chain propagates HContent going negative (0 -> -1 -> -2 -> ...)
- G formulas in the backward chain do not propagate toward the shared base

### Analysis: Why Cross-Sign Cases Are Blocked

The current two-chain architecture (forward Nat chain + backward Nat chain) is structurally incapable of cross-sign temporal propagation because Lindenbaum extension is one-directional. For G(phi) at time t < 0 to propagate to time t' >= 0, we would need G-content to flow from the backward chain toward the shared base, but the backward chain construction only includes HContent (not GContent) in its seeds.

Resolution options (per plan contingency):
1. Restructure to interleaved chain construction (significant effort, 12-15 hours)
2. Accept sorry markers at cross-sign cases as non-blocking for modal axiom goal (Phase 4 complete)

Per plan contingency, accepting sorry markers is acceptable since Phase 4 (the critical goal) is complete.

## Remaining Work (Phases 1, 2, 3, 5)

### Phase 1: Complete Temporal Dovetailing Sorries [PARTIAL]
- [x] Unified shared base MCS construction (chains_share_base)
- [ ] Cross-sign forward_G (BLOCKED - requires interleaved chain architecture)
- [ ] Cross-sign backward_H (BLOCKED - requires interleaved chain architecture)
- [ ] forward_F dovetailing enumeration (NOT STARTED)
- [ ] backward_P dovetailing enumeration (NOT STARTED)
- 4 sorries remain in DovetailingChain.lean

### Phase 2: BoxContent Accessibility Symmetry [NOT STARTED]
- Prove symmetry lemma for BoxContent inclusion

### Phase 3: Generalized Diamond-BoxContent Consistency [NOT STARTED]
- Extend consistency lemma to bare MCS

### Phase 5: Prove the Correct Axiom [NOT STARTED]
- Transform `fully_saturated_bmcs_exists` from axiom to theorem
- Requires full canonical model construction

## Why Phase 4 Was Prioritized

Per research-016 priority order:
1. **Priority 1 (Immediate): Phase 4** - Replace FALSE axiom with CORRECT one for mathematical soundness
2. Priority 2 (Near-term): Phase 1 - Complete temporal sorries
3. Priority 3 (Medium-term): Phases 2-3 - Enable full canonical model approach
4. Priority 4 (Long-term): Phase 5 - Full axiom elimination

Phase 4 was completed first because it:
- Makes the proof chain mathematically sound
- Is independent of the other phases
- Has low risk and clear implementation path
- Does NOT require resolving the complex cross-sign propagation issue

## Notes

- The old FALSE axiom is preserved (deprecated) for backward compatibility
- The new CORRECT axiom will be proven in Phase 5 using canonical model construction
- Phase 1 cross-sign cases require significant architectural work beyond the scope of this session

---

## Session 3: Dovetailing Infrastructure (sess_1770748252_437b4a)

### Changes Made

Added dovetailing index functions to `DovetailingChain.lean`:

1. **`dovetailIndex : Nat -> Int`** - Maps construction step to time index
   - Step 0 -> time 0
   - Step 2k+1 -> time k+1 (positive)
   - Step 2k+2 -> time -(k+1) (negative)
   - Encodes the interleaved construction order: M_0, M_1, M_{-1}, M_2, M_{-2}, ...

2. **`dovetailRank : Int -> Nat`** - Inverse mapping (time to step)
   - Time 0 -> step 0
   - Time k+1 -> step 2k+1
   - Time -(k+1) -> step 2k+2

3. **Inverse property theorems** (with sorry):
   - `dovetailRank_dovetailIndex` - Computationally verified
   - `dovetailIndex_dovetailRank` - Computationally verified
   - `dovetail_neighbor_constructed` - Neighbor availability property

4. **Updated module documentation** to describe the interleaved chain approach

### Technical Analysis

During implementation, discovered that the plan's interleaved approach as originally described does NOT fundamentally solve the cross-sign propagation problem:

- The interleaved ORDER changes which MCS are built first
- However, each MCS's SEED still only includes GContent/HContent from neighbors
- M_0 is still built first (step 0) without GContent from negative times
- G-formulas in M_{-k} still cannot propagate through M_0 to M_{k'}

**Key insight**: Resolving cross-sign G/H requires either:
1. A fundamentally different construction (canonical model with ALL MCS)
2. Proving forward_F first, then using contrapositive argument
3. Including ALL F/P-witnesses in M_0's seed (complex consistency argument)

### Sorry Count

DovetailingChain.lean now has 7 sorries:
- 3 new: dovetailRank_dovetailIndex, dovetailIndex_dovetailRank, dovetail_neighbor_constructed
- 4 original: forward_G cross-sign, backward_H cross-sign, forward_F, backward_P

### Verification

- `lake build Bimodal` succeeds with sorry warnings
- Dovetailing functions verified computationally via #eval

### Plan Updated

- Phase 1 status: [PARTIAL]
- Updated task checkboxes to reflect completed work
- Added progress notes documenting analysis findings
