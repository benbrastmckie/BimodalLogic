# GHR93 Round 2 Structure vs. Lean tau_left/tau_right Implementation

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Extract the EXACT Round 2 proof structure from GHR93 Case II and compare it point-by-point to the current Lean implementation. Determine whether tau_left/tau_right can be eliminated.

---

## 1. GHR93's Round 2 Structure (Case II)

### 1.1 Setup (What GHR93 Has Before Round 2)

In GHR93 / GHR94 (Chapter 12, pp.806-810), Case II starts with:

- **Spoiler's backward selections**: a_0, ..., a_{n-1}, a_n = p_n (a point, not a gap)
- **Split point**: d-bar (infimum of continuation set) with corresponding c in M
- **Sigma**: backward strategy on [x', d-bar] -> [x, c] at rank r+4
- **Supremum b**: b = sup{t in (x,y) : M |= B(t)} where B = X_{a_n}; similarly b' in N
- **Tau**: backward strategy on [d-bar, b'] -> [c, b] at rank r+4 (RESTRICTED interval, NOT [d-bar, y'] -> [c, y])
- **Tau's responses**: e_0 = resp_tau(0), ..., e_{n-1} = resp_tau(n-1), all in (c, b)
- **e_n = z**: the Until witness from U(B, A)(e_{n-1}), chosen so that z <= b

