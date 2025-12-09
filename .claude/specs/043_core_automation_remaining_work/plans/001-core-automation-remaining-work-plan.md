# Implementation Plan: Core Automation - Remaining Work

**Plan ID**: 043_core_automation_remaining_work/001
**Created**: 2025-12-08
**Status**: [COMPLETE]
**Workflow**: lean-plan (Lean tactic implementation)
**Complexity**: 3 (Medium - software engineering focus, not theorem proving)

---

## Metadata

**Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean`
**Lean Project**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker`
**Test File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Automation/TacticsTest.lean`
**Feature Type**: Software Engineering (Custom Tactic Implementation)
**Estimated Effort**: 30-40 hours (8 tactics remaining)

---

## Executive Summary

This plan completes the remaining 8/12 custom tactics for TM logic automation in the Logos project. The Aesop integration blocker has been resolved - all tactics can now be implemented using established elab/macro patterns. This is primarily a software engineering task (implementing Lean 4 metaprogramming code) rather than theorem proving.

**Completed** (4/12 tactics, 33%):
- `apply_axiom` macro
- `modal_t` macro
- `tm_auto` macro (Aesop integration)
- `assumption_search` elab

**Remaining** (8/12 tactics):
- 2 inference rule tactics (modal_k_tactic, temporal_k_tactic)
- 4 axiom tactics (modal_4_tactic, modal_b_tactic, temp_4_tactic, temp_a_tactic)
- 2 proof search tactics (modal_search, temporal_search)

**Key Resolution**: Aesop blocker resolved - AesopRules.lean provides 260 LOC of working forward chaining rules with no Batteries dependency issues.

---

## Research Context

**Research Report**: [001-lean-mathlib-research.md](../reports/001-lean-mathlib-research.md)

**Key Findings**:
1. Aesop integration working (260 LOC in AesopRules.lean, 18 tests passing)
2. Strong foundation: 4/12 tactics complete with 110+ tests
3. Clear patterns: elab for goal destructuring, macro for simple sequences
4. ProofSearch.lean provides 171 LOC of working infrastructure
5. Test coverage excellent: Already 110 tests, need 20-30 more targeted tests

**Blocker Resolution**: Original Batteries dependency issue **RESOLVED** - mathlib v4.14.0 includes Aesop with no compatibility issues.

---

## Implementation Phases

### Phase Routing Summary

| Phase | Type | Agent | Dependencies | Estimated Hours |
|-------|------|-------|--------------|-----------------|
| Phase 1 | software | implementer-coordinator | None | 8-12 |
| Phase 2 | software | implementer-coordinator | Phase 1 | 6-8 |
| Phase 3 | software | implementer-coordinator | Phase 2 | 6-8 |
| Phase 4 | software | implementer-coordinator | Phase 3 | 8-12 |
| Phase 5 | software | implementer-coordinator | Phases 1-4 | 4-6 |

**Total Estimated Effort**: 32-46 hours (with 10% contingency: 35-50 hours)

---

### Phase 1: Inference Rule Tactics [COMPLETE]

**Objective**: Implement modal_k_tactic and temporal_k_tactic using elab pattern with goal destructuring.

**Scope**:
- Complete modal_k_tactic elab (lines 216-241 in Tactics.lean)
- Complete temporal_k_tactic elab (lines 260-285 in Tactics.lean)
- Add 8 targeted tests to TacticsTest.lean

**Implementation Strategy**:

Both tactics follow the same elab pattern:
1. Get main goal and goal type via `getMainGoal` and `goal.getType`
2. Pattern match on `Derivable context formula` structure
3. Check if formula matches expected pattern (box/all_future)
4. Apply corresponding inference rule constructor (Derivable.modal_k / Derivable.temporal_k)
5. Replace goal with new subgoals via `replaceMainGoal`

**Files to Modify**:
- `Logos/Core/Automation/Tactics.lean` (complete stubs at lines 216-285)
- `LogosTest/Core/Automation/TacticsTest.lean` (add tests 78-85)

**Success Criteria**:
- [ ] modal_k_tactic applies Derivable.modal_k to goals of form `Derivable (□Γ) (□φ)` creating subgoal `Derivable Γ φ`
- [ ] temporal_k_tactic applies Derivable.temporal_k to goals of form `Derivable (FΓ) (Fφ)` creating subgoal `Derivable Γ φ`
- [ ] Both tactics provide clear error messages for malformed goals
- [ ] 8 new tests passing (basic application, with axioms, with non-empty contexts)
- [ ] No regressions in existing 110 tests
- [ ] Zero lint warnings

**Estimated Effort**: 8-12 hours

---

### Phase 2: Modal Axiom Tactics [COMPLETE]

**Objective**: Implement modal_4_tactic and modal_b_tactic using elab pattern with formula matching.

**Scope**:
- Complete modal_4_tactic elab (lines 306-339 in Tactics.lean)
- Complete modal_b_tactic elab (lines 354-385 in Tactics.lean)
- Add 12 tests to TacticsTest.lean (tests 84-95)

**Implementation Strategy**:

Modal axiom tactics pattern match on goal formula structure:
1. Get main goal and destructure to `Derivable context formula`
2. Pattern match on implication structure (`Formula.imp lhs rhs`)
3. Verify inner formula patterns match axiom schema
4. Use `isDefEq` to check formula consistency
5. Apply axiom via `mkAppM` and assign goal

**modal_4_tactic**: Matches `□φ → □□φ`, verifies both inner formulas are definitionally equal
**modal_b_tactic**: Matches `φ → □◇φ`, handles derived diamond operator expansion

**Files to Modify**:
- `Logos/Core/Automation/Tactics.lean` (complete stubs at lines 306-385)
- `LogosTest/Core/Automation/TacticsTest.lean` (tests 84-95 already exist as manual applications)

**Success Criteria**:
- [ ] modal_4_tactic applies Axiom.modal_4 to goals matching `□φ → □□φ` pattern
- [ ] modal_b_tactic applies Axiom.modal_b to goals matching `φ → □◇φ` pattern
- [ ] Both tactics handle atomic formulas, compound formulas, and nested structures
- [ ] Clear error messages for pattern mismatches
- [ ] 12 tests passing (basic, compound, atomic for each tactic)
- [ ] No regressions in existing tests
- [ ] Zero lint warnings

**Estimated Effort**: 6-8 hours

---

### Phase 3: Temporal Axiom Tactics [COMPLETE]

**Objective**: Implement temp_4_tactic and temp_a_tactic mirroring Phase 2 modal patterns for temporal operators.

**Scope**:
- Complete temp_4_tactic elab (lines 406-439 in Tactics.lean)
- Complete temp_a_tactic elab (lines 454-479 in Tactics.lean)
- Reuse Phase 2 test structure (tests 84-95 adapted for temporal)

**Implementation Strategy**:

Temporal axiom tactics mirror modal axiom pattern:
1. Pattern match on `Derivable context formula`
2. Destructure implication and verify temporal operator patterns
3. Use `isDefEq` for formula consistency checks
4. Apply temporal axioms via `mkAppM`

**temp_4_tactic**: Matches `Fφ → FFφ` (all_future transitivity)
**temp_a_tactic**: Matches `φ → F(Pφ)` (temporal accessibility, handles sometime_past derived operator)

**Files to Modify**:
- `Logos/Core/Automation/Tactics.lean` (complete stubs at lines 406-479)
- `LogosTest/Core/Automation/TacticsTest.lean` (tests 84-95 adapted for temporal operators)

**Success Criteria**:
- [ ] temp_4_tactic applies Axiom.temp_4 to goals matching `Fφ → FFφ` pattern
- [ ] temp_a_tactic applies Axiom.temp_a to goals matching `φ → F(Pφ)` pattern
- [ ] Both tactics handle nested temporal operators correctly
- [ ] Error messages consistent with Phase 2 modal tactics
- [ ] 12 tests passing (reusing test structure from Phase 2)
- [ ] No regressions in existing tests
- [ ] Zero lint warnings

**Estimated Effort**: 6-8 hours

---

### Phase 4: Proof Search Tactics [COMPLETE]

**Objective**: Implement modal_search and temporal_search tactics with MVP delegation to tm_auto.

**Scope**:
- Complete modal_search elab (lines 504-507 in Tactics.lean)
- Complete temporal_search elab (lines 523-526 in Tactics.lean)
- Add 10 proof search tests (tests 96-105)
- Document full recursive search design for future implementation

**Implementation Strategy**:

**MVP Approach** (4-6 hours):
- Keep existing delegation to tm_auto via `evalTactic`
- Add depth parameter validation (ensure depth > 0)
- Provide clear docstrings explaining MVP vs full implementation
- Document integration path with ProofSearch.bounded_search

**Optional Full Implementation** (4-6 hours additional):
- Integrate ProofSearch.bounded_search infrastructure
- Convert Bool results to proof terms in TacticM
- Implement backtracking with TacticM state management
- Add caching with ProofCache

**Files to Modify**:
- `Logos/Core/Automation/Tactics.lean` (complete stubs at lines 504-526)
- `LogosTest/Core/Automation/TacticsTest.lean` (tests 96-105)
- Optional: `Logos/Core/Automation/ProofSearch.lean` (proof term extraction)

**Success Criteria**:
- [ ] modal_search accepts depth parameter and delegates to tm_auto (MVP)
- [ ] temporal_search accepts depth parameter and delegates to tm_auto (MVP)
- [ ] Depth parameter validation prevents invalid inputs
- [ ] 10 tests passing (various depths, modal/temporal patterns)
- [ ] Documentation describes full recursive search design
- [ ] Optional: Full integration with ProofSearch.bounded_search
- [ ] No regressions in existing tests
- [ ] Zero lint warnings

**Estimated Effort**: 8-12 hours (4-6 for MVP, 4-6 for optional full implementation)

---

### Phase 5: Test Expansion and Documentation [COMPLETE]

**Objective**: Complete test coverage, add negative tests, update documentation.

**Scope**:
- Add 20-30 targeted tests for remaining tactics
- Implement negative test cases (malformed goals, error messages)
- Update TACTIC_DEVELOPMENT.md with working examples
- Update CLAUDE.md automation section
- Create performance benchmarks

**Implementation Strategy**:

**Test Expansion**:
1. Negative tests (5-10 tests): Verify error messages for malformed goals
2. Integration tests (5-10 tests): Combine multiple tactics in complex proofs
3. Performance tests (5-10 tests): Verify depth limits, timeout behavior

**Documentation Updates**:
1. TACTIC_DEVELOPMENT.md: Add elab pattern examples from Phases 1-4
2. CLAUDE.md: Update automation section with completed tactics
3. Create performance benchmark report (execution time, depth limits)

**Files to Modify**:
- `LogosTest/Core/Automation/TacticsTest.lean` (20-30 new tests)
- `Documentation/Development/TACTIC_DEVELOPMENT.md` (working examples)
- `CLAUDE.md` (automation section update)
- Create: `Documentation/Development/TACTIC_PERFORMANCE.md` (benchmark report)

**Success Criteria**:
- [ ] 20-30 new tests added (total 130+ tests)
- [ ] Negative tests verify error messages for all 8 new tactics
- [ ] Integration tests demonstrate combined tactic usage
- [ ] Performance benchmarks document execution time and depth limits
- [ ] TACTIC_DEVELOPMENT.md contains working elab examples
- [ ] CLAUDE.md automation section updated
- [ ] All 130+ tests passing
- [ ] Zero lint warnings
- [ ] Zero regressions

**Estimated Effort**: 4-6 hours

---

## Risk Assessment

**Low Risk** (Resolved or Mitigated):
- Aesop integration working (blocker resolved)
- Pattern matching well-understood (4 tactics complete)
- Test infrastructure mature (110 tests passing)
- ProofSearch infrastructure available (171 LOC)

**Medium Risk**:
- Derived operator handling complexity (modal_b, temp_a)
- Proof term construction for recursive search (Phase 4 full implementation)
- Performance optimization for deep proofs

**Mitigation Strategies**:
1. Implement MVP versions first (delegation to tm_auto for proof search)
2. Test incrementally after each tactic completion
3. Use existing helper functions (is_box_formula, extract_from_box, etc.)
4. Document complex patterns in TACTIC_DEVELOPMENT.md
5. Defer full recursive search to future iteration if time-constrained

---

## Implementation Notes

### Metaprogramming Patterns

**Pattern A: Macro-based Tactics** (Simple, already used):
```lean
macro "apply_axiom" : tactic =>
  `(tactic| (apply Derivable.axiom; refine ?_))
```

