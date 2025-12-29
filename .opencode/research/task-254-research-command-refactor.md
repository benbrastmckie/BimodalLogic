# Research Report: /research Command Refactoring Analysis

**Task**: 254 - Refactor /research command to directly invoke agents and properly manage task status and state updates  
**Report**: task-254-research-command-refactor  
**Date**: 2025-12-29  
**Researcher**: researcher  
**Session**: sess_1767033346_ynt3nt

## Executive Summary

Analysis of the /research command reveals systematic failures caused by split implementation (research.md routing + research-routing.md redundant), incomplete workflow execution (stops after stages 1-3), and missing status/state management. The command does not update TODO.md to [RESEARCHING]/[RESEARCHED], does not update state.json, does not link research reports, and does not create git commits. Root cause: Command contains workflow as XML documentation (narrative) rather than executable code, causing Claude to skip stages 4-8 as optional guidance. Solution: Adopt OpenAgents frontmatter delegation pattern proven in Task 240 migration - commands define "what" via frontmatter, agents own "how" via executable workflows. Recommended architecture: Single unified research.md (150-200 lines) with frontmatter delegation to researcher.md agent that owns complete 8-stage workflow including status updates, state management, and git commits. Implementation follows Task 240 Phase 1 proven pattern with validation showing 100% Stage 7 execution reliability.

## Research Scope

**Objective**: Analyze /research command failures and identify refactoring approach using successful OpenAgents migration patterns

**Sources**:
- `.opencode/command/research.md` (current routing implementation, 272 lines)
- `.opencode/command/research-routing.md` (redundant file, 167 lines)
- `.opencode/command/research.md.backup` (backup file, 678 lines)
- `.opencode/command/plan.md` (successful pattern reference, 269 lines)
- `.opencode/command/implement.md` (successful pattern reference, 373 lines)
- `.opencode/specs/240_*/reports/research-001.md` (OpenAgents comparative analysis)
- `.opencode/specs/240_*/plans/implementation-002.md` (OpenAgents migration plan)
- `.opencode/context/core/standards/delegation.md` (delegation standard)
- `.opencode/context/core/system/state-management.md` (state management standard)
- `.opencode/context/common/system/git-commits.md` (git commit standard)
- `.opencode/context/common/system/artifact-management.md` (artifact patterns)

**Methodology**: File analysis, pattern comparison, root cause analysis, architectural recommendation

## Key Findings

### Finding 1: Split Implementation Creates Confusion

**Current State**:
- `research.md` (272 lines): Frontmatter delegation pattern with routing stages 1-3
- `research-routing.md` (167 lines): Redundant routing-only file
- `research.md.backup` (678 lines): Full workflow implementation backup

**Problems**:
1. **Redundancy**: Two active files (research.md + research-routing.md) with overlapping content
2. **Incomplete Execution**: research.md defines stages 1-3 only, stops before execution
3. **Backup Confusion**: Presence of .backup file suggests incomplete migration
4. **No Clear Owner**: Unclear which file is authoritative

**Evidence from research.md**:
```yaml
---
name: research
agent: subagents/researcher
description: "Conduct research and create reports with [RESEARCHED] status"
routing:
  lean: lean-research-agent
  default: researcher
---
```

**Evidence from research-routing.md**:
```yaml
---
name: research
agent: orchestrator
execution_file: research-execution.md
---
```

**Analysis**: research.md has correct frontmatter delegation pattern but incomplete workflow. research-routing.md references non-existent research-execution.md file. Backup file contains full workflow but is outdated pattern.

**Recommendation**: Delete research-routing.md and research.md.backup. Consolidate to single research.md with frontmatter delegation.

### Finding 2: Workflow Stops After Routing Stages 1-3

**Current Workflow** (research.md):
- Stage 1 (Preflight): Parse arguments, validate task
- Stage 2 (CheckLanguage): Extract language, determine routing
- Stage 3 (PrepareDelegation): Generate session ID, prepare context
- **STOPS HERE** - No stages 4-8 execution

**Missing Stages**:
- Stage 4 (InvokeAgent): Delegate to researcher agent
- Stage 5 (ValidateReturn): Verify research artifact created
- Stage 6 (PrepareReturn): Format return object
- Stage 7 (Postflight): Update status, create git commit
- Stage 8 (ReturnSuccess): Return result to user

