# Handoff: Phase 4 Complete, Phases 5-8 Blocked by c2' Infrastructure Gap

**Task**: 107 - Burgess chronicle construction
**Session**: sess_1777426622_f6339d
**Agent**: lean-implementation-agent
**Date**: 2026-04-28

## Completed Work

### Phase 4: C4 Nested Case Fix via BX6 [COMPLETED]

Both sorry sites (old lines 425, 543) closed using the BX6 absorption argument:

1. **Until direction (line 425)**: Proved `ce.gamma not in chi.g w w_next` by contradiction:
   - Derived `gamma in f(w_next)` from `no_witness` (no domain point between x and y has gamma.neg)
   - Formed `gamma AND untl(gamma, delta) in f(w_next)` by MCS conjunction
   - Used burgessR3 to get `untl(gamma, gamma AND untl(gamma, delta)) in f(w)`
   - Applied BX6 (`Axiom.absorb_until`) to get `untl(gamma, delta) in f(w)`
   - Contradiction with `neg(untl(gamma, delta)) in f(w)`

2. **Since direction (line 543)**: Mirror proof using `Axiom.absorb_since`.

Sorry count in CounterexampleElimination.lean: 9 -> 7. Build passes.

## Blocking Analysis for Phases 5-8

### Root Cause: g-Value Construction Gap

**ALL 7 remaining sorry sites in CounterexampleElimination.lean** share the same root cause:

The `singleton_chronicle` initializes `g := fun _ _ => empty_set`. All elimination functions preserve g unchanged (`g' = chi.g`). Therefore, for any pair (a, b) that was NOT adjacent in a previous stage, `chi.g a b = empty_set`. But `BurgessR3Maximal(A, empty_set, C)` is FALSE because `empty_set` is not DCS (not SetDeductivelyClosed, since it lacks theorems and isn't closed under derivation).

This means c2' is STRUCTURALLY unprovable for the current chronicle construction. The fix requires modifying the elimination functions to construct proper g-values for new adjacent pairs.

### Why g-Value Construction Is Hard

To construct `BurgessR3Maximal(A, B, C)` via `burgessR3Maximal_extension_exists`, we need a starting DCS S with `burgessR3(A, S, C)`. For `burgessR3(A, S, C)`:

- `burgessRSet(A, S, C)`: for all beta in S, for all gamma in C, `untl(beta, gamma) in A`
- `burgessRSetSince(C, S, A)`: for all beta in S, for all alpha in A, `snce(beta, alpha) in C`

Finding a non-trivial S satisfying these conditions requires Until/Since formulas connecting A and C. Specifically, we need a **seed** eta with:
- `burgessR(A, eta, C)`: for all gamma in C, `untl(eta, gamma) in A`
- `burgessRSince(C, eta, A)`: for all alpha in A, `snce(eta, alpha) in C`

**Key mathematical gap**: There is no existing lemma connecting `g_content(A) subset C` (which Lemma 2.4 provides) to `burgessR(A, eta, C)`. The `g_content` inclusion says "if G(phi) in A then phi in C", but `burgessR` requires "for all gamma in C, untl(eta, gamma) in A", which is a much stronger condition.

Under strict/open guard semantics, `G(eta) -> eta U gamma` is NOT derivable without `F(gamma)` (since `eta U gamma` requires a witness in the future). The theorem `G_implies_topUntil` (G(a) -> top U a) is itself a sorry in TemporalDerived.lean.

### Impact on Each Phase

| Phase | Sorry Sites | Blocked By | Required Infrastructure |
|-------|-------------|------------|------------------------|
| 5 | Lines 830, 868 | g-value for new endpoint pair | Seed lemma: `g_content(f(x)) subset C -> burgessR(f(x), eta, C)` |
| 6 | Line 1130 | Self-pair BurgessR3Maximal | Restructure density case to use intermediate MCS D |
| 7 | Lines 908, 946, 982, 1014 | g-value for split pairs | Seed from existing g(x,y) for new sub-pairs |
| 8 | Lines 615, 619 | Blocked by Phase 5-7 | Guard propagation requires proper g + C3 |

### Possible Resolution Paths

1. **Seed lemma approach** (plan's recommendation): Prove `G(eta) in A AND g_content(A) subset C -> burgessR(A, eta, C)`. This requires a new derivation: from G(eta), derive untl(eta, gamma) for all gamma in C. May need new BX theorem: `G(phi) AND F(psi) -> phi U psi` (derivable from BX7 linearity + BX10 until_F + temporal induction?).

2. **Architectural change**: Modify elimination functions to NOT preserve g unchanged. Instead, construct g lazily using `burgessR3Maximal_extension_exists`. This requires proving that for the specific MCS pairs created by each elimination, burgessR3 seeds exist. Essentially the same mathematical challenge but with different code structure.

3. **Strengthen BurgessR3Maximal definition** (Teammate C's suggestion from report 41): Add Xu 2.0(iii) witness property to the definition. This would provide more seed material directly but requires verifying that Zorn extension still produces the strengthened property.

4. **Remove c2' from finite-stage invariant**: c2' is carried in `omega_chain` but `omega_chain_c2'` is NEVER USED downstream. At the limit, c2' is vacuously true. If we can prove C2 at the limit WITHOUT finite-stage c2', all sorry sites become moot. This requires proving C2 directly using limit density + C3 + absorption (Lemma 2.5). **This might be the simplest path but requires careful verification that no other code depends on finite-stage c2'.**

### Recommendation

Run `/revise 107` to update the plan. The current plan assumes the seed-finding is straightforward ("direct g-construction"), but the analysis shows it requires new mathematical infrastructure (BX theorems connecting G to Until). Resolution path 4 (removing c2' from the finite-stage invariant) deserves investigation first, as it would eliminate all 7 sorry sites by removing the obligation entirely.
