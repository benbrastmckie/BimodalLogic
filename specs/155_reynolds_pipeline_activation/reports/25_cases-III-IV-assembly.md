# Research Report: GHR93 Cases III/IV and the Assembly Chain

## 1. Cases III and IV of Theorem 6

### 1.1. Case III: a_n is a left-defined gap (GHR93 p.30-31, Page 30-31)

**Hypothesis**: All points alpha_0, ..., alpha_n lie in (d, y')_r, and alpha_n is a gap defined on the left by some formula D of rank <= r.

**Proof argument** (GHR93 pp.117-118):

1. **Setup**: Since alpha_n is defined on the left by D, and the formula A holds on the interval (alpha_{n-1}, alpha_n), we can assume D |- A (D implies A, or more precisely, alpha_n is also defined by A /\ D). Set B = X_{alpha_n} (the type descriptor for alpha_n).

2. **Define delta**: delta = M's version of `left(B, D)` -- a formula of rank <= r + 2. The key fact is N_r |= U(delta, A)(alpha_{n-1}), i.e., there is a point above alpha_{n-1} where delta holds, with A holding in between. (If n = 0, take alpha_{n-1} to be d.)

3. **Define auxiliary points in N**:
   - d' = sup{t in (x', y') : N |= ~D(t)} -- the last point where D fails
   - g' = sup{t in (x', d') : N |= delta(t)} -- the last delta-point below d'

4. **Define d, g similarly in M_r** (at rank r+2). Key: alpha_n < d' and the U(delta, A)(alpha_{n-1}) witness t' satisfies t' < g'.

5. **Derive sub-interval strategies**: Using the same argument as Claims 1-2 (strategy restriction with c, g, d added to Spoiler's choices), Duplicator has a winning strategy for G_{1+3n; r+4(n+1)}(M, cg; N, dg'). By (**)_n, she gets a winning strategy for G_{n; r+4}(N, dg'; M, cg).

6. **Duplicator's response**: Apply the backward strategy to alpha_0, ..., alpha_{n-1} to get e_0, ..., e_{n-1} in (c, g)_r. Since rank r+4 formulas are preserved, M_r |= U(delta, A)(e_{n-1}). Since e_{n-1} < g, we can choose t < g in M with M |= delta(t), with A holding on (e_{n-1}, t].

7. **Invoke Lemma 9** (left direction): By definition of delta and Lemma 9, there is a gap e_n in (t, d)_r defined by D on the left, such that A holds between t and e_n. Moreover, any rank r formula holds at e_n iff it holds at alpha_n (both satisfy B). Duplicator chooses e_n as her response to alpha_n.

8. **Remainder**: Same argument as Case I -- the remaining game play uses sigma/tau on the sub-intervals.

**Key dependencies**:
- `left_formula_gap_detection` (Lemma 9, left direction) -- currently sorry'd at EFGames.lean:2728
- `stavi_untl_gap_detection` -- partially proved, used inside Lemma 9 
- The formula `delta = left(B, D)` with rank bound `stavi_depth delta <= r + 2`
- The backward strategy from (**)_n on the sub-interval (c, g) vs (d, g')
- Strategy restriction to get G_{1+3n; r+4(n+1)}(M, cg; N, dg')

### 1.2. Case IV: a_n is a gap NOT left-defined (GHR93 p.31, Page 31)

**Hypothesis**: alpha_0, ..., alpha_n in (d, y'), alpha_n not in N (is a gap), and alpha_n is NOT definable on the left by any formula of rank <= r.

**Proof argument** (GHR93 pp.119):

1. **Key consequence**: Since alpha_n is not left-defined, A holds throughout some interval *containing* alpha_n (the gap has no left-boundary detectable by any rank-r formula). Choose D of rank <= r defining alpha_n on the RIGHT.

2. **Define B and delta**: B = X_{alpha_n}. delta = A /\ ~D /\ U(right(B, D), A) -- rank r + 3.

3. **Define auxiliary points in N**:
   - d' = sup{t in (x', y') : N |= right(B, D)(t)} -- last right-detection point
   - g' = sup{t in (x', d') : N |= delta(t)} -- last delta-point below d'

4. **Define d, g similarly in M_r** (at rank r+3).

5. **Witnesses in N**: There exist alpha_{n-1} < t' < alpha_n < u' < y' with t', u' in N, N |= delta(t'), N |= right(B, D)(u'), and A holding on (t', u'). Hence t' < g' and u' < d'.

6. **Derive sub-interval strategies**: As usual, Duplicator has a winning strategy for G_{1+3n; r+4(n+1)}(M, cg; N, dg'), giving G_{n; r+4}(N, dg'; M, cg) by (**)_n.

7. **Duplicator's response**: Use backward strategy on alpha_0, ..., alpha_{n-1} to get e_0, ..., e_{n-1}. Since U(delta, A) has rank < r + 4, M_r |= U(delta, A)(e_{n-1}). Choose e_{n-1} < t < g with M |= delta(t), and A on (e_{n-1}, t). Then choose u in M with t < u < d, M |= right(B, D)(u), and A on (e_{n-1}, u).

8. **Invoke Lemma 9** (right direction): By Lemma 9 there is a gap e_n in (t, u) defined by D on the right, at which the same relativised rank r formulas hold as at alpha_n. (e_n > t because M |= ~D(t).)

9. **Remainder**: Same as before.

**Key dependencies**:
- `right_formula_gap_detection` (Lemma 9, right direction) -- sorry'd at EFGames.lean:3137
- `stavi_snce_gap_detection` -- sorry'd at EFGames.lean:3109
- The formula `delta = conj A (conj (neg D) (stavi_untl (right_formula B D) A))` with rank bound
- Strategy restriction to sub-interval (c, g) vs (d, g')

### 1.3. Case III vs Case IV: The Structural Difference

| Aspect | Case III | Case IV |
|--------|----------|---------|
| Gap type | Left-defined by D | NOT left-defined; right-defined by D |
| Detection formula | `left(B, D)` | `right(B, D)` |
| Delta formula | `left(B, D)` (rank r+2) | `A /\ ~D /\ U(right(B,D), A)` (rank r+3) |
| Gap location | (t, d) -- between delta-witness and right boundary | (t, u) -- between two actual points |
| Lemma 9 direction | Left direction | Right direction |
| Rank overhead | rank r+2 for delta | rank r+3 for delta |

### 1.4. D-Consistency and Cases III/IV

**Question**: Is d-consistency (Claim 1) needed for Cases III/IV?

**Answer**: YES, but INDIRECTLY. Claim 1 is used in the *setup* phase (constructing the split point d and showing it is the unique response to c). It is part of `obtain_split_point_props` and Claim 2 (strategy restriction). All four cases share the same setup -- they all use sigma and tau from the split point construction. The case-specific argument happens *after* the setup, so Cases III/IV do not directly invoke Claim 1. However, they rely on the backward strategies sigma and tau which *were* obtained using Claim 1 + Claim 2.

In the current Lean code, this is reflected by:
- `obtain_split_point_props` provides `SplitPointProps` including sigma and tau
- `ghr93_cases_III_IV` takes `SplitPointProps` as input (already contains sigma/tau)
- The d-consistency sorries (lines 1157, 1235) are in `obtain_split_point_props`, NOT in the case lemmas

## 2. The Assembly Chain

### 2.1. Theorem 6 (Uniform Rank) -> Rank-Varying Theorem 6

**GHR93 Statement**: (*)_n: For all r, if Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y'), then she wins G_{n; r}(N, x'y'; M, xy).

**Current Lean** (`ghr93_forward_to_backward`, line 3658): The uniform-rank version uses rank r throughout both games. The rank-varying version (`ghr93_forward_to_backward_rank_varying`, line 3775) should derive from:
1. `rank_embed` to lift positions from rank r to rank r+4n
2. Apply the uniform-rank theorem at rank r+4n  
3. Show the backward strategy at rank r+4n restricts to rank r

**Blocker**: The rank-varying version is sorry'd (line 3793). Its proof needs:
- `rank_embed` properties (monotone, preserves gap/point status, preserves formula agreement at lower rank)
- Lemma 10 for rank monotonicity (already available as `ghr93_duplicator_wins_round_mono`)

**Approach**: The forward game hypothesis at rank r+4n already matches what the uniform-rank theorem expects. The backward game at rank r+4n gives formula agreement at rank r+4n, which implies agreement at rank r (trivially). The key subtlety is that the backward game at rank r only considers elements from M_r and N_r, while the backward game at rank r+4n considers M_{r+4n}. We need to show that Duplicator's strategy restricted to selecting from M_r gives valid responses in N_r.

### 2.2. Proposition 6 (GHR93 p.25-26, Page 25-26)

**Statement**: Let M, N be linear temporal structures and x in M, y in N. If x and y satisfy the same temporal formulas of rank r + 4n + 1, then Duplicator has winning strategies for:
- G_{n;r}(M, -inf x; N, -inf y) (past game)  
- G_{n;r}(M, x inf; N, y inf) (future game)

**Proof sketch** (from GHR93): When Spoiler chooses n points x < alpha_1 < ... < alpha_n in the future of x:
- Define C_n = X_{alpha_n} /\ ~U(~X_{alpha_n}, T) [captures "alpha_n has type B and nothing after it has a different type"]
- For i < n, C_i = X_{alpha_i} /\ U(C_{i+1}, X_{(alpha_i, alpha_{i+1})}) [captures the chain of types]
- rank(C_i) = r + n + 1 - i, so rank(C_0) <= r + n + 1
- Since M |= C_0(x) and x, y agree on formulas of rank r + 4n + 1 >= r + n + 1, N |= C_0(y)
- Duplicator uses C_0 to construct matching points e_0 < ... < e_n in N

**When some alpha_i are gaps**: The argument uses left(X_{alpha_i}, D) or right(X_{alpha_i}, D) in place of the simple formula, with rank bound C_0 <= r + 4n + 1 (the worst case: gaps add +3 per selection, times n selections, plus the base).

**What's needed in Lean**:
- A new theorem, likely `ghr93_proposition_6` or `formula_agreement_to_half_line_game`
- Statement: formula agreement at rank r + 4n + 1 implies `ghr93_duplicator_wins` on half-line intervals
- Proof uses the C_i chain construction (inductive on n) + Lemma 9 for gap cases
- Estimated ~100-150 lines

### 2.3. Proposition 7 (GHR93 p.26-27, Page 26-27)

**Statement**: Let f, g be growth functions with f(0)=g(0)=0, f(n+1)>(1+3f(n))*(2k_n)+1, g(n+1)>g(n)+4f(n), where k_n = number of inequivalent (1+3f(n));(g(n)+4f(n))-decomposition formulas. Let x_1 < ... < x_m in M and y_1 < ... < y_m in N (with x_0=-inf, x_{m+1}=inf, similarly for y).

If Duplicator wins G_{f(n+1); g(n+1)}(M, x_i x_{i+1}; N, y_i y_{i+1}) AND G_{f(n+1); g(n+1)}(N, y_i y_{i+1}; M, x_i x_{i+1}) for all i, then she wins the full Ehrenfeucht-Fraisse game G_n((M,x), (N,y)).

**Proof** (induction on n, GHR93 p.26-27):
1. Base n=0: trivial
2. Inductive step: Assume true for n. Let r = g(n) + 4f(n) < g(n+1). Suppose winning strategies for G_{f(n+1);g(n+1)} in both directions on each sub-interval.
3. V begins G_{n+1}((M,x),(N,y)) by choosing alpha in M (WLOG). If alpha = x_i, respond with y_i (use IH + Lemma 10).
4. Otherwise x_i < alpha < x_{i+1} for some i. List the (1+3f(n));r-decomposition formulas true at (x_i, alpha) and (alpha, x_{i+1}).
5. Choose witnesses for each decomposition formula, plus alpha itself, making at most n_1 = (1+3f(n))*(j+k)+1 < f(n+1) elements total.
6. Apply the forward strategy G_{f(n+1); g(n+1)}(M, x_i x_{i+1}; N, y_i y_{i+1}) with these n_1 elements. Let e be the response to alpha.
7. **By Lemma 11** (cf. comment in paper): N_r agrees on all (1+3f(n));r-decomposition formulas at (y_i, e) and (e, y_{i+1}). By Lemma 11 backward, Duplicator wins G_{1+3f(n);r}(M, x_i alpha; N, y_i e) and G_{1+3f(n);r}(M, alpha x_{i+1}; N, e y_{i+1}).
8. **By Theorem 6** (crucially): Duplicator also wins G_{f(n);g(n)}(N, y_i e; M, x_i alpha) and G_{f(n);g(n)}(N, e y_{i+1}; M, alpha x_{i+1}).
9. By IH, Duplicator wins G_n((M, x + alpha), (N, y + e)). Strategy: respond with e, then follow sigma.

**Does Proposition 7 need Lemma 11 backward?**

YES. Step 7 explicitly uses "Clearly (cf. Lemma 11)" to establish that N_r agrees on decomposition formulas at (y_i, e) and (e, y_{i+1}). Then "By Lemma 11, Duplicator has a winning strategy for G_{1+3f(n);r}..." This is the BACKWARD direction of Lemma 11: decomposition agreement implies game winning strategy.

In Lean, this corresponds to `ghr93_decomposition_implies_game` (EFGames.lean:4190), which is sorry'd.

### 2.4. Corollary 5 = `stavi_expressive_completeness` (GHR93 p.27, Page 27)

**Statement**: If x in M and y in N satisfy the same temporal formulas of rank g(n+1)+1, then for all monadic FO formulas phi of quantifier depth <= n, M |= phi(x) iff N |= phi(y).

**Proof**: By Propositions 5, 6, 7 (one line).

The argument:
1. Proposition 6 + formula agreement at rank g(n+1)+1 gives Duplicator winning G_{f(n+1); g(n+1)} on each half-line interval (both directions by symmetry).
2. Proposition 7 composes these into a full EF game win G_n((M,x), (N,y)).
3. Proposition 5 (standard EF theorem) converts the game win into first-order equivalence at depth n.

**Then**: Expressive completeness follows by a finitary argument -- partition the space of rank g(n+1)+1 formulas into finitely many complete types, and for each type consistent with phi, the type implies phi (by Corollary 5). So phi is equivalent to a disjunction of types, each of which is a temporal formula of bounded rank.

**What's needed in Lean**:
- Proposition 5 (standard EF game theorem): likely already available or easy to state for the specific game type
- Composition of Props 5 + 6 + 7
- The final "expressive completeness" argument wrapping these together
- Estimated ~80-120 lines for Corollary 5

## 3. Rank Handling in the Paper vs. Lean

### 3.1. Paper's Statement (GHR93 Theorem 6)

(*)_n: For all r, if Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y'), then she wins G_{n; r}(N, x'y'; M, xy).

The forward game uses rank **r+4n**, the backward game uses rank **r**. In the inductive step (n -> n+1):
- Forward hypothesis: rank r+4(n+1) = r+4n+4
- Apply (**)_n (IH) on sub-intervals at rank r+4, to get backward at rank r+4
- The case analysis (Cases I-IV) operates at rank r

### 3.2. Current Lean: Uniform vs. Varying

The uniform-rank version (`ghr93_forward_to_backward`, line 3658) uses rank r for BOTH games:
- Forward: G_{1+3n; r}(M, xy; N, x'y')
- Backward: G_{n; r}(N, x'y'; M, xy)

This is a **weaker** result than the paper (stronger hypothesis), but sufficient for the inductive step because:
- IH at sub-intervals also uses uniform rank
- Strategy restriction preserves the uniform rank

The rank-varying version (`ghr93_forward_to_backward_rank_varying`, line 3775) derives from uniform-rank + rank embedding. The key insight:

1. Given: Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y') at rank r+4n
2. Apply uniform-rank Theorem 6 at rank r+4n -> Duplicator wins G_{n; r+4n}(N, x'y'; M, xy) at rank r+4n
3. Rank monotonicity: winning at rank r+4n >= r implies winning at rank r

Step 3 requires showing that elements of M_r are a subset of M_{r+4n} (which holds -- higher rank adds more gaps), and the winning condition at rank r+4n implies the condition at rank r (since rank-r formulas are a subset of rank-(r+4n) formulas).

### 3.3. What the Assembly Needs

For Proposition 7 / Corollary 5, the rank-varying version IS needed:
- Prop 7 calls Theorem 6 with forward game at rank g(n+1) and backward game at rank g(n)
- The growth function ensures g(n+1) > g(n) + 4f(n), matching the r+4n offset

## 4. Dependency Analysis: What Needs What

### 4.1. Critical Path for Cases III/IV

```
left_formula_gap_detection (Lemma 9 left)     -- EFGames.lean:2728, sorry
right_formula_gap_detection (Lemma 9 right)   -- EFGames.lean:3137, sorry
    |
    v
ghr93_cases_III_IV (line 3572, sorry)
    |
    v
ghr93_inductive_step (line 3607, currently works if cases compiled)
    |
    v
ghr93_forward_to_backward (line 3658, currently compiles)
```

### 4.2. Critical Path for Assembly

```
ghr93_forward_to_backward (uniform rank)
    |
    v
ghr93_forward_to_backward_rank_varying (line 3775, sorry)
    +
ghr93_decomposition_implies_game (Lemma 11 backward, line 4190, sorry)
    |
    v
Proposition 6 (NEW, ~100-150 lines)
    +
Proposition 7 (NEW, ~150-250 lines, needs Lemma 11 backward + Theorem 6 rank-varying)
    |
    v
Corollary 5 = stavi_expressive_completeness (line 5493, sorry)
```

### 4.3. Sorries Blocking the Path

| Sorry Location | What | Needed For | Estimated Effort |
|---------------|------|-----------|-----------------|
| EFGames:2728 | `left_formula_gap_detection` | Cases III/IV | 200-300 lines (sub-induction on A) |
| EFGames:3109 | `stavi_snce_gap_detection` | `right_formula_gap_detection` | ~100 lines |
| EFGames:3137 | `right_formula_gap_detection` | Case IV | 200-300 lines (dual of left) |
| ExpGen:3572 | `ghr93_cases_III_IV` | Theorem 6 inductive step | 200-350 lines (case split + Lemma 9 application) |
| ExpGen:3793 | `ghr93_forward_to_backward_rank_varying` | Proposition 7 | 80-150 lines (rank embed + uniform) |
| EFGames:4198 | `ghr93_decomposition_implies_game` | Proposition 7 | 80-120 lines |
| EFGames:5500 | `stavi_expressive_completeness` | Final goal | 80-120 lines (Props 5+6+7 composition) |

### 4.4. Sorries NOT on the Critical Path (for assembly)

| Sorry Location | What | Why Not Blocking |
|---------------|------|-----------------|
| ExpGen:1157 | `d_consistency_left` interior | Blocks `obtain_split_point_props` which blocks ALL cases. Already a known Phase 4C-W1 blocker. |
| ExpGen:1235 | `d_consistency_right` interior | Same as above |
| ExpGen:1547 | `h_pt_xc` degenerate gap | SplitPointProps restructuring needed |
| ExpGen:1564 | `h_pt_cy` degenerate gap | Same |
| ExpGen:1668 | c-gap-case in `obtain_split_point_props` | Needs Lemma 9 (same dependency as Cases III/IV) |

## 5. Recommendations

### 5.1. For Phase 4C-W3 (Cases III/IV)

1. **Split `ghr93_cases_III_IV`** into two lemmas: `ghr93_case_III` (left-defined gap) and `ghr93_case_IV` (not left-defined gap). The dispatch is on whether the gap `a_bwd(n)` is left-definable.

2. **Case III proof structure** (~120-180 lines):
   - Extract D from the left-definability hypothesis
   - Define B = rank_type of a_bwd(n), delta = left(B, D)
   - Use tau (from SplitPointProps) to get e_0, ..., e_{n-1}
   - Show M_r |= U(delta, A)(e_{n-1}) by formula preservation of tau
   - Find t < g in M with M |= delta(t) and A on (e_{n-1}, t]
   - Apply `left_formula_gap_detection` to get gap e_n
   - Verify winning condition

3. **Case IV proof structure** (~120-180 lines):
   - Extract D from right-definability (and NOT left-definability)
   - Define B, delta = A /\ ~D /\ U(right(B,D), A)
   - Same structure as Case III but using right direction
   - Apply `right_formula_gap_detection` to get gap e_n

4. **Prerequisite**: Lemma 9 (`left_formula_gap_detection` and `right_formula_gap_detection`) MUST be proved first. This is the hard part (~400-600 total lines across both directions).

### 5.2. For Phase 4C-W4 (Assembly)

1. **Rank-varying Theorem 6** (Task W4.1): Straightforward derivation from uniform-rank + rank_embed. The proof should:
   - Apply uniform-rank theorem at rank r+4n
   - Use rank_embed properties to show backward strategy at r+4n restricts to r
   - Key lemma needed: `ghr93_duplicator_wins_rank_mono` (rank monotonicity for winning)

2. **Lemma 11 backward** (Task W4.2): NEEDED. The proof constructs Duplicator's strategy from decomposition agreement:
   - Round 1: use the forward matching from decomposition_agreement
   - Round 2: use the backward matching to find a type-matching point for any challenge
   - Estimated 80-120 lines

3. **Proposition 6** (Task W4.3): New theorem. Uses formula agreement at high rank to win half-line games. The proof constructs the C_i chain inductively.

4. **Proposition 7** (Task W4.4): The composition lemma. Uses:
   - Lemma 11 forward (already proved: `ghr93_game_implies_decomposition`)
   - Lemma 11 backward (`ghr93_decomposition_implies_game` -- sorry'd)
   - Theorem 6 rank-varying
   - Induction on n with decomposition formula counting

5. **Corollary 5** (Task W4.5): Composition of Props 5 + 6 + 7. Relatively straightforward once Props 6-7 exist.

### 5.3. Proposed Execution Order

```
1. Lemma 9 (left + right) -- PREREQUISITE for everything
2. Cases III/IV -- unblocks Theorem 6 fully
3. Rank-varying Theorem 6 -- straightforward derivation
4. Lemma 11 backward -- needed for Prop 7
5. Proposition 6 -- half-line games
6. Proposition 7 -- composition
7. Corollary 5 -- final assembly
```

Total estimated effort: 1200-2000 lines of new proof code.
