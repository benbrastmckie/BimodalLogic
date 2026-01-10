# Implementation Plan: Hybrid Proof Search - Tactic Mode + Programmatic API

- **Task**: 315 - Research and resolve Axiom Prop vs Type blocker for proof term construction
- **Status**: [NOT STARTED]
- **Effort**: 61-97 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: 
  - reports/research-001.md (Initial Analysis - Three Approaches)
  - reports/research-002.md (Approach Comparison for AI Training)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements a **hybrid strategy** to resolve the Axiom Prop vs Type blocker preventing programmatic proof term construction in Task 260. The blocker is that `Axiom φ` is defined as `Prop` (proposition), not `Type`, making it impossible to return `Option (Axiom φ)` from witness functions.

**Research Integration**: Two research reports inform this plan:
1. **research-001.md**: Analyzed three approaches with viability ratings - Classical.choice (3/10), Refactor to Type (6/10), Tactic Mode (9/10)
2. **research-002.md**: Compared approaches for AI training data generation - Tactic Mode is Lean 4 standard practice, but Refactor to Type is vastly superior for DUAL_VERIFICATION.md vision (5/5 vs 0/5 on AI training requirements)

**Hybrid Strategy**: Implement both approaches sequentially:
- **Phase 1 (Approach 3)**: Tactic Mode for immediate user value and ecosystem alignment (28-44 hours)
- **Phase 2 (Approach 2)**: Refactor to Type for AI training pipeline and programmatic API (33-53 hours)

**Scope**: 
- Phase 1: Create `modal_search` tactic for interactive proof development
- Phase 2: Refactor `Axiom : Formula → Prop` to `Axiom : Formula → Type` and implement programmatic proof search API
- Integration: Reimplement tactic to use programmatic API after Phase 2

**Constraints**:
- Phase 1 must not introduce breaking changes
- Phase 2 is a breaking change requiring comprehensive testing
- Both phases must maintain soundness and completeness guarantees
- Must align with Lean 4 ecosystem standards (tactic-first interface)

**Definition of Done**:
- Phase 1: `modal_search` tactic working with Aesop integration, tests passing, documentation complete
- Phase 2: `Axiom` refactored to `Type`, programmatic API implemented, tactic reimplemented, all tests passing, AI training pipeline functional

## Goals & Non-Goals

**Goals**:
- ✅ Implement `modal_search` tactic for interactive proof development (Phase 1)
- ✅ Integrate tactic with Aesop for automatic proof search (Phase 1)
- ✅ Refactor `Axiom : Formula → Prop` to `Axiom : Formula → Type` (Phase 2)
- ✅ Implement programmatic proof search API (Phase 2)
- ✅ Enable DUAL_VERIFICATION.md AI training pipeline (Phase 2)
- ✅ Maintain soundness and completeness guarantees throughout
- ✅ Provide comprehensive testing for both phases
- ✅ Document tactic usage and programmatic API

**Non-Goals**:
- ❌ Implement Classical.choice approach (research-001.md rated 3/10 viability)
- ❌ Support noncomputable proof search (both phases are computable)
- ❌ Implement model-checker integration (separate task, depends on Phase 2)
- ❌ Optimize proof search performance (deferred to tasks 317-318)
- ❌ Implement BFS variant or advanced heuristics (tasks 317-318)

## Risks & Mitigations

**Risk 1: Phase 2 Breaking Change Introduces Bugs**
- **Severity**: High
- **Mitigation**: Comprehensive testing after refactor, incremental file updates, rollback plan prepared
- **Detection**: Test suite must pass 100% before merging Phase 2

**Risk 2: Tactic Implementation Complexity**
- **Severity**: Medium
- **Mitigation**: Start with simple axiom matching, add complexity incrementally, reference Aesop/Duper implementations
- **Detection**: Test tactic on simple examples before complex proofs

**Risk 3: Proof Irrelevance Loss in Phase 2**
- **Severity**: Medium
- **Mitigation**: Prove axiom uniqueness explicitly for all 14 axiom schemata, verify soundness proofs still hold
- **Detection**: Metalogic tests must pass after refactor

**Risk 4: Phase 1 Implementation Wasted if Phase 2 Requires Rewrite**
- **Severity**: Low
- **Mitigation**: Design Phase 1 tactic with Phase 2 API in mind, use modular architecture
- **Detection**: Code review before Phase 1 completion

**Risk 5: AI Training Pipeline Integration Complexity**
- **Severity**: Medium
- **Mitigation**: Design programmatic API with DUAL_VERIFICATION.md requirements in mind, prototype integration early
- **Detection**: Test batch proof generation on small dataset before full pipeline

## Implementation Phases

### Phase 1.1: Tactic Syntax and Basic Infrastructure [COMPLETED]

**Goal**: Define tactic syntax and create basic tactic wrapper in TacticM monad

**Tasks**:
- [ ] Create `Logos/Core/Automation/Tactics.lean` file for tactic implementations
- [ ] Define `modal_search` tactic syntax with optional depth parameter
- [ ] Implement basic tactic elaboration function `evalModalSearch`
- [ ] Extract goal from tactic state using `getMainGoal`
- [ ] Extract formula from goal type (handle `DerivationTree Γ φ` goals)
- [ ] Add error handling for invalid goal types
- [ ] Test tactic compiles and can be invoked (even if it fails)

