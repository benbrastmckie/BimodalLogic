# TODO Implementation Systematic Plan

## Metadata
- **Date**: 2025-12-02
- **Feature**: Systematic implementation of TODO.md tasks for Layer 0 (Core TM) completion
- **Scope**: Complete all 11 tasks tracked in TODO.md, organized in 4 phased waves with parallel execution opportunities
- **Estimated Phases**: 8
- **Estimated Hours**: 130-180 (parallel execution) / 223-333 (sequential with all low priority)
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [IN PROGRESS]
- **Complexity Score**: 285.5 (Base: 10 + Tasks: 55 + Files: 129 + Integrations: 25)
- **Structure Level**: 1 (main plan with expanded phases)
- **Expanded Phases**: [2, 3, 5, 6, 7, 8]
- **Research Reports**:
  - [TODO Implementation Systematic Plan](../reports/001-todo-implementation-systematic-plan.md)

## Overview

Logos has 11 well-documented tasks in TODO.md with 1/11 complete (9% overall). This plan provides a systematic phased approach to implementing all remaining tasks using 4 execution waves with parallel opportunities to reduce sequential time from 223-333 hours to 130-180 hours (25-32% time savings).

**Key Objectives**:
1. Complete high-priority blocking tasks (CI fixes, propositional axioms, archive examples)
2. Implement medium-priority enhancements (soundness, perpetuity, automation, WorldHistory fix)
3. Address low-priority long-term work (completeness, decidability, layer planning)
4. Maintain documentation consistency across TODO.md, IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md

**Critical Path**: Task 2 (Add Propositional Axioms, 10-15 hours) → Task 6 (Complete Perpetuity Proofs, 20-30 hours)

## Research Summary

Research findings from the TODO Implementation Systematic Plan report indicate:

1. **TODO.md Structure Quality**: Exceptionally well-organized with accurate sorry counts (41 placeholders verified), clear dependency tracking, and realistic effort estimates
2. **Critical Blocking Dependency**: Task 2 (Add Propositional Axioms) blocks Task 6 (Perpetuity P1-P2, P4-P6) - this is the ONLY blocking dependency in high/medium priority tasks
3. **Parallel Execution Opportunities**: 4 execution waves enable 25-32% time savings (170-252 hours sequential → 130-180 hours parallel)
4. **Documentation Consistency**: Perfect alignment between TODO.md, IMPLEMENTATION_STATUS.md, and KNOWN_LIMITATIONS.md
5. **Sorry Distribution**: 41 placeholders verified (15 in Soundness.lean, 14 in Perpetuity.lean, 8 in Tactics.lean, 3 in ProofSearch.lean, 1 in WorldHistory.lean)
6. **Missing Files**: 3 files genuinely missing (Archive/ModalProofs.lean, Archive/TemporalProofs.lean, Logos/Metalogic/Decidability.lean)
7. **CI Technical Debt**: 4 continue-on-error flags masking failures (lines 45, 49, 77, 86 in .github/workflows/ci.yml)

**Recommended Approach**: Execute tasks in 4 waves (Wave 1: High Priority parallel, Wave 2: Medium Priority parallel after Task 2, Wave 3: Completeness sequential, Wave 4: Future planning)

## Success Criteria

- [ ] All 10 remaining TODO.md tasks marked complete (1/11 already complete)
- [ ] Zero sorry placeholders in Layer 0 code (41 → 0)
- [ ] All 3 missing files created (Archive examples, Decidability module)
- [ ] CI continue-on-error flags removed (4 → 0)
- [ ] lake test passes with zero failures
- [ ] lake lint returns zero warnings
- [ ] TODO.md, IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md updated consistently after each task
- [ ] Layer 0 (Core TM) fully complete and stable
- [ ] Documentation accurate and synchronized

## Technical Design

### Architecture Overview

The implementation follows a phased wave execution strategy optimized for parallel development:

**Wave 1 (High Priority Foundations)**:
- Task 1: CI flag fixes (independent, 1-2 hours)
- Task 2: Propositional axioms (independent but critical path, 10-15 hours)
- Task 3: Archive examples (independent, 5-10 hours)
- **Parallelization**: All 3 tasks can run concurrently
- **Time**: 16-27 hours sequential, ~15 hours parallel

