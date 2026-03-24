# Research Report: Task #48 - closureWithNeg Negation Closure Blocker

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)
**Session**: sess_1774320915_0d81a8

## Summary

Both teammates independently confirmed that the claim in research report #22 — that `closureWithNeg` is closed under negation — is **FALSE**. This invalidates plan v12's core strategy. The boundary case (`FF(psi) in closureWithNeg \ subformulaClosure`) IS reachable. Five genuinely untried approaches were identified; the recommended path combines case splitting with theorem weakening.

## Key Findings

### 1. closureWithNeg Has Only ONE-LAYER Negation (Confirmed by Both)

**Definition**: `closureWithNeg(phi) = subformulaClosure(phi) ∪ {g.neg | g ∈ subformulaClosure(phi)}`

This gives a one-layer property: for `g ∈ subformulaClosure`, `g.neg` is included. But `neg(g.neg) = g.neg.neg` is NOT included unless `g.neg` itself is a subformula. There is no double-negation closure.

**Counter-example**: `phi = p.box` → `neg(p.neg) ∉ closureWithNeg(phi)` (Teammate A, verified in source)

### 2. The Boundary Case IS Reachable (Teammate A)

When `phi = GG(neg(F(p)))`:
- `GG(neg(F(p))) ∈ subformulaClosure(phi)` (it IS phi)
- `FF(p) = GG(neg(F(p))).neg ∈ closureWithNeg` (in Set B)
- But `FF(p) ∉ subformulaClosure(phi)` (no F-formulas are subformulas)
- Therefore `neg(FF(p)) ∉ deferralClosure` and negation completeness CANNOT apply

### 3. Historical Pattern: 12 Plans Failed at the Same Core Issue (Teammate B)

All approaches that attempt to propagate "F(psi) not in successor" through the restricted chain fail at the same point: DRM negation completeness requires BOTH `psi` and `neg(psi)` in deferralClosure, which isn't guaranteed for iterated F-formulas at the boundary.

### 4. Lindenbaum Succ Lifting is Definitively Fatal (Confirmed by Both)

Plan v11's approach cannot work because two independent `Classical.choose` applications for `extendToMCS` produce disconnected extensions — g_content transfer is impossible.

## Untried Approaches (from Teammate B)

| Approach | Description | Effort | Risk |
|----------|-------------|--------|------|
| A. Filtration | Build finite model from Fischer-Ladner closure | 8-12h | Major refactor |
| **B. Weaken theorem** | Add `h_all_in_dc` hypothesis to callers | 2-3h | **Low** |
| C. Forward simulation | Construct explicit witness path | 4-6h | Complex WF recursion |
| **D. Two-phase proof** | Split FF-in-dc vs FF-not-in-dc | 3-4h | **Medium** |
| E. Semantic transfer | Use model existence for consistency | 6-8h | New infrastructure |

## Synthesis

### Conflicts Resolved

1. **Approach D viability**: Teammate A recommended case split (similar to D). Teammate B initially recommended D but then discovered that Case (a) — `FF(psi) ∉ dc` but `F(psi) ∈ subformulaClosure` — still faces the deferral problem: excluding `F(psi)` from `chain(k+1)` requires negation completeness at the `FF(psi)` level, which is exactly what we can't get. **Resolution**: Approach D alone is insufficient for Case (a). Need to combine with Approach B's hypothesis strengthening.

2. **Case split vs hypothesis strengthening**: Teammate A focuses on structural analysis of GG-formulas for Case B of the case split. Teammate B focuses on modifying the theorem signature. **Resolution**: These are complementary — a combined approach is strongest.

### Gaps Identified

1. **Caller analysis incomplete**: Neither teammate fully traced what `restricted_forward_chain_F_coherence` actually passes to `restricted_bounded_witness`. Verifying that callers can provide `h_all_in_dc` is critical.

2. **GG-content path unverified**: Teammate A's Option 3 (use GG-content when `FF(psi) = GG(...).neg`) needs verification against the actual Succ definition and g_persistence lemmas.

3. **Working unrestricted proof not analyzed**: The working `bounded_witness` in `CanonicalTaskRelation.lean:651-680` was referenced but not studied in detail. Understanding WHY it works there may reveal the key difference.

### Recommendations

**Primary: Combined Approach B+D (Weaken + Case Split)**

1. **Examine the caller** `restricted_forward_chain_F_coherence` to determine what hypotheses it can provide
2. **Add hypothesis** `h_all_in_dc : ∀ i ≤ d, iter_F i psi ∈ deferralClosure phi` to `restricted_bounded_witness`
3. **With this hypothesis**: When `FF(psi) ∈ deferralClosure` (guaranteed by `h_all_in_dc` for appropriate indices), negation completeness applies and the existing plan v12 proof chain works
4. **Verify callers**: The caller uses `restricted_forward_chain_F_bounded` which explicitly provides a bound `d` where `iter_F d psi` leaves deferralClosure. For all `i < d`, `iter_F i psi` should be in deferralClosure by definition of `d`.

**Fallback: Approach A (Filtration)**

If B+D fails, a complete filtration-based approach would bypass the issue entirely but requires major infrastructure.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical analysis of closureWithNeg | completed | HIGH (math), MEDIUM (impl) |
| B | Historical analysis + alternatives | completed | MEDIUM-HIGH |

## References

- Teammate A report: `specs/048_prove_succ_chain_fam_bounded_f_depth/reports/25_teammate-a-findings.md`
- Teammate B report: `specs/048_prove_succ_chain_fam_bounded_f_depth/reports/25_teammate-b-findings.md`
- `SubformulaClosure.lean:94-95` - closureWithNeg definition
- `SubformulaClosure.lean:109-113` - neg_mem_closureWithNeg (one-layer only)
- `SuccChainFMCS.lean:2340-2440, 2990-3030` - actual sorries
- `CanonicalTaskRelation.lean:651-680` - working bounded_witness (unrestricted)
- All 24 prior reports in `specs/048_prove_succ_chain_fam_bounded_f_depth/reports/`
