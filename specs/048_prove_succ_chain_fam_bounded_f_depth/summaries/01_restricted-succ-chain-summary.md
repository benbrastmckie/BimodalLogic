# Implementation Summary: Task #48

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [BLOCKED]
- **Date**: 2026-03-23
- **Session**: sess_1774288277_b4cedd

## Executive Summary

The task aimed to prove that F/P-iteration depth is bounded in the succ_chain_fam construction. Research revealed that the existing `f_nesting_is_bounded` and `p_nesting_is_bounded` theorems are **mathematically impossible to prove** as stated because an arbitrary MCS can consistently contain all F/P-iterations.

The correct approach requires using `RestrictedMCS` (MCS bounded by a finite closure), which guarantees F/P-iterations eventually leave the set. Partial implementation was completed: provable restricted versions added, P-infrastructure created, deprecated markers added. Full resolution requires restructuring the chain construction (Phases 3-4).

## Completed Work

### Phase 1 (Partial): RestrictedSerialMCS and Infrastructure

**Completed**:
- Added `RestrictedSerialMCS` structure to SuccChainFMCS.lean
- Added P-nesting depth infrastructure:
  - `p_nesting_depth` and `max_P_depth_in_closure` in SubformulaClosure.lean
  - `iter_P_p_nesting_depth`, `closure_P_bound`, `iter_P_leaves_closure` in CanonicalTaskRelation.lean
- Added `restricted_mcs_P_bounded` to RestrictedMCS.lean (symmetric to F-bounded from Task 47)

**Not completed**:
- Restricted chain construction (requires modifying deferral seed to use `restricted_lindenbaum`)

### Phase 2 (Completed): Adapted F/P Boundedness Lemmas

**Completed**:
- `f_nesting_is_bounded_restricted`: Provable version using RestrictedMCS
- `f_nesting_boundary_restricted`: Provable boundary lemma
- `p_nesting_is_bounded_restricted`: Provable version using RestrictedMCS
- `p_nesting_boundary_restricted`: Provable boundary lemma
- Deprecated original theorems with `@[deprecated]` attribute and clear migration documentation

## Blocker Analysis

### Root Cause

The theorems `f_nesting_is_bounded` and `p_nesting_is_bounded` claim:

```lean
theorem f_nesting_is_bounded (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M
```

This is **FALSE** for arbitrary `SetMaximalConsistent M`. An MCS can consistently contain the infinite set `{F(phi), FF(phi), FFF(phi), ...}` because:
1. These formulas are all distinct (by complexity)
2. There's no derivation of `bot` from any finite subset
3. Lindenbaum's lemma extends to a full MCS

### Correct Statement

The correct version requires `RestrictedMCS`:

```lean
theorem f_nesting_is_bounded_restricted (psi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS psi M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M
```

This is **PROVABLE** because `M ⊆ closureWithNeg psi` and the closure is finite.

### Resolution Path

Full resolution requires:
1. **Restructure chain construction**: Build restricted chains using `restricted_lindenbaum`
2. **Update completeness proof**: Use `RestrictedMCS` built from target formula's closure
3. **Migrate callers**: Update all uses of the deprecated theorems

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Syntax/SubformulaClosure.lean` | Added p_nesting_depth, max_P_depth_in_closure |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` | Added P-closure bounds and iter_P lemmas |
| `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` | Added restricted_mcs_P_bounded |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | Added RestrictedSerialMCS, restricted versions, deprecated old |

## Verification

- **Build**: Passes (`lake build` succeeds)
- **Sorry count**: 238 (unchanged in target theorems, provable alternatives added)
- **Axiom count**: 5 (no new axioms introduced)
- **New sorries**: 0 (new restricted versions are sorry-free)

## Recommendations

1. **Accept as blocked**: The original theorem statements are mathematically false
2. **Consider alternative completeness strategy**: Use FMCSTransfer from dovetailed model or restructure chain construction
3. **Document in theory**: Add mathematical note explaining why arbitrary MCS boundedness fails
4. **Future work**: Create task for Phase 3-4 to complete the restricted chain construction

## Technical Notes

The key mathematical insight: in a syntactic MCS construction, F-obligations can be deferred indefinitely via the disjunction `phi ∨ F(phi)`. Each successor MCS can consistently choose to defer (keep F(phi)) rather than resolve (include phi). This is why boundedness only holds when the MCS is restricted to a finite closure.
