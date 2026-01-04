# Task 169: Consumer Audit Report

**Date**: 2025-12-24
**Audit Scope**: All /task, task-executor, and batch-task-orchestrator references
**Status**: COMPLETED

## Executive Summary

- **Total /task references found**: 259 (excluding archives and task 169 specs)
- **task-executor references**: 6 in command files
- **batch-task-orchestrator references**: 6 in command files
- **Files requiring updates**: 80+ files across commands, agents, documentation, and standards

## Critical Findings

### 1. Command Files with Direct Dependencies
- `.opencode/command/implement.md` - Already exists (should be task.md → implement.md rename)
- `.opencode/command/optimize.md` - References batch-task-orchestrator
- `.opencode/command/meta.md` - References task-executor
- `.opencode/command/task.md` - **PRIMARY FILE TO RENAME**

### 2. Agent Files Consuming Return Formats
- `.opencode/agent/orchestrator.md` - Routes to task-executor
- `.opencode/agent/subagents/task-executor.md` - **PRIMARY AGENT** (needs return format update)
- `.opencode/agent/subagents/batch-task-orchestrator.md` - **BATCH AGENT** (needs return format update)

### 3. Documentation Files with /task References
- `.opencode/README.md` - 7 references to /task command
- `.opencode/QUICK-START.md` - Example usage
- `.opencode/SYSTEM_SUMMARY.md` - Command table and workflow descriptions
- `Documentation/ProjectInfo/FEATURE_REGISTRY.md` - Feature descriptions
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` - Task status references

### 4. Standards and Context Files
- `.opencode/context/core/standards/tasks.md` - Task execution standards
- `.opencode/context/core/standards/commands.md` - Command standards
- `.opencode/context/core/system/artifact-management.md` - Artifact requirements
- `.opencode/context/core/workflows/task-breakdown.md` - Task workflow patterns

### 5. Spec Files (Non-Archive)
- `.opencode/specs/TODO.md` - Task 169 description and acceptance criteria
- `.opencode/specs/171_gap_analysis_20251224/reports/analysis-001.md` - References /task workflow
- `.opencode/specs/research/context-window-protection-and-agent-communication.md` - Research on /task improvements

## Consumption Patterns

### task-executor Return Format Consumers
**Current Format** (lines 559-706 in task-executor.md):
- Returns verbose coordinator_results
- Returns full workflow_executed details
- Returns complete todo_status_tracking
- **Estimated size**: 100+ lines per task

**Consumers**:
1. **orchestrator.md** - Receives results from task-executor routing
2. **batch-task-orchestrator.md** - Aggregates task-executor results for batch execution
3. **implement.md** (formerly task.md) - Primary command interface

**Required Updates**:
- All consumers must handle new artifact-first format
- Remove dependencies on coordinator_results, workflow_executed fields
- Add handling for artifacts array, summary, key_metrics fields

### batch-task-orchestrator Return Format Consumers
**Current Format** (lines 344-398):
- Returns full task results array
- Returns detailed failure information
- **Estimated size**: 1000+ lines for 10 tasks

**Consumers**:
1. **implement.md** - Receives batch results
2. **optimize.md** - May coordinate batch operations

**Required Updates**:
- Implement progressive summarization
- Return brief summaries instead of full results
- Target: <50 lines per 10 tasks

## /task → /implement Rename Scope

### Files Requiring Rename Updates (80+ files)

**Category 1: Command Files** (5 files)
- `.opencode/command/task.md` → `.opencode/command/implement.md` (RENAME)
- `.opencode/command/README.md` - Update command table
- `.opencode/command/optimize.md` - Update references
- `.opencode/command/meta.md` - Update references
- `.opencode/command/implement.md` - Already exists, verify no conflicts

**Category 2: Agent Files** (60+ files)
- All subagent files with `/task` references in examples or routing
- Primary: task-executor.md, batch-task-orchestrator.md, orchestrator.md

**Category 3: Documentation** (10+ files)
- README.md, QUICK-START.md, SYSTEM_SUMMARY.md
- Documentation/ProjectInfo/*.md files
- All user-facing guides and tutorials

**Category 4: Standards and Context** (5+ files)
- context/core/standards/tasks.md
- context/core/standards/commands.md
- context/core/workflows/task-breakdown.md

**Category 5: Spec Files** (5+ files)
- specs/TODO.md
- specs/171_gap_analysis_20251224/reports/analysis-001.md
- specs/research/context-window-protection-and-agent-communication.md

## Hidden Dependencies

**None identified** - All dependencies are explicit through routing and command invocation.

## External Integrations

**None identified** - No external systems consume these formats.

## Validation Checklist

- [x] All command files identified
- [x] All agent files identified
- [x] All documentation files identified
- [x] Consumption patterns documented
- [x] No hidden dependencies found
- [x] No external integrations found
- [x] Rename scope catalogued

## Recommendations

1. **Phase 1b is CRITICAL** - Must update all 80+ files atomically to prevent broken references
2. **Use feature branch** - All changes must be on dedicated branch until Phase 7 complete
3. **Test each category** - Validate command files, then agents, then documentation
4. **Automated validation** - Grep for remaining /task references after rename
5. **Rollback ready** - Maintain clean main branch for instant revert if needed

## Next Steps

1. Proceed to Phase 1a: Define new return format schemas
2. Create detailed file-by-file update plan for Phase 1b
3. Prepare validation scripts for post-rename verification
