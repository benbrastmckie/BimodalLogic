# Teammate C (Critic) Findings: succ_cofinal

**Task**: 153 — Prove succ_cofinal (ChronicleToCountermodel.lean:1885)
**Role**: Critical analysis — identify gaps, shortcomings, blind spots in prior research
**Date**: 2026-05-15

---

## Key Findings

### Finding 1: The Proof Strategy in the Docstring Is Internally Contradicted

The docstring at lines 1540-1557 proposes a "Step 3" argument:

> The first limit_dom point z at or above L satisfies pred(z) is a succ-iterate
> (since all limit_dom below L are succ-iterates), so z = succ(pred(z)) = succ^[m+1](a).
> Hence z.val <= L (as a succ-iterate), giving z.val = L, so L in Q ∩ limit_dom.

This is **circular**. The premise "all limit_dom below L are succ-iterates" is what the
`orbit_below_L` lemma says (lines 1645-1662), and it holds for c.val < L. The step
"hence z.val <= L (as a succ-iterate)" assumes that every succ-iterate of a has value
strictly < L (i.e., the orbit is bounded by L from above). But succ-iterates are
already defined to be less than b.val (from h_not_cofinal), and convergence to L
exactly means the orbit approaches L from below with all f(n) <= L. So z.val = L
would require the orbit to REACH L in finitely many steps — but if it did, L would
be rational (a limit_dom point), and then succ^[n](a) = z for some n contradicts
succ^[n](a).val < L for all n (since succ-iterates are below L by h_not_cofinal).

The actual problem is exactly the L <= pred(b).val case where the gap scenario arises.
L is NOT necessarily rational, and even if some limit_dom point exists at L, showing
that pred(that_point) is a succ-iterate requires succ_cofinal itself (for a smaller
instance). The docstring's Step 3 argument would require well-foundedness of "gap
size", which is not established.

**Assessment**: The proof strategy documented in the docstring is not a valid proof
sketch. It begs the question at the key step.

---

### Finding 2: The Gap Scenario IS Logically Self-Consistent

The core claim of the existing analysis is that the gap scenario (orbit converging to L,
pred-chain from above, L irrational or not in limit_dom) is consistent with all
temporal axioms in the constant-MCS case. Careful verification confirms this.

**The constant-MCS model**: Suppose all limit_dom points have the same MCS value A.
Then limit_f(x) = A for all x. In this model:
- G(phi) holds at x iff phi in A (since phi holds at all future points iff phi in A)
- F(phi) holds at x iff phi in A (since there exists y > x with phi in limit_f(y) = A)
- U(phi, psi) holds at x iff psi in A (take y = succ(x), which exists since next_top in A)

Z1 = G(G(phi)->phi) -> (FG(phi)->G(phi)):
- G(phi) in A iff phi in A (for a constant model)
- G(G(phi)->phi): G(phi)->phi is (phi->phi) = True, so this is G(True) = True, in A
- FG(phi): F(G(phi)), G(phi) in A iff phi in A, so FG(phi) in A iff phi in A
- Z1 conclusion G(phi) in A iff phi in A
- So Z1 reduces to: True -> (phi in A -> phi in A), trivially satisfied

This confirms: **Z1 is trivially satisfied in any constant-MCS model, regardless of
the order structure**. A constant-MCS model on a Z+Z-like ordering satisfies all of
Z1, Prior-UZ, Prior-SZ, and all other BX axioms vacuously.

Prior-UZ = F(phi) -> U(phi, neg phi):
- F(phi) in A iff phi in A
- U(phi, neg phi): requires y > x with neg phi at y and phi at all intermediate points
  In constant model: neg phi in A iff phi not in A. If phi in A, then neg phi not in A.
  So U(phi, neg phi) has no witness when phi in A. But F(phi) is in A iff phi in A.
  So Prior-UZ antecedent (F(phi)) fails iff phi not in A, in which case consequent
  U(phi, neg phi) also holds vacuously (phi not at the starting point anyway).
  When phi in A: F(phi) in A. Need U(phi, neg phi) in A. U(phi, neg phi) requires a
  witness y > x with neg phi at y (i.e., phi not in limit_f(y) = A). Contradiction:
  phi in A but we need phi not in limit_f(y) = A. So U(phi, neg phi) requires phi
  to NOT be uniformly present. **Therefore Prior-UZ fails in the constant-MCS model
  when phi is present uniformly!**

**Critical revision to the existing analysis**: The existing analysis in report 01 says
"Z1 is trivially satisfied in the constant MCS case" and uses this to argue the constant
MCS case is the hard one. But PRIOR-UZ FAILS in the constant-MCS case when phi in A.
This means **the constant-MCS case is actually RULED OUT by Prior-UZ**, not permitted.