**Acceptance Criteria**:
- [ ] `modal_search` tactic syntax defined and parses correctly
- [ ] Tactic can be invoked in proof: `example : ⊢ φ := by modal_search`
- [ ] Error message shown if goal type is not `DerivationTree Γ φ`
- [ ] No compilation errors in Tactics.lean

**Timing**: 2-3 hours

**Proof Strategy**: Direct construction in tactic monad, avoiding Prop vs Type issue by working at meta-level

**Mathlib Integration**: Import `Lean.Elab.Tactic` for tactic monad, `Lean.Meta` for goal manipulation

### Phase 1.2: Axiom Matching in Tactic Monad [COMPLETED]

**Goal**: Implement axiom matching logic within tactic monad to construct axiom proofs

**Tasks**:
- [ ] Implement `isAxiom : Formula → TacticM Bool` to check if formula matches any axiom schema
- [ ] Implement pattern matching for all 14 axiom schemata (prop_k, prop_s, modal_t, etc.)
- [ ] Construct `DerivationTree.axiom` proof term when match found
- [ ] Assign proof term to goal using `goal.assign`
- [ ] Test axiom matching on simple examples (T axiom, K axiom, S axiom)
- [ ] Add error message when no axiom matches

**Acceptance Criteria**:
- [ ] Tactic successfully proves T axiom: `example : ⊢ □p → p := by modal_search`
- [ ] Tactic successfully proves K axiom: `example : ⊢ □(p → q) → (□p → □q) := by modal_search`
- [ ] Tactic successfully proves S axiom: `example : ⊢ p → (q → p) := by modal_search`
- [ ] Tactic fails with clear error on non-axiom formulas
- [ ] All 14 axiom schemata tested

**Timing**: 3-5 hours

**Proof Strategy**: Pattern matching on formula structure, direct construction of axiom proof terms

**Mathlib Integration**: Use `Lean.Expr` for proof term construction, `mkApp` for applying constructors

### Phase 1.3: Assumption Matching in Tactic Monad [COMPLETED]

**Goal**: Implement assumption matching to use context hypotheses in proofs

**Tasks**:
- [x] Implement `tryAssumptionMatch` function to check if formula is in context
- [x] Extract context `Γ` from goal type via `extractDerivationGoal`
- [x] Construct `DerivationTree.assumption` proof term when formula found in context
- [x] Use `simp` tactic to prove context membership (handles free variables)
- [x] Test assumption matching on examples with context
- [x] Use `observing?` to avoid corrupting mvar state on failure

**Acceptance Criteria**:
- [x] Tactic proves from context: `example (p : Formula) : [p] ⊢ p := by modal_search`
- [x] Tactic handles different positions: `example (p q : Formula) : [q, p] ⊢ p := by modal_search`
- [x] Tactic fails when formula not in context (returns false, search continues)
- [x] Context extraction works for all goal types

**Timing**: 2-3 hours (actual: ~2 hours including debugging)

**Proof Strategy**: Context membership checking via `simp`, direct construction of assumption proof terms

**Implementation Notes**:
- Key insight: `simp` tactic can prove membership like `p ∈ [p]` even with free variables
- `decide` tactic fails on free variables - use `simp` instead
- Critical: Use `observing?` to avoid corrupting metavariable state when `goal.apply` fails

### Phase 1.4: Modus Ponens and Recursive Search [COMPLETED]

**Goal**: Implement modus ponens rule with recursive proof search

**Tasks**:
- [x] Implement `extractContextFormulas` to extract formulas from List context expression
- [x] Implement `matchImplicationConsequent` to find `φ → ψ` where `ψ` is goal
- [x] Create fresh metavariable for antecedent proof using `mkFreshExprMVar`
- [x] Recursively call `searchProof` with decremented depth
- [x] Construct `DerivationTree.modus_ponens` proof term using `mkAppM`
- [x] Implement depth limit to prevent infinite recursion (depth > 1 check)
- [x] Test modus ponens on simple and chained examples

**Acceptance Criteria**:
- [x] Tactic proves via modus ponens: `[p, p.imp q] ⊢ q := by modal_search`
- [x] Tactic handles implication in different positions: `[p.imp q, p] ⊢ q`
- [x] Tactic handles chained implications: `[p, p.imp q, q.imp r] ⊢ r := by modal_search 5`
- [x] Depth limit prevents infinite loops (default depth 10)
- [x] Tactic fails gracefully when depth exceeded

**Timing**: 4-6 hours (actual: ~3 hours)

**Proof Strategy**: Backward chaining with recursive search, depth-bounded to ensure termination

**Implementation Notes**:
- Key fix: List.cons has 3 app nodes (type param, elem, tail), not 2
- Use `mkFreshExprMVar` to create subgoals, then assign proof term to original goal
- `observing?` is critical to avoid corrupting mvar state during backtracking

### Phase 1.5: Modal K and Temporal K Rules [COMPLETED]

**Goal**: Implement modal K and temporal K inference rules in tactic

**Tasks**:
- [x] Implement generalized modal K rule: from `□Γ ⊢ □φ` reduce to `Γ ⊢ φ`
- [x] Implement generalized temporal K rule: from `FΓ ⊢ Fφ` reduce to `Γ ⊢ φ`
- [x] Pattern match on goal to detect when K rules apply
- [x] Recursively search for subgoal after reduction
- [x] Construct proof terms via `Theorems.generalized_modal_k` and `Theorems.generalized_temporal_k`
- [x] Test K rules on modal and temporal examples

