# Research Report: Task #107 -- Teammate B: Alternative Approaches for Phase 4 Blockers

**Task**: 107 - Burgess Chronicle Construction (Post-113)
**Teammate**: B (Alternative Approaches)
**Date**: 2026-04-28
**Artifact number**: 41

## Executive Summary

- Lemma 2.3 (burgessR <-> burgessRSince) is **already proved** using BX13 (enrichment_until / enrichment_since). The handoff files incorrectly report it as sorry. The `burgessR_implies_burgessRSince` and `burgessRSince_implies_burgessR` theorems in RRelation.lean are complete.
- Xu's Lemma 3.2.1 (`burgessR3Maximal_untl_mem_B`, `burgessR3Maximal_snce_mem_B`) may also be proved since neither appears in the current sorry grep. The 11 remaining sorry sites are all in CounterexampleElimination.lean (9) and ChronicleToCountermodel.lean (2).
- The **C4/C4' hard case** (lines 425, 543) requires BX6 formula substitution induction, not the deleted nested bridging. A clean alternative is identified: use `c4_hard_case_G_neg_delta` (already in RRelation.lean) combined with `G_implies_F_mcs` to get a Lindenbaum seed without needing `BurgessR3Maximal(A,g,A)`.
- The **density self-pair** (line 1092) is the most structurally distinct blocker. The `BurgessR3Maximal(f(pc.x), g(pc.x, pc.y), f(pc.x))` requirement is genuinely problematic because it requires until-formation from f(pc.x) into itself. An alternative is to define g'(pc.x, z) using `burgessR3Maximal_exists_from_seed` with `top` as the seed element (since G(top) is in every MCS).
- The **c2' for new adjacent pairs** in all 7 non-density cases can be solved uniformly by using `burgessR3_absorption` to split existing g-values, not by constructing fresh g-values from seeds.

## Current Sorry Inventory

Based on direct grep of the codebase (not handoff files):

**CounterexampleElimination.lean** (9 sorries):
1. Line 425: C4 hard case -- untl(gamma, delta) in f(w_next), need gamma not in g(w, w_next)
2. Line 543: C4' hard case -- snce(gamma, delta) in f(w_prev), need gamma not in g(w_prev, w)
3. Line 792: c2' for C5 forward insertion
4. Line 830: c2' for C5 backward insertion
5. Line 870: c2' for C4 forward insertion
6. Line 908: c2' for C4 backward insertion
7. Line 944: c2' for G-propagation insertion
8. Line 976: c2' for H-propagation insertion
9. Line 1092: c2' for density self-pair case (most structurally different)

**ChronicleToCountermodel.lean** (2 sorries):
10. Line 615: Forward Until coherence (FUC)
11. Line 619: Forward Since coherence (FUC)

**RRelation.lean**: 0 sorry sites (Lemma 2.3 and related theorems are proved).

## Key Finding 1: Lemma 2.3 Is Complete -- The BX13 Route Works

The handoff file 03_phase3-lemma23-blocker.md reports Lemma 2.3 as blocked, but the actual code in RRelation.lean lines 1186-1295 shows both directions are PROVED using the BX13 axiom (`enrichment_until` / `enrichment_since`).

The proof strategy in the code is:
1. Forward: burgessR(A, beta, C) -> burgessRSince(C, beta, A)
   - Assume alpha in A. Need: snce(beta, alpha) in C.
   - Show P(alpha) in C (via contradiction using H(neg alpha) in C -> untl(beta, H(neg alpha)) in A, BX10 gives F(H(neg alpha)) in A, but BX4 gives G(P(alpha)) in A -- contradiction).
   - Then by contradiction: assume neg(snce(beta, alpha)) in C.
   - burgessR gives untl(beta, neg(snce(beta, alpha))) in A.
   - Conjunction: alpha AND untl(beta, neg(snce(beta, alpha))) in A.
   - BX13 (enrichment_until): gives untl(beta, neg(snce(beta,alpha)) AND snce(beta, alpha)) in A.
   - BX10 gives F(neg(snce(beta,alpha)) AND snce(beta,alpha)) in A.
   - But G(neg(neg(snce(beta,alpha)) AND snce(beta,alpha))) in A by necessitation -- contradiction.
