# Research Report: Task #736

**Task**: 736 - Complete phase 6 of task 700: Algebraic Representation Theorem
**Started**: 2026-01-29T12:31:00Z
**Completed**: 2026-01-29T12:45:00Z
**Effort**: TBD
**Priority**: Medium
**Dependencies**: Task 700 (phases 1-5 completed)
**Sources/Inputs**: Mathlib, lean_leansearch, lean_loogle, lean_leanfinder, codebase analysis
**Artifacts**: specs/736_complete_task700_phase6_algebraic_representation/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- **Two sorries require completion**: `consistent_implies_satisfiable` in `AlgebraicRepresentation.lean` and `mcs_ultrafilter_correspondence` in `UltrafilterMCS.lean`
- **Key insight**: The ultrafilter existence proof requires proving that for non-⊥ element `a`, there exists an ultrafilter containing `a`
- **Approach**: Use Lindenbaum's lemma (`set_lindenbaum`) already available in the codebase, combined with the `mcsToSet` and `ultrafilterToSet_mcs` theorems
- **Bijection proof**: Requires defining `mcsToUltrafilter` function and proving it's inverse to `ultrafilterToSet`

## Context & Scope

Task 736 completes phase 6 of the algebraic representation theorem development (task 700). The goal is to prove two key results:

1. **`consistent_implies_satisfiable`**: If a formula φ is consistent (⊬ ¬φ), then φ is algebraically satisfiable (exists ultrafilter U with [φ] ∈ U)
2. **`mcs_ultrafilter_correspondence`**: Bijection between MCS and ultrafilters of the Lindenbaum algebra

### Files Involved

| File | Role | Status |
|------|------|--------|
| `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` | Main theorem | Line 71-77: `sorry` |
| `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` | MCS-Ultrafilter bijection | Line 325-329: `sorry` |
| `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` | Lindenbaum algebra definition | Complete |
| `Theories/Bimodal/Metalogic/Algebraic/BooleanStructure.lean` | Boolean algebra instance | Complete |
| `Theories/Bimodal/Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` | MCS theory | Contains `set_lindenbaum` |

## Findings

### 1. Ultrafilter Structure (Custom Definition)

The codebase defines a custom `Ultrafilter` structure in `UltrafilterMCS.lean`:

```lean
structure Ultrafilter (α : Type*) [BooleanAlgebra α] where
  carrier : Set α
  top_mem : ⊤ ∈ carrier
  bot_not_mem : ⊥ ∉ carrier
  mem_of_le : ∀ {a b}, a ∈ carrier → a ≤ b → b ∈ carrier
  inf_mem : ∀ {a b}, a ∈ carrier → b ∈ carrier → a ⊓ b ∈ carrier
  compl_or : ∀ a, a ∈ carrier ∨ aᶜ ∈ carrier
  compl_not : ∀ a, a ∈ carrier → aᶜ ∉ carrier
```

This is a Boolean algebra ultrafilter definition (filter-theoretic), distinct from Mathlib's type-level `Filter.Ultrafilter`.

### 2. Existing Theorems in Codebase

#### Available in `UltrafilterMCS.lean`:
- `mcsToSet : Set Formula → Set LindenbaumAlg` - Maps MCS to quotient classes
- `mcsToSet_top` - Proves ⊤ ∈ mcsToSet Γ for MCS Γ
- `ultrafilterToSet : Ultrafilter LindenbaumAlg → Set Formula` - Maps ultrafilter to formulas
- `ultrafilterToSet_mcs` - **Proves ultrafilterToSet U is an MCS** (complete!)
- `fold_le_of_derives` - Key lemma relating derivations to quotient ordering

#### Available in `MaximalConsistent.lean`:
- `SetMaximalConsistent` - Set-based MCS definition
- `set_lindenbaum` - **Lindenbaum's lemma**: Every consistent set extends to MCS
- `theorem_in_mcs` - Theorems belong to every MCS
- `maximal_negation_complete` - MCS negation completeness

#### Available in `BooleanStructure.lean`:
- `BooleanAlgebra LindenbaumAlg` instance - **Complete!**
- `compl_eq_top` - Used in `satisfiable_implies_consistent` (proven)

### 3. Mathlib Theorems (Reference Only)

