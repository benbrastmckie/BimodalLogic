# Alternative Proof Structures for GHR93 Case II Claim 1

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-26
**Focus**: Assess whether the sigma/tau decomposition is the correct approach and evaluate alternative proof structures for the cross-boundary ordering blocker in Case II.

---

## 1. Does GHR93 Use Sigma/Tau Decomposition?

**Yes, GHR93 explicitly uses sigma/tau decomposition.** This is not a simplification introduced during formalization -- it is the core structure of the original proof. The verbatim text from GHR93 Section 8, pp. 117-118 states:

> "She already has a winning strategy sigma for G_{n; r+4}(N, x'd-bar; M, xc)."
> "So by the induction hypothesis (*) _n she has a winning strategy tau for G_{n; r+4}(N, d-bar b'; M, cb)."

The sigma/tau decomposition is intrinsic to the proof. The proof does NOT handle all n+1 positions in a single game. Instead:

1. **Sigma** handles the sub-interval [x', d-bar] vs [x, c]
2. **Tau** handles the sub-interval [d-bar, b'] vs [c, b] (or [d-bar, y'] vs [c, y] in our broader version)
3. **e_n** is constructed FRESH from tau's formula transfer (not from any game directly)
4. **Round 2** dispatches to sigma, tau, or ad-hoc matching depending on where Spoiler plays

The critical point: GHR93's tau game handles only a_0, ..., a_{n-1} (n positions). The position a_n is NOT in the tau game. Instead, e_n (the response to a_n) is constructed via U(B,A) transfer from the tau game's formula agreement.

---

## 2. The Precise Nature of the Blocker

The current code has three sorry sites in `ghr93_case_II` (CaseAnalysis.lean):

| Line | Location | Nature |
|------|----------|--------|
| 1569 | Case A same_order_type | One grid cell in sigma sub-case ordering |
| 1657 | Case B same_order_type | Full ordering assembly in tau sub-case |
| 1710 | Case B same_order_type | Same sorry with dead code block |

Lines 1657 and 1710 are the SAME sorry (the block-commented code at 1658-1709 is dead). The actual blocker is the `same_order_type` assembly for the (n+1)-round game tuple when b_sp > c.

The specific problem identified in the dead code comment (line 1655):

> "The pivot_chain_order approach needs (x' < d iff x < c) which requires instantiating the sigma strategy."

This is the cross-boundary ordering problem. To prove `same_order_type` for the full (n+1)-round game, we need orderings between:

- **Tau positions** (a_init(k) / resp_tau(k)): Available from `hord_tau`
- **e_n / p_n**: Available from `hord_cd_en_pn` and forward game orderings
- **x / x' and y / y'**: Available from forward game orderings
- **Cross-domain orderings** (e.g., x' vs a_init(k), resp_tau(k) vs e_n): These require **pivot chains** through d/c, which in turn require (x' < d iff x < c)

