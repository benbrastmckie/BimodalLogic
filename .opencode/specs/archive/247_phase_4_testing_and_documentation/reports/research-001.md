# Research Report: Phase 4 Testing and Documentation for OpenAgents Migration

**Task**: 247  
**Phase**: Phase 4 of 4 (OpenAgents Architectural Migration - Task 240)  
**Date**: 2025-12-29  
**Researcher**: researcher  
**Session**: sess_1735516800_res247

---

## Executive Summary

This research provides comprehensive testing strategies, documentation patterns, and validation approaches for Phase 4 of the OpenAgents architectural migration. Building on the validated success of Phases 1-3, Phase 4 focuses on proving 100% Stage 7 reliability through comprehensive testing (80 runs across 4 commands) and establishing documentation standards for future development.

**Key Findings**:

1. **Testing Strategy**: Implement test pyramid approach with 80 total runs (20 per command) to validate 100% Stage 7 execution reliability
2. **Validation Metrics**: Track Stage 7 execution rate, context window usage, command file sizes, and artifact creation success
3. **Documentation Patterns**: Create migration guides, architectural decision records, and command development templates
4. **Measurement Approaches**: Automated scripts for context window tracking, Stage 7 validation, and reliability testing
5. **Success Criteria**: 100% Stage 7 reliability (80/80 runs), context window <10% during routing, all artifacts validated

**Expected Outcomes**:
- Stage 7 reliability: 100% (80/80 successful runs)
- Context window usage: <10% during routing (maintained from Phase 2)
- Documentation: Migration guide, ADR, testing standards, command templates
- Total effort: 16-20 hours for Phase 4

---

## Table of Contents

