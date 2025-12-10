# Proof Strategies for Modal Infrastructure Theorems

## Metadata
- **Date**: 2025-12-09
- **Agent**: research-coordinator (direct execution mode)
- **Topic**: Proof Strategies
- **Report Type**: Proof pattern analysis (tactic sequence design)

## Executive Summary

Analysis of existing proven theorems reveals three key proof strategies for completing blocked modal theorems: (1) biconditional proof via iff_intro with forward/backward cases using lce_imp/rce_imp and box_mono patterns (box_conj_iff template), (2) conditional monotonicity achieved by wrapping standard mono theorems with deduction_theorem, and (3) S5 distribution using modal_5_collapse with double contraposition. All strategies leverage existing proven infrastructure without requiring new axioms.

## Findings

### Finding 1: Biconditional Proof Pattern from box_conj_iff (Lines 342-428)
- **Description**: Successful biconditional proof splits into forward and backward cases, each using different combinator strategies
- **Location**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean:342-428
- **Evidence**:
  - Backward direction (lines 351-409): Uses pairing combinator + box_mono + modal_k_dist + b_combinator composition
  - Forward direction (lines 412-424): Uses lce_imp/rce_imp + box_mono + combine_imp_conj
  - Final combination (line 427): Applies iff_intro to join both directions
- **Impact**: This pattern directly applies to diamond_disj_iff - replace box with diamond (dual), conjunction with disjunction (dual), same combinator sequence

### Finding 2: Conditional Monotonicity via Deduction Theorem Wrapping
- **Description**: Pattern ⊢ θ → (φ → ψ) ⇒ ⊢ θ → (◇φ → ◇ψ) achievable by applying deduction_theorem to standard diamond_mono
- **Location**: Existing infrastructure at /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean (proven), ModalS5.lean (diamond_mono)
- **Evidence**:
  - Standard diamond_mono: If ⊢ φ → ψ then ⊢ ◇φ → ◇ψ
  - Conditional form needed: If ⊢ θ → (φ → ψ) then ⊢ θ → (◇φ → ◇ψ)
  - Strategy: Apply deduction_theorem to derivation [θ] ⊢ φ → ψ, then apply diamond_mono, wrap result
- **Impact**: Enables s4_diamond_box_conj proof by allowing diamond_mono under conditional hypothesis θ = A.diamond

### Finding 3: S5 Distribution Uses modal_5_collapse with Double Contraposition
- **Description**: Nested modality distribution requires modal_5_collapse axiom (◇□A → □A) combined with contraposition and double negation
- **Location**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean (modal_5_collapse), Propositional.lean (contrapose patterns)
- **Evidence**:
  - modal_5_collapse proven sound in Phase 3 (lines 186-222 of prior plan)
  - s5_diamond_box already proven using this pattern (ModalS5.lean:479-522)
  - Distribution over conjunction with nested diamond follows same collapse strategy
- **Impact**: s5_diamond_conj_diamond proof decomposes: (1) apply lce_imp/rce_imp to extract conjuncts, (2) apply modal_5_collapse to collapse nested diamond-box, (3) recombine with pairing

### Finding 4: De Morgan Laws Require prop_k + double_negation Composition
- **Description**: De Morgan laws (¬(A ∧ B) ↔ (¬A ∨ ¬B)) provable from existing axioms without new infrastructure
- **Location**: Existing axioms in /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean
- **Evidence**:
  - Forward direction: Use prop_k distribution with negation: ¬(A ∧ B) via (A → B → ⊥) equivalence
  - Backward direction: Use double_negation elimination + contraposition
  - Biconditional: Combine with iff_intro (same pattern as box_conj_iff)
- **Impact**: De Morgan laws enable diamond_disj_iff completion via modal duality transformation

## Recommendations

1. **Implement De Morgan Laws Using prop_k + Contraposition Pattern**: Add demorgan_conj_neg and demorgan_disj_neg to Propositional.lean following box_conj_iff structure (iff_intro with forward/backward cases). Forward: distribute negation via prop_k composition. Backward: use double_negation + contrapose combinator. Target LOC: 80-120 lines per theorem.

2. **Create diamond_mono_conditional Helper Lemma**: Add to ModalS5.lean helper section. Implementation: Start with [θ] ⊢ φ → ψ, apply standard diamond_mono, then wrap with deduction_theorem to yield ⊢ θ → (◇φ → ◇ψ). Use for s4_diamond_box_conj with θ = A.diamond. Target LOC: 40-60 lines.

3. **Follow s5_diamond_box Pattern for Nested Distribution**: For s5_diamond_conj_diamond, decompose proof into: (1) extract A.diamond and B.diamond from conjunction using lce_imp/rce_imp, (2) apply modal_5_collapse to inner box (if present), (3) distribute over conjunction, (4) recombine using combine_imp_conj. Target LOC: 100-150 lines.

4. **Use combine_imp_conj for Biconditional Backward Cases**: The combine_imp_conj helper (used in box_conj_iff:424) efficiently builds P → (Q ∧ R) from P → Q and P → R. Reuse this pattern in diamond_disj_iff and s5_diamond_conj_diamond backward directions. Reduces proof complexity significantly.

## References

- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean (lines 342-428: box_conj_iff complete proof pattern)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean (lines 479-522: s5_diamond_box using modal_5_collapse)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean (lines 1-400: deduction theorem infrastructure)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean (lines 562-579: lce_imp, rce_imp proven)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean (lines 50-80: modal_5_collapse axiom)
