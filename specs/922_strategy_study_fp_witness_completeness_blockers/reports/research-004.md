# Research Report: Task #922

**Task**: Strategy study: identify viable path for forward_F/backward_P completeness
**Date**: 2026-02-24
**Mode**: Team Research (2 teammates)
**Session**: sess_1771970510_ead61b

## Summary

This team research investigated the CanonicalR antisymmetry blocker in Phase 3 of the Canonical Quotient completeness proof. **Conclusion: Use Mathlib's `Antisymmetrization` quotient** to obtain a LinearOrder without proving antisymmetry directly. Both teammates independently converged on this recommendation.

Key discoveries:
1. **Antisymmetry is unprovable** from temp_linearity alone (confidence: HIGH)
2. **Mutually CanonicalR-related MCSes agree on ALL F and G formulas** (not just G)
3. **`Antisymmetrization` quotient** gives LinearOrder automatically via Mathlib
4. **Strict-future-witness problem** is the TRUE remaining blocker (orthogonal to antisymmetry)

## Key Findings

### Primary Approach: Quotient via Antisymmetrization (RECOMMENDED)

**From Teammate A (Antisymmetry Analysis):**

The linearity axiom ensures *totality* (comparability) but does NOT prevent two distinct MCSes from being mutually CanonicalR-related. The case analysis from temp_linearity produces witnesses but does not close to a contradiction.

**Critical insight**: While GContent equality follows from mutual CanonicalR, **F-formulas are ALSO shared**. Since:
- F(φ) = neg(G(neg(φ)))
- G(neg(φ)) is in GContent iff G(neg(φ)) is in the MCS
- GContent equality means G(neg(φ)) is shared
- Therefore F(φ) (the negation) is also shared by MCS negation completeness

**Mutually CanonicalR-related MCSes can only differ on:**
- Propositional atoms (not prefixed by G or F)
- Box/Diamond formulas (modal content)
- H/P formulas (past-temporal content)
- Complex nested combinations

For BFMCS temporal coherence, only forward_G/forward_F/backward_H/backward_P matter, and these are determined by G/F/H/P formulas which ARE shared within equivalence classes.

**From Teammate B (Alternative Approaches):**

| Alternative | Assessment | Effort | Risk |
|-------------|------------|--------|------|
| Quotient via Antisymmetrization | RECOMMENDED | 17-28 hours | Medium-High |
| Direct chain construction | NOT RECOMMENDED | 8-12 hours | Very High (recreates DovetailingChain failure) |
| OrderEmbedding without OrderIso | NOT RECOMMENDED | 10-15 hours | High (same blocker) |
| Modify BFMCS type constraints | NOT RECOMMENDED | 10-15 hours | High (cascade risk) |

### Mathlib Pipeline (Verified)

```
CanonicalReachable
    │
    ├── Define Preorder (via CanonicalR)
    │   ├── le_refl: canonicalR_reflexive
    │   └── le_trans: canonicalR_transitive
    │
    ├── Prove IsTotal (from canonical_reachable_comparable)
    │
    ├── Add DecidableLE/DecidableLT (classical)
    │
    └── Antisymmetrization (CanonicalReachable M₀ h_mcs₀) (· ≤ ·)
            │
            ├── PartialOrder (automatic from Mathlib)
            │
            └── LinearOrder (automatic from IsTotal + Decidable)
                    │
                    └── orderIsoIntOfLinearSuccPredArch
                            │
                            ├── Requires: SuccOrder, PredOrder
                            ├── Requires: IsSuccArchimedean
                            ├── Requires: NoMaxOrder, NoMinOrder
                            └── Requires: Nonempty
```

### The Strict-Future-Witness Problem (TRUE Remaining Blocker)

Both teammates identified this as orthogonal to the antisymmetry question:

**Problem**: When `F(φ) ∈ M` and `φ ∈ M`, the `canonical_forward_F` witness `W` equals `M` itself. We need `φ` at a STRICTLY later position.

**Case analysis:**
- If `G(φ) ∈ M`: φ propagates via forward_G to all future positions. **RESOLVED.**
- If `G(φ) ∉ M`: φ is "fleeting" - holds at M but may not hold at strictly later positions. **UNRESOLVED.**

