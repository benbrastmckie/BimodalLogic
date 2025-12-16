# Mathlib Theorems for Modal Logic Infrastructure

## Metadata
- **Date**: 2025-12-09
- **Agent**: research-coordinator (direct execution mode)
- **Topic**: Mathlib Theorems
- **Report Type**: Mathlib analysis (Lean 4 theorem discovery)

## Executive Summary

Research into Mathlib theorem support for De Morgan laws, distribution patterns, and monotonicity lemmas reveals that while Mathlib provides extensive propositional logic theorems, modal logic infrastructure is project-specific. The ProofChecker project must implement De Morgan laws, conditional monotonicity, and S5 distribution patterns as custom theorems derived from existing Hilbert system axioms rather than importing from Mathlib.

## Findings

### Finding 1: De Morgan Laws Must Be Derived Within Hilbert System
- **Description**: Mathlib provides classical De Morgan laws for propositional logic, but these cannot be directly imported into ProofChecker's Hilbert-style proof system
- **Location**: Mathlib.Logic.Basic contains not_and_or, not_or, but requires adaptation
- **Evidence**: ProofChecker uses custom Formula inductive type (Logos/Core/Syntax/Formula.lean) with Derivable relation, incompatible with Mathlib's Prop-based theorems
- **Impact**: De Morgan laws must be proven from scratch using existing axioms (prop_k, prop_s, double_negation) and deduction_theorem infrastructure

### Finding 2: Modal Distribution Patterns Are Project-Specific
- **Description**: Modal logic distribution over conjunction/disjunction requires custom implementation using ProofChecker's box/diamond operators
- **Location**: No Mathlib equivalent - modal operators defined in Logos/Core/Syntax/Formula.lean:29-30 (box, all_past, all_future)
- **Evidence**: Existing proven theorem box_conj_iff (ModalS5.lean:342-428) demonstrates successful pattern
- **Impact**: Distribution infrastructure must follow box_conj_iff pattern: biconditional proof via iff_intro with forward/backward cases

### Finding 3: Conditional Monotonicity Requires Deduction Theorem Integration
- **Description**: Pattern ⊢ θ → (φ → ψ) ⇒ ⊢ θ → (◇φ → ◇ψ) requires combining existing diamond_mono with conditional context
- **Location**: Existing infrastructure at Logos/Core/Metalogic/DeductionTheorem.lean (proven) and ModalS5.lean (diamond_mono theorem)
- **Evidence**: deduction_theorem proven complete (Phase 1), enables conditional derivations
- **Impact**: Conditional monotonicity achievable by applying deduction_theorem to standard diamond_mono pattern

## Recommendations

1. **Implement De Morgan Laws in Propositional.lean**: Add demorgan_conj_neg and demorgan_disj_neg as derived theorems using prop_k, prop_s, double_negation, and deduction_theorem. Proof strategy: biconditional via iff_intro, forward direction uses negation distribution, backward uses double negation elimination.

2. **Create Conditional Monotonicity Helper Lemmas**: Add diamond_mono_conditional and box_mono_conditional to ModalS5.lean helper section. Implementation: Apply deduction_theorem to wrap existing mono theorems with conditional hypothesis.

3. **Follow box_conj_iff Pattern for Distribution**: Use ModalS5.lean:342-428 as template for diamond_disj_iff and s5_diamond_conj_diamond. Pattern: iff_intro splits into forward (uses lce_imp/rce_imp) and backward (uses pairing combinator) cases.

## References

- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Syntax/Formula.lean (lines 1-100: Formula type, box/diamond definitions)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean (lines 342-428: box_conj_iff successful pattern)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean (lines 1-400: complete deduction theorem infrastructure)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/058_hilbert_completion_plan/plans/001-hilbert-completion-plan.md (lines 250-289: Phase 4 blocker analysis)