Key point: GHR93 uses a SINGLE tau on the RESTRICTED interval [d-bar, b'] -> [c, b]. There are no sub-games tau_left or tau_right.

### 1.2 The 5-Way Round 2 Case Split

GHR93/GHR94 (pp.808-810) splits Spoiler's Round 2 challenge point t (a carrier point in [x, y] on the M-side) into these cases:

**(a) t <= c**: Use sigma's Round 2. Spoiler's challenge is in [x, c], so delegate to sigma's winning condition. Sigma provides a response t' in [x', d-bar]. All orderings follow from sigma's game.

**(b) c < t < e_n (and t in (c, e_{n-1}])**: t is in the "pre-witness" region. Since tau plays on [c, b] and the responses e_0, ..., e_{n-1} are in (c, b), tau's Round 2 handles this. Spoiler's challenge t in [c, b] is within tau's interval, so delegate to tau's winning condition. Tau provides t' in [d-bar, b']. Orderings follow from tau's game plus the fact that t < e_n.

**(c) c < t < e_n (and t in (e_{n-1}, e_n))**: t is in the "Until interval." Since U(B,A)(e_{n-1}) holds and e_{n-1} < t < e_n = z (the witness), we know A(t) holds. By the definition of A = X_{(a_{n-1}, a_n)}, there exists a mu-point v in (a_{n-1}, a_n) in N with rank_type(t) = rank_type(v). Duplicator responds with v (or any carrier point having matching rank-type).

**(d) t = e_n**: Respond with p_n. Since B(e_n) holds (e_n is the Until witness), rank_type(e_n) = rank_type(a_n) = rank_type(p_n). Formula agreement follows from rank-type matching.

**(e) t > e_n**: The "continuation formula" C = X_{(a_n, y')} handles this. GHR94: "If t in (e_n, y), then since t > e_n > c, we have t > c so M |= C(t). By definition of C, there exists t' > a_n in N with matching rank-type. Duplicator plays t'." Alternatively, if t is in (e_n, b], tau's Round 2 may still handle it (since b >= e_n and tau plays on [c, b]). If t > b, the continuation formula argument applies.

### 1.3 Where GHR93 Gets Its Ordering Data

For each case, the ordering between t' (response) and the selections is established as follows:

- **Case (a)**: Sigma's game gives biconditional orderings for all positions in [x', d-bar] vs [x, c].
- **Cases (b)/(c)**: Tau's game (on [d-bar, b'] -> [c, b]) gives biconditional orderings between t' and a_0, ..., a_{n-1}. The ordering relative to a_n = p_n follows from the fact that t' is in [d-bar, b'] and a_n is also in [d-bar, b'] (since a_n < b').
- **Case (d)**: Trivial: t' = p_n corresponds to t = e_n.
- **Case (e)**: The continuation formula/tau tail gives orderings.

CRITICAL OBSERVATION: In GHR93, tau plays on [d-bar, b'] -> [c, b], and BOTH a_n = p_n AND e_n are bounded by b' and b respectively. This means tau's game includes positions up to b/b', and orderings relative to any point in [c, b] (including e_n) are available from tau. Similarly, on the N-side, orderings relative to any point in [d-bar, b'] (including p_n) are available.

---

## 2. The Current Lean Implementation

### 2.1 Setup (What the Lean Code Has Before Round 2)

The Lean code (CaseAnalysis.lean, lines 1395-1603) does NOT use GHR93's supremum approach. Instead:

- **tau_r**: backward game on [d, y'] -> [c, y] at rank r (projected from rank r+delta)
- **resp_tau**: tau_r's responses for a_init = a_0, ..., a_{n-1}, all in [c, y]
- **e_n**: constructed via the d-compatible forward game (h_d_compat_left), NOT from U(B,A)
- **tau_left**: backward game on [d, p_n] -> [c, e_n] at rank r, obtained by applying IH
- **tau_right**: backward game on [p_n, y'] -> [e_n, y] at rank r, obtained by applying IH
- **resp_left**: tau_left's responses for a_init, all in [c, e_n]
- **a'_resp**: resp_left(0..n-1), e_n at position n

### 2.2 The 3-Way Round 2 Case Split (Lean Code)

The Lean code splits into 3 cases (not 5):

**(A) b_sp <= c** (lines 1607-1785): Use sigma_r for Round 2. Identical to GHR93 case (a).

**(B1) c < b_sp <= e_n** (lines 1794-1965): Use tau_left for Round 2. Spoiler's challenge is in [c, e_n], which is tau_left's interval. Tau_left provides b_resp in [d, p_n]. All orderings come from tau_left's winning condition. This is the tau_left's Round 2, which covers GHR93 cases (b), (c), and (d).

**(B2) b_sp > e_n** (lines 1966-2136): Use tau_right for Round 2. Spoiler's challenge is in [e_n, y], which is tau_right's interval. Tau_right provides b_resp in [p_n, y']. Orderings between b_resp and a_init(k) use a combination of tau_left (for sel-vs-sel orderings) and tau_right (for b_resp orderings). This covers GHR93 case (e).

### 2.3 Where the Lean Code Gets Its Ordering Data

The biconditional ordering `(a_bwd k < a_bwd k' <-> a'_resp k < a'_resp k')` is the critical requirement for `same_order_type_of_cases`. Here is where each piece comes from:

**For sel-vs-sel (k, k' both < n)**: tau_left provides `(a_init j < a_init j' <-> resp_left j < resp_left j')`.

**For sel-vs-e_n (k < n, k' = n)**: tau_left provides `hord_left_sel_pn`:
```
(a_init k < extendPoint p_n <-> resp_left k < e_n) AND
(a_init k = extendPoint p_n <-> resp_left k = e_n)
```

**For b_resp orderings in B1**: tau_left's Round 2 provides orderings between b_resp and all game positions (sel, endpoints).

**For b_resp orderings in B2**: tau_right's Round 2 provides `(p_n < b_resp <-> e_n < b_sp)` and `(b_resp < y' <-> b_sp < y)`.

**For x/x' and y/y' orderings**: The forward game (h_d_compat_left) provides `hord_fwd_x_en`, `hord_fwd_en_y`, `hord_fwd_x_y`, `hform_fwd_x`, `hform_fwd_y`, `hgp_fwd_x`, `hgp_fwd_y`.

---

## 3. Point-by-Point Comparison

### 3.1 The Fundamental Architectural Difference

| Aspect | GHR93 | Lean Code |
|--------|-------|-----------|
| **tau interval** | [d-bar, b'] -> [c, b] (restricted) | [d, y'] -> [c, y] (full) |
| **e_n source** | U(B,A) witness z, chosen with z <= b | Forward game challenge with p_n |
| **Sub-games** | None -- single tau covers everything | tau_left on [d, p_n]->[c, e_n], tau_right on [p_n, y']->[e_n, y] |
| **Ordering source** | Tau's game (single) + sigma | tau_left + tau_right + forward game |
| **Round 2 split** | 5-way | 3-way (equivalent coverage) |

### 3.2 Why GHR93 Does Not Need Sub-Games

In GHR93, tau plays on [d-bar, b'] -> [c, b]. Since b >= e_n and b' >= p_n (because b = sup of B-satisfying points and B(a_n) = B(p_n) holds so b' >= a_n = p_n, and B(e_n) holds so e_n <= b), the critical orderings ARE available from tau:

- **sel vs p_n / e_n**: Since both p_n and e_n are within tau's interval ([d-bar, b'] and [c, b] respectively), tau's order-type preservation gives biconditional orderings between any pair of positions.
- **b_resp orderings**: For any challenge t in [c, b], tau's Round 2 gives a response t' in [d-bar, b'] with orderings relative to all positions.

The Lean code CANNOT do this because its tau plays on [d, y'] -> [c, y], and p_n/e_n are interior points of this interval, NOT endpoints. Tau's game only gives orderings relative to the game's fixed positions (d, y', c, y, and the selections), NOT relative to arbitrary interior points like p_n and e_n.

### 3.3 The Biconditional Ordering Problem (Why tau_left Is Required in the Lean Code)

The `same_order_type_of_cases` helper requires biconditional orderings:
```
(a_init k < p_n <-> resp_left k < e_n)
```

This cannot be obtained from tau_r (on [d, y'] -> [c, y]) because:
1. p_n is not an endpoint of tau_r's game
2. e_n is not an endpoint of tau_r's game
3. tau_r gives orderings between selections and d/y'/c/y, but NOT between selections and p_n/e_n
4. `pivot_chain_order` could help but requires `resp_tau(k) <= e_n`, which is not known from tau_r

tau_left (on [d, p_n] -> [c, e_n]) solves this because p_n and e_n ARE the endpoints, so tau_left's winning condition directly provides the needed biconditional.

### 3.4 Why GHR93 Gets Free Orderings the Lean Code Cannot

In GHR93, tau is on [c', b'] -> [c, b] with b >= e_n. Since e_n is IN the interval [c, b], and p_n is IN the interval [c', b'], tau's game includes these as possible challenge points. So when Spoiler challenges with e_n in tau's Round 2, Duplicator responds with some point (call it p_n' which should equal p_n by formula matching). The orderings (sel_k < e_n <-> resp(k) < p_n) come from tau's order-type preservation applied to the Round 2 challenge.

But this only works because GHR93's tau plays on [c, b] where b >= e_n. In the Lean code, tau_r plays on [c, y] where y >= e_n is true, but y is much larger. The problem is NOT that e_n is outside the interval -- it IS inside. The problem is that the game's winning condition gives orderings between the FIXED positions (x, y, x', y', selections, b_sp, b_resp), and e_n/p_n are not fixed positions of tau_r's game.

HOWEVER, this analysis suggests a potential path: if we play tau_r with an additional Round 2 challenge at e_n, we get orderings between resp_tau(k) and e_n. But this gives orderings involving tau_r's b_resp (the response to e_n challenge), not resp_left(k). The issue is that the Round 1 responses (resp_tau) and the Round 2 response (b_resp to e_n challenge) are conceptually separate entities in the game structure.

---

## 4. Detailed Mapping: Every tau_left/tau_right Usage Site

### 4.1 tau_left (lines 1540-1544)

**Definition**: `tau_left : ghr93_duplicator_wins N M atomMap n r d (extendPoint p_n) c e_n`

**How obtained**: Apply IH to the (1+3n)-round forward game at rank r on [c, e_n] x [d, p_n].

**What it provides**:
1. `resp_left`: Round 1 responses for a_init, all in [c, e_n]
2. `hwin_left`: Round 2 winning condition -- for any b_sp in [c, e_n], there exists b_resp in [d, p_n] with full game condition
3. `hord_left`: Biconditional orderings between all game positions (including d/p_n/c/e_n)
4. `hgp_left`: Gap/point agreement at all positions
5. `hform_left`: Formula agreement at all positions

**Critical usage**: `hord_left_sel_pn` (line 1581-1586):
```lean
(a_init k < extendPoint p_n <-> resp_left k < e_n) AND
(a_init k = extendPoint p_n <-> resp_left k = e_n)
```

**GHR93 equivalent**: In GHR93, this ordering comes from tau itself (since tau plays on [c', b'] -> [c, b] and both p_n and e_n are within the interval). No separate sub-game is needed.

**Can it be eliminated?**: NOT with the current architecture (tau_r on [d, y'] -> [c, y]). WOULD be eliminable if tau were restricted to [d, b'] -> [c, b] (matching GHR93), which requires supremum infrastructure.

### 4.2 tau_right (lines 1546-1550)

**Definition**: `tau_right : ghr93_duplicator_wins N M atomMap n r (extendPoint p_n) y' e_n y`

**How obtained**: Apply IH to the (1+3n)-round forward game at rank r on [e_n, y] x [p_n, y'].

**What it provides**:
1. Round 2 winning condition for challenges in [e_n, y] -- provides b_resp in [p_n, y']
2. Orderings: `(p_n < b_resp <-> e_n < b_sp)` via tau_right's Round 2

**Usage in Case B2** (lines 1966-2136):
- tau_right provides b_resp for the challenge b_sp > e_n
- tau_right's orderings give `tau_pn_b : (p_n < b_resp <-> e_n < b_sp)`
- tau_right's formula agreement gives formula data for b_resp

**GHR93 equivalent**: In GHR93, case (e) uses either (1) tau's Round 2 (if t is in (e_n, b] and tau covers [c, b]) or (2) the continuation formula C for challenges beyond b.

**Can it be eliminated?**: NOT with the current architecture. Required for Case B2 orderings and formula agreement.

### 4.3 Forward Game (h_d_compat_left, lines 1440-1517)

The forward game provides data that is NOT available from tau_r, sigma_r, tau_left, or tau_right:

- `hord_fwd_x_en`: (x < e_n <-> x' < p_n)
- `hord_fwd_en_y`: (e_n < y <-> p_n < y')
- `hord_fwd_x_y`: (x < y <-> x' < y')
- `hform_fwd_x`, `hform_fwd_y`: formula agreement at x/x' and y/y'
- `hgp_fwd_x`, `hgp_fwd_y`: gap/point agreement at x/x' and y/y'
- `hord_cd_en_pn`: (c < e_n <-> d < p_n) -- used for pivot_chain_order

These are endpoint-crossing orderings that relate x/y (outer interval endpoints) to e_n/p_n (inner pivot points). In GHR93, these would come from the original forward game used in Claim 1 / Claim 2 (which establishes c, d, sigma, tau). The Lean code uses a SEPARATE forward game (h_d_compat_left) to get these.

**Can it be eliminated?**: NOT without an alternative source for endpoint-crossing orderings.

---

## 5. The Critical Insight: Why GHR93 and Lean Diverge

### 5.1 GHR93's Argument Is Enabled by the Supremum

GHR93's entire simplification comes from one fact: **tau plays on the RESTRICTED interval [c', b'] -> [c, b] where b = sup{B-satisfying points}**. This restriction means:

1. e_n = z (the Until witness) satisfies z <= b, so e_n is INSIDE tau's interval
2. p_n satisfies p_n <= b' (since B(p_n) holds), so p_n is INSIDE tau's interval
3. Tau's game orderings include orderings relative to e_n and p_n (as interior points)
4. No sub-games are needed because the single tau covers the entire relevant range

### 5.2 The Lean Code Lacks the Supremum

The Lean code uses tau on [d, y'] -> [c, y] -- the FULL right sub-interval. This means:

1. e_n and p_n are interior points of tau's interval (they are in [c, y] and [d, y'] respectively)
2. But tau's winning condition only gives orderings between its FIXED positions (d, y', c, y, selections, and Round 2 challenge/response pairs)
3. e_n and p_n are NOT fixed positions of this tau game
4. To get orderings relative to e_n/p_n, the code must use ADDITIONAL games (tau_left, tau_right)

### 5.3 The Supremum Is Not Just About Containment

The previous analysis (reports 40, 45, 46) focused on the supremum's role in CONTAINING the Until witness (z <= b). But the supremum plays a SECOND equally important role: it makes tau's interval SMALLER, which puts e_n/p_n at the boundary of the interval, making their orderings available from the single tau game.

Without the supremum:
- tau plays on [c, y] (large interval)
- e_n is an interior point of [c, y] -- no orderings relative to it from tau
- Need tau_left ([c, e_n]) and tau_right ([e_n, y]) as sub-games

With the supremum:
- tau plays on [c, b] (smaller interval, b = sup of B-satisfying points)
- e_n <= b, so e_n is in [c, b] -- tau covers it
- tau's Round 2, when challenged with e_n, gives orderings relative to e_n

This is the deeper reason tau_left/tau_right exist in the Lean code: they compensate for tau playing on the wrong (too-large) interval.

---

## 6. Could the Lean Code Adopt GHR93's Single-Tau Approach?

### 6.1 What Would Be Required

To eliminate tau_left/tau_right and follow GHR93 exactly:

1. **Build supremum infrastructure**: Define b = sup{t in (x,y) : B(t)} in ExtendedCarrier. Prove it exists and is in M_r. (~100-200 lines of new infrastructure)

2. **Restrict tau**: Derive a backward game on [d, b'] -> [c, b] from either:
   - The existing tau on [d, y'] -> [c, y] by restriction (may not be straightforward since game strategies are not simply "restricted" to sub-intervals), OR
   - A fresh application of IH to the sub-interval [c, b] x [d, b'] (requires a forward game on this sub-interval)

3. **Construct e_n from U(B,A)**: Use `ghr93_untl_transfer` + `untl_witness_bounded` (already implemented in Tasks 5.0-5.5).

4. **Prove z <= b**: From the supremum definition + B(z) + z > e_{n-1} >= c. Since b = sup of B-satisfying points in (x,y) and B(z) holds, z <= b. (Requires that z is in (x,y), which needs argument.)

5. **Rewrite Round 2**: Replace the 3-way split with a 5-way split using tau's orderings directly.

### 6.2 The Fundamental Obstacle: Tau Restriction

The hardest step is #2. A backward game strategy is a function that maps selections to responses and provides a winning condition. "Restricting" a strategy to a sub-interval is NOT just about restricting the domain -- the strategy function must still produce valid responses, and the winning condition must still hold, on the sub-interval.

Two approaches:
- **Strategy restriction theorem**: If tau wins on [d, y'] -> [c, y], and all Spoiler selections are in [d, b'] (subset of [d, y']), then Duplicator's responses are in [c, y] but are they in [c, b]? Not necessarily. Tau guarantees responses in [c, y] but not in [c, b].
- **Fresh IH application**: Apply IH to get a new backward game on [d, b'] -> [c, b]. This requires a forward game on [c, b] x [d, b'], which is available from h_r1_univ (universal forward game) applied to the sub-interval.

The fresh IH approach is cleaner and matches GHR93 exactly, but it introduces more computational cost (an additional IH application).

### 6.3 Assessment

Adopting the full GHR93 approach would require ~300-500 lines of new infrastructure:
- ~100-200 lines: supremum existence/properties
- ~50-100 lines: restricted tau (via fresh IH)
- ~100-200 lines: rewritten Round 2 with 5-way split

It would DELETE ~400-600 lines:
- tau_left, tau_right construction (~20 lines each)
- resp_left play and ordering extraction (~100 lines)
- Forward game e_n construction and extraction (~200 lines)
- Duplicated ordering machinery in B1 and B2 cases (~200 lines)

Net change: approximately -100 to +100 lines, but with dramatically simpler structure.

**However**, this is a large refactoring with non-trivial mathematical prerequisites (supremum existence). The current code is sorry-free and axiom-clean. The refactoring risk may outweigh the simplification benefit.

---

## 7. Summary of Findings

### Q1: How does GHR93 handle Round 2?
GHR93 uses a SINGLE tau on the RESTRICTED interval [c', b'] -> [c, b] (where b = supremum of B-satisfying points). Round 2 is a 5-way case split: (a) t <= c -> sigma, (b)/(c) c < t < e_n -> tau's Round 2 or Until interval-type, (d) t = e_n -> respond with p_n, (e) t > e_n -> tau's tail or continuation formula.

### Q2: Why does the Lean code use tau_left/tau_right?
Because tau_r plays on [d, y'] -> [c, y] (NOT the restricted [d, b'] -> [c, b]), and p_n/e_n are interior points. Tau_r gives no orderings relative to p_n/e_n. Tau_left/tau_right decompose the interval at p_n/e_n to make them endpoints, recovering the needed biconditional orderings.

### Q3: Is the Lean approach mathematically equivalent to GHR93?
Yes. The 3-way split (A, B1, B2) covers the same cases as GHR93's 5-way split. Case B1 (b_sp <= e_n) combines GHR93 cases (b), (c), (d). Case B2 (b_sp > e_n) matches GHR93 case (e). The ordering data comes from different sources (sub-games vs. single game) but the end result is identical.

### Q4: Can tau_left/tau_right be eliminated?
Only if the supremum infrastructure is built AND tau is restricted to [c, b]. This is a ~300-500 line refactoring. Without the supremum, tau_left/tau_right are mathematically NECESSARY in the current architecture because the biconditional orderings `(a_init k < p_n <-> resp_left k < e_n)` cannot be obtained from tau_r alone.

### Q5: What does the forward game provide that cannot be obtained otherwise?
Endpoint-crossing orderings: (x < e_n <-> x' < p_n), (e_n < y <-> p_n < y'), formula/gap-point agreement at x/x' and y/y'. These relate the outer interval endpoints to the inner pivot points. In GHR93, these come from the original Claim 1/Claim 2 forward game, which IS still used (just not for e_n construction).

### Q6: Where exactly does resp_tau fail and resp_left succeed?
resp_tau gives orderings between a_init(j) and a_init(j'), between a_init(k) and d/y', and between b_resp and all positions. But it gives NO orderings between a_init(k) and p_n, or between resp_tau(k) and e_n. resp_left succeeds because p_n and e_n are ENDPOINTS of tau_left's game, so tau_left's winning condition directly provides `(a_init k < p_n <-> resp_left k < e_n)`.

---

## 8. Recommendation

**Do not attempt to eliminate tau_left/tau_right without first building the supremum infrastructure.** The current implementation is sorry-free and mathematically correct. The tau_left/tau_right decomposition is the Lean code's substitute for GHR93's supremum-restricted tau, and it works correctly.

If a future plan revision pursues GHR93 faithfulness:
1. Build `definable_sup` in CharacteristicFormula.lean or a new file
2. Derive restricted tau via fresh IH on [c, b] x [c', b']
3. Rewrite Round 2 with the 5-way split using single-tau orderings
4. Delete tau_left, tau_right, resp_left, forward-game e_n, and all associated ordering machinery

But this is an optimization, not a correctness fix. The current proof compiles, passes axiom checks, and has zero sorries in ghr93_case_II.
