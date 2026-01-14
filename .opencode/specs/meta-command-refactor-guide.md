# /meta Command Refactor Guide

**Created**: 2026-01-09
**Source**: ModelChecker repository refactor
**Purpose**: Guide for updating /meta command to create tasks instead of directly implementing work

---

## Problem Statement

### Previous Behavior

The `/meta` command was directly implementing work:
- Created commands, skills, rules, and context files immediately
- Modified CLAUDE.md and ARCHITECTURE.md directly
- Used TodoWrite for internal tracking only
- Did NOT create tasks in `.claude/specs/TODO.md`
- Did NOT create tasks in `.claude/specs/state.json`
- Did NOT create plan artifacts

### Why This Is Wrong

1. **Bypasses task management system**: Work isn't tracked or recoverable
2. **No plan artifacts**: Can't review approach before implementation
3. **No git history per component**: Single large commit instead of incremental
4. **Can't resume**: If interrupted, no way to continue from checkpoint
5. **No effort tracking**: Can't measure how long components take
6. **Inconsistent with other commands**: /research, /plan, /implement all use task system

### Correct Behavior

The `/meta` command should:
1. Analyze domain requirements (Stages 1-5)
2. Propose architecture with component list (Stage 6)
3. **Create N tasks** in TODO.md and state.json (Stage 7)
4. **Create plan artifacts** for each task (Stage 7)
5. Git commit the tasks/plans (Stage 8)
6. Output summary with next steps (Stage 9)

Then user runs `/implement {N}` for each task to actually build components.

---

## Infrastructure Requirements

The following infrastructure must exist for /meta to work correctly:

### 1. State Files

**`.claude/specs/state.json`** must have structure:
```json
{
  "next_project_number": 349,
  "active_projects": [
    {
      "project_number": 348,
      "project_name": "task_slug",
      "status": "planned",
      "language": "meta",
      "priority": "high",
      "created": "2026-01-09T10:00:00Z",
      "last_updated": "2026-01-09T10:00:00Z"
    }
  ]
}
```

**`.claude/specs/TODO.md`** must have structure:
```markdown
---
next_project_number: 349
...
---

# TODO

## High Priority

### 348. Task Title
- **Effort**: 2-4 hours
- **Status**: [PLANNED]
- **Priority**: High
- **Language**: meta
- **Plan**: [implementation-001.md](.claude/specs/348_task_slug/plans/implementation-001.md)

**Description**: Task description here.

---

## Medium Priority

...

## Low Priority

...
```

### 2. Rules Files

These rules define formats and patterns:

- `.claude/rules/state-management.md` - Two-phase update pattern
- `.claude/rules/artifact-formats.md` - Plan/report templates
- `.claude/rules/workflows.md` - Command lifecycle patterns

### 3. Skills

- `skill-status-sync` - Atomic updates to TODO.md + state.json
- `skill-git-workflow` - Scoped git commits

---

## Updated /meta Command

Replace `.claude/commands/meta.md` with the following content:

```markdown
---
description: Interactive system builder for agent architectures
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Task, TodoWrite, WebSearch
argument-hint: [DOMAIN] | --analyze | --generate
model: claude-opus-4-5-20251101
---

# /meta Command

Interactive system builder for creating agent architectures, commands, and skills.

**IMPORTANT**: This command creates TASKS with PLANS. It does NOT directly implement anything.

## Arguments

- No args: Start interactive interview
- `DOMAIN` - Direct domain specification
- `--analyze` - Analyze existing .claude/ structure
- `--generate` - Generate from previous interview

## Constraints

**FORBIDDEN**: This command ONLY creates tasks and plans. Never:
- Directly create commands, skills, rules, or context files
- Directly modify CLAUDE.md or ARCHITECTURE.md
- Implement any work
- Write any code or configuration files outside .claude/specs/

**REQUIRED**: All work must be tracked via:
- Tasks in TODO.md and state.json
- Plans in .claude/specs/{N}_{SLUG}/plans/

## Modes

### Interactive Mode (Default)

Multi-stage interview process to design agent system.

#### Stage 1: Domain Discovery

```
What domain will this system support?
Examples: "API development", "data pipeline", "game engine", "ML workflow"

Domain: {user_input}
```

#### Stage 2: Use Case Gathering

```
What are the main use cases?
1. {use_case_1}
2. {use_case_2}
3. {use_case_3}
(Enter blank line when done)
```

#### Stage 3: Workflow Analysis

```
For each use case, what's the typical workflow?

Use case: {use_case_1}
Steps:
1. {step}
2. {step}
...
```

#### Stage 4: Tool Requirements

```
What tools/integrations are needed?
- [ ] Web search
- [ ] File operations
- [ ] Git operations
- [ ] External APIs
- [ ] Build tools
- [ ] Testing frameworks
- [ ] Custom MCP servers

