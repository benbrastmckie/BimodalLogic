# Infrastructure Inventory and sel-vs-p_n Fix Design

## 1. Current Infrastructure Inventory

### 1.1 SplitPointProps (SplitPoint.lean:44-111)

| Field | Type | Description | Line |
|-------|------|-------------|------|
| `hc_interval` | `inClosedInterval x y c` | c in [x,y] | 53 |
| `hd_interval` | `inClosedInterval x' y' d` | d in [x',y'] | 55 |
| `hd_le_an` | `d <= a_bwd(n)` | Split point below last pick | 60 |
| `hxc` | `x <= c` | Left containment | 62 |
| `hcy` | `c <= y` | Right containment | 64 |
| `hx'd` | `x' <= d` | Left containment (N) | 66 |
| `hdy'` | `d <= y'` | Right containment (N) | 68 |
| `h_pt_xc` | Point in [x,c] or degenerate | Point witness | 72-73 |
| `h_pt_cy` | Point in [c,y] or degenerate | Point witness | 77-78 |
| `hcd_form` | Formula agreement c/d | At rank r | 81-83 |
| `hcd_gp` | Gap/point correspondence c/d | IsPoint/IsGap iff | 86 |
| `sigma` | `ghr93_duplicator_wins N M ... x' d x c` | Left sub-interval backward strategy | 89 |
| `tau` | `ghr93_duplicator_wins N M ... d y' c y` | Right sub-interval backward strategy | 92 |
| `h_fwd_n1` | `ghr93_duplicator_wins M N ... (n+1) r x y x' y'` | Forward strategy (n+1 rounds) | 96 |
| `h_d_compat_left` | D-compatible (1+3n+1)-round forward | Ends with c -> d | 101-111 |

### 1.2 Key Definitions in CaseAnalysis.lean

- **`a_init`** (line 1198): `fun k => a_bwd ⟨k.val, ...⟩` -- first n elements of Spoiler's backward selections
- **`resp_tau`** (line 1204): Duplicator's tau-response to `a_init`, all in `[c, y]`
- **`p_n`** (line 1208): The carrier point such that `a_bwd(n) = extendPoint p_n`
- **`e_n`** (line 1244): `extendPoint e_n_pt`, the forward-game response to challenge with `p_n`, in `[x, y]`
- **`a_pad_big`** (line 1226): Padded selection for d-compatible game: `resp_tau(k)` for `k < n`, `c` at position `1+3n`
- **`a'_big`** (line 1240): N-side response from d-compatible game (NOT the same as `a_init`)

### 1.3 Available Ordering Lemmas

From the **tau game** (`hord_tau_aux` / `hord_tau`):
- `tau_d_sel : forall k, (d < a_init k <-> c < resp_tau k) /\ (d = a_init k <-> c = resp_tau k)`
- `tau_sel_y : forall k, (a_init k < y' <-> resp_tau k < y) /\ ...`
- `tau_sel_sel : forall k k', (a_init k < a_init k' <-> resp_tau k < resp_tau k') /\ ...`
- `tau_d_b, tau_b_y', tau_sel_b, tau_b_sel` (Case B only)

From the **d-compatible big game** (`hord_big`):
- `hord_cd_en_pn : (c < e_n <-> d < extendPoint p_n) /\ (c = e_n <-> d = extendPoint p_n)` -- **cross-boundary** d/c vs p_n/e_n
- `hord_fwd_x_en, hord_fwd_x_y, hord_fwd_en_y` -- x/x' vs e_n/p_n and y/y'

From **sigma game** (`hord_sig`, Case A only):
- `sig_x_b, sig_x_d, sig_b_d`

Interval bounds:
- `hd_le_sel : forall k, d <= a_init k`
- `hc_le_rtau : forall k, c <= resp_tau k`
- `hd_le_pn : d <= extendPoint p_n`
- `hc_le_en : c <= e_n`

### 1.4 `pivot_chain_order'` (EFGameTactics.lean:86-92)