**Possible resolutions to investigate:**
1. Prove every reachable MCS is NOT temporally saturated
2. Prove temporally saturated MCSes form a single equivalence class (quotient's max)
3. Use a different witness strategy (e.g., Lindenbaum({φ, F(φ)} ∪ GContent(M)))
4. Weaken BFMCS forward_F requirement (high-risk refactor)

## Synthesis

### Conflicts Found: 0

Both teammates independently converged on the same recommendation. No conflicts to resolve.

### Gaps Identified: 1

- The strict-future-witness problem requires additional research (not resolved by the quotient approach)

### Recommendations

**Immediate Action (Phase 3 revision):**
1. Define `Preorder` on `CanonicalReachable` via CanonicalR
2. Prove `IsTotal` from `canonical_reachable_comparable`
3. Form `Antisymmetrization` quotient
4. Obtain `LinearOrder` (automatic from Mathlib)

**Next Steps:**
5. Prove `Countable` on quotient (Formula is Countable)
6. Prove `NoMaxOrder` and `NoMinOrder` (medium-hard)
7. Define `SuccOrder`/`PredOrder` and prove `IsSuccArchimedean`
8. Apply `orderIsoIntOfLinearSuccPredArch`
9. Address strict-future-witness problem for forward_F

**Estimated Effort:**
| Phase | Hours | Risk |
|-------|-------|------|
| Phase A: LinearOrder | 3-5 | Low |
| Phase B: SuccOrder/NoMax/Archimedean | 5-10 | Medium |
| Phase C: OrderIso + BFMCS | 4-8 | High |
| Strict-future-witness resolution | 4-10 | Unknown |
| **Total** | 16-33 | Medium-High |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Antisymmetry proof analysis | completed | High (quotient), Low (direct proof) |
| B | Alternative approaches | completed | High (quotient), Low (bypass) |

## Evidence

### Verified Mathlib Declarations

| Name | Exists | Location |
|------|--------|----------|
| `Antisymmetrization` | YES | Mathlib.Order.Antisymmetrization |
| `AntisymmRel.setoid` | YES | Mathlib.Order.Antisymmetrization |
| `instPartialOrderAntisymmetrization` | YES | Mathlib.Order.Antisymmetrization |
| `instLinearOrderAntisymmetrizationLe...` | YES | Mathlib.Order.Antisymmetrization |
| `toAntisymmetrization` | YES | Mathlib.Order.Antisymmetrization |
| `ofAntisymmetrization` | YES | Mathlib.Order.Antisymmetrization |
| `orderIsoIntOfLinearSuccPredArch` | YES | Mathlib.Order.SuccPred.LinearLocallyFinite |

### Verified Project Lemmas

| Name | Exists | Location |
|------|--------|----------|
| `canonicalR_reflexive` | YES | CanonicalFrame.lean |
| `canonicalR_transitive` | YES | CanonicalFrame.lean |
| `canonical_reachable_comparable` | YES | CanonicalReachable.lean |
| `gcontent_eq_of_mutual_R` | YES | CanonicalReachable.lean |
| `canonical_forward_F_strict` | YES | CanonicalReachable.lean |
| `canonical_reachable_linear` | YES | CanonicalEmbedding.lean |

## Confidence Level

| Aspect | Confidence |
|--------|------------|
| Quotient resolves antisymmetry blocker | HIGH (90%) |
| Antisymmetry unprovable directly | HIGH (85-90%) |
| Full path to orderIsoIntOfLinearSuccPredArch | MEDIUM (70%) |
| Strict-future-witness resolution | LOW-MEDIUM (40%) |

## References

- Teammate A report: `research-004-teammate-a-findings.md`
- Teammate B report: `research-004-teammate-b-findings.md`
- Mathlib source: `Mathlib/Order/Antisymmetrization.lean`
- Mathlib source: `Mathlib/Order/SuccPred/LinearLocallyFinite.lean`
- Task 922 handoff: `handoffs/phase-3-handoff-20260224T215519.md`
- Goldblatt 1992, *Logics of Time and Computation*