**Root Cause**: Command contains workflow as XML documentation (narrative) in research.md.backup, not executable code. Current research.md only defines routing, delegates to non-existent execution file.

**Evidence from research-routing.md**:
```xml
<execution_transition>
  After Stage 3 complete:
  - Load execution file: @.opencode/command/research-execution.md
  - Execution file contains Stages 4-8
</execution_transition>
```

**Problem**: research-execution.md does not exist. Workflow stops at Stage 3.

**Recommendation**: Move stages 4-8 to researcher.md agent as executable workflow, not XML documentation.

### Finding 3: Status Transitions Not Implemented

**Expected Status Flow**:
```
[NOT STARTED] → [RESEARCHING] → [RESEARCHED]
```

**Current Behavior**:
- No status update to [RESEARCHING] at start (Stage 1)
- No status update to [RESEARCHED] at completion (Stage 7)
- TODO.md status remains unchanged
- state.json not updated

**Evidence from research.md**:
```markdown
## Status Transitions

| From | To | Condition |
|------|-----|-----------|
| [NOT STARTED] | [RESEARCHING] | Research started (Stage 1) |
| [RESEARCHING] | [RESEARCHED] | Research completed successfully (Stage 7) |
```

**Problem**: Status transitions documented but not implemented. No delegation to status-sync-manager.

**Comparison with /plan command** (working pattern):
```markdown
**Status Update**: Delegated to `status-sync-manager` for atomic synchronization across TODO.md and state.json.
```

**Analysis**: /plan and /implement commands delegate status updates to status-sync-manager. /research command documents status transitions but does not invoke status-sync-manager.

**Recommendation**: Add status-sync-manager delegation in researcher.md Stage 1 (mark [RESEARCHING]) and Stage 7 (mark [RESEARCHED]).

### Finding 4: State.json Not Updated

**Expected state.json Updates**:
```json
{
  "status": "researched",
  "started": "2025-12-29",
  "completed": "2025-12-29",
  "artifacts": [
    {
      "type": "research",
      "path": ".opencode/specs/254_*/reports/research-001.md"
    }
  ]
}
```

**Current Behavior**:
- state.json not updated at all
- No status field changes
- No timestamp tracking
- No artifact paths recorded

**Root Cause**: Stage 7 not executed, status-sync-manager not invoked.

**Comparison with state-management.md standard**:
```markdown
### status-sync-manager

The `status-sync-manager` specialist provides atomic multi-file updates using two-phase commit:

**Phase 1 (Prepare)**:
1. Read all target files into memory
2. Validate current status allows requested transition
3. Prepare all updates in memory

**Phase 2 (Commit)**:
1. Write files in dependency order: TODO.md → state.json → project state
2. Verify each write before proceeding
3. On any write failure, rollback all previous writes
```

**Recommendation**: Invoke status-sync-manager in researcher.md Stage 7 for atomic TODO.md + state.json updates.

### Finding 5: Research Reports Not Linked to TODO.md

**Expected TODO.md Link**:
```markdown
### 254. Refactor /research command
**Status**: [RESEARCHED]
**Research**: [Research Report](.opencode/specs/254_*/reports/research-001.md)
```

**Current Behavior**:
- Research artifacts created by researcher agent
- No links added to TODO.md task entry
- User cannot find research reports from TODO.md

**Root Cause**: Stage 7 artifact linking not implemented.

**Comparison with artifact-management.md**:
```markdown
### Artifact Linking

Link artifacts in .opencode/specs/TODO.md:
  - Research Report: {report_path}

Reference: artifact-management.md "Context Window Protection via Metadata Passing"
```

**Recommendation**: Add artifact linking logic to researcher.md Stage 7 postflight.

### Finding 6: Git Commits Not Created

**Expected Git Workflow**:
```bash
git add .opencode/specs/254_*/reports/research-001.md
git add .opencode/specs/TODO.md
git add .opencode/specs/state.json
git commit -m "task 254: research completed"
```

**Current Behavior**:
- No git commits created
- Research artifacts not committed
- Status updates not committed
- Manual git operations required

**Root Cause**: Stage 7 git-workflow-manager delegation not implemented.

**Comparison with git-commits.md standard**:
```markdown
## When to Commit
- After artifacts are written (code, docs, reports, plans, summaries) and status/state/TODO updates are applied.
- Once validation steps for the scope are done.

## Scoping Rules
- Stage only files relevant to the current task/feature.
- Use `git add <file1> <file2>`; **do not** use `git add -A`.
```

