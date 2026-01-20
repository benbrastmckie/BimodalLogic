# Research Report: Task #643

**Task**: 643 - implement_learn_command_tag_extraction
**Started**: 2026-01-20T19:38:00Z
**Completed**: 2026-01-20T19:55:00Z
**Effort**: Medium (2-4 hours estimated)
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis: `.claude/commands/`, `.claude/skills/`, `.claude/agents/`
- Context file organization: `.claude/context/`
- Existing tag patterns in codebase via Grep
**Artifacts**:
- This report: `specs/643_implement_learn_command_tag_extraction/reports/research-001.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The `/learn` command requires a new command, skill, and agent following established patterns
- Tag extraction can leverage the Grep tool with file-type-specific regex patterns for comment syntax
- Comment syntax varies by file type: Lean (`--`), LaTeX (`%`), Markdown (`<!--`), Python/shell (`#`)
- Context file routing for NOTE: tags should use path heuristics (e.g., LaTeX file -> `project/latex/`)
- Task creation should reuse the existing jq-based patterns from `/task` command
- The implementation follows the thin-wrapper skill pattern with a new `learn-agent`

## Context & Scope

### Task Description

Create a `/learn` command that:
1. Scans files for `FIX:`, `NOTE:`, and `TODO:` tags
2. Creates tasks based on tags found:
   - **fix-it-task**: Groups FIX: and NOTE: tags for small implementation changes
   - **learn-it-task**: Gathers NOTE: tags to update context files
   - **todo-tasks**: Creates individual tasks from TODO: tags

### Research Focus Areas
1. Command, skill, and agent patterns in the codebase
2. Tag extraction patterns across file types
3. Context file organization for learnings
4. Integration with existing task creation workflow

## Findings

### 1. Established Command/Skill/Agent Patterns

**Command Pattern** (from `task.md`, `meta.md`):
```yaml
---
description: {Brief description}
allowed-tools: Skill | Bash, Read, Edit, etc.
argument-hint: {argument patterns}
model: claude-opus-4-5-20251101
---
```

Key characteristics:
- Commands parse `$ARGUMENTS` to determine operation mode
- Commands either delegate to skills or execute directly
- Commands that create tasks use jq patterns for state.json updates

**Skill Pattern** (from `skill-researcher`, `skill-meta`):
```yaml
---
name: skill-{name}
description: {When to invoke}
allowed-tools: Task, Bash, Edit, Read, Write
---
```

Key characteristics:
- Thin wrapper skills delegate to subagents via Task tool
- Skills handle preflight status update, invoke subagent, then do postflight
- Postflight includes status update, artifact linking, git commit

**Agent Pattern** (from `meta-builder-agent`, `general-research-agent`):
```yaml
---
name: {agent-name}
description: {One-line description}
---
```

Key characteristics:
- Agents write metadata to file instead of returning JSON to console
- Agents return brief text summary (3-6 bullets)
- Metadata file: `specs/{N}_{SLUG}/.return-meta.json`

### 2. Comment Syntax by File Type

| File Type | Extension | Comment Prefix | Tag Pattern |
|-----------|-----------|----------------|-------------|
| Lean | `.lean` | `--` | `-- (FIX\|NOTE\|TODO):` |
| LaTeX | `.tex` | `%` | `% (FIX\|NOTE\|TODO):` |
| Markdown | `.md` | `<!--` | `<!-- (FIX\|NOTE\|TODO):` |
| Python | `.py` | `#` | `# (FIX\|NOTE\|TODO):` |
| Shell/Bash | `.sh` | `#` | `# (FIX\|NOTE\|TODO):` |
| YAML/config | `.yaml`, `.yml` | `#` | `# (FIX\|NOTE\|TODO):` |

**Evidence from codebase**:
- Lean: `-- TODO: Implement full Batteries integration` (RunEnvLinters.lean:67)
- LaTeX: `% TODO: there should also be a theory for the H operator` (05-Theorems.tex:168)
- LaTeX: `% FIX: make negation complete a definition` (04-Metalogic.tex:89)
- LaTeX: `% NOTE: I want 'Representation Theorem'...in italics` (04-Metalogic.tex:109)
- Markdown: `<!-- FIX: turn this into a statement...` (research-001.md)

