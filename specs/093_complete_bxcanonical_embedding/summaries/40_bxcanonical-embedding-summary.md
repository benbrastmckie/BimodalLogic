# Implementation Summary: Task #93 - Complete BXCanonical Embedding

**Completed**: 2026-04-18
**Mode**: Team Implementation (2 max concurrent teammates)
**Plan**: plans/40_bxcanonical-embedding.md (Quasimodel BFMCS Path B)
**Status**: PARTIAL

## Wave Execution

### Wave 1 (Parallel)
- Phase 1: Archive Dead Round-Robin Code [COMPLETED] - Moved ~800 lines to Boneyard/
- Phase 2: Validate Derived Rules [COMPLETED] - All 6 validation items PASS

### Wave 2
- Phase 3: Build qm_oracle_step [PARTIAL] - Core oracle infrastructure built, defect_count decrease sorry'd

### Wave 3
- Phase 4: Build qm_fmcs and qm_bfmcs [PARTIAL] - Chain infrastructure built, 3 restricted coherence proofs sorry'd

### Wave 4-5
- Phase 5: Close restricted_buc/fuc [NOT STARTED] - Blocked by Phase 4
- Phase 6: Integration and Verification [NOT STARTED] - Blocked by Phase 5

## Changes Made

### Phase 1: Boneyard Archival
- Created `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/RoundRobinChain.lean` (509 lines)
- Removed ~800 lines of dead round-robin code from RootScopedChain.lean
- Build succeeds after archival

### Phase 2: Validation Results
- bx_le gives h_content backward: PASS (g_content_subset_implies_h_content_reverse)
- Until introduction rule NOT needed: PASS (use BX8+BX7+oracle guard)
- until_defects_seed_consistent: PASS (subset-of-MCS argument)
- Vacuous interval guard: PASS (omega confirms)
- SubformulaClosure_untl_closed: PASS (sorry-free in Realization.lean)
- Design decision: modify dd_bfmcs in place

### Phase 3: Oracle Step Construction
- Created `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean` (454 lines)
- Sorry-free core: qm_oracle_seed, qm_oracle_seed_consistent, qm_oracle_step, qm_oracle_step_bx_le, qm_oracle_step_h_content, qm_oracle_step_until_in_next
- Sorry-free backward: qm_oracle_step_bwd with symmetric properties
- Sorry-free sigma_sig oracle: hintikka_step_for_sigma_sig (the key result)
- 23 sorries in general HintikkaStepOracle (defect_count decrease)

### Phase 4: FMCS/BFMCS Infrastructure
- Added ~480 lines to RootScopedChain.lean
- Built: qm_fwd_chain, qm_bwd_chain, qm_chain, qm_fmcs, shifted_qm_fmcs, qm_bfmcs
- Proved: chain MCS properties, g_content/h_content propagation, Until-defect persistence
- 6 new sorries in restricted coherence proofs

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Archival cleanup + oracle chain infrastructure
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean` - New file, oracle step construction
- `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/RoundRobinChain.lean` - New file, archived dead code
- `specs/093_complete_bxcanonical_embedding/phases/40_phase-2-results.md` - Validation results

## Remaining Sorry Analysis

### Original 3 sorry sites (unchanged)
1. `dd_bfmcs_restricted_tc` (line 953) - Forward temporal coherence
2. `dd_bfmcs_restricted_buc` (line 958) - Backward Until/Since coherence
3. `dd_bfmcs_restricted_fuc` (line 963) - Forward Until/Since coherence

### New sorry sites (in qm_bfmcs proofs)
4-5. `qm_bfmcs_restricted_tc` forward/backward (lines 1878, 1883) - Defect count decrease needed
6-7. `qm_bfmcs_restricted_buc` Until/Since step transfer (lines 1921, 1929) - Semantically invalid step
8-9. `qm_bfmcs_restricted_fuc` Until/Since witness (lines 1957, 1961) - Depends on restricted_tc

### Root Causes (2 irreducible blockers)
1. **Defect count decrease** (blocks restricted_tc): Lindenbaum extension may introduce new Until-defects from Sigma, preventing monotone defect reduction. The oracle seed includes defects, but the Lindenbaum MCS extension can add arbitrary Until-formulas.

2. **Backward step transfer** (blocks restricted_buc): `phi AND F(phi U psi) -> phi U psi` is SEMANTICALLY INVALID. Counterexample: phi at t=0, not phi at t=1, phi at t=2, psi at t=3. Then F(phi U psi) at t=0 but phi U psi NOT at t=0 (guard fails at t=1).

## Verification

- Build: Pass (951 jobs, all compile)
- Tests: N/A
- Sorry count in OracleStep.lean: 23 (defect_count decrease)
- Sorry count in RootScopedChain.lean: 9 (3 original + 6 new)

## Team Metrics

| Metric | Value |
|--------|-------|
| Total phases | 6 |
| Waves executed | 3 of 5 |
| Phases completed | 2 |
| Phases partial | 2 |
| Phases not started | 2 |
| Max parallelism | 2 |
| Debugger invocations | 0 |
| Total teammates spawned | 5 |

## Notes

The two irreducible blockers (defect count decrease, backward step transfer) are the SAME obstacles identified across 40 rounds of research. The quasimodel BFMCS approach (Path B) successfully builds the infrastructure but encounters the same mathematical gap at the proof level. The infrastructure is valuable -- the oracle step, chain construction, and Until-defect persistence are all sound. The gap is in the termination/coherence arguments that require properties the Lindenbaum extension does not guarantee.

Possible next steps:
1. Prove defect count decrease by enriching the oracle seed to include ALL Sigma-formulas present in the MCS (not just defects), preventing Lindenbaum from adding new ones
2. Find a BX-derivable backward step transfer (perhaps via G(phi U psi) propagation)
3. Restructure to avoid backward Until coherence entirely (different completeness proof architecture)
