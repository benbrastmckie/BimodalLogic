# Phase 3C Handoff: U(B,A) Transfer Blocked on Formula Materialization

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 3C (U(B,A) Transfer -- Replace e_n Construction)
**Session**: sess_1748393400_orch155
**Date**: 2026-05-27
**Status**: BLOCKED

## What Was Accomplished

1. **ghr93_winning_condition_perm** implemented in `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` (95 lines, sorry-free, verified via lean_verify). This theorem proves that permuting both selection arrays by the same permutation preserves the GHR93 winning condition. It enables selection sorting via Tuple.sort in ghr93_case_II.

2. **Exhaustive analysis** confirming the fan problem is fundamental and cannot be resolved with existing infrastructure. 20+ approaches documented in the plan's Superseded Approaches section (numbers 1-20). The analysis in this session confirmed:
   - The big game gives `(resp_tau(k) < e_n <-> a'_big(k) < extendPoint p_n)` but a'_big(k) < p_n is unprovable (fan: d <= a'_big(k) and d <= p_n with no chain).
   - Tau's Round 2 with e_n gives b_tau_en with same rank-r type as p_n but at unknown position.
   - h_fwd_n1 produces new N-side responses, not a_init.
   - Formula agreement (rank-r type equivalence) between a'_big(k) and a_init(k) does NOT determine ordering relative to p_n.

## Immediate Next Action

**Resolve the circular dependency between Phase 3C and Phase 6.**

The U(B,A) approach requires expressing the interval type as a single StaviFormula, which requires `nf_characterizable_by_stavi` (Phase 6). But Phase 6 depends on Phase 5, which depends on Phase 3C. Three options:

### Path A: Implement Phase 6 First (Recommended)
Reorder: Phase 6A (Proposition 7 composition) -> Phase 6C (nf_characterizable_by_stavi) -> Phase 3C (formula materialization using nf_characterizable_by_stavi) -> Phase 3B/5 (unblocked by 3C).

This breaks the circular dependency by making Phase 6 independent of Phase 3C. The key observation: Phase 6's nf_characterizable_by_stavi proof does NOT actually depend on the sorries that Phase 3C would close. It has its own dependency chain through Proposition 7 (composition lemma).

### Path B: Direct Formula Construction
Find a way to construct the interval type formula without nf_characterizable_by_stavi. This might be possible if:
- There are only finitely many EQUIVALENCE CLASSES of StaviFormulas at depth <= r modulo logical equivalence
- We can construct a canonical representative for each class
- We can build their conjunction (or use cont_holds in a clever way)

This path requires new research into the structure of StaviFormula equivalence classes.

### Path C: Single-Game Architecture
Restructure Case II to use ONE game that covers all positions (a_init, resp_tau, p_n, e_n) simultaneously. This avoids cross-game ordering entirely but requires a fundamentally different proof architecture.

## Current Proof State

### Sorry Sites (Unchanged)
- CaseAnalysis.lean:1435 -- sel_pn_ord Case A (`intro k; sorry`)
- CaseAnalysis.lean:1804 -- sel_pn_ord Case B (`intro k; sorry`)
- CaseAnalysis.lean:2015 -- b_resp vs p_n Case B (`| sorry`)
- CaseAnalysis.lean:2068 -- dead code block (`sorry`)
- CaseAnalysis.lean:4100 -- Cases III-IV winning condition (`sorry`)

### Available Infrastructure
- `ghr93_winning_condition_perm`: selection permutation preserves winning condition (NEW)
- `cont_holds` / `cont_holds_cross`: interval type as predicate (NOT as formula)
- `stavi_untl_gap_detection`: Until formula semantics for gap detection
- `pigeonhole_definable_formula`: extracts a single defining formula from continuation failures
- `Tuple.sort` (Mathlib): sorting permutation for selection arrays

### Key Files
- `CustomGame.lean`: winning_condition_perm at line ~1577 (NEW)
- `CaseAnalysis.lean`: sorry sites at lines 1435, 1804, 2015, 2068, 4100
- `SplitPoint.lean`: SplitPointProps with h_d_compat_left (d-compatible game)
- `Claim1.lean`: cont_holds, continuation_set, pigeonhole infrastructure

## Key Decisions Made

1. **d remains inf(S_C)** -- changing d would break Claim 1 infrastructure for no gain.
2. **Sorting alone is insufficient** -- resolves N-side (a_init(k) < p_n) but not M-side (resp_tau(k) < e_n).
3. **The fan problem is fundamental** -- no game-based approach with separate tau + forward game can produce the cross-game ordering resp_tau(k) < e_n.
4. **U(B,A) is the correct approach** but requires formula materialization infrastructure that doesn't exist yet.

## Deviations from Plan

- ghr93_winning_condition_perm: completed as planned (no deviation)
- Selection sorting: deferred -- useful only after e_n construction replaced
- Formula materialization: blocked on circular dependency with Phase 6
- All downstream tasks (U(B,A), e_n extraction, sorry closures): blocked
