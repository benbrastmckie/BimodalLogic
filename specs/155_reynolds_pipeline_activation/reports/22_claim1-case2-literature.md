# GHR93 Claim 1 and Case II: Literature Extraction with Lean Identifier Mapping

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: Extract exact proof steps from GHR93 Section 8 for Claim 1 (d-consistency) and Case II (point case), with Lean identifier mappings for implementation guidance.

---

## Section 1: Verbatim Extraction of Claim 1

### Source

Gabbay, Hodkinson, Reynolds (1993), "Temporal Expressive Completeness in the Presence of Gaps," Section 8, pages 115--117. The claim appears on page 116 of the paper (page 28 of the markdown: lines 1386--1402 of `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md`).

### Setup (p.115--116)

The inductive step proves (\*)_{n+1}: fix r < omega. Assume Duplicator has a winning strategy for G_{4+3n; r+4(n+1)}(M, xy; N, x'y'). We must construct a winning strategy for G_{n+1; r}(N, x'y'; M, xy).

Spoiler (in the backward game) chooses n+1 points x' < alpha_0 < ... < alpha_n < y' in N_r.

The proof defines:

```
A = X_{(alpha_{n-1}, alpha_n)}     [rank r formula; interval type of (alpha_{n-1}, alpha_n) in N]
C = X_{(alpha_n, y')}              [rank r formula; interval type of (alpha_n, y') in N]
c = inf { t in [x, y] : M |= C(u) for all u in (t, y) }   [infimum in M]
d-bar = inf { t in [x', y'] : N |= C(u) for all u in (t, y') }  [infimum in N, written "c'" in GHR94]
```

If c is not a point of M, then either c = x (already in M_r) or c is a gap definable on the right by C (hence in M_r). Similarly for d-bar.

When n = 0, we take alpha_{n-1} = x' in the definition of A.

### Claim 1 (Verbatim, p.116)

