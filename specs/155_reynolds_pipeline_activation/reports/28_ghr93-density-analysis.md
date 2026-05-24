# GHR93 Section 8: Where Is Density Assumed?

**Task**: 155 (Reynolds Pipeline Activation)
**Date**: 2026-05-23
**Focus**: Identifying density assumptions in GHR93 expressive completeness proof

---

## Question 1: Where does the proof assume density?

### Answer: GHR93 does NOT assume density. The proof works for ALL linear orders.

The theorem statement (Theorem 3, p.93; restated on p.108-109) is explicit:

> "{U, S, U', S'} is expressively complete over **all linear time**." (p.93, line 420)

> "For all L-formulas phi(x) there is a temporal formula A such that if N is a **linear temporal structure** (i.e., one with linear flow of time)..." (p.108-109, lines 980-989)

Section 8's opening paragraph (p.108, lines 952-956) confirms:

> "In this section we will prove Theorem 3. That is, we establish expressive completeness of U, S and the Stavi connectives for **arbitrary linear flows of time**."

There is no density, completeness, or continuity hypothesis anywhere in Section 8. The proof is designed to work for all linear orders, including discrete ones (like Z), finite orders, scattered orders, and dense orders.

### Key structural feature: The proof operates on M_r, not M

GHR93 Definition 8.3 (p.109, lines 1004-1019) defines:

> M_r = M union {r-definable gaps of M}

The proof operates on the extended structure M_r, which includes all gaps definable by formulas of rank at most r. Points of M are called "points" (non-gaps), and M_r also includes gaps. The game G_{n;r} (Definition 8.7, p.111-112) explicitly distinguishes:

- **First round**: V chooses elements from [x,y]_r (which may include gaps)
- **Second round**: V chooses b' from [x',y'] (which must be a **point**, not a gap)

The distinction between points and gaps is fundamental. The K- argument in GHR93 does NOT require density because it operates on M_r where definable gaps are explicit elements.

---

## Question 2: Does Claim 1 work for discrete orders?

### Claim 1 (p.116, lines 1392-1402)