**Regex patterns for Grep tool**:
```regex
# Combined pattern for all file types
(--|%|#|<!--)\s*(FIX|NOTE|TODO):\s*(.*)
```

Or file-type-specific patterns:
- Lean: `^[[:space:]]*--[[:space:]]*(FIX|NOTE|TODO):[[:space:]]*(.*)$`
- LaTeX: `^[[:space:]]*%[[:space:]]*(FIX|NOTE|TODO):[[:space:]]*(.*)$`
- Markdown: `<!--[[:space:]]*(FIX|NOTE|TODO):[[:space:]]*(.*?)[[:space:]]*-->`

### 3. Context File Organization

**Directory structure** (from `context/README.md`):
```
.claude/context/
├── core/           # General/reusable context
│   ├── orchestration/
│   ├── formats/
│   ├── standards/
│   ├── workflows/
│   └── templates/
└── project/        # ProofChecker-specific
    ├── meta/       # Agent/command patterns
    ├── lean4/      # Lean 4 knowledge
    ├── logic/      # Logic domain
    ├── latex/      # LaTeX patterns
    ├── math/       # Math domain
    └── repo/       # Repository-specific
```

**Routing heuristics for NOTE: tags**:
| Source File Type | Target Context Directory |
|------------------|-------------------------|
| `.lean` | `project/lean4/` subdirectory based on content |
| `.tex` | `project/latex/` |
| `.md` in `.claude/` | `core/` or `project/meta/` |
| `.md` in `specs/` | `project/repo/` |
| Other | `project/repo/` (default) |

### 4. Task Creation Infrastructure

**Existing jq patterns** (from `task.md`):
```bash
# Get next task number
next_num=$(jq -r '.next_project_number' specs/state.json)

# Create slug
slug=$(echo "{title}" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd 'a-z0-9_' | cut -c1-50)

# Update state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '.next_project_number = {NEW_NUMBER} |
   .active_projects = [{
     "project_number": {N},
     "project_name": "slug",
     "status": "not_started",
     "language": "meta",
     "priority": "medium",
     "created": $ts,
     "last_updated": $ts
   }] + .active_projects' \
  specs/state.json > /tmp/state.json && \
  mv /tmp/state.json specs/state.json
```

**TODO.md entry format**:
```markdown
### {N}. {Title}
- **Effort**: {estimate}
- **Status**: [NOT STARTED]
- **Priority**: {priority}
- **Language**: {language}

**Description**: {description}
```

### 5. Proposed Architecture

```
/learn [paths] [--dry-run]
    │
    ├── Mode Detection
    │   ├── No args: Scan current directory
    │   ├── paths: Scan specified files/directories
    │   └── --dry-run: Show what would be created without creating
    │
    ├── CHECKPOINT 1: Validate Input
    │   └── Check paths exist
    │
    ├── STAGE 2: Delegate to skill-learn
    │   │
    │   └── skill-learn invokes learn-agent
    │       │
    │       ├── Scan files for tags
    │       │   ├── FIX: tags -> group for fix-it-task
    │       │   ├── NOTE: tags -> group for learn-it-task + contribute to fix-it-task
    │       │   └── TODO: tags -> individual todo-tasks
    │       │
    │       ├── Route NOTE: tags to context directories
    │       │   └── Based on source file type heuristics
    │       │
    │       └── Create tasks conditionally
    │           ├── If FIX: or NOTE: found -> create fix-it-task
    │           ├── If NOTE: found -> create learn-it-task
    │           └── For each TODO: -> create todo-task
    │
    └── CHECKPOINT 2: Commit created tasks
```

### 6. Tag Content Extraction

Tags should capture the full text after the marker:
- `-- TODO: Re-enable when Task 260 unblocked` -> "Re-enable when Task 260 unblocked"
- `% FIX: make negation complete a definition` -> "make negation complete a definition"
- `% NOTE: terms should not be used before they are defined` -> "terms should not be used before they are defined"

