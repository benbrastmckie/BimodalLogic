# Project Structure Analysis for Modal Infrastructure

## Metadata
- **Date**: 2025-12-09
- **Agent**: research-coordinator (direct execution mode)
- **Topic**: Project Structure
- **Report Type**: Codebase analysis (module organization and dependencies)

## Executive Summary

Analysis of ProofChecker's modal theorem modules reveals a well-organized three-file structure (Propositional.lean, ModalS5.lean, ModalS4.lean) with clear separation of propositional, S5-specific, and S4-specific theorems. The three blocked theorems (diamond_disj_iff, s4_diamond_box_conj, s5_diamond_conj_diamond) can be completed in-place without new modules by adding De Morgan laws to Propositional.lean (40-60 lines each) and conditional monotonicity helpers to ModalS5.lean (60-80 lines). Existing import structure supports these additions without circular dependencies.

## Findings

### Finding 1: ModalS5.lean Structure Supports In-Place Completion
- **Description**: ModalS5.lean organized into helper section (lines 1-200) and main theorems (200+), with diamond_disj_iff at lines 439-461 ready for completion
- **Location**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean
- **Evidence**:
  - Helper section imports: Propositional, ProofSystem.Axioms, Metalogic.DeductionTheorem (lines 1-20)
  - Proven infrastructure: box_conj_iff (lines 342-428), s5_diamond_box (479-522) provide templates
  - diamond_disj_iff placeholder (lines 439-461) has proof strategy documented, ready for implementation
- **Impact**: No new module needed - add De Morgan laws to Propositional.lean, then complete diamond_disj_iff in-place using dual of box_conj_iff pattern

### Finding 2: Propositional.lean Optimal Location for De Morgan Laws
- **Description**: Propositional.lean contains all conjunction/disjunction infrastructure with clear phase-based organization
- **Location**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean:550-599
- **Evidence**:
  - lce_imp (lines 563-566) and rce_imp (581-584) recently proven using deduction_theorem
  - Phase 3 section (lines 586-599) designated for "Classical Reasoning" - ideal location for De Morgan
  - Existing negation theorems (double_negation, contrapose) provide foundation
- **Impact**: Add demorgan_conj_neg and demorgan_disj_neg to Phase 3 section (after line 618). Estimate: 80-120 lines per theorem using biconditional pattern.

### Finding 3: ModalS4.lean Requires Conditional Monotonicity Helper
- **Description**: s4_diamond_box_conj (lines 61-76) blocked on conditional diamond monotonicity pattern not present in codebase
- **Location**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS4.lean:61-76
- **Evidence**:
  - Blocker documented at lines 64-76: "conditional diamond monotonicity lemma: ⊢ θ → (φ → ψ) ⇒ ⊢ θ → (◇φ → ◇ψ)"
  - Current diamond_mono only provides unconditional form: ⊢ φ → ψ ⇒ ⊢ ◇φ → ◇ψ
  - Alternative approaches attempted and failed (lines 69-75)
- **Impact**: Add diamond_mono_conditional helper to ModalS5.lean (best location as it contains standard diamond_mono). Implementation via deduction_theorem wrapping. Estimated 60-80 lines.

### Finding 4: Dependency Chain Requires Sequenced Implementation
- **Description**: The three blocked theorems have clear dependency order requiring phased implementation
- **Location**: Cross-module dependencies analysis
- **Evidence**:
  - Phase 1: De Morgan laws in Propositional.lean (no dependencies, uses deduction_theorem already proven)
  - Phase 2: diamond_disj_iff in ModalS5.lean (depends on Phase 1 De Morgan laws)
  - Phase 3: diamond_mono_conditional helper in ModalS5.lean (no dependencies, uses deduction_theorem)
  - Phase 4a: s4_diamond_box_conj in ModalS4.lean (depends on Phase 3 helper)
  - Phase 4b: s5_diamond_conj_diamond in ModalS4.lean (depends on Phase 1 De Morgan + lce_imp/rce_imp)
- **Impact**: Sequential implementation required - cannot parallelize. Total estimated effort: 300-400 LOC across 5 sub-phases.

### Finding 5: No Circular Dependency Risks with Proposed Structure
- **Description**: Import structure analysis confirms safe addition of new theorems without circular dependencies
- **Location**: Import chains across Propositional.lean → ModalS5.lean → ModalS4.lean
- **Evidence**:
  - Propositional.lean imports: Syntax, ProofSystem, Metalogic (no theorem imports)
  - ModalS5.lean imports: Propositional (safe - one-way dependency)
  - ModalS4.lean imports: ModalS5, Propositional (safe - terminal node in dependency graph)
  - New additions respect existing hierarchy
- **Impact**: Safe to proceed with in-place additions. No refactoring or new modules required.

## Recommendations

1. **Add De Morgan Laws to Propositional.lean Phase 3 Section**: Insert demorgan_conj_neg and demorgan_disj_neg after classical_merge (line 618). Use biconditional pattern from box_conj_iff. Target: 160-240 lines total (80-120 per theorem). No new imports required - uses existing double_negation, prop_k, deduction_theorem.

2. **Create Conditional Monotonicity Helper in ModalS5.lean**: Add diamond_mono_conditional as helper theorem in early section (around line 200, after standard diamond_mono definition). Implementation: Wrap standard diamond_mono with deduction_theorem to enable conditional context. Target: 60-80 lines. Then export for use in ModalS4.lean.

3. **Complete diamond_disj_iff In-Place in ModalS5.lean**: Replace sorry at lines 439-461 using De Morgan laws from Recommendation 1. Follow box_conj_iff dual pattern (conjunction → disjunction, box → diamond). Target: 100-150 lines (similar complexity to box_conj_iff).

4. **Complete s4_diamond_box_conj and s5_diamond_conj_diamond in ModalS4.lean**: After completing Recommendations 2-3, replace sorry at lines 61-76 (s4_diamond_box_conj using conditional helper) and lines 230-245 (s5_diamond_conj_diamond using De Morgan + distribution). Target: 80-120 lines each.

5. **Follow Existing Module Organization Conventions**: Maintain phase-based structure in Propositional.lean (Phase 3 for classical reasoning), helper-then-main pattern in ModalS5.lean, and import hierarchy Propositional → ModalS5 → ModalS4. Document new theorems with standard docstrings including proof strategy and dependencies.

## References

- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean (lines 550-618: lce_imp, rce_imp, classical_merge, Phase 3 organization)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean (lines 1-20: imports; 342-428: box_conj_iff pattern; 439-461: diamond_disj_iff sorry)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS4.lean (lines 61-76: s4_diamond_box_conj sorry with blocker analysis; 230-245: s5_diamond_conj_diamond sorry)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean (lines 1-400: proven deduction_theorem infrastructure)
- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/058_hilbert_completion_plan/plans/001-hilbert-completion-plan.md (lines 225-304: Phase 4 analysis and status)
