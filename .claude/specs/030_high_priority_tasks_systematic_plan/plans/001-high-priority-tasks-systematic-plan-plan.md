# Lean Implementation Plan: High Priority Tasks Systematic Completion

## Metadata
- **Date**: 2025-12-03
- **Feature**: Systematic implementation of remaining High Priority Tasks from TODO.md
- **Status**: [NOT STARTED]
- **Estimated Hours**: 125-175 hours
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Research Reports**:
  - [Remaining Tasks Lean Research](../reports/001_remaining_tasks_lean_research.md)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/Completeness.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/Logos

## Overview

This plan systematically implements the remaining work identified in TODO.md after completion of all High Priority Tasks (1-5). The focus is on:

1. **Task 7 Enhancement** (15-25 hours): Batteries compatibility fix and Aesop integration for production-ready automation
2. **Task 9: Completeness Proofs** (70-90 hours): Canonical model construction and completeness theorems
3. **Task 10: Decidability Module** (40-60 hours): Tableau method and satisfiability decision procedures

**Key Context**: All High Priority Tasks (1-5) are COMPLETE as of 2025-12-03. The MVP for Layer 0 (Core TM) is functionally complete. This plan addresses enhancement and long-term completion goals.

## Success Criteria

- [ ] Batteries imported without breaking Truth.lean
- [ ] Aesop integration functional with TMLogic rule set
- [ ] All 11 completeness theorems proven (zero `axiom`, zero `sorry`)
- [ ] Decidability module created with tableau method
- [ ] Weak completeness: `⊨ φ → ⊢ φ` proven
- [ ] Strong completeness: `Γ ⊨ φ → Γ ⊢ φ` proven
- [ ] Complexity bounds documented for decidability
- [ ] Zero `#lint` warnings
- [ ] Build time < 2 minutes
- [ ] Test coverage ≥85% overall

---

## Phase 1: Batteries Compatibility Fix [NOT STARTED]
dependencies: []

**Objective**: Resolve Batteries dependency conflict with Truth.lean to enable Aesop integration

**Complexity**: Medium

**Theorems**: N/A (refactoring task)

**Implementation Tasks**:
- [ ] Analyze Truth.lean type errors when Batteries imported
  - Strategy: Import Batteries in isolated test file, reproduce errors, identify conflicting definitions
  - Complexity: Simple (diagnostic task)
  - Estimated: 1 hour

- [ ] Identify conflicting definitions (likely `List` or `Option` extensions)
  - Strategy: Use `#check` on conflicting types, compare Batteries vs Lean.Core, trace import chains
  - Complexity: Medium (requires understanding import resolution)
  - Estimated: 2-3 hours

- [ ] Refactor Truth.lean to avoid conflicts
  - Strategy: Use qualified imports (`open Batteries hiding ...`) or rename local definitions
  - Complexity: Medium (may require extensive changes)
  - Prerequisites: Conflict identification complete
  - Estimated: 3-5 hours

- [ ] Verify build with Batteries imported
  - Strategy: Run `lake build`, check zero type errors, verify existing tests pass
  - Complexity: Simple (verification task)
  - Prerequisites: Refactoring complete
  - Estimated: 0.5 hour

**Testing**:
```bash
# Verify Batteries import works
cd /home/benjamin/Documents/Philosophy/Projects/Logos
lake build

# Verify no regressions in Truth.lean
lake test LogosTest.Semantics.TruthTest

# Check no new type errors
grep -c "error:" $(lake build 2>&1)
```

**Expected Duration**: 6-9 hours

---

## Phase 2: Aesop Integration [NOT STARTED]
dependencies: [1]

**Objective**: Integrate Aesop proof search with custom TMLogic rule set for automated TM reasoning

**Complexity**: Medium

**Theorems**: N/A (integration task, but includes theorem wrappers)

**Implementation Tasks**:
- [ ] Create TMLogic rule set declaration
  - Strategy: Add `declare_aesop_rule_sets [TMLogic]` to Tactics.lean
  - Complexity: Simple (single declaration)
  - Estimated: 0.25 hour