**Comparison with /plan command** (working pattern):
```markdown
### Git Workflow

Git commits delegated to `git-workflow-manager` for standardized commits:
- Commit message format: `task {number}: {description}`
- Scope files: All implementation artifacts + TODO.md + state.json
```

**Recommendation**: Add git-workflow-manager delegation in researcher.md Stage 7 after status updates.

### Finding 7: Successful Patterns from /plan and /implement Commands

**Pattern Analysis**:

Both /plan and /implement commands successfully implement complete workflows with:
1. Frontmatter delegation to agents
2. Status updates via status-sync-manager
3. Git commits via git-workflow-manager
4. Artifact linking to TODO.md
5. State.json updates

**Evidence from plan.md**:
```yaml
---
name: plan
agent: subagents/planner
description: "Create implementation plans with [PLANNED] status"
---
```

**Evidence from implement.md**:
```yaml
---
name: implement
agent: subagents/implementer
description: "Execute implementation with resume support and [COMPLETED] status"
routing:
  lean: lean-implementation-agent
  default: implementer
---
```

**Key Success Factors**:
1. **Frontmatter Delegation**: Commands define "what", agents define "how"
2. **Agent Workflow Ownership**: Agents own complete 8-stage workflow
3. **Status-Sync-Manager**: Atomic TODO.md + state.json updates
4. **Git-Workflow-Manager**: Standardized git commits
5. **Artifact Management**: Lazy directory creation, artifact linking

**Recommendation**: Apply same pattern to /research command.

### Finding 8: OpenAgents Migration Proven Pattern (Task 240)

**Task 240 Phase 1 Results** (from implementation-002.md):

**Validation Criteria**:
- Context window usage during /research routing: under 15% (down from 60-70%)
- research.md file size: under 200 lines (down from 684 lines)
- Stage 7 execution rate: 100% in 20 consecutive runs
- researcher.md owns complete workflow including status updates

**Pattern Applied**:
1. Create frontmatter delegation in research.md
2. Extract workflow stages to researcher.md
3. Reduce research.md to 150-200 lines (frontmatter + description only)
4. researcher.md owns stages 4-8 including status updates
5. Lazy-loading context via index.md

**Success Metrics**:
- 100% Stage 7 execution reliability
- 63% command file size reduction
- 60-70% context window reduction

**Recommendation**: Follow Task 240 Phase 1 proven pattern exactly.

## Root Cause Analysis

### Problem: /research Command Systematic Failures

**Symptoms**:
1. Workflow stops after stages 1-3
2. No status updates to [RESEARCHING]/[RESEARCHED]
3. No state.json updates
4. No research report links in TODO.md
5. No git commits created

**Root Cause**: Command contains workflow as XML documentation (narrative) rather than executable code. Claude interprets XML stages as optional guidance, not requirements.

**Evidence from research.md.backup**:
```xml
<stage id="7" name="Postflight">
  <status_transition>
    Completion: [RESEARCHED] + **Completed**: {date}
  </status_transition>
  
  <atomic_update>
    <action>INVOKE status-sync-manager subagent</action>
  </atomic_update>
  
  <git_commit>
    <invocation>
      STEP 1: PREPARE git-workflow-manager delegation
    </invocation>
  </git_commit>
</stage>
```

**Problem**: XML stages are narrative documentation, not executable code. Claude skips them.

**Why OpenAgents Pattern Avoids This**:
1. Agents own workflow stages as executable code, not documentation
2. Commands delegate immediately without embedded workflow
3. Agents return validated results with artifacts
4. Stage 7 always executes because agent owns it

**Solution**: Move workflow ownership from command to agent.

## Recommended Architecture

### Unified /research Command Structure

**File**: `.opencode/command/research.md` (150-200 lines)