**Wave 2 (Medium Priority Enhancements)**:
- Task 5: Soundness proofs (independent, 15-20 hours)
- Task 6: Perpetuity proofs (REQUIRES Task 2, 20-30 hours)
- Task 7: Core automation (independent, phased 40-60 hours)
- Task 8: WorldHistory fix (independent, 1-2 hours)
- **Parallelization**: Tasks 5, 7, 8 concurrent with Task 6 after Task 2 complete
- **Time**: 77-112 hours sequential, ~40-60 hours parallel

**Wave 3 (Low Priority Completeness)**:
- Task 9: Completeness proofs (sequential 3 phases, 70-90 hours)
- Task 10: Decidability module (REQUIRES Task 9, 40-60 hours)
- **Parallelization**: None (sequential dependencies)
- **Time**: 110-150 hours sequential

**Wave 4 (Future Planning)**:
- Task 11: Layer 1/2/3 planning (20-40 hours research)
- **Time**: 20-40 hours

### Component Interactions

**Critical Dependency Chain**:
```
Task 2 (Propositional Axioms)
  ↓
  Unblocks: Perpetuity.lean:88 (imp_trans helper)
  Unblocks: Perpetuity.lean:139 (contraposition helper)
  ↓
Task 6 (Perpetuity P1-P2, P4-P6 proofs)
```

**Documentation Synchronization**:
```
After Each Task Completion:
  1. Update TODO.md task checkbox + completion date
  2. Update TODO.md Sorry Registry (remove resolved placeholders)
  3. Update TODO.md Progress Tracking percentages
  4. Update IMPLEMENTATION_STATUS.md module status
  5. Update KNOWN_LIMITATIONS.md (remove workarounds for fixed gaps)
```

### Standards Compliance

**TDD Enforcement** (from CLAUDE.md):
- Every code change requires tests first
- Run `lake test` before marking task complete
- Zero `#lint` warnings required

**Fail-Fast Philosophy**:
- Remove CI continue-on-error flags to expose failures immediately
- Functions fail immediately on invalid input

**Documentation Requirements**:
- Every public definition requires docstring
- Update ARCHITECTURE.md if design changes
- Maintain cross-reference consistency

**LEAN 4 Syntax Standards**:
- 100-char line limit
- 2-space indentation
- Flush-left declarations
- Use `by` for tactic proofs, `where` for local definitions

## Implementation Phases

### Phase 1: Wave 1 - High Priority Foundations (Parallel) [COMPLETE]
dependencies: []

**Objective**: Execute all high-priority tasks in parallel to establish foundational improvements (CI reliability, propositional reasoning infrastructure, documentation completeness)

**Complexity**: Medium

**Tasks**:
- [x] **Task 1.1**: Audit and fix CI continue-on-error flags
  - File: `.github/workflows/ci.yml` (lines 45, 49, 77, 86)
  - Audit `lake test` - remove flag if tests pass (line 45)
  - Audit `lake lint` - configure properly, remove flag if passing (line 49)
  - Test `lake build :docs` - verify target exists, remove flag if working (line 77)
  - Test GitHub Pages deployment - remove flag if successful (line 86)
  - Add build status badge to README.md
- [x] **Task 1.2**: Add propositional axioms K and S (CRITICAL PATH)
  - File: `Logos/ProofSystem/Axioms.lean`
  - Add `prop_k` axiom: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
  - Add `prop_s` axiom: `φ → (ψ → φ)`
  - Update `Logos/ProofSystem/Derivation.lean` with new axioms
  - Write tests in `LogosTest/ProofSystem/AxiomsTest.lean`
- [x] **Task 1.3**: Prove propositional helpers (removes 2 sorry)
  - File: `Logos/Theorems/Perpetuity.lean`
  - Prove `imp_trans` from K and S (remove sorry at line 88)
  - Prove `contraposition` from K and S (remove sorry at line 139)
  - Add tests for propositional helpers
- [x] **Task 1.4**: Create Archive/ModalProofs.lean
  - File: `Archive/ModalProofs.lean` (new)
  - S5 modal logic examples (T, 4, B axioms)
  - Derived modal theorem examples
  - Update `Archive/Archive.lean` re-exports
- [x] **Task 1.5**: Create Archive/TemporalProofs.lean
  - File: `Archive/TemporalProofs.lean` (new)
  - Temporal axiom examples (TA, TL, TF)
  - Temporal duality examples (past/future)
  - Modal-temporal interaction examples
