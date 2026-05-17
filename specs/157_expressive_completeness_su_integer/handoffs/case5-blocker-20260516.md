# Case 5 Blocker Analysis - 2026-05-16

## Session: sess_1778993907_e9df35

## Summary

Extensive analysis of Case 5 (`S(a ^ U(A,B), q v U(A,B))`) revealed that the GHR94 formula on p.370 is incorrect. The formula requires `A v (B ^ U(A,B))` at t which is NOT always guaranteed when the original formula holds. This blocks all of Cases 5-8, DualEliminations, SeparationThm, and ExpressiveCompleteness.

## The GHR94 Formula (p.370)

GHR94 claims Case 5 is equivalent to:

```
S(a, B) ^ [A v (B ^ U(A,B))]
v S(A ^ S(a, B), A v B v ~S(~q, ~A))
  ^ [A v (B ^ U(A,B))] ^ ~S(~q, ~A)
```

Both disjuncts contain the factor `A v (B ^ U(A,B))` evaluated at t.

## Counterexample

The following integer temporal structure demonstrates the failure:

- Time points: s=0, t=3
- a(0) = true, a(r) = false for r != 0
- A(1) = true, A(r) = false for r != 1
- B(1) = false (and B(2) = false, etc.)
- q(1) = true, q(2) = true

**LHS verification**: `S(a ^ U(A,B), q v U(A,B))` at t=3:
- S-witness: s=0
- Event: a(0) ^ U(A,B)(0). U(A,B)(0) via u=1: A(1), B on (0,1) = vacuous on integers. OK.
- Guard on (0,3): r=1: q(1)=true. r=2: q(2)=true. OK.
- **LHS holds at t=3.**

**RHS verification**: Both disjuncts require `A(3) v (B(3) ^ U(A,B)(3))`:
- A(3) = false
- B(3) = false
- So `A(3) v (B(3) ^ U(A,B)(3))` = false
- **Both disjuncts fail. RHS is false.**

**Conclusion**: LHS is true but RHS is false. The equivalence fails.

## Why This Counterexample Works

The key insight: on integers, U(A,B)(0) can hold with a VACUOUS B-guard. When u=s+1 (e.g., s=0, u=1), the open interval (0,1) contains no integers, so "B everywhere on (0,1)" is vacuously true. This means U(A,B) can hold without B actually being true at any point.

Meanwhile, the guard `q v U(A,B)` on (s,t) can be satisfied purely by q. This gives a scenario where:
- The S-formula holds (via q covering the guard)
- But B never holds anywhere
- And A doesn't hold at t
- So `A(t) v (B(t) ^ U(A,B)(t))` fails

The GHR94 formula implicitly assumes that the U-cascade produces B-coverage reaching t, which is NOT true in discrete time with vacuous B-guards.

## Root Cause

The issue is specific to **discrete** (integer) time. In dense time (reals), the open interval (s, s+epsilon) is non-empty for any epsilon > 0, so U(A,B) at s always forces B at some point. On integers, consecutive points are distance 1 and the open interval (n, n+1) is empty, making B-guards vacuous.

GHR94 may have been thinking about the proof in terms of dense-time intuition even though the section is explicitly about integer time. The formula may be correct for dense time but fails for integers.

## Approaches Attempted

1. **Direct GHR94 formula**: Failed (counterexample above)
2. **case1_psi + S(a,B)^A + S(a,B)^B^U(A,B)**: Missing cascade case where q covers gap
3. **Adding S(A^S(a,B), q)**: S(a,B) can fail at cascade A-points due to B-gaps
4. **Adding S(A^S(A,B), q)**: Loses connection to `a`
5. **S(A,q) ^ S(a, A|B)**: Backward direction fails — doesn't guarantee U(A,B)(s)
6. **neg_since_equiv decomposition**: Circular — reduces back to Case 5
7. **Substitution-based approach for all_separable**: Requires elimination cases anyway

## The Fundamental Difficulty

The guard `q v U(A,B)` provides coverage that cannot be decomposed into a pointwise boolean combination of separated formulas. Specifically:
- `U(A,B)(r)` at point r guarantees `exists v > r, A(v) ^ B on (r,v)`
- This does NOT imply A(r), B(r), or any other pointwise property at r
- So `q(r) v U(A,B)(r)` cannot be replaced by `q(r) v A(r) v B(r)` or similar

This means any separated guard for the S-formula must capture the U-coverage without using U itself inside S.

## Suggested Next Steps

1. **Consult additional literature**: Check Reynolds (2010), Gabbay (1981), or other sources for a corrected Case 5 formula. The formula may exist in the literature but not in GHR94.

2. **Try a cascade-tracking formula**: The correct formula likely needs to track the cascade via nested S-formulas. Something like:
   ```
   case1_psi(a,q,A,B) 
   v (S(a,B) ^ A) 
   v (S(a,B) ^ B ^ U(A,B))
   v S(A ^ S(a,B), q)        -- cascade ending with q from first A-point
   v S(A ^ S(A^S(a,B), q|A|B), q)  -- two-step cascade
   v ...                       -- potentially infinite nesting?
   ```
   The issue is that the cascade can have arbitrarily many steps, requiring arbitrarily deep nesting.

3. **Alternative proof of all_separable**: Skip the 8-case lemma entirely and prove the separation theorem using a different induction (e.g., on a combined measure involving formula size and the cascade length). This would require novel proof architecture.

4. **Accept axiom for Case 5**: As a last resort, axiomatize the existence of a separated equivalent for Case 5 and prove everything downstream. This is unsatisfying but would unblock the rest of the development.

## Files Affected

- `Eliminations.lean`: 4 sorries (Cases 5-8)
- `DualEliminations.lean`: 8 sorries (depend on all 8 cases)
- `SeparationThm.lean`: 4 sorries (depend on elimination cases)
- `ExpressiveCompleteness.lean`: 1 sorry (depends on separation theorem)
- Total: 17 sorries

## Key Discovery

The GHR94 formula for Case 5 of Lemma 10.2.3 (p.370) appears to contain an error in the integer-time setting. This is a finding about the published mathematical literature, not just a formalization difficulty.
