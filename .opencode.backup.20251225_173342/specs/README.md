# Specifications - Task Work Products

**Purpose**: Task specifications, plans, reports, and work products  
**Last Updated**: December 20, 2025

## Overview

The specs directory contains all task-related work products organized by
project. Each task receives a numbered directory containing research reports,
implementation plans, summaries, and state tracking. This organization
provides a complete audit trail of all work performed by the AI system.

The directory follows a standardized structure that enables efficient artifact
discovery, version tracking, and state management. All agents create artifacts
here following consistent naming conventions and organizational patterns.

## Directory Structure

Each task gets a directory named `NNN_task_name/` containing:

```
NNN_task_name/
├── reports/
│   ├── research-001.md
│   ├── analysis-001.md
│   └── verification-001.md
├── plans/
│   ├── implementation-001.md
│   └── implementation-002.md
├── summaries/
│   ├── project-summary.md
│   └── research-summary.md
└── state.json
```

**Subdirectories**:
- `reports/` - Research and analysis reports from specialist subagents
- `plans/` - Implementation plans (versioned, incremented on revision)
- `summaries/` - Brief summaries for quick reference (1-2 pages max)
- `state.json` - Project-specific state tracking

## Special Files and Directories

### TODO.md

Master task list tracking all identified work. Tasks are organized by priority
and status, with links to project directories.

**Format**:
```markdown
## High Priority

- [ ] Task #63: Implement soundness proof → 063_soundness_proof/
- [x] Task #62: Refactor proof system → 062_refactor_proof_system/

## Medium Priority

- [ ] Task #64: Add documentation → 064_add_documentation/
```

**Status Markers**:
- `[ ]` - Not started
- `[x]` - Completed
- `[~]` - In progress
- `[!]` - Blocked

### state.json

Global state file tracking all projects and system state.

**Schema**:
```json
{
  "projects": {
    "066_opencode_readme_documentation": {
      "status": "in_progress",
      "created": "2025-12-20T10:00:00Z",
      "updated": "2025-12-20T14:30:00Z"
    }
  },
  "next_project_number": 67
}
```

See [state-schema.md](../context/repo/state-schema.md) for complete schema
reference.

### archive/

Completed and archived tasks. Tasks are moved here after completion and
verification to keep the main specs/ directory focused on active work.

**Archive Structure**:
```
archive/
├── 001_initial_setup/
├── 002_lean_test_moderate/
└── 003_lean_test_complex/
```

### maintenance/

Maintenance reports and operations tracking. Contains periodic repository
reviews, cleanup operations, and system maintenance artifacts.

**Maintenance Structure**:
```
maintenance/
├── review-2025-12-20.md
├── cleanup-2025-12-15.md
└── migration-2025-12-10.md
```

## Task Lifecycle

Tasks progress through defined states from creation to archival:

**States**:
1. **Planned**: Task identified and added to TODO.md
2. **Researched**: Research report created in `reports/`
3. **Planned**: Implementation plan created in `plans/`
4. **In Progress**: Implementation underway, tracked in state.json
5. **Completed**: Implementation finished and verified
6. **Archived**: Task moved to `archive/` after completion

**State Transitions**:
- Planned → Researched: `/research` command creates research report
- Researched → Planned: `/plan` command creates implementation plan
- Planned → In Progress: `/lean` or `/implement` command starts implementation
- In Progress → Completed: Implementation verified and committed
- Completed → Archived: Manual archival after verification period

## Project Numbering

Projects use a sequential numbering scheme for organization and tracking.

**Format**: `NNN_descriptive_task_name`

**Rules**:
- NNN: Zero-padded 3-digit sequential number (001, 002, ..., 066, ...)
- Start at 001, increment sequentially
- Never reuse numbers (even for archived tasks)
- Use descriptive, lowercase names with underscores
- Keep names concise but clear (3-5 words)

**Examples**:
- `066_opencode_readme_documentation`
- `063_soundness_proof`
- `072_phase1_migration`

**Next Number**: Check `state.json` for `next_project_number`.

## Artifact Naming Conventions

Consistent naming within project directories enables automated processing and
discovery.

**Reports**: `{type}-{NNN}.md`
- `research-001.md` - First research report
- `analysis-001.md` - First analysis report
- `verification-001.md` - First verification report
- Increment NNN for multiple reports of same type

**Plans**: `implementation-{NNN}.md`
- `implementation-001.md` - Initial implementation plan
- `implementation-002.md` - First revision
- `implementation-003.md` - Second revision
- Increment on each `/revise` command

**Summaries**: `{type}-summary.md`
- `project-summary.md` - Overall project summary
- `research-summary.md` - Research findings summary
- `implementation-summary.md` - Implementation summary
- One summary per type (updated in place)

**State**: `state.json`
- Project-specific state tracking
- Updated atomically by agents
- Schema defined in state-schema.md

## Archive Policy

Tasks are archived after completion to maintain focus on active work.

**Archive Criteria**:
- Task completed and verified
- No active dependencies from other tasks
- Documentation updated to reflect changes
- All artifacts preserved in project directory
- Minimum 7 days since completion (cooling-off period)

**Archive Process**:
1. Verify task completion and dependencies
2. Update TODO.md to mark task as archived
3. Move project directory from `specs/` to `specs/archive/`
4. Update state.json to reflect archival
5. Preserve all artifacts (no deletion)

**Archive Retention**:
- Archived tasks retained indefinitely
- Provide historical record and reference
- Can be restored if needed

## Related Documentation

All context files are located in `.opencode/context/`:

- [Project Structure](../context/repo/project-structure.md) - Detailed organization guide
- [State Schema](../context/repo/state-schema.md) - State file format reference
- [Documentation Standards](../context/repo/documentation-standards.md) - Artifact quality standards
- [Task Command](../command/task.md) - Task execution workflow
- [Plan Command](../command/plan.md) - Planning workflow
- [Context Guide](../context/README.md) - Context organization and usage
