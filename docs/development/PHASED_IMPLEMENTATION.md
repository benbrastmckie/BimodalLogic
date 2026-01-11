# Phased Implementation Roadmap for Logos Layer 0

## 1. Introduction

### Purpose

This document provides a systematic implementation strategy for completing Layer 0
(Core TM) of Logos, organizing tasks into execution waves with parallel task
opportunities and critical path analysis. The roadmap translates TODO.md tasks into
actionable phases with time-saving parallelization strategies.

### Implementation Scope

**Total Effort**:
- Sequential execution: 93-143 hours
- Parallel execution: 70-95 hours
- **Time Savings**: 25-32% with proper task ordering

**Layer 0 Completion Goals**:
- Fix CI reliability (Task 1)
- Complete propositional axioms (Task 2)
- Finish Archive examples (Task 3)
- Complete soundness proofs (Task 5)
- Complete perpetuity proofs (Task 6)
- Implement core automation (Task 7)
- Fix WorldHistory helper (Task 8)

**Out of Scope** (Layer 0):
- Completeness proofs (Task 9) - 70-90 hours, Wave 3
- Decidability module (Task 10) - 40-60 hours, Wave 3
- Layer 1-3 planning (Task 11) - Wave 4

### How to Use This Roadmap

1. **Start with Wave 1**: All tasks are independent, can run in parallel
2. **Synchronize before Wave 2**: Task 2 must complete before Task 6
3. **Maximize parallelism**: Wave 2 has 4 parallel opportunities
4. **Monitor critical path**: Task 2 → Task 6 → Task 9 → Task 10 is longest path
5. **Track dependencies**: See Section 6 (Critical Path Analysis) for blocking
   relationships

## 2. Wave 1 - High Priority Foundation (16-30 hours, all parallel)

**Objective**: Establish reliable CI, complete foundational axioms, and finish
pedagogical examples. All tasks are independent and can run simultaneously.

**Completion Signal**: CI reliable, K/S axioms proven, Archive complete

### Task 1: Fix CI Flags (1-2 hours) - Independent

**Description**: Remove `continue-on-error: true` flags from CI configuration.

**Parallelization**: Independent, can run alongside Tasks 2 and 3.

**Steps**:
1. Audit `lake test` command (CI line 45)
2. Verify `lake lint` is configured (CI line 49)
3. Check `lake build :docs` target (CI line 77)
4. Test GitHub Pages deployment (CI line 86)
5. Add build status badge to README.md

**Dependencies**: None

**Outputs**: Reliable CI pipeline, build status badge

### Task 2: Add Propositional Axioms (10-15 hours) - Unblocks Wave 2 Task 6

**Description**: Add K and S propositional axioms, prove `imp_trans` and
`contraposition` helpers.

**Parallelization**: Independent, but blocks Task 6 (Perpetuity P4-P6).

**Steps**:
1. Add K axiom: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
2. Add S axiom: `φ → (ψ → φ)`
3. Prove `imp_trans` helper (Perpetuity.lean:88)
4. Prove `contraposition` helper (Perpetuity.lean:139)
5. Update ProofSystem/Derivation.lean
6. Write tests in LogosTest/ProofSystem/AxiomsTest.lean
7. Update IMPLEMENTATION_STATUS.md axiom count (8 → 10)

**Dependencies**: None

**Outputs**: K/S axioms, proven helpers, unblocks Perpetuity P4-P6

### Task 3: Complete Archive Examples (5-10 hours) - Independent

**Description**: Create missing Archive example files (ModalProofs.lean,
TemporalProofs.lean).

**Parallelization**: Independent, can run alongside Tasks 1 and 2.

**Steps**:
1. Create `Archive/ModalProofs.lean` with S5 examples
2. Create `Archive/TemporalProofs.lean` with temporal reasoning examples
3. Update `Archive/Archive.lean` to re-export new modules
4. Write tests in `LogosTest/Archive/`
5. Update IMPLEMENTATION_STATUS.md Archive status (3/3 complete)

**Dependencies**: None

**Outputs**: Complete Archive documentation, pedagogical examples

### Wave 1 Summary

```
┌─────────────────────────────────────────────────────────────┐
│ Wave 1: High Priority Foundation                │
├─────────────────────────────────────────────────────────────┤
│ Total Effort: 16-30 hours                    │
│ Parallel Execution: 16-30 hours (longest task = Task 2)   │
│ Sequential Execution: 16-30 hours (sum of all tasks)    │
│ Time Savings: 0% (all tasks already parallel)       │
├─────────────────────────────────────────────────────────────┤
│ Task 1: Fix CI Flags (1-2 hours)              │
│ Task 2: Add Propositional Axioms (10-15 hours) [CRITICAL]  │
│ Task 3: Complete Archive Examples (5-10 hours)       │
└─────────────────────────────────────────────────────────────┘
```

