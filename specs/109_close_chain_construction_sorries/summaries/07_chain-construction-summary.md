# Implementation Summary: Close Chain Construction Sorries (v7)

- **Task**: 109
- **Status**: PARTIAL
- **Plan**: plans/07_implementation-plan.md
- **Session**: sess_1776749113_2af146

## Results

### Completed

- **Phase 1**: Archived 1327 lines of dead defect-directed chain code to `Boneyard/DefectDirectedChain/RootScopedChain.lean`
- **Phase 2**: Rewired `dd_countermodel` to use `bx_bfmcs` (new BFMCS wrapper around `shifted_bx_fmcs` from CanonicalModel.lean instead of the old `dd_bfmcs` with `shifted_dd_fmcs`)
- **Proved**: `fwd_chain_F_not_return` (F-obligation monotonicity for forward chain)
- **Proved**: `bwd_chain_P_not_return` (P-obligation monotonicity for backward chain)
- **Proved**: `bx_bfmcs` modal_forward and modal_backward (box stability for the new BFMCS)
- **Sorry reduction**: 5 sorries -> 3 sorries in RootScopedChain.lean
- **Code reduction**: 1556 lines -> 229 lines

### Blocked (Phases 3-5)

The core F-resolution problem (`fwd_chain_forward_F`) is NOT provable with the simple schedule-based chain:

**The Fundamental Issue**: When `fwd_succ` constructs a new MCS via Lindenbaum extension from `g_content(chain(n))`, the formula F(phi) may be absent from the result even though F(phi) was present in chain(n). The Lindenbaum step can introduce G(neg phi) (which is consistent with g_content(chain(n)) since G(neg phi) is NOT in g_content unless G(G(neg phi)) was in chain(n)). Once G(neg phi) enters the chain, F(phi) never returns (proved as `fwd_chain_F_not_return`), and phi may never appear.

This is the **same fundamental obstruction** that blocked the defect-directed chain. The plan v7 incorrectly assumed that the schedule-based chain avoids this problem. It does not: the Lindenbaum extension step is the source of the issue in BOTH constructions.

### Remaining Sorries

1. `bx_bfmcs_restricted_tc` - Temporal coherence (F-resolution + P-resolution)
2. `bx_bfmcs_restricted_buc` - Backward Until/Since coherence
3. `bx_bfmcs_restricted_fuc` - Forward Until/Since coherence

### Required for Resolution

Closing the temporal coherence sorry requires one of:
- **(a)** An enriched seed that includes ALL F-obligations at each step (blocked by BX11 `Classical.choice` opacity — dead ends 13-37)
- **(b)** A deterministic chain construction where each step is fully determined (no Lindenbaum freedom), ensuring F-obligations persist
- **(c)** A semantic completeness proof (e.g., Goldblatt/GHR-style) that avoids syntactic chain construction entirely
- **(d)** Proof that F-resolution holds for some OTHER chain (not the current `fwd_chain`) and rewiring the FMCS to use that chain

## Artifacts

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — Rewritten (229 lines, 3 sorries)
- `Theories/Bimodal/Boneyard/DefectDirectedChain/RootScopedChain.lean` — Archived (1556 lines)
- `specs/109_close_chain_construction_sorries/plans/07_implementation-plan.md` — Updated phase markers

## Build Verification

- `lake build` succeeds
- `#print axioms bx_completeness` shows `sorryAx` (expected, due to remaining sorries)
