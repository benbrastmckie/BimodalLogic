# Research Report: Task #675

**Task**: 675 - Enforce skill-based checkpoint pattern
**Started**: 2026-01-25T20:00:00Z
**Completed**: 2026-01-25T21:30:00Z
**Effort**: 2 hours
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Command scripts (.claude/commands/{research,plan,implement}.{sh,md})
- Skill definitions (.claude/skills/)
- Context documentation (.claude/context/core/)
- Checkpoint pattern documentation (.claude/context/core/patterns/checkpoint-execution.md)
- State management rules (.claude/rules/state-management.md)

**Artifacts**:
- This research report at specs/675_enforce_skill_postflight_checkpoint_pattern/reports/research-001.md

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root Cause Identified**: Commands currently contain BOTH bash shell scripts (.sh) AND markdown documentation (.md) with identical names, creating confusion about which executes
- **Critical Gap**: Shell scripts (.sh files) implement checkpoints 1-3 inline with SIMULATED delegation (placeholder code), while markdown files (.md) document the INTENDED skill-based delegation pattern but don't execute
- **Bypass Mechanism**: Commands can directly create stub artifacts and metadata without invoking skills, completely bypassing the checkpoint pattern enforcement
- **Missing Validation Layer**: No enforcement mechanism prevents commands from skipping skill delegation or ensures postflight operations execute
- **Skill Pattern Status**: Skills themselves correctly implement internal postflight (marker files, metadata exchange), but commands don't actually invoke them

## Context & Scope

Task 675 investigates why the documented checkpoint pattern (GATE IN → DELEGATE → GATE OUT → COMMIT) can be bypassed, causing missing status updates, artifact linking failures, and skipped git commits.

The checkpoint pattern is documented in:
- `.claude/context/core/patterns/checkpoint-execution.md` - The 3-checkpoint model
- `.claude/commands/*.md` - Command documentation showing skill delegation
- `.claude/skills/*/SKILL.md` - Skill-internal postflight pattern
- `.claude/CLAUDE.md` - System overview

Research scope covers:
1. Current command implementation architecture
2. Skill delegation mechanisms
3. Status management requirements
4. Return metadata validation
5. Checkpoint pattern enforcement gaps

## Findings

### 1. Command Implementation Architecture

**Critical Discovery**: Dual file system creates execution ambiguity

Commands exist in TWO forms:
```
.claude/commands/
├── research.sh        # Executable bash script
├── research.md        # Documentation markdown
├── plan.sh           # Executable bash script
├── plan.md           # Documentation markdown
├── implement.sh      # Executable bash script
└── implement.md      # Documentation markdown
```

**Analysis**:
- **Shell scripts (.sh)**: Contain full checkpoint implementation with SIMULATED delegation
- **Markdown files (.md)**: Document INTENDED skill-based delegation pattern
- **Execution**: Only .sh files execute (shebang `#!/usr/bin/env bash`)
- **Problem**: Shell scripts contain placeholder code that bypasses real skill invocation

**Evidence from research.sh (lines 125-159)**:
```bash
# For now, we'll simulate the delegation with a placeholder
# In a real implementation, this would invoke the Task tool
echo "Note: Full delegation implementation requires Task tool integration"
echo "Proceeding with simulation..."

# Create a sample research report
report_file="$task_dir/reports/research-$session_id.md"
cat > "$report_file" <<EOF
# Research Report for Task #$task_number
...
EOF

# Create metadata file
metadata_file="$task_dir/.meta/research-return-meta.json"
cat > "$metadata_file" <<EOF
{
  "status": "completed",
  "summary": "Research completed for task #$task_number: $task_description",
  "artifacts": ["$report_file"],
  "session_id": "$session_id",
  "timestamp": "$timestamp_iso"
}
EOF
```

This creates stub artifacts WITHOUT invoking any skill, completely bypassing:
- Skill-internal preflight status updates
- Subagent delegation via Task tool
- Skill-internal postflight operations
- Metadata file validation
- Artifact quality verification

### 2. Skill Delegation Pattern Status

**Skills correctly implement internal postflight**, but commands never invoke them.

