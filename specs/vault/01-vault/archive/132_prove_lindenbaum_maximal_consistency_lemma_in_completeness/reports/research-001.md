# Research Report: Task #132

**Task**: Prove Lindenbaum maximal consistency lemma in Completeness.lean
**Date**: 2026-01-12
**Session**: sess_1768240721_547bfc

## Summary

The Lindenbaum lemma is currently an axiom placeholder in `Bimodal/Metalogic/Completeness.lean:117-118`. Proving it requires using Zorn's lemma from Mathlib to extend consistent sets to maximal consistent sets. The existing infrastructure (Deduction Theorem, Soundness, Derivation system) provides a solid foundation. Main challenge is proving that unions of chains of consistent sets remain consistent.

## Findings

### 1. Current Codebase State

**File**: `Theories/Bimodal/Metalogic/Completeness.lean`

**Current Axiom Placeholder** (lines 117-118):
```lean
axiom lindenbaum (Γ : Context) (h : Consistent Γ) :
  ∃ Δ : Context, (∀ φ, φ ∈ Γ → φ ∈ Δ) ∧ MaximalConsistent Δ
```

**Existing Definitions** (lines 69-93):
- `Consistent Γ : Prop` - Defined as `¬Nonempty (DerivationTree Γ Formula.bot)`
- `MaximalConsistent Γ : Prop` - Defined as `Consistent Γ ∧ ∀ φ : Formula, φ ∉ Γ → ¬Consistent (φ :: Γ)`

**Supporting Infrastructure**:
- **Deduction Theorem**: Fully implemented in `Bimodal/Metalogic/DeductionTheorem.lean` with well-founded recursion
- **Soundness Theorem**: Complete with all 14 axiom validity lemmas proven
- **Derivation System**: `DerivationTree` is a `Type` (not `Prop`), enabling pattern matching

### 2. Mathlib Resources for Zorn's Lemma

**Primary Candidate** - `Mathlib.Order.Zorn`:

```lean
theorem zorn_le_nonempty₀ {α : Type*} [Preorder α] (s : Set α)
  (h : ∀ c ⊆ s, IsChain (· ≤ ·) c → ∀ y ∈ c, ∃ ub ∈ s, ∀ z ∈ c, z ≤ ub) :
  ∀ x ∈ s, ∃ m, x ≤ m ∧ Maximal (· ∈ s) m
```

This is the recommended approach because:
- Directly produces maximal elements extending a given element
- Takes a non-empty set and guarantees maximal extensions
- Requires proving chain upper bounds exist within the set

**Supporting Definitions**:
- `Maximal (P : α → Prop) (x : α) : Prop` from `Mathlib.Order.Max`
- `IsChain (· ≤ ·) c` for chain definition

### 3. Recommended Proof Strategy

**Phase 1: Setup Preorder on Contexts**
1. Define `≤` on contexts as subset inclusion: `Γ₁ ≤ Γ₂ := ∀ φ, φ ∈ Γ₁ → φ ∈ Γ₂`
2. Show this forms a preorder (reflexive, transitive)
3. Note: Not antisymmetric for list equality, but preorder suffices

**Phase 2: Define Target Set**
```lean
def ConsistentExtensions (Γ : Context) : Set Context :=
  {Δ : Context | (∀ φ, φ ∈ Γ → φ ∈ Δ) ∧ Consistent Δ}
```
- Non-empty: contains Γ itself (given consistent hypothesis)
- Ordered by subset inclusion

**Phase 3: Prove Chain Upper Bound Property (Critical)**

For any chain `c` of consistent extensions:
1. Form union: `⋃ Δ ∈ c, Δ`
2. **Key Lemma**: Union is an upper bound in the set

```lean
lemma consistent_union_chain (c : Set Context)
  (chain : IsChain (· ≤ ·) c)
  (h : ∀ Δ ∈ c, Consistent Δ) :
  Consistent (⋃ Δ ∈ c, Δ)
```

**Proof Sketch**:
- Assume `⋃ Δ ⊢ ⊥` (derivation tree exists)
- By finiteness of derivation trees, only finitely many formulas from context used
- These finite formulas all contained in some single chain member (directed set property)
- But that member is consistent, contradiction

