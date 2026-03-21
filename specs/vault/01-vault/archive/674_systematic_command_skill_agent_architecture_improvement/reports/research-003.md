# Research Report: Integrated Preflight and Postflight Operations in Workflow Skills
- **Task**: 674 - Systematic Command-Skill-Agent Architecture Improvement
- **Started**: 2026-01-24
- **Completed**: 2026-01-24
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**: 
  - Current workflow command implementations (.opencode/command/research.md, plan.md, implement.md, revise.md)
  - Workflow skill implementations (.opencode/skills/skill-researcher/SKILL.md, skill-planner/SKILL.md, skill-implementer/SKILL.md)
  - skill-status-sync implementation (.opencode/skills/skill-status-sync/SKILL.md)
  - skill-orchestrator routing patterns (.opencode/skills/skill-orchestrator/SKILL.md)
  - Postflight control patterns (.opencode/context/core/patterns/postflight-control.md)
  - Inline status update patterns (.opencode/context/core/patterns/inline-status-update.md)
  - Skill lifecycle patterns (.opencode/context/core/patterns/skill-lifecycle.md)
  - Thin wrapper patterns (.opencode/context/core/patterns/thin-wrapper-skill.md)
  - Previous research reports for task 674 (research-001.md, research-002.md)
  - Current architecture patterns and context files
- **Artifacts**: 
  - specs/674_systematic_command_skill_agent_architecture_improvement/reports/research-003.md
- **Standards**: report-format.md

## Executive Summary

The current architecture shows a fundamental misalignment between documented patterns and actual implementation. While the system has evolved toward integrated preflight/postflight in workflow skills (as documented in skill-lifecycle.md), the actual skill implementations remain thin wrappers that rely on the separate skill-status-sync component. This research reveals that integrating preflight and postflight directly into workflow skills is not only feasible but already the documented standard - the gap is in implementation, not architecture. Five specific design recommendations provide a clear path to eliminate the separate skill-status-sync dependency for workflow operations.

## Context & Scope

- **Objective**: Research integration of preflight and postflight operations directly into workflow skills instead of using separate skill-status-sync
- **Focus Areas**: Current architecture analysis, integrated preflight/postflight design, architecture benefits/drawbacks, implementation strategy
- **Scope**: /research, /plan, /revise, /implement workflow skills and their relationship to skill-status-sync

## Findings

### 1. Current Architecture Analysis

#### 1.1 Documented vs Implemented Pattern Mismatch (Critical)
- **Documented Standard**: skill-lifecycle.md clearly states "workflow skills now handle their own status updates" and shows integrated pattern as current standard
- **Actual Implementation**: skill-researcher, skill-planner, and skill-implementer are still implemented as thin wrappers without inline status updates
- **Gap**: Documentation has evolved to integrated pattern but implementations haven't caught up
- **Evidence**: All workflow skills show 7-step flow in documentation but actual SKILL.md files contain only 51 lines each

#### 1.2 skill-status-sync Role Confusion (High)
- **Original Purpose**: skill-status-sync designed for "standalone use only" and "manual status corrections or recovery operations"
- **Current Usage**: Commands reference skill-status-sync for preflight/postflight but skills don't use it
- **Missing Integration**: No clear delegation patterns from skills to skill-status-sync
- **Result**: skill-status-sync exists as 36-line utility but workflow skills don't leverage it

#### 1.3 Command-Level Reliance on Separate Components (Medium)
- **Current Pattern**: Commands implement 3-checkpoint lifecycle expecting skills to handle status updates
- **Dependency**: Commands assume skills will manage preflight/postflight but provide no mechanism
- **Gap**: No clear handoff between command-level lifecycle and skill-level status management
- **Impact**: Status updates may be skipped when skills are thin wrappers

### 2. Integrated Preflight Design

#### 2.1 Inline Status Update Patterns Already Defined (High)
- **Existing Resource**: inline-status-update.md provides complete patterns for research, planning, and implementation preflight/postflight
- **Atomic Operations**: All patterns include specs/state.json and specs/TODO.md updates with proper error handling
- **jq Escaping Solutions**: Patterns address known jq bugs with two-step update approaches
- **Readiness**: Complete implementation patterns already exist and tested

#### 2.2 Validation Gate Integration (High)
- **Session ID Tracking**: Patterns include session_id integration for traceability
- **Status Transition Validation**: Inline patterns can validate status transitions before updates
- **Error Handling**: Robust error handling with rollback capabilities
- **Atomic Operations**: All operations designed to be atomic with temp file patterns

#### 2.3 Skill Frontmatter Requirements (Medium)
- **Required Tools**: Workflow skills need Bash, Edit, Read tools (not just Task tool)
- **Current Mismatch**: Most workflow skills only allow Task tool for thin wrapper pattern
- **Tool Access**: Skills need direct file system access for status updates
- **Security**: No additional security concerns - same tools as commands

### 3. Integrated Postflight Design

