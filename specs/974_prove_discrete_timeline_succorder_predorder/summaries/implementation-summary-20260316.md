# Implementation Summary: Task 974 - DiscreteTimeline SuccOrder/PredOrder

**Date**: 2026-03-16
**Sessions**:
- sess_1742170000_x7m2q (phases 1-3: restructure)
- sess_1742179200_q8k3r (phase 4: blocker discovered)
**Status**: BLOCKED (architectural issue discovered)

## Executive Summary

Phase 1-3 restructured SuccOrder/PredOrder using proper Mathlib patterns (7 sorries -> 3).
Phase 4 discovered a fundamental architectural blocker: the staged construction always adds
density intermediates using the DN axiom, making discreteness proofs impossible without
new infrastructure or a different proof strategy.

## Changes Made

### SuccOrder Restructuring

**Before**: Used `Classical.choice ⟨b⟩` which ignored the witness and picked an arbitrary element, making `succ_le_of_lt` unprovable.

**After**: Uses `LinearLocallyFiniteOrder.succFn` which computes the GLB of `Set.Ioi a`. This provides:
- `le_succ`: `a ≤ succFn a` (from Mathlib)
- `succ_le_of_lt`: `a < b → succFn a ≤ b` (from Mathlib)
- `max_of_succ_le`: Proved using new `discrete_timeline_lt_succFn` theorem

### PredOrder Restructuring

**Before**: Used `Classical.choice` symmetrically with the same issues.

**After**: Uses custom `discretePredFn` which computes the LUB of `Set.Iio a`. This provides:
- `pred_le`: `predFn a ≤ a` (proved from LUB properties)
- `le_pred_of_lt`: `a < b → a ≤ predFn b` (proved from LUB properties)
- `min_of_le_pred`: Proved using new `discrete_timeline_predFn_lt` theorem

### IsSuccArchimedean

Updated documentation to explain that this requires `LocallyFiniteOrder` (intervals being finite). Left with clear TODO explaining the proof path.

## Sorry Analysis

### Resolved (4 sorries eliminated)
1. `SuccOrder.le_succ` - Now uses `le_succFn` from Mathlib
2. `SuccOrder.max_of_succ_le` - Proved using discreteness theorem
3. `SuccOrder.succ_le_of_lt` - Now uses `succFn_le_of_lt` from Mathlib
4. `PredOrder.pred_le` - Proved using LUB properties
5. `PredOrder.min_of_le_pred` - Proved using discreteness theorem
6. `PredOrder.le_pred_of_lt` - Proved using LUB properties

### Remaining (3 sorries)
1. **Line 193**: `discrete_timeline_lt_succFn` - Key discreteness property
   - States: For all `a`, `a < succFn a` (GLB is strictly greater)
   - Requires: Proving the discrete timeline is not densely ordered
   - Blocked on: Extracting DF frame condition at MCS level

2. **Line 251**: `discrete_timeline_predFn_lt` - Symmetric discreteness property
   - States: For all `a`, `predFn a < a` (LUB is strictly less)
   - Requires: Same as above, using DP (derivable from DF)

3. **Line 296**: `IsSuccArchimedean.exists_succ_iterate_of_le`
   - States: `a ≤ b → ∃ n, succ^[n] a = b`
   - Requires: `LocallyFiniteOrder` instance
   - Blocked on: Proving intervals are finite

## Technical Insights

### Why WellFounded.min Doesn't Work

The original research suggested using `WellFounded.min`, but this requires `WellFoundedLT`, which is FALSE for Z-like structures (infinite descending chains exist). The timeline is unbounded below, so it's not well-founded.

### Why succFn Works

`succFn` from `LinearLocallyFiniteOrder` computes the GLB of `Set.Ioi a` using `exists_glb_Ioi`, which exists for any `LinearOrder`. The key properties:
- `le_succFn`: `a ≤ succFn a` (GLB is a lower bound of strict upper bounds)
- `succFn_le_of_lt`: `a < b → succFn a ≤ b` (GLB ≤ any element in the set)

For non-dense (discrete) orders, the GLB is actually the minimum of the set, so `a < succFn a`. This is the discreteness property we need to prove.

### The Discreteness Gap

