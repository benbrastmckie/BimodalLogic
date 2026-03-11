# Phase 6 Blocker: DenselyOrdered on BidirectionalQuotient from DN

**Task**: 956
**Phase**: 6
**Date**: 2026-03-09
**Session**: sess_1773073235_90cfc3
**Status**: BLOCKED - requires user review

## Problem Statement

Proving `DenselyOrdered (BidirectionalQuotient M0 h_mcs0)` when the density axiom DN
(`F(psi) -> F(F(psi))`) is available in the logic.

Given `[a] < [b]` in the quotient (representatives a, b with `CanonicalR a.world b.world`
and `not CanonicalR b.world a.world`), need to find `[c]` with `[a] < [c] < [b]`.

## What Was Proven

1. `strict_lt_has_distinguishing_formula`: extracts psi with G(psi) in b, psi in b, psi not in a, F(psi) in a
2. `density_gives_FF`: DN gives F(F(psi)) in a from F(psi) in a
3. `fragment_intermediate_from_FF`: gets fragment element c with a <= c and F(psi) in c
4. `constrained_forward_above`: Seed {G(psi)} union GContent(a) union HContent(b) (subset of b.world) gives c with **a < c <= b** (strict below, not necessarily strict above)
5. `constrained_forward_below`: Seed {neg psi} union GContent(a) union HContent(b) (subset of a.world) gives c with **a <= c < b** (strict above, not necessarily strict below)

## The Gap

Each constrained seed achieves ONE direction of strictness but not both simultaneously:

- Seed with `G(psi)`: Forces `psi in GContent(c)`, and `psi not in a.world` gives `not(c <= a)`. But `b <= c` is not prevented.
- Seed with `neg psi`: Forces `neg psi in c`, and `G(psi) in b` with `b <= c` would give `psi in c`, contradiction. So `not(b <= c)`. But `c <= a` is not prevented.

Combining both `G(psi)` and `neg psi` in one seed is IMPOSSIBLE because `G(psi) -> psi` (T-axiom) and `neg psi` are contradictory.

Using two different formulas psi1, psi2 from GContent(b) \ a requires proving the combined seed `{G(psi1), neg psi2} union GContent(a) union HContent(b)` is consistent, which is non-trivial (elements come from both a.world and b.world).

## Root Cause Analysis

The Antisymmetrization quotient identifies MCSes with mutual CanonicalR (same GContent). Two MCSes can differ on propositional content while having identical GContent. The only mechanism to add new elements to GContent is via `temp_a` (phi -> G(P(phi))), which places `P(phi)` into GContent. Whether `P(psi) not in a.world` (needed for the a < c direction) depends on the specific MCS structure and cannot be proven from the available hypotheses alone.

## The Research Gap

Research-012 Section 3.3 claimed "u is strictly between s and t: CanonicalR(s, u) and CanonicalR(u, t)" without justification for CanonicalR(u, t) or for strictness. The research handwaved the critical step. The proof is harder than the sketch suggested.

## Potential Approaches

1. **Two-formula approach**: Find two distinct formulas in GContent(b) \ a.world and prove the combined seed consistent. Requires a careful compactness-style argument.

2. **Counting/adjacency contradiction**: Show that "adjacent" quotient classes (no class between them) are impossible when DN holds. Possibly via semantic argument (DN is sound for dense frames, so if quotient is not dense, completeness fails, but this requires the completeness theorem first -- circular).

3. **Different quotient construction**: Instead of Antisymmetrization of the BidirectionalFragment, use a different construction that is inherently dense. For example, work in an irreflexive temporal logic setting where the canonical relation is already antisymmetric.

4. **Frame density (weaker)**: Prove density of the CanonicalR relation on MCSes (without the quotient), which is easier but may not directly give DenselyOrdered on the quotient.

5. **Direct Q-embedding**: Instead of proving DenselyOrdered and then applying Cantor's theorem, directly construct an order-embedding of the quotient into Q. This bypasses the density proof entirely.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` - Added constrained_forward_above and constrained_forward_below lemmas (sorry-free)
- `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-002.md` - Phase 6 marked [BLOCKED]

## Recommendation

This is a genuine mathematical obstacle, not a formalization issue. The user should:
1. Review the mathematical argument for density of the quotient from DN
2. Decide whether to pursue one of the approaches above or pivot the architecture
3. Consider whether approach 5 (direct Q-embedding) bypasses the issue entirely