Let me verify: Prior-UZ states F(phi) -> U(phi, neg phi). If all limit_f(x) = A and
phi in A, then F(phi) is in A (since phi in A means "phi holds at all future points
including some"). But U(phi, neg phi) in A requires the semantic condition: exists y > x
with neg phi in limit_f(y) = A and phi in limit_f(w) = A for all w in (x,y). But
neg phi in A contradicts phi in A (consistency of MCS). So U(phi, neg phi) NOT in A.

But wait: is Prior-UZ semantically validated in this construction? The MCS A contains
Prior-UZ as a theorem (since Prior-UZ is an axiom of the system, hence in every MCS by
`theorem_in_mcs`). So Prior-UZ is in A = limit_f(x) for all x. Since A is an MCS,
its content is semantically consistent via the truth lemma structure. The issue is:

In the canonical model semantics, "phi U psi at x" means "exists y > x with psi(y) and
phi at all intermediate points". In the CONSTANT model, if phi in A and neg phi not in A,
then U(phi, neg phi) is false everywhere (no witness y with neg phi at y). So Prior-UZ
would be semantically FALSE: F(phi) is true (phi holds at all future points, so in
particular at some future point) but U(phi, neg phi) is false. This is a contradiction
with Prior-UZ being in every MCS and the truth lemma.

**Conclusion**: The truth lemma for U(phi, psi) says: phi U psi in limit_f(x) iff exists
y > x with psi in limit_f(y) and phi in limit_f(w) for all w in (x,y). In the constant
model, if phi in A and neg phi NOT in A: U(phi, neg phi) would require a y with neg phi
in limit_f(y) = A. This is impossible. So U(phi, neg phi) NOT in limit_f(x). But
Prior-UZ is in every MCS, and limit_f(x) = A is an MCS, so Prior-UZ in limit_f(x).
Implication property: F(phi) in limit_f(x) -> U(phi, neg phi) in limit_f(x).

If F(phi) in limit_f(x) = A: since phi in A, exists y > x with phi in limit_f(y) = A.
So F(phi) is semantically true, hence F(phi) in limit_f(x) (by the truth lemma for F).
Then implication property gives U(phi, neg phi) in limit_f(x). But U(phi, neg phi) is
semantically false. Contradiction with the truth lemma for U.

So the truth lemma itself would FAIL for the constant-MCS model. This means the
constant-MCS limit domain IS NOT a valid chronicle model (it fails the truth lemma).

**This is the key insight the existing analysis missed**: The constant-MCS case is
not just "trivially satisfying Z1" — it is excluded by the truth lemma + Prior-UZ
interaction. The gap scenario in the constant-MCS case is self-contradictory WITHIN
the chronicle model, not just at the semantic level.

---

### Finding 3: The Non-Constant Case Gap Scenario Also Has Structure Not Exploited

In the gap scenario (L <= pred(b).val, orbit < all pred-chain, constant orbit succ-orbit
not reaching b), the analysis correctly identifies that points with value in (orbit-sup, pred-chain-inf)
are neither in the orbit nor in the pred-chain. But it doesn't analyze what MCS values
these intermediate points can have.

Key observation: By `orbit_below_L`, every limit_dom point c with a <= c and c.val < L
IS in the orbit. So there are NO intermediate limit_dom points strictly between the
orbit and L. Similarly, the pred-chain is strictly above L.

This means: the ONLY limit_dom points in the region [a.val, b.val] are:
- Orbit points: a, s(a), s^2(a), ...  (all with values < L)
- Points in the pred-chain: pb, p(pb), p^2(pb), ...  (all with values >= L)

If L is irrational (not in limit_dom), the gap region (L, limit_dom-inf) between orbit
and pred-chain contains NO limit_dom points. In this scenario, what MCS do the pred-chain
points have?

For any pred-chain point p^[k](pb), the formula next_top = U(T, bot) is in its MCS.
So there is an immediate successor of p^[k](pb) in limit_dom. By succ_pred:
succ(p^[k](pb)) = p^[k-1](pb) (for k >= 1, since pred-chain decreases, succ of p^[k] is p^[k-1]).
And pred(p^[k](pb)) = p^[k+1](pb).

So the pred-chain points have succ/pred structure among themselves: they are locally
connected as a discrete sub-order. Similarly for orbit points.

The two components (orbit and pred-chain) are ordered with all orbit < all pred-chain.
But in a discrete order with SuccOrder/PredOrder: for any point x, succ(x) must be the
immediate next element. For the "top" of the orbit (in the limit), there is no immediate
next element in the orbit (since orbit is cofinal at L from below). For the "bottom" of
the pred-chain, its predecessor must be the top of the orbit — but there is no top!

This is the key: in a discrete order with NO gaps (every element has a succ and pred),
the existence of pred(pb) = p(pb) implies there is a limit_dom point BETWEEN pb and the
orbit-sup. But the orbit has no maximum (it's cofinal at L), and p(pb) is strictly above
all orbit points. So p(pb) is an immediate predecessor of pb in limit_dom — meaning there
are NO limit_dom points strictly between p(pb) and pb. But the orbit points are all < pb,
and some of them are > p(pb)? No: h_lt_pred_chain k n says s^[n](a) < p^[k](pb) for ALL
k, n. So s^[n](a) < p(pb) = p^[1](pb) for all n. The orbit is below all pred-chain points.

Now, the key question: what is pred(pb)? It is p(pb) = the pred-chain's second element.
And p(pb) is strictly below pb in limit_dom. What is pred(p(pb))? It is p^[2](pb) = p(p(pb)),
another pred-chain element below p(pb). The pred-chain extends downward indefinitely.

But: pred-chain values are ALL >= L (h_pred_chain_ge_L). So pred-chain values form a
sequence converging DOWN to some value >= L. This sequence is strictly decreasing
(h_pred_chain_strict). If the sequence converges to M >= L, and M is a limit point from
above...

Now by the same orbit_below_L argument applied to the pred-chain: every limit_dom point c
with c.val > M (in the pred-chain range) and c.val <= pb.val is in the pred-chain, by
an analogous convexity argument. But what is pred^[k](pb) for large k? Its values approach
M from above. If M = L (the orbit's limit), then:
- Orbit: values < L, approaching L from below
- Pred-chain: values > L, approaching L from above
- L itself: not in limit_dom (by assumption, since orbit < all pred-chain)

This gives a genuine two-component Z+Z-like structure with a REAL NUMBER gap at L.

The key question remains: **can this actually occur in the chronicle construction?**

---

### Finding 4: The Archive Task 129 Analysis Has a Critical Claim

The Task 129 team research report (02_team-research.md) explicitly states:

> "The sorry is deep inside the Burgess chronicle construction, trying to prove
> IsSuccArchimedean of the chronicle's limit domain. The Doets/Reynolds approach
> does not fix the chronicle — it provides a completely separate completeness proof."

And:

> "Integration Must Bypass the Chronicle Entirely"

This confirms that Task 129's resolution was to AVOID proving succ_cofinal, not to prove
it. The Reynolds/Doets pipeline (Task 129's approach) makes succ_cofinal dead code by
providing a separate completeness proof. After Task 129's partial implementation, the
WeakCanonical pipeline still has 5 sorry-propagation issues (all in FO satisfaction
infrastructure for MonadicSentence). These are NOT in succ_cofinal itself.

**Implication for Task 153**: Task 153's goal (prove succ_cofinal directly) is
orthogonal to Task 129's approach (bypass it). Task 153 is attempting the harder path.

---

### Finding 5: The Prior-UZ Obstruction to Constant-MCS Is Available as a Proof Ingredient

From Finding 2, the key insight is:

In the gap scenario, if ALL limit_dom points in the orbit and pred-chain region have the
same MCS value, then Prior-UZ would be violated: take phi = any formula in A.
F(phi) is in limit_f(x) for any orbit point x (since phi in A = limit_f(y) for all y > x).
U(phi, neg phi) would require a point y > x with neg phi present. But neg phi not in A
(consistency). Contradiction with Prior-UZ being in every MCS.

Therefore: in the gap scenario, the limit_dom points must have NON-CONSTANT MCS values.

Specifically: there exists a formula phi such that phi in limit_f(orbit-point) but
phi not in limit_f(pred-chain-point), or vice versa.

This is the discriminating formula whose existence the report 01 doubted for the
constant case! Prior-UZ guarantees its existence.

**The question then becomes**: can we use this discriminating formula + Z1 to derive
a contradiction? The backward_G lemma in scope at the sorry says:
- If phi at all y > x, then G(phi) in limit_f(x)

And Z1 = G(G(phi)->phi) -> (FG(phi)->Gφ) says:
- If G(phi)->phi holds everywhere in the future, and FG(phi) holds, then G(phi) holds now

The Z1 maximum principle argument would work as follows:
1. By Prior-UZ non-constancy: some orbit point x has phi in limit_f(x), some pred-chain
   point y has phi NOT in limit_f(y)
2. Consider the "final phi point" in the orbit (the last orbit point with phi present)
3. Using Prior-UZ at the last phi point: F(phi) -> U(phi, neg phi). Since phi at some
   future point (the last one)... wait, it's not clear the orbit has a "last phi point"

The subtlety: orbit points are indexed by N, with no maximum. So there might be
infinitely many orbit points with phi present, or finitely many. If finitely many:
there's a last orbit point with phi, and from that point forward phi is absent.
If infinitely many: phi is present at all sufficiently late orbit points.

Case: phi present at all sufficiently late orbit points (succ^[n](a) for n >= N0):
- For large n, phi in limit_f(succ^[N0](a)) and phi in limit_f(succ^[n](a)) for all n >= N0
- By backward_G: G(phi) in limit_f(succ^[N0](a)) (since phi at all future y > succ^[N0](a))
  BUT: this requires phi at ALL future limit_dom points, not just orbit ones
  The pred-chain points might have phi absent, so backward_G fails

This is exactly the gap the existing analysis identified: we don't know what happens
to phi at pred-chain points.

Case: phi present at only finitely many orbit points:
- Let succ^[m](a) be the last orbit point with phi
- From succ^[m+1](a) forward: phi absent from all orbit points
- By Prior-UZ at succ^[m](a): F(phi) -> U(phi, neg phi)
  F(phi) holds iff phi at some y > succ^[m](a). But phi is absent from orbit points
  after succ^[m](a). What about pred-chain points? If phi is at some pred-chain point y,
  then F(phi) holds at succ^[m](a). Prior-UZ gives U(phi, neg phi) at succ^[m](a).
  U(phi, neg phi) requires a y > succ^[m](a) with neg phi at y and phi at all intermediates.
  In orbit region: succ^[m+1](a) > succ^[m](a) has neg phi (absent). So y = succ^[m+1](a)
  works IF phi at succ^[m](a)... wait, succ^[m](a) is the source, not the witness.
  U(phi, neg phi) at succ^[m](a) needs: exists y > succ^[m](a) with neg phi at y and
  phi at all intermediate z in (succ^[m](a), y). The witness is succ^[m+1](a) if neg phi
  at succ^[m+1](a) and no intermediate points exist. Since succ is immediate:
  U(phi, neg phi) at succ^[m](a) is witnessed by y = succ^[m+1](a) since:
  - neg phi in limit_f(succ^[m+1](a)) (by assumption)
  - No intermediate limit_dom in (succ^[m](a), succ^[m+1](a)) (by immediate succ property)
  So U(phi, neg phi) holds. This is CONSISTENT, not a contradiction!

**Conclusion from Finding 5**: The Prior-UZ argument confirms non-constant MCS, but
STILL does not directly give a contradiction. We know the discriminating formula phi
has a "last occurrence" pattern, but this is consistent with the gap structure.

---

### Finding 6: The Real Obstruction Is the Pred-Chain Bottom

The gap scenario has a pred-chain p^[k](pb) for k = 0, 1, 2, ... with values strictly
decreasing, bounded below by L. This pred-chain has NO minimum in the ordering (it's
infinite, decreasing). But in a SuccOrder/PredOrder structure on limit_dom, every element
has a predecessor. So pred(p^[N](pb)) = p^[N+1](pb) for all N.

The pred-chain itself is a copy of (-N, <=) embedded in limit_dom. The orbit is a
copy of (N, <=) embedded in limit_dom. Together they form a Z+Z structure.

Now here is the crucial observation: **what is the predecessor of the bottommost pred-chain
elements?**

For any pred-chain element p^[k](pb), the predecessor is p^[k+1](pb) — another pred-chain
element strictly below it with value in [L, p^[k](pb)). This is fine.

But the pred-chain values are decreasing and bounded below by L. So the pred-chain
converges to some M >= L from above. If M > L: the pred-chain is bounded strictly above L,
and there is a "gap" region (L, M) with no limit_dom points (since orbit points are < L
and pred-chain values are >= M). But if no limit_dom in (L, M), then there must be a
limit_dom at M or... but M might be irrational.

If M is irrational and no limit_dom in [L, M]: the pred-chain "converges" to M without
having a minimum. But pred is a well-defined function: every element has a predecessor.
The pred-chain elements DO have predecessors — each other. This is consistent. The
pred-chain extends infinitely downward in value (but always >= M from below), forming
a copy of -N inside the real interval [M, pb.val].

Now: **does the limit_dom have any elements with value in (L, M)?**

By the orbit_below_L argument: no limit_dom in (L with orbit < ..., but orbit < L).
By h_pred_chain_ge_L: all pred-chain values >= L. So no limit_dom in (orbit-sup, pred-chain-inf)
= (L, M) — PROVIDED no OTHER limit_dom points exist in this interval.

But there could be OTHER limit_dom points! The gap argument only shows:
- Points with a <= c and c.val < L: these are orbit points (orbit_below_L)
- Points in the pred-chain: p^[k](pb) for k >= 0

What about points that are NOT in the orbit and NOT in the pred-chain but are > L?

If such a point z exists with z.val in [L, M): then h_lt_pred_chain says s^[n](a) < z
for all n (since h_lt_pred_chain gives s^[n](a) < p^[k](pb) for all k, and z <= some
pred-chain value). But what is pred(z)? pred(z) is some limit_dom point < z. If pred(z).val >= L:
pred(z) is above L, not in orbit. If pred(z).val < L: pred(z) is in orbit (by orbit_below_L).

If pred(z).val < L: then pred(z) = s^[m](a) for some m. Then z = succ(pred(z)) = succ(s^[m](a)) = s^[m+1](a). But s^[m+1](a).val < L. This contradicts z.val >= L.

**Key insight from Finding 6**: If there exists any limit_dom point z with z.val >= L
and z is NOT in the pred-chain, then pred(z).val >= L (since pred(z).val < L would give
pred(z) in orbit and z = succ(pred(z)) = orbit point with value < L, contradicting z.val >= L).

So z.val >= L and pred(z).val >= L. The set of limit_dom points with value >= L forms a
pred-closed set. The pred-chain is one such set. If another point z exists with z.val in [L, M),
then pred^[k](z) is a strictly decreasing sequence (in value) starting at z.val in [L, M) and
remaining >= L. This gives ANOTHER pred-chain (starting from z) interleaved with the original.

This creates a more complex structure, but the key point is: **there cannot be a limit_dom
point z with L <= z.val < M that is strictly between orbit and pred-chain elements in the order**.

Wait — why not? z.val >= L means z > all orbit points (all orbit < L). z.val < M means
z < some pred-chain elements. But h_lt_pred_chain says ALL orbit points < ALL pred-chain
elements. It doesn't say what happens to z relative to pred-chain points. If z.val in [L, M),
then z.val < M <= pred-chain-inf, so z < all pred-chain elements. So z is between orbit
and pred-chain in the order. Then pred(z) must exist. pred(z) < z. If pred(z) is in orbit:
pred(z).val < L, and succ(pred(z)) = z. But succ of an orbit point should be another orbit
point (in the orbit by definition... wait, orbit = {s^[n](a)}, and succ of s^[n](a) = s^[n+1](a)).

Here is the contradiction: if pred(z).val < L, then pred(z) is an orbit point by orbit_below_L.
But succ(pred(z)) = z (by succ_pred). And succ(pred(z)) = succ(s^[m](a)) = s^[m+1](a) for some m.
So z = s^[m+1](a) = orbit point. But z.val >= L contradicts all orbit values < L.

**This is the contradiction**: Any limit_dom point z with z.val in [L, m) would satisfy
z.val >= L (above orbit) and z < all pred-chain. Its predecessor pred(z) must have value
< z.val. If pred(z).val < L, pred(z) is orbit, and z = succ(pred(z)) is orbit with z.val < L
(since orbit values < L). Contradiction. If pred(z).val >= L, we recurse: pred(z) is
also a point with value in [L, something). Taking limit: pred^[k](z) is a decreasing
sequence bounded below by L (in real values). This sequence must stabilize or converge.

It cannot stabilize (strict decrease: pred(x) < x for all x). It converges to some M' >= L.
If M' > L: same argument, we need pred^[k](z) to converge to a limit that is either
rational (in limit_dom) or irrational (not in limit_dom). If not in limit_dom: the pred-chain
{pred^[k](z)} is a legitimate pred-chain with no minimum, values converging to M'. But then
succ_cofinal fails for this pred-chain too.

**So the gap scenario is self-referentially consistent**: We assume succ_cofinal fails.
We show that any limit_dom point above L also starts a new pred-chain. This gives us
multiple interleaved pred-chains but does not by itself give a contradiction.

---

### Finding 7: What Task 129 Actually Learned and Deferred

The Task 129 archive summary reveals:

1. Task 129 confirmed succ_cofinal is the root sorry
2. Task 129's chosen resolution was the Reynolds pipeline, BYPASSING succ_cofinal
3. The Reynolds pipeline (WeakCanonical) still has 5 sorry-propagation issues
4. The monadic FO satisfaction infrastructure (MonadicSentence type) is unresolved
5. Task 129 did NOT attempt to directly prove succ_cofinal

Task 129 phase 5-6 summary: closed chronicle_is_good and one_class via sorry propagation
from k_type_of. The "one_class" argument (Reynolds's 4-line contradiction argument)
was closed formally but via sorry propagation, meaning the logical content is not verified.

**Key learning from Task 129**: The Reynolds route was expected to require 45-65 hours
and still has substantial open work. The direct succ_cofinal proof was not attempted.

---

## Gaps and Shortcomings Identified

### Gap 1: The Existing Analysis Misidentified the Constant-MCS Case

Report 01 says "Z1 is trivially satisfied in the constant-MCS case, making it the hard
case." This is WRONG in a crucial way: **Prior-UZ is NOT satisfied in a constant-MCS
model**. Specifically, if phi is in A and neg phi is not in A, then F(phi) holds at
every point but U(phi, neg phi) fails everywhere (no witness y with neg phi present).

This means the constant-MCS model doesn't satisfy Prior-UZ, so it cannot arise as
the limit domain of the Burgess construction (the limit domain satisfies all MCS
axioms including Prior-UZ via the truth lemma). The constant-MCS case is excluded,
not the hard case.

**Impact**: This eliminates one supposed difficulty but does NOT make the proof easier,
because the non-constant case has its own structural obstacles (Finding 5 above).

### Gap 2: The Prior-UZ Argument Does Not Close the Gap Directly

Even knowing MCS values are non-constant, the discriminating formula phi exists but:
- It might have a "last occurrence" in the orbit, which is consistent (not contradictory)
- backward_G cannot be applied unless phi holds at ALL future points
- Z1 requires G(G(phi)->phi) to be established, which needs control of pred-chain points

The report 01 correctly identifies this as the core difficulty ("control formula truth
at ALL future points, not just orbit/pred-chain points"). Finding 5 above confirms this.

### Gap 3: The Docstring Proof Strategy Is Circular

The proof strategy documented at lines 1540-1557 ("first limit_dom point z at or above L
satisfies pred(z) is a succ-iterate, giving z.val = L") is circular: it uses the very
claim being proved (that all limit_dom points < L are succ-iterates) to bootstrap a
conclusion about z. The argument is valid ONLY if we already know succ_cofinal, which
is what we're trying to prove.

### Gap 4: The Stage Induction Boundary Cases Are Genuinely Hard

The succ_reaches_dom_N proof at lines 1162-1456 has sorries at:
- Line 1297: a in dom(N), b above max(dom(N)). Need succ(max_N_sub) = b, but succ
  might enter limit_dom at a much later stage than N+1.
- Line 1450: a below min(dom(N)), b in dom(N). Same issue in the other direction.

The analysis of these cases (lines 1202-1296) correctly diagnoses the problem:
`omega_chain_dom_new_unique` says at most one new point per step, but it says the
new point at step N+1 is unique among dom(N+1)\dom(N) points. It does NOT say that
the global succ of max_N is in dom(N+1). The global succ of max_N could be inserted
at step M >> N+1.

This is not just a formalization obstacle — it reflects a genuine feature of the
construction: the enumeration processes counterexamples in arbitrary order (via
Cantor unpairing), so the point inserted to resolve the succ of max_N might come
arbitrarily late.

### Gap 5: The Pred-Chain Analysis Does Not Conclude

Finding 6 above shows that the pred-chain structure is self-consistent: pred-chain
points can form an infinite decreasing sequence bounded below by L. Any other limit_dom
points above L must also be pred-chain-like. This is consistent without contradiction
— it just creates a richer gap structure. No immediate contradiction is derivable from
this analysis alone.

### Gap 6: The L Being Rational vs. Irrational Distinction Is Unexplored

The existing analysis casually treats L as either rational or irrational. But:
- If L is rational and in limit_dom: L = s^[m](a) for some m (by orbit_below_L, since
  L is an orbit point if in orbit and below L, but L itself might be in limit_dom with
  L.val = L). This is impossible since orbit values < L strictly.
- If L is rational and NOT in limit_dom: possible, but then what is pred of the first
  pred-chain element > L? Its predecessor must be < it and in limit_dom. If pred < L:
  it's in orbit. pred of first-pred-chain = last orbit point? But orbit has no maximum.

Actually: if L is rational and NOT in limit_dom, and the first pred-chain element is
pb with pb.val > L, then pred(pb) must have value < pb.val. Could pred(pb) < L? By
le_pred_iff: a ≤ pred(pb) ↔ a < pb. For all orbit points s^[n](a) < pb (since orbit < pred-chain),
we have s^[n](a) ≤ pred(pb). So pred(pb).val >= L (since orbit values converge to L from below
and all are ≤ pred(pb)). Actually: all orbit values < pb means all orbit values ≤ pred(pb).
So pred(pb).val >= sup(orbit values) = L. So pred(pb).val >= L. Since pred(pb) < pb and
pred(pb).val >= L: pred(pb) is itself a pred-chain element (value >= L, above orbit).

This confirms pred-chain is pred-closed (downward), as noted in Finding 6.

---

## Questions That Need Answers

### Question 1: Does the Truth Lemma Explicitly Require Non-Constant MCS?

The truth lemma for Until (phi U psi at x iff exists y > x with psi at y and phi
intermediate) — is this PROVED for the limit chronicle? If so, combining with Prior-UZ
being in every MCS and the implication property should give a formal contradiction with
constant-MCS scenarios via Prior-UZ. Is this already formalized in ChronicleConstruction.lean?

Answer from the code: `limit_satisfies_c5_strong` proves that U(eta, xi) in limit_f(x)
implies exists y > x with eta at y and xi at all intermediate points. And conversely
(from c5-completeness). So YES, the truth lemma for U is formalized. This means:

If phi in A and the construction produces a constant-MCS model, then:
- Prior-UZ in A (it's an axiom, hence in every MCS via theorem_in_mcs)
- Implication property: F(phi) in A -> U(phi, neg phi) in A
- F(phi) in limit_f(x) for some/all x: does F(phi) hold? By the truth lemma for F:
  F(phi) in limit_f(x) iff exists y > x in limit_dom with phi in limit_f(y).
  If limit_f(y) = A for all y, and phi in A, then F(phi) is semantically true everywhere.
  By the truth lemma, F(phi) = F(phi) in limit_f(x) for all x. So implication property
  gives U(phi, neg phi) in limit_f(x) = A. But U(phi, neg phi) in A means:
  exists y > x in limit_dom with neg phi in limit_f(y) = A. But phi in A and
  neg phi in A contradicts consistency of A. This IS a formal contradiction.

**This means the constant-MCS case IS formally excluded and the non-constant case is
the only possibility.** This is a stronger result than report 01 claims. The constant-MCS
case is not "hard" — it's IMPOSSIBLE given the formalized truth lemma + Prior-UZ.

### Question 2: Is There a Proof via Prior-UZ Applied to the Discriminating Formula?

Given that non-constant MCS is guaranteed, can the Prior-UZ argument be made to work?
The argument would need:
1. Find phi that distinguishes orbit from pred-chain points (exists by non-constancy)
2. Apply Prior-UZ to phi to get U(phi, neg phi) wherever F(phi) holds
3. Use U(phi, neg phi) to find the "nearest phi witness" from orbit points
4. Use Z1 or backward_G to propagate

The difficulty: even with a discriminating phi, the gap between orbit and pred-chain
means we don't know what happens to phi in the gap region. The orbit approaches L,
and pred-chain is above L. There are no limit_dom points in (L, L+epsilon) for small
epsilon. So "all future points" from a late orbit point include:
- Later orbit points (phi might be present or absent)
- pred-chain points (phi might be present or absent)

Unless phi is defined to be "present at orbit and absent at pred-chain", backward_G
won't work (since phi might be absent at some orbit point between x and the pred-chain).

### Question 3: Can U(T, bot) = next_top Itself Be the Discriminating Formula?

next_top = U(T, bot) is in limit_f(x) for ALL x in limit_dom (by h_discrete). So it
doesn't distinguish orbit from pred-chain. This is not useful.

But WHAT IS in limit_f(x) at orbit vs. pred-chain points? Since MCS are non-constant
by Question 1's analysis, there must exist phi with phi in limit_f(orbit_x) but phi not
in limit_f(pred_y), or vice versa. But we have NO INFORMATION about which formula
distinguishes them, and no formula is "named" by the construction.

The construction chooses MCS values for new points using `eliminate_potential_counterexample`,
which invokes `BurgessR3Maximal`. The resulting MCS at each new point is some extension
of the relevant U/S witness MCS — but we have no explicit control over which formulas
are in/out.

### Question 4: Does the Proof Need the Least-Upper-Bound Property of R in a New Way?

The existing proof uses R to show the orbit sequence converges (uses BddAbove + Monotone
to get a limit L). Could the convergence be used more directly? For instance:

- The orbit values are rational (each s^[n](a).val is rational, in limit_dom)
- Their sup in R is L
- L might be irrational

If L is rational and in limit_dom: the orbit approaches L from below, and L is in
limit_dom. L is NOT in the orbit (since orbit values strictly increase and are < L).
But then: what is L's predecessor? pred(L) is some limit_dom point < L. pred(L).val < L.
But pred(L) must be in the orbit (by orbit_below_L: pred(L).val < L and pred(L) >= a).
So pred(L) = s^[m](a) for some m. Then succ(pred(L)) = succ(s^[m](a)) = s^[m+1](a) = L.
So s^[m+1](a) = L, meaning s^[m+1](a).val = L.val. But the orbit values are < L
(from h_not_cofinal since b >= L means s^[m+1](a) >= b, contradicting h_not_cofinal).
**Wait**: b >= s^[m+1](a) = L means L <= b.val. And L is the limit with L <= b.val (h_le_b).
If L = s^[m+1](a).val then s^[m+1](a) >= b (since s^[m+1](a).val = L and L <= b.val means
s^[m+1](a) >= b by L = b if L = b.val, but L could be < b.val). Actually:
b <= s^[m+1](a) iff s^[m+1](a).val >= b.val, which requires L >= b.val. But L <= b.val
from h_le_b. So b <= s^[m+1](a) iff L >= b.val, which with L <= b.val gives L = b.val.
If L = b.val and L in limit_dom: then L is a limit_dom point equal to b. That means
b has the same rational value as L, so b.val = L. Then b <= s^[m+1](a) iff b.val <= s^[m+1](a).val.
Since s^[m+1](a).val = L = b.val, we have b <= s^[m+1](a) and s^[m+1](a) <= b. So
s^[m+1](a) = b. But this contradicts h_not_cofinal (which says s^[n](a) < b for ALL n).

**This is an actual contradiction**: If L = b.val and L is in limit_dom, then the
argument above shows s^[m+1](a) = b, contradicting h_not_cofinal (n = m+1).

So: if L is rational AND in limit_dom AND L = b.val, we get a contradiction.
But we can't assume L = b.val in general (we only know L <= b.val from h_le_b).

If L < b.val: the orbit approaches L < b.val from below. The first case (L > pred(b).val)
was already handled. The second case is L <= pred(b).val = the sorry case.

---

## Confidence Level

### Is succ_cofinal provable from existing infrastructure?

**LOW CONFIDENCE** that it can be proved via the currently available tools in the
already-built-up context (backward_G, backward_F, orbit_below_L, h_lt_pred_chain,
z1_in_mcs, etc.).

**MEDIUM CONFIDENCE** that a proof EXISTS mathematically, using Prior-UZ non-constancy
plus a careful combinatorial argument about where the orbit's limit meets the pred-chain.

**HIGH CONFIDENCE** that the docstring proof strategy (lines 1540-1557) is incorrect
as written and the sorry represents a genuine proof gap, not just a formalization difficulty.

### Is the gap scenario actually possible in this construction?

**HIGH CONFIDENCE** that in the constant-MCS case, the gap is formally impossible
(excluded by truth lemma + Prior-UZ, as shown in Question 1). The constant-MCS case
is formally contradictory given the formalized infrastructure.

**MEDIUM CONFIDENCE** that the non-constant-MCS gap scenario is also impossible, but
the proof of impossibility requires additional work beyond what's currently formalized.

### What approach has the best chance of success?

**Highest probability approach**: Use the truth lemma + Prior-UZ to formally establish
non-constant MCS in the gap scenario (this should be formalizable from existing infrastructure),
then use the explicit formula non-constancy to apply a more careful Z1 argument. The
key missing piece is controlling formula truth in the gap region.

**Alternative approach that might be simpler**: Show directly that if pred-chain values
form an infinite decreasing sequence bounded below (converging to M >= L), then there
must be a limit_dom point at M (by a "first element" argument using Prior-SZ or similar),
and this first element's predecessor would be in the orbit, giving the orbit reaches M,
contradicting M >= L and orbit < M. This argument uses Prior-SZ in a symmetric way
to how the orbit-analysis uses Prior-UZ.

**Risk**: Both approaches require careful interaction with the MCS consistency
infrastructure and the truth lemma, which adds formalization complexity.

### The Reynolds/Doets bypass (Task 129 approach)

Task 129's WeakCanonical pipeline remains unfinished. If the succ_cofinal proof is truly
intractable, completing Task 129 is the only alternative. The key blocker there is the
MonadicSentence FO satisfaction infrastructure (5 sorry-propagation issues in k_type_of).

---

## Summary of Critical Gaps

1. The constant-MCS case is ruled out by Prior-UZ, not the "hard case" — this is a
   CORRECTION to report 01's analysis.

2. The docstring proof strategy at lines 1540-1557 is circular and should be replaced
   with a different approach.

3. The non-constant MCS case has the necessary discriminating formula, but the Z1
   argument requires controlling formula truth in the gap region (orbit + pred-chain
   separate, unknown behavior in between).

4. The Prior-SZ dual argument (show the pred-chain has a minimum, that minimum's
   predecessor is in orbit, orbit reaches the minimum) may be the most promising
   unexplored approach.

5. Task 129's bypass route remains available but requires substantial new infrastructure
   for FO satisfaction in MonadicSentence types.
