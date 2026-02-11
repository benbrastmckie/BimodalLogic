# Git Staging Scope Guide

**Created**: 2026-02-11
**Purpose**: Define allowed git staging scopes per agent type to prevent race conditions in concurrent operations

---

## Overview

When multiple agents run concurrently (e.g., parallel research, team implementations), using `git add -A` or `git add .` creates race conditions: one agent may stage another agent's uncommitted changes, causing data loss or corrupted commits.

**Core Principle**: Each agent stages ONLY files within its designated scope.

---

## Agent Staging Scopes

### Research Agents (skill-researcher, skill-lean-research)

**Allowed files**:
```bash
git add \
  "specs/${task_number}_${project_name}/reports/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
```

**Rationale**: Research agents only create reports in their task directory and update shared state.

---

### Planner Agents (skill-planner)

**Allowed files**:
```bash
git add \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
```

**Rationale**: Planner agents only create plans in their task directory and update shared state.

---

### General Implementation Agents (skill-implementer)

**Allowed files**:
```bash
# Task-specific files (varies by task)
git add \
  "specs/${task_number}_${project_name}/summaries/" \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json" \
  "${implementation_files[@]}"  # Files created/modified per plan
```

**Note**: Implementation agents must explicitly list files they modify. The plan file specifies which files are modified per phase.

---

### Lean Implementation Agents (skill-lean-implementation)

**Allowed files**:
```bash
git add \
  "Theories/" \
  "specs/${task_number}_${project_name}/summaries/" \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
```

**Rationale**: Lean implementation agents modify files under `Theories/` and their task summaries.

---

### LaTeX/Typst Implementation Agents (skill-latex-implementation, skill-typst-implementation)

**Allowed files**:
```bash
git add \
  "docs/" \
  "specs/${task_number}_${project_name}/summaries/" \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
```

**Rationale**: Document implementation agents modify files under `docs/` and their task summaries.

---

### Meta Agents (skill-meta)

**Allowed files**:
```bash
git add \
  ".claude/" \
  "specs/${task_number}_${project_name}/" \
  "specs/TODO.md" \
  "specs/state.json"
```

**Rationale**: Meta agents modify `.claude/` configuration and their task directories.

---

## Special Cases

### /todo Command (Exclusive Access Required)

The `/todo` command archives completed tasks by:
- Moving directories from `specs/` to `specs/archive/`
- Updating `specs/TODO.md`, `specs/state.json`, `specs/archive/state.json`

**This command requires exclusive access to `specs/`**. Do not run `/todo` while other agents are operating on tasks.

```bash
# /todo uses broader staging (justified by exclusive access)
git add \
  "specs/TODO.md" \
  "specs/state.json" \
  "specs/archive/"
```

---

## Copy-Paste Bash Snippets

### Research Postflight Commit
```bash
git add \
  "specs/${task_number}_${project_name}/reports/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
git commit -m "task ${task_number}: complete research

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### Plan Postflight Commit
```bash
git add \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
git commit -m "task ${task_number}: create implementation plan

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### Implementation Phase Commit
```bash
# After updating phase status in plan file
git add \
  "specs/${task_number}_${project_name}/plans/" \
  "${modified_files[@]}"  # Files modified in this phase
git commit -m "task ${task_number} phase ${phase}: ${phase_name}

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### Implementation Complete Commit
```bash
git add \
  "specs/${task_number}_${project_name}/summaries/" \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json" \
  "${all_implementation_files[@]}"
git commit -m "task ${task_number}: complete implementation

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Verification Commands

### Check for Unsafe Patterns
```bash
# Should return no matches in skill/agent files (except /todo)
grep -r "git add -A" .claude/skills/
grep -r "git add -A" .claude/agents/

# Verify /todo is the only command with broad staging
grep -r "git add specs/" .claude/commands/
```

### Check Staged Files Before Commit
```bash
# Always verify before committing
git status --short
git diff --staged --stat
```

---

## Anti-Patterns

### DO NOT
```bash
# Stages all changes including other agents' work
git add -A
git add .
git commit -am "..."

# Stages entire specs directory (except for /todo)
git add specs/
```

### DO
```bash
# Stage only files your agent owns
git add "specs/${task_number}_${project_name}/reports/"
git add "specs/TODO.md"
git add "specs/state.json"
```

---

## Migration Checklist

When updating a skill or agent to use targeted staging:

- [ ] Identify all files the skill/agent modifies
- [ ] Replace `git add -A` with explicit file list
- [ ] Include task directory files: plans/, reports/, summaries/
- [ ] Include shared state files: TODO.md, state.json
- [ ] Include implementation-specific files (Theories/, docs/, .claude/)
- [ ] Test with a sample task to verify correct staging
- [ ] Run verification commands to confirm no `git add -A` remains

---

## References

- **Git Safety**: `.claude/context/core/standards/git-safety.md` - Rollback patterns
- **Git Workflow**: `.claude/rules/git-workflow.md` - Commit conventions
- **Research**: `specs/871_safer_git_staging_concurrent_agents/reports/research-001.md`
