# Phase 6 Handoff: Cases III/IV Gap Handling

**Date**: 2026-05-28
**Session**: sess_1780001766_2e723d
**Status**: BLOCKED
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
**Sorry location**: Line 3477

## Current State

- Phases 1-5 are COMPLETE
- Phase 6 targets the single remaining sorry at CaseAnalysis.lean:3477
- The sorry is inside `ghr93_cases_III_IV`, in the winning condition assembly for the gap case
- `lake build` passes (sorry is not a build error, it is the proof obligation)
- 1 sorry remains in CaseAnalysis.lean (line 3477)

## Proof Context at the Sorry

The goal at line 3477 is:
```
∃ b_resp,
    inClosedInterval x' y' (extendPoint b_resp) ∧
      ghr93_winning_condition (n + 1) (game_tuple x' y' a_bwd b_resp) (game_tuple x y a'_resp b_sp)
```

Available hypotheses include:
- `hwin_tau` - tau sub-game giving b_resp for challenges in [c, y]
- `gamma_M`, `gamma_N` - matching gaps with formula agreement (`hgamma_M_form`)
- `a'_resp` - response function: positions 0..n-1 from `resp_tau`, position n is `Sum.inr gamma_M`
- `b_sp` - the M-side challenge point in [x, y]
- `props : SplitPointProps` - split point data including sigma, tau, h_d_compat_left, h_fwd_n1
- `h_gap_match` - already proved: existence of matching gap gamma_M with formula agreement

## The Blocker: sel_gap_ord

The winning condition has 3 components:
1. `same_order_type` - ordering agreement for all position pairs
2. `gap_point_agreement` - point/gap status at each position
3. `formula_agreement` - formula truth at each position

Components (2) and (3) are straightforward:
- Gap/point at position n: `hgamma_gp` (both are gaps, trivial)
- Formula at position n: `hgamma_M_form`
- Other positions: from tau sub-game data

Component (1) requires **sel_gap_ord**: for each k < n,
```
(a_init(k) < Sum.inr gamma_N iff resp_tau(k) < Sum.inr gamma_M) ∧
(a_init(k) = Sum.inr gamma_N iff resp_tau(k) = Sum.inr gamma_M)
```

This ordering relationship between tau sub-game selections (a_init/resp_tau) and the gap position (gamma_N/gamma_M) is NOT derivable from:
- Tau sub-game orderings alone (gamma is not a tau game position)
- Forward game orderings alone (forward game relates M-selections to N-responses, but we need N-selections vs M-selections)
- Formula agreement alone (two positions with same formulas can have different orderings)
- Interval containment alone (both resp_tau(k) and gamma_M are in [x,y])

## What Was Tried

1. **Forward game approach**: Play `props.h_fwd_n1` with `a'_resp` as M-selections. Gives `resp_tau(k) < gamma_M iff a'_fwd(k) < a'_fwd(n)`. But a'_fwd (forward game N-response) is unrelated to a_bwd (backward game N-selection), so this doesn't bridge to `a_init(k) < gamma_N`.

2. **Pivot chain through d/c**: Works for tau-vs-tau orderings (positions 0..n-1 against each other), but requires `resp_tau(k) <= gamma_M` to chain to the gap position. This bound is not available without additional structure.

3. **h_d_compat_left approach**: Gives cross-boundary orderings between resp_tau and c/d, but not between resp_tau and gamma_M.

4. **Formula-based argument**: Formula agreement between a_init(k)/resp_tau(k) and gamma_N/gamma_M doesn't determine ordering (formula-equivalent positions can be at different places in the linear order).

5. **Adding h_mono**: Added `h_mono : Monotone a_bwd` to the signature (caller ghr93_cases_II_III_IV has it). This gives `a_init(k) <= gamma_N` but doesn't directly give `resp_tau(k) <= gamma_M`.

## What Is Needed

The correct mathematical argument likely requires ONE of:
1. **Gap detection structural argument**: Show that the gap detection transfer maps the "segment above tau selections" to a corresponding segment. Since gamma_M was found via gap detection transfer using a reference point m_M, and resp_tau(k) should be below m_M (as tau maps selections below gamma_N to selections below m_M), we'd get resp_tau(k) < gamma_M.

2. **Extended tau game**: Play a (n+1)-round tau game that includes gamma_N as an additional selection. This would directly give the sel_gap_ord. But we only have an n-round tau.

3. **IH-based sub-interval argument**: Use the backward game IH on a sub-interval [d, gamma_N] vs [c, gamma_M] to derive the ordering. This requires adding the IH parameter to ghr93_cases_III_IV.

4. **Reference point m_M bound**: Show that all resp_tau(k) <= m_M (the reference point used in gap detection), and m_M < gamma_M. The reference point m_M comes from the forward game at rank r+4. The tau sub-game at rank r maps a_init to resp_tau. If m_N (N-side reference) is above all a_init(k), then by tau ordering preservation, m_M would be above all resp_tau(k). This is the most promising direction.

## Recommended Next Steps

1. **Read the gap detection construction carefully** (lines 2440-2940, especially the LEFT case). Identify where m_M is obtained and verify that m_N >= all a_init(k) (which follows from m_N in gamma_N.cut and a_init(k) <= gamma_N).

2. **Derive resp_tau(k) <= m_M** from the tau sub-game ordering and m_N >= a_init(k). Use tau endpoint ordering d < m_N iff c < m_M combined with tau_sel orderings d < a_init(k) iff c < resp_tau(k) and a_init(k) < m_N iff resp_tau(k) < m_M (from tau ordering at position 1+k vs m_N position).

3. **But m_M is not in the tau game** - it's from the forward game. So we may need to play a separate forward game that includes both resp_tau(k) and m_M to get the ordering.

4. **Alternative**: Restructure the proof so that resp_tau is not constructed from a bare tau sub-game but from a COMBINED game that includes the gap position. This is a significant refactor.

## Files Modified (None - Blocked Before Changes)

No source files were modified. The sorry at line 3477 remains as in the previous phase.

## Prohibited Workarounds

- Do NOT use `sorry` for sel_gap_ord and consider the phase done
- Do NOT use vacuous definitions (def X := True)
- Do NOT simplify to discrete-only (no gaps) case