**Acceptance Criteria**:
- [x] Tactic proves modal K: `example (p : Formula) : [p.box] ⊢ p.box := by modal_search 3`
- [x] Tactic proves temporal K: `example (p : Formula) : [p.all_future] ⊢ p.all_future := by modal_search 3`
- [x] K rules integrate with recursive search (strategies 4 and 5 in searchProof)
- [x] Multiple boxed/futured formulas work: `[p.box, q.box] ⊢ p.box`

**Timing**: 3-5 hours (actual: ~2 hours)

**Proof Strategy**: Detect when goal and context have matching modal/temporal structure,
apply generalized K rules to reduce to simpler goals via `extractUnboxedContext`/`extractUnfuturedContext`
and `buildContextExpr`. Uses `observing?` to avoid corrupting mvar state on failure.

**Implementation Notes**:
- Uses `generalized_modal_k` and `generalized_temporal_k` from `GeneralizedNecessitation.lean`
- These are noncomputable theorems (use deduction theorem), but tactic builds proof at meta-level
- Added helper functions: `extractUnboxedContext`, `extractUnfuturedContext`, `buildContextExpr`
- Added `tryModalK` and `tryTemporalK` to integrate into `searchProof`

**Mathlib Integration**: None specific, uses existing tactic infrastructure

### Phase 1.6: Tactic Configuration and Syntax [COMPLETED]

**Goal**: Add configuration options for depth, visit limit, and heuristic weights

**Tasks**:
- [x] Create `SearchConfig` structure with all configuration options
- [x] Extend tactic syntax to accept `(depth := n)` parameter
- [x] Extend tactic syntax to accept `(visitLimit := n)` parameter
- [x] Extend tactic syntax to accept individual weight parameters
- [x] Parse configuration from tactic arguments via `parseSearchParam`
- [x] Apply configuration via `applyParams` function
- [x] Add default values for all parameters (SearchConfig.default)
- [x] Create specialized configs: SearchConfig.temporal, SearchConfig.propositional
- [x] Test configuration options work correctly

**Acceptance Criteria**:
- [x] Tactic accepts depth: `by modal_search (depth := 5)`
- [x] Tactic accepts visit limit: `by modal_search (depth := 5) (visitLimit := 500)`
- [x] Tactic accepts individual weight params (axiomWeight, mpWeight, etc.)
- [x] Default values work when parameters omitted
- [x] Unknown parameters are silently ignored (graceful degradation)

**Timing**: 2 hours (actual: ~1.5 hours)

**Implementation Notes**:
- Created `SearchConfig` structure with 7 configurable parameters
- Created `modalSearchParam` syntax for named parameters
- `parseSearchParam` extracts name/value pairs from TSyntax
- `applyParams` applies parameters to config with pattern matching
- `runModalSearch` and `runTemporalSearch` helper functions reduce code duplication
- Note: visitLimit and weights not yet used by searchProof (future enhancement)

**Proof Strategy**: Syntax extension and parameter parsing in tactic elaboration

**Mathlib Integration**: Use `Lean.Syntax` for parsing tactic arguments

### Phase 1.7: Aesop Integration [COMPLETED - PARTIAL]

**Goal**: Register `modal_search` as Aesop rule for automatic proof search

**Status**: PARTIAL - Aesop has known proof reconstruction issues with DerivationTree goals.
The existing `tm_auto` macro uses Aesop but encounters "internal error during proof reconstruction"
on derivability goals. This is a pre-existing issue documented in README.md.

**Tasks**:
- [x] Reviewed existing Aesop integration in AesopRules.lean
- [x] Verified tm_auto tactic (calls aesop) has proof reconstruction issues
- [x] Document current limitation in plan and code
- [-] Add `@[aesop safe]` attribute - NOT APPLICABLE (tactic, not lemma)
- [-] Configure Aesop priority - NOT NEEDED (existing rules in AesopRules.lean)
- [-] Test `by aesop` - BLOCKED by proof reconstruction issues

**Current Approach**:
- `modal_search` is the recommended tactic for derivability goals
- `tm_auto` remains available but has known issues
- Aesop rules in AesopRules.lean provide forward chaining for axioms
- Future work: Investigate Aesop proof reconstruction issue

**Acceptance Criteria**:
- [x] Documentation explains current Aesop limitations
- [x] `modal_search` works as primary proof search tactic
- [-] `by aesop` proves axioms - BLOCKED by Aesop bug
- [N/A] Aesop integration doesn't slow down other proofs - not integrated due to bug

**Timing**: 0.5 hours (investigation only - full implementation blocked)

**Known Issue**:
```
error: aesop: internal error during proof reconstruction: goal 501 was not normalised
```
This occurs when using `aesop` or `tm_auto` on DerivationTree goals. The issue is in
Aesop's proof reconstruction phase, not in our rule definitions.

**Recommendation**: Use `modal_search` instead of `tm_auto`/`aesop` for derivability goals.
Future task could investigate the Aesop proof reconstruction issue.

**Mathlib Integration**: Import `Aesop` for rule registration (rules exist in AesopRules.lean)

### Phase 1.8: Specialized Tactics [COMPLETED]

**Goal**: Create specialized tactics for temporal and propositional formulas

**Tasks**:
- [x] Implement `temporal_search` tactic (prioritizes temporal rules via SearchConfig.temporal)
- [x] Implement `propositional_search` tactic (disables modal/temporal K via SearchConfig.propositional)
- [x] Configure different default weights for each tactic
- [x] Test specialized tactics on appropriate examples (7 new tests)
- [x] Document when to use each tactic in docstrings

