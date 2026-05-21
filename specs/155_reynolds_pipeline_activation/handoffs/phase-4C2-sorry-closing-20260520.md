# Phase 4C.2 Handoff: Strategy Restriction Sorry Closing

**Date**: 2026-05-20T22:00Z
**Session**: sess_1779304083_f28ee0
**Status**: Partial progress on strategy restriction sorries

## What Was Done

### Analysis Phase

Deep analysis of why the original `response_containment_left` and winning condition
transfer sorries were unprovable as stated. Root cause: d (N-side split point) was
taken as a parameter with type/gap-point agreement, but the strategy's response to c
(a'_full(n)) may differ from d. Without d = a'_full(n), the index mapping from the
restricted game to the full game breaks at the boundary index (n+2 in restricted game
maps to n+1 in full game, where M-side has c = a_pad(n) but N-side has a'_full(n) != d).

The GHR93 paper handles this by defining d as an infimum, which guarantees d <= a'_full(n)
for all plays. Our formalization lacks ConditionallyCompleteLattice on ExtendedCarrier.

### Implementation: Restructured Strategy Restriction

1. **Deleted `response_containment_left`** (private, unprovable as stated)

2. **Added `h_d_consistent` hypothesis** to both `ghr93_strategy_restrict_left` and
   `ghr93_strategy_restrict_right`. This hypothesis states that for ANY padded selection
   with c at the designated position, the strategy's response at that position equals d.

3. **Added 4 helper lemmas** for index embeddings:
   - `restrict_emb_left` / `restrict_emb_right`: index mappings from Fin(n+3) to Fin(n+4)
   - `restrict_left_game_tuple_M` / `restrict_left_game_tuple_N`: game_tuple transfer, left
   - `restrict_right_game_tuple_M` / `restrict_right_game_tuple_N`: game_tuple transfer, right

4. **Closed 5 sorries**:
   - 3 winning condition transfer sorries in `ghr93_strategy_restrict_left` (same_order_type,
     gap_point_agreement, formula_agreement) -- proved via index embeddings + h_d_consistent
   - 1 `hb_le_c` sorry in `ghr93_strategy_restrict_left` -- proved from same_order_type
     at indices (n+1, n+2), showing c < extendPoint b => d < extendPoint b', contradiction
     with b' in [x', d]
   - 1 `hc_le_b` sorry in `ghr93_strategy_restrict_right` -- symmetric proof

5. **Updated `obtain_split_point_props`** in ExpressivenessGeneral.lean with sorry'd
   d-consistency conditions (+2 sorries in the caller).

### Sorry Count Change

| File | Before | After | Delta |
|------|--------|-------|-------|
| EFGames.lean (strategy restrict section) | 7 | 2 | -5 |
| ExpressivenessGeneral.lean | 6 | 8 | +2 |
| **Net** | **13** | **10** | **-3** |

### Remaining Sorries in Strategy Restriction

1. **EFGames.lean line ~1900**: `a'_full(i) <= a'_full(n)` in `ghr93_strategy_restrict_left`.
   Needs existence of an actual point in [x',y'] to instantiate hwin_full and get same_order_type.
   Could be closed by adding h_pt hypothesis.

2. **EFGames.lean line ~2100**: `a'_full(0) <= a'_full(i+1)` in `ghr93_strategy_restrict_right`.
   Same issue, symmetric.

3. **ExpressivenessGeneral.lean line ~292**: d-consistency left (`a'_full(n) = d`).
   Requires infimum construction or strategy determinism.

4. **ExpressivenessGeneral.lean line ~302**: d-consistency right (`a'_full(0) = d`).
   Same issue, symmetric.

## Next Actions

1. Add `h_pt` hypothesis to strategy_restrict theorems to close response ordering sorries
2. Address d-consistency in obtain_split_point_props (requires either infimum infrastructure
   or restructuring to have d produced by the strategy)
3. Continue with Phase 4C.3-4C.6 (Cases I-IV)

## Key Decisions

- **h_d_consistent approach**: Rather than building infimum infrastructure, we added the
  consistency condition as a hypothesis. This isolates the infimum issue to the caller.
- **Index embedding approach**: Created explicit Fin-to-Fin mappings and game_tuple transfer
  lemmas. This is cleaner than ad-hoc simp-based proofs and reusable.
