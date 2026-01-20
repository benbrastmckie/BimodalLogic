# Integration Example: Learn Flow

This example traces a complete `/learn` command through all three layers of the ProofChecker agent system, showing how the command extracts tags from source files and creates structured tasks.

---

## Scenario

A user runs `/learn Logos/ --dry-run` to preview what tasks would be created from embedded tags in the Logos directory, then runs `/learn Logos/` to create the tasks.

---

## Tag Types and Task Generation

The `/learn` command recognizes three tag types in source code comments:

| Tag | Task Type | Behavior |
|-----|-----------|----------|
| `FIX:` | fix-it-task | All FIX: and NOTE: tags grouped into single task |
| `NOTE:` | fix-it-task + learn-it-task | Creates two task types |
| `TODO:` | todo-task | One task per TODO: tag |

---

## Complete Flow Diagram

```
User Input: /learn Logos/ --dry-run
       |
       v
[Layer 1: Command] .claude/commands/learn.md
       |
       | Frontmatter specifies: allowed-tools: Skill
       v
[Layer 2: Skill] skill-learn/SKILL.md
       |
       | 1. Parse arguments -> paths = ["Logos/"], mode = "dry_run"
       | 2. Prepare delegation context
       | 3. Invoke learn-agent via Task tool
       v
[Layer 3: Agent] learn-agent.md
       |
       | 1. Parse delegation context
       | 2. Validate paths exist
       | 3. Scan for tags using grep patterns
       | 4. Categorize tags by type
       | 5. Generate task preview (dry-run)
       | 6. Write metadata file
       | 7. Return text summary
       v
[Return Flow]
       |
       | Agent -> Skill -> User
       v
Output: Preview of 5 tasks from 12 tags across 8 files
```

---

## Step-by-Step Walkthrough: Dry Run

### Step 1: User Invokes Command (Dry Run)

```bash
/learn Logos/ --dry-run
```

Claude Code reads `.claude/commands/learn.md` and sees:

```yaml
---
description: Scan files for FIX:, NOTE:, TODO: tags and create structured tasks
allowed-tools: Skill
argument-hint: [PATH...] [--dry-run]
---
```

### Step 2: Skill Receives Command

The skill (`skill-learn/SKILL.md`) parses arguments:

```
Input: $ARGUMENTS = "Logos/ --dry-run"
Parsed:
  paths = ["Logos/"]
  mode = "dry_run"
```

**Skill Step 1: Prepare Delegation Context**

```json
{
  "session_id": "sess_1736700000_abc123",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "learn", "skill-learn"],
  "timeout": 3600,
  "mode": "dry_run",
  "paths": ["Logos/"],
  "metadata_file_path": ".claude/.return-meta-learn.json"
}
```

**Skill Step 2: Invoke Subagent**

The skill invokes `learn-agent` via the Task tool.

### Step 3: Agent Executes Tag Extraction

The agent (`learn-agent.md`) receives the delegation context.

**Agent Stage 1: Validate Paths**

```bash
# Check path exists
if [ -d "Logos/" ]; then
  echo "[INFO] Path validated: Logos/"
fi
```

**Agent Stage 2: Scan for Tags**

Execute grep patterns for each file type:

```bash
# Lean files
grep -rn --include="*.lean" "-- \(FIX\|NOTE\|TODO\):" Logos/

# Example output:
Logos/Layer1/Modal.lean:67:-- TODO: Add completeness theorem for S5
Logos/Layer1/Modal.lean:89:-- FIX: Handle edge case in frame validation
Logos/Layer2/Temporal.lean:45:-- NOTE: This pattern should be documented
Logos/Shared/Utils.lean:23:-- TODO: Optimize this function
```

**Agent Stage 3: Parse and Categorize Tags**

```json
{
  "fix_tags": [
    {"file": "Logos/Layer1/Modal.lean", "line": 89, "content": "Handle edge case in frame validation"}
  ],
  "note_tags": [
    {"file": "Logos/Layer2/Temporal.lean", "line": 45, "content": "This pattern should be documented"}
  ],
  "todo_tags": [
    {"file": "Logos/Layer1/Modal.lean", "line": 67, "content": "Add completeness theorem for S5"},
    {"file": "Logos/Shared/Utils.lean", "line": 23, "content": "Optimize this function"}
  ]
}
```

