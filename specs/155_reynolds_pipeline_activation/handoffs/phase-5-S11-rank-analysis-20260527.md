# Phase 5 S11 Analysis: Rank Issue in Gap Detection Transfer

## Status: BLOCKED

## Summary

The `ghr93_cases_III_IV` sorry in CaseAnalysis.lean (line ~3024) requires a gap detection transfer argument that is blocked by a rank mismatch between gap detection formulas and the available forward game.

## What Was Done This Session

1. **Added `h_fwd_r1` parameter threading**: Modified `ghr93_cases_III_IV`, `ghr93_cases_II_III_IV`, and `ghr93_inductive_step` to accept and pass the rank-(r+2) forward game. This infrastructure is needed for any resolution of the sorry.

2. **Full rank analysis**: Determined the exact rank requirements for gap detection transfer.

3. **Build verification**: Full `lake build` passes (1667 jobs). No regressions.

## The Rank Issue

### Problem Statement

To close the sorry in `ghr93_cases_III_IV`, we need to find a gap `gamma_M` in M that matches `gamma_N` in N. This requires:

1. **Gap existence**: Show M has a D-defined gap (where D is gamma_N's defining formula)
2. **Formula agreement**: Show `A^mu(gamma_M) <-> A^mu(gamma_N)` for all A with `stavi_depth A <= r`
3. **Order agreement**: Show gamma_M has correct ordering relative to other M-elements

### Rank Requirements

| Component | Formula | Depth | Required Rank |
|-----------|---------|-------|---------------|
| Gap existence | `gap_char_formula D` | `stavi_depth D + 2 <= r + 2` | r + 2 |
| Formula agreement | `left_formula A D` | `max(depth A, depth D) + 4 <= r + 4` | r + 4 |
| Gap existence (alt) | `U'(top, D)` | `stavi_depth D + 1 <= r + 1` | r + 1 |

### Available Forward Games

| Game | Rank | Rounds | Source |
|------|------|--------|--------|
| `h_fwd` (props.h_fwd_n1) | r | n + 1 | SplitPointProps |
| `h_fwd_r1` | r + 2 | 4 + 3*n | ghr93_inductive_step parameter |

### The Gap

- **Gap existence** requires rank r + 2, which IS available via `h_fwd_r1`.
- **Formula agreement** requires rank r + 4, which is NOT available.

The rank-(r+2) forward game can transfer `gap_char_formula D` (depth r+2) to detect gap existence and definability, following the DConsistencyTransport.lean pattern. But the full formula agreement `A^mu(gamma_M) <-> A^mu(gamma_N)` requires transferring `left_formula A D` (depth up to r+4) or `right_formula A D` (depth up to r+4), which exceeds the rank-(r+2) game's capacity.

### Depth Breakdown for `left_formula A D` by Formula Type

- `base (atom/bot/box)`: depth 0 (trivially False at gaps, no transfer needed)
- `stavi_untl A B`: depth r + 1 (fits in rank r+2)
- `stavi_snce A B`: depth r + 1 (fits in rank r+2)  
- `base (.untl f g)`: depth r + 1 (fits in rank r+2)
- `base (.snce f g)`: depth r + 3 (EXCEEDS rank r+2)
- `base (.imp f g)`: depth up to r + 4 (EXCEEDS rank r+2)
- `neg A`: depends on IH, up to r + 2 (borderline)
- `conj A B`: max of IH depths

So MOST formula types can be handled at rank r+2, but `.snce` and `.imp` base cases require rank r+3 or r+4.

## Resolution Options

### Option A: Extend to rank r+4 forward game

Modify `ghr93_forward_to_backward_core` to provide a rank-(r+4) forward game. In `ghr93_forward_to_backward_rank_varying`, `h_r1_univ` is universally quantified over `r'`, so we can instantiate at `r' = r+2` to get rank `(r+2)+2 = r+4`. But this requires:
- Adding a new parameter to `ghr93_inductive_step` and `ghr93_forward_to_backward_core`
- `ghr93_forward_to_backward_core`'s `h_r1_univ` is NOT universally quantified over `r'` (only over endpoints)
- The rank-varying version's `h_r1_univ` IS universally quantified over `r'`

**Approach**: Modify `ghr93_forward_to_backward_core` to accept `h_r1_univ` universally quantified over `r'`, not just at rank `r`. This is a breaking change but logically sound.

**Estimated effort**: 4-8 hours (signature changes, parameter threading, verification)

### Option B: Structural induction on formula agreement at gaps

Prove `A^mu(gamma_M) <-> A^mu(gamma_N)` by structural induction on `A`, using:
- For base cases: atoms are False at both gaps
- For temporal operators: truth at a gap depends on truth at nearby mu-points, which can be related via the rank-r forward game

The key challenge: temporal operators quantify over ALL mu-points between the gap and a witness. The rank-r forward game only gives agreement at FINITELY many points.

**Approach**: This might work via the gap structure. Both gamma_M and gamma_N have the same defining formula D. The truth of temporal formulas at a D-defined gap depends only on the D-induced structure near the gap, which is finitely describable.

**Estimated effort**: 10-20 hours (novel proof, uncertain feasibility)

### Option C: Use rank-varying version directly

Move Cases III/IV handling into `ghr93_forward_to_backward_rank_varying`, where rank `r + 4n` is available (for n >= 1, this gives rank >= r + 4).

**Approach**: Restructure so that the gap case is handled at the rank-varying level, not at the uniform-rank `ghr93_inductive_step` level.

**Estimated effort**: 6-12 hours (significant restructuring)

## Recommendation

**Option A** is the most straightforward. The key insight is that `ghr93_forward_to_backward_rank_varying` already has `h_r1_univ` universally quantified over `r'`. We need to thread this through to `ghr93_forward_to_backward_core` and down to `ghr93_cases_III_IV`. The changes are:

1. Make `h_r1_univ` in `ghr93_forward_to_backward_core` universally quantified over `r'`
2. In `ghr93_inductive_step`, derive `h_fwd_r3` at rank `r + 4` from `h_r1_univ` at `r' = r + 2`
3. Pass `h_fwd_r3` to `ghr93_cases_III_IV`
4. In `ghr93_cases_III_IV`, use `h_fwd_r3` to transfer `left_formula A D` / `right_formula A D`

## Current State

- `CaseAnalysis.lean`: 1 sorry at `ghr93_cases_III_IV` (line ~3024)
  - Parameters `hxy`, `hx'y'`, `h_fwd_r1` added (infrastructure ready)
  - Build passes
- `Theorem6.lean`: sorry-free
- Phase 3B/3C sorries: untouched (as instructed)