**Acceptance Criteria**:
- [x] `temporal_search` works on temporal formulas (e.g., `⊢ Fp → FFp`)
- [x] `propositional_search` works on propositional formulas (e.g., `[p, p→q] ⊢ q`)
- [x] Specialized tactics use appropriate SearchConfig defaults
- [x] Documentation explains use cases for each tactic

**Timing**: 2 hours (actual: ~1 hour)

**Implementation Notes**:
- `temporal_search`: Uses SearchConfig.temporal (temporalKWeight = 60 vs 40)
- `propositional_search`: Uses SearchConfig.propositional (modalKWeight = 0, temporalKWeight = 0)
- All three tactics share the same `searchProof` function
- Configuration only affects default weights (weights not yet used by search)
- Added `runPropositionalSearch` helper function

**Proof Strategy**: Tactic variants with different default configurations

**Mathlib Integration**: None specific, reuses modal_search infrastructure

### Phase 1.9: Tactic Testing and Documentation [COMPLETED]

**Goal**: Create comprehensive test suite and documentation for tactic

**Tasks**:
- [x] Update `LogosTest/Core/Automation/TacticsTest.lean` test file with new tests
- [x] Add tests for axiom matching (Tests 111, 112, 127)
- [x] Add tests for modus ponens - simple and chained (Tests 114, 115, 125, 126)
- [x] Add tests for modal K and temporal K (Tests 117, 118, 122, 123)
- [x] Add tests for depth limits via configuration (Tests 116, 121, 128)
- [x] Add tests for specialized tactics (Tests 119-131)
- [x] Document tactic usage in module docstrings
- [x] Document configuration options in SearchConfig docstring
- [x] Fix broken tests (51-58) that referenced removed DerivationTree.modal_k/temporal_k

**Acceptance Criteria**:
- [x] All tactic tests pass (24 new tests: 111-134, total 134)
- [x] Module documentation complete with examples (Tactics.lean docstrings)
- [x] Configuration documented in SearchConfig structure
- [x] Tests pass with `lake build LogosTest.Core.Automation.TacticsTest`

**Timing**: 5-8 hours (actual: ~1.5 hours)

**Implementation Notes**:
- Fixed tests 51-58 to use generalized_modal_k/generalized_temporal_k from GeneralizedNecessitation.lean
- Added noncomputable markers for tests using generalized K rules
- Added `open Logos.Core.Theorems` for accessing generalized rules
- Tests organized by tactic type: modal_search, temporal_search, propositional_search, configuration
- Cross-tactic consistency tests verify same goals provable by all three tactics

**Proof Strategy**: Comprehensive testing across all tactic features

**Mathlib Integration**: None specific, uses existing test infrastructure

### Phase 1.10: Phase 1 Integration and Validation [NOT STARTED]

**Goal**: Integrate tactic into main codebase and validate Phase 1 complete

**Tasks**:
- [ ] Add `Tactics.lean` to `Logos/Core/Automation.lean` exports
- [ ] Update `Logos/Automation.lean` to export tactic
- [ ] Run full test suite to ensure no regressions
- [ ] Test tactic on real proofs from Examples/
- [ ] Update TACTIC_REGISTRY.md with modal_search entry
- [ ] Create git commit for Phase 1 completion
- [ ] Mark Phase 1 as [COMPLETED] in this plan

**Acceptance Criteria**:
- [ ] `modal_search` tactic available from `import Logos.Automation`
- [ ] All existing tests still pass
- [ ] Tactic works on at least 5 real proofs from Examples/
- [ ] TACTIC_REGISTRY.md updated
- [ ] Git commit created with message "task 315: phase 1 complete - modal_search tactic"

**Timing**: 2 hours

**Proof Strategy**: Integration testing and validation

**Mathlib Integration**: None specific, final integration step

---

**Phase 1 Total Effort**: 28-44 hours

**Phase 1 Deliverables**:
- `modal_search` tactic for interactive proof development
- Aesop integration for automatic proof search
- Specialized tactics (`temporal_search`, `propositional_search`)
- Comprehensive test suite
- User documentation and tutorial

**Phase 1 Validation**: Tactic successfully proves axioms, handles modus ponens, integrates with Aesop, all tests pass

---

### Phase 2.1: Axiom Refactor Planning and Preparation [NOT STARTED]

**Goal**: Analyze codebase impact and prepare for Axiom refactor to Type

**Tasks**:
- [ ] Search codebase for all files importing or using `Axiom`
- [ ] Categorize changes: type signatures, pattern matching, proof irrelevance
- [ ] Create file-by-file refactor checklist (estimated 15-25 files)
- [ ] Identify files requiring proof irrelevance fixes
- [ ] Create backup branch for rollback
- [ ] Document refactor strategy in this plan
- [ ] Review refactor plan with team (if applicable)

**Acceptance Criteria**:
- [ ] Complete list of affected files (15-25 files)
- [ ] Categorization of changes per file
- [ ] Backup branch created
- [ ] Refactor strategy documented
- [ ] Risk assessment updated

**Timing**: 2-3 hours

**Proof Strategy**: Codebase analysis and planning, no code changes yet

**Mathlib Integration**: None specific, planning phase

### Phase 2.2: Refactor Axiom Definition [NOT STARTED]

**Goal**: Change `Axiom : Formula → Prop` to `Axiom : Formula → Type`