**Skill Pattern (from skill-researcher/SKILL.md)**:
```
Stage 1: Input Validation
Stage 2: Preflight Status Update (skill handles)
Stage 3: Create Postflight Marker
Stage 4: Prepare Delegation Context
Stage 5: Invoke Subagent (Task tool with subagent_type)
Stage 6: Parse Metadata File
Stage 7: Update Task Status (Postflight)
Stage 8: Link Artifacts
Stage 9: Git Commit
Stage 10: Cleanup
Stage 11: Return Brief Summary
```

**Current Command Behavior**:
- Commands DO: Preflight status update (GATE IN)
- Commands DO: Create stub artifacts (SIMULATE)
- Commands DO: Postflight status update (GATE OUT)
- Commands DO: Git commit (CHECKPOINT 3)
- Commands DON'T: Invoke skills
- Commands DON'T: Use Task tool delegation
- Commands DON'T: Validate metadata from agents
- Commands DON'T: Create postflight markers

**Gap**: Commands implement checkpoints 1, 2, 3 inline but skip STAGE 2 skill delegation entirely.

### 3. Documented vs Actual Delegation

**Documented Pattern** (from research.md lines 133-156):
```markdown
### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Language-Based Routing**:
| Language | Skill to Invoke |
|----------|-----------------|
| `lean` | `skill-lean-research` |
| `general`, `meta`, `markdown`, `latex` | `skill-researcher` |

**Invoke the Skill tool NOW** with:
task: "Research Task ${task_number}"
prompt: "Research task number ${task_number}..."
subagent_type: "{skill-name from table above}"
```

**Actual Pattern** (from research.sh lines 372-388):
```bash
# Language-based routing
case "$task_language" in
  "lean")
    subagent="lean-research-agent"
    ;;
  *)
    subagent="general-research-agent"
    ;;
esac

echo "Delegating to $subagent for $task_language research..."
echo "Session ID: $session_id"
echo "Focus: $focus_prompt"

# For now, we'll simulate the delegation with a placeholder
# In a real implementation, this would invoke the Task tool
echo "Note: Full delegation implementation requires Task tool integration"
echo "Proceeding with simulation..."
```

**Gap**: Routing logic exists but delegation is simulated, not executed.

### 4. State Management Violations

Commands perform state updates directly, duplicating skill responsibilities:

**Preflight** (research.sh lines 90-103):
```bash
# Update state.json
jq --arg num "$task_number" \
   --arg status "researching" \
   --arg ts "$timestamp_iso" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
     status: $status,
     last_updated: $ts,
     researching: $ts
   }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Update TODO.md
sed -i "s/### ${task_number}\./&\n- **Status**: [RESEARCHING]/" specs/TODO.md
```

**Postflight** (research.sh lines 208-219):
```bash
jq --arg num "$task_number" \
   --arg status "researched" \
   --arg ts "$timestamp_iso" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
     status: $status,
     last_updated: $ts,
     researched: $ts
   }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

sed -i "s/\[RESEARCHING\]/[RESEARCHED]/" specs/TODO.md
```

**Problem**: This duplicates the exact logic skills are supposed to handle (see skill-researcher/SKILL.md stages 2, 7), violating separation of concerns.

### 5. Checkpoint Pattern Enforcement Gaps

**Current Reality**:
```
Command Checkpoint Flow (as-implemented):
┌─────────────────────────────────────────────────────┐
│  CHECKPOINT 1 → SIMULATE → CHECKPOINT 2 → CHECKPOINT 3 │
│   GATE IN       (stub)      GATE OUT       COMMIT   │
│  (in command)  (in command) (in command)  (in cmd)  │
│                                                      │
│  Skills: NEVER INVOKED                               │
└─────────────────────────────────────────────────────┘
```

**Intended Pattern**:
```
Command Checkpoint Flow (as-documented):
┌─────────────────────────────────────────────────────┐
│  CHECKPOINT 1 → DELEGATE → CHECKPOINT 2 → CHECKPOINT 3 │
│   GATE IN       (skill)     GATE OUT       COMMIT   │
│  (in command)  (in skill)  (in command)  (in cmd)  │
│                                                      │
│  Skill handles: preflight, agent delegation,        │
│                 postflight, artifact validation     │
└─────────────────────────────────────────────────────┘
```