- [x] **Task 1.6**: Update documentation for Wave 1 completion
  - Update TODO.md: Mark Tasks 1-3 complete with dates
  - Update TODO.md: Remove 2 sorry entries (lines 88, 139)
  - Update IMPLEMENTATION_STATUS.md: Axiom count 8 → 10, Archive status
  - Update KNOWN_LIMITATIONS.md: Remove propositional reasoning gap

**Testing**:
```bash
# Verify CI improvements
cd /home/benjamin/Documents/Philosophy/Projects/Logos
lake test  # Should pass (or flag at line 45 stays)
lake lint  # Should return zero warnings (or flag at line 49 stays)
lake build :docs  # Should succeed (or flag at line 77 stays)

# Verify propositional axioms
lake test LogosTest.ProofSystem.AxiomsTest  # New propositional axiom tests
lake test LogosTest.Theorems.PerpetuityTest  # Helper tests

# Verify Archive examples
lake build Archive.ModalProofs
lake build Archive.TemporalProofs

# Verify sorry count decreased
grep -r "sorry" Logos/ --include="*.lean" | wc -l  # Expected: 39 (41 - 2)
```

**Expected Duration**: 16-27 hours sequential, ~15 hours parallel (bottleneck is Task 1.2-1.3)

---

### Phase 2: Wave 2 Task 6 - Complete Perpetuity Proofs [IN PROGRESS]
dependencies: [1]

**⚠️ PLAN SUPERSEDED**: Original plan replaced by research-based approach incorporating proof strategies from TM logic paper

**Objective**: Complete perpetuity principle proofs P4-P6 using paper-based proof strategies (removes 3 sorry)

**Complexity**: Medium (downgraded from High due to simplified approach)

**Summary**: Prove perpetuity principles P4-P6 using direct derivations from the original TM logic paper. P4 proven by contraposition of P3, P5 uses MB+TF axioms with `possibility_persists` lemma, P6 has multiple proof approaches from paper. Simplified from 4 modal-temporal lemmas to 2 propositional helpers. Removes 3 sorry placeholders from Perpetuity.lean.

**Expected Duration**: 13-20 hours (reduced from 20-30 hours, 35% time savings)

**Original Plan** (SUPERSEDED): [Phase 2 Details](phase_2_wave2_task6_complete_perpetuity_proofs.md)
**New Plan** (ACTIVE): [TM Perpetuity Paper Research Plan](../../020_tm_perpetuity_paper_research/plans/001-tm-perpetuity-paper-research-plan.md)

**Key Improvements**:
- Direct paper-based proof strategies from §3.2 (Bimodal Logic)
- P4: Simple contraposition of P3 applied to `¬φ`
- P5: `possibility_persists` lemma using MB + TF axioms
- P6: Multiple approaches from paper's "equivalent to P5" claim
- Semantic backing from Corollary 2.11 (all P1-P6 validated)
- Only 2 propositional helpers needed (not 4 modal-temporal lemmas)

---

### Phase 3: Wave 2 Parallel - Soundness, Automation, WorldHistory [IN PROGRESS]
dependencies: [1]

**Objective**: Execute Tasks 5, 7, 8 in parallel (can run concurrently with Phase 2)

**Complexity**: High

**Summary**: Prove remaining soundness axioms (TL, MF, TF) and rules, implement core automation tactics using LEAN 4 metaprogramming, and fix WorldHistory universal helper. Expanded into 3 independent sub-phases (Soundness, Automation, WorldHistory) for parallel execution. Removes 16 sorry placeholders.

**Expected Duration**: 56-82 hours sequential, ~40-60 hours parallel (Tasks 5, 7, 8 concurrent)

**For detailed tasks and implementation**, see [Phase 3 Details](phase_3_wave2_parallel_soundness_automation_worldhistory.md)

---

### Phase 4: Wave 2 Completion - Documentation Sync [NOT STARTED]
dependencies: [2, 3]

**Objective**: Synchronize all documentation after Wave 2 completion and verify Layer 0 High/Medium Priority complete

**Complexity**: Low

**Tasks**:
- [ ] **Task 4.1**: Verify all Wave 2 tasks complete
  - Confirm Task 5 (Soundness) complete: 0 sorry in Soundness.lean
  - Confirm Task 6 (Perpetuity) complete: 0 sorry in Perpetuity.lean
  - Confirm Task 7 (Automation) Phase 1-3 complete: 3-4 tactics implemented
  - Confirm Task 8 (WorldHistory) complete: 0 sorry in WorldHistory.lean