**Critical Path Note**: Task 2 is on critical path (blocks Task 6 in Wave 2).
Prioritize Task 2 completion to avoid blocking Wave 2.

## 3. Wave 2 - Medium Priority Implementation (77-113 hours, partial parallelization)

**Objective**: Complete soundness proofs, perpetuity theorems, core automation, and
WorldHistory helper. Tasks 5, 7, 8 can run in parallel; Task 6 requires Task 2
completion.

**Completion Signal**: Soundness 100%, Perpetuity P1-P6 proven, 4 tactics implemented

### Task 5: Complete Soundness Proofs (15-20 hours) - Can run parallel with 6, 7, 8

**Description**: Prove soundness for TL, MF, TF axioms and modal_k, temporal_k,
temporal_duality rules.

**Parallelization**: Independent, can run alongside Tasks 6, 7, 8.

**Steps**:
1. Analyze frame constraints for TL, MF, TF axioms
2. Choose constraint architecture (Option A: add to TaskFrame, Option B: conditional
   axioms)
3. Prove TL, MF, TF axiom validity with frame constraints
4. Prove modal_k and temporal_k rule soundness
5. Prove temporal_duality soundness with semantic duality lemma
6. Remove all 15 `sorry` placeholders from Soundness.lean
7. Write tests for new soundness proofs
8. Update IMPLEMENTATION_STATUS.md Soundness status (60% → 100%)

**Dependencies**: None (but benefits from Task 2 propositional axioms for proof
techniques)

**Outputs**: Complete soundness proof, metalogic validation

### Task 6: Complete Perpetuity Proofs (20-30 hours) - REQUIRES Task 2

**Description**: Prove perpetuity principles P4-P6 using propositional helpers.

**Parallelization**: Requires Task 2 completion (propositional axioms). Can run in
parallel with Tasks 5, 7, 8 once Task 2 completes.

**Steps**:
1. Prove P4 (`◇▽φ → ◇φ`) using corrected contraposition
2. Develop modal-temporal interaction lemmas:
   - `□△` and `◇▽` interaction
   - `△◇` and `▽□` interaction
   - Nesting properties for box-future and diamond-past
3. Prove P5 (`◇▽φ → △◇φ`) from interaction lemmas
4. Prove P6 (`▽□φ → □△φ`) from interaction lemmas
5. Remove all 3 `sorry` placeholders (lines 225, 252, 280)
6. Write comprehensive tests for P4-P6
7. Update IMPLEMENTATION_STATUS.md Perpetuity status (50% → 100%)

**Dependencies**:
- **REQUIRES**: Task 2 (Add Propositional Axioms) - P4-P6 need propositional helpers
- **BENEFITS FROM**: Task 5 (Complete Soundness) - for proof techniques

**Outputs**: Complete perpetuity principles P1-P6

### Task 7: Implement Core Automation (40-60 hours, phased) - Can run parallel

**Description**: Implement 4 core tactics using LEAN 4's `Lean.Elab.Tactic` API.

**Parallelization**: Independent, can run alongside Tasks 5, 6, 8. Phased approach
allows incremental progress.

**Phased Implementation**:

**Phase 1** (15-20 hours): Basic Axiom Application
- Implement `apply_axiom` (generic axiom application, 8-10 hours)
- Implement `modal_t` (modal T axiom, 4-6 hours)
- Write tests for Phase 1 tactics
- Update IMPLEMENTATION_STATUS.md Automation (0% → 20%)

**Phase 2** (15-20 hours): Automated Search
- Implement `tm_auto` (Aesop-based automation, 15-20 hours)
- Integrate Phase 1 tactics into `tm_auto`
- Write tests for `tm_auto`
- Update IMPLEMENTATION_STATUS.md Automation (20% → 35%)

**Phase 3** (10-20 hours): Context Search
- Implement `assumption_search` (premise search, 8-12 hours)
- Write comprehensive tactic tests
- Update documentation (TACTIC_DEVELOPMENT.md)
- Update IMPLEMENTATION_STATUS.md Automation (35% → 50%)

**Dependencies**: None (can start anytime, benefits from all proven theorems)

**Outputs**: 4 working tactics, 40-50% automation coverage

### Task 8: Fix WorldHistory (1-2 hours) - Can run parallel with all

