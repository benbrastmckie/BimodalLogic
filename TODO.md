# TODO.md - Logos Task Tracking

## Overview

This file serves as the central task tracking system for Logos development. It organizes all pending work by priority (High/Medium/Low), tracks `sorry` placeholders requiring resolution, documents missing files, and provides actionable next steps for systematic project development.

**Purpose**: Maintain a comprehensive view of remaining implementation work for Layer 0 (Core TM) completion and beyond.

**Organization**: Tasks are prioritized based on blocking status, dependency relationships, and estimated effort. High priority tasks should be completed within 1 month, medium priority within 3 months, and low priority represents future work.

---

## ⚠️ Keep Documentation in Sync

**IMPORTANT**: As you complete tasks, update these files to maintain accurate project status:

1. **[IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)** - Module-by-module completion tracking
   - Update completion percentages as proofs are completed
   - Update sorry counts as placeholders are resolved
   - Mark modules as COMPLETE when fully proven

2. **[KNOWN_LIMITATIONS.md](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md)** - Gap documentation with workarounds
   - Remove limitation entries when issues are resolved
   - Update "What works well" and "What to avoid" sections
   - Keep roadmap section current with actual priorities

3. **This file (TODO.md)** - Task tracking and progress
   - Mark tasks complete in Progress Tracking section
   - Update Sorry Placeholder Registry as items are resolved
   - Add completion dates to Completion Log

---

