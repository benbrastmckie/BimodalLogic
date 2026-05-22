# Research Report: Lean Infrastructure for h_d_unique Closure

**Task**: 155 (Reynolds Pipeline Activation)
**Focus**: Codebase infrastructure and online resources for closing h_d_unique sorries
**Session**: sess_1779485383_cbe939
**Date**: 2026-05-22

## 1. Exact Goal States

### Sorry at Line 1759 (t' <= d direction, sub-case d < t')

**Goal**: `False`

**Case name**: `neg.a.a.inr`

**Key hypotheses in scope**:
- `_hd_lt_t' : d < t'` -- the contradiction target
- `ht'_in_SC : t' in S_C` -- t' is in the continuation set
- `hd_le_t' : d <= t'` -- from hd_glb (d is GLB of S_C)
- `hs : s in S_C` -- an element of S_C
- `h_not_le : s < t'` -- s is strictly below t'
- `hd_glb : forall s in S_C, d <= s` -- d is lower bound
- `hd_is_inf : forall (e : ...), (forall s in S_C, e <= s) -> e <= d` -- d is GLB
- `ht'_form : forall A, stavi_depth A <= r -> (stavi_temporal_truth_mu N atomMap r t' A <-> stavi_temporal_truth_mu N atomMap r d A)` -- rank-r formula agreement
- `hcd_form : forall A, stavi_depth A <= r -> (stavi_temporal_truth_mu M atomMap r c A <-> stavi_temporal_truth_mu N atomMap r d A)` -- c-d formula agreement
- `h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 1) (rank_embed ... x) (rank_embed ... y) (rank_embed ... x') (rank_embed ... y')` -- rank-(r+1) forward strategy
- `h_mono_left_r1 : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) (r + 1) ...` -- reduced-round rank-(r+1) strategy

**Analysis**: We have `d < t'` and `t' in S_C`, so `d <= t'` from `hd_glb`. But we also assumed `d < t'`. The goal is False. The difficulty: `d` is the GLB of `S_C` and `t'` is in `S_C`, so `d <= t'`. The case `d < t'` means the GLB is strictly below a member. This is not inherently contradictory -- it just means d is not the minimum but a strict lower bound. The contradiction must come from ELSEWHERE: the rank-r formula agreement between d and t' combined with the infimum properties.

### Sorry at Line 1796 (d <= t' direction, sub-case u <= d)

**Goal**: `False`

**Case name**: `neg.a.inl`