**Description**: Prove `respects_task` property for universal history helper.

**Parallelization**: Independent, can run alongside Tasks 5, 6, 7.

**Steps**:
1. Analyze universal history helper requirements
2. Prove `respects_task` property
3. Remove `sorry` at line 75 (WorldHistory.lean)
4. Add test case for universal history
5. Update IMPLEMENTATION_STATUS.md Semantics status

**Dependencies**: None

**Outputs**: Complete WorldHistory implementation

### Wave 2 Summary

```
┌─────────────────────────────────────────────────────────────┐
│ Wave 2: Medium Priority Implementation            │
├─────────────────────────────────────────────────────────────┤
│ Total Effort: 77-113 hours                   │
│ Parallel Execution: 40-60 hours (Task 7 is longest)     │
│ Sequential Execution: 77-113 hours (sum of all tasks)    │
│ Time Savings: 48-47% (parallelization of 4 tasks)      │
├─────────────────────────────────────────────────────────────┤
│ Task 5: Complete Soundness (15-20 hours) [PARALLEL]     │
│ Task 6: Complete Perpetuity (20-30 hours) [REQUIRES TASK 2]│
│ Task 7: Implement Automation (40-60 hours) [PARALLEL]    │
│ Task 8: Fix WorldHistory (1-2 hours) [PARALLEL]       │
└─────────────────────────────────────────────────────────────┘
```

**Synchronization Point**: Task 6 blocked until Task 2 (Wave 1) completes. Start
Tasks 5, 7, 8 immediately; start Task 6 as soon as Task 2 finishes.

## 4. Wave 3 - Low Priority Completion (130-190 hours)

**Objective**: Implement canonical model construction and prove completeness theorems
(weak and strong). This is long-term metalogic work requiring significant effort.

**Completion Signal**: Layer 0 metalogic complete (soundness + completeness proven)

### Task 9: Begin Completeness Proofs (70-90 hours, phased)

**Description**: Prove completeness theorems through canonical model construction.

**Parallelization**: Sequential phases recommended (complex interdependencies).

**Phased Implementation**:

**Phase 1** (20-30 hours): Maximal Set Properties
- Prove lindenbaum (maximal consistent extension)
- Prove maximal_consistent_closed (closure under MP)
- Prove maximal_negation_complete (negation completeness)
- Write tests for maximal set properties

**Phase 2** (20-30 hours): Canonical Model Construction
- Define canonical_task_rel from derivability
- Prove canonical_frame satisfies nullity and compositionality
- Define canonical_valuation from maximal sets
- Combine into canonical_model
- Write tests for canonical model components

**Phase 3** (20-30 hours): Truth Lemma and Completeness
- Define canonical_history for temporal operators
- Prove truth_lemma by induction on formula structure
- Prove weak_completeness (`⊨ φ → ⊢ φ`)
- Prove strong_completeness (`Γ ⊨ φ → Γ ⊢ φ`)
- Write comprehensive completeness tests

**Dependencies**: Benefits from Task 5 (soundness proof techniques)

**Outputs**: Complete completeness proofs, 11 `sorry` placeholders removed

### Task 10: Create Decidability Module (40-60 hours) - REQUIRES Task 9

**Description**: Implement decision procedure for TM satisfiability and validity.

**Parallelization**: Requires Task 9 completion (completeness infrastructure).

**Phased Implementation**:

**Phase 1** (15-20 hours): Decidability Infrastructure
- Create Logos/Decidability/Procedures.lean
- Define satisfiability decision algorithm
- Define validity decision algorithm via completeness

**Phase 2** (15-20 hours): Tableau Method
- Implement semantic tableau for TM
- Prove tableau soundness and completeness
- Write tests for tableau procedures

**Phase 3** (10-20 hours): Performance Optimization
- Optimize decision procedures for practical formulas
- Add caching for repeated subformulas
- Benchmark on test suite (target: <1 second for formulas with <10 operators)

**Dependencies**:
- **REQUIRES**: Task 9 (completeness proofs provide decidability foundation)

**Outputs**: Decision procedures, tableau method, performance benchmarks

### Wave 3 Summary

```
┌─────────────────────────────────────────────────────────────┐
│ Wave 3: Low Priority Completion                │
├─────────────────────────────────────────────────────────────┤
│ Total Effort: 110-150 hours                  │
│ Parallel Execution: 110-150 hours (sequential recommended)  │
│ Sequential Execution: 110-150 hours              │
│ Time Savings: 0% (sequential dependencies)          │
├─────────────────────────────────────────────────────────────┤
│ Task 9: Begin Completeness (70-90 hours) [SEQUENTIAL PHASES]│
│ Task 10: Decidability Module (40-60 hours) [REQUIRES TASK 9]│
└─────────────────────────────────────────────────────────────┘
```

