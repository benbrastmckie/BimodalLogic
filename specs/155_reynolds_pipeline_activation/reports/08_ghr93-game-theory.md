# GHR93 Game-Theoretic Proof of Expressive Completeness

## Scope

Technical extraction from GHR93 Section 8 (pp. 108-121 of the gaps paper;
Chapter 9 Definitions 8.1-8.9, Theorem 6, Propositions 6-7 of the book).
Covers the custom EF game G_{n;r}, the depth function f(n), all four cases
of the main induction, the composition lemma, and the left/right gap
detection formulas.

---

## 1. Definitions and Setup (Def. 8.1-8.5)

### 1.1 Rank of a Temporal Formula (Def. 8.2)

The **rank** of a temporal formula A is the maximum depth of nesting of
temporal connectives (U, S, U', S'). For a finite atom set L, there are
finitely many inequivalent formulas of each rank.

### 1.2 Gaps and M_r (Def. 8.3)

Given a linear temporal structure M = (T, <, h):

- A **gap** gamma is a Dedekind cut in T with no supremum: a non-empty
  downward-closed proper subset of T whose complement has no minimum.
- Gap gamma is **definable on the left by D** if D holds throughout some
  non-empty interval (t, gamma) immediately left of gamma, and D does NOT
  hold throughout any non-empty interval (gamma, t') immediately right.
- **Definable on the right** is symmetric.
- An **r-definable gap** is one definable by a formula of rank at most r.
- **M_r** = M union {r-definable gaps of M}, with induced ordering. So
  M subset M_0 subset M_1 subset ...

### 1.3 Relativised Connectives (Def. 8.4)

Introduce a new atom mu with h'(mu) = M (the set of actual points, not
gaps). Define U^mu, S^mu, U'^mu, S'^mu as the connectives whose tables
are the relativisation of the standard tables to mu. Concretely:

- U^mu(A,B) holds at t in M_r iff there exists a **point** s > t (s in M)
  where A holds, with B holding at all **points** u in (t,s).
- Similarly for S^mu, U'^mu, S'^mu.

For any temporal formula A, let A^mu be A with all connectives replaced by
their mu-relativised versions.

**Key facts:**
1. If t is in M, then M |= A(t) iff M_r |= A^mu(t).
2. If A = S'(B,C) with C of rank <= r, and M_r |= A^mu(t), then the gap
   asserted by A actually lies in M_r (since C defines it on the right).

### 1.4 X_t and X_{(t,u)} Formulas (Def. 8.8)

For t in M_r, define:

- **X_t** = conjunction of all temporal L-formulas X of rank <= r such that
  M_r |= X^mu(t). This is effectively finite. X_t has rank r.
- **X_{(t,u)}** = disjunction of X_v for all points v in open interval (t,u).
  Again effectively finite, rank r.

These are the "type" formulas: X_t describes the complete rank-r theory
at position t, and X_{(t,u)} describes the set of rank-r types realized in
the open interval.

### 1.5 The left() and right() Formulas (Def. 8.5, Lemma 9)

These convert properties of gaps into properties of actual points.

**Definition.** For temporal formulas A and D, define left(A, D) by
structural induction on A:

```
left(p, D)         = bot                    (atoms are false at gaps)
left(neg A, D)     = U'(top, D) and neg left(A, D)
left(A and B, D)   = left(A, D) and left(B, D)
left(U(A,B), D)    = U'(B and U(A,B), D)
left(U'(A,B), D)   = U'(B and U'(A,B), D)
left(S(A,B), D)    = U(D and B and S(A,B) and U'(top, B and D)
                          and neg U'(D, B and D), D)
left(S'(A,B), D)   = U(D and B and S'(A,B) and U'(top, B and D)
                          and neg U'(D, B and D), D)
```

Define right(A, D) by swapping U<->S and U'<->S' throughout.

**Rank bound:** rank(left(A, D)) <= max(rank(A), rank(D)) + 2.

**Lemma 9 (Gap detection).** The following are equivalent:
1. M_r |= left(A, D)(m)
2. There exists gamma in M_r (a gap of M, not +/-infinity), gamma
   defined by D on the left, with gamma > m, D holds in M on (m, gamma),
   and M_r |= A^mu(gamma).

