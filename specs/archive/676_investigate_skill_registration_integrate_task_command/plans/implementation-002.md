# Implementation Plan: Task #676 (v2)

- **Task**: 676 - Investigate skill registration and integrate /task command with checkpoint pattern
- **Status**: [NOT STARTED]
- **Effort**: 16 hours (revised from 8h based on Task 677 research)
- **Priority**: High
- **Dependencies**: Coordinate with Tasks 674, 675, 677
- **Research Inputs**:
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-001.md
  - specs/676_investigate_skill_registration_integrate_task_command/reports/research-002.md
  - specs/677_study_preflight_postflight_patterns_for_improvements/reports/research-001.md (NEW)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This revised plan incorporates critical findings from Task 677's research on preflight/postflight patterns. The original plan focused on archiving .opencode/ and adding hooks, but Task 677 revealed a deeper issue: **commands contain simulation code that bypasses skills entirely** (lines 385-430 in research.sh). The system is "90% correctly designed but 0% correctly wired" - skills exist and work correctly, they're just never invoked.

### Key Revision Rationale

**From Task 677 Research**:
1. **Root cause**: Commands have placeholder simulation code instead of real skill invocation
2. **Skills are correct**: 11-stage pattern in skills is properly implemented
3. **Agents are correct**: Return metadata pattern is properly implemented
4. **Only commands are broken**: Simulation code creates fake artifacts
5. **Recommended approach**: 4-phase migration from simulation → real delegation → markdown-only commands → guard rails

### Changed Strategy

**Original Plan (v1)**: Add hooks to enforce checkpoints
**Revised Plan (v2)**: Remove simulation code and wire commands to actually invoke skills

The hook-based approach from v1 assumed commands were invoking skills but not validating results. Task 677 revealed commands aren't invoking skills at all. Hooks alone won't fix simulation code.

## Goals & Non-Goals

**Goals**:
- Remove simulation code from research.sh, plan.sh, implement.sh
- Wire commands to actually invoke skills via Skill tool
- Add validation to ensure skills were invoked (not bypassed)
- Archive .opencode/ legacy system (carried from v1)
- Migrate commands to markdown-only format (long-term)
- Document corrected architecture in CLAUDE.md

