# Research Report: Task #874

**Task**: 874 - document_team_flag_command_files
**Started**: 2026-02-11T09:00:00Z
**Completed**: 2026-02-11T09:15:00Z
**Effort**: 0.5 hours
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (command files, skill files, CLAUDE.md)
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Three command files need --team and --team-size documentation: research.md, plan.md, implement.md
- The skill-orchestrator already fully documents team mode routing (sections 2a, 2b)
- Established pattern exists: use "Options" table format (from lake.md) for flag documentation
- Changes are straightforward: add Arguments section entries and optional Options table

## Context & Scope

The --team and --team-size flags enable multi-agent parallel execution for /research, /plan, and /implement commands. While the orchestrator skill correctly handles these flags, the command files do not document them, making the feature undiscoverable to users.

### Files Examined

| File | Current State | Needs Update |
|------|---------------|--------------|
| `.claude/commands/research.md` | No --team documentation | Yes |
| `.claude/commands/plan.md` | No --team documentation | Yes |
| `.claude/commands/implement.md` | Has --force flag, no --team | Yes |
| `.claude/skills/skill-orchestrator/SKILL.md` | Full documentation (sections 2a, 2b) | No |
| `.claude/skills/skill-team-research/SKILL.md` | Full documentation | No |
| `.claude/skills/skill-team-plan/SKILL.md` | Reference only | No |
| `.claude/skills/skill-team-implement/SKILL.md` | Reference only | No |

## Findings

### Current Documentation Patterns

#### Argument Hint Pattern (YAML frontmatter)

The `argument-hint` field in YAML frontmatter provides quick usage reference:

```yaml
# From implement.md
argument-hint: TASK_NUMBER

# From lake.md (with multiple options)
argument-hint: [--clean] [--max-retries N] [--dry-run] [--module NAME]

# From task.md (complex)
argument-hint: "description" | --recover N | --expand N | --sync | --abandon N | --review N
```

#### Arguments Section Pattern

Commands document arguments in `## Arguments` section with bullet lists:

```markdown
## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction
```

#### Options Table Pattern (for flags)

Commands with multiple flags use table format (from lake.md):

```markdown
## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--clean` | Run `lake clean` before building | false |
| `--max-retries N` | Maximum auto-fix iterations | 3 |
```

### Team Mode Implementation Details

From skill-orchestrator/SKILL.md:

1. **Flag Parsing** (Section 2a):
   ```bash
   team_mode=false
   team_size=2  # default

   if [[ "$args" == *"--team"* ]]; then
     team_mode=true
     if [[ "$args" =~ --team-size[[:space:]]+([0-9]+) ]]; then
       team_size="${BASH_REMATCH[1]}"
     fi
   fi
   ```

2. **Routing Logic** (Section 2b):
   - `--team` present: Route to skill-team-{research|plan|implement}
   - No flag: Use standard language-based routing

3. **Team Size Range**: 2-4 (clamped by team skills)

### CLAUDE.md Reference

CLAUDE.md already documents team mode in the Command Reference:

```markdown
| `/research` | `/research N [focus] [--team [--team-size N]]` | Research task, route by language |
| `/plan` | `/plan N [--team [--team-size N]]` | Create implementation plan |
| `/implement` | `/implement N [--team [--team-size N]]` | Execute plan, resume from incomplete phase |
```

The command files need to be updated to match this documentation.

## Recommendations

### Required Changes per File

#### 1. `.claude/commands/research.md`

**Update argument-hint** (line 4):
```yaml
argument-hint: TASK_NUMBER [FOCUS] [--team [--team-size N]]
```

**Update Arguments section** (after line 15):
```markdown
## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--team` | Enable multi-agent parallel research | false |
| `--team-size N` | Number of teammates (2-4) | 2 |

When `--team` is specified, routes to `skill-team-research` which spawns parallel teammates for diverse investigation angles.
```

#### 2. `.claude/commands/plan.md`

**Update argument-hint** (line 4):
```yaml
argument-hint: TASK_NUMBER [--team [--team-size N]]
```

**Update Arguments section** (after line 14):
```markdown
## Arguments

- `$1` - Task number (required)

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--team` | Enable multi-agent parallel planning | false |
| `--team-size N` | Number of teammates (2-4) | 2 |

When `--team` is specified, routes to `skill-team-plan` which spawns parallel teammates for diverse planning approaches.
```

#### 3. `.claude/commands/implement.md`

**Update argument-hint** (line 4):
```yaml
argument-hint: TASK_NUMBER [--team [--team-size N]] [--force]
```

**Update Arguments section** (lines 14-16):
```markdown
## Arguments

- `$1` - Task number (required)

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--team` | Enable multi-agent parallel implementation | false |
| `--team-size N` | Number of teammates (2-4) | 2 |
| `--force` | Override status validation | false |

When `--team` is specified, routes to `skill-team-implement` which spawns parallel teammates for concurrent phase execution.
```

### Implementation Notes

1. **Consistency**: All three commands should follow the same pattern for Options table placement (after Arguments, before Execution)

2. **Default Values**: Document default team_size as 2 (from skill-orchestrator line 67)

3. **Range Validation**: Note that team_size is clamped to 2-4 by the team skills

4. **Language Routing**: Team skills handle all languages and apply wave-based parallelization

## Decisions

1. **Use Options table format**: Consistent with lake.md pattern for flag documentation
2. **Add brief explanation line**: Explain what happens when --team is used
3. **Keep existing optional flags**: implement.md's --force flag should remain, just reorganized

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Inconsistent documentation style | Follow established Options table pattern from lake.md |
| Missing details | Reference skill files for authoritative behavior |
| Documentation drift | Link to skill-team-* for detailed behavior |

## Appendix

### Search Queries Used

1. `Glob(".claude/commands/**/*.md")` - Found all command files
2. `Read` on research.md, plan.md, implement.md - Current state
3. `Read` on skill-orchestrator/SKILL.md - Team routing implementation
4. `Read` on skill-team-research/SKILL.md - Team execution details
5. `Read` on lake.md - Options table format pattern
6. `Read` on task.md - Complex argument-hint pattern

### References

- `.claude/skills/skill-orchestrator/SKILL.md` - Authoritative team mode routing
- `.claude/skills/skill-team-research/SKILL.md` - Research team skill details
- `.claude/commands/lake.md` - Options table documentation pattern
- `.claude/CLAUDE.md` - Command Reference table (lines 73-75)
