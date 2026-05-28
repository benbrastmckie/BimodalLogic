# GHR93-Faithful Case II Rewrite: Research Report for Tasks 5.1-5.6

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Complete architectural analysis for rewriting ghr93_case_II to follow GHR93 exactly, replacing the current ~1107-line forward-game-based proof with a ~400-600 line U(B,A)-based proof.

---

## 1. Current CaseAnalysis.lean Architecture

### 1.1 File Overview

- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
- **Total lines**: 3625
- **Imports**: `SplitPoint`, `Composition`, `Mathlib.Data.Fin.Tuple.Sort` (line 1-3)
- **CharacteristicFormula.lean is NOT imported** -- must be added for Tasks 5.1-5.6
- **Only sorry**: Line 3477 (in Cases III/IV -- DO NOT TOUCH)

### 1.2 ghr93_case_II Signature (lines 1196-1232)

```lean
private theorem ghr93_case_II {sig : MonadicSignature}
    {atomMap : Formula -> sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) -> ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (hd : 2 <= delta)
    (ha_bwd : forall i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : forall i : Fin (n + 1), d <= a_bwd i)
    (h_point : IsPoint (a_bwd (Fin.mk n (by omega))))
    (ih : ...)  -- IH for sub-interval backward games
    (h_r1_univ : ...)  -- universal forward games at any rank
    (h_mono : Monotone a_bwd) :
    exists (a'_resp : Fin (n + 1) -> ExtendedCarrier M atomMap r), ...
```

Key parameters:
- `props : SplitPointProps` provides sigma, tau (at rank r+delta on rank-embedded positions), h_d_compat_left, h_fwd_n1, boundary data
- `hd : 2 <= delta` guarantees tau at rank r+delta has formula agreement at depth <= r+delta >= r+2
- `h_mono : Monotone a_bwd` gives sorted selections (a_bwd k <= a_bwd k' when k <= k')
- `h_point : IsPoint (a_bwd (n, ...))` means a_n is a carrier point p_n

### 1.3 Current Proof Structure (lines 1233-2302)

| Lines | Step | Description | GHR93-Faithful? |
|-------|------|-------------|-----------------|
| 1239-1247 | 1 | Extract p_n from h_point, define a_init | YES |
| 1248-1255 | 2 | Project sigma/tau to rank r via rank_down | YES |
| 1257-1288 | 3 | **Construct e_n via forward game h_d_compat_left** | **NO** |
| 1289-1345 | 4 | Extract formula/ordering/gap-point from big game | **NO** (artifact of step 3) |
| 1346-1357 | -- | Hoist p_cy existence, extract tau formula data | YES |
| 1358-1378 | 5 | Build tau_left and tau_right via IH | **Unnecessary** with GHR93 |
| 1380-1391 | -- | Pivot agreement between p_n and e_n | Depends on step 3 |
| 1392-1414 | 6 | Play tau_left with a_init, extract hord_left_sel_pn | **NO** (use tau_r directly) |
| 1415-1439 | 7 | resp_mod indirection (if a_init k = p_n then e_n else resp_left k) | **Artifact** |
| 1440-1449 | 8a | Build a'_resp : Fin (n+1) -> M | Partially reusable |
| 1450-2302 | 8b | Round 2 winning condition dispatch (Case A, B1, B2) | **Needs rewrite** |

### 1.4 The Forward-Game e_n Construction (DELETE target)

