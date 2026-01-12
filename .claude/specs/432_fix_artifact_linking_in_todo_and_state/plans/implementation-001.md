# Implementation Plan: Task #432

**Task**: Systematic agent system overhaul for robustness
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

This plan implements a systematic overhaul of the .claude/ agent system based on findings from five research reports. The overhaul introduces a Checkpoint-Based Execution Model with three gates (GATE IN, GATE OUT, COMMIT), unifies all status updates through skill-status-sync, implements tiered progressive context loading, and standardizes the plan-file-as-checkpoint pattern across all implementer agents.

**Key Architectural Changes**:
1. Checkpoint-based execution with three gates at command level
2. Unified status updates via skill-status-sync (no inline jq in commands)
3. Tiered progressive context loading (Commands ~200 tokens, Skills ~300 tokens, Agents ~10k+ tokens)
4. Idempotent artifact linking with grep checks
5. Enhanced error tracking with context, trajectory, and recovery fields
6. Session-aware git commits for traceability

**Estimated Total Effort**: 11-17 hours

---

## Phases

### Phase 1: Consolidate Checkpoint Templates

**Estimated effort**: 2-3 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create checkpoint template files that define the three gates
2. Document checkpoint execution requirements for commands
3. Establish verification patterns at each gate

**Files to create**:
- `.claude/context/core/checkpoints/checkpoint-gate-in.md` - Preflight checkpoint template
- `.claude/context/core/checkpoints/checkpoint-gate-out.md` - Postflight checkpoint template
- `.claude/context/core/checkpoints/checkpoint-commit.md` - Finalization checkpoint template
- `.claude/context/core/checkpoints/README.md` - Checkpoint system overview

**Steps**:
1. Create `.claude/context/core/checkpoints/` directory
2. Create checkpoint-gate-in.md with:
   - Task existence validation
   - Status transition validation
   - Session ID generation
   - Status update to in-progress variant
   - Verification of status update
   - ABORT/PROCEED decision criteria
3. Create checkpoint-gate-out.md with:
   - Return JSON structure validation
   - Artifact existence verification on disk
   - Status update to completed variant
   - Artifact linking to TODO.md (with idempotency check)
   - Verification of all updates
   - PROCEED/RETRY decision criteria
4. Create checkpoint-commit.md with:
   - Git commit creation with session metadata
   - Commit verification
   - Session completion logging
   - Result return format
5. Create README.md documenting the checkpoint system

**Verification**:
- All four files exist and have correct structure
- Cross-references between checkpoints are consistent
- Patterns can be executed without modification

---

### Phase 2: Create Routing and Validation Context Files

**Estimated effort**: 1-2 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create minimal routing context file for commands (~200 tokens)
2. Create minimal validation context file for skills (~300 tokens)
3. Establish the progressive context loading pattern

**Files to create**:
- `.claude/context/core/routing.md` - Command-level routing context
- `.claude/context/core/validation.md` - Skill-level validation context

**Steps**:
1. Create routing.md with:
   - Language -> Skill mapping table
   - Valid status transitions table
   - Task lookup pattern (single jq command)
   - Target: Under 200 tokens
2. Create validation.md with:
   - Return schema (required fields only)
   - Input requirements (task_number, focus_prompt)
   - Basic artifact validation rules
   - Target: Under 300 tokens
3. Update index.md to include new context files
4. Document token budgets in each file

**Verification**:
- routing.md is under 200 tokens
- validation.md is under 300 tokens
- Both files are self-contained and require no additional loading

---

### Phase 3: Unify Status Updates via skill-status-sync

**Estimated effort**: 2-3 hours
**Status**: [COMPLETED]

