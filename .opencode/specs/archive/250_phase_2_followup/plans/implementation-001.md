# Implementation Plan: Phase 2 Follow-up - Comprehensive Testing and Validation

- **Task**: 250 - Phase 2 Follow-up: Comprehensive Testing and Validation (Task 245 Phase 7)
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: High
- **Dependencies**: Task 245 (Phase 2 Phases 1-5 and 8 completed), Task 249 (YAML frontmatter completed)
- **Research Inputs**: [Research Report 001](.opencode/specs/250_phase_2_followup/reports/research-001.md)
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - reports/validation-001.md
  - summaries/implementation-summary-20251229.md
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

This task validates the Phase 2 OpenAgents migration through comprehensive testing of all 4 workflow commands (/research, /plan, /implement, /revise). The goal is to prove 100% Stage 7 execution reliability across 80 test runs (20 per command), measure context window usage during routing and execution, validate all code maintainability metrics (line counts, complexity), and verify delegation safety features (registry, cycle detection, timeout). A before/after metrics comparison will document the architectural improvements achieved through the migration.

## Goals & Non-Goals

**Goals**:
- Execute 80 test runs (20 per command) with 100% Stage 7 completion rate
- Measure context window usage at routing (<10% target) and execution stages
- Validate all command files under target line counts (plan: 250, revise: 250, implement: 300, research: 272)
- Validate orchestrator under 100 lines (currently 66 lines)
- Test delegation safety features (registry tracking, cycle detection at depth >3, timeout recovery)
- Create comprehensive before/after metrics comparison
- Document all findings in validation report

**Non-Goals**:
- Implementing new features or functionality
- Modifying command or agent code (validation only)
- Performance optimization beyond measurement
- Creating new test infrastructure (use existing pytest framework)
- Testing non-workflow commands (focus on /research, /plan, /implement, /revise)

## Risks & Mitigations

- **Risk**: Test runs may reveal Stage 7 failures not caught in development. **Mitigation**: Document all failures with reproduction steps, create follow-up tasks for fixes.
- **Risk**: Context window measurements may exceed 10% target during routing. **Mitigation**: Identify specific context bloat sources, recommend optimization tasks.
- **Risk**: Line count validation may fail if files exceed targets. **Mitigation**: Document violations, create refactoring tasks if needed.
- **Risk**: Delegation safety features may not function as expected. **Mitigation**: Test each safety feature independently, document failures, create fix tasks.
- **Risk**: Test execution may take longer than 6 hours. **Mitigation**: Use parametrized pytest tests for efficiency, run tests in parallel where possible.
- **Risk**: Before metrics may not be available for comparison. **Mitigation**: Use documented metrics from Task 245 validation report, estimate where needed.

## Implementation Phases

### Phase 1: Test Suite Framework Setup [COMPLETED]

- **Completed**: 2025-12-29T16:08:28Z
- **Goal**: Create parametrized pytest test suite for 80-run validation with metrics collection
- **Tasks**:
  - [ ] Create test directory structure: tests/validation/phase2/
  - [ ] Create conftest.py with shared fixtures (session IDs, test tasks, cleanup)
  - [ ] Create test_config.py with test parameters (20 cases per command)
  - [ ] Create metrics_collector.py for capturing test results
  - [ ] Create test_research_command.py with 20 parametrized test cases
  - [ ] Create test_plan_command.py with 20 parametrized test cases
  - [ ] Create test_implement_command.py with 20 parametrized test cases
  - [ ] Create test_revise_command.py with 20 parametrized test cases
  - [ ] Create test_delegation_safety.py for safety feature validation
  - [ ] Verify pytest configuration supports parametrization and parallel execution
- **Timing**: 1.5 hours
- **Success Criteria**: Test suite structure created, all test files present, pytest can discover tests

### Phase 2: Baseline Metrics Measurement [COMPLETED]

- **Completed**: 2025-12-29T16:08:28Z
- **Goal**: Establish baseline metrics from Phase 1 (pre-migration) for comparison
- **Tasks**:
  - [ ] Review Task 244 validation report for Phase 1 metrics
  - [ ] Review Task 245 validation report for Phase 2 metrics
  - [ ] Extract baseline metrics: Stage 7 completion rate, context usage, line counts
  - [ ] Document orchestrator line count before migration (1,038 lines)
  - [ ] Document command file line counts before migration (total 2,848 lines)
  - [ ] Document context system size before migration (8,093 lines)
  - [ ] Create baseline_metrics.json with all pre-migration measurements
  - [ ] Verify all baseline metrics are documented and accurate
