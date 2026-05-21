# D-Consistency Blocker: How GHR93 Actually Handles the Split Point

## Problem Analysis

### The Current Implementation

In `ExpressivenessGeneral.lean`, the function `obtain_split_point_props` (line 197) defines:
- `d := a_bwd(n)` -- Spoiler's last backward selection (line 217)
- `c` -- obtained from the forward strategy via a 1-round play (lines 226-496)
- `sigma` -- backward strategy on [x',d] from IH (line 417)
- `tau` -- backward strategy on [d,y'] from IH (line 418)

The `SplitPointProps` structure (line 137) includes `hd_eq_an : d = a_bwd(n)`, which is trivially `rfl` because `d` is literally defined as `a_bwd(n)`.

### The D-Consistency Sorries

At lines 298 and 308, two `sorry`s assert the d-consistency hypothesis required by `ghr93_strategy_restrict_left` and `ghr93_strategy_restrict_right`:

```lean
h_d_consistent_left : forall (a_pad : ...), a_pad(1+3*n) = c ->
  forall (a'_full : ...), (winning condition) -> a'_full(1+3*n) = d
```

This says: in ANY play of the forward strategy where the M-side puts `c` at position `n`, the N-side response at position `n` MUST equal `d`. But `d = a_bwd(n)` is a specific element from the backward game. The forward strategy is existentially quantified -- different plays yield different responses. There is no reason a particular play's response must equal a specific backward selection.

### Why This Is Genuinely Unprovable

The forward strategy `ghr93_duplicator_wins M N atomMap (4+3*n) r x y x' y'` says:

> For all M-selections a, THERE EXIST N-responses a' such that (winning condition).

The responses `a'` are chosen by the strategy and depend on the specific M-selections `a`. There is no mechanism forcing `a'(n) = a_bwd(n)` for an arbitrary backward selection `a_bwd(n)`.

## Literature Review

### GHR93 Theorem 6 Proof (Pages 27-31)

The paper defines `c` and `d` (which I will call `c_paper` and `d_paper` to distinguish from the Lean implementation) as follows:

**Temporal formulas A and C** (Page 27):
> Define the following rank r temporal formulas: [A = X_{(a_{n-1}, a_n)}] and C [holds on (a_n, y')]. Let
> - c = inf {t in [x,y] : M |= C(u) for all u in (t, y)}.

**Crucially**, `c_paper` is defined as an **infimum** -- specifically, the infimum of the set of elements `t` in `[x,y]` such that `C` holds on the entire interval `(t, y)`. This is a property of the **structure M** and the formula `C`, not a response from any particular game play.

**Then** (also Page 27):
> Define d in Nr similarly.

So `d_paper = inf {t in [x',y'] : N |= C(u) for all u in (t, y')}`. This is an infimum in the **N-side** structure.

### Claim 1 (Page 28)

> **Claim 1.** Consider a play of the game G_{m;r'}(M,xy; N,x'y') for arbitrary r' >= r, m >= 1 in which Duplicator uses a winning strategy. Let Spoiler begin by choosing c plus m-1 other points, and let Duplicator's response to c be d (plus m-1 other points). **Then d = d_paper.**
>
> **Proof of Claim.** As the strategy is winning, any rank r' temporal formula satisfied by one of Spoiler's choices must also be satisfied by the corresponding choice of Duplicator. Now the rank r+1 formula C' = not-C or K-*C satisfies M_r |= C'(c). Hence also N_r |= C'(d), so d <= d_paper. If d < d_paper then Spoiler can choose d' in (d, y') with N |= not-C(d'). Duplicator now has no winning response, a contradiction. Hence d = d_paper.

**Key insight**: The paper defines `c` and `d` as infima of formula-defined sets in the structures M and N respectively. Claim 1 then PROVES that any winning strategy's response to `c` must equal `d`. The d-consistency is not assumed -- it is a THEOREM derived from the infimum definition.

### How the Infimum Makes D-Consistency Provable

The argument is:

1. `c = inf {t : C holds on (t, y)}` in M.
2. `d_paper = inf {t : C holds on (t, y')}` in N.
3. The formula `C' = (not C) or K-*(C)` has rank r+1. `C'` holds at `c` (by definition of infimum: C holds on (c, y) but C fails or has a left boundary at c).
4. In any winning play where Spoiler plays c, Duplicator's response `resp` must satisfy the same formulas of rank r' >= r+1. So `N |= C'(resp)`, which forces `resp <= d_paper`.
5. If `resp < d_paper`, then there exists `d'` between `resp` and `d_paper` where `not-C` holds. Spoiler challenges at `d'`. No winning response exists (Spoiler would need a point in [x,y] where not-C holds in (c, y), but C holds everywhere in (c, y)). Contradiction.
6. Therefore `resp = d_paper`.

### The Lean Implementation's Error

The current implementation sets `d = a_bwd(n)` (Spoiler's backward selection), NOT as an infimum. This causes two problems:

1. **D-consistency is unprovable**: There is no reason the forward strategy's response to `c` must equal an arbitrary backward selection.
2. **The inequality `d <= a_n` is definitional only because `d = a_n`**: The paper's approach gives `d_paper <= a_n` as a consequence of the infimum definition (since `C` holds on `(a_n, y')` by construction, `a_n` is in the set, so `d_paper = inf(...) <= a_n`).

## Solution Design

### The Correct Approach: Define `d` as the Infimum

Replace `d = a_bwd(n)` with the GHR93 definition:

```
d = inf {t in ExtendedCarrier N atomMap r : C_mu holds on (t, y')}
```

where `C` is a rank-r formula defined from the backward selections (specifically, `C` captures the "continuation type" past `a_n`).

### Concrete Changes

#### 1. Define the formulas A and C (new infrastructure, ~50-80 lines)

The paper defines:
- `A = X_{(a_{n-1}, a_n)}` -- the rank-r type formula characterizing the interval `(a_{n-1}, a_n)`.
- `C` holds at `t` iff `A` holds everywhere on `(t, ?)` -- specifically, `C` encodes the continuation condition.

In Lean terms, `C` is the conjunction of all rank-r formulas that hold throughout `(a_n, y')` in N. This can be built from the `X_t` / rank-type infrastructure already in the codebase.

#### 2. Define `d` and `c` as infima (changes to `SplitPointProps`)

```lean
structure SplitPointProps ... where
  -- Replace hd_eq_an with:
  hd_le_an : d <= a_bwd(n)  -- d is the infimum, so d <= a_n
  hd_infimum : IsInfimum d {t | C_holds_on t y'}  -- d is the actual infimum
  -- ... rest unchanged
```

However, implementing a general infimum over `ExtendedCarrier` is significant infrastructure. There is a simpler approach.

#### 3. SIMPLER APPROACH: Define `d` from the Forward Strategy's Response

Instead of computing an explicit infimum, we can define `d` as the forward strategy's response to `c`, making d-consistency definitional.

**Method**:
1. Define `c` as before (from the infimum in M, or from the forward strategy -- either works).
2. Play the forward strategy with `c` as one of the selections. Let `d` be the response to `c`.
3. D-consistency is now `rfl` -- `d` IS the response.
4. Prove `d <= a_n` using the same argument as Claim 1: the winning condition forces formula agreement, and the formula `C` characterizes the infimum position, so the response must be <= a_n.

**Problem**: This approach still requires proving `d <= a_n` (for the case analysis) and that sigma/tau are valid (for the IH). The paper derives these from the infimum property.

#### 4. RECOMMENDED APPROACH: Infimum via Classical.choice

Define:
```lean
let S := {t : ExtendedCarrier N atomMap r | forall u, t < u -> u <= y' -> C_mu_holds u}
let d := if h : S.Nonempty then Classical.choice (infimum_exists h) else x'
```

This requires:
- Proof that `ExtendedCarrier` is a conditionally complete linear order (it inherits linear order from the sum type, but completeness needs verification).
- If `ExtendedCarrier` is NOT complete (which is likely since it includes gaps from arbitrary linear orders), the infimum may not exist in the carrier.

**GHR93's handling**: The paper notes (Page 28): "If c not in M then either c = x in M_r already, or c is a gap definable on the right by C. Hence c in M_r." This means `c` is guaranteed to be in `M_r` (the extended carrier at rank r), because if the infimum is not an actual point of M, it is a rank-r definable gap, which by definition is in `M_r`.

This means the infimum ALWAYS exists in `ExtendedCarrier`. The proof:
- The set S is nonempty (since y' is in S).
- The infimum either is a point of the carrier (hence in ExtendedCarrier), or is a gap. If it's a gap, it's definable by C on the right, so it's an r-definable gap, hence in M_r = ExtendedCarrier.

#### 5. PRAGMATIC HYBRID: Response-Based `d` with Manual Infimum Properties

The most practical solution combines approaches 3 and 4:

1. **Define `d` from the strategy response** (making d-consistency trivial).
2. **Prove `d` satisfies infimum-like properties** using Claim 1's argument:
   - `d <= a_n` (from formula agreement + C' characterization)
   - The forward strategy restricted to [x,c] yields responses in [x',d] (from Claim 2's argument)

This avoids building full infimum infrastructure while achieving the same result.

### Impact on Cases I and II

#### Case I (lines 623-969, sorry-free)

Case I uses `hd_eq_an` in exactly one place (line 653):
```lean
exact absurd (props.hd_eq_an ▸ le_refl _) (not_le.mpr hi_split)
```

This handles the `n = 0` subcase by contradiction: if `d = a_bwd(0)` and `a_bwd(0) < d`, that's impossible. With `hd_le_an : d <= a_bwd(n)` instead, this becomes: if `a_bwd(0) < d` and `d <= a_bwd(0)`, contradiction. **Same proof works**.

The `hR_nonempty` proof (line 663) uses:
```lean
exact not_lt.mpr (props.hd_eq_an ▸ le_refl _)
```

This shows `a_bwd(n)` is in R (i.e., `not (a_bwd(n) < d)`). With `hd_le_an`, this becomes `not_lt.mpr props.hd_le_an`. **Same proof works**.

**Case I impact: minimal. Replace `hd_eq_an ▸ le_refl _` with `hd_le_an` in 2 places.**

#### Case II (lines 1572-2357, sorry-free)

Case II uses `props.hd_eq_an` extensively. The W1 handoff reports ~30 locations. The key usage pattern is:

```lean
rw [props.hd_eq_an] at h_something
```

This rewrites `d` to `a_bwd(n)` to deduce that `d` is a point (when `a_bwd(n)` is known to be a point from the case hypothesis `h_pt : IsPoint (a_bwd(n))`).

With `hd_le_an` instead of `hd_eq_an`, we need to SEPARATELY prove that `d` is a point. But the paper's approach already ensures this: when `a_n` is a point and all selections are >= d, the fact that `d <= a_n` combined with the formula agreement means `d` satisfies the same "type" as `a_n`. In particular, if `a_n` is a point and `d = a_n` (which the paper proves), then `d` is a point.

**Critical question**: Does the paper's Claim 1 argument actually prove `d = a_n` when all selections are >= d?

Looking at the paper again: `d_paper <= a_n` because `C` holds on `(a_n, y')`. But `d_paper` could be strictly less than `a_n`. In Case II, the paper says "clearly d <= a_n" and then works with d as a separate point from a_n. The case split is NOT "d = a_n" -- it's "d < a_0" (Case I) vs "all a_i in (d, y')" (Cases II-IV). The paper never needs d = a_n.

**This means the current `hd_eq_an` is WRONG -- it's stronger than what the paper uses. The paper only needs `d <= a_n`.**

#### Case II Rewrite with `hd_le_an`

Case II's proof needs d to have the same "type" as the infimum. The paper's Case II argument never uses `d = a_n` -- it uses:
- `d <= a_n` (to ensure the split works)
- sigma, tau (from strategy restriction, which uses Claim 1)
- Formula C holds on (a_n, y'), which is how the sup/inf construction works

The ~30 locations in Case II that use `hd_eq_an` are likely using it to establish `IsPoint d` (from `IsPoint a_bwd(n)`). If we change to `hd_le_an`, we need a separate `hd_point_or_gap` field or we need to prove it from the infimum construction.

**Key realization**: If `d` is defined as an infimum, `d` could be a gap even when `a_n` is a point. This is fine -- the paper's Case II explicitly handles `a_n` being a point, and `d` is just the split point (which may be a gap). The case analysis is on `a_n`, not on `d`.

Looking more carefully at Case II in the paper (page 29):
> "Case II: All the points a_0,...,a_n lie in (d,y'), and a_n in N is not a gap."

So `a_n > d` (strictly), and `a_n` is a point. The proof constructs `B = X_{a_n}` and finds a matching point `e_n` in M such that `B` holds at `e_n`. It does NOT need `d = a_n` or `d` to be a point.

**The current Lean Case II implementation (lines 1572-2357) is built on the assumption `d = a_bwd(n)`. This assumption is not needed by the paper. But rewriting Case II to not use this assumption would require significant changes to ~30 locations.**

## Implementation Sketch

### Option A: Full Infimum (Correct but High Effort)

1. **Define `C` formula** from backward selections (30-50 lines)
2. **Prove infimum existence** in ExtendedCarrier for C-defined sets (100-150 lines)
3. **Define `d = inf S` and `c = inf S'`** (20 lines)
4. **Prove Claim 1** (50-100 lines)
5. **Update `SplitPointProps`**: replace `hd_eq_an` with `hd_le_an` (5 lines)
6. **Fix Case I**: 2-line change (replace `hd_eq_an` references with `hd_le_an`)
7. **Fix Case II**: Rewrite ~30 locations to not depend on `d = a_bwd(n)` (200-400 lines)
8. **Fix degenerate cases** in sub-interval point witnesses (may simplify since d is now an infimum with specific properties)

**Total estimate**: 400-700 lines of new/changed code. Significant risk of cascading breakage in Case II.

### Option B: Strategy-Response Definition (Simpler but Still Requires Claim 1 Argument)

1. **Play the forward strategy** with a specific selection including c to get d (30 lines)
2. **D-consistency is `rfl`** (0 lines -- eliminates 2 sorries)
3. **Prove `d <= a_n`** using Claim 1 argument (50-80 lines)
4. **Update `SplitPointProps`**: replace `hd_eq_an` with `hd_le_an` (5 lines)
5. **Fix Case I and Case II**: same as Option A (200-400 lines)

**Total estimate**: 280-510 lines. Still significant Case II rewrite.

### Option C: Deterministic Canonical Strategy (Eliminate the Problem)

Use `Classical.choice` to select a canonical (deterministic) forward strategy, then define `d` as this canonical strategy's response to `c`.

1. **Lift `ghr93_duplicator_wins` to a function** using `Classical.choice` (30 lines)
2. **Define `d := canonical_strategy.response(c)`** (10 lines)
3. **D-consistency is `rfl`** (0 lines)
4. **Prove properties of `d`** using the winning condition (50 lines)
5. **Update SplitPointProps**: change `hd_eq_an` to `hd_le_an` (5 lines)
6. **Fix Cases I and II**: same as Options A and B

**Total estimate**: 300-500 lines. Same Case II rewrite issue.

### Option D (RECOMMENDED): Infimum-Free Proof with d from Strategy + Preserve hd_eq_an

The key insight is that we can KEEP `d = a_bwd(n)` AND make d-consistency provable, by changing what the strategy restriction lemma requires.

**Current architecture**:
- `ghr93_strategy_restrict_left` requires: "For every play where M-side has c at position n, the N-side response at position n equals d."
- This is unprovable because d = a_bwd(n) has nothing to do with the forward strategy.

**New architecture**:
- Do NOT use `ghr93_strategy_restrict_left/right` with d-consistency.
- Instead, prove strategy restriction DIRECTLY from Claim 2's argument.

Claim 2 says: "Duplicator adds c to Spoiler's choices and applies the master strategy. By same_order_type, all responses to selections in [x,c] lie in [x',d_paper]. Hence the restricted strategy works on [x,c] vs [x',d_paper]."

If we set `d = a_bwd(n)`, we need to prove that the restriction maps [x,c] selections to [x',a_bwd(n)] responses. This is STILL unprovable because `a_bwd(n)` is arbitrary.

**Therefore, Option D does NOT work with d = a_bwd(n).**

### Option E (STRONGLY RECOMMENDED): Define d from Infimum, Add SplitPointProps Field for IsPoint

1. Define `d` as the infimum (or use Classical.choice on the forward strategy response).
2. Replace `hd_eq_an` with `hd_le_an : d <= a_bwd(n)`.
3. Add `hd_point : IsPoint d` to `SplitPointProps` ONLY for the Case II branch (or as a conditional field).
4. In Case II, use `hd_point` instead of deducing IsPoint from hd_eq_an.

But wait -- in Case II, the paper does NOT need d to be a point. Case II works when `a_n` is a point, regardless of what `d` is. The Lean implementation incorrectly fuses d and a_n.

**The real fix**: Separate the role of d (split point for strategy restriction) from a_n (Spoiler's last backward selection). They are different objects in the paper.

## Recommended Solution

### Step 1: Redefine d

Change `obtain_split_point_props` to define d NOT as `a_bwd(n)` but as the forward strategy's canonical response to c.

Specifically:
```lean
-- Play the forward strategy with c as the sole selection
have h1 : ghr93_duplicator_wins M N atomMap 1 r x y x' y' := round_mono ...
obtain <a'1, ha'1, hwin1> := h1 (fun _ => c) (fun _ => hc_interval)
-- d is the strategy's response to c
let d := a'1 (0)
```

Wait -- this gives `d` from a 1-round play where the ONLY selection is `c`. But `d` needs to be formula-compatible with `c` AND less than or equal to `a_n`. The 1-round play gives formula compatibility, but `d <= a_n` requires the Claim 1 argument with the specific formula C.

### Step 2: Use the Claim 1 argument

Actually, looking again at the GHR93 proof, the crucial insight is:

1. `c` is defined as `inf {t in [x,y] : C holds on (t,y)}` where C is a specific rank-r formula.
2. `d` is defined INDEPENDENTLY as `inf {t in [x',y'] : C holds on (t,y')}`.
3. Both c and d are determined by the formula C and the structures M, N -- they do NOT depend on any game play.
4. Claim 1 then shows that any winning strategy's response to c must equal d.

The essential point: **both c and d are defined before any game is played**. They are semantic properties of the structures, not game-theoretic quantities.

### Step 3: Concrete Implementation

The simplest correct implementation:

1. Define the formula `C` from the backward selections (C captures the "type" of the interval past a_n).
2. Define `c` as `sInf {t in [x,y]_r : C holds on (t, y)}` in M_r.
3. Define `d` as `sInf {t in [x',y']_r : C holds on (t, y')}` in N_r.
4. Prove `d <= a_n` (because a_n is in the set).
5. Prove Claim 1: any winning response to c equals d.
6. Derive d-consistency from Claim 1.
7. The rest of the proof proceeds as before.

**Infrastructure needed**:
- `sInf` / `cInf` for `ExtendedCarrier` (or a custom infimum)
- Proof that formula-defined sets have infima in ExtendedCarrier
- The formula C construction

### Step 4: Estimated Changes

| Component | Lines | Risk |
|-----------|-------|------|
| Formula C construction | 40-60 | Low |
| Infimum infrastructure for ExtendedCarrier | 80-120 | Medium |
| Claim 1 proof | 50-80 | Medium |
| SplitPointProps changes (hd_eq_an -> hd_le_an) | 5 | Low |
| Case I fixes (2 sites) | 10 | Low |
| Case II rewrites (remove IsPoint d assumption) | 100-200 | High |
| Degenerate case simplification | 30-50 | Medium |
| **Total** | **315-525** | **Medium-High** |

## Confidence Level

**Diagnosis confidence**: 95%. The GHR93 paper's definition of c and d as infima is unambiguous. The current Lean implementation's `d = a_bwd(n)` is a misreading of the paper that made d-consistency unprovable.

**Solution confidence**: 80%. The infimum-based approach is mathematically correct and matches the paper. The implementation risk is in the Case II rewrite (~30 locations) and the infimum infrastructure for ExtendedCarrier.

**Alternative viability**: The "strategy-response" approach (define d from a specific play) would work if combined with the Claim 1 formula argument to prove d <= a_n, but is less clean than the true infimum approach.

## Answers to Specific Questions

### a. In GHR93, is d defined as an infimum? If so, infimum of WHAT set exactly?

YES. Both c and d are defined as infima:
- `c = inf {t in [x,y] : M |= C(u) for all u in (t, y)}` (c is in M_r)
- `d = inf {t in [x',y'] : N |= C(u) for all u in (t, y')}` (d is in N_r)

Where C is a rank-r formula encoding the "continuation type" past a_n.

### b. Does GHR93 use a deterministic or non-deterministic strategy?

The strategy is non-deterministic (existential). But Claim 1 proves that ALL winning strategies agree on the response to c -- the response is always d. This is the whole point of defining d as an infimum: it forces determinism at the split point.

### c. How does GHR93 extract the sub-strategies sigma and tau from the forward strategy?

Via Claim 2: The forward strategy sigma for G_{4+3n;r'}(M,xy; N,x'y') is RESTRICTED to sub-intervals by adding c to Spoiler's choices. Since Claim 1 guarantees the response to c is always d, the restricted strategy maps [x,c] selections to [x',d] responses. This gives the sub-interval forward strategies, which the IH converts to backward strategies.

### d. Is there a way to define d in Lean so that d-consistency is definitional (rfl)?

YES, if we define d as the forward strategy's response to c (using Classical.choice to select a canonical strategy). D-consistency would be rfl. But we would still need to prove d <= a_n via the Claim 1 argument, so this doesn't eliminate all the work.

### e. Could we use Classical.choice to select a canonical strategy response and define d from it?

YES. This is Option C above. It works but still requires:
1. Proving the canonical response satisfies d <= a_n (Claim 1 argument)
2. Rewriting Case II to not assume d = a_bwd(n)

### f. What would need to change in Cases I and II if we redefine d?

**Case I**: 2 trivial changes (replace `hd_eq_an ▸ le_refl _` with `hd_le_an`). Case I is structurally sound.

**Case II**: ~30 locations need rewriting. The main pattern is `rw [props.hd_eq_an]` used to prove `IsPoint d` from `IsPoint a_bwd(n)`. With the infimum approach, d may be a gap even when a_n is a point (d <= a_n strictly). The paper's Case II handles this naturally because it never assumes d is a point -- it only assumes a_n is a point.
