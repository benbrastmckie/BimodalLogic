# Phase R3 Handoff: CaseAnalysis Rank Projection

## Status
Phase R3 PARTIAL. Rank-projection sorry sites closed (7 of 9). Case II body and Cases III/IV assembly remain sorry'd.

## What Changed

### CaseAnalysis.lean
- Added `(hd : 2 ≤ delta)` to: `ghr93_case_I`, `ghr93_case_II`, `ghr93_cases_III_IV`, `ghr93_cases_II_III_IV`, `ghr93_inductive_step`
- Case I sorry sites (sigma_reduced, tau_reduced): **CLOSED** via `ghr93_duplicator_wins_rank_down` + `ghr93_duplicator_wins_round_mono`
- Cases III/IV `h_tau_app` sorry: **CLOSED** via `tau_r` (projected from `props.tau` via `rank_down`)
- Cases III/IV degenerate `h_tau_0` sorries (2 sites): **CLOSED** via `tau_r` + `round_mono`
- Cases III/IV degenerate `h_sigma_0` sorry: **CLOSED** via `sigma_r` (projected from `props.sigma` via `rank_down`)
- Cases II-IV dispatcher sorry: **CLOSED** -- now calls `ghr93_case_II` with correct arguments
- `ghr93_inductive_step`: constructs `ih_r` (rank-r IH) from the rank-(r+delta) IH via `rank_down`
- Added `ih` and `h_r1_univ` parameters to `ghr93_cases_II_III_IV` (for Case II dispatch)

### Theorem6.lean
- Added `(by omega : 2 ≤ 4)` to rank-varying `ghr93_inductive_step` call
- Changed uniform-rank core from delta=0 to delta=2 (delta=0 incompatible with hd≥2; IH already sorry'd)

## Remaining Sorry Sites

### CaseAnalysis.lean (2 sorry sites)
1. **Line 1243**: `ghr93_case_II` body -- the full GHR93 Case II proof requires U(B, sf_top) formula transfer through tau at r+delta. This requires materializing the rank-r type formula B = X_{p_n} as a StaviFormula, which depends on the Stavi expressive completeness chain (Phases 6D-6F).
2. **Line 4564**: `ghr93_cases_III_IV` winning condition assembly -- same grid-dispatch pattern as Case II. Pre-existing sorry from Phase 3A.

### Theorem6.lean (2 sorry sites, unchanged)
1. **Line 124**: Core succ-case IH (uniform-rank, sorry'd since R2)
2. **Line 325**: Rank-varying succ-case IH (rank promotion, sorry'd since R2)

## Key Architectural Decision
The `hd : 2 ≤ delta` constraint ensures rank_down is always available when projecting sigma/tau from rank r+delta to rank r. This is satisfied in the GHR93 proof path (delta=4) but not in the uniform-rank path (delta=0). The uniform-rank path was changed to delta=2 with a sorry'd IH.

## Next Action
Phase R4: Update DConsistencyTransport.lean and GapDetection.lean if their interfaces changed. The `hd` parameter does not propagate to these files (they don't call the case theorems directly).
