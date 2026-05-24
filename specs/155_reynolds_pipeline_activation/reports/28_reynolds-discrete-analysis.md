# Reynolds 1994: How Discrete-Order Axiomatization Handles the K^- Problem

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-23
**Source**: Reynolds 1994, "Axiomatising U and S over Integer Time"

---

## 1. The K^- Problem in Discrete Orders

### K^- is vacuously false in all discrete orders

Reynolds defines (p.118, line 135):

```
K^-(A) = ~S(T, ~A)   ("A was true arbitrarily recently")
```

Unfolding: K^-(A)(t) = for all s < t, exists u with s < u < t and A(u).

In a discrete order with immediate predecessors, taking s = t-1: we need
u with t-1 < u < t, but no such u exists. Hence K^-(A)(t) is **always false**
in any discrete linear order, for any formula A.

### Why this kills the GHR93 Claim 1 argument in discrete orders

GHR93 Claim 1 (p.116) constructs:

```
C' = ~C  or  K^-(~C)
```

and needs M_r |= C'(c) where c = inf(continuation set). When c is IN the
continuation set (i.e., C(c) holds), the first disjunct ~C(c) is false, so
the proof needs K^-(~C)(c) to be true. But K^-(~C) is always false in
discrete orders. Hence C'(c) is false, and the Claim 1 argument collapses.

This is the **exact blocker** identified in phase-3e-handoff.md: "When c_inf
is a carrier point in a discrete linear order with cont_holds_cross failing
ONLY at c_inf, the K^- formula approach breaks."

### The open-interval semantics are the root cause

S(A,B)(t) requires a witness s < t with A(s) and B holding on the **open**
interval (s,t). In discrete orders, adjacent points have empty open intervals
between them. This makes S(T, X)(t) trivially true (witnessed by the
predecessor), making K^-(A) = ~S(T,~A) trivially false.

This is NOT a bug in the formalization -- it is a genuine mathematical fact
about the interaction of S-semantics with discreteness.

---

## 2. How Reynolds Defines Since/Until

### Strict (open-interval) semantics throughout

Reynolds p.119 (Section 2):

```
U(A,B)(t) iff there is s > t such that A(s) and
            for all u in T, if t < u < s then B(u)

S(A,B)(t) iff there is s < t such that A(s) and
            for all u in T, if s < u < t then B(u)
```

Both use **strict** inequalities. The witness s is strictly past/future of t,
and the guard B must hold on the **open** interval between s and t. The
current point t is excluded from both the witness and the guard.

This matches our Lean formalization exactly:

```lean
| .std_snce A B =>
    exists s, s < t /\ mu_holds s /\
      stavi_temporal_truth_mu M atomMap r s A /\
      forall u, s < u -> u < t -> mu_holds u ->
        stavi_temporal_truth_mu M atomMap r u B
```

### Derived operators in Reynolds

```
F(A)   = U(A, T)     -- A will be true (strictly future)
P(A)   = S(A, T)     -- A was true (strictly past)
G(A)   = ~F(~A)      -- A always future
H(A)   = ~P(~A)      -- A always past
K+(A)  = ~U(T, ~A)   -- A true arbitrarily soon (future)
K-(A)  = ~S(T, ~A)   -- A true arbitrarily recently (past)
```

In discrete orders: K+(A)(t) and K-(A)(t) are both **always false**.

---

## 3. Reynolds's Proof Architecture (Avoids the Problem Entirely)

### The completeness theorem structure

Reynolds proves Theorem 18 (weak completeness of US/Z for integer time)
through a pipeline that NEVER applies K^- reasoning in a discrete order:

**Step 1: Burgess-Xu (Theorem 2, Corollary 3)**

Given a US/Z-consistent set F, the Burgess-Xu system (which is strongly
complete for ALL linear frames) produces a model M0 with:
- Countable, discrete flow without endpoints
- All substitution instances of Prior-UZ and Prior-SZ valid
- M0 |= F(t0)

This structure is a Prior structure. It is discrete (so K^- is trivially
false throughout), but the Prior axioms are satisfied vacuously in the
relevant cases because the Since-based preconditions are vacuously true
in discrete orders.