- [ ] Mark TM axioms as safe rules (10 axioms)
  - Goal: Wrap each axiom in theorem with `@[aesop safe [TMLogic]]` attribute
  - Strategy: Create wrapper theorems for MT, M4, MB, T4, TA, TL, MF, TF, prop_k, prop_s
  - Complexity: Simple (repetitive pattern)
  - Estimated: 2-3 hours

- [ ] Replace `tm_auto` macro with Aesop version
  - Strategy: Replace native `first` combinator with `macro "tm_auto" : tactic => `(tactic| aesop (rule_sets [TMLogic]))`
  - Complexity: Simple (macro replacement)
  - Prerequisites: TMLogic rule set populated
  - Estimated: 0.5 hour

- [ ] Expand TacticsTest.lean with Aesop-specific tests (10+ tests)
  - Strategy: Add tests for complex derivations, negative tests for expected failures, performance benchmarks
  - Complexity: Medium (requires diverse test cases)
  - Prerequisites: Aesop tm_auto functional
  - Estimated: 3-4 hours

**Testing**:
```bash
# Verify Aesop integration
lake build Logos.Automation.Tactics

# Test tm_auto with Aesop backend
lake test LogosTest.Automation.TacticsTest

# Verify rule set includes all axioms
grep -c "@\[aesop safe \[TMLogic\]\]" Logos/Automation/Tactics.lean
```

**Expected Duration**: 6-8 hours

---

## Phase 3: Maximal Consistent Sets [NOT STARTED]
dependencies: []

**Objective**: Prove Lindenbaum's lemma and establish properties of maximal consistent sets

**Complexity**: High

**Theorems**:
- [ ] `lindenbaum`: Every consistent set extends to maximal consistent set
  - Goal: `∀ Γ, Consistent Γ → ∃ Δ, (∀ φ, φ ∈ Γ → φ ∈ Δ) ∧ MaximalConsistent Δ`
  - Strategy: Apply `Zorn.chain_Sup` from `Mathlib.Order.Zorn`, construct chain of consistent extensions, prove upper bound exists
  - Complexity: Complex (Zorn's lemma application)
  - Estimated: 10-15 hours

- [ ] `maximal_consistent_closed`: Maximal sets deductively closed
  - Goal: `MaximalConsistent Γ → Derivable Γ φ → φ ∈ Γ`
  - Strategy: Proof by contradiction using maximality, requires deduction theorem as helper lemma
  - Complexity: Medium (uses maximality property)
  - Prerequisites: `lindenbaum`
  - Estimated: 5-7 hours

- [ ] `maximal_negation_complete`: Maximal sets negation complete
  - Goal: `MaximalConsistent Γ → (φ ∉ Γ → ¬φ ∈ Γ)`
  - Strategy: Use maximality to show `φ :: Γ ⊢ ⊥`, derive `Γ ⊢ ¬φ`, apply deductive closure
  - Complexity: Medium (uses deductive closure)
  - Prerequisites: `maximal_consistent_closed`
  - Estimated: 5-7 hours

**Testing**:
```bash
# Verify completeness theorems
lake build Logos.Metalogic.Completeness

# Check no sorry markers in maximal set proofs
grep -A5 "lindenbaum\|maximal_consistent_closed\|maximal_negation_complete" Logos/Metalogic/Completeness.lean | grep -c "sorry"

# Verify Mathlib imports work
lake build | grep -i "Mathlib.Order.Zorn"
```

**Expected Duration**: 20-30 hours

---

## Phase 4: Canonical Frame Construction [NOT STARTED]
dependencies: [3]

**Objective**: Construct canonical frame from maximal consistent sets and prove frame properties

**Complexity**: High

**Theorems**:
- [ ] `canonical_task_rel`: Define task relation from derivability
  - Goal: `MaximalSet → TaskSet → MaximalSet → Prop` (relation from modal/temporal derivability)
  - Strategy: Define `R w T u := ∀ φ, □φ ∈ w → φ ∈ u` for modal reachability, extend for temporal
  - Complexity: Medium (definition + well-definedness proof)
  - Estimated: 8-10 hours

- [ ] `canonical_frame`: Prove frame satisfies nullity and compositionality
  - Goal: `TaskFrame` instance for canonical frame with proven properties
  - Strategy: Prove `canonical_task_rel w ∅ w` (nullity), prove `canonical_task_rel w T₁ u ∧ canonical_task_rel u T₂ v → canonical_task_rel w (T₁ ∪ T₂) v` (compositionality)
  - Complexity: Medium (structural property verification)
  - Prerequisites: `canonical_task_rel`
  - Estimated: 10-12 hours

- [ ] `canonical_valuation`: Define valuation from maximal sets
  - Goal: `MaximalSet → String → Prop` mapping atomic formulas to truth values
  - Strategy: Define `canonical_valuation w p := Formula.atom p ∈ w.to_context`
  - Complexity: Simple (straightforward definition)
  - Estimated: 2-3 hours

- [ ] `canonical_model`: Construct model from frame and valuation
  - Goal: `TaskModel` instance combining canonical frame and valuation
  - Strategy: Combine `canonical_frame` and `canonical_valuation` into `TaskModel` structure
  - Complexity: Simple (structural combination)
  - Prerequisites: `canonical_frame`, `canonical_valuation`
  - Estimated: 2-3 hours

**Testing**:
```bash
# Verify frame construction
lake build Logos.Metalogic.Completeness

