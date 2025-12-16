# Project Structure Guide

## Overview
Organization of .opencode/specs/ directory for project-based artifact management.

## Directory Structure

```
.opencode/specs/
├── TODO.md                          # User-facing master task list
├── state.json                       # Global state file
├── 001_project_name/
│   ├── reports/
│   │   ├── research-001.md
│   │   ├── research-002.md
│   │   ├── analysis-001.md
│   │   └── verification-001.md
│   ├── plans/
│   │   ├── implementation-001.md
│   │   ├── implementation-002.md   # Revised plan
│   │   └── implementation-003.md   # Further revision
│   ├── summaries/
│   │   ├── project-summary.md
│   │   ├── research-summary.md
│   │   └── implementation-summary.md
│   └── state.json                   # Project-specific state
├── 002_another_project/
│   ├── reports/
│   ├── plans/
│   ├── summaries/
│   └── state.json
└── ...
```

## Project Numbering

### Format
- **NNN_project_name** where NNN is zero-padded 3-digit number
- Examples: 001_bimodal_proof_system, 002_semantics_layer, 003_metalogic

### Numbering Rules
1. Start at 001
2. Increment sequentially
3. Never reuse numbers
4. Zero-pad to 3 digits

## Subdirectories

### reports/
Contains all research and analysis reports:
- **research-NNN.md**: Research findings from researcher agent
- **analysis-NNN.md**: Repository analysis from reviewer agent
- **verification-NNN.md**: Verification reports from reviewer agent
- **refactoring-NNN.md**: Refactoring reports from refactorer agent

### plans/
Contains implementation plans with version control:
- **implementation-001.md**: Initial plan
- **implementation-002.md**: First revision
- **implementation-NNN.md**: Subsequent revisions

Version increments when:
- Plan needs significant changes
- User runs /revise command
- Implementation approach changes

### summaries/
Contains brief summaries for quick reference:
- **project-summary.md**: Overall project summary
- **research-summary.md**: Key research findings
- **plan-summary.md**: Implementation plan overview
- **implementation-summary.md**: What was implemented

## State Files

### Project State (.opencode/specs/NNN_project/state.json)
```json
{
  "project_name": "bimodal_proof_system",
  "project_number": 1,
  "type": "implementation",
  "phase": "planning",
  "reports": [
    "reports/research-001.md",
    "reports/research-002.md"
  ],
  "plans": [
    "plans/implementation-001.md",
    "plans/implementation-002.md"
  ],
  "summaries": [
    "summaries/project-summary.md"
  ],
  "status": "active",
  "created": "2025-01-15T10:00:00Z",
  "last_updated": "2025-01-16T14:30:00Z"
}
```

### Global State (.opencode/specs/state.json)
```json
{
  "active_projects": [1, 2, 5],
  "completed_projects": [3, 4],
  "next_project_number": 6,
  "recent_activities": [
    {
      "type": "research",
      "project_number": 5,
      "timestamp": "2025-01-16T14:30:00Z",
      "summary": "Researched Kripke semantics for bimodal logic"
    }
  ],
  "pending_tasks": [
    {
      "description": "Implement soundness proof",
      "project_number": 1,
      "priority": "high"
    }
  ]
}
```

## TODO.md Format

```markdown
# TODO - LEAN 4 ProofChecker

## High Priority

- [ ] Implement soundness proof for bimodal logic [Project #001](001_bimodal_proof_system/plans/implementation-002.md)
- [ ] Complete Kripke model definition [Project #002](002_semantics_layer/plans/implementation-001.md)

## Medium Priority

- [ ] Refactor proof system axioms for readability [Project #001](001_bimodal_proof_system/reports/verification-001.md)
- [ ] Add documentation for modal operators

## Low Priority

- [ ] Explore alternative proof strategies
- [ ] Research decidability procedures

## Completed

- [x] Research bimodal logic foundations [Project #001](001_bimodal_proof_system/reports/research-001.md)
- [x] Create initial implementation plan [Project #001](001_bimodal_proof_system/plans/implementation-001.md)
```

## Artifact Naming Conventions

### Reports
- **research-NNN.md**: Incremental numbering within project
- **analysis-NNN.md**: Incremental numbering within project
- **verification-NNN.md**: Incremental numbering within project

### Plans
- **implementation-NNN.md**: Version number (increments with revisions)

### Summaries
- **{type}-summary.md**: One per type (project, research, plan, implementation)

## Best Practices

1. **Always create project directory first** before generating artifacts
2. **Use descriptive project names** that reflect the task
3. **Increment versions properly** when revising plans
4. **Keep summaries brief** (1-2 pages max)
5. **Link TODO items** to relevant reports/plans
6. **Update state files** after every operation
7. **Sync TODO.md** with project progress

## Context Protection

All agents create artifacts in these directories and return only:
- File path (reference)
- Brief summary (3-5 sentences)
- Key findings (bullet points)

This protects the orchestrator's context window from artifact content bloat.
