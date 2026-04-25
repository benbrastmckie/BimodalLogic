# Implementation Summary: Task #107 (v11 -- C4 Definition Fix)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: PARTIAL
- **Plan**: plans/25_implementation-plan.md
- **Session**: sess_1777135521_5c1fd8

## Completed Work

### Phase 1: Fix C4/C4' Definitions and Delete g_ordered [COMPLETED]

**Changes made**:

1. **ChronicleTypes.lean**: Fixed C4/C4' definitions to match Burgess 1982 (C4a/C4b)
   - C4 now checks EVENT (delta) at f(y) and negates GUARD (gamma) at f(z)
   - C4' mirror updated identically
   - Removed `hg_ord` and `hh_ord` fields from `ChronicleInvariant` structure
   - Updated docstrings with correct Burgess semantics

2. **CounterexampleElimination.lean**: Updated C4/C4' counterexample structures
   - Renamed `guard_mem` to `event_mem` in C4Counterexample/C4'Counterexample
   - Updated `no_witness` field to check for `gamma.neg` (GUARD negation) instead of `delta.neg`
   - Updated `eliminate_C4_counterexample` conclusion to produce `gamma.neg` at witness z
   - Updated `eliminate_C4'_counterexample` mirror
   - Updated `eliminate_potential_counterexample` C4/C4' branches with correct field access
   - Updated docstrings throughout

3. **ChronicleConstruction.lean**: Removed g_ordered infrastructure
   - Deleted `omega_chain_g_ordered` (was sorry'd)
   - Deleted `omega_chain_h_ordered` (was sorry'd)
   - Removed `hg_ord`/`hh_ord` from `singleton_invariant` proof
   - Updated `limit_forward_G`/`limit_backward_H` with new proof strategy (sorry, Phase 3)

**Verification**: `lake build` succeeds with no errors.

### Phase 3: forward_G/backward_H Analysis [BLOCKED]

Investigation revealed that the plan's C4+C0 proof strategy does not work for dense domains:

- **Adjacent-pair C4 is vacuously true** at the limit (dense domain has no adjacent pairs)
- **g_ordered cannot be maintained** under strict semantics (density insertion uses f(z)=f(x), and G(phi) in f(x) does not imply phi in f(x) without the T axiom)
- **g_prop elimination cannot fix existing f-values** (it only inserts new points)
- **h_content/g_content duality is circular** (forward_G needs backward_H and vice versa)

This is a fundamental obstruction of the current construction under strict (irreflexive) temporal semantics. Burgess's original proof uses reflexive semantics where G(phi) -> phi (T axiom), making g_ordered trivially maintained.

**Resolution requires construction restructuring** (documented in ChronicleConstruction.lean).

## Sorry Count

| File | Count | Notes |
|------|-------|-------|
| CounterexampleElimination.lean | 2 | C4/C4' hard case (gamma in both endpoints) |
| PointInsertion.lean | 1 | lemma_2_6_full |
| ChronicleConstruction.lean | 2 | limit_forward_G, limit_backward_H |
| ChronicleToCountermodel.lean | 8 | Downstream wiring |
| **Total** | **13** | Same as before (2 deleted, 2 relocated) |

## Phases Not Attempted

- **Phase 2**: C4/C4' counterexample elimination hard case -- depends on Phase 1 (done), but blocked by Lemma 2.6 full seed
- **Phase 4**: lemma_2_6_full -- depends on Phase 2
- **Phase 5**: ChronicleToCountermodel wiring -- depends on Phases 3 (blocked) and 4
- **Phase 6**: Cleanup -- depends on Phase 5

## Key Finding

The C4 argument swap (Phase 1) is confirmed correct and the build succeeds. However, the forward_G/backward_H proof (Phase 3) requires restructuring the omega chain construction to work under strict semantics. This is a deeper issue than the original plan anticipated. The C4 fix alone does not resolve the g_ordered blocker because the obstruction is in how the construction propagates G-formulas through density insertions, not in the C4 definition per se.

## Modified Files

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
