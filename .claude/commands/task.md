---
description: Create, recover, divide, sync, or abandon tasks
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), TodoWrite
argument-hint: "description" | --recover N | --divide N | --sync | --abandon N
model: claude-opus-4-5-20251101
---

# /task Command

Unified task lifecycle management. Parse $ARGUMENTS to determine operation mode.

## Mode Detection

Check $ARGUMENTS for flags:
- `--recover RANGES` → Recover tasks from archive
- `--divide N [prompt]` → Divide task into subtasks
- `--sync` → Sync TODO.md with state.json
- `--abandon RANGES` → Archive tasks
- No flag → Create new task with description

## Create Task Mode (Default)

When $ARGUMENTS contains a description (no flags):

### Steps

1. **Read state.json** for next_project_number:
   ```
   Read .opencode/specs/state.json
   Extract next_project_number (e.g., 346)
   ```

2. **Parse description** from $ARGUMENTS:
   - Remove any trailing flags (--priority, --effort, --language)
   - Extract optional: priority (default: medium), effort, language

3. **Detect language** from keywords:
   - "lean", "theorem", "proof", "lemma", "Mathlib" → lean
   - "meta", "agent", "command", "skill" → meta
   - Otherwise → general

4. **Create slug** from description:
   - Lowercase, replace spaces with underscores
   - Remove special characters
   - Max 50 characters

5. **Create task directory**:
   ```
   mkdir -p .opencode/specs/{NUMBER}_{SLUG}
   ```

6. **Update state.json**:
   - Increment next_project_number
   - Add to active_projects array:
     ```json
     {
       "project_number": N,
       "project_name": "slug",
       "status": "not_started",
       "language": "detected",
       "priority": "medium",
       "created": "ISO_TIMESTAMP",
       "last_updated": "ISO_TIMESTAMP"
     }
     ```

7. **Update TODO.md**:
   - Add entry under appropriate priority section:
     ```markdown
     ### {N}. {Title}
     - **Effort**: {estimate}
     - **Status**: [NOT STARTED]
     - **Priority**: {priority}
     - **Language**: {language}

     **Description**: {description}
     ```

8. **Git commit**:
   ```
   git add .opencode/specs/
   git commit -m "task {N}: create {title}"
   ```

9. **Output**:
   ```
   Task #{N} created: {TITLE}
   Status: [NOT STARTED]
   Language: {language}
   Path: .opencode/specs/{N}_{SLUG}/
   ```

## Recover Mode (--recover)

Parse task ranges after --recover (e.g., "343-345", "337, 343"):

1. For each task number in range:
   - Find in .opencode/specs/archive/state.json
   - Move entry back to state.json active_projects
   - Update TODO.md with recovered entry
   - Update status to [NOT STARTED]

2. Git commit: "task: recover tasks {ranges}"

## Divide Mode (--divide)

Parse task number and optional prompt:

1. Read task from state.json
2. Analyze description for natural breakpoints
3. Create 2-5 subtasks with sequential numbers
4. Update original task with subtask references
5. Git commit: "task {N}: divide into subtasks"

## Sync Mode (--sync)

1. Read both TODO.md and state.json
2. Compare entries for consistency
3. Use git blame to determine "latest wins"
4. Sync discrepancies
5. Git commit: "sync: reconcile TODO.md and state.json"

## Abandon Mode (--abandon)

Parse task ranges:

1. For each task:
   - Move from state.json active_projects to archive/state.json
   - Update TODO.md status to [ABANDONED]
   - Move task directory to archive/ (optional)

2. Git commit: "task: abandon tasks {ranges}"

## Constraints

**FORBIDDEN**: This command ONLY manages task entries. Never:
- Implement tasks
- Create code files
- Run build tools
- Modify source code
