# Research Report: Task #432 - Systematic Agent System Overhaul

**Task**: Fix artifact linking in TODO.md and state.json
**Date**: 2026-01-12
**Focus**: Systematic overhaul for robustness and uniformity while maintaining efficiency

## Executive Summary

This research expands beyond the initial artifact linking fix to address a comprehensive overhaul of the agent system. The analysis reveals six systemic issues that compound each other: (1) fragmented responsibility delegation, (2) inconsistent preflight/postflight execution, (3) documentation-implementation gaps, (4) redundant verification points, (5) unclear artifact lifecycle, and (6) metadata propagation failures. The recommended approach introduces a **Checkpoint-Based Execution Model** with unified verification gates that consolidate checks at strategic points while avoiding unnecessary repetition.

## Findings

### 1. Architecture Analysis: Current State

#### 1.1 Three-Layer Pattern (Documented)
```
User -> Command -> Skill -> Subagent
```

**Reality Check**: The system has evolved organically with inconsistent adherence:
- Commands sometimes do preflight/postflight (research.md, plan.md)
- Commands sometimes delegate to skills (via Skill tool)
- Skills sometimes invoke subagents (via Task tool)
- Subagents sometimes update status directly (violates architecture)

#### 1.2 Responsibility Fragmentation

| Operation | Command File Says | Skill File Says | Agent File Says |
|-----------|------------------|-----------------|-----------------|
| Preflight status update | "Update both files atomically" | N/A | N/A |
| Postflight status update | "Update status to [X]" | N/A | N/A |
| Artifact linking | "Add link if not present" | "Use Edit patterns" | "Return artifacts in JSON" |
| Git commit | "git add && commit" | N/A | N/A |

**Problem**: Three layers describe responsibilities differently, leading to gaps.

#### 1.3 Documented vs Actual Execution

The preflight-postflight.md says:
> "Commands MUST execute preflight in Stage 1.5... Commands MUST execute postflight in Stage 3.5"

But actual command files (research.md, plan.md, implement.md):
- Describe status updates in prose, not executable steps
- Mix jq commands (state.json) with Edit tool (TODO.md) instructions
- Never invoke skill-status-sync as a subagent
- Never verify updates succeeded (no defense-in-depth)

### 2. Identified Systemic Issues

#### Issue 1: Preflight/Postflight Are Instructions, Not Enforcement

**Evidence**: research.md Step 3 says:
```markdown
**state.json** (via jq):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: "researching",
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && \
  mv /tmp/state.json specs/state.json
```
```

**Problem**: This is documentation showing what SHOULD happen, not executable automation. The command file provides a recipe that Claude may or may not follow consistently.

#### Issue 2: Artifact Linking Has Three Implementations

**Implementation A** (command files): "Add link if not already present" (vague)
**Implementation B** (skill-status-sync): Detailed Edit patterns (documented but not invoked)
**Implementation C** (subagents): Return artifacts in JSON (correct, but not linked)

**Result**: Artifacts end up in state.json but not in TODO.md.

#### Issue 3: Verification Is Scattered and Incomplete

| Document | What It Verifies | When |
|----------|-----------------|------|
| subagent-validation.md | Return JSON, artifacts exist | Stage 3 |
| preflight-pattern.md | Status update succeeded | Stage 1.5 |
| postflight-pattern.md | Status + artifacts linked | Stage 3.5 |
| validation.md | Task exists, status valid | Stage 1 |

**Problem**: Verification occurs at 4+ different stages with overlapping checks, yet critical operations still fail.

#### Issue 4: Metadata Propagation Failures

The delegation context includes:
```json
{
  "session_id": "sess_...",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "agent"]
}
```

**Problem**: Session ID is passed to subagents but:
- Not always validated on return
- Not used for tracking in any registry
- Not included in git commit messages for traceability

#### Issue 5: Status-Sync Manager Is Documented But Not Invoked

skill-status-sync (570 lines) documents:
- Atomic two-phase commit
- Artifact linking patterns
- Verification patterns
- Error handling

**Reality**: Command files never invoke this skill. They either:
- Use inline jq commands (bypassing atomic updates)
- Describe Edit tool usage (without calling skill-status-sync)

#### Issue 6: Defense-in-Depth Is Theoretical

preflight-pattern.md prescribes:
```bash
# Verify status was actually updated (defense in depth)
actual_status=$(jq -r ...)
if [ "$actual_status" != "$target_status" ]; then
  # ABORT