**Structure**:
```yaml
---
name: research
agent: subagents/researcher
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
routing:
  lean: lean-research-agent
  default: researcher
---

## Purpose
Conduct research for specified task, create research reports, update status to [RESEARCHED].

## Usage
/research TASK_NUMBER [PROMPT] [FLAGS]

## Examples
- /research 197
- /research 197 "Focus on CLI integration"
- /research 197 --divide

## Workflow
1. Parse arguments, validate task exists
2. Extract language, determine routing (lean → lean-research-agent, else → researcher)
3. Delegate to researcher agent with task context
4. Agent executes complete workflow (stages 4-8)
5. Return standardized result to user

## Artifacts Created
- Research Report: .opencode/specs/{task_number}_{slug}/reports/research-001.md
- Summary: Metadata in return object (not separate file)

## Status Transitions
| From | To | Condition |
|------|-----|-----------|
| [NOT STARTED] | [RESEARCHING] | Research started |
| [RESEARCHING] | [RESEARCHED] | Research completed |

**Status Update**: Delegated to researcher agent → status-sync-manager
```

**Key Changes**:
1. Remove stages 4-8 XML documentation
2. Remove redundant routing details
3. Keep frontmatter delegation pattern
4. Keep usage examples and artifact descriptions
5. Delegate workflow execution to researcher agent

### Researcher Agent Workflow Ownership

**File**: `.opencode/agent/subagents/researcher.md`

**Workflow Stages** (agent owns these):

**Stage 1: Preflight**
- Parse task number from delegation context
- Validate task exists in TODO.md
- Extract task description and language
- **Invoke status-sync-manager**: Mark task [RESEARCHING], add **Started**: {date}

**Stage 2: Research Execution**
- Conduct research using web sources, documentation
- Gather findings, citations, recommendations
- Create research report artifact

**Stage 3: Artifact Creation**
- Lazy create project directory: .opencode/specs/{task_number}_{slug}/
- Lazy create reports/ subdirectory
- Write research-001.md report
- Validate artifact exists and is non-empty

**Stage 4: Validation**
- Verify research report created successfully
- Verify report contains findings and citations
- Prepare return object with artifact path and summary

**Stage 5: Postflight**
- **Invoke status-sync-manager**: Mark task [RESEARCHED], add **Completed**: {date}
- Link research report in TODO.md task entry
- Update state.json with artifact path
- **Invoke git-workflow-manager**: Create commit with research artifacts + status updates

**Stage 6: Return**
- Return standardized format per delegation.md
- Include brief summary (<100 tokens)
- Include artifact path
- Include session metadata

**Key Responsibilities**:
1. Status updates via status-sync-manager (Stage 1 and Stage 5)
2. Artifact creation with lazy directory creation (Stage 3)
3. Artifact validation (Stage 4)
4. Git commits via git-workflow-manager (Stage 5)
5. Standardized return format (Stage 6)

### Status Transition Workflow

**Stage 1 (Preflight) - Mark [RESEARCHING]**:
```markdown
<status_update>
  Invoke status-sync-manager:
  - task_number: {number}
  - new_status: "researching"
  - timestamp: {ISO8601 date}
  - session_id: {session_id}
  
  Updates:
  - TODO.md: [RESEARCHING], **Started**: {date}
  - state.json: status = "researching", started = "{date}"
</status_update>
```

**Stage 5 (Postflight) - Mark [RESEARCHED]**:
```markdown
<status_update>
  Invoke status-sync-manager:
  - task_number: {number}
  - new_status: "researched"
  - timestamp: {ISO8601 date}
  - validated_artifacts: [{research report path}]
  
  Updates:
  - TODO.md: [RESEARCHED], **Completed**: {date}, **Research**: [link]
  - state.json: status = "researched", completed = "{date}", artifacts = [...]
</status_update>
```

**Atomic Guarantee**: status-sync-manager uses two-phase commit - all files updated or none updated.

### State.json Update Pattern

**Before Research**:
```json
{
  "project_number": 254,
  "status": "not_started",
  "created": "2025-12-29T10:00:00Z"
}
```

**After Stage 1 (Preflight)**:
```json
{
  "project_number": 254,
  "status": "researching",
  "started": "2025-12-29",
  "created": "2025-12-29T10:00:00Z"
}
```

**After Stage 5 (Postflight)**:
```json
{
  "project_number": 254,
  "status": "researched",
  "started": "2025-12-29",
  "completed": "2025-12-29",
  "artifacts": [
    {
      "type": "research",
      "path": ".opencode/specs/254_*/reports/research-001.md",
      "summary": "Analysis of /research command refactoring"
    }
  ],
  "created": "2025-12-29T10:00:00Z",
  "last_updated": "2025-12-29"
}
```

**Update Mechanism**: status-sync-manager performs atomic updates across TODO.md, state.json, and project state.json.

### Git Commit Pattern

