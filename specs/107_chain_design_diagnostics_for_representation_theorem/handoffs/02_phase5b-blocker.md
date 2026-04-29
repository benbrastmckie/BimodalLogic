# Handoff: Phase 5b Blocked -- Xu Splitting Requires Guard Strengthening Axiom

**Task**: 107
**Phase**: 5b (Xu Lemma 2.4 Splitting)
**Status**: BLOCKED
**Session**: sess_1777467484_0f48f6
**Date**: 2026-04-28

## Summary

Phase 5b (Xu Lemma 2.4 Splitting) is blocked because the proof requires
strengthening the Until guard using G-information, which is semantically valid
under open guard but NOT derivable from the current BX axiom system.

## Root Cause Analysis

### The Derivation Gap

Xu's 1988 Lemma 2.3 (prerequisite for Lemma 2.4 splitting) proves: if
BurgessR3Maximal(A, B, C), then `snce(top, alpha) in B` for all `alpha in A`.

Xu's proof uses axiom (1): `G(p -> q) -> (U(r, p) -> U(q, r)) AND (U(r, p) -> U(r, q))`.

The FIRST conjunct `G(p -> q) -> U(r, p) -> U(q, r)` is a guard/event SWAP
operation. Under open guard semantics (t,s), this swap is INVALID:

- `U(r, p)` at t: exists s > t, r(s), p at all (t,s)
- `U(q, r)` at t: exists s' > t, q(s'), r at all (t,s')
- The swap fails because knowing r(s) (event at endpoint) does NOT give
  r at all interior points (t,s')

Our BX axiom system correctly omits this first conjunct. Our BX2
(`left_mono_until`) only provides guard WEAKENING:
`(phi -> chi) AND G(phi -> chi) -> untl(phi, psi) -> untl(chi, psi)`

### What We Need But Cannot Derive

The core derivation Xu 2.3 needs is:

`alpha AND untl(beta, gamma) -> untl(beta AND snce(top, alpha), gamma)`

This STRENGTHENS the guard from `beta` to `beta AND snce(top, alpha)`. The proof
requires:

1. From `alpha in A`, derive `G(snce(top, alpha)) in A` (via BX4 + BX12')
2. From `G(snce(top, alpha))`, derive `G(beta -> beta AND snce(top, alpha))`
3. Apply BX2 to strengthen guard

Step 3 fails because BX2 requires BOTH:
- `G(beta -> beta AND snce(top, alpha))` -- we have this
- `(beta -> beta AND snce(top, alpha))` at current point -- requires
  `snce(top, alpha)` at current point, which we do NOT have

Under open guard, the pointwise condition in BX2 is STRONGER than semantically
needed. The semantically valid rule:

`G(phi -> chi) -> untl(phi, psi) -> untl(chi, psi)`

(without the pointwise `(phi -> chi)`) would suffice, but is NOT derivable from
current BX axioms.

### Confirmed Semantically Valid

I verified that `G(phi -> chi) -> untl(phi, psi) -> untl(chi, psi)` IS valid
under open guard (t,s):

- `untl(phi, psi)` at t: exists s > t, psi(s), phi at all r in (t,s)
- `G(phi -> chi)` at t: (phi -> chi) at all u > t, including all r in (t,s)
- At each r in (t,s): phi(r) and (phi -> chi)(r), so chi(r)
- Therefore: chi at all r in (t,s), psi(s), giving untl(chi, psi)(t)

The point is that the guard interval (t,s) is a SUBSET of the G-interval
(t, infinity), so G-information always covers the guard interior.

### Why All Alternative Proof Routes Also Fail

I explored many alternatives:

1. **enrichment_until (BX13)**: Adds information to the EVENT, not the GUARD.
   Gives `untl(beta, gamma AND snce(beta, alpha))` but we need
   `untl(beta AND snce(top, alpha), gamma)`.

2. **untl_conj_guard (BX7-based)**: Conjoins guards of TWO untls with SAME event.
   Needs `untl(snce(top, alpha), gamma)` as input -- circular.

3. **Self-accumulation (BX5)**: Enriches guard with the full until formula, not
   with snce(top, alpha).

4. **g_content approach**: BurgessR3Maximal(A, B, C) does NOT imply
   g_content(A) subset B (would require T axiom or reflexivity).

5. **Direct BX2 with G**: Cannot derive `snce(top, alpha)` at the current
   point of A (alpha at current point does not give P(alpha) without past
   seriality).

## Impact on Plan

All sorry sites in the plan depend on xu_splitting either directly or
indirectly:

- **Density (1 sorry)**: Directly uses xu_splitting
- **C4/g_prop/h_prop (4 sorries)**: Phase 9 uses xu_splitting
- **C5 (2 sorries)**: Phase 10 uses Lemma 2.7 splitting (same gap)
- **FUC/FSC (2 sorries)**: Phase 11 depends on all prior phases

## Recommended Resolution

### Option A: Add `left_mono_until_G` as a new BX axiom (PREFERRED)

Add the semantically valid axiom:

```
| left_mono_until_G (phi psi chi : Formula) :
    Axiom ((phi.imp chi).all_future.imp
      ((Formula.untl phi psi).imp (Formula.untl chi psi)))
```

This is `G(phi -> chi) -> untl(phi, psi) -> untl(chi, psi)` -- BX2 without
the pointwise `(phi -> chi)` conjunct.

**Justification**: Valid under open guard (t,s) since the guard interval is
always a subset of the G-interval. This is a WEAKENING of BX2 (fewer
hypotheses, same conclusion structure). It does not change the logic's theorems
over closed guard, since under closed guard BX2 already derives it (from the T
axiom G(X) -> X giving the pointwise condition).

**Effort**: ~2 hours for axiom + soundness proof + update Axioms.lean and
Soundness.lean.

### Option B: Add `left_mono_until_G` as a derived rule

Try to derive it from existing axioms. My analysis suggests this is NOT
possible, but a formal impossibility proof would be needed.

### Option C: Fall back to Path 1 (add A4a axiom)

Report 44 confirms A4a (`U(p,q) AND NOT U(p,r) -> U(q AND NOT r, q)`) is
semantically valid under open guard. Adding it would enable Burgess's original
Lemma 2.6 approach. But this adds a complex axiom instead of a simple one.

### Option D: Structural redesign of density/g-construction

Avoid splitting entirely by restructuring how the density and C4/C5 cases
construct g-values. This would be a major plan revision.

## Current State

- All source files unchanged (reverted the incomplete proof attempt)
- `lake build` passes
- Plan file Phase 5b marked [BLOCKED]
- 7 sorry sites in CounterexampleElimination.lean, 2 in ChronicleToCountermodel.lean (unchanged)

## Files Examined

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean`
- `literature/Xu_1988_On_some_US_tense_logics.md`
