# X_t Complete Usage Analysis: Every Occurrence in GHR93 Section 8

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Precise analysis of X_t construction, every usage in Cases I-IV, the interval type formula A, the left/right gap-detection formulas, and the finiteness argument. Includes assessment of Lean infrastructure requirements.

---

## 1. Definition of X_t and X_{(t,u)} (GHR93 Def. 8.8 / GHR94 Def. 12.8.13)

### 1.1 X_t: Complete Rank-r Type at a Position

**Definition** (verbatim from GHR94 p.636, GHR93 p.112):

> Let r < omega and t in M_r be given. Define X_t to be the conjunction of all temporal L-formulas X of rank <= r with M_r |= X^mu(t). This conjunction is effectively finite, as because L is finite there are up to logical equivalence only finitely many distinct formulae of any rank. Hence X_t can be taken to be a temporal formula of rank r.

**Key properties**:
- **Carrier**: t ranges over M_r (points AND gaps).
- **Evaluation**: Uses mu-relativized evaluation X^mu, NOT direct evaluation. This means connectives in X quantify only over actual points (mu-points), not gaps.
- **Rank**: rank(X_t) = r (the conjunction has the same rank as its highest-rank conjunct).
- **Semantic content**: X_t is the complete rank-r theory at t. Two positions t, u have X_t = X_u (as formulas) iff they satisfy exactly the same rank-r formulas under mu-relativization.
- **Construction**: X_t is NOT built by explicit enumeration. GHR93 relies on the fact that there are finitely many inequivalent formulas of each rank (because L is finite), so one picks a representative from each equivalence class and conjoins those that hold at t.

### 1.2 X_{(t,u)}: Interval Type Formula

**Definition** (verbatim from GHR94 p.644, GHR93 p.112):

> If t < u in M_r, define X_{(t,u)} to be the disjunction of X_v for v in (t,u). Again the disjunction is effectively finite, so that X_{(t,u)} can be taken to be a formula of rank r. Note that only non-gaps (points) contribute to the disjunction.

**Key properties**:
- **Carrier**: v ranges over actual points in (t,u) -- explicitly "only non-gaps contribute."
- **Rank**: rank(X_{(t,u)}) = r (same as each X_v, since disjunction does not increase rank).
- **Semantic content**: X_{(t,u)} holds at a point w iff w has the same rank-r type as SOME actual point in the interval (t,u). Equivalently, X_{(t,u)}(w) iff the rank-r type of w is realized in the interval (t,u).
- **NOT "all points satisfy A"**: X_{(t,u)}(w) does NOT mean that w is in the interval. It means w has a type that appears somewhere in the interval.

---

## 2. Every Occurrence of X_t in GHR93 Theorem 6

### 2.1 Setup Phase (Before Case Split)

