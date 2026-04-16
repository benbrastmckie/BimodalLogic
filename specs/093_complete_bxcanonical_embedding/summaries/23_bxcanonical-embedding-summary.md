# Implementation Summary: Task 93, Plan v23

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-16
**Session**: sess_1713293500_impl93
**Status**: Partial (Phase 1 of 6 completed)

## What Was Accomplished

### Phase 1: Dead-Code Cleanup [COMPLETED]

Removed ~200 lines of dead code from `CanonicalModel.lean`:

- Deleted `bx_fmcs_forward_F` (sorry) — unprovable for scheduling chain
- Deleted `bx_fmcs_backward_P` (sorry) — symmetric obstacle
- Deleted `bx_bfmcs` definition — BFMCS using old `int_chain`, superseded by `dd_bfmcs`
- Deleted `bx_bfmcs_tc`, `bx_bfmcs_buc`, `bx_bfmcs_fuc` (sorry) — unrestricted coherence
- Deleted `bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`, `bx_bfmcs_restricted_fuc` (sorry) — restricted coherence delegating to sorry'd theorems
- Deleted `bx_countermodel` — superseded by `dd_countermodel` in RootScopedChain.lean
- Cleaned unused imports (`ParametricRepresentation`, `RestrictedParametricTruthLemma`, `UntilSinceCoherence`)
- Added missing import (`FMCSDef`) for `FMCS` type
- Moved `ParametricRepresentation` and `RestrictedParametricTruthLemma` imports to `RootScopedChain.lean` (where they're actually used by `dd_countermodel`)

**Result**: `lake build` succeeds. CanonicalModel.lean has zero sorry sites (was 7). All 6 remaining sorries are in RootScopedChain.lean only.

## What Remains Blocked (Phases 2-6)

### Deep Analysis of the Forward_F Problem

After extensive analysis of the codebase and all available infrastructure, the forward_F problem remains fundamentally unresolved. The core issue:

**Problem**: Given `F(psi) in chain(n)` and `psi in sigma_list`, prove `exists s > n, psi in chain(s)`.

**Why it's hard**: The enriched forward step (`enriched_fwd_step`) uses the BX11 fold to protect ALL F-obligations from sigma_list, giving a DISJUNCTIVE result: for each chi with `F(chi) in M`, either `chi in M'` or `F(chi) in M'`. The specific formula psi might NEVER be directly resolved (always the "F(psi) in M'" branch).

**Approaches analyzed and why they don't work**:

1. **Round-robin schedule with enriched step**: F-obligations persist (by `rr_fwd_chain_F_obligation_forward`), but the enriched step's direct witness depends on the BX11 ordering and might perpetually not be psi.

2. **Demand-driven chain with `target_resolving_fwd_exists_strong`**: Requires target to be BX11-earliest among all defects. Cannot guarantee psi is ever the BX11-earliest since the ordering depends on the current MCS and changes non-deterministically.

3. **Extended defect seed `{target} ∪ g_content(M) ∪ f_carry(M)`**: NOT consistent in general (counterexample: `G(F(alpha) -> neg psi) in M, F(alpha) in M, F(psi) in M`).

4. **Existential extended defect seed (Finding 2)**: Gives `exists j, seed with psi_j is consistent`. But we can't control which j is chosen, so we can't guarantee any specific psi gets resolved.

5. **Perpetual-deferral contradiction (Finding 16)**: Uses truth lemma to derive `G(neg psi) in chain(n)` from `neg psi in chain(m) for all m > n`. But the truth lemma REQUIRES forward_F. Circular.

6. **Simple `fwd_succ` (non-enriched step)**: Guarantees `target in M'` but doesn't preserve F-obligations of other formulas. So F(psi) can be lost at resolving steps for other targets.

7. **Defect-count induction**: Defect count doesn't decrease because resolved formulas re-acquire F-obligations (`psi in M' implies F(psi) in M'` by phi_in_mcs_imp_F_phi).

8. **BX11 ordering induction**: The ordering changes between chain steps because the MCS changes. No well-founded measure available.

### Assessment

The 6 sorry sites in RootScopedChain.lean represent a genuine mathematical difficulty in formalizing the canonical model construction for bimodal logic with Until/Since. The BX11 linearity axiom provides disjunctive control over F-formulas, but converting disjunctive control to universal eventuality resolution (forward_F) appears to require either:

- A fundamentally new chain construction technique not yet identified
- A non-syntactic argument (semantic/model-theoretic) that avoids the circularity with the truth lemma
- A reformulation of the completeness proof that bypasses forward_F entirely

**Confidence in remaining phases**: LOW (< 20%). The forward_F problem has resisted 23 rounds of research and is identified as the deepest obstruction in the project.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — removed ~200 lines of dead code, cleaned imports
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — added 2 imports previously transitive through CanonicalModel

## Sorry Inventory

| File | Count | Status |
|------|-------|--------|
| CanonicalModel.lean | 0 (was 7) | Cleaned |
| RootScopedChain.lean | 6 | Blocked |
| **Total** | **6** | **Blocked** |

RootScopedChain.lean sorry sites:
1. `rr_fwd_chain_forward_F` (line 1319) — PRIMARY BLOCKER
2. `dd_fmcs_forward_F` t < 0 case (line 1350) — depends on #1
3. `dd_fmcs_backward_P` (line 1357) — symmetric to #1
4. `dd_bfmcs_restricted_tc` (line 1410) — depends on #1, #3
5. `dd_bfmcs_restricted_buc` (line 1415) — depends on Until step transfer
6. `dd_bfmcs_restricted_fuc` (line 1420) — depends on #1 + guard condition