#### 3.1 Artifact Linking Patterns Available (High)
- **Standardized Patterns**: inline-status-update.md includes complete postflight patterns for all workflow types
- **Artifact Registration**: Specific patterns for research, plan, and summary artifact linking
- **Idempotency**: Patterns include idempotency checks to prevent duplicate artifacts
- **State Synchronization**: Atomic updates across specs/state.json and specs/TODO.md

#### 3.2 Git Integration Without Separate Component (Medium)
- **Simple Commit Patterns**: Git commits can be handled with bash commands in skills
- **Session Tracking**: Session ID integration for commit messages already defined
- **Error Handling**: Non-blocking commit patterns with logging
- **No Dependency**: No need for separate git workflow component

#### 3.3 Postflight Control Compatibility (High)
- **Marker Protocol**: Existing postflight-control.md marker system works with integrated approach
- **Hook Integration**: SubagentStop hook continues to work with integrated postflight
- **Cleanup Patterns**: Same cleanup procedures apply
- **No Disruption**: Integration doesn't break existing postflight control mechanisms

### 4. Architecture Benefits/Drawbacks Analysis

#### 4.1 Benefits of Integrated Approach (High)

**Reduced Complexity**:
- Eliminates dependency on separate skill-status-sync for workflow operations
- Single point of responsibility for workflow lifecycle
- Fewer moving parts and potential failure modes

**Improved Reliability**:
- Atomic operations within single skill execution context
- No cross-skill communication failures
- Consistent error handling and rollback

**Better Debugging**:
- Single skill to troubleshoot for workflow issues
- Clearer ownership of lifecycle operations
- Simplified logging and tracing

**Performance**:
- Eliminates skill invocation overhead
- Fewer tool calls and context switches
- Faster execution for common workflows

#### 4.2 Drawbacks and Mitigations (Medium)

**Code Duplication**:
- **Issue**: Status update patterns duplicated across skills
- **Mitigation**: Common patterns in inline-status-update.md, reusable snippets

**Skill Complexity**:
- **Issue**: Skills become more complex than thin wrappers
- **Mitigation**: Clear patterns and standardized sections in skill-lifecycle.md

**Testing Complexity**:
- **Issue**: More logic in skills requires more comprehensive testing
- **Mitigation**: Standardized test patterns and mock state files

### 5. Implementation Strategy

#### 5.1 Migration Path (Critical)

**Phase 1: Update Workflow Skill Frontmatter**
- Add Bash, Edit, Read tools to workflow skills
- Remove context: fork and agent fields for direct execution
- Update skill descriptions to reflect integrated lifecycle

**Phase 2: Implement Integrated Preflight/Postflight**
- Add inline status update sections to each workflow skill
- Implement preflight validation using patterns from inline-status-update.md
- Implement postflight operations using same patterns
- Maintain postflight marker protocol for compatibility

**Phase 3: Update Command Integration**
- Modify commands to expect integrated skills
- Remove references to skill-status-sync in command documentation
- Update error handling to work with integrated approach

**Phase 4: Repurpose skill-status-sync**
- Keep skill-status-sync for manual operations and recovery
- Update documentation to clarify standalone usage
- Add validation commands for consistency checking

#### 5.2 Specific Implementation Recommendations

**Skills to Update**:
- skill-researcher: Add integrated research preflight/postflight
- skill-planner: Add integrated planning preflight/postflight  
- skill-implementer: Add integrated implementation preflight/postflight
- skill-lean-research: Same as skill-researcher
- skill-lean-implementation: Same as skill-implementer
- skill-latex-implementation: Same as skill-implementer

**Operations to Integrate**:
- Research: not_started/researched → researching → researched
- Planning: researched → planning → planned
- Implementation: planned → implementing → completed/partial

**Keep Separate**:
- skill-status-sync: Manual corrections and recovery only
- skill-orchestrator: Routing only, no lifecycle management
- skill-git-workflow: Utility function, not task lifecycle
- skill-meta: Task creation, not lifecycle transitions

#### 5.3 Testing and Validation Approach

**Unit Testing**:
- Test status update patterns in isolation
- Validate atomic operations and rollback
- Test error handling and edge cases

**Integration Testing**:
- Test complete workflows with integrated skills
- Validate command-skill integration
- Test postflight marker protocol compatibility

**Regression Testing**:
- Ensure existing functionality preserved
- Test manual recovery operations still work
- Validate performance improvements

## Technical Design Recommendations

### 1. Skill Structure Updates

#### Updated Frontmatter Pattern
```yaml
---
name: skill-researcher
description: Conduct general research and manage complete research lifecycle.
allowed-tools: Task, Bash, Edit, Read, Write
---
```

#### Execution Section Pattern
```markdown
## Execution

### 0. Preflight Status Update
[Update task status to "researching" using inline patterns]

### 1. Input Validation
[Validate task exists and status allows research]

### 2. Context Preparation
[Generate session_id, prepare delegation context]

### 3. Invoke Subagent
[Delegate to general-research-agent via Task tool]

### 4. Return Validation
[Validate agent return metadata]

### 5. Postflight Status Update
[Update task status to "researched", link artifacts, commit changes]

### 6. Cleanup
[Remove marker and metadata files]
```