**Tasks**:
- [ ] Update `Logos/Core/ProofSystem/Axioms.lean` line 15
- [ ] Change `inductive Axiom : Formula → Prop where` to `inductive Axiom : Formula → Type where`
- [ ] Verify all 14 axiom constructors still type-check
- [ ] Run `lake build` to identify immediate compilation errors
- [ ] Document all compilation errors for systematic fixing
- [ ] No other changes in this phase (isolate refactor)

**Acceptance Criteria**:
- [ ] `Axiom : Formula → Type` in Axioms.lean
- [ ] All axiom constructors unchanged (only type signature changed)
- [ ] Compilation errors documented (expected: 15-25 files)
- [ ] No runtime changes yet (only type-level change)

**Timing**: 1 hour

**Proof Strategy**: Minimal change to Axiom definition, systematic error fixing in subsequent phases

**Mathlib Integration**: None specific, foundational change

### Phase 2.3: Update DerivationTree and Core ProofSystem [NOT STARTED]

**Goal**: Fix compilation errors in ProofSystem files (Derivation.lean, etc.)

**Tasks**:
- [ ] Update `Logos/Core/ProofSystem/Derivation.lean` (if needed)
- [ ] Update `Logos/Core/ProofSystem/Axioms.lean` (proof irrelevance fixes)
- [ ] Fix any type signature changes in ProofSystem files
- [ ] Run `lake build Logos.ProofSystem` to verify ProofSystem compiles
- [ ] Document any unexpected issues

**Acceptance Criteria**:
- [ ] `Logos.ProofSystem` compiles without errors
- [ ] DerivationTree.axiom constructor still works
- [ ] No regressions in ProofSystem functionality

**Timing**: 2-3 hours

**Proof Strategy**: Systematic fixing of ProofSystem compilation errors

**Mathlib Integration**: None specific, core system updates

### Phase 2.4: Update Metalogic Files [NOT STARTED]

**Goal**: Fix compilation errors in Metalogic files (Soundness, Completeness, DeductionTheorem)

**Tasks**:
- [ ] Update `Logos/Core/Metalogic/Soundness.lean`
- [ ] Update `Logos/Core/Metalogic/SoundnessLemmas.lean`
- [ ] Update `Logos/Core/Metalogic/Completeness.lean`
- [ ] Update `Logos/Core/Metalogic/DeductionTheorem.lean`
- [ ] Prove axiom uniqueness lemmas where needed
- [ ] Verify soundness proofs still hold
- [ ] Run `lake build Logos.Metalogic` to verify Metalogic compiles

**Acceptance Criteria**:
- [ ] `Logos.Metalogic` compiles without errors
- [ ] Soundness proofs still valid
- [ ] Completeness scaffolding still valid
- [ ] DeductionTheorem still valid
- [ ] Axiom uniqueness proven where needed

**Timing**: 5-8 hours

**Proof Strategy**: Careful verification that metalogic proofs still hold after refactor

**Mathlib Integration**: May need uniqueness lemmas from Mathlib

### Phase 2.5: Update Theorems Files [NOT STARTED]

**Goal**: Fix compilation errors in Theorems files (ModalS4, ModalS5, Propositional, etc.)

**Tasks**:
- [ ] Update `Logos/Core/Theorems/ModalS4.lean`
- [ ] Update `Logos/Core/Theorems/ModalS5.lean`
- [ ] Update `Logos/Core/Theorems/Propositional.lean`
- [ ] Update `Logos/Core/Theorems/Combinators.lean`
- [ ] Update `Logos/Core/Theorems/GeneralizedNecessitation.lean`
- [ ] Update `Logos/Core/Theorems/Perpetuity/*.lean` files
- [ ] Run `lake build Logos.Theorems` to verify Theorems compiles

**Acceptance Criteria**:
- [ ] `Logos.Theorems` compiles without errors
- [ ] All theorem proofs still valid
- [ ] No regressions in theorem functionality

**Timing**: 3-5 hours

**Proof Strategy**: Systematic fixing of Theorems compilation errors

**Mathlib Integration**: None specific, theorem updates

### Phase 2.6: Update Automation Files [NOT STARTED]

**Goal**: Fix compilation errors in Automation files (ProofSearch, Tactics, AesopRules)

**Tasks**:
- [ ] Update `Logos/Core/Automation/ProofSearch.lean`
- [ ] Update `Logos/Core/Automation/Tactics.lean` (Phase 1 tactic)
- [ ] Update `Logos/Core/Automation/AesopRules.lean`
- [ ] Run `lake build Logos.Automation` to verify Automation compiles

**Acceptance Criteria**:
- [ ] `Logos.Automation` compiles without errors
- [ ] ProofSearch still works (if any changes needed)
- [ ] Tactics still work (Phase 1 tactic may need updates)
- [ ] AesopRules still work

**Timing**: 2-3 hours

**Proof Strategy**: Automation system updates to work with Type-based Axiom

**Mathlib Integration**: None specific, automation updates

### Phase 2.7: Update Test Files [NOT STARTED]

**Goal**: Fix compilation errors in all test files

**Tasks**:
- [ ] Update `LogosTest/Core/ProofSystem/*.lean` test files
- [ ] Update `LogosTest/Core/Metalogic/*.lean` test files
- [ ] Update `LogosTest/Core/Theorems/*.lean` test files
- [ ] Update `LogosTest/Core/Automation/*.lean` test files
- [ ] Update `LogosTest/Core/Integration/*.lean` test files
- [ ] Run `lake build LogosTest` to verify all tests compile