**Enforcement Gaps**:
1. **No validation** that skills were invoked
2. **No verification** of metadata file schema
3. **No check** that artifacts are non-empty
4. **No enforcement** of postflight marker creation
5. **No guard** against direct state manipulation

### 6. Skill-to-Command Integration Contract

Skills expect to be invoked via Skill tool with specific arguments:

**skill-researcher expectations** (lines 137-139):
```markdown
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "general-research-agent"
  - prompt: [Include task_context, delegation_context, focus_prompt, metadata_file_path]
```

**skill-planner expectations** (lines 143-145):
```markdown
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "planner-agent"
  - prompt: [Include task_context, delegation_context, research_path, metadata_file_path]
```

**skill-implementer expectations** (lines 153-155):
```markdown
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "general-implementation-agent"
  - prompt: [Include task_context, delegation_context, plan_path, metadata_file_path]
```

**Problem**: Commands never call these skills, so the Task tool delegation chain never activates.

### 7. Metadata File Exchange Protocol

Skills use file-based metadata exchange (return-metadata-file.md):

**Expected Flow**:
1. Command invokes skill
2. Skill creates `.postflight-pending` marker
3. Skill invokes agent via Task tool
4. Agent writes `specs/{N}_{SLUG}/.return-meta.json`
5. Agent returns brief text summary
6. Skill reads `.return-meta.json`
7. Skill executes postflight (status, artifacts, commit)
8. Skill removes marker and metadata file
9. Skill returns brief summary to command

**Current Flow** (bypassed):
1. Command simulates delegation
2. Command creates fake `.return-meta.json` directly
3. Command reads its own fake metadata
4. Command executes postflight itself
5. No marker file created (hook never engaged)

**Gap**: Metadata exchange protocol never activates because skills aren't invoked.

### 8. Postflight Marker File Pattern

Skills should create marker files to prevent premature termination:

**From postflight-control.md**:
```json
{
  "session_id": "sess_1736700000_abc123",
  "skill": "skill-researcher",
  "task_number": 259,
  "operation": "research",
  "reason": "Postflight pending: status update, artifact linking, git commit",
  "created": "2026-01-18T10:00:00Z",
  "stop_hook_active": false
}
```

**Purpose**: SubagentStop hook detects marker and blocks premature stop, allowing skill to complete postflight.

**Current Reality**: Commands never create markers because they don't invoke skills. The hook infrastructure exists but is never activated.

### 9. Command Markdown Documentation Accuracy

