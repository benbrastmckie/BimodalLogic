---
name: research
agent: subagents/researcher
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
routing:
  lean: lean-research-agent
  default: researcher
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`, `/research 172`)

## Purpose

Conduct research for a specified task, create research reports, and update task status to [RESEARCHED]. Supports language-based routing (Lean tasks → lean-research-agent, general tasks → researcher) and topic subdivision via --divide flag.

## Usage

```bash
/research TASK_NUMBER [PROMPT] [FLAGS]
```

### Examples

- `/research 197` - Research task 197 using task description
- `/research 197 "Focus on CLI integration"` - Research with custom focus
- `/research 197 --divide` - Subdivide research into multiple topics

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| TASK_NUMBER | integer | Yes | Task number from .opencode/specs/TODO.md |
| PROMPT | string | No | Optional additional context or focus for research |

### Flags

| Flag | Description |
|------|-------------|
| `--divide` | Subdivide research into multiple topics |

## Workflow

This command follows the 8-stage command-lifecycle.md pattern with language-based routing:

1. **Preflight**: Parse arguments, validate task exists, update status to [RESEARCHING]
2. **CheckLanguage**: Extract language from task entry, determine routing (lean → lean-research-agent, else → researcher)
3. **PrepareDelegation**: Generate session ID, prepare delegation context with timeout (3600s)
4. **InvokeAgent**: Delegate to researcher agent with task context
5. **ValidateReturn**: Verify research artifact created and return format valid
6. **PrepareReturn**: Format return object with artifact paths and summary
7. **Postflight**: Update status to [RESEARCHED], create git commit, verify on disk
8. **ReturnSuccess**: Return standardized result to user

**Implementation**: See `.opencode/agent/subagents/researcher.md` for complete workflow execution details.

## Language-Based Routing

### Language Extraction

Language is extracted from task entry in TODO.md:

```bash
grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
```

If extraction fails, defaults to "general" with warning logged.

### Routing Rules

| Language | Agent | Tools Available |
|----------|-------|----------------|
| `lean` | `lean-research-agent` | LeanExplore, Loogle, LeanSearch, lean-lsp-mcp |
| `markdown` | `researcher` | Web search, documentation review |
| `python` | `researcher` | Web search, documentation review |
| `general` | `researcher` | Web search, documentation review |

**Critical**: Language extraction MUST occur before routing. Incorrect routing bypasses Lean-specific tooling.

## Context Loading

### Routing Stage (Stages 1-3)

Load minimal context for routing decisions:
- `.opencode/context/system/routing-guide.md` (routing logic)

### Execution Stage (Stage 4+)

Researcher agent loads context on-demand per `.opencode/context/index.md`:
- `common/standards/subagent-return-format.md` (return format)
- `common/system/status-markers.md` (status transitions)
- `common/system/artifact-management.md` (lazy directory creation)
- Task entry via `grep -A 50 "^### ${task_number}\." TODO.md` (~2KB vs 109KB full file)
- `state.json` (project state)

Language-specific context:
- If lean: `project/lean4/tools/leansearch-api.md`, `project/lean4/tools/loogle-api.md`
- If markdown: (no additional context)

## Artifacts Created

### Research Report (required)

Path: `.opencode/specs/{task_number}_{slug}/reports/research-001.md`

Contains:
- Research findings and analysis
- Relevant documentation and references
- Recommendations for implementation
- Technical details and considerations

**Note**: Directory created lazily when writing artifact (not during routing).

### Summary (metadata only)

Summary is included in return object metadata (3-5 sentences, <100 tokens), NOT as separate artifact file.

**Rationale**: Protects orchestrator context window from bloat. Full research content is in report artifact.

Reference: `artifact-management.md` "Context Window Protection via Metadata Passing"

## Status Transitions

| From | To | Condition |
|------|-----|-----------|
| [NOT STARTED] | [RESEARCHING] | Research started (Stage 1) |
| [RESEARCHING] | [RESEARCHED] | Research completed successfully (Stage 7) |
| [RESEARCHING] | [RESEARCHING] | Research failed or partial (Stage 7) |
| [RESEARCHING] | [BLOCKED] | Research blocked by dependency (Stage 7) |

**Status Update**: Delegated to `status-sync-manager` for atomic synchronization across TODO.md and state.json.

**Timestamps**: `**Started**: {date}` added in Stage 1, `**Completed**: {date}` added in Stage 7.

## Error Handling

### Task Not Found

```
Error: Task {task_number} not found in .opencode/specs/TODO.md