Selected: {tools}
```

#### Stage 5: Complexity Assessment

```
System complexity:
- Simple: 2-3 commands, 1-2 skills
- Medium: 4-6 commands, 3-5 skills
- Complex: 7+ commands, 6+ skills

Assessment: {level}
```

#### Stage 6: Architecture Design

Based on interview, propose architecture:

```
Proposed Architecture:

Commands:
1. /{command1} - {description}
2. /{command2} - {description}
...

Skills:
1. {skill1} - {when invoked}
2. {skill2} - {when invoked}
...

Rules:
1. {rule1}.md - {scope}
...

Context Files:
1. {context1}.md - {purpose}
...

Documentation Updates:
1. CLAUDE.md - {changes needed}
2. ARCHITECTURE.md - {changes needed}

Total tasks to create: {N}

Proceed with task creation? (y/n)
```

#### Stage 7: Task Creation

**For each component identified in Stage 6, create a task with a plan.**

##### 7.1 Read Current State

```bash
# Get next task number
jq '.next_project_number' .claude/specs/state.json
```

##### 7.2 Create Tasks Sequentially

For each component (command, skill, rule, context file, doc update):

**A. Create task directory:**
```bash
mkdir -p .claude/specs/{N}_{SLUG}/plans/
```

**B. Update state.json** (add to active_projects):
```json
{
  "project_number": {N},
  "project_name": "{slug}",
  "status": "planned",
  "language": "meta",
  "priority": "{high|medium|low}",
  "created": "{ISO_DATE}",
  "last_updated": "{ISO_DATE}"
}
```

**C. Update TODO.md** (add entry under appropriate priority):
```markdown
### {N}. {Title}
- **Effort**: {estimate}
- **Status**: [PLANNED]
- **Priority**: {High|Medium|Low}
- **Language**: meta
- **Created**: {ISO_DATE}
- **Plan**: [implementation-001.md](.claude/specs/{N}_{SLUG}/plans/implementation-001.md)

**Description**: {detailed description of component to create}

**Files to Create/Modify**:
- {target file path}
```

**D. Create plan artifact** at `.claude/specs/{N}_{SLUG}/plans/implementation-001.md`:
```markdown
# Implementation Plan: Task #{N}

**Task**: {title}
**Version**: 001
**Created**: {ISO_DATE}
**Language**: meta

## Overview

{Description of what to create and why}

## Phases

### Phase 1: Create {Component Type}

**Estimated effort**: {hours}
**Status**: [NOT STARTED]

**Objectives**:
1. Create {component} following project standards
2. Integrate with existing system

**Files to create/modify**:
- `{target_path}` - {description}

**Steps**:
1. {Step 1}
2. {Step 2}
3. {Step 3}

**Verification**:
- File exists and has valid frontmatter
- No syntax errors
- Integrates with existing components

## Success Criteria

- [ ] {Component} created at correct path
- [ ] Follows project conventions
- [ ] Documented in CLAUDE.md if applicable
```

**E. Increment next_project_number** in state.json

##### 7.3 Priority Assignment

| Component Type | Default Priority |
|----------------|------------------|
| CLAUDE.md update | High |
| ARCHITECTURE.md update | High |
| Commands | High |
| Skills | Medium |
| Rules | Medium |
| Context files | Low |

##### 7.4 Task Ordering

Create tasks in this order (dependencies flow downward):
1. Documentation updates (CLAUDE.md, ARCHITECTURE.md)
2. Rules (define standards before implementing)
3. Skills (core functionality)
4. Commands (user-facing, depend on skills)
5. Context files (reference material)

#### Stage 8: Git Commit

```bash
git add .claude/specs/
git commit -m "meta: create {N} tasks for {domain} system"
```

#### Stage 9: Summary Output

```
Meta system builder complete.

Created {N} tasks with implementation plans:

High Priority:
- Task #{N1}: {title}
  Plan: .claude/specs/{N1}_{SLUG}/plans/implementation-001.md

- Task #{N2}: {title}
  Plan: .claude/specs/{N2}_{SLUG}/plans/implementation-001.md

Medium Priority:
- Task #{N3}: {title}
  Plan: .claude/specs/{N3}_{SLUG}/plans/implementation-001.md

Low Priority:
- Task #{N4}: {title}
  Plan: .claude/specs/{N4}_{SLUG}/plans/implementation-001.md

Next steps:
1. Review tasks in TODO.md
2. Review plans in .claude/specs/
3. Execute: /implement {N1} (start with highest priority)
4. Continue through task list
```

### Analyze Mode (--analyze)

Examine existing .claude/ structure:

```
Current .claude/ Structure:

Commands ({N}):
- /{command1} - {description}
- /{command2} - {description}

Skills ({N}):
- {skill1} - {description}
- {skill2} - {description}

Rules ({N}):
- {rule1}.md - {paths}

Context:
- core/: {N} files
- project/: {N} files

