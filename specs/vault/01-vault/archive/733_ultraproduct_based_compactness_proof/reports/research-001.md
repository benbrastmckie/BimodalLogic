# Research Report: Task #733

**Task**: 733 - Ultraproduct-based proof of compactness for TM logic
**Started**: 2026-01-29T15:52:30Z
**Completed**: 2026-01-29T16:15:00Z
**Effort**: 6-10 hours (estimated)
**Priority**: Medium
**Dependencies**: Task 700 (algebraic infrastructure), Task 735/736 (ultrafilter-MCS correspondence)
**Sources/Inputs**: Mathlib.ModelTheory.Ultraproducts, Mathlib.ModelTheory.Satisfiability, existing codebase
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The current compactness proof (`Compactness.lean`) relies on `infinitary_strong_completeness`, which has a sorry requiring exactly the ultraproduct argument we want to provide
- Mathlib provides complete ultraproduct machinery in `Mathlib.ModelTheory.Ultraproducts` with Łoś's theorem (`sentence_realize`)
- The challenge is that TM logic is not first-order: it has modal operators (□) and temporal operators (G/H) that require Kripke-style semantics
- Two approaches are viable: (1) adapt Mathlib's first-order ultraproduct to TM semantics, or (2) build a specialized ultraproduct for TaskModels
- Recommended approach: Build TaskModel ultraproducts directly, using the algebraic infrastructure from Task 700

## Context & Scope

### What Was Researched

1. Current compactness proof structure in the codebase
2. Mathlib's ultraproduct implementation for first-order logic
3. Existing algebraic infrastructure (Lindenbaum algebra, ultrafilter-MCS correspondence)
4. Compatibility of TM semantics with ultraproduct construction

### Constraints

- TM logic is bimodal (box + temporal operators), not first-order
- TaskModels are polymorphic over temporal type `D : Type*` with `LinearOrderedAddCommGroup D`
- The ultraproduct must preserve modal and temporal truth conditions
- Should integrate with existing algebraic approach (Task 700)

## Findings

### Current Compactness Proof Structure

The existing proof in `Theories/Bimodal/Metalogic/Compactness/Compactness.lean`:

```lean
theorem compactness (Gamma : Set Formula) :
    (∀ (Delta : Finset Formula), ↑Delta ⊆ Gamma → set_satisfiable ↑Delta) →
    set_satisfiable Gamma
```

This proof relies on `infinitary_strong_completeness` (line 141), which itself has a sorry at `InfinitaryStrongCompleteness.lean:175`. The comment explicitly states:

> "The full proof requires either: 1. Model-theoretic compactness (ultraproducts), or 2. A proof-theoretic argument showing derivations use finite premises"

### Mathlib's Ultraproduct Theorem

`Mathlib.ModelTheory.Satisfiability` provides (lines 98-119):

```lean
theorem isSatisfiable_iff_isFinitelySatisfiable {T : L.Theory} :
    T.IsSatisfiable ↔ T.IsFinitelySatisfiable
```

The proof constructs:
1. Index type: `Finset T` (finite subsets of theory)
2. Model family: `M : Finset T → Type` where each `M T0` is a model of `T0`
3. Ultrafilter: `Ultrafilter.of Filter.atTop` on `Finset T`
4. Ultraproduct: `Filter.Product u M`