**Step 2: Expressive completeness over Prior structures (Theorem 5)**

This is the elegant key. Reynolds proves US is expressively complete over
the class of Prior structures by reducing the Stavi connectives:

> "We claim that U'(A,B) <-> bot is valid in all Prior structures."

Proof (p.123): Suppose M |= U'(A,B)(t) in some Prior structure. Then B
holds for a while up until a gap after which ~B is true arbitrarily soon.
By Prior-U applied to B: M |= U(~B or K+(~B), B)(t), contradiction.

This argument uses K+ applied to the structure M, which may have dense
parts (Prior structures are not required to be discrete -- they just
satisfy the Prior axioms). The argument works precisely because Prior
structures have NO definable gaps. Stavi connectives detect gaps, and
Prior axioms prevent gaps, so U' and S' are equivalent to bot.

**Step 3: Gap elimination (Theorem 14)**

Proves that contemporaneous equivalence classes on a Prior structure do
not end at gaps. This uses K^-(~R) reasoning (Lemma 7, proof of
openness) -- but the structure may have dense parts where K^- is
non-trivially evaluable.

Critical point: the proof constructs an auxiliary structure N by "model
surgery" (Lemma 12), shows formulas are preserved, and derives a
contradiction. The K^- reasoning happens WITHIN arbitrary Prior
structures, not specifically within discrete ones.

**Step 4: Integer model construction (Theorem 15)**

Given a countable discrete Prior structure M, constructs a structure with
integer flow satisfying the same monadic sentences up to quantifier
depth k. This uses:

1. Define ~_M (a contemporaneous equivalence relation based on
   "very good" subintervals, Lemma 17)
2. By Theorem 14, ~_M classes don't end at gaps
3. Since M is discrete, if a's class doesn't end at a gap, it must
   include the successor c+1 of its rightmost point c (since M|[c,c+1]
   is finite hence very good, and ~ is transitive)
4. Therefore all of M is in one ~_M class, hence M is very good
5. By Lemma 16, M is good (k-equivalent to an integer interval)

**Step 5: Transfer (Theorem 18)**

The integer structure Z satisfies the same sentences as M up to depth k,
so the original formula A0 holds in Z.

### Why K^- problems never arise

The architecture is designed so that:

1. K^- reasoning (Lemmas 7-13) happens over **arbitrary Prior structures**
   where the order may have dense parts. The structures are NOT assumed
   discrete at this stage.

2. The discrete structure M from Step 1 enters the argument only at
   Step 4, where the gap elimination theorem has ALREADY been proved
   for all Prior structures.

3. Step 4's argument about discrete structures uses **transitivity of ~_M**
   and **finiteness of M|[c,c+1]**, not K^-. The discrete-specific
   reasoning is purely order-theoretic.

---

## 4. Gap Elimination (Theorem 14) in Detail

### Statement

> If ~ is a contemporaneous equivalence relation on a Prior structure M,
> then the ~-classes do not end at gaps.

### Proof architecture

The proof proceeds through Lemmas 6-13:

**Lemma 6** (Foundation): By US expressive completeness over Prior structures
(Theorem 5), there exists a temporal formula R true exactly where rho(x) --
"x's ~-class ends in a gap on the right" -- holds.

**Lemma 7** (R-interval openness): Maximal R-intervals are open with excluded
endpoints in M. Uses Prior-U to show R can't have a "first point" (which
would require K^-(~R) at that point to hold -- and in the Prior structure,
if there IS such a first point, the gap before it would contradict Prior-S).

Crucially, Lemma 7 DOES use the K^- concept indirectly. The proof on p.125:

> "Suppose for contradiction that s is this first point of R so that
> M |= (R and K^-(~R))(s)."

But this is a PROOF BY CONTRADICTION. Reynolds assumes K^-(~R)(s) holds
and derives a contradiction. He never needs K^- to be true; he shows that
the assumption leads to absurdity. The argument works in any Prior
structure, including discrete ones, because in a discrete structure
K^-(~R)(s) is always false, so the "first point of R" case is vacuously
impossible.

**Lemma 8** (No first/last class): Uses Prior-U + expressive completeness.