**A = X_{(a_{n-1}, a_n)}** -- the interval type formula for the open interval between Spoiler's last two choices in N_r.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.115-116, GHR94 p.750 |
| Rank | r |
| Construction | Disjunction of X_v for non-gap v in (a_{n-1}, a_n) in N_r |
| Evaluation domain | M_r (mu-relativized) |
| Used inside temporal op? | YES -- inside U(B,A), U(delta,A), and directly for interval-type matching |
| Key usage | "A holds on (a_{n-1}, a_n)" means every non-gap point in that interval satisfies A |
| Edge case | When n = 0, take a_{n-1} = x' (= c' per GHR94), so A = X_{(x', a_0)} |

**C = X_{(a_n, y')}** -- the continuation formula for the tail interval.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.115, GHR94 p.750 |
| Rank | r |
| Construction | Disjunction of X_v for non-gap v in (a_n, y') in N_r |
| Used inside temporal op? | YES -- inside C' = not-C or K^-(not-C) (rank r+1) |
| Key usage | Defines the infimum c = inf{t in [x,y] : M |= C(u) for all u in (t,y)} |

### 2.2 Claim 1: d-Consistency

**C' = not-C or K^-(not-C)** -- the formula used to prove d = d-bar.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.116, GHR94 p.764 |
| Rank | r + 1 (one level above C) |
| Construction | C is rank r, negation preserves rank, K^-(not-C) = not-S(top, not-not-C) adds one temporal layer |
| Used inside temporal op? | NO -- evaluated directly at c and d via winning condition transfer |
| Key usage | M_r |= C'(c), transfer via forward game gives N_r |= C'(d), forcing d <= d-bar |
| Role of X_t | INDIRECT -- C is built from X_v's, C' wraps C in negation + K^- |

### 2.3 Case I: a_0 < d (Split Case)

**No new X_t formulas are constructed in Case I.**

Case I does not build any new type formulas. It merely distributes Spoiler's choices between the sigma and tau strategies based on which side of d they fall. The existing strategies sigma and tau (inherited from the induction hypothesis via strategy restriction) handle all formula agreement.

### 2.4 Case II: a_n Is a Point (Not a Gap)

**B = X_{a_n}** -- the complete rank-r type of Spoiler's last choice.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.117, GHR94 p.792 |
| Rank | r |
| Construction | Conjunction of all rank-r formulas X with N_r |= X^mu(a_n) |
| Used inside temporal op? | YES -- inside U(B, A) (rank r+1) |
| Key properties required | (1) a_n satisfies B by definition; (2) any point satisfying B has the same rank-r type as a_n |

**U(B, A)** -- the Until formula witnessing the existence of a B-point beyond an A-interval.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.117-118, GHR94 p.802-806 |
| Rank | r + 1 (max of rank(B)=r and rank(A)=r, plus 1 for the Until) |
| Construction | Standard Until: U(B, A)(t) iff exists s > t with B(s) and A on (t,s) |
| Used inside temporal op? | NO -- evaluated directly, not nested |
| Key usage | N_r |= U(B,A)(a_{n-1}) [witnessed by a_n]; transfer through tau (rank r+4 >= r+1) gives M_r |= U(B,A)(e_{n-1}); extract witness z = e_n |

**b = sup{t in (x,y) : M |= B(t)}** -- the supremum of B-satisfying points.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.117, GHR94 p.792 |
| Construction | Standard supremum of a definable set |
| Role | Bounds the region where e_n can be placed; ensures z < b |
| In M_r? | Yes: either b in M, b = y, or b is an r-definable gap defined on the right by not-B |

**Round 2 verification**: For Spoiler's challenge point t:
- t in (e_{n-1}, e_n): M |= A(t), so there exists t' in (a_{n-1}, a_n) with X_{t'} agreeing with X_t. Duplicator responds with such t'.
- t = e_n: Respond with a_n (both satisfy B = X_{a_n}).
- t > e_n: M |= C(t) (since t > c), so there exists t' > a_n with X_{t'} agreeing with X_t.

### 2.5 Case III: a_n Is a Gap Defined on the Left

**B = X_{a_n}** -- the complete rank-r type at the gap a_n (using mu-relativized evaluation).

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.118, GHR94 p.812-814 |
| Rank | r |
| Construction | Same as Case II: conjunction of all rank-r formulas true at a_n under mu-relativization |
| Note | B is evaluated AT A GAP via A^mu. Gaps have no intrinsic predicate values; atoms evaluate to false at gaps. But compound formulas (U, S, U', S') can be non-trivially true at gaps via mu-relativized quantification. |

**D** -- the formula defining a_n on the left, rank <= r.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.118, GHR94 p.812 |
| Rank | <= r |
| Construction | Given by the case assumption: a_n is a gap definable on the left by D |
| Constraint | Can assume D implies A (since a_n is also definable by A and D, replace D with A and D) |

**delta = left(B, D)** -- the gap-detection formula.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.118, GHR94 p.814 |
| Rank | <= max(r, r) + 2 = r + 2 |
| Construction | left(B, D) as defined in GHR93 Def. 8.5 / GHR94 Def. 12.8.6 by structural induction on B |
| Used inside temporal op? | YES -- inside U(delta, A) (rank r + 3) |
| Key usage | By Lemma 9 (GHR94 12.8.7): M_r |= left(B,D)(t) iff there exists a gap gamma > t defined by D on the left, with D on (t, gamma), and M_r |= B^mu(gamma). |

**U(delta, A)** -- the Until formula detecting a gap with property B reachable through an A-interval.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.118, GHR94 p.814 |
| Rank | max(r+2, r) + 1 = r + 3 |
| Construction | Standard Until: U(delta, A)(t) iff exists s > t with delta(s) and A on (t,s) |
| Used inside temporal op? | NO -- evaluated directly |
| Key usage | N_r |= U(delta, A)(a_{n-1}); transfer through backward strategy (rank r+4 >= r+3) gives M_r |= U(delta, A)(e_{n-1}); find t < g with delta(t) and A on (e_{n-1}, t); by Lemma 9, there exists gap e_n in (t,d) matching a_n. |

**Supremum points d', g' and d, g**:
- d' = sup{t in (x',y') : N |= not-D(t)} -- supremum of not-D region
- g' = sup{t in (x', d') : N |= delta(t)} -- supremum of delta-holding region below d'
- d, g defined similarly in M
- All lie in M_{r+2}, N_{r+2} (since D has rank <= r and delta has rank <= r+2)

### 2.6 Case IV: a_n Is a Gap NOT Defined on the Left

**B = X_{a_n}** -- same construction as Cases II/III.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.119, GHR94 p.833-835 |
| Rank | r |

**D** -- a formula of rank <= r defining a_n on the RIGHT.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.119, GHR94 p.835 |
| Rank | <= r |
| Note | Since a_n is NOT definable on the left by any rank-r formula, but it IS in M_r (hence definable by SOME rank-r formula), it must be definable on the right. |

**delta = A and not-D and U(right(B, D), A)** -- compound gap-detection formula.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.119, GHR94 p.835 |
| Rank | max(r, r, max(r,r)+2, r) + 1 = r + 3 |
| Construction | Conjunction of: (1) A (rank r), (2) not-D (rank r), (3) U(right(B,D), A) where right(B,D) has rank <= r+2 and U adds 1. |
| Used inside temporal op? | YES -- inside U(delta, A) (rank r + 4) |

**U(delta, A)** -- the compound Until.

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.119, GHR94 p.839 |
| Rank | max(r+3, r) + 1 = r + 4 |
| Key constraint | THIS IS THE MAXIMUM RANK FORMULA IN THE PROOF. rank(U(delta, A)) = r + 4, which exactly matches the rank budget of the backward strategy (rank r+4). |

**Supremum points d', g' and d, g**:
- d' = sup{t in (x',y') : N |= right(B,D)(t)} -- where right(B,D) is witnessed
- g' = sup{t in (x', d') : N |= delta(t)}
- d, g defined similarly in M
- All lie in M_{r+3}, N_{r+3}

### 2.7 Proposition 6 (Formula Agreement -> Game Strategies)

**C_i formulas**: Proposition 6 (GHR94 12.8.16) constructs formulas C_n, ..., C_0 as:

```
C_n = X_{a_n} and not-U(not-X_{(a_n, infinity)}, top)
C_i = X_{a_i} and U(C_{i+1}, X_{(a_i, a_{i+1})})  for i < n
```

| Attribute | Value |
|-----------|-------|
| Where | GHR93 p.114, GHR94 p.686 |
| Rank | rank(C_i) = r + n + 1 - i; rank(C_0) = r + n + 1 |
| Construction | Nested Until formulas incorporating X_t and X_{(t,u)} at each level |
| When gaps are involved | Formulas become more complicated: involve left(X_{a_i}, D) or right(X_{a_i}, D), pushing rank up to r + 4n + 1 |

### 2.8 Decomposition Formulas (Lemma 11 / Lemma 12.8.14)

X_t and X_{(t,u)} appear in the canonical decomposition formula psi:

```
psi(y_0, y_{n+1}) = exists y_1,...,y_n.
  y_0 < y_1 < ... < y_{n+1} and
  for all x.
    AND_i [X_{a_i}^mu(y_i)] and
    AND_{i<=n} [mu(x) and y_i < x < y_{i+1} -> X_{(a_i, a_{i+1})}(x)]
```

This is the (2) => (1) direction of Lemma 11: Duplicator can win the game iff the structures agree on all decomposition formulas.

---

## 3. The A Formula -- X_{(a_{n-1}, a_n)} in Detail

### 3.1 Precise Construction

A = X_{(a_{n-1}, a_n)} is a disjunction:

```
A = OR_{v in (a_{n-1}, a_n), v is a point of N} X_v
```

where each X_v is itself a conjunction of all rank-r formulas true at v under mu-relativization.

Since there are only finitely many inequivalent rank-r formulas (and hence finitely many distinct rank-r types), the disjunction has only finitely many distinct disjuncts. Let tau_1, ..., tau_m be the distinct rank-r types realized by points in the interval (a_{n-1}, a_n). Then:

```
A = X_{v_1} or X_{v_2} or ... or X_{v_m}
```

where v_i is any representative point of type tau_i.

### 3.2 What "A Holds on (a_{n-1}, a_n)" Means

GHR93 states: "A holds on (a_{n-1}, a_n)." This means: for every non-gap point v in the interval (a_{n-1}, a_n) in N_r, N_r |= A^mu(v). This is TRIVIALLY TRUE because A is the disjunction of all types realized in the interval, so every point in the interval has its type appearing as one of the disjuncts.

### 3.3 Rank

rank(A) = r. The disjunction of rank-r formulas has rank r.

### 3.4 How A Is Used in Round 2

When Spoiler challenges with t in (e_{n-1}, e_n) in M:
1. M |= A(t) (because A holds on the interval by the U(B,A) witness extraction)
2. A(t) means t has the same rank-r type as some point v in (a_{n-1}, a_n) in N
3. Duplicator responds with such a v
4. Since t and v have the same rank-r type, they agree on all rank-r formulas (winning condition)

### 3.5 Can A Be Materialized as a StaviFormula?

**Yes, in principle.** The current Lean code already has `nf_characterizable_by_stavi` which produces a StaviFormula for each 1-var depth-k NormalForm. The A formula would be:

```lean
A = sf_disjList (types_in_interval.map char_k)
```

where `types_in_interval` is the list of depth-k NFs realized by points in the interval, and `char_k` maps each NF to its characteristic StaviFormula.

**The blocker** is that `char_k` produces formulas of Stavi depth approximately related to the NF quantifier depth k, not directly to the "rank r" parameter in GHR93. The relationship between NF quantifier depth k and temporal formula rank r is mediated by the NF-to-Stavi bridge. If we set k = r (which is the natural choice), then each `char_k nf` has some Stavi depth that is bounded but not necessarily exactly r.

**Alternative**: The `rank_type` definition in `TypeFormulas.lean` already defines X_t as a Set of StaviFormulas (the predicative/semantic version). The question is whether we need a SYNTACTIC StaviFormula representing X_t (for use inside U(B,A)) or whether we can work at the semantic level (using `stavi_temporal_truth_mu` agreement directly).

---

## 4. The left(A, D) and right(A, D) Formulas

### 4.1 Definition (GHR93 Def. 8.5 / GHR94 Def. 12.8.6)

left(A, D) is defined by structural induction on A:

| A | left(A, D) | Rank |
|---|-----------|------|
| atom p | bot | 0 |
| neg A | U'(top, D) and not-left(A, D) | max(rk(A), rk(D)) + 2 |
| A and B | left(A, D) and left(B, D) | max(rk(A), rk(B), rk(D)) + 2 |
| U(A, B) | U'(B and U(A,B), D) | max(rk(A), rk(B), rk(D)) + 2 |
| U'(A, B) | U'(B and U'(A,B), D) | max(rk(A), rk(B), rk(D)) + 2 |
| S(A, B) | U(D and B and S(A,B) and U'(top, B and D) and not-U'(D, B and D), D) | max(rk(A), rk(B), rk(D)) + 2 |
| S'(A, B) | U(D and B and S'(A,B) and U'(top, B and D) and not-U'(D, B and D), D) | max(rk(A), rk(B), rk(D)) + 2 |

right(A, D) is the dual: swap U <-> S and U' <-> S' throughout.

### 4.2 Rank Bound

**rank(left(A, D)) <= max(rank(A), rank(D)) + 2.**

This is the critical bound. In Cases III/IV:
- rank(B) = r, rank(D) <= r
- So rank(left(B, D)) <= r + 2
- And rank(right(B, D)) <= r + 2

### 4.3 Lemma 9 (GHR94 Lemma 12.8.7)

Lemma 9 is the correctness theorem for left/right. For m in M_r:

**M_r |= left(A, D)(m)** iff there exists a gap gamma in M_r (not +/-infinity), gamma defined by D on the left, with:
- (a) gamma > m
- (b) D holds in M on (m, gamma)
- (c) M_r |= A^mu(gamma)

This is the bridge that converts gap-properties (evaluated at gaps via mu-relativization) into properties of actual points (where left(A,D) is a plain temporal formula evaluable at points).

### 4.4 Why Cases III/IV Need left/right

In Case II, a_n is a point, so U(B, A)(a_{n-1}) directly witnesses the existence of a point e_n with B(e_n). But in Cases III/IV, a_n is a GAP. The formula U'(B, A) does NOT say that B^mu holds at the gap -- it says something about the gap's neighborhood. To detect "B^mu holds at a gap defined by D on the left," we use left(B, D).

Specifically:
- left(B, D)(t) at an actual point t means: there is a D-left-gap above t with B^mu true at it
- This converts the "gap has property B" statement into a formula evaluable at ordinary points

---

## 5. Rank Budget Summary Across All Cases

| Formula | Rank | Where Used |
|---------|------|-----------|
| A = X_{(a_{n-1}, a_n)} | r | All cases: interval type |
| C = X_{(a_n, y')} | r | Setup: continuation formula |
| C' = not-C or K^-(not-C) | r + 1 | Claim 1: d-consistency |
| B = X_{a_n} | r | Cases II-IV: type at a_n |
| U(B, A) | r + 1 | Case II: point witness |
| left(B, D) | r + 2 | Case III: gap detection |
| delta_III = left(B, D) | r + 2 | Case III |
| U(delta_III, A) | r + 3 | Case III: gap reachability |
| right(B, D) | r + 2 | Case IV: gap detection |
| delta_IV = A and not-D and U(right(B,D), A) | r + 3 | Case IV: compound detection |
| U(delta_IV, A) | **r + 4** | Case IV: MAX RANK FORMULA |

**The rank budget r + 4(n+1) in the forward game provides**: at the IH level, backward strategies at rank r + 4. The formulas in Cases I-IV all have rank <= r + 4, which is exactly the preservation range of sigma/tau.

---

## 6. The Finiteness Argument

### 6.1 How GHR93 Establishes Finiteness

GHR93 (p.112 / GHR94 p.638) states:

> "This conjunction is effectively finite, as because L is finite there are up to logical equivalence only finitely many distinct formulae of any rank."

The argument is:

1. **L is finite** (finitely many propositional atoms).
2. **By induction on rank r**: there are finitely many inequivalent temporal L-formulas of rank <= r.
   - Rank 0: Boolean combinations of finitely many atoms. Finitely many up to equivalence.
   - Rank r+1: Built from rank-r formulas using U, S, U', S'. Since there are finitely many inequivalent rank-r formulas, there are finitely many pairs (A, B) to plug into U(A,B), etc. Hence finitely many rank-(r+1) formulas up to equivalence.
3. **X_t is a conjunction** of representatives from finitely many equivalence classes: specifically, one from each class where the representative is true at t. This is a finite conjunction.
4. **X_{(t,u)} is a disjunction** of finitely many X_v's (one per distinct type realized in the interval). Since types are finitely many (step 2), this is a finite disjunction.

### 6.2 Is the Enumeration Explicit or Abstract?

**Abstract.** GHR93 does not construct an explicit enumeration of formulas. The proof uses:
- Classical logic: "there are finitely many equivalence classes" (existential).
- The axiom of choice (implicit): pick a representative from each class.

The statement "effectively finite" refers to the decidability/computability claim later (p.121 / GHR94 p.730): the translation is effective because the universal monadic second-order theory of linear order is decidable (Gurevich's result), so one can algorithmically determine which types are consistent.

### 6.3 How the Lean Code Handles Finiteness

The Lean code uses the NormalForm machinery:
- `NormalForm sig k n` is a Fintype (proven in NormalForm.lean).
- `Fintype.card (NormalForm sig k 1)` is the number of distinct depth-k 1-variable types.
- `nf_characterizable_by_stavi` provides, for each NormalForm, a StaviFormula characterizing it.

The correspondence is:
- GHR93's "equivalence class of rank-r formulas" <-> Lean's `NormalForm sig r 1`
- GHR93's "X_t" <-> Lean's `rank_type M atomMap r t` (as a set of StaviFormulas)
- GHR93's "effectively finite" <-> Lean's `Fintype (NormalForm sig r 1)`

### 6.4 The Depth-Agreement Gap

There is a known mismatch between GHR93's "rank r" and the Lean code's "NormalForm depth k":

- In GHR93, rank is the maximum nesting depth of temporal connectives.
- In Lean, `stavi_depth` counts nesting of temporal connectives in StaviFormula.
- `nf_characterizable_by_stavi` builds a StaviFormula for each NormalForm, but the depth of this formula is NOT necessarily equal to the NormalForm's quantifier depth k. The formula involves nested Until/Since connectives for the existential quantifiers in the NormalForm, so its depth is typically larger than k.

This means: the StaviFormula produced by `char_k nf` for a depth-k NormalForm has Stavi depth approximately 2k (not k). When used inside U(B, A) as U(char_k nf_an, sf_top), the resulting formula has depth approximately 2k + 1. If tau only preserves rank r + 4 formulas, and 2k + 1 > r + 4, the transfer fails.

**This is the "depth-agreement gap" documented in reports 38 and 45.**

---

## 7. What Lean Infrastructure Is Needed

### 7.1 For X_t (Already Partially Present)

**Existing**:
- `rank_type` in TypeFormulas.lean -- the semantic version (a Set of StaviFormulas)
- `rank_type_eq_iff` -- positions with same rank_type agree on all depth-r formulas
- `interval_types` -- set of types realized in an interval
- `nf_characterizable_by_stavi` -- for each NormalForm, a characteristic StaviFormula

**Needed for direct construction bypass**:
1. **`x_t_formula : ExtendedCarrier M atomMap r -> StaviFormula`** -- a function producing a single StaviFormula X_t for each position, such that stavi_temporal_truth_mu evaluates it correctly. This requires materializing the conjunction.
2. **`x_t_correct`** -- the correctness theorem: `stavi_temporal_truth_mu M atomMap r u (x_t_formula t) <-> rank_type M atomMap r u = rank_type M atomMap r t`.
3. **`x_interval_formula : ExtendedCarrier -> ExtendedCarrier -> StaviFormula`** -- materializing X_{(t,u)} as a disjunction.
4. **`x_interval_correct`** -- if A = x_interval_formula t u and M_r |= A(w), then there exists a point v in (t,u) with rank_type_eq v w.

### 7.2 For U(B, A) Transfer (The Critical Path)

**Option 1: Syntactic materialization.** Build X_t as a StaviFormula, build U(B,A) as a StaviFormula, prove it has the right depth, and transfer through tau.

- Requires: x_t_formula with controlled depth
- Blocker: depth of char_k formulas may exceed the rank budget

**Option 2: Semantic bypass.** Instead of materializing U(B,A) as a syntactic formula, work entirely at the level of `stavi_temporal_truth_mu` agreement. The winning condition of tau gives formula agreement for ALL formulas up to rank r+4. If we can show that the semantic content of "U(B,A) holds" is captured by some formula of rank <= r+4 (even without explicitly naming it), the transfer goes through.

- This is the approach Report 45 calls the "semantic-vs-syntactic B" resolution
- Requires: a "universally quantified" transfer lemma over the winning condition

**Option 3: Restructure the induction.** Make delta = 4 (matching GHR93's rank budget exactly), so tau preserves rank r+4 formulas. Then U(B,A) at rank r+1 transfers trivially.

- This is Report 39's recommendation
- Requires: restructuring game_depth and the induction step

### 7.3 For left(A, D) / right(A, D) (Cases III/IV Only)

**Not present in the codebase.** The GapDetection.lean file exists but contains definitions, not left/right.

**Needed**:
1. `left_formula : StaviFormula -> StaviFormula -> StaviFormula` -- structural induction on A
2. `right_formula : StaviFormula -> StaviFormula -> StaviFormula` -- dual
3. `left_rank_bound` -- rank(left(A,D)) <= max(rank(A), rank(D)) + 2
4. `left_correct` (Lemma 9) -- the equivalence between left(A,D)(m) and the gap-existence statement
5. `right_correct` -- dual

**Effort estimate**: 200-300 lines for definitions + rank bounds + correctness.

**For Z-specific (discrete) orders**: Cases III/IV are vacuous (no gaps exist on Z), so left/right are NOT needed. The entire proof reduces to Cases I and II.

### 7.4 For the Finiteness Argument

**Already present**: NormalForm Fintype instance, nf_characterizable_by_stavi.

**Needed**: Bridging from `NormalForm sig k 1` (which counts distinct types at quantifier depth k) to `rank_type` (which is defined via stavi_temporal_truth_mu at a specific rank r). The bridge needs to ensure that the number of distinct rank-r types equals `Fintype.card (NormalForm sig r 1)` (or is bounded by it).

---

## 8. Summary: Decision Matrix for Direct X_t Construction

### Can we bypass `nf_characterizable_by_stavi` and construct X_t directly from StaviFormulas?

| Aspect | Via NF Bridge | Direct Construction |
|--------|--------------|-------------------|
| X_t as a Set | Already have `rank_type` | Same |
| X_t as a Formula | Use `char_k` per NF, build conjunction | Build conjunction of all depth-r StaviFormulas true at t |
| Finiteness | Fintype NormalForm guarantees finite conjunction | Need to enumerate depth-r StaviFormulas (harder) |
| Depth control | char_k depth may exceed r | Direct formulas have depth exactly r |
| U(B,A) depth | char_k-based B has depth > r, so U(B,A) depth > r+1 | Direct B has depth r, U(B,A) has depth r+1 |
| Rank budget fit | Does NOT fit: char_k depth too large for tau at rank r+4 | FITS: r+1 <= r+4 |
| Implementation effort | ~100 lines (bridge) but depth gap blocks it | ~200-300 lines (new enumeration) but clean rank bounds |

### Recommendation

**Direct construction is architecturally correct** for matching GHR93's proof. The NF bridge was designed for the compositional (Proposition 7) path, not for the formula-materialization path needed by Theorem 6. The direct approach:

1. Enumerate all StaviFormulas of depth <= r up to equivalence (using the NormalForm count as an abstract bound).
2. For each, evaluate at t via `stavi_temporal_truth_mu`.
3. Conjoin those that evaluate to true -> this IS X_t, with depth exactly r.
4. Build U(B, A) with depth r+1 and transfer through tau at rank r+4.

**However**, the "enumerate all StaviFormulas of depth <= r" step is non-trivial in Lean because StaviFormula is an inductive type (not a Fintype). The cleanest path is:

1. Use `NormalForm sig r 1` as the finite enumeration of types (which IS a Fintype).
2. Use `nf_characterizable_by_stavi` to get a StaviFormula `char_r nf` for each NF.
3. Define B = char_r (nf_characteristic_mu M r t) -- the StaviFormula characterizing the NF of t.
4. Accept that `stavi_depth (char_r nf)` may be larger than r, but prove that `stavi_temporal_truth_mu` at rank r agrees with `stavi_temporal_truth_mu` at rank `stavi_depth (char_r nf)` (which is true because mu-relativized truth is independent of the rank of the carrier, per `rank_embed_stavi_truth_mu`).
5. The formula U(B, A) then has some depth d > r+1, but what matters is that its SEMANTIC CONTENT is preserved by tau at rank r+4. This requires showing that tau's formula agreement at rank r+4 implies agreement on U(B, A) despite B having depth > r.

**This last step is the remaining open question.** It is essentially: does depth-k agreement for k >= r+4 imply agreement on U(char_r nf, X_interval) even though char_r nf may have depth > r? The answer depends on whether `stavi_temporal_truth_mu` for char_r nf depends only on depth-r information (which it does, by the NF characterization theorem).