**Lines 1257-1288**: The current code constructs e_n by:
1. Building `a_pad_big : Fin (1 + 3*n + 1) -> ExtendedCarrier M atomMap r` from resp_tau values plus c at the last position
2. Playing `props.h_d_compat_left` with a_pad_big to get `a'_big` on the N side (with a'_big(last) = d)
3. Challenging the resulting forward game with p_n to get `e_n_pt`
4. Setting `e_n := extendPoint e_n_pt`

This is architecturally wrong per GHR93 (reports 40, 44-B, 44-C). GHR93 constructs e_n from the U(B,A) witness transferred through tau.

### 1.5 The resp_mod Indirection (DELETE target)

**Lines 1418-1428**: `resp_mod k = if a_init k = extendPoint p_n then e_n else resp_left k`

This exists because with the forward-game e_n, resp_left (from tau_left) might not equal e_n at positions where a_init(k) = p_n. With the GHR93 approach, resp_tau is used directly and this indirection is unnecessary.

### 1.6 Task 5.7 Additions (same_order_type_of_cases)

Task 5.7 added `same_order_type_of_cases` in EFGameTactics.lean (line 231) and used it at three sites:
- Line 1640: Case A grid dispatch
- Line 1986: Case B1 grid dispatch
- Line 2232: Case B2 grid dispatch

Each usage site constructs ~220 lines of prerequisite ordering lemmas (full_sel_sel, full_x_sel, full_b_sel, full_y_sel) via `by_cases hk : k.val < n` splits on whether an index refers to a_init element or to p_n/e_n.

**Impact of rewrite**: With the GHR93 approach, the ordering prerequisites become MUCH simpler because:
- resp_tau is used directly (no resp_mod indirection)
- sel_pn_ord is trivial (resp_tau(k) <= resp_tau(n-1) < z = e_n)
- The hord_left_sel_pn / tau_left machinery disappears entirely
- The same_order_type_of_cases helper REMAINS useful but its prerequisite construction shrinks dramatically

---

## 2. CharacteristicFormula.lean Infrastructure

### 2.1 Available Constructions (ALL sorry-free)

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (632 lines, zero sorries)

| Identifier | Type/Signature | Line |
|-----------|---------------|------|
| `x_t_formula M atomMap r t` | `StaviFormula` (noncomputable) | 371-374 |
| `x_t_depth` | `stavi_depth (x_t_formula M atomMap r t) <= r` | 377-381 |
| `x_t_correct u` | `stavi_temporal_truth_mu ... u (x_t_formula ... t) <-> rank_type ... u = rank_type ... t` | 384-390 |
| `x_t_self` | `stavi_temporal_truth_mu ... t (x_t_formula ... t)` | 393-397 |
| `x_t_implies_agreement` | Given X_t holds at u: `stavi_temporal_truth_mu ... u A <-> stavi_temporal_truth_mu ... t A` for depth A <= r | 401-408 |
| `x_interval_formula M atomMap r t u` | `StaviFormula` (noncomputable) | 497-500 |
| `x_interval_depth` | `stavi_depth (x_interval_formula ...) <= r` | 503-507 |
| `x_interval_correct w` | `stavi_temporal_truth_mu ... w (x_interval_formula ... t u) <-> exists v, mu_holds v /\ t < v /\ v < u /\ rank_type ... w = rank_type ... v` | 510-518 |
| `x_interval_self` | Given mu_holds v, t < v, v < u: `stavi_temporal_truth_mu ... v (x_interval_formula ... t u)` | 521-527 |
| `sf_untl B A` | `StaviFormula` (= .std_untl B A) | 532-533 |
| `sf_untl_depth B A` | `stavi_depth (sf_untl B A) = max (stavi_depth B) (stavi_depth A) + 2` | 536-538 |
| `sf_untl_truth_mu B A` | Until semantics: `exists s, t < s /\ mu_holds s /\ B(s) /\ forall w in (t,s), mu_holds w -> A(w)` | 556-564 |
| `untl_extract_witness h` | Extracts Until witness from proof h | 610-619 |
| `untl_type_holds_at_witness` | Given mu_holds t, s < t: `U(X_t, X_{(s,t)})(s)` | 581-589 |
| `untl_type_depth` | `stavi_depth(U(X_t, X_{(s,t)})) <= r + 2` | 592-597 |
| `untl_type_depth_le_r_plus_4` | `stavi_depth(U(X_t, X_{(s,t)})) <= r + 4` | 600-607 |
| `formula_transfer_rank_embed h t A` | `stavi_temporal_truth_mu ... r' (rank_embed h t) A <-> stavi_temporal_truth_mu ... r t A` | 624-630 |

### 2.2 Depth Budget Analysis

- `B = x_t_formula N atomMap r (a_bwd (n, ...))` -- depth <= r
- `A = x_interval_formula N atomMap r ref_point (a_bwd (n, ...))` where ref_point is a_{n-1} or d -- depth <= r
- `U(B, A) = sf_untl B A` -- depth = max(r, r) + 2 = r + 2
- tau is at rank r + delta (with delta >= 2 from hd), so formula agreement covers depth <= r + delta >= r + 2
- **CONCLUSION**: U(B,A) at depth r+2 is transferable through tau at rank r+delta when delta >= 2. The existing infrastructure SUFFICES.

### 2.3 Required Import

Add to line 1 of CaseAnalysis.lean:
```lean
import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula
```

---

## 3. Tau Transfer Mechanism

### 3.1 The Rank Chain

```
props.tau : ghr93_duplicator_wins N M atomMap n (r + delta)
    (rank_embed (r <= r+delta) d) (rank_embed (r <= r+delta) y')
    (rank_embed (r <= r+delta) c) (rank_embed (r <= r+delta) y)
```

This game plays at rank r+delta on rank-embedded positions. Its winning condition gives formula agreement at depth <= r+delta.

Currently the code does:
```lean
have tau_r := ghr93_duplicator_wins_rank_down ... props.tau  -- projects to rank r
```

This loses the formula depth budget. For the GHR93 approach, we need tau to preserve formulas at depth r+2 (for U(B,A)). Two approaches:

**Approach A (Recommended)**: Use `props.tau` directly at rank r+delta on rank-embedded positions. Apply it to `rank_embed (r <= r+delta)` of the a_init values. The formula agreement at depth r+delta covers U(B,A) at depth r+2 (since delta >= 2). Then use `rank_embed_stavi_truth_mu` to transfer back to rank r.

**Approach B**: Use tau_r (rank-r game) for the initial play (getting resp_tau), but SEPARATELY extract formula data from `props.tau` at rank r+delta for the U(B,A) transfer. This is more modular but requires two separate plays of tau.

### 3.2 Concrete Transfer Steps

Given: `props.tau` at rank r+delta gives resp_tau(k) in [c, y].

For U(B, A) transfer:
1. Build U(B, A) where B = x_t_formula N atomMap r (a_bwd (n, ...)), A = x_interval_formula N atomMap r ref_point (a_bwd (n, ...))
2. Show `stavi_temporal_truth_mu N atomMap r ref_point (sf_untl B A)` using `untl_type_holds_at_witness`
3. Since `stavi_depth (sf_untl B A) <= r + 2 <= r + delta`, this is within tau's formula budget
4. The winning condition of props.tau (or tau_r) gives: if `stavi_temporal_truth_mu N atomMap r ref_point (sf_untl B A)` then `stavi_temporal_truth_mu M atomMap r resp_tau_ref (sf_untl B A)`
5. Use `untl_extract_witness` to get z > resp_tau_ref with B(z) and A on (resp_tau_ref, z)
6. Set e_n := z

### 3.3 Extracting Formula Data from tau at r+delta

The key challenge: `props.tau` plays on rank_embed'd positions and gives formula agreement at depth <= r+delta. We need to:

1. Play `props.tau` with rank_embed'd a_init values
2. Extract formula agreement at the ref_point position
3. Use `rank_embed_stavi_truth_mu` to translate: truth at rank r+delta on rank_embed'd position <-> truth at rank r on original position
4. Since `stavi_depth(U(B,A)) <= r + 2 <= r + delta`, the formula is within budget

Concretely:
```lean
-- Play tau at full rank r+delta
let a_init_emb := fun k => rank_embed (by omega : r <= r + delta) (a_init k)
have ha_init_emb : forall k, inClosedInterval
    (rank_embed _ d) (rank_embed _ y') (a_init_emb k) := ...
obtain (resp_emb, hresp_emb_in, hwin_emb) := props.tau a_init_emb ha_init_emb

-- Extract formula at ref position
-- Need a carrier point to challenge; use p_cy or similar
obtain (b_emb, hb_emb_in, hcond_emb) := hwin_emb ...
obtain (_, _, hform_emb) := hcond_emb

-- Formula at ref_point index gives U(B,A) transfer
-- hform_emb at index for ref_point: truth at rank r+delta on rank_embed'd position
-- Use rank_embed_stavi_truth_mu to go back to rank r
```

However, this is somewhat complex. A simpler approach: use `ghr93_duplicator_wins_rank_down` which already provides formula agreement at depth <= r. But that only gives depth <= r, not r+2.

**Resolution**: We need a PARTIAL rank_down that keeps depth r+2 agreement. Looking at the code, `ghr93_duplicator_wins_rank_down` requires `r + 2 <= r'` and then gives a rank-r game with formula agreement at depth <= r. This is NOT sufficient.

**The correct approach**: Do NOT rank-down tau before playing it for the U(B,A) transfer. Instead:
1. Use `tau_r` (rank-r game, from rank_down) for the INITIAL play to get resp_tau ordering data
2. SEPARATELY use `props.tau` at full rank r+delta to extract the U(B,A) formula transfer

This means we play tau TWICE:
- Once at rank r (tau_r) for resp_tau and ordering
- Once at rank r+delta (props.tau) for formula transfer of U(B,A)

Alternatively, do everything at rank r+delta and use rank_embed_stavi_truth_mu at the end. This is cleaner.

### 3.4 The n=0 Boundary Case

When n=0:
- a_init is `Fin 0 -> ...` (empty)
- There is no a_{n-1}
- The reference point for U(B,A) should be d (GHR93: a_{n-1} = d-bar)
- resp_tau reference should be c
- U(B, A)(d) holds because a_n = p_n witnesses it: d < p_n (since d <= a_n = p_n, and we need strict inequality)

Wait -- what if d = p_n? Then n=0 means there's exactly one selection a_0 = a_bwd(0, ...) = p_n, and d <= a_0 from h_no_split. If d = a_0 = p_n, then U(B,A)(d) requires a witness z > d with B(z). But d = p_n and p_n is a carrier point, so U(B,A)(d) says: exists z > d, mu_holds z, B(z), forall w in (d,z), mu_holds w -> A(w). With d = p_n, z = p_n would need z > d = p_n, i.e., p_n > p_n, contradiction.

So when d = p_n and n=0, U(B,A)(d) fails. This means the n=0/d=p_n case must be handled separately.

Actually, let me re-read GHR93 more carefully. In GHR93, the reference point is a_{n-1} when n >= 1. When n=0, GHR93 uses d-bar (= x' side endpoint) as the reference. But actually, looking at the plan: "When n=0, take a_{n-1} = d_bar (= x') and e_{n-1} = c (= x side)."

So the reference point for n=0 is d (= x' side endpoint). And we need d < a_0 = p_n (strict). Since d <= p_n from h_no_split, and if d = p_n, then... let me check what happens.

If d = p_n with n=0: props.hd_le_an gives d <= a_bwd(0) = p_n. If d = p_n, then U(B,A)(d) needs a witness z > d = p_n. Since p_n is a point, there might be such a z if the interval [d, y'] is non-trivial. But U(B,A)(d) = U(B,A)(p_n) would need z > p_n with B(z) and A on (p_n, z). B = X_{p_n}, so B(z) means rank_type(z) = rank_type(p_n). This exists if the interval (p_n, y') contains a point with matching type.

Actually, GHR93 avoids this issue differently. When d = a_n, the "continuation set" is {a_n} itself, and the construction reduces to the case where Spoiler plays only at d. In GHR93 Case II, a_n is always in the continuation set (d <= a_n), and d is the inf. When d = a_n, all selections collapse to d = p_n.

In the Lean code, when d = a_bwd(n) and all a_bwd(i) = d (since d <= a_bwd(i) <= a_bwd(n) = d by monotonicity), then a'_resp should be all c (since c corresponds to d) and e_n should be c as well. The proof becomes trivial.

**Handling**: The GHR93 rewrite should handle the degenerate case d = p_n separately (a simple case split at the top), then proceed with the main construction assuming d < p_n (which gives U(B,A)(ref) a legitimate witness).

---

## 4. Deletion Map

### 4.1 Lines to Delete (within ghr93_case_II, lines 1196-2302)

| Lines | Identifier/Content | Reason |
|-------|-------------------|--------|
| 1257-1288 | `a_pad_big`, `ha_pad_big`, `hpad_last`, `h_d_compat_left` call, `e_n_pt`, `e_n` definition | Forward-game e_n construction -- replaced by U(B,A) witness |
| 1289-1321 | `hform_en_an`, `hord_cd_en_pn`, `hM_sel`, `hM_b`, `hN_sel`, `hN_b` | Forward-game extraction -- replaced by U(B,A) properties |
| 1322-1345 | `hord_fwd_x_en`, `hord_fwd_x_y`, `hord_fwd_en_y`, `hgp_fwd_x`, `hgp_fwd_y`, `hform_fwd_x`, `hform_fwd_y` | Forward-game orderings -- endpoint data still needed but obtained differently |
| 1346-1357 | p_cy hoisting, pre-extracted tau formula data | May be partially reusable |
| 1358-1378 | `tau_left`, `tau_right` via IH | Replaced: no sub-interval decomposition needed |
| 1380-1391 | `hpivot_form`, `hpivot_gp` | Replaced: pivot between p_n/e_n no longer needed |
| 1392-1414 | `h_ainit_le_pn`, `ha_init_sub`, `resp_left`, `hresp_left_in`, `hwin_left`, extraction of `hord_left`, `hord_left_sel_pn` | Replaced: tau_left play -- use tau_r directly |
| 1415-1439 | `resp_mod`, `hresp_mod_eq`, `hresp_mod_ne`, `hresp_mod_in`, `sel_pn_ord` | Artifact of forward-game approach -- ELIMINATED |
| 1440-1449 | `a'_resp` definition, `ha'_resp_in` | Kept but simplified (uses resp_tau directly, not resp_mod) |
| 1450-2302 | Entire Round 2 dispatch (Case A, Case B1, Case B2) | Rewritten with simpler structure |

### 4.2 Lines to Keep (within ghr93_case_II)

| Lines | Content | Why Keep |
|-------|---------|----------|
| 1196-1232 | Function signature | Unchanged |
| 1233-1247 | Step 1: extract p_n, define a_init | Unchanged |
| 1248-1255 | Step 2: tau_r via rank_down | Keep for resp_tau ordering |

### 4.3 Net Effect

- **Delete**: Lines 1257-2302 (~1045 lines)
- **Add**: ~350-500 lines of new GHR93-faithful code
- **Net**: ~-550 to -700 lines

---

## 5. Construction Map

### 5.1 New Code Structure (replacing lines 1257-2302)

```
Step 3-NEW: Construct B, A, prove U(B,A)(ref) in N     (~40 lines)
Step 4-NEW: Transfer U(B,A) through tau at r+delta       (~50 lines)
Step 5-NEW: Extract witness z = e_n, prove properties     (~30 lines)
Step 6-NEW: Build a'_resp and prove interval containment   (~20 lines)
Step 7-NEW: Endpoint data from forward game h_fwd_n1       (~60 lines)
Step 8-NEW: Round 2 winning condition dispatch              (~200-300 lines)
```

### 5.2 Step 3-NEW: Construct B, A, Prove U(B,A)(ref) (Task 5.1 + 5.2)

```lean
-- Reference point: a_{n-1} when n >= 1, d when n = 0
let ref_N : ExtendedCarrier N atomMap r :=
    if h : 0 < n then a_bwd ⟨n - 1, by omega⟩ else d

-- B = X_{a_n} (characteristic formula for the type of a_n = p_n)
let B := x_t_formula N atomMap r (a_bwd ⟨n, by omega⟩)
-- A = X_{(ref, a_n)} (interval type formula)
let A := x_interval_formula N atomMap r ref_N (a_bwd ⟨n, by omega⟩)

-- U(B, A) holds at ref_N in N
have h_untl_N : stavi_temporal_truth_mu N atomMap r ref_N (sf_untl B A) := by
    -- When n > 0: a_n witnesses U(B,A)(a_{n-1})
    -- When n = 0: a_0 = p_n witnesses U(B,A)(d)
    -- Requires ref_N < a_n (strict inequality)
    -- From h_mono: ref_N <= a_n. Need strict: ref_N < a_n.
    -- Handle degenerate case ref_N = a_n separately.
    exact untl_type_holds_at_witness (mu_holds_point p_n) h_ref_lt_an
```

**Key subtlety**: We need `ref_N < a_bwd(n, ...)` (strict). This holds when:
- n >= 1: ref_N = a_bwd(n-1) <= a_bwd(n) by h_mono. Strict if a_bwd(n-1) < a_bwd(n).
- n = 0: ref_N = d <= a_bwd(0) by h_no_split. Strict if d < a_bwd(0).

When ref_N = a_bwd(n), all selections equal p_n (degenerate case). Handle at top of proof.

### 5.3 Step 4-NEW: Transfer U(B,A) Through tau (Task 5.3)

Depth of U(B,A): stavi_depth(sf_untl B A) <= r + 2 (from untl_type_depth).
tau at rank r+delta has formula agreement at depth <= r+delta.
Since r + 2 <= r + delta (from hd : 2 <= delta), the transfer works.

```lean
-- Reference point on M side: resp_tau(n-1) when n >= 1, c when n = 0
let ref_M : ExtendedCarrier M atomMap r :=
    if h : 0 < n then resp_tau ⟨n - 1, by omega⟩ else c

-- Transfer: stavi_temporal_truth_mu M atomMap r ref_M (sf_untl B A)
-- This requires extracting formula data from tau at rank r+delta
-- Use props.tau directly (NOT tau_r which loses the depth budget)
have h_untl_M : stavi_temporal_truth_mu M atomMap r ref_M (sf_untl B A) := by
    -- Play props.tau at rank r+delta with rank-embedded a_init
    -- Extract formula agreement at the reference position
    -- Use rank_embed_stavi_truth_mu to translate back to rank r
    ...
```

### 5.4 Step 5-NEW: Extract Witness (Task 5.4)

```lean
-- Extract z > ref_M with B(z) and A on (ref_M, z)
obtain ⟨z, h_ref_lt_z, h_mu_z, h_B_z, h_A_interval⟩ :=
    untl_extract_witness h_untl_M

-- z is a carrier point (since mu_holds z = IsPoint z)
obtain ⟨e_n_pt, he_n_eq⟩ := h_mu_z
let e_n : ExtendedCarrier M atomMap r := z
-- Or: let e_n := extendPoint e_n_pt

-- Key properties:
-- 1. e_n = z is a point in M
-- 2. ref_M < e_n (from h_ref_lt_z)
-- 3. B(e_n) <-> rank_type(e_n) = rank_type(a_n) (from x_t_correct)
--    => e_n and a_n agree on all rank-r StaviFormulas
-- 4. A holds on (ref_M, e_n): every mu-point w in this interval
--    has rank_type matching some mu-point in (ref_N, a_n)

-- sel_pn_ord is TRIVIAL:
-- For all k < n: resp_tau(k) <= resp_tau(n-1) = ref_M < z = e_n
-- First inequality: h_mono on a_init gives monotone resp_tau from tau ordering
-- Second inequality: h_ref_lt_z from Until witness
have sel_pn_ord : forall (k : Fin n),
    resp_tau k < e_n := by
    intro k
    calc resp_tau k <= ref_M := ... -- from tau ordering + h_mono
    _ < e_n := h_ref_lt_z
```

### 5.5 Steps 6-7-NEW: Build a'_resp and Endpoint Data (partial Task 5.5)

```lean
-- Response: resp_tau(0), ..., resp_tau(n-1), e_n
let a'_resp : Fin (n + 1) -> ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩ else e_n

-- Endpoint data from forward game h_fwd_n1
-- Still need x/y vs x'/y' orderings, gp, and formula data
-- Use props.h_fwd_n1 with a'_resp to get this
obtain ⟨a'_fwd, ha'_fwd, hwin_fwd⟩ := props.h_fwd_n1 a'_resp ha'_resp_in
-- Challenge with any N-carrier point to extract endpoint data
...
```

### 5.6 Step 8-NEW: Round 2 Dispatch (Task 5.6)

The Round 2 dispatch splits on Spoiler's b_sp position. The GHR93-faithful version:

**Case A (b_sp <= c)**: Use sigma for Round 2 response. Same as current code but WITHOUT resp_mod. The sigma game gives b_resp in [x', d]. Gap/point and formula from sigma. Ordering through d/c pivot.

**Case B (b_sp > c)**: Further split:

**Case B-below (c < b_sp, b_sp in tau's range)**: For k < n with resp_tau(k) < b_sp <= resp_tau(k+1) or b_sp < resp_tau(0), use tau's winning condition directly. No resp_mod needed.

**Case B-interval (resp_tau(n-1) < b_sp < e_n = z)**: This is the KEY new case from GHR93. A holds at b_sp (from h_A_interval). By x_interval_correct, b_sp's rank type matches some mu-point v in (ref_N, a_n). Respond with v (or any carrier point with matching rank type in (a_{n-1}, a_n)).

Actually, looking more carefully at GHR93: the response in this case uses tau's Round 2 mechanism, not a direct construction. The Round 2 of tau gives a point b_resp in [d, y'] with formula agreement. The key insight is that ALL orderings between resp_tau elements and b_sp are determined by tau's winning condition.

**Practical implementation**: The simplest approach for Round 2 is:
1. Case A (b_sp <= c): use sigma, same as now
2. Case B (b_sp > c): use tau_r's Round 2 directly, then combine with e_n ordering data

For Case B, play tau_r (which has resp_tau from Round 1 already matched with a_init) and get b_resp from tau_r's Round 2. The ordering between tau selections and b_resp comes from tau's winning condition. The ordering between e_n and b_resp uses x_t_correct for formula agreement and interval bounds for ordering.

The current code's split into B1 (b_sp <= e_n) and B2 (b_sp > e_n) can be retained, but the ordering proofs become much simpler without resp_mod.

---

## 6. Dependency Impact

### 6.1 Downstream Code Changes

The only downstream consumer of ghr93_case_II is `ghr93_cases_II_III_IV` at line 3986:
```lean
exact ghr93_case_II props hd ha_bwd h_no_split h_pt ih h_r1_univ h_mono
```

**Since the SIGNATURE of ghr93_case_II does not change, no downstream code needs modification.**

### 6.2 Impact on Task 5.7 Work

The `same_order_type_of_cases` helper (EFGameTactics.lean line 231) remains valid and useful. The change is that the PREREQUISITES fed to it become simpler:
- `hord_sel_sel` no longer needs resp_mod case splits
- `hord_x_sel`, `hord_b_sel`, `hord_y_sel` no longer need the by_cases on k.val < n for the resp_mod/e_n split

The same_order_type_of_cases calls at lines 1640, 1986, 2232 will be REPLACED with new calls that have simpler prerequisite construction.

### 6.3 Cases III/IV (line 3477 sorry)

The Cases III/IV proof at lines 2328-3937 is UNAFFECTED by this rewrite. The sorry at line 3477 is in the Cases III/IV winning condition assembly, which is completely separate from Case II's e_n construction. **DO NOT TOUCH.**

---

## 7. Task-by-Task Implementation Spec

### Task 5.1: Import CharacteristicFormula.lean and Construct B, A

**Scope**: Add import; define B, A, ref_N within ghr93_case_II; handle n=0 boundary

**Steps**:
1. Add `import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` at line 1 (or after existing imports)
2. After step 1 (line 1247), add:
   - Define `ref_N` (a_bwd(n-1) when n > 0, d when n = 0)
   - Prove `h_ref_N_lt_an : ref_N < a_bwd(n, ...)` -- requires case analysis for degenerate case
   - Define `B := x_t_formula N atomMap r (a_bwd ⟨n, by omega⟩)`
   - Define `A := x_interval_formula N atomMap r ref_N (a_bwd ⟨n, by omega⟩)`
3. Handle degenerate case: if ref_N = a_bwd(n), all selections equal p_n. In this case, resp should be all c and e_n = c. Prove directly without U(B,A).

**Lines affected**: Insert after line 1247 (before current step 2)
**Estimated size**: 30-50 lines
**Dependencies**: None

### Task 5.2: Prove N_r |= U(B, A)(ref_N)

**Scope**: Show the Until formula holds at the reference point in N

**Steps**:
1. Apply `untl_type_holds_at_witness` with witness a_bwd(n, ...) = extendPoint p_n
2. Need: `mu_holds (a_bwd ⟨n, by omega⟩)` -- from h_point (a_n is a point, hence mu_holds)
3. Need: `ref_N < a_bwd ⟨n, by omega⟩` -- from h_ref_N_lt_an (Task 5.1)

**Concrete**:
```lean
have h_untl_N : stavi_temporal_truth_mu N atomMap r ref_N (sf_untl B A) := by
    rw [hp_n] at h_ref_N_lt_an ⊢
    exact untl_type_holds_at_witness (mu_holds_point p_n) h_ref_N_lt_an
```

**Lines affected**: Insert after Task 5.1 additions
**Estimated size**: 10-20 lines
**Dependencies**: Task 5.1

### Task 5.3: Transfer U(B, A) Through tau at Rank r+delta

**Scope**: Show M_r |= U(B, A)(ref_M) using tau's formula preservation

**Steps**:
1. Keep `tau_r` (line 1252-1254) for resp_tau and ordering
2. Play `tau_r` with `a_init` to get `resp_tau` (line 1255)
3. Define `ref_M` (resp_tau(n-1) when n > 0, c when n = 0)
4. Extract formula agreement from tau at rank r+delta:
   - Use `props.tau` with rank-embedded a_init values
   - Get formula agreement at the ref_N/ref_M positions at depth <= r+delta
   - Since stavi_depth(U(B,A)) <= r+2 <= r+delta, the transfer works
   - Use rank_embed_stavi_truth_mu to bridge between rank r and rank r+delta
5. Conclude: `stavi_temporal_truth_mu M atomMap r ref_M (sf_untl B A)`

**Technical detail**: Playing props.tau requires rank-embedded inputs:
```lean
let a_init_emb : Fin n -> ExtendedCarrier N atomMap (r + delta) :=
    fun k => rank_embed (by omega : r <= r + delta) (a_init k)
have ha_init_emb : forall k, inClosedInterval
    (rank_embed _ d) (rank_embed _ y') (a_init_emb k) := by
    intro k; exact (rank_embed_inClosedInterval _ d y' (a_init k)).mpr (ha_init k)
obtain ⟨resp_emb, hresp_emb_in, hwin_emb⟩ := props.tau a_init_emb ha_init_emb
```

Then challenge with a carrier point (from h_pt_cy) to extract formula data:
```lean
-- Need carrier point in rank-embedded [c, y]
obtain ⟨p_cy, hp_cy⟩ := ... -- from props.h_pt_cy
let p_cy_emb := rank_embed (by omega : r <= r + delta) (extendPoint p_cy)
-- But rank_embed of extendPoint is extendPoint again (by rank_embed_point)
obtain ⟨b_emb, hb_emb_in, hcond_emb⟩ := hwin_emb p_cy ...
obtain ⟨_, _, hform_emb⟩ := hcond_emb

-- Extract formula at reference position
-- The ref position in the game tuple is index (n-1)+1 = n when n>0, or index 0 when n=0 (d endpoint)
-- Formula at that index: stavi truth at rank r+delta on rank_embed'd positions
-- Apply rank_embed_stavi_truth_mu to go to rank r
```

**Lines affected**: After Task 5.2, replacing lines 1248-1255 partially
**Estimated size**: 40-60 lines
**Dependencies**: Task 5.2

### Task 5.4: Extract Witness z = e_n and Prove Properties

**Scope**: Extract e_n from Until witness, prove sel_pn_ord, interval properties

**Steps**:
1. Apply `untl_extract_witness` to `h_untl_M`
2. Get `z > ref_M`, `mu_holds z`, `B(z)`, `A on (ref_M, z)`
3. Set `e_n := z` (or `e_n := extendPoint e_n_pt` from mu_holds decomposition)
4. Prove `hform_en_an`: e_n and a_n agree on all rank-r StaviFormulas
   - From B(z) and x_t_correct: rank_type(z) = rank_type(a_n)
   - From rank_type_eq_iff: agreement on all depth-r formulas
5. Prove `sel_pn_ord`: forall k < n, resp_tau(k) < e_n
   - Chain: resp_tau(k) <= resp_tau(n-1) = ref_M < z = e_n
   - First: from tau ordering (h_mono on a_init implies resp_tau preserves order)
   - Second: from Until witness (z > ref_M)
6. Prove ordering between c/d and e_n: c <= ref_M < e_n, d <= ref_N < a_n
7. Prove `he_n_in : inClosedInterval x y e_n`
   - e_n = z is in M (from mu_holds), z > ref_M >= c >= x
   - z < y? Not guaranteed a priori. GHR93 assumes z can be chosen < b, which requires additional argument. In the Lean formalization, the Until witness just gives z > ref_M with no upper bound. We need z <= y for e_n to be in [x, y].

**CRITICAL ISSUE**: The Until witness z is unbounded above. GHR93 says "we can assume z < b" (where b is some upper bound). In the Lean formulation, the structure M has a carrier M.carrier and ExtendedCarrier includes gaps. The Until formula gives z anywhere in the structure, not necessarily in [x, y].

**Resolution**: The witness z from U(B,A)(ref_M) satisfies z > ref_M. Since ref_M is in [c, y] (as resp_tau is in [c, y] from tau_r), we have z > c. But z might exceed y. However, the mu-relativized truth `stavi_temporal_truth_mu` operates on the FULL extended carrier, not just [x, y]. So z can be ANY element of ExtendedCarrier M atomMap r with z > ref_M.

For the proof to work, we need e_n in [x, y]. If z > y, we can't use it directly. GHR93 resolves this by observing that the interval [ref_M, y] must contain a point with matching type (because the formulas involved are preserved by tau, which maps [d, y'] to [c, y]). This may require a more careful argument.

Actually, looking at the Until semantics: `exists s, t < s /\ mu_holds s /\ B(s) /\ ...`. The `s` is an element of `ExtendedCarrier M atomMap r`, which includes ALL points and gaps in the extended structure. There is no constraint that s is in [x, y].

**Alternative**: Instead of raw untl_extract_witness, we can use the fact that B = X_{a_n} holds at a_n in N. By tau's formula transfer, X_{a_n} truth transfers to M. But we need a POINT in M with matching type that is in [x, y].

This may require a more nuanced approach. Let me reconsider.

**Actually**: The key insight from GHR93 is that the Until witness can be chosen in (e_{n-1}, b) where b is any upper bound. GHR93's tau maps [d-bar, y'] to [c, b] (not [c, y]). The "b" in GHR93 is the y endpoint of the tau game. Since tau maps to [c, y], the Until witness z satisfies c < z (as z > ref_M >= c), and z is a carrier point of M. If z is in [c, y], we're done. If z > y, we need to find a different witness.

