# Context Index

Path: `.opencode/context/core/{category}/{file}`

## Quick Map
```
code        → standards/code.md       [critical] implement, refactor, architecture
docs        → standards/docs.md       [critical] write docs, README, documentation
tests       → standards/tests.md      [critical] write tests, testing, TDD → deps: code
patterns    → standards/patterns.md   [high]     error handling, security, validation
analysis    → standards/analysis.md   [high]     analyze, investigate, debug

delegation  → workflows/delegation.md [high]     delegate, task tool, subagent
review      → workflows/review.md     [high]     review code, audit → deps: code, patterns
breakdown   → workflows/task-breakdown.md [high] break down, 4+ files → deps: delegation
sessions    → workflows/sessions.md   [medium]   session management, cleanup
```

## Loading Instructions

**For common tasks, use quick map above. For keyword matching, scan triggers.**

**Format:** `id → path [priority] triggers → deps: dependencies`

**Dependencies:** Load dependent contexts alongside main context for complete guidelines.

## Categories

**Standards** - Code quality, testing, documentation standards (critical priority)
**Workflows** - Process templates for delegation, review, task breakdown (high priority)
**System** - Documentation and guides (medium priority)
