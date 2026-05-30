# Phase 2 Handoff: Reynolds Model Surgery Core Factoring

**Date**: 2026-05-30T16:30:00Z
**Session**: sess_1780157486_orch202r4
**Agent**: lean-implementation-agent (cycle 16)

## What was done

Factored `reynolds_model_surgery_core` from a monolithic sorry into a clean
proof structure with 2 well-scoped sorry sites:

1. **reynolds_model_surgery_core** (sorry-free): By contradiction + case split
   on whether y > a or y < a. Delegates to gap_prior_UZ/SZ_contradiction.

2. **gap_prior_UZ_contradiction** (sorry): Reynolds Lemmas 6-13, upward case.
   Contract: given class(a) succ-closed + y > a + NOT contemp_equiv a y +
   h_surj + Prior-UZ/SZ, derive False.

3. **gap_prior_SZ_contradiction** (sorry): Symmetric downward case.

Added helper lemmas:
- `class_pred_closed`: delegates to contemp_equiv_pred_closed
- `class_boundary_gap`: class boundary implies NOT IsSuccArchimedean

Updated module documentation with correct architecture diagram showing the
two sorry sites and their relationship to the sorry-free infrastructure.

## Current state

- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
- **Sorry count in file**: 2 (gap_prior_UZ_contradiction at line 603, gap_prior_SZ_contradiction at line 629)
- **Build status**: `lake build` passes (full project, 1679 jobs)
- **Plan phase**: Phase 2 [IN PROGRESS]

## What remains

### To close the 2 sorry sites (Phase 2 completion):

Each sorry requires the full Reynolds model surgery (Lemmas 6-13), estimated
~300 lines per sorry (or ~300 lines shared if the downward case is derived
from the upward case via Order.dual).

The proof requires:
1. **Lemma 6**: Construct MonadicFormula sig 1 for right_gap_class, apply
   US_expressively_complete_over_prior to get temporal formula R
2. **Lemmas 7-8**: R-interval properties
3. **Lemma 9**: Class homogeneity
4. **Lemmas 10-11**: Bad intervals and formula propagation
5. **Lemma 12**: Model surgery construction + temporal truth preservation
   (26 subcases for U/S)
6. **Lemma 13 + Theorem 14**: Contradiction

### Available sorry-free infrastructure:
- US_expressively_complete_over_prior (PriorExpressiveness.lean)
- contemp_equiv_is_equiv, no_boundary_at_successor (GoodStructures.lean)
- contemp_equiv_convex, contemp_equiv_pred_closed (GoodStructuresModelSurgery.lean)
- prior_UZ_first_transition, prior_SZ_last_transition (GoodStructuresModelSurgery.lean)
- gap_of_not_succ_archimedean, one_class_archimedean (ReynoldsNoGaps.lean)

### Key insight from 16 agent cycles:
- class_temporal_formula (R detecting class(a) membership) is UNPROVABLE
- right_gap_class (R detecting "class has gap boundary") IS the correct approach
- right_gap_class IS expressible as MonadicFormula sig 1 (via k-type finiteness)
- The direct Prior-UZ shortcut FAILS in Case B (report 15)
- Full model surgery IS mathematically required

## Immediate next action

Implement gap_prior_UZ_contradiction by constructing the right_gap_class
MonadicFormula sig 1 and applying the Reynolds model surgery argument.
Start with Lemma 6 (formula construction via US_expressively_complete_over_prior).
