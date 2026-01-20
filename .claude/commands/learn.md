---
description: Scan files for FIX:, NOTE:, TODO: tags and create structured tasks interactively
allowed-tools: Skill
argument-hint: [PATH...]
model: claude-opus-4-5-20251101
---

# /learn Command

Scans codebase files for embedded tags (`FIX:`, `NOTE:`, `TODO:`) and creates structured tasks based on user selection. This command helps capture work items embedded in source code comments.

## Arguments

- No args: Scan entire project for tags
- `PATH...` - Scan specific files or directories

## Interactive Flow

The command always runs interactively:
1. Scan files for tags
2. Display tag summary to user
3. Prompt for task type selection
4. Optionally prompt for individual TODO selection
5. Create selected tasks

This design ensures users always see what was found before any tasks are created.

## Tag Types and Task Generation

| Tag | Task Type | Description |
|-----|-----------|-------------|
| `FIX:` | fix-it-task | Grouped into single task for small changes |
| `NOTE:` | fix-it-task + learn-it-task | Creates both task types |
| `TODO:` | todo-task | Individual task per selected tag |

### Task Type Details

**fix-it-task**: Combines all FIX: and NOTE: tags into a single task describing fixes needed. Includes file paths and line references. Only offered if FIX: or NOTE: tags exist.

**learn-it-task**: Groups NOTE: tags by target context directory. Creates tasks to update `.claude/context/` files based on the learnings. Only offered if NOTE: tags exist.

**todo-task**: One task per selected TODO: tag. Preserves original text as task description. Language detected from source file type.

## Supported Comment Styles

| File Type | Comment Prefix | Example |
|-----------|----------------|---------|
| Lean (`.lean`) | `--` | `-- FIX: Handle edge case` |
| LaTeX (`.tex`) | `%` | `% NOTE: Document this pattern` |
| Markdown (`.md`) | `<!--` | `<!-- TODO: Add section -->` |
| Python/Shell/YAML | `#` | `# FIX: Optimize loop` |

## Execution

### 1. Scan and Display

The skill scans specified paths and displays findings:

```
## Tag Scan Results

**Files Scanned**: Logos/, docs/
**Tags Found**: 15

### FIX: Tags (5)
- `src/module.lean:23` - Handle edge case in parser
- `src/module.lean:45` - Fix off-by-one error
...

### NOTE: Tags (3)
- `docs/guide.tex:89` - Document this pattern
...

### TODO: Tags (7)
- `Logos/Layer1/Modal.lean:67` - Add completeness theorem
...
```

### 2. Task Type Selection

User selects which task types to create:

```
[Task Types]
Which task types should be created?

[ ] fix-it task (Combine 8 FIX:/NOTE: tags into single task)
[ ] learn-it task (Update context from 3 NOTE: tags)
[ ] TODO tasks (Create tasks for 7 TODO: items)
```

### 3. TODO Item Selection

If "TODO tasks" is selected, user picks individual items:

```
[TODO Selection]
Select TODO items to create as tasks:

[ ] Add completeness theorem (Logos/Layer1/Modal.lean:67)
[ ] Implement helper function (Shared/Utils.lean:23)
...
```

For >20 TODO items, a "Select all" option is added.

### 4. Task Creation

Selected tasks are created in TODO.md and state.json.

## Output Examples

### Tags Found - Interactive Selection

```
## Tag Scan Results

**Files Scanned**: .
**Tags Found**: 15

### FIX: Tags (5)
- `src/module.lean:23` - Handle edge case in parser
- `src/module.lean:45` - Fix off-by-one error
- `docs/guide.tex:56` - Update outdated reference

### NOTE: Tags (3)
- `docs/guide.tex:89` - Document this pattern
- `.claude/agents/foo.md:12` - Update context routing

### TODO: Tags (7)
- `Logos/Layer1/Modal.lean:67` - Add completeness theorem
- `Logos/Shared/Utils.lean:23` - Implement helper function
...

---

[User selects task types and TODO items]

---

## Tasks Created from Tags

**Tags Processed**: 15

### Created Tasks

| # | Type | Title | Priority | Language |
|---|------|-------|----------|----------|
| 650 | fix-it | Fix issues from FIX:/NOTE: tags | High | lean |
| 651 | learn-it | Update context files from NOTE: tags | Medium | meta |
| 652 | todo | Add completeness theorem | Medium | lean |
| 653 | todo | Implement helper function | Medium | lean |

---

**Next Steps**:
1. Review tasks in TODO.md
2. Run `/research 650` to begin
3. Progress through /research -> /plan -> /implement cycle
```

### No Tags Found

```
## No Tags Found

Scanned files in: Logos/
No FIX:, NOTE:, or TODO: tags detected.

Nothing to create.
```

### No Selection Made

```
## Tag Scan Results
...

---

No task types selected. No tasks created.
```

## Examples

```bash
# Scan entire project interactively
/learn

# Scan specific directory
/learn Logos/Layer1/

# Scan specific file
/learn docs/04-Metalogic.tex

# Scan multiple paths
/learn Logos/ .claude/agents/
```

## Notes

- The `--dry-run` flag is no longer supported. The interactive flow is inherently "preview first" - users always see findings before any tasks are created.
- Git commit is performed automatically after tasks are created.
- Task numbers are assigned sequentially from state.json.