- [ ] **Task 4.2**: Update TODO.md comprehensive status
  - Mark Tasks 5-8 complete with completion dates
  - Update Status Summary: High Priority 4/4 (100%), Medium Priority 4/4 (100%)
  - Update Sorry Placeholder Resolution: 41 → 22 (19 resolved from Wave 2)
  - Update Estimated Effort: High/Medium complete, Low Priority 130-190 hours remaining
- [ ] **Task 4.3**: Update IMPLEMENTATION_STATUS.md module status
  - Soundness: 60% → 100% (all axioms and rules proven)
  - Perpetuity: 50% → 100% (P1-P6 all proven)
  - Automation: 0% → 40-50% (3-4 core tactics implemented)
  - Semantics: Note WorldHistory.lean 1 sorry → 0 sorry
- [ ] **Task 4.4**: Update KNOWN_LIMITATIONS.md gaps
  - Remove Section 1 (Metalogic Soundness Gaps) - now complete
  - Remove Section 3 propositional gaps - now complete
  - Remove perpetuity P4-P6 workarounds - now complete
  - Update Section 4 (Automation) to reflect implemented tactics
- [ ] **Task 4.5**: Run comprehensive verification
  - Run `lake test` - all tests should pass
  - Run `lake lint` - zero warnings expected
  - Run `lake build` - clean build expected
  - Verify sorry count: 22 remaining (ProofSearch.lean:3 + Completeness.lean:11 axioms + Tactics.lean:8 stubs)
- [ ] **Task 4.6**: Generate Layer 0 High/Medium Priority completion report
  - Document completion milestone in TODO.md
  - Create summary of Wave 1-2 achievements
  - Note remaining work (Wave 3-4: Low Priority tasks)

**Testing**:
```bash
# Comprehensive Layer 0 verification
cd /home/benjamin/Documents/Philosophy/Projects/Logos

# Verify build
lake build

# Verify tests
lake test

# Verify lint
lake lint

# Verify sorry count
echo "Remaining sorry count: $(grep -r 'sorry' Logos/ --include='*.lean' | wc -l)"
# Expected: 22 (3 ProofSearch + 11 Completeness axioms + 8 Tactics stubs)

# Verify documentation consistency
grep "Status Summary" TODO.md  # Should show High: 4/4, Medium: 4/4
grep "Overall" TODO.md  # Should show 8/11 (73%)
```

**Expected Duration**: 2-4 hours

---

### Phase 5: Wave 3 Phase 1 - Lindenbaum Lemma and Maximal Sets [NOT STARTED]
dependencies: [4]

**Objective**: Begin completeness proofs with Lindenbaum lemma and maximal consistent set properties (first phase of 3-phase completeness work)

**Complexity**: High

**Summary**: Prove Lindenbaum lemma using Zorn's lemma to extend consistent sets to maximal consistent sets. Prove closure and negation completeness properties. First of three sequential completeness proof phases. Replaces 3 axiom declarations with proofs.

**Expected Duration**: 20-30 hours

**For detailed tasks and implementation**, see [Phase 5 Details](phase_5_wave3_phase1_lindenbaum_lemma_maximal_sets.md)

---

### Phase 6: Wave 3 Phase 2 - Canonical Model Construction [NOT STARTED]
dependencies: [5]

**Objective**: Construct canonical model components (task relation, frame, valuation, model)

**Complexity**: High

**Summary**: Build canonical model from maximal consistent sets. Define canonical task relation from derivability, construct frame proving nullity and compositionality, define valuation from atom membership, and assemble complete model. Integrates task semantics constraints into standard modal canonical model construction. Replaces 4 axiom declarations.

**Expected Duration**: 20-30 hours

**For detailed tasks and implementation**, see [Phase 6 Details](phase_6_wave3_phase2_canonical_model_construction.md)

---

### Phase 7: Wave 3 Phase 3 - Truth Lemma and Completeness Theorems [NOT STARTED]
dependencies: [6]

**Objective**: Prove truth lemma and both completeness theorems (weak and strong), completing all metalogic properties

**Complexity**: Very High

**Summary**: Culmination of completeness proof. Define canonical history for temporal operators with convex time sets, prove truth lemma by structural induction (6 cases: atom, bot, imp, box, past, future), derive weak and strong completeness theorems. Most complex phase with detailed case analysis for modal-temporal interactions. Completes all 11 axiom declarations.

