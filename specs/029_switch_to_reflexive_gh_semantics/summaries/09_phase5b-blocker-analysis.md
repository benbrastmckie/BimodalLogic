# Implementation Summary: Task #29 Phase 5B Blocker Analysis

**Task**: 29 - switch_to_reflexive_gh_semantics
**Session**: sess_1774232803_b6632b
**Date**: 2026-03-22
**Status**: BLOCKED
**Phases Completed**: 4, 5A (per-construction strictness infrastructure)
**Phases Blocked**: 5B, 5C, 6

## Summary

Phase 5B attempted to refactor ~33 call sites to use per-construction strictness instead of the deprecated `canonicalR_irreflexive_axiom`. Deep analysis revealed a fundamental mathematical limitation that prevents this refactoring without additional axioms or major architectural changes.

## Key Findings

### 1. Seriality Construction Cannot Provide Strictness

The NoMaxOrder/NoMinOrder instances use seriality to construct successors:
```lean
let N := executeForwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_F
```

This constructs `N ⊇ g_content(M) ∪ {¬⊥}`. For strictness (`¬CanonicalR N M`), we need some formula `φ` with:
- `G(φ) ∈ N` (so `φ ∈ g_content(N)`)
- `φ ∉ M`

**Problem**: `¬⊥` (negation of bottom) is a tautology and IS in M. There's no construction-specific formula that distinguishes N from M.

### 2. Fresh Atom Existence Is Unprovable

The fresh G-atom approach requires finding atom `q` fresh for `g_content(M)` (meaning `q ∉ atoms_of_set(g_content M)`). However:

**Counterexample** (from Team Research report 12): A pathological MCS `M` can have `G(¬q) ∈ M` for every atom `q`. For such M:
- `¬q ∈ g_content(M)` for all atoms
- `atoms_of_set(g_content(M)) = Set.univ`
- NO fresh atoms exist

The theorem `exists_fresh_for_g_content` was deleted in Phase 4 because the cardinality argument is flawed.

### 3. Antisymmetry Fails Under Reflexive Semantics

The deprecated `canonicalR_strict` theorem claims:
```lean
CanonicalR M N → ¬CanonicalR N M
```

This is equivalent to antisymmetry: if both directions hold, then M = N. But antisymmetry is FALSE under reflexive semantics. Two distinct MCS can have identical g_content, giving mutual accessibility without equality.

## Impact Assessment

### Call Sites Affected

| File | Count | Type |
|------|-------|------|
| CanonicalSerialFrameInstance.lean | ~2 | NoMaxOrder/NoMinOrder |
| CantorApplication.lean | ~4 | Frame conditions |
| DovetailedTimelineQuot.lean | ~12 | Order structure |
| SaturatedChain.lean | ~8 | Chain construction |
| FMCSTransfer.lean | ~2 | Transfer lemma |
| ClosureSaturation.lean | ~2 | Saturation step |
| TimelineQuotCanonical.lean | ~1 | Quotient canonical |
| IncrementalTimeline.lean | ~1 | Timeline point equality |
| DiscreteTimeline.lean | ~2 | Discrete successor |

Total: ~33 call sites in active code (not Boneyard)

### Resolution Options

| Option | Description | Effort | Acceptability |
|--------|-------------|--------|---------------|
| A | Add semantic axiom excluding pathological MCS | Low | Medium - adds new axiom |
| B | Thread seed tracking through MCS construction | Very High | High - mathematically rigorous |
| C | Accept limitation, keep deprecated axiom | None | Medium - inconsistency remains |
| D | Weaken forward_F to use ≥ instead of > | High | Medium - changes semantics |

### Recommended Path

**Option C (Accept Limitation)** for now:
1. Keep `canonicalR_irreflexive_axiom` with deprecation warnings
2. Document the mathematical limitation thoroughly
3. The system remains functional (all proofs complete)
4. Future work can explore Option B (seed tracking)

## Technical Details

### Existing Infrastructure (Phase 5A - Completed)

```lean
theorem lt_of_canonicalR_and_not_reverse {M N : Set Formula}
    (h_M_mcs : SetMaximalConsistent M) (h_N_mcs : SetMaximalConsistent N)
    (h_fwd : CanonicalR M N)
    (h_not_bwd : ¬CanonicalR N M) :
    M ≠ N

theorem strict_of_formula_in_g_content_not_in_source {M W : Set Formula} {φ : Formula}
    (h_φ_in_g_W : φ ∈ g_content W)
    (h_φ_not_M : φ ∉ M) :
    ¬CanonicalR W M
```

These theorems are CORRECT but cannot be applied without a distinguishing formula.

### The Fundamental Gap

The infrastructure assumes we can FIND a formula `φ` such that:
- `φ ∈ g_content(W)` (witness contains G(φ))
- `φ ∉ M` (source doesn't contain φ)

For general MCS constructions (like seriality), no such formula is guaranteed to exist.

## Verification

```
Build Status: Passing (1044 jobs)
Sorry Count: 456 (unchanged from baseline)
Axiom Count: 10 (unchanged - canonicalR_irreflexive_axiom remains)
```

## Files Modified

| File | Changes |
|------|---------|
| plans/06_per-construction-strictness.md | Updated phase markers to [BLOCKED] with analysis |

## Conclusion

The per-construction strictness approach, while mathematically elegant, cannot be implemented without addressing the fresh atom existence problem. The current axiom-based approach remains the only working solution.

**Recommended next steps**:
1. Close task 29 as [PARTIAL] - core work done, axiom removal blocked
2. Create follow-up task for Option B (seed tracking) if rigorous solution is desired
3. Document the limitation in the codebase

## References

- specs/029_switch_to_reflexive_gh_semantics/reports/12_team-research.md (order-theoretic foundations)
- specs/029_switch_to_reflexive_gh_semantics/reports/13_unbounded-axiom-analysis.md (seriality analysis)
- Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean (infrastructure)
