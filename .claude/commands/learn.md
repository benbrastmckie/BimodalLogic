---
description: Scan files for FIX:, NOTE:, TODO: tags and create structured tasks
allowed-tools: Skill
argument-hint: [PATH...] [--dry-run]
model: claude-opus-4-5-20251101
---

# /learn Command

Scans codebase files for embedded tags (`FIX:`, `NOTE:`, `TODO:`) and creates structured tasks based on tag types. This command helps capture work items embedded in source code comments.

## Arguments

- No args: Scan entire project for tags
- `PATH...` - Scan specific files or directories
- `--dry-run` - Preview tasks without creating them

## Tag Types and Task Generation

| Tag | Task Type | Description |
|-----|-----------|-------------|
| `FIX:` | fix-it-task | Grouped into single task for small changes |
| `NOTE:` | fix-it-task + learn-it-task | Creates both task types |
| `TODO:` | todo-task | Individual task per tag |

### Task Type Details

**fix-it-task**: Combines all FIX: and NOTE: tags into a single task describing fixes needed. Includes file paths and line references. Created only if FIX: or NOTE: tags exist.

**learn-it-task**: Groups NOTE: tags by target context directory. Creates tasks to update `.claude/context/` files based on the learnings. Created only if NOTE: tags exist.

**todo-task**: One task per TODO: tag. Preserves original text as task description. Language detected from source file type.

## Supported Comment Styles

| File Type | Comment Prefix | Example |
|-----------|----------------|---------|
| Lean (`.lean`) | `--` | `-- FIX: Handle edge case` |
| LaTeX (`.tex`) | `%` | `% NOTE: Document this pattern` |
| Markdown (`.md`) | `<!--` | `<!-- TODO: Add section -->` |
| Python/Shell/YAML | `#` | `# FIX: Optimize loop` |

## Execution

### 1. Mode Detection

```
if $ARGUMENTS contains "--dry-run":
    mode = "dry_run"
    paths = extract paths from $ARGUMENTS (excluding --dry-run)
elif $ARGUMENTS is empty:
    mode = "execute"
    paths = ["."]  # Project root
else:
    mode = "execute"
    paths = $ARGUMENTS
```

### 2. Delegate to Skill

Invoke skill-learn via Skill tool with:
- Mode (execute or dry_run)
- Paths to scan

The skill will:
1. Validate inputs
2. Prepare delegation context
3. Invoke learn-agent
4. Handle postflight (git commit if tasks created)
5. Return results

### 3. Present Results

Based on agent return:
- **Dry-run mode**: Display tag summary and preview tasks
- **Execute mode**: Display created tasks and next steps
- **No tags found**: Report gracefully

## Output

### Dry-Run Output

```
## Tag Scan Results (Dry Run)

**Files Scanned**: 42
**Tags Found**: 15

### FIX: Tags (5)
- `src/module.lean:23` - Handle edge case in parser
- `src/module.lean:45` - Fix off-by-one error

### NOTE: Tags (3)
- `docs/guide.tex:89` - Document this pattern
- `.claude/agents/foo.md:12` - Update context routing

### TODO: Tags (7)
- `Logos/Layer1/Modal.lean:67` - Add completeness theorem

---

**Tasks That Would Be Created**:
1. fix-it-task: "Fix issues from FIX:/NOTE: tags" (5 items)
2. learn-it-task: "Update context files from NOTE: tags" (3 items)
3. todo-task: "Add completeness theorem" (Layer1)
4. todo-task: "Implement helper function" (Shared)
...

Run `/learn` without --dry-run to create these tasks.
```

### Execute Output

```
## Tasks Created from Tags

**Tags Processed**: 15 across 42 files

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
2. Run `/research {first_task}` to begin
3. Progress through /research -> /plan -> /implement cycle
```

### No Tags Found

```
## No Tags Found

Scanned 42 files in specified paths.
No FIX:, NOTE:, or TODO: tags detected.

Nothing to create.
```

## Examples

```bash
# Scan entire project (dry run first)
/learn --dry-run

# Scan entire project and create tasks
/learn

# Scan specific directory
/learn Logos/Layer1/

# Scan specific file
/learn docs/04-Metalogic.tex

# Scan multiple paths
/learn Logos/ .claude/agents/ --dry-run
```

## Confirmation Flow

When not in dry-run mode and more than 10 tasks would be created:
1. Display task count warning
2. Require explicit confirmation before proceeding
3. User can cancel to review with --dry-run first