The claim states: in any play of G_{m;r'}(M,xy; N,x'y') where Exists uses a winning strategy, if Forall chooses c (the infimum of the continuation set), then Exists's response d equals d-bar (the infimum of the corresponding set in N).

**The proof of Claim 1 uses only:**
1. Formula transfer at rank r' >= r+1 (from the winning strategy)
2. The rank r+1 formula C_1 = not-C or K-minus-C, which detects c
3. An order argument: if d < d-bar, then Forall can choose d' in (d-bar, y') with not-C(d'), and Exists has no winning response

**This argument is purely order-theoretic and works for any linear order.** No density is needed. The K-minus formula K^-(C) = not-U(top, not-C) says "not-C is cofinal in the past." This formula's truth value at c depends only on whether not-C holds at points arbitrarily close below c in M_r (not in M!). Since M_r includes all r-definable gaps, the formula correctly detects c regardless of whether M is discrete or dense.

### Can two adjacent points in a discrete order have the same type?

Yes, but this does not break the proof. The proof does not claim that d is the unique point with its rank-r type. Rather, Claim 1 says d is uniquely determined as the response to c by ANY winning strategy. The proof shows d = d-bar by showing that d >= d-bar (from formula transfer of C_1) and d <= d-bar (from the contradiction argument: if d < d-bar, Forall wins).

---

## Question 3: How does GHR93 define Since/Until semantics?

### Standard Since and Until (p.90-91, lines 95-105)

The tables are (OCR is garbled, but the standard definitions apply):

- **S(p,q)** at t: exists s < t such that p(s) and for all u with s < u < t, q(u)
- **U(p,q)** at t: exists s > t such that p(s) and for all u with t < u < s, q(u)

**These use STRICT/OPEN intervals.** The witness s is strictly past/future of t, and the universal quantifier ranges over the open interval (s,t) or (t,s). The evaluation point t itself is not included in any quantifier range.

### Mu-relativized versions (p.110, Definition 8.4, lines 1021-1068)

When evaluating in M_r, the connectives are relativized to mu (the set of actual points = non-gaps):

- **U^mu(A,B)** at gap gamma: exists point t > gamma with A(t), and B holds at all points u in (gamma, t)
- **S^mu(A,B)** at gap gamma: exists point s < gamma with A(s), and B holds at all points u in (s, gamma)

The mu-relativization means: quantifiers range only over actual points (elements of M), not over gaps. This is crucial -- it means the connectives "skip over" gaps when evaluated at gap positions.

### K-minus formula

K^-(X) = not S(top, X) = not (exists s < t, top(s) and forall u in (s,t), X(u))

Equivalently: for all s < t, there exists u in (s,t) with not X(u). This says "not-X is cofinal below t."

**In the mu-relativized version at a gap gamma:**
K^-_mu(X)(gamma) = not S^mu(top, X)(gamma) = for all mu-point s < gamma, there exists mu-point u with s < u < gamma and not X(u).

**Critical observation for the discrete case**: The quantifiers range over MU-POINTS (carrier points), and the interval is OPEN. In a discrete order at a carrier point p, the open interval (s, p) excludes p itself. If s is the predecessor of p, then (s, p) is empty (no carrier points between adjacent elements), so the universal quantifier in S^mu is vacuously true, making S^mu(top, D)(p) = TRUE (witnessed by s).

This means K^-_mu(not D)(p) = FALSE at a carrier point p in a discrete order whenever p has an immediate predecessor in M_r. This is the root of the formalization issue.

### Lean formalization's semantics (EFGames.lean lines 877-882)

```lean
| .std_snce A B =>
    -- Standard Since, mu-relativized: exists mu-point s < t, A(s) and forall mu-point u in (s,t), B(u)
    exists s : ExtendedCarrier M atomMap r, s < t and mu_holds s and
      stavi_temporal_truth_mu M atomMap r s A and
      forall u : ExtendedCarrier M atomMap r, s < u -> u < t -> mu_holds u ->
        stavi_temporal_truth_mu M atomMap r u B
```

This matches GHR93 exactly: strict/open intervals, mu-restricted quantifiers. The formalization is correct.

---

## Question 4: Does GHR93 restrict to dense orders anywhere?

### Answer: NO. The entire Section 8 works for ALL linear orders.

**Evidence:**

1. **Theorem 3 statement** (p.93): "expressively complete over all linear time"

2. **Section 8 opening** (p.108): "arbitrary linear flows of time"

3. **Definition 8.1** (p.108): "A temporal (L-) structure is formally a triple N = (T, <, h), where (T, <) is an irreflexive poset" -- no density condition

4. **No density hypothesis in Theorem 6** (p.113, lines 1244-1250): The theorem states (*)_n for "all r < omega, if x < y in M_r, x' < y' in N_r..." with no restriction on M or N

5. **The proof handles the natural numbers** explicitly: The abstract (p.89) notes the argument was "sketched in [GPSS] for the case of U and S over natural numbers time" -- i.e., the integers/naturals, which are discrete

6. **Stavi connectives are always false on discrete orders** (noted in the Lean formalization, StaviConnectives.lean lines 202-206). The GHR93 proof works despite this because: (a) the Stavi connectives are only needed to handle gaps, and (b) discrete orders have no Dedekind gaps, so M_r = M for all r, and the standard Until/Since suffice

### Why density is not needed for Claim 1

The K- argument in the formalization attempts to prove: if c_inf is the infimum of the continuation set, then ¬D is cofinal below c_inf, making Since(top, D) false at c_inf, making K^-(not D) true at c_inf.

**In GHR93**, c is defined as (p.115-116, line 1381):

> c = inf {t in [x,y] : M |= C(u) for all u in (t, y)}

This infimum is taken in M_r (the structure extended with r-definable gaps), NOT in M. The key insight is that c might be:
1. A point of M (c in M)
2. Equal to x (c = x, already in M_r)
3. A gap definable on the right by C (c in M_r \ M)

When c is a GAP (case 3), the K- argument works perfectly because the open interval (s, c) in M_r contains points of M arbitrarily close to the gap (by the definition of a gap as a Dedekind cut). Even in a discrete order, if c is a gap, there are points below c with no maximum, so the cofinal failure argument goes through.

When c is a POINT of M (cases 1-2), the situation is different. But in this case, c itself is in M and the game can directly interact with c as a carrier point. The proof handles this by noting that c = x gives a direct contradiction (lines 1253-1268 in the handoff), and when x < c with c a carrier point, the argument uses a different path.

---

## Question 5: Relationship between G_{n;r} and standard EF games

### GHR93's game G_{n;r} (Definition 8.7, p.111-112)

The game G_{n;r}(M, xy; N, x'y') is NOT a standard Ehrenfeucht-Fraisse game. It has specific modifications:

1. **Two rounds only** (not n rounds):
   - Round 1: Forall chooses n elements from [x,y]_r (may include gaps); Exists responds with n elements from [x',y']_r
   - Round 2: Forall chooses ONE element b' from [x',y'] (**must be a point**, not a gap); Exists responds with b from [x,y]

2. **Winning condition** (3 parts):
   - (a) Same order type for the combined tuples xyab and x'y'a'b'
   - (b) Gap agreement: t is a gap of M iff t' is the corresponding gap of N
   - (c) Formula agreement: for all rank-r formulas A, M_r |= A^mu(t) iff N_r |= A^mu(t')

3. **The game structure does NOT change for discrete orders.** The same game definition applies. However:
   - In discrete orders, M_r = M (no new gaps), so [x,y]_r = [x,y]
   - Gaps in the game selections would come only from +/- infinity or from formula-definable gaps, but discrete orders have none
   - The formula agreement condition at rank r compares mu-relativized truth, which on discrete orders reduces to standard truth

### Proposition 7 (p.113-115): Connection to standard EF games

Proposition 7 shows how to build a winning strategy for the standard EF game G_n((M,x), (N,y)) from winning strategies for the modified games G_{f(n);g(n)}. This is the bridge from the game-theoretic framework to the expressive completeness result (Corollary 5, p.115).

### Theorem 6 (p.113): The reversal theorem

The central result (*)_n says: if Exists has a winning strategy for G_{1+3n; r+4n}(M,xy; N,x'y'), then she has one for G_{n;r}(N,x'y'; M,xy) (note the reversal of M and N). This reversal is what makes the proof work -- it shows the games are "symmetric enough" to derive equivalence.

---

## The Real Issue: Formalization Architecture

### Why the formalization has trouble with discrete orders

The formalization's `h_strict_failure` lemma (ExpressivenessGeneral.lean line 3276) requires:

> For all s < c_inf, there exists a mu-point u with s < u < c_inf (STRICTLY) where cont_holds_cross fails.

This strict inequality u < c_inf is the problem. In the GHR93 proof, c (the infimum) is computed in M_r. When c is a gap, the cofinal failure below c is guaranteed because gaps are limit points of carrier points. When c is a carrier point, the GHR93 proof handles it differently.

### The mismatch: c_inf in the formalization vs c in GHR93

The formalization computes c_inf as:

```
c_inf = inf (continuation_set_cross x y a_n y')
```

This is the infimum of the set of carrier points where `cont_holds_cross` holds, taken in `ExtendedCarrier M atomMap r`. The infimum could be:

1. **A carrier point where cont_holds_cross holds** -- then cofinal failures below it ARE strict (all failures are below it), and h_strict_failure is provable. This is the case handled at line 3284-3286 (the `hv_eq` case uses `absurd h_cont_c`).

2. **A carrier point where cont_holds_cross FAILS** -- then the infimum itself is a failure point, but failures below it may not exist. The `hv_eq` branch at line 3286 would substitute `h_not_cont_v` into `h_cont_c`, but `h_cont_c` says cont_holds_cross HOLDS at c_inf, so this case is handled by the case split at line 3273.

3. **A gap** -- then carrier-point failures exist cofinally below it, and h_strict_failure is provable.

Wait -- re-reading the code: the case split at line 3273 (`by_cases h_cont_c : cont_holds_cross ... c_inf`) handles case (A) where cont_holds_cross holds at c_inf, and case (B) where it fails. In case (A), h_strict_failure at lines 3280-3286 DOES work: if `hv_le_c` is actually `hv_eq` (v = c_inf), then `hv_eq ▸ h_not_cont_v` contradicts `h_cont_c`. So the strict failure IS provable in case (A).

The issue described in the handoff is about case (B): when cont_holds_cross fails at c_inf. In case (B), the code at line 3272 says "use the failing formula A directly (depth <= r)." This should be a simpler argument -- the formula that fails at c_inf can be used directly as D without needing the cofinal/pigeonhole machinery.

### Resolution

The formalization architecture actually handles the density question correctly through the case split:

- **(A) cont_holds_cross holds at c_inf**: h_strict_failure is provable (contradicts any v = c_inf case). The pigeonhole + K- argument applies.

- **(B) cont_holds_cross fails at c_inf**: No K- argument needed. The failing formula at c_inf can be used directly as the distinguishing formula.

The bug in the handoff appears to be that case (B) was not fully implemented, not that the proof structure is fundamentally unsound. The GHR93 proof does not need density because:

1. When the infimum is a gap: cofinal failures exist automatically
2. When the infimum is a point where the continuation holds: cofinal failures exist strictly below (any failure AT the infimum contradicts the hypothesis)
3. When the infimum is a point where the continuation fails: use the failure directly, no cofinality needed

---

## Summary of Findings

1. **GHR93 does NOT assume density.** Theorem 3 and Section 8 explicitly claim all linear orders.

2. **Claim 1 works for discrete orders.** The K- argument operates on M_r (extended with gaps), and the proof handles both gap and point infima.

3. **Since/Until semantics are STRICT (open intervals).** S(A,B) at t requires exists s < t with A(s) and forall u in (s,t), B(u). The mu-relativized version restricts quantifiers to carrier points.

4. **GHR93 does not restrict to dense orders anywhere.** The paper explicitly handles natural numbers and arbitrary linear time.

5. **The G_{n;r} game does not change structurally for discrete orders.** The key difference is that M_r = M (no new gaps), simplifying the case analysis.

6. **The formalization's h_strict_failure issue is an implementation bug, not a theoretical gap.** The case split architecture (cont_holds at c_inf vs not) correctly handles both scenarios. Case (B) needs implementation, not density hypotheses.

---

## Detailed Sorry Analysis in the Direction 1 Proof

### Case (A): cont_holds_cross holds at c_inf (line 3274)

- **h_strict_failure** (line 3276): PROVABLE. When v = c_inf from h_cofinal_failure_below_c_inf, the `absurd h_cont_c (hv_eq subst h_not_cont_v)` closes the goal. The strict version succeeds because cont_holds_cross holding at c_inf rules out c_inf as a failure point.

- **h_since_false_c** (line 3354): PROVABLE. Uses hD_cofinal to find D_M failures in every open interval (s, c_inf). The code at lines 3388-3414 handles both `x <= s` and `s < x` cases, producing mu-points with D_M failure strictly between s and c_inf.

- **K- transfer** (lines 3415-3436): COMPLETED. Successfully transfers K^-(not D_M) from c_inf in M to r2_resp in N via rank_embed + formula agreement.

- **Since(top, D_M) contradiction** (lines 3437-3666): COMPLETED for both d-is-carrier-point and d-is-gap sub-cases.

**No sorries remain in case (A)** -- the full K- argument is implemented.

### Case (B): cont_holds_cross fails at c_inf (line 3667)

The direct formula argument extracts A_fail from the cont_holds_cross failure, transfers via formula agreement, and derives contradiction.

- **Carrier-point r2_resp, r2_resp < rank_embed(y')** (line 3760): COMPLETED. Projects to rank r, shows A_fail holds at q_r2 from hd_in_SC, contradicts hA_fail_r2.

- **Carrier-point r2_resp, r2_resp = rank_embed(y')** (line 3759): SORRY. Edge case where c_inf = y. This forces S_C_M = {y}, meaning cont_holds_cross fails everywhere in (x, y). The formula A_fail holds on (a_n, y') in N but fails at c_inf = y in M. At r2_resp = rank_embed(y'), A_fail fails (via transfer), but showing A_fail holds at r2_resp requires A_fail to hold at y', which is a boundary point not in the open interval (a_n, y'). This is a genuine edge case that may require a boundary argument or a separate treatment when c_inf = y.

- **Gap r2_resp** (line 3793): SORRY. When r2_resp is a gap at rank r+2, showing A_fail holds at r2_resp requires evaluating a StaviFormula at a gap. This goes through the mu-relativized semantics. The current code marks this as "blocked: report 39 confirms formula materialization is circular."

### Summary of actual sorry sites in Direction 1

| Line | Case | Sub-case | Status | Root cause |
|------|------|----------|--------|------------|
| 3759 | (B) | carrier r2_resp, r2_resp = rank_embed(y') | SORRY | Boundary edge case: c_inf = y, A_fail truth at boundary |
| 3793 | (B) | gap r2_resp | SORRY | Formula materialization at gap (reported circular) |

Neither sorry is related to density. Both are edge cases in the direct formula argument of case (B).

---

## Recommendation

Do NOT add density hypotheses to the formalization. The GHR93 proof is valid for all linear orders.

**For the remaining sorries:**

1. **Line 3759 (c_inf = y boundary)**: When c_inf = y, the entire interval (x, y) has cont_holds_cross failures. This means S_C_M effectively consists only of y itself. The argument should show that r2_resp cannot equal rank_embed(y') in this configuration. Consider using the order agreement at indices (1,3): if c_inf = y, then rank_embed(c_inf) = rank_embed(y), and the order condition should force r2_resp = rank_embed(y') only when c_inf = y in M, but then d = y' in N (from the parallel construction), making rank_embed(d) = rank_embed(y') = r2_resp, contradicting h_not_le.

2. **Line 3793 (gap r2_resp)**: This requires showing that A_fail holds at a gap position. In GHR93, the formula C (which defines the continuation set) is a concrete temporal formula, so its value at gaps in M_r is determined by the mu-relativized semantics. The Lean formalization uses a universally-quantified predicate (cont_holds_cross) rather than a single formula. The fix is to use the specific formula A_fail extracted from the cont_holds_cross failure and show it holds at the gap r2_resp via the mu-relativized evaluation. This requires understanding how std_snce, std_untl, etc. evaluate at gaps -- the quantifiers range only over mu-points, so the gap itself is not quantified over.

3. **The sorry at line 3331** (listed in the handoff as part of h_strict_failure) appears to be resolved by the case split architecture: it is inside case (A) where cont_holds_cross holds at c_inf, so the v = c_inf sub-case leads to contradiction via `absurd h_cont_c`.