**Non-Goals**:
- Redesigning the skill/agent architecture (it's correct)
- Implementing new checkpoint patterns (existing 11-stage is correct)
- Adding complexity to skills (they're properly implemented)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking commands during migration | High | Medium | Phase 1 adds validation without breaking; keep .sh until Phase 3 |
| Skill tool invocation complexity | High | Medium | Test with one command (research) first |
| Performance degradation | Medium | Low | Measure baseline, accept small overhead for correctness |
| Metadata file race conditions | Medium | Low | Include session_id in paths, add validation |
| Coordination with Tasks 674, 675 | Medium | Medium | This task creates reusable patterns |

## Implementation Phases

### Phase 1: Add Validation Layer (Non-Breaking) [NOT STARTED]

**Goal**: Detect when delegation is bypassed without breaking current functionality

**Priority**: P1 (enables subsequent phases)

**Tasks**:
- [ ] Create `.claude/lib/validate-delegation.sh` library with:
  - `validate_skill_delegation()` function
  - Metadata file schema validation
  - Artifact existence verification
  - Postflight marker cleanup check
  - Session ID match verification
- [ ] Add warning-only validation calls to research.sh, plan.sh, implement.sh
- [ ] Create `commit_with_logging()` function that logs failures to errors.json
- [ ] Test that warnings appear when simulation code runs

**Timing**: 3 hours

**Files to create**:
- `.claude/lib/validate-delegation.sh`

**Files to modify**:
- `.claude/commands/research.sh` (add warning-only validation)
- `.claude/commands/plan.sh` (add warning-only validation)
- `.claude/commands/implement.sh` (add warning-only validation)

**Verification**:
- Commands still run without breaking
- Warnings appear indicating "Skill was not invoked"
- Commit failures are logged to errors.json
- Validation library functions return correct exit codes

**Validation Script**:
```bash
validate_skill_delegation() {
  local metadata_file="$1"
  local expected_status="$2"

  # Check metadata file exists and is valid JSON
  if ! [ -f "$metadata_file" ] || ! jq empty "$metadata_file" 2>/dev/null; then
    echo "WARNING: Skill did not create valid metadata file"
    return 1
  fi

  # Check required fields
  if ! jq -e '.status and .artifacts and .metadata.session_id' "$metadata_file" >/dev/null; then
    echo "WARNING: Metadata missing required fields"
    return 1
  fi

  # Verify artifacts exist and are non-empty
  jq -r '.artifacts[].path' "$metadata_file" | while read artifact_path; do
    if ! [ -s "$artifact_path" ]; then
      echo "WARNING: Artifact missing or empty: $artifact_path"
      return 1
    fi
  done

  # Check postflight marker was cleaned up
  if [ -f "specs/.postflight-pending" ]; then
    echo "WARNING: Postflight marker not cleaned up"
    return 1
  fi

  return 0
}
```

---

### Phase 2: Implement Real Skill Delegation (Breaking) [NOT STARTED]

**Goal**: Replace simulation code with actual skill invocation

**Priority**: P0 (fixes root cause)

**Tasks**:
- [ ] In research.sh, replace lines 385-430 (simulation code) with:
  ```bash
  # Invoke skill-researcher via Skill tool pattern
  # Skill handles all preflight/postflight internally
  ```
- [ ] In plan.sh, replace simulation code with skill-planner invocation
- [ ] In implement.sh, replace simulation code with skill-implementer invocation
- [ ] Change validation from warning-only to fatal errors
- [ ] Test all three commands end-to-end with real delegation

**Timing**: 4 hours

**Specific Code Changes**:

**research.sh** - Replace this:
```bash
# For now, we'll simulate the delegation with a placeholder
echo "Note: Full delegation implementation requires Task tool integration"
echo "Proceeding with simulation..."

# Create a sample research report (FAKE)
report_file="$task_dir/reports/research-$session_id.md"
cat > "$report_file" <<EOF
...
EOF

# Create metadata file (FAKE)
metadata_file="$task_dir/.meta/research-return-meta.json"
cat > "$metadata_file" <<EOF
...
EOF
```

With this pattern:
```bash
# Invoke skill via Skill tool
# The skill handles preflight, delegation to agent, and postflight
echo "Invoking skill-researcher for $task_language research..."
echo "Session ID: $session_id"

# Skill invocation happens via Claude Code's Skill tool
# This bash script prepares context and validates results
# Actual invocation is through the Skill tool, not bash subprocess

# After skill completes, validate metadata
metadata_file="$task_dir/.meta/research-return-meta.json"
if ! validate_skill_delegation "$metadata_file" "researched"; then
  echo "ERROR: Skill delegation failed validation"
  exit 1
fi
```

**Files to modify**:
- `.claude/commands/research.sh` - Remove simulation, add skill invocation
- `.claude/commands/plan.sh` - Remove simulation, add skill invocation
- `.claude/commands/implement.sh` - Remove simulation, add skill invocation

**Verification**:
- `/research N` creates real research report via agent
- `/plan N` creates real implementation plan via agent
- `/implement N` executes real phases via agent
- All postflight operations execute correctly
- Validation fails if skill not invoked

---

### Phase 3: Archive .opencode Legacy System [NOT STARTED]

**Goal**: Eliminate dual-system confusion (carried from v1)

**Priority**: P1

**Tasks**:
- [ ] Search codebase for `.opencode/` references using Grep
- [ ] Document all files containing .opencode references
- [ ] Update discovered references to point to `.claude/` equivalents
- [ ] Create archive directory `archive/opencode-legacy-20260125/`
- [ ] Move `.opencode/` and `.opencode_OLD/` to archive
- [ ] Add note to archive explaining historical context
- [ ] Verify no broken paths remain

**Timing**: 1.5 hours

**Verification**:
- `grep -r ".opencode" --include="*.md" --include="*.sh"` returns no active results
- All commands still function after archival
- Archive directory contains complete .opencode/ contents

---

### Phase 4: Migrate to Markdown-Only Commands [NOT STARTED]

**Goal**: Delete .sh files, unify commands with skills

**Priority**: P1 (architectural improvement)

**Tasks**:
- [ ] Add frontmatter to research.md (allowed-tools, model, hooks)
- [ ] Simplify research.md to validation + Skill call + verification
- [ ] Test research.md executes correctly via Claude Code
- [ ] Delete research.sh
- [ ] Repeat for plan.md (add frontmatter, simplify, test, delete .sh)
- [ ] Repeat for implement.md (add frontmatter, simplify, test, delete .sh)

**Timing**: 6 hours (2 hours per command)

**Target Structure**:

```markdown
---
description: Research a task and create reports
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101
hooks:
  PreToolUse:
    - match: "Skill"
      script: ".claude/lib/validate-delegation.sh gate_in"
  PostToolUse:
    - match: "Skill"
      script: ".claude/lib/validate-delegation.sh gate_out"
---

# /research Command

Research a task by delegating to the appropriate research skill.

## Arguments
- `$1` - Task number (required)
- Remaining args - Optional focus/prompt

## Execution

### CHECKPOINT 1: GATE IN
1. Generate session_id
2. Read task from state.json (jq)
3. Validate task exists and status allows research
4. ABORT if validation fails

### STAGE 2: DELEGATE
Invoke skill based on language:
- lean → skill-lean-research
- other → skill-researcher

Use Skill tool - skill handles ALL work (preflight, delegation, postflight).

### CHECKPOINT 2: GATE OUT
Verify skill completed (automatic via PostToolUse hook)

### CHECKPOINT 3: COMMIT
Skills handle git commits internally.

## Output
Display skill's return summary.
```

**Files to delete**:
- `.claude/commands/research.sh`
- `.claude/commands/plan.sh`
- `.claude/commands/implement.sh`

**Verification**:
- All commands work via markdown files only
- No .sh files remain in .claude/commands/
- Documentation and implementation are unified

---

### Phase 5: Add Checkpoint Guard Rails [NOT STARTED]

**Goal**: Make checkpoint bypass impossible

**Priority**: P2 (hardening)

**Tasks**:
- [ ] Implement checkpoint state machine in `.claude/lib/checkpoint-state.sh`:
  - `checkpoint_gate_in()` - Records GATE_IN completed
  - `checkpoint_delegate()` - Verifies GATE_IN, records DELEGATE
  - `checkpoint_gate_out()` - Verifies DELEGATE, records GATE_OUT
  - `checkpoint_commit()` - Verifies GATE_OUT, cleans up
- [ ] Add checkpoint state tracking to validation library
- [ ] Configure skill-scoped hooks to call state machine
- [ ] Create pre-commit hook to prevent simulation code from merging
- [ ] Document guard rail pattern

**Timing**: 3 hours

**State Machine**:
```bash
checkpoint_state_file="specs/.checkpoint-state-${session_id}.json"

checkpoint_gate_in() {
  echo '{"checkpoint": "GATE_IN", "completed": true, "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' \
    > "$checkpoint_state_file"
}

checkpoint_delegate() {
  if ! jq -e '.checkpoint == "GATE_IN" and .completed == true' "$checkpoint_state_file" >/dev/null 2>&1; then
    echo "ERROR: Cannot DELEGATE - GATE_IN not completed"
    exit 1
  fi
  jq '.checkpoint = "DELEGATE" | .skill_invoked = true' "$checkpoint_state_file" > /tmp/cp.json && mv /tmp/cp.json "$checkpoint_state_file"
}

checkpoint_gate_out() {
  if ! jq -e '.checkpoint == "DELEGATE" and .skill_invoked == true' "$checkpoint_state_file" >/dev/null 2>&1; then
    echo "ERROR: Cannot GATE_OUT - DELEGATE not completed"
    exit 1
  fi
  jq '.checkpoint = "GATE_OUT" | .postflight_verified = true' "$checkpoint_state_file" > /tmp/cp.json && mv /tmp/cp.json "$checkpoint_state_file"
}

checkpoint_commit() {
  if ! jq -e '.checkpoint == "GATE_OUT" and .postflight_verified == true' "$checkpoint_state_file" >/dev/null 2>&1; then
    echo "ERROR: Cannot COMMIT - GATE_OUT not completed"
    exit 1
  fi
  rm -f "$checkpoint_state_file"
}
```

**Files to create**:
- `.claude/lib/checkpoint-state.sh`

**Verification**:
- Cannot skip checkpoints (state machine enforces order)
- Pre-commit hooks prevent simulation code
- Runtime errors if checkpoints violated

---

### Phase 6: Update CLAUDE.md Documentation [NOT STARTED]

**Goal**: Document corrected architecture

**Priority**: P1

**Tasks**:
- [ ] Add "Architecture Correction" section explaining:
  - Commands previously had simulation code bypassing skills
  - Skills were always correctly implemented
  - Migration wired commands to skills properly
- [ ] Update "Command Execution Flow" to show:
  ```
  User → Command (GATE IN) → Skill (preflight+delegate+postflight) → Agent (work) → Return
  ```
- [ ] Remove or mark as historical any .opencode references
- [ ] Update skill architecture section with 2026 commands-as-skills pattern
- [ ] Add reference to validation and checkpoint libraries

**Timing**: 1.5 hours

**Verification**:
- Documentation matches actual implementation
- No misleading information about simulation or .opencode
- Clear explanation of corrected architecture

---

## Priority Summary

| Priority | Phase | Description | Hours |
|----------|-------|-------------|-------|
| P0 | Phase 2 | Real skill delegation (fixes root cause) | 4 |
| P1 | Phase 1 | Validation layer (enables P0) | 3 |
| P1 | Phase 3 | Archive .opencode | 1.5 |
| P1 | Phase 4 | Markdown-only commands | 6 |
| P1 | Phase 6 | Documentation | 1.5 |
| P2 | Phase 5 | Guard rails | 3 |
| **Total** | | | **19 hours** |

**Critical Path**: Phase 1 → Phase 2 (7 hours) gets system working correctly.

## Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Skills invoked per command | 0% | 100% | Check metadata file created by agent |
| Agents executed per operation | 0% | 100% | Verify real artifacts created |
| Validation failures caught | 0% | 100% | Test with invalid task |
| Checkpoint bypass possible | Yes | No | Try skipping skill |
| Command file count | 6 (.sh + .md) | 3 (.md only) | `ls .claude/commands/` |
| State update duplication | 100% | 0% | Only skills update state |
| Simulation code in commands | ~150 lines | 0 lines | Grep for "simulation" |
| .opencode references | ~10 | 0 | Grep for ".opencode" |

## Testing & Validation

- [ ] `/research N` creates real report via agent (not stub)
- [ ] `/plan N` creates real plan via agent (not stub)
- [ ] `/implement N` executes real phases via agent
- [ ] Validation library catches missing metadata
- [ ] Validation library catches missing artifacts
- [ ] Checkpoint state machine prevents bypass
- [ ] No .opencode references in active codebase
- [ ] All commands work without .sh files (Phase 4)
- [ ] CLAUDE.md accurately documents architecture

## Artifacts & Outputs

- `.claude/lib/validate-delegation.sh` - Validation library
- `.claude/lib/checkpoint-state.sh` - Checkpoint state machine
- `archive/opencode-legacy-20260125/` - Archived legacy system
- Updated `.claude/commands/{research,plan,implement}.md` - Markdown-only commands
- Updated `.claude/CLAUDE.md` - Corrected architecture docs
- `specs/676_investigate_skill_registration_integrate_task_command/summaries/implementation-summary-YYYYMMDD.md` - Summary

## Rollback/Contingency

**If skill delegation breaks commands** (Phase 2):
1. Revert to simulation code (git revert phase 2 commits)
2. Keep validation library active for warnings
3. Debug skill invocation separately

**If markdown-only migration fails** (Phase 4):
1. Keep .sh files
2. Commands work via bash
3. Debug markdown invocation pattern separately

**Git branch strategy**:
- Create feature branch before Phase 1
- Commit after each phase for granular rollback
- Test thoroughly before merging to main

## Coordination Notes

**Task 674** (Systematic command-skill-agent architecture improvement):
- This task fixes the root cause for /research, /plan, /implement
- Task 674 can build on these patterns for additional commands

**Task 675** (Enforce skill postflight checkpoint pattern):
- This task implements validation that proves enforcement
- Task 675 validates the guard rails work

**Task 677** (Study preflight/postflight patterns for improvements):
- Research from Task 677 directly informed this revision
- Task 677's 4-phase approach adopted and expanded to 6 phases

## Changes from v1

| Aspect | v1 (Original) | v2 (Revised) |
|--------|---------------|--------------|
| Root cause | Commands not validating skills | Commands not invoking skills |
| Approach | Add hooks to enforce validation | Remove simulation, wire real skills |
| Effort | 8 hours | 16 hours |
| Phases | 5 | 6 |
| Primary fix | Checkpoint hooks | Real skill delegation |
| .opencode archival | Phase 1 | Phase 3 (after core fix) |
| Markdown migration | Not planned | Phase 4 (new) |
| Guard rails | Phase 5 (hooks only) | Phase 5 (state machine) |
| Research inputs | 2 reports | 3 reports (+ Task 677) |