**Pattern B: Elab Pattern** (Recommended for Phases 1-3):
```lean
elab "modal_k_tactic" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType
  match goalType with
  | .app (.app (.const ``Derivable _) context) formula =>
    -- Pattern match and apply
```

**Pattern C: Direct TacticM** (Used in assumption_search, optional for Phase 4):
```lean
elab "assumption_search" : tactic => do
  let goal ← getMainGoal
  let lctx ← getLCtx
  -- Iterate and search
```

### Helper Functions Available

Already implemented in Tactics.lean:
- `is_box_formula`: Check if formula is `□φ`
- `is_future_formula`: Check if formula is `Fφ`
- `extract_from_box`: Extract `φ` from `□φ`
- `extract_from_future`: Extract `φ` from `Fφ`

### Test Organization

Current test coverage (110 tests):
- Phase 4 Tests (1-12): apply_axiom, modal_t
- Phase 5 Tests (13-18, 32-35): tm_auto
- Phase 6 Tests (19-23): assumption_search
- Helper Tests (24-31): Pattern matching utilities
- Phase 8-10 Tests (36-50): Negative tests, edge cases
- Phase 5 Groups (51-77): Inference rules, ProofSearch, Aesop

Target coverage (130+ tests):
- Add 20-30 targeted tests for new tactics (Phases 1-4)
- Expand negative test coverage
- Add integration tests combining multiple tactics

