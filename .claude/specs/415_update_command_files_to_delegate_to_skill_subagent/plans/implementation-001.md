# Implementation Plan: Task #415

**Task**: Update command files to delegate to skill/subagent system
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Update the three primary workflow commands (/research, /plan, /implement) to delegate to the skill/subagent system instead of executing inline. Each command will be converted to a thin wrapper that:
1. Validates the task and extracts language
2. Updates status to "in progress" state
3. Invokes the appropriate skill via the Skill tool (based on task language)
4. Updates status to "completed" state based on skill result
5. Commits changes and outputs results

This completes the forked subagent pattern by connecting command entry points to the existing skill → agent infrastructure.

## Phases

### Phase 1: Update /research command

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Convert /research from inline execution to skill delegation
2. Route to skill-lean-research or skill-researcher based on task language

**Files to modify**:
- `.claude/commands/research.md` - Full rewrite

**Steps**:
1. Read the current research.md to understand its structure
2. Reduce `allowed-tools` to `Skill, Bash(jq:*), Read`
3. Keep task validation logic (jq lookup)
4. Keep status validation logic
5. Replace inline research execution with Skill tool invocation:
   - If language == "lean": invoke `skill-lean-research`
   - Else: invoke `skill-researcher`
6. Keep status update calls (skill-status-sync pattern)
7. Keep git commit and output sections
8. Update model to match current standard

**New command structure**:
```markdown
---
description: Research a task and create reports
allowed-tools: Skill, Bash(jq:*), Read
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101
---

# /research Command

## Execution
1. Parse and Validate (jq lookup)
2. Validate Status
3. Update Status to RESEARCHING (skill-status-sync)
4. Route by Language → Invoke Skill
5. Handle Skill Result
6. Update Status to RESEARCHED (skill-status-sync)
7. Git Commit
8. Output
```

**Verification**:
- [ ] File has reduced allowed-tools
- [ ] Skill invocation replaces inline execution
- [ ] Language routing logic is correct

---

### Phase 2: Update /plan command

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Convert /plan from inline execution to skill delegation
2. Route to skill-planner (same for all languages)

**Files to modify**:
- `.claude/commands/plan.md` - Full rewrite

**Steps**:
1. Read the current plan.md to understand its structure
2. Reduce `allowed-tools` to `Skill, Bash(jq:*), Read`
3. Keep task validation logic (jq lookup)
4. Keep status validation logic
5. Replace inline plan creation with Skill tool invocation:
   - All languages → invoke `skill-planner`
6. Keep status update calls (skill-status-sync pattern)
7. Keep git commit and output sections

**New command structure**:
```markdown
---
description: Create implementation plan for a task
allowed-tools: Skill, Bash(jq:*), Read
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /plan Command

## Execution
1. Parse and Validate (jq lookup)
2. Validate Status
3. Update Status to PLANNING (skill-status-sync)
4. Invoke skill-planner
5. Handle Skill Result
6. Update Status to PLANNED (skill-status-sync)
7. Git Commit
8. Output
```

**Verification**:
- [ ] File has reduced allowed-tools
- [ ] Skill invocation replaces inline execution
- [ ] skill-planner is invoked for all languages

---

### Phase 3: Update /implement command

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Convert /implement from inline execution to skill delegation
2. Route to skill-lean-implementation, skill-latex-implementation, or skill-implementer based on language

**Files to modify**:
- `.claude/commands/implement.md` - Full rewrite

**Steps**:
1. Read the current implement.md to understand its structure
2. Reduce `allowed-tools` to `Skill, Bash(jq:*), Read`
3. Keep task validation logic (jq lookup)
4. Keep status validation logic
5. Keep resume point detection (read plan, find incomplete phase)
6. Replace inline implementation with Skill tool invocation:
   - If language == "lean": invoke `skill-lean-implementation`
   - If language == "latex": invoke `skill-latex-implementation`
   - Else: invoke `skill-implementer`
7. Handle partial/completed returns from skill
8. Keep status update calls (skill-status-sync pattern)
9. Keep git commit and output sections

**New command structure**:
```markdown
---
description: Execute implementation with resume support
allowed-tools: Skill, Bash(jq:*), Read
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /implement Command

## Execution
1. Parse and Validate (jq lookup)
2. Validate Status
3. Load Plan, Detect Resume Point
4. Update Status to IMPLEMENTING (skill-status-sync)
5. Route by Language → Invoke Skill
6. Handle Skill Result (completed/partial)
7. Update Status based on result
8. Git Commit
9. Output
```

**Verification**:
- [ ] File has reduced allowed-tools
- [ ] Skill invocation replaces inline execution
- [ ] Language routing covers lean, latex, and general/meta/markdown
- [ ] Partial result handling is preserved

---

### Phase 4: Integration Testing

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify the full workflow works end-to-end
2. Confirm subagents are being spawned correctly

**Steps**:
1. Find a test task (existing or create new)
2. Run `/research N` and verify:
   - Correct skill is invoked (skill-lean-research or skill-researcher)
   - Subagent is spawned (lean-research-agent or general-research-agent)
   - Research report is created
   - Status updates correctly
3. Run `/plan N` and verify:
   - skill-planner is invoked
   - planner-agent is spawned
   - Plan is created
   - Status updates correctly
4. Run `/implement N` and verify:
   - Correct implementation skill is invoked
   - Correct agent is spawned
   - Implementation proceeds
   - Status updates correctly

**Verification**:
- [ ] /research spawns subagent
- [ ] /plan spawns subagent
- [ ] /implement spawns subagent
- [ ] Full workflow completes successfully

---

## Dependencies

- Task 409: Convert workflow skills to forked subagent pattern (COMPLETED)
- Task 410: Remove eager context loading from skill frontmatter (COMPLETED)
- Task 411: Create lean-research-agent subagent (COMPLETED)
- Task 412: Create general-research-agent subagent (COMPLETED)
- Task 413: Create implementation agent subagents (COMPLETED)
- Task 414: Create planner-agent subagent (COMPLETED)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Skill invocation fails silently | High | Low | Add explicit error handling in command |
| Status updates out of sync | Medium | Medium | Keep atomic skill-status-sync pattern |
| Subagent doesn't return expected format | Medium | Low | Skills validate return format |
| Breaking existing workflow | High | Medium | Test each command after update |

## Success Criteria

- [ ] /research delegates to skill-lean-research or skill-researcher
- [ ] /plan delegates to skill-planner
- [ ] /implement delegates to skill-lean-implementation, skill-latex-implementation, or skill-implementer
- [ ] Status updates work correctly (RESEARCHING→RESEARCHED, PLANNING→PLANNED, IMPLEMENTING→COMPLETED)
- [ ] Git commits are created at appropriate points
- [ ] Subagents are actually spawned (visible in output)
- [ ] Full workflow test passes

## Rollback Plan

If implementation fails, restore original command files from git:
```bash
git checkout HEAD~N -- .claude/commands/research.md
git checkout HEAD~N -- .claude/commands/plan.md
git checkout HEAD~N -- .claude/commands/implement.md
```

Where N is the number of commits to roll back.