**Lemma 9** (Elementary equivalence of classes): If a formula holds somewhere
in one ~-class of a maximal R-interval, it holds somewhere in each ~-class.
Uses Prior-U + expressive completeness.

**Lemma 10** (Bad interval structure): Bad points occur in non-singleton bad
intervals. Both R and L hold throughout bad intervals.

**Lemma 11** (Propagation): Formulas true "for a while" at a class boundary
hold throughout the bad interval. Uses Prior-U.

**Lemma 12** (Model surgery): Replace a bad interval by one of its ~-classes.
Temporal truth is preserved. The proof is a 14-case induction on Until and
Since. The key cases (cases 2, 5 for Until) use Lemma 9's elementary
equivalence to transfer formula truth between classes.

**Lemma 13** (Contradiction): In the surgery model N, R still holds in I
(the retained class). But N is a Prior structure (Prior axiom instances that
fail in N would also fail in M). By Theorem 5, R detects gap-ending classes
in N. But I's class in N ends at an excluded point (Lemma 7), not at a gap.
So R should NOT hold in I -- contradiction.

### Where discreteness plays NO role

The entire Lemma 6-13 chain works for **any** Prior structure. The K^-
connective appears only in the proof-by-contradiction of Lemma 7 (where
K^-(~R)(s) is assumed for contradiction) and in the Prior axioms
themselves. The Prior axioms in a discrete structure have vacuously
satisfied preconditions (the Since/Until guards are over empty intervals),
so they impose no non-trivial constraints in the discrete case -- but they
don't need to, because the discrete case turns out to be trivially
handled at Step 4 of the main proof.

---

## 5. How Reynolds's Approach Relates to GHR93

### Different proof strategies for different goals

**GHR93** proves: {U, S, U', S'} is expressively complete over ALL linear
orders. The game argument (Theorem 6) is a general expressive completeness
result that works for arbitrary linear orders, including those with
non-isolated gaps.

**Reynolds** proves: US is expressively complete over Prior structures
(Theorem 5). This is a WEAKER result (restricted to Prior structures), but
it's sufficient for the completeness of US/Z.

### GHR93's Claim 1 IS the problematic step

GHR93 Claim 1 constructs C' = ~C or K^-(~C) and needs C'(c) to hold at
the infimum c. As analyzed in Section 1 above, K^-(~C) is always false
in discrete orders. However:

- GHR93 works over GENERAL linear orders, not specifically discrete ones
- The extended carrier M_r includes gaps (added artificially), which create
  dense-like neighborhoods even in otherwise discrete structures
- The gap points are NOT actual carrier points, so K^- evaluated on the
  extended carrier behaves differently than on the base carrier

The issue in our formalization is that when c_inf is a **carrier point**
(not a gap), its neighborhood in the extended carrier may still be
discrete (no extended points between it and its predecessor). In that
case K^-(~C)(c_inf) is false on the extended carrier, and the argument
breaks.

### Compatibility assessment

**Reynolds's approach does NOT need GHR93 Claim 1 at all.** His Theorem 5
uses a simple reduction argument (Stavi connectives are trivial in Prior
structures), not the GHR93 game argument. His gap elimination (Theorem 14)
uses expressive completeness as a black box -- it needs "for any monadic
formula, there's an equivalent temporal formula" but doesn't care HOW the
expressive completeness was proved.

**For our formalization**, the relevant question is: can we use Reynolds's
approach instead of the GHR93 game approach for the SPECIFIC purpose of
integer completeness?

---

## 6. Implications for Our Formalization

### The formalization's architecture vs Reynolds's architecture

**Our current architecture** (GHR93-based):
1. Prove {U,S,U',S'} expressively complete over all linear orders (EF games)
2. Use this for gap elimination on Prior structures
3. Apply to the chronicle-produced discrete structure

**Reynolds's architecture**:
1. Cite {U,S,U',S'} expressive completeness over all linear orders
   (Theorem 4, from GHR93)
2. Reduce to US expressive completeness over Prior structures (Theorem 5,
   simple 10-line argument)
3. Prove gap elimination (Theorem 14, using Theorem 5)
4. Prove integer model existence (Theorem 15, using Theorem 14 + discrete
   order theory)

