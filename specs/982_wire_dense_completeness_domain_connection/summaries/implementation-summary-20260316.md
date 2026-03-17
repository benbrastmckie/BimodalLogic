# Implementation Summary: Task 982 - Wire Dense Completeness Domain Connection

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Date**: 2026-03-16
- **Status**: PARTIAL (Phase 1 complete, Phase 2 partial)
- **Session**: sess_1773705645_12453

## Overview

This task aims to connect the existing completeness infrastructure (truth lemma over CanonicalMCS) to the TimelineQuot-based semantics required for the DenseCompletenessStatement.

## Completed Work

### Phase 1: Analyze TaskFrame AddCommGroup Dependency [COMPLETED]

**Analysis Results:**
- TaskFrame requires `AddCommGroup D` in its type signature
- `valid_over D` requires TaskFrame, inheriting the AddCommGroup requirement
- DenseCompletenessStatement quantifies over all D with these constraints
- TimelineQuot has LinearOrder, Countable, DenselyOrdered, NoMaxOrder, NoMinOrder but NOT AddCommGroup

**Decision:** Use DurationTransfer.ratAddCommGroup to transfer AddCommGroup from Rat to TimelineQuot via the Cantor isomorphism.

### Phase 2: Create TimelineQuotAlgebra Module [COMPLETED]

**File Created:** `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean`

**Definitions:**
- `timelineQuotAddCommGroup`: AddCommGroup structure transferred from Q via Cantor isomorphism
- `timelineQuotIsOrderedAddMonoid`: Order-compatible monoid structure
- `timelineQuotNontrivial`: Nontrivial instance (distinct elements exist)
- `timelineQuot_instantiate_dense`: Key lemma for instantiating validity quantification

**Properties:**
- Zero sorries
- Zero new axioms
- Builds successfully: `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra`

## Blocked Work

### TimelineQuotFMCS Construction

**Attempted Approach:**
1. Define `timelineQuotMCS : TimelineQuot → Set Formula` using `ofAntisymmetrization`
2. Prove `timelineQuot_lt_implies_canonicalR` for FMCS coherence
3. Build FMCS over TimelineQuot

**Blocking Issue:**
The proof of `timelineQuot_lt_implies_canonicalR` is complex because:
1. `ofAntisymmetrization` picks arbitrary representatives from equivalence classes
2. Representatives may differ from the original elements used to form the quotient
3. Tracking CanonicalR through equivalent elements requires careful reasoning about g_content/h_content preservation

**Root Cause:**
The quotient structure of TimelineQuot means that two equivalent DenseTimelineElem values have:
- Equal or mutually CanonicalR-related MCSs
- Same G-content and H-content

However, proving CanonicalR between arbitrary representatives requires chaining through multiple transitivity steps, which becomes complex when the representative choice is non-deterministic.

## Recommendations for Continuation

### Option A: Complete TimelineQuotFMCS (Moderate Complexity)

1. Prove `timelineQuot_lt_implies_canonicalR` by:
   - Using `Antisymmetrization.ind` to work with representatives
   - Leveraging `toAntisymmetrization_lt_toAntisymmetrization_iff`
   - Carefully tracking CanonicalR through equivalent elements
   - Using g_content equality for equivalent MCSs

2. Key insight needed: Show that for equivalent elements p ~ q, CanonicalR p.mcs r.mcs iff CanonicalR q.mcs r.mcs (up to g_content equality)

### Option B: Alternative Architecture (Lower Complexity)

Instead of building FMCS over TimelineQuot, consider:
1. Use existing `canonical_truth_lemma` over `BFMCS Int` (already proven)
2. Build a TaskFrame over TimelineQuot using timelineQuotAddCommGroup
3. Transfer the model through the semantic structure
4. The key is that TimelineQuot can instantiate the universal quantification in DenseCompletenessStatement

The `timelineQuot_instantiate_dense` lemma in TimelineQuotAlgebra.lean already provides the mechanism for this approach.

### Option C: Use Rat Directly (Simplest)

Since TimelineQuot ≃o Q (Cantor's theorem), and Q has all required instances:
1. Build the completeness proof using Q as the temporal domain
2. Use the Cantor isomorphism to transfer back to TimelineQuot if needed
3. This avoids the quotient representative complexity entirely

## Files Modified/Created

| File | Status | Description |
|------|--------|-------------|
| `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean` | NEW | AddCommGroup transfer from Rat to TimelineQuot |
| `specs/982_wire_dense_completeness_domain_connection/plans/implementation-001.md` | MODIFIED | Phase status updates |

## Axiom/Sorry Status

- **New Sorries**: 0
- **New Axioms**: 0
- **Pre-existing**: 1 axiom (`canonicalR_irreflexive`), 1 sorry in `dense_completeness_fc` (the target to resolve)

## Next Steps

1. Choose one of Options A, B, or C above
2. Complete the wiring between truth lemma infrastructure and DenseCompletenessStatement
3. Resolve the sorry in `dense_completeness_fc`
4. Verify zero-debt completion gate

## Time Spent

- Phase 1: ~30 minutes (analysis)
- Phase 2 (partial): ~2 hours (TimelineQuotAlgebra + attempted TimelineQuotFMCS)
- Total: ~2.5 hours of planned 4.5 hours
