# Research Report: Task #367

**Task**: Complete example proofs
**Date**: 2026-01-11
**Focus**: General research - sorry placeholders in Bimodal/Examples/

## Summary

Found 24 sorry placeholders across 4 files in Bimodal/Examples/. The sorries fall into distinct categories based on required proof techniques. Most can be completed using existing infrastructure (imp_trans, identity, contraposition, generalized_modal_k/temporal_k). Some require advanced techniques not yet available.

## Findings

### Sorry Distribution by File

| File | Count | Category |
|------|-------|----------|
| ModalProofStrategies.lean | 8 | Modal proof patterns |
| ModalProofs.lean | 7 | Basic modal reasoning |
| TemporalProofs.lean | 4 | Temporal axiom applications |
| TemporalProofStrategies.lean | 5 | Temporal proof patterns |

### Categorization by Difficulty

#### Category A: Trivial (Can be completed with identity/axioms)
**Count**: 3
**Examples**:
- `ModalProofs.lean:155-160` - `φ.box.imp φ.box` (identity)
- `TemporalProofs.lean:155-158` - `all_future.imp all_future` (identity)
- `TemporalProofs.lean:222-228` - Chaining T4 with imp_trans

**Technique**: Use `identity φ.box` or `imp_trans` with appropriate axioms

#### Category B: Medium (Requires generalized necessitation)
**Count**: 6
**Examples**:
- `ModalProofStrategies.lean:215-229` - Modal modus ponens from `□φ` and `□(φ → ψ)` to `□ψ`
- `ModalProofStrategies.lean:396-412` - Weakening under necessity `□φ → □(ψ → φ)`
- `ModalProofs.lean:174-179` - Using modal K rule `[p] ⊢ p.box`
- `TemporalProofs.lean:168-171` - Temporal K rule `[p] ⊢ p.all_future`
- `TemporalProofs.lean:181-183` - Future on atomic formula
- `TemporalProofStrategies.lean:332-344` - Temporal A iteration with temporal K

**Technique**: Use `generalized_modal_k` or `generalized_temporal_k` from `Bimodal.Theorems.GeneralizedNecessitation`

#### Category C: Advanced (Requires modal K axiom application)
**Count**: 4
**Examples**:
- `ModalProofStrategies.lean:159-176` - `□φ → ◇φ` (necessity implies possibility)
- `ModalProofs.lean:188-191` - `□p ∧ □(p → q) → □q` distribution
- `ModalProofStrategies.lean:421-427` - `□φ ∧ □ψ → □(φ ∧ ψ)` distribution
- `ModalProofStrategies.lean:237-243` - Curried modal modus ponens

**Technique**: Use `Axiom.modal_k_dist` with modus ponens and conjunction/disjunction rules

#### Category D: S5-Specific (Requires contraposition/negation reasoning)
**Count**: 6
**Examples**:
- `ModalProofStrategies.lean:282-288` - `◇□φ → φ` (characteristic S5)
- `ModalProofStrategies.lean:314-320` - `◇◇φ → ◇φ` (possibility idempotence)
- `ModalProofStrategies.lean:187-192` - `◇(φ ∨ ψ) → ◇φ ∨ ◇ψ` distribution
- `ModalProofs.lean:162-166` - `◇□φ → φ` (S5 characteristic)
- `ModalProofs.lean:194-196` - `◇(p ∧ q) → ◇p ∨ ◇q`
- `ModalProofs.lean:199-202` - `□φ → ¬¬◇φ` (duality)

**Technique**: Use `contraposition` from Perpetuity.Principles, `diamond_4`, `modal_5`, and double negation lemmas

#### Category E: Temporal-Specific (Requires perpetuity infrastructure)
**Count**: 5
**Examples**:
- `TemporalProofStrategies.lean:405-413` - `△φ → G△φ` (always implies future-always)
- `TemporalProofStrategies.lean:424-428` - `△φ → H△φ` (via duality)
- `TemporalProofStrategies.lean:479-489` - `GGφ → Gφ` (temporal transitivity)
- `TemporalProofStrategies.lean:534-541` - `H(Gφ) → G(Hφ)` (past-future composition)
- `ModalProofs.lean:148-152` - Modal modus ponens (duplicate of Category B)

**Technique**: Use `perpetuity_1` through `perpetuity_6`, `future_k_dist`, `past_k_dist` from Perpetuity module

### Available Infrastructure

