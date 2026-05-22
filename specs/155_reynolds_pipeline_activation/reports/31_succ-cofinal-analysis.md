# succ_cofinal: Root Blocker Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: The actual root sorry blocking sorry-free bx_completeness

---

## 1. The Sorry Chain (Corrected)

Report 30 claimed `chronicle_is_good` is sorry-free and can bypass `succ_cofinal`. This is **incorrect**:

```
completeness_discrete
  → countermodel_discrete_enriched (sorry, Completeness.lean:227)
    → countermodel_discrete (Transfer.lean)
      → dd_countermodel_chronicle_discrete
        → cantor_bfmcs_discrete_restricted_tc (sorryAx)
        → cantor_bfmcs_discrete_restricted_fuc (sorryAx)
          → succ_embed_surjective (sorryAx)
            → limitDomSubtype_isSuccArchimedean (sorryAx)
              → succ_cofinal (ROOT SORRY, line 1508/1885)
```

`chronicle_is_good` is sorry-free as a THEOREM (it takes `ChronicleAsPriorModel` as parameter), but its INSTANTIATION via `extract_chronicle_as_prior` uses `limitDomSubtype_isSuccArchimedean` which depends on `succ_cofinal`.

The OrderIso from `chronicle_is_good` and `succ_embed_surjective` both depend on the same `IsSuccArchimedean`, which comes from `succ_cofinal`.

## 2. succ_cofinal Proof State

Location: ChronicleToCountermodel.lean, lines 1453-1885.

**Completed (8 of 9 steps)**:
- Step 1: All orbit points ≤ pred(b) ✓
- Step 2: Convergence of orbit sequence in ℝ ✓
- Step 3: L ≤ b.val (limit ≤ bound) ✓
- Step 4: Case split on L > pred(b).val vs L ≤ pred(b).val ✓
- Step 5: L > pred(b) case → direct contradiction ✓
- Step 6: orbit_below_L (domain points with val < L are orbit points) ✓
- Step 7: backward_G / backward_F / backward_P truth lemmas ✓
- Step 8: pred-chain analysis (p^[k](pb) ≥ L, strictly decreasing) ✓

**Sorry (Step 9, line 1885)**: Gap elimination in the L ≤ pred(b).val case.

## 3. Why Step 9 Is Hard

The orbit {s^[n](a)} converges to L from below. The pred-chain {p^[k](pb)} has values ≥ L from above. The domain decomposes into orbit points (val < L) and pred-chain points (val ≥ L) in the interval [a, pb], with no domain point at value L.

Three approaches investigated and documented as insufficient:
1. **Prior-UZ maximum principle**: F(φ) → U(φ, ¬φ) at orbit points, but discrete case has no intermediates between consecutive orbit points, making the guard vacuous
2. **Z1 axiom**: G(Gφ→φ) → (FGφ→Gφ) is vacuously true in constant-MCS case
3. **Gap point analysis**: infinite descent on pred chain doesn't terminate (NoMinOrder)

The comments state: "the gap scenario is consistent with all temporal axioms under strict semantics in the constant-MCS case."

## 4. Viable Approaches

### A. Construction-level argument (~200-400 lines)
Show the omega-chain construction CANNOT produce gap points. Every point added by the construction resolves a specific temporal formula failure. In the "constant MCS" scenario (all domain points have identical MCS labels), the construction stabilizes because there are no formula failures to resolve. Therefore the constant-MCS case doesn't arise for an infinite limit domain, and the non-constant case has discriminating formulas.

**Difficulty**: Requires deep interaction with `omega_chain_elim_result`, `BurgessR3Maximal`, and the inductive construction internals.

### B. Reynolds gap elimination (Phases 5-6B, ~1000-1500 lines)
Prove Reynolds Theorem 14 (no gaps in Prior structures), apply to chronicle domain. This is the "Reynolds pipeline" that task 155 was designed around.

**Difficulty**: Requires stavi_expressive_completeness (Phase 4, sorry'd), Reynolds Lemmas 6-14 (not started), and the full gap elimination proof.

### C. Henkin model approach (task 129, ~500-800 lines)
Build a Henkin-style model that is IsSuccArchimedean by construction, avoiding the gap issue entirely.

**Difficulty**: Different proof architecture, significant new infrastructure.

## 5. Recommendation

**Approach A** (construction-level argument) is the most direct and requires the least new infrastructure. The key insight: the omega-chain construction adds a new domain point at each stage to resolve a specific formula F(φ) or P(φ) that was unresolved. If the construction runs for ω stages:
- Each new point resolves a specific formula at a specific existing domain point
- The new point is placed at a specific rational (from Cantor's back-and-forth)
- If all succ iterates of a are bounded by z, then the accumulated points form a convergent sequence
- The construction ADDS points to resolve F(φ) failures. If there are F(φ) failures at orbit points that require witnesses ABOVE all orbit points, those witnesses are gap points
- But such witnesses are orbit points if they're succ iterates, or gap points otherwise

The contradiction: the construction adds point y to resolve F(φ) at x. If x is an orbit point and y is a gap point, then y > succ(x) (since nothing between consecutive orbit points). But the construction places y at a specific rational that respects the existing ordering. If all future orbit points are below L, and y > L, then y is above all existing points at the time it was added.

This requires showing: the construction's point-placement strategy is incompatible with gaps accumulating at L. This is a deep property of the omega-chain construction.

## 6. Summary

| Item | Status |
|------|--------|
| Root sorry | `succ_cofinal` (ChronicleToCountermodel.lean:1885) |
| Steps 1-8 | Complete |
| Step 9 | Sorry (gap elimination) |
| OrderIso bypass | Does NOT work (transitively depends on same sorry) |
| Recommended approach | A (construction-level argument) |
| Estimated effort | 200-400 lines |
| Alternative | B (Reynolds pipeline, ~1000-1500 lines) |
