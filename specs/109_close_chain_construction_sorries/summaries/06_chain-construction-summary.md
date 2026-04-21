# Implementation Summary: Close Chain Construction Sorries (v5)

**Task**: 109 -- Close chain construction sorries
**Plan**: plans/06_implementation-plan.md (v5)
**Session**: sess_1745189500_b4c8d2
**Status**: BLOCKED
**Phases Completed**: 0 of 5

## Outcome

All 5 sorry sites in `RootScopedChain.lean` remain open. The implementation is blocked because the current chain construction (`fwd_chain_of_sigma` using `preserving_fwd_step`) is provably unable to satisfy the keystone theorem `fwd_chain_forward_F`. A chain redesign is required.

## Analysis Performed

### Confirmed Impossibility

Through detailed mathematical analysis, confirmed that `fwd_chain_forward_F` (sorry #1, line 1134) cannot be proved for the current chain. The BX11 fold used in `preserving_fwd_step` provides only a disjunctive guarantee (phi in M' OR F(phi) in M') and the resolved witness is chosen non-constructively by `Exists.choose`, which cannot be proved to ever select phi.

### BX12 Bridge Approach (Plan's Primary Strategy)

The BX12 bridge approach (F(phi) -> T U phi -> bx_until_eventuality_resolution) produces abstract BXPoints that cannot be mapped back to chain indices. The bridge from BXPoint to chain index is fundamentally impossible because BXPoints are Lindenbaum extensions of arbitrary seeds, while chain points are Lindenbaum extensions of specific BX11-fold seeds.

### Extended Discharge Approach (Plan's Backup)

The extended discharge seed `{phi} union {F(chi_i)} union g_content(M)` is NOT always consistent. When `G(phi -> G(neg chi_i)) in M`, the seed derives a contradiction.

### Key Mathematical Discovery

The BX11 analysis of F(phi) with F(G(neg phi)) (which follows from G(F(phi)) not-in M) reveals:
- Case 1: F(phi and G(neg phi)) gives a seed that resolves phi AND kills F(phi)
- Case 2: F(phi and F(G(neg phi))) gives a seed that resolves phi but F(phi) persists
- Case 3: F(F(phi) and G(neg phi)) is IMPOSSIBLE (the conjunction F(phi) and G(neg phi) is contradictory under irreflexive semantics)

This means discharge_single_step ALWAYS places phi in the next step when F(phi) is present.

## Proposed Chain Redesign

Replace `preserving_fwd_step` with a hybrid step:
- Most steps: use existing `preserving_fwd_step` (preserves F-obligations)
- At round-robin target's step: use `discharge_single_step` (guarantees target resolution)

The proof of `fwd_chain_forward_F` would then be: F(phi) persists through preserving steps until phi's round-robin slot, where discharge_single_step resolves it.

Estimated effort for redesign: 14-22 hours across 2-3 sessions.

## Artifacts

- Handoff: `specs/109_close_chain_construction_sorries/handoffs/01_chain-redesign-handoff.md`
- This summary: `specs/109_close_chain_construction_sorries/summaries/06_chain-construction-summary.md`
- Plan (updated phase markers): `specs/109_close_chain_construction_sorries/plans/06_implementation-plan.md`

## Unmodified Files

No source files were modified. All changes are to task management artifacts only.