The following helpers are available in the Bimodal.Theorems namespace:

**From Combinators.lean**:
- `imp_trans`: Chain implications `⊢ A → B` and `⊢ B → C` to `⊢ A → C`
- `identity`: `⊢ A → A` (SKK construction)
- `mp`: Modus ponens wrapper
- `b_combinator`: `⊢ (B → C) → (A → B) → (A → C)` (composition)
- `theorem_flip`: `⊢ (A → B → C) → (B → A → C)` (flip)
- `theorem_app1`: `⊢ A → (A → B) → B` (application)
- `pairing`: `⊢ A → B → A ∧ B` (conjunction introduction)
- `dni`: `⊢ A → ¬¬A` (double negation introduction)
- `combine_imp_conj`: Combine implications into conjunction

**From Perpetuity.Helpers**:
- `box_to_future`: `⊢ □φ → Gφ`
- `box_to_past`: `⊢ □φ → Hφ`
- `box_to_present`: `⊢ □φ → φ`
- `axiom_in_context`: Apply axiom in context
- `apply_axiom_to`: Apply axiom to derivation

**From Perpetuity.Principles**:
- `contraposition`: `⊢ A → B` gives `⊢ ¬B → ¬A`
- `diamond_4`: `⊢ ◇◇φ → ◇φ`
- `modal_5`: `⊢ ◇φ → □◇φ` (S5 characteristic)
- `perpetuity_1` through `perpetuity_6`: Core perpetuity principles
- `future_k_dist`: Future K distribution
- `past_k_dist`: Past K distribution
- `box_conj_intro_imp`: Box conjunction introduction under implication

**From GeneralizedNecessitation.lean**:
- `generalized_modal_k`: `Γ ⊢ φ` gives `□Γ ⊢ □φ`
- `generalized_temporal_k`: `Γ ⊢ φ` gives `GΓ ⊢ Gφ`
- `reverse_deduction`: `Γ ⊢ A → B` gives `A :: Γ ⊢ B`

### Missing Infrastructure

Some proofs require infrastructure not yet available:
1. **Disjunction rules**: For `◇(φ ∨ ψ) → ◇φ ∨ ◇ψ` patterns
2. **Classical reasoning**: Some S5 proofs need classical negation lemmas beyond what's proven
3. **Double negation elimination**: Available via `box_dne` but needs more general form

## Recommendations

### Priority Order for Implementation

1. **High Value, Low Effort (Complete First)**:
   - Category A trivial proofs (3 sorries)
   - Basic temporal chain examples
   - These demonstrate core proof techniques with minimal investment

2. **Medium Value, Medium Effort**:
   - Category B generalized necessitation proofs (6 sorries)
   - These are important pedagogical examples showing the modal K rule
   - Use existing `generalized_modal_k` and `generalized_temporal_k`

3. **High Value, Higher Effort**:
   - Category C modal distribution proofs (4 sorries)
   - Key patterns for practical modal reasoning
   - Requires careful application of K axiom

4. **Mark as Exercises**:
   - Category D S5-specific proofs (6 sorries)
   - Category E advanced temporal proofs (5 sorries)
   - These are more complex and serve as good exercises for users

### Suggested Approach

1. **Complete ~12 high-value sorries** (Categories A, B, and select C proofs)
2. **Mark ~12 remaining as explicit exercises** with hints
3. **Update documentation** to explain which examples are exercises

### Exercise Marking Pattern

For sorries marked as exercises, use this pattern:
```lean
example (φ : Formula) : ⊢ ... := by
  -- EXERCISE: Complete this proof using [technique hint]
  -- Hint: Start with [specific approach]
  sorry
```

## References

- `Bimodal/Theorems/Perpetuity.lean` - Main perpetuity principles (P1-P6)
- `Bimodal/Theorems/Combinators.lean` - Core propositional combinators
- `Bimodal/Theorems/GeneralizedNecessitation.lean` - Modal/temporal K rules
- `Bimodal/Metalogic/DeductionTheorem.lean` - Deduction theorem

## Next Steps

1. Create implementation plan with phased approach
2. Phase 1: Complete Category A (trivial) proofs
3. Phase 2: Complete Category B (generalized necessitation) proofs
4. Phase 3: Complete select Category C (modal distribution) proofs
5. Phase 4: Mark remaining as exercises with appropriate hints
6. Update example file documentation to reflect exercise status
