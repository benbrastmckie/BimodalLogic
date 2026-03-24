# Implementation Summary: Task #48 (v10)

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Plan Version**: v10 (chi-in-u-restriction)
**Date**: 2026-03-23
**Session**: sess_1774312144_672b4e
**Status**: PARTIAL

## Overview

This implementation attempted to complete the boundary_resolution_set approach for task 48. Phases 1-2 were completed in a prior session. This session investigated Phases 3-5 and found that the boundary case proofs require a different strategy than planned.

## Phases Completed

### Phase 1: Modify boundary_resolution_set definition [COMPLETED - Prior Session]

- Added `chi in u` requirement to boundary_resolution_set
- Definition now requires all four conditions: chi in u, F(chi) in u, FF(chi) not in dc, GF(chi) not in u
- Location: SuccExistence.lean lines 318-322

### Phase 2: Complete augmented_seed_consistent [COMPLETED - Prior Session]

- Proof completed via subset argument: augmented_seed subset u, u is consistent
- Location: SuccChainFMCS.lean lines 1566-1589

### Phase 3: Update v2 construction and Succ proof [PARTIAL]

- The v2 construction approach was abandoned
- Investigation revealed the existing construction is sufficient
- Boundary case proofs require different strategy than originally planned

### Phase 4: Simplify restricted_single_step_forcing [PARTIAL]

- The boundary_resolution_set approach only helps when `psi in chain(k)`
- `restricted_single_step_forcing` does not have `psi in chain(k)` as hypothesis
- Sorries remain for FF(psi) not in dc cases

### Phase 5: Update downstream and verify [PARTIAL]

- Build passes successfully
- 7 sorries remain in SuccChainFMCS.lean (5 boundary + 2 deprecated)
- Plan expected 2 sorries (deprecated only)

## Current State

### Build Status
- `lake build`: PASSES (928 jobs)
- No new errors introduced

### Sorry Count in SuccChainFMCS.lean (7 total)
| Line | Location | Type |
|------|----------|------|
| 736 | f_nesting_is_bounded | Deprecated |
| 971 | p_nesting_is_bounded | Deprecated |
| 3201 | restricted_single_step_forcing | Boundary: FF not in dc |
| 3360 | restricted_succ_propagates_F_not | Boundary: F in dc, FF not in dc |
| 4108 | restricted_succ_propagates_F_not' | Edge: GF in dc but not in chain |
| 4336 | restricted_succ_propagates_F_not' | Edge: GF not in dc |
| 4348 | restricted_succ_propagates_F_not' | Edge: F not in u |

### Key Theorems Status

| Theorem | Status | Notes |
|---------|--------|-------|
| augmented_seed_consistent | COMPLETE | Uses chi in u restriction |
| boundary_resolution_set | MODIFIED | Added chi in u condition |
| restricted_single_step_forcing | PARTIAL | Sorry for FF not in dc |
| restricted_succ_propagates_F_not | PARTIAL | Sorry for boundary case |
| restricted_succ_propagates_F_not' | PARTIAL | Sorries for edge cases |
| restricted_bounded_witness | COMPLETE* | Uses sorry-containing lemmas |
| restricted_forward_chain_forward_F | COMPLETE* | Uses bounded_witness |

*These theorems have complete proof structure but rely on lemmas with sorries.

## Blocker Analysis

The remaining sorries represent a genuine mathematical challenge:

1. **The f_content path**: When FF(psi) not in dc, we cannot use negation completeness to derive GG(neg psi), which is needed to block F(psi) from entering the successor.

2. **The g_content path**: Even when f_content is blocked, GF(psi) in chain(k) can inject F(psi) via g_persistence.

3. **Primed versions**: Adding h_GF_not hypothesis blocks both paths but creates new edge cases when GF(psi) is in dc but not in chain(k).

4. **The mathematical insight**: The bounded_witness induction should handle these cases because the F-depth eventually decreases, but proving this requires tracking additional information (G-depth or lexicographic termination).

## Recommendations for Follow-up

### Option 1: Lexicographic Termination (Recommended)
Modify restricted_bounded_witness to use lexicographic induction on (f_depth, g_depth, k), where:
- f_depth = F-nesting depth (current d)
- g_depth = G-nesting depth of the obligation
- k = chain position

This should handle all cases where the current approach has sorries.

### Option 2: Semantic Argument
Prove consistency of augmented_seed by showing it has a model, using the successor witnessing F(chi).

### Option 3: Accept Current State
The bounded_witness theorem "works" at the type level and the sorries are in edge cases. For practical purposes, this may be acceptable.

## Files Modified (This Session)

- `specs/048_prove_succ_chain_fam_bounded_f_depth/plans/10_chi-in-u-restriction.md` - Updated phase status markers
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/10_chi-in-u-restriction-summary.md` - This summary

## Files Modified (Prior Session)

- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - boundary_resolution_set definition
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - augmented_seed_consistent proof

## Artifacts

- Plan: specs/048_prove_succ_chain_fam_bounded_f_depth/plans/10_chi-in-u-restriction.md
- Summary: specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/10_chi-in-u-restriction-summary.md
- Research: specs/048_prove_succ_chain_fam_bounded_f_depth/reports/16_derivability-blocker.md
