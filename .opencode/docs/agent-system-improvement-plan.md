# Systematic Improvement Plan for .opencode/ Agent System

## Executive Summary

The .opencode/ agent system has several gaps compared to the .claude/ system that cause the reported issues:
1. Task creation sometimes implements instead of just creating entries
2. Status updates are not atomic across TODO.md and state.json  
3. Artifacts aren't consistently linked to tasks
4. No unified status synchronization mechanism

## Root Cause Analysis

### Issue 1: /task Command Implements Tasks
**Symptom**: "/task command often just implements the task instead of creating a task entry"
**Root Cause**: 
- The task creation validation (lines 86-109 in task.md) tries to detect implementation keywords
- This heuristic is unreliable and context-dependent
- The command delegates to subagents that may ignore the "task creation only" constraint

**Solution**: Implement strict architectural barriers where task-creator subagent has permissions that ONLY allow writing to TODO.md and state.json

### Issue 2: No Atomic Status Synchronization  
**Symptom**: "doesn't typically update the status of the task"
**Root Cause**:
- Commands try to update status via direct delegation to status-sync-manager
- But status-sync-manager is not properly implemented in .opencode/
- Commands fall back to manual updates that aren't atomic

**Solution**: Implement a proper status-sync-manager subagent that provides two-phase commit atomic updates

### Issue 3: Missing Artifact Links
**Symptom**: "doesn't typically link them in the task"
**Root Cause**:
- Postflight stages validate artifacts exist but don't ensure they're linked
- No unified mechanism for linking artifacts to tasks across both TODO.md and state.json

**Solution**: Enhance status-sync-manager to handle artifact linking atomically

## Implementation Plan

### Phase 1: Implement Atomic Status Sync Manager

**File**: `.opencode/agent/subagents/status-sync-manager.md`

Key features:
- Two-phase commit atomic updates
- Validates status transitions
- Updates TODO.md, state.json, and plan files together
- Links artifacts to tasks
- Rollback on failure

### Phase 2: Fix Task Creation Architectural Barriers

**File**: `.opencode/agent/subagents/task-creator.md`

Key features:
- Permissions ONLY allow writing to TODO.md and state.json
- No implementation tools allowed
- Creates task entries atomically
- Validates no implementation keywords

### Phase 3: Update Command Files

**Files to update**:
- `.opencode/command/task.md` - Fix validation and delegation
- `.opencode/command/research.md` - Implement proper preflight/postflight
- `.opencode/command/implement.md` - Implement proper preflight/postflight  
- `.opencode/command/plan.md` - Implement proper preflight/postflight
- `.opencode/command/revise.md` - Implement proper preflight/postflight

### Phase 4: Add Subagent Return Format Validation

**File**: `.opencode/context/core/formats/subagent-return-format.md`

Key features:
- Standardized return format
- Required fields validation
- Artifact metadata structure
- Error handling patterns

### Phase 5: Enhance Artifact Management

**File**: `.opencode/context/core/system/artifact-management.md`

Key features:
- Artifact linking patterns
- Validation requirements
- Summary artifact requirements
- Context window protection

## Detailed Implementation

### 1. Status Sync Manager Implementation

The status-sync-manager will provide these operations:

```json
{
  "operation": "update_status",
  "task_number": N,
  "new_status": "researched|planned|implementing|completed|partial|blocked",
  "timestamp": "2026-01-16T10:00:00Z",
  "artifacts": [
    {
      "type": "research|plan|implementation",
      "path": "/path/to/artifact.md",
      "summary": "Brief description"
    }
  ],
  "session_id": "sess_...",
  "delegation_depth": 1,
  "delegation_path": ["command", "status-sync-manager"]
}
```

Two-phase commit:
1. **Prepare Phase**: Read all files, validate transitions, prepare updates
2. **Commit Phase**: Write files in dependency order, verify each write

### 2. Task Creator Permission Model

The task-creator will have:
- **Allowed tools**: Read(.opencode/specs/*), Edit(.opencode/specs/TODO.md), Bash(jq:*), Bash(date:*)
- **Forbidden tools**: Write(except .opencode/specs/), Bash(build:*), Edit(source files)

### 3. Command Pattern Updates

All commands will follow this pattern:
```
Stage 1: ParseAndValidate
Stage 1.5: Preflight (update status to IN_PROGRESS via status-sync-manager)
Stage 2: Delegate (to research/plan/implement agent)
Stage 3: ValidateReturn
Stage 3.5: Postflight (update final status + link artifacts via status-sync-manager)
Stage 4: RelayResult
```

### 4. Artifact Linking Format

In TODO.md:
```markdown
### 259. Task Title
- **Effort**: 4 hours
- **Status**: [COMPLETED]
- **Priority**: Medium
- **Language**: lean

**Description**: Task description

**Artifacts**:
- [Research Report](specs/259_task_slug/reports/research-001.md)
- [Implementation Plan](specs/259_task_slug/plans/implementation-001.md)
- [Implementation Summary](specs/259_task_slug/summaries/implementation-summary-20260116.md)
```

In state.json:
```json
{
  "project_number": 259,
  "status": "completed",
  "artifacts": [
    {
      "type": "research",
      "path": ".opencode/specs/259_task_slug/reports/research-001.md",
      "created": "2026-01-16T10:00:00Z"
    },
    {
      "type": "plan", 
      "path": ".opencode/specs/259_task_slug/plans/implementation-001.md",
      "created": "2026-01-16T11:00:00Z"
    }
  ]
}
```

## Success Metrics

1. **Task Creation**: 100% of /task commands create entries only (no implementation)
2. **Status Updates**: 100% atomic across TODO.md and state.json
3. **Artifact Links**: 100% of created artifacts are linked to tasks
4. **Rollback Success**: 100% of failed updates rollback cleanly
5. **User Experience**: Clear status transitions visible immediately

## Implementation Timeline

- **Day 1**: Implement status-sync-manager subagent
- **Day 2**: Implement task-creator with proper permissions
- **Day 3**: Update /task command with proper validation
- **Day 4**: Update /research and /plan commands with preflight/postflight
- **Day 5**: Update /implement and /revise commands with preflight/postflight
- **Day 6**: Add validation and testing
- **Day 7**: Documentation and rollout

## Testing Strategy

1. Unit test each subagent in isolation
2. Integration test command workflows end-to-end
3. Test failure scenarios and rollback
4. Verify atomic updates with concurrent access
5. User acceptance testing with sample tasks

## Rollback Plan

If issues arise:
1. Revert to current command files
2. Keep new subagents for future integration
3. Document lessons learned
4. Plan phased rollout with feature flags