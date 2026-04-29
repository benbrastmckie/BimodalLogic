# Teammate C Findings: A4a Validity Analysis and Alternative Stress-Testing

**Role**: Critic
**Artifact**: 44
**Date**: 2026-04-28

---

## Key Findings

### Finding 1: A4a IS VALID Under Open-Guard Semantics

**Claim under scrutiny**: "A4a is invalid under strict semantics."

**Verdict**: A4a is VALID under open-guard semantics on all strict linear orders. Previous reports claiming invalidity were wrong or confused A4a with a different axiom (BX9/until_elim).

**A4a**: `U(p,q) AND NOT U(p,r) -> U(q AND NOT r, q)`

**Proof of validity under open-guard semantics**:

Suppose at time t:
- (H1) U(p,q) holds: there exists s1 > t with q at s1, and for all u with t < u < s1, p at u.
- (H2) NOT U(p,r): for every s > t, either NOT r at s, or there exists u with t < u < s and NOT p at u.

We need to show: U(q AND NOT r, q) at t, i.e., there exists s2 > t with q at s2, and for all u with t < u < s2, (q AND NOT r) at u.

**Construction**: We must find an appropriate witness s2. Consider the set of times s > t where r holds AND p holds on the entire open interval (t,s). By (H2), for every such s, there must exist a u with t < u < s where p fails. But if p holds on (t,s), that is a contradiction. So in fact: for every s > t, if p holds on all of (t,s), then r does NOT hold at s.

Now take s1 from (H1). We have q at s1 and p on (t,s1). By the observation above, r does NOT hold at s1. So q AND NOT r holds at s1.

