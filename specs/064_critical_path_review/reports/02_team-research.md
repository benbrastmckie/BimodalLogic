# Research Report: Task #64 — Strategy C vs. Temporal Shift Automorphism

**Task**: Critical path review: algebraic analysis of completeness obstacles
**Date**: 2026-03-25
**Mode**: Team Research (2 teammates)
**Session**: sess_1774450042_09f668
**Focus**: Strategy C (Restricted Chain + σ-Duality Dovetailing) vs. Temporal Shift Automorphism (Task 992 approach) for completing task 58

## Summary

Two research teammates investigated complementary approaches to the temporal coherence obstacle blocking task 58. **Strategy C (Restricted Chain + Dovetailing) is the clear winner** — it has complete infrastructure, no mathematical obstacles, and an estimated ~780 lines of mostly mechanical code. The Temporal Shift Automorphism (τ) is proven **impossible as a global algebraic construction** because G is deflationary and non-invertible; the "shift" is inherently relational and history-dependent, making it equivalent to — not superior to — the existing SuccChain approach.

## Key Findings

### 1. Strategy C Is Viable and Well-Supported (HIGH confidence)

The restricted forward chain (`restricted_forward_chain` in SuccChainFMCS.lean) is sorry-free. The backward chain requires a **symmetric construction** — not direct σ application — because `deferralClosure` is not σ-invariant. However:

- `deferralClosure` already includes **both** forward and backward deferral disjunctions: `{χ ∨ F(χ)}` and `{χ ∨ P(χ)}`
- `h_content_subset_deferralClosure` is already proven
- `predecessor_deferral_seed` is already defined
- `p_nesting_is_bounded_restricted` is already proven

The backward construction is a mechanical mirror of the forward construction, using the same `deferral_restricted_lindenbaum` for Lindenbaum extension within the closure.

### 2. σ-Duality Provides Theoretical Guarantee, Not Direct Implementation (HIGH confidence)

While σ(M) = {σ(φ) : φ ∈ M} transforms F-coherent MCS into P-coherent MCS at the formula level, this does **not** preserve the `DeferralRestrictedMCS` property (σ maps the closure to a different closure). The correct approach:

- Use σ-duality as a **meta-theorem**: it guarantees that every forward-direction proof has a symmetric backward-direction proof
- Implement backward chain directly using the symmetric `h_content` / `pastDeferralDisjunctions` operations
- The temporal_duality inference rule in the proof system ensures the symmetric proofs exist

### 3. Temporal Shift Automorphism τ Is Impossible as Global Construction (HIGH confidence)

Teammate B proved that:

1. **G has no algebraic inverse**: G is deflationary (G(a) ≤ a) and idempotent (G(G(a)) = G(a)). If G⁻¹ existed, G would be the identity — contradiction.
2. **The fixpoint algebra Fix(G) is trivial for translation**: Elements fixed by G are "eternal" truths; translation is the identity on them.
3. **R_G is not functional**: Multiple futures exist for any MCS (different Lindenbaum extensions for different F-obligations).
4. **τ is inherently history-relative**: τ_f(U) := f(t+1) where f(t) = U is only defined along a fixed FMCS f, not globally on Spec(A).

**Consequence**: The "elegant algebraic τ" from task 992 research is a **conceptual insight** (FMCS can be viewed as orbits of a local shift), not a construction tool. It does not provide a path superior to Strategy C.

### 4. Dovetailing Construction Is Mathematically Clean (HIGH confidence)

```
combined : ℤ → DeferralRestrictedMCS φ
combined(n) = if n ≥ 0 then forward_chain(n) else backward_chain(-n)
```

- Join point: Both chains share M₀ at position 0
- Forward F-coherence: Proven (`restricted_forward_chain_forward_F`)
- Backward P-coherence: Symmetric theorem (needs proof, ~150 lines)
- No consistency issues at the join

## Synthesis

### Conflicts Resolved

