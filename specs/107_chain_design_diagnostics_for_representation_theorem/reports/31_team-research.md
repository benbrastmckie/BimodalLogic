# Research Report: Task #107 — Dependency Chain Resolution and Critical Path

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1777270198_275251

## Summary

Four teammates resolved the Phase 3 blocker. Key conclusions: (1) BUC cannot bypass C4 — finite-stage g-population is the only correct path per Burgess. (2) FUC sorries are INDEPENDENT of C4 — they need C5-with-guard, not C4. This enables parallel workstreams. (3) g(x,y) does NOT need to be MCS — Lemma 2.6 works directly from "gamma not in g(x,y)". (4) The seed problem is confined to C5 elimination; burgessR3_absorption handles C4 splitting. (5) gamma=top makes the C4 hard case trivially False.

## Key Findings

### 1. Two Independent Workstreams (C confirmed)

The 4 sorry sites split into two INDEPENDENT problems:

**Workstream A — C4 hard case (lines 332, 448):**
- Requires BurgessR3Maximal g-values at finite stages
- Resolution: burgessR3_gamma_not_in_B + Lemma 2.6
- Blocks: limit_forward_G, BUC, everything downstream

**Workstream B — FUC (lines 615, 619):**
- Requires C5-with-guard (phi at intermediate points)
- Resolution: C5 + C3 + populated g-values + limit_g
- Does NOT depend on C4 at all

These can be worked on in parallel.

### 2. BUC Cannot Bypass C4 (A confirmed)

No BX axiom can synthesize `untl(phi,psi)` membership from a semantic witness pattern across a dense domain. The contradiction argument via C4 is the mathematically correct approach (Burgess Claim 2.11). The finite-stage g-population approach is the ONLY viable path.

### 3. g(x,y) Does NOT Need to Be MCS (D confirmed)

Previous sessions assumed g(x,y) must be MCS (via R3Maximal_is_mcs) to get gamma.neg from "gamma not in g(x,y)." This is WRONG under BurgessR3Maximal (which is anti-monotone, so maximality does not force MCS).

The correct argument: given gamma not in g(x,y) (from burgessR3_gamma_not_in_B), apply Lemma 2.6 directly. Lemma 2.6 takes R(f(x), g(x,y), f(y)) and "gamma not in g(x,y)" and produces D with gamma.neg in D, plus new interval sets B' and B''. No MCS requirement on g(x,y).

### 4. Seed Problem Is Confined (B confirmed)

The seed construction for BurgessR3Maximal is only needed at:
- **C5 elimination** (new endpoint): Need a seed for the new interval. Lemma 2.4 produces the endpoint; the interval seed needs burgessR3.
- **C4 splitting** (Lemma 2.6): burgessR3_absorption handles this — if g(x,y) satisfies burgessR3 and D splits it, the sub-intervals inherit burgessR3.

For C5, the kernel set K = {beta : for all gamma in C, untl(beta,gamma) in A AND for all alpha in A, snce(beta,alpha) in C} is deductively closed when non-empty (B proved via BX7 + BX2).

### 5. gamma=top Edge Case Is Trivial (C, D confirmed)

If gamma=top in the C4 hard case: burgessR3(f(x), g(x,y), f(y)) with top in g(x,y) forces untl(top, delta) = F(delta) in f(x). But neg(F(delta)) = G(neg(delta)) in f(x) (from the C4 counterexample). Contradiction. So the counterexample premises are inconsistent. This sub-case produces False directly — no need for Lemma 2.6.

More generally: if g(x,y) is non-empty and satisfies burgessR3, then for ANY beta in g(x,y) and delta in f(y), untl(beta,delta) in f(x). If neg(untl(gamma,delta)) in f(x) and gamma in g(x,y), immediate contradiction. The gamma=top case is just a special instance.

### 6. Correct Architecture (D confirmed from Burgess)

Burgess's proof has zero circularity:
1. Build omega chain maintaining C0-C5 + burgessR3Maximal g-values at every finite stage
2. C4 holds at every finite stage via Lemma 2.9 (uses Lemma 2.6 + burgessR3)
3. At the limit: C4 carries over. forward_G follows from C4. Truth lemma by formula induction.
4. BUC = backward Until case of truth lemma, uses C4 at limit
5. FUC = forward Until case of truth lemma, uses C5 + C3 at limit

The codebase's error was trying to prove C4 at the limit using forward_G (which depends on C4). Burgess proves C4 at FINITE STAGES.

## Recommendations

### Phase 3 Unblocking Strategy

The seed problem has a clear solution path:

1. **For C5 elimination (new endpoint):** Construct kernel set K from g_content(A) filtered by burgessR3 condition. If K is empty, the empty DCS vacuously satisfies burgessR3 — apply Zorn from there. If K is non-empty, it's a DCS (proved by B) — apply burgessR3Maximal_extension_exists.

2. **For C4 splitting (Lemma 2.6):** burgessR3_absorption gives the sub-interval burgessR3 for free. No new seed needed.

3. **For other eliminations (density, g_prop, h_prop):** These insert points and need g-values. Use burgessR3_absorption to derive g-values for new sub-intervals from the parent interval's g-value.

### Parallel Implementation Plan

**Wave 1 (independent):**
- Agent A: Implement Lemma 2.6 for burgessR3 + close C4 hard case (Workstream A)
- Agent B: Implement C5-with-guard + close FUC (Workstream B)

**Wave 2 (after Wave 1):**
- Final validation: lake build, sorry count = 0, #print axioms clean

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | BUC without C4 | completed | Confirmed BUC requires C4; finite-stage g-population is only path |
| B | Seed construction | completed | Kernel set K is DCS when non-empty; seed confined to C5 |
| C | Validate chain | completed | FUC is INDEPENDENT of C4; gamma=top trivially False |
| D | Truth lemma architecture | completed | g(x,y) need not be MCS; Lemma 2.6 works directly; zero circularity in Burgess |