fi
```

**Reality**: No command file implements this verification step.

### 3. Root Cause Analysis

The fundamental problem is **documentation without enforcement**:

1. **Architecture documents** describe ideal patterns
2. **Command files** provide prose instructions that may or may not be followed
3. **Skill files** document operations that are never invoked
4. **Agent files** return correct data that is never fully processed
5. **Validation documents** prescribe checks that are not implemented

The gap between documented behavior and actual execution creates:
- Artifact linking failures (Task 429, 386)
- Status desynchronization
- Missing git commits
- Inconsistent metadata propagation

### 4. Similar Systems Analysis

#### Well-Structured Agent Systems Have:

1. **Single Source of Truth for Execution**: One place that defines what happens
2. **Checkpoint-Based Verification**: Verify at strategic points, not everywhere
3. **Separation of Orchestration and Execution**: Clear who does what
4. **Idempotent Operations**: Same operation twice = same result
5. **Audit Trail**: Every operation logged with metadata

#### Current System Lacks:

- Single execution path (multiple documented patterns)
- Checkpoint consolidation (verification scattered)
- Clear responsibility boundaries (commands vs skills vs agents)
- Idempotency guarantees (re-running may duplicate)
- Centralized audit logging

## Recommendations: Systematic Overhaul Plan

### Principle 1: Checkpoint-Based Execution Model

**Replace**: Scattered verification at 4+ stages
**With**: Three unified checkpoints

```
CHECKPOINT 1: GATE IN (Before Delegation)
├── Task exists and status allows operation
├── Generate session_id
├── Update status to [IN_PROGRESS]
├── Verify status update succeeded
└── Decision: PROCEED or ABORT

CHECKPOINT 2: GATE OUT (After Subagent Return)
├── Validate return JSON structure
├── Validate all artifacts exist on disk
├── Update status to [COMPLETED]
├── Link artifacts to TODO.md
├── Verify all updates succeeded
└── Decision: PROCEED or RETRY

CHECKPOINT 3: COMMIT (Finalize)
├── Create git commit with session metadata
├── Verify commit succeeded
├── Log completion to session registry
└── Return result to user
```

**Benefits**:
- All verification consolidated at checkpoints
- No redundant checks between checkpoints
- Clear decision points: proceed, retry, or abort
- Checkpoints are mandatory (not optional documentation)

### Principle 2: Unified Status Manager

**Replace**: Multiple implementations (jq in commands, skill-status-sync, inline Edit)
**With**: Single invocation path through skill-status-sync

All status updates MUST flow through:
```
Command -> skill-status-sync -> {state.json, TODO.md}
```

**Operations**:
- `preflight_update(task_number, in_progress_status)`
- `postflight_update(task_number, completed_status, artifacts[])`
- `artifact_link(task_number, artifact_path, artifact_type)`

**Never Allow**:
- Direct jq commands in command files
- Inline Edit tool for status/artifact updates
- Subagents updating status

### Principle 3: Artifact Lifecycle Management

**Current**: Artifacts returned in JSON, sometimes linked
**Proposed**: Explicit lifecycle with ownership

```
ARTIFACT LIFECYCLE:
1. CREATED: Subagent creates file, returns path in JSON
2. VALIDATED: Command verifies file exists and is non-empty
3. REGISTERED: skill-status-sync adds to state.json
4. LINKED: skill-status-sync adds link to TODO.md
5. COMMITTED: Git commit includes artifact path
```

**Enforcement**:
- CHECKPOINT 2 validates artifacts (step 2)
- CHECKPOINT 2 calls skill-status-sync (steps 3-4)
- CHECKPOINT 3 creates commit (step 5)

### Principle 4: Metadata Propagation Protocol

**Replace**: Optional metadata in delegation context
**With**: Mandatory metadata chain

```
SESSION METADATA (immutable per operation):
{
  "session_id": "sess_{timestamp}_{random}",
  "operation": "research|plan|implement|revise",
  "task_number": N,
  "started_at": ISO8601,
  "delegation_depth": 0,
  "delegation_path": []
}
```

**Propagation Rules**:
1. Command generates session_id at CHECKPOINT 1
2. Session metadata passed to all delegations
3. Subagent returns must include matching session_id
4. Git commit message includes session_id
5. Session registry tracks active sessions

### Principle 5: Command File Standardization

**Replace**: Prose instructions varying by command
**With**: Standardized template all commands follow

```markdown
# /{command} Command

## Arguments
- `$1` - Task number (required)

## Execution

### CHECKPOINT 1: GATE IN
[Standard preflight - identical across commands]

1. Parse task_number from $ARGUMENTS
2. Lookup task via jq (extract language, status, slug)
3. Validate status allows operation
4. Generate session_id
5. Invoke skill-status-sync:
   - operation: "preflight_update"
   - task_number: N
   - new_status: "{in_progress_status}"
6. Verify status update succeeded
7. DECISION: If failed, ABORT with error

### STAGE 2: DELEGATE
[Command-specific delegation]

8. Route by language to appropriate skill
9. Invoke skill with session metadata
10. Wait for return

### CHECKPOINT 2: GATE OUT
[Standard postflight - identical across commands]

11. Validate return JSON structure
12. Validate artifacts exist on disk
13. Invoke skill-status-sync:
    - operation: "postflight_update"
    - task_number: N
    - new_status: "{completed_status}"
    - artifacts: [from return]
14. Verify status and artifact links
15. DECISION: If failed, log warning (work done)