**Invocation** (Stage 5 Postflight):
```markdown
<git_commit>
  Invoke git-workflow-manager:
  - scope_files: [
      "{research_report_path}",
      ".opencode/specs/TODO.md",
      ".opencode/specs/state.json",
      ".opencode/specs/{task_number}_{slug}/state.json"
    ]
  - message_template: "task {number}: research completed"
  - task_context: {
      task_number: {number},
      description: "research completed"
    }
  - session_id: {session_id}
</git_commit>
```

**Expected Commit**:
```bash
git add .opencode/specs/254_*/reports/research-001.md
git add .opencode/specs/TODO.md
git add .opencode/specs/state.json
git add .opencode/specs/254_*/state.json
git commit -m "task 254: research completed"
```

**Scoping**: Only files relevant to research task, following git-commits.md standard.

### Artifact Management Pattern

**Lazy Directory Creation**:
```markdown
1. Do NOT create directories during routing (stages 1-3)
2. Create project directory when writing first artifact (stage 3):
   - .opencode/specs/{task_number}_{slug}/
3. Create reports/ subdirectory when writing research-001.md
4. Do NOT create summaries/ subdirectory (summary is metadata, not artifact)
```

**Artifact Validation**:
```markdown
Before returning (Stage 4):
- Verify research-001.md exists on disk
- Verify research-001.md is non-empty (size > 0)
- Verify summary field in return object is brief (<100 tokens)
- Return validation result in metadata field

If validation fails:
- Return status: "failed"
- Include error in errors array
- Recommendation: "Fix artifact creation and retry"
```

**Context Window Protection**:
```markdown
Research creates 1 artifact (report only). Summary is returned as metadata
in the return object summary field, NOT as a separate artifact file.

This protects the orchestrator's context window from bloat while providing
necessary metadata for task tracking.

Reference: artifact-management.md "Context Window Protection via Metadata Passing"
```

### Error Handling Patterns

**Task Not Found**:
```markdown
Error: Task {task_number} not found in .opencode/specs/TODO.md

Recommendation: Verify task number exists in TODO.md
```

**Language Extraction Failed**:
```markdown
Warning: Language not found for task {task_number}, defaulting to 'general'

Proceeding with researcher agent (web search, documentation)
```

**Research Timeout**:
```markdown
Warning: Research timed out after 3600s

Partial artifacts created: {list}

Resume with: /research {task_number}
```

**Status Update Failed**:
```markdown
Error: Failed to update task status

Details: {error_message}

Artifacts created:
- Research Report: {report_path}

Manual recovery steps:
1. Verify research artifact exists: {report_path}
2. Manually update TODO.md status to [RESEARCHED]
3. Manually update state.json status to "researched"

Or retry: /research {task_number}
```

**Git Commit Failed (non-critical)**:
```markdown
Warning: Git commit failed

Research completed successfully: {report_path}
Task status updated to [RESEARCHED]

Manual commit required:
  git add {files}
  git commit -m "task {number}: research completed"

Error: {git_error}
```

## Implementation Guidance

### Step 1: Clean Up Redundant Files

**Actions**:
1. Delete `.opencode/command/research-routing.md` (redundant)
2. Delete `.opencode/command/research.md.backup` (outdated)
3. Keep `.opencode/command/research.md` as single source of truth

**Validation**:
```bash
# Verify only research.md exists
ls -la .opencode/command/research*
# Expected: research.md only
```

### Step 2: Simplify research.md to Frontmatter Delegation

**Current**: 272 lines with routing stages 1-3  
**Target**: 150-200 lines with frontmatter + description only

**Changes**:
1. Keep frontmatter delegation (lines 1-10)
2. Keep purpose, usage, examples (lines 14-48)
3. Keep artifacts created, status transitions (lines 101-134)
4. **Remove**: Routing stages 1-3 XML documentation
5. **Remove**: Execution stage references
6. **Remove**: Detailed context loading instructions
7. **Add**: Brief workflow description delegating to researcher agent

**Template**:
```markdown
---
name: research
agent: subagents/researcher
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
routing:
  lean: lean-research-agent
  default: researcher
---

## Purpose
[Keep existing]

## Usage
[Keep existing]

## Workflow
This command delegates to researcher agent for complete workflow execution:
1. Parse arguments, validate task
2. Extract language, determine routing
3. Delegate to researcher agent
4. Agent executes research, creates artifacts, updates status
5. Return result to user

## Artifacts Created
[Keep existing]

## Status Transitions
[Keep existing]

## Error Handling
[Keep existing]
```