This is the crucial bridge: left(A,D) is a temporal formula (evaluable at
actual points) that detects whether A^mu holds at a specific gap.

---

## 2. The Custom Game G_{n;r} (Def. 8.6-8.7)

### 2.1 Standard EF Games (Def. 8.6)

Standard n-round EF game G_n(M, N) on Sigma-structures: n rounds, each
round Spoiler picks from one structure, Duplicator responds from the other.
Duplicator wins iff the resulting partial map preserves all quantifier-free
formulas.

**Proposition 5 (Ehrenfeucht-Fraisse).** Duplicator has a winning strategy
for G_n(M,N) iff M and N satisfy the same Sigma-sentences of quantifier
depth <= n.

### 2.2 The Custom Game G_{n;r} (Def. 8.7)

**Definition.** Let M, N be linear temporal structures. The game
G_{n;r}(M, xy; N, x'y') for n, r < omega, x < y in M_r, x' < y' in N_r,
is played as follows:

**Round 1 (bulk selection):** Spoiler chooses n elements
a_1, ..., a_n in [x,y]_r (the closed interval in M_r between x and y).
Duplicator responds with a'_1, ..., a'_n in [x',y']_r.

**Round 2 (point challenge):** Spoiler chooses one more element
b' in [x',y'] -- this must be an actual point, NOT a gap.
Duplicator responds with b in [x,y] (also an actual point).

**Winning condition.** Duplicator wins iff:
1. The tuples x y a b and x' y' a' b' have the **same order type** (same
   relative ordering of all elements).