**Blocking Relationship**: Task 10 blocked until Task 9 completes. Sequential
execution recommended for Task 9 phases due to complexity.

## 5. Wave 4 - Future Planning (20-40 hours)

**Objective**: Plan Layer 1 (Counterfactual Conditionals), Layer 2 (Epistemic
Operators), and Layer 3 (Normative Operators) extensions.

**Completion Signal**: Layer 1-3 roadmap documented, extension architecture defined

### Task 11: Plan Layer 1/2/3 Extensions (20-40 hours)

**Description**: Research and design extensions beyond core TM logic.

**Phased Planning**:

**Phase 1** (8-15 hours): Layer 1 Counterfactual Design
- Research Lewis counterfactual semantics
- Design grounding relation integration with task semantics
- Draft Layer 1 specification document

**Phase 2** (8-15 hours): Layer 2 Epistemic Design
- Research epistemic logic for bimodal systems
- Design knowledge/belief operator integration
- Draft Layer 2 specification document

**Phase 3** (4-10 hours): Layer 3 Normative Design
- Research deontic logic (obligation, permission)
- Design normative operator integration
- Draft Layer 3 specification document

**Dependencies**:
- **REQUIRES**: Wave 1-3 completion (Layer 0 finalization provides foundation)

**Outputs**: Layer 1-3 specification documents, extension roadmap

### Wave 4 Summary

```
┌─────────────────────────────────────────────────────────────┐
│ Wave 4: Future Planning                    │
├─────────────────────────────────────────────────────────────┤
│ Total Effort: 20-40 hours                   │
│ Parallel Execution: 20-40 hours (planning phases)      │
│ Sequential Execution: 20-40 hours              │
│ Time Savings: 0% (single task)                │
├─────────────────────────────────────────────────────────────┤
│ Task 11: Plan Layer 1/2/3 (20-40 hours) [REQUIRES WAVE 1-3]│
└─────────────────────────────────────────────────────────────┘
```

## 6. Critical Path Analysis

### Longest Path Identification

**Critical Path**: Task 2 → Task 6 → Task 9 → Task 10

Total time: 10-15h + 20-30h + 70-90h + 40-60h = **140-205 hours**

This path represents the longest sequence of dependent tasks. Any delay on critical
path tasks delays entire project completion.

### Critical Path Tasks

1. **Task 2 (Add Propositional Axioms)**: 10-15 hours
   - **Why critical**: Blocks Task 6 (Perpetuity P4-P6)
   - **Optimization**: Start immediately in Wave 1, prioritize completion

2. **Task 6 (Complete Perpetuity)**: 20-30 hours
   - **Why critical**: Indirect dependency for completeness proofs (theorem base)
   - **Optimization**: Start immediately after Task 2 completes

3. **Task 9 (Begin Completeness)**: 70-90 hours
   - **Why critical**: Blocks Task 10 (Decidability Module)
   - **Optimization**: Use phased approach (3 phases of 20-30 hours each)

4. **Task 10 (Create Decidability Module)**: 40-60 hours
   - **Why critical**: Final Layer 0 milestone
   - **Optimization**: Prepare infrastructure during Task 9

### Off-Critical-Path Tasks

These tasks are NOT on critical path and can run in parallel:

- Task 1 (Fix CI Flags): 1-2 hours - Independent
- Task 3 (Complete Archive): 5-10 hours - Independent
- Task 5 (Complete Soundness): 15-20 hours - Independent
- Task 7 (Implement Automation): 40-60 hours - Independent
- Task 8 (Fix WorldHistory): 1-2 hours - Independent

**Parallelization Strategy**: Start off-critical-path tasks alongside critical path
work to maximize throughput.

### Risk Factors

**High Risk** (could delay critical path):

1. **Propositional axiom proof complexity** (Task 2):
   - Risk: `imp_trans` and `contraposition` helpers harder than expected
   - Mitigation: Allocate 15 hours (high estimate), study Hilbert-style proof
     techniques first

2. **Completeness lemma difficulty** (Task 9):
   - Risk: Canonical model construction requires deep metalogic expertise
   - Mitigation: Use phased approach, study Blackburn et al. "Modal Logic" textbook,
     allocate full 90 hours

**Medium Risk** (off-critical-path delays):