The markdown files (.claude/commands/*.md) document the CORRECT pattern but don't execute:

**research.md correctly shows** (lines 143-154):
```markdown
**Invoke the Skill tool NOW** with:
task: "Research Task ${task_number}"
prompt: "Research task number ${task_number} with description: '${task_description}'
Language: ${task_language}
Focus prompt: ${focus_prompt}
Session ID: ${session_id}
Task directory: ${task_dir}

Please conduct comprehensive research and create a report in ${task_dir}/reports/
The report should analyze the requirements and provide specific recommendations.
Return metadata to ${task_dir}/.meta/research-return-meta.json"
subagent_type: "{skill-name from table above}"
```

**But research.sh actually runs** placeholder simulation code.

**Gap**: Documentation-code mismatch. Markdown files serve as specifications but shell scripts don't implement them.

### 10. Comparison with Working Skill Patterns

**Skills that DO execute properly** (when invoked):

From skill-researcher/SKILL.md analysis:
- ✅ Creates postflight marker (Stage 3)
- ✅ Invokes agent via Task tool (Stage 5)
- ✅ Reads metadata file (Stage 6)
- ✅ Executes postflight atomically (Stage 7-9)
- ✅ Cleans up markers (Stage 10)
- ✅ Returns brief summary (Stage 11)

From skill-planner/SKILL.md analysis:
- ✅ Identical pattern to researcher
- ✅ All postflight stages present
- ✅ Metadata validation included

From skill-implementer/SKILL.md analysis:
- ✅ Enhanced with completion_data extraction (Stage 7)
- ✅ Plan file status updates
- ✅ Phase-based commits

**Conclusion**: Skills are correctly implemented. Commands just don't use them.

## Architectural Assessment

### System Design Analysis

The checkpoint pattern architecture has THREE layers:

**Layer 1: Commands** (.claude/commands/)
- **Role**: User-facing entry points
- **Responsibilities**: GATE IN validation, skill invocation, GATE OUT verification, COMMIT
- **Current Issue**: Implement all checkpoints inline, never delegate to Layer 2

**Layer 2: Skills** (.claude/skills/)
- **Role**: Orchestration wrappers
- **Responsibilities**: Preflight, subagent delegation, postflight, metadata validation
- **Current Status**: Correctly implemented but NEVER INVOKED

**Layer 3: Agents** (.claude/agents/)
- **Role**: Work execution
- **Responsibilities**: Research/plan/implement, artifact creation, metadata writing
- **Current Status**: Correctly implemented but NEVER INVOKED (skills don't run)

**Root Cause**: Layer 1 bypasses Layer 2, preventing Layer 3 from executing.

### Intended vs Actual Execution Flow

**Intended**:
```
User → Command (GATE IN)
           ↓
       Skill (preflight, delegate, postflight)
           ↓
       Agent (work + metadata)
           ↓
       Skill (artifact validation)
           ↓
       Command (GATE OUT, COMMIT)
```

**Actual**:
```
User → Command (GATE IN)
           ↓
       Command (simulate work)
           ↓
       Command (fake metadata)
           ↓
       Command (GATE OUT, COMMIT)
           ↓
       Skills/Agents: NOT EXECUTED
```

### Violation of Separation of Concerns

**Command responsibilities** (should be):
- Argument parsing
- Session ID generation
- GATE IN validation (task exists, status allows operation)
- Skill invocation
- GATE OUT verification (metadata valid, artifacts exist)
- COMMIT (git commit)

**Skill responsibilities** (documented):
- Preflight status update
- Postflight marker creation
- Subagent delegation
- Metadata file reading
- Postflight status update
- Artifact linking
- Git commit coordination
- Marker cleanup

**Current violation**:
Commands perform BOTH sets of responsibilities, making skills redundant.

## Root Cause Analysis

### Primary Root Cause

**Incomplete migration from direct implementation to skill-based delegation**

Evidence:
1. Shell scripts contain complete inline implementation (legacy pattern)
2. Markdown files document skill-based pattern (new pattern)
3. Skills exist and are correctly implemented (new pattern)
4. No migration path or validation enforces new pattern
5. Placeholder comments acknowledge incomplete state

### Contributing Factors

1. **Dual file system confusion**
   - .sh and .md files with same base name
   - Unclear which is authoritative
   - No CI/CD check for consistency

2. **No runtime validation**
   - Commands can bypass skills silently
   - No metadata schema enforcement
   - No artifact quality checks
   - No postflight marker verification

3. **Simulation code in production**
   - Placeholder delegation code executes in real operations
   - Creates valid-looking but fake metadata
   - Users can't tell simulation from real execution

4. **Missing skill invocation enforcement**
   - No mechanism requires commands to delegate
   - No guard against direct state manipulation
   - No verification skills were actually invoked

5. **Documentation-code drift**
   - Markdown shows ideal pattern
   - Shell scripts show legacy pattern
   - No automated sync or validation

## Specific Recommendations

### Recommendation 1: Enforce Skill Delegation Contract

**Add validation layer that requires skill invocation**

Create a delegation validator that:
- Checks postflight marker was created
- Verifies metadata file schema
- Ensures artifacts are non-empty
- Validates session_id continuity
- Confirms skill return format

**Implementation approach**:
```bash
# In command after STAGE 2 (delegate)
validate_skill_delegation() {
  local marker_file="specs/.postflight-pending"
  local metadata_file="$task_dir/.return-meta.json"

  # Check marker was created (proves skill ran)
  if [ ! -f "$marker_file" ]; then
    echo "ERROR: Skill delegation failed - no postflight marker found"
    echo "This indicates the skill was not invoked correctly"
    exit 1
  fi

  # Verify metadata schema
  if ! jq -e '.status and .artifacts and .metadata.session_id' "$metadata_file" >/dev/null; then
    echo "ERROR: Invalid metadata schema"
    exit 1
  fi

  # Verify artifacts exist and are non-empty
  local artifact_path=$(jq -r '.artifacts[0].path' "$metadata_file")
  if [ ! -s "$artifact_path" ]; then
    echo "ERROR: Artifact missing or empty: $artifact_path"
    exit 1
  fi
}
```

### Recommendation 2: Remove Simulation Code

**Replace placeholder delegation with real Skill tool invocation**

**Current** (research.sh lines 385-388):
```bash
# For now, we'll simulate the delegation with a placeholder
# In a real implementation, this would invoke the Task tool
echo "Note: Full delegation implementation requires Task tool integration"
echo "Proceeding with simulation..."
```

**Replace with**:
```bash
# Invoke skill-researcher (for non-lean) or skill-lean-research (for lean)
case "$task_language" in
  "lean")
    skill_name="skill-lean-research"
    ;;
  *)
    skill_name="skill-researcher"
    ;;
esac

# Invoke via Skill tool (NOTE: This is Claude Code agent invocation, not bash)
# The skill will handle all postflight operations internally
invoke_skill "$skill_name" \
  --arg task_number "$task_number" \
  --arg session_id "$session_id" \
  --arg focus_prompt "$focus_prompt"
```

**Note**: This requires commands to transition from bash scripts to Claude Code skill invocations.

### Recommendation 3: Migrate Commands to Skill-Only Pattern

**Replace .sh shell scripts with skill-invoking markdown commands**

**Current architecture**:
- Commands are bash scripts
- Commands contain full checkpoint logic
- Skills are bypassed

**Proposed architecture**:
- Commands are markdown files (Claude interprets)
- Commands ONLY contain GATE IN, skill invocation, GATE OUT, COMMIT
- Skills handle ALL work delegation and postflight

**Example** (research.md becomes the ONLY file):
```markdown
---
description: Research a task and create reports
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101
---

# /research Command

## CHECKPOINT 1: GATE IN

Parse args, generate session_id, validate task exists and status allows research.

## STAGE 2: DELEGATE

Invoke skill-researcher (or skill-lean-research for lean tasks).

## CHECKPOINT 2: GATE OUT

Verify skill completed, metadata valid, artifacts exist.

## CHECKPOINT 3: COMMIT

Git commit with session ID.
```

**Benefits**:
- Single source of truth (one file per command)
- Impossible to bypass skills (no inline implementation)
- Claude Code interprets markdown directly
- Skill tool invocation is native

**Migration path**:
1. Update .md commands to include allowed-tools and model frontmatter
2. Remove all bash logic except jq/git commands
3. Add skill validation in GATE OUT
4. Delete .sh files
5. Update documentation

### Recommendation 4: Add Postflight Verification

**Verify postflight operations actually executed**

In CHECKPOINT 2 (GATE OUT), add verification:

```bash
# After skill returns, verify postflight completed
verify_postflight() {
  local task_num="$1"
  local expected_status="$2"  # "researched", "planned", "implemented"

  # Check state.json was updated
  current_status=$(jq -r --argjson num "$task_num" \
    '.active_projects[] | select(.project_number == $num) | .status' \
    specs/state.json)

  if [ "$current_status" != "$expected_status" ]; then
    echo "ERROR: Postflight failed - status not updated to $expected_status"
    echo "Current status: $current_status"
    exit 1
  fi

  # Check artifacts were linked
  artifact_count=$(jq -r --argjson num "$task_num" \
    '[.active_projects[] | select(.project_number == $num) | .artifacts[]] | length' \
    specs/state.json)

  if [ "$artifact_count" -eq 0 ]; then
    echo "WARNING: No artifacts linked to task"
  fi

  # Check marker was cleaned up
  if [ -f "specs/.postflight-pending" ]; then
    echo "ERROR: Postflight marker not cleaned up"
    echo "Skill may have failed during postflight"
    exit 1
  fi
}
```

### Recommendation 5: Implement Checkpoint Guard Rails

**Add validation checkpoints that prevent bypass**

Create a checkpoint state machine:

```bash
# Track checkpoint progression
checkpoint_state_file="specs/.checkpoint-state-${session_id}.json"

checkpoint_gate_in() {
  echo '{"checkpoint": "GATE_IN", "session_id": "'$session_id'", "completed": true}' \
    > "$checkpoint_state_file"
}

checkpoint_delegate() {
  # Verify GATE_IN completed
  if ! jq -e '.checkpoint == "GATE_IN" and .completed == true' "$checkpoint_state_file" >/dev/null; then
    echo "ERROR: Cannot DELEGATE - GATE_IN not completed"
    exit 1
  fi

  jq '.checkpoint = "DELEGATE" | .skill_invoked = true' "$checkpoint_state_file" \
    > /tmp/checkpoint.json && mv /tmp/checkpoint.json "$checkpoint_state_file"
}

checkpoint_gate_out() {
  # Verify DELEGATE completed
  if ! jq -e '.checkpoint == "DELEGATE" and .skill_invoked == true' "$checkpoint_state_file" >/dev/null; then
    echo "ERROR: Cannot GATE_OUT - DELEGATE not completed"
    exit 1
  fi

  jq '.checkpoint = "GATE_OUT" | .postflight_verified = true' "$checkpoint_state_file" \
    > /tmp/checkpoint.json && mv /tmp/checkpoint.json "$checkpoint_state_file"
}

checkpoint_commit() {
  # Verify GATE_OUT completed
  if ! jq -e '.checkpoint == "GATE_OUT" and .postflight_verified == true' "$checkpoint_state_file" >/dev/null; then
    echo "ERROR: Cannot COMMIT - GATE_OUT not completed"
    exit 1
  fi

  # Cleanup
  rm -f "$checkpoint_state_file"
}
```

### Recommendation 6: Unify Documentation and Implementation

**Eliminate .sh/.md split**

Options:

**Option A**: Markdown-only commands
- Delete all .sh files
- Make .md files executable via Claude Code
- Benefits: Single source of truth, skill invocation natural
- Drawbacks: Requires Claude Code to interpret commands

**Option B**: Shell scripts that invoke Claude
- Keep .sh files but remove inline logic
- Have bash invoke `claude --skill skill-name --args "..."`
- Benefits: Can still use bash for argument parsing
- Drawbacks: Adds subprocess overhead

**Option C**: Template-based generation
- Generate .sh from .md using templates
- CI/CD verifies they match
- Benefits: Best of both worlds
- Drawbacks: Added complexity

**Recommendation**: Start with Option A (markdown-only), it aligns with Claude Code's skill model.

### Recommendation 7: Add CI/CD Validation

**Prevent simulation code from merging**

Add pre-commit hooks:

```bash
#!/bin/bash
# .claude/hooks/pre-commit-validate-delegation.sh

# Check for simulation placeholders
if grep -r "simulate the delegation\|For now, we'll simulate\|Proceeding with simulation" .claude/commands/*.sh 2>/dev/null; then
  echo "ERROR: Simulation code found in commands"
  echo "Commands must delegate to skills, not simulate work"
  exit 1
fi

# Check for direct state manipulation in commands
if grep -r "jq.*active_projects.*status" .claude/commands/*.sh 2>/dev/null; then
  echo "ERROR: Direct state manipulation found in commands"
  echo "State updates must happen in skills, not commands"
  exit 1
fi

# Verify skill invocation present
if ! grep -r "Skill.*skill-researcher\|Skill.*skill-planner\|Skill.*skill-implementer" .claude/commands/*.md 2>/dev/null; then
  echo "WARNING: No skill invocations found in command documentation"
fi
```

### Recommendation 8: Create Delegation Validator Utility

**Shared validation logic across all commands**

Create `.claude/lib/validate-delegation.sh`:

```bash
#!/bin/bash
# Delegation validation library

validate_skill_return() {
  local metadata_file="$1"
  local expected_status="$2"

  # Schema validation
  required_fields=("status" "artifacts" "metadata.session_id" "metadata.agent_type")
  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$metadata_file" >/dev/null 2>&1; then
      echo "ERROR: Missing required field: $field"
      return 1
    fi
  done

  # Status validation
  actual_status=$(jq -r '.status' "$metadata_file")
  if [ "$actual_status" != "$expected_status" ] && [ "$actual_status" != "partial" ] && [ "$actual_status" != "failed" ]; then
    echo "ERROR: Unexpected status: $actual_status (expected: $expected_status)"
    return 1
  fi

  # Artifact validation
  jq -r '.artifacts[].path' "$metadata_file" | while read artifact_path; do
    if [ ! -f "$artifact_path" ]; then
      echo "ERROR: Artifact not found: $artifact_path"
      return 1
    fi
    if [ ! -s "$artifact_path" ]; then
      echo "ERROR: Artifact is empty: $artifact_path"
      return 1
    fi
  done

  return 0
}

validate_postflight_complete() {
  local task_number="$1"
  local expected_status="$2"

  # Check marker cleaned up
  if [ -f "specs/.postflight-pending" ]; then
    echo "ERROR: Postflight marker still exists"
    return 1
  fi

  # Check status updated
  actual_status=$(jq -r --argjson num "$task_number" \
    '.active_projects[] | select(.project_number == $num) | .status' \
    specs/state.json)

  if [ "$actual_status" != "$expected_status" ]; then
    echo "ERROR: Status not updated (expected: $expected_status, actual: $actual_status)"
    return 1
  fi

  return 0
}
```

Then source in commands:
```bash
source .claude/lib/validate-delegation.sh
validate_skill_return "$metadata_file" "researched"
validate_postflight_complete "$task_number" "researched"
```

## Implementation Approach Suggestions

### Phase 1: Add Validation (Non-Breaking)

**Goal**: Detect when delegation is bypassed without breaking current functionality

1. Add validation functions to commands (don't fail on error, just log warnings)
2. Create checkpoint state tracking (optional, logged only)
3. Add CI/CD checks for simulation code (warning level)
4. Document validation gaps in errors.json

**Deliverables**:
- `.claude/lib/validate-delegation.sh` library
- Updated commands with validation calls (non-failing)
- CI/CD warning checks
- Error logging for bypassed checkpoints

**Timeline**: 1-2 hours

### Phase 2: Implement Real Skill Delegation (Breaking)

**Goal**: Replace simulation code with actual skill invocation

1. Update research.sh to invoke skill-researcher
2. Update plan.sh to invoke skill-planner
3. Update implement.sh to invoke skill-implementer
4. Remove all simulation code
5. Make validation failures fatal

**Deliverables**:
- Commands delegate to skills (no simulation)
- Skills execute and perform postflight
- Validation enforces checkpoint pattern
- All placeholder code removed

**Timeline**: 3-4 hours

### Phase 3: Migrate to Markdown-Only Commands (Major Refactor)

**Goal**: Eliminate .sh files, use Claude Code's skill invocation

1. Add frontmatter to .md commands (allowed-tools, model)
2. Convert bash logic to Skill tool invocations
3. Test commands execute via Claude Code
4. Delete .sh files
5. Update documentation

**Deliverables**:
- Single .md file per command
- No shell scripts
- Pure skill delegation
- Simplified architecture

**Timeline**: 4-6 hours

### Phase 4: Add Guard Rails (Hardening)

**Goal**: Make checkpoint bypass impossible

1. Implement checkpoint state machine
2. Add pre-commit hooks
3. Create runtime validators
4. Enforce marker file protocol
5. Add metadata schema validation

**Deliverables**:
- Checkpoint state enforcement
- Pre-commit validation
- Runtime guards
- Comprehensive error messages

**Timeline**: 2-3 hours

## Risks & Mitigations

### Risk 1: Breaking Existing Workflows

**Risk**: Removing simulation code breaks current command execution

**Mitigation**:
- Phase 1 adds validation without breaking
- Test skill delegation in isolated tasks
- Provide rollback path (keep .sh files temporarily)
- Document migration for users

### Risk 2: Skill Tool Invocation Complexity

**Risk**: Invoking skills from markdown commands may not work as expected

**Mitigation**:
- Test skill invocation in prototype command
- Review Claude Code skill invocation documentation
- Start with one command (research) before migrating all
- Keep bash option (Option B) as fallback

### Risk 3: Incomplete Skill Implementation

**Risk**: Skills may not handle all cases that commands currently handle

**Mitigation**:
- Review skill implementations thoroughly
- Add missing error handling to skills
- Test edge cases (timeouts, partial results, failures)
- Document skill limitations

### Risk 4: Performance Degradation

**Risk**: Skill delegation may add latency vs direct implementation

**Mitigation**:
- Measure baseline performance with simulation code
- Measure performance with real skill delegation
- Optimize if needed (consider caching, parallel execution)
- Document performance expectations

### Risk 5: Metadata File Race Conditions

**Risk**: Concurrent operations may corrupt metadata files

**Mitigation**:
- Use file locking for metadata writes
- Include session_id in metadata file path for uniqueness
- Add validation that session_id matches expected value
- Detect and report stale metadata files

## Appendix

### Search Queries Used

1. Grep: `Task tool|Skill tool|subagent_type` in `.claude/skills/`
2. Glob: `.claude/commands/**/*`
3. Glob: `.claude/skills/**/*.md`
4. Glob: `.claude/context/core/patterns/*`
5. Read: All command scripts and key skills

### References

**Checkpoint Pattern**:
- `.claude/context/core/patterns/checkpoint-execution.md` - 3-checkpoint model
- `.claude/context/core/checkpoints/` - Detailed checkpoint specs

**Skills**:
- `.claude/skills/skill-researcher/SKILL.md` - General research delegation
- `.claude/skills/skill-planner/SKILL.md` - Plan creation delegation
- `.claude/skills/skill-implementer/SKILL.md` - Implementation delegation

**State Management**:
- `.claude/rules/state-management.md` - State update patterns
- `.claude/context/core/formats/return-metadata-file.md` - Metadata schema

**Patterns**:
- `.claude/context/core/patterns/postflight-control.md` - Marker file protocol
- `.claude/context/core/patterns/thin-wrapper-skill.md` - Skill delegation pattern
- `.claude/context/core/patterns/file-metadata-exchange.md` - File I/O helpers

### Key Files Analyzed

**Commands** (8 files):
- research.sh, research.md
- plan.sh, plan.md
- implement.sh, implement.md
- revise.sh, revise.md (not analyzed in detail)

**Skills** (13 files):
- skill-researcher/SKILL.md
- skill-planner/SKILL.md
- skill-implementer/SKILL.md
- skill-lean-research/SKILL.md
- skill-lean-implementation/SKILL.md
- skill-latex-implementation/SKILL.md
- (7 others scanned but not analyzed in detail)

**Context Documentation** (10 files):
- checkpoint-execution.md
- return-metadata-file.md
- subagent-return.md
- postflight-control.md
- state-management.md
- (5 others referenced but not primary sources)

### Definitions

**Checkpoint**: Validation and state update point in command execution

**GATE IN**: Checkpoint 1 - Validate preconditions before work

**GATE OUT**: Checkpoint 2 - Validate results after work

**COMMIT**: Checkpoint 3 - Finalize with git commit

**Skill**: Thin wrapper that delegates to agents via Task tool

**Agent**: Work executor that creates artifacts and metadata

**Postflight**: Operations after agent returns (status update, artifact linking, commit)

**Metadata file**: JSON file at `specs/{N}_{SLUG}/.return-meta.json` containing agent results

**Marker file**: JSON file at `specs/.postflight-pending` signaling postflight in progress

**Session ID**: Unique identifier for command execution (`sess_{timestamp}_{random}`)

**Delegation context**: JSON object passed to skills containing task info and session tracking