---

## Dependencies

**External Dependencies**:
- mathlib v4.14.0 (includes Aesop, no Batteries needed)
- Lean 4 (version from lean-toolchain)

**Internal Dependencies**:
- `Logos.Core.ProofSystem` (axioms and derivability)
- `Logos.Core.Automation.AesopRules` (forward chaining rules)
- `Logos.Core.Automation.ProofSearch` (optional for Phase 4 full implementation)

**Blocking**: None - all blockers resolved

---

## Success Criteria

**Phase 1-3 Complete When**:
- 6 tactics implemented (modal_k, temporal_k, modal_4, modal_b, temp_4, temp_a)
- 40+ new tests passing (total 150+ tests)
- No regressions in existing 110 tests
- Documentation updated with working elab examples

**Phase 4-5 Complete When**:
- 8 tactics total implemented (100% of remaining work)
- 60+ new tests passing (total 170+ tests)
- Performance benchmarks documented
- TACTIC_DEVELOPMENT.md comprehensive
- Zero lint warnings

**Full Task 7 Complete When**:
- 12/12 tactics implemented (100% completion)
- 130+ tests passing
- Zero sorry placeholders in Tactics.lean
- Ready for Archive/ example integration
- Documentation updated (CLAUDE.md, TACTIC_DEVELOPMENT.md)