| Theorem | Module | Type | Relevance |
|---------|--------|------|-----------|
| `Ultrafilter.exists_le` | Filter.Ultrafilter.Defs | `(f : Filter α) [NeBot f] → ∃ u, ↑u ≤ f` | Different ultrafilter type |
| `Ultrafilter.of` | Filter.Ultrafilter.Defs | `(f : Filter α) [NeBot f] → Ultrafilter α` | Constructive version |
| `zorn_le₀` | Order.Zorn | Zorn's lemma for partial orders | Used by `set_lindenbaum` |
| `Function.bijective_iff_has_inverse` | Logic.Function.Basic | Bijection ↔ has inverse | For bijection proof |

**Note**: Mathlib's `Filter.Ultrafilter` is different from the custom Boolean algebra ultrafilter structure. The custom structure is appropriate for the Lindenbaum algebra context.

### 4. Proof Strategy for `consistent_implies_satisfiable`

**Goal**: `AlgConsistent φ → AlgSatisfiable φ`
- Where `AlgConsistent φ = ¬Nonempty (⊢ ¬φ)`
- And `AlgSatisfiable φ = ∃ U : AlgWorld, toQuot φ ∈ U.carrier`

**Strategy**:
1. If ⊬ ¬φ, then [¬φ] ≠ ⊤ in the Lindenbaum algebra
2. Therefore [φ] = [¬φ]ᶜ ≠ ⊥ (since complement of ⊤ is ⊥)
3. Need to prove: **For any non-⊥ element a of a Boolean algebra, there exists an ultrafilter containing a**

**Key Lemma Required**: `exists_ultrafilter_containing`
```lean
theorem exists_ultrafilter_containing {α : Type*} [BooleanAlgebra α]
    {a : α} (h : a ≠ ⊥) : ∃ U : Ultrafilter α, a ∈ U.carrier
```

**Proof Approach for Key Lemma**:
1. Define the "principal filter generated by a": `{b | a ≤ b}`
2. Show this is a proper filter (since a ≠ ⊥)
3. Extend to an ultrafilter using Zorn's lemma

**Alternative using MCS machinery**:
1. The formula representing a (any φ with [φ] = a) is consistent (since a ≠ ⊥ means ⊬ ¬φ equivalent)
2. Use `set_lindenbaum` to extend {φ} to an MCS Γ
3. Convert Γ to an ultrafilter using `mcsToUltrafilter`
4. This ultrafilter contains a = [φ]

### 5. Proof Strategy for `mcs_ultrafilter_correspondence`

**Goal**: Define f and g such that:
- `f : {Γ : Set Formula // SetMaximalConsistent Γ} → Ultrafilter LindenbaumAlg`
- `g : Ultrafilter LindenbaumAlg → {Γ : Set Formula // SetMaximalConsistent Γ}`
- `Function.LeftInverse g f` - g(f(Γ)) = Γ
- `Function.RightInverse g f` - f(g(U)) = U

**Existing Components**:
- `ultrafilterToSet U` already exists and `ultrafilterToSet_mcs` proves it's an MCS
- So `g` is essentially `fun U => ⟨ultrafilterToSet U, ultrafilterToSet_mcs U⟩`

**Required Component**:
- `mcsToUltrafilter : {Γ : Set Formula // SetMaximalConsistent Γ} → Ultrafilter LindenbaumAlg`
- This constructs an ultrafilter from an MCS

**Construction of mcsToUltrafilter**:
Given MCS Γ, define:
```lean
def mcsToUltrafilter (Γ : {S // SetMaximalConsistent S}) : Ultrafilter LindenbaumAlg where
  carrier := mcsToSet Γ.val
  top_mem := mcsToSet_top Γ.property
  bot_not_mem := -- ⊥ = [⊥], need φ ∉ Γ where [φ] = ⊥
  mem_of_le := -- If a ∈ mcsToSet and a ≤ b, need b ∈ mcsToSet
  inf_mem := -- If a, b ∈ mcsToSet, need a ⊓ b ∈ mcsToSet
  compl_or := -- For all a, either a ∈ mcsToSet or aᶜ ∈ mcsToSet
  compl_not := -- If a ∈ mcsToSet then aᶜ ∉ mcsToSet
```

**Required Lemmas for mcsToUltrafilter**:
1. `mcsToSet_bot_not_mem`: ⊥ ∉ mcsToSet Γ (from MCS consistency)
2. `mcsToSet_mem_of_le`: a ∈ mcsToSet → a ≤ b → b ∈ mcsToSet (from deductive closure)
3. `mcsToSet_inf_mem`: a, b ∈ mcsToSet → a ⊓ b ∈ mcsToSet (from closure under conjunction)
4. `mcsToSet_compl_or`: a ∈ mcsToSet ∨ aᶜ ∈ mcsToSet (from negation completeness)
5. `mcsToSet_compl_not`: a ∈ mcsToSet → aᶜ ∉ mcsToSet (from consistency)