In practice, the Until semantics in the Lean formalization is: exists s in ExtendedCarrier such that ref_M < s, mu_holds s, B(s), etc. This s might not be in [c, y].

**Resolution path**: We may need to prove that there exists a z in (ref_M, y] with the required properties. This follows from the fact that U(B,A) is a TEMPORAL formula about the structure M, and the relevant interval is [c, y]. The tau game ensures that the formula content of [d, y'] is faithfully transferred to [c, y], so the Until witness must exist within [c, y].

More precisely: if U(B,A)(ref_M) holds, there is a FIRST witness z > ref_M. If z > y, then all the formulas in (ref_M, y] still hold the "A" condition, and there must be a witness at or before y for the "B" condition. This requires structural reasoning about dense/discrete orderings in the extended carrier.

**Practical approach for implementation**: The cleanest approach may be to use `props.h_fwd_n1` (the forward game) to establish that there exists a carrier point in [c, y] with the right type, rather than relying on U(B,A) witness being in range. This is actually what the CURRENT code does (it uses h_d_compat_left for e_n construction). But that's not GHR93-faithful.

**Alternative practical approach**: Extract the Until witness, then use interval containment. Since ref_M is in [c, y] and the Until witness z > ref_M, we need z <= y. This can potentially be derived from properties of the extended structure: if there's a carrier point z > ref_M with B(z), and y is an upper bound, then either z <= y (and we're done) or z > y, which means the interval (ref_M, y] has no B-points. But U(B,A)(ref_M) holding means there IS a B-point above ref_M. If the first one is above y, we need additional argument.

