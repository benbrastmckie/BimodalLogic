# Phase 1 Blocked Handoff: succ_reaches_dom_N Boundary Cases

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1780464467_3275ea
**Date**: 2026-06-02
**Status**: Phase 1 BLOCKED

## Immediate Next Action

Decide between:
1. **Path E** (plan fallback): Restructure `cantor_bfmcs_discrete_restricted_tc/fuc` to avoid `succ_embed_surjective` entirely. Build the countermodel over the limit domain index set instead of Z. ~300-500 lines.
2. **Prove the limit domain is one Z-chain**: Requires new structural lemmas about the omega chain construction showing that the counterexample enumeration cannot create multi-Z-chain configurations. Novel mathematical work, difficulty unknown.

## Current State

- **File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- **Sorry chain**: `chronicle_gap_contradiction` (line 486) -> `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `succ_embed_surjective` -> `cantor_bfmcs_discrete_restricted_tc/fuc` -> `countermodel_discrete_reynolds` -> `completeness_discrete`
- **Build status**: Passes with warnings (sorry in chain is existing, no regressions)
- **No code changes made** -- this session was pure analysis

## Key Findings

### Path D (stage induction) is genuinely intractable

The boundary cases in `succ_reaches_dom_N` (lines 236 and 392) cannot be completed because:

1. `limitDomSubtype_succ` is defined over the FULL limit domain, not relative to any single stage
2. Between two adjacent dom(N) points, infinitely many limit_dom points can be inserted by later stages of the omega chain construction
3. The succ chain from a dom(N) point may never reach the next dom(N) point in finitely many steps
4. This is documented in the code's own comments (lines 226-236) and the file docstring (line 88: "Stage induction: boundary cases intractable")

### Model surgery proves one class but not one Z-chain

- `reynolds_model_surgery_core` (GoodStructuresModelSurgery.lean:2058) proves: the entire carrier is one contemp_equiv class (sorry-free)
- But "one contemp_equiv class" does NOT imply "one Z-chain" (IsSuccArchimedean)
- Contemp_equiv is a semantic k-equivalence; it doesn't give concrete succ-reachability
- The Z+Z counterexample (two copies of Z with same NF type) shows this gap is genuine

### restricted_tc genuinely requires IsSuccArchimedean

- `cantor_bfmcs_discrete_restricted_tc` (line 1992) requires: if F(phi) in fam.mcs(t), then phi in fam.mcs(s) for some s > t
- fam.mcs is indexed by Z, following one Z-chain in the limit domain
- The F-witness (from limit_F_resolution) might be on a different Z-chain
- If the witness is on a different chain, phi is NOT in fam.mcs(s) for any s -- restricted_tc fails
- So restricted_tc is genuinely FALSE when the limit domain has multiple Z-chains

### C4 propagation approach analyzed

- F(phi) = U(phi, top) can be propagated along the Z-chain: if F(phi) in limit_f(x_s) and phi not in limit_f(x_{s+1}), then F(phi) in limit_f(x_{s+1}) (by contrapositive of limit_satisfies_c4)
- But the process may not terminate (infinitely many steps without phi appearing)
- If the F-witness is on a different Z-chain, the propagation runs forever

## Deviations from Plan

- Task 1.1: Completed (analysis of goal states and proof structure)
- Task 1.2: Blocked (Case 3a boundary intractable)
- Task 1.3: Blocked (Case 3b symmetric)
- Task 1.4: Blocked (depends on 1.2/1.3)

## Dependencies for Unblocking

- Need either:
  (a) A structural property of the omega chain construction that prevents multi-Z-chain configurations (novel mathematical result)
  (b) Path E: restructure the parametric canonical model to work over LimitDomSubtype instead of Z
  (c) A completely different proof of completeness_discrete that avoids the succ-embedding pipeline