**Objectives**:
1. Refactor skill-status-sync to expose clear API operations
2. Add explicit preflight_update and postflight_update operations
3. Add idempotent artifact_link operation

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md` - Main skill file

**Steps**:
1. Read current skill-status-sync implementation
2. Add new operation section: `preflight_update`
   - Input: task_number, target_status
   - Output: success/failure with current status
   - Includes verification step
3. Add new operation section: `postflight_update`
   - Input: task_number, target_status, artifacts[]
   - Output: success/failure with linked artifacts
   - Includes artifact linking with idempotency
4. Add new operation section: `artifact_link`
   - Input: task_number, artifact_path, artifact_type
   - Output: success/failure
   - Check if link exists before adding (grep pattern)
   - Edit pattern for each artifact type
5. Document the clear API:
   ```
   Operations:
   - preflight_update(task_number, in_progress_status)
   - postflight_update(task_number, completed_status, artifacts[])
   - artifact_link(task_number, artifact_path, artifact_type)
   ```

**Verification**:
- All three operations are documented with executable patterns
- Idempotency check is present in artifact_link
- Examples show invocation patterns

---

### Phase 4: Standardize Command Files with Checkpoints

**Estimated effort**: 3-4 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create command template following checkpoint pattern
2. Refactor each command to use checkpoints
3. Remove inline jq commands (delegate to skill-status-sync)

**Files to modify**:
- `.claude/commands/research.md`
- `.claude/commands/plan.md`
- `.claude/commands/implement.md`
- `.claude/commands/revise.md`

**Files to create**:
- `.claude/context/core/templates/command-template.md` - Standard command template

**Steps**:
1. Create command-template.md with standardized structure:
   ```markdown
   # /{command} Command

   ## Arguments
   - `$1` - Task number (required)

   ## Execution

   ### CHECKPOINT 1: GATE IN
   [Reference checkpoint-gate-in.md]

   ### STAGE 2: DELEGATE
   [Command-specific delegation]

   ### CHECKPOINT 2: GATE OUT
   [Reference checkpoint-gate-out.md]

   ### CHECKPOINT 3: COMMIT
   [Reference checkpoint-commit.md]
   ```
2. Refactor research.md:
   - Replace inline jq with "Invoke skill-status-sync: preflight_update"
   - Replace postflight jq with "Invoke skill-status-sync: postflight_update"
   - Reference checkpoint files instead of inline patterns
3. Refactor plan.md following same pattern
4. Refactor implement.md following same pattern
5. Refactor revise.md following same pattern

**Verification**:
- All four commands follow the same checkpoint structure
- No inline jq commands for status updates
- Each command references checkpoints, not duplicated patterns

---

### Phase 5: Update Skills with Context Pointers

**Estimated effort**: 2-3 hours
**Status**: [COMPLETED]

**Objectives**:
1. Remove @-reference context loading sections from skills
2. Replace with "Context Pointers" pattern
3. Clarify that skills don't load context - agents do

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md`
- `.claude/skills/skill-planner/SKILL.md`
- `.claude/skills/skill-implementer/SKILL.md`
- `.claude/skills/skill-lean-research/SKILL.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/skills/skill-latex-implementation/SKILL.md`
- `.claude/skills/skill-meta/SKILL.md`

**Steps**:
1. For each skill file, replace:
   ```markdown
   ## Context Loading
   Load context on-demand:
   - `@.claude/context/core/formats/subagent-return.md`
   ```
   With:
   ```markdown
   ## Context Pointers
   Reference (do not load):
   - Path: `.claude/context/core/validation.md`
   - Purpose: Return validation at CHECKPOINT 2
   - Load at: Agent execution only

   Note: This skill is a thin wrapper. Context is loaded by the delegated agent.
   ```
2. Verify each skill references validation.md for return validation
3. Remove any eager context loading instructions

**Verification**:
- No skills have @-references that imply eager loading
- Each skill documents its delegation target
- Context loading responsibility is clearly agent-side

---

### Phase 6: Enhance Error Tracking

**Estimated effort**: 1-2 hours
**Status**: [COMPLETED]

**Objectives**:
1. Extend errors.json schema with context, trajectory, and recovery fields
2. Add error pattern aggregation structure
3. Document enhanced error format

