# Implementation Plan: Task #871

- **Task**: 871 - safer_git_staging_concurrent_agents
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/871_safer_git_staging_concurrent_agents/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Replace unsafe `git add -A` patterns with targeted staging across skills, agents, and commands to prevent race conditions when concurrent agents modify overlapping files. The implementation follows a staged rollout: create documentation and helper patterns first, update high-risk skills, then extend to remaining components.

### Research Integration

From research-001.md:
- 40+ instances of `git add -A` identified across the codebase
- Agent file scope analysis completed (research/plan/implement agents)
- Targeted staging approach selected over file locking (simpler, no deadlock risk)
- /todo command identified as special case requiring exclusive access

## Goals & Non-Goals

**Goals**:
- Replace `git add -A` with targeted file staging in all skills and agents
- Document allowed file scopes per agent type
- Prevent concurrent agents from staging each other's uncommitted changes
- Maintain backward compatibility with existing workflows

**Non-Goals**:
- Implementing file locking mechanisms (rejected per research)
- Modifying /todo command (special case, requires exclusive access)
- Creating automated tests for concurrent agent scenarios (manual verification sufficient)
- Changing the fundamental git workflow (still commit at end of operations)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agents forget to list all modified files | Uncommitted changes accumulate | Medium | Clear documentation with copy-paste examples |
| Breaking existing workflows during rollout | Workflow failures | Medium | Staged rollout: skills first, verify, then agents |
| Inconsistent adoption across files | Partial protection | Low | Systematic grep verification after each phase |
| /todo still vulnerable to races | Data loss during archival | Medium | Document exclusive access requirement prominently |

## Implementation Phases

### Phase 1: Create Documentation and Patterns [COMPLETED]

**Goal**: Establish authoritative documentation for git staging scopes per agent type

**Tasks**:
- [ ] Create `.claude/context/core/standards/git-staging-scope.md` with agent-specific file scope rules
- [ ] Define allowed staging patterns for each agent type (research, plan, implement, meta)
- [ ] Add copy-paste bash snippets for targeted staging
- [ ] Document special case: /todo requires exclusive specs/ access
- [ ] Update `.claude/context/core/standards/git-safety.md` to reference new document

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/standards/git-staging-scope.md` - CREATE (new file)
- `.claude/context/core/standards/git-safety.md` - Update to reference new document

**Verification**:
- New file exists with all agent types documented
- git-safety.md links to new document

---

### Phase 2: Update High-Priority Skills [COMPLETED]

**Goal**: Replace `git add -A` in skills that handle research, planning, and implementation

**Tasks**:
- [ ] Update `skill-researcher/SKILL.md` postflight: stage only `specs/{N}_{SLUG}/reports/`, `specs/{N}_{SLUG}/.return-meta.json`, `specs/TODO.md`, `specs/state.json`
- [ ] Update `skill-lean-research/SKILL.md` postflight: same pattern as skill-researcher
- [ ] Update `skill-planner/SKILL.md` postflight: stage only `specs/{N}_{SLUG}/plans/`, `specs/{N}_{SLUG}/.return-meta.json`, `specs/TODO.md`, `specs/state.json`
- [ ] Update `skill-implementer/SKILL.md` postflight: stage task-specific files plus `specs/TODO.md`, `specs/state.json`
- [ ] Update `skill-lean-implementation/SKILL.md` postflight: stage `Theories/`, task summaries, `specs/TODO.md`, `specs/state.json`

**Timing**: 2 hours

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` (around line 232)
- `.claude/skills/skill-lean-research/SKILL.md` (around line 230)
- `.claude/skills/skill-planner/SKILL.md` (around line 80)
- `.claude/skills/skill-implementer/SKILL.md` (around line 333)
- `.claude/skills/skill-lean-implementation/SKILL.md` (around line 303)

**Verification**:
- `grep -r "git add -A" .claude/skills/` shows no matches in updated files
- Each updated file has explicit file list in git add command