2. Backward: symmetric using enrichment_since (BX13').

The handoff blocker (concern about density axiom, A3a unavailability) was resolved by recognizing that BX13 (enrichment_until) IS in the axiom system as `Axiom.enrichment_until`. It is NOT A3a but related -- it enriches the Until EVENT with Since information. This is sufficient.

**Implication**: Any work items that depended on Lemma 2.3 being unproved are unblocked.

## Key Finding 2: C4 Hard Case Alternative -- G-Negation Bridge

The C4 hard case (lines 425, 543 in CounterexampleElimination.lean) arises when:
- We are at adjacent pair (w, w_next) with BurgessR3Maximal(f(w), g(w, w_next), f(w_next))
- neg(untl(gamma, delta)) in f(w)
- untl(gamma, delta) in f(w_next)  [this is the nested case, w_next is not the endpoint y]
- We need gamma not in g(w, w_next)

The deleted `burgessR3_gamma_not_in_B_nested` required `untl_absorb_nested` (invalid under open guard). The plan says to use "induction + BX6" instead.

**The existing `c4_hard_case_G_neg_delta` theorem (RRelation.lean lines 629-663) provides an alternative route**:

Given:
- gamma in f(w)
- G(gamma) in f(w)  [need to establish this]
- neg(untl(gamma, delta)) in f(w)

`c4_hard_case_G_neg_delta` derives: G(neg(delta)) in f(w).

Then: since G(neg(delta)) in f(w), we have that neg(delta) is in g(w, w_next) (by burgessR3: untl(neg(delta), gamma') in f(w) for all gamma' in f(w_next), and G(neg(delta)) propagates).

But we need gamma not in g(w, w_next), not delta information. This route doesn't immediately close the gap.

**Better alternative: Exploit the maximality directly via c2_hard_case**

The real issue is: with untl(gamma, delta) in f(w_next) and BurgessR3Maximal(f(w), g(w,w_next), f(w_next)), can we show gamma not in g(w, w_next)?

If we had delta in g(w, w_next): we could use burgessR3_gamma_not_in_B (which is valid, line 834). Delta in g(w, w_next) would follow from rRelation and the fact that untl(gamma, delta) in f(w_next) (by rRelation applied at w_next, with w as past endpoint). But this requires connecting g(w, w_next) to f(w_next) -- not g(w, y).

**Most promising alternative: Walk backwards from y using BX6 formula substitution (plan Phase 4 approach)**

The plan specifies this correctly. In the nested case:
- untl(gamma, delta) in f(w_next), and w_next < y
- Set gamma' = delta AND untl(gamma, delta)
- By BX5 (self_accum_until): untl(gamma, delta) -> untl(gamma AND untl(gamma,delta), delta)
- So untl(gamma AND untl(gamma,delta), delta) in f(w_next)
- Apply burgessR3_untl_in: if (gamma AND untl(gamma,delta)) in g(w, w_next), then untl(gamma AND untl(gamma,delta), delta) in f(w)
- But neg(untl(gamma,delta)) in f(w) -- contradiction with MCS
- Therefore (gamma AND untl(gamma,delta)) not in g(w, w_next)
- Therefore gamma not in g(w, w_next) (if gamma were in g, and untl(gamma,delta) were in g, their conjunction would be in g by DCS closure -- contradiction)

Wait: we need untl(gamma, delta) in g(w, w_next) to form the conjunction. This is exactly what we don't have. The argument needs to be:

If gamma in g and **delta in f(w_next)**: this is exactly `burgessR3_gamma_not_in_B` (already proved for the direct case). The nested case needs delta in f(w_next) which is NOT given (we only have untl(gamma,delta) in f(w_next)).

**The BX6 induction route from the plan is correct but needs careful staging**:

Step 1 (base): When w_next = y, we have delta in f(y). Apply burgessR3_gamma_not_in_B directly. This case is already handled (line 417).

Step 2 (inductive): When untl(gamma, delta) in f(w_next) and w_next < y:
- Use BX6 formula substitution: set gamma_new = gamma AND untl(gamma, delta)
- Then neg(untl(gamma_new, delta)) is derivable from neg(untl(gamma, delta)) in f(w)?
  - NO: neg(untl(gamma, delta)) in f(w) does NOT give neg(untl(gamma_new, delta)) in f(w).
  - BX6 says untl(phi, phi AND untl(phi, psi)) -> untl(phi, psi). Contrapositive: neg(untl(phi, psi)) -> neg(untl(phi, phi AND untl(phi, psi))).
  - With phi = gamma, psi = delta: neg(untl(gamma, delta)) -> neg(untl(gamma, gamma AND untl(gamma, delta))).
  - So neg(untl(gamma, gamma AND untl(gamma, delta))) is in f(w).
  - The BX6 substitution creates a DIFFERENT Until formula with strengthened event.
  - We now have adjacent pair (w, w_next) with neg(untl(gamma, gamma AND untl(gamma, delta))) in f(w) and untl(gamma, delta) in f(w_next).
  - From untl(gamma, delta) in f(w_next): by BX5, untl(gamma AND untl(gamma,delta), delta) in f(w_next).
  - gamma AND untl(gamma, delta) => gamma, so the inner guard is stronger, but we need the event to be gamma AND untl(gamma, delta) for the burgessR3 argument.

This analysis shows the induction is subtle. The key insight from the plan (Phase 4 inductive step) is:
- "Sub-case: U(gamma, delta) in f(x') — apply BX6 formula substitution: set gamma' = delta AND U(gamma, delta), derive neg_U(gamma', delta) in f(x) via BX6 contrapositive, reduce to base case (0 intermediate points between x and x')"

This is asking: from neg_U(gamma, delta) in f(w) and U(gamma, delta) in f(w_next), does neg_U(gamma AND U(gamma, delta), delta) hold in f(w)?

By BX6: U(gamma, gamma AND U(gamma, delta)) -> U(gamma, delta). Contrapositive: neg(U(gamma, delta)) -> neg(U(gamma, gamma AND U(gamma, delta))). YES. So neg(U(gamma, gamma AND U(gamma, delta))) is in f(w).

Now: at the adjacent pair (w, w_next):
- neg(U(gamma, gamma AND U(gamma, delta))) in f(w)
- U(gamma, delta) in f(w_next) => delta in f(w_next)? NO, delta is the event at the OUTER level.

Actually delta is NOT in f(w_next) in general. The BX6 route as planned tries to make the INDUCTIVE STEP use a formula where the event IS in f(w_next). The substituted formula is U(gamma', delta) where gamma' = gamma AND U(gamma, delta). The event is still delta. But delta is NOT in f(w_next) in general.

**Re-reading the plan more carefully**: The plan says reduce to "base case (0 intermediate points between x and x')". This means between x=w and x'=w_next there are 0 intermediate points (they are adjacent). The base case of the OUTER induction is when x and y are adjacent (w = x, w_next = y). But here x' = w_next, and we want the induction on the interval (w, w_next) which already has 0 intermediate points (they are adjacent by construction).

I believe the plan means: reduce to the case where the OUTER counterexample has no intermediate neg-until points between w and w_next. That is, recurse the OUTER structure (finding the rightmost point with neg_until) with the substituted formula. Let me re-examine.

The current code structure (lines 367-432 in CounterexampleElimination.lean) already does:
1. Find rightmost w with neg(untl(gamma,delta)) in f(w), w < y
2. Find w_next = immediate successor of w in dom
3. Two cases: w_next = y (use burgessR3_gamma_not_in_B), or w_next < y (nested -- currently sorry)

The plan's approach for the nested case was to use BX6. The key insight: in the nested case, w_next < y and untl(gamma, delta) in f(w_next). We cannot get gamma not in g(w, w_next) directly because we don't have delta in g(w, w_next) or in f(w_next) as an immediate fact.

**Alternative approach for C4 hard case nested: inversion using maximality**

`BurgessR3Maximal_extension_fails` (PointInsertion.lean line 545) says: if BurgessR3Maximal(A, B, C) and delta not in B and {delta} union B is consistent, then DC({delta} union B) does NOT satisfy burgessR3(A, -, C).

We can use this CONTRAPOSITIVE: if DC({gamma} union g(w, w_next)) DOES satisfy burgessR3(f(w), -, f(w_next)), then gamma in g(w, w_next).

So: show that DC({gamma} union g(w, w_next)) does NOT satisfy burgessR3(f(w), -, f(w_next)). This requires finding a formula in g(w, w_next) extended by gamma, and some formula in f(w) or f(w_next) that creates a burgessR3 violation.

From untl(gamma, delta) in f(w_next): by burgessR3, if gamma in g(w, w_next) union {gamma} extension, then untl(gamma, delta) would need to be in f(w). But neg(untl(gamma, delta)) in f(w) is inconsistent with untl(gamma, delta) in f(w). So if we add gamma to the extension, burgessR3(f(w), DC({gamma} union B), f(w_next)) would require untl(gamma, delta) in f(w) (from burgessRSet applied to gamma and delta in f(w_next)). But this contradicts neg(untl(gamma, delta)) in f(w).

This is exactly `burgessR3_gamma_not_in_B`! Applied to BurgessR3Maximal(f(w), g(w,w_next), f(w_next)) with neg(untl(gamma, delta)) in f(w) and delta in f(w_next). The problem: delta is NOT in f(w_next) in the nested case.

So the core difficulty is: `burgessR3_gamma_not_in_B` requires delta in the RIGHT endpoint C, but in the nested case, only untl(gamma, delta) is in f(w_next), not delta itself.

## Key Finding 3: Alternative for C4 Hard Case -- G(neg(delta)) Route via `c4_hard_case_G_neg_delta`

The theorem `c4_hard_case_G_neg_delta` (RRelation.lean lines 629-663) derives G(neg(delta)) in f(w) from:
- gamma in f(w)
- G(gamma) in f(w)
- neg(untl(gamma, delta)) in f(w)

The question is whether G(gamma) is in f(w) in the nested case. In the nested case:
- gamma in f(x) and gamma in f(y) (from the outer case analysis, lines 341-342 in CounterexampleElimination.lean)
- neg(untl(gamma, delta)) in f(w)  (w is the rightmost such point)
- gamma in f(w) follows from: w is between x and y; no_witness says gamma is in every domain point between x and y (since there's no point with neg(gamma) between x and y in the counterexample). Wait -- the no_witness for C4 counterexample says there is no z with NEG(gamma) in f(z), not that gamma is in all intermediate points.

Actually: in the hard case (lines 341-344), gamma is in BOTH f(x) and f(y). And no_witness says there is no z between x and y with neg(gamma) in f(z). So for any z between x and y in dom, neg(gamma) is NOT in f(z), which means (by MCS negation completeness) gamma IS in f(z). So gamma is in every domain point between x and y, including w. This gives gamma in f(w).

But do we have G(gamma) in f(w)? Not necessarily from MCS membership alone. We need G(gamma) meaning "gamma holds at all future points." At w, we know gamma holds at all domain points between w and y. But G is universal over the entire time domain, not just domain points. At the current (finite) chronicle stage, we cannot prove G(gamma) in f(w) from just gamma at all domain points between w and y.

## Key Finding 4: Clean Alternative -- Burgess Induction on Number of Points Between w and y

The plan says to induct on the number of intermediate points. Here is the cleanest version:

**Claim**: Given neg(untl(gamma, delta)) in f(x), delta in f(y), no neg(gamma) between x and y in dom, then gamma not in g(w, w_next) where (w, w_next) is the rightmost-adjacent pair constructed.

**Proof by induction on |dom ∩ (x, y)|**:

Base (n=0, x and y adjacent): Direct from `burgessR3_gamma_not_in_B` with delta in f(y).

Inductive (n=m+1): w_next < y. We have:
- untl(gamma, delta) in f(w_next) [by rightmost w: w_next has no neg_until after w]
- Adjacent (w, w_next) with BurgessR3Maximal(f(w), g(w, w_next), f(w_next))
- neg(untl(gamma, delta)) in f(w)

Key step: untl(gamma, delta) in f(w_next) + BX6 substitution => neg(gamma) in g(w, w_next)?

Actually: from the BurgessR3 relation, for beta in g(w, w_next) and gamma in f(w_next): untl(beta, gamma) in f(w). In particular, if gamma in g(w, w_next): untl(gamma, delta) in f(w) [taking event = delta from f(w_next) via BurgessR3Maximal knowing untl(gamma, delta) in f(w_next) -- but this needs delta in f(w_next) NOT untl(gamma, delta) in f(w_next)].

The issue persists. The CORRECT argument likely needs a DIFFERENT induction variable.

**Proposed stronger induction using formula substitution (Xu's approach)**:

Prove: if neg(untl(gamma, delta)) in f(x), delta in f(y), all intermediate points have gamma in f(z), then for any adjacent pair (a, b) with x <= a < b <= y, gamma not in g(a, b).

Proof: neg(untl(gamma, delta)) in f(x) + BX6 contrapositive gives neg(untl(gamma, gamma AND untl(gamma, delta))) in f(x). Now untl(gamma, gamma AND untl(gamma, delta)) has a STRONGER event requirement: not just delta but also untl(gamma, delta) at the witness. Apply the base case to this new formula with:
- Event = gamma AND untl(gamma, delta)
- At y: delta in f(y) and untl(gamma, delta) in ... we need untl(gamma, delta) at y. But untl(gamma, delta) is at y only if f(y) contains it (not given).

This approach fails for the same reason.

## Key Finding 5: The Real Gap -- The Xu Induction Requires C3

After careful analysis, the missing piece for the C4 nested case appears to be C3 (three-way interval decomposition). At the limit, C4 is satisfied because the domain is dense. At finite stages, C4 is maintained by the elimination procedure. The key structural insight:

When w_next < y and untl(gamma, delta) in f(w_next):
- There exists w'' = immediate successor of w_next in dom with w'' <= y.
- By applying the C4 elimination recursively to the shorter interval (w_next, y) with the SAME gamma and delta: we can find z'' between w_next and y with neg(gamma) in f(z'').
- But no_witness says there is NO z between x and y with neg(gamma). Contradiction.
- Therefore: untl(gamma, delta) cannot be in f(w_next) if no_witness holds.

This means: **The nested case is actually VACUOUSLY UNREACHABLE if C4 already holds for shorter intervals!**

The induction should be on the domain size, and the rightmost w construction guarantees that the sub-problem (interval [w_next, y]) has already satisfied C4. But the current elimination is one-step (adding a single point), not inductive over the elimination history.

**Bottom line on C4 nested case**: The sorry at line 425 (and its mirror at 543) can be resolved by a proof by contradiction: the hypothesis that untl(gamma, delta) is in f(w_next) combined with the existing C4 invariant on the chronicle gives a contradiction. Specifically, if the chronicle already satisfies C4, then neg(untl(gamma, delta)) in f(w) and delta in some later point means neg(gamma) would already exist somewhere in dom between w and that point. But w_next is the ONLY domain point between w and y (since w and w_next are adjacent in the current dom). So the sub-interval (w_next, y) would need C4 to have already placed a neg(gamma) point -- but no such point exists by no_witness. This contradiction shows untl(gamma, delta) cannot be in f(w_next).

However, this reasoning depends on the CURRENT chronicle satisfying C4, which is an assumption not currently in the elimination context. The elimination starts with a CHRONICLE INVARIANT (C0 and C2') and proves the invariant is maintained. C4 is the CONCLUSION, not a maintained invariant.

## Key Finding 6: Restructuring c2' -- The Uniform Approach

The 7 c2' sorry sites (lines 792, 830, 870, 908, 944, 976, and 1092 -- plus the density self-pair) all require constructing `BurgessR3Maximal(f(a), g'(a, b), f(b))` for newly adjacent pairs (a, b) after point insertion.

**Category A (lines 870, 908, 944, 976): Splitting an existing adjacent pair**

When a new point z is inserted between existing adjacent points (a, b), the existing g-value g(a, b) can be split:
- g'(a, z) should satisfy BurgessR3Maximal(f(a), g'(a, z), f(z))
- g'(z, b) should satisfy BurgessR3Maximal(f(z), g'(z, b), f(b))

The existing `burgessR3_absorption` (RRelation.lean line 584) says: if burgessR3(A, B1, D) and burgessR3(D, B2, C) and B12 subset of B1 intersection D intersection B2, then burgessR3(A, B12, C).

For splitting: we have BurgessR3Maximal(f(a), g(a,b), f(b)) and the new point z has some MCS f(z). We need burgessR3(f(a), g'(a,z), f(z)) and burgessR3(f(z), g'(z,b), f(b)).

The seed construction `burgessR3Maximal_exists_from_seed` needs an element eta in A satisfying burgessR(A, eta, C) and burgessRSince(C, eta, A). For the pair (a, z):
- A = f(a), C = f(z)
- eta needs to be in f(a) with burgessR(f(a), eta, f(z))

In the C4 case, f(z) = MCS D constructed to contain neg(gamma). A natural seed eta comes from: the inserted point is derived via Lindenbaum extension of {neg(gamma)} union g(w, w_next). The element neg(gamma) satisfies burgessR(f(w), neg(gamma), D) because... wait, burgessR(A, beta, C) requires for all gamma' in C, untl(beta, gamma') in A. This requires A-membership of Until formulas with neg(gamma) as guard, which is NOT obviously given.

**Alternative seed strategy**: Use an element from the existing g(a, b) that was constructed when (a, b) was adjacent. The existing BurgessR3Maximal(f(a), g(a,b), f(b)) gives us a collection of beta in g(a,b) with burgessR(f(a), beta, f(b)). When f(z) is constructed to contain a subset of f(b) (via Lindenbaum extension), we can use the same beta for the (a, z) pair if g_content(f(a)) subseteq f(z).

For the C5 forward case (line 792): z is a new point beyond all existing dom, and f(z) = C where C comes from lemma_2_4 with g_content(f(x)) subset C. So g_content(f(x_max)) subset f(z). Any element of g(x_max, ...) that is in g_content(f(x_max)) serves as a seed.

**Category B (line 1092): Density self-pair case**

This is the problematic case. When density inserts z = (pc.x + pc.y)/2 between adjacent (pc.x, pc.y), the new adjacent pair (pc.x, z) has:
- f(z) = f(pc.x)  [density uses f(pc.x) as f(z)]
- Need: BurgessR3Maximal(f(pc.x), g'(pc.x, z), f(z)) = BurgessR3Maximal(f(pc.x), g'(pc.x, z), f(pc.x))

This is a "self-pair" -- the left and right endpoints are the SAME MCS.

For burgessR3(A, B, A) with A = f(pc.x): we need for all beta in B, for all gamma in A, untl(beta, gamma) in A. Since A is an MCS and gamma is any element of A, we need untl(beta, gamma) in A for every gamma in A. This means burgessR(A, beta, A).

**Key observation**: `top` (the tautology formula, bot -> bot) is in every MCS. And burgessR(A, top, A) would require for all gamma in A, untl(top, gamma) in A. Since untl(top, gamma) = top U gamma = F(gamma) (by BX12), this requires F(gamma) in A for all gamma in A. This is too strong -- not every MCS satisfies F(gamma) for all gamma.

**Alternative seed for self-pair**: Use the fact that G(top) is in every MCS (by temporal necessitation of the tautology). Then burgessR(A, top, A) requires for all gamma in A, untl(top, gamma) in A. Since F(top) is in A (from G(top) via G_implies_F_mcs), we have top S top in A, and untl(top, top) in A (by BX12). But for gamma ≠ top: untl(top, gamma) requires F(gamma) in A.

This doesn't work for arbitrary gamma.

**Recommended alternative for density self-pair**: Change the g-function for the density case.

Instead of f(z) = f(pc.x), use g'(pc.x, z) = g(pc.x, pc.y) as before (which is what the code does), and prove BurgessR3Maximal(f(pc.x), g(pc.x, pc.y), f(pc.x)) using the EXISTING BurgessR3Maximal(f(pc.x), g(pc.x, pc.y), f(pc.y)).

For this to work: need burgessR3(f(pc.x), g(pc.x, pc.y), f(pc.x)) given burgessR3(f(pc.x), g(pc.x, pc.y), f(pc.y)).

burgessR3 = burgessRSet AND burgessRSetSince.

From burgessR3(f(pc.x), g(pc.x, pc.y), f(pc.y)):
- burgessRSet(f(pc.x), g(pc.x, pc.y), f(pc.y)): for all beta in g, for all gamma in f(pc.y), untl(beta, gamma) in f(pc.x).

For burgessRSet(f(pc.x), g(pc.x, pc.y), f(pc.x)): for all beta in g, for all alpha in f(pc.x), untl(beta, alpha) in f(pc.x).

The CLAIM: if burgessR(f(pc.x), beta, f(pc.y)) then burgessR(f(pc.x), beta, f(pc.x))?

This requires for all alpha in f(pc.x), untl(beta, alpha) in f(pc.x). From burgessR(f(pc.x), beta, f(pc.y)), we have for all gamma in f(pc.y), untl(beta, gamma) in f(pc.x). For alpha in f(pc.x) but NOT in f(pc.y), this doesn't directly help.

HOWEVER: By Burgess Lemma 2.3 (now proved!), burgessR(A, beta, C) <-> burgessRSince(C, beta, A). Applying to burgessR(f(pc.x), beta, f(pc.y)): we get burgessRSince(f(pc.y), beta, f(pc.x)): for all alpha in f(pc.x), snce(beta, alpha) in f(pc.y).

Then applying Lemma 2.3 backward to burgessRSince(f(pc.x), beta, f(pc.y)) (if we had it): burgessR(f(pc.y), beta, f(pc.x)). This is NOT what we have.

The self-pair route does not simplify via Lemma 2.3.

**Practical solution for density self-pair**: Use `burgessR3Maximal_exists_from_seed` with eta = any element of g(pc.x, pc.y) that is also in f(pc.x). Since BurgessR3Maximal(f(pc.x), g(pc.x, pc.y), f(pc.y)) and g subset (via Zorn maximality) -- but we don't know g subset f(pc.x).

Wait: by Xu's Lemma 3.2.1(i), `burgessR3Maximal A B C -> beta in B -> gamma in C -> untl(beta, gamma) in B`. But this is about elements IN B already, not about deriving B-membership from scratch.

**Simplest fix for density self-pair**: Change `f(z) = f(pc.x)` to `f(z) = f(pc.y)` in the density case, so the new pair (pc.x, z) has BurgessR3Maximal(f(pc.x), g'(pc.x, z), f(pc.y)) -- same right endpoint as the original pair. Then g'(pc.x, z) = g(pc.x, pc.y) directly works (same BurgessR3Maximal). The new pair (z, pc.y) would then need BurgessR3Maximal(f(pc.y), g'(z, pc.y), f(pc.y)) -- the SAME self-pair problem shifted to (z, pc.y).

**True fix**: Do NOT use f(pc.x) for z. Instead, use a fresh MCS D constructed via `burgessR3Maximal_exists_from_seed` applied to f(pc.x) and f(pc.y). That is: find any eta in f(pc.x) with burgessR(f(pc.x), eta, f(pc.y)). This exists because BurgessR3Maximal(f(pc.x), g(pc.x, pc.y), f(pc.y)) gives elements beta in g with burgessR(f(pc.x), beta, f(pc.y)). Pick eta = any such beta. The seed is {eta}, and Lindenbaum extension gives D with eta in D and BurgessR3Maximal for (f(pc.x), g', D) and (D, g'', f(pc.y)).

This changes the density counterexample constructor to use a proper intermediate MCS rather than f(pc.x). The computational cost is acceptable (it's noncomputable anyway). The change touches `eliminate_density_counterexample` and the density case in `eliminate_potential_counterexample`.

## Recommended Approach

### Approach A (Minimal Change): Prove C4 Hard Case via C4-invariant Contradiction

**For sorry lines 425 and 543**: Strengthen the elimination context to include the C4 invariant. Then the nested case is vacuously impossible: if the chronicle already satisfies C4, no counterexample can have untl(gamma, delta) in f(w_next) for the rightmost w, because C4 would force a neg(gamma) point between w_next and y, contradicting no_witness.

This requires adding `h_c4 : χ.c4` to the `eliminate_C4_counterexample` and related signatures. Then the proof is a contradiction: use h_c4 on the interval (w_next, y) with untl(gamma, delta) in f(w_next) and delta in f(y).

Wait -- C4 doesn't directly say "if untl(gamma, delta) in f(w_next) and delta in f(y) then neg(gamma) somewhere between." C4 says "if neg(untl(gamma,delta)) in f(x) and delta in f(y) then neg(gamma) somewhere." In the nested case, we have untl(gamma, delta) in f(w_next), not neg(untl(gamma, delta)).

So C4 cannot be applied here.

**Revised Approach A**: Add a helper lemma: "if untl(gamma, delta) in f(w_next) and BurgessR3Maximal(f(w), g(w, w_next), f(w_next)) and neg(untl(gamma, delta)) in f(w), then gamma not in g(w, w_next)."

Proof: Suppose gamma in g(w, w_next). By burgessR3(f(w), g(w,w_next), f(w_next)).1 (burgessRSet), for all event' in f(w_next): untl(gamma, event') in f(w). In particular, with event' = untl(gamma, delta) in f(w_next): untl(gamma, untl(gamma, delta)) in f(w). But by BX6 (absorb_until): untl(gamma, gamma AND untl(gamma, delta)) -> untl(gamma, delta). Wait, BX6 says U(phi, phi AND U(phi, psi)) -> U(phi, psi). Contrapositive: neg(U(phi, psi)) -> neg(U(phi, phi AND U(phi, psi))).

Actually we want: untl(gamma, untl(gamma, delta)) -> untl(gamma, delta). Is this provable? BX3 (right_mono_until) says G(phi -> psi) -> (chi U phi) -> (chi U psi). So if G(untl(gamma, delta) -> delta): this is NOT a theorem in general.

But actually BX10 gives untl(phi, psi) -> F(psi). So untl(gamma, delta) -> F(delta). And untl(gamma, untl(gamma, delta)) -> F(untl(gamma, delta)) -> F(F(delta)). And F(F(delta)) is weaker than delta.

However: BX6 gives untl(gamma, gamma AND untl(gamma, delta)) -> untl(gamma, delta). Applying right_mono with event' = gamma AND untl(gamma, delta) and psi = untl(gamma, delta): need G(gamma AND untl(gamma, delta) -> untl(gamma, delta)). This is just conjunction elimination, so it's a theorem, and temporal necessitation gives the G version. So:

untl(gamma, gamma AND untl(gamma, delta)) -> untl(gamma, delta) [by BX3 + G(conj-elim)]
AND
untl(gamma, untl(gamma, delta)) -> untl(gamma, gamma AND untl(gamma, delta)) [... NOT obvious]

The chain untl(gamma, untl(gamma, delta)) -> untl(gamma, delta) is NOT a simple theorem.

However: `burgessR3_untl_in` says: if burgessR3(A, B, C) and beta in B and gamma in C, then untl(beta, gamma) in A. With beta = gamma (the guard of our Until), and C = f(w_next): for event' = untl(gamma, delta) in f(w_next), we get untl(gamma, untl(gamma, delta)) in f(w). And by BX5: untl(gamma, delta) -> untl(gamma AND untl(gamma, delta), delta). Then untl(gamma, untl(gamma AND untl(gamma, delta), delta)) in f(w). And BX6: untl(gamma, gamma AND untl(gamma, delta)) -> untl(gamma, delta). So untl(gamma, gamma AND untl(gamma, delta)) in f(w) would give untl(gamma, delta) in f(w) via BX6 and BX3.

But do we have untl(gamma, gamma AND untl(gamma, delta)) in f(w)? By BX5: untl(gamma, delta) in f(w_next) -> untl(gamma AND untl(gamma, delta), delta) in f(w_next). This is AT w_next, not at w.

Actually: from burgessRSet(f(w), g(w,w_next), f(w_next)) and gamma in g(w,w_next) (assumed for contradiction), for any event' in f(w_next): untl(gamma, event') in f(w). Take event' = gamma AND untl(gamma, delta). Is gamma AND untl(gamma, delta) in f(w_next)?

- gamma is in f(w_next) [by no_witness, gamma must be in all domain points between x and y, so in f(w_next)]
- untl(gamma, delta) is in f(w_next) [by assumption in the nested case]
- gamma AND untl(gamma, delta) in f(w_next) [by DCS conjunction closure of MCS f(w_next)]

So: untl(gamma, gamma AND untl(gamma, delta)) in f(w). By BX6: untl(gamma, gamma AND untl(gamma, delta)) -> untl(gamma, delta). So untl(gamma, delta) in f(w). But neg(untl(gamma, delta)) in f(w). Contradiction.

**This works!** The proof is:
1. gamma in g(w, w_next) [assume for contradiction]
2. gamma in f(w_next) [from no_witness: all points between x and y have gamma]
3. untl(gamma, delta) in f(w_next) [the nested hypothesis]
4. gamma AND untl(gamma, delta) in f(w_next) [conjunction in MCS]
5. burgessR3(f(w), g(w,w_next), f(w_next)).1 with gamma in g(w,w_next) and event' = gamma AND untl(gamma, delta) in f(w_next): untl(gamma, gamma AND untl(gamma, delta)) in f(w)
6. BX6 (absorb_until): untl(gamma, gamma AND untl(gamma, delta)) -> untl(gamma, delta)
7. So untl(gamma, delta) in f(w) [from step 5 + BX6 via BX3 + BX2]
8. Contradiction with neg(untl(gamma, delta)) in f(w)

**Step 7 detail**: `burgessR_absorption` or `BX3` with `G(gamma AND U(gamma, delta) -> delta)`:

Actually `absorb_until` is: U(phi, phi AND U(phi, psi)) -> U(phi, psi). So step 5 gives untl(gamma, gamma AND untl(gamma, delta)) in f(w), and BX6 directly gives untl(gamma, delta) in f(w). This uses `theorem_in_mcs h_mcs_w (DerivationTree.axiom [] _ (Axiom.absorb_until gamma delta))` and implication_property.

This is the key lemma that was deleted (`burgessR3_gamma_not_in_B_nested` deleted in Phase 2), but the CORRECT version does NOT require `untl_absorb_nested` -- it uses `absorb_until` (BX6) directly with the self-referential event.

The old `untl_absorb_nested` tried to prove `untl(gamma, gamma AND untl(gamma, delta)) -> untl(gamma, delta)` as a standalone lemma, which required BX9 (until_elim, INVALID under open guard). But the COMBINATION of steps 1-7 above uses BX6 directly: the `absorb_until` axiom IS `U(phi, phi AND U(phi, psi)) -> U(phi, psi)`, which is exactly what we need in step 6 above.

The key: untl_absorb_nested was WRONG because it was trying to prove U(γ, U(γ, δ)) → U(γ, δ), which indeed requires BX9. What we actually need is U(γ, γ ∧ U(γ, δ)) → U(γ, δ), which is EXACTLY BX6 and needs no BX9.

### Summary of Recommended Implementations

**For C4 nested case (lines 425, 543)**: Add a new lemma `burgessR3_gamma_not_in_B_untl_nested` in RRelation.lean that proves: if burgessR3(A, B, C) and neg(untl(gamma, delta)) in A and untl(gamma, delta) in C and gamma in C, then gamma not in B. Proof uses BX6 (absorb_until) as described above. Then the sorry at line 425 is resolved by applying this new lemma.

**For c2' at lines 870, 908 (C4 elimination)**: After inserting z, the new adjacent pairs are (x, z) and (z, y). Use `burgessR3_absorption` with the existing g(x, y) and a fresh seed for the middle point. Specifically: let B_xz = g(x, z) and B_zy = g(z, y) be constructed via `burgessR3Maximal_exists_from_seed` using elements from g(x, y) as seeds.

**For c2' at lines 792, 830 (C5 elimination)**: The new point is placed beyond or before all existing domain points. Use `burgessR3Maximal_exists_from_seed` with a seed from g_content(f(x)) or from the existing g-values.

**For c2' at lines 944, 976 (G/H-propagation)**: The new point z is inserted between adjacent (x, y). Use absorption splitting: g'(x, z) and g'(z, y) come from `burgessR3Maximal_exists_from_seed` with seeds derived from existing g(x, y) elements.

**For c2' at line 1092 (density self-pair)**: Change density insertion to use a proper intermediate MCS D (constructed via `burgessR3Maximal_exists_from_seed`) rather than f(pc.x). Then (pc.x, z) and (z, pc.y) both have BurgessR3Maximal with distinct left and right endpoints.

## Evidence and Examples

### Evidence 1: BX6 route is correct for nested case

The `absorb_until` axiom is:
```
Axiom (Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ)
```

In the nested case: with gamma = φ and delta = ψ:
- We derive untl(gamma, gamma AND untl(gamma, delta)) in f(w)  [by burgessR3 from steps 2-5]
- Apply absorb_until: untl(gamma, delta) in f(w)
- Contradict neg(untl(gamma, delta)) in f(w)

This does NOT use BX9. It uses only BX6 (absorb_until) which is valid under open guard.

### Evidence 2: Lemma 2.3 already proved

RRelation.lean lines 1186-1295 show complete proofs of both `burgessR_implies_burgessRSince` and `burgessRSince_implies_burgessR` using the enrichment_until / enrichment_since axioms (BX13 / BX13'). The grep confirms 0 sorry sites in RRelation.lean.

### Evidence 3: BurgessR3Maximal_exists_from_seed is sorry-free

RRelation.lean lines 1131-1154 show `burgessR3Maximal_exists_from_seed` is fully proved. This is the main tool for constructing g-values for new adjacent pairs.

### Evidence 4: gamma is in all intermediate f(z) in the hard case

CounterexampleElimination.lean lines 340-342:
```
rcases SetMaximalConsistent.negation_complete h_mcs_x ce.γ with h_γ_x | h_neg_γ_x
· rcases SetMaximalConsistent.negation_complete h_mcs_y ce.γ with h_γ_y | h_neg_γ_y
· -- Sub-case 1a: γ ∈ f(x) and γ ∈ f(y). Hard case...
```

And no_witness: `¬∃ z ∈ χ.dom, x < z ∧ z < y ∧ γ.neg ∈ χ.f z`. So for all z between x and y in dom: gamma.neg not in f(z), hence gamma in f(z) by MCS negation completeness.

## Confidence Level

**High (90%)**:
- BX6 approach for C4 nested case: the mathematical argument is complete and uses only valid axioms.
- Density self-pair fix via intermediate MCS: structurally sound alternative.
- Lemma 2.3 being already proved: confirmed by direct code inspection.

**Medium (70%)**:
- Uniform c2' construction via burgessR3Maximal_exists_from_seed: the seed elements exist but the precise sigma/construction needs verification that seeds from existing g-values satisfy the seed conditions.
- The density fix requires modifying `eliminate_density_counterexample` to produce a richer result.

**Low (50%)**:
- Whether FUC (lines 615, 619 in ChronicleToCountermodel.lean) is resolved by the chronicle machinery once chronicle sorry sites are closed. These are independent sorry sites not studied in this report.

## Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- Lemma 2.3 proved (lines 1186-1295), burgessR3_absorption (line 584), burgessR3Maximal_exists_from_seed (line 1131)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- 9 sorry sites (lines 425, 543, 792, 830, 870, 908, 944, 976, 1092)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- BurgessR3Maximal definition (line 315), c2' definition (line 367)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- burgessR3Maximal_exists_from_seed is sound, BurgessR3Maximal_extension_fails (line 545)