**Files to modify**:
- `.claude/rules/error-handling.md` - Error format documentation
- `.claude/specs/errors.json` - If exists, verify structure

**Steps**:
1. Update error-handling.md error format to:
   ```json
   {
     "id": "err_{timestamp}",
     "timestamp": "ISO_DATE",
     "type": "error_type",
     "severity": "critical|high|medium|low",
     "message": "Error description",
     "context": {
       "task_number": 432,
       "operation": "implement",
       "phase": 2,
       "checkpoint": "gate_out"
     },
     "trajectory": ["preflight_ok", "delegate_ok", "validate_failed"],
     "recovery": {
       "attempted": "retry_validation",
       "result": "failed"
     },
     "fix_status": "unfixed"
   }
   ```
2. Add patterns section documentation:
   ```json
   {
     "patterns": {
       "artifact_linking_failure": {
         "count": 3,
         "last_occurrence": "2026-01-12",
         "tasks_affected": [386, 429, 432],
         "common_context": "postflight phase"
       }
     }
   }
   ```
3. Document how /errors command should use patterns for prioritization

**Verification**:
- Error format in documentation includes all new fields
- Pattern aggregation structure is documented
- Examples show populated error entries

---

### Phase 7: Add Session-Aware Git Commits

**Estimated effort**: 0.5-1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Update git commit template to include session_id
2. Document session ID format and generation

**Files to modify**:
- `.claude/rules/git-workflow.md` - Git commit conventions
- `.claude/context/core/checkpoints/checkpoint-commit.md` (created in Phase 1)

**Steps**:
1. Update git-workflow.md commit format to:
   ```
   {scope}: {action} {description}

   Session: sess_{timestamp}_{random}

   Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
   ```
2. Document session ID generation:
   - Format: `sess_{unix_timestamp}_{6_char_random}`
   - Generated at CHECKPOINT 1 (GATE IN)
   - Passed through entire operation
   - Included in final git commit

**Verification**:
- Git commit template includes session line
- Session ID format is documented
- Example commits show session correlation

---

### Phase 8: Standardize Plan-File-as-Checkpoint Pattern

**Estimated effort**: 1-2 hours
**Status**: [COMPLETED]

**Objectives**:
1. Document the plan-file-as-checkpoint pattern for implementer agents
2. Ensure all implementer agents follow same phase update pattern
3. Verify git commits occur after each phase completion