**RECOMMENDATION**: Handle this by first showing that a B-point exists in [c, y] (which is non-trivial and may require the forward game for verification), and then using the Until formula to get the interval type A data. This hybrid approach uses:
- Forward game (h_fwd_n1) for e_n existence and interval containment
- U(B,A) for formula agreement at e_n and interval type data for Round 2

This is a COMPROMISE between the current approach and pure GHR93. It retains the forward game for EXISTENCE (which is natural in Lean where we can't freely choose witnesses) while using U(B,A) for FORMULA PROPERTIES (which simplifies the ordering arguments enormously).

**Lines affected**: Replaces lines 1257-1439
**Estimated size**: 50-80 lines
**Dependencies**: Task 5.3

### Task 5.5: Delete Old e_n Construction and resp_mod

**Scope**: Remove the forward-game e_n construction, resp_mod indirection, tau_left, tau_right

**Steps**:
1. Delete lines 1257-1288 (a_pad_big, h_d_compat_left call)
2. Delete lines 1289-1345 (forward game extraction)
3. Delete lines 1346-1391 (tau_left, tau_right, pivot data)
4. Delete lines 1392-1439 (resp_left play, resp_mod, sel_pn_ord old proof)
5. Insert new code from Tasks 5.1-5.4

**Net deletion**: ~183 lines of pure deletion (minus new insertions from Tasks 5.1-5.4)
**Dependencies**: Tasks 5.1-5.4 must be ready as replacements

### Task 5.6: Implement Round 2 Winning Condition

**Scope**: Rewrite the Round 2 dispatch (lines 1450-2302) with simplified ordering

**Steps**:
1. Keep the Case A / Case B split
2. Case A (b_sp <= c): Use sigma, same structure but with `resp_tau` instead of `resp_mod`
3. Case B (b_sp > c): Split on b_sp vs e_n
   - B1 (b_sp <= e_n): Play tau_r's Round 2 with b_sp. All orderings from tau's winning condition + sel_pn_ord (trivial). No resp_mod case splits needed.
   - B2 (b_sp > e_n): Use forward game or tau_right for response. Orderings trivial because resp_tau(k) < e_n < b_sp.
4. For each sub-case, construct prerequisites for `same_order_type_of_cases`:
   - `hord_sel_sel`: from tau ordering (tau_r gives same_order_type on tau's game tuple)
   - `hord_x_sel`, `hord_b_sel`, `hord_y_sel`: via pivot_chain_order through d/c
   - No resp_mod case splits needed
5. Gap/point agreement: sel positions are simple (resp_tau(k) for k < n are from tau, e_n is from Until witness / point)
6. Formula agreement: sel positions from tau's formula agreement, e_n from B = X_{a_n} (x_t_implies_agreement)

**Key simplification over current code**:
- No resp_mod indirection: resp_tau is used directly
- sel_pn_ord is trivial: resp_tau(k) < e_n by construction
- No hord_left_sel_pn / tau_left extraction needed
- The `by_cases hk : k.val < n` splits in full_sel_sel are simpler:
  - k < n: use tau ordering
  - k = n: use sel_pn_ord (trivial) or order_refl
  - No heq_k / hne_k (resp_mod eq/ne) sub-splits

**Estimated size**: 200-300 lines (vs current ~850 lines for lines 1450-2302)
**Dependencies**: Tasks 5.1-5.5

---

## 8. Risk Analysis

### 8.1 Until Witness Containment (HIGHEST RISK)

**Risk**: The Until witness z from `untl_extract_witness` may not be in [x, y].

**Mitigation**: 
1. Use the forward game (h_fwd_n1 or h_d_compat_left) to establish existence of a type-matching point in [c, y], then separately show it satisfies the U(B,A) properties.
2. Alternatively, prove that the Until witness must be in [c, y] by structural argument (the mu-relativized truth of U(B,A) restricted to [c, y] still holds because tau maps [d, y'] to [c, y]).
3. Worst case: retain the forward-game e_n for EXISTENCE but use U(B,A) for FORMULA properties, getting the best of both approaches.

### 8.2 The n=0 Boundary Case (MEDIUM RISK)

**Risk**: When n=0, the reference point ref_N = d and the reference point ref_M = c. Need d < p_n (strict) for U(B,A)(d) to have a witness. When d = p_n, all selections collapse to d.

**Mitigation**: Handle the degenerate case d = a_bwd(n) at the top of the proof with a case split. When d = a_bwd(n), respond with all c and e_n = c (trivial proof).

### 8.3 resp_tau Ordering (LOW RISK)

**Risk**: Need resp_tau to be monotone (resp_tau(k) <= resp_tau(k+1)) for sel_pn_ord.

**Mitigation**: tau's same_order_type condition gives: a_init(k) < a_init(k') iff resp_tau(k) < resp_tau(k'). Since a_init is a sub-sequence of h_mono, a_init is monotone, hence resp_tau is monotone. Specifically, resp_tau(k) <= resp_tau(n-1) for all k < n.

### 8.4 rank_embed Complexity (LOW RISK)

**Risk**: Playing props.tau at rank r+delta requires rank-embedded positions and careful use of rank_embed_stavi_truth_mu.

**Mitigation**: This is well-tested in the codebase. The `formula_transfer_rank_embed` from CharacteristicFormula.lean provides the exact specialization needed. The `rank_embed_inClosedInterval` lemma handles interval containment transfer.

### 8.5 Does the GHR93 Rewrite Make Task 5.7 Unnecessary? (CLARIFICATION)

**No**. The `same_order_type_of_cases` helper from Task 5.7 remains useful. It handles the 16-cell grid dispatch which is present in ANY Case II proof (GHR93 or not). What changes is that the PREREQUISITES (the 7 ordering lemmas fed to same_order_type_of_cases) become much simpler to construct. Task 5.7's ~740 lines will be partially preserved (the helper theorem stays), but the ~660 lines of prerequisite construction per case will shrink dramatically (~100-150 lines per case).

---

## 9. Literature Proof Structure

**Source**: GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9/12, Case II

### Step Map

1. **Apply tau to a_0, ..., a_{n-1}** -> resp_tau(0), ..., resp_tau(n-1) in [c, b]
2. **Define B = X_{a_n}, A = X_{(a_{n-1}, a_n)}** (characteristic / interval formulas)
3. **Prove N_r |= U(B, A)(a_{n-1})**: a_n witnesses it
4. **Transfer U(B, A) through tau at rank r+4**: tau preserves depth r+2 <= r+4
5. **Extract witness z = e_n** from M_r |= U(B, A)(resp_tau(n-1))
6. **sel_pn_ord is trivial**: resp_tau(k) <= resp_tau(n-1) < z = e_n
7. **Round 2: 5-way case split** on Spoiler's challenge b_sp

### Dependencies
- Step 2 depends on Step 1 (needs a_{n-1} reference)
- Step 3 depends on Step 2 (uses B, A definitions)
- Step 4 depends on Steps 1 and 3 (needs resp_tau and N-side truth)
- Step 5 depends on Step 4 (extracts from M-side truth)
- Step 6 depends on Steps 1 and 5 (combines tau ordering with Until witness)
- Step 7 depends on all previous steps

### Formalization Challenges
- **Step 4**: Requires playing tau at full rank r+delta, not rank-r. Must manage rank_embed carefully.
- **Step 5**: Until witness may not be in [x, y]. Need containment argument.
- **Step 7**: Grid dispatch via same_order_type_of_cases. Prerequisite construction still non-trivial but much simpler than current code.