**Inverse Proofs**:
- `g(f(Γ)) = Γ`: Need `ultrafilterToSet (mcsToUltrafilter Γ) = Γ.val`
  - ultrafilterToSet = {φ | [φ] ∈ U}
  - mcsToUltrafilter Γ has carrier = {[φ] | φ ∈ Γ}
  - So ultrafilterToSet (mcsToUltrafilter Γ) = {φ | ∃ ψ ∈ Γ, [φ] = [ψ]} = Γ (by provable equivalence)

- `f(g(U)) = U`: Need `mcsToUltrafilter (ultrafilterToSet U) = U`
  - Need to show the carriers are equal
  - mcsToSet (ultrafilterToSet U) = {[φ] | φ ∈ ultrafilterToSet U} = {[φ] | [φ] ∈ U} = U.carrier

## Decisions

1. **Use MCS machinery for ultrafilter existence**: Rather than building ultrafilter existence from first principles, leverage `set_lindenbaum` and the MCS-ultrafilter correspondence
2. **Construct mcsToUltrafilter**: Requires proving 5 lemmas about `mcsToSet` preserving ultrafilter properties
3. **Bijection via set equality**: Prove carriers are equal using quotient properties

## Recommendations

### Phase 1: MCS-to-Ultrafilter Construction (Priority: High)

1. Prove helper lemmas for `mcsToSet`:
   - `mcsToSet_bot_not_mem`
   - `mcsToSet_mem_of_le`
   - `mcsToSet_inf_mem`
   - `mcsToSet_compl_or`
   - `mcsToSet_compl_not`

2. Define `mcsToUltrafilter` using these lemmas

### Phase 2: Bijection Proof (Priority: High)

1. Define `f := fun Γ => mcsToUltrafilter Γ`
2. Define `g := fun U => ⟨ultrafilterToSet U, ultrafilterToSet_mcs U⟩`
3. Prove `g(f(Γ)) = Γ` using quotient extensionality
4. Prove `f(g(U)) = U` using carrier equality (Set extensionality)

### Phase 3: Ultrafilter Existence (Priority: High)

1. Use the MCS-to-Ultrafilter bijection
2. For consistent φ:
   - {φ} is consistent (since ⊬ ¬φ)
   - By `set_lindenbaum`, extend to MCS Γ containing φ
   - Apply `mcsToUltrafilter` to get ultrafilter containing [φ]

### Phase 4: Complete `consistent_implies_satisfiable` (Priority: High)

Fill in the sorry using the ultrafilter existence result.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Quotient reasoning complexity | Medium | Use `Quotient.ind` and `Quotient.sound` systematically |
| MCS property proofs require derivation theory | Medium | Leverage existing `maximal_negation_complete`, `theorem_in_mcs` |
| Set equality proofs may be tedious | Low | Use `Set.ext` and membership reasoning |
| Dependencies on earlier phases | Low | Phases 1-5 of task 700 are complete |

## Appendix

### Search Queries Used

1. `lean_local_search "ultrafilter"` - Found custom Ultrafilter structure
2. `lean_local_search "Zorn"` - No local Zorn results
3. `lean_local_search "consistent_implies_satisfiable"` - Found existing sorry
4. `lean_local_search "mcs_ultrafilter"` - Found `mcs_ultrafilter_correspondence`
5. `lean_leansearch "for any non-bottom element of a Boolean algebra, there exists an ultrafilter containing it"`
6. `lean_loogle "BooleanAlgebra _ -> _ -> Ultrafilter"`
7. `lean_leanfinder "prime ideal ultrafilter Boolean algebra correspondence"`
8. `lean_leanfinder "Zorn's lemma maximal ideal existence Boolean algebra"`
9. `lean_leansearch "order ideal exists maximal proper ideal containing an element"`
10. `lean_leanfinder "principal filter generated by element non-bottom"`
11. `lean_leanfinder "ultrafilter exists containing element not bottom Boolean algebra"`
12. `lean_leansearch "bijection as pair of functions with left inverse and right inverse"`

### References

- Mathlib Filter.Ultrafilter.Defs
- Mathlib Order.Zorn
- Mathlib Order.PrimeIdeal
- Mathlib Logic.Function.Basic

## Next Steps

Proceed to `/plan 736` to create implementation plan based on these findings.