### 2. Atomic Operation Patterns

#### Preflight Validation
```bash
# Validate task exists and status allows research
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  specs/state.json)

if [ -z "$task_data" ]; then
  echo "ERROR: Task $task_number not found"
  exit 1
fi

current_status=$(echo "$task_data" | jq -r '.status')
if [[ ! "$current_status" =~ ^(not_started|researched|partial|blocked)$ ]]; then
  echo "ERROR: Task $task_number has status '$current_status', cannot start research"
  exit 1
fi
```

#### Integrated Status Update
```bash
# Atomic preflight update
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"

jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researching" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

### 3. Error Handling Patterns

#### Rollback on Failure
```bash
# Store previous state for rollback
previous_status=$(echo "$task_data" | jq -r '.status')

# On agent failure, rollback status
if [ "$agent_status" != "success" ]; then
  jq --arg status "$previous_status" \
    '(.active_projects[] | select(.project_number == '$task_number')).status = $status' \
    specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
  echo "ERROR: Agent failed, rolled back status to $previous_status"
  exit 1
fi
```

#### Postflight Error Recovery
```bash
# Log errors but don't fail workflow
if ! jq --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    ([(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "research")] + [{"path": $path, "type": "research"}])' \
  specs/state.json > /tmp/state.json; then
  echo "WARNING: Failed to link artifact, but status updated successfully"
fi
```

### 4. Integration Testing Framework

#### Test Data Patterns
```bash
# Create test state file
cat > test-state.json << 'EOF'
{
  "active_projects": [
    {
      "project_number": 674,
      "project_name": "test_task",
      "status": "not_started",
      "language": "general",
      "description": "Test task for integrated skill validation"
    }
  ]
}
EOF
```

#### Validation Commands
```bash
# Test preflight validation
validate_preflight() {
  local task_number=$1
  local expected_status=$2
  
  # Run skill preflight
  # Check status updated correctly
  # Validate session_id set
  # Check specs/TODO.md updated
}

# Test postflight validation  
validate_postflight() {
  local task_number=$1
  local expected_status=$2
  local artifact_type=$3
  
  # Check status updated
  # Validate artifact linked
  # Check git commit created
  # Verify metadata cleanup
}
```

## Risk Assessment

### High Risk
- **Implementation Complexity**: Multiple skills need coordinated updates
- **Testing Coverage**: Comprehensive testing required to ensure reliability

### Medium Risk
- **Performance Impact**: Additional inline operations may slow skill execution
- **Debugging Complexity**: More logic in skills may complicate troubleshooting

### Low Risk
- **Breaking Changes**: Integration maintains backward compatibility
- **Tool Access**: No additional permissions required

### Mitigation Strategies
1. **Incremental Migration**: Update skills one at a time with rollback capability
2. **Comprehensive Testing**: Unit and integration tests for each skill
3. **Documentation Updates**: Clear patterns and examples for developers
4. **Monitoring**: Logging and health checks for integrated operations

## Success Criteria

### Functional Requirements
1. **Complete Integration**: All workflow skills handle their own preflight/postflight
2. **Atomic Operations**: Status updates atomic across all state files
3. **Artifact Management**: Automatic artifact linking and git commits
4. **Error Recovery**: Robust error handling and rollback mechanisms
5. **Backward Compatibility**: Existing workflows continue to function

### Non-Functional Requirements
1. **Performance**: No significant slowdown in skill execution (<10% target)
2. **Reliability**: Reduced failure points compared to separate skill-status-sync
3. **Maintainability**: Clear patterns and standardized implementations
4. **Debugging**: Simplified troubleshooting with single point of responsibility

## Implementation Priority Matrix

### Phase 1: Foundation (Day 1)
1. **Update skill-researcher** - Implement integrated research lifecycle
2. **Update skill-planner** - Implement integrated planning lifecycle  
3. **Test Basic Integration** - Validate preflight/postflight patterns work

### Phase 2: Expand (Day 1-2)
1. **Update skill-implementer** - Implement integrated implementation lifecycle
2. **Update Lean Skills** - Apply same patterns to skill-lean-research and skill-lean-implementation
3. **Integration Testing** - Test complete workflows

### Phase 3: Finalize (Day 2)
1. **Update Commands** - Remove references to separate skill-status-sync
2. **Documentation Updates** - Update skill-lifecycle.md and related patterns
3. **Performance Validation** - Benchmark against current implementation

## Next Steps

1. **Immediate Actions**
   - Begin with skill-researcher integration as proof of concept
   - Create test framework for validating integrated operations
   - Update skill frontmatter to include necessary tools

2. **Dependencies**
   - No blocking dependencies - can proceed with skill updates immediately
   - Coordination needed for command updates after skills complete

3. **Validation Approach**
   - Unit test each integrated skill with mock data
   - Integration test complete workflows
   - Performance benchmarking against current implementation
   - User acceptance testing with real scenarios

---

**Status**: Ready for implementation phase
**Priority**: High - eliminates unnecessary complexity and improves system reliability
**Next Phase**: Begin skill integration updates starting with skill-researcher