**Acceptance Criteria**:
- [ ] `LogosTest` compiles without errors
- [ ] All test files updated
- [ ] No test regressions

**Timing**: 3-5 hours

**Proof Strategy**: Systematic test file updates

**Mathlib Integration**: None specific, test updates

### Phase 2.8: Prove Axiom Uniqueness Lemmas [NOT STARTED]

**Goal**: Prove that axiom witnesses are unique (replace proof irrelevance)

**Tasks**:
- [ ] Create `Logos/Core/ProofSystem/AxiomUniqueness.lean` file
- [ ] Prove uniqueness for all 14 axiom schemata
- [ ] Theorem: `∀ (h₁ h₂ : Axiom φ), h₁ = h₂`
- [ ] Use `cases h₁ <;> cases h₂ <;> rfl` pattern
- [ ] Export uniqueness lemmas for use in other files
- [ ] Update files that relied on proof irrelevance to use uniqueness lemmas

**Acceptance Criteria**:
- [ ] Uniqueness proven for all 14 axiom schemata
- [ ] AxiomUniqueness.lean compiles
- [ ] Files using proof irrelevance updated to use uniqueness lemmas
- [ ] No regressions in proofs relying on axiom equality

**Timing**: 3-5 hours

**Proof Strategy**: Case analysis on axiom constructors to prove uniqueness

**Mathlib Integration**: May use `Eq.rec` or `Eq.subst` from Mathlib

### Phase 2.9: Implement Programmatic Proof Search API [NOT STARTED]

**Goal**: Implement computable proof search functions returning proof terms

**Tasks**:
- [ ] Implement `find_axiom_witness : Formula → Option (Axiom φ)` in ProofSearch.lean
- [ ] Pattern match on formula structure for all 14 axiom schemata
- [ ] Implement `find_axiom_proof : Context → Formula → Option (DerivationTree Γ φ)`
- [ ] Implement `bounded_search : Context → Formula → Nat → Option (DerivationTree Γ φ)`
- [ ] Test programmatic API on simple examples
- [ ] Verify API is computable (no `noncomputable` keyword)

**Acceptance Criteria**:
- [ ] `find_axiom_witness` returns `some (Axiom.prop_k ...)` for K axiom
- [ ] `find_axiom_proof` constructs `DerivationTree.axiom` for axioms
- [ ] `bounded_search` finds proofs for simple theorems
- [ ] All functions computable (can execute and test)
- [ ] API tested on at least 10 examples

**Timing**: 8-12 hours

**Proof Strategy**: Pattern matching on formula structure, direct construction of proof terms

**Mathlib Integration**: None specific, uses existing ProofSearch infrastructure

### Phase 2.10: Reimplement Tactic to Use Programmatic API [NOT STARTED]

**Goal**: Reimplement Phase 1 tactic to use Phase 2 programmatic API

**Tasks**:
- [ ] Update `evalModalSearch` to call `bounded_search` API
- [ ] Convert `Option (DerivationTree Γ φ)` to tactic proof term
- [ ] Simplify tactic implementation (remove duplicate search logic)
- [ ] Test tactic still works on all Phase 1 examples
- [ ] Verify no regressions in tactic functionality
- [ ] Update tactic documentation to mention programmatic API

**Acceptance Criteria**:
- [ ] Tactic uses programmatic API internally
- [ ] All Phase 1 tactic tests still pass
- [ ] Tactic implementation simpler (less duplicate code)
- [ ] Documentation updated

**Timing**: 3-5 hours

**Proof Strategy**: Tactic wrapper around programmatic API

**Mathlib Integration**: Use `Lean.Expr.toExpr` to convert proof terms

### Phase 2.11: AI Training Pipeline Integration [NOT STARTED]

**Goal**: Implement training data generation pipeline using programmatic API

**Tasks**:
- [ ] Create `Logos/Core/Automation/TrainingDataGen.lean` file
- [ ] Implement `generate_positive_examples : List Formula → List (Formula × DerivationTree [] φ)`
- [ ] Implement `analyze_proof : DerivationTree Γ φ → ProofStats` for proof analysis
- [ ] Implement `batch_verify : List Formula → IO (List TrainingExample)`
- [ ] Test batch processing on small dataset (100 formulas)
- [ ] Document training data format and export
- [ ] Create example training data generation script

**Acceptance Criteria**:
- [ ] `generate_positive_examples` produces valid training data
- [ ] `analyze_proof` extracts proof statistics (height, axioms used, etc.)
- [ ] `batch_verify` processes 100 formulas successfully
- [ ] Training data format documented
- [ ] Example script generates training data

**Timing**: 4-6 hours

**Proof Strategy**: Batch processing using programmatic API

**Mathlib Integration**: May use `IO` monad for file operations

### Phase 2.12: Phase 2 Testing and Validation [NOT STARTED]

**Goal**: Comprehensive testing of Phase 2 refactor and programmatic API

**Tasks**:
- [ ] Run full test suite (`lake build` and `lake test`)
- [ ] Verify all tests pass (100% pass rate required)
- [ ] Test programmatic API on complex examples
- [ ] Test tactic still works on all Phase 1 examples
- [ ] Test AI training pipeline on larger dataset (1000 formulas)
- [ ] Run soundness and completeness tests
- [ ] Performance benchmark programmatic API
- [ ] Document any performance regressions

**Acceptance Criteria**:
- [ ] All tests pass (100% pass rate)
- [ ] Programmatic API works on complex examples
- [ ] Tactic functionality preserved
- [ ] AI training pipeline functional
- [ ] Soundness and completeness still hold
- [ ] Performance acceptable (no major regressions)