**Related Documentation**:
- [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Detailed module-by-module completion tracking
- [KNOWN_LIMITATIONS.md](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) - Comprehensive gap documentation with workarounds
- [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md) - System design and TM logic specification

**Active Implementation Plan**:
- [TODO Implementation Systematic Plan](.claude/specs/019_research_todo_implementation_plan/plans/001-research-todo-implementation-plan.md) - 8-phase execution plan for Layer 0 completion
  - **Status**: Phases 1-4 COMPLETE, Phases 5-8 remaining (Wave 3-4: Completeness proofs and Future Work)
  - **Estimated Remaining**: 120-190 hours

**How to Use This File**:
1. Review High Priority tasks first - these are blocking or urgent
2. Check dependencies before starting a task (see Dependency Graph section)
3. Mark completed tasks with completion date in Progress Tracking section
4. Update `sorry` registry as placeholders are resolved
5. Cross-reference with IMPLEMENTATION_STATUS.md for detailed module status

---

## High Priority Tasks

### 7. Implement Core Automation ✓ PARTIAL COMPLETE
*Effort**: 40-60 hours
*Status**: PARTIAL COMPLETE (2025-12-03) - 4/12 tactics implemented (33%)
*Priority**: Medium (developer productivity, proof automation)

**Description**: Implement 3-4 most useful tactics to replace axiom stubs with real implementations using LEAN 4's `Lean.Elab.Tactic` API.

**Files**:
- `Logos/Automation/Tactics.lean` (175 lines, working tactics)
- `LogosTest/Automation/TacticsTest.lean` (31 tests)

**Completed Actions** (2025-12-03):
1. ✓ Implemented `apply_axiom` macro (generic axiom application for all 10 TM axioms)
2. ✓ Implemented `modal_t` macro (modal T axiom: `□φ → φ`)
3. ✓ Implemented `tm_auto` macro (native implementation using `first` combinator)
4. ✓ Implemented `assumption_search` elab (TacticM-based context search)
5. ✓ Implemented 4 helper functions (is_box_formula, is_future_formula, extract_from_box, extract_from_future)
6. ✓ Created 31 tests in `LogosTest/Automation/TacticsTest.lean`
7. ✓ Updated IMPLEMENTATION_STATUS.md Automation status (0% → 33%)

**Blocker Documented**: Aesop integration blocked by Batteries dependency breaking Truth.lean. Native `tm_auto` implemented as MVP alternative.

**Remaining Work** (future enhancement):
- Fix Truth.lean for Batteries compatibility (4-8 hours)
- Complete Aesop integration (6-8 hours)
- Implement remaining 8 tactics (30-40 hours)
- Expand test suite to 50+ tests (5-10 hours)

**Reference**: [Implementation Summary](.claude/specs/025_soundness_automation_implementation/summaries/004_iteration_3_final_summary.md)

---

## Medium Priority Tasks

### 14. Clean Up 'Always' Operator Definition Cruft
**Effort**: 3-5 hours
**Status**: Not Started
**Priority**: Medium (code clarity and documentation accuracy)

**Description**: After aligning the `always` operator with the JPL paper definition (`Pφ ∧ φ ∧ Fφ`), the TL, MF, and TF axiom proofs no longer require frame constraints. Remove the unused `BackwardPersistence` and `ModalTemporalPersistence` definitions and update all associated documentation that incorrectly claims these constraints are required.

**Files**:
- `Logos/Metalogic/Soundness.lean` (primary - remove definitions, update docstrings)
- `CLAUDE.md` (update implementation status)
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` (update frame constraint references)
- `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md` (remove outdated limitation sections)

**Action Items**:
1. **Phase 1** (1 hour): Remove unused frame constraint definitions
   - Delete `BackwardPersistence` definition (Soundness.lean:99-123)
   - Delete `ModalTemporalPersistence` definition (Soundness.lean:125-149)
   - Verify `lake build` succeeds
2. **Phase 2** (1 hour): Update Soundness.lean docstrings
   - Remove all references to conditional validity and frame constraints
   - Update module docstring (lines 1-70)
   - Update `temp_l_valid`, `modal_future_valid`, `temp_future_valid` docstrings
3. **Phase 3** (1-2 hours): Update external documentation
   - Update CLAUDE.md line 191 (remove "require frame constraints")
   - Review and update IMPLEMENTATION_STATUS.md
   - Review and update KNOWN_LIMITATIONS.md
4. **Phase 4** (0.5 hours): Final verification
   - Grep for remaining BackwardPersistence/ModalTemporalPersistence references
   - Run `lake build && lake test`

**Blocking**: None (cleanup task, doesn't affect functionality)

**Dependencies**: None (can be done anytime)

**Research/Plan Reference**:
- [Research Report](.claude/specs/034_always_operator_cleanup_alignment/reports/001-always-operator-cruft-analysis.md)
- [Implementation Plan](.claude/specs/034_always_operator_cleanup_alignment/plans/001-always-operator-cleanup-plan.md)

**Notes**: The definitions were never used in actual proofs - they were documented as "required" but the proofs use time-shift infrastructure (MF, TF) or the correct `always` definition (TL) instead.

---

## Low Priority Tasks

### 15. Generalize Temporal Order to LinearOrderedAddCommGroup ✓ COMPLETE
**Effort**: 30-45 hours (Actual: ~25-30 hours)
**Status**: COMPLETE (2025-12-04)
**Priority**: Low (architectural improvement, paper alignment)

**Description**: Generalize Logos's temporal domain from hardcoded `Int` to polymorphic `LinearOrderedAddCommGroup` typeclass, matching the JPL paper specification. This enables support for rational/real time models, bounded temporal domains, and custom temporal structures while maintaining alignment with the paper's formal semantics.

**Paper Reference**: JPL Paper §app:TaskSemantics (lines 1835-1867)
- def:frame (line 1835): "A totally ordered abelian group T = ⟨T, +, ≤⟩"
- def:world-history (line 1849): Functions τ: X → W where X ⊆ T is convex
- Current implementation uses `Int` (specific abelian group, line 39 TaskFrame.lean)

**Files**:
- `Logos/Semantics/TaskFrame.lean` (parameterize by T)
- `Logos/Semantics/WorldHistory.lean` (add convexity constraint)
- `Logos/Semantics/Truth.lean` (polymorphic temporal type)
- `Logos/Semantics/Validity.lean` (update quantification)
- `Logos/Semantics/TaskModel.lean` (minor updates)

**Benefits**:
1. **Paper Alignment**: Direct correspondence with JPL paper specification
2. **Generality**: Support for rational/real time models (physics, economics)
3. **Bounded Systems**: Enable finite temporal domains (games, bounded processes)
4. **Mathlib Integration**: Leverage `LinearOrderedAddCommGroup` lemmas

**Action Items**:
1. **Phase 1** (8-12 hours): Generalize TaskFrame
   - Add type parameter `(T : Type*) [LinearOrderedAddCommGroup T]`
   - Replace `Int` with `T` throughout
   - Update example frames
   - Fix downstream compilation errors
2. **Phase 2** (10-15 hours): Generalize WorldHistory
   - Add type parameter and convexity constraint
   - Update `time_shift` infrastructure
   - Prove convexity preservation lemmas
3. **Phase 3** (6-10 hours): Generalize Truth evaluation
   - Update temporal quantification to `∀ (s : T)`
   - Review time-shift preservation with abstract groups
   - Update temporal duality infrastructure
4. **Phase 4** (3-5 hours): Update Validity and Model
   - Generalize validity to quantify over all temporal types
   - Update semantic consequence definitions
5. **Phase 5** (3-5 hours): Documentation and Testing
   - Create examples with `Rat` and `Real` temporal types
   - Add convexity tests
   - Update ARCHITECTURE.md with typeclass explanation
   - Document migration guide

**Breaking Changes**:
- All `TaskFrame` → `TaskFrame T` with explicit type parameter
- Convexity proofs required for all world histories
- Some arithmetic proofs may need group lemmas instead of omega

**Migration Path**:
```lean
-- Provide type aliases for backward compatibility
abbrev TaskFrameInt := TaskFrame Int
abbrev WorldHistoryInt := WorldHistory (F : TaskFrame Int)
```

**Blocking**: None (architectural improvement, doesn't affect functionality)

**Dependencies**:
- **INDEPENDENT**: Can run anytime after Layer 0 stabilization
- **BENEFITS FROM**: Completed soundness/completeness proofs (more tests to verify)

**Research/Plan Reference**:
- [Research Report](.claude/specs/035_semantics_temporal_order_generalization/reports/001-semantics-temporal-order-generalization-research.md)
- [Implementation Plan](.claude/specs/035_semantics_temporal_order_generalization/plans/001-semantics-temporal-order-generalization-plan.md)

**Notes**: This is an architectural improvement for paper alignment and increased expressivity. Not required for Layer 0 MVP completion, but provides foundation for advanced temporal models (continuous time physics, bounded games, rational-time economics). Generalization matches paper's formal specification exactly via Mathlib's `LinearOrderedAddCommGroup` typeclass.

---

### 9. Begin Completeness Proofs
**Effort**: 70-90 hours
**Status**: Not Started
**Priority**: Low (long-term metalogic goal)

**Description**: Implement canonical model construction and prove completeness theorems (weak and strong). This is a major undertaking requiring significant effort.

**Files**:
- `Logos/Metalogic/Completeness.lean`
  - Line 116: lindenbaum (maximal consistent extension)
  - Line 140: maximal_consistent_closed (closure under MP)
  - Line 154: maximal_negation_complete (negation completeness)
  - Line 199: canonical_task_rel (task relation from derivability)
  - Line 210: canonical_frame (frame from maximal consistent sets)
  - Line 235: canonical_valuation (valuation from maximal sets)
  - Line 242: canonical_model (model construction)
  - Line 263: canonical_history (history from maximal sets)
  - Line 297: truth_lemma (truth preservation in canonical model)
  - Line 326: weak_completeness (`⊨ φ → ⊢ φ`)
  - Line 346: strong_completeness (`Γ ⊨ φ → Γ ⊢ φ`)

**Action Items**:
1. **Phase 1** (20-30 hours): Prove Lindenbaum lemma and maximal set properties
   - Prove lindenbaum (maximal consistent extension exists)
   - Prove maximal_consistent_closed (closure under modus ponens)
   - Prove maximal_negation_complete (for every φ, either φ or ¬φ in set)
2. **Phase 2** (20-30 hours): Construct canonical model components
   - Define canonical_task_rel from derivability relation
   - Prove canonical_frame satisfies nullity and compositionality
   - Define canonical_valuation from maximal sets
   - Combine into canonical_model
3. **Phase 3** (20-30 hours): Prove truth lemma and completeness
   - Define canonical_history for temporal operators
   - Prove truth_lemma by induction on formula structure
   - Prove weak_completeness from truth lemma
   - Prove strong_completeness from weak completeness
4. Replace all 11 axiom declarations with actual proofs
5. Write comprehensive tests in `LogosTest/Metalogic/CompletenessTest.lean`
6. Update IMPLEMENTATION_STATUS.md Completeness status (0% → 100%)

**Blocking**: None (metalogic property, doesn't block derivations or applications)

**Dependencies**:
- **BENEFITS FROM**: Task 5 (Complete Soundness) - for metalogic proof techniques
- **BENEFITS FROM**: Task 2 (Add Propositional Axioms) - for completeness proof techniques

**Notes**: This is the largest remaining task for Layer 0 completion. Can be deferred to Layer 1 planning phase.

---

### 10. Create Decidability Module
**Effort**: 40-60 hours
**Status**: Not Started
**Priority**: Low (future enhancement, not in MVP)

**Description**: Create Logos/Metalogic/Decidability.lean module with tableau method for validity checking and satisfiability decision procedures.

**Files**:
- `Logos/Metalogic/Decidability.lean` (does not exist, planned in CLAUDE.md line 318)

**Action Items**:
1. **Phase 1** (15-20 hours): Design decidability architecture
   - Analyze complexity (EXPTIME for S5 modal, PSPACE for LTL)
   - Design tableau method for TM logic
   - Plan satisfiability decision procedure
2. **Phase 2** (15-20 hours): Implement tableau method
   - Implement systematic tableau construction
   - Implement closure rules for TM operators
   - Implement satisfiability checking
3. **Phase 3** (10-20 hours): Prove correctness and complexity
   - Prove tableau method sound and complete
   - Analyze time/space complexity
   - Document complexity bounds
4. Write comprehensive tests in `LogosTest/Metalogic/DecidabilityTest.lean`
5. Update documentation with decidability results
6. Update IMPLEMENTATION_STATUS.md to add Decidability module

**Blocking**: None (enhancement, doesn't affect existing functionality)

**Dependencies**:
- **REQUIRES**: Task 9 (Begin Completeness Proofs) - correctness proofs depend on completeness
- **BENEFITS FROM**: Task 7 (Implement Core Automation) - for automated search

**Notes**: Planned but not essential for Layer 0. Can be deferred to Layer 1 or beyond.

---

### 11. Plan Layer 1/2/3 Extensions
**Effort**: Research phase (20-40 hours initial planning)
**Status**: Not Started
**Priority**: Low (future work, after Layer 0 complete)

**Description**: Design and plan extensions beyond Core TM (Layer 0): counterfactual operators (Layer 1), epistemic operators (Layer 2), normative operators (Layer 3).

**Action Items**:
1. **Layer 1 (Counterfactuals)**: Design counterfactual operators and semantics
   - Research counterfactual logic approaches
   - Design `□c` (would-counterfactual) and `◇m` (might-counterfactual) operators
   - Specify task semantics for counterfactuals
   - Document architectural changes needed
2. **Layer 2 (Epistemic)**: Design epistemic operators (knowledge, belief)
   - Design `K` (knowledge) and `B` (belief) operators
   - Specify multi-agent epistemic semantics
   - Plan integration with TM and counterfactuals
3. **Layer 3 (Normative)**: Design deontic/normative operators
   - Design `O` (obligation) and `P` (permission) operators
   - Specify normative task semantics
   - Plan interaction with epistemic and modal operators
4. Create implementation plans for each layer
5. Update ARCHITECTURE.md with layer design

**Blocking**: None (future work)

**Dependencies**:
- **REQUIRES**: Layer 0 completion and stability
- **REQUIRES**: Tasks 1-8 complete (high and medium priority)

**Notes**: This is strategic planning for post-MVP development. Should not begin until Layer 0 is complete and tested.

---

### 13. Create Proof Strategy Documentation
**Effort**: 5-10 hours
**Status**: Not Started
**Priority**: Low (pedagogical, not blocking)

**Description**: Create Archive/ examples demonstrating common proof strategies and
patterns for TM derivations. Provides pedagogical value for new users, students, and
researchers learning TM logic and Logos usage.

**Files**:
- `Archive/ModalProofStrategies.lean` (to be created)
- `Archive/TemporalProofStrategies.lean` (to be created)
- `Archive/BimodalProofStrategies.lean` (to be created)

**Action Items**:
1. Create `ModalProofStrategies.lean` with S5 modal proof patterns (necessity chains,
   possibility proofs, modal modus ponens)
2. Create `TemporalProofStrategies.lean` with temporal reasoning patterns (always/
   eventually proofs, induction over time, temporal duality)
3. Create `BimodalProofStrategies.lean` with modal-temporal interaction patterns
   (perpetuity principles, frame reasoning, task relation proofs)
4. Document common proof techniques in extensive comments
5. Update `Archive/Archive.lean` to re-export new modules

**Blocking**: None (independent documentation task)

**Dependencies**: None (can be created anytime, benefits from completed proofs)

**Audience**: New users, students, researchers learning TM logic

**Reference**: Best practices report (.claude/specs/
021_lean4_bimodal_logic_best_practices/reports/001-lean-4-modal-logic-
implementation-best.md) lines 649-675

**Notes**: These are pedagogical examples, not required for project functionality.
Can be deferred until after core implementation is stable.

---

## Sorry Placeholder Registry

This section lists all 41 `sorry` placeholders in the codebase that require resolution. Each entry includes the file, line number, context, and recommended resolution approach.

### Logos/Semantics/WorldHistory.lean ✓ COMPLETE (0 sorry)

- **WorldHistory.lean:119** - `universal` helper function ✓ RESOLVED (2025-12-03)
  - **Context**: Universal history that maps all times to the same world state
  - **Resolution**: Refactored to require explicit reflexivity proof parameter
  - **Added**: `universal_trivialFrame`, `universal_natFrame` for reflexive frames
  - **See**: Task 8 (COMPLETE)

### Logos/Theorems/Perpetuity.lean (14 sorry)

**Propositional Helpers** (2 sorry):
- **Perpetuity.lean:88** - `imp_trans` propositional helper
  - **Context**: `(φ → ψ) → (ψ → χ) → (φ → χ)` transitive implication
  - **Resolution**: Prove from K and S propositional axioms
  - **Effort**: 2-3 hours (after axioms added)
  - **See**: Task 2 (Add Propositional Axioms)

- **Perpetuity.lean:139** - `contraposition` propositional helper
  - **Context**: `(φ → ψ) → (¬ψ → ¬φ)` contrapositive reasoning
  - **Resolution**: Prove from K and S propositional axioms
  - **Effort**: 2-3 hours (after axioms added)
  - **See**: Task 2 (Add Propositional Axioms)

**Perpetuity Principles** (3 sorry):
- **Perpetuity.lean:225** - P4 (`◇▽φ → ◇φ`)
  - **Context**: Possibility of occurrence implies possibility
  - **Resolution**: Use corrected contraposition after propositional axioms added
  - **Effort**: 8-10 hours (complex nested formulas)
  - **See**: Task 6 (Complete Perpetuity Proofs)

- **Perpetuity.lean:252** - P5 (`◇▽φ → △◇φ`)
  - **Context**: Persistent possibility (possible occurrence implies always possible)
  - **Resolution**: Develop modal-temporal interaction lemmas
  - **Effort**: 10-12 hours (complex modal-temporal interaction)
  - **See**: Task 6 (Complete Perpetuity Proofs)

- **Perpetuity.lean:280** - P6 (`▽□φ → □△φ`)
  - **Context**: Occurrent necessity is perpetual
  - **Resolution**: Develop modal-temporal interaction lemmas
  - **Effort**: 10-12 hours (complex modal-temporal interaction)
  - **See**: Task 6 (Complete Perpetuity Proofs)

### Logos/Automation/ProofSearch.lean (3 sorry)

- **ProofSearch.lean:186** - Example usage documentation
  - **Context**: Example proof search usage (documentation `sorry`)
  - **Resolution**: Implement proof search functions, then replace with real examples
  - **Effort**: 1 hour (after search implemented)
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:191** - Example usage documentation
  - **Context**: Example heuristic search usage (documentation `sorry`)
  - **Resolution**: Implement heuristic search, then replace with real examples
  - **Effort**: 1 hour (after search implemented)
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:196** - Example cached search usage
  - **Context**: Example cached search usage (documentation `sorry`)
  - **Resolution**: Implement cached search, then replace with real examples
  - **Effort**: 1 hour (after search implemented)
  - **See**: Task 7 (Implement Core Automation)

### Logos/Metalogic/Soundness.lean (1 sorry remaining)

**Axiom Soundness** - ✓ ALL COMPLETE (2025-12-03):
- TL axiom (`△φ → F(Pφ)`): PROVEN
- MF axiom (`□φ → □Fφ`): PROVEN
- TF axiom (`□φ → F□φ`): PROVEN

**Rule Soundness** - ✓ 6/7 COMPLETE (2025-12-03):
- **modal_k** - ✓ COMPLETE (2025-12-03)
  - Rule fixed in Derivation.lean to match paper (line 1030)
  - Soundness proof complete (lines 535-565, zero sorry)
  - **See**: Task 5 (COMPLETE)

- **temporal_k** - ✓ COMPLETE (2025-12-03)
  - Rule fixed in Derivation.lean to match paper (line 1037)
  - Soundness proof complete (lines 567-597, zero sorry)
  - **See**: Task 5 (COMPLETE)

- **temporal_duality** - ⚠ DOCUMENTED AS LIMITATION (2025-12-03)
  - **Soundness.lean:~642** - 1 sorry remaining
  - **Context**: Requires SymmetricFrame constraint for general soundness
  - **Resolution**: Documented as MVP limitation with clear implementation path
  - **Effort**: 5-10 hours (when needed)
  - **See**: Task 5b (DOCUMENTED AS LIMITATION)

### Logos/Metalogic/Completeness.lean (11 axiom declarations)

**Note**: These are axiom declarations (unproven theorems), not `sorry` placeholders, but require the same resolution attention.

- **Completeness.lean:116** - lindenbaum
  - **Context**: Every consistent set extends to maximal consistent set
  - **Resolution**: Prove using Zorn's lemma or transfinite induction
  - **Effort**: 10-15 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 1

- **Completeness.lean:140** - maximal_consistent_closed
  - **Context**: Maximal consistent sets closed under modus ponens
  - **Resolution**: Prove from maximality and consistency
  - **Effort**: 5-7 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 1

- **Completeness.lean:154** - maximal_negation_complete
  - **Context**: For every φ, either φ or ¬φ in maximal set
  - **Resolution**: Prove from maximality
  - **Effort**: 5-7 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 1

- **Completeness.lean:199** - canonical_task_rel
  - **Context**: Task relation from derivability
  - **Resolution**: Define relation, prove respects derivability
  - **Effort**: 8-10 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 2

- **Completeness.lean:210** - canonical_frame
  - **Context**: Frame from maximal consistent sets
  - **Resolution**: Prove frame axioms (nullity, compositionality)
  - **Effort**: 10-12 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 2

- **Completeness.lean:235** - canonical_valuation
  - **Context**: Valuation from maximal sets (atom membership)
  - **Resolution**: Define valuation function
  - **Effort**: 3-5 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 2

- **Completeness.lean:242** - canonical_model
  - **Context**: Combine canonical frame and valuation
  - **Resolution**: Construct model from components
  - **Effort**: 2-3 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 2

- **Completeness.lean:263** - canonical_history
  - **Context**: History from maximal sets for temporal operators
  - **Resolution**: Define history function, prove respects task
  - **Effort**: 8-10 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 3

- **Completeness.lean:297** - truth_lemma
  - **Context**: `φ ∈ Γ ↔ truth_at canonical_model canonical_history Γ t φ`
  - **Resolution**: Prove by induction on formula structure
  - **Effort**: 15-20 hours (most complex proof)
  - **See**: Task 9 (Begin Completeness Proofs), Phase 3

- **Completeness.lean:326** - weak_completeness
  - **Context**: `⊨ φ → ⊢ φ` (valid implies derivable)
  - **Resolution**: Prove from truth lemma using canonical model
  - **Effort**: 5-7 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 3

- **Completeness.lean:346** - strong_completeness
  - **Context**: `Γ ⊨ φ → Γ ⊢ φ` (semantic consequence implies derivability)
  - **Resolution**: Prove from weak completeness
  - **Effort**: 5-7 hours
  - **See**: Task 9 (Begin Completeness Proofs), Phase 3

### Logos/Automation/Tactics.lean (1 axiom declaration remaining)

**Note**: Most tactic stubs have been replaced with real implementations (2025-12-03).

**Implemented** (2025-12-03):
- ✓ `apply_axiom` macro (lines 70-71) - Generic axiom application
- ✓ `modal_t` macro (lines 87-88) - Modal T axiom convenience wrapper
- ✓ `tm_auto` macro (lines 127-139) - Native automation using `first` combinator
- ✓ `assumption_search` elab (lines 129-144) - TacticM context search
- ✓ `is_box_formula` (lines 152-155) - Formula pattern matching
- ✓ `is_future_formula` (lines 157-160) - Formula pattern matching
- ✓ `extract_from_box` (lines 162-165) - Modal operator extraction
- ✓ `extract_from_future` (lines 167-170) - Temporal operator extraction

**Remaining** (1 axiom stub):
- **Tactics.lean:109** - `tm_auto_stub`
  - **Context**: Placeholder axiom for Aesop integration (blocked)
  - **Resolution**: Remove when Aesop integration complete
  - **Workaround**: Native `tm_auto` macro provides working alternative
  - **See**: Task 7 (Aesop blocker documented)

### Logos/Automation/ProofSearch.lean (8 axiom declarations)

- **ProofSearch.lean:133** - bounded_search
  - **Resolution**: Implement depth-bounded search
  - **Effort**: 8-10 hours
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:146** - search_with_heuristics
  - **Resolution**: Implement heuristic-guided search
  - **Effort**: 10-12 hours
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:156** - search_with_cache
  - **Resolution**: Implement cached search
  - **Effort**: 10-12 hours
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:164** - matches_axiom
  - **Resolution**: Implement axiom pattern matching
  - **Effort**: 3-5 hours
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:167** - find_implications_to
  - **Resolution**: Implement implication chain search
  - **Effort**: 5-7 hours
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:170** - heuristic_score
  - **Resolution**: Implement formula heuristic scoring
  - **Effort**: 3-5 hours
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:173** - box_context
  - **Resolution**: Implement modal context extraction
  - **Effort**: 2-3 hours
  - **See**: Task 7 (Implement Core Automation)

- **ProofSearch.lean:176** - future_context
  - **Resolution**: Implement temporal context extraction
  - **Effort**: 2-3 hours
  - **See**: Task 7 (Implement Core Automation)

---

## Missing Files

This section lists files that are referenced in documentation but do not exist in the repository.

### 1. Archive/ModalProofs.lean ✓ CREATED
**Priority**: High
**Effort**: 3-5 hours
**Status**: COMPLETE (2025-12-02, Phase 1)

**Description**: Pedagogical examples for S5 modal logic proofs using Logos.

### 2. Archive/TemporalProofs.lean ✓ CREATED
**Priority**: High
**Effort**: 3-5 hours
**Status**: COMPLETE (2025-12-02, Phase 1)

**Description**: Pedagogical examples for temporal logic proofs using Logos.

### 3. Logos/Metalogic/Decidability.lean
**Priority**: Low
**Effort**: 40-60 hours
**Referenced In**: CLAUDE.md (line 318), IMPLEMENTATION_STATUS.md (line 319)

**Description**: Decidability module with tableau method and satisfiability decision procedures.

**Creation Plan**:
1. Design tableau method for TM logic
2. Implement systematic tableau construction
3. Implement satisfiability checking
4. Prove soundness and completeness of tableau method
5. Analyze and document complexity bounds
6. Write comprehensive tests
7. Update documentation

**See**: Task 10 (Create Decidability Module)

---

## Dependency Graph

This section shows task prerequisite relationships and identifies parallel execution opportunities.

### High Priority Dependencies

```
Task 1 (Fix CI Flags)
  → Independent, can run anytime
  → Enables: Reliable CI feedback for all tasks

Task 2 (Add Propositional Axioms)
  → Independent, no prerequisites
  → Unblocks: Task 6 (Complete Perpetuity P1-P2, P4-P6)
  → Unblocks: Perpetuity.lean:88, 139 (propositional helpers)

Task 3 (Complete Archive Examples)
  → Independent, can run anytime
  → No blockers

Task 4 (Create TODO.md) 
  → COMPLETE
```

**Parallel Opportunities**: Tasks 1, 2, 3 can run in parallel (all independent).

### Medium Priority Dependencies

```
Task 5 (Complete Soundness Proofs)
  → Independent, no strict prerequisites
  → Benefits from: Task 2 (for proof techniques)
  → Unblocks: Documentation updates only (doesn't block functionality)

Task 6 (Complete Perpetuity Proofs)
  → REQUIRES: Task 2 (Add Propositional Axioms) - BLOCKING
  → Benefits from: Task 5 (for proof techniques)
  → After Task 2 complete, can proceed

Task 7 (Implement Core Automation)
  → Independent, can start anytime
  → Benefits from: All proven theorems (more automation targets)
  → Phased approach allows incremental progress

Task 8 (Fix WorldHistory Universal Helper)
  → Independent, can run anytime
  → No blockers

Task 12 (Create Tactic Test Suite)
  → CONCURRENT WITH: Task 7 (Implement Core Automation)
  → Independent, can start anytime
  → Follows TDD approach (tests written before/alongside implementation)
  → Benefits from: Documentation/Development/TACTIC_DEVELOPMENT.md
```

**Parallel Opportunities**: Tasks 5, 7, 8, 12 can run in parallel. Task 6 must wait
for Task 2. Task 12 should be concurrent with Task 7 per TDD methodology.

### Low Priority Dependencies

```
Task 9 (Begin Completeness Proofs)
  → Independent, can start anytime
  → Benefits from: Task 2 (for proof techniques)
  → Benefits from: Task 5 (for metalogic patterns)
  → Large task, phased approach recommended

Task 10 (Create Decidability Module)
  → REQUIRES: Task 9 (completeness proofs for correctness)
  → Benefits from: Task 7 (automation for search)

Task 11 (Plan Layer 1/2/3 Extensions)
  → REQUIRES: Layer 0 completion (Tasks 1-8 complete)
  → Strategic planning, not implementation

Task 13 (Create Proof Strategy Documentation)
  → Independent, can run anytime
  → No blockers
  → Benefits from: Completed proofs (more examples to document)
  → Pedagogical value for new users, students, researchers
```

**Parallel Opportunities**: Tasks 9 and 13 can run in parallel. Task 10 requires
Task 9 complete. Task 11 requires Layer 0 completion.

### Execution Waves (Optimal Ordering)

**Wave 1** (High Priority, Parallel):
- Task 1: Fix CI Flags (1-2 hours)
- Task 2: Add Propositional Axioms (10-15 hours)
- Task 3: Complete Archive Examples (5-10 hours)

**Wave 2** (Medium Priority, After Wave 1):
- Task 5: Complete Soundness Proofs (15-20 hours) - Can run parallel with 6, 7, 8, 12
- Task 6: Complete Perpetuity Proofs (20-30 hours) - AFTER Task 2, parallel with 5, 7, 8, 12
- Task 7: Implement Core Automation (40-60 hours, phased) - Can run parallel with 5, 6, 8, 12
- Task 8: Fix WorldHistory (1-2 hours) - Can run parallel with 5, 6, 7, 12
- Task 12: Create Tactic Test Suite (10-15 hours) - CONCURRENT with Task 7, parallel with 5, 6, 8

**Wave 3** (Low Priority, After Wave 2):
- Task 9: Begin Completeness Proofs (70-90 hours, phased) - Can start anytime, parallel with 13
- Task 10: Create Decidability Module (40-60 hours) - AFTER Task 9
- Task 13: Create Proof Strategy Documentation (5-10 hours) - Can run anytime, parallel with 9

**Wave 4** (Future Planning, After Layer 0 Complete):
- Task 11: Plan Layer 1/2/3 Extensions (20-40 hours research)

### Critical Path Analysis

**Shortest path to Layer 0 completion**:
1. Task 2 (Add Propositional Axioms) - 10-15 hours
2. Task 6 (Complete Perpetuity Proofs) - 20-30 hours (depends on Task 2)
3. Task 5 (Complete Soundness Proofs) - 15-20 hours (parallel with Task 6 after Task 2)
4. Task 7 (Implement Core Automation) - 40-60 hours (parallel with Tasks 5-6)
5. Task 8 (Fix WorldHistory) - 1-2 hours (parallel with any)
6. Task 1 (Fix CI Flags) - 1-2 hours (parallel with any)
7. Task 3 (Complete Archive Examples) - 5-10 hours (parallel with any)

**Total Sequential Time**: ~93-140 hours
**Estimated Parallel Time**: ~70-95 hours (with 2-3 parallel tasks)
**Time Savings**: ~25-32% with parallelization

---

## CI Technical Debt ✓ RESOLVED

**Status**: COMPLETE (2025-12-02, Phase 1 - Task 1)

All `continue-on-error` flags have been removed from CI configuration per Task 1 completion.

### Audit Results

- [x] `lake test` flag removed - tests pass
- [x] `lake lint` flag removed - lint configured
- [x] `lake build :docs` flag removed - docs target works
- [x] GitHub Pages deployment flag removed - deployment functional
- [x] Build status badge added to README.md

**Note**: CI now fails fast on any test, lint, or build issues as intended.

---

## Progress Tracking

This section tracks task completion with date stamps. Mark tasks complete here when finished.

### Completed Tasks

**High Priority**:
- [x] **Task 1**: Fix CI Continue-on-Error Flags - COMPLETE (2025-12-02, Phase 1)
- [x] **Task 2**: Add Propositional Axioms - COMPLETE (2025-12-02, Phase 1)
- [x] **Task 3**: Complete Archive Examples - COMPLETE (2025-12-02, Phase 1)
- [x] **Task 4**: Create TODO.md - COMPLETE (2025-12-01)
- [x] **Task 5**: Fix Modal K and Temporal K Rule Implementations - COMPLETE (2025-12-03)

**Medium Priority**:
- [x] **Task 5b**: Temporal Duality Soundness - DOCUMENTED AS LIMITATION (2025-12-03)
- [x] **Task 6**: Complete Perpetuity Proofs - COMPLETE (2025-12-02, Phase 2)
- [x] **Task 7**: Implement Core Automation - PARTIAL COMPLETE (2025-12-03, 4/12 tactics)
- [x] **Task 8**: WorldHistory Universal Helper - COMPLETE (2025-12-03, zero sorry)
- [x] **Task 12**: Create Tactic Test Suite - COMPLETE (2025-12-03, 50 tests)

**Low Priority**:
- [ ] None yet

### In Progress

- **Task 7**: Remaining automation work (Aesop integration blocked, 8 tactics remaining)

### Completion Log

| Date | Task | Notes |
|------|------|-------|
| 2025-12-01 | Task 4: Create TODO.md | Initial TODO.md creation complete with all sections |
| 2025-12-02 | Task 1: Fix CI Flags (Phase 1) | All continue-on-error flags removed from CI configuration |
| 2025-12-02 | Task 2: Add Propositional Axioms (Phase 1) | K and S propositional axioms added, imp_trans and contraposition helpers proven |
| 2025-12-02 | Task 3: Archive Examples (Phase 1) | ModalProofs.lean and TemporalProofs.lean created |
| 2025-12-02 | Task 6: Perpetuity Proofs (Phase 2) | P1-P6 perpetuity principles proven using paper-based strategies |
| 2025-12-03 | Task 5: Soundness Axioms (Phase 3) | All 8 TM axioms proven sound (MT, M4, MB, T4, TA, TL, MF, TF). Transport lemmas in WorldHistory.lean and Truth.lean complete. 3 inference rules remain |
| 2025-12-03 | Task 8: WorldHistory (Phase 3) | Universal constructor documented as accepted limitation |
| 2025-12-03 | Phase 4: Documentation Sync | All documentation synchronized - TODO.md, IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md updated |
| 2025-12-03 | Paper Alignment Review | Aligned KNOWN_LIMITATIONS.md with paper §sec:Appendix. Discovered Modal K and Temporal K code-paper discrepancy. Created Task 5 and 5b. |
| 2025-12-03 | **Task 5: Modal K/Temporal K Fix** | **CRITICAL BUG FIXED**: Rule directions fixed in Derivation.lean to match paper (lines 1030, 1037). Soundness proofs complete for both rules (zero sorry). |
| 2025-12-03 | **Task 5b: Temporal Duality** | **COMPLETE**: Derivation-indexed approach (Approach D). `axiom_swap_valid` + `derivable_implies_swap_valid` in Truth.lean. Zero sorry in Soundness.lean. |
| 2025-12-03 | **Task 7: Core Automation** | 4/12 tactics implemented: apply_axiom, modal_t, tm_auto (native), assumption_search. Aesop integration blocked by Batteries/Truth.lean conflict. |
| 2025-12-03 | **Task 12: Tactic Test Suite** | 31 tests created in TacticsTest.lean (174 lines). Tests build successfully. Target: 50+ tests. |
| 2025-12-03 | **Task 8: WorldHistory** | COMPLETE: Removed sorry at line 119. Added universal_trivialFrame, universal_natFrame constructors. Refactored universal to require reflexivity proof. Zero sorry in WorldHistory.lean. |
| 2025-12-03 | **Task 12: Test Expansion** | COMPLETE: Expanded TacticsTest.lean from 31 to 50 tests. Added tm_auto coverage (4 tests), negative tests (8 tests), context tests (4 tests), edge cases (3 tests). |
| 2025-12-04 | **Task 15: Temporal Generalization** | COMPLETE: Generalized temporal domain from `Int` to `LinearOrderedAddCommGroup`. TaskFrame, WorldHistory, Truth, Validity all updated. Tests updated with explicit Int types. Archive/TemporalStructures.lean created with polymorphic examples. JPL paper alignment achieved. |

### Status Summary

**Layer 0 Completion Progress**:
- High Priority: 5/5 tasks complete (100%) ✓
- Medium Priority: 5/6 tasks complete (83%) (Task 14 pending)
- Low Priority: 1/5 tasks complete (20%) (Task 15 complete)
- **Overall**: 11/16 tasks complete or partial (69%)

**Implementation Plan Progress** ([Plan Link](.claude/specs/019_research_todo_implementation_plan/plans/001-research-todo-implementation-plan.md)):
- Wave 1 (Phase 1): COMPLETE - High priority foundations
- Wave 2 (Phases 2-4): COMPLETE - Perpetuity proofs, transport lemmas, documentation sync
- Wave 3 (Phases 5-7): NOT STARTED - Completeness proofs (120-190 hours)
- Wave 4 (Phase 8): NOT STARTED - Future work and layer planning

**Soundness & Automation Plan** ([Plan Link](.claude/specs/025_soundness_automation_implementation/plans/001-soundness-automation-implementation-plan.md)):
- Status: COMPLETE (2025-12-03)
- Phases 0-8: ALL COMPLETE (with documented limitations)
- Key achievements: Modal K/Temporal K rules fixed, 4 tactics implemented, 31 tests created

**Sorry Placeholder Resolution**:
- Total: 41 placeholders identified (original count)
- Resolved: 40 (Truth.lean complete, all axiom proofs done, Perpetuity proofs done, Soundness rules done, Tactics implemented, WorldHistory universal fixed)
- Remaining: 1 (1 Tactics tm_auto_stub - native alternative exists)

**Missing Files**:
- Total: 3 files identified
- Created: 3 (ModalProofs.lean, TemporalProofs.lean, TacticsTest.lean)
- Remaining: 1 (Decidability.lean - low priority)

**Estimated Effort to Layer 0 Completion**:
- High Priority Tasks: COMPLETE ✓
- Medium Priority Tasks: COMPLETE ✓ (with documented limitations)
- **Remaining Work**: Future enhancements only (Aesop integration 10-15h, full test suite 5-10h)
- **Total for full completion**: 15-25 hours

**Estimated Effort to Full Completion (including Low Priority)**:
- Low Priority Tasks: 135-200 hours (Completeness 70-90h, Decidability 40-60h, ~~Temporal Generalization 30-45h~~ DONE, Layer Planning 20-40h, Proof Strategies 5-10h)
- **Grand Total**: 150-225 hours

---

## How to Update This File

When completing a task:
1. Mark the task checkbox in the appropriate section (High/Medium/Low Priority)
2. Add completion date and notes to the Completion Log table
3. Update Status Summary percentages
4. Remove corresponding `sorry` entries from Sorry Placeholder Registry (if applicable)
5. Update Missing Files section (if files were created)
6. Update IMPLEMENTATION_STATUS.md with detailed module changes
7. Cross-reference with KNOWN_LIMITATIONS.md (remove workarounds if gaps fixed)

When adding new tasks:
1. Add to appropriate priority section with effort estimate
2. Document dependencies in Dependency Graph section
3. Update Status Summary with new task count
4. If task resolves `sorry` placeholders, link to Sorry Placeholder Registry

---

## Notes

- This TODO.md is the **central task tracking system** for Logos development
- For detailed module status and completion tracking, see [IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md)
- For comprehensive gap documentation and workarounds, see [KNOWN_LIMITATIONS.md](docs/KNOWN_LIMITATIONS.md)
- For system design and TM logic specification, see [ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Priority levels reflect blocking status and estimated timeline, not importance (all tasks are important for completeness)
- Effort estimates are conservative and may vary based on complexity during implementation
- Dependencies are explicitly tracked; always check Dependency Graph before starting a task
- CI technical debt should be resolved early to ensure reliable test feedback

**Last Updated**: 2025-12-04 (Task 15 added - Temporal order generalization to LinearOrderedAddCommGroup)
