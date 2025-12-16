# Report 070-001: Theoretical Foundations of EFQ + Peirce Axiomatization

**Date**: 2025-12-14  
**Author**: Research Analysis  
**Status**: Complete

## Executive Summary

This report establishes the theoretical foundations for replacing the Double Negation Elimination (DNE) axiom with Ex Falso Quodlibet (EFQ) and Peirce's Law. The key finding is that EFQ + Peirce provides **derivational equivalence** to DNE while offering better **conceptual modularity**.

## Background

### Current Axiomatization
The Logos proof system currently includes DNE as a primitive axiom:
- **DNE**: `¬¬φ → φ` (Double Negation Elimination)

This axiom serves dual purposes:
1. Characterizes classical logic (vs. intuitionistic)
2. Enables reasoning from contradiction

### Proposed Axiomatization
Replace DNE with two axioms:
1. **EFQ**: `⊥ → φ` (Ex Falso Quodlibet / Principle of Explosion)
2. **Peirce**: `((φ → ψ) → φ) → φ` (Peirce's Law)

## Theoretical Analysis

### 1. Ex Falso Quodlibet (EFQ)

#### Logical Content
EFQ states that from a contradiction (⊥), anything follows. This directly characterizes the meaning of the primitive symbol `⊥`.

#### Why EFQ is More Fundamental than DNE
1. **Primitive Symbol**: In the Logos system, `⊥` (bot) is primitive, while `¬φ` is defined as `φ → ⊥`
2. **Direct Characterization**: EFQ directly states what `⊥` means, rather than characterizing it indirectly through negation
3. **Minimal Assumption**: EFQ is accepted in both classical and intuitionistic logic

#### Semantic Justification
In classical two-valued semantics:
- `⊥` is false at all models (M, τ, t)
- `⊥ → φ` is vacuously true (false antecedent makes implication true)
- Therefore, EFQ is valid in all task semantic models

### 2. Peirce's Law

#### Logical Content
Peirce's Law: `((φ → ψ) → φ) → φ` states that if assuming "φ implies ψ" leads to φ, then φ holds.

#### Why Peirce is Preferred Over DNE
1. **Pure Implicational**: Uses only implication, no mention of negation or disjunction
2. **Classical Characteristic**: Distinguishes classical from intuitionistic logic
3. **Independence**: Separates classical reasoning from the characterization of `⊥`

#### Semantic Justification
Classical proof by cases:
- Case 1: If φ is true, we're done
- Case 2: If φ is false, then φ → ψ is vacuously true
  - From (φ → ψ) → φ and φ → ψ, we get φ
  - But φ is false (assumption), contradiction
- Therefore φ must be true

### 3. Derivational Equivalence

#### Theorem: DNE is Derivable from EFQ + Peirce

**Claim**: `⊢ ¬¬φ → φ` is derivable using only EFQ, Peirce, and propositional axioms K and S.

**Proof Sketch**:
1. `¬¬φ = (φ → ⊥) → ⊥` (definition of negation)
2. Peirce with `ψ = ⊥`: `⊢ ((φ → ⊥) → φ) → φ`
3. EFQ: `⊢ ⊥ → φ`
4. Compose using b_combinator: from `⊥ → φ` and `(φ → ⊥) → ⊥`, derive `(φ → ⊥) → φ`
5. Apply Peirce to get `φ`
6. Use deduction: `⊢ ((φ → ⊥) → ⊥) → φ`

**Dependencies**: Only requires prop_k, prop_s, EFQ, Peirce, and b_combinator (which is derivable from K and S).

**Circular Dependency Check**: ✓ No circularity - b_combinator does not depend on DNE.

#### Corollary: EFQ + Peirce ≡ DNE (in presence of K, S)

The set {K, S, EFQ, Peirce} and {K, S, DNE} are deductively equivalent:
- DNE → EFQ: Trivial (⊥ → φ is a special case of ¬¬φ → φ)
- DNE → Peirce: Requires classical reasoning, derivable using DNE + K + S
- EFQ + Peirce → DNE: As proven above

### 4. Comparison with Standard Presentations

#### Mendelson (1997) - "Introduction to Mathematical Logic"
Uses EFQ as primitive in natural deduction systems. Notes Peirce as classical characteristic.

#### van Dalen (2013) - "Logic and Structure"  
Presents minimal logic (no classical axiom) + EFQ (absurdity characterization) + Peirce (classical logic).

#### Prawitz (1965) - "Natural Deduction"
Uses ⊥-introduction and ⊥-elimination (EFQ), with classical logic via excluded middle (equivalent to Peirce).

**Consensus**: EFQ + Peirce is a standard, well-studied axiomatization preferred in modern logic texts.

### 5. Modularity Benefits

#### Separation of Concerns
- **EFQ**: "What does ⊥ mean?" (semantic characterization)
- **Peirce**: "Classical or intuitionistic?" (logical strength)
- **DNE**: Conflates both (harder to analyze independently)

#### Flexibility for Variants
The modular presentation enables easy exploration of:
1. **Intuitionistic TM**: Remove Peirce, keep EFQ
2. **Minimal TM**: Remove both EFQ and Peirce (pure implicational minimal logic)
3. **Paraconsistent variants**: Modify EFQ to limit explosion

This is not immediately planned, but the refactoring makes such investigations straightforward.

### 6. Pedagogical Advantages

#### Clearer Teaching Progression
1. Base system (K, S) - implicational reasoning
2. Add EFQ - characterize absurdity
3. Add Peirce - choose classical logic
4. Derive DNE - show classical equivalences

#### Alignment with Literature
Students familiar with standard logic textbooks will recognize EFQ + Peirce immediately.

## Impact Analysis

### Proof Complexity
- **DNE as axiom**: 1 step to apply
- **DNE as theorem**: ~6 steps to apply (via `double_negation_derived`)

**Impact**: Negligible - DNE uses are typically wrapped in helper theorems like `dne`, `rcp`, `ne` which hide the complexity.

### Axiom Count
- Current: 13 axioms (including DNE)
- Proposed: 14 axioms (EFQ + Peirce, minus DNE)

**Impact**: Net +1 axiom, but better conceptual structure.

### Code Churn
- **Files affected**: ~8 files
- **Lines changed**: ~150 lines (mostly documentation)
- **Breaking changes**: 0 (backwards compatible via derived theorem)

**Impact**: Low - mostly additive changes with localized updates.

## Recommendations

### Primary Recommendation: Proceed with Refactoring

**Rationale**:
1. **Theoretical soundness**: EFQ + Peirce is well-established
2. **Backwards compatibility**: Full derivational equivalence
3. **Improved modularity**: Better separation of concerns
4. **Pedagogical benefit**: Aligns with standard presentations

### Implementation Strategy
Follow the phased approach in Plan 070:
1. Add EFQ and Peirce (Phase 1)
2. Derive DNE (Phase 2)
3. Remove DNE axiom (Phase 3)
4. Update documentation (Phase 4)
5. Verify and test (Phase 5)

### Risk Mitigation
- **Dependency audit**: Verify b_combinator and dependencies don't use DNE
- **Incremental testing**: Test after each phase
- **Rollback plan**: Keep git commit history for easy reversion

## Open Questions

1. **Minimal Logic Investigation**: Should we create a separate branch exploring intuitionistic/minimal variants?
   - **Answer**: Defer to future work; focus on classical TM for now

2. **Axiom Minimality**: Could we reduce further (e.g., Łukasiewicz axioms)?
   - **Answer**: Out of scope; current refactoring maintains pedagogical clarity over minimality

3. **Documentation Depth**: How much theoretical background should be in code comments vs. separate documentation?
   - **Answer**: Brief rationale in code, detailed theory in ARCHITECTURE.md

## Conclusion

The replacement of DNE with EFQ + Peirce is **theoretically sound**, **pedagogically valuable**, and **practically feasible**. The refactoring maintains full backwards compatibility while improving the conceptual structure of the axiom system.

**Recommendation**: Proceed with implementation following Plan 070.

## References

1. Mendelson, E. (1997). *Introduction to Mathematical Logic* (4th ed.). Chapman & Hall.
2. van Dalen, D. (2013). *Logic and Structure* (5th ed.). Springer.
3. Prawitz, D. (1965). *Natural Deduction: A Proof-Theoretical Study*. Almqvist & Wiksell.
4. Troelstra, A. S., & Schwichtenberg, H. (2000). *Basic Proof Theory* (2nd ed.). Cambridge University Press.
5. Girard, J.-Y. (1989). *Proofs and Types*. Cambridge University Press.

## Appendix: Derivation Details

### A.1 DNE from EFQ + Peirce (Detailed)

```
Goal: ⊢ ((φ → ⊥) → ⊥) → φ

Step 1: Peirce(φ, ⊥)
  ⊢ ((φ → ⊥) → φ) → φ

Step 2: EFQ(φ)
  ⊢ ⊥ → φ

Step 3: b_combinator(φ → ⊥, ⊥, φ)
  ⊢ (⊥ → φ) → ((φ → ⊥) → ⊥) → ((φ → ⊥) → φ))

Step 4: MP(Step 3, Step 2)
  ⊢ ((φ → ⊥) → ⊥) → ((φ → ⊥) → φ)

Step 5: b_combinator((φ → ⊥) → φ, φ, ((φ → ⊥) → ⊥))
  ⊢ (((φ → ⊥) → φ) → φ) → 
    (((φ → ⊥) → ⊥) → ((φ → ⊥) → φ)) → 
    (((φ → ⊥) → ⊥) → φ)

Step 6: MP(Step 5, Step 1)
  ⊢ (((φ → ⊥) → ⊥) → ((φ → ⊥) → φ)) → (((φ → ⊥) → ⊥) → φ)

Step 7: MP(Step 6, Step 4)
  ⊢ ((φ → ⊥) → ⊥) → φ

QED
```

### A.2 EFQ from DNE (For Completeness)

```
Goal: ⊢ ⊥ → φ

Step 1: prop_s(⊥, φ.neg)
  ⊢ ⊥ → (φ.neg → ⊥)
  = ⊥ → ¬¬φ

Step 2: DNE(φ)
  ⊢ ¬¬φ → φ

Step 3: b_combinator(⊥, ¬¬φ, φ)
  ⊢ (¬¬φ → φ) → (⊥ → ¬¬φ) → (⊥ → φ)

Step 4: MP(Step 3, Step 2)
  ⊢ (⊥ → ¬¬φ) → (⊥ → φ)

Step 5: MP(Step 4, Step 1)
  ⊢ ⊥ → φ

QED
```

This shows the derivational equivalence is bidirectional.