**Expected Duration**: 20-30 hours

**For detailed tasks and implementation**, see [Phase 7 Details](phase_7_wave3_phase3_truth_lemma_completeness_theorems.md)

---

### Phase 8: Wave 4 - Future Work and Layer Planning [NOT STARTED]
dependencies: [7]

**Objective**: Complete decidability module (Task 10) and plan Layer 1/2/3 extensions (Task 11), finalizing all TODO.md tasks

**Complexity**: High

**Summary**: Implement tableau-based decision procedure for TM logic satisfiability checking with EXPTIME/PSPACE complexity analysis. Design architectural roadmaps for three extension layers: counterfactuals (would/might operators), epistemics (knowledge/belief), and normatives (obligation/permission). Expanded into 2 sub-phases (Decidability and Layer Planning) for independent execution. Completes all 11 TODO.md tasks.

**Expected Duration**: 60-100 hours (40-60 hours Task 10 + 20-40 hours Task 11)

**For detailed tasks and implementation**, see [Phase 8 Details](phase_8_wave4_future_work_layer_planning.md)

---

## Testing Strategy

### Overall Test Approach

**Test-Driven Development**:
- Write failing tests BEFORE implementation for each task
- Verify tests pass after implementation
- Maintain 85%+ overall test coverage (target from CLAUDE.md)

**Test Organization**:
- Unit tests in `LogosTest/` mirroring `Logos/` structure
- Integration tests in `LogosTest/Integration/`
- Metalogic property tests in `LogosTest/Metalogic/`

**Coverage Targets** (from CLAUDE.md):
- Overall: ≥85%
- Metalogic: ≥90%
- Automation: ≥80%
- Error Handling: ≥75%

### Phase-Specific Testing

**Phase 1 (Wave 1 High Priority)**:
```bash
lake test LogosTest.ProofSystem.AxiomsTest  # New propositional axioms
lake test LogosTest.Theorems.PerpetuityTest  # Propositional helpers
lake build Archive.ModalProofs  # Archive examples
lake build Archive.TemporalProofs
```

**Phase 2 (Wave 2 Task 6 Perpetuity)**:
```bash
lake test LogosTest.Theorems.PerpetuityTest  # P4-P6 proofs
```

**Phase 3 (Wave 2 Parallel Tasks 5, 7, 8)**:
```bash
lake test LogosTest.Metalogic.SoundnessTest  # Soundness proofs
lake test LogosTest.Automation.TacticsTest  # Automation tactics
lake test LogosTest.Semantics.WorldHistoryTest  # WorldHistory fix
```

**Phase 4 (Wave 2 Completion)**:
```bash
lake test  # Full test suite
lake lint  # Zero warnings
lake build  # Clean build
```

**Phases 5-7 (Wave 3 Completeness)**:
```bash
lake test LogosTest.Metalogic.CompletenessTest  # Each phase
```

**Phase 8 (Wave 4 Future Work)**:
```bash
lake test LogosTest.Metalogic.DecidabilityTest  # Decidability
lake test  # Final full verification
```

### Verification Commands

**After Each Phase**:
```bash
# Verify build
lake build

# Verify tests pass
lake test

# Verify lint clean
lake lint

# Verify sorry count decreasing
echo "Sorry count: $(grep -r 'sorry' Logos/ --include='*.lean' | wc -l)"

# Verify documentation consistency
diff <(grep -A5 "Status Summary" TODO.md) <(grep -A5 "Quick Summary" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
```

## Documentation Requirements

### Files Requiring Updates After Each Phase

**After Each Task Completion**:
1. **TODO.md**:
   - Mark task checkbox in priority section
   - Add completion date to Completion Log
   - Update Status Summary percentages
   - Remove resolved sorry entries from Sorry Placeholder Registry
   - Update Missing Files section if files created

2. **IMPLEMENTATION_STATUS.md**:
   - Update module percentages (Soundness, Perpetuity, Completeness, Automation, etc.)
   - Update "Last Updated" date
   - Add notes about implementation details if significant

3. **KNOWN_LIMITATIONS.md**:
   - Remove workarounds for fixed gaps
   - Update gap sections if limitations removed
   - Add notes about remaining gaps if any

4. **ARCHITECTURE.md** (if applicable):
   - Update if design changes (frame constraints, canonical model, etc.)
   - Document new architectural decisions

5. **CLAUDE.md** (if applicable):
   - Update if workflow changes
   - Update if standards change