Both architectures need Theorem 4 ({U,S,U',S'} expressively complete).
The difference is that Reynolds adds Theorem 5 (Prior reduction) as a
clean intermediate step, while GHR93 proves Theorem 6 (forward-to-backward
game transfer, which includes Claim 1) as an intermediate step toward the
same Theorem 4.

### The fundamental question: do we NEED Claim 1?

**For the GHR93 Theorem 6 (game transfer)**: Yes. Claim 1 is used in the
inductive step to locate Duplicator's response to the infimum point.
Without it, the backward game strategy cannot be constructed.

**For integer completeness**: Not necessarily. If we can establish US
expressive completeness over Prior structures by ANY means, we can proceed
with Reynolds's Theorem 14 (gap elimination) and Theorem 15 (integer model)
without ever invoking GHR93 Claim 1.

### Three paths forward

**Path A: Fix Claim 1 in the GHR93 framework.**
Replace the predicate encoding of C with a materialized StaviFormula
(per report 36). The formula C = X_{(a_n,y')} is a finite disjunction
of rank-r formulas. K^-(~C) then has rank r+1 (GHR93 terms) or r+2
(our terms). This eliminates the pigeonhole and works uniformly because
C is a SINGLE formula whose evaluation doesn't depend on density.

Important nuance: with C materialized as a formula, the infimum c of the
continuation set {t : C(u) for all u in (t,y)} may behave differently.
If c is a carrier point where C(c) holds, then ~C(c) is false. But
K^-(~C)(c) asks whether ~C holds cofinally below c. In the extended
carrier, if c has no immediate predecessor in M_r (i.e., c is a gap or
there are extended points below c), then K^-(~C)(c) can be non-vacuously
true. If c is a carrier point with an immediate predecessor in M_r AND
no gap points between them, K^-(~C)(c) is false -- but then ~C(c-1)
must hold (since c-1 is not in the continuation set), giving ~C at a
point strictly below c, which can serve as the witness directly.

**Path B: Use Reynolds Theorem 5 directly.**
Prove US expressive completeness over Prior structures by the Stavi
elimination argument (Theorem 5). This is a simple proof (~100-150 lines):
show U'(A,B) <-> bot in Prior structures (Prior-U prevents definable
gaps, U' detects gaps, so U' is trivially false). Then expressive
completeness of {U,S,U',S'} over all linear orders (Theorem 4) reduces
to US completeness over Prior structures.

This path requires Theorem 4 as a prerequisite. If Theorem 4 is already
proved (even with Claim 1 issues), Theorem 5 is immediate. If Theorem 4
is NOT proved, this path doesn't help.

**Path C: Direct integer model construction (bypass games entirely).**
Use Reynolds's Theorem 15 directly: given a countable discrete Prior
structure, construct an integer model via the ~_M relation and the
"very good" / "good" analysis. This requires Theorem 14 (gap elimination),
which requires Theorem 5, which requires Theorem 4.

### Assessment of current state

The fundamental dependency chain is:

```
Integer completeness (Theorem 18)
  <- Integer model (Theorem 15)
    <- Gap elimination (Theorem 14)
      <- US complete over Prior (Theorem 5)
        <- {U,S,U',S'} complete over linear (Theorem 4)
          <- Game transfer (GHR93 Theorem 6)
            <- Claim 1 (GHR93 p.116)
```

Our formalization is implementing the FULL chain. The Claim 1 blocker
affects the game transfer step. Reynolds's contribution is showing that
once game transfer is established (giving Theorem 4), the remaining
steps (Theorems 5, 14, 15, 18) are clean and do not encounter
discrete-order K^- issues.

**The K^- problem is LOCALIZED to Claim 1.** It does not infect the rest
of the pipeline. Once Claim 1 is resolved (via formula materialization,
Path A), the Reynolds pipeline proceeds without further K^- issues.

---

## 7. Reynolds's Prior-UZ and Prior-SZ Axioms

### The discrete-specific Prior axioms

Reynolds's axiom system US/Z includes:

```
Prior-UZ:  F(p) -> U(p, ~p)
Prior-SZ:  P(p) -> S(p, ~p)
```

These are STRONGER than the general Prior axioms:

```
Prior-U:   U(~p, p) and F(~p) -> U(~p or K+(~p), p)
Prior-S:   S(~p, p) and P(~p) -> S(~p or K-(~p), p)
```

In discrete orders, Prior-UZ says: if p will hold at some future point,
then p holds at the NEXT point where p is true, with ~p at all
intermediate points. Since the order is discrete with successor, this
means: between now and the first future p-point, ~p holds at every
intermediate point. The Until guard "~p" is evaluated at actual discrete
points, not over empty intervals.

Prior-UZ is SOUND for integer time: in Z, if F(p)(t) holds (p is true
at some s > t), then letting s be the LEAST such, ~p holds at all points
in (t,s), so U(p, ~p)(t) holds.

### How Prior-UZ interacts with K^-

The general Prior axiom Prior-U uses K+(~p) in the conclusion. In discrete
orders, K+(~p) is always false (as analyzed above), so Prior-U degenerates
to:

```
U(~p, p) and F(~p) -> U(~p, p)       [since K+(~p) = false]
```

which is trivially valid. The stronger Prior-UZ avoids this degeneracy by
making a different (and substantively useful) assertion about discrete
structure. Prior-UZ does NOT mention K+ or K- at all.

Reynolds's key insight: for integer time, the Prior axioms can be stated
WITHOUT K+/K-, using the inherent discreteness to make a direct assertion.
This avoids the semantic triviality of K+/K- in discrete orders.

---

## 8. Summary of Findings

1. **Since/Until are strict (open-interval)** in both Reynolds and GHR93.
   K^-(A) is vacuously false in all discrete orders. This is a mathematical
   fact, not a formalization error.

2. **Reynolds does NOT use the GHR93 Claim 1 argument.** His Theorem 5
   reduces Stavi connectives to bot in Prior structures via a simple 5-line
   argument. His gap elimination (Theorem 14) uses US expressive completeness
   as a black box.

3. **The K^- problem is localized to GHR93 Claim 1.** Reynolds's pipeline
   (Theorems 5, 14, 15, 18) avoids K^- reasoning in discrete structures.
   K^- appears only in Lemma 7's proof-by-contradiction (which works
   because K^-(~R)(s) being assumed true in a discrete structure is
   vacuously impossible).