**Key hypotheses in scope**:
- `h_not_le : t' < d` -- assumed for contradiction (trying to prove d <= t')
- `ht'_not_SC : t' not_in S_C` -- t' is below the infimum, so not in S_C
- `u : ExtendedCarrier N atomMap r` -- a failure witness
- `ht'u : t' < u` -- u is above t'
- `huy' : u < y'`
- `hmu_u : mu_holds u` -- u is a point
- `h_not_cont_u : not (cont_holds (a_bwd ...) y' u)` -- continuation fails at u
- `hu_le_d : u <= d` -- the failure witness is at or below d
- Same formula agreement and forward strategy hypotheses as above

**Analysis**: We have `t' < u <= d`, u is a mu-point where `cont_holds` fails. Since `d` is the infimum of `S_C` and `u <= d`, every element of `S_C` is >= d >= u. But `cont_holds` fails at `u`. The case `u > d` is handled (lines 1797-1804) by finding an element of S_C below u and using upward-closedness. The remaining case `u <= d` requires the GHR93 Claim 1 argument.

## 2. Infrastructure Inventory

### What Exists (Sorry-Free)

| Component | Location | Status |
|-----------|----------|--------|
| `cont_holds` | ExpressivenessGeneral.lean:129 | Defined, sorry-free |
| `continuation_set` | ExpressivenessGeneral.lean:143 | Defined, sorry-free |
| `continuation_set_nonempty` | ExpressivenessGeneral.lean:163 | Proved |
| `continuation_set_upward_closed` | ExpressivenessGeneral.lean:175 | Proved |
| `a_n_in_continuation_set` | ExpressivenessGeneral.lean:193 | Proved |
| `cont_holds_above_gap` | ExpressivenessGeneral.lean:425 | Proved |
| `cont_fails_below_gap` | ExpressivenessGeneral.lean:469 | Proved |
| `formula_failure_in_cut` | ExpressivenessGeneral.lean (search) | Proved |
| `pigeonhole_definable_formula` | ExpressivenessGeneral.lean:625 | Proved |
| `infimum_gap_r_definable` | ExpressivenessGeneral.lean:905 | Proved |
| `stavi_temporal_truth_mu` | EFGames.lean:823 | Defined |
| `rank_type` | EFGames.lean:900 | Defined |
| `rank_type_eq_iff` | EFGames.lean:918 | Proved |
| `rank_embed_stavi_truth_mu` | EFGames.lean:1050 | Proved |
| `stavi_depth` | EFGames.lean:185 | Defined |
| `stavi_depth_neg` | EFGames.lean:945 | Proved |
| `formula_agreement` | EFGames.lean:6855 | Defined |
| `ghr93_duplicator_wins` | EFGames.lean:6901 | Defined |
| `ghr93_winning_condition` | EFGames.lean:6878 | Defined |
| `ghr93_duplicator_wins_round_mono` | EFGames.lean:7044 | Proved |
| `stavi_table_mu_correct` | EFGames.lean:8354 | Proved |
| `IsGLB.unique` (Mathlib) | Mathlib.Order.Bounds.Basic | Available |

### What Is Missing

1. **No C' formula construction**: There is no function that constructs the "continuation formula" C' = neg(C) or K^-(neg(C)) as a single StaviFormula of depth <= r+1. The `cont_holds` predicate is a Prop-level universal quantification over ALL rank-r formulas, not a single formula.

2. **No bridge from `cont_holds` to a single StaviFormula**: `cont_holds` says "for all A with depth <= r, if A holds on (a_n, y'), then A holds at t." This is an infinite conjunction (for each such A), but since there are finitely many inequivalent formulas (NormalForm finiteness), it COULD be expressed as a finite conjunction. However, no such construction exists in the codebase.

3. **No "interval type formula" construction**: The `rank_type` is a SET of formulas, not a single conjunction formula. There is no `type_conjunction : Set StaviFormula -> StaviFormula` that creates the big conjunction and proves its depth is bounded.

4. **No K^-(X) combinator for StaviFormula**: The formula K^-(X) = neg(S(top, neg(X))) captures "X holds cofinally in the past." This would be `StaviFormula.neg (.std_snce top (.neg X))` where `top` is some tautology. No such combinator or its semantic lemma exists.

## 3. Mathematical Analysis of the Sorries

### Why Rank-r Formula Agreement Is Insufficient

Both sorries require deriving `False` from a situation where:
- `d` is the GLB of `S_C`
- `t'` has the same rank-r type as `d` (formula agreement at depth <= r)
- `t'` has the same gap/point status and boundary position as `d`

But rank-r formula agreement alone cannot distinguish d from t' -- by definition, they agree on all depth-r formulas. The GHR93 proof uses a RANK-(r+1) formula to separate them.

### The GHR93 Argument (Claim 1, pp. 28-29 / p.116)

The argument proceeds:

1. **Define C'**: Let X_{(a_n, y')} be the interval type -- the set of rank-r types realized by mu-points in (a_n, y'). The continuation predicate C captures: "for every type tau in X_{(a_n, y')}, the conjunction of tau holds at t." Since there are finitely many types in X_{(a_n, y')}, this IS expressible as a finite formula of depth <= r.

2. **Define the separation formula at rank r+1**: The key formula is:
   - C' = C or K^-(C) = C or neg(S(top, neg(C)))
   - Depth: C has depth <= r, so S(top, neg(C)) has depth <= r+2... wait, that exceeds r+1.

   Actually the GHR93 argument is more nuanced. Let me re-analyze:
   
   The separation uses the fact that the **rank-(r+1) game** (via `h_fwd_r1`) provides formula agreement at depth r+1, not just r. The formula `S(top, neg(D))` where D has depth <= r gives a formula of depth r+2 (since std_snce adds 2 to the max of its children). So S(top, neg(D)) has depth max(0, r) + 2 = r+2, which exceeds the r+1 budget.

   **Critical depth issue**: `stavi_depth (.std_snce A B) = max (stavi_depth A) (stavi_depth B) + 2`. If A = top (depth 0) and B = neg(D) (depth r), then depth = max(0, r) + 2 = r + 2. This EXCEEDS r+1.

   So the naive K^-(D) = neg(S(top, neg(D))) approach does NOT fit in depth r+1.