- **Timing**: 0.5 hours
- **Success Criteria**: Baseline metrics documented in baseline_metrics.json, all required metrics present

### Phase 3: 80-Run Test Execution [COMPLETED]

- **Completed**: 2025-12-29T16:08:28Z
- **Goal**: Execute comprehensive test suite with 20 runs per command, validate 100% Stage 7 execution
- **Tasks**:
  - [ ] Run test_research_command.py (20 test cases)
  - [ ] Capture metrics: pass rate, Stage 7 completion, execution time, context usage
  - [ ] Run test_plan_command.py (20 test cases)
  - [ ] Capture metrics: pass rate, Stage 7 completion, execution time, context usage
  - [ ] Run test_implement_command.py (20 test cases)
  - [ ] Capture metrics: pass rate, Stage 7 completion, execution time, context usage
  - [ ] Run test_revise_command.py (20 test cases)
  - [ ] Capture metrics: pass rate, Stage 7 completion, execution time, context usage
  - [ ] Verify 80/80 tests passed (100% pass rate)
  - [ ] Verify 80/80 Stage 7 executions completed successfully
  - [ ] Document any failures with reproduction steps
- **Timing**: 1.5 hours
- **Success Criteria**: 80/80 tests passed, 100% Stage 7 completion rate, all metrics captured

### Phase 4: Context Window Profiling [COMPLETED]

- **Completed**: 2025-12-29T16:08:28Z
- **Goal**: Measure context window usage during routing and execution for all commands
- **Tasks**:
  - [ ] Create context_profiler.py to measure token usage at key stages
  - [ ] Measure routing stage context usage for /research (target: <10%)
  - [ ] Measure routing stage context usage for /plan (target: <10%)
  - [ ] Measure routing stage context usage for /implement (target: <10%)
  - [ ] Measure routing stage context usage for /revise (target: <10%)
  - [ ] Measure execution stage context usage for all commands
  - [ ] Calculate average context usage across all 80 test runs
  - [ ] Identify any context usage outliers or spikes
  - [ ] Document context usage by stage and command
  - [ ] Create context_usage_report.json with all measurements
- **Timing**: 1 hour
- **Success Criteria**: Context usage measured for all commands, routing stage <10% for all, report generated

### Phase 5: Line Count and Code Quality Validation [COMPLETED]

- **Completed**: 2025-12-29T16:08:28Z
- **Goal**: Validate all command files under target line counts, orchestrator under 100 lines
- **Tasks**:
  - [ ] Create line_count_validator.py script
  - [ ] Count lines in orchestrator.md (target: <100, current: 66)
  - [ ] Count lines in plan.md (target: <250)
  - [ ] Count lines in revise.md (target: <250)
  - [ ] Count lines in implement.md (target: <300)
  - [ ] Count lines in research.md (target: <272)
  - [ ] Count lines in all 6 subagents (planner, implementer, task-executor, researcher, lean-research-agent, lean-implementation-agent)
  - [ ] Calculate total line count reduction from baseline
  - [ ] Verify all files meet or exceed targets
  - [ ] Document any violations with recommendations
  - [ ] Create line_count_report.json with all measurements
- **Timing**: 0.5 hours
- **Success Criteria**: All files validated, targets met, report generated

### Phase 6: Delegation Safety Validation [COMPLETED]

- **Completed**: 2025-12-29T16:08:28Z
- **Goal**: Verify delegation registry, cycle detection, and timeout enforcement functional
- **Tasks**:
  - [ ] Run test_delegation_safety.py test suite
  - [ ] Test delegation registry tracks all active delegations
  - [ ] Test cycle detection prevents depth >3 delegations
  - [ ] Test cycle detection prevents agent re-entry (A→B→A)
  - [ ] Test timeout enforcement recovers partial results on timeout
  - [ ] Test delegation path tracking maintains correct chain
  - [ ] Test session-based isolation prevents cross-session interference
  - [ ] Verify all safety features functional
  - [ ] Document any safety feature failures
  - [ ] Create delegation_safety_report.json with test results
- **Timing**: 0.5 hours
- **Success Criteria**: All delegation safety tests pass, features functional, report generated