---

## References

### Primary Sources
- [Lean 4 Metaprogramming Book](https://leanprover-community.github.io/lean4-metaprogramming-book/)
- [Tactics Chapter](https://leanprover-community.github.io/lean4-metaprogramming-book/main/09_tactics.html)
- [Mathlib4 Metaprogramming for Dummies](https://github.com/leanprover-community/mathlib4/wiki/Metaprogramming-for-dummies)
- [Aesop Documentation](https://github.com/leanprover-community/aesop)

### Project Files
- `Logos/Core/Automation/Tactics.lean` (175 LOC, 4 working tactics)
- `Logos/Core/Automation/AesopRules.lean` (260 LOC, Aesop integration)
- `Logos/Core/Automation/ProofSearch.lean` (485 LOC, search infrastructure)
- `LogosTest/Core/Automation/TacticsTest.lean` (670 LOC, 110 tests)
- `TODO.md` (Task 7 lines 58-88)

### Documentation
- `Documentation/Development/TACTIC_DEVELOPMENT.md` (tactic development guide)
- `Documentation/Development/LEAN_STYLE_GUIDE.md` (coding conventions)
- `CLAUDE.md` (Section 10 automation quick reference)

---

**Plan Status**: [NOT STARTED]
**Next Action**: Begin Phase 1 implementation (modal_k_tactic and temporal_k_tactic)
**Estimated Timeline**: 5-7 weeks at 6-8 hours/week
