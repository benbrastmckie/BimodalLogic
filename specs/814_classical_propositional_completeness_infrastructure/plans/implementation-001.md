# Implementation Plan: Task #814

- **Task**: 814 - Classical Propositional Completeness Infrastructure
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (all required lemmas already exist)
- **Research Inputs**: specs/814_classical_propositional_completeness_infrastructure/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task resolves 4 classical propositional sorries in the BMCS completeness infrastructure. Two sorries in TruthLemma.lean require deriving classical tautologies as DerivationTrees. Two sorries in Completeness.lean combine the deduction theorem with double negation elimination. The existing `double_negation` theorem in Propositional.lean and `deduction_theorem` in DeductionTheorem.lean provide all necessary infrastructure. The duplicate `double_negation_elim` at Completeness.lean:193 should be removed and replaced with an import.

### Research Integration

- Research identified all 4 sorry locations with exact line numbers and type signatures
- Confirmed `double_negation` exists at Propositional.lean:140 with signature `⊢ φ.neg.neg.imp φ`
- Confirmed `deduction_theorem` exists at DeductionTheorem.lean:335
- Boneyard proofs (`neg_imp_fst`/`neg_imp_snd`) operate at MCS level, not DerivationTree level, so must be reimplemented

## Goals & Non-Goals

**Goals**:
- Resolve 4 sorries in the BMCS completeness infrastructure
- Import existing `double_negation` theorem instead of duplicating it
- Remove the duplicate `double_negation_elim` definition
- Maintain clean build with no new warnings

**Non-Goals**:
- Refactoring other parts of the completeness proof
- Optimizing proof performance
- Adding new theorems beyond what's needed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Classical tautology proofs complex | M | M | Use existing proof patterns from Propositional.lean |
| Context reordering for 4th sorry | M | L | Use List.subset for `Γ ++ [φ.neg]` since order doesn't matter for weakening |
| Import cycles | H | L | Verify import graph before adding new imports |

## Implementation Phases

### Phase 1: TruthLemma.lean Sorries [NOT STARTED]

**Goal**: Resolve the two classical tautology sorries (`neg_imp_implies_antecedent` and `neg_imp_implies_neg_consequent`)

**Tasks**:
- [ ] Add import `Bimodal.Theorems.Propositional` to TruthLemma.lean
- [ ] Add import `Bimodal.Metalogic.Core.DeductionTheorem` to TruthLemma.lean
- [ ] Implement `neg_imp_implies_antecedent` (line 186): Prove `⊢ ¬(ψ → χ) → ψ`
  - Proof sketch: Use proof by contradiction with deduction theorem
  - From `[¬(ψ → χ), ¬ψ]`, derive `ψ → χ` (vacuously), then `⊥`
  - Apply deduction theorem to get `[¬(ψ → χ)] ⊢ ¬¬ψ`
  - Apply `double_negation` and modus ponens to get `[¬(ψ → χ)] ⊢ ψ`
  - Final deduction theorem: `⊢ ¬(ψ → χ) → ψ`
- [ ] Implement `neg_imp_implies_neg_consequent` (line 198): Prove `⊢ ¬(ψ → χ) → ¬χ`
  - Proof sketch: Simpler than above
  - From `[¬(ψ → χ), χ]`, derive `ψ → χ` via prop_s (`χ → (ψ → χ)`), then `⊥`
  - Apply deduction theorem to get `[¬(ψ → χ)] ⊢ ¬χ`
  - Final deduction theorem: `⊢ ¬(ψ → χ) → ¬χ`
- [ ] Run `lake build` to verify no errors

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Add imports, implement both proofs

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.TruthLemma` compiles without sorry warnings
- No new errors in dependent files

---

### Phase 2: Completeness.lean Sorries [NOT STARTED]

**Goal**: Resolve the two consistency lemma sorries and remove duplicate `double_negation_elim`

**Tasks**:
- [ ] Add import `Bimodal.Theorems.Propositional` to Completeness.lean
- [ ] Add import `Bimodal.Metalogic.Core.DeductionTheorem` to Completeness.lean (if not already present via TruthLemma)
- [ ] Remove duplicate `double_negation_elim` definition (lines 193-197) - it duplicates Propositional.double_negation
- [ ] Implement `not_derivable_implies_neg_consistent` (line 184):
  - Code already has `d_neg_neg : DerivationTree [] (φ.neg.neg)` from deduction theorem
  - Apply `Propositional.double_negation φ` to get `⊢ ¬¬φ → φ`
  - Apply modus ponens to get `⊢ φ`
  - Contradiction with `h_not_deriv`
- [ ] Implement `context_not_derivable_implies_extended_consistent` (line 323):
  - From `(Γ ++ [φ.neg]) ⊢ ⊥`, need to apply deduction theorem
  - Use weakening to reorder: `Γ ++ [φ.neg] ⊆ φ.neg :: Γ` isn't true, but we can show `φ.neg ∈ Γ ++ [φ.neg]`
  - Alternative: Work with `(Γ ++ [φ.neg])` directly using membership-based reasoning
  - Apply deduction theorem variant for non-head elements if available, or build derivation manually
  - Get `Γ ⊢ ¬¬φ`, then `Γ ⊢ φ` by double_negation + modus ponens
  - Contradiction with `h_not_deriv`
- [ ] Run `lake build` to verify no errors

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Add imports, remove duplicate, implement both proofs

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.Completeness` compiles without sorry warnings
- No regression in dependent modules
- Full `lake build` succeeds

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.TruthLemma` succeeds with no sorry warnings
- [ ] `lake build Bimodal.Metalogic.Bundle.Completeness` succeeds with no sorry warnings
- [ ] Full `lake build` succeeds with no new errors
- [ ] `grep -n "sorry" Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` returns 0 matches at lines 186, 198
- [ ] `grep -n "sorry" Theories/Bimodal/Metalogic/Bundle/Completeness.lean` returns 0 matches at lines 184, 197, 323

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - 2 sorries resolved
- Modified `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - 3 sorries resolved (including duplicate removal)
- `specs/814_classical_propositional_completeness_infrastructure/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

- Git revert to pre-implementation state if proofs become intractable
- If import cycles occur, consider moving `double_negation` to a shared Core module
- If context reordering is difficult for sorry #4, consider adding a helper lemma for context permutation
