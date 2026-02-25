---
paths: specs/**/*
---

# Git Workflow Rules

## Commit Format

```
task {N}: {action} {description}

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Standard Actions

| Operation | Commit Message |
|-----------|----------------|
| Create task | `task {N}: create {title}` |
| Complete research | `task {N}: complete research` |
| Create plan | `task {N}: create implementation plan` |
| Complete phase | `task {N} phase {P}: {phase_name}` |
| Complete implementation | `task {N}: complete implementation` |
| Revise plan | `task {N}: revise plan (v{V})` |
| Archive tasks | `todo: archive {N} completed tasks` |

## Session ID

Format: `sess_{unix_timestamp}_{6_char_random}`

Generate: `session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"`

Lifecycle: Generated at GATE IN, passed through delegation, included in commits.

## Commit Timing

**Create commits after**: Task creation, research completion, plan creation, each phase, final implementation, archival.

**Do not commit**: Partial/incomplete work, failed operations, intermediate states.

## Git Safety

**Never run**: `git push --force` to main, `git reset --hard` without request, `git rebase -i`

**Always check**: `git status`, `git diff --staged`, no sensitive files staged

## Error Handling

On commit failure: Log, do not block, preserve changes, report to user.
On pre-commit hook failure: Fix issue, create new commit (never amend).