1. **Automation implementation complexity** (Task 7):
   - Risk: LEAN 4 metaprogramming learning curve steeper than expected
   - Mitigation: Use phased approach, start with simple `apply_axiom` macro

### Optimization Opportunities

**Opportunity 1**: Start Task 7 (Automation) During Wave 1
- Task 7 is independent (40-60 hours)
- Can run alongside Wave 1 and Wave 2 tasks
- Reduces perceived project duration by running high-effort task in parallel

**Opportunity 2**: Overlap Task 6 Start with Task 2 Completion
- Task 6 only needs propositional helpers (Task 2 outputs)
- Can start Task 6 as soon as `imp_trans` and `contraposition` proven (not full
  Task 2)
- Saves 1-2 weeks of synchronization delay

**Opportunity 3**: Prepare Decidability Infrastructure During Task 9
- Task 10 infrastructure can be designed during Task 9 Phase 3
- Reduces Task 10 Phase 1 time from 15-20 hours to 10-15 hours

## 7. Parallel Execution Strategy

### Developer Allocation (3 Developers)

**Wave 1 Configuration** (1-2 week sprint):

```
Developer A: Task 2 (Add Propositional Axioms) - 10-15 hours [CRITICAL PATH]
Developer B: Task 3 (Complete Archive Examples) - 5-10 hours
Developer C: Task 1 (Fix CI Flags) - 1-2 hours, then assist Developer A
```

**Result**: All Wave 1 tasks complete in 10-15 hours (limited by Task 2).

**Wave 2 Configuration** (3-5 week sprint):

```
Developer A: Task 6 (Complete Perpetuity) - 20-30 hours [CRITICAL PATH]
Developer B: Task 7 (Implement Core Automation) - 40-60 hours [LONGEST]
Developer C: Task 5 (Complete Soundness) - 15-20 hours
Developer D (Optional): Task 8 (Fix WorldHistory) - 1-2 hours (can be absorbed)
```

**Result**: All Wave 2 tasks complete in 40-60 hours (limited by Task 7, longest
task).

**Synchronization Point**: Start Wave 2 only after Task 2 (Wave 1) completes to
unblock Task 6.

### Solo Developer Strategy

If working alone, prioritize critical path to minimize project duration:

**Week 1-2**: Task 2 (Propositional Axioms) - 10-15 hours [CRITICAL]
**Week 3-4**: Task 6 (Complete Perpetuity) - 20-30 hours [CRITICAL]
**Week 5-6**: Task 7 Phase 1 (apply_axiom, modal_t) - 15-20 hours
**Week 7-8**: Task 5 (Complete Soundness) - 15-20 hours
**Week 9-10**: Task 7 Phase 2-3 (tm_auto, assumption_search) - 25-40 hours
**Week 11**: Tasks 1, 3, 8 (Quick wins) - 7-14 hours

**Total**: 92-139 hours over 11 weeks (8-13 hours/week average)

### Time Savings Calculation

**Sequential Execution** (no parallelism):
- Wave 1: 16-30 hours
- Wave 2: 77-113 hours
- Total: 93-143 hours

**Parallel Execution** (3 developers):
- Wave 1: 10-15 hours (limited by Task 2)
- Wave 2: 40-60 hours (limited by Task 7, longest task)
- Total: 50-75 hours

**Time Savings**: (93-143h - 50-75h) / (93-143h) = **32-47% reduction**

**Parallel Execution** (solo developer, smart ordering):
- Critical path completed early
- Off-critical-path tasks done in remaining time
- Reduces perceived duration by tackling high-effort tasks early

## References

### TODO.md Task Details

- [TODO.md](../../TODO.md) - Comprehensive task tracking with dependencies
- TODO.md Dependency Graph (lines 701-805) - Full dependency visualization

### Best Practices Reports

- Report 021: LEAN 4 Modal Logic Implementation Best Practices, lines 479-675
  (Six Recommendations with Effort Estimates)
- Report 022: Documentation Improvement Implementation Plan (Wave Structure
  Inspiration)

### Logos Documentation

- [IMPLEMENTATION_STATUS.md](../project-info/IMPLEMENTATION_STATUS.md) - Module-by-
  module status tracking
- [IMPLEMENTATION_STATUS.md - Known Limitations](../project-info/IMPLEMENTATION_STATUS.md#known-limitations) - Gaps and workarounds
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

### Related Guides

- [TACTIC_DEVELOPMENT.md](../user-guide/TACTIC_DEVELOPMENT.md) - Tactic implementation patterns
- [METAPROGRAMMING_GUIDE.md](METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming
  fundamentals