It remains to show q AND NOT r on (t,s1). Take any u with t < u < s1.
- p at u (from H1's guard).
- We need q at u and NOT r at u.

**This is where the argument gets subtle.** We do NOT have q at intermediate points from H1 alone. The Until formula U(p,q) only guarantees p on the guard interval, not q.

**Revised approach**: The witness for U(q AND NOT r, q) need not be s1. We need to find SOME witness.

Consider the infimum approach. Define s* = inf{s > t : NOT p at s OR (r at s AND p on (t,s))}. By (H1), s* <= s1. By (H2), for any s with p on (t,s), r fails at s.

Actually, let me reconsider using a simpler semantic argument.

**Careful proof**: From U(p,q) at t with witness s1:
- q at s1
- p on (t, s1) -- the open interval

From NOT U(p,r) at t:
- For every s > t: NOT(r at s AND p on (t,s))
- Equivalently: for every s > t with p on (t,s), NOT r at s

Since p holds on (t,s1) (from H1), every s in (t,s1] has p on (t,s) (by restriction). In particular, for every s in (t,s1], we have NOT r at s.

So r fails at every point of (t,s1] where p holds on the entire sub-interval (t,s). Since p DOES hold on (t,s1), r fails at every point of (t,s1].

Wait -- more carefully. For s in (t,s1): p holds on (t,s) (since p holds on the larger interval (t,s1) and (t,s) is a subset). So by (H2), NOT r at s. For s = s1: p holds on (t,s1), so NOT r at s1.

So NOT r holds everywhere on (t,s1].

Now we need U(q AND NOT r, q) at t. We need a witness s2 > t with q at s2 and (q AND NOT r) on (t,s2).

Take s2 = s1. Then q at s2 = q at s1 (from H1). And we need (q AND NOT r) on (t,s1).

We have NOT r on (t,s1] (proved above), so NOT r on (t,s1) in particular. But we need q on (t,s1).

**We do NOT have q on (t,s1).** The hypothesis U(p,q) only gives p on (t,s1), not q.

**So the simple approach fails.** The guard of U(q AND NOT r, q) requires BOTH q and NOT r at intermediate points, but U(p,q) only gives p at intermediate points.

**Key insight**: The conclusion is `U(q AND NOT r, q)`, not `U(p AND NOT r, q)`. The guard formula changed from p to q AND NOT r. This is a strong requirement -- it demands q holds at ALL intermediate points.

### Finding 2: Concrete Countermodel Showing A4a IS INVALID Under Open-Guard Semantics

**Frame**: The integers Z with strict order <.

**Valuation**:
- p holds at all integers (everywhere true)
- q holds only at 3
- r holds only at 2

**Evaluation at t = 0**:

U(p,q) at 0: Witness s1 = 3. q at 3? Yes. p on (0,3) = {1,2}? p at 1 = true, p at 2 = true. So U(p,q) holds at 0.

U(p,r) at 0: Witness would need r at some s > 0 with p on (0,s). Try s = 2: r at 2 = true, p on (0,2) = {1}, p at 1 = true. So U(p,r) holds at 0.

**Problem**: NOT U(p,r) fails at 0. So the antecedent `U(p,q) AND NOT U(p,r)` is not satisfied.

**Revised countermodel**: Need U(p,r) to FAIL at t.

**Frame**: Rationals Q with strict order <.

**Valuation at t = 0**:
- p holds everywhere except at 1.5
- q holds at 2
- r holds at 1 and at 3

U(p,q) at 0: Need witness s > 0 with q(s) and p on (0,s). Try s = 2: q(2) = true. p on (0,2): need p at every x in (0,2). But p(1.5) = false. So (0,2) fails. Try s = 1 (if q(1)? No). No valid witness with contiguous p-guard reaching q. U(p,q) fails.

**This is getting complicated. Let me try dense order more carefully.**

**Frame**: Q (rationals) with strict <.

**Valuation at t = 0**:
- p holds everywhere (always true, p = top)
- q holds at 2 (and possibly elsewhere)
- r holds at 3 (and possibly elsewhere)

U(p,q) at 0: witness 2. p on (0,2) (always true). q(2) = true. HOLDS.

U(p,r) at 0: witness 3. p on (0,3) (always true). r(3) = true. HOLDS.

NOT U(p,r) fails. Need to make U(p,r) fail while U(p,q) holds.

So need: some witness for q reachable with p-guard, but NO witness for r reachable with p-guard.

**Let p = top**: Then U(p,r) = U(top,r) at t iff there exists s > t with r(s). This is just F(r). So NOT U(p,r) means NOT F(r), meaning r is false at all future times. But then NOT r holds everywhere, so q AND NOT r = q. And U(q AND NOT r, q) = U(q, q).

So A4a with p = top becomes: `F(q) AND NOT F(r) -> U(q,q)`.

U(q,q) at t means: exists s > t with q(s) and q on (t,s). This requires q to hold at ALL points of some interval (t,s) AND at s.

F(q) only requires q at SOME future point. If q holds at exactly one point (say t=2) and nowhere else, then U(q,q) at 0 would need a witness s with q(s) and q on (0,s). If q only holds at 2, then for s=2, we need q on (0,2), but q fails at e.g. 1. So U(q,q) fails even though F(q) holds.

**COUNTERMODEL (VERIFIED)**:

**Frame**: Q (rationals) with strict <.

**Valuation**:
- p = top (holds everywhere)
- q holds ONLY at t = 2
- r = bot (holds nowhere)

**At t = 0**:
- U(p,q) = U(top, q) at 0: witness s = 2. top on (0,2)? Yes (vacuously, top always holds). q(2)? Yes. **HOLDS**.
- U(p,r) = U(top, bot) at 0: need s > 0 with bot at s. No such s. **FAILS**. So NOT U(p,r) **HOLDS**.
- Antecedent: U(p,q) AND NOT U(p,r) = true AND true = **TRUE**.

- U(q AND NOT r, q) = U(q AND top, q) = U(q, q) at 0: need s > 0 with q(s) and q on (0,s).
  - Only candidate: s = 2. Need q on (0,2). But q holds only at t=2. q(1) = false. **FAILS**.
  - No other candidates since q holds only at 2. **FAILS**.

- Consequent: **FALSE**.

**Therefore A4a is FALSE at t=0 in this model.** The antecedent is true and the consequent is false.

**Verification**: This countermodel works for ANY strict linear order with at least 3 points (e.g., integers, rationals, reals). The key: p = top, r = bot makes U(p,r) equivalent to F(bot) which is always false, so NOT U(p,r) is always true. Meanwhile q holding at exactly one point makes U(p,q) hold (since p=top provides the guard) but U(q,q) fail (since q doesn't hold on any open interval reaching its witness).

### Finding 3: Existing BX Axioms That Mention Until

Complete inventory of BX axioms involving Until:

| Axiom | Formula | Valid (open guard)? |
|-------|---------|---------------------|
| BX2 (left_mono_until) | `(phi->chi) AND G(phi->chi) -> (U(phi,psi) -> U(chi,psi))` | YES |
| BX3 (right_mono_until) | `G(phi->psi) -> (U(chi,phi) -> U(chi,psi))` | YES |
| BX5 (self_accum_until) | `U(phi,psi) -> U(phi AND U(phi,psi), psi)` | YES |
| BX6 (absorb_until) | `U(phi, phi AND U(phi,psi)) -> U(phi,psi)` | YES |
| BX7 (linear_until) | `U(phi,psi) AND U(chi,theta) -> U(phi AND chi, psi AND theta) OR U(phi AND chi, psi AND chi) OR U(phi AND chi, phi AND theta)` | YES |
| BX10 (until_F) | `U(phi,psi) -> F(psi)` | YES |
| BX12 (F_until_equiv) | `F(phi) -> U(top, phi)` | YES |
| BX13 (enrichment_until) | `p AND U(phi,psi) -> U(phi, psi AND S(phi,p))` | YES |
| BX13' (enrichment_since) | `p AND S(phi,psi) -> S(phi, psi AND U(phi,p))` | YES |

**No axiom implies A4a.** A4a requires deriving `U(q AND NOT r, q)` from `U(p,q) AND NOT U(p,r)`. The problem is that no BX axiom can change the guard from p to q (BX2 can only strengthen or weaken guards uniformly via implications, not replace them with event formulas). A4a's essential content is: "if the p-guard reaches q but not r, then q itself serves as a guard reaching q (while excluding r)." This requires q to hold at all intermediate points -- a much stronger claim than what U(p,q) gives us.

**BX7 (linearity)** comes closest by comparing two Until formulas, but its output guards are conjunctions of the INPUT guards, not the event formulas.

### Finding 4: Hodkinson-Reynolds 2006 Does NOT Discuss A4a

Searched `literature/Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md` for A4a, A4, separation, and Burgess axiom references. No matches found. The chapter does not discuss this specific axiom or its equivalents. The axiom systems presented in Hodkinson-Reynolds focus on other formulations.

### Finding 5: A4a's Role in Burgess's Proof Can Be Bypassed

Examining Burgess's Lemma 2.6 proof in detail:

**What Burgess proves**: D0 = {S(alpha,beta) : alpha in A, beta in B} UNION B UNION {NOT delta} UNION {U(gamma,beta) : gamma in C, beta in B} is consistent.

**Where A4a is used**: To show that the typical element zeta = S(alpha,beta) AND beta AND NOT delta AND U(gamma,beta) is consistent. The key step:
1. From R(A,B,C) and delta not in B: exists beta0 in B, gamma0 in C with NOT U(gamma0, beta0 AND delta) in A
2. From U(gamma, beta) in A: apply A5a to get U(gamma, beta AND U(gamma,beta)) in A
3. Apply A4a to U(gamma, beta AND U(gamma,beta)) and NOT U(gamma, beta AND delta) to get U(beta AND U(gamma,beta) AND NOT delta, beta) in A
4. Apply A3a to enrich with S(alpha, beta)

**A4a is essential**: Step 3 transforms the guard from gamma to "beta AND U(gamma,beta) AND NOT delta". No BX axiom can do this. BX7 produces guards that are conjunctions of the original guards, never the event formulas. The key difficulty is getting NOT delta into the guard.

**The current codebase approach (PointInsertion.lean)** bypasses A4a by using a WEAKER version of Lemma 2.6:

```lean
noncomputable def lemma_2_6 ... :
    exists D : Set Formula, SetMaximalConsistent D AND
      delta.neg in D AND g_content A subset D
```

This weaker version only produces D (the MCS) with NOT delta and g_content(A) subset D. It does NOT produce B' and B'' with the full R(A,B',D) and R(D,B'',C) decomposition. The current implementation uses Lindenbaum extension of {NOT delta} UNION g_content(A), which is much simpler than Burgess's D0 construction.

**Critical question**: Does the current weaker Lemma 2.6 suffice for the chronicle construction?

The plan v27 (artifact 43) calls for the FULL Lemma 2.6 (producing B', D, B'' with BurgessR3Maximal) in Phases 6 and 10-11. This full version requires showing D0 is consistent, which requires A4a.

### Finding 6: Alternatives Assessment

**Alternative 1: Add A4a as a new axiom to BX system.**

Pros: Direct, matches Burgess exactly.
Cons: A4a is INVALID under open-guard semantics (countermodel in Finding 2). Cannot be added as a sound axiom.

**Alternative 2: Use Xu's construction instead of Burgess's.**

Xu 1988 does NOT use A4a. His system Sigma_4 omits it. Reynolds 1992 explicitly notes "we are rid of the extra one" (referring to A4a). The Xu construction achieves completeness without Lemma 2.6 in its Burgess form. The codebase already references this (specs/113 teammate-b findings). This is likely the correct path.

**Alternative 3: Restructure Lemma 2.6 to avoid A4a.**

The current weaker `lemma_2_6` in PointInsertion.lean already avoids A4a by producing only D (not B', D, B''). The question is whether this suffices. For the C4 elimination (Lemma 2.9), Burgess applies Lemma 2.6 to R(f(x), g(x,y), f(y)) and uses the B', D, B'' to set g'(x,z) = B', f'(z) = D, g'(z,y) = B''. Without the full decomposition, how do we get g-values?

One approach: use the existing `BurgessR3Maximal_extension_fails` + `dc_delta_B_burgessR3` machinery to construct g-values from D after obtaining D via the weak Lemma 2.6. Specifically:
1. Get D from weak Lemma 2.6 (NOT delta in D, g_content(A) subset D)
2. Construct B' = BurgessR3Maximal between A and D using Zorn
3. Construct B'' = BurgessR3Maximal between D and C using Zorn

This avoids A4a entirely but requires showing that B' and B'' exist (via `burgessR3Maximal_exists_from_seed`). The seed for B' needs burgessR(A, seed, D), and for B'' needs burgessR(D, seed, C).

**The catch**: To get burgessR(A, seed, D), we need: for all beta in seed, gamma in D, U(gamma, beta) in A. If seed = g_content(A) intersect D (or similar), this requires showing U(gamma, beta) in A for appropriate beta. This is where A4a was doing the heavy lifting in Burgess's proof.

**Alternative 4: Use BX13 (enrichment) to replace A4a's role.**

BX13: `p AND U(phi,psi) -> U(phi, psi AND S(phi,p))`. This enriches the EVENT, not the guard. A4a changes the GUARD. These serve fundamentally different purposes. BX13 cannot replace A4a.

### Finding 7: Risk Assessment for Plan v27

Plan v27 (Phases 6-12) assumes Lemma 2.6 and Lemma 2.7 can be formalized in their full Burgess form. Lemma 2.7's proof (lines 178-181) uses A5a and A7a, which ARE in BX (as BX5 and BX7). Let me verify:

**Lemma 2.7 proof uses**: A5a (BX5), A7a (BX7), A3a (BX13). Does NOT use A4a.

**Lemma 2.6 proof uses**: A5a (BX5), A4a (NOT in BX), A3a (BX13).

So **Lemma 2.7 does not depend on A4a** (confirmed by the Phase 5 gate verdict). But **Lemma 2.6 does depend on A4a**. This means:

- Phases 6 (Lemma 2.6 formalization) of plan v27 is BLOCKED by A4a invalidity
- Phases 10-11 (density, C4/g_prop/h_prop via Lemma 2.6) are transitively BLOCKED
- Phase 9 (C5 via Lemma 2.7) is NOT blocked (Lemma 2.7 does not use A4a)

---

## Countermodel

**A4a: `U(p,q) AND NOT U(p,r) -> U(q AND NOT r, q)`**

**Frame**: (Q, <) -- rationals with strict order

**Valuation**:
- V(p) = Q (p is true everywhere)
- V(q) = {2} (q is true only at 2)
- V(r) = emptyset (r is false everywhere)

**At t = 0**:
- U(p,q) at 0: witness s=2, p on (0,2) = true (p everywhere), q(2) = true. **TRUE**.
- U(p,r) at 0: need s > 0 with r(s). No such s exists (r = bot). **FALSE**.
- NOT U(p,r) at 0: **TRUE**.
- Antecedent: TRUE AND TRUE = **TRUE**.
- U(q AND NOT r, q) = U(q, q) at 0: need s > 0 with q(s) and q on (0,s).
  - Only candidate s=2. Need q on (0,2): q(1) = false (q only at 2). **FALSE**.
- Consequent: **FALSE**.

**A4a fails at t=0.** Verified on (Q, <), (Z, <), (R, <), and any strict linear order with >= 3 points.

**Why it fails**: A4a demands that the event formula q can serve as its own guard. But U(p,q) only places the guard p (not q) at intermediate points. When p = top, the guard is vacuous and says nothing about q at intermediate points.

---

## Gaps Identified

1. **Plan v27 Phase 6 is unfeasible**: Lemma 2.6 in full Burgess form requires A4a, which is invalid under open-guard semantics. The consistency argument for D0 cannot go through without A4a.

2. **The claim in PointInsertion.lean that "BX5 + BX6 + BX7 provide A4a's role" is incorrect**: These axioms manipulate guards within their original form (conjunctions of input guards). None can substitute event formulas into the guard position, which is A4a's unique contribution.

3. **The claim in plan v34 that "BX axiom substitutions for A3a/A4a are documented" overstates the case**: BX13 replaces A3a (confirmed, proven in Phase 3). No BX axiom or combination replaces A4a.

4. **The current weak `lemma_2_6` avoids A4a but is insufficient for the full chronicle construction**: It produces only D, not the R(A,B',D) and R(D,B'',C) decomposition needed for g-values.

---

## Risk Assessment

| Risk | Severity | Likelihood | Notes |
|------|----------|------------|-------|
| A4a invalidity blocks full Lemma 2.6 | HIGH | CERTAIN | Countermodel verified |
| Plan v27 Phases 6, 10, 11 infeasible as written | HIGH | CERTAIN | Direct dependency on full Lemma 2.6 |
| Xu-style alternative required | HIGH | HIGH | Must bypass Burgess's Lemma 2.6 entirely |
| Lemma 2.7 remains valid (no A4a dependency) | -- | CERTAIN | Uses only BX5, BX7, BX13 |
| Current weak lemma_2_6 may be extendable | MEDIUM | MEDIUM | Requires novel proof not in Burgess |

---

## Confidence Level

| Finding | Confidence | Notes |
|---------|-----------|-------|
| A4a invalid under open-guard semantics | **VERY HIGH** | Concrete countermodel on (Q,<) with explicit witness |
| No BX axiom implies A4a | **HIGH** | Semantic argument: no BX axiom substitutes events into guards |
| Lemma 2.6 proof requires A4a | **VERY HIGH** | Direct reading of Burgess 1982 proof, step 3 |
| Lemma 2.7 does NOT require A4a | **HIGH** | Direct reading of Burgess 1982 proof; uses A5a, A7a, A3a only |
| Xu construction bypasses A4a | **HIGH** | Literature confirmation from Reynolds 1992 via report 113 |
| Plan v27 Phases 6/10/11 blocked | **HIGH** | Transitive dependency on full Lemma 2.6 |

---

## Recommendations

1. **Accept A4a invalidity as definitive** and stop attempting to derive it from BX axioms.

2. **Pivot Phase 6 to a Xu-style or novel construction** that avoids A4a. The most promising approach:
   - Use the weak `lemma_2_6` (which is sorry-free) to obtain D with NOT delta and g_content(A) subset D
   - Construct BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C) via Zorn separately
   - For the B' existence seed: use the fact that g_content(A) subset D implies burgessR(A, empty_seed, D) can be bootstrapped from BX12 + BX10
   - For the B'' existence seed: this is the harder direction and may require novel proof techniques

3. **Preserve Lemma 2.7 path (Phase 9)**: Lemma 2.7 does NOT depend on A4a and should proceed as planned.

4. **Investigate whether the FULL Lemma 2.6 decomposition is actually needed**: Perhaps the chronicle construction can work with weaker intermediate results that don't require the B' and B'' to satisfy the full BurgessR3Maximal relation simultaneously. The Xu 1988 construction likely provides the template.
