# Implementation Summary: Task 956 Phase 2B (v013)

**Date**: 2026-03-10
**Session**: sess_1773164719_a5b7c9
**Plan**: implementation-013.md (v013)
**Status**: BLOCKED - requires user review

## Phase 2B: Enriched Seed Construction - BLOCKED

### What Was Attempted

All three pure-syntax paths from the v013 plan were evaluated for resolving the
NoMaxOrder/NoMinOrder sorries (lines 573-585 of ConstructiveFragment.lean):

1. **Path A (Enriched Seed)**: Enriched forward seed `{phi, G(psi)} union GContent(M)` where
   `psi not in M`. Under irreflexive semantics, `G(psi)` and `neg(psi)` are compatible, so
   the seed is not trivially inconsistent. However, the consistency proof requires handling the
   case where the finite derivation uses `G(psi)` but not `phi`. This case requires
   `F(G(psi)) in M`, which cannot be derived from the axiom system for contingent `psi`.

2. **Path B (Aut+(T))**: Per research-033, Aut+(T) is uncountable and inherits T's problems.

3. **Path C (Pruned Fragment)**: Cannot guarantee M_0 is non-G-complete, so the fragment
   could be empty.

### Mathematical Analysis: NoMaxOrder is FALSE for Generic M_0

The statement `instance : NoMaxOrder (ConstructiveQuotient M_0 h_mcs_0)` is false when M_0
is a G-complete MCS (one where `phi in M iff G(phi) in M` for all phi).

**Why G-complete MCSs exist**: They are consistent with all axioms (seriality, density,
linearity, temp_4, temp_a). Research-033 Appendix C constructs an explicit model: take Q with
the standard order and a constant valuation where every time point has the same MCS. The
resulting MCS is G-complete.

**Why G-complete MCSs collapse the quotient**:
- `GContent(M) = M` by definition of G-completeness
- Forward witness seed `{phi} union GContent(M) = {phi} union M = M` (phi in M since
  F(phi) in M implies phi in M for G-complete M)
- Lindenbaum extension of M is M itself (M already extends the seed maximally)
- All witnesses in the ConstructiveFragment are M itself
- ConstructiveQuotient is a singleton, violating NoMaxOrder

**Why enriched seeds cannot fix this**:
- The enriched seed `{phi, G(psi)} union GContent(M)` needs consistency proof
- The consistency proof for the case where only `G(psi)` appears in the finite
  derivation requires `F(G(psi)) in M` (its syntactic negation in M)
- No axiom combination can derive `F(G(psi)) in M` for non-theorem psi
- The temp_a trick (`phi -> G(P(phi))`) fails because G-completeness implies
  H-completeness (via GContent/HContent duality), so `P(phi) in M iff phi in M`
  whenever `F(phi) in M`

### Possible Resolutions (for User Decision)

1. **Accept Path D (bulldozing)**: Define `D = ConstructiveQuotient x Q`. The product
   inherits all required properties from Q. This violates the "no Q import" constraint
   but is justified by the Cantor uniqueness argument. Working template exists in Boneyard.

2. **Add hypothesis to NoMaxOrder**: Require M_0 to not be G-complete (i.e., there exists
   psi with `G(psi) in M_0` and `psi not in M_0`). Restructure the completeness proof to
   construct M_0 with this property.

3. **Enriched M_0 construction**: Extend `{neg phi_0, F(G(neg phi_0))}` to MCS, ensuring
   M_0 has `F(G(neg phi_0)) in M_0` which provides the needed `F(G(psi))` for the enriched
   seed. Requires proving this enriched initial seed is consistent.

4. **Abandon ConstructiveQuotient approach**: Use an entirely different construction for the
   temporal domain.

### Files Modified

- `specs/956_.../plans/implementation-013.md` - Phase 2B marked [BLOCKED] with progress notes

### Sorries Status

- Pre-existing: 2 (NoMaxOrder line 573, NoMinOrder line 581 in ConstructiveFragment.lean)
- New: 0
- Resolved: 0
- Net change: 0