### Step 3: Update researcher.md to Own Complete Workflow

**Current**: researcher.md exists but may not own complete workflow  
**Target**: researcher.md owns stages 1-6 including status updates

**Add to researcher.md**:

**Stage 1: Preflight**
```markdown
<stage_1_preflight>
  <action>Parse arguments, validate task, update status to [RESEARCHING]</action>
  
  <process>
    1. Extract task_number from delegation context
    2. Validate task exists in TODO.md
    3. Extract task description and language
    4. Invoke status-sync-manager:
       - new_status: "researching"
       - timestamp: {ISO8601}
       - Updates TODO.md and state.json atomically
  </process>
  
  <validation>
    - Task number is positive integer
    - Task exists in TODO.md
    - Status update succeeded
  </validation>
</stage_1_preflight>
```

**Stage 5: Postflight**
```markdown
<stage_5_postflight>
  <action>Update status to [RESEARCHED], link artifacts, create git commit</action>
  
  <process>
    1. Invoke status-sync-manager:
       - new_status: "researched"
       - timestamp: {ISO8601}
       - validated_artifacts: [{research_report_path}]
       - Updates TODO.md, state.json, project state.json atomically
    
    2. Invoke git-workflow-manager:
       - scope_files: [research_report, TODO.md, state.json, project_state.json]
       - message: "task {number}: research completed"
       - Creates commit with all research artifacts and status updates
  </process>
  
  <validation>
    - Status update succeeded
    - Artifacts linked in TODO.md
    - Git commit created (warning if failed, non-critical)
  </validation>
</stage_5_postflight>
```

### Step 4: Add Argument Parsing

**Location**: researcher.md Stage 1

**Parsing Logic**:
```markdown
<argument_parsing>
  <task_number>
    Extract from delegation context:
    - delegation_context.task_context.task_number
    
    Validation:
    - Must be positive integer
    - Must exist in TODO.md
  </task_number>
  
  <prompt>
    Extract from delegation context (optional):
    - delegation_context.task_context.prompt
    
    Default: Use task description from TODO.md
  </prompt>
  
  <flags>
    Extract from delegation context (optional):
    - delegation_context.task_context.divide
    
    Default: false
  </flags>
</argument_parsing>
```

### Step 5: Implement Status-Sync-Manager Delegation

**Location**: researcher.md Stage 1 and Stage 5

**Stage 1 Delegation**:
```markdown
<status_sync_delegation>
  <prepare>
    delegation_context = {
      "task_number": {number},
      "new_status": "researching",
      "timestamp": "{ISO8601}",
      "session_id": "{session_id}",
      "delegation_depth": 2,
      "delegation_path": ["orchestrator", "research", "researcher", "status-sync-manager"]
    }
  </prepare>
  
  <invoke>
    Invoke status-sync-manager with delegation_context
    Timeout: 60s
  </invoke>
  
  <validate>
    - Verify return.status == "completed"
    - Verify files_updated includes ["TODO.md", "state.json"]
    - If failed: Abort with error
  </validate>
</status_sync_delegation>
```

**Stage 5 Delegation**:
```markdown
<status_sync_delegation>
  <prepare>
    delegation_context = {
      "task_number": {number},
      "new_status": "researched",
      "timestamp": "{ISO8601}",
      "validated_artifacts": [{research_report_path}],
      "session_id": "{session_id}",
      "delegation_depth": 2,
      "delegation_path": ["orchestrator", "research", "researcher", "status-sync-manager"]
    }
  </prepare>
  
  <invoke>
    Invoke status-sync-manager with delegation_context
    Timeout: 60s
  </invoke>
  
  <validate>
    - Verify return.status == "completed"
    - Verify files_updated includes ["TODO.md", "state.json"]
    - Verify artifact linked in TODO.md
    - If failed: Abort with error
  </validate>
</status_sync_delegation>
```

### Step 6: Implement Git-Workflow-Manager Delegation

**Location**: researcher.md Stage 5 (after status-sync-manager)