4. **Reynolds's gap elimination works for all Prior structures.** It does
   not assume density or discreteness. The discrete case is handled
   trivially at the Theorem 15 level, where ~_M transitivity + finite
   intervals eliminate gaps without K^-.

5. **Both approaches require {U,S,U',S'} expressive completeness over
   all linear orders (Theorem 4 = GHR93 Theorem 6).** This is the shared
   foundation. Reynolds adds a clean reduction (Theorem 5) that makes the
   remaining steps independent of game-theoretic subtleties.

6. **The fix for Claim 1 is formula materialization (Path A from Section 6).**
   Replace the predicate cont_holds with a materialized StaviFormula C per
   GHR93 Definition 8.8. This eliminates the pigeonhole, the carrier-point
   edge cases, and the K^- vacuity problem. With C as a single formula,
   C' = ~C or K^-(~C) is a formula of rank r+2, and the game transfer
   works uniformly regardless of order density.

---

## Citations

- Reynolds 1994, Section 2 (p.119): Since/Until semantics, K+/K- definitions
- Reynolds 1994, Section 4 (p.121): Prior-UZ / Prior-SZ axioms
- Reynolds 1994, Theorem 5 (p.123): US expressively complete over Prior structures
- Reynolds 1994, Lemmas 6-13 (pp.124-129): Gap elimination proof chain
- Reynolds 1994, Theorem 14 (p.129): No gap-ending classes in Prior structures
- Reynolds 1994, Theorem 15 (pp.130-131): Integer model from discrete Prior structure
- Reynolds 1994, Theorem 18 (p.132): Weak completeness of US/Z
- GHR93, Claim 1 (p.116): Infimum response in game transfer
- GHR93, Definition 8.8 (p.112): X_t and X_{(t,u)} type formulas