Key lemma used: `Ultraproduct.sentence_realize` (Łoś's theorem):
```lean
theorem sentence_realize (φ : L.Sentence) :
    u.Product M ⊨ φ ↔ ∀ᶠ a in u, M a ⊨ φ
```

### Challenges for TM Logic

TM logic differs from first-order logic in critical ways:

1. **Modal Semantics**: Truth is evaluated at world-history-time triples `(M, τ, t)`, not just in a structure
2. **World Histories**: The modal operator □ quantifies over all world histories through the current time
3. **Temporal Operators**: G/H quantify over times within a world history's domain
4. **Polymorphic Time**: Temporal type `D` varies (ℤ, ℚ, ℝ, etc.)

The ultraproduct construction for TM must handle:
- Product of TaskFrames
- Product of WorldHistories (or equivalence classes thereof)
- Preservation of task relation compositionality/nullity

### Algebraic Infrastructure (Task 700)

The algebraic approach in `Theories/Bimodal/Metalogic/Algebraic/` provides:

1. **LindenbaumQuotient.lean**: Lindenbaum-Tarski algebra `Formula / ≈ₚ`
2. **BooleanStructure.lean**: `BooleanAlgebra LindenbaumAlg` instance
3. **UltrafilterMCS.lean**: Bijection between ultrafilters and MCS (partial, has sorries)
4. **AlgebraicRepresentation.lean**: `AlgSatisfiable φ ↔ AlgConsistent φ` (partial)

The key missing piece is `consistent_implies_satisfiable` at line 77:
```lean
theorem consistent_implies_satisfiable {φ : Formula} (h : AlgConsistent φ) :
    AlgSatisfiable φ := sorry
```

This requires proving: for any non-⊥ element of the Lindenbaum algebra, there exists an ultrafilter containing it.

### Two Viable Approaches

#### Approach A: Algebraic Compactness (Recommended)

Use the ultrafilter-MCS correspondence to prove compactness algebraically:

1. **Prime Ultrafilter Existence**: Prove that for any `a ≠ ⊥` in `LindenbaumAlg`, there exists an ultrafilter `U` with `a ∈ U`
   - Requires Zorn's lemma or Boolean Prime Ideal theorem
   - Mathlib provides `Filter.exists_ultrafilter_le` for filters

2. **Connect to Satisfiability**: Use `ultrafilterToSet_mcs` (already proved) to convert ultrafilters to MCS

3. **Construct Canonical Model**: Use the existing canonical model construction from Task 654/656

4. **Derive Compactness**:
   - If every finite Δ ⊆ Γ is satisfiable, then Δ is consistent
   - By finitary nature of proofs, Γ is consistent
   - By prime ultrafilter existence, there's an ultrafilter containing [Γ]
   - By ultrafilter-MCS correspondence, get an MCS ⊇ Γ
   - By truth lemma, get satisfying model

**Pros**:
- Leverages existing algebraic infrastructure
- Avoids constructing ultraproducts of TaskModels directly
- Mathematically elegant

**Cons**:
- Requires completing Task 735/736 sorries first
- Does not provide a constructive ultraproduct model

#### Approach B: Direct TaskModel Ultraproduct

Build ultraproducts of TaskModels directly:

1. **Define TaskFrame Ultraproduct**:
   - World states: Ultraproduct of world state types
   - Time: Fix a single temporal type D (or take the ultraproduct of time types)
   - Task relation: Lifted componentwise

2. **Define WorldHistory Ultraproduct**:
   - Domain: Intersection of domains (or ultrafilter-modified)
   - States function: Componentwise application

3. **Prove Łoś-style Theorem**: For TM sentences
   ```
   ultraproduct M ⊨ φ ↔ {i | Mᵢ ⊨ φ} ∈ U
   ```

4. **Apply to Compactness**: Following Mathlib's pattern

**Pros**:
- Provides explicit ultraproduct construction
- More direct/classical proof

**Cons**:
- Significant new machinery required
- Must handle modal/temporal operators carefully
- Polymorphic time complicates things

### Relevant Mathlib Resources

| Resource | Location | Purpose |
|----------|----------|---------|
| `Filter.exists_ultrafilter_le` | `Mathlib.Order.Filter.Ultrafilter.Defs` | Ultrafilter existence |
| `Ultrafilter.of` | `Mathlib.Order.Filter.Ultrafilter.Defs` | Construct ultrafilter from filter |
| `Filter.Product` | `Mathlib.ModelTheory.Ultraproducts` | Ultraproduct construction |
| `sentence_realize` | `Mathlib.ModelTheory.Ultraproducts` | Łoś's theorem |
| `isSatisfiable_iff_isFinitelySatisfiable` | `Mathlib.ModelTheory.Satisfiability` | First-order compactness |

## Decisions

1. **Recommended Approach**: Algebraic (Approach A)
   - Aligns with existing Task 700 direction
   - Less new machinery required
   - Dependencies (Tasks 735/736) are already in progress

2. **Key Dependency**: The `consistent_implies_satisfiable` theorem requires proving ultrafilter existence for non-trivial Boolean algebra elements

3. **Scope**: This task should focus on the compactness proof itself, assuming Tasks 735/736 complete the ultrafilter-MCS correspondence

## Recommendations

### Phase 1: Complete Dependencies (1-2 hours)
1. Verify Tasks 735/736 are complete or identify remaining sorries
2. Ensure `mcs_ultrafilter_correspondence` bijection is proven

### Phase 2: Prime Ultrafilter Existence (2-3 hours)
1. Prove: For any `a ≠ ⊥` in `LindenbaumAlg`, exists `U : Ultrafilter` with `a ∈ U`
2. Use Mathlib's `Filter.exists_ultrafilter_le` or Boolean Prime Ideal theorem
3. Fill the `consistent_implies_satisfiable` sorry in `AlgebraicRepresentation.lean`

### Phase 3: Algebraic Compactness (2-3 hours)
1. Prove: consistent formulas have models via ultrafilter existence
2. Connect to `infinitary_strong_completeness` to remove its sorry
3. Verify `compactness` theorem follows

### Phase 4: Integration (1-2 hours)
1. Update imports/exports
2. Run `lake build` to verify
3. Document the proof in module docstrings

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Tasks 735/736 have blocking sorries | High | Review and complete those first |
| Boolean Prime Ideal requires Choice | Medium | Already using classical logic throughout |
| Ultrafilter existence proof complex | Medium | Use Mathlib's existing infrastructure |
| Time type polymorphism complicates proof | Low | Work with generic D, leverage parametric completeness |

## Appendix

### Search Queries Used

1. `lean_local_search "ultraproduct"` - No local results
2. `lean_local_search "compactness"` - Found existing theorems
3. `lean_leansearch "ultraproduct of structures model theory"` - Found Mathlib.ModelTheory.Ultraproducts
4. `lean_leansearch "compactness theorem via ultraproduct"` - Found isSatisfiable_iff_isFinitelySatisfiable
5. `lean_leanfinder "ultraproduct Los theorem model theory"` - Found sentence_realize

### File References

- `Theories/Bimodal/Metalogic/Compactness/Compactness.lean` - Current compactness proof
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean:175` - Key sorry
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean:77` - consistent_implies_satisfiable sorry
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean:329` - mcs_ultrafilter_correspondence sorry
- `.lake/packages/mathlib/Mathlib/ModelTheory/Satisfiability.lean` - Mathlib compactness proof

## Next Steps

1. Review Task 735/736 status - check if ultrafilter-MCS correspondence is complete
2. If complete: proceed with Phase 2 (prime ultrafilter existence)
3. If incomplete: coordinate with those tasks first
4. Create implementation plan after Phase 1 assessment