**Phase 4: Apply Zorn's Lemma**
```lean
have := zorn_le_nonempty₀ (ConsistentExtensions Γ) chain_property Γ ⟨refl, h⟩
```
Obtain maximal element Δ* with `Γ ⊆ Δ*` and `Maximal (· ∈ ConsistentExtensions Γ) Δ*`

**Phase 5: Verify MaximalConsistent**

Show that `Maximal (· ∈ S) Δ*` implies `MaximalConsistent Δ*`:
- If we could add φ and stay consistent, we could extend Δ* in S
- This contradicts maximality of Δ* in S

### 4. Implementation Challenges

| Challenge | Description | Mitigation |
|-----------|-------------|------------|
| Context Representation | `Context := List Formula` vs sets in Zorn | Work with `Set Formula` internally, convert via membership |
| Finiteness of Derivations | Must show derivations use finite context | Prove `deriv_uses_finite_context` lemma using induction on tree |
| Classical Logic | Maximality arguments need classical reasoning | Already used in Soundness.lean (`Classical.byContradiction`) |
| Chain Union Construction | Unions of lists are not lists directly | Use `Set Formula` as intermediate representation |

### 5. Required Lemmas

**Must be implemented**:
1. `consistent_union_chain` - Unions of chains of consistent sets are consistent
2. `deriv_uses_finite_context` - Any derivation uses finitely many context formulas
3. `maximal_in_preorder_iff` - Link Zorn maximality to `MaximalConsistent` definition

**Already Available**:
- Deduction theorem (`deduction_thm`)
- Soundness theorem
- Derivation tree induction principles

### 6. Related Tasks and Dependencies

**Dependent Tasks** (from TODO.md):
- Task 133: Build canonical model constructors (depends on 132)
- Task 134: Prove truth lemma (depends on 133)
- Task 135: Remove provable_iff_valid sorry (depends on 132, 133, 134)
- Task 257: Full completeness proofs (umbrella task)

**Blocking Resolution**:
- Task 132 has no code dependencies
- Can be developed independently of other tasks
- Currently on hold pending "Bimodal polish (Task 360)" but research is preparatory

## Recommendations

1. **Use `Set Formula` Intermediate Representation**: Convert between `List Formula` (Context) and `Set Formula` for Zorn's lemma application. This avoids the need to reason about list equality.

2. **Prove Finiteness First**: The `deriv_uses_finite_context` lemma is the critical piece. Prove it by induction on `DerivationTree` structure.

3. **Follow Task 257's Research**: The completeness task (257) has research recommending this order:
   - First prove `maximal_consistent_closed`
   - Then prove `maximal_negation_complete`
   - Finally prove `lindenbaum`

4. **Consider Bimodal Context**: Since this is in the Bimodal theory (not Logos), ensure the proof strategy aligns with Bimodal-specific derivation rules.

## References

- `Mathlib.Order.Zorn` - Zorn's lemma variants
- `Mathlib.Order.Max` - Maximality definitions
- `Bimodal/Metalogic/DeductionTheorem.lean` - Pattern for well-founded recursion
- `Bimodal/Metalogic/Soundness.lean` - Usage of classical logic patterns
- Task 257 research (`research-001.md`) - Completeness proof roadmap

## Next Steps

1. **Immediate**: `/plan 132` to create implementation plan based on this research
2. **Then**: Implement `deriv_uses_finite_context` lemma
3. **Then**: Implement `consistent_union_chain` using Zorn's lemma
4. **Finally**: Prove `lindenbaum` and remove the axiom

## Estimated Effort

| Component | Hours |
|-----------|-------|
| Finiteness lemma | 4-5 |
| Chain union lemma | 4-5 |
| Zorn application | 2-3 |
| Maximality verification | 2-3 |
| Testing & refinement | 2-3 |
| **Total** | 14-19 |

Note: Original estimate was 3 hours; actual implementation will likely require 14-19 hours due to the complexity of the Zorn's lemma application and finiteness arguments.
