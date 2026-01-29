# Failed Truth Lemma Approaches (Task 750)

This directory contains files archived during Task 750 that attempted to solve
the "forward truth lemma" gap via different approaches. All approaches failed
due to the same fundamental obstacle: **Box semantics**.

## The Fundamental Problem

The forward truth lemma requires proving:
```
truth_at M tau t phi → semantic_truth_at_v2 w phi
```

For Box formulas, this means showing:
```
(∀ sigma : WorldHistory, truth_at M sigma t psi) → (box psi assignment is true)
```

The problem is that `truth_at (box psi)` quantifies over ALL world histories,
while our constructions (MCS, ultrafilters) only have information about ONE
specific world state. There's no way to bridge this gap without restricting
which histories we consider - but Box semantics by definition considers ALL.

## Archived Files

### MCSDerivedWorldState.lean

**Original location**: `Metalogic/FMP/MCSDerivedWorldState.lean`

**Approach**: Restrict truth lemma to "MCS-derived" world states - those that
carry proof of derivation from a Closure Maximal Consistent set.

**Why it failed**: Even for MCS-derived states, the Box case requires truth
at ALL histories, not just MCS-derived ones. The MCS restriction only helps
with the assignment side, not the universal quantification over histories.

### AlgebraicSemanticBridge.lean

**Original location**: `Metalogic/Algebraic/AlgebraicSemanticBridge.lean`

**Approach**: Bridge the algebraic representation theorem (ultrafilter membership)
to standard Kripke semantics (truth_at evaluation).

**Why it failed**: Same fundamental problem. `algTrueAt U (box psi)` means
`[box psi] ∈ U` (membership in ONE ultrafilter), while `truth_at (box psi)`
requires truth at ALL histories. No bridge between these.

### HybridCompleteness.lean

**Original location**: `Metalogic/Algebraic/HybridCompleteness.lean`

**Approach**: Combine algebraic and FMP paths:
1. Use algebraic theorem to get MCS from unprovability
2. Project to closure MCS
3. Build finite model where formula is false
4. Connect to general validity

**Why it failed**: The final step (valid → semantic_truth_at_v2 everywhere)
requires exactly the forward truth lemma that the other approaches couldn't prove.

## The Correct Solution

Use `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean`:

```lean
theorem semantic_weak_completeness (phi : Formula) :
    (∀ w : SemanticWorldState phi, semantic_truth_at_v2 phi w origin phi) → ⊢ phi
```

This works via **contrapositive**:
- If `¬(⊢ phi)`, construct a countermodel (MCS-derived state where phi is false)
- The countermodel construction uses only the *backward* direction (MCS membership → assignment)
- No forward truth lemma needed

**Key insight**: For completeness, we don't need to prove that valid formulas
have the right semantic assignment everywhere. We only need to show that
unprovable formulas have countermodels. The contrapositive approach sidesteps
the Box limitation entirely.

## Related Tasks

- Task 750: Research-012 identified the Box limitation as fundamental
- Task 750: Implementation-006 archived these approaches

## References

- SemanticCanonicalModel.lean: `semantic_weak_completeness` (the sorry-free solution)
- Research-012: Analysis of Box semantics limitation
