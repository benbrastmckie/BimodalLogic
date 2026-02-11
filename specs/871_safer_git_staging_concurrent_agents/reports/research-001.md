# Research Report: Task #871

**Task**: 871 - safer_git_staging_concurrent_agents
**Started**: 2026-02-11T12:00:00Z
**Completed**: 2026-02-11T12:45:00Z
**Effort**: 45 minutes
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, git-safety.md, skill files, web research
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The root cause is that 40+ locations in the codebase use `git add -A` or `git add specs/` which stage ALL modified files regardless of agent scope
- Existing documentation (git-safety.md) already recommends targeted staging but this is not enforced or consistently applied
- The solution is a staged rollout: (1) define allowed file scopes per agent type, (2) create a validation function, (3) update skills/agents to use targeted staging
- File locking is unnecessary; targeted staging is sufficient for most cases
- The /todo command is a special case requiring exclusive access to specs/

## Context & Scope

### Problem Statement

Background agents running concurrent operations use broad git staging patterns (`git add -A`, `git add specs/`) that capture all modified files in the working directory, not just the files they created or modified. When multiple agents run concurrently:

1. Agent A modifies TODO.md (or other shared files)
2. Agent B stages ALL files with `git add -A` (including A's uncommitted changes)
3. Agent B commits, potentially with incomplete/intermediate state from Agent A
4. Agent A's subsequent commit may overwrite Agent B's changes

**Demonstrated Failure**: Task 865 research agent wiped TODO.md to empty while task 869 archival was completing.

### Scope of Research

1. Identify all locations using broad git staging patterns
2. Analyze which files each agent type should be allowed to stage
3. Evaluate file locking vs targeted staging approaches
4. Design a solution that maintains simplicity while preventing race conditions

## Findings

### Codebase Patterns Discovered

#### Locations Using `git add -A`

Found 40+ instances of `git add -A` across the codebase:

| Category | Files | Count |
|----------|-------|-------|
| Skills | skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-typst-implementation, skill-team-* | 12 |
| Agents | general-implementation-agent, latex-implementation-agent, typst-implementation-agent, lean-implementation-flow | 4 |
| Commands | implement.md, plan.md, research.md, errors.md, revise.md | 6 |
| Context patterns | checkpoint-execution.md, postflight-pattern.md, file-metadata-exchange.md, workflow-interruptions.md | 4 |

#### Locations Using `git add specs/`

Found in:
- skill-git-workflow/SKILL.md (line 178)
- meta-builder-agent.md (line 562)
- todo.md command (lines 1075)
- task.md command (lines 160, 470)

#### Existing Guidance (Not Followed)

`.claude/context/core/standards/git-safety.md` already contains excellent guidance:

```markdown
### Scoping Best Practices
- Stage only files relevant to the current task/feature
- **Avoid repo-wide adds**: Do not use `git add -A` or `git commit -am`
- Use targeted staging: `git add <file1> <file2>`
- Split unrelated changes into separate commits
```

This guidance is documented but not enforced or consistently applied.

### Agent File Scope Analysis

| Agent Type | Primary Files Modified | Shared Files Touched |
|------------|------------------------|---------------------|
| Research Agents | `specs/{N}_{SLUG}/reports/research-*.md` | `specs/TODO.md`, `specs/state.json` |
| Plan Agents | `specs/{N}_{SLUG}/plans/implementation-*.md` | `specs/TODO.md`, `specs/state.json` |
| Implementation Agents | Task-specific files (Theories/, docs/, etc.) | `specs/TODO.md`, `specs/state.json`, plan files |
| Meta Builder | `.claude/**`, `specs/TODO.md`, `specs/state.json` | Multiple task directories |
| /todo Command | `specs/TODO.md`, `specs/state.json`, `specs/archive/**`, `specs/ROAD_MAP.md` | ALL of specs/ |

### Conflict Categories

**Low Risk** (agent-isolated files):
- Research reports: `specs/{N}_{SLUG}/reports/*.md`
- Plan files: `specs/{N}_{SLUG}/plans/*.md`
- Summary files: `specs/{N}_{SLUG}/summaries/*.md`

**High Risk** (shared files):
- `specs/TODO.md` - Modified by ALL operations
- `specs/state.json` - Modified by ALL operations
- `specs/ROAD_MAP.md` - Modified by /todo only

### External Resources

From web research on concurrent git operations:

1. **Git Parallel Checkout** - Git's internal parallelism avoids race conditions by having the main process handle file removal, but this doesn't apply to staging operations
2. **File Locking with flock** - The `flock` command provides atomic file locking in bash, useful for coordinating access to shared files

References:
- [Linux Lock Files - dmorgan.info](https://dmorgan.info/posts/linux-lock-files/)
- [BashFAQ/045 - Greg's Wiki](https://mywiki.wooledge.org/BashFAQ/045)
- [File Locking in Linux - Baeldung](https://www.baeldung.com/linux/file-locking)

### Recommendations

#### Solution Architecture: Targeted Staging

Instead of file locking (complex, risk of deadlocks), use **targeted staging** with validation:

**Approach 1: Explicit File Lists (Recommended)**

Each agent explicitly lists files it modified:

```bash
# Instead of: git add -A
# Use: git add ${modified_files[@]}

# Example for research agent:
modified_files=(
  "specs/${task_number}_${project_name}/reports/research-${report_number}.md"
  "specs/${task_number}_${project_name}/.return-meta.json"
)
git add "${modified_files[@]}"
```

**Approach 2: Scoped Directory Add with Exclusion**

Use git add with pathspec to exclude shared files:

```bash
# Stage task directory only, explicitly exclude shared files
git add "specs/${task_number}_${project_name}/" \
  --exclude="specs/TODO.md" \
  --exclude="specs/state.json"
```

Note: `--exclude` is not a standard git option. Use pathspec negation instead:

```bash
git add "specs/${task_number}_${project_name}/"
# Shared files are staged by skill postflight separately
```

**Approach 3: Validation Before Commit**

Add a pre-commit validation that checks staged files against allowed scope:

```bash
validate_staging_scope() {
  local task_number=$1
  local allowed_patterns=(
    "specs/${task_number}_*/reports/*"
    "specs/${task_number}_*/plans/*"
    "specs/${task_number}_*/summaries/*"
  )

  staged_files=$(git diff --cached --name-only)

  for file in $staged_files; do
    match=false
    for pattern in "${allowed_patterns[@]}"; do
      if [[ "$file" == $pattern ]]; then
        match=true
        break
      fi
    done
    if [ "$match" = false ]; then
      echo "ERROR: File outside allowed scope: $file"
      return 1
    fi
  done
}
```

#### Handling Shared Files (TODO.md, state.json)

**Option A: Separate Commit Phase**

1. Agents stage ONLY their task-specific files
2. Skill postflight stages shared files (TODO.md, state.json) separately
3. Single atomic commit with both

```bash
# Agent: stage task-specific files
git add "specs/${task_number}_${project_name}/"

# Skill postflight: stage shared files after status update
git add "specs/TODO.md" "specs/state.json"

# Commit together
git commit -m "task ${task_number}: complete research"
```

**Option B: File Locking for Shared Files**

Use flock for atomic access to shared files:

```bash
(
  flock -x 200
  # Critical section: update and stage shared files
  jq '...' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
  # Edit TODO.md
  git add specs/TODO.md specs/state.json
) 200>/tmp/specs-shared-files.lock
```

This is more complex but provides stronger guarantees.

#### Special Case: /todo Command

The /todo command legitimately needs to stage all of `specs/` because it:
- Archives task directories
- Updates TODO.md
- Updates state.json
- Updates ROAD_MAP.md
- Updates archive/state.json

**Recommendation**: /todo should:
1. Run with exclusive access (not concurrently with other agents)
2. Use `git add specs/` as currently implemented
3. Document that /todo should not run while background agents are active

Alternatively, implement a coordination mechanism:
```bash
# Before /todo starts
echo "todo" > /tmp/exclusive-specs-lock
trap "rm /tmp/exclusive-specs-lock" EXIT

# Agents check this before starting
if [ -f /tmp/exclusive-specs-lock ]; then
  echo "ERROR: /todo command running, cannot start agent"
  exit 1
fi
```

## Decisions

1. **Targeted staging over file locking**: Simpler, no deadlock risk, easier to debug
2. **Explicit file lists over patterns**: Clearer, self-documenting, easier to audit
3. **Shared files staged by skill postflight**: Centralizes coordination in skills where status updates occur
4. **/todo remains special case**: Document that it requires exclusive access to specs/

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agents forget to list all modified files | Uncommitted changes accumulate | Validation function warns about unstaged changes in task directory |
| Breaking existing workflows | Widespread failures | Staged rollout: update skills first, then agents, then commands |
| /todo still has race conditions | Data loss | Document exclusive access requirement; consider advisory lock |
| Complexity of implementation | Engineering time | Start with highest-risk skills (research, implementation) |

## Implementation Approach

### Phase 1: Create Validation Function (1-2 hours)

Create `.claude/scripts/validate-git-scope.sh`:
```bash
#!/bin/bash
# Validates staged files are within allowed scope for task

validate_git_staging_scope() {
  local task_number=$1
  local agent_type=$2  # research, plan, implement, meta, todo

  case "$agent_type" in
    research|plan)
      allowed="specs/${task_number}_*/(reports|plans|summaries)/*"
      ;;
    implement)
      allowed="specs/${task_number}_*/* Theories/**"
      ;;
    meta)
      allowed=".claude/** specs/**"
      ;;
    todo)
      allowed="specs/**"
      ;;
  esac

  # Validate staged files match allowed pattern
  ...
}
```

### Phase 2: Update Skills (4-6 hours)

Update git staging in these skills (highest priority):
1. skill-researcher/SKILL.md (line 232)
2. skill-lean-research/SKILL.md (line 230)
3. skill-implementer/SKILL.md (line 333)
4. skill-lean-implementation/SKILL.md (line 303)

Pattern to apply:
```markdown
### Stage 9: Git Commit

Commit changes with session ID:

```bash
# Stage task-specific files only
git add "specs/${task_number}_${project_name}/reports/"
git add "specs/${task_number}_${project_name}/.return-meta.json"

# Stage shared files (updated by postflight)
git add "specs/TODO.md" "specs/state.json"

# Commit with scoped message
git commit -m "task ${task_number}: complete research

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```
```

### Phase 3: Update Agents (2-4 hours)

Update implementation agents:
1. general-implementation-agent.md (line 317)
2. latex-implementation-agent.md (line 343)
3. typst-implementation-agent.md (line 319)

### Phase 4: Document and Test (2-3 hours)

1. Update git-safety.md with explicit enforcement guidance
2. Add "Concurrent Agent Safety" section to README.md
3. Create test scenario for concurrent agents

## Appendix

### Search Queries Used

1. `git add` across .claude directory - found 40+ instances
2. `git add -A` - found all broad staging uses
3. `concurrent|race|lock` - found existing documentation
4. Web search for git concurrent staging patterns
5. Web search for bash flock file locking

### References to Documentation

- `.claude/context/core/standards/git-safety.md` - Existing best practices (not enforced)
- `.claude/rules/git-workflow.md` - Commit conventions
- `.claude/skills/skill-git-workflow/SKILL.md` - Git workflow skill (uses `git add {scope}`)
- `.claude/context/core/standards/git-integration.md` - Integration standards (mentions scope_files)
- `.claude/context/core/workflows/preflight-postflight.md` - Status update flow

### Files to Modify (Implementation)

Priority order:
1. `.claude/skills/skill-researcher/SKILL.md` (line 232)
2. `.claude/skills/skill-lean-research/SKILL.md` (line 230)
3. `.claude/skills/skill-implementer/SKILL.md` (line 333)
4. `.claude/skills/skill-lean-implementation/SKILL.md` (line 303)
5. `.claude/agents/general-implementation-agent.md` (line 317)
6. `.claude/agents/latex-implementation-agent.md` (line 343)
7. `.claude/agents/typst-implementation-agent.md` (line 319)
8. `.claude/commands/implement.md` (lines 129, 142)
9. `.claude/commands/plan.md` (line 80)
10. `.claude/commands/research.md` (line 84)