Settings:
- Permissions: {N} allow, {N} deny
- Hooks: {N} configured

Recommendations:
1. {suggestion}
2. {suggestion}
```

### Generate Mode (--generate)

Re-run task creation from last interview session stored in memory.

## Component Templates

These templates guide plan creation. The actual files are created during /implement.

### Command Task Description Template

```
Create /{command} command for {purpose}.

The command should:
- {Capability 1}
- {Capability 2}

Arguments:
- {arg1} - {description}

Tools needed: {tool list}

Target file: .claude/commands/{command}.md
```

### Skill Task Description Template

```
Create {skill-name} skill for {purpose}.

The skill should:
- {Capability 1}
- {Capability 2}

Trigger conditions:
- {When to invoke}

Tools needed: {tool list}

Target file: .claude/skills/{skill-name}/SKILL.md
```

### Rule Task Description Template

```
Create {rule}.md rule for {purpose}.

The rule should define:
- {Standard 1}
- {Standard 2}

Applies to: {glob pattern}

Target file: .claude/rules/{rule}.md
```

### Context File Task Description Template

```
Create {context}.md context file for {purpose}.

The file should document:
- {Topic 1}
- {Topic 2}

Target file: .claude/context/project/{domain}/{context}.md
```

## Example Execution

User runs: `/meta "Lean 4 theorem proving"`

Output after Stage 9:
```
Meta system builder complete.

Created 8 tasks with implementation plans:

High Priority:
- Task #350: Update CLAUDE.md for Lean 4 focus
  Plan: .claude/specs/350_update_claude_md_lean4/plans/implementation-001.md

- Task #351: Update ARCHITECTURE.md for Lean system
  Plan: .claude/specs/351_update_architecture_lean4/plans/implementation-001.md

Medium Priority:
- Task #352: Create skill-lean-research for Mathlib research
  Plan: .claude/specs/352_create_skill_lean_research/plans/implementation-001.md

- Task #353: Create skill-lean-implementation for proof writing
  Plan: .claude/specs/353_create_skill_lean_implementation/plans/implementation-001.md

- Task #354: Update skill-orchestrator for Lean routing
  Plan: .claude/specs/354_update_skill_orchestrator_lean/plans/implementation-001.md

- Task #355: Create lean4.md rule for development patterns
  Plan: .claude/specs/355_create_lean4_rule/plans/implementation-001.md

Low Priority:
- Task #356: Create lean4/tools/mcp-tools-guide.md context
  Plan: .claude/specs/356_create_lean4_mcp_tools_context/plans/implementation-001.md

- Task #357: Create lean4/patterns/tactic-patterns.md context
  Plan: .claude/specs/357_create_lean4_tactic_patterns_context/plans/implementation-001.md

Next steps:
1. Review tasks in TODO.md
2. Review plans in .claude/specs/
3. Execute: /implement 350 (start with highest priority)
4. Continue through task list
```
```

---

## Key Changes Summary

| Aspect | Before | After |
|--------|--------|-------|
| Direct implementation | Yes | No (forbidden) |
| Creates tasks | No | Yes (in TODO.md + state.json) |
| Creates plans | No | Yes (in .claude/specs/{N}_{SLUG}/plans/) |
| Git commits | One large commit | One commit with all tasks/plans |
| Resumable | No | Yes (via /implement) |
| Trackable | No | Yes (task numbers, status markers) |
| Reviewable | No | Yes (plans can be reviewed before /implement) |

---

## Implementation Checklist

To apply this refactor to ProofChecker:

- [ ] Verify `.claude/specs/state.json` exists with correct structure
- [ ] Verify `.claude/specs/TODO.md` exists with correct structure
- [ ] Verify `.claude/rules/state-management.md` exists
- [ ] Verify `.claude/rules/artifact-formats.md` exists
- [ ] Replace `.claude/commands/meta.md` with updated version above
- [ ] Test with `/meta --analyze` to verify it reads existing structure
- [ ] Test with `/meta "test domain"` to verify task creation works

---

## Related Documentation

- `rules/state-management.md` - Two-phase update pattern for state files
- `rules/artifact-formats.md` - Templates for plans, reports, summaries
- `rules/workflows.md` - Command lifecycle patterns
- `ARCHITECTURE.md` - Full system architecture
- `CLAUDE.md` - Quick reference for commands

---

## Troubleshooting

### state.json not found
Create initial state.json:
```json
{
  "next_project_number": 1,
  "active_projects": []
}
```

### TODO.md not found
Create initial TODO.md:
```markdown
---
next_project_number: 1
---

# TODO

## High Priority

## Medium Priority

## Low Priority
```

### Tasks created but not visible
Check that:
1. state.json was updated (active_projects array)
2. TODO.md was updated (entry under correct priority section)
3. Plan file was created at correct path
4. next_project_number was incremented in both files