### Revised Analysis: What Depth Is Actually Available?

Looking at `h_fwd_r1`:
```
h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 1) ...
```

This gives formula agreement at depth <= r+1. But `std_snce` with a depth-r argument produces depth r+2. So we need a different approach.

**Key observation**: The GHR93 game depth is NOT the same as `stavi_depth`. Let me check what `game_depth` is.

Looking at EFGames.lean:
```lean
def stavi_depth : StaviFormula -> Nat
  | .std_snce A B => max (stavi_depth A) (stavi_depth B) + 2
```

The +2 for std_snce means depth-r formulas wrapped in Since give depth r+2, not r+1. This is a fundamental constraint.

### Alternative Approach: Direct Use of h_fwd_r1

Instead of constructing a C' formula, we can use `h_fwd_r1` directly:

**Strategy for Sorry 1 (line 1759, d < t'):**

We have d < t' and both in S_C (actually, we need to show t' being above d with the same rank-r type leads to contradiction). The key insight:

1. We have `h_fwd_r1` giving a (4+3n)-round rank-(r+1) forward strategy on the lifted interval
2. Via `rank_embed_stavi_truth_mu`, rank-(r+1) formula agreement at `rank_embed d` implies rank-r formula agreement at `d`
3. The rank-(r+1) extended carrier has MORE gaps (all r+1-definable gaps), potentially separating d and t'

But the challenge is: d and t' are elements of `ExtendedCarrier N atomMap r`. When lifted to `ExtendedCarrier N atomMap (r+1)` via `rank_embed`, they become the SAME elements (rank_embed is injective and order-preserving). So they still agree on rank-r formulas.

The question is whether there exists a rank-(r+1) formula that separates `rank_embed d` from `rank_embed t'` in `ExtendedCarrier N atomMap (r+1)`. The infimum property of d means:
- Above d (in the continuation set): cont_holds is satisfied
- Below d: cont_holds fails cofinally

If we could express "cont_holds fails somewhere between me and d" as a rank-(r+1) formula, we could separate d from t'. But this requires the formula infrastructure that is missing.

### Alternative Approach: Predicate-Level Argument

Instead of constructing an explicit formula, use the GAME directly:

1. Play `h_fwd_r1` with c as Spoiler's selection (lifted to rank r+1)
2. Duplicator responds with some d' in the rank-(r+1) extended carrier
3. d' agrees with rank_embed(c) on depth-(r+1) formulas
4. Project d' back to rank r. By `rank_embed_stavi_truth_mu`, d' projected agrees with c on depth-r formulas, hence with d on depth-r formulas
5. By the infimum properties, d' projected must equal d
6. But d' also agrees with rank_embed(c) on depth-(r+1) formulas, which means d agrees with c at depth r+1 as well

This still doesn't directly help, because we'd need to show t' != d using a depth-(r+1) formula.

## 4. Concrete Proof Approach: The "Two Infima" Strategy

After deep analysis, here is the most viable approach:

### Core Idea

The proof does NOT need to construct an explicit C' formula. Instead, it can use a **purely predicate-level argument** based on the characterization of the infimum:

