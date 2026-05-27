# Path C Research: Single-Game Architecture for Case II

**Task**: 155 (Reynolds Pipeline Activation)
**Date**: 2026-05-27
**Focus**: Can Case II be restructured to use a SINGLE game covering all positions?

## 1. Current Game Architecture in Case II

Case II (`ghr93_case_II`, CaseAnalysis.lean lines 1187-1708) currently uses **three distinct games**:

### Game 1: Tau (n-round backward game on [d, y'] / [c, y])

- **Source**: `props.tau` from `SplitPointProps` (SplitPoint.lean line 92)
- **Direction**: Backward (N selects, M responds)
- **Rounds**: n
- **N-side selections**: `a_init(k) = a_bwd(k)` for k = 0..n-1 (the first n of the n+1 backward selections)
- **M-side responses**: `resp_tau(k)` for k = 0..n-1
- **Interval**: [d, y'] (N-side), [c, y] (M-side)
- **Provides**: `same_order_type` among `{d, a_init(0..n-1), b_tau, y'}` and `{c, resp_tau(0..n-1), b_tau_M, y}`

### Game 2: D-compatible forward game (1+3n+1 rounds on [x, y] / [x', y'])

- **Source**: `props.h_d_compat_left` from `SplitPointProps` (SplitPoint.lean lines 101-111)
- **Direction**: Forward (M selects, N responds)
- **Rounds**: 1 + 3n + 1 = 2 + 3n
- **M-side selections**: `a_pad_big(i)` -- resp_tau(i) for i < n, then c at position 1+3n, plus padding
- **N-side responses**: `a'_big(i)` -- some responses in [x', y'], with `a'_big(1+3n) = d`
- **Challenge**: p_n (a carrier point from a_bwd(n)), producing response e_n
- **Interval**: [x, y] (M-side), [x', y'] (N-side)
- **Provides**: `same_order_type` among `{x, a_pad_big(0..2+3n-1), e_n, y}` and `{x', a'_big(0..2+3n-1), p_n, y'}`

### Game 3: Sigma (n-round backward game on [x', d] / [x, c])

- **Source**: `props.sigma` from `SplitPointProps` (SplitPoint.lean line 89)
- **Direction**: Backward (N selects, M responds)
- **Rounds**: n
- **Used only in Case A** (b_sp <= c) for round-2 delegation and x-vs-d ordering
- **Interval**: [x', d] (N-side), [x, c] (M-side)

### The Fan Problem

The `sel_pn_ord` sorry at lines 1435 and 1804 requires:

```
(a_init(k) < extendPoint p_n <-> resp_tau(k) < e_n)
```

- `a_init(k)` and `resp_tau(k)` come from **Game 1 (tau)**
- `extendPoint p_n` and `e_n` come from **Game 2 (d-compat forward)**
- Tau's `same_order_type` covers `{d, a_init, b_tau, y'}` vs `{c, resp_tau, b_tau_M, y}` -- it does NOT include p_n or e_n
- The forward game's `same_order_type` covers `{x, a_pad_big, e_n, y}` vs `{x', a'_big, p_n, y'}` -- it includes resp_tau(k) as selections, but the responses a'_big(k) are NOT a_init(k)

The geometry is:
- `d <= a_init(k)` (tau interval bound)
- `d <= extendPoint p_n` (all selections >= d)
- `c <= resp_tau(k)` (tau interval bound)
- `c <= e_n` (derived from d <= p_n via cross-boundary ordering)

Both a_init(k) and p_n are >= d, but they branch from d with no chain connecting them. Similarly resp_tau(k) and e_n are >= c. This is the "fan" -- `pivot_chain_order` requires a chain (a <= p <= b), not a fan (a <= b1, a <= b2).

## 2. Single-Game Design Analysis

### Option 2A: Extended tau to (n+1) backward rounds

**Idea**: Replace the n-round tau with an (n+1)-round backward game on [d, y'] / [c, y]. The (n+1) N-side selections would be:
- a_init(0), ..., a_init(n-1), p_n (= a_bwd(n))

All are in [d, y']. The M-side responses would be:
- resp(0), ..., resp(n-1), resp(n) = e_n_new

The `same_order_type` of this single (n+1)-round game would directly give:
```
(a_init(k) < p_n <-> resp(k) < e_n_new) for all k < n
```

This is **exactly** `sel_pn_ord`.

**Problem: Round Budget**

The (n+1)-round backward game on [d, y'] / [c, y] requires an `(n+1)`-round backward strategy on that sub-interval. Where does this come from?

Currently:
- The inductive step has a **(4+3n)-round forward** strategy on [x, y] / [x', y'] (SplitPoint.lean line 155: `h_fwd`)
- Strategy restriction to [c, y] / [d, y'] consumes 1 round: `ghr93_strategy_restrict_right` takes `(n+1)` rounds and produces `n` rounds. More precisely, it takes a d-consistent `(k+1)`-round forward game on [x,y] and produces a `k`-round forward game on [c,y].
- To get **(1+3n) forward** rounds on [c, y], we need **(1+3n+1) forward** rounds on [x, y]. The SplitPoint construction does exactly this (line 813-814): `1+3n+1 <= 4+3n` by omega, so this works.
- Applying the IH to (1+3n) forward rounds on [c, y] / [d, y'] gives **n backward** rounds (by IH: forward (1+3n) -> backward n).

To get **(n+1) backward** rounds on [d, y'] / [c, y], we would need **(1+3(n+1)) = (4+3n) forward** rounds on [c, y] / [d, y']. This requires **(4+3n+1) forward** rounds on [x, y] / [x', y'] before strategy restriction. But we only have **(4+3n)** rounds total. **We are exactly 1 round short.**

**Verdict: INFEASIBLE with current round budget.** The caller provides exactly (4+3n) forward rounds, and getting (n+1) backward rounds on the sub-interval would require (4+3n+1).

### Option 2B: Use h_fwd_n1 directly as an (n+1)-round forward game

`SplitPointProps` provides `h_fwd_n1 : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y'` (line 96). This is an (n+1)-round **forward** game on the full interval [x, y] / [x', y'].

**Idea**: Play this game with M-side selections being a_init(0), ..., a_init(n-1), extendPoint p_n (wait -- a_init is N-side). Problem: `h_fwd_n1` is a forward game where **M selects** and **N responds**. But a_init(k) lives on the N-side.

We could try the reverse: play with M-side selections = resp_tau(0), ..., resp_tau(n-1), e_n (once found). But e_n is what we're trying to construct -- circular.

**Verdict: INFEASIBLE.** The direction mismatch (forward = M selects, but we need N-side a_init as selections) prevents direct use.

### Option 2C: Reverse h_fwd_n1 via forward-to-backward

Apply `ghr93_forward_to_backward` to h_fwd_n1 to get a backward game. The forward-to-backward theorem converts (1+3n)-round forward to n-round backward. But h_fwd_n1 has only (n+1) forward rounds, not (1+3n). For n >= 1, n+1 < 1+3n = 3n+1. **Not enough rounds.**

Actually, wait: we need to convert h_fwd_n1's (n+1) forward rounds. The forward-to-backward theorem requires (1+3m) forward rounds to get m backward rounds. Setting m such that 1+3m = n+1 gives m = n/3, which is not an integer in general.

**Verdict: INFEASIBLE.** Round counts don't match for the forward-to-backward conversion.

### Option 2D: Separate (n+1)-round game from h_d_compat_left

`h_d_compat_left` provides a **(2+3n)-round forward** game on [x,y]/[x',y'] with d-consistency. Can we extract an (n+1)-round backward game from this?

(2+3n) forward rounds -> by forward-to-backward theorem, we need (1+3m) forward rounds for m backward rounds. So m = (2+3n-1)/3 = (1+3n)/3 which is not necessarily an integer.

For the forward-to-backward conversion: (1+3m) -> m backward. Set 1+3m = 2+3n, so 3m = 1+3n, m = (1+3n)/3. For n=1: m = 4/3 -- not integer. **INFEASIBLE.**

### Option 2E: Play tau AND challenge with p_n in the SAME game

**Key Insight**: The current construction plays tau's n rounds separately, then plays the d-compat forward game. What if we could combine them?

The tau game is a backward game: N selects a_init(0..n-1) from [d,y'], M responds with resp_tau(0..n-1) from [c,y]. Then N challenges with b_tau from [c,y] and M responds with b_tau_resp from [d,y'].

If we could somehow ALSO challenge with p_n inside this same game, the same_order_type would cover both a_init vs resp_tau AND p_n vs its response. But the game structure has exactly ONE challenge point per game (Round 2 = single point challenge).

**Variant**: What if we made p_n = b_tau (the challenge point)? Then the response would be the tau game's b-response. Tau challenge is by M (M picks a carrier point from [c,y]; N responds from [d,y']). But p_n is an N-carrier point from [d,y'], not an M-carrier point from [c,y]. **Direction mismatch.**

Actually, check the game definition more carefully. In `ghr93_duplicator_wins N M atomMap n r d y' c y`:
- N selects first (a_init from [d,y'])
- M responds (resp_tau from [c,y])
- Then M challenges with b_sp from [c,y] (carrier point)
- N responds with b_resp from [d,y'] (carrier point)

So the challenge point is an M-carrier point from [c,y], and p_n is an N-carrier point from [d,y']. We cannot make p_n be the challenge. **INFEASIBLE.**

### Option 2F: Use a game with n+1 selections INCLUDING p_n

Since `a_bwd = [a_init(0), ..., a_init(n-1), a_bwd(n)]` where `a_bwd(n) = extendPoint p_n`, we could in principle play a game with ALL n+1 of them.

Tau is an n-round backward game. The full backward game at the inductive step is (n+1)-round. The issue is that tau only covers [d,y']/[c,y], while the full backward game covers [x',y']/[x,y].

If we had an (n+1)-round backward game on [d,y']/[c,y], we could play it with all n+1 selections (since all a_bwd(i) >= d). But as shown in Option 2A, getting (n+1) backward rounds on this sub-interval requires (4+3n+1) forward rounds -- one more than available.

**Verdict: INFEASIBLE** -- same round budget constraint as Option 2A.

## 3. Round Budget Analysis (Detailed)

Starting resources:
- **Forward game**: (4+3n) rounds on [x,y]/[x',y'] at rank r
- **Forward game at rank r+2**: (4+3n) rounds at rank r+2 (from h_r1_univ)

Round consumption:
1. **round_mono** to (1+3n+1) = (2+3n) rounds: OK (2+3n <= 4+3n)
2. **d_consistency_left**: consumes 0 extra rounds, just packages the (2+3n) game with d-consistency guarantee
3. **strategy_restrict_right** on (2+3n) rounds: produces (1+3n) forward rounds on [c,y]/[d,y']
4. **IH** on (1+3n) forward rounds: produces **n backward** rounds on [d,y']/[c,y] = tau

For n+1 backward rounds on [d,y']/[c,y]:
1. Need (1+3(n+1)) = (4+3n) forward rounds on [c,y]/[d,y']
2. Need (4+3n+1) forward rounds on [x,y]/[x',y'] before strategy_restrict
3. We only have (4+3n). **SHORT BY 1 ROUND.**

The +1 deficit is structural: strategy_restrict consumes 1 round by padding selections with c at the boundary.

## 4. GHR93 Paper Comparison

Based on the handoff at phase-3e-handoff.md line 75:

> "The GHR93 proof uses ONE game at the higher rank, not two separate games."

The GHR93 paper (Gabbay, Hodkinson, Reynolds 1993) handles Case II differently:

1. **GHR93 plays ONE forward game at rank r**, not separate tau + forward games
2. The single game includes ALL positions: selections a_0..a_n, their responses, AND e_n
3. The `same_order_type` of this single game directly gives all pairwise orderings
4. There is no need for cross-game ordering transfer

The Lean formalization diverged from GHR93 by:
- Constructing tau via the IH on a sub-interval (which gives an n-round backward game)
- Using a separate d-compatible forward game for e_n
- Attempting to COMBINE orderings from these two independent games

The paper avoids the fan problem entirely because it never has two separate games whose orderings need merging.

### Why the Formalization Diverged

The formalization's approach came from the split-point decomposition:
1. d is constructed as inf(S_C), splitting [x',y'] into [x',d] and [d,y']
2. Strategy restriction produces forward games on sub-intervals
3. The IH converts sub-interval forward games to backward games (sigma, tau)
4. These backward games are used directly

The paper presumably handles the ordering more carefully, likely through one of these mechanisms:
- A single game at a higher round count that subsumes both tau and the e_n construction
- A direct argument using the forward strategy without decomposing into backward sub-games
- The continuation/formula materialization approach (Path A/B from the handoff)

## 5. Feasibility Verdict

**Path C (single-game restructuring) is INFEASIBLE** as a self-contained approach for the following reasons:

1. **Round budget deficit**: Getting (n+1) backward rounds on [d,y']/[c,y] requires (4+3n+1) forward rounds on [x,y]/[x',y'], but only (4+3n) are available. The deficit is exactly 1 round, caused by strategy_restrict consuming 1 round.

2. **Direction mismatches**: Forward games have M selecting and N responding, but we need N-side a_init as selections. Backward tau has N selecting, but the challenge point must be an M-carrier point.

3. **No round-count workaround exists**: All variants (2A through 2F) hit either the round budget or the direction mismatch. The round budget is tight -- the proof requires exactly (4+3n) rounds and there is no slack.

### Could the Round Budget Be Changed?

In principle, if the main theorem used `(5+3n)` or `(4+3(n+1))` forward rounds instead of `(4+3n)`, the single-game approach would work. But:

- The round count `(4+3n)` is dictated by the GHR93 theorem statement
- Increasing it would change the theorem being proved
- The whole point of the forward-to-backward conversion is to show that `(1+3n)` forward rounds suffice for n backward rounds, with the `4+3n` coming from the inductive step needing `1+3(n+1) = 4+3n`

So the round budget is NOT negotiable.

## 6. Comparison with Paths A and B

### Path A: Implement Phase 6 First (Formula Materialization)

- **Approach**: Implement `nf_characterizable_by_stavi` (Phase 6) to express interval types as StaviFormulas, then use U(B,A) (Stavi Until) to encode the ordering as a temporal formula
- **Feasibility**: HIGH -- breaks the Phase 3C/6 circular dependency by showing Phase 6 is independently provable
- **Effort**: Large (Phase 6 requires Proposition 7, composition lemma, etc.)
- **Risk**: Medium -- Phase 6 has its own sorry chain but is structurally independent
- **Cleanest result**: YES -- follows the GHR93 paper's approach more closely

### Path B: Direct Formula Construction

- **Approach**: Construct interval-type formulas directly without the full nf_characterizable machinery
- **Feasibility**: UNCLEAR -- requires understanding the finite structure of StaviFormula equivalence classes
- **Effort**: Medium if feasible
- **Risk**: High -- may not be achievable without Phase 6 infrastructure

### Path C: Single-Game Architecture (This Report)

- **Feasibility**: **INFEASIBLE** due to round budget constraints
- **No workaround**: All 6 variants explored hit fundamental obstacles

### Path D (Not Previously Enumerated): Interval-Bound Strategy

There is existing work (handoff `phase-5-interval-bound-handoff-20260527.md`) on using sub-interval forward games via `h_r1_univ` to derive ordering facts. The `sel_pn_ord` problem is structurally similar to the Cases III/IV interval bound problem:

- Both need to show an ordering between elements from different sub-games
- Both could use `h_r1_univ` to play a sub-interval forward game that includes BOTH elements
- The interval bound strategy plays a 1-round game on a sub-interval containing both elements, then extracts ordering from `same_order_type` at positions 0 and 2

**For sel_pn_ord**: Play a 1-round forward game on [d, y'] / [c, y] (or [c, y] / [d, y'] depending on direction) via `h_r1_univ`. Select `resp_tau(k)` (M-side). Challenge with the N-carrier point corresponding to p_n. The game's `same_order_type` would give ordering between `resp_tau(k)` and whatever M responds to the p_n challenge. But this M-response is NOT necessarily e_n.

The key question for Path D: can we derive `sel_pn_ord` from `h_r1_univ` by playing a sub-interval game that includes resp_tau(k), a_init(k), p_n, and e_n simultaneously? This requires further research but appears more promising than Path C because `h_r1_univ` is universally quantified over endpoints and works at any rank.

## 7. Estimated Effort (If Path C Were Feasible)

Not applicable -- Path C is infeasible. For comparison:

| Path | Effort (LOC) | Files Affected | Risk |
|------|-------------|----------------|------|
| A (Phase 6 First) | ~2000 | 3-5 new files | Medium |
| B (Direct Formula) | ~500-1000 | 2-3 files | High |
| C (Single Game) | **INFEASIBLE** | -- | -- |
| D (h_r1_univ) | ~200-400 | CaseAnalysis.lean only | Medium-Low |

## 8. Recommendation

**Path A** provides the cleanest long-term result by following the GHR93 paper structure and building the formula materialization infrastructure that may be needed elsewhere.

**Path D** (using `h_r1_univ` sub-interval games) deserves dedicated research as a potentially cheaper alternative that avoids the formula materialization entirely. It is structurally analogous to the proven-correct interval bound strategy already documented for Cases III/IV.

**Path C should be abandoned** -- the round budget constraint is fundamental and not negotiable.