**Delegation**:
```markdown
<git_workflow_delegation>
  <prepare>
    delegation_context = {
      "scope_files": [
        "{research_report_path}",
        ".opencode/specs/TODO.md",
        ".opencode/specs/state.json",
        ".opencode/specs/{task_number}_{slug}/state.json"
      ],
      "message_template": "task {number}: research completed",
      "task_context": {
        "task_number": {number},
        "description": "research completed"
      },
      "session_id": "{session_id}",
      "delegation_depth": 2,
      "delegation_path": ["orchestrator", "research", "researcher", "git-workflow-manager"]
    }
  </prepare>
  
  <invoke>
    Invoke git-workflow-manager with delegation_context
    Timeout: 120s
  </invoke>
  
  <validate>
    - If return.status == "completed": Log commit hash
    - If return.status == "failed": Log warning (non-critical)
    - Git failure does not fail research command
  </validate>
</git_workflow_delegation>
```

### Step 7: Validation and Testing

**Validation Checklist**:
- [ ] research.md reduced to 150-200 lines
- [ ] research-routing.md deleted
- [ ] research.md.backup deleted
- [ ] researcher.md owns complete workflow (stages 1-6)
- [ ] Status updates to [RESEARCHING] in Stage 1
- [ ] Status updates to [RESEARCHED] in Stage 5
- [ ] state.json updated atomically with TODO.md
- [ ] Research report linked in TODO.md
- [ ] Git commit created with all artifacts
- [ ] Lazy directory creation (no pre-creation)
- [ ] Artifact validation before return

**Testing Protocol**:
```bash
# Test 1: Basic research
/research 254

# Verify:
# - TODO.md shows [RESEARCHING] during execution
# - TODO.md shows [RESEARCHED] after completion
# - state.json status = "researched"
# - Research report exists: .opencode/specs/254_*/reports/research-001.md
# - Research report linked in TODO.md
# - Git commit created: "task 254: research completed"

# Test 2: Research with prompt
/research 254 "Focus on status transitions"

# Verify same as Test 1

# Test 3: Research with --divide flag
/research 254 --divide

# Verify same as Test 1 + topic subdivision

# Test 4: Lean task routing
/research 197  # Assuming task 197 is Lean language

# Verify:
# - Routes to lean-research-agent (not researcher)
# - Same status updates and git commits

# Test 5: Error handling
/research 9999  # Non-existent task

# Verify:
# - Error message: "Task 9999 not found"
# - No status updates
# - No artifacts created
```

**Success Criteria**:
- 5/5 tests pass
- 100% Stage 7 execution (status updates + git commits)
- research.md under 200 lines
- No redundant files
- Atomic status updates
- Proper error handling

## Comparison with Successful Commands

### /plan Command Pattern (Working)

**Frontmatter**:
```yaml
---
name: plan
agent: subagents/planner
description: "Create implementation plans with [PLANNED] status"
---
```

**Status Updates**:
```markdown
**Status Update**: Delegated to `status-sync-manager` for atomic synchronization across TODO.md and state.json.
```

**Git Commits**:
```markdown
Git commits delegated to `git-workflow-manager` for standardized commits
```

**File Size**: 269 lines (concise, focused)

### /implement Command Pattern (Working)

**Frontmatter**:
```yaml
---
name: implement
agent: subagents/implementer
description: "Execute implementation with resume support and [COMPLETED] status"
routing:
  lean: lean-implementation-agent
  default: implementer
---
```

**Status Updates**:
```markdown
**Status Update**: Delegated to `status-sync-manager` for atomic synchronization across TODO.md and state.json.
```

**Git Commits**:
```markdown
Git commits delegated to `git-workflow-manager` for standardized commits
```

**File Size**: 373 lines (includes resume support, still focused)

### /research Command Pattern (Target)

**Frontmatter** (same pattern):
```yaml
---
name: research
agent: subagents/researcher
description: "Conduct research and create reports with [RESEARCHED] status"
routing:
  lean: lean-research-agent
  default: researcher
---
```

**Status Updates** (same pattern):
```markdown
**Status Update**: Delegated to researcher agent → status-sync-manager for atomic synchronization.
```

**Git Commits** (same pattern):
```markdown
Git commits delegated to researcher agent → git-workflow-manager for standardized commits.
```

**File Size** (target): 150-200 lines (simpler than /implement, no resume support)

**Key Insight**: /research should be SIMPLER than /plan and /implement because it has no resume support, no phase tracking, and single artifact output.

## Recommendations Summary

### Immediate Actions (High Priority)

