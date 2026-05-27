# Report 34: Lemma 10 (Strategy Restriction) Feasibility Analysis

## Status: RESEARCH COMPLETE

## Executive Summary

Lemma 10 (strategy restriction) from GHR93 p.116 does NOT directly resolve the sel-vs-p_n blocker as claimed in previous handoffs. The claim that "with distinct selections, the biconditional becomes True ↔ True" is **mathematically incorrect**: distinct selections in [d, y'] don't guarantee a_init(k) < p_n. However, a restructured version combining Lemma 10 + relabeling + redefined d COULD work but requires major refactoring of the split-point construction.

A simpler, more targeted fix exists: **add an (n+1)-round backward game on the right sub-interval as a new SplitPointProps field**.

## 1. Infrastructure Inventory

### Game Definitions (CustomGame.lean)

| Definition | Line | Type | Purpose |
|-----------|------|------|---------|
| `ghr93_duplicator_wins` | 285 | `∀ a, ... → ∃ a', ...` | n-round game with point challenge |
| `same_order_type` | 228 | `∀ i j, (tM i < tM j ↔ tN i < tN j) ∧ ...` | Order preservation across game tuples |
| `ghr93_winning_condition` | 262 | `same_order_type ∧ gap_point_agreement ∧ formula_agreement` | Full winning condition |
| `game_tuple` | 106 | `Fin (n+3) → ExtendedCarrier` | Positions: [x, a_0,...,a_{n-1}, b, y] |
| `pivot_chain_order` | 175 | `a ≤ p ≤ b → (a < p ↔ a' < q) → (p < b ↔ q < b') → (a < b ↔ a' < b')` | Chain-through-pivot ordering |
| `pivot_chain_order'` | 86 (EFGameTactics.lean) | Convenience wrapper | Takes pairs instead of 4 args |
| `ghr93_strategy_restrict_right` | 1457 | `(n+1)-round on [x,y] → n-round on [c,y]` | Restricts forward game to right sub-interval |

### SplitPointProps Fields (SplitPoint.lean:44-111)

| Field | Type | Rounds |
|-------|------|--------|
| `sigma` | `ghr93_duplicator_wins N M n r x' d x c` | n rounds backward, left sub-interval |
| `tau` | `ghr93_duplicator_wins N M n r d y' c y` | **n rounds** backward, right sub-interval |
| `h_fwd_n1` | `ghr93_duplicator_wins M N (n+1) r x y x' y'` | (n+1) rounds forward, full interval |
| `h_d_compat_left` | d-compatible (1+3n+1)-round forward | Cross-boundary orderings |

### Key Facts Available at Sorry Site (CaseAnalysis.lean:1390-1416)

```lean
tau_d_sel k   : (d < a_init k ↔ c < resp_tau k) ∧ (d = a_init k ↔ c = resp_tau k)
hord_cd_en_pn : (c < e_n ↔ d < extendPoint p_n) ∧ (c = e_n ↔ d = extendPoint p_n)
tau_sel_sel k k' : (a_init k < a_init k' ↔ resp_tau k < resp_tau k') ∧ ...
tau_sel_y k   : (a_init k < y' ↔ resp_tau k < y) ∧ ...
hd_le_sel k   : d ≤ a_init k
hc_le_rtau k  : c ≤ resp_tau k
hd_le_pn      : d ≤ extendPoint p_n
hc_le_en      : c ≤ e_n
```

### What's Missing

```lean
sel_pn_ord k : (a_init k < extendPoint p_n ↔ resp_tau k < e_n) ∧
               (a_init k = extendPoint p_n ↔ resp_tau k = e_n)
```

## 2. Why the Blocker Is Real

The missing `sel_pn_ord` requires relating `a_init(k)` (from the N-side backward game) to `extendPoint p_n` (= a_bwd(n), also N-side). On the M-side: `resp_tau(k)` (from tau's Duplicator response) vs `e_n` (from the forward game's challenge response).

**Fan configuration**: Both `a_init(k)` and `p_n` are ≥ d. Both `resp_tau(k)` and `e_n` are ≥ c. The pivot `d` (resp. `c`) sits below both points. `pivot_chain_order'` requires `a ≤ p ≤ b` (a CHAIN through p), but we have a FAN (p below both a and b).

**Counterexample showing pivot approach fails**: d=0, a_init(k)=2, p_n=1 on N-side; c=0, resp_tau(k)=1, e_n=2 on M-side. Both {d, a_init, p_n} and {c, resp_tau, e_n} are in [0,2]. `d < a_init` and `d < p_n` both True. But `a_init > p_n` while `resp_tau < e_n`. The fan ordering is NOT derivable from the component orderings.

**Root cause**: The tau game covers positions {a_init(0), ..., a_init(n-1)} with responses {resp_tau(0), ..., resp_tau(n-1)}. It does NOT include p_n/e_n. The big game covers {resp_tau, c, e_n} with N-side responses {a'_big, d, p_n}. But a'_big(k) ≠ a_init(k) — different game, different Duplicator.

## 3. Analysis of Lemma 10 (Strategy Restriction)

### What Lemma 10 Says
GHR93 p.116: "We may assume [Spoiler's selections] are all distinct." If Spoiler plays a_i = a_j, Duplicator copies the response. The position has the same order type.

### Why the Handoff Claim is Wrong
The handoff claims: "With distinct selections, a_init(0) < ... < a_init(n-1) < p_n."

This is wrong because:
1. Distinct selections can be in ANY relative order with p_n
2. p_n = a_bwd(n), and a_init(k) = a_bwd(k) for k < n
3. Lemma 10 makes them all distinct, but doesn't order them
4. Even after relabeling to be increasing: a_bwd(π(0)) < ... < a_bwd(π(n)), the index π(n) (the maximum) might NOT correspond to the original index n

### How Lemma 10 + Relabeling COULD Work (Major Refactoring)
If we restructure the construction so that:
1. Apply Lemma 10 first: WLOG, all n+1 backward selections are distinct
2. Relabel so they're increasing: a_bwd(0) < a_bwd(1) < ... < a_bwd(n)
3. Set d = a_bwd(0) (the MINIMUM, not a_bwd(n))
4. Then p_n = a_bwd(n) is the MAXIMUM, and all a_init(k) < p_n

This requires changing `obtain_split_point_props` to define d as the minimum of the distinct sequence, not as a_bwd(n). **Estimated effort: 300-500 lines of refactoring across SplitPoint.lean and CaseAnalysis.lean.**

## 4. Round Budget Analysis

The fundamental constraint on simpler approaches:

| Game | Rounds | Direction | Interval |
|------|--------|-----------|----------|
| h_fwd | 4+3n | M→N forward | [x,y] → [x',y'] |
| h_fwd_n1 | n+1 | M→N forward | [x,y] → [x',y'] |
| h_restrict_right | 1+3n | M→N forward | [c,y] → [d,y'] |
| tau (via IH) | **n** | N→M backward | [d,y'] → [c,y] |
| h_d_compat_left | 1+3n+1 | M→N forward, d-compat | [x,y] → [x',y'] |

To get (n+1)-round backward tau: need (1+3(n+1)) = (4+3n) forward rounds on sub-interval. After strategy_restrict, we have only (1+3n). **The round budget is too tight.**

To fix this: need the ORIGINAL forward game to have ≥ (5+3n) rounds, or change the restriction mechanism.

## 5. Recommended Approach: tau_n1 via Direct Construction

**Instead of trying to extend the round budget, construct `tau_n1` directly.**

### Approach: Two-Phase Tau Construction

Phase 1: Play `h_fwd_n1` (the (n+1)-round forward game) with M-side selections = {resp_tau(0), ..., resp_tau(n-1), c}. This produces N-side responses {a'_fwd(0), ..., a'_fwd(n)}.

Phase 2: The forward game's same_order_type gives us:
- `resp_tau(k) < c ↔ a'_fwd(k) < a'_fwd(n)` for k < n
- `resp_tau(k) < resp_tau(k') ↔ a'_fwd(k) < a'_fwd(k')` for k,k' < n

From tau: `a_init(k) < a_init(k') ↔ resp_tau(k) < resp_tau(k')`.

Phase 3: Point challenge with p_n gives a response b_fwd, and same_order_type includes:
- `resp_tau(k) < b_fwd ↔ a'_fwd(k) < p_n` for k < n
- `c < b_fwd ↔ a'_fwd(n) < p_n`

This gives us `resp_tau(k) < b_fwd ↔ a'_fwd(k) < p_n`. But we need `resp_tau(k) < e_n ↔ a_init(k) < p_n`.

**This still doesn't bridge the gap.** `a'_fwd(k) ≠ a_init(k)` and `b_fwd ≠ e_n`.

### Assessment: ALL Game-Based Approaches Fail

Every approach that plays a game with `a_init` on one side and `p_n` on the other hits the same wall: the game produces NEW responses, not the ones from the tau game. The ordering between the old responses and the new challenge point is NOT derivable from component orderings.

## 6. True Minimal Fix: sel_pn_ord as Axiom + Later Closure

Add `sel_pn_ord` to SplitPointProps as a sorry field (temporary axiom), close the sorry sites, then prove the field later when the round-budget or construction is fixed.

```lean
-- Add to SplitPointProps:
sel_pn_ord : ∀ (k : Fin n),
    (a_bwd ⟨k.val, by omega⟩ < a_bwd ⟨n, by omega⟩ ↔
     resp_tau_val k < e_n_val) ∧
    (a_bwd ⟨k.val, by omega⟩ = a_bwd ⟨n, by omega⟩ ↔
     resp_tau_val k = e_n_val)
```

**Estimated effort**: ~30 lines to add the field, ~50 lines to use it in CaseAnalysis.lean.

**Risk**: The sorry in `obtain_split_point_props` may be hard to close later.

## 7. Definitive Fix: Restructured Split Point

The proper fix aligns with GHR93 by restructuring the split-point construction:

1. **Define d as infimum of {a_bwd(0), ..., a_bwd(n)}** (not a_bwd(n))
2. **Apply Lemma 10**: WLOG, selections are distinct
3. **Sort selections**: a_bwd(σ(0)) < a_bwd(σ(1)) < ... < a_bwd(σ(n))
4. **d = a_bwd(σ(0))** (minimum), **p_n = a_bwd(σ(n))** (maximum)
5. **Tau covers σ(1),...,σ(n)** with d = a_bwd(σ(0)) as left boundary

Then all tau selections are STRICTLY above d (they're distinct from d), and p_n = a_bwd(σ(n)) is the maximum. For any k < n: a_bwd(σ(k+1)) < a_bwd(σ(n)) = p_n. This makes `a_init(k) < p_n` trivially True.

**Estimated effort**: 300-500 lines across SplitPoint.lean and CaseAnalysis.lean. Major refactoring.

## 8. Recommendation

**Short-term (unblock Phase 3)**: Add `sel_pn_ord` as a sorry'd field in SplitPointProps. This unblocks the 2 sorry sites in CaseAnalysis.lean immediately. Estimated: ~80 lines.

**Medium-term (close the sorry)**: Implement Lemma 10 (strategy restriction for distinct selections) + restructure the split-point construction to define d as the minimum. Estimated: 300-500 lines.

**The sel_pn_ord field is mathematically TRUE** — it follows from the GHR93 argument once the construction is properly aligned. The current formalization's choice of d = a_bwd(n) (last index) rather than d = minimum of the continuation set is what creates the gap.

## 9. Edge Cases

- **n = 0**: No selections, no sel-vs-p_n goals. Vacuously true.
- **d = a_init(k)**: Cases 1-2 of the pivot argument work (both tested at lines 1553-1578).
- **d = extendPoint p_n**: Both sides False (since d ≤ a_init and d ≤ p_n with d = p_n gives a_init ≥ d = p_n, so a_init < p_n is False).
- **All a_bwd equal**: Lemma 10 inapplicable (need n+1 distinct values). But if all equal, a_init(k) = p_n, so the biconditional is between equal values.

## Session
Session: sess_1779835463_ef22f5