**Agent Stage 4: Generate Preview**

Since mode is "dry_run", generate preview without creating tasks:

```
Tasks that would be created:
1. fix-it-task: "Fix issues from FIX:/NOTE: tags" (2 items)
2. learn-it-task: "Update context files from NOTE: tags" (1 item)
3. todo-task: "Add completeness theorem for S5"
4. todo-task: "Optimize this function"

Total: 4 tasks from 4 tags
```

**Agent Stage 5: Write Metadata File**

```json
{
  "status": "preview",
  "summary": "Found 4 tags across 3 files. Would create 4 tasks.",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_1736700000_abc123",
    "agent_type": "learn-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"],
    "mode": "dry_run",
    "files_scanned": 15,
    "tags_found": {
      "fix": 1,
      "note": 1,
      "todo": 2
    },
    "tasks_preview": 4
  },
  "next_steps": "Run /learn Logos/ without --dry-run to create tasks"
}
```

**Agent Stage 6: Return Text Summary**

```
Learn dry-run - preview of tag scan:
- Scanned 15 files in Logos/
- Found: 1 FIX:, 1 NOTE:, 2 TODO: tags
- Would create: 1 fix-it task, 1 learn-it task, 2 todo-tasks
- Run /learn Logos/ without --dry-run to create tasks
- Metadata written for skill postflight
```

### Step 4: User Reviews and Runs Execute

After reviewing the dry-run output, user runs:

```bash
/learn Logos/
```

---

## Step-by-Step Walkthrough: Execute

### Step 1: Agent Creates Tasks

**Agent Stage 4: Create Tasks (Execute Mode)**

**Fix-It Task Creation**:
```json
{
  "title": "Fix issues from FIX:/NOTE: tags",
  "description": "Address 2 items from embedded tags:\n\n- Logos/Layer1/Modal.lean:89 - Handle edge case in frame validation\n- Logos/Layer2/Temporal.lean:45 - This pattern should be documented",
  "language": "lean",
  "priority": "high",
  "effort": "2-4 hours"
}
```

**Learn-It Task Creation**:
```json
{
  "title": "Update context files from NOTE: tags",
  "description": "Update 1 context files based on learnings:\n\n- .claude/context/project/lean4/ - This pattern should be documented (from Logos/Layer2/Temporal.lean:45)",
  "language": "meta",
  "priority": "medium",
  "effort": "1-2 hours"
}
```

**Todo-Task Creation** (one per TODO: tag):
```json
{
  "title": "Add completeness theorem for S5",
  "description": "Add completeness theorem for S5\n\nSource: Logos/Layer1/Modal.lean:67",
  "language": "lean",
  "priority": "medium",
  "effort": "1 hour"
}
```

**Agent Stage 5: Update State Files**

```bash
# Get next task numbers
next_num=$(jq -r '.next_project_number' specs/state.json)  # Returns 650

# Create 4 tasks: 650, 651, 652, 653
# Update state.json with new tasks
# Update TODO.md with task entries
# Increment next_project_number to 654
```

**Agent Stage 6: Write Metadata File**

```json
{
  "status": "tasks_created",
  "summary": "Created 4 tasks from 4 tags across 3 files",
  "artifacts": [
    {
      "type": "task_entry",
      "path": "specs/TODO.md",
      "summary": "Tasks #650-653 added"
    }
  ],
  "metadata": {
    "session_id": "sess_1736700100_def456",
    "agent_type": "learn-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "learn", "learn-agent"],
    "mode": "execute",
    "files_scanned": 15,
    "tags_found": {
      "fix": 1,
      "note": 1,
      "todo": 2
    },
    "tasks_created": 4,
    "task_numbers": [650, 651, 652, 653]
  },
  "next_steps": "Run /research 650 to begin research on first task"
}
```

### Step 2: Skill Handles Postflight

**Skill Postflight: Git Commit**