1. **Delete Redundant Files**
   - Delete `.opencode/command/research-routing.md`
   - Delete `.opencode/command/research.md.backup`
   - Keep only `.opencode/command/research.md`

2. **Simplify research.md**
   - Reduce from 272 lines to 150-200 lines
   - Keep frontmatter delegation pattern
   - Remove routing stages XML documentation
   - Add brief workflow description delegating to researcher agent

3. **Update researcher.md Workflow**
   - Add Stage 1: Preflight with status-sync-manager delegation ([RESEARCHING])
   - Add Stage 5: Postflight with status-sync-manager delegation ([RESEARCHED])
   - Add Stage 5: Git-workflow-manager delegation (commit artifacts)
   - Add artifact validation before return

4. **Implement Status Transitions**
   - Stage 1: Invoke status-sync-manager to mark [RESEARCHING]
   - Stage 5: Invoke status-sync-manager to mark [RESEARCHED]
   - Atomic updates across TODO.md and state.json

5. **Implement Git Commits**
   - Stage 5: Invoke git-workflow-manager after status updates
   - Scope files: research report + TODO.md + state.json + project state.json
   - Message: "task {number}: research completed"

### Architecture Recommendations

1. **Follow OpenAgents Pattern**
   - Commands define "what" (frontmatter + description)
   - Agents define "how" (executable workflow stages)
   - Eliminates XML-as-documentation problem

2. **Agent Workflow Ownership**
   - researcher.md owns complete workflow (stages 1-6)
   - No workflow logic in research.md command
   - Clear separation of concerns

3. **Atomic State Management**
   - Use status-sync-manager for all status transitions
   - Two-phase commit ensures consistency
   - Rollback on failure

4. **Standardized Git Workflow**
   - Use git-workflow-manager for all commits
   - Scoped file additions (no `git add -A`)
   - Consistent commit message format

5. **Lazy Directory Creation**
   - Create directories only when writing artifacts
   - No pre-creation during routing
   - Follows artifact-management.md standard

### Quality Standards

1. **File Size Targets**
   - research.md: 150-200 lines (down from 272 lines)
   - researcher.md: Complete workflow ownership
   - No redundant files

2. **Execution Reliability**
   - 100% Stage 7 execution rate
   - Atomic status updates
   - Proper error handling

3. **Context Window Protection**
   - Summary as metadata in return object
   - No separate summary artifact file
   - Single research report artifact

4. **Testing Requirements**
   - 5 test scenarios (basic, prompt, divide, lean routing, error)
   - 100% pass rate
   - Validation of all status transitions

## References

**Standards**:
- `.opencode/context/core/standards/delegation.md` - Delegation patterns and return format
- `.opencode/context/core/system/state-management.md` - Status markers and state.json schema
- `.opencode/context/common/system/git-commits.md` - Git commit patterns
- `.opencode/context/common/system/artifact-management.md` - Lazy directory creation, artifact patterns

**Successful Patterns**:
- `.opencode/command/plan.md` - Frontmatter delegation, status updates, git commits
- `.opencode/command/implement.md` - Frontmatter delegation, status updates, git commits
- `.opencode/specs/240_*/reports/research-001.md` - OpenAgents comparative analysis
- `.opencode/specs/240_*/plans/implementation-002.md` - OpenAgents migration plan with Phase 1 validation

**Current Implementation**:
- `.opencode/command/research.md` - Current routing implementation (272 lines)
- `.opencode/command/research-routing.md` - Redundant file (167 lines)
- `.opencode/command/research.md.backup` - Backup file (678 lines)

## Conclusion

The /research command requires refactoring to adopt the proven OpenAgents frontmatter delegation pattern successfully implemented in /plan and /implement commands. Root cause of systematic failures: workflow defined as XML documentation (narrative) rather than executable code, causing Claude to skip stages 4-8. Solution: Single unified research.md (150-200 lines) with frontmatter delegation to researcher.md agent that owns complete workflow including status updates (status-sync-manager), git commits (git-workflow-manager), and artifact management. Implementation follows Task 240 Phase 1 proven pattern with validation showing 100% Stage 7 execution reliability. Recommended immediate actions: delete redundant files, simplify research.md, update researcher.md workflow, implement status transitions, implement git commits. Expected outcomes: 100% Stage 7 execution, atomic status updates, proper git commits, reduced file size, eliminated redundancy.