2. For each pair of corresponding elements t, t':
   - t is a gap of M iff t' is a gap of N.
   - For each temporal L-formula A of rank <= r: M_r |= A^mu(t) iff
     N_r |= A^mu(t').

**Key asymmetries:**
- Round 1 elements can be gaps or points (from [x,y]_r).
- Round 2 element must be an actual point.
- Round 1: Spoiler plays in M, Duplicator responds in N.
- Round 2: Spoiler plays in N (the OTHER structure), Duplicator responds
  in M.

### 2.3 Monotonicity (Lemma 10)

If Duplicator wins G_{n;r}(M,xy; N,x'y'), then she also wins
G_{n';r'}(M,xy; N,x'y') for any n' <= n, r' <= r, provided x,y in M_{r'}
and x',y' in N_{r'}.

### 2.4 Decomposition Formulas (Def. 8.8)

An **(n;r)-decomposition formula** is a first-order formula of the form:

```
exists y_1,...,y_n: x_1 < y_1 < ... < y_n < x_2 and Chi
```

where Chi is a conjunction of:
- (a) theta(t) where t is an element of x_1 x_2 y and theta is mu, neg mu,
  or A^mu for some temporal formula A of rank <= r.
- (b) mu(z) and a < z < b implies B^mu(z), where a < b are adjacent
  elements and B has rank <= r.

**Lemma 11.** Duplicator has a winning strategy for G_{n;r}(M,xy; N,x'y')
iff M_r and N_r agree on all (n;r)-decomposition formulas with free
variables x_1, x_2 evaluated at (x,y) and (x',y') respectively.

---

## 3. The Depth Functions f(n) and g(n) (Def. 8.9)

### 3.1 Recurrence

Define functions f, g: omega -> omega satisfying:

```
f(0) = g(0) = 0
f(n+1) > (1 + 3*f(n)) * (2*k_n) + 1
g(n+1) > g(n) + 4*f(n)
```

where **k_n** is the number of inequivalent (1+3f(n)); (g(n)+4f(n))-decomposition
formulas.

### 3.2 What k_n Represents

k_n counts the number of distinct (up to logical equivalence) decomposition
formulas of the relevant parameters. Since L is finite and the rank is
bounded, there are finitely many inequivalent temporal formulas of each
rank, hence finitely many decomposition formulas.

In the existing Lean code, this is approximated as:
```
k_n = Fintype.card (NormalForm sig (game_depth sig n) 1)
```

### 3.3 Role in the Proof

The depth function f(n) governs how many elements Duplicator needs to
select in Round 1 to ensure she can win. The key relationship:

- f(n+1) elements in the "forward" game suffice to guarantee n elements
  in the "backward" game after applying Theorem 6.
- g(n) controls the temporal rank needed so that rank-g(n) agreement
  implies n-round game equivalence.

### 3.4 Current Lean Implementation

```lean
noncomputable def game_depth (sig : MonadicSignature) : Nat -> Nat
  | 0 => 0
  | n + 1 =>
    let prev := game_depth sig n
    let k_n := Fintype.card (NormalForm sig prev 1)
    (1 + 3 * prev) * (2 * k_n) + 2
```

This matches the recurrence f(n+1) = (1+3f(n))*(2k_n) + 2 (using +2
instead of the weaker +1 lower bound for cleaner arithmetic).

---

## 4. The Composition Lemma (Proposition 7)

### 4.1 Statement

**Proposition 7.** For all n < omega: Let M, N be linear temporal structures
and let x_1 < ... < x_m and y_1 < ... < y_m be increasing m-tuples in
M, N respectively. Define x_0 = -infinity, x_{m+1} = +infinity in M,
and y_0, y_{m+1} similarly.

Suppose Duplicator has winning strategies for:

```
G_{f(n);g(n)+4f(n)}(M, x_i x_{i+1}; N, y_i y_{i+1})
```

and

```
G_{f(n);g(n)+4f(n)}(N, y_i y_{i+1}; M, x_i x_{i+1})
```

for all 0 <= i <= m. Then Duplicator has a winning strategy for the
standard EF game G_n((M,x), (N,y)).

### 4.2 Proof Sketch

By induction on n. For n = 0 trivial. For n+1:

Let r = g(n) + 4f(n) < g(n+1). Suppose Spoiler chooses alpha in M
(WLOG). Find the interval (x_i, x_{i+1}) containing alpha. List all
(1+3f(n));r-decomposition formulas satisfied by (x_i, alpha) and
(alpha, x_{i+1}). Duplicator uses at most:

```
n' = (1 + 3f(n)) * (j + k) + 1 <= f(n+1)
```

elements. She applies her strategy for G_{f(n+1);r} to find a
corresponding element e in N. By Lemma 11, the decomposition formulas
transfer, giving Duplicator strategies on the sub-intervals. By Theorem 6,
she also gets backward strategies. The induction hypothesis then applies.

### 4.3 Role as EF Analogue of Feferman-Vaught

This is the composition theorem: if Duplicator can win on each interval
between corresponding selected points, she can win on the whole structure.
This is the EF game analogue of the Feferman-Vaught theorem for
lexicographic sums of linear orders.

---

## 5. The Main Theorem: Forward-to-Backward (Theorem 6)

### 5.1 Statement

**Theorem 6.** Suppose M, N are linear temporal structures. Then (*)_n
holds for all n < omega:

(*)_n: For all r < omega, if x < y in M_r, x' < y' in N_r, and
Duplicator has a winning strategy for

```
G_{1+3n; r+4n}(M, xy; N, x'y')
```

then Duplicator has a winning strategy for

```
G_{n;r}(N, x'y'; M, xy)
```

This is the deep result: forward games with extra rounds/rank yield
backward games.

### 5.2 Proof by Induction on n

#### Base Case: n = 0

For G_{0;r}(N, x'y'; M, xy): Round 1 is empty (0 elements), so Spoiler
only plays Round 2 by choosing alpha in (x,y) (an actual point). Since
Duplicator has a winning strategy for G_{1;r}(M,xy; N,x'y'), she can
respond to find e in (x',y') matching alpha on rank-r formulas.

#### Inductive Step: Assume (*)_n, Prove (*)_{n+1}

Fix r < omega, x < y in M_r, x' < y' in N_r. Assume Duplicator has a
winning strategy for G_{4+3n; r+4(n+1)}(M, xy; N, x'y'). We construct a
winning strategy for G_{n+1;r}(N, x'y'; M, xy).

**Setup.** Suppose Spoiler chooses n+1 points x' < a_0 < ... < a_n < y'
in N_r. Define:

- A = X_{(a_{n-1}, a_n)} (the rank-r type describing the open interval
  before a_n; if n=0, use a_{-1} = x').
- C = A restricted to the interval (a_n, y'): the conjunction of
  temporal formulas describing the region where the "type" A continues.
  Concretely, C holds at points satisfying the same rank-r theory as
  points between a_{n-1} and a_n.
- c = inf{t in [x,y] : M |= C(u) for all u in (t,y)}
- d = corresponding infimum in N.

**Claim 1.** In any play of G_{m;r'} where Spoiler includes c among his
choices, Duplicator (using her winning strategy) must respond to c with
exactly d. This follows because the rank-(r+1) formula
C' = neg C or K^-(neg C) satisfies M_r |= C'(c), forcing N_r |= C'(d).

**Claim 2.** By restricting the master strategy to sub-intervals,
Duplicator has winning strategies for:
- G_{1+3n; r+4(n+1)}(M, xc; N, x'd)
- G_{1+3n; r+4(n+1)}(M, cy; N, dy')

Hence by (*)_n:
- sigma: winning for G_{n;r+4}(N, x'd; M, xc)
- tau: winning for G_{n;r+4}(N, dy'; M, cy)

The proof now splits into **four cases** depending on the nature of a_n.

---

## 6. The Four Cases of the Main Induction

### Case I: a_0 < d (The "split" case)

**When it applies:** At least one of the chosen points a_0,...,a_n lies
in (x', d). Since d < a_n always holds, at most n points are in (x',d)
and at most n are in (d,y').

**Strategy:** Duplicator applies sigma to the points in (x',d) and tau
to those in (d,y'). She combines the responses using the method of
Lemma 10. For the Round 2 challenge, she uses whichever strategy covers
the relevant interval.

**Connective used:** None specifically -- this case does not construct a
new StaviFormula. It reduces to the two backward strategies sigma and tau.

### Case II: All a_0,...,a_n in (d,y'), a_n is a POINT (not a gap)

**When it applies:** All chosen points lie in the "tail" interval (d,y'),
and a_n is an actual point of N (not a gap).

**Construction:**
- B = X_{a_n} (the rank-r type at a_n).
- b = sup{t in (x,y) : M |= B(t)}: the supremum of where B-type holds.
- Since Duplicator's strategies preserve rank-(r+4) formulas and
  U(B, A) has rank r+1, M_r |= U(B, A)^mu(e_{n-1}).

**Duplicator's strategy:** She uses tau to respond to a_0,...,a_{n-1},
getting e_0,...,e_{n-1}. Then she finds z > e_{n-1} in M where B holds
and A holds on (e_{n-1}, z), with z < b. She sets e_n = z.

**Connective used:** Standard **Until** U(B, A). The formula U(B, A) holds
at e_{n-1}, witnessed by the point e_n.

**Verification:** e_n and a_n satisfy the same rank-r formulas (both
satisfy B = X_{a_n}). For the Round 2 challenge, if t falls between
e_{n-1} and e_n, M |= A(t), so there exists t' in (a_{n-1}, a_n) with
matching type.

### Case III: All a_0,...,a_n in (d,y'), a_n is a gap defined on the LEFT

**When it applies:** a_n is a gap of N defined on the left by some formula
D of rank <= r, with D implying A.

**Construction:**
- B = X_{a_n} (rank-r type at the gap a_n, using A^mu).
- delta = left(B, D): the gap detection formula for B at D-gaps.
  rank(delta) <= r + 2.
- N_r |= U(delta, A)^mu(a_{n-1}).
- d' = sup{t in (x',y') : N |= neg D(t)}.
- g' = sup{t in (x', d') : N |= delta(t)}.
- Define d, g similarly in M.

**Duplicator's strategy:** She uses the backward strategy to respond to
a_0,...,a_{n-1} with e_0,...,e_{n-1} in (c, g)_r. Since
U(delta, A) has rank <= r+4 and is preserved, M_r |= U(delta, A)^mu(e_{n-1}).
She finds t < g with M |= delta(t) and A holding on (e_{n-1}, t).

By Lemma 9 (the gap detection lemma), there exists a gap e_n in (t, d)_r
defined by D on the left, satisfying the same rank-r relativised formulas
as a_n. She chooses this gap.

**Connective used:** Stavi Until **U'(B, A)** (implicitly, via left(B, D)
which detects U'-like behavior at the gap).

### Case IV: All a_0,...,a_n in (d,y'), a_n is a gap NOT defined on the left

**When it applies:** a_n is a gap of N that is not definable on the left
by any rank-<= r formula. Hence A holds throughout some interval
containing a_n. Choose D of rank <= r defining a_n on the **right**.

**Construction:**
- B = X_{a_n}.
- delta = A and neg D and U(right(B,D), A). rank(delta) <= r + 3.
- d' = sup{t in (x',y') : N |= right(B,D)(t)}.
- g' = sup{t in (x', d') : N |= delta(t)}.
- Define d, g similarly in M.

**Duplicator's strategy:** There exist a_{n-1} < t' < a_n < u' < y' with
t', u' in N, N |= delta(t'), N |= right(B,D)(u'), and A holding on
(t', u'). So t' < g' and u' < d'.

Duplicator uses the backward strategy on (d,g') to respond to
a_0,...,a_{n-1}. Since U(delta, A) has rank <= r+4 and is preserved,
she finds t < g with M |= delta(t) and A on (e_{n-1}, t). Then she
finds u in M with t < u < d, M |= right(B,D)(u), and A on (e_{n-1}, u).

By Lemma 9, there exists a gap e_n in (t, u) defined by D on the right,
satisfying the same rank-r relativised formulas as a_n.

**Connective used:** Stavi **U'** (or S' dually) via right(B, D) which
detects the gap from the other side.

---

## 7. From Games to Expressive Completeness

### 7.1 Proposition 6 (Game from Formula Agreement)

If x in M and y in N satisfy the same temporal formulas of rank
r + 4n + 1, then Duplicator has winning strategies for:
- G_{n;r}(M, -infinity x; N, -infinity y)
- G_{n;r}(M, x infinity; N, y infinity)

**Proof sketch:** If Spoiler chooses a_1 < ... < a_n in M (future of x),
define C_n = X_{a_n} and neg U(neg X_{(a_n, T)}, ...) and for i < n,
C_i = X_{a_i} and U(C_{i+1}, X_{(a_i, a_{i+1})}). Then rank(C_0)
<= r + n + 1. Since M |= C_0(x), N |= C_0(y), and Duplicator finds
e_0 < ... < e_n matching all types. For gaps, the C formulas involve
left() and right(), pushing rank up to r + 4n + 1.

### 7.2 Corollary 5 (Expressive Completeness)

If x in M and y in N satisfy the same temporal formulas of rank
g(n+1) + 1, then for all monadic FO formulas phi of quantifier depth
<= n: M |= phi(x) iff N |= phi(y).

**Proof:** By Propositions 5, 6, 7.

### 7.3 The Final Step

Given phi(x) of quantifier depth n, choose a finite L with atoms matching
phi's monadic predicates. Take a finite set Phi of temporal formulas of
rank 1 + g(n+1) partitioning the space of complete types. Let Phi' be
those types consistent with phi. Then phi is equivalent over linear time
to the disjunction of Phi', a temporal formula of rank 1 + g(n+1).

---

## 8. Summary of Key Lemmas for Formalization

### Critical Path (in order of dependency)

1. **Def: M_r** (structure with r-definable gaps)
2. **Def: A^mu** (relativised formula evaluation at gaps)
3. **Def: X_t, X_{(t,u)}** (complete rank-r type formulas)
4. **Def: left(A,D), right(A,D)** (gap detection, Def 8.5)
5. **Lemma 9** (left/right correctness: temporal formula <-> gap property)
6. **Def: G_{n;r}** (custom game, Def 8.7)
7. **Def: Decomposition formulas** (Def 8.8)
8. **Lemma 11** (game <-> decomposition formula agreement)
9. **Lemma 10** (monotonicity in n, r)
10. **Theorem 6** (forward-to-backward, 4 cases)
11. **Proposition 6** (formula agreement -> game strategies)
12. **Proposition 7** (composition lemma)
13. **Corollary 5** (expressive completeness)

### Estimated Complexity

| Component | Lines (est.) | Difficulty |
|-----------|-------------|------------|
| M_r, A^mu, X_t definitions | 100-150 | Medium |
| left/right formulas + Lemma 9 | 150-200 | Hard |
| G_{n;r} game definitions | 80-120 | Medium |
| Decomposition formulas + Lemma 11 | 100-150 | Medium |
| Theorem 6 (4 cases) | 400-600 | Very Hard |
| Propositions 6, 7 | 150-200 | Hard |
| Corollary 5 (final assembly) | 50-80 | Medium |
| **Total** | **1030-1500** | |

### Key Formalization Challenges

1. **M_r as a type:** M_r contains both points and gaps. Need a sum type
   `M.carrier + (r-definable gaps)` with an induced linear order. The
   order must interleave gaps among points correctly.

2. **A^mu evaluation at gaps:** Gaps are not points, so temporal formulas
   cannot be directly evaluated there. The mu-relativisation restricts
   quantification to actual points, but the formula is "evaluated" at a
   gap position. This requires careful encoding.

3. **left(A,D) correctness (Lemma 9):** The structural induction on A
   has 7 cases, each requiring non-trivial reasoning about gap-point
   interaction. The S and S' cases involve U' in the definition, creating
   mutual dependency.

4. **Theorem 6 Case III/IV:** These cases construct gaps in M matching
   gaps in N. The existence argument uses left/right formulas and
   Lemma 9. Formalizing the "there exists a gap e_n in (t,d)_r defined
   by D" requires careful handling of gap definability.

5. **The composition lemma (Prop 7):** The inductive argument requires
   keeping track of multiple game strategies simultaneously and
   "restricting" a master strategy to sub-intervals. This is technically
   the EF-game version of Feferman-Vaught and is notation-heavy.

### Simplification Opportunities

- **For the ProofChecker project (Z-only):** On discrete orders like Z,
  there are NO gaps. Hence M_r = M for all r, and Cases III and IV of
  Theorem 6 never arise. The entire left/right machinery becomes vacuous.
  The proof reduces to Cases I and II only. This cuts the formalization
  roughly in half.

- **Alternative via Reynolds Theorem 5:** The current codebase already
  has `flatten_stavi_correct` showing that U'/S' reduce to U/S on
  discrete orders. Combined with Kamp's theorem ({U,S} expressively
  complete for Dedekind-complete orders), this may provide a shorter
  path for the Z-specific result, bypassing the full game theory.

---

## 9. Relationship to Existing Lean Code

The current `EFGames.lean` (280 lines) contains:

- `EFPosition`: basic game position type (correct but simplified)
- `ef_duplicator_wins`: standard winning condition (needs extension for
  the custom G_{n;r} format with gap handling)
- `game_depth`: the depth function f(n) (correct recurrence)
- `stavi_n_equiv`: formula agreement at bounded depth (correct)
- `stavi_expressive_completeness`: the main theorem (sorry'd)

**What needs to change for the full proof:**

1. Replace `EFPosition` with a G_{n;r}-aware version that supports:
   - Two-round structure (bulk selection + point challenge)
   - Elements from M_r (points + gaps)
   - Point constraint on Round 2

2. Add `M_r` type (structure extended with r-definable gaps)
3. Add `A^mu` (relativised evaluation)
4. Add `left()`, `right()` formulas and Lemma 9
5. Add decomposition formulas and Lemma 11
6. Implement the 4-case induction (Theorem 6)
7. Implement Propositions 6, 7 and the final assembly

**For the Z-specific path:** Steps 2-4 become trivial (M_r = M, no gaps).
Step 6 reduces to Cases I and II. This is the recommended approach if the
goal is expressive completeness over Z specifically.