The ordering (x' < d iff x < c) is NOT directly available from the tau game (tau's game tuple starts at d/c, not x'/x). It IS available from the sigma game, but the current Case B code instantiates sigma only in the Case A branch (b_sp <= c). In Case B, sigma is not instantiated.

### Why Case A Works but Case B Does Not

In Case A (b_sp <= c), the code at line 1340 instantiates sigma:
```
obtain ⟨_resp_sig, _, hwin_sig⟩ := props.sigma (fun _ => d) (fun _ => hd_in_x'd)
```
This gives `sig_x_d : (x' < d iff x < c)` from sigma's ordering at positions 0 vs n+2.

In Case B (b_sp > c), the code tries to use only tau and the forward game, but tau does not provide the x'/x to d/c ordering. The sigma game is never instantiated.

---

## 3. Feasibility Assessment of Each Alternative

### Alternative 1: Fix the Current Approach (Instantiate Sigma in Case B)

**Description**: Simply instantiate the sigma game in Case B, the same way Case A does. The sigma game gives (x' < d iff x < c), which is all that is needed for the pivot chains.

**Feasibility**: HIGH. The sigma strategy `props.sigma` is available in both branches. In Case B, it can be instantiated with dummy selections (e.g., `fun _ => d` as in Case A) to extract the boundary ordering. The key insight from Case A's working proof (lines 1370-1568) is that `sig_x_d` is derived from `hord_sig` at positions 0 and n+2. The SAME derivation works in Case B.

**What is needed**:
1. Add `obtain ⟨_, _, hwin_sig_dummy⟩ := props.sigma (fun _ => d) (fun _ => ⟨props.hx'd, le_refl d⟩)` in the Case B branch
2. Extract `sig_x_d` from the sigma game's ordering
3. The rest of the pivot chain arguments follow the same pattern as Case A

**Evidence**: Case A (lines 1370-1568) already proves the COMPLETE `same_order_type` for a more complex configuration (sigma + tau + forward + cross-boundary). Case B has fewer complications (no sigma positions in the game tuple), so it should be EASIER.

**Effort**: 40-80 lines. The dead code block (lines 1658-1709) contains most of the necessary extractions -- the only missing piece is `sig_x_d`. Once that is added, the `same_order_type_grid` tactic should close the goal as it does in Case A.

**Risk**: LOW. The pattern is proven to work in Case A.

### Alternative 2: Single (n+1)-Round Tau Game on [d, y']

**Description**: Run a single (n+1)-round tau game on [d, y'] x [c, y] that includes ALL positions (a_0, ..., a_{n-1}, a_n), so orderings between tau positions and a_n come from the same game.

**Feasibility**: LOW. This approach has fundamental problems:

1. **Incompatible with the IH**: The inductive hypothesis gives an n-round game on [d, y']. To get an (n+1)-round game on [d, y'], we would need a (4+3(n+1))-round forward strategy restricted to [c, y] x [d, y']. But `strategy_restrict_right` only produces (1+3n)-round games from (1+3n+1)-round games. We would need (4+3n)-round = (1+3(n+1)+1)-round on the sub-interval, which requires (1+3(n+1)+2)-round on the full interval. We have (4+3n) rounds, and (4+3n) = (1+3(n+1)+1), so this gives (1+3(n+1))-round = (4+3n)-round on the sub-interval, which by IH gives an (n+1)-round backward game. This is exactly tau already, but at (n+1) rounds.

2. **But tau is constructed as an n-round game**: The current infrastructure gives tau as an n-round backward game. To make it (n+1)-round, we would need to bypass the IH and use a separate argument. This would require substantial restructuring of `obtain_split_point_props`.

3. **GHR93 does not do this**: GHR93 explicitly uses an n-round tau game (for n positions) and constructs e_n separately. Diverging from the literature here would introduce risk.

**Effort**: 300-500 lines (substantial restructuring of SplitPoint.lean and CaseAnalysis.lean).

**Risk**: HIGH. Fundamental changes to the game-round arithmetic.

### Alternative 3: Inductive Extension

**Description**: Use the IH more directly -- construct the (n+1)-round game by extending an n-round game with one extra position.

**Feasibility**: MEDIUM-LOW. This is essentially what GHR93 already does (tau gives n rounds, e_n extends to n+1). The "extension" step IS the U(B,A) transfer and e_n construction. The current code already has this structure. The blocker is not the extension logic but the ordering assembly AFTER extension.

**Effort**: Does not address the actual blocker.

**Risk**: N/A -- this is the current approach.

### Alternative 4: Prove Ordering from Structure (Formula Agreement Transfer)

**Description**: Instead of deriving a_init(k) < a_n iff resp_tau(k) < e_n from a combined game, derive it from:
- a_init(k) < a_n is a fact about N (known from the adversary's play)
- resp_tau(k) < e_n should follow from c <= resp_tau(k) (from tau) and c <= e_n (from cross-boundary ordering), plus the fact that resp_tau(k) and e_n are both in [c, y]

**Feasibility**: LOW-MEDIUM. The problem is that "resp_tau(k) < e_n" does NOT follow from just interval containment. Both are in [c, y], but that does not determine their relative order. The ordering must come from a game or from a pivot chain argument.

However, the ordering CAN be derived via pivot chains:
- a_init(k) < a_bwd(n) (from N-side ordering, since Spoiler's picks are strictly ordered)
- (a_init(k) < a_bwd(n) iff resp_tau(k) < ?) -- this needs a game that contains BOTH positions

The issue circles back to the same problem: tau contains resp_tau(k) but not e_n. The forward game contains e_n but not resp_tau(k).

**The pivot chain solution**: resp_tau(k) < e_n iff a_init(k) < a_bwd(n), proved by:
1. a_init(k) < d (from tau: tau_d_sel)
2. d < a_bwd(n) (from h_no_split, when d < a_bwd(n) strictly)
3. c < resp_tau(k) (from tau: tau_d_sel)
4. c < e_n (from cross-boundary ordering hord_cd_en_pn)
5. Pivot: a_init(k) < a_bwd(n) iff resp_tau(k) < e_n via the chain d/c -> a_init(k)/resp_tau(k) and d/c -> p_n/e_n

This IS the pivot_chain_order approach, and it works WITH sig_x_d. This is exactly Alternative 1.

**Effort**: Same as Alternative 1 (the pivot chain IS the mechanism).

**Risk**: Same as Alternative 1.

---

## 4. Codebase Analysis: What Exists and What Is Missing

### Game Tuples in Case II

The `SplitPointProps` record provides:

| Field | Type | Status |
|-------|------|--------|
| `sigma` | n-round backward on [x',d] vs [x,c] | Sorry-free |
| `tau` | n-round backward on [d,y'] vs [c,y] | Sorry-free |
| `h_fwd_n1` | (n+1)-round forward on [x,y] vs [x',y'] | Sorry-free |
| `h_d_compat_left` | D-compatible forward with d at boundary | Sorry-free |
| `hd_le_an` | d <= a_bwd(n) | Sorry-free |
| `hcd_form` | Formula agreement c <-> d | Sorry-free |
| `hcd_gp` | Gap/point correspondence c <-> d | Sorry-free |

### Cross-Boundary Ordering Available

From `h_d_compat_left` (the d-compatible forward game), we get:

| Ordering | Source |
|----------|--------|
| `hord_cd_en_pn : (c < e_n iff d < p_n) and (c = e_n iff d = p_n)` | Lines 1262-1289 |
| `hord_fwd_x_en : (x < e_n iff x' < p_n) and ...` | Lines 1291-1294 |
| `hord_fwd_en_y : (e_n < y iff p_n < y') and ...` | Lines 1298-1301 |

### What Is Missing (The Single Missing Piece)

**`sig_x_d : (x' < d iff x < c) and (x' = d iff x = c)`**

This ordering between the boundary endpoints x'/x and d/c is NOT available from tau (which starts at d/c) and NOT available from the forward game (which does not directly relate x' to d). It IS available from sigma, which covers [x',d] vs [x,c] and has x' and d in its game tuple.

The fix: instantiate sigma in the Case B branch to extract this ordering.

### The Sorry at Line 1569 (Case A)

This is a single remaining grid cell in the Case A ordering proof. The error message from the dead code indicates it is a minor index-mapping issue in the `same_order_type_grid` macro. It is likely closeable with a few lines of manual case dispatch.

---

## 5. Ranked Recommendations

### Rank 1 (Strongly Recommended): Fix Case B by Instantiating Sigma

**Approach**: Add sigma instantiation in the Case B branch of `ghr93_case_II` to derive `sig_x_d`, then use `same_order_type_grid` with `pivot_chain_order'` exactly as in Case A.

**Steps**:
1. In the Case B branch (after line 1625), add:
   ```lean
   -- Extract boundary ordering from sigma (same pattern as Case A)
   obtain ⟨_, _, hwin_sig_aux⟩ := props.sigma (fun _ => d) (fun _ => ⟨props.hx'd, le_refl d⟩)
   obtain ⟨b_sig_aux, _, hcond_sig_aux⟩ := hwin_sig_aux (some_point_in_xc) (some_point_in_xc_interval)
   ```
2. Extract `sig_x_d` from `hcond_sig_aux.1` at positions 0 vs n+2
3. Copy the `same_order_type_grid` approach from Case A (lines 1418-1568), adapting for Case B's game tuple structure

**Effort**: 40-80 lines
**Risk**: LOW
**Dependencies**: None (all infrastructure exists)

### Rank 2: Fix the Sorry at Line 1569 (Case A, Single Grid Cell)

**Approach**: The sorry at line 1569 is inside a `first | ... | sorry)` pattern, meaning all other tactic alternatives failed. This likely needs manual case analysis for one specific grid cell in the N x N ordering matrix.

**Effort**: 5-20 lines
**Risk**: LOW

### Rank 3: Restructure to Match GHR93's e_n Construction More Closely

**Approach**: Instead of using `h_d_compat_left` to construct e_n from a forward game, construct e_n via U(B,A) transfer through tau (matching GHR93 exactly). This would make the proof more faithful to the literature but requires materializing U(B,A) as a StaviFormula.

**NOT recommended for the current blocker** because the current e_n construction already works -- the blocker is in the ordering assembly, not the e_n construction. However, this approach would give STRONGER properties (e.g., resp_tau(k) < e_n would follow directly from tau's game if e_n were constructed inside tau's scope).

**Effort**: 150-300 lines (new infrastructure for U(B,A) formula)
**Risk**: MEDIUM

### Rank 4 (Not Recommended): Single (n+1)-Round Tau Game

**Effort**: 300-500 lines
**Risk**: HIGH (fundamental restructuring)

---

## 6. Analysis of the Cross-Boundary Ordering via Pivot Chains

The `pivot_chain_order'` tactic/lemma proves orderings between positions from different sub-games by chaining through a common pivot point. The pattern is:

```
a < d  and  d < b    (in N)
a' < c and  c < b'   (in M)
(a < d iff a' < c)   (from game 1)
(d < b iff c < b')   (from game 2)
------------------------------------
(a < b iff a' < b')  (by transitivity of the biconditionals)
```

For the specific case of a_init(k) vs p_n (and resp_tau(k) vs e_n):

| Fact | Source |
|------|--------|
| a_init(k) >= d | h_no_split (all positions >= d) |
| p_n >= d | h_no_split at position n |
| resp_tau(k) >= c | hresp_tau_in |
| e_n >= c | hc_le_en (derived from hord_cd_en_pn) |
| (d < a_init(k) iff c < resp_tau(k)) | tau_d_sel from hord_tau |
| (d < p_n iff c < e_n) | hord_cd_en_pn |

The pivot through d/c gives:
```
a_init(k) < p_n
  iff (a_init(k) > d and p_n > a_init(k))  -- need to decompose
```

Actually, the correct pivot chain for a_init(k) vs p_n uses:
- Chain: d <= a_init(k) <= p_n  and  c <= resp_tau(k) <= e_n
- From tau: (d < a_init(k) iff c < resp_tau(k))
- From cross-boundary: (d < p_n iff c < e_n)
- Need: (a_init(k) < p_n iff resp_tau(k) < e_n)

This is exactly `pivot_chain_order'` applied with:
- h1: d <= a_init(k), h2: d <= p_n
- h3: c <= resp_tau(k), h4: c <= e_n
- h5: (d < a_init(k) iff c < resp_tau(k))
- h6: (d < p_n iff c < e_n)

And it gives: (a_init(k) < p_n iff resp_tau(k) < e_n).

This chain works WITHOUT sig_x_d. The `sig_x_d` ordering is only needed for orderings involving x'/x vs other positions (e.g., x' < a_init(k) iff x < resp_tau(k)), which requires pivoting through x'/x -> d/c -> a_init/resp_tau.

**Summary**: For the cross-boundary orderings between tau positions and e_n/p_n, the pivot through d/c suffices (no sigma needed). Sigma is only needed for orderings involving x'/x.

Looking at the Case A proof (lines 1464-1473), the sel vs p_n orderings use exactly this pattern:
```lean
| (exact pivot_chain_order' (hd_le_sel ...) (le_trans (h_no_split ...) ...)
    (hc_le_rtau ...) he_n_in.1
    (tau_d_sel ...) fwd_x_b)
```

And for x' vs sel orderings (lines 1449-1452):
```lean
| exact pivot_chain_order' props.hx'd (hd_le_sel ...) props.hxc
    (hc_le_rtau ...) sig_x_d (tau_d_sel ...)
```

Here `sig_x_d` IS used for x' vs sel. So sigma IS needed for x'/x orderings in Case B as well.

---

## 7. Definitive Recommendation

**The blocker has a straightforward fix: instantiate sigma in Case B to derive sig_x_d.**

The proof of `same_order_type` in Case B requires the same boundary ordering (x' < d iff x < c) that Case A uses. Case A obtains it from `hord_sig` (the sigma game's ordering). Case B can obtain it the same way by instantiating `props.sigma` with dummy selections.

**Implementation steps**:

1. In CaseAnalysis.lean, Case B branch (after line 1649), add sigma instantiation
2. Extract `sig_x_d` from the sigma ordering
3. The rest follows Case A's proven pattern using `same_order_type_grid` + `pivot_chain_order'`

**The sigma/tau decomposition IS correct and matches GHR93.** The blocker is not structural -- it is a missing sigma instantiation in one code branch. No alternative proof structure is needed.

**Estimated effort**: 40-80 lines for Case B fix + 5-20 lines for the line 1569 sorry = 45-100 lines total.
