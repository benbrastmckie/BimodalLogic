# Handoff: Task 107 -- Phase 3 Lemma 2.3 Blocker Analysis

## Session
- **Session ID**: sess_1777387372_ae0206
- **Phases Completed**: 1 (Review), 2 (Cleanup)
- **Phase 3**: IN PROGRESS (P(alpha) in C proved, snce(beta, alpha) in C blocked)
- **Phases Remaining**: 3 (finish), 4-8
- **Build Status**: `lake build` passes (1097 jobs)
- **Sorry Count**: 15 (unchanged from handoff 02)

## What Was Done This Session

### Partial Progress on Burgess Lemma 2.3 (Forward Direction)

Proved **P(alpha) in C** for all alpha in A, given burgessR(A, beta, C):

```
burgessR_implies_burgessRSince: intro alpha h_alpha
  -- Step 1 (COMPLETE): P(alpha) in C
  -- Proof: by contradiction on H(neg alpha) in C
  -- If H(neg alpha) in C: by burgessR, untl(beta, H(neg alpha)) in A
  -- By BX10: F(H(neg alpha)) in A
  -- F(H(neg alpha)) = neg(G(P(alpha))) definitionally
  -- By BX4: G(P(alpha)) in A
  -- Contradiction: G(P(alpha)) and neg(G(P(alpha))) both in A
  -- Therefore H(neg alpha) not in C, so P(alpha) = neg(H(neg alpha)) in C

  -- Step 2 (BLOCKED): From P(alpha) in C, derive snce(beta, alpha) in C
  sorry
```

The same technique was applied to the backward direction (burgessRSince_implies_burgessR):
- **F(gamma) in A** proved for all gamma in C, given burgessRSince(C, beta, A)
- Uses BX4' + BX10' in the mirror argument
- Step 2 (F(gamma) to untl(beta, gamma)) is blocked

### Root Cause Analysis

The gap between P(alpha) and snce(beta, alpha) is:
- P(alpha) at y says: there exists SOME past z < y with alpha(z)
- snce(beta, alpha) at y says: there exists past z < y with alpha(z) AND beta on (z, y)

The guard beta is the missing ingredient. P(alpha) gives a "past witness" but without any guard constraint.

### Approaches Exhaustively Investigated

1. **BX4 + BX3 (event enrichment)**: From G(P(alpha)) in A and BX3 (right_mono_until), can enrich event of Until formulas with P(alpha). Gives untl(beta, gamma AND P(alpha)) in A. But P(alpha) at the witness doesn't give snce(beta, alpha) at the witness.

2. **BX12' (P to Since conversion)**: P(alpha) -> snce(top, alpha). But top is weaker than beta as guard. Left_mono_since goes from STRONGER to WEAKER guard (since phi -> psi makes snce(phi, e) -> snce(psi, e)), so cannot strengthen guard.

3. **BX7' (Since linearity)**: Combining two Since formulas (snce(top, alpha) and snce(top, untl(beta, gamma))) via linearity only produces disjuncts with top guard. Cannot strengthen to beta.

4. **BX5' (Since self-accumulation)**: Enriches guard with Since formulas. Gives snce(top AND snce(top, alpha AND untl(beta, gamma)), event). The enriched guard is a Since formula, not untl(beta, gamma).

5. **Contrapositive approach**: Assume neg(snce(beta, alpha)) in C. Then untl(beta, neg(snce(beta, alpha))) in A. By BX10: F(neg(snce(beta, alpha))) in A. But F(neg(snce(beta, alpha))) = neg(G(neg neg snce(beta, alpha))). And G(P(alpha)) in A. These are DIFFERENT formulas (G(P(alpha)) vs G(snce(beta, alpha))), no contradiction.

6. **BX7 (Until linearity at past points)**: From P(alpha AND untl(beta, gamma)) in C (provable by H-trick), combined with gamma in C and BX4' giving H(F(gamma)) in C. At the past witness z: untl(beta, gamma) and F(gamma) both hold. By BX12 + BX7: disjuncts all have guard beta but witness may differ from current point.

7. **BX6 (Until absorption)**: The anti-accumulation axiom doesn't connect Until and Since.

### Why A3a Was Needed

