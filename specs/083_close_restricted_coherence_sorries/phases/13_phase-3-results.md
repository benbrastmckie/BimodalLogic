# Phase 3 Results: Seed Redesign and g_content Resolution

**Status**: BLOCKED — redirected to documentation and dependency analysis
**Sorry closures**: 0 (none closable — see analysis below)
**Build impact**: No regressions (documentation-only changes)

## Key Finding: g_content(u) subset u is Provably FALSE

Under strict temporal semantics (`<` not `<=`), `G(phi) in MCS` means phi holds at
all strictly future states. It does NOT imply phi holds at the current state. Therefore:

- `g_content(u) = {phi | G(phi) in u}` is NOT a subset of u
- `h_content(u) = {phi | H(phi) in u}` is NOT a subset of u (temporal dual)

These are PROVABLY FALSE, not merely unproven. The T-axiom `G(phi) -> phi` was removed
during the strict semantics refactor (task 81) precisely because it is unsound under `<`.

## Critical Path Analysis

The plan assumed ~14 sorry closures in Phase 3. Deep analysis reveals:

### SuccExistence.lean (3 sorries: lines 473, 788, 869)
- All three attempt `g_content(u) subset u` or `h_content(u) subset u`
- **Provably false** under strict semantics
- **NOT on critical completeness path**: `completeness_over_Int` uses the DovetailedChain
  construction, not the SuccChainFMCS/constrained_successor path
- The sorry-free `forward_temporal_witness_seed_consistent` (WitnessSeed.lean) provides
  seed consistency via G-wrapping without requiring `g_content subset u`

### SuccChainFMCS.lean (4 T-axiom sorries: lines 1243, 3989, 4256, 4399)
- `g_content_subset_deferral_restricted_mcs` (line 1243): T-axiom in proof body
- `h_content_subset_deferral_restricted_mcs` (line 3989): temporal dual
- Lines 4256, 4399: T-axiom in constrained_predecessor_seed proofs
- **All provably false** under strict semantics
- **NOT on critical completeness path**: DovetailedChain avoids these entirely

### DovetailedChain.lean (6 sorries: lines 608, 974, 1070, 1083, 1240, 1247)
- Lines 608, 974: Until/Since persistence through single Succ step
- Lines 1070, 1083: Until/Since backward propagation to M_0
- Lines 1240, 1247: Strict inequality strengthening for forward_F/backward_P
- **ALL ON CRITICAL PATH** for `completeness_over_Int`
- **ALL BLOCKED by Phase 4**: X-content propagation infrastructure
- Lines 1240, 1247 depend on lines 608, 974 (via dovetailed_fam_forward_F)

### UltrafilterChain.lean (2 sorries: lines 3917, 3927)
- `succ_chain_restricted_forward_F` and `backward_P`
- On SuccChainFMCS path, NOT on DovetailedChain critical path

## Dependency Analysis: What Blocks Completeness

The complete dependency chain for `completeness_over_Int`:

```
completeness_over_Int
  -> dovetailed_bundle_validity_implies_provability
    -> dovetailed_bfmcs_restricted_temporally_coherent
      -> DovetailedFMCS_forward_F (SORRY, line 1240)
      -> DovetailedFMCS_backward_P (SORRY, line 1247)
        -> dovetailed_fam_forward_F (non-strict version)
          -> forward_dovetailed_forward_F
            -> forward_dovetailed_until_propagate
              -> forward_dovetailed_until_persists (SORRY, line 608)
                BLOCKED BY: X-content propagation (Phase 4)
```

The REAL blockers are the Until/Since persistence sorries (Phase 4), not the
g_content/h_content subset sorries (Phase 3 as originally scoped).

## Changes Made

Documentation updates to 3 files (no code changes, no sorry count change):

1. **SuccExistence.lean**: Updated docstrings for 3 sorry-bearing theorems to mark them
   as "PROVABLY FALSE under strict semantics" and "NOT on critical completeness path"
2. **SuccChainFMCS.lean**: Updated docstrings for g_content_subset_deferral_restricted_mcs
   and h_content dual with same analysis
3. **DovetailedChain.lean**: Updated docstrings for all 6 sorry sites with critical-path
   annotations and Phase 4 dependency notes

## Recommendation

Phase 3 should be reclassified from "Seed Redesign" to "Documentation and Dependency
Analysis". The original goal of 14 sorry closures was based on an incorrect assumption
that `g_content(u) subset u` could be restructured. Under strict semantics, this is
provably false, and the code paths that need it are NOT on the critical completeness path.

The critical-path effort should redirect to **Phase 4** (X-Content Propagation and
Until/Since Persistence), which addresses the actual blockers for `completeness_over_Int`.

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`