The DF axiom semantically ensures immediate successors exist. The challenge is:
1. DF is stated at the formula/derivability level
2. We need discreteness at the order level (on the quotient type)
3. The translation requires formalizing the frame condition correspondence

## Files Modified

- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
  - Lines 153-210: New SuccOrder infrastructure using succFn
  - Lines 212-268: New PredOrder infrastructure using LUB
  - Lines 270-296: Updated IsSuccArchimedean documentation

## Recommendations for Completion

1. **Short-term**: Prove `discrete_timeline_lt_succFn` by showing the DF axiom prevents dense intermediate MCSs. This may require:
   - Formalizing the DF frame condition at the MCS level
   - Showing seriality witnesses are immediate successors
   - Using `canonicalR_irreflexive` to ensure strictness

2. **Medium-term**: Prove `LocallyFiniteOrder` by showing:
   - Each stage of the staged construction adds finitely many MCSs
   - Between any two MCSs, there are finitely many stages

3. **Alternative**: Consider axiomatizing discreteness (like `canonicalR_irreflexive` was) if the full proof is too complex.

## Verification Status

- Build: Cannot verify due to upstream errors in `DurationTransfer.lean` (pre-existing)
- Syntax: Edits are syntactically correct based on test snippets
- Sorry count: Reduced from 7 to 3

## Dependencies

- `Mathlib.Order.SuccPred.LinearLocallyFinite`: For `succFn`, `le_succFn`, `succFn_le_of_lt`
- `Mathlib.Order.Bounds.Basic`: For `exists_lub_Iio`, `IsLUB`
- Existing: `NoMaxOrder`, `NoMinOrder`, `LinearOrder` instances (already proven)

---

## Phase 4 Analysis (Session: sess_1742179200_q8k3r)

### Architectural Blocker Discovered

During Phase 4 implementation, a fundamental architectural issue was discovered that
blocks completion of the remaining 3 sorries.

### Problem: Staged Construction Always Adds Density Intermediates

The `buildStagedTimeline` construction (StagedExecution.lean) alternates between:
- **Even stages**: Process F/P obligations (add forward/backward witnesses)
- **Odd stages**: Add density intermediates via `processDensity`

The density witness creation uses `density_of_canonicalR` (CanonicalTimeline.lean:134),
which applies the DN axiom:
```lean
theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.density phi))
```

This happens REGARDLESS of whether we're building a "discrete" or "dense" timeline.

### Why This Blocks Discreteness Proofs

The three remaining sorries all require the timeline to be discrete (non-dense):

1. `discrete_timeline_lt_succFn`: The GLB of `Set.Ioi a` must be strictly greater than `a`
2. `discrete_timeline_predFn_lt`: The LUB of `Set.Iio a` must be strictly less than `a`
3. `IsSuccArchimedean.exists_succ_iterate_of_le`: Intervals must be finite

But the staged construction adds density witnesses at every odd stage, potentially
making the order dense (not discrete).

### Resolution Options

**Option A: Prove Quotient Collapse** (Est. 4-8 hours)
Show density witnesses collapse in the Antisymmetrization quotient.
Requires detailed MCS equivalence analysis and new infrastructure.

**Option B: Create Discrete Staged Construction** (Est. 3-5 hours)
Build `buildDiscreteStagedTimeline` that skips odd-stage density insertion.
Requires significant refactoring of StagedConstruction module.

**Option C: Alternative Proof Strategy** (Est. unknown)
Bypass staged construction and prove discreteness directly from DF frame conditions.
Requires new research and proof approach.

### Relationship to Research-002 Finding

Research-002 correctly identified that DN is trivially valid under reflexive semantics.
The proposed solution ("discreteness follows from staged construction lacking DN") was
partially correct in principle, but incorrect in practice because:

1. The staged construction DOES use DN (it's in the axiom set for all MCSs)
2. There is NO separate discrete staged construction in the codebase
3. The docstring saying "without density intermediates" is aspirational, not implemented

### Recommendation

This task requires architectural decisions before proof completion:
1. Choose between Options A, B, or C
2. Implement chosen solution
3. Then complete the remaining 3 sorries

Escalating to user review for architectural decision.