Recommendation: Verify task number exists in TODO.md
```

### Invalid Task Number

```
Error: Task number must be an integer. Got: {input}

Usage: /research TASK_NUMBER [PROMPT]
```

### Language Extraction Failed

```
Warning: Language not found for task {task_number}, defaulting to 'general'

Proceeding with researcher agent (web search, documentation)
```

### Routing Validation Failed

```
Error: Routing validation failed: language={language}, agent={agent}

Expected: language=lean → agent=lean-research-agent
Got: language=lean → agent=researcher

Recommendation: Fix language extraction or routing logic
```

### Research Timeout

```
Warning: Research timed out after 3600s

Partial artifacts created: {list}

Resume with: /research {task_number}
```

### Status Update Failed

```
Error: Failed to update task status

Details: {error_message}

Artifacts created:
- Research Report: {report_path}

Manual recovery steps:
1. Verify research artifact exists: {report_path}
2. Manually update TODO.md status to [RESEARCHED]
3. Manually update state.json status to "researched"

Or retry: /research {task_number}
```

### Git Commit Failed (non-critical)

```
Warning: Git commit failed

Research completed successfully: {report_path}
Task status updated to [RESEARCHED]

Manual commit required:
  git add {files}
  git commit -m "task {number}: research completed"

Error: {git_error}
```

## Quality Standards

### Research Report Quality

- Comprehensive coverage of topic
- Relevant documentation and references cited
- Clear recommendations for implementation
- Technical details and considerations documented
- NO EMOJI (per documentation.md standards)

### Status Marker Compliance

- Use text-based status markers: [RESEARCHING], [RESEARCHED]
- Include timestamps: **Started**: {date}, **Completed**: {date}
- Follow status-markers.md conventions

### Atomic Updates

- Status updates delegated to status-sync-manager
- Two-phase commit ensures atomicity across TODO.md and state.json
- Rollback on failure to maintain consistency

## Implementation Notes

### Lazy Directory Creation

Directories created only when writing artifacts:
- `.opencode/specs/{task_number}_{slug}/` created when writing first artifact
- `reports/` subdirectory created when writing research-001.md
- `summaries/` NOT created (summary is metadata, not artifact)

### Task Extraction Optimization

Extract only specific task entry from TODO.md to reduce context load:

```bash
grep -A 50 "^### ${task_number}\." .opencode/specs/TODO.md > /tmp/task-${task_number}.md
```

**Impact**: Reduces context from 109KB (full TODO.md) to ~2KB (task entry only), 98% reduction.

### Delegation Safety

- Max delegation depth: 3 (orchestrator → command → agent → utility)
- Timeout: 3600s (1 hour) with partial result recovery
- Session tracking: Unique session_id for all delegations
- Cycle detection: Prevent infinite delegation loops

## References

- **Workflow Pattern**: `.opencode/context/common/workflows/command-lifecycle.md`
- **Agent Implementation**: `.opencode/agent/subagents/researcher.md`
- **Routing Guide**: `.opencode/context/system/routing-guide.md`
- **Context Index**: `.opencode/context/index.md`
- **Status Markers**: `.opencode/context/common/system/status-markers.md`
- **Artifact Management**: `.opencode/context/common/system/artifact-management.md`
- **Return Format**: `.opencode/context/common/standards/subagent-return-format.md`
