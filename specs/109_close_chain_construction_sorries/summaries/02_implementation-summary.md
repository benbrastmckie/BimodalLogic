# Implementation Summary: Close BXCanonical Chain Construction Sorries

- **Task**: 109 - Close chain construction sorries
- **Status**: BLOCKED
- **Session**: sess_1776728020_3dc5ca
- **Plan**: specs/109_close_chain_construction_sorries/plans/02_implementation-plan.md

## Completed Phases

### Phase 0: Axiom Audit [COMPLETED]
- Established sorry dependency tree for `bx_completeness`
- Cleaned up misleading comments in CanonicalModel.lean
- Documented axiom dependencies

### Phase 1: Dead Code Cleanup [COMPLETED]
- Removed 4 dead-code sorries from CanonicalModel.lean
- Archived to Boneyard/DeadCanonicalModel/
- Sorry count in CanonicalModel.lean reduced from 6 to 2

### Phase 2: FMCS Strict Ordering [COMPLETED]
- Changed FMCS forward_G/backward_H from `<=` to `<` (strict)
- Eliminated `g_content_subset_self` and `h_content_subset_self`
- Updated all downstream: CanonicalModel, RootScopedChain, RestrictedParametricTruthLemma
- Sorry count in CanonicalModel.lean reduced to 0

## Blocked Phases

### Phase 3: F-Resolution Keystone [BLOCKED]
- **Blocker**: `fwd_chain_forward_F` cannot be proved with current chain construction
- **Root cause**: BX11 fold preserves F-defects but cannot guarantee a specific defect is resolved. Under strict semantics, F-defects do not persist through g_content alone. BX11 case 3 (temporal deferral) can fire indefinitely for a fixed target with no known contradiction.
- **Prior art**: 4 Boneyard approaches attempted and failed for analogous reasons
- **Handoff**: specs/109_close_chain_construction_sorries/handoffs/01_phase3-analysis.md

### Phase 4: Backward P-Preservation [BLOCKED]
- Depends on Phase 3 (symmetric problem for P-formulas)

### Phase 5: Until/Since Coherence [BLOCKED]
- Step transfer property not derivable from bare FMCS under strict semantics
- Forward Until depends on temporal coherence (circular with Phase 3)

### Phase 6: Final Verification [BLOCKED]
- Depends on Phases 3-5

## Remaining Sorries (5)

| Line | Definition | Description |
|------|-----------|-------------|
| 1079 | `fwd_chain_forward_F` | F-resolution in forward chain |
| 1106 | `dd_bfmcs_restricted_tc` | Forward TC, backward chain case |
| 1113 | `dd_bfmcs_restricted_tc` | Backward TC (P-resolution) |
| 1121 | `dd_bfmcs_restricted_buc` | Backward Until/Since coherence |
| 1128 | `dd_bfmcs_restricted_fuc` | Forward Until/Since coherence |

## Recommended Next Steps

1. **Research task**: Investigate Option C (enriched seed with BX11 retry) from the handoff document
2. **Alternative**: Consider adding discreteness axiom to BX to enable deterministic chain approach
3. **Alternative**: Explore quasimodel-based construction from Boneyard

## Build Status

`lake build` passes with 5 sorries (all pre-existing, no regressions).