> **Claim 1.** Consider a play of the game G_{m; r'}(M, xy; N, x'y') for arbitrary r' > r, m >= 1 in which Duplicator uses a winning strategy. Let Spoiler begin by choosing c plus m-1 other points, and let Duplicator's response to c be d (plus m-1 other points). Then d = d-bar.

### Proof of Claim (Verbatim, p.116)

> As the strategy is winning, any rank r' temporal formula satisfied by one of Spoiler's choices must also be satisfied by the corresponding choice of Duplicator. Now the rank r+1 formula C' = not-C or K^{-}(not-C) satisfies M_r |= C'(c). Hence also N_r |= C'(d), so d <= d-bar. If d < d-bar then Spoiler can choose d' in (d-bar, y') with N |= not-C(d'). Duplicator now has no winning response, a contradiction. Hence d = d-bar. This proves the claim.

### Key Formula

```
C' = not-C  or  K^{-}(not-C)
```

where K^{-}(X) abbreviates not-S(T, not-X), meaning "X holds cofinally in the past." The rank of C' is r+1, since C has rank r and K^{-} adds one level of temporal connective nesting.

---

## Section 2: Step-by-Step Proof of Claim 1, Annotated with Lean Mappings

### Step 2.0: Prerequisites and Definitions

**GHR93 Notation -> Lean Identifier Mapping:**

| GHR93 | Lean | Description |
|-------|------|-------------|
| M, N (temporal structures) | `M N : OrderedMonadicStructure sig` | The two structures in the game |
| M_r, N_r (extended carriers) | `ExtendedCarrier M atomMap r`, `ExtendedCarrier N atomMap r` | Extended carrier at rank r |
| G_{n;r}(M,xy;N,x'y') | `ghr93_duplicator_wins M N atomMap n r x y x' y'` | Duplicator wins n-round game at rank r |
| Winning condition | `ghr93_winning_condition` | Same order type, gap/point, formula agreement |
| X_t (type of point t) | Part of `ghr93_winning_condition` via `stavi_temporal_truth_mu` | Conjunction of rank-r formulas true at t |
| C (continuation formula) | `cont_holds a_n y'` | Predicate-level (not materialized as formula) |
| S_C (continuation set) | `continuation_set x' y' a_n` | Set of t where cont_holds holds on (t, y') |
| c (infimum in M) | `c : ExtendedCarrier M atomMap r` in `SplitPointProps` | `hc_interval : inClosedInterval x y c` |
| d-bar (infimum in N) | `d : ExtendedCarrier N atomMap r` in `SplitPointProps` | `hd_interval : inClosedInterval x' y' d` |
| mu-points | `mu_holds t` (i.e., `IsPoint t`) | Actual carrier points (not gaps) |
| K^{-}(X) | Not yet materialized in Lean | `not-S(T, not-X)` at the Stavi formula level |
| C' = not-C or K^{-}(not-C) | Not yet materialized | Rank r+1 formula |
| h_fwd (forward strategy) | `h_fwd : ghr93_duplicator_wins M N atomMap (n+1) r x y x' y'` | Forward game at rank r |
| h_fwd_r1 (rank r+1 fwd) | `h_fwd_r1 : ghr93_duplicator_wins M N atomMap (n+1) (r+1) ...` | Forward game at rank r+1 |

### Step 2.1: C' holds at c (M-side infimum property)

**Claim**: M_r |= C'(c), where C' = not-C or K^{-}(not-C).

**Proof**: By definition, c = inf(S_C) where S_C = {t in [x,y] : C holds on (t,y) in M}. There are two cases:

1. **c is not in S_C** (c is strictly below all elements of S_C, or is a boundary gap). Then there exist points arbitrarily close above c where C fails. In particular, not-C holds cofinally above c in the direction of c (i.e., in (c-epsilon, c)... actually, not-C(c) holds directly since C is the continuation predicate and c is not in S_C). So the first disjunct "not-C(c)" holds, giving C'(c).

2. **c is in S_C** (c achieves the infimum). Then C holds on (c, y). But by the infimum property, for every t < c, t is not in S_C, so there exist mu-points in (t, y) where C fails. Since these failure points can be found arbitrarily close below c (taking t arbitrarily close to c from below), the formula not-C holds cofinally in the past of c. Hence K^{-}(not-C)(c) holds, giving C'(c).

**Lean mapping**: This corresponds to the existing infrastructure:
- Case 1 maps to `cont_fails_below_gap` (line 468): when `p` is in the infimum cut, there exist mu-points above p where `cont_holds` fails.
- Case 2 is handled by `cont_holds_above_gap` (line 424) for the forward direction, but the K^{-} argument requires showing that *below* the infimum, cont_holds fails cofinally.

**Key insight**: The Lean code encodes C as a predicate (`cont_holds`) rather than a materialized formula. To use the rank-(r+1) forward game, we need C' to be a *formula* of rank r+1, not just a Prop. The existing `cont_holds_above_gap` and `cont_fails_below_gap` provide the semantic content but do not construct C' as a `StaviFormula`. This is the main gap between the predicate-level encoding and the formula-level encoding.

**Implementation options**:
- **Option A (formula materialization)**: Construct C' as a `StaviFormula` of depth r+1, prove it semantically equals the predicate version, then use it with h_fwd_r1.
- **Option B (predicate-level argument)**: Work entirely at the predicate level. The winning condition already provides `stavi_temporal_truth_mu` agreement for all formulas of depth <= r. Extend to show that the rank-(r+1) forward game's response to c must satisfy the same continuation properties as c (hence must be >= d-bar). This avoids materializing C' but requires careful reasoning about the game structure.

### Step 2.2: Formula transfer gives d <= d-bar

**Claim**: If d is Duplicator's response to c in a game G_{m; r'}(M, xy; N, x'y') with r' > r, then N_r |= C'(d), and hence d <= d-bar.

**Proof**:
1. C' has rank r+1. Since r' > r, we have r' >= r+1, so the winning condition includes rank-(r+1) formula agreement.
2. From Step 2.1, M_r |= C'^mu(c).
3. By formula transfer (item 3 of the winning condition), N_r |= C'^mu(d).
4. Analyze C'(d):
   - If not-C(d) holds in N_r: d is not in S_C(N). Since S_C(N) is upward-closed in [x', y'] and d-bar = inf(S_C(N)), if d were above d-bar, then d would be in S_C(N) (by upward-closedness), contradicting not-C(d). So d <= d-bar.
   - If K^{-}(not-C)(d) holds in N_r: not-C holds cofinally below d. If d > d-bar, then C holds throughout (d-bar, y'), so C holds on (d-bar, d) in particular. But "not-C cofinal below d" means there are points arbitrarily close below d where C fails, contradicting C holding on (d-bar, d). So d <= d-bar.

**Lean mapping**: The forward game at rank r+1 is `h_fwd_r1`. Playing it with c as one of Spoiler's choices and reading off the response gives a point t = d (the response) satisfying the same rank-(r+1) formulas as c. The analysis of C'(d) uses `continuation_set_upward_closed` (line 174) and the infimum properties.

### Step 2.3: Contradiction gives d-bar <= d

**Claim**: d < d-bar leads to contradiction.

**Proof**:
1. Assume d < d-bar.
2. By definition of d-bar = inf(S_C(N)), since d < d-bar, d is not in S_C(N).
3. So there exists d' in (d, y') (in fact, in (d, d-bar) more precisely) with N |= not-C(d'). Specifically, since d is not in S_C(N), there is a mu-point u in (d, y') where cont_holds fails.
4. In the same game, Spoiler now challenges with d' (in round 2, choosing d' in N).
5. Duplicator must respond with some b in [x, y] (in M) such that b is in (c, y) (because d' > d corresponds to something above c) and the winning condition is satisfied.
6. But c = inf(S_C(M)), so C holds throughout (c, y) in M. Hence M |= C(b) for all b in (c, y).
7. The winning condition requires not-C(d') in N to correspond to not-C(b) in M. But M |= C(b), contradiction.

**Lean mapping**: This step uses:
- The infimum property: d < d-bar implies d not in S_C (contrapositive of d-bar being the GLB).
- d not in S_C gives a witness u with `cont_fails_below_gap` or direct construction.
- The forward game's round-2 challenge with this witness.
- The fact that `cont_holds_above_gap` gives C(b) for all b above c in M.

### Step 2.4: Conclusion: d = d-bar

From Steps 2.2 and 2.3: d <= d-bar and d-bar <= d, so d = d-bar.

This is the content of `d_consistency_left` and `d_consistency_right` (lines 1080--1246 of `ExpressivenessGeneral.lean`), specifically the interior case that is currently sorry'd at lines 1165 and 1246.

### Step 2.5: Rank Arithmetic

The forward hypothesis provides a strategy at rank r+4(n+1). The formula C' has rank r+1. Since r+4(n+1) >= r+4 >= r+1 for all n >= 0, C' is within the formula agreement range of the forward game.

The Lean code already propagates `h_fwd_r1` (rank r+1 forward strategy) as a parameter to `d_consistency_left/right`. This is sufficient.

---

## Section 3: Verbatim Extraction of Case II

### Source

GHR93, Section 8, pages 117--118 (page 29--30 of the markdown: lines 1443--1504 of `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md`).

### Case II Statement (p.117)

> **Case II**: All the points alpha_0, ..., alpha_n lie in (d-bar, y'), and alpha_n in N is not a gap.

### Case II Proof (Verbatim, pp.117--118)

> Recall that Duplicator is trying to win G_{n+1; r}(N, x'y'; M, xy) -- i.e., to preserve all rank r formulas. Define B = X_{alpha_n}, and b = sup{t in (x,y) : M |= B(t)}. As before, either b in M, b = y or b is an r-definable gap, defined on the right by not-B, so that b in M_r. Define b' in N_r similarly. Then clearly b' > alpha_n.
>
> As in Claim 1, in any play of G_{4+3n; r+4(n+1)}(M, xy; N, x'y') in which Duplicator is using her winning strategy and Spoiler chooses b, c amongst other points, Duplicator will respond with b', d-bar amongst others. Hence again Duplicator has a winning strategy for G_{1+3n; r+4(n+1)}(M, cb; N, d-bar b'). So by the induction hypothesis (\*)_n she has a winning strategy tau for G_{n; r+4}(N, d-bar b'; M, cb). She already has a winning strategy sigma for G_{n; r+4}(N, x'd-bar; M, xc).
>
> Let her first use tau in response to alpha_0, ..., alpha_{n-1}. It delivers n points e_0, ..., e_{n-1} in (c, b)_r (cf. Lemma 10). Now clearly N_r |= U(B, A)(alpha_{n-1}): alpha_n is a witness to this. (This holds even if alpha_{n-1} is a gap; if n = 0 we take alpha_{-1} to be d-bar and (see below) e_{-1} to be c.) U(B, A) has rank r+1, so as tau preserves formulas up to rank r+4, M_r |= U(B, A)^mu(e_{n-1}). Hence there is z > e_{n-1} in M with M |= B(z) and M |= A(t) for all t in (e_{n-1}, z). But e_{n-1} < b. Hence we can assume that z < b. Duplicator defines e_n to be such a z, completing her move. Clearly e_n and alpha_n satisfy the same temporal formulas of rank r, as they both satisfy B.
>
> Suppose that Spoiler continues by choosing t in [x, y]. Recall that by the game rules, t is not a gap. If t < c then Duplicator uses sigma to respond, and if c < t < e_{n-1} she uses tau. If t in (e_{n-1}, e_n) then M |= A(t). By definition of A there is t' in (alpha_{n-1}, alpha_n) with N |= X_{t'}(t). Duplicator can then choose any such t' as her response. It follows that t and t' agree on all rank r temporal formulas, as required. If t = e_n then Duplicator responds with alpha_n. Finally, if y > t > e_n then certainly t > c, so M |= C(t). By definition of C there is t' > alpha_n with N |= X_{t'}(t), and Duplicator can choose such a t' in response to t. If Duplicator follows these directions she will win.