**Files to modify**:
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/agents/latex-implementation-agent.md`

**Steps**:
1. Add standardized section to each implementer agent:
   ```markdown
   ## Phase Checkpoint Protocol

   For each phase in the plan:
   1. Read plan file, identify current phase
   2. Update phase status to [IN PROGRESS]
   3. Execute phase steps
   4. Update phase status to [COMPLETED] or [BLOCKED] or [PARTIAL]
   5. Git commit with message: "task {N} phase {P}: {phase_name}"
   6. Proceed to next phase or return if blocked

   This ensures:
   - Resume point is always discoverable from plan file
   - Git history reflects phase-level progress
   - Failed phases can be retried from beginning
   ```
2. Verify each agent documents this protocol
3. Add verification step for plan file update before proceeding

**Verification**:
- All three implementer agents have Phase Checkpoint Protocol section
- Protocol is identical across all agents
- Git commit patterns match expected format

---

### Phase 9: Fix index.md and Consolidate Context

**Estimated effort**: 1-2 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Fix broken paths in index.md
2. Add new context files to index
3. Document token budgets

**Files to modify**:
- `.claude/context/index.md` - Context discovery index

**Steps**:
1. Read current index.md
2. Fix broken paths:
   - `core/system/` -> `core/orchestration/`
   - Remove references to non-existent files
   - Add references to new checkpoint files
3. Add new files:
   - `core/checkpoints/checkpoint-gate-in.md`
   - `core/checkpoints/checkpoint-gate-out.md`
   - `core/checkpoints/checkpoint-commit.md`
   - `core/routing.md`
   - `core/validation.md`
4. Add token budget annotations:
   ```markdown
   - `routing.md` (~200 tokens) - Command-level routing
   - `validation.md` (~300 tokens) - Skill-level validation
   ```

**Verification**:
- All paths in index.md point to existing files
- New context files are included
- Token budgets are documented

---

### Phase 10: Update CLAUDE.md with Simplified Overview

**Estimated effort**: 0.5-1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Update CLAUDE.md to reference checkpoint model
2. Simplify context references to pointers only
3. Document the new architecture briefly

**Files to modify**:
- `.claude/CLAUDE.md` - Main project instructions

**Steps**:
1. Add section on Checkpoint-Based Execution:
   ```markdown
   ## Checkpoint-Based Execution

   All commands follow a three-checkpoint model:
   1. GATE IN (preflight) - Validate and update status
   2. DELEGATE - Route to skill/agent
   3. GATE OUT (postflight) - Validate return and link artifacts
   4. COMMIT - Git commit with session ID

   See: `.claude/context/core/checkpoints/README.md`
   ```
2. Simplify context loading section to reference progressive loading
3. Ensure CLAUDE.md stays under 3000 tokens (per research findings)

**Verification**:
- CLAUDE.md references checkpoint model
- No redundant detailed patterns (defer to context files)
- File size is reasonable

---

## Dependencies

| Phase | Depends On | Reason |
|-------|-----------|--------|
| Phase 2 | Phase 1 | Routing/validation contexts reference checkpoints |
| Phase 3 | Phase 1 | Status sync uses checkpoint patterns |
| Phase 4 | Phase 1, 3 | Commands reference checkpoints and status sync |
| Phase 5 | Phase 2 | Skills reference validation context |
| Phase 6 | None | Independent enhancement |
| Phase 7 | Phase 1 | Git workflow references checkpoint-commit |
| Phase 8 | Phase 1, 4 | Agents use plan-file-as-checkpoint from commands |
| Phase 9 | Phase 1, 2 | Index includes new files |
| Phase 10 | Phase 1-9 | CLAUDE.md summarizes all changes |

**Recommended Execution Order**:
1. Phase 1 (checkpoints - foundation)
2. Phase 2 (routing/validation contexts)
3. Phase 3 (status sync API)
4. Phase 4 (command standardization)
5. Phase 5, 6, 7 (can be parallel)
6. Phase 8 (agent standardization)
7. Phase 9 (index cleanup)
8. Phase 10 (documentation update)

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing workflows | High | Test each command after refactor with simple task |
| State.json format change | High | No format changes; only documentation changes |
| Token budget exceeded | Medium | Monitor file sizes during creation |
| Incomplete migration | Medium | Each phase is independently verifiable |
| Inconsistent checkpoint implementation | Medium | Use templates; verify structure in each phase |

---

## Success Criteria

After implementation, the following must be true:

- [ ] Three checkpoint template files exist in `.claude/context/core/checkpoints/`
- [ ] routing.md exists and is under 200 tokens
- [ ] validation.md exists and is under 300 tokens
- [ ] skill-status-sync has preflight_update, postflight_update, artifact_link operations
- [ ] All commands (research, plan, implement, revise) follow checkpoint structure
- [ ] All commands have no inline jq for status updates
- [ ] All skills use "Context Pointers" pattern instead of @-references
- [ ] error-handling.md documents extended error format with context, trajectory, recovery
- [ ] git-workflow.md documents session_id in commit messages
- [ ] All implementer agents document Phase Checkpoint Protocol
- [ ] index.md has correct paths and includes new files
- [ ] CLAUDE.md references checkpoint model

**Key Metrics for Robustness**:
- No artifact linking failures in new operations
- Every operation follows preflight -> work -> postflight
- Session IDs in git commits enable traceability
- All status updates flow through skill-status-sync