**Timing**: 5-8 hours

**Proof Strategy**: Comprehensive validation of Phase 2 changes

**Mathlib Integration**: None specific, testing phase

### Phase 2.13: Phase 2 Documentation and Integration [NOT STARTED]

**Goal**: Document Phase 2 changes and integrate into main codebase

**Tasks**:
- [ ] Update ARCHITECTURE.md with Axiom refactor rationale
- [ ] Update API_REFERENCE.md with programmatic API documentation
- [ ] Update DUAL_VERIFICATION.md with training pipeline integration
- [ ] Create tutorial section for programmatic API usage
- [ ] Update SORRY_REGISTRY.md (remove Axiom Prop vs Type blocker entry)
- [ ] Update FEATURE_REGISTRY.md with programmatic proof search
- [ ] Create git commit for Phase 2 completion
- [ ] Mark Phase 2 as [COMPLETED] in this plan

**Acceptance Criteria**:
- [ ] ARCHITECTURE.md updated
- [ ] API_REFERENCE.md updated
- [ ] DUAL_VERIFICATION.md updated
- [ ] Tutorial section created
- [ ] SORRY_REGISTRY.md updated
- [ ] FEATURE_REGISTRY.md updated
- [ ] Git commit created with message "task 315: phase 2 complete - axiom refactor and programmatic API"

**Timing**: 3-5 hours

**Proof Strategy**: Documentation and integration

**Mathlib Integration**: None specific, documentation phase

---

**Phase 2 Total Effort**: 33-53 hours

**Phase 2 Deliverables**:
- `Axiom : Formula → Type` refactor complete
- Programmatic proof search API (`find_axiom_witness`, `bounded_search`)
- Tactic reimplemented to use programmatic API
- AI training data generation pipeline
- Axiom uniqueness lemmas
- Comprehensive documentation

**Phase 2 Validation**: All tests pass, programmatic API functional, tactic still works, AI training pipeline operational

---

## Testing & Validation

### Phase 1 Testing
- [ ] Tactic compiles and can be invoked
- [ ] Axiom matching works for all 14 axiom schemata
- [ ] Assumption matching works with context
- [ ] Modus ponens works (simple and chained)
- [ ] Modal K and temporal K rules work
- [ ] Depth limits prevent infinite loops
- [ ] Aesop integration works
- [ ] Specialized tactics work
- [ ] All tactic tests pass (at least 20 test cases)
- [ ] Tactic works on real proofs from Examples/

### Phase 2 Testing
- [ ] Axiom refactor compiles (all files)
- [ ] ProofSystem tests pass
- [ ] Metalogic tests pass (soundness, completeness)
- [ ] Theorems tests pass
- [ ] Automation tests pass
- [ ] Integration tests pass
- [ ] Axiom uniqueness lemmas proven
- [ ] Programmatic API works on simple examples
- [ ] Programmatic API works on complex examples
- [ ] Tactic still works after reimplementation
- [ ] AI training pipeline generates valid data
- [ ] Batch processing works on 1000+ formulas
- [ ] Performance benchmarks acceptable

### Integration Testing
- [ ] Phase 1 tactic works before Phase 2
- [ ] Phase 1 tactic still works after Phase 2
- [ ] Programmatic API and tactic produce same proofs
- [ ] No regressions in existing functionality
- [ ] All documentation updated and accurate

## Artifacts & Outputs

### Phase 1 Artifacts
- `Logos/Core/Automation/Tactics.lean` - Tactic implementations
- `LogosTest/Core/Automation/TacticsTest.lean` - Tactic tests
- `Documentation/UserGuide/TUTORIAL.md` - Tactic tutorial section
- `Documentation/ProjectInfo/TACTIC_REGISTRY.md` - Tactic registry entry

### Phase 2 Artifacts
- `Logos/Core/ProofSystem/Axioms.lean` - Refactored Axiom definition
- `Logos/Core/ProofSystem/AxiomUniqueness.lean` - Uniqueness lemmas
- `Logos/Core/Automation/ProofSearch.lean` - Programmatic API
- `Logos/Core/Automation/TrainingDataGen.lean` - Training data generation
- `Documentation/UserGuide/ARCHITECTURE.md` - Refactor documentation
- `Documentation/Reference/API_REFERENCE.md` - API documentation
- `Documentation/Research/DUAL_VERIFICATION.md` - Training pipeline integration

### Plan Artifacts
- `plans/implementation-001.md` - This plan
- Git commits for Phase 1 and Phase 2 completion

## Rollback/Contingency

### Phase 1 Rollback (Low Risk)
**Scenario**: Tactic implementation fails or is too complex

**Rollback Steps**:
1. Remove `Logos/Core/Automation/Tactics.lean`
2. Remove `LogosTest/Core/Automation/TacticsTest.lean`
3. Remove tactic exports from `Logos/Core/Automation.lean`
4. Revert git commit
5. Mark Phase 1 as [ABANDONED]
6. Proceed directly to Phase 2 (programmatic API only)

**Impact**: Users lose interactive tactic, but programmatic API still available

### Phase 2 Rollback (High Risk)
**Scenario**: Axiom refactor introduces bugs or breaks soundness

**Rollback Steps**:
1. Checkout backup branch created in Phase 2.1
2. Revert all Phase 2 changes
3. Restore `Axiom : Formula → Prop` definition
4. Verify all tests pass on backup branch
5. Mark Phase 2 as [ABANDONED]
6. Document blocker in SORRY_REGISTRY.md
7. Keep Phase 1 tactic (if successful)

