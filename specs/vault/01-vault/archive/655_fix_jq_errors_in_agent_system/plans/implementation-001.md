# Implementation Plan: Task #655

- **Task**: 655 - fix_jq_errors_in_agent_system
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/655_fix_jq_errors_in_agent_system/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The research analysis revealed that the agent system has already mitigated the primary jq error pattern (Issue #1132) through a two-step jq approach and reusable postflight scripts. No vulnerable `map(select())` patterns exist in command or skill files. However, five improvement opportunities were identified: (1) postflight-implement.sh lacks completion_data field handling, (2) no regression testing for jq patterns, (3) execution flow documentation is missing, (4) no automated pattern linting, and (5) manual error recovery for jq failures. This plan addresses these gaps in priority order.

### Research Integration

Key findings from research-001.md:
- Issue #1132 is NOT a blocker (mitigated via two-step pattern)
- Only one jq error observed (incorrect -s flag, self-corrected)
- All commands delegate to skill-status-sync, avoiding vulnerable patterns
- Three postflight scripts implement correct patterns
- Gap: completion_data not extracted/stored in postflight-implement.sh

## Goals & Non-Goals

**Goals**:
- Add completion_data field extraction to postflight-implement.sh
- Create regression test suite for jq patterns
- Document command execution flow for maintainability
- Add jq pattern linter to prevent regression
- Create jq safe wrapper for automatic error recovery

**Non-Goals**:
- Fixing Issue #1132 upstream (marked NOT_PLANNED)
- Rewriting existing postflight scripts (they work correctly)
- Adding jq tests to CI pipeline (future enhancement)
- Changing the two-step pattern (proven effective)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Regression to vulnerable pattern | Medium | Low | Pattern linter (Phase 4) prevents reintroduction |
| completion_data mismatch | Medium | Medium | Validate field propagation in Phase 1 testing |
| Test script false positives | Low | Medium | Include expected failure cases in test suite |
| Documentation drift | Low | Low | Link execution flow doc from CLAUDE.md |

## Implementation Phases

### Phase 1: Enhance postflight-implement.sh [NOT STARTED]

**Goal**: Add completion_data field extraction and state.json updates

**Tasks**:
- [ ] Read current postflight-implement.sh structure
- [ ] Add completion_summary extraction from .return-meta.json
- [ ] Add roadmap_items array extraction (if present)
- [ ] Add claudemd_suggestions extraction for meta tasks
- [ ] Update state.json with new fields using two-step jq pattern
- [ ] Test field propagation with sample metadata file

**Timing**: 1 hour

**Files to modify**:
- `.claude/scripts/postflight-implement.sh` - Add completion_data handling

**Verification**:
- Create test .return-meta.json with completion_data
- Run script and verify fields appear in state.json
- Validate jq commands use two-step pattern (no map(select) in pipes)

---

### Phase 2: Create jq Pattern Test Suite [NOT STARTED]

**Goal**: Create regression test script for all jq patterns

**Tasks**:
- [ ] Extract test patterns from jq-escaping-workarounds.md (lines 161-207)
- [ ] Add tests for postflight-research.sh patterns
- [ ] Add tests for postflight-plan.sh patterns
- [ ] Add tests for postflight-implement.sh patterns (including new completion_data)
- [ ] Add tests for status-sync operations
- [ ] Include validation of output JSON structure
- [ ] Document test execution in script header

**Timing**: 2 hours

**Files to create**:
- `.claude/scripts/test-jq-patterns.sh` - Comprehensive test suite

**Verification**:
- Run test script with clean state.json fixture
- All tests pass without Issue #1132 errors
- Output shows clear pass/fail status for each pattern

---

### Phase 3: Document Command Execution Flow [NOT STARTED]

**Goal**: Create documentation capturing efficient execution patterns observed in /todo analysis

**Tasks**:
- [ ] Create command-execution-flow.md structure
- [ ] Document checkpoint execution with timing from research
- [ ] Include validation steps and error recovery patterns
- [ ] Add state synchronization flow diagrams
- [ ] Document orphan detection and tracking patterns
- [ ] Add examples from /todo execution log analysis
- [ ] Reference from CLAUDE.md architecture section

**Timing**: 2.5 hours

**Files to create**:
- `.claude/docs/architecture/command-execution-flow.md` - Execution flow documentation

**Files to update**:
- `.claude/CLAUDE.md` - Add reference to new documentation

**Verification**:
- Documentation covers all checkpoint patterns
- Examples are accurate and reproducible
- CLAUDE.md reference links correctly

---

### Phase 4: Create jq Pattern Linter [NOT STARTED]

**Goal**: Create pre-commit hook to detect vulnerable jq patterns

**Tasks**:
- [ ] Create lint-jq-patterns.sh script
- [ ] Add detection for map(select patterns in quoted strings
- [ ] Add detection for pipe operators in jq command substitution
- [ ] Output suggestions for two-step alternative
- [ ] Make script executable and document usage
- [ ] Add integration with git pre-commit hook (optional, documented)

**Timing**: 2 hours

**Files to create**:
- `.claude/scripts/lint-jq-patterns.sh` - Pattern linter

**Files to update**:
- `.claude/scripts/README.md` (if exists) or document in script header

**Verification**:
- Linter detects vulnerable pattern in test file
- Linter passes on correct two-step pattern
- Clear, actionable output when violations found

---

### Phase 5: Create jq Safe Wrapper [NOT STARTED]

**Goal**: Create wrapper for automatic error detection and retry

**Tasks**:
- [ ] Create jq-safe-wrapper.sh script structure
- [ ] Implement INVALID_CHARACTER error detection
- [ ] Add automatic retry with two-step pattern template
- [ ] Log recovery actions to errors.json with session_id
- [ ] Add usage documentation and examples
- [ ] Update error-handling.md to reference wrapper

**Timing**: 2.5 hours

**Files to create**:
- `.claude/scripts/jq-safe-wrapper.sh` - Safe wrapper with retry logic

**Files to update**:
- `.claude/rules/error-handling.md` - Add wrapper reference

**Verification**:
- Wrapper detects simulated INVALID_CHARACTER error
- Recovery logged to errors.json with proper structure
- Documentation is clear and accurate

---

## Testing & Validation

- [ ] Run test-jq-patterns.sh - all patterns pass
- [ ] Verify postflight-implement.sh extracts completion_data correctly
- [ ] Verify lint-jq-patterns.sh detects vulnerable patterns
- [ ] Verify jq-safe-wrapper.sh handles error cases
- [ ] Confirm documentation links resolve correctly
- [ ] Manual test: run /implement on a meta task, verify completion_data flows to state.json

## Artifacts & Outputs

- `.claude/scripts/postflight-implement.sh` (modified)
- `.claude/scripts/test-jq-patterns.sh` (new)
- `.claude/scripts/lint-jq-patterns.sh` (new)
- `.claude/scripts/jq-safe-wrapper.sh` (new)
- `.claude/docs/architecture/command-execution-flow.md` (new)
- `.claude/rules/error-handling.md` (modified)
- `.claude/CLAUDE.md` (modified - reference added)
- `specs/655_fix_jq_errors_in_agent_system/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If implementation causes issues:
1. **Phase 1 rollback**: Revert postflight-implement.sh to previous version (completion_data handling is additive, not destructive)
2. **Phase 2-5 rollback**: Simply delete new script files; they are standalone utilities
3. **Documentation rollback**: Remove CLAUDE.md reference and delete command-execution-flow.md

All changes are additive and isolated. No existing functionality is modified destructively. Git history preserves all prior versions for easy revert.
