# Roadmap Update Pattern

**Purpose**: Document roadmap update process during /review and /todo

---

## Update Triggers

Roadmap updates occur in two places:
- `/review` at Step 2.5 (Roadmap Integration) - for review reports
- `/todo` during archival - for completion annotations

---

## Completion Detection

### Data Sources

| Source | Query |
|--------|-------|
| state.json | Filter `status == "completed"`, extract `roadmap_items` |
| ROAD_MAP.md | Scan for `(Task {N})` references |

### Matching Strategy (Two-Tier Only)

**Priority 1 - Explicit roadmap_items** (High Confidence):
- Tasks populate `roadmap_items` array during implementation
- Array contains exact text of ROAD_MAP.md checkbox items
- Matched via exact string comparison

**Priority 2 - Exact Task References** (High Confidence):
- ROAD_MAP.md contains `(Task N)` annotation
- Matched via regex pattern `\(Task {N}\)`

**Important**: No fuzzy title matching is performed. This is intentional:
- Fuzzy matching produced unreliable results
- Explicit items ensure precision over recall
- Not all completed tasks update the roadmap - this is intentional design

**Design Philosophy**: Precision takes priority over recall. Tasks without explicit
`roadmap_items` or existing `(Task N)` references are silently ignored rather than
generating warnings. This avoids false positives since many internal tasks (meta,
refactoring, tooling) do not correspond to roadmap deliverables.

---

## Annotation Process

Convert `- [ ] {item}` to `- [x] {item} *(Completed: Task {N}, {DATE})*`

**Safety Rules**:
- Never remove content
- Skip already-annotated items (contain `*(Completed:`)
- One edit per item
- Use exact string matching

---

## Goal Identification

Find first incomplete item (`- [ ]`) in each active phase. Format:

```json
{
  "phase": 1,
  "priority": "High",
  "current_goal": "Audit proof dependencies",
  "items_remaining": 12
}
```

---

## Task Recommendations

### Selection

1. First incomplete from highest-priority phase
2. First incomplete from other phases (max 2 per phase)
3. Items in "Near Term" execution order

### Scoring

| Factor | Weight |
|--------|--------|
| High/Medium/Low priority | 3x / 2x / 1x |
| First in phase | +2 |
| In "Near Term" list | +3 |

### Limit

Present max 5-7 recommendations.

### Language Inference

- `.lean` path: `lean`
- `.md` path: `meta`
- `.tex` path: `latex`
- Otherwise: `general`

---

## User Interaction

Prompt user with numbered list. Accept: numbers (e.g., "1,3"), "all", or "none".

---

## Agent Responsibility

Implementation agents **must** populate `roadmap_items` in completion_data:

```json
{
  "completion_data": {
    "completion_summary": "What was accomplished",
    "roadmap_items": ["Exact text from ROAD_MAP.md checkbox"]
  }
}
```

If no roadmap items match the task, use an empty array:
```json
{
  "roadmap_items": []
}
```

See agent documentation for detailed guidance:
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/agents/latex-implementation-agent.md`

---

## Related

- @.claude/context/core/formats/roadmap-format.md - ROAD_MAP.md structure
- @.claude/commands/review.md - Review command with matching logic
- @.claude/skills/skill-todo/SKILL.md - Todo archival with roadmap annotation
