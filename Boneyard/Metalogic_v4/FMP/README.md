# Metalogic v4 FMP Archive

**Archived**: 2026-01-30
**Task**: 776 - Refactor Metalogic to zero sorry
**Session**: sess_1769738478_e2a1e3

## Purpose

This directory contains deprecated code from `Theories/Bimodal/Metalogic/FMP/` that was archived to achieve zero sorry count in the active codebase. The code is preserved for reference and historical context.

## Archived Files

### SemanticCanonicalFrame.lean
Contains the deprecated `SemanticCanonicalFrame` definition with a sorry in the `compositionality` field.

**Why Sorry is Unfixable**:
The compositionality axiom `task_rel w d1 v -> task_rel v d2 u -> task_rel w (d1+d2) u` is mathematically false for unbounded durations in finite time domain `[-k, k]`. The sum `d1 + d2` can exceed the representable range `[-2k, 2k]`.

**Related Definitions**:
- `SemanticCanonicalModel` - Uses the deprecated frame
- `finiteHistoryToWorldHistory` - Converts finite histories to world histories
- `semantic_world_state_has_world_history` - Existence lemma

### TruthLemmaGap.lean
Contains theorems that depend on the architectural "forward truth lemma gap".

**Why Sorry is Unfixable**:
The forward truth lemma `truth_at_implies_semantic_truth` requires showing that recursive truth evaluation (especially Box which quantifies over ALL histories) matches the shallow assignment check. For non-MCS-derived world states, there's no guarantee the assignment respects recursion. This is an architectural limitation, not a bug.

**Archived Theorems**:
- `truth_at_atom_iff_semantic` - Base case (actually provable, but depends on deprecated code path)
- `truth_at_bot_iff_semantic` - Base case (actually provable, but depends on deprecated code path)
- `truth_at_implies_semantic_truth` - Contains the sorry
- `valid_implies_semantic_truth` - Depends on above
- `valid_implies_neg_unsatisfiable` - Part of the deprecated path
- `set_mcs_neg_excludes_helper` - Helper for deprecated path
- `sorry_free_weak_completeness` - Misnamed (contains sorry via dependency)

### FiniteModelPropertyConstructive.lean
Contains the `finite_model_property_constructive` theorem with a sorry for the truth bridge.

**Why Sorry is Unfixable**:
The theorem tries to show `truth_at (SemanticCanonicalModel phi) tau 0 phi` for a constructed world history. This requires the forward truth lemma which has the architectural gap described above.

## Sorry-Free Alternative

Use `semantic_weak_completeness` from `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`:

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

This theorem is completely sorry-free and provides the completeness result via contrapositive:
1. Assume phi is not provable
2. Then {phi.neg} is consistent
3. Extend to full MCS by Lindenbaum
4. Project to closure MCS
5. Build FiniteWorldState from closure MCS
6. phi is false at this world state (by construction)
7. This contradicts the hypothesis

The contrapositive approach works because:
- We only need to show phi is FALSE at ONE world state
- MCS-derived world states have the truth correspondence property
- No need to reason about ALL histories (the Box problem)

## Architecture Notes

The fundamental issue is the asymmetry between:
1. **Backward direction** (provable -> valid): MCS construction ensures truth correspondence
2. **Forward direction** (valid -> semantic truth): Arbitrary world states may not have truth correspondence

The `semantic_weak_completeness` theorem cleverly avoids the forward direction by using the contrapositive, which only requires the backward direction.

## References

- Task 750: Research on truth lemma gap
- Task 769: Previous archival attempt (deprecated code marking)
- Task 772: WeakCompleteness refactoring
- Blackburn et al., Modal Logic, Chapter 4 (Finite Model Property)
