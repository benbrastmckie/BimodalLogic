---
name: skill-refresh
description: Manage Claude Code resources - terminate orphaned processes and clean up ~/.claude/ directory
allowed-tools: Bash, Read, AskUserQuestion
---

# Refresh Skill (Direct Execution)

Direct execution skill for managing Claude Code resources. Performs two operations:
1. **Process cleanup**: Identify and terminate orphaned Claude Code processes
2. **Directory cleanup**: Clean up accumulated files in ~/.claude/

This skill executes inline without spawning a subagent.

## Trigger Conditions

This skill activates when:
- User invokes `/refresh` command
- Memory usage needs investigation
- Orphaned processes need cleanup
- ~/.claude/ directory needs cleanup

## Command Syntax

```
/refresh [--dry-run] [--force]
```

### Options

| Flag | Description |
|------|-------------|
| `--dry-run` | Preview both cleanups without making changes |
| `--force` | Skip confirmation and run with 8-hour default |
| (no flags) | Interactive mode with age selection |

---

## Execution Flow

### Step 1: Parse Arguments

Parse command input for flags:
- `--dry-run`: Preview mode, no changes made
- `--force`: Skip confirmation, use 8-hour default

### Step 2: Run Process Cleanup

First, always run process cleanup:

```bash
.claude/scripts/claude-refresh.sh [--force if specified]
```

Display the process cleanup output to the user.

### Step 3: Run Directory Cleanup Survey

Run the directory cleanup script in survey mode:

```bash
.claude/scripts/claude-cleanup.sh
```

This shows:
- Current ~/.claude/ directory sizes
- Cleanup candidates for each directory
- Total space that can be reclaimed

### Step 4: Handle Based on Mode

#### Dry-Run Mode (`--dry-run`)

Run both scripts in dry-run mode:
```bash
.claude/scripts/claude-refresh.sh
.claude/scripts/claude-cleanup.sh --dry-run --age 8
```

Display the preview and exit without changes.

#### Force Mode (`--force`)

Run process cleanup with force, then directory cleanup with 8-hour default:
```bash
.claude/scripts/claude-refresh.sh --force
.claude/scripts/claude-cleanup.sh --force --age 8
```

Display results and exit.

#### Interactive Mode (Default)

1. Display process cleanup status (from Step 2)

2. If orphaned processes found, prompt for process cleanup:
   ```json
   {
     "question": "Terminate orphaned processes?",
     "header": "Process Cleanup",
     "options": [
       {
         "label": "Yes, terminate",
         "description": "Kill orphaned processes and reclaim memory"
       },
       {
         "label": "Skip",
         "description": "Continue to directory cleanup"
       }
     ]
   }
   ```

3. Display directory cleanup survey (from Step 3)

4. If cleanup candidates found (script exits with code 1), prompt for age selection:
   ```json
   {
     "question": "Select cleanup age threshold:",
     "header": "Directory Cleanup",
     "options": [
       {
         "label": "8 hours (default)",
         "description": "Remove files older than 8 hours"
       },
       {
         "label": "2 days",
         "description": "Remove files older than 2 days (conservative)"
       },
       {
         "label": "Clean slate",
         "description": "Remove everything except safety margin (1 hour)"
       },
       {
         "label": "Cancel",
         "description": "Exit without cleaning directories"
       }
     ]
   }
   ```

5. Map selection to `--age` parameter:
   - "8 hours (default)" → `--age 8`
   - "2 days" → `--age 48`
   - "Clean slate" → `--age 0`
   - "Cancel" → exit

6. Run cleanup with selected age:
   ```bash
   .claude/scripts/claude-cleanup.sh --force --age <selected>
   ```

7. Display cleanup results

---

## Cleanable Directories

The directory cleanup targets these directories in ~/.claude/:

| Directory | Contents | Safe to Clean |
|-----------|----------|---------------|
| projects/ | Session .jsonl files, subdirectories | Yes, by age |
| debug/ | Debug output files | Yes, by age |
| file-history/ | File version snapshots | Yes, by age |
| todos/ | Todo list backups | Yes, by age |
| session-env/ | Environment snapshots | Yes, by age |
| telemetry/ | Usage telemetry data | Yes, by age |
| shell-snapshots/ | Shell state | Yes, by age |
| plugins/cache/ | Old plugin versions | Yes, by age |
| cache/ | General cache | Yes, by age |

---

## Safety Measures

### Process Cleanup

1. **Never kill processes with a TTY** - Active sessions have terminals
2. **Exclude current process tree** - Don't kill the running command
3. **SIGTERM before SIGKILL** - Allow graceful shutdown
4. **Confirmation by default** - Require `--force` to skip

### Directory Cleanup

1. **Never delete protected files**:
   - `sessions-index.json` (in each project directory)
   - `settings.json`
   - `.credentials.json`
   - `history.jsonl` (user command history)

2. **Safety margin**: Files modified within the last hour are never deleted

3. **Age threshold**: Only deletes files older than selected threshold

4. **Dry-run available**: Preview changes before executing

5. **Confirmation by default**: Require `--force` to skip

---

## Integration with Scripts

### Process Cleanup Script

```bash
.claude/scripts/claude-refresh.sh [--force]
```

### Directory Cleanup Script

```bash
.claude/scripts/claude-cleanup.sh [--age HOURS] [--dry-run] [--force]
```

Age options:
- `--age 8`: 8 hours (default)
- `--age 48`: 2 days
- `--age 0`: Clean slate (only safety margin applies)

---

## Return Format

### Combined Output

```
Claude Code Refresh
===================

[Process cleanup output...]

---

Claude Code Directory Cleanup
=============================

Target: ~/.claude/

Current total size: 7.3 GB

Age threshold: 8 hours
Safety margin: 1 hour (files modified within last hour are preserved)

Scanning directories...

Directory                   Total    Cleanable    Files
----------                -------   ----------    -----
projects/                  7.0 GB       6.5 GB      980
debug/                   151.0 MB     140.0 MB      650
file-history/             56.0 MB      50.0 MB     3100
...

TOTAL                      7.3 GB       6.7 GB     4800

Space that can be reclaimed: 6.7 GB

[After cleanup...]

Cleanup Complete
================
Deleted: 4800 files
Failed:  0 files
Space reclaimed: 6.7 GB

New total size: 600.0 MB
```

### Dry Run Output

```
[Survey output...]

Dry Run Summary
===============
Would delete: 4800 files
Would reclaim: 6.7 GB
```

---

## Error Handling

### Permission Denied (Process Mode)
If kill fails due to permissions, report which processes couldn't be terminated.

### No Orphaned Processes
Report "All Claude processes are active sessions."

### Process Already Gone
If process exits between detection and kill, ignore the error and continue.

### Directory Not Found
If ~/.claude doesn't exist, display error message.

### No Cleanup Candidates
Report "No cleanup candidates found. All files are within the age threshold."
