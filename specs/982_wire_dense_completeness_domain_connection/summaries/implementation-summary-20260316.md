# Implementation Summary: Task 982 - Wire Dense Completeness Domain Connection

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Date**: 2026-03-16
- **Status**: PARTIAL (Phase 1 complete, Phase 2 partial, Phase 4 complete)
- **Session**: sess_1773705645_12453

## Overview

This task aims to connect the existing completeness infrastructure (truth lemma over CanonicalMCS) to the TimelineQuot-based semantics required for the DenseCompletenessStatement.

## Architecture Achievement

The completeness wiring is now structurally complete:
- `dense_completeness_fc` in `Completeness.lean` uses `dense_completeness_theorem`
- `dense_completeness_theorem` in `TimelineQuotCompleteness.lean` implements contrapositive argument
- Single remaining gap: `timelineQuot_not_valid_of_neg_consistent` (countermodel construction)

## Completed Work

### Phase 1: Analyze TaskFrame AddCommGroup Dependency [COMPLETED]

**Analysis Results:**
- TaskFrame requires `AddCommGroup D` in its type signature
- `valid_over D` requires TaskFrame, inheriting the AddCommGroup requirement
- DenseCompletenessStatement quantifies over all D with these constraints
- TimelineQuot has LinearOrder, Countable, DenselyOrdered, NoMaxOrder, NoMinOrder but NOT AddCommGroup

**Decision:** Use DurationTransfer.ratAddCommGroup to transfer AddCommGroup from Rat to TimelineQuot via the Cantor isomorphism.

### Phase 2: Create TimelineQuot Infrastructure [PARTIAL]

**Files Created:**
1. `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean`
2. `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

**TimelineQuotAlgebra.lean** (sorry-free):
- `timelineQuotAddCommGroup`: AddCommGroup structure transferred from Q via Cantor isomorphism
- `timelineQuotIsOrderedAddMonoid`: Order-compatible monoid structure
- `timelineQuotNontrivial`: Nontrivial instance (distinct elements exist)
- `timelineQuot_instantiate_dense`: Key lemma for instantiating validity quantification

**TimelineQuotCompleteness.lean** (one sorry):
- `timelineQuotMCS`: Extract MCS from TimelineQuot element
- `timelineQuotMCS_is_mcs`: Extracted MCS is maximal consistent
- `timelineQuot_not_valid_of_neg_consistent`: KEY GAP - needs proof
- `dense_completeness_theorem`: Main theorem using contrapositive

### Phase 4: Wire Dense Completeness Theorem [COMPLETED]

**What Was Done:**
- Updated `Completeness.lean` to import `TimelineQuotCompleteness`
- Changed `dense_completeness_fc` to use `TimelineQuotCompleteness.dense_completeness_theorem`
- Removed inline sorry in favor of structured dependency

## Remaining Gap

### The Key Lemma: `timelineQuot_not_valid_of_neg_consistent`

**Goal:** Show that when [φ.neg] is consistent, φ is NOT valid over TimelineQuot built from that MCS.

**What This Means:**
- We have an MCS M₀ containing φ.neg
- We need to construct a TaskFrame, TaskModel, Omega, history, and time over TimelineQuot
- At that point, φ must evaluate to false (equivalently, φ.neg must evaluate to true)

**Resolution Options:**

1. **Direct Countermodel Construction**: Build a simple model with MCS-based valuation
2. **Full Truth Lemma**: Port CanonicalConstruction.lean infrastructure to TimelineQuot
3. **Transfer Theorem**: Show satisfiability transfers along order isomorphisms

## Files Modified/Created

| File | Status | Description |
|------|--------|-------------|
| `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean` | NEW | AddCommGroup transfer (sorry-free) |
| `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` | NEW | Completeness wiring (1 sorry) |
| `Theories/Bimodal/FrameConditions/Completeness.lean` | MODIFIED | Uses dense_completeness_theorem |
| `specs/982_wire_dense_completeness_domain_connection/plans/implementation-001.md` | MODIFIED | Phase status updates |

## Axiom/Sorry Status

- **New Sorries**: 1 (`timelineQuot_not_valid_of_neg_consistent`)
- **New Axioms**: 0
- **Pre-existing in pipeline**: 1 axiom (`canonicalR_irreflexive`)

**Note:** The sorry in `dense_completeness_fc` has been replaced with a structured dependency on `dense_completeness_theorem`, which in turn depends on the single sorry above.

## Build Status

```
lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra  # passes (no sorries)
lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness  # passes (1 sorry)
lake build Bimodal.FrameConditions.Completeness  # passes
```

## Next Steps

1. Prove `timelineQuot_not_valid_of_neg_consistent` using one of the resolution options
2. This will make `dense_completeness_theorem` sorry-free
3. Which will make `dense_completeness_fc` sorry-free
4. Verify zero-debt completion gate

## Time Spent

- Phase 1: ~30 minutes (analysis)
- Phase 2 (partial): ~2.5 hours (TimelineQuotAlgebra + TimelineQuotCompleteness)
- Phase 4: ~30 minutes (wiring)
- Total: ~3.5 hours of planned 4.5 hours