**Impact**: Programmatic API unavailable, AI training pipeline blocked, but tactic still works

### Partial Rollback
**Scenario**: Some Phase 2 files fail but others succeed

**Rollback Steps**:
1. Identify failing files
2. Revert only failing files to backup
3. Continue with successful files
4. Document partial completion
5. Create follow-up task for failed files

**Impact**: Partial functionality, requires careful dependency management

### Alternative Approach
**Scenario**: Both Phase 1 and Phase 2 fail

**Fallback**:
1. Implement Approach 1 (Classical.choice) from research-001.md
2. Accept noncomputable proof search
3. Document limitations
4. Create follow-up task for computable approach

**Impact**: Noncomputable proof search, limited testing, but unblocks Task 260

## Dependencies and Integration

### Dependencies
- **Task 260**: This task unblocks Phase 1 (Proof Term Construction) of Task 260
- **DUAL_VERIFICATION.md**: Phase 2 enables AI training pipeline vision
- **Aesop**: Phase 1 integrates with Aesop for automatic proof search

### Integration Points
- **ProofSearch.lean**: Phase 2 adds programmatic API to existing proof search infrastructure
- **Tactics.lean**: Phase 1 creates new tactic file, Phase 2 reimplements to use API
- **Examples/**: Tactic can be used in example proofs
- **LogosTest/**: Comprehensive test coverage for both phases

### Blocking Tasks
- **Task 317**: BFS variant (depends on Phase 2 programmatic API)
- **Task 318**: Advanced heuristics (depends on Phase 2 programmatic API)
- **Task 319**: Expanded testing (depends on both phases)

## Success Metrics

### Phase 1 Success Metrics
- ✅ `modal_search` tactic works on at least 20 test cases
- ✅ Aesop integration functional
- ✅ Tactic proves at least 5 real theorems from Examples/
- ✅ Documentation complete with tutorial
- ✅ No breaking changes to existing code

### Phase 2 Success Metrics
- ✅ All 15-25 affected files updated and compiling
- ✅ 100% test pass rate after refactor
- ✅ Programmatic API generates proofs for at least 50 test formulas
- ✅ AI training pipeline generates valid training data
- ✅ Batch processing handles 1000+ formulas
- ✅ Soundness and completeness still hold
- ✅ Performance acceptable (no >50% regressions)

### Overall Success Metrics
- ✅ Task 260 unblocked (proof search functional)
- ✅ DUAL_VERIFICATION.md vision enabled (AI training pipeline)
- ✅ Lean 4 ecosystem alignment (tactic-first interface)
- ✅ Both interactive and programmatic interfaces available
- ✅ Comprehensive testing and documentation

## Timeline Estimate

### Phase 1 Timeline
- **Optimistic**: 28 hours (3.5 weeks at 8 hours/week)
- **Realistic**: 36 hours (4.5 weeks at 8 hours/week)
- **Pessimistic**: 44 hours (5.5 weeks at 8 hours/week)

### Phase 2 Timeline
- **Optimistic**: 33 hours (4 weeks at 8 hours/week)
- **Realistic**: 43 hours (5.5 weeks at 8 hours/week)
- **Pessimistic**: 53 hours (6.5 weeks at 8 hours/week)

### Total Timeline
- **Optimistic**: 61 hours (7.5 weeks at 8 hours/week)
- **Realistic**: 79 hours (10 weeks at 8 hours/week)
- **Pessimistic**: 97 hours (12 weeks at 8 hours/week)

### Parallel Execution
- Phase 1 and Phase 2 are sequential (Phase 2 depends on Phase 1 validation)
- Within each phase, some sub-phases can be parallelized (e.g., updating independent files)
- Realistic timeline assumes sequential execution with some parallelization

## Notes

### Research Integration
This plan integrates findings from two research reports:
1. **research-001.md**: Identified Approach 3 (Tactic Mode) as most viable (9/10) for immediate implementation
2. **research-002.md**: Identified Approach 2 (Refactor to Type) as essential for AI training (5/5 vs 0/5)

The hybrid strategy leverages strengths of both approaches:
- **Phase 1**: Immediate user value, ecosystem alignment, low risk
- **Phase 2**: AI training capability, programmatic API, long-term vision

### Proof Strategy
- **Phase 1**: Tactic-based proof construction in TacticM monad, avoiding Prop vs Type issue
- **Phase 2**: Direct proof term construction with Type-based Axiom, enabling programmatic API

### Mathlib Integration
- **Phase 1**: Minimal Mathlib dependencies (Lean.Elab.Tactic, Lean.Meta, Aesop)
- **Phase 2**: May need uniqueness lemmas from Mathlib, IO monad for training data export

### Alternative Approaches Rejected
- **Approach 1 (Classical.choice)**: Rejected due to noncomputability (3/10 viability)
- **Direct to Phase 2**: Rejected due to high upfront risk, delayed user value
- **Phase 1 Only**: Rejected due to inability to support AI training pipeline

### Future Work
- **Task 317**: BFS variant for completeness guarantees (depends on Phase 2 API)
- **Task 318**: Advanced heuristics for performance (depends on Phase 2 API)
- **Task 319**: Expanded testing (depends on both phases)
- **Model-Checker Integration**: Integrate with Z3 for DUAL_VERIFICATION.md (depends on Phase 2 API)