**For Sorry 1 (d < t', need False):**

The hypotheses give us:
- `d` is the GLB of `S_C` (infimum)
- `d < t'` (strict)
- `t'` is in `S_C` (from upward-closedness)
- `ht'_form` gives rank-r agreement between t' and d

But wait -- we already have `ht'_in_SC : t' in S_C` and `hd_le_t' : d <= t'`. The sub-case is `_hd_lt_t' : d < t'`. So we need to show d < t' leads to False given that t' has the SAME rank-r type as d.

The key question: is there actually a contradiction here from JUST rank-r agreement + infimum? The answer is NO, not without additional structure. Two distinct elements CAN have the same rank-r type and one be strictly above the infimum. The GHR93 argument requires rank-(r+1) information.

### The True GHR93 Approach

Re-reading the GHR93 proof more carefully, the argument for Claim 1 (uniqueness of d-bar) uses the game at the SAME rank r, not rank r+1. The key insight is:

**GHR93 Claim 1**: Let d-bar = inf(S_C). Suppose t' in [x', y'] has the same rank-r type as d-bar, same gap/point status, same boundary positions. Then t' = d-bar.

**Proof** (GHR93): Suppose t' != d-bar. WLOG t' > d-bar (the other direction is symmetric).

Then d-bar < t'. Since d-bar = inf(S_C), there exists s in S_C with d-bar <= s. Since S_C is upward-closed and t' has the same rank-r type as d-bar, if t' were in S_C, we'd have d-bar <= t' (which we already know). The contradiction comes from the fact that d-bar being the INFIMUM means for any e > d-bar, there exists s in S_C with s < e. BUT S_C is upward-closed in [x', y'], so if s in S_C and s < t', then t' in S_C (since x' < t' < y').

Wait, that's exactly what we have. Let me re-read the actual code structure:

Looking at lines 1733-1759 again:
```
apply le_antisymm
  -- Goal: t' <= d
  apply hd_is_inf
  intro s hs
  by_contra h_not_le
  push_neg at h_not_le
  -- h_not_le : s < t'
  -- By upward-closedness, t' in S_C
  have ht'_in_SC : t' in S_C := continuation_set_upward_closed hs ...
  have hd_le_t' : d <= t' := hd_glb t' ht'_in_SC
  rcases eq_or_lt_of_le hd_le_t' with hd_eq_t' | _hd_lt_t'
    -- d = t': s < t' = d contradicts d <= s (DONE)
    -- d < t': THIS IS THE SORRY
```

So the proof is trying to show `t' <= d` by showing t' is a lower bound of S_C (then by hd_is_inf, the greatest lower bound d >= t'). It assumes for contradiction that some s in S_C has s < t'. Then t' in S_C (upward-closed). Then d <= t'. If d = t', contradiction. If d < t', we need a contradiction.

**The fundamental issue**: When d < t', we have both d and t' in the interval, t' in S_C, same rank-r type. The infimum d is strictly below t', so there COULD be elements of S_C between d and t'. The question is whether d itself can fail to be in S_C while having the same rank-r type as t' which IS in S_C.

