---
name: skill-refresh
description: Manage Claude Code resources - terminate orphaned processes or clean up old project files
allowed-tools: Bash, Read, AskUserQuestion
---

# Refresh Skill (Direct Execution)

Direct execution skill for managing Claude Code resources. Supports two modes:
- **Process cleanup** (default): Identify and terminate orphaned Claude Code processes
- **Project cleanup** (`--projects`): Survey and clean up accumulated project files

This skill executes inline without spawning a subagent.

## Trigger Conditions

This skill activates when:
- User invokes `/refresh` command
- Memory usage needs investigation
- Orphaned processes need cleanup
- Project files need cleanup

## Command Syntax

```
/refresh [--force]                              # Process cleanup mode
/refresh --projects [--age DAYS] [--dry-run] [--force]  # Project cleanup mode
```

### Process Cleanup Options

| Flag | Description |
|------|-------------|
| `--force` | Terminate orphaned processes immediately |
| (no flags) | Show status and prompt for confirmation |

### Project Cleanup Options

| Flag | Description |
|------|-------------|
| `--projects` | Enable project file cleanup mode |
| `--age DAYS` | Only target sessions older than DAYS (default: 7) |
| `--dry-run` | Show what would be cleaned without changes |
| `--force` | Skip confirmation and clean immediately |

---

## Mode Detection

Parse command input to determine mode:

```
if "--projects" in arguments:
    mode = "projects"
else:
    mode = "processes"
```

---

## Process Cleanup Mode (Default)

### 1. Parse Arguments

Parse command flags from input:
- `--force`: Skip confirmation and terminate immediately

### 2. Run Detection Script

Execute the detection script to get status:
```bash
.claude/scripts/claude-refresh.sh
```

The script will output:
- Process counts (total, active, orphaned)
- Memory usage breakdown
- List of orphaned processes with PID, memory, age, and command
- Exit without terminating (unless --force is passed)

### 3. Handle Based on Mode

#### Force Mode (--force flag provided)

Run the script with --force to terminate immediately:
```bash
.claude/scripts/claude-refresh.sh --force
```

Display the termination results and exit.

#### Default Mode (no flags)

1. Display the status output from the script
2. If orphaned processes were found, use AskUserQuestion for confirmation:

```json
{
  "question": "Terminate these orphaned processes?",
  "header": "Confirm Cleanup",
  "options": [
    {
      "label": "Yes, terminate",
      "description": "Kill orphaned processes and reclaim memory"
    },
    {
      "label": "Cancel",
      "description": "Exit without changes"
    }
  ]
}
```

3. If user confirms, run the script with --force:
```bash
.claude/scripts/claude-refresh.sh --force
```

4. Display the termination results

---

## Project Cleanup Mode (--projects)

### 1. Parse Arguments

Extract options from arguments:
- `--age DAYS`: Age threshold (default: 7)
- `--dry-run`: Preview mode
- `--force`: Skip confirmation

Build script arguments:
```bash
SCRIPT_ARGS=""
if age_specified:
    SCRIPT_ARGS="$SCRIPT_ARGS --age $AGE_DAYS"
if dry_run:
    SCRIPT_ARGS="$SCRIPT_ARGS --dry-run"
if force:
    SCRIPT_ARGS="$SCRIPT_ARGS --force"
```

### 2. Run Project Cleanup Script

Execute the project cleanup script:
```bash
.claude/scripts/claude-project-cleanup.sh $SCRIPT_ARGS
```

The script will output:
- Project path and directory location
- Current disk usage statistics
- Cleanup candidates by age threshold
- Size that can be reclaimed

### 3. Handle Based on Flags

#### Dry-Run Mode (--dry-run)

Script runs and shows what would be deleted without making changes.
Exit after displaying results.

#### Force Mode (--force)

Script runs and performs cleanup immediately.
Display the results and exit.

#### Default Mode (no --force or --dry-run)

1. Display the survey output from the script
2. If cleanup candidates were found (script exits with code 1), use AskUserQuestion for confirmation:

```json
{
  "question": "Clean up these old project files?",
  "header": "Confirm Project Cleanup",
  "options": [
    {
      "label": "Yes, clean up",
      "description": "Delete old session files and reclaim disk space"
    },
    {
      "label": "Cancel",
      "description": "Exit without changes"
    }
  ]
}
```