**Multi-line tags**: If a tag spans multiple lines (continuation with same comment prefix), concatenate them.

## Decisions

1. **Command Structure**: Use the `/task`-like direct execution pattern rather than checkpoint delegation since task creation is the primary purpose (similar to how `/task` works)

2. **Skill Design**: Create `skill-learn` as a thin wrapper that delegates to `learn-agent`

3. **Agent Design**: Create `learn-agent` that:
   - Uses Grep tool for tag scanning (more reliable than shell grep)
   - Returns metadata via file (consistent with other agents)
   - Creates tasks via jq patterns

4. **Tag Grouping Strategy**:
   - FIX: tags grouped by file for coherent fix-it-task description
   - NOTE: tags grouped by target context directory for learn-it-task
   - TODO: tags remain individual (each is a separate task)

5. **Dry Run Mode**: Essential for user review before creating tasks

## Recommendations

### Priority 1: Core Implementation

1. **Create `/learn` command** (`commands/learn.md`)
   - Parse arguments for paths and --dry-run flag
   - Delegate to skill-learn
   - Display created tasks summary

2. **Create `skill-learn`** (`skills/skill-learn/SKILL.md`)
   - Thin wrapper pattern
   - Handles preflight/postflight for git commit

3. **Create `learn-agent`** (`agents/learn-agent.md`)
   - Tag scanning using Grep with type-specific patterns
   - Task creation using jq patterns
   - Metadata file output

### Priority 2: Tag Processing Logic

4. **Implement tag extraction**
   - Use Grep tool with glob patterns for each file type
   - Parse tag content (text after `TAG:`)
   - Group by tag type and source file

5. **Implement context routing for NOTE: tags**
   - Map source file extensions to target context directories
   - Default to `project/repo/` for unknown types

### Priority 3: Task Generation

6. **Fix-it-task generation**
   - Combine FIX: and NOTE: tags into single task description
   - Include file paths and line references
   - Set language based on predominant file type

7. **Learn-it-task generation**
   - Group NOTE: tags by target context directory
   - Create description referencing which context files to update
   - Set language to "meta"

8. **Todo-tasks generation**
   - One task per TODO: tag
   - Preserve original text as task description
   - Detect language from source file type

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Tag parsing misses edge cases | Medium | Start with simple patterns, iterate based on real-world usage |
| Context routing is inaccurate | Low | Use conservative defaults, allow manual correction |
| Too many tasks created at once | Medium | Require --dry-run review, add confirmation for >10 tasks |
| Duplicate tasks created | Medium | Check existing task descriptions for similar content |
| Multi-line tags not handled | Low | Document single-line limitation initially, add multi-line support later |

## Appendix

### Search Queries Used

1. `Grep: (FIX|NOTE|TODO):` - Found tags across codebase
2. `Glob: .claude/commands/**/*.md` - Inventoried commands
3. `Glob: .claude/skills/**/*.md` - Inventoried skills
4. `Glob: .claude/agents/**/*.md` - Inventoried agents
5. `Read: .claude/context/README.md` - Context organization

### Component Inventory

**Commands**: 11 total
- errors, meta, convert, research, plan, revise, task, review, refresh, implement, todo

**Skills**: 12 total
- skill-git-workflow, skill-document-converter, skill-meta, skill-orchestrator, skill-researcher, skill-lean-research, skill-lean-implementation, skill-planner, skill-status-sync, skill-implementer, skill-latex-implementation, skill-refresh

**Agents**: 8 total
- document-converter-agent, lean-research-agent, general-research-agent, planner-agent, lean-implementation-agent, meta-builder-agent, latex-implementation-agent, general-implementation-agent

### References

- Command template: `.claude/context/core/templates/command-template.md`
- Thin wrapper skill pattern: `.claude/context/core/templates/thin-wrapper-skill.md`
- Agent template: `.claude/context/core/templates/agent-template.md`
- Return metadata file schema: `.claude/context/core/formats/return-metadata-file.md`
- Context organization: `.claude/context/README.md`
- Task command patterns: `.claude/commands/task.md`