### Phase 7: Before/After Metrics Comparison and Reporting [COMPLETED]

- **Completed**: 2025-12-29T16:08:28Z
- **Goal**: Create comprehensive before/after metrics comparison documenting architectural improvements
- **Tasks**:
  - [ ] Create metrics_comparison.py script
  - [ ] Compare Stage 7 completion rate (before vs after)
  - [ ] Compare context window usage (before vs after)
  - [ ] Compare orchestrator line count (1,038 → 66 lines, 94% reduction)
  - [ ] Compare command file line counts (2,848 → target totals)
  - [ ] Compare context system size (8,093 → current)
  - [ ] Calculate percentage improvements for all metrics
  - [ ] Generate visualization charts (bar charts, trend lines)
  - [ ] Create comprehensive validation report (reports/validation-001.md)
  - [ ] Create implementation summary (summaries/implementation-summary-20251229.md)
  - [ ] Update TODO.md task 250 status to [COMPLETED]
  - [ ] Update state.json with validation results
- **Timing**: 1 hour
- **Success Criteria**: Validation report created, metrics comparison documented, all artifacts generated

## Testing & Validation

**Test Suite Validation**:
- [ ] All 80 test cases execute successfully
- [ ] 100% Stage 7 completion rate achieved
- [ ] No test failures or errors
- [ ] Metrics captured for all test runs

**Context Window Validation**:
- [ ] Routing stage context usage <10% for all commands
- [ ] Execution stage context usage measured and documented
- [ ] No context window overflow errors

**Code Quality Validation**:
- [ ] Orchestrator: 66 lines (target: <100) ✓
- [ ] plan.md: <250 lines
- [ ] revise.md: <250 lines
- [ ] implement.md: <300 lines
- [ ] research.md: <272 lines

**Delegation Safety Validation**:
- [ ] Registry tracks all delegations
- [ ] Cycle detection blocks depth >3
- [ ] Timeout enforcement functional
- [ ] No delegation failures

**Metrics Comparison Validation**:
- [ ] Before/after comparison complete
- [ ] All improvements documented
- [ ] Validation report comprehensive

## Artifacts & Outputs

**Test Suite**:
- tests/validation/phase2/conftest.py
- tests/validation/phase2/test_config.py
- tests/validation/phase2/test_research_command.py
- tests/validation/phase2/test_plan_command.py
- tests/validation/phase2/test_implement_command.py
- tests/validation/phase2/test_revise_command.py
- tests/validation/phase2/test_delegation_safety.py

**Metrics and Reports**:
- .opencode/specs/250_phase_2_followup/metrics/baseline_metrics.json
- .opencode/specs/250_phase_2_followup/metrics/test_results.json
- .opencode/specs/250_phase_2_followup/metrics/context_usage_report.json
- .opencode/specs/250_phase_2_followup/metrics/line_count_report.json
- .opencode/specs/250_phase_2_followup/metrics/delegation_safety_report.json
- .opencode/specs/250_phase_2_followup/reports/validation-001.md
- .opencode/specs/250_phase_2_followup/summaries/implementation-summary-20251229.md

**Scripts**:
- .opencode/specs/250_phase_2_followup/scripts/metrics_collector.py
- .opencode/specs/250_phase_2_followup/scripts/context_profiler.py
- .opencode/specs/250_phase_2_followup/scripts/line_count_validator.py
- .opencode/specs/250_phase_2_followup/scripts/metrics_comparison.py

## Rollback/Contingency

**If Test Failures Occur**:
1. Document all failures with reproduction steps
2. Create follow-up tasks for each failure category
3. Continue with remaining tests to gather complete data
4. Mark task as [PARTIAL] with failure documentation

**If Context Usage Exceeds Targets**:
1. Identify specific context bloat sources
2. Document violations in validation report
3. Create optimization tasks for follow-up
4. Proceed with remaining validation

**If Line Counts Exceed Targets**:
1. Document violations with file details
2. Assess if violations are acceptable (minor overages)
3. Create refactoring tasks if needed
4. Proceed with remaining validation

**If Delegation Safety Failures**:
1. Document specific safety feature failures
2. Create fix tasks with priority
3. Assess impact on overall system reliability
4. Proceed with remaining validation

**Rollback Not Applicable**: This is a validation task with no code changes. If validation reveals issues, create follow-up tasks rather than rolling back.