# Test canonical frame properties
lake test LogosTest.Metalogic.CompletenessTest

# Verify no axiom declarations remain in frame section
grep -A10 "canonical_task_rel\|canonical_frame" Logos/Metalogic/Completeness.lean | grep -c "^axiom"
```

**Expected Duration**: 22-28 hours

---

## Phase 5: Truth Lemma and Completeness [NOT STARTED]
dependencies: [4]

**Objective**: Prove truth lemma by induction and derive completeness theorems

**Complexity**: Very High

**Theorems**:
- [ ] `canonical_history`: Define history from maximal sets for temporal operators
  - Goal: `MaximalSet → ConvexTimeSet → WorldState` (temporal history function)
  - Strategy: Map time points to world states via temporal derivability chains, prove `respects_task`
  - Complexity: Complex (requires temporal consistency)
  - Estimated: 8-10 hours

- [ ] `truth_lemma`: Truth preservation in canonical model
  - Goal: `∀ φ Γ, MaximalConsistent Γ → (φ ∈ Γ ↔ truth_at canonical_model (canonical_history Γ) 0 φ)`
  - Strategy: Induction on formula structure - atom (2h), bot (1h), imp (6h), box (6h), past (5h), future (5h)
  - Complexity: Very Complex (mutual induction with multiple cases)
  - Prerequisites: `canonical_model`, `canonical_history`
  - Estimated: 15-20 hours

- [ ] `weak_completeness`: Valid implies provable
  - Goal: `∀ φ, (∀ M τ t, truth_at M τ t φ) → Derivable [] φ`
  - Strategy: Contrapositive - if `¬(⊢ φ)` then `¬φ` consistent, extend to maximal, use truth lemma to find countermodel
  - Complexity: Medium (uses truth lemma)
  - Prerequisites: `truth_lemma`
  - Estimated: 5-7 hours

- [ ] `strong_completeness`: Semantic consequence implies syntactic
  - Goal: `∀ Γ φ, (∀ M τ t, (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ) → Derivable Γ φ`
  - Strategy: Reduce to weak completeness via deduction theorem or direct maximal set construction
  - Complexity: Medium (reduction argument)
  - Prerequisites: `weak_completeness`
  - Estimated: 5-7 hours

**Testing**:
```bash
# Verify truth lemma and completeness
lake build Logos.Metalogic.Completeness

# Verify no axiom declarations in completeness section
grep -c "^axiom" Logos/Metalogic/Completeness.lean

# Run completeness property tests
lake test LogosTest.Metalogic.CompletenessTest

# Verify all 11 theorems proven
grep -E "theorem (lindenbaum|maximal|canonical|truth_lemma|weak_completeness|strong_completeness)" Logos/Metalogic/Completeness.lean | wc -l
```

**Expected Duration**: 33-44 hours

---

## Phase 6: Decidability Module Creation [NOT STARTED]
dependencies: [5]

**Objective**: Create decidability module with tableau method and complexity analysis

**Complexity**: High

**Theorems**:
- [ ] `formula_complexity`: Define complexity measure for termination
  - Goal: `Formula → Nat` (measure decreasing on subformulas)
  - Strategy: Recursive definition - `atom/bot: 1`, `imp: 1 + c(φ) + c(ψ)`, `box/past/future: 1 + c(φ)`
  - Complexity: Simple (structural recursion)
  - Estimated: 1-2 hours

- [ ] `complexity_decreases_subformulas`: Well-foundedness of subformula relation
  - Goal: `∀ φ ψ, ψ ∈ subformulas φ → formula_complexity ψ < formula_complexity φ`
  - Strategy: Induction on formula structure, use `omega` tactic for arithmetic
  - Complexity: Simple (straightforward induction)
  - Prerequisites: `formula_complexity`
  - Estimated: 2-3 hours

- [ ] `tableau_search`: Bounded depth-first tableau search
  - Goal: `Formula → Nat → Option Bool` (returns satisfiability result)
  - Strategy: Pattern match on formula, apply closure rules, recurse with decreasing depth
  - Complexity: Complex (requires termination proof)
  - Prerequisites: `formula_complexity`, `complexity_decreases_subformulas`
  - Estimated: 15-20 hours

- [ ] `tableau_soundness`: Closed tableau implies unsatisfiable
  - Goal: `∀ φ, tableau_search φ depth = some false → ¬(∃ M τ t, truth_at M τ t φ)`
  - Strategy: Induction on tableau construction, use completeness for countermodel existence
  - Complexity: Complex (requires completeness)
  - Prerequisites: `tableau_search`, `strong_completeness`
  - Estimated: 10-15 hours

- [ ] `tableau_completeness`: Unsatisfiable implies closed tableau
  - Goal: `∀ φ, (¬∃ M τ t, truth_at M τ t φ) → ∃ depth, tableau_search φ depth = some false`
  - Strategy: Use completeness to show non-derivability implies satisfiability, contrapositive for tableau closure
  - Complexity: Complex (uses completeness)
  - Prerequisites: `tableau_search`, `strong_completeness`
  - Estimated: 10-15 hours

- [ ] `decidability_theorem`: Decidability of TM validity
  - Goal: `∀ φ, Decidable (∀ M τ t, truth_at M τ t φ)`
  - Strategy: Combine `tableau_soundness` and `tableau_completeness` into decision procedure
  - Complexity: Medium (combination of previous results)
  - Prerequisites: `tableau_soundness`, `tableau_completeness`
  - Estimated: 3-5 hours

**Testing**:
```bash
# Verify decidability module exists
lake build Logos.Metalogic.Decidability

# Test tableau on example formulas
lake test LogosTest.Metalogic.DecidabilityTest

# Verify complexity analysis documented
grep -c "EXPTIME\|PSPACE" Logos/Metalogic/Decidability.lean

# Check no axiom declarations
grep -c "^axiom" Logos/Metalogic/Decidability.lean
```

**Expected Duration**: 41-60 hours

---

## Phase 7: Documentation and Testing [NOT STARTED]
dependencies: [2, 5, 6]

**Objective**: Update documentation, expand test coverage, and verify quality metrics

**Complexity**: Low

**Implementation Tasks**:
- [ ] Update IMPLEMENTATION_STATUS.md
  - Strategy: Mark Completeness and Decidability modules as COMPLETE, update sorry counts to zero
  - Complexity: Simple (documentation update)
  - Estimated: 1 hour

- [ ] Update KNOWN_LIMITATIONS.md
  - Strategy: Remove completeness/decidability limitations, document any remaining gaps
  - Complexity: Simple (documentation update)
  - Estimated: 1 hour

- [ ] Expand TacticsTest.lean to 50+ tests
  - Strategy: Add 19 more tests for edge cases, performance benchmarks, negative tests
  - Complexity: Medium (creative test design)
  - Estimated: 4-6 hours

- [ ] Create CompletenessTest.lean with property tests
  - Strategy: Test maximal set properties, canonical model construction, truth lemma on examples
  - Complexity: Medium (metalogic testing)
  - Estimated: 3-5 hours

- [ ] Create DecidabilityTest.lean with tableau tests
  - Strategy: Test tableau on satisfiable/unsatisfiable formulas, verify termination, benchmark complexity
  - Complexity: Medium (decidability testing)
  - Estimated: 3-5 hours

- [ ] Verify zero `#lint` warnings
  - Strategy: Run `lake lint`, fix any warnings in new modules
  - Complexity: Simple (lint compliance)
  - Estimated: 1-2 hours

- [ ] Run full test suite and verify ≥85% coverage
  - Strategy: Run `lake test`, analyze coverage, add tests for uncovered paths
  - Complexity: Medium (may require additional tests)
  - Estimated: 2-3 hours

**Testing**:
```bash
# Verify documentation updated
git diff Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
git diff Documentation/ProjectInfo/KNOWN_LIMITATIONS.md

# Run full test suite
lake test

# Verify lint compliance
lake lint

# Check test counts
grep -c "^def test_" LogosTest/Automation/TacticsTest.lean
grep -c "^def test_" LogosTest/Metalogic/CompletenessTest.lean
grep -c "^def test_" LogosTest/Metalogic/DecidabilityTest.lean
```

**Expected Duration**: 15-23 hours

---

## Dependency Graph

**Wave 1** (Parallel, 12-17 hours):
- Phase 1: Batteries Compatibility Fix (6-9h)
- Phase 3: Maximal Consistent Sets (20-30h) - independent of Batteries

**Wave 2** (After Wave 1, 6-8 hours):
- Phase 2: Aesop Integration (6-8h) - requires Phase 1

**Wave 3** (After Phase 3, 55-72 hours):
- Phase 4: Canonical Frame Construction (22-28h) - requires Phase 3
- Phase 5: Truth Lemma and Completeness (33-44h) - requires Phase 4

**Wave 4** (After Phase 5, 41-60 hours):
- Phase 6: Decidability Module (41-60h) - requires Phase 5 (completeness)

**Wave 5** (After Phases 2, 5, 6, 15-23 hours):
- Phase 7: Documentation and Testing (15-23h) - requires all previous phases

**Total Sequential Time**: 125-175 hours
**Critical Path**: Phase 1 → Phase 2 (12-17h), Phase 3 → Phase 4 → Phase 5 → Phase 6 (116-162h)
**Parallel Opportunities**: Phase 1 and Phase 3 can run in parallel

---

## Risk Assessment

### High Risk: Zorn's Lemma Application
- **Problem**: Applying Zorn's lemma in Lean 4 requires careful chain construction
- **Mitigation**: Study Mathlib examples, use `Zorn.chain_Sup`, construct chain explicitly
- **Estimated Impact**: Built into 20-30 hour estimate for Phase 3

### Medium Risk: Truth Lemma Complexity
- **Problem**: Implication case requires deduction theorem for TM logic
- **Mitigation**: Prove deduction theorem as separate helper, build library of propositional lemmas
- **Estimated Impact**: Built into 33-44 hour estimate for Phase 5

### Medium Risk: Decidability Complexity Analysis
- **Problem**: Proving optimal complexity bounds for bimodal logic (S5 + LTL) may be difficult
- **Mitigation**: Prove soundness/completeness first (decidability guaranteed), accept conservative bounds
- **Estimated Impact**: May defer formal complexity proof, document informally (5-10h savings)

### Low Risk: Test Coverage for Completeness
- **Problem**: Testing existential proofs (maximal sets exist) is challenging
- **Mitigation**: Use property-based tests, focus on helper lemmas, test on specific examples
- **Estimated Impact**: 3-5 hours for creative test design (Phase 7)

---

## Notes

**Context from Research**:
- All High Priority Tasks (1-5) are COMPLETE as of 2025-12-03
- MVP for Layer 0 (Core TM) is functionally complete
- Remaining work is enhancement (Task 7) and long-term completion (Tasks 9-10)

**Completion Signals**:
- Phase 2 complete → Production-ready automation with Aesop
- Phase 5 complete → Full metalogic for Layer 0 (soundness + completeness)
- Phase 6 complete → Decidability and complexity analysis
- All phases complete → Layer 0 100% complete, ready for Layer 1 planning

**Standards Compliance**:
- Zero `#lint` warnings required (enforced in Phase 7)
- 100% docstring coverage for public definitions (ongoing)
- Build time < 2 minutes (monitored throughout)
- Test coverage ≥85% overall (verified in Phase 7)

**Documentation Updates**:
- IMPLEMENTATION_STATUS.md updated in Phase 7
- KNOWN_LIMITATIONS.md updated in Phase 7
- TODO.md updated as phases complete
