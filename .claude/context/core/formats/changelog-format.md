# Changelog Format Standard

**Purpose**: Document the CHANGE_LOG.md structure for agents and commands

---

## File Location

`specs/CHANGE_LOG.md`

---

## File Structure

```markdown
# ProofChecker Change Log

**Purpose**: Record of completed work with rationale and references...

---

## Changelog

<!-- Schema comment -->

### YYYY-MM-DD

- **Task {N}**: {summary}
  - *Rationale*: {reason}
  - *References*: [summary](path), [plan](path)
```

---

## Entry Schema

### Date Header

Format: `### YYYY-MM-DD`

Date headers are in **reverse chronological order** (newest first).

### Task Entry

Required fields:
- `**Task {N}**`: Task number and summary (one line)

Optional fields (indented under task):
- `*Rationale*`: Why this work was needed
- `*References*`: Links to summary, plan, or other artifacts

### Full Entry Example

```markdown
### 2026-02-26

- **Task 933**: Archived CanonicalReachable/CanonicalQuotient stack to Boneyard. Net ~1135 lines removed from active code.
  - *Rationale*: CanonicalReachable backward_P is blocked because past witnesses are not future-reachable.
  - *References*: [summary](specs/933_research_alternative_canonical_construction/summaries/implementation-summary-20260226.md)
```

### Minimal Entry Example

```markdown
- **Task 913**: Added automatic completion of expanded tasks to /todo command.
  - *References*: [summary](specs/archive/913_todo_expanded_autocompletion/summaries/implementation-summary-20260219.md)
```

---

## Update Process

### Automatic Updates

The `/todo` command automatically adds changelog entries in **Step 5.8** when archiving completed tasks:

1. Groups completed tasks by completion date
2. Creates date header if not present
3. Appends entry after existing date header or creates new section
4. Links to summary artifact if available

### Manual Updates

Entries may be added manually for:
- Major milestones not tied to specific tasks
- Aggregate summaries of related work
- Corrections to automated entries

---

## Relationship to Task System

| File | Purpose | Timeframe |
|------|---------|-----------|
| `specs/TODO.md` | Active task queue | Days-weeks |
| `specs/state.json` | Machine state | Real-time |
| `specs/CHANGE_LOG.md` | Historical record | Permanent |
| `specs/ROAD_MAP.md` | Strategic direction | Months-years |

The changelog captures **what was done** after task completion. It serves as:
- Audit trail of development decisions
- Context for future planning
- Rationale documentation for code archaeology

---

## Content Guidelines

### Summary Text

- Describe what was accomplished, not the process
- Include quantitative impact when relevant (lines removed, files modified)
- Keep to 1-2 sentences

### Rationale

- Explain why the work was pursued
- Document key decisions or tradeoffs
- Reference blocking issues or prerequisites

### References

- Link to implementation summary (preferred)
- Link to plan if no summary exists
- Use relative paths from repository root

---

## Related

- @.claude/commands/todo.md - Command that updates changelog (Step 5.8)
- @.claude/context/core/formats/roadmap-format.md - Strategic counterpart
- @.claude/rules/artifact-formats.md - Task artifact naming conventions