3. If user confirms, run the script with --force (preserving other options):
```bash
.claude/scripts/claude-project-cleanup.sh $SCRIPT_ARGS --force
```

4. Display the cleanup results

### 4. Handle Errors

If the project directory doesn't exist:
- Display error message with expected directory path
- Suggest running from a valid project directory

---

## Safety Measures

### Process Cleanup

1. **Never kill processes with a TTY** - Active sessions have terminals
2. **Exclude current process tree** - Don't kill the running command
3. **SIGTERM before SIGKILL** - Allow graceful shutdown
4. **Confirmation by default** - Require `--force` to skip

### Project Cleanup

1. **Never modify sessions-index.json** - System file managed by Claude Code
2. **Never delete recently modified files** - Files modified within last hour are protected
3. **Age threshold** - Only targets old sessions (default: 7 days)
4. **Dry-run available** - Preview changes before executing
5. **Confirmation by default** - Require `--force` to skip

---

## Integration with Scripts

### Process Cleanup Script

The skill delegates to `.claude/scripts/claude-refresh.sh` for process management:

```bash
.claude/scripts/claude-refresh.sh [--force]
```

### Project Cleanup Script

The skill delegates to `.claude/scripts/claude-project-cleanup.sh` for project file cleanup:

```bash
.claude/scripts/claude-project-cleanup.sh [--age DAYS] [--dry-run] [--force]
```

This separation allows:
- CLI usage outside Claude Code
- Integration with shell aliases
- systemd timer automation

---

## Return Format

### Process Mode - No Orphans

```
Claude Code Refresh
===================

No orphaned processes found.
All N Claude processes are active sessions.
```

### Process Mode - After Cleanup

```
Claude Code Refresh
===================

Found N orphaned processes using X MB:

PID      Memory       Age        Command
-----    -------      -------    --------------------------------
12345    450 MB       2h 15m     node /path/to/claude-code/...
...

Terminating orphaned processes...
  PID 12345: terminated (graceful)
  ...

Claude Code Cleanup Complete
============================
Terminated: N processes
Failed:     0 processes
Memory reclaimed: ~X MB

Active sessions preserved: M
```

### Project Mode - No Candidates

```
Claude Code Project Cleanup
===========================

Project: /path/to/project
Directory: ~/.claude/projects/-path-to-project/

Current Usage:
  Total size:        X GB
  Session dirs:      N
  JSONL log count:   M

No cleanup candidates found (age threshold: 7 days)
```

### Project Mode - With Candidates (Survey)

```
Claude Code Project Cleanup
===========================

Project: /path/to/project
Directory: ~/.claude/projects/-path-to-project/

Current Usage:
  Total size:        9.7 GB
  Session dirs:      367
  JSONL log count:   567

Cleanup Candidates (sessions older than 7 days):
  JSONL files:       232
  Session dirs:      163
  Total size:        244.5 MB
  Largest:           326dd164... (11.2 MB, 9d 8h old)

Total space that can be reclaimed: 244.5 MB
```

### Project Mode - After Cleanup

```
Cleaning up old sessions...

  Deleted: 326dd164....jsonl (11.2 MB)
  Deleted: abc12345.../ (5.3 MB)
  ...

Claude Code Project Cleanup Complete
====================================
Deleted files: 232
Deleted dirs:  163
Failed:        0
Space reclaimed: 244.5 MB
```

### Project Mode - Dry Run

```
Dry run - showing what would be deleted:

  Would delete: 326dd164....jsonl (11.2 MB)
  Would delete: abc12345.../ (5.3 MB)
  ...

Dry Run Summary
===============
Would delete: 232 JSONL files
Would delete: 163 session directories
Would reclaim: 244.5 MB
```

---

## Error Handling

### Permission Denied (Process Mode)
If kill fails due to permissions, report which processes couldn't be terminated.

### No Orphaned Processes
Report "All Claude processes are active sessions."

### Process Already Gone
If process exits between detection and kill, ignore the error and continue.

### Project Directory Not Found (Project Mode)
If the project directory doesn't exist in ~/.claude/projects/, display:
```
Error: Could not survey project directory
Directory: ~/.claude/projects/-path-to-project/
```