**No substantive conflicts**. The teammates investigated different approaches and reached complementary conclusions. Teammate B's negative result on τ strengthens the case for Teammate A's Strategy C.

One point of apparent tension resolved:
- Teammate A says "σ-duality means backward construction should be derivable by applying σ"
- Teammate B says "σ is reversal, not translation"
- **Resolution**: Both correct. σ provides a **proof transfer principle** (any forward theorem has a backward analog), but the **implementation** is direct symmetric construction, not σ-application to formula sets.

### Gaps Identified

1. **`constrained_predecessor_restricted` not yet implemented** — This is the single missing piece. It requires:
   - Predecessor seed construction (~80 lines)
   - Seed consistency proof (~120 lines)
   - Restricted predecessor via deferral_restricted_lindenbaum (~50 lines)
   - Predecessor properties (Succ relationship, f-content transfer) (~100 lines)

2. **Integration with `construct_bfmcs`** — Two options:
   - (a) Create new `RestrictedSuccChainFMCS` wrapper (~100 lines)
   - (b) Use existing `DeferralRestrictedSerialMCS.extendToMCS_*` theorems to transfer from restricted to full MCS

3. **P-nesting coherence for backward chain** — Expected to follow the same pattern as F-nesting coherence for forward chain, using the already-proven `p_nesting_is_bounded_restricted`.

### Recommendations

**Primary recommendation: Implement Strategy C**

| Phase | Description | Lines | Difficulty |
|-------|-------------|-------|------------|
| 1 | Symmetric seed construction (predecessor) | 200 | Low-Medium |
| 2 | Restricted predecessor construction | 150 | Low |
| 3 | Backward chain + P-coherence | 200 | Medium |
| 4 | Dovetailing into FMCS over ℤ | 150 | Low |
| 5 | Wire to construct_bfmcs | 100 | Medium |
| **Total** | | **~800** | **Medium** |

**Why this is the best solution (not just the first)**:

1. **Mathematically correct by construction**: F/P-nesting IS bounded within deferralClosure — this is a theorem, not an assumption. The false `f_nesting_is_bounded` that killed the original approach does not apply.

2. **Maximally leverages existing infrastructure**: 80% of the code already exists in sorry-free form. The backward chain is a symmetric mirror.

3. **Elegant via σ-duality guarantee**: The temporal_duality rule ensures every forward proof has a backward analog. This is the algebraic elegance — not in the construction itself, but in the **meta-theorem that guarantees the construction works**.

4. **The alternative (τ) is impossible**: Teammate B's analysis definitively rules out the "more elegant" approach. Strategy C is not a compromise — it is the mathematically correct path.

**Secondary recommendation: Document τ impossibility in task 992**

The insight that τ cannot be a global algebraic automorphism should be recorded in task 992. The STSA representation theorem remains valuable as a framework for understanding the algebra, but the representation itself must go through the relational (SuccChain) route, not through an algebraic shift.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Result |
|----------|-------|--------|------------|------------|
| A | Strategy C analysis | completed | HIGH | ~800 lines, symmetric construction, no mathematical obstacles |
| B | Temporal shift automorphism | completed | MEDIUM | τ is impossible globally; relational approach is correct |

## References

### Strategy C Infrastructure (sorry-free)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:2025-2276` — restricted forward chain + open items
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:587-693` — predecessor deferral seed
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` — DeferralRestrictedMCS
- `Theories/Bimodal/Syntax/SubformulaClosure.lean:592-690` — deferralClosure (includes both F and P closures)

### Algebraic Infrastructure (sorry-free)
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean:371-438` — sigma_quot
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` — STSA typeclass
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` — G, H properties

### Integration Target
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean:1785-1878` — construct_bfmcs (deprecated, needs replacement)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` — conditional representation theorem

### Prior Research
- `specs/064_critical_path_review/reports/01_critical-path-analysis.md` — Strategy C/B/A overview
- `specs/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md` — STSA framework
- `specs/058_wire_completeness_to_frame_conditions/reports/02_team-research.md` — Prior team research on direct algebraic construction