```bash
git add specs/TODO.md specs/state.json
git commit -m "learn: create 4 tasks from tags

Session: sess_1736700100_def456

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Skill Postflight: Cleanup**

```bash
rm -f .claude/.return-meta-learn.json
```

### Step 3: User Sees Results

```
## Tasks Created from Tags

**Tags Processed**: 4 across 3 files

### Created Tasks

| # | Type | Title | Priority | Language |
|---|------|-------|----------|----------|
| 650 | fix-it | Fix issues from FIX:/NOTE: tags | High | lean |
| 651 | learn-it | Update context files from NOTE: tags | Medium | meta |
| 652 | todo | Add completeness theorem for S5 | Medium | lean |
| 653 | todo | Optimize this function | Medium | lean |

---

**Next Steps**:
1. Review tasks in TODO.md
2. Run `/research 650` to begin
3. Progress through /research -> /plan -> /implement cycle
```

---

## Tag Detection Examples

### Lean Files (.lean)

```lean
-- FIX: This needs to handle the empty frame case
-- NOTE: The S5 axiom pattern could be generalized
-- TODO: Add reflexivity lemma
```

### LaTeX Files (.tex)

```latex
% FIX: Correct the citation format
% NOTE: This theorem should be referenced in the appendix
% TODO: Add proof sketch for completeness
```

### Markdown Files (.md)

```markdown
<!-- FIX: Update outdated section -->
<!-- NOTE: Consider reorganizing these examples -->
<!-- TODO: Add code examples -->
```

### Python/Shell Files

```python
# FIX: Handle edge case when input is empty
# NOTE: This algorithm could be optimized
# TODO: Add unit tests
```

---

## Context Routing for NOTE: Tags

NOTE: tags are special because they create both fix-it and learn-it tasks. The learn-it task routes to appropriate context directories:

| Source File Pattern | Target Context Directory |
|--------------------|-------------------------|
| `.claude/agents/*.md` | `.claude/context/core/agents/` |
| `.claude/skills/*/SKILL.md` | `.claude/context/core/skills/` |
| `.claude/commands/*.md` | `.claude/context/core/commands/` |
| `Logos/**/*.lean` | `.claude/context/project/lean4/` |
| `docs/*.tex` | `.claude/context/project/logic/` |

---

## Error Scenarios

### Scenario A: No Tags Found

If user runs `/learn Logos/` but no tags exist:

```
Learn scan - no tags found:
- Scanned 42 files in Logos/
- No FIX:, NOTE:, or TODO: tags detected
- Nothing to create
- Metadata written for skill postflight
```

### Scenario B: Invalid Path

If user runs `/learn nonexistent/`:

```
Learn failed:
- Path not found: nonexistent/
- No valid paths to scan
- Metadata written with failed status
```

### Scenario C: Large Number of Tasks

If more than 10 tasks would be created, the agent includes a warning:

```
Warning: About to create 15 tasks. This is a large number.
Consider using /learn --dry-run to review tags first.

Proceeding with task creation...
```

---

## Summary

This example demonstrated:

1. **Dry-Run Mode**: Preview tasks without creating them
2. **Tag Extraction**: Using grep patterns for multiple file types
3. **Task Grouping**: FIX:/NOTE: grouped into fix-it task, TODO: individual tasks
4. **Context Routing**: NOTE: tags route to appropriate context directories for learn-it tasks
5. **Postflight**: Git commit after task creation
6. **Error Handling**: Graceful handling of no tags or invalid paths

The `/learn` command provides:
- Automated task discovery from embedded source comments
- Structured task creation following project standards
- Preview mode for safe review before action
- Integration with existing task workflow

---

## Related Documentation

- [Research Flow Example](research-flow-example.md) - End-to-end research flow
- [Creating Commands](../guides/creating-commands.md) - Command creation guide
- [Creating Agents](../guides/creating-agents.md) - Agent creation guide
- `.claude/commands/learn.md` - Command definition
- `.claude/skills/skill-learn/SKILL.md` - Skill definition
- `.claude/agents/learn-agent.md` - Agent definition

---

**Document Version**: 1.0
**Created**: 2026-01-20
**Maintained By**: ProofChecker Development Team