---

### Phase 3: Update Remaining Skills and Commands [COMPLETED]

**Goal**: Complete skill coverage and update command files

**Tasks**:
- [ ] Update `skill-latex-implementation/SKILL.md` postflight
- [ ] Update `skill-typst-implementation/SKILL.md` postflight
- [ ] Update `skill-meta/SKILL.md` postflight: special case, stages `.claude/**` and `specs/**`
- [ ] Update `skill-git-workflow/SKILL.md` to use `git add {scope}` pattern
- [ ] Update team skills: `skill-team-research`, `skill-team-plan`, `skill-team-implement`
- [ ] Update command files: `implement.md`, `plan.md`, `research.md`, `revise.md`, `errors.md`

**Timing**: 2 hours

**Files to modify**:
- `.claude/skills/skill-latex-implementation/SKILL.md`
- `.claude/skills/skill-typst-implementation/SKILL.md`
- `.claude/skills/skill-meta/SKILL.md`
- `.claude/skills/skill-git-workflow/SKILL.md`
- `.claude/skills/skill-team-research/SKILL.md`
- `.claude/skills/skill-team-plan/SKILL.md`
- `.claude/skills/skill-team-implement/SKILL.md`
- `.claude/commands/implement.md`
- `.claude/commands/plan.md`
- `.claude/commands/research.md`
- `.claude/commands/revise.md`
- `.claude/commands/errors.md`

**Verification**:
- `grep -r "git add -A" .claude/skills/` returns zero matches
- `grep -r "git add -A" .claude/commands/` returns zero matches (except /todo which is exempt)

---

### Phase 4: Update Agents and Context Patterns [COMPLETED]

**Goal**: Update agent definitions and context pattern documentation

**Tasks**:
- [ ] Update `general-implementation-agent.md` (line 317) with targeted staging
- [ ] Update `latex-implementation-agent.md` (line 343) with targeted staging
- [ ] Update `typst-implementation-agent.md` (line 319) with targeted staging
- [ ] Update `lean-implementation-flow.md` if it contains staging logic
- [ ] Update context patterns: `checkpoint-execution.md`, `postflight-pattern.md`, `file-metadata-exchange.md`
- [ ] Add warning to `/todo` command documentation about exclusive access requirement
- [ ] Run final grep verification across entire `.claude/` directory

**Timing**: 1 hour

**Files to modify**:
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/latex-implementation-agent.md`
- `.claude/agents/typst-implementation-agent.md`
- `.claude/context/core/patterns/checkpoint-execution.md`
- `.claude/context/core/patterns/postflight-pattern.md`
- `.claude/context/core/patterns/file-metadata-exchange.md`
- `.claude/commands/todo.md`

**Verification**:
- `grep -r "git add -A" .claude/` returns only exempt locations (if any)
- `grep -r "git add specs/" .claude/` returns only /todo command
- All agent files use explicit file lists

## Testing & Validation

- [ ] Verify `grep -r "git add -A" .claude/` returns no matches in skill/agent files
- [ ] Verify `grep -r "git add specs/" .claude/` returns only exempt /todo command
- [ ] Verify each skill's postflight section has explicit file staging
- [ ] Verify git-staging-scope.md documents all agent types
- [ ] Manual test: run /research and verify only expected files are staged

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `.claude/context/core/standards/git-staging-scope.md` (new documentation)
- Updated skill files (5 high-priority, 7 remaining)
- Updated command files (5 files)
- Updated agent files (3-4 files)
- Updated context pattern files (3 files)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If targeted staging causes workflow failures:
1. Revert the specific skill/agent file via git
2. Restore `git add -A` temporarily
3. Investigate which files were missed
4. Add missing files to the explicit list
5. Re-apply targeted staging

The staged rollout (Phase 2 first, then Phase 3) allows verification before wide deployment.