**Answer**: YES, d can fail to be in S_C. The continuation set membership requires the TAIL CONDITION: all mu-points in (d, y') satisfy cont_holds. But d might be strictly below some element where cont_holds fails. Having the same rank-r type as an element IN S_C does not automatically put d in S_C, because S_C membership depends on the tail, not on d's own formula type.

So the contradiction MUST come from the rank-(r+1) strategy. The argument is:

1. If d < t', then there exists a mu-point u with d < u < t' where cont_holds fails (because d is the infimum of S_C and t' is in S_C, the interval (d, t') contains points below the infimum's reach)
2. Actually no, that's backwards. If d = inf(S_C) and t' in S_C, then ALL elements of S_C are >= d. The interval (d, t') might not contain any elements of S_C.

Let me reconsider. The issue is more subtle. We need:

**Approach**: Show that d itself is in S_C, contradicting d being a strict lower bound.

**Claim**: If t' in S_C and t' has the same rank-r type as d, and d < t', then d in S_C.

**Proof attempt**: d in S_C requires: d in [x', y'] (have this) AND for all mu-points u with d < u < y', cont_holds a_n y' u.

Take any such u with d < u < y'. If u >= t', then since t' in S_C and t' < u < y' and u is a mu-point, cont_holds holds at u by definition of S_C membership.

If d < u < t', this is the hard case. We need cont_holds at u. cont_holds says: for all A with depth <= r, if A holds at all mu-points in (a_n, y'), then A holds at u.

Since t' in S_C, cont_holds holds at all mu-points in (t', y'). But u < t', so u is NOT in (t', y'). We cannot directly use t's S_C membership for u.

This confirms: **rank-r information alone is insufficient**. The GHR93 argument genuinely needs rank-(r+1) information from `h_fwd_r1` to close this.

## 5. Recommended Architecture for the Fix

### Option A: The "Rank-(r+1) Game Play" Strategy

Use `h_fwd_r1` (or `h_mono_left_r1`) to play the forward game at rank r+1. The argument:

1. Lift d and t' to rank r+1 via `rank_embed`
2. Play the rank-(r+1) forward game with `rank_embed c` as Spoiler's challenge
3. Duplicator responds with some element d'' in the rank-(r+1) extended carrier
4. d'' agrees with `rank_embed c` on depth-(r+1) formulas
5. Project d'' back: show d'' must agree with d at depth r (via `rank_embed_stavi_truth_mu`)
6. The rank-(r+1) carrier has ADDITIONAL gaps. Some of these gaps separate d from t'
7. The depth-(r+1) formula agreement forces d'' = rank_embed(d), which gives the needed constraint

**Challenge**: Step 6-7 requires showing that the infimum gap (at rank r) becomes DEFINABLE at rank r+1, and the defining formula separates d from t'. The `infimum_gap_r_definable` theorem gives a formula D of depth <= r. This D, combined with Since/Until at depth r+2, exceeds the r+1 budget.

### Option B: The "Finite Type Conjunction" Strategy

This approach constructs the continuation predicate as a single formula:

1. By NormalForm finiteness, there are finitely many rank-r types
2. `interval_types M atomMap r a_n y'` is finite (subset of finite set of types)
3. For each type tau in the interval, construct the conjunction of all formulas in tau
4. The overall continuation formula C = big-AND over all tau of (big-AND of tau) is a CONJUNCTION of depth-r formulas
5. Conjunction preserves depth: `stavi_depth (.conj A B) = max (stavi_depth A) (stavi_depth B)`
6. So C has depth <= r (not r+1!)

**Critical insight**: If C has depth <= r, then C is in the scope of `ht'_form` (rank-r agreement), so C(t') <-> C(d). This means d satisfies C iff t' does, which means d is in S_C iff t' is. Since t' IS in S_C, d would be too, contradicting d < t' with d = inf(S_C).

Wait -- this would mean the sorry is actually provable WITHOUT rank-(r+1) at all! Let me verify:

The continuation predicate is:
```
cont_holds a_n y' t = forall A, stavi_depth A <= r ->
  (forall v, a_n < v -> v < y' -> mu_holds v -> stavi_temporal_truth_mu N atomMap r v A) ->
  stavi_temporal_truth_mu N atomMap r t A
```

This is: for each A with depth <= r, if A holds throughout (a_n, y'), then A holds at t.

If we let C_A = "A holds at t" for each A that holds throughout (a_n, y'), then cont_holds is the conjunction of all such C_A. Each C_A is just "A holds at t," which is captured by A itself (since A has depth <= r).

So cont_holds at t <=> for each A in Gamma, stavi_temporal_truth_mu N atomMap r t A, where Gamma = {A : stavi_depth A <= r, A holds at all mu-points in (a_n, y')}.

If t' and d agree on ALL depth-r formulas (which `ht'_form` gives), then for each A in Gamma:
  stavi_temporal_truth_mu N atomMap r t' A <-> stavi_temporal_truth_mu N atomMap r d A

So cont_holds at t' <-> cont_holds at d.

**BUT**: S_C membership is NOT just cont_holds at the point. It's:
```
t in S_C <=> t in [x', y'] AND forall u, t < u -> u < y' -> mu_holds u -> cont_holds a_n y' u
```

The tail condition quantifies over mu-points ABOVE t. Even if d and t' agree on rank-r formulas at their own positions, the tail conditions are different because they quantify over different sets of mu-points (the interval (d, y') vs (t', y') when d < t').

Specifically: (d, y') is STRICTLY LARGER than (t', y') since d < t'. So showing cont_holds holds on (d, y') requires showing it on (d, t') as well, which is NOT implied by t' being in S_C.

### Option C: The "Cont_holds Transfer via Game" Strategy (RECOMMENDED)

This approach avoids formula construction entirely and works at the predicate level with the game:

**For Sorry 1 (d < t'):**

We need to derive False from: d < t', d = inf(S_C), t' in S_C, rank-r agreement between t' and d.

**Key lemma needed**: If d = inf(S_C) and d < t' and t' in S_C, and d and t' agree on all depth-r formulas, then d in S_C.

**Proof of key lemma**:
1. d in [x', y'] (have this as hd_interval)
2. Need: for all u with d < u < y' and mu_holds u, cont_holds a_n y' u
3. Take such u. If u >= t', then u in (t', y') (since t' in S_C, cont_holds holds at u). Done.
4. If d < u < t': u is a mu-point in (d, t'). We need cont_holds a_n y' u.
   - cont_holds a_n y' u = for all A with depth <= r, if A holds on all mu-points in (a_n, y'), then A(u)
   - Take such A. A holds on all mu-points in (a_n, y').
   - Since t' in S_C and u < t' < y' and d < u, and d < t':
     - Actually, t' in S_C means cont_holds at all mu-points in (t', y'), not (d, y')
     - u is in (d, t'), NOT in (t', y'), so t' in S_C doesn't directly help
   - HOWEVER: a_n in S_C (proved as `h_an_in_SC`), and d <= a_n. So a_n >= d.
     - If u < a_n: u is in (d, a_n). Since A holds on all mu-points in (a_n, y'), and u < a_n, the hypothesis about A doesn't tell us about u directly.
     - Actually, cont_holds at u says: if A holds on ALL mu-points in (a_n, y'), then A(u). But u might be BELOW a_n (if d < u < a_n). The interval (a_n, y') doesn't include u.
     - So we can't conclude A(u) from "A holds on (a_n, y')."

   This approach fails for the case d < u < a_n. The predicate `cont_holds a_n y' u` talks about formulas that hold on `(a_n, y')`, but u might be below a_n.

**This confirms that a pure predicate-level argument at rank r is insufficient.**

## 6. Definitive Assessment and Recommendation

### The Core Blocker

Both sorries require the GHR93 Claim 1 argument, which fundamentally needs rank-(r+1) information. The specific infrastructure gap is:

1. **No mechanism to express the infimum's characterizing property as a formula of bounded depth**. The infimum's position is characterized by the continuation set, which involves quantification over all rank-r formulas. While each formula has depth <= r, the conjunction of ALL such formulas (capturing the full continuation predicate) is at depth r. The K^- (cofinal Since) operator adds depth 2, exceeding the r+1 budget.

2. **No mechanism to convert game-theoretic information (h_fwd_r1) into a pointwise formula separation**. The game provides formula agreement for depth <= r+1 formulas, but we need to FIND a depth-(r+1) formula that separates d from t'.

### What Needs to Be Built

**Approach 1: Finite conjunction of interval types (depth <= r)**

Since there are finitely many rank-r types realized in any interval (by NormalForm finiteness), the continuation predicate restricted to REALIZED types can be expressed as a finite conjunction of depth-r formulas. The depth of a conjunction is the max of its children's depths (NOT additive), so the big conjunction has depth <= r.

**Required infrastructure**:
- `realized_types_finite : Fintype (interval_types N atomMap r a_n y')` -- finiteness of realized types
- `type_conjunction : Finset StaviFormula -> StaviFormula` -- big conjunction
- `type_conjunction_depth : stavi_depth (type_conjunction S) <= r` -- depth bound
- `type_conjunction_semantics` -- big conjunction is true iff all conjuncts are true
- `cont_holds_iff_type_conjunction` -- the bridge: cont_holds <=> big conjunction holds

**Approach 2: Use pigeonhole formula D directly (already exists!)**

The `pigeonhole_definable_formula` already extracts a SINGLE formula D of depth <= r that characterizes the gap. The `infimum_gap_r_definable` theorem uses this D.

For the h_d_unique argument, the key fact is:
- Above the gap: D holds at all carrier points (cont_holds_above_gap)
- Below the gap: D fails cofinally (pigeonhole)

If d is a gap (the common case in the interior), then D from `infimum_gap_r_definable` has depth <= r. Since d and t' agree on depth-r formulas:
- If d is on one side of the gap and t' is on the other, D separates them

But d IS the gap (the infimum). And t' > d means t' is above the gap. D holds above the gap. If d < t' and D has depth <= r:
- D holds at t' (above gap) -- but what about at d? d is the gap itself, not a carrier point.
- `stavi_temporal_truth_mu` evaluates at ExtendedCarrier elements including gaps.
- For gaps, the evaluation goes through the mu-relativized semantics.

**Key insight**: When d is a gap, `stavi_temporal_truth_mu` at d evaluates through the FO table interpretation. The formula D (from gap definability) has different truth values above vs below the gap, but at the GAP ITSELF, the truth depends on the FO semantics.

This approach requires understanding how `stavi_temporal_truth_mu` evaluates at a gap element.

### Recommended Next Step

**Build the finite type conjunction infrastructure** (Approach 1 from above). This is the cleanest path because:

1. The NormalForm finiteness machinery already exists
2. Conjunction of StaviFormulas already exists (`.conj`)
3. The depth of a conjunction is max (not sum), so depth stays <= r
4. Once cont_holds is equivalent to a single depth-r formula, the argument follows from `ht'_form` (rank-r agreement)

However, as analyzed in Section 5 Option C, cont_holds at t iff cont_holds at d is NOT sufficient because S_C membership depends on the TAIL condition, not just cont_holds at the point itself.

**Therefore, the correct approach requires proving the full GHR93 Claim 1, which involves**:
1. Playing the rank-(r+1) game via h_fwd_r1
2. Extracting a response to challenge point c
3. Showing the response must equal d (using uniqueness from the game structure)
4. Transferring properties from c back to d and t'

This is a substantial proof engineering effort requiring approximately 150-250 lines of new Lean code, primarily involving game plays and formula agreement transfers.

## 7. Relevant Mathlib Lemmas

| Lemma | Type | Use |
|-------|------|-----|
| `IsGLB.unique` | `IsGLB s a -> IsGLB s b -> a = b` | Infimum uniqueness (if we can establish a second GLB) |
| `le_antisymm` | `a <= b -> b <= a -> a = b` | Already used at line 1732 |
| `not_le.mpr` | `a < b -> not (b <= a)` | Used at line 1747 |
| `lt_irrefl` | `not (a < a)` | Standard |
| `lt_of_le_of_lt` | `a <= b -> b < c -> a < c` | Standard |
| `sInf_eq_of_forall_ge_of_forall_gt_exists_lt` | Conditionally complete lattice infimum characterization | Not directly applicable (ExtendedCarrier is not a ConditionallyCompleteLattice instance) |

## 8. Summary of Findings

1. **Both sorries (lines 1759 and 1796) require the GHR93 Claim 1 argument** which uses rank-(r+1) information from `h_fwd_r1`.

2. **Rank-r formula agreement alone is provably insufficient** because S_C membership depends on the tail condition (quantifying over intervals above the point), and different points have different tails even with the same rank-r type.

3. **The depth arithmetic is tight**: `std_snce` adds +2 to depth, so wrapping a depth-r formula in Since gives depth r+2, exceeding the r+1 budget from `h_fwd_r1`.

4. **The `infimum_gap_r_definable` infrastructure exists** and provides a formula D of depth <= r that characterizes the gap. This D, combined with the existing `rank_embed_stavi_truth_mu` theorem, could potentially be used at rank r+1 to bridge the gap.

5. **The most viable approach** is to build the GHR93 Claim 1 proof as a standalone lemma that takes `h_fwd_r1`, the infimum properties, and the formula agreement, and produces `t' = d`. This lemma would be approximately 150-250 lines and would play the rank-(r+1) game to extract the needed information.

6. **No existing EF game formalization in Lean or Coq** was found in Mathlib or via online search that handles this specific predicate-to-formula bridge.