```lean
theorem pivot_chain_order' {a p b : alpha} {a' q b' : beta}
    (hap : a <= p) (hpb : p <= b) (ha'q : a' <= q) (hqb' : q <= b')
    (hord_l : (a < p <-> a' < q) /\ (a = p <-> a' = q))
    (hord_r : (p < b <-> q < b') /\ (p = b <-> q = b')) :
    (a < b <-> a' < b') /\ (a = b <-> a' = b')
```

Requires a **chain** `a <= p <= b` (and `a' <= q <= b'`). Transfers ordering from two half-chains to the full chain.

### 1.5 `same_order_type_grid` (EFGameTactics.lean:202-203)

Macro that introduces index variables `i j`, unfolds `game_tuple`, and splits on all if-conditions. Produces ~16 goals (one per category pair from `{x, sel, b, y} x {x, sel, b, y}`).

## 2. The Blocker: Precise Analysis

### 2.1 What Goals Remain at the Sorry Sites

**Sorry site 1 (line 1594, Case A -- b_sp <= c):**
Multiple subgoals from the grid dispatch, the key ones being:

1. `(a_init k < extendPoint p_n <-> resp_tau k < e_n)` -- **sel vs p_n** (after `hab_eq` rewrite)
2. `(extendPoint p_n < a_init k <-> e_n < resp_tau k)` -- **p_n vs sel** (reverse)
3. `(y' < a_bwd ⟨j-1,...⟩ <-> y < resp_tau ⟨j-1,...⟩)` -- **y' vs sel** (Fin mismatch)
4. `(extendPoint b_resp < extendPoint p_n <-> extendPoint b_sp < e_n)` -- **b_resp vs p_n**

**Sorry site 2 (line 1866, Case B -- c < b_sp):**
Same pattern, additionally:

5. `(y' < extendPoint b_resp <-> y < extendPoint b_sp)` -- **y' vs b_resp**
6. `(extendPoint p_n < x' <-> e_n < x)` -- **p_n vs x'**
7. `(extendPoint p_n < extendPoint b_resp <-> e_n < extendPoint b_sp)` -- **p_n vs b_resp**

**Sorry site 3 (line 2837, Cases III-IV):**
Entire theorem body -- sorry'd pending Lemma 9 (gap detection). This is an independent blocker.

### 2.2 Why pivot_chain_order' Fails

The `pivot_chain_order'` lemma requires a CHAIN: `a <= p <= b`. For sel-vs-p_n goals, the configuration is:

```
  d <= a_init(k)    (from hd_le_sel)
  d <= p_n           (from hd_le_pn)
```

This is a FAN (V-shape), NOT a chain. Both `a_init(k)` and `p_n` are >= d, but their relative order is unknown. `pivot_chain_order'` cannot produce `(a_init(k) < p_n <-> resp_tau(k) < e_n)` from this fan.

**Counterexample proving a "common pivot" lemma is FALSE:**
Take alpha = beta = {0,1,2,3}. Set p=0, a=2, b=3 in alpha; q=0, a'=3, b'=2 in beta. All hypotheses of a putative common-pivot lemma hold, but `(a < b) = True` while `(a' < b') = False`.

### 2.3 What IS Available from hord_big

The d-compatible big game encodes `a_pad_big(k) = resp_tau(k)` on the M-side, with response `a'_big(k)` on the N-side. Extracting at positions `(1+k, b-position)`:

```
(resp_tau(k) < e_n <-> a'_big(k) < extendPoint p_n)
```

This is exactly what we need, EXCEPT `a'_big(k)` is NOT `a_init(k) = a_bwd(k)`. The gap: `a'_big` is the forward game's response to `a_pad_big`, while `a_init` is Spoiler's original backward selection. There is no a priori reason these are equal or even order-equivalent relative to `p_n`.

## 3. Three Fix Approaches

### Approach A: Extract sel_pn_ord Directly from hord_big

**Idea:** Instead of trying to derive `(a_init(k) < p_n <-> resp_tau(k) < e_n)` via pivot through d/c, extract the ordering `(resp_tau(k) < e_n <-> a'_big(k) < p_n)` from `hord_big`, then prove `a'_big(k)` and `a_init(k)` are order-equivalent relative to `p_n`.