### CHECKPOINT 3: COMMIT
[Standard finalization - identical across commands]

16. Create git commit with session_id
17. Verify commit succeeded
18. Return result to user
```

### Principle 6: Skill Layer Simplification

**Current**: Skills are "thin wrappers" that validate and delegate
**Problem**: Skills add a layer without adding value

**Option A**: Eliminate skill layer entirely
- Commands invoke agents directly via Task tool
- Validation happens at checkpoints (not in skills)
- Reduces delegation depth

**Option B**: Make skills into checkpoint enforcers
- Skills own CHECKPOINT 1 and CHECKPOINT 2
- Commands only do routing and CHECKPOINT 3
- Skills become "workflow managers" not "thin wrappers"

**Recommendation**: Option B - Skills become checkpoint enforcers

```
New Architecture:
Command (routing + CHECKPOINT 3) -> Skill (CHECKPOINT 1 + 2) -> Agent (work)
```

### Principle 7: Agent Contract Simplification

**Current**: Agents return complex JSON with metadata
**Problem**: Metadata often wrong or missing

**Simplified Agent Contract**:
```json
{
  "status": "completed|partial|failed",
  "summary": "Brief description (<100 tokens)",
  "artifacts": [
    {"type": "research|plan|summary", "path": "relative/path"}
  ],
  "errors": [{"message": "...", "recoverable": true}]
}
```

**Removed from agent returns**:
- session_id (skill provides, not agent)
- delegation_depth (tracked by skill)
- delegation_path (tracked by skill)
- duration_seconds (tracked by skill)
- agent_type (known by skill that invoked it)

**Benefits**:
- Agents focus on work, not metadata bookkeeping
- Skills handle metadata consistently
- Fewer opportunities for metadata errors

## Implementation Phases

### Phase 1: Consolidate Checkpoints (2-3 hours)
1. Create checkpoint templates in context/core/checkpoints/
2. Define checkpoint-1-gate-in.md
3. Define checkpoint-2-gate-out.md
4. Define checkpoint-3-commit.md

### Phase 2: Unify Status Manager (2-3 hours)
1. Refactor skill-status-sync to expose clear API
2. Add preflight_update() operation
3. Add postflight_update() operation
4. Add artifact_link() operation
5. Remove inline jq from commands

### Phase 3: Standardize Command Files (3-4 hours)
1. Create command-template.md with all checkpoints
2. Refactor research.md to use checkpoints
3. Refactor plan.md to use checkpoints
4. Refactor implement.md to use checkpoints
5. Refactor revise.md to use checkpoints

### Phase 4: Transform Skills to Checkpoint Enforcers (2-3 hours)
1. Refactor skill-researcher to own CHECKPOINT 1 + 2
2. Refactor skill-planner to own CHECKPOINT 1 + 2
3. Refactor skill-implementer to own CHECKPOINT 1 + 2
4. Update skill-to-agent routing

### Phase 5: Simplify Agent Contracts (1-2 hours)
1. Update agent-template.md with simplified contract
2. Refactor general-research-agent
3. Refactor planner-agent
4. Refactor general-implementation-agent
5. Update validation to match new contract

### Phase 6: Add Session Registry (1-2 hours)
1. Define session registry format in state.json
2. Track active sessions at CHECKPOINT 1
3. Close sessions at CHECKPOINT 3
4. Enable session-based debugging

**Total Estimated Effort**: 11-17 hours

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing workflows | High | Medium | Test each command after refactor |
| Increased delegation depth | Medium | Low | Skills become enforcers, agents simpler |
| State.json format change | High | Low | Migrate gradually, maintain compatibility |
| Checkpoint overhead | Low | Medium | Checkpoints consolidate existing checks |

## Success Criteria

After implementation:

1. **No artifact linking failures**: Every completed operation has artifacts in both state.json AND TODO.md
2. **Consistent status updates**: Every operation follows preflight -> work -> postflight
3. **Session traceability**: Every operation logged with session_id in git commits
4. **Single implementation path**: All status updates flow through skill-status-sync
5. **Checkpoint verification**: All checkpoints executed consistently across commands
6. **Simplified agents**: Agents return work results, skills handle metadata

## References

- `.claude/context/core/orchestration/architecture.md` - Three-layer pattern
- `.claude/context/core/orchestration/preflight-pattern.md` - Preflight (current)
- `.claude/context/core/orchestration/postflight-pattern.md` - Postflight (current)
- `.claude/context/core/orchestration/subagent-validation.md` - Validation (current)
- `.claude/skills/skill-status-sync/SKILL.md` - Status sync (documented)
- `.claude/commands/research.md` - Research command (example)
- `specs/432_fix_artifact_linking_in_todo_and_state/reports/research-001.md` - Initial analysis

## Next Steps

1. Review and approve overhaul approach
2. Create implementation plan with detailed phases
3. Begin Phase 1: Consolidate Checkpoints
4. Test checkpoint patterns on single command (research)
5. Roll out to remaining commands
6. Update all documentation to reflect new architecture
