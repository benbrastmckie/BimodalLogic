# Implementation Summary: Parallel Dense/Discrete Completeness (v2)

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Plan**: plans/05_parallel-dense-discrete.md
- **Date**: 2026-05-09
- **Session**: sess_1778363834_9eead2

## Phase Results

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| 1 | Dense BFMCS Construction | COMPLETED | `cantor_bfmcs_dense` with sorry-free modal_forward/backward |
| 2 | Dense Restricted Coherence | PARTIAL | 3 sorry stubs (tc, buc, fuc) -- coordinate transfer proofs |
| 3 | Dense Countermodel | COMPLETED | `dd_countermodel_chronicle_dense` defined (depends on Phase 2 sorries) |
| 4 | Case-Split Completeness | COMPLETED | `bx_completeness` restructured with box-density case split |
| 5 | Dense Verification | COMPLETED | Full `lake build` passes, sorry isolation confirmed |
| 6 | Omega Chain Analysis | COMPLETED (prior) | NO-GO for IsSuccArchimedean |
| 7 | IsSuccArchimedean | SKIPPED | Phase 6 NO-GO |
| 8 | Discrete BFMCS | SKIPPED | Phase 7 skipped |
| 9 | Final Integration | COMPLETED | Full build passes |

## Key Architectural Decisions

### Case Split: Box Density (not Formula Density)

The plan's original case split on `F'T in A` vs `U(T,bot) in A` was revised to use `box(F'T) in A` vs `neg(box(F'T)) in A`. This is necessary because:

1. **Box-equivalence transfers box formulas**: `box(F'T) in A` implies `box(F'T) in N` for all box-equivalent MCS N
2. **Modal_backward requires separate chronicles**: Each BFMCS family needs its own chronicle, which requires density for each box-equivalent N
3. **F'T alone doesn't transfer**: `F'T in A` does NOT imply `F'T in N` for box-equivalent N (F'T is not a box formula, and there's no BX axiom `F'T -> G(F'T)`)
4. **box(F'T) gives propagation**: From `box(F'T)`, we derive `G(box(F'T))` (temp_future) and then `G(F'T)` (modal_t under G), ensuring density at all chronicle domain points

### Non-Dense Branch

The non-dense branch (`neg(box(F'T)) in A`) includes both:
- Pure discrete case: `U(T,bot) in A`
- Mixed modal class: Some box-accessible worlds are dense, others discrete

This branch has `sorry`. The plan's `dd_countermodel_chronicle_discrete_sorry` is replaced by the more general `dd_countermodel_chronicle_nondense_sorry`.

## New Definitions

### ChronicleToCountermodel.lean

| Definition | Type | Status |
|-----------|------|--------|
| `box_stable_in_limit_f` | theorem | sorry-free |
| `box_stable_in_cantor_f_dense` | theorem | sorry-free |
| `box_dense_gives_density` | theorem | sorry-free |
| `shifted_cantor_fmcs_dense'` | def (FMCS Rat) | sorry-free |
| `rooted_cantor_fmcs_dense` | def (FMCS Rat) | sorry-free |
| `rooted_cantor_fmcs_dense_at_s` | theorem | sorry-free |
| `box_stable_in_rooted_cantor_fmcs_dense` | theorem | sorry-free |
| `cantor_bfmcs_dense` | def (BFMCS Rat) | sorry-free |
| `cantor_bfmcs_dense_restricted_tc` | theorem | **sorry** |
| `cantor_bfmcs_dense_restricted_buc` | theorem | **sorry** |
| `cantor_bfmcs_dense_restricted_fuc` | theorem | **sorry** |
| `dd_countermodel_chronicle_dense` | theorem | depends on above sorries |
| `dd_countermodel_chronicle_nondense_sorry` | theorem | **sorry** |

### Completeness.lean

| Change | Description |
|--------|-------------|
| `bx_completeness` | Restructured with `box(F'T)` case split |
| Axiom audit | Updated `#print axioms` reference |

## Sorry Analysis

### New sorries in ChronicleToCountermodel.lean (4)

1. **`cantor_bfmcs_dense_restricted_tc`**: F/P resolution transfer through Cantor iso. Strategy: unfold `rooted_cantor_fmcs_dense` to `cantor_f_dense`, apply `limit_F_resolution`/`limit_P_resolution`, map witness back through iso. Mechanical coordinate transform.

2. **`cantor_bfmcs_dense_restricted_buc`**: Backward Until/Since via C4/C4' contrapositive. Strategy: contrapositive -- if negU in f(t) and witness pattern holds, C4 gives intermediate z with guard violation. Map z through iso, apply guard, get contradiction. Mechanical coordinate transform.

3. **`cantor_bfmcs_dense_restricted_fuc`**: Forward Until/Since via C5/C5'. Strategy: unfold to limit_f, apply `limit_satisfies_c5_strong`, map witness and guard through iso. The guard over limit_dom becomes guard over all of Rat since iso is a bijection.

4. **`dd_countermodel_chronicle_nondense_sorry`**: Non-dense branch countermodel. This is the documented sorry for the non-dense modal class (replaces the plan's discrete sorry).

### Pre-existing sorry (1)

5. **`limitDomSubtype_isSuccArchimedean`**: Well-founded termination for discrete succ chain. Confirmed NO-GO by Phase 6 analysis.

## Build Verification

- `lake build` passes (1097 jobs, 0 errors)
- `bx_completeness` compiles with `sorryAx` (from the sorry stubs)
- No new axioms introduced
- No imports of Boneyard files
