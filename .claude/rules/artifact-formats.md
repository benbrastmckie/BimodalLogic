---
paths: specs/**/*
---

# Artifact Format Rules

## Placeholder Conventions

| Placeholder | Format | Examples |
|-------------|--------|----------|
| `{N}` | Unpadded integer | `389`, `task 389:` |
| `{NNN}` | 3-digit padded | `001`, `research-001.md` |
| `{P}` | Unpadded integer | `1`, `phase 1:` |
| `{DATE}` | YYYYMMDD | `20260111` |
| `{SLUG}` | snake_case | `fix_bug_name` |

## Artifact Locations

- Research: `specs/{N}_{SLUG}/reports/research-{NNN}.md`
- Plans: `specs/{N}_{SLUG}/plans/implementation-{NNN}.md`
- Summaries: `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`

Full templates: @.claude/context/core/reference/artifact-templates.md

## Phase Status Markers

| Marker | When to Use |
|--------|-------------|
| `[NOT STARTED]` | Phase not begun |
| `[IN PROGRESS]` | Currently executing |
| `[COMPLETED]` | Phase finished, verification passed |
| `[PARTIAL]` | Interrupted, can resume |
| `[BLOCKED]` | External dependency blocking |

## Phase Status Decision Tree

1. All steps succeeded + verification passed? -> `[COMPLETED]`
2. Some progress made? -> `[PARTIAL]`
3. External blocker? -> `[BLOCKED]`
4. Otherwise -> `[PARTIAL]`

## Progress Subsection Format

```markdown
**Progress:**

**Session: YYYY-MM-DD, sess_NNNNNN_XXXXXX**
- Added: `lemma_name` - description
- Fixed: `function_name` by adding precondition
- Sorries: 18 -> 14 (4 eliminated)
```

Action verbs: `Added`, `Fixed`, `Completed`, `Removed`, `Refactored`, `Attempted`

## Team Artifacts

Team runs use run number `{RRR}` to correlate teammate outputs:
- Research: `research-{RRR}-teammate-{letter}-findings.md` -> `research-{RRR}.md`
- Plans: `plan-{RRR}-candidate-{letter}.md` -> `implementation-{RRR}.md`

See @.claude/context/core/reference/artifact-templates.md for full team artifact naming.

## Versioning

- Research: Increment (001, 002) - multiple reports supplement each other
- Plans: Increment (001, 002) - new version = revised approach
- Summaries: Date-based - one per completion