**Why this works (or doesn't):**
From `hord_big` at `(0, 1+k)`: `(x < resp_tau(k) <-> x' < a'_big(k))` and `(x = resp_tau(k) <-> x' = a'_big(k))`.
From `hord_big` at `(0, 1+3n)`: `(x < c <-> x' < d)` (since `a_pad_big(1+3n) = c` and `a'_big(1+3n) = d`).
From `tau_d_sel`: `(d < a_init(k) <-> c < resp_tau(k))`.
From `hord_big` at `(1+3n, 1+k)`: `(c < resp_tau(k) <-> d < a'_big(k))`.

So: `(d < a_init(k) <-> c < resp_tau(k)) <-> (d < a'_big(k) <-> c < resp_tau(k))`.
This gives `d < a_init(k) <-> d < a'_big(k)` and similarly `d = a_init(k) <-> d = a'_big(k)`.

**But this is not enough!** Knowing two points have the same order relative to d does NOT determine their order relative to p_n (the counterexample above applies).

**Verdict: Approach A alone is INSUFFICIENT.**

**Estimated effort:** Would need a new auxiliary lemma relating `a'_big(k)` and `a_init(k)` more strongly (e.g., equal, or in the same interval). This likely requires new game-theoretic infrastructure.

### Approach B: Add sel_pn_ord as a New SplitPointProps Field

**Idea:** Add a new field to `SplitPointProps`:
```lean
  sel_pn_ord : forall (k : Fin n) (a_sel : Fin (n+1) -> ExtendedCarrier N atomMap r),
    (forall i, d <= a_sel i) ->
    (forall i, inClosedInterval x' y' (a_sel i)) ->
    a_sel (n, ...) = extendPoint p_n ->  -- need p_n parametrized
    ...
```

**Problem:** This requires knowing `p_n` at SplitPointProps construction time, but `p_n` is only defined inside `ghr93_case_II` (it comes from the hypothesis `h_point : IsPoint (a_bwd(n))`). The SplitPointProps structure is shared across Cases I, II, III, and IV. In Cases III-IV, `a_bwd(n)` is a GAP, not a point, so `p_n` doesn't exist.

**Revised approach:** Instead of a SplitPointProps field, add a standalone lemma that extracts the sel-vs-p_n ordering from the d-compatible game when given the full tau+big game data.

**Concrete design:**
```lean
/-- When both a_init(k) and extendPoint p_n are >= d on the N-side,
    and resp_tau(k) and e_n are >= c on the M-side,
    the ordering transfers via the d-compatible game. -/
theorem sel_pn_order_from_big_game
    (hord_big : same_order_type (1+3*n+1) (game_tuple x y a_pad_big e_n_pt) (game_tuple x' y' a'_big p_n))
    (tau_d_sel_k : (d < a_init k <-> c < resp_tau k) /\ (d = a_init k <-> c = resp_tau k))
    (hpad_k : a_pad_big (k, ...) = resp_tau k)
    ...
```

But the core issue remains: `a'_big(k)` is not `a_init(k)`, and no amount of indexing tricks changes that.

**Verdict: Adding a SplitPointProps field doesn't help because the data to populate it doesn't exist.**

### Approach C: Restructure the Big Game to Include a_init Selections

**Idea:** Instead of using `a_pad_big(k) = resp_tau(k)` (M-side selections), use `a_init(k)` on the N-side by playing the forward game differently. Specifically:

1. Build an N-side selection array containing `a_init(0), ..., a_init(n-1), p_n` (the original backward selections plus the last pick as a point).
2. Play the `h_fwd_n1` (n+1)-round forward game on `[x,y]/[x',y']` with these N-side selections.
3. Get M-side responses `resp_fwd(0), ..., resp_fwd(n)` where `resp_fwd(n) = e_n` (response to `p_n`).
4. Extract `(a_init(k) < p_n <-> resp_fwd(k) < e_n)` directly from the game's `same_order_type`.
5. Show `resp_fwd(k) = resp_tau(k)` (or at least order-equivalent) to connect back.

**Why this could work:** The `h_fwd_n1` field gives `ghr93_duplicator_wins M N atomMap (n+1) r x y x' y'`. We can play it with selections `a_init(0), ..., a_init(n-1), extendPoint p_n` (all are in `[x', y']`). Wait -- `h_fwd_n1` is a FORWARD game: M selects, N responds. The selections are M-side. We need N-side selections.

Alternatively, note that tau is `ghr93_duplicator_wins N M atomMap n r d y' c y`. This means Spoiler selects in [d,y'] (N-side), Duplicator responds in [c,y] (M-side). But the tau game only has n positions, not including p_n.

**Key insight:** We could use `h_d_compat_left` differently. Instead of padding with `resp_tau(k)` at positions `k < n`, we could include BOTH `resp_tau(k)` AND some proxy for `a_init(k)` in the padded array. But the array is already full at `1+3n+1` positions.

**Better approach: Use h_fwd_n1 with an (n+1)-selection that includes p_n.**

The `h_fwd_n1` field gives: `ghr93_duplicator_wins M N atomMap (n+1) r x y x' y'`.

This means: for any M-side selection of `n+1` points in `[x,y]`, Duplicator responds with N-side points in `[x',y']`, plus Spoiler challenges with an N-carrier-point and Duplicator responds.

But we need N-side Spoiler selections (which would be `a_init`). The game `h_fwd_n1` has M as Spoiler and N as Duplicator. We need the REVERSE direction.

Actually wait: `ghr93_duplicator_wins M N atomMap (n+1) r x y x' y'` means Spoiler selects in M and Duplicator wins in N. We need to derive orderings between N-side points. If Spoiler selects `resp_tau(k)` for `k < n` and `e_n` for position `n`, then Duplicator responds with N-side points. But we can't control what Duplicator responds with.

**Alternative: Construct a separate game that directly generates the ordering.**

Play `h_d_compat_left` with a modified padding that has `a_init(k)` at additional positions. But the d-compatible game already uses all `1+3n+1` positions.

**The real fix:** We need a NEW lemma, a "fan ordering" lemma that works for two points on the same side of a pivot. This requires additional game-theoretic input beyond what `pivot_chain_order` uses.

**Concrete proposed lemma:**

```lean
/-- Fan ordering: given a common lower bound d/c with order-compatible branches,
    derive the ordering between two branches. This works by extracting from a 
    game that includes BOTH branches as selections. -/
theorem fan_order_from_game
    {n : Nat}
    {a_sel : Fin n -> ExtendedCarrier N atomMap r}
    {resp : Fin n -> ExtendedCarrier M atomMap r}
    {p_n : N.carrier} {e_n : M.carrier}
    (hord_game : same_order_type (n+1) 
      (game_tuple ... (fun i => if i < n then resp i else extendPoint e_n) ...)
      (game_tuple ... (fun i => if i < n then a_sel i else extendPoint p_n) ...))
    (k : Fin n) :
    (a_sel k < extendPoint p_n <-> resp k < extendPoint e_n) /\
    (a_sel k = extendPoint p_n <-> resp k = extendPoint e_n)
```

This can be extracted DIRECTLY from the game's `same_order_type` at positions `(1+k, n+1)` (sel vs b-position) IF the game tuple is structured so that position `1+k` is `a_sel(k)`/`resp(k)` and position `n+1` is `extendPoint p_n`/`extendPoint e_n`.

**Wait -- this is exactly what `hord_big` at positions `(1+k, b-position)` gives... except the M-side at `1+k` is `resp_tau(k)` and the N-side at `1+k` is `a'_big(k)`, not `a_init(k)`.**

So Approach C requires: play a SECOND game where M-side selections include positions that correspond to `a_init` on the N-side. The `h_fwd_n1` game allows this IF we play it "backwards" -- select `resp_tau(k)` and `e_n` on M-side, challenge with a carrier point, and get N-side responses that are guaranteed to be order-compatible with the selections. But the N-side responses are NOT `a_init(k)`.

**True fix: Play the (n+1)-round forward game with a_init as input on the N-side.**

We need a game where N-side Spoiler selects `a_init(0), ..., a_init(n-1), extendPoint p_n`, i.e., where the a_init points appear as Spoiler selections. This requires a BACKWARD game direction: `ghr93_duplicator_wins N M atomMap (n+1) r x' y' x y`. But that's exactly the CONCLUSION we're trying to prove -- so it's circular.

**Alternatively:** Extract from `hord_big` at positions `(1+k, b-position)`, giving `(a_pad_big(k) < e_n <-> a'_big(k) < p_n)`. Since `a_pad_big(k) = resp_tau(k)`, this is `(resp_tau(k) < e_n <-> a'_big(k) < p_n)`.

Now we also need `(a_init(k) < p_n <-> a'_big(k) < p_n)`.

From `hord_big` at `(1+3n, 1+k)`: `(c < resp_tau(k) <-> d < a'_big(k))`.
From `tau_d_sel`: `(d < a_init(k) <-> c < resp_tau(k))`.
So: `(d < a_init(k) <-> d < a'_big(k))` and `(d = a_init(k) <-> d = a'_big(k))`.

This tells us `a_init(k)` and `a'_big(k)` are on the SAME side of d. But as shown in the counterexample (Section 2.2), same-side-of-d does NOT imply same-side-of-p_n.

**The additional constraint we could exploit:** Both `a_init(k)` and `a'_big(k)` are in `[d, y']`. And `p_n` is also in `[d, y']`. The game ordering gives FULL structure on the `a'_big` side but not on the `a_init` side relative to positions beyond d.

### RECOMMENDED: Approach D -- Extract Orderings from a Tau Game Played with e_n

**The key observation:** The sorry goals need `(a_init(k) < extendPoint p_n <-> resp_tau(k) < e_n)`. We have `hwin_tau` which is `ghr93_duplicator_wins N M atomMap n r d y' c y`. When we play tau with `b' = e_n_pt` (challenge with the carrier point `e_n_pt`), Duplicator responds with some `b_tau_en` in `[d, y']`, and the winning condition gives:

```
same_order_type n (game_tuple d y' a_init b_tau_en) (game_tuple c y resp_tau e_n_pt)
```

From this, extracting at `(1+k, n+1)` (sel vs b-position):
```
(a_init(k) < extendPoint b_tau_en <-> resp_tau(k) < e_n) /\
(a_init(k) = extendPoint b_tau_en <-> resp_tau(k) = e_n)
```

And from `(0, n+1)` (d/c vs b-position):
```
(d < extendPoint b_tau_en <-> c < e_n) /\ (d = extendPoint b_tau_en <-> c = e_n)
```

Combined with `hord_cd_en_pn: (c < e_n <-> d < p_n) /\ (c = e_n <-> d = p_n)`:
```
(d < extendPoint b_tau_en <-> d < extendPoint p_n) /\
(d = extendPoint b_tau_en <-> d = extendPoint p_n)
```

If the order is linear and both are in `[d, y']`, then `b_tau_en` and `p_n` have the same order relative to d. But as shown in Section 2.2, this still doesn't give `(a_init(k) < b_tau_en <-> a_init(k) < p_n)`.

HOWEVER: from `(sel vs b-position)` in both the tau-with-e_n game AND in `hord_cd_en_pn`, we get:

```
(a_init(k) < extendPoint b_tau_en <-> resp_tau(k) < e_n)  ... [from tau game with e_n]
```

This is EXACTLY the shape we need, just with `b_tau_en` instead of `p_n`. 

But our goal has `extendPoint p_n`, not `extendPoint b_tau_en`. We need to show that `b_tau_en = p_n` or at least that they have the same ordering relative to `a_init(k)`.

**Can we derive `b_tau_en` and `p_n` have same ordering w.r.t. a_init(k)?**

From tau game (with e_n as challenge): `(a_init(k) < b_tau_en <-> resp_tau(k) < e_n)`.
We want: `(a_init(k) < p_n <-> resp_tau(k) < e_n)`.
So we need: `(a_init(k) < b_tau_en <-> a_init(k) < p_n)`.

From tau game: `(d < b_tau_en <-> c < e_n)`, and `hord_cd_en_pn: (c < e_n <-> d < p_n)`.
So `(d < b_tau_en <-> d < p_n)` and `(d = b_tau_en <-> d = p_n)`.
Both are >= d. **Same counterexample issue.**

**Unless we can use the FULL game ordering.** From the tau game with e_n, we get `same_order_type n (game_tuple d y' a_init b_tau_en) (game_tuple c y resp_tau e_n_pt)`. From the d-compatible big game, we get `same_order_type (1+3n+1) (game_tuple x y a_pad_big e_n_pt) (game_tuple x' y' a'_big p_n)`.

Both games share the b-point `e_n_pt` / `p_n` on their respective sides, and selections `resp_tau(k)` / `a'_big(k)` (big game) and `a_init(k)` / `resp_tau(k)` (tau game).

The critical shared element is `resp_tau(k)` which appears as:
- M-side selection in the big game (at position `1+k`)
- M-side selection in the tau game (at position `1+k`)

From the big game at `(1+k, b-position)`: `(resp_tau(k) < e_n <-> a'_big(k) < p_n)`.
From the tau game (e_n) at `(1+k, b-position)`: `(a_init(k) < b_tau_en <-> resp_tau(k) < e_n)`.
Combining: `(a_init(k) < b_tau_en <-> a'_big(k) < p_n)`.

Still not `(a_init(k) < p_n)`.

**FINAL APPROACH: Use hord_big to extract a'_big(k) vs p_n, then show a'_big(k) ~ a_init(k) using the combined game data from tau+big.**

Wait, I realize there might be a simpler solution. Let me re-examine:

From the tau game played with e_n as challenge:
- `(d < b_tau_en <-> c < e_n)` and `(d = b_tau_en <-> c = e_n)` [pos 0 vs b-pos]
- `(a_init(k) < b_tau_en <-> resp_tau(k) < e_n)` and `(a_init(k) = b_tau_en <-> resp_tau(k) = e_n)` [pos 1+k vs b-pos]
- `(b_tau_en < y' <-> e_n < y)` and `(b_tau_en = y' <-> e_n = y)` [b-pos vs y-pos]

Now we can use `pivot_chain_order'` with the chain `a_init(k) ≤ ??? ≤ p_n`:
- We DON'T have `a_init(k) ≤ b_tau_en ≤ p_n` in general.

But we CAN use pivot through b_tau_en if `d ≤ a_init(k)` and `a_init(k) ≤ b_tau_en` and `b_tau_en ≤ p_n`:

Actually there is no guarantee of this ordering either.

**The approach that DOES work: use hord_big at (1+k, b-pos) combined with a substitution argument.**

From `hord_big` at `(1+k, b-pos)`:
`(resp_tau(k) < e_n <-> a'_big(k) < extendPoint p_n)` -- call this `(*)`.

Now we need to show `a'_big(k)` can be replaced by `a_init(k)`.

From `hord_big` at `(1+k, 1+k')` for sel-sel:
`(resp_tau(k) < resp_tau(k') <-> a'_big(k) < a'_big(k'))`.

From `tau_sel_sel`:
`(a_init(k) < a_init(k') <-> resp_tau(k) < resp_tau(k'))`.

So: `(a_init(k) < a_init(k') <-> a'_big(k) < a'_big(k'))` -- `a_init` and `a'_big` have the SAME internal ordering.

Also from `hord_big` at `(1+3n, 1+k)`: `(c < resp_tau(k) <-> d < a'_big(k))`.
From `tau_d_sel`: `(d < a_init(k) <-> c < resp_tau(k))`.
So: `(d < a_init(k) <-> d < a'_big(k))`.

**The combined facts show: the map `k -> a_init(k)` and `k -> a'_big(k)` are order-isomorphic in their relationship to d AND to each other. But they need not be equal or even have the same relationship to p_n.**

## 4. Recommended Fix: Approach D -- Instantiate Tau with e_n and Extract via Pivot

The cleanest fix that requires NO new SplitPointProps fields:

### Step 1: Play tau with e_n_pt as the challenge point

```lean
-- Already in context: hwin_tau can be called with any b' in [c, y]
-- e_n = extendPoint e_n_pt is in [c, y] (from hc_le_en and he_n_in.2)
-- But we need e_n_pt to be a carrier point in [c,y]:
have he_n_cy : inClosedInterval c y (extendPoint e_n_pt) :=
  ⟨hc_le_en, he_n_in.2⟩
obtain ⟨b_tau_en, hb_tau_en_in, hcond_tau_en⟩ := hwin_tau e_n_pt he_n_cy
obtain ⟨hord_tau_en, hgp_tau_en, hform_tau_en⟩ := hcond_tau_en
```

### Step 2: Extract orderings from tau-with-e_n game

```lean
have tau_sel_en : forall k : Fin n,
    (a_init k < extendPoint b_tau_en <-> resp_tau k < e_n) /\
    (a_init k = extendPoint b_tau_en <-> resp_tau k = e_n) := by
  intro k; have h := hord_tau_en ⟨1 + k.val, by omega⟩ ⟨n + 1, by omega⟩
  simp_game_tuple at h; exact h

have tau_d_en : (d < extendPoint b_tau_en <-> c < e_n) /\
    (d = extendPoint b_tau_en <-> c = e_n) := by
  have h := hord_tau_en ⟨0, by omega⟩ ⟨n + 1, by omega⟩
  simp_game_tuple at h; exact h
```

### Step 3: Use pivot_chain_order' through b_tau_en / e_n to get sel vs p_n

```lean
-- Key: d ≤ a_init(k), d ≤ b_tau_en (from hb_tau_en_in.1 and hd_le_sel)
-- and c ≤ resp_tau(k), c ≤ e_n
-- tau_d_sel gives left leg: (d < a_init(k) <-> c < resp_tau(k))
-- tau_d_en gives: (d < b_tau_en <-> c < e_n)
-- hord_cd_en_pn gives: (c < e_n <-> d < p_n)

-- From tau_d_en and hord_cd_en_pn:
-- (d < b_tau_en <-> d < p_n) and (d = b_tau_en <-> d = p_n)

-- THEN: pivot a_init(k) through b_tau_en to p_n:
-- Need: a_init(k) ≤ b_tau_en ≤ p_n OR b_tau_en ≤ a_init(k)
-- WE DON'T HAVE THIS.
```

**This approach also hits the fan problem.** The pivot needs a CHAIN, not a fan.

### The ACTUAL Working Fix

After thorough analysis, there are exactly two viable approaches:

#### Option 1: Extract from hord_big via index arithmetic (LOW effort, ~30 lines)

The `hord_big` game HAS the ordering we need, just at different N-side positions. The game tuple for the big game is:

- M-side: `game_tuple x y a_pad_big e_n_pt`
  - Position 0: x
  - Position 1+k (k < n): a_pad_big(k) = resp_tau(k)
  - Position 1+(1+3n): a_pad_big(1+3n) = c (if it lands here via index)
  - Position b: e_n
  - Position y: y

- N-side: `game_tuple x' y' a'_big p_n`
  - Position 0: x'
  - Position 1+k (k < n): a'_big(k)
  - Position 1+(1+3n): a'_big(1+3n) = d
  - Position b: extendPoint p_n
  - Position y: y'

Extract at `(1+k, b-position)` to get:
```
(resp_tau(k) < e_n <-> a'_big(k) < extendPoint p_n)
```

Then we ALSO need `(a'_big(k) < extendPoint p_n <-> a_init(k) < extendPoint p_n)`.

This second part is where ALL approaches fail because `a'_big(k)` and `a_init(k)` are fundamentally different game responses.

#### Option 2: Restructure the game construction (MEDIUM effort, ~100 lines)

**Change how `a_pad_big` and the d-compatible game are played so that `a'_big(k) = a_init(k)` by construction.** 

Currently: `a_pad_big(k) = resp_tau(k)` for `k < n`. Duplicator chooses `a'_big` freely.

New approach: Play the d-compatible game with a DIFFERENT selection. Use the (n+1)-round forward game `h_fwd_n1 : ghr93_duplicator_wins M N atomMap (n+1) r x y x' y'` instead. Play it with M-side selections that are the REVERSE of what we want:

Actually, the clean fix is to change `a_pad_big` so that `a'_big(k) = a_init(k)` is forced by the game. But the d-compatible forward game has M selecting, N responding -- we can't force the N-side response to equal `a_init(k)`.

#### Option 3: Add a NEW game play that directly gives sel_pn ordering (RECOMMENDED, ~60 lines)

Play the `h_fwd_n1` field of SplitPointProps with selections `resp_tau(0), ..., resp_tau(n-1), e_n` on the M-side. Get N-side responses `fwd_resp(0), ..., fwd_resp(n)` plus round-2 data. The same_order_type from this game gives, at `(1+k, n+1)`:

```
(resp_tau(k) < e_n <-> fwd_resp(k) < fwd_resp(n))
```

And `fwd_resp(n)` is Duplicator's response to `e_n`. If we challenge with `p_n` (N-carrier point), Spoiler gets back some `e_n'`:

Wait, this doesn't help either since `fwd_resp` are NEW N-side points.

#### THE CORRECT FIX: Dedicated `sel_en_ord` from Tau + Pivot Through e_n/b_tau_en

After much analysis, the issue reduces to this: we CANNOT derive `a_init(k) < p_n <-> resp_tau(k) < e_n` from existing infrastructure because both p_n and a_init(k) are on the SAME SIDE of the pivot d, and the "fan" lemma is false in general.

**The correct GHR93 argument** establishes this ordering through the GAME WINNING CONDITION itself: the full winning condition of the backward game (which is what we're constructing) guarantees this ordering as part of `same_order_type`. The issue is that we're trying to prove `same_order_type` component-by-component, and the sel-vs-p_n component cannot be assembled from the sub-games alone.

**Fix: Change the response construction.** Instead of using `resp_tau(k)` directly as the M-side response for a_init(k), and e_n as the M-side response for p_n, we should define:

```lean
let a'_resp : Fin (n+1) -> ExtendedCarrier M atomMap r := fun i =>
  if h : i.val < n then resp_tau ⟨i.val, h⟩ else e_n
```

And play a SINGLE game that includes ALL selections together. The `h_fwd_n1` game CAN be used for this if we reconstruct the proof differently.

**Specifically:** Instead of extracting `same_order_type` from tau and big separately, use a SINGLE game that gives `same_order_type` for the full `(n+1)` positions. This means playing `h_fwd_n1` with `a'_resp` as M-side selections and getting N-side responses that include both a_init-like and p_n-like points in one shot.

**Estimated lines: ~80-120 lines of refactoring in ghr93_case_II**

## 5. Summary and Recommendation

| Approach | Feasibility | Lines | Risk |
|----------|------------|-------|------|
| A: Extract from hord_big | INFEASIBLE | N/A | a'_big(k) != a_init(k) |
| B: New SplitPointProps field | INFEASIBLE | N/A | p_n unknown at construction time |
| C: Restructure big game | MEDIUM | ~100 | Requires careful game replay |
| D: Play tau with e_n + pivot | BLOCKED | N/A | Fan lemma is false |
| **E: Single unified game** | **RECOMMENDED** | **~80-120** | Moderate refactoring |

**Recommended approach (E):** Restructure `ghr93_case_II` to play a SINGLE forward game that produces ALL orderings in one `same_order_type`, rather than assembling orderings from separate tau, sigma, and big games. This avoids the fan problem entirely because the game's `same_order_type` inherently provides all pairwise orderings.

**Concretely:**
1. Use `h_fwd_n1` or a modified d-compatible game to play with selections that include BOTH the tau-like positions AND the p_n/e_n position.
2. Extract `same_order_type` from this single game.
3. The sel-vs-p_n ordering falls out as a grid cell from this unified game.

**Blockers for sorry site 3 (line 2837):** `ghr93_cases_III_IV` is independently blocked on Lemma 9 (gap detection) infrastructure. This is a separate work item.
