---
paths: specs/**/*
---

# State Management Rules

## File Synchronization

TODO.md and state.json MUST stay synchronized. state.json is machine truth; TODO.md is user-facing.

## Status Transitions

```
[NOT STARTED] -> [RESEARCHING] -> [RESEARCHED]
[RESEARCHED] -> [PLANNING] -> [PLANNED]
[PLANNED] -> [IMPLEMENTING] -> [COMPLETED]
Any -> [BLOCKED] | [ABANDONED] | [PARTIAL] | [EXPANDED]
```

Invalid: Cannot skip phases or regress (except for revisions).

## Two-Phase Update Pattern

1. **Prepare**: Read both files, validate, prepare updates
2. **Commit**: Write state.json first, then TODO.md, verify both

## Status Values Mapping

| TODO.md | state.json |
|---------|-----------|
| [NOT STARTED] | not_started |
| [RESEARCHING] | researching |
| [RESEARCHED] | researched |
| [PLANNING] | planning |
| [PLANNED] | planned |
| [IMPLEMENTING] | implementing |
| [COMPLETED] | completed |
| [BLOCKED/ABANDONED/PARTIAL/EXPANDED] | blocked/abandoned/partial/expanded |

## Artifact Linking

Update TODO.md when creating artifacts:
- Research: `- **Research**: [specs/{N}_{SLUG}/reports/research-001.md]`
- Plan: `- **Plan**: [specs/{N}_{SLUG}/plans/implementation-001.md]`
- Summary: `- **Summary**: [specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md]`

## Lazy Directory Creation

Create directories only when writing first artifact:
```bash
mkdir -p "specs/${task_num}_${slug}/reports"
```

Do NOT create empty directories at task creation.

## Error Handling

- On write failure: Preserve original state, log error
- On inconsistency: Use git blame for latest, sync, log resolution

Full schema: @.claude/context/core/reference/state-json-schema.md
