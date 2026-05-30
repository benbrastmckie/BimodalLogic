# Phase 2 Handoff: Proof Restructuring Complete

**Date**: 2026-05-30
**Session**: sess_1780151044_orch202r3
**Phase**: 2 (Reynolds Model Surgery Core)
**Status**: PARTIAL (restructured, 1 sorry remains)

## What Changed

### Deleted: class_temporal_formula

The `class_temporal_formula` definition (previously at line 537) has been removed.
This was proven UNPROVABLE across 5 approaches (see phase-2-class-formula-analysis
handoff for full analysis). The fundamental obstruction: `contemp_equiv sig k M a t`
depends on a fixed element `a`, but `MonadicFormula sig 1` has only ONE free variable
and cannot reference specific carrier elements.

### Restructured: reynolds_model_surgery_core

Previously: `reynolds_model_surgery_core` was sorry-free but delegated to the
sorry'd `class_temporal_formula`. The proof used a "get R, show R holds everywhere
via Prior-UZ/SZ first/last-transition" argument that ONLY works if R detects
class(a) membership.

Now: `reynolds_model_surgery_core` has the sorry directly, with clean documentation
of what the model surgery proof requires (Reynolds Lemmas 6-13). The theorem
statement is unchanged and correct:

```lean
theorem reynolds_model_surgery_core (sig k M atomMap h_surj h_prior_UZ h_prior_SZ a h_succ_closed) :
    forall y, contemp_equiv sig k M a y
```

### Unchanged: downstream chain

All of these remain sorry-free, delegating to `reynolds_model_surgery_core`:
- `gap_contradicts_prior`
- `gap_contradicts_prior_below`
- `no_gaps_discrete_model_surgery`

## Current Sorry Architecture

```
reynolds_model_surgery_core (SORRY -- line 485)
  <- gap_contradicts_prior (sorry-free)
  <- gap_contradicts_prior_below (sorry-free)
  <- no_gaps_discrete_model_surgery (sorry-free)
    <- no_gaps_discrete (sorry in GoodStructures.lean:852, same blocker)
      <- one_class (sorry-free given no_gaps_discrete)
        <- chronicle_is_good_direct (sorry-free)
          <- countermodel_discrete_reynolds (Transfer.lean)
```

## What Remains for Phase 2 Completion

To close the sorry at `reynolds_model_surgery_core`, implement Reynolds Lemmas 6-13:

1. Construct right_gap_class formula rho(x) : MonadicFormula sig 1
2. Convert to temporal formula R via US_expressively_complete_over_prior
3. Analyze R-intervals (Lemmas 7-9)
4. Define bad intervals and prove formula propagation (Lemmas 10-11)
5. Construct surgery model N (Lemma 12)
6. Prove temporal truth preservation M <-> N (13 subcases for U/S)
7. Derive contradiction (Lemma 13)

Estimated: 400-600 lines, 12+ hours.

## Immediate Next Action

Either:
- (A) Continue implementing Reynolds Lemmas 6-13 (high effort, full completion)
- (B) Proceed to Phase 3 (wire no_gaps_discrete to model surgery) -- this will propagate the sorry but make the architecture clean
- (C) Leave as-is with well-documented sorry for future implementation

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
  - DELETED: class_temporal_formula (was lines 485-550)
  - RESTRUCTURED: reynolds_model_surgery_core (now has sorry directly at line 485)
  - UPDATED: file docstring, section comments
  - Net: file reduced from 690 to 572 lines (-118 lines of unprovable code)
- `specs/202_reynolds_k_equivalence_bypass/plans/14_reynolds-model-surgery-definitive.md`
  - Phase 2 status updated to reflect restructuring

## Build Status

`lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` passes.
1 sorry warning (reynolds_model_surgery_core).