### Diagram (from GHR93, p.117)

```
N':  x' -------d-bar-------alpha_0---...---alpha_{n-1}---alpha_n---b'--- y'
                 |              |               |            |       |
                 |     K^-~C   |      A        |     B      |  ~B  |
                 |              |               |            |       |
M :  x  ---------c----------e_0------...-----e_{n-1}-------e_n-----b---- y
                 |              |               |            |       |
                 |     ~C      |      A        |     B      |  ~B  |

         <--sigma-->                  <---tau--->
```

---

## Section 4: Step-by-Step Case II Construction, Annotated with Lean Mappings

### Step 4.0: GHR93 Notation -> Lean Identifier Mapping for Case II

| GHR93 | Lean | Description |
|-------|------|-------------|
| alpha_n (a point) | `a_bwd (n, ...)` with `h_point : IsPoint (a_bwd ...)` | Spoiler's last backward pick |
| alpha_0, ..., alpha_{n-1} | `a_bwd (0, ...), ..., a_bwd (n-1, ...)` | Remaining backward picks |
| B = X_{alpha_n} | Rank-r type formula for alpha_n | Conjunction of rank-r formulas true at alpha_n |
| b = sup{t : M |= B(t)} | Not yet defined in Lean | Supremum in M of B-satisfying points |
| b' = similarly in N | Not yet defined in Lean | Supremum in N |
| d-bar | `d` (the split point from `SplitPointProps`) | Infimum of continuation_set |
| c | `c` (from `SplitPointProps`) | Corresponding infimum in M |
| sigma | `props.sigma` in `SplitPointProps` | Backward strategy on [x', d-bar] vs [x, c] |
| tau | `props.tau` in `SplitPointProps` | Backward strategy on [d-bar, y'] vs [c, y] |
| e_0, ..., e_{n-1} | `resp_tau` (line 3013) | Tau's response to alpha_0, ..., alpha_{n-1} |
| e_n | `e_n` (line 3036 / 3061) | Fresh point from U(B,A) transfer |
| U(B, A) | Stavi formula of rank r+1 | Until formula using B and A |
| z (witness for U(B,A)) | The point chosen as e_n | Found via existential in U(B,A) |

### Step 4.1: Define B and supremum points b, b'

**GHR93**: B = X_{alpha_n}, the rank-r type of alpha_n. b = sup{t in (x,y) : M |= B(t)}.

**Why b' > alpha_n**: B holds at alpha_n (by definition of X_{alpha_n}). So alpha_n is in the set {t : N |= B(t)}, hence b' >= alpha_n. Moreover, b' > alpha_n because either:
- There exist points above alpha_n satisfying B (then b' > alpha_n trivially), or
- alpha_n is the supremum. But in that case, B = X_{alpha_n} holds at alpha_n and not above, and since alpha_n is a point (Case II assumption), b' = alpha_n... Actually the proof says "clearly b' > alpha_n" which follows because B = X_{alpha_n} includes all rank-r formulas true at alpha_n; points in (alpha_n, y') satisfying the same type also satisfy B.

**Lean relevance**: The current code does NOT define b, b'. Instead, it works directly with the interval [d, y'] / [c, y] via tau. The supremum b/b' serves in GHR93 to bound the region where B holds, ensuring e_n < b (so e_n is not in the "beyond-B" region). In the Lean code, this bound is implicit: e_n is found between e_{n-1} and c+something.

**Implementation note**: The Lean code may not need to explicitly define b/b' if the U(B,A) witness z is guaranteed to be below y (which it is, since z satisfies B and A holds on (e_{n-1}, z), and A describes the interval type between alpha_{n-1} and alpha_n, which is bounded).

### Step 4.2: Strategy restriction gives sigma and tau

**GHR93**: By Claim 1, whenever Spoiler plays c and b in the forward game, Duplicator responds with d-bar and b'. This gives:
- Forward strategy restricted to [x, c] x [x', d-bar]: G_{1+3n; r+4(n+1)}(M, xc; N, x'd-bar)
- Forward strategy restricted to [c, b] x [d-bar, b']: G_{1+3n; r+4(n+1)}(M, cb; N, d-bar b')

By (\*)_n (the induction hypothesis), these give backward strategies:
- sigma: G_{n; r+4}(N, x'd-bar; M, xc)
- tau: G_{n; r+4}(N, d-bar b'; M, cb)

**Lean mapping**: `props.sigma` and `props.tau` in `SplitPointProps` (lines 1310--1313). Currently these are on [x', d] / [x, c] and [d, y'] / [c, y] respectively. The GHR93 version uses [d-bar, b'] / [c, b] for tau, which is a sub-interval of [d, y'] / [c, y]. Since the Lean version uses the larger interval [d, y'] / [c, y], it is at least as strong as the GHR93 version. This is fine -- any strategy on the larger interval restricts to the smaller one.

The key property: tau preserves rank-(r+4) formulas (not just rank r). This is critical for transferring U(B, A) which has rank r+1.

### Step 4.3: Apply tau to alpha_0, ..., alpha_{n-1}

**GHR93**: Use tau to respond to alpha_0, ..., alpha_{n-1}. This gives e_0, ..., e_{n-1} in (c, b)_r.

**Lean mapping**: This is lines 3007--3013 of `ExpressivenessGeneral.lean`:
```lean
let a_init : Fin n -> ExtendedCarrier N atomMap r :=
  fun k => a_bwd (k.val, ...)
obtain (resp_tau, hresp_tau_in, hwin_tau) := props.tau a_init ha_init
```

This step is already implemented and sorry-free. `resp_tau` gives the Lean equivalent of e_0, ..., e_{n-1}.

### Step 4.4: Transfer U(B, A) from N to M

**GHR93**: N_r |= U(B, A)(alpha_{n-1}). Since tau preserves rank-(r+4) formulas and U(B,A) has rank r+1 <= r+4, we get M_r |= U(B, A)(e_{n-1}).

**Detailed justification**:
1. alpha_n is a witness to U(B, A) at alpha_{n-1}: B holds at alpha_n, and A holds throughout (alpha_{n-1}, alpha_n).
2. The formula U(B, A) has rank max(rank(B), rank(A)) + 1 = r + 1.
3. tau preserves rank-(r+4) formulas (from Claim 2, which gives the backward strategy on the sub-interval with rank r+4 formula agreement).
4. Therefore M_r |= U(B, A)(e_{n-1}).

**Lean mapping**: This is the critical transfer step. The current code at lines 3044--3054 extracts formula agreement at rank r between e_n (a forward-game witness) and alpha_n. But what we ACTUALLY need is:
- `hform_en_prev_an_prev`: formula agreement at rank r+4 between `resp_tau(n-1)` and `alpha_{n-1}`, which comes from tau's winning condition.
- Then: N_r |= U(B, A)(alpha_{n-1}) transfers to M_r |= U(B, A)(e_{n-1}).

The Lean code currently constructs e_n via the FORWARD game (h_fwd_n1 at line 3033), which is the wrong approach. GHR93 constructs e_n via U(B, A) TRANSFER through tau, then WITNESSING the Until formula in M.

**Implementation note**: The correct approach is:
1. Show U(B, A)(alpha_{n-1}) holds in N_r.
2. Transfer via tau to get U(B, A)(resp_tau(n-1)) in M_r.
3. Unfold U(B, A): there exists z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z).
4. Set e_n = z.

### Step 4.5: Find z and set e_n

**GHR93**: From M_r |= U(B, A)(e_{n-1}), there exists z > e_{n-1} in M with:
- M |= B(z) (z has the same rank-r type as alpha_n)
- M |= A(t) for all t in (e_{n-1}, z) (A holds between e_{n-1} and z)
- e_{n-1} < z < b (so z is in the B-region)

Set e_n = z.

**Key property**: e_n and alpha_n satisfy the same temporal formulas of rank r, since they both satisfy B = X_{alpha_n}.

**Lean mapping**: The Until connective U(B, A) is a `StaviFormula`. Its truth at `resp_tau(n-1)` in M_r means (by `stavi_temporal_truth_mu` for U):

```
exists z : ExtendedCarrier M atomMap r,
  resp_tau(n-1) < z /\ z is a mu-point /\
  stavi_temporal_truth_mu M atomMap r z B /\
  forall t, resp_tau(n-1) < t -> t < z -> mu_holds t ->
    stavi_temporal_truth_mu M atomMap r t A
```

The witness z becomes e_n. The formula agreement between e_n and alpha_n follows from both satisfying B (the rank-r type formula).

### Step 4.6: Verify the winning condition (round 2)

**GHR93**: Spoiler now chooses t in [x, y] (round 2 of the backward game). Duplicator responds according to where t falls:

| Spoiler's t | Duplicator's response t' | Justification |
|-------------|--------------------------|---------------|
| t < c | Use sigma | sigma is the backward strategy on [x,c] vs [x',d-bar] |
| c < t < e_{n-1} | Use tau | tau is the backward strategy on [c,y] vs [d-bar,y'] |
| t in (e_{n-1}, e_n) | Choose t' in (alpha_{n-1}, alpha_n) with X_{t'} = X_t | A holds on (e_{n-1}, e_n), so some alpha' in (alpha_{n-1}, alpha_n) has the same type |
| t = e_n | Respond with alpha_n | They satisfy the same rank-r formulas (both satisfy B) |
| t > e_n | Choose t' > alpha_n with X_{t'} = X_t | C holds on (e_n, y) in M, so C holds at t; some point above alpha_n has the same type |

**Lean mapping**: This is the winning condition assembly that is currently sorry'd at lines 3082 and 3092. The case split is over the position of b_sp (Spoiler's round-2 choice) relative to c and e_n.

The key observations:
- The sub-cases t < c and c < t < e_{n-1} are delegated to sigma and tau respectively.
- The sub-case t in (e_{n-1}, e_n) uses the A-agreement: since A = X_{(alpha_{n-1}, alpha_n)} and A holds on (e_{n-1}, e_n) in M, and A describes the type of points in (alpha_{n-1}, alpha_n) in N, any point t in (e_{n-1}, e_n) has a type-match in (alpha_{n-1}, alpha_n).
- The sub-case t = e_n uses B-agreement.
- The sub-case t > e_n uses C-agreement: C holds on (c, y) in M (by definition of c as infimum), so C holds at t, and C = X_{(alpha_n, y')} describes the type of points above alpha_n in N.

---

## Section 5: Concrete Implementation Recommendations

### 5.1: What New Infrastructure is Needed

**5.1.1: U(B, A) Formula Construction (~20 lines)**

The proof needs to construct the Stavi formula `U(B, A)` where:
- B is a rank-r formula describing alpha_n's type
- A is a rank-r formula describing the (alpha_{n-1}, alpha_n) interval type

In the current Lean encoding, the type information is captured by `stavi_temporal_truth_mu` agreement, not by a named formula. The winning condition of tau gives formula agreement at rank r+4 for all `StaviFormula`s. The key is: can we construct a `StaviFormula` `UBA` of depth r+1 such that `stavi_temporal_truth_mu N atomMap r (a_bwd (n-1, ...)) UBA` holds?

**Alternative (predicate-level)**: Instead of materializing U(B,A) as a formula, use the winning condition of the forward game directly. The forward game provides:
- Given that tau's response e_{n-1} and alpha_{n-1} agree on rank-(r+4) formulas,
- And the forward game's response at rank r includes formula agreement,
- Derive the U(B,A) transfer as a semantic consequence.

This approach avoids formula construction but requires careful reasoning about the game's semantic content.

**5.1.2: Formula Agreement Type-Match Witness (~40 lines)**

For the round-2 sub-case t in (e_{n-1}, e_n), we need: if A holds at t in M, then there exists t' in (alpha_{n-1}, alpha_n) in N with the same rank-r type. This follows from A's definition as the interval type formula. Lean needs:

```lean
-- If A = X_{(alpha_{n-1}, alpha_n)} and stavi_temporal_truth_mu M atomMap r t A holds,
-- then there exists some non-gap point t' in (alpha_{n-1}, alpha_n) in N
-- with the same rank-r type as t.
```

This witness extraction is needed but currently absent. It requires the definition of A to be such that A(t) in M implies the existence of a matching point in N. This is inherent in the definition of X_{(s,t)} as the disjunction over non-gap points in (s,t), but the Lean code encodes intervals via the game winning condition rather than explicit disjunctions.

**5.1.3: C-Agreement Witness for t > e_n (~30 lines)**

Similarly, for t > e_n: C holds at t (since t > e_n > c and C holds on (c, y)), and C = X_{(alpha_n, y')} means there exists t' > alpha_n with the same type. This again requires type-match witnessing from the interval type formula.

### 5.2: Restructuring Claim 1 (d_consistency_left/right Interior)

**Current state**: Lines 1165 and 1246 are sorry'd.

**Recommended approach**:

1. **Semantic Claim 1** (~80 lines): Prove that for any play of the rank-(r+1) forward game where Spoiler includes c, Duplicator's response must be d (the infimum of continuation_set). Use:
   - `cont_holds_above_gap` (above d in N, cont_holds is true)
   - `cont_fails_below_gap` (below d in N, cont_holds fails)
   - `h_fwd_r1` to play the rank-(r+1) game
   - Winning condition gives formula agreement at rank r+1
   - The rank-(r+1) formula C' semantically distinguishes d from any t != d

2. **Difficulty**: The main challenge is that C' is not materialized as a formula. The argument needs to show that the rank-(r+1) game's response to c cannot be strictly above or below d, using the semantic properties of the infimum. This can be done at the predicate level without materializing C', using the following argument:
   - If t > d: there are mu-points between d and t where cont_holds fails. These witnesses can be used in the game to show the response is incompatible.
   - If t < d: all mu-points above d satisfy cont_holds, but t would need to NOT satisfy certain formulas that hold at d. The rank-(r+1) game should prevent this.

3. **Estimated lines**: 80-120 for the full proof.

### 5.3: Restructuring Case II

**Current state**: Lines 3000--3105 have the skeleton; lines 3082 and 3092 are sorry'd.

**Recommended restructuring**:

1. **Step A: U(B,A) transfer** (~40 lines): Extract from tau's winning condition that U(B,A) holds at resp_tau(n-1) in M. This requires:
   - Showing that U(B,A) holds at alpha_{n-1} in N (alpha_n witnesses it)
   - Tau preserves rank-(r+4) formulas, and U(B,A) has rank r+1 <= r+4

2. **Step B: Witness extraction** (~30 lines): From U(B,A)(resp_tau(n-1)) in M, extract the witness z with B(z) and A on (resp_tau(n-1), z). Set e_n = z.

3. **Step C: Winning condition assembly** (~100-150 lines): For each sub-case of b_sp (Spoiler's round-2 choice):
   - b_sp < c: delegate to sigma
   - c < b_sp < resp_tau(n-1): delegate to tau  
   - resp_tau(n-1) < b_sp < e_n: use A-agreement to find type-match in (alpha_{n-1}, alpha_n)
   - b_sp = e_n: respond with alpha_n (B-agreement)
   - b_sp > e_n: use C-agreement to find type-match above alpha_n

4. **Estimated lines**: 200-300 total for the full Case II restructure.

### 5.4: Priority Order

1. **First**: Claim 1 (d_consistency_left/right interior). This is the linchpin -- without it, obtain_split_point_props cannot produce the correct d, and all downstream cases fail.

2. **Second**: Case II winning condition assembly (lines 3082, 3092). This is the largest change but has the clearest path: the skeleton exists, the sub-case delegation logic is correct, only the winning condition stitching is missing.

3. **Third**: IH sorry at line 4122 (the overall inductive step). This becomes closeable once Claim 1 and Cases I-IV are complete.

### 5.5: Estimated Total Line Counts

| Component | New Lines | Sorry Sites Closed |
|-----------|-----------|-------------------|
| Claim 1 (d_consistency interior) | 80-120 | 2 (lines 1165, 1246) |
| Case II restructure | 200-300 | 2 (lines 3082, 3092) |
| IH assembly | 40-60 | 1 (line 4122) |
| **Total** | **320-480** | **5** |

### 5.6: Existing Infrastructure That Is Ready

The following infrastructure is already sorry-free and available for use:

- `continuation_set`, `continuation_set_nonempty`, `continuation_set_upward_closed`, `a_n_in_continuation_set` -- all ready
- `cont_holds_above_gap`, `cont_fails_below_gap` -- the semantic core of Claim 1
- `infimum_gap`, `infimum_gap_r_definable` -- gap construction from carrier cut
- `rank_embed`, `rank_embed_stavi_truth_mu`, `rank_embed_inClosedInterval` -- rank embedding
- `ghr93_strategy_restrict_left/right` -- strategy restriction (takes d_consistency as argument)
- `ghr93_duplicator_wins_round_mono` -- Lemma 10 (round monotonicity)
- `ghr93_winning_condition_symm` -- symmetry of winning conditions
- `SplitPointProps` structure with sigma, tau, h_fwd_n1

### 5.7: Key Architectural Insight

The single most important architectural point is: **the current code's approach of setting d = a_bwd(n) is fundamentally wrong**. GHR93 Claim 1 proves that d MUST be the infimum d-bar. The code at `obtain_split_point_props` (line 1346) already attempts infimum construction (the S_C case split at lines 1377--1530). The main remaining work is:

1. Close the Case 3 sorry at line 1530 (no carrier-point GLB exists; must use infimum_gap)
2. Prove Claim 1 to close d_consistency interior cases
3. Restructure Case II to match GHR93's e_n construction

All three are well-defined tasks with clear mathematical content from the literature.