### Documentation Consistency Verification

**After Each Phase**:
```bash
# Verify TODO.md task counts match
grep "tasks complete" TODO.md

# Verify IMPLEMENTATION_STATUS.md module percentages align
grep "Status.*Complete" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

# Verify KNOWN_LIMITATIONS.md gaps align with sorry counts
grep -c "sorry" Logos/ --include="*.lean"
grep "Remaining.*sorry" Documentation/ProjectInfo/KNOWN_LIMITATIONS.md
```

### Final Documentation Deliverables

**Upon Full Completion (Phase 8)**:
- [ ] TODO.md shows 11/11 tasks complete (100%)
- [ ] IMPLEMENTATION_STATUS.md shows all modules 100% complete
- [ ] KNOWN_LIMITATIONS.md shows zero gaps (or documents accepted limitations)
- [ ] ARCHITECTURE.md updated with all design decisions
- [ ] Release notes prepared for Layer 0 completion
- [ ] README.md updated with completion milestone

## Dependencies

### External Dependencies

**Build System**:
- LEAN 4 toolchain (version from `lean-toolchain` file)
- Lake build system

**Testing**:
- LEAN 4 test framework
- Lake test command

**Linting**:
- LEAN 4 linter
- Lake lint command

**Documentation**:
- LEAN 4 documentation generator
- Lake docs target (`:docs`)

### Internal Dependencies

**Critical Blocking Chain**:
- Phase 1 Task 1.2-1.3 (Propositional Axioms) → Phase 2 (Perpetuity P4-P6)

**Sequential Dependencies**:
- Phase 5 → Phase 6 → Phase 7 (Completeness 3-phase sequence)
- Phase 7 → Phase 8 Task 8.1-8.4 (Completeness required for Decidability correctness)

**Phase Dependencies**:
- Wave 2 Phases (2, 3) depend on Wave 1 completion (Phase 1)
- Wave 3 Phases (5, 6, 7) can begin after Wave 2 but benefit from full Layer 0 stability
- Wave 4 Phase (8) requires Layer 0 completion for Layer 1/2/3 planning

### Parallel Execution Opportunities

**Wave 1 (Phase 1)**: All 3 tasks (1, 2, 3) can run in parallel
**Wave 2 (Phases 2, 3)**: Phase 2 (Task 6) and Phase 3 (Tasks 5, 7, 8) can run in parallel after Phase 1 complete
**Wave 3 (Phases 5, 6, 7)**: Sequential (no parallelization due to Completeness phase dependencies)
**Wave 4 (Phase 8)**: Task 10 and Task 11 could theoretically run in parallel, but Task 11 planning benefits from Task 10 completion

---

## Notes

**Complexity Score Calculation**: 285.5 = Base(10) + Tasks(11 × 5 = 55) + Files(43 × 3 = 129) + Integrations(5 × 5 = 25)

**Structure Level**: 0 (single file) chosen despite high complexity score because this is a meta-plan coordinating existing TODO.md tasks rather than implementing a single cohesive feature. Using `/expand` during implementation is recommended if individual phases become too large.

**Time Estimates**:
- **Sequential**: 223-333 hours (all tasks sequential)
- **Parallel (2-3 developers)**: 130-180 hours (optimal parallelization)
- **Layer 0 Only (High/Medium Priority)**: 93-143 hours

**Critical Success Factors**:
1. Complete Task 2 (Propositional Axioms) early to unblock Task 6
2. Maintain documentation consistency after EVERY task completion
3. Run verification commands after each phase
4. Use `/todo` command to automate TODO.md updates
5. Follow TDD strictly (tests first, implementation second)

**Risk Mitigation**:
- **Risk**: Completeness proofs (Task 9) may take longer than estimated (70-90 hours)
  - **Mitigation**: Phased approach allows progress tracking and early issue detection
- **Risk**: Frame constraints for soundness (Task 5) may be complex
  - **Mitigation**: Option B (document as conditional) available if constraints too difficult
- **Risk**: Automation tactics (Task 7) require LEAN 4 meta-programming expertise
  - **Mitigation**: Phased approach (3 phases) allows learning curve and incremental progress

**Post-Completion**:
- All 41 sorry placeholders resolved
- All 3 missing files created
- CI continue-on-error flags removed
- Layer 0 (Core TM) fully complete and stable
- Ready for Layer 1/2/3 extensions