The original Burgess proof used axiom A3a: `p AND U(q, r) -> U(q AND S(p, r), r)`. This DIRECTLY enriches the Until guard with Since information. Under reflexive semantics, this is valid because at the first intermediate point after x, Since from x to that point is reflexively satisfied.

Under STRICT semantics (open guard), A3a fails:
```
Counterexample: times {0, 1, 2}, p true at 0, q at 0-1, r at 2.
At time 0: p AND U(q,r). But U(q AND S(p,r), r) fails at 0
because S(p,r) at u=0 requires v < 0 with r(v), which doesn't exist.
```

The BX axiom system under open-guard does NOT include A3a. The comment in TemporalDerived.lean saying "BX4 + BX5 subsume A3a's role" is aspirational -- the algebraic content may be present but the specific Lemma 2.3 derivation has not been found.

### Mathematical Assessment

The formula `P(alpha) AND (beta U gamma) AND gamma -> S(beta, alpha)` IS semantically valid for **dense** linear orders (because the Until guard beta holds on (z, w), and if w > y then beta holds on (z, y), and if w <= y we can iterate via density). But:

1. The BX axiom system is designed for BOTH dense and discrete orders
2. There is no density axiom in BX (GGp -> Gp is not included)
3. Under discrete orders, the iteration argument doesn't work (might have w = z+1 < y with no intermediate points)

**Conclusion**: Lemma 2.3 may require a density axiom or a different axiom to be derivable. Under the current BX axiom system with strict semantics, the derivation appears blocked.

## Recommended Actions

### Option A: Add Density Axiom (Preferred)
Add `GGp -> Gp` (or equivalently `P(P(alpha)) -> P(alpha)`) to the BX axiom system. This restricts the frame class to dense linear orders. With density:
- `P(alpha)` at y gives witness z < y
- From untl(beta, gamma) at z: if gamma witness w > y, done (beta on (z,y))
- If w <= y: by density, get intermediate point u in (z, w), with untl(beta, gamma) at u
- Iterate: getting witnesses closer and closer to y
- This infinite iteration can be captured by BX6 (absorption)

**Risk**: Adding density changes the logic's frame class. Need to verify all existing axioms are still valid on dense orders. The plan's non-goal says "Adding density axioms (GGp->Gp is not derivable in BX)" -- this suggests density was intentionally excluded.

### Option B: Change BurgessR3Maximal to Forward-Only
Redefine BurgessR3Maximal to use only burgessRSet (forward direction) in the maximality condition. The Since direction would be derived separately.

**Pros**: Xu 3.2.1(i) becomes provable without Lemma 2.3.
**Cons**: Since direction of g-values would need different infrastructure. Downstream phases may need adjustment.

### Option C: Plan Revision
Run `/revise 107` to create a new plan version that addresses the strict-semantics gap. The plan was written assuming BX4+BX5 subsume A3a, which appears incorrect.

### Option D: Prove Lemma 2.3 with Existing Axioms
The formula `alpha AND untl(beta, neg(snce(beta, alpha))) -> bot` IS semantically valid for all linear orders with strict Until/Since. A derivation from BX1-BX12 might exist but was not found in this session. A specialized research task could investigate this.

## Key Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
  - Lines 1186-1210: `burgessR_implies_burgessRSince` -- Step 1 (P(alpha) in C) proved, Step 2 sorry
  - Lines 1218-1243: `burgessRSince_implies_burgessR` -- Step 1 (F(gamma) in A) proved, Step 2 sorry
  - Lines 1415, 1428: Xu 3.2.1(i) and (ii) unchanged (sorry)

## Design Notes

1. The P(alpha) ∈ C proof is clean and sorry-free. It demonstrates that the BX4+BX10 trick works for "weak" temporal properties but not for "guarded" temporal properties.

2. The F(H(neg alpha)) = neg(G(P(alpha))) identity is DEFINITIONAL in Lean (not just provable). The proof exploits this for a clean absurd/neg_excludes contradiction.

3. The backward direction mirrors perfectly: F(gamma) ∈ A via BX4' + BX10'.

4. All 4 sorry sites in RRelation.lean (Lemma 2.3 forward/backward + Xu 3.2.1 i/ii) share the same root cause: the P-to-Since (or F-to-Until) gap.