1. [Testing Strategy for Command Workflow Validation](#1-testing-strategy-for-command-workflow-validation)
2. [Documentation Patterns for Architectural Migrations](#2-documentation-patterns-for-architectural-migrations)
3. [Validation Metrics and Measurement Approaches](#3-validation-metrics-and-measurement-approaches)
4. [Migration Guide Templates and Standards](#4-migration-guide-templates-and-standards)
5. [Implementation Roadmap](#5-implementation-roadmap)
6. [Risk Assessment and Mitigation](#6-risk-assessment-and-mitigation)
7. [Recommendations](#7-recommendations)
8. [References](#8-references)

---

## 1. Testing Strategy for Command Workflow Validation

### 1.1 Test Pyramid Approach

**Concept**: Apply Martin Fowler's Test Pyramid to command workflow validation

**Test Pyramid Layers** (from bottom to top):

```
                    /\
                   /  \
                  / E2E \          <- 4 tests (1 per command)
                 /--------\
                /          \
               / Integration \     <- 16 tests (4 per command)
              /--------------\
             /                \
            /   Unit Tests     \   <- 60 tests (15 per command)
           /--------------------\
```

**Layer 1: Unit Tests** (60 tests total)
- **Purpose**: Test individual command components in isolation
- **Scope**: Argument parsing, status transitions, artifact validation
- **Speed**: <1 second per test
- **Coverage**: 15 tests per command × 4 commands = 60 tests

**Example Unit Test**:
```bash
# Test argument parsing for /research command
test_research_argument_parsing() {
  # Given: Valid task number
  task_number=247
  
  # When: Parse arguments
  result=$(parse_research_args "$task_number")
  
  # Then: Arguments parsed correctly
  assert_equals "$result" "task_number=247"
}
```

**Layer 2: Integration Tests** (16 tests total)
- **Purpose**: Test command integration with agents and status-sync-manager
- **Scope**: Command → Agent delegation, Status updates, Artifact creation
- **Speed**: 5-10 seconds per test
- **Coverage**: 4 tests per command × 4 commands = 16 tests

**Example Integration Test**:
```bash
# Test /research command integration with researcher agent
test_research_agent_integration() {
  # Given: Task 247 exists
  # When: Execute /research 247
  /research 247
  
  # Then: Researcher agent invoked
  assert_agent_invoked "researcher"
  
  # And: Research artifact created
  assert_file_exists ".opencode/specs/247_*/reports/research-001.md"
  
  # And: Status updated to [RESEARCHED]
  assert_status_equals 247 "RESEARCHED"
}
```

**Layer 3: End-to-End Tests** (4 tests total)
- **Purpose**: Test complete command workflow from invocation to completion
- **Scope**: Full 8-stage lifecycle including Stage 7 (Postflight)
- **Speed**: 30-60 seconds per test
- **Coverage**: 1 test per command × 4 commands = 4 tests

**Example E2E Test**:
```bash
# Test /research command end-to-end workflow
test_research_e2e_workflow() {
  # Given: Clean state
  cleanup_task 247
  
  # When: Execute /research 247
  /research 247
  
  # Then: All 8 stages executed
  assert_stage_executed 1 "Preflight"
  assert_stage_executed 2 "CheckLanguage"
  assert_stage_executed 3 "PrepareDelegation"
  assert_stage_executed 4 "InvokeAgent"
  assert_stage_executed 5 "ReceiveResults"
  assert_stage_executed 6 "ProcessResults"
  assert_stage_executed 7 "Postflight"
  assert_stage_executed 8 "ReturnSuccess"
  
  # And: Stage 7 completed successfully
  assert_todo_updated 247 "RESEARCHED"
  assert_state_json_updated 247 "researched"
  assert_git_commit_created "task 247: research completed"
}
```

**Source**: Martin Fowler, "The Practical Test Pyramid" (2018)

### 1.2 Stage 7 Reliability Testing

**Objective**: Prove 100% Stage 7 execution reliability across 80 test runs

**Test Suite Design**:

```bash
#!/bin/bash
# test-stage7-reliability.sh

COMMANDS=("research" "plan" "implement" "revise")
RUNS_PER_COMMAND=20
TOTAL_RUNS=80

echo "=== Stage 7 Reliability Test Suite ==="
echo "Target: 100% success rate (80/80 runs)"
echo ""

total_success=0
total_failures=0

for cmd in "${COMMANDS[@]}"; do
  echo "Testing /${cmd} command (${RUNS_PER_COMMAND} runs)..."
  
  cmd_success=0
  cmd_failures=0
  
  for i in $(seq 1 $RUNS_PER_COMMAND); do
    # Create unique test task
    task_number=$((247 + (${cmd}_offset * 20) + i))
    
    # Execute command
    echo "  Run ${i}/${RUNS_PER_COMMAND}: /${cmd} ${task_number}"
    /${cmd} ${task_number} > /tmp/${cmd}-${i}.log 2>&1
    
    # Validate Stage 7 execution
    if validate_stage7 "${task_number}" "${cmd}"; then
      ((cmd_success++))
      ((total_success++))
      echo "    [PASS] Stage 7 executed successfully"
    else
      ((cmd_failures++))
      ((total_failures++))
      echo "    [FAIL] Stage 7 execution incomplete"
      cat /tmp/${cmd}-${i}.log
    fi
  done
  
  # Calculate command success rate
  cmd_rate=$((cmd_success * 100 / RUNS_PER_COMMAND))
  echo "  /${cmd} Success Rate: ${cmd_rate}% (${cmd_success}/${RUNS_PER_COMMAND})"
  echo ""
done

# Calculate overall success rate
overall_rate=$((total_success * 100 / TOTAL_RUNS))
echo "=== Overall Results ==="
echo "Successful runs: ${total_success}/${TOTAL_RUNS}"
echo "Failed runs: ${total_failures}/${TOTAL_RUNS}"
echo "Success rate: ${overall_rate}%"
echo ""

# Validate against target
if [ $overall_rate -eq 100 ]; then
  echo "[PASS] Achieved 100% Stage 7 reliability target"
  exit 0
else
  echo "[FAIL] Did not achieve 100% Stage 7 reliability target"
  echo "Expected: 100%, Actual: ${overall_rate}%"
  exit 1
fi
```

**Validation Function**:

```bash
validate_stage7() {
  local task_number=$1
  local command=$2
  
  # Determine expected status based on command
  local expected_status
  case $command in
    research) expected_status="RESEARCHED" ;;
    plan) expected_status="PLANNED" ;;
    implement) expected_status="IMPLEMENTED" ;;
    revise) expected_status="COMPLETED" ;;
  esac
  
  # Check 1: TODO.md updated with correct status
  if ! grep -q "### ${task_number}.*\[${expected_status}\]" .opencode/specs/TODO.md; then
    echo "    ERROR: TODO.md not updated with [${expected_status}]"
    return 1
  fi
  
  # Check 2: state.json updated
  local state_status=$(jq -r ".tasks[] | select(.task_number == ${task_number}) | .status" .opencode/specs/state.json)
  if [ "$state_status" != "${expected_status,,}" ]; then
    echo "    ERROR: state.json status is '${state_status}', expected '${expected_status,,}'"
    return 1
  fi
  
  # Check 3: Artifacts linked in TODO.md
  if ! grep -A 20 "### ${task_number}\." .opencode/specs/TODO.md | grep -q "artifacts"; then
    echo "    ERROR: Artifacts not linked in TODO.md"
    return 1
  fi
  
  # Check 4: Git commit created
  if ! git log -1 --oneline | grep -q "${command}.*${task_number}"; then
    echo "    ERROR: Git commit not created"
    return 1
  fi
  
  # Check 5: Timestamp updated
  if ! grep -A 20 "### ${task_number}\." .opencode/specs/TODO.md | grep -q "Completed:"; then
    echo "    ERROR: Completion timestamp not updated"
    return 1
  fi
  
  # All checks passed
  return 0
}
```

**Success Criteria**:
- [PASS] 80/80 runs complete successfully (100% success rate)
- [PASS] All TODO.md updates verified
- [PASS] All state.json updates verified
- [PASS] All git commits verified
- [PASS] All timestamps verified
- [PASS] All artifacts linked verified

**Source**: Adapted from ProofChecker testing standards and Phase 1-3 validation reports

### 1.3 Context Window Usage Measurement

**Objective**: Validate context window usage remains <10% during routing

**Measurement Script**:

```bash
#!/bin/bash
# measure-context-usage.sh

echo "=== Context Window Usage Measurement ==="
echo ""

# Checkpoint 1: Orchestrator routing (before command delegation)
echo "Checkpoint 1: Orchestrator Routing"
orchestrator_lines=$(wc -l .opencode/agent/orchestrator.md | awk '{print $1}')
routing_guide_lines=$(wc -l .opencode/context/system/routing-guide.md 2>/dev/null | awk '{print $1}')
routing_guide_lines=${routing_guide_lines:-0}

checkpoint1_lines=$((orchestrator_lines + routing_guide_lines))
checkpoint1_tokens=$((checkpoint1_lines * 4))

echo "  orchestrator.md: $orchestrator_lines lines (~$((orchestrator_lines * 4)) tokens)"
echo "  routing-guide.md: $routing_guide_lines lines (~$((routing_guide_lines * 4)) tokens)"
echo "  Total: $checkpoint1_lines lines (~$checkpoint1_tokens tokens)"
echo "  Target: <10,000 tokens"

if [ $checkpoint1_tokens -lt 10000 ]; then
  echo "  Status: [PASS]"
  checkpoint1_status="PASS"
else
  echo "  Status: [FAIL] - Exceeds 10,000 token target"
  checkpoint1_status="FAIL"
fi
echo ""

# Checkpoint 2: Command routing (Stages 1-3)
echo "Checkpoint 2: Command Routing (Stages 1-3)"
research_lines=$(wc -l .opencode/command/research.md | awk '{print $1}')
plan_lines=$(wc -l .opencode/command/plan.md | awk '{print $1}')
implement_lines=$(wc -l .opencode/command/implement.md | awk '{print $1}')
revise_lines=$(wc -l .opencode/command/revise.md | awk '{print $1}')

avg_command_lines=$(( (research_lines + plan_lines + implement_lines + revise_lines) / 4 ))
task_entry_lines=50  # Estimated task entry size

checkpoint2_lines=$((avg_command_lines + task_entry_lines))
checkpoint2_tokens=$((checkpoint2_lines * 4))

echo "  Average command file: $avg_command_lines lines (~$((avg_command_lines * 4)) tokens)"
echo "  Task entry: $task_entry_lines lines (~$((task_entry_lines * 4)) tokens)"
echo "  Total: $checkpoint2_lines lines (~$checkpoint2_tokens tokens)"
echo "  Target: <5,000 tokens"

if [ $checkpoint2_tokens -lt 5000 ]; then
  echo "  Status: [PASS]"
  checkpoint2_status="PASS"
else
  echo "  Status: [FAIL] - Exceeds 5,000 token target"
  checkpoint2_status="FAIL"
fi
echo ""

# Overall routing context
routing_total=$((checkpoint1_tokens + checkpoint2_tokens))
routing_pct=$((routing_total * 100 / 100000))

echo "=== Overall Routing Context ==="
echo "Routing (Checkpoints 1-2): $routing_total tokens ($routing_pct% of 100k budget)"
echo "Target: <10% of context window"
echo ""

if [ $routing_pct -lt 10 ]; then
  echo "Status: [PASS] - Routing uses $routing_pct% of context"
  overall_status="PASS"
else
  echo "Status: [FAIL] - Routing uses $routing_pct% of context (target: <10%)"
  overall_status="FAIL"
fi

# Exit with appropriate code
if [ "$checkpoint1_status" = "PASS" ] && [ "$checkpoint2_status" = "PASS" ] && [ "$overall_status" = "PASS" ]; then
  exit 0
else
  exit 1
fi
```

**Measurement Points**:

| Checkpoint | Components | Target Tokens | Validation |
|------------|-----------|---------------|------------|
| 1. Orchestrator Routing | orchestrator.md + routing-guide.md | <10,000 | [PASS] if <10,000 |
| 2. Command Routing | command.md + task entry | <5,000 | [PASS] if <5,000 |
| Overall | Checkpoints 1+2 | <15,000 (15%) | [PASS] if <10% |

**Source**: Phase 1 validation report context window measurement methodology

### 1.4 Artifact Validation Testing

**Objective**: Verify all artifacts created correctly for each command

**Validation Checklist**:

```bash
#!/bin/bash
# validate-artifacts.sh

validate_research_artifacts() {
  local task_number=$1
  local task_dir=$(find .opencode/specs -type d -name "${task_number}_*" | head -1)
  
  # Check 1: Research report exists
  if [ ! -f "${task_dir}/reports/research-001.md" ]; then
    echo "[FAIL] Research report not found"
    return 1
  fi
  
  # Check 2: Research report is non-empty
  if [ ! -s "${task_dir}/reports/research-001.md" ]; then
    echo "[FAIL] Research report is empty"
    return 1
  fi
  
  # Check 3: Research report contains required sections
  if ! grep -q "## Executive Summary" "${task_dir}/reports/research-001.md"; then
    echo "[FAIL] Research report missing Executive Summary"
    return 1
  fi
  
  echo "[PASS] Research artifacts validated"
  return 0
}

validate_plan_artifacts() {
  local task_number=$1
  local task_dir=$(find .opencode/specs -type d -name "${task_number}_*" | head -1)
  
  # Check 1: Implementation plan exists
  if [ ! -f "${task_dir}/plans/implementation-001.md" ]; then
    echo "[FAIL] Implementation plan not found"
    return 1
  fi
  
  # Check 2: Plan is non-empty
  if [ ! -s "${task_dir}/plans/implementation-001.md" ]; then
    echo "[FAIL] Implementation plan is empty"
    return 1
  fi
  
  # Check 3: Plan contains phases
  if ! grep -q "## Phase" "${task_dir}/plans/implementation-001.md"; then
    echo "[FAIL] Implementation plan missing phases"
    return 1
  fi
  
  echo "[PASS] Plan artifacts validated"
  return 0
}

validate_implement_artifacts() {
  local task_number=$1
  local task_dir=$(find .opencode/specs -type d -name "${task_number}_*" | head -1)
  
  # Check 1: Implementation summary exists
  if ! ls "${task_dir}"/summaries/implementation-summary-*.md 1> /dev/null 2>&1; then
    echo "[FAIL] Implementation summary not found"
    return 1
  fi
  
  # Check 2: Summary is non-empty
  local summary_file=$(ls "${task_dir}"/summaries/implementation-summary-*.md | head -1)
  if [ ! -s "$summary_file" ]; then
    echo "[FAIL] Implementation summary is empty"
    return 1
  fi
  
  echo "[PASS] Implementation artifacts validated"
  return 0
}

# Main validation
echo "=== Artifact Validation ==="
for task in 247 248 249 250; do
  echo "Validating task ${task}..."
  
  validate_research_artifacts $task
  validate_plan_artifacts $task
  validate_implement_artifacts $task
  
  echo ""
done
```

**Source**: ProofChecker artifact-management.md standards

---

## 2. Documentation Patterns for Architectural Migrations

### 2.1 Migration Guide Template

**Purpose**: Document migration process for future reference and replication

**Template Structure**:

```markdown
# Migration Guide: [Migration Name]

**Version**: 1.0  
**Date**: YYYY-MM-DD  
**Author**: [Name]  
**Status**: [Draft|Review|Approved]

---

## Overview

### Migration Scope
- What is being migrated
- Why the migration is needed
- Expected benefits

### Migration Phases
1. Phase 1: [Name] - [Duration]
2. Phase 2: [Name] - [Duration]
3. Phase 3: [Name] - [Duration]
4. Phase 4: [Name] - [Duration]

### Success Criteria
- Metric 1: [Target]
- Metric 2: [Target]
- Metric 3: [Target]

---

## Phase-by-Phase Guide

### Phase 1: [Name]

**Objective**: [What this phase achieves]

**Duration**: [Estimated hours]

**Prerequisites**:
- Prerequisite 1
- Prerequisite 2

**Steps**:

1. **Step 1**: [Action]
   - Substep 1.1
   - Substep 1.2
   - Validation: [How to verify]

2. **Step 2**: [Action]
   - Substep 2.1
   - Substep 2.2
   - Validation: [How to verify]

**Deliverables**:
- Deliverable 1: [Description]
- Deliverable 2: [Description]

**Validation**:
- [ ] Validation check 1
- [ ] Validation check 2
- [ ] Validation check 3

**Rollback Procedure**:
```bash
# Commands to rollback this phase
```

---

## Testing Strategy

### Test Types
- Unit tests: [Coverage]
- Integration tests: [Coverage]
- End-to-end tests: [Coverage]

### Test Execution
```bash
# Commands to run tests
```

### Success Criteria
- [ ] All tests pass
- [ ] No regressions detected
- [ ] Performance targets met

---

## Metrics and Validation

### Before Migration
| Metric | Value |
|--------|-------|
| Metric 1 | [Baseline] |
| Metric 2 | [Baseline] |

### After Migration
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Metric 1 | [Target] | [Actual] | [PASS/FAIL] |
| Metric 2 | [Target] | [Actual] | [PASS/FAIL] |

---

## Lessons Learned

### What Went Well
- Success 1
- Success 2

### What Could Be Improved
- Improvement 1
- Improvement 2

### Recommendations for Future Migrations
- Recommendation 1
- Recommendation 2

---

## References

- [Related Document 1]
- [Related Document 2]
```

**Example**: OpenAgents Migration Guide (Task 240-247)

**Source**: Software engineering migration best practices

### 2.2 Architectural Decision Record (ADR)

**Purpose**: Document architectural decisions and rationale

**ADR Template**:

```markdown
# ADR-XXX: [Decision Title]

**Status**: [Proposed|Accepted|Deprecated|Superseded]  
**Date**: YYYY-MM-DD  
**Deciders**: [Names]  
**Technical Story**: [Task number or description]

---

## Context and Problem Statement

[Describe the context and problem statement, e.g., in free form using two to three sentences. You may want to articulate the problem in form of a question.]

## Decision Drivers

* [driver 1, e.g., a force, facing concern, …]
* [driver 2, e.g., a force, facing concern, …]
* [driver 3, e.g., a force, facing concern, …]

## Considered Options

* [option 1]
* [option 2]
* [option 3]

## Decision Outcome

Chosen option: "[option 1]", because [justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force force | … | comes out best (see below)].

### Positive Consequences

* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, …]
* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, …]

### Negative Consequences

* [e.g., compromising quality attribute, follow-up decisions required, …]
* [e.g., compromising quality attribute, follow-up decisions required, …]

## Pros and Cons of the Options

### [option 1]

[example | description | pointer to more information | …]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]

### [option 2]

[example | description | pointer to more information | …]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]

### [option 3]

[example | description | pointer to more information | …]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]

## Links

* [Link type] [Link to ADR]
* [Link type] [Link to ADR]
```

**Example**: ADR-002: Agent Workflow Ownership Pattern

**Source**: Michael Nygard, "Documenting Architecture Decisions" (2011)

### 2.3 Command Development Template

**Purpose**: Standardize command development for consistency

**Template**:

```markdown
---
name: {command_name}
agent: subagents/{agent_name}
description: "{Brief description with status marker}"
routing:
  lean: lean-{command}-agent
  default: {agent_name}
flags:
  - {flag_name}: "{flag description}"
---

# /{command_name} - {Command Title}

## Purpose

{What this command does, not how}

## Usage

```bash
/{command_name} TASK_NUMBER [ARGUMENTS] [FLAGS]
```

**Examples**:
- `/{command_name} 247` - {Example description}
- `/{command_name} 247 "{example argument}"` - {Example with argument}
- `/{command_name} 247 --{flag}` - {Example with flag}

## Workflow

This command follows the 8-stage command-lifecycle.md pattern:

1. **Preflight**: Parse arguments, validate task, update status
2. **CheckLanguage**: Extract language, determine routing
3. **PrepareDelegation**: Generate session ID, prepare context
4. **InvokeAgent**: Delegate to agent with task context
5. **ValidateReturn**: Verify artifacts and return format
6. **PrepareReturn**: Format return object
7. **Postflight**: Update status, create git commit, verify
8. **ReturnSuccess**: Return standardized result

**Implementation**: See `.opencode/agent/subagents/{agent_name}.md` for complete workflow execution.

## Routing Logic

```
IF Language == "lean":
  agent = "lean-{command}-agent"
ELSE:
  agent = "{agent_name}"
```

## Status Transitions

- Initial: [NOT STARTED] → [{IN_PROGRESS_STATUS}]
- Completion: [{IN_PROGRESS_STATUS}] → [{COMPLETION_STATUS}]
- Partial: Keep [{IN_PROGRESS_STATUS}]
- Failed: Keep [{IN_PROGRESS_STATUS}]

## Artifacts Created

- {Artifact type}: `.opencode/specs/{task_number}_{slug}/{path}/{filename}`
- {Artifact type}: `.opencode/specs/{task_number}_{slug}/{path}/{filename}`

## Error Handling

- Missing task number: "Error: Task number required. Usage: /{command_name} TASK_NUMBER [ARGUMENTS]"
- Invalid task number: "Error: Task number must be an integer. Got: {input}"
- Task not found: "Error: Task {task_number} not found in .opencode/specs/TODO.md"

## Context Loading

### Routing Stage (Stages 1-3)
Load minimal context for routing decisions:
- `.opencode/context/system/routing-guide.md`

### Execution Stage (Stage 4+)
Agent loads context on-demand per `.opencode/context/index.md`

## Related Commands

- `/{related_command_1}` - {Description}
- `/{related_command_2}` - {Description}
```

**Source**: Phase 1-2 command migration patterns

---

## 3. Validation Metrics and Measurement Approaches

### 3.1 Stage 7 Execution Rate Tracking

**Metric**: Percentage of command runs where Stage 7 executes successfully

**Measurement Formula**:
```
Stage 7 Execution Rate = (Successful Stage 7 Executions / Total Command Runs) × 100%
```

**Target**: 100% (80/80 runs)

**Tracking Script**:

```bash
#!/bin/bash
# track-stage7-rate.sh

# Initialize counters
declare -A stage7_success
declare -A stage7_total

for cmd in research plan implement revise; do
  stage7_success[$cmd]=0
  stage7_total[$cmd]=0
done

# Parse test logs
for cmd in research plan implement revise; do
  for log in /tmp/${cmd}-*.log; do
    ((stage7_total[$cmd]++))
    
    # Check if Stage 7 executed successfully
    if grep -q "Stage 7 completed successfully" "$log"; then
      ((stage7_success[$cmd]++))
    fi
  done
done

# Calculate and display rates
echo "=== Stage 7 Execution Rate Tracking ==="
echo ""

total_success=0
total_runs=0

for cmd in research plan implement revise; do
  success=${stage7_success[$cmd]}
  total=${stage7_total[$cmd]}
  rate=$((success * 100 / total))
  
  echo "/${cmd}: ${success}/${total} (${rate}%)"
  
  total_success=$((total_success + success))
  total_runs=$((total_runs + total))
done

overall_rate=$((total_success * 100 / total_runs))
echo ""
echo "Overall: ${total_success}/${total_runs} (${overall_rate}%)"
echo "Target: 100%"
echo ""

if [ $overall_rate -eq 100 ]; then
  echo "[PASS] Achieved 100% Stage 7 execution rate"
else
  echo "[FAIL] Stage 7 execution rate below 100%"
fi
```

**Visualization**:

```
Stage 7 Execution Rate by Command
==================================

/research:   ████████████████████ 20/20 (100%)
/plan:       ████████████████████ 20/20 (100%)
/implement:  ████████████████████ 20/20 (100%)
/revise:     ████████████████████ 20/20 (100%)

Overall:     ████████████████████ 80/80 (100%)
Target:      ████████████████████ 100%

Status: [PASS]
```

### 3.2 Context Window Usage Tracking

**Metric**: Percentage of context window used during routing vs execution

**Measurement Formula**:
```
Routing Context % = (Routing Tokens / Total Context Budget) × 100%
Execution Context % = (Execution Tokens / Total Context Budget) × 100%
```

**Targets**:
- Routing: <10% of 100k context window (<10,000 tokens)
- Execution: <50% of 100k context window (<50,000 tokens)

**Tracking Table**:

| Phase | Component | Lines | Tokens | % of Budget | Target | Status |
|-------|-----------|-------|--------|-------------|--------|--------|
| Routing | orchestrator.md | 80 | 320 | 0.3% | <10% | [PASS] |
| Routing | routing-guide.md | 200 | 800 | 0.8% | <10% | [PASS] |
| Routing | command.md (avg) | 250 | 1,000 | 1.0% | <10% | [PASS] |
| Routing | task entry | 50 | 200 | 0.2% | <10% | [PASS] |
| **Routing Total** | | **580** | **2,320** | **2.3%** | **<10%** | **[PASS]** |
| Execution | agent.md | 500 | 2,000 | 2.0% | <50% | [PASS] |
| Execution | context files | 2,000 | 8,000 | 8.0% | <50% | [PASS] |
| Execution | TODO.md (extract) | 50 | 200 | 0.2% | <50% | [PASS] |
| **Execution Total** | | **2,550** | **10,200** | **10.2%** | **<50%** | **[PASS]** |

**Source**: Phase 1-2 validation reports

### 3.3 Command File Size Tracking

**Metric**: Line count and byte size of command files

**Measurement**:

```bash
#!/bin/bash
# track-command-sizes.sh

echo "=== Command File Size Tracking ==="
echo ""

echo "| Command | Lines | Bytes | Target Lines | Status |"
echo "|---------|-------|-------|--------------|--------|"

for cmd in research plan implement revise; do
  lines=$(wc -l .opencode/command/${cmd}.md | awk '{print $1}')
  bytes=$(wc -c .opencode/command/${cmd}.md | awk '{print $1}')
  target=250
  
  if [ $lines -le $target ]; then
    status="[PASS]"
  else
    status="[FAIL]"
  fi
  
  echo "| /${cmd} | ${lines} | ${bytes} | <${target} | ${status} |"
done

echo ""
```

**Target**: <250 lines per command (adjusted from original 200-line target based on Phase 1 results)

### 3.4 Artifact Creation Success Rate

**Metric**: Percentage of command runs where all artifacts created successfully

**Measurement**:

```bash
#!/bin/bash
# track-artifact-success.sh

echo "=== Artifact Creation Success Rate ==="
echo ""

for cmd in research plan implement revise; do
  success=0
  total=0
  
  for log in /tmp/${cmd}-*.log; do
    ((total++))
    
    # Extract task number from log filename
    task_number=$(basename "$log" | sed 's/.*-\([0-9]*\)\.log/\1/')
    
    # Validate artifacts for this task
    if validate_${cmd}_artifacts $task_number; then
      ((success++))
    fi
  done
  
  rate=$((success * 100 / total))
  echo "/${cmd}: ${success}/${total} (${rate}%)"
done
```

**Target**: 100% artifact creation success rate

---

## 4. Migration Guide Templates and Standards

### 4.1 Migration Documentation Structure

**Directory Structure**:

```
.opencode/
├── docs/
│   ├── migrations/
│   │   ├── 001-openagents-migration/
│   │   │   ├── README.md                    # Migration overview
│   │   │   ├── phase-1-guide.md             # Phase 1 implementation guide
│   │   │   ├── phase-2-guide.md             # Phase 2 implementation guide
│   │   │   ├── phase-3-guide.md             # Phase 3 implementation guide
│   │   │   ├── phase-4-guide.md             # Phase 4 testing and docs
│   │   │   ├── validation-reports/
│   │   │   │   ├── phase-1-validation.md
│   │   │   │   ├── phase-2-validation.md
│   │   │   │   ├── phase-3-validation.md
│   │   │   │   └── phase-4-validation.md
│   │   │   ├── adr/
│   │   │   │   ├── ADR-001-context-index.md
│   │   │   │   ├── ADR-002-agent-workflow-ownership.md
│   │   │   │   └── ADR-003-frontmatter-delegation.md
│   │   │   └── lessons-learned.md
│   │   └── README.md                        # Migration index
│   └── templates/
│       ├── command-template.md              # Command development template
│       ├── agent-template.md                # Agent development template
│       └── migration-guide-template.md      # Migration guide template
```

### 4.2 Command Development Standards

**Standard**: All new commands must follow frontmatter delegation pattern

**Requirements**:

1. **Frontmatter**:
   - `name`: Command name (lowercase, no slashes)
   - `agent`: Target agent path (subagents/{agent_name})
   - `description`: Brief description with status marker
   - `routing`: Language-based routing rules (if applicable)
   - `flags`: Optional flags with descriptions

2. **File Size**:
   - Target: <250 lines
   - Maximum: 300 lines
   - Justification required if exceeding 300 lines

3. **Sections**:
   - Purpose (what, not how)
   - Usage (examples)
   - Workflow (8-stage reference)
   - Routing Logic (if applicable)
   - Status Transitions
   - Artifacts Created
   - Error Handling
   - Context Loading
   - Related Commands

4. **Context Loading**:
   - Routing stage: Minimal context (<10% budget)
   - Execution stage: Full context loaded by agent

5. **Workflow Ownership**:
   - Command delegates to agent
   - Agent owns 8-stage workflow execution
   - Agent responsible for Stage 7 (Postflight)

**Validation Checklist**:

```markdown
## Command Development Checklist

### Frontmatter
- [ ] `name` field present and correct
- [ ] `agent` field points to valid agent
- [ ] `description` includes status marker
- [ ] `routing` rules defined (if applicable)
- [ ] `flags` documented (if applicable)

### File Size
- [ ] File size <250 lines (target)
- [ ] File size <300 lines (maximum)
- [ ] Justification provided if >300 lines

### Required Sections
- [ ] Purpose section present
- [ ] Usage section with examples
- [ ] Workflow section references command-lifecycle.md
- [ ] Routing Logic documented (if applicable)
- [ ] Status Transitions documented
- [ ] Artifacts Created documented
- [ ] Error Handling documented
- [ ] Context Loading documented
- [ ] Related Commands documented

### Context Loading
- [ ] Routing stage context <10% budget
- [ ] Execution stage context loaded by agent
- [ ] No duplicate context loading

### Workflow Ownership
- [ ] Command delegates to agent
- [ ] Agent owns workflow execution
- [ ] Stage 7 owned by agent
- [ ] No embedded workflow in command

### Testing
- [ ] Unit tests written
- [ ] Integration tests written
- [ ] End-to-end test written
- [ ] Stage 7 reliability test passed
```

### 4.3 Agent Development Standards

**Standard**: All agents must implement complete 8-stage workflow

**Requirements**:

1. **Frontmatter**:
   - `description`: Agent purpose and capabilities
   - `mode`: "subagent" or "specialist"
   - `temperature`: LLM temperature (0.0-1.0)
   - `timeout`: Default timeout in seconds
   - `tools`: Tool permissions (read, write, bash, etc.)
   - `permissions`: Security restrictions

2. **Workflow Implementation**:
   - All 8 stages documented
   - Stage 7 (Postflight) includes:
     - Artifact validation
     - Status update delegation
     - Git commit delegation
     - Verification on disk

3. **Return Format**:
   - Follow subagent-return-format.md
   - Include validation result in metadata
   - Brief summary (<100 tokens)

**Validation Checklist**:

```markdown
## Agent Development Checklist

### Frontmatter
- [ ] `description` present
- [ ] `mode` set to "subagent" or "specialist"
- [ ] `temperature` specified
- [ ] `timeout` specified
- [ ] `tools` permissions defined
- [ ] `permissions` security restrictions defined

### Workflow Implementation
- [ ] Stage 1 (Preflight) implemented
- [ ] Stage 2 (Routing/Analysis) implemented
- [ ] Stage 3 (Execution) implemented
- [ ] Stage 4 (Artifact Creation) implemented
- [ ] Stage 5 (Validation) implemented
- [ ] Stage 6 (Return Preparation) implemented
- [ ] Stage 7 (Postflight) implemented
- [ ] Stage 8 (Return Success) implemented

### Stage 7 Requirements
- [ ] Artifact validation included
- [ ] Status update delegation included
- [ ] Git commit delegation included
- [ ] Verification on disk included

### Return Format
- [ ] Follows subagent-return-format.md
- [ ] Validation result in metadata
- [ ] Summary <100 tokens
- [ ] All required fields present
```

---

## 5. Implementation Roadmap

### 5.1 Phase 4 Timeline

**Total Duration**: 16-20 hours

**Week 1: Testing Infrastructure** (8-10 hours)

**Day 1-2: Test Suite Development** (6-8 hours)
- [ ] Create test-stage7-reliability.sh (2 hours)
- [ ] Create validate-artifacts.sh (2 hours)
- [ ] Create measure-context-usage.sh (1 hour)
- [ ] Create track-stage7-rate.sh (1 hour)
- [ ] Test all scripts (1-2 hours)

**Day 3: Test Execution** (2 hours)
- [ ] Run 80-run reliability test suite (1 hour)
- [ ] Analyze results and fix issues (1 hour)

**Week 2: Documentation** (8-10 hours)

**Day 1-2: Migration Guide** (4-5 hours)
- [ ] Create migration guide template (1 hour)
- [ ] Document Phase 1 (1 hour)
- [ ] Document Phase 2 (1 hour)
- [ ] Document Phase 3 (1 hour)
- [ ] Document Phase 4 (1 hour)

**Day 3: ADRs and Templates** (4-5 hours)
- [ ] Create ADR-001: Context Index (1 hour)
- [ ] Create ADR-002: Agent Workflow Ownership (1 hour)
- [ ] Create ADR-003: Frontmatter Delegation (1 hour)
- [ ] Create command development template (1 hour)
- [ ] Create agent development template (1 hour)

### 5.2 Deliverables

**Testing Deliverables**:
- [ ] test-stage7-reliability.sh (80-run test suite)
- [ ] validate-artifacts.sh (artifact validation)
- [ ] measure-context-usage.sh (context tracking)
- [ ] track-stage7-rate.sh (execution rate tracking)
- [ ] Test execution report (80 runs)

**Documentation Deliverables**:
- [ ] Migration guide (Phases 1-4)
- [ ] ADR-001: Context Index
- [ ] ADR-002: Agent Workflow Ownership
- [ ] ADR-003: Frontmatter Delegation
- [ ] Command development template
- [ ] Agent development template
- [ ] Lessons learned document

**Validation Deliverables**:
- [ ] Phase 4 validation report
- [ ] Stage 7 reliability metrics (100% target)
- [ ] Context window usage metrics (<10% target)
- [ ] Command file size metrics (<250 lines target)
- [ ] Artifact creation success metrics (100% target)

### 5.3 Success Criteria

**Testing Success Criteria**:
- [PASS] 80/80 test runs successful (100% Stage 7 reliability)
- [PASS] All artifacts validated (100% creation success)
- [PASS] Context window usage <10% during routing
- [PASS] All command files <250 lines

**Documentation Success Criteria**:
- [PASS] Migration guide complete (Phases 1-4)
- [PASS] 3 ADRs created and approved
- [PASS] Command template created and validated
- [PASS] Agent template created and validated
- [PASS] Lessons learned documented

**Overall Success Criteria**:
- [PASS] All testing success criteria met
- [PASS] All documentation success criteria met
- [PASS] Phase 4 validation report created
- [PASS] Task 247 marked [COMPLETED]

---

## 6. Risk Assessment and Mitigation

### 6.1 Testing Risks

**Risk 1: Test Flakiness**

**Description**: Tests may fail intermittently due to timing issues or external dependencies

**Likelihood**: MEDIUM  
**Impact**: MEDIUM  
**Severity**: MEDIUM

**Mitigation**:
- Use deterministic test data
- Avoid time-based assertions
- Retry failed tests (max 3 retries)
- Log detailed failure information
- Isolate tests from external dependencies

**Risk 2: Incomplete Test Coverage**

**Description**: Tests may not cover all edge cases or failure scenarios

**Likelihood**: MEDIUM  
**Impact**: HIGH  
**Severity**: MEDIUM-HIGH

**Mitigation**:
- Use test pyramid approach (unit, integration, E2E)
- Review test coverage metrics
- Add tests for discovered bugs
- Document known limitations
- Plan for continuous test improvement

### 6.2 Documentation Risks

**Risk 3: Documentation Becomes Outdated**

**Description**: Documentation may not be updated as system evolves

**Likelihood**: HIGH  
**Impact**: MEDIUM  
**Severity**: MEDIUM

**Mitigation**:
- Include documentation in code review process
- Link documentation to code (ADRs, templates)
- Schedule quarterly documentation reviews
- Use automated documentation generation where possible
- Assign documentation ownership

**Risk 4: Documentation Too Detailed**

**Description**: Over-documentation may make it hard to find relevant information

**Likelihood**: LOW  
**Impact**: LOW  
**Severity**: LOW

**Mitigation**:
- Follow "just enough documentation" principle
- Use templates for consistency
- Create clear navigation structure
- Include table of contents
- Link related documents

### 6.3 Overall Risk Assessment

**Risk Matrix**:

| Risk | Likelihood | Impact | Severity | Mitigation Effectiveness |
|------|-----------|--------|----------|-------------------------|
| Test Flakiness | MEDIUM | MEDIUM | MEDIUM | HIGH |
| Incomplete Coverage | MEDIUM | HIGH | MEDIUM-HIGH | HIGH |
| Outdated Docs | HIGH | MEDIUM | MEDIUM | MEDIUM |
| Over-Documentation | LOW | LOW | LOW | HIGH |

**Overall Risk Level**: MEDIUM

**Mitigation Effectiveness**: HIGH

---

## 7. Recommendations

### 7.1 Testing Recommendations

**Recommendation 1: Implement Continuous Testing**

**Priority**: HIGH  
**Effort**: 2 hours  
**Impact**: Ensures ongoing Stage 7 reliability

**Actions**:
1. Add test-stage7-reliability.sh to CI pipeline
2. Run on every commit to main branch
3. Fail build if Stage 7 reliability <100%
4. Send notifications on failures

**Recommendation 2: Create Test Data Generator**

**Priority**: MEDIUM  
**Effort**: 4 hours  
**Impact**: Simplifies test setup and maintenance

**Actions**:
1. Create script to generate test tasks
2. Include various task types (lean, markdown, etc.)
3. Support cleanup and reset
4. Document usage in testing guide

**Recommendation 3: Add Performance Testing**

**Priority**: LOW  
**Effort**: 6 hours  
**Impact**: Validates command execution speed

**Actions**:
1. Measure command execution time
2. Set performance targets (e.g., <60s per command)
3. Track performance over time
4. Alert on performance regressions

### 7.2 Documentation Recommendations

**Recommendation 4: Create Interactive Documentation**

**Priority**: MEDIUM  
**Effort**: 8 hours  
**Impact**: Improves documentation usability

**Actions**:
1. Add code examples with syntax highlighting
2. Include interactive diagrams (Mermaid)
3. Create video walkthroughs for complex topics
4. Add search functionality

**Recommendation 5: Establish Documentation Review Process**

**Priority**: HIGH  
**Effort**: 2 hours  
**Impact**: Keeps documentation current

**Actions**:
1. Schedule quarterly documentation reviews
2. Assign documentation owners
3. Create documentation update checklist
4. Track documentation issues in GitHub

**Recommendation 6: Create Developer Onboarding Guide**

**Priority**: MEDIUM  
**Effort**: 6 hours  
**Impact**: Accelerates new developer productivity

**Actions**:
1. Document system architecture
2. Explain migration patterns
3. Provide step-by-step setup guide
4. Include common troubleshooting tips

---

## 8. References

### Primary Sources

1. **Martin Fowler - The Practical Test Pyramid** (2018)
   - URL: https://martinfowler.com/articles/practical-test-pyramid.html
   - Relevance: Test pyramid approach, test types, testing best practices
   - Key Concepts: Unit tests, integration tests, E2E tests, test structure

2. **ProofChecker Testing Standards** (TESTING_STANDARDS.md)
   - Location: Documentation/Development/TESTING_STANDARDS.md
   - Relevance: Test organization, coverage targets, TDD workflow
   - Key Concepts: Test types, naming conventions, coverage requirements

3. **ProofChecker Quality Metrics** (QUALITY_METRICS.md)
   - Location: Documentation/Development/QUALITY_METRICS.md
   - Relevance: Quality targets, measurement methods, compliance
   - Key Concepts: Coverage targets, lint compliance, performance benchmarks

4. **Phase 1 Validation Report** (Task 244)
   - Location: .opencode/specs/244_phase_1_context_index_and_research_frontmatter_prototype/reports/validation-001.md
   - Relevance: Context window measurement, validation methodology
   - Key Concepts: Context usage tracking, validation gates

5. **Phase 2 Validation Report** (Task 245)
   - Location: .opencode/specs/245_phase2_core_architecture/reports/validation-001.md
   - Relevance: Command migration patterns, orchestrator simplification
   - Key Concepts: Frontmatter delegation, workflow ownership

### Related Documentation

6. **Michael Nygard - Documenting Architecture Decisions** (2011)
   - Relevance: ADR template and best practices
   - Key Concepts: Decision documentation, rationale capture

7. **Software Engineering Best Practices**
   - Relevance: Migration patterns, testing strategies
   - Key Concepts: DRY principle, test automation, documentation standards

8. **OpenAgents Reference Implementation**
   - Relevance: Migration patterns, architectural decisions
   - Key Concepts: Context index, frontmatter delegation, agent ownership

---

## Conclusion

Phase 4 of the OpenAgents architectural migration focuses on proving the success of Phases 1-3 through comprehensive testing and establishing documentation standards for future development. The testing strategy validates 100% Stage 7 reliability through 80 test runs, while documentation patterns ensure the migration knowledge is captured for future reference.

**Key Achievements Expected**:
1. ✅ 100% Stage 7 reliability (80/80 successful runs)
2. ✅ Context window usage <10% during routing (maintained)
3. ✅ Comprehensive migration guide (Phases 1-4)
4. ✅ 3 ADRs documenting architectural decisions
5. ✅ Command and agent development templates
6. ✅ Testing and validation standards

**Total Effort**: 16-20 hours

**Risk Level**: MEDIUM with HIGH mitigation effectiveness

**Recommendation**: **Proceed with Phase 4 implementation** following the testing and documentation roadmap outlined in this research.

---

**End of Research Report**